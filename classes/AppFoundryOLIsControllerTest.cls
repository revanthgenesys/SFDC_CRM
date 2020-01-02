/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest(SeeAllData=true)
private class AppFoundryOLIsControllerTest {

   static testMethod void viewOrderLineItemsTestMethod() {
        String currISOCode = null;
    	
        List<Product2> testprod =  TestUtil.createProducts(1, true);
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
       
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 prod = new Product2();
        prod.Name = 'Test Prod ';
        prod.recordTypeId = rtypes[0].Id;
        prod.Type__c = 'AppFoundry';
        insert prod;
      
        Pricebook2 pbook_std = [select id from Pricebook2 where Pricebook2.Name = 'Standard Price Book' limit 1];
        
        //Pricebook2 pbook_cust = [select id from Pricebook2 where Name = 'Sales PriceBook' limit 1];
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pbook_std.Id;
        pbe1.IsActive = true;
        pbe1.Product2Id = prod.Id;
        pbe1.UnitPrice = 10.1;
        pbe1.UseStandardPrice = false;
        pbe1.CurrencyIsoCode = 'USD';
        insert pbe1;
        
        /*
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pbook_cust.Id;
        pbe2.IsActive = true;
        pbe2.Product2Id = prod.Id;
        pbe2.UnitPrice = 10.1;
        pbe2.UseStandardPrice = false;
        pbe2.CurrencyIsoCode = currISOCode;
        insert pbe2; */
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = testOpp.id;
        oli1.PricebookEntryId = pbe1.id;
        insert oli1;
        
        Order__c order =  new Order__c();
      	order.Maintenance_Start__c = Date.today();
      	order.Maintenance_End__c = Date.today().addYears(1);
      	order.Numb_of_Maint_Months__c = 12;
      	order.status__c = 'In Progress';
      	order.Approved_By_Manager__c = false;
      	order.RecordTypeId = '012U0000000M2Tw';
      	Order.Opportunity__c = testOpp.id;
      	insert order;
      	
      	
      	Order_Line_Item__c oline =  new Order_Line_Item__c();
      	oline.Order__c = order.Id;
      	oline.Product__c = prod.Id;
      	oline.Contract_Line_Update_Status__c = '';
      	oline.BigMachines_Quantity__c = 1;
      	oline.Sales_Price__c = 10;
      	oline.Name = '1';
        
        PageReference pageRef = Page.AppFoundryOrderLineItem;
			Test.setCurrentPage(pageRef);	
	    	AppFoundryOLIsController obj = new AppFoundryOLIsController(new ApexPages.StandardController(order)); 
	    	obj.newOrderLineItem();
	  }
}