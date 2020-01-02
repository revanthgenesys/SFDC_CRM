global class clsScheduleUserDeactivationJob implements Schedulable {
  
    global set<string>sUserId{get;set;}
  
  
    global void execute(SchedulableContext sc){
     
        //To bypass all trigger for this User
        User objUs = new User();
        objUs.id = UserInfo.getUserid();
        objUs.Bypass_Triggers__c = true;
        objUs.BypassValidationRules__c = true;
        objUs.BypassWorkflows__c = true;
        update objUs;
  
        system.debug('+execute of sch+');
    
        sUserId = new Set<string>();
    
        //Get object list from custom settings
        
        List<ObjectListDeactivationUser__c> lstCstSetting = ObjectListDeactivationUser__c.getall().values();
    
        /*Set limit to 100 because can't submit more then 100 batch job.
        Batch job runs for single user at a time to change the owner of 
        records for selected objects returned from custom setting. */
    

        //date dt = Termination_Date__c >:
        
        //List<id>test_User = new List<id>();
        //test_User.add('0050B000006ojt9');
        //List<User>lstUser = [Select id,name,ManagerId from User where id IN : test_User];
    
        //Need to update the condition and Termination_Date__c >: Date.today(-5) 
        List<User> lstUser = [Select id,name,ManagerId from User where Termination_Date__c <: Date.today() and Deactivation_Date__c =: null and isActive =: true and Is_Ownership_Changed__c =:false and Is_Deactivation_Error__c =: false  limit 100];
    
        string batchId;
        AsyncApexJob objApexJob;
        
        //integer iTotal = 0;
        
        system.debug('First **** '+ lstUser.size());
        
        for(User objUser : lstUser){
            //if(batchId !='')
            //  objApexJob = [SELECT Id, Status FROM AsyncApexJob WHERE ID =: batchId];
           
            //if(objApexJob.status == 'Completed') 
            //{
            sUserId.add(objUser.id);
            system.debug('2nd **** '+ objUser );
            clsUserDeactivationJob  obj = new clsUserDeactivationJob(objUser.id,lstCstSetting);
            batchId = Database.executebatch(obj,1);  
            //}                 
        }
    
    
    }
  
    global void finish(SchedulableContext sc){
    
        system.debug('+finish of sch+');
         
        //Get all User used in deactivation process
        List<User>lstUser = new List<User>();
        lstUser = [Select id,name,ManagerId,isActive,Error_Description__c  from User where id IN : sUserId];
     
        string EmailBody,mSubject,sEmailBodyActiveUsers,sSubjectActiveUsers;
        List<string>list_ActiveUser = new List<string>();
     
        sEmailBodyActiveUsers = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td>Hi,</td></tr>';
        sSubjectActiveUsers = 'Active Users List';
     
        mSubject = 'Batch Process Status';
        EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td>Hi,</td></tr>';
        EmailBody = EmailBody + '<tr><td></td></tr>';
        EmailBody = EmailBody + '<tr><td>Below is the status of user deactivation of dated '+Date.today().format()+'.</td></tr>';
        EmailBody = EmailBody + '<tr><td></td></tr>';
        EmailBody = EmailBody + '<tr><td>Total users to be deactivated – '+lstUser.size()+'</td></tr>';
        EmailBody = EmailBody + '<tr><td></td></tr>';
        EmailBody = EmailBody + '<tr><td>Successful Deactivation List:-</td></tr>';
        integer i=1;
        
        for(User obj : lstUser){
        
            EmailBody = EmailBody + '<tr><td>'+i+'- '+obj.Name+'</td></tr>';
      
            //Check for Active Users
            if(obj.isActive){
            
                list_ActiveUser.add(obj.Name);
                sEmailBodyActiveUsers = sEmailBodyActiveUsers + '<tr><td>'+ obj.Name +'</td><td>'+ obj.Error_Description__c +'</td></tr>';
                //sEmailBodyActiveUsers = sEmailBodyActiveUsers + '<tr><td>Active '+ obj.isActive+'</td></tr>';
            }  
            i=i+1; 
        }
        
        EmailBody = EmailBody + '<tr><td></td></tr>';
        EmailBody = EmailBody + '<tr><td>Thanks,</td></tr>';
        EmailBody = EmailBody + '<tr><td>Administrator</td></tr>';
     
     
        sEmailBodyActiveUsers = sEmailBodyActiveUsers + '<tr><td></td></tr>';
        sEmailBodyActiveUsers = sEmailBodyActiveUsers + '<tr><td>Thanks,</td></tr>';
        sEmailBodyActiveUsers = sEmailBodyActiveUsers + '<tr><td>Administrator</td></tr>';
        sEmailBodyActiveUsers = sEmailBodyActiveUsers + '</body></html>';
     
        //Get Email list from custom settings
        List<UserDeactivationEmail__c> lstEmail = UserDeactivationEmail__c.getall().values();
        EmailNotification(EmailBody,mSubject,lstEmail); 
     
        //Send Email for Active Users
        system.debug('+++sEmailBodyActiveUsers &&&&&&&&'+sEmailBodyActiveUsers );
        if(list_ActiveUser.size()>0)
            EmailNotification(sEmailBodyActiveUsers ,sSubjectActiveUsers ,lstEmail); 
     
        //Enable all triggers for this User
        User objUs = new User();
        objUs.id = UserInfo.getUserid();
        objUs.Bypass_Triggers__c = false;
        objUs.BypassValidationRules__c = false;
        objUs.BypassWorkflows__c = false;
        //update objUs;
     
    }
  
    public void EmailNotification(string mailBody,string mailSubject,List<UserDeactivationEmail__c> lstEmail){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[lstEmail.size()];
        for(integer i=0;i<lstEmail.size();i++)
        {
          toAddresses[i] =  lstEmail[i].Email__c;
        }
        mail.setToAddresses(toAddresses);
        mail.setPlainTextBody(mailBody);
        mail.setHtmlBody(mailBody);
        mail.setSubject(mailSubject);
        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
}