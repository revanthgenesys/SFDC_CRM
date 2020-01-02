@isTest
public class CasesListViewPortal_Test {
	
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
    	
    	Util.Bypass_Trigger_Chk = true;
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Support_Request'];
        cs = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id);                        
        insert cs;
        cs.Cloud_Deployment__c = depl.Id;
        update cs;
    	
	}
	
	static testMethod void viewTst() {
		setUpdata();
		
		Test.startTest(); 
		
		Util.Bypass_Trigger_Chk = true;
        System.runAs(testUser) {
        	Util.Bypass_Trigger_Chk = true;
			  Apexpages.currentPage().getParameters().put('rectp','adm');
		      Apexpages.currentPage().getParameters().put('euid',testAccount.id);
		      Apexpages.currentPage().getParameters().put('dpl', depl.Id);
		      Apexpages.currentPage().getParameters().put('st',testAccount.id);
		      
		      CasesListViewPortal contr = new CasesListViewPortal();
		      contr.getHomePageCases();
		      contr.exportCases();
		      List<SelectOption> eus = contr.EuSelectOpts;
		      List<SelectOption> cld = contr.cldDeplOpts;
		       List<SelectOption> st = contr.statusOpts;
		       String titl = contr.exportTitle;
		       String endUsrId = contr.endUsrId;
		      contr.changeQuerySelections();
		      
		      contr.showMore();
		      contr.populateMyCases();
		  
        }
        Test.stopTest(); 	
	}

}