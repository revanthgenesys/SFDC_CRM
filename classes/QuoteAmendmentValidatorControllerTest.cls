@IsTest
public class QuoteAmendmentValidatorControllerTest
{
    static final String AMENDMENT_QUOTE = 'Amend Subscription';

    @testSetup static void testSetup()
    {
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        //insert AxLegalEntityFactory.CreateDefaultEntity();
        insert PureCloudMonthlyMinimumFactory.createPureCloudMonthlyMinimums();

        Account acct = new Account(Name = String.valueOf(Crypto.getRandomLong()));
        Account holdingAcct = new Account(Name = 'Holding Account');
        insert new List<Account>{ acct, holdingAcct };

        Opportunity oppty = new Opportunity(Name = String.valueOf(Crypto.getRandomLong()));
        oppty.AccountId = acct.Id;
        oppty.StageName = 'Proposed';
        oppty.CloseDate = DateTime.now().date();
        insert oppty;
    }

    public static Opportunity getOpp()
    {
        return [SELECT Id FROM Opportunity LIMIT 1];
    }

    @isTest
    private static void testValidation() 
    {
        Opportunity oppty = getOpp();
		Account acct = [SELECT Id, CurrencyIsoCode FROM Account WHERE Name != 'Holding Account' LIMIT 1];
        zqu__Quote__c quote = new zqu__Quote__c(Name = 'Quote1', zqu__Opportunity__c = oppty.Id, zqu__Account__c = acct.Id);
        quote.zqu__ExistSubscriptionId__c = '8a8ae4ac3966b02501396c250f3a0376';
        quote.zqu__SubscriptionType__c = AMENDMENT_QUOTE;
        quote.zqu__Currency__c = acct.CurrencyIsoCode;
        insert quote;

        ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
        QuoteAmendmentValidatorController QuoteAmendmentValidatorController = new QuoteAmendmentValidatorController(stdController);
        QuoteAmendmentValidatorController.onload();
        System.assert(QuoteAmendmentValidatorController.isZuoraSubscriptionRenewed, 'Expecting Zuora Subscription to be renewed');
        QuoteAmendmentValidatorController.updateQuoteSubscriptionVersion();

        PageReference pageRef = QuoteAmendmentValidatorController.cancel();

        quote = new zqu__Quote__c(Name = 'Quote2', zqu__Opportunity__c = oppty.Id, zqu__Account__c = acct.Id);
        quote.zqu__ExistSubscriptionId__c = '8a8ae4ac3966b02501396c250f3a0376';
        quote.zqu__SubscriptionType__c = 'New Subscription Quote';
        quote.zqu__Currency__c = acct.CurrencyIsoCode;
        insert quote;

        stdController = new ApexPages.StandardController(quote);
        QuoteAmendmentValidatorController = new QuoteAmendmentValidatorController(stdController);
        QuoteAmendmentValidatorController.onload();
        System.assert(!QuoteAmendmentValidatorController.isZuoraSubscriptionRenewed);

        stdController = new ApexPages.StandardController(new zqu__Quote__c());
        QuoteAmendmentValidatorController = new QuoteAmendmentValidatorController(stdController);
        System.assert(ApexPages.getMessages().size() > 0);
        System.assert(!QuoteAmendmentValidatorController.isZuoraSubscriptionRenewed);
    }

    @isTest
    private static void testValidationError()
    {
        Opportunity oppty = getOpp();
		Account acct = [SELECT Id, CurrencyIsoCode FROM Account WHERE Name != 'Holding Account' LIMIT 1];
        zqu__Quote__c quote = new zqu__Quote__c(Name = 'Amend', zqu__Opportunity__c = oppty.Id, zqu__Account__c = acct.Id);
        quote.zqu__ExistSubscriptionId__c = '8a8ae4ac3966b02501396c250f3a0376';
        quote.zqu__SubscriptionType__c = AMENDMENT_QUOTE;
        quote.zqu__Currency__c = acct.CurrencyIsoCode;
        insert quote;

        ApexPages.StandardController stdController = new ApexPages.StandardController(quote);
        QuoteAmendmentValidatorController QuoteAmendmentValidatorController = new QuoteAmendmentValidatorController(stdController);
        QuoteAmendmentValidatorController.onload();
        
        System.assert(ApexPages.getMessages().size() > 0);
        System.assert(!QuoteAmendmentValidatorController.isZuoraSubscriptionRenewed);
    }

    public static List<ZObject> createMockSubscription() 
    {
        List <ZObject> zobjs = new List<ZObject>();
        zObject zobj = new ZObject(null, 'S-000001', 'Expired', 1, null, null);
        zobjs.add(zobj);
        return zobjs;
    }

    public static List<ZObject> createMockSubscriptions() 
    {
        List <ZObject> zobjs = new List<ZObject> ();
        ZObject mockZobj = new ZObject('8a8ae4ac3966b02501396c250f3a0371', 'S-000001', null, 2, DateTime.now(), null);
        zobjs.add(mockZobj);
        mockZobj = new ZObject('8a8ae4ac3966b02501396c250f3a0372', 'S-000001', null, 1, DateTime.now(), null);
        zobjs.add(mockZobj);
        return zobjs;
    }

    public static List<ZObject> createMockAmendments(String quoteName) 
    {
        List <ZObject> zobjs = new List<ZObject> ();
        ZObject mockZobj = new ZObject('8a8ae4ac3966b02501396c250f3a0373', null, null, null, null, quoteName == 'Amend' ? quoteName : 'Renewal');
        zobjs.add(mockZobj);
        return zobjs;
    }
}