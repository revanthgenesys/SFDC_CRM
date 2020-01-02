@isTest(SeeAllData = true)
public class OpportunityReportScheduler_Test{

    static testmethod void test1(){

        Test.StartTest();
        
        List<Dynamic_Query__c> dynamicQueryList = new List<Dynamic_Query__c>();
             
        Dynamic_Query__c dq = new Dynamic_Query__c();
        dq.Process_Name__c = 'Default';
        dq.Query_type__c = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c';
        dq.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq.Query_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq.Template_Name__c =  'Opportunity_Order_Quote_Report';
        dynamicQueryList.add(dq);
        
        
        Dynamic_Query__c dq2 = new Dynamic_Query__c();
        dq2.Process_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq2.Query_type__c = 'where Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c';
        dq2.Report_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq2.Query_Name__c = 'eMite_Closed Won_FY2018_MW';
        dq2.Template_Name__c =  'Opportunity_Order_Quote_Report';
        dynamicQueryList.add(dq2);
         
        insert dynamicQueryList;
         
       
        OpportunityReportScheduler oppReportScheduler = new OpportunityReportScheduler();
           
        oppReportScheduler.sendEmail();  
         
         
        Test.StopTest();
         

    }
    






}