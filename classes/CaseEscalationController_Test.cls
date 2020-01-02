@isTest
public class CaseEscalationController_Test {
	
	static testMethod void tstEscl() {
		
		Util.Bypass_Trigger_Chk = true;
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
       Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    boa.Contract_Status__c = 'Active';
	    insert boa;
	     boa.Contract_Status__c = 'Active';
	     update boa;

        Support_Access__c sa = new Support_Access__c(Back_Office_Account__c = boa.Id, SR_Access_Level__c = 'Read/Write',
                               Status__c = 'Active', Contact__c = testContact.id);
        insert sa;
        
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        Case cs = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id,
                 End_User_Account__c = testAccount.Id, Sold_To_Account__c = testAccount.Id);                        
        insert cs;
       
        Test.startTest(); 
	     ApexPages.StandardController sc = new ApexPages.StandardController(cs);	
	     ApexPages.currentPage().getParameters().put('csid', cs.Id); 		
		 CaseEscalationController contr = new CaseEscalationController(sc);	
			
		 contr.saveEscl();
		 
		 //errors
		 ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
		 ApexPages.currentPage().getParameters().put('csid', null); 		 		
		 CaseEscalationController contr1 = new CaseEscalationController(sc1);	
		 contr1.saveEscl();	
			
		Test.stopTest(); 	
    	
	}
    
}