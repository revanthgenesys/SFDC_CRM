@isTest(seeAllData=true)
public class Partner_TestUtil {

  public static List<Account> createAccounts( Integer numToInsert, Boolean doInsert ) {
    List<Account> accounts = new List<Account>();
        for( Integer i=0; i < numToInsert; i++ ) {
            Account a = new Account( Name='Partner Account', Status__c = 'Active' );            
            accounts.add( a );
        }
        
        if( doInsert )
            insert accounts;
        return accounts;
    }

    public static List<partner_portal_prospect__c> createPartenrOpps( Integer numToInsert, Boolean doInsert ) {
    List<partner_portal_prospect__c> opps = new List<partner_portal_prospect__c>();
       
        for( Integer i=0; i < numToInsert; i++ ) {
            partner_portal_prospect__c pOpp = new partner_portal_prospect__c( Name='Test Account', Status__c = 'Request Submitted' );            
            opps.add(pOpp );
        }
        
        if(doInsert)
        insert opps ;
        return opps ;
    }
    
    Public static List<Contact>  createContacts(Integer numToInsert, Boolean doInsert,Account acnt) {
    List<Contact> cnts = new List<Contact>();        
    for(Integer i=0; i < numToInsert; i++ )
    {
      Contact contact1 = new Contact(FirstName = 'Test', 
                                      Lastname = 'Test',
                                      AccountId = acnt.id,
                                      Email = 'test@test.com');	
      cnts.add(contact1);
    }
     if(doInsert)
     insert cnts ;
     return cnts ;
   }
   
    Public static List<User>  createGoldPortalUsers(Integer numToInsert, Boolean doInsert,Contact cnt) {
    List<User> users = new List<User>();
    for(Integer i=0; i < numToInsert; i++ )
    {
       Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Custom Gold Partner User' Limit 1];
       User user1 = new User(
            Username = 'test12345test@test.com',
            ProfileId = portalProfile.Id,
            contactId = cnt.id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Kumar',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
      );
      users.add(user1);
    }
     if(doInsert)
     insert users ;
     return users ;
   }
}