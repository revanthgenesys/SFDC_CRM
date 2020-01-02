trigger Partnerdirectorychildstg on Partner_Directory_Staging__c (After insert, After Update) {

Map<id,Partner_Directory_Staging__c> partneridandpartnermap = new Map<id,Partner_Directory_Staging__c>();
List<Partner_Directory_Approved__c> lstpartdirStg = new List<Partner_Directory_Approved__c>();
List<Partner_Directory_Approved__c> updlstpartdirStg = new List<Partner_Directory_Approved__c>();

if ((trigger.isInsert || trigger.isUpdate) && trigger.isAfter) {

    for(Partner_Directory_Staging__c pd : trigger.new)
    {
        if(trigger.isinsert)
        {
            Partner_Directory_Approved__c stgpd = new Partner_Directory_Approved__c();
            stgpd.Partner_Directory_Staging__c = pd.Id ;
            stgpd.Account__c  = pd.Account__C;            
            stgpd.Phone__c = pd.Phone__c;
            stgpd.Website__c = pd.Website__c;
            stgpd.Approval_Status__c = pd.Approval_Status__c;
            stgpd.Company_Description__c = pd.Company_Description__c;
            stgpd.Country_Territory__c = pd.Country_Territory__c;  
            stgpd.Partner_Country__c = pd.Partner_Country__c;            
            stgpd.HQ_Address__c = pd.HQ_Address__c;
            stgpd.latitude__c = pd.latitude__c;
            stgpd.longitude__c = pd.longitude__c;      
            stgpd.channel_Manager__c= pd.channel_Manager__c; 
          
            lstpartdirStg.add(stgpd);     
        }
        
        if(trigger.isUpdate) {    // Check isUpdate
                partneridandpartnermap.put(pd.Id, pd);    // Put the Map value
            }
    }
    
    if(lstpartdirStg.size() > 0){
    
        insert lstpartdirStg;
    }
    
    
   if(partneridandpartnermap.size() > 0 )
    {
    for(Partner_Directory_Approved__c stgpdr : [select id,name,Approval_Status__c,HQ_Address__c ,region__C,Phone__c,Website__c,latitude__c,longitude__c,
         Partner_Name__c,Company_Description__c,Partner_Directory_Staging__c,channel_Manager__c,Partner_Country__c  from  Partner_Directory_Approved__c  where Partner_Directory_Staging__c in :partneridandpartnermap.keyset()])
            {
            if(partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Approval_Status__c == 'Published'){
             stgpdr.Approval_Status__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Approval_Status__c;
             stgpdr.HQ_Address__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).HQ_Address__c;
             stgpdr.Phone__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Phone__c;
             stgpdr.Website__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Website__c;
             stgpdr.latitude__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).latitude__c;
             stgpdr.longitude__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).longitude__c;
             stgpdr.Company_Description__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Company_Description__c;
             stgpdr.channel_Manager__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).channel_Manager__c;
             stgpdr.Country_Territory__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Country_Territory__c;           
             stgpdr.Partner_Country__c = partneridandpartnermap.get(stgpdr.Partner_Directory_Staging__c).Partner_Country__c;
               
             
             updlstpartdirStg.add(stgpdr);
             
           }
            } 
            if(updlstpartdirStg.size()>0)
            {
            update updlstpartdirStg;
            }
    
    } 
    
    }
    }