@isTest(seeAllData = true)
private class SellableItemHistoryMainTest{ 
    static testmethod void testSellableItem() {
        Sellable_Item_Product__c testSellableItem = new Sellable_Item_Product__c();
        testSellableItem.Name = 'SellableItemHistoryMainTest Test Item';
        insert testSellableItem;
        
        Sellable_Item_History__c testHistory = new Sellable_Item_History__c();
        testHistory.Sellable_Item__c = testSellableItem.id;
        testHistory.Field_Name__c = 'Name';
        testHistory.Old_Value__c = 'SellableItemHistoryMainTest Test Item';
        testHistory.New_Value__c = 'SellableItemHistoryMainTest Test Item 1';
        insert testHistory;
         
    }
}