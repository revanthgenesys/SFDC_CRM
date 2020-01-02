/************************************************************************************
Purpose : Trigger to fire events on update
Written By : Anto Carmel
Test Classes : GenesysTriggerHandlerTest
*************************************************************************************/
trigger GenesysProductTrigger on Product2 (before update) {
	/**Added by Anto on 08/15/2018 for Has Overage Validation**/
	if (Util.Bypass_Trigger_Chk)return;
	GenesysProductTriggerHandler.productValidations(Trigger.new);
	/**Added by Anto Ends**/
}