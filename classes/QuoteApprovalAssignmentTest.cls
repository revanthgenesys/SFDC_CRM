//Naresh Kumar  10/01/2014
@isTest(seeAllData = true)
public class QuoteApprovalAssignmentTest {

    static testMethod void testQuoteAproval() {
        Test.startTest();
        createTestConfigData();
        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;
        testQuote.Quote_Business_Type__c = 'On Premise';
        insert testQuote;
        String result = QuoteApprovalAssignment.submitQuoteToApproval(testQuote.id);
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_APPROVED;
        testQuote.ELA__c = false;
        update testQuote;
        Test.stopTest();
        result = QuoteApprovalAssignment.submitQuoteToApproval(testQuote.id);
        //Quote Product
        createQuoteProducts(testOpp, testQuote);
        testQuote.ELA__c = true;
        testQuote.BigMachines__Total__c = 100000;
        testQuote.Pricing_Model__c = QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT;
        testQuote.Expiration_Date__c = System.today().addDays(10);
        testQuote.Approval_Submission_Date__c = System.today();
        testQuote.Total_Discount_Genesys_Products_Only__c = 50;
        testQuote.Include_Special_Offer_in_Output__c = true;
        testQuote.Genesys_Care_Rate__c = 10;
        testQuote.Genesys_Care_Default_Pricing_Percentage__c = 12;
        testQuote.Duration_Unit__c = 'Days';
        testQuote.Order_Numb_of_Maint_Days__c = 200;
        testQuote.Duration_Unit__c = 'Months';
        testQuote.Order_Numb_of_Maint_Months__c = 2;
        testQuote.Service_Level__c = QuoteApprovalUtil.DECLINE;
        testQuote.Revise_Minor__c = true;
        testQuote.CAD_Override__c = true;
        testQuote.Service_Level__c = QuoteApprovalUtil.PREMIUM;
        testQuote.Additional_Legal_Terms__c = true;
        testQuote.Editable_List_Price_Approval_Required__c = true;
        update testQuote;
        result = QuoteApprovalAssignment.submitQuoteToApproval(testQuote.id);
        QuoteApprovalAssignmentHelper.byPassApprovals(testQuote.id);
        System.debug('NKC debug result ['+result+']');
        QuoteProductsEmailTemplateController objContQPETC = new QuoteProductsEmailTemplateController();
        objContQPETC.getProducts();
    }  
    
    private static testMethod void testUpfrontApprovals(){
        Test.startTest();
        createTestConfigData();
        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;
        testQuote.Quote_Business_Type__c = 'On Premise';
        insert testQuote;
        createQuoteProducts(testOpp, testQuote);
        testQuote.ELA__c = true;
        testQuote.BigMachines__Total__c = 100000;
        testQuote.Pricing_Model__c = QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT;
        testQuote.Expiration_Date__c = System.today().addDays(10);
        testQuote.Approval_Submission_Date__c = System.today();
        testQuote.Total_Discount_Genesys_Products_Only__c = 50;
        testQuote.Include_Special_Offer_in_Output__c = true;
        testQuote.Genesys_Care_Rate__c = 10;
        testQuote.Genesys_Care_Default_Pricing_Percentage__c = 12;
        testQuote.Duration_Unit__c = 'Days';
        testQuote.Order_Numb_of_Maint_Days__c = 200;
        testQuote.Duration_Unit__c = 'Months';
        testQuote.Order_Numb_of_Maint_Months__c = 2;
        testQuote.Service_Level__c = QuoteApprovalUtil.DECLINE;        
        testQuote.CAD_Override__c = true;
        testQuote.Service_Level__c = QuoteApprovalUtil.PREMIUM;
        testQuote.Additional_Legal_Terms__c = true;
        testQuote.Editable_List_Price_Approval_Required__c = true;
        testQuote.No_Of_Months__c = 120;
        testQuote.Ramp_Period__c = '90';
        testQuote.Professional_Services_Discount__c = 35;
        testQuote.Hardware_Discount__c = 35;
        testQuote.Software_Discount__c = 35;
        testQuote.Overage_Discount__c = 35;
        testQuote.Billing_Period__c = 'Monthly';
        testQuote.Order_Payment_Terms__c = '120';
        update testQuote;
        ApexPages.currentPage().getParameters().put('id', testQuote.id);
        QuoteUpfrontApprovalController objUpfront = new QuoteUpfrontApprovalController();        
        testQuote.Revise_Minor__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING;
        update testQuote;        
        objUpfront.quoteId = testQuote.id; 
        objUpfront.getUpfrontApprovals();     
        QuoteApprovalAssignmentHelper.approvalRejectionActions(testQuote.id);
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);   
        QuoteRedirectController objQRC = new QuoteRedirectController(controller); 
        objQRC.goToPage();
        QuoteApprovalAssignmentHelper.approveDuplicateApproverRecordsQuote(Global_Configuration_Settings__c.getOrgDefaults().BE_DAP_User_Check__c.split(';')[0],testQuote.id);
        QuoteApprovalAssignmentHelper.quoteRevisionActions(testQuote);
        QuoteApprovalAssignmentHelper.getAlreadyApprovedRecords(testQuote,2);
        Test.stopTest();
    }  
    
    private static testMethod void testUpfrontApprovals2(){
        Test.startTest();
        Deal_qualification__c dq = [Select id from Deal_qualification__c order by lastmodifieddate limit 1];
        QuoteApprovalAssignmentHelper.approveDuplicateApproverRecordsDQ(userinfo.getuserid(),dq.id);
        QuoteApprovalAssignmentHelper.orderReasons('deal,desk');
        
        Test.stopTest();
    }
    
    private static void createQuoteProducts(Opportunity testOpp,  BigMachines__Quote__c testQuote){
        
        Product_Manager_Approval_Group__c testPMGroup = new Product_Manager_Approval_Group__c();
        testPMGroup.Name = 'Test PM Group';
        insert testPMGroup;
        List<Product2> products = TestUtil.createProducts(3, false);
        products[0].Type__c = QuoteApprovalUtil.PRODUCT_TYPE_GU;
        products[0].Product_Specific_Discount__c = 10;
        products[0].Third_Party__c = 'TRUE';
        products[1].Type__c = QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;  
        products[1].Product_Manager_Approval_Group__c = testPMGroup.id;
        products[1].Shipment_Approval__c = QuoteApprovalUtil.REQUIRED_FOR_NEW_ORDERS_ONLY;
        products[2].Type__c = 'Cloud';  
        products[2].Product_Manager_Approval_Group__c = testPMGroup.id;
        products[2].Shipment_Approval__c = QuoteApprovalUtil.NOTIFICATION_ONLY;     
        insert products;
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
        Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true LIMIT 1];
        testOpp.Pricebook2Id = standardPB.id;       
        update testOpp;
        List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(products, false);      
        quoteProducts[0].BigMachines__Quote__c = testQuote.id;
        quoteProducts[0].Total_Discount__c = 20;
        quoteProducts[0].BigMachines__Quantity__c = 10;
        quoteProducts[0].BigMachines__Sales_Price__c = 100;
        quoteProducts[1].BigMachines__Quote__c = testQuote.id;
        quoteProducts[1].Total_Discount__c = 20;
        quoteProducts[1].BigMachines__Quantity__c = 10;
        quoteProducts[1].BigMachines__Sales_Price__c = 100;
        quoteProducts[2].BigMachines__Quote__c = testQuote.id;
        quoteProducts[2].Total_Discount__c = 20;    
        quoteProducts[2].BigMachines__Quantity__c = 10;
        quoteProducts[2].BigMachines__Sales_Price__c = 100; 
        insert quoteProducts;
        
    }
        
    public static void createTestConfigData(){
        
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];      
        User testUser = TestCommon.createUser('u007', null, 'Last', 'Test', partnerProfile.id, false);
        insert testUser;
        
        //Quote Step Approver Details
        Quote_Approver_Step_Approver_Details__c testStepApproverDetails = new Quote_Approver_Step_Approver_Details__c();
        testStepApproverDetails.Actual_Approver__c = testUser.id;
        testStepApproverDetails.Name = 'Test Function Name';
        testStepApproverDetails.Minor_Quote_Change__c = QuoteApprovalUtil.MINOR_QUOTE_AND_EXPIRATION_DATE;
        insert testStepApproverDetails;
        testStepApproverDetails.OwnerId = testUser.id;
        update testStepApproverDetails;
        
        //Quote Approval Step 
        Quote_Approval_Steps__c testStep = new Quote_Approval_Steps__c();
        testStep.Name = 'Test Step 1';
        testStep.Order__c = 1;
        insert testStep;
        
        //Quote_Approval_Regions__c
        Quote_Approval_Regions__c testRegion = new Quote_Approval_Regions__c();
        testRegion.DAP_Region__c = 'NA';
        testRegion.Region__c = 'NA';
        testRegion.Sub_Region__c = 'NA';
        insert testRegion;
        
        //Quote Approval Step Details
        Quote_Approval_Step_Details__c testStepDetails = new Quote_Approval_Step_Details__c();
        testStepDetails.Quote_Approval_Step__c = testStep.id;
        testStepDetails.Quote_Approver_Step_Approver_Detail__c = testStepApproverDetails.id;
        insert testStepDetails;
        
        createConfigRecords(testRegion.id, testStep.id);
        
    }
    
    
    
    private static void createConfigRecords(Id regionId, Id stepId){
        
        List<Quote_Approval_Config__c> testConfigs = new List<Quote_Approval_Config__c>();
        //Quote Approval Config
        //ELA
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_ELA;
        testConfig1.Quote_Type__c = 'On Premise';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig1);
        //DISCOUNT
        Quote_Approval_Config__c testConfig2 = new Quote_Approval_Config__c();
        testConfig2.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_DISCOUNT;
        testConfig2.Quote_Type__c = 'On Premise';
        testConfig2.Threshold_From__c = 0;
        testConfig2.Active__c = true;
        testConfig2.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig2);
        //DEAL SIZE
        Quote_Approval_Config__c testConfig3 = new Quote_Approval_Config__c();
        testConfig3.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        testConfig3.Quote_Type__c = 'On Premise';
        testConfig3.Threshold_From__c = 100;
        testConfig3.Active__c = true;
        testConfig3.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig3);
        //PRICING MODEL CONCURRENT
        Quote_Approval_Config__c testConfig5 = new Quote_Approval_Config__c();
        testConfig5.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT;
        testConfig5.Quote_Type__c = 'On Premise';
        testConfig5.Active__c = true;
        testConfig5.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig5);
        //Exipiration Date
        Quote_Approval_Config__c testConfig4 = new Quote_Approval_Config__c();
        testConfig4.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE;
        testConfig4.Quote_Type__c = 'On Premise';
        testConfig4.No_Of_Days_After_Quote_Expires__c = 1;
        testConfig4.Active__c = true;
        testConfig4.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig4);
        //Special Offer Terms
        Quote_Approval_Config__c testConfig6 = new Quote_Approval_Config__c();
        testConfig6.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS;
        testConfig6.Quote_Type__c = 'On Premise';
        testConfig6.Active__c = true;
        testConfig6.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig6);
        //Care Override
        Quote_Approval_Config__c testConfig7 = new Quote_Approval_Config__c();
        testConfig7.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        testConfig7.Care_Override_Threshold__c = QuoteApprovalUtil.GC_THRESHOLD_GREATER_THAN_TWO;
        testConfig7.Quote_Type__c = 'On Premise';
        testConfig7.Active__c = true;
        testConfig7.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig7);
        //Term Reduced
        Quote_Approval_Config__c testConfig8 = new Quote_Approval_Config__c();
        testConfig8.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        testConfig8.Quote_Type__c = 'On Premise';
        testConfig8.Active__c = true;
        testConfig8.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig8);
        //Term Increased
        Quote_Approval_Config__c testConfig9 = new Quote_Approval_Config__c();
        testConfig9.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        testConfig9.Quote_Type__c = 'On Premise';
        testConfig9.Active__c = true;
        testConfig9.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig9);
        //Service Level - Decline
        Quote_Approval_Config__c testConfig10 = new Quote_Approval_Config__c();
        testConfig10.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        testConfig10.Quote_Type__c = 'On Premise';
        testConfig10.Active__c = true;
        testConfig10.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig10);
        //Revision
        Quote_Approval_Config__c testConfig11 = new Quote_Approval_Config__c();
        testConfig11.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_REVISION;
        testConfig11.Quote_Type__c = 'On Premise';
        testConfig11.Active__c = true;
        testConfig11.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig11);
        //3rd Party
        Quote_Approval_Config__c testConfig12 = new Quote_Approval_Config__c();
        testConfig12.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_THIRD_PARTY;
        testConfig12.Quote_Type__c = 'On Premise';
        testConfig12.Active__c = true;
        testConfig12.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig12);
        //Product Specific
        Quote_Approval_Config__c testConfig13 = new Quote_Approval_Config__c();
        testConfig13.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC;
        testConfig13.Quote_Type__c = 'On Premise';
        testConfig13.Active__c = true;
        testConfig13.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig13);
        //CAD Override
        Quote_Approval_Config__c testConfig14 = new Quote_Approval_Config__c();
        testConfig14.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        testConfig14.Quote_Type__c = 'On Premise';
        testConfig14.Active__c = true;
        testConfig14.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig14);
        //Premier Care
        Quote_Approval_Config__c testConfig15 = new Quote_Approval_Config__c();
        testConfig15.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        testConfig15.Quote_Type__c = 'On Premise';
        testConfig15.Active__c = true;
        testConfig15.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig15);
        //Additional Legal Terms
        Quote_Approval_Config__c testConfig16 = new Quote_Approval_Config__c();
        testConfig16.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        testConfig16.Quote_Type__c = 'On Premise';
        testConfig16.Active__c = true;
        testConfig16.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig16);
        //Editable List Price 
        Quote_Approval_Config__c testConfig17 = new Quote_Approval_Config__c();
        testConfig17.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        testConfig17.Quote_Type__c = 'On Premise';
        testConfig17.Active__c = true;
        testConfig17.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig17);
        //Intial subscription
        Quote_Approval_Config__c testConfig18 = new Quote_Approval_Config__c();
        testConfig18.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM;
        testConfig18.Quote_Type__c = 'Cloud';
        testConfig18.Threshold_From__c = 0;
        testConfig18.Active__c = true;
        testConfig18.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig18);
        //Ramp period
        Quote_Approval_Config__c testConfig19 = new Quote_Approval_Config__c();
        testConfig19.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD;
        testConfig19.Quote_Type__c = 'Cloud';
        testConfig19.Threshold_From__c = 0;
        testConfig19.Active__c = true;
        testConfig19.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig19);
        //PC PS Discount
        Quote_Approval_Config__c testConfig20 = new Quote_Approval_Config__c();
        testConfig20.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        testConfig20.Quote_Type__c = 'Cloud';
        testConfig20.Threshold_From__c = 0;
        testConfig20.Active__c = true;
        testConfig20.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig20);
        //PC Harware Discount
        Quote_Approval_Config__c testConfig21 = new Quote_Approval_Config__c();
        testConfig21.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        testConfig21.Quote_Type__c = 'Cloud';
        testConfig21.Threshold_From__c = 0;
        testConfig21.Active__c = true;
        testConfig21.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig21);
        //PC Software Discount
        Quote_Approval_Config__c testConfig22 = new Quote_Approval_Config__c();
        testConfig22.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        testConfig22.Quote_Type__c = 'Cloud';
        testConfig22.Threshold_From__c = 0;
        testConfig22.Active__c = true;
        testConfig22.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig22);
        //PC Overage Discount
        Quote_Approval_Config__c testConfig23 = new Quote_Approval_Config__c();
        testConfig23.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        testConfig23.Quote_Type__c = 'Cloud';
        testConfig23.Threshold_From__c = 0;
        testConfig23.Active__c = true;
        testConfig23.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig23);
        //PC APPROVAL_TYPE_BILLING_PERIOD
        Quote_Approval_Config__c testConfig24 = new Quote_Approval_Config__c();
        testConfig24.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        testConfig24.Quote_Type__c = 'Cloud';
        testConfig24.Threshold_From__c = 0;
        testConfig24.Active__c = true;
        testConfig24.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig24);
        //PC payment terms
        Quote_Approval_Config__c testConfig25 = new Quote_Approval_Config__c();
        testConfig25.Approval_Type__c = QuoteApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        testConfig25.Quote_Type__c = 'Cloud';
        testConfig25.Threshold_From__c = 0;
        testConfig25.Active__c = true;
        testConfig25.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfigs.add(testConfig25);
        
        insert testConfigs;
        List<Quote_Approval_Config_And_Steps__c> configAndSteps = new List<Quote_Approval_Config_And_Steps__c>();
        List<Quote_Approval_And_Quote_Approval_Region__c> configAndRegions = new List<Quote_Approval_And_Quote_Approval_Region__c>();
        for(Quote_Approval_Config__c eachConfig : testConfigs){
            Quote_Approval_Config_And_Steps__c configAndStep  = new Quote_Approval_Config_And_Steps__c();
            configAndStep.Quote_Approval_Steps__c = stepId;
            configAndStep.Quote_Approval_Config__c = eachConfig.id;
            configAndSteps.add(configAndStep);
            
            Quote_Approval_And_Quote_Approval_Region__c configAndRegion = new Quote_Approval_And_Quote_Approval_Region__c();
            configAndRegion.Quote_Approval_Region__c = regionId;
            configAndRegion.Quote_Approval_Config__c = eachConfig.id;
            configAndRegions.add(configAndRegion);
        }
        
        insert configAndSteps;
        insert configAndRegions;
        
        
    }
    
    private static testMethod void testUpfrontApprovals22(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        
        quote.No_Of_Months__c = 120;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Ramp_Period__c = '90';
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.CMRR__c = 15000;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Monthly_Recurring_Revenue_less_than_14K__c = 'Yes';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Estimated_Number_of_Agents__c = 2;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Estimated_Number_of_Business_Users__c = 6000;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        /*
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Business_User_to_Agent_Ratio_Exception__c = 'Yes';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].If_Other_PureCloud_Monthly_Minimum_Req__c = 100;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].PureCloud_Credit_Applied__c = true;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Professional_Services_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].PS_Discount_on_Quote__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Hardware_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Hardware_Discount__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Software_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Software_Discount__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Overage_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Overage_Discount__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Billing_Period__c = 'Monthly';
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Billing_Period__c = 'Monthly';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Order_Payment_Terms__c = '90';
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Payment_Terms__c = '90';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].offering_type__c = 'PureCloud';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS;
        update qaConfig;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        */
        Test.stopTest();
    }
  
  
  
private static testMethod void testUpfrontApprovals222(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);

appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Business_User_to_Agent_Ratio_Exception__c = 'Yes';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].If_Other_PureCloud_Monthly_Minimum_Req__c = 100;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].PureCloud_Credit_Applied__c = true;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
    
    Test.stopTest();
}



private static testMethod void testUpfrontApprovals222q(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);


        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Professional_Services_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].PS_Discount_on_Quote__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Hardware_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Hardware_Discount__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Software_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Software_Discount__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
      QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
    
    Test.stopTest();
}



private static testMethod void testUpfrontApprovals2212(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        quote.Overage_Discount__c = 40;
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Overage_Discount__c = 35;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Billing_Period__c = 'Monthly';
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Billing_Period__c = 'Monthly';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        quote.Order_Payment_Terms__c = '90';
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].Payment_Terms__c = '90';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        
        
  Test.stopTest();
}



private static testMethod void testUpfrontApprovals223(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);


        
       appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        dqList[0].offering_type__c = 'PureCloud';
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
    
      Test.stopTest();
}

private static testMethod void testUpfrontApprovals2231(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
     Test.stopTest();
        
}
private static testMethod void testUpfrontApprovals2232(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        Test.stopTest();
}

private static testMethod void testUpfrontApprovals223a2(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS;
        update qaConfig;
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
   Test.stopTest();
}
private static testMethod void testUpfrontApprovals2233(){
        Test.startTest();
        
        Country__c cntry = [Select id,name,RU__c,Country__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            op.Country__c=cntry.Id;
        }
        insert optyList;
        //create test records in Deal Qualification object
        list<Deal_Qualification__c> dqList = TestDataFactory2.createDealQualification(string.valueof(optyList[0].Id),1);
        for(Deal_Qualification__c dq:dqList){
            dq.Net_Deal_Value__c = '500K - 1M';
            dq.CurrencyIsoCode = 'USD';
            dq.Offering_Type__c = 'PureEngage Subscription';
            dq.New_Pricing_Discount__c = '< 50%';
            dq.Payment_Terms__c = 'Net 45';

        }
        insert dqList;
        Quote_Approval_Config__c qaConfig = new Quote_Approval_Config__c(Active__c=true,Quote_Type__C='On Premise',
                                                                         Offering_Type__c = 'PureEngage On Premise',
                                                                        Approval_Type__c='Discount Size',Threshold_From__c = 0,
                                                                        Threshold_Price_From__c = 90000000,
                                                                        No_Of_Days_After_Quote_Expires__c = 5,
                                                                         Doesn_t_Depend_on_Region_Sub_Region__c=true);
        insert qaConfig;
        List<Quote_Approval_Config__c> qaConfigList= new List<Quote_Approval_Config__c>();
        qaConfigList.add(qaConfig);
        
                
        Quote_Approval_Regions__c qaRegion = new Quote_Approval_Regions__c(DAP_Region__c='Brazil',Region__c='LATAM');
        insert qaRegion;
        
        Quote_Approval_And_Quote_Approval_Region__c qApprvlReg = new Quote_Approval_And_Quote_Approval_Region__c(Quote_Approval_Config__c=qaConfig.id,
                                                                                                                 Quote_Approval_Region__c=qaRegion.Id);
        insert qApprvlReg;
        
        Quote_Approval_Steps__c qAppSteps = new Quote_Approval_Steps__c(Name='Level 1',Order__c=1);
        insert qAppSteps;
        
        Quote_Approval_Config_And_Steps__c qAppConfSteps = new Quote_Approval_Config_And_Steps__c(//Quote_Approval_Config__c=qaConfig.id,
                                                                                                Quote_Approval_Config__c=qaConfig.id,
                                                                                                  Quote_Approval_Steps__c=qAppSteps.Id);
        insert qAppConfSteps;
        qAppConfSteps = [Select id,Quote_Approval_Config__r.Approval_Type__c,Quote_Approval_Config__r.Threshold_From__c,Quote_Approval_Config__r.Quote_Type__c,
        Quote_Approval_Config__r.Care_Override_Threshold__c,Quote_Approval_Config__r.Criteria__c,
        Quote_Approval_Config__r.Threshold_To__c,Quote_Approval_Config__r.Pricing_Model__c,Quote_Approval_Config__r.Threshold_Price_From__c,
        Quote_Approval_Config__r.Threshold_Price_To__c,Quote_Approval_Config__r.Partner_Only_Approval__c from Quote_Approval_Config_And_Steps__c where id = :qAppConfSteps.id limit 1];
        list<Quote_Approval_Config_And_Steps__c> appConfStepList = new List<Quote_Approval_Config_And_Steps__c>();
        appConfStepList.add(qAppConfSteps);
        
            
        Quote_Approval_Step_Details__c qAppStepDetails = new Quote_Approval_Step_Details__c(Quote_Approval_Region__c=qaRegion.Id,
                                                                                             Quote_Approval_Step__c=qAppSteps.Id);
        insert qAppStepDetails;
        List<Quote_Approval_Step_Details__c> qASD = new List<Quote_Approval_Step_Details__c>();
        qASD.add(qAppStepDetails);
                
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps = new Map<String, List<Quote_Approval_Config_And_Steps__c>> ();
        system.debug(qAppSteps.Id+''+appConfStepList);
        mapIdVsQuoteConfigAndSteps.put(qAppSteps.Id,appConfStepList);
        
        //string aprRsn = '';
        BigMachines__Quote_Product__c bmqp = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c  where BigMachines__Product__r.Product_Specific_Discount__c = 30 and
        Total_Discount__c > 30 limit 1];
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where id =:bmqp.BigMachines__Quote__c];
        quote = QuoteApprovalUtil.getQuote(quote.id);  
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PS;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PS;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);
        
        appConfStepList[0].Quote_Approval_Config__r.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION;
        qaConfig.Approval_Type__c = DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION;
        update qaConfig;
        qASD.add(qAppStepDetails);
        QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote ,qASD ,mapIdVsQuoteConfigAndSteps);
        QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote,qAppStepDetails,appConfStepList,null);     
  Test.stopTest();
}

    
    private static testMethod void testUpfrontApprovals3(){
        Test.startTest();
        createTestConfigData();
        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = 'Revision Pending';
        testQuote.Quote_Business_Type__c = 'On Premise';
        insert testQuote;
        createQuoteProducts(testOpp, testQuote);
        testQuote.ELA__c = true;
        
        testQuote.BigMachines__Total__c = 100000;
        testQuote.Pricing_Model__c = QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT;
        testQuote.Expiration_Date__c = System.today().addDays(10);
        testQuote.Approval_Submission_Date__c = System.today();
        testQuote.Total_Discount_Genesys_Products_Only__c = 50;
        testQuote.Include_Special_Offer_in_Output__c = true;
        testQuote.Genesys_Care_Rate__c = 10;
        testQuote.Genesys_Care_Default_Pricing_Percentage__c = 12;
        testQuote.Duration_Unit__c = 'Days';
        testQuote.Order_Numb_of_Maint_Days__c = 200;
        testQuote.Duration_Unit__c = 'Months';
        testQuote.Order_Numb_of_Maint_Months__c = 2;
        testQuote.Service_Level__c = QuoteApprovalUtil.DECLINE;        
        testQuote.CAD_Override__c = true;
        testQuote.Service_Level__c = QuoteApprovalUtil.PREMIUM;
        testQuote.Additional_Legal_Terms__c = true;
        testQuote.Editable_List_Price_Approval_Required__c = true;
        testQuote.No_Of_Months__c = 120;
        testQuote.Ramp_Period__c = '90';
        testQuote.Professional_Services_Discount__c = 35;
        testQuote.Hardware_Discount__c = 35;
        testQuote.Software_Discount__c = 35;
        testQuote.Overage_Discount__c = 35;
        testQuote.Billing_Period__c = 'Monthly';
        testQuote.Order_Payment_Terms__c = '120';
        update testQuote;
        ApexPages.currentPage().getParameters().put('id', testQuote.id);
        QuoteUpfrontApprovalController objUpfront = new QuoteUpfrontApprovalController();        
        testQuote.Revise_Minor__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING;
        update testQuote;        
        objUpfront.quoteId = testQuote.id; 
        objUpfront.getUpfrontApprovals();     
        QuoteApprovalAssignmentHelper.approvalRejectionActions(testQuote.id);
        ApexPages.StandardController controller = new ApexPages.StandardController(testQuote);   
        QuoteRedirectController objQRC = new QuoteRedirectController(controller); 
        objQRC.goToPage();
        QuoteApprovalAssignmentHelper.approveDuplicateApproverRecordsQuote(Global_Configuration_Settings__c.getOrgDefaults().BE_DAP_User_Check__c.split(';')[0],testQuote.id);
        QuoteApprovalAssignmentHelper.quoteRevisionActions(testQuote);
        QuoteApprovalAssignmentHelper.getAlreadyApprovedRecords(testQuote,2);
        Test.stopTest();
    } 
    
}