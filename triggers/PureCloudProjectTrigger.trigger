/************************************************************************************
Purpose : Trigger for PureCloud Project object to send notification and update service packages
Written By : Ranjith Punneli
Test Classes : PureCloudProjectTest
*************************************************************************************/

trigger PureCloudProjectTrigger on PureCloud_Trial__c (before insert, after insert, after update) {
    
    if(Util.Bypass_Trigger_Chk)
        return; 
        
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            PureCloudProjectHandler.BeforeInsert(Trigger.new);
            if(TriggerFlowManager.PURECLOUDPROJECT_TRIGGER_RUN) {
                PureCloudProjectTriggerHandler.updateServicePackage(Trigger.new);
                TriggerFlowManager.PURECLOUDPROJECT_TRIGGER_RUN = false;
            }
        }
    }
    
     if(Trigger.Isafter && (Trigger.Isupdate || Trigger.IsInsert)){
        PureCloudProjectTriggerHandler.afterInsertUpdate(Trigger.newMap, Trigger.Oldmap);

        //Mukunthan added below line for CCDB Req JIRA # CRMBILL-403 on 11-APR-2019
        PureCloudProjectTriggerHandler.associateActivationEmailAddress(trigger.new);
    }
}