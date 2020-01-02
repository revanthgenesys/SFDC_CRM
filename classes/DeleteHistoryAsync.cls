public class DeleteHistoryAsync implements Queueable {
    
    public List<Delete_History_Object__c> lstToInsrt = new List<Delete_History_Object__c>();
    public List<Delete_History_Object__c> lstToDel = new List<Delete_History_Object__c>();

    public DeleteHistoryAsync(Map<id,OpportunityLineItem> deletedlinitem, String Operation) {
         
        system.debug('deletedlinitem--> '+deletedlinitem);
        if(operation.containsIgnoreCase('delete')){
            if(deletedlinitem.size()>0){
                map<Id,Delete_History_Object__c> mapDelHist = fetchDeleteHistory(deletedlinitem.keyset());
                System.Debug('mapDelHistOppLine--->'+mapDelHist);
                for(OpportunityLineItem del: deletedlinitem.values()){
                    if(mapDelHist.size()>0 && mapDelHist.containsKey(del.Id)){
                        mapDelHist.get(del.Id).State__c = 'Deleted';
                        lstToInsrt.add(mapDelHist.get(del.Id));
                        //Delete_History_Object__c backup1 = new Delete_History_Object__c(Id=mapDelHist.get(del.Id).Id,State__c='Deleted');
                        
                    }
                    else{
                       Delete_History_Object__c backup = new Delete_History_Object__c();
                       backup.Object_Name__c   = 'OpportunityLineItem';
                       backup.Parent_Object_Name__c = 'Opportunity';
                       backup.API_Name__c   ='OpportunityLineItem';
                       backup.State__c ='Deleted';
                       backup.Parent_Id__c = del.OpportunityId;
                       backup.Record_ID__c   = del.X18_Digit_Id__c;
                       backup.Deleted_By_User__c = userinfo.getuserId();
                       lstToInsrt.add(backup);
                    }
                        
                  }
                  System.Debug('lstToInsrt--->'+lstToInsrt);
            }
        }
        else{
            lstToDel = [select id,State__c from Delete_History_Object__c where Record_ID__c in :deletedlinitem.keyset() OR Parent_Id__c IN:deletedlinitem.keyset()];
            System.Debug('lstToDelOpty--->'+lstToDel);
            for(Delete_History_Object__c upd :lstToDel)
            {
               upd.State__c = 'Undeleted';
            }
            
        }
            
    }
    
    public DeleteHistoryAsync(Map<id,Opportunity> deletedlinitem, String Operation) {
         
        this(new map<Id,OpportunityLineItem>([Select id,opportunityid,X18_Digit_Id__c from opportunitylineitem where opportunityid IN:deletedlinitem.keyset()]),Operation);
        system.debug('deletedopty--> '+deletedlinitem);
        if(operation.containsIgnoreCase('delete')){
            if(deletedlinitem.size()>0){  
                map<Id,Delete_History_Object__c> mapDelHist = fetchDeleteHistory(deletedlinitem.keyset());
                System.Debug('mapDelHistOpp--->'+mapDelHist);
                for(Opportunity del: deletedlinitem.values()){
                    if(mapDelHist.size()>0 && mapDelHist.containsKey(del.Id)){
                        mapDelHist.get(del.Id).State__c = 'Deleted';
                        lstToInsrt.add(mapDelHist.get(del.Id));                        
                    }
                    else{
                   Delete_History_Object__c backup = new Delete_History_Object__c();
                  // backup.Deleted_Object_Name__c   = del.opportunityId;
                   backup.Object_Name__c   = 'Opportunity';
                   backup.API_Name__c   ='Opportunity';
                   backup.State__c ='Deleted';
                   //backup.Parent_Object_Name__c = 'Opportunity';
                   //backup.Parent_Id__c = del.OpportunityId;
                   backup.Record_ID__c   = del.X18_Digit_Id__c;
                   backup.Deleted_By_User__c = userinfo.getuserId();
                    
                   lstToInsrt.add(backup);
                  }
                  System.Debug('lstToInsrtOpty--->'+lstToInsrt);
            }
            }
        }
        else{
            System.Debug('after Undelete started');
            lstToDel = [select id,State__c from Delete_History_Object__c where Record_ID__c IN :deletedlinitem.keyset() OR Parent_Id__c IN:deletedlinitem.keyset()];
             for(Delete_History_Object__c upd :lstToDel)
            {
               upd.State__c = 'Undeleted';
            }
            System.Debug('lstToDelOpty--->'+lstToDel);
        }
            
    }
    
    public DeleteHistoryAsync(Map<id,BigMachines__Quote_Product__c> deletedlinitem, String Operation) {         
        system.debug('deletedlinitem--> '+deletedlinitem);
        if(operation.containsIgnoreCase('delete')){
            if(deletedlinitem.size()>0){
                map<Id,Delete_History_Object__c> mapDelHist = fetchDeleteHistory(deletedlinitem.keyset());
                System.Debug('mapDelHistquotePdt--->'+mapDelHist);
                for(BigMachines__Quote_Product__c del: deletedlinitem.values()){
                    if(mapDelHist.size()>0 && mapDelHist.containsKey(del.Id)){
                        mapDelHist.get(del.Id).State__c = 'Deleted';
                        lstToInsrt.add(mapDelHist.get(del.Id));
                    }
                    else{
                        
                   Delete_History_Object__c backup = new Delete_History_Object__c();
                   backup.Object_Name__c   = 'Quote_Product';
                   backup.Parent_Object_Name__c = 'Quote';
                   backup.State__c ='Deleted';
                   backup.API_Name__c   = 'BigMachines__Quote_Product__c';
                   backup.Parent_Id__c = del.BigMachines__Quote__c;
                   backup.Record_ID__c   = del.X18_Digit_Id__c;
                   backup.Deleted_By_User__c = userinfo.getuserId();
                    
                   lstToInsrt.add(backup);
                  }
                }
                  System.Debug('lstToInsrtquotepdt--->'+lstToInsrt);
            }
        }
        else{
            lstToDel = [select id,State__c from Delete_History_Object__c where Record_ID__c in :deletedlinitem.keyset() OR Parent_Id__c IN:deletedlinitem.keyset()];
            System.Debug('lstToDelquotepdt--->'+lstToDel);
             for(Delete_History_Object__c upd :lstToDel)
            {
               upd.State__c = 'Undeleted';
            }
        }
            
    }

      public DeleteHistoryAsync(Map<id,BigMachines__Quote__c> deletedlinitem, String Operation) {
         
        this(new map<Id,BigMachines__Quote_Product__c>([Select id,BigMachines__Quote__c,X18_Digit_Id__c from BigMachines__Quote_Product__c where BigMachines__Quote__c IN:deletedlinitem.keyset()]),Operation);
        system.debug('deletedquote--> '+deletedlinitem);
        if(operation.containsIgnoreCase('delete')){
            if(deletedlinitem.size()>0){    
                map<Id,Delete_History_Object__c> mapDelHist = fetchDeleteHistory(deletedlinitem.keyset());
                System.Debug('mapDelHistQuote--->'+mapDelHist);
                for(BigMachines__Quote__c del: deletedlinitem.values()){
                    if(mapDelHist.size()>0 && mapDelHist.containsKey(del.Id)){
                        mapDelHist.get(del.Id).State__c = 'Deleted';
                        lstToInsrt.add(mapDelHist.get(del.Id));                        
                    }
                    else{

                   Delete_History_Object__c backup = new Delete_History_Object__c();
                   backup.Object_Name__c   = 'Quote';
                  backup.State__c ='Deleted';
                  backup.API_Name__c   ='BigMachines__Quote__c';
                   backup.Record_ID__c   = del.X18_Digit_Id__c;
                   backup.Deleted_By_User__c = userinfo.getuserId();
                    
                   lstToInsrt.add(backup);
                   system.debug('added');
                  }
                }
                  System.Debug('lstToInsrtquote--->'+lstToInsrt);
            }
        }
        else{
            System.Debug('after Undelete started');
            lstToDel = [select id,State__c from Delete_History_Object__c where Record_ID__c IN :deletedlinitem.keyset() OR Parent_Id__c IN:deletedlinitem.keyset()];
            System.Debug('lstToDelquote--->'+lstToDel);
             for(Delete_History_Object__c upd :lstToDel)
            {
               upd.State__c = 'Undeleted';
            }
        }
            
    }
     public DeleteHistoryAsync(Map<id,Order_Line_Item__c> deletedlinitem, String Operation) {
         
        system.debug('deletedlinitem--> '+deletedlinitem);
        if(operation.containsIgnoreCase('delete')){
            if(deletedlinitem.size()>0){
                map<Id,Delete_History_Object__c> mapDelHist = fetchDeleteHistory(deletedlinitem.keyset());
                System.Debug('mapDelHistOrderLine--->'+mapDelHist);
                for(Order_Line_Item__c del: deletedlinitem.values()){
                     if(mapDelHist.size()>0 && mapDelHist.containsKey(del.Id)){
                        mapDelHist.get(del.Id).State__c = 'Deleted';
                        lstToInsrt.add(mapDelHist.get(del.Id));                        
                    }
                    else{
                   Delete_History_Object__c backup = new Delete_History_Object__c();
                   backup.Object_Name__c   = 'Order_Line_Item';
                   backup.Parent_Object_Name__c = 'Order';
                   backup.State__c ='Deleted';
                   backup.API_Name__c   ='Order_Line_Item__c';
                   backup.Parent_Id__c = del.Order__c;
                   backup.Record_ID__c   = del.X18_Digit_Id__c;
                   backup.Deleted_By_User__c = userinfo.getuserId();
                    
                   lstToInsrt.add(backup);
                  }
                }
                  System.Debug('lstToInsrt--->'+lstToInsrt);
            }
        }
        else{
            lstToDel = [select id,State__c from Delete_History_Object__c where Record_ID__c in :deletedlinitem.keyset() OR Parent_Id__c IN:deletedlinitem.keyset()];
            System.Debug('lstToDelOrder--->'+lstToDel);
             for(Delete_History_Object__c upd :lstToDel)
            {
               upd.State__c = 'Undeleted';
            }
        }
            
    }
    public DeleteHistoryAsync(Map<id,Order__c> deletedlinitem, String Operation) {
         
        this(new map<Id,Order_Line_Item__c>([Select id,Order__c,X18_Digit_Id__c from Order_Line_Item__c where Order__c IN:deletedlinitem.keyset()]),Operation);
        system.debug('deletedorder--> '+deletedlinitem);
        if(operation.containsIgnoreCase('delete')){
            if(deletedlinitem.size()>0){    
                map<Id,Delete_History_Object__c> mapDelHist = fetchDeleteHistory(deletedlinitem.keyset());
                System.Debug('mapDelHistOpp--->'+mapDelHist);
                for(Order__c del: deletedlinitem.values()){
                    if(mapDelHist.size()>0 && mapDelHist.containsKey(del.Id)){
                        mapDelHist.get(del.Id).State__c = 'Deleted';
                        lstToInsrt.add(mapDelHist.get(del.Id));                        
                    }
                    else{
                   Delete_History_Object__c backup = new Delete_History_Object__c();
                   backup.Object_Name__c   = 'Order';
                   backup.API_Name__c   ='Order__c';
                   backup.State__c ='Deleted';
                   backup.Record_ID__c   = del.X18_Digit_Id__c;
                   backup.Deleted_By_User__c = userinfo.getuserId();
                    
                   lstToInsrt.add(backup);
                  }
                }
                  System.Debug('lstToInsrtOrder--->'+lstToInsrt);
            }
        }
        else{
            System.Debug('after Undelete started');
            lstToDel = [select id,State__c from Delete_History_Object__c where Record_ID__c IN :deletedlinitem.keyset() OR Parent_Id__c IN:deletedlinitem.keyset()];
            System.Debug('lstToDelOrder--->'+lstToDel);
             for(Delete_History_Object__c upd :lstToDel)
            {
               upd.State__c = 'Undeleted';
            }
        }
            
    }
    public void execute(QueueableContext context) {
             if(lstToInsrt.size()>0)
          {
           upsert lstToInsrt;
           system.debug('listinsertDel--->'+lstToInsrt);
           }
            if(lstToDel.size()>0)
          {
           update lstToDel;
           system.debug('listinsertundel'+lstToDel);
           }
    }
    
    public map<Id,Delete_History_Object__c> fetchDeleteHistory(set<Id> delIdLst){
        map<id,Delete_History_Object__c> delHistMap = new map<id,Delete_History_Object__c>();
        if(delIdLst.size()>0){
            for(Delete_History_Object__c delRec:[Select Id,State__c,Record_ID__c from Delete_History_Object__c where Record_ID__c IN:delIdLst]){
                delHistMap.put(delRec.Record_ID__c,delRec);
            }
        }
        return delHistMap;
    }
}