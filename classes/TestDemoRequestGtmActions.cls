@isTest(SeeAllData=true)
public class TestDemoRequestGtmActions {
    
    //SeeAllData must be set to true for this test class.  Initialize data cannot be used due to DML before callout restriction.
    static testMethod void TestGetTokenSuccess(){
        System.debug('Starting TestGetTokenSuccess');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
    }
    
    static testMethod void TestGetTokenFailure(){
        System.debug('Starting TestGetTokenFailure');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        
        HttpResponse res = g2mActions.getRequestToken();
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(400, res.getStatusCode(), 'A 400 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
    }
    
    static testMethod void TestMeetingCreationSuccess(){
        System.debug('Starting TestMeetingCreationSuccess');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting creation');
        System.assertEquals(201, res.getStatusCode(), 'A 201 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        body = jsonDeserialize(res.getBody());
        System.assert(body.get('joinURL') != null, 'A join URL was not returned');
        System.assert(body.get('meetingid') != null, 'A meeting ID was not returned');
    }
    
    static testMethod void TestMeetingCreationFailure(){
        System.debug('Starting TestMeetingCreationFailure');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = 'NotTheRightKey';  //Pass the wrong key back to create a 400 message
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting creation');
        System.assertEquals(400, res.getStatusCode(), 'A 400 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');

    }
    
    static testMethod void TestMeetingUpdateSuccess(){
        System.debug('Starting TestMeetingUpdateSuccess');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        body = jsonDeserialize(res.getBody());
        
        //Update Meeting
        g2mActions.meetingId = Decimal.valueOf(String.valueOf(body.get('meetingid')));
        startTime = startTime.addDays(1);
        endTime = endTime.addDays(1);
        res = g2mActions.updateMeeting(subject, startTime, endTime);
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting update');
        System.assertEquals(204, res.getStatusCode(), 'A 204 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');

    }
    
    static testMethod void TestMeetingUpdateFailure(){
        System.debug('Starting TestMeetingUpdateFailure');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        body = jsonDeserialize(res.getBody());
        
        //Update Meeting
        g2mActions.meetingId = 1002;  //Pass meeting ID that is not expected to return a 404.
        startTime = startTime.addDays(1);
        endTime = endTime.addDays(1);
        res = g2mActions.updateMeeting(subject, startTime, endTime);
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting update');
        System.assertEquals(404, res.getStatusCode(), 'A 404 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');

    }
    
    static testMethod void TestMeetingDeleteSuccess(){
        System.debug('Starting TestMeetingDeleteSuccess');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        body = jsonDeserialize(res.getBody());
        
        //Delete Meeting
        g2mActions.meetingId = Decimal.valueOf(String.valueOf(body.get('meetingid')));
        res = g2mActions.deleteMeeting();
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting delete');
        System.assertEquals(204, res.getStatusCode(), 'A 204 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');

    }
    
    static testMethod void TestMeetingDeleteFailure(){
        System.debug('Starting TestMeetingDeleteFailure');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        body = jsonDeserialize(res.getBody());
        
        //Delete Meeting
        g2mActions.meetingId = 1002;  //Pass meeting ID that is not expected to return a 404.
        res = g2mActions.deleteMeeting();
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting delete');
        System.assertEquals(404, res.getStatusCode(), 'A 404 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');

    }
    
    static testMethod void TestMeetingGetSuccess(){
        System.debug('Starting TestMeetingGetSuccess');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        body = jsonDeserialize(res.getBody());
        
        //Get Meeting
        g2mActions.meetingId = Decimal.valueOf(String.valueOf(body.get('meetingid')));
        res = g2mActions.getMeeting();
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting get');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        System.assert(body.get('joinURL') != null, 'A join URL was not returned');
        System.assert(body.get('meetingid') != null, 'A meeting ID was not returned');

    }
    
    static testMethod void TestMeetingGetFailure(){
        System.debug('Starting TestMeetingGetFailure');
        List<Demonstration_Presenter__c> pres = [SELECT Id FROM Demonstration_Presenter__c];
        // If presenter list is empty we cannot run this test
        if(pres.isEmpty()) return;
        Test.startTest();
        User tscTest = TestDemoRequestClass.GetTestUser(0);
        
        
        Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
        DemoRequestGTMActions g2mActions = new DemoRequestGTMActions(tscTest.Id);
        g2mActions.responseKey = 'demoResponseKey';
        HttpResponse res = g2mActions.getRequestToken();
        
        //Validate Response
        System.debug('Validating oauth response');
        System.assertEquals(200, res.getStatusCode(), 'A 200 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');
        Map<String, Object> body = jsonDeserialize(res.getBody());
        System.assert(body.get('access_token') != null, 'Access Token was not returned');
        
        g2mActions.accessToken = String.valueOf(body.get('access_token'));
        
        //Create Meeting
        DateTime startTime = DateTime.now().addDays(4);
        DateTime endTime = startTime.addHours(1);
        String subject = 'Test meeting';
        res = g2mActions.createMeeting(subject, startTime, endTime);
        body = jsonDeserialize(res.getBody());
        
        //Get Meeting
        g2mActions.meetingId = 1002;  //Pass meeting ID that is not expected to return a 404.
        res = g2mActions.getMeeting();
        
        Test.stopTest();
        
        //Validate Response
        System.debug('Validating meeting delete');
        System.assertEquals(404, res.getStatusCode(), 'A 404 resopnse was not returned from the mock response class');
        System.assertEquals('application/json', res.getHeader('Content-Type'), 'Header value returned was not correct');

    }
    
    static testMethod void TestCreateMeetingFromController(){
        Boolean canTest = false;
        DateTime now = DateTime.now();
        Set<Id> tscIds = DemoRequestUtility.GetTSCsIds('Technical Sales');
        Map<Id, List<Demo_Request_Tracking__c>> userToActivity = new Map<Id, List<Demo_Request_Tracking__c>>();
        Map<Id, Id> identityMap = new Map<Id, Id>();
        List<Demo_Request_Tracking__c> activities = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c FROM Demo_Request_Tracking__c WHERE Activity_Type__c = 'Demo' AND Activity_Date_Time__c > :now AND Activity_Completed_By__c IN :tscIds];
        if(!activities.isEmpty()) canTest = true;
        
        if(canTest){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
            
            for(Demo_Request_Tracking__c t : activities){
                if(userToActivity.containsKey(t.Activity_Completed_By__c)){
                    userToActivity.get(t.Activity_Completed_By__c).add(t);
                } else {
                    userToActivity.put(t.Activity_Completed_By__c, new List<Demo_Request_Tracking__c>{t});
                    identityMap.put(t.Activity_Completed_By__c, t.Activity_Completed_By__c);
                }
            }
            //Get Test User
            Id userId = identityMap.values().get(0);
            User tscTest = [SELECT Id, Name FROM User WHERE Id = :userId];
            
            List<Demo_Request_Tracking__c> userActs = userToActivity.get(userId);
            Demo_Request_Tracking__c testAct = userActs.get(0);
            system.runAs(tscTest){
                ApexPages.currentPage().getParameters().put('state', testAct.Demo_Request__c);
                ApexPages.currentPage().getParameters().put('code', 'demoResponseKey');
                ApexPages.StandardSetController stdRequest = new ApexPages.StandardSetController(new List<Demo_Request_Tracking__c>{testAct});
                DemoRequestActivityController ext = new DemoRequestActivityController(stdRequest);
                ext.StartGtmOauth();
                ext.selectedId = testAct.Id;
                ext.showRecord();
                ext.activityDate = testAct.Activity_Date_Time__c.format('yyyy-MM-dd');
                ext.activityTime = testAct.Activity_Date_Time__c.format('HH:mm');
                ext.CreateGtm();
            }
            
            //Validate Results
            testAct = [SELECT Id, GoToMeeting_ID__c FROM Demo_Request_Tracking__c WHERE Id = :testAct.Id];
            System.assert(testAct.GoToMeeting_ID__c != null, 'A meeting Id was not created for activity Id: ' + testAct.Id);
            Test.stopTest();
        }        
        
    }
    
    static testMethod void TestUpdateMeetingFromController(){
        Boolean canTest = false;
        DateTime now = DateTime.now();
        Set<Id> tscIds = DemoRequestUtility.GetTSCsIds('Technical Sales');
        Map<Id, List<Demo_Request_Tracking__c>> userToActivity = new Map<Id, List<Demo_Request_Tracking__c>>();
        Map<Id, Id> identityMap = new Map<Id, Id>();
        List<Demo_Request_Tracking__c> activities = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c FROM Demo_Request_Tracking__c WHERE Activity_Type__c = 'Demo' AND Activity_Date_Time__c > :now AND Activity_Completed_By__c IN :tscIds];
        if(!activities.isEmpty()) canTest = true;
        
        if(canTest){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
            
            for(Demo_Request_Tracking__c t : activities){
                if(userToActivity.containsKey(t.Activity_Completed_By__c)){
                    userToActivity.get(t.Activity_Completed_By__c).add(t);
                } else {
                    userToActivity.put(t.Activity_Completed_By__c, new List<Demo_Request_Tracking__c>{t});
                    identityMap.put(t.Activity_Completed_By__c, t.Activity_Completed_By__c);
                }
            }
            //Get Test User
            Id userId = identityMap.values().get(0);
            User tscTest = [SELECT Id, Name FROM User WHERE Id = :userId];
            
            List<Demo_Request_Tracking__c> userActs = userToActivity.get(userId);
            Demo_Request_Tracking__c testAct = userActs.get(0);
            system.runAs(tscTest){
                ApexPages.currentPage().getParameters().put('state', testAct.Demo_Request__c);
                ApexPages.currentPage().getParameters().put('code', 'demoResponseKey');
                ApexPages.StandardSetController stdRequest = new ApexPages.StandardSetController(new List<Demo_Request_Tracking__c>{testAct});
                DemoRequestActivityController ext = new DemoRequestActivityController(stdRequest);
                ext.StartGtmOauth();
                ext.selectedId = testAct.Id;
                ext.showRecord();
                ext.activityDate = testAct.Activity_Date_Time__c.format('yyyy-MM-dd');
                ext.activityTime = testAct.Activity_Date_Time__c.format('HH:mm');
                ext.CreateGtm();
                ext.showRecord();
                ext.activityDate = testAct.Activity_Date_Time__c.addDays(1).format('yyyy-MM-dd');
                ext.activityTime = testAct.Activity_Date_Time__c.format('HH:mm');
                ext.updateRecord();
                if(!ext.conflicts.isEmpty()) ext.updateFinal();
            }
            
            //Validate Results
            testAct = [SELECT Id, GoToMeeting_ID__c FROM Demo_Request_Tracking__c WHERE Id = :testAct.Id];
            System.assert(testAct.GoToMeeting_ID__c != null, 'A meeting Id was not created for activity Id: ' + testAct.Id);
            Test.stopTest();
        }
    }
    
    static testMethod void TestDeleteMeetingFromController(){
        Boolean canTest = false;
        DateTime now = DateTime.now();
        Set<Id> tscIds = DemoRequestUtility.GetTSCsIds('Technical Sales');
        Map<Id, List<Demo_Request_Tracking__c>> userToActivity = new Map<Id, List<Demo_Request_Tracking__c>>();
        Map<Id, Id> identityMap = new Map<Id, Id>();
        List<Demo_Request_Tracking__c> activities = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c, GoToMeeting_ID__c FROM Demo_Request_Tracking__c WHERE Activity_Type__c = 'Demo' AND Activity_Date_Time__c > :now AND Activity_Completed_By__c IN :tscIds AND GoToMeeting_ID__c != null];
        if(!activities.isEmpty()) canTest = true;
        
        if(canTest){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
            
            for(Demo_Request_Tracking__c t : activities){
                if(userToActivity.containsKey(t.Activity_Completed_By__c)){
                    userToActivity.get(t.Activity_Completed_By__c).add(t);
                } else {
                    userToActivity.put(t.Activity_Completed_By__c, new List<Demo_Request_Tracking__c>{t});
                    identityMap.put(t.Activity_Completed_By__c, t.Activity_Completed_By__c);
                }
            }
            //Get Test User
            Id userId = identityMap.values().get(0);
            User tscTest = [SELECT Id, Name FROM User WHERE Id = :userId];
            
            List<Demo_Request_Tracking__c> userActs = userToActivity.get(userId);
            Demo_Request_Tracking__c testAct = userActs.get(0);
            system.runAs(tscTest){
                ApexPages.currentPage().getParameters().put('state', testAct.Demo_Request__c);
                ApexPages.currentPage().getParameters().put('code', 'demoResponseKey');
                ApexPages.StandardSetController stdRequest = new ApexPages.StandardSetController(new List<Demo_Request_Tracking__c>{testAct});
                DemoRequestActivityController ext = new DemoRequestActivityController(stdRequest);
                ext.selectedId = testAct.Id;
                ext.showRecord();
                ext.activityDate = testAct.Activity_Date_Time__c.format('yyyy-MM-dd');
                ext.activityTime = testAct.Activity_Date_Time__c.format('HH:mm');
                ext.g2mActions.meetingId = 1001;
                ext.DeleteGTMOnly();
            }
            
            //Validate Results
            testAct = [SELECT Id, GoToMeeting_ID__c FROM Demo_Request_Tracking__c WHERE Id = :testAct.Id];
            System.assert(testAct.GoToMeeting_ID__c == null, 'A meeting Id was not removed for activity Id: ' + testAct.Id);
            Test.stopTest();
        }
    }
    
    static testMethod void TestSaveToken(){
        Boolean canTest = false;
        DateTime now = DateTime.now();
        Set<Id> tscIds = DemoRequestUtility.GetTSCsIds('Technical Sales');
        Map<Id, List<Demo_Request_Tracking__c>> userToActivity = new Map<Id, List<Demo_Request_Tracking__c>>();
        Map<Id, Id> identityMap = new Map<Id, Id>();
        List<Demo_Request_Tracking__c> activities = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c FROM Demo_Request_Tracking__c WHERE Activity_Type__c = 'Demo' AND Activity_Date_Time__c > :now AND Activity_Completed_By__c IN :tscIds];
        if(!activities.isEmpty()) canTest = true;
        
        if(canTest){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
            
            for(Demo_Request_Tracking__c t : activities){
                if(userToActivity.containsKey(t.Activity_Completed_By__c)){
                    userToActivity.get(t.Activity_Completed_By__c).add(t);
                } else {
                    userToActivity.put(t.Activity_Completed_By__c, new List<Demo_Request_Tracking__c>{t});
                    identityMap.put(t.Activity_Completed_By__c, t.Activity_Completed_By__c);
                }
            }
            //Get Test User
            Id userId = identityMap.values().get(0);
            User tscTest = [SELECT Id, Name FROM User WHERE Id = :userId];
            
            List<Demo_Request_Tracking__c> userActs = userToActivity.get(userId);
            Demo_Request_Tracking__c testAct = userActs.get(0);
            system.runAs(tscTest){
                ApexPages.currentPage().getParameters().put('state', testAct.Demo_Request__c);
                ApexPages.currentPage().getParameters().put('code', 'demoResponseKey');
                ApexPages.StandardSetController stdRequest = new ApexPages.StandardSetController(new List<Demo_Request_Tracking__c>{testAct});
                DemoRequestActivityController ext = new DemoRequestActivityController(stdRequest);
                ext.StartGtmOauth();
                ext.selectedId = testAct.Id;
                ext.SaveToken();
            }
            
            //Validate Results
            Demonstration_Presenter__c pres = [SELECT Id, User_Name__c, GTM_Access_Token__c, GTM_Token_Expire_Date__c, GTM_Account_Key__c, GTM_Organizer_Key__c FROM Demonstration_Presenter__c WHERE User_Name__c = :tscTest.Id];
            System.assert(pres.GTM_Access_Token__c != null, 'An access token was not added to the presenter object');
            System.assert(pres.GTM_Token_Expire_Date__c != null, 'An expire date was not added to the presenter object');
            System.assert(pres.GTM_Account_Key__c != null, 'An account key was not added to the presenter object');
            System.assert(pres.GTM_Organizer_Key__c != null, 'An organizer key was not added to the presenter object');
            Test.stopTest();
        }
    }
    
    static testMethod void TestCalloutErrors(){
        Boolean canTest = false;
        DateTime now = DateTime.now();
        List<String> actTypes = new List<String>{'Demo', 'Tradeshow'};
        Set<Id> tsIds = DemoRequestUtility.getAllTSIds('Technical Sales');
        Map<Id, List<Demo_Request_Tracking__c>> userToActivity = new Map<Id, List<Demo_Request_Tracking__c>>();
        Map<Id, Id> identityMap = new Map<Id, Id>();
        List<Demo_Request_Tracking__c> activities = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c FROM Demo_Request_Tracking__c WHERE Activity_Type__c IN :actTypes AND Activity_Date_Time__c > :now AND Activity_Completed_By__c IN :tsIds];
        if(!activities.isEmpty()) canTest = true;
        
        if(canTest){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestDemoRequestMockHTTPResponse());
            
            for(Demo_Request_Tracking__c t : activities){
                if(userToActivity.containsKey(t.Activity_Completed_By__c)){
                    userToActivity.get(t.Activity_Completed_By__c).add(t);
                } else {
                    userToActivity.put(t.Activity_Completed_By__c, new List<Demo_Request_Tracking__c>{t});
                    identityMap.put(t.Activity_Completed_By__c, t.Activity_Completed_By__c);
                }
            }
            //Get Test User
            Id userId = identityMap.values().get(0);
            User tscTest = [SELECT Id, Name FROM User WHERE Id = :userId];
            
            List<Demo_Request_Tracking__c> userActs = userToActivity.get(userId);
            Demo_Request_Tracking__c testAct = userActs.get(0);
            system.runAs(tscTest){
                ApexPages.currentPage().getParameters().put('state', testAct.Demo_Request__c);
                ApexPages.currentPage().getParameters().put('code', 'wrongKey');
                ApexPages.StandardSetController stdRequest = new ApexPages.StandardSetController(new List<Demo_Request_Tracking__c>{testAct});
                DemoRequestActivityController ext = new DemoRequestActivityController(stdRequest);
                ext.selectedId = testAct.Id;
                ext.g2mActions.accessToken = ''; //Make sure access token is clear to return errors from callouts
                ext.showRecord();
                ext.activityDate = testAct.Activity_Date_Time__c.format('yyyy-MM-dd');
                ext.activityTime = testAct.Activity_Date_Time__c.format('HH:mm');
                ext.CreateGtm();
                List<ApexPages.Message> pageMessages = ApexPages.getMessages();
                for(ApexPages.Message message : pageMessages){
                    System.assert(message.getSeverity() == ApexPages.Severity.ERROR, 'Create Meeting should not have completed');
                }
                pageMessages.clear();
                ext.DeleteGTMOnly();
                pageMessages = ApexPages.getMessages();
                for(ApexPages.Message message : pageMessages){
                    System.assert(message.getSeverity() == ApexPages.Severity.ERROR, 'Delete Meeting should not have completed');
                }
            }
            Test.stopTest();
        }
    }
    
    //Utility Methods
    private static Map<String, object> jsonDeserialize(String jsonString){
        return (Map<String, Object>)JSON.deserializeUntyped(jsonString);
    }
}