@isTest
public class SubApprovalTestDataFactory {
@isTest(SeeAllData=true)
    public static List<DQ_Special_Offers__c> DQSpecialOffers(){
        
        return [select Name,Additional_Email_Addresses__c,Back_Up_Contact_Email__c,Finance_Function__c,Primary_Contact_Email__c,Region__c from DQ_Special_Offers__c];
        
    }
}