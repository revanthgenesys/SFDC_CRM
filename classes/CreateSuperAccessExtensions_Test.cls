@isTest
private class CreateSuperAccessExtensions_Test {

    static testMethod void myUnitTest() {
        Util.Bypass_Trigger_Chk = true;
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testCont = TestUtil.createContacts(1, testAccount, false)[0];
        testCont.Email = 'testUserCSAE@test.com';
        insert testCont;
        Support_Access__c testSA = new Support_Access__c();
        
        Back_Office_Account__c boa = new Back_Office_Account__c (End_User_Account__c = testAccount.id,
                                          Sold_To_Account__c = testAccount.id);
        insert boa;                                  
       
        testSA.Contact__c = testCont.id;
        testSA.Back_Office_Account__c = boa.Id;
        testSA.End_User_Account__c = testAccount.id;
        testSA.Sold_To_Account__c = testAccount.id;
        testSA.SR_Access_Level__c = 'Read/Write';
        testSA.Status__c = 'Active';
        insert testSA;
                 
        PageReference pageRef = ApexPages.currentPage();
		pageRef.getParameters().put('contactId', testCont.id);
		pageRef.getParameters().put('retURL', '/fffffffff');
			
		ApexPages.StandardController sc = new ApexPages.StandardController(testSA);			
		CreateSuperAccessExtensions ext  = new CreateSuperAccessExtensions(sc);	
         
         String acc = ext.endUserAccName;
         String st = ext.soldToAccName;
         String stid = ext.soldToAccId;
         String fs = ext.fields;
         String q = ext.query;
         
         ext.showInactive = true;
         Boolean inl = ext.isContactIdNull;
         ext.accounts = new List<Account>{testAccount};
         
         ext.getServiceContracts();
         
         ext.next();
         ext.save();
         ext.test();
         ext.cancel();
        
     
    }
}