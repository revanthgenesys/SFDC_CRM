@istest(seeAllData = true)
public class PublicGroupReportController_Test{
    
    static testMethod void PublicGroupReportController_TestMethod() { 
        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = testQuote.id;
        insert ord_1;
        
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
        Test.startTest();
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
        
        List<Order_Line_Item__c> list_oli = TestUtil.createOrderLines(new List<Product2>{objTestProd1}, ord_1.Id, true);
        
        PublicGroupReportController publicGroup = new PublicGroupReportController();
        publicGroup.loadReport();
        Test.stopTest();
    }
}