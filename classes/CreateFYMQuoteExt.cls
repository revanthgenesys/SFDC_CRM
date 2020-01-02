public with sharing class CreateFYMQuoteExt 
{
    Id idOppty;
	public BigMachines__Quote__c objNewQuote {get; set;}
	public List<SelectOption> list_ParentQuoteOptions {get; set;}
	public String strQuoteSelected {get; set;}
	
	public CreateFYMQuoteExt(ApexPages.StandardController controller)
    {
		idOppty = controller.getId();
		objNewQuote = new BigMachines__Quote__c();
		list_ParentQuoteOptions = new List<SelectOption>();
		
		for(BigMachines__Quote__c objQuote : [SELECT Id,Name,Revision_No__c FROM BigMachines__Quote__c 
				WHERE BigMachines__Opportunity__c = :idOppty AND Quote_Business_Type__c != 'Renewal'])
		{
			list_ParentQuoteOptions.add(new SelectOption(objQuote.Id,objQuote.Name + (objQuote.Revision_No__c != null ? (' (' + objQuote.Revision_No__c + ')') : '')));
		}
    }
	
	// *** Handler for 'Create' button ***
	public PageReference createBtnHandler()
	{
		if(String.isBlank(strQuoteSelected))
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a source quote.'));
			return null;
		}
		
		// Save-point before DML
		Savepoint objSP = Database.setSavepoint();
		// Skip Triggers
		Util.Bypass_Trigger_Chk = true;
		try
		{
            List<Opportunity> list_Opportunity = [SELECT AccountId, BusinessPartner__c, 
                        CurrencyISOCode,Previous_Maintenance_Rate__c,Gene_Care_Specialist__c,Gene_Care_Specialist__r.Name  
                        FROM Opportunity WHERE id =: idOppty];

            if(list_Opportunity.size() > 0)
            {
                Opportunity objOppty = list_Opportunity[0];
				objNewQuote.BigMachines__Opportunity__c = idOppty;
				objNewQuote.Parent_Quote__c = strQuoteSelected;
				objNewQuote.BigMachines__Status__c = 'Quote In Progress';
				objNewQuote.Quote_Created_Date__c = Date.today();
				// Default quote expiration after 3 months
				objNewQuote.Expiration_Date__c = Date.today().addMonths(3);
				objNewQuote.End_User_ID__c = objOppty.AccountId;
				objNewQuote.BigMachines__Account__c = objOppty.AccountId;
				objNewQuote.Sold_To_Name__c = objOppty.BusinessPartner__c;
                objNewQuote.CurrencyISOCode = objOppty.CurrencyISOCode;
                objNewQuote.Previous_Maint_Rate__c = objOppty.Previous_Maintenance_Rate__c;
                objNewQuote.Quote_Business_Type__c = 'Renewal';
                objNewQuote.Order_Type__c = 'Revenue';
				// FYM Quote
				objNewQuote.Is_FYM_Quote__c = true;
				
                if(objOppty.Gene_Care_Specialist__c != null)
                    objNewQuote.Genesys_Care_Rep_Name__c = objOppty.Gene_Care_Specialist__r.Name;
					
				insert objNewQuote;
				objNewQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE Id =: objNewQuote.Id].Quote_Number__c;
				update objNewQuote;
				
				if(objNewQuote.Maintenance_Start_Date__c != null && objNewQuote.Maintenance_End_Date__c != null)
				{
					Quote_Period__c objQuotePeriod = new Quote_Period__c();
					objQuotePeriod.Quote__c = objNewQuote.Id;
					objQuotePeriod.Start_Date__c = objNewQuote.Maintenance_Start_Date__c;
					objQuotePeriod.End_Date__c = objNewQuote.Maintenance_End_Date__c;
					insert objQuotePeriod;
				}
				
				List<BigMachines__Quote_Product__c> list_QuoteProducts = Util.createQPFromOnPremiseToRenewal((Id)strQuoteSelected,objNewQuote);
				if(list_QuoteProducts.size() > 0)
					insert list_QuoteProducts;
				
				return (new PageReference('/apex/CreateQuote?id=' + objNewQuote.Id));
            }
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity Id needs to be passed as a parameter for this page.'));
		}
		catch(Exception ex)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
			// Roll back changes in case of DML failure
			Database.rollback(objSP);
		}
		return null;
	}
}