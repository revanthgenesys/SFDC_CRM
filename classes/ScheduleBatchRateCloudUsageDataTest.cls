@isTest
public class ScheduleBatchRateCloudUsageDataTest {

    @testSetup
    public static void setUpData() {
        List<SureTax_Settings__c> list_SureTaxSettings = SureTaxSettingsFactory.createDefaultSureTaxSettings();//BatchCreateCloudMonthlySalesOrdersTest.setupSureTaxSettings();
        insert list_SureTaxSettings;
    }
    
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        ScheduleBatchRateCloudUsageData objScheduleRating = new ScheduleBatchRateCloudUsageData();
        String strSch = '0 0 23 * * ?';
        System.schedule('Test ScheduleBatchRateCloudUsageData', strSch, objScheduleRating);
        Test.stopTest();
    } 
}