@isTest
public class ZEstimatorTest {
    
    // BEGIN: TEST SETUP
    @testSetup
    static void SetupTestData()
    {
        insert new Account(name = 'Holding Account');
    }
    // END: TEST SETUP

    // BEGIN: UNIT TESTS
    @isTest 
    static void VerifyChargeDisplayForNewSubscription() 
    {       
        // Create product catalog        
        //Product2 product = zqu.ZQTestDataSetup.prepareProduct();
        
        /*TestZQuoteContext.createCatalog('TestProductZuoraId', 'TestRatePlanZuoraId', 'TestChargeZuoraId');
     
        Product2 product = [SELECT Id, Product_Category__c FROM Product2 LIMIT 1];
        product.Product_Category__c = 'Licenses';
        update product;
        
        // Create Quote
        zqu__Quote__c quote = zqu.ZQTestDataSetup.prepareNewSubscriptionQuote(true);        

        // Create quote charge groups
        Map<Id, zqu__ProductRatePlan__c> rateplanMap = new Map <Id, zqu__ProductRatePlan__c> ([select Id from zqu__ProductRatePlan__c where zqu__Product__c = :product.Id]);
        List<Id> ratePlanIds = new List<Id>(rateplanMap.keySet());
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);
        List<zqu.zChargeGroup> addedGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);*/
        
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();

        Test.startTest();
        PageReference pg = Page.ZEstimatorWizard;
        Test.setCurrentPage(pg);
        ApexPages.StandardController stc = new ApexPages.StandardController(context.ZQuote);
        ZUsageEstimatorController controller = new ZUsageEstimatorController(stc);

        System.assert(!controller.newCharges.isEmpty(), 'The controller did not see new charges');

        ApexPages.currentPage().getParameters().put('onetimeChargesHf', controller.onetimeChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('servicesChargesHf', controller.servicesChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('purecloudVoiceChargesHf', controller.purecloudVoiceChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('usageChargesHf', controller.usageChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('recurringHardwareHFName', controller.recurringHardwareChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('PurecloudVoicePartHFName', controller.purecloudVoicePartJson);

        // Test save
        pg = controller.save();

        System.assert(pg.getUrl().contains('/apex/zestimatorwizard?id=' + context.ZQuote.Id), 'Page reference returned from save is incorrect.  The page reference returned was: ' + pg.getUrl());

        pg = controller.ViewPdf();
        
        zUsageEstimatorPDFController pdfController = new zUsageEstimatorPDFController(stc);
        System.assert(pdfController.usageCtrl != null);

        String expectedUrl = '/apex/ZUsageEstimatorPdf?id=' + context.ZQuote.Id;
        System.assert(expectedUrl.equalsIgnoreCase(pg.getUrl()), 'The view PDF page reference is not correct.  Expected: ' + expectedUrl + ' Actual: ' + pg.getUrl());

        pg = controller.SavePdfAsAttachment();

        zqu__Quote__c quote = [SELECT Id, (SELECT Id FROM Attachments) FROM zqu__Quote__c where Id = :context.ZQuote.Id];
        System.assert(!quote.Attachments.isEmpty(), 'No attachments found on the quote.');
        
        Test.stopTest();
    }
    
    @isTest
    static void VerifyChargeDisplayForAmendment() 
    {   
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        zqu__Quote__c quoteAmend = zqu.ZQTestDataSetup.prepareAmendmentQuote(true);
        quoteAmend.zqu__StartDate__c = system.Today();
        quoteAmend.PureCloud_Ramp_Up_Period__c = 3;
        update quoteAmend;
        // This line will create the product catalog, so no need to create it prior.  THANKS ZUORA
        List<zqu.zChargeGroup> amendChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteAmend.Id);
        
        // Update product fields
        Product2 product = [SELECT Id, Product_Category__c FROM Product2 LIMIT 1];
        product.Product_Category__c = 'Licenses';
        update product;

        // Remove a charge from the amendment quote
        zqu.zQuoteUtil.deleteChargeGroup(amendChargeGroups.get(0));

        Test.startTest();
        PageReference pg = Page.ZEstimatorWizard;
        Test.setCurrentPage(pg);
        ApexPages.StandardController stc = new ApexPages.StandardController(quoteAmend);
        ZUsageEstimatorController controller = new ZUsageEstimatorController(stc);

        System.assert(!controller.removedCharges.isEmpty(), 'The controller did not see removed charges');
        System.assert(!controller.originalCharges.isEmpty(), 'The controller did not see original charges');

        ApexPages.currentPage().getParameters().put('onetimeChargesHf', controller.onetimeChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('servicesChargesHf', controller.servicesChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('purecloudVoiceChargesHf', controller.purecloudVoiceChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('usageChargesHf', controller.usageChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('recurringHardwareHFName', controller.recurringHardwareChargeItemsJSON);
        ApexPages.currentPage().getParameters().put('PurecloudVoicePartHFName', controller.purecloudVoicePartJson);

        // Test save
        pg = controller.SaveAndExit();

        System.assertEquals('/' + quoteAmend.Id, pg.getUrl(), 'Page reference returned from save is incorrect.  The page reference returned was: ' + pg);

        Test.stopTest();    
    }

}