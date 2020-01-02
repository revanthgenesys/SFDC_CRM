public class LicenseReqActivityHistory {
        
        public List<EmailMessage> msgs {get; set;}
        public List<Task> tsks {get; set;}
        public String msgId {get; set;}
        private ID licRecId;
        
        public LicenseReqActivityHistory (ApexPages.StandardController stdController)  {
          licRecId = stdController.getId();
          
          msgs = new List<EmailMessage>();
          tsks = new List<Task>();
          
          if ( licRecId != null ) {               
                  getEmailList(); 
                         
                  tsks = [SELECT Subject, CreatedDate FROM Task WHERE WhatId = :licRecId AND Subject LIKE 'Auto-Follow up%' 
                          ORDER BY CreatedDate DESC];
          }
          
        }
        
        public PageReference delRec() {
                if ( msgId != null ) {
                  List<EmailMessage> delms = [SELECT Id FROM EmailMessage WHERE Id = :msgId];
                  
                  if ( !delms.isEmpty() ) {
                        delete delms[0];
                        getEmailList();
                  }                  
                }
                
                return null;
        }
        
        private void getEmailList() {
            msgs = [SELECT Id, CreatedDate, Incoming, FromAddress, FromName, HasAttachment, ToAddress, subject
                    FROM EmailMessage 
                    WHERE relatedToId = :licRecId OR Related_Activation_Request__c = :licRecId
                    ORDER BY CreatedDate DESC];
        }
    
    
}