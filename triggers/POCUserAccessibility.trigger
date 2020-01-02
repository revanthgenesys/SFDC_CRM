trigger POCUserAccessibility on POC_Engagement_Request__c(after insert,after update) {
   
   if(trigger.isInsert)
   {
      
      //if AE submit the Wow request then share the record to Leader if leader does not belong in above hierarchy of AE.
      
         //Get all leaders from selected Queue
         opportunity objopp=[SELECT End_User_Region__c,Country_Sub_Region__c from opportunity where id=:trigger.new[0].Opportunity_id__c];
         List<string> list_GroupMem =WoWUtility.getSubRegionalUsersForSharing(string.valueof(objopp.End_User_Region__c),string.valueof(objopp.Country_Sub_Region__c));
                        
         Set<string> objUID=new Set<string>();
       
         for(string obj: list_GroupMem)
           objUID.Add(obj);
        
         List<User> list_Users = [SELECT id,Name,ManagerId,userroleid FROM User WHERE UserName IN : objUID];  
         
        //Get all Users above role hierarchy of Leaders 
        clsGetUserAccessWow obj= new clsGetUserAccessWow();
        List<User>list_SelectedUsers = obj.GetUsers(list_Users);
        
        //Share records to Leaders        
        POCUtility.SharePOCRequest(list_Users,trigger.new[0]);
        
        //Share Wow request to above role hierarchy of Leaders
        POCUtility.SharePOCRequest(list_SelectedUsers,trigger.new[0]);
        
        //Find the Global wow requester from custom setting and share the wow request 
        List<Global_wow_requester__c> list_GlobalCusUsers = Global_wow_requester__c.getAll().values(); //fetch all values from custom setting
        
        List<user> list_GlobalUsers = new List<User>();
        set<string> Set_UserId=new set<string>();
        if(list_GlobalCusUsers.Size()>0)
            {
            for(Global_wow_requester__c objWowReq:list_GlobalCusUsers)
                Set_UserId.add(objWowReq.RequesterName__c);
             }
           
        list_GlobalUsers=[Select Id,Name From User Where userName in:Set_UserId];
         
        //Share Wow request to Global title users
        POCUtility.SharePOCRequest(list_GlobalUsers,trigger.new[0]);   
   }
   
   if(trigger.isUpdate)
   {      
      set<string> setVT=new set<string>();
      
      list<POCVirtualUser__c> list_VTUsers=[SELECT Solution_Consultant__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:trigger.new[0].Id];
      for(POCVirtualUser__c objVT : list_VTUsers)
          setVT.add(objVT.Solution_Consultant__c);
      List<User>list_UserAllData = [Select id,userroleid,managerid from User where id IN :setVT];
      
      //Get all Users above role hierarchy of Leaders 
      
        clsGetUserAccessWow obj= new clsGetUserAccessWow();
        List<User>list_SelectedUsers = obj.GetUsers(list_UserAllData);
        
        system.debug('+++list_SelectedUsers+++   '+list_SelectedUsers);
      
      //Share Wow request to above role hierarchy of Virtual Team
      if(list_SelectedUsers.size()>0 && list_SelectedUsers!=null)
        POCUtility.SharePOCRequest(list_SelectedUsers,trigger.new[0]);
   }
   
}