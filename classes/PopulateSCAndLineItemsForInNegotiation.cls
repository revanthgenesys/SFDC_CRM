/*
    07/17/2013  Naresh Kumar
*/
public with sharing class PopulateSCAndLineItemsForInNegotiation {

    public static void populateSCAndLineItems(Map<Id, ServiceContract> newMap, Map<Id, ServiceContract> oldMap){
         //Naresh Kumar	06/26/2018	Returning from function as this function is not doing anything. Update is already commneted out.
        return;
        /*
        Set<Id> scIds = new Set<Id>();
        List<ServiceContract> scToBeUpdated = new List<ServiceContract>();
        for(ServiceContract eachSC : newMap.values()){
            if(eachSC.Agreement_Status__c == 'In Negotiation' && eachSC.Agreement_Status__c != oldMap.get(eachSC.id).Agreement_Status__c)
                scIds.add(eachSC.id);           
        }
        Map<Id,ServiceContract> newMapSC = new Map<Id,ServiceContract>([SELECT StartDate, EndDate FROM ServiceContract WHERE id IN : scIds]);
        for(Id eachSCId : scIds){
            ServiceContract currentSC = newMapSC.get(eachSCId);
            //currentSC.StartDate = currentSC.EndDate;
            //currentSC.EndDate = currentSC.EndDate.addDays(90);
            scToBeUpdated.add(currentSC);
        }
        if(!scToBeUpdated.isEmpty()){
            //update scToBeUpdated;
            newMapSC = new Map<Id,ServiceContract>([SELECT StartDate, EndDate FROM ServiceContract WHERE id IN : scIds]);
            List<ContractLineItem> scLineItems = [SELECT ServiceContractId, Maintenance_Start_Date__c, Maintenance_End_Date__c, StartDate, EndDate FROM ContractLineItem WHERE ServiceContractId IN : scIds];
            for(ContractLineItem eachSCLineItem : scLineItems){
                //eachSCLineItem.Maintenance_Start_Date__c = newMapSC.get(eachSCLineItem.ServiceContractId).StartDate;
                //eachSCLineItem.Maintenance_End_Date__c = newMapSC.get(eachSCLineItem.ServiceContractId).EndDate;                
                //eachSCLineItem.StartDate = newMapSC.get(eachSCLineItem.ServiceContractId).StartDate;
                //eachSCLineItem.EndDate = newMapSC.get(eachSCLineItem.ServiceContractId).EndDate;    
            }
            if(!scLineItems.isEmpty()){
                //update scLineItems;
            }
        }
		*/
    }
}