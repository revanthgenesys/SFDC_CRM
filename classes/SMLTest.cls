//Naresh Kumar    11/27/2015
@isTest(seeAllData=true)
public class SMLTest{
    static Account testAccount;
    static testMethod void testSMLBatchHelper(){  
      insertTestData();
        List<Account> accounts = new List<Account>();
        accounts.add(testAccount);
        SMLBatchHelper.populateData(accounts);        
    }
    
    static testMethod void testSMLTrigger(){ 
      //SMLAccountEngagementScoreMain       
        Account testAccount1 = TestUtil.createAccounts(1, true)[0];
        SML_Account_Engagement_Score__c newScore = new SML_Account_Engagement_Score__c();
        newScore.Account__c = testAccount1.id;
        newScore.Score__c = 11;
        insert newScore; 
        newScore.Score__c = 21;
        update newScore;      
        SMLEngagementScoreDetailController testController = new SMLEngagementScoreDetailController(new ApexPages.StandardController(testAccount1)); 
    }
    
    static testMethod void testSMLAccountAttachmentController(){
      Account testAccount1 = TestUtil.createAccounts(1, true)[0];
      SML_Account_Attachments__c testAtt = new SML_Account_Attachments__c();
      testAtt.Account__c = testAccount1.id;
      insert testAtt;
      ApexPages.currentPage().getParameters().put('id', testAccount1.id); 
      ApexPages.StandardController stdController = new ApexPages.StandardController(new Account());
      SMLAccountAttachmentController controller = new SMLAccountAttachmentController(stdController);
      controller.att.Name = 'Test';
      controller.att.body = Blob.valueOf('Unit Test Attachment Body');
      controller.save();
      //controller.deleteAtt();
      controller.selectAtt();      
    }
    
    static testMethod void testSMLBatch(){
      insertTestData();
      SMLBatch testBatch = new SMLBatch('SELECT id FROM Account WHERE id = \'' + testAccount.id + '\'');
      Database.executeBatch(testBatch);
    }
    
    static testMethod void testSMLAccountSearchController(){
      Account testAccount1 = TestUtil.createAccounts(1, true)[0];
      SML_Search_View__c testView = new SML_Search_View__c();
      testView.Name = 'Test';
      insert testView;
      SML_Search_View_Account__c newViewAccount = new SML_Search_View_Account__c();
      newViewAccount.Account__c = testAccount1.id;
      newViewAccount.SML_Search_View__c = testView.id;
      insert newViewAccount;
      SMLAccountSearchController testController = new SMLAccountSearchController();
      testController.accountName = 'test';
      testController.selectedView = testView.id;
      testController.search();
      testController.showPopup();
      testController.hidePopup();
      testController.saveSelectedInView();
      testController.removeSelectedInView();
      testController.goToSML();      
    }
    
    static testMethod void testSMLOrderLineItemsController(){
    /*
      Order__c testOrder = TestUtil.createOrders(1, true)[0];
      List<Product2> prods = TestUtil.createProducts(1, true);
        List<Order_Line_Item__c> olis = TestUtil.createOrderLines(prods, testOrder.id, true);
        ApexPages.currentPage().getParameters().put('id', testOrder.id);
        */
        //SMLOrderLineItemsController testController = new SMLOrderLineItemsController(new ApexPages.StandardController(new Order__c()));
        
    }
    
    static testMethod void testSMLController1(){
      insertTestData();
      SMLController1 testController = new SMLController1();
      testController.onLoad();
      testController.populateSubRegion();
      testController.selectedFilter = 'My Team';
      //testController.filterBtn();
    testController.openHidePopup();
            
    }
    static testMethod void testSMLController2(){
      insertTestData();
      SMLController1 testController = new SMLController1();
      testController.selectedFilter = 'My Team';
      //testController.filterBtn();
      //testController.closeHidePopup();      
    }    
    
    static testMethod void testSMLNBABatchHelper(){
      insertTestData();
      SMLNBABatchHelper.populateNBAStatus(testAccount.Id);
    }
    
    static testMethod void testSMLNBABatch(){
      insertTestData();
      SMLNBABatch testBatch = new SMLNBABatch('SELECT id FROM Account WHERE id = \'' + testAccount.id + '\'');
      Database.executeBatch(testBatch);      
    }
    
    static testMethod void testSMLNBABatchSchedular(){
        insertTestData();

        SMLNBABatchSchedular sh1 = new SMLNBABatchSchedular();
        String schString = '0 0 23 * * ?'; 
        system.schedule('Test Scheduler', schString, sh1); 

    }
    
    static testMethod void testSMLPlanningUnderwayStatusBatch(){
        insertTestData();
        SMLPlanningUnderwayStatusBatch testBatch = new SMLPlanningUnderwayStatusBatch('SELECT Status__c, Account__c, Planning_Underway_Date__c  FROM SML_Data__c WHERE Status__c = \'Planning Underway\' AND Account__c != null AND Planning_Underway_Date__c < LAST_N_DAYS:180');
        Database.executeBatch(testBatch);
    }
    
    private static void insertTestData(){
        Test.StartTest();
        //Test Account
        testAccount = TestUtil.createAccounts(1, true)[0];
        
        //Test Product/Solution Categories
        List<Solution_Category__c> solutionCategories = new List<Solution_Category__c>();
        Solution_Category__c newCategory = new Solution_Category__c();
        newCategory.Name = 'Insights';
        newCategory.Solution_Name__c = 'Analytics';
        newCategory.Active__c = true;
        newCategory.Technical_Profile_Field_Name__c = 'Contact_Center_Type__c';
        solutionCategories.add(newCategory);
        
        newCategory = new Solution_Category__c();
        newCategory.Name = 'Advisors';
        newCategory.Solution_Name__c = 'Analytics';
        newCategory.Active__c = true;
        newCategory.Technical_Profile_Field_Name__c = 'Contact_Center_Types__c';        
        solutionCategories.add(newCategory);
        insert solutionCategories;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Secondary_Solution_Category__c =  'Insights';
        insert testOpp;
        
        List<Product2> testProduct = TestUtil.createProducts(1, false);
        testProduct[0].Solution_Category1__c = solutionCategories[0].id;
        insert testProduct;
        
        List<PricebookEntry> testPBEntry =TestUtil.CreatePriceBookEntries(testProduct, true);
        /*
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        testQuote.Split_Status__c = false;
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        insert testQuote;
        
        List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(1, false, testQuote.id);
        quoteProducts[0].Contract_Line_Update_Status__c = 'Split';
        quoteProducts[0].Original_Qty__c = 100;
        quoteProducts[0].Current_Qty__c = 40;
        insert quoteProducts;
        */
        
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.Split_Status__c = false;
        testQuote.BigMachines__Is_Primary__c  = true;
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.BigMachines__Status__c = 'Quote In Progress';
        testQuote.End_User_ID__c = testQuote.id;
        insert testQuote;       
        
        System.debug('NKC debug testProduct [' + testProduct + ']');
        
        BigMachines__Quote_Product__c quoteProduct = TestUtil.createQuoteProducts(testProduct, false)[0];
        quoteProduct.BigMachines__Quote__c = testQuote.id;
        quoteProduct.BigMachines__Product__c = testProduct[0].id;
        insert quoteProduct;
        
        /*
        Order__c testOrder = TestUtil.createOrders(1, false)[0]; 
        testorder.End_User_Name__c = testAccount.id;       
        insert testOrder;
        Test.StopTest();
        List<Order_Line_Item__c> testOLIs = TestUtil.createOrderLines(testProduct, testOrder.id, false);
        testOLIs[0].SML__c = true;
        insert testOLIs;  
        */
        Technical_Profile__c testTP = new Technical_Profile__c();
        testTP.Account__c = testAccount.id;
        insert testTP;
        
        Technical_Profile_Competitors__c newTPC = new Technical_Profile_Competitors__c();
        newTPC.Technical_Profile__c = testTP.id;
        newTPC.Competitor__c = 'test competitor';
        insert newTPC;
        
        Technical_Profile_Competitors__c testCompetitor = new Technical_Profile_Competitors__c();
        testCompetitor.Technical_Profile__c = testTP.id;
        insert testCompetitor;
        
        ServiceContract testSC = TestUtil.createServiceContracts(1, false)[0];
        testSC.AccountId = testAccount.id;
        testSC.Agreement_Status__c = 'Active';
        insert testSC;
        
        ContractLineItem testCLI = TestUtil.createContractLineItems(testSC.id, 1, false)[0];
        testCLI.PricebookEntryId = testPBEntry[0].id;
        insert testCLI;
        
    }
}