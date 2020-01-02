@isTest(SeeAllData=true)
private  class WinLossWeeklyTest {
    @isTest
    static void TestWinLossWeeklySchedular(){
        Test.startTest();
        WinLossWeeklySchedular sh1 = new WinLossWeeklySchedular();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Win Loss Report', sch, sh1); 
        Test.stopTest(); 
	}
    
    @isTest
    static void TestWinLossWeeklyController(){
        Test.startTest();
        WillLossWeeklyReportController objController = new WillLossWeeklyReportController();
        objController.getOpps();
        Test.stopTest(); 
	}
}