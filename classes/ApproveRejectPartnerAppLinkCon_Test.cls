@isTest(seeAllData=true)
private class ApproveRejectPartnerAppLinkCon_Test {
    static testMethod void testMethod_1() {
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];   
        User adminUser = [select id,name,email from User where ProfileId =: partnerProfile.id and ManagerId !=NULL AND isActive = TRUE limit 1];
        
        Test.startTest();
        
        System.runAs(adminUser){
            ApproveRejectPartnerAppLinkController ApproveRejectPartnerAppLinkControllerObj = new ApproveRejectPartnerAppLinkController();
            ApproveRejectPartnerAppLinkControllerObj.getWorkItemId();
            //Partner_Application__c partnerApp = new Partner_Application__c();
        }
        Test.stopTest();
    }
}