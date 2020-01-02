global class OpportunityDailyRateUpdate_Schedule implements Schedulable{
    
    global void execute(SchedulableContext ctx) {
        OpportunityDailyRateUpdate_Batch ODR = new OpportunityDailyRateUpdate_Batch();
        Database.executeBatch(ODR,200);
    }

}