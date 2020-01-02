//Nik Mills - 16-Nov-2018
//For code coverage and testing of the AssociatedOpportunityApprovalHelper class, used in association with the OpportunityApproval creation from a Process Builder flow
@IsTest(SeeAllData=true)
public class AssociatedOpportunityApprovalHelper_Test {
    static Opportunity testOpp;
    static Opportunity testParentOpp;
    static Opportunity_Approval__c testOpptyApproval;
        
    // test PS AssociatedOpportunityApprovalHelper creation for test Opp
    static testMethod void Test1_TestAssciatedOpportunityApprovalHelper() {
        createPSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<Opportunity_Approval__c> AllOppApprovals = new List<Opportunity_Approval__c>();
        List<ID> oppIDs = new List<ID>();
        AllOpps.add(testOpp);
        oppIDs.add(testOpp.Id);

        Test.startTest();

        // Test the submission of the opportunity, simulating this from the PSA tool (external)
        testOpp.PSA_Closed_OM_Oppty_Submit_Status__c = 'Submitted';
        update testOpp;
        AssociatedOpportunityApprovalHelper.SetOpportunityApproval(oppIDs);

        // Now test the resubmission
        testOpp.PSA_Closed_OM_Oppty_Submit_Status__c = 'Resubmitted';
        update testOpp;
        AssociatedOpportunityApprovalHelper.SetOpportunityApproval(oppIDs);
        
        // Now test the cancellation
        testOpp.PSA_Closed_OM_Oppty_Submit_Status__c = 'Cancelled';
        update testOpp;
        AssociatedOpportunityApprovalHelper.SetOpportunityApproval(oppIDs);

        Test.stopTest();
    }
    
    // Create a PS Specific standalone test opportunity
    static void createPSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.PS_Region__c = 'North America';
        testOpp.Direct_Sales__c = true;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

}