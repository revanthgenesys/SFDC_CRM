trigger RelatedLicenseRequestTrigger_Main on Related_License_Request__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
    if (Util.Bypass_Trigger_Chk) return;
    
    // trigger to provide bi-directional relationship functionality. Updates are not allowed
    if ( Trigger.isBefore )  {
  	  if ( Trigger.isUpdate ) {
         Trigger.new[0].addError('You cannot modify this record. Please delete the existing and then add a new relationship.');
      }
    }
    
	if ( Trigger.isAfter) {
        if ( Trigger.isInsert ) {
            List<Related_License_Request__c> relToIns = new List<Related_License_Request__c>();           
            for ( Related_License_Request__c rlr : Trigger.new ) {
                List<Related_License_Request__c> recExist = [SELECT ID FROM Related_License_Request__c 
                                                             WHERE AFR_Prnt__c = :rlr.AFR_Rel__c AND AFR_Rel__c = :rlr.AFR_Prnt__c];
                if ( recExist.isEmpty() )
                    relToIns.add(new Related_License_Request__c(AFR_Prnt__c = rlr.AFR_Rel__c,
                                                                 AFR_Rel__c = rlr.AFR_Prnt__c ));                                        
            }
            if ( !relToIns.isEmpty()) {
                try {
                    insert relToIns;
                }
                catch(DMLException ex) {}
            }        
        }       
        if ( Trigger.isDelete ) {
            List<Related_License_Request__c> relToDelete = new List<Related_License_Request__c>();           
            for ( Related_License_Request__c rlr : Trigger.old ) {
                List<Related_License_Request__c> recExist = [SELECT ID FROM Related_License_Request__c 
                                                             WHERE AFR_Prnt__c = :rlr.AFR_Rel__c AND AFR_Rel__c = :rlr.AFR_Prnt__c];
                if ( !recExist.isEmpty() )
                   relToDelete.add(recExist[0]);                                                     
            }
            if ( !relToDelete.isEmpty()) {
                try {
                    delete relToDelete;
                }
                catch(DMLException ex) {}
            }        
        }
    }

}