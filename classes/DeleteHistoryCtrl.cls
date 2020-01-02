public class DeleteHistoryCtrl {
    public static void ondelete(map<Id,OpportunityLineItem> deletedlinitem){ 
        system.debug('deletedlinitem--> '+deletedlinitem);
       
        List<Delete_History_Object__c> lstToInsrt = new List<Delete_History_Object__c>();
        for(OpportunityLineItem del: deletedlinitem.values()){
                   system.debug('del '+del );
           Delete_History_Object__c backup = new Delete_History_Object__c();
          // backup.Deleted_Object_Name__c   = del.opportunityId;
           backup.Object_Name__c   = 'OpportunityLineItem';
           backup.Parent_Object_Name__c = 'Opportunity';
           backup.Parent_Id__c = del.OpportunityId;
           backup.Record_ID__c   = del.X18_Digit_Id__c;
           backup.Deleted_By_User__c = userinfo.getuserId();
        
           lstToInsrt.add(backup);
           system.debug('backup '+backup);
          }
           if(lstToInsrt.size()>0)
          {
           insert lstToInsrt;
           system.debug('list'+lstToInsrt);
           }
  }
  public static void ondelete(map<Id,Opportunity> deletedoppitem){ 
        system.debug('deletedoppitem--> '+deletedoppitem);
        List<Delete_History_Object__c> lstToInsrt = new List<Delete_History_Object__c>();
        list<Id> optyIDs = new list<Id>();
        for(Opportunity del: deletedoppitem.values()){
           system.debug('del '+del );
           Delete_History_Object__c backup = new Delete_History_Object__c();
           backup.Object_Name__c   = 'Opportunity';
           backup.Record_ID__c   = del.X18_Digit_Id__c;
           backup.Deleted_By_User__c = userinfo.getuserId();
           lstToInsrt.add(backup);
           system.debug('backup '+backup);
          }
           if(lstToInsrt.size()>0)
          {
           insert lstToInsrt;
           system.debug('list'+lstToInsrt);
           }
        map<Id,OpportunityLineItem> optyLineMap = new map<Id,OpportunityLineItem>([Select id,opportunityid,X18_Digit_Id__c from opportunitylineitem where opportunityid IN:deletedoppitem.keyset()]);
        System.Debug('optyLineMap--->'+optyLineMap);
        if(optyLineMap.size()>0){
            ondelete(optyLineMap);
        }
  }
 }