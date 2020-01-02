/*
    04/29/2013  Naresh Kumar
    Test Class to test main class PrimaryQuoteController
*/
@isTest (seeAllData = true)
public with sharing class PrimaryQuoteController_Test {
    static testMethod void myTestMethod() {        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, false)[0];
        testOrder.License_FYM_detail__c = 'Maintenance Only Order';
        insert testOrder;
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        PrimaryQuoteController objController = new PrimaryQuoteController(stdController);
    }
}