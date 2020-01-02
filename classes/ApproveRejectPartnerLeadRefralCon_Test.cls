@isTest(seeAllData=true)
private class ApproveRejectPartnerLeadRefralCon_Test {
    static testMethod void testMethod_1() {
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];   
        User adminUser = [select id,name,email from User where ProfileId =: partnerProfile.id and ManagerId !=NULL AND isActive = TRUE limit 1];
        
        Test.startTest();
        
        System.runAs(adminUser){
            ApproveRejectLeadRefLinkController ctrlObj = new ApproveRejectLeadRefLinkController();
            ctrlObj.getWorkItemId();
            
        }
        Test.stopTest();
    }
}