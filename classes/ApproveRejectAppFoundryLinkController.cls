public class ApproveRejectAppFoundryLinkController {
public String relatedRecordIdField{get;set;}
public String sfdcBaseURL{get;set;}
//public string objectAPINameField{get;set;}
    public ApproveRejectAppFoundryLinkController(){
        sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        Partner_Portal_Settings__c settings = Partner_Portal_Settings__c.getInstance('BaseURL');
        sfdcBaseURL = settings.Id_Value__c;  
    }
    public String getWorkItemId(){
        Technology_Market_place_Application__c appFountryApplicationObj;
        String processWorkItemId;
        List<Technology_Market_place_Application__c> appFountryApplicationobjList = [Select id,(select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus from ProcessSteps where StepStatus = 'Pending') from Technology_Market_place_Application__c where id =: relatedRecordIdField LIMIT 1];
        System.debug('*****appFountryApplicationobjList'+appFountryApplicationobjList);
        if(appFountryApplicationobjList.size() == 1){
            appFountryApplicationObj = appFountryApplicationobjList[0];
            System.debug('*****appFountryApplicationObj'+appFountryApplicationObj);           
            if(appFountryApplicationObj.ProcessSteps!=null && appFountryApplicationObj.ProcessSteps.size()>0){
                System.debug('******appFountryApplicationObj.ProcessSteps[0]'+appFountryApplicationObj.ProcessSteps[0]);
                processWorkItemId = appFountryApplicationObj.ProcessSteps[0].id;
            }
        }
        return processWorkItemId;
    }
}