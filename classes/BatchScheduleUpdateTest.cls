@isTest

public class BatchScheduleUpdateTest{
    public static testmethod void testSchedule(){
        Test.StartTest();
            BatchScheduleUpdate bsu = new BatchScheduleUpdate();
            String sch = '0 0 23 * * ?';
            system.schedule('Test Territory Check', sch, bsu);
        Test.StopTest();
    }
}