@isTest
public class ScheduleBatchReconcileRollupDataTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        ScheduleBatchReconcileRollupData objScheduleReconcile = new ScheduleBatchReconcileRollupData();
        String strSch = '0 0 23 * * ?';
        System.schedule('Test ScheduleBatchRateCloudUsageData', strSch, objScheduleReconcile);
        Test.stopTest();
    }
}