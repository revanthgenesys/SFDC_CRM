global class PartnerComplianceNotificationBatch implements Database.Batchable<sObject>{
  
    global Boolean isTestFire;
    global List<String> emailAddresses;

    public PartnerComplianceNotificationBatch(Boolean isTestFire, List<String> emailAddresses) {
        this.isTestFire = isTestFire;
        this.emailAddresses = emailAddresses;
    }
  
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT id, Name, Account__c, Account_Name__c, Email_Template__c, Processed__c,Bookings_Target__c FROM Partner_Notification__c WHERE Processed__c = false';
        if(Test.isRunningTest()){
            query = query + ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc , List<sObject> scope){
    
        List<Contact> contactsToDelete = new List<Contact>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(sObject so: scope){
            Partner_Notification__c pn = (Partner_Notification__c)so; 
            String[] CCEmails = new List<String>();
            CCEmails.add('partners@genesys.com');
            EmailTemplate[] pt = new List <EmailTemplate>();
            pt = [Select id, Name FROM EmailTemplate WHERE Name = :pn.Email_Template__c]; 
            EmailTemplate et = [Select id, Name FROM EmailTemplate WHERE Name = :pn.Email_Template__c];
            if(isTestFire == false && pt.size()>0){
                for(Contact eachContact : [SELECT id, Name, accountId, account.Channel_Manager__c, account.Channel_Manager__r.Email 
                                       FROM Contact WHERE accountId =:pn.Account__c and FirstName != 'Portal' and Designated_Partner_Contact__c = true])
                {
                    if(String.isNotBlank(eachContact.account.Channel_Manager__r.Email)){
                        CCEmails.add(eachContact.account.Channel_Manager__r.Email);
                    }
                
                    Messaging.SingleEmailMessage externalMail = new Messaging.SingleEmailMessage(); 
                    externalMail.setTemplateId(et.id);
                    externalMail.setSaveAsActivity(false);
                    externalMail.setreplyto('partners@genesys.com');
                    externalMail.setSenderDisplayName('partners@genesys.com');
                   // externalMail.setWhatId(eachContact.accountId); //Object Id
                    externalMail.setWhatId(pn.ID);
                    externalMail.setTargetObjectId(eachContact.Id); //contactid Lead or Userid
                    if(CCEmails.size() > 0)
                        externalMail.setCCAddresses(CCEmails);
                    emailList.add(externalMail);                
                }
           }
           if(isTestFire == true && pt.size()>0){
               //Create contact
               Contact c = new Contact(FirstName = 'testFirst', Lastname = 'testLast', AccountId = pn.Account__c, HomePhone = '1236547890', MobilePhone = '9012345678',
                                        MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                        Designated_Partner_Contact__c=true,  Email=emailAddresses[0]);
               insert c;
               
               Messaging.SingleEmailMessage externalMail = new Messaging.SingleEmailMessage(); 
               externalMail.setTemplateId(et.id);
               externalMail.setSaveAsActivity(false);
               externalMail.setreplyto('partners@genesys.com');
               externalMail.setSenderDisplayName('partners@genesys.com');
               externalMail.setWhatId(pn.ID); //Object Id
               externalMail.setTargetObjectId(c.Id); //contactid Lead or Userid
               if(emailAddresses.size() > 1){
                   for(integer i=1; i < emailAddresses.size(); i++){
                       CCEmails.add(emailAddresses[i]);  
                   }            
               }

               if(CCEmails.size() > 0)
                    externalMail.setCCAddresses(CCEmails);
               emailList.add(externalMail); 
               contactsToDelete.add(c); 
           }
           pn.Processed__c = true; 
        }
        if(emailList.size() > 0 && !Test.isRunningTest()){
            Messaging.sendEmail(emailList);
        }
        if(contactsToDelete.size() > 0)
            Database.delete(contactsToDelete);
        Database.update(scope);
    }
    
    global void finish(Database.BatchableContext bc){
        // completed clean up ...   
    }
}