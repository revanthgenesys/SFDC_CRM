@isTest
public class FailedOperationRecovery_Test {
    
    static TestMethod void myUnitTest0(){
        util.Bypass_Trigger_Chk=true;
        Order__c ordr = TestUtil.createOrders(1, true)[0];
        util.Bypass_Trigger_Chk=false;
        Failed_Operation_Recovery__c rec = new Failed_Operation_Recovery__c(
            Object_Name__c = ordr.Name,
            Object_Id__c = String.valueOf(ordr.Id),
            Error_Message__c = 'Error updatingcreating CCDB for Order:');                   
        insert rec;
        
        Failed_Operation_Recovery_Settings__c FORS = new Failed_Operation_Recovery_Settings__c();
        FORS.Max_Retry_Attempts__c=10;
        FORS.Wait_Minutes__c=0;
        //FORS.Max_Retry_Attempts__c=60;
        insert FORS;
        
        util.Bypass_Trigger_Chk=true;
        //Order__c ordr1 = TestUtil.createOrders(1, true)[0];
        util.Bypass_Trigger_Chk=false;
        Failed_Operation_Recovery__c rec1 = new Failed_Operation_Recovery__c(
            Object_Name__c = ordr.Name,
            Object_Id__c = String.valueOf(ordr.Id),
            Error_Message__c = 'Error updatingcreating CCDB for Order:');                   
        insert rec1;
        
        util.Bypass_Trigger_Chk=true;
        //Order__c ordr1 = TestUtil.createOrders(1, true)[0];
        //util.Bypass_Trigger_Chk=false;
        Failed_Operation_Recovery__c rec2 = new Failed_Operation_Recovery__c(
            Object_Name__c = ordr.Name,
            Object_Id__c = String.valueOf(ordr.Id),
            Error_Message__c = 'Error updatingcreating CCDB for Order:');                   
        insert rec2;
    }

}