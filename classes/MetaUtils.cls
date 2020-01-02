/* MetaUtils
 * Utility method to get record type Information without query.
 *
 * Developer: Harish
 * Business Owner: 
 *
 * Scenario:
 * 
 * 
 *
 * History:
 
 * 03/08/2017, Harish Emmadi, APTTUS - created MetaUtils.
 */
public with sharing class MetaUtils {
    public class RecordTypeNotFoundException extends Exception {}

    private static final Map<String,Map<String, Schema.RecordTypeInfo>> sObjectRecordTypes = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    
    public static Id getRecordTypeId(SObjectType so, String recordTypeName) {
        if (so != null && String.isNotBlank(recordTypeName)) {
            Schema.DescribeSObjectResult r = so.getDescribe();
            if (r != null && !sObjectRecordTypes.containsKey(r.getName())) {
                sObjectRecordTypes.put(r.getName(), r.getRecordTypeInfosByName());
            }

            Map<String, Schema.RecordTypeInfo> recTypeInfos = sObjectRecordTypes.get(r.getName());
            Schema.RecordTypeInfo recTypeInfo = recTypeInfos.get(recordTypeName);
            if (recTypeInfo != null)
                return recTypeInfo.getRecordTypeId();
        }

        throw new RecordTypeNotFoundException('RecordType \'' + recordTypeName + '\' was not found for SObjectType \'' + so + '\'.');
    }
}