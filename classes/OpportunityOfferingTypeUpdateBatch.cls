global class OpportunityOfferingTypeUpdateBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext bc){
        ID RenewalOpportunityRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
        String query = 'SELECT Id, Lines_of_Businesses__c, Service_Contract__c, Service_Contract__r.Offering_Type__c '
                     + 'FROM Opportunity WHERE RecordTypeId = :RenewalOpportunityRT AND Service_Contract__c != NULL AND Lines_of_Businesses__c = NULL';
        if(Test.isRunningTest()){
         	query = query + ' LIMIT 100';   
        }
        return Database.getQueryLocator(query);    
    }
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){
        
        Set<String> serviceContractIds = new Set<String>();
        for(Opportunity opp : scope){
        	serviceContractIds.add(opp.Service_Contract__c);
        }
        
        Map<Id, ServiceContract> serviceContractsMap = new Map<Id, ServiceContract>([SELECT id, Name,
                                                                                    (SELECT id, Product2.OfferingType__c FROM ContractLineItems 
                                                                                        WHERE Product2.Type__c = 'Genesys Care') 
                                                                                    FROM ServiceContract WHERE Id IN :serviceContractIds]);
        for(Opportunity opp : scope){
        	if(opp.Service_Contract__r.Offering_Type__c != NULL)
            	opp.Lines_of_Businesses__c = opp.Service_Contract__r.Offering_Type__c;
            else {
                Set<String> productOfferingTypes = new Set<String>();
                for(ContractLineItem cli : serviceContractsMap.get(opp.Service_Contract__c).ContractLineItems){
                        productOfferingTypes.add(cli.Product2.OfferingType__c);
                }
                List<String> productOfferingTypesList = new List<String>();
                productOfferingTypesList.addAll(productOfferingTypes);
                if(productOfferingTypes.size() == 1){
                    if(productOfferingTypesList[0] == 'PureEngage On Premise')
                        opp.Lines_of_Businesses__c = 'PureEngage';
                    else if(productOfferingTypesList[0] == 'PureConnect On Premise')
                        opp.Lines_of_Businesses__c = 'PureConnect'; 
                }
            }
        }   
        
        Util.Bypass_Trigger_Chk = true;
        Database.update(scope);
		Util.Bypass_Trigger_Chk = false;
    }
    
    global void finish(Database.BatchableContext bc){
    }
}