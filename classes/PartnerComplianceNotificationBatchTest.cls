@isTest(seeAllData=true)
private class PartnerComplianceNotificationBatchTest {
    static void setupData(){
        Contact con = [SELECT Id, Name, AccountId, Account.Name from Contact where Designated_Partner_Contact__c = true LIMIT 1];
        EmailTemplate et = [Select id, Name FROM EmailTemplate WHERE Name LIKE 'Partner Compliance%' limit 1];
        Partner_Notification__c partnerNotif = new Partner_Notification__c(Account__c = con.AccountId, Account_Name__c = con.Account.Name, Email_Template__c = et.Name, Processed__c = false);
        insert partnerNotif;
    }
    static testMethod void testPartnerComplianceNotificationBatch1(){
        setupData();
        Database.executeBatch(new PartnerComplianceNotificationBatch(false, null), 1);
    } 
    static testMethod void testPartnerComplianceNotificationBatch2(){
        setupData();
        List<String> emailIds = new List<String>{'test@test.com', 'test2@test.com'};
        Database.executeBatch(new PartnerComplianceNotificationBatch(true, emailIds), 1);
    } 
}