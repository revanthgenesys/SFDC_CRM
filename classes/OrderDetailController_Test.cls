@isTest (seeAllData = true)
private class OrderDetailController_Test {
  static testMethod void myUnitTest(){
    Util.Bypass_Trigger_Chk = true;
        Order__c testOrder = TestUtil.createOrders(1, false)[0];
        Opportunity opp = TestUtil.createOpportunities(1,true)[0];
        Test.StartTest();
        BigMachines__Quote__c quo = TestUtil.createQuotes( 1, opp.id, false)[0];
        quo.BigMachines__Is_Primary__c = true;
        insert quo;
        
        Test.StopTest();
        testOrder.Quote__c = quo.id;   
        testOrder.End_User_Name__c = opp.accountid;
        insert testOrder;       
        //Map<id,Order__c> ordMap = new Map<id,order__c>();
        //ordmap.put(testorder.id,testorder);
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        OrderDetailController obj = new OrderDetailController(stdCtrl);
  }
}