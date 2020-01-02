@isTest
private class CreateOrderMultipleShipPCCCntlrTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders(list_NewQuotes[0].Id, list_NewOpps[0].Id, 1);
        System.assertEquals(list_NewOrders.size(), 1);
        
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA');    
        insert objNewCountry;
        
        //list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);    
        
        BigMachines__Quote_Product__c objNewQtPrd = [SELECT Id, BigMachines__Product__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id LIMIT 1];
        
        Product2 objQtProd = new Product2(Id=objNewQtPrd.BigMachines__Product__c,ProductShippable__c='Yes');      
        update objQtProd;
        
        //Quote address
        Account_Order_Address__c objNewAOA = new Account_Order_Address__c(Quote__c=list_NewQuotes[0].Id, Address_Type__c='Sold To',
                                                        Address__c='test 1', Address2__c='test 2', City__c='test', State__c='test',
                                                        Country__c='test', Sort_Order__c=1);
        insert objNewAOA;
        //Address
        Address__c objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='test', Address_Line_2__c='test',
                                    Address_Name__c='test', City__c='test', Country__c='test');
        insert objNewAddr;
                
        //Unit tests for OrderAddressPureCloudController methods       
        Test.setCurrentPageReference(new PageReference('Page.CreateOrderMultipleShip')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(list_NewQuotes[0]); 
        CreateOrderMultipleShipPCCCntlr objCreateOrderMultipleShip = new CreateOrderMultipleShipPCCCntlr(sc); 
        objCreateOrderMultipleShip.getselectedLocations();
        objCreateOrderMultipleShip.saveAndClose();
        objCreateOrderMultipleShip.enterSubmitTab();
        objCreateOrderMultipleShip.enterAllocationTab();
        objCreateOrderMultipleShip.showShipToSelection();
        
        objCreateOrderMultipleShip.getShippingMethodList();
        objCreateOrderMultipleShip.getLineItems();
        objCreateOrderMultipleShip.showLocationPopup();
        objCreateOrderMultipleShip.selectedShippingAddressId=objNewAddr.Id;
        objCreateOrderMultipleShip.shippingAddressSelect();
        objCreateOrderMultipleShip.selectedShippingAddressId=objNewAOA.Id;
        objCreateOrderMultipleShip.selectedShippingMethod='Test';
        objCreateOrderMultipleShip.shippingAddressSelect();        
        objCreateOrderMultipleShip.saveLocation();
        
        objCreateOrderMultipleShip.saveAccountOrderAddress();
        objCreateOrderMultipleShip.selectedLocationNumber=0;
        objCreateOrderMultipleShip.saveLocation();
        objCreateOrderMultipleShip.cancelUpdateAddress();
        objCreateOrderMultipleShip.LineNumber=1;
        objCreateOrderMultipleShip.editLocation();
        objCreateOrderMultipleShip.retrieveAddress(objNewAddr.Id);
        objCreateOrderMultipleShip.selectedAddressRecordId=objNewAOA.Id;
        
        objCreateOrderMultipleShip.getShippingAddresses();
        objCreateOrderMultipleShip.retrieveAddress(objNewAOA.Id);
        objCreateOrderMultipleShip.buildLineItem(new order_line_item__c());
        objCreateOrderMultipleShip.removeLocation();
    }
}