@isTest(SeeAllData=true)
public class Marketing_Connect_Test {

static testMethod void testSearchComponent() {
 
 Marketing_Content__c mc = new Marketing_Content__c ();
 mc.Type__c = 'News';
 mc.Active__c = true;
 Test.startTest();
 insert mc;
 Marketing_Connect obj = new Marketing_Connect();
 Test.stopTest();
}
}