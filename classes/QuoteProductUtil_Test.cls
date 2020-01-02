/*
	04/30/2013	Naresh Kumar
	Test Class to test main class QuoteProductUtil	
*/
@isTest (seeAllData = true)
private class QuoteProductUtil_Test {

    static testMethod void myUnitTest() {
        QuoteProductUtil.getMonth(1);
        QuoteProductUtil.getMonth(2);
        QuoteProductUtil.getMonth(3);
        QuoteProductUtil.getMonth(4);
        QuoteProductUtil.getMonth(5);
        QuoteProductUtil.getMonth(6);
        QuoteProductUtil.getMonth(7);
        QuoteProductUtil.getMonth(8);
        QuoteProductUtil.getMonth(9);
        QuoteProductUtil.getMonth(10);
        QuoteProductUtil.getMonth(11);
        QuoteProductUtil.getMonth(12);
        QuoteProductUtil.getMonth(13);
        QuoteProductUtil.getFiscalQuarter(1);
        QuoteProductUtil.getFiscalQuarter(4);
        QuoteProductUtil.getFiscalQuarter(6);
        QuoteProductUtil.getFiscalQuarter(10);
        QuoteProductUtil.getFiscalQuarter(13);
    }
}