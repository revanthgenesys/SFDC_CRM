@isTest(SeeAllData=true)
public class GenericPartnerPortalUserCreation_Test {
    
     static testmethod void testContactCreation(){
        List<Account> acct = TestUtil.createAccounts(1,false);
        insert acct[0];
        GenericPartnerPortalUserCreation.insertPartnerContactAndUser(acct[0].Id);
    }
    static testmethod void testExistingContact(){
        Account acct = TestUtil.createAccounts(1,false)[0];
        insert acct;
        Contact contact = new Contact(AccountId = acct.Id, FirstName = 'Test', LastName = 'User', Email = Label.Generic_Portal_User_Email);
        insert contact;
        GenericPartnerPortalUserCreation.insertPartnerContactAndUser(acct.Id);
    }
}