/***********************************************************************************************
 * Class Name   : CCHttpResponseGenerator 
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : A Http call Mock class which will used by test classes to test the rest api callouts
 **********************************************************************************************/

@isTest
global class CCHttpResponseGenerator implements HttpCalloutMock 
{
    global static Integer countofRestCalls = 0;
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req)
    {System.debug('----------->>>>'+countofrestcalls);
        countofRestCalls += 1;
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(countofRestCalls==1)
        {
        res.setBody('{"id" : "Test Id",' +
                     '"issued_at" : "Test Time",' +
                     '"instance_url" : "Test Instance Url",' +
                     '"signature" : "Test Signature",' +
                     '"access_token" : "Test Access Token"' +
                    '}');
        }
        else if(countofRestCalls==2)
        {
        res.setBody('"[{\"id\":\"701c0000000DnV6AAK\",\"success\":true,\"created\":false,\"errors\":[]}]"');
        countofRestCalls = 0;
        }
        res.setStatusCode(200);
        return res;
    }
}