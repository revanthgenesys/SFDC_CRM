/************************************************************************************
Purpose : Trigger for under Subscription Product to create service tokens
Written By : Ranjith Punneli
Test Classes : SubscriptionProductTest
*************************************************************************************/

trigger SubscriptionProductTrigger on Subscription_Product__c (after insert) {
    
    if(Util.Bypass_Trigger_Chk)
        return; 
    
    if(Trigger.isInsert) {
        if(Trigger.isAfter) {
            //Create service tokens and support purchases
            if(Trigger.isAfter && TriggerFlowManager.SUBSCRIPTION_PRODUCT_TRIGGER_RUN) {
                //Create service tokens and support purchases
                SubscriptionProductTriggerHandler.createServiceTokens(Trigger.new);
                TriggerFlowManager.SUBSCRIPTION_PRODUCT_TRIGGER_RUN = false;
            }
        }
    }
}