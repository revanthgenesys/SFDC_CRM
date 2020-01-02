/*****************************************************
Class: CaseUtil
Author – Rashmi K
Date – 3/4/2013
******************************************************/ 

public without sharing class CaseUtil {
    //final variables to store milestone names
    public static final String FIRST_TECHNICAL_RESPONSE = 'First Technical Response';
    public static final String OPEN_ACITIVITY_MSG = 'Case can not be closed with open activities';
	public static final String STATUS_CLOSED = 'Closed';
	public static String caseAccessLevel;
	
	private static List<RecordType> caseTStypesLst;
	private static Map<Id, RecordType> caseTStypesMap;

    private static void setBusinessHours(List<Case> cases,Map<String,BusinessHours> bhMap){
    	List<Id> enuAccId = new List<Id>();
    	Map<Id,String> accSuppGpMap = new Map<Id,String>();
    	Map<Id,String> recordTypeMap = new Map<Id,String>();
    	
    	Set<Id> caseRTIdList = new Set<Id>();
    	
    	for(Case ca: cases){
    		if(ca.End_User_Account__c != null) 
    		        enuAccId.add(ca.End_User_Account__c);
    	}

    	for(Account acc : [SELECT id, Support_Group__c 
    	                   FROM   Account 
    	                   WHERE  Id IN : enuAccId]){
    		accSuppGpMap.put(acc.Id,acc.Support_Group__c);
    	}

    	for(Case ca: cases){

            if(ca.End_User_Account__c != null && accSuppGpMap != null){
	    			system.debug('--End_User_Account__c'+ca.End_User_Account__c);
	    			String suppRegion =  accSuppGpMap.get(ca.End_User_Account__c );
	
	    			if(suppRegion == 'APAC'){
	    				if(ca.Priority == 'Prod Down' || ca.Priority == '1-Critical' ){
	    				    ca.BusinessHoursId = bhMap.get('24/7 Support').Id;
	    				}
	    				else if(ca.Priority == '2-High' || ca.Priority == '3-Medium' ||  ca.Priority == '4-Low'){
	    					ca.BusinessHoursId = bhMap.get('Australia Business Hours').Id;
	    				}
	    			}
	    			
	    			if(suppRegion == 'EMEA'){
	    				if(ca.Priority == 'Prod Down' || ca.Priority == '1-Critical' ){
	                        ca.BusinessHoursId = bhMap.get('24/7 Support').Id;
	                    }
	                    else if(ca.Priority == '2-High' || ca.Priority == '3-Medium' ||  ca.Priority == '4-Low'){
	                    	ca.BusinessHoursId = bhMap.get('Coordinated Universal Time (UTC)').Id;
	                    }
	    			}
	    			
	    			if(suppRegion == 'Japan'){
	    				if(ca.Priority == 'Prod Down' || ca.Priority == '1-Critical' ){
	                        ca.BusinessHoursId = bhMap.get('24/7 Support').Id;
	                    }
	    				if(ca.Priority == '2-High' || ca.Priority == '3-Medium' ||  ca.Priority == '4-Low'){
	                        ca.BusinessHoursId = bhMap.get('Japan Business Hours').Id;
	                    }
	    			}
	    			
	    			if(suppRegion == 'Latin America'){
	    				if(ca.Priority == 'Prod Down' || ca.Priority == '1-Critical' ){
	                        ca.BusinessHoursId = bhMap.get('24/7 Support').Id;
	                    }
	                    if(ca.Priority == '2-High' || ca.Priority == '3-Medium' ||  ca.Priority == '4-Low' ){
	                        ca.BusinessHoursId = bhMap.get('Latin America Business Hours').Id;
	                    }
	    			}
	    			
	    			if(suppRegion == 'North America'){
	                    if(ca.Priority == 'Prod Down' || ca.Priority == '1-Critical' ){
	                        ca.BusinessHoursId = bhMap.get('24/7 Support').Id;
	                    }
	                    if(ca.Priority == '2-High' || ca.Priority == '3-Medium' ||  ca.Priority == '4-Low'){
	                        ca.BusinessHoursId = bhMap.get('Atlantic Business Hours').Id;
	                    }
	    			}
    		}
    	}
     
    }
    

    // method to map entitlements and business hours on Case based on the support Product selected on Case 
    public static void getEntitlementsOnCaseSetBH( List<Case> cases ){
        Map<Id, List<Case>> supportIdToCase = new Map<Id, List<Case>>();
        Map<String,BusinessHours> bhMap = new Map<String,BusinessHours>();
        for(BusinessHours bh: [SELECT Name,Id 
                             FROM   BusinessHours]){
        	bhMap.put(bh.Name,bh);
        }
       
        for(Case ca : cases){
        
          if( ca.Support_Access__c != null ) {
                if(supportIdToCase.containsKey(ca.Support_Access__c))
                    supportIdToCase.get( ca.Support_Access__c).add( ca );
                else
                    supportIdToCase.put( ca.Support_Access__c, new List<Case>{ca});
            }
        }
        if( !supportIdToCase.isEmpty() )    {
            Map<Id, Id> scIdToSaId = new Map<Id, Id>();
            for(Support_Access__c sa : [Select Service_Contract__c, Id From Support_Access__c where Id IN:supportIdToCase.keySet() ]){
                scIdToSaId.put( sa.Service_Contract__c , sa.Id);
            }
            Map<Id, Id> caseIdToEntitlementProcessId = new Map<Id, Id>();
            for(Entitlement e : [Select SlaProcess.Name, BusinessHoursId, ServiceContractId 
                                 From Entitlement 
                                 where ServiceContractId IN :scIdToSaId.keySet()]){
                Id saId = scIdToSaId.get( e.ServiceContractId );
                for(Case ca : supportIdToCase.get( saId )){
                    ca.EntitlementId = e.Id;
                    ca.Level_of_Service__c = e.SlaProcess.Name;
                }
            }
        }
        
        setBusinessHours(cases,bhMap);// Set business hours
     
    }

    /*
        Mehtod : updateBusinessHours
        Usage : Update business hours when priority is changed.
    */
    public static void updateBusinessHours( Map<Id,Case> oldCasesMap, List<Case> newCases ){
    	List<Case> cases = new List<Case>();
        for( Case ca : newCases ){
            Case oldCase = oldCasesMap.get(ca.Id);
            if(ca.Priority != oldCase.Priority){//Caclulate BH only when there is a change in the priority
                cases.add(ca);
            }
        }
        
        Map<String,BusinessHours> bhMap = new Map<String,BusinessHours>();
        if(cases != null && !cases.isEmpty()){
	        for(BusinessHours bh: [SELECT Name,Id 
	                             FROM   BusinessHours]){
	            bhMap.put(bh.Name,bh);
	        }
	        setBusinessHours(cases,bhMap);// Set business hours
        }
    }
  
    // Prevent users from closing a case if there are open activities associated with the case of record type escalation
    public static void checkOpenAcivity(List<Case> newCases , Map<Id,Case> oldMapCase ){
    	Map<Id,Case> mapOfCaseIds = new Map<Id,Case>();
        Map<Id,String> recordTypeMap = new Map<Id,String>();
        Set<Id> caseRTIdList = new Set<Id>();
        Set<Id> setOfEscCase= new Set<Id>();
        
        for( Case ca : newCases ){
            Case oldCase = oldMapCase.get(ca.Id);
            
            if(ca.Status != oldCase.Status && (ca.Status == 'Closed' )){
                mapOfCaseIds.put(ca.Id,ca);
                caseRTIdList.add(ca.RecordTypeId);
            }
        }
 
        for(Case ca : [SELECT Id,(SELECT Id,ActivityDate, Description FROM OpenActivities) OA
                       FROM   Case
                       WHERE  Id in: setOfEscCase]) {
            if(!ca.OpenActivities.isEmpty()){
            	Trigger.newMap.get(ca.Id).addError(OPEN_ACITIVITY_MSG);
            }              	
        }
    }
    
   /** MS - cannot remove b/c seems like it is used in vf components and probably pages ***/
    public static Boolean isCurrentUserProfileReadOnly(){
     /*	List<Profile> readOnlyProfile = [SELECT id FROM Profile WHERE Name =: PORTAL_READONLY_PROFILE ];
    	if(!readOnlyProfile.isEmpty() && UserInfo.getProfileId() == readOnlyProfile[0].id){
    		return true;
    	}  */  	
    	return false; 
    }

    public static void setProductSupportGroup (List<Case> newCases , Map<Id, Case> oldMapCase ) {   	
    	//Map<Id, RecordType> typesMap = recTypesMapProductFR();  
    	Map<Id, Support_Product__c> supProdCaseMap = new Map<Id, Support_Product__c>();
    	List<Id> supProdCaseIdList = new List<Id>();
    	Map<Id, RecordType> rectypes = new Map<Id, RecordType>(getAllTScaseTypes());
    	
        for ( Case ca : newCases ) {
            if ( ca.Support_Product__c != null ) 
                supProdCaseIdList.add(ca.Support_Product__c);  
            else if ( ca.Cloud_Service__c != null ) 
                supProdCaseIdList.add(ca.Cloud_Service__c);
        }
    	for (Support_Product__c supProd : [SELECT Id, Product_Support_Group__c 
                   						   FROM Support_Product__c WHERE Id In :supProdCaseIdList]) {                   						   	
              supProdCaseMap.put(supProd.Id, supProd);     						  	
        }    	
    		
        for( Case ca : newCases )  { 

        	if ( !rectypes.containsKey(ca.RecordTypeId) )
        	   continue;
        	/// Premise Cases OR PureConnect Cases, premise and cloud
            if ( rectypes.get(ca.RecordTypeId).DeveloperName == 'Genesys_Product_Case' ||
                 rectypes.get(ca.RecordTypeId).DeveloperName == 'Genesys_Feature_Request_Case' ||
                 rectypes.get(ca.RecordTypeId).DeveloperName == 'Premises_Service_Request' ||
                 (ca.Cloud_Platform__c != null && ca.Cloud_Platform__c.startswith('PureConnect')) )  {    
                	
	        	if ( oldMapCase != null )  {
	            	Case oldCase = oldMapCase.get(ca.Id);
	            	if ( ca.Support_Product__c == oldCase.Support_Product__c) 
	            	      continue;
	        	}	        	
	            if ( supProdCaseMap.get(ca.Support_Product__c) != null )  {                                  
	           		ca.Product_Support_Group__c = supProdCaseMap.get(ca.Support_Product__c).Product_Support_Group__c;   
	            } 
    		}
    		else if ( rectypes.get(ca.RecordTypeId).DeveloperName.startswith('Genesys_Cloud_') )  {
    			// Cloud Cases, except PureConnect cases
    			if ( oldMapCase != null )  {
	            	Case oldCase = oldMapCase.get(ca.Id);
	            	if ( ca.Cloud_Service__c == oldCase.Cloud_Service__c ) 
	            	      continue;
	        	}	        	
	            if ( supProdCaseMap.get(ca.Cloud_Service__c) != null )  {                                  
	           		ca.Product_Support_Group__c = supProdCaseMap.get(ca.Cloud_Service__c).Product_Support_Group__c;   
	            } 
    		}      
       }
    } 
    
    public static void setLastOwnerChangeDate (List<Case> newCases , Map<Id,Case> oldMapCase ) {
    	List<Case> cases = new List<Case>();   	
        for( Case ca : newCases ) {
        	
        	if ( oldMapCase != null )  {
            	Case oldCase = oldMapCase.get(ca.Id);
            	if ( ca.OwnerId != oldCase.OwnerId ) 
            	      ca.Last_Owner_Change__c = datetime.now();
        	}       	
        }
    }
    
    public static void setAutoFollowupDate (List<Case> newCases , Map<Id,Case> oldMapCase ) {
    	Map<Id, RecordType> rectypes = new Map<Id, RecordType>(getAllTScaseTypes());
    	
        for( Case ca : newCases )  {
        	if ( !rectypes.containsKey(ca.RecordTypeId) )
        	   continue;
        	         	
        	if ( rectypes.get(ca.RecordTypeId).DeveloperName == 'Genesys_Escalation_Case' ||
        	     rectypes.get(ca.RecordTypeId).DeveloperName == 'Genesys_Optimization_Case' ||
        	     rectypes.get(ca.RecordTypeId).DeveloperName == 'Genesys_Outage' )
        	       continue;
     
        	if ( oldMapCase != null )  {
            	Case oldCase = oldMapCase.get(ca.Id);           	
            	/// FR
            	if ( (rectypes.get(ca.RecordTypeId).DeveloperName).contains('Feature') ) {
            	
              	    if ( ca.Sub_Status__c == oldCase.Sub_Status__c ) 
              	       continue;
              	          
            		if (ca.Sub_Status__c == 'Info Required From Customer' || ca.Sub_Status__c == 'Solution Proposed' ) {
            		     if ( ca.Auto_Follow_up_Start_Date__c == oldCase.Auto_Follow_up_Start_Date__c )          		       
            		           ca.Auto_Follow_up_Start_Date__c = datetime.now(); 
            		}
	           		else  if ( ca.Auto_Follow_up_Start_Date__c == oldCase.Auto_Follow_up_Start_Date__c )
            		   	  ca.Auto_Follow_up_Start_Date__c = null;
 
            	}          	
            	else { /// all other Case types  
            	
	            	if ( ca.Status != oldCase.Status && ca.Priority != 'Prod Down' &&
	            	     (ca.Status == 'Awaiting Info' || ca.Status == 'Solution Proposed' || ca.Status == 'Replied') &&
	            	      ca.Auto_Follow_up_Start_Date__c == oldCase.Auto_Follow_up_Start_Date__c ) 
	            	    	   ca.Auto_Follow_up_Start_Date__c = datetime.now();
	                   	    	  
	            	else if ( ca.Priority != 'Prod Down' && oldCase.Priority == 'Prod Down' &&
	            	     (ca.Status == 'Awaiting Info' || ca.Status == 'Solution Proposed') &&
	            	      ca.Auto_Follow_up_Start_Date__c == oldCase.Auto_Follow_up_Start_Date__c ) 
	            	    	   ca.Auto_Follow_up_Start_Date__c = datetime.now(); 
	            	    	  
	            	else if ( ca.Status != oldCase.Status  &&
	            	          ca.Status != 'Awaiting Info' && ca.Status != 'Solution Proposed'  && ca.Status != 'Replied')
	            			    ca.Auto_Follow_up_Start_Date__c = null;
	            	
	            	else if (ca.Priority != oldCase.Priority && ca.Priority == 'Prod Down') 
	        	       			ca.Auto_Follow_up_Start_Date__c = null;
              }
        
        	}
           else {  /// new case
           	    //FR
           	    if ( (rectypes.get(ca.RecordTypeId).DeveloperName).contains('Feature') && ca.Auto_Follow_up_Start_Date__c == null &&
           	         (ca.Sub_Status__c == 'Info Required From Customer' || ca.Sub_Status__c ==  'Solution Proposed') )
           	           ca.Auto_Follow_up_Start_Date__c = datetime.now();
           	    /// all other types
        		else if  (ca.Priority != 'Prod Down' && ca.Auto_Follow_up_Start_Date__c == null &&
            	     (ca.Status == 'Awaiting Info' || ca.Status == 'Solution Proposed' || ca.Status == 'Replied') )
            	       ca.Auto_Follow_up_Start_Date__c = datetime.now();
           }
        }
    }
    
    public static void setHighestLevelOfService (List<Case> newCases , Map<Id,Case> oldMapCase ) {
        Map<Id, RecordType> rectypes = new Map<Id, RecordType>(getAllTScaseTypes());
        
		List<User> userList = [SELECT Id, Level_of_Expertise__c FROM User WHERE Level_of_Expertise__c != null];
		Map<Id, String> userMap = new Map<Id, String>();
		for (User userRec : userList) {
			userMap.put(userRec.Id, userRec.Level_of_Expertise__c);
		}
 	                                     
        for( Case ca : newCases ){
        	if ( !rectypes.containsKey(ca.RecordTypeId) )
        	   continue;
        	   
            if ( (rectypes.get(ca.RecordTypeId).DeveloperName != 'Genesys_Product_Case' &&
                  rectypes.get(ca.RecordTypeId).DeveloperName != 'Genesys_Feature_Request_Case' &&
                  !rectypes.get(ca.RecordTypeId).DeveloperName.startswith('Genesys_Cloud_') ) ||
                  ca.Highest_Level_of_Service__c == '5 Third Party' ) 
                     continue;
                     	
            if ( ca.Sub_Status__c == 'Third Party Pending' )
                       ca.Highest_Level_of_Service__c = '5 Third Party';
                       
            else if ( ca.Sub_Status__c == 'Engineering Request' ) 
                  ca.Highest_Level_of_Service__c = '4 R&D';                                        
                                     
            else if ( ca.Highest_Level_of_Service__c == '3 Expert' )
                      continue;
            
            else {     	
            	  List<String> levels = new List<String>();
				  /// Expert Help Level 
	              if ( userMap.get(ca.Expert_Help__c) != null )
	                     levels.add( userMap.get(ca.Expert_Help__c) );

            	  ///Owner Level
            	  if ( userMap.get(ca.OwnerId) != null )
	                     levels.add( userMap.get(ca.OwnerId) );
 
	              /// current case level         		   
            	  if ( ca.Highest_Level_of_Service__c != null )
            		      levels.add(ca.Highest_Level_of_Service__c);
           		       
            	  if ( !levels.isEmpty() )  {         			   
            			levels.sort();
            			if ( ca.Highest_Level_of_Service__c != levels.get( levels.size()-1 ) )
  								ca.Highest_Level_of_Service__c = levels.get( levels.size()-1 );  						
            	  }
            } 
         } ///for (case)       
    }   
    
 
   public static List<Support_Product__c> getCloudProdLine () {
    	List<Support_Product__c> cloudProdLine = [SELECT id, Name FROM Support_Product__c WHERE Name ='Cloud' 
    	                                          AND Product_Type__c ='Product Line'];
        return cloudProdLine;
    }
    
   public static void getCaseAccessLevel(String caseId) {
   	
            ID contId = ContactUtil.getUserContactId();
            
	        List<Case> caseLst = [SELECT Sold_To_Account__c, End_User_Account__c, ContactId,
	                                     RecordType.DeveloperName, Cloud_Deployment__c 
	                              FROM Case WHERE Id = :caseId];                             
	        
	        if ( caseLst.isEmpty() )
	            return;
	        
	        /// Admin Cases
	        if ( caseLst[0].ContactId == contId && caseLst[0].RecordType.DeveloperName == 'Genesys_Admin_Case') {
	        	caseAccessLevel = 'Read/Write';
	        	return; 
	        }
	        
	        List<Support_Access_Cloud__c> cloudAccLst = new List<Support_Access_Cloud__c>();
	        List<Support_Access__c> premiseAccLst = new List<Support_Access__c>();
	        
	        if ( caseLst[0].RecordType.DeveloperName.startswith('Genesys_Cloud_') && caseLst[0].Cloud_Deployment__c != null ) {
	        	  cloudAccLst = [SELECT Access_Level__c, Deployment_Support_Status__c
	        	             FROM Support_Access_Cloud__c
	        	            WHERE  Contact__c = :contId 
	        	              AND  Cloud_Deployment__c = :caseLst[0].Cloud_Deployment__c
	        	              AND  Deployment_Support_Status__c != 'Billing Only'
	        	              AND  Deployment_Support_Status__c != 'Order Processing'  
	        	              AND Access_Status__c = 'Active'
	        	              AND Access_Level__c in ('Read/Write','Read Only')];
	        	
	        }  
	        else {                         
		    	   premiseAccLst = [SELECT SR_Access_Level__c, Service_Contract_Status__c
				    	            FROM Support_Access__c 
							        WHERE Contact__c = :contId   
						  	         AND Status__c = 'Active' 
				                     AND SR_Access_Level__c in ('Read/Write','Read Only')
				                      AND  Sold_To_Account__c = :caseLst[0].Sold_To_Account__c
				                      AND  End_User_Account__c = :caseLst[0].End_User_Account__c ];
	        }
	                              
    	   if ( !cloudAccLst.isEmpty() )  {
    	   	     
    	   	     if ( String.isBlank(cloudAccLst[0].Deployment_Support_Status__c) || cloudAccLst[0].Deployment_Support_Status__c != 'Active' )
    	   	          caseAccessLevel = 'Read Only';
    	   	     else 
    	       		  caseAccessLevel = cloudAccLst[0].Access_Level__c;
    	   }
    	   else if ( !premiseAccLst.isEmpty() )  {
    	   	      if ( String.isBlank(premiseAccLst[0].Service_Contract_Status__c) || premiseAccLst[0].Service_Contract_Status__c != 'Active' )
    	   	          caseAccessLevel = 'Read Only';
    	   	      else
    	          	  caseAccessLevel = premiseAccLst[0].SR_Access_Level__c;
    	   }
    	   else
    	          caseAccessLevel = 'None';
    	          
    	   return;
    }
  
    public static Boolean canUserAccessThisCase(String caseId) {  
    	if ( caseAccessLevel == null )
    	      getCaseAccessLevel(caseId);
    
		 if ( caseAccessLevel != 'None' ) 
	           return true;
	       else
	           return false;      
	     return null;                            
    }
    
    public static Boolean isCaseAccessLevelReadOnly (Case ca) {   	
       if ( caseAccessLevel == null )
    	      getCaseAccessLevel(ca.Id);
    
        if ( caseAccessLevel == 'Read Only') 
           return true;
        else
           return false;                            
    }
    
    public static List<Support_Product__c> getCloudProducts (Support_Product__c cloudProdLine) {
    	Support_Product__c line = new Support_Product__c();
    	if ( cloudProdLine == null ) {   	
    		List<Support_Product__c> lineList = CaseUtil.getCloudProdLine();
    	    if ( ! lineList.isEmpty() ) 
    	        line = lineList[0];
    	    else
    	        return null;
    	}
    	else
    	    line = cloudProdLine;
    	                      
        List<Support_Product__c> cloudProd = [SELECT id, Name FROM Support_Product__c 
                                              WHERE Name ='Cloud Products' AND Product_Type__c ='Product' 
                                              AND Parent_Product__c = :line.Id];
        return cloudProd;    	
    }
    
    public static List<RecordType> getAllTScaseTypes() {
    	if ( caseTStypesLst == null )  {    		
    		caseTStypesLst = [SELECT Id, Name, DeveloperName FROM RecordType 
                              WHERE SobjectType = 'Case' AND isActive = true
                              ORDER BY Description];
    	}   	
    	return caseTStypesLst;
    }
    
    public static List<RecordType> getTScaseTypes() {    	
    	return  [SELECT Id, Name, DeveloperName FROM RecordType 
                              WHERE SobjectType = 'Case' AND isActive = true
                              AND DeveloperName IN ('Genesys_Product_Case', 
                                  'Genesys_Admin_Case', 'Genesys_Cloud_Support_Request', 'Genesys_Cloud_Service_Request',
                                   'Genesys_Cloud_Incident','Premises_Service_Request') 
                                 //'Genesys_Feature_Request_Case', 'Genesys_Cloud_Feature_Request'
                              ORDER BY Description];
    }
    
    public static Map<Id, RecordType> getAllTScaseTypesMap() {
    	if ( caseTStypesMap == null )  {    		
    		caseTStypesMap  = new Map<Id, RecordType>(CaseUtil.getAllTScaseTypes());
    	}   	
    	return caseTStypesMap;
    }
        
    public static String casePageTitleByType(String recTypeId)  {
    	String pageTitle='';
    	
    	Map<String, String> pageTitles = new Map<String, String> {
    		'Genesys_Product_Case'            => 'On-Premise Support Case',
    		'Genesys_Feature_Request_Case'    => 'On-Premise Feature Request',
    		'Premises_Service_Request'        => 'On-Premise Service Request',
    		'Genesys_Admin_Case'              => 'Admin Case',
    		'Genesys_Cloud_Support_Request'   => 'Cloud Support Case',
    		'Genesys_Cloud_Service_Request'   => 'Cloud Service Request',
    		'Genesys_Cloud_Incident'          => 'Cloud Incident',
    		'Genesys_Cloud_Feature_Request'   => 'Cloud Feature Request'
    	};
    	
    	if ( String.isNotBlank(recTypeId) ) {    	     	 
   	   	  String caseType = CaseUtil.getAllTScaseTypesMap().get(recTypeId).DeveloperName;   	   	
   	      pageTitle = pageTitles.get(caseType);   	     
    	}    	
    	return pageTitle;
    }  
}