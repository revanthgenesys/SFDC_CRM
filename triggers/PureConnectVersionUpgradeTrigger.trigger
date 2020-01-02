trigger PureConnectVersionUpgradeTrigger on Pure_Connect_Version_Upgrade__c (before insert, before update) {
    Set<String> partNumbers = new Set<String>();
    for(Pure_Connect_Version_Upgrade__c  pcvu : Trigger.NEW){
        if(pcvu.Old_Part_Number__c != NULL)
        	partNumbers.add(pcvu.Old_Part_Number__c);   
        if(pcvu.New_Part_Number__c != NULL)
        	partNumbers.add(pcvu.New_Part_Number__c);    
    }
    
    Map<String, String> productsMap = new Map<String, String>();
    for(Product2 P : [SELECT id, APN_Number__c, Product_Name__c FROM Product2 WHERE APN_Number__c IN :partNumbers]){
        productsMap.put(p.APN_Number__c, p.Id);    
    }
    
    for(Pure_Connect_Version_Upgrade__c  pcvu : Trigger.NEW){
        if(pcvu.Old_Part_Number__c != NULL)
        	pcvu.Old_Product__c = productsMap.get(pcvu.Old_Part_Number__c); 
        if(pcvu.New_Part_Number__c != NULL)
        	pcvu.New_Product__c = productsMap.get(pcvu.New_Part_Number__c);    
    }
}