public class DemoRequestTrackingBuilder {
    
    public Demo_Request_Tracking__c tracking { get; set; }
    public Demo_Request_Tracking__c orig { get; set; }
    public final List<String> activityTypes { get; private set; }
    { activityTypes = new List<String>{'Demo', 'Demo Setup', 'Prep Call', 'Follow-up', 'Demo Shadow'}; }
    private Boolean isUpdating;
    
    public DemoRequestTrackingBuilder() {
        tracking = new Demo_Request_Tracking__c();
        tracking.Activity_State__c = 'Not Started';
        tracking.hasEvent__c = true;
        isUpdating = false;
    }
    
    public DemoRequestTrackingBuilder(Demo_Request_Tracking__c track) {
        tracking = track;
        orig = track.clone(true, true, true, true);
        isUpdating = true;
    }

    public DemoRequestTrackingBuilder withTemplate(Demo_Request_Tracking__c track) {
        tracking = track.clone(false, true); //new id, deep clone
        tracking.isTemplate__c = false;
        tracking.Activity_State__c = 'Not Started';
        isUpdating = false;
        return this;
    }
    
    public DemoRequestTrackingBuilder withStartTime(DateTime start) {
        tracking.Activity_Date_Time__c = start;
        return this;
    }
    
    public DemoRequestTrackingBuilder withDuration(Decimal length) {
        tracking.Activity_Duration__c = length;
        return this;
    }
    
    public DemoRequestTrackingBuilder withType(String typ) {
        tracking.Activity_Type__c = typ;
        return this;
    }
    
    public DemoRequestTrackingBuilder withState(String state) {
        tracking.Activity_State__c = state;
        if(state == 'Completed'){
            tracking.timeCompleted__c = DateTime.now();
        }
        return this;
    }
    
    public DemoRequestTrackingBuilder withOwner(Id owner) {
        tracking.Activity_Completed_By__c = owner;
        return this;
    }
    
    public DemoRequestTrackingBuilder withNotes(String notes) {
        tracking.Notes__c = notes;
        return this;
    }
    
    public DemoRequestTrackingBuilder withNotesLong(String notes) {
        tracking.NotesLong__c = notes;
        return this;
    }
    
    public DemoRequestTrackingBuilder withOtherApps(String otherApps) {
        tracking.Other_Applications_Demonstrated__c = otherApps;
        return this;
    }
    
    public DemoRequestTrackingBuilder withDemoCount(Decimal count) {
        tracking.demosGivenCount__c = count;
        return this;
    }
    
    public DemoRequestTrackingBuilder withContactCount(Decimal count) {
        tracking.peopleCount__c = count;
        return this;
    }
    
    public DemoRequestTrackingBuilder withRequest(Id demo) {
        tracking.Demo_Request__c = demo;
        return this;
    }
    
    public DemoRequestTrackingBuilder withRequestFullInfo(Demo_Request__c demo) {
        tracking.Demo_Request__c = demo.Id;
        tracking.Activity_Date_Time__c = demo.Demo_Date_Time__c;
        tracking.Activity_Duration__c = demo.Demo_Time_Length__c;
        tracking.Other_Applications_Demonstrated__c = demo.Other_Applications__c;
        return this;
    }
    
    public DemoRequestTrackingBuilder withRequestTime(Demo_Request__c demo) {
        tracking.Activity_Date_Time__c = demo.Demo_Date_Time__c;
        tracking.Activity_Duration__c = demo.Demo_Time_Length__c;
        return this;
    }
    
    public DemoRequestTrackingBuilder withGTMURL(string url) {
        tracking.GoToMeeting_JoinURL__c = url;
        return this;
    }
    
    public DemoRequestTrackingBuilder withGTMID(Decimal gtm) {
        tracking.GoToMeeting_ID__c = gtm;
        return this;
    }
    
    public DemoRequestTrackingBuilder withGTMConfCall(String call) {
        tracking.GTM_ConfCall__c = call;
        return this;
    }
    
    public DemoRequestTrackingBuilder withOppStage(String stage){
        tracking.OpportunityStageAtCompletion__c = stage;
        return this;
    }
    
    public DemoRequestTrackingBuilder withCustomDemo(Boolean customDemo, String customDescription){
        tracking.Custom_Demo__c = customDemo;
        tracking.Custom_Demo_Description__c = customDescription;
        return this;
    }
    
    public DemoRequestTrackingBuilder asTemplate(Boolean b){
        tracking.isTemplate__c = b;
        return this;
    }
    
    public DemoRequestTrackingBuilder hasEvent(Boolean b){
        tracking.hasEvent__c = b;
        return this;
    }
    
    public Demo_Request_Tracking__c build() {
        if(isUpdating) {
            update tracking;
            if(tracking.hasEvent__c && !tracking.isTemplate__c) {
                List<Event> updateEvent = DemoRequestEventBuilder.updateEvent(tracking, orig, null);
                update updateEvent;
            }
        } else { 
            insert tracking;
            if(tracking.hasEvent__c && !tracking.isTemplate__c){
                new DemoRequestEventBuilder()
                    .withActivity(tracking)
                    .build();
            }
        }
        return tracking;
    }
    
    public static void buildBulk(List<Demo_Request_Tracking__c> tracks) {
        List<Event> events = new List<Event>();
        for(Demo_Request_Tracking__c t : tracks) {
            if(t.hasEvent__c && !t.isTemplate__c) {
                events.add(new DemoRequestEventBuilder()
                    .withActivity(t)
                    .evt);
            }
        }
        if(tracks.size() > 0) {
            system.debug('Inserting ' + tracks.size() + ' tracking activities');
            insert tracks;
        }
        if(events.size() > 0) {
            system.debug('Inserting ' + events.size() + ' events for activites');
            insert events;
        }
    }
    
    public static void buildBulkFromTemplate(List<Demo_Request_Tracking__c> templates, List<Id> users) {
        system.debug('Creating ' + templates.size() + ' Activities for ' + users.size() + ' users');
        List<Demo_Request_Tracking__c> addTracking = new List<Demo_Request_Tracking__c>();
        for(Demo_Request_Tracking__c t : templates) {
            for(Id s: users) {
                DemoRequestTrackingBuilder trb = new DemoRequestTrackingBuilder()
                	.withTemplate(t)
                    .withOwner(s);
                addTracking.add(trb.tracking);
            }
        }
        system.debug('Inserting ' + addTracking.size() + ' Activities');
        DemoRequestTrackingBuilder.buildBulk(addTracking);
    }
}