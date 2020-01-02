/***************************************************************************************************
* 
*  Trigger Name     :   OrderTrigger
*  Description      :   This trigger is used to create Source Account when order status = Order Submitted
*  Auther           :   R Systems (Mahesh)
* 
****************************************************************************************************/

trigger OrderTrigger on Order__c (after insert, after update) {
    if(Util.Bypass_Trigger_Chk) 
        return;   
       
    if(trigger.isInsert || trigger.isUpdate){
        OrderTriggerHandler.afterInsertUpdate(trigger.newmap, trigger.Oldmap);
    }
    
    if(trigger.isInsert || trigger.isUpdate){
        OrderTriggerHelper.InsertPureSuccessPackage(trigger.newmap, trigger.Oldmap);
    }
}