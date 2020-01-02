@isTest
public class OpportunityNewFromRegistration_Test {
	
	static testMethod void testOppReg() {
		
	  TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
	    Account accnt = new Account( Name='Test Account', Status__c = 'Active', OwnerId = runAsUser[0].Id);   
        insert accnt;
	
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
		
		partner_portal_prospect__c oppReg = new partner_portal_prospect__c
    		        ( Name='Test Account', Status__c = 'Approved', Genesys_AE__c='exec',
    		          End_User_Account__c = accnt.Id,
    		          Opportunity_Currency__c = 'USD - U.S. Dollar',
    		          What_is_the_Expected_Close_Date__c = Date.today().addDays(1));     		          
        insert oppReg; 
        
         Partner_Opporty_Registr_Product__c regprod = new Partner_Opporty_Registr_Product__c (Product__c = prod.Id,
    	 			                                            CurrencyIsoCode = 'USD',
                                                                Amount_Currency__c = 100,
                                                                Opporty_Registration__c = oppReg.Id);                                                               
        insert regprod;
        
        Lead_Referral_Registration__c ldReg = new Lead_Referral_Registration__c
                     (Name='Test Account', Status__c = 'Approved', Genesys_AE__c='exec',
    		          End_User_Account__c = accnt.Id,
    		          What_is_the_Expected_Close_Date__c = Date.today().addDays(1)); 
    		          
        insert ldReg;
       
        Test.StartTest();
        System.runAs(runAsUser[0]) {    
        	
    		 OpportunityNewFromRegistration.newOppFromOppRegistr(oppReg.Id, 'OppRegistration');
    		 
    		 OpportunityNewFromRegistration.newOppFromOppRegistr(ldReg.Id, 'LeadOppRegistration');
        }
        Test.StopTest();
        
        List<partner_portal_prospect__c> oppRegRes = [SELECT Opportunity__c FROM partner_portal_prospect__c 
                                                      WHERE Id = :oppReg.Id];
       
       List<Lead_Referral_Registration__c> ldRegRes = [SELECT Opportunity__c FROM Lead_Referral_Registration__c 
                                                      WHERE Id = :ldReg.Id];
       
       System.assertNotEquals(null, oppRegRes[0].Opportunity__c);
       System.assertNotEquals(null, ldRegRes[0].Opportunity__c);
  		
	}
	
	static testMethod void testOppRegExceptions() {
        
		TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
		Account accnt = new Account( Name='Test Account', Status__c = 'Active', OwnerId = runAsUser[0].Id);   
        insert accnt;
	    partner_portal_prospect__c oppReg = new partner_portal_prospect__c
    		        ( Name='Test Account',End_User_Account__c=accnt.Id, Status__c = 'Approved', Genesys_AE__c='exec', What_is_the_Expected_Close_Date__c = System.today().addDays(100));     		          
        insert oppReg; 
        
        Lead_Referral_Registration__c ldReg = new Lead_Referral_Registration__c
                     (Name='Test Account', Status__c = 'Approved', Genesys_AE__c='exec');     		          
        insert ldReg;
        
        Test.StartTest();
        System.runAs(runAsUser[0]) {    
        	
    		 OpportunityNewFromRegistration.newOppFromOppRegistr(oppReg.Id, 'OppRegistration');
    		 
    		 OpportunityNewFromRegistration.newOppFromOppRegistr(ldReg.Id, 'LeadOppRegistration');
        }
        Test.StopTest();
        
        List<partner_portal_prospect__c> oppRegRes = [SELECT Opportunity__c FROM partner_portal_prospect__c 
                                                      WHERE Id = :oppReg.Id];
       
       List<Lead_Referral_Registration__c> ldRegRes = [SELECT Opportunity__c FROM Lead_Referral_Registration__c 
                                                      WHERE Id = :ldReg.Id];
        
      //  System.assertEquals(null, oppRegRes[0].Opportunity__c);
        System.assertEquals(null, ldRegRes[0].Opportunity__c);
  
	}
}