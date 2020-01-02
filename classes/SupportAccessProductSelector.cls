public without sharing class SupportAccessProductSelector {

    private static List<Support_Product__c> productsAll;
	private static List<Support_Product__c> productsStEu;
	private static List<Support_Product__c> components;
	private static List<Support_Product__c> cloudprods;
	private static Map<Id, Map<Id, String>> prodProbPureCnct;
	private static Map<Id, Map<Id, String>> prodProbPureCnctCloud;
	private static Map<String, Map<Id, String>> groupProdsPureCnct;
	private static Map<String, Map<Id, String>> groupProdsPureCnctCloud;
	private static List<Support_Product__c> prodsPC;
	private static List<Support_Product__c> prodsCldPC;
	
	public static List<Support_Product__c> getProductsByStEu (Id soldToId, Id endUserId) {
		if ( productsStEu != null )
		   return productsStEu;
	
	/*** PureEngade products only until iSupport - 11/17/2017 Leave because PureConnect product list is static, not defined by Service Contracts *****/
	    List<ServiceContract> srvContrs = BackOfficeAccountService.getServiceContractsByStEuId (soldToId, endUserId, 'PureEngage On Premise', 'active');
	    	
		productsStEu = new List<Support_Product__c>();
		
		if ( !srvContrs.isEmpty() )	 {
			
			List<ContractLineItem> lineItems = [SELECT id, PriceBookEntry.Product2Id
											    FROM ContractLineItem 
											    WHERE ServiceContractId IN : srvContrs];
			
			if ( ! lineItems.isEmpty() ) {
				
				Set<ID> prodIDs = new Set<ID>();
				for ( ContractLineItem lnIt : lineItems )  {
					prodIDs.add(lnIt.PriceBookEntry.Product2Id);
				}
							
				productsStEu = [SELECT Id, Name, Parent_Product__c, Parent_Product__r.Name, Category__c, Product_Group__c
					            FROM Support_Product__c
					            WHERE Id IN (SELECT Product__c FROM Product_Mapping__c WHERE Sellable_Item__c IN :prodIDs)
					             AND Product_Type__c = 'Product'
					             AND Customer_Available__c = true AND Active__c = true ORDER BY Name ASC];
			}			       		   
		}				   
		
		return productsStEu;
	}
	
	public static List<Support_Product__c> getComponentsByProduct (ID prodId) {
		if ( components != null )
		   return components;
		
		if ( prodId == null )
		   return null;
		
	    components =  [SELECT id, Name 
	                   FROM Support_Product__c 
	                   WHERE Product_Type__c IN ('Component','Third Party')
	                    AND Parent_Product__c = :prodId
	                    AND Customer_Available__c = true AND Active__c = true ORDER BY Name ASC];
				
		return components;
	}
	
	public static List<Support_Product__c> getProductsAccessAll() {
	  if ( productsAll != null )
		   return productsAll;
			
	   productsAll =  [SELECT id, Name, Parent_Product__c, Parent_Product__r.Name, Category__c FROM Support_Product__c 
	                    WHERE Product_Type__c = 'Product' 
	                     AND Category__c != 'PureConnect Products'  
                         AND Product_Group__c != 'Custom App for PureConnect' AND Product_Group__c != 'Custom App for PureCloud'
	                     AND Customer_Available__c = true AND Active__c = true ORDER BY Name ASC];
	   
	   return productsAll;	   
	}   
	
	public static List<Support_Product__c> getCloudProductsByDepl (ID deplId)  {
		if ( cloudprods != null )
		   return cloudprods;
		
		cloudprods = new List<Support_Product__c>();		
		if ( String.isNotBlank(deplId) )  {
			List<Cloud_Deployment__c> depl = [SELECT Cloud_Platform__c FROM Cloud_Deployment__c WHERE Id = :deplId];
		
		    if ( String.isNotBlank(depl[0].Cloud_Platform__c) )  {
	    		cloudprods = [SELECT Id, Name FROM Support_Product__c 
	    		              WHERE Product_Type__c = 'Cloud Service' 
	    		               AND Cloud_Platform__c = :depl[0].Cloud_Platform__c
	    		               AND Customer_Available__c = true AND Active__c = true
	    		              Order By Name];	    
		    }   		 
	    }
	    return cloudprods;
   }
   
   /// PureConnect Products
   public static Map<Id, Map<Id, String>> getPureCnctProdWithProbCateg(Boolean isCategCloud) {
      if ( !isCategCloud && prodProbPureCnct != null )
   	       return prodProbPureCnct;
   	  else if ( isCategCloud && prodProbPureCnctCloud != null ) 
   	       return prodProbPureCnctCloud;
   	
   	  Map<Id, Map<id, String>> prodProbCategories = new Map<Id, Map<Id, String>>();
   	  
      List<Support_Product__c> prods = getPureConnectProducts(isCategCloud);
	                      
	  if ( !prods.isEmpty() )  {
	  	 for ( Support_Product__c pr : prods ) {
	  	 	
	  	 	if ( pr.Support_Product_Related_Categories__r.isEmpty() ) 
	  	 	    continue;
	  	 	
	  	 	for ( Support_Product_Related_Category__c relctg : pr.Support_Product_Related_Categories__r )  {
	  	 		if ( prodProbCategories.get(pr.Id) == null ) {
	  	 		    prodProbCategories.put(pr.Id, new Map<Id, String>{relctg.Support_Problem_Category__c => relctg.Support_Problem_Category__r.Name});
	  	 	    }
	  	 	    else {
		  	 		Map<Id, String> categ = prodProbCategories.get(pr.Id);
		  	 		categ.put(relctg.Support_Problem_Category__c, relctg.Support_Problem_Category__r.Name);
		  	 		prodProbCategories.put(pr.Id, categ);
	  	 	    }	  
	  	 	}	  	 	
	  	 }	  	
	  }
	
	  if ( isCategCloud ) {
	      prodProbPureCnctCloud = new Map<Id, Map<id, String>>();
	      prodProbPureCnctCloud.putAll(prodProbCategories);
	  }
	  else  {
	      prodProbPureCnct = new Map<Id, Map<id, String>>();
	      prodProbPureCnct.putAll(prodProbCategories);
	  }
	      
   	  return prodProbCategories;
   }
   
  public static Map<String, Map<Id, String>> getPureCnctGroupWithProducts(Boolean isCategCloud) {
  	   if ( !isCategCloud && groupProdsPureCnct != null )
   	       return groupProdsPureCnct;
   	  else if ( isCategCloud && groupProdsPureCnctCloud != null ) 
   	       return groupProdsPureCnctCloud;
   	
   	  Map<String, Map<Id, String>> groupWithProds = new  Map<String, Map<Id, String>>();
   	  
      List<Support_Product__c> prods = getPureConnectProducts(isCategCloud);
      
       if ( !prods.isEmpty() )  {
	  	 for ( Support_Product__c pr : prods ) {
	  	 	if ( String.isBlank(pr.Product_Group__c) )
	  	 	   continue;
	  	 	
	  	 	if ( groupWithProds.get(pr.Product_Group__c) == null ) {
	  	 		groupWithProds.put(pr.Product_Group__c, new Map<Id, String>{pr.Id => pr.Product_Name__c});
	  	 	}
	  	 	else {
	  	 		Map<Id, String> prds = groupWithProds.get(pr.Product_Group__c);
	  	 		prds.put(pr.Id, pr.Product_Name__c);
	  	 		groupWithProds.put(pr.Product_Group__c, prds);
	  	 	}	  
	  	 }	  	
	  }
	     
       if ( isCategCloud ) {
	      groupProdsPureCnctCloud = new Map<String, Map<Id, String>>();
	      groupProdsPureCnctCloud.putAll(groupWithProds);
	  }
	  else  {
	      groupProdsPureCnct = new Map<String, Map<Id, String>>();
	      groupProdsPureCnct.putAll(groupWithProds);
	  }
	      
   	  return groupWithProds;     
  }
   
  public static List<Support_Product__c> getPureConnectProducts(Boolean isCategCloud) {
  	//  if ( !isCategCloud && prodsPC != null )
  	  if ( prodsPC != null )
   	       return prodsPC;
   	 // else if ( isCategCloud && prodsCldPC != null ) 
   	 //      return prodsCldPC;
 
  	//  String searchCateg = isCategCloud ? 'PureConnect%'  : 'PureConnect Products';   	  
   	   prodsPC =  [SELECT Id, Product_Name__c, Product_Group__c, Category__c,
 						(SELECT Support_Problem_Category__c, Support_Problem_Category__r.Name
                         FROM Support_Product_Related_Categories__r
                         WHERE Support_Problem_Category__r.Status__c = 'Active')
                  FROM Support_Product__c 
                  WHERE (Category__c LIKE 'PureConnect%' OR 
                         (Category__c ='Custom PS Applications' AND Product_Group__c = 'Custom App for PureConnect'))
                   AND Product_Type__c = 'Product' 
                   AND Customer_Available__c = true AND Active__c = true 
                   ORDER BY Product_Name__c];
	 /*                     
	  if ( !isCategCloud ) {
   	       prodsPC = new List<Support_Product__c>();
   	       prodsPC.addAll(prdlist);
	  }
   	  else if ( isCategCloud ) {
   	       prodsCldPC = new List<Support_Product__c>();
   	       prodsCldPC.addAll(prdlist);
   	  }
   	*/
   	  
   	  return prodsPC;
  	
  }
   
   
}