public with sharing class RecordType_H {

	public RecordType_H() {
	}

	// return all recordstypes for the requested sObject types
	public static Map<String, Map<String, RecordType>> createRecordTypesMap(String[] sObjTypes) {
		return createRecordTypesMap(sObjTypes, null);
	}

	public static Map<String, Map<String, RecordType>> createRecordTypesMap(String[] sObjTypes, String[] recordTypeNames) {

		Map<String, Map<String, RecordType>> sObjTypesMap = new Map<String, Map<String, RecordType>>();

		if ((sObjTypes == null) || (sObjTypes.isEmpty())) {
			return sObjTypesMap;
		}

		List<RecordType> recTypes;

		if ((recordTypeNames != null) && (!recordTypeNames.isEmpty())) {
			// return specific record types by name for sObjects
			recTypes =
				[select Name
					,DeveloperName
					,sObjectType
					from RecordType
					where sObjectType in :sObjTypes
					and Name in :recordTypeNames];
		}
		else {
			// return all record types for sObjects
			recTypes =
				[select Name
					,DeveloperName
					,sObjectType
					from RecordType
					where sObjectType in :sObjTypes];
		}

		for (RecordType recType : recTypes) {
			Map<String, RecordType> tmp = sObjTypesMap.get(recType.sObjectType);
			if (tmp == null) {
				tmp = new Map<String, RecordType>();
				sObjTypesMap.put(recType.sObjectType, tmp);
			}
			tmp.put(recType.Name, recType);
		}
		return sObjTypesMap;
	}

}