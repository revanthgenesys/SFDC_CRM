global class DeletehistoryAsyncBatch implements Database.Batchable<sObject>{
        public static integer x=Integer.valueOf(System.Label.Deletehistoryobjectdelduration);      
        global DeletehistoryAsyncBatch(){                   
        }      
        global Database.QueryLocator start(Database.BatchableContext BC){
            Date s = system.today()-x;
            string query = 'select id from Delete_History_Object__c  where CreatedDate <:S';
            return Database.getQueryLocator(query);
        }
     
       global void execute(Database.BatchableContext BC, List<Delete_History_Object__c> scope){
              if(scope.size()>0)
                  delete scope;     
       }
            global void finish(Database.BatchableContext BC){
            
       }
    }