global class CalculateAverageConversionRatesSchd implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        CalculateAverageConversionRates cldAvgConvRates = new CalculateAverageConversionRates();             
        cldAvgConvRates.buildConversionRates(Date.today());
    }    
}