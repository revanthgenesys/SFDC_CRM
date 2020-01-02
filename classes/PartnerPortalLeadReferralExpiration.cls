global class PartnerPortalLeadReferralExpiration implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
		Integer noOfDaysToNotifyBefore = 30;
        if(PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig') != NULL)
            noOfDaysToNotifyBefore = (Integer)PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig').No_of_Days_to_Notify_Before_Expire__c;        
		
        Date cutoffDate = Date.Today().addDays(noOfDaysToNotifyBefore);
        String query = 'SELECT Id, Name, Status__c, Account__c, End_Date__c, CreatedDate, OwnerId, Owner.Email '
            		 + ' FROM Lead_Referral_Registration__c '
            		 + ' WHERE Opportunity__c = NULL AND Status__c != \'Expired\' AND End_Date__c = :cutoffDate';
        if(Test.isRunningTest())
            query = query + ' LIMIT 5';
        //System.debug(Database.getQueryLocator(query));
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Integer noOfDaysToNotifyBefore = 30;
        if(PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig') != NULL)
            noOfDaysToNotifyBefore = (Integer)PartnerPortalReferralsExpirationConfig__c.getValues('ReferralsExpirationConfig').No_of_Days_to_Notify_Before_Expire__c;        
        
        String partnerPortalBaseURL = '';
		if(Partner_Portal_Settings__c.getValues('PartnerPortalBaseURL') != NULL)
            partnerPortalBaseURL = (String)Partner_Portal_Settings__c.getValues('PartnerPortalBaseURL').Id_Value__c;                
        
        List<Lead_Referral_Registration__c> recordsToNotify = new List<Lead_Referral_Registration__c>();
        Set<String> accountIdsToNotify = new Set<String>();
        for(sObject so: scope){
            Lead_Referral_Registration__c lrr = (Lead_Referral_Registration__c)so;
            if(lrr.Account__c != NULL){
                recordsToNotify.add(lrr);
                accountIdsToNotify.add(lrr.Account__c);
            }
        }
        
        if(accountIdsToNotify.size() > 0){
            List<Messaging.SingleEmailMessage>  emailMessages = new List<Messaging.SingleEmailMessage>();
            Map<Id, Account> accountDesignatedContacts = new Map<Id, Account>([SELECT id, Name, 
                                                                               	(SELECT id, Name, Email, Designated_Partner_Contact__c 
                                                                                 FROM Contacts 
                                                                                 WHERE Designated_Partner_Contact__c = true AND (NOT Name Like '%Portal%')) 
                                                                               FROM Account 
                                                                               WHERE Id IN :accountIdsToNotify]);
            
            for(Lead_Referral_Registration__c l: recordsToNotify){
                if(accountDesignatedContacts.get(l.Account__c) != NULL){
                    String leadURL = partnerPortalBaseURL + '/partner/LeadReferralRegistration?id='+l.Id+'&ro=true';

                    Account a = accountDesignatedContacts.get(l.Account__c);
                    List<Contact> contacts = a.contacts;
                    String emailSubject = l.Name + ' submitted on ' + l.CreatedDate + ' will expire in ' + noOfDaysToNotifyBefore + ' Days';                
                    String emailBody = '';
                    emailBody += '<html><body><table border="0" cellspacing="0" cellpadding="5">';
                    emailBody += '<tr><td>Hello '+a.Name+',</td></tr>';
                    emailBody += '<tr><td>&nbsp;</td></tr>';
                    emailBody += '<tr><td>';
                    emailBody += 'This note is to inform you that the accepted Referral Lead for, <a href="'+leadURL+'">'+l.Name+'</a>, is due to expire in ' + noOfDaysToNotifyBefore + ' days. ';
                    emailBody += 'Referral Leads are valid for 12 months from original acceptance. ';
                    emailBody += 'If this Referral Lead is still an active pipeline deal, with an expected closed date beyond the next ' + noOfDaysToNotifyBefore + ' days, please contact your Channel Manager to renew Referral Lead registration for up to an additional 6 months. ';
                    emailBody += 'Extension time will be determined by Channel Manager. You will receive an extension notification as appropriate.';
                    emailBody += '</td></tr>';
                    emailBody += '<tr><td></td></tr>';
                    emailBody += '<tr><td>';
                    emailBody += 'Thank you for this Referral Lead and your continued partnership.';
                    emailBody += '</td></tr>';
                    emailBody += '<tr><td>&nbsp;</td></tr>';
                    emailBody += '<tr><td>&nbsp;</td></tr>';
                    emailBody += '<tr><td>Genesys Partner Network</td></tr>';
                    emailBody += '</table></body></html>';
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    Set<String> toAddressesSet = new Set<String>();
                    toAddressesSet.add(l.Owner.Email);
                    for(integer i=0; i< contacts.size(); i++){
                        toAddressesSet.add(contacts[i].Email);
                    }	
                    
                    String[] toAddresses = new String[toAddressesSet.size()];
                    Integer i = 0;
                    for(String e: toAddressesSet){
                        toAddresses[i++] =  e;
                    }	
                    
                    mail.setToAddresses(toAddresses);
                    mail.setPlainTextBody(emailBody);
                    mail.setHtmlBody(emailBody);
                    mail.setSubject(emailSubject);
                    emailMessages.add(mail);
                }				
            }
            if(!Test.isRunningTest())
            	Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
        }      
    }
    
    global void finish(Database.BatchableContext BC){
        // Finished processing for all Partners
    }
}