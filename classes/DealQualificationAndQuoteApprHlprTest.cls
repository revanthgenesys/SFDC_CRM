/*
Created By: Mukunthan Koothan
Created On: 11-JAN-2018
Purpose: Test class for DealQualificationAndQuoteApprovalHelper
*/

@isTest(seeAllData=true)
public class DealQualificationAndQuoteApprHlprTest {
    
    static testMethod void synchDQOnPremiseTest(){
        Test.startTest();
        List<Account> acct = TestDataFactoryForQuoteTool.createAccounts(1);
        country__c country = [Select Id from country__c where Country__c='USA'];
        list<opportunity> optyList = TestDataFactoryForQuoteTool.createOpportunties1(acct[0].Id,country.Id,1);
        List<BigMachines__Quote__c> quote = TestDataFactoryForQuoteTool.createQuotes(optyList[0].Id, acct[0].Id,1);
        for(BigMachines__Quote__c qRec:quote){
            qRec.Offering_Type__c = 'PureEngage Subscription';
        }
        update quote;
        
        List<product2> product = TestDataFactoryForQuoteTool.createproducts(2);
        List<BigMachines__Quote_Product__c> quoteProd = TestDataFactoryForQuoteTool.createQuoteProducts(quote[0].Id);
        
        string syncDQ = DealQualificationAndQuoteApprovalHelper.synchDQ(string.valueof(quote[0].Id),string.valueof(optyList[0].Id));      
        
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
        quote.Deal_Score__c = 3;
        
        Deal_Qualification__c dq = getDQ();  
        dq.Editable_List_Price_Approval_Required__c = false;
        dq.Discount_On_Quote__c = 5;
        dq.Deal_Score__c = 2;
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
    
    static testMethod void Test2(){
        Test.startTest();
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from 
        BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_CAAS and BigMachines__Line_Items__c = 2 and Annual_Contract_Value__c != null
        order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Special_Offer_Terms__c = 'testQ';
        quote.Editable_List_Price_Approval_Required__c = true;
        quote.Base_Agent_Discount__c = 20;
        quote.Hardware_Discount__c = 20;
        quote.Business_Users_Add_On__c = 20;
        quote.Data_Center_Provisioning_Discount__c = 20;
        quote.No_Of_Months__c = 38;
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Ramp_Period__c = '120';
        quote.Billing_Period__c = 'Monthly';
        quote.Order_Payment_Terms__c = '24';
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        Deal_Qualification__c dq = getDQ(); 
        
        dq.Editable_List_Price_Approval_Required__c= false;
        dq.Base_Agent_Discount__c = 5;
        dq.Hardware_Discount__c = 5;
        dq.Business_Users_Add_On__c = 5;
        dq.Data_Center_Provisioning_Discount__c = 5;
        dq.Initial_Subscription_Term_Months_PC__c = '12';
        dq.Payment_Terms__c = 'Net 30';
        dq.Special_Offer_Terms__c = false;
        dq.If_Other_Ramp_Period_Requested_Days__c = 60;
        dq.Billing_Period__c = 'Yearly';
        dq.Payment_Terms__c = '12';
        dq.Estimated_Number_of_Business_Users__c =  null;
        dq.Estimated_Number_of_Agents__c = null;
        
        List<BigMachines__Quote_Product__c> list_QPProducts = [ Select id,BigMachines__Product__c,Total_Discount__c,BigMachines__Product__r.Product_Specific_Discount__c,
         BigMachines__Product__r.Type__c,
         BigMachines__Product__r.Third_Party__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :quote.id];                  
        list_QPProducts[0].APN_Number__c = Label.PCC_Agent_based_products.split(';')[0];
        list_QPProducts[0].Quantity__c = 15;
        list_QPProducts[1].APN_Number__c = Label.PCC_Business_users_products.split(';')[0];
        list_QPProducts[1].Quantity__c = 6000;
        
        
        update list_QPProducts; 
        
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForCaaS(quote,dq,false);
        
        
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }
    
    
    static testMethod void Test3a(){
        Test.startTest();
        
        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        insert objAccount;
        
        subscription__c sub = new Subscription__c();   
        sub.Account__c =objAccount.id;
        sub.Subscription_Start_Date__c = Date.today().addDays(-4);
        sub.Ramp_End_Date__c = Date.today().addMonths(1);   
        sub.Subscription_End_Date__c = Date.today().addMonths(1);
        sub.Status__c = 'Active';
        sub.Offering_Type__c  = 'PureConnect';
        sub.Term__c = '1 Month';
        insert sub;
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD'; 
        opportunities.Offering_Detail__c = 'Pilot';       
        insert opportunities;
        
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from BigMachines__Quote__c where BigMachines__Line_Items__c = 2 order by lastmodifieddate desc limit 1];
        quote.Offering_Type__c = QuoteUtil.OFFERING_TYPE_PC;
        quote.Order_Type__c = 'Amend';
        quote.Annual_Contract_Value__c = 50;
        quote.BigMachines__Opportunity__c = opportunities.id;
        quote.Amendment_For__c = sub.id;
        update quote;
        quote = QuoteApprovalUtil.getQuote(quote.id);
        
        Currency_Configuration__c currConfig = new Currency_Configuration__c();
        currConfig.Price_Book__c = 'NG5_NA_USD';
        currConfig.Pricing_Type__c = 'Old Pricing';
        currConfig.Multiplier__c = 1.1002;
        currConfig.Conversion_Rate__c = 1.1;
        currConfig.Offering_Type__c = 'PureConnect';
        currConfig.Start_Date__c = Date.today().addDays(-2);
        currConfig.End_Date__c = Date.today().addDays(2);
        insert currConfig;
                          
        /*List<Product2> toUpdate =  new List<Product2>();
        toUpdate.add(new Product2(Name = 'PureCloud Credit v2',APN_Number__c = 'Test'));
        toUpdate.add(new Product2(Name = 'PureCloud Credit v2',APN_Number__c = 'Test1'));
        insert toUpdate;*/
        List<Product2> toUpdate = [SELECT Id,Name,APN_Number__c  FROM Product2 Limit 2];
        List<BigMachines__Quote_Product__c> list_QPProducts = [ Select id,BigMachines__Product__c,Total_Discount__c,BigMachines__Product__r.Product_Specific_Discount__c,
        BigMachines__Product__r.Type__c,
        BigMachines__Product__r.Third_Party__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :quote.id];
        list_QPProducts[0].BigMachines__Product__c = toUpdate[0].id;
        update list_QPProducts;
        quote.Include_Special_Offer_in_Output__c = true;
        quote.No_Of_Months__c = 38;
        quote.Ramp_Period__c = '120';
        quote.Editable_List_Price_Approval_Required__c = true;
        quote.Order_Payment_Terms__c = '50';
        quote.Order_Type__c = 'New Subscription';
        quote.Annual_Contract_Value__c = 100000;
        quote.New_Price_Book__c = 'NG5_NA_USD';
        update quote;
        Deal_Qualification__c dq = getDQ(); 
        dq.PureCloud_Credit_Applied__c = false;
        dq.PureCloud_Trial__c = false;
        dq.PureCloud_Credit_Applied__c = false;
        dq.Special_Offer_Terms__c = false;
        dq.If_Other_Term_Months_Requested__c = 32;
        dq.If_Other_Ramp_Period_Requested_Days__c = 90;
        dq.Editable_List_Price_Approval_Required__c = false;
        dq.Payment_Terms__c = '30';
        update dq;
        //DealQualificationAndQuoteApprovalHelper.checkApprovalsForPC(quote,dq,false);
        
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);    
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        sub.Term__c = '1 Year';
        update sub;
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);    
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        
        Test.stopTest();
    }
    
    
    static testMethod void Test4(){
        Test.startTest();
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where Offering_Type__c = 'PureEngage Subscription' 
                                       and Discount__c != null order by lastmodifieddate desc limit 1];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Highest_Discount__c = 35;
        quote.Special_Offer_Terms__c = 'testQ';
        quote.Price_Escalation__c = 'Other';
        quote.Overage_Allowance__c = 'Other';
        quote.Order_Payment_Terms__c = 'Net 90';
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Highest_Discount__c = 10;
        update quote;
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        Deal_Qualification__c dq = getDQ(); 
        dq.Price_Escalation__c = 'test';  
        dq.Overage_Allowance__c = 'test';
        dq.Payment_Terms__c = 'Net 30';
        dq.Special_Offer_Terms__c = false;
        
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForSubscription(quote,dq,false);
        Test.stopTest();
    }
    
    static testMethod void Test4a(){
        Test.startTest();
        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        insert objAccount;
        
        subscription__c sub = new Subscription__c();   
        sub.Account__c =objAccount.id;
        sub.Subscription_Start_Date__c = Date.today().addDays(-4);
        sub.Ramp_End_Date__c = Date.today().addMonths(1);   
        sub.Subscription_End_Date__c = Date.today().addMonths(1);
        sub.Status__c = 'Active';
        sub.Offering_Type__c  = 'PureConnect';
        sub.Term__c = '1 Month';
        insert sub;
        
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where Offering_Type__c = 'PureEngage Subscription' 
                                       and Discount__c != null order by lastmodifieddate desc limit 1];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Highest_Discount__c = 35;
        quote.Special_Offer_Terms__c = 'testQ';
        quote.Price_Escalation__c = 'Other';
        quote.Overage_Allowance__c = 'Other';
        quote.Discount__c = 2;
        quote.Amendment_For__c = sub.id;
        quote.Usage_Data_Submission_Method__c = 'Manual';
        quote.Order_Payment_Terms__c = 'Net 90';
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Highest_Discount__c = 10;
        update quote;
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        Deal_Qualification__c dq = getDQ(); 
        dq.Price_Escalation__c = 'test';  
        dq.Overage_Allowance__c = 'test';
        dq.Payment_Terms__c = 'Net 30';
        dq.Special_Offer_Terms__c = false;
        
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForSubscription(quote,dq,false);
        Test.stopTest();
    }
    
    static testMethod void Test5(){
        Test.startTest();
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c,Quote_Business_Type__c,Offering_Type__c from BigMachines__Quote__c where Offering_Type__c = 'Premier Edition' 
                                       and BigMachines__Line_Items__c > 1 
                                       and Discount__c != null order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);    
        DealQualificationAndQuoteApprovalHelper.resetELAApproval(quote);
        
        Test.stopTest();
    }
    
    static testMethod void Test6a(){
        Test.startTest();
        Account objAccount = TestUtil.createAccounts(1, false)[0];
        objAccount.SAP_Account_Code__c = 'GARN TEST';
        insert objAccount;
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD'; 
        opportunities.Offering_Detail__c = 'Pilot';       
        insert opportunities;
        
        subscription__c sub = new Subscription__c();   
        sub.Account__c =objAccount.id;
        sub.Subscription_Start_Date__c = Date.today().addDays(-4);
        sub.Ramp_End_Date__c = Date.today().addMonths(1);   
        sub.Subscription_End_Date__c = Date.today().addMonths(1);
        sub.Status__c = 'Active';
        sub.Term__c ='3 Years';
        sub.Offering_Type__c  = 'PureConnect';
        sub.Term__c = '1 Month';
        insert sub;
        
        Deal_Qualification__c dq = getDQ();
        dq.PureCloud_Credit_Applied__c = false;
        update dq;
        
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_PC order by lastmodifieddate desc limit 1];
        quote.BigMachines__Opportunity__c = opportunities.id;
        quote.Order_Type__c = 'Amend';
        quote.Amendment_For__c = sub.id;
        update quote;
        DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.id);    
        sub.Term__c ='1 Month';
        update sub;
        DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.id); 
        Test.stopTest();
    }
    
    static testMethod void Test7(){
        Test.startTest();
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_PC  and Annual_Contract_Value__c != null order by lastmodifieddate desc limit 1];
           
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }
    
    static testMethod void Test8(){
        Test.startTest();
        Order__c order = [Select id from Order__c order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.sendNROPMApprovalNotifications(order.id);    
        DealQualificationAndQuoteApprovalHelper.getOverrideScore('test');
        Test.stopTest();
    }
    
    static testMethod void Test9(){
        Test.startTest();
        Deal_Qualification__c dq = getDQ();
        
        DealQualificationAndQuoteApprovalHelper.resetApprovalsIfNeeded(dq,'New Pricing');    
        
        Test.stopTest();
    }
    
    static testMethod void test10() {
        Test.startTest();
        BigMachines__Quote__c quote = [Select id from BigMachines__Quote__c where Offering_Type__c = 'PureEngage Subscription' 
                                       and Discount__c != null and order__c != null and BigMachines__Line_Items__c > 3 order by lastmodifieddate desc limit 1];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        BigMachines__Quote__c quote2 = [Select id,order__c from BigMachines__Quote__c where id = :quote.id limit 1];

        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);  
        
             Set<Id> set_ProdIds = new Set<Id>();
             Id prodMgrApprId = [SELECT Id FROM Product_Manager_Approval_Group__c  where Product_Manager_Email_Addresses__c != null Limit 1].Id;
              List<BigMachines__Quote_Product__c> list_QtProds = [SELECT Id, BigMachines__Product__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quote.Id];
              for(BigMachines__Quote_Product__c objQP : list_QtProds) {
                             set_ProdIds.add(objQP.BigMachines__Product__c);
                             objQP.Total_Discount__c = 15.0;
              }
              update list_QtProds;
              List<Product2> list_Prods = [SELECT Id, Type__c, Product_Specific_Discount__c, Third_Party__c FROM Product2 WHERE Id IN :set_ProdIds];
              for(Product2 objProd : list_Prods) {
                             objProd.Product_Specific_Discount__c = 10.0;
                             objProd.Third_Party__c = 'true';
                             objProd.Type__c = QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
                             objProd.Product_Manager_Approval_Group__c = prodMgrApprId;
                             objProd.Shipment_Approval__c = DealQualificationApprovalUtil.PRODUCT_HAS_PREREQ; 
              }
              list_Prods[1].Type__c = QuoteApprovalUtil.PRODUCT_TYPE_GU;
              update list_Prods;
              
              Quote_Approval_Step_Details__c qA = [Select id,Product_Manager_Approval_Group__c  from Quote_Approval_Step_Details__c where Quote_Approver_Step_Approver_Detail__c != null limit 1];
              qA.Product_Manager_Approval_Group__c = prodMgrApprId;
              update qA;
        /*
list_DQProducts[0].Product__r.Product_Specific_Discount__c = 10.0;
list_DQProducts[0].Discount__c = 15.0;
list_DQProducts[0].Product__r.Type__c = QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
list_DQProducts[1].Product__r.Product_Specific_Discount__c = 10.0;
list_DQProducts[1].Discount__c = 15.0;
list_DQProducts[1].Product__r.Type__c = QuoteApprovalUtil.PRODUCT_TYPE_GU;
list_DQProducts[2].Product__r.Product_Specific_Discount__c = 10.0;
list_DQProducts[2].Discount__c = 15.0;
list_DQProducts[2].Product__r.Third_Party__c = true;
*/
        
        //update list_QPProducts;  
        //minimumLimitsDiscountAndDealSize[0] -- set to 2 if test class;
        
        quote.Total_Discount_Genesys_Products_Only__c = 10;
              quote.ELA__c = true;
              quote.Offering_Type__c = 'PureConnect Cloud';
              quote.Expiration_Date__c = System.today().addDays(100);
              quote.Include_Special_Offer_in_Output__c = true;
              quote.Special_Offer_Terms__c = 'Quote Offer';
              quote.Order_Numb_of_Maint_Days__c = DealQualificationApprovalUtil.STANDARD_TERM_DAYS - 1;
              quote.Duration_Unit__c = 'Days';
              quote.PPU_Rental__c = false;
              quote.Don_t_Fire_Genesys_Care_Approval__c = false;
              quote.Genesys_Care_Rate__c = 3;
              quote.Genesys_Care_Default_Pricing_Percentage__c = 7;
              quote.BigMachines__Total__c = 1000;
              //quote.GC_Decline__c = true;
              quote.CAD_Override__c = true;
              quote.Service_Level__c = QuoteApprovalUtil.PREMIUM;
              quote.Additional_Legal_Terms__c = true;
              quote.X3rd_Party_Override__c = true;
              quote.Quote_Opportunity_Type__c = 'Old Pricing';
              quote.No_Of_Months__c = 12;
              quote.Pricing_Model__c = 'PPU';
              //quote.BigMachines__Opportunity__r.BusinessPartner__r.PartnerType__c = 'Cloud Solution Provider';
              quote.Finance_Exceptions__c = 'Non-Standard Payment terms';
              quote.Legal_Exceptions__c = '    Limitation of Liability';
              quote.Support_Options__c = 'Priority Support';
              quote.Carveout__c = true;
              quote.CarveOutDetails__c = 'CarveOut';
              quote.Editable_List_Price_Approval_Required__c = true;
              
              Deal_Qualification__c dq = getDQ(); 
              dq.New_Pricing_Discount__c = '5';
              dq.ELA__c = 'No';
              dq.Expiration_Date__c = System.today().addDays(90);
              dq.Special_Offer_Terms__c = false;
              dq.Special_Offers_Business_Exceptions__c = 'Special Offer';
              dq.Net_Deal_Value__c = '500';
              dq.Term_Decrease__c = false;
              dq.Term_Increase__c = false;
              dq.Decline__c = false;
              dq.CAD_Override__c = false;
              dq.Premium_Care__c = false;
              dq.Additional_Legal_Terms__c = false;
              dq.X3rd_Party_Override__c = false;
              dq.IsOldPricingApproved__c = false;
              dq.Term_Length__c = 14;
              dq.PPU_Deal_Approval__c = false;
              dq.Cloud_Partner_Approval__c = false;
              dq.Finance_Exception__c = '       Acceptance of Software or PSO';
              dq.Legal_Exceptions__c = '          Extended Warranty';
              dq.Support_Option__c = null;
              dq.Carveout__c = false;
              dq.CarveOutDetails__c = 'Carve';
              dq.Editable_List_Price_Approval_Required__c = false;
              dq.Opportunity__c = quote.BigMachines__Opportunity__c;
              dq.Offering_Type__c = quote.Offering_Type__c;
              
              Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
              dqp.Deal_Qualification__c= dq.id;
              dqp.Product__c = list_Prods[1].id;
              dqp.Discount__c = 15;
              insert dqp;
              Deal_Qualification_Products__c dqp2 = new Deal_Qualification_Products__c();
              dqp2.Deal_Qualification__c= dq.id;
              dqp2.Product__c = list_Prods[2].id;
              dqp2.Discount__c = 15;
              insert dqp2;
              Test.stopTest();
              DealQualificationAndQuoteApprovalHelper.checkApprovalsForOnPremiseQuote(quote, dq, false);
                             
              quote.Offering_Type__c = QuoteUtil.OFFERING_TYPE_CIC;
              quote.PPU_Rental__c = false;
              quote.Don_t_Fire_Genesys_Care_Approval__c = false;
              quote.Genesys_Care_Rate__c = 3;
              quote.Genesys_Care_Default_Pricing_Percentage__c = 5;
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForOnPremiseQuote(quote, dq, false);
              
              quote.PPU_Rental__c = false;
              quote.Don_t_Fire_Genesys_Care_Approval__c = false;
              quote.Genesys_Care_Rate__c = 3;
              quote.Genesys_Care_Default_Pricing_Percentage__c = 4;
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForOnPremiseQuote(quote, dq, false);
                DealQualificationAndQuoteApprovalHelper.synchDQOnPremise(quote, quote.BigMachines__Opportunity__c);
              DealQualificationAndQuoteApprovalHelper.sendPMApprovalNotifications(quote.id);
              Order_Line_Item__c oL = new Order_Line_Item__c(Order__c = quote2.Order__c,Product__c = list_Prods[0].id);
              insert oL; 
              DealQualificationAndQuoteApprovalHelper.sendNROPMApprovalNotifications(quote2.order__c);
              List<Quote_Approval__c> existingQuoteApprovals = [SELECT Step__c, Approval_Submission_Counter__c,Deal_Qualification__c  FROM Quote_Approval__c 
                                                          LIMIT 1];
        
              DealQualificationAndQuoteApprovalHelper.insertNotificationResetInfo(existingQuoteApprovals[0].Deal_Qualification__c , 'test');
              
    }
    static testMethod void test11() {
        
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from BigMachines__Quote__c where Offering_Type__c = 'Business Edition' 
                                       and Discount__c != null and order__c != null and BigMachines__Line_Items__c > 3 order by lastmodifieddate desc limit 1];
        quote = QuoteApprovalUtil.getQuote(quote.id);
        BigMachines__Quote__c quote2 = [Select id,order__c from BigMachines__Quote__c where id = :quote.id limit 1];
        Integer intNumOfprods=3;
        List<Product2> list_NewProd = new List<Product2>();
        for(Integer i=0; i<intNumOfprods; i++) {
            list_NewProd.add(new Product2(Name='Testproduct' + i,Quantities_Available__c = '1',Product_Specific_Discount__c=5,
                                          Unit_of_Measure__c = 'Seat',Quantity__c = 1 ,Product_Name__c='test',
                                          Taxonomy_Solution_Category__c='Business Optimization', Taxonomy_Solution__c='Integration',
                                          OfferingType__c ='PureEngage Subscription',Shipment_Approval__c='No Approval Required',New_Category__c = 'Bundles',
            
                                          Tier__c='Preferred', ProductSubFamily__c = 'Data Center Provisioning',zqu__SKU__c = '123'+ i));
        }
        // Insert all Products for prod.
        insert list_NewProd;
        List<BigMachines__Quote_Product__c> insertBMP= new List<BigMachines__Quote_Product__c>();
        for(Product2 P: list_NewProd){
            BigMachines__Quote_Product__c BigQP= new BigMachines__Quote_Product__c();
            BigQP.APN_Number__c = 'CS-012-NV-CBAF';
            BigQP.BigMachines__Quote__c=quote.id;
            BigQP.BigMachines__Product__c=p.id;
            BigQP.BigMachines__Quantity__c=10;
            BigQP.BigMachines__Sales_Price__c=10;
            BigQP.Quantity__c=10;
            insertBMP.add(BigQP);
        }
        insert insertBMP;
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);  
        
             Set<Id> set_ProdIds = new Set<Id>();
             Id prodMgrApprId = [SELECT Id FROM Product_Manager_Approval_Group__c  where Product_Manager_Email_Addresses__c != null Limit 1].Id;
              List<BigMachines__Quote_Product__c> list_QtProds = [SELECT Id, BigMachines__Product__c,ACV_Equivalent__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quote.Id AND Type__c != 'Cloud' AND BigMachines__Product__c !=''];
              for(BigMachines__Quote_Product__c objQP : list_QtProds) {
                             set_ProdIds.add(objQP.BigMachines__Product__c);
                             objQP.Total_Discount__c = 15.0;
                             objQP.APN_Number__c = 'CS-012-NV-CBAF';
                             objQP.Quantity__c = 2;
              }
              update list_QtProds;
              List<Product2> list_Prods = [SELECT Id, Type__c, Product_Specific_Discount__c, Third_Party__c FROM Product2 WHERE Id IN :set_ProdIds];
              system.debug('list_Prods###'+list_Prods);
              system.debug('list_Prods###'+list_Prods.size());
              for(Product2 objProd : list_Prods) {
                             objProd.Product_Specific_Discount__c = 10.0;
                             objProd.Type__c = QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE;
                             objProd.Product_Manager_Approval_Group__c = prodMgrApprId;
                             objProd.Shipment_Approval__c = DealQualificationApprovalUtil.PRODUCT_HAS_PREREQ; 
              }
              list_Prods[0].Type__c = 'GU';
              update list_Prods;
              
              Quote_Approval_Step_Details__c qA = [Select id,Product_Manager_Approval_Group__c  from Quote_Approval_Step_Details__c where Quote_Approver_Step_Approver_Detail__c != null limit 1];
              qA.Product_Manager_Approval_Group__c = prodMgrApprId;
              update qA;
        
              quote.Total_Discount_Genesys_Products_Only__c = 10;
              quote.ELA__c = true;
              quote.Order_Type__c = 'New';
              quote.Offering_Type__c = 'Business Edition';
              quote.Expiration_Date__c = System.today().addDays(100);
              quote.Include_Special_Offer_in_Output__c = true;
              quote.Special_Offer_Terms__c = 'Quote Offer';
              quote.Ramp_Period__c = '120';
              quote.Order_Numb_of_Maint_Days__c = DealQualificationApprovalUtil.STANDARD_TERM_DAYS - 1;
              quote.Duration_Unit__c = 'Days';
              quote.PPU_Rental__c = false;
              quote.Don_t_Fire_Genesys_Care_Approval__c = false;
              quote.Genesys_Care_Rate__c = 3;
              quote.Genesys_Care_Default_Pricing_Percentage__c = 7;
              quote.BigMachines__Total__c = 1000;
              quote.CurrencyIsoCode = 'USD';
              //quote.GC_Decline__c = true;
              quote.CAD_Override__c = true;
              quote.Service_Level__c = QuoteApprovalUtil.PREMIUM;
              quote.Additional_Legal_Terms__c = true;
              quote.X3rd_Party_Override__c = true;
              quote.Quote_Opportunity_Type__c = 'Old Pricing';
              quote.No_Of_Months__c = 12;
              quote.Pricing_Model__c = 'PPU';
              //quote.BigMachines__Opportunity__r.BusinessPartner__r.PartnerType__c = 'Cloud Solution Provider';
              quote.Finance_Exceptions__c = 'Non-Standard Payment terms';
              quote.Legal_Exceptions__c = '    Limitation of Liability';
              quote.Support_Options__c = 'Priority Support';
              quote.Carveout__c = true;
              quote.CarveOutDetails__c = 'CarveOut';
              quote.Editable_List_Price_Approval_Required__c = true;
              
              Deal_Qualification__c dq = getDQ(); 
              dq.New_Pricing_Discount__c = '5';
              dq.ELA__c = 'No';
              dq.Expiration_Date__c = System.today().addDays(90);
              dq.Special_Offer_Terms__c = false;
              dq.Special_Offers_Business_Exceptions__c = 'Special Offer';
              dq.Net_Deal_Value__c = '500';
              dq.Term_Decrease__c = false;
              dq.Term_Increase__c = false;
              dq.Decline__c = false;
              dq.CAD_Override__c = false;
              dq.Premium_Care__c = false;
              dq.Additional_Legal_Terms__c = false;
              dq.X3rd_Party_Override__c = false;
              dq.IsOldPricingApproved__c = false;
              dq.Term_Length__c = 14;
              dq.PPU_Deal_Approval__c = false;
              dq.Cloud_Partner_Approval__c = false;
              dq.Finance_Exception__c = 'Acceptance of Software or PSO';
              dq.Legal_Exceptions__c = 'Extended Warranty';
              dq.Support_Option__c = null;
              dq.Carveout__c = false;
              dq.CarveOutDetails__c = 'Carve';
              dq.Editable_List_Price_Approval_Required__c = false;
              dq.Opportunity__c = quote.BigMachines__Opportunity__c;
              dq.Offering_Type__c = quote.Offering_Type__c;
              
              Deal_Qualification_Products__c dqp = new Deal_Qualification_Products__c();
              dqp.Deal_Qualification__c= dq.id;
              dqp.Product__c = list_Prods[1].id;
              dqp.Discount__c = 15;
              insert dqp;
              Deal_Qualification_Products__c dqp2 = new Deal_Qualification_Products__c();
              dqp2.Deal_Qualification__c= dq.id;
              dqp2.Product__c = list_Prods[2].id;
              dqp2.Discount__c = 15;
              insert dqp2;
              
              DealQualificationAndQuoteApprovalHelper.checkApprovalsForCloudBE(quote, dq, false);
              DealQualificationAndQuoteApprovalHelper.checkApprovalsForCaaS(quote, dq, false);
              DealQualificationAndQuoteApprovalHelper.checkApprovalsForPC(quote, dq, false);
                             
              quote.Offering_Type__c = 'Business Edition';
              quote.PPU_Rental__c = false;
              quote.Don_t_Fire_Genesys_Care_Approval__c = false;
              quote.Genesys_Care_Rate__c = 3;
              quote.Genesys_Care_Default_Pricing_Percentage__c = 5;
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForCloudBE(quote, dq, false);
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForCaaS(quote, dq, false);
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForPC(quote, dq, false);
              
              quote.PPU_Rental__c = false;
              quote.Don_t_Fire_Genesys_Care_Approval__c = false;
              quote.Genesys_Care_Rate__c = 3;
              quote.Genesys_Care_Default_Pricing_Percentage__c = 4;
              Test.startTest();
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForCloudBE(quote, dq, false);
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForCaaS(quote, dq, false);
                DealQualificationAndQuoteApprovalHelper.checkApprovalsForPC(quote, dq, false);
                DealQualificationAndQuoteApprovalHelper.synchDQCloudBE(quote, quote.BigMachines__Opportunity__c);
                DealQualificationAndQuoteApprovalHelper.synchDQPC(quote, quote.BigMachines__Opportunity__c);
                //DealQualificationAndQuoteApprovalHelper.synchDQPCC(quote, quote.BigMachines__Opportunity__c);
              DealQualificationAndQuoteApprovalHelper.sendPMApprovalNotifications(quote.id);
              Order_Line_Item__c oL = new Order_Line_Item__c(Order__c = quote2.Order__c,Product__c = list_Prods[0].id);
              insert oL; 
              DealQualificationAndQuoteApprovalHelper.sendNROPMApprovalNotifications(quote2.order__c);
              List<Quote_Approval__c> existingQuoteApprovals = [SELECT Step__c, Approval_Submission_Counter__c,Deal_Qualification__c  FROM Quote_Approval__c 
                                                          LIMIT 1];
        
              DealQualificationAndQuoteApprovalHelper.insertNotificationResetInfo(existingQuoteApprovals[0].Deal_Qualification__c , 'test');
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
                Smart_Use_Case__c, Discount_Base_Package__c, Overage_Allowance_Other__c, Annual_Price_Escalation_Other__c, Subscription_Smart_Qualified_Approval__c,Deal_Score__c,Third_Party_Discount__c
                from Deal_Qualification__c 
                where Type__c = 'History' order by lastmodifieddate desc limit 1];
        
    }

    static testMethod void testPCC(){
        Util.Bypass_Trigger_Chk = true;
        
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from 
        BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_CAAS and BigMachines__Line_Items__c = 2 and Annual_Contract_Value__c != null
        order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Special_Offer_Terms__c = 'testQ';
        quote.Editable_List_Price_Approval_Required__c = true;
        quote.Base_Agent_Discount__c = 20;
        quote.Hardware_Discount__c = 20;
        quote.Business_Users_Add_On__c = 20;
        quote.Data_Center_Provisioning_Discount__c = 20;
        quote.No_Of_Months__c = 38;
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Ramp_Period__c = '120';
        quote.Billing_Period__c = 'Monthly';
        quote.Order_Payment_Terms__c = '24';
        quote.Order_Type__c = 'Amend Subscription';
        quote.Third_Party_Discount__c = 30;
        quote.Overage_Allowance__c = 'Other';
        quote.Overage_Discount__c = 10;
        quote.Price_Escalation__c = 'Other';
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        Deal_Qualification__c dq = getDQ(); 
        
        dq.Editable_List_Price_Approval_Required__c= false;
        dq.Base_Agent_Discount__c = 5;
        dq.Hardware_Discount__c = 5;
        dq.Business_Users_Add_On__c = 5;
        dq.Data_Center_Provisioning_Discount__c = 5;
        dq.Initial_Subscription_Term_Months_PC__c = '12';
        dq.Payment_Terms__c = 'Net 30';
        dq.Special_Offer_Terms__c = false;
        dq.If_Other_Ramp_Period_Requested_Days__c = 60;
        dq.Billing_Period__c = 'Yearly';
        dq.Payment_Terms__c = '12';
        dq.Estimated_Number_of_Business_Users__c =  null;
        dq.Estimated_Number_of_Agents__c = null;
        
        List<BigMachines__Quote_Product__c> list_QPProducts = [ Select id,BigMachines__Product__c,Total_Discount__c,BigMachines__Product__r.Product_Specific_Discount__c,
         BigMachines__Product__r.Type__c,
         BigMachines__Product__r.Third_Party__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :quote.id];                  
        list_QPProducts[0].APN_Number__c = Label.PCC_Agent_based_products.split(';')[0];
        list_QPProducts[0].Quantity__c = 15;
        list_QPProducts[1].APN_Number__c = Label.PCC_Business_users_products.split(';')[0];
        list_QPProducts[1].Quantity__c = 6000;
         list_QPProducts[0].Is_Overage__c = true;
        List<BigMachines__Quote_Product__c> list_QPProducts2 = TestDataFactoryForQuoteTool.createQuoteProductsforDQ(quote.Id);
        update list_QPProducts[0]; 
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes2(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Test.startTest();
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForCaaS(quote,dq,false);
        DealQualificationAndQuoteApprovalHelper.synchDQPCC(quote,quote.BigMachines__Opportunity__c);
        DealQualificationAndQuoteApprovalHelper.synchDQPCC(list_NewQuotes[0],quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }
    static testMethod void testPEC(){
        Util.Bypass_Trigger_Chk = true;
        
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from 
        BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_CAAS and BigMachines__Line_Items__c = 2 and Annual_Contract_Value__c != null
        order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Offering_Type__c = SubscriptionUtil.OFFERING_TYPE_PEC;
        quote.Special_Offer_Terms__c = 'testQ';
        quote.Editable_List_Price_Approval_Required__c = true;
        quote.Base_Agent_Discount__c = 20;
        quote.Hardware_Discount__c = 20;
        quote.Business_Users_Add_On__c = 20;
        quote.Data_Center_Provisioning_Discount__c = 20;
        quote.No_Of_Months__c = 38;
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Ramp_Period__c = '120';
        quote.Billing_Period__c = 'Monthly';
        quote.Order_Payment_Terms__c = '24';
        quote.Order_Type__c = 'New';
        quote.Third_Party_Discount__c = 30;
        quote.Overage_Allowance__c = 'Other';
        quote.Overage_Discount__c = 10;
        quote.Price_Escalation__c = 'Other';
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        Deal_Qualification__c dq = getDQ(); 
        
        dq.Editable_List_Price_Approval_Required__c= false;
        dq.Base_Agent_Discount__c = 5;
        dq.Hardware_Discount__c = 5;
        dq.Business_Users_Add_On__c = 5;
        dq.Data_Center_Provisioning_Discount__c = 5;
        dq.Initial_Subscription_Term_Months_PC__c = '12';
        dq.Payment_Terms__c = 'Net 30';
        dq.Special_Offer_Terms__c = false;
        dq.If_Other_Ramp_Period_Requested_Days__c = 60;
        dq.Billing_Period__c = 'Yearly';
        dq.Payment_Terms__c = '12';
        dq.Estimated_Number_of_Business_Users__c =  null;
        dq.Estimated_Number_of_Agents__c = null;
        dq.PureCloud_Credit_Applied__c=false;
        Integer intNumOfprods=3;
        List<Product2> list_NewProd = new List<Product2>();
        for(Integer i=0; i<intNumOfprods; i++) {
            list_NewProd.add(new Product2(Name='Testproduct' + i,Quantities_Available__c = '1',Product_Specific_Discount__c=5,
                                          Unit_of_Measure__c = 'Seat',Quantity__c = 1 ,Product_Name__c='test',
                                          Taxonomy_Solution_Category__c='Business Optimization', Taxonomy_Solution__c='Integration',
                                          OfferingType__c ='PureEngage Subscription',Shipment_Approval__c='No Approval Required',New_Category__c = 'Bundles',
            
                                          Tier__c='Preferred', ProductSubFamily__c = 'Data Center Provisioning',zqu__SKU__c = '123'+ i));
        }
        // Insert all Products for prod.
        insert list_NewProd;
        List<BigMachines__Quote_Product__c> insertBMP= new List<BigMachines__Quote_Product__c>();
        for(Product2 P: list_NewProd){
            BigMachines__Quote_Product__c BigQP= new BigMachines__Quote_Product__c();
            BigQP.BigMachines__Quote__c=quote.id;
            BigQP.BigMachines__Product__c=p.id;
            BigQP.BigMachines__Quantity__c=10;
            BigQP.BigMachines__Sales_Price__c=10;
            BigQP.Quantity__c=10;
            insertBMP.add(BigQP);
        }
        insert insertBMP;
        List<BigMachines__Quote_Product__c> list_QPProducts = [ Select id,BigMachines__Product__c,Total_Discount__c,BigMachines__Product__r.Product_Specific_Discount__c,
                                                                BigMachines__Product__r.Type__c,BigMachines__Product__r.Third_Party__c from BigMachines__Quote_Product__c 
                                                                where BigMachines__Quote__c = :quote.id ];                  
        system.debug('list_QPProducts####'+list_QPProducts.size());
        list_QPProducts[0].APN_Number__c = Label.PCC_Agent_based_products.split(',')[0];
        list_QPProducts[0].Quantity__c = 15;
        list_QPProducts[0].Discount__c=1;
        list_QPProducts[1].APN_Number__c = Label.PCC_Business_users_products.split(',')[0];
        list_QPProducts[1].Quantity__c = 6000;
        list_QPProducts[1].Discount__c=35;
         list_QPProducts[0].Is_Overage__c = true;
        List<BigMachines__Quote_Product__c> list_QPProducts2 = TestDataFactoryForQuoteTool.createQuoteProductsforDQ(quote.Id);
        update list_QPProducts[0]; 
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes2(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Test.startTest();
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForPEC(quote,dq,false);
        DealQualificationAndQuoteApprovalHelper.synchDQPEC(quote,quote.BigMachines__Opportunity__c);
        DealQualificationAndQuoteApprovalHelper.synchDQPEC(list_NewQuotes[0],quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }


    static testMethod void testPC(){
        Util.Bypass_Trigger_Chk = true;
        
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c from 
        BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_PC and BigMachines__Line_Items__c = 2 
        order by lastmodifieddate desc limit 1];
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        quote = QuoteApprovalUtil.getQuote(quote.id);
        quote.Special_Offer_Terms__c = 'testQ';
        quote.Editable_List_Price_Approval_Required__c = true;
        quote.Base_Agent_Discount__c = 20;
        quote.Hardware_Discount__c = 20;
        quote.Business_Users_Add_On__c = 20;
        quote.Data_Center_Provisioning_Discount__c = 20;
        quote.No_Of_Months__c = 38;
        quote.Include_Special_Offer_in_Output__c = true;
        quote.Ramp_Period__c = '120';
        quote.Billing_Period__c = 'Monthly';
        quote.Order_Payment_Terms__c = '24';
        quote.Order_Type__c = 'Amend Subscription';
        quote.Third_Party_Discount__c = 30;
        quote.Overage_Allowance__c = 'Other';
        quote.Overage_Discount__c = 10;
        quote.Price_Escalation__c = 'Other';
        quote.Ramp_Period__c = '180.8976';
        DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id); 
        Deal_Qualification__c dq = getDQ(); 
        
        dq.Editable_List_Price_Approval_Required__c= false;
        dq.Base_Agent_Discount__c = 5;
        dq.Hardware_Discount__c = 5;
        dq.Business_Users_Add_On__c = 5;
        dq.Data_Center_Provisioning_Discount__c = 5;
        dq.Initial_Subscription_Term_Months_PC__c = '12';
        dq.Payment_Terms__c = 'Net 30';
        dq.Special_Offer_Terms__c = false;
        dq.If_Other_Ramp_Period_Requested_Days__c = 60;
        dq.Billing_Period__c = 'Yearly';
        dq.Payment_Terms__c = '12';
        dq.Estimated_Number_of_Business_Users__c =  null;
        dq.Estimated_Number_of_Agents__c = null;
        
        List<BigMachines__Quote_Product__c> list_QPProducts = [ Select id,BigMachines__Product__c,Total_Discount__c,BigMachines__Product__r.Product_Specific_Discount__c,
         BigMachines__Product__r.Type__c,
         BigMachines__Product__r.Third_Party__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :quote.id];                  
        list_QPProducts[0].APN_Number__c = Label.PCC_Agent_based_products.split(';')[0];
        list_QPProducts[0].Quantity__c = 15;
        list_QPProducts[1].APN_Number__c = Label.PCC_Business_users_products.split(';')[0];
        list_QPProducts[1].Quantity__c = 6000;
         list_QPProducts[0].Is_Overage__c = true;
        List<BigMachines__Quote_Product__c> list_QPProducts2 = TestDataFactoryForQuoteTool.createQuoteProductsforDQPC(quote.Id);
        update list_QPProducts[0];
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes2(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Test.startTest();
        DealQualificationAndQuoteApprovalHelper.checkApprovalsForPC(quote,dq,false);
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        DealQualificationAndQuoteApprovalHelper.synchDQPC(list_NewQuotes[0],quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }
    
    static testMethod void testPCC2(){
        Util.Bypass_Trigger_Chk = true;
        
        List<Account> lstAcc=TestDataFactoryForQuoteTool.createAccounts(1);
        List<Opportunity> lstOpp= TestDataFactoryForQuoteTool.createOpportunties(lstAcc[0].id,1);
        List<BigMachines__Quote__c> lstquote=TestDataFactoryForQuoteTool.createQuotes(lstOpp[0].id,lstAcc[0].id,1,QuoteUtil.OFFERING_TYPE_CAAS);
        BigMachines__Quote__c quote=lstquote[0];
        
        Test.startTest();
        DealQualificationAndQuoteApprovalHelper.synchDQPCC(quote,quote.BigMachines__Opportunity__c);
        DealQualificationAndQuoteApprovalHelper.synchDQPC(quote,quote.BigMachines__Opportunity__c);
        Test.stopTest();
    }
    
    static testMethod void Test6(){
        List<BigMachines__Quote__c> quote = [Select id from BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_PC 
                                       AND Renewal_Subscription_Term__c='Automatic Monthly' AND Billing_Category__c != 'M2M' order by lastmodifieddate desc limit 1];
        Test.startTest();
        if ( !quote.isEmpty())
           DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote[0].id); 
        Test.stopTest();
    }
    
    static testMethod void TestCate1(){
        List<BigMachines__Quote__c> quote = [Select id from BigMachines__Quote__c where Renewal_Subscription_Term__c='Automatic Initial Subscription' AND Billing_Category__c != 'M2M' order by lastmodifieddate desc limit 1];
        Test.startTest();
          if ( !quote.isEmpty())
              DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote[0].id); 
        Test.stopTest();
    }
    
    static testMethod void TestCate2(){
        List<BigMachines__Quote__c> quote = [Select id from BigMachines__Quote__c where Offering_Type__c = :QuoteUtil.OFFERING_TYPE_PC 
                                       AND Renewal_Subscription_Term__c='No Auto-Renewal' AND Billing_Category__c != 'M2M' order by lastmodifieddate desc limit 1];
        Test.startTest();
        if ( !quote.isEmpty())
          DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote[0].id); 
        Test.stopTest();
    }
 
}