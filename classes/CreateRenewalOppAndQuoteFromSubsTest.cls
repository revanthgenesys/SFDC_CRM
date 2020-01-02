/************************************************************************************
Purpose : Unit test class for CreateRenewalOppAndQuoteFromSubsBatch
Written By : Rony Joseph
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
public class CreateRenewalOppAndQuoteFromSubsTest {
    @isTest
    public static void TestMethod1(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Country__c objNewCountry = new Country__c(Name = 'United States', Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
        

        
        list_NewAccts[0].Country__c = objNewCountry.Id;     
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        list_NewQuotes[0].Subscription_End_Date__c = Date.today().addDays(120);
        update list_NewQuotes[0];
        
        JBCXM__GSRelationshipType__c jbxmgs = new JBCXM__GSRelationshipType__c();
            jbxmgs.JBCXM__Active__c = true;
            jbxmgs.Name = 'PureCloud'; 
            jbxmgs.JBCXM__Attributes__c = 'test';
            jbxmgs.JBCXM__CardConfig__c = 'test';
            jbxmgs.JBCXM__Definition__c = 'test';
            jbxmgs.JBCXM__Description__c = 'test';
            jbxmgs.JBCXM__DisplayOrder__c = 1;
            jbxmgs.JBCXM__LayoutAttribute__c = 'test';
            jbxmgs.JBCXM__LayoutCriteria__c = 'test';
            jbxmgs.JBCXM__Type__c = 'PureCloud';
            insert jbxmgs;
        
        JBCXM__GSRelationship__c jbcxm = new JBCXM__GSRelationship__c();
        jbcxm.JBCXM__GSCSM__c = UserInfo.getUserId();
        jbcxm.JBCXM__Account__c = list_NewAccts[0].Id;      
        jbcxm.JBCXM__RelationshipType__c = jbxmgs.id;
        jbcxm.PureEngage_Cloud_Stage__c = 'Steady State';
        insert jbcxm;
            
       		Product2 objProd1 = new Product2();
            objProd1.Name = 'test';
            objProd1.Quantities_Available__c = '1';
            objProd1.APN_Number__c = 'PC-170-NV-PCEDGE-VIR';
            objProd1.New_Category__c = 'Passthrough';
            objProd1.Partner_Margin_Category__c = 'Software';
            objProd1.Price_Type__c = 'Range';
            objProd1.NG5_NA_USD_Price__c = 100.00;
            objProd1.Unit_of_Measure__c = 'Seat' ;
            objProd1.Quantity__c = 1 ;
            objProd1.Product_Name__c='test';
            objProd1.Taxonomy_Solution_Category__c='Business Optimization';
            objProd1.Taxonomy_Solution__c='Integration';
            objProd1.OfferingType__c ='purecloud';
        	objProd1.Shipment_Approval__c='No Approval Required';
            objProd1.Tier__c='Preferred';
            objProd1.ProductSubFamily__c = 'Data Center Provisioning';
            
            insert objProd1;
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
 		system.debug('list_NewQuoteProds1'+ list_NewQuoteProds[0].id);   
        
        list_NewQuoteProds = [SELECT Id, Adjustment__c, Disc__c, or_Amount__c, BigMachines__Quote__c,BigMachines__Product__c,Quantity__c,List_Price__c,Partner_Price__c,Net_Unit_Price__c
                              FROM BigMachines__Quote_Product__c 
                              WHERE BigMachines__Quote__c =: list_NewQuotes[0].Id];
           system.debug('list_NewQuoteProds2'+ list_NewQuoteProds[0].id);                   
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
        list_NewQuoteProds[0].or_Amount__c='Amt';
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
        Date dtEndDate = Date.today().addDays(120);
        String strWhereCondition = ' WHERE Status__c = \'Active\' AND (Opportunity_LookUp__c != null OR Quote__c != null OR Order__c != null) AND ';
        strWhereCondition += ' Offering_Type__c = \'PureCloud\' AND Subscription_End_Date__c = ' + String.valueOf(dtEndDate);
        CreateRenewalOppAndQuoteFromSubsBatch clsOppAndQuoteRenewal = new CreateRenewalOppAndQuoteFromSubsBatch(strWhereCondition);
        Database.executeBatch(clsOppAndQuoteRenewal, 200); 
        Test.stopTest();       
        
    }
    
@isTest    
     public static void TestMethod2(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
         Country__c objNewCountry = new Country__c(Name = 'United States',Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                            New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD');    
        insert objNewCountry;
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);          
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4);        
       
        
        list_NewAccts[0].Country__c = objNewCountry.Id;
        update list_NewAccts[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        list_NewOpps[0].Country__c = objNewCountry.Id;
        update list_NewOpps[0];
        list_NewQuotes[0].Subscription_End_Date__c = Date.today().addDays(120);
        update list_NewQuotes[0];
        
        JBCXM__GSRelationshipType__c jbxmgs = new JBCXM__GSRelationshipType__c();
            jbxmgs.JBCXM__Active__c = true;
            jbxmgs.Name = 'PureCloud'; 
            jbxmgs.JBCXM__Attributes__c = 'test';
            jbxmgs.JBCXM__CardConfig__c = 'test';
            jbxmgs.JBCXM__Definition__c = 'test';
            jbxmgs.JBCXM__Description__c = 'test';
            jbxmgs.JBCXM__DisplayOrder__c = 1;
            jbxmgs.JBCXM__LayoutAttribute__c = 'test';
            jbxmgs.JBCXM__LayoutCriteria__c = 'test';
            jbxmgs.JBCXM__Type__c = 'PureCloud';
            insert jbxmgs;
        
        JBCXM__GSRelationship__c jbcxm = new JBCXM__GSRelationship__c();
        jbcxm.JBCXM__GSCSM__c = UserInfo.getUserId();
        jbcxm.JBCXM__Account__c = list_NewAccts[0].Id;      
        jbcxm.JBCXM__RelationshipType__c = jbxmgs.id;
        jbcxm.PureEngage_Cloud_Stage__c = 'Migrated';
        insert jbcxm;
         
         Product2 objProd1 = new Product2();
            objProd1.Name = 'test';
            objProd1.Quantities_Available__c = '1';
            objProd1.APN_Number__c = 'PC-170-NV-PCEDGE-VIR';
            objProd1.New_Category__c = 'Passthrough';
            objProd1.Partner_Margin_Category__c = 'Software';
            objProd1.Price_Type__c = 'Range';
            objProd1.NG5_NA_USD_Price__c = 100.00;
            objProd1.Unit_of_Measure__c = 'Seat' ;
            objProd1.Quantity__c = 1 ;
            objProd1.Product_Name__c='test';
            objProd1.Taxonomy_Solution_Category__c='Business Optimization';
            objProd1.Taxonomy_Solution__c='Integration';
            objProd1.OfferingType__c ='purecloud';
        	objProd1.Shipment_Approval__c='No Approval Required';
            objProd1.Tier__c='Preferred';
            objProd1.ProductSubFamily__c = 'Data Center Provisioning';
            
            insert objProd1;
       
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
        list_NewQuoteProds[0].or_Amount__c='Amt';
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
		CloudSubscriptionRenewalLogCreation.SuccessLogCreation(objNewSubscription.Id,list_NewOpps[0].id,list_NewQuotes[0].id);
        CloudSubscriptionRenewalLogCreation.FailureLogCreation(objNewSubscription.Id,'Error Message');
        try{
           Account acc = new Account();
            insert acc;
            }catch(Exception e)
            {ExceptionHandling.ExceptionHandling(e);} 
        Date dtEndDate = Date.today().addDays(120);
        String strWhereCondition = ' WHERE Status__c = \'Active\' AND (Opportunity_LookUp__c != null OR Quote__c != null OR Order__c != null) AND ';
        strWhereCondition += ' Offering_Type__c = \'PureCloud\' AND Subscription_End_Date__c = ' + String.valueOf(dtEndDate);
        CreateRenewalOppAndQuoteFromSubsBatch clsOppAndQuoteRenewal = new CreateRenewalOppAndQuoteFromSubsBatch(strWhereCondition);
        Database.executeBatch(clsOppAndQuoteRenewal, 200); 
        Test.stopTest();       
        
    }

}