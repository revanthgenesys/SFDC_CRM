global class BatchScheduleDeleteHistoryobject implements Schedulable{
    //public static string conexp= System.Label.AutoDeletehisobjSchedule; 
    global void execute(SchedulableContext sc){
        ID BatchId= Database.executeBatch(new DeletehistoryAsyncBatch(), 200);
    }    
   
}