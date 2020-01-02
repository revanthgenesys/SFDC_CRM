@isTest
global class TestWebService_MockSetUp implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{“subscription_id”: “aLV0d000000CkheGAC”,“deployment_id”:”a8d0B000000HildQAC”}');
        response.setStatusCode(200);
        return response;
    }

}