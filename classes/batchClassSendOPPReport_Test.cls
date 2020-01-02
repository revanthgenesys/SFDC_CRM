@isTest(SeeAllData = true)
public class batchClassSendOPPReport_Test{
    
    static testMethod void batchClassSendOPPReport_TestMethod() { 
    
        Dynamic_Query__c dq1 = new Dynamic_Query__c();
        dq1.Process_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq1.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        string queryType1 = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c =' + 'Pure Cloud' + ' and Order__r.Quote__r.BigMachines__Opportunity__r.StageName =' + 'Closed' +' and Order__r.Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c =' + 'Won' + ' and Order__r.Quote__r.BigMachines__Is_Primary__c =' + 'true' + 'and (Product__r.APN_Number__c like'+ '%pureins%' + ' OR Product__r.Name like'+ '%pureins%';
        dq1.Query_type__c = queryType1;
        dq1.is_active__c = true;
        dq1.Template_Name__c = 'Opportunity_Order_Quote_Report_Open';
        dq1.From_Email__c = 'appfoundry@genesys.com';
        dq1.Emails__c= 'anshul.jain@rsystems.com';
        insert dq1;
        
        EmailTemplate template = [SELECT id,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName = 'Opportunity_Order_Quote_Report_Open' LIMIT 1];
        
        List<String> emails = new List<String>();
        string acc = 'test@gmail.com';
        emails.add(acc);
        
        test.startTest();
        batchClassSendOPPReport batchNew = new batchClassSendOPPReport(dq1,emails);
        database.executebatch(batchNew);
        test.stopTest();

    }
    static testMethod void batchClassSendOPPReport_TestMethod2() { 
    
        Dynamic_Query__c dq1 = new Dynamic_Query__c();
        dq1.Process_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq1.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        string queryType1 = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c =' + 'Pure Cloud' + ' and Order__r.Quote__r.BigMachines__Opportunity__r.StageName =' + 'Closed' +' and Order__r.Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c =' + 'Won' + ' and Order__r.Quote__r.BigMachines__Is_Primary__c =' + 'true' + 'and (Product__r.APN_Number__c like'+ '%pureins%' + ' OR Product__r.Name like'+ '%pureins%';
        dq1.Query_type__c = queryType1;
        dq1.is_active__c = true;
        dq1.From_Email__c = 'appfoundry@genesys.com';
        dq1.Emails__c= 'anshul.jain@rsystems.com';
        dq1.Template_Name__c = 'Opportunity_Order_Quote_Report_Open';
        
        insert dq1;
        
        EmailTemplate template = [SELECT id,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName = 'Opportunity_Order_Quote_Report_Open' LIMIT 1];
        
        List<String> emails = new List<String>();
        string acc = 'test@gmail.com';
        emails.add(acc);
        
        test.startTest();
        batchClassSendOPPReport batchNew = new batchClassSendOPPReport(dq1,emails);
        database.executebatch(batchNew);
        test.stopTest();

    }
}