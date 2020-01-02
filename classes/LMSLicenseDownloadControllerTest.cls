@isTest(seeAllData=true)
public class LMSLicenseDownloadControllerTest {
	@isTest
    static void testLMSLicenseDownloadController(){
    	Test.startTest();
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c LIMIT 1];
    	PageReference pageRef = Page.LMSLicenseDownload;
        pageRef.getParameters().put('id', requestLog.id);
        Test.setCurrentPage(pageRef);
        LMSLicenseDownloadController controller = new LMSLicenseDownloadController();
    	Test.stopTest();
    }
}