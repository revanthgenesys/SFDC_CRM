@isTest(seeAllData=true)
private class PartnerSetupControllerTest {

    static testMethod void myUnitTest1() { 
    	Account testAccount = TestUtil.createAccounts(1, true)[0];    	   	
    	Partner_Application__c pa = new Partner_Application__c();
    	pa.Company_Name__c = 'Test Company';
    	pa.For_User__c = UserInfo.getUserId();
    	pa.Account__c = testAccount.id;
        pa.AnnualSalesRevenue_PL__c = 'No';
        pa.Ownership_PL__c = 'No';
        pa.RightToAppointOrDismiss_PL__c = 'No';
        pa.AppointOrDismissMD_PL__c = 'No';
        pa.Government_Veto_PL__c = 'No';
        pa.PublicInternationalOrg_PL__c = 'No';
        pa.Convicted_Executive_PL__c = 'No';
        pa.BannedEmployee_PL__c = 'No';
        pa.ExportEnforcementActivity_PL__c = 'No';
        pa.CountryCurrentlyUnderUS_PL__c = 'No';
        pa.Conflict_of_Interest_PL__c = 'No';
        pa.Current_or_Former_Genesys_Employee_PL__c = 'No';
    	insert pa;
    	Partner_Business_Terms_and_Conditions__c pbt = new Partner_Business_Terms_and_Conditions__c();
    	pbt.Partner_Application__c = pa.id;
    	pbt.Date_Acknowledged__c = System.today();
    	insert pbt;
    	Partner_Contract__c pc = new Partner_Contract__c();
    	pc.Partner_Business_Terms_and_Conditions__c = pbt.id;
    	pc.Application__c = pa.id;
    	insert pc;
    	Partner_Application_Category_and_Country__c pacc = new Partner_Application_Category_and_Country__c();
    	pacc.Partner_Application__c = pa.id;
    	pacc.Approval_Status__c = 'Approved';
    	pacc.Category__c = 'Value Added Reseller (VAR)';
    	insert pacc;
    	Partner_Contract_Request__c pcr = new Partner_Contract_Request__c();
    	pcr.Partner_Business_Terms_and_Conditions__c = pbt.id;
    	insert pcr;
    	ApexPages.currentPage().getParameters().put('contId', pc.id);
        PartnerSetupController obj = new PartnerSetupController();
        obj.quickSaveBtnHandler();
        obj.saveBtnHandler();
        obj.changeToEditMode();
        obj.cancelBtnHandler();        
        delete pacc;
    }
    static testMethod void PartnerPortal_ApproveAllPACounries_WS() { 
    	Account testAccount = TestUtil.createAccounts(1, true)[0];    	   	
    	Partner_Application__c pa = new Partner_Application__c();
    	pa.Company_Name__c = 'Test Company';
    	pa.For_User__c = UserInfo.getUserId();
    	pa.Account__c = testAccount.id;
        pa.AnnualSalesRevenue_PL__c = 'No';
        pa.Ownership_PL__c = 'No';
        pa.RightToAppointOrDismiss_PL__c = 'No';
        pa.AppointOrDismissMD_PL__c = 'No';
        pa.Government_Veto_PL__c = 'No';
        pa.PublicInternationalOrg_PL__c = 'No';
        pa.Convicted_Executive_PL__c = 'No';
        pa.BannedEmployee_PL__c = 'No';
        pa.ExportEnforcementActivity_PL__c = 'No';
        pa.CountryCurrentlyUnderUS_PL__c = 'No';
        pa.Conflict_of_Interest_PL__c = 'No';
        pa.Current_or_Former_Genesys_Employee_PL__c = 'No';
    	insert pa;
    	Partner_Business_Terms_and_Conditions__c pbt = new Partner_Business_Terms_and_Conditions__c();
    	pbt.Partner_Application__c = pa.id;
    	pbt.Date_Acknowledged__c = System.today();
    	insert pbt;
    	Partner_Contract__c pc = new Partner_Contract__c();
    	pc.Partner_Business_Terms_and_Conditions__c = pbt.id;
    	pc.Application__c = pa.id;
    	insert pc;
    	Partner_Application_Category_and_Country__c pacc = new Partner_Application_Category_and_Country__c();
    	pacc.Partner_Application__c = pa.id;
    	pacc.Approval_Status__c = 'Approved';
    	pacc.Category__c = 'Value Added Reseller (VAR)';
    	insert pacc;
    	PartnerPortal_ApproveAllPACounries_WS.approveAllCountries(pa.id);    	        
    }    
    static testMethod void Partner_Portal_Attachments_Class() { 
    	Test.startTest();
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser;
    	Test.stopTest();
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
    	System.runAs(testUser){
    		Partner_Portal_Attachments_Class obj = new Partner_Portal_Attachments_Class();
    	}
    }
    static testMethod void Partner_Portal_Template_Controller() { 
    	Util.Bypass_Trigger_Chk = true;
    	
    	Test.startTest();
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	testAccount.PartnerType__c = 'VAR';
    	update testAccount;
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser;
    	Test.stopTest();
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
    	System.runAs(testUser){
    		Partner_Portal_Template_Controller obj = new Partner_Portal_Template_Controller();
    	}
    }
    /*
    static testMethod void testMethod2(){
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	partner_portal_prospect__c obj = new partner_portal_prospect__c();
    	obj.Account__c = testAccount.id;
    	insert obj; 
    }
    */
}