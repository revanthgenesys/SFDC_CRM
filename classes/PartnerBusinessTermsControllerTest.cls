@isTest
private class PartnerBusinessTermsControllerTest {
    static testMethod void myUnitTest1() {
    	Partner_Application__c pa = new Partner_Application__c();
    	pa.Company_Name__c = 'Test Company';
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
    	pc.Status__c = 'Approved';
    	pc.Partner_Business_Terms_and_Conditions__c = pbt.id;
    	insert pc;
    	Partner_Application_Category_and_Country__c pacc = new Partner_Application_Category_and_Country__c();
    	pacc.Partner_Application__c = pa.id;
    	pacc.Approval_Status__c = 'Approved';
    	pacc.Category__c = 'Value Added Reseller (VAR)';
    	insert pacc;
    	Partner_Contract_Request__c pcr = new Partner_Contract_Request__c();
    	pcr.Partner_Business_Terms_and_Conditions__c = pbt.id;
    	insert pcr;
    	ApexPages.currentPage().getParameters().put('appId', pa.id);
    	PartnerBusinessTermsController obj = new PartnerBusinessTermsController(new ApexPages.StandardController (pa));
    	obj.changeToEditMode();
    	obj.cancelBtnHandler();
    	//obj.submitForApproval();
    	obj.viewContract();
    	//obj.approveContract();
    	obj.refresh();    	
    	obj.quickSaveBtnHandler();
    	obj.saveBtnHandler();
    	//obj.partnerAcknowledgement();
    	obj.rejectTerms();
    	obj.backToApplication();
    }
    
    static testMethod void myUnitTest2() {
    	Partner_Application__c pa = new Partner_Application__c();
    	pa.Company_Name__c = 'Test Company';
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
    	ApexPages.currentPage().getParameters().put('appId', pa.id);
    	ApexPages.currentPage().getParameters().put('mode', 'edit');
    	PartnerBusinessTermsController obj = new PartnerBusinessTermsController(new ApexPages.StandardController (pa));
    	
    }
}