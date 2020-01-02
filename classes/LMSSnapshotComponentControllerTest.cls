@isTest(seeAllData=true)
public class LMSSnapshotComponentControllerTest {
	@isTest
    static void testLMSSnapshotComponentController(){
    	Test.startTest();
    	//License_Request_Log__c requestLog = [SELECT End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Active__c = true LIMIT 1];
    	License_Snapshot__c snapShotRecord = [SELECT id, Part_Number__c, End_User__c, Sold_To__c, Product__c FROM License_Snapshot__c WHERE IsActive__c = true LIMIT 1];
    	
    	LMSSnapshotComponentController controller = new LMSSnapshotComponentController();
    	controller.endUserAccountId = snapShotRecord.End_User__c;
    	controller.soldToAccountIds = new List<String>{snapShotRecord.Sold_To__c};
    	controller.userType = 'Internal';
    	boolean pendindRefersh = controller.getPendingRefresh();
    	List<LMSSnapshotComponentController.SnapshotRecordWrapper> snapshotData = controller.getSnapshotData();
    	Product_Upgrade_Request__c pur = new Product_Upgrade_Request__c(Account__c = snapShotRecord.End_User__c, Product__c = snapShotRecord.Product__c, Quantity__c = 10, Type__c = 'Version');
    	insert pur;
    	Pure_Connect_Version_Upgrade__c pcvu = new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = 'Test', New_Part_Number__c = snapShotRecord.Part_Number__c, Old_Part_Number__c = snapShotRecord.Part_Number__c);
    	insert pcvu;
    	
    	controller.selectedPartNumber = snapShotRecord.Part_Number__c;
    	controller.showHistory();
    	controller.showLineItems();
    	controller.closeLineItems();
    	controller.refreshSnapshot();
    	controller.selectedPartNumber = snapShotRecord.Part_Number__c + 'A';
    	controller.showLineItems();
    	controller.userType = 'Partner';
    	pendindRefersh = controller.getPendingRefresh();
    	snapshotData = controller.getSnapshotData();
        
        LMSSnapshotComponentController.UpgradeRequestWrapper upgradeRequestWrapper = new LMSSnapshotComponentController.UpgradeRequestWrapper('Old_APN_Number__c', 'Old_Part_Name__c', 'New_APN_Number__c', 'New_Part_Name__c', DateTime.Now(), 100);
        Test.stopTest();
    }    
}