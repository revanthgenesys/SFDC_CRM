@isTest(seeAllData = false)
public class OrderAcknowledgeSchedularTest1{
     
    
    public static testMethod void testOrderAcknowledgeEmailTemplateController1(){
        Test.StartTest();
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Contact testContact = new Contact(AccountId = testAcc.id, LastName = 'Test');
        insert testContact;
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, false)[0];
        testOpp.Contact__c = testContact.id;
        insert testOpp;
        
        List<Account_Order_Address__c> orderAddress = [SELECT Order__c FROM Account_Order_Address__c WHERE Order__c != null LIMIT 5];         
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        Test.StopTest();
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(id = testOrder.Quote__c, BigMachines__Is_Primary__c = true);
        update objQuote;
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
        objContTest.getContractEmails();
        //objContTest.isRunningTest();
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