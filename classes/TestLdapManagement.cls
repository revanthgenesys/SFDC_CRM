@isTest
private class TestLdapManagement {    
    // Create LDAP Login
    static testMethod void TestCreateLogin(){                
        Id contactId = setupContact();
        LdapManagement ldap = new LdapManagement();       
        Test.startTest();
		ldap.CreateLogin(contactId);
        Test.stopTest();
    }
    
    static testMethod void TestMultipleCreateLogin(){                
        List<ID> contactIds = setupMultipleContacts();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.CreateLogins(contactIds);
        Test.stopTest();
    }
    
    static testMethod void TestCreateLoginsAsync(){                
        List<ID> contactIds = setupMultipleContacts();
        Test.startTest();
		LdapManagement.CreateLoginsAsync(contactIds);
        Test.stopTest();
    }
    
	// Update contact
    static testMethod void TestUpdateLogin(){                
        Id contactId = setupContact();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.UpdateLogin(contactId);
        Test.stopTest();
    }
    
    static testMethod void TestMultipleUpdateLogin(){                
        List<ID> contactIds = setupMultipleContacts();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.UpdateLogins(contactIds);
        Test.stopTest();
    }
    static testMethod void TestUpdateLoginsAsync(){                
        List<ID> contactIds = setupMultipleContacts();
        Test.startTest();
		LdapManagement.UpdateLoginsAsync(contactIds);
        Test.stopTest();
    }
	// Update permissions
    static testMethod void TestUpdatePermissions(){            
        Id contactId = setupContact();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.UpdatePermissions(contactId);        
        Test.stopTest();
    }
    
    static testMethod void TestMultipleUpdatePermissions(){                
        List<ID> contactIds = setupMultipleContacts();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.UpdatePermissions(contactIds);
        Test.stopTest();
    }
    
    static testMethod void TestUpdatePermissionsAsync(){                
        List<ID> contactIds = setupMultipleContacts();
        Test.startTest();
		LdapManagement.UpdatePermissionsAsync(contactIds);
        Test.stopTest();
    }
    
	// Reset Password
    static testMethod void TestResetPassword(){          
        Id contactId = setupContact();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.ResetPassword(contactId);        
        Test.stopTest();
    }
    
    static testMethod void TestMultipleResetPassword(){           
        List<ID> contactIds = setupMultipleContacts();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.ResetPasswords(contactIds);
        Test.stopTest();
    }
    
	// Delete contact
    static testMethod void TestDeleteLogin(){                
        Id contactId = setupContact();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.DeleteLogin(contactId);        
        Test.stopTest();
    }
    
    static testMethod void TestMultipleDeleteLogin(){        
        List<ID> contactIds = setupMultipleContacts();
        LdapManagement ldap = new LdapManagement();
        Test.startTest();
		ldap.DeleteLogins(contactIds);
        Test.stopTest();
    }

    static testMethod void TestDeleteLoginsAsync(){        
        List<ID> contactIds = setupMultipleContacts();
        Test.startTest();
		LdapManagement.DeleteLoginsAsync(contactIds);
        Test.stopTest();
    }

    private static Id setupContact(){
        Account acc = setupAccount();
        Insert acc;
        Contact con = ContactFactory.CreateContact('Test');
        con.AccountId = acc.Id;
        Insert con;
        return con.Id;
    }
    
    private static List<Id> setupMultipleContacts(){   
        Account acc = setupAccount();
        Insert acc;
        List<ID> contactIds = new List<ID>();
        List<Contact> contacts = new List<Contact>();
        Contact con;
        for (integer i = 1; i < 5; i++){
        	con = ContactFactory.CreateContact('Test' + i);
            con.AccountId = acc.Id;
            contacts.add(con);
        }
        Insert contacts;
        
        for (Contact c : contacts){
            contactIds.add(c.Id);
        }
        return contactIds;
    }
    
    private static Account setupAccount(){
        List<General_Custom_Settings__c> settings = GeneralCustomSettingFactory.CreateDefaultCustomSettings();
        Insert settings;
		
        AX_Legal_Entity__c defaultEntity = AxLegalEntityFactory.CreateDefaultEntity();
        insert defaultEntity;
        
        Account acc = AccountFactory.CreateProspectAccount('Holding Account');
        return acc;
    }
}