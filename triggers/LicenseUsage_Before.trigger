trigger LicenseUsage_Before on License_Usage__c (before insert) {
    // The below is used to determine if we should bypass this trigger for Opportunity
    CS_Disable_Triggers__c fireTrigger = CS_Disable_Triggers__c.getInstance('LicenseUsageTrigger');
    
    if (fireTrigger == null || fireTrigger.Flag__c == null || !fireTrigger.Flag__c.equalsIgnoreCase('Disable')) {
        Set<String> itemNumbers = new Set<String>();
        Set<String> licenseIds = new Set<String>();
        for(License_Usage__c lu : Trigger.New){
            itemNumbers.add(lu.ItemNumber__c);
            licenseIds.add(lu.LicenseId__c);
        }
        
        Map<String, String> productAPNNumberProductIdMap = new Map<String, String>();
        for(Product2 p : [SELECT id, APN_Number__c FROM Product2 WHERE APN_Number__c IN :itemNumbers]){
            productAPNNumberProductIdMap.put(p.APN_Number__c, p.Id);    
        }
        Map<String, String> ExternalKeyRequestLogIdMap = new Map<String, String>();
        for(License_Request_Log__c lrl : [SELECT id, Legacy_Id__c, Log_Type__c FROM License_Request_Log__c WHERE Legacy_Id__c IN :licenseIds]){
            String key = lrl.Legacy_ID__c + lrl.Log_Type__c;
            ExternalKeyRequestLogIdMap.put(key, lrl.id);   
        }
        
        for(License_Usage__c lu : Trigger.New){
            if(productAPNNumberProductIdMap.containsKey(lu.ItemNumber__c)){
                lu.Product__c = productAPNNumberProductIdMap.get(lu.ItemNumber__c);
            }
            String key = lu.LicenseId__c + lu.Log_Type__c;
            if(lu.License_Request_Log__c == NULL && ExternalKeyRequestLogIdMap.containsKey(key)){
                lu.License_Request_Log__c = ExternalKeyRequestLogIdMap.get(key);
            }
        }
    }
}