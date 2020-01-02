@isTest 
private class CaseDetailController_Test {
  
  	
   static testMethod void myUnitTest() {
         
		Util.Bypass_Trigger_Chk = true;  
        
        Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        
         Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    boa.Platform__c = 'PureEngage On Premise';
	    boa.Support_Package__c = 'Managed Services';
	    boa.Contract_Status__c = 'Active';
	    insert boa;
	     boa.Contract_Status__c = 'Active';
	     update boa;
        
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        Case cs = new Case(subject='test', priority = '4-Low', Status = 'Solution Proposed', ContactId = testContact.Id,
                         Closure_Category__c = 'Admin', Closure_Reason_Code__c = 'Access granted',
                         recordtypeid = rectp[0].id, Back_Office_Account__c = boa.Id);                        
        insert cs;
 
        Customer_Care_Live_Chat__c lch = new Customer_Care_Live_Chat__c(Key__c = '12345678901234567890123456789012',
                                                                        Enabled__c = true,
                                                                        URL__c = '');
        insert lch;                                                                              
       
        User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
        System.runAs(testUser) {

	        Test.startTest();
	        ApexPages.currentPage().getParameters().put('id', cs.id);
	        CaseDetailController cdet = new CaseDetailController();
	        cdet.liveChat();
	        cdet.liveChatConnect();
	        
	        lch.Enabled__c = false;
             update lch;
	        cdet.liveChat();
	        
	        boa.Platform__c = 'PureConnect On Premise';
	        update boa;
	        CaseDetailController cdet1 = new CaseDetailController();
	        cdet1.liveChat();
	        cdet1.liveChatConnect();
	        	            
	        Test.stopTest();
        }   
    }
}