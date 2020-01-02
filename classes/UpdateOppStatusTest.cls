@IsTest(SeeAllData=true)
public class UpdateOppStatusTest {
    static testmethod void testMethod4(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        Test.startTest();
        UpdateOppStatus UpdateObj = new UpdateOppStatus();
        UpdateOppStatus.UpdateOppStatus(list_NewOpps[0],'Order Accepted');
        UpdateOppStatus.UpdateOppStatus(list_NewOpps[0],'Quote In Progress');
        UpdateOppStatus.UpdateOppStatus(list_NewOpps[0],'Quote Approved');
        UpdateOppStatus.updateoppStatusFromQuote(list_NewQuotes[0].id);
        Test.stopTest();
    }

}