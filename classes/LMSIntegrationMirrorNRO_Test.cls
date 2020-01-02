@isTest
public class LMSIntegrationMirrorNRO_Test {
	
	static testMethod void tstMirr() {

		TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;

		Account acc = new Account( Name='Account', Status__c = 'Active' );  
	 	insert acc;   
	
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', 
                                     	OfferingType__c = 'PureConnect Cloud', IsActive = true);
        insert prod;
            
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Product2 prod1 = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'A', 
                                     	OfferingType__c = 'PureConnect Cloud', IsActive = true);
        insert prod1;
            
        PricebookEntry standardPrice1 = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod1.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        
        LMSIntegrationMirrorNRO.OrderProduct pr1 = new LMSIntegrationMirrorNRO.OrderProduct();
        pr1.PartNum = 'APN';
        pr1.Qty = 1;
        LMSIntegrationMirrorNRO.OrderProduct pr2 = new LMSIntegrationMirrorNRO.OrderProduct();
        pr2.PartNum = 'A';
        pr2.Qty = 1;
        
        LIst<LMSIntegrationMirrorNRO.OrderProduct> plst1 = new LIst<LMSIntegrationMirrorNRO.OrderProduct>();
        plst1.add(pr1);
        LIst<LMSIntegrationMirrorNRO.OrderProduct> plst2 = new LIst<LMSIntegrationMirrorNRO.OrderProduct>();
        plst2.add(pr2);
        
        
        List<RecordType> nroContractType = [SELECT Id From RecordType WHERE DeveloperName = 'Non_Revenue_Orders' AND SObjectType ='Order__c'];
        
        List<RecordType> orderLineType = [SELECT Id From RecordType WHERE DeveloperName = 'Default' AND SobjectType ='Order_Line_Item__c'];
       
        Global_Setting__c gs1 = new Global_Setting__c(Name='NRO RT', ID__c = nroContractType[0].Id );
        insert gs1;
        Global_Setting__c gs2 = new Global_Setting__c(Name='Mirror', Information__c = 'Mirror');
        insert gs2;
        Global_Setting__c gs3 = new Global_Setting__c(Name='Order Line Default RT', ID__c = orderLineType[0].Id);
        insert gs3;
        
        Auto_number__c myCS1 = new Auto_number__c(Name='start', values__c = 1);
        insert myCS1;
        
        ServiceContract sc = new ServiceContract();
        sc.Name = 'Test Service Contract';
        sc.Agreement_Status__c = 'Active';
        sc.Service_Contract_Type__c = 'Mirror';
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
        
        Util.Bypass_Trigger_Chk = true;
             
        Test.startTest();
        
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(acc.Id, acc.Id, '', plst1);
        // duplicate
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(acc.Id, acc.Id, '', plst1);
        
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(acc.Id, acc.Id, '', plst2);
        
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO('', acc.Id, '', plst2);
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(acc.Id, '', '', plst2);
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO('12', acc.Id, '', plst2);
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(acc.Id, acc.Id, '', plst2);
        LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(acc.Id, acc.Id, '', new LIst<LMSIntegrationMirrorNRO.OrderProduct>());
        
        Test.stopTest();
	}
    
}