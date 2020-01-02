@istest
class BatchScheduleDeleteHistoryobjectTest{
    public static testMethod void testschedule() {
        Test.StartTest();
        BatchScheduleDeleteHistoryobject testsche = new BatchScheduleDeleteHistoryobject();
        String sch = System.Label.AutoDeletehisobjSchedule;
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}