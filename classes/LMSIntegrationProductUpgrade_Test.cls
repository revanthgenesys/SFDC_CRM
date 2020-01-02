@isTest
public class LMSIntegrationProductUpgrade_Test {
	
	static testMethod void tstUpgr() {

		TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;

		Account acc = new Account( Name='Account', Status__c = 'Active');  
	 	insert acc;   
	
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', APN_Number__c = 'APN', IsActive = true);
        insert prod;
            
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(CurrencyIsoCode ='USD',
				        Pricebook2Id = pricebookId, Product2Id = prod.Id,
				        UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        LMSIntegrationProductUpgrade.OrderProduct pr1 = new LMSIntegrationProductUpgrade.OrderProduct();
        pr1.PartNum = 'APN';
        pr1.Qty = 1;
        LMSIntegrationProductUpgrade.OrderProduct pr2 = new LMSIntegrationProductUpgrade.OrderProduct();
        pr2.PartNum = 'A';
        pr2.Qty = 1;
   
        LIst<LMSIntegrationProductUpgrade.OrderProduct> plst = new LIst<LMSIntegrationProductUpgrade.OrderProduct>();
        plst.add(pr1);
        
        Test.startTest();
        
        LMSIntegrationProductUpgrade.LMSIntegrationProductUpgrade(acc.Id, plst);
        
        LMSIntegrationProductUpgrade.LMSIntegrationProductUpgrade('', plst);
        LMSIntegrationProductUpgrade.LMSIntegrationProductUpgrade(acc.Id, plst);
        
        plst.add(pr2);
        LMSIntegrationProductUpgrade.LMSIntegrationProductUpgrade(acc.Id, plst);
        
        LMSIntegrationProductUpgrade.LMSIntegrationProductUpgrade(acc.Id, new LIst<LMSIntegrationProductUpgrade.OrderProduct>());
        
        Test.stopTest();
        
	}
    
}