@isTest
public class TestZuoraMockData {

    public static String PRODUCT_CATEGORY_HARDWARE = 'Hardware';
    public static String PRODUCT_CATEGORY_SERVICES = 'Services';
    public static String PRODUCT_CATEGORY_LICENSES = 'Licenses';
    public static String PRODUCT_CATEGORY_VOICE = 'Voice Services';
    
    public static List<zqu.ZQuoteUtil.ZBillingResult> TestPreviewQuotes(List<Id> quoteIds) {
        
        List<zqu.ZQuoteUtil.ZBillingResult> results = new List<zqu.ZquoteUtil.ZBillingResult>();
        
        for(Id q : quoteIds)
        {
            decimal discount = 0.10;
            decimal subTotal = 1000.00;
            decimal tax = 0.07;
            decimal totalWithoutTax = subTotal - (subtotal * discount);
            decimal total = (subtotal - (subtotal * discount)) * (1 + tax);
            
            zqu.ZquoteUtil.ZBillingResult billingResult = new zqu.ZquoteUtil.ZBillingResult();

            billingResult.message = 'Mock Response';
            billingResult.sfdcQuoteId = q;
            billingResult.success = true;
            billingResult.totalMrr = 2500.00;
            billingResult.totalTcv = 2500.00;
            billingResult.zAccountId = 'SomeFakeString';
            billingResult.zSubscriptionId = 'SomeFakeString2';
            
            billingResult.totalInfo = new zqu.ZQuoteUtil.TotalInfo();
            billingResult.totalInfo.discount = discount;
            billingResult.totalInfo.subTotal = subTotal;
            billingResult.totalInfo.tax = tax;
            billingResult.totalInfo.total = total;
            billingResult.totalInfo.totalWithoutTax = totalWithoutTax;

            billingResult.chargeMetrics = new List<zqu.ZQuoteUtil.ChargeMetrics>();
            //billingResult.chargeMetrics.chargeNumber = '';
            //billingResult.chargeMetrics.deltaMrr = 0.0;
            //billingResult.chargeMetrics.deltaTcv = 0.0;
            //billingResult.chargeMetrics.mrr = 0.0;
            //billingResult.chargeMetrics.sfdcQuoteRatePlanChargeId = '';
            //billingResult.chargeMetrics.tcv = 0.0;
            //billingResult.chargeMetrics.productRatePlanId = '';
            //billingResult.chargeMetrics.productRatePlanChargeId = '';
            //billingResult.chargeMetrics.originalRatePlanId = '';
            //billingResult.chargeMetrics.originalId = '';

            results.add(billingResult);
        }

        return results;      
    }



    public static Integer GetRandomIndex(Integer listSize)
    {
        return Math.mod(Math.abs(Crypto.getRandomInteger()), listSize);
    }
}