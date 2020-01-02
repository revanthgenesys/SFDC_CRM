trigger EntitlementMain on Entitlement (before insert, before update, before delete, after insert, after update, after delete) {
    if(Util.Bypass_Trigger_Chk)return;
    if(Trigger.isBefore && Trigger.isInsert){
        Entitlement ent = trigger.new[0];
        if(ent.AccountId == null){
        	Account tempAcc = [SELECT id FROM ACCOUNT limit 1];
        	if(tempAcc != null)
            	ent.AccountId = tempAcc.id; 
        }
    }
}