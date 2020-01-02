trigger TaskMain on Task (before insert) {

/*  MS - commented out 10/25/2017
 if(Util.Bypass_Trigger_Chk)return;

    Task taskToBeUpdated = Trigger.new[0];
    //Trigger.new[0].addError('Error = ' + taskToBeUpdated.Description);    
    if(EmailPublisherExtensions.isSendMail)
        return;
    
    if(taskToBeUpdated.Subject != null && taskToBeUpdated.Subject.contains('#')){
        List<Case> caseFound;
        String str = FindCasePattern.fetchCaseNo(taskToBeUpdated.Subject);
        //Trigger.new[0].addError('Str ='+str);
        caseFound = [SELECT id FROM Case WHERE (CaseNumber = : str OR Case_Number__c = : str) AND Status != 'Closed' LIMIT 1];
        
        if(caseFound.size() > 0){
            DateTime lastThreeMinutes = System.now().addMinutes(-3);
            List<Case> caseToBeDeleted = [SELECT id FROM Case WHERE id =: taskToBeUpdated.WhatId AND CreatedDate >: lastThreeMinutes];                      
            if(!caseToBeDeleted.isEmpty() && caseFound[0].id == caseToBeDeleted[0].id) return;
            System.debug('NKC debug caseToBeDeleted ['+caseToBeDeleted+']');
            if(!caseToBeDeleted.isEmpty())
                delete caseToBeDeleted;         
            taskToBeUpdated.WhatId = caseFound[0].id;
            //taskToBeUpdated.Subject = taskToBeUpdated.Subject.replace(prevStr, str);          
        }
    }
 */   
}