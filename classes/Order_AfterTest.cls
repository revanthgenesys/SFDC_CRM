/************************************************************************************
Purpose : Unit test class for Order_After trigger
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
private class Order_AfterTest {
    
    static Subscription__c objNewSubscription = new Subscription__c();
    static String strAmendQuoteId = null;
    static List<BigMachines__Quote__c> list_NewQuotes = new List<BigMachines__Quote__c>();
    
    
   static testMethod void intialTest() {
        
        prepareData();
        
        Test.setCurrentPageReference(new PageReference('Page.OptyQuoteCategory')); 
        System.currentPageReference().getParameters().put('oppId', list_NewQuotes[0].BigMachines__Opportunity__c);  
        OptyQuoteHandler objOptyQuoteHandler = new OptyQuoteHandler();
        objOptyQuoteHandler.selectedSubscrToAmend = objNewSubscription.Id;
        objOptyQuoteHandler.map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(list_NewQuotes[0].BigMachines__Account__c, 'PureCloud');
        Test.startTest();
        objOptyQuoteHandler.strSubscrSubType = Label.Amend_Subscription;
     //   PageReference newQuotePage = objOptyQuoteHandler.createAmendPureCloudQuote();
        //String strAmendQuoteId = newQuotePage.getParameters().get('id'); 
        
        Util.Bypass_Trigger_Chk = false;      
        TriggerFlowManager.ORDER_AFTER_SCLINES_POPULATE = false;
        TriggerFlowManager.ORDER_AFTER_UPDATE_TRIGGER = false;  
        TriggerFlowManager.PURECLOUDPROJECT_TRIGGER_RUN = false;
        TriggerFlowManager.SUBSCRIPTION_PRODUCT_TRIGGER_RUN = false;
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createPCOrders(strAmendQuoteId, list_NewQuotes[0].BigMachines__Opportunity__c, 1);
        
        
            OrderTrigger_Utils_Class.setOrdAdrInsertFlag(true);   
            TriggerFlowManager.ORDER_AFTER_UPDATE_TRIGGER = true;
            list_NewOrders[0].status__c = 'Approved';
            //update list_NewOrders;
        Test.stopTest();      
    } 
    
    
    static testMethod void otherTest1() {
        prepareData();
        
        Test.setCurrentPageReference(new PageReference('Page.OptyQuoteCategory')); 
        System.currentPageReference().getParameters().put('oppId', list_NewQuotes[0].BigMachines__Opportunity__c);  
        OptyQuoteHandler objOptyQuoteHandler = new OptyQuoteHandler();
        objOptyQuoteHandler.selectedSubscrToAmend = objNewSubscription.Id;
        objOptyQuoteHandler.map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(list_NewQuotes[0].BigMachines__Account__c, 'PureCloud');
        Test.startTest();
        objOptyQuoteHandler.strSubscrSubType = Label.Amend_Subscription;
      //  PageReference newQuotePage = objOptyQuoteHandler.createAmendPureCloudQuote();
        //String strAmendQuoteId = newQuotePage.getParameters().get('id'); 
        
        Util.Bypass_Trigger_Chk = false; 
        
            List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createPCOrders(strAmendQuoteId, list_NewQuotes[0].BigMachines__Opportunity__c, 1);
            list_NewOrders[0].RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c' AND Name = 'Hardware Order'].Id;
            list_NewOrders[0].status__c = 'Approved';
            list_NewOrders[0].License_FYM_Detail__c = 'Subscription Order';
            //update list_NewOrders;
            
            list_NewOrders[0].RecordTypeId = Label.Cloud_Monthly_Order_RecordTypeId;
            list_NewOrders[0].status__c = 'Complete';
            
            update list_NewOrders;
        Test.stopTest();
    }
    
/*    static testMethod void otherTest2() {
        
       
           // Order__c testOrder = [Select id,status__c,Quote__r.BigMachines__Opportunity__r.Country_Region__c from Order__c where Quote__c != null and Offering_Type__c = 'PureCloud' and status__c != 'Approved' and RecordType.Name = 'Hardware Order' and Quote__r.BigMachines__Opportunity__r.Country_Region__c = 'APAC' order by lastmodifieddate desc limit 1];
            Order__c testOrder = [Select id,status__c,Quote__r.BigMachines__Opportunity__r.Country_Region__c from Order__c where Quote__c != null and Offering_Type__c = 'PureCloud' and status__c != 'Approved' and RecordType.Name = 'Hardware Order' order by lastmodifieddate desc limit 1];
            system.debug('in testclass'+testOrder.Quote__r.BigMachines__Opportunity__r.Country_Region__c);
            testOrder.status__c = 'Approved';
            testOrder.Bypass_Service_Contract__c = false;
            testOrder.Maintenance_Amount__c = 10;
            testOrder.Invoice_Date__c = Date.today();
           update testOrder;
            Test.startTest();            
            testOrder.status__c = 'Completed';
            update testOrder;
            Test.stopTest();
            testOrder.status__c = 'Cancelled';
            update testOrder;
            
            
        
    }*/
    
    
    static testMethod void otherTest4() {
        
        Test.startTest();
            TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK = null;
            TriggerFlowManager.ORDER_BEFORE_INSERT_TRIGGER = true;
            Order__c testOrder = [Select id,recordtypeid,status__c,Quote__r.BigMachines__Opportunity__r.Country_Region__c,Opportunity__c from Order__c where Status__c != 'Cancelled' and Opportunity__c != null order by lastmodifieddate desc limit 1];
                        
            Order__c testOrder2 = testOrder.clone();
            testOrder2.recordtypeid = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
                     
            insert testOrder2;
            
            TriggerFlowManager.ORDER_BEFORE_UPDATE_TRIGGER = true;
            testOrder2.Status__c = 'Cancelled';
            update testOrder2;
            
            testOrder2.Status__c = 'Approved';
            testOrder2.License_FYM_detail__c = 'Hardware Order';
            testOrder2.Bypass_Service_Contract__c = false;
            testOrder2.Maintenance_Start__c = system.today();
            testOrder2.Maintenance_End__c = system.today() + 360;
            update testOrder2;

        Test.stopTest();
        
    }

    @isTest
    static void testPureEngageSubscription() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        update list_NewQuotes[1];

        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);
        list_NewQuotes[1].Amendment_For__c = objNewSubscription.Id;
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
       List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders2(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
       Util.Bypass_Trigger_Chk = false;
         list_NewOrders[1].status__c = 'Completed';
        list_NewOrders[1].Generate_Subscription_Record__c = true;
        list_NewOrders[1].PO_Number__c = 'test123';
        list_NewOrders[1].status__c = 'test';

        update list_NewOrders[1];
        /*test.startTest();
        list_NewOrders[1].PO_Number__c = 'test4567';
        list_NewOrders[1].status__c = 'Pending FYM PO';
        update list_NewOrders[1];
        test.stopTest();*/
       
        
    }

     @isTest
    static void testOrderBeforeUpdate() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        update list_NewQuotes[1];
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
        Util.Bypass_Trigger_Chk = false;
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders3(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
        
        list_NewOrders[1].status__c = 'Completed';
        list_NewOrders[1].Generate_Subscription_Record__c = true;
        list_NewOrders[1].RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('PPU Order').getRecordTypeId();

        update list_NewOrders[1];
       
        
    }

     @isTest
    static void testOrderBeforeInsert() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        update list_NewQuotes[1];
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
        Util.Bypass_Trigger_Chk = false;
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders3(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
        list_NewOrders[1].status__c = 'Completed';
        list_NewOrders[1].Generate_Subscription_Record__c = true;

        update list_NewOrders[1];
       
        
    }
    @isTest
    static void testOrderBeforeInsert2() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        update list_NewQuotes[1];
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
        Util.Bypass_Trigger_Chk = false;
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders2(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
        list_NewOrders[0].status__c = 'Completed';
        list_NewOrders[0].Generate_Subscription_Record__c = true;
        list_NewOrders[0].Ship_software_via__c = 'Courier';
        update list_NewOrders[0];
        Order__c objOrder = [Select Id,Ship_software_via__c from Order__C where Id = :list_NewOrders[0].Id limit 1];
        System.debug('updated order'+ objOrder.Ship_software_via__c);
        list_NewOrders[0].Ship_software_via__c = 'FTP';
        update list_NewOrders[0];

       // Map<Id, Id> lst = new Map<id,Id>{objOrder.Id => list_NewQuotes[1].Id};
       //  System.enqueueJob( new OrderAfterTrigExtension(lst, list_NewQuotes, objOrder)); 
    }
    @isTest
    static void testOrderBeforeUpdate2() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Lines_of_Businesses__c = 'PureCloud';
        update list_NewOpps[0];
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureCloud';
        list_NewQuotes[1].Order_Type__c = 'New Subscription';
        update list_NewQuotes[1];

        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
        
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders2(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
        Order__c objOrder = [Select Id,Offering_Type__c from Order__C where Id = :list_NewOrders[0].Id limit 1];
        System.debug('offering type'+ objOrder.Offering_Type__c);
        Util.Bypass_Trigger_Chk = false;
        list_NewOrders[1].Generate_Subscription_Record__c = true;
        list_NewOrders[1].Status__c = 'Approved';
        list_NewOrders[1].Ship_software_via__c = 'FTP';
        list_NewOrders[1].End_User_Name__c = list_NewAccts[0].Id;
        list_NewOrders[1].Sold_To_Name__c = list_NewAccts[0].Id;
        update list_NewOrders[1];
    }

    @isTest
    static void testOrderBeforeUpdate3() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Lines_of_Businesses__c = 'PureCloud';
        update list_NewOpps[0];
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureCloud';
        list_NewQuotes[1].Order_Type__c = 'New Subscription';
        update list_NewQuotes[1];

        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
        
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders4(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
        //Order_Line_Item__c objOL = TestDataFactoryForQuoteTool.createOrderLineItems(list_NewOrders[1]);
        Order__c objOrder = [Select Id,Offering_Type__c from Order__C where Id = :list_NewOrders[0].Id limit 1];
        System.debug('offering type'+ objOrder.Offering_Type__c);
        Util.Bypass_Trigger_Chk = false;
        list_NewOrders[1].Generate_Subscription_Record__c = true;
        list_NewOrders[1].Status__c = 'Completed';
        list_NewOrders[1].Ship_software_via__c = 'FTP';
        update list_NewOrders[1];
    }

    @isTest
    static void testOrderBeforeUpdate4() {
        
        //Create account, opp and quote
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Lines_of_Businesses__c = 'PureEngage';
        update list_NewOpps[0];
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);        
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[0].Order_Type__c = 'New Subscription';
        update list_NewQuotes[0];

        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders4(list_NewQuotes[0].Id, list_NewQuotes[0].BigMachines__Opportunity__c, 1);
        Order_Line_Item__c objOL = TestDataFactoryForQuoteTool.createOrderLineItems(list_NewOrders[0]);
        Order__c objOrder = [Select Id,Offering_Type__c,Maintenance_Start__c,Maintenance_End__c from Order__C where Id = :list_NewOrders[0].Id limit 1];
        objOrder.Maintenance_Start__c = System.today();
        objOrder.Maintenance_End__c = System.today().addDays(30);
        System.debug('offering type'+ objOrder.Offering_Type__c);
        Util.Bypass_Trigger_Chk = false;
        list_NewOrders[0].Generate_Subscription_Record__c = true;
        //list_NewOrders[1].Status__c = 'Approved';
        list_NewOrders[0].Ship_software_via__c = 'FTP';
        //list_NewOrders[1].License_FYM_detail__c ='Maintenance Only Order';
        //update list_NewOrders[1];
        
         Map<Id, Id> lst = new Map<id,Id>{objOrder.Id => list_NewQuotes[0].Id};
         System.enqueueJob( new OrderAfterTrigExtension(lst, list_NewQuotes, objOrder)); 
    }
    private static void prepareData() {
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00);
        insert objsub;
        list_NewQuotes[0].Amendment_For__c = objsub.id;
        list_NewQuotes[0].Order_Type__c = Label.Amend_Subscription;
        update list_NewQuotes;
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        Util.Bypass_Trigger_Chk = false;
        List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createPCOrders(list_NewQuotes[0].Id, list_NewOpps[0].Id, 3);
        System.assertEquals(list_NewOrders.size(), 3);        

        TriggerFlowManager.ORDER_AFTER_UPDATE_TRIGGER = true;
        OrderTrigger_Utils_Class.setOrdAdrInsertFlag(true);        
        
        list_NewOrders[1].status__c = 'Rejected';
        list_NewOrders[1].Reject_Reasons__c = 'Test Reason';
        list_NewOrders[1].Original_Parent_Order1__c = list_NewOrders[2].Id;
        list_NewOrders[2].status__c = 'Approved';
        update list_NewOrders;
        
        Util.Bypass_Trigger_Chk = true;        
        list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<Subscription__c> lst = [SELECT Id FROM Subscription__c WHERE Quote__c =: list_NewQuotes[0].Id LIMIT 1];
        if ( lst.size()>0 )
             objNewSubscription = lst[0];
        else {
            objNewSubscription = objsub;
        }

        //return list_NewQuotes;   
     }
    
    @isTest
    static void testMethod1() {
        
        //Create account, opp and quote
        //Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);
        test.startTest();
        insert objNewSubscription;
        system.debug('objNewSubscription####0'+objNewSubscription.Version__c);
        system.debug('objNewSubscription####0'+objNewSubscription.Id);
        //Subscription__c CCDB= new Subscription__c();
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[1].Order_Type__c = Label.Amend_Subscription;
        list_NewQuotes[1].Amendment_For__c = objNewSubscription.Id;
        update list_NewQuotes[1];
        
        system.debug(list_NewQuotes[1].Order_Type__c+'##1########2##'+list_NewQuotes[1].Amendment_For__c);
        system.debug('########'+list_NewQuotes[1].Amendment_For__r.Version__c);
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
       List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders2(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
       Util.Bypass_Trigger_Chk = false;
       list_NewOrders[1].status__c = 'Completed';
        list_NewOrders[1].Generate_Subscription_Record__c = true;

        update list_NewOrders[1];
        test.stopTest();
       
        
    }
    @isTest
    static void testMethod2() {
        
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
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        
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
            insert objNewQuoteProduct;            
        
        BigMachines__Quote_Product__c objNewQuoteProduct2 = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = list_NewQuotes[1].Id, BigMachines__Product__c = list_Products[0].Id,
                Name = list_Products[0].Name, Build_Type__c = list_Products[0].Name, APN_Number__c = list_Products[0].APN_Number__c,
                BigMachines__Quantity__c=100, BigMachines__Sales_Price__c=1000,Quantity__c=100,
                Bundle__c = obj_ProductGroup.Id,Bundle_Line__c=objNewQuoteProduct.Id);
            insert objNewQuoteProduct2;
        
        /*Product_Group__c PG=[SELECT Id,Group_Type__c FROM Product_Group__c WHERE id =: list_NewQuoteProds2[0].Bundle__c limit 1];
        PG.Group_Type__c='Base Package';
        update PG;
        List<Product_Group__c> updatePG= new List<Product_Group__c>();
        for(Product_Group__c PG:LstPGs){
            PG.Group_Type__c='Base Package';
            updatePG.add(PG);
        }
        Update updatePG;*/
        
       List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders2(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
       Util.Bypass_Trigger_Chk = false;
       list_NewOrders[1].status__c = 'Completed';
        list_NewOrders[1].Generate_Subscription_Record__c = true;
        //list_NewOrders[1].Original_Parent_Order1__c= list_NewOrders[0].id;
        update list_NewOrders[1];
        
        //OrderAfterTrigExtension.testCoverageMethod(); 
    }
    
    
 @isTest
    static void testAfterOrderTrigExtension() {
       
        //Create account, opp and quote
        //Util.Bypass_Trigger_Chk = true;
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties2(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);
        test.startTest();
        insert objNewSubscription;
        system.debug('objNewSubscription####0'+objNewSubscription.Version__c);
        system.debug('objNewSubscription####0'+objNewSubscription.Id);
        //Subscription__c CCDB= new Subscription__c();
        list_NewQuotes[1].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[1].Order_Type__c = Label.Amend_Subscription;
        list_NewQuotes[1].Amendment_For__c = objNewSubscription.Id;
        update list_NewQuotes[1];
        
        system.debug(list_NewQuotes[1].Order_Type__c+'##1########2##'+list_NewQuotes[1].Amendment_For__c);
        system.debug('########'+list_NewQuotes[1].Amendment_For__r.Version__c);
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        
        List<BigMachines__Quote_Product__c> list_NewQuoteProds2 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
       List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders2(list_NewQuotes[1].Id, list_NewQuotes[1].BigMachines__Opportunity__c, 2);
       Util.Bypass_Trigger_Chk = false;
       list_NewOrders[0].status__c = 'Completed';       
        list_NewOrders[0].Generate_Subscription_Record__c = true;
		list_NewOrders[1].Original_Parent_Order1__c=list_NewOrders[0].id;
        update list_NewOrders;
        test.stopTest();
    }
    
}