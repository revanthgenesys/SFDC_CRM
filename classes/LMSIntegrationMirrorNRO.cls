@RestResource(urlMapping='/LMSIntegrationMirrorNRO/')
global class LMSIntegrationMirrorNRO {
	
	global class OrderProduct {
		public String PartNum;
		public Integer Qty;
	}
	
	global class ResponseStatus {
    	public String statusCode;
    	public String statusMsg;
    }
	
	public static Account enduser;
	public static Account soldto;
	public static String emailTo;
	public static Map<String, Id> prodIds; 
	
	@HttpPost
    global static ResponseStatus LMSIntegrationMirrorNRO(String AccntId, String SoldToId, String EmailToNotify, List<OrderProduct> products) {
    	ResponseStatus resp = new ResponseStatus();
    	prodIds = new  Map<String, Id>();
    	
        resp = validateInputs(AccntId, SoldToId, EmailToNotify, products);
    	if ( resp != null )
    	   return resp;
    	   
       resp = createMirrorNRO(products);
    	
       return resp;
    	
    }
    
    public static ResponseStatus createMirrorNRO (List<OrderProduct> products) {
    	ResponseStatus resp = new ResponseStatus();
    	List<SObject> insrecords = new List<SObject>();
    	/// set unique reference id 
    	String refnum = String.valueOf(DateTime.now().getTime());
    	Order__c orderReference = new Order__c( Siebel_ID__c = refnum );
    	
    	try {    	
    	/// Order Header
	    	Order__c ordr = new Order__c ( Siebel_ID__c = refnum );
	    	ordr.Name = 'Mirror NRO ' + enduser.Name + ' - ' + refnum.substring(8);
	    	ordr.RecordTypeId = Global_Setting__c.getInstance('NRO RT').ID__c;
	    	ordr.NRO_Type__c = 'Mirror';
	    	ordr.End_User_Name__c = enduser.Id;
	    	ordr.Sold_To_Name__c  = soldto.Id;
	    	ordr.Maintenance_Start__c = Date.today();
	    	ordr.Maintenance_End__c = Date.today().addMonths(6);
	    	ordr.Status__c = 'In Progress';
	    	ordr.Priority__c = '3-Medium';
	    	ordr.Ship_software_via__c = 'No Shipment Required';
	    	ordr.Order_Fulfillment_Email_Receipt__c = 'genesyslicense@genesys.com';
	    
	    	insrecords.add(ordr);
	    	
	    	///LineItems
	    	List<Order_Line_Item__c> lineitems = new List<Order_Line_Item__c>();
	    	
	    	for (OrderProduct pr : products)  {
	    	   Order_Line_Item__c li = new Order_Line_Item__c ( Order__r = orderReference ); 
	    	   li.RecordTypeId =  Global_Setting__c.getInstance('Order Line Default RT').ID__c;
	    	   li.Name = pr.PartNum;
	    	   li.Product__c = prodIds.get(pr.PartNum);
	    	   li.BigMachines_Quantity__c = pr.Qty;
	    	   li.Quantity__c = pr.Qty;
	    	   insrecords.add(li);
	
	    	}
	
	 	    insert insrecords;
	    	
	    	/// cleanup and status update - this will trigger generation of a Service Contract
	    	List<Order__c> neworder = [SELECT Id, Siebel_ID__c FROM Order__c WHERE Siebel_ID__c = :refnum];	    	
	    	if ( !neworder.isEmpty() ) {
	    		neworder[0].Status__c = 'Approved';  //trigger Service Contract creation
	    		neworder[0].Siebel_ID__c = '';
	    		update neworder[0];
	    		
	    		//trigger Service Contract status update to Active and Complete the Order
	    	    neworder[0].Status__c = 'Completed';
	    	    update neworder[0];
	    	}
	    	
    	}
    	catch(Exception ex) {
    		/// log the error
    		ErrorLogUtil.insertLog('LMSIntegrationMirrorNRO', 'Error creating Order/SC ' +  ex.getMessage(), 'LMSIntegrationMirrorNRO.createMirrorNRO');     
    		
    		resp.statusCode = 'Error';
    		resp.statusMsg = ex.getMessage();
    		return resp;
    	}
    	
    	resp.statusCode = 'OK';
    	resp.statusMsg = 'Order has been submitted.';
    	return resp;
    }
   
    public static ResponseStatus validateInputs(String AccntId, String SoldToId, String EmailToNotify, List<OrderProduct> products) {    	
    	ResponseStatus resp = new ResponseStatus();
    	
    	/// validations
    	if ( String.isBlank(AccntId) || String.isBlank(SoldToId) ) {
    		resp.statusCode = 'Error';
    		resp.statusMsg = 'Account Id and Sold To Id cannot be blank.';
    		return resp;
    	}
    	else if ( products.isEmpty() ) {
    		resp.statusCode = 'Error';
    		resp.statusMsg = 'At least one product is required.';
    		return resp;
    	}
    	emailTo = EmailToNotify;
    	
    	List<Account> enduserLst = [SELECT Id, Name, Owner.Email FROM Account WHERE Id = :AccntId];
    	if ( enduserLst.isEmpty() ) {
    		resp.statusCode = 'Error';
    		resp.statusMsg = 'Invalid Account Id: ' + AccntId;
    		return resp;
    	}
    	else
    	   enduser = enduserLst[0];
                
    	if ( AccntId != SoldToId ) {
    		List<Account> soldtoLst = [SELECT Id FROM Account WHERE Id = :SoldToId];
    		if ( soldtoLst.isEmpty() ) {
    			resp.statusCode = 'Error';
    			resp.statusMsg = 'Invalid Sold To Account Id: ' + SoldToId;
    			return resp;
    		}
    		else 
    		    soldto = soldtoLst[0];
    	}
    	else
    	   soldto = enduser;
    	
    	/// products
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
    	
    	/// DO NOT create NRO and a contract if another Mirror contract for same products and Quantities aleady exist
    	AggregateResult[] agrRes = [SELECT Upgraded_Product__r.APN_Number__c prt, SUM(Current_Quantity__c) sum
					  	  	        FROM ContractLineItem
					  	  	       WHERE ServiceContract.Service_Contract_Type__c = 'Mirror'
					  	  	          AND ServiceContract.End_User_Name__c = :AccntId
					  	  	          AND ServiceContract.Sold_To_Name__c = :SoldToId
                                      AND ServiceContract.Agreement_Status__c = 'Active'
                                   GROUP BY Upgraded_Product__r.APN_Number__c];	
    	
    	if ( !agrRes.isEmpty() )  {
    		Map<String, Integer> mirrContrProds = new Map<String, Integer>();
    		Map<String, Integer> ordrReqstProds = new Map<String, Integer>();
    		
    		for (AggregateResult ar : agrRes ) 
    		   mirrContrProds.put( String.valueOf(ar.get('prt')), Integer.valueOf(ar.get('sum')) );
    		   
    		for (OrderProduct op : products) 
    	   		ordrReqstProds.put( op.PartNum, ordrReqstProds.containsKey(op.PartNum) ? ordrReqstProds.get(op.PartNum) + op.Qty : op.Qty );
    	   		
    	    // compare products in both maps. if products in the are equal or subset of the existing contract(s)
    	    // return dulicate request error
    	    if ( ordrReqstProds.size() <= mirrContrProds.size() ) {  
    	    	Boolean diff = false;
    	    	    		 	    	
    	    	for ( String key : ordrReqstProds.keySet() ) {
   					if ( ! mirrContrProds.containsKey(key) || ordrReqstProds.get(key) > mirrContrProds.get(key) ) {					
   						diff = true;
   						break;
   					}  					   
				}
    	    
	    	    if ( diff == false ) {
	    	    	resp.statusCode = 'Error';
		    		resp.statusMsg = 'Dulicate request. Mirror contarct containing same products and quantities already exist.';
		    		return resp; 
	    	    }
    	    } 
    	}
    	   	
    	return null;
    }
    
}