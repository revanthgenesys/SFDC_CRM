public class ERPCurrencyTemplateController {
    public String costId {get; set;}
    private ERPCurrencyWrapper costWrap;
    public ERPCurrencyTemplateController(){
        
    }
    
    public ERPCurrencyWrapper getCostWrap(){
        String legalEntry = '';
        ERP_Currency_Daily_Exchange_Rate__c cost;
        if(costId != null){
            cost = [SELECT Id, Name, From_Currency_Name__c, FROM_CURRENCY_CODE__c, Effective_Date__c, CONVERSION_RATE__c
                        FROM ERP_Currency_Daily_Exchange_Rate__c WHERE Id =: costId];
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
        costWrap = new ERPCurrencyWrapper(cost, aprvlid, comments);
        //costWrap = new ERPCurrencyWrapper(cost, aprvlid);
        return costWrap;
    }
    
    public class ERPCurrencyWrapper {
        public ERP_Currency_Daily_Exchange_Rate__c costObj {get; set;}
        public String approverId {get; set;}
        public String comment {get; set;}
        
        public ERPCurrencyWrapper(ERP_Currency_Daily_Exchange_Rate__c cost, String aprvlId, String cmnt){
            costObj = cost;
            approverId = aprvlId;
            comment = cmnt;
        }
        
        public ERPCurrencyWrapper(){
        
        }
    }
}