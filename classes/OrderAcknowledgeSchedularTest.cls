@isTest(seeAllData = true)
public class OrderAcknowledgeSchedularTest{
    public static testMethod void testSchedule(){
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Contact testContact = new Contact(AccountId = testAcc.id, LastName = 'Test');
        insert testContact;
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, false)[0];
        testOpp.Contact__c = testContact.id;
        insert testOpp;
        
        List<Account_Order_Address__c> orderAddress = [SELECT Order__c FROM Account_Order_Address__c WHERE Order__c != null LIMIT 5];
        //Order__c testOrder = [SELECT id, Name, Status__c, Region__c, Quote__c FROM Order__c WHERE id =: orderAddress[0].Order__c 
        //                       AND Quote__c != null LIMIT 1];
                              //AND Quote__r.BigMachines__Is_Primary__c = true LIMIT 1];
        Test.StartTest();
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        Order_Acknowledge_Email__c objEmail = new Order_Acknowledge_Email__c(Order__c = testOrder.id, Email_Status__c = 'Pending');
        insert objEmail;
        
            OrderAcknowledgeEmailBatchSchedular bsu = new OrderAcknowledgeEmailBatchSchedular();
            String sch = '0 0 23 * * ?';
            system.schedule('Test Schedular Batch', sch, bsu);
        Test.StopTest();
    }
    
    public static testMethod void testOrderAcknowledgeEmailTemplateController(){
        Test.StartTest();
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Contact testContact = new Contact(AccountId = testAcc.id, LastName = 'Test');
        insert testContact;
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, false)[0];
        testOpp.Contact__c = testContact.id;
        insert testOpp;
        
        List<Account_Order_Address__c> orderAddress = [SELECT Order__c FROM Account_Order_Address__c WHERE Order__c != null LIMIT 5];
        //Order__c testOrder = [SELECT id, Name, Status__c, Region__c, Quote__c FROM Order__c WHERE id =: orderAddress[0].Order__c 
        //                       AND Quote__c != null LIMIT 1];
                              //AND Quote__r.BigMachines__Is_Primary__c = true LIMIT 1];
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        Test.StopTest();
        //BigMachines__Quote__c objQuote = new BigMachines__Quote__c(id = testOrder.Quote__c, BigMachines__Is_Primary__c = true);
        //update objQuote;
        List<Account_Order_Address__c> listOfOrderAddresses = new List<Account_Order_Address__c>();
        Account_Order_Address__c testAddress = new Account_Order_Address__c(Order__c = testOrder.id, Address_Type__c = 'Bill To');
        listOfOrderAddresses.add(testAddress);
        testAddress = new Account_Order_Address__c(Order__c = testOrder.id,Address_Type__c = 'Ship To');
        listOfOrderAddresses.add(testAddress);
        testAddress = new Account_Order_Address__c(Order__c = testOrder.id,Address_Type__c = 'Sold To');
        listOfOrderAddresses.add(testAddress);
        insert listOfOrderAddresses;
        
        OrderAcknowledgeEmailTemplateController objContTest = new OrderAcknowledgeEmailTemplateController();
        objContTest.orderId = testOrder.id;
        objContTest.getOrderLineItems();
        objContTest.getOrderAddreses();
        OrderAcknowledgeEmailTemplateController.resendEmail(testOrder.id);
        
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Finance_Notifications__c objFin = new Finance_Notifications__c(Active__c = true, Email__c = 'test@asdf.com1');
        objFin.Account__c = testAccount.id;
        objFin.Notification_Type__c = 'Invoice';
        insert objFin;
        
        testOrder.Status__c = 'Order Submitted';
        update testOrder;
        objContTest.accountId = testAccount.id;
        objContTest.getContractEmails();
        Map<Id, Order__c> newMap = new Map<Id, Order__c>();
        newMap.put(testOrder.id, testOrder);
        
        OrderUtil.sendAcknowledgeEmail(newMap, null);
    }
}