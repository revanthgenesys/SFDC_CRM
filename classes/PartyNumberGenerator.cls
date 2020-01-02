@RestResource(urlMapping='/PartyNumberGenerator/*')
global class PartyNumberGenerator {
	
	global class ReturnResp {
    	public Integer retValue;
    	public String statusMsg;
    }

	@HttpGet
    global static ReturnResp PartyNumberGenerator() {
    	ReturnResp resp = new ReturnResp();
    	
    	String requestType = RestContext.request.params.get('tp');
    	Global_Setting__c sequObj; 
    	
    	try {
	    	if ( requestType != null && requestType == 'GARN' ) 
	    	   sequObj = Global_Setting__c.getInstance('GARN');
	    	else if ( requestType != null && requestType == 'GPRN' )
	    	   sequObj = Global_Setting__c.getInstance('GPRN');
	    	else {
	    	    resp.statusMsg = 'ERROR: ' + requestType + ' is not a valid type. Expected values are: GARN, GPRN';
	    	    return resp;
	    	}
	    	   
	    	String currentNumStr = sequObj.ID__c;	    	
	    	if ( currentNumStr.isNumeric() ) {
		    	Integer nextNum = Integer.valueOf(currentNumStr) + 1;
		    	sequObj.ID__c = String.valueOf(nextNum);
		    	update sequObj;
		    	
		    	resp.retValue = nextNum;
		    	resp.statusMsg = 'Success';
	    	}
    	}
    	catch(Exception ex) {
    	   resp.statusMsg = 'ERROR: ' + ex.getMessage();
    	   return resp;
    	}

    	return resp;
    }
    
}