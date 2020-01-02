trigger ContractLineItem_TrackForLMS_After on ContractLineItem (after update, after delete, after undelete) {
    if(Util.Bypass_Trigger_Chk) 
        return;
    if(Trigger.isUpdate && Trigger.isAfter){
        LicenseSnapshotUtil.trackServiceContractLineItemForSnapshot(Trigger.New, Trigger.Old);
    }
    if(Trigger.isDelete && Trigger.isAfter){
    	LicenseSnapshotUtil.trackServiceContractLineItemForSnapshot(Trigger.Old);
    }
    if(Trigger.isUndelete && Trigger.isAfter){
    	LicenseSnapshotUtil.trackServiceContractLineItemForSnapshot(Trigger.New);
    }
}