@isTest
public class ContactsListWithUserInfoController_Test {
	
	static testMethod void repTest() {
		
		TestUtil.setConfigValues();
		List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        Util.Bypass_Trigger_Chk = true;
        
        Profile p = [select id from profile where name='Gold Partner User']; 
        
        List<Account> accnts = TestUtil.createAccounts(1, true);
       	Contact cont = new Contact(LastName = 'TestContact', Email = 'test@genesys.com', accountId = accnts[0].Id, FirstName = 'Test');
       	insert cont;
       		
       	User user = new User(
	            Username = 'ContactsListWithUserInfoControllerTest@genesys.com',
	            ProfileId = p.Id,
	            contactId = cont.id,
	            Alias = 'ts',
	            Email = 'test@genesys.com',
	            EmailEncodingKey = 'UTF-8',
	            FirstName = 'Test',
	            LastName = 'Test',
	            TimeZoneSidKey = 'America/Los_Angeles',
	            CommunityNickname = 'testcomm',
	            LocaleSidKey = 'en_US',
	            LanguageLocaleKey = 'en_US'
      		);
      		insert user;
       		         
        System.runAs(runAsUser[0]) {   	
        	
           
       		ContactsListWithUserInfoController contrEm = new ContactsListWithUserInfoController();
       		contrEm.contactSearchEmail = 'test@genesys.com';      		
       		contrEm.getByEmail();
       		
       		System.assertEquals(false, contrEm.wrapContList.isEmpty());
       		
       		ContactsListWithUserInfoController contrNm = new ContactsListWithUserInfoController();
       		contrNm.contactSearchName = 'Test TestContact';
       		contrNm.sortField = 'isWebEnabled';
       		contrNm.sortDir = 'asc';
       		contrNm.getByName();
            
            contrNm.contactSearchName = 'test';
       		contrNm.sortField = 'isWebEnabled';
       		contrNm.sortDir = 'asc';
       		contrNm.getByAcct();
       		
       		System.assertEquals(false, contrNm.wrapContList.isEmpty());
        } 
               
	} 
	
	static testMethod void pageMoveContactsTest() {
		
		TestUtil.setConfigValues();
		List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        Util.Bypass_Trigger_Chk = true;
                
        List<Account> accnts = TestUtil.createAccounts(2, true);
       	Contact cont = new Contact(LastName = 'TestContact', Email = 'test@genesys.com', accountId = accnts[0].Id, FirstName = 'Test');
       	insert cont;
       
        PageReference pg = Page.ContactsChangeAccount;
        pg.getParameters().put('acctid', accnts[0].Id);
       	
       	Test.setCurrentPage(pg);
       
        Test.StartTest();
       	
       	ContactsListWithUserInfoController contrNm = new ContactsListWithUserInfoController();
      // 	contrNm.fromAccntId = accnts[0].Id;
       	contrNm.dummyCont.AccountId = accnts[1].Id;
       	contrNm.contStatus ='Active';
       	
       	contrNm.getContacts();
       	if ( !contrNm.wrapContList.isEmpty() )
       		contrNm.wrapContList[0].isSelected = true;
       		
       	contrNm.updateContacts();
       	
       	Test.StopTest();
	} 
}