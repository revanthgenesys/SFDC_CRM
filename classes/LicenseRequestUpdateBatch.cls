global class LicenseRequestUpdateBatch implements Database.Batchable<sobject> {
  
   global Database.Querylocator start (Database.BatchableContext BC) {
   String query = 'Select id, Type__c From License_Request_Log__c WHERE Type__c = \'\' ';
       
      return Database.getQueryLocator(query);
   }
   
   // Execute method
   global void execute (Database.BatchableContext BC, List<License_Request_Log__c> scope) {
      for(License_Request_Log__c objScope: scope) {
          objScope.type__c = 'Regular';
      }
       update scope;
   }
   
   // Finish Method
    global void finish(Database.BatchableContext BC) {}
}