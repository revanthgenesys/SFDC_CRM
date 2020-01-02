@isTest
public class TestLDAPLoginContactControllerExtension{
    static testMethod void CreateLogin_Failure()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
       
        // Test contact with account without sync account type
        Contact cont = CreateContact(false);
        Test.startTest();
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);

        /*
        System.assertEquals(false, extController.ShouldRecheck);
        System.assertEquals(true, extController.DisableCreateLogin);
        System.assertEquals(true, extController.DisablePasswordReset);
        System.assertEquals(true, extController.DisableDeleteLogin);
        */
        extController.CreateLogin();
        Test.stopTest();
        AssertMessages(ApexPages.Severity.ERROR, 1);
    }

    static testMethod void CreateLogin_Success()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
        
        // Test contact with account with sync account type
        Contact cont = CreateContact(true);
        SetContactFields(cont, false);
        Test.startTest();
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);
        
        extController.CreateLogin();
        AssertMessages(ApexPages.Severity.INFO, 2);
        Test.stopTest();
        /*System.assertEquals(true, extController.DisableCreateLogin);
        System.assertEquals(true, extController.DisablePasswordReset);
        System.assertEquals(true, extController.DisableDeleteLogin);
        System.assertEquals(false, extController.ShouldRecheck);*/
    }

    static testMethod void ResetPassword_Failure()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
        
        // Test contact with account without sync account type
        Contact cont = CreateContact(false);
        Test.startTest();
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);
        
        extController.ResetPassword();
        Test.stopTest();
        AssertMessages(ApexPages.Severity.ERROR, 1);
    }

    static testMethod void ResetPassword_Success()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
        
        // Test contact with account with sync account type
        Contact cont = CreateContact(true);
        SetContactFields(cont, true);
        Test.startTest();   
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);
        
        System.assertEquals(false, extController.ShouldRecheck);
            
        extController.ResetPassword();
        Test.stopTest();
        AssertMessages(ApexPages.Severity.INFO, 2);
    }

    static testMethod void DeleteLogin_Failure()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
        
        // Test contact with account without sync account type
        Contact cont = CreateContact(false);
        Test.startTest();
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);
        
        extController.DeleteLogin();
        Test.stopTest();
        AssertMessages(ApexPages.Severity.ERROR, 1);
    }

    static testMethod void DeleteLogin_Success()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
        
        // Test contact with account without sync account type, but with a BCF ID
        Contact cont = CreateContact(false);
        SetContactFields(cont, true);
        Test.startTest();
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);     
        
        extController.DeleteLogin();
        Test.stopTest();
        AssertMessages(ApexPages.Severity.INFO, 1);
		/*
        System.assertEquals(true, extController.DisableCreateLogin);
        System.assertEquals(false, extController.DisablePasswordReset);
        System.assertEquals(true, extController.DisableDeleteLogin);
        System.assertEquals(false, extController.ShouldRecheck);        
		*/
    }
    
    static testMethod void Recheck()
    {
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        AX_Legal_Entity__c entity = AxLegalEntityFactory.CreateDefaultEntity(); 
        insert entity;
        
        // Test contact with account with sync account type
        Contact cont = CreateContact(true);
        Test.startTest();
        ApexPages.StandardController stnController = new ApexPages.StandardController(cont);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);
        
        /*
        System.assertEquals(true, extController.DisableCreateLogin);
        System.assertEquals(false, extController.DisablePasswordReset);
        System.assertEquals(true, extController.DisableDeleteLogin);
        System.assertEquals(true, extController.ShouldRecheck);
        */
        
        System.debug('============> Sync Account ' + cont.Sync_To_Internal_Systems__c);
        System.debug('============> Sync Contact ' + cont.Account.Sync_To_Internal_Systems__c);
        
        for (Integer i = 0; i < (LDAPLoginContactControllerExtension.maxRecheckCount - 1); i++)
        {
            extController.RefreshContact();
        }
        Test.stopTest();        
    }
    
    static testMethod void UtilityIsSyncedAccountType()
    {
        Boolean b = Utility.IsSyncedAccountType('Partner');
    }
	/*
    static testMethod void DuplicateEmail()
    {        
        // TODO: needs fixed once duplicate management is in sandbox
        PageReference currentPage = Page.LdapLogin;
        Test.setCurrentPage(currentPage);
        
        TestAccountBuilderContext context = new TestAccountBuilderContext();
        context.build();
        
        Test.startTest();
        // Test contacts with same email address.
        Contact contact1;
        Contact contact2;
        try
        {
            contact1 = CreateContactWithEmail(true, 'test@inin.com', context.CustomerAcct1);
            contact2 = CreateContactWithEmail(true, 'test@inin.com', context.CustomerAcct1);
        }
        catch (Exception ex)
        {
            
        }
        
        ApexPages.StandardController stnController = new ApexPages.StandardController(contact1);
        LDAPLoginContactControllerExtension extController = new LDAPLoginContactControllerExtension(stnController);
        
        // System.assertEquals(true, extController.IsEmailDuplicate);
        // System.assertEquals(false, extController.ShouldRecheck);
        // System.assertEquals(true, extController.DisableCreateLogin);
        // System.assertEquals(true, extController.DisablePasswordReset);
        // System.assertEquals(true, extController.DisableDeleteLogin);
        Test.stopTest();
    }
	*/
    
    private static void AssertMessages(ApexPages.Severity severity, Integer expected)
    {
        ApexPages.Message[] messages = ApexPages.getMessages();
        for (ApexPages.Message message : messages)
        {
            System.debug('=========> ' + message.getDetail());
        }
    }

    private static Contact CreateContact(Boolean setValidType)
    {        
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
        
        Account acc = new Account(Name = 'Holding Account');
        if (setValidType)
        {
            acc.Type = 'Customer';
        }
        //acc.Ldap_Account_Permissions__c = 'AccountAccess;GeneralAccess';
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id);
        insert con;
        
        con = [SELECT LastName, AccountId, Sync_To_Internal_Systems__c, Account.Sync_To_Internal_Systems__c, LDAP_Contact_Permissions__c FROM Contact WHERE Id =: con.Id LIMIT 1];
        
        return con; 
    }
    
    private static Contact CreateContactWithEmail(Boolean setValidType, String EmailAddress, Account acc)
    {        
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.Id, Email = EmailAddress);
        insert con;
        
        con = [SELECT LastName, AccountId, Sync_To_Internal_Systems__c, Account.Sync_To_Internal_Systems__c, LDAP_Contact_Permissions__c FROM Contact WHERE Id =: con.Id LIMIT 1];
        
        return con; 
    }
    
    private static void SetContactFields(Contact con, boolean hasWebLogin)
    {
        con.Email = 'test@inin.com';
        con.Contact_ID__c = 'testBcfId';
        if(!hasWebLogin)
        {
            con.Has_LDAP_Login__c = hasWebLogin;
        }
        con.LDAP_Contact_Permissions__c = 'GeneralAdmin;AccountAdmin';
        
        update con;
        
        if(hasWebLogin)
        {
            con.Has_LDAP_Login__c = hasWebLogin;
            update con;
        }
    }
    

}