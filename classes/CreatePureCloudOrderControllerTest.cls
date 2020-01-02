@isTest
private class CreatePureCloudOrderControllerTest {
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
     
        List<zqu__QuoteRatePlanCharge__c> list_ZQRPCs = TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(list_NewQuotes[0], false); 
        
       // Product2 objQtProd = new Product2(Id=list_ZQRPCs[0].zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,ProductShippable__c='Yes');      
      //  update objQtProd;
        
        //Quote address
        List<Account_Order_Address__c> list_NewAOAs = TestDataFactoryForQuoteTool.createPureCloudAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewAOAs.size(), 4);
        
        list_NewAOAs[2].Shipping_Method_Name__c = 'PICK UP';
        update list_NewAOAs[2];
        
        Order_Line_Item_Allocation__c objNewOLIA = new Order_Line_Item_Allocation__c(Order_Shipping_Location__c=list_NewAOAs[2].Id, 
                                                            Zuora_Quote__c=list_NewQuotes[0].Id, Quantity__c=10,
                                                            Quote_Rate_Plan_Charge__c=list_ZQRPCs[0].Id);
        insert objNewOLIA;
        
        //Address
        Address__c objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='test', Address_Line_2__c='test',
                                    Address_Name__c='test', City__c='test', Country__c='test');
        insert objNewAddr;
                
        //Unit tests for OrderAddressPureCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.CreatePureCloudOrder')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        CreatePureCloudOrderController objCreatePureCloudOrderController = new CreatePureCloudOrderController(); 
        objCreatePureCloudOrderController.saveOrderBtn();
        objCreatePureCloudOrderController.submitOrderBtn();
        objCreatePureCloudOrderController.cancelOrderBtn();        
        objCreatePureCloudOrderController.getIsOrderInfoAvailable();
        objCreatePureCloudOrderController.insertAttachment();
    }
}