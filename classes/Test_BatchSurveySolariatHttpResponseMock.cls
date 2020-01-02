@isTest
global class Test_BatchSurveySolariatHttpResponseMock implements HttpCalloutMock 
{
    global static String returnType;
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if( returnType == 'Token') {
        
	        res.setBody('{"ok" : true,' +
	                     '"token" : "Test Access Token"' +
	                    '}');
        }
        else if ( returnType == 'Error' ) {
	        res.setBody('{"ok" : false,' +	               
	                     '"error" : "error"' +
	                    '}');
        }
        
        res.setStatusCode(200);
        return res;
    }

}