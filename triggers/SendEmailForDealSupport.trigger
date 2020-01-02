trigger SendEmailForDealSupport on Note (after insert) 
{
    Note objNote = Trigger.new[0];
    if(String.valueOf(objNote.ParentId).startsWith(Deal_Support__c.sObjectType.getDescribe().getKeyPrefix()))
    {
        Deal_Support__c objDS = [SELECT Requester__r.Email,Support_Email__c,Support_Email2__c,Support_Area__c FROM Deal_Support__c
                                    WHERE Id = :objNote.ParentId];
         If(objDS.Support_Area__c == 'Sales Ops' || objDS.Support_Area__c == 'Professional Services')
         return;                           
                                    
        List<String> list_EmailIds = new List<String>();
        if(String.isNotBlank(objDS.Requester__r.Email))
            list_EmailIds.add(objDS.Requester__r.Email);
        if(String.isNotBlank(objDS.Support_Email__c))
            list_EmailIds.add(objDS.Support_Email__c);
        if(String.isNotBlank(objDS.Support_Email2__c))
            list_EmailIds.add(objDS.Support_Email2__c);
        
        if(list_EmailIds.size() > 0)
        {
            List<Messaging.SingleEmailMessage> list_Emails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(Label.New_Note_Temlate_Id);
            msg.setWhatId(objNote.ParentId);
            msg.setTargetObjectId(Label.Dummy_Contact_Id);
            msg.setToAddresses(list_EmailIds);
            msg.setCcAddresses(new List<String>{Label.Email_Parsing_Address});
            list_Emails.add(msg);
            // Send the emails in a transaction, then roll it back
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(list_Emails);
            Database.rollback(sp);
            // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
            // contents to a new SingleEmailMessage. Then send those new messages.
            List<Messaging.SingleEmailMessage> list_EmailsToSend = new List<Messaging.SingleEmailMessage>();
            for (Messaging.SingleEmailMessage email : list_Emails) 
            {
                Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                emailToSend.setToAddresses(email.getToAddresses());
                emailToSend.setCcAddresses(email.getCcAddresses());
                emailToSend.setPlainTextBody(email.getPlainTextBody());
                emailToSend.setHTMLBody(email.getHTMLBody());
                emailToSend.setSubject(email.getSubject());
                list_EmailsToSend.add(emailToSend);
            }
            Messaging.sendEmail(list_EmailsToSend);
        }
    }
}