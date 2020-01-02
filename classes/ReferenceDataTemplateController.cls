public class ReferenceDataTemplateController {
    public String costId {get; set;}
    private ReferenceDataWrapper costWrap;
    public ReferenceDataTemplateController(){
        
    }
    
    public ReferenceDataWrapper getCostWrap(){
        String legalEntry = '';
        Reference_Data__c cost;
        if(costId != null){


            cost = [SELECT Id, Name, Data_Element_ID__c, Data_Element_ID_Description__c, Data_Element_ID_Status__c, Data_Element__c 
                        FROM Reference_Data__c WHERE Id =: costId];
        }
        List<ProcessInstanceWorkitem> list_approval = new List<ProcessInstanceWorkitem>([Select Id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:costId]);
        String aprvlid = '';
        if(list_approval.size() > 0){
            aprvlid = list_approval.get(0).Id;
        }
        String comments = '';
        List<ProcessInstance> list_Process = new List<ProcessInstance>([Select Id from ProcessInstance where TargetObjectId =:costId order by createddate desc limit 1]);
        
        if(list_Process.size() > 0){
            List<ProcessInstanceStep> list_ProcessStep = new List<ProcessInstanceStep>([Select Id,  StepStatus, Comments FROM ProcessInstanceStep where ProcessInstanceId =: list_Process.get(0).Id order by createdDate desc limit 1]);
            if(list_ProcessStep.size() > 0){
                comments = list_ProcessStep.get(0).Comments;
            }
        }
        costWrap = new ReferenceDataWrapper(cost, aprvlid, comments);
        //costWrap = new ReferenceDataWrapper(cost, aprvlid);
        return costWrap;
    }
    
    public class ReferenceDataWrapper {
        public Reference_Data__c costObj {get; set;}
        public String approverId {get; set;}
        public String comment {get; set;}
        
        public ReferenceDataWrapper(Reference_Data__c cost, String aprvlId, String cmnt){
            costObj = cost;
            approverId = aprvlId;
            comment = cmnt;
        }
        
        public ReferenceDataWrapper(){
        
        }
    }
}