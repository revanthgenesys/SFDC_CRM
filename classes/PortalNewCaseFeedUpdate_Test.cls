@isTest
public class PortalNewCaseFeedUpdate_Test {
	
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
	    
	    List<RecordType> rectpcd = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Incident'];
         
        Case cs1 = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           recordtypeid = rectpcd[0].id);                        
	    insert cs1;
	    	    
	    List<RecordType> recfrtp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Feature_Request'];
        
        Case fr = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
	                           recordtypeid = recfrtp[0].id);                        
	    insert fr;
	    
	     List<RecordType> recsrtp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        
	 	
	 	 Test.startTest();
	 	 
	 	 ApexPages.currentPage().getParameters().put('cs', cs.id); 
         ApexPages.currentPage().getParameters().put('tp', 'upd'); 
         PortalNewCaseFeedUpdate fupd = new PortalNewCaseFeedUpdate();
         
         fupd.caseupdate = 'body';
         
         fupd.addCaseUpdate();      
         fupd.saveOpen();
         fupd.saveClose();
         fupd.reopenCase();
         fupd.cancel();
         
         ///exceptions
         fupd.caseupdate = '';
         fupd.saveOpen();
         fupd.saveClose();
         fupd.reopenCase();
         
         ApexPages.currentPage().getParameters().put('cs', fr.id); 
         ApexPages.currentPage().getParameters().put('tp', 'upd'); 
         PortalNewCaseFeedUpdate fupd1 = new PortalNewCaseFeedUpdate();        
         fupd1.caseupdate = 'body';      
         fupd1.addCaseUpdate();      
         fupd1.saveOpen();
         
         ApexPages.currentPage().getParameters().put('cs', cs1.id); 
         ApexPages.currentPage().getParameters().put('tp', 'upd'); 
         PortalNewCaseFeedUpdate fupd3 = new PortalNewCaseFeedUpdate();              
         fupd3.cancel(); 
         
         cs1.recordtypeid = recsrtp[0].id;     
         update cs1;         
         ApexPages.currentPage().getParameters().put('cs', cs1.id); 
         ApexPages.currentPage().getParameters().put('tp', 'upd'); 
         PortalNewCaseFeedUpdate fupd4 = new PortalNewCaseFeedUpdate();              
         fupd4.cancel(); 
                   
         Test.stopTest();
	}
    
}