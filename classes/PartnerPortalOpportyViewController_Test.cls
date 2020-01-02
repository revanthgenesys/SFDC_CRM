@isTest
public class PartnerPortalOpportyViewController_Test {
	
	private static partner_portal_prospect__c  pOpp1;
    private static Account  acnt;
    private static Contact cnt;
    private static User user;

    static testMethod void testMethod_1() {

        TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account acct = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, acct, true)[0];
    	User testUser;

    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
    	   
	    partner_portal_prospect__c oppReg = new partner_portal_prospect__c
    		        ( Name='Test Account', Status__c = 'Approved', Genesys_AE__c='exec',
    		          End_User_Account__c = acct.Id,
    		          Account__c = acct.Id,
    		          Opportunity_Currency__c = 'USD - U.S. Dollar',
    		          What_is_the_Expected_Close_Date__c = Date.today().addDays(1));     		          
        insert oppReg; 
        System.runAs(runAsUser[0]) {            	
    		 OpportunityNewFromRegistration.newOppFromOppRegistr(oppReg.Id, 'OppRegistration');
        }
        
        List<Opportunity> opp = [SELECT Id
                                 FROM Opportunity 
                                 WHERE Partner_Opportunity_Registration__c IN 
                                       (SELECT Id FROM partner_portal_prospect__c WHERE Account__c =: acct.Id)];
        if ( !opp.isEmpty() ) {
        
	        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
	        Product2 prod = new Product2();
	        prod.Name = 'Test Prod ';
	        prod.recordTypeId = rtypes[0].Id;
	        prod.Type__c = 'Product';
	        insert prod;  
	        Id pricebookId = Test.getStandardPricebookId();
	               
	        PricebookEntry pbe1 = new PricebookEntry();
	        pbe1.Pricebook2Id = pricebookId;
	        pbe1.IsActive = true;
	        pbe1.Product2Id = prod.Id;
	        pbe1.UnitPrice = 10.1;
	        pbe1.UseStandardPrice = false;
	        pbe1.CurrencyIsoCode = 'USD';
	        insert pbe1;
	        
	        OpportunityLineItem oli1 = new OpportunityLineItem();
	        oli1.OpportunityId = opp[0].id;
	        oli1.PricebookEntryId = pbe1.id;
	        insert oli1;
        }
                                               
      Test.startTest();       
      System.runAs(testUser) {
      	
        	PageReference pg = Page.PartnerPortalOpportyView;	       	        
	        pg.getParameters().put('Id', opp.isEmpty() ? '' : opp[0].Id );	 
	        pg.getParameters().put('acc', acct.Id);	       	
	        Test.setCurrentPage(pg);         
	        PartnerPortalOpportyViewController vc = new PartnerPortalOpportyViewController();
        	
        	PageReference pg2 = Page.PartnerPortalOpportyView;	       	        	           	
	        Test.setCurrentPage(pg2);         
	        PartnerPortalOpportyViewController vc2 = new PartnerPortalOpportyViewController();
        	
        }
        Test.stopTest();
	}

}