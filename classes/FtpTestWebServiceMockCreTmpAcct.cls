@isTest 
global class FtpTestWebServiceMockCreTmpAcct implements WebServiceMock {	
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
          
        FtpGSservices.CreateTempUserResponse_element retCode =
                new FtpGSservices.CreateTempUserResponse_element();
                
       retCode.CreateTempUserResult = 'Success';
             
       response.put('response_x', retCode);  
   }
}