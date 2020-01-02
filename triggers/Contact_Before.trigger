trigger Contact_Before on Contact (before insert, before update, before delete) {
   if(Util.Bypass_Trigger_Chk || Bypass_Triggers__c.getInstance(UserInfo.getUserId()).All__c)
      return;

    if(trigger.isInsert){
        // populate contacts Account based on their email's domain address
        ContactUtil.populateContactsAccountId(Trigger.new);
        Set<Id> accountIds = new Set<Id>();
        for(Contact con : trigger.new){
            accountIds.add(con.AccountId);
        }
    }
    
    if(trigger.isUpdate){
        Set<Id> accountIds = new Set<Id>();
        for(Contact con : trigger.new){
            Contact oldCon = trigger.oldMap.get(con.Id);
            // if the contacts account is changed
            if(con.AccountId != oldCon.AccountId){
                accountIds.add(con.AccountId);
            } 
        }
        
        ContactUtil.createEmailDomains(Trigger.oldMap, Trigger.new);
        
        if(TriggerFlowManager.CONTACT_AFTER_ENABLE_PARTNER_PORTAL){
            EnableCustomerPortal.enablePartnerPortalForContacts(Trigger.new, Trigger.oldMap);
        }
        
        ContactUtil.validateTrainingAccess(Trigger.new, Trigger.oldMap);
        
         /************Check Main Contact for PureSuccess*************/
        //Added on 04/25/2018
        //It would not work in Bulk Upload
        string sName = ContactUtil.CheckMainContact(Trigger.new, Trigger.old);
        if(sName != null && sName != '')
        {
          if(!Test.isRunningTest())
            Trigger.new[0].addError('PureSuccess Main Contact '+ sName +' is already exist.');
        }  
    }
    
    /// do not allow delete unless profile is System Administrator
    if(trigger.isDelete){
        /*List<String> listOfAdminProfiles = Label.Admin_Profiles.split(';');
        Integer admin = [SELECT count() FROM Profile p WHERE ID in 
                          (SELECT u.ProfileId From User u WHERE ID = :UserInfo.getUserId())
                         AND p.name IN ('System Administrator','Partner Administrator','Customer Care Data Admin))];
       
                          
        if ( admin == 0 ) {        
            for (Contact cont : Trigger.old) {
                cont.addError('Only System Aministrator can delete a Contact');
            } 
        }
        */
        //Anju May 11 : Only users or profiles with Delete contact custom permissions can delete contact.
        if(!FeatureManagement.checkPermission('Delete_Contact'))
        {
            for (Contact cont : Trigger.old) {
                cont.addError('Only Aministrator can delete a Contact');
            } 
        }
          
    }

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ContactUtil.BeforeInsert(Trigger.new);   
            
             // Added By: Ashish (07/20/2018)
            // Desc: To populate the offering type from account at the time of contact creation
            system.debug('#Enter Contact Trigger');
            ContactUtil.populateOfferingTypeOnContact(trigger.new);         
        }
        if(Trigger.isDelete){            
            ContactUtil.BeforeDelete(Trigger.old,Trigger.oldMap);            
        }
        
        //Sep 8 - Anju - Update Contact Mailing Country, city and state from custom fields starts
        if(Trigger.isInsert || Trigger.isupdate){
            ContactUtil.UpdateMailingAddress(Trigger.new);
        }
        //Sep 8 - Anju - Update Contact Mailing Country, city and state from custom fields ends
    }
    
    
   
    
    
}