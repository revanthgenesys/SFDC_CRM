global without sharing class AppFoundryOrderHelper {
	 webservice static String newAppFoundryOrder(String opportunityId){
        System.debug('NKC debug opportunityId ['+opportunityId+']');
        List<OpportunityLineItem> oppLineItems = [SELECT id FROM OpportunityLineItem 
            WHERE PricebookEntry.Product2.Type__c = 'AppFoundry' AND OpportunityId =: opportunityId];
        if(oppLineItems.isEmpty())
            return 'You cannot create an AppFoundry Order on an opportunity with no AppFoundry Usage product on it. Please add an AppFoundry Usage product before proceeding';
        return 'OK';
    }
	
}