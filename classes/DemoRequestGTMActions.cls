public without sharing class DemoRequestGTMActions {
    
    public boolean oauthComplete { get; set; } {oauthComplete = false;}
    public boolean hasValidToken { get; set; } {hasValidToken = false;}
    public DateTime expireDate { get; set; }
    public Decimal meetingId { get; set; }
    public String accessToken { get; set; }
    public String organizerKey { get; set; }
    public String accountKey { get; set; }
    public String responseKey { get; set; }
    public String joinUrl { get; set; }
    public String conferenceCallInfo { get; set; }
    public String consumerKey { get {if(consumerKey == null) consumerKey = getConsumerKey();
        							return consumerKey;}
                              	private set; }
    
    private String citrixOauthUrl = 'https://api.getgo.com/oauth/';
    private String citrixApiUrl = 'https://api.getgo.com/G2M/rest/';
    private String confCallPref = 'PSTN';
    
    public DemoRequestGTMActions(Id userId){
        Demonstration_Presenter__c presenter = [SELECT Id, User_Name__c, GTM_Access_Token__c, GTM_Token_Expire_Date__c, GTM_Conference_Preference__c FROM Demonstration_Presenter__c WHERE User_Name__c = :userId];
        DateTime now = DateTime.now();
        if(presenter.GTM_Access_Token__c == null || presenter.GTM_Token_Expire_Date__c <= now){
            hasValidToken = false;
            oauthComplete = false;
        } else {
            accessToken = presenter.GTM_Access_Token__c;
            hasValidToken = true;
            oauthComplete = true;
        }
        
        if(!String.isEmpty(presenter.GTM_Conference_Preference__c)){
            confCallPref = presenter.GTM_Conference_Preference__c;
        } 
    }
    
    public void updatePresenter(Id userId){
        Demonstration_Presenter__c presenter = [SELECT Id, User_Name__c, GTM_Access_Token__c, GTM_Token_Expire_Date__c FROM Demonstration_Presenter__c WHERE User_Name__c = :userId];
        presenter.GTM_Token_Expire_Date__c = expireDate;
        presenter.GTM_Access_Token__c = accessToken;
        presenter.GTM_Account_Key__c = accountKey;
        presenter.GTM_Organizer_Key__c = organizerKey;
        update presenter;
        
        hasValidToken = true;
    }
    
    public void updateActivity(Id activityId){
        Demo_Request_Tracking__c currentActivity = [SELECT Id, GoToMeeting_ID__c, GoToMeeting_JoinURL__c, GTM_ConfCall__c, Activity_Completed_By__c,
                                                    Activity_Type__c, Activity_Date_Time__c, Activity_Duration__c, Demo_Request__c, hasEvent__c, isTemplate__c
                                                    From Demo_Request_Tracking__c WHERE Id = :activityId];
        Demo_Request_Tracking__c newActivity = currentActivity.clone(true, true, true, true);
        system.debug('cloned activity');
        newActivity = new DemoRequestTrackingBuilder(newActivity)
            .withGTMID(meetingId)
            .withGTMURL(joinUrl)
            .withGTMConfCall(conferenceCallInfo)
            .build();
    }
    
    public PageReference oauthStart(string reqId) {
        PageReference url = new PageReference(citrixOauthUrl + 'authorize?client_id=' + consumerKey + '&state=' + reqId);
        url.setRedirect(true);
        return url;
    }
    
    public HTTPResponse getRequestToken() {
        Http h = new Http();
        
        HttpRequest getToken = new HttpRequest();
        getToken.setEndpoint(citrixOauthUrl + 'access_token');
        getToken.setMethod('POST');
        getToken.setHeader('Accept', 'application/json');
        getToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        getToken.setBody('grant_type=authorization_code&code=' + responseKey + '&client_id=' + consumerKey);
        
        return h.send(getToken);        
    }
    
    public HTTPResponse createMeeting(String subject, DateTime startTime, DateTime endTime){
        Http h = new Http();
        
        HttpRequest meeting = buildRequest('POST');
        meeting.setEndpoint(citrixApiUrl + 'meetings');
        String jsonMessage = jsonBodyMap(subject, startTime, endTime);
        meeting.setBody(jsonMessage);
        
        return h.send(meeting);        
    }
    
    public HTTPResponse updateMeeting(String subject, DateTime startTime, DateTime endTime){
        Http h = new Http();
        
        HttpRequest meeting = buildRequest('PUT');
        meeting.setEndpoint(citrixApiUrl + 'meetings/' + meetingId);
		String jsonMessage = jsonBodyMap(subject, startTime, endTime);
        meeting.setBody(jsonMessage);
        
        return h.send(meeting);
    }
    
    public HTTPResponse deleteMeeting(){
        Http h = new Http();
        
        HttpRequest meeting = buildRequest('DELETE');
        meeting.setEndpoint(citrixApiUrl + 'meetings/' + meetingId);
        
        return h.send(meeting);
    }

	public HTTPResponse getMeeting(){
        Http h = new Http();
        
        HttpRequest meeting = buildRequest('GET');
        meeting.setEndpoint(citrixApiUrl + 'meetings/' + meetingId);
        
        return h.send(meeting);
    } 
    
    public static String createMeetingDetails(String joinUrl, String callInfo){
        return '\r\n\r\nPlease join my meeting. \r\n' + joinUrl + '\r\n\r\nJoin the conference call: \r\n \r\n' + callInfo + '\r\nAudio PIN: Shown after joining the meeting \r\n \r\n';
    }
    
    public static String removeMeetingDetails(String messageBody, String joinUrl, String callInfo){
        return messageBody.remove(createMeetingDetails(joinUrl, callInfo).trim());
    }
    
    private HttpRequest buildRequest(String method){
        HttpRequest request = new HttpRequest();
        request.setMethod(method);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', accessToken);
        return request;
    }
    
    private String getConsumerKey(){
        Organization thisOrg = [SELECT Id, IsSandBox, InstanceName FROM Organization LIMIT 1];
        
        //Determine which GTM App to use based on environment
        if(thisOrg.IsSandbox){
            if(thisOrg.InstanceName == 'CS8') {
                return '3KdsixG5ShIl4S0Kh23bODNRrpJCGqnj';
            } else {
                return '72W3x7ls4jsGSttzuGPXqdkpKQuNAQ7k';
            }
        } else {
            return '70AdbGZ3hBcrMTthZYP5DR8UbbqDjqMs';
        }
    }
    
    private String jsonBodyMap(String subject, DateTime startTime, DateTime endTime){
        Map<String, object> bodyMap = new Map<String, object>();
        bodyMap.put('subject', subject);
        bodyMap.put('starttime', startTime);
        bodyMap.put('endtime', endTime);
        bodyMap.put('passwordrequired', false);
        bodyMap.put('conferencecallinfo', confCallPref);
        bodyMap.put('timezonekey', '');
        bodyMap.put('meetingtype', 'scheduled');
        return JSON.serialize(bodyMap);
    }

}