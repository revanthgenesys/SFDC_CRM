global class OpportunitySpotRateUpdate_Schedule implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        OpportunitySpotRateUpdate_Batch OSR = new OpportunitySpotRateUpdate_Batch();
        Database.executeBatch(OSR,200);
    }

}