@RestResource(urlMapping='/LMSIntegrationProductUpgrade/')
global class LMSIntegrationProductUpgrade {
	
	global class ResponseStatus {
    	public String statusCode;
    	public String statusMsg;
    }
	
	global class OrderProduct {
		public String PartNum;
		public Integer Qty;
	}
	
	public static Account enduser;
	public static Map<String, Id> prodIds; 
	
	@HttpPost
    global static ResponseStatus LMSIntegrationProductUpgrade(String AccntId, List<OrderProduct> products) {
    	ResponseStatus resp = new ResponseStatus();
    	prodIds = new  Map<String, Id>();
    	
        resp = validateInputs(AccntId, products);
    	if ( resp != null )
    	   return resp;
    	   
       resp = createUpgradeRequest(products);
    	
       return resp;   	
    }
    
    public static ResponseStatus createUpgradeRequest (List<OrderProduct> products) {
    	ResponseStatus resp = new ResponseStatus();
    	List<Product_Upgrade_Request__c> reqToinsert = new List<Product_Upgrade_Request__c>();
    	List<Product_Upgrade_Request__c> reqExist = new List<Product_Upgrade_Request__c>();
    	
    	reqExist = [SELECT Product__c FROM Product_Upgrade_Request__c WHERE Account__c = :enduser.Id AND Processed__c = false];
 
    	try {
    		
    		for ( OrderProduct pr : products ) {
    			Boolean requestFound = false;
    			
    			for (Product_Upgrade_Request__c req : reqExist) {
    				if ( req.Product__c == prodIds.get(pr.PartNum) ) {
    					requestFound = true;
    					break;
    				}
    			}
    			
    			if ( !requestFound )  {
	    			Product_Upgrade_Request__c upgrReq = new Product_Upgrade_Request__c();
	    			upgrReq.Account__c = enduser.Id;
	    			upgrReq.Product__c =  prodIds.get(pr.PartNum);
	    			upgrReq.Quantity__c = pr.Qty;
	    			upgrReq.Type__c = 'Version';
	    			reqToinsert.add(upgrReq);
    			}
    		}
    		
    		if ( !reqToinsert.isEmpty() )
    		   insert reqToinsert;
    	}
    	catch(Exception ex) {
    		ErrorLogUtil.insertLog('LMSIntegrationProductUpgrade', 'Error creating Upgrade Product Request ' +  ex.getMessage(), 'LMSIntegrationProductUpgrade.createUpgradeRequest');     
    		
    		resp.statusCode = 'Error';
    		resp.statusMsg = ex.getMessage();
    		return resp;
    	}
    	
    	resp.statusCode = 'OK';
    	resp.statusMsg = 'Upgrade Request has been logged.';
    	return resp;
    
    }
    
    public static ResponseStatus validateInputs(String AccntId, List<OrderProduct> products) {
    	ResponseStatus resp = new ResponseStatus();
    	
    	if ( String.isBlank(AccntId) ) {
    		resp.statusCode = 'Error';
    		resp.statusMsg = 'Account Id cannot be blank.';
    		return resp;
    	}
    	else if ( products.isEmpty() ) {
    		resp.statusCode = 'Error';
    		resp.statusMsg = 'At least one product is required.';
    		return resp;
    	}
    	
    	List<Account> enduserLst = [SELECT Id FROM Account WHERE Id = :AccntId];
    	if ( enduserLst.isEmpty() ) {
    		resp.statusCode = 'Error';
    		resp.statusMsg = 'Invalid Account Id ' + AccntId;
    		return resp;
    	}
    	else
    	   enduser = enduserLst[0];
    	
    	List<String> prodPartNumbers = new List<String>();
    	for (OrderProduct op : products) 
    	   prodPartNumbers.add(op.PartNum);
    
     	try {
    		List<Product2> productLst = [SELECT Id, APN_Number__c FROM Product2 WHERE APN_Number__c IN :prodPartNumbers];  
    		
	    	for (Product2 pr : productLst)     			
	    		prodIds.put(pr.APN_Number__c, pr.Id);
    	}
    	catch(Exception ex) {
    	    resp.statusCode = 'Error';
    		resp.statusMsg = ex.getMessage();
    		return resp;
    	}

    	if ( prodIds.size() != products.size() ) {
    		String apnNotFound = '';
    		for (OrderProduct pn : products) {
    		   if ( prodIds.get(pn.PartNum) == null )
    		       apnNotFound += pn.PartNum + ' ';
    		} 
    		if ( String.isNotBlank(apnNotFound) ) {
	    		resp.statusCode = 'Error';
	    		resp.statusMsg = 'Product Part Number(s) NOT Found: ' + apnNotFound;
	    		return resp; 
    		}
    	}
    	   	
    	return null;
    }
    
}