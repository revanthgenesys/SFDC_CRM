public class BusinessRegionTemplateController {
    public String costId {get; set;}
    private BusinessRegionWrapper costWrap;
    public BusinessRegionTemplateController(){
        
    }
    
    public BusinessRegionWrapper getCostWrap(){
        String legalEntry = '';
        Business_Region__c cost;
        if(costId != null){
            cost = [SELECT Id, Name, Description__c, Definition__c, Region_ID__c, Hierarchy_1_PN__c, Hierarchy_2_PN__c, Hierarchy_3_PN__c, Level__c FROM Business_Region__c WHERE Id =: costId ];
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
        costWrap = new BusinessRegionWrapper(cost, aprvlid,comments);
        //costWrap = new BusinessRegionWrapper(cost, aprvlid);
        return costWrap;
    }
    
    public class BusinessRegionWrapper {
        public Business_Region__c costObj {get; set;}
        public String approverId {get; set;}
        public String comment {get; set;}
        
        public BusinessRegionWrapper(Business_Region__c cost, String aprvlId, String cmnt){
            costObj = cost;
            approverId = aprvlId;
            comment = cmnt;
        }
        
        public BusinessRegionWrapper(){
        
        }
    }
}