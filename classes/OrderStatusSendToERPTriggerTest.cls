@IsTest
public class OrderStatusSendToERPTriggerTest {
    
    static testMethod void testStatusMoveToERP() {

        Util.Bypass_Trigger_Chk = true;

        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;
        testQuote.Bill_To_Name__c = testAccount.id;
        testQuote.End_User_ID__c = testAccount.id;
        testQuote.Sold_To_Name__c = testAccount.id;
        testQuote.System_Integrator__c = testAccount.id;
        testQuote.Support_Owner__c = testAccount.id;
        insert testQuote;    
        //Quote address
        Account_Order_Address__c orderAddress1 = new Account_Order_Address__c();
        orderAddress1.Quote__c = testQuote.id;
        orderAddress1.Address_Type__c = 'Sold To';
        orderAddress1.Address__c = 'test 1';
        orderAddress1.Address2__c = 'test 2';
        orderAddress1.City__c = 'test';
        orderAddress1.State__c = 'test';
        orderAddress1.Country__c = 'test';
        insert orderAddress1;
        //Address
        Address__c testAddress1 = new Address__c(Account__c = testAccount.id);
        testAddress1.Address_Line_1__c = 'test';
        testAddress1.Address_Line_2__c = 'test';
        testAddress1.Address_Name__c = 'test';
        testAddress1.City__c = 'test';
        testAddress1.Country__c = 'test';
        insert testAddress1;
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, true)[0];
        System.Debug('testOrder ' + testOrder);
        
		List<RecordType> listIds = [SELECT Id FROM RecordType WHERE Name = 'Cloud Monthly Billing Order'];
        if (listIds.size() == 0) {
            System.Debug('OrderStatusSendToERPTriggerTest.testStatusMoveToERP Could not find RecordType Cloud Monthly Billing Order');
            System.Assert(false);
        }

        Id idCMBO = listIds[0].Id;
        List<Subsidary__c> listSubsidary = [select Id, Name from Subsidary__c];
        if (listSubsidary.size() == 0) {
            System.Debug('OrderStatusSendToERPTriggerTest.testStatusMoveToERP Subsidiary List size is 0');
        } else {
           for (Subsidary__c objSubsidary : listSubsidary) {
                System.Debug('OrderStatusSendToERPTriggerTest.testStatusMoveToERP ' + objSubsidary);
            }
        }        
        Subsidary__c objSubsidary = new Subsidary__c(Name = '8100', Active__c = true);
        insert objSubsidary;
        System.debug('OrderStatusSendToERPTriggerTest.testStatusMoveToERP inserted Subsidiary ' +  objSubsidary);
        testOrder.Subsidaries__c = objSubsidary.Id;
        testOrder.RecordTypeId = idCMBO;
        testOrder.Status__c = 'In Progress';
        update testOrder;

        // Start the test
		TriggerFlowManager.ORDER_BEFORE_INSERT_TRIGGER = false;
        Util.Bypass_Trigger_Chk = false;
		testOrder.Status__c = 'Approved';
        update testOrder;

    }
}