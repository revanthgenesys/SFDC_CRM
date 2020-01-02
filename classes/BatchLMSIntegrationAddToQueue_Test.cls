@isTest 
private class BatchLMSIntegrationAddToQueue_Test {
	
	static testmethod void tst() {
		
		TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;

		Account acc = new Account( Name='Account', Status__c = 'Active');  
	 	insert acc;   
	
	    List<Id> acclstId = new List<Id>();
	 	acclstId.add(acc.Id);
	 		 	
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                      OfferingType__c = 'PureConnect On Premise', IsActive = true);
        insert prod;
            
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        ServiceContract sc = new ServiceContract();
        sc.Name = 'Test Service Contract';
        sc.Agreement_Status__c = 'Active';
        sc.AccountId = acc.id;
        sc.End_User_Name__c = acc.id;
        sc.Sold_To_Name__c = acc.Id;
        sc.EndDate = Date.Today().addDays(200);
        sc.StartDate = Date.Today();
        sc.pricebook2id = pricebookId;
        insert sc;
        
        ContractLineItem cLI = new ContractLineItem(ServiceContractId = sc.Id);
        cLI.Quantity = 10;
        cLI.UnitPrice = 100;
        cLI.pricebookEntryId = standardPrice.Id;
        cLI.Upgraded_Product__c = prod.Id;
        cLI.Current_Quantity__c = 1;
        cLI.Maintenance_Start_Date__c = Date.Today();
        cLI.Maintenance_End_Date__c = Date.Today().addDays(200);
        insert cLI;
		
		LMS_Integration_Configuration__c custConf = new LMS_Integration_Configuration__c(
		  Last_Successful_AddQ_Run__c = Date.today().addDays(-3),
		  Notify_On_Errors__c = 'tst@tst.com' );   
		insert custConf;
		
		System.Test.startTest();
		BatchLMSIntegrationAddToQueue batch = new BatchLMSIntegrationAddToQueue();
	    Database.executeBatch(batch, 1); 
		System.Test.stopTest();
		
	}
	
	static testmethod void tstschedulable() {
	   Test.startTest();
        system.schedule('BatchLMSIntegrationAddToQueueSchedulable','0 0 * * * ?', new BatchLMSIntegrationAddToQueueSchedulable());
       Test.stopTest();
	}
    
}