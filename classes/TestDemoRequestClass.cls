@isTest
public class TestDemoRequestClass {
    
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
    
    static testMethod void validateDemoRequestCancel() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];        
        //Users to test with
        //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User tscTest = GetTscTestUser(0);
        
        System.runAs(tscTest){
        
            //Create Requests
            List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);
            //Get Current state of demos after workflow/triggers have run
            request = [SELECT Id, State__c, Demo_Date_Time__c FROM Demo_Request__c];
            List<Id> requestIds = new List<Id>();
            for(Demo_Request__c dr : request){
                requestIds.add(dr.Id);
            }
        
            Test.startTest();
        
            //Cancel Request and Check state
            CancelRequests(request);
            for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
                System.AssertEquals('Cancelled', dr.State__c , 'The request did not cancel');
            }
            
            Test.stopTest();
        }
    }

    static testMethod void validateDemoRequestBlankCancelReason() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Users to test with
        User tscTest = GetTscTestUser(0);
        
        System.runAs(tscTest){
        
            //Create Requests
            List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);
            //Get Current state of demos after workflow/triggers have run
            request = [SELECT Id, State__c, Demo_Date_Time__c FROM Demo_Request__c];
            List<Id> requestIds = new List<Id>();
            for(Demo_Request__c dr : request){
                requestIds.add(dr.Id);
            }
        
            Test.startTest();
        
            for(Demo_Request__c r : request){
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestCancelExtension ext = new DemoRequestCancelExtension(stdRequest);
                ext.Submit();
                ApexPages.Message[] pageMessages = ApexPages.getMessages();
                System.assertEquals(1, pageMessages.size(), 'Error not displayed for blank cancel reason');         
            }
            
            Test.stopTest();
        }
    }

    static testMethod void validateDemoRequestCancelledCannotBeCancelled() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Users to test with
        User tscTest = GetTscTestUser(0);
        
        System.runAs(tscTest){
        
            //Create Requests
            List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);
            //Get Current state of demos after workflow/triggers have run
            request = [SELECT Id, State__c, Demo_Date_Time__c FROM Demo_Request__c];
            List<Id> requestIds = new List<Id>();
            for(Demo_Request__c dr : request){
                requestIds.add(dr.Id);
            }
        
            Test.startTest();
        
            CancelRequests(request);
            
             for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
                System.AssertEquals('Cancelled', dr.State__c , 'The request did not cancel');
            }
            
            CheckCannotCancelRequests(request);
            
            Test.stopTest();
        }
    }
    
    static testMethod void createRequestWithEscalationWeekendOnlyPassesOnFriday() {
        //only run test if it is friday
        if(DateTime.now().format('EEE') != 'Fri') return;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        User tscTest = GetTscTestUser(0);
        
        System.runAs(tscTest){
            DemoRequestSubmissionController ext = createRandomDemoRequestSkeleton();
            ext.demoDate = DateTime.now().format('yyyy-MM-dd');
            ext.demoTime = '23:00';
            ext.checkAvail();
            ext.submitVerify();
            
            System.assertEquals(True, ext.showFinished, 'Demo did not submit correctly');
            
            Demo_Request__c demo = ext.req;
            
            //System.assertEquals('Escalated', demo.State__c, 'Demo did not escalate with a request date of a weekend with submission datetime: ' + demo.Demo_Date_Time__c);
        }
    }

    static testMethod void validateCompleteDemo(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(3, null);        
        
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        completeRequest(request);
        
        Test.startTest();
        
        request = [Select State__c, Demo_Owner__c from Demo_Request__c where Id in :requestIds];
        System.runAs(tscTest){
            for(Demo_Request__c d : request) {
                System.AssertEquals('Completed', d.State__c, 'Demo did not become completed');
            }
        }
        
        Test.stopTest();
    }
    
    static testMethod void validateBulkCreate(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);
        
        Test.startTest();
        TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
            
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(201, null);

        //Test Validation
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }
        
        //Bulk test the available demos page
        TestControllerAvailableRequests(request, tscTest, true);
        
        System.assertEquals(201, request.size(), 'Bulk creation did not make the correct amount');
        
        Test.stopTest();
    }  
    
    static testMethod void validateTrackingJunctionsCreated(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);
        
        Test.startTest();
        TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
                    
        //Create Test Request
        List<Demo_Request__c> request = new List<Demo_Request__c>();
        request.add(TestDemoRequestClass.createRandomDemoRequest(tscTest.Id));  
        
        //Test Validation
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }

        TestDemoRequestClass.AcceptRequest(request, tscTest);
        Test.stopTest();
        List<Demo_Request_Tracking__c> tracks = [Select Id, Demo_Request__c from Demo_Request_Tracking__c where Demo_Request__c in :requestIds];
        List<Id> trackIds = new List<Id>();
        for(Demo_Request_Tracking__c r : tracks){
            trackIds.add(r.Id);
        }
        
        //map all of the tracking demo items to trackID
        List<Demo_Request_Tracking_Gen_Concept_Jnctn__c> gens = [Select Demo_Request_Activity_Tracking__r.Demo_Request__c, General_Concept__c from Demo_Request_Tracking_Gen_Concept_Jnctn__c where Demo_Request_Activity_Tracking__c in :trackIds];
        List<Demo_Request_Tracking_Integration_Jnctn__c> ints = [Select Demo_Request_Activity_Tracking__r.Demo_Request__c, Integration_Solution__c from Demo_Request_Tracking_Integration_Jnctn__c where Demo_Request_Activity_Tracking__c in :trackIds];
        List<Demo_Request_Tracking_Product_Junction__c> prods = [Select Demo_Request_Activity_Tracking__r.Demo_Request__c, Product__c from Demo_Request_Tracking_Product_Junction__c where Demo_Request_Activity_Tracking__c in :trackIds];
        Map<Id, Set<Id>> requestToItemTrack = new Map<Id, Set<Id>>();
        for(Demo_Request_Tracking_Gen_Concept_Jnctn__c g : gens) {
            if(!requestToItemTrack.containsKey(g.Demo_Request_Activity_Tracking__r.Demo_Request__c)) requestToItemTrack.put(g.Demo_Request_Activity_Tracking__r.Demo_Request__c, new Set<Id>());
            requestToItemTrack.get(g.Demo_Request_Activity_Tracking__r.Demo_Request__c).add(g.General_Concept__c);
        }
        for(Demo_Request_Tracking_Integration_Jnctn__c g : ints) {
            if(!requestToItemTrack.containsKey(g.Demo_Request_Activity_Tracking__r.Demo_Request__c)) requestToItemTrack.put(g.Demo_Request_Activity_Tracking__r.Demo_Request__c, new Set<Id>());
            requestToItemTrack.get(g.Demo_Request_Activity_Tracking__r.Demo_Request__c).add(g.Integration_Solution__c);
        } 
        for(Demo_Request_Tracking_Product_Junction__c g : prods) {
            if(!requestToItemTrack.containsKey(g.Demo_Request_Activity_Tracking__r.Demo_Request__c)) requestToItemTrack.put(g.Demo_Request_Activity_Tracking__r.Demo_Request__c, new Set<Id>());
            requestToItemTrack.get(g.Demo_Request_Activity_Tracking__r.Demo_Request__c).add(g.Product__c);
        }
        //map all of the demo items to requestID
        List<Demo_Request_Gen_Concept_Junction__c> gs = [Select Demo_Request__c, General_Concept__c from Demo_Request_Gen_Concept_Junction__c where Demo_Request__c in :requestIds];
        List<Demo_Request_Integration_Junction__c> is = [Select Demo_Request__c, Integration_Solution__c from Demo_Request_Integration_Junction__c where Demo_Request__c in :requestIds];
        List<Demo_Request_Product_Junction__c> ps = [Select Demo_Request__c, Product__c from Demo_Request_Product_Junction__c where Demo_Request__c in :requestIds];
        Map<Id, Set<Id>> requestToItem = new Map<Id, Set<Id>>();
        for(Demo_Request_Gen_Concept_Junction__c g : gs) {
            if(!requestToItem.containsKey(g.Demo_Request__c)) requestToItem.put(g.Demo_Request__c, new Set<Id>());
            requestToItem.get(g.Demo_Request__c).add(g.General_Concept__c);
        }
        for(Demo_Request_Integration_Junction__c g : is) {
            if(!requestToItem.containsKey(g.Demo_Request__c)) requestToItem.put(g.Demo_Request__c, new Set<Id>());
            requestToItem.get(g.Demo_Request__c).add(g.Integration_Solution__c);
        }
        for(Demo_Request_Product_Junction__c g : ps) {
            if(!requestToItem.containsKey(g.Demo_Request__c)) requestToItem.put(g.Demo_Request__c, new Set<Id>());
            requestToItem.get(g.Demo_Request__c).add(g.Product__c);
        }
        
        for(Id i : requestIds) {
            if(requestToItem.get(i) != null && requestToItemTrack.get(i) != null) {
                System.assertEquals(requestToItem.get(i).size(), requestToItemTrack.get(i).size(), 'The related items between the demo and tracking object had a different count');
                System.assert(requestToItemTrack.get(i).containsAll(requestToItem.get(i)), 'The tracking item did not contain all Ids of related items');
            }
        }
        
    }
    
    static testMethod void validateDemoRequestHome() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);

        Test.startTest();

        System.runas(tscTest) {
            DemoRequestHome ext = new DemoRequestHome();
            System.assertEquals(true, ext.isTSC, 'TSC did not see correct home screen');
        }
        User mgr = GetTsmTestUser(0);
        System.runas(mgr) {
            DemoRequestHome ext = new DemoRequestHome();
            System.assertEquals(true, ext.isTSM, 'TSM did not see correct home screen');
        }
        //this was a dumb way to do it in the first place. I don't want to add a isTSD flag. still pondering
        /*
        User carl = [SELECT Id, Name FROM User WHERE Alias = 'cfluk'];
        System.runas(carl) {
            DemoRequestHome ext = new DemoRequestHome();
            System.assertEquals(true, ext.isTSD, 'TSD did not see correct home screen');
            ext.selectedPerson = mgr.Id;
            ext.updateManager();
        }
        */
        Test.stopTest();
    }
    
    static testMethod void validateMyDemosFilters() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);
        Integer requestCount = 1;
        Test.startTest();
        TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(requestCount, null);
        System.debug('############################################################################################ Created request for validation: ' + request[0].Name);
        
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        System.assertEquals(requestCount, request.size(), 'Bulk creation did not make the correct amount');
        System.runas(tscTest) {
            DemoRequestMyDemosController myDemos = new DemoRequestMyDemosController();
            myDemos.selectedState = 'Upcoming';
            myDemos.refresh();
            List<DemoRequestWrapper> myReqShown = myDemos.getRequestWrappers();
            System.assertEquals(requestCount, myReqShown.size(), 'TSC did not see correct amount of upcoming requests');
        }
    }
    
    static testMethod void validateAvailableFilter() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);
        Integer requestCount = 2;
        Test.startTest();
        TestDemoRequestClass.TestControllerAvailableRequests(new List<Demo_Request__c>(), tscTest, true);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(requestCount, null);
        System.assertEquals(requestCount, request.size(), 'Creation did not make the correct amount');
        
        
        System.runas(tscTest) {
            DemoRequestAvailableController available = new DemoRequestAvailableController();
            List<DemoRequestWrapper> reqShown = available.getRequests();
            System.assertEquals(requestCount, reqShown.size(), 'TSC did not see correct amount of upcoming requests');
        }
        
        RescheduleRequest(request);
        
        System.runas(tscTest) {
            DemoRequestAvailableController available = new DemoRequestAvailableController();
            available.selectedState = 'Rescheduled';
            available.filter();
            available.resort();
            List<DemoRequestWrapper> reqShown = available.getRequests();
            System.assertEquals(requestCount, reqShown.size(), 'TSC did not see correct amount of rescheduled requests');
        }
        
        RescheduleRequestEscalated(request);
        
        System.runas(tscTest) {
            DemoRequestAvailableController available = new DemoRequestAvailableController();
            available.selectedState = 'Escalated';
            List<DemoRequestWrapper> my = available.getRequests();
            //System.assertEquals(requestCount, my.size(), 'TSC did not see correct amount of upcoming requests after reschedule');
        }
        
    }
    
    //test multi select component
    static testMethod void testMultiselectController() {
        MultiselectController c = new MultiselectController();
        
        c.leftOptions = new List<SelectOption>();
        c.rightOptions = new List<SelectOption>();

        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';
        
        System.assertEquals(c.leftOptions.size(), 3);
        System.assertEquals(c.rightOptions.size(), 0);
    }

    static testMethod void testBootstrapMultiselectController() {
        BootstrapMultiselectController c = new BootstrapMultiselectController();
        
        c.lOptions = new List<SelectOption>{new SelectOption('A', 'a')};
        c.rOptions = new List<SelectOption>{new SelectOption('b', 'b'), new SelectOption('C', 'c')};
        BootstrapMultiselectController.sOption[] s = c.options;
        c.selected = 'A&a&b&b&C&c';
        c.unselected = '';
        
        System.assertEquals(c.lOptions.size(), 0);
        System.assertEquals(c.rOptions.size(), 0);
    }
    
    static testMethod void ValidateOppIntegrationInterestCreation(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Create Test User
        User tscTest = GetTscTestUser(0);
        
        //Create Test Request
        Id oppId = DemoRequestFactory.CreateOpportunity();
        System.debug('oppId' +oppId);
        List<Demo_Request__c> request = new List<Demo_Request__c>();
        request = TestDemoRequestClass.CreateRequest(1, null);
        //request.add(TestDemoRequestClass.createRandomDemoRequest(tscTest.Id));
        DemoRequestSubmissionController ext = new DemoRequestSubmissionController();
        DemoRequestBuilder drb = ext.drb;
        ext.drb.withOpportunity(oppId);
        ext.drb.audienceType = 'Prospect';
        ext.drb.queue = 'Technical Sales';
        ext.submitRequestor();
        ext.selectedCompetitors = randomSelections(ext.competitorOptions);
        ext.submitClient();
        ext.drl.platSel = ext.drl.platOptSel;
        ext.submitPlatform();
        ext.drl.intSel = ext.drl.intOptSel;
        ext.drl.genSel = randomSelections(ext.drl.genOptSel);
        ext.drl.prodSel = randomSelections(ext.drl.prodOptSel);
        ext.submitItems();
        ext.demoDate = getTuesday();
        ext.demoTime = '22:30';
        ext.demoDurationHours = 1;
        ext.demoDurationMinutes = 30;
        drb.demoTimezone = ext.timezoneOptions.get(0).getValue();
        drb.demoLocation = ext.locationOptions.get(0).getValue();
        ext.checkAvail();
        ext.submitWhen();
        ext.submitVerify();
        Demo_Request__c req2 = ext.req;
        request.add(req2);
       
        /*List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : request){
            requestIds.add(r.Id);
        }*/
        Test.startTest();
        TestDemoRequestClass.AcceptRequest(request, tscTest);
        
        completeRequest(request);
        Test.stopTest();
        
        //Get Results Data
        List<Demo_Request__c> requests = [SELECT Id, Opportunity__c FROM Demo_Request__c];
        Map<Id, Id> reqToOpp = new Map<Id, Id>();
        for(Demo_Request__c r : requests){
            reqToOpp.put(r.Id, r.Opportunity__c);
        }
        List<Demo_Request_Tracking__c> trackedDemos = [SELECT Id, Demo_Request__c FROM Demo_Request_Tracking__c WHERE Demo_Request__c IN :reqToOpp.keySet() AND Activity_Type__c = 'Demo'];
        Map<Id, Id> trackToReq = new Map<Id, Id>();
        for(Demo_Request_Tracking__c t : trackedDemos){
            trackToReq.put(t.Id, t.Demo_Request__c);
        }
        List<Demo_Request_Tracking_Integration_Jnctn__c> trackedInts = [SELECT Demo_Request_Activity_Tracking__c, Integration_Solution__c FROM Demo_Request_Tracking_Integration_Jnctn__c WHERE Demo_Request_Activity_Tracking__c IN :trackToReq.keySet()];
        List<Opportunity_Integration_Interest__c> oppInts = [SELECT Integration_Solution__c FROM Opportunity_Integration_Interest__c WHERE Opportunity__c = :oppId];
        Set<Id> oppIntIds = new Set<Id>();
        for(Opportunity_Integration_Interest__c oppInt : oppInts){
            oppIntIds.add(oppInt.Integration_Solution__c);
        }
        //End Get Results Data
        
        //Validate Results
        for(Demo_Request_Tracking_Integration_Jnctn__c i : trackedInts){
            if(reqToOpp.get(trackToReq.get(i.Demo_Request_Activity_Tracking__c)) == null){
                System.assertEquals(false, oppIntIds.contains(i.Integration_Solution__c), 'The integration solution with Id: ' + i.Integration_Solution__c + ' Was incorrectly added to the Opportunity');
            } else {
                System.assertEquals(true, oppIntIds.contains(i.Integration_Solution__c), 'The integration solution with Id: ' + i.Integration_Solution__c + ' Was not added to the Opportunity');
            }
            
        }

    }
    
    static testMethod void ValidateViewRequestAs(){ 
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tscs = new List<User>();
        List<User> tsms = new List<User>();
        User sales = new User();
        System.runAs(thisUser) {
            tscs = DemoRequestFactory.CreateTscTestUsers(7);
            tsms = DemoRequestFactory.CreateTsmTestUsers(1);
            sales = GetSalesTestUser('JohnSales');
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tscs, tsms);
        DemoRequestFactory.InitializeData();
        User tsc = GetTscTestUser(0);
        User tsm = GetTsmTestUser(0);
        List<User> testUsers = new List<User> {tsc, tsm, sales};
            
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        
        for(User u : testUsers){
            system.runAs(u){
                for(Demo_Request__c de : request){
                    ApexPages.currentPage().getParameters().put('id', de.Id);
                    ApexPages.StandardController stdRequest = new ApexPages.StandardController(de);
                    DemoRequestAltLayoutExt ext = new DemoRequestAltLayoutExt(stdRequest);
                    ext.decline();
                    ext.acceptAssign();
                    ext.reschedule();
                    ext.cancel();
                    ext.updateItems();
                    ext.addPresenters();
                }                
            }
        }
        
    }
    
    
    // Utility 
    // Methods
    // Here
     
  
    static public User GetTscTestUser(Integer index){
        List<Demonstration_Presenter__c> pres = [SELECT Id, User_Name__c FROM Demonstration_Presenter__c WHERE isTsc__c = true AND isTsm__c = false AND QueueName__c='Technical Sales'];
        Demonstration_Presenter__c p = pres.get(index);
        User testUser = [SELECT Id, Name FROM User WHERE Id = :p.User_Name__c];
        
        System.debug('TSC test user Name and ID: ' + testUser.Name + ' ' + testUser.Id);
        return testUser;
    }
    
    static public User GetVscTestUser(Integer index){
        List<Demonstration_Presenter__c> pres = [SELECT Id, User_Name__c FROM Demonstration_Presenter__c WHERE isTsc__c = true AND isTsm__c = false AND QueueName__c='Velocity Sales'];
        Demonstration_Presenter__c p = pres.get(index);
        User testUser = [SELECT Id, Name FROM User WHERE Id = :p.User_Name__c];
        
        System.debug('TSC test user Name and ID: ' + testUser.Name + ' ' + testUser.Id);
        return testUser;
    }
    
    static public User GetTestUser(Integer index){
        List<Demonstration_Presenter__c> pres = [SELECT Id, User_Name__c FROM Demonstration_Presenter__c];
        Demonstration_Presenter__c p = pres.get(index);
        User testUser = [SELECT Id, Name FROM User WHERE Id = :p.User_Name__c];
        
        System.debug('TSC test user Name and ID: ' + testUser.Name + ' ' + testUser.Id);
        return testUser;
    }
    
    static public User GetTsmTestUser(Integer index){
        List<Demonstration_Presenter__c> pres = [SELECT Id, User_Name__c FROM Demonstration_Presenter__c WHERE isTsm__c = true];
        Demonstration_Presenter__c p = pres.get(index);
        User testUser = [SELECT Id, Name FROM User WHERE Id = :p.User_Name__c];
        
        System.debug('TSM test user Name and ID: ' + testUser.Name + ' ' + testUser.Id);
        return testUser;
    }
    
    static public User GetSalesTestUser(String name) {
        User testUser = UserFactory.CreateInternalUser(name);
        insert testUser;
        System.debug('Sales test user Name ID: ' + testUser.Name + ' ' + testUser.Id);
        return testUser;
    }
    
    static public void TestControllerAvailableRequests(List<Demo_Request__c> requests, User runAs, Boolean beforeDecline){
        System.runAs(runAs){
                      
            System.debug('Begin Testing Available Demo Display');
            Integer requestsToView = requests.size();
            DemoRequestAvailableController available = new DemoRequestAvailableController();
            if(beforeDecline){                
                List<DemoRequestWrapper> reqs = available.getRequests();
                Integer requestsDisplayed = reqs.size();
                System.assertEquals(requestsToView, requestsDisplayed, 'The user did not see all of the requests available');
            } else {
                List<DemoRequestWrapper> reqs = available.getRequests();
                Integer requestsDisplayed = reqs.size();
                System.assertEquals(0, requestsDisplayed, 'The user saw available requests when they should not have');
            }
        }
    }
    
    static public void TestControllerAcceptedRequests(User runAs, Boolean accepted, List<Demo_Request__c> requests){
        System.runAs(runAs){
            System.debug('Begin Testing Accepted Demo Display with user: ' + runAs.Id);
            Integer requestsToView = requests.size();
            DemoRequestMyDemosController ext = new DemoRequestMyDemosController();
            if(accepted){                
                List<DemoRequestWrapper> reqs = ext.getRequestWrappers();
                Integer requestsDisplayed = reqs.size();
                System.assertEquals(requestsToView, requestsDisplayed, 'The user did not see all of the requests accepted');
            } else {
                List<DemoRequestWrapper> reqs = ext.getRequestWrappers();
                Integer requestsDisplayed = reqs.size();
                System.assertEquals(0, requestsDisplayed, 'The user saw accepted requests when they should not have');
            }
        }
    }
    
    static public void TestControllerAutoDeclinedRequests(User runAs, List<Demo_Request__c> requests){
        System.runAs(runAs){
            System.debug('Begin Testing Auto-Decline Demo Display');
            Integer requestsToView = requests.size();
            DemoRequestAvailableController ext = new DemoRequestAvailableController();           
            List<DemoRequestWrapper> reqs = ext.getRequests();
            ext.selectedState = 'Auto-Declined';
            reqs = ext.getRequests();
            Integer requestsDisplayed = reqs.size();
            System.assertEquals(requestsToView, requestsDisplayed, 'The user did not see all of their auto-declined requests');
        }
    }
    
    static public void CheckCannotCancelRequests(List<Demo_Request__c> requests) {            
        for(Demo_Request__c r : requests){
            ApexPages.currentPage().getParameters().put('id',r.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
            DemoRequestCancelExtension ext = new DemoRequestCancelExtension(stdRequest);
            System.assertEquals(ext.showNotAbleToCancel , true, 'Demo could still be cancelled when it should not');           
        }
    }
    
    static public void CheckCannotDecline(List<Demo_Request__c> ds) {
        for(Demo_Request__c d : ds) {
            ApexPages.currentPage().getParameters().put('id',d.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
            DemoRequestDeclineExtension ext = new DemoRequestDeclineExtension(stdRequest);
            System.assertEquals(true, ext.showNotAbleToDecline, 'Demo could be declined after being accepted');
        }
    }
    
    static public List<Demo_Request__c> CreateRequest(Integer numberOfRequests, Id opportunityId){
        System.debug('############################################################################################ Creating: ' + numberOfRequests + ' Requests');
        List<Demo_Request__c> demos = new List<Demo_Request__c>();
        LIst<Id> demoIds = new List<Id>();
        Map<Id, List<Id>> platformToProductMap = DemoRequestFactory.BuildProductList();        
        Map<Id, List<Id>> platformToGenConMap = DemoRequestFactory.BuildGenConList();
        Map<Id, List<Id>> platformToIntMap = DemoRequestFactory.BuildIntegrationList();        
        List<Id> competitors = DemoRequestFactory.BuildCompetitorsList();
        List<Id> platform = DemoRequestFactory.BuildPlatformList();
        List<DateTime> requestTime = DemoRequestFactory.BuildRequestTimes(numberOfRequests);
        
        Integer startIdx = 0;
        //if list is below length of platforms, don't always start with the first
        if(numberOfRequests < platform.size()) {
            startIdx = randomInt(0,(platform.size() - numberOfRequests));
        }
        Integer endIdx = startIdx + numberOfRequests;
        System.debug('############################################################################################ StartIdx: ' + startIdx + ', EndIdx: ' + endIdx + ', NumRequests: ' + numberOfRequests);
        
        for(Integer i = startIdx; i < endIdx; i++){
            System.debug('Begin Creating Demo Request Number: ' + i);
            Demo_Request__c d = new Demo_Request__c();
            
            //Create Static Content
            d.Requester_Name__c = 'Justin Hawkins';
            d.Requester_Email_Addr__c = 'justin.hawkins@inin.com';
            d.Requester_Company__c = 'Interactive Intelligence, Inc.';
            d.Requester_Phone__c = '3174766203';
            //d.AudienceType__c = 'Prospect';
            d.Request_Type__c = 'New Revenue';
            d.Demo_Time_Length__c = 1.25;   
            d.Demo_Location__c = 'Web Based';
            d.State__c = 'Submitted';
            d.Escalate_Request_Time__c = false;
            d.Vertical__c = 'Not Applicable';
            
            //Dynamic Content
            d.Demo_Date_Time__c = requestTime.get(i-startIdx);
            
            if(DemoRequestUtility.EscalateForRequestedTime(d.Demo_Date_Time__c)) {
                d.State__c = 'Escalated';
                d.Escalate_Request_Time__c = true;
                d.Escalation_Reason__c = 'Submitted With Short Notice';
            }
            
            //if number of requests is greater than platform change Idx to circle through that number of platforms
            Integer tzIdx = i;
            while(tzIdx > DemoRequestFactory.requestTimeZone.size()-1) tzIdx -= DemoRequestFactory.requestTimeZone.size();
            
            d.Requested_Timezone__c = DemoRequestFactory.requestTimeZone.get(tzIdx);
            d.SuppressNotification__c = false;
            d.Org_URL__c = URL.getSalesforceBaseUrl().toExternalForm();
            d.QueueName__c = 'Technical Sales';
            
            if(opportunityId != null){
                d.Opportunity__c = opportunityId;
            } 
            
            System.debug('Date/Time before insert: ' + d.Demo_Date_Time__c + ' ' + d.Requested_Timezone__c);
            System.debug('State before insert: ' + d.State__c);
            System.debug('Escalation Set before insert: ' + d.Escalate_Request_Time__c);
            
            demos.add(d);
            
            System.debug('############################################################################################ demo (d): ' + d.Name + ', ID: ' + d.Id + ', Requester: ' + d.Requester_Name__c);
        }   
        
        System.debug('############################################################################################ Demos size: ' + demos.size());
        
        insert demos;
        
        for(Demo_Request__c d : demos) {
        	System.debug('############################################################################################ New Demo ID: ' + d.Id);
        }
        
        Return demos;
    }
    
    static public List<Demo_Request__c> CreateTrainingRequest(Integer numberOfRequests){
        
        List<Demo_Request__c> demos = new List<Demo_Request__c>();
        LIst<Id> demoIds = new List<Id>();
        User demoOwner = GetTscTestUser(0);
        List<Id> platform = DemoRequestFactory.BuildPlatformList();
        List<DateTime> requestTime = DemoRequestFactory.BuildRequestTimes(numberOfRequests);
        
        Integer startIdx = 0;
        //if list is below length of platforms, don't always start with the first
        if(numberOfRequests < platform.size()) {
            startIdx = randomInt(0,(platform.size() - numberOfRequests));
        }
        Integer endIdx = startIdx + numberOfRequests;
        
        for(Integer i = startIdx; i < endIdx; i++){
            System.debug('Begin Creating Demo Request Number: ' + i);
            Demo_Request__c d = new Demo_Request__c();
            
            //Create Static Content
            d.Requester_Name__c = 'Internal Bootcamp';
            d.Requester_Email_Addr__c = 'teschsalesdev@inin.com';
            d.Requester_Company__c = 'Interactive Intelligence, Inc.';
            d.Requester_Phone__c = '3174766203';
            d.AudienceType__c = 'Internal';
            d.Request_Type__c = 'Bootcamp';
            d.Demo_Time_Length__c = 96.00;  
            d.Demo_Location__c = 'On-site (Requires Approval)';
            d.State__c = 'Accepted';
            d.Demo_Owner__c = demoOwner.Id;
            d.Escalate_Request_Time__c = false;
            d.Vertical__c = 'Not Applicable';
            
            //Dynamic Content
            d.Demo_Date_Time__c = requestTime.get(i-startIdx);
            
            //if number of requests is greater than platform change Idx to circle through that number of platforms
            Integer tzIdx = i;
            while(tzIdx > DemoRequestFactory.requestTimeZone.size()-1) tzIdx -= DemoRequestFactory.requestTimeZone.size();
            
            d.Requested_Timezone__c = DemoRequestFactory.requestTimeZone.get(tzIdx);
            d.SuppressNotification__c = true;
            d.Org_URL__c = URL.getSalesforceBaseUrl().toExternalForm();
            
            System.debug('Date/Time before insert: ' + d.Demo_Date_Time__c + ' ' + d.Requested_Timezone__c);
            System.debug('State before insert: ' + d.State__c);
            System.debug('Escalation Set before insert: ' + d.Escalate_Request_Time__c);
            
            demos.add(d);
        }   
        
        insert demos;
        
        Return demos;
    }
    
    //pass empty or null for time and/or datetime if they are irrelevant to test
    static public void DeclineRequest(List<Demo_Request__c> requests, List<Id> declineUsers, String tim, DateTime datetim){
        //need to get to User's name for controller call
        List<User> gettingNames = [Select Id, Name from User where Id in :declineUsers];
        Map<Id, String> names = new Map<Id, String>();
        for(User u : gettingNames) {
            names.put(u.Id, u.Name);
        }
        String t = '';
        String d = '';
        if(datetim != null) {
            t = datetim.format('hh:mm a');
            d = datetim.format('MM/dd/yyyy');
        } 
        if(tim != '') t='11:30 AM';
        
        for(Demo_Request__c r : requests){
            if(declineUsers.size() == 1) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestDeclineExtension ext = new DemoRequestDeclineExtension(stdRequest);
                ext.declineReason = 'Demo Prep';            
                ext.rescheduleTime = t;
                ext.rescheduleDate = d;
                ext.selectSelf();
                ext.submitDecline();
            } else {
                for(Id i: declineUsers){
                    ApexPages.currentPage().getParameters().put('id',r.Id);
                    ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                    DemoRequestDeclineExtension ext = new DemoRequestDeclineExtension(stdRequest);
                    ext.declineReason = 'Demo Prep';            
                    ext.rescheduleTime = t;
                    ext.rescheduleDate = d;
                    ext.selectedPerson = names.get(i);
                    ext.selectPerson();
                    ext.submitDecline();
                }       
            }  
        }
    }
    
    static public void CancelRequests(List<Demo_Request__c> requests) {
                
        for(Demo_Request__c r : requests){
            ApexPages.currentPage().getParameters().put('id',r.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
            DemoRequestCancelExtension ext = new DemoRequestCancelExtension(stdRequest);
            ext.cancelReason = 'Deal Lost';
            ext.Submit();           
        }
    }
    
    static public void RescheduleRequest(List<Demo_Request__c> requests){
        
        System.debug('Begin Reschedule of Demo Request');
    
        for(Demo_Request__c d : requests){
            ApexPages.currentPage().getParameters().put('id',d.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
            DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
            system.assert(ext.cannotReschedule == null || ext.cannotReschedule == false, 'Could not reshedule this request');
            //Covert the time from GMT
            TimeZone tz = TimeZone.getTimeZone(d.Requested_Timezone__c);
            Integer tzOffset = tz.getOffset(d.Demo_Date_Time__c); //offset in milliseconds
            tzOffset /= 1000; //offset in seconds
            DateTime dtOffset = d.Demo_Date_Time__c.addSeconds(tzOffset);
            DateTime newDt = dtOffset.addDays(1);
            ext.timezone = 'America/New_York';
            ext.rDate = d.Demo_Date_Time__c.format('yyyy-MM-dd');
            ext.rTime = '23:30';
            ext.rescheduleReason = ext.rescheduleReasons[2].getValue(); 
            ext.submit();
        }
    }
    
    static public void ModifyRequest(List<Demo_Request__c> requests, List<Integration_Solution__c> availableIntegrations, List<General_Concept__c> availableGenConcepts, List<Product__c> availableProducts){
        
        //Create Lists of Integration, General Concepts and Products to Add to each Request
        List<Demo_Request_Integration_Junction__c> demoIntJunction = new List<Demo_Request_Integration_Junction__c>();
        List<Demo_Request_Gen_Concept_Junction__c> demoGcJunction = new List<Demo_Request_Gen_Concept_Junction__c>();
        List<Demo_Request_Product_Junction__c> demoProdJunction = new List<Demo_Request_Product_Junction__c>();
        
        for(Demo_Request__c d : requests){
            for(Integration_Solution__c i : availableIntegrations){
                Demo_Request_Integration_Junction__c demoInt = new Demo_Request_Integration_Junction__c();
                demoInt.Demo_Request__c = d.Id;
                demoInt.Integration_Solution__c = i.Id;
                demoIntJunction.add(demoInt);
            }
            
            for(General_Concept__c g : availableGenConcepts){
                Demo_Request_Gen_Concept_Junction__c demoGc = new Demo_Request_Gen_Concept_Junction__c();
                demoGc.Demo_Request__c = d.Id;
                demoGc.General_Concept__c = g.Id;
                demoGcJunction.add(demoGc);
            }
            
            for(Product__c p : availableProducts){
                Demo_Request_Product_Junction__c demoProd = new Demo_Request_Product_Junction__c();
                demoProd.Demo_Request__c = d.Id;
                demoProd.Product__c = p.Id;
                demoProdJunction.add(demoProd);
            }
        }
        
        try{
            insert demoIntJunction;
        } catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        try{
            insert demoGcJunction;
        } catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        try{
            insert demoProdJunction;
        } catch(Exception e){
            System.Assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
    }
    
    static public void AcceptRequest(List<Demo_Request__c> request, User owner){
        
        System.debug('Begin Acceptance of Demo Request');
        System.debug('########################################################## Accepting request for owner: ' + owner.Id + ' Demo Count: ' + request.size());
        System.runAs(owner) {
        for(Demo_Request__c d : request) {
            system.debug('Requester in AcceptRequest Method: ' + d.Requester_Name__c + ' for Request ' + d.Id);
            ApexPages.currentPage().getParameters().put('id',d.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
            DemoRequestAssignExtension ext = new DemoRequestAssignExtension(stdRequest);
            ext.selectedPerson = owner.Name;
            ext.submitAssign();
            if(!ext.conflicts.isEmpty()) ext.submitFinal();
        }}
    }
    
    static public void AcceptSelfRequest(List<Demo_Request__c> request, User owner) {
        System.debug('Begin Acceptance of Demo Request');
        System.debug('########################################################## Accepting request for owner: ' + owner.Id + ' Demo Count: ' + request.size());
        System.runAs(owner) {
        for(Demo_Request__c d : request) {
            ApexPages.currentPage().getParameters().put('id',d.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
            DemoRequestAssignExtension ext = new DemoRequestAssignExtension(stdRequest);
            ext.submitSelf();
            if(!ext.conflicts.isEmpty()) ext.submitFinal();
        }}
    }
    
    static public Demo_Request__c createRandomDemoRequest(Id createdFrom) {
        ApexPages.currentPage().getParameters().put('id',createdFrom);
        DemoRequestSubmissionController ext = createRandomDemoRequestSkeleton();
        ext.submitVerify();
        return ext.req;
    }
    
    static public DemoRequestSubmissionController createRandomDemoRequestSkeleton() {
        DemoRequestSubmissionController ext = new DemoRequestSubmissionController();
        ext.drb.audienceType = 'Prospect';
        ext.drb.queue = 'Technical Sales';
        ext.submitRequestor();
        ext.selectedCompetitors = randomSelections(ext.competitorOptions);
        ext.submitClient();
        ext.drl.platSel = ext.drl.platOptSel;
        ext.submitPlatform();
        ext.drl.intSel = ext.drl.intOptSel;
        ext.drl.genSel = randomSelections(ext.drl.genOptSel);
        ext.drl.prodSel = randomSelections(ext.drl.prodOptSel);
        ext.submitItems();
        DateTime dtNow = DateTime.Now();
        if(dtNow.format('EEE') == 'Mon'){
            ext.DemoDate = dtNow.addDays(2).format('yyyy-MM-dd');
        } else {
            ext.demoDate = getTuesday();
        }
        ext.demoTime = '10:30';
        ext.demoDurationHours = 1;
        ext.demoDurationMinutes = 30;
        ext.drb.demoTimezone = ext.timezoneOptions.get(0).getValue();
        ext.drb.demoLocation = ext.locationOptions.get(0).getValue();
        ext.checkAvail();
        ext.submitWhen();
        return ext;
    }
    
    static public String getTuesday() {
        return getTuesdayDateTime().format('yyyy-MM-dd');
    }
    
    static public DateTime getTuesdayDateTime() {
        Integer addDays = 1;
        while(DateTime.now().addDays(addDays).format('EEE') != 'Tue') {
            addDays++;
            if(addDays > 7) break;
        }
        return DateTime.now().addDays(addDays);
    }
    
    static public Integer randomInt(integer low, integer high) {
        return Math.round(Math.random() * (high - low)) + low;
    }
    
    static public List<SelectOption> randomSelections(List<SelectOption> options) {
        if(options == null || options.size() == 0) return new List<SelectOption>();
        SelectOption[] opts = new List<SelectOption>();
        Integer selectCount = randomInt(1, options.size()-1);
        Set<Integer> selections = randomListOfInts(selectCount, options.size()-1);
        for(Integer i : selections) {
            opts.add(options.get(i));
        }
        return opts;
    }
    
    static public Set<Integer> randomListOfInts(Integer size, Integer high) {
        Set<Integer> ints = new Set<Integer>();
        while(ints.size() < size) {
            Integer n = randomInt(0, high);
            if(ints.contains(n)) continue;
            ints.add(n);
        }
        return ints;
    }
    
    static public DateTime nextWeekendDate() {
        DateTime dtNow = DateTime.Now();
        Set<String> weekendDays = new Set<String>{'Fri', 'Sat', 'Sun'};
        while(!weekendDays.contains(dtNow.format('EEE'))) {
            dtNow = dtNow.addDays(1);
        }
        return dtNow;
    }
    
    static public List<Demo_Request_Tracking__c> CreateTrackingObject(List<Demo_Request__c> request, User testUser, String activity){
        List<Demo_Request_Tracking__c> tracking = new List<Demo_Request_Tracking__c>();
        
        for(Demo_Request__c r : request){
            Demo_Request_Tracking__c t = new Demo_Request_Tracking__c();
            t.Activity_Type__c = activity;
            t.Activity_Date_Time__c = r.Demo_Date_Time__c.addHours(-24);
            t.Activity_Duration__c = 1.0;
            t.Activity_Completed_By__c = testUser.Id;
            t.Demo_Request__c = r.Id;
            t.Activity_State__c = 'Not Started';
            tracking.add(t);
        }
        
        insert tracking;
        return tracking;
    }
    
    static public List<Demo_Request_Tracking__c> ModifyTrackingObject(List<Demo_Request_Tracking__c> tracking, User testUser, String activity){
        
        List<Demo_Request_Tracking__c> trackToUpdate = new List<Demo_Request_Tracking__c>();
        
        for(Demo_Request_Tracking__c t : tracking){
            t.Activity_Date_Time__c = t.Activity_Date_Time__c.addHours(24);
            t.Activity_Completed_By__c = testUser.Id;
            t.Activity_Type__c = activity;
            trackToUpdate.add(t);
        }
        update trackToUpdate;
        return trackToUpdate;
    }
    
    static public void CancelTrackingObject(List<Demo_Request_Tracking__c> tracking){
        delete tracking;
    }
    
    static public void CreateAdHocEvent(String subject, String showAs, User eventOwner){

        Event e = new Event();
        DateTime eventStart = datetime.now();

        e.OwnerId = eventOwner.Id;
        e.StartDateTime = eventStart;
        e.EndDateTime = eventStart.addDays(7);
        e.ShowAs = showAs;
        e.Subject = subject;
        system.debug('inserting adhoc event');
        system.debug(e);
        insert e;
    }
    
    static public Event CreateAdHocEvent(User eventOwner, DateTime start, Integer durationInMinutes) {
        Event e = new Event();
        e.OwnerId = eventOwner.Id;
        e.StartDateTime = start;
        e.EndDateTime = start.addMinutes(durationInMinutes);
        e.ShowAs = 'Busy';
        e.Subject = 'I am an Event!';
        system.debug('returning adhoc event');
        system.debug(e);
        return e;
    }
    
    static public Integer getDemoCommentCount(Id feedElementId) {
        ConnectApi.CommentPage feedComment = ConnectApi.ChatterFeeds.getCommentsForFeedElement(null, feedElementId);
        return feedComment.total;
        
    }
    
    static public String getDemoCommentBody(Id feedElementId, Integer commentIndex) {
        ConnectApi.CommentPage feedComment = ConnectApi.ChatterFeeds.getCommentsForFeedElement(null, feedElementId);
        List<ConnectApi.Comment> comments = feedComment.items;
        List<String> commentText = new List<String>();
        for(ConnectApi.Comment c : comments){
            commentText.add(c.body.text);
        }
        return commentText.get(commentIndex);
        
    }
    
    static public void RescheduleRequestEscalated(List<Demo_Request__c> requests){
        System.debug('Begin Reschedule of Demo Request');
    
        for(Demo_Request__c d : requests){
            ApexPages.currentPage().getParameters().put('id',d.Id);
            ApexPages.StandardController stdRequest = new ApexPages.StandardController(d);
            DemoRequestRescheduleExtension ext = new DemoRequestRescheduleExtension(stdRequest);
            ext.timezone = 'America/New_York';
            ext.rDate = DateTime.now().format('yyyy-MM-dd');
            ext.rTime = '23:50';
            ext.checkAvail();
            ext.submit();
        }
    }
    
    static public void completeRequest(List<Demo_Request__c> demos) {
        List<Id> requestIds = new List<Id>();
        for(Demo_Request__c r : demos){
            requestIds.add(r.Id);
        }
        
        List<Demo_Request_Tracking__c> tracks = [Select Id, Activity_State__c, Demo_Request__c from Demo_Request_Tracking__c where Demo_Request__c in :requestIds];
        List<Demo_Request_Tracking__c> updateT = new List<Demo_Request_Tracking__c>();
        for(Demo_Request_Tracking__c t : tracks) {
            updateT.add(new DemoRequestTrackingBuilder(t)
                .withState('Completed')
                 .tracking);
        }
        update updateT;
        
        DemoRequestClass.AddOppIntegrationInterest(tracks);
        DemoRequestClass.CompleteDemos(demos);
    }
    
    static public List<Demo_Request_Contact_Junction__c> RegisterForTraining(List<Demo_Request__c> trainings, string contactType){
        Contact c = ContactFactory.CreateContact('TrainingUser');
        insert c;
        List<Demo_Request_Contact_Junction__c> junctions = new List<Demo_Request_Contact_Junction__c>();
        
        for(Demo_Request__c t : trainings){
            Date startDate = t.Demo_Date_Time__c.dateGMT();
            Integer numOfDays = t.Demo_Time_Length__c.intValue() / 24;
            
            while(numOfDays > 0){
                Demo_Request_Contact_Junction__c j = new Demo_Request_Contact_Junction__c();
                j.Demo_Request__c = t.Id;
                j.Contact__c = c.Id;
                j.Contact_Type__c = contactType;
                j.Training_Date__c = startDate.addDays(numOfDays - 1);
                numOfDays--;
                junctions.add(j);
            }
        }
        
        insert junctions;
        return junctions;
    }
    
    static public List<Demo_Request_Tracking__c> CreateMultiDayEventActivities (List<Demo_Request__c> events, string eventType){
        List<Demo_Request_Tracking__c> acts = new List<Demo_Request_Tracking__c>();
        
        for(Demo_Request__c e : events){
            Integer numOfDays = e.Demo_Time_Length__c.intValue() / 24;
            
            while(numOfDays > 0){
                Demo_Request_Tracking__c j = new Demo_Request_Tracking__c();
                j.Demo_Request__c = e.Id;
                j.Activity_Completed_By__c = e.Demo_Owner__c;
                j.Activity_Type__c = eventType;
                j.Activity_Duration__c = 8.0;
                j.Activity_State__c = 'Not Started';
                j.Activity_Date_Time__c = e.Demo_Date_Time__c.addDays(numOfDays - 1);
                numOfDays--;
                acts.add(j);
            }
        }
        
        insert acts;
        return acts;
    }
    
    static public Demo_Request__c createBootcampDemo(User tsc) {
        Demo_Request__c d;
        System.runAs(tsc) {
            DemoRequestTradeshow ext = new DemoRequestTradeshow();
            DateTime current = DateTime.now();
            DateTime ends = current.addDays(1);
            ext.drb.companyName = 'Internal Bootcamp';
            ext.drb.onsiteDemoLocation = 'San Fran';
            ext.eventType = 'Bootcamp';
            ext.dateRangeStart = current.format('yyyy-MM-dd');
            ext.dateRangeEnd = ends.format('yyyy-MM-dd');
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
            d= ext.demo;
        }
        return d;
    }

}