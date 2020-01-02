@isTest 
global class FtpTestWebServiceMockDeactTmpAcct implements WebServiceMock {	
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
          
        FtpGSservices.DisableTempUserResponse_element retCode =
                new FtpGSservices.DisableTempUserResponse_element();
                
       retCode.DisableTempUserResult = 'Success';
             
       response.put('response_x', retCode);  
   }

}