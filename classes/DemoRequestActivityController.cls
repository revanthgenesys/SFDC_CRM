public class DemoRequestActivityController {
    public Demo_Request__c req { get; set; }
    public DemoRequestGTMActions g2mActions { get; set; }
    public DemoRequestRelatedItems drl { get; set; }
    
    public boolean editActivity { get; set; }
    public boolean isNewActivity { get; set; }
    public boolean isUpdatedActivity { get; set; }
    public boolean showActivity { get; set; }
    public boolean isTSMember { get; set; }
    public boolean showComplete { get; set; } {showComplete = false;}
    public boolean showPreviousEventWarning { get; set; } {showPreviousEventWarning = false;}
    public boolean showContactCount { get { 
    	return (selectedActivity == 'Tradeshow' || (req.Request_Type__c == 'Webinar' && selectedActivity == 'Demo'));
            }}
    
    public String selectedId { get; set; }
    public String selectedState { get; set; }
    public String selectedActivity { get; set; } {selectedActivity = 'Prep Call';}
    public String activityDate { get; set; }
    public String activityTime { get; set; }
    public Boolean activityCustomDemo { get; set; }
    public String activityCustomDemoDescription { get; set; }
    public String selectedNotes { get; set; }
    public Decimal demoCount { get; set; }
    public Decimal demoPersonCount { get; set; }
    public String origDate { get; set; } 
    public String origTime { get; set; }
    public String otherProducts { get; set; }
    public String selectedPerson { get; set; }
    private String oppStageAtComplete { get; private set; }
       
    public List<SelectOption> activitySelection { get; set; }
    public List<Event> conflicts { get; set; }
    
    public integer activityDurationHours { get; set; }
    public integer activityDurationMinutes { get; set; }
    
    private DateTime activityDateTime { get { return DateTime.valueOf(activityDate + ' ' + activityTime + ':00'); } } 
    private List<String> activityTypes = new List<String>{'Demo', 'Demo Setup', 'Prep Call', 'Follow-up', 'Demo Shadow', 'Tradeshow', 'Travel', 'Demo Training'};
    private List<Demo_Request_Tracking__c> activities = new List<Demo_Request_Tracking__c>();
    private Set<Id> trackingIds = new Set<Id>();
    private String reqId;
    private Demo_Request_Tracking__c origTrack = new Demo_Request_Tracking__c();
	
    public DemoRequestActivityController(ApexPages.StandardSetController stdSetController) {
		g2mActions = new DemoRequestGTMActions(UserInfo.getUserId());        
        if(ApexPages.currentPage().getParameters().get('id') != null){
            reqId = ApexPages.currentPage().getParameters().get('id');
        } else if(ApexPages.currentPage().getParameters().get('state') != null){
            reqId = ApexPages.currentPage().getParameters().get('state');
            g2mActions.responseKey = ApexPages.currentPage().getParameters().get('code');
            GetGtmAccessToken();
        }    
        
        activities = [SELECT Id, Name, Activity_Type__c, Activity_Date_Time__c, Activity_Duration__c, Activity_Completed_By__c,
                      Demo_Request__c, Notes__c, NotesLong__c, Other_Applications_Demonstrated__c, Activity_State__c, demosGivenCount__c, 
                      peopleCount__c, GoToMeeting_JoinURL__c, GTM_ConfCall__c, GoToMeeting_ID__c, Custom_Demo__c, Custom_Demo_Description__c
                      FROM Demo_Request_Tracking__c WHERE Activity_Completed_By__c = :UserInfo.getUserId() AND Demo_Request__c = :reqId Order By Activity_Date_Time__c ASC];
        req = [SELECT Name, Id, Demo_Time_Length__c, Demo_Date_Time__c, Request_Type__c, State__c, Demo_Owner__c, Org_URL__c, Opportunity__c, Opportunity__r.Name, Account__c, Account__r.Name, CompanyName__c, Lead__c, Lead__r.Name, Requester_Name__c FROM Demo_Request__c WHERE Id = :reqId];
        Id firstDemoActivity;
        for(Demo_Request_Tracking__c t : activities){
            if(t.Activity_Type__c == 'Demo' || t.Activity_Type__c == 'Tradeshow') {
                firstDemoActivity = t.Id;
                trackingIds.add(t.Id);
            }
        }
        
        activitySelection = new List<SelectOption>();
        for(String s : activityTypes){
            activitySelection.add(new SelectOption(s,s));
        }
        
        if(DemoRequestUtility.getAllTSIds().contains(UserInfo.getUserId())) isTSMember = true;
        
        String d = ApexPages.currentPage().getParameters().get('demo');
        if(d != null && d == 't' && firstDemoActivity != null) {
            selectedId = firstDemoActivity;
            showRecord();
        }
    }
    
    public ApexPages.StandardSetController myActivities {
        get {
            if(myActivities == null){
                myActivities = new ApexPages.StandardSetController(activities);
                myActivities.setPageSize(200);
            }
            return myActivities;
        }
        set;
    }
    
    public List<Demo_Request_Tracking__c> getActivities() {
        return (List<Demo_Request_Tracking__c>) myActivities.getRecords();
	}
    
    public void showRecord() {
        editActivity = false;
        isNewActivity = false;
        isUpdatedActivity = true;
        showComplete = false;
        showPreviousEventWarning = false;
        DateTime now = DateTime.now();
        for(Demo_Request_Tracking__c t : (List<Demo_Request_Tracking__c>) myActivities.getRecords()){
            if(t.Id == selectedId){
                if (t.Activity_Type__c == 'Demo' || t.Activity_Type__c == 'Tradeshow' || t.Activity_Type__c == 'Demo Training'){
                    drl = new DemoRequestRelatedItems(t);
                  	if(t.Activity_Date_Time__c <= now && t.Activity_State__c != 'Completed') showComplete = true;
                } else {
                    drl = new DemoRequestRelatedItems();
                }
                activityDurationHours = t.Activity_Duration__c.intValue();
                activityDurationMinutes = DemoRequestUtility.ConvertDecimalToMinutes(t.Activity_Duration__c);
                selectedActivity = t.Activity_Type__c;
                selectedState = t.Activity_State__c;
                selectedNotes = (String.isNotEmpty(t.NotesLong__c) ? t.NotesLong__c : '') + ' ' + (String.isNotEmpty(t.Notes__c) ? t.Notes__c : '');
                otherProducts = t.Other_Applications_Demonstrated__c;
                origDate = t.Activity_Date_Time__c.format('yyyy-MM-dd');
        		origTime = t.Activity_Date_Time__c.format('HH:mm');
                demoCount = t.demosGivenCount__c;
                demoPersonCount = t.peopleCount__c;
                g2mActions.meetingId = t.GoToMeeting_ID__c;
                g2mActions.joinUrl = t.GoToMeeting_JoinURL__c;
                g2mActions.conferenceCallInfo = t.GTM_ConfCall__c;
                activityCustomDemo = t.Custom_Demo__c;
                activityCustomDemoDescription = t.Custom_Demo_Description__c;
				showActivity = true;                
                break;
            }
        }
        
    }
    
    public void newRecord() {
        selectedState = '';
        selectedNotes = '';
        activityCustomDemo = false;
        activityCustomDemoDescription = '';
        drl = new DemoRequestRelatedItems();
        if(selectedActivity == 'Demo' || selectedActivity == 'Demo Shadow'){
            origDate = req.Demo_Date_Time__c.format('yyyy-MM-dd');
            origTime = req.Demo_Date_Time__c.format('HH:mm');
            activityDurationHours = req.Demo_Time_Length__c.intValue();
            activityDurationMinutes = ((req.Demo_Time_Length__c - activityDurationHours)*60).intValue();
        } else {
            origDate = DateTime.now().format('yyyy-MM-dd');
            origTime = DateTime.now().format('HH:mm');
            activityDurationHours = 0;
            activityDurationMinutes = 30;
        }
        otherProducts = '';
        selectedId = '';
        g2mActions.meetingId = null;
        editActivity = true;
        isNewActivity = true;
        isUpdatedActivity = false;
        showActivity = true;
        showComplete = false;
        showPreviousEventWarning = false;
    }
    
    public PageReference submitAnyway(){
        if(isUpdatedActivity) return updateFinal();
        return submitFinal();
    }
    
    public PageReference submitRecord() {
        if(checkDuration()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid duration.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;                
        }            
        if(checkDateTime()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a date and time for the activity.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;                
        }
        if(checkConflicts()) return null;
        if(checkCustomDemo()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please submit a Custom Demo Description to provide detail around what was customized.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;                
        }
        return submitFinal();
    }
    
    public PageReference submitFinal() {
        try{                      
            Demo_Request_Tracking__c newTrack = new DemoRequestTrackingBuilder()
                .withRequest(req.Id)
                .withOwner(UserInfo.getUserId())
                .withStartTime(activityDateTime)
                .withDuration(Math.round(((double)activityDurationHours + (double)activityDurationMinutes/60)*100)/100.0)
                .withType(selectedActivity)
                .withNotesLong(selectedNotes)
                .withNotes('')
                .withDemoCount(demoCount)
                .withContactCount(demoPersonCount)
                .withOtherApps(otherProducts)
                .withState(selectedState)
                .withCustomDemo(activityCustomDemo,activityCustomDemoDescription)
                .build();
            drl.setTrack(newTrack);
            drl.saveChanges();
            system.debug('submitting a' + selectedActivity + ' activity to demo: ' + req.Id);
            return SuccessPage();

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred during submission.  Detailed message: ' + e));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;
        }
        
    }
    
    public PageReference updateRecord() {
        if(checkDuration()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a valid duration.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;                
        }
        if(checkDateTime()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a date and time for the activity.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;                
        }
        if(checkCustomDemo()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please submit a Custom Demo Description to provide detail around what was customized.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;                
        }
        origTrack = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c, demosGivenCount__c, peopleCount__c, GoToMeeting_ID__c FROM Demo_Request_Tracking__c WHERE Id = :selectedId];
        Decimal activityDuration = Math.round(((double)activityDurationHours + (double)activityDurationMinutes/60)*100)/100.0;
        if(((origTrack.Activity_Date_Time__c != activityDateTime) || (origTrack.Activity_Duration__c != activityDuration)) && checkConflicts()) return null;
        return updateFinal();
    }
   
    public PageReference updateFinal() {
        try{            
            Demo_Request_Tracking__c updateTrack = new Demo_Request_Tracking__c();
            DemoRequestTrackingBuilder trb = new DemoRequestTrackingBuilder(origTrack)
                .withStartTime(activityDateTime)
                .withState(selectedState)
                .withDuration(Math.round(((double)activityDurationHours + (double)activityDurationMinutes/60)*100)/100.0)
                .withNotesLong(selectedNotes)
                .withNotes('')
                .withOtherApps(otherProducts)
                .withContactCount(demoPersoncount)
                .withOppStage(oppStageAtComplete)
                .withDemoCount(demoCount)
                .withCustomDemo(activityCustomDemo,activityCustomDemoDescription);
                
            if(trb.tracking.GoToMeeting_ID__c != null) UpdateGTM(trb.tracking.GoToMeeting_ID__c);
            updateTrack = trb.build();
            
            if(updateTrack.Activity_Type__c == 'Demo' || updateTrack.Activity_Type__c == 'Tradeshow'){
                drl.saveChanges();
                if(req.Opportunity__c != null) DemoRequestClass.AddOppIntegrationInterest(new List<Demo_Request_Tracking__c>{updateTrack});
                
                if(req.State__c != 'Completed' && origTrack.Activity_Completed_By__c == req.Demo_Owner__c && selectedState == 'Completed'){
                    DemoRequestClass.CompleteDemos(new List<Demo_Request__c>{req});
                }
            }

            if(updateTrack.Activity_Type__c == 'Demo Training'){
                drl.saveContacts();
                
                if(req.State__c != 'Completed' && origTrack.Activity_Completed_By__c == req.Demo_Owner__c && selectedState == 'Completed'){
                    DemoRequestClass.CompleteTraining(req);
                }
            }
            
            return SuccessPage();
            
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating this record.  Detailed message: ' + e));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;
        }
    }
    
    public PageReference deleteRecord() {
        try{
            Demo_Request_Tracking__c deleteTrack = [SELECT Id, Activity_Date_Time__c, Activity_Type__c, Activity_State__c, Activity_Duration__c, Notes__c, NotesLong__c, Demo_Request__c, Activity_Completed_By__c, GoToMeeting_ID__c FROM Demo_Request_Tracking__c WHERE Id = :selectedId];
            if(deleteTrack.GoToMeeting_ID__c != null) DeleteGTM();
            DemoRequestEventBuilder.CancelEventDelete(deleteTrack);          
            delete deleteTrack;
            
            return SuccessPage();

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating this record.  Detailed message: ' + e));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;
        }
    }
    
    public PageReference CompleteTracking(){
        selectedState = 'Completed';
        if(req.Opportunity__c != null) {
            Opportunity opp = [Select StageName from Opportunity where id = :req.Opportunity__c];
            oppStageAtComplete = opp.StageName;
        }
        return updateRecord();        
    }
    
    public PageReference StartGtmOauth(){
        return g2mActions.oauthStart(reqId);
    }
    
    public PageReference CreateGtm(){
        Decimal duration = Math.round(((double)activityDurationHours + (double)activityDurationMinutes/60)*100)/100.0;
        DateTime endTime = activityDateTime.addHours(duration.intValue()).addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(duration));
        String subject;
        
        subject = DemoRequestEventBuilder.createEventSubject(req, selectedActivity);
        
        HTTPResponse response = g2mActions.createMeeting(subject, activityDateTime, endTime);
        
        if(response.getStatusCode() != 201){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attemping to create your GoToMeeting.  The service responded with a message of  ' + response.getStatus() + '.  Please try the operation again.  If the error persists, please contact the Technical Sales Development Team.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;
        }
        
        JSONParser parser = JSON.createParser(response.getBody());
        while(parser.nextToken() != null){
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'joinUrl'){
                    g2mActions.joinUrl = parser.getText();
                } else if(fieldName == 'meetingid'){
                    g2mActions.meetingId = parser.getLongValue();
                } else if(fieldName == 'conferenceCallInfo'){
                    g2mActions.conferenceCallInfo = parser.getText();
                }
            }
        }
        
        g2mActions.updateActivity(selectedId);
        
        return SuccessPage();
    }
    
    public PageReference DeleteGTMOnly(){
        HTTPResponse response = g2mActions.deleteMeeting();
        
        if(response.getStatusCode() != 204){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attemping to delete your meeting.  The service responded with a message of  ' + response.getStatus() + '.  Please try the operation again.  If the error persists, please contact the Technical Sales Development Team.'));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;
        } else {
            g2mActions.meetingId = null;
            g2mActions.joinUrl = null;
            g2mActions.conferenceCallInfo = null;
            g2mActions.updateActivity(selectedId);
            return SuccessPage();
        }
    }
    
    public PageReference SaveToken(){
        try{
            g2mActions.updatePresenter(Userinfo.getUserId());
            return SuccessPage();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating this record.  Detailed message: ' + e));
            PageReference thisPage = ApexPages.currentPage();
            return thisPage;
        }
        
    }
    
    private void GetGtmAccessToken(){
        HTTPResponse response = g2mActions.getRequestToken();
        
        if(response.getStatusCode() != 200){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attemping to Authenticate with GoToMeeting.  The service responded with a message of  ' + response.getStatus() + '.  Please try the operation again.  If the error persists, please contact the Technical Sales Development Team.'));
            return;
        }
        
        String expiresInSeconds;
        
        JSONParser parser = JSON.createParser(response.getBody());
        while(parser.nextToken() != null){
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token'){
                    g2mActions.accessToken = parser.getText();
                } else if(fieldName == 'expires_in'){
                    expiresInSeconds = parser.getText();
                } else if(fieldName == 'organizer_key'){
                    g2mActions.organizerKey = parser.getText();
                } else if(fieldName == 'account_key'){
                    g2mActions.accountKey = parser.getText();
                }
            }
        }
        
        DateTime now = DateTime.now();
        g2mActions.expireDate = now.addSeconds(Integer.valueOf(expiresInSeconds));        
        
        g2mActions.oauthComplete = true;
    }
    
    private void UpdateGTM(Decimal meetId){
        Decimal duration = Math.round(((double)activityDurationHours + (double)activityDurationMinutes/60)*100)/100.0;
        DateTime endTime = activityDateTime.addHours(duration.intValue()).addMinutes(DemoRequestUtility.ConvertDecimalToMinutes(duration));
        String subject;
        
        subject = DemoRequestEventBuilder.createEventSubject(req, selectedActivity);
        
        HTTPResponse response = g2mActions.updateMeeting(subject, activityDateTime, endTime);
        
        if(response.getStatusCode() != 204){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attemping to update your GoToMeeting.  The service responded with a message of  ' + response.getStatus() + '.  Please try the operation again.  If the error persists, please contact the Technical Sales Development Team.'));
            return;
        }

    }
    
    private void DeleteGTM(){
        HTTPResponse response = g2mActions.deleteMeeting();
        
        if(response.getStatusCode() != 204){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while attemping to delete your meeting.  The service responded with a message of  ' + response.getStatus() + '.  Please try the operation again.  If the error persists, please contact the Technical Sales Development Team.'));
        } 
    }    
    
    //Private Methods
    private PageReference SuccessPage(){
        PageReference thisPage = ApexPages.currentPage();
        thisPage.getParameters().put('id', reqId);
        thisPage.setRedirect(true);
        return thisPage;
    }
    
    private Boolean checkDuration() {
        return activityDurationHours == 0 && activityDurationMinutes == 0;
    }
    
    private Boolean checkDateTime() {
        return String.isEmpty(activityDate) || String.isEmpty(activityTime);
    }
    
    private Boolean checkConflicts() {
        selectedPerson = Userinfo.getName();
        Decimal duration = Math.round(((double)activityDurationHours + (double)activityDurationMinutes/60)*100)/100.0;
        conflicts = DemoRequestUtility.GetActivityEventConflicts(activityDateTime, duration, Userinfo.getUserId());
        if(conflicts.size() > 0) {
            showActivity = false;
            showPreviousEventWarning = true;
            return true;
        }
        showPreviousEventWarning = false;
        return false;
    }  
    
    private Boolean checkCustomDemo() {
        if(activityCustomDemo) return activityCustomDemoDescription.length() == 0;
        return false;
    }

}