trigger trgOpportunityConvert on partner_portal_prospect__c (before insert, before update, after update) {
    try{
        if(Util.Bypass_Trigger_Chk) 
          return;
        
        //Added by Rsystem on 07/24/2017 to assign Regional Channel Lead from custom setting <start>
        set<Id> set_OppIds= new set<Id>();
        set<string> set_UserName= new set<string>();
        map<id, string> map_opp= new map<id, string>(); 
        map<string,Id> map_userInfo = new map<string, Id>(); 
          
        if((trigger.isInsert || trigger.isUpdate)&& trigger.isBefore){
            for(Partner_Rebate_Regional_Channel_Lead__c customsetting: Partner_Rebate_Regional_Channel_Lead__c.getall().values())
                set_UserName.add(customsetting.User_Name__c);
            for(User objUser : [SELECT UserName,Id FROM User WHERE UserName in : set_UserName])
                map_userInfo.put(objUser.UserName,objUser.Id); 
            
            id strUserId;
            string strUserName =''; 
            for(partner_portal_prospect__c objPortal: trigger.new){
                //find the value in custom setting by opportunity region
                //strUserName = Partner_Rebate_Regional_Channel_Lead__c.getInstance(map_opp.get(objPortal.Opportunity__c)).User_Name__c;
                if(Partner_Rebate_Regional_Channel_Lead__c.getInstance(objPortal.Regions__c) != null)
                    strUserName = Partner_Rebate_Regional_Channel_Lead__c.getInstance(objPortal.Regions__c).User_Name__c;
                strUserId = map_userInfo.get(strUserName);
                objPortal.Regional_Channel_Lead__c = strUserId;
            } 
            
            //Navaneetha Added 03-07-2018
            if(trigger.isInsert){  
                //OfferingPlatformTypeUtil.updatePlatformAndOfferingType(trigger.new, null);  
                updateofferplatformtypehandler.updateOfferingPlatformType( trigger.new, null); 
            } else {
                //OfferingPlatformTypeUtil.updatePlatformAndOfferingType(trigger.new, trigger.oldMap);
                updateofferplatformtypehandler.updateOfferingPlatformType(trigger.new, trigger.oldMap);  
        }
      }
        //Added by Rsystem on 07/24/2017 to assign Regional Channel Lead from custom setting <end>    
        //if(trigger.isUpdate){
        if(trigger.isAfter){
           if(trigger.new[0].End_User_Account__c==null && trigger.new[0].Status__c != 'Rejected')
              trigger.new[0].addError('Please select End User Account.'); 
           else if(trigger.new[0].What_is_the_Expected_Close_Date__c==null)       
              trigger.new[0].addError('Please enter Expected Close Date.');  
           if(trigger.new[0].End_User_Account__c!=null){    
               Account endUserAccount = [SELECT RecordType.DeveloperName FROM Account WHERE id =: trigger.new[0].End_User_Account__c];
            if(endUserAccount.RecordType.DeveloperName != 'EMGCustomerRecordType' && endUserAccount.RecordType.DeveloperName != 'EMGProspectRecordType'){
                 if(!Test.isRunningTest())
                  trigger.new[0].addError('Please select a customer/prospect account as End User.');
                }
            } 
             
          //if the status become Approved then the partner portal registration should be automatically converted to opportunity
          	System.debug('trigger.new[0].Status__c = ' + trigger.new[0].Status__c);
            System.debug('trigger.old[0].Status__c = ' + trigger.old[0].Status__c);
            System.debug('trigger.new[0].Opportunity__c = ' + trigger.new[0].Opportunity__c);
            if(trigger.new[0].Status__c == 'Approved' && trigger.old[0].Status__c != 'Approved'){
                if(trigger.new[0].for_workflow__c == null && trigger.new[0].Opportunity__c == NULL){
                //if(trigger.new[0].for_workflow__c == null){
                    String retMsg = OpportunityConvertPartnerPortalHelper.newOppFromOppRegistr(trigger.new[0].Id,'OppRegistration');
                    System.debug('**** retMsg = ' + retMsg);

                }
            }
               
           // if the status change to expired, associated not booked opportunity should be updated 
            if(trigger.new[0].Status__c=='Expired' && trigger.old[0].Status__c!='Expired' && trigger.new[0].IsOpportunity_Exist__c){  
                if(!(trigger.new[0].Opportunity_Stage__c.equalsIgnoreCase('6.Closed') || trigger.new[0].Opportunity_Stage__c.equalsIgnoreCase('5.Purchase Solution'))){
                    Opportunity op = [Select id, Partner_Opportunity_Source__c from Opportunity where Id =: trigger.new[0].Opportunity__c];
                    op.Partner_Opportunity_Source__c = 'Partner Sourced not registered';
                    update op;               
                } 
            }
        } else if(trigger.isBefore){
            //Populates AE if there is sold to on the record(s)
            PartnerPortalProspectTriggerHelper.populateAEFromSoldTo(trigger.new);
        }
    }
    catch(exception e){
        System.Debug('Error--->'+e.getMessage());
        System.Debug('LineNumber--->'+e.getLineNumber());
    }
}