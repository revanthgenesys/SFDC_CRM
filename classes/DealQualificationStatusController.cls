//Naresh Kumar	06/06/2017 
public without sharing class DealQualificationStatusController {    
    //DQ Status
    public String dqStatus {get; private set;}
    public DealQualificationStatusController(ApexPages.StandardController stdCtrl){
        Id quoteId = stdCtrl.getId();
        // Quote Object
        zqu__Quote__c objQuote = [SELECT zqu__Opportunity__c FROM zqu__Quote__c WHERE id =: quoteId];
        List <Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(objQuote.zqu__Opportunity__c, 'New Pricing', 'Cloud', 'PureCloud', DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        if (!dqs.isEmpty()) {
            dqStatus = dqs[0].Status__c;
        }
    }
}