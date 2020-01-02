@isTest
private class SubscriptionBurstTermTest {
    
   @isTest(SeeAllData=true)
    static void unitTest(){
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);
        insert objNewSubscription;
        system.debug('objNewSubscription####0'+objNewSubscription.Version__c);
        system.debug('objNewSubscription####0'+objNewSubscription.Id);
        //Subscription__c CCDB= new Subscription__c();
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[1].Order_Type__c = Label.Order_Type_Amend;
        list_NewQuotes[1].Amendment_For__c = objNewSubscription.Id;
        update list_NewQuotes[1];
        
        system.debug(list_NewQuotes[1].Order_Type__c+'##1########2##'+list_NewQuotes[1].Amendment_For__c);
        system.debug('########'+list_NewQuotes[1].Amendment_For__r.Version__c);
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createSubscriptionBurstQuoteProducts(list_NewQuotes[0].Id);
		 List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
       for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        //List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
        Product_Group__c obj_ProductGroup = new Product_Group__c();
        obj_ProductGroup.Name = 'Equip,Guide,Drive,Partner';
        obj_ProductGroup.Group_Type__c = 'Base Package';
        insert obj_ProductGroup;
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = new List<BigMachines__Quote_Product__c>();
        List<Product2> list_Products = [SELECT Id, Name, APN_Number__c
                                        FROM Product2 
                                        WHERE ProductSubFamily__c = 'Data Center Provisioning' LIMIT 1];
                                         
        system.debug('product list'+ list_Products);
        BigMachines__Quote_Product__c objNewQuoteProduct = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = list_NewQuotes[1].Id, BigMachines__Product__c = list_Products[0].Id,
                Name = list_Products[0].Name, Build_Type__c = list_Products[0].Name, APN_Number__c = list_Products[0].APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Quantity__c=100
                );
            list_NewQuoteProds2.add(objNewQuoteProduct);            
        
        BigMachines__Quote_Product__c objNewQuoteProduct2 = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = list_NewQuotes[1].Id, BigMachines__Product__c = list_Products[0].Id,
                Name = list_Products[0].Name, Build_Type__c = list_Products[0].Name, APN_Number__c = list_Products[0].APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Quantity__c=100,
                Bundle__c = obj_ProductGroup.Id,Bundle_Line__c=objNewQuoteProduct.Id);
            insert objNewQuoteProduct2;		
        Subscription_Burst_Term__c term = new Subscription_Burst_Term__c(Quote__c = list_NewQuotes[0].Id,Term_Length_Months__c='3',CCDB_Subscription__c=objNewSubscription.Id);
         insert term;		
        SubscriptionBurstTerm SubsBurstTerm = new SubscriptionBurstTerm();
        test.startTest();
        Subscription_Burst_Term__c SubTest =SubsBurstTerm.addTermToQuote(list_NewQuotes[0].Id);             
        Map<Id,Id> amend = SubscriptionBurstTerm.addTermToAmend(objNewSubscription.Id,list_NewQuotes[0].Id);
        Boolean isQuoteBurstable=SubscriptionBurstTerm.isQuoteBurstable(list_NewQuotes[0].Id);
        List<Subscription_Burst_Term__c> SubsBurstTerms = SubscriptionBurstTerm.getQuoteBurstTerms(list_NewQuotes[0].Id);
        SubsBurstTerm.deleteBlankQuoteTerm(SubTest.Id);
        SubsBurstTerm.deleteQuoteBurstTerm(SubTest.Id);
        SubsBurstTerm.addMissingBurstProdsToQuote(list_NewQuotes[0].Id);
        list_NewQuoteProds2[0].Bundle_Line__c= list_NewQuoteProds[0].Id;
        insert list_NewQuoteProds2;
		list_NewQuoteProds[0].Subscription_Burst_Term__c = term.Id;
		list_NewQuoteProds[0].Bundle__c=obj_ProductGroup.Id;
		update list_NewQuoteProds;     
        List<BigMachines__Quote_Product__c> QuoteProdsList = SubscriptionBurstTerm.updateBurstBasePackageItems(list_NewQuoteProds,list_NewQuoteProds2);
        list_NewQuoteProds2[0].Weightage__c=2;
        update list_NewQuoteProds2;
        for(Integer i=0; i<list_NewQuoteProds.size(); i++)
        {
        list_NewQuoteProds[i].Quantity__c=2;
        list_NewQuoteProds[i].List_Price__c=1;
        list_NewQuoteProds[i].List_Price_1__c=2;
        list_NewQuoteProds[i].List_Price_2__c=2;
        list_NewQuoteProds[i].Partner_Price__c=2;
        list_NewQuoteProds[i].Partner_Price_1__c=2;
        list_NewQuoteProds[i].Partner_Price_2__c=2;
        list_NewQuoteProds[i].Ext_List__c=2;
        list_NewQuoteProds[i].Ext_List_Price_1__c=2;
        list_NewQuoteProds[i].Ext_List_Price_2__c=2;
        list_NewQuoteProds[i].Net_Unit_Price__c=2;
        list_NewQuoteProds[i].Net_Unit_Price_1__c=2;
        list_NewQuoteProds[i].Net_Unit_Price_2__c=2;            
        }
        update list_NewQuoteProds;
        List<BigMachines__Quote_Product__c> QuoteProdsList2 = SubscriptionBurstTerm.updateBurstBasePackageItems(list_NewQuoteProds,list_NewQuoteProds2);
		list_NewQuoteProds2[0].Weightage__c=0;
        update list_NewQuoteProds2;
        List<BigMachines__Quote_Product__c> QuoteProdsList3 = SubscriptionBurstTerm.updateBurstBasePackageItems(list_NewQuoteProds,list_NewQuoteProds2);
        SubscriptionBurstTerm.setCommitQtyOnBurstSubscrProd(list_NewSubscriptionProds);
        test.stopTest();
}   
}