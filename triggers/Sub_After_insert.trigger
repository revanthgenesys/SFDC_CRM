trigger Sub_After_insert on Subscription__c (after insert,after update) {

        if(Util.Bypass_Trigger_Chk)
            return;
            
         if(trigger.isUpdate && trigger.isAfter){
            for(Subscription__c subRec:trigger.new){
                if((subRec.Offering_Type__c =='PureConnect Subscription' || subRec.Offering_Type__c == 'PureConnect Cloud')&&
                    subRec.Cloud_Deployment__c !=null){
                        
                       SubscriptionUtil.sendSubscriptionsToBilling(subRec.Id,subRec.Cloud_Deployment__c,subRec.Offering_Type__c);
                }
            }
           // Subscription__c objSub = trigger.new[0];
            //SubscriptionUtil.sendSubscriptionsToBilling();
        }
        if(Trigger.isInsert){
        
            //Mukunth added below lines to map Account Order Addresses from Order to CCDB record
            //---------Start----------
            map<Id,string> ccdbIDs = new map<Id,string>();
            for(Subscription__c subRec:trigger.new){
                ccdbIDs.put(subRec.Id,subRec.Offering_Type__c);
            }
            if(ccdbIDs.size()>0){
                SubscriptionUtil.copyAccountOrderAddrtoCCDB(ccdbIDs);
            }
            //----------End------------
          
            Map < Id, List<Cloud_Deployment__c> > mapCDId = new Map < Id, List<Cloud_Deployment__c>  > ();
            Set < Id > accIds = new Set < Id > ();
            Map <string, string> cdsbid = new Map<string, String>();
            for( Subscription__c subcc: Trigger.new ){
                
            if(subcc.Offering_Type__c == 'PureEngage Subscription' || subcc.Offering_Type__c =='PureConnect Subscription'|| subcc.Offering_Type__c =='PureConnect Cloud' || subcc.Offering_Type__c == 'PureCloud' || subcc.Offering_Type__c == 'PureEngage Cloud' ){
            accIds.add(subcc.Account__c);   }     
            }       
            system.debug('TEstnavanee1'+ accIds);
             list <Cloud_Deployment__c> cdid = new list<Cloud_Deployment__c> ();        
             List < Cloud_Deployment__c > cDaccounts = [SELECT id, Account__c, Cloud_Platform__c,Cloud_Deployment__c.Order__c FROM Cloud_Deployment__c WHERE  Account__c IN: accIds and (Cloud_Platform__c = 'PureEngage Subscription' or Cloud_Platform__c ='PureConnect Subscription' or Cloud_Platform__c ='PureConnect Cloud' or Cloud_Platform__c ='PureCloud' or Cloud_Platform__c ='PureEngage Cloud'  )];
             system.debug('TEstnavanee2'+ cDaccounts);
            for( Cloud_Deployment__c eachcd : cDaccounts  ){
             
             if(mapCDId.containskey(eachcd.Account__c))
                 {
                     mapCDId.get(eachcd.Account__c).add(eachcd);
                 }
                 
             else{
                     List<Cloud_Deployment__c> lstccd=new List<Cloud_Deployment__c>();
                     lstccd.add(eachcd);
                     mapCDId.put(eachcd.Account__c,lstccd);
             
             }
             
             }
            List<Cloud_Deployment__c> lstccdtoinsert = new List<Cloud_Deployment__c>();
            List<Cloud_Deployment__c> lstccdtoupdate = new List<Cloud_Deployment__c>();
             for(Subscription__c subcc1: Trigger.new ){
             system.debug('subcc1.id' + subcc1.id);
             system.debug('subcc1.Offering_Type__c '+  subcc1.Offering_Type__c);
                 if((subcc1.Offering_Type__c == 'PureEngage Subscription' || subcc1.Offering_Type__c =='PureConnect Subscription'|| subcc1.Offering_Type__c =='PureConnect Cloud' || subcc1.Offering_Type__c == 'PureCloud' || subcc1.Offering_Type__c == 'PureEngage Cloud')){
             boolean create=true;
              system.debug('subcc1.Quote_Order_Type__c '+  subcc1.Quote_Order_Type__c);
             if(mapCDId.containskey(subcc1.Account__c) && (subcc1.Quote_Order_Type__c == 'Amend' || subcc1.Quote_Order_Type__c == 'Amend Subscription' || subcc1.Quote_Order_Type__c == 'Renew Subscription' ||subcc1.Quote_Order_Type__c == 'Add On' ||subcc1.Quote_Order_Type__c == 'Add-On' || subcc1.Order__r.RecordTypeId == '012U0000000kF07' ))
                 {
                 System.debug('Navanee5' + subcc1.Account__c);
                     for(Cloud_Deployment__c cdpt : mapCDId.get(subcc1.Account__c) )
                     {
                     System.debug('Navanee6' + subcc1.Account__c); 
                     System.debug('Navanee61' + cdpt.Account__c );
                     System.debug('Navanee6.1' + subcc1.Offering_Type__c);
                     System.debug('Navanee6.1' + cdpt.id);
                      if(cdpt.Cloud_Platform__c == subcc1.Offering_Type__c && cdpt.Account__c == subcc1.Account__c )                  
                      {
                          cdpt.CCDB_Subscription_ID__c = subcc1.id;
                          cdpt.Order__c = subcc1.Order__c;
                          cdpt.Quote__c= subcc1.Quote__c;
                          lstccdtoupdate.add(cdpt);                  
                          cdsbid.put(subcc1.id , cdpt.id);
                          System.debug('Navanee71' + cdsbid);
                          create=false;
                      } else{ System.debug('TEst navanee vinay');
                      create=true;}                    
                      
                     }
                     
                 }
                 
                 
                 if(create){                 
                 system.debug('subcc1.id' + subcc1.id);
                 system.debug('NAvanee' + subcc1.id);
                 system.debug('subcc1.Offering_Type__c' +  subcc1.Offering_Type__c);
                 Cloud_Deployment__c cd= new Cloud_Deployment__c();
                 cd.CCDB_Subscription_ID__c = subcc1.id ;
                 cd.Cloud_Platform__c = subcc1.Offering_Type__c;
                 //cd.Status__c = 'Production';
                 //Modified below if condition by Vinay 05/02/19                 
                 if(subcc1.Offering_Type__c == 'PureConnect Cloud' || subcc1.Offering_Type__c == 'PureCloud' || subcc1.Offering_Type__c == 'PureEngage Cloud' ) {
                     cd.Support_Status__c = 'Order Processing';
                     cd.Care_Level__c = 'PureConnect Standard';
                     cd.Status__c = 'Deployment';
                 }
                 else 
                 {
                     cd.Support_Status__c = 'Billing Only';
                     cd.Care_Level__c = 'Care for Cloud';
                     cd.Status__c = 'Production';
                 }
                 cd.Account__c = subcc1.Account__c;
                 //cd.Care_Level__c = 'Care for Cloud';
                 cd.Name = subcc1.Account_Name__c;
                 if(subcc1.Sale_Type__c == 'Direct'){
                 System.debug('Direct/Indirect1' + subcc1.Sale_Type__c);
                   cd.Sold_To_Account__c = subcc1.Account__c;  
                 }
                 else{
                 System.debug('Direct/Indirect1' + subcc1.Sale_Type__c);             
                 cd.Sold_To_Account__c = subcc1.Business_Partner__c;
                 }
                 cd.Order__c = subcc1.Order__c;
                 cd.CCDB_Subscription_ID__c = subcc1.id;
                 cd.Quote__c= subcc1.Quote__c;
                 lstccdtoinsert.add(cd);
                 
                 }
             }
             
             }
             if(lstccdtoupdate.size()>0){
             update lstccdtoupdate; }
              if(lstccdtoinsert.size()>0){
             insert lstccdtoinsert;
             for(Cloud_Deployment__c cld: lstccdtoinsert ){
                 cdsbid.put(cld.CCDB_Subscription_ID__c , cld.id);
             }         
             }
             
             if(cdsbid.Size() > 0){
             List<Subscription__c> lstupdatesub = new List<Subscription__c>();
             lstupdatesub = [Select id, Cloud_Deployment__c from Subscription__c where id IN : cdsbid.keyset()];
             for(Subscription__c subcdid : lstupdatesub)
             {
                 subcdid.Cloud_Deployment__c = cdsbid.get(subcdid.id);
             }
             
             update lstupdatesub;
             }
             
           
            
        }
    }