@isTest
private class CreateOrderMultipleShipPureCloudCtrTest {
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
        
        //list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        
        //Add quote line items         
        List<zqu__QuoteChargeDetail__c> list_NewQtChrgDtls = TestDataFactoryForQuoteTool.createZuoraQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtChrgDtls.size(), 1); 
        List<zqu__QuoteRatePlanCharge__c> list_QuoteRPC = TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(list_NewQuotes[0], false);
        
       // zqu__QuoteChargeDetail__c objNewQtChrgDtl = [SELECT Id, zqu__ProductRatePlan__r.zqu__Product__c FROM zqu__QuoteChargeDetail__c WHERE Id =: list_NewQtChrgDtls[0].Id];
        
       // Product2 objQtProd = new Product2(Id=objNewQtChrgDtl.zqu__ProductRatePlan__r.zqu__Product__c,ProductShippable__c='Yes');      
       // update objQtProd;
        
        //Quote address
        Account_Order_Address__c objNewAOA = new Account_Order_Address__c(Zuora_Quote__c=list_NewQuotes[0].Id, Address_Type__c='Sold To',
                                                        Address__c='test 1', Address2__c='test 2', City__c='test', State__c='test',
                                                        Country__c='test', Sort_Order__c=1);
        insert objNewAOA;
        //Address
        Address__c objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='test', Address_Line_2__c='test',
                                    Address_Name__c='test', City__c='test', Country__c='test');
        insert objNewAddr;
                
        //Unit tests for OrderAddressPureCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.CreateOrderMultipleShipPureCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        CreateOrderMultipleShipPureCloudCntlr objCreateOrderMultipleShipPureCloudCntlr = new CreateOrderMultipleShipPureCloudCntlr(); 
        
        objCreateOrderMultipleShipPureCloudCntlr.getselectedLocations();
        //Added By Vijay 30th Jul 2017 - Start
        OrderingUIClasses.ShippingLocation objShippingLocation = new OrderingUIClasses.ShippingLocation();
        List<OrderingUIClasses.ShippingLocation> selectedLocations = new List<OrderingUIClasses.ShippingLocation>{objShippingLocation};
        objCreateOrderMultipleShipPureCloudCntlr.selectedLocations = selectedLocations;
        objCreateOrderMultipleShipPureCloudCntlr.selectedShippingMethod = 'Economy';
        objShippingLocation.LineNumber = 2; 
        //Added By Vijay 30th Jul 2017 - End
        
        objCreateOrderMultipleShipPureCloudCntlr.saveAndClose();
        objCreateOrderMultipleShipPureCloudCntlr.enterSubmitTab();
        objCreateOrderMultipleShipPureCloudCntlr.enterAllocationTab();
        objCreateOrderMultipleShipPureCloudCntlr.showShipToSelection();
        
        objCreateOrderMultipleShipPureCloudCntlr.getShippingMethodList();
        objCreateOrderMultipleShipPureCloudCntlr.getLineItems();
        objCreateOrderMultipleShipPureCloudCntlr.showLocationPopup();
        objCreateOrderMultipleShipPureCloudCntlr.selectedShippingAddressId=objNewAddr.Id;
        objCreateOrderMultipleShipPureCloudCntlr.shippingAddressSelect();
        objCreateOrderMultipleShipPureCloudCntlr.selectedShippingAddressId=objNewAOA.Id;
        objCreateOrderMultipleShipPureCloudCntlr.selectedShippingMethod='Test';
        objCreateOrderMultipleShipPureCloudCntlr.shippingAddressSelect();        
        objCreateOrderMultipleShipPureCloudCntlr.saveLocation();
        
        objCreateOrderMultipleShipPureCloudCntlr.saveAccountOrderAddress();
        objCreateOrderMultipleShipPureCloudCntlr.selectedLocationNumber=0;
        objCreateOrderMultipleShipPureCloudCntlr.saveLocation();
        objCreateOrderMultipleShipPureCloudCntlr.cancelUpdateAddress();
        objCreateOrderMultipleShipPureCloudCntlr.LineNumber=1;
        objCreateOrderMultipleShipPureCloudCntlr.editLocation();
        objCreateOrderMultipleShipPureCloudCntlr.retrieveAddress(objNewAOA.Id);
        objCreateOrderMultipleShipPureCloudCntlr.selectedAddressRecordId=objNewAOA.Id;
        
        objCreateOrderMultipleShipPureCloudCntlr.removeLocation();
        objCreateOrderMultipleShipPureCloudCntlr.getShippingAddresses();
        objCreateOrderMultipleShipPureCloudCntlr.retrieveAddress(objNewAOA.Id);    
        
        OrderingUIClasses.ShippingLocation shipLoc = new OrderingUIClasses.ShippingLocation();    
        shipLoc.ContactId = null;
        
        OrderingUIClasses.LineItem lnItem = new OrderingUIClasses.LineItem();
        lnItem.MSRP=0;
        lnItem.OrderableStartDate = null;
        lnItem.OrderableEndDate = null;
        lnItem.IsMonthly = false;
        lnItem.QuoteChargeName = '';
        
        
        OrderingUIClasses.mAddress addr = new OrderingUIClasses.mAddress();    
        addr.toString();
        addr.DisplayAddressLine('billing', true);
        addr.DisplayAddressLine('shipping', true);
        addr.LegalName='';
        addr.AxId='';
        addr.BillingContactId='';
        addr.BillingContact=new Contact();
        addr.BillingContactPhone='';
        addr.BillingContactFax='';
        addr.BillingContactEmail='';
        addr.ShippingContactId='';
        addr.ShippingContact=new Contact();
        addr.ShippingContactPhone='';
        addr.ShippingContactFax='';
        addr.ShippingContactEmail='';
        
        
        //Added By Vijay 30th Jul 2017 - Start
        OrderingUIClasses.LineItem objLineItem = new OrderingUIClasses.LineItem();
        List<OrderingUIClasses.LineItem> lineItems = new List<OrderingUIClasses.LineItem>{objLineItem};
        objCreateOrderMultipleShipPureCloudCntlr.lineItems  = lineItems;
        
        objLineItem.qty = 1;
        objLineItem.isOrderLine = true;
        objLineItem.PartNumber = '1';
        objLineItem.PartName = 'Test 1';
        objLineItem.IsShippable = true;
        objLineItem.ListPrice = 1;
        objLineItem.MSRP = 1;
        objLineItem.SalesPrice = 1;
        objLineItem.OrderableStartDate = Date.newInstance(2017, 01, 01);
        objLineItem.OrderableEndDate = Date.newInstance(2017, 12, 01);
        objLineItem.IsMonthly = true;
        OrderingUIClasses.LineItemAllocation objLIA = new OrderingUIClasses.LineItemAllocation();
        objLineItem.Allocation = new List<OrderingUIClasses.LineItemAllocation>{objLIA};
        objLIA.Location = 2;
        objLIA.Quantity = 1;
        objCreateOrderMultipleShipPureCloudCntlr.locNumsForExisting = new Map<Decimal, Id>();
        objCreateOrderMultipleShipPureCloudCntlr.locNumsForExisting.put(1, null);
        
        objCreateOrderMultipleShipPureCloudCntlr.createNewLocation();
        
        selectedLocations = new List<OrderingUIClasses.ShippingLocation>{objShippingLocation};
        objCreateOrderMultipleShipPureCloudCntlr.selectedLocations = selectedLocations;
        objCreateOrderMultipleShipPureCloudCntlr.selectedShippingMethod = 'Economy';
        objShippingLocation.LineNumber = 2; 
        objCreateOrderMultipleShipPureCloudCntlr.updateLocation();
        objCreateOrderMultipleShipPureCloudCntlr.saveLocationsAndItems();
        
        objCreateOrderMultipleShipPureCloudCntlr.calculateSupportAndGrandTotal(new List<Order_Line_Item__c>{new Order_Line_Item__c()});
        objCreateOrderMultipleShipPureCloudCntlr.buildLineItem(list_QuoteRPC[0]);
        objCreateOrderMultipleShipPureCloudCntlr.renumberLocations();
        objCreateOrderMultipleShipPureCloudCntlr.initialize();
        //Added By Vijay 30th Jul 2017 - End
    }
}