@isTest
public class ContractTierSetFactory {

    public static Contract_Tier_Set__c createContractTierSet(String name, Id contractId, String aggregationModel, String period, String rcPeriod, String unitType)
    {
        return new Contract_Tier_Set__c(
            Name = name,
            Contract__c = contractId,
            Aggregation_Model__c = aggregationModel,
            Period_In_Months__c = period,
            RC_Period__c = rcPeriod,
            Units_Type__c = unitType,
            Is_Deleted__c = false
        );
    }
}