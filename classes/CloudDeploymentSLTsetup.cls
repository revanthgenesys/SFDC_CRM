public class CloudDeploymentSLTsetup {
        
        public Service_Level_Target__c currentSlt {get; set;}
        public Cloud_Deployment__c depl {get; set;}
        public String currentSltType {get; set;}
        public String mode {get; set;}
        private ID deplId;
  
        public CloudDeploymentSLTsetup (ApexPages.StandardController stdController)  {
            deplId = stdController.getId();
            currentSltType = '';
            mode = 'view';
            
            if ( deplId != null )  {
                    List<Cloud_Deployment__c> cldDepl = [SELECT Name, Care_Level__c FROM Cloud_Deployment__c WHERE Id = :deplId];
                    depl = cldDepl[0];
                    
                        setCurrentSlt();
            }           
        }
        
        private void setCurrentSlt() {
                 if ( deplId == null )
                     return;
                 
                currentSlt = customSlt();
                if ( currentSlt != null )
                   currentSltType = 'custom';
                else {
                   currentSlt = defaultSlt();
                   currentSltType = 'template';
                }               
        }
             
        private Service_Level_Target__c customSlt() {           
                 List<Service_Level_Target__c> cldSlt = [SELECT Id, Name, SLT_Level__c, Cloud_Deployment__r.Name,
                                                Resolution_Critical__c, Resolution_High__c, Resolution_Low__c, Resolution_Medium__c,
                                                Response_Critical__c, Response_High__c, Response_Low__c, Response_Medium__c, 
                                                Restoration_Critical__c, Restoration_High__c, Restoration_Medium__c, 
                                                Restoration_Low__c, Restoration_Production_Down__c, Resolution_Production_Down__c,
                                                Response_Production_Down__c
                                               FROM Service_Level_Target__c 
                                               WHERE Cloud_Deployment__c = :deplId 
                                                AND RecordType.DeveloperName = 'SLT_Cloud_Deployment'];                 
            if ( cldSlt.size() > 0)  
                return cldSlt[0];
        else                      
                        return null;
        }
        
        private Service_Level_Target__c defaultSlt() {           
                 if ( depl == null || depl.Care_Level__c == null )
                       return null;
                
                 List<Service_Level_Target__c> cldSlt = [SELECT Id, Name, SLT_Level__c,
                                               Resolution_Critical__c, Resolution_High__c, Resolution_Low__c, Resolution_Medium__c,
                                                Response_Critical__c, Response_High__c, Response_Low__c, Response_Medium__c, 
                                                Restoration_Critical__c, Restoration_High__c, Restoration_Medium__c, 
                                                Restoration_Low__c, Restoration_Production_Down__c, Resolution_Production_Down__c,
                                                Response_Production_Down__c
                                               FROM Service_Level_Target__c 
                                               WHERE Cloud_Support_Package__c = :depl.Care_Level__c
                                                AND RecordType.DeveloperName = 'SLT_Cloud_Master_Definition']; 
                
             if ( cldSlt.size() > 0)  
                return cldSlt[0];
        else                      
                        return null;
        }
        
        public PageReference addCustomSlt() {
                /// prepopulate values from an existing default SLT Record
                Service_Level_Target__c defaultSlt = defaultSlt();
                
                List<RecordType> recType = [SELECT Id FROM RecordType 
                                           WHERE SobjectType = 'Service_Level_Target__c' AND DeveloperName = 'SLT_Cloud_Deployment'];
                                            
                currentSlt = new Service_Level_Target__c(RecordTypeId = recType[0].Id, Cloud_Deployment__c = deplId);           
                if ( defaultSlt != null )  {
                         currentSlt.Resolution_Production_Down__c = defaultSlt.Resolution_Production_Down__c;
                     currentSlt.Resolution_Critical__c = defaultSlt.Resolution_Critical__c; 
                     currentSlt.Resolution_High__c  = defaultSlt.Resolution_High__c; 
                     currentSlt.Resolution_Low__c = defaultSlt.Resolution_Low__c;
                     currentSlt.Resolution_Medium__c = defaultSlt.Resolution_Medium__c; 
    
                     currentSlt.Response_Production_Down__c = defaultSlt.Response_Production_Down__c;
                     currentSlt.Response_Critical__c = defaultSlt.Response_Critical__c;                                        
                     currentSlt.Response_High__c = defaultSlt.Response_High__c; 
                     currentSlt.Response_Low__c = defaultSlt.Response_Low__c; 
                     currentSlt.Response_Medium__c = defaultSlt.Response_Medium__c; 
                     
                     currentSlt.Restoration_Production_Down__c = defaultSlt.Restoration_Production_Down__c;
                     currentSlt.Restoration_Critical__c = defaultSlt.Restoration_Critical__c;                                        
                     currentSlt.Restoration_High__c = defaultSlt.Restoration_High__c; 
                     currentSlt.Restoration_Low__c = defaultSlt.Restoration_Low__c; 
                     currentSlt.Restoration_Medium__c = defaultSlt.Restoration_Medium__c; 
 
                }
                
                currentSltType = 'newcust';
                mode = 'edit';
                return null;
        }

  public PageReference removeCustomSlt() {
           Service_Level_Target__c custSlt = customSlt();
           if ( custSlt != null )  {
                delete custSlt;
                currentSlt = defaultSlt();
                currentSltType = 'template';
           }            
           return null; 
   }
   
   public PageReference saveCustSlt() {
           try {
                  if ( currentSltType == 'custom' )             
                      update currentSlt;

                  else if ( currentSltType == 'newcust' )  
                       insert currentSlt;
                }
                catch (Exception ex) {
                         ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error updating SLT. Additional details: ' + ex.getMessage() );
                 ApexPages.addMessage(msg); 
                 return null;
                }
          
          currentSlt = customSlt();
          currentSltType = 'custom';    
          mode = 'view' ;      
          return null;  
   }
   
    public PageReference actCancel() {
        setCurrentSlt();
        mode = 'view';
        return null;
    }
    
      public PageReference editCustom() {
        mode = 'edit';
        return null;
    }
}