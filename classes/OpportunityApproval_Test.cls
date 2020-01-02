//Nik Mills - 10-Nov-2018
//For code coverage and testing of the OpportunityApproval class, used in association with the OpportunityApproval triggers (OpportunityApprovalMain)
@IsTest(SeeAllData=true)
public class OpportunityApproval_Test {
    static Opportunity testOpp;
    static Opportunity testParentOpp;
    static Opportunity_Approval__c testOpptyApproval;
        
    // test PS OpportunityApproval creation and triggers
    static testMethod void Test1_TestOpportunityApprovalCreate() {
        createPSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<Opportunity_Approval__c> AllOppApprovals = new List<Opportunity_Approval__c>();
        AllOpps.add(testOpp);

        Test.startTest();         
        createOpptyApprovalTestData();
        AllOppApprovals.add(testOpptyApproval);

        System.AssertEquals(testOpptyApproval.Finance_Approval_Status__c, 'Submitted');

        Test.stopTest();
    }

    // test PS OpportunityApproval update methods with Approval
    static testMethod void Test2_TestEMEA_UK_OpportunityApprovalUpdateApproved() {
        createEMEA_UK_PSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<Opportunity_Approval__c> AllOppApprovals = new List<Opportunity_Approval__c>();
        AllOpps.add(testOpp);
        
        Test.startTest();         
        
        createOpptyApprovalTestData();
        AllOppApprovals.add(testOpptyApproval);
        
        testOpptyApproval.Finance_Approval_Status__c = 'Approved';
        update testOpptyApproval;

        System.AssertEquals(testOpptyApproval.Finance_Approval_Status__c, 'Approved');
        
        Test.stopTest();
    }    
    
     // test PS OpportunityApproval update methods with Rejection
    static testMethod void Test3_TestEMEA_UK_OpportunityApprovalUpdateRejected() {
        createEMEA_UK_PSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<Opportunity_Approval__c> AllOppApprovals = new List<Opportunity_Approval__c>();
        AllOpps.add(testOpp);
        
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        testOrder.Opportunity__c = testOpp.Id;
        testOrder.Status__c = 'In Progress';
        update testOrder;

        Test.startTest();         
        
        createOpptyApprovalTestData();
        AllOppApprovals.add(testOpptyApproval);

        testOpptyApproval.Finance_Rejection_Reason__c = 'This is a test rejection for code coverage/deployment validations';
        testOpptyApproval.Finance_Approval_Status__c = 'Rejected';
        update testOpptyApproval;

        System.AssertEquals(testOpptyApproval.Finance_Approval_Status__c, 'Rejected');
        
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
        testOpp.Direct_Sales__c = true;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

    // Create a PS Specific standalone test opportunity
    static void createEMEA_UK_PSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        acc.Country__c = 'a06U0000000ugdx'; // United Kingdom for specific UK/EMEA PS Oppty testing for subsidiary overrides
        update acc;
        
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'GBP';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        testOpp.PS_Region__c = 'EMEA';
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }

    static void createOpptyApprovalTestData()
    {
        testOpptyApproval = new Opportunity_Approval__c();
        testOpptyApproval.Approval_Type__c = 'Professional Services';
        testOpptyApproval.Finance_Approval_Status__c = 'Submitted';
        testOpptyApproval.Opportunity__c = testOpp.Id;
        testOpptyApproval.Finance_Review_Request_Sent__c = date.today();
        
        insert testOpptyApproval;
    }    
}