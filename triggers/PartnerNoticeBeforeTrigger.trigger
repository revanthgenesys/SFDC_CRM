trigger PartnerNoticeBeforeTrigger on Partner_Notice_of_Non_Renewal__c (before insert) {

    Set<String> emailAddresses = new Set<String>();
    for(Partner_Notice_of_Non_Renewal__c pn: Trigger.NEW){
    	emailAddresses.add(pn.Email__c);	    
    }
    
    Map<String, Contact> contactsMap = new Map<String, Contact>();
    for(Contact c : [SELECT id, Name, Email, AccountId FROM Contact WHERE EMail IN :emailAddresses]){
        String Key = c.Email + '#' + c.AccountId;
    	contactsMap.put(Key.toLowerCase(), c);    
    }
    
    List<Contact> contactsToCreate = new List<Contact>();
    RecordType contactRT = [SELECT id, Name FROM RecordType WHERE Name = 'EMG - Customer / Prospect Contact Record Type' LIMIT 1];
        
    for(Partner_Notice_of_Non_Renewal__c pn: Trigger.NEW){
        String Key = pn.Email__c + '#' + pn.Account__c;
        Key = Key.toLowerCase();
        if(!contactsMap.containsKey(key)){
       		contactsToCreate.add(new Contact(FirstName = pn.FirstName__c, 
                                             LastName = pn.LastName__c, 
                                             Email = pn.Email__c, 
                                             AccountId = pn.Account__c, 
                                             DecisionRole__c = 'Other', 
                                             Title = 'Unknown', 
                                             Persona__c ='', 
                                             Status__c = 'Active',
                                             RecordTypeId = contactRT.Id));     
        }
    }
    
    if(contactsToCreate.size() > 0){
        Database.insert(contactsToCreate);
        for(Contact c : contactsToCreate){
        	String Key = c.Email + '#' + c.AccountId;
    		contactsMap.put(Key.toLowerCase(), c);    
    	}
    }
    
    for(Partner_Notice_of_Non_Renewal__c pn: Trigger.NEW){
        String Key = pn.Email__c + '#' + pn.Account__c;
        Key = Key.toLowerCase();
        if(contactsMap.containsKey(key)){
            pn.Contact__c = contactsMap.get(key).Id;
        } 
    }
}