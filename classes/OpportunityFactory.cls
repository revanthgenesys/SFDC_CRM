@isTest(seealldata = true)
public class OpportunityFactory {
    public static Opportunity CreatePremiseQualifiedOpportunity(String name)
    {
        return CreateOpportunity(name, 'PureConnect', Date.today().addMonths(3), 'Qualified', 'None');
    }
    
    public static Opportunity CreateCaaSOpportunity(String name)
    {
        return CreateOpportunity(name, 'PureConnect', Date.today().addMonths(3), 'ReadyToOrder', 'Subscription');
    }
    
    public static Opportunity CreatePureCloudOpportunity(String name)
    {
        return CreateOpportunity(name, 'PureCloud', Date.today().addMonths(3), 'ReadyToOrder', 'Subscription');
    }
    
    public static Opportunity CreatePureCloudTrialOpportunity(String name)
    {
        return CreateOpportunity(name, 'PureCloud', Date.today().addMonths(3), 'ReadyToOrder', 'Pilot/Trial/POC');
    }

    private static Opportunity CreateOpportunity(String name, String type, Date closeDate, string stage, string offerDetail)
    {
        return new Opportunity(
            Name = name,            
            Quote_Type__c = type,
            Lines_of_Businesses__c = type,
            Deployment_Model__c = type,             
            CloseDate = closeDate,
            CurrencyIsoCode = 'USD',            
            StageName = stage, 
            Language__c = 'English-US',
            Offering_Detail__c = offerDetail,
            accountid = [Select id from account limit 1][0].id
        );
            
    }
    
    //public static Opportunity_Line_Item__c CreateOpportunityLineItem(string PartNumber, integer Qty)
    //{
    //    Opportunity_Line_Item__c oli = new Opportunity_Line_Item__c();
    //    oli.Part_Number__c = PartNumber;
    //    oli.Part_Name__c = 'Part ' + PartNumber;
    //    oli.Part_Description__c = 'Description for ' + PartNumber;
    //    oli.Quantity__c = Qty;          
    //    return oli;
    //}
    
    
}