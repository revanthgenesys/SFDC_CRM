@isTest
public class AddressMatchUpdateTest{
    public static testmethod void testSchedule(){
        Test.StartTest();
            AddressMatchUpdate bsu = new AddressMatchUpdate();
            String sch = '0 0 23 * * ?';
            system.schedule('Test Territory Check', sch, bsu);
        Test.StopTest();
    }
}