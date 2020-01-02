@isTest
private class ContactOfferingTypeAsync_Test{
    static testmethod void testSC(){
        List<Account> list_Acc = new List<Account>();
        list_Acc.add(new Account(Type = 'Customer', Name='Test Account', Status__c = 'Active'));
        list_Acc.add(new Account(Type = 'Customer', Name='Test Account2', Status__c = 'Active', Offering_Type__c = 'PureEngage Premise'));
        list_Acc.add(new Account(Type = 'Customer', Name='Test Account3', Status__c = 'Active'));
        insert list_Acc;
        
        List<Contact> list_Contact = new List<Contact>();
        list_Contact.add(new Contact(LastName = 'Test 1', Email = 'test1@test.com', AccountId = list_Acc.get(0).Id));
        list_Contact.add(new Contact(LastName = 'Test 2', Email = 'test2@test.com', AccountId = list_Acc.get(1).Id));
        list_Contact.add(new Contact(LastName = 'Test 3', Email = 'test3@test.com', AccountId = list_Acc.get(2).Id));
        insert list_Contact;
        
        list_Acc.get(0).Offering_Type__c = 'PureEngage Premise';
        list_Acc.get(1).Offering_Type__c = null;
        list_Acc.get(2).Offering_Type__c = 'PureEngage Premise;PureConnect Cloud';
        Test.startTest();
        update list_Acc;
        Set<Id> set_AccountId = new Set<Id>{list_Acc.get(0).Id, list_Acc.get(1).Id, list_Acc.get(2).Id};
        ContactOfferingTypeAsync.processRecords(set_AccountId);
        Test.stopTest();
    }
}