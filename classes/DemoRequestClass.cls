public without sharing class DemoRequestClass {
    
    //region Triggers
    public static void AfterReqUpdate(List<Demo_Request__c> requests){
        List<Demo_Request__c> requestsToNotify = new List<Demo_Request__c>();
        for(Demo_Request__c d : requests){
            if(d.NotifyNonDeclined__c && DemoRequestUtility.activeDemoStates.contains(d.State__c)){
                requestsToNotify.add(d);
            }
        }
        
        if(!requestsToNotify.isEmpty()) DemoRequestEmails.SendCallToActionEmail(requestsToNotify);
    }
    
    //end region Triggers

    //region Actions
    public static void CancelDemos(List<Demo_Request__c> ds){
        for(Demo_Request__c d : ds){
            if(d.State__c == 'Pending Approval') {
                RemoveApprovalProcess(d);
            }
            d.State__c = 'Cancelled';
        }
        
        removeDeclinesPresentersTracking(ds);
        update ds;
        DemoRequestClass.CheckTestBeforePost(ds, DemoRequestUtility.chatterPostType.get(4));
    }
    
    public static void RemoveApprovalProcess(Demo_Request__c d) {
        try{
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction('Removed');
            ProcessInstanceWorkItem item = [Select p.Id from ProcessInstanceWorkItem p where p.ProcessInstance.TargetObjectId = :d.Id];
            pwr.setWorkItemId(item.Id);
            pwr.setComments('Demo Cancelled');
            Approval.ProcessResult result = Approval.process(pwr);
        } catch (Exception e) {
            system.debug(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Error with removing approval process: ' + e.getMessage()));
        }
    }
    
    public static void DeclineDemos(List<Demo_Request_Decline__c> declines){       
        insert declines;
    }
    
    public static void CompleteDemos(List<Demo_Request__c> demos){
        for(Demo_Request__c d : demos) {
            d.State__c = 'Completed';
            d.Timestamp_Completed__c = DateTime.now();
            system.debug('Completeing demo: ' + d.Id);
        }
        update demos;
    }
    
    public static void CompleteTraining(Demo_Request__c demo){
        List<Demo_Request_Tracking__c> tracks = [SELECT Id FROM Demo_Request_Tracking__c WHERE Demo_Request__c = :demo.Id AND Activity_Type__c = 'Demo Training' AND Activity_State__c != 'Completed'];
        if(tracks.isEmpty()) CompleteDemos(new List<Demo_Request__c>{demo});
    }
    
    public static void AcceptDemos(Map<Demo_Request__c, Id> ds){
        system.debug('Accepting ' + ds.size() + ' demos');
        List<Demo_Request__c> saveDemos = new List<Demo_Request__c>();
        List<Request_Presenter_Junction__c> removeps = new List<Request_Presenter_Junction__c>();
        List<Demo_Request_Tracking__c> removets = new List<Demo_Request_Tracking__c>();
        List<Demonstration_Presenter__c> users = [Select Id, User_Name__c, Presenter_E_mail__c, Presenter_Signature__c  from Demonstration_Presenter__c];
        
        Map<Id, Id> demoRequestOwner = new Map<Id, Id>();
        Map<Id, Demo_Request__c> demoPresenterId = new Map<Id, Demo_Request__c>();
        Map<Id, Demo_Request__c> demoUserId = new Map<Id, Demo_Request__c>();
        Map<Id,Id> presenterToUser = new Map<Id, Id>();
        Map<Id,Id> userToPresenter = new Map<Id, Id>();
        Map<Id, Demonstration_Presenter__c> presenterDetails = new Map<Id, Demonstration_Presenter__c>();
        Set<Id> multiActDemo = new Set<Id>();
        Set<Id> previousPresenters = new Set<Id>();
        Set<Id> previousDemoActivity = new Set<Id>();
        
        //map presenterIds to UserId (owner)
        for(Demonstration_Presenter__c u : users){
            presenterToUser.put(u.Id, u.User_Name__c);
            userToPresenter.put(u.User_Name__c, u.Id);
            presenterDetails.put(u.User_Name__c, u);
        }
        
        for(Demo_Request__c req : ds.keySet()) {
            //collect ownerIds
            if(req.Demo_Owner__c != null) {
                demoRequestOwner.put(req.Id, req.Demo_Owner__c);
            }
        }
        //Get all presenters from demos with owners
        List<Request_Presenter_Junction__c> p = [Select Id, Demonstration_Presenter__c, Demo_Request__c, Demonstration_Presenter__r.User_Name__c from Request_Presenter_Junction__c where Demo_Request__c in :demoRequestOwner.keySet()];
        List<Demo_Request_Tracking__c> t = [Select Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, Demo_Request__c, Activity_Completed_By__c, GoToMeeting_ID__c, isTemplate__c, hasEvent__c from Demo_Request_Tracking__c where Demo_Request__c in :ds.keySet()];
        
        for(Request_Presenter_Junction__c r : p) {
            previousPresenters.add(r.Demonstration_Presenter__r.User_Name__c);
        }
        system.debug('Retrieved ' + t.size() + ' activities for ' + ds.size() + ' demos');
        for(Demo_Request_Tracking__c tr : t) {
            if(tr.Activity_Type__c == 'Demo' || tr.Activity_Type__c == 'Tradeshow' || tr.Activity_Type__c == 'Demo Training') {
                previousDemoActivity.add(tr.Activity_Completed_By__c);
            }
            Boolean hasMultipleActs = tr.isTemplate__c && !multiActDemo.contains(tr.Demo_Request__c);
            if(hasMultipleActs) {
                	multiActDemo.add(tr.Demo_Request__c);
            }
            system.debug(tr.Id + ' tracking, has multiple acts: ' + hasMultipleActs);
        }
        
        //add them as presenter and demo activity
        for(Demo_Request__c req : ds.keySet()) {
            //skip them if previous presenter (already have presenter and tracking item)
            if(!previousPresenters.contains(ds.get(req)))
                demoPresenterId.put(userToPresenter.get(ds.get(req)), req);
            if(!previousDemoActivity.contains(ds.get(req)))
                demoUserId.put(ds.get(req), req);
        }
        
        //delete old owner's presenter object
		removeps.addAll(getPreviousPresenterList(p, demoRequestOwner, presenterToUser));
        
        //delete old owner's tracking object
        removets.addAll(getPreviousTrackingItems(t, demoRequestOwner));
        
        Map<Id, Id> demoIdtoUserId = new Map<Id, Id>();
        for(Demo_Request__c req : ds.keySet()) {
            System.debug('User: ' + ds.get(req));
            String newOwnerId = ds.get(req);
            demoIdtoUserId.put(req.Id, newOwnerId);
            Demonstration_Presenter__c pres = presenterDetails.get(newOwnerId);
            //accept demo and add owner
            req.State__c = 'Accepted';
            req.Demo_Owner__c = newOwnerId;
            if(pres.Presenter_E_mail__c != null)
                req.Demo_Owner_Email__c = pres.Presenter_E_mail__c;
            if(pres.Presenter_Signature__c != null)
                req.Demo_Owner_Signature__c = pres.Presenter_Signature__c;
            if(req.Timestamp_Accepted__c == null)
                req.Timestamp_Accepted__c = DateTime.now();
            saveDemos.add(req);  
        }
        removeDemoActivity(removets);
        update saveDemos;        
        removePresenter(removeps);
        addPresenter(demoPresenterId);
        for(Demo_Request__c req : ds.keySet()) {
            if(multiActDemo.contains(req.Id)) {
                //skip this if previous presenter
                boolean wasPresenter = false;
                for(Id r : previousPresenters){
                	if(previousPresenters.contains(r)){
                    	wasPresenter = true;
                        system.debug('Skipped activities due to previous presenter for: ' + req.Id);
                        break;
                	}
                }
                if(wasPresenter) continue;
                system.debug('creating mulitple activities for demo: ' + req.Id);
                createEventActivities(t, demoIdtoUserId);
                if(req.Request_Type__c != 'Webinar Series')
                	DemoRequestEventBuilder.CreateEventsFromDemo(req, new List<Id>{demoIdtoUserId.get(req.Id)});
            } else {
                system.debug('creating demo activity for demo: ' + req.Id);
                addDemoActivity(demoUserId);
            }
        }
        DemoRequestClass.AddOppTeamMember(saveDemos);
        DemoRequestClass.CheckTestBeforePost(saveDemos, DemoRequestUtility.chatterPostType.get(5));
    }
    
    private static List<Request_Presenter_Junction__c> getPreviousPresenterList(List<Request_Presenter_Junction__c> p, Map<Id, Id> demoRequestOwner, Map<Id,Id> presenterToUser) {
        List<Request_Presenter_Junction__c> foundList = new List<Request_Presenter_Junction__c>();
        for(Request_Presenter_Junction__c pres : p) {
            if(demoRequestOwner.get(pres.Demo_Request__c) == presenterToUser.get(pres.Demonstration_Presenter__c)) {
                foundList.add(pres);
                System.debug('Removing presenter:' + pres.Demonstration_Presenter__c + ' of demo: ' + pres.Demo_Request__c);
            }
        }
        return foundList;
    }
    
    private static List<Demo_Request_Tracking__c> getPreviousTrackingItems(List<Demo_Request_Tracking__c> t, Map<Id, Id> demoRequestOwner) {
        List<Demo_Request_Tracking__c> foundList = new List<Demo_Request_Tracking__c>();
        for(Demo_Request_Tracking__c ts : t) {
            if(demoRequestOwner.get(ts.Demo_Request__c) == ts.Activity_Completed_By__c && (ts.Activity_Type__c == 'Demo' || ts.Activity_Type__c == 'Tradeshow') && !ts.isTemplate__c) {
                foundList.add(ts);
                System.debug('Updating tracking activity to new owner: ' + ts.Activity_Completed_By__c);
            }
        }
        return foundList;
    }
    
    public static void RescheduleDemos(Map<Demo_Request__c, DateTime> ds, Map<Id, Demo_Request__c> oldRequests) {
        //update demos
        List<Demo_Request__c> saveDemos = rescheduleLogicState(ds, oldRequests);
        removeDeclinesPresentersTracking(saveDemos);

        rescheduleLogicNotify(saveDemos, oldRequests);
        for(Demo_Request__c d : saveDemos) AutoDeclineRequest(d);
    }
    
    public static void RescheduleAndAccept(Map<Demo_Request__c, DateTime> ds, Map<Id, Demo_Request__c> oldRequests) {
        //update demos
        List<Demo_Request__c> saveDemos = new List<Demo_Request__c>();
        Boolean wasAccepted = false; 
        Boolean ownerChanged = false;
        for(Demo_Request__c d : ds.keySet()) {
            Demo_Request__c oldRequest = oldRequests.get(d.Id);
            if(oldRequest.Demo_Owner__c != null) wasAccepted = true;
            if(oldRequest.Demo_Owner__c != d.Demo_Owner__c) ownerChanged = true;
            if(d.State__c != 'Pending Approval') d.State__c = 'Accepted';
            saveDemos.add(d);
        }
        
        if(wasAccepted){
            rescheduleUpdateActivities(saveDemos, oldRequests);
            if(ownerChanged) UpdatePresenter(saveDemos, oldRequests);
            rescheduleLogicNotify(saveDemos, oldRequests);
        } else {
            Map<Demo_Request__c, Id> reqToOwner = new Map<Demo_Request__c, Id>();
            for(Demo_Request__c r : saveDemos){
                reqToOwner.put(r, r.Demo_Owner__c);
            }
            AcceptDemos(reqToOwner);
        }                      
    }
    
    private static void rescheduleUpdateActivities(List<Demo_Request__c> demos, Map<Id, Demo_Request__c> oldRequest) {
        Set<Id> demoIds = new Set<Id>();
        Map<Id, Demo_Request__c> idToDemo = new Map<Id, Demo_Request__c>();
        Set<Id> ownerIds = new Set<Id>();
        for(Demo_Request__c d : demos) {
            demoIds.add(d.Id);
            idToDemo.put(d.Id, d);
            Demo_Request__c oldReqOwner = oldRequest.get(d.Id);
            ownerIds.add(oldReqOwner.Demo_Owner__c);
        }
        List<Demonstration_Presenter__c> pres = [SELECT Id, GTM_Access_Token__c, User_Name__c FROM Demonstration_Presenter__c WHERE User_Name__c IN :ownerIds];
        Map<Id, String> presToToken = new Map<Id, String>();
        for(Demonstration_Presenter__c p : pres){
            presToToken.put(p.User_Name__c, p.GTM_Access_Token__c);
        }
        List<Demo_Request_Tracking__c> updateTracks = new List<Demo_Request_Tracking__c>();
        List<Demo_Request_Tracking__c> tracks = [SELECT Id, Name, Activity_Type__c, Activity_Date_Time__c, Activity_Duration__c, Activity_Completed_By__c,
                                                 Demo_Request__c, GoToMeeting_JoinURL__c, GTM_ConfCall__c, GoToMeeting_ID__c 
                                                 FROM Demo_Request_Tracking__c where Demo_Request__c IN :demoIds and Activity_Type__c = :'Demo'];
        Map<Id, Demo_Request_Tracking__c> oldTrack = new Map<Id, Demo_Request_Tracking__c>();
        for(Demo_Request_Tracking__c track : tracks) {
            Demo_Request_Tracking__c tempTrack = track.clone(true, true, true, true);
            oldTrack.put(tempTrack.Id, tempTrack);
            Demo_Request__c d = idToDemo.get(track.Demo_Request__c);
            Demo_Request__c oldD = oldRequest.get(track.Demo_Request__c);
            Demo_Request_Tracking__c t = new DemoRequestTrackingBuilder(track)
                             			.withRequestTime(d)
                						.tracking;
            if(track.Activity_Completed_By__c == oldD.Demo_Owner__c) t.Activity_Completed_By__c = d.Demo_Owner__c;
            updateTracks.add(t);
            if(track.GoToMeeting_ID__c == null) continue;            
            DemoRequestGTMActions gtm = new DemoRequestGTMActions(track.Activity_Completed_By__c);
            gtm.meetingId = track.GoToMeeting_ID__c;
            if(d.Demo_Owner__c == oldD.Demo_Owner__c){
                if(presToToken.get(d.Demo_Owner__c) == null) continue;
               	string subject = DemoRequestEventBuilder.createEventSubject(d, track.Activity_Type__c.trim());
                DateTime startTime = track.Activity_Date_Time__c;
                DateTime endTime = track.Activity_Date_Time__c.addHours(track.Activity_Duration__c.intValue()).addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(track.Activity_Duration__c));
                gtm.updateMeeting(subject, startTime, endTime); 
            } else {
                if(presToToken.get(oldD.Demo_Owner__c) != null){
                    gtm.accessToken = presToToken.get(oldD.Demo_Owner__c);
                    gtm.deleteMeeting();
                } 
            }            
        }                                                                                                   

        update updateTracks;
        UpdateEvent(updateTracks, oldTrack);
    }
    
    private static void UpdatePresenter(List<Demo_Request__c> demos, Map<Id, Demo_Request__c> oldRequest){
        Set<Id> requestIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        List<Request_Presenter_Junction__c> presToUpdate = new List<Request_Presenter_Junction__c>();
        List<Request_Presenter_Junction__c> presToRemove = new List<Request_Presenter_Junction__c>();
        for(Demo_Request__c d : demos){
            requestIds.add(d.Id);
            ownerIds.add(d.Demo_Owner__c);
            Demo_Request__c oldD = oldRequest.get(d.Id);
            ownerIds.add(oldD.Demo_Owner__c);
        }
        List<Demonstration_Presenter__c> pres = [Select Id, User_Name__c FROM Demonstration_Presenter__c WHERE User_Name__c IN :ownerIds];
        List<Request_Presenter_Junction__c> presJ = [Select Id, Demo_Request__c, Demonstration_Presenter__c from Request_Presenter_Junction__c where Demo_Request__c in :requestIds];
        
        Map<Id, Demonstration_Presenter__c> userToPres = new Map<Id, Demonstration_Presenter__c>();
        Map<Id, List<Request_Presenter_Junction__c>> reqToPres = new Map<Id, List<Request_Presenter_Junction__c>>();
        for(Demonstration_Presenter__c p : pres){
            userToPres.put(p.User_Name__c, p);
        }
        
        for(Request_Presenter_Junction__c pJ : presJ){
            if(reqToPres.containsKey(pJ.Demo_Request__c)){
                reqToPres.get(pJ.Demo_Request__c).add(pJ);
            } else {
                reqToPres.put(pJ.Demo_Request__c, new List<Request_Presenter_Junction__c>{pJ});
            }
        }
        
        for(Demo_Request__c demo : demos){
            Demo_Request__c oldDemo = oldRequest.get(demo.Id);
            if(demo.Demo_Owner__c == oldDemo.Demo_Owner__c) continue;
            Demonstration_Presenter__c oldPres = userToPres.get(oldDemo.Demo_Owner__c);
            Demonstration_Presenter__c newPres = userToPres.get(demo.Demo_Owner__c);
            List<Request_Presenter_Junction__c> presenters = reqToPres.get(demo.Id);            
            for(Request_Presenter_Junction__c rp : presenters){
                if(rp.Demonstration_Presenter__c != oldPres.Id) continue;
                Request_Presenter_Junction__c updatePres = new Request_Presenter_Junction__c();
                updatePres.Demonstration_Presenter__c = newPres.Id;
                updatePres.Demo_Request__c = demo.Id;
                presToUpdate.add(updatePres);
                presToRemove.add(rp);
            }
        }
        
        insert presToUpdate;
        delete presToRemove;
    }
    
    private static List<Demo_Request__c> rescheduleLogicState(Map<Demo_Request__c, DateTime> ds, Map<Id, Demo_Request__c> oldRequests) {
        //update demos
        List<Demo_Request__c> saveDemos = new List<Demo_Request__c>();
        for(Demo_Request__c d : ds.keySet()) {
            System.debug('Timezone: ' + d.Requested_Timezone__c);
            System.debug('Time: ' + d.Demo_Date_Time__c);
            //Check if demo is soon to escalate
            if(d.State__c == 'Pending Approval') {
                //skip state change for approval process
            } else if(DemoRequestUtility.EscalateForRequestedTime(ds.get(d))){
                d.State__c = 'Escalated';
                d.Escalate_Request_Time__c = true;
                d.Escalation_Reason__c = 'Rescheduled With Short Notice';
            } else {
                d.State__c = 'Rescheduled';
                d.Escalate_Request_Time__c = false;
            }
            d.Demo_Owner__c = null;
            
            saveDemos.add(d);
        }
        return saveDemos;
    }
    
    private static void rescheduleLogicNotify(List<Demo_Request__c> saveDemos, Map<Id, Demo_Request__c> oldRequests) {
        update saveDemos;
        
        DemoRequestEmails.SendRescheduleEmail(saveDemos, oldRequests);
        DemoRequestClass.CheckTestBeforePost(saveDemos, DemoRequestUtility.chatterPostType.get(1));
    }
    
    private static void checkDeleteGTMBulk(List<Demo_Request_Tracking__c> tracks) {
        for(Demo_Request_Tracking__c track : tracks) {
            checkDeleteGTM(track);
        }
    }
    
    private static void checkDeleteGTM(Demo_Request_Tracking__c track) {
        if(track.GoToMeeting_ID__c == null) return;
        DemoRequestGTMActions gtm = new DemoRequestGTMActions(track.Activity_Completed_By__c);
        gtm.meetingId = track.GoToMeeting_ID__c;
        if(!gtm.hasValidToken) return;
        HTTPResponse response = gtm.deleteMeeting();
        
        if(response.getStatusCode() != 204){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attemping to delete your GoToMeeting.  The service responded with a message of  '
                                                       + response.getStatus() + '.  Please manually delete the related gtm meeting.  If the error persists, please contact the Technical Sales Development Team.'));
        }
    }
    
    private static void removeDeclinesPresentersTracking(List<Demo_Request__c> ds) {
        //one liner to turn list of objects to a set of ids
        Set<Id> allIds = (new Map<Id,Demo_Request__c>(ds)).keySet();
        
        //remove previous activity
        List<Demo_Request_Tracking__c> tracks = [Select Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c,
                                                 Demo_Request__c, Activity_Completed_By__c, GoToMeeting_ID__c from Demo_Request_Tracking__c where Demo_Request__c
                                                 in :allIds and (Activity_Date_Time__c >= :Datetime.now() or (Activity_Type__c = 'Demo' and Activity_State__c != 'Completed'))];
        checkDeleteGTMBulk(tracks);
        CancelEvent(tracks);
        delete tracks;
                
        //remove previous declines
        List<Demo_Request_Decline__c> declines = [Select Id from Demo_Request_Decline__c where Demo_Request_ID__c in :allIds];
        delete declines;
        
        //remove previous presenters
        List<Request_Presenter_Junction__c> pres = [Select Id from Request_Presenter_Junction__c where Demo_Request__c in :allIds];
        delete pres;
    }
    
    public static void addPresenter(Map<Id, Demo_Request__c> demoPresenterId) {
        if(demoPresenterId.size() < 1) return;
        List<Request_Presenter_Junction__c> addPresenter = new List<Request_Presenter_Junction__c>();
        for(Id i : demoPresenterId.keySet()) {
            Request_Presenter_Junction__c presenter = new Request_Presenter_Junction__c();
            presenter.Demonstration_Presenter__c = i;
            presenter.Demo_Request__c = demoPresenterId.get(i).Id;
            addPresenter.add(presenter);
        }
        
        insert addPresenter;
    }
    
    public static void removePresenter(List<Request_Presenter_Junction__c> presenters) {
        if(presenters.size() < 1) return;
        delete presenters;
    }
    
    public static void addDemoActivity(Map<Id, Demo_Request__c> demoUserId) {
        if(demoUserId.size() < 1) return;
        
        List<Demo_Request_Tracking__c> addTracking = new List<Demo_Request_Tracking__c>();
        
        for(Id i : demoUserId.keySet()) {       
            if(demoUserId.get(i).AudienceType__c == 'Tradeshow') continue;
            Demo_Request__c demo = demoUserId.get(i);
            DemoRequestTrackingBuilder trb = new DemoRequestTrackingBuilder()
                .withOwner(i)
                .withState('Not Started')
                .withType('Demo')
                .withRequestFullInfo(demo);
                
            addTracking.add(trb.tracking);
            system.debug('Added demo activity tracking for demo: ' + demo.Id + ' for user: ' + i);
        }
        
        insert addTracking;
        CreateRelatedTrackingItems(addTracking);
        DemoRequestEventBuilder.CreateEventsFromActivity(addTracking);
    }
    
    public static void createEventActivities(List<Demo_Request_Tracking__c> acts, Map<Id, Id> ds) {
        List<Demo_Request_Tracking__c> tracks = new List<Demo_Request_Tracking__c>();
        for(Demo_Request_Tracking__c t : acts) {
            if(!t.isTemplate__c) continue;
            for(Id d : ds.keySet()) {
                if(d != t.Demo_Request__c) continue;
                system.debug('creating activity for ' + ds.get(d));
                DemoRequestTrackingBuilder trb = new DemoRequestTrackingBuilder()
                    .withTemplate(t)
                    .withOwner(ds.get(d));
                tracks.add(trb.tracking);
            }
        }
        if(tracks.size() > 0) DemoRequestTrackingBuilder.buildBulk(tracks);
    }
    
    //ToDo move to activity builder
    public static void removeDemoActivity(List<Demo_Request_Tracking__c> acts) {
        if(acts.size() < 1) return;
        checkDeleteGTMBulk(acts);
        CancelEvent(acts);
        system.debug('deleting ' + acts.size() + ' events');
        delete acts;
    }
    
    public static void SetToInReview(List<Demo_Request__c> demos) {
        for(Demo_Request__c d : demos) {
            d.State__c = 'In Review';
        }
        update demos;
    }
    
    public static void SetToEscalate(List<Demo_Request__c> demos) {
        for(Demo_Request__c d : demos) {
            d.State__c = 'Escalated';
            d.Escalation_Reason__c = 'TSCs Unavailable';
        }
        update demos;
        DemoRequestClass.CheckTestBeforePost(demos, DemoRequestUtility.chatterPostType.get(2));
        DemoRequestEmails.SendEscalationEmail(demos);
        
    }
    
    public static void SetToDeclined(List<Demo_Request__c> demos) {
        for(Demo_Request__c d : demos) {
            d.State__c = 'Declined';
        }
        update demos;
        for(Demo_Request__c d : demos) {
            DemoRequestEmails.SendDeclineEmail(d);
        }
        DemoRequestClass.CheckTestBeforePost(demos, DemoRequestUtility.chatterPostType.get(3));
    }
    
    public static Boolean checkLastModified(Demo_Request__c demo){
        if(Test.isRunningTest()) return true;
        DateTime viewer = demo.LastModifiedDate;
        Demo_Request__c recent = [Select LastModifiedDate from Demo_Request__c where Id=:demo.Id];
        return recent.LastModifiedDate == viewer;
    }
    
    public static void createApprovalProcess(Demo_Request__c demo) {
        if(!checkIfShouldRunApproval(demo)) return;
        if(Test.isRunningTest()) return;
        
        Approval.ProcessSubmitRequest sr = new Approval.ProcessSubmitRequest();
        sr.setObjectId(demo.Id);
        sr.setProcessDefinitionNameOrId('DemoRequest_OnSite_Demo_Requested');
        Approval.process(sr);
    }
    
    public static Boolean checkIfShouldRunApproval(Demo_Request__c demo) {
        if(demo.Demo_Location__c != 'On-site (Requires Approval)') return false;
        if(demo.Demo_Date_Time__c < DateTime.now()) return false;
        if(demo.Request_Type__c == 'Training' || demo.Request_Type__c == 'Tradeshow' || 
           demo.Request_Type__c == 'Webinar Series' || demo.Request_Type__c == 'Bootcamp') return false;
        
        return true;
    }
    //endregion
    
    private static void AddOppTeamMember(List<Demo_Request__c> request){
        List<OpportunityTeamMember> oppTeamMmbr = new List<OpportunityTeamMember>();
        List<AccountTeamMember> acctTeamMmbr = new List<AccountTeamMember>();
        String teamRole = 'Technical Sales Consultant';
        
        for(Demo_Request__c req : request){
            if(req.Opportunity__c != null){
                OpportunityTeamMember oppTM = new OpportunityTeamMember();            
                
                oppTM.UserId = req.Demo_Owner__c;
                oppTM.OpportunityId = req.Opportunity__c;
                oppTM.TeamMemberRole = teamRole;
                
                oppTeamMmbr.add(oppTM);       		
            } 
            if(req.Account__c != null){
                AccountTeamMember acctTeam = new AccountTeamMember();
                acctTeam.UserId = req.Demo_Owner__c;
                acctTeam.AccountId = req.Account__c;
                acctTeam.TeamMemberRole = teamRole;	
                acctTeamMmbr.add(acctTeam);        		
            }            
        }
        if(!oppTeamMmbr.isEmpty()){
            insert oppTeamMmbr;
        }
        if(!acctTeamMmbr.isEmpty()){
            insert acctTeamMmbr;
        }
    }
    
    //ToDo can debulkify, move to tracking-builder and base off completing activity
    public static void AddOppIntegrationInterest(List<Demo_Request_Tracking__c> track){
        Set<Id> requestIds = new Set<Id>();
        Set<Id> trackIds = new Set<Id>();
        Map<Id, Id> reqToOpp = new Map<Id, Id>();
        Map<Id, Set<Id>> trackToInt = new Map<Id, Set<Id>>();
        List<Opportunity_Integration_Interest__c> oppIntegration = new List<Opportunity_Integration_Interest__c>();
        Map<Id, Set<Id>> oppToInt = new Map<Id, Set<Id>>();
        
        for(Demo_Request_Tracking__c t : track){
            requestIds.add(t.Demo_Request__c);
            trackIds.add(t.Id);
        }
        
        List<Demo_Request__c> requests = [SELECT Id, Opportunity__c FROM Demo_Request__c WHERE Id IN :requestIds];
        List<Demo_Request_Tracking_Integration_Jnctn__c> trackInts = [SELECT Demo_Request_Activity_Tracking__c, Integration_Solution__c FROM Demo_Request_Tracking_Integration_Jnctn__c WHERE Demo_Request_Activity_Tracking__c IN :trackIds];
        
        //Map Request Id to Opportunity Id
        for(Demo_Request__c r : requests){
            reqToOpp.put(r.Id, r.Opportunity__c);
        }
        
        //Get Current List of Integration Interest on the Opportunities
        List<Opportunity_Integration_Interest__c> oppIntgrtionInt = [SELECT Opportunity__c, Integration_Solution__c FROM Opportunity_Integration_Interest__c WHERE Opportunity__c IN :reqToOpp.values()];
        
        //Map Opportunity to List of Current Integration Interests.  Used to prevent adding duplicates.
        for(Opportunity_Integration_Interest__c o : oppIntgrtionInt){
            if(oppToInt.containsKey(o.Opportunity__c)){
                oppToInt.get(o.Opportunity__c).add(o.Integration_Solution__c);
            } else {
                oppToInt.put(o.Opportunity__c, new Set<Id>{o.Integration_Solution__c});
            }
        }
        
        //Map Tracking Object Id to List of Integrations that were tracked
        for(Demo_Request_Tracking_Integration_Jnctn__c tInt : trackInts){
            if(trackToInt.containsKey(tInt.Demo_Request_Activity_Tracking__c)){
                trackToInt.get(tInt.Demo_Request_Activity_Tracking__c).add(tInt.Integration_Solution__c);
            } else {
                trackToInt.put(tInt.Demo_Request_Activity_Tracking__c, new Set<Id>{tInt.Integration_Solution__c});
            }
        }
        
        for(Demo_Request_Tracking__c tr : track){
            if(tr.Activity_State__c != 'Completed') continue;  //Demo is yet to be completed or tracked
            if(reqToOpp.get(tr.Demo_Request__c) == null) continue; //Demo is not linked to an opportunity
            if(trackToInt.get(tr.Id) == null) continue; //No Integrations were tracked, so no need to add
            Id opp = reqToOpp.get(tr.Demo_Request__c);
            Set<Id> intsToAdd = trackToInt.get(tr.Id);
            Set<Id> currentInts = new Set<Id>();
            if(oppToInt.get(opp) != null) currentInts = oppToInt.get(opp);
            for(Id i : intsToAdd){
                if(currentInts.contains(i)) continue; //Integration has already been added
                Opportunity_Integration_Interest__c oppInt = new Opportunity_Integration_Interest__c();
                oppInt.Opportunity__c = opp;
                oppInt.Integration_Solution__c = i;
                oppIntegration.add(oppInt);
            }
        }
        
        if(!oppIntegration.isEmpty()) insert oppIntegration;
    }
    
    //could move some event conflict code to utility. would be a refactor with others
    public static void AutoDeclineRequest(Demo_Request__c request) {
        //skip demo in the past
        if(request.Demo_Date_Time__c < DateTime.now().addDays(-1)) return;
        
        Set<Id> declineUsers = DemoRequestUtility.GetUsersWithConflictingEvent(request.Demo_Date_Time__c, request.Demo_Time_Length__c, request.QueueName__c);
        system.debug('found ' + declineUsers.size() + ' users with conflicting events');
        List<Demo_Request_Decline__c> declines = new List<Demo_Request_Decline__c>();
        for(Id i : declineUsers){
            Demo_Request_Decline__c d = new Demo_Request_Decline__c();
            d.User_Name__c = i;
            d.Demo_Request_ID__c = request.Id;
            d.Decline_Reason__c = 'Auto-declined by Calendar';
            declines.add(d);
        }
        
        DemoRequestClass.DeclineDemos(declines);
    }
    
    //Move into activity builder
    private static void CreateRelatedTrackingItems(List<Demo_Request_Tracking__c> trackRequests){
        
        List<Demo_Request_Tracking_Product_Junction__c> productJunction = new List<Demo_Request_Tracking_Product_Junction__c>();
        List<Demo_Request_Tracking_Gen_Concept_Jnctn__c> gcJunction = new List<Demo_Request_Tracking_Gen_Concept_Jnctn__c>();
        List<Demo_Request_Tracking_Integration_Jnctn__c> intJunction = new List<Demo_Request_Tracking_Integration_Jnctn__c>();
        
        List<Id> demoIds = new List<Id>();
        for(Demo_Request_Tracking__c t : trackRequests) {
            demoIds.add(t.Demo_Request__c);
        }
        
        List<Demo_Request_Product_Junction__c> allProductIds = [Select Product__c, Demo_Request__c from Demo_Request_Product_Junction__c where Demo_Request__c in :demoIds];
        Map<Id, List<Demo_Request_Product_Junction__c>> allProducts = new Map<Id, List<Demo_Request_Product_Junction__c>>();
        for(Demo_Request_Product_Junction__c j : allProductIds) {
            if(allProducts.containsKey(j.Demo_Request__c)) allProducts.get(j.Demo_Request__c).add(j);
            else allProducts.put(j.Demo_Request__c, new List<Demo_Request_Product_Junction__c>{j});
        }
        List<Demo_Request_Gen_Concept_Junction__c> allGenConceptIds = [Select General_Concept__c, Demo_Request__c from Demo_Request_Gen_Concept_Junction__c where Demo_Request__c in :demoIds];
        Map<Id, List<Demo_Request_Gen_Concept_Junction__c>> allGenConcept = new Map<Id, List<Demo_Request_Gen_Concept_Junction__c>>();
        for(Demo_Request_Gen_Concept_Junction__c j : allGenConceptIds) {
            if(allGenConcept.containsKey(j.Demo_Request__c)) allGenConcept.get(j.Demo_Request__c).add(j);
            else allGenConcept.put(j.Demo_Request__c, new List<Demo_Request_Gen_Concept_Junction__c>{j});
        }
        List<Demo_Request_Integration_Junction__c> allIntegrationIds = [Select Integration_Solution__c, Demo_Request__c from Demo_Request_Integration_Junction__c where Demo_Request__c in :demoIds];
        Map<Id, List<Demo_Request_Integration_Junction__c>> allIntegration = new Map<Id, List<Demo_Request_Integration_Junction__c>>();
        for(Demo_Request_Integration_Junction__c j : allIntegrationIds) {
            if(allIntegration.containsKey(j.Demo_Request__c)) allIntegration.get(j.Demo_Request__c).add(j);
            else allIntegration.put(j.Demo_Request__c, new List<Demo_Request_Integration_Junction__c>{j});
        }
        
        for(Demo_Request_Tracking__c track : trackRequests){
            List<Demo_Request_Product_Junction__c> productIds = new List<Demo_Request_Product_Junction__c>();
            if(allProducts.get(track.Demo_Request__c) != null)
                productIds = allProducts.get(track.Demo_Request__c);
            List<Demo_Request_Gen_Concept_Junction__c> genConceptIds = new List<Demo_Request_Gen_Concept_Junction__c>();
            if(allGenConcept.get(track.Demo_Request__c) != null)
                genConceptIds = allGenConcept.get(track.Demo_Request__c);
            List<Demo_Request_Integration_Junction__c> integrationIds = new List<Demo_Request_Integration_Junction__c>();
            if(allIntegration.get(track.Demo_Request__c) != null)
                integrationIds = allIntegration.get(track.Demo_Request__c);
            
            //Create Product Items on Demo Request Tracking Object
            for(Demo_Request_Product_Junction__c p : productIds){
                Demo_Request_Tracking_Product_Junction__c d = new Demo_Request_Tracking_Product_Junction__c();
                d.Demo_Request_Activity_Tracking__c = track.Id;
                d.Product__c = p.Product__c;
                productJunction.add(d);
            }
            
            //Create General Concept Items on Demo Request Tracking Object
            for(Demo_Request_Gen_Concept_Junction__c g : genConceptIds){
                Demo_Request_Tracking_Gen_Concept_Jnctn__c gCJ = new Demo_Request_Tracking_Gen_Concept_Jnctn__c();
                gCJ.Demo_Request_Activity_Tracking__c = track.Id;
                gCJ.General_Concept__c = g.General_Concept__c;
                gcJunction.add(gCJ);
            }
            
            //Create Integration Items on Demo Request Tracking Object
            for(Demo_Request_Integration_Junction__c i : integrationIds){
                Demo_Request_Tracking_Integration_Jnctn__c intJ = new Demo_Request_Tracking_Integration_Jnctn__c();
                intJ.Demo_Request_Activity_Tracking__c = track.Id;
                intJ.Integration_Solution__c = i.Integration_Solution__c;
                intJunction.add(intJ);
            }
        }
        //Insert Product Junction Objects
        if(!productJunction.isEmpty()){
            insert productJunction;
        }
        //Insert General Concept Junction Objects
        if(!gcJunction.isEmpty()){
            insert gcJunction;
        }
        //Insert Integration Junction Objects
        if(!intJunction.isEmpty()){
            insert intJunction;
        }
    }
    
    public static Map<Id, List<String>> GetRequestRelatedPlatforms (List<Id> requestIds){
        List<Demo_Request_Platform_Junction__c> platforms = [SELECT Id, Demo_Request__c, Platform__r.Name FROM Demo_Request_Platform_Junction__c WHERE Demo_Request__c IN :requestIds];
        Map<Id, List<String>> requestPlatforms = new Map<Id, List<String>>();
        for(Demo_Request_Platform_Junction__c p : platforms){
            if(requestPlatforms.containsKey(p.Demo_Request__c)){
                requestPlatforms.get(p.Demo_Request__c).add(p.Platform__r.Name);
            } else {
                requestPlatforms.put(p.Demo_Request__c, new List<String>{p.Platform__r.Name});
            }
        }
        return requestPlatforms;
    }
    
    public static Map<Id, List<String>> GetRequestRelatedProducts (List<Id> requestIds){
        List<Demo_Request_Product_Junction__c> products = [SELECT Id, Demo_Request__c, Product__r.Name FROM Demo_Request_Product_Junction__c WHERE Demo_Request__c IN :requestIds];
        Map<Id, List<String>> requestProducts = new Map<Id, List<String>>();
        for(Demo_Request_Product_Junction__c p : products){
            if(requestProducts.containsKey(p.Demo_Request__c)){
                requestProducts.get(p.Demo_Request__c).add(p.Product__r.Name);
            } else {
                requestProducts.put(p.Demo_Request__c, new List<String>{p.Product__r.Name});
            }
        }
        return requestProducts;
    }
    
    public static Map<Id, List<String>> GetRequestRelatedGenCons (List<Id> requestIds){
        List<Demo_Request_Gen_Concept_Junction__c> genConcepts = [SELECT Id, Demo_Request__c, General_Concept__r.Name FROM Demo_Request_Gen_Concept_Junction__c WHERE Demo_Request__c IN :requestIds];
        Map<Id, List<String>> requestGenCons = new Map<Id, List<String>>();
        for(Demo_Request_Gen_Concept_Junction__c g : genConcepts){
            if(requestGenCons.containsKey(g.Demo_Request__c)){
                requestGenCons.get(g.Demo_Request__c).add(g.General_Concept__r.Name);
            } else {
                requestGenCons.put(g.Demo_Request__c, new List<String>{g.General_Concept__r.Name});
            }
        }
        return requestGenCons;
    }
    
    public static Map<Id, List<String>> GetRequestRelatedIntegrations (List<Id> requestIds){
        List<Demo_Request_Integration_Junction__c> integrations = [SELECT Id, Demo_Request__c, Integration_Solution__r.Name FROM Demo_Request_Integration_Junction__c WHERE Demo_Request__c IN :requestIds];
        Map<Id, List<String>> requestInts = new Map<Id, List<String>>();
        for(Demo_Request_Integration_Junction__c i : integrations){
            if(requestInts.containsKey(i.Demo_Request__c)){
                requestInts.get(i.Demo_Request__c).add(i.Integration_Solution__r.Name);
            } else {
                requestInts.put(i.Demo_Request__c, new List<String>{i.Integration_Solution__r.Name});
            }
        }
        return requestInts;
    }
    
    public static void UpdateEvent(List<Demo_Request_Tracking__c> newTrack, Map<Id, Demo_Request_Tracking__c> oldTrack){
        Set<Id> requestIds = new Set<Id>();
        List<Event> eventsToUpdate = new List<Event>();
        
        for(Demo_Request_Tracking__c t : newTrack){
            requestIds.add(t.Demo_Request__c);
        }
        
        System.debug('finding events for ' + requestIds.size() + ' demos');
        List<Event> events = [Select Id, WhatId, Type, StartDateTime, EndDateTime, OwnerId FROM Event WHERE WhatId IN :requestIds];
        System.debug('found ' + events.size() + ' events');
        Map<Id, List<Event>> requestToEvent = new Map<Id, List<Event>>();
        for(Event e : events){
            if(requestToEvent.containsKey(e.WhatId)){
                requestToEvent.get(e.WhatId).add(e);
            }else{
                requestToEvent.put(e.WhatId, new List<Event>{e});
            }
        }
        
        for(Demo_Request_Tracking__c track : newTrack){
            List<Event> evts = DemoRequestEventBuilder.updateEvent(track, oldTrack.get(track.Id), requestToEvent.get(track.Demo_Request__c));
            eventsToUpdate.addAll(evts);
        }
        system.debug('updating ' + eventsToUpdate.size() + ' events');
        update eventsToUpdate;
    }
    
    public static void CancelEvent(List<Demo_Request_Tracking__c> tracking){
        List<Event> eventsToDelete = new List<Event>();
        Map<Id, List<Event>> requestToEvent = findRelatedEvents(tracking);
        
        for(Demo_Request_Tracking__c track : tracking){
            List<Event> checkEvents = requestToEvent.get(track.Demo_Request__c);
            if(checkEvents == null) {
                system.debug('No events for demo: ' + track.Demo_Request__c);
                continue;
            } 
            List<Event> evt = DemoRequestEventBuilder.CancelEvent(track, checkEvents);
            system.debug('Found ' + evt.size() + ' for demo: ' + track.Demo_Request__c);
            eventsToDelete.addAll(evt);
        }
        
        if(!eventsToDelete.isEmpty()){
            system.debug('delete list contained ' + eventsToDelete.size() + ' events');
            Set<Event> delEvents = new Set<Event>();
            List<event> findel = new List<Event>();
            delEvents.addAll(eventsToDelete);
            findel.addAll(delEvents);
            system.debug('deleting ' + delEvents.size());
            delete findel;
        }    	
    }
    
    private static Map<Id, List<Event>> findRelatedEvents(List<Demo_Request_Tracking__c> tracking) {
        Set<Id> requestIds = new Set<Id>();
        Map<Id, List<Event>> requestToEvent = new Map<Id, List<Event>>();
        
        for(Demo_Request_Tracking__c t : tracking){
            requestIds.add(t.Demo_Request__c);
        }
        
        List<Event> events = [Select Id, WhatId, Type, StartDateTime, EndDateTime, OwnerId, Description, Location FROM Event WHERE WhatId IN :requestIds];
        system.debug('Found ' + events.size() + ' events related to tracking items');
        for(Event e : events){
            if(requestToEvent.containsKey(e.WhatId)){
                requestToEvent.get(e.WhatId).add(e);
            }else{
                requestToEvent.put(e.WhatId, new List<Event>{e});
            }
        }
        return requestToEvent;
    }
    
    public static void CheckTestBeforePost(List<Demo_Request__c> requests, String postType){
        if(!Test.isRunningTest()){
            DemoRequestClass.PostToChatter(requests, postType);
        }
    }
    
    public static void PostToChatter(List<Demo_Request__c> requests, String postType){
        try{        
            CollaborationGroup chatterGroup = new CollaborationGroup();
            List<Demo_Request__c> updateReqs = new List<Demo_Request__c>();
            
            if(Test.isRunningTest()){
                chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'TS Test Group']; 
            } else {                
                chatterGroup = [SELECT Id FROM CollaborationGroup WHERE Name = 'Demonstration Requests'];                           
            }
            
            String chatterMessage;
            List<Id> userIds = new List<Id>();
            for(Demo_Request__c d : requests){
                userIds.add(d.Demo_Owner__c);
            }
            
            Map<Id, String> userToName = new Map<Id, String>();
            if(!userIds.isEmpty()){
                List<User> demoOwners = [SELECT Id, FirstName, LastName FROM User WHERE Id IN :userIds];                
                for(User u : demoOwners){
                    userToName.put(u.Id, u.FirstName + ' ' + u.LastName);
                }
            }            
            
            for(Demo_Request__c r : requests){
                if(r.SuppressNotification__c == true) continue;
                if(postType == 'Submit'){
                    chatterMessage = 'A new demonstration request has been submitted. ';
                } else if(postType == 'Reschedule'){
                    chatterMessage = ' This request has been Rescheduled.  Please review the new Date and Time of the request ';
                } else if(postType == 'Escalate') {
                    chatterMessage = ' This request has been Escalated for Management Review. ';
                } else if(postType == 'Decline'){
                    chatterMessage = ' This request has been Declined.  All Technical Sales Members are unavailable. ';
                } else if(postType == 'Cancel'){
                    chatterMessage = ' This request has been Cancelled. ';
                } else if(postType == 'Accept'){
                    chatterMessage = ' This request has been Accepted by: ' + userToName.get(r.Demo_Owner__c) + ' ';
                }
                
                if(r.Chatter_Feed_ID__c == null){
                    chatterMessage += DemoRequestUtility.orgUrl + r.Id;
                    ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), chatterGroup.Id, ConnectApi.FeedElementType.FeedItem, chatterMessage);
                    r.Chatter_Feed_ID__c = feedElement.Id;
                    system.debug('adding chatter feed: ' + r.Chatter_Feed_ID__c);
                    updateReqs.add(r);
                } else {    			
                    ConnectApi.Comment comment = ConnectApi.ChatterFeeds.postCommentToFeedElement(null, r.Chatter_Feed_ID__c, chatterMessage);
                }
            }
            if(!updateReqs.isEmpty()) update updateReqs;
        } catch (Exception e) {
            System.debug('A Chatter Post failed with the following result: ' + e);
            return;
        } 
    }
    
}