/************************************************************************************
Purpose :  Test class for the class OpportunityPriceChangeNotificationHelper.
Written By :  Naresh
*************************************************************************************/
@isTest(seeAllData=true)
private class OpportunityPriceChangeNotiHelperTest {
    
    static testMethod void test1(){
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        
        Country__c testCountry = [SELECT id FROM Country__c WHERE Name = 'United States'];
        
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.RecordTypeId = '012U0000000LrBP';
        testOpp.Sold_To_Country__c = testCountry.id;
        testOpp.StageName = '6.Closed';
        testOpp.License_Amount__c = 0;
        //testOpp.Booking__c = 0;
        testOpp.ACV_Subscription_Only__c = 0;
        testOpp.Total_Annual_Contract_Value__c = 0;
        testOpp.Total_PS_Support__c = 0;
        testOpp.Monthly_Commitment__c = 0;
        testOpp.Estimated_Usage_Agreements_EUA__c = 0;
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.CloseDate = System.today().addDays(10);
        insert testOpp;
        
        testOpp.License_Amount__c = 100;
        //testOpp.Booking__c = 100;
        testOpp.ACV_Subscription_Only__c = 100;
        testOpp.Total_Annual_Contract_Value__c = 100;
        testOpp.Total_PS_Support__c = 100;
        testOpp.Monthly_Commitment__c = 100;
        testOpp.Estimated_Usage_Agreements_EUA__c = 100;
        testOpp.Lines_of_Businesses__c = 'PureConnect';
        testOpp.CloseDate = System.today().addDays(5);
        update testOpp;        
    }	
}