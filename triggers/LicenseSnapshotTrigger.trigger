trigger LicenseSnapshotTrigger on License_Snapshot__c (after insert, before update) {
	// The below is used to determine if we should bypass this trigger for Opportunity
    CS_Disable_Triggers__c fireTrigger = CS_Disable_Triggers__c.getInstance('LicenseSnapshotTrigger');
    
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
	    Set<String> SoldToEndUserSet = new Set<String>();
	    for(License_Snapshot__c lss : Trigger.New){
	        SoldToEndUserSet.add((String)lss.Sold_To__c + (String)lss.End_User__c); 
	    }
	    Map<String, String> SoldToEndUserSnapReasonMap = new Map<String, String>();
	    for(License_Snapshot_Sold_To_End_User__c lsse : [SELECT Sold_To_End_User__c, Snapshot_Reason__c FROM License_Snapshot_Sold_To_End_User__c WHERE Sold_To_End_User__c IN :SoldToEndUserSet]){
	        SoldToEndUserSnapReasonMap.put(lsse.Sold_To_End_User__c, (lsse.Snapshot_Reason__c == NULL || lsse.Snapshot_Reason__c == '') ? 'Initial Snapshot' : lsse.Snapshot_Reason__c);
	    }
	    
	    List<License_Snapshot_Change__c> changeRecords = new List<License_Snapshot_Change__c>();
	    if(Trigger.isInsert){
	        for(License_Snapshot__c lss : Trigger.New){
	            changeRecords.add(new License_Snapshot_Change__c(
	                                        License_Snapshot__c = lss.Id,
	                                        Change_Date__c = Date.Today(),
	                                        Change_Type__c = SoldToEndUserSnapReasonMap.get((String)lss.Sold_To__c + (String)lss.End_User__c),
	                                        Perpetual__c =(lss.Perpetual__c != NULL ? lss.Perpetual__c : 0),
	                                        Non_Perpetual__c = (lss.Non_Perpetual__c != NULL ? lss.Non_Perpetual__c : 0)
	                                    )
	                             );
	        }
	    }
	    if(Trigger.isUpdate){
	        for(License_Snapshot__c lss : Trigger.New){
	            if(lss.Perpetual__c != Trigger.OldMap.get(lss.Id).Perpetual__c || lss.Non_Perpetual__c != Trigger.OldMap.get(lss.Id).Non_Perpetual__c){
	                changeRecords.add(new License_Snapshot_Change__c(
	                                            License_Snapshot__c = lss.Id,
	                                            Change_Date__c = Date.Today(),
	                                            Change_Type__c = SoldToEndUserSnapReasonMap.get((String)lss.Sold_To__c + (String)lss.End_User__c),
	                                            Perpetual__c = (lss.Perpetual__c != NULL ? lss.Perpetual__c : 0) - (Trigger.OldMap.get(lss.Id).Perpetual__c != NULL ? Trigger.OldMap.get(lss.Id).Perpetual__c : 0),
	                                            Non_Perpetual__c = (lss.Non_Perpetual__c != NULL ? lss.Non_Perpetual__c : 0)- (Trigger.OldMap.get(lss.Id).Non_Perpetual__c != NULL ? Trigger.OldMap.get(lss.Id).Non_Perpetual__c : 0)
	                                        )
	                                 );
	            }
	        }
	    }
	    Database.insert(changeRecords, false);
    }
}