//Naresh Kumar	07/15/2017
@IsTest(SeeAllData=true)
public class DealQualificationDetailController_Test {
    static testMethod void testMethod1() {
        
        Id profileId = [SELECT id FROM profile WHERE name = 'Custom Gold Partner'].id;
       
        Account ac = new Account(name ='Test Acc') ;
        insert ac; 
        
        
       
        Contact con = new Contact(LastName ='testCon', AccountId = ac.Id);
        insert con;  
                  
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                ContactId = con.Id,
                timezonesidkey='America/Los_Angeles', username='DealQualificationDetailController_Test@test.com');
       
        insert user;
        system.runAs(user) {
            Account ac1 = new Account(name ='Test Acc 1') ;
        	insert ac1; 
            
            // statements to be executed by this test user.
            Opportunity testOpp = TestUtil.createOpportunities(1, false)[0];
            testOpp.Partner_Opportunity_Status__c = 'Approved';
            testOpp.Lines_of_Businesses__c = 'PureConnect';
            testOpp.BusinessPartner__c = ac1.id;
            insert testOpp;
            
            Deal_Qualification__c testDQ = new Deal_Qualification__c();
            testDQ.Opportunity__c = testOpp.id;
            insert testDQ;
            Test.startTest();         
            ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
            DealQualificationDetailController objController = new DealQualificationDetailController(strCtrl);	
            Test.stopTest();
        }
    }
    
    static testMethod void testMethod2() {
        // statements to be executed by this test user.
        Opportunity testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.Partner_Opportunity_Status__c = 'Approved';
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        insert testOpp;
            
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        testDQ.Opportunity__c = testOpp.id;
        insert testDQ;
        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        DealQualificationDetailController objController = new DealQualificationDetailController(strCtrl);	
        Test.stopTest();        
    }
    
}