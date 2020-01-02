@isTest
public class BatchCreateCloudMonthlySalesOrdersTest  {
    static Boolean blnUseBillingConversionRate = true;
    static private Date dtQuoteStartDate = Date.newInstance(2017,5,1);
    static private Date dtOrderStartDate = Date.newInstance(2017,5,1);
    static private Date dtContractStartDate = Date.newInstance(2017,6,1);
    // Keep this creation in line with the above date
    static private CloudBillingData getCloudBillingDataConsistent() {
        return new CloudBillingData(true, '6' , '2017' , '30');
    }
    
    @testSetup
    public static void setUpData() {
        {
            Util.Bypass_Trigger_Chk = true;
            String strOfferingType = 'PureEngage Cloud';
            String strPricingModel = 'User';
            List<Account> list_Accounts = TestUtil.createAccounts(1,false);
            list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
            insert list_Accounts;
            Account objAccount = list_Accounts[0];
            Opportunity objOpportunity  = TestUtil.createOpportunities(1,objAccount.id, false)[0];
            objOpportunity.Lines_of_Businesses__c = strOfferingType;
            insert objOpportunity;
            BigMachines__Quote__c objQuote = setupQuote('PureEngage Cloud Test', objAccount, objOpportunity, strOfferingType, strPricingModel);
            insert objQuote;
            GCR_Content_Document_Detail__c objContract = setupContracts(objQuote);
            Genesys_Entity__c objGenEntity = setupGenesysEntity();
            objContract.Genesys_Entity__c = objGenEntity.id;
            insert objContract;
    
            List<Product2> list_Products = TestUtil.createProducts(5, false);
            for(integer i = 0 ; i < list_Products.size() ; i++){
                list_Products[i].APN_Number__c = 'APNABC'+i;
                list_Products[i].Unit_of_Measure__c = 'Per Month';
            }
            insert list_Products;
            Order__c objOrder = setupOrder(objContract);
            objOrder.Order_Date__c = dtOrderStartDate;
            objOrder.CurrencyIsoCode = 'USD';
            insert objOrder;
            List<Contract_Tier_Set__c> list_ContractTS = setupTierSets(objContract.id , list_Products);
            insert list_ContractTS;
            List<Contract_Tier_Set_Month__c> list_CTSM = getListTierSetMonth(1, list_ContractTS);
            List<SureTax_Settings__c> list_SureTaxSettings =  setupSureTaxSettings();
            List<Contract_Tier_Set_Month_Charges__c> list_CTSMC  = setupContractTierSetMonthCharges(list_CTSM);
            List<BOGO_Detail__c> list_BOGO = setupBOGODetail(list_ContractTS);
            setupContractRecurringCharges(list_ContractTS);
    
            // Setup standard contract with regular Quote
            objQuote.Order__c = objOrder.Id;
            update objQuote;
            //objContract = setupContracts(objQuote);
            //insert objContract;
    
            Billing_Conversion_Rate__c objBillingConversionRate = new Billing_Conversion_Rate__c (
                CurrencyIsoCode = 'CAD',
                To_Currency_Code__c = 'USD',
                From_Date__c = dtContractStartDate,
                To_Date__c = dtContractStartDate.addMonths(1).addDays(-1),
                Average_Conversion_Rate__c = 0.76
            );
            insert objBillingConversionRate;
        }

        List<Product2> listProducts = [SELECT Id, Name, APN_Number__c FROM Product2 ORDER BY name];
        for (Product2 objProduct : listProducts) {
            System.Debug('objProduct ' + objProduct);
        }
        List<GCR_Content_Document_Detail__c> listContracts = [select Id, Name from GCR_Content_Document_Detail__c];
        for (GCR_Content_Document_Detail__c objContractLoad : listContracts) {
            System.debug('objContractLoad ' + objContractLoad);
        }
        List<BigMachines__Quote__c> listQuotes = [select id, Name from BigMachines__Quote__c];
        Set<Id> setQuoteIds = new Set<Id>();
        Map<Id, List<BigMachines__Quote_Product__c>> mapQuoteToQP = new Map<Id, List<BigMachines__Quote_Product__c>>();
        for (BigMachines__Quote__c objQuoteLoad : listQuotes) setQuoteIds.add(objQuoteLoad.Id);
        List<BigMachines__Quote_Product__c> listQPs = [select Id, Name, BigMachines__Quote__c from BigMachines__Quote_Product__c];
        for (BigMachines__Quote_Product__c objQP : listQPs) {
            if (mapQuoteToQP.containsKey(objQP.BigMachines__Quote__c)) {
                mapQuoteToQP.get(objQP.BigMachines__Quote__c).add(objQP);
            } else {
                mapQuoteToQP.put(objQP.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c>{objQP});
            }
        }
        for (BigMachines__Quote__c objQuoteLoad : listQuotes) {
            System.Debug('objQuoteLoad ' + objQuoteLoad);
            List<BigMachines__Quote_Product__c> listQP = mapQuoteToQP.get(objQuoteLoad.Id);
            if (listQP != null && listQP.size() > 0) {
                for (BigMachines__Quote_Product__c objQP : listQP) {
                    System.Debug(' objQP ' + objQP);
                }
            } else {
                System.Debug('No Quote Products');
            }
        }
        
        Product_Group__c objProductGroup = new Product_Group__c(
            Name = 'Base Product Group',
            Offering_Type__c = 'PureEngage Cloud',
            Group_Type__c = 'Base Package',
            Pricing_Model__c = 'User',
            Active__c = true
        );
        
        Integer i= 0;
        if (listProducts.size() > 1) {
            objProductGroup.Product__c = listProducts[i].id;
            insert objProductGroup;
            i++;
            List<Product_Group_Item__c> listProductGroupItems = new List<Product_Group_Item__c>();
            while (i < listProducts.size()) {
                Product_Group_Item__c objPGI = new Product_Group_Item__c(
                    Product_Group__c = objProductGroup.Id,
                    Product__c = listProducts[i].id,
                    Price_Weightage__c = 100
                );
                listProductGroupItems.add(objPGI);
                i++;
            }
            insert listProductGroupItems;
        } else {
            System.assert(false, 'Not Enough Products Saved');
        }

    }
    private static testmethod void testAddAllContractStartDates(){
        System.debug('Test: testAddAllContractStartDates');
        // Non-Leap year Feb 28
        BatchCreateCloudMonthlySalesOrders.addAllContractStartDates(2015,2,28);
        // Leap Year Feb 29
        BatchCreateCloudMonthlySalesOrders.addAllContractStartDates(2016,2,29);
    }

    private static testmethod void testBatch(){
        System.debug('Test: testBatch');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        System.debug('testBatch got contract ' + objContract);
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c, Contract__r.Product_Group__c
                                               FROM Contract_Tier_Set__c
                                               WHERE Contract__c = :objContract.Id];
        System.Debug('list_CTS size ' + list_CTS.size());
        for (Contract_Tier_Set__c objCTS : list_CTS) {
            System.Debug('objCTS ' + objCTS);
        }
        
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        
        Contract_Tier_Range__c objRange = new Contract_Tier_Range__c(To__c = 12.0 , Price__c = 12.0, From__c=5.0, Contract_Tier_Set__c = list_CTS[0].id);
        insert objRange;
        list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                    Period_In_Months__c, Aggregation_Model__c, Contract__r.Product_Group__c,
                    (SELECT id, To__c, From__c, Price__c, Contract_Tier_Set__c FROM Contract_Tier_Ranges__r  )
                    FROM Contract_Tier_Set__c];        
        
        Test.startTest();
        List<Order_Line_Item__c> list_OrderLineItemsForTierSet = new List<Order_Line_Item__c>();
        Date dtFirstOfBillingMonth = dtContractStartDate.addMonths(1);
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Database.executeBatch(objBatch, 1);
        objContract.Outbound_Rate_Table_Discount__c = 5;
        objBatch.intLineCount = 0;
        objBatch.map_ConversionRates = map_ConversionRates;
        objBatch.createOLIOutboundRatingTable(objContract, objOrder, list_CTS[0], list_OrderLineItemsForTierSet, 10, 20, 30, 'test', 2);
        objBatch.createOLIOutboundRatingTable(objContract, objOrder, list_CTS[0], list_OrderLineItemsForTierSet, 10, null, null, 'test', 2);
        objBatch.createOLIInboundRatingTable(objContract, objOrder, list_CTS[0], list_OrderLineItemsForTierSet, 10, 20, 30, 'test', 2);
        objBatch.createOLIInboundRatingTable(objContract, objOrder, list_CTS[0], list_OrderLineItemsForTierSet, 10, null, null, 'test', 2);
        
        list_CTS[0].Aggregation_Model__c=  'Lookback';
        
        Order_Line_Item__c objOLI = new Order_Line_Item__c();
        objOLI.Quantity__c = 1;
        objOLI.Net_Unit_Price__c = 1;
        objOLI.Ext_Net_Price__c = 1;
        list_OrderLineItemsForTierSet.add(objOLI);
        
        objBatch.createOLIStandard(list_CTS[0], list_OrderLineItemsForTierSet, 'test notes' , 1, null, null,  null, 'test', 2);
        Test.stopTest();
    }
    
    
    private static testmethod void testBatch2(){
        System.debug('Test: testBatch2');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c, Contract__r.Product_Group__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Tier_Set_Month_Charges__c> list_CTSMC  = [SELECT id FROM Contract_Tier_Set_Month_Charges__c];
        delete list_CTSMC;
        List<Contract_Tier_Set_Month__c> list_CTSM = [SELECT id FROM Contract_Tier_Set_Month__c];
        delete list_CTSM ; 
        List<Contract_Tier_Set__c> list_ContractTS = [SELECT id FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.id];
        getListTierSetMonth(2, list_ContractTS);
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch3(){
        System.debug('Test: testBatch3');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Tier_Set_Month_Charges__c> list_CTSMC  = [SELECT id FROM Contract_Tier_Set_Month_Charges__c];
        delete list_CTSMC;
        List<Contract_Tier_Set_Month__c> list_CTSM = [SELECT id FROM Contract_Tier_Set_Month__c];
        delete list_CTSM ; 
        List<Contract_Tier_Set__c> list_ContractTS = [SELECT id FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.id];
        getListTierSetMonth(2, list_ContractTS);
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch4(){
        System.debug('Test: testBatch4');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c, Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        
        Contract_Tier_Range__c objRange = new Contract_Tier_Range__c(To__c = 12.0 , Price__c = 12.0, From__c=5.0, Contract_Tier_Set__c = list_CTS[0].id);
        insert objRange;
        list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                    Period_In_Months__c, Aggregation_Model__c, 
                    (SELECT id, To__c, From__c, Price__c, Contract_Tier_Set__c FROM Contract_Tier_Ranges__r  )
                    FROM Contract_Tier_Set__c];        
        
        Test.startTest();
        List<Order_Line_Item__c> list_OrderLineItemsForTierSet = new List<Order_Line_Item__c>();
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch5(){
        System.debug('Test: testBatch5');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Tier_Set_Month_Charges__c> list_CTSMC  = [SELECT id FROM Contract_Tier_Set_Month_Charges__c];
        delete list_CTSMC;
        List<Contract_Tier_Set_Month__c> list_CTSM = [SELECT id FROM Contract_Tier_Set_Month__c];
        delete list_CTSM ; 
        List<Contract_Tier_Set__c> list_ContractTS = [SELECT id FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.id];
        getListTierSetMonth(0, list_ContractTS);
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch6(){
        System.debug('Test: testBatch6');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Tier_Set__c> list_ContractTS = [SELECT id FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.id];
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'Installment Plan';
        }
        update list_CRC;
        getListTierSetMonth(0, list_ContractTS);
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch7(){
        System.debug('Test: testBatch7');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'Monthly Access Fee';
        }
        update list_CRC;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch8(){
        System.debug('Test: testBatch8');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'Commitment Shortfall';
        }
        update list_CRC;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch9(){
        System.debug('Test: testBatch9');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'Variable Term Flat Fee';
        }
        update list_CRC;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch10(){
        System.debug('Test: testBatch10');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'One Time Flat Fee';
        }
        update list_CRC;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch11(){
        System.debug('Test: testBatch11');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'Units In Plan';
        }
        update list_CRC;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch12(){
        System.debug('Test: testBatch12');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Recurring_Charge__c> list_CRC = [SELECT id, Type__c FROM Contract_Recurring_Charge__c];
        for(Contract_Recurring_Charge__c objCRC : list_CRC){
            objCRC.Type__c = 'Business Care';
        }
        update list_CRC;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch13(){
        System.debug('Test: testBatch13');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c , Invoice_Type__c, Inbound_Billing_Type__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Invoice_Type__c = 'Cloud Deployment Breakout';
        objContract.Inbound_Billing_Type__c = 'Inbound Rate Table';
        update objContract;
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Product2 objProduct = [SELECT id, APN_Number__c, Unit_of_Measure__c FROM Product2 LIMIT 1];
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        objBatch.intLineCount = 0;
        objBatch.createProductOrderLineItem(objProduct, 'Test Description');
        
        Test.stopTest();
    }
    
    
    
    private static testmethod void testBatch14(){
        System.debug('Test: testBatch2');
        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<Contract_Tier_Set__c> list_CTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                                               Period_In_Months__c, Aggregation_Model__c, Contract__r.Product_Group__c
                                               FROM Contract_Tier_Set__c];
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        List<Contract_Tier_Set_Month_Charges__c> list_CTSMC  = [SELECT id FROM Contract_Tier_Set_Month_Charges__c];
        delete list_CTSMC;
        List<Contract_Tier_Set_Month__c> list_CTSM = [SELECT id FROM Contract_Tier_Set_Month__c];
        delete list_CTSM ; 
        List<Contract_Tier_Set__c> list_ContractTS = [SELECT id FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.id];
        getListTierSetMonth(2, list_ContractTS);
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Test.startTest();
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
    private static testmethod void testBatch15(){
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunitySub  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunitySub.Lines_of_Businesses__c = 'PureEngage';
        objOpportunitySub.Primary_Line_of_Business__c = 'On Premise';
        objOpportunitySub.Offering_Detail__c = 'Subscription';
        insert objOpportunitySub;
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
        }
        insert list_Products;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
      
        update standardPricebook;
       
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries( list_Products, true);
        objOpportunitySub.Pricebook2Id = standardPricebook.id;
        update objOpportunitySub;
        BigMachines__Quote__c objQuoteSub = TestUtil.createQuotes(1,objOpportunitySub.id,false)[0];
        objQuoteSub.Offering_Type__c = 'PureEngage Subscription';
        objQuoteSub.BigMachines__Is_Primary__c = true;
        objQuoteSub.Subscription_End_Date__c = dtQuoteStartDate+60;
        insert objQuoteSub;
        MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objQuoteSub.id));
        OpportunityQuotes.populateOpportunityProducts(String.valueof(objQuoteSub.id));
        GCR_Content_Document_Detail__c objContractSub = setupContractSub(objQuoteSub);
        Genesys_Entity__c objGenEntity1 = setupGenesysEntity();
        objContractsub.Genesys_Entity__c = objGenEntity1.id;
        insert objContractSub;

        // Debug Logs
        List<GCR_Content_Document_Detail__c> listContractTest = [SELECT id , Pricing_Start_Date__c,Product_Group__c, Document_Name__c,
                                                                 Quote__r.Offering_Type__c, Quote__r.BigMachines__Opportunity__r.Offering_Detail__c
                                                                 FROM GCR_Content_Document_Detail__c];
        for (GCR_Content_Document_Detail__c objContractTest : listContractTest) {
			System.debug('');
            System.debug('objContractTest ' + objContractTest);
            System.debug('objContractTest.Product_Group__c ' + objContractTest.Product_Group__c);
            System.debug('objContractTest.Quote__r.Offering_Type__c ' + objContractTest.Quote__r.Offering_Type__c);
            System.debug('objContractTest.Quote__r.BigMachines__Opportunity__r.Offering_Detail__c ' + objContractTest.Quote__r.BigMachines__Opportunity__r.Offering_Detail__c);
        }

        GCR_Content_Document_Detail__c objContract = [SELECT id , Pricing_Start_Date__c,Product_Group__c FROM GCR_Content_Document_Detail__c where Quote__r.Offering_Type__c like '%Subscription%' LIMIT 1];
        Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        
        
        List<BigMachines__Quote_Product__c>  list_QuoteProducts = TestUtil.createQuoteProducts(5,false,objQuoteSub.id);
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            list_QuoteProducts[i].BigMachines__Product__c = list_Products[i].id;
        }
        insert list_QuoteProducts;
        List<Contract_Tier_Set__c> list_ContractTS = setupTierSets(objContract.id , list_Products);
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            list_ContractTS[i].Quote_Product__c = list_QuoteProducts[i].id;
        }
        insert list_ContractTS;
        Contract_Tier_Range__c objRange1 = new Contract_Tier_Range__c(To__c = 5.0 , Price__c = 12.0, From__c=0.0, Contract_Tier_Set__c = list_ContractTS[0].id);
        Contract_Tier_Range__c objRange2 = new Contract_Tier_Range__c(To__c = 8.0 , Price__c = 12.0, From__c=5.0, Contract_Tier_Set__c = list_ContractTS[0].id);
        Contract_Tier_Range__c objRange3 = new Contract_Tier_Range__c(To__c = 8.0 , Price__c = 12.0, From__c=25.0, Contract_Tier_Set__c = list_ContractTS[0].id);
        insert objRange1;
        insert objRange2;
        insert objRange3;
        list_ContractTS = [SELECT id, Name, Quote_Product__c, Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                           Period_In_Months__c, Aggregation_Model__c, Contract__r.Product_Group__c,
                           (SELECT id, To__c, From__c, Price__c, Contract_Tier_Set__c FROM Contract_Tier_Ranges__r  )
                           FROM Contract_Tier_Set__c where Contract__c  =:  objContract.id]; 
        List<Contract_Tier_Set_Month__c> list_PreviousTierSetMonthsForThisOrder = getListTierSetMonth(1, list_ContractTS);
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        objCloudBillingData.contractId = objContract.Id ;
        objCloudBillingData.subsidiary = 'All';
        objCloudBillingData.region = 'All';
        objCloudBillingData.edition = 'All';
        objCloudBillingData.day =  objContract.Pricing_Start_Date__c.day()+'';
        objCloudBillingData.blnIsPreBill = false;
        Account_Order_Address__c objAccountAddressEndUser =  new Account_Order_Address__c(Address_Type__c = 'End User',Account__c=list_Accounts[0].id,GCR_Content_Document_Detail__c	= objContract.id);
        insert objAccountAddressEndUser;
        Account_Order_Address__c objAccountAddressShipTo =  new Account_Order_Address__c(Address_Type__c = 'Ship To',Account__c=list_Accounts[0].id,GCR_Content_Document_Detail__c	= objContract.id);
        insert objAccountAddressShipTo;
        Account_Order_Address__c objAccountAddressBillTo =  new Account_Order_Address__c(Address_Type__c = 'Bill To',Account__c=list_Accounts[0].id,GCR_Content_Document_Detail__c	= objContract.id);
        insert objAccountAddressBillTo;
        Test.startTest();
        List<Order_Line_Item__c> list_OrderLineItemsForTierSet = new List<Order_Line_Item__c>();
        Date dtFirstOfBillingMonth = dtContractStartDate;
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        objBatch.map_BurstedProduct= new  map<BigMachines__Quote_Product__c,decimal>{list_QuoteProducts[0]=>10.00};
            objBatch.map_BurstContractTierSet = new map <ID,Decimal>{list_ContractTS[0].id=>10.00};
        objBatch.map_BurstContractTierSetPrice = new Map<ID,Decimal>{list_ContractTS[0].id=>10.00};
        objBatch.map_IDToQproducts = new Map<ID,BigMachines__Quote_Product__c>();
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            objBatch.map_IDToQproducts.put(list_QuoteProducts[i].id,list_QuoteProducts[i]);
        }
        for(integer i = 0 ;i < list_ContractTS.size();i++) {
            objBatch.map_BurstContractTierSet.put(list_ContractTS[i].id,10.00);
        }
         for(integer i = 0 ;i < list_ContractTS.size();i++) {
            objBatch.map_BurstContractTierSetPrice.put(list_ContractTS[i].id,10.00);
        }
        Database.executeBatch(objBatch, 1);
        objContract.Outbound_Rate_Table_Discount__c = 5;
        objBatch.intLineCount = 0;
        objBatch.map_ConversionRates = map_ConversionRates;
        objBatch.createOLIOutboundRatingTable(objContract, objOrder, list_ContractTS[0], list_OrderLineItemsForTierSet, 10, 20, 30, 'test', 2);
        objBatch.createOLIOutboundRatingTable(objContract, objOrder, list_ContractTS[0], list_OrderLineItemsForTierSet, 10, null, null, 'test', 2);
        objBatch.createOLIInboundRatingTable(objContract, objOrder, list_ContractTS[0], list_OrderLineItemsForTierSet, 10, 20, 30, 'test', 2);
        objBatch.createOLIInboundRatingTable(objContract, objOrder, list_ContractTS[0], list_OrderLineItemsForTierSet, 10, null, null, 'test', 2);
        Order_Line_Item__c objOLI = new Order_Line_Item__c();
        objOLI.Quantity__c = 1;
        objOLI.Net_Unit_Price__c = 1;
        objOLI.Ext_Net_Price__c = 1;
        list_OrderLineItemsForTierSet.add(objOLI);
        list_ContractTS[0].Aggregation_Model__c=  'Max Per Month';	  
        objBatch.createOLIStandard(list_ContractTS[0], list_OrderLineItemsForTierSet, 'test notes' , 1, 10,list_PreviousTierSetMonthsForThisOrder,  null, 'test', 10);
        Test.stopTest();
    }
    static List<Cloud_Deployment__c> setupCloudDeployments(List<GCR_Content_Document_Detail__c> list_Contracts){
        List<Cloud_Deployment__c> list_CloudDeployments = new List<Cloud_Deployment__c>();
        
        for(GCR_Content_Document_Detail__c objContract : list_Contracts){
            Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
            objCloudDeployment.Account__c = objContract.Account_Name__c;
            //objCloudDeployment.Cloud_Billing_Contract__c = objContract.id ;
            objCloudDeployment.Cloud_Platform__c = 'PureCloud';
            objCloudDeployment.PureCloud_OrgID__c = objContract.Account_Name__c + '#'+ objContract.id ;
            list_CloudDeployments.add(objCloudDeployment);
        }
        insert list_CloudDeployments;
        return list_CloudDeployments;
    }
    
    public static zqu__Quote__c setupZuoraQuote(String strName, String strAccId , String strOppId, Integer intPeriod ){
        zqu__Quote__c objZquQuote = new zqu__Quote__c();
        objZquQuote.Name = strName;
        objZquQuote.zqu__Account__c = strAccId;
        objZquQuote.zqu__Opportunity__c = strOppId;
        objZquQuote.PureCloud_Ramp_Up_Period__c = intPeriod;
        return objZquQuote;
    }
    public static BigMachines__Quote__c setupQuote(String strName, Account objAccount, Opportunity objOpp, String strOfferingType, String strPricingModel) {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(Name = strName,
                                                                   BigMachines__Account__c = objAccount.Id,
                                                                   BigMachines__Opportunity__c = objOpp.Id,
                                                                   Offering_Type__c = strOfferingType,
                                                                   Pricing_Model__c = strPricingModel);
        return objQuote;    }

    // Remove Zuora
    public static GCR_Content_Document_Detail__c setupContractsZ(zqu__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = objQuote.zqu__Account__c;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Zuora_Quote__c = objQuote.id;
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = dtContractStartDate;
        return objContract;
    }
    public static GCR_Content_Document_Detail__c setupContracts(BigMachines__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = objQuote.BigMachines__Account__c;
        objContract.Quote__c = objQuote.id;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = dtContractStartDate;
        return objContract;
    }
    
    public static GCR_Content_Document_Detail__c setupContractSub(BigMachines__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        // objContract.Account_Name__c = objQuote.zqu__Account__c;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Quote__c = objQuote.id;
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = dtContractStartDate;
        return objContract;
    }
    
    public static Genesys_Entity__c setupGenesysEntity(){
        Genesys_Entity__c objGenEntity = new Genesys_Entity__c();
        objGenEntity.Remit_To__c = 'Test Remit To Info';
        objGenEntity.Selling_Entity__c = 'Test Selling Entity Info';
        objGenEntity.CurrencyIsoCode = 'USD';
        insert objGenEntity;
        return objGenEntity;
    }
    
    public static List<SureTax_Settings__c> setupSureTaxSettings(){
        Product2 objProduct = [SELECT id FROM Product2 LIMIT 1];
        List<SureTax_Settings__c> list_SureTaxDesciption = new List<SureTax_Settings__c>();
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '100' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '101' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '102' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = '103' , Value__c = 'Test Tax 1'));
        list_SureTaxDesciption.add(new SureTax_Settings__c(name = 'Product' , Value__c = objProduct.id));
        insert list_SureTaxDesciption;
        return list_SureTaxDesciption;
    }
    
    public static Order__c setupOrder(GCR_Content_Document_Detail__c objContract){
        Order__c objOrder = new Order__c(Name = 'Test Order');
        objOrder.Contract_Lookup__c = objContract.Id;
        objOrder.Month__c = '6';
        objOrder.Year__c = '2017';
        objOrder.status__c = 'In Progress';
        objOrder.End_User_Name__c = objOrder.Bill_To_Name__c = objOrder.Sold_To_Name__c = objOrder.Ship_To_Name__c = objContract.Account_Name__c ;
        objOrder.Opportunity__c = objContract.Zuora_Quote__r.zqu__Opportunity__c;
        return objOrder;
    }
    
    static List<Contract_Tier_Set_Month__c> getListTierSetMonth(Integer intServiceType, List<Contract_Tier_Set__c> list_CTS) {
        List<id> list_ids = new List<id>();
        for(Contract_Tier_Set__c objCTS : list_CTS ){
            list_ids.add(objCTS.id);
            Contract_Tier_Set_Period__c ctsp1 = new Contract_Tier_Set_Period__c();
            insert ctsp1;
            Contract_Tier_Set_Month__c ctsm1 = new Contract_Tier_Set_Month__c(Contract_Tier_Set_Period__c = ctsp1.Id , Contract_Tier_Set__c = objCTS.id, 
                                                                              Month__c = '6' , Year__c = '2017');
            insert ctsm1;
            Service_Usage__c su1 = new Service_Usage__c(Count__c = 2, Quantity__c = 5, Cost__c = 0.1, Service_Type__c = intServiceType, Contract_Tier_Set_Month__c = ctsm1.Id);
            Service_Usage__c su2 = new Service_Usage__c(Count__c = 5, Quantity__c = 10, Cost__c = 0.2, Service_Type__c = intServiceType, Contract_Tier_Set_Month__c = ctsm1.Id);
            insert su1;
            insert su2;
        }
        // Have to get from DB to populate Formula Fields
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = [SELECT id,
                                                                      Sum_Count__c,
                                                                      Max_Usage__c,
                                                                      Total_Usage__c,
                                                                      Total_Outbound_Calls_Cost__c,
                                                                      Total_Inbound_Calls_Cost__c, Contract_Tier_Set__c
                                                                      FROM Contract_Tier_Set_Month__c WHERE Contract_Tier_Set__c = :list_ids];
        return list_ContractTierSetMonth;
    }
    
    static List<Contract_Tier_Set__c> setupTierSets(Id contractId , List<Product2> list_Products){
        List<Contract_Tier_Set__c> list_ContractTS = new List<Contract_Tier_Set__c>();
        for(Product2 objProd : list_Products){
            list_ContractTS.add( new Contract_Tier_Set__c(Name = 'Test '+objProd.Name , 
                                                          Product__c = objProd.id ,
                                                          Period_In_Months__c = '6', 
                                                          Contract__c = contractId , Is_Deleted__c = false) );
        }
        return list_ContractTS;
    }
    
    static List<Contract_Tier_Set_Month_Charges__c> setupContractTierSetMonthCharges(List<Contract_Tier_Set_Month__c> list_CTSM){
        List<Contract_Tier_Set_Month_Charges__c> list_CTSMC = new List<Contract_Tier_Set_Month_Charges__c>();
        for(Contract_Tier_Set_Month__c objCTSM : list_CTSM){
            Contract_Tier_Set_Month_Charges__c objCTSMC = new Contract_Tier_Set_Month_Charges__c(Contract_Tier_Set_Month__c = objCTSM.id, 
                                                                                                 Amount__c = 10, Description__c = '102');    
            list_CTSMC.add(objCTSMC);
        }
        insert list_CTSMC;
        return list_CTSMC;
    }
    
    static List<BOGO_Detail__c> setupBOGODetail(List<Contract_Tier_Set__c> list_CTS){
        List<BOGO_Detail__c> list_BOGO = new List<BOGO_Detail__c>();
        for(Contract_Tier_Set__c objCTS : list_CTS){
            BOGO_Detail__c objBOGO = new BOGO_Detail__c(Is_Deleted__c = false , Parent_Quantity__c = 2, Parent_Tier_Set__c = objCTS.id , Prorate__c = true,
                                                        Related_Quantity__c = 2, Related_Tier_Set__c = list_CTS[0].id);
            list_BOGO.add(objBOGO);
        }
        insert list_BOGO;
        return list_BOGO;
    }
    
    static List<Contract_Recurring_Charge__c> setupContractRecurringCharges(List<Contract_Tier_Set__c> list_CTS){
        List<Contract_Recurring_Charge__c> list_CRC = new List<Contract_Recurring_Charge__c>();
        
        for(Contract_Tier_Set__c objCTS : list_CTS){
            Contract_Recurring_Charge__c objCRC = new Contract_Recurring_Charge__c(Is_Deleted__c = false , 
                                                                                   Active__c = true, 
                                                                                   Contract_Tier_Set__c = objCTS.id , 
                                                                                   Units__c = 2,
                                                                                   Amount__c = 2.0 , 
                                                                                   Type__c = 'Monthly Flat Fee' , 
                                                                                   External_Note__c = 'Test Note' , 
                                                                                   Pre_Bill__c = false , 
                                                                                   Business_Care_Min_Revenue_Threshold__c = 1,
                                                                                   Business_Care_Max_Revenue_Threshold__c = 2 ,
                                                                                   Business_Care_Support_Fee_Percentage__c = 1 , 
                                                                                   Deferred__c = true);
            
            list_CRC.add(objCRC);
            Contract_Recurring_Charge__c objCRC2 = new Contract_Recurring_Charge__c(Is_Deleted__c = false , 
                                                                                   Active__c = true, 
                                                                                   Contract_Tier_Set__c = objCTS.id , 
                                                                                   Units__c = 2,
                                                                                   Amount__c = 2.0 , 
                                                                                   Type__c = 'Commitment Shortfall' , 
                                                                                   External_Note__c = 'Test Note' , 
                                                                                   Pre_Bill__c = false , 
                                                                                   Business_Care_Min_Revenue_Threshold__c = 1,
                                                                                   Business_Care_Max_Revenue_Threshold__c = 2 ,
                                                                                   Business_Care_Support_Fee_Percentage__c = 1 , 
                                                                                   Deferred__c = true);
            
            list_CRC.add(objCRC2);
        }
        
        insert list_CRC;
        return list_CRC;
    }
    static List<Contract_Tier_Set__c> getListContractTierSetForOrderCreation() {
        List<Contract_Tier_Set__c> listContractTierSetForOrderCreation = [
            SELECT Id,Name,Aggregation_Model__c,Contract__c,Product__c,Quote_Product__c,
            Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Period_In_Months__c, Product__r.SureTax_Code_Undetermined__c,
            Contract__r.Account_Name__r.Subsidary__r.Name, Contract__r.Product_Group__c,
            (SELECT Id, To__c,From__c,Price__c FROM Contract_Tier_Ranges__r WHERE Is_Deleted__c = false ORDER BY From__c),
            (SELECT Contract_Tier_Set__c,Contract_Tier_Set__r.RC_Period__c,Units__c,Amount__c,Type__c, External_Note__c,Pre_Bill__c,
             Business_Care_Min_Revenue_Threshold__c, Business_Care_Max_Revenue_Threshold__c, Business_Care_Support_Fee_Percentage__c,
             Deferred__c, Contract_Tier_Set__r.Period_In_Months__c, Quantity__c, Rate__c
             FROM Contract_Recurring_Charges__r 
             WHERE Active__c = true AND Is_Deleted__c = false),
            (SELECT Id, Total_Usage__c,Total_Outbound_Calls_Cost__c, Total_Inbound_Calls_Cost__c,
             Max_Usage__c,Max_Usage_AP__c,Max_Usage_EU__c,Max_Usage_US__c, Source_Name__c, Platform_Id__c,
             Contract_Tier_Set_Period__c, Sum_Count__c, Sum_Usage__c
             FROM Contract_Tier_Set_Month__r 
             //WHERE Month__c = :strMonth AND Year__c = :strYear
            ),
            (SELECT Parent_Quantity__c,Related_Quantity__c,Related_Tier_Set__c,Prorate__c FROM BOGO_Details__r
             WHERE Is_Deleted__c = false)
            FROM Contract_Tier_Set__c WHERE //Contract__c IN :list_Contracts AND
            Is_Deleted__c = false
        ];
        return listContractTierSetForOrderCreation;
    }
    
    private static testmethod void testRateTable(){
        List<Order_Line_Item__c> objListOLI = new List<Order_Line_Item__c>();
        Order__c objOrder = new Order__c(CurrencyISOCode = 'USD');
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c(Outbound_Rate_Table_Discount__c = 10);
        List<Contract_Tier_Set__c> listCS = getListContractTierSetForOrderCreation();
        for (Contract_Tier_Set__c cs : listCS) {
        }
        Contract_Tier_Set__c objCTS = listCS[0];
        System.debug('objCTS ' + objCTS);
        System.debug('objCTS.Contract__r.Product_Group__c ' + objCTS.Contract__r.Product_Group__c);
        Contract_Tier_Set_Month__c objCTSM = new Contract_Tier_Set_Month__c();
        
        CloudBillingData objCloudBillingData = new CloudBillingData();
        BatchCreateCloudMonthlySalesOrders objBatchCreateCloudMonthlySalesOrders = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        objBatchCreateCloudMonthlySalesOrders.objJobLog = new Cloud_Billing_Log__c();
        objBatchCreateCloudMonthlySalesOrders.intLineCount = 0;
        objBatchCreateCloudMonthlySalesOrders.map_ConversionRates = new Map<String,Decimal>();
        objBatchCreateCloudMonthlySalesOrders.map_ConversionRates.put('USD', 1.0);
        
        // Set nulls
        System.Debug('Test 1');
        objBatchCreateCloudMonthlySalesOrders.createOLIOutboundRatingTable(objContract, objOrder, objCTS, objListOLI, 1, null, null, 'cloudDeployment', 10);
        System.Debug('Test 2');
        objBatchCreateCloudMonthlySalesOrders.createOLIInboundRatingTable(objContract, objOrder, objCTS, objListOLI, 1, null, null, 'cloudDeployment', 10);
        
        //Standard
        System.Debug('Test 3');
        objBatchCreateCloudMonthlySalesOrders.createOLIOutboundRatingTable(objContract, objOrder, objCTS, objListOLI, 1, 10, 13, 'cloudDeployment', 10);
        System.Debug('Test 4');
        objBatchCreateCloudMonthlySalesOrders.createOLIInboundRatingTable(objContract, objOrder, objCTS, objListOLI, 1, 10, 13, 'cloudDeployment', 10);
        
        // No Currency conversion found
        objOrder.CurrencyISOCode = 'GBP';
        objBatchCreateCloudMonthlySalesOrders.map_ConversionRates = new Map<String,Decimal>();
        // Force appearance of no rate found
        objBatchCreateCloudMonthlySalesOrders.map_ConversionRates.put('GBP', 0.0);
        
        System.debug('objCTS ' + objCTS);
        System.debug('objCTS.Contract__r.Product_Group__c ' + objCTS.Contract__r.Product_Group__c);
        System.Debug('Test 5');
        try {
            objBatchCreateCloudMonthlySalesOrders.createOLIOutboundRatingTable(objContract, objOrder, objCTS, objListOLI, 1, 10, 13, 'cloudDeployment', 10);
        } catch (Exception e) {
            System.Assert(true);
        }
        System.Debug('Test 6');
        try {
            objBatchCreateCloudMonthlySalesOrders.createOLIInboundRatingTable(objContract, objOrder, objCTS, objListOLI, 1, 10, 13, 'cloudDeployment', 10);
        } catch (Exception e) {
            System.Assert(true);
        }
    }    
    private static testmethod void testIsBillingLastMonthRegionAndEdition() {
        CloudBillingData objCloudBillingData = new CloudBillingData(true, '6' , '2017' , '28');
        objCloudBillingData.subsidiary = '8100'; // For the test
        objCloudBillingData.region = 'North America'; // For the test
        objCloudBillingData.edition = 'PureConnect'; // For the test
        objCloudBillingData.blnIsPreBill = false;

        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        Database.executeBatch(objBatch, 1);
    }

    private static testmethod void testIsActiveCommitmentShortfall() {
        List<Contract_Tier_Set__c> listTierSets = [select (select Type__c from Contract_Recurring_Charges__r) from Contract_Tier_Set__c];
        Contract_Tier_Set__c objTierSet = null;
        for(Contract_Tier_Set__c objContractTierSetInLoop : listTierSets) {
            for (Contract_Recurring_Charge__c objRecurringCharge : objContractTierSetInLoop.Contract_Recurring_Charges__r) {
                if (objRecurringCharge.Type__c == 'Commitment Shortfall') {
                    objTierSet = objContractTierSetInLoop;
                    break;
                }
            }
        }
        BatchCreateCloudMonthlySalesOrders.isActiveCommitmentShortfall(objTierSet);
    }

    private static testmethod void testSetOrderLineItemUncommited(){
        Order_Line_Item__c objOLI = new Order_Line_Item__c();
        BatchCreateCloudMonthlySalesOrders.setOrderLineItemUncommited(objOLI);
    }
    private static testmethod void testCreateBasePackageLinesforQuote() {
            BigMachines__Quote_Product__c objQuoteProduct = new BigMachines__Quote_Product__c(Ext_Net_Price__c = 500,
                                                                                              Quantity__c = 1,
                                                                                              List_Price__c = 500
                                                                                              );
            BatchCreateCloudMonthlySalesOrders.createBasePackageLinesforQuote(objQuoteProduct, 'PureEngage Cloud', 'User');

    }
    private static testmethod void testCreateBasePackageLinesforOrder() {
        CloudBillingData objCloudBillingData = getCloudBillingDataConsistent();
        BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(objCloudBillingData);
        List<Contract_Tier_Set__c> listContractTierSets = [SELECT
                                                           Contract__r.Quote__r.Offering_Type__c,
                                                           Contract__r.Quote__r.Pricing_Model__c
                                                           FROM Contract_Tier_Set__c];
        for (Contract_Tier_Set__c objCTS : listContractTierSets) {
            System.Debug('objCTS ' + objCTS);
            System.Debug(' objCTS.Contract__r.Quote__r.Pricing_Model__c ' + objCTS.Contract__r.Quote__r.Pricing_Model__c);
        }
        objBatch.createBasePackageLinesforOrder(listContractTierSets[0], 1000, 1);
    }
}