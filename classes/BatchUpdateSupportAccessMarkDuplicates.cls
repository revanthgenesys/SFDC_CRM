/*	
	BatchUpdateSupportAccessMarkDuplicates batch = new BatchUpdateSupportAccessMarkDuplicates();
	Database.executeBatch(batch);
	
	HAS to run as batch.admin, 	"New System, Migrated to"
	
	need to run 2 times
	First take care of Pending status records
	Select Status__c, count(name) from Support_Access__c group by Status__c
	
*/

global class BatchUpdateSupportAccessMarkDuplicates implements Database.Batchable<SObject>, Database.Stateful {

    global static Map<String, Support_Access__c> toKeep = new Map<String, Support_Access__c>();
    global static List<Support_Access__c> dupl = new List<Support_Access__c>();
	
	global Database.Querylocator start(Database.BatchableContext ctx) {		 
		 return Database.getQueryLocator([SELECT Contact__c, Sold_To_Account__c, End_User_Account__c, Status__c 
		                                 FROM Support_Access__c WHERE Duplicate_BOA__c = null 
		                                 Order BY Contact__c, Sold_To_Account__c, End_User_Account__c]);			                                                      		 		 
	}
	
	global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
       List<Support_Access__c> suppAccessLst = (List<Support_Access__c>)scope;
       
       for (Support_Access__c sa : suppAccessLst) {
           String key = sa.Contact__c + '_' + sa.Sold_To_Account__c + '_' + sa.End_User_Account__c;          
           Support_Access__c replSa = (Support_Access__c)toKeep.get(key);
  
           if ( replSa == null ) {
               toKeep.put(key, sa);
           }
           else {

           	   if ( sa.Status__c == 'Active' || replSa.Status__c == null ) {
           	   	   replSa.Duplicate_BOA__c = 'Yes';
           	   	   dupl.add(replSa);
           	   	   toKeep.put(key, sa);           	   	   
           	   }
           	   else {      	   	
	               sa.Duplicate_BOA__c = 'Yes'; 
	               dupl.add(sa);
           	   }
           }    
       }
        
       update dupl;
    }
    
    global void finish(Database.BatchableContext ctx){}
}