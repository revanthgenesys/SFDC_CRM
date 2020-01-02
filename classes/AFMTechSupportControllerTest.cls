@isTest(seeAllData = true)
public class AFMTechSupportControllerTest {
    static testMethod void AFMTechSupportTest1(){
        List<License_Snapshot_Sold_To_End_User__c> LSSEU = new List<License_Snapshot_Sold_To_End_User__c>();
        LSSEU = [SELECT Id, End_User__c, Sold_To__c from License_Snapshot_Sold_To_End_User__c ORDER BY CreatedDate DESC LIMIT 2];
        AFMTechSupportController controller = new AFMTechSupportController();
        controller.forEndUser.AccountId = LSSEU[0].End_User__c;
        controller.accountSelected();    
        controller.createCombinations();
        controller.cleanUpCombinations();
        controller.toSoldTo.AccountId = LSSEU[1].End_User__c;
        controller.migrateActivationFiles();
        controller.refreshSnapshot();
    }
    
    static testMethod void AFMTechSupportTest2(){
        List<License_Request_Log__c> LSSEU = [SELECT Id, End_User__c, Sold_To__c from License_Request_Log__c WHERE isActive__c = true ORDER BY CreatedDate DESC LIMIT 2];
        AFMTechSupportController controller = new AFMTechSupportController();
        controller.forEndUser.AccountId = LSSEU[0].End_User__c;
        controller.accountSelected();    
        controller.createCombinations();
        controller.cleanUpCombinations();
        controller.toSoldTo.AccountId = LSSEU[1].End_User__c;
        controller.migrateActivationFiles();
        controller.refreshSnapshot();
    }
}