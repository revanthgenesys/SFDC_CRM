/*
    BatchToVerifyBackOfficeAccountFields batch = new BatchToVerifyBackOfficeAccountFields();
    Database.executeBatch(batch, 100);
    
    bypass triggers, bypass workflows
    HAS to run as batch.admin,  "New System, Migrated to"
*/

global class BatchToVerifyBackOfficeAccountFields implements Database.Batchable<SObject>, Database.Stateful {
    
    global Database.Querylocator start(Database.BatchableContext ctx) { 
             
         return Database.getQueryLocator([SELECT Id, End_User_Name__c, Sold_To_Name__c, Platform__c,
                                                 Contract_Status__c, Service_Type__c,
                                                 End_User_Account__c, Sold_To_Account__c,
                                                 Unique_STEU__c 
                                          FROM Back_Office_Account__c WHERE Service_Type__c != 'Cloud']);                                                                                
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
        
       List<Back_Office_Account__c> boaList = (List<Back_Office_Account__c>)scope;       
       List<Back_Office_Account__c> updList = new List<Back_Office_Account__c>();
       
       for ( Back_Office_Account__c boa : boaList )  {
           
           Boolean needUpd = false;
           Back_Office_Account__c servContrBoa = BackOfficeAccountService.getBoaContractFieldsBySTEU(boa.Sold_To_Account__c, boa.End_User_Account__c, boa.Platform__c);
           
           //Contract not found
           if ( servContrBoa == null && boa.Contract_Status__c != 'Terminated' ) {
         
                  boa.Contract_Status__c = 'Terminated';
                  updList.add(boa); 
           }
           else if (servContrBoa != null ) {
     
               if ( servContrBoa.Contract_Status__c != boa.Contract_Status__c ) {                      
                       boa.Contract_Status__c = servContrBoa.Contract_Status__c;
                       needUpd = true;
               }
               
               if ( String.isBlank(boa.Unique_STEU__c) || boa.Unique_STEU__c != servContrBoa.Unique_STEU__c ) {
                      boa.Unique_STEU__c = servContrBoa.Unique_STEU__c;
                      needUpd = true;
               }
               
               if ( String.isBlank(boa.End_User_Name__c) || boa.End_User_Name__c != servContrBoa.End_User_Name__c ) {
                     boa.End_User_Name__c = servContrBoa.End_User_Name__c;
                     needUpd = true;
               }  
                    
               if ( String.isBlank(boa.Sold_To_Account__c) || boa.Sold_To_Name__c != servContrBoa.Sold_To_Name__c )  {
                     boa.Sold_To_Name__c = servContrBoa.Sold_To_Name__c;
                     needUpd = true;
               }          
           
               if (needUpd)
                 updList.add(boa); 
           }
       }
       
       if ( !updList.isEmpty() )
          update updList;
    }
    
    global void finish(Database.BatchableContext ctx) {
        
             AsyncApexJob a = [SELECT id, ApexClassId,
                                JobItemsProcessed, TotalJobItems,
                                NumberOfErrors, ExtendedStatus
                                FROM AsyncApexJob
                                WHERE id = :ctx.getJobId()];
            
            if ( a.NumberOfErrors > 0 || System.Test.isRunningTest() )  {
                
                String emailMessage = 'Errors executing job BatchToVerifyBackOfficeAccountFields. \n\n'
                 + 'It executed ' + a.totalJobItems  + ' batches. \n'
                 + 'Of which, ' + a.JobItemsProcessed + ' processed without any exceptions thrown. \n'
                 + a.numberOfErrors + ' batches threw unhandled exceptions. \n\n'
                 + 'Status Details: \n' + a.ExtendedStatus;
                
                Messaging.SingleEmailMessage mail =
                      new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {Label.Notify_On_Errors_Customer_Care};
                mail.setToAddresses(toAddresses);
                mail.setSubject('Errors executing job BatchToVerifyBackOfficeAccountFields');
                mail.setPlainTextBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                                   { mail });
            }
    }

}