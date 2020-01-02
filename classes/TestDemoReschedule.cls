@isTest
public class TestDemoReschedule {
    
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
    
    static testMethod void validateDemoRequestReschedule(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Testing Variables
        Map<Id, DateTime> currentDateTimeMap = new Map<Id, DateTime>();
        //Get List of platform IDs to create a request for each
        
        //Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(6, null);
        //Get Id and Date/Time after workflow and triggers have run.
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c];
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
            currentDateTimeMap.put(dr.Id, dr.Demo_Date_Time__c);
        }
        
        Test.startTest();
        System.debug('Reschedule Request');        
        TestDemoRequestClass.RescheduleRequest(request);
        Test.stopTest();
        
        //Compare the DateTime value before and after reschedule and make sure the DateTime value has changed.
        for(Demo_Request__c dr : [SELECT Id, Demo_Date_Time__c FROM Demo_Request__c WHERE ID IN :requestIds]){
            DateTime currentDateTime = currentDateTimeMap.get(dr.Id);
            DateTime rescheduleDateTime = dr.Demo_Date_Time__c;
            System.assertNotEquals(currentDateTime, rescheduleDateTime, 'The request was not correctly rescheduled');
        }
    }
    
    static testMethod void validateRescheduleEscalation() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Testing Variables
        Map<Id, DateTime> currentDateTimeMap = new Map<Id, DateTime>();
        //Get List of platform IDs to create a request for each
        
        //Create Requests
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(6, null);
        //Get Id and Date/Time after workflow and triggers have run.
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c];
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
            currentDateTimeMap.put(dr.Id, dr.Demo_Date_Time__c);
        }
        
        Test.startTest();
        System.debug('Reschedule Request');        
        TestDemoRequestClass.RescheduleRequestEscalated(request);
        Test.stopTest();
        
        //Compare the DateTime value before and after reschedule and make sure the DateTime value has changed.
        for(Demo_Request__c dr : [SELECT Id, State__c, Demo_Date_Time__c, Requested_Timezone__c, Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, SuppressNotification__c, QueueName__c FROM Demo_Request__c WHERE ID IN :requestIds]){
            DateTime currentDateTime = currentDateTimeMap.get(dr.Id);
            DateTime rescheduleDateTime = dr.Demo_Date_Time__c;
            //System.assertNotEquals(currentDateTime, rescheduleDateTime, 'The request was not correctly rescheduled');
            //System.assertEquals('Escalated', dr.State__c, 'The request did not escalate when rescheduled on a weekend');
        }
    }   
    
    static testMethod void validateCannotReschedule(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        TestDemoRequestClass.completeRequest(request);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                System.AssertEquals(true, ext.cannotReschedule, 'Demo could be rescheduled after being completed');
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateRescheduleBadDateInput(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
       
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.rDate = 'blarg';
                ext.checkAvail();
                ApexPages.Message[] pageMessages = ApexPages.getMessages();
                System.assertEquals(1, pageMessages.size());
                ext.resetTime();
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateRescheduleEmptyOnSiteLocationInput(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.rDate = '2020-02-14';
                ext.rTime = '11:11';
                ext.timezone = 'America/New_York';
                ext.demoLocation = 'On-site (Requires Approval)';
                ext.checkAvail();
                System.assertEquals(1, ApexPages.getMessages().size(), 'Reschedule did not require justify and onsite location to be included');
            }
        }
        
        Test.stopTest();
    }

    static testMethod void validateRescheduleGoodOnSiteLocationInput(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.rDate = '2020-02-14';
                ext.rTime = '11:11';
                ext.timezone = 'America/New_York';
                ext.demoLocation = 'On-site (Requires Approval)';
                ext.onsiteDemoLocation = 'blah';
                ext.onsiteJustify = 'blah';
                ext.checkAvail();
                system.assertEquals(0, ApexPages.getMessages().size(), 'Reschedule gave a page message, when it shouldnt have');
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateRescheduleBadHqLocationInput(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.rDate = '2020-02-14';
                ext.rTime = '11:11';
                ext.timezone = 'America/New_York';
                ext.demoLocation = 'ININ HQ Campus';
                ext.checkAvail();
                System.assertEquals(1, ApexPages.getMessages().size(), 'Reschedule did not require onsiteMeetingRoom ' + ApexPages.getMessages()[0]);
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateRescheduleGoodHqLocationInput(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.rDate = '2020-02-14';
                ext.rTime = '11:11';
                ext.timezone = 'America/New_York';
                ext.demoLocation = 'ININ HQ Campus';
                ext.onsiteMeetingRoom = 'blah';
                ext.checkAvail();
                System.assertEquals(0, ApexPages.getMessages().size(), 'Reschedule gave a page message, when it shouldnt have');
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateRescheduleBadReasonInput(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        Test.startTest();
        
        request = [Select State__c, SuppressNotification__c, Org_URL__c, Demo_Date_Time__c, Requested_Timezone__c, 
                   Demo_Time_Length__c, Chatter_Feed_ID__c, Reschedule_Reason__c, Requester_Email_Addr__c, Demo_Owner__c,
                   Requester_Name__c, OnSite_Justification__c, On_site_Location__c, Demo_Location__c, HQ_Meeting_Room__c, QueueName__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                ext.rDate = '2020-02-14';
                ext.rTime = '11:11';
                ext.timezone = 'America/New_York';
                ext.demoLocation = 'ININ HQ Campus';
                ext.checkAvail();
                System.assertEquals(1, ApexPages.getMessages().size(), 'Reschedule did not require a reason ' + ApexPages.getMessages()[0]);
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateRescheduleAndAccept() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);  
        
        System.runAs(tscTest) {
            for(Demo_Request__c d : request) {
                ApexPages.currentPage().getParameters().put('id',d.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                //Covert the time from GMT
                TimeZone tz = TimeZone.getTimeZone(d.Requested_Timezone__c);
                Integer tzOffset = tz.getOffset(d.Demo_Date_Time__c); //offset in milliseconds
                tzOffset /= 1000; //offset in seconds
                DateTime dtOffset = d.Demo_Date_Time__c.addSeconds(tzOffset);
                DateTime newDt = dtOffset.addDays(1);
                ext.timezone = 'America/New_York';
                ext.rDate = d.Demo_Date_Time__c.format('yyyy-MM-dd');
                ext.rTime = '11:30';
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.submitAccept();
            }
        }
        request = [Select Id, State__c, Demo_Owner__c from Demo_Request__c];
        for(Demo_Request__c d : request) {
            System.assertEquals('Accepted', d.State__c, 'State was not accepted');
            System.assertEquals(tscTest.Id, d.Demo_Owner__c, 'Different demo owner than expected');
        }
    }
    
    static testMethod void validateRescheduleAndAcceptNewOwner() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest2 = TestDemoRequestClass.GetTscTestUser(1);
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);  
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        System.runAs(tscTest2) {
            for(Demo_Request__c d : request) {
                ApexPages.currentPage().getParameters().put('id',d.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                //Covert the time from GMT
                TimeZone tz = TimeZone.getTimeZone(d.Requested_Timezone__c);
                Integer tzOffset = tz.getOffset(d.Demo_Date_Time__c); //offset in milliseconds
                tzOffset /= 1000; //offset in seconds
                DateTime dtOffset = d.Demo_Date_Time__c.addSeconds(tzOffset);
                DateTime newDt = dtOffset.addDays(1);
                ext.timezone = 'America/New_York';
                ext.rDate = d.Demo_Date_Time__c.format('yyyy-MM-dd');
                ext.rTime = '11:30';
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.submitAccept();
            }
        }
        request = [Select Id, State__c, Demo_Owner__c from Demo_Request__c];
        for(Demo_Request__c d : request) {
            System.assertEquals('Accepted', d.State__c, 'State was not accepted');
            System.assertEquals(tscTest2.Id, d.Demo_Owner__c, 'Different demo owner than expected');
        }
    }
    
    static testMethod void validateRescheduleAndDecline() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        Integer demoCount = 3;
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(demoCount, null);  
        
        System.runAs(tscTest) {
            for(Demo_Request__c d : request) {
                ApexPages.currentPage().getParameters().put('id',d.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                Boolean b = ext.isTSMember;
                String user = ext.userName;
                //Covert the time from GMT
                TimeZone tz = TimeZone.getTimeZone(d.Requested_Timezone__c);
                Integer tzOffset = tz.getOffset(d.Demo_Date_Time__c); //offset in milliseconds
                tzOffset /= 1000; //offset in seconds
                DateTime dtOffset = d.Demo_Date_Time__c.addSeconds(tzOffset);
                DateTime newDt = dtOffset.addDays(1);
                ext.timezone = 'America/New_York';
                ext.rDate = d.Demo_Date_Time__c.format('yyyy-MM-dd');
                ext.rTime = '11:30';
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.submitDecline();
                ext.declineReason = 'Demo Prep';
                ext.declineComments = 'Comment Comments';
                ext.declineDate = '';
                ext.declineTime = '';
                ext.submitDeclineFinal();
            }
        }
        request = [Select Id, State__c, Demo_Owner__c from Demo_Request__c];
        List<Demo_Request_Decline__c> declines = [Select Id from Demo_Request_Decline__c];
        for(Demo_Request__c d : request) {
            System.assertEquals('Rescheduled', d.State__c, 'State was not rescheduled');
        }
        
        System.assertEquals(demoCount, declines.size(), 'Incorrect number of declines'); 
    }
    
    static testMethod void validateRescheduleAndDeclineDateTime() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        Integer demoCount = 3;
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(demoCount, null);  
        
        System.runAs(tscTest) {
            for(Demo_Request__c d : request) {
                ApexPages.currentPage().getParameters().put('id',d.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
                DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
                //Covert the time from GMT
                TimeZone tz = TimeZone.getTimeZone(d.Requested_Timezone__c);
                Integer tzOffset = tz.getOffset(d.Demo_Date_Time__c); //offset in milliseconds
                tzOffset /= 1000; //offset in seconds
                DateTime dtOffset = d.Demo_Date_Time__c.addSeconds(tzOffset);
                DateTime newDt = dtOffset.addDays(1);
                ext.timezone = 'America/New_York';
                ext.rDate = d.Demo_Date_Time__c.format('yyyy-MM-dd');
                ext.rTime = '11:30';
                ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
                ext.submitDecline();
                ext.declineReason = 'Demo Prep';
                ext.declineComments = 'Comment Comments';
                DateTime dt = d.Demo_Date_Time__c;
                ext.declineDate = dt.addDays(1).format('MM/dd/yyyy');
                ext.declineTime = '12:00 PM';
                ext.submitDeclineFinal();
            }
        }
        request = [Select Id, State__c, Demo_Owner__c from Demo_Request__c];
        List<Demo_Request_Decline__c> declines = [Select Id from Demo_Request_Decline__c];
        for(Demo_Request__c d : request) {
            System.assertEquals('Rescheduled', d.State__c, 'State was not rescheduled');
        }
        
        System.assertEquals(demoCount, declines.size(), 'Incorrect number of declines'); 
    }
    
}