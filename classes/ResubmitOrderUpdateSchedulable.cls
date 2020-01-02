global class ResubmitOrderUpdateSchedulable implements Schedulable {

    public String objId;
    public String jobname;

    public ResubmitOrderUpdateSchedulable(String objId, String jobname) {
        this.objId = objId;
        this.jobname = jobname;
    }
    global void execute(SchedulableContext ctx) {
        // re-activate the order trigger 
        Order__c or1 = new Order__c (id = objId, Generate_Subscription_Record__c = false);
        update or1;

        Order__c or2 = new Order__c (id = objId, Generate_Subscription_Record__c = true);
        update or2;

        abortJob();
    }

    public void abortJob() {
        /// abort when finished
        List<CronTrigger> ct = [SELECT Id FROM CronTrigger WHERE CronjobDetail.Name = :jobname];

        if ( !ct.isEmpty() ) 
          system.abortJob(ct[0].id);
    }
}