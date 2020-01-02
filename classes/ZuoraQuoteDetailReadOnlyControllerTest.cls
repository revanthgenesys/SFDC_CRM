@isTest
public class ZuoraQuoteDetailReadOnlyControllerTest {

    @isTest
    static void TestController()
    {
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
        
        Test.startTest();
        ApexPages.StandardController stc = new ApexPages.StandardController(context.ZQuote);
        ZuoraQuoteDetailReadOnlyController controller = new ZuoraQuoteDetailReadOnlyController(stc);
        
        zqu.SelectProductComponentOptions customOptions = controller.customOptions;
        
        System.assertEquals(zqu.SelectProductComponentOptions.MODE_DETAIL, customOptions.mode);
        
        Test.stopTest();
    }
}