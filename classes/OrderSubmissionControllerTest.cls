/************************************************************************************
Purpose : Unit test class for OrderSubmissionController
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest
private class OrderSubmissionControllerTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Address__c> list_NewAddresses = new List<Address__c>();
        Address__c objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='Test', Type__c='Corporate',
                                               Zipcode__c='ZipCode',Country__c='US',State__c='State');
        list_NewAddresses.add(objNewAddr);
        objNewAddr = new Address__c(Account__c=list_NewAccts[0].Id, Address_Line_1__c='Test1', Type__c='Ship To',
                                               Zipcode__c='ZipCode1',Country__c='US',State__c='State1');
        list_NewAddresses.add(objNewAddr);
        insert list_NewAddresses;
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);  
        for(Account_Order_Address__c objAOA : list_NewQtAddrs) {
            objAOA.New__c = true; 
            objAOA.Shipping_Method_Name__c = 'Economy';
        }      
        update list_NewQtAddrs;
        
        //Unit tests for ProposalCloudPCController method       
        Test.setCurrentPageReference(new PageReference('Page.OrderSubmission')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(list_NewQuotes[0]);
        OrderSubmissionController objOrderSubmissionController = new OrderSubmissionController(sc); 
        objOrderSubmissionController.list_AccountAddresses[0].blnSelected = true;
        objOrderSubmissionController.list_AccountAddresses[1].blnSelected = true; 
        objOrderSubmissionController.list_AccountAddresses[1].strShippingMethod = 'Economy';
        objOrderSubmissionController.list_AccountAddresses[1].strEmail = 'test@test.com';
        objOrderSubmissionController.makeAddressTypeEditable();
        objOrderSubmissionController.addSelectedAddresses();
        objOrderSubmissionController.getShippingMethodNames();
        objOrderSubmissionController.hidePopUp();
        objOrderSubmissionController.showPopUp();
        
        objOrderSubmissionController.objNewAddress.Address_Type__c = 'Ship To';
        objOrderSubmissionController.objNewAddress.Address__c = 'Address Line Test 1';
        objOrderSubmissionController.objNewAddress.City__c = 'City';
        objOrderSubmissionController.objNewAddress.Shipping_Method_Name__c = 'Economy';
        objOrderSubmissionController.objNewAddress.State__c = 'State';
        objOrderSubmissionController.objNewAddress.Country__c = 'US';
        objOrderSubmissionController.objNewAddress.Zip_Code__c = 'Code1';
        objOrderSubmissionController.objNewAddress.Email__c = 'teset@test.com';        
        objOrderSubmissionController.createAddress();
        
        objOrderSubmissionController.selectedAddressId = list_NewQtAddrs[0].Id;
        objOrderSubmissionController.deleteAddress();
        
        objOrderSubmissionController.updateAllocations();
    }
}