@isTest
public class TestDemoSubmission {
    
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
    
    static testMethod void validateDemoRequestCreate(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        //Testing Variables
        DateTime dtNow = DateTime.now();
        DateTime dtAddTime = dtNow.addHours(96);
        String dayToday = dtNow.format('EEE');

        //Start Tests
        Test.startTest();
        System.debug('Testing as Sys Admin');
        System.debug('Create Requests without Opportunities');
        List<Platform__c> platforms = [Select Id from Platform__c];
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(platforms.size(), null);
        Test.stopTest();
        
        //Validate Test
        Integer count = request.size();
        Integer numberOfDemoRequests = platforms.size();
        System.AssertEquals(count, numberOfDemoRequests, 'The expected number of Demo Requests were not created');
        
        List<Id> requestIds = new List<Id>();
        
        for(Demo_Request__c dr : request){
            requestIds.add(dr.Id);
        }
        
        for(Demo_Request__c dr : [SELECT Id, State__c, Demo_Date_Time__c FROM Demo_Request__c WHERE ID IN :requestIds]){
            //Check Time escalation scenarios
            String reqDay = dr.Demo_Date_Time__c.format('EEE');
            if(dr.Demo_Date_Time__c.addHours(-24) < dtNow){
                System.assertEquals('Escalated', dr.State__c, 'The request did not escalate for being within 24 hours');
            } else if((dayToday == 'Fri') && (dr.Demo_Date_Time__c < dtAddTime)){
                if(reqDay == 'Fri' || reqDay == 'Sat' || reqDay == 'Sun' || reqDay == 'Mon'){
                    System.assertEquals('Escalated', dr.State__c, 'The request did not escalate for Friday within 96 hours was: ' + reqDay);
                }
            } else {
                System.assertNotEquals('Escalated', dr.State__c, 'The request has incorrectly escalated due to Request Date/Time');
            }
        }        
    }
    
    static testMethod void createHQDemo() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.backToSchedule();
            ext.drb.demoLocation = 'ININ HQ Campus';
            ext.checkAvail();
            ext.getLocationDetails();
            System.assert(ext.showHQ, 'HQ Campus additional information was not show when choosen');
            ext.drb.onsiteMeetingRoom = 'HQ1F3 Greyhounds';
            ext.submitWhen();
            ext.submitVerify();
            
            Demo_Request__c demo = ext.req;
            
            System.assertEquals('Submitted', demo.State__c, 'Demo did not submit an at HQ correctly');
        }
    }
    
    static testMethod void validateSubmissionNavigation() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
        ext.backToClient();
        ext.backToVerify();
        ext.backToItems();
        ext.resetPlatform();
        ext.backToVerify();
        ext.backToRequestor();
        ext.backToVerify();
        ext.backToSchedule();
        ext.backToVerify();
        ext.submitVerify();
    }
   
    static testMethod void createRequestWithOpp() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Id opp = DemoRequestFactory.CreateOpportunity();
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                    
            Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(opp);
            
            System.assert(demo.Opportunity__c == opp, 'Opputunity was not linked even though it was created from there');
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
        }
    }
    
    static testMethod void createRequestWithAccountLinkedOpp() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Opportunity opp = DemoRequestFactory.CreateOpportunityfromAccount();
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
            ApexPages.currentPage().getParameters().put('id',opp.Account.Id);
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            system.assertEquals(ext.opportunityOptions.size(), 2, 'Linked opportunity did not show');
            system.assert(ext.drb.acct == opp.Account.Id, 'Did not start from the Account');
            ext.backToClient();
            ext.submitClient();
            ext.selectedLinkedOpp = opp.Id;
            ext.submitLinkedOpp();
            ext.backToVerify();
            ext.submitVerify();
            Demo_Request__c demo = [Select Account__c, Opportunity__c from Demo_Request__c where id= :ext.req.Id];
            
            System.assertEquals(demo.Account__c, opp.Account.Id, 'Account was not linked');
            system.assertEquals(demo.Opportunity__c, opp.Id, 'Opportunity was not linked');
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
        }
        
    }
    
    static testMethod void createRequestWithAccount() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Id acct = DemoRequestFactory.CreateAccount(null);
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                    
            Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(acct);
            
            System.assert(demo.Account__c == acct, 'Account was not linked even though it was created from there');
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
        }
    }
    
    static testMethod void createRequestWithLead() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Id lead = DemoRequestFactory.CreateLead();
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                    
            Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(lead);
            
            System.assert(demo.Lead__c == lead, 'Lead was not linked even though it was created from there');
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, true);
        }
    }
    
    static testMethod void createRequestWithEscalationHours() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.demoDate = DateTime.now().addDays(1).format('yyyy-MM-dd');
            ext.demoTime = '00:03';
            ext.checkAvail();
            ext.submitVerify();
            
            Demo_Request__c demo = ext.req;
            
            System.assertEquals(demo.State__c, 'Escalated', 'Demo did not escalate with a request time within 24 hours');
        }
    }
    
    static testMethod void createRequestAndAccept() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.submitVerifyAccept();
            
            Demo_Request__c req = [Select State__c, Demo_Owner__c from Demo_Request__c where Id = :ext.req.Id];
            System.assertEquals('Accepted', req.State__c, 'Demo was not accepted when submitted');
            System.assertEquals(tsc.Id, req.Demo_Owner__c, 'Demo was not accepted when submitted');
        }
    }
    
    static testMethod void createRequestAndDecline() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.submitVerifyDecline();
            ext.declineReason = 'Demo Prep';
            ext.declineDate = '';
            ext.declineTime = '';
            ext.submitDecline();
            
            Demo_Request__c req = [Select Id, State__c, Demo_Owner__c from Demo_Request__c where Id = :ext.req.Id];
            System.assertEquals('Submitted', req.State__c, 'Demo was not in correct state');
            List<Demo_Request_Decline__c> declines = [Select Id from Demo_Request_Decline__c where Demo_Request_ID__c = :req.Id];
            System.assertEquals(1, declines.size(), 'Decline was not created');
        }
    }
    
    static testMethod void createRequestAndComplete() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            PageReference comp = ext.submitVerifyComplete();
            system.assert(comp.getUrl().contains('DemoRequestActivityTracking'), 'Was not directed to complete tracking activity');
            Demo_Request__c req = [Select Id, State__c, Demo_Owner__c from Demo_Request__c where Id = :ext.req.Id];
            System.assertEquals('Accepted', req.State__c, 'Demo was not in correct state');
        }
    }
    
    static testMethod void createRequestAndDeclineDateTime() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.backToSchedule();
            ext.resetSchedule();
            ext.checkAvail();
            ext.submitWhen();
            ext.submitVerifyDecline();
            ext.declineReason = 'Demo Prep';
            DateTime n = DateTime.now();
            ext.declineDate = n.addDays(2).format('MM/dd/yyyy');
            ext.declineTime = '11:30 AM';
            ext.declineComments = 'Comment there. Comment here.';
            ext.submitDecline();
            
            Demo_Request__c req = [Select Id, State__c, Demo_Owner__c from Demo_Request__c where Id = :ext.req.Id];
            System.assertEquals('Submitted', req.State__c, 'Demo was not in correct state');
            List<Demo_Request_Decline__c> declines = [Select Id from Demo_Request_Decline__c where Demo_Request_ID__c = :req.Id];
            System.assertEquals(1, declines.size(), 'Decline was not created');
        }
    }
    
    static testMethod void createRequestInternal() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        DemoRequestFactory.CreateAccount('Genesys');
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.backToRequestor();
            ext.drb.audienceType = 'Internal';
            ext.submitRequestor();
            ext.drb.requestType = ext.requestTypeOptions[0].getValue();
            ext.submitClient();
            ext.backToVerify();
            ext.submitVerify();
            
            Demo_Request__c req = [Select Id, State__c, Demo_Owner__c, audienceType__c, request_Type__c from Demo_Request__c where Id = :ext.req.Id];
            System.assertEquals('Submitted', req.State__c, 'Demo was not in correct state');
            System.assertEquals('Internal', req.audienceType__c, 'Demo did not have correct audience type');
            System.assertEquals('Internal', req.request_Type__c, 'Demo did not have correct request type');
        }
    }
    
    static testMethod void createTradeshowDemo() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestTradeshow ext = new DemoRequestTradeshow();
            ext.drb.companyName = 'Dreamforce';
            ext.drb.onsiteDemoLocation = 'San Fran';
            ext.eventType = 'Tradeshow';
            ext.dateRangeStart = '2015-09-07';
            ext.dateRangeEnd = '2015-09-09';
            ext.submitInfo();
            ext.tscLeader = ext.presenters[1].getValue();
            ext.updateOtherPresenters();
            SelectOption[] others = new SelectOption[]{};
            others.add(ext.otherpresenters[1]);
            others.add(ext.otherpresenters[2]); 
            ext.selectedOtherPresenters = others;
            ext.submitTSCs();
            Integer count = ext.dayInputs.size();
            for(Integer i = 0; i < count; i++) {
                ext.dayTimeRanges[i] = '07:00';
                ext.dayTimeEnds[i] = '17:00';
            }
            ext.submitTimes();
            ext.submitVerify();
            Demo_Request__c d = ext.demo;
            d = [Select State__c from Demo_Request__c where Id=:d.Id];
            System.assertEquals('Accepted', d.State__c, 'State was not accepted');
            List<Demo_Request_Tracking__c> acts = [Select Id from Demo_Request_Tracking__c where Demo_Request__c=:d.Id];
            System.assertEquals(12, acts.size(), 'Incorrect amount of activities created');
        }
    }
    
    static testMethod void createTradeshowDemoBadTimes() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestTradeshow ext = new DemoRequestTradeshow();
            ext.drb.companyName = 'Dreamforce';
            ext.drb.onsiteDemoLocation = 'San Fran';
            ext.dateRangeStart = '2015-09-07';
            ext.dateRangeEnd = '2015-09-09';
            ext.submitInfo();
            ext.tscLeader = ext.presenters[1].getValue();
            ext.updateOtherPresenters();
            SelectOption[] others = new SelectOption[]{};
            others.add(ext.otherpresenters[1]);
            others.add(ext.otherpresenters[2]); 
            ext.selectedOtherPresenters = others;
            ext.submitTSCs();
            Integer count = ext.dayInputs.size();
            for(Integer i = 0; i < count; i++) {
                ext.dayTimeRanges[i] = '11:00';
                ext.dayTimeEnds[i] = '09:00';
            }
            ext.submitTimes();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size());
            ext.backToInfo();
            ext.backToTimes();
            for(Integer i = 0; i < count; i++) {
                ext.dayTimeRanges[i] = '09:00';
                ext.dayTimeEnds[i] = '11:00';
            }
            ext.submitTimes();
            ext.backToTSCs();
            ext.backToVerify();
            ext.submitVerify();
        }
    }
    
    static testMethod void createTradeshowDemoBadInfo() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestTradeshow ext = new DemoRequestTradeshow();
            ext.drb.companyName = 'Dreamforce';
            ext.submitInfo();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size(), 'No error displayed for missing location');
        }
    }
    
    static testMethod void createTradeshowDemoBadInfo1() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {            
            DemoRequestTradeshow ext2 = new DemoRequestTradeshow();
            ext2.drb.companyName = 'Dreamforce';
            ext2.drb.onsiteDemoLocation = 'San Fran';
            ext2.eventType = 'Bootcamp';
            ext2.checkShowAudienceType();
            ext2.submitInfo();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            System.assertNotEquals(0, pageMessages.size(), 'No error displayed for missing start and end date');
        }
    }
    
    static testMethod void createTradeshowDemoBadInfo2() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestTradeshow ext3 = new DemoRequestTradeshow();
            ext3.drb.companyName = 'Dreamforce';
            ext3.drb.onsiteDemoLocation = 'San Fran';
            ext3.eventType = 'Bootcamp';
            ext3.checkShowAudienceType();
            ext3.dateRangeStart = '2015-09-07';
            ext3.dateRangeEnd = '2015-09-09';
            ext3.submitInfo();
            ApexPages.Message[] pageMessages = ApexPages.getMessages();
            String msg = '';
            for(ApexPages.Message m : pageMessages) msg += '  ' + m.getSummary();
            System.assertEquals(0, pageMessages.size(), 'Error displayed when there shouldnt be: ' + msg);
        }
    }
      
    static testMethod void createBootcampEvent() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        Demo_Request__c d = TestDemoRequestClass.createBootcampDemo(tsc);
        d = [Select State__c from Demo_Request__c where Id=:d.Id];
        System.assertEquals('Accepted', d.State__c, 'State was not accepted');
        List<Demo_Request_Tracking__c> acts = [Select Id from Demo_Request_Tracking__c where Demo_Request__c=:d.Id];
        System.assertEquals(8, acts.size(), 'Incorrect amount of activities created');
        List<Event> events = [Select Id from Event where WhatId=:d.Id];
        System.assertEquals(3, events.size(), 'Incorrect amount of activities created');
    }
    
    static testMethod void createWebinarSeries() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        User tsc = TestDemoRequestClass.GetTscTestUser(0);
        System.runAs(tsc) {
            DemoRequestTradeshow ext = new DemoRequestTradeshow();
            ext.drb.companyName = 'Internal Bootcamp';
            ext.drb.onsiteDemoLocation = 'Indianapolis';
            ext.eventType = 'Webinar Series';
            ext.webinarCount = 4;
            ext.submitInfo();
            ext.tscLeader = ext.presenters[1].getValue();
            ext.updateOtherPresenters();
            SelectOption[] others = new SelectOption[]{};
            others.add(ext.otherpresenters[1]);
            others.add(ext.otherpresenters[2]); 
            ext.selectedOtherPresenters = others;
            ext.submitTSCs();
            Integer count = ext.webinarCount;
            DateTime today = DateTime.now();
            for(Integer i = 0; i < count; i++) {
                DateTime webDay = today.addDays(i*7);
                ext.webinarDays[i] = webDay.format('yyyy-MM-dd');
                ext.dayTimeRanges[i] = '07:00';
                ext.dayTimeEnds[i] = '17:00';
            }
            ext.submitTimes();
            ext.submitVerify();
            Demo_Request__c d = ext.demo;
            d = [Select State__c from Demo_Request__c where Id=:d.Id];
            System.assertEquals('Accepted', d.State__c, 'State was not accepted');
            List<Demo_Request_Tracking__c> acts = [Select Id from Demo_Request_Tracking__c where Demo_Request__c=:d.Id];
            System.assertEquals(16, acts.size(), 'Incorrect amount of activities created');
            List<Event> events = [Select Id from Event where WhatId=:d.Id];
            System.assertEquals(12, events.size(), 'Incorrect amount of events created');
        }
    }
      
    static testMethod void createWebinar() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        DemoWebinar.createWeeklyWebinars();
        List<Demo_Request__c> demo = [Select Id from Demo_Request__c];
        System.assertEquals(2, demo.size(), '2 demos were not created for webinars');
        DemoWebinar.createWeeklyWebinars();
        System.assertEquals(2, demo.size(), 'Webinars were created more than once');
    }
    
    static testMethod void createRequestDuringMaintenance() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //uped to avoid failure by escalation
        Integer addDays = 3;
        while(DateTime.now().addDays(addDays).format('EEE') != 'Fri') {
            addDays++;
            system.debug('Day of the week is ' + DateTime.now().addDays(addDays).format('EEE'));
            if(addDays > 10) break;
        }        
        DateTime requestDt = DateTime.now().addDays(addDays);
        
        System.runAs(tscTest){
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.demoDate = requestDt.format('yyyy-MM-dd');
            ext.demoTime = '06:30';
            ext.checkAvail();
            ext.submitVerify();
            
            Demo_Request__c demo = ext.req;
            
            System.assertEquals(demo.State__c, 'Submitted', 'Demo did not Submit correctly');
        }
    }
    
    static testMethod void createVSRequest() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> vsc = new List<User>();
        List<User> vsm = new List<User>();
        System.runAs(thisUser) {
            vsc = DemoRequestFactory.CreateTscTestUsers(3);
            vsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(vsc, vsm, 'Velocity Sales');
        User vscTest = TestDemoRequestClass.GetVscTestUser(0);
        
        System.runAs(vscTest){
            
            Id opp = DemoRequestFactory.CreateOpportunity();
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), vscTest, true);
                    
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.backToClient();
            ext.drb.withOpportunity(opp);
            ext.drb.queue = 'Velocity Sales';
            ext.submitClient();
            ext.backToVerify();
            ext.submitVerify();
            Demo_Request__c demo = [Select Id, State__c, Demo_Owner__c, audienceType__c, request_Type__c,Opportunity__c, QueueName__c from Demo_Request__c where Id = :ext.req.Id];
            System.assert(demo.Opportunity__c == opp, 'Opportunity was not linked even though it was created from there');
            System.assert(demo.QueueName__c == 'Velocity Sales', 'Velocity Queue was not set');
            //Test Controller after user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, vscTest, true);
        }
    }
    
    //create a demo for 2 days out at 10:30, make busy events for over half the team, expect a return of alternate times
    /*
    public static testMethod void createSubmissionValidateSuggestTimes(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<Event> events = new List<Event>();
        List<User> tsc = [Select Id, Name from User where FirstName like 'Tsc%'];
        DateTime dDate = DateTime.now().addDays(2);
        DateTime demoDate = DateTime.newInstance(dDate.date(), Time.newInstance(10, 30, 0, 0));
        events.add(TestDemoRequestClass.CreateAdHocEvent(tsc[0],demoDate.addHours(-1),180));
        events.add(TestDemoRequestClass.CreateAdHocEvent(tsc[1],demoDate.addHours(-2),280));
        events.add(TestDemoRequestClass.CreateAdHocEvent(tsc[2],demoDate,180));
        events.add(TestDemoRequestClass.CreateAdHocEvent(tsc[3],demoDate.addMinutes(15),180));
        insert events;
        
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
            
            Id opp = DemoRequestFactory.CreateOpportunity();
            
            Test.startTest();
            //Test controller before user declines
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                    
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.backToClient();
            ext.drb.withOpportunity(opp);
            ext.submitClient();
            ext.submitPlatform();
            ext.submitItems();

            ext.DemoDate = demoDate.format('yyyy-MM-dd');
            ext.demoTime = '10:30';
            ext.demoDurationHours = 1;
            ext.demoDurationMinutes = 30;
            ext.checkAvail();
            System.assert(ext.altTimes.size() > 0, 'Alternate times had 0 return ' + ext.tscCount + '  ' + ext.altTimes.size());
            System.assert(ext.showAltTimes, 'Alternate times were not displayed to requester');
            ext.backToVerify();
            ext.submitVerify();
            Demo_Request__c demo = [Select Id, State__c, Demo_Owner__c, audienceType__c, request_Type__c,Opportunity__c, QueueName__c from Demo_Request__c where Id = :ext.req.Id];
            System.assert(demo.Opportunity__c == opp, 'Opportunity was not linked even though it was created from there');
            //Test Controller after user declines, they shouldn't see it
            TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>{demo}, tscTest, false);
        }
    } */
}