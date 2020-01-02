@isTest
public class BackOfficeAccountUtil_Test {
	
	static testMethod void testBoaUtil1() {
	    Util.Bypass_Trigger_Chk = true;
        Account accnt = TestUtil.createAccounts(1, true)[0];
        		
		Back_Office_Account__c boa = new Back_Office_Account__c();
		boa.Sold_To_Account__c = accnt.Id;
		boa.End_User_Account__c = accnt.Id;
 
        List<Back_Office_Account__c> boaLst = new List<Back_Office_Account__c>();
        boaLst.add(boa);
        
        BackOfficeAccountUtil.setBoaFields(boaLst);
        insert boa;
        
        List<Back_Office_Account__c> bosLst = [SELECT Id, Contract_Status__c FROM Back_Office_Account__c WHERE Id = :boa.id];
        System.assertNotEquals(null, bosLst);
        
        BackOfficeAccountUtil.setBoaFields(boaLst);
	}
	
    static testMethod void testBoaUtil2() {
		
		Util.Bypass_Trigger_Chk = true;

		Account acc = new Account( Name='Account', Status__c = 'Active');  
	 	insert acc;   
	
	    List<Id> acclstId = new List<Id>();
	 	acclstId.add(acc.Id);
	 		 	
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                     OfferingType__c = 'PureEngage On Premise', IsActive = true);
        insert prod;
        
        Product2 prod2 = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                       OfferingType__c = 'PureEngage On Premise', IsActive = true);
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice2 = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod2.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        List<ServiceContract> scl = new List<ServiceContract>();
        
        ServiceContract sc = new ServiceContract();
        sc.Name = 'Test Service Contract';
        sc.Agreement_Status__c = 'Active';
        sc.AccountId = acc.id;
        sc.End_User_Name__c = acc.id;
        sc.Sold_To_Name__c = acc.Id;
        sc.EndDate = Date.Today().addDays(200);
        sc.StartDate = Date.Today();
        sc.pricebook2id = pricebookId;
        sc.Service_Contract_Type__c = 'Perpetual';
        insert sc;
        scl.add(sc);
                
        ContractLineItem cLI = new ContractLineItem(ServiceContractId = sc.Id);
        cLI.Quantity = 10;
        cLI.UnitPrice = 100;
        cLI.pricebookEntryId = standardPrice.Id;
        cLI.Upgraded_Product__c = prod.Id;
        cLI.Current_Quantity__c = 1;
        cLI.Maintenance_Start_Date__c = Date.Today();
        cLI.Maintenance_End_Date__c = Date.Today().addDays(200);
        insert cLI;
                
        ServiceContract sc2 = new ServiceContract();
        sc2.Name = 'Test Service Contract';
        sc2.Agreement_Status__c = 'Active';
        sc2.AccountId = acc.id;
        sc2.End_User_Name__c = acc.id;
        sc2.Sold_To_Name__c = acc.Id;
        sc2.EndDate = Date.Today().addDays(200);
        sc2.StartDate = Date.Today();
        sc2.pricebook2id = pricebookId;
        sc2.Service_Contract_Type__c = 'Perpetual';
        insert sc2;
        scl.add(sc2);
                
        ContractLineItem cLI2 = new ContractLineItem(ServiceContractId = sc2.Id);
        cLI2.Quantity = 10;
        cLI2.UnitPrice = 100;
        cLI2.pricebookEntryId = standardPrice2.Id;
        cLI2.Upgraded_Product__c = prod2.Id;
        cLI2.Current_Quantity__c = 1;
        cLI2.Maintenance_Start_Date__c = Date.Today();
        cLI2.Maintenance_End_Date__c = Date.Today().addDays(200);
        insert cLI2;
        
        Util.Bypass_Trigger_Chk = false;
        
         Test.startTest(); 
        Back_Office_Account__c boa = new Back_Office_Account__c(Sold_To_Account__c = acc.Id, End_User_Account__c = acc.Id,
                                                 Platform__c = 'PureEngage On Premise');
        insert boa;
        
        BackOfficeAccountUtil.addBOAbyServiceContract(scl);
         
        Test.stopTest();
        
	}
	
	static testMethod void testBoaUtil3() {
		
		Util.Bypass_Trigger_Chk = true;

		Account acc = new Account( Name='Account', Status__c = 'Active');  
	 	insert acc;   
	
	    List<Id> acclstId = new List<Id>();
	 	acclstId.add(acc.Id);
	 		 	
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                     OfferingType__c = 'PureEngage On Premise', IsActive = true);
        insert prod;
        
        Product2 prod2 = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                       OfferingType__c = 'PureEngage On Premise', IsActive = true);
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice2 = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod2.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        List<ServiceContract> scl = new List<ServiceContract>();
        
        ServiceContract sc = new ServiceContract();
        sc.Name = 'Test Service Contract';
        sc.Agreement_Status__c = 'Active';
        sc.AccountId = acc.id;
        sc.End_User_Name__c = acc.id;
        sc.Sold_To_Name__c = acc.Id;
        sc.EndDate = Date.Today().addDays(200);
        sc.StartDate = Date.Today();
        sc.pricebook2id = pricebookId;
        sc.Service_Contract_Type__c = 'Perpetual';
        insert sc;
        scl.add(sc);
                
        ContractLineItem cLI = new ContractLineItem(ServiceContractId = sc.Id);
        cLI.Quantity = 10;
        cLI.UnitPrice = 100;
        cLI.pricebookEntryId = standardPrice.Id;
        cLI.Upgraded_Product__c = prod.Id;
        cLI.Current_Quantity__c = 1;
        cLI.Maintenance_Start_Date__c = Date.Today();
        cLI.Maintenance_End_Date__c = Date.Today().addDays(200);
        insert cLI;
                
        ServiceContract sc2 = new ServiceContract();
        sc2.Name = 'Test Service Contract';
        sc2.Agreement_Status__c = 'Active';
        sc2.AccountId = acc.id;
        sc2.End_User_Name__c = acc.id;
        sc2.Sold_To_Name__c = acc.Id;
        sc2.EndDate = Date.Today().addDays(200);
        sc2.StartDate = Date.Today();
        sc2.pricebook2id = pricebookId;
        sc2.Service_Contract_Type__c = 'Perpetual';
        insert sc2;
        scl.add(sc2);
                
        ContractLineItem cLI2 = new ContractLineItem(ServiceContractId = sc2.Id);
        cLI2.Quantity = 10;
        cLI2.UnitPrice = 100;
        cLI2.pricebookEntryId = standardPrice2.Id;
        cLI2.Upgraded_Product__c = prod2.Id;
        cLI2.Current_Quantity__c = 1;
        cLI2.Maintenance_Start_Date__c = Date.Today();
        cLI2.Maintenance_End_Date__c = Date.Today().addDays(200);
        insert cLI2;
      
        BackOfficeAccountUtil.addBOAbyServiceContract(scl);
        
        List<Back_Office_Account__c> boaLst = [SELECT Id, Contract_Status__c, Platform__c, Sold_To_Account__c, End_User_Account__c
                                               FROM Back_Office_Account__c 
                                               WHERE Sold_To_Account__c = :acc.Id
                                                 AND End_User_Account__c = :acc.Id
                                                 ];				
       Test.startTest();                                          
         BackOfficeAccountUtil.setBoaFields(boaLst);
          BackOfficeAccountUtil.addBOAbyServiceContract(scl);
          BackOfficeAccountUtil.setBoaFields(boaLst);
          
       Test.stopTest();
  
	}		
}