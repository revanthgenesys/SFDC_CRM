/*
Controller : ManageSubscriptionsController
Author : Vinay Lakshmeesh 3/19/2013
Used to manage contact subscription.
Note: we cannot use Standard controller. 
	  If Standard controller is used, the page redirects 
	  to contact page which would result in 'Insufficient Privileges'
*/

public with sharing class ManageSubscriptionsController {
	public Contact myContact{get;set;}
	public Boolean isPartner {get;set;}
	public Boolean isDesignatedContact {get;set;}
	List<User> lstUser;
	public ManageSubscriptionsController(){
		isPartner = false;
		lstUser = [Select Id,ContactId, Profile.Name, Contact.Designated_Contact__c
							  from   User  
							  where  Id = :UserInfo.getUserId()];
    	Id conId = lstUser[0].ContactId;
    	isDesignatedContact = (lstUser[0].Contact.Designated_Contact__c == 'Yes'? true : false);
    	List<Contact> conList = Database.query('select '+ListFields()+' from Contact where Id=:conId');
    	if(!conList.isEmpty()){
			myContact = conList[0];	
			if(lstUser[0].Profile.Name == 'Genesys Portal Partner User'){
				myContact.Subscribe_to_Partner_Communications__c = true;
				isPartner = true;						
			}
			else{
				myContact.Subscribe_to_Partner_Communications__c = false;
				isPartner = false;
			}		
    	}
	}
	
	public void updateContact(){		
		update myContact;
	}
	
	public Pagereference saveSubscription(){
		update myContact;
	    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Subscriptions Saved.');
        ApexPages.addMessage(myMsg);  
		
		return null;
	}	
	
	//  Get the fields from a field set 
//  ---------------------------------------------------------------------------------------------
   private static String ListFields(){  
       	String fields;             
       	
       	for(Schema.FieldSetMember f : SObjectType.Contact.FieldSets.Subscription_Management.getFields()) {
          	
          	if(fields == null)fields = f.getFieldPath();
           	else fields += ','+f.getFieldPath();
       	}
	    
	    return fields;
   	}
}