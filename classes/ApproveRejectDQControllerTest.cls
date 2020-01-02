/************************************************************************************
Purpose : test class for ApproveRejectDQController
Written By : Ranjith Punneli
Test Classes : NA
*************************************************************************************/
@isTest(seealldata=true)
private class ApproveRejectDQControllerTest {
    
    static testMethod void intialTest() {
        Test.starttest();
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        List<Quote_Approval__c> list_quoteApprovals = [SELECT id, BigMachines_Quote__c, Deal_Qualification__c, 
            Deal_Qualification__r.Name, Comments__c, Step_Name__c, Status__c, Owner.Name, ownerId, Owner.Type, 
            Deal_Qualification__r.Incentive_Rebate__c,Reason_Name__c ,Deal_Qualification__r.Offering_Type__c
            FROM Quote_Approval__c 
            WHERE Status__c != :QuoteApprovalUtil.STATUS_PENDING
            ORDER BY Lastmodifieddate DESC limit 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ApproveRejectDQ')); 
        System.currentPageReference().getParameters().put('approvalRecord', list_quoteApprovals[0].Id);  
        System.currentPageReference().getParameters().put('retURL', 'test'); 
        System.currentPageReference().getParameters().put('skipValidation', 'test'); 
        
        ApproveRejectDQController objApproveRejectDQController  = new ApproveRejectDQController(); 
        objApproveRejectDQController.approve();
        objApproveRejectDQController.cancel();
        objApproveRejectDQController.reject();
        
        
        System.currentPageReference().getParameters().put('approvalRecord', 'test');  
        System.currentPageReference().getParameters().put('retURL', 'test'); 
        
        ApproveRejectDQController objApproveRejectDQController2  = new ApproveRejectDQController();
        
        Test.stoptest();
    }
    
    static testMethod void intialTest2() {
        Test.starttest();
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        List<Quote_Approval__c> list_quoteApprovals = [SELECT id, BigMachines_Quote__c, Deal_Qualification__c, 
            Deal_Qualification__r.Name, Comments__c, Step_Name__c, Status__c, Owner.Name, ownerId, Owner.Type, 
            Deal_Qualification__r.Incentive_Rebate__c,Reason_Name__c ,Deal_Qualification__r.Offering_Type__c
            FROM Quote_Approval__c 
            WHERE Status__c = :QuoteApprovalUtil.STATUS_PENDING
            ORDER BY Lastmodifieddate DESC limit 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ApproveRejectDQ')); 
        System.currentPageReference().getParameters().put('approvalRecord', list_quoteApprovals[0].Id);  
        System.currentPageReference().getParameters().put('retURL', 'test'); 
        
        
        ApproveRejectDQController objApproveRejectDQController  = new ApproveRejectDQController(); 
        objApproveRejectDQController.approve();
        objApproveRejectDQController.cancel();
        objApproveRejectDQController.reject();
        
        
        System.currentPageReference().getParameters().put('approvalRecord', 'test');  
        System.currentPageReference().getParameters().put('retURL', 'test'); 
        
        
        ApproveRejectDQController objApproveRejectDQController2  = new ApproveRejectDQController();
        
        list_quoteApprovals[0].Reason_Name__c = 'Special Offer Terms';
        update list_quoteApprovals[0];
        System.currentPageReference().getParameters().put('approvalRecord', list_quoteApprovals[0].Id);  
        ApproveRejectDQController objApproveRejectDQController3  = new ApproveRejectDQController();
        objApproveRejectDQController3.approve();
        objApproveRejectDQController3.cancel();
        objApproveRejectDQController3.reject();
        
        Test.stoptest();
    }
    
    static testMethod void intialTest3() {
        Test.starttest();
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        List<Quote_Approval__c> list_quoteApprovals = [SELECT id, BigMachines_Quote__c, Deal_Qualification__c, 
            Deal_Qualification__r.Name, Comments__c, Step_Name__c, Status__c, Owner.Name, ownerId, Owner.Type, 
            Deal_Qualification__r.Incentive_Rebate__c,Reason_Name__c ,Deal_Qualification__r.Offering_Type__c
            FROM Quote_Approval__c 
            WHERE Status__c = :QuoteApprovalUtil.STATUS_PENDING
            ORDER BY Lastmodifieddate DESC limit 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ApproveRejectDQ')); 
        System.currentPageReference().getParameters().put('approvalRecord', list_quoteApprovals[0].Id);  
        System.currentPageReference().getParameters().put('retURL', 'test'); 
        System.currentPageReference().getParameters().put('skipValidation', 'test'); 
        
        
        ApproveRejectDQController objApproveRejectDQController  = new ApproveRejectDQController(); 
        objApproveRejectDQController.approve();
        objApproveRejectDQController.cancel();
        objApproveRejectDQController.reject();
        
        
        System.currentPageReference().getParameters().put('approvalRecord', 'test');  
        System.currentPageReference().getParameters().put('retURL', 'test'); 
        
        
        ApproveRejectDQController objApproveRejectDQController2  = new ApproveRejectDQController();
        
        list_quoteApprovals[0].Reason_Name__c = 'Special Offer Terms';
        update list_quoteApprovals[0];
        System.currentPageReference().getParameters().put('approvalRecord', list_quoteApprovals[0].Id);  
        ApproveRejectDQController objApproveRejectDQController3  = new ApproveRejectDQController();
        objApproveRejectDQController3.approve();
        objApproveRejectDQController3.cancel();
        objApproveRejectDQController3.reject();
        
        Test.stoptest();
    }
}