@isTest 
global class FtpTestWebServiceMock implements WebServiceMock {
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
              	  	     	
        ftp.CreateFTPFolder_Move_Output_element mvRetcode = 
                               new ftp.CreateFTPFolder_Move_Output_element();    		
        response.put('response_x', mvRetcode);
        
   }
}