trigger ValidatePercentageReferralFee on Lead_Referral_Registration__c (before update) {
    
    List<ProcessInstance> processInstanceList = [SELECT Id,TargetObjectid, Status,
                                              (select id,StepStatus,ActorId,OriginalActorId from stepsandworkitems)
                                              FROM ProcessInstance where TargetObjectId IN : Trigger.NewMap.KeySet()];
    //Map<Id, ProcessInstance> processInstanceMap = new Map<Id, ProcessInstance>();
    /*for(ProcessInstance pi: processInstanceList){
        processInstanceMap.put(pi.TargetObjectid, pi);
    }*/
    
    map<Id,set<id>> procInsActorsID = new map<Id,set<id>>();
    for(ProcessInstance pi:processInstanceList){
        for(ProcessInstanceHistory SWI:pi.StepsAndWorkitems){
            if(procInsActorsID.containsKey(pi.TargetObjectid)){
                procInsActorsID.get(pi.TargetObjectid).add(SWI.ActorId);
                procInsActorsID.get(pi.TargetObjectid).add(SWI.OriginalActorId);
            }
            else{
                procInsActorsID.put(pi.TargetObjectid,new  Set<Id>{SWI.ActorId});
                procInsActorsID.get(pi.TargetObjectid).add(SWI.OriginalActorId);
            }
        }       
    }
    System.Debug('procInsActorsID--->'+procInsActorsID);
    
    Map<Id, Profile> overrideProfilesMap = new Map<Id, Profile>([SELECT id, Name from Profile WHERE Name IN ('System Administrator')]);
    
    for(Lead_Referral_Registration__c lrr : Trigger.NEW){
        // Perform the validation 
        // 1. only there is a change in the Percentage_Referral_Fee__c
        // 2. User editing the record not in Allowed Profiles to Edit Percentage_Referral_Fee__c
        if(lrr.Percentage_Referral_Fee__c != Trigger.OldMap.get(lrr.Id).Percentage_Referral_Fee__c && !overrideProfilesMap.containsKey(UserInfo.getProfileId())){
            if(lrr.Status__c == 'Approved'){
                lrr.addError('Percentage Referral Fee can not be adjusted or overridden, Please contact Administrator!');
            }
            if(lrr.Status__c == 'Request Pending'){
                if(procInsActorsID.size()>0){
                    if(procInsActorsID.get(lrr.Id).size()>0){
                        //ProcessInstance currentPI = processInstanceMap.get(lrr.Id);
                        if(UserInfo.getUserId() != '005U0000000dwSnIAI'){
                            if(!procInsActorsID.get(lrr.Id).contains(UserInfo.getUserId())){
                                lrr.addError('Percentage Referral Fee can not be adjusted or overridden, Please contact Administrator!');
                            }                         
                        }
                    }
                }    
            }
        }
    }
}