@isTest
global class TestDemoRequestMockHTTPResponse implements HttpCalloutMock {
    
    private static String accessToken = 'RlUe11faKeyCWxZToK3nk0uTKAL'; //Use this value for access token in Callout Testing
    private static String responseKey = 'demoResponseKey'; //Use this value for responseKey in oauth testing
    private static Decimal meetingId = 1001; //Use this value for meetingId in Callout testing
    private static List<String> meetingKeys = new List<String>{'subject', 'starttime', 'endtime', 'passwordrequired', 'conferencecallinfo', 'timezonekey', 'meetingtype'};
    
    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = initializeResponse();
        if(req.getEndpoint() == 'https://api.getgo.com/oauth/access_token'){
            if(req.getBody().contains(responseKey)){
                res = OauthSuccessResponse(res);            
            } else {
                res = Meeting400Response(res);
            }            
        } else if(req.getHeader('Authorization') != accessToken){
            res = Meeting400Response(res);
        } else if(req.getMethod() == 'GET' && req.getEndpoint().contains(String.valueOf(meetingId))){
            res = GetMeetingSuccessResponse(res);              
        } else if(req.getMethod() == 'DELETE' && req.getEndpoint().contains(String.valueOf(meetingId))){
            res = Meeting204Response(res);
        } else if(req.getMethod() == 'PUT' && req.getEndpoint().contains(String.valueOf(meetingId))){
            if(ValidRequestBody(jsonDeserialize(req.getBody()))){
                res = Meeting204Response(res);
            } else {
                res = Meeting400Response(res);
            }               
        } else if(req.getMethod() == 'POST'){
            if(ValidRequestBody(jsonDeserialize(req.getBody()))){
                res = CreateMeetingSuccessResponse(res);
            } else {
                res = Meeting400Response(res);
            }
        } else {
            res = Meeting404Response(res);
        }
        
        return res;
    }
    
    private HttpResponse initializeResponse(){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
    
    private HttpResponse OauthSuccessResponse(HttpResponse res){
        Map<String, object> bodyMap = new Map<String, object>();
        bodyMap.put('access_token', accessToken);
        bodyMap.put('expires_in', '3600');
        bodyMap.put('refresh_token', '');
        bodyMap.put('organizer_key', '8439885694023999999');
        bodyMap.put('account_key', '9999982253621659654');
        bodyMap.put('account_type', '');
        bodyMap.put('firstName', 'John');
        bodyMap.put('lastName', 'Smith');
        bodyMap.put('email', 'john.smith@email.com');
        bodyMap.put('meetingType', 'scheduled');
        bodyMap.put('platform', 'Global');
        bodyMap.put('version', '2');
        String jsonResponse = JSON.serialize(bodyMap);
        
        res.setStatusCode(200);
        res.setBody(jsonResponse);
        return res;        
    }
    
    private HttpResponse CreateMeetingSuccessResponse(HttpResponse res){
        Map<String, object> bodyMap = new Map<String, object>();
        bodyMap.put('joinURL', 'subject');
        bodyMap.put('meetingid', meetingId);
        bodyMap.put('maxParticipants', 24);
        bodyMap.put('uniqueMeetingId', meetingId);
        bodyMap.put('conferencecallinfo', 'PSTN');
        String jsonResponse = JSON.serialize(bodyMap);
        
        res.setStatusCode(201);
        res.setBody(jsonResponse);
        return res;
    }
    
    private HttpResponse GetMeetingSuccessResponse(HttpResponse res){
        DateTime createTime = DateTime.now().addHours(-24);
        DateTime startTime = createTime.addDays(4);
        DateTime endTime = startTime.addHours(1);
        Map<String, object> bodyMap = new Map<String, object>();
        bodyMap.put('createTime', createTime);
        bodyMap.put('passwordRequired', false);
        bodyMap.put('status', 'Not Started');
        bodyMap.put('subject', 'string');
        bodyMap.put('endTime', endTime);
        bodyMap.put('startTime', startTime);
        bodyMap.put('duration', 1);
        bodyMap.put('meetingid', meetingId);
        bodyMap.put('meetingKey', meetingId);
        bodyMap.put('meetingType', 'scheduled');
        bodyMap.put('maxParticipants', 24);
        bodyMap.put('uniqueMeetingId', meetingId);
        bodyMap.put('conferencecallinfo', 'PSTN');
        String jsonResponse = JSON.serialize(bodyMap);
        
        res.setStatusCode(200);
        res.setBody(jsonResponse);
        return res;
    }
    
    private HttpResponse Meeting404Response(HttpResponse res){
        res.setStatusCode(404);
        res.setStatus('Not found');
        return res;
    }
    
    private HttpResponse Meeting400Response(HttpResponse res){
        res.setStatusCode(400);
        res.setStatus('Bad Request');
        return res;
    }
    
    private HttpResponse Meeting204Response(HttpResponse res){
        res.setStatusCode(204);
        res.setStatus('No content');
        return res;
    }
    
    private Map<String, object> jsonDeserialize(String jsonString){
        return (Map<String, Object>)JSON.deserializeUntyped(jsonString);
    }
    
    private Boolean ValidRequestBody(Map<String, object> body){
        for(String i : meetingKeys){
            if(body.get(i) == null){
                return false;
            }
        }
        return true;
    }

}