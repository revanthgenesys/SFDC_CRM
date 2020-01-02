@isTest
public class TestDemoEvents {
    
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
    
    static testMethod void validateEventCreation(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        //Create Prep Call Tracking
        List<Demo_Request_Tracking__c> trackPc = TestDemoRequestClass.CreateTrackingObject(request, tscTest, 'Prep Call');
        DemoRequestEventBuilder.CreateEventsFromActivity(trackPc);
        //Create Demo Setup Tracking
        List<Demo_Request_Tracking__c> trackDs = TestDemoRequestClass.CreateTrackingObject(request, tscTest, 'Demo Setup'); 
        DemoRequestEventBuilder.CreateEventsFromActivity(trackDs);
        Test.stopTest();
        
        //Test Validation
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c r : request){
        	requestIds.add(r.Id);
        }
        
        Map<Id, List<Event>> requestToEvent = new Map<Id, List<Event>>();
        //WhatId is related Item id, in this case demo request
        List<Event> events = [SELECT Id, WhatId, Type FROM Event WHERE WhatId IN :requestIds];
        for(Event e : events){
    		if(requestToEvent.containsKey(e.WhatId)){
       			requestToEvent.get(e.WhatId).add(e);
       		}else{
           		requestToEvent.put(e.WhatId, new List<Event>{e});
       		}
    	}
    	
    	for(Demo_Request__c req : request){
    		List<Event> evts = requestToEvent.get(req.Id);
    		System.assertEquals(evts.size(), 3, 'The expected number of events were not created for this request');
    	}
        
    }
    
    static testMethod void validateEventModification(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest2 = TestDemoRequestClass.GetTscTestUser(1);
        
        //Create Test Request
        Demo_Request__c request = TestDemoRequestClass.createRandomDemoRequest(tscTest.Id);
        
        Test.startTest();
        //Create Prep Call Tracking
        Demo_Request_Tracking__c firstTrack = new DemoRequestTrackingBuilder()
            										.withOwner(tscTest.Id)
                                                    .withRequestFullInfo(request)
                                                    .withType('Prep Call')
                                                    .build();

        
        //List<Demo_Request_Tracking__c> track = TestDemoRequestClass.CreateTrackingObject(request, tscTest, 'Prep Call');
        //DemoRequestClass.CreateEvent(track);
        
        //Gather Test Data
        List<Event> oldEvents = [SELECT Id, WhatId, StartDateTime, Type, OwnerId FROM Event WHERE WhatId = :request.Id];
        
        //Demo_Request_Tracking__c origTrack = track[0].clone(true,true,true,true);
        //Modify Prep Call to Demo Setup and change user assignment    
        //track = [Select Id, Activity_Type__c, Activity_Completed_By__c, Activity_Date_Time__c, Activity_Duration__c, Demo_Request__c, GoToMeeting_ID__c from Demo_Request_Tracking__c];
        //System.debug('New Event time should be: ' + track[0].Activity_Date_Time__c + '   ' + origTrack.Activity_Date_Time__c);
		Demo_Request_Tracking__c secondTrack = new DemoRequestTrackingBuilder(firstTrack)
                                                    .withType('Demo Setup')
                                                    .withOwner(tscTest2.Id)
                                                    .withStartTime(firstTrack.Activity_Date_Time__c.addHours(24))
                                                    .build();

        Test.stopTest();
        
        List<Event> updatedEvents = [SELECT Id, WhatId, StartDateTime, Type, OwnerId FROM Event WHERE WhatId = :request.Id];
        
        System.debug('Old Events Count: ' + oldEvents.size() + ' Time: ' + oldEvents[0].StartDateTime);
        System.debug('New Events Count: ' + updatedEvents.size() + ' Time: ' + updatedEvents[0].StartDateTime);
        
        //Test Validation
        for(Event e : updatedEvents){
            for(Event eComp : oldEvents){
                if(e.Id == eComp.Id) {
                    System.AssertNotEquals(eComp.StartDateTime, e.StartDateTime, 'The event time did not update as expected'); //Verify for Prep Call time change
                    System.AssertNotEquals(eComp.Type, e.Type, 'The event type did not update as expected'); //Verify for Type change
                    System.AssertNotEquals(eComp.OwnerId, e.OwnerId, 'The event owner did not update as expected'); //Verify for User Assignment
                }
            }
        }
    }
    
    static testMethod void validateEventCancel(){
    	//Initalize Test Data
    	User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        //Create Prep Call Tracking
        List<Demo_Request_Tracking__c> track = TestDemoRequestClass.CreateTrackingObject(request, tscTest, 'Prep Call');               
        
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request_Tracking__c t : track){
        	requestIds.add(t.Demo_Request__c);
        }
        
        List<Event> oldEvents = [SELECT Id, WhatId, StartDateTime, Type FROM Event WHERE WhatId IN :requestIds];
        
        Map<Id, List<Event>> oldMap = new Map<Id, List<Event>>();
        for(Event e : oldEvents){
        	if(oldMap.containsKey(e.Id)){
       			oldMap.get(e.Id).add(e);
       		}else{
           		oldMap.put(e.Id, new List<Event>{e});
       		}
        }
        
        TestDemoRequestClass.RescheduleRequest(request);
        
        Test.stopTest();
        
        List<Event> updatedEvents = [SELECT Id, WhatId, StartDateTime, Type FROM Event WHERE WhatId IN :requestIds];
        
        //Test Validation
        System.assert(updatedEvents.isEmpty(), 'Events were not removed after reschedule');
        
        
    }
    
    static testMethod void validateAddPresenterSelf() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);             
        Test.stopTest();
        
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest1) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
             	DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.addMe();
            }
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c in :requestIds AND Activity_Type__c = 'Demo' AND Activity_Completed_By__c = :tscTest1.Id];
        List<Request_Presenter_Junction__c> pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c in :requestIds AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(reqCount, tracks.size(), 'Tracking item not created for new Presenter');
        System.assertEquals(reqCount, pres.size(), 'Presenter junction not created for new Presenter');
        
    }
    
    static testMethod void validateAddRemovePresenterOther() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Demonstration_Presenter__c tsc1 = [Select Id, Name FROM Demonstration_Presenter__c WHERE User_Name__c= :tscTest1.Id];
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);             
        
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
             	DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.selectedPersonAdd = tsc1.Id;
                ext.addPresenter();
            }
            
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.selectedPersonRemove = tsc1.Id;
                ext.removePresenter();
            }
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c in :requestIds AND Activity_Type__c = 'Demo' AND Activity_Completed_By__c = :tscTest1.Id];
        List<Request_Presenter_Junction__c> pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c in :requestIds AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(0, tracks.size(), 'Tracking item not created for new Presenter');
        System.assertEquals(0, pres.size(), 'Presenter junction not created for new Presenter');
        Test.stopTest();
        
    }
    
    static testMethod void validateRemovePresenterSelf() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Demonstration_Presenter__c tsc1 = [Select Id, Name FROM Demonstration_Presenter__c WHERE User_Name__c= :tscTest1.Id];
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);             
        
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest1) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
             	DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.addMe();
            }
            
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.removeMe();
            }
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c in :requestIds AND Activity_Type__c = 'Demo' AND Activity_Completed_By__c = :tscTest1.Id];
        List<Request_Presenter_Junction__c> pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c in :requestIds AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(0, tracks.size(), 'Tracking item not removed for new Presenter');
        System.assertEquals(0, pres.size(), 'Presenter junction not removed for new Presenter');
        Test.stopTest();
    }
    
    static testMethod void validateRemovePresenterOther() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Demonstration_Presenter__c tsc1 = [Select Id, Name FROM Demonstration_Presenter__c WHERE User_Name__c= :tscTest1.Id];
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);             
        
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.selectedPersonAdd = tsc1.Id;
                ext.addPresenter();
            }
            
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.selectedPersonRemove = tsc1.Id;
                ext.removePresenter();
            }
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c in :requestIds AND Activity_Type__c = 'Demo' AND Activity_Completed_By__c = :tscTest1.Id];
        List<Request_Presenter_Junction__c> pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c in :requestIds AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(0, tracks.size(), 'Tracking item not removed from removing presenter');
        System.assertEquals(0, pres.size(), 'Presenter junction not removed for removing Presenter');
        Test.stopTest();
    }
    
    static testMethod void validateCannotAlterPresentersView() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        
        Test.startTest();
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
             	DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                //Verify presenter and tracking created
                System.assertEquals(true, ext.showWarning, 'Warning not shown when demo was in an invalid addPresenter State');
            }
        }
        Test.stopTest();
        
    }
    
    static testMethod void validateCannotAddRemoveOwner() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);             
        
        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
             	DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                //Verify presenter and tracking created
                System.assertEquals(false, ext.showAddMe, 'Owner could add himself as presenter');
                System.assertEquals(false, ext.showRemoveMe, 'Owner could remove his presenter');
                System.assertEquals(false, ext.showRemove, 'Owner could see empty remove other box');
            }
        }
        Test.stopTest();
    }
    
    static testMethod void validatePresenterConflictCheck() {
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Integer reqCount = 2;
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(reqCount, null);
        
        TestDemoRequestClass.CreateAdHocEvent('PTO', 'Busy', tscTest1);
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);             

        //Gather Test Data
        Set<Id> requestIds = new Set<Id>();
        for(Demo_Request__c t : request){
            requestIds.add(t.Id);
        }
        
        //Add tsc2 as presenter
        System.runAs(tscTest1) {
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
                ext.addMe();
                System.assertEquals(true, ext.showConflict, 'Conflict event was not shown');
            }
        }
        Test.stopTest();
        
    }
    
    static testMethod void validateAddPresenterMultiActs(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];

        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Demo_Request__c demo = TestDemoRequestClass.createBootcampDemo(tsctest);
        List<Demo_Request_Tracking__c> templateTracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c = :demo.Id AND isTemplate__c = true];
        //Add tsc2 as presenter
        System.runAs(tscTest1) {
            ApexPages.currentPage().getParameters().put('id',demo.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
            ext.addMe();
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c = :demo.Id AND Activity_Completed_By__c = :tscTest1.Id];
        List<Request_Presenter_Junction__c> pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c = :demo.Id AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(templateTracks.size(), tracks.size(), 'Tracking item not created for new Presenter');
        System.assertEquals(1, pres.size(), 'Presenter junction not created for new Presenter');
    }
    
    static testMethod void validateRemovePresenterMultiActs(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest1 = TestDemoRequestClass.GetTscTestUser(1);
        Demo_Request__c demo = TestDemoRequestClass.createBootcampDemo(tsctest);
        List<Demo_Request_Tracking__c> templateTracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c = :demo.Id AND isTemplate__c = true];
        
        //Add tsc2 as presenter
        System.runAs(tscTest1) {
            ApexPages.currentPage().getParameters().put('id',demo.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(demo);
            DemoRequestPresenterExtension ext = new DemoRequestPresenterExtension(stdRequest);
            ext.addMe();
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c = :demo.Id AND Activity_Completed_By__c = :tscTest1.Id];
        List<Request_Presenter_Junction__c> pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c = :demo.Id AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(templateTracks.size(), tracks.size(), 'Tracking item not created for new Presenter');
        System.assertEquals(1, pres.size(), 'Presenter junction not created for new Presenter');
        
        System.runAs(tscTest1) {
            ApexPages.currentPage().getParameters().put('id',demo.Id);
            ApexPages.StandardController stdRequest2 = new ApexPages.StandardController(demo);
            DemoRequestPresenterExtension ext2 = new DemoRequestPresenterExtension(stdRequest2);
            ext2.removeMe();
        }
        
        tracks = [Select Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c = :demo.Id AND Activity_Type__c = 'Demo' AND Activity_Completed_By__c = :tscTest1.Id];        
        pres = [Select Id FROM Request_Presenter_Junction__c WHERE Demo_Request__c = :demo.Id AND User_Name__c = :tscTest1.Name];
        
        //Verify presenter and tracking created
        System.assertEquals(0, tracks.size(), 'Tracking item not deleted for removed Presenter');
        System.assertEquals(0, pres.size(), 'Presenter junction not deleted for removed Presenter');
    }
}