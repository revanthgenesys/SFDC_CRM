public class LiveChatEnableController {
        
        public Boolean enableFlg {get; set;}
        public String url {get; set;}
        public String key {get; set;}
        private Customer_Care_Live_Chat__c csf;
        
        public LiveChatEnableController() {
            csf = Customer_Care_Live_Chat__c.getOrgDefaults();
            enableFlg = csf.Enabled__c; 
            url = csf.URL__c;   
            key = csf.Key__c;     
        }
        
        public PageReference applyUpdate() {
            csf.Enabled__c = enableFlg; 
            csf.URL__c = url;
            csf.Key__c = key;
            
            try {
                update csf;
            }
            catch (Exception e) {
                 ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,  e.getMessage()));
                 return null;
            }
            
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'Update has been successfully applyed.'));
            return null;
        }             

}