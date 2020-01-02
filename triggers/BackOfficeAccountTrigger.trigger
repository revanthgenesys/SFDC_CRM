trigger BackOfficeAccountTrigger on Back_Office_Account__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    if ( Util.Bypass_Trigger_Chk )
           return;
           
    if ( trigger.isInsert && trigger.isBefore ) {
        BackOfficeAccountUtil.setBoaFields (trigger.new);               
    }  
}