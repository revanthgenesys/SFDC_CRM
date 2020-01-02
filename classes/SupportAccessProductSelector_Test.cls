@isTest (SeeAllData = true)
public class SupportAccessProductSelector_Test {
    
    static testMethod void testProdByStEu() {
        
            Util.Bypass_Trigger_Chk = true;
            Account accnt = new Account( Name='Test Account', Status__c = 'Active');   
            insert accnt;
        
            Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', zqu__ZuoraId__c = 'testProdByStEu',
                                            	OfferingType__c = 'PureEngage On Premise', IsActive = true);
            insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            ServiceContract servCon = new ServiceContract();
            servCon.Name = 'Test Service Contract';
            servCon.Sold_To_Name__c = accnt.Id;
            servCon.End_User_Name__c = accnt.Id;
            servCon.Agreement_Status__c = 'Active';
            servCon.pricebook2id = pricebookId;     
            insert servCon; 
            
            ContractLineItem cli = new ContractLineItem( ServiceContractId = servCon.Id,
                                                         Quantity = 10, UnitPrice = 100,
                                                         PricebookEntryId = standardPrice.Id,
                                                         Upgraded_Product__c = prod.Id
                                                        );
            insert cli;
            
            Support_Product__c supportProduct = new Support_Product__c(name='Support Prod',                                                                        
                                                                        Product_Type__c ='Cloud Service',
                                                                        Customer_Available__c = true, Status__c = 'Active', Active__c = true );
            insert supportProduct;
            
             Support_Product__c supportProduct2 = new Support_Product__c(name='Support Prod', 
                                                                        Product_Type__c ='Component',
                                                                        Customer_Available__c = true, Active__c = true );
                                                                        
            Support_Product__c cldprod =  new Support_Product__c(name='Cloud Prod', 
                                                                Product_Type__c ='Product',
                                                                // Category__c = 'PureConnect Products',
                                                                Category__c = 'Genesys Care Tools',
                                                                //Product_Group__c = 'ACD', 
                                                                Customer_Available__c = true, Status__c = 'Acive', Active__c = true );
            insert cldprod;
            
            Support_Problem_Category__c cat = new Support_Problem_Category__c(name = 'Category',Status__c = 'Active');
            insert cat;   
            
            Support_Product_Related_Category__c rel = new Support_Product_Related_Category__c(
                                             Support_Product__c = cldprod.Id,
                                             Support_Problem_Category__c = cat.Id);                                               
                                                            
            Back_Office_Account__c testBOA = new Back_Office_Account__c();
            testBOA.End_User_Account__c = accnt.id;
            testBOA.Sold_To_Account__c = accnt.id;
            insert testBOA;
            
            Cloud_Deployment__c cld = new Cloud_Deployment__c(Account__c= accnt.Id, Sold_To_Account__c = accnt.id,
                                       Cloud_Platform__c = 'PureConnect Cloud');
            insert cld;
            
            Test.startTest();
            SupportAccessProductSelector.getComponentsByProduct(supportProduct.Id);
            
            SupportAccessProductSelector.getComponentsByProduct(supportProduct.Id); // return existing
            
            SupportAccessProductSelector.getProductsByStEu (accnt.Id, accnt.Id);
            
            SupportAccessProductSelector.getProductsByStEu (accnt.Id, accnt.Id); // return existing
            
            SupportAccessProductSelector.getProductsAccessAll();
            
             SupportAccessProductSelector.getProductsAccessAll(); // return existing
            
            Map<String, Map<Id, String>> gr = SupportAccessProductSelector.getPureCnctGroupWithProducts(false);            
             Map<Id, Map<Id, String>> mp = SupportAccessProductSelector.getPureCnctProdWithProbCateg(false);
             
            SupportAccessProductSelector.getCloudProductsByDepl(cld.id);
            
             Map<String, Map<Id, String>> gr1 = SupportAccessProductSelector.getPureCnctGroupWithProducts(true);            
             Map<Id, Map<Id, String>> mp1 = SupportAccessProductSelector.getPureCnctProdWithProbCateg(true);
            
            SupportAccessProductSelector.getComponentsByProduct(null);
            
            Test.stopTest();
  }
/*  
    static testMethod void testNoProd() {
        
            Util.Bypass_Trigger_Chk = true;
            Account accnt = new Account( Name='Test Account', Status__c = 'Active');   
            insert accnt;
        
            Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', 
                                            	OfferingType__c = 'PureEngage On Premise', IsActive = true);
            insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            ServiceContract servCon = new ServiceContract();
            servCon.Name = 'Test Service Contract';
            servCon.Sold_To_Name__c = accnt.Id;
            servCon.End_User_Name__c = accnt.Id;
            servCon.Agreement_Status__c = 'Active';
            servCon.pricebook2id = pricebookId;     
            insert servCon; 
            
            ContractLineItem cli = new ContractLineItem( ServiceContractId = servCon.Id,
                                                         Quantity = 10, UnitPrice = 100,
                                                         PricebookEntryId = standardPrice.Id,
                                                         Upgraded_Product__c = prod.Id
                                                        );
            insert cli;
            
            Test.startTest();
            
            SupportAccessProductSelector.getProductsByStEu (accnt.Id, accnt.Id); // return existing
            
             SupportAccessProductSelector.getProductsAccessAll(); // return existing
            
            Map<String, Map<Id, String>> gr = SupportAccessProductSelector.getPureCnctGroupWithProducts(false);            
             Map<Id, Map<Id, String>> mp = SupportAccessProductSelector.getPureCnctProdWithProbCateg(false);
     
             Map<String, Map<Id, String>> gr1 = SupportAccessProductSelector.getPureCnctGroupWithProducts(true);            
             Map<Id, Map<Id, String>> mp1 = SupportAccessProductSelector.getPureCnctProdWithProbCateg(true);
            
            SupportAccessProductSelector.getComponentsByProduct(null);
            
            Test.stopTest();
  } 
  */
}