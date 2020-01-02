@isTest(SeeAllData = true)
private class clsLeadConversion_Test {

    static testMethod void myUnitTest() 
    {
        //find current user
        user objUser=[SELECT Id,Bypass_Triggers__c FROM User WHERE Id=:UserInfo.getUserId()];  
        objUser.Bypass_Triggers__c = true;
        //objUser.BypassApexTriggers__c = true;
        //update objUser;
        
        Account newAccount = new Account(
          name = 'Test Account'
        );
        Insert newAccount;
        
        Country__c objCon = [Select id from Country__c limit 1];
        
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',
                        LeadSource = 'Web',  
                        Status = 'Closed - Converted',Country__c = objCon.id,Country='United States');
        
        Insert newLead;
        
        //Set Page and Query string
        PageReference pageRef = Page.LeadConversion;
        
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', newLead.Id);
       
        clsLeadConversion objCls = new clsLeadConversion(); 
        objCls.accountChanged();
        objCls.accountLookedUp();
        objCls.DueDateChanged();
        
        List<SelectOption> list_Opt = objCls.ReminderTimeOption;
        string s = objCls.disabledActivityDate;
        List<SelectOption> list_Opt2 =  objCls.TaskStatusOption;
        List<SelectOption> list_Opt3 = objCls.TaskPriorityOption;
        List<SelectOption> list_Opt4 = objCls.LeadStatusOption;
        objCls.taskID2.subject = 'Email';
        objCls.taskID2.Priority = 'High';
        objCls.taskID2.Status = 'Not Started';
        objCls.selectedAccount = newAccount.Id;
        objCls.leadConvert = newLead;
        
        

        objCls.doNotCreateOppty = true;
        objCls.sendOwnerEmail = false;
        objCls.convertLeadDtl();
        
        
        
    } 
}