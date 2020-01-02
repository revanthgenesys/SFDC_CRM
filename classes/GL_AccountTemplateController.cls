public class GL_AccountTemplateController {
    public String costId {get; set;}
    private GL_AccountWrapper costWrap;
    public GL_AccountTemplateController(){
        
    }
    
    public GL_AccountWrapper getCostWrap(){
        String legalEntry = '';
        GL_Account__c cost;
        if(costId != null){
           
            cost = [SELECT Id, Name,  Description__c,Proposed_GL_Account_ID__c, Netsuite_Type__c, GL_Account_Type__c,Statistical_Account_Number__c, 
                        Statistical_Account_Description__c, Chart_of_Account__c, Business_Segment__r.Name, NewUpdated_Indicator__c, NewUpdate_Request_Indicator__c,
                        Currency__r.Currency_ISO_Code__c, Asset_Management__c, GL_Account_Management_Hierarchy__r.Name, 
                        System_Posting_Only__c, Revalue_Open_Balance_for_Foreign_Currenc__c,  FX_Clearing__c, 
                        Eliminate_intercompany_transactions__c,  X1099_Misc_Category__c,  Account_Definition__c, 
                        Financial_Statement_Updated_in_NetSuite__c, Planning_Account_Number__c, Planning_Account_Description__c,
                        (SELECT Name, Legal_Entity_ID__c FROM GL_Account_Legal_Entities__r)                         
                        FROM GL_Account__c WHERE Id =: costId];

            if(cost.GL_Account_Legal_Entities__r.size() > 0 && cost.GL_Account_Legal_Entities__r.size() <= 10){                
                for(GL_Account_Legal_Entity__c legal : cost.GL_Account_Legal_Entities__r){
                    legalEntry += legal.Legal_Entity_ID__c + ',';
                }
                legalEntry = legalEntry.subString(0, legalEntry.lastIndexOf(','));                
            }
            
             if(cost.GL_Account_Legal_Entities__r.size() > 10)
                 legalEntry = 'Please take a look at the GL Account to see the full list of Legal Entities.';
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
        costWrap = new GL_AccountWrapper(cost, aprvlid, comments, legalEntry);
        //costWrap = new GL_AccountWrapper(cost, aprvlid);
        return costWrap;
    }
    
    public class GL_AccountWrapper {
        public GL_Account__c costObj {get; set;}
        public String approverId {get; set;}
        public String comment {get; set;}
        public String legalEntry {get; set;}
        
        public GL_AccountWrapper(GL_Account__c cost, String aprvlId, String cmnt, String entries){
            costObj = cost;
            approverId = aprvlId;
            comment = cmnt;
            legalEntry = entries;
        }
        
        public GL_AccountWrapper(){
        
        }
    }
}