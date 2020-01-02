/***************************************************************************************************
* 
*  Trigger Name     :   GSRelationshipTrigger
*  Description      :   This trigger is used to insert the Source Account on Insert and Update of GS 
*                       Relationship
*  Auther           :   R Systems
* 
****************************************************************************************************/
 
trigger GSRelationshipTrigger on JBCXM__GSRelationship__c (after insert, after update, after Delete, before insert, before update, before delete, after undelete) {
        
     //By pass the triggers thru User setting
    
     if(Util.Bypass_Trigger_Chk){
         return;
     }
     
     // By Pass the trigger thru Custom setting
     Bypass_Trigger__c   gsSetting  = Bypass_Trigger__c.getInstance('GSRelationshipTrigger');
     
     if(gsSetting != null && gsSetting.IsActive__c){
         return;
     }
    /**
     *  After Events methods 
     **/
     
    if(Trigger.IsAfter){
        
        if(Trigger.IsInsert){
            // Call the Handler method on insert of record
            if(GSRelationshipTriggerHandler.stopRecursion){
                GSRelationshipTriggerHandler.afterInsert(Trigger.NewMap,  Trigger.OldMap);
            }
            //Priyank added below line on 19 Nov 2018 as discussed with JJ to update the ARF record and populate GsObject id in Gs Relationship field.
            GSRelationshipTriggerHandler.afterInsertArfUpdate(Trigger.new);
        }
        
        if(Trigger.IsUpdate){
            // Call the Handler method on update of record
            if(GSRelationshipTriggerHandler.stopRecursion){
                GSRelationshipTriggerHandler.afterInsertUpdate(Trigger.NewMap, Trigger.OldMap);
            }
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