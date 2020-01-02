/*
    Naresh Kumar    07/03/2013
*/
public without sharing class CaseEmailCaseUpdateRelatedListController {
    String caseId {get;set;}
    public String selectedCUId {get;set;}
    public transient List<resultWrapper> result{get;set;}
    public boolean caseClose {get;set;}
    public transient Case currentCase {get;set;}
    public String caseNumberField {get;set;}
    public String caseUpdatePrivateRecordTypeId {get;set;}
    public Boolean isReadOnlyProfile {get;set;}
    public String caseUpdateObjPrefix {get;set;}
    public Boolean isPortal {get;set;}
    public CaseEmailCaseUpdateRelatedListController(ApexPages.StandardController stdController){
        isReadOnlyProfile = CaseUtil.isCurrentUserProfileReadOnly();        
        caseId = stdController.getId();            
        currentCase = [SELECT id, CaseNumber FROM Case WHERE id =: caseId]; 
        result = new List<resultWrapper>();  
        caseNumberField = Label.Case_Update_CaseNumber_Field;       
        List<User> lstUser = [Select IsPortalEnabled From  User Where  Id =: UserInfo.getUserId()];
        isPortal = lstUser[0].IsPortalEnabled;
        RecordType rType = [SELECT id FROM RecordType WHERE DeveloperName = 'Private' AND SobjectType = 'Genesys_Case_Updates__c' LIMIT 1];
        caseUpdatePrivateRecordTypeId = rType.id;
        loadRecords();
        caseClosed();        
    }
    
    public CaseEmailCaseUpdateRelatedListController(){
        caseId = ApexPages.currentPage().getParameters().get('id');
        currentCase = [SELECT id, CaseNumber FROM Case WHERE id =: caseId];
        result = new List<resultWrapper>();   
        List<User> lstUser = [Select IsPortalEnabled From  User Where  Id =: UserInfo.getUserId()];
        isPortal = lstUser[0].IsPortalEnabled;     
        loadRecords();
        caseClosed();
        isReadOnlyProfile = CaseUtil.isCurrentUserProfileReadOnly();
    }
    
    public void caseClosed() {
      Case caseRecord = [Select id,Status from Case where id =:caseId];
      if(caseRecord != null && caseRecord.Status != null && caseRecord.Status =='Closed')
        caseClose = false; 
      else 
        caseClose = true;   
        
    }
    
    private void loadRecords(){
        Map<DateTime, resultWrapper> mapResult = new Map<DateTime, resultWrapper>();        
        List<Genesys_Case_Updates__c> caseUpdates = [SELECT id, Name, Created_By_Name__c,Type__c, Status__c, Make_Public__c, Summary__c, CreatedDate, Description__c
            FROM Genesys_Case_Updates__c WHERE Case__c =: caseId];
        for(Genesys_Case_Updates__c eachCaseUpdate : caseUpdates){
            resultWrapper item = new resultWrapper();
            item.fullDescription = eachCaseUpdate.Description__c;
            item.fullDescriptionPlainText = eachCaseUpdate.Description__c;
            if(eachCaseUpdate.Description__c != null && eachCaseUpdate.Description__c.length() > 1000)              
                item.Description = eachCaseUpdate.Description__c.left(1000) + ' ....';
            else
                item.Description = eachCaseUpdate.Description__c;            
            item.dt = eachCaseUpdate.CreatedDate;
            item.updateType = 'Update';
            item.actionLabel = 'Edit';
            item.actionURL = '/'+ eachCaseUpdate.id + '/e?retURL=/' + eachCaseUpdate.id;
            item.isPublic = eachCaseUpdate.Make_Public__c;
            item.utype = eachCaseUpdate.Type__c;   
            item.linkLabel = eachCaseUpdate.Name;
            item.linkURL = '/' + eachCaseUpdate.id; 
            item.createdBy = eachCaseUpdate.Created_By_Name__c;
            mapResult.put(item.dt, item);
        }
        
        Map<Id, Task> mapTaskIdVsTask = new Map<Id, Task>();
        Set<Id> setTaskIdHasAttachment = new Set<Id>();     
        List<Task> tasks = [select Id, WhatId, OwnerId, Subject, Description, Priority, IsVisibleInSelfService, Status, CreatedDate  from Task where WhatId=:caseId];
            
        List<EmailMessage> emails = new List<EmailMessage>();       
        for(Task eachTask : tasks) {
           mapTaskIdVsTask.put(eachTask.id, eachTask);         
        }        
        List<EmailMessage> ems = [Select Id,incoming, ParentId, ActivityId, Subject, HtmlBody, TextBody, CreatedDate, CreatedBy.Name, CreatedBy.Email, FromAddress 
            from EmailMessage where ActivityId IN : mapTaskIdVsTask.keyset() ORDER BY CreatedDate DESC];
        
        for(EmailMessage eachEM : ems){
            resultWrapper item = new resultWrapper();
            item.fullDescription  = eachEM.HtmlBody;
      item.fullDescriptionPlainText  = eachEM.TextBody;         
            item.Description = mapTaskIdVsTask.get(eachEM.ActivityId).Subject;
            item.dt = mapTaskIdVsTask.get(eachEM.ActivityId).CreatedDate;
            item.updateType = 'Email';
            item.actionLabel = 'Reply';
            item.actionURL = '/_ui/core/email/author/EmailAuthor?email_id='+eachEM.Id+'&p26=customercare@genesyslab.com:Genesys Customer Care&p24=' + eachEM.FromAddress;
            item.isPublic = mapTaskIdVsTask.get(eachEM.ActivityId).IsVisibleInSelfService;
            item.utype = eachEM.Incoming == true ? 'Inbound' : 'Outbound';   
            item.linkLabel = 'View Content';
            item.linkURL = '/apex/TaskDetail?id=' + eachEM.ActivityId + '&readOnly=true';
            item.createdBy = eachEM.FromAddress;   
            mapResult.put(item.dt, item);   
        }
       
        List<EmailMessage> emm = [Select Id,incoming, ParentId, ActivityId, Subject, HtmlBody, TextBody, CreatedDate, CreatedBy.Name, CreatedBy.Email, FromAddress 
            from EmailMessage where ParentId = :caseId ORDER BY CreatedDate DESC];
      
         for(EmailMessage eachEM : emm){
            resultWrapper item = new resultWrapper();
            item.fullDescription  = eachEM.HtmlBody;
      item.fullDescriptionPlainText  = eachEM.TextBody; 
            item.Description = eachEM.Subject;
            item.dt = eachEM.CreatedDate;
            item.updateType = 'Email';
            item.actionLabel = 'Reply';
            item.actionURL = '/_ui/core/email/author/EmailAuthor?email_id='+eachEM.Id+'&p26=customercare@genesyslab.com:Genesys Customer Care&p24=' + eachEM.FromAddress;
            item.utype = eachEM.Incoming == true ? 'Inbound' : 'Outbound';   
            item.linkLabel = 'View Content';
            
            if(eachEM.ActivityId != null) {
                try {
                  item.isPublic = mapTaskIdVsTask.get(eachEM.ActivityId).IsVisibleInSelfService;
                }
                catch (Exception e) {
                  item.isPublic = false;
                }               
                item.linkURL = '/apex/TaskDetail?id=' + eachEM.ActivityId + '&readOnly=true';              
            }
            else {
               item.linkURL = '/' +eachEM.Id;
                item.isPublic = false;
            }
            
            item.createdBy = eachEM.FromAddress;   
            mapResult.put(item.dt, item);   
        }       
        
        Set<DateTime> setDTTime = mapResult.keyset();
        List<DateTime> dtTime = new List<DateTime>();
        for(DateTime eachDT : setDTTime)
            dtTime.add(eachDT);
        dtTime.sort();
        for(Integer i = dtTime.size() - 1 ; i >= 0 ; i --){
            result.add(mapResult.get(dtTime[i]));
        }         
    }
    
     public class resultWrapper{
        public String Description {get;set;}     
        public DateTime dt {get;set;}  
        public String updateType {get;set;} 
        public Boolean isPublic {get;set;}
        public String actionLabel {get;set;}
        public String actionURL {get;set;}
        public String createdBy {get;set;}
        public String utype {get;set;}
        public String linkLabel {get;set;}
        public String linkURL {get;set;}
        public String fullDescription {get;set;}
        public String fullDescriptionPlainText {get;set;}
        
    }
}