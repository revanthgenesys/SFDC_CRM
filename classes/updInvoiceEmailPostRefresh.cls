global class updInvoiceEmailPostRefresh implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'Select id, Email1__c, Email2__c, Email3__c, Email4__c, Email5__c, Email6__c, Email7__c, Email8__c, Email9__c, Email10__c from invoice__c';
        string query2 = ' where Email1__c != \'\' or  Email2__c != \'\' or  Email3__c != \'\' or  Email4__c != \'\' or  Email5__c != \'\' or  Email6__c != \'\' or  Email7__c != \'\' or  Email8__c != \'\' or  Email9__c != \'\' or  Email10__c != \'\'';
        System.Debug('query--->'+query);
        return Database.getQueryLocator(query+query2);
    }
    
    global void execute(Database.BatchableContext bc, List<invoice__c> scope){
    
        List<invoice__c> invoiceRecs = (List<invoice__c>)scope;
        
        for(invoice__c eachRec : invoiceRecs){
            if(eachRec.Email1__c != '' && eachRec.Email1__c != null)
                eachRec.Email1__c += '.sandbox';
            if(eachRec.Email2__c != '' && eachRec.Email2__c != null)
                eachRec.Email2__c += '.sandbox';
            if(eachRec.Email3__c != '' && eachRec.Email3__c != null)
                eachRec.Email3__c += '.sandbox';
            if(eachRec.Email4__c != '' && eachRec.Email4__c != null)
                eachRec.Email4__c += '.sandbox';
            if(eachRec.Email5__c != '' && eachRec.Email5__c != null)
                eachRec.Email5__c += '.sandbox';
            if(eachRec.Email6__c != '' && eachRec.Email6__c != null)
                eachRec.Email6__c += '.sandbox';
            if(eachRec.Email7__c != '' && eachRec.Email7__c != null)
                eachRec.Email7__c += '.sandbox';
            if(eachRec.Email8__c != '' && eachRec.Email8__c != null)
                eachRec.Email8__c += '.sandbox';
            if(eachRec.Email9__c != '' && eachRec.Email9__c != null)
                eachRec.Email9__c += '.sandbox';
            if(eachRec.Email10__c != '' && eachRec.Email10__c != null)
                eachRec.Email10__c += '.sandbox';
        }
        
        update invoiceRecs;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}