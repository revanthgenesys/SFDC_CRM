@RestResource(urlMapping='/SNOWIntegrationGetRecordId/')
global class SNOWIntegrationGetRecordId {
	
	global class SNOWRecordInfo {
    	public String statusMsg;
    	public String recordId;
    }
	
	@HttpPost
    global static SNOWRecordInfo SNOWIntegrationGetRecordId(String snRecName) {
    	SNOWRecordInfo ret = new SNOWRecordInfo();
    	ret.recordId = '';
    	
    	if ( String.isBlank(snRecName) ) {
    		ret.statusMsg = 'ERROR: Please provide the Name of the SFDC record.';
    		return ret;
    	}
    	
    	try {
    		List<Case_SN_Request__c> snrecs = [SELECT Id FROM Case_SN_Request__c WHERE Name = :snRecName];
    		
    		if ( ! snrecs.isEmpty() ) {
    			ret.recordId = snrecs[0].Id;
    			ret.statusMsg = 'Success';
    		}
    		else {
    			ret.statusMsg = 'ERROR: Unable to find: ' + snRecName;
    		}
    	}
    	catch (Exception ex) {
    		ret.statusMsg = 'ERROR: ' + ex.getMessage();
    		return ret;
    	}
    	    	
        return ret;
    	
    }   
}