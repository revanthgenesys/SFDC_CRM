//Naresh Kumar 04/17/2014
public with sharing class DynamicFieldMappingHelper {
    public static final String QUOTE_TO_ORDER = 'QUOTE - ORDER';
    public static final String QUOTE_LINEITEMS_TO_ORDER_LINE_ITEMS = 'QUOTE LINE ITEMS - ORDER LINE ITEMS'; 
    public static final String ORDER_TO_SERVICE_CONTRACT = 'ORDER - SERVICE CONTRACT';
    public static final String ORDER_LINEITEMS_TO_CONTRACT_LINEITEMS = 'ORDER LINE ITEMS - SERVICE CONTRACT LINE ITEM';    
    
    public static Map<String ,FieldDescribeWrapper> sourceFieldMap;
    public static SObject getPopulatedSObjectRecord(SObject sourceSObject, SObject targetSObject, String mappingTypeName, String recordName){
    	System.debug('NKC debug mappingTypeName ['+mappingTypeName+'] ');
    	sourceFieldMap = populateSourceObjectFieldMap(mappingTypeName);        
        Map<String,String> quoteOrderMapping = getQuoteOrderMapping(mappingTypeName, recordName);
        System.debug('NKC debug quoteOrderMapping ['+quoteOrderMapping+']');
        for(String eachOrderField : quoteOrderMapping.keySet()) {                               
            String value = quoteOrderMapping.get(eachOrderField);
            String quoteField = value != null ? value.trim() : '';
            if(quoteField.startsWith('*')) {                
            	System.debug('NKC debug quoteField.substring(1,quoteField.length()) ['+quoteField.substring(1,quoteField.length())+']');
                targetSObject.put(eachOrderField,  quoteField.substring(1,quoteField.length()));
            }
            else{ 
                Object oppFieldValue = null;
                FieldDescribeWrapper fieldObj = getFieldData(quoteField);             
                if(fieldObj.fieldType == Schema.DisplayType.DATE){
                    oppFieldValue = (Date)sourceSObject.get(quoteField);
                }
                else if(fieldObj.fieldType ==Schema.DisplayType.DateTime){
                    oppFieldValue = (DateTime)sourceSObject.get(quoteField);
                }
                else if(fieldObj.fieldType ==Schema.DisplayType.CURRENCY || fieldObj.fieldType == Schema.DisplayType.Double
                    || fieldObj.fieldType ==Schema.DisplayType.PERCENT ){
                    oppFieldValue = (Double)sourceSObject.get(quoteField);
                    
                } else if(fieldObj.fieldType == Schema.DisplayType.REFERENCE){
                    oppFieldValue = (Id)sourceSObject.get(quoteField);
                    
                } else if(fieldObj.fieldType == Schema.DisplayType.String || fieldObj.fieldType == Schema.DisplayType.Picklist 
                    || fieldObj.fieldType == Schema.DisplayType.TEXTAREA || fieldObj.fieldType == Schema.DisplayType.Phone
                    || fieldObj.fieldType == Schema.DisplayType.URL){
                    oppFieldValue = (String)sourceSObject.get(quoteField);
                }  
                else if(fieldObj.fieldType == Schema.DisplayType.Boolean ){
                    oppFieldValue = (Boolean)sourceSObject.get(quoteField);
                    }            
                else if(fieldObj.fieldType == Schema.DisplayType.Id){
                    oppFieldValue = (Id)sourceSObject.get(quoteField);
                }
                else if (fieldObj.fieldType == Schema.DisplayType.EMAIL){
                    oppFieldValue = (String)(sourceSObject.get(quoteField));
                }
                else if (fieldObj.fieldType == Schema.DisplayType.INTEGER){
                    oppFieldValue = (Integer)(sourceSObject.get(quoteField));
                }
                targetSObject.put(eachOrderField,  oppFieldValue);
            }
        }   
        return targetSObject;
    }
    
    public static Map<String ,FieldDescribeWrapper> populateSourceObjectFieldMap(String mappingType){
        Map<String ,FieldDescribeWrapper> sourceFieldMap1 = new Map<String ,FieldDescribeWrapper>();   
        Map<String, Schema.SObjectField> fieldMap;
        if(mappingType == QUOTE_TO_ORDER)
            fieldMap = Schema.SObjectType.BigMachines__Quote__c.fields.getMap();
        else if(mappingType == QUOTE_LINEITEMS_TO_ORDER_LINE_ITEMS)
            fieldMap = Schema.SObjectType.BigMachines__Quote_Product__c.fields.getMap();  
        else if(mappingType == ORDER_TO_SERVICE_CONTRACT)
            fieldMap = Schema.SObjectType.Order__c.fields.getMap();  
        else if(mappingType == ORDER_LINEITEMS_TO_CONTRACT_LINEITEMS)
            fieldMap = Schema.SObjectType.Order_Line_Item__c.fields.getMap();            
        System.debug('NKC debug fieldMap ['+fieldMap+'] ');
        System.debug('NKC debug mappingType ['+mappingType+'] ');          
        
        for(String nextField :fieldMap.keySet()){  
            Schema.SObjectField field = fieldMap.get(nextField);                                                    
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();     
            FieldDescribeWrapper fieldDescribeObj = new FieldDescribeWrapper(); 
            fieldDescribeObj.fieldName = nextField ;
            fieldDescribeObj.fieldLabel = fieldDesc.getLabel(); 
            fieldDescribeObj.fieldType =  fieldDesc.getType();
            fieldDescribeObj.isEditable =  fieldDesc.isUpdateable();
            sourceFieldMap1.put(nextField,fieldDescribeObj);      
        }     
        return sourceFieldMap1;
    }
    
    public static Map<String, String> getQuoteOrderMapping(String mappingType, String recordName) {
        Map<String,String> dealRegOppportunityMapping = new Map<String,String>();
        Map<String,String> dealRegOpportunityCustomSettingMap = getQuoteOrderCustomMapping(mappingType, recordName);
        List<String> customSettingMappingList = dealRegOpportunityCustomSettingMap.values();
        for(String customSettingMapping : customSettingMappingList) {
            parseAndSetMapping(customSettingMapping,dealRegOppportunityMapping);
        }
        return dealRegOppportunityMapping;
    }
    public static Map<String,String> getQuoteOrderCustomMapping(String mappingType, String recordName) {
        Map<String, String> quoteOrderFieldValueMap = new Map<String, String>();        
        Map<String, Schema.SObjectField> fieldMap;
        if(mappingType == QUOTE_TO_ORDER){
            QuoteOrderFieldMappings__c confObj = QuoteOrderFieldMappings__c.getInstance(recordName);
            fieldMap = Schema.SObjectType.QuoteOrderFieldMappings__c.fields.getMap();
            for(String fieldName : fieldMap.keySet()) {
	            System.debug(' fieldName  ' +  fieldName);
	            if(fieldName != null && fieldName.trim() != '' && fieldName.endsWith('__c')) {
	                String fieldMapping = (String)confObj.get(fieldName);
	                System.debug(' fieldMapping  ' + fieldMapping);
	                if(fieldMapping != null && fieldMapping.trim() !='' ) {
	                    quoteOrderFieldValueMap.put(fieldName.trim(), fieldMapping.trim());   
	                }
	            }
        	} 
        }
        else if (mappingType == QUOTE_LINEITEMS_TO_ORDER_LINE_ITEMS){        	
        	QuoteLineItemsToOrderLineItemsMapping__c confObj = QuoteLineItemsToOrderLineItemsMapping__c.getInstance(recordName);
            fieldMap = Schema.SObjectType.QuoteLineItemsToOrderLineItemsMapping__c.fields.getMap();
            for(String fieldName : fieldMap.keySet()) {
	            System.debug(' fieldName  ' +  fieldName);
	            if(fieldName != null && fieldName.trim() != '' && fieldName.endsWith('__c')) {
	                String fieldMapping = (String)confObj.get(fieldName);
	                System.debug(' fieldMapping  ' + fieldMapping);
	                if(fieldMapping != null && fieldMapping.trim() !='' ) {
	                    quoteOrderFieldValueMap.put(fieldName.trim(), fieldMapping.trim());   
	                }
	            }
        	} 
        }
        else if (mappingType == ORDER_TO_SERVICE_CONTRACT){        	
        	OrderToServiceContractMappings__c confObj = OrderToServiceContractMappings__c.getInstance(recordName);
            fieldMap = Schema.SObjectType.OrderToServiceContractMappings__c.fields.getMap();
            for(String fieldName : fieldMap.keySet()) {
	            System.debug(' fieldName  ' +  fieldName);
	            if(fieldName != null && fieldName.trim() != '' && fieldName.endsWith('__c')) {
	                String fieldMapping = (String)confObj.get(fieldName);
	                System.debug(' fieldMapping  ' + fieldMapping);
	                if(fieldMapping != null && fieldMapping.trim() !='' ) {
	                    quoteOrderFieldValueMap.put(fieldName.trim(), fieldMapping.trim());   
	                }
	            }
        	} 
        }
        else if (mappingType == ORDER_LINEITEMS_TO_CONTRACT_LINEITEMS){        	
        	OrderLineItemToSCLineItemMappings__c confObj = OrderLineItemToSCLineItemMappings__c.getInstance(recordName);
            fieldMap = Schema.SObjectType.OrderLineItemToSCLineItemMappings__c.fields.getMap();
            for(String fieldName : fieldMap.keySet()) {
	            System.debug(' fieldName  ' +  fieldName);
	            if(fieldName != null && fieldName.trim() != '' && fieldName.endsWith('__c')) {
	                String fieldMapping = (String)confObj.get(fieldName);
	                System.debug(' fieldMapping  ' + fieldMapping);
	                if(fieldMapping != null && fieldMapping.trim() !='' ) {
	                    quoteOrderFieldValueMap.put(fieldName.trim(), fieldMapping.trim());   
	                }
	            }
        	} 
        }              
        return quoteOrderFieldValueMap;
    }
    
    private static void parseAndSetMapping(String valueWithMapping, Map<String,String> fieldMapping ) {
        if(valueWithMapping == null || valueWithMapping.trim() == '') return;
        String[] mappings = valueWithMapping.split('=');
        if(isValidMapping(mappings)) {
            fieldMapping.put(mappings[0],mappings[1]);
        }
    }
    
    private static boolean isValidMapping(String[] mappings) {
        if(mappings == null || mappings.size() != 2) 
            return false;
        if(mappings[0] == null || mappings[0].trim() == '' || 
                mappings[1] == null || mappings[1].trim() == '' ) 
            return false;
        return true;        
    }
    
    public static FieldDescribeWrapper getFieldData(String fieldName){ 
        //Map<String ,FieldDescribeWrapper> sourceFieldMap1 = populateSourceObjectFieldMap();
        System.debug('NKC debug sourceFieldMap1 ['+sourceFieldMap+']');
        if(sourceFieldMap.get(fieldName.toLowerCase()) !=null){
            return sourceFieldMap.get(fieldName.toLowerCase());
        }
        else{ 
            System.debug('NKC debug FIELD NOT FOUND ['+fieldName.toLowerCase()+']');
            return null;
        }
    }
    /*
    public static String getQuery(Id recordId, String referenceFields, String objectName){
    	if(referenceFields == null)
    		referenceFields = '';    
        String queryAllFields = 'SELECT ' + referenceFields;
        if(objectName == 'BigMachines__Quote__c'){
            //Getting all the fields for the object, Not in mood of copy each field name manually.      
            Set<String> fieldSet = Schema.SObjectType.BigMachines__Quote__c.fields.getMap().keySet();
            for(String eachFieldName : fieldSet){
                queryAllFields += eachFieldName + ', ';
            }
            queryAllFields = queryAllFields.substring(0, queryAllFields.lastIndexOf(','));      
            queryAllFields += ' FROM BigMachines__Quote__c WHERE id = \'' + recordId + '\'';
        }        
        else if(objectName == 'BigMachines__Quote_Product__c'){
            //Getting all the fields for the object, Not in mood of copy each field name manually.      
            Set<String> fieldSet = Schema.SObjectType.BigMachines__Quote_Product__c.fields.getMap().keySet();
            for(String eachFieldName : fieldSet){
                queryAllFields += eachFieldName + ', ';
            }
            queryAllFields = queryAllFields.substring(0, queryAllFields.lastIndexOf(','));      
            queryAllFields += ' FROM BigMachines__Quote_Product__c WHERE id = \'' + recordId + '\'';
        }        
        return queryAllFields;
    }
    */
    
    public class FieldDescribeWrapper {
        public String fieldName {get;set;}
        public String fieldLabel {get;set;}
        public Schema.Displaytype fieldType {get;set;}
        public boolean isEditable {get;set;}
    }
}