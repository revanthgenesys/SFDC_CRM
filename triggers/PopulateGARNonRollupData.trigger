trigger PopulateGARNonRollupData on Rolled_Up_Usage_Data__c (before insert,before update) 
{
	// On insert : GARN needs to be populated for all records
    if(Trigger.isInsert)
    {
        // ETL feeds 'X' for null values so setting explicitly to null for better representation of data in SFDC
        for(Rolled_Up_Usage_Data__c objRollUpData : Trigger.new)
        {
            if(objRollUpData.Device_Steering_Digits__c == 'X')
				objRollUpData.Device_Steering_Digits__c = null;
        }
       CloudBillingUtil.populateGARNCodesFromCloudDeployment(Trigger.new); 
    }
    // On update : GARN needs to be populated only for those records whose Platform Id has changed
    else
    {
        List<Rolled_Up_Usage_Data__c> list_RolledUpUsageData = new List<Rolled_Up_Usage_Data__c>();
        for(Rolled_Up_Usage_Data__c objRollUpData : Trigger.new)
        {
            if(Trigger.oldMap.get(objRollUpData.Id).Platform_Id__c != objRollUpData.Platform_Id__c)
            	list_RolledUpUsageData.add(objRollUpData);
        }
        
        if(!list_RolledUpUsageData.isEmpty())
            CloudBillingUtil.populateGARNCodesFromCloudDeployment(list_RolledUpUsageData);
    }    
}