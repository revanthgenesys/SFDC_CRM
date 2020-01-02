@isTest
private class PureCloudProjectHandlerTest {

    private static testMethod void pureCloudProjectTest() {
        
        List<Account> acnt = TestUtil.createAccounts(1, true);
        
        List<Opportunity> opps = TestUtil.createOpportunities(1, acnt[0].Id, true);
        
        Zuora_Custom_Settings__c zuora = new Zuora_Custom_Settings__c();
        zuora.Description__c = 'Test';
        zuora.Value__c= '1';
        zuora.Name= 'ZuoraInitialTerm';
        insert zuora;
        
        Zuora_Custom_Settings__c zuora1 = new Zuora_Custom_Settings__c();
        zuora1.Description__c = 'Test';
        zuora1.Value__c= '1';
        zuora1.Name= 'ZuoraRenewalTerm';
        insert zuora1;
        
        
        zqu__Quote__c q = new zqu__Quote__c();
        q.zqu__Account__c= acnt[0].Id;
        q.zqu__Opportunity__c = opps[0].Id;
        q.PureCloud_Ramp_Up_Period__c = 2;
        q.zqu__StartDate__c = Date.today();
        insert q;
        
        zqu__QuoteAmendment__c amend = new zqu__QuoteAmendment__c();
        amend.zqu__Quote__c = q.Id;
        insert amend;
        
        zqu__QuoteRatePlan__c quoteplan = new zqu__QuoteRatePlan__c();
        quoteplan.zqu__Quote__c = q.Id;
        quoteplan.zqu__QuoteAmendment__c = amend.Id;
        insert quoteplan;
        
        zqu__QuoteRatePlanCharge__c  quoterateplancharge = new zqu__QuoteRatePlanCharge__c();
        quoterateplancharge.zqu__QuoteRatePlan__c = quoteplan.Id;
        quoterateplancharge.zqu__ProductRatePlanChargeZuoraId__c = 'Ttest';
        insert quoterateplancharge;
        
        PureCloud_Trial__c purecloud = new PureCloud_Trial__c();
        purecloud.Account__c = acnt[0].Id;
        purecloud.Opportunity__c = opps[0].Id;
        purecloud.Quote__C= q.id;
        insert purecloud;
        
    }

}