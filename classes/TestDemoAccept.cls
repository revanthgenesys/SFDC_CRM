@isTest
public class TestDemoAccept {
    
    @testSetup
    static void setup() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tsc = new List<User>();
        List<User> tsm = new List<User>();
		System.runAs(thisUser) {
            tsc = DemoRequestFactory.CreateTscTestUsers(7);
            tsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tsc, tsm);
        DemoRequestFactory.InitializeData();
    }
    
    static testMethod void validateDemoRequestAssign(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];        
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);

        //Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(2, null);
        Integer count = request.size();
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
        }
        
        Test.startTest();
        
        //Test controller before user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, false, request);        
        
        //Accept request and check owner and state
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        //Test controller after user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, true, request);
        
        Test.stopTest();
        
        //create maps of request to Tracking Object and request to Presenter
        List<Request_Presenter_Junction__c> pres = [Select Demo_Request__c, User_Name__c from Request_Presenter_Junction__c where Demo_Request__c in :requestIds];
        List<Demo_Request_Tracking__c> track = [Select Demo_Request__c, Activity_Completed_By__c from Demo_Request_Tracking__c where Demo_Request__c = :requestIds];
		Map<Id, String> presenters = new Map<Id, String>();
        Map<Id, Id> tracking = new Map<Id, Id>();
        for(Request_Presenter_Junction__c p : pres) {
            presenters.put(p.Demo_Request__c, p.User_Name__c);
        }
       	for(Demo_Request_Tracking__c t : track) {
            tracking.put(t.Demo_Request__c, t.Activity_Completed_By__c);
        }
        
        //Validate Test
        for(Demo_Request__c dr : [SELECT State__c, Demo_Owner__c, Id FROM Demo_Request__c WHERE ID IN :requestIds]){
            System.assertEquals('Accepted', dr.State__c, 'The state did not update to Accepted');
            System.assertEquals(tscTest.Id, dr.Demo_Owner__c, 'The owner was not assigned to the demo request');
            System.assertEquals(presenters.get(dr.Id), tscTest.Name, 'The owner was not added as a presenter');
            System.assertEquals(tracking.get(dr.Id), tscTest.Id, 'The owner did not get an activity tracking object');
            
        }
    }
    
    static testMethod void validateDemoRequestAccept(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];        
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);

        //Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(2, null);
        Integer count = request.size();
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
        }
        
        Test.startTest();
        System.debug('1 Test user: ' + tscTest.Id);
        //Test controller before user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, false, request);        
        System.debug('2 Test user: ' + tscTest.Id);
        //Accept request and check owner and state
        TestDemoRequestClass.AcceptSelfRequest(request, tscTest);
        System.debug('3 Test user: ' + tscTest.Id);
        //Test controller after user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, true, request);
        System.debug('4 Test user: ' + tscTest.Id);
        Test.stopTest();
        
        //create maps of request to Tracking Object and request to Presenter
        List<Request_Presenter_Junction__c> pres = [Select Demo_Request__c, User_Name__c from Request_Presenter_Junction__c where Demo_Request__c in :requestIds];
        List<Demo_Request_Tracking__c> track = [Select Demo_Request__c, Activity_Completed_By__c from Demo_Request_Tracking__c where Demo_Request__c = :requestIds];
		Map<Id, String> presenters = new Map<Id, String>();
        Map<Id, Id> tracking = new Map<Id, Id>();
        for(Request_Presenter_Junction__c p : pres) {
            presenters.put(p.Demo_Request__c, p.User_Name__c);
        }
       	for(Demo_Request_Tracking__c t : track) {
            tracking.put(t.Demo_Request__c, t.Activity_Completed_By__c);
        }
        
        //Validate Test
        for(Demo_Request__c dr : [SELECT State__c, Demo_Owner__c, Id FROM Demo_Request__c WHERE ID IN :requestIds]){
            System.assertEquals('Accepted', dr.State__c, 'The state did not update to Accepted');
            System.assertEquals(tscTest.Id, dr.Demo_Owner__c, 'The owner was not assigned to the demo request');
            System.assertEquals(presenters.get(dr.Id), tscTest.Name, 'The owner was not added as a presenter');
            System.assertEquals(tracking.get(dr.Id), tscTest.Id, 'The owner did not get an activity tracking object');
            
        }
    }
    
    static testMethod void validateDemoRequestAcceptWithOpportunity(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];        
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        Id opportunityId = DemoRequestFactory.CreateOpportunity();
        //Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, opportunityId);
        Integer count = request.size();
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
        }
        
        Test.startTest();
        
        //Test controller before user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, false, request);        
        
        //Accept request and check owner and state
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        //Test controller after user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, true, request);
        
        Test.stopTest();
        
        //Validate Test
        for(Demo_Request__c dr : [SELECT State__c, Demo_Owner__c FROM Demo_Request__c WHERE ID IN :requestIds]){
            System.assertEquals('Accepted', dr.State__c, 'The state did not update to Accepted');
            System.assertEquals(tscTest.Id, dr.Demo_Owner__c, 'The owner was not assigned to the demo request');
        }
    }
    
    static testMethod void validateDemoRequestAcceptThenAssign() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];        
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest2 = TestDemoRequestClass.GetTscTestUser(1);

        //Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        Integer count = request.size();
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
        }
        
        Test.startTest();
        
        //Test controller before user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest, false, request);        
        
        //Accept request and check owner and state
        TestDemoRequestClass.AcceptSelfRequest(request, tscTest);
        TestDemoRequestClass.AcceptRequest(request, tscTest2);
        
        //Test controller after user accepts
        TestDemoRequestClass.TestControllerAcceptedRequests(tscTest2, true, request);
        
        Test.stopTest();
        
        //create maps of request to Tracking Object and request to Presenter
        List<Request_Presenter_Junction__c> pres = [Select Demo_Request__c, User_Name__c from Request_Presenter_Junction__c where Demo_Request__c in :requestIds];
        List<Demo_Request_Tracking__c> track = [Select Demo_Request__c, Activity_Completed_By__c from Demo_Request_Tracking__c where Demo_Request__c = :requestIds];
		Map<Id, String> presenters = new Map<Id, String>();
        Map<Id, Id> tracking = new Map<Id, Id>();
        for(Request_Presenter_Junction__c p : pres) {
            presenters.put(p.Demo_Request__c, p.User_Name__c);
        }
       	for(Demo_Request_Tracking__c t : track) {
            tracking.put(t.Demo_Request__c, t.Activity_Completed_By__c);
        }
        
        //Validate Test
        for(Demo_Request__c dr : [SELECT State__c, Demo_Owner__c, Id FROM Demo_Request__c WHERE ID IN :requestIds]){
            System.assertEquals('Accepted', dr.State__c, 'The state did not update to Accepted');
            System.assertEquals(tscTest2.Id, dr.Demo_Owner__c, 'The owner was not assigned to the demo request');
            System.assertEquals(presenters.get(dr.Id), tscTest2.Name, 'The owner was not added as a presenter');
            System.assertEquals(tracking.get(dr.Id), tscTest2.Id, 'The owner did not get an activity tracking object');
            
        }
    }
    
    static testMethod void validateWarningOfAcceptConflictingEvent(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Event Conflict
        TestDemoRequestClass.CreateAdHocEvent('PTO', 'OutOfOffice', tscTest);
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        
        //Test Validation
        List<Id> requestIds = new List<Id>();
		for(Demo_Request__c r : request){
			requestIds.add(r.Id);
		}
		
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.currentPage().getParameters().put('id',d.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestAssignExtension ext = new DemoRequestAssignExtension(stdRequest);
                ext.submitSelf();
				System.Assert(ext.showPreviousEventWarning, 'Warning was not shown when other event conflicted');
            }
        }
        
    }
    
    static testMethod void validateWarningOfAssignConflictingEvent(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest2 = TestDemoRequestClass.GetTscTestUser(1);
        
        //Create Event Conflict
        TestDemoRequestClass.CreateAdHocEvent('PTO', 'OutOfOffice', tscTest2);
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        
        //Test Validation
        List<Id> requestIds = new List<Id>();
		for(Demo_Request__c r : request){
			requestIds.add(r.Id);
		}
		
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.currentPage().getParameters().put('id',d.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestAssignExtension ext = new DemoRequestAssignExtension(stdRequest);
                ext.selectedPerson = tscTest2.Name;
                ext.submitAssign();
				System.Assert(ext.showPreviousEventWarning, 'Warning was not shown when other event conflicted');
            }
        }
        
    }
    
    static testMethod void validateCannotAcceptOrAssign(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);        
        List<Id> requestIds = new List<Id>();
		for(Demo_Request__c r : request){
			requestIds.add(r.Id);
            system.debug('LastModifiedDate in validateCannotAcceptOrAssign method: ' + r.LastModifiedDate + ' for Request ' + r.Name);
		}
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
		TestDemoRequestClass.completeRequest(request);
        
        Test.startTest();
				
        request = [Select State__c, Demo_Owner__c, SuppressNotification__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestAssignExtension ext = new DemoRequestAssignExtension(stdRequest);
				System.AssertEquals(true, ext.showNotAbleToAssign, 'Demo could be accepted after being completed.  The state of the request was ' + d.State__c);
            }
        }
        
        Test.stopTest();
    }
    
}