trigger OrderStatusSendToERPTrigger on Order__c (after update) {
    
    if(Util.Bypass_Trigger_Chk) 
        return;   
    
    if(!Trigger.isUpdate) return;

    Set<Id> setOrderIds = new Set<Id>();
    for (Order__c objOrder : Trigger.newMap.values()) {
        setOrderIds.add(objOrder.Id);
    }

    List<Order__c> listOrdersToUpdate = new List<Order__c>();
    for (Order__c objOrder : Trigger.newMap.values()) {
        System.Debug('OrderStatusSendToERPTrigger:objOrder.Status__c ' + objOrder.Status__c +
                     ' objOrder.RecordTypeId ' + objOrder.RecordTypeId +
                     ' objOrder.Subsidaries__c ' + objOrder.Subsidaries__c + 
                     ' objOrder.Order_Category__c ' + objOrder.Order_Category__c);
        if (objOrder.Status__c == 'Approved' && 
            (objOrder.RecordTypeId == Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Cloud Monthly Billing Order').getRecordTypeId() ||
             (objOrder.Order_Category__c == 'PureEngage - Renewal' && objOrder.Subsidaries__c == 'a24U00000004XlJIAU'))
           )
        {
            System.Debug('OrderStatusSendToERPTrigger:Update Order ' + objOrder);
            Order__c objOrderToUpdate = new Order__c(Id = objOrder.Id, Status__c = 'Send to ERP');
            listOrdersToUpdate.add(objOrderToUpdate);
        }
    }
    update listOrdersToUpdate;

}