@isTest
public class CloneSupportAccessCloudController_Test {
	
	 static testMethod void testClone () {
		TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
  System.runAs(runAsUser[0]) {

    RecordType rType = [SELECT id, Name FROM RecordType WHERE Name = 'Group Account - Customer' LIMIT 1];
        List<Account> testAccounts = TestUtil.createAccounts(2, false);
        testAccounts[0].RecordTypeId = rType.id;
        testAccounts[0].Status__c = 'Active';
        testAccounts[0].Name = 'Test Group Account 1';
        testAccounts[1].Name = 'Holding Account';
        insert testAccounts;
        
        List<Contact> testContacts = TestUtil.createContacts(2, testAccounts[0], false);
        testContacts[1].AccountId = testAccounts[1].id;
        insert testContacts;
        
        Account accnt1 = testAccounts[0];
        Account accnt2 = testAccounts[1];
 
        Contact cont1 = testContacts[0];
        Contact cont2 = testContacts[1];
        		
		Cloud_Deployment__c deplTo = new Cloud_Deployment__c();
		deplTo.Support_Status__c = 'Active';
	   	deplTo.Account__c = accnt1.id;
	   	deplTo.Sold_To_Account__c = accnt1.id;
	   	deplTo.Status__c = 'Production';	  
        insert deplTo;
        
        Cloud_Deployment__c deplFrom = new Cloud_Deployment__c();
		deplFrom.Support_Status__c = 'Active';
	   	deplFrom.Account__c = accnt2.id;
	   	deplFrom.Sold_To_Account__c = accnt2.id;
	   	deplFrom.Status__c = 'Production';	
        insert deplFrom;
        
        Cloud_Deployment__c cldfr = [SELECT Name FROM Cloud_Deployment__c WHERE Id = :deplFrom.Id LIMIT 1];
        
        Support_Access_Cloud__c sa1 = new Support_Access_Cloud__c (Contact__c = cont1.Id, Cloud_Deployment__c = deplTo.Id, Access_Status__c = 'Active');
        insert sa1;
        Support_Access_Cloud__c sa2 = new Support_Access_Cloud__c (Contact__c = cont1.Id, Cloud_Deployment__c = deplFrom.Id, Access_Status__c = 'Active');
        insert sa2;
        Support_Access_Cloud__c sa3 = new Support_Access_Cloud__c (Contact__c = cont2.Id, Cloud_Deployment__c = deplFrom.Id, Access_Status__c = 'Active');
        insert sa3;
               
        Test.startTest();
        CloneSupportAccessCloudController cntr = new CloneSupportAccessCloudController();
         
        String flds = cntr.fields;
    	cntr.showInactive = false;    	
    	cntr.existingContact = cont1;
    	cntr.newContact = cont2;
    	cntr.findAccessRecords();   
    	
    	if (cntr.accessRecords != null && ! cntr.accessRecords.isEmpty() ) {
    		cntr.accessRecords[0].isSelected = true;
    	}
    		
    	cntr.createAccessRecords();
    	cntr.done();
          
        Test.stopTest();                                                
	}
 }
}