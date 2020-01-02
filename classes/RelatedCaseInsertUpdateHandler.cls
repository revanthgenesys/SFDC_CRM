public with sharing class RelatedCaseInsertUpdateHandler {

	private class RelatedCaseStruct {
		public Id caseId;
		public String caseStatus;
		public Related_Case__c relatedCase;
	}

	// wsmith
	// There are two ways this gets triggered
	// A) User creates a new Related Escalation
	// B) User creates a newe Case Relationship
	public static void updateRelatedCaseFields(List<Related_Case__c> newList){
		List<RecordType> recordType = [SELECT id FROM RecordType WHERE DeveloperName = 'Genesys_Escalation_Case'];
		List<RecordType> recordTypeRelatedCase = [SELECT id FROM RecordType WHERE DeveloperName = 'Related_Escalation' and sObjectType = :Related_Case__c.sObjectType.getDescribe().getName()];
		List<Related_Case__c> casesToBeUpdate = new List<Related_Case__c>();
		Set<Id> rsIds = new Set<Id>();

		for(Related_Case__c eachRC : newList)
			rsIds.add(eachRC.id);
		System.debug(LoggingLevel.ERROR, 'NKC debug recordType[0].id ['+recordType[0].id+']');

		//wsmith .. this works only with Action B
		//List<Related_Case__c> relatedCaseRecords = [SELECT Case__r.RecordTypeId, Case__r.Status, Case__c,
		//	Related_Escalation__c, Escalation__c, Escalation__r.RecordTypeId
		//	Parent_Case__c, RecordTypeId, RecordType.Name
		//		FROM Related_Case__c WHERE id in : rsIds AND (Case__r.RecordTypeId =: recordType[0].id or Escalation__r.RecordTypeId = : recordType[0].id)];

		// wsmith make the list broder to satify both Actions A and B
		List<Related_Case__c> relatedCaseRecords =
			[SELECT Case__c
				,Case__r.RecordTypeId
				,Case__r.Status
				,Case__r.RecordType.Name
				,Related_Escalation__c
				,Escalation__c
				,Escalation__r.Status
				,Escalation__r.RecordTypeId
				,Escalation__r.RecordType.Name
				,Parent_Case__c
				,Parent_Case__r.Status
				,Parent_Case__r.RecordTypeId
				,Parent_Case__r.RecordType.Name
				,RecordTypeId
				,RecordType.Name
				FROM Related_Case__c
				WHERE id in :rsIds
				AND (
					Case__r.RecordTypeId = :recordType[0].id
					OR
					Escalation__r.RecordTypeId = :recordType[0].id
				)];

		//System.debug(LoggingLevel.ERROR, 'NKC debug relatedCaseRecords[0].Case__r.RecordTypeId ['+relatedCaseRecords[0].Case__r.RecordTypeId+']');

		// Related Case records to update for Action B
		List<Related_Case__c> updateRelatedCaseRecords = new List<Related_Case__c>();
		// Case records to update for Action A
		// Map<Case.Id, RelatedCaseStruct>
		Map<Id, RelatedCaseStruct> relatedEscalationCaseStatusMap = new Map<Id, RelatedCaseStruct>();

		for(Related_Case__c eachCase : relatedCaseRecords) {

			if (eachCase.Case__r.RecordTypeId == recordType[0].id) {
				// Action B
				eachCase.Related_Escalation__c = eachCase.Parent_Case__c;
				eachCase.Escalation__c = eachCase.Case__c;

				Related_Case__c updateRelatedCaseRecord = new Related_Case__c(Id = eachCase.Id);
				updateRelatedCaseRecords.add(updateRelatedCaseRecord);
				updateRelatedCaseRecord.Related_Escalation__c = eachCase.Parent_Case__c;
				updateRelatedCaseRecord.Escalation__c = eachCase.Case__c;

				RelatedCaseStruct rcs = new RelatedCaseStruct();
				rcs.caseId = eachCase.Parent_Case__c;
				rcs.caseStatus = eachCase.Parent_Case__r.Status;
				rcs.relatedCase = eachCase;
				relatedEscalationCaseStatusMap.put(eachCase.Parent_Case__c, rcs);
			}

			if (eachCase.Escalation__r.RecordTypeId == recordType[0].id) {
				// Action A
				if (
					(null != eachCase.Escalation__c) &&
					(null != eachCase.Related_Escalation__c) &&
					(eachCase.RecordTypeId == recordTypeRelatedCase[0].Id)) {

					RelatedCaseStruct rcs = new RelatedCaseStruct();
					rcs.caseId = eachCase.Related_Escalation__c;
					rcs.caseStatus = eachCase.Escalation__r.Status;
					rcs.relatedCase = eachCase;
					relatedEscalationCaseStatusMap.put(eachCase.Related_Escalation__c, rcs);
				}
			}
		}
		if (!updateRelatedCaseRecords.isEmpty()) {
			update updateRelatedCaseRecords;
		}

		if (!relatedEscalationCaseStatusMap.isEmpty()) {
			updateRelatedEscalationCases(relatedEscalationCaseStatusMap);
		}
	}

	private static void updateRelatedEscalationCases(Map<Id, RelatedCaseStruct> relatedEscalationCaseStatusMap) {
		Map<Id, Case> updateCaseMap = new Map<Id, Case>();
		List<RelatedCaseStruct> relatedCaseStructs = relatedEscalationCaseStatusMap.values();
		for (RelatedCaseStruct rec : relatedEscalationCaseStatusMap.values()) {
			Case c = updateCaseMap.get(rec.caseId);
			if (null == c) {
				c = new Case(Id = rec.caseId);
 				updateCaseMap.put(rec.caseId, c);
 				// initilize to false
 				c.Escalation_Flag__c = false;
			}
 			if (CaseUtil.STATUS_CLOSED != rec.caseStatus) {
 				c.Escalation_Flag__c = true;
 			}
		}
		if (!updateCaseMap.isEmpty()) {
			try {
				// not sure about if case related triggers fire again, maybe should lock triggers first
				update updateCaseMap.values();
			}
			catch (DmlException e) {
				// caught dmlexception
				for (Integer i = 0, leni = e.getNumDml(); i < leni; ++i) {
					// loop through exceptions and get case id
					Id caseId = e.getDmlId(i);
					for (RelatedCaseStruct rcs : relatedEscalationCaseStatusMap.values()) {
						// loop through the related escalations
						if (rcs.caseId == caseId) {
							rcs.relatedCase.addError(e.getDmlMessage(i));
						}
					}
				}
			}
		}
	}
	
	public static void updateEscaltionFlag (Case cs, String updateType) {
	 /// called from CaseMain trigger	
		if ( updateType == 'Closed' )
		   cs.Escalation_Flag__c = false;
		
		else if ( updateType == 'Reopen' ) {
			List<RecordType> recordType = [SELECT id FROM RecordType WHERE DeveloperName = 'Genesys_Escalation_Case'];
			List<RecordType> recordTypeRelatedCase = [SELECT id FROM RecordType WHERE DeveloperName = 'Related_Escalation' and sObjectType = :Related_Case__c.sObjectType.getDescribe().getName()];
	
	        Integer n = [SELECT count() FROM Related_Case__c
						  WHERE (Related_Escalation__c = :cs.Id OR Parent_Case__c = :cs.Id) AND
							    (Case__r.RecordTypeId = :recordType[0].id OR Escalation__r.RecordTypeId = :recordType[0].id)];
							    
	        if ( n > 0 )
	           cs.Escalation_Flag__c = true;
	   }
	} 
}