@isTest
public class QuoteApprovalUtilTest{

    static testMethod void unitTest(){
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'North America',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;        
        insert opportunities;
        
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'Cloud';
        objTestQuote.Offering_Type__c = 'Business Edition';
        objTestQuote.Expiration_Date__c = Date.today().addDays(90);
        objTestQuote.Approval_Submission_Date__c = Date.today();
        insert objTestQuote;
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                     Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        
        Quote_Approval__c objQuoteApproval = new Quote_Approval__c();
        objQuoteApproval.Actual_Approver__c = UserInfo.getUserId();
        objQuoteApproval.Status__c = 'In Progress';
        objQuoteApproval.Quote_Approval_Date__c = System.today();
        objQuoteApproval.Step__c = 1;
        objQuoteApproval.Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id;
        objQuoteApproval.BigMachines_Quote__c = objTestQuote.id;
        objQuoteApproval.Submitted_Date__c = System.today();
        insert objQuoteApproval;
        
        Quote_Approval_Steps__c testStep = new Quote_Approval_Steps__c();
        testStep.Name = 'Test Step 1';
        testStep.Order__c = 1;
        insert testStep;
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';       
        insert objTestProd1;
        
        //QuoteApprovalUtil quoteUtil = new QuoteApprovalUtil();
        QuoteApprovalUtil.getQuote(objTestQuote.id);
        QuoteApprovalUtil.getPMGroupIdsWithPMApprovalRequired(objTestQuote.id);
        QuoteApprovalUtil.getQuoteProducts(objTestQuote.id);
        QuoteApprovalUtil.getApprovalSubmission(objTestQuote.id,1);
        QuoteApprovalUtil.getQuoteApprvalConfigRecords(objTestQuote,new Set<ID>{testStep.id});
        QuoteApprovalUtil.getQuoteApprovalRecords(new Set<ID>{testStep.id},objTestQuote);
        
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = 'Product Management';
        testConfig1.Quote_Type__c = 'Cloud';
        testConfig1.Offering_Type__c = 'Business Edition';
        testConfig1.Pricing_Type__c = 'New Pricing';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfig1.Quote_Offering_Type__c ='Business Edition';
        insert testConfig1;
        
        Quote_Approval_Regions__c testRegion = new Quote_Approval_Regions__c();
        testRegion.DAP_Region__c = 'North America';
        testRegion.Region__c = 'NA';
        testRegion.Sub_Region__c = 'NA';
        insert testRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c quoteApprovalRegion = new Quote_Approval_And_Quote_Approval_Region__c();
        quoteApprovalRegion.Quote_Approval_Region__c = testRegion.id;
        quoteApprovalRegion.Quote_Approval_Config__c = testConfig1.id;
        insert quoteApprovalRegion;
        
        Quote_Approval_Config_And_Steps__c configAndStep = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig1.id;
        insert configAndStep;
        
        Set<Id> setId = new Set<Id>();
        setId.add(objTestProd1.id);
        Map<Id,Set<Id>> mapID = new Map<Id,Set<Id>>();
        mapID.put(objQuoteApproval.id,setId);
        QuoteApprovalUtil.isAlreadyApprovedPMApproval(objTestQuote.id,mapID,'In Progress');
    }
}