@isTest(seeAllData=true)
public class LMSSummaryComponentControllerTest {
	@isTest
    static void testLMSSummaryComponentController(){
    	//License_Request_Log__c requestLog = [SELECT End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Active__c = true LIMIT 1];
    	License_Snapshot__c snapShotRecord = [SELECT id, Part_Number__c, End_User__c, Sold_To__c, Product__c FROM License_Snapshot__c WHERE IsActive__c = true LIMIT 1];
    	Test.startTest();
    	LMSSummaryComponentController controller = new LMSSummaryComponentController();
    	controller.endUserAccountId = snapShotRecord.End_User__c;
    	controller.soldToAccountIds = new List<String>{snapShotRecord.Sold_To__c};
    	controller.userType = 'Internal';
    	boolean pendindRefersh = controller.getPendingRefresh();
    	List<SelectOption> productLines = controller.getProductLines();
    	List<SelectOption> installSites = controller.getInstallSites();
    	controller.refreshSnapshot();
    	List<LMSSummaryComponentController.LicenseSummaryWrapper> summaryDaya = controller.licenseSummaryData;
    	controller.clearFilters();

    	controller.userType = 'Partner';
    	pendindRefersh = controller.getPendingRefresh();
    	controller.refreshSnapshot();
    	summaryDaya = controller.licenseSummaryData;
    	Test.stopTest();
    }     
}