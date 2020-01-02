trigger OrderLineItem_After on Order_Line_Item__c (after insert, after update, after delete,after undelete) {
    if(Util.Bypass_Trigger_Chk && !Util.blnRunPPUTrigger)
        return;
    // if there are no maintenance Line on orders, update the decline maintenance
    if(trigger.isInsert){
        Set<Id> orderIds = new Set<Id>();
        for(Order_Line_Item__c oli : trigger.new){
            orderIds.add( oli.Order__c );
        }
        if(!orderIds.isEmpty() && TriggerFlowManager.ORDER_LINE_ITEM_DECLINE_MAINT){
            List<Order__c> orders = [Select Id, (Select Id, Product__r.Type__c from Order_Line_Items__r) from Order__c where Id In : orderIds];
            if(!orders.IsEmpty()){
                for(Order__c o : orders){
                    Boolean isDeclineMaintenance = true;
                    for( Order_Line_Item__c oli : o.Order_Line_Items__r){
                        if( oli.Product__r.Type__c == ServiceContractUtil.MAINTENANCE || oli.Product__r.Type__c == ServiceContractUtil.GENESYS_CARE)
                            isDeclineMaintenance = false;
                    }
                    o.Decline_Maintenance__c = isDeclineMaintenance;
                } 
                TriggerFlowManager.ORDER_LINE_ITEM_DECLINE_MAINT = false;
                update orders;
            }
        }
    }   
    //Non Revenue Order Handling
    if(trigger.isInsert && TriggerFlowManager.POPULATE_NRO_AND_EDUCATION_INFO_ON_ORDER){        
        NonRevenueOrderHandler.populateNROApprovalRequired(trigger.new);
        OrderFieldPopulationHelper.populateEducationFlagOnOrder(trigger.new);    
        TriggerFlowManager.POPULATE_NRO_AND_EDUCATION_INFO_ON_ORDER = false;
    }
    
    //PPU Order
    if(TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL && Trigger.isAfter && !Trigger.isUnDelete){
        if(trigger.isInsert || trigger.isUpdate)        
            PPUOrderHandler.updateTotalOnOrder(trigger.new, false); 
        else 
            PPUOrderHandler.updateTotalOnOrder(trigger.old, true);
        
        TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL = false;
    }
    
    
      
    //Naresh Kumar  12/15/2015  SML Data Update  
    if(TriggerFlowManager.ORDER_LINEITEM_SML_UPDATE && !System.isFuture() && !System.isBatch() && (trigger.isInsert || trigger.isUpdate)){
        TriggerFlowManager.ORDER_LINEITEM_SML_UPDATE = false;
        SMLHelperWTS.runSMLUpdateForOrder(trigger.new);     
    }

if(trigger.isUnDelete && trigger.isAfter)
     {   
        ID jobID2 = System.enqueueJob(new DeleteHistoryAsync(Trigger.newMap,'Restore'));
     }
 }