public class ZuoraQuoteDetailReadOnlyController {
    
    private final zqu__Quote__c quote;
    public zqu.SelectProductComponentOptions customOptions { get; set; }
    
    public ZuoraQuoteDetailReadOnlyController(ApexPages.StandardController stdController)
    {
        this.quote = (zqu__Quote__c)stdController.getRecord();
        
        this.customOptions = new zqu.SelectProductComponentOptions();
        // Make component read only
        this.customOptions.mode = zqu.SelectProductComponentOptions.MODE_DETAIL;
        this.customOptions.quoteType = this.quote.zqu__SubscriptionType__c;
        this.customOptions.quoteId = this.quote.Id;
    }

}