/*
Naresh Kumar    05/29/2013
*/
public with sharing class ImportantScoreHandler {
    public final static String GENESYS_ESCALATION_CASE = 'Genesys_Escalation_Case';
    public static void enableIsOutOfMaintainenceFlagOnCases(List<ServiceContract> newList, Map<Id, ServiceContract> oldMap){
        Set<Id> accIds = new Set<Id>();     
        for(ServiceContract eachSC : newList){
            if(eachSC.Status == 'Expired' && oldMap.get(eachSC.id).Status != eachSC.Status){
                accIds.add(eachSC.End_User_Name__c);                
            }
        }
        List<ServiceContract> serviceContracts = [SELECT id, End_User_Name__c FROM ServiceContract WHERE End_User_Name__c IN : accIds AND Status != 'Expired'];
        for(ServiceContract eachSC : serviceContracts){         
            accIds.remove(eachSC.End_User_Name__c);
        }
        List<Case> cases = [SELECT Is_out_of_maintenance__c FROM Case WHERE End_User_Account__c IN : accIds AND Is_out_of_maintenance__c = false];
        for(Case eachCase : cases){
            eachCase.Is_out_of_maintenance__c = true;
        }
        if(!cases.isEmpty()){
            Database.SaveResult[] result = Database.update(cases, false);
        }
        TriggerFlowManager.SERVICECONTRACT_AFTER_IMPORTANT_SCORE_UPDATE = false;
        disableIsOutOfMaintainenceFlagOnCases(newList, oldMap);
    }
    
    private static void disableIsOutOfMaintainenceFlagOnCases(List<ServiceContract> newList, Map<Id, ServiceContract> oldMap){
        Set<Id> accIds = new Set<Id>();     
        for(ServiceContract eachSC : newList){
            if(oldMap.get(eachSC.id).Status == 'Expired' && oldMap.get(eachSC.id).Status != eachSC.Status && eachSC.End_User_Name__c != null){
                accIds.add(eachSC.End_User_Name__c);                
            }
        }
        List<Case> cases = [SELECT Is_out_of_maintenance__c FROM Case WHERE End_User_Account__c IN : accIds AND Is_out_of_maintenance__c = true];
        for(Case eachCase : cases){
            eachCase.Is_out_of_maintenance__c = false;
        }
        if(!cases.isEmpty()){
            Database.SaveResult[] result = Database.update(cases, false);
        }       
    }
    
    public static void updateIsOpenEscalationOnAccount(Map<Id, Case> newMap, Map<Id, Case> oldMap, Boolean isInsert){
        Map<Id, Case> mapESCCasesMap = new Map<Id, Case>();
        List<Case> cases = [SELECT Status, End_User_Account__c, RecordType.DeveloperName FROM Case WHERE id IN : newMap.keyset()];
        for(Case eachCase : cases){
            if(eachCase.RecordType.DeveloperName == GENESYS_ESCALATION_CASE)
                mapESCCasesMap.put(eachCase.id, eachCase);
        }
        Set<Id> accIds = new Set<Id>();
        Set<Id> accIdToDisableFlag = new Set<Id>();
        for(Case eachCase : mapESCCasesMap.values()){
            if(isInsert || eachCase.End_User_Account__c != oldMap.get(eachCase.id).End_User_Account__c || (eachCase.Status != 'Closed' && eachCase.Status != oldMap.get(eachCase.id).Status)){
                accIds.add(eachCase.End_User_Account__c);
            }
            if(eachCase.Status == 'Closed' && eachCase.Status != oldMap.get(eachCase.id).Status)
                accIdToDisableFlag.add(eachCase.End_User_Account__c);
        }
        
        List<Account> accs = [SELECT Is_Open_Escalations__c FROM Account WHERE id IN : accIds];
        for(Account eachAccount : accs){
            eachAccount.Is_Open_Escalations__c = true;
            if(isInsert)
                eachAccount.Escalation_Case_Date__c = System.today();            
        }
        /*
        for(Case eachCase : [SELECT id, End_User_Account__c FROM Case WHERE RecordType.DeveloperName =: GENESYS_ESCALATION_CASE AND Status = 'Closed' AND End_User_Account__c IN : accIdToDisableFlag]){
            newMap.remove(eachCase.id); 
        }
        if(!accIdToDisableFlag.isEmpty() && !newMap.keyset().isEmpty()){
            for(Case eachCase : [SELECT End_User_Account__c FROM Case WHERE id IN : newMap.keyset()]){
                if(eachCase.End_User_Account__c != null){
                    Account acc = new Account(id = eachCase.End_User_Account__c);
                    acc.Is_Open_Escalations__c = false;
                    acc.Escalation_Case_Date__c = null;
                    accs.add(acc);
                }
            }
        }
        */      
        update accs;
        TriggerFlowManager.CASE_IMPORTSCORE_FIELD_UPDATES = false;
    }
}