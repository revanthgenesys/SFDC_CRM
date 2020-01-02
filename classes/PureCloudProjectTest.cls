/************************************************************************************
Purpose : Unit test class for PureCloudProjectTrigger, PureCloudProjectTriggerHandler, 
          PureCloudProjectUtil, PureCloudProjectNotificationController
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest
private class PureCloudProjectTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Contact> list_NewCnts = TestDataFactoryForQuoteTool.createContacts(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewCnts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        
        List<Order__c> lstOrder = TestDataFactoryForQuoteTool.createPCOrders(list_NewQuotes[0].Id, list_NewOpps[0].Id, 1);
        
        list_NewQuotes[0].Order__c=lstOrder[0].Id;
        update list_NewQuotes[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
   
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);      
        
        Util.Bypass_Trigger_Chk = false;
        
        PureCloud_Trial__c newPCProject = new PureCloud_Trial__c(Opportunity__c=list_NewOpps[0].Id, BMQuote__c=list_NewQuotes[0].Id,
                                                                 Trial_Contact__c=list_NewCnts[0].Id);
        insert newPCProject;
        
        PureCloud_Trial__c newPCProject1 = new PureCloud_Trial__c(Desired_Go_Live_Date__c = Date.today(), Id=newPCProject.Id);
        update newPCProject1;
        
        PureCloudProjectNotificationController objPCProjNotContr = new PureCloudProjectNotificationController();
        objPCProjNotContr.quoteId = list_NewQuotes[0].Id;
        objPCProjNotContr.getUrlPrefix();
        objPCProjNotContr.getQuoteProducts();
        objPCProjNotContr.getBillToAddress();
        objPCProjNotContr.getShipToAddresses();
    }
}