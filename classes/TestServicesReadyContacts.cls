/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@isTest
public class TestServicesReadyContacts{
    public static Id accountId;
    public static string lastName = 'TestLast';
    public static string firstName = 'TestFirst';
    public static string phone = '317-000-1111' ;
    public static string mobilePhone = '317-111-0000';
    public static string email = 'test@test.com';
    public static string title = 'TESTER';
    public static string callingApplication = Utility.IsSandboxEnvironment() ? 'Salesforce-Dev' : 'Salesforce';    
    public static Id updateId; 
    public static string updlastName = 'UpdTestLast';
    public static string updfirstName = 'UpdTestFirst'; 
    public static string updphone = 'Upd-317-000-1111'; 
    public static string updmobilePhone = 'Upd-317-111-0000'; 
    public static string updtitle = 'UPDATED TESTER';
    public static string url = system.Url.getSalesforceBaseUrl().toExternalForm();       
    
    public static TestMethod void TestDoInsert()
    { 
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
     
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('___---*** Test Contact Permission Entry: ' + permissionMap + ' ****************************');
        
        Test.startTest();
        ServicesReadyContactInserter.Result results = ServicesReadyContactInserter.doInsert(accountId,
        lastName, 
        firstName, 
        phone, 
        mobilePhone, 
        email, 
        title);
        updateId = results.InsertedId;
        Test.stopTest();
        System.debug('___---*** Results Returned' + results + ' ****************************');
        
        System.assertNotEquals(null, results.InsertedId);
        System.assertNotEquals(0, results.successMessages.size());                  
    }
    
    public static TestMethod void TestDoUpdate()
    {     
        TestAccountContext context = new TestAccountContext();  
        accountId = context.PartnerAcct1.Id;        
        updateId = context.partContact1.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('___---*** Test Contact Permission Entry: ' + permissionMap + ' ****************************');
        
        Test.startTest();
        ServicesReadyContactUpdater.Result results = ServicesReadyContactUpdater.doUpdate(updateId, 
        updlastName, 
        updfirstName, 
        updphone, 
        updmobilePhone, 
        updtitle);
        Test.stopTest();
        System.debug('___---*** Results Returned' + results + ' ****************************');
        System.assertNotEquals(0, results.successMessages.size());                   
    }
    
    public static TestMethod void TestCreateLogin()
    {
        TestAccountContext context = new TestAccountContext();
        accountId = context.PartnerAcct3.Id;
        updateId = context.partContact5.Id;
        System.debug('Update Id: ' + updateId);
        
        //Insert a record into ServicesReadyContactPermission__c table so that it can be added to the test contact        
        ServicesReadyContactPermission__c permissionMap = TestServicesReadyContactsContext.contactPermissionEntry;  
        System.debug('Test Contact Permission Entry: ' + permissionMap);
        
        TestServicesReadyContactsContext.createLoginQueueEntry(context.partContact5);
        System.debug('Created Login Queue entry for contact: ' + updateId);
        Contact con = (Contact)context.partContact5;
        con.Contact_ID__c = updateId; // prevent contact id error in CreateLogin
        ServicesReadyContactMethods servicesContact = new ServicesReadyContactMethods(con);
        System.debug('Created ServicesReadyContactMethods instance for contact: ' + updateId);
        
        Test.startTest();
        // The following are executed for code coverage since the above test methods have not 
        // covered every path.
        // Update the account permissions using an account that already has ldap perms set
        servicesContact.UpdateAccountPermissions(accountId);
        System.debug('Updated account perms for account: ' + accountId);
        // Update permissions for the contact that already has ldap perms set
        servicesContact.SetPermissionsAndUpdate();
        System.debug('Updated contact perms for contact: ' + updateId);
        // Created login queue entry already above, so call the method to update it
        string Response = servicesContact.InsertOrUpdateContactQueue(updateId);
        System.debug('Updated Login Queue entry for contact: ' + updateId + ' with response: ' + Response);
        
        // Now test the CreateLogin method
        Response = servicesContact.CreateLogin();
        System.debug('Create Login returned with response: ' + Response);
        System.assert(Response.toLowerCase().Contains('successfully'), 'ERROR: login could not be created for contact');
        
        Test.stopTest();
        
    }
}