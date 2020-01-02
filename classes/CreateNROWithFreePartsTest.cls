//Naresh Kumar	04/12/2018
/** Yuvaraj Palani 03/11/2019 - Update for Queueable apex NRO change */
@isTest
public class CreateNROWithFreePartsTest {
    static testMethod void testCreateNRO(){ 
        Auto_number__c myCS1 = new Auto_number__c();
        myCS1.Name='start';
        myCS1.values__c=1;
        insert myCS1;
        Global_Setting__c GS = new Global_Setting__c();
        GS.ID__c='012U0000000M2TwIAK';
        GS.Name='NRO RT';
        GS.Type__c='Record Type';
        insert GS;
        Global_Setting__c GS1 = new Global_Setting__c();
        GS1.ID__c='012U0000000t4CkIAI';
        GS1.Name='Order Line Default RT';
        GS1.Type__c='Record Type';
         insert GS1;
        Account objAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity objOpp = TestUtil.createOpportunities(1, objAccount.id, true)[0];
        BigMachines__Quote__c objQuote = TestUtil.createQuotes(1, objOpp.id, true)[0];
        Order__c objOrder = TestUtil.createOrders(1, objQuote.id, objOpp.id, false)[0];
        objOrder.Status__c = 'In Progress';
        insert objOrder;
        
        Product2 objProductPurchased = TestUtil.createProducts(1, true)[0];
        Product2 objProductFree = TestUtil.createProducts(1, true)[0];
        
        PureConnect_Dev_Parts__c objFreeParts = new PureConnect_Dev_Parts__c(Purchased_Part__c = objProductPurchased.id, Free_Part__c = objProductFree.id);
        insert objFreeParts;       
        List<Product2> listOfProducts = new List<Product2>();
        listOfProducts.add(objProductPurchased);
        Order_Line_Item__c objOLI = TestUtil.createOrderLines(listOfProducts, objOrder.id, true)[0];
        
        
        objOrder.Status__c = 'Approved';
        update objOrder;
         objOrder.Status__c = 'Completed';
        update objOrder;
        Test.startTest();
         
        CreateNROWithFreeParts ad = new CreateNROWithFreeParts (objOrder.id);
        
        ID jobID = System.enqueueJob(ad);
        Test.stopTest();  
  
    }
}