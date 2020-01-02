trigger ProductCategoryFilterUpdate on Case (before insert, before update) {

 if(Util.Bypass_Trigger_Chk)return;

    Case[] cases = Trigger.new;
    Map<Id, RecordType> cstypes = CaseUtil.getAllTScaseTypesMap();
    
    Map<String,String> catSyncLabelMap = CategorySyncController.getCategorySyncLabelMap();
    Set<Id> prodIds = new Set<Id>();
    
    try {
	    for (Case c : cases) {
	        // create maps for our product info
	        
	        if ( cstypes.get(c.RecordTypeId).DeveloperName.startswith('Genesys_Cloud_') )
	             prodIds.add(c.Cloud_Service__c);
	        else {
		        prodIds.add(c.Support_Product__c);
		        prodIds.add(c.Product_Line__c);
	        }
	    }
	    if (prodIds.contains(null)) prodIds.remove(null);
	    Map<Id,Support_Product__c> prodMap = new Map<Id,Support_Product__c>([SELECT Id,Product_Name__c FROM Support_Product__c WHERE Id IN :prodIds]);
	    if ( prodMap.size() == 0 )
	      return;
	    
	    for (Case c : cases) {
	    	 String prodName;
	    	 
	    	 if ( cstypes.get(c.RecordTypeId).DeveloperName.startswith('Genesys_Cloud_') )  {
	    	 	 prodName = c.Cloud_Service__c != null ? prodMap.get(c.Cloud_Service__c).Product_Name__c : '';    	 	       
	    	 }
	    	 else {
	              prodName = c.Support_Product__c != null ? prodMap.get(c.Support_Product__c).Product_Name__c :
	                          c.Product_Line__c != null ? prodMap.get(c.Product_Line__c).Product_Name__c :
	                          '';                 
	    	 }
	    	             
	        c.Product_Category_Filter__c = (prodName!='' && catSyncLabelMap.containsKey(prodName)) ? catSyncLabelMap.get(prodName) : prodName;	      
	    }
    }
	catch (Exception ex) {
		
	}
}