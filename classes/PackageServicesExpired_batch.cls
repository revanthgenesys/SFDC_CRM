global class PackageServicesExpired_batch implements Database.Batchable<sObject>, Schedulable {
    
    global  Database.QueryLocator start (Database.BatchableContext sc){ 
        String query = 'SELECT Id FROM Package_Services__c where End_Date__c < today AND Status__c != \'Expired\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext sc, List<Package_Services__c> ScopPackageServices){

        for(Package_Services__c ps: ScopPackageServices){
            ps.Status__c = 'Expired';
        }
        update ScopPackageServices;
    } 

    global void finish(Database.batchableContext sc){ 
    } 
    
    global void execute(SchedulableContext sc) {
      PackageServicesExpired_batch b = new PackageServicesExpired_batch(); 
      database.executebatch(b);
   }
}