@isTest(seealldata = true)
public class DealQualificationHistoryControllerTest {

static testmethod void DealQualificationm1(){
Test.StartTest();
        Country__c cntry = [Select id,name,RU__c,Country__c,Old_Pricing_DAP_Region__c from Country__c where name = 'Brazil' limit 1];
        
        list<opportunity> optyList = TestDataFactory2.createOpportunity('GEN - Opportunity Record Type',1);
        for(opportunity op:optyList){
            //op.Country__c=cntry.Id;
            op.Country__r=cntry;
        }
        insert optyList;
    DealQualificationAppredHistoryController dqs = new DealQualificationAppredHistoryController();
    dqs.offeringType = 'test';
    dqs.platformType = 'test';
    dqs.pricingType = 'true';
    dqs.oppId = optyList[0].id;  
    dqs.dealscoredq = 'test';
    dqs.getDQApprovedHistory();

}

}