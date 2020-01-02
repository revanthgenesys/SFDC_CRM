@isTest(SeeAllData=true)
private class Order_Quote_Attachment_Class_Test {

    static testMethod void method_1() {

      Test.startTest();
      Account testAccount = TestUtil.createAccounts(1, true)[0];
	  
      BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
	  Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      Order__c ord_1 = new Order__c();
      ord_1.Quote__c = testQuote.id;
      ord_1.Maintenance_Start__c = Date.today();
      ord_1.Maintenance_End__c = Date.today().addYears(1);
      ord_1.Opportunity__c = testOpp.id;
      ord_1.Numb_of_Maint_Months__c = 12;
      ord_1.End_User_Name__c = testAccount.id;
      ord_1.status__c = 'In Progress';
      insert ord_1;
      
      ApexPages.Standardcontroller controller = New ApexPages.StandardController(ord_1);
      Order_Quote_Attachment_Class cntler = new Order_Quote_Attachment_Class(controller);
      
      cntler.getorder();
      cntler.getAllAtachments();
      
      Test.stopTest();
           

    }
}