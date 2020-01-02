global class PartnerNoticeOfNonRenewalBatch implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT id, Account__c, Account__r.Channel_Manager__c, Account__r.Channel_Manager__r.Email, '
                     + 'Contact__c, Email_Template__c, Processed__c FROM Partner_Notice_of_Non_Renewal__c WHERE Processed__c = false';
        if(Test.isRunningTest()){
            query = query + ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc , List<sObject> scope){
        
        Map<String, String> emailTemplatesMap = new Map<String, String>();
        for(EmailTemplate et : [Select id, Name FROM EmailTemplate WHERE Name IN ('Partner Notice of Non-Renewal Standard','Partner Notice of Non-Renewal Non-Standard')]){
            emailTemplatesMap.put(et.Name.toLowerCase(), et.Id);                
        }
                                
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(sObject so: scope){
            Partner_Notice_of_Non_Renewal__c pn = (Partner_Notice_of_Non_Renewal__c)so; 
            String[] CCEmails = new List<String>();
            CCEmails.add('partners@genesys.com');
            CCEmails.add('Prabhuram.Doraiswamy@genesys.com');
            CCEmails.add('narasimha@dasincusa.com');
            if(String.isNotBlank(pn.Account__r.Channel_Manager__r.Email)){
                CCEmails.add(pn.Account__r.Channel_Manager__r.Email);
            }
            Messaging.SingleEmailMessage externalMail = new Messaging.SingleEmailMessage(); 
            externalMail.setTemplateId(emailTemplatesMap.get(pn.Email_Template__c.toLowerCase()));
            externalMail.setSaveAsActivity(true);
            externalMail.setOrgWideEmailAddressId('0D2U0000000PBXV');
            externalMail.setreplyto('partners@genesys.com');
            //externalMail.setSenderDisplayName('Genesys Partner Network');
            externalMail.setWhatId(pn.Account__c); //Object Id
            externalMail.setTargetObjectId(pn.Contact__c); //contactid Lead or Userid
            externalMail.setCCAddresses(CCEmails);
            emailList.add(externalMail);                
            pn.Processed__c = true;
        }
        
        if(emailList.size() > 0 && !Test.isRunningTest()){
            Messaging.sendEmail(emailList);
        }
        Database.update(scope);
    }
    
    global void finish(Database.BatchableContext bc){
        // completed clean up ...   
    }
}