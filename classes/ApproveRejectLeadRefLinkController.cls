public class ApproveRejectLeadRefLinkController{
public string relatedRecordIdField{get;set;}
public String sfdcBaseURL{get;set;}
//public string objectAPINameField{get;set;}
    public ApproveRejectLeadRefLinkController(){
        sfdcBaseURL='';
        Partner_Portal_Settings__c BaseURLSetting = Partner_Portal_Settings__c.getValues('BaseURL');
        if(BaseURLSetting!=null){
            sfdcBaseURL = BaseURLSetting.Id_Value__c;
        }
        //sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        //sfdcBaseURL = 'https://cs9.salesforce.com';
    }
    public String getWorkItemId(){
        Lead_Referral_Registration__c LeadReferralObj;
        String processWorkItemId;
        List<Lead_Referral_Registration__c> LeadReferralObjList = [Select id,(select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus from ProcessSteps where StepStatus = 'Pending') from Lead_Referral_Registration__c where id =: relatedRecordIdField LIMIT 1];
        System.debug('*****LeadReferralObjList'+LeadReferralObjList);
        if(LeadReferralObjList.size() == 1){
            LeadReferralObj = LeadReferralObjList[0];
            System.debug('*****LeadReferralObj'+LeadReferralObj);           
            if(LeadReferralObj.ProcessSteps!=null && LeadReferralObj.ProcessSteps.size()>0){
                System.debug('******LeadReferralObj.ProcessSteps[0]'+LeadReferralObj.ProcessSteps[0]);
                processWorkItemId = LeadReferralObj.ProcessSteps[0].id;
            }
        }
        return processWorkItemId;
    }
}