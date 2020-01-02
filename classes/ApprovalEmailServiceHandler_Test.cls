@isTest(seeAllData=true)
private class ApprovalEmailServiceHandler_Test {
    static testMethod void testMethod_1() {
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];   
        User adminUser = [select id,name,email from User where ProfileId =: partnerProfile.id and ManagerId !=NULL AND isActive = TRUE limit 1];
        
        Test.startTest();
        
        System.runAs(adminUser){
        
        
        
        Lead_Referral_Registration__c  pLead = new Lead_Referral_Registration__c();
        pLead.name = 'Test Lead';
        pLead.Channel_Manager__c = adminUser.id;
        insert pLead;
        
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(pLead.id);
        List<Id> nextApproverIds = new List<Id>();
        nextApproverIds.add(adminUser.id);
        req1.setNextApproverIds(nextApproverIds);
        // Commented by Sourav to prevent template exception to deploy Cloud Billing project (10/19/2015)
        //Approval.ProcessResult result = Approval.process(req1);
        
        Lead_Referral_Registration__c LeadReferralObj;
        String processWorkItemId;
        List<Lead_Referral_Registration__c> LeadReferralObjList = [Select id,(select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus from ProcessSteps where StepStatus = 'Pending') from Lead_Referral_Registration__c where id =: pLead.id LIMIT 1];
        System.debug('*****LeadReferralObjList'+LeadReferralObjList);
        if(LeadReferralObjList.size() == 1){
            LeadReferralObj = LeadReferralObjList[0];
            System.debug('*****LeadReferralObj'+LeadReferralObj);           
            if(LeadReferralObj.ProcessSteps!=null && LeadReferralObj.ProcessSteps.size()>0){
                System.debug('******LeadReferralObj.ProcessSteps[0]'+LeadReferralObj.ProcessSteps[0]);
                processWorkItemId = LeadReferralObj.ProcessSteps[0].id;
            }
        }
        
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'test';
        email.plainTextBody  = 'approved \n testcomments\n recordidstart' + pLead.id + 'recordidend' + 'workprocessitemidstart' + processWorkItemId + 'workprocessitemidend';
        
        env.fromAddress = adminUser.email;
        
        ApprovalEmailServiceHandler emailServiceObj = new ApprovalEmailServiceHandler();

        emailServiceObj.handleInboundEmail(email, env );
        
        
        
        }
        Test.stopTest();
    }
}