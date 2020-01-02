@isTest(SeeAllData=true)
private  class CreateOrderFromQuoteTest {
      /*
      @isTest
      static void TestCreateOrderFromQuote(){
            Test.startTest();
            //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
            Util.Bypass_Trigger_Chk = true;
            
            //Create account, opp and quote
            List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
            System.assertEquals(list_NewAccts.size(), 1);
            List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
            System.assertEquals(list_NewOpps.size(), 1);
            List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);
            System.assertEquals(list_NewQuotes.size(), 2);
            //Add quote line items         
            List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
            List<BigMachines__Quote_Product__c> list_NewQuoteProds1 = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[1].Id);
                        
            List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
            List<Account_Order_Address__c> list_NewQtAddrs1 = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[1].Id);
            
            Country__c objNewCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', Region__c='NA', RU__c='NA');    
            insert objNewCountry;
            
            list_NewOpps[0].Primary_Quote__c=list_NewQuotes[1].Id;
            list_NewOpps[0].Country__c = objNewCountry.Id;
            update list_NewOpps[0];
            
            List<Order__c> list_NewOrders = TestDataFactoryForQuoteTool.createOrders(list_NewQuotes[1].Id, list_NewOpps[0].Id, 1);
            
            Util.Bypass_Trigger_Chk = false;
            list_NewQuotes[0].Offering_Type__c = 'Business Edition';
            list_NewQuotes[0].BigMachines__Status__c = 'Order Submitted';
            list_NewQuotes[0].PureSuccess__c = 'GUIDE';
            list_NewQuotes[0].Cloud_Total__c = 100;
            list_NewQuotes[0].A_La_Carte_PureSuccess_Services_Amount__c = 0;
            list_NewQuotes[0].PureSuccess_Offer_Subscription_Amount__c = 100;
            update list_NewQuotes[0];
            Test.stopTest();
            list_NewQuotes[1].Offering_Type__c = 'Business Edition';
            list_NewQuotes[1].BigMachines__Status__c = 'Order Submitted';
            list_NewQuotes[1].PO_for_FYM__c = 'Separate PO for FYM';
            list_NewQuotes[1].Quote_Business_Type__c = 'Renewal';
            update list_NewQuotes[1];           
      }
      */
       
   /*   @isTest
      static void TestCreateOrderFromQuote2(){
          
           BigMachines__Quote__c testQuote = [Select id from BigMachines__Quote__c where Offering_Type__c = 'Business Edition' and BigMachines__Status__c != 'Order Submitted' and BigMachines__Is_Primary__c = true and PureSuccess__c = null and Does_customer_currently_have_PureSuccess__c = false and A_La_Carte_PureSuccess_Services_Amount__c = 0 order by lastmodifieddate desc limit 1];
          testQuote.BigMachines__Status__c = 'Order Submitted';
          Test.startTest();
          update testQuote;
          
          Order__c checkOrder = [select id,License_FYM_detail__c from Order__c where License_FYM_detail__c = 'License only order' or License_FYM_detail__c = 'Both License & Maintenance Order' limit 1];
          Order__c checkOrder2 = checkOrder.clone();
          checkOrder2.id = null;  
          checkOrder2.Quote__c = testQuote.id;
          insert checkOrder2;
          Test.stopTest();
      }*/
      
      @isTest
      static void TestCreateOrderFromQuote3(){
          Test.startTest();
          BigMachines__Quote__c testQuote = [Select id,Maintenance_Due_Discount_Amount__c from BigMachines__Quote__c where Offering_Type__c = 'Business Edition' and BigMachines__Status__c != 'Order Submitted' and BigMachines__Is_Primary__c = true order by lastmodifieddate desc limit 1];
          testQuote.Maintenance_Due_Discount_Amount__c=20.0;
          
          Order__c checkOrder = [select id,License_FYM_detail__c from Order__c where License_FYM_detail__c = 'Maintenance Only Order'  limit 1];
          Order__c checkOrder2 = checkOrder.clone();
          checkOrder2.id = null;  
          checkOrder2.Quote__c = testQuote.id;
          insert checkOrder2;
          
          testQuote.PO_for_FYM__c = 'Separate PO for FYM';
          testQuote.BigMachines__Status__c = 'Order Submitted';
          
          //update testQuote;
          
          Test.stopTest();
      }
      
      @isTest
      static void TestCreateOrderFromQuote4(){
          Test.startTest();
          BigMachines__Quote__c testQuote = [Select id from BigMachines__Quote__c where Quote_Business_Type__c != 'Cloud' and BigMachines__Status__c != 'Order Submitted' and BigMachines__Is_Primary__c = true order by lastmodifieddate desc limit 1];
          testQuote.Maintenance_Due_Discount_Amount__c=20.0;
          testQuote.BigMachines__Status__c = 'Order Submitted';
          update testQuote;          
          
          Test.stopTest();
      }
      
      @isTest
      static void TestCreateOrderFromQuote5(){
          Test.startTest();
          BigMachines__Quote__c testQuote = [Select id from BigMachines__Quote__c where Quote_Business_Type__c != 'Cloud' and Quote_Business_Type__c != 'On Premise' and BigMachines__Status__c != 'Order Submitted' and BigMachines__Is_Primary__c = true order by lastmodifieddate desc limit 1];
          testQuote.Maintenance_Due_Discount_Amount__c=20.0;
          testQuote.BigMachines__Status__c = 'Order Submitted';
          update testQuote;          
          
          Test.stopTest();
      }
    
    @isTest
      static void TestCreateOrderFromQuote6(){
          Test.startTest();
          BigMachines__Quote__c testQuote = [Select id from BigMachines__Quote__c where Quote_Business_Type__c = 'Cloud' and BigMachines__Status__c != 'Order Submitted' and BigMachines__Is_Primary__c = true order by lastmodifieddate desc limit 1];
          testQuote.Maintenance_Due_Discount_Amount__c=20.0;
          testQuote.BigMachines__Status__c = 'Order Submitted';
          //update testQuote;          
          
          Test.stopTest();
      }
 }