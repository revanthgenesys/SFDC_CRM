@isTest 
global class FtpTestWebServiceMockCreateFolder implements WebServiceMock {	
	 global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
          
        FtpGSservices.CreateUserAndCaseResponse_element retCode =
                new FtpGSservices.CreateUserAndCaseResponse_element();
        
        retCode.CreateUserAndCaseResult = 'https://test.com';       
        response.put('response_x', retCode);   
   }
}