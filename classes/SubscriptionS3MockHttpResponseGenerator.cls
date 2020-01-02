@isTest
public class SubscriptionS3MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    String type;
    public SubscriptionS3MockHttpResponseGenerator(String input) {
        type = input;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
       // System.assertEquals('https://ininlicensinggenerationapi.azurewebsites.net/api/GenerateMediaServer24License', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        String xmlString;
        if(type.equalsIgnorecase('username'))
            xmlString = '{"access_key": {"AccessKeyId": "AKIAJG43M2EAFWEO7ANQ", "CreateDate": "Wed, 29 Aug 2018 03:20:58 GMT","SecretAccessKey": "PY4XQ2ULQXziAa1MhczOjilcBEigg7IM6BY6MVOA", "Status": "Active", "UserName": "SAMPLE122"},"message": "Removed all access keys of the user and attached a new one", "status": "success"}';
        else
            xmlString = '{"message": "Created object and attached custom user policy successfully", "status": "success"}'; 
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(xmlString);
        res.setStatusCode(200);
        return res;
    }
}