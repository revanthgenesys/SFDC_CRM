public class consumeSrvOwnerChng {
    
    public boolean sendNotification{get;set;}
    public string additionalEmails{get;set;}
    
    public Consume_Service__c consumeServRec{get;set;}

    public consumeSrvOwnerChng(ApexPages.StandardController controller) {
        consumeServRec = [Select Id,Name,Contact__c,OwnerId from Consume_Service__c where Id=:((Consume_Service__c)controller.getRecord()).Id];
        sendNotification = true;
        system.debug('cons--->'+sendNotification);
    }
    
    public pagereference saveCSRec(){
        update consumeServRec;
        system.debug('save2--->'+sendNotification);
        if(sendNotification){
            emailtemplate emlTemplate = [select id from emailtemplate where DeveloperName = 'Consume_Service_Owner_Change'];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(getMailAddresses());
            if(!string.isBlank(consumeServRec.Contact__c))
                mail.setTargetObjectId(consumeServRec.Contact__c);
            else{
                //set dummy contact id for template merge fields to work
                mail.setTargetObjectId([Select Contact__c from Consume_Service__c where Contact__c != null Limit 1].Contact__c);
            }
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setTemplateId(emlTemplate.Id);
            mail.setSaveAsActivity(false);
            mail.setWhatId(consumeServRec.Id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        pagereference csPage = new pagereference('/'+consumeServRec.Id);
        csPage.setRedirect(true);
        return csPage;
    }
    
    public pagereference cancelCSRec(){
        pagereference cancelPage = new pagereference('/'+consumeServRec.Id);
        cancelPage.setRedirect(true);
        return cancelPage;
    }
    
    public List<String> getMailAddresses(){

        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>();
    
        /*Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE DeveloperName = 'Consume_Service_Owner_Change'];
        for (GroupMember gm : g.groupMembers){
            mailList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr){
            mailAddresses.add(u.email);
        }*/
        Consume_Service__c tempCS = [Select Id,Owner.Email from Consume_Service__c where Id=:consumeServRec.Id];
        system.debug('tempCS.Owner.Email--->'+tempCS.Owner.Email);
        mailAddresses.add(tempCS.Owner.Email);
        mailAddresses.add(UserInfo.getUserId());
        if(!string.isBlank(additionalEmails))
            mailAddresses.addAll(additionalEmails.split(';'));
            
        return mailAddresses;
    }

}