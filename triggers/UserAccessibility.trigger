trigger UserAccessibility on Wow_Request_Form__c (before insert, before update, after insert,after update) {
   if(Util.Bypass_Trigger_Chk)
        return;
   if(trigger.isAfter)
   {     
       if(trigger.isInsert)
       {
          system.debug('insert');
          //if AE submit the Wow request then share the record to Leader if leader does not belong in above hierarchy of AE.
          //Get all leaders from selected Queue
          opportunity objopp=[SELECT End_User_Region__c,Country_Sub_Region__c,account.Primary_Solution_Consultant__c from opportunity where id=:trigger.new[0].Opportunity_id__c];
          //Commented/added by swastika on 28-sept-2016 get access all subregional leaders
          //List<string> list_GroupMem =WoWUtility.getSubRegionalUsersForSharing(string.valueof(objopp.End_User_Region__c),string.valueof(objopp.Country_Sub_Region__c));
          List<string> list_GroupMem =WoWUtility.getSubRegionalUsersForSharing();
          //Group objGroup = [Select Id from Group where type=: 'Queue' and Name=: trigger.new[0].Assign_Queue__c];
          //List<GroupMember> list_GroupMem = new List<GroupMember>(); 
          //list_GroupMem =[Select UserOrGroupId From GroupMember where GroupId =: objGroup.id];                   
          Set<string> objUID=new Set<string>();
          //for(GroupMember obj: list_GroupMem)
          if(list_GroupMem.size()>0)
          {
             for(string obj: list_GroupMem)
               objUID.Add(obj);
             system.debug(LoggingLevel.Info,'++++++objUID++++'+objUID);
             List<User> list_Users = [SELECT id,Name,ManagerId,userroleid FROM User WHERE UserName IN : objUID];  
             //added by Swastika on 26-Oct-2016 to insert Subregional Leaders on insertion of SC <start>
             //WoWUtility.InsertSCSubregionalUser(WoWUtility.getSubRegionalUsersForReport(string.valueof(objopp.End_User_Region__c),string.valueof(objopp.Country_Sub_Region__c)),trigger.new[0].Id);
             //added by Swastika on 26-Oct-2016 to insert Subregional Leaders on insertion of SC <end>
            //Get all Users above role hierarchy of Leaders 
            clsGetUserAccessWow obj= new clsGetUserAccessWow();
            List<User>list_SelectedUsers = obj.GetUsers(list_Users);
            system.debug(LoggingLevel.Info,'++++++list_SelectedUsers ++++'+list_SelectedUsers );
            //Share records to Leaders
            //WoWUtility.ShareWowRequest(objGroup,trigger.new[0]);
            WoWUtility.ShareWowRequest(list_Users,trigger.new[0]);
            
            //Share Wow request to above role hierarchy of Leaders
            WoWUtility.ShareWowRequest(list_SelectedUsers,trigger.new[0]);
          }
            //Find the Global wow requester from custom setting and share the wow request 
            List<Global_wow_requester__c> list_GlobalCusUsers = Global_wow_requester__c.getAll().values(); //fetch all values from custom setting
            system.debug(LoggingLevel.Info,'list_GlobalCusUsers '+list_GlobalCusUsers);
            List<user> list_GlobalUsers = new List<User>();
            set<string> Set_UserId=new set<string>();
            if(list_GlobalCusUsers.Size()>0)
            {
              for(Global_wow_requester__c objWowReq:list_GlobalCusUsers)
                Set_UserId.add(objWowReq.RequesterName__c);
            }
                system.debug(LoggingLevel.Info,'Set_UserId '+Set_UserId);
            list_GlobalUsers=[Select Id,Name From User Where userName in:Set_UserId];
             system.debug(LoggingLevel.Info,'list_GlobalUsers '+list_GlobalUsers);
            //Share Wow request to Global title users
            WoWUtility.ShareWowRequest(list_GlobalUsers,trigger.new[0]); 
            //Added by Swastika on 10-Oct-2016 to assign primary consultant from account as virtual team member <start>
            if(trigger.isAfter) 
            {            
                if(objopp.account.Primary_Solution_Consultant__c!=null)
                {        
                 WoW_Virtual_Users__c objAccountVT= new WoW_Virtual_Users__c();
                 objAccountVT.Virtual_User__c=objopp.account.Primary_Solution_Consultant__c;
                 objAccountVT.Virtual_User_type__c='Solution Consultant';
                 objAccountVT.Wow_Request_Form__c= trigger.new[0].Id; 
                 insert objAccountVT;                 
                }            
            }
            //Added by Swastika on 10-Oct-2016 to assign primary consultant from account as virtual team member <End> 
       }
       
       if(trigger.isUpdate)
       {
          system.debug(LoggingLevel.Info,'+++isUpdate+++');
          System.debug(LoggingLevel.INFO,'update trigger');
          //List<User>list_VirtualTeam = new List<User>();
          set<string> setVT=new set<string>();
          /*system.debug('+++trigger.new[0].SE__c +++'+trigger.new[0].SE__c );
          if(trigger.new[0].SE__c != null)
          {
            User objUser_SE = new User(id=trigger.new[0].SE__c);
            list_VirtualTeam.add(objUser_SE);
            system.debug('+++SE list_VirtualTeam+++   '+list_VirtualTeam);
          }
           system.debug('+++trigger.new[0].BC__c +++'+trigger.new[0].BC__c );
          if(trigger.new[0].BC__c != null)  
          {
            User objUser_BC = new User(id=trigger.new[0].BC__c);
            list_VirtualTeam.add(objUser_BC);
            system.debug('+++BC list_VirtualTeam+++   '+list_VirtualTeam);
          }*/
          list<WoW_Virtual_Users__c> list_VTUsers=[SELECT Virtual_User__c FROM WoW_Virtual_Users__c  WHERE Wow_Request_Form__c=:trigger.new[0].Id];
          system.debug(LoggingLevel.Info,'+++list_VTUsers+++   '+list_VTUsers);
          if(list_VTUsers.size()>0)
          {
             for(WoW_Virtual_Users__c objVT : list_VTUsers)
               setVT.add(objVT.Virtual_User__c);
             List<User>list_UserAllData = [Select id,userroleid,managerid from User where id IN :setVT];
              
             //Get all Users above role hierarchy of Leaders 
             clsGetUserAccessWow obj= new clsGetUserAccessWow();
             List<User>list_SelectedUsers = obj.GetUsers(list_UserAllData);
             //Share Wow request to above role hierarchy of Virtual Team
             if(list_SelectedUsers.size()>0 && list_SelectedUsers!=null)
               WoWUtility.ShareWowRequest(list_SelectedUsers,trigger.new[0]);
             system.debug(LoggingLevel.Info,'+++End trigger User Acc+++   ');
          }
       }
   }
   
   /*if(trigger.isInsert && trigger.isbefore)
   {
     //Update virtual user count
     Opportunity objOpp=[SELECT account.Primary_Solution_Consultant__c from opportunity where id=:trigger.new[0].Opportunity_id__c];
     if(objOpp.account.Primary_Solution_Consultant__c!= null)
     {
       trigger.new[0].VirtualUserCount__c = 1;
     } 
   }*/
   
   //Added by Swastika on 21-Oct-2016 to assign technical Profile and technical profile acknowledgement Date, score
   if(trigger.isafter && trigger.isinsert)
   {
      List<Technical_Profile__c> list_TechPro=[Select Id,score1__c,score2__c,Technical_Profile_Acknowledgment_Date__c FROM Technical_Profile__c WHERE Account__c=:trigger.new[0].Account_Id__c ORDER BY LastModifiedDate LIMIT 1];
      if(list_TechPro.size()>0)
      {
        Wow_Request_Form__c  objW = [Select id,Technical_Profile__c,score__c  from Wow_Request_Form__c  where id =: trigger.new[0].id];
        if(trigger.new[0].WoW_Status__c!='Completed')
        {                  
          objW.Technical_Profile__c=list_TechPro[0].Id;
          objW.Technical_Profile_Acknowledgement_Date__c=list_TechPro[0].Technical_Profile_Acknowledgment_Date__c;
        }                   
        objW.score__c = (list_TechPro[0].Score1__c == null ? 0 : integer.valueof(list_TechPro[0].Score1__c))  + (list_TechPro[0].Score2__c == null ? 0 : integer.valueof(list_TechPro[0].Score2__c)) ;
        update objW;                 
      } 
   }
}