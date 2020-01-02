public class HierarchyTemplateController {
    public String costId {get; set;}
    private HierarchyWrapper costWrap;
    public HierarchyTemplateController(){
        
    }
    
    public HierarchyWrapper getCostWrap(){
        String legalEntry = '';
        Hierarchy__c cost;
        if(costId != null){
            cost = [SELECT Id, Name, Unique_Hierarchy_ID1__c, Top_Node_ID1__r.Node_ID1__c, Domain__c, Hierarchy_Description__c, 
                        Node_ID1__c, Node_Description__c, Node_Type__c, Parent_Node_ID1__r.Node_ID1__c, Level__c 
                        FROM Hierarchy__c WHERE Id =: costId];
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
        costWrap = new HierarchyWrapper(cost, aprvlid,comments);
        //costWrap = new HierarchyWrapper(cost, aprvlid);
        return costWrap;
    }
    
    public class HierarchyWrapper {
        public Hierarchy__c costObj {get; set;}
        public String approverId {get; set;}
        public String comment{get; set;}
        
        public HierarchyWrapper(Hierarchy__c cost, String aprvlId,String cmnt){
            costObj = cost;
            approverId = aprvlId;
            comment = cmnt;
        }
        
        public HierarchyWrapper(){
        
        }
    }
}