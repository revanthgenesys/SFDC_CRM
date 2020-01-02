global class PartnerPortalOpportunityExpiration implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    	Integer noOfDaysToNotifyBefore = 30;
        if(PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig') != NULL)
            noOfDaysToNotifyBefore = (Integer)PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig').No_of_Days_to_Notify_Before_Expire__c;        
    
        Date cutoffDate = Date.Today().addDays(noOfDaysToNotifyBefore);
        String query = 'SELECT Id, Name, Status__c, Account__c, Account__r.Name, End_Date__c, CreatedDate, OwnerId, Owner.Email, Opportunity_Channel_Manager__r.Email, Primary_Contact__r.Email '
                 + ' FROM partner_portal_prospect__c '
                 + ' WHERE Opportunity_Stage__c != \'6.Closed\' AND Status__c = \'Approved\' AND End_Date__c = :cutoffDate';
        System.Debug('query--->'+query);
        if(Test.isRunningTest())
            query = query + ' LIMIT 5';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Integer noOfDaysToNotifyBefore = 30;
        if(PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig') != NULL)
            noOfDaysToNotifyBefore = (Integer)PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig').No_of_Days_to_Notify_Before_Expire__c;        
            
        String partnerPortalBaseURL = '';
    	if(Partner_Portal_Settings__c.getValues('PartnerPortalBaseURL') != NULL)
            partnerPortalBaseURL = (String)Partner_Portal_Settings__c.getValues('PartnerPortalBaseURL').Id_Value__c;                
        
        Set<String> accountIdsToNotify = new Set<String>();
        List<Partner_Portal_Prospect__c> recordsToNotify = new List<Partner_Portal_Prospect__c>();
        for(sObject so: scope){
            Partner_Portal_Prospect__c ppp = (Partner_Portal_Prospect__c)so;
            if(ppp.Account__c != NULL){
        		accountIdsToNotify.add(ppp.Account__c);
                recordsToNotify.add(ppp);
            }
        }
        //if(accountIdsToNotify.size() > 0){
            List<Messaging.SingleEmailMessage>  emailMessages = new List<Messaging.SingleEmailMessage>();
            
            //Map<Id, Account> accountDesignatedContacts = new Map<Id, Account>([SELECT id, Name, 
            //                                                                     (SELECT id, Name, Email, Designated_Partner_Contact__c 
            //                                                                     FROM Contacts 
            //                                                                     WHERE Designated_Partner_Contact__c = true AND (NOT Name Like '%Portal%')) 
            //                                                                   FROM Account 
            //                                                                   WHERE Id IN :accountIdsToNotify]);
            
            for(Partner_Portal_Prospect__c p: recordsToNotify){
                //if(accountDesignatedContacts.get(p.Account__c) != NULL){
                    String oppURL = partnerPortalBaseURL + '/partner/PartnerPortalOppRegistration_Page?id='+p.Id+'&ro=true';
                    //Account a = accountDesignatedContacts.get(p.Account__c);
                    //List<Contact> contacts = a.contacts;
                    String emailSubject = p.Name + ' submitted on ' + p.CreatedDate + ' will expire in ' + noOfDaysToNotifyBefore + ' Days';                
                    String emailBody = '';
                    emailBody += '<html><body><table border="0" cellspacing="0" cellpadding="5">';
                    // emailBody += '<tr><td>Hello '+a.Name+',</td></tr>';
                    emailBody += '<tr><td>Hello '+p.Account__r.Name+',</td></tr>';
                    emailBody += '<tr><td>&nbsp;</td></tr>';
                    emailBody += '<tr><td>';
                    emailBody += 'This note is to inform you that the accepted Opportunity Registration for, <a href="'+oppURL+'">'+p.Name+'</a>, is due to expire in ' + noOfDaysToNotifyBefore + ' days. ';
                    emailBody += 'Opportunity Registrations are valid for 12 months from original acceptance. ';
                    emailBody += 'If this Opportunity Registration is still an active pipeline deal, with an expected closed date beyond the next ' + noOfDaysToNotifyBefore + ' days, please go to your Partner Portal and locate the deal registration. Click the button "Request Expiration Extension".';
                    emailBody += 'All extensions requests will go through approvals. You will receive a notification with the confirmation/rejection of the request.';
                    emailBody += '</td></tr>';
                    emailBody += '<tr><td></td></tr>';
                    emailBody += '<tr><td>';
                    emailBody += 'Thank you for this Opportunity Registration and your continued partnership.';
                    emailBody += '</td></tr>';
                    emailBody += '<tr><td>&nbsp;</td></tr>';
                    emailBody += '<tr><td>&nbsp;</td></tr>';
                    emailBody += '<tr><td>Regards,</td></tr>';
                    emailBody += '<tr><td>Partner Program Team</td></tr>';
                    emailBody += '</table></body></html>';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    Set<String> toAddressesSet = new Set<String>();
                    toAddressesSet.add(p.Owner.Email);
                    
                    //for(integer i=0; i< contacts.size(); i++){
                    //    toAddressesSet.add(contacts[i].Email);
                    //}  
                    
                    String[] toAddresses = new String[toAddressesSet.size()];
                    Integer i = 0;
                    for(String e: toAddressesSet){
                        toAddresses[i++] =  e;
                    }
                    
                    list<string> chnlMgrEmail = new list<string>();
                    chnlMgrEmail.add(p.Opportunity_Channel_Manager__r.Email);
                    
                    
                    mail.setToAddresses(toAddresses);
                    mail.setCcAddresses(chnlMgrEmail);
                    mail.setPlainTextBody(emailBody);
                    mail.setHtmlBody(emailBody);
                    mail.setSubject(emailSubject);
                    emailMessages.add(mail);
                //}
            }     
            if(!Test.isRunningTest())
              Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
        //}      
    }

    global void finish(Database.BatchableContext BC){
        // Finished processing for all Partners
    }
}