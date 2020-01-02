/*
 * Class            : PartnerPortalCustomSharingBatch
 * Description      : A Batch class to add Designated contacts to Opportunity Teams and share Opportunity Related Objects.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerPortalCustomSharingBatch implements Database.Batchable<SObject>{
    
    global List<String> contactIds {get; set;}
    
    global PartnerPortalCustomSharingBatch(List<String> contactsToProcess){
    	contactIds = contactsToProcess;	
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
		Set<String> accountIds = new Set<String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId IN :contactIds]){
			accountIds.add(u.Contact.AccountId);
		} 
    	
        String query = 'SELECT Id, Name, AccountId, BusinessPartner__c, CreatedBy.Contact.AccountId, OwnerId FROM Opportunity '
            		 + 'WHERE BusinessPartner__c != NULL AND BusinessPartner__c IN :accountIds AND Account.Name NOT IN (\'ABC Test Co - KK\',\'ABC Test DL\',\'ABC Testing 123\',\'ABC Testing Co\',\'ABC Testing Co. (Merged, Do Not Use)\' ) '
            		 + 'AND (RecordType.Name = \'GEN - Opportunity Record Type\' OR RecordType.Name = \'Partner Opportunity\') ';
        if(Test.isRunningTest()){
         	query = query + ' LIMIT 5';   
        }
        return Database.getQueryLocator(query);
        /*
        return Database.getQueryLocator([SELECT Id, Name, AccountId, BusinessPartner__c, CreatedBy.Contact.AccountId, OwnerId 
                                         FROM Opportunity 
                                         WHERE BusinessPartner__c != NULL AND BusinessPartner__c IN :accountIds AND RecordType.Name != 'Genesys Renewal'
                                        ]);
		*/
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
    	PartnerPortalCustomSharing.manageOpportunityTeamAndShareRelatedObjects(contactIds, scope);
    }
    
    global void finish(Database.BatchableContext BC){
        // Sharing completed for given contacts ...
    }
}