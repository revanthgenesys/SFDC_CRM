@isTest
public class BatchUpdateAccountOfferingType_Test{

    static testMethod void BatchUpdateAccountOfferingType_unitTest(){
        
        Id emgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('EMG - Customer Record Type').getRecordTypeId();
        
        Account acc = new Account();
        acc.name = 'Test';
        acc.recordTypeId = emgRecordTypeId;
        insert acc;
        
        Account acc1 = new Account();
        acc1.name = 'Test';
        acc1.recordTypeId = emgRecordTypeId;
        insert acc1;
        
        Contact con = new Contact();
        con.lastname = 'test contact';
        con.accountId = acc.id;
        insert con;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, true)[0];
        
        List<ServiceContract> list_SC = new List<ServiceContract>();
        
        ServiceContract testSC = TestUtil.createServiceContracts(1, false)[0];
        testSC.Agreement_Status__c = 'Active';
        testSC.Override_Offering_Type__c = 'PureEngage';
        testSC.End_User_Name__c = acc.id;
        testSC.Sold_To_Name__c =acc1.id;
        testSC.AccountId = acc.id;
        list_SC.add(testSC);
        
        ServiceContract testSC1 = TestUtil.createServiceContracts(1, false)[0];
        testSC1.Agreement_Status__c = 'Active';
        testSC1.Override_Offering_Type__c = 'PureEngage';
        testSC1.End_User_Name__c = acc.id;
        testSC1.Sold_To_Name__c =acc.id;
        testSC1.AccountId = acc.id;
        list_SC.add(testSC1);
        
        ServiceContract testSC2 = TestUtil.createServiceContracts(1, false)[0];
        testSC2.Agreement_Status__c = 'Closed';
        testSC2.Override_Offering_Type__c = 'PureEngage';
        testSC2.End_User_Name__c = acc.id;
        testSC2.AccountId = acc.id;
        testSC2.Sold_To_Name__c =acc.id;
        list_SC.add(testSC2);
        
        ServiceContract testSC3 = TestUtil.createServiceContracts(1, false)[0];
        testSC3.Agreement_Status__c = 'Closed';
        testSC3.Override_Offering_Type__c = 'PureEngage';
        testSC3.End_User_Name__c = acc.id;
        testSC3.Sold_To_Name__c =acc1.id;
        testSC3.AccountId = acc.id;
        list_SC.add(testSC3);
        
        insert list_SC;
        
        List<Cloud_Deployment__c> list_CD = new List<Cloud_Deployment__c>();
        Cloud_Deployment__c deplTo = new Cloud_Deployment__c();
        deplTo.Support_Status__c = 'Active';
        deplTo.Account__c = acc.id;
        deplTo.Sold_To_Account__c = acc.id;
        deplTo.Status__c = 'Production';
        deplTo.Cloud_Platform__c = 'PureConnect Subscription';   
        list_CD.add(deplTo); 
        
        Cloud_Deployment__c deplTo1 = new Cloud_Deployment__c();
        deplTo1.Support_Status__c = 'Active';
        deplTo1.Account__c = acc1.id;
        deplTo1.Sold_To_Account__c = acc.id;
        deplTo1.Status__c = 'Production';
        deplTo1.Cloud_Platform__c = 'Outbound Engagement';   
        list_CD.add(deplTo1);
        
        Cloud_Deployment__c deplTo2 = new Cloud_Deployment__c();
        deplTo2.Support_Status__c = 'InActive';
        deplTo2.Account__c = acc.id;
        deplTo2.Sold_To_Account__c = acc.id;
        deplTo2.Status__c = 'Production';
        deplTo2.Cloud_Platform__c = 'PureEngage Subscription';   
        list_CD.add(deplTo2); 
        
        Cloud_Deployment__c deplTo3 = new Cloud_Deployment__c();
        deplTo3.Support_Status__c = 'InActive';
        deplTo3.Account__c = acc1.id;
        deplTo3.Sold_To_Account__c = acc.id;
        deplTo3.Status__c = 'Production';
        deplTo3.Cloud_Platform__c = 'Premier Edition';   
        list_CD.add(deplTo3);
        
        insert list_CD;
        
        
        Test.startTest();
        BatchUpdateAccountOfferingType bc = new BatchUpdateAccountOfferingType();
        Database.executeBatch(bc);
        Test.stopTest();
        
        Contact newCon = [SELECT Id, Primary_offering__c, Additional_Offering__c, Account.Offering_Type__c FROM Contact WHERE Id =: con.Id];
        System.assert(newCon.Primary_offering__c != null);
    }
}