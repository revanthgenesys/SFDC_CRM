public class ProductUpgradeRequestNotificationHelper {

    public static void sendEmail(set<Id> LstAccount){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Id objDefault:LstAccount){
            if(objDefault != null){   
                System.debug('objDefault ' + objDefault);  
                String orgWideEmail  = 'chandramouli.nalinukala@genesys.com';  
                List<String> emails=new List<String>(); 
                /*if(objDefault.Genesys_Care_specialist__r.Email != null && objDefault.Genesys_Care_specialist__r.Email != '')
                    emails.add(objDefault.Genesys_Care_specialist__r.Email); 
                if(objDefault.Genesys_Care_Ops__r.Email != null && objDefault.Genesys_Care_Ops__r.Email != '')
                    emails.add(objDefault.Genesys_Care_Ops__r.Email);                                
                */
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                mail.setToAddresses(emails);
                
                //Setting Org Wide Email
                if(orgWideEmail != null && orgWideEmail != ''){
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :orgWideEmail];
                    if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                }
                
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setTargetObjectId(userinfo.getuserid());
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setTemplateId('00X22000000DwAa');                    
                mail.SaveAsActivity = false; 
                mail.setWhatId(objDefault);
                mails.add(mail);
                system.debug('mails####'+mail);
            }
        }
        system.debug('mails####'+mails);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(mails);
        }
    }
}