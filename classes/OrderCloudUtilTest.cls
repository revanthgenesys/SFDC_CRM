/*
* Class Name       : OrderCloudUtilTest 
* Description      : Test class for OrderCloudUtil. 
* ***************************************************************************************************************
* Developer Note   : *
* ***************************************************************************************************************
*/
@isTest(SeeAllData=true)
private class OrderCloudUtilTest {
    
    static testMethod void OrderCloudUtil_TestMethod() {
        Test.startTest();
        
        String strQuoteQuery = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        
        strQuoteQuery += 'End_User_ID__r.Country__r.Name, Quote_Cloned_Revised__r.Name,';     
        strQuoteQuery += 'Sold_To_Name__r.Country__r.PSRDP_Region__c,Sold_To_Name__r.Country__r.Name,Sold_To_Name__r.Country__r.Region__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c,BigMachines__Opportunity__r.RecordType.Name,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Name,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email, BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,';        
        strQuoteQuery += 'Amendment_For__r.CMRR__c, Amendment_For__r.ACV__c, Amendment_For__r.TCV__c,End_User_ID__r.Subsidary__c,';        
        strQuoteQuery += 'Amendment_For__r.Total_Services__c, Amendment_For__r.Total_Education__c, Amendment_For__r.Total_Hardware__c,Amendment_For__r.Total_Non_Recurring_Fees__c,';        
        //Anju May 2018 
        strQuoteQuery += 'Amendment_For__r.Status__c,';  
        //Anju May 31 Revpro
        strQuoteQuery += 'Amendment_For__r.Order__r.name,Amendment_For__r.Order__c,';      
        
        strQuoteQuery += 'BigMachines__Opportunity__r.Account.Partner_Tier__c,BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c FROM BigMachines__Quote__c WHERE offering_type__c = \'' + 'PureCloud' + '\' and BigMachines__Status__c = \'Quote Approved\' and Order_Type__c = \'Amend Subscription\' and Amendment_For__c != null and BigMachines__Opportunity__c != null and BigMachines__Line_Items__c > 0 order by lastmodifieddate desc limit 1';
        
        BigMachines__Quote__c objTestQuote = (BigMachines__Quote__c)Database.query(strQuoteQuery);

        objTestQuote.A_La_Carte_PureSuccess_Services_Amount__c   = 1000;
        objTestQuote.PureSuccess_Offer_Subscription_Amount__c = 1000;
        BigMachines__Quote_Product__c objQuoteProduct = new BigMachines__Quote_Product__c();
        objQuoteProduct.BigMachines__Product__c = '01t0B000007Iq8x';
        objQuoteProduct.BigMachines__Quote__c = objTestQuote.Id;
        objQuoteProduct.BigMachines__Quantity__c = 1;
        objQuoteProduct.BigMachines__Sales_Price__c = 100;
        objQuoteProduct.Net_Unit_Price__c = 100;
        insert objQuoteProduct;
        BigMachines__Quote_Product__c objTestProd = [Select id from BigMachines__Quote_Product__c  where BigMachines__Quote__c = :objTestQuote.id limit 1];
        delete objTestProd ;
        
        Util.Bypass_Trigger_Chk = true;
        OrderCloudUtil.orderFromQuote(objTestQuote); 
        List<Order__c>list_Order = [SELECT Id,Name,Recordtypeid,Original_Parent_Order1__c,Order_Type__c,License_FYM_detail__c,Year__c,Maintenance_Start__c,
                                    Maintenance_End__c,Numb_of_Maint_Months__c,Annual_Contract_Value__c,Bypass_Service_Contract__c,TCV__c,Total_Order__c
                                       FROM Order__c LIMIT 10];
        list_Order[0].TCV__c = 1000000;
        
        system.debug(objTestQuote.BigMachines__Opportunity__c);
        //Opportunity objOpp = new Opportunity(id = objTestQuote.BigMachines__Opportunity__c, ownerid = system.userinfo.getuserid());
        //update objOpp;
        
        system.debug(objTestQuote.BigMachines__Opportunity__r.ownerId);
        
        OrderCloudUtil.createPureSuccessOrder(objTestQuote, list_Order[0]);

        OrderCloudUtil.insertPureSuccessItemsFromOffer(objTestQuote);
        //OrderCloudUtil.populateRevproFields(OlList);    
        Test.stopTest();
        
    }

    static testMethod void testcreateHWOrdersForCloud(){
        Test.startTest();
        
        Account_Order_Address__c aOA = [Select id,Quote__c,Order__c from Account_Order_Address__c where Address_Type__c = 'Ship To' and Quote__c != null and Order__c != null order by lastmodifieddate desc limit 1];
        Order__c objOrder = [Select id,Quote__c,Name,End_User_Name__c,Sold_To_Name__c,Maintenance_Start__c,Maintenance_End__c,
        Payment_Terms__c,Opportunity__c,Date_Submitted__c,Due_Date__c,PO_Received_Date__c,
        PO_Number__c,PO_Date__c,recordtypeid,Genesys_Care_Specialist_Email__c,Genesys_Care_Ops_Email__c,Net_Maint__c,OwnerId,status__c,License_FYM_detail__c,Maintenance_Amount__c,Opportunity_Type__c,Numb_of_Maint_Months__c,Net_License__c,Revised_Net_License_Value__c,Comments__c,Ship_To_Name__c,Shipping_Contact_Phone_Number__c,Shipping_Contact__c,Shipping_Instructions__c,Shipping_Contact_Email__c,Order_Fulfillment_Email_Receipt__c,Delivery_Method__c,CurrencyIsoCode,quote_number__c,Ship_software_via__c,Date_Rejected__c,Date_Re_Submitted__c from  Order__c where id = :aOA.Order__c limit 1];
        
        OrderCloudUtil.createHWOrdersForCloud(aOA.Quote__c, objOrder); 

        Test.stopTest();
    }

    static testMethod void testShareOrder(){
        Test.startTest();
        List<Order__c>list_OrderId = [Select Id from Order__c limit 10];
        Set<Id> set_OrderId = new Set<Id>();
        for(Order__c objOrder : list_OrderId) {
            set_OrderId.add(objOrder.Id);
        }

        User objUser = [Select Id from User where Id != :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId() and IsActive = true Limit 1];
        OrderCloudUtil.shareOrders(set_OrderId,objUser.Id);
        

        Test.stopTest();
    }

    static testMethod void testpopulateRevproFields() {
        Util.Bypass_Trigger_Chk = true;
        Opportunity testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.Gainsight_Relationship_Type__c = 'test it';
        insert testOpp;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
        Test.startTest();
        List<Order__c> ordList = new List<Order__c>();    
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = testQuote.id;

        insert ord_1;
        ordList.add(ord_1);

        Order__c ord_2 = new Order__c(Id=ord_1.id);
        ord_2.Subsidaries__c = 'a24U00000004Xlg';
        ord_2.status__c = 'Approved';
        update ord_2;

        Map<Id, Order__c> oldMap= new Map<Id, Order__c>{ord_1.Id => ord_1};
        Map<Id,Order__c> newMap= new Map<Id,Order__c>{ord_2.Id => ord_2};     
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name='Test Prod1';
        objTestProd1.recordTypeId = rtypes[0].Id;
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'testAshosh';
        insert objTestProd1;

        BigMachines__Quote_Product__c objQuoteProduct = new BigMachines__Quote_Product__c();
        objQuoteProduct.BigMachines__Product__c = objTestProd1.Id;
        objQuoteProduct.BigMachines__Quote__c = testQuote.Id;
        objQuoteProduct.BigMachines__Quantity__c = 1;
        objQuoteProduct.BigMachines__Sales_Price__c = 100;
        insert objQuoteProduct;
        
        List<Order_Line_Item__c> OlList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oline =  new Order_Line_Item__c();
        oline.Order__c = ord_1.Id;
        oline.Product__c = objTestProd1.Id;
        oline.Contract_Line_Update_Status__c = '';
        oline.BigMachines_Quantity__c = 1;
        oline.Sales_Price__c = 10;
        insert oline;
        OlList.add(oline);

        Order_Line_Item__c oline_sec =  new Order_Line_Item__c();
        oline_sec.Order__c = ord_1.Id;
        oline_sec.Product__c = objTestProd1.Id;
        oline_sec.Contract_Line_Update_Status__c = '';
        oline_sec.BigMachines_Quantity__c = 1;
        oline_sec.Sales_Price__c = 10;
        oline_sec.APN_Number__c = '93303';
        insert oline_sec; 
        OlList.add(oline_sec);

        OrderCloudUtil.populateRevproFields(OlList);
       OrderCloudUtil.populatePureSuccessOLI(oline_sec,100000,objQuoteProduct,testQuote);
        Test.stopTest();

    }

    static testMethod void testcreatePureSuccessLinesCloud() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Id idUserId = [Select Id from User where IsActive = true and profileid='00eU0000000pPrrIAE' Limit 1].Id;
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
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,Net_Unit_Price__c,BigMachines__Product__r.New_Category__c,Bundle_Line__r.BigMachines__Quantity__c,Bundle_Line__r.Tokens__c,
                              BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.APN_Number__c,Is_Overage__c,Quantity__c,Product_Description__c,Ext_List__c,BigMachines__Product__r.List_Price__c,List_Price__c,Bundle_Line__r.List_Price__c,
                              Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Ext_Net_Price__c,Total_Discount__c,BigMachines__Product__r.Include_in_Agent_Seat_Count__c,BigMachines__Product__r.Include_in_CMMR_Total__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id and id = :list_NewQuoteProds[0].id];
        Map<String,BigMachines__Quote_Product__c> mapOfPackageVsPrice = new  Map<String,BigMachines__Quote_Product__c>{'Partner'=>list_NewQuoteProds[0]};
        Set<String> set_UniqueString =  new Set<String>();
        QuoteCloudUtil.mapOfProducts = new Map<Id,Product2>{objProd2.Id =>objProd2};
        OrderCloudUtil.createPureSuccessLinesCloud(mapOfPackageVsPrice, list_NewQuotes[0], objOrder,list_OLI);
        OrderCloudUtil.createOneTimeChargeOLIforPEC(list_NewQuotes[0].Id, objOrder, list_OLI);
       // QuoteCloudUtil.populatePureSuccessOLI(list_OLI[0],100000,list_NewQuoteProds[0],list_NewQuotes[0]);
        update objOrder;
        Test.stopTest();
        
    }

    static testMethod void testcreateOneTimeChargeOrder(){
        Id idUserId = [Select Id from User where IsActive = true and profileid='00eU0000000pPrrIAE' Limit 1].Id;
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
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        Product_Group__c objPG = new Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess');
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Serivces' );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4' );      
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
        Test.startTest();
        
        Order__c objOrder = TestUtil.createOrders(1,true)[0];
        Set<Id> set_OrderIds = new Set<Id>();
        set_OrderIds.add(objOrder.Id);
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

        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name='Test Prod1';
        objTestProd1.recordTypeId = rtypes[0].Id;
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureCloud';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'testAshosh';
        objTestProd1.New_category__c = 'Services';
        insert objTestProd1;

        OrderCloudUtil.createOneTimeChargeOrder(list_NewQuotes[0].Id, objOrder, SubscriptionUtil.OFFERING_TYPE_PC, Label.New_Subscription, list_NewQtAddrs);
    }
	
	static testMethod void testcreateOneTimeOrder(){
        Id idUserId = [Select Id from User where IsActive = true and profileid='00eU0000000pPrrIAE' Limit 1].Id;
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
        list_NewQuotes[0].Offering_Type__c = 'Business Edition';
        update list_NewQuotes[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c,BigMachines__Product__r.Sub_Type__c,BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Product__r.APN_Number__C
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        Product_Group__c objPG = new Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess');
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Serivces' );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4' );      
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
        Test.startTest();
        
        Order__c objOrder = TestUtil.createOrders(1,true)[0];
        objOrder.Quote__c = list_NewQuotes[0].id;
        update objOrder;
        Set<Id> set_OrderIds = new Set<Id>();
        set_OrderIds.add(objOrder.Id);
        String strObjName = 'Product2';
        String strWhereCondition = 'APN_Number__c in ( \'3GP00209AAAA\',\'ED-012-NV-WEXV\',\'PC-170-NV-PCPENTST\',\'PS-170-PURE-SVTOKEN\',\'TH-900-PCEDGE-2120200\')';  
        List<Product2> list_Prods = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
        List<Order_Line_Item__c> list_OLI = TestUtil.createOrderLines(list_Prods, objOrder.id, true);
        for(BigMachines__Quote_Product__c objQP:list_NewQuoteProds){
            for(Order_Line_Item__c objOLI:list_OLI){
                if(objOLI.Product__c == objQP.BigMachines__Product__c){
                    objOLI.Quote_Product__c = objQP.Id;
                }
            }
        }
        update list_OLI;
        list_NewQuoteProds[0].BigMachines__Product__r.Type__c = 'Product';
        list_NewQuoteProds[0].Bundle__c= objPG.id;
        list_NewQuoteProds[1].Extended_Price_Per_Month__c = 10.00;
        list_NewQuoteProds[0].Bundle_Line__c = list_NewQuoteProds[1].id;
        update list_NewQuoteProds;
        System.debug('list_NewQuoteProds'+list_NewQuoteProds);
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,Net_Unit_Price__c,BigMachines__Product__r.New_Category__c,BigMachines__Product__r.APN_Number__c,
                              BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.APN_Number__c,Is_Overage__c,Quantity__c,Product_Description__c,Ext_List__c,
                              Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Ext_Net_Price__c,Total_Discount__c,BigMachines__Product__r.Include_in_Agent_Seat_Count__c,BigMachines__Product__r.Include_in_CMMR_Total__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id and id = :list_NewQuoteProds[0].id];

        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name='Test Prod1';
        objTestProd1.recordTypeId = rtypes[0].Id;
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureCloud';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'testAshosh';
        objTestProd1.New_category__c = 'Services';
        insert objTestProd1;
        OrderCloudUtil.createOneTimeOrdersForPEC(objOrder.Id);
        OrderCloudUtil.cloneSubscriptionOrderAndOrderLineItems(objsub.Id,list_NewQuotes[0].id,list_NewOpps[0].id,false,'Terms And Conditions',System.today()+30);
		OrderCloudUtil.thisForCodeCoverage();

    }
}