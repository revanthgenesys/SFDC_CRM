@istest(seeAllData = true)
public class PublicGroupReportControllerOpen_Test{
    
    static testMethod void PublicGroupReportController_TestMethod() { 
        
        Test.StartTest();
        /*Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = testQuote.id;
        insert ord_1;*/
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name='Test Prod1';
        objTestProd1.recordTypeId = rtypes[0].Id;
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'testAshosh12121';
       
        insert objTestProd1;
        
        /*Dynamic_Query__c dq = new Dynamic_Query__c();
        dq.Process_Name__c = 'Default';
        dq.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        string queryType = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c =' + 'Pure Cloud' + ' and Order__r.Quote__r.BigMachines__Opportunity__r.StageName =' + 'Closed' +' and Order__r.Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c =' + 'Won' + ' and Order__r.Quote__r.BigMachines__Is_Primary__c =' + 'true' + 'and (Product__r.APN_Number__c like'+ '%pureins%' + ' OR Product__r.Name like'+ '%pureins%';
        dq.Query_type__c = queryType;
        insert dq;*/
        
        //Dynamic_Query__c dq1 = new Dynamic_Query__c();
        //dq1.Process_Name__c = 'eMite_Closed Won_FY2018_MW';
        //dq1.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        //string queryType1 = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c =' + 'Pure Cloud' + ' and Order__r.Quote__r.BigMachines__Opportunity__r.StageName =' + 'Closed' +' and Order__r.Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c =' + 'Won' + ' and Order__r.Quote__r.BigMachines__Is_Primary__c =' + 'true' + 'and (Product__r.APN_Number__c like'+ '%pureins%' + ' OR Product__r.Name like'+ '%pureins%';
        //dq1.Query_type__c = queryType1;
        //insert dq1;
        
         Util.Bypass_Trigger_Chk = true;
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'GEN - Opportunity Record Type' LIMIT 1];
        Account acc = TestUtil.createAccounts(1,true)[0];
        Opportunity opp = TestUtil.createOpportunities(1,acc.id,false)[0];
        opp.AccountId = acc.id;
        opp.Cloud_Renewal__c =false;
        //opp.Win_Loss_Status__c = 'Won';
        opp.Primary_Line_of_Business__c='On Premise';
        opp.RecordTypeId = rt.id;
        opp.Lines_of_Businesses__c = 'PureConnect';
        insert opp;
        
        Opportunity opp1 = TestUtil.createOpportunities(1,acc.id,false)[0];
        opp1.Cloud_Renewal__c = false;
        opp1.Lines_of_Businesses__c = 'PureConnect';
        //opp1.Win_Loss_Status__c = 'Won';
        opp1.Primary_Line_of_Business__c = 'On Premise';
        opp1.RecordTypeId = rt.id;
        insert opp1;
        
        BigMachines__Quote__c bmQuotes = TestUtil.createQuotes(1,opp.id,false)[0];
        bmQuotes.BigMachines__Is_Primary__c = true;
        bmQuotes.Quote_Business_Type__c = 'Renewal';
        bmQuotes.End_User_ID__c = acc.id;
        bmQuotes.BigMachines__Opportunity__c = opp.Id;        
        
        insert bmQuotes;   
        
        BigMachines__Quote__c bmQuotes1 = TestUtil.createQuotes(1,opp.id,false)[0];
        bmQuotes1.BigMachines__Is_Primary__c = true;
        bmQuotes1.Quote_Business_Type__c = 'Cloud';
        bmQuotes1.End_User_ID__c = acc.id;
        bmQuotes1.BigMachines__Opportunity__c = opp1.Id;        
        insert bmQuotes1;
        
        List<Product2> list_Product = new List<Product2>();
        Product2 prod = TestUtil.createNoMaintenanceProducts(2,false)[0];
        prod.ProductSubFamily__c = 'Data Center Provisioning';
        prod.zqu__SKU__c = 'test';
        prod.Taxonomy_Solution__c = 'Digital';
        prod.Third_Party__c = 'True';
        prod.NG5_NA_USD_Price__c = 10;
        prod.Type__c = 'Product';
        list_Product.add(prod);
        
        Product2 prod1 = TestUtil.createNoMaintenanceProducts(2,false)[0];
        prod1.ProductSubFamily__c = 'Data Center Provisioning';
        prod1.zqu__SKU__c = 'test1';
        prod1.Third_Party__c = 'True';
        prod1.Type__c = 'Product';
        list_Product.add(prod1);        
        insert list_Product;
        
        
        
        /*BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();
        qp1.Product__c = list_Product.get(1).Id;            
        qp1.BigMachines__Quantity__c = 10;
        qp1.BigMachines__Sales_Price__c = 500;        
        qp1.BigMachines__Quantity__c = 2;        
        qp1.Ext_List__c = 10;
        qp1.Ext_Net_Price__c = 100;
        qp1.CurrencyIsoCode = 'USD';        
        qp1.BigMachines__Quote__c = bmQuotes1.Id;
        bmQuoteProduct.add(qp1);*/
        
        //insert bmQuoteProduct;
        
        //List<Order_Line_Item__c> list_oli = TestUtil.createOrderLines(new List<Product2>{objTestProd1}, ord_1.Id, true);
        
        PublicGroupReportControllerOpen publicGroup = new PublicGroupReportControllerOpen();
        publicGroup.loadReport();
        Test.stopTest();
    }
}