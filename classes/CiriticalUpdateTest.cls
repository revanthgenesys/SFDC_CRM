//04/21/2014	Naresh Kumar
@isTest(seeAllData = true)
private class CiriticalUpdateTest {
    static testMethod void myUnitTest() {
        Critical_Account__c newCA = new Critical_Account__c();
        newCA.Name = 'Test CA';
        newCA.Status__c = 'Open';
        newCA.update__c = 'this is update text';
        insert newCA;
        Critical_Account_Updates__c newCAU = new Critical_Account_Updates__c();
        newCAU.Critical_Account__c = newCA.id;
        newCAU.Update__c = 'this is update text on CAU.';
        insert newCAU;
    }
}