/************************************************************************************
Purpose : Handler class to handle GenesysProductTrigger events
Written By : Anto Carmel
Test Classes : GenesysProductTriggerHandlerTest
*************************************************************************************/

public with sharing class GenesysProductTriggerHandler {
	/**Method to validate Has Overage written by Anto**/
	public static void productValidations(List<Product2> list_Products) {
		Set<Id> set_ProductIds = new Set<Id>();
		User objUsr = [Select Id, BypassValidationRules__c from User where Id = : UserInfo.getUserId()];
		if (!FeatureManagement.checkPermission('Can_Check_Has_Overage_Field') && !objUsr.BypassValidationRules__c) {
			List<Product_Tier_Pricing__c>list_ProductTierPricing = [SELECT Id, Charge_Type__c, Product__c, Product__r.OfferingType__c
															        FROM Product_Tier_Pricing__c
															        WHERE Product__c in :list_Products and Charge_Type__c = 'M2M'];
			try {
				for (Product_Tier_Pricing__c objPrt : list_ProductTierPricing) {
					set_ProductIds.add(objPrt.Product__c);
				}
				for (Product2 objProd : list_Products) {
					if (objProd.Has_Overage__c && !set_ProductIds.contains(objProd.Id) && (objProd.OfferingType__c.contains(SubscriptionUtil.OFFERING_TYPE_PC) || objProd.OfferingType__c.contains(SubscriptionUtil.OFFERING_TYPE_PCC))) {
						objProd.addError(Label.Genesys_Product_Error_Message);
					}
				}
			} catch (Exception e) {
				System.debug(e);
			}
		}
	}
}