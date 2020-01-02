//Naresh Kumar	01/20/2015
public without sharing class UpdateContactInfoController {
	
	public List<Contact> contacts {get; set;}
	public String email {get; set;}
	public Boolean showResult {get; set;}
	public UpdateContactInfoController(){
		contacts = new List<Contact>();	
	}	
	
	public void searchContact(){
		if(email == null || email.trim() == ''){
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No contact to update !');  
			ApexPages.addMessage(msg);
			return;
		}
		contacts = [SELECT Name, Training_Access__c FROM Contact WHERE Email =: email];		
		if(contacts.isEmpty())
			showResult = false;
		else
			showResult = true;
	}
	
	public void updateContact(){
		ApexPages.Message msg;
		if(!contacts.isEmpty()){
			update contacts;
			msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Contact updated successfully !');
		}
		else{
			msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No contact to update !');        	
		}
		ApexPages.addMessage(msg);
	}

}