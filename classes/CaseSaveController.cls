public class CaseSaveController {
        
        public Case cs {get; set;}
        public String caseType {get; set;}
        public List<SelectOption> prioropts {get; set;}
        public String cldDeplName {get; set;}
        public String cldServName {get; set;}
        public String platform {get; set;}
        private String recordTypeId;        
       
        public CaseSaveController(ApexPages.StandardController stdController)  {
                
                 recordTypeId = ApexPages.currentPage().getParameters().get('RecordType'); 
                 
                 platform = '';
                 if ( String.isNotBlank(recordTypeId) )
                         caseType = CaseUtil.getAllTScaseTypesMap().get(recordTypeId).DeveloperName;
                 
                 String contId = ApexPages.currentPage().getParameters().get('contId'); 
                 String stId = ApexPages.currentPage().getParameters().get('stId');
                 String euId = ApexPages.currentPage().getParameters().get('euId');                  
                 String mjrVersion = ApexPages.currentPage().getParameters().get('mjvr'); 
                 String patchRel = ApexPages.currentPage().getParameters().get('ptch');  
                 
            try {
                     CaseService.caseInstance caseinst = new CaseService.caseInstance(recordTypeId);
                     cs = caseinst.cs;
        
                     cs.ContactId = contId;         
                     cs.End_User_Account__c = euId;
                     cs.Sold_To_Account__c = stId;
                     cs.AccountId = euId;
                     
                     if ( mjrVersion != null && String.isNotBlank(mjrVersion) )
                           cs.Major_Version__c = mjrVersion;
                     
                     if ( patchRel != null && String.isNotBlank(patchRel) )
                          cs.Patch_Release__c = Integer.valueOf(patchRel); 
                     
                     prioropts = caseinst.priorOpts;
                     
                     if ( caseType.contains('_Feature_') ) 
                        cs.Description = Label.CustomerCareFRDescriptionPrompt;
                        
                     if ( caseType.startswith('Genesys_Cloud_') )  
                         initCloudCase();
                     else if ( caseType == 'Genesys_Product_Case' || caseType == 'Genesys_Feature_Request_Case' || 
                               caseType == 'Premises_Service_Request' )
                         initPremCase(); 
              }
              catch (Exception ex) {
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create the Case. Additional details: ' + ex.getMessage() );
                 ApexPages.addMessage(msg);  
              }
        }
        
        private PageReference initCloudCase() {
                platform = ApexPages.currentPage().getParameters().get('plfrm');
                String deplId = ApexPages.currentPage().getParameters().get('dplId');
                String prdsrvId = ApexPages.currentPage().getParameters().get('srvId'); 
                String prodId = ApexPages.currentPage().getParameters().get('prdId'); 
                String pcProblm = ApexPages.currentPage().getParameters().get('prb');
                String cldLocation = ApexPages.currentPage().getParameters().get('lctn');
                
                cs.Cloud_Deployment__c = deplId;
                cs.Cloud_Service__c = prdsrvId;  
                cs.Deployment_Location__c = cldLocation;
                
                if ( platform != null && platform.equals('cnct') ) {
                        cs.Support_Product__c = prodId; 
                        cs.Problem_Category__c = pcProblm;                         
                }
                
                cldDeplName = ApexPages.currentPage().getParameters().get('dplnm'); 
                cldServName = ApexPages.currentPage().getParameters().get('srvnm');     
                return null;
        }
        
        private PageReference initPremCase() { 
                platform = ApexPages.currentPage().getParameters().get('pltf');
                String boaId = ApexPages.currentPage().getParameters().get('boaId');                                                         
                String prodId = ApexPages.currentPage().getParameters().get('prdId'); 
                String compId = ApexPages.currentPage().getParameters().get('compId');         
                String rel = ApexPages.currentPage().getParameters().get('rel');               
                String vers = ApexPages.currentPage().getParameters().get('ver'); 
                String pcProblm = ApexPages.currentPage().getParameters().get('prb');
                
                cs.Back_Office_Account__c = boaId;
                cs.Support_Product__c = prodId;
              
                if ( platform != null && platform.equals('eng') ) {
                        cs.Component__c = compId;
                        cs.Major_Release1__c = rel;
                        cs.Product_Version__c = vers;  
                } 
                else if ( platform != null && platform.equals('cnct') ) {    
                        cs.Problem_Category__c = pcProblm;                       
                }           

           return null;       
      }

     public PageReference saveCase() {  
         try {              
                /*    if ( caseType.contains('_Feature_') )  {
                          cs.Description = cs.Feature_Description__c;
                          cs.Feature_Description__c = null;
                     }
                 */
                 insert cs;
            }
           catch  (Exception ex) {
                   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create the Case. Additional details: ' + ex.getMessage() );
                   ApexPages.addMessage(msg); 
                   return null;
          }
        
          PageReference pr;               
          if ( ContactUtil.isPortalUser() )  {
                        
                        if ( caseType == 'Genesys_Admin_Case' )
                            pr = new PageReference('/customercare/CaseDetailAdminPortal?id=' + cs.id);
                        else if ( caseType == 'Genesys_Cloud_Feature_Request' )
                            pr = new PageReference('/customercare/CaseFRDetailCloudPortal?id=' + cs.id);        
                        else if ( caseType.startswith('Genesys_Cloud_') && caseType != 'Genesys_Cloud_Fearture_Request' )
                            pr = new PageReference('/customercare/CaseDetailCloudPortal?id=' + cs.id);
                        else
                            pr = new PageReference('/customercare/CaseDetail?id=' + cs.id);   
                            
                        pr.setRedirect(true);  
            }
            else 
                pr = new PageReference('/' + cs.id);   
 
            return pr; 
        }
        
   public String pageTitle {
      get {
            return CaseUtil.casePageTitleByType(recordTypeId);
          } 
      set;
   } 
   
}