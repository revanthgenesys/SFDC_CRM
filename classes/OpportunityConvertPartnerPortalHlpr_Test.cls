@isTest
public class OpportunityConvertPartnerPortalHlpr_Test {
	
	 static testMethod void tst() {
	 	
	 	Util.Bypass_Trigger_Chk = true;
	 	
	 	Account testAccount = TestUtil.createAccounts(1, true)[0];
	 	 
	 	partner_portal_prospect__c oppReg = new partner_portal_prospect__c
                                ( Name='Test Account', Customer_Company_Name__c = 'Customer Company Name', Status__c = 'Request Submitted', Genesys_AE__c='exec',
                                Opportunity_Currency__c = 'USD - U.S. Dollar', End_User_Account__c = testAccount.Id,
                                Account__c = testAccount.Id,
                                Account_Executive_at_Genesys__c = UserInfo.getUserId(),
                                Opportunity_Channel_Manager__c =  UserInfo.getUserId(),                              
                                Platform_Type__c = 'Cloud',
                                Offerings_Type__c='PureCloud', Offering_Details__c = 'None',
                                What_is_the_Expected_Close_Date__c = Date.today().addDays(7));
                                
        insert oppReg;
        
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', IsActive = true);
		insert prod;
		
		Id pricebookId = Test.getStandardPricebookId();
		PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
		
		Pricebook2 customPB  = new Pricebook2(Name = 'Sales PriceBook', IsActive = true);
		insert customPB;
		
		PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
         Partner_Opporty_Registr_Product__c regprod = new Partner_Opporty_Registr_Product__c (Product__c = prod.Id,
    	 			                                            CurrencyIsoCode = 'USD',
                                                                Amount_Currency__c = 100,
                                                                Opporty_Registration__c = oppReg.Id);                                                               
        insert regprod;
        
        String ret = OpportunityConvertPartnerPortalHelper.newOppFromOppRegistr(oppReg.Id, 'OppRegistration');
	 } 
}