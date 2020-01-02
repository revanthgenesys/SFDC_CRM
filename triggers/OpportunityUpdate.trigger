trigger OpportunityUpdate on Opportunity (before update, after update) 
{
	if(Util.Bypass_Trigger_Chk)
    	return;
    
  	if(Trigger.isupdate && Trigger.isafter){
    	for(Opportunity opp : Trigger.new){
      		// PS RevPro POB Type
      		// Added by A. Haun
      		// If the Opp Project Type changes we need to review the
      		// Opportunity Products and update their POB Type value. 
      		//Opportunity oRec = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id = :opp.Id]; - Commented by Rony Joseph - July 30 2019.Replaced by Formula field

      		if(opp.Opportunity_RecordType_DeveloperName__c == 'Professional_Services' && (opp.ProjectType__c != Trigger.oldMap.get(opp.Id).ProjectType__c)){
        		System.debug('*** Opportunityupdate: opp is PS with updated Project Type, so update POB Types');
        		OpportunityProductHelper helper = new OpportunityProductHelper();
        		helper.UpdateProductPOBTypes(opp.Id, opp.ProjectType__c);
      		}
    	}
  	}

    // INC0305051
	if(Trigger.isupdate && Trigger.isBefore){
    	for(Opportunity opp : Trigger.new){
            if(Trigger.OldMap.get(opp.Id).Partner_Opportunity_Registration__c != NULL && opp.Partner_Opportunity_Registration__c != NULL && opp.Partner_Opportunity_Registration__c != Trigger.OldMap.get(opp.Id).Partner_Opportunity_Registration__c){
                Partner_Portal_Prospect__c relatedOpp = [SELECT id, Opportunity__c FROM Partner_Portal_Prospect__c WHERE Id = :opp.Partner_Opportunity_Registration__c];
                if(relatedOpp.Opportunity__c != NULL){
                    opp.addError('Selected Deal Registration is already associated with a different Opportunity.');		
                }
            }
        }
    }
}