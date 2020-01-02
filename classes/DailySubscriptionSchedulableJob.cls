global with sharing class DailySubscriptionSchedulableJob implements Schedulable {

    public void processSubscriptions() {
        BatchUserSubscriptions task = new BatchUserSubscriptions(true);
        database.executebatch(task,50);
    }


    global void execute(SchedulableContext schedulableContext) {
        processSubscriptions();
    }

}