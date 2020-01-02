/*
   BatchUpdateSupportAccessSetBackOffAcct batch = new BatchUpdateSupportAccessSetBackOffAcct();
	 Database.executeBatch(batch);
	 
	 need to run about 8 times
*/
global class BatchUpdateSupportAccessSetBackOffAcct implements Database.Batchable<SObject>, Database.Stateful {
	
	global static Map<String, Back_Office_Account__c> boaMap = new Map<String, Back_Office_Account__c>();
	
	global Database.Querylocator start(Database.BatchableContext ctx) {		 
		 return Database.getQueryLocator([SELECT Id, Sold_To_Account__c, End_User_Account__c, Contact__c 
		                                 FROM Support_Access__c 
		                                 WHERE Back_Office_Account__c = null]);	
		                                                      		 		 
	}
	
	global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	List<Support_Access__c> suppAccessLst = (List<Support_Access__c>)scope;
    	
    	if (boaMap.size() == 0) {   
    		///this is to split query to avoid limits		
    		List<Back_Office_Account__c> activeBoa = [SELECT Id, Unique_STEU__c FROM Back_Office_Account__c WHERE Contract_Status__c = 'Active'];
            List<Back_Office_Account__c> notActiveBoa = [SELECT Id, Unique_STEU__c FROM Back_Office_Account__c WHERE Contract_Status__c != 'Active'];
			for (Back_Office_Account__c boa : activeBoa) {
			    boaMap.put(boa.Unique_STEU__c, boa);
			}
			for (Back_Office_Account__c boa : notActiveBoa) {
			    boaMap.put(boa.Unique_STEU__c, boa);
			}    		
    	}
    	
    	List<Support_Access__c> updSaList = new List<Support_Access__c>();
    	
    	for (Support_Access__c sa : suppAccessLst) {
    		Back_Office_Account__c ba = boaMap.get(sa.Sold_To_Account__c + '_' + sa.End_User_Account__c);
			if ( ba != null) {
				sa.Back_Office_Account__c = ba.Id;
				sa.Unique_Boa_Contact_Combination__c = (Id) ba.Id + '_' + (Id) sa.Contact__c;
				updSaList.add(sa);
			}
	
    	}
    	
    	if (updSaList.size() > 0)
    	   update updSaList;
  
	}
	
	 global void finish(Database.BatchableContext ctx){
	 	
	 }
}