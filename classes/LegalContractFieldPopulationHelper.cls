/************************************************************************************
Purpose : Helper class for the logic implementation of legal to Quote relationship.
Written By :  Naresh Kumar  12/11/2017
Test Classes :  LegalContractFieldPopulationHelperTest
*************************************************************************************/
public class LegalContractFieldPopulationHelper {

    //Populates contract from quote
    public static Subscription__c populateContractFromQuote(String quoteId, Subscription__c objSubscription){
        String quoteQuery = getQuoteQuery();
        quoteQuery += ' FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        System.debug('NKC debug quoteQuery [' + quoteQuery + ']');
        BigMachines__Quote__c objQuote = (BigMachines__Quote__c)Database.query(quoteQuery);
        objSubscription = populateContract(objQuote, objSubscription, 'Quote');
        return objSubscription;
    }
    
    //Populates contract from opportunity
    public static Subscription__c populateContractFromOpportunity(String oppId, Subscription__c objSubscription){
        String oppQuery = getOpportunityQuery();
        oppQuery += ' FROM Opportunity WHERE id = \'' + oppId + '\'';
        Opportunity objOpp = (Opportunity)Database.query(oppQuery);
        objSubscription = populateContract(objOpp, objSubscription, 'Opportunity');
        return objSubscription;    
    }   
    
    //Populates contract from opportunity
    public static Subscription__c populateContractFromAccount(String accId, Subscription__c objSubscription){
        String accountQuery = getAccountQuery();
        accountQuery += ' FROM Account WHERE id = \'' + accId + '\'';
        Account objAcc = (Account)Database.query(accountQuery);
        objSubscription = populateContract(objAcc, objSubscription, 'Account');
        return objSubscription;    
    }
    
    private static Subscription__c populateContract(SObject objSourceObject, 
                                         Subscription__c objSubscription, String sourceObjectType){
        //Getting all custom setting records for applicable product
        List<SubscriptionContractMapping__c> listOfMappings = [SELECT Field_Mapping__c FROM SubscriptionContractMapping__c WHERE Object__c =: sourceObjectType];                                                                                                  
        //Source object field map
        Map<String, Schema.SObjectField> mapOfFieldVsDetails;
        if(sourceObjectType == 'Opportunity'){
            mapOfFieldVsDetails = Schema.SObjectType.Opportunity.fields.getMap();            
        }
        else if(sourceObjectType == 'Quote') {                                                             
            mapOfFieldVsDetails = Schema.SObjectType.BigMachines__Quote__c.fields.getMap();                                             
        }
        else if(sourceObjectType == 'Account') {                                                             
            mapOfFieldVsDetails = Schema.SObjectType.Account.fields.getMap();                                             
        }
        //Looping over each record
        for(SubscriptionContractMapping__c eachMapping : listOfMappings){
            String mapFieldValue = eachMapping.Field_Mapping__c;
            String sourceField = eachMapping.Field_Mapping__c.split('=')[0];            
            String contractField = eachMapping.Field_Mapping__c.split('=')[1];
            objSubscription = mapFieldValue(mapOfFieldVsDetails, objSourceObject, objSubscription, sourceField, contractField);
         }
        
    /*
        else if(sourceObjectType == 'Quote') {                                                             
            Map<String, Schema.SObjectField> mapOfQuoteFieldVsDetails = Schema.SObjectType.BigMachines__Quote__c.fields.getMap();
            //Getting all custom setting records
            List<QuoteAndContractMapping__c> listOfQuoteFieldMapping = QuoteAndContractMapping__c.getall().values();  
            //Looping over each record
            for(QuoteAndContractMapping__c eachMapping : listOfQuoteFieldMapping){
                String mapFieldValue = eachMapping.Field_Mapping__c;
                String sourceField = eachMapping.Field_Mapping__c.split('=')[0];            
                String contractField = eachMapping.Field_Mapping__c.split('=')[1];
                objSubscription = mapFieldValue(mapOfQuoteFieldVsDetails, objSourceObject, objSubscription, sourceField, contractField);
            }
        }
        else if(sourceObjectType == 'Account') {                                                             
            Map<String, Schema.SObjectField> mapOfAccountFieldVsDetails = Schema.SObjectType.Account.fields.getMap();
            //Getting all custom setting records
            List<AccountAndContractMapping__c> listOfAccountFieldMapping = AccountAndContractMapping__c.getall().values();  
            //Looping over each record
            for(AccountAndContractMapping__c eachMapping : listOfAccountFieldMapping){
                String mapFieldValue = eachMapping.Field_Mapping__c;
                String sourceField = eachMapping.Field_Mapping__c.split('=')[0];            
                String contractField = eachMapping.Field_Mapping__c.split('=')[1];
                objSubscription = mapFieldValue(mapOfAccountFieldVsDetails, objSourceObject, objSubscription, sourceField, contractField);
            }
        }        
        */
        System.debug('NKC debug objSubscription [' + objSubscription + ']');
        return objSubscription;
    }
    
    private static Subscription__c mapFieldValue(Map<String, Schema.SObjectField> mapOfQuoteFieldVsDetails, 
        SObject objSourceObject, Subscription__c objSubscription, String sourceField, String contractField){
        Object sourceFieldValue;
        FieldDescribeWrapper fieldObj = getFieldWrapperPopulated(mapOfQuoteFieldVsDetails.get(sourceField));   
            
        if(fieldObj.fieldType == Schema.DisplayType.DATE){
            sourceFieldValue = (Date)objSourceObject.get(sourceField);
        }
        else if(fieldObj.fieldType ==Schema.DisplayType.DateTime){
            sourceFieldValue = (DateTime)objSourceObject.get(sourceField);
        }
        else if(fieldObj.fieldType ==Schema.DisplayType.CURRENCY || fieldObj.fieldType == Schema.DisplayType.Double
                || fieldObj.fieldType ==Schema.DisplayType.PERCENT ){
                sourceFieldValue = (Double)objSourceObject.get(sourceField);                    
        } 
        else if(fieldObj.fieldType == Schema.DisplayType.REFERENCE){
            sourceFieldValue = (Id)objSourceObject.get(sourceField);                    
        } 
        else if(fieldObj.fieldType == Schema.DisplayType.String || fieldObj.fieldType == Schema.DisplayType.Picklist 
                || fieldObj.fieldType == Schema.DisplayType.TEXTAREA || fieldObj.fieldType == Schema.DisplayType.Phone
                || fieldObj.fieldType == Schema.DisplayType.URL){
                sourceFieldValue = (String)objSourceObject.get(sourceField);
        }  
        else if(fieldObj.fieldType == Schema.DisplayType.Boolean ){
            sourceFieldValue = (Boolean)objSourceObject.get(sourceField);
        }            
        else if(fieldObj.fieldType == Schema.DisplayType.Id){
            sourceFieldValue = (Id)objSourceObject.get(sourceField);
        }
        else if (fieldObj.fieldType == Schema.DisplayType.EMAIL){
            sourceFieldValue = (String)(objSourceObject.get(sourceField));
        }
        else if (fieldObj.fieldType == Schema.DisplayType.INTEGER){
            sourceFieldValue = (Integer)(objSourceObject.get(sourceField));
        }            
        objSubscription.put(contractField, sourceFieldValue);
        return objSubscription;
    }
    
    private static String getQuoteQuery(){
        String query = 'SELECT X18_Digit_ID__c ';
        //Getting all custom setting records
        List<QuoteAndContractMapping__c> listOfQuoteFieldMapping = QuoteAndContractMapping__c.getall().values();
        //Looping over each record
        for(QuoteAndContractMapping__c eachMapping : listOfQuoteFieldMapping){
            String mapFieldValue = eachMapping.Field_Mapping__c;
            //Fetching quote object field name from mapping
            query += ', ' + mapFieldValue.split('=')[0];
        }
        return query;
    }
    
    private static String getOpportunityQuery(){
        String query = 'SELECT BPWarning__c';
        //Getting all custom setting records
        List<OpportunityAndContractMapping__c> listOfOppFieldMapping = OpportunityAndContractMapping__c.getall().values();
        //Looping over each record
        for(OpportunityAndContractMapping__c eachMapping : listOfOppFieldMapping){
            String mapFieldValue = eachMapping.Field_Mapping__c;
            //Fetching quote object field name from mapping
            query += ', ' + mapFieldValue.split('=')[0];
        }
        return query;
    }
    
    private static String getAccountQuery(){
        String query = 'SELECT Website';
        //Getting all custom setting records
        List<AccountAndContractMapping__c> listOfOppFieldMapping = AccountAndContractMapping__c.getall().values();
        //Looping over each record
        for(AccountAndContractMapping__c eachMapping : listOfOppFieldMapping){
            String mapFieldValue = eachMapping.Field_Mapping__c;
            //Fetching quote object field name from mapping
            query += ', ' + mapFieldValue.split('=')[0];
        }
        return query;
    }    
    
    private static FieldDescribeWrapper getFieldWrapperPopulated(Schema.SObjectField field){    
        Schema.DescribeFieldResult fieldDesc = field.getDescribe();     
        FieldDescribeWrapper fieldDescribeObj = new FieldDescribeWrapper(); 
        fieldDescribeObj.fieldName = fieldDesc.getName() ;
        fieldDescribeObj.fieldLabel = fieldDesc.getLabel(); 
        fieldDescribeObj.fieldType =  fieldDesc.getType();
        fieldDescribeObj.isEditable =  fieldDesc.isUpdateable();    
        return fieldDescribeObj;
    }
    
    private class FieldDescribeWrapper {
        public String fieldName {get;set;}
        public String fieldLabel {get;set;}
        public Schema.Displaytype fieldType {get;set;}
        public boolean isEditable {get;set;}
    }
}