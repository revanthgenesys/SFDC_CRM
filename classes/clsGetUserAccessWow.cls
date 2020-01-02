public class clsGetUserAccessWow
{
  public List<User>list_AllUsers{get;set;}
  public List<User>list_SelectedUsers{get;set;}
  
  public List<UserRole>list_UserRole{get;set;}
  public List<UserRole>list_SelectedUserRole{get;set;}
  public set<id>set_SelectedUserRoleIds{get;set;}
  public Set<UserRole>set_SelectedUserRole{get;set;}
  public Map<ID, UserRole> map_UserRole{get;set;}
  
  public clsGetUserAccessWow()
  {
    system.debug('+++set_SelectedUserRole+++'); 
    set_SelectedUserRole = new Set<UserRole>();
    list_SelectedUserRole = new List<UserRole>();
    list_AllUsers = new List<User>();
    list_SelectedUsers = new List<User>();
    set_SelectedUserRoleIds = new Set<id>();
    
    //list_AllUsers = [Select id,ManagerId,userroleid from User where isActive =: true and profile.name <>'Chatter Free User' and profile.name <>'Chatter External User'];
    //list_UserRole = [select Id,name,ParentRoleId from UserRole];
    map_UserRole = new Map<ID, UserRole>([select Id,name,ParentRoleId from UserRole where PortalType <> 'CustomerPortal' and PortalType <> 'Partner']);
    //for(UserRole objUR : list_UserRole )
    // set_SelectedUserRole.add(objUR);
     
    //system.debug('+++set_SelectedUserRole+++'+set_SelectedUserRole); 
  }
  
  public List<User> GetUsers(List<User> list_User)
  {
   
    system.debug('+++list_User+++'+list_User);
    
    for(User objU : list_User)
    {
      //UserRole objUR = new UserRole(id=objU.userroleid);
      UserRole objUR;
      
      /*for(UserRole objRole : list_UserRole)
      {
        if(objRole.id == objU.userroleid)
           objUR = objRole; 
      }*/
      objUR = map_UserRole.get(objU.userroleid);
      
     if(objUR != null)
      {
         system.debug('+++objU.userroleid  +++'+objU.userroleid);
         system.debug('+++objUR +++'+objUR );
         system.debug('+++map_UserRole+++'+map_UserRole);         
          if(!set_SelectedUserRole.contains(objUR))
          {  
            set_SelectedUserRole.add(objUR);
            list_SelectedUserRole.add(objUR);
            set_SelectedUserRoleIds.add(objUR.id);
            
            //UserRole objR = new UserRole(id=objUR.id);
            GetUsersList(objUR,'FIRST'); //Recursive function to find the above role hierarchy users
          }
       }   
    }
    
    system.debug('+++list_SelectedUserRole+++'+list_SelectedUserRole);
    system.debug('+++set_SelectedUserRole query+++'+set_SelectedUserRole);
    system.debug('+++set_SelectedUserRole size+++'+set_SelectedUserRole.size());
    
    if(set_SelectedUserRole.size()>0)
      list_SelectedUsers = [Select id,managerid,userroleid from User where userroleid IN :set_SelectedUserRole and isActive =: true and profile.name <>'Chatter Free User' and profile.name <>'Chatter External User'];
    
    /*for(User objUs : list_AllUsers) 
    {
      if(set_SelectedUserRoleIds.contains(objUs.userroleid))
        list_SelectedUsers.add(objUs);
    }*/
     system.debug('+++list_SelectedUsers +++'+list_SelectedUsers );
     return list_SelectedUsers;
  }
  
  private void GetUsersList(UserRole objUserRole,string occurence)
  {
     system.debug('+++GetUsersList 11+++');
     system.debug('+++objUserRole 11+++'+objUserRole);
    //if(!set_SelectedUserRole.contains(objUserRole))
    if(objUserRole != null)
    {
        if((!set_SelectedUserRole.contains(objUserRole) && occurence == 'SECOND')|| (set_SelectedUserRole.contains(objUserRole) && occurence == 'FIRST'))
        {
          system.debug('+++GetUsersList 22+++');
          if(occurence != 'FIRST')
          {
            set_SelectedUserRole.add(objUserRole);
            list_SelectedUserRole.add(objUserRole);
            set_SelectedUserRoleIds.add(objUserRole.id);
          }
          
          //UserRole objUR = new UserRole(id = objUserRole.ParentRoleId);
          UserRole objParentRole = new UserRole();
          /*for(UserRole objRole : list_UserRole)
          {
            if(objRole.id == objUserRole.ParentRoleId)
               objParentRole = objRole; 
          }*/
          objParentRole = map_UserRole.get(objUserRole.ParentRoleId);
          system.debug('+++objParentRole +++'+objParentRole );
          GetUsersList(objParentRole,'SECOND');
        }
    }
  }
}