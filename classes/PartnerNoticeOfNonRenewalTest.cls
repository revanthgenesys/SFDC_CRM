@isTest(seeAllData=true)
public class PartnerNoticeOfNonRenewalTest {

    @isTest
    static void testPartnerNoticeOfNonRenewalBatch(){
        setupTestData();
        Database.executeBatch(new PartnerNoticeOfNonRenewalBatch(), 1);
    } 
    
    static void setupTestData() {
		RecordType accountRT = [SELECT id, Name FROM RecordType WHERE Name = 'Enterprise - Business Partner' LIMIT 1];
        List<Account> testAccounts = new List<Account>();
        testAccounts.add( new Account( Name='Test Account 1', Status__c = 'Active', RecordTypeId = accountRT.id ) );
		testAccounts.add( new Account( Name='Test Account 2', Status__c = 'Active', RecordTypeId = accountRT.id ) );
        insert testAccounts;
        
		RecordType contactRT = [SELECT id, Name FROM RecordType WHERE Name = 'EMG - Customer / Prospect Contact Record Type' LIMIT 1];
        List<Contact> testContacts = new List<Contact>();
        testContacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 1', Email = '001test@genesys.com', accountId = testAccounts[0].id, RecordTypeId = contactRT.id ));
        testContacts.add(new Contact(FirstName = 'Test', LastName = 'Contact 2', Email = '002test@genesys.com', accountId = testAccounts[1].id, RecordTypeId = contactRT.id ));
        insert testContacts;

		List<Partner_Notice_of_Non_Renewal__c> testPartnerNotices = new List<Partner_Notice_of_Non_Renewal__c>();
        testPartnerNotices.add(new Partner_Notice_of_Non_Renewal__c(FirstName__c = 'Test', LastName__c = 'Contact 1', Email__c = '001test@genesys.com', Email_Template__c = 'Partner Notice of Non-Renewal Standard', Account__c = testAccounts[0].id));
        testPartnerNotices.add(new Partner_Notice_of_Non_Renewal__c(FirstName__c = 'Test', LastName__c = 'Contact 2', Email__c = '002test@genesys.com', Email_Template__c = 'Partner Notice of Non-Renewal Non-Standard', Account__c = testAccounts[1].id));
        testPartnerNotices.add(new Partner_Notice_of_Non_Renewal__c(FirstName__c = 'Test', LastName__c = 'Contact 3', Email__c = '003test@genesys.com', Email_Template__c = 'Partner Notice of Non-Renewal Standard', Account__c = testAccounts[0].id));
        testPartnerNotices.add(new Partner_Notice_of_Non_Renewal__c(FirstName__c = 'Test', LastName__c = 'Contact 4', Email__c = '004test@genesys.com', Email_Template__c = 'Partner Notice of Non-Renewal Non-Standard', Account__c = testAccounts[1].id));
        insert testPartnerNotices;
    }
}