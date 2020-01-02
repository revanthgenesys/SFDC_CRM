@isTest
private class UpdatePCQuoteTotalsTest {

    @isTest(seealldata=true)
    static void newSubscriptionTest() {
        /*zqu__QuoteRatePlanCharge__c objQtRtPlnChrge = [SELECT zqu__QuoteRatePlan__r.zqu__quote__c
                                                       FROM zqu__QuoteRatePlanCharge__c 
                                                       WHERE zqu__QuoteRatePlan__r.zqu__quote__r.zqu__SubscriptionType__c = 'New Subscription' LIMIT 1];
        UpdatePCQuoteTotals.updateZQuoteTotals(objQtRtPlnChrge.zqu__QuoteRatePlan__r.zqu__quote__c);
        */
        
        Id quoteId = Label.Quote_Id_For_Test_Class;
        UpdatePCQuoteTotals.updateZQuoteTotals(quoteId);
        Map<Id, Product2> map_toUpdateProds = new Map<Id, Product2>();
        List<zqu__QuoteRatePlanCharge__c> list_QtRtPlnChrges = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c
                                                                FROM zqu__QuoteRatePlanCharge__c 
                                                                WHERE zqu__QuoteRatePlan__r.zqu__quote__c = :quoteId];
        for(zqu__QuoteRatePlanCharge__c objQtRtPlnChrge : list_QtRtPlnChrges) {
            Product2 objProd = new Product2();
            objProd.Id = objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c;
            objProd.Product_Category__c = '';
            map_toUpdateProds.put(objProd.Id, objProd);
        }
        update map_toUpdateProds.values();
        
        Test.startTest();
            UpdatePCQuoteTotals.updateZQuoteTotals(quoteId);  
            UpdatePCQuoteTotals.updateZQuoteAmendTotalsFuture(quoteId);   
        Test.stopTest();   
        
    }
}