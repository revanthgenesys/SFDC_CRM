public class DemoRequestEventBuilder {
    public Event evt { get; set; }
    public Demo_Request_Tracking__c act { get; set; }
    
    private static Map<String, String> activityTypeToEventType { 
        get { if(activityTypeToEventType == null) {
            activityTypeToEventType = new Map<String,String> {
                'Demo' => 'Demo',
                    'Prep Call' => 'Conference Call',
                    'Demo Setup' => 'Other',
                    'Follow-up' => 'Other',
                    'Demo Shadow' => 'Demo',
                    'Tradeshow' => 'Demo',
                    'Travel' => 'Other',
                    'Demo Training' => 'Demo'};
                        }
             return activityTypeToEventType; } set; }
    
    private static Map<String, String> activityTypeToEventShowAs { 
        get { if(activityTypeToEventShowAs == null) {
            activityTypeToEventShowAs = new Map<String,String> {
                'Demo' => 'Busy',
                    'Prep Call' => 'Busy',
                    'Demo Setup' => 'Busy',
                    'Follow-up' => 'Free',
                    'Demo Shadow' => 'Free',
                    'Tradeshow' => 'OutOfOffice',
                    'Travel' => 'OutOfOffice',
                    'Demo Training' => 'Busy'};
                        }
             return activityTypeToEventShowAs; } set; }
    
    private static Map<String, String> activityTypeToEventText { 
        get { if(activityTypeToEventText == null) {
            activityTypeToEventText = new Map<String,String> {
                'Demo' => 'Demonstration',
                    'Prep Call' => 'Demonstration Pre-Call',
                    'Demo Setup' => 'Demonstration Setup',
                    'Follow-up' => 'Demonstration Follow-up',
                    'Demo Shadow' => 'Demonstration',
                    'Tradeshow' => 'Tradeshow',
                    'Travel' => 'Travel',
                    'Demo Training' => 'Demonstration Training'};
                        }
             return activityTypeToEventText; } set; }
    
    public DemoRequestEventBuilder() {
        evt = new Event();
    }
    
    public Event build() {
        insert evt;
        return evt;
    }
    
    public DemoRequestEventBuilder withActivity(Demo_Request_Tracking__c activity) {
        act = activity;
        Demo_Request__c req = [SELECT Id, Name, Demo_Owner__c, Demo_Date_Time__c,
                               Demo_Time_Length__c, Demo_Location__c, Account__c, Account__r.Name,
                               Lead__c, Lead__r.Name, Requester_Name__c, Requester_Company__c, CompanyName__c
                               FROM Demo_Request__c WHERE Id = :activity.Demo_Request__c];
        evt.OwnerId = activity.Activity_Completed_By__c;
        evt.StartDateTime = activity.Activity_Date_Time__c;
        evt.EndDateTime = activity.Activity_Date_Time__c
            .addHours(activity.Activity_Duration__c.intValue())
            .addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(activity.Activity_Duration__c));
        evt.IsReminderSet = true;
        evt.ReminderDateTime = activity.Activity_Date_Time__c.addMinutes(-15);
        evt.WhatId = req.Id;
        evt.Type = activityTypeToEventType.get(activity.Activity_Type__c);
        evt.ShowAs = activityTypeToEventShowAs.get(activity.Activity_Type__c);
        evt.Subject = createEventSubject(req, activityTypeToEventText.get(activity.Activity_Type__c));
        evt.Location = req.Demo_Location__c;
        evt.Description = createEventDescription(req);
        System.debug('Added Activity info to event. Demo Id: ' + req.Id + ' Demo Owner: ' + req.Demo_Owner__c);
        return this;
    }
    
    public DemoRequestEventBuilder withDemo(Demo_Request__c demo, Id person) {
    	if(person == null) person = demo.OwnerId;
        evt.OwnerId = person;
        evt.StartDateTime = demo.Demo_Date_Time__c; 
        evt.EndDateTime = demo.Demo_Date_Time__c
            .addHours(demo.Demo_Time_Length__c.intValue())
            .addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(demo.Demo_Time_Length__c));
        evt.IsReminderSet = true;
        evt.ReminderDateTime = demo.Demo_Date_Time__c.addMinutes(-15);
        evt.WhatId = demo.Id;
        string actType = DemoRequestUtility.requestToActType.get(demo.Request_Type__c);
        evt.Type = activityTypeToEventType.get(actType);
        evt.ShowAs = activityTypeToEventShowAs.get(actType);
        evt.Subject = createEventSubject(demo, activityTypeToEventText.get(actType));
        evt.Location = demo.Demo_Location__c;
        evt.Description = createEventDescription(demo);
        return this;
    }
    
    public static string createEventDescription(Demo_Request__c req) {
        String body = 'Demonstration details: \r\n \r\n';
        
        body += 'Requester Name: ' + req.Requester_Name__c + '\r\nRequester Company: ' + req.Requester_Company__c + '\r\n \r\n';
        
        List<Id> demoIds = new List<Id>{req.Id};
        Map<Id, List<String>> requestPlatforms = DemoRequestClass.GetRequestRelatedPlatforms(demoIds);
        Map<Id, List<String>> requestProducts = DemoRequestClass.GetRequestRelatedProducts(demoIds);
        Map<Id, List<String>> requestGenCons = DemoRequestClass.GetRequestRelatedGenCons(demoIds);
        Map<Id, List<String>> requestIntegrations = DemoRequestClass.GetRequestRelatedIntegrations(demoIds);
        
        if(requestPlatforms.get(req.Id) != null && !requestPlatforms.get(req.Id).isEmpty()){
            body += 'Platforms: \r\n';
            for(String p : requestPlatforms.get(req.Id)){
                body += p + '\r\n';
            }
            body += '\r\n';
        }
        
        if(requestProducts.get(req.Id) != null && !requestProducts.get(req.Id).isEmpty()){
            body += 'Products: \r\n';
            for(String p : requestProducts.get(req.Id)){
                body += p + '\r\n';
            }
            body += '\r\n';
        }
        
        if(requestGenCons.get(req.Id) != null && !requestGenCons.get(req.Id).isEmpty()){
            body += 'General Concepts: \r\n';
            for(String g : requestGenCons.get(req.Id)){
                body += g + '\r\n';
            }
            body += '\r\n';
        }
        
        if(requestIntegrations.get(req.Id) != null && !requestIntegrations.get(req.Id).isEmpty()){
            body += 'Integrations: \r\n';
            for(String i : requestIntegrations.get(req.Id)){
                body += i + '\r\n';
            }
            body += '\r\n';
        }
        
        body += 'Link to Request: ' + DemoRequestUtility.orgUrl + req.Id;
        
        return body;
    }
    
    public static string createEventSubject(Demo_Request__c req, string eventType) {
        string subject = eventType;
        if(req.Account__c != null){
            subject += ' for ' + req.Account__r.Name;
        } else if(req.Lead__c != null){
            subject += ' for ' + req.Lead__r.Name;
        }  else if(req.CompanyName__c != null) {
            subject += ' for ' + req.CompanyName__c;  
        } else {
            subject += ' for ' + req.Requester_Name__c;
        }
        return subject;
    }
    
    public static List<Event> updateEvent(Demo_Request_Tracking__c track, Demo_Request_Tracking__c oldtrack, List<Event> events) {
        if(events == null) {
            events = [Select Id, WhatId, Type, StartDateTime, EndDateTime, OwnerId, Description FROM Event WHERE WhatId = :track.Demo_Request__c];
            System.debug('found ' + events.size() + ' events');
        }
        List<Event> eventsToUpdate = new List<Event>();
        
        for(Event evt : events){
            Boolean updateEvent = false;
            
            if(evt.OwnerId == oldtrack.Activity_Completed_By__c && evt.StartDateTime.format() == oldtrack.Activity_Date_Time__c.format()){
                if(evt.Type == oldtrack.Activity_Type__c) updateEvent = true;
                else if(evt.Type == 'Conference Call' && oldtrack.Activity_Type__c == 'Prep Call') updateEvent = true;
                else if(evt.Type == 'Other' && (oldtrack.Activity_Type__c == 'Demo Setup' || oldtrack.Activity_Type__c == 'Follow-up' || oldtrack.Activity_Type__c == 'Travel')) updateEvent = true;
                else if(evt.Type == 'Demo' && (oldtrack.Activity_Type__c == 'Demo Shadow' || oldtrack.Activity_Type__c == 'Tradeshow' || oldtrack.Activity_Type__c == 'Demo Training')) updateEvent = true;
            }
            system.debug('How is this false? ' + (evt.OwnerId == track.Activity_Completed_By__c && evt.StartDateTime == track.Activity_Date_Time__c));
            system.debug('Part 1 ' + (evt.OwnerId == track.Activity_Completed_By__c) + ' Part 2 ' + (evt.StartDateTime == track.Activity_Date_Time__c));
            system.debug('Part 2 Formatted: ' + (evt.StartDateTime.format() == track.Activity_Date_Time__c.format()));
            system.debug('Checking Update: ' + updateEvent + ' Event Type ' + evt.Type + ' with Activity Type ' + track.Activity_Type__c);
            system.debug('Event Owner: ' + evt.OwnerId + ' Activity Owner: ' + track.Activity_Completed_By__c);
            system.debug('Event Time: ' + evt.StartDateTime + ' Activity Time: ' + track.Activity_Date_Time__c);
            system.debug('Deleting Event: ' + evt);
            
            if(!updateEvent) continue;
            
            if(track.Activity_Completed_By__c != oldtrack.Activity_Completed_By__c){
                evt.OwnerId = track.Activity_Completed_By__c;
            }
            if(track.Activity_Date_Time__c != oldtrack.Activity_Date_Time__c){
                evt.StartDateTime = track.Activity_Date_Time__c;
                evt.EndDateTime = track.Activity_Date_Time__c.addHours(track.Activity_Duration__c.intValue()).addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(track.Activity_Duration__c));
                evt.ReminderDateTime = track.Activity_Date_Time__c.addMinutes(-15);
            }
            if(track.Activity_Duration__c != oldtrack.Activity_Duration__c){
                evt.EndDateTime = track.Activity_Date_Time__c.addHours(track.Activity_Duration__c.intValue()).addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(track.Activity_Duration__c));
            }
            if(track.Activity_Type__c != oldtrack.Activity_Type__c){
                evt.Type = activityTypeToEventType.get(track.Activity_Type__c);
            }
            if((track.GoToMeeting_ID__c != oldtrack.GoToMeeting_ID__c) && track.GoToMeeting_ID__c != null){
                evt.Description += DemoRequestGTMActions.createMeetingDetails(track.GoToMeeting_JoinURL__c, track.GTM_ConfCall__c);
            }
            if((track.GoToMeeting_ID__c != oldtrack.GoToMeeting_ID__c) && track.GoToMeeting_ID__c == null){
                evt.Description = DemoRequestGTMActions.removeMeetingDetails(evt.Description, oldtrack.GoToMeeting_JoinURL__c, oldtrack.GTM_ConfCall__c);
            }
            system.debug('updating event: ' + track);
            eventsToUpdate.add(evt);
        }
        
        return eventsToUpdate;
    }
    
    public static List<Event> CancelEvent(Demo_Request_Tracking__c track, List<Event> events){
        if(events == null)
       		events = [Select Id, WhatId, Type, OwnerId, StartDateTime, Location FROM Event WHERE WhatId = :track.Demo_Request__c];
        List<Event> eventsToDelete = new List<Event>();
        for(Event evt : events){
            Boolean delEvent = false;
            if(evt.OwnerId == track.Activity_Completed_By__c && evt.StartDateTime == track.Activity_Date_Time__c){
                if(evt.Type == track.Activity_Type__c){
                    delEvent = true;
                } else if(evt.Type == 'Conference Call' && track.Activity_Type__c == 'Prep Call'){
                    delEvent = true;
                } else if(evt.Type == 'Other' && (track.Activity_Type__c == 'Demo Setup' || track.Activity_Type__c == 'Follow-up' || track.Activity_Type__c == 'Travel')){
                    delEvent = true;
                } else if(evt.Type == 'Demo' && (track.Activity_Type__c == 'Demo Shadow' || track.Activity_Type__c == 'Tradeshow' || track.Activity_Type__c == 'Demo Training')){
                    delEvent = true;
                }
            } else if(evt.OwnerId == track.Activity_Completed_By__c && (evt.Location =='Tradeshow' || evt.Location =='On-site (Requires Approval)')) {
                system.debug('setting to delete for tradeshow, bootcamps, and webinar series, this may cause a bug');
                delEvent = true;
            }
            system.debug('How is this false? ' + (evt.OwnerId == track.Activity_Completed_By__c && evt.StartDateTime == track.Activity_Date_Time__c));
            system.debug('Part 1 ' + (evt.OwnerId == track.Activity_Completed_By__c) + ' Part 2 ' + (evt.StartDateTime == track.Activity_Date_Time__c));
            system.debug('Part 2 Formatted: ' + (evt.StartDateTime.format() == track.Activity_Date_Time__c.format()));
            system.debug('Checking Delete: ' + delEvent + ' Event Type ' + evt.Type + ' with Activity Type ' + track.Activity_Type__c);
            system.debug('Event Owner: ' + evt.OwnerId + ' Activity Owner: ' + track.Activity_Completed_By__c);
            system.debug('Event Time: ' + evt.StartDateTime + ' Activity Time: ' + track.Activity_Date_Time__c);
            system.debug('Deleting Event: ' + evt);
            if(delEvent) eventsToDelete.add(evt);
        }
        
        return eventsToDelete; 	
    }
    
    public static void CancelEventDelete(Demo_Request_Tracking__c track) {
        List<Event> events = CancelEvent(track, null);
        delete events;
    }
    
    public static void CreateEventsFromActivity(List<Demo_Request_Tracking__c> tracks) {    
        List<Event> events = new List<Event>();
        
        for(Demo_Request_Tracking__c track : tracks){
            DemoRequestEventBuilder evb = new DemoRequestEventBuilder()
            	.withActivity(track);
            events.add(evb.evt);
        }
        system.debug('Inserting ' + events.size() + ' events');
        insert events;
    }
    
    public static void CreateEventsFromDemo(Demo_Request__c demo, List<Id> userIds) {
        List<Event> newEvents = new List<Event>();
        for(Id s: userIds) {
        	DemoRequestEventBuilder e = new DemoRequestEventBuilder()
                .withDemo(demo, s);
            newEvents.add(e.evt);
        }
        system.debug('inserting ' + newEvents.size() + ' events');
        insert newEvents;
    }
}