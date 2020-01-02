trigger FailedOperationRecovery_After on Failed_Operation_Recovery__c (after insert) {

     if(Util.Bypass_Trigger_Chk)
        return;

    String objId = Trigger.new[0].Object_id__c;

    if ( objId == null) return;

    List<Order__c> ordrs = [SELECT Generate_Subscription_Record__c, (SELECT id FROM Subscriptions__r) FROM Order__c WHERE Id = :objId];

    //do not create CCDB if already exists
    if ( !ordrs.isEmpty() && ordrs[0].Subscriptions__r.size() == 0 ) {
        //check re-submissions counter
        List<Failed_Operation_Recovery__c> attempts = [SELECT Id FROM Failed_Operation_Recovery__c WHERE Object_Id__c = :objId];
        
        //check Max attempts allowed
        Decimal maxnum = Failed_Operation_Recovery_Settings__c.getInstance().Max_Retry_Attempts__c;
        Integer waitmin = Integer.valueOF(Failed_Operation_Recovery_Settings__c.getInstance().Wait_Minutes__c);

        if ( maxnum > attempts.size() )  {
          //run in RUN_IN_MINUTES min
            Datetime torun = Datetime.now().addMinutes(waitmin);
            String jobname = 'OrderAfterTrigExtension Resubmitted ' + objId + ' ' + 
                              Datetime.now().minute() + ':' + Datetime.now().second();
            String runtime = String.valueOf(torun.second()) + ' ' +
                             String.valueOf(torun.minute()) + ' ' + 
                             String.valueOf(torun.hour())   + ' * * ?';                

            system.schedule(jobname, runtime, new ResubmitOrderUpdateSchedulable(objId, jobname));
        }
        else {
            Failed_Operation_Recovery__c frec = new Failed_Operation_Recovery__c(id = Trigger.new[0].Id, Last_Retry_Failed__c = true);
            update frec;
        }

    }
}