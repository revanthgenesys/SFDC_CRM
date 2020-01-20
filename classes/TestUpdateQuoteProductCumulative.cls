/*
* Class Name       : TestUpdateQuoteProductCumulative
* Description      : Test class for UpdateQuoteProductCumulative
* ***************************************************************************************************************
* Developer Note   : *
* ***************************************************************************************************************
*/
@isTest(seealldata=true)
public class TestUpdateQuoteProductCumulative {
    testmethod static void testmethod1(){
        Id idUserId = [Select Id from User where IsActive = true and profileid='00eU0000000pPrrIAE' Limit 1].Id;
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
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        list_NewQuotes[0].Offering_Type__c = 'PureCloud';
        update list_NewQuotes[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        Decimal decLineNumber = 1;
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c,BigMachines__Product__r.Sub_Type__c,BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Product__r.APN_Number__C,BigMachines__Quantity__c,Quantity__c,Line_Number__c 
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        for(BigMachines__Quote_Product__c objQP:list_NewQuoteProds){
            objQP.Line_Number__c = decLineNumber;
            decLineNumber++; 
        }
        update list_NewQuoteProds;
        list_NewQuoteProds[0].Line_Number__c = null;
        update list_NewQuoteProds;
        Order__c objOrder = TestUtil.createOrders(1,true)[0];
        objOrder.Quote__c = list_NewQuotes[0].id;
        objOrder.RecordTypeId = '012U0000000MqMG';
        update objOrder;
        String strObjName = 'Product2';
        String strWhereCondition = 'APN_Number__c in ( \'3GP00209AAAA\',\'ED-012-NV-WEXV\',\'PC-170-NV-PCPENTST\',\'PS-170-PURE-SVTOKEN\',\'TH-900-PCEDGE-2120200\')';  
        List<Product2> list_Prods = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
        List<Order_Line_Item__c> list_OLI = TestUtil.createOrderLines(list_Prods, objOrder.id, true);
        for(BigMachines__Quote_Product__c objQP:list_NewQuoteProds){
            for(Order_Line_Item__c objOLI:list_OLI){
                if(objOLI.Product__c == objQP.BigMachines__Product__c){
                    objOLI.Quote_Product__c = objQP.Id;
                }
            }
        }
        update list_OLI;
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00,Subscription_End_Date__c = DAte.today()+365,Ramp_Period__c = 12,CurrencyISOCode = 'USD',Org_Id__c='Abcd1234',Status__c='Active');
        insert objsub;
        objsub.Quote__c = list_NewQuotes[0].Id;
        objsub.Opportunity_LookUp__c =  list_NewOpps[0].Id;
        update objSub;
        Subscription_Product__c objSubProd = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = false,Product__c = list_Prods[0].id,Quantity__c = 1.00);
        insert objSubProd;
        Test.startTest();
        UpdateQuoteProductCumulative clsOppAndQuoteRenewal = new UpdateQuoteProductCumulative();
        Database.executeBatch(clsOppAndQuoteRenewal,2000); 
        Test.stopTest();       
        
        
    }
}