@isTest
public class ZuoraOrderUtilTest {

    @isTest
    static void TestSendToZBilling()
    {
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
        
        Test.startTest();
        
        ZuoraOrderUtil order = new ZuoraOrderUtil(context.ZQuote);
        order.SendToZBilling();
        
        Test.stopTest();
        
        List<PCOrder_Subscription_Logs__c> pcLogs = [SELECT Id, Log_Type__c FROM PCOrder_Subscription_Logs__c];
        System.assert(!pcLogs.isEmpty(), 'No PC Logs were created');
        for(PCOrder_Subscription_Logs__c log : pcLogs)
        {
            System.assertEquals('Success', log.Log_Type__c);
        }                
    }
    
    @isTest
    static void TestSendToZBillingExceptions() 
    {
        insert AccountFactory.CreateHoldingAccount();
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        // Create a test quote, but don't insert it
        // This should cause exceptions that are handled by the class
        zqu__Quote__c quote = zqu.ZQTestDataSetup.prepareNewSubscriptionQuote(false);
        
        Test.startTest();
        
        ZuoraOrderUtil order = new ZuoraOrderUtil(quote);
        order.SendToZBilling();
        
        Test.stopTest();
        
        List<PCOrder_Subscription_Logs__c> pcLogs = [SELECT Id, Log_Type__c FROM PCOrder_Subscription_Logs__c];
        System.assert(!pcLogs.isEmpty(), 'No PC Logs were created');
        for(PCOrder_Subscription_Logs__c log : pcLogs)
        {
            System.assertEquals('Error', log.Log_Type__c);
        }  
    }
}