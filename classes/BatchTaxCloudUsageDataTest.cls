@isTest
public class BatchTaxCloudUsageDataTest {
    @testSetup
    public static void setUpData() {
        List<SureTax_Settings__c> list_SureTaxSettings = SureTaxSettingsFactory.createDefaultSureTaxSettings();//BatchCreateCloudMonthlySalesOrdersTest.setupSureTaxSettings();
		insert list_SureTaxSettings;

        Util.Bypass_Trigger_Chk = true;
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(new List<Rolled_Up_Usage_Data__c>());
        CloudBillingTestUtil.insertRuud();
        List<Rolled_Up_Usage_Data__c> listRUUD = [select Id, Count__c, Billable_60__c, Service_Type__c from Rolled_Up_Usage_Data__c];
        if (listRUUD.size() > 1) {
            
            Rolled_Up_Usage_Data__c objRUUD = listRUUD[0];
            System.Debug('First Rudd ' + objRUUD);
            
            List<Contract_Tier_Set__c> listCTS = new List<Contract_Tier_Set__c>();
            Contract_Tier_Set__c objCTS = new Contract_Tier_Set__c(Contract__c = objContract.Id);
            insert objCTS;
            listCTS.add(objCTS);
            
            TestCloudBilling.getListTierSetMonth(1);
            // Above method inserts 2 SU's Contract Tier Set Month and Contract Tier Set
            List<Service_Usage__c> listSU = [select Count__c,
                                             Quantity__c,
                                             Cost__c,
                                             Service_Type__c,
                                             Contract_Tier_Set_Month__c
                                             from Service_Usage__c];
            if (listSU == null && listSU.size() == 0) {
                System.Assert(false);
            }
            Service_Usage__c objSU = listSU[0];
            objSU.Rolled_Up_Usage_Data__c = objRUUD.Id;
            objSU.Tax_Status__c = BatchTaxCloudUsageData.TAX_STATUS_ROLLUP_TAX_NEEDED;
            update objSU;
            
			List<Service_Usage_Tax__c> listServiceUsageTaxToInsert = new List<Service_Usage_Tax__c>();
            Service_Usage_Tax__c objServiceUsageTax = new Service_Usage_Tax__c(Rolled_Up_Usage_Data__c = objRUUD.Id,
                                                                               Service_Usage__c = objSU.id,
                                                                               Tax_Type_Code__c = '106',
                                                                               Tax_Amount__c = 3.33);
            listServiceUsageTaxToInsert.add(objServiceUsageTax);
            Service_Usage_Tax__c objServiceUsageTax2 = new Service_Usage_Tax__c(Rolled_Up_Usage_Data__c = objRUUD.Id,
                                                                                Service_Usage__c = objSU.id,
                                                                                Tax_Type_Code__c = '035',
                                                                                Tax_Amount__c = 6.66);
            listServiceUsageTaxToInsert.add(objServiceUsageTax2);
            insert listServiceUsageTaxToInsert;
        } else {
            System.assert(false);
        }

        {
        // These products in SureTaxSettingsFactory
        List<Product2> listProducts = TestUtil.createProducts(3, false);
        Product2 prod1 = listProducts[0];
        prod1.APN_Number__c = 'PEC-100-TAX-SL911';
        Product2 prod2 = listProducts[1];
        prod2.APN_Number__c = 'PEC-100-TAX-FUSFC';
        Product2 prod3 = listProducts[2];
        prod3.Name = 'Cloud Contact Center -Outbound Call (Blended Rate)';
        prod3.APN_Number__c = '3GP21171ABAA';
        prod3.SureTax_Code_Undetermined__c = '050155';
        insert listProducts;
        
        Util.Bypass_Trigger_Chk = true;
        //GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(new List<Rolled_Up_Usage_Data__c>());

        Subsidary__c objSubsidiary = new Subsidary__c(Name = '8100', Active__C = true);
        insert objSubsidiary;

        Util.Bypass_Trigger_Chk = true;
        Order__c objOrder = CloudBillingTestUtil.setupOrder(objContract);
        objOrder.Subsidaries__c = objSubsidiary.Id;
        objOrder.Maintenance_Start__c = Date.newInstance(2018, 02, 01);
        insert objOrder;

		Account_Order_Address__c objAddress = new Account_Order_Address__c(
            Order__c = objOrder.Id,
            Country__c = 'US',
            Zip_Code__c = '02176',
            State__c = 'MA',
            Address_Type__c = 'Bill To');
        insert objAddress;

        list<Order_Line_Item__c> listOLIinsert = new List<Order_Line_Item__c>();
        Order_Line_Item__c objOLI = new Order_Line_Item__c(
            Product__c = prod3.id,
            Order__c = objOrder.Id,
            Sales_Price__c = 300,
            Quantity__c = 1,
            BigMachines_Quantity__c = 1,
            Tax_Status__c = BatchTaxCloudUsageData.TAX_STATUS_ORDER_LINE_SURETAX_NEEDED
        );
        listOLIinsert.add(objOLI);
        Order_Line_Item__c objOLItax = new Order_Line_Item__c(
            Product__c = prod1.Id,
            Order__c = objOrder.Id,
            Sales_Price__c = 300,
            Quantity__c = 1,
            BigMachines_Quantity__c = 1
        );
        listOLIinsert.add(objOLItax);
		insert listOLIinsert;
        }

    }
    @isTest
    public static void testBatchRolledTax(){
        Test.startTest();
        BatchTaxCloudUsageData objBatch = new BatchTaxCloudUsageData(BatchTaxCloudUsageData.PROCESS_ROLLUP_TAX_NEEDED);
        Database.executeBatch(objBatch, 100);
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchOrderLineSureTax(){
        Test.startTest();

        GCR_Content_Document_Detail__c objContract = [select id from GCR_Content_Document_Detail__c];
        Order_Line_Item__c objOLI = [select Id from Order_Line_Item__c where Tax_Status__c = :BatchTaxCloudUsageData.TAX_STATUS_ORDER_LINE_SURETAX_NEEDED];
        TaxCalculatorTest.idOrderLineItem = objOLI.Id;

        CloudBillingData objCloudBillingData = new CloudBillingData();
        // This is set in CloudBillingTestUtil.setupOrder()
        objCloudBillingData.month = '6';
        objCloudBillingData.year = '2017';
        //objCloudBillingData.subsidiary = '8100';
        objCloudBillingData.contractId = objContract.Id;
        //objCloudBillingData.region = 'North America';
        //Skip this for testing
        //objCloudBillingData.edition = 'PureEngage';

		Cloud_Billing_Log__c objJobLog = new Cloud_Billing_Log__c(
            Month__c = objCloudBillingData.month,
            Year__c = objCloudBillingData.year
        );
        BatchTaxCloudUsageData objBatch = new BatchTaxCloudUsageData(BatchTaxCloudUsageData.PROCESS_ORDER_LINE_SURETAX, objCloudBillingData);
        objBatch.objJobLog = objJobLog;
        Util.Bypass_Trigger_Chk = true;
        Database.executeBatch(objBatch, 1);
        Test.stopTest();
    }
    
}