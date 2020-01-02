public class BusinessSegmentTemplateController {
    public String costId {get; set;}
    private BusinessSegmentWrapper costWrap;
    public BusinessSegmentTemplateController(){
        
    }
    
    public BusinessSegmentWrapper getCostWrap(){
        String legalEntry = '';
        Business_Segment__c cost;
        if(costId != null){
            cost = [SELECT Id, Name, Business_Segment_ID__c, Status__c, Hierarchy_node__r.Name,Description__c,
                     Business_Segment_Offer_Type_Hierarchy1__r.Name, Business_Segment_Cloud_Hierarchy__r.Name,
                     Business_Segment_Offer_Type_Hi_Parent_No__c,Business_Segment_Cloud_Hi_Parent_N__c, NewUpdated_Indicator__c,
                     Hierarchy_Parent_node__c,
                     (SELECT Name, Legal_Entity_ID__c FROM Business_Segment_Legal_Entities__r)
                     FROM Business_Segment__c 
                     WHERE Id =: costId];                     
                     
            if(cost.Business_Segment_Legal_Entities__r.size() > 0 && cost.Business_Segment_Legal_Entities__r.size() <= 10){                
                for(Business_Segment_Legal_Entity__c legal : cost.Business_Segment_Legal_Entities__r){
                    legalEntry += legal.Legal_Entity_ID__c + ',';
                }
                legalEntry = legalEntry.subString(0, legalEntry.lastIndexOf(','));                
            }
            if(cost.Business_Segment_Legal_Entities__r.size() > 10)
                 legalEntry = 'Please take a look at the Business Segment to see the full list of Legal Entities.';  
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
        costWrap = new BusinessSegmentWrapper(cost, aprvlid,legalEntry,comments);
        //costWrap = new BusinessSegmentWrapper(cost, aprvlid,legalEntry);
        return costWrap;
    }
    
    public class BusinessSegmentWrapper {
        public Business_Segment__c costObj {get; set;}
        public String approverId {get; set;}
        public String legalEntry {get; set;}
        public String comment {get; set;}
        
        public BusinessSegmentWrapper(Business_Segment__c cost, String aprvlId, String entries, String cmnt){
            costObj = cost;
            approverId = aprvlId;
            legalEntry = entries;
            comment = cmnt;
        }
        
        public BusinessSegmentWrapper(){
        
        }
    }
}