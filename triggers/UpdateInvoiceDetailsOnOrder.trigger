trigger UpdateInvoiceDetailsOnOrder on Invoice__c (after insert,after update) 
{
    // Creating a set of all parent order ids
    Set<Id> set_OrderIds = new Set<Id>();
    for(Invoice__c objInvoice : Trigger.new)
    {
        if(objInvoice.Order__c != null)
        {
            if(Trigger.isUpdate && objInvoice.Status__c == Trigger.oldMap.get(objInvoice.Id).Status__c)
                continue;
            
            set_OrderIds.add(objInvoice.Order__c);                
        }
    }
    // Map of Parent Orders
    Map<Id,Order__c> map_Orders = new Map<Id,Order__c>([SELECT Id FROM Order__c WHERE RecordType.Name = 'Cloud Monthly Billing Order' AND
                                                       Id IN :set_OrderIds]);
    // Iterating parent orders which are monthly billing orders and populating Invoice lookup on them
    if(!map_Orders.isEmpty())
    {
        for(Invoice__c objInvoice : Trigger.new)
        {
            if(map_Orders.containsKey(objInvoice.Order__c))
            {
                if(Trigger.isInsert)
                    map_Orders.get(objInvoice.Order__c).Invoice__c = objInvoice.Id;
                else
                    map_Orders.get(objInvoice.Order__c).Invoice_Status__c = objInvoice.Status__c;
            }
        }
        Util.Bypass_Trigger_Chk = true;
        update map_Orders.values();
    }
}