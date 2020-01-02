@isTest
public class TestDemoDeclines {
    
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
   
    static testMethod void validateDemoRequestDeclineTSC() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
		//Users to test with
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){

        	//Testing Variables
        	List<Id> tsc = new List<Id>{tscTest.Id};
        	System.debug('TSC Ids: ' + tsc);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}        
        
            Test.startTest();
        
        	//Test controller before user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, true);
        
        	//Decline request with a single user.  Verify that the request does not escalate from this action unless it was previously escalated
            TestDemoRequestClass.DeclineRequest(request, new Id[]{tscTest.Id}, '', null);
            
        	for(Demo_Request__c dr : [SELECT State__c, Id FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];
                System.AssertEquals(1, declines.size(), 'The request did not have a single decline');
                System.AssertNotEquals('Escalated', dr.State__c , 'The request incorrectly escalated due to a single decline');
                System.AssertEquals('In Review', dr.State__c, 'The request did not become In Review from a single decline');
        	}
        
        	//Test Controller after user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, false);
        }
        test.stopTest();
            
    }
    
    static testMethod void validateDemoRequestDeclineTSM() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
		//Users to test with
        User jason = TestDemoRequestClass.GetTsmTestUser(0);
        
        System.runAs(jason){
        	//Testing Variables
        	Map<Id, String> idToStateMap = new Map<Id, String>(); 
        	List<Id> mgmt = new List<Id>{jason.Id};
        	System.debug('TSM Ids: ' + mgmt);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, QueueName__c FROM Demo_Request__c];
        	Integer count = request.size();
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
            	idToStateMap.put(dr.Id, dr.State__c);
        	}        
        
            Test.startTest();
        
        	//Decline with a single management user
        	TestDemoRequestClass.DeclineRequest(request, mgmt, '', null); 
        	for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];
                System.AssertEquals(1, declines.size(), 'The request did not have a single decline');
				System.AssertNotEquals('Escalated', dr.State__c , 'The request incorrectly escalated due to a single management decline');
                System.AssertEquals('In Review', dr.State__c, 'The request did not become In Review from a single management decline');
        	}
        }
        test.stopTest();
            
    }
    
    static testMethod void validateDemoRequestDeclineAllTSC() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        System.runAs(thisUser){
        
        	//Testing Variables
            List<Id> tscIds = DemoRequestFactory.BuildTSCList();
        	System.debug('All TSC Ids: ' + tscIds);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, Requested_Timezone__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}
        
            Test.startTest();
        
        	//Decline all TSCs and Check for Escalation
        	TestDemoRequestClass.DeclineRequest(request, tscIds, '', null);
        	for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];
                System.AssertEquals(tscIds.size(), declines.size(), 'The request did not have as many declines as users');
                
                Set<Id> decliners = new Set<Id>();
                List<Id> repeats = new List<Id>();
                for(Demo_Request_Decline__c d : declines) {
                    decliners.add(d.User_Name__c);
                	repeats.add(d.User_Name__c);
                }
                
                //should remove but sharing my pain
                System.AssertEquals(tscIds.size(), repeats.size(), 'The request did not have as many names as declines? list? wtf');
                System.AssertEquals(tscIds.size(), decliners.size(), 'The request did not have as many names as declines? set? wtf' + repeats);
				
                Integer count = 0;
                for(Id i : tscIds) {
                    count++;
                	System.assert(decliners.contains(i), 'Declines did not include TSC: ' + count + ' ' + i + ' ' + decliners);
                }

            	System.AssertEquals('Escalated', dr.State__c , 'The request did not escalate after all TSCs declined');
        	}
            
            Test.stopTest();
        }
    }
    
    static testMethod void validateDemoRequestDeclineAllTSM(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser){
        	//Testing Variables
        	List<Id> allMgmt = DemoRequestFactory.BuildTSMList();
        	System.debug('All TSM Ids: ' + allMgmt);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, Requested_Timezone__c, QueueName__c FROM Demo_Request__c];
        	Integer count = request.size();
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}        
        
            Test.startTest();
        
        	//Decline all of Management and Check for Declined state
        	TestDemoRequestClass.DeclineRequest(request, allMgmt, '', null); //decline with all Mgmt users
        	for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
            	System.AssertEquals('In Review', dr.State__c , 'The request did not remain in review after all TSMs declined');
        	}
        	Test.stopTest();
        }
    }
    
	static testMethod void validateDemoRequestDeclineAll(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        System.runAs(thisUser){
        	//Testing Variables
            List<Id> allIds = DemoRequestFactory.BuildAllTSList();
            List<Id> mgmtIds = DemoRequestFactory.BuildTSMList();
            List<Id> tscIds = DemoRequestFactory.BuildTSCList();
            //Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, Requested_Timezone__c, Requester_Email_Addr__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}        

            Test.startTest();
        
        	//Decline all of Management and Check for Declined state
        	System.debug('Declining ' + request.size() + ' requests with ' + allIds.size() + ' users');
        	TestDemoRequestClass.DeclineRequest(request, allIds, '', null); //decline with all users
            
        	for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];
                System.AssertEquals(allIds.size(), declines.size(), 'The request did not have as many declines as users');
                
                Set<Id> decliners = new Set<Id>();
                List<Id> repeats = new List<Id>();
                for(Demo_Request_Decline__c d : declines) {
                    decliners.add(d.User_Name__c);
                	repeats.add(d.User_Name__c);
                }
                
                //should remove but sharing my pain
                System.AssertEquals(allIds.size(), repeats.size(), 'The request did not have as many names as declines? list? wtf');
                System.AssertEquals(allIds.size(), decliners.size(), 'The request did not have as many names as declines? set? wtf' + repeats);
				
                Integer count =0;
                for(Id i : tscIds) {
                    count++;
                	System.assert(decliners.contains(i), 'Declines did not include TSC: ' + count + ' ' + i + ' ' + decliners);
                }
                count=0;
                for(Id i : mgmtIds) {
                    count++;
                	System.assert(decliners.contains(i), 'Declines did not include management: ' + count);
                }
                
            	System.AssertEquals('Declined', dr.State__c , 'The request did not decline after everyone declined');
        	}
        	Test.stopTest();
        }
        
        
    }
    
	static testMethod void validateDemoRequestDeclineTime() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
		//Users to test with
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
        	//Testing Variables
        	List<Id> tsc = new List<Id>{tscTest.Id};
        	System.debug('TSC Ids: ' + tsc);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, Requested_Timezone__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}        
        
            Test.startTest();
        
        	//Test controller before user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, true);
        
        	//Decline request with a single user.  Verify that the request does not escalate from this action unless it was previously escalated
        	TestDemoRequestClass.DeclineRequest(request, tsc, '11:30 AM', null); //decline with single user
        	for(Demo_Request__c dr : [SELECT State__c, Id FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];
                System.AssertEquals(1, declines.size(), 'The request did not have a single decline');
                System.AssertNotEquals('Escalated', dr.State__c , 'The request incorrectly escalated due to a single decline');
                System.AssertEquals('In Review', dr.State__c, 'The request did not become In Review from a single decline');
        	}
        
        	//Test Controller after user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, false);
        }
        test.stopTest();
            
    }
    
    static testMethod void validateDemoRequestDeclineDateTime() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
		//Users to test with
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
        	//Testing Variables
        	List<Id> tsc = new List<Id>{tscTest.Id};
        	System.debug('TSC Ids: ' + tsc);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}        
        
            Test.startTest();
        
        	//Test controller before user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, true);
        
        	//Decline request with a single user.  Verify that the request does not escalate from this action unless it was previously escalated
        	DateTime tim = DateTime.now().addDays(1);
        	TestDemoRequestClass.DeclineRequest(request, tsc, null, tim); //decline with single user
        	for(Demo_Request__c dr : [SELECT State__c, Id FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];
                System.AssertEquals(1, declines.size(), 'The request did not have a single decline');
                System.AssertNotEquals('Escalated', dr.State__c , 'The request incorrectly escalated due to a single decline');
                System.AssertEquals('In Review', dr.State__c, 'The request did not become In Review from a single decline');
        	}
        
        	//Test Controller after user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, false);
        }
        test.stopTest();
            
    }  

    static testMethod void validateDemoRequestDeclineBadDateTime() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
		//Users to test with
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        System.runAs(tscTest){
        	//Testing Variables
        	List<Id> tsc = new List<Id>{tscTest.Id};
        	System.debug('TSC Ids: ' + tsc);
        
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
        	}        
        
            Test.startTest();
        
        	//Test controller before user declines
        	TestDemoRequestClass.TestControllerAvailableRequests(request, tscTest, true);
        
        	//Decline request with a single user.  Verify that the request does not escalate from this action unless it was previously escalated
        	DateTime tim = DateTime.now().addDays(-1);
            
            String t = tim.format('hh:mm a');
            String d = tim.format('MM/dd/yyyy');
            
            for(Demo_Request__c r : request) {
                ApexPages.currentPage().getParameters().put('id',r.Id);
                ApexPages.StandardController stdRequest = new ApexPages.StandardController(r);
                DemoRequestDeclineExtension ext = new DemoRequestDeclineExtension(stdRequest);
                ext.declineReason = 'Demo Prep';            
                ext.rescheduleTime = t;
                ext.rescheduleDate = d;
                ext.selectedPerson = tscTest.Name;
                ext.selectPerson();
                ext.submitDecline();
                ApexPages.Message[] pageMessages = ApexPages.getMessages();
                System.assertNotEquals(0, pageMessages.size(), 'Did not get past warning on decline');
             }
            
        }
        test.stopTest();
            
    }  
    
    static testMethod void validateAutoDeclineFromDemo(){
        //Initalize Test Data
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];        
        //Create Test User
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        
        //Create Test Request
        List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        //Clone requests to check for auto decline on these requests
        List<Demo_Request__c> clonedRequest = new List<Demo_Request__c>();
        for(Demo_Request__c req : request){
        	Demo_Request__c dup = req.clone(false, true, false, false);
        	clonedRequest.add(dup);        	
        }
        
        Test.startTest();
        //Accept Request
        TestDemoRequestClass.AcceptRequest(request, tscTest);
                      
        Test.stopTest();
        
        insert clonedRequest;
        
        //Test Validation
        List<Id> clonedIds = new List<Id>();
		for(Demo_Request__c clone : clonedRequest){
            DemoRequestClass.AutoDeclineRequest(clone);
			clonedIds.add(clone.Id);
		}
		
		List<Demo_Request_Decline__c> autoDeclines = [SELECT Id, Demo_Request_ID__c, User_Name__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c IN : clonedIds AND User_Name__c = :tscTest.Id];
		
		System.Assert(!autoDeclines.isEmpty(), 'No Auto Declines were created for the cloned requests');
		System.AssertEquals(autoDeclines.size(), clonedRequest.size(), 'An Auto Decline was not created for every cloned request');
        TestDemoRequestClass.TestControllerAutoDeclinedRequests(tscTest, clonedRequest);
        
    }
    
    static testMethod void validateAutoDeclineFromEvent(){
        //Initalize Test Data
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
            DemoRequestClass.AutoDeclineRequest(r);
			requestIds.add(r.Id);
		}
		
		List<Demo_Request_Decline__c> autoDeclines = [SELECT Id, Demo_Request_ID__c, User_Name__c FROM Demo_Request_Decline__c WHERE Demo_Request_ID__c IN : requestIds AND User_Name__c = :tscTest.Id];
		
		System.Assert(!autoDeclines.isEmpty(), 'No Auto Declines were created for the requests');
		System.AssertEquals(autoDeclines.size(), request.size(), 'An Auto Decline was not created for every request');
        TestDemoRequestClass.TestControllerAutoDeclinedRequests(tscTest, request);
        
    }
    
    static testMethod void validateCannotDeclineAcceptedRequest() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
        //Users to test with
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        system.debug('Starting validateCannotDeclineAcceptedRequest run as user: ' + tscTest.Id);
        System.runAs(tscTest){
            Demo_Request__c demo = TestDemoRequestClass.createRandomDemoRequest(null);
            TestDemoRequestClass.AcceptSelfRequest(new List<Demo_Request__c>{demo}, tscTest);
            TestDemoRequestClass.CheckCannotDecline(new List<Demo_Request__c>{demo});
        }
    }
    
    static testMethod void validateDemoRequestDeclineInReview() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        
		//Users to test with
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        User tscTest2 = TestDemoRequestClass.GetTscTestUser(1);
        
        System.runAs(tscTest){
        
        	//Testing Variables
            List<Id> tscIds = DemoRequestFactory.BuildTSCList();
        	System.debug('All TSC Ids: ' + tscIds);
        
            TestDemoRequestClass.CreateAdHocEvent('PTO', 'Busy', tscTest2);
            
        	//Create Requests
        	List<Demo_Request__c> request = TestDemoRequestClass.CreateRequest(1, null);
        	//Get Current state of demos after workflow/triggers have run
        	request = [SELECT Id, State__c, Demo_Date_Time__c, Requested_Timezone__c, QueueName__c FROM Demo_Request__c];
        	List<Id> requestIds = new List<Id>();
        	for(Demo_Request__c dr : request){
            	requestIds.add(dr.Id);
                System.assertEquals('Submitted', dr.State__c, 'The request did not start as submitted');
        	}
        
            Test.startTest();
        	
        	//Decline all TSCs and Check for Escalation
            TestDemoRequestClass.DeclineRequest(request, new List<Id>{tscTest.Id}, '', null);
        	for(Demo_Request__c dr : [SELECT State__c FROM Demo_Request__c WHERE ID IN :requestIds]){
                List<Demo_Request_Decline__c> declines = [Select User_Name__c from Demo_Request_Decline__c where Demo_Request_ID__c = :dr.Id];

            	System.AssertEquals('In Review', dr.State__c , 'The request did go to in-review on first real decline');
        	}
            
            Test.stopTest();
        }
    }
    
}