public class AllRoleUtils //Ravi V - G360 -  9/3/2013 this is for getting all subordinates/under users list for anyuser
 {
  public Set<ID> getAllunderRoleIds(Set<ID> roleIds) 
  {
   Set<ID> currentRoleIds = new Set<ID>();
   for(UserRole userRole :[select Id,name from UserRole where ParentRoleId IN :roleIds ])
   {
    currentRoleIds.add(userRole.Id);
   }
   if(currentRoleIds.size() > 0)
   currentRoleIds.addAll(getAllunderRoleIds(currentRoleIds));
   return currentRoleIds;
  }
 }