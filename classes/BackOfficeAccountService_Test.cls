@isTest
public class BackOfficeAccountService_Test {
	
	static testMethod void testBoaService() {
	
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
        
        BackOfficeAccountUtil.addBOAbyServiceContract(new List<ServiceContract>{sc});
        
        List<Back_Office_Account__c> boaLst = [SELECT Id, Contract_Status__c, Platform__c, Sold_To_Account__c, End_User_Account__c
                                               FROM Back_Office_Account__c 
                                               WHERE Sold_To_Account__c = :acc.Id
                                                 AND End_User_Account__c = :acc.Id
                                                 ];				
     
        Test.startTest();       
          BackOfficeAccountService.getBoaContractFieldsBySTEU(acc.id, acc.id, 'PureConnect On Premise');
          BackOfficeAccountService.getBoaIdBySTEU(acc.id, acc.id, 'PureConnect On Premise');
          if (!boaLst.isEmpty())
         	 BackOfficeAccountService.getServiceContractsByBoaId(boaLst[0].id, 'active');
          BackOfficeAccountService.getServiceContractOffering(sc);
          BackOfficeAccountService.BoaInstance bi = new BackOfficeAccountService.BoaInstance(acc.id, acc.id, true, 'PureConnect On Premise');
		Test.stopTest();
		
		/// this is to cover Service ontract trigger ServiceContract_After
		Util.Bypass_Trigger_Chk = false;
		sc.Agreement_Status__c = 'Closed';
		update sc;
	    
	}	

}