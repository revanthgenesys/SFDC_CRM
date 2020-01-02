@isTest(seeAlldata = true)
private class  QuoteCloudUtilTest {
    
    static testMethod void testUtilMethods1() {
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        
        Test.startTest();
        Account objAcc = TestDataFactoryForQuoteTool.createAccounts(1)[0];
        Id IdaccountId = objAcc.Id;
        QuoteCloudUtil.fetchLevelOneVsTwoMapping('test key');
        QuoteCloudUtil.fetchLevelOneVsTwoMapping('fail key');
        QuoteCloudUtil.fetchLevelTwoVsThreeMapping('test key','PureConnect Cloud');
        QuoteCloudUtil.fetchLevelTwoVsThreeMapping('Subscription Fees','PureCloud');
        QuoteCloudUtil.buildPartnerMargins(IdaccountId);
        Test.StopTest();
    }
    
    static testMethod void testUtilMethods2() {
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Id idUserId = [Select Id from User where IsActive = true and profileid='00eU0000000pPrrIAE' Limit 1].Id;
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        List<Account> list_NewPartnerAccts = TestDataFactoryForQuoteTool.createAccountspartner(1);
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
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c,APN_Number__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        Product_Group__c objPG = new    Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess' );
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles',Has_Overage__c = true );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4',Has_Overage__c = true );      
        insert objProd2;
        Product_Tier_Pricing__c objPT = new Product_Tier_Pricing__c(Charge_Type__c='M2M',Product__c=objProd.id, Range_To__c = 999, NG3_EMEA_USD_Price__c = 10.00);
        insert objPT;
        List<Product_Tier_Pricing__c> list_PTR = new list<Product_Tier_Pricing__c>();
        list_PTR.add(objPT);
        Set<Id> set_ProdIds =  new Set<Id>();
        set_ProdIds.add(objProd.Id);
        List<Product2> list_Prod = new List<Product2>();
        list_Prod.add(objProd);
        Product_Group__c objProdGroup = new Product_Group__c(Product__c = objProd.Id,Group_Type__c = 'Dependent Products');
        insert objProdGroup;
        Product_Group_Item__c objProdGrItem = new Product_Group_Item__c(Product_Group__c = objProdGroup.id,Product_Type__c = 'Mandatory',Product__c = objProd2.Id);
        insert objProdGrItem;
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00);
        insert objsub;
        Subscription_Product__c objSubProd = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = true,Product__c = list_Prod[0].id);
        insert objSubProd;
        Subscription_Product__c objSubProd2 = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = true,Product__c = list_Prod[0].id);
        insert objSubProd2;
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
        list_NewQuotes[0].Total_Software__c = 0.00;
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
        Order__c objOrder = TestUtil.createOrders(1,true)[0];
        Set<Id> set_OrderIds = new Set<Id>();
        set_OrderIds.add(objOrder.Id);
        list_NewQuotes[0].offering_Type__C = 'PureConnect Subscription';
        List<Order_Line_Item__c> list_OLI = TestUtil.createOrderLines(list_Prod, objOrder.id, true);
        list_NewQuoteProds[0].BigMachines__Product__r.Type__c = 'Product';
        list_NewQuoteProds[0].Bundle__c= objPG.id;
        list_NewQuoteProds[1].Extended_Price_Per_Month__c = 10.00;
        list_NewQuoteProds[0].Bundle_Line__c = list_NewQuoteProds[1].id;
        update list_NewQuoteProds;
        System.debug('list_NewQuoteProds'+list_NewQuoteProds);
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,Net_Unit_Price__c,BigMachines__Product__r.New_Category__c,
                              BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.APN_Number__c,Is_Overage__c,Quantity__c,Product_Description__c,Ext_List__c,Bundle__r.Type__c,APN_Number__c,
                              Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Ext_Net_Price__c,Total_Discount__c,BigMachines__Product__r.Include_in_Agent_Seat_Count__c,BigMachines__Product__r.Include_in_CMMR_Total__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        Map<String,BigMachines__Quote_Product__c> mapOfPackageVsPrice = new  Map<String,BigMachines__Quote_Product__c>{'Partner'=>list_NewQuoteProds[0]};
            Set<String> set_UniqueString =  new Set<String>();
        QuoteCloudUtil.buildQuoteProductsForRenewal(objSub.Id,list_NewQuotes[0]);
        QuoteCloudUtil.buildQuoteProductsForAmend(objSub.Id,list_NewQuotes[0]);
        QuoteCloudUtil.updateQuoteTotalsForRenewal(list_NewQuotes[0],list_NewQuoteProds);
        QuoteCloudUtil.updateOpportunityTotals(list_NewQuotes[0]);
        QuoteCloudUtil.createOpportunityLineItems(list_NewQuotes[0],list_NewQuoteProds,set_ProdIds);
        QuoteCloudUtil.getMSALink(list_NewOpps[0], 'PureCloud');
        QuoteCloudUtil.cloneAccountOrderAddresses(list_NewQuotes[0].id,list_NewQuotes[0].id);
        QuoteCloudUtil.prepareQuoteProducts(list_NewQuotes[0].id);
        QuoteCloudUtil.getRecordTypes('Opportunity');
        QuoteCloudUtil.PreparePBEList(map_QuoteIdtoQP);
        QuoteCloudUtil.prepareQuotes(list_NewQuotes[0].Id);
        QuoteCloudUtil.findOverageChargeAPNs(list_NewQuotes[0]);
        QuoteCloudUtil.prepareQuoteProduct(list_NewQuotes[0].Id);
        QuoteCloudUtil.insertPureSuccessItemsFromOffer(list_NewQuotes[0]);
        objOrder.Quote__c = list_NewQuotes[0].id;
        update objOrder;
        list_NewOpps[0].Direct_Indirect_Sale__c='Indirect';
        list_NewOpps[0].BusinessPartner__c=list_NewPartnerAccts[0].id;
        update list_NewOpps[0];
        list_NewQuotes[0] = QuoteCloudUtil.prepareQuotes(list_NewQuotes[0].Id);
        list_NewQuotes[0].offering_Type__C = SubscriptionUtil.OFFERING_TYPE_PCC ;
        update list_NewQuotes[0];
        QuoteCloudUtil.buildQuoteProductsForRenewal(objSub.Id,list_NewQuotes[0]);
        QuoteCloudUtil.getProductTierPricing(list_PTR, 10, 10, 'NG3_EMEA_USD_Price__c');
        QuoteCloudUtil.calculateTokenValue(5001,'PureEngage Cloud','GUIDE');
        QuoteCloudUtil.calculateTokenValue(5001,'PureEngage Cloud','DRIVE');
        QuoteCloudUtil.calculateTokenValue(5001,'PureConnect Cloud','GUIDE');
        QuoteCloudUtil.calculateTokenValue(5001,'PureConnect Cloud','DRIVE');
        QuoteCloudUtil.calculateTokenValue(5001,'Business Edition','GUIDE');
        QuoteCloudUtil.calculateTokenValue(5001,'Business Edition','DRIVE');
        QuoteCloudUtil.buildConversionRatesMap();
        QuoteCloudUtil.updateQuoteTotalsForRenewal(list_NewQuotes[0],list_NewQuoteProds);
        QuoteCloudUtil.createDependentAndOverages(list_NewQuoteProds,list_NewQuotes[0],1);
        Test.stopTest();
        QuoteCloudUtil.buildTierPricingQuery('abc', 'abc');
        QuoteCloudUtil.buildProductAndTierPricingQuery('abc', 'abc');
        
    }
    static testMethod void testUtilMethods3() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Id idUserId = [Select Id from User where IsActive = true and profileid='00eU0000000pPrrIAE' Limit 1].Id;
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        
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
        list_NewOpps[0].Avaya_Contract_Expiration__c = System.today()+100;
        list_NewOpps[0].Lever__c = 'Lever 1;Lever 2;Lever 3;';
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        Product_Group__c objPG = new    Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess' );
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles' );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4' );      
        insert objProd2;
        Set<Id> set_ProdIds =  new Set<Id>();
        set_ProdIds.add(objProd.Id);
        List<Product2> list_Prod = new List<Product2>();
        list_Prod.add(objProd);
        Product_Group__c objProdGroup = new Product_Group__c(Product__c = objProd.Id,Group_Type__c = 'Dependent Products');
        insert objProdGroup;
        Product_Group_Item__c objProdGrItem = new Product_Group_Item__c(Product_Group__c = objProdGroup.id,Product_Type__c = 'Mandatory',Product__c = objProd2.Id);
        insert objProdGrItem;
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00,Subscription_End_Date__c = DAte.today()+365,Ramp_Period__c = 12,CurrencyISOCode = 'USD');
        insert objsub;
        Subscription_Product__c objSubProd = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = false,Product__c = list_Prod[0].id);
        insert objSubProd;
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
        list_NewQuotes[0].Total_Software__c = 0.00;
        list_NewQuotes[0].Setup_Provisioning_Charges__c = 0.00;
        update list_NewQuotes[0];
        objsub.Quote__c = list_NewQuotes[0].id;
        update objsub;                                     
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
        Order__c objOrder = TestUtil.createOrders(1,true)[0];
        Set<Id> set_OrderIds = new Set<Id>();
        set_OrderIds.add(objOrder.Id);
        list_NewQuotes[0].offering_Type__C = 'PureConnect Subscription';
        List<Order_Line_Item__c> list_OLI = TestUtil.createOrderLines(list_Prod, objOrder.id, true);
        list_NewQuoteProds[0].BigMachines__Product__r.Type__c = 'Product';
        list_NewQuoteProds[0].Bundle__c= objPG.id;
        list_NewQuoteProds[1].Extended_Price_Per_Month__c = 10.00;
        list_NewQuoteProds[0].Bundle_Line__c = list_NewQuoteProds[1].id;
        update list_NewQuoteProds;
        System.debug('list_NewQuoteProds'+list_NewQuoteProds);
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,Net_Unit_Price__c,BigMachines__Product__r.New_Category__c,
                              BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.APN_Number__c,Is_Overage__c,Quantity__c,Product_Description__c,Ext_List__c,
                              Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Ext_Net_Price__c,Total_Discount__c,BigMachines__Product__r.Include_in_Agent_Seat_Count__c,BigMachines__Product__r.Include_in_CMMR_Total__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id and id = :list_NewQuoteProds[0].id];
        Map<Id,Product2> map_PSProducts = new Map<Id,Product2>([Select id from Product2 where OfferingType__c = 'PureCloud' and Sub_Category__c = 'PureSuccess A-la-Carte' limit 5]);
        Map<String,BigMachines__Quote_Product__c> mapOfPackageVsPrice = new  Map<String,BigMachines__Quote_Product__c>{'Partner'=>list_NewQuoteProds[0]};
            Set<String> set_UniqueString =  new Set<String>();
        QuoteCloudUtil.mapOfProducts = new Map<Id,Product2>{objProd2.Id =>objProd2};
            QuoteCloudUtil.createPureSuccessLinesCloud(mapOfPackageVsPrice, list_NewQuotes[0], objOrder,list_OLI);
        QuoteCloudUtil.createRenewalQuotes(objsub, list_NewOpps[0]);
        QuoteCloudUtil.retrieveBundleBaseProduct(list_NewQuoteProds,list_NewQuotes[0],'Existing');
        QuoteCloudUtil.retrivePureSuccessMultiplier('EMEA','BRL',map_PSProducts.keySet(),list_NewQuotes[0].Id);
        QuoteCloudUtil.retrivePureSuccessMultiplier('Greater China','RMB',map_PSProducts.keySet(),list_NewQuotes[0].Id);
        QuoteCloudUtil.retrivePureSuccessMultiplier('NA','CAD',map_PSProducts.keySet(),list_NewQuotes[0].Id);
        QuoteCloudUtil.retrivePureSuccessMultiplier('LATAM','USD',map_PSProducts.keySet(),list_NewQuotes[0].Id);
        QuoteCloudUtil.cloneSubscriptionQuoteAndQuoteProducts(objsub,list_NewOpps[0],list_Prod,System.today(),System.today()+30,false);
        map<String,Boolean> map_LeverSelected = new map<String,Boolean>{'Lever 1'=>true,'Lever 2'=>true,'Lever 3'=>true};
            QuoteCloudUtil.updateLeverDetials(list_NewQuotes[0],list_NewOpps[0],map_LeverSelected);    
        list_NewQuotes[0].offering_Type__C = 'PureConnect Cloud';
        update objOrder;
        QuoteCloudUtil.updateLeverDetials(list_NewQuotes[0],list_NewOpps[0],map_LeverSelected); 
        QuoteCloudUtil.calculateCumulativeTotal(new Set<ID>{list_NewQuoteProds[0].id});
        
        Test.stopTest();
        QuoteCloudUtil.thisForCodeCoverage();
    }
    
    static testMethod void testUtilMethodforCumulativeTotal() {
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c,BypassWorkflows__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.Bypass_Triggers__c = true;
        objuser.BypassValidationRules__c = true;
        objuser.BypassWorkflows__c = true;
        update objuser;
        
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
        list_NewOpps[0].Avaya_Contract_Expiration__c = System.today()+100;
        list_NewOpps[0].Lever__c = 'Lever 1;Lever 2;Lever 3;';
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        Product_Group__c objPG = new    Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess' );
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles' );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4' );      
        insert objProd2;
        Set<Id> set_ProdIds =  new Set<Id>();
        set_ProdIds.add(objProd.Id);
        List<Product2> list_Prod = new List<Product2>();
        list_Prod.add(objProd);
        Product_Group__c objProdGroup = new Product_Group__c(Product__c = objProd.Id,Group_Type__c = 'Dependent Products');
        insert objProdGroup;
        Product_Group_Item__c objProdGrItem = new Product_Group_Item__c(Product_Group__c = objProdGroup.id,Product_Type__c = 'Mandatory',Product__c = objProd2.Id);
        insert objProdGrItem;
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00,Subscription_End_Date__c = DAte.today()+365,Ramp_Period__c = 12,CurrencyISOCode = 'USD');
        insert objsub;
        Subscription_Product__c objSubProd = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = false,Product__c = list_Prod[0].id);
        insert objSubProd;
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
        list_NewQuotes[0].Total_Software__c = 0.00;
        list_NewQuotes[0].Setup_Provisioning_Charges__c = 0.00;
        list_NewQuotes[0].Subscription_Amend_Date__c = System.Today();
        list_NewQuotes[0].Subscription_Start_Date__c = System.Today() - 30;
        update list_NewQuotes[0];
        objsub.Quote__c = list_NewQuotes[0].id;
        update objsub;                                     
        Test.startTest();
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,Net_Unit_Price__c,BigMachines__Product__r.New_Category__c,
                              BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.APN_Number__c,Is_Overage__c,Quantity__c,Product_Description__c,Ext_List__c,Subscription_Product__c,
                              Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Ext_Net_Price__c,Total_Discount__c,BigMachines__Product__r.Include_in_Agent_Seat_Count__c,BigMachines__Product__r.Include_in_CMMR_Total__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id and id = :list_NewQuoteProds[0].id];
        
        QuoteCloudUtil.calculateCumulativeTotal(new Set<ID>{list_NewQuoteProds[0].id});
        list_NewQuoteProds[0].Subscription_Product__c = objSubProd.Id;
        update  list_NewQuoteProds[0];
        QuoteCloudUtil.calculateCumulativeTotal(new Set<ID>{list_NewQuoteProds[0].id}); 
        list_NewQuoteProds[0].Total_Discount__c = 10.00;
        list_NewQuoteProds[0].Subscription_Product__c = null;
        update  list_NewQuoteProds[0];
        QuoteCloudUtil.calculateCumulativeTotal(new Set<ID>{list_NewQuoteProds[0].id}); 
        list_NewQuoteProds[0].Subscription_Product__c = objSubProd.Id;
        update  list_NewQuoteProds[0];
        QuoteCloudUtil.calculateCumulativeTotal(new Set<ID>{list_NewQuoteProds[0].id}); 
        QuoteCloudUtil.populateLineNumbers(list_NewQuotes[0].Id,'New Subscription',null);
        Test.stopTest();
        
    } 
}