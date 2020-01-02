@isTest
public class CalculateAverageConversionRatesSchdTest {
    @isTest
    public static void testschedule() {
        
        Test.StartTest();
        CalculateAverageConversionRatesSchd objCalculateAverageConversionRatesSchd = new CalculateAverageConversionRatesSchd();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, objCalculateAverageConversionRatesSchd);
        Test.stopTest();
        
    }
}