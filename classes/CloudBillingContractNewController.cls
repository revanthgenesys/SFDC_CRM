public class CloudBillingContractNewController {
    
    //New Contract
    public GCR_Content_Document_Detail__c objNewContract {get; set;}
    //New Contract Address
    public Account_Order_Address__c objNewContractAddress {get; set;}
    //Quote Opportunity
   	public Opportunity objUIOpportunity {get; private set;}
    //Quote Options
    public BigMachines__Quote__c  objUIQuote {get; private set;}
    // Direct Sales
    //public Boolean blnDirectSales {get; set;}
    
	public List<SelectOption> selectQuoteRecordType  {get; private set;}
    public String quoteRecordTypeSelectedField {get; set;}

    public List<SelectOption> selectOpportunityRecordType  {get; private set;}
    public String opportunityRecordTypeSelectedField {get; set;}

    public CloudBillingContractNewController(ApexPages.StandardController controller){
        
        objNewContract = new GCR_Content_Document_Detail__c();
        objNewContractAddress= new Account_Order_Address__c();
        objUIOpportunity = new Opportunity();
        objUIQuote = new BigMachines__Quote__c();

        selectQuoteRecordType = new List<SelectOption>();
        List<RecordType> listQuoteRecordType = [select id,Name from RecordType where SobjectType = 'BigMachines__Quote__c'];
        for (RecordType objRecordType : listQuoteRecordType) {
            selectQuoteRecordType.add(new SelectOption(objRecordType.Id,objRecordType.Name));
        }

        selectOpportunityRecordType = new List<SelectOption>();
		List<RecordType> listOppRecordType = [select id,Name from RecordType where SobjectType = 'Opportunity'];
        for (RecordType objRecordType : listOppRecordType) {
            selectOpportunityRecordType.add(new SelectOption(objRecordType.Id,objRecordType.Name));
        }

    }


    //ECD
    public BigMachines__Quote__c createQuote(GCR_Content_Document_Detail__c objContractInserted) {
        GCR_Content_Document_Detail__c objContract = [select Id, Name, Account_Name__c
                                                         from GCR_Content_Document_Detail__c where Id = :objContractInserted.Id];
        if (objNewContract == null) {
            System.debug('objNewContract is null');
            return null;
        }
        
        objUIQuote.Name = 'CB-' + objContract.Name;
        if (objUIQuote.Sold_To_Name__c == null) {
            objUIQuote.Sold_To_Name__c = objContract.Account_Name__c;
        }
        objUIQuote.Offering_Type__c = objUIOpportunity.Lines_of_Businesses__c;
        objUIQuote.Billing_Period__c = objUIOpportunity.Frequency_Term__c;

        Opportunity objOpportunity = new Opportunity(Name = 'CB-' + objContract.Name,
                                                     Lines_of_Businesses__c = objUIOpportunity.Lines_of_Businesses__c,
                                                     Lead_Offer__c = objUIOpportunity.Lead_Offer__c,
                                                     CloseDate = Date.today(),
                                                     StageName = 'Closed',
                                                     BusinessPartner__c = objContract.Account_Name__c, // required to pass trigger
                                                     AccountId = objContract.Account_Name__c,
                                                     Status__c = 'Closed',
                                                     Is_Business_Consulting_Engaged__c = 'No'
                                                    );
		objOpportunity.RecordTypeId = opportunityRecordTypeSelectedField;
        insert objOpportunity;

        objUIQuote.BigMachines__Opportunity__c = objOpportunity.Id;

        System.Debug('Selected Record Type ' + quoteRecordTypeSelectedField);
		objUIQuote.RecordTypeId = quoteRecordTypeSelectedField;

        return objUIQuote;
    }

    
    public PageReference saveBtnHandler(){
        if(validateInput()){
            SavePoint objSP = Database.setSavepoint();
            try{
                //Validate Data
                objNewContract.Document_Name__c = 'Cloud Billing Contract';
                objNewContract.Order_Date_Option__c = 'Last Day of Usage Month';
                objNewContract.Status__c = 'New';
                objNewContract.Active__c = true;
                insert objNewContract;
                System.debug('Contract Save Success Id is ' + objNewContract.Id + ' with Account Id of ' + objNewContract.Account_Name__c);
                
				BigMachines__Quote__c objQuote = createQuote(objNewContract);//objOpportunity);
                insert objQuote;
                
                objNewContract.Quote__c = objQuote.Id;
                update objNewContract;
                
                objNewContractAddress.GCR_Content_Document_Detail__c = objNewContract.Id;
                objNewContractAddress.Address_Type__c = 'Bill To';
                insert objNewContractAddress;
               
                String strMsg = 'New Contract and address has been created with Id ' + objNewContract.Id +
                                                           '. Return to contract search page to update the contract.';
                System.Debug(strMsg);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,strMsg));  
                
                return (new PageReference('/' + objNewContract.Id));
                
            } catch(Exception ex){
                System.Debug('Caught Exception ' + ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                // Roll back changes in case of DML failure
                Database.rollback(objSP);
            }
        }
        objNewContract = new GCR_Content_Document_Detail__c();
       	objNewContractAddress= new Account_Order_Address__c();
        return null;
    }
    
    public Boolean validateInput(){
        Boolean IsInputValid = true;

        //Check if account it present
        if(objNewContract.Account_Name__c==null){
            String strError = 'Account is required';
            System.debug(strError);
            objNewContract.Account_Name__c.addError(strError);
            IsInputValid = false;
        }
        if (objUIOpportunity.Lines_of_Businesses__c == null) {
            String strError = 'Please choose an Offering';
            System.debug(strError);
            objUIOpportunity.Lines_of_Businesses__c.addError(strError);
            IsInputValid = false;
        }
        if (objUIOpportunity.Region__c == null) {
            String strError = 'Please choose a Region';
            System.debug(strError);
            objUIOpportunity.Region__c.addError(strError);
            IsInputValid = false;
        }
		return IsInputValid;
    }

}