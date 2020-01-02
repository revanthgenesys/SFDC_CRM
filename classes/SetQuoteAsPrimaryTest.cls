@isTest(seeAllData=true)
private class SetQuoteAsPrimaryTest {
    @isTest
    static void testSetQuoteAsPrimary1(){
     	List<BigMachines__Quote__c>  quotes = [SELECT Id, BigMachines__Opportunity__c, Revision_No__c, BigMachines__Is_Primary__c 
                                              FROM BigMachines__Quote__c 
                                              WHERE BigMachines__Status__c = 'Quote In Progress' 
                                               AND Opportunity_Type__c = 'Genesys_Renewal' 
                                               AND Order__c = NULL
                                               AND BigMachines__Is_Primary__c = false LIMIT 2];
        SetQuoteAsPrimary.setQuoteAsPrimary(quotes[0].Id);
   		SetQuoteAsPrimary.setQuoteAsPrimary(quotes[1].Id);     
    }
    
    @isTest
    static void testSetQuoteAsPrimary2(){
     	List<BigMachines__Quote__c>  quotes = [SELECT Id, BigMachines__Opportunity__c, Revision_No__c, BigMachines__Is_Primary__c 
                                              FROM BigMachines__Quote__c 
                                              WHERE BigMachines__Status__c = 'Quote In Progress' 
                                               AND Opportunity_Type__c = 'Genesys_Renewal' 
                                               AND Order__c != NULL
                                               AND BigMachines__Is_Primary__c = false LIMIT 2];
        SetQuoteAsPrimary.setQuoteAsPrimary(quotes[0].Id);
   		SetQuoteAsPrimary.setQuoteAsPrimary(quotes[1].Id);     
    }
}