@isTest
public class OpportunitySpotRateUpdate_Schedule_Test {
    
    static  testMethod  void testOpportunitySpotRateUpdate(){
        Test.startTest();
        Util.Bypass_Trigger_Chk = true;
        ERP_Currency_Daily_Exchange_Rate__c testRate = new ERP_Currency_Daily_Exchange_Rate__c();
        testRate.Effective_Date__c = System.today().addDays(-1);
        testRate.FROM_CURRENCY_CODE__c = 'CAD';
        testRate.TO_CURRENCY_CODE__c = 'USD';
        testRate.EXCHANGE_RATE_TYPE__c='FORECAST';
        Util.Bypass_Trigger_Chk = true; 
        insert testRate;
        //Util.Bypass_Trigger_Chk = true;
        
        Account testAccount = TestUtil.createAccounts(1, true)[0];  
        Id cloudRenewalRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        Opportunity testOpportunity = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpportunity.recordtypeId = cloudRenewalRecTypeId;
        testOpportunity.CloseDate = System.today()-20;
        testOpportunity.Spot_Rate__c=null;
        testOpportunity.Has_PS__c=false;
        testOpportunity.Cloud_Renewal__c=false;
        testOpportunity.amount=1000.00;
        testOpportunity.Cloud_Renewal__c=false; 
        testOpportunity.Win_Loss_Status__c = 'Won';
        testOpportunity.currencyIsocode ='CAD';
        insert testOpportunity;
        system.debug('testOpportunity*****'+testOpportunity);
        
            OpportunitySpotRateUpdate_Schedule OSR = new OpportunitySpotRateUpdate_Schedule();
            SchedulableContext sc = null;
            OSR.execute(sc);
        //OpportunitySpotRateUpdate_Batch PSRB = new OpportunitySpotRateUpdate_Batch();
        //database.executebatch(PSRB);
        Test.stopTest();
        
    }
    
}