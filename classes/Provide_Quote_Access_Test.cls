/*
    05/05/2013  Naresh Kumar
    Test class for the trigger Provide_Quote_Access 
*/
@isTest (seeAllData = true)
private class Provide_Quote_Access_Test {
    
    static testMethod void myUnitTest() {
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        User testUser = TestCommon.createUser('tstAlias', null, 'Test Last Name', 'Test First Name', null);
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        OpportunityShare testOppShare = new OpportunityShare();
        testOppShare.OpportunityAccessLevel = 'Read';
        testOppShare.UserOrGroupId = testUser.id;
        //testOppShare.RowCause = 'Owner';
        testOppShare.OpportunityId = testOpp.id;
        insert testOppShare;
        OpportunityTeamMember testOppTM = new OpportunityTeamMember();        
        testOppTM.OpportunityId = testOpp.id;
        testOppTM.UserId = testUser.id;
        insert testOppTM; 
        testOppShare.OpportunityAccessLevel = 'Edit';
        update testOppShare;
        update testOppTM;
        BigMachines__Quote__c testQuote1 = TestUtil.createQuotes(1, testOpp.id, true)[0];
        delete testOppTM;
    }
}