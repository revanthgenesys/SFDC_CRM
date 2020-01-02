/***************************************************************************************************
* 
*  Trigger Name     :   Consume Service Trigger
*  Description      :   This trigger is used to when Consume Service record is closed
*  Auther           :   R Systems
* 
****************************************************************************************************/
 
trigger ConsumeServiceTriggerMain on Consume_Service__c (after update) 
{
        
     //By pass the triggers thru User setting
     if(Util.Bypass_Trigger_Chk){
         return;
     }
     
    if(Trigger.IsAfter){
        
        if(Trigger.IsUpdate){
            // Call the Handler method on update of record
            System.debug('Consume Service Update is Called');
            ConsumeServiceTriggerHandler.afterStatusClosedUpdatePkgSrv(Trigger.NewMap, Trigger.OldMap  );
            ConsumeServiceTriggerHandler.updateServiceElementStatus(Trigger.OldMap, Trigger.NewMap );
            System.debug('Consume Service Update is Completed');
        }
        
}
}