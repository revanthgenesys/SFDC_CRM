/*
* Added By: Ashish Goyal (08/30/2018)
* Desc: Update Blackout Period field
*/
trigger ReferenceDataMain on Reference_Data__c (before insert, before update) {
    if (Util.Bypass_Trigger_Chk) return;
    
    if(Trigger.isUpdate) {
        FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
    }
    //Moved to helper class
    /*
    for(Reference_Data__c obj : trigger.new)
    {
        string strdigits;
        if(string.valueOf(obj.Data_Element_ID__c).length()<= 1)
            strdigits = '1000';
        else
            strdigits = '100';
            
        obj.Name = strdigits + obj.Data_Element_ID__c+'-'+ obj.Data_Element_ID_Description__c;
    }
    */
    
    FinanceMDMTriggerHelper.updateReferenceData(trigger.new, trigger.oldMap);
}