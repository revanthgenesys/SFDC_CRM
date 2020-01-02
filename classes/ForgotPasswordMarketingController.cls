public with sharing class ForgotPasswordMarketingController {

    public String username {get; set;}   
    public Boolean passSent {get;set;}
    public ForgotPasswordMarketingController () {
      passSent = false;
    }
  /*  public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }*/
    
    public PageReference forgotPassword() {
        if(username == ''){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Your User Name');
            ApexPages.addMessage(msg);  
            return null;   
        }else{
            Portal_Password__c portalPassword = new Portal_Password__c();
            portalPassword.username__c = username;
            portalPassword.Reset__c = true;
            String passW = getPassword(8);
            system.debug('****username************'+username);
            system.debug('****passW************'+passW);
            List<User> usr = [Select Id,Name,Email,UserName from User where UserName =: username limit 1];
            passSent = true;
            if(usr.size() > 0)
            {
                system.debug('****passW************'+passW);
                System.setPassword(usr[0].Id,passW);
                portalPassword.Current_Password__c = passW ;
                upsert portalPassword Username__c;
                
                string email = usr[0].Email ;
                
                Messaging.SingleEmailMessage mailHandler = new Messaging.SingleEmailMessage();
                String[] emailRecipient = new String[]{email};
                //set the recipient
                mailHandler.setToAddresses(emailRecipient);
                //set the reply email address
                mailHandler.setReplyTo('test@test.com');
                List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Customer Care' OR DisplayName =: 'Customer Care'];
                if(!orgAdd.isEmpty()){
                mailHandler.setOrgWideEmailAddressId(orgAdd[0].id);
                }
                //set the subject
                 String body = '<table><tr><td>' ;
                 body = 'Dear Customer,<br/><br/></td></tr>' ;
                 body =  body +  '<tr><td> Please find the below User name and password to login.<br/></td></tr>' ;
                 body =  body + '<tr><td> User Name :' + username +'</td></tr><br/>';
                 body =  body + '<tr><td> Password :' + portalPassword.Current_Password__c +'</td></tr><br/><br/>';
                 body =  body + '<tr><td> Thanks,</td></tr><br/>' ;
                 body =  body + '<tr><td> Support Team</td></tr>' ;
                 body =  body +'</table><br/>' ;
                
                mailHandler.setSubject('login Details');
                //set the template ID
                //mailHandler.setTemplateId('00X200000015XFL');
                mailHandler.setHtmlBody(body);
                try
                {
                Messaging.sendEmail(new Messaging.Email[] { mailHandler });
              
                }
                catch(EmailException e)
                {
                    System.debug(e.getMessage());
                    
                }
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'We have sent you an email containing your new password.');
                ApexPages.addMessage(msg);                
                return null;
            }else{
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter Valid User Name');
                ApexPages.addMessage(msg);  
                return null; 
            }
        }          
        return null;
    }

        public static String getPassword(Integer len) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        
        System.debug(key);
        return key.substring(0,len);
       }

}