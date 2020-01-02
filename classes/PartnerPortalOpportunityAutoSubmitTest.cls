@isTest
private class PartnerPortalOpportunityAutoSubmitTest {
	@isTest(seeAllData=true)
    static void testTrigger_PartnerPortalOpportunityRegistration_After1(){
        User u = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.OwnerId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 1];
        Partner_Portal_Prospect__c oppReg = new Partner_Portal_Prospect__c
                    ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Approved', Genesys_AE__c='exec',
                      End_User_Account__c = u.Contact.AccountId,
                      Account__c = u.Contact.AccountId,
                      Offerings_Type__c = 'PureConnect',
                      Offering_Details__c = 'Subscription',
                      Opportunity_Currency__c = 'USD',
                      Opportunity_Channel_Manager__c = u.Contact.Account.OwnerId,
                      What_is_the_Expected_Close_Date__c = Date.today().addDays(1));                      
        insert oppReg; 
    }
    
    @isTest(seeAllData=true)
    static void testTrigger_PartnerPortalOpportunityRegistration_After2(){
        User u = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.OwnerId FROM User WHERE isActive = true AND ContactId != NULL AND Contact.Account.RecordType.Name = 'Enterprise - Business Partner' LIMIT 1];
        Partner_Portal_Prospect__c oppReg = new Partner_Portal_Prospect__c
                    ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Request Submitted', Genesys_AE__c='exec',
                      End_User_Account__c = u.Contact.AccountId,
                      Account__c = u.Contact.AccountId,
                      Offerings_Type__c = 'PureConnect',
                      Offering_Details__c = 'Subscription',
                      Opportunity_Currency__c = 'USD',
                     Opportunity_Channel_Manager__c = u.Contact.Account.OwnerId,
                      What_is_the_Expected_Close_Date__c = Date.today().addDays(1));                      
        
        User zinfiIntegrationUser = [SELECT Id, Name FROM User WHERE Id = :Label.Zinfi_Integration_User];
        System.runAs(zinfiIntegrationUser) {
			insert oppReg; 	
        }    
    }
    
}