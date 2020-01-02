@isTest
private class ZQuoteRatePlanChargeManagementTest {
	
	public testMethod static void TestUpdateQtyToCheckIncludedUnits() 
	{
        zqu__Quote__c zQuote;
        zqu__QuoteRatePlanCharge__c dummyCharge = null;
        zqu__QuoteRatePlanCharge__c licenseCharge = new zqu__QuoteRatePlanCharge__c();
        zqu__QuoteRatePlanCharge__c overageCharge = new zqu__QuoteRatePlanCharge__c();
        
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
        
        Test.startTest();
        
        zQuote = context.ZQuote;
        
        // Provide both charges in the update as it seems Zuora always updates all charges under one rate plan
        overageCharge = [SELECT Id, Name, zqu__IncludedUnits__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :zQuote.Id AND zqu__Model__c = 'Overage Pricing' LIMIT 1];
        licenseCharge = context.ZQuoteLicenseCharge;
        licenseCharge.zqu__Quantity__c = 125;
        update new List<zqu__QuoteRatePlanCharge__c>{licenseCharge, overageCharge};
        
        Test.stopTest();
        
        overageCharge = [SELECT Id, Name, zqu__IncludedUnits__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :zQuote.Id AND zqu__Model__c = 'Overage Pricing' LIMIT 1];
        
        System.assertEquals(licenseCharge.zqu__Quantity__c, overageCharge.zqu__IncludedUnits__c, 'Included Charges updated using License count');
    }
	
}