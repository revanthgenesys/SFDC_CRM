/************************************************************************************
Purpose : Unit test class for CreateRenewalOppAndQuoteforM2MSubs
Written By : Rony Joseph
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
public class CreateRenewalOppAndQuoteforM2MSubsTest {
    @isTest
    public static void TestMethod1(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
        Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                                  New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        list_NewQuotes[0].Subscription_End_Date__c = Date.today().addDays(120);
        update list_NewQuotes[0];
        
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c,BigMachines__Product__c,Quantity__c,List_Price__c,Partner_Price__c,Net_Unit_Price__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        
        for(BigMachines__Quote_Product__c objQP : list_NewQuoteProds) {
            //objQP.Quantity__c = 100;
            objQP.Adjustment__c=10;
            objQP.Disc__c=10;
            objQP.or_Amount__c='%';
            objQP.Group_Number__c='PG1';
            objQP.List_Price__c = objQP.List_Price__c !=null?objQP.List_Price__c:0.00;
            objQP.Partner_Price__c = objQP.Partner_Price__c !=null?objQP.Partner_Price__c:0.00;
            objQP.Net_Unit_Price__c  = objQP.Net_Unit_Price__c  !=null?objQP.Net_Unit_Price__c :0.00;
            
        }    
        list_NewQuoteProds[1].or_Amount__c='Amt';
        update list_NewQuoteProds;
        
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=true );      
        update objProd;
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = objNewSubscription.Total_Education__c= objNewSubscription.Total_Hardware__c = objNewSubscription.Total_Non_Recurring_Fees__c = 0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        list_NewQuotes[0].Amendment_For__c = objNewSubscription.Id;
        update list_NewQuotes[0];
        Test.startTest();
        CreateRenewalOppAndQuoteforM2MSubs.createRenewalOppandQuote(objNewSubscription.Id);
        Test.stopTest();
    }
    
    
}