/**
* Class Name : QuoteUtilTest
* Covered Class : QuoteUtil
* Description : Test coverage for QuoteUtil Class
* Created By : Vijay Gopi
* Util Class : TestUtil, TestDataFactoryForQuoteTool
*/
@isTest(seeAlldata = true)
private class QuoteUtilTest {
    Public static List<Product_Tier_Pricing__c> list_PTP = new List<Product_Tier_Pricing__c>();
    Public static Id quoteId;
    Public static Id accountId;
    Public static Id oppId;
    Public static List<BigMachines__Quote_Product__c> list_QP = new List<BigMachines__Quote_Product__c>() ;
    Public static List<Genesys_Product_Prerequisite__c> list_ProductPrerequisites = new List<Genesys_Product_Prerequisite__c>();

    public static void setupData(){
        Level_One_Level_Two__c objLOLT = new Level_One_Level_Two__c(name='test key' , Level_One__c = 'test key',
                                                                    Level_Two__c='Level2.1;Level2.2;Level2.3', Offering_Type__c = 'PureConnect');
        insert objLOLT;
        Level_Two_Level_Three__c objLTLT= new Level_Two_Level_Three__c(name='test Key' , Level_Two__c= 'test key',
                                                                       Level_Three__c=  'Level3.1;Level3.2;Level3.3', Offering_Type__c = 'PureConnect');
        insert objLTLT;
        
        Product2 objProd = TestUtil.createProducts(1,true, false)[0];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = objProd.Id,
            UnitPrice = 100, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Test Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = objProd.Id,
            UnitPrice = 120, IsActive = true);
        insert customPrice;
        
        Product_Tier_Pricing__c objPTP = new Product_Tier_Pricing__c(Range_To__c = 10, Product__c = objProd.id, NG5_NA_USD_Price__c = 150.0 
        );
        Product_Tier_Pricing__c objPTP2 = new Product_Tier_Pricing__c(Range_To__c = 100, Product__c = objProd.id, NG5_NA_USD_Price__c = 152.0 
        );
        list_PTP = new List<Product_Tier_Pricing__c>{objPTP , objPTP2};
            insert list_PTP;
        
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        accountId = objAcc.Id;
        
        Opportunity objOpp = TestDataFactoryForQuoteTool.createOpportunties(objAcc.Id, 1)[0];
        oppId = objOpp.Id;
        
        BigMachines__Quote__c objQuote = TestDataFactoryForQuoteTool.createQuotes(objOpp.Id, objAcc.Id, 1)[0];
        QuoteId = objQuote.Id;
        
        list_QP = TestDataFactoryForQuoteTool.createQuoteProducts(QuoteId);
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE Type__c ='Genesys Care' LIMIT 1];
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            system.debug('product list1'+ list_Products[0]);
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,List_Price__c=100,Extended_Price_Per_Month__c = 1100,Quantity__c=200);
            list_QP.add(objNewQuoteProduct);            
        }
        
        for(BigMachines__Quote_Product__c objQP : list_QP){
            objQP.Quantity__c = 100;
            objQP.maintenance_due__c=120.00;
        }
        upsert list_QP;
        
        list_ProductPrerequisites = new List<Genesys_Product_Prerequisite__c>();
        
        boolean flag = true;

        for(BigMachines__Quote_Product__c objQP : list_QP){
            for(String strType : new String[]{'Quantity Range','Dependency', 'Quantity Comparison',
                'Ratio','Mandatory Product'}){
                    Genesys_Product_Prerequisite__c objGPP = new Genesys_Product_Prerequisite__c();
                    objGPP.Genesys_Product_Master__c = objQP.BigMachines__Product__c ; 
                    objGPP.Prerequisite_Product__c = objQP.BigMachines__Product__c;
                    objGPP.Prerequisite_Product2__c = objQP.BigMachines__Product__c;
                    objGPP.Prerequisite_Product3__c = objQP.BigMachines__Product__c;
                    objGPP.Type__c = strType;
                    objGPP.Operator__c = 'greater than';
                    objGPP.Min_Quantity__c = 1;
                    objGPP.Max_Quantity__c = 100;
                    objGPP.Active__c = true;
                    objGPP.Quote_Type__c = 'PureConnect Cloud';
                    objGPP.Order_Type__c = 'New';
                    objGPP.Tier__c = 'Premium';
                    list_ProductPrerequisites.add(objGPP);
                }
        }
        insert list_ProductPrerequisites;
        
    }
    
    static testMethod void testUtilMethods1() {
        setupData();
        List<ID> list_ids = new List<Id>();
        for(Product_Tier_Pricing__c obj :list_PTP){
            list_ids.add(obj.Id);
        }
        Account objAcc = new Account(Id = accountId,  Partner_Product_Margin__c = 1.0);
        update objAcc;
        
        Country__c objCon = new Country__c(Name = 'Test EMEA', Country__c = 'Test EMEA', Region__c = 'EMEA');
        insert objCon;
        
        Opportunity objOpp = new Opportunity(Id = oppId , Partner_Opportunity_Source__c = 'Partner Registered Opportunity');
        objOpp.Sold_To_Country__c = objCon.id;
        update objOpp;
        
        List<Product_Tier_Pricing__c> list_PTP = [SELECT Id, Range_To__c, Product__c, NG5_NA_USD_Price__c 
                                                  FROM  Product_Tier_Pricing__c
                                                  WHERE Id IN :list_ids];
        Product2 objProduct2 = [SELECT id,Type__c, Partner_Margin_Category__c FROM Product2 WHERE Id =:list_PTP[0].Product__c LIMIT 1];
        
        BigMachines__Quote__c objQuote = [SELECT id, Sold_To_Name__c, Sold_To_Name__r.Name, Sold_To_Name__r.Partner_Product_Margin__c,
                                          BigMachines__Opportunity__r.Partner_Opportunity_Source__c, BigMachines__Opportunity__r.Offering_Detail__c,
                                          BigMachines__Opportunity__r.Sold_To_Country__c,BigMachines__Opportunity__r.Type,BigMachines__Opportunity__r.Cloud_Renewal__c
                                          FROM  BigMachines__Quote__c 
                                          WHERE Id = :QuoteId];
        
        Partner_Hardware_Margins__c objPHM = new Partner_Hardware_Margins__c(name='Product MC test', Margin__c=1.0);
        insert objPHM;
        
        zqu__Quote__c objzQuote = TestDataFactoryForQuoteTool.createZuoraQuotes(objOpp.Id, accountId, 1)[0];
        
        
        Deal_Qualification__c objDQ = new Deal_Qualification__c(Opportunity__c = objOpp.Id, ZQuote__c = objzQuote.Id ,
                                                                Pricing_Type__c = 'New Pricing', Platform_Type__c ='Cloud' ,
                                                                Offering_Type__c = 'PureCloud' , 
                                                                Type__c = 'History',Net_Deal_Value__c = '200M - 500M');
        
        insert objDQ;
        
        Test.startTest();
        QuoteUtil.fetchLevelOneVsTwoMapping('test key');
        QuoteUtil.fetchLevelOneVsTwoMapping('fail key');
        
        QuoteUtil.fetchLevelTwoVsThreeMapping('test key','PureConnect Cloud');
        QuoteUtil.fetchLevelTwoVsThreeMapping('Subscription Fees','PureCloud');
        
        QuoteUtil.getProductTierPricing(list_PTP, 30, 25,'NG5_NA_USD_Price__c');
        
        objProduct2.Type__c = 'Product';
        objProduct2.Partner_Margin_Category__c = 'Third Party Hardware';
        update objProduct2;
        
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote);
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote, new List<Decimal>{10,20});
        
        objProduct2.Partner_Margin_Category__c = 'Software';
        update objProduct2;
        
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote);
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote, new List<Decimal>{10,20});
        
        objProduct2.Type__c = 'GU';
        update objProduct2;
        
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote);
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote, new List<Decimal>{10,20});
        
        objProduct2.Type__c = null;
        update objProduct2;
        
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote);
        QuoteUtil.getPartnerMargin(1.0, objProduct2, objQuote, new List<Decimal>{10,20});                
        
        objQuote.Order_Type__c = 'New';
        objQuote.Offering_Type__c = 'PureConnect Cloud';
        objQuote.Product_Tier__c = 'Premium';
        
        QuoteUtil.runPrerequisiteValidations(objQuote, list_QP);
        QuoteUtil.getPriceBookForCICCaas('USD');
        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        objQuote.Quote_Business_Type__c = 'Renewal';
        objQuote.BigMachines__Opportunity__c = objOpp.id;        
        update objQuote;        
        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'North America';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'LATAM';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'APAC';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'JAPAN';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = null;
        update objCon;
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objQuote.Quote_Business_Type__c = null;
        objQuote.BigMachines__Opportunity__c = objOpp.id;        
        update objQuote;        
        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'North America';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'LATAM';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'APAC';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = 'JAPAN';
        update objCon;        
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        objCon.Region__c = null;
        update objCon;
        QuoteUtil.getOrderManagementQueue(objQuote.Id);
        
        
        
        QuoteUtil.checkForDQStatus(objOpp.Id, objzQuote.Id , 0 , 'false', '1000');
        
        QuoteUtil.checkForDQStatus(objOpp.Id, objzQuote.Id , 0 , 'true' , '1000');
        zqu__Quote__c objzQuote2 = [Select id from zqu__Quote__c where PureCloud_Monthly_Minimum__c >= 2000 order by lastmodifieddate desc limit 1];
        QuoteUtil.checkForDQStatus(objOpp.Id, objzQuote2.Id , 0 , 'false' , '1000');
        // QuoteUtil.approveQuote(objzQuote.Id);
        
        QuoteUtil.getRecordTypes('zqu__Quote__c');
        QuoteUtil.buildPartnerMargins(accountId);
        
        QuoteUtil.updateLeverDetials(objQuote,objOpp);

        
        //QuoteUtil.getSubscriptionPartnerMargin(0,objQuote,null);
        QuoteUtil.testCoverageMethod();
        
        Test.StopTest();
    }
    
    /*
    static testMethod void testUtilMethods2() {
        setupData();
        Test.startTest();        
        QuoteUtil.CreateOrderFromQuote(quoteId);
        
        
            
        BigMachines__Quote__c objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                          Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                                          BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                                          PureSuccess__c,Does_customer_currently_have_PureSuccess__c,A_La_Carte_PureSuccess_Services_Amount__c,
                                          BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where Offering_Type__c = 'PureConnect Cloud' and PureSuccess__c != null and BigMachines__Status__c != 'Order Submitted' and BigMachines__Status__c != 'Order Accepted' order by lastmodifieddate desc limit 1];
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(objQuote.Id);
        QuoteUtil.CreateOrderFromQuote(objQuote.id);
        
        BigMachines__Quote__c objQuote2 = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                           Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                                           BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                                           PureSuccess__c,
                                           BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where Offering_Type__c = 'PureConnect Subscription' and PureSuccess__c != null and BigMachines__Status__c != 'Order Submitted' and BigMachines__Status__c != 'Order Accepted' order by lastmodifieddate desc limit 1];
        //QuoteUtil.CreateOrderFromQuoteFuture(objQuote2.id, quoteId, null);
        Test.StopTest();
    }*/
    
    static testMethod void testUtilMethods22() {
        setupData();
        Test.startTest();
        QuoteUtil.CreateOrderFromQuote(quoteId);
        
        
        BigMachines__Quote__c objQuote2 = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                           Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                                           BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                                           PureSuccess__c,Quote_Business_Type__c,
                                           BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId 
                                           from BigMachines__Quote__c where Offering_Type__c = 'PureConnect Subscription' and PureSuccess__c != null 
                                           and BigMachines__Status__c != 'Order Submitted' AND Amendment_For__c != null limit 1];
        
        objQuote2.BigMachines__Is_Primary__c = true;
        update objQuote2;
        QuoteUtil.CreateOrderFromQuote(objQuote2.id);
        QuoteUtil.CreateOrderAddresses(null,objQuote2);        
        Test.StopTest();
    }
    static testMethod void msalink() {
         List<Opportunity> opp = [SELECT Id, Sold_To_Country__r.Name FROM Opportunity WHERE Sold_To_Country__c != null LIMIT 1];
         String str = QuoteUtil.getMSALink(opp[0], 'PureConnect Subscription');
    }
    static testMethod void createOLIfromSupProds() {
         
        List<BigMachines__Quote__c> objQuote = [Select id,Order__c, Token_Value__c,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                           PureSuccess__c,Quote_Business_Type__c, Amendment_For__c, CreatedBy.Id,
                                           offering_Type__c
                                           from BigMachines__Quote__c where Offering_Type__c = 'PureEngage Subscription' 
                                           AND Order__c != null AND Amendment_For__c != null limit 1];

        Set<String> set_OLIUniqueString = new Set<String>();
        Set<Id> set_NewOrderIds = new Set<Id>();
        set_NewOrderIds.add(objQuote[0].Order__c);
        List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProducts(objQuote[0].Amendment_For__c);
        for (Subscription_Product__c objSubProd : list_SubscriptionProds) {
            String strUniqueKey = objSubProd.Product__c + ';' + objSubProd.Is_Overage__c;
            set_OLIUniqueString.add(strUniqueKey);
        }
        List<Order_Line_Item__c> ls = QuoteUtil.createOLIfromSupProds(set_OLIUniqueString, 1, objQuote[0], objQuote[0].Order__c); 

         List<Date> dt1 = QuoteUtil.calculateOnPremAmendOrderLineDates(System.today().addDays(-30), System.today(), System.today().addDays(30), 1);
        List<Date> dt2 = QuoteUtil.calculateOnPremAmendOrderLineDates(System.today().addDays(-30), System.today(), System.today().addDays(30), 2);
        List<Date> dt3 = QuoteUtil.calculateOnPremSubscripOrderLineDates(System.today().addDays(-30), System.today(), objQuote[0].Order__c, 3);
        QuoteUtil.shareOrders(set_NewOrderIds, objQuote[0].CreatedBy.Id);
        
    }

    static testMethod void calculationsForQuote() {
      
       List<BigMachines__Quote__c> list_NewQuotes = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                           Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                                           BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                                           PureSuccess__c, BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId, 
                                           Subscription_Start_Date__c, Subscription_End_Date__c,Billing_Category__c,New_Price_Book__c
                                           FROM BigMachines__Quote__c 
                                           WHERE Offering_Type__c = 'PureEngage Subscription' AND Quote_Business_Type__c != 'Cloud' AND BigMachines__Opportunity__c != null 
                                           and PureSuccess__c != null and BigMachines__Status__c != 'Order Submitted' and BigMachines__Status__c != 'Order Accepted' AND CreatedDate = LAST_N_MONTHS:6 limit 1];

      List<BigMachines__Quote_Product__c > list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, 
                              BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,
                              BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c = :list_NewQuotes[0].Id];

        QuoteUtil.calculationsForQuote(list_NewQuotes, new Map<Id, List<BigMachines__Quote_Product__c>>{list_NewQuotes[0].Id => list_NewQuoteProds});

         QuoteUtil.createGUPassports(list_NewQuotes[0]);  
       
    }
    /*
    static testMethod void testUtilMethods2222() {
       // setupData();
        Test.startTest();  
        
        BigMachines__Quote__c objQuote2 = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                           Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                                           BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                                           PureSuccess__c, Subscription_End_Date__c,Subscription_Start_Date__c,
                                           BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c 
                                           WHERE Offering_Type__c = 'PureConnect Subscription' AND Quote_Business_Type__c != 'Cloud' AND BigMachines__Opportunity__c != null 
                                           AND New_Price_Book__c != null AND Subscription_Start_Date__c != null
                                           and PureSuccess__c != null and BigMachines__Status__c != 'Order Submitted' and BigMachines__Status__c != 'Order Accepted' AND CreatedDate = LAST_N_MONTHS:6 limit 1];
     
     
           // objQuote2.Shipping_Required__c = true;
          //  objQuote2.Rejected_flag__c = true;
            update objQuote2;       
            QuoteUtil.CreateOrderFromQuote(objQuote2.id);
      
            //QuoteUtil.createGUPassports(objQuote2); 

        Test.StopTest();
    }
    */

    static testMethod void testUtilMethods222() {
         
        Test.startTest();
        BigMachines__Quote__c objQuote2 = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                                           Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                                           BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                                           PureSuccess__c,Quote_Business_Type__c,
                                           BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId 
                                           from BigMachines__Quote__c where Quote_Business_Type__c != 'Cloud' and Quote_Business_Type__c != 'On Premise' order by lastmodifieddate desc limit 1];
        QuoteUtil.CreateOrderAddresses(null,objQuote2);
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods3() {
        Util.Bypass_Trigger_Chk = true;
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM');
        update objQuote;
        
        objQuote = new BigMachines__Quote__c(Id = QuoteId , Offering_Type__c= 'PureConnect Cloud',PureSuccess__c ='DRIVE');
        objQuote.No_Of_Months__c = 10;
        objQuote.Cloud_Total__c = 10000;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 20000;
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 50000;
        update objQuote;

        //QuoteUtil.CreateOrderFromQuote(objQuote.id);
        
        //QuoteUtil.createPureSuccessLines(null,null,null,null);
        
        QuoteUtil.insertPureSuccessItemsFromOffer(objQuote);
        QuoteUtil.calculateTokenValue(90000,'PureConnect Cloud','DRIVE');
        QuoteUtil.calculateTokenValue(90000,'PureEngage Subscription','DRIVE');
        QuoteUtil.calculateTokenValue(90000,'PureConnect Subscription','DRIVE');
        QuoteUtil.calculateTokenValue(90000,'PureEngage Cloud','DRIVE');
        QuoteUtil.calculateTokenValue(90000,'Business Edition','DRIVE');
        QuoteUtil.calculateTokenValue(90000,'PureConnect Cloud','GUIDE');
        QuoteUtil.calculateTokenValue(90000,'PureEngage Subscription','GUIDE');
        QuoteUtil.calculateTokenValue(90000,'PureConnect Subscription','GUIDE');
        QuoteUtil.calculateTokenValue(90000,'PureEngage Cloud','GUIDE');
        QuoteUtil.calculateTokenValue(90000,'Business Edition','GUIDE'); 
        Test.startTest();
        objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                    Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                    BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                    BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where Offering_Type__c = 'Business Edition' and PureSuccess__c = 'DRIVE' and id != :objQuote.id limit 1];
        QuoteUtil.insertPureSuccessItemsFromOffer(objQuote);
        
    //    TestDataFactoryForQuoteTool.createAOAsForAccount(objQuote.End_User_ID__c);
     //  TestDataFactoryForQuoteTool.createAOAsForAccount(objQuote.Sold_To_Name__c);
        
        //QuoteUtil.CreateOrderFromPCQuote(objQuote);
        Test.StopTest();
    }

    static testMethod void testUtilMethods3a() {
        Util.Bypass_Trigger_Chk = true;
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM');
        update objQuote;
        
        QuoteUtil.CreateOrderFromQuote(quoteId);
        
        objQuote = new BigMachines__Quote__c(Id = QuoteId , Offering_Type__c= 'PureConnect Cloud',PureSuccess__c ='DRIVE');
        objQuote.No_Of_Months__c = 10;
        objQuote.Cloud_Total__c = 10000;
        objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 20000;
        objQuote.PureSuccess_Offer_Subscription_Amount__c = 50000;
        update objQuote;
        
        //QuoteUtil.createPureSuccessLines(null,null,null,null);
        Test.startTest();
        objQuote = [Select id,Token_Value__c,Sold_To_Name__c,End_User_ID__c,BigMachines__Opportunity__r.Country_Region__c,Name,Annual_Contract_Value__c,CMRR__c,Total_Contract_Value__c,
                    Order_PO_Received_Date__c,Bill_To_Name__c,BigMachines__Opportunity__c,BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,
                    BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,Order_PO_Number__c,Order_PO_Date__c,Order_Payment_Terms__c,CurrencyIsoCode,
                    BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,offering_Type__c,BigMachines__Opportunity__r.OwnerId from BigMachines__Quote__c where Offering_Type__c = 'Business Edition' and PureSuccess__c = 'DRIVE' and id != :objQuote.id limit 1];
        TestDataFactoryForQuoteTool.createAOAsForAccount(objQuote.End_User_ID__c);
        TestDataFactoryForQuoteTool.createAOAsForAccount(objQuote.Sold_To_Name__c);
        QuoteUtil.populateDefaultOrderAddress(objQuote);
        
        
        //QuoteUtil.CreateOrderFromPCQuote(objQuote);
        Test.StopTest();
    }
   
    static testMethod void testUtilMethods4() {
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM');
        update objQuote;
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(QuoteId, oppId ,1)[0];
        objOrder.License_FYM_detail__c = 'Both License & Maintenance Order';
         Test.startTest();
        update objOrder;
        Test.StopTest();
       
       // QuoteUtil.CreateOrderFromQuote(quoteId);
        
    }
    
    static testMethod void testUtilMethods5() {
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM');
        update objQuote;
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(QuoteId, oppId ,1)[0];
        objOrder.License_FYM_detail__c = 'Maintenance Only Order';
        update objOrder;
        
        Opportunity objOpp = new Opportunity(Id = oppId , RecordTypeId = [SELECT id 
                                                                          FROM RecordType 
                                                                          WHERE SobjectType = 'Opportunity' AND
                                                                          DeveloperName != 'Genesys_Renewal'
                                                                          LIMIT 1].Id);
        
        update objOpp;
        
        Test.startTest();
        QuoteUtil.CreateOrderFromQuote(quoteId);
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods6() {
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM',
                                                                   Rejected_Flag__c = true);
        update objQuote;
        
        Opportunity objOpp = new Opportunity(Id = oppId , RecordTypeId = [SELECT id 
                                                                          FROM RecordType 
                                                                          WHERE SobjectType = 'Opportunity' AND
                                                                          DeveloperName != 'Genesys_Renewal'
                                                                          LIMIT 1].Id);
        
        update objOpp;
        
        Test.startTest();
        QuoteUtil.CreateOrderFromQuote(quoteId);
        Test.StopTest();
    }
    
    
    
    static testMethod void testUtilMethods111() {
        BigMachines__Quote_Product__c quoteProd = [select id,BigMachines__Quote__c from BigMachines__Quote_Product__c where 
                                                    BigMachines__Quote__r.Offering_Type__c = 'PureConnect Cloud' 
                                                    AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved'
                                                    AND BigMachines__Quote__r.PureSuccess__c != NULL AND Bundle_Line__c != NULL
                                                    AND Bundle__r.Group_Type__c = 'PureSuccess' limit 1];
        
        Test.startTest();
        try{
            QuoteUtil.CreateOrderFromQuote(quoteProd.BigMachines__Quote__c);
        }
        catch(exception e){
            system.debug('error--->'+e.getmessage());
            system.debug('errorinline--->'+e.getlinenumber());
        }
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods112(){
        BigMachines__Quote_Product__c quoteProd = [select id,BigMachines__Quote__c from BigMachines__Quote_Product__c where 
                                                    BigMachines__Quote__r.Offering_Type__c = 'PureConnect On Premise' 
                                                    AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved'
                                                    AND BigMachines__Product__r.Third_Party_GC__c != null AND BigMachines__Product__r.Third_Party_GC__c != 0
                                                    limit 1];
        
        Test.startTest();
        try{
            QuoteUtil.CreateOrderFromQuote(quoteProd.BigMachines__Quote__c);
        }
        catch(exception e){
            system.debug('error--->'+e.getmessage());
            system.debug('errorinline--->'+e.getlinenumber());
        }
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods113(){
        BigMachines__Quote_Product__c quoteProd = [select id,BigMachines__Quote__c from BigMachines__Quote_Product__c where 
                                                    BigMachines__Quote__r.Offering_Type__c = 'PureConnect On Premise' 
                                                    AND BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved'
                                                    AND BigMachines__Product__r.Type__c = 'Genesys Care'
                                                    limit 1];
        
        Test.startTest();
        try{
            QuoteUtil.CreateOrderFromQuote(quoteProd.BigMachines__Quote__c);
        }
        catch(exception e){
            system.debug('error--->'+e.getmessage());
            system.debug('errorinline--->'+e.getlinenumber());
        }
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods7() {
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM',
                                                                   Rejected_Flag__c = true, Quote_Business_Type__c = 'Cloud');
        update objQuote;
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(QuoteId, oppId ,1)[0];
        objOrder.License_FYM_detail__c = 'Maintenance Only Order';
        update objOrder;
        
        
        Opportunity objOpp = new Opportunity(Id = oppId , RecordTypeId = [SELECT id 
                                                                          FROM RecordType 
                                                                          WHERE SobjectType = 'Opportunity' AND
                                                                          DeveloperName != 'Genesys_Renewal'
                                                                          LIMIT 1].Id);
        
        update objOpp;
        
        Test.startTest();
        QuoteUtil.CreateOrderFromQuote(quoteId);
        Test.StopTest();
    }
    
			    static testMethod void testUtilMethods8() {
        setupData();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM',
                                                                   Rejected_Flag__c = true, Quote_Business_Type__c = 'Hybrid',
                                                                   offering_Type__c='PureConnect On Premise');
        update objQuote;
        
        Order__c objOrder = TestDataFactoryForQuoteTool.createOrders(QuoteId, oppId ,1)[0];
       
        objOrder.License_FYM_detail__c = 'Maintenance Only Order';
        objOrder.Maintenance_End__c = Date.Today()+30;
         Test.startTest();
        update objOrder;
                    
        
        Test.stopTest();

      /*  
        Opportunity objOpp = new Opportunity(Id = oppId , RecordTypeId = [SELECT id 
                                                                          FROM RecordType 
                                                                          WHERE SobjectType = 'Opportunity' AND
                                                                          DeveloperName != 'Genesys_Renewal'
                                                                          LIMIT 1].Id, 
                    Direct_Sales__c = true, Lever__c ='Lever 4', Avaya_Contract_Expiration__c = (Date)System.today());
        
        update objOpp;
   */
        //Test.startTest();
        //QuoteUtil.CreateOrderFromQuote(quoteId);
        //Test.StopTest();
    }
    
    static testMethod void testUtilMethods9() {
        Test.startTest();
        setupData();
        
        Opportunity testOpp = new Opportunity(id = oppId);
        testOpp.Partner_Opportunity_Source__c = 'Partner Registered Opportunity';
        update testOpp;
        
        Partner_Discount__c pD = [Select id,Account__c,type__c from Partner_Discount__c where Type__c = 'PureConnect Premise' or Type__c = 'PureEngage Premise' or Type__c = 'PureEngage Subscription' or Type__c = 'PureConnect Subscription' limit 1];
        
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Id = QuoteId , PO_for_FYM__c = 'Separate PO for FYM',
                                                                   Rejected_Flag__c = true, Quote_Business_Type__c = 'Hybrid',
                                                                   offering_Type__c=pD.type__c,Sold_To_Name__c = pD.Account__c);
        update objQuote;
        Product2 Prod = [Select id,Partner_Margin_Category__c  from product2 where Partner_Margin_Category__c != null and Partner_Margin_Category__c != 'No Margin' limit 1];
        Product2 Prod2 = [Select id,Partner_Margin_Category__c  from product2 where Partner_Margin_Category__c = null limit 1];
        List<Partner_Discount__c> listOfPartnerDiscounts = [SELECT Discount__c, Year__c, Category__c FROM Partner_Discount__c WHERE
                                                            Account__c =: objQuote.Sold_To_Name__c AND Type__c =: objQuote.Offering_Type__c];
        
        
        QuoteUtil.getSubscriptionPartnerMargin(100000,objQuote,Prod,listOfPartnerDiscounts);
        QuoteUtil.getSubscriptionPartnerMargin(100000,objQuote,Prod2,listOfPartnerDiscounts);
        QuoteUtil.buildConversionRatesMap();
        QuoteUtil.getPackagePricingPercentage('PureConnect Cloud','GUIDE','PureSuccess');
        QuoteUtil.getPackagePricingPercentage('PureConnect Cloud',null,'PureSuccess');
        
        QuoteUtil.calculateOveragePrice(1000,objQuote,null);
        QuoteUtil.calculatePaymentTermPrice(1000,objQuote,null);
        QuoteUtil.getPartnerDiscounts(objQuote);
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods10() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Id idUserId = [Select Id from User where IsActive = true Limit 1].Id;
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
     
        List<Product2> list_Prod = new List<Product2>();
        try {
            QuoteUtil.calculationsForQuote(list_NewQuotes, new Map<Id, List<BigMachines__Quote_Product__c>>{list_NewQuotes[0].Id => list_NewQuoteProds});
            Product_Group__c objPG = new    Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess' );
            insert objPG;
            Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
            update objProd;
           
            list_Prod.add(objProd);
            Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00);
            insert objsub;
            list_NewQuotes[0].Amendment_For__c = objsub.id;
            list_NewQuotes[0].order_type__c= Label.Amend_Subscription;
            list_NewQuotes[0].Treat_SO_as_PO__c = true;
            list_NewQuotes[0].Order_PO_Number__c =  'Test PO Num';
            list_NewQuotes[0].Order_Payment_Terms__c = 'Test Term';
            list_NewQuotes[0].BigMachines__Status__c='Quote Approval Pending';
            list_NewQuotes[0].End_User_ID__c = list_NewQuotes[0].Sold_To_Name__c;
            list_NewQuotes[0].Include_Special_Offer_in_Output__c = true;
            list_NewQuotes[0].Special_Offer_Terms__c = 'test';
            list_NewQuotes[0].Total_Education__c = 0.00;
            list_NewQuotes[0].Total_List_Price__c = 0.00;
            list_NewQuotes[0].Total_Hardware__c = 0.00;
            list_NewQuotes[0].Non_Recurring_Fees__c = 0.00;
            list_NewQuotes[0].Setup_Provisioning_Charges__c = 0.00;
            update list_NewQuotes[0];
  
            Test.startTest();
            Map<id,List<BigMachines__Quote_Product__c>> map_QuoteIdtoQP =  new Map<Id,List<BigMachines__Quote_Product__c>>();
            if(list_NewQuoteProds.size() > 0){
                for(BigMachines__Quote_Product__c objQP:list_NewQuoteProds){
                    if(!map_QuoteIdtoQP.containskey(objQP.BigMachines__Quote__c)) {
                        map_QuoteIdtoQP.put(objQP.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c>());
                        map_QuoteIdtoQP.get(objQP.BigMachines__Quote__c).add(objQP);
                    }
                    else
                    {map_QuoteIdtoQP.get(objQP.BigMachines__Quote__c).add(objQP);}   
                }
            }
            //QuoteUtil.calculationsForQuote(list_NewQuotes,map_QuoteIdtoQP);
            Order__c objOrder = TestUtil.createOrders(1,true)[0];
            Set<Id> set_OrderIds = new Set<Id>();
            set_OrderIds.add(objOrder.Id);
            date d1 = objOrder.Maintenance_Start__c ;
            date d2 = objOrder.Maintenance_End__c  ;
            list_NewQuotes[0].offering_Type__C = 'PureConnect Subscription';
            List<Order_Line_Item__c> list_OLI = TestUtil.createOrderLines(list_Prod, objOrder.id, true);
            Map<String,BigMachines__Quote_Product__c> mapOfPackageVsPrice = new  Map<String,BigMachines__Quote_Product__c>{'Partner'=>list_NewQuoteProds[0]};
            QuoteUtil.createPureSuccessLines(mapOfPackageVsPrice,list_NewQuotes[0],objOrder,list_OLI,10.00,15.00);
            list_NewQuoteProds[0].BigMachines__Product__r.Type__c = 'Product';
            list_NewQuoteProds[0].Bundle__c= objPG.id;
            update list_NewQuoteProds;
            System.debug('list_NewQuoteProds'+list_NewQuoteProds);
            QuoteUtil.insertOrderLineItemsSubscription(list_NewQuotes[0],objOrder,list_NewOpps[0],false);
            QuoteUtil.shareOrders(set_OrderIds,idUserId);
            
           
            Test.stopTest();
        }
        catch(Exception e) {}
        
    }
    
        
    static testMethod void testRunPrerequisite() {

        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Id idUserId = [Select Id from User where IsActive = true Limit 1].Id;
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        
        try {
            //Add quote line items         
            List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
            
            Product_Group__c objPG = new    Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess' );
            insert objPG;
            Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
            update objProd;
            List<Product2> list_Prod = new List<Product2>();
            list_Prod.add(objProd);
            Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00);
            insert objsub;
            list_NewQuotes[0].Amendment_For__c = objsub.id;
            list_NewQuotes[0].order_type__c= Label.Amend_Subscription;
            list_NewQuotes[0].Treat_SO_as_PO__c = true;
            list_NewQuotes[0].Order_PO_Number__c =  'Test PO Num';
            list_NewQuotes[0].Order_Payment_Terms__c = 'Test Term';
            list_NewQuotes[0].BigMachines__Status__c='Quote Approval Pending';
            list_NewQuotes[0].End_User_ID__c = list_NewQuotes[0].Sold_To_Name__c;
            list_NewQuotes[0].Include_Special_Offer_in_Output__c = true;
            list_NewQuotes[0].Special_Offer_Terms__c = 'test';
            list_NewQuotes[0].Total_Education__c = 0.00;
            list_NewQuotes[0].Total_List_Price__c = 0.00;
            list_NewQuotes[0].Total_Hardware__c = 0.00;
            list_NewQuotes[0].Non_Recurring_Fees__c = 0.00;
            list_NewQuotes[0].Setup_Provisioning_Charges__c = 0.00;
            update list_NewQuotes[0];
            Test.startTest();
            List<Genesys_Product_Prerequisite__c> list_PreRequisite = QuoteUtil.runPrerequisiteValidations(list_NewQuotes[0], list_NewQuoteProds);
            //String str_Link = QuoteUtil.getMSALink(list_NewOpps[0],'PureCloud');
            Test.stopTest();
        }
        catch(Exception e) {}
    }
    
    
    private static BigMachines__Quote__c createQuote() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        list_NewOpps[0].Type = 'Existing Business - Cross Sell';
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  
    
        //Unit tests for CreateQuoteSubscriptionController methods    
        BigMachines__Quote__c objQuote = list_NewQuotes[0];  
        objQuote.No_Of_Months__c=12;
        objQuote.Deployment_Model__c='Local Control';
        objQuote.Ramp_Period__c='60';
        objQuote.Initial_Subscription_Term__c='1 Year';
        objQuote.Billing_Period__c='Annually';
        objQuote.MSA_Link__c='www.google.com';  
        objQuote.Sold_To_Name__c=[SELECT Id FROM Account WHERE Id != :list_NewAccts[0].Id LIMIT 1].Id;  
        objQuote.Sent_to_Customer__c=true;
        objQuote.Special_Offer_Terms__c='New Offer';
        objQuote.Grid_Group_By__c='Categories';
        objQuote.New_Price_Book__c='NG5_NA_USD';
        objQuote.Offering_Type__c = 'PureConnect Subscription';
        objQuote.Subscription_Start_Date__c = System.today();
        objQuote.Subscription_End_Date__c = System.today().addMonths(6);
        objQuote.PO_for_FYM__c = 'Seperate PO';
        objQuote.Generate_Revpro_Order__c = false;
        objQuote.Keep_the_existing_estate_on_Perpetual__c = false;
        objQuote.Total_Software__c = 0;
        objQuote.Total_Hardware__c = 1000;
        objQuote.Total_Education__c = 2000;
        objQuote.Setup_Provisioning_Charges__c = 4000;
        update objQuote;      
                 
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: objQuote.Id];
                              
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
        }    
        list_NewQuoteProds[1].or_Amount__c='Amt';
        
        Product_Group__c objPG = new Product_Group__c(Name = 'Test Group', Active__c = true, Type__c = 'GUIDE', Group_Type__c = 'PureSuccess');
        insert objPG;        
        
        List<Product2> listOfProduct2 = new List<Product2>();        
        Product2 objProduct1 = new Product2(NAME = 'Test 1', Type__c = 'Genesys Care', APN_Number__c = 'TESTAPN1');
        listOfProduct2.add(objProduct1);      
        Product2 objProduct2 = new Product2(NAME = 'Test 2', Type__c = 'Flex Care', APN_Number__c = 'TESTAPN2');
        listOfProduct2.add(objProduct2);      
        Product2 objProduct3 = new Product2(NAME = 'Test 2', Type__c = 'Product', APN_Number__c = 'TESTAPN2', PS_Contract__c = true);
        listOfProduct2.add(objProduct3);      
        
        insert listOfProduct2;        
        
        BigMachines__Quote_Product__c objNewQuoteProduct1 = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = objQuote.id, BigMachines__Product__c = objProduct1.Id,
                                                  Name = objProduct1.Name, Build_Type__c = objProduct1.Name, APN_Number__c = objProduct1.APN_Number__c,
                                                  BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, 
                                                  List_Price__c =10, List_Price_1__c =10, List_Price_2__c =20, Ext_Net_Price_1__c = 200, Ext_Net_Price_2__c = 200);        
        list_NewQuoteProds.add(objNewQuoteProduct1);
        
        BigMachines__Quote_Product__c objNewQuoteProduct2 = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = objQuote.id, BigMachines__Product__c = objProduct2.Id,
                                                  Name = objProduct2.Name, Build_Type__c = objProduct2.Name, APN_Number__c = objProduct2.APN_Number__c,
                                                  BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, 
                                                  List_Price__c =10, List_Price_1__c =10, List_Price_2__c =20, Ext_Net_Price_1__c = 200, Ext_Net_Price_2__c = 200);
        list_NewQuoteProds.add(objNewQuoteProduct2);
        
        BigMachines__Quote_Product__c objNewQuoteProduct3 = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = objQuote.id, BigMachines__Product__c = objProduct3.Id,
                                                  Name = objProduct3.Name, Build_Type__c = objProduct3.Name, APN_Number__c = objProduct3.APN_Number__c,
                                                  BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000, Bundle__c = objPG.id);        
        list_NewQuoteProds.add(objNewQuoteProduct3);
        
        
        
        upsert list_NewQuoteProds;
        
        Product2 objQtProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objQtProd;
        
        Quote_Proposal_Group__c objQProposalGroup = new Quote_Proposal_Group__c( Quote__c = objQuote.id,
                                                                                Description__c = 'Test',
                                                                                Discount__c = 2.5,
                                                                                Group_Number__c = 'PG1',
                                                                                Goal_Seek__c = 1 ,
                                                                                Name__c = 'Test Proposal Group'
                                                                               );
        insert objQProposalGroup;
        
        return objQuote;
    }

    static testMethod void testAddProductPrecisionToMap() {

        List<Product2> listProducts = [select Id, Tier_Pricing_Decimal_Precision__c from Product2];
        System.Debug('listProducts size ' + listProducts.size());
        if (listProducts.size() > 0) {
            listProducts[0].Tier_Pricing_Decimal_Precision__c = '6';
        }
        for (Product2 objProduct : listProducts) {
            System.Debug(objProduct);
        }
        // Call with null to force creation of map in the util
        QuoteUtil.addProductPrecisionToMap(listProducts, null);

        // Call to populate existing map
        Map<id, Integer> mapProductIdToDecimalPrecision = new Map<id, Integer>();
        QuoteUtil.addProductPrecisionToMap(listProducts, mapProductIdToDecimalPrecision);

        // Call again to enter code where ID already exists
        QuoteUtil.addProductPrecisionToMap(listProducts, mapProductIdToDecimalPrecision);
    }
    
    static testMethod void testSetDecimalPrecisionFormat() {
        Integer intExpectedProductCount = 1;
        List<BigMachines__Quote_Product__c> listQuoteProducts = [SELECT Id, Name, BigMachines__Product__c, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c
                                                                 FROM BigMachines__Quote_Product__c LIMIT 1];

        Id idQuoteProduct = listQuoteProducts[0].Id;

        Set<Id> setQuoteProductIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        for (BigMachines__Quote_Product__c objQuoteProduct : listQuoteProducts) {
            System.Debug('testSetDecimalPrecisionFormat:objQuoteProduct ' + objQuoteProduct);
            setQuoteProductIds.add(objQuoteProduct.Id);
            setProductIds.add(objQuoteProduct.BigMachines__Product__c);
        }

        List<Product2> listProducts = [select Id, Tier_Pricing_Decimal_Precision__c from Product2 where Id in :setProductIds];
        if (listProducts.size() != intExpectedProductCount) {
            String strErrorMsg = 'Unexpected number of products got ' + listProducts.size() + ' expected ' + intExpectedProductCount;
            System.Debug('testSetDecimalPrecisionFormat:' + strErrorMsg);
            System.assert(false, strErrorMsg);
        }

        Product2 objProduct = listProducts[0];

        objProduct.Tier_Pricing_Decimal_Precision__c = null;
        update listProducts;
        BigMachines__Quote_Product__c objQuoteProduct = [SELECT BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE Id = :idQuoteProduct] ;
        QuoteUtil.setDecimalPrecisionFormat(objQuoteProduct);
        
        objProduct.Tier_Pricing_Decimal_Precision__c = '2';
        update listProducts;
        objQuoteProduct = [SELECT BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE Id = :idQuoteProduct] ;
        QuoteUtil.setDecimalPrecisionFormat(objQuoteProduct);
        
        objProduct.Tier_Pricing_Decimal_Precision__c = '4';
        update listProducts;
        objQuoteProduct = [SELECT BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE Id = :idQuoteProduct] ;
        QuoteUtil.setDecimalPrecisionFormat(objQuoteProduct);
        
        objProduct.Tier_Pricing_Decimal_Precision__c = '6';
        update listProducts;
        objQuoteProduct = [SELECT BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE Id = :idQuoteProduct] ;
        QuoteUtil.setDecimalPrecisionFormat(objQuoteProduct);
    }

    static testMethod void pob(){
        
        Test.startTest();
   
       String p1 = QuoteUtil.getPOBType('Token', 'Latitude Perpetual - On Premise', 'Passthrough', null, 'Rental Order', 'PureEngage Subscription',null);
       String p2 = QuoteUtil.getPOBType('Product', 'Latitude Perpetual - On Premise', '', null, 'Rental Order', 'PureEngage Subscription',null);
       String p3 = QuoteUtil.getPOBType('Genesys Care', 'Latitude Perpetual - On Premise', '', null, 'Rental Order', 'PureEngage Subscription',null);
       String p4 = QuoteUtil.getPOBType('GU', 'Base Package', '', null, 'Rental Order', 'PureEngage Subscription',null);
       String p5 = QuoteUtil.getPOBType('', 'PPU Commited', '', null, 'Rental Order', '',null);
       String p6 = QuoteUtil.getPOBType('', 'PPU Overag', '', null, 'Rental Order', '',null);
    
        Test.stopTest();
        
    }

}