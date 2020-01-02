public class LegalEntityTemplateController {
    public String costId {get; set;}
    private LegalEntityWrapper costWrap;
    public LegalEntityTemplateController(){
        
    }
    
    public LegalEntityWrapper getCostWrap(){
        String legalEntry = '';
        Legal_Entity__c cost;
        if(costId != null){
            cost = [SELECT Id, Name, Legal_Entity__c, Name_No_Hierarchy__c, Status__c, Address_1__c, Address_2__c, Language__c, 
                        Address_3__c, City__c, State_Province__c, Zip__c, Country__r.Name, Currency_Code__c, Elimination__c, Tax_ID__c 
                        FROM Legal_Entity__c WHERE Id =: costId];
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
        costWrap = new LegalEntityWrapper(cost, aprvlid, comments);
        //costWrap = new LegalEntityWrapper(cost, aprvlid);
        return costWrap;
    }
    
    public class LegalEntityWrapper {
        public Legal_Entity__c costObj {get; set;}
        public String approverId {get; set;}
        public String comment {get; set;}
        
        public LegalEntityWrapper(Legal_Entity__c cost, String aprvlId, String cmnt){
            costObj = cost;
            approverId = aprvlId;
            comment = cmnt;
        }
        
        public LegalEntityWrapper(){
        
        }
    }
}