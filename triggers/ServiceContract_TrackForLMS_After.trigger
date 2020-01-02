trigger ServiceContract_TrackForLMS_After on ServiceContract (after insert, after update, after delete) {
	if(Util.Bypass_Trigger_Chk)
        return;
    if(Trigger.isAfter && Trigger.isInsert){
 		LicenseSnapshotUtil.trackServiceContractForSnapshot(Trigger.New);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        LicenseSnapshotUtil.trackServiceContractForSnapshot(Trigger.New, Trigger.Old);
    }
    if(Trigger.isAfter && Trigger.isDelete){     
        LicenseSnapshotUtil.trackServiceContractForSnapshot(Trigger.Old);
    }
}