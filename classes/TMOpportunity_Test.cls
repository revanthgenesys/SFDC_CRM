/**
 */
@isTest(SeeAllData=true)
private class TMOpportunity_Test {

    static testMethod void assignNewTerritory_1() {
    test.startTest();
    Opportunity testOpp_1 = TestUtil.createOpportunities(1, true)[0];
    Opportunity testOpp_2 = TestUtil.createOpportunities(1, true)[0];
    
    List<Opportunity> oppList = new List<Opportunity>();
    oppList.add(testOpp_1);
    oppList.add(testOpp_2);
    
    TM01Opportunity.assignNewTerritory(oppList);
    TM01Opportunity.hasAlreadyUpdatedOpp();
    TM01Opportunity.setAlreadyAlreadyUpdatedOpp();
        	
    }
}