/*
    Naresh Kumar    06/05/2013      Modified
*/
public without sharing class caseEmailExtn {
    private final Case c;   
    public Boolean renderResult {get;set;}
    public transient List<emailWrapper> emailRecords {get;set;}
    public Boolean isPortal {get;set;}
    public caseEmailExtn (ApexPages.StandardController stdController) {
        this.c = (Case)stdController.getRecord();
        renderResult = true;
        emailRecords = new List<emailWrapper>();
        List<User> lstUser = [Select IsPortalEnabled From  User Where  Id =: UserInfo.getUserId()];
        isPortal = lstUser[0].IsPortalEnabled;
        populateWrapper(); 
    }
    public caseEmailExtn(){
        c = [SELECT id FROM Case WHERE id =: ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        renderResult = true;
        emailRecords = new List<emailWrapper>();
        List<User> lstUser = [Select IsPortalEnabled From  User Where  Id =: UserInfo.getUserId()];
        isPortal = lstUser[0].IsPortalEnabled;
        populateWrapper();
    }
    public void populateWrapper() {
        Map<Id, Task> mapTaskIdVsTask = new Map<Id, Task>();
        Set<Id> setTaskIdHasAttachment = new Set<Id>();     
        List<Task> tasks = [select Id, WhatId, OwnerId, Subject, Description, Priority, IsVisibleInSelfService, Status from Task where WhatId=:c.Id];
            
        List<EmailMessage> emails = new List<EmailMessage>();       
        for(Task eachTask : tasks) {
           mapTaskIdVsTask.put(eachTask.id, eachTask);         
        }        
        List<EmailMessage> ems = [Select Id,incoming, ParentId, ActivityId, Subject, HtmlBody, CreatedDate, CreatedBy.Name, CreatedBy.Email, FromAddress from EmailMessage where ActivityId IN : mapTaskIdVsTask.keyset() ORDER BY CreatedDate DESC];
        Set<Id> emailIds = new Set<Id>();
        for(EmailMessage eachEM : ems){
            emailIds.add(eachEM.id);
        }
        List<Attachment> atts = [SELECT id, parentId FROM Attachment WHERE parentId IN : mapTaskIdVsTask.keyset() OR parentId IN : emailIds];
        for(Attachment eachATT : atts){
            setTaskIdHasAttachment.add(eachATT.parentId);
        }

        for(EmailMessage eachEM : ems){
            emailWrapper eW = new emailWrapper();
            eW.em = eachEM;
            if(eachEM.FromAddress != null) {
                eW.email1 = eachEM.FromAddress.split('@')[0];
                eW.email2 = eachEM.FromAddress.split('@')[1];
            }            
            if(eachEM.Incoming) 
             ew.incoming = true; 
            else 
             ew.incoming = false; 
            /* 
            if(eachEM.HtmlBody != null && eachEM.HtmlBody.indexOf('</') == -1 )
                ew.showDesc = true;
            else
                ew.showDesc = false;
            */
            if(eachEM.HtmlBody != null && eachEM.HtmlBody.length() > 150)
                eW.smallDescription = eachEM.HtmlBody.left(150);
            else
                eW.smallDescription = eachEM.HtmlBody;
            if(eW.smallDescription != null && eW.smallDescription.indexOf('<br/><br/><br/>ref:00DJ') != -1)
                eW.smallDescription = eW.smallDescription.split('<br/><br/><br/>ref:00DJ')[0];
            System.debug('NKC debug mapTaskIdVsTask.get(eachEM.ActivityId) [' + mapTaskIdVsTask.get(eachEM.ActivityId) + ']');
            eW.isPublic = mapTaskIdVsTask.get(eachEM.ActivityId).IsVisibleInSelfService;
            eW.hasAttachments = setTaskIdHasAttachment.contains(mapTaskIdVsTask.get(eachEM.ActivityId).id); 
            if(!eW.hasAttachments)
                eW.hasAttachments = setTaskIdHasAttachment.contains(eachEM.id);
 
             emailRecords.add(eW);             
        }
        if(emailRecords.isEmpty()){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'There are no email activities.');
            ApexPages.addMessage(errorMessage);
            renderResult = false;
        }
    }
    
    public class emailWrapper{
        public EmailMessage em {get;set;}
        public Boolean isPublic {get;set;}
        public String smallDescription {get;set;}
        public Boolean showDesc {get;set;}
        public Boolean hasAttachments {get;set;}
        public Boolean incoming {get;set;}
        public String email1 {get;set;}
        public String email2 {get;set;}
        
    }
}