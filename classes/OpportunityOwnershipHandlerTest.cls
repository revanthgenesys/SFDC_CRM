//Naresh Kumar	09/14/2017
@isTest(seeAllData=true)
private class OpportunityOwnershipHandlerTest {	
    
    static testMethod void updateOpportunityOwner(){        
        Account testAccount = TestUtil.createAccounts(1, true)[0];        
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.RecordTypeId = Global_Setting__c.getInstance('GEN - Opportunity Record Type').ID__c;
        testOpp.Partner_Opportunity_Source__c = 'Partner Registered Opportunity';
        insert testOpp;
        testOpp.Partner_Opportunity_Source__c = 'Partner Sourced not registered';
        update testOpp;        
        Opportunity testOpp1 = TestUtil.createOpportunities(1, true)[0];        
    }    
}