/*
Created By: Anju Chacko
Created On: 11-JAN-2018
Purpose: Test class for DealQualificationApprovalUtil
*/

@isTest(seeAllData=true)
public class DealQualificationApprovalUtilTest {
    
    static testMethod void synchDQOnPremiseTest(){
        Test.startTest();
        /*List<Account> acct = TestDataFactoryForQuoteTool.createAccounts(1);
        country__c country = [Select Id from country__c where Country__c='USA'];
        list<opportunity> optyList = TestDataFactoryForQuoteTool.createOpportunties1(acct[0].Id,country.Id,1);
        
        DealQualificationApprovalUtil.getDQ(optyList[0].id,'Enabled','test','PureConnect Cloud','test',getDQ().id);
        DealQualificationApprovalUtil.getDQ(optyList[0].id,'Enabled','test','PureConnect Cloud','test',null);
        Set<Id> stepIds = new Set<Id>();
        DealQualificationApprovalUtil.getQuoteApprvalConfigRecords(getDQ(),stepIds );
        DealQualificationApprovalUtil.getQuoteApprovalRecords(stepIds,getDQ());
        
        List<BigMachines__Quote__c> quote = TestDataFactoryForQuoteTool.createQuotes(optyList[0].Id, acct[0].Id,1);
        for(BigMachines__Quote__c qRec:quote){
            qRec.Offering_Type__c = 'PureEngage Subscription';
        }
        update quote;*/
        BigMachines__Quote__c quote = [select id,BigMachines__Opportunity__c from BigMachines__Quote__c where Offering_Type__c='PureEngage Subscription' limit 1];
        
        deal_qualification__c dq = getDQ();
        dq.Req_Revenue_Approval__c = true;
        dq.Req_Order_Mgmt_Billing_approval__c = true;
        dq.Req_Credit_Collections_approval__c = true;
        dq.Req_Legal_approval__c = true;
        
        
        DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c,'Enabled','test','PureConnect Cloud','test',dq.id);
        DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c,'Enabled','test','PureConnect Cloud','test',null);
        Set<Id> stepIds = new Set<Id>();
        DealQualificationApprovalUtil.getQuoteApprvalConfigRecords(dq,stepIds );
        DealQualificationApprovalUtil.getQuoteApprovalRecords(stepIds,dq);
        
        //List<product2> product = TestDataFactoryForQuoteTool.createproducts(2);
        //List<BigMachines__Quote_Product__c> quoteProd = TestDataFactoryForQuoteTool.createQuoteProducts(quote[0].Id);
        
        string syncDQ = DealQualificationAndQuoteApprovalHelper.synchDQ(string.valueof(quote.Id),string.valueof(quote.BigMachines__Opportunity__c));      
        
        DealQualificationApprovalUtil.DQSpecOfferSubApprWrapper testwrrpr = DealQualificationApprovalUtil.checkSpecOfferApprPending(dq);
        DealQualificationApprovalUtil.sendSpecOfferSubApprEmails(dq,testwrrpr.finToAddresses, dq.Opportunity__r.Country_Region__c,false,false,false,false);
        
        
        Test.stopTest();
    }
    
    
    static testMethod void Test1(){
        Test.startTest();
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c,Quote_Opportunity_Type__c,Quote_Business_Type__c,
                                       Offering_Type__c,Total_Discount_Genesys_Products_Only__c,Include_Special_Offer_in_Output__c,
                                       Special_Offer_Terms__c,Editable_List_Price_Approval_Required__c,CurrencyIsoCode from BigMachines__Quote__c where Offering_Type__c = 'Business Edition' 
                                       and Total_Discount_Genesys_Products_Only__c != null order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);   
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Total_Discount_Genesys_Products_Only__c = 10;
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Editable_List_Price_Approval_Required__c = true;
        
        Deal_Qualification__c dq = getDQ();  
        dq.Editable_List_Price_Approval_Required__c = false;
        dq.Discount_On_Quote__c = 5;
        dq.Special_Offer_Terms__c = false;
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForCloudBE(quote,dq,false);
        dq.Opportunity__c = quote.BigMachines__Opportunity__c;
        dq.Offering_Type__c = quote.Offering_Type__c;
        update dq;
        
        
        
        List<Deal_Qualification__c> dqs = new List<Deal_Qualification__c>();
        dqs = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        if(dqs.size() > 0)
            delete dqs;
        DealQualificationAndQuoteApprovalHelper.synchDQCloudBE(quote,quote.BigMachines__Opportunity__c);
        dq = new Deal_Qualification__c();
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForCloudBE(quote,dq,false);
        
        Test.stopTest();
    }
    
    
    
    static testMethod void Test7(){
        Test.startTest();
        DealQualificationApprovalUtil DQT = new DealQualificationApprovalUtil();
        DealQualificationApprovalUtil.getPCMonthlyMinimum('Other',2000);
        DealQualificationApprovalUtil.getPCMonthlyMinimum('4000',2000);
        DealQualificationApprovalUtil.getBillingPeriod('Yearly');
        DealQualificationApprovalUtil.getPaymentTerms('Net 30');
        DealQualificationApprovalUtil.getRampPeriod('Other',40);
        DealQualificationApprovalUtil.getRampPeriod('40',40);
        DealQualificationApprovalUtil.getInitialSubscriptionTerm('Other',30);
        DealQualificationApprovalUtil.getInitialSubscriptionTerm('40',40);
        DealQualificationApprovalUtil.getRespectiveDQPageName('test','test');
        
        Map<Id, Set<Id>> mapGroupIdVsProductId = new Map<Id, Set<Id>> ();
        
        Quote_Approval__c QA = [SELECT Product_Ids__c, Product_Manager_Approval_Group__c,Deal_Qualification__c,Status__c FROM Quote_Approval__c WHERE  
             Product_Manager_Approval_Group__c != null limit 1];
        DealQualificationApprovalUtil.isAlreadyApprovedPMApproval(QA.Deal_Qualification__c,mapGroupIdVsProductId , QA.Status__c);
        
        DealQualificationApprovalUtil.getDQListPrice('5-10',80);
        DealQualificationApprovalUtil.convertCurrencyfromUSD(4567,'EUR');
        DealQualificationApprovalUtil.convertCurrency(4456,'EUR');
        DealQualificationApprovalUtil.getDiscountSize('5-10');
        DealQualificationApprovalUtil.getDiscountSize('No Discount');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(75,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(85,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(95,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(65,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(55,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(35,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(45,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(25,'New Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(15,'New Pricing');        
        DealQualificationApprovalUtil.getDiscountSizePickListVal(99,'New Pricing');
        
        DealQualificationApprovalUtil.getDiscountSizePickListVal(75,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(85,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(95,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(65,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(55,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(35,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(45,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(25,'Old Pricing');
        DealQualificationApprovalUtil.getDiscountSizePickListVal(15,'Old Pricing');        
        DealQualificationApprovalUtil.getDiscountSizePickListVal(99,'Old Pricing');
        
        DealQualificationApprovalUtil.getDealSize('200M - 500M');
        DealQualificationApprovalUtil.getDealSize('200B - 500B');
        DealQualificationApprovalUtil.getDealSizePickListVal(200000000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(40000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(74000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(90000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(400000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(900000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(1100000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(2000000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(10000000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(50000000,QuoteUtil.OFFERING_TYPE_CIC);
        DealQualificationApprovalUtil.getDealSizePickListVal(2000000000,QuoteUtil.OFFERING_TYPE_CIC);
        
        
        DealQualificationApprovalUtil.getDealSizePickListVal(200000000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(200000000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(40000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(74000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(90000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(400000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(900000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(1100000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(2000000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(10000000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(50000000,'PureConnect Cloud');
        DealQualificationApprovalUtil.getDealSizePickListVal(2000000000,'PureConnect Cloud');
        
        DealQualificationApprovalUtil.isPMApprovalRequired(DealQualificationApprovalUtil.HIGHLY_TECHNICAL_SALE);
        DealQualificationApprovalUtil.isPMApprovalRequired('test');
        DealQualificationApprovalUtil.isNotificationOnly('NOTIFICATION_ONLY');
        DealQualificationApprovalUtil.isNotificationOnly('test');
        
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_PC order by lastmodifieddate desc limit 1];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        
        DealQualificationApprovalUtil.getMinimumApprovalLimit(quote);
        DealQualificationApprovalUtil.getApprovalSubmission(QA.Deal_Qualification__c,2);
        DealQualificationApprovalUtil.getDQProducts(QA.Deal_Qualification__c);
        DealQualificationApprovalUtil.getPMGroupIdsWithPMApprovalRequired(QA.Deal_Qualification__c);
        DealQualificationApprovalUtil.getDQFromId(QA.Deal_Qualification__c);
        
        String testStr = DealQualificationApprovalUtil.STATUS_INACTIVE;
        
             
        
        //DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }
    
    
    static Deal_Qualification__c getDQ(){
        return [SELECT id,Opportunity__c,Name, Net_Deal_Value__c, Old_Pricing_Discount__c, New_Pricing_Discount__c, CurrencyIsoCode, Ramp_Period_Days__c, Payment_Terms__c,
                Genesys_Care__c, Override_by_2__c, Override_2__c, Term_Increase__c, Term_Decrease__c, Decline__c,
                Premium_Care__c, Require_Separate_Quote_for_Genesys_Care__c, Support_Option__c, Other_Non_Standard_Finance_Exceptions__c,
                ELA__c, X3rd_Party_Products__c, Contractual_Pricing__c, Are_you_selling_Non_GA_Future_Roadmap__c,
                No_Professional_Services_Required__c, Other__c, Partner_Provided_Professional_Services__c, Opportunity__r.Country_Region__c, Opportunity__r.Country_Sub_Region__c, Expected_Billing_Start_Date__c, Delayed_Billing_Start_Date__c,
                Opportunity__r.Country_DAP__c, Opportunity__r.New_DAP_Region__c, Opportunity__r.Country__r.Old_Pricing_DAP_Region__c,
                Special_Offer_Terms__c, CAD_Override__c, Service_Level__c, Status__c, Expiration_Date__c, Opportunity__r.Country__r.RU__c,
                PureCloud_Credit_Applied__c,Additional_Legal_Terms__c, Editable_List_Price_Approval_Required__c, Do_you_require_Professional_Services__c,
                Product_or_Solution_Name__c, Describe_your_roadmap_related_request__c, Justification_and_time_constraints__c,
                Product_Managers_already_approached__c, Is_Genesys_Providing_PS__c, Is_third_Party_company_providing_PS__c,
                Pricing_Type__c, Contractual_Rate__c, GC_Override__c, Quote__r.Quote_Business_Type__c, Quote__r.Offering_Type__c,
                Special_Offers_Business_Exceptions__c, Product_Values__c, Potential_Growth__c, Discount_On_Quote__c, Justification_for_Discount__c,
                Compliance_of_the_Request_with_Value_Pri__c, Current_and_Historical_discount_within_t__c, Current_and_Historical_Genesys_Care_Rate__c,
                Historical_Discount_on_the_Account__c, Historical_Genesys_Care_rate_on_the_acco__c, Deal_Factory_Recommendation_Status__c,
                Submission_Date__c, Approval_Date__c, Competitor__c, X3rd_Party_Override__c, Competition__c, Partner__c, Opportunity__r.BusinessPartner__c,
                IsOldPricingApproved__c, Partner_Tier_Discount__c, Deal_Registration_Discount__c, Term_Discount__c, Seat_Size_Discount__c, Seat_Count_Tier__c,
                Term_Discount_Range__c, Seat_Discount_Range__c, New_Logo_Discount_Range__c, New_Logo_Discount__c, Term_Length__c, Is_Cloud_Partner__c,
                Cloud_Partner_Approval__c, PPU_Deal_Approval__c, Platform_Type__c, Offering_Type__c, Total_Genesys_Agent_Seats__c,Total_Agent_Seats__c,
                Number_of_Seats__c,Committed_Minutes__c,Estimated_Usage_Minutes__c,Pricing_Model__c,Is_Telco_Included__c,Is_Telco_Quoted_At_Standard_Rates__c,
                Explanation_for_Telco_Pricing__c,Is_MPLS_included__c,Has_MPLS_been_approved__c,Has_MPLS_questionnaire_been_submitted__c,DQ_Page_Name__c,
                Is_Inbound_Voice_included__c,Data_Center_Region__c,PureEngage_Cloud_Regional_Avg_Discount__c,Margin__c,Type__c,
                Finance_Exception__c, Legal_Exceptions__c, PureCloud_Business_Exceptions__c, Any_Overage_over_20_for_any_month__c, Explanation_for_Overage__c,
                Business_Users_Add_On__c,Base_Agent_Discount__c, Hardware_Discount__c, Business_Users_Provisioning_Discount__c, Data_Center_Provisioning_Discount__c,
                Estimated_Usage_Minutes_Numbers__c, Initial_Subscription_Term_Months__c, Professional_Services__c, What_is_total_list_price__c, Carveout__c,
                OwnerId, Opportunity__r.Owner.Name, Opportunity__r.Owner.Email, CarveOutDetails__c,
                Initial_Subscription_Term_Months_PC__c,If_Other_Term_Months_Requested__c,If_Other_Ramp_Period_Requested_Days__c,
                PureCloud_Monthly_Minimum__c,If_Other_PureCloud_Monthly_Minimum_Req__c,Billing_Period__c, Business_User_to_Agent_Ratio_Exception__c,Estimated_Monthly_Recurring_Revenue__c,Estimated_Number_of_Agents__c,Estimated_Number_of_Business_Users__c,
                Less_than_100_Agents__c,Monthly_Recurring_Revenue_less_than_14K__c,More_than_5_000_Business_Users__c, Opportunity__r.Region_Non_CSM__c,PureCloud_Trial__c,
                PS_Discount_on_Quote__c,Overage_Allowance__c, Overage_Price_Premium__c, PureSuccess__c, Are_you_selling_A_La_Cart_PureSuccess__c,
                Delayed_Billing_Start_Date_Days__c, Delayed_Subscription_Start_Date_Days__c, Optional_extended_term_length_Months__c, Price_Escalation__c,
                Req_Credit_Collections_approval__c,Req_Legal_approval__c,Req_Order_Mgmt_Billing_approval__c,Req_Revenue_Approval__c,Credit_and_Collections_approval__c,
                Credit_Collections_Comments__c,Legal_approval__c,Legal_Comments__c,Order_Mgmt_Billing_approval__c,Order_Management_Billing_Comments__c,Revenue_approval__c,
                Revenue_Comments__c,createdbyid,
                Smart_Use_Case__c, Discount_Base_Package__c, Overage_Allowance_Other__c, Annual_Price_Escalation_Other__c, Subscription_Smart_Qualified_Approval__c
                from Deal_Qualification__c 
                where Type__c = 'History' order by lastmodifieddate desc limit 1];
        
    }
}