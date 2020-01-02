@isTest
public class TestDataFactoryForQuoteTool2 {

    
    //subsidary
    
    public static List<Subsidary__c> createSubsidary(integer intNumSubsid){
        List<Subsidary__c> list_subsid = new List<Subsidary__c>();
        for(Integer i=0; i<intNumSubsid; i++) {
          Subsidary__c subsi = new Subsidary__c( Name = '8450'+i, Active__c = true, Billing_Invoice_Footer__c = 'Questions? Contact us',
                            Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id, Description__c = '8445 Canaplus Indonesia') ;
        list_subsid.add(subsi);
        }
        insert list_subsid;
        return list_subsid;
    }
    
    //*** Method to create accounts //
    public static List<Account> createAccounts(id subsid, Integer intNumOfAccts) {
        List<Account> list_NewAccts = new List<Account>();
        for(Integer i=0; i<intNumOfAccts; i++) {
            Account a = new Account(Name='TestAccount' + i,
            Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
            Screening_Checklist_Completed__c=true, isDirect__c= true,Subsidary__c= subsid);
            list_NewAccts.add(a);
        }
        insert list_NewAccts;
        return list_NewAccts;
    } 
    
    public static List<Account> createAccounts1(Integer intNumOfAccts) {
        List<Account> list_NewAccts = new List<Account>();
        for(Integer i=0; i<intNumOfAccts; i++) {
            Account a = new Account(Name='TestAccount' + i,
            Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
            Screening_Checklist_Completed__c=true, isDirect__c= true);
            list_NewAccts.add(a);
        }
        insert list_NewAccts;
        return list_NewAccts;
    }
    //*** Method to create contacts //
    public static List<Contact> createContacts(Id acctId, Integer intNumOfConts) {   
        List<Contact> list_NewConts = new List<Contact>();
        for(Integer i=0; i<intNumOfConts; i++) {
            list_NewConts.add(new Contact(LastName=' Contact ' + i,                                   
                                          AccountId=acctId));
        }
        // Insert all contacts for accounts.
        insert list_NewConts;         
        return list_NewConts;
    }
    //*** Method to create opportunities //
    public static List<Opportunity> createOpportunties(Id acctId, Integer intNumOfOpps) {   
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        for(Integer i=0; i<intNumOfOpps; i++) {
            list_NewOpps.add(new Opportunity(Name=' Opportunity ' + i,
                                   StageName='1.Recognize Needs',
                                   CurrencyIsoCode = 'USD',
                                   Partner_Opportunity_Source__c = 'Partner Registered Opportunity',
                                   Sold_To_Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].Id,
                                   Direct_Sales__c = true,
                                   CloseDate=System.today().addMonths(1),
                                   AccountId=acctId));
        }
        // Insert all opportunities for all accounts.
        insert list_NewOpps;         
        return list_NewOpps;
    }
    //****Method for country
    public  void createcounty(){
     Country__c countr = new country__C(Name = 'United States', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
      insert countr;
    }
        
    //*** Method to create BM pureconnect cloud quotes //
    public static List<BigMachines__Quote__c> createQuotes(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
        Map<String, RecordType> map_BMQuoteRecTypes = getOrderRecordTypes('BigMachines__Quote__c');
        for (Integer i=0; i<intNumOfQuotes; i++) {
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(
                                                  RecordTypeId = map_BMQuoteRecTypes.get('Cloud Quote').Id,
                                                  BigMachines__Opportunity__c = oppId, Quote_Created_Date__c = System.today(), 
                                                  BigMachines__Status__c = 'Quote In Progress', BigMachines__Is_Primary__c = true,
                                                  Product_Tier__c = 'Premium', Offering_Type__c = 'PureEngage Subscription',
                                                  Service_Level__c = 'Business', Pricing_Model__c = 'Concurrent', 
                                                  Quote_Opportunity_Type__c = 'Old Pricing', Duration_Unit__c = 'Months', 
                                                  Order_Numb_of_Maint_Months__c = 12, Order_Type__c = 'Revenue', 
                                                  End_User_ID__c = acctId, BigMachines__Account__c = acctId, 
                                                  Sold_To_Name__c = acctId, New_Price_Book__c = 'NG5_NA_USD', 
                                                  Support_Owner__c = acctId, System_Integrator__c = acctId, 
                                                  CurrencyISOCode = 'USD', Quote_Business_Type__c = 'Cloud', 
                                                  Expiration_Date__c = Date.today().addDays(90), Deployment_Model__c = 'Local Control',
                                                  Multi_Year_Quote__c = true,                                                  
                                                  Approval_Submission_Date__c = Date.today());
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    public static List<Product2> createproducts(Integer intNumOfprods) {   
        List<Product2> list_NewProd = new List<Product2>();
        for(Integer i=0; i<intNumOfprods; i++) {
            list_NewProd.add(new Product2(Name='Testproduct' + i,Quantities_Available__c = '1',
                                          Unit_of_Measure__c = 'Seat',Quantity__c = 1 ,Product_Name__c='test',
                                          Taxonomy_Solution_Category__c='Business Optimization', Taxonomy_Solution__c='Integration',
                                          OfferingType__c ='PureEngage Subscription',Shipment_Approval__c='No Approval Required',
                                          Tier__c='Preferred'));
        }
        // Insert all Products for prod.
        insert list_NewProd;         
        return list_NewProd;
    }
    
    //*** Method to create Product group //
    public static List<Product_Group__c> createprodgrop(Integer intNumOfprodgrop) {
        List<Product_Group__c> list_Newprodgrop = new List<Product_Group__c>();
        for(Integer i=0; i<intNumOfprodgrop; i++) {
            Product_Group__c a = new Product_Group__c(Name='Testgroup' + i,
            Group_Type__c = 'Favorite',
            User__c = UserInfo.getUserId());
            list_Newprodgrop.add(a);
        }
        insert list_Newprodgrop;
        return list_Newprodgrop;
    } 
    
     public static List<Product_Group_Item__c> createprodgropIt(Id prgdrp, id prod,  Integer intNumOfprodgropIt) {
        List<Product_Group_Item__c> list_Newprodgropit = new List<Product_Group_Item__c>();
        for(Integer i=0; i<intNumOfprodgropIt; i++) {
            Product_Group_Item__c a = new Product_Group_Item__c(Bundle__c = prgdrp, Price_Weightage__c = 5,
                                                                Product__c= prod, Product_Group__c=prgdrp,
                                                                Product_Type__c = 'Optional',Quantity__c = 1,
                                                                Token_Value__c = 1);
            
            list_Newprodgropit.add(a);
        }
        insert list_Newprodgropit;
        return list_Newprodgropit;
    }
    
    //*** Method to create Discount //
    public static List<Partner_Discount__c> createpartdis(Id acctId, Integer intNumOfpartdis) {
        List<Partner_Discount__c> list_Newpartdis = new List<Partner_Discount__c>();
        for(Integer i=0; i<intNumOfpartdis; i++) {
            Partner_Discount__c a = new Partner_Discount__c(Account__c=acctId, Category__c = 'Tiered Partner Discount',
            Discount__c = 5 ,    Type__c = 'Subscription',   Year__c = 'Year 1' );                                                            
            list_Newpartdis.add(a);
        }
        insert list_Newpartdis;
        return list_Newpartdis;
    } 
    
    //*** Method to create BM pureconnect cloud quote line items //
    public static List<BigMachines__Quote_Product__c> createQuoteProducts(Id quoteId,Id prdgrp ) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 2];
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                                                  Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                                                  BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Bundle__c= prdgrp);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    public static List<BigMachines__Quote_Product__c> createQuoteProducts11(Id quoteId ) {
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 2];
        for(Integer i=0; i<list_Products.size(); i++) {
            Product2 prod = list_Products[i];
            BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                                                  BigMachines__Quote__c = quoteId, BigMachines__Product__c = prod.Id,
                                                  Name = prod.Name, Build_Type__c = prod.Name, APN_Number__c = prod.APN_Number__c,
                                                  BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
    
    //*** Method to create orders for BM quotes //
    public static List<Order__c> createOrders(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    }
    
    //*** Method to create account order address for Zuora quotes //
    public static List<Account_Order_Address__c> createAOAs(Id quoteId){
        List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();
        List<String> list_addrTypes = new List<String> {'Bill To', 'End User', 'Ship To', 'Sold To'};
        for(Integer i=0; i<list_addrTypes.size(); i++ ){
            Account_Order_Address__c objNewAOA = new Account_Order_Address__c();
            objNewAOA.Quote__c = quoteId;
            objNewAOA.Address_Type__c = list_addrTypes[i];
            objNewAOA.Address__c = 'Address 1 - '+i;
            objNewAOA.Address2__c = 'Address 2 - '+i;
            objNewAOA.City__c = 'City'+i;
            objNewAOA.State__c = 'State'+i;
            objNewAOA.Country__c = 'US';
            objNewAOA.Sort_Order__c = i+1;
            objNewAOA.Email__c = 'test@test.com';
            list_NewAOAs.add(objNewAOA);
        }
        
        insert list_NewAOAs;
        return list_NewAOAs;  
    }
    
    //method for subscriotion__C
    
      public static List<Subscription__c> createsubscription(Id Accid, Id quoteId,  Integer intNumOfSubs) {
        List<Subscription__c> list_NewSubscription = new List<Subscription__c>();        
        for (Integer i=0; i<intNumOfSubs; i++) {
            Subscription__c objNewSubscription = new Subscription__c(
                                                  Account__c = Accid,ACV__c = 13389336,CMRR__c = 1115778, TCV__c=26778672, Version__c = 1,
                                                  Amendment_Date__c = System.today(), Quote__c = quoteId,  
                                                  Status__c = 'Active', Subscription_Start_Date__c = System.today(),
                                                  Subscription_End_Date__c =  System.today().addYears(1), Offering_Type__c ='PureCloud',
                                                  Billing_Category__c = 'Annual Prepay', Monthly_Minimum__c = 1550, Business_Partner__c = Accid,
                                                  Ramp_Period__c = 100,     Price_Book_Currency__c='NG5_NA_USD' );
            list_NewSubscription.add(objNewSubscription);            
        }
        insert list_NewSubscription;
        return list_NewSubscription;
    }
    
    //method for subscriotion__C
    
      public static List<Subscription_product__c> createsubscriptionprod(id subsc, Integer intNumOfSubsprd) {
        List<Subscription_product__c> list_NewSubscriptionprod = new List<Subscription_product__c>();        
        for (Integer i=0; i<intNumOfSubsprd; i++) {
            Subscription_product__c objNewSubscriptionprod = new Subscription_product__c(
                                                  Subscription__c = subsc, or_Amount__c = '13', Adjustment__c = 100, Disc__c= 267, Ext_List__c = 10,
                                                  Ext_Net_Price__c = 10,Group_Number__c = 'test', Line_Number__c = 12,  
                                                  List_Price__c = 5,Net_Unit_Price__c =  5, Quantity__c = 1
                                                  );
            list_NewSubscriptionprod.add(objNewSubscriptionprod);            
        }
        insert list_NewSubscriptionprod;
        return list_NewSubscriptionprod;
    }
    
    //*** Method to create BM pureconnect cloud quotes //
    public static List<zqu__Quote__c> createZuoraQuotes(Id oppId, Id acctId, Integer intNumOfQuotes) {
        List<zqu__Quote__c> list_NewQuotes = new List<zqu__Quote__c>();
        for (Integer i=0; i<intNumOfQuotes; i++) {
            zqu__Quote__c objNewQuote = new zqu__Quote__c(zqu__Account__c=acctId, zqu__ApprovalStatus__c='Quote In Progress',
                                                 zqu__Currency__c='USD', Customer_PO_Not_Required__c=true, 
                                                 zqu__Opportunity__c=oppId, zqu__StartDate__c=System.today()+10, 
                                                 zqu__Primary__c=true, zqu__QuoteBusinessType__c='New',
                                                 zqu__Status__c='New', zqu__PaymentTerm__c='Net 30');
            list_NewQuotes.add(objNewQuote);            
        }
        insert list_NewQuotes;
        return list_NewQuotes;
    }
    
    //*** Method to create PureCloud quote line items //
    public static List<zqu__QuoteChargeDetail__c> createZuoraQuoteProducts(Id quoteId) {
        List<zqu__QuoteChargeDetail__c> list_NewQuoteProducts = new List<zqu__QuoteChargeDetail__c>();
        List<zqu__ProductRatePlanCharge__c> list_ProdRtPlChrge = [SELECT Id, zqu__ProductRatePlan__c
                                        FROM zqu__ProductRatePlanCharge__c 
                                        WHERE zqu__ProductRatePlan__r.zqu__Product__r.OfferingType__c INCLUDES ('PureCloud') LIMIT 1];  
        for(Integer i=0; i<list_ProdRtPlChrge.size(); i++) {
            zqu__QuoteChargeDetail__c objNewQuoteProduct = new zqu__QuoteChargeDetail__c(
                                              zqu__Quote__c=quoteId, zqu__ProductRatePlanCharge__c=list_ProdRtPlChrge[i].Id,
                                              zqu__ProductRatePlan__c=list_ProdRtPlChrge[i].zqu__ProductRatePlan__c);
            list_NewQuoteProducts.add(objNewQuoteProduct);            
        }
        system.debug('$$$$$$'+list_NewQuoteProducts.size());
        insert list_NewQuoteProducts;
        return list_NewQuoteProducts;
    }
       
    public static List<zqu__QuoteRatePlanCharge__c> setupQuoteRatePlanCharges(zqu__Quote__c objQuote, boolean doInsert)
    {
        List<zqu__QuoteRatePlanCharge__c> list_ZQRPCs = new List<zqu__QuoteRatePlanCharge__c>();
        Map<Id, zqu__QuoteRatePlan__c> map_ZuoraQuoteRatePlan = new Map<Id, zqu__QuoteRatePlan__c>();
        Map<Id, zqu__ProductRatePlanCharge__c> map_ZuoraProductRatePlanCharges = new Map<Id, zqu__ProductRatePlanCharge__c>();
                
        List<zqu__QuoteRatePlan__c> list_ZuoraQuoteRatePlans = setupZuoraQuoteRatePlans(objQuote, true);
        System.assert(list_ZuoraQuoteRatePlans[0].Id != NULL);
        
        List<zqu__ProductRatePlan__c> list_ZuoraProductRatePlans = setupZuoraProductRatePlans(list_ZuoraQuoteRatePlans, true);
        System.assert(list_ZuoraProductRatePlans[0].Id != NULL);
        
        List<zqu__ProductRatePlanCharge__c> list_ZuoraProductRatePlanCharges = setupZuoraProductRatePlanCharges(list_ZuoraProductRatePlans, true);
        System.assert(list_ZuoraProductRatePlanCharges[0].Id != NULL);
        
        List<Id> list_ids = new List<Id>();
        for(zqu__ProductRatePlanCharge__c obj : list_ZuoraProductRatePlanCharges){
            list_ids.add(obj.Id);
        }
        
        list_ZuoraProductRatePlanCharges =  [SELECT Id , zqu__ProductRatePlan__r.zqu__Product__c
                                             FROM zqu__ProductRatePlanCharge__c WHERE Id  IN :list_ids];
        
        
        for(zqu__QuoteRatePlan__c objQRP : list_ZuoraQuoteRatePlans){
            map_ZuoraQuoteRatePlan.put(objQRP.zqu__Product__c, objQRP);            
        }
        
        for(zqu__ProductRatePlanCharge__c objPRPC : list_ZuoraProductRatePlanCharges){
            map_ZuoraProductRatePlanCharges.put(objPRPC.zqu__ProductRatePlan__r.zqu__Product__c, objPRPC);
        }
        for(Id idProd : map_ZuoraProductRatePlanCharges.keySet()){
            zqu__QuoteRatePlanCharge__c objZQRPC = new zqu__QuoteRatePlanCharge__c();
            objZQRPC.zqu__ProductRatePlanCharge__c = map_ZuoraProductRatePlanCharges.get(idProd).Id;
            objZQRPC.zqu__Discount__c = 1;
            objZQRPC.zqu__EffectivePrice__c = 1;
            objZQRPC.zqu__Quantity__c = 1;
            objZQRPC.zqu__UOM__c = 'test UOM';
            objZQRPC.Partner_Price__c = 10;
            objZQRPC.zqu__QuoteRatePlan__c = map_ZuoraQuoteRatePlan.get(idProd).Id;
            list_ZQRPCs.add(objZQRPC);
        }
        if(doInsert)
            insert list_ZQRPCs;
        return list_ZQRPCs;
    }
    
    public static List<zqu__ProductRatePlanCharge__c> setupZuoraProductRatePlanCharges(List<zqu__ProductRatePlan__c> list_ZuoraProductRatePlans, boolean doInsert)
    {
        
        List<zqu__ZUnitOfMeasure__c> list_UOMs = new List<zqu__ZUnitOfMeasure__c>(); 
      
        for(integer i = 0 ; i< list_ZuoraProductRatePlans.size() ; i++){
            zqu__ZUnitOfMeasure__c  objUOM = new zqu__ZUnitOfMeasure__c();
            objUOM.zqu__Active__c = true;
            //objUOM.zqu__BillingEntity__c = onBillingEntity.Id;
            objUOM.zqu__Uom_rounding_mode__c = 'Up';
            objUOM.zqu__UOMFullName__c = 'test'+i;
            list_UOMs.add(objUOM);
        }
        insert list_UOMs ; 
        System.assert(list_UOMs[0].Id != NULL);
        
        List<zqu__ProductRatePlanCharge__c> list_ProductRatePlanCharges = new List<zqu__ProductRatePlanCharge__c>();
        
        for(zqu__ProductRatePlan__c objProductRatePlan : list_ZuoraProductRatePlans){
            zqu__ProductRatePlanCharge__c objPRPC = new zqu__ProductRatePlanCharge__c();
            
            objPRPC.zqu__ProductRatePlan__c = objProductRatePlan.Id;
            list_ProductRatePlanCharges.add(objPRPC);
        }
                
        if(doInsert)
            insert list_ProductRatePlanCharges;
        return list_ProductRatePlanCharges;
    } 
    
     public static List<zqu__QuoteRatePlan__c> setupZuoraQuoteRatePlans(zqu__Quote__c objQuote, boolean doInsert){
        
        List<zqu__QuoteRatePlan__c> list_ZuoraQuoteRatePlans = new  List<zqu__QuoteRatePlan__c>();
        
        zqu__QuoteAmendment__c  objQA = new zqu__QuoteAmendment__c(zqu__Quote__c = objQuote.Id);        
        insert objQA;
        
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE OfferingType__c Includes ('PureCloud')
                                          AND ProductShippable__c='Yes' LIMIT 2];
        
        for(Product2 objProduct : list_Products){
            zqu__QuoteRatePlan__c objQuoteRatePlan = new zqu__QuoteRatePlan__c();
            objQuoteRatePlan.zqu__Product__c = objProduct.Id;
            objQuoteRatePlan.zqu__Quote__c = objQuote.Id;
            objQuoteRatePlan.zqu__QuoteAmendment__c = objQA.Id;
            list_ZuoraQuoteRatePlans.add(objQuoteRatePlan);
        }
        if(doInsert)
            insert list_ZuoraQuoteRatePlans;
        return list_ZuoraQuoteRatePlans;
    }
    
    
    public static List<zqu__ProductRatePlan__c> setupZuoraProductRatePlans(List<zqu__QuoteRatePlan__c> list_ZuoraQuoteRatePlans, boolean doInsert){
        
        List<zqu__ZProduct__c> list_ZProduct = new List<zqu__ZProduct__c>();
        for(zqu__QuoteRatePlan__c objQuoteRate : list_ZuoraQuoteRatePlans){
            list_ZProduct.add(new zqu__ZProduct__c(zqu__Active__c = true , zqu__Deleted__c = false, zqu__EffectiveStartDate__c = Date.newInstance(2017, 1, 1), 
                                                  zqu__Product__c = objQuoteRate.zqu__Product__c));
        }
        
        insert list_ZProduct;
        
        Map<Id,zqu__ZProduct__c> map_ZProducts = new Map<Id,zqu__ZProduct__c>();
        
        for(zqu__ZProduct__c obj : list_ZProduct){
            map_ZProducts.put(obj.zqu__Product__c , obj);
        }
        
        List<zqu__ProductRatePlan__c> list_ZuoraProductRatePlans = new List<zqu__ProductRatePlan__c>();
        
        for(zqu__QuoteRatePlan__c objQuoteRate : list_ZuoraQuoteRatePlans){
            zqu__ProductRatePlan__c objProductRatePlan = new zqu__ProductRatePlan__c();
            objProductRatePlan.zqu__Product__c = objQuoteRate.zqu__Product__c;
            objProductRatePlan.zqu__ZProduct__c = map_ZProducts.get(objQuoteRate.zqu__Product__c).Id;
            objProductRatePlan.zqu__EffectiveStartDate__c = Date.newInstance(2017, 1, 1);
            objProductRatePlan.zqu__EffectiveEndDate__c = Date.newInstance(2017, 12, 1);
            list_ZuoraProductRatePlans.add(objProductRatePlan);
        }
        if(doInsert)
            insert list_ZuoraProductRatePlans;
        return list_ZuoraProductRatePlans;
    }
            
    //*** Method to create orders for Zuora quotes //
    public static List<Order__c> createPureCloudOrders(Id quoteId, Id oppId, Integer intNumOfOrders){
        List<Order__c> list_NewOrders = new List<Order__c>();
        
        for(Integer i=0; i<intNumOfOrders; i++ ){
            Order__c objNewOrder = new Order__c();
            objNewOrder.Zuora_Quote__c = quoteId;
            objNewOrder.Maintenance_Start__c = Date.today();
            objNewOrder.Maintenance_End__c = Date.today().addYears(1);
            objNewOrder.Opportunity__c = oppId;
            objNewOrder.Numb_of_Maint_Months__c = 12;
            list_NewOrders.add(objNewOrder);
        }
        
        insert list_NewOrders;
        return list_NewOrders;  
    }
    
    //*** Method to create account order address for Zuora quotes //
    public static List<Account_Order_Address__c> createPureCloudAOAs(Id quoteId){
        List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();
        List<String> list_addrTypes = new List<String> {'Bill To', 'End User', 'Ship To', 'Sold To'};
        for(Integer i=0; i<list_addrTypes.size(); i++ ){
            Account_Order_Address__c objNewAOA = new Account_Order_Address__c();
            objNewAOA.Zuora_Quote__c = quoteId;
            objNewAOA.Address_Type__c = list_addrTypes[i];
            objNewAOA.Address__c = 'Address 1 - '+i;
            objNewAOA.Address2__c = 'Address 2 - '+i;
            objNewAOA.City__c = 'City'+i;
            objNewAOA.State__c = 'State'+i;
            objNewAOA.Country__c = 'US';
            objNewAOA.Sort_Order__c = i+1;
            objNewAOA.Email__c = 'test@test.com';
            list_NewAOAs.add(objNewAOA);
        }
        
        insert list_NewAOAs;
        return list_NewAOAs;  
    }
    
    // *** Method to pull record types of a sobject ***
    private static Map<String, RecordType> getOrderRecordTypes(String strObjType) {
        Map<String, RecordType> map_rts = new Map<String, RecordType>();
        for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType =: strObjType]) {
            map_rts.put(recType.Name, recType);
        }
        return map_rts;
    }
}