@isTest
public class BatchSendInvoicesTest {
    
    @testSetup
    static void setUpData() {
        Util.Bypass_Trigger_Chk = true;
/*
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;

        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = list_Accounts[0].Id;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = System.today() - 730 ;
*/
        Id idCloudMonthlyBillingOrder = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Cloud Monthly Billing Order').getRecordTypeId();
        Order__c objOrder = new Order__c(Sales_Org__c = 'PureConnect',
                                     Month__c = '7',
                                     Year__c = '2017',
                                     Status__c = 'Completed',
                                     RecordTypeId = idCloudMonthlyBillingOrder);
        insert objOrder;
        Invoice__c objInvoice = new Invoice__c(
            Status__c = 'Invoice Attached',
            Order__c = objOrder.Id
        );
        insert objInvoice;
        
        
    }
    
    static testmethod void testSend() {
        CloudBillingData objCloudBillingData = new CloudBillingData();
        Cloud_Billing_Log__c objCloudBillingLog = new Cloud_Billing_Log__c(Month__c = '7',
                                                                          Year__c = '2017');
		BatchSendInvoices objBatchSendInvoices = new BatchSendInvoices(objCloudBillingData, objCloudBillingLog);
        Test.startTest();
        Database.executeBatch(objBatchSendInvoices, 50);
        Test.stopTest();
    }
    static testmethod void testSendPureCloud() {
        CloudBillingData objCloudBillingData = new CloudBillingData();
        objCloudBillingData.edition = 'PureCloud';
        Cloud_Billing_Log__c objCloudBillingLog = new Cloud_Billing_Log__c(Month__c = '7',
                                                                          Year__c = '2017');
		BatchSendInvoices objBatchSendInvoices = new BatchSendInvoices(objCloudBillingData, objCloudBillingLog);
        Test.startTest();
        Database.executeBatch(objBatchSendInvoices, 50);
        Test.stopTest();
    }
    static testmethod void testSendPureConnect() {
        CloudBillingData objCloudBillingData = new CloudBillingData();
        objCloudBillingData.edition = 'PureConnect';
        Cloud_Billing_Log__c objCloudBillingLog = new Cloud_Billing_Log__c(Month__c = '7',
                                                                          Year__c = '2017');
		BatchSendInvoices objBatchSendInvoices = new BatchSendInvoices(objCloudBillingData, objCloudBillingLog);
        Test.startTest();
        Database.executeBatch(objBatchSendInvoices, 50);
        Test.stopTest();
    }

    static testmethod void testSendNullLog() {
        CloudBillingData objCloudBillingData = new CloudBillingData();
		BatchSendInvoices objBatchSendInvoices = new BatchSendInvoices(objCloudBillingData, null);
        Test.startTest();
        Database.executeBatch(objBatchSendInvoices, 50);
        Test.stopTest();
    }

}