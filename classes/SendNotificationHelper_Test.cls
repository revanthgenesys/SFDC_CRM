@isTest
public class SendNotificationHelper_Test {
    
    static testMethod void SendNotificationHelper_TestMethod() { 
        
        List<Dynamic_Query__c> dynamicList = new List<Dynamic_Query__c>();
        
        Dynamic_Query__c dq1 = new Dynamic_Query__c();
        dq1.Process_Name__c = 'Default';
        dq1.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        string queryType1 = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c =' + 'Pure Cloud' + ' and Order__r.Quote__r.BigMachines__Opportunity__r.StageName =' + 'Closed' +' and Order__r.Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c =' + 'Won' + ' and Order__r.Quote__r.BigMachines__Is_Primary__c =' + 'true' + 'and (Product__r.APN_Number__c like'+ '%pureins%' + ' OR Product__r.Name like'+ '%pureins%';
        dq1.Query_type__c = queryType1;
        dq1.is_active__c = true;
        dq1.Template_Name__c = 'Opportunity_Order_Quote_Report_Open';
        dq1.From_Email__c = 'appfoundry@genesys.com';
        dq1.Emails__c= 'anshul.jain@rsystems.com';
        
        dynamicList.add(dq1);
        test.startTest();
        
        insert dynamicList;
        
        
        SendNotificationHelper.sendEmail(dynamicList);
        test.stopTest();

    }
    
}