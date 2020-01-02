public without sharing class SoftwareDownloadDetailsController {
	
	transient public final Software_Download__c swdDetail {get; set;}
	
	public SoftwareDownloadDetailsController() {
		
		ID swID = ApexPages.currentPage().getParameters().get('id');
		
		if ( swID != null ) {
			List<Software_Download__c> swdList = [SELECT Name, CD_DVD_Name__c, TruncatedComponentName__c, Product_Component__c,
		                             File_Name__c, Download_Type__c, Expiration_Date__c, File_Date__c, File_Size_KBs__c,
		                             File_Type__c, Image_Type__c, Localization__c, Major_Release__c, Operating_Systam__c, 
		                             Product__r.Name, Publish_Date__c, Release_Type__c, Support_Product__c,
		                             Contolled__c, Version__c, Product_Name__c
		                             FROM Software_Download__c WHERE Id = : swID];
		    if ( !swdList.isEmpty() )
		           swdDetail = swdList[0];  
		}		
	}
}