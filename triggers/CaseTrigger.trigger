/***************************************************************************************************
* 
*  Trigger Name     :   CaseTrigger
*  Description      :   This trigger is used to on Case Triger
*  Auther           :   R Systems
* 
****************************************************************************************************/
 
trigger CaseTrigger on Case (after insert, after update, after Delete, before insert, before update, before delete, after undelete) {
        
     //By pass the triggers thru User setting
    
     if(Util.Bypass_Trigger_Chk){
         return;
     }
     
     // By Pass the trigger thru Custom setting
     Bypass_Trigger__c   gsSetting  = Bypass_Trigger__c.getInstance('CaseTrigger');
     
     if(gsSetting != null && gsSetting.IsActive__c){
         return;
     }
    /**
     *  After Events methods 
     **/
     
    if(Trigger.IsAfter){
        
        if(Trigger.IsInsert){
            // Call the Handler method on insert of record
        }
        
        if(Trigger.IsUpdate){
            // Call the Handler method on update of record
            /*if(CaseTriggerHandler.stopRecursion)
                CaseTriggerHandler.afterUpdate(Trigger.NewMap, Trigger.OldMap);*/
            System.debug('Case Update is Called');
            CaseTriggerHandler.afterCaseUpdateupdatePkgSrv(Trigger.NewMap, Trigger.OldMap);
            System.debug('Case Update is Completed');
        }
        
        if(Trigger.IsDelete){
            // No Action
        }
        
        if(Trigger.IsUndelete){
            // No Action
        }
        
    }
    
    /**
     *  Before Events methods 
     **/
     
    if(Trigger.IsBefore){
        
        if(Trigger.IsInsert){
            // No Action
        }
        
        if(Trigger.IsUpdate){
            // No Action
        }
        
        if(Trigger.IsDelete){
            // No Action
        }
        
        if(Trigger.IsUndelete){
            // No Action
        }
        
    }
}