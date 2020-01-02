/*
Case Relationship
04/15/2013    Naresh Kumar    Original for Task/Story #   
Description : Class is called from case trigger (before insert and after insert) and provides functionality for FR field updates.
*/
public class FR_FieldUpdate {
    public static void updateFRFields(List<Case> newCases, Map<id, Case> oldMap){
        Map<String,String> mapCaseIdsVsComponentIds = new Map<String,String>();
        Map<String,String> mapCaseIdsVsSupportProductIds = new Map<String,String>();
        Map<String,String> mapCaseIdsVsProductLineIds = new Map<String,String>();

		// wsmith 20130614 This is a little bit of a hack for time to get only tier 3 queue updates working
		// the users can only update the Tier 3 Queue so we have to update the Tier 3 Queue Email
		// Below we do not do product lines so not included here 
        //Map<String,String> mapTier3QueueCaseIdsVsComponentIds = new Map<String,String>();
        //Map<String,String> mapTier3QueueCaseIdsVsSupportProductIds = new Map<String,String>();

		// Get the Queue names for the Tier 3 Queue Emails
		Map<Id, Group> queueMap = new Map<Id, Group>(
			[Select Type
				,Name
				,Email
				,DeveloperName
				From Group
				where Type = 'Queue'
				and Email != null]
			);

        //Looping over each record and adding the respective ids to the sets.
        for(Case eachCase : newCases){

			// Issue 116
			populateMaintenanceQueueEmail(eachCase, queueMap);
            
            // wsmith Issue 843 (Track 2 UAT Test Cases & Issues Log)
            populateFollowTheSunTracking(eachCase, oldMap);

            // wsmith 20130614 .. I am worried about this condition. I will assume
            // the Tier 3 targets happen after the case is created
            // so I do not have to set the Tier 3 Queue Email upon Case creation
            //Skip the record if nothing has changed
            //Naresh Kumar	07/02/2013 - This part of code should also being called in case of insert. PROD Issue
            //if(oldMap == null) 
            //    continue;  
     /* MS - 08/11/2013 - commented
			// wsmith: unset the tier 3 queue email address if tier 3 queue has changed
			if (oldMap == null || eachCase.Tier_3_Queue__c != oldMap.get(eachCase.id).Tier_3_Queue__c) {
				eachCase.Tier_3_Queue_Email__c = null;
				if (null != eachCase.Tier_3_Queue__c) {
					if (null != eachCase.Component__c) {
						mapTier3QueueCaseIdsVsComponentIds.put(eachCase.id, eachCase.Component__c);
					}
					if (null != eachCase.Support_Product__c) {
						mapTier3QueueCaseIdsVsSupportProductIds.put(eachCase.id, eachCase.Support_Product__c);
					}
				}
			}
       MS-08/11/2013 */
       
            if  (eachCase.Component__c != null && ((oldMap == null || eachCase.Component__c != oldMap.get(eachCase.id).Component__c) || (eachCase.Status == 'Open - Product Management' && (oldMap == null || eachCase.Status != oldMap.get(eachCase.id).Status))))
                mapCaseIdsVsComponentIds.put(eachCase.id, eachCase.Component__c);            
            else if(eachCase.Support_Product__c != null && ((oldMap == null || eachCase.Support_Product__c != oldMap.get(eachCase.id).Support_Product__c) || (eachCase.Status == 'Open - Product Management' && (oldMap == null || eachCase.Status != oldMap.get(eachCase.id).Status))))            
                mapCaseIdsVsSupportProductIds.put(eachCase.id, eachCase.Support_Product__c );
            //else if(eachCase.Product_Line__c != null )                
            //    mapCaseIdsVsProductLineIds.put(eachCase.id, eachCase.Product_Line__c );
        }
        System.debug('NKC debug mapCaseIdsVsComponentIds ['+mapCaseIdsVsComponentIds+']');
        //Don't continue if there no record(s) to update
        if(mapCaseIdsVsComponentIds.values().size() == 0 && mapCaseIdsVsSupportProductIds.values().size() == 0 
            && mapCaseIdsVsProductLineIds.values().size() == 0 )
              //&& mapTier3QueueCaseIdsVsComponentIds.isEmpty() && mapTier3QueueCaseIdsVsSupportProductIds.isEmpty())
            return;
        //Querying all the records.
        List<Support_Product__c> SPs = [SELECT id, PM_Owner__c, PM_Owner__r.FirstName, PM_Owner__r.LastName, Product_Support_Group__c 
                                          /// MS; Tier_3_Manager__r.FirstName, Tier_3_Manager__r.LastName, Tier_3_Queue__c
                    	FROM Support_Product__c
                    	WHERE (
                    		id IN : mapCaseIdsVsComponentIds.values()
                    		OR id IN : mapCaseIdsVsSupportProductIds.values() 
                    		OR id IN: mapCaseIdsVsProductLineIds.values() 
                    		//OR id IN :mapTier3QueueCaseIdsVsComponentIds.values() 
                    		//OR id IN :mapTier3QueueCaseIdsVsSupportProductIds.values()
                    	)];
        Map<String, Support_Product__c> mapSPs = new Map<String, Support_Product__c>();
        System.debug('NKC debug SPs ['+SPs+']');
        //Looping over all the components records
        for(Support_Product__c sp : SPs)
            mapSPs.put(sp.id, sp);
        
        //Again looping over each case records.        
        for(Case eachCase : newCases){
        	// wsmith this is for product/component changes only
        	if (
        		(!mapCaseIdsVsComponentIds.isEmpty()) ||
        		(!mapCaseIdsVsSupportProductIds.isEmpty()) ||
        		(!mapCaseIdsVsProductLineIds.isEmpty())
        		) {
	            Support_Product__c sp;
    	        //For Component 
        	    sp = mapSPs.get(mapCaseIdsVsComponentIds.get(eachCase.id));
            	System.debug('NKC debug sp ['+sp+']');
	            populateCaseFields(eachCase, sp);
	            
	            //populateTier3QueueEmail(eachCase, sp, queueMap);
    	        //For Support Products
        	    sp = mapSPs.get(mapCaseIdsVsSupportProductIds.get(eachCase.id));
            	populateCaseFields(eachCase, sp);
            	//populateTier3QueueEmail(eachCase, sp, queueMap);
            	//Product Lines
            	sp = mapSPs.get(mapCaseIdsVsProductLineIds.get(eachCase.id));
            	populateCaseFields(eachCase, sp);
            	//populateTier3QueueEmail(eachCase, sp, queueMap);            	
            	
        	}
        	/* MS-08/11/2013
        	// wsmith this is for tier 3 queue change only to set email
        	if (!mapTier3QueueCaseIdsVsComponentIds.isEmpty()) {
        		Support_Product__c sp = mapSPs.get(mapTier3QueueCaseIdsVsComponentIds.get(eachCase.id));
        		populateTier3QueueEmail(eachCase, sp, queueMap);
        	}
        	if (!mapTier3QueueCaseIdsVsSupportProductIds.isEmpty()) {
        		Support_Product__c sp = mapSPs.get(mapTier3QueueCaseIdsVsSupportProductIds.get(eachCase.id));
        		populateTier3QueueEmail(eachCase, sp, queueMap);
        	}
        	MS-08/11/2013 */
        }        
    } 

    //Populates case fields
    private static void populateCaseFields(Case eachCase, Support_Product__c sp){
        if(sp == null)
            return;
        //Updates T3 Manager
        /* MS
        if(sp.Tier_3_Manager__c != null)                   
            eachCase.Tier_3_Manager__c = sp.Tier_3_Manager__r.FirstName+ ' '+ sp.Tier_3_Manager__r.LastName;
        MS */
        //Updates T3 Queues
        // wsmith note for some reason we always reset it so it will take the product version (overwrite the component)
        // I do not know why this is like this
        // since we set it first for component, then product, then product line (actually not product line)
		// if this changes, rexamine populateTier3QueueEmail wich also just overrides
        /// MS; eachCase.Tier_3_Queue__c = sp.Tier_3_Queue__c;

        //Updates PM Owner
        ///MS- 6/13/13 
        //if(sp.PM_Owner__c != null)  
        if(sp.PM_Owner__c != null && eachCase.Status == 'Open - Product Management')                
            eachCase.PMOwnerNew__c = sp.PM_Owner__c;
        System.debug('NKC debug eachCase.PMOwnerNew__c ['+eachCase.PMOwnerNew__c+']');
        System.debug('NKC debug sp.PM_Owner__c ['+sp.PM_Owner__c+']');
            
    }
    
    /* MS-08/11/2011
    private static void populateTier3QueueEmail(Case eachCase, Support_Product__c sp, Map<Id, Group> queueMap) {
        if(sp == null)
            return;
        eachCase.Tier_3_Queue_Email__c = null;
        if ((null != queueMap) && (null != eachCase.Tier_3_Queue__c)) {
        	for (Group queueElem : queueMap.values()) {
        		if (queueElem.Name == eachCase.Tier_3_Queue__c) {
        			eachCase.Tier_3_Queue_Email__c = queueElem.Email;
        			break;
        		}
        	}
        }
    }
   MS-08/11/2011 */

    private static void populateMaintenanceQueueEmail(Case eachCase, Map<Id, Group> queueMap) {
    	if (null == eachCase.Maintenance_Queue__c) {
    		eachCase.Maintenance_Queue_Email__c = null;
    	}
        if ((null != queueMap) && (null != eachCase.Maintenance_Queue__c)) {
        	for (Group queueElem : queueMap.values()) {
        		if (queueElem.Name == eachCase.Maintenance_Queue__c) {
        			eachCase.Maintenance_Queue_Email__c = queueElem.Email;
        			return;
        		}
        	}
        }
        // if we reach here we did not find a match so we should blank out the old value so the
        // wrong user does not get an email
        eachCase.Maintenance_Queue_Email__c = null;
        
    }

    private static void populateFollowTheSunTracking(Case newCase, Map<Id, Case> oldCaseMap) {
        Case oldCase = null;
        if (null == oldCaseMap) {
            // assume insert
            if (newCase.Follow_the_Sun__c) {
                newCase.Follow_the_Sun_Tracking__c = true;
                return;
            }
        }
        else if (null != (oldCase = oldCaseMap.get(newCase.Id))) {
            // assume update
            if (
                (newCase.Follow_the_Sun__c) &&
                (!newCase.Follow_the_Sun_Tracking__c)
                ) {
                // don't reset if already set to true
                // some of the aboye checks are redundant
                newCase.Follow_the_Sun_Tracking__c = true;
            }
        }                 
    } 
      
}