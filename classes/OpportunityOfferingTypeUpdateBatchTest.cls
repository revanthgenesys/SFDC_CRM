@isTest(seeAllData=true)
private class OpportunityOfferingTypeUpdateBatchTest {
    @isTest
    static void testOpportunityOfferingTypeUpdateBatch(){
        List<ContractLineItem> lineItems1 = [SELECT id, ServiceContractId, ServiceContract.Renewal_Opportunity__c, Product2.OfferingType__c 
									FROM ContractLineItem 
									WHERE Product2.Type__c = 'Genesys Care' 
                                    AND ServiceContract.Offering_Type__c != NULL        
                                    AND ServiceContract.Renewal_Opportunity__r.RecordType.Name = 'Genesys Renewal'
                                    LIMIT 5];
        List<ContractLineItem> lineItems2 = [SELECT id, ServiceContractId, ServiceContract.Renewal_Opportunity__c, Product2.OfferingType__c 
									FROM ContractLineItem 
									WHERE Product2.Type__c = 'Genesys Care' 
                                    AND ServiceContract.Offering_Type__c = NULL
                                    AND ServiceContract.Renewal_Opportunity__r.RecordType.Name = 'Genesys Renewal'
                                    LIMIT 5];
        Util.Bypass_Trigger_Chk = true;
        List<Opportunity> opportunities = new List<Opportunity>();
        Set<String> opportunityIds = new Set<String>();
        for(ContractLineItem cli : lineItems1){
            if(!opportunityIds.contains(cli.ServiceContract.Renewal_Opportunity__c)){
                opportunities.add(new Opportunity(id=cli.ServiceContract.Renewal_Opportunity__c, Lines_of_Businesses__c = ''));
                opportunityIds.add(cli.ServiceContract.Renewal_Opportunity__c);
            }
        }
        for(ContractLineItem cli : lineItems2){
            if(!opportunityIds.contains(cli.ServiceContract.Renewal_Opportunity__c)){
                opportunities.add(new Opportunity(id=cli.ServiceContract.Renewal_Opportunity__c, Lines_of_Businesses__c = ''));
                opportunityIds.add(cli.ServiceContract.Renewal_Opportunity__c);
            }
        }	
        Database.update(opportunities);
        Database.executeBatch(new OpportunityOfferingTypeUpdateBatch(), 100);
        Util.Bypass_Trigger_Chk = false;
        
    }
}