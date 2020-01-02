trigger CaseSNOWRequestTrigger on Case_SN_Request__c (after update) {
	
	if (Util.Bypass_Trigger_Chk) return;
		
	List<FeedItem> fitems = new List<FeedItem>();
	for( Case_SN_Request__c sn : Trigger.new ) {
		
	  if ( sn.External_Comment__c != Trigger.oldMap.get(sn.Id).External_Comment__c && 
	       sn.External_Comment__c != null && String.isNotBlank(sn.External_Comment__c) ) {
			
	      FeedItem fdi = new FeedItem();
          fdi.Body = sn.Name + ', comment added: \n' + sn.External_Comment__c;
          fdi.ParentId = sn.Case__c;
          fdi.Visibility = 'InternalUsers';
          fitems.add(fdi);
		}
	}
		
    if ( !fitems.isEmpty() ) {
    	try {
    		insert fitems;
    	}
    	catch(Exception ex) {
    		ErrorLogUtil.insertLog('CaseSNOWRequestTrigger', 'Error adding Case Post for SNOW external comment ' +  
			                        ex.getMessage(),  'CaseSNOWRequestTrigger');   
    	}
    }
           
}