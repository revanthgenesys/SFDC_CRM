//Naresh Kumar
@IsTest(SeeAllData=false)
private class OptyQuoteHandlerTest {
private static user currentuser = [select id,Bypass_Triggers__c from user where id =: userinfo.getUserId()];
    static testMethod void myUnitTest1() {
        system.runAs(currentuser){
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        testOpp.Is_Downgrade__c = true;
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        //obj.retrieveQuoteCategory();
        obj.goToCloneQuoteIfOppIsDownUpGrade();       
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription' ;
        obj.strSelectedOrderType = 'New';           
        obj.nextStep1();
        obj.backStep2();
        obj.createAmendPureEngageOrPureConnectSubscriptionQuote();
        }
        
    }
    
    
    static testMethod void myUnitTest2() {
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.SMART_Qualified__c = true;
        testAccount.Key_Account_Group__c = 'LargeAcct-Avaya';
        insert testAccount;
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = null;
        testOpp.Is_Downgrade__c = true;
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        //obj.retrieveQuoteCategory();
        obj.goToCloneQuoteIfOppIsDownUpGrade();   
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription' ;
        obj.strSelectedOrderType = 'New';    
        obj.objOppQuoteCategory.Offering_Type__c = 'PureConnect';
        obj.nextStep1();
        obj.goToStep2();
       // obj.backStep2();
    }
    
    
    static testMethod void myUnitTest3() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Business Edition';
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        //obj.retrieveQuoteCategory();
        obj.goToCloneQuoteIfOppIsDownUpGrade();
    }
    
    static testMethod void myUnitTest4() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Business Edition';
        testOpp.Lines_of_Businesses__c = 'Business Edition';
        testOpp.Direct_Sales__c=false;
        testOpp.Lever__c = 'Lever 1';
        testOpp.Avaya_Contract_Expiration__c = (Date)System.today();
        
      //  Country__c con = [Select id from country__c where name = 'United States'];
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = countr.id;
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        obj.nextStep1();
         obj.backStep2();
        //obj.retrieveQuoteCategory();
        //obj.goToCloneQuoteIfOppIsDownUpGrade();
    } 
    
    static testMethod void myUnitTest5() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'On Premise';
        testOpp.currencyIsoCode = 'GBP';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Business Edition';
        testOpp.Direct_Sales__c=false;
        testOpp.BusinessPartner__c = testAccount.id;
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        //obj.selectedPricingOption ='New Pricing';
        //obj.retrieveQuoteCategory();
        obj.goToCloneQuoteIfOppIsDownUpGrade();
    } 
    
    static testMethod void myUnitTest6() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
         Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
       // Country__c con = [Select id from country__c where name = 'United States'];
        //testOpp.Sold_To_Country__c = con.id;
        testOpp.Sold_To_Country__c = countr.id;
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        //obj.retrieveQuoteCategory();
        obj.goToCloneQuoteIfOppIsDownUpGrade();
        obj.refresh();
    }    
    
    // Added by Vijay - Start
     static testMethod void myUnitTest7() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
       // Country__c con = [Select id from country__c where name = 'United States'];
        //testOpp.Sold_To_Country__c = con.id;
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
         testOpp.Sold_To_Country__c = countr.id;
         testOpp.MSA_Link_Type__c='Custom';
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
        obj.getProductVersion();
         //.Offering_Type__c
        obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage';              
        obj.objOppQuoteCategory.Platform_Type__c = 'Cloud';              
        obj.createQuoteAndGoToQuote();
        obj.redirectToRespectiveDQ();
        obj.createOnPremiseQuote();
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 prodtmp = new Product2();
        prodtmp.Name = 'Test Prod1 ';
        prodtmp.recordTypeId = rtypes[0].Id;
        prodtmp.Type__c = 'AppFoundry1';
        prodtmp.Description = 'Business Care-New(Partner)';
        prodtmp.Genesys_Care_Quote__c = true;
        prodtmp.IsActive = true;
        insert prodtmp; 
        obj.createOnPremiseQuote();
        
        obj.createCICQuote();
        obj.createCaaSOrPureCloudQuote();
        obj.createPPUQuote();
        obj.createCICQuote();
        
    }  
    
    
     static testMethod void myUnitTest71() { 

         Util.Bypass_Trigger_Chk = true;       
        system.runAs(currentuser){
      
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        testOpp.Type = 'Existing Business - Cross Sell';            
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
      //  Country__c con = [Select id from country__c where name = 'United States'];
        //testOpp.Sold_To_Country__c = con.id;
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
         testOpp.Sold_To_Country__c = countr.id;
          testOpp.MSA_Link_Type__c='Custom'; 
        insert testOpp;    

        Test.startTest();    
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        obj.getProductVersion(); 
         //.Offering_Type__c
        obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage';              
        obj.objOppQuoteCategory.Platform_Type__c = 'Cloud';  
        obj.objOppQuoteCategory.Quote_Type__c = 'Business Edition';
        obj.createQuoteAndGoToQuote();
        obj.objOpty.currencyIsoCode = 'GBP';
        //obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage';              
       // obj.objOppQuoteCategory.Platform_Type__c = 'Cloud';  
        obj.objOppQuoteCategory.Quote_Type__c = 'Subscription (Rentals)';
        obj.createQuoteAndGoToQuote();
        obj.objOppQuoteCategory.Quote_Type__c = 'Enterprise Edition';
        obj.createQuoteAndGoToQuote();
        obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage'; 
        obj.objOppQuoteCategory.Platform_Type__c = 'On Premise'; 
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription';  
       
         
     //  List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
        System.assertEquals(list_NewQuotes.size(), 2);    

       Subscription__c objNewSubscription = new Subscription__c(
                                                  Account__c = testaccount.id,ACV__c = 13389336,CMRR__c = 1115778, TCV__c=26778672, Version__c = 1,
                                                  Amendment_Date__c = System.today(), Quote__c = list_NewQuotes[0].id,  
                                                  Status__c = 'Active', Subscription_Start_Date__c = System.today(),
                                                  Subscription_End_Date__c =  System.today().addYears(1), Offering_Type__c =obj.objOppQuoteCategory.Offering_Type__c + ' ' + obj.objOppQuoteCategory.Offering_Details__c,
                                                  Billing_Category__c = 'Annual Prepay', Monthly_Minimum__c = 1550, Business_Partner__c = testaccount.id,
                                                  Ramp_Period__c = 100,     Price_Book_Currency__c='NG5_NA_USD' );          
         insert objNewSubscription;
         
        obj.repopulateQuoteType();         
        obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage'; 
        obj.objOppQuoteCategory.Platform_Type__c = 'On Premise'; 
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription';
        //obj.strSelectedOrderType = 'Amend';

         
         for(id testmapsubscriptions : obj.map_Subscriptions.keyset()){
          obj.selectedSubscrToAmend = testmapsubscriptions ;
            // system.debug('testmapid'+obj.selectedSubscrToAmend  );
         }
         
         obj.createQuoteAndGoToQuote();
         obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage'; 
        obj.objOppQuoteCategory.Platform_Type__c = 'On Premise'; 
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription';
        //obj.strSelectedOrderType = 'Amend';
         for(id testmapsubscriptions :obj.map_Subscriptions.keyset()){
          obj.selectedSubscrToAmend = testmapsubscriptions ;
            // system.debug('testmapid'+obj.selectedSubscrToAmend  );
         }
        obj.createQuoteAndGoToQuote();
        obj.objOppQuoteCategory.Offering_Type__c = 'PureConnect';
        obj.createQuoteAndGoToQuote();
        obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage';
        obj.objOppQuoteCategory.Platform_Type__c = 'On Premise';
        obj.createQuoteAndGoToQuote();
        Test.stopTest();
        obj.nextStep1();   
        //obj.createAmendPureCloudQuote();
        Util.Bypass_Trigger_Chk = true; 
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 prod = new Product2();
        prod.Name = 'Test Prod1 ';
        prod.recordTypeId = rtypes[0].Id;
        prod.Type__c = 'AppFoundry1';
        insert prod;
        
        List<Product_Group__c> testListOfProductGroups = new List<Product_Group__c>();
        Product_Group__c testPG1 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='Base Package', Type__c='Base Package', Active__c=true, Offering_Type__c = 'PureEngage Subscription');
        
        testListOfProductGroups.add(testPG1);           
        Product_Group__c testPG2 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='PureSuccess', Type__c='PureSuccess', Active__c=true, Offering_Type__c = 'PureEngage Subscription');
        testListOfProductGroups.add(testPG2);           
        Product_Group__c testPG3 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='Use Case', Type__c='Use Case', Active__c=true, Offering_Type__c = 'PureEngage Subscription');
        testListOfProductGroups.add(testPG3);  
        Product_Group__c testPG4 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='Base Package', Type__c='Base Package', Active__c=true, Offering_Type__c = 'PureEngage Subscription',Pricing_Model__c = 'User');
        testListOfProductGroups.add(testPG4); 
        insert testListOfProductGroups;
        
        List<Product_Group_Item__c> testListOfProductGroupItems = new List<Product_Group_Item__c>();
        Product_Group_Item__c testPGI1 = new Product_Group_Item__c(Product_Group__c = testListOfProductGroups[0].id, Product__c = prod.id);
        testListOfProductGroupItems.add(testPGI1);
        Product_Group_Item__c testPGI2 = new Product_Group_Item__c(Product_Group__c = testListOfProductGroups[1].id, Product__c = prod.id);
        testListOfProductGroupItems.add(testPGI2);
        Product_Group_Item__c testPGI3 = new Product_Group_Item__c(Product_Group__c = testListOfProductGroups[2].id, Product__c = prod.id);
        testListOfProductGroupItems.add(testPGI3);
        insert testListOfProductGroupItems;
            
        obj.listOfUseCases.add(testPG3);
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c( Name='Test Quote', BigMachines__Opportunity__c=testOpp.id, New_Price_Book__c= 'NG5_NA_USD' );                        
        insert objQuote;
        System.Debug('objQuote--->'+objQuote);   
        obj.addUseCases(objQuote);
        obj.objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c = false;
        obj.blnShowBaseAndPureSuccessPackage = false;
        obj.createPureEngageSubscriptionQuote();        
        obj.blnShowBaseAndPureSuccessPackage = true;
        obj.createPureEngageSubscriptionQuote();
       // obj.createPureConnectSubscriptionQuote();
        obj.changePriceBook();

        obj.createQuoteAndGoToQuote();
        obj.redirectToRespectiveDQ();
        obj.createOnPremiseQuote();
        obj.createCICQuote();
        obj.createCaaSOrPureCloudQuote();
        obj.createPPUQuote();
        obj.createCICQuote();
        obj.createAmendPureEngageOrPureConnectSubscriptionQuote(); 
        
        //BigMachines__Quote__c objQuote2 = [Select id,Offering_Type__c,New_Price_Book__c,Pricing_Model__c from BigMachines__Quote__c where Offering_Type__c = 'PureEngage Subscription' AND New_Price_Book__c != NULL order by lastmodifieddate desc limit 1];
        BigMachines__Quote__c objQuote2 = new BigMachines__Quote__c( Name='Test Quote',Offering_Type__c='PureEngage Subscription', BigMachines__Opportunity__c=testOpp.id, New_Price_Book__c= 'NG5_NA_USD' );                        
        insert objQuote2;
        list<Product_Group__c> idlist = [SELECT id FROM Product_Group__c WHERE Offering_Type__c INCLUDES (:objQuote2.Offering_Type__c)
                                                                                       AND Group_Type__c = 'Base Package' AND Active__c = true AND Pricing_Model__c = 'User'];
        System.Debug('idlist--->'+idlist);
        obj.addBundleToQuote(objQuote2);
        obj.nextStep1();
        obj.goToStep2();
        }
        
    }  
    
    
    static testMethod void myUnitTest73() {        
        system.runAs(currentuser){
         Test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        testOpp.Type = 'Existing Business - Cross Sell';            
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
      //  Country__c con = [Select id from country__c where name = 'United States'];
        //testOpp.Sold_To_Country__c = con.id;
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
         testOpp.Sold_To_Country__c = countr.id;   
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        obj.getProductVersion(); 
         //.Offering_Type__c
        obj.objOpty.currencyIsoCode = 'GBP';
        obj.objOppQuoteCategory.Offering_Type__c = 'PureConnect'; 
        obj.objOppQuoteCategory.Platform_Type__c = 'On Premise'; 
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription';  
       
         
     //  List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
        System.assertEquals(list_NewQuotes.size(), 2);    

        Subscription__c objNewSubscription = new Subscription__c(
                                                  Account__c = testaccount.id,ACV__c = 13389336,CMRR__c = 1115778, TCV__c=26778672, Version__c = 1,
                                                  Amendment_Date__c = System.today(), Quote__c = list_NewQuotes[0].id,  
                                                  Status__c = 'Active', Subscription_Start_Date__c = System.today(),
                                                  Subscription_End_Date__c =  System.today().addYears(1), Offering_Type__c='PureConnect Subscription',
                                                  Billing_Category__c = 'Annual Prepay', Monthly_Minimum__c = 1550, Business_Partner__c = testaccount.id,
                                                  Ramp_Period__c = 100,     Price_Book_Currency__c='NG5_NA_USD' );          
         insert objNewSubscription;
         
        
        Test.stopTest();
        //obj.createAmendPureCloudQuote();
        Util.Bypass_Trigger_Chk = true; 
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 prod = new Product2();
        prod.Name = 'Test Prod1 ';
        prod.recordTypeId = rtypes[0].Id;
        prod.Type__c = 'AppFoundry1';
        insert prod;
        
        List<Product_Group__c> testListOfProductGroups = new List<Product_Group__c>();
        Product_Group__c testPG1 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='Base Package', Type__c='Base Package', Active__c=true, Offering_Type__c = 'PureEngage Subscription');
        testListOfProductGroups.add(testPG1);           
        Product_Group__c testPG2 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='PureSuccess', Type__c='PureSuccess', Active__c=true, Offering_Type__c = 'PureEngage Subscription');
        testListOfProductGroups.add(testPG2);           
        Product_Group__c testPG3 = new Product_Group__c(Selected__c = true, Product__c = prod.id, Group_Type__c='Use Case', Type__c='Use Case', Active__c=true, Offering_Type__c = 'PureEngage Subscription');
        testListOfProductGroups.add(testPG3);           
        insert testListOfProductGroups;
        
        List<Product_Group_Item__c> testListOfProductGroupItems = new List<Product_Group_Item__c>();
        Product_Group_Item__c testPGI1 = new Product_Group_Item__c(Product_Group__c = testListOfProductGroups[0].id, Product__c = prod.id);
        testListOfProductGroupItems.add(testPGI1);
        Product_Group_Item__c testPGI2 = new Product_Group_Item__c(Product_Group__c = testListOfProductGroups[1].id, Product__c = prod.id);
        testListOfProductGroupItems.add(testPGI2);
        Product_Group_Item__c testPGI3 = new Product_Group_Item__c(Product_Group__c = testListOfProductGroups[2].id, Product__c = prod.id);
        testListOfProductGroupItems.add(testPGI3);
        insert testListOfProductGroupItems;
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c( Name='Test Quote', BigMachines__Opportunity__c=testOpp.id, New_Price_Book__c= 'NG5_NA_USD' );                        
        insert objQuote;         
        obj.objOppQuoteCategory.Keep_the_existing_estate_on_Perpetual__c = false;
        obj.blnShowBaseAndPureSuccessPackage = true;        
        obj.createPureConnectSubscriptionQuote();
        obj.blnShowBaseAndPureSuccessPackage = false;
        obj.createPureEngageSubscriptionQuote();
        
        
       // obj.createPureConnectSubscriptionQuote();
        //obj.changePriceBook();

        obj.createQuoteAndGoToQuote();
        obj.redirectToRespectiveDQ();
        obj.goToStep2();
       // obj.createOnPremiseQuote();
        //obj.createCICQuote();
      //  obj.createCaaSOrPureCloudQuote();
       // obj.createPPUQuote();
       // obj.createCICQuote();
       
         }
        
    }
    
    
    //Added by navaneetha
    static testMethod void myUnitTest72() {        
        system.runAs(currentuser){
         Test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';        
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;     
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = countr.id;   
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
        System.assertEquals(list_NewQuotes.size(), 2);    
             obj.createQuoteAndGoToQuote();
         obj.objOppQuoteCategory.Offering_Type__c = 'PureEngage'; 
        obj.objOppQuoteCategory.Platform_Type__c = 'On Premise'; 
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription';
        obj.strSelectedOrderType = 'Amend';
       Subscription__c objNewSubscription = new Subscription__c(
                                                  Account__c = testaccount.id,ACV__c = 13389336,CMRR__c = 1115778, TCV__c=26778672, Version__c = 1,
                                                  Amendment_Date__c = System.today(), Quote__c = list_NewQuotes[0].id,  
                                                  Status__c = 'Active', Subscription_Start_Date__c = System.today(),
                                                  Subscription_End_Date__c =  System.today().addYears(1), Offering_Type__c =obj.objOppQuoteCategory.Offering_Type__c + ' ' + obj.objOppQuoteCategory.Offering_Details__c,
                                                  Billing_Category__c = 'Annual Prepay', Monthly_Minimum__c = 1550, Business_Partner__c = testaccount.id,
                                                  Ramp_Period__c = 100,     Price_Book_Currency__c='NG5_NA_USD' );          
         insert objNewSubscription; 
         List<Subscription_product__c> list_NewSubscriptionprod = TestDataFactoryForQuoteTool2.createsubscriptionprod(objNewSubscription.id, 1);
         obj.blnShowBaseAndPureSuccessPackage = true;
         obj.createPureConnectSubscriptionQuote();
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
            List<Product2> prod2lst = new list<Product2>();
            Product2 prodtmp1 = new Product2(Name = 'Test Prod1 ',recordTypeId = rtypes[0].Id,Type__c = 'AppFoundry1',Product_Type__c = 'Standard Support - New (Partner)',Genesys_Care_Quote__c=true,IsActive=true);
            prod2lst.add(prodtmp1);
            Product2 prodtmp2 = new Product2(Name = 'Test Prod1 ',recordTypeId = rtypes[0].Id,Type__c = 'AppFoundry1',Product_Type__c = 'Priority Support - New (Partner)',Genesys_Care_Quote__c=true,IsActive=true);
            prod2lst.add(prodtmp2);
            Product2 prodtmp3 = new Product2(Name = 'Test Prod1 ',recordTypeId = rtypes[0].Id,Type__c = 'AppFoundry1',Product_Type__c = 'VIP Priority Support - New (Partner)',Genesys_Care_Quote__c=true,IsActive=true);
            prod2lst.add(prodtmp3);
            insert prod2lst;
         obj.createCICQuote();
        Test.stopTest();
        }
        
    } 
    
    static testMethod void myUnitTest8() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
        //Country__c con = [Select id from country__c where name = 'United States'];
        //testOpp.Sold_To_Country__c = con.id;
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = countr.id;
        testOpp.Is_Upgrade__c  =true;
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
        obj.goToCloneQuoteIfOppIsDownUpGrade();
        
        testOpp.Is_Upgrade__c  =false;
        testOpp.Is_Downgrade__c = true;
        update testOpp; 
        obj.goToCloneQuoteIfOppIsDownUpGrade();
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Offering_Type__c = 'PureEngage', Platform_Type__c = 'Cloud');
        obj.repopulateQuoteType();
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Offering_Type__c = 'PureEngage', Platform_Type__c = 'On Premise');
        obj.repopulateQuoteType();
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Offering_Type__c = 'PureConnect', Platform_Type__c = 'Cloud');
        obj.repopulateQuoteType();
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Offering_Type__c = 'PureConnect', Platform_Type__c = 'On Premise');
        obj.repopulateQuoteType();
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Offering_Type__c = 'PureCloud');
        obj.repopulateQuoteType();
        
    }
    
     static testMethod void myUnitTest9() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
       // Country__c con = [Select id from country__c where name = 'United States'];
       // testOpp.Sold_To_Country__c = con.id;
       Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
         testOpp.Sold_To_Country__c = countr.id;
        testOpp.Is_Upgrade__c  =true;
        
        insert testOpp;        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
         testOpp.Offering_Detail__c = 'Free Trial';
        testOpp.Lever__c = 'Lever 1';
        testOpp.Avaya_Contract_Expiration__c = (Date)System.today();
        testOpp.Quote_Type1__c = 'Business Edition';
        testOpp.Direct_Sales__c = true;
        update testOpp;   
       // List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
      //  delete listQuote;
      List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
      System.assertEquals(list_NewQuotes.size(), 2);  
      delete list_NewQuotes;
        obj.objOpty = testOpp;
        obj.createCloudQuote();
        
        testOpp.Quote_Type1__c = 'Premier Edition';
        update testOpp; 
        obj.objOpty = testOpp;  
        obj.createCloudQuote();
     }
     
     
     static testMethod void myUnitTest10() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.BusinessPartner__c = testAccount.Id;
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
         
       // Country__c con = [Select id from country__c where name = 'United States'];
        //testOpp.Sold_To_Country__c = con.id;
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = countr.id;
        testOpp.Is_Upgrade__c  =true;
        
        insert testOpp;     
        
        List<Product2> list_Products = TestUtil.createProducts(2, false);
        
        list_Products[0].Description = 'Business Care-New (Partner)';
        list_Products[1].Description = 'Business Care-New (Partner)';
        
        list_Products[0].Genesys_Care_Quote__c = true;
        list_Products[1].Genesys_Care_Quote__c = true;
        
        list_Products[0].IsActive = true;
        list_Products[1].IsActive = true;
        
        insert list_Products;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
        
        testOpp.Quote_Type1__c = 'Business Edition';
        testOpp.Direct_Sales__c = true;
        update testOpp;   
        //List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
        //delete listQuote;
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
        System.assertEquals(list_NewQuotes.size(), 2);  
         delete list_NewQuotes;
        obj.objOpty = testOpp;
        obj.createPPUQuote();
     }
     
     
     static testMethod void myUnitTest11() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.BusinessPartner__c = testAccount.Id;
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
        //Country__c con = [Select id from country__c where name = 'United States'];
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = NULL;
        testOpp.Is_Upgrade__c  =true;
        testOpp.Direct_Sales__c  =true;
        insert testOpp;     
        
        List<Product2> list_Products = TestUtil.createProducts(2, false);
        
        list_Products[0].Description = 'Business Care-New (Partner)';
        list_Products[1].Description = 'Business Care-New (Partner)';
        
        list_Products[0].Genesys_Care_Quote__c = true;
        list_Products[1].Genesys_Care_Quote__c = true;
        
        list_Products[0].IsActive = true;
        list_Products[1].IsActive = true;
        
        insert list_Products;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Pricing__c = 'New Pricing', Offering_Details__c = 'Subscription');
        obj.repopulateQuoteType();
        
        testOpp.Quote_Type1__c = 'Business Edition';
        testOpp.Direct_Sales__c = true;
        update testOpp;   
        //List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
       // delete listQuote;
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
        System.assertEquals(list_NewQuotes.size(), 2);  
         delete list_NewQuotes;
        obj.objOpty = testOpp;
        obj.createOnPremiseQuote();
        obj.objOpty.PricingType__c = 'Old / Legacy Pricing';
        obj.createCICQuote();
     }
     
    static testMethod void myUnitTest12() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.BusinessPartner__c = testAccount.Id;
        testOpp.Quote_Category__c = 'Cloud';
        testOpp.Offering_Detail__c = 'Free Trial';
        testOpp.Lever__c = 'Lever 1';
        testOpp.Avaya_Contract_Expiration__c = (Date)System.today();
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
        //Country__c con = [Select id from country__c where name = 'United States'];
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = NULL;
        testOpp.Is_Upgrade__c  =true;
        testOpp.Direct_Sales__c  =true;
        insert testOpp; 
        
        List<Product2> list_Products = TestUtil.createProducts(2, false);
        
        list_Products[0].Description = 'Business Care-New (Partner)';
        list_Products[1].Description = 'Business Care-New (Partner)';
        
        list_Products[0].Genesys_Care_Quote__c = true;
        list_Products[1].Genesys_Care_Quote__c = true;
        
        list_Products[0].IsActive = true;
        list_Products[1].IsActive = true;
        
        insert list_Products;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Pricing__c = 'New Pricing', Offering_Details__c = 'Subscription');
        obj.repopulateQuoteType();
        
        testOpp.Quote_Type1__c = 'Business Edition';
        testOpp.Direct_Sales__c = true;
        testOpp.Offering_Detail__c = 'Free Trial';
        testOpp.Lever__c = 'Lever 1';
        testOpp.Avaya_Contract_Expiration__c = (Date)System.today();
        update testOpp;   
        //List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
       // delete listQuote;
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2);
        System.assertEquals(list_NewQuotes.size(), 2);  
         delete list_NewQuotes;
        obj.objOpty = testOpp;        
        
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureConnect Cloud';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureConnect Premise';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureConnect Premise Subscription';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureConnect Premise Rental';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureEngage Cloud';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'Premier Edition Cloud';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'Outbound Engagement Cloud';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureEngage Premise';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureEngage Premise Subscription';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureEngage Premise Rental';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureEngage Cloud Partner PPU';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Lead_Offer__c = 'PureCloud';
        obj.populatePlatformAndOfferingType();
        obj.objOppQuoteCategory.Offering_Details__c = 'Subscription' ;
        obj.objOppQuoteCategory.Offering_Type__c = 'PureConnect';
        
        List<BigMachines__Quote__c> list_NewQuotes2 = TestDataFactoryForQuoteTool2.createQuotes(testOpp.Id, testAccount.Id, 2); 
        
       Subscription__c objNewSubscription = new Subscription__c(
                                                  Account__c = testaccount.id,ACV__c = 13389336,CMRR__c = 1115778, TCV__c=26778672, Version__c = 1,
                                                  Amendment_Date__c = System.today(), Quote__c = list_NewQuotes2[0].id,  
                                                  Status__c = 'Active', Subscription_Start_Date__c = System.today(),
                                                  Subscription_End_Date__c =  System.today().addYears(1), Offering_Type__c ='PureConnect Cloud',
                                                  Billing_Category__c = 'Annual Prepay', Monthly_Minimum__c = 1550, Business_Partner__c = testaccount.id,
                                                  Ramp_Period__c = 100,     Price_Book_Currency__c='NG5_NA_USD' );
        insert objNewSubscription;
                                                  
        try{
        test.startTest();
        obj.map_Subscriptions.clear();
        obj.map_Subscriptions.put(objNewSubscription.Id,objNewSubscription);
        obj.selectedSubscrToAmend = objNewSubscription.Id;
        obj.strSubscrSubType = 'Renew Existing Subscription';
        obj.createAmendPureCloudQuote();
        obj.strSubscrSubType = 'TEST';
        obj.createAmendPureCloudQuote();
        obj.createAmendPureEngageOrPureConnectSubscriptionQuote();
        test.stopTest();
        }catch(Exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
        obj.objOppQuoteCategory.Offering_Type__c = 'PureConnect On Premise';
        obj.getOrderTypes();
        obj.getSubscrSubTypes();
        obj.strSelectedOrderType = 'Amend';
        obj.getSubscrSubTypes();
        list_NewQuotes2[1].New_Price_Book__c= 'NG5_NA_USD';
        update list_NewQuotes2;
        obj.createIVRDataStorageParts(list_NewQuotes2[1]);
        obj.getPCMonthlyMinimum();
        obj.objOppQuoteCategory.Offering_Type__c = 'PureCloud';
        obj.createCaaSOrPureCloudQuote();
        obj.getproductTier();
     }


      static testMethod void testaddBundleWithLinesToQuote() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.BusinessPartner__c = testAccount.Id;
        testOpp.Quote_Category__c = 'Cloud';
        //testOpp.Is_Upgrade__c = true;
        testOpp.Lines_of_Businesses__c = 'Cloud Partner (PPU)';
        testOpp.Direct_Sales__c=false;
        //Country__c con = [Select id from country__c where name = 'United States'];
        Country__c countr = new country__C(Name = 'United Statesb',country__C = 'United Statesb', RU__c = 'North America', SubRegion__c = 'AMERICAS',SubRU__c='USA', Region__c='North America',PSRDP_Region__c='NA');
        insert countr;
        testOpp.Sold_To_Country__c = NULL;
        testOpp.Is_Upgrade__c  =true;
        testOpp.Direct_Sales__c  =true;
        insert testOpp;     
        
        List<Product2> list_Products = TestUtil.createProducts(2, false);
        
        list_Products[0].Description = 'Business Care-New (Partner)';
        list_Products[1].Description = 'Business Care-New (Partner)';
        
        list_Products[0].Genesys_Care_Quote__c = true;
        list_Products[1].Genesys_Care_Quote__c = true;
        
        list_Products[0].IsActive = true;
        list_Products[1].IsActive = true;
        
        insert list_Products;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        
        Util.Bypass_Trigger_Chk = true;
        
        obj.objOppQuoteCategory = new Admin_Dummy__c(Pricing__c = 'New Pricing', Offering_Details__c = 'Subscription');
        obj.repopulateQuoteType();
        
        testOpp.Quote_Type1__c = 'Business Edition';
        testOpp.Direct_Sales__c = true;
        update testOpp;   
        //List<BigMachines__Quote__c> listQuote = [SELECT id FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :testOpp.id];
       // delete listQuote;
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(testOpp.Id, testAccount.Id, 1);
        List<Product_Group__c>list_ProdGroup = [SELECT Id,Name,Quantity__c,Price__c,Additional_Discount__c,Discount__c,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.NG5_NA_USD_Price__c,Product__r.Is_Concurrent__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r Where Product__c != null AND Product_Type__c = 'Mandatory')FROM Product_Group__c Where Id in (Select Product_Group__c from Product_Group_Item__c where Product__c != null) AND Group_Type__c = 'Dependent Products'
                                                          AND Active__c = true limit 10];
        Set<Id>set_Id = new Set<Id>();
        for(Product_Group__c objPG : list_ProdGroup){
           set_Id.add(objPG.Id);
        }

        obj.addBundleWithLinesToQuote(list_NewQuotes[0],set_Id,'Base Package','type');
    
     }
    
}