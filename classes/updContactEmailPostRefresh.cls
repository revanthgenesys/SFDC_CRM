global class updContactEmailPostRefresh implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'Select id, email, Alternate_Email__c from contact where ((email != \'\' AND email != null) or (Alternate_Email__c != \'\' AND Alternate_Email__c != null))';
        string query2 = ' AND (NOT email like \'%sandbox%\') AND (NOT Alternate_Email__c like \'%sandbox%\')';
        System.Debug('query--->'+query);
        return Database.getQueryLocator(query+query2);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope){
    
        List<Contact> contcts = (List<Contact>)scope;
        
        for(contact eachRec : contcts){
            if(!eachRec.email.containsIgnoreCase('sandbox')){
                eachRec.email += '.sandbox';
            }
            if(eachRec.Alternate_Email__c != '' && eachRec.Alternate_Email__c != null && !eachRec.Alternate_Email__c.containsIgnoreCase('sandbox')){
                eachRec.Alternate_Email__c += '.sandbox';
            }
        }
        
        update contcts;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}