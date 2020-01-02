/*
DefaultQuoteServiceContracts
04/16/2013    Naresh Kumar    Original for Task/Story #   
Description : Class to create a default record in Quote_Service_Contracts__c object
*/
public class DefaultQuoteServiceContracts{
    public static void populateLookupsOnInsert(List<BigMachines__Quote__c> newQuoteList){
        populateLookupsOnUpdate(newQuoteList, null, true);
    }
    public static void populateLookupsOnUpdate(List<BigMachines__Quote__c> newQuoteList, Map<Id,BigMachines__Quote__c> oldMap){
        populateLookupsOnUpdate(newQuoteList, oldMap, false);
    }
    public static void populateLookupsOnUpdate(List<BigMachines__Quote__c> newQuoteList, Map<Id,BigMachines__Quote__c> oldMap, Boolean isInsert){
        Set<String> setCompNames = new Set<String>();
        Map<String,String> mapAccNameVsAccId = new Map<String,String>(); 
        for(BigMachines__Quote__c eachQuote : newQuoteList){
            if(isInsert || eachQuote.End_User_Company_Name__c != oldMap.get(eachQuote.id).End_User_Company_Name__c){                
                setCompNames.add(eachQuote.End_User_Company_Name__c);                                
            }
            if(isInsert || eachQuote.Sold_To_Company_Name__c != oldMap.get(eachQuote.id).Sold_To_Company_Name__c){
                setCompNames.add(eachQuote.Sold_To_Company_Name__c);
            }
            if(isInsert || eachQuote.Support_Owner_Company_Name__c != oldMap.get(eachQuote.id).Support_Owner_Company_Name__c){
                setCompNames.add(eachQuote.Support_Owner_Company_Name__c);
            }
            if(isInsert || eachQuote.SI_Company_Name__c != oldMap.get(eachQuote.id).SI_Company_Name__c){
                setCompNames.add(eachQuote.SI_Company_Name__c);
            }
            if(isInsert || eachQuote.Bill_To_Company_Name__c != oldMap.get(eachQuote.id).Bill_To_Company_Name__c){
                setCompNames.add(eachQuote.Bill_To_Company_Name__c);
            }            
        }
        for(Account eachAcc : [SELECT id, Name FROM Account WHERE Name IN : setCompNames AND RecordType.DeveloperName NOT IN ('Group_Account_Customer','Party_Account')]){
            mapAccNameVsAccId.put(eachAcc.Name, eachAcc.id);
        }
        List<BigMachines__Quote__c> recordsToBeUpdated = new List<BigMachines__Quote__c>();
        for(BigMachines__Quote__c eachQuote : newQuoteList){
            BigMachines__Quote__c recordToBeUpdated = new BigMachines__Quote__c(id = eachQuote.id);
            Boolean isRecordChanged = false;            
            if((isInsert || eachQuote.End_User_Company_Name__c != oldMap.get(eachQuote.id).End_User_Company_Name__c)
            && mapAccNameVsAccId.get(eachQuote.End_User_Company_Name__c) != null){
                recordToBeUpdated.End_User_ID__c = mapAccNameVsAccId.get(eachQuote.End_User_Company_Name__c);
                isRecordChanged = true;
            }
            if((isInsert || eachQuote.Sold_To_Company_Name__c != oldMap.get(eachQuote.id).Sold_To_Company_Name__c)
            && mapAccNameVsAccId.get(eachQuote.End_User_Company_Name__c) != null){
                recordToBeUpdated.Sold_To_Name__c = mapAccNameVsAccId.get(eachQuote.Sold_To_Company_Name__c);
                isRecordChanged = true;
            }
            if(isInsert || eachQuote.Support_Owner_Company_Name__c != oldMap.get(eachQuote.id).Support_Owner_Company_Name__c){
                recordToBeUpdated.Support_Owner__c = mapAccNameVsAccId.get(eachQuote.Support_Owner_Company_Name__c);
                isRecordChanged = true;
            }
            if(isInsert || eachQuote.SI_Company_Name__c != oldMap.get(eachQuote.id).SI_Company_Name__c){
                recordToBeUpdated.System_Integrator__c = mapAccNameVsAccId.get(eachQuote.SI_Company_Name__c);
                isRecordChanged = true;
            }
            if(isInsert || eachQuote.Bill_To_Company_Name__c != oldMap.get(eachQuote.id).Bill_To_Company_Name__c){
                recordToBeUpdated.Bill_To_Name__c = mapAccNameVsAccId.get(eachQuote.Bill_To_Company_Name__c);
                isRecordChanged = true;
            }            
            if(isRecordChanged)
                recordsToBeUpdated.add(recordToBeUpdated);                
        }              
        if(!recordsToBeUpdated.isEmpty()){          
            TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER = true;
            Database.SaveResult[] result = Database.update(recordsToBeUpdated, false);
            Integer counter = 0;
            //Iterate through the Save Results
            for(Database.SaveResult sr:result){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];        
                    recordsToBeUpdated[counter].addError(err.getMessage());
                }
                counter ++;
            }
        }
    }
    public static void addDefaultQuoteServiceContractsRecord(List<BigMachines__Quote__c> newQuoteList){        
        Set<String> oppIds = new Set<String>();
        Map<String,String> mapOppIdVsQuoteId = new Map<String,String>();
        Map<String,String> mapOppIdVsServiceContractId = new Map<String,String>(); 
        Map<String,Integer> mapQuoteIVsQSCRecords = new Map<String,Integer>(); 
        Set<String> quoteIds = new Set<String>();              
        for(BigMachines__Quote__c eachQuote : newQuoteList){
            oppIds.add(eachQuote.BigMachines__Opportunity__c);
            mapOppIdVsQuoteId.put(eachQuote.id, eachQuote.BigMachines__Opportunity__c);
            quoteIds.add(eachQuote.id);
        }
        for(Quote_Service_Contracts__c eachRecord : [SELECT id, Quote__c FROM Quote_Service_Contracts__c WHERE Quote__c in : quoteIds]){
            if(mapQuoteIVsQSCRecords.get(eachRecord.Quote__c) == null)
               mapQuoteIVsQSCRecords.put(eachRecord.Quote__c, 1);
            else
               mapQuoteIVsQSCRecords.put(eachRecord.Quote__c, mapQuoteIVsQSCRecords.get(eachRecord.Quote__c) + 1);
        }
        
        for(ServiceContract eachSC : [SELECT id, Renewal_Opportunity__c  FROM ServiceContract WHERE Renewal_Opportunity__c in : oppIds]){
            mapOppIdVsServiceContractId.put(eachSC.Renewal_Opportunity__c, eachSC.id);    
        }
        List<Quote_Service_Contracts__c> newRecordsToBeInserted = new List<Quote_Service_Contracts__c>();
        for(BigMachines__Quote__c eachQuote : newQuoteList){
            if(mapQuoteIVsQSCRecords.get(eachQuote.id) > 1)
                continue;
            Quote_Service_Contracts__c newRecord = new Quote_Service_Contracts__c();
            newRecord.Quote__c = eachQuote.id;
            newRecord.Service_Contract__c = mapOppIdVsServiceContractId.get(mapOppIdVsQuoteId.get(eachQuote.id));
            newRecordsToBeInserted.add(newRecord);
        }        
        if(!newRecordsToBeInserted.isEmpty()){
            Database.SaveResult[] result = Database.insert(newRecordsToBeInserted, false);
            Integer counter = 0;
            //Iterate through the Save Results
            for(Database.SaveResult sr:result){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];        
                    newRecordsToBeInserted[counter].addError(err.getMessage());
                }
                counter ++;
            }
        }        
    }
}