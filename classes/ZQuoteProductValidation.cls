//
// This class was added to support PCPQ-33 - Validation for only one type of engage license
// 
public class ZQuoteProductValidation {
    
    public static void BeforeInsert(List<zqu__QuoteRatePlanCharge__c> newChargesList)
    {
        //System.debug('ZQuoteProductValidation.BeforeInsert');  

        // Since the newChargesList passed in only contains the newly added charges, query the quote for all the existing charges and add those to the list to be validated
        Id quoteId = newChargesList.get(0).QuoteId__c;
        List<zqu__QuoteRatePlanCharge__c> charges = [SELECT Id, Part_Number__c, zqu__ChargeType__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: quoteId];
        charges.addAll(newChargesList);

        if (!ValidateCharges(charges))
        {
            newChargesList.get(0).addError('Only one version of Engage may be added to the quote.');
        }
        
    }
    
    private static Boolean ValidateCharges(List<zqu__QuoteRatePlanCharge__c> charges)
    {
        //System.debug('ZQuoteProductValidation.Validate');
		Set<String> engagePartNumbers = new Set<String>();
        Zuora_Custom_Settings__c obj  = Zuora_Custom_Settings__c.getAll().get('PureCloudEngagePartNumbers');        
       	if (obj != null)
		{
			engagePartNumbers.addAll(obj.Value__c.split(';'));	
		}        

        Set<String> engageCharges = new Set<String>();
        
        for (zqu__QuoteRatePlanCharge__c charge : charges)
        {
            if (engagePartNumbers.contains(charge.Part_Number__c))
            {
                engageCharges.add(charge.Part_Number__c);
            }
        }

        if (engageCharges.size() > 1)
        {
            return false;
        }
		else
        {
            return true;
        }
    }
    
}