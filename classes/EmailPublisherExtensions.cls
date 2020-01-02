/*
    Class  : EmailPublisherExtensions
    Author : Vinay L 4/1/2013
    Usage  : The following table will show the logic by which email addresses will be populated in the To: field of the email publisher. 
        
            Case Contact - Case.Contact.Email
            Case Owner - Case.Owner.Email
            Service Team - The email address of all case team members, where role = Service Team
            Customer Distribution List - The email address of all case team members, where role = Customer Contact
            Case Tier 3 Owner - Case.Tier3Owner.Email
            Distribution List (everyone) - Combination of Service team & customer distribution list
    Naresh Kumar  06/04/2013
*/
public with sharing class EmailPublisherExtensions {
    public Case ca {get;set;}
    public String msg {get; set;}
    public String toStr {get; set;}
    public String ccStr {get; set;}
    public String bccStr {get; set;}
    public String toEmailAddr {get;set;}
    public String emailBody {get;set;}
    public String emailSubj {get;set;}
    public String fromAddr {get;set;}
    public Boolean isPublic {get;set;}
    public string fromS {get;set;}
    public string to {get;set;}
    public string cc {get;set;}
    public string bcc {get;set;}
    public string ato {get;set;}
    public string subject {get;set;}
    public string body {get;set;}
    public string attFile {get;set;}
    public string fileNames {get;set;}
    public static Boolean isSendMail = false;
    public EmailPublisherExtensions(ApexPages.StandardController stdController) {
        this.ca = (Case)stdController.getRecord();
        ca = [select id,Contact.Email, CaseNumber, Case.Owner.Email, Tier_3_Owner__r.Email, Select_them_email_audience__c, OwnerId, Thread_Id__c,
            Contact_Alternate_Email__c from Case where id = :ca.Id][0];
        ca.Select_them_email_audience__c = null;
        emailBody = '';
        toEmailAddr = '';
        body = '';
        isPublic = false;
        bccStr = UserInfo.getUserEmail();
    }
    public void updateIsPublicField(){     
    }
    
    //public pageReference sendEmail(){
   public void sendEmail() {
     to = toStr;
     cc = ccStr;
     bcc = bccStr;
     msg = '';
  
      String url_content_server = Label.URL_Content_Server;
      String url_vf_server = Label.URL_VF_Server;
      try{
        System.debug('NKC debug body ['+body+']');
        if(body.indexOf(url_vf_server) != -1)
          body = body.split(url_vf_server)[1];
        System.debug('NKC debug body ['+body+']');
        body = body + ' <br/><br/><br/>'+ ca.Thread_ID__c;
        //body = ' test email ';
        if(to == null || to == ''){
          // ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the TO address.');
          //  ApexPages.addMessage(errorMessage);
          msg = 'Please enter the TO address.';
          return;
        }
        
        if(cc == null)
          cc = '';
        if(bcc == null)
          bcc = '';
          
        if(body == null || body == '' || body.replace(' ','') == ''){
          //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the email Body.');
          //  ApexPages.addMessage(errorMessage);
            msg = 'Please enter the email Body.';
            return;
        }
        List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
        List<Attachment> attsTask = new List<Attachment>();
        List<Attachment> attsEmail = new List<Attachment>();
        
        Integer counter = 0;
        System.debug('NKC debug attFile ['+attFile+']');
        if(attFile != null && attFile != ''){
          for(String eachFile : attFile.split(',')){
            
            PageReference file =  new PageReference(url_content_server + 'servlet/servlet.FileDownload?file='+eachFile);
              file.setRedirect(true);
              Blob b;
              if(!Test.isRunningTest())    
                b = file.getContent();    
              
              System.debug('NKC debug file ['+file+']');
              String fileName = fileNames.split(',')[counter];
              Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
              efa.setFileName(fileName);
              efa.setBody(b);
              efas.add(efa);
              
              Attachment attTask = new Attachment();
            attTask.Body = b;
            attTask.Name = fileName;
            attsTask.add(attTask);
            Attachment attEmail = new Attachment();
            attEmail.Body = b;
            attEmail.Name = fileName;            
              attsEmail.add(attEmail);
              counter ++;
          }
        }
        List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Customer Care' OR DisplayName =: 'Customer Care'];
        System.debug('NKC debug efas ['+efas+']');
        //Sending an email
        EmailPublisherExtensions.isSendMail = true;      
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        toEmailAddr = to;      
        List<String> toAddresses = new List<String>();
        System.debug('NKC debug toEmailAddr ['+toEmailAddr+']');
        String emailSeperator;
        if(toEmailAddr.contains(';'))
          emailSeperator = ';';
        else
          emailSeperator = ',';
          
        if(toEmailAddr.contains(emailSeperator))
          toAddresses.addAll(toEmailAddr.split(emailSeperator));
        else
          toAddresses.add(toEmailAddr);
          
        System.debug('NKC debug toAddresses ['+toAddresses+']');
        email.setToAddresses( toAddresses ); 
        if(!orgAdd.isEmpty()){
          email.setOrgWideEmailAddressId(orgAdd[0].id);
        }
        
        toAddresses.clear();
        if(cc != null && cc.replace(' ', '') != ''){
          if(cc.contains(','))
            toAddresses.addAll(cc.split(','));
          else
            toAddresses.add(cc);
          email.setCCAddresses(toAddresses);
        }
        
        toAddresses.clear();
        if(bcc != null && bcc.replace(' ', '') != ''){
          if(bcc.contains(','))
            toAddresses.addAll(bcc.split(','));
          else
            toAddresses.add(bcc);
          email.setBccAddresses(toAddresses);
        }
        
        email.setSubject( subject );                  
          email.setHtmlBody( body );
          if(!Test.isRunningTest())
            email.setFileAttachments( efas);
          Messaging.SendEmailResult [] r = 
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});        
          System.debug('NKC debug r ['+r+']'); 
          //Creating a task
          Task newTask = new Task();
          newTask.WhatId = ca.id;
          newTask.Subject = subject;
          newTask.Type = 'Outbound call';
          if(isPublic)
            newTask.IsVisibleInSelfService = true;
          newTask.Description = body;
          newTask.Status = 'Done';
          newTask.ActivityDate = System.today();
          insert newTask;
          insertAttachments(attsTask, newTask.id);
          //Creating EmailMessage
          EmailMessage newEM = new EmailMessage();
          newEM.parentId = ca.id;
          newEM.ActivityId = newTask.id;
          newEM.MessageDate = System.now();
          newEM.ToAddress = toEmailAddr;
          newEM.Subject = subject;
          newEM.HtmlBody = body;
          insert newEM;
          insertAttachments(attsEmail, newEM.id);
          if(isPublic){
            ca.Last_Public_Care_Update__c = System.now();
            update ca;
          }
      }
      catch(Exception e){
        //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
         // ApexPages.addMessage(errorMessage);
         msg = e.getMessage();
         return;
      }        
        //return new PageReference('/'+ca.id);
        msg = 'Success';
        return;
    }
    
    private void insertAttachments(List<Attachment> atts, String parentId){      
      for(Attachment eachAtt : atts){
        eachAtt.ParentId = parentId;
      }
      if(!Test.isRunningTest())
        insert atts;
    }
 
    
    public Pagereference cngEmail(){
        toEmailAddr = '';
        
        if(ca.Select_them_email_audience__c == 'Case Contact'){
          if(ca.Contact.Email != null)
              toEmailAddr = ca.Contact.Email + ',';
            toEmailAddr = addAlternateEmailIfAny(toEmailAddr);
        }else if(ca.Select_them_email_audience__c == 'Case Owner'){
          if(ca.Owner.Email != null)
              toEmailAddr = ca.Owner.Email + ',';
        }else if(ca.Select_them_email_audience__c == 'Service Team'){
            toEmailAddr = '';
            
            for(Service_Team_Member__c ct : [SELECT Email__c 
                                     FROM   Service_Team_Member__c
                                     WHERE  Case__c = :ca.Id and Email__c <> :null]){
                 toEmailAddr = toEmailAddr + ct.Email__c + ',';
             }
            for(Internal_Contact__c ct : [SELECT Email__c 
                                     FROM   Internal_Contact__c
                                     WHERE  Case__c = :ca.Id and Email__c <> :null]){
                 toEmailAddr = toEmailAddr + ct.Email__c + ',';
             }
             
        }else if(ca.Select_them_email_audience__c == 'Customer Distribution List'){
            toEmailAddr = '';
            if(ca.Contact.Email != null)
              toEmailAddr = ca.Contact.Email + ',';
            toEmailAddr = addAlternateEmailIfAny(toEmailAddr);
            for(Customer_Contact__c ct : [SELECT Email__c 
                                     FROM   Customer_Contact__c
                                     WHERE  Case__c = :ca.Id and Email__c <> :null]){
                 toEmailAddr = toEmailAddr + ct.Email__c + ',';
             }             
        }else if(ca.Select_them_email_audience__c == 'Case Tier 3 Owner'){
          if(ca.Tier_3_Owner__r.Email != null)
              toEmailAddr = ca.Tier_3_Owner__r.Email + ',';
        }else if(ca.Select_them_email_audience__c  == 'Distribution List (everyone)'){
            toEmailAddr = '';
            if(ca.Contact.Email != null)
              toEmailAddr = ca.Contact.Email + ',';
            toEmailAddr = addAlternateEmailIfAny(toEmailAddr);
            for(Service_Team_Member__c ct : [SELECT Email__c 
                                     FROM   Service_Team_Member__c
                                     WHERE  Case__c = :ca.Id and Email__c <> :null]){
                 toEmailAddr = toEmailAddr + ct.Email__c + ',';
             }
            for(Internal_Contact__c ct : [SELECT Email__c 
                                     FROM   Internal_Contact__c
                                     WHERE  Case__c = :ca.Id and Email__c <> :null]){
                 toEmailAddr = toEmailAddr + ct.Email__c + ',';
             }
             
            for(Customer_Contact__c ct : [SELECT Email__c 
                                    FROM   Customer_Contact__c
                                    WHERE  Case__c = :ca.Id and Email__c <> :null]){
                toEmailAddr = toEmailAddr + ct.Email__c + ',';
            }
            if(ca.Tier_3_Owner__r.Email != null)
              toEmailAddr = ca.Tier_3_Owner__r.Email + ',';            
        }        
        toEmailAddr = toEmailAddr.removeEndIgnoreCase(',');
        System.debug('NKC debug toEmailAddr ['+toEmailAddr+'] ');
 
        toStr = toEmailAddr;
        return null;
    }
    private String addAlternateEmailIfAny(string email){
      if(ca.Contact_Alternate_Email__c != null)
        email += ca.Contact_Alternate_Email__c + ',';
      return email;
    }
}