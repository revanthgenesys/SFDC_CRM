trigger LicenseRequest_Main on License_Request__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
		
	if (Util.Bypass_Trigger_Chk) return;

	if ( Trigger.isBefore) {
		
		if ( Trigger.isUpdate ) {
			
		  List<RecordType> rtlst = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'License_Request__c'];		  
		  Map<String, Id> rtmap = new Map<String, Id>();
		  for (RecordType rt : rtlst)
		      rtmap.put(rt.DeveloperName, rt.Id);
		  
		  for( License_Request__c lcr : trigger.new)  {
		  	if ( lcr.RecordTypeId == rtmap.get('Email_to_LicenseRequest') )
		  	     continue;
		  	
            License_Request__c oldLr = trigger.oldMap.get(lcr.Id);    
            try {       
	            if ( oldLr.Status__c != 'Closed' && lcr.Status__c == 'Closed' ) {
	                 lcr.RecordTypeId = rtmap.get('Read_Only');
	            } 
	            else if ( oldLr.Status__c == 'Closed' && lcr.Status__c != 'Closed' ) {
	                 lcr.RecordTypeId = rtmap.get('Editable');
	            } 
            }
            catch (Exception ex) {}
          }
	   } ///isUpdate		
	} //isBefore
}