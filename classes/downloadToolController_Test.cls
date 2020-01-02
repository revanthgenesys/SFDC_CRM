@isTest
public class downloadToolController_Test {
	 
	static testMethod void wbTest() {
		
		ApexPages.currentPage().getParameters().put('pageType', 'Work');		
	  	downloadToolController dwlc = new downloadToolController();
	  	dwlc.download();
	  	
	  	dwlc.termsAccepted = true;
	  	dwlc.download();
	  	
	  	dwlc.wbenchCodeInpt = 'NA1955';
	  	dwlc.download();
	  	
	  	dwlc.termsAccepted = false;
	  	dwlc.download();
	  	
	  	dwlc.termsAccepted = true;
	  	dwlc.wbenchCodeInpt = 'NA1';
	  	dwlc.download();
	    	
	}
	
	static testMethod void logTest() {
		
		ApexPages.currentPage().getParameters().put('pageType', 'Log');		
	  	downloadToolController dwlc = new downloadToolController();
	  	dwlc.download();
	  	
	  	dwlc.termsAccepted = true;
	  	dwlc.download();
	  	
	    dwlc.termsAccepted = false;
	  	dwlc.download();
	}
	
	static testMethod void alartmTest() {
		
		ApexPages.currentPage().getParameters().put('pageType', 'Alarm');		
	  	downloadToolController dwlc = new downloadToolController();
	  	dwlc.download();
	  	
	  	dwlc.termsAccepted = true;
	  	dwlc.download();
	  	
	    dwlc.termsAccepted = false;
	  	dwlc.download();
	}
	
}