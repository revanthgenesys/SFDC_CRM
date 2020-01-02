/*
Created By:    Swastika Rajkhowa
Function:      Schedule the Lead SLA notification every 24 hours whose POC status is 'Open and Not assign'  
*/
 global class POCSLANotificationSchedulableJob implements Schedulable {
  public void processEmail() {
    BatchPOCMailNotifiactionLeadSLA POCBatch = new BatchPOCMailNotifiactionLeadSLA();    
    database.executebatch(POCBatch,100);
  }

  global void execute(SchedulableContext schedulableContext) {
     processEmail();
  }

}