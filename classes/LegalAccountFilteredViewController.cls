public with sharing class LegalAccountFilteredViewController 
{
    public String strSearch {get; set;}
    public List<SelectOption> list_AccountOptions {get; private set;}
    public String strAccountOptionSelected {get; set;}
	public List<GCR_Content_Document_Detail__c> list_GCRCDDRecords {get; private set;}
    public List<Account> accounts {get; set;}
    public Boolean showAccountGrid {get;set;}
    public LegalAccountFilteredViewController()
    {
        initializeSearchResults();
    }
    
    private void initializeSearchResults()
    {
        list_AccountOptions = new List<SelectOption>();
        list_AccountOptions.add(new SelectOption('','None'));
        strAccountOptionSelected = '';
		list_GCRCDDRecords = new List<GCR_Content_Document_Detail__c>();
    }
    
    public void searchBtnHandler()
    {
        initializeSearchResults();
        if(String.isNotBlank(strSearch)){
            accounts = [SELECT Name, Owner.Name, Country__r.Region__c FROM Account WHERE Name LIKE :(strSearch + '%') 
									   AND Id IN (SELECT Account_Name__c FROM GCR_Content_Document_Detail__c) 
									   ORDER BY Name LIMIT 10];
            if(accounts.isEmpty())
            	showAccountGrid = false;
            else
            	showAccountGrid = true;	
			if(accounts.size() > 2)
			{
                list_AccountOptions.add(new SelectOption('All','All'));
				
				if(list_AccountOptions.size() == 12)
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'10 or more results. Please refine search if account is not found.'));
			}
        }
    }
	
	public void showContracts()
	{
		list_GCRCDDRecords = new List<GCR_Content_Document_Detail__c>();
		
		if(strAccountOptionSelected == '')
			return;
		
		Set<Id> set_AccountIds = new Set<Id>();
		if(strAccountOptionSelected == 'All')
		{
			for(SelectOption objOption : list_AccountOptions)
			{
				if(objOption.getValue() != '' && objOption.getValue() != 'All')
					set_AccountIds.add(objOption.getValue());
			}
		}
		else
			set_AccountIds.add((Id)strAccountOptionSelected);
			
		String strQuery = 'SELECT ';
		List<Schema.FieldSetMember> viewFields = SObjectType.GCR_Content_Document_Detail__c.FieldSets.Account_Filter_View.getFields();
        for(Schema.FieldSetMember field : viewFields)
            strQuery += field.getFieldPath() + ',';
				
		strQuery += 'Id,Name FROM GCR_Content_Document_Detail__c WHERE Account_Name__c IN :set_AccountIds ORDER BY Name LIMIT 100';
		
		list_GCRCDDRecords = Database.query(strQuery);
	}
}