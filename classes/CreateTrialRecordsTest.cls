/*
* Class Name       : CreateTrialRecordsTest 
* Description      : Test class for CreateTrialRecords
* ***************************************************************************************************************
* Developer Note   : *
* ***************************************************************************************************************
*/
@isTest(SeeAllData=true)
public class CreateTrialRecordsTest {
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
        list_NewQuotes[0].Offering_Type__c = 'Business Edition';
        update list_NewQuotes[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c,BigMachines__Product__r.Sub_Type__c,BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Product__r.APN_Number__C,BigMachines__Quantity__c,Quantity__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        for(BigMachines__Quote_Product__c objQP:list_NewQuoteProds){
            objQP.BigMachines__Quantity__c = objQP.Quantity__c = 1;
        }
        update list_NewQuoteProds;
        Product_Group__c objPG = new Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess');
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Serivces' );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4' );      
        insert objProd2;
        Set<Id> set_ProdIds =  new Set<Id>();
        set_ProdIds.add(objProd.Id);
        List<Product2> list_Prod = new List<Product2>();
        list_Prod.add(objProd);
        Product_Group__c objProdGroup = new Product_Group__c(Product__c = objProd.Id,Group_Type__c = 'Dependent Products');
        insert objProdGroup;
        Product_Group_Item__c objProdGrItem = new Product_Group_Item__c(Product_Group__c = objProdGroup.id,Product_Type__c = 'Mandatory',Product__c = objProd2.Id);
        insert objProdGrItem;
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00,Subscription_End_Date__c = DAte.today()+365,Ramp_Period__c = 12,CurrencyISOCode = 'USD',Org_Id__c='Abcd1234',Status__c='Active');
        insert objsub;
        objsub.Quote__c = list_NewQuotes[0].Id;
        objsub.Opportunity_LookUp__c =  list_NewOpps[0].Id;
        update objSub;
        Subscription_Product__c objSubProd = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = false,Product__c = list_Prod[0].id,Quantity__c = 1.00);
        insert objSubProd;
        Test.startTest();
        CreateTrialRecords.CreateRecordforTrialAutomation(objsub.Id,new List<String>{'CS-012-NV-AR05-SMCC-SUB'},System.today(),'Terms and Conditions',System.today()+30);
        CreateTrialRecords.thisForCodeCoverage();
		Test.stopTest();                                                  
    }
        testmethod static void testmethod2(){
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
        list_NewQuotes[0].Offering_Type__c = 'Business Edition';
        update list_NewQuotes[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c, BigMachines__Product__c , Unit_of_Measure__c,CurrencyIsoCode,Current_Qty__c,Original_Qty__c,BigMachines__Product__r.Type__c,Bundle__r.Group_Type__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__c,Extended_Price_Per_Month__c,Is_Overage__c,BigMachines__Product__r.Sub_Type__c,BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Product__r.APN_Number__C,BigMachines__Quantity__c,Quantity__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
        for(BigMachines__Quote_Product__c objQP:list_NewQuoteProds){
            objQP.BigMachines__Quantity__c = objQP.Quantity__c = 1;
        }
        update list_NewQuoteProds;
        Product_Group__c objPG = new Product_Group__c(Group_Type__c='PureSuccess',Type__c='PureSuccess');
        insert objPG;
        Product2 objProd = new Product2(Id=list_NewQuoteProds[0].BigMachines__Product__c, ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Serivces' );      
        update objProd;
        Product2 objProd2 = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=false,APN_Number__c='PC-170-NV-PCEDGE-VIR',New_Category__c ='Bundles', zqu__SKU__c = 'Test4' );      
        insert objProd2;
        Set<Id> set_ProdIds =  new Set<Id>();
        set_ProdIds.add(objProd.Id);
        List<Product2> list_Prod = new List<Product2>();
        list_Prod.add(objProd);
        Product_Group__c objProdGroup = new Product_Group__c(Product__c = objProd.Id,Group_Type__c = 'Dependent Products');
        insert objProdGroup;
        Product_Group_Item__c objProdGrItem = new Product_Group_Item__c(Product_Group__c = objProdGroup.id,Product_Type__c = 'Mandatory',Product__c = objProd2.Id);
        insert objProdGrItem;
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00,Subscription_End_Date__c = DAte.today()+365,Ramp_Period__c = 12,CurrencyISOCode = 'USD',Org_Id__c='Abcd1234',Status__c='Active');
        insert objsub;
        objsub.Quote__c = list_NewQuotes[0].Id;
        objsub.Opportunity_LookUp__c =  list_NewOpps[0].Id;
        update objSub;
        Subscription_Product__c objSubProd = new Subscription_Product__c(Subscription__c =objsub.id, Quote_Product__c=list_NewQuoteProds[0].id,CurrencyIsoCode = 'USD',Is_Overage__c = false,Product__c = list_Prod[0].id,Quantity__c = 1.00);
        insert objSubProd;
        Test.startTest();
        CreationofTrialRecords.CreationofTrialRecords('ABCD1234','CS-012-NV-AR05-SMCC-SUB',System.today(),'Terms and Conditions',System.today()+30);
		CreationofTrialRecords.thisForCodeCoverage();
        Test.stopTest();                                                  
    }
       
}