/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@isTest
public class TestServicesReadyContactsAPI{
    public static Id accountId;
    public static string lastName = 'TestLast';
    public static string firstName = 'TestFirst';
    public static string phone = '317-000-1111' ;
    public static string mobilePhone = '317-111-0000';
    public static string email = 'test@test.test.test';
    public static string title = 'TESTER';
    public static string callingApplication = Utility.IsSandboxEnvironment() ? 'Salesforce-Dev' : 'Salesforce';    
    public static Id updateId; 
    public static string updlastName = 'UpdTestLast';
    public static string updfirstName = 'UpdTestFirst'; 
    public static string updphone = 'Upd-317-000-1111'; 
    public static string updmobilePhone = 'Upd-317-111-0000'; 
    public static string updtitle = 'UPDATED TESTER';
    public static string updEmail = 'test@test.test2.test';    
    public static string url = system.Url.getSalesforceBaseUrl().toExternalForm();       
    public static string[] conPerms;
    
    public static TestMethod void TestDoInsert()
    { 
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
     
        Test.startTest();
        InsertContact.Result results = InsertContact.doInsert(accountId,
        lastName, 
        firstName, 
        phone, 
        mobilePhone, 
        email, 
        title);
        updateId = results.InsertedId;
        
        System.debug('Results Returned' + results);
        Test.StopTest();
        
        System.assertNotEquals(null, results.InsertedId);
        System.assertNotEquals(0, results.successMessages.size());                  
    }
    
    public static TestMethod void TestDoUpdate()
    {     
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        Test.startTest();
        
        UpdateContact.Result results = UpdateContact.doUpdate(updateId, 
        updlastName, 
        updfirstName, 
        updphone, 
        updmobilePhone, 
        updEmail,
        updtitle);
        
        UpdateContact.Result results2 = UpdateContact.doUpdate(updateId, 
        updlastName, 
        updfirstName, 
        updphone, 
        updmobilePhone, 
        'invalidEmailTest',
        updtitle);
        
        Test.stopTest();
        
        System.debug('Results Returned' + results);
        System.assertNotEquals(0, results.successMessages.size()); 
        System.assertNotEquals(0, results2.failureMessages.size()); 
    }
    
    public static TestMethod void TestGrantPermissions()
    {   
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        conPerms = new string[]{};
        conPerms.Add('IProject');
        conPerms.add('AccountBasic');
        
        Test.startTest();
        
        System.debug('Permissions being granted: ' + conPerms);
        GrantContactPermissions.Result results = GrantContactPermissions.grantPermissions(updateId, 
        conPerms);
        
        Test.stopTest();
        
        System.debug('Results Returned' + results);
        System.assertNotEquals(0, results.successMessages.size());                   
    }
    
    public static TestMethod void TestGrantPermissions2()
    {   
        // Testing granting permissions to a contact that has permissions set already
        // to attempt to force the code coverage down another path in the 
        // contactsreadyapi.grantpermissions method.
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct3.Id;        
        updateId = context.partContact5.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        conPerms = new string[]{};
        conPerms.Add('IProject');
        conPerms.add('AccountBasic');
        
        Test.startTest();
        
        System.debug('Permissions being granted: ' + conPerms);
        GrantContactPermissions.Result results = GrantContactPermissions.grantPermissions(updateId, 
        conPerms);
        
        Test.stopTest();
        
        System.debug('Results Returned' + results);
        System.assertNotEquals(0, results.successMessages.size());                   
    }
    
    public static TestMethod void TestRevokePermissions()
    {   
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        conPerms = new string[]{};
        conPerms.Add('IProject');
        conPerms.add('AccountBasic');
        
        System.debug('Permissions being removed: ' + conPerms);
        
        Test.startTest();
        
        RevokeContactPermissions.Result results = RevokeContactPermissions.revokePermissions(updateId, 
        conPerms);
        
        Test.stopTest();
        
        System.debug('Results Returned' + results);
        System.assertNotEquals(0, results.successMessages.size());                   
    }
    
    public static TestMethod void TestRevokePermissions2()
    {   
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        // Attempt to remove permissions that aren't on the contact.
        conPerms = new string[]{};
        conPerms.Add('MyCloud');
        conPerms.add('Education');
        
        System.debug('Permissions being removed: ' + conPerms);
        
        Test.startTest();
        
        RevokeContactPermissions.Result results = RevokeContactPermissions.revokePermissions(updateId, 
        conPerms);
        
        Test.stopTest();
        
        System.debug('Results Returned' + results);
        System.assertNotEquals(0, results.successMessages.size());                   
    }
    
    
    public static TestMethod void TestCreateLogin() 
    {
        // This method directly tests the CreateLogin method (which is normally to be called
        // by the schedule apex job CreateLoginQueueWorker.
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        TestServicesReadyContactsContext.createLoginQueueEntry(context.partContact1);
        
        conPerms = new string[]{};
        conPerms.Add('IProject');
        conPerms.add('AccountBasic'); 
        
        System.debug('Permissions being granted: ' + conPerms);
        GrantContactPermissions.Result results = GrantContactPermissions.grantPermissions(updateId, conPerms);
        
        List<CreateLoginQueue__c> conQueue = [SELECT Id, ContactId__c, IsProcessed__c, IsError__c FROM CreateLoginQueue__c WHERE ContactId__c =: updateId LIMIT 1];
        System.debug('Contact Queue entry: ' + conQueue[0]);
        
        Contact con = CreateLoginForContact.GetContact(updateId);
        System.debug('Contact object created for contact: ' + updateId + ', ' + con);
        
        ContactAPIMethods contactMethods = new ContactAPIMethods(con, conPerms);
        
        Test.startTest();
        string Response = contactMethods.CreateLogin();
        System.debug('Create Login Response: ' + Response);
        Test.stopTest();
        
        System.assert(!Response.startsWith('Error'), 'FAILED: CreateLogin returned an error: ' + Response);
    }
    
    public static TestMethod void TestCreateLoginForContact()
    {    
        // This method tests the AsyncCreateLogin method.
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        TestServicesReadyContactsContext.createLoginQueueEntry(context.partContact1);
        
        conPerms = new string[]{};
        conPerms.Add('IProject');
        conPerms.add('AccountBasic');
       
        System.debug('Permissions being granted: ' + conPerms);        

        Test.startTest();
        
        CreateLoginForContact.Result results = CreateLoginForContact.CreateLogin(updateId, 
        conPerms);
        
        Test.stopTest();
        
        System.debug('Results Returned' + results);
        System.assertNotEquals(0, results.successMessages.size());                   
    }

    public static TestMethod void TestInsertOrUpdateContactQueue()
    {
        TestAccountContext context = new TestAccountContext();
        accountId = context.partnerAcct1.Id;
        updateId = context.partContact1.Id;
        System.debug('Insert/Update Id: ' + updateId);
        
        Test.startTest();
        
        Contact con = CreateLoginForContact.GetContact(updateId);
        System.debug('Contact object created for contact: ' + updateId + ', ' + con);
        
        ContactAPIMethods contactMethods = new ContactAPIMethods(con, null);
        System.assertNotEquals(null, contactMethods);
        
        List<CreateLoginQueue__c> conQueue = [SELECT Id, ContactId__c, Result__c, IsProcessed__c, IsError__c FROM CreateLoginQueue__c WHERE ContactId__c =: updateId];
        // We have not created a create login queue entry yet, should be none in the list
        System.assertEquals(0, conQueue.size(), 'ERROR: There was already a CreateLoginQueue entry for the contact ' + updateId);
        
        // Insert a contact queue entry for the contact
        string Response = contactMethods.InsertOrUpdateContactQueue(updateId);
        System.debug('Insert contact queue entry response: ' + Response);
        // Now there should be one entry for the contact
        conQueue = [SELECT Id, ContactId__c, Result__c, IsProcessed__c, IsError__c FROM CreateLoginQueue__c WHERE ContactId__c =: updateId];
        System.assertEquals(1, conQueue.size(), 'ERROR: The expected number of CreateLoginQueue entries for the contact was wrong after insert');
        
        // Update a contact queue entry for the contact
        Response = contactMethods.InsertOrUpdateContactQueue(updateId);
        System.debug('Update contact queue entry response: ' + Response);
        // We only updated the entry, so there still should be only one entry
        conQueue = [SELECT Id, ContactId__c, Result__c, IsProcessed__c, IsError__c FROM CreateLoginQueue__c WHERE ContactId__c =: updateId];
        System.assertEquals(1, conQueue.size(), 'ERROR: The expected number of CreateLoginQueue entries for the contact was wrong after update');
        Test.stopTest();
    }
}