global class GenericPartnerPortalUserPasswordUpd Implements Schedulable {
        public static String CRON_EXP = '0 0 * * * ?';
       
        global void execute(SchedulableContext sc){
            setPortalUserPassword();
        }

        public void setPortalUserPassword(){
            List<User> listUsers = [SELECT Id, Generic_Portal_User__c, Generic_Portal_Password_Set__c 
                                    FROM User WHERE IsActive=true AND Username like 'genuser%genesys%' AND 
                                    UserType='PowerPartner' AND Generic_Portal_User__c=true 
                                    AND Generic_Portal_Password_Set__c=false];

                      
            String passwordToUse;
			Partner_Portal_Settings__c pps = Partner_Portal_Settings__c.getInstance('GenericPartnerPortalUserPassword');
			if(pps != NULL)
                passwordToUse = pps.Id_Value__c;
            else 
                passwordToUse = 'genesys0001';
            for(User usr : listUsers){
                try{
                    System.setPassword(usr.Id, passwordToUse);
                    usr.Generic_Portal_Password_Set__c = true;
                }catch(Exception e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    SendEmail.sendSingleEmail(Label.Admin_Emails, 'Error Occured During Generic Portal User Password Set', 'Error Details :' + e.getMessage());    
                }
            }
            if(!listUsers.isEmpty() )
            	update listUsers;
        }
        
        global static String scheduleIt() {
            return System.schedule('GenericPortalUserPasswordUpd', CRON_EXP, new GenericPartnerPortalUserPasswordUpd());
        }
    }