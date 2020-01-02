//Naresh Kumar  05/04/2019
global class OrderAcknowledgeEmailBatch implements Database.Batchable<SObject>,  Database.Stateful {
    
    Map<Id, String> mapOfSentIdsVsEmailContent = new Map<Id, String>();
    Map<Id, List<String>> mapOfSentIdsVsRecipients = new Map<Id, List<String>>();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Order__c, Order__r.Owner.Email,order__r.Opportunity_Type__c,order__r.Order_Category__c FROM Order_Acknowledge_Email__c WHERE Email_Status__c =\'Pending\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order_Acknowledge_Email__c> listOfEmails) {
        try{
            Messaging.reserveSingleEmailCapacity(Integer.valueOf(Label.Email_Reserve_Threshold));
            EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Order_Acknowledge_Email_Template'];
            List<Messaging.SingleEmailMessage> listOfMails = new List<Messaging.SingleEmailMessage>();
            
            //Contact objContact = new Contact(id=Label.Temp_Contact_Id_To_Send_Emails);
            Map<Id, Order__c> mapOfOrderIdVsOrder = OrderAcknowledgeEmailTemplateController.getEmailRecipients(listOfEmails);
            //OrgWideEmailAddress owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Order Address'];
            for(Order_Acknowledge_Email__c eachEmail : listOfEmails){
                Order__c objOrder = mapOfOrderIdVsOrder.get(eachEmail.Order__c);
                if(objOrder == null)
                    continue;
                //Id primaryContactId1 = objOrder.id;
             //  Id primaryContactId = objOrder.Opportunity__r.Contact__c; 
                Id primaryContactId = objOrder.Opportunity__r.Ownerid;                            
               system.debug('primaryContactId1' + primaryContactId);
              
              
               if(primaryContactId == null && !Test.isRunningTest())
                   continue;
                                                                 
                
                List<String> listOfCCAddresses = new List<String>();
                if(objOrder.CreatedBy.Email != null)
                    listOfCCAddresses.add(objOrder.CreatedBy.Email);
                if(objOrder.Opportunity__r.Owner.Email != null)
                    listOfCCAddresses.add(objOrder.Opportunity__r.Owner.Email);
                if(objOrder.End_User_Name__r.CSM_Account_Owner__r.Email != null)
                    listOfCCAddresses.add(objOrder.End_User_Name__r.CSM_Account_Owner__r.Email);
                if(objOrder.End_User_Name__r.CSM_Account_Owner__r.Email != null)
                    listOfCCAddresses.add(objOrder.End_User_Name__r.CSM_Account_Owner__r.Email);
                    
                if(objOrder.Order_Acknowledgement_Email__c != null)
                    listOfCCAddresses.add(objOrder.Order_Acknowledgement_Email__c);
             
                 for(Account_Order_Address__c ordadd : objOrder.Account_Order_Addresses__r){
                    if(ordadd.Email__C != null){
               // if(objOrder.Account_Order_Addresses__r[0].Email__C != null)
                        listOfCCAddresses.add(ordadd.Email__C);}
                } 
        system.debug('listOfCCAddresses navanee' + listOfCCAddresses);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                        
                for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]){
                system.debug('objOrder.Region__c' + objOrder.Region__c);
                        
                            if(owa.DisplayName.contains('Genesys Order AcknowledgementNA') && (objOrder.Region__c == 'North America'))
                            {
                                mail.setOrgWideEmailAddressId(owa.id);
                                 system.debug('objOrder.Region__c' + objOrder.Region__c);
                                
                            } else if (owa.DisplayName.contains('Genesys Order Acknowledgement EMEA') && (objOrder.Region__c == 'EMEA'))
                            {
                                mail.setOrgWideEmailAddressId(owa.id);
                                 system.debug('objOrder.Region__c' + objOrder.Region__c);
                                
                            }else if (owa.DisplayName.contains('Genesys Order Acknowledgement LATAM') && (objOrder.Region__c == 'LATAM'))
                            {
                                mail.setOrgWideEmailAddressId(owa.id);
                                 system.debug('objOrder.Region__c' + objOrder.Region__c);
                                
                            }else if (owa.DisplayName.contains('Genesys Order Acknowledgement APAC') && (objOrder.Region__c == 'APAC'))
                            {
                                mail.setOrgWideEmailAddressId(owa.id);
                                system.debug('objOrder.Region__c' + objOrder.Region__c);
                                
                            }
                        }
                
                mail.setWhatId(eachEmail.Order__c);        
                mail.setTemplateId(template.id);
                mail.setTargetObjectId(primaryContactId);
                
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new list<string>{objOrder.Opportunity__r.Owner.email});
                system.debug('testmmmm');
                //Need to add more recipients
                //String[] toAddresses = new String[]{'nareshk.it@gmail.com'};
                //String[] toAddresses = new String[]{'vikram.sharma@genesys.com','wendy.coffey@genesys.com','vinay.ravula@genesys.com'};// {eachEmail.Order__r.Owner.Email};
                //mail.setToAddresses(toAddresses);
                if(!listOfCCAddresses.isEmpty())
                    mail.setCcAddresses(listOfCCAddresses);
                    
                listOfMails.add(mail);
                mail = Messaging.renderStoredEmailTemplate(template.id, null, eachEmail.Order__c);
              //  mail = Messaging.SingleEmailMessage();  
                mapOfSentIdsVsEmailContent.put(eachEmail.id, mail.gethtmlBody());
                listOfCCAddresses.add(primaryContactId);
                mapOfSentIdsVsRecipients.put(eachEmail.id, listOfCCAddresses);
            }
            Messaging.sendEmail(listOfMails);
           // Messaging.SingleEmailMessage(listOfMails);
        }
        catch(Exception ex){
            for(Order_Acknowledge_Email__c eachEmail : listOfEmails){
                eachEmail.Error_s_If_any__c = ex.getMessage() + ex.getLineNumber();
            }
            update listOfEmails;
        }
        
    }   
    
    global void finish(Database.BatchableContext BC){
        List<Order_Acknowledge_Email__c> listOfEmailsToBeUpdated = new List<Order_Acknowledge_Email__c>();
        for(Id eachId : mapOfSentIdsVsEmailContent.keyset()){
            Order_Acknowledge_Email__c emailUpdate = new Order_Acknowledge_Email__c(id = eachId);
            emailUpdate.Email_Status__c = 'Sent';
            emailUpdate.Email__c = mapOfSentIdsVsEmailContent.get(eachId);
            emailUpdate.Email_Sent_To__c = String.valueOf(mapOfSentIdsVsRecipients.get(eachId));
            emailUpdate.Error_s_If_any__c = null;
            listOfEmailsToBeUpdated.add(emailUpdate);
        }
        if(!listOfEmailsToBeUpdated.isEmpty())
            update listOfEmailsToBeUpdated;
    }
}