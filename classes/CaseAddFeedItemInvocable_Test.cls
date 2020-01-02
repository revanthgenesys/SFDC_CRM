@isTest
public class CaseAddFeedItemInvocable_Test {
	
	static testMethod void tst() {
		Util.Bypass_Trigger_Chk = true; 
		
		Account acct = TestUtil.createAccounts(1, true)[0];	   
	    List<Contact >testContacts = TestUtil.createContacts(1, acct, true);  
	    testContacts[0].Alternate_Email__c = 'tst@tst.com';
	    update  testContacts[0];
	    
	    List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
         
        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           recordtypeid = rectp[0].id);                        
	    insert cs;
	    
	     FeedItem fdi = new FeedItem();
		      fdi.Body = 'body';
		      fdi.ParentId = cs.Id;
	          fdi.Visibility = 'InternalUsers';
	     insert fdi;	
	    
	    
		Util.Bypass_Trigger_Chk = false;
		
		Test.startTest();
		
		CaseAddFeedItemInvocable.PostRequest req = new CaseAddFeedItemInvocable.PostRequest();		
		req.caseId = cs.id;
		req.isPublic = true;
		req.postBody = 'body';		
		CaseAddFeedItemInvocable.feedPostToCase(new List<CaseAddFeedItemInvocable.PostRequest>{req});
		
		CaseAddFeedItemInvocable.PostRequest req2 = new CaseAddFeedItemInvocable.PostRequest();		
		req2.caseId = cs.id;
		req2.isPublic = false;	
		CaseAddFeedItemInvocable.feedPostToCase(new List<CaseAddFeedItemInvocable.PostRequest>{req2});
		
		CaseAddFeedItemInvocable.PostRequest req3 = new CaseAddFeedItemInvocable.PostRequest();		
		req3.caseId = cs.id;
		req3.isPublic = false;	
		CaseAddFeedItemInvocable.feedPostToCase(new List<CaseAddFeedItemInvocable.PostRequest>{req2});
		
		List<FeedItem> cfd = [SELECT Id, Visibility FROM FeedItem WHERE id = :fdi.Id];
		if (!cfd.isEmpty())  {
		   cfd[0].Visibility = 'AllUsers';
		   update cfd[0];
		   
		   cfd[0].Visibility = 'InternalUsers';
		   update cfd[0];
		   
		   delete cfd[0];
		
		}
		
		Test.stopTest();
	}
    
}