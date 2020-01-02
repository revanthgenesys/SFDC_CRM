/*
Author: Mukunthan Koothan
Creation Date: 18-APR-2018

*/
public class CustomApprovalProcExpEtnController {


    //Properties Declaration
    transient public ApprovalList aSW {get; private set;}
    private Id recordId;
    private Id retURLRecordId;
    private String ORG_LNK;
    public boolean isApprHistoryAvailable{get;set;}
    public string recallURL{get;set;}
    public partner_portal_prospect__c deal{get;set;} 
   //Properties Construnctor
    public CustomApprovalProcExpEtnController(ApexPages.StandardController controller) {
        retURLRecordId = recordId = ApexPages.currentPage().getParameters().get('id');
         if(!Test.isRunningTest())
          controller.addFields(new List<String>{'End_Date__c', 'Proposed_End_Date__c','Opportunity_Channel_Manager__c','Opportunity_Channel_Manager__r.Name'});
        deal = (partner_portal_prospect__c) controller.getRecord();
        ORG_LNK = 'https://'+URL.getSalesforceBaseUrl().getHost();
        isApprHistoryAvailable = true;
        if(!String.isBlank(recordID)){
            aSW = new ApprovalList();
            aSW = generateData();
        }            
    }  
    ApprovalList generateData(){
        ApprovalList approvalResultForObject = new ApprovalList();
        List<ApprovalStepWrapper> aSW = new List<ApprovalStepWrapper>();
        String recallApprovalProcessLink;
        Boolean isSubmitForApproval = true;
        //System.Debug('getProcessHistory(recordId).values()--->'+getProcessHistory(recordId));
        //System.Debug('getProcessHistory(recordId).values()--->'+getProcessHistory(recordId).values());
        for(ProcessInstance pI:getProcessHistory(recordId).values()){
            Map<Id,List<ProcessInstanceHistory>> mapOfProcessNodeIdAndProcessInstanceHistory = new Map<Id,List<ProcessInstanceHistory>>();
            Set<Id> processNodeId= new Set<Id>(); 
            //System.Debug('pI.StepsAndWorkitems--->'+pI.StepsAndWorkitems);
            for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
                if(processNodeId.size() ==0)
                    processNodeId.add(sWI.ProcessNodeId);
                else if(processNodeId.size()>0 && processNodeId.contains(sWI.ProcessNodeId)!= NULL)
                    processNodeId.add(sWI.ProcessNodeId);
            }
            //System.Debug('processNodeId--->'+processNodeId);
            for(Id pNId: processNodeId){
                ApprovalStepWrapper aSWr = new ApprovalStepWrapper();
                for(ProcessInstanceHistory sWI:pI.StepsAndWorkitems){
                    if(sWI.processNodeId == pNID){
                        aSWr.listOfSteps.add(sWI);
                    }
                    if(sWI.StepStatus == 'Pending'){
                        aSWr.workItemApproveOrRejectLink = ORG_LNK+'/p/process/ProcessInstanceWorkitemWizardStageManager?id='+sWI.Id;
                        aSWr.workItemReassignLink =  ORG_LNK+'/'+sWI.Id+'/e?et=REASSIGN&retURL=/'+retURLRecordId;
                        recallApprovalProcessLink =  ORG_LNK +'/'+sWI.Id+'/e?et=REMOVE&retURL=/'+retURLRecordId;
                        isSubmitForApproval = false;
                    }
                    
                }
                aSW.add(aSWr);
            }
        }
        //System.Debug('aSW--->'+aSW);
        if(aSW==null || aSW.size()==0){
            isApprHistoryAvailable = false;
        }
        approvalResultForObject.approvals = aSW;
        approvalResultForObject.recordId = recordId;
        approvalResultForObject.isSubmitForApproval = isSubmitForApproval;
        approvalResultForObject.recallApprovalProcessLink = recallApprovalProcessLink;
        recallURL=recallApprovalProcessLink;
        //System.Debug('approvalResultForObject--->'+approvalResultForObject);
        return approvalResultForObject;
    }
    private Map<Id,ProcessInstance> getProcessHistory(Id objectId){
       return new Map<Id,ProcessInstance>([SELECT Id, (SELECT ID, ProcessNodeId,
 StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending
,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,
OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by CreatedDate DESC, Id DESC ) 
FROM ProcessInstance where TargetObjectId =:objectId AND ProcessDefinition.DeveloperName IN ('Above_6_Months_Expiration_Extension','Below_6_Months_Expiration_Extension')
 order by CreatedDate DESC, Id DESC]);
    }
    public class ApprovalStepWrapper{
        public String workItemApproveOrRejectLink {get;set;}
        public String workItemReassignLink {get;set;}
        public List<ProcessInstanceHistory> listOfSteps {get;set;}
        public ApprovalStepWrapper(){
            listOfSteps = new  List<ProcessInstanceHistory>();
        }
    }
    public class ApprovalList{
        public List<ApprovalStepWrapper> approvals {get;set;}
        public String recallApprovalProcessLink {get;set;}
        public Boolean isSubmitForApproval {get;set;}
        public Id recordId {get;set;}
        public ApprovalList(){
            approvals = new List<ApprovalStepWrapper>();
            isSubmitForApproval = true;
        }
    }
}