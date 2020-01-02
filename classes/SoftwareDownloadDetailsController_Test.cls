@isTest
private class SoftwareDownloadDetailsController_Test {
	
	static testMethod void testSwDetails() {
		
		Software_Download__c swDet = new Software_Download__c(name='sw');
		insert swDet;
				
		Pagereference detPg = Page.SoftwareDownloadDetails;  
		Test.setCurrentPageReference(detPg);  
		ApexPages.currentPage().getParameters().put('Id', swDet.Id);
		SoftwareDownloadDetailsController detCntr = new SoftwareDownloadDetailsController();
	
	}

}