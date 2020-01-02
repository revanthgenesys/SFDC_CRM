/* 
Purpose: controller for the page BackOfficeAccountSLTsetup
Test class: BackOfficeAccountSLTsetup_Test
*/
public class BackOfficeAccountSLTsetup {
	
	 public Service_Level_Target__c currentSlt {get; set;}
        public Back_Office_Account__c boa {get; set;}
        public String currentSltType {get; set;}
        public String mode {get; set;}
        private ID boaId;
  
        public BackOfficeAccountSLTsetup (ApexPages.StandardController stdController)  {
            boaId = stdController.getId();
            currentSltType = '';
            mode = 'view';
            
            if ( boaId != null )  {
                List<Back_Office_Account__c> boalst = [SELECT Name, Support_Package__c FROM Back_Office_Account__c WHERE Id = :boaId];
                boa = boalst[0];
                    
                setCurrentSlt();
            }           
        }
        
        private void setCurrentSlt() {
                 if ( boaId == null )
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
                 List<Service_Level_Target__c> boaSlt = [SELECT Id, Name, SLT_Level__c, Back_Office_Account__r.Name,
                                                Resolution_Critical__c, Resolution_High__c, Resolution_Low__c, Resolution_Medium__c,
                                                Response_Critical__c, Response_High__c, Response_Low__c, Response_Medium__c, 
                                                Restoration_Critical__c, Restoration_High__c, Restoration_Medium__c, 
                                                Restoration_Low__c, Restoration_Production_Down__c, Resolution_Production_Down__c,
                                                Response_Production_Down__c
                                               FROM Service_Level_Target__c 
                                               WHERE Back_Office_Account__c = :boaId 
                                                AND RecordType.DeveloperName = 'SLT_BOA'];                 
            if ( boaSlt.size() > 0)  
                return boaSlt[0];
            else                      
                return null;
        }
        
        private Service_Level_Target__c defaultSlt() {           
                 if ( boa == null || boa.Support_Package__c == null )
                       return null;
                
                 List<Service_Level_Target__c> boaSlt = [SELECT Id, Name, SLT_Level__c,
                                               Resolution_Critical__c, Resolution_High__c, Resolution_Low__c, Resolution_Medium__c,
                                                Response_Critical__c, Response_High__c, Response_Low__c, Response_Medium__c, 
                                                Restoration_Critical__c, Restoration_High__c, Restoration_Medium__c, 
                                                Restoration_Low__c, Restoration_Production_Down__c, Resolution_Production_Down__c,
                                                Response_Production_Down__c
                                               FROM Service_Level_Target__c 
                                               WHERE BOA_Support_Package__c = :boa.Support_Package__c
                                                AND RecordType.DeveloperName = 'SLT_BOA_Definition']; 
                
             if ( boaSlt.size() > 0)  
                return boaSlt[0];
             else                      
                 return null;
        }
        
        public PageReference addCustomSlt() {
                /// prepopulate values from an existing default SLT Record
                Service_Level_Target__c defaultSlt = defaultSlt();
                
                List<RecordType> recType = [SELECT Id FROM RecordType 
                                           WHERE SobjectType = 'Service_Level_Target__c' AND DeveloperName = 'SLT_BOA'];
                                            
                currentSlt = new Service_Level_Target__c(RecordTypeId = recType[0].Id, Back_Office_Account__c = boaId);           
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