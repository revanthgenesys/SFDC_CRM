@isTest
public class CaseViewSelector_Test {
	static Contact testContact;
	static User testUser;
	static Case cs;
	static Account testAccount;
	static Support_Product__c prod;
	static Cloud_Deployment__c depl;
	
	static void setUpdata() {
	 Util.Bypass_Trigger_Chk = true; 
		
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
    	prod = new Support_Product__c (name='Cloud Product', Product_Type__c = 'Cloud Service', Cloud_Platform__c = 'Premier Edition');
        insert prod;
        
        depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Cloud_Platform__c = 'Premier Edition';
        insert depl;
        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.Id, Cloud_Deployment__c = depl.Id, Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
        
        Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    insert boa;
	    boa.Contract_Status__c = 'Active';
	    update boa;

        Support_Access__c sap = new Support_Access__c(Back_Office_Account__c = boa.Id, SR_Access_Level__c = 'Read/Write',
                                                      Status__c = 'Active', Contact__c = testContact.id);
        insert sap;
        	
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
	}
	
	static testMethod void casetypes() {
		List<SelectOption> adm = CaseViewSelector.statusOptsByCaseType('adm');
		List<SelectOption> cld = CaseViewSelector.statusOptsByCaseType('cld');
		List<SelectOption> sprt = CaseViewSelector.statusOptsByCaseType('sprt');
		List<SelectOption> frp = CaseViewSelector.statusOptsByCaseType('frprm');
		List<SelectOption> frc = CaseViewSelector.statusOptsByCaseType('frcld');		
	}
	
	static testMethod void whereCls() {
		setUpdata();
		
		Test.startTest(); 
        System.runAs(testUser) {
			String adm = CaseViewSelector.baseWhere('adm');
			String cld = CaseViewSelector.baseWhere('cld');
			String sprt = CaseViewSelector.baseWhere('sprt');
			String frp = CaseViewSelector.baseWhere('frprm');
			String frc = CaseViewSelector.baseWhere('frcld');	
        }
        Test.stopTest(); 	
	}
	
	static testMethod void statusCls() {
		String blnc = CaseViewSelector.statusClause('');
		String ncl =CaseViewSelector.statusClause('NonClosed') ;
        String op = CaseViewSelector.statusClause('Open');
        String inf = CaseViewSelector.statusClause('Awaiting Info');
       String sp = CaseViewSelector.statusClause('Solution Proposed'); 
       String sga = CaseViewSelector.statusClause('SupGenAct'); 
       String sr = CaseViewSelector.statusClause('Service Restored'); 
       String sca = CaseViewSelector.statusClause('SupCustAct');
       String repl = CaseViewSelector.statusClause('Replied'); 
               
      String fga = CaseViewSelector.statusClause('FRGenAct'); 
      String fca = CaseViewSelector.statusClause('FRCustAct'); 
      String ir = CaseViewSelector.statusClause('Info Required From Customer');
      String mc = CaseViewSelector.statusClause('MyClosed');
	}

}