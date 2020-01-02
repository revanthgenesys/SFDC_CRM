@isTest(seeAllData=true)
public class LMSUpgradeComponentControllerTest {
    @isTest
    static void testLMSUpgradeComponentController1(){
    	License_Request_Log__c requestLog = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'CIC 3.0' AND Active__c = true LIMIT 1];
    	Test.startTest();
    	LMSUpgradeComponentController controller = new LMSUpgradeComponentController();
    	controller.endUserAccountId = requestLog.End_User__c;
    	controller.soldToAccountIds = new List<String>{requestLog.Sold_To__c};
    	controller.userType = 'Internal';
    	controller.showAlert();
    	controller.hideAlert();
    	controller.clearFilters();
    	controller.resetFilters();
    	controller.dummyAction();
    	List<LMSUpgradeComponentController.PartUpgradeWrapper> NotAvailableForUpgrades = controller.getNotAvailableForUpgrades();
    	List<LMSUpgradeComponentController.PartUpgradeWrapper> availableForUpgrades = controller.availableForUpgrades;
    	for(LMSUpgradeComponentController.PartUpgradeWrapper puw : availableForUpgrades){
    		puw.selected = true;
    	}
    	controller.performUpgrade();
    	LMSUpgradeComponentController.MirrorWrapper mWrapper = new LMSUpgradeComponentController.MirrorWrapper('mirrorOption');
    	Test.stopTest();
    }
    
    @isTest
    static void testLMSUpgradeComponentController2(){
    	List<License_Request_Log__c> requestLogs = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'CIC 2.4' AND Active__c = true LIMIT 1];
    	if(requestLogs.size() > 0){
    		License_Request_Log__c requestLog = requestLogs[0];
	    	Test.startTest();
	    	LMSUpgradeComponentController controller = new LMSUpgradeComponentController();
	    	controller.endUserAccountId = requestLog.End_User__c;
	    	controller.soldToAccountIds = new List<String>{requestLog.Sold_To__c};
	    	controller.userType = 'Internal';
	    	controller.showAlert();
	    	controller.hideAlert();
	    	controller.clearFilters();
	    	controller.resetFilters();
	    	controller.dummyAction();
	    	List<LMSUpgradeComponentController.PartUpgradeWrapper> NotAvailableForUpgrades = controller.getNotAvailableForUpgrades();
	    	List<LMSUpgradeComponentController.PartUpgradeWrapper> availableForUpgrades = controller.availableForUpgrades;
	    	for(LMSUpgradeComponentController.PartUpgradeWrapper puw : availableForUpgrades){
	    		puw.selected = true;
	    	}
	    	controller.performUpgrade();
	    	LMSUpgradeComponentController.MirrorWrapper mWrapper = new LMSUpgradeComponentController.MirrorWrapper('mirrorOption');
	    	Test.stopTest();
    	}
    }
    
    @isTest
    static void testLMSUpgradeComponentController3(){
    	List<License_Request_Log__c> requestLogs = [SELECT id, End_User__c, Sold_To__c FROM License_Request_Log__c WHERE Product_Line__r.Name = 'CIC 4.0' AND Active__c = true LIMIT 1];
    	if(requestLogs.size() > 0){
    		License_Request_Log__c requestLog = requestLogs[0];
	    	Test.startTest();
	    	LMSUpgradeComponentController controller = new LMSUpgradeComponentController();
	    	controller.endUserAccountId = requestLog.End_User__c;
	    	controller.soldToAccountIds = new List<String>{requestLog.Sold_To__c};
	    	controller.userType = 'Internal';
	    	controller.showAlert();
	    	controller.hideAlert();
	    	controller.clearFilters();
	    	controller.resetFilters();
	    	controller.dummyAction();
	    	List<LMSUpgradeComponentController.PartUpgradeWrapper> NotAvailableForUpgrades = controller.getNotAvailableForUpgrades();
	    	List<LMSUpgradeComponentController.PartUpgradeWrapper> availableForUpgrades = controller.availableForUpgrades;
	    	for(LMSUpgradeComponentController.PartUpgradeWrapper puw : availableForUpgrades){
	    		puw.selected = true;
	    	}
	    	controller.performUpgrade();
	    	LMSUpgradeComponentController.MirrorWrapper mWrapper = new LMSUpgradeComponentController.MirrorWrapper('mirrorOption');
	    	Test.stopTest();
    	}
    }	
}