//Nik Mills - 27-May-2019
//For code coverage and testing of the OM Oppty RevPro Fields Checks custom panel
@IsTest(SeeAllData=true)
public class OM_Oppty_RevPro_Fields_Checks_Test
{
    static Opportunity testOpp;
    static Opportunity_Approval__c testOppApproval;
    
    static testMethod void TestOppApprovalRevProPanel()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        Test.StartTest();

        createPSOpptyTestData();

        Opportunity_Approval__c testOppApproval = new Opportunity_Approval__c (Opportunity__c = testOpp.Id, Approval_Type__c = 'Professional Services');
        insert testOppApproval;
        
        AllOpps.add(testOpp);
        
        PageReference pageRef = Page.Om_Oppty_RevPro_Field_Checks;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(testOppApproval.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(testOppApproval);

        
        OM_Oppty_RevPro_Field_Checks OMApprPanel = new OM_Oppty_RevPro_Field_Checks(sc);
        
        //System.AssertNotEquals(true, Om_Oppty_RevPro_Field_Checks.opptyRevProMissingDataDetails == '', 'Panel text return is blank');
              
        Test.StopTest();
    }
    
    
    // Create a PS Specific standalone test opportunity
    static void createPSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        List <Pricebook2> pBook = [SELECT Id, Name
                                                FROM Pricebook2
                                                WHERE Name =: 'Professional Services'];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        testOpp.PriceBook2Id = pBook[0].Id;
        testOpp.RevPro_Required_Data_Missing__c = true;
        testOpp.RevPro_Missing_Data_Details__c = 'Testing missing RevPro required PS Opportunity Data';
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

}