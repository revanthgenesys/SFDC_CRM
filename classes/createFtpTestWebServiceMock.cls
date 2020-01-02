@isTest
global class createFtpTestWebServiceMock implements WebServiceMock{
	
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
              	  	     	
        ftp.CreateFTPFolder_Create_Output_element crRetcode = 
        						new ftp.CreateFTPFolder_Create_Output_element();	
        response.put('response_x', crRetcode);
        
   }
}