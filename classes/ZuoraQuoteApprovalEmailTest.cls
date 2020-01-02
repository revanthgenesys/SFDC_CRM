@isTest
public class ZuoraQuoteApprovalEmailTest {
    static zqu__Quote__c ZQuote;
    static TestZQuoteContext context;
    
    public static testMethod void TestLoadPage()
    {
        Test.startTest();
        
        date today = date.today();
        decimal licensesTotal;
        decimal servicesTotal;
        decimal hardwareTotal;
        integer licensesCount;
        integer hardwareCount;
        integer servicesCount;
        ZuoraQuoteApprovalEmailController ctl = new ZuoraQuoteApprovalEmailController();
        
        CreateTestData();
        context.SetupZQuote();
        
        Test.stopTest();
        
        ctl.quoteID = context.ZQuote.Id;
        licensesTotal = ctl.getlicensesTotal();
        servicesTotal = ctl.getServicesTotal();
        hardwareTotal = ctl.gethardwareTotal();
        licensesCount = ctl.getlicensesCount();
        servicesCount = ctl.getServicesCount();
        hardwareCount = ctl.getHardwareCount();
        ctl.getLicenses();
        ctl.getServices();
        ctl.getHardware();
        ctl.getUrlPrefix();
        System.debug('## servicesTotal: ' + servicesTotal);
        
        for(zqu__QuoteRatePlanCharge__c zcharge: [SELECT Id, Name,
            zqu__ProductName__c,
            zqu__Discount__c,
            zqu__ChargeType__c,
            Discounted_Amount__c,
            Product_Category__c,
            zqu__ListPrice__c,
            zqu__ListTotal__c,
            zqu__TCV__c FROM zqu__QuoteRatePlanCharge__c where id =: ctl.quoteID])
        {
            if(zcharge.Product_Category__c == 'Licenses')
            {
                if(zcharge.zqu__ListTotal__c != null)
                {
                    licensesTotal += zcharge.zqu__ListTotal__c;
                }
            }
        }
        
        System.Debug('LicensesTotal: ' + LicensesTotal);
    }
    
    static void CreateTestData()
    {
        if(context == null)
        {
            context = new TestZQuoteContext();
        }
    }
}