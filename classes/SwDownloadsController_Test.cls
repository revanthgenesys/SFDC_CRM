@isTest (seeAllData= true)
public class SwDownloadsController_Test {
	
	static testMethod void testSwDownload() {
	
			SwDownloadsController dlcntr = new SwDownloadsController();
		    dlcntr.setInternalStEu();
		    
		    if ( dlcntr.products.size() > 1 ) {
			    dlcntr.selectedProduct = dlcntr.products[1].getValue();
			    dlcntr.populateAllOnProdChange();
			    
			    dlcntr.acceptTnc = true;
			    dlcntr.version = '1.0';
			    dlcntr.lang = 'ENU';
			    dlcntr.mjrRlease ='7';
			    dlcntr.disableComponent = false;
			    dlcntr.disableProdVersion = false;
			    dlcntr.disableMajorVersion = false;
			    dlcntr.disableLanguage = false;
			    dlcntr.disableOSVersion = false;
			   
			    SwDownloadsControllerExtension dlext = new SwDownloadsControllerExtension(dlcntr);
			    List<Software_Download__c> swId = [SELECT Id FROM Software_Download__c LIMIT 1];
			    dlext.swdLoadId = swId[0].Id;

				 CCHttpResponseGenerator testMock = new CCHttpResponseGenerator();            
	    	   Test.setMock(HttpCalloutMock.class, testMock);		    
			    
			    dlext.gtDload();
			    
			    dlcntr.setContact();
			    
			    pageReference pr = dlcntr.lazyLoad();
		    }
   
	} 

}