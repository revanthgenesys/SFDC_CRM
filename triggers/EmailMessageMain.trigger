/*
Naresh Kumar    06/06/2013
*/
trigger EmailMessageMain on EmailMessage (before insert, after insert) {
    //
 if(Util.Bypass_Trigger_Chk)return;
 
    EmailMessage em = Trigger.new[0]; 
     
    if(Trigger.isBefore && em.Incoming){
        if(em.Subject != null && em.Subject.contains('#')){
            List<Case> caseFound;
            String str = FindCasePattern.fetchCaseNo(em.Subject);                   
            //Trigger.new[0].addError('Str ='+str);     
            caseFound = [SELECT id FROM Case WHERE (CaseNumber = : str OR Case_Number__c = : str) AND Status != 'Closed' LIMIT 1];
            if(caseFound.size() > 0){
                em.ParentId = caseFound[0].id;
                //em.Subject = em.Subject.replace(prevStr, str);
                if(em.FromAddress == null || em.FromAddress == '' || !em.FromAddress.contains('genesys.com')) 
                    caseFound[0].Last_Public_Customer_Update__c = System.now();
                update caseFound[0];
            }
        }
    }

    if(Trigger.isAfter){
        List<Task> taskToBeUpdated = [SELECT WhatId, IsVisibleInSelfService FROM Task WHERE id =: em.ActivityId AND IsVisibleInSelfService = false];
        if(!taskToBeUpdated.isEmpty()){
            List<Case> taskCase = [SELECT Contact.Email FROM Case WHERE id =: taskToBeUpdated[0].WhatId];
            if(!taskCase.isEmpty()){                
                String contactEmail = taskCase[0].Contact.Email;
                if(em.FromAddress == contactEmail || em.ToAddress == contactEmail){         
                    taskToBeUpdated[0].IsVisibleInSelfService = true;
                    update taskToBeUpdated[0];                                   
                }
            }
        }       
    }
}