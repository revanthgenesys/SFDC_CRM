public class PartnerPortalRegistration_Class {

    public partner_portal_prospect__c opp{get;set;}  
    public Contact cnct {get;set;}
    private ApexPages.StandardController sController;  
    public String oppId ;
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public Boolean isReadOnly {get;set;}
    public Boolean showError {get;set;}
    public Boolean isApproved {get;set;}
    public List<oppProduct> oppProdsTab1 {get; set;}
    public List<oppProduct> oppProdsTab2 {get; set;}
    public List<Partner_Opporty_Registr_Product__c> regstrdProds {get; set;}
    private List<Partner_Opporty_Registr_Product__c> oppProdsToInsert = new List<Partner_Opporty_Registr_Product__c>();
   
    
    public PartnerPortalRegistration_Class(ApexPages.StandardController controller) {
        sController = controller;
        oppProdsTab1 = new List<oppProduct>();
        oppProdsTab2 = new List<oppProduct>();
        isReadOnly = false;
        showError = false;
        oppId = ApexPages.CurrentPage().getParameters().get('id');
        system.debug('id'+oppId );
        if(ApexPages.CurrentPage().getParameters().get('ro') != null)
            isReadOnly = true; 
         if(ApexPages.CurrentPage().getParameters().get('ap') != null)
            isApproved = ApexPages.CurrentPage().getParameters().get('ap').equalsIgnoreCase('true');      
        mapFieldLabelVsHelpText = getMapOfFieldsAndHelpText();   
        String runAs = UserInfo.getUserId();
        if(ApexPages.CurrentPage().getParameters().get('runAs') != null)
            runAs = ApexPages.CurrentPage().getParameters().get('runAs');
            
        User currentUser = [SELECT ContactId,email,AccountId FROM User where id =:runAs];
        system.debug('currentUser '+currentUser );
        Contact userContact = [Select AccountId,Name,Title,Email,Legacy_Company_Name__c from Contact where id =: currentUser.contactId ];
        system.debug('userContact '+userContact );
        Account userAccount = [SELECT Owner.Id, Owner.IsActive, Country__r.Region__c, Country__r.CurrencyISOCode FROM Account where Id =:userContact.AccountId];
        system.debug('userAccount '+userAccount );
        if(!Test.isRunningTest())
        controller.addFields(new List<String>{'Status__c','End_Date__c','End_User_Account__c', 'Proposed_End_Date__c','Opportunity_Channel_Manager__c','Opportunity_Channel_Manager__r.Name'});
        opp = (partner_portal_prospect__c)controller.getRecord(); 
       // opp = [Select id,Name, status__c,End_Date__c,End_User_Account__c,Proposed_End_Date__c from partner_portal_prospect__c where id=:oppId];
        system.debug('status '+opp.status__c);
        if (userAccount.Owner.Id == null || userAccount.Owner.IsActive != true) {
            Partner_Portal_Settings__c partnerPortalLeadReferralSetting = Partner_Portal_Settings__c.getValues('Janelle Mertens');  
            opp.Opportunity_Channel_Manager__c = partnerPortalLeadReferralSetting.Id_Value__c;
        }
        else {
            opp.Opportunity_Channel_Manager__c = userAccount.Owner.Id;
        }
                
        opp.Genesys_Channel_Manager__c = currentUser.ContactId;
        opp.Status__c = 'Request Submitted';
        opp.Account__c = userAccount.id; 
        opp.Your_Title__c = userContact.Title;
        opp.Your_Name__c =  userContact.Name;
        opp.Your_Email__c = userContact.Email;
        opp.Regions__c = userAccount.Country__r.Region__c;        
        Account currentAccount = [SELECT AccountNameNative__c FROM Account where Id =: currentUser.accountId ];
        opp.Your_Company_Name__c = currentAccount.AccountNameNative__c;
        
        if(oppId != null)  {
            partner_portal_prospect__c partnerProspectRecord = [SELECT Account__c FROM partner_portal_prospect__c WHERE id =: oppId];   
            
            regstrdProds = [SELECT Id, Product__c, Product__r.Name, Amount_Currency__c 
                            FROM Partner_Opporty_Registr_Product__c WHERE Opporty_Registration__c = :oppId];
            
            if(partnerProspectRecord.Account__c != userContact.AccountId) {
                showError = true;           
            }       
        } else {
                
            /* new registration, using default currency USD until requested otherwise */
            //opp.CurrencyIsoCode = 'USD';
            //opp.Opportunity_Currency__c = 'USD - U.S. Dollar';
            
            opp.CurrencyIsoCode = userAccount.Country__r.CurrencyISOCode;
            opp.Opportunity_Currency__c = userAccount.Country__r.CurrencyISOCode;
            getSalesProducts(opp.CurrencyIsoCode); 
        }
    }
    
    
    public PageReference saveOpp() { 
    
            if(opp.Opportunity_Channel_Manager__c == null ){
                Partner_Portal_Settings__c partnerPortalLeadReferralSetting = Partner_Portal_Settings__c.getValues('Janelle Mertens');
                String channelManagerId;
                
                if(partnerPortalLeadReferralSetting!=null){
                    channelManagerId = partnerPortalLeadReferralSetting.Id_Value__c;
                }
                
                if(channelManagerId!=null){
                    opp.Opportunity_Channel_Manager__c  = channelManagerId;
                }
            }
           
            Integer noOfDaysToExpire = 364;
            if(PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig') != NULL)
                noOfDaysToExpire = (Integer)PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig').No_of_Days_To_Expire__c;        
        
           opp.End_Date__c = Date.today().addDays(noOfDaysToExpire);    
           opp.CurrencyIsoCode = opp.Opportunity_Currency__c.substring(0,3);  
                    
           String errMsg = validateProducts();
           if ( errMsg != null ) {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
              return null;
           }

           if(opp.Lead_Offer__c.contains('Premise') && (opp.License_Amount__c < 0 || opp.License_Amount__c == 0)){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'License Amount should be greater than 0'));
             return null;
           }
           if(opp.Lead_Offer__c.contains('Cloud') && (opp.Annual_Contract_Value_Amount__c < 0 || opp.Annual_Contract_Value_Amount__c == 0)){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Annual Contract Value Amount should be greater than 0'));
               return null;
           }
                    
           insert opp;         
           if ( !oppProdsToInsert.isEmpty() && opp.id != null ) {
              for ( Partner_Opporty_Registr_Product__c pr : oppProdsToInsert )
                  pr.Opporty_Registration__c = opp.Id;
             
              insert oppProdsToInsert;          
           }
           
        submitPartnerApplicationToApprovalProcess(opp);   
   
        PageReference pr = new PageReference('/partner/apex/DealRegistrationGraphs');  
        return pr;
    }
    
    public PageReference cancelOpp() {     
          PageReference pr = new PageReference('/partner/apex/Home');  
    return pr;
    }
    
    public static void submitPartnerApplicationToApprovalProcess(partner_portal_prospect__c newApplication){
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Request submitted for approval automatically.');
    req.setObjectId(newApplication.id);
        // Submit the approval request for the account
    Approval.ProcessResult result = Approval.process(req);
    }
    
    public static Map<String,String> getMapOfFieldsAndHelpText(){
    String objName ='partner_portal_prospect__c';
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType leadSchema = schemaMap.get(objName);
    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
    Map<String, String> mapFieldLabelVsHelpText = new Map<String, String>();
    
    for (String fieldName: fieldMap.keySet()) {
        String label = fieldMap.get(fieldName).getDescribe().getLabel();
        String helpText = fieldMap.get(fieldName).getDescribe().getInlineHelpText();
        if(helpText == null || helpText == '')
            helpText = label;
        mapFieldLabelVsHelpText.put(label, helpText);
        }   
    return mapFieldLabelVsHelpText;
    } 
           
    public class oppProduct  {
       public Integer rowcnt {get;set;}
       public String regprodname {get; set;}
       public Boolean isSelected {get; set;}
       public String amount {get; set;}
       public ID prodId {get; set;}
 
       public oppProduct(Product2 prd, Integer rcnt) {
            rowcnt = rcnt;
            prodId = prd.Id;                                                              
            regprodname = prd.Name;
            isSelected = false;
       }
    }
    
    private void getSalesProducts(String currencyCode)   {
        List<Product2> prods = new List<Product2>();
        //oppProds.clear();
        oppProdsTab1.clear();
        oppProdsTab2.clear();
        
        if ( currencyCode != null && currencyCode != '' )  {
          prods =  [SELECT Id, Name, Product_Name__c
                    FROM Product2 
                    WHERE id IN
                      (SELECT Product2Id FROM PriceBookEntry WHERE PriceBook2.Name LIKE 'Sales PriceBook' 
                                         AND CurrencyIsoCode = :currencyCode AND IsActive = true)
                    AND IsActive = true
                    ORDER BY Name];
        }
        
        Integer cnt = 1;
        Integer len = prods.size() / 2;
        for (Product2 pr : prods)  {
            if (cnt <= len)
                oppProdsTab1.add( new oppProduct(pr, cnt++));
            else 
                oppProdsTab2.add( new oppProduct(pr, cnt++));
        }
        
    }
    
    public void resetCurriency() {   
        opp.CurrencyIsoCode = opp.Opportunity_Currency__c.substring(0,3);  
        getSalesProducts(opp.CurrencyIsoCode);
    }
    
    private String validateProducts() {
         oppProdsToInsert.clear();
         List<oppProduct> oppProds = new List<oppProduct>();
         oppProds.addAll(oppProdsTab1);
         oppProds.addAll(oppProdsTab2);
            
         if ( !oppProds.isEmpty() ) {
            for (oppProduct pr : oppProds) {
                if ( pr.isSelected ) {                  
                    try {
                         Decimal amnt = Decimal.valueOf(pr.amount);
                         if ( amnt == 0 )
                            return 'Please enter the Opportunity Amount for product ' + pr.regprodname;
                         
                         oppProdsToInsert.add(
                                   new Partner_Opporty_Registr_Product__c (Product__c = pr.prodId,
                                                                           CurrencyIsoCode = opp.CurrencyIsoCode,
                                                                           Amount_Currency__c = amnt) );
                    }
                    catch (Exception e) {  
                        return 'Error processing Opportunity Amount for the product ' + pr.regprodname + '. Please re-enter the amount.';               
                    }                   
                }
            }           
         } 
          
         //if ( oppProdsToInsert.isEmpty() ) {
         //    return 'Please select Products and Opportunity Amount for each selected product.';
         //}
         
         return null;
    }
}