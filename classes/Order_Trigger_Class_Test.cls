/*
Raghu R : 2/3/2014 : MDM Project : Test Class for the triger Order_Trigger and Order_Trigger_class.

Erik D : May 15 2018 tests for trigger Order_Trigger
*/
@isTest(SeeAllData=true)
public class Order_Trigger_Class_Test {
    
      static testMethod void onAfterUpdate_test_indirect_allSame()   
      {
      test.startTest();
       
      Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
      Account testAccount_2 = TestUtil.createAccounts(1, true)[0];
      Global_Setting__c obj1;
      
      BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
      Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      Order__c ord_1 = new Order__c();
      ord_1.Quote__c = testQuote.id;
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount_1.id;
      ord_1.Sold_To_Name__c = testAccount_2.id;
      ord_1.status__c = 'In Progress';
      insert ord_1;
      test.stopTest();     
      Order__c ord_2 = new Order__c(Id=ord_1.id);
      ord_2.Subsidaries__c =  Global_Setting__c.getInstance('Japan').Id__c;
      ord_2.status__c = 'Approved';
      ord_2.End_User_Name__c = testAccount_1.id;
      ord_2.Sold_To_Name__c = testAccount_2.id;
      update ord_2; 
      
      Account_Order_Address__c ordAdr_1 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Sold To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_1;
      
      Account_Order_Address__c ordAdr_2 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test1';
      ordAdr_2.Address2__c = 'Test1';
      ordAdr_2.Address_Type__c = 'End User';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_2;
      
      Account_Order_Address__c ordAdr_3 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Bill To';
      ordAdr_1.Order__c = ord_2.id;
      insert ordAdr_3;
      
      Account_Order_Address__c ordAdr_4 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test1';
      ordAdr_2.Address2__c = 'Test1';
      ordAdr_2.Address_Type__c = 'Ship To';
      ordAdr_2.Order__c = ord_2.id;
      insert ordAdr_4;
            
      Map<Id, Order__c> oldMap= new Map<Id, Order__c>{ord_1.Id => ord_1};
      Map<Id,Order__c> newMap= new Map<Id,Order__c>{ord_2.Id => ord_2}; 

      Order_Trigger_Class.onAfterUpdate(oldMap,newMap);
      
      
      }
      
      static testMethod void onAfterUpdate_test_indirect_alldiff()   
      {
      test.startTest();
       
      Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
      Account testAccount_2 = TestUtil.createAccounts(1, true)[0];
      Global_Setting__c obj1;
      
      BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
      Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      Order__c ord_1 = new Order__c();
      ord_1.Quote__c = testQuote.id;
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount_1.id;
      ord_1.Sold_To_Name__c = testAccount_2.id;
      ord_1.status__c = 'In Progress';
      insert ord_1;
      test.stopTest();     
      Order__c ord_2 = new Order__c(Id=ord_1.id);
      ord_2.Subsidaries__c =  Global_Setting__c.getInstance('Japan').Id__c;
      ord_2.status__c = 'Approved';
      ord_2.End_User_Name__c = testAccount_1.id;
      ord_2.Sold_To_Name__c = testAccount_2.id;
      update ord_2; 
      
      Account_Order_Address__c ordAdr_1 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Sold To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_1;
      
      Account_Order_Address__c ordAdr_2 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test2';
      ordAdr_2.Address2__c = 'Test2';
      ordAdr_2.Address_Type__c = 'End User';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_2;
      
      Account_Order_Address__c ordAdr_3 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test3';
      ordAdr_1.Address2__c = 'Test3';
      ordAdr_1.Address_Type__c = 'Bill To';
      ordAdr_1.Order__c = ord_2.id;
      insert ordAdr_3;
      
      Account_Order_Address__c ordAdr_4 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test4';
      ordAdr_2.Address2__c = 'Test4';
      ordAdr_2.Address_Type__c = 'Ship To';
      ordAdr_2.Order__c = ord_2.id;
      insert ordAdr_4;
            
      Map<Id, Order__c> oldMap= new Map<Id, Order__c>{ord_1.Id => ord_1};
      Map<Id,Order__c> newMap= new Map<Id,Order__c>{ord_2.Id => ord_2}; 

      Order_Trigger_Class.onAfterUpdate(oldMap,newMap);
      
      }
      
      static testMethod void onAfterUpdate_test_indirect_soldToBilltoSame()   
      {
      test.startTest();
       
      Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
      Account testAccount_2 = TestUtil.createAccounts(1, true)[0];
      Global_Setting__c obj1;
      
      BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
      Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      Order__c ord_1 = new Order__c();
      ord_1.Quote__c = testQuote.id;
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount_1.id;
      ord_1.Sold_To_Name__c = testAccount_2.id;
      ord_1.status__c = 'In Progress';
      insert ord_1;
      test.stopTest();     
      Order__c ord_2 = new Order__c(Id=ord_1.id);
      ord_2.Subsidaries__c =  Global_Setting__c.getInstance('Japan').Id__c;
      ord_2.status__c = 'Approved';
      ord_2.End_User_Name__c = testAccount_1.id;
      ord_2.Sold_To_Name__c = testAccount_2.id;
      update ord_2; 
      
      Account_Order_Address__c ordAdr_1 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Sold To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_1;
      
      Account_Order_Address__c ordAdr_2 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test2';
      ordAdr_2.Address2__c = 'Test2';
      ordAdr_2.Address_Type__c = 'End User';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_2;
      
      Account_Order_Address__c ordAdr_3 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Bill To';
      ordAdr_1.Order__c = ord_2.id;
      insert ordAdr_3;
      
      Account_Order_Address__c ordAdr_4 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test1';
      ordAdr_2.Address2__c = 'Test1';
      ordAdr_2.Address_Type__c = 'Ship To';
      ordAdr_2.Order__c = ord_2.id;
      insert ordAdr_4;
            
      Map<Id, Order__c> oldMap= new Map<Id, Order__c>{ord_1.Id => ord_1};
      Map<Id,Order__c> newMap= new Map<Id,Order__c>{ord_2.Id => ord_2}; 

      Order_Trigger_Class.onAfterUpdate(oldMap,newMap);
      
      }
      
      
        static testMethod void onAfterUpdate_test_direct_alldiff()   
      {
      test.startTest();
       
      Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
      Account testAccount_2 = TestUtil.createAccounts(1, true)[0];
      Global_Setting__c obj1;
      
      BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
      Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      Order__c ord_1 = new Order__c();
      ord_1.Quote__c = testQuote.id;
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount_1.id;
      ord_1.Sold_To_Name__c = testAccount_2.id;
      ord_1.status__c = 'In Progress';
      insert ord_1;
      test.stopTest();     
      Order__c ord_2 = new Order__c(Id=ord_1.id);
      ord_2.Subsidaries__c =  Global_Setting__c.getInstance('Japan').Id__c;
      ord_2.status__c = 'Approved';
      ord_2.End_User_Name__c = testAccount_1.id;
      ord_2.Sold_To_Name__c = testAccount_1.id;
      update ord_2; 
      
      Account_Order_Address__c ordAdr_1 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Sold To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_1;
      
      Account_Order_Address__c ordAdr_2 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test2';
      ordAdr_2.Address2__c = 'Test2';
      ordAdr_2.Address_Type__c = 'End User';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_2;
      
      Account_Order_Address__c ordAdr_3 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test3';
      ordAdr_1.Address2__c = 'Test3';
      ordAdr_1.Address_Type__c = 'Bill To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_3;
      
      Account_Order_Address__c ordAdr_4 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test4';
      ordAdr_2.Address2__c = 'Test4';
      ordAdr_2.Address_Type__c = 'Ship To';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_4;
            
      Map<Id, Order__c> oldMap= new Map<Id, Order__c>{ord_1.Id => ord_1};
      Map<Id,Order__c> newMap= new Map<Id,Order__c>{ord_2.Id => ord_2}; 

      Order_Trigger_Class.onAfterUpdate(oldMap,newMap);
      
      delete ord_1;
      
      }
    
    static testMethod void onInsertSubscriptionOfferingType() {
        test.startTest();
        Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
        testQuote.Offering_Type__c = 'PureEngage Subscription'; // Should make the order for this quote Offering_Type__c = 'PureEngage Subscription'
        update testQuote;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        Order__c ord_1 = new Order__c();
        ord_1.Quote__c = testQuote.id;
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Opportunity__c = testOpp.id;
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.End_User_Name__c = testAccount_1.id;
        ord_1.Sold_To_Name__c = testAccount_1.id;
/*
       if(!objOrder.Synced_with_Contract__c 
       && objOrder.status__c == 'Completed' 
       && !objOrder.No_Cloud_Billing_Contract__c 
       && objOrder.Offering_Type__c != null 
       && objOrder.Offering_Type__c.contains('Subscription')) 
           list_OrdersforContracts.add(objOrder);    
    }
*/
        ord_1.Synced_with_Contract__c = false;
        ord_1.status__c = 'Completed';
        ord_1.No_Cloud_Billing_Contract__c = false;
        insert ord_1;
        test.stopTest();     
        
    }  
}