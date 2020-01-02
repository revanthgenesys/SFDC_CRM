global class GUComplianceEmailPartnersScheduler implements System.Schedulable {
    global void execute(SchedulableContext sc){
    	Database.executeBatch(new GUComplianceEmailPartnersBatch());
    }
}