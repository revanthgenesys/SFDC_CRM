trigger ConvertOpp on Lead_Referral_Registration__c (After Update, before update, before insert) {

//Added by navaneetha
if((trigger.isInsert || trigger.isUpdate)&& trigger.isBefore)
        {
        //Navaneetha Added 03-07-2018
            if(trigger.isInsert){  
            //OfferingPlatformTypeUtil.updatePlatformAndOfferingType(trigger.new, null);  
            updateofferplatformtypehandler.updateOfferingPlatformType( trigger.new, null); 
            system.debug('Navaneethatest12');
            }
            else{
            //OfferingPlatformTypeUtil.updatePlatformAndOfferingType(trigger.new, trigger.oldMap);
            updateofferplatformtypehandler.updateOfferingPlatformType(trigger.new, trigger.oldMap);  
            system.debug('Navaneethatest2');
            }
        }
  //codeended
  if(Trigger.isAfter)
  {
    /*if(trigger.new[0].Status__c=='Request Pending' && trigger.old[0].Status__c!='Request Pending')// && trigger.new[0].End_User_Account__c != null
    {
       RecordType objRec = [SELECT Name, id FROM RecordType where name = 'Lead Referral Registration After Approval'];
       Lead_Referral_Registration__c objLRR = new Lead_Referral_Registration__c();
       objLRR.RecordTypeId = objRec.id;
       objLRR.id = trigger.new[0].id;
       update objLRR;
    }*/
   
   if(trigger.new[0].isCMApproved__c && trigger.new[0].End_User_Account__c == null)
     trigger.new[0].addError('Please select End User Account.');
   
    if(trigger.new[0].Status__c=='Approved' && trigger.old[0].Status__c!='Approved'){
      //if(trigger.new[0].for_workflow__c == null)
        if(trigger.new[0].End_User_Account__c==null){
            trigger.new[0].addError('Please select End User Account.'); 
        }else{
            LeadReferralRegistration_Utility.newOppFromOppRegistr(trigger.new[0].Id,'OppRegistration');
        }
    }
    
    
  }
  
       
}