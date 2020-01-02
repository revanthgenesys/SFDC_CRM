global class Schedular_userSubscriptionAlerts implements Schedulable{
    global void execute (SchedulableContext SC){
        BatchUserSubscriptions USA = new  BatchUserSubscriptions(true);
        database.executeBatch(USA,100);
        
    }
}