@isTest
global class MockHttpResponseSwDownloads implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('token=123 status=200');
        System.debug('MockHttpResponseSwDownloads, setBody');
        res.setStatusCode(200);
        return res;
    }
}