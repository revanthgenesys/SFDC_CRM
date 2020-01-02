@isTest
public class BatchReconcileRollupDataTest {
    
    @TestSetup
    public static void setupData(){
        Util.Bypass_Trigger_Chk = true;
        Service__c objService = CloudBillingTestUtil.insertServiceInboundUS();
        
        Rolled_Up_Usage_Data__c ruud = CloudBillingTestUtil.insertRolledUpUsageDataInboundUS();
        Date dt = Date.today();
        ruud.Start_Time__c = DateTime.newInstance(dt.year(), dt.month(), dt.day());
        ruud.Total_Duration__c = ruud.Billable_6__c;
        update ruud;
        
        ruud.Id = null;
        insert ruud;
        Rolled_Up_Usage_Data__c ruudCheck = [select Reconciliation_Key__c,
                                             Source_Name__c,
                                             Platform_Id__c,
                                             Activity_Type__c,
                                             Service_Type__c,
                                             Channel_Type__c,
                                             Origin_Country_Code__c,
                                             Service_Class__c,
                                             Usage_Type__c
                                             from Rolled_Up_Usage_Data__c where id = :ruud.id];
        System.Debug('setupData:ruudCheck ' + ruudCheck + ' Country Code ' + ruudCheck.Origin_Country_Code__c);
        
        List<Rolled_Up_Usage_Data__c> listRUUD = new List<Rolled_Up_Usage_Data__c>();
        listRUUD.add(ruud);
        /*
        List<Account> list_Accounts = TestUtil.createAccounts(1, false);
        Account objAccount = list_Accounts[0];
        objAccount.SAP_Account_Code__c = 'GARNTest';
        insert objAccount;
        */
        //GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.insertBigMachinesQuoteContract('PureConnect Subscription', 'PureConnect Subscription');
		GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(listRUUD);
        List<BigMachines__Quote__c> listQuotes = [select Offering_Type__c from BigMachines__Quote__c];
        for (BigMachines__Quote__c objQuote : listQuotes) {
            objQuote.Offering_Type__c = 'PureConnect Subscription';
        }
        update listQuotes;
        System.debug(listQuotes);

        Cloud_Deployment__c objCloudDeployment1 = new Cloud_Deployment__c();
        objCloudDeployment1.Account__c = objContract.Account_Name__c;//objAccount.Id;
        objCloudDeployment1.Tenant_ID__c = 'Tenant123';
        objCloudDeployment1.Billing_Platform_Id__c = 'Tenant123'; // Testing purposes only. Illegal in reality. Only one platofrm ID should be allowed.
        objCloudDeployment1.Cloud_Platform__c = 'PureConnect Subscription';
        insert objCloudDeployment1;

        Cloud_Deployment__c objCloudDeployment2 = new Cloud_Deployment__c();
        objCloudDeployment2.Account__c = objContract.Account_Name__c;//objAccount.Id;
        objCloudDeployment2.Tenant_ID__c = 'Tenant456';
        objCloudDeployment2.Billing_Platform_Id__c = 'Tenant456'; // Testing purposes only. Illegal in reality. Only one platofrm ID should be allowed.
        objCloudDeployment2.Cloud_Platform__c = 'PureConnect Subscription';
        insert objCloudDeployment2;

        Cloud_Deployment_To_Contract_Junction__c objCDJunction1 = new Cloud_Deployment_To_Contract_Junction__c(Contract__c = objContract.Id,
                                                                                                              Cloud_Deployment__c = objCloudDeployment1.Id);
        insert objCDJunction1;
        Cloud_Deployment_To_Contract_Junction__c objCDJunction2 = new Cloud_Deployment_To_Contract_Junction__c(Contract__c = objContract.Id,
                                                                                                              Cloud_Deployment__c = objCloudDeployment2.Id);
        insert objCDJunction2;
    }
    
    @isTest
    public static void testReconcile() {
        System.debug('testReconcile');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Agent_Seats_Concurrent__c = true;
        objClientProductMapping.Agent_Seats__c = true;
        objClientProductMapping.Inbound_Minutes__c = true;
        objClientProductMapping.IVR_Port_Excess_Minutes__c = true;
        objClientProductMapping.IVR_Ports__c = true;
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcile  end');
    }

    @isTest
    public static void testReconcileNoConcurrent() {
        System.debug('testReconcileNoConcurrent');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Agent_Seats__c = true;
        objClientProductMapping.Inbound_Minutes__c = true;
        objClientProductMapping.IVR_Port_Excess_Minutes__c = true;
        objClientProductMapping.IVR_Ports__c = true;
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileNoConcurrent end');
    }
    @isTest
    public static void testReconcileSettingsButCount0() {
        System.debug('testReconcileSettingsButCount0');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Agent_Seats__c = true;
        objClientProductMapping.Agent_Seats_Enabled_Region_Count__c = '0';
        objClientProductMapping.IVR_Ports__c = true;
        objClientProductMapping.IVR_Port_Region_Count__c = '0';
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Outbound_Minute_Region_Count__c = '0';
        objClientProductMapping.Port_Minutes__c = true;
        objClientProductMapping.Port_Minute_Region_Count__c = '0';
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileSettingsButCount0 end');
    }

    @isTest
    public static void testReconcileNoSeats() {
        System.debug('testReconcileNoSeats');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Inbound_Minutes__c = true;
        objClientProductMapping.IVR_Port_Excess_Minutes__c = true;
        objClientProductMapping.IVR_Ports__c = true;
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileNoSeats end');
    }

    @isTest
    public static void testReconcileNoSeatNoInbound() {
        System.debug('testReconcileNoSeatNoInbound');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.IVR_Port_Excess_Minutes__c = true;
        objClientProductMapping.IVR_Ports__c = true;
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileNoSeatNoInbound end');
    }

    @isTest
    public static void testReconcileNoSeatsInboundNoPortExcess() {
        System.debug('testReconcileNoSeatsInboundNoPortExcess');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.IVR_Ports__c = true;
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileNoSeatsInboundNoPortExcess end');
    }
    @isTest
    public static void testReconcileOutboundAndPortMinutes() {
        System.debug('testReconcileOutboundAndPortMinutes');

		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Outbound_Minutes__c = true;
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileOutboundAndPortMinutes end');
    }
    @isTest
    public static void testReconcileOnlyPortMinutes() {
        System.debug('testReconcileOnlyPortMinutes');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileOnlyPortMinutes end');
    }

    @isTest
    public static void testReconcileOnlyPortMinutesReconAlreadyExists() {
        System.debug('testReconcileOnlyPortMinutesReconAlreadyExists');
        Cloud_ETL_Reconciliation__c objRecon = new Cloud_ETL_Reconciliation__c(
            Name='Tenant123#0#2#1#21#0#ROLLUP - SUCCESS#4-2018',
            Account_Name__c='Test Account',
            GARN_Account_Code__c='GARN123',
            Source_Name__c='BEEEC',
            Platform_Id__c='Tenant123',
            Unique_Id__c='Tenant123#0#2#1#21#0#ROLLUP - SUCCESS#4-2018',
            Expected_File_Count__c=30,
            Month__c='4', Year__c='2018');
        insert objRecon;

        Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        BatchReconcileRollupData objBatch = new BatchReconcileRollupData();
        Date dt = Date.newInstance(2018, 4, 1);
        objBatch.populateExpectedFileCountsPureEngage(dt);
        System.debug('testReconcileOnlyPortMinutesReconAlreadyExists end');
    }

    @isTest
    public static void testReconcileUnrecognizedHash() {
        System.debug('testReconcileUnrecognizedHash');
        Cloud_ETL_Reconciliation__c objRecon = new Cloud_ETL_Reconciliation__c(
            Name='Tenant123#999#999#999#999#999#ROLLUP - SUCCESS#4-2018',
            Account_Name__c='Test Account',
            GARN_Account_Code__c='GARN123',
            Source_Name__c='BEEEC',
            Platform_Id__c='Tenant123',
            Unique_Id__c='Tenant123#999#999#999#999#999#ROLLUP - SUCCESS#4-2018',
            Expected_File_Count__c=0,
            Month__c='4', Year__c='2018');
        insert objRecon;

        Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        BatchReconcileRollupData objBatch = new BatchReconcileRollupData();
        Date dt = Date.newInstance(2018, 4, 1);
        objBatch.populateExpectedFileCountsPureEngage(dt);
        System.debug('testReconcileUnrecognizedHash end');
    }
/*
    @isTest
    public static void testReconcileNotCurrentlySetup() {
        System.debug('testReconcileNotCurrentlySetup');
        Rolled_Up_Usage_Data__c ruud = CloudBillingTestUtil.insertRolledUpUsageDataInboundUS();
        Date dt = Date.today();
        ruud.Start_Time__c = DateTime.newInstance(dt.year(), dt.month(), dt.day());
        ruud.Total_Duration__c = ruud.Billable_6__c;
		ruud.Service_Type__c = 0; // Intentionally create unused Service Type to force the record not matching an expected value in mapActivityTypeToReconcileHash
        // Produces unique id ##2#1#0#0#ROLLUP - SUCCESS#
        update ruud;
        System.Debug('testReconcileNotCurrentlySetup:ruud ' + ruud);

		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];
        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testReconcileNotCurrentlySetup end');
    }
*/
    @isTest
    public static void testCloudDeploymentSoldTo() {
        System.debug('testCloudDeploymentSoldTo');
		Cloud_Deployment__c objCloudDeployment = [SELECT Id FROM Cloud_Deployment__c LIMIT 1];

        List<Account> list_Accounts = TestUtil.createAccounts(1, false);
        Account objAccount = list_Accounts[0];
        objAccount.Name = 'SoldToName';
        objAccount.SAP_Account_Code__c = 'SOLDTOGARN';
        insert objAccount;

        objCloudDeployment.Sold_To_Account__c = objAccount.Id;
        update objCloudDeployment;

        Client_Product_Mapping__c objClientProductMapping = new Client_Product_Mapping__c(Cloud_Deployment__c = objCloudDeployment.Id);
        objClientProductMapping.Port_Minutes__c = true;
        insert objClientProductMapping;

        Test.startTest();
        Database.executeBatch(new BatchReconcileRollupData(), 50);
        Test.stopTest();
        System.debug('testCloudDeploymentSoldTo end');
    }
// End Class
}