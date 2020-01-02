@isTest(seeAllData=true)
public class LicenseActivityComponentControllerTest{
	@isTest
    static void testLMSLicenseActivityComponentController(){
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Active__c = true LIMIT 1];
    	Test.startTest();
    	LMSLicenseActivityComponentController controller = new LMSLicenseActivityComponentController();
    	controller.endUserAccountId = requestLog.End_User__c;
    	controller.soldToAccountIds = new List<String>{requestLog.Sold_To__c};
    	controller.userType = 'Internal';
    	List<SelectOption> productLines = controller.getProductLines();
    	List<SelectOption> licenseTypes = controller.getLicenseTypes();
    	List<SelectOption> installSites = controller.getInstallSites();
    	List<SelectOption> activeInactive = controller.getActiveInactive();
    	List<LMSLicenseActivityComponentController.LicenseRequestWrapper> requestLogs = controller.getLicenseRequests();
    	controller.resetFilters();
    	controller.clearFilters();
    	controller.cancel();
    	controller.showAlert();
    	controller.hideAlert();
    	controller.selectedLicenseRequestId = requestLog.id;
    	LMSLicenseActivityComponentController.LicenseRequestWrapper rLog = controller.getLicenseRequest();
    	controller.updateLicense(); 
    	controller.deactivateLicense();
    	Test.stopTest();
    }
}