/**
 */
@isTest(SeeAllData=true)
private class opportunityExtnLOB_Test {

    static testMethod void opportunityExtnLOB_Method1() {
    	
    	Test.startTest();
        List<Product2> testprod =  TestUtil.createProducts(1, true);
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
       
        PageReference pageRef = page.opportunity_productCloud;
        Test.setCurrentPage(pageRef);
            
        ApexPages.StandardController sc = new ApexPages.standardController(testOpp);                
        opportunityExtnLOB controller = new opportunityExtnLOB(sc); 
       
        controller.Change_PB();
        controller.getOppline();
    	Test.stopTest();
       }
       
        static testMethod void opportunityExtnLOB_Method2() {
    	
    	Test.startTest();
    	String currISOCode = null;
    	
        List<Product2> testprod =  TestUtil.createProducts(1, true);
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
       
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 prod = new Product2();
        prod.Name = 'Test Prod ';
        prod.recordTypeId = rtypes[0].Id;
        prod.Type__c = 'Product';
        insert prod;
      
        Pricebook2 pbook_std = [select id from Pricebook2 where IsStandard = true limit 1];
        
        Pricebook2 pbook_cust = [select id from Pricebook2 where Name = 'Sales PriceBook' limit 1];
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = pbook_std.Id;
        pbe1.IsActive = true;
        pbe1.Product2Id = prod.Id;
        pbe1.UnitPrice = 10.1;
        pbe1.UseStandardPrice = false;
        if(currISOCode != null)
        pbe1.CurrencyIsoCode = currISOCode;
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = pbook_cust.Id;
        pbe2.IsActive = true;
        pbe2.Product2Id = prod.Id;
        pbe2.UnitPrice = 10.1;
        pbe2.UseStandardPrice = false;
        if(currISOCode != null)
        pbe2.CurrencyIsoCode = currISOCode;
        insert pbe2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = testOpp.id;
        oli1.PricebookEntryId = pbe2.id;
        insert oli1;
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = testOpp.id;
        oli2.PricebookEntryId = pbe2.id;
        insert oli2;
               
        PageReference pageRef = page.opportunity_productCloud;
        Test.setCurrentPage(pageRef);
            
        ApexPages.StandardController sc = new ApexPages.standardController(testOpp);                
        opportunityExtnLOB controller = new opportunityExtnLOB(sc); 
                  
        controller.Change_PB();
        controller.getQuotecheck();
        controller.getOppline();
        controller.setLobvalue();
        controller.DeleteLineItem();
    	Test.stopTest();
        }    
   
}