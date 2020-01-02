global with sharing class WeeklySubscriptionSchedulableJob implements Schedulable {

    
    public void processSubscriptions() {
        BatchUserSubscriptions task = new BatchUserSubscriptions(false);
        database.executebatch(task,50);
    }
    
    global void execute(SchedulableContext schedulableContext) {
        
        processSubscriptions();
    }

}