@isTest
public class DealQualificationAppAssignmentTest2{
    
    static testMethod void unitTest(){
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        accounts[0].SMART_Qualified__c = true;
        update accounts;
        
        RecordType rt = [Select id, name, developername from Recordtype where developername = 'Professional_Services' LIMIT 1];
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today();
        opportunities.Direct_Indirect_Sale__c ='Direct';
        opportunities.StageName = '5.Purchase Solution';
        opportunities.Competitor__c = 'Bridgetec';
        opportunities.ForecastStatus__c = '0.Booked';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.License_Amount__c = 24000;
        opportunities.RecordTypeId = rt.id;
        insert opportunities;
        
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                     Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Discount__c = 10;
        objTestProd.Product_Manager_Approval_Group__c =objProdMangerApprovalGroup.id;
        objTestProd.Product_Specific_Discount__c = 1;
        insert objTestProd;
        
        Deal_Qualification__c dealObj = new Deal_Qualification__c();
        dealObj.CurrencyIsoCode = 'USD';
        dealObj.Opportunity__c = opportunities.id;
        dealObj.Pricing_Type__c = 'New Pricing';
        dealObj.Type__c = 'Original';
        dealObj.Competitor__c = 'Bridgetec';
        dealObj.Compliance_of_the_Request_with_Value_Pri__c = 'Green = Value Pricing Compliant';
        dealObj.New_Pricing_Discount__c = '< 25%';
        dealObj.Net_Deal_Value__c = '25K - 50K';
        insert dealObj;
        
        Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
        dqp.Deal_Qualification__c= dealObj.id;
        dqp.Product__c = objTestProd.id;
        dqp.Discount__c = 15;
        insert dqp;
        
        Quote_Approver_Step_Approver_Details__c quoteApproverStepDetail = new Quote_Approver_Step_Approver_Details__c();
        quoteApproverStepDetail.Name = 'test';
        insert quoteApproverStepDetail;
        
        Quote_Approval_Steps__c quoteStep = new Quote_Approval_Steps__c();
        quoteStep.Name = 'test1';
        quoteStep.Deal_Size_Threshold_From__c = 1;
        quoteStep.Step_Type__c = 'test2';
        insert quoteStep;
        
        Quote_Approval_Step_Details__c qupteApprovalStep = new Quote_Approval_Step_Details__c();
        qupteApprovalStep.Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id;
        qupteApprovalStep.Quote_Approver_Step_Approver_Detail__c = quoteApproverStepDetail.id;
        qupteApprovalStep.Quote_Approval_Step__c = quoteStep.id;
        insert qupteApprovalStep;
        
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = 'ELA';
        testConfig1.Quote_Type__c = 'Cloud';
        testConfig1.Offering_Type__c = 'Business Edition';
        testConfig1.Pricing_Type__c = 'New Pricing';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        //testConfig1.Threshold_From__c = 2;
        //testConfig1.Criteria__c = '50;100';
        insert testConfig1;
        
        
        Quote_Approval_Config__c testConfig2 = new Quote_Approval_Config__c();
        testConfig2.Approval_Type__c = 'Deal Score';
        testConfig2.Quote_Type__c = 'Cloud';
        testConfig2.Offering_Type__c = 'Business Edition';
        testConfig2.Pricing_Type__c = 'New Pricing';
        testConfig2.Active__c = true;
        testConfig2.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfig2.Threshold_From__c = 2;
        testConfig2.Criteria__c = '50;100';
        insert testConfig2;
        
        List<Quote_Approval_Config_And_Steps__c> configAndStepList = new List<Quote_Approval_Config_And_Steps__c>();
        
        Quote_Approval_Config_And_Steps__c configAndStep = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig1.id;
        //insert configAndStep;
        configAndStepList.add(configAndStep);
        
        Quote_Approval_Config_And_Steps__c configAndStep2 = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig2.id;
        configAndStepList.add(configAndStep2);
        insert configAndStepList;
        
        Map<string,List<Quote_Approval_Config_And_Steps__c>> mapAbc = new Map<string,List<Quote_Approval_Config_And_Steps__c>>();
        mapAbc.put(qupteApprovalStep.Quote_Approval_Step__c,configAndStepList);
        
        
        
        
        
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dealObj,NULL,new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},mapAbc);
        
        
        DealQualificationAppAssignmentHelper.getApprovalForThresholdTypeIfAny(new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},
        configAndStep2, qupteApprovalStep, 3);
        
        
        
        DealQualificationAppAssignmentHelper.updateAmountToReadableFormat(1000);
        
        
        
        DealQualificationAppAssignmentHelper.updateAmountToReadableFormat(9999990);
        
        DealQualificationAppAssignmentHelper.updateAmountToReadableFormat(100000000);
        
        
        DealQualificationAppAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicableUpfront(dealObj, 2.0);

        DealQualificationAppAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicable(dealObj,2.0, true);
        
        /*DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dealObj, qupteApprovalStep,
        new List<Quote_Approval_Config_And_Steps__c>{configAndStep},'');*/        
    }

    static testMethod void unitTest1(){
        
        List<Account> accounts = TestUtil.createAccounts(1, true);
        accounts[0].SMART_Qualified__c = true;
        update accounts;
        
        RecordType rt = [Select id, name, developername from Recordtype where developername = 'Professional_Services' LIMIT 1];
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today();
        opportunities.Direct_Indirect_Sale__c ='Direct';
        opportunities.StageName = '5.Purchase Solution';
        opportunities.Competitor__c = 'Bridgetec';
        opportunities.ForecastStatus__c = '0.Booked';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.License_Amount__c = 24000;
        opportunities.RecordTypeId = rt.id;
        insert opportunities;
        
        
        Product_Manager_Approval_Group__c objProdMangerApprovalGroup 
                                        = new Product_Manager_Approval_Group__c(name='Test',
                                                                                     Product_Manager_Email_Addresses__c = 'test123@gensystestemail.com');
        insert objProdMangerApprovalGroup;
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';
        objTestProd.zqu__SKU__c ='Test1';
        objTestProd.Type__c = 'Product';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Discount__c = 10;
        objTestProd.Product_Manager_Approval_Group__c =objProdMangerApprovalGroup.id;
        objTestProd.Product_Specific_Discount__c = 1;
        insert objTestProd;
        
        Deal_Qualification__c dealObj = new Deal_Qualification__c();
        dealObj.CurrencyIsoCode = 'USD';
        dealObj.Opportunity__c = opportunities.id;
        dealObj.Pricing_Type__c = 'New Pricing';
        dealObj.Type__c = 'Original';
        dealObj.Competitor__c = 'Bridgetec';
        dealObj.Compliance_of_the_Request_with_Value_Pri__c = 'Green = Value Pricing Compliant';
        dealObj.New_Pricing_Discount__c = '< 25%';
        dealObj.Net_Deal_Value__c = '25K - 50K';
        insert dealObj;
        
        Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
        dqp.Deal_Qualification__c= dealObj.id;
        dqp.Product__c = objTestProd.id;
        dqp.Discount__c = 15;
        insert dqp;
        
        Quote_Approver_Step_Approver_Details__c quoteApproverStepDetail = new Quote_Approver_Step_Approver_Details__c();
        quoteApproverStepDetail.Name = 'test';
        insert quoteApproverStepDetail;
        
        Quote_Approval_Steps__c quoteStep = new Quote_Approval_Steps__c();
        quoteStep.Name = 'test1';
        quoteStep.Deal_Size_Threshold_From__c = 1;
        quoteStep.Step_Type__c = 'test2';
        insert quoteStep;
        
        Quote_Approval_Step_Details__c qupteApprovalStep = new Quote_Approval_Step_Details__c();
        qupteApprovalStep.Product_Manager_Approval_Group__c = objProdMangerApprovalGroup.id;
        qupteApprovalStep.Quote_Approver_Step_Approver_Detail__c = quoteApproverStepDetail.id;
        qupteApprovalStep.Quote_Approval_Step__c = quoteStep.id;
        insert qupteApprovalStep;
        
        Quote_Approval_Config__c testConfig1 = new Quote_Approval_Config__c();
        testConfig1.Approval_Type__c = 'ELA';
        testConfig1.Quote_Type__c = 'Cloud';
        testConfig1.Offering_Type__c = 'Business Edition';
        testConfig1.Pricing_Type__c = 'New Pricing';
        testConfig1.Active__c = true;
        testConfig1.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        //testConfig1.Threshold_From__c = 2;
        //testConfig1.Criteria__c = '50;100';
        insert testConfig1;
        
        Quote_Approval_Config__c testConfig2 = new Quote_Approval_Config__c();
        testConfig2.Approval_Type__c = 'Deal Score';
        testConfig2.Quote_Type__c = 'Cloud';
        testConfig2.Offering_Type__c = 'Business Edition';
        testConfig2.Pricing_Type__c = 'New Pricing';
        testConfig2.Active__c = true;
        testConfig2.Doesn_t_Depend_on_Region_Sub_Region__c = true;
        testConfig2.Threshold_From__c = 2;
        testConfig2.Criteria__c = '50;100';
        insert testConfig2;
        
        List<Quote_Approval_Config_And_Steps__c> configAndStepList = new List<Quote_Approval_Config_And_Steps__c>();
        
        Quote_Approval_Config_And_Steps__c configAndStep = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig1.id;
        //insert configAndStep;
        configAndStepList.add(configAndStep);
        
        Quote_Approval_Config_And_Steps__c configAndStep2 = new Quote_Approval_Config_And_Steps__c();
        configAndStep.Quote_Approval_Config__c = testConfig2.id;
        configAndStepList.add(configAndStep2);
        insert configAndStepList;
        
        
        
        Map<string,List<Quote_Approval_Config_And_Steps__c>> mapAbc = new Map<string,List<Quote_Approval_Config_And_Steps__c>>();
        mapAbc.put(quoteStep.id,new List<Quote_Approval_Config_And_Steps__c>{configAndStep});
        
        System.debug('mapAbc ' + mapAbc );
        
        DealQualificationAppAssignmentHelper.filterQuoteApprovals(dealObj,dealObj,new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},mapAbc);
        
        /*DealQualificationAppAssignmentHelper.getApprovalForDealScoreThresholdTypeIfAny(new List<Quote_Approval_Step_Details__c>{qupteApprovalStep},
        configAndStep2, qupteApprovalStep, 2,1.0);*/
        
                   
    }
}