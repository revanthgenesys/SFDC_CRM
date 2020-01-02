//Naresh Kumar  01/15/2014
trigger PartnerUserRequestMain on Partner_User_Request__c (before insert, after insert, after update, before update) {
    
    if(Trigger.isBefore && Trigger.isUpdate){
        CreateUserForPortalApplicationHandler.updateCreateNewFlags(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        CreateUserForPortalApplicationHandler.processRequests(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isInsert && Trigger.isafter)
    {
      Partner_User_Request__c objPUR = [select id,Account_Name__r.Channel_Manager__c from Partner_User_Request__c where id =: trigger.new[0].id];
      if(trigger.new[0].Channel_Manager__c == null)
        objPUR.Channel_Manager__c = objPUR.Account_Name__r.Channel_Manager__c; 
        update objPUR;
    }
}