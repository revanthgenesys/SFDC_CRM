@isTest
public class ZQuoteDomainTest {
    
    Private final static String IndependentPartNumber = 'PS-170-PURE-SVEDE';
    Private final static String DependentPartNumber1 = 'TH-508-ACIP50PS';
    Private final static String DependentPartNumber2 = 'PS-000-PURE-ECSPEP_14d6843bb03';
    
    static Opportunity opp;
    static Order__c order;    
    
    public testMethod static void TestAutoAddNothing() 
    {
        string message;
        List<zqu__QuoteRatePlanCharge__c> beforeCharges;
        List<zqu__QuoteRatePlanCharge__c> afterCharges;
        
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
       
        Test.startTest();
                
        ZQuoteDomain zqDomain = ZQuoteDomain.getInstance(context.InternalPCOpp1.Id, context.ZQuote.Id); 
        zqDomain.AutoAddDependentCharges();
        
        test.stopTest();
    }
}