public with sharing class ZUsageEstimatorPDFController {
    
    private final zqu__Quote__c quote;

    public ZUsageEstimatorController usageCtrl
    {
        get
        {
            if(usageCtrl == null)
            {
                ApexPages.StandardController stc = new ApexPages.StandardController(this.quote);
                usageCtrl = new ZUsageEstimatorController(stc);
            }
            return usageCtrl;
        }
        private set;
    }

    public zUsageEstimatorPDFController(ApexPages.StandardController stdController)
    {
        this.quote = (zqu__Quote__c)stdController.getRecord();
    }
}