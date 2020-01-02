@isTest
public class Subtrigger_test {
    
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
        list_NewQuotes[0].Offering_Type__c = 'PureConnect Subscription';
        list_NewQuotes[0].Order_Type__c = 'Amend';
        update list_NewQuotes[0];
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
         Cloud_Deployment__c CDEa = new Cloud_Deployment__c();
        CDEa.Account__c =list_NewAccts[0].Id;
        CDEa.Quote__c =list_NewQuotes[0].Id;
        CDEa.Cloud_Platform__c= 'PureEngage Subscription';
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
        
        Subscription__c subc = new Subscription__c();
        subc.Offering_Type__c = 'PureEngage Subscription'; 
        subc.Sale_Type__c = 'Direct';
        subc.Account__c = list_NewAccts[0].Id;
        subc.Subscription_Start_Date__c = Date.today();        
        insert subc;
        
        Cloud_Deployment__c CDE = new Cloud_Deployment__c();
        CDE.Account__c =list_NewAccts[0].Id;
        CDE.Quote__c =list_NewQuotes[0].Id;
        CDE.Cloud_Platform__c= 'PureEngage Subscription';
        CDE.Order__c= objOrders[0].id;
        CDE.Opportunity__c= list_NewOpps[0].Id;
    	insert CDE;
        
        Subscription__c subcw = new Subscription__c();
        subcw.Offering_Type__c = 'PureEngage Subscription'; 
        subcw.Sale_Type__c = 'Direct';
        subcw.Account__c = list_NewAccts[0].Id;
        subcw.Subscription_Start_Date__c = Date.today();        
        insert subcw;
        
        
        Subscription__c subc1 = new Subscription__c();
        subc1.Offering_Type__c = 'PureConnect Cloud'; 
        subc1.Sale_Type__c = 'Indirect';
        subc1.Account__c = list_NewAccts[0].Id;
        subc1.Subscription_Start_Date__c = Date.today();        
        insert subc1;
        
        CDE.Cloud_Platform__c ='PureConnect Subscription';
        update CDE;
        
        
         
        
        
        
    }

}