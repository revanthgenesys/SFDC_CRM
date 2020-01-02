public with sharing class Opportunity_H {

	// get the record types (by given name)
	private static Map<String, Map<String, RecordType>> RECORDTYPESMAP =
		RecordType_H.createRecordTypesMap(new String[]{Schema.sObjectType.Opportunity.getName()}, null);

	public static Map<String,RecordType> RECORDTYPEMAP = RECORDTYPESMAP.get(Schema.sObjectType.Opportunity.getName());

	public Opportunity_H() {
	}

}