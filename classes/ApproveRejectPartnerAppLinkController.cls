public class ApproveRejectPartnerAppLinkController{
public String relatedRecordIdField{get;set;}
public String sfdcBaseURL{get;set;}
//public string objectAPINameField{get;set;}
    public ApproveRejectPartnerAppLinkController(){
        sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        sfdcBaseURL ='https://genesys.my.salesforce.com';  
    }
    public String getWorkItemId(){
        Partner_Application__c PartnerApplicationObj;
        String processWorkItemId;
        List<Partner_Application__c> PartnerApplicationobjList = [Select id,(select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus from ProcessSteps where StepStatus = 'Pending') from Partner_Application__c where id =: relatedRecordIdField LIMIT 1];
        System.debug('*****PartnerApplicationobjList'+PartnerApplicationobjList);
        if(PartnerApplicationobjList.size() == 1){
            PartnerApplicationObj = PartnerApplicationobjList[0];
            System.debug('*****PartnerApplicationObj'+PartnerApplicationObj);           
            if(PartnerApplicationObj.ProcessSteps!=null && PartnerApplicationObj.ProcessSteps.size()>0){
                System.debug('******PartnerApplicationObj.ProcessSteps[0]'+PartnerApplicationObj.ProcessSteps[0]);
                processWorkItemId = PartnerApplicationObj.ProcessSteps[0].id;
            }
        }
        return processWorkItemId;
    }
}