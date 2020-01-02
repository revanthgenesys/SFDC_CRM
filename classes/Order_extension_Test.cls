/**
 */
@isTest(SeeAllData=true)
public class Order_extension_Test {

    static testMethod void Submit_BillTo() {
     
    test.startTest();
    Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
    Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
    
      Order__c ord_1 = new Order__c();
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount_1.id;
      ord_1.Bill_To_Name__c = testAccount_1.id;
      ord_1.Sold_To_Name__c = testAccount_1.id;
      ord_1.Ship_To_Name__c  = testAccount_1.id;
      insert ord_1;
      
      Account_Order_Address__c ordAdr_1 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Bill To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_1;  
      
      Account_Order_Address__c ordAdr_2 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test1';
      ordAdr_2.Address2__c = 'Test1';
      ordAdr_2.Address_Type__c = 'Bill To';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_2;
      
      Address__c Address_1 = new Address__c();
      Address_1.Address_Line_1__c = 'Test';
      Address_1.Address_Line_2__c = 'Test';
      Address_1.City__c = 'Test';
      Address_1.State__c = 'CA';
      Address_1.Country__c = 'USA';
      Address_1.Account__c = testAccount_1.iD;
      insert Address_1;  
      
      Address__c Address_2 = new Address__c();
      Address_2.Address_Line_1__c = 'Test';
      Address_2.Address_Line_2__c = 'Test';
      Address_2.City__c = 'Test';
      Address_2.State__c = 'CA';
      Address_2.Country__c = 'USA';
      Address_2.Account__c = testAccount_1.iD;
      insert Address_2;
      
      
      PageReference pageRef = page.Order_address;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id',ord_1.id);     
      
      ApexPages.StandardController sc = new ApexPages.standardController(ord_1);                
      Order_extension controller = new Order_extension(sc); 
      
      controller.recid = ord_1.id;   
      Order_extension.wAddress wrap = new Order_extension.wAddress(Address_1);
      controller.bill_to_waddress[0].selected = true; 
      controller.Ship_to_waddress[0].selected = true;
      controller.end_user_waddress[0].selected= true;
      controller.Sold_to_waddress[0].selected = true;
     
      controller.submit();
    }
    
    
    static testMethod void Submit_ShipTo() {
       
    test.startTest();
    Account testAccount_1 = TestUtil.createAccounts(1, true)[0];
    Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
    
      Order__c ord_1 = new Order__c();
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount_1.id;
      ord_1.Bill_To_Name__c = testAccount_1.id;
      ord_1.Sold_To_Name__c = testAccount_1.id;
      ord_1.Ship_To_Name__c  = testAccount_1.id;
      insert ord_1;
      
      Account_Order_Address__c ordAdr_1 = new Account_Order_Address__c();
      ordAdr_1.Address__c = 'Test1';
      ordAdr_1.Address2__c = 'Test1';
      ordAdr_1.Address_Type__c = 'Ship To';
      ordAdr_1.Order__c = ord_1.id;
      insert ordAdr_1;  
      
      Account_Order_Address__c ordAdr_2 = new Account_Order_Address__c();
      ordAdr_2.Address__c = 'Test1';
      ordAdr_2.Address2__c = 'Test1';
      ordAdr_2.Address_Type__c = 'Ship To';
      ordAdr_2.Order__c = ord_1.id;
      insert ordAdr_2;
      
      Address__c Address_1 = new Address__c();
      Address_1.Address_Line_1__c = 'Test';
      Address_1.Address_Line_2__c = 'Test';
      Address_1.City__c = 'Test';
      Address_1.State__c = 'CA';
      Address_1.Country__c = 'USA';
      Address_1.Account__c = testAccount_1.iD;
      insert Address_1;  
      
      Address__c Address_2 = new Address__c();
      Address_2.Address_Line_1__c = 'Test';
      Address_2.Address_Line_2__c = 'Test';
      Address_2.City__c = 'Test';
      Address_2.State__c = 'CA';
      Address_2.Country__c = 'USA';
      Address_2.Account__c = testAccount_1.iD;
      insert Address_2;
      
      
      PageReference pageRef = page.Order_address;
      Test.setCurrentPage(pageRef);
      
      ApexPages.currentPage().getParameters().put('id',ord_1.id);     
      
      ApexPages.StandardController sc = new ApexPages.standardController(ord_1);                
      Order_extension controller = new Order_extension(sc); 
      
      controller.recid = ord_1.id;   
      Order_extension.wAddress wrap = new Order_extension.wAddress(Address_2);
      controller.bill_to_waddress[0].selected = true; 
      controller.Ship_to_waddress[0].selected = true;
      controller.end_user_waddress[0].selected= true;
      controller.Sold_to_waddress[0].selected = true;
     
      controller.submit();
    }
    
    
    
    
}