/*
Naresh Kumar	06/05/2013
*/
public without sharing class TaskDetailController {
	public Task currentTask {get;set;}
	public EmailMessage em {get;set;}
	public Boolean isReadOnly {get;set;}
	public List<Attachment> atts {get;set;}
	public String body {get;set;}
	private String caseId;
	public TaskDetailController(ApexPages.StandardController stdController){
		this.currentTask = (Task)stdController.getRecord();
		currentTask = [SELECT id, IsVisibleInSelfService, WhatId, CreatedDate, CreatedBy.Name FROM Task WHERE id =: currentTask.id];
		init();
		
	}
	public TaskDetailController(){
		String taskId = ApexPages.currentPage().getParameters().get('id');
		currentTask = [SELECT id, IsVisibleInSelfService, WhatId, CreatedDate, CreatedBy.Name FROM Task WHERE id =: taskId];
		init();
	}
	private void init(){
		caseId = currentTask.whatId;
		em = [Select id, HtmlBody, TextBody, Incoming, CreatedBy.Email, FromAddress, ActivityId, BccAddress, CcAddress, FromName, Headers,
					  ParentId, ReplyToEmailMessageId, Status, ToAddress, Subject from EmailMessage where ActivityId = : currentTask.id LIMIT 1];
		if(em.HtmlBody != null && em.HtmlBody != '')
			body = em.HtmlBody;
		else
			body = em.TextBody;
		if(ApexPages.currentPage().getParameters().get('readOnly') != null)
			isReadOnly = true;
		else
			isReadOnly = false;
		atts = [SELECT id, Name FROM Attachment WHERE parentId =: em.id];
	}
	public pageReference updateTask(){
		if(currentTask.WhatId != caseId){		
			EmailMessage newEM = cloneEmailMsg(em);
			insert newEM;
			List<Attachment> newAtts = new List<Attachment>();
			atts = [SELECT id, Name, Body, Description, IsPrivate, ParentId  FROM Attachment WHERE parentId =: em.id];
			for(Attachment eachAtt : atts){
				Attachment newAtt = new Attachment();
				newAtt.Body = eachAtt.Body;
				newAtt.Description = eachAtt.Description;
				newAtt.IsPrivate = eachAtt.IsPrivate;
				newAtt.Name = eachAtt.Name;
				newAtt.ParentId = newEM.id;
				newAtts.add(newAtt);
			}
			insert newAtts;			
			delete em;
			List<Case> casesToBeUpdated = new List<Case>();
			Case oldCase = new Case(id = caseId, Status = 'Closed');
			casesToBeUpdated.add(oldCase);
			Case newCase = new Case(id = currentTask.WhatId, Last_Public_Customer_Update__c = System.now());
			casesToBeUpdated.add(newCase);
			update casesToBeUpdated;			
		}
		update currentTask;
		return new pageReference('/' + caseId);
	}
	
	private EmailMessage cloneEmailMsg(EmailMessage em){
		EmailMessage newEM = new EmailMessage();
		newEM.ActivityId = em.ActivityId;
		newEM.BccAddress = em.BccAddress;
		newEM.CcAddress = em.CcAddress;
		newEM.FromAddress = em.FromAddress;
		newEM.FromName = em.FromName;
		newEM.Headers = em.Headers;
		newEM.HtmlBody = em.HtmlBody;
		newEM.Incoming = em.Incoming;
		newEM.ParentId = currentTask.whatId;
		newEM.ReplyToEmailMessageId = em.ReplyToEmailMessageId;
		newEM.Status = em.Status;
		newEM.Subject = em.Subject;
		newEM.TextBody = em.TextBody;
		newEM.ToAddress = em.ToAddress;
		return newEM;
		
	}
}