public class DemoRequestEmails {
    
    private static DemoRequestEmails instance = null;
    public String orgEmailId { get; private set; }
    public Boolean isSandbox { get; private set; }
    
    public static void SendDeclineEmail(Demo_Request__c request) {
        List<Demo_Request__c> demos = [SELECT Id, Name, QueueName__c, Demo_Date_Time__c, Demo_Time_Length__c, Requested_Timezone__c, Account__r.Name, Lead__r.Name, CompanyName__c, Requester_Email_Addr__c FROM Demo_Request__c WHERE Id = :request.Id];          
        if(request.Requester_Email_Addr__c ==null ) return;
        
        DateTime requestTime = DemoRequestUtility.convertTimeFromGmt(request.Demo_Date_Time__c, request.Requested_Timezone__c);
        String sSubject = 'Demo Reschedule Request for ' + getRequestCompanyName(request);
        String tscHtmlGreeting = 'Unfortunately, the ININ Technical Sales team is unable to accommodate your demo request for ' + getRequestCompanyName(request) + 
            '<br/>Click <a href="' + DemoRequestUtility.orgUrl + request.Id + '">here</a> to access the full details of the request' +
            '.</br></br>Request ID: ' + request.Name + '</br>Date/Time: ' + requestTime + '</br>Timezone: ' + request.Requested_Timezone__c;
        String tscHtmlClose = '<br/><br/>Follow the link above to reschedule the request. If you do not have salesforce access, please reply to this message with the new preferred time.  If there are no available suggested times or those times are not acceptable, please suggest other alternate times' + 
            ' and your request will be rescheduled.</br></br>';
        
        String tscHtmlBody = '';
        String declineBody = '';                
        List<Demo_Request_Decline__c> declineIds = DemoRequestUtility.CheckAltDateTimeConflicts(request);       
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(Demo_Request_Decline__c i : declineIds){
            if(i.Alternate_Date_Time_Available__c == null) continue;
            declineBody += '<tr><td>' + i.User_Name__r.FirstName + ' ' + i.User_Name__r.LastName + '</td><td>' + DemoRequestUtility.convertTimeFromGmt(i.Alternate_Date_Time_Available__c, request.Requested_Timezone__c) + '</td></tr>';
        }
        if(declineBody != '') {
            tscHtmlBody = '</br></br>However, here are some alternate timeslots when a resource is potentially available.</br></br>Please note that these timeslots are not guaranteed.' + 
                '  Please check with the individual listed before confirming the time with the customer.  All alternate times listed correspond to the GMT timezone listed above.</br></br>' + 
                '<br/><br/><table><tr><td>Consultant</td><td>Alternate Date/Time</td></tr>' + declineBody + '</table></br></br>';
        }
        
        
        Messaging.SingleEmailMessage mail = prepareEmail(new String[]{request.Requester_Email_Addr__c});
        
        mail.setReplyTo(DemoRequestUtility.getDistroEmail(request.QueueName__c));
        mail.setSubject(sSubject);
        mail.setHtmlBody(tscHtmlGreeting + tscHtmlBody + tscHtmlClose);
        mails.add(mail);            		
        
        sendEmail(mails);
    }
    
    public static void SendRescheduleEmail(List<Demo_Request__c> newRequest, Map<Id,Demo_Request__c> originalRequest){
        
        List<Id> requestIds = new List<Id>();
        
        for(Demo_Request__c request : newRequest){
            requestIds.add(request.Id);
        }
        
        List<Demo_Request__c> req = [SELECT Id, Account__r.Name, Lead__r.Name, CompanyName__c FROM Demo_Request__c WHERE Id in :requestIds];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Demo_Request__c request : newRequest){
            if(request.Requester_Email_Addr__c == null || request.SuppressNotification__c) continue;
            
            Demo_Request__c oldRequest = originalRequest.get(request.Id);
            
            DateTime oldTime = DemoRequestUtility.convertTimeFromGmt(oldRequest.Demo_Date_Time__c, oldRequest.Requested_Timezone__c);
            DateTime newTime = DemoRequestUtility.convertTimeFromGmt(request.Demo_Date_Time__c, request.Requested_Timezone__c);
            String sSubject = 'Demo ID: ' + request.Name + ' for ' + getRequestCompanyName(request) + ' has been rescheduled.';
            String tscHtmlGreeting = 'Your demo request for ' + getRequestCompanyName(request) + ' has been rescheduled.' + 
                '</br> Click <a href="' + DemoRequestUtility.orgUrl + request.Id + '">here</a> to access the full details of the request.</br>'+
                ' Please see the details below containing the original details of your request and the rescheduled details.</br></br>Request ID: ' + 
                request.Name + '</br>Original Date/Time: ' + oldTime + '</br>Original Timezone: ' + oldRequest.Requested_Timezone__c + 
                '</br></br>Rescheduled Date/Time: ' + newTime + '</br>Rescheduled Timezone: ' + request.Requested_Timezone__c + '</br>Reschedule Reason: ' +
                request.Reschedule_Reason__c + '</br></br>';
            String tscHtmlClose = 'Please allow three business days for the Techincal Sales team to review and respond to your rescheduled request.</br>';
            
            Messaging.SingleEmailMessage mail = prepareEmail(new String[]{request.Requester_Email_Addr__c});
            
            mail.setSubject(sSubject);
            mail.setHtmlBody(tscHtmlGreeting + tscHtmlClose);
            
            mails.add(mail);
            
        }            
        
        sendEmail(mails);        
    }
    
    public static void SendEscalationEmail(List<Demo_Request__c> requests){
        List<Id> requestIds = new List<Id>();
       
        for(Demo_Request__c req : requests){
            requestIds.add(req.Id);
        }
        
        List<Demo_Request__c> demos = [SELECT Id, Name, Demo_Date_Time__c, Requested_Timezone__c, Escalation_Reason__c, Account__r.Name, Lead__r.Name, CompanyName__c, QueueName__c FROM Demo_Request__c WHERE Id in :requestIds];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        Map<String,List<String>> superEmails = getSupervisorEmails();
		        
        for(Demo_Request__c request : demos){
            if(request.Demo_Date_Time__c < DateTime.now()) continue;
            Messaging.SingleEmailMessage mail = prepareEmail(superEmails.get(request.QueueName__c));
            DateTime requestTime = DemoRequestUtility.convertTimeFromGmt(request.Demo_Date_Time__c, request.Requested_Timezone__c);
            String sSubject = 'Demo ID: ' + request.Name + ' for ' + getRequestCompanyName(request) + ' has been escalated.';
            String sBody = 'The demo request for ' + getRequestCompanyName(request) + ' has been escalated with a reason of ' + request.Escalation_Reason__c + '.</br></br>Request ID: ' + request.Name + '</br>Date/Time: ' + requestTime + '</br>Timezone: ' + request.Requested_Timezone__c + '</br></br>';
            String sClose = 'Click <a href="' + DemoRequestUtility.orgUrl + request.Id + '">here</a> to access the full details of the request';
            mail.setSubject(sSubject);
            mail.setHtmlBody(sBody + sClose);
            
            mails.add(mail);
        }
        
        sendEmail(mails);
    }
    
    public static void SendMaintenanceEmail(List<Demo_Request__c> requests){
        List<Id> requestIds = new List<Id>();
        
        for(Demo_Request__c req : requests){
            requestIds.add(req.Id);
        }
        
        List<Demo_Request__c> demos = [SELECT Id, Name, Demo_Date_Time__c, Requested_Timezone__c, Account__r.Name, Lead__r.Name, CompanyName__c, Requester_Name__c, Requester_Email_Addr__c FROM Demo_Request__c WHERE Id in :requestIds];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Demo_Request__c request : demos){
            if(request.Demo_Date_Time__c < DateTime.now()) continue;
            Messaging.SingleEmailMessage mail = prepareEmail(new String[]{'TechnicalSalesSystems@inin.com'});
            DateTime requestTime = DemoRequestUtility.convertTimeFromGmt(request.Demo_Date_Time__c, 'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)');
            String sSubject = 'Demo ID: ' + request.Name + ' for ' + getRequestCompanyName(request) + ' has been submitted during Maintenance.';
            String sBody = 'A demo request submitted by ' + request.Requester_Name__c + ' has been submitted during the maintenance window.  Please find the details of the request below. </br></br>Request ID: ' + 
                request.Name + '</br>Requester: ' + request.Requester_Name__c + '</br>Requester E-mail: ' + request.Requester_Email_Addr__c +
                '</br>Date/Time: ' + requestTime + '</br></br>';
            String sClose = 'Click <a href="' + DemoRequestUtility.orgUrl + request.Id + '">here</a> to access the full details of the request.  (Salesforce account required)';
            mail.setSubject(sSubject);
            mail.setHtmlBody(sBody + sClose);
            
            mails.add(mail);
        }
        
        sendEmail(mails);
    }
    
    public static void SendCallToActionEmail(List<Demo_Request__c> requests){
        
        List<Id> requestIds = new List<Id>();
        
        for(Demo_Request__c req : requests){
            requestIds.add(req.Id);
        }
        
        List<Demo_Request__c> demos = [SELECT Id, Name, QueueName__c, Demo_Date_Time__c, Requested_Timezone__c, Account__r.Name,
                                       Lead__r.Name, CompanyName__c, Requester_Name__c, Requester_Email_Addr__c FROM Demo_Request__c WHERE Id in :requestIds];
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Map<String,List<String>> superEmails = getSupervisorEmails();
        
        for(Demo_Request__c request : demos){
            if(request.Demo_Date_Time__c < DateTime.now()) continue;
            Set<User> sendToUsers = DemoRequestUtility.getUsersLeftToDecline(request);//requestToUser.get(request.Id);
            String[] sendToEmails = new List<String>();
            String offenderList = 'The following users have yet to perform action on this request:</br>';
            for(User u : sendToUsers){
                sendToEmails.add(u.Email);
                offenderList += u.Name + '</br>';
            }
            Messaging.SingleEmailMessage mail = prepareEmail(sendToEmails);
            DateTime requestTime = DemoRequestUtility.convertTimeFromGmt(request.Demo_Date_Time__c, 'GMT–05:00 Eastern Standard Time (America/Indiana/Indianapolis)');
            String sSubject = 'Demo ID: ' + request.Name + ' for ' + getRequestCompanyName(request) + ' requires your action.';
            String sBody = 'Demo request ' + request.Name + ' submitted by ' + request.Requester_Name__c + ' is nearing the Requested date and time and needs your ' +
                'attention.  Please find the details of the request below. </br></br>Request ID: ' + 
                request.Name + '</br>Requester: ' + request.Requester_Name__c + '</br>Requester E-mail: ' + request.Requester_Email_Addr__c +
                '</br>Date/Time: ' + requestTime + '</br></br>';
            String actionCall = '</br>Please access this request as soon as possible and either accept or decline.  Process logic cannot complete and the requester will not be notified until your action is taken. </br>';
            String sClose = '</br>Click <a href="' + DemoRequestUtility.orgUrl + request.Id + '">here</a> to access the full details of the request.';
            mail.setSubject(sSubject);
            mail.setHtmlBody(sBody + offenderList + actionCall + sClose);
            if(!DemoRequestEmails.getInstance().isSandbox) mail.setCcAddresses(superEmails.get(request.QueueName__c));
            mail.emailPriority = 'Highest';
            
            mails.add(mail);
        }
        
        sendEmail(mails);
        
    }   
    
    
    private static Messaging.SingleEmailMessage prepareEmail(String[] sendTo) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(DemoRequestEmails.getInstance().orgEmailId);
        if(DemoRequestEmails.getInstance().isSandbox){
        	mail.setToAddresses(new String[]{'carl.fluke@inin.com','justin.hawkins@inin.com'});
        } else {
            mail.setToAddresses(sendTo);
        }
        return mail;
    }
    
    private static void sendEmail(List<Messaging.SingleEmailMessage> mails){
        try{
            if(!Test.isRunningTest()) Messaging.sendEmail(mails);
        } catch(EmailException e){
            if(e.getMessage().contains('NO_MASS_MAIL_PERMISSION') && DemoRequestEmails.getInstance().isSandbox){
                System.debug('Sending Email failed with a message of: ' + e.getMessage() + '.  This is an expected failure on newly created sandboxes.  If desired, change the Send Email permissions to All Mail from System Only');
            } else {
                System.debug('Sending Email failed with a message of: ' + e.getMessage() + '.  No emails were sent for this operation.');
            }
        }
    }
    
    private static string getRequestCompanyName(Demo_Request__c r) {
        if(r.Account__c != null)return r.Account__r.Name;
        if(r.Lead__c != null)return  r.Lead__r.Name;
        if(r.CompanyName__c != null)return  r.CompanyName__c;
        else  return '<Unspecified>';
    }
   
    private static Map<String,List<String>> getSupervisorEmails(){
        List<Demonstration_Presenter__c> supers = [Select Presenter_E_mail__c,QueueName__c FROM Demonstration_Presenter__c where isTSM__c = true];
        Map<String,List<String>> superEmails = new Map<String,List<String>>();
        
        for(Demonstration_Presenter__c p : supers){
            if(superEmails.containsKey(p.QueueName__c))
                superEmails.get(p.QueueName__c).add(p.Presenter_E_Mail__c);
            else
                superEmails.put(p.QueueName__c, new List<String>{p.Presenter_E_Mail__c});
        }
        
        return superEmails;
    }
    
    private DemoRequestEmails(){
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Salesforce No-Reply'];
        Organization thisOrg = [SELECT Id, IsSandBox, InstanceName FROM Organization LIMIT 1];
        isSandbox = thisOrg.IsSandbox;
        orgEmailId = owa.Id;
    }
    
    //this will be allow the default values to only be pulled once per execution context
    public static DemoRequestEmails getInstance(){
        if(instance == null) instance = new DemoRequestEmails();
        return instance;
    }
}