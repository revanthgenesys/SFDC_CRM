/*
Raghu R : 2/3/2014 : MDM Project : Trigger Which flags Account as Primary as per below  scenarios.

Business Process
Order Addresses: (Copy order addresses to account addresses when status changed to approved)

Direct Order: (sold to &  end user account both are same)

Step 1:
If all four order addresses are same then create only one sold to address on End User account (set sold to address as primary)
[AA] If the Account record was created a Customer directly and therefore already had a Sold To address, will this copy-from-order look to match against the existing Address records?
[AS] Yes before inserting address from order addresses we will do comparison check

Step 2:
If end user and ship to are same then only end user address requires to copy as address on End User account(lookup on order). (set end user address as primary)
If end user and ship to are different then copy end user & ship To address requires to copy as address on End User account(lookup on order). (set end user address as primary)

Step 3:
If bill to and sold to are same then only sold to requires to copy as address on Sold Account(lookup on order). (set sold to address as primary)
If bill to and sold to are different then only sold to & Bill To requires to copy as address on Sold Account(lookup on order). (set sold to address as primary)

InDirect Order(When sold and end user are different):

If end user and ship to are same then only end user address requires to copy as address on End User account(lookup on order).
If end user and ship to are different then copy end user & ship To address requires to copy as address on End User account(lookup on order).

If bill to and sold to are same then only sold to requires to copy as address on Sold Account(lookup on order).
If bill to and sold to are different then only sold to & Bill To requires to copy as address on Sold Account(lookup on order).
*/

trigger Order_Trigger on Order__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

if(Util.Bypass_Trigger_Chk)return;

//Seperating out Subscription Orders for Contract Creation
if(Trigger.isUpdate&&Trigger.isBefore){
    //List of Order to Create Contracts
    list<order__c> list_OrdersforContracts =  new list<order__c>(); 
    
    for(order__C objOrder:Trigger.new)
    {
       if(!objOrder.Synced_with_Contract__c 
       && objOrder.status__c == 'Completed' 
       && !objOrder.No_Cloud_Billing_Contract__c 
       && objOrder.Offering_Type__c != null 
       && objOrder.Offering_Type__c.contains('Subscription')) 
           list_OrdersforContracts.add(objOrder);    
    }
    
    if(list_OrdersforContracts.size()>0)
        CloudBillingUtil.createBillingContract(list_OrdersforContracts); 
    
      
}

/* Forbid both Edit and Delete allowing Edit for Admin and ETL
// Update is allowed for System Admins and Integeration User(Checking for Sys Admin, MDM Administrator Profile Id)
if ((Trigger.isDelete || Trigger.isUpdate) && Trigger.isBefore && 
    !(Trigger.isUpdate && (UserInfo.getProfileId() == '00eU0000000pPrr' || UserInfo.getProfileId() == '00eU0000000drKd'))) 
{
    // profile logic
    List<Order__c> list_Orders = Trigger.isDelete ? Trigger.old : Trigger.new;
    for (Order__c objOrder : list_Orders) 
    {
        if (!OrderTrigger_Utils_Class.cloudMonthlyOrderAllowEditDelete(objOrder))
            objOrder.addError('Cannot Edit/Delete Cloud Monthly Billing Order in Status ' + objOrder.Status__c);
    }
}
*/

//Cloud Monthly Billing Order logic
if ((Trigger.isDelete) && Trigger.isBefore) {
    System.debug('Checking if delete');
    for (Order__c oldOrder : Trigger.old) {
        if (!OrderTrigger_Utils_Class.cloudMonthlyOrderAllowDelete(oldOrder)) {
            oldOrder.addError('Cannot Delete Cloud Monthly Billing Order in Status ' + oldOrder.Status__c);
        }
    }
}



// Inserting Account Address 
if(Trigger.isafter && Trigger.isInsert && !OrderTrigger_Utils_Class.isOrdAdrInsertFlag())
{
    OrderTrigger_Utils_Class.setOrdAdrInsertFlag(true);
    if(Trigger.isAfter && Trigger.isUpdate)
    {
      Order_Trigger_Class.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    } 
    OrderTrigger_Utils_Class.setOrdAdrInsertFlag(false);    
}
//Inserted for Hard delete
if(trigger.isDelete && trigger.isBefore)
     {   
        ID jobID = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'delete'));
     }
     
   if(trigger.isUnDelete && trigger.isAfter)
     {   
        ID jobID2 = System.enqueueJob(new DeleteHistoryAsync(Trigger.newMap,'Restore'));
     }
}