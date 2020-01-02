/*
Naresh Kumar	05/30/2013
*/
public without sharing class MergeGroupAccountContacts {
	public Contact source {get;set;}
	public Contact target {get;set;}	
	public MergeGroupAccountContacts(){
		source = new Contact();
		target = new Contact();
	} 	
	public pageReference updateContacts(){
		if(source.Group_Account_Lookup__c == null || target.Group_Account_Lookup__c == null){
				ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select both the source and target accounts.');
            	ApexPages.addMessage(errorMessage);
            	return null;
		}		
		List<Contact> conts = [SELECT Name, AccountId, Employer__c FROM Contact WHERE AccountId =: source.Group_Account_Lookup__c];
		if(conts.isEmpty()){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no contacts in source group account.');
            ApexPages.addMessage(errorMessage);
            return null;
		}
		for(Contact eachContact : conts){
			eachContact.AccountId = target.Group_Account_Lookup__c;
		}
		
		Database.SaveResult[] srList = Database.update(conts, false);
		Boolean isError = false;
		Integer counter = 0;
		for (Database.SaveResult sr : srList) {
	    	if (!sr.isSuccess()) {
	        	for(Database.Error err : sr.getErrors()) {
	         		isError = true;
	         		ApexPages.Message errorMessage1 = new ApexPages.Message(ApexPages.Severity.ERROR, conts[counter].Name + ' - ' + err.getMessage());
	         		ApexPages.addMessage(errorMessage1); 
	        	}
	    	}
	    	counter++;
		}
		ApexPages.Message errorMessage;
		if(!isError)
			errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'All the Contacts moved successfully !');
		else
			errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Contacts moved successfully except the contacts which had some error as per shown above.');
		
        ApexPages.addMessage(errorMessage);
        return null;
	}
	public pageReference back(){
		String recordId = Apexpages.currentPage().getParameters().get('id');
		if(recordId != null){
			return new PageReference('/'+recordId);
		}
		return null;
	}
}