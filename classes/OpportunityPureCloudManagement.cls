/*
 * Managed functionality related to PureCloud opps. Called by OpportunityTrigger. 
*/
public class OpportunityPureCloudManagement {

    private List<Account_PureCloud_Monthly_Minimum__c> newAccountMonthlyMinimums;

    public OpportunityPureCloudManagement()
    {
        newAccountMonthlyMinimums = new List<Account_PureCloud_Monthly_Minimum__c>();
    }

    public static void pureCloudOppManagement(Map<Id, Opportunity> oldOppList, List<Opportunity> newOppList)
    {
        OpportunityPureCloudManagement opportunityPureCloudManagement = new OpportunityPureCloudManagement();

        // Check if the Opportunity is a PureCloud Opp
        for (Opportunity opp : newOppList)
        {
            Opportunity oldOpp = null;
            if (opp.AccountId != null)
            {
                // Check if the opp is new or the currency has changed
                if (oldOppList != null)
                {
                    oldOpp = oldOppList.get(opp.Id);
                }      
                        
                if ((oldOpp == null && opp.Lines_of_Businesses__c == 'PureCloud')
                    || (oldOpp != null && opp.CurrencyIsoCode != oldOpp.CurrencyIsoCode && opp.Lines_of_Businesses__c == 'PureCloud')
                    || (oldOpp != null && oldOpp.Lines_of_Businesses__c != 'PureCloud' && opp.Lines_of_Businesses__c == 'PureCloud'))
                {
                    opportunityPureCloudManagement.createAccountPureCloudMonthlyMinimum(opp.AccountId, opp.CurrencyIsoCode);
                }
            }
        }

        if (opportunityPureCloudManagement.newAccountMonthlyMinimums.size() > 0)
        {
            insert opportunityPureCloudManagement.newAccountMonthlyMinimums;
        } 
    }

    public void createAccountPureCloudMonthlyMinimum(Id accountId, String ISOCode)
    {
        List<Account_PureCloud_Monthly_Minimum__c> accountMonthlyMinimum = new List<Account_PureCloud_Monthly_Minimum__c>([SELECT Id 
                                                                                                                           FROM Account_PureCloud_Monthly_Minimum__c 
                                                                                                                           WHERE CurrencyIsoCode = :ISOCode                                     
                                                                                                                           AND Account__c = :accountId
                                                                                                                           LIMIT 1]);

        // If there is no monthly minium, create a new one with the default values for the given currency
        if (accountMonthlyMinimum.size() == 0)
        {
            newAccountMonthlyMinimums.add(new Account_PureCloud_Monthly_Minimum__c (
                    Account__c = accountId,
                    CurrencyIsoCode = ISOCode,
                    Monthly_Minimum__c = PureCloudMonthlyMinimum.getMonthlyMinimum(ISOCode)
                    )
                );
        }
    }

}