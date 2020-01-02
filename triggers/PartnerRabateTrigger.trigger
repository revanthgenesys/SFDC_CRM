trigger PartnerRabateTrigger on Partner_Rebate__c (before insert,before update,after Insert,after Update) {
    set<string> partnerNames = new set<string>();
    set<string> rebateYears = new set<string>();
    
    for(Partner_Rebate__c prebate: Trigger.New){
        rebateYears.add(prebate.Rebate_Year__c);
        partnerNames.add(prebate.Partner_Name__c);
    }
    
    if(Trigger.isBefore){
        PartnerRabateTriggerHandler.beforeTrigger(Trigger.New, Trigger.oldMap, rebateYears, partnerNames);
    }
    
    if(Trigger.isAfter){
        PartnerRabateTriggerHandler.afterTrigger(Trigger.New, Trigger.oldMap, partnerNames);    
    }
}