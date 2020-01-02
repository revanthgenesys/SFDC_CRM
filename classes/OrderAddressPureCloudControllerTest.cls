@isTest
private class OrderAddressPureCloudControllerTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<zqu__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createZuoraQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createPureCloudOrders(list_NewQuotes[0].Id, list_NewOpps[0].Id, 1);
        System.assertEquals(list_NewOrders.size(), 1);
        
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA');    
        insert objNewCountry;
        
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];  
        
        //Quote address
        Account_Order_Address__c objNewAOA = new Account_Order_Address__c(Zuora_Quote__c=list_NewQuotes[0].Id, Address_Type__c='Sold To',
                                                        Address__c='test 1', Address2__c='test 2', City__c='test', State__c='test',
                                                        Country__c='test');
        insert objNewAOA;
        //Address
        Address__c objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='test', Address_Line_2__c='test',
                                    Address_Name__c='test', City__c='test', Country__c='test');
        insert objNewAddr;
                
        //Unit tests for OrderAddressPureCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.OrderAddressPureCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        OrderAddressPureCloudController objOrderAddressPureCloudCntrl = new OrderAddressPureCloudController(); 
        objOrderAddressPureCloudCntrl.addressId = objNewAOA.Id;
        objOrderAddressPureCloudCntrl.accountAddresses[0].check = true;
        objOrderAddressPureCloudCntrl.save();
        objOrderAddressPureCloudCntrl.editAddress();
        objOrderAddressPureCloudCntrl.deleteAddress();
        objOrderAddressPureCloudCntrl.showCreateNewPopup();
        objOrderAddressPureCloudCntrl.createNewAddress();
        objOrderAddressPureCloudCntrl.makeAddressTypeEditable();
        objOrderAddressPureCloudCntrl.hideCreateNewPopup();
        OrderAddressPureCloudController.validateOrderSubmission(list_NewQuotes[0].Id);
    }
}