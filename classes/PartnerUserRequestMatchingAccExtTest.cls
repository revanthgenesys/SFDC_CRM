@isTest(seeAllData=true)
private class PartnerUserRequestMatchingAccExtTest {

    static testMethod void myUnitTest() {
        Partner_User_Request__c newRequest = new Partner_User_Request__c();
        newRequest.First_Name__c = 'Test';
        newRequest.Create_New_Account__c = true;
        newRequest.Email__c = 'test@testHello.com';
        insert newRequest;
        PartnerUserRequestMatchingAccExtension obj = new PartnerUserRequestMatchingAccExtension(new ApexPages.StandardController(newRequest));
        newRequest.Create_New_Account__c = true;
        update newRequest;
        newRequest.Partner_Portal_Access__c = 'New User Access';
        update newRequest;
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Name = 'Test Nick';
        insert testAccount;
        newRequest.Company_Name__c = testAccount.Name;
        update newRequest;
        PartnerUserRequestMatchingAccExtension obj1 = new PartnerUserRequestMatchingAccExtension(new ApexPages.StandardController(newRequest));
        
    }
    
    static testMethod void myUnitTest1() {
        RecordType objRecType = [Select id from RecordType where name =: 'EMG - Customer Record Type'];
        User objUser = TestUtil.createUsers(1,false)[0];
        objUser.email = 'aa@aa.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name =: 'GEN - Genesys Care Ops'];     
        objUser.ProfileId = prof.Id;
        insert objUser;
    
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Name = 'Test Nick';
        testAccount.RecordTypeid = objRecType.id;
        testAccount.Status__c = 'Active';
        insert testAccount;
        
        Contact objCon = TestUtil.createContacts(1,testAccount,false)[0];
        objCon.email = 'aa@aa.com';
        insert objCon;
        
        Country__c cntry = [Select Id,Name from Country__c where id='a06U0000000ugaxIAA'];
        
        Partner_User_Request__c newRequest = new Partner_User_Request__c();
        newRequest.First_Name__c = 'Test';
        newRequest.Account_Name__c = testAccount.id;
        newRequest.Create_New_Account__c = false;
        newRequest.Create_New_Contact__c = false;
        newRequest.Company_Name__c = testAccount.Name;
        newRequest.Partner_Portal_Access__c = 'Existing Partner User Access';//'Full Portal Access';
        newRequest.Country__c = cntry.id;
        newRequest.Email__c = 'aa@aa.com';
        newRequest.Duplicate_Account__c = testAccount.id;
        newRequest.Contact_Name__c = objCon.id;
        newRequest.Duplicate_Contact__c = objCon.id;
        newRequest.Status__c= 'Approved';
        insert newRequest;
        
        PartnerUserRequestMatchingAccExtension obj = new PartnerUserRequestMatchingAccExtension(new ApexPages.StandardController(newRequest));
        obj.selectedAccountId = 'a';
        obj.selectedContactId = 'sADs';
        obj.renderAccounts = true;
        obj.renderContacts = true;
        obj.noAccountMsg = '';
        obj.noContactMsg = '';
        obj.newusercheckBox = true;
        
        obj.updatePartnerAccess();
        obj.updateUserAcntDetails();
        obj.updateUserCntDetails();
        
        obj.partnerUserRequest = newRequest;
        obj.updatePUR();
        obj.sendEmail();
        obj.closeEmailPopup();
        obj.showEmailPopup();
        obj.closeRejectPopup();
        obj.showRejectPopup();
        //obj.rejectPur();        
        //obj.createNewAccount();
        
        newRequest.Create_New_Account__c = true;
        newRequest.Create_New_Contact__c = true;
        update newRequest;
        
        obj.createNewAccount();
        //obj.createNewContact(); 
               
        /*newRequest.Status__c = 'Approved';
        newRequest.Last_Name__c = 'Test';
        newRequest.Email__c = 'test@test.com';
        newRequest.First_Name__c = 'Test';
        update newRequest;*/
    }
}