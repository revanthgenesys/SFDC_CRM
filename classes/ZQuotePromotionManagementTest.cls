//
// This class was added to support promotion parts and the PureCloud Dev Org part
// JIRA: PCPQ-56, PCPQ-52
// 
@isTest
public class ZQuotePromotionManagementTest {
    
    public static List<zqu__QuoteRatePlanCharge__c> GetQuoteRatePlanCharges()
    {
        return [SELECT Id, Name, zqu__QuoteRatePlan__c, zqu__Description__c, SKU__c, zqu__Discount_Level__c, zqu__Discount__c, zqu__EffectivePrice__c, 
                zqu__ListPrice__c, zqu__ListTotal__c, zqu__Quantity__c, EstimatedQty__c FROM zqu__QuoteRatePlanCharge__c ORDER BY LastModifiedDate DESC];        
    }
    
	// Run through the add code without the promo part being in the quote
	public testMethod static void TestAddWithoutPromoPart()
	{
		System.debug('TestZQuotePromotionManagement.TestAddWithoutPromoPart');

		TestZQuoteContext context = new TestZQuoteContext();
		context.SetupZQuote(false, true);
		context.SetupDevOrgProducts();
		context.SetupDevOrgPromotion();
		context.LoadAmendmentList();

		List<zqu__QuoteRatePlanCharge__c> beforeCharges = GetQuoteRatePlanCharges();

        List<String> addedRatePlans = new List<String>();
        
		Test.startTest();

		ZQuotePromotionManagement promotionManager = new ZQuotePromotionManagement();
		promotionManager.AddPromotions(context.ZQuote.Id, addedRatePlans);

		Test.stopTest();

		List<zqu__QuoteRatePlanCharge__c> afterCharges = GetQuoteRatePlanCharges();

		System.assertEquals(beforeCharges.size(), afterCharges.size(), 'The quote charge object was changed when it should not have been.');

	}


	// Run through the delete code without the promo part being in the quote
	public testMethod static void TestDeleteWithoutPromoPart()
	{
		System.debug('TestZQuotePromotionManagement.TestDeleteWithoutPromoPart');

		TestZQuoteContext context = new TestZQuoteContext();
		context.SetupZQuote(false, true);
		context.SetupDevOrgProducts();
		context.SetupDevOrgPromotion();
		context.LoadAmendmentList();

		List<zqu__QuoteRatePlanCharge__c> beforeCharges = GetQuoteRatePlanCharges();

        List<String> removedRatePlans = new List<String>();

		Test.startTest();

		ZQuotePromotionManagement promotionManager = new ZQuotePromotionManagement();
		promotionManager.DeletePromotions(context.ZQuote.Id, removedRatePlans);

		Test.stopTest();

		List<zqu__QuoteRatePlanCharge__c> afterCharges = GetQuoteRatePlanCharges();

		System.assertEquals(beforeCharges.size(), afterCharges.size(), 'The quote charge object was changed (size is different) when it should not have been.');

	}

    
    /*
     //* 
     //*  We can't test any of the methods that actually add or remove any parts because we can't call the zqu.zQuoteUtil methods from a test context
     //* 
     //* 
    

	// Run through the add code with the promo part being in the quote
	public testMethod static void TestAddWithPromoPart()
	{
		System.debug('TestZQuotePromotionManagement.TestAddWithPromoPart');

		TestZQuoteContext context = new TestZQuoteContext();
		context.SetupZQuote(false, true);
		context.SetupDevOrgProducts();
		context.SetupDevOrgPromotion();
		context.LoadAmendmentList();

		String quoteId = context.ZQuote.Id;

		Test.startTest();

		List<zqu__QuoteRatePlanCharge__c> beforeAddPromoPart = [SELECT Id, Part_Number__c, SKU__c, Name, QuoteId__c FROM zqu__QuoteRatePlanCharge__c WHERE QuoteId__c = :quoteId];

        System.debug('beforeAddPromoPart: ' + JSON.serialize(beforeAddPromoPart));
        
		context.AddPromoPart();

		List<zqu__QuoteRatePlanCharge__c> afterAddPromoPart = [SELECT Id, Part_Number__c, SKU__c, Name, QuoteId__c FROM zqu__QuoteRatePlanCharge__c WHERE QuoteId__c = :quoteId];

        System.debug('afterAddPromoPart: ' + JSON.serialize(afterAddPromoPart));

		System.assertEquals(beforeAddPromoPart.size() + 4, afterAddPromoPart.size(), 'The dev org promo part was not added correctly.');

		//zqu__QuoteRatePlanCharge__c edge = FindSKU(afterAddPromoPart, 'PC-170-NV-PCEDGE-VIR-C1');

		//System.assertEquals(100, edge.zqu__Discount__c, 'The discount percent on PC-170-NV-PCEDGE-VIR was not applied correctly.');

		//zqu__QuoteRatePlanCharge__c engage = FindSKU(afterAddPromoPart, 'PC-170-NV-USES3-C1');

		//Double discountAmount = engage.zqu__ListPrice__c - engage.zqu__EffectivePrice__c;
		//System.assertEquals(10, discountAmount, 'The discount amount on PC-170-NV-USES3 was not applied correctly.');

		Test.stopTest();

	}

	public static zqu__QuoteRatePlanCharge__c FindSKU(List<zqu__QuoteRatePlanCharge__c> chargeList, String sku)
	{
		for (zqu__QuoteRatePlanCharge__c charge : chargeList)
		{
			if (charge.SKU__c == sku)
			{
				return charge;
			}
		}

		return null;
	}

	// Run through the delete code with the promo part in the quote
	public testMethod static void TestDeleteWithPromoPart()
	{
		System.debug('TestZQuotePromotionManagement.TestDeleteWithPromoPart');

		System.debug('TestZQuotePromotionManagement.TestDeleteWithPromoPart');

		TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote(false, true);
        context.SetupDevOrgProducts();
		context.SetupDevOrgPromotion();
		context.AddPromoPart();
		context.LoadAmendmentList();
		//context.SetupDevOrgPromotion();		

		Test.startTest();

		//context.SetupDevOrgProducts();
		//context.AddPromoPart();
		//context.LoadAmendmentList();

		String quoteId = context.ZQuote.Id;

		List<zqu__QuoteRatePlanCharge__c> beforeCharges = [SELECT Id FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId];

        // Delete the promo part
        Product2 devOrgProduct = context.MakeDevOrgPart();
        String devOrgSKU = devOrgProduct.zqu__SKU__c + '-C1';
        zqu__ProductRatePlanCharge__c devOrgRatePlanCharge = [SELECT Id, zqu__ZuoraId__c, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c WHERE SKU__c = :devOrgSKU];
		List<zqu__QuoteRatePlanCharge__c> toDelete = [SELECT Id, Name, zqu__Quote__c, zqu__Apply_Discount_To_One_Time_Charges__c, zqu__Apply_Discount_To_Recurring_Charges__c, 
                                              zqu__Apply_Discount_To_Usage_Charges__c, zqu__BillCycleDay__c, zqu__BillingPeriodAlignment__c, zqu__ChargeType__c, 
                                              zqu__Currency__c, zqu__Description__c, zqu__Discount_Level__c, zqu__Discount__c, zqu__EffectivePrice__c, zqu__FeeType__c, 
                                              zqu__FirstPeriodCharge__c, zqu__IncludedUnits__c, zqu__ListPriceDisplay__c, zqu__ListPrice__c, zqu__ListTotal__c, 
                                              zqu__MRRForRollup__c, zqu__MRR__c, zqu__Model__c, zqu__PeriodNumeric__c, zqu__Period__c, zqu__Prepay__c, zqu__PrepaymentPeriods__c, 
                                              zqu__ProductName__c, zqu__ProductRatePlanCharge__c, zqu__ProductRatePlanName__c, zqu__Quantity__c, zqu__RatePlanCharge_ZuoraID__c, 
                                              zqu__SpecificBillingPeriod__c, zqu__TCVForRollup__c, zqu__TCV__c, zqu__TimeProductAdded__c, zqu__Total_Discount_Amount__c, 
                                              zqu__Total__c, zqu__TriggerDate__c, zqu__TriggerEvent__c, zqu__Type__c, zqu__UOM__c, zqu__Upto_How_Many_Periods__c, Discounted_Amount__c, 
                                              EstimatedQty__c, EstimatedTotalCharge__c, Estimated_Discount__c, Product_Category__c, Estimated_Period__c, ShippingAddressId__c, 
                                              ForRelatedPart__c, PureCloud_Voice_Price_Sheet_URL__c, Conga_Total__c, Can_Be_Auto_Discounted__c, Conga_Annualized_Total_Effective_Price__c, 
                                              Conga_Display_On_Template__c, Conga_Document_Category__c, Conga_Document_Subcategory__c, Conga_Proposal_Discount__c, 
                                              Conga_Proposal_Effective_Price__c, Conga_Proposal_Effective_Usage_Price__c, Conga_Proposal_Quantity__c, Conga_Proposal_Table__c, 
                                              Conga_Proposal_Total_Effective_Price__c, Conga_Proposal_Total_List_Price__c, Part_Number__c, Conga_Annualized_Total__c, 
                                              Is_Service_Token_Part__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__ProductRatePlanCharge__c = :devOrgRatePlanCharge.Id];
        
		ZQuotePromotionManagement promotionManager = new ZQuotePromotionManagement();
        promotionManager.DeletePromotions(context.ZQuote.Id, new List<String>{devOrgRatePlanCharge.zqu__ProductRatePlan__c});

		Test.stopTest();

		List<zqu__QuoteRatePlanCharge__c> afterCharges = [SELECT Id FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId];

		System.assertEquals(beforeCharges.size() - 3, afterCharges.size(), 'Dev Org Part bundle charges not deleted');

	}



*/
}