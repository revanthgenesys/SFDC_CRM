/*
* Class Name       : trgEmailNotificationOnOrderCompletedTest 
* Description      : Test class for trgEmailNotificationOnOrderCompleted. 
* ***************************************************************************************************************
* Developer Note   : *
* ***************************************************************************************************************
*/
@isTest(SeeAllData=true)
private class trgEmailNotificationOnOrderCompletedTest {
    
    static testMethod void trgEmailNotificationOnOrderCompleted_TestMethod() {
        Test.startTest();
        Order__c objTestOrder = [SELECT id from Order__c
                                 WHERE Order_Category__c = 'PureEngage - On Premise'
                                 AND status__c != 'Completed'
                                 AND Order_lines_Count__c > 0
                                 Order by lastmodifieddate limit 1];
        
        Order_Line_Item__c objOrderLine = [SELECT id from Order_Line_Item__c
                                           WHERE Order__c = :objTestOrder.id limit 1];
        objOrderLine.Contract_Line_Update_Status__c = 'Reinstate';
        update objOrderLine;
                                           
        objTestOrder.status__c = 'Completed';
        update objTestOrder;
        Test.stopTest();
    }
}