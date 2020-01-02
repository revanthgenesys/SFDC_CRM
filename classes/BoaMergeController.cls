public class BoaMergeController {
            
       public Id boaIdTo {get; set;}
       public Id boaIdFrom {get; set;}
       public String searchBoaFromName {get; set;}
       public List<Support_Access__c> supAccLstFrom {get; set;}
       private transient List<Support_Access__c> supAccLstTo;
       private Set<Id> contIDsTo;
       private Integer BATCH_LIMIT = 80;
       
       public BoaMergeController (ApexPages.StandardController stdController) {
            boaIdTo = stdController.getId();           
       }
       
       public void getSupportAccessList() {
           if ( searchBoaFromName == null ) {
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Please enter the Back Office Account Name FROM which you want to move Support Access records.'));
               return;
           }
           supAccLstFrom = [SELECT Id, Name, Contact__c, Contact__r.Name, Back_Office_Account__c, Back_Office_Account__r.Name, 
                                   Status__c, SR_Access_Level__c, Status_Comment__c, BOA_Platform__c 
                            FROM Support_Access__c 
                            WHERE Back_Office_Account__r.Name = :searchBoaFromName];
                          
           if ( supAccLstFrom.isEmpty() ) {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'No Support Access records found associtated with the BOA name ' + searchBoaFromName));
             return;
           }
           else {
              boaIdFrom = supAccLstFrom[0].Back_Office_Account__c;  
           }             
       }
       
       public void mergeBoa() {

          getBoaTo();
          if ( supAccLstFrom == null || supAccLstFrom.isEmpty() )  {
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Please enter the Back Office Account Name FROM which you want to Move Support Access records.'));
               return;
          }
          
          List<Support_Access__c> saUpdLst = new List<Support_Access__c>();
          List<Support_Access__c> saDeleteDuplLst = new List<Support_Access__c>();
          
                  
          Integer size = supAccLstFrom.size();         
          Integer merged=0, deleted=0;
          for (Support_Access__c saFrom : supAccLstFrom) {          
               if ( !contIDsTo.isEmpty() && contIDsTo.contains(saFrom.Contact__c) ) {   
                       saDeleteDuplLst.add(saFrom);
                       deleted++;
               }
               else {                                              
                   String comm = 'Merged from ' + searchBoaFromName;  
                   if ( ! String.isBlank(saFrom.Status_Comment__c) )  {
                       comm =  saFrom.Status_Comment__c + '; ' + comm;
                       comm = comm.length() > 255 ? comm.substring(0, 250) : comm;
                   }
                   
                   saFrom.Back_Office_Account__c = boaIdTo;                  
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
       
       public void cloneBoa() {
        
          getBoaTo();
          if ( supAccLstFrom == null || supAccLstFrom.isEmpty() )  {
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, 'Please enter the Back Office Account Name FROM which you want to Clone Support Access records.'));
               return;
          }
          
          List<Support_Access__c> saInsLst = new List<Support_Access__c>(); 
          
          Integer alreadyExist = 0;                    
          Integer size = supAccLstFrom.size();         
          Integer cloned=0;         
          for (Support_Access__c saFrom : supAccLstFrom) {  
                       
               if ( !contIDsTo.isEmpty() && contIDsTo.contains(saFrom.Contact__c) ) { 
                       alreadyExist++;  
                       continue;
               }
               else { 
                  
                   String comm = 'Cloned from ' + searchBoaFromName;  
                   if ( ! String.isBlank(saFrom.Status_Comment__c) )  {
                       comm =  saFrom.Status_Comment__c + '; ' + comm;
                       comm = comm.length() > 255 ? comm.substring(0, 250) : comm;
                   }
                                          
                   Support_Access__c newSA = new Support_Access__c(Contact__c = saFrom.Contact__c,
                                                                   Back_Office_Account__c = boaIdTo,
                                                                   SR_Access_Level__c = saFrom.SR_Access_Level__c,
                                                                   Status__c = saFrom.Status__c,
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
       
       public void getBoaTo() {                   
          supAccLstTo = [SELECT Contact__c FROM Support_Access__c WHERE Back_Office_Account__c = :boaIdTo];         
          contIDsTo = new Set<Id>();
          if ( !supAccLstTo.isEmpty() ) {
             for (Support_Access__c saTo : supAccLstTo )         
                contIDsTo.add(saTo.Contact__c);             
          }         
       }

}