global without sharing class PartnerPortal_ApproveAllPACounries_WS {
	
	 webservice static String approveAllCountries(Id partnerAppId){
	 	
	 system.debug('-------------------------partnerAppId-------------------------'+partnerAppId);
	 	
	  List<Partner_Application_Category_and_Country__c> countriesToUpdate = [Select Id,Approval_Status__c from Partner_Application_Category_and_Country__c where
	                                                                     Partner_Application__c = :partnerAppId];
	  for(Partner_Application_Category_and_Country__c eachCountry : countriesToUpdate){
            eachCountry.Approval_Status__c = 'Approved';
        }
	
		 system.debug('-------------------------countriesToUpdate-------------------------'+countriesToUpdate);
	
	 	update countriesToUpdate;
	    return '';	 	
	 }
}