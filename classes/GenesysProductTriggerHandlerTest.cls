/************************************************************************************
Purpose : Unit test class for GenesysProductTriggerHandler.
Written By : Anto Carmel
Test Classes : N/A
*************************************************************************************/
@isTest
public with sharing class GenesysProductTriggerHandlerTest {
	@testsetup
	static void setupData() {
		Product2 objProd = new Product2();
		objProd.Name = 'Test Product';
		objProd.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('PureCloud').getRecordTypeId();
		objProd.OfferingType__c = 'PureCloud';
		objProd.Has_Overage__c = false;
		insert objProd;
	}

	static testmethod void updateProductWithM2M() {
		Product2 objProd = [SELECT Id, Name, Has_Overage__c
		                    FROM Product2
		                    WHERE Name = 'Test Product'];

		Product_Tier_Pricing__c objPTP = new Product_Tier_Pricing__c();
		objPTP.Product__c = objProd.Id;
		objPTP.Charge_Type__c = 'M2M';
		insert objPTP;

		Test.startTest();
		objProd.Has_Overage__c = true;
		update objProd;
		system.assertEquals(true, objProd.Has_Overage__c);
		Test.stopTest();
	}

	static testmethod void updateProductWithoutM2M() {
		Product2 objProd = [SELECT Id, Name, Has_Overage__c
		                    FROM Product2 WHERE Name = 'Test Product'];

		Product_Tier_Pricing__c objPTP = new Product_Tier_Pricing__c();
		objPTP.Product__c = objProd.Id;
		objPTP.Charge_Type__c = 'Annual M2M';
		insert objPTP;

		Test.startTest();
		try {
			objProd.Has_Overage__c = true;
			update objProd;
		} catch (Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains((Label.Genesys_Product_Error_Message)) ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
		}
		Test.stopTest();
	}

}