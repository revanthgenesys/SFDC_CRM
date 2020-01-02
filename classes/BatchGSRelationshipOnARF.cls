/****************************************************************************
    Created by Priyank on 15 Nov 2018
    Description :- Building relationship between ARF and GS_Relationship__c.
    As discussed with JJ
****************************************************************************/

global class BatchGSRelationshipOnARF implements Database.Batchable<sObject>, Database.Stateful {
    
    global Map<String, String> map_GSNameARFOffering = new Map<String, String>{'PureCloud' => 'PureCloud', 'PureConnect Cloud' => 'PureConnect', 'PureEngage Cloud' => 'PureEngage', 'PureEnagae Cloud Outbound' => 'Outbound', 'Premier Edition' => 'Premier', 'Cloud Solution Partner (PPU)' => 'Cloud Solution Partner (PPU)'};
    global Map<String, String> map_ARFOfferingGSName = new Map<String, String>{'PureCloud' => 'PureCloud', 'PureConnect' => 'PureConnect Cloud', 'PureEngage' => 'PureEngage Cloud', 'Outbound' => 'PureEnagae Cloud Outbound', 'Premier' => 'Premier Edition', 'Cloud Solution Partner (PPU)' => 'Cloud Solution Partner (PPU)'};
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT GS_Relationship__c,Offering_Type__c,Account__c FROM Account_Revenue_Forecast__c WHERE GS_Relationship__c = \'\' AND Account__c != \'\' AND Offering_Type__c != \'\'');
        //return Database.getQueryLocator('SELECT GS_Relationship__c,Offering_Type__c,Account__c FROM Account_Revenue_Forecast__c WHERE GS_Relationship__c = \'\' AND (id= \'a8J4C000000Gu8b\' OR id= \'a8J4C000000Gu8g\')');//for testing.
    }
    global void execute(Database.BatchableContext bc, List<Account_Revenue_Forecast__c> records){
        Map<string,string> mapAccountOfferingIdGS = new Map<string,string>(); //Map of accountId and offering type
        Map<string,JBCXM__GSRelationship__c> mapAccountGSObj = new Map<string,JBCXM__GSRelationship__c>(); // Map of accountid and Gs Object.
        List<Account_Revenue_Forecast__c> arfList = new List<Account_Revenue_Forecast__c>(); // List of ARF for updation
        Map<string, List<string>> mapAccountIdOfferingAF = new Map<string, List<string>>(); // 
        
        
        for(Account_Revenue_Forecast__c arf : records){
            if(!mapAccountIdOfferingAF.containsKey(arf.Account__c)){
                mapAccountIdOfferingAF.put(arf.Account__c, new List<string>());
            }           
            if(map_ARFOfferingGSName.containsKey(arf.Offering_Type__c)){
                mapAccountIdOfferingAF.get(arf.Account__c).add(map_ARFOfferingGSName.get(arf.Offering_Type__c));
            }
        }
        List<JBCXM__GSRelationship__c> lstgsObjDatabase = new List<JBCXM__GSRelationship__c>([SELECT id,Name,JBCXM__Account__c,Offerings_Type__c 
                                                                                                FROM JBCXM__GSRelationship__c 
                                                                                                WHERE JBCXM__Account__c IN : mapAccountIdOfferingAF.KeySet()]); // AND Offerings_Type__c NAME IN : mapAccountIdOfferingAF.values()]);
        for(JBCXM__GSRelationship__c gsOBJ : lstgsObjDatabase){
            if(mapAccountIdOfferingAF.containsKey(gsOBJ.JBCXM__Account__c)){
                for(String offeringType : mapAccountIdOfferingAF.get(gsOBJ.JBCXM__Account__c)){
                    if(gsOBJ.Name == offeringType){
                        mapAccountOfferingIdGS.put(gsOBJ.JBCXM__Account__c,gsOBJ.Name);
                        mapAccountGSObj.put(gsOBJ.JBCXM__Account__c,gsOBJ);
                    }
                }
            }
        }
        
        for(Account_Revenue_Forecast__c arf : records){
            if(mapAccountOfferingIdGS.containsKey(arf.Account__c) && map_GSNameARFOffering.get(mapAccountOfferingIdGS.get(arf.Account__c)) == arf.Offering_Type__c){
                arf.GS_Relationship__c = mapAccountGSObj.get(arf.Account__c).id;
                arfList.add(arf);
            }
        }
        
        //updateing ARF records
        if(arfList.size()>0){
            update arfList;
        }
    }    
    global void finish(Database.BatchableContext bc){
        
    }    
}