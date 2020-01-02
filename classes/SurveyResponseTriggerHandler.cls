/***************************************************************************************************
* 
*  Class Name      :   SurveyResponseTriggerHandler
*  Description     :   This class is used to define the method for SurveyResponseTrigger.trigger.
*  Auther          :   R Systems
* 
****************************************************************************************************/
 
public with sharing class SurveyResponseTriggerHandler {
    
    /**
    *   Method Name :   beforeInsertUpdate()
    *   Description :   This method used to update the record type of Survey Respnse based on Survey Type
    *   Parameters  :   mapNewGSRelationship => Map of New inserted records.
    **/
    
    public static void beforeInsertUpdate(List<Survey_Response__c> lsttSurveyResponse,  Map<Id, Survey_Response__c> oldMapSurveyResponse){
       
        for(Survey_Response__c surveyResponse: lsttSurveyResponse){
            
            if(oldMapSurveyResponse == null){
                if(surveyResponse.Survey_Type__c == 'Transactional' && surveyResponse.Department__c == 'Customer Care'){
                    surveyResponse.RecordTypeId = getRecordTypeId('Transactional Customer Care', 'Survey_Response__c');
                }else if(surveyResponse.Survey_Type__c == 'Transactional' && surveyResponse.Department__c == 'PS'){
                    surveyResponse.RecordTypeId = getRecordTypeId('Transactional PS', 'Survey_Response__c');
                }else if(surveyResponse.Survey_Type__c == 'Partner'){
                    surveyResponse.RecordTypeId = getRecordTypeId('Partner', 'Survey_Response__c');
                }else if(surveyResponse.Survey_Type__c == 'Relationship'){
                    surveyResponse.RecordTypeId = getRecordTypeId('Relationship', 'Survey_Response__c');
                }
            }else{
                if(surveyResponse.Survey_Type__c != oldMapSurveyResponse.get(surveyResponse.Id).Survey_Type__c || surveyResponse.Department__c != oldMapSurveyResponse.get(surveyResponse.Id).Department__c){
                    if(surveyResponse.Survey_Type__c == 'Transactional' && surveyResponse.Department__c == 'Customer Care'){
                        surveyResponse.RecordTypeId = getRecordTypeId('Transactional Customer Care', 'Survey_Response__c');
                    }else if(surveyResponse.Survey_Type__c == 'Transactional' && surveyResponse.Department__c == 'PS'){
                        surveyResponse.RecordTypeId = getRecordTypeId('Transactional PS', 'Survey_Response__c');
                    }else if(surveyResponse.Survey_Type__c == 'Partner'){
                        surveyResponse.RecordTypeId = getRecordTypeId('Partner', 'Survey_Response__c');
                    }else if(surveyResponse.Survey_Type__c == 'Relationship'){
                        surveyResponse.RecordTypeId = getRecordTypeId('Relationship', 'Survey_Response__c');
                    }
                }
            }
        }
      
    }
    
    /**
    *   Method Name :   getRecordTypeId()
    *   Description :   This method used to get the record Type Id based on the Record Type Name 
    *   Parameters  :   recordTypeName => Record Type Name, sobj => Object Name
    **/
    
    public Static Id getRecordTypeId(String recordTypeName, String sobj){
        
        if(recordTypeName != null && sobj != null){
            
            Id SoureAccountRecordTypeId = Schema.getGlobalDescribe().get(sobj).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            
            return SoureAccountRecordTypeId;
        }
        
        return null;
    }
    
}