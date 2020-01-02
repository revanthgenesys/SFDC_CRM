/***************************************************************************************************
* 
*  Trigger Name     :   SurveyResponseTrigger
*  Description      :   This trigger is used to update the record Type based
*  Auther           :   R Systems = > Mahesh Varde
* 
****************************************************************************************************/
 
trigger SurveyResponseTrigger on Survey_Response__c (after insert, after update, after Delete, before insert, before update, before delete, after undelete) {
        
     //By pass the triggers
    
     if(Util.Bypass_Trigger_Chk){
         return;
     }
     
      // By Pass the trigger thru Custom setting
     Bypass_Trigger__c   gsSetting  = Bypass_Trigger__c.getInstance('SurveyResponseTrigger');
     
     if(gsSetting != null && gsSetting.IsActive__c){
         return;
     }
    
    /**
     *  After Events methods 
     **/
     
    if(Trigger.IsAfter){
        
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
    
    /**
     *  Before Events methods 
     **/
     
    if(Trigger.IsBefore){
        
        if(Trigger.IsInsert){
            SurveyResponseTriggerHandler.beforeInsertUpdate(Trigger.New, Trigger.Oldmap);
        }
        
        if(Trigger.IsUpdate){
            SurveyResponseTriggerHandler.beforeInsertUpdate(Trigger.New, Trigger.Oldmap);
        }
        
        if(Trigger.IsDelete){
            // No Action
        }
        
        if(Trigger.IsUndelete){
            // No Action
        }
        
    }
}