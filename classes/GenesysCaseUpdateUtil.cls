/*
	Class  : GenesysCaseUpdateUtil
	Author : Vinay L 4/1/2013 
	Usage : 1) Util class to create case feed when a case update is added in service console
			2) Field updates are made on parent Case object when a case update is made
   7/21/2013  Updated by Vikram For PS Updpate
   

*/

public without sharing class GenesysCaseUpdateUtil {
	public GenesysCaseUpdateUtil() {}
	
	/*
		Method : createCaseFeed
		Usage  : Util class to create case feed when a case update is added in service console
	*//*	
	
	public static void createCaseFeed(List<Genesys_Case_Updates__c> newGcuList){
		List<FeedItem> feedItemList = new List<FeedItem>();
		Id loggedInUsrId =  Userinfo.getUserId();
		User u = [Select Id,IsPortalEnabled from User where Id=:loggedInUsrId][0];
		
		if(!u.IsPortalEnabled){
			
			for(Genesys_Case_Updates__c gcu:newGcuList){
				FeedItem fItem = new FeedItem();
				fItem.Type = 'LinkPost'; 
				fItem.ParentId = gcu.Case__c; 
				fItem.LinkUrl = '/ui/support/servicedesk/ServiceDeskPage#%2F'+gcu.Id;
				fItem.Title  = 'View Case Update';
				fItem.Body =  'posted a new '+gcu.Type__c + ' update, subject: '+gcu.Name ; 
				feedItemList.add(fItem); 
			}
			
			system.debug('--feedItemList'+feedItemList);
			if(feedItemList!= null && !feedItemList.isEmpty()) insert feedItemList;
		}
	}
	
 */	/*
		Method :	recordLastUpdate
		Usage  :    1. A public comment from Genesys Care to Customer
				    2. A private comment from Genesys Care to Genesys Care
				    3. A public comment from Customer to Genesys Care
	
					When each of these actions occur, field updates need to be triggered on the parent case object. 
					Requirements 
					For each action above:
					1. Update “Last_Public_Care_Update__c“ the field on the parent case to NOW(). 
					2. Update “Last_Private_Care_Update__c“ the field on the parent case to NOW(). 
					3. Update “Last_Public_Customer_Update__c“ the field on the parent case to NOW(). 
	*/ /*
	public static void recordLastUpdate(List<Genesys_Case_Updates__c> newGcuList){
		Id loggedInUsrId =  Userinfo.getUserId();
		User u = [Select Id,IsPortalEnabled from User where Id=:loggedInUsrId][0];
		
		List<Id> gcuCaseIdList = new List<Id>();
		
		for(Genesys_Case_Updates__c gcu:newGcuList){
			gcuCaseIdList.add(gcu.Case__c);
		}

		Map<Id,Case> mapOfCase = new Map<Id,Case>();
		
		for(Case ca: [Select Last_Public_Care_Update__c,Last_Private_Care_Update__c, 
							 Last_Public_Customer_Update__c, Owner.Email, Contact.Id, Contact_Alternate_Email__c 
					  From	 Case 
					  Where  id in:gcuCaseIdList]){
								  	
	    	mapOfCase.put(ca.Id,ca);
	    }
	    
	    List<Case> updateCaseList = new List<Case>();
	    
		for(Genesys_Case_Updates__c gcu:newGcuList){
			Case updcase = new Case();
			Case updcase2 = mapOfCase.get(gcu.Case__c);
			updcase = new Case (Id = gcu.Case__c);
			if(!u.IsPortalEnabled){
				
				if(gcu.Make_Public__c){
					//A public comment from Genesys Care to Customer
				    if(gcu.Type__c != null && gcu.Type__c.contains('PS Update'))
					 updcase.Last_Public_Customer_Update__c = system.now();
					else
					 updcase.Last_Public_Care_Update__c = system.now();
					 
					gcu.Case_Owner_Email__c = updcase2.Owner.Email;
					gcu.Case_Contact__c = updcase2.ContactId;
					gcu.Case_Contact_Alternate_Email__c = updcase2.Contact_Alternate_Email__c;
				}else{
					//A private comment from Genesys Care to Genesys Care
					system.debug('--in pricate comment');
					updcase.Last_Private_Care_Update__c = system.now();
					gcu.Case_Owner_Email__c = updcase2.Owner.Email;
					gcu.Case_Contact__c = updcase2.ContactId;
					gcu.Case_Contact_Alternate_Email__c = updcase2.Contact_Alternate_Email__c;
				}
			}else{// Customer Portal User
				
				//A public comment from Customer to Genesys Care
				gcu.Make_Public__c = true;
				updcase.Last_Public_Customer_Update__c = system.now();
				gcu.Case_Owner_Email__c = updcase2.Owner.Email;
				gcu.Case_Contact__c = updcase2.ContactId;	
				gcu.Case_Contact_Alternate_Email__c = updcase2.Contact_Alternate_Email__c;			
			}
			updateCaseList.add(updcase);	
		}
		update updateCaseList;// Update List of Cases
	}
	
	private static Map<Id,Genesys_Case_Updates__c> processedUpdates = null;
	public static void updateMadePublic(List<Genesys_Case_Updates__c> newList, Map<Id, Genesys_Case_Updates__c> oldMap) {
		if ( processedUpdates == null )
    	       processedUpdates = new Map<Id,Genesys_Case_Updates__c>();
    	
    	List<Case> caseListToUpdate = new List<Case>();       
    	for ( Genesys_Case_Updates__c cu : newList ) {
 
            if ( processedUpdates.containsKey(cu.Id) ) 
                continue;
            
            Genesys_Case_Updates__c oldUpdate = oldMap.get(cu.Id);           
            if ( cu.Make_Public__c == true && oldUpdate.Make_Public__c == false && cu.Case__c != null ) {
            	 Case caseToUpdate = new Case (ID = cu.Case__c, 
            	                               Last_Public_Care_Update__c = system.now());
            	                               
            	 caseListToUpdate.add(caseToUpdate);
            }                   
    	}
    	if ( !caseListToUpdate.isEmpty() ) {
    		try {
    			update caseListToUpdate;
    		}
    		catch (Dmlexception de) {}    		
    	}	                    
	}
	*/
}