@isTest
public class TestDemoRequestTriggers {
    
    static testMethod void ValidateNotifyNonDeclinedUpdateNoDeclines(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tsc = new List<User>();
        List<User> tsm = new List<User>();
		System.runAs(thisUser) {
            tsc = DemoRequestFactory.CreateTscTestUsers(7);
            tsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tsc, tsm);
        DemoRequestFactory.InitializeData();
        
		//Users to test with
        //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
            
            request = [SELECT Id, State__c, Demo_Date_Time__c FROM Demo_Request__c];
            for(Demo_Request__c d : request){
                d.NotifyNonDeclined__c = true;
            }
            update request;
            
            for(Demo_Request__c d : [SELECT Id, NotifyNonDeclined__c FROM Demo_Request__c]){
                System.assert(d.NotifyNonDeclined__c, 'The request did not update the NotifyNonDeclined__c flag as expected.');
            }
        }
    }
    
    static testMethod void ValidateNotifyNonDeclinedUpdateWithDeclines(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tsc = new List<User>();
        List<User> tsm = new List<User>();
		System.runAs(thisUser) {
            tsc = DemoRequestFactory.CreateTscTestUsers(7);
            tsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tsc, tsm);
        DemoRequestFactory.InitializeData();
        
		//Users to test with
        //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
            
            TestDemoRequestClass.DeclineRequest(request, new List<Id>{tscTest.Id}, '', null);
            
            request = [SELECT Id, State__c, Demo_Date_Time__c FROM Demo_Request__c];
            for(Demo_Request__c d : request){
                d.NotifyNonDeclined__c = true;
            }
            update request;
            
            for(Demo_Request__c d : [SELECT Id, NotifyNonDeclined__c FROM Demo_Request__c]){
                System.assert(d.NotifyNonDeclined__c, 'The request did not update the NotifyNonDeclined__c flag as expected.');
            }
        }
    }

}