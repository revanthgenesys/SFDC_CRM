//01/21/2014	Naresh Kumar
global with sharing class PartnerAppAutoCancellationBatchSchedular implements Schedulable {
	public static String scheduleString = '0 00 00 * * ?';  //Every Day at Midnight 

    global static String scheduleMe() {
        PartnerAppAutoCancellationBatchSchedular SC = new PartnerAppAutoCancellationBatchSchedular(); 
        return System.schedule('Partner App Auto Cancellation', scheduleString, SC);
    }
    global void execute(SchedulableContext sc) {
        PartnerApplicationAutoCancellationBatch apexJob = new PartnerApplicationAutoCancellationBatch();
        ID batchprocessid = Database.executeBatch(apexJob, 200);           
    }
}