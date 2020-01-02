trigger OrderLineItem_Before on Order_Line_Item__c (before insert,before update, before delete) 
{
    if(Util.Bypass_Trigger_Chk)
        return;
// adding from line 7 to line 14 - for the incident INC0441400 by Suresh Rayi on 05/12/2019
    if(trigger.isBefore && trigger.IsDelete){ 
        for (Order_Line_Item__c oli : Trigger.old){      
            system.debug('loggedin user profile: '+UserInfo.getProfileId());
            If(UserInfo.getProfileId() != System.Label.SystemAdministratorProfileID){
                oli.addError('You cannot delete Order Line Items after adding them, If you don\'t want the Order Line Item, please modify the quantity to Zero(0).');
            }
        }
    }
    // ECD old logic needs to not run for delete
    if (!Trigger.isDelete) {  
    
        //Anju June 2018 Revpro changes
        if(trigger.isInsert)
            OrderCloudUtil.populateRevproFields(trigger.new);
              
        List<Order_Line_Item__c> list_OLIToUpdate = new List<Order_Line_Item__c>();
        for(Order_Line_Item__c objOLI : Trigger.new)
        {
            if(objOLI.Product__c != null && ((Trigger.isInsert && (objOLI.APN_Number__c == null || objOLI.Unit_of_Measure__c == null)) ||
                                            (Trigger.IsUpdate && objOLI.Product__c != Trigger.OldMap.get(objOLI.Id).Product__c)))
                list_OLIToUpdate.add(objOLI);
        }
        if(!list_OLIToUpdate.isEmpty() && TriggerFlowManager.ORDER_LINE_INFO_UPDATE)
            OrderUtil.populateInfoOnOrderLines(list_OLIToUpdate);
        
        // code to fire on insert only
        if(trigger.isInsert && TriggerFlowManager.POPULATE_ORDER_INFO)
        { 
            // copy date fields from order
            Map<Id, Order__c> ordersMap = OrderUtil.populateOrderDates( trigger.new );
            
            // field mapping from QuoteLine 
            if(ordersMap!= null && !ordersMap.isEmpty()){
                OrderUtil.populateQuoteLineFields( ordersMap, trigger.new );
            }
            
            //Validate Products to exclude SalesPriceBook
            OrderUtil.validateLineItemProducts(trigger.new);
            TriggerFlowManager.POPULATE_ORDER_INFO = false;
        }
        
        
    }

    if (Trigger.isDelete) {
        // Collect Order ID's
        Set<Id> setOrderIds = new Set<Id>();
        for (Order_Line_Item__c oli : Trigger.old) {
            setOrderIds.add(oli.Order__c);
        }
        List<Order__c> listOrders = [select Id, RecordTypeId, Status__c from Order__c where Id in :setOrderIds];
        Map<Id, Order__c> mapOrders = new Map<Id, Order__c>();
        for (Order__c o : listOrders) {
            mapOrders.put(o.Id, o);
        }
        for (Order_Line_Item__c oli : Trigger.old) {
            Order__c o = mapOrders.get(oli.Order__c);
            if (!OrderTrigger_Utils_Class.cloudMonthlyOrderAllowDelete(o)) {
                oli.addError('Cannot Delete Order Line Item from Cloud Monthly Billing Order in Status ' + o.Status__c);
            }
        }
    }
    //Inserted for Hard delete
     if(trigger.isDelete && trigger.isBefore)
     {   
        ID jobID = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'delete'));
     }
}