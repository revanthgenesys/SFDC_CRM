trigger ServiceContract_After on ServiceContract (after insert, after update ) {
    if(Util.Bypass_Trigger_Chk)return;
   
    System.debug('NKC debug Trigger.new[0].Name '+Trigger.new[0].Name+' ');
   
   /*** moved to flow *** 
    BackOfficeAccountUtil.upsertBoaByServiceContracts(trigger.new);
   ***/
    
    if(trigger.isUpdate && TriggerFlowManager.SERVICECONTRACT_AFTER_UPDATE_TRIGGER){        

        TriggerFlowManager.SERVICECONTRACT_AFTER_UPDATE_TRIGGER = false;        
    }
    if(Trigger.isUpdate && TriggerFlowManager.SC_AFTER_ENTITLEMENT_UPDATION){
        ServiceContractUtil.updateEntitlements(trigger.oldMap, trigger.new);        
    }
    if(trigger.isInsert){
      
        QuoteFieldMappings.populateFieldsOnServiceContract(trigger.new, trigger.oldMap);
 
    }
   /*
    if(trigger.isUpdate && TriggerFlowManager.SERVICECONTRACT_AFTER_IMPORTANT_SCORE_UPDATE){
        ImportantScoreHandler.enableIsOutOfMaintainenceFlagOnCases(Trigger.new, Trigger.oldMap);
    }
   */
    if(trigger.isUpdate){
        PopulateSCAndLineItemsForInNegotiation.populateSCAndLineItems(Trigger.newMap, Trigger.oldMap);
        //ServiceContractUtil.populateDatesOnSCLineItems(Trigger.newMap, Trigger.oldMap);
    }
}