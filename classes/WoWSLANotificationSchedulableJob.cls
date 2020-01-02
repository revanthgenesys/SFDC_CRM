/*
Created By:    Swastika Rajkhowa
Function:      Schedule the Lead SLA notification every 24 hours whose WoW status is 'Open and Not assign'  
*/
 global class WoWSLANotificationSchedulableJob implements Schedulable {
  public void processEmail() {
    BatchWoWMailNotifiactionLeadSLA WoWBatch = new BatchWoWMailNotifiactionLeadSLA();    
    database.executebatch(WoWBatch,100);
  }

  global void execute(SchedulableContext schedulableContext) {
     processEmail();
  }

}