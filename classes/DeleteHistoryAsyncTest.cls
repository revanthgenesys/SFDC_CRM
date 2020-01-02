@isTest
public class DeleteHistoryAsyncTest {
       static testMethod void insertNewOpportunity() {   
           String Oper ='delete';
           String Oprev='restore';
           
        RecordType rt = [
            select Name
            from RecordType
            where Name = 'GEN - Opportunity Record Type'
        ];
        Auto_number__c myCS1 = new Auto_number__c();
        myCS1.Name='start';
        myCS1.values__c=1;
        insert myCS1;
       Product2 pro = new Product2(Name = 'test prd', Family = 'test');
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
        
        insert testOpp;
            SourceAccounts__c sacct = new SourceAccounts__c();        
        sacct.Account__c = acc.id; 
        sacct.Type__c = 'PureCloud';
        sacct.Offering_detail__c = 'Pilot/Trial/POC';
        sacct.Opportunity__c = testOpp.id;
        sacct.Trial_Status__c = 'Active';
        insert sacct;
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry.Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1');
        insert oli1;    
        
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = testOpp.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Service_Level__c = 'Business';
        objTestQuote.Pricing_Model__c = 'Enabled';
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.Duration_Unit__c = 'Months';
        objTestQuote.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote.Order_Type__c = 'Revenue';
        objTestQuote.End_User_ID__c =acc.id;
        objTestQuote.BigMachines__Account__c = acc.id;
        objTestQuote.Sold_To_Name__c = acc.id; 
        objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote.Support_Owner__c = acc.id;
        objTestQuote.System_Integrator__c = acc.id;
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'On Premise';
        objTestQuote.Expiration_Date__c = Date.today().addDays(90);
        objTestQuote.Approval_Submission_Date__c = Date.today();
        objTestQuote.Offering_Type__c = 'PureConnect Subscription';
        insert objTestQuote;
            
        BigMachines__Quote_Product__c QuoteP = new BigMachines__Quote_Product__c(BigMachines__Product__c = pro.Id,BigMachines__Sales_Price__c = 2,
                            BigMachines__Quote__c = objTestQuote.Id,BigMachines__Quantity__c = 1);           
           
        insert QuoteP;
           
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = objTestQuote.id;
        ord_1.Subsidaries__c = 'a24U00000004Xlg';
        ord_1.License_FYM_detail__c='Both License & Maintenance Order';
        Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Hardware Order').getRecordTypeId();
        ord_1.RecordTypeId = recordTypeId; 
        insert ord_1;

           
        Order_Line_Item__c oline =  new Order_Line_Item__c();
        oline.Order__c = ord_1.Id;
        oline.Product__c = pro.Id;
        oline.Contract_Line_Update_Status__c = '';
        oline.BigMachines_Quantity__c = 1;
        oline.Sales_Price__c = 10;
        insert oline;
        List<Order_Line_Item__c> OlList = new List<Order_Line_Item__c>();
        OlList.add(oline);
       Order_Line_Item__c oline_sec =  new Order_Line_Item__c();
       oline_sec.Order__c = ord_1.Id;
       oline_sec.Product__c = pro.Id;
       oline_sec.Contract_Line_Update_Status__c = '';
       oline_sec.BigMachines_Quantity__c = 1;
       oline_sec.Sales_Price__c = 10;
       insert oline_sec; 
       OlList.add(oline_sec);     
         Map<id,OpportunityLineItem> deletedlinitem =new Map<id,OpportunityLineItem> {oli1.Id => oli1};
         Map<id,Opportunity> deletedoppitem =new Map<id,Opportunity> {testOpp.Id => testOpp};
         Map<id,BigMachines__Quote__c> deletedQitem =new Map<id,BigMachines__Quote__c> {objTestQuote.Id => objTestQuote};
         Map<id,BigMachines__Quote_Product__c> deletedQPitem =new Map<id,BigMachines__Quote_Product__c> {QuoteP.Name => QuoteP};
         Map<id,Order__c> deletedOitem =new Map<id,Order__c> {ord_1.Id => ord_1};
        Map<id,Order_Line_Item__c> deletedOlitem =new Map<id,Order_Line_Item__c> {oline.Id => oline};
          Test.startTest();
        DeleteHistoryAsync mytestclass = new DeleteHistoryAsync(deletedlinitem,oper);
        DeleteHistoryAsync mytestclass1 = new DeleteHistoryAsync(deletedlinitem,oprev);
        DeleteHistoryAsync mytestclass16 = new DeleteHistoryAsync(deletedlinitem,oper);
        DeleteHistoryAsync mytestclass17 = new DeleteHistoryAsync(deletedlinitem,oprev);
        DeleteHistoryAsync mytestclass2 = new DeleteHistoryAsync(deletedoppitem,oper);
        DeleteHistoryAsync mytestclass3 = new DeleteHistoryAsync(deletedoppitem,oprev);
        DeleteHistoryAsync mytestclass4 = new DeleteHistoryAsync(deletedQitem,oper);
        DeleteHistoryAsync mytestclass5 = new DeleteHistoryAsync(deletedQitem,oprev);
        DeleteHistoryAsync mytestclass10 = new DeleteHistoryAsync(deletedQpitem,oper);
        DeleteHistoryAsync mytestclass11 = new DeleteHistoryAsync(deletedQpitem,oprev);
        DeleteHistoryAsync mytestclass6 = new DeleteHistoryAsync(deletedOitem,oper);  
        DeleteHistoryAsync mytestclass7 = new DeleteHistoryAsync(deletedOitem,oprev);     
       DeleteHistoryAsync mytestclass8 = new DeleteHistoryAsync(deletedOlitem,oper);  
       DeleteHistoryAsync mytestclass9 = new DeleteHistoryAsync(deletedOlitem,oprev);
       OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry.Id, Quantity=1, UnitPrice=400, Description__c='Test OLI Item 2');
       insert oli2; 
       Map<id,Opportunity> deletedoppitem1 =new Map<id,Opportunity> {testOpp.Id => testOpp};
       DeleteHistoryAsync mytestclass12 = new DeleteHistoryAsync(deletedoppitem1,oper);
       DeleteHistoryAsync mytestclass13 = new DeleteHistoryAsync(deletedoppitem1,oprev);
       Map<id,OpportunityLineItem> deletedlinitem1 =new Map<id,OpportunityLineItem> {oli2.Id => oli2};
       DeleteHistoryAsync mytestclass14 = new DeleteHistoryAsync(deletedlinitem1,oper);
       DeleteHistoryAsync mytestclass15 = new DeleteHistoryAsync(deletedlinitem1,oprev);



    
       delete ord_1;  
       delete objTestQuote;
       
          
    
        Test.stopTest();
             }
}