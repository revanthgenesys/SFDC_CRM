public class CloudDeplSAMergeController {
        
       public Id deplIdTo {get; set;}
       public Id deplIdFrom {get; set;}
       public String searchDeplFromName {get; set;}
       public List<Support_Access_Cloud__c> supAccLstFrom {get; set;}
       private transient List<Support_Access_Cloud__c> supAccLstTo;
       private Set<Id> contIDsTo;
       private Integer BATCH_LIMIT = 95;
       
       public CloudDeplSAMergeController (ApexPages.StandardController stdController) {
            deplIdTo = stdController.getId();           
       }
       
       public void getSupportAccessList() {
           if ( searchDeplFromName == null ) {
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Please enter the Cloud Deployment Name FROM which you want to move Support Access records.'));
               return;
           }
           supAccLstFrom = [SELECT Id, Name, Contact__c, Contact__r.Name, Cloud_Deployment__c, Cloud_Deployment__r.Name, 
                                   Access_Status__c, Access_Level__c, Status_Comment__c 
                            FROM Support_Access_Cloud__c 
                            WHERE Cloud_Deployment__r.Name = :searchDeplFromName];
                          
           if ( supAccLstFrom.isEmpty() ) {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'No Support Access records found associtated with the Cloud Deplyment name ' + searchDeplFromName));
             return;
           }
           else {
              deplIdFrom = supAccLstFrom[0].Cloud_Deployment__c;  
           }             
       }
       
       public void mergeDeployments() {

          getDelpTo();
          if ( supAccLstFrom == null || supAccLstFrom.isEmpty() )  {
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Please enter the Cloud Deployment Name FROM which you want to Move Support Access records.'));
               return;
          }
          
          List<Support_Access_Cloud__c> saUpdLst = new List<Support_Access_Cloud__c>();
          List<Support_Access_Cloud__c> saDeleteDuplLst = new List<Support_Access_Cloud__c>();
          
                  
          Integer size = supAccLstFrom.size();         
          Integer merged=0, deleted=0;
          for (Support_Access_Cloud__c saFrom : supAccLstFrom) {          
               if ( !contIDsTo.isEmpty() && contIDsTo.contains(saFrom.Contact__c) ) {   
                       saDeleteDuplLst.add(saFrom);
                       deleted++;
               }
               else {                                              
                   String comm = 'Merged from ' + searchDeplFromName;  
                   if ( ! String.isBlank(saFrom.Status_Comment__c) )  {
                       comm =  saFrom.Status_Comment__c + '; ' + comm;
                       comm = comm.length() > 255 ? comm.substring(0, 250) : comm;
                   }
                   
                   saFrom.Cloud_Deployment__c = deplIdTo;                  
                   saFrom.Status_Comment__c = comm;
                   
                   saUpdLst.add(saFrom); 
                   merged++;
               }  
               
               if ( merged == BATCH_LIMIT ) 
                   break;         
           }
           
           if ( !saUpdLst.isEmpty() )  {
               try {
                   update saUpdLst;
               }
               catch (DMLException e) {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,  e.getMessage()));
                    return;
               }               
           }
           
           if ( !saDeleteDuplLst.isEmpty() )  {          
               try {
                  delete saDeleteDuplLst;
               }
               catch (DMLException e) {
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,  e.getMessage()));
                    return;
               }               
           }          
           
           String msg = merged + ' Support Access records have been merged.';
           if ( merged < size - deleted)
              msg += '\n' + ' Not all records out of ' + size + ' have been merged. To complete operation please Retrieve Support Accesses first and then click Merge button again.';
           
           
           ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, msg));
           supAccLstFrom.clear();
           return;
       }
       
       public void cloneDeployment() {
        
          getDelpTo();
          if ( supAccLstFrom == null || supAccLstFrom.isEmpty() )  {
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Please enter the Cloud Deployment Name FROM which you want to Clone Support Access records.'));
               return;
          }
          
          List<Support_Access_Cloud__c> saInsLst = new List<Support_Access_Cloud__c>(); 
          
          Integer alreadyExist = 0;                    
          Integer size = supAccLstFrom.size();         
          Integer cloned=0;         
          for (Support_Access_Cloud__c saFrom : supAccLstFrom) {  
                       
               if ( !contIDsTo.isEmpty() && contIDsTo.contains(saFrom.Contact__c) ) { 
                       alreadyExist++;  
                       continue;
               }
               else { 
                  
                   String comm = 'Cloned from ' + searchDeplFromName;  
                   if ( ! String.isBlank(saFrom.Status_Comment__c) )  {
                       comm =  saFrom.Status_Comment__c + '; ' + comm;
                       comm = comm.length() > 255 ? comm.substring(0, 250) : comm;
                   }
                                          
                   Support_Access_Cloud__c newSA = new Support_Access_Cloud__c(Contact__c = saFrom.Contact__c,
                                                                   Cloud_Deployment__c = deplIdTo,
                                                                   Access_Level__c = saFrom.Access_Level__c,
                                                                   Access_Status__c = saFrom.Access_Status__c,
                                                                   Status_Comment__c = comm);
                   saInsLst.add(newSA); 
                   cloned++;
               }           
                      
               if ( cloned == BATCH_LIMIT ) 
                   break;
           }  
           
           if ( !saInsLst.isEmpty() ) {                    
                   try {
                       insert saInsLst;
                   }
                   catch (DMLException e) {
                        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error,  e.getMessage()));
                        return;
                   }      
          }
          
           String msg = cloned + ' Support Access records have been Cloned.';
           if ( alreadyExist > 0 )
               msg += '\n' + alreadyExist + ' already existing Support Access records found.';
           if ( cloned < size - alreadyExist )
              msg += '\n' + ' Not all records out of ' + size + ' have been cloned. To complete operation please Retrieve Support Accesses first and then click Clone button again.';
           
           ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, msg));
           supAccLstFrom.clear();
           return;
       }
       
       public void getDelpTo() {                   
          supAccLstTo = [SELECT Contact__c FROM Support_Access_Cloud__c WHERE Cloud_Deployment__c = :deplIdTo];         
          contIDsTo = new Set<Id>();
          if ( !supAccLstTo.isEmpty() ) {
             for (Support_Access_Cloud__c saTo : supAccLstTo )         
                contIDsTo.add(saTo.Contact__c);             
          }         
       }
}