@isTest(seeAllData=true)
private class AccountUpdateOrderTest {
    @isTest
    static void testAccountUpdateOrder(){
        Map<Id, Order__c> orders = new Map<Id, Order__c>([SELECT id, Name, End_User_Name__c, 
                                 End_User_Name__r.Genesys_Care_Ops__c, End_User_Name__r.Genesys_Care_specialist__c, 
                                 End_User_Name__r.Genesys_Care_Offering__c 
                                 FROM Order__c 
                                 WHERE status__c = 'Completed' AND Opportunity__r.RecordType.Name = 'Genesys Renewal' LIMIT 2]);
        
        
        Util.Bypass_Trigger_Chk = true;
        Order__c order = orders.Values().get(0);
		Account a1 = new Account(Id = order.End_User_Name__c, Genesys_Care_Ops__c = NULL, Genesys_Care_specialist__c = NULL, Genesys_Care_Offering__c = NULL);
        update a1;
        Util.Bypass_Trigger_Chk = false;
        Test.startTest();
        AccountUpdateOrder.updateAccount(orders, orders);
        Test.stopTest();
    }

}