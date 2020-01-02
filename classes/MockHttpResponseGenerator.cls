@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://api.boomi.com/mdm/api/rest/v1/genesyslabs-E17Z4Z/repositories/1577fc7d-fd11-4f90-a562-fdd491357b6b/universes/fb7aacdb-c5bb-4459-98d7-3bb376620957/records', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        req.setHeader('Content-Type', 'text/xml');
        res.setBody('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><MdmQueryResponse resultCount="1"><results><customer createddate="02-13-2014T13:53:56.000-0600" grid="37adae10-5b51-48a1-899d-f8a1f4640ada" source="SALESFORCE" updateddate="02-13-2014T15:06:20.000-0600"><id>37adae10-5b51-48a1-899d-f8a1f4640ada</id><genesys_account_reference_number>41286</genesys_account_reference_number><account_name>Wells Fargo Bank</account_name><account_type>Customer</account_type><stage>Confirmed</stage><is_inactive>false</is_inactive><subsidiary>8100</subsidiary><account_owner>LK0079856</account_owner><sales_relationship>Direct</sales_relationship><categories><classification>Unknown</classification><industry>Finance - Banking</industry><key_account_type>Premier Account</key_account_type><region>North America</region><sector>Private</sector><sub_region>#N/A</sub_region><type_of_commerce>Business-to-Consumer</type_of_commerce><vertical>FINANCE AND INSURANCE</vertical></categories><communication><fax>(415) 222-6590</fax><phone>(415) 222-6590</phone></communication><financial><credit_limit>8000000.0</credit_limit><currency>USD</currency><terms>Net 30</terms></financial><primary_address><address_1>455 Market Street 4th Floor</address_1><address_2>MAC A0104-049</address_2><city>SAN FRANCISCO</city><country>United States</country><postal_code>94105</postal_code><state_province>California</state_province></primary_address><references><party>95c87ba0-199a-4b74-aff2-f39f2827808e</party></references></customer></results></MdmQueryResponse>');
        res.setStatusCode(200);
        return res;
    }
}