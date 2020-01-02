/*
* Added By: Ashish Goyal (08/30/2018)
* Desc: Update Blackout Period field
*/
trigger CurrencyMain on Currencies__c (before insert, before update) {
    if (Util.Bypass_Trigger_Chk) return;
    if(Trigger.isUpdate) {
        FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
    }
    FinanceMDMTriggerHelper.checkDuplicateCurrencyIdOrDescription(trigger.new);
    FinanceMDMTriggerHelper.populateBlackoutNRecordNameOnCurrency(trigger.new, trigger.oldMap);
    
    /*
    // Code moved to Helper class
    
    for(Currencies__c obj : trigger.new)
    {
        obj.Name = obj.Currency_Key__c+'-'+ obj.Description__c;
    }
    
    Map<Id, Currencies__c> oldMap = trigger.oldMap;
    Boolean blnBlackoutPeriod = CostCenterUtil.getBlackoutFlag();             
    for(Currencies__c eachCC : trigger.new){
        if(oldMap == null || (eachCC.Approval_Status__c == 'New' && oldMap.get(eachCC.id).Approval_Status__c != 'New')){
          eachCC.Blackout_Period__c = blnBlackoutPeriod;  
        }    
    }
    */
}