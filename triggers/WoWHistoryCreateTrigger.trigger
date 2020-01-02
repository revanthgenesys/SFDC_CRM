trigger WoWHistoryCreateTrigger on Wow_Attachments__c (after insert) {
    
   if(trigger.isInsert) 
   {
        boolean isVision = false;
        for(Wow_Attachments__c obj :trigger.new)
        {
         system.debug(LoggingLevel.Info,'obj.Link_URL__c '+obj.Link_URL__c);
          if(obj.Type__c == 'Vision' && obj.Link_URL__c != null)
            isVision = true;
        }
        system.debug(LoggingLevel.Info,'++++isVision ++++   '+isVision );
        if(isVision)
        {
          system.debug(LoggingLevel.Info,'++++isVision in if ++++   '+isVision );
           Wow_Request_Form__c objWow = [Select id,WoW_Status__c from Wow_Request_Form__c where id =: trigger.new[0].Wow_Request_Form__c];
        
            Wow_Request_Form_History__c objWoWHst=new Wow_Request_Form_History__c();
            objWoWHst.Action__c = 'Vision Link added by Virtual Team';
            objWoWHst.UserId__c = UserInfo.getUserID();
            objWoWHst.Date__c = System.now();
            objWoWHst.User_Type__c = WoWUtility.GetUserType(UserInfo.getUserId(),trigger.new[0].Wow_Request_Form__c,null);
            objWoWHst.WoW_Status_del__c = objWow.WoW_Status__c;
            objWoWHst.WoW_Request_Id__c = trigger.new[0].Wow_Request_Form__c;
            objWoWHst.w_o_w_stage__c = WoWUtility.GetWowStage('Virtual Team');
            insert objWoWHst;
        }
   }   
}