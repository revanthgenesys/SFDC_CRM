@isTest(seeAllData=true)
private class RecordType_H_Test {

	public static testmethod void constructor_Test() {
		// test default constructor
		RecordType_H obj = new RecordType_H();
	}

	public static testmethod void createRecordTypeMap_Test() {
		String opportunityLabelName = Schema.sObjectType.Opportunity.getName();
		// get all opportunity record types
		Map<String, Map<String, RecordType>> RECORDTYPEMAP =
			RecordType_H.createRecordTypesMap(new String[]{opportunityLabelName});
		System.assertNotEquals(null, RECORDTYPEMAP);
 
		if (RECORDTYPEMAP.size() > 0) {
			// get one specific record type
			RECORDTYPEMAP =
				RecordType_H.createRecordTypesMap(new String[]{opportunityLabelName},
					new String[]{RECORDTYPEMAP.get(opportunityLabelName).values().get(0).Name});
			System.assertNotEquals(null, RECORDTYPEMAP);
			System.assertEquals(1, RECORDTYPEMAP.size());
			System.assertEquals(1, RECORDTYPEMAP.get(opportunityLabelName).size());
		}

		// test with null sObjects
		RECORDTYPEMAP =
			RecordType_H.createRecordTypesMap(null, new String[]{});
		System.assertNotEquals(null, RECORDTYPEMAP);
		System.assertEquals(0, RECORDTYPEMAP.size());
	}

}