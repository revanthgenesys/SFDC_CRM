@isTest(seeAllData = true)
private class ContactUtil_test {

    static testMethod void myUnitTest() {
        RecordType rType = [SELECT id, Name FROM RecordType WHERE Name = 'Group Account - Customer' LIMIT 1];
        List<Account> testAccounts = TestUtil.createAccounts(2, false);
        testAccounts[0].RecordTypeId = rType.id;
        testAccounts[0].Status__c = 'Active';
        testAccounts[0].Name = 'Test Group Account 1';
        testAccounts[0].Offering_Type__c = 'PureCloud;PureConnect Cloud;PureConnect Premise';
        testAccounts[1].Name = 'Holding Account';
        insert testAccounts;
        
        List<Contact> testContacts = TestUtil.createContacts(2, testAccounts[0], false);
        testContacts[1].AccountId = testAccounts[1].id;
        testContacts[1].is_Created_From_Site__c = true;
        insert testContacts;
        
        testContacts[1].AddToEmailDomain__c = true;
        testContacts[1].AccountId = testAccounts[0].id;
        update testContacts;
        
    }
    
    
    static testMethod void ValidateContactTrainingAccessTest() {
      Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Partner_Program_Status__c = 'Active';
       insert testAccount;
      
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];
        //Profile potenPartnerProfile = [SELECT id FROM Profile WHERE Name = 'Custom Potential Partner User' LIMIT 1];
        
        
        User testUser1 = [SELECT id FROM User WHERE Profile.Name LIKE '%System Admin%' AND isActive = true LIMIT 1];
        User testUser;
        
        System.runAs(testUser1){
            Test.startTest();
            testUser = TestCommon.createUser('tes12', 'testGen0012@test132.com.test', 'testGenUserfname', 'testGenUserlname', partnerProfile.id, false);      
            testUser.ContactId = testContact.id;
            insert testUser;
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = PartnerPortalUtil.PARTNER_PORTAL_PERMISSIONSET_ID, AssigneeId = testUser.Id);
            insert psa;
            testContact.status__c = 'Active';
            testContact.Training_Access__c  = true;
            update testContact;
            
            Map<String, String> mp = ContactUtil.getPortalUserPermissionMap();
            
            Test.stopTest(); 
        
      }
    }
    
     static testMethod void contactTestMethods() {
        
        Util.Bypass_Trigger_Chk = true;
        
        Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];     
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, accnt, true)[0];
        testContact.Has_Ldap_Login__c = true;
        update testContact;
         
        User testUser;  
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);      
        testUser.ContactId = testContact.id;
        insert testUser;

        Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
                                                              Cloud_Platform__c = 'PureCloud', Support_Status__c = 'Active');
        insert cldDep;
            
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
        
        Cloud_Deployment__c cldDep2 = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
                                                              Cloud_Platform__c = 'PureConnect Cloud', Support_Status__c = 'Active');
        insert cldDep2;
            
        Support_Access_Cloud__c sacl = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep2.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read Only');
        insert sacl;
        
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', 
                                                OfferingType__c = 'PureEngage On Premise', IsActive = true);
         insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            ServiceContract servCon = new ServiceContract();
            servCon.Name = 'Test Service Contract';
            servCon.Sold_To_Name__c = accnt.Id;
            servCon.End_User_Name__c = accnt.Id;
            servCon.Agreement_Status__c = 'Active';
            servCon.pricebook2id = pricebookId;     
            insert servCon; 
            
            ContractLineItem cli = new ContractLineItem( ServiceContractId = servCon.Id,
                                                         Quantity = 10, UnitPrice = 100,
                                                         PricebookEntryId = standardPrice.Id,
                                                         Upgraded_Product__c = prod.Id
                                                        );
            insert cli;
            
            Support_Product__c supportProduct = new Support_Product__c(name='Support Prod', 
                                                                        Product_Type__c ='Component',
                                                                        Customer_Available__c = true);
            insert supportProduct;
            
            Back_Office_Account__c testBOA = new Back_Office_Account__c();
            testBOA.End_User_Account__c = accnt.id;
            testBOA.Sold_To_Account__c = accnt.id;
            testBOA.Platform__c = 'PureEngage On Premise';
            insert testBOA;
        
            Back_Office_Account__c testBOA2 = new Back_Office_Account__c();
            testBOA2.End_User_Account__c = accnt.id;
            testBOA2.Sold_To_Account__c = accnt.id;
            testBOA2.Platform__c = 'PureConnect On Premise';
            testBOA2.Support_Package__c = 'Managed Services';
            
            insert testBOA2;

        Support_Access__c sa2 = new Support_Access__c(Back_Office_Account__c = testBOA.Id,
                                                         Contact__c = testContact.id,
                                             Status__c = 'Active', SR_Access_Level__c = 'Read/Write');                                                   
        insert sa2;  
        
        Support_Access__c sa3 = new Support_Access__c(Back_Office_Account__c = testBOA2.Id,
                                                         Contact__c = testContact.id,
                                             Status__c = 'Active', SR_Access_Level__c = 'Read Only');                                                    
        insert sa3;   

        Test.startTest();       
         System.runAs(testUser) {
            Map<String, String> mp = ContactUtil.getPortalUserPermissionMap();
            
            ContactUtil.isGCAPuser(); 
            ContactUtil.currentUserInfo = null;
            ContactUtil.isGCAPuser();
             
            ContactUtil.isSBContact();
            ContactUtil.currentUserInfo = null;
            ContactUtil.isSBContact();
             
            ContactUtil.getUserCloudDepl();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.getUserCloudDepl();
             
            ContactUtil.isCloudUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isCloudUser();

            ContactUtil.isPremiseUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isPremiseUser();

            ContactUtil.isPremiseReadOnlyUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isPremiseReadOnlyUser();

            ContactUtil.isCloudReadOnlyUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isCloudReadOnlyUser();

            ContactUtil.isPortalUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isPortalUser();
            
            ContactUtil.getRWSupprtAccLstByContact(testContact.id);
            ContactUtil.suppAccesses = NULL;
            ContactUtil.getAllActiveSupprtAccLstByContact(testContact.id);
            ContactUtil.getUserContactId();
             
            ContactUtil.getAllActiveCloudDeplByContId(testContact.id); 
            
            Map<String, String> mp1 = ContactUtil.getPortalUserPermissionMap();
         }
         
        Test.stopTest();       
     }
     
      static testMethod void contactTestMethodsBasic() {
        
        Util.Bypass_Trigger_Chk = true;
        
        Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];     
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, accnt, true)[0];
        testContact.Has_Ldap_Login__c = true;
        update testContact;
         
        User testUser;  
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);      
        testUser.ContactId = testContact.id;
        insert testUser;

        Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
                                                              Cloud_Platform__c = 'PureCloud', Support_Status__c = 'Active');
        insert cldDep;
            
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Basic');
        insert sa;
        
        Cloud_Deployment__c cldDep2 = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
                                                              Cloud_Platform__c = 'PureConnect Cloud', Support_Status__c = 'Active');
        insert cldDep2;
            
        Support_Access_Cloud__c sacl = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep2.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Basic');
        insert sacl;
        
        Product2 prod = new Product2 (Name = 'ProdName', ProductCode = 'ProdCode', 
                                                OfferingType__c = 'PureEngage On Premise', IsActive = true);
         insert prod;
            
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = pricebookId, Product2Id = prod.Id,
                UnitPrice = 10000, IsActive = true);
            insert standardPrice;
            
            ServiceContract servCon = new ServiceContract();
            servCon.Name = 'Test Service Contract';
            servCon.Sold_To_Name__c = accnt.Id;
            servCon.End_User_Name__c = accnt.Id;
            servCon.Agreement_Status__c = 'Active';
            servCon.pricebook2id = pricebookId;     
            insert servCon; 
            
            ContractLineItem cli = new ContractLineItem( ServiceContractId = servCon.Id,
                                                         Quantity = 10, UnitPrice = 100,
                                                         PricebookEntryId = standardPrice.Id,
                                                         Upgraded_Product__c = prod.Id
                                                        );
            insert cli;
            
            Support_Product__c supportProduct = new Support_Product__c(name='Support Prod', 
                                                                        Product_Type__c ='Component',
                                                                        Customer_Available__c = true);
            insert supportProduct;
            
            Back_Office_Account__c testBOA = new Back_Office_Account__c();
            testBOA.End_User_Account__c = accnt.id;
            testBOA.Sold_To_Account__c = accnt.id;
            testBOA.Platform__c = 'PureEngage On Premise';
            insert testBOA;
        
            Back_Office_Account__c testBOA2 = new Back_Office_Account__c();
            testBOA2.End_User_Account__c = accnt.id;
            testBOA2.Sold_To_Account__c = accnt.id;
            testBOA2.Platform__c = 'PureConnect On Premise';
            testBOA2.Support_Package__c = 'Managed Services';
            
            insert testBOA2;

        Support_Access__c sa2 = new Support_Access__c(Back_Office_Account__c = testBOA.Id,
                                                         Contact__c = testContact.id,
                                             Status__c = 'Active', SR_Access_Level__c = 'Basic');                                                    
        insert sa2;  
        
        Support_Access__c sa3 = new Support_Access__c(Back_Office_Account__c = testBOA2.Id,
                                                         Contact__c = testContact.id,
                                             Status__c = 'Active', SR_Access_Level__c = 'Basic');                                                    
        insert sa3;   

        Test.startTest();       
         System.runAs(testUser) {
            Map<String, String> mp = ContactUtil.getPortalUserPermissionMap();
            
            ContactUtil.isGCAPuser(); 
            ContactUtil.currentUserInfo = null;
            ContactUtil.isGCAPuser();
             
            ContactUtil.isSBContact();
            ContactUtil.currentUserInfo = null;
            ContactUtil.isSBContact();
             
            ContactUtil.getUserCloudDepl();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.getUserCloudDepl();
             
            ContactUtil.isCloudUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isCloudUser();

            ContactUtil.isPremiseUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isPremiseUser();

            ContactUtil.isPremiseReadOnlyUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isPremiseReadOnlyUser();

            ContactUtil.isCloudReadOnlyUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isCloudReadOnlyUser();

            ContactUtil.isPortalUser();
            ContactUtil.currentUserInfo = null; 
            ContactUtil.isPortalUser();
            
            ContactUtil.getRWSupprtAccLstByContact(testContact.id);
            ContactUtil.suppAccesses = NULL;
            ContactUtil.getAllActiveSupprtAccLstByContact(testContact.id);
            ContactUtil.getUserContactId();
             
            ContactUtil.getAllActiveCloudDeplByContId(testContact.id); 
            
            Map<String, String> mp1 = ContactUtil.getPortalUserPermissionMap();
         }
         
        Test.stopTest();       
     }
    
    
     static testMethod void contactDeleteTest() {
        Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];     
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, accnt, true)[0];
        testContact.Has_Ldap_Login__c = true;
        update testContact;
        Database.delete(testContact.id);
     }
     static testMethod void CheckMainContact() {
        List<Account> list_Acc = TestUtil.createAccounts(2, true);
        List<Contact> list_Contact = TestUtil.createContacts(2, list_Acc[0], true);
        
        list_Contact[0].PureSuccess_Main_Contact__c = true;
        list_Contact[0].IsMasterContact__c = null;//list_Acc[0].id;
        update list_Contact[0];
        
        list_Contact[1].PureSuccess_Main_Contact__c = true;
        list_Contact[1].IsMasterContact__c = null;//list_Acc[0].id;
        //update list_Contact[1];
     }
}