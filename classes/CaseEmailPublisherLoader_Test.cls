@isTest
public class CaseEmailPublisherLoader_Test {
	
	static testMethod void pubtst() {
		
		TestUtil.setConfigValues();    

        Util.Bypass_Trigger_Chk = true;  
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        
        Account acct = TestUtil.createAccounts(1, true)[0];
        acct.Support_Group__c = 'Japan';
        update acct;
        
        Contact[] testContacts = TestUtil.createContacts(1, acct, true);  
     
        CaseUtil.isCurrentUserProfileReadOnly();              
        Case cs = new Case(status='Awaiting Info',subject='test', priority = '3-Medium', ContactId = testContacts[0].Id,                      
                           recordtypeid = rectp[0].id);                        
        insert cs;
  	    
	    List<Map<String, Object>> defaultSettingAsObject = new List<Map<String, Object>>
        {
          new Map<String, Object>
          {
                'targetSObject' => new EmailMessage(),
                'contextId' => cs.Id,
                'actionType' => 'Email',
                'actionName' => 'Case.Email',
                'fromAddressList' => new List<String> { 'tst@test.com' }
          }
        };

        List<QuickAction.SendEmailQuickActionDefaults> defaultsSettings = 
            (List<QuickAction.SendEmailQuickActionDefaults>)JSON.deserialize(JSON.serialize(defaultSettingAsObject), List<QuickAction.SendEmailQuickActionDefaults>.class);
        Test.startTest();
            (new CaseEmailPublisherLoader()).onInitDefaults(defaultsSettings);       
        Test.stopTest();
		
	}
    
}