global class BatchUpdateContactOfferingType implements Database.Batchable<sObject>{
    public Set<Id> set_AccountId;
    
    public BatchUpdateContactOfferingType(){
        // Do Nothing
    }
    
    public BatchUpdateContactOfferingType(Set<Id> set_AccountIdPassed){
        set_AccountId = set_AccountIdPassed;
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Primary_offering__c, Additional_Offering__c, Account.Offering_Type__c FROM Contact WHERE AccountId IN :set_AccountId';
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC, List<Contact> scope){        
        List<Contact> list_ContactToUpdate = new List<Contact>();
        for(Contact con : scope){
            String offeringType = con.Account.Offering_Type__c;
            if(offeringType.indexOf(';') == -1){
                con.Primary_offering__c = offeringType;
            }
            else{
                con.Primary_offering__c = offeringType.subString(0, offeringType.indexOf(';'));
                con.Additional_Offering__c = offeringType.subString(offeringType.indexOf(';')+1);
            }
            list_ContactToUpdate.add(con); 
        }
        update list_ContactToUpdate;
    }
    
    
    global void finish(Database.BatchableContext BC){
        // Do nothing
    }
}