@isTest (seeAllData = true)
public class PortalUsageFileUploadController_Test {
	
	static testMethod void testOpenFtp() {
		PortalUsageFileUploadController cnt = new PortalUsageFileUploadController();
		cnt.boa = 'BOA-100';
		cnt.platform = 'PureEngage';
		
		Test.startTest();		
	   		Test.setMock(WebServiceMock.class, new FtpTestWebServiceMockCreateFolder());
			cnt.openGSfolder();
			
			cnt.boa = null;
		    cnt.openGSfolder();
		    
		    cnt.boa = 'BOA-100';
		    cnt.platform = '';
		    cnt.openGSfolder();
		    				     
	   Test.stopTest();	  	   
	
	}
    
}