global class LMSIintegrationService {
			
 global class AccountProductEntlmnt {
		public String statusCode;
		public String statusMsg;
		public String AccntId;
		public Integer totalLinesNum;
		public List<ProductEntlmntLine> Products;

		public AccountProductEntlmnt(String accId) {
			AccntId = accId;
			Products = new List<ProductEntlmntLine>();
			
			if ( String.isNotBlank(accId) ) {
				statusCode = 'OK';
				Products = getContractLineItemsByEU(accId);
		    	totalLinesNum = Products.size();	
			}
			else {
				statusCode = 'Error';
				statusMsg = 'Invalid Account ID <' + accId + '>';
			}  
		} 
		
	   private List<ProductEntlmntLine> getContractLineItemsByEU(String accntId) {
	  	 List<ProductEntlmntLine> prdlines = new  List<ProductEntlmntLine>();

/* "Shelved" contracts line items included only for 18 months after the line item End Date
   "In Negotiation" contracts all lines included based on the contract header start/end dates
   "Active" contracts lines are included based on the line item start/end date
*/		 
		 try { 
		  	  if ( String.isNotBlank(accntId) ) {
		  	  	     
		  	  	     /// STEP -1. check for upgrades in the upgrade requests pending list for the EndUser. If found, replace old (current) version with a new version
			         // based on product upgrade mapping list stored in Pure_Connect_Version_Upgrade__c. Mirror type contracts are excluded.
			         /// including only products with offering type 'PureConnect On Premise' (formula field isPureConnectPrem)
		  	  	     List<Pure_Connect_Version_Upgrade__c> pendingUpgrProds = pendingUpgradeProducts(accntId);
                      
			  	  	 AggregateResult[] agrRes = [SELECT Upgraded_Product__r.APN_Number__c prt, Upgraded_Product__r.Name nm,
			  	  	                                    	Non_Billable__c nonb, SUM(Current_Quantity__c) sum
					  	  	               FROM ContractLineItem
					  	  	               WHERE isPureConnectPrem__c = true 
					  	  	                AND ServiceContract.Service_Contract_Type__c != 'Mirror'
					  	  	                AND ServiceContract.End_User_Name__c = :accntId
                                            AND (
	                                            ( ServiceContract.Agreement_Status__c = 'Active'					  	  	               
							  	  	                AND Maintenance_Start_Date__c <= :Date.today().addDays(1)
							  	  	                AND Maintenance_End_Date__c >= :Date.today().addDays(-1) )
							  	  	            OR 
							  	  	            ( ServiceContract.Agreement_Status__c = 'In Negotiation'					  	  	               
							  	  	                AND ServiceContract.StartDate <= :Date.today().addDays(1)
							  	  	                AND ServiceContract.EndDate >= :Date.today().addDays(-1) )
							  	  	            OR 
							  	  	            ( ServiceContract.Agreement_Status__c = 'Shelved'					  	  	               
							  	  	                AND Maintenance_End_Date__c <= :Date.today().addDays(1)
							  	  	                AND Maintenance_End_Date__c > :Date.today().addMonths(-18) )							  	  	            
					  	  	                )
					  	  	               GROUP BY Upgraded_Product__r.APN_Number__c, Upgraded_Product__r.Name, Non_Billable__c];
		
					 for (AggregateResult ar : agrRes ) {
					 	 String partNum = String.valueOf(ar.get('prt'));
					 	 String prdName = String.valueOf(ar.get('nm'));
					 	 Boolean nonBill = Boolean.valueOf(ar.get('nonb'));
					 	 Integer qty = Integer.valueOf(ar.get('sum'));
					 	 
					 	 /// replace upgraded products with a new product values,
					 	 /// upgrade of one product can add additional products based on the product upgrade metrix 
					 	 Boolean upgrade = false;
					 	 for ( Pure_Connect_Version_Upgrade__c upgr : pendingUpgrProds ) {				 	 	
					 	 	if ( partNum == upgr.Old_Product_APN_Number__c) {
					 	 		upgrade = true;
					 	 		// Skip 1:0 Upgrades ..
			                	if(upgr.New_Product__c != NULL){
						 	 		String partNumUpgr = upgr.New_Product_APN_Number__c;
						 	 		String prdNameUpgr = upgr.New_Product__r.Name;
						 	 		prdlines.add( new ProductEntlmntLine( partNumUpgr, prdNameUpgr, nonBill, qty ) );
			                	}							 	 						 	 		
					 	 	}
					 	 }
                         /// add non-upgrade products 
                         if ( ! upgrade )             					 	
		 	 				 prdlines.add( new ProductEntlmntLine( partNum, prdName, nonBill, qty ) );
					 }
					 
					 ///STEP - 2. Process Mirror contracts. Mirror products are not subject to Upgrades, they show up in LMS exactly as is, even if
					 // there is a pending Upgrade request 
					 
					 AggregateResult[] agrResMirr = [SELECT Upgraded_Product__r.APN_Number__c prt, Upgraded_Product__r.Name nm,
			  	  	                                     	Non_Billable__c nonb, SUM(Current_Quantity__c) sum
					  	  	               FROM ContractLineItem
					  	  	               WHERE isPureConnectPrem__c = true 
					  	  	                AND ServiceContract.Service_Contract_Type__c = 'Mirror'
					  	  	                AND ServiceContract.End_User_Name__c = :accntId
                                            AND ServiceContract.Agreement_Status__c = 'Active'					  	  	               
							  	  	        AND Maintenance_Start_Date__c < :Date.today().addDays(1)
							  	  	        AND Maintenance_End_Date__c > :Date.today().addDays(-1)
					  	  	               GROUP BY Upgraded_Product__r.APN_Number__c, Upgraded_Product__r.Name, Non_Billable__c];
					
					  for (AggregateResult ar : agrResMirr ) {					 	                                       					  	
					 	 prdlines.add( new ProductEntlmntLine( String.valueOf(ar.get('prt')), String.valueOf(ar.get('nm')), 
					 	                                       Boolean.valueOf(ar.get('nonb')), Integer.valueOf(ar.get('sum')) ));
					  }					
			  }
			  			  
		   }
		   catch (Exception ex)	{
			 	 statusCode = 'Error';
			 	 statusMsg = ex.getMessage();
			 }  
	  	 
	  	  return prdlines;
	   }     
  
  ////Pending Upgrades
	  private List<Pure_Connect_Version_Upgrade__c> pendingUpgradeProducts(String accntId) {
	  	 List<Pure_Connect_Version_Upgrade__c> upgrProdsMapping = new List<Pure_Connect_Version_Upgrade__c>();
	  	
	  	 List<Product_Upgrade_Request__c> upgrReqst = [SELECT Product__c FROM Product_Upgrade_Request__c 
	  	                                               WHERE Account__c = :accntId
	  	                                                 AND Type__c = 'Version' AND Processed__c = false];
	  	                                                 
	  	 if ( ! upgrReqst.isEmpty() )   {
	  	 	Set<String> prodIds = new Set<String>();
	  	 	
	  	 	for (Product_Upgrade_Request__c r : upgrReqst)
	  	 	    prodIds.add(String.ValueOf(r.Product__c));
  	 	    
	  	 	upgrProdsMapping = [SELECT Old_Product_APN_Number__c, New_Product_APN_Number__c, New_Product__r.Name
	  	 	                    FROM Pure_Connect_Version_Upgrade__c
	  	 	                    WHERE Old_Product__c IN : prodIds];
	  	 }                                             
	  	 return upgrProdsMapping;
	  }
  
  }
  
  global class AccountProductEntlmntBatchable {
  	  public String AccntId;
  	  public List<ProductEntlmntLine> Products;
  	  
  	  public AccountProductEntlmntBatchable(LMSIintegrationService.AccountProductEntlmnt accntEntl ) {
  	  	  AccntId = accntEntl.AccntId;
  	  	  Products = accntEntl.Products;
  	  }  	
  }
  		
  public class ProductEntlmntLine {
  	    public String Name;
		public String PartNum;
		public Integer BillQty;
		public Integer NonBillQty;

		public ProductEntlmntLine ( String part, String prname, Boolean nonb, Integer prqty ) {
			//Name = prname == null ? 'No Name yet' : prname;
			Name = prname;
			PartNum = part;
			BillQty = nonb ? 0 : prqty;
			NonBillQty = nonb ? prqty : 0;
		}
  }
  
  public static Boolean isContractActive(String status) {
    	Set<String> activeStates = new Set<String>{'Active','In Negotiation','Shelved'};
    	return activeStates.contains(status);
  }

///// Queue methods  
  public static void putAccountsInLMSQueueById(List<String> accntIdList)  {
  	 if ( accntIdList == null || accntIdList.isEmpty() )
  	    return;
  	       
  	 try {  	 	
  	 	/// find if an account is already in the Queue
  	 	 List<LMS_Outbound_Msg_Queue__c> skipLst = [SELECT Account__c FROM LMS_Outbound_Msg_Queue__c
  	 	                                           WHERE Account__c IN :accntIdList 
  	 	                                            AND (Status__c = 'New' OR (Status__c = 'Failed' AND Failure_Count__c < 4))];
  	 	 
  	 	Set<String> skipIDs = new Set<String>();
  	 	for (LMS_Outbound_Msg_Queue__c lq : skipLst)
  	 	    skipIDs.add(lq.Account__c);
 	    
  	 	Set<String> insertIDs = new Set<String>(accntIdList); 	
  	 	insertIDs.removeAll(skipIDs);
   	 	
  	 	Set<LMS_Outbound_Msg_Queue__c> QtoInsert = new Set<LMS_Outbound_Msg_Queue__c>();
  	 	for (String aId : insertIDs)
  	 	   QtoInsert.add( new LMS_Outbound_Msg_Queue__c(Account__c = aId));
  
        if ( ! QtoInsert.isEmpty() )
       		 insert new List<LMS_Outbound_Msg_Queue__c>(QtoInsert); 	 	
  	 }
  	 catch(Exception ex) {} // no need to report on error	
  }

  public static List<Id> lmsAccountsFromContracts(List<ServiceContract> contracts)  {  	 
  	  if ( contracts == null )
  	        return null;
  	  
  	  Set<Id> accntIDs = new Set<Id>();
  	  
  	  try { 
	  	  List<ContractLineItem> cicLineItems = [SELECT ServiceContractId, ServiceContract.End_User_Name__c
	  	                                             FROM ContractLineItem
	  	                                             WHERE isPureConnectPrem__c = true
	  	                                              AND ServiceContractId IN : contracts];
	  	                                              
	  	  if ( ! cicLineItems.isEmpty() ) {
	  	  	  for ( ContractLineItem li : cicLineItems )
	  	  	 	 accntIDs.add(li.ServiceContract.End_User_Name__c);
  	  		}
  	  }
  	  catch (Exception ex) {}
  	
  	return new List<id>(accntIDs);
  }
   
}