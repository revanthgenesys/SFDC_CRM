/*
Raghu R : 2/3/2014 : MDM Project : Util Class for the triger Order_Trigger and AccountAddress_Trigger.
*/
public class OrderTrigger_Utils_Class {
    
    private static Boolean ordAdrInsertFlag = false;
    private static Boolean acntAddrInsertFlag = false;
    public static Boolean ACCOUNT_ORDER_UPDATE = true;

    private static String COMPLETED_STATUS = 'Completed';
    private static String PROCESSED_IN_ERP_STATUS = 'Processed in ERP';
    
    public static void setOrdAdrInsertFlag(Boolean triggerFlag){
        ordAdrInsertFlag = triggerFlag;
    }
    
    public static Boolean isOrdAdrInsertFlag(){ 
        return ordAdrInsertFlag;
    }
    
    public static void setAcntAddrInsertFlag(Boolean triggerFlag){
        acntAddrInsertFlag = triggerFlag;
    }
    
    public static Boolean isAcntAdrInsertFlag(){ 
        return acntAddrInsertFlag;
    }

    public static Boolean cloudMonthlyOrderAllowDelete(Order__c oldOrder) {
        // If not a Cloud Monthly Order, do not forbid a delete in this logic
        if (oldOrder.RecordTypeId != (Id)Label.Cloud_Monthly_Order_RecordTypeId) {
            return true;
        }
        
        // Our order is a Cloud Monthly Order forbid a delete if processed or completed
        if (oldOrder.Status__c == PROCESSED_IN_ERP_STATUS || oldOrder.Status__c == COMPLETED_STATUS) {
            return false;
        }
        return true;
    }
    
}