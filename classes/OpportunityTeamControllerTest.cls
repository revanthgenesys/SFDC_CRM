/*
Created By: R Systems
Created Date: 17-July-2017
Function: Test Classes for Controller class OpportunityTeammemberController 
*/
@isTest(SeeAllData = true)
private class OpportunityTeamControllerTest
{
    static testmethod void testDealSupport()
    {
        try
        {
            Test.startTest();
            
            // Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            Account objTestAccount;
            Opportunity objTestOppty;
            List<User> runAsUser = TestUtil.createUsers(1, false);
            System.runAs(runAsUser[0]) 
            {
                objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
                objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id;
                insert objTestAccount;
                
                objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
                objTestOppty.CloseDate = Date.today().addMonths(1);
                objTestOppty.StageName = '1.Recognize Needs';
                insert objTestOppty;
            }
            
             apexPages.StandardController sc = new ApexPages.StandardController(objTestOppty);
             OpportunityTeammemberController  teamRole = new OpportunityTeammemberController (sc);
              Test.stopTest();
       }
       catch(CalloutException e){
       
       }
    }
}