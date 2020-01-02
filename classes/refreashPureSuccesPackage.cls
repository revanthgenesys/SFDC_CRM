public class refreashPureSuccesPackage {
    //kartik
    public static void refreashPureSuccesPackageMethod(ID psID,date refreshdate)
    {
        system.debug('coming');
        list<Pure_Success_Package__c> psp = new list<Pure_Success_Package__c>();
        list<Package_Services__c> ps = new list<Package_Services__c>();
        psp = [select id,Account__c,Order__c,Product_Group__c,Token_Status__c,Product__c,Package_Type__c,Product_Group_Item__c,Service_Contract_No__c,
              Tokens__c,refresh_date__c from Pure_Success_Package__c where id = :psID];
       ps = [select id,Name,Status__c,Product__c,PureSuccess_Package__c,Product_Group__c,Product_Group_Item__c,Case__c,Order__c,Use_Date__c,Buy_Date__c,
          Consume_Date__c from Package_Services__c where PureSuccess_Package__c = :psID];
       list<Package_Services__c> clonedps = new list<Package_Services__c>();
   if(psp[0].Package_Type__c=='Pure Success'){
        Pure_Success_Package__c pspclone =  psp[0].clone(false,true);
       // pspclone.refresh_date__c = psp[0].refresh_date__c.addYears(1);
        pspclone.refresh_date__c = refreshdate;
        insert pspclone; 
        system.debug('pspclone'+pspclone);   
         for(Package_Services__c c :ps)
        {
            Package_Services__c psCopy = c.clone(false,true);
            system.debug('psCopy'+psCopy.Name);
            psCopy.PureSuccess_Package__c = pspclone.Id;
            psCopy.Status__c = 'Allocated';
            clonedps.add(psCopy);
            Package_Services__c psOriginal = new Package_Services__c();
            psOriginal.id = c.Id;
            psOriginal.Status__c = 'Expired';
            clonedps.add(psOriginal);
                       
        }
        system.debug('clonedps'+clonedps.size());
        upsert clonedps;
        //insert clonedps;
}
if(psp[0].Package_Type__c=='A la Carte'){
for(Package_Services__c c :ps)
        {
         Package_Services__c psOriginal = new Package_Services__c();
            psOriginal.id = c.Id;
            psOriginal.Status__c = 'Expired';
            clonedps.add(psOriginal);
                       
        }
        system.debug('clonedps'+clonedps.size());
        update clonedps;
}        
        psp[0].Token_Status__c = 'Expired';
        update psp;
        
    }
    }