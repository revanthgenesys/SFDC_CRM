public class CostCenterTemplateController {
    public String costId {get; set;}
    private CostWrapper costWrap;
    public CostCenterTemplateController(){
        
    }
    
    public CostWrapper getCostWrap(){
        String legalEntry = '';
        Cost_Center__c cost;
        if(costId != null){
            cost = [SELECT Id, Name, Cost_Center_ID1__c, Description__c, Cost_Center_Type__c, FP_A_Owner__r.Name, Planning_Only_Yes_No__c, NewUpdated_Indicator__c,
                            GL_Account_Posting_Rule_Group1__r.Data_Element_ID__c, Cost_Center_GAAP_Reporting_Hierarchy__r.Name, Cost_Center_Management_Hierarchy__r.Name, 
                            (SELECT Name, Legal_Entity_ID__c FROM Cost_Center_Legal_Entities__r) , Region__r.description__c, 
                            Business_Segment__r.Name FROM Cost_Center__c WHERE Id =: costId];
                            
            if(cost.Cost_Center_Legal_Entities__r.size() > 0 && cost.Cost_Center_Legal_Entities__r.size() <= 10){                
                for(Cost_Center_Legal_Entity__c legal : cost.Cost_Center_Legal_Entities__r){
                    legalEntry += legal.Legal_Entity_ID__c + ',';
                }
                legalEntry = legalEntry.subString(0, legalEntry.lastIndexOf(','));                
            }
            if(cost.Cost_Center_Legal_Entities__r.size() > 10)
                legalEntry = 'Please take a look at the Cost Center to see the full list of Legal Entities.';
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
        costWrap = new CostWrapper(cost, legalEntry, aprvlid,comments);
        //costWrap = new CostWrapper(cost, legalEntry, aprvlid);
        return costWrap;
    }
    
    public class CostWrapper {
        public Cost_Center__c costObj {get; set;}
        public String legalEntry {get; set;}
        public String approverId {get; set;}
        public String comment {get; set;}
        
        public CostWrapper(Cost_Center__c cost, String entries, String aprvlId, String cmnt){
            costObj = cost;
            legalEntry = entries;
            approverId = aprvlId;
            comment = cmnt;
        }
        
        public CostWrapper(){
        
        }
    }
}