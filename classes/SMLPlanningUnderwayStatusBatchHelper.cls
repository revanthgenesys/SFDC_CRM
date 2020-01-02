//Naresh Kumar    10/03/2016
public without sharing class SMLPlanningUnderwayStatusBatchHelper{
        
        public static void resetPlanningUnderwayStatus(List<SML_Data__c> smlData){
            Date date180Days = System.today().addDays(-180);
            Map<Id, Id> mapOfSMLDataIdVsAccountId = new Map<Id, Id>();
            //Looping over each data set
            for(SML_Data__c eachSMLData : smlData){
                if(eachSMLData.Planning_Underway_Date__c < date180Days){
                    mapOfSMLDataIdVsAccountId.put(eachSMLData.id, eachSMLData.Account__c);
                }                   
            }   
            if(mapOfSMLDataIdVsAccountId.keyset().isEmpty())
                return;
            List<Account_Trends__c> accountTrends = [SELECT id, SML_Data__c FROM Account_Trends__c WHERE SML_Data__c IN : mapOfSMLDataIdVsAccountId.keyset()
                AND CreatedDate >=: date180Days];
            Set<Id> setOfSMLDataIdsWithAccountTrend = new Set<Id>();
            for(Account_Trends__c eachAccountTrend : accountTrends){
                setOfSMLDataIdsWithAccountTrend.add(eachAccountTrend.SML_Data__c);
            }
            
            Set<Id> setOfAccountIdsWithGameAttachments = new Set<Id>();
            List<SML_Account_Attachments__c> gameAttachments = [SELECT id, Account__c FROM SML_Account_Attachments__c WHERE Account__c IN : mapOfSMLDataIdVsAccountId.values()
                AND CreatedDate >=: date180Days];
            for(SML_Account_Attachments__c eachAtt : gameAttachments){
                setOfAccountIdsWithGameAttachments.add(eachAtt.Account__c); 
            }
            
            //List to be updated
            List<SML_Data__c> smlDataToBeUpdated = new List<SML_Data__c>();
            
            for(Id eachSMLDataId : mapOfSMLDataIdVsAccountId.keyset()){
                Id accountId = mapOfSMLDataIdVsAccountId.get(eachSMLDataId);
                if(!setOfSMLDataIdsWithAccountTrend.contains(eachSMLDataId) && accountId != null && 
                    !setOfAccountIdsWithGameAttachments.contains(mapOfSMLDataIdVsAccountId.get(eachSMLDataId))){
                    SML_Data__c newSMLData = new SML_Data__c(id = eachSMLDataId);
                    newSMLData.Status__c = SMLHelper.WHITESPACE;
                    newSMLData.Comments__c = 'Business rule change';
                    smlDataToBeUpdated.add(newSMLData);
                }
            }
            
            if(!smlDataToBeUpdated.isEmpty())
                update smlDataToBeUpdated;
        }
}