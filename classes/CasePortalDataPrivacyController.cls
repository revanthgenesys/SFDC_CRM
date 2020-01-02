public class CasePortalDataPrivacyController {
        
        public Case cs {get; set;}
        public String comments {get; set;}
        public String caseType {get; set;}
        public String reqDetail {get; set;}     
    private String recordTypeId;
    private String offering;
    private String cldServiceId;
        
        public CasePortalDataPrivacyController(ApexPages.StandardController stdController) {
                recordTypeId = ApexPages.currentPage().getParameters().get('RecordType'); 
                
                if ( String.isNotBlank(recordTypeId) )
             caseType = CaseUtil.getAllTScaseTypesMap().get(recordTypeId).DeveloperName;
                 
          String contId = ApexPages.currentPage().getParameters().get('contId'); 
          String stId = ApexPages.currentPage().getParameters().get('stId');
          String euId = ApexPages.currentPage().getParameters().get('euId');
          cldServiceId = ApexPages.currentPage().getParameters().get('srvId');
          offering = ApexPages.currentPage().getParameters().get('fltr'); 
          
          try {
                     CaseService.caseInstance caseinst = new CaseService.caseInstance(recordTypeId);
                     cs = caseinst.cs;
        
                     cs.ContactId = contId;         
                     cs.End_User_Account__c = euId;
                     cs.Sold_To_Account__c = stId;
                     cs.AccountId = euId;
                     cs.Business_Impact_Product__c= 'N/A';
                     
                   //  cs.Product_Support_Group__c = 'Data Privacy';
                     cs.Problem_Sub_Type__c = 'Data Privacy';

                    if ( caseType == 'Genesys_Cloud_Service_Request' )  
                         initCloudCase();
                     else if ( caseType == 'Premises_Service_Request')
                         initPremCase();  
   
              }
              catch (Exception ex) {
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create a Case. Additional details: ' + ex.getMessage() );
                 ApexPages.addMessage(msg);  
              }            
    }
    
    public PageReference initCloudCase() {
          String deplId = ApexPages.currentPage().getParameters().get('dplId');
          cs.Cloud_Deployment__c = deplId;
                                          
           /// Support Product           
           if ( offering != null && offering == 'cnct') {               
                   /// Cloud Service
               List<Support_Product__c> cldsrv = [SELECT Id FROM Support_Product__c WHERE Product_Name__c = 'PureConnect Cloud' AND Product_Type__c = 'Cloud Service'];
               if ( !cldsrv.isEmpty() )
                    cs.Cloud_Service__c = cldsrv[0].Id;
                  
                List<Support_Product__c> cldprd = [SELECT Id FROM Support_Product__c WHERE Product_Name__c = 'Data Privacy' 
                                            AND Product_Type__c = 'Product' AND Category__c = 'PureConnect Products'];                                            
               if ( !cldprd.isEmpty() )
                        cs.Support_Product__c = cldprd[0].Id;
           }           
           else if ( cldServiceId != null )
              cs.Cloud_Service__c = cldServiceId;
                        
           return null;
     }
        
     public PageReference initPremCase() { 
   
          String boaId = ApexPages.currentPage().getParameters().get('boaId');                                                           
          cs.Back_Office_Account__c = boaId;
          
          List<Support_Product__c> premprd = new List<Support_Product__c>();
           if ( offering != null && offering == 'cnct') {          
                 premprd = [SELECT Id FROM Support_Product__c WHERE Product_Name__c = 'Data Privacy' 
                                 AND Product_Type__c = 'Product' AND Category__c = 'PureConnect Products'];
           }
           else if ( offering != null && offering == 'eng' )  {
                      premprd = [SELECT Id FROM Support_Product__c WHERE Product_Name__c = 'Management Framework' 
                                AND Product_Type__c = 'Product'];               
           }
           
           if ( !premprd.isEmpty() )
               cs.Support_Product__c = premprd[0].Id;
          
          cs.Major_Release1__c = 'Unknown';
          
          
           return null;       
      }
      
    public PageReference saveCase() {  
         try { 
                     
                 cs.Subject = 'Data Privacy Request: ' + reqDetail;
                 cs.MAC_Type_PureCnct__c = reqDetail;
                 cs.Description = 'Data Privacy Request: ' + reqDetail + '\n\n' +
                                                           + comments;
                 insert cs;
            }
           catch  (Exception ex) {
                   ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create a Case. Additional details: ' + ex.getMessage() );
                   ApexPages.addMessage(msg); 
                   return null;
          }
        
          PageReference pr;               
  
           if ( caseType.startswith('Genesys_Cloud_') )
                  pr = new PageReference('/customercare/CaseDetailCloudPortal?id=' + cs.id);
            else
                  pr = new PageReference('/customercare/CaseDetail?id=' + cs.id);   
                            
            return pr; 
     } 
}