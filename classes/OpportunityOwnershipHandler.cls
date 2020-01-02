/************************************************************************************
Purpose :  Updates partner opportunity's owner.
Written By :  Naresh Kumar
Test Classes : OpportunityOwnershipHandlerTest  
*************************************************************************************/
public class OpportunityOwnershipHandler {

    public static void updateOpportunityOwner(List<Opportunity> listOfOpportunity, Map<Id, Opportunity> oldOppMap){        
        //Set of end user account ids
        Set<Id> setOfEndUserAccountIds = new Set<Id>();
        //Contains list of partner opportunities
        List<Opportunity> listOfPartnerOpportunity = new List<Opportunity>();
        Id genRecordTypeId;
        Global_Setting__c obj = Global_Setting__c.getInstance('GEN - Opportunity Record Type');
        System.debug('NKC debug obj [' + obj + ']');
        if(obj != null)
			genRecordTypeId = obj.ID__c;
        //Looping over each Opportunity
        for(Opportunity eachOpp : listOfOpportunity){
            //Whether it's partner opportunity or not
            if(eachOpp.AccountId != null && eachOpp.RecordTypeId == genRecordTypeId && 
               (eachOpp.Partner_Opportunity_Source__c == 'Partner Registered Opportunity' || eachOpp.Partner_Opportunity_Source__c == 'Partner Sourced not registered') 
               && (oldOppMap == null || eachOpp.Partner_Opportunity_Source__c != oldOppMap.get(eachOpp.id).Partner_Opportunity_Source__c)){
           		setOfEndUserAccountIds.add(eachOpp.AccountId);
                listOfPartnerOpportunity.add(eachOpp);
        	}
        }        
        //Return if there is no partner opportunity
        if(setOfEndUserAccountIds.isEmpty())
            return;
        System.debug('NKC debug setOfEndUserAccountIds [' + setOfEndUserAccountIds + ']');
        System.debug('NKC debug listOfPartnerOpportunity [' + listOfPartnerOpportunity + ']');
        //Holds map of end user account record
        Map<Id, Account> mapOfAccountIdVsAccount = new Map<Id, Account>([SELECT OwnerId FROM Account WHERE id IN :setOfEndUserAccountIds]);
        System.debug('NKC debug mapOfAccountIdVsAccount [' + mapOfAccountIdVsAccount + ']');
        //Looping over list of partner opps
        for(Opportunity eachOpp : listOfPartnerOpportunity){
            if(mapOfAccountIdVsAccount.containsKey(eachOpp.AccountId) && (oldOppMap == null || eachOpp.OwnerId == oldOppMap.get(eachOpp.id).OwnerId)){
                eachOpp.OwnerId = mapOfAccountIdVsAccount.get(eachOpp.AccountId).OwnerId;
                eachOpp.Opportunity_Owner__c = eachOpp.OwnerId;
                System.debug('NKC debug eachOpp.OwnerId [' + eachOpp.OwnerId + ']');
            }
        }
    }
}