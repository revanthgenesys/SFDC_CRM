@isTest
public class TestDemoProcessSeeAllData {
    
    @isTest(SeeAllData=True) 
    static void ValidateAllChatterPosts(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tsc = new List<User>();
        List<User> tsm = new List<User>();
		System.runAs(thisUser) {
            tsc = DemoRequestFactory.CreateTscTestUsers(7);
            tsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tsc, tsm);
        DemoRequestFactory.InitializeDataWithSeeAllData();
        //Testing Variables
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        String orgUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        Integer comments;
        /*
        System.runAs(tscTest){
        	
            Test.startTest();
            //Create Request
			List<Demo_Request__c> requests = TestDemoRequestClass.CreateRequest(1, null);
            DemoRequestClass.PostToChatter(requests, 'Submit');
            
            //Validate chatter posts for demo creation
            Map<Id, Id> requestToFeed = new Map<Id, Id>();
            for(Demo_Request__c d : requests){
                System.assert(d.Chatter_Feed_ID__c != null, 'The Chatter Feed ID was not updated on the demo request');
                ConnectApi.FeedElement feedElement  = ConnectApi.ChatterFeeds.getFeedElement(null, d.Chatter_Feed_ID__c);
        		System.assertEquals('A new demonstration request has been submitted. ' + orgUrl + d.Id, feedElement.body.text, 'The feed element text is not correct');
                requestToFeed.put(d.Id, d.Chatter_Feed_ID__c);
            }
            
            //Reschedule Request
            //TestDemoRequestClass.RescheduleRequest(requests);  //not really necessary since class checks for test.  Posts have to be tested manually
            DemoRequestClass.PostToChatter(requests, 'Reschedule');
            //Validate reschedule chatter post
            for(Id dResId : requestToFeed.keySet()){
                System.assertEquals(1, TestDemoRequestClass.getDemoCommentCount(requestToFeed.get(dResId)), 'The Reschedule Comment was not added to this chatter feed');
                System.assertEquals('This request has been Rescheduled.  Please review the new Date and Time of the request', TestDemoRequestClass.getDemoCommentBody(requestToFeed.get(dResId), 0), 'The Reschedule Comment text is incorrect');
            }
            
            //Decline TSCs and Escalate Request
            //TestDemoRequestClass.DeclineRequest(request, tscIds); //not really necessary since class checks for test.  Posts have to be tested manually
            DemoRequestClass.PostToChatter(requests, 'Escalate');
            //Validate escalate chatter post
            for(Id dResId : requestToFeed.keySet()){
                System.assertEquals(2, TestDemoRequestClass.getDemoCommentCount(requestToFeed.get(dResId)), 'The Escalate Comment was not added to this chatter feed');
                System.assertEquals('This request has been Escalated for Management Review.', TestDemoRequestClass.getDemoCommentBody(requestToFeed.get(dResId), 1), 'The Escalation Comment text is incorrect');
            }
            
            DemoRequestClass.PostToChatter(requests, 'Decline');
            //Validate decline chatter post
            for(Id dResId : requestToFeed.keySet()){
                System.assertEquals(3, TestDemoRequestClass.getDemoCommentCount(requestToFeed.get(dResId)), 'The Decline Comment was not added to this chatter feed');
                System.assertEquals('This request has been Declined.  All Technical Sales Members are unavailable.', TestDemoRequestClass.getDemoCommentBody(requestToFeed.get(dResId), 2), 'The Decline Comment text is incorrect');
            }
            
            DemoRequestClass.PostToChatter(requests, 'Cancel');
            //Validate cancel chatter post
            for(Id dResId : requestToFeed.keySet()){
                System.assertEquals(4, TestDemoRequestClass.getDemoCommentCount(requestToFeed.get(dResId)), 'The Cancel Comment was not added to this chatter feed');
                System.assertEquals('This request has been Cancelled.', TestDemoRequestClass.getDemoCommentBody(requestToFeed.get(dResId), 3), 'The Cancel Comment text is incorrect');
            }
            
            DemoRequestClass.AcceptDemos(new Map<Demo_Request__c, Id>{requests[0] => tscTest.Id});
            DemoRequestClass.PostToChatter(requests, 'Accept');
            //Validate accept chatter post
            for(Id dResId : requestToFeed.keySet()){
                System.assertEquals(5, TestDemoRequestClass.getDemoCommentCount(requestToFeed.get(dResId)), 'The Accept Comment was not added to this chatter feed');
                System.assertEquals('This request has been Accepted by: '+tscTest.Name, TestDemoRequestClass.getDemoCommentBody(requestToFeed.get(dResId), 4), 'The Accept Comment text is incorrect');
            }

        }
		*/
    } 
    
    @isTest(SeeAllData=True) 
    static void createOnSiteDemo() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        List<User> tsc = new List<User>();
        List<User> tsm = new List<User>();
		System.runAs(thisUser) {
            tsc = DemoRequestFactory.CreateTscTestUsers(7);
            tsm = DemoRequestFactory.CreateTsmTestUsers(1);
        }
        
        DemoRequestFactory.CreateDemonstrationPresenters(tsc, tsm);
        DemoRequestFactory.InitializeDataWithSeeAllData();
        User tscTest = TestDemoRequestClass.GetTscTestUser(0);
        /*
        System.runAs(tscTest){
            DemoRequestSubmissionController ext = TestDemoRequestClass.createRandomDemoRequestSkeleton();
            ext.backToSchedule();
            ext.drb.demoLocation = 'On-site (Requires Approval)';
            ext.checkAvail();
            ext.getLocationDetails();
            System.assert(ext.showOnsite, 'On-site additional information was not shown when choosen');
            ext.drb.onsiteDemoLocation = 'New England. The Patriots want a demo!';
            ext.drb.onsiteJustify = 'The Patriots cheat to win... Do what you gotta do';
            ext.submitWhen();
            ext.submitVerify();
            
            Demo_Request__c demo = ext.req;
            
            System.assertEquals('Pending Approval', demo.State__c, 'Demo did not submit an onsite correctly');
            
            TestDemoRequestClass.CancelRequests(new List<Demo_Request__c>{demo});
            
            System.assertEquals('Cancelled', demo.State__c, 'Demo did not cancel correctly with an approval process');
        }
		*/
    }
    
}