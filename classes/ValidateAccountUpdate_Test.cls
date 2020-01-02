/*
    Naresh Kumar    06/15/2013
    Test class for the main extension class ValidateAccountUpdate.
*/
@isTest(SeeAllData = true)
private class ValidateAccountUpdate_Test {
    static testMethod void myUnitTest() {
        
        Util.Bypass_Trigger_Chk = false;
        
        
        
        Country__c objCoun = [Select id,name from Country__c where name =: 'Canada'];
        
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Status__c = 'Active';
        testAccount.Country__c = objCoun.id;
        testAccount.Type = 'Prospect';
        insert testAccount;
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        testAccount.Status__c = 'Inactive';    
        
        Address__c objAdd = [Select id from Address__c where Account__c =: testAccount.id];
        delete objAdd;
         
        try{update testAccount;}catch(exception e){}
        
        Country__c objCoun2 = [Select id,name from Country__c where name =: 'United States'];
        Account testAccount1 = TestUtil.createAccounts(1, false)[0];
        testAccount1.Status__c = 'Active';
        testAccount.Country__c = objCoun2.id;
        testAccount.Type = 'Partner';
        insert testAccount1;
        Account testAccount2 = TestUtil.createAccounts(1, false)[0];
        testAccount1.ParentId = testAccount1.id;
        insert testAccount2;
        testAccount2.Status__c = 'Inactive';        
        try{update testAccount2;}catch(exception e){}
        
    }
    static testMethod void myUnitTest2() {
        
        Util.Bypass_Trigger_Chk = false;
        
        Country__c objCoun = [Select id,name from Country__c where name =: 'Canada'];
        
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Status__c = 'Active';
        testAccount.Street1__c='test street';
        testAccount.Country__c = objCoun.id;
        testAccount.Type = 'Partner';
        insert testAccount;
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        testAccount.Status__c = 'Inactive';     
        try{update testAccount;}catch(exception e){}
        
        delete testAccount;
        
        Country__c objCoun2 = [Select id,name from Country__c where name =: 'United States'];
        Account testAccount1 = TestUtil.createAccounts(1, false)[0];
        testAccount1.Status__c = 'Active';
        //testAccount.Country__c = objCoun2.id;
        testAccount.Type = 'Partner';
        insert testAccount1;
        delete testAccount1;
        
        Test.startTest();
        Account testAccount2 = TestUtil.createAccounts(1, false)[0];
        testAccount1.ParentId = testAccount1.id;
        insert testAccount2;
        testAccount2.Status__c = 'Inactive';        
        try{update testAccount2;}catch(exception e){}
        
        delete testAccount2;
        
        
        Account testAccount3 = TestUtil.createAccounts(1, false)[0];
        testAccount3.Status__c = 'Active';
        testAccount3.Street1__c='test street';
        testAccount3.Country__c = objCoun.id;
        testAccount3.Type = 'Customer';
        insert testAccount3;
        Contact testContact3 = TestUtil.createContacts(1, testAccount3, true)[0];
        testAccount3.Status__c = 'Inactive'; 
            
        try{update testAccount3;}catch(exception e){}
        
        delete testAccount3;
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3() {
        test.starttest();
        Util.Bypass_Trigger_Chk = false;
        
        Country__c objCoun = [Select id,name from Country__c where name =: 'Canada'];
                
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Status__c = 'Active';
        testAccount.Street1__c='test street';
        testAccount.Country__c = objCoun.id;
        testAccount.Type = 'Prospect';
        insert testAccount;
        
        List<Address__c> list_Add = [Select id from Address__c where Account__c =: testAccount.id];
        delete list_Add;
        
        /*Address__c objAddress = new Address__c();
        objAddress.Address_Type__c='zzz';
        objAddress.Account__c = testAccount.id;
        insert objAddress; */
        
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        testAccount.Status__c = 'Inactive';     
        try{update testAccount;}catch(exception e){}  
        delete testAccount;
        
        
        Account testAccount2 = TestUtil.createAccounts(1, false)[0];
        testAccount2.Status__c = 'Active';
        testAccount2.Street1__c='test street';
        testAccount2.Country__c = objCoun.id;
        testAccount2.Type = 'Partner';
        insert testAccount2;
        
        List<Address__c> list_Add2 = [Select id from Address__c where Account__c =: testAccount2.id];
        delete list_Add2; 
        update testAccount2;
        
        Account testAccount3 = TestUtil.createAccounts(1, false)[0];
        testAccount3.Status__c = 'Active';
        testAccount3.Street1__c='test street';
        testAccount3.Country__c = objCoun.id;
        
        testAccount3.Type = 'Customer';
        insert testAccount3;
        
        List<Address__c> list_Add3 = [Select id from Address__c where Account__c =: testAccount3.id];
        delete list_Add3;
        update testAccount3; 
        test.stoptest();     
    }
}