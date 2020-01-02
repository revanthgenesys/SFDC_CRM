public class CaseMngrAttentionController {
        
        public Integer esclNum {get; set;}
        public List<Case_Escalation__c> EsclRec {get; set;}
        public List<Case_Escalation__c> escls  {get; set;}
        
        public CaseMngrAttentionController(ApexPages.StandardController stdController)  {
                String csId = Apexpages.currentPage().getParameters().get('Id');
                
                esclNum = 0;

                                
                if ( csId != null && String.isNotBlank(csId) ) {
                    escls = [SELECT Id,Name,Account_Escalation_Owner__r.Name,Level__c,Reason__c,Status__c
                                 FROM Case_Escalation__c WHERE Status__c = 'Open'
                                 AND End_User_Account__c IN (SELECT End_User_Account__c FROM Case WHERE id = :csId )];                                                         
                        esclNum = escls.size(); 
                    
                    EsclRec    = [SELECT Id,Name,Account_Escalation_Owner__r.Name,Level__c,Reason__c,Status__c
                                  FROM Case_Escalation__c WHERE Case__c=:csId AND  Status__c != 'Closed']; 
                }
                
        }
    
}