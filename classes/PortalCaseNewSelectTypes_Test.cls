@isTest
public class PortalCaseNewSelectTypes_Test {

     public static  User testUser;
     public static Contact testContact;
     public static Account accnt;
     
     public static void setTstData() {
     	
     	 Util.Bypass_Trigger_Chk = true;
       
	    Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
	    accnt = TestUtil.createAccounts(1, true)[0];
	    testContact = TestUtil.createContacts(1, accnt, true)[0];
	    	
	    testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);    	
		testUser.ContactId = testContact.id;
		insert testUser;

	    Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
	                                                             Support_Status__c = 'Active', Sold_To_Account__c = accnt.id);
	    insert cldDep;
	        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
         
        Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = accnt.Id;
			boa.End_User_Account__c = accnt.Id;
			insert boa;
			
	    List<Support_Access__c> saLst = new List<Support_Access__c>();
		Support_Access__c pr = new Support_Access__c(Back_Office_Account__c = boa.Id,
			                                             Contact__c = testContact.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read/Write');
			                                             
		insert pr;   
     }
     
     static testMethod void tstPortalCase1 () {
	    setTstData();
	        	
	    Test.startTest();       
      	 System.runAs(testUser) {
      	 	
      	 	PortalCaseNewSelectTypes cntr = new PortalCaseNewSelectTypes();
      	 	
      	 	cntr.selectedRecType = cntr.recTypes.isEmpty() ? null : cntr.recTypes[0].getValue();
      	 	cntr.goNext();
      	 	cntr.redirectToCasePage();
 
      	 	PortalCaseNewSelectTypes cntr1 = new PortalCaseNewSelectTypes();
      	 	     	 	
      	 	cntr1.StId = accnt.id;
      	 	cntr1.EuId = accnt.id;
      	 	cntr1.StName = 'Test';
      	 	cntr1.EuName = 'Test';
      	 	cntr1.selectedRecType = cntr1.recTypes.isEmpty() ? null : cntr1.recTypes[0].getValue();
      	 	cntr1.goNext();
      	 	cntr.redirectToCasePage();
      	 	      
      	 }
      	Test.stopTest();
     }
     
     static testMethod void tstPortalCase2 () {
     	/// test for multiple SA types. Add two more SAs
         setTstData();
     	 
	    Account accnt2 = TestUtil.createAccounts(1, true)[0];

	    Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test3', Account__c = accnt2.id, Status__c = 'Production',
	                                                             Support_Status__c = 'Active', Sold_To_Account__c = accnt2.id);
	    insert cldDep;
	        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
         
        Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = accnt2.Id;
			boa.End_User_Account__c = accnt2.Id;
			insert boa;
			
	    List<Support_Access__c> saLst = new List<Support_Access__c>();
		Support_Access__c pr = new Support_Access__c(Back_Office_Account__c = boa.Id,
			                                             Contact__c = testContact.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read/Write');
			                                             
		insert pr;   
	
	    Test.startTest();       
      	 System.runAs(testUser) {
      	 	
      	 	PortalCaseNewSelectTypes cntr = new PortalCaseNewSelectTypes();
      	 	
      	 	cntr.selectedRecType = cntr.recTypes.isEmpty() ? null : cntr.recTypes[0].getValue();
      	 	cntr.selectedCloudPrem = 'Cloud';
      	 	cntr.selectedDepl = cldDep.Id; 
      	 	cntr.goNext();
      	 	String gact =  cntr.getacnt;
      	 	cntr.redirectToCasePage();
      	 	      
      	 }
      	Test.stopTest();
     }
}