@isTest 
public class DeletehistoryAsyncBatchTest
{
    static testMethod void testMethod1()
    {
        
        Delete_History_Object__c del = new Delete_History_Object__c();
        List<Delete_History_Object__c> mylist = new List <Delete_History_Object__c>();
        del.Object_Name__c='OpportunityLineItem';
       del.State__c='Undeleted';
       del.Record_ID__c ='00k220000042XesAAY';
        insert del;
        
        Test.startTest();

            DeletehistoryAsyncBatch obj = new DeletehistoryAsyncBatch();
            Database.QueryLocator ql = obj.start(null);
            obj.execute(null,mylist);
            obj.Finish(null);
            //DataBase.executeBatch(obj); 
           // obj.execute();
            
        Test.stopTest();
    }
}