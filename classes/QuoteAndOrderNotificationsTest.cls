@isTest(seeAllData=true)
private class QuoteAndOrderNotificationsTest {
    static testMethod void testTrgEmailNotificationOnQuoteApproved() {
        setupTestData();
        Test.startTest();
       	List<BigMachines__Quote_Product__c> quoteProducts = [SELECT id, Name, BigMachines__Quote__c , BigMachines__Quote__r.BigMachines__Status__c 
                                                     FROM BigMachines__Quote_Product__c 
                                                     WHERE BigMachines__Quote__r.BigMachines__Status__c = 'Quote In Progress' 
                                              		AND Contract_Line_Update_Status__c IN ('Drop', 'Downsize', 'Reinstate') LIMIT 100];

		Set<String> quoteIds = new Set<String>();
        for(BigMachines__Quote_Product__c qp : quoteProducts){
            quoteIds.add(qp.BigMachines__Quote__c);
        }
		
        List<BigMachines__Quote__c> quotes = [SELECT id, Name, BigMachines__Status__c  from BigMachines__Quote__c WHERE Id IN :quoteIds LIMIT 1];
        for(BigMachines__Quote__c q : quotes){
            QuoteAndOrderNotificationsUtil.quoteTriggerfirstRun = true;
            q.BigMachines__Status__c = 'Quote Approved';
			update q;
        }
        Test.stopTest();
    }
    static testMethod void trgEmailNotificationOnOrderCompleted() {
        setupTestData();
		Test.startTest();
        /*
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT id, Name, BigMachines__Quote__c , BigMachines__Quote__r.BigMachines__Status__c, BigMachines__Quote__r.Order__c 
             													FROM BigMachines__Quote_Product__c 
                                                                 WHERE  BigMachines__Quote__r.Order__r.Status__c = 'Submitted' 
                                                                 AND Contract_Line_Update_Status__c IN ('Drop', 'Downsize', 'Reinstate') LIMIT 100];
        Set<String> orderIds = new Set<String>();
        for(BigMachines__Quote_Product__c qp : quoteProducts){
            orderIds.add(qp.BigMachines__Quote__r.Order__c);
        }

        List<Order__c> orders = [SELECT id, Name, status__c  from Order__c WHERE Id IN :orderIds LIMIT 2];
        for(Order__c o : orders){
            QuoteAndOrderNotificationsUtil.orderTriggerfirstRun = true;
            o.status__c = 'Approved';
			update o;
        } 
        for(Order__c o : orders){
            QuoteAndOrderNotificationsUtil.orderTriggerfirstRun = true;
            o.status__c = 'Completed';
			update o;
        }
		*/
        
        Order_Line_Item__c orderLine = [SELECT id, Order__c, Contract_Line_Update_Status__c 
                                                 FROM Order_Line_Item__c 
                                                 WHERE 
                                        			// Order__r.Status__c = 'Submitted' AND 
                                        		Contract_Line_Update_Status__c IN ('Drop', 'Downsize', 'Reinstate') LIMIT 1];
        Order__c order = [SELECT id, Name, status__c  from Order__c WHERE Id = :orderLine.Order__c LIMIT 1];
        
        QuoteAndOrderNotificationsUtil.orderTriggerfirstRun = true;
        order.status__c = 'Approved';
        update order;

        QuoteAndOrderNotificationsUtil.orderTriggerfirstRun = true;
        order.status__c = 'Completed';
        update order;
        Test.stopTest();
    }
    
    @future
    public static void setupTestData(){
        Group qGroup = [SELECT Id FROM Group WHERE Name='Quote Approved Notification Group' LIMIT 1]; 
        List<GroupMember> qGroupMemList = [SELECT UserOrGroupId From GroupMember where GroupId =:qGroup.id];
        if(qGroupMemList.isEmpty()){
            GroupMember qgm = new GroupMember(UserOrGroupId=UserInfo.getUserId(), GroupId=qGroup.id);
            insert qgm;
        }
        
        Group oGroup = [SELECT Id FROM Group WHERE Name='Order Completed Notification Group' LIMIT 1]; 
        List<GroupMember> oGroupMemList = [SELECT UserOrGroupId From GroupMember where GroupId =:oGroup.id];
        if(oGroupMemList.isEmpty()){
            GroupMember ogm = new GroupMember(UserOrGroupId=UserInfo.getUserId(), GroupId=oGroup.id);
            insert ogm;
        }
    }
}