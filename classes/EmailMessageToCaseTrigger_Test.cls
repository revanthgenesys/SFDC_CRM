@isTest
public class EmailMessageToCaseTrigger_Test {
	
	public static testmethod void outCaseEmailtst() {
	
		Util.Bypass_Trigger_Chk = true;  
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        
        Account acct = TestUtil.createAccounts(1, true)[0];
        acct.Support_Group__c = 'Japan';
        update acct;
        
        Contact testContact = TestUtil.createContacts(1, acct, true)[0];
        testContact.Email = 'em@fromexample.com';
        update testContact;
        
        CaseUtil.isCurrentUserProfileReadOnly();              
        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContact.Id,                      
                           recordtypeid = rectp[0].id);                        
        insert cs;
        
        Util.Bypass_Trigger_Chk = false;
        
        Test.startTest();
           
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.Subject = 'test';
            emailMessage.TextBody = 'body ';
            emailMessage.ParentId = cs.Id;
            emailMessage.toAddress = 'em@toexample.com';
            emailMessage.FromAddress = 'em@fromexample.com';
            emailMessage.IsExternallyVisible = true;
            emailMessage.Incoming = false;
            emailMessage.status = '3'; 
            insert emailMessage;
            
            emailMessage.IsExternallyVisible = false;
            update emailMessage;
            
            emailMessage.IsExternallyVisible = true;
            update emailMessage;
            
            EmailMessage emailMessage2 = new EmailMessage();
            emailMessage2.Subject = 'test';
            emailMessage2.TextBody = 'body ';
            emailMessage2.ParentId = cs.Id;
            emailMessage2.toAddress = 'em@toexample.com';
            emailMessage2.FromAddress = 'em@fromexample.com';
            emailMessage2.IsExternallyVisible = true;
            emailMessage2.Incoming = true;
            emailMessage.status = '3'; 
            insert emailMessage2;
            
        Test.stopTest();
		
	}
    
}