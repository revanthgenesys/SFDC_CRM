@isTest
public class dsrOrgCancellation_test {

// clone of Subtrigger_test    
     @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);     
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        
        list_NewQuotes[0].Offering_Type__c = 'PureCloud';
        list_NewQuotes[0].Order_Type__c = 'Amend';
        list_NewQuotes[0].BigMachines__Opportunity__c = list_NewOpps[0].Id;
        
        update list_NewQuotes[0];
        list_NewOpps[0].Primary_Quote__c = list_NewQuotes[0].Id;
        list_NewOpps[0].Offering_Detail__c = 'Free Trial';
        list_NewOpps[0].Lead_Offer__c = 'PureCloud';
        
        update list_NewOpps[0];
        
        System.assertEquals('Free Trial', list_NewOpps[0].Offering_Detail__c );
                
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        Cloud_Deployment__c CDEa = new Cloud_Deployment__c();
        CDEa.Account__c =list_NewAccts[0].Id;
        CDEa.Quote__c =list_NewQuotes[0].Id;
        CDEa.Cloud_Platform__c= 'PureCloud';
     // CDEa.Order__c= objOrders[0].id;
        CDEa.Opportunity__c= list_NewOpps[0].Id;
      insert CDEa;
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Util.Bypass_Trigger_Chk = false;
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]); 
          
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        Util.Bypass_Trigger_Chk = true;
        
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        List<Subscription_Product__c> list_SubscriptionProds = [SELECT Id, Product__r.APN_Number__c, Product__c,Subscription__r.Account__c,
                                                                       Subscription__r.Subscription_Start_Date__c, Quantity__c,
                                                                       Subscription__r.Start_Date__c, Subscription__r.Name, Subscription__c
                                                                FROM Subscription_Product__c 
                                                                WHERE Subscription__c =: objNewSubscription.Id];
        List<Order__c> objOrders = TestDataFactoryForQuoteTool.createOrders(list_NewQuotes[0].id,list_NewQuotes[0].BigMachines__Opportunity__c,1);
        Set<ID> set_OrderIDs = new Set<ID>();
        for(Account_Order_Address__c objAddress : list_NewQtAddrs)
        {
            objAddress.Order__c = objOrders[0].id;
        }
        update list_NewQtAddrs;
        
        for(Order__c objOrder : objOrders)
        {
            set_OrderIDs.add(objOrder.id);
        }
        
        
        Cloud_Deployment__c CDE = new Cloud_Deployment__c();
        CDE.Account__c =list_NewAccts[0].Id;
        CDE.Quote__c =list_NewQuotes[0].Id;
        CDE.Cloud_Platform__c= 'PureCloud';
        CDE.Order__c= objOrders[0].id;
        CDE.Opportunity__c= list_NewOpps[0].Id;
      insert CDE;
      
      System.assertEquals(1, [select count() from Subscription__c where Account__c =: list_NewAccts[0].Id]);
      
      Util.Bypass_Trigger_Chk = false;
      Test.startTest();
      
        List<Subscription__c> subsc = [Select Id
                                             ,Offering_Detail__c
                                             ,Opportunity__c
                                             ,Org_Id__c
                                             ,Status__c
                                             ,Subscription_Start_Date__c
                                             ,Sale_Type__c 
                                             ,Subscription_End_Date__c 
                                             from Subscription__c where Account__c =: list_NewAccts[0].Id];
        
        for(Subscription__c s : subsc){
            If(subsc.size() == 0){continue;}
                s.Subscription_Start_Date__c = Date.today()-5;
                s.Subscription_End_Date__c = Date.today();
                s.Status__c = 'Cancelled';
                s.Offering_Type__c = 'PureCloud'; 
                s.Sale_Type__c = 'Indirect';
                s.Org_Id__c = 'Test';
                }
            update subsc;
        
        Test.stopTest();
        System.assertEquals('Free Trial', subsc[0].Offering_Detail__c);

    }

}