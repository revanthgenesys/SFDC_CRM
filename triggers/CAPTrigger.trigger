trigger CAPTrigger on New_Solution_Design__c (before insert,before update,after insert,after update) {
    
    if (trigger.isBefore && trigger.isUpdate) {
        
        set<Id> CAPIdList = new set<Id> ();
     
        for (New_Solution_Design__c eachCAP : trigger.new) {
            if ((eachCAP.Status__c == 'Approved' || eachCAP.Status__c == 'Rejected') &&
                    (trigger.oldMap.get(eachCAP.id).Status__c != 'Approved' && trigger.oldMap.get(eachCAP.id).Status__c != 'Rejected')) {                      
                      CAPIdList.add(eachCAP.id);
                    }
        }
        
      for(ProcessInstanceStep Step:[SELECT s.Id, s.StepStatus,s.Comments,s.Actor.Name,s.Createddate,s.OriginalActor.Name,s.ProcessInstance.TargetObjectId FROM 
                                    ProcessInstanceStep s where s.ProcessInstance.TargetObjectId IN :CAPIdList order by s.createdDate DESC]) 
      {
          
        String QueueName= step.OriginalActor.Name;
        QueueName = QueueName.replace('Professional Services', 'PS');
        String ActorName = QueueName+' Actor';
        String ActionDate = QueueName+' Action Date';
        system.debug('<----'+QueueName+'----->');        
        for(Schema.FieldSetMember f : SObjectType.New_Solution_Design__c.FieldSets.Approval.getFields())
        	{
        		if(f.Label == ActorName)
        			{
 						trigger.newMap.get(Step.ProcessInstance.TargetObjectId).put(f.fieldpath,Step.Actor.Name);
                        system.debug('<----'+f.fieldpath+' '+Step.Actor.Name+'----->');
                        
                    }
                 if(f.Label == ActionDate)
                 	{
                        trigger.newMap.get(Step.ProcessInstance.TargetObjectId).put(f.fieldpath,Step.Createddate);
                        system.debug('<----'+f.fieldpath+'----->');
                    }
        	}          
                 
		}
    
        
    }

}