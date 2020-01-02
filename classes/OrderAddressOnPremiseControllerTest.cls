//Naresh Kumar	10/09/2014
@isTest(seeAllData = true)
private class OrderAddressOnPremiseControllerTest {
    static testMethod void myUnitTest() {
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
        Apexpages.currentPage().getParameters().put('id', testQuote.id);
        OrderAddressOnPremiseController objController = new  OrderAddressOnPremiseController();
        objController.addressId = orderAddress1.id;
        objController.accountAddresses[0].check = true;
        objController.save();
        objController.editAddress();
        objController.deleteAddress();
        objController.showCreateNewPopup();
        objController.createNewAddress();
        objController.makeAddressTypeEditable();
        objController.hideCreateNewPopup();
        OrderAddressOnPremiseController.populateAddressOnOrder(testQuote.id, testOrder.id);
        OrderAddressOnPremiseController.validateOrderSubmission(testQuote.id);
        
        
    }
}