//Naresh Kumar	Helper class for Partner Portal Prospect main trigger
public class PartnerPortalProspectTriggerHelper {
	//Populates AE from
    public static void populateAEFromSoldTo(List<partner_portal_prospect__c> newList){
    	Map<Id, Id> mapOfDealRegIdVsEndUserId = new Map<Id, Id>();
        //Looping over each map and populating map
        for(partner_portal_prospect__c eachRecord : newList){
            if(eachRecord.End_User_Account__c != null){
        		mapOfDealRegIdVsEndUserId.put(eachRecord.id, eachRecord.End_User_Account__c);
            }
        }
        Map<Id, Account> map_OfAccounts = new Map<Id, Account>([SELECT id, OwnerId FROM Account WHERE id IN: mapOfDealRegIdVsEndUserId.values()]);
        
        for(partner_portal_prospect__c eachRecord : newList){
            if(mapOfDealRegIdVsEndUserId.get(eachRecord.Id) != null)
            	eachRecord.Account_Executive_at_Genesys__c = map_OfAccounts.get(mapOfDealRegIdVsEndUserId.get(eachRecord.Id)).ownerId;
        }
    }
}