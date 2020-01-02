//Naresh Kumar	07/02/2017				
global without sharing class PartnerPortalUtil_WS {
    //Updates record type of the given opportunity
    webservice static String updateOpportunityRecordType(Id oppId, String strRecordType){
        //Querying record type
        List<RecordType> list_OfRecordType = [SELECT ID FROM RecordType WHERE DeveloperName =: strRecordType AND SObjectType = 'Opportunity'];
        if(!list_OfRecordType.isEmpty()){
            Opportunity objOpp = new Opportunity(id = oppId, RecordTypeId = list_OfRecordType[0].id);
            update objOpp;
            return 'OK';
        }
        return 'Failed';        
    }
}