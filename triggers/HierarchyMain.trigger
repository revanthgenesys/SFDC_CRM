//Naresh Kumar  08/27/2018
trigger HierarchyMain on Hierarchy__c (before insert, before update) {
    if (Util.Bypass_Trigger_Chk) return;
    
    
    
   
    // Moved code to Helper class
     
    //Set Top Node ID
    /*List<Hierarchy__c> objHierarchy = [select id,Hierarchy_Description__c from Hierarchy__c where level__c = 1];
    Map<string,ID> objTopNodeID = new Map<string,ID>();
    for(Hierarchy__c obj : objHierarchy)
        objTopNodeID.put(obj.Hierarchy_Description__c,obj.id);
    
    //Check Unique Hierarchy
    if(trigger.new.size() == 1)
    {
        system.debug('##enter');
        Hierarchy__c  obj = trigger.new[0];
        Hierarchy__c objTopNodeID = [select id,Node_ID1__c from Hierarchy__c where id =: objTopNodeID.get(obj.Hierarchy_Description__c)];
        string strUniqueHierarchy = objTopNodeID.Node_ID1__c + obj.Node_ID1__c;
        
        system.debug('##UHier'+strUniqueHierarchy);
        List<Hierarchy__c> lstAllHierarchy = [select id from Hierarchy__c where Unique_Hierarchy_ID1__c =: strUniqueHierarchy  and ID != :obj.ID];

        system.debug('##size'+lstAllHierarchy.size());
        if(lstAllHierarchy != null && lstAllHierarchy.size()>0)
            trigger.new[0].addError('Duplicate Record Found!! Please check Top Node ID and Node ID, combination should be Unique.');
    }
    
    
    for(Hierarchy__c obj : trigger.new)
    {
        if(obj.Level__C != 1)
            obj.Top_Node_ID1__c = objTopNodeID.get(obj.Hierarchy_Description__c);
    }*/
    
    
    //Set SFDC Record Name
    for(Hierarchy__c obj : trigger.new) {
        obj.Name = obj.Node_ID1__C +'-'+ obj.Node_Description__c;
    }
    
    FinanceMDMTriggerHelper.updateHierarchy(trigger.new, trigger.oldMap);
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            FinanceMDMTriggerHelper.onBeforeInsertHI(trigger.new);
            FinanceMDMTriggerHelper.checkParentNode_beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
            FinanceMDMTriggerHelper.onBeforeUpdateHI(trigger.new, trigger.oldMap);
            FinanceMDMTriggerHelper.checkParentNode_beforeUpdate(Trigger.oldMap,Trigger.new);
        }
    }
}