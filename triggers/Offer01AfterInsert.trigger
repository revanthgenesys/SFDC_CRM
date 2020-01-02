trigger Offer01AfterInsert on Offer__c (after insert) {
if(Util.Bypass_Trigger_Chk)return;
System.Debug('## Offer01 begin prepare');
// Create a list of old offers
List<Offer__c> ListOldOffer = new List<Offer__c>();

// Create a list of offer to update
List<Offer__c> ListOfferToUpdate = new List<Offer__c>();

// Create a map of Offer ID and associated OQM ID 
Map<id,String> Offer01MapOfferId =new Map<Id,String>();

if(!Trigger.New.isEmpty()){
    
    // Fetch Offer record inserted
    for (Integer i = 0; i < Trigger.New.size(); i++) {
        
        // Add modified OQM to Map Offer - OQM
           Offer01MapOfferID.put(Trigger.new[i].Id,Trigger.new[i].OQMName__c);
    }
    
    // Select associated Offers linked to the same OQM
    ListOldOffer = [SELECT id,Active_Offer1__c,OQMName__c
                    FROM Offer__c
                    WHERE id NOT IN: Trigger.New 
                    AND OQMName__c IN: Offer01MapOfferID.values()];
    
    // Fetch Offer List to check which one need to be update
    for(Offer__c offer : ListOldOffer)
    {
        If(offer.Active_Offer1__c == Config.ACTIVE){
             offer.Active_Offer1__c = Config.INACTIVE;
             ListOfferToUpdate.add(offer);
        }
    }   
    
    //Update Offer if List is not empty
    if(!ListOfferToUpdate.isEmpty())
        Update ListOfferToUpdate;
}
System.Debug('## Offer01 end');
}