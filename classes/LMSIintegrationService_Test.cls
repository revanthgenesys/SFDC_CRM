@isTest
public class LMSIintegrationService_Test {
	
	 static testMethod void tstLMS() {
	 	
	 	TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;

		Account acc = new Account( Name='Account', Status__c = 'Active');  
	 	insert acc;   
	
	    List<Id> acclstId = new List<Id>();
	 	acclstId.add(acc.Id);
	 		 	
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                     OfferingType__c = 'PureConnect On Premise', IsActive = true);
        insert prod;
        
        Pure_Connect_Version_Upgrade__c up = new Pure_Connect_Version_Upgrade__c(Old_Product__c = prod.Id, New_Product__c = prod.Id,
                                                             	Old_Part_Number__c = 'APN', New_Part_Number__c = 'APN1');
        insert up;
            
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
               
        Product_Upgrade_Request__c upgrReqst = new Product_Upgrade_Request__c(
                                    Product__c = prod.Id, Account__c = acc.Id, Type__c = 'Version');
 
        insert upgrReqst;     
 
	 	Test.startTest();
	 	LMSIintegrationService.AccountProductEntlmnt ape = new LMSIintegrationService.AccountProductEntlmnt(acc.Id);
	 	
	 	LMSIintegrationService.AccountProductEntlmntBatchable ct = new LMSIintegrationService.AccountProductEntlmntBatchable(ape);
	 	
	 	LMSIintegrationService.ProductEntlmntLine ln = new LMSIintegrationService.ProductEntlmntLine('A', 'B', false, 1);
	 		 	
	 	LMSIintegrationService.putAccountsInLMSQueueById(acclstId);	
	 	LMSIintegrationService.putAccountsInLMSQueueById(null);	 
	 	
	 	LMSIintegrationService.isContractActive('Closed');
	 		
	 	Test.stopTest();	 	
	 }
	 
	 static testMethod void tstLMS3() {
	 	
	 	ServiceContract sc = new ServiceContract();
        sc.Name = 'Service Contract';
        insert sc;
        List<ServiceContract> scLst = new List<ServiceContract>();
        scLst.add(sc);
        
        Test.startTest();
        LMSIintegrationService.lmsAccountsFromContracts(scLst);
        LMSIintegrationService.lmsAccountsFromContracts(null);
        Test.stopTest();
	 	
	 }   
}