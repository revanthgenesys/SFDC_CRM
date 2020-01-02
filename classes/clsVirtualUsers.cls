public class clsVirtualUsers
{
   public string strDSRID{get;set;}
   
   public List<DSR_Virtual_Team__c>list_VT{
   get {
      list_VT = [select id,name,Virtual_Team_Member_Name__r.Name from DSR_Virtual_Team__c where Virtual_User_Role__c =: 'Virtual Team' and SCE_ID__c =: strDSRID];
      return list_VT; }
   set;
   }
   
   public clsVirtualUsers()
   {
      //list_VT = new List<DSR_Virtual_Team__c>();
      //list_VT = [select id,name,Virtual_Team_Member_Name__r.Name from DSR_Virtual_Team__c where Virtual_User_Role__c =: 'Virtual Team' and SCE_ID__c =: strDSRID];
      //system.debug('++++list_VT ++++  '+list_VT );
   }
}