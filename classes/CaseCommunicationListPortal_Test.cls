@isTest
public class CaseCommunicationListPortal_Test {
    
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
		fdi.Body = 'caseupdate';
		fdi.ParentId = cs.Id;
		fdi.Visibility = 'AllUsers';
		fdi.Type = 'TextPost';
		insert fdi;   
      
        EmailMessage em = new EmailMessage();
        em.Incoming = false;
        em.IsExternallyVisible = true;
        em.Subject = 'subj';
        em.ParentId = cs.Id;
        insert em; 
        
        
		Test.startTest();		
			ApexPages.currentPage().getParameters().put('id', cs.id);
	        CaseDetailController cdet = new CaseDetailController();        
	        CaseCommunicationListPortal ccp = new CaseCommunicationListPortal(cdet);   
	        
	        ccp.getComall();
	        ccp.setCaseId(cs.Id);
	        ccp.getCaseId();
	             		
		Test.stopTest();   		
     	
     }
}