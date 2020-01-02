@isTest
private class updateopportunityfieldstest {
    public static testMethod void testupdoppfields()
                  {
            RecordType rt = [select Name from RecordType where Name = 'GEN - Opportunity Record Type'];
                      Auto_number__c myCS1 = new Auto_number__c();
        myCS1.Name='start';
        myCS1.values__c=1;
        insert myCS1;
       Product2 pro = new Product2(Name = 'test prd', Family = 'test',Forecasted__c = true,type__c='product');
       Insert pro;
        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(pro);
       Pricebook2 pBook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
       Update pBook;
       PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pBook.Id,Product2Id = pro.Id,UnitPrice = 1020,IsActive = true);
       Insert pbEntry;     
    Account acc = new Account();
    acc.Name = 'Test Account';
   acc.Partner_Success_Manager__c=UserInfo.getUserId();
    insert acc;    
        Opportunity testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rt.Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        testOpp.PriceBook2Id = pBook.Id;
        insert testopp;
        SourceAccounts__c sacct = new SourceAccounts__c();        
        sacct.Account__c = acc.id; 
        sacct.Type__c = 'PureCloud';
        sacct.Offering_detail__c = 'Pilot/Trial/POC';
        sacct.Opportunity__c = testOpp.id;
        sacct.Trial_Status__c = 'Active';
        insert sacct;
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry.Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1');
        insert oli1; 
    Delete   oli1;
    
      

}
}