trigger CaseAfterInsert on Case (after insert){
 
if(Util.Bypass_Trigger_Chk)return;

Util.MyLog('## >>> Case After insert <<< run by ' + UserInfo.getName());
        //AP05 :  (MB 10/02/2011) Case creator is added to CaseTeam
    if(Util.canTrigger('AP05'))
    {   
     Case [] CaseToTreat =new Case[]{};   
      
      for(Integer i = (Trigger.new.size()-1); i >=0 ; i--) 
      {
            Util.MyLog('## CaseId:'+ Trigger.new[i].Id);
            Util.MyLog('## RequesterId:'+ Trigger.new[i].CreatedById);
            CaseToTreat.add(Trigger.new[i]);      
      }           
        if(CaseToTreat.size()>0)
        {   
            AP05Case.AddRequesterToCaseTeamReadAccess(CaseToTreat);
        }  
    }      
}