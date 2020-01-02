public class clsLeadConversion
{

    public clsLeadConversion(ApexPages.StandardController controller) {
     taskID2 = new Task();
     // create a new Opportunity which will hold the Opportuniy name set by the user
        opportunityId = new Opportunity();
        
     // set the selected Account to NONE by default
        selectedAccount = 'NONE';
     GetLead();
     leadToConvert = [SELECT Id, Status, OwnerId, Name, Company FROM Lead WHERE Id = :sLeadId];
     GetTaskDetails();

    }

      public Lead objLead{get;set;}
      public string sLeadId{get;set;}
  
    // Selected Account's record type
    private string accountRecordType {get;set;}
    
  // prefix for the label of existing accounts
    private final string EXISTING = 'Attach to existing: ';
    
    // checkbox on the component indicating if there will be an email sent to the owner 
    public boolean sendOwnerEmail {get; set;}
    
    // This will hold the Opportunity for the Opportunity name on the comonent 
    public Opportunity opportunityID {get; set;}
    
    // Checkbox on the component indicating if an Opportunity should be created
    public Boolean doNotCreateOppty {get; set;}
    
    // This will hold the owner of Lead
    public Contact contactID {
        get {
            if (contactId == null) {
                contactID = new Contact(OwnerId = leadConvert.ownerId);
            }
            return contactId;
        }
        set;
    }
  // the list of accounts in the select list
    public List<SelectOption> accounts {get; set;}
    
    // the selected account in the select list of accounts
    public string selectedAccount {get; set;}
    
    // This is the lead that is to be converted
    public  Lead leadToConvert {get; set;}
    
    
    /* Task variables and properties -- Start*/
        // The Task object the component will interact with
        public Task taskID {get; set;}
        
        // 
        public String reminderTime {get; set;}
        
        
        public Boolean reminder {get; set;}
        

    
        // task priorities and statuses 
        private transient List<Schema.PicklistEntry> taskStatuses = Task.Status.getDescribe().getPicklistValues();
        private transient List<Schema.PicklistEntry> taskPriorities = Task.Priority.getDescribe().getPicklistValues();
        
         public Task taskID2 {
           get ;
          set;
         }
         
         //this will return the reminder date as a string in the desired format of 'M/d/yyyy'
        public string disabledActivityDate {
            get {
                return (taskID2.ActivityDate != null) ? 
                    (DateTime.newInstance(taskID2.ActivityDate, Time.newInstance(0,0,0,0)).format('M/d/yyyy')).trim()
                    : '';
            }
            set;
        }
        
        //This will populate the Reminder Times in increments of 30 minutes 
    //Based on the user's locale it will use AM/PM or 24 hour time
    public List<SelectOption> ReminderTimeOption {
        get {
            if(ReminderTimeOption == null) {
                
                ReminderTimeOption = new List<SelectOption>();
                
                //get the time format based on the user's locale
                String timeFormat = DateTimeUtility.LocaleToTimeFormatMap().get(UserInfo.getLocale());
                
                String timeValue;
                
                //if the user uses AM/PM 
                if (timeFormat != null && timeFormat.endsWith('a')) {
                    ReminderAddMeridiem(ReminderTimeOption, 'AM');
                    ReminderAddMeridiem(ReminderTimeOption, 'PM');
                    reminderTime = '8:00 AM';
                } 
                //if the user uses 24 hour time
                else {
                    ReminderAddHour(ReminderTimeOption, '00', '');
                    for (Integer i = 1; i <= 23; i++)
                    {
                        ReminderAddHour(ReminderTimeOption, i.format(), '');
                    }
                    reminderTime = '8:00';
                }
            }
            return ReminderTimeOption;
        }
        set;
    }
    /* Task variables and properties -- End*/    
    
  /* constructor*/
  public clsLeadConversion()
  {
      taskID2 = new Task();
     // create a new Opportunity which will hold the Opportuniy name set by the user
        opportunityId = new Opportunity();
        
     // set the selected Account to NONE by default
        selectedAccount = 'NONE';
     GetLead();
     leadToConvert = [SELECT Id, Status, OwnerId, Name, Company FROM Lead WHERE Id = :sLeadId];
     GetTaskDetails();
    
  }
  
  public void GetLead()
  {
    sLeadId = ApexPages.currentpage().getParameters().get('id');
    leadConvert = [Select id,name,FirstName,LastName,Company,ownerid,ProjectType__c,Status,Sold_To_Country__c,
        mobilePhone,LegacyCreatedBy__c,LegacyCreatedDate__c,Legacy_Last_Modified_By__c,Legacy_Last_Modified_Date__c,
        LeadSource,Primary_Line_of_Business__c,Lines_of_Businesses__c,Opportunity_Source__c,Opportunity_Type__c,
        Primary_Solution__c,Products__c,campaign_source__c, Direct_Indirect_Sale__c, Lead_Offer__c from Lead where id =: sLeadId];
  } /*PricingType__c,Contractual_obligation__c,*/
  
  /* Start -- Task Methods*/
  public void GetTaskDetails()
  {
     // create the task
        //taskId2 = new Task();
        
        //se the reminder to true by default
        taskID2.IsReminderSet = true;
        
        //set the reminder date to today
        taskID2.ActivityDate = system.today();
     
     //create the Task that will hold information gathered on the component 
        //taskID2 = new Task();
        
        //the reminder is set to true
        taskID2.IsReminderSet = true;
        reminder = true;
        
        // set the default values for the status and priority fields
        taskID2.Status = TaskDefaulValue(taskStatuses);
        taskID2.Priority = TaskDefaulValue(taskPriorities);
        
        //the reminder date will be set to now by default
        taskId2.ReminderDateTime = datetime.now();
        
        
  }
   
   //set the default value based on the picklist sent to the method
    private String TaskDefaulValue(List<Schema.PicklistEntry> pickList)
    {
        String defaultValue = '';
        for(Schema.PicklistEntry entry : pickList)
        {
            //if this is the default value then set it
            if(entry.isDefaultValue())
            {
                defaultValue = entry.getLabel();
                break;
            }
        }
        return defaultValue;
    }
    
    //this method will get the Task's Statuses
    public List<SelectOption> TaskStatusOption 
    {
        get {
            if(TaskStatusOption == null) {
                TaskStatusOption = new List<SelectOption>();
                
                for (Schema.PicklistEntry status : taskStatuses)
                {
                    TaskStatusOption.add(new SelectOption(status.getLabel(), status.getLabel()));
                } 
            }
            return TaskStatusOption;
        }
        set;
    }
    
    //this method will get the Task's Priorities
    public List<SelectOption> TaskPriorityOption 
    {
        get {
            if(TaskPriorityOption == null) {
                TaskPriorityOption = new List<SelectOption>();
                
                for (Schema.PicklistEntry priority : taskPriorities)
                {
                    TaskPriorityOption.add(new SelectOption(priority.getLabel(), priority.getLabel()));
                } 
            }
            return TaskPriorityOption;
        }
        set;
    }
    
    //This will get called when the due date is changed.
    //This will update the reminder date to that date that was changed
    public PageReference DueDateChanged() {
        taskId2.ActivityDate = taskId2.ActivityDate;
        return null;
    }
    // Add AM/PMs to the times
    private void ReminderAddMeridiem(List<SelectOption> reminderTimeOption, String meridiem)
    {
        ReminderAddHour(reminderTimeOption, '12', ' ' + meridiem);
        for (Integer i = 1; i <= 11; i++)
        {
            ReminderAddHour(reminderTimeOption, i.format(), ' ' + meridiem);
        }
    }
    
    //add the hours to the list
    private void ReminderAddHour(List<SelectOption> reminderTimeOption, String hour, String meridiem)
    {
        reminderTimeOption.add(ReminderOption(hour + ':00' + meridiem));
        reminderTimeOption.add(ReminderOption(hour + ':30' + meridiem));
    }
    
    //create the select options
    private SelectOption ReminderOption(String value)
    {
        return new SelectOption(value, value);
    }

  /*--------------------- End -- Task Method-------------------------------*/
  
  
  
  
  //THis is set by the <apex:attribute> and is the lead to convert
    public Lead leadConvert {
        get; 
        set {
            //the first time this is set, the select list of Accounts will be populated 
            if (accounts == null) {
                system.debug('leadConvert set to ' + value);
                
                leadConvert = value;
                
                //populate the Account dropdown based on the lead
                populateAccounts(); 
                
            }
        }
    }
  
      // Find an Account using SOSL based on the given company name
    private Account [] findCompany (string companyName) 
    {
        
        //perform the SOSL query
        List<List<SObject>> searchList = [
            FIND :companyName 
            IN NAME FIELDS 
            RETURNING 
            Account(
                Id, 
                Name
            )
        ];
        
        List <Account> accountsFound = new List<Account>();
        
        for (List <sobject> sObjs : searchList) {
            
            for (sObject s : sObjs) {
                
                //add the account that was found to the list of found accounts
                accountsFound.add((Account) s);
            }   
        }
        
        // return the list of found accounts
        return accountsFound;
    }
        //populate the list of Accounts in the dropdown
    private void populateAccounts() {
        
        if (leadConvert != null) {
                
            string company = leadConvert.Company;
            
            // find any accounts that match the SOSL query in the findCompany() method  
            Account [] accountsFound = findCompany(company + '*');
            
            accounts = new List<selectOption>();
            
            if (accountsFound != null && accountsFound.size() > 0) {
                
                // if there is at least 1 account found add a NONE option and a Create New Account option
                accounts.add(new SelectOption('NONE', '-None-'));
                
                accounts.add(new SelectOption('NEW', 'Create New Account: ' + company ));
                
                // for each account found, add an option to attach to the existing account
                for (Account a : accountsFound) {
                    
                    accounts.add(new SelectOption(a.Id, EXISTING + a.Name));
                }
                
            }
            
            else {
                
                // if no accounts matched then simply add a Create New Account option
                accounts.add(new SelectOption('NEW', 'Create New Account: ' + company ));
                
                system.debug('no account matches on company ' + company);
            }
            
            //the default opportunity name will be the lead's company
            opportunityId.Name = company + '-';
        }
        
        else system.debug('leadConvert = null');
            
    }
    
    // when the selected account in the select list of accounts changes this method is called 
    public PageReference accountChanged() {
       
        // if either the NONE option or the Create New Account option is selected, the Opportuniy Name is set to the lead's company
        if (selectedAccount == 'NEW' || selectedAccount == 'NONE') {
            opportunityId.Name = leadConvert.Company  + '-';
            
        }

        else {
            // otherwise find the account's Id and Name that was selected and set the Opportuity name to that Account
            Account [] a = [
                SELECT Id, Name 
                FROM Account WHERE Id = :selectedAccount];
            
            if (a.size() > 0) {
                opportunityId.Name = a[0].Name + '-';
            }
            
        }
        return null;
    }
    
    //this gets called when an existing accout gets looked up via the lookup magnifying glass
    public PageReference accountLookedUp() {
        system.debug('!!! Account looked up --> ' + contactId.AccountId );
        
        //find the Id and Nmae of the Account that was looked up        
        Account [] a = [
            SELECT Id, Name, RecordType.DeveloperName 
            FROM Account WHERE Id = :contactId.AccountId];
        
        if (a.size() > 0) {
            // populating account record type name
            accountRecordType = a[0].RecordType.DeveloperName;
             
            // add the locked up account to the slect list
            accounts.add(new SelectOption(a[0].Id, EXISTING + a[0].Name));
            
            // set the selected account to the one that was just looked up by default
            selectedAccount = a[0].Id;
            
            // set the Opportunity name to the account's name that was looked up
            opportunityId.Name = a[0].Name + '-';
            
            system.debug('accounts --> ' + accounts);
        }
        
        return null;
    }
    
        // set up the Lead Status pick list
    public List<SelectOption> LeadStatusOption {
        
        get {
            
            
            if(LeadStatusOption == null) {
                
                LeadStatusOption = new List<SelectOption>();
                
                //get the lead statuses
                LeadStatus [] ls = [select MasterLabel from LeadStatus where IsConverted=true order by SortOrder];
                
                // if there is more than 1 lead status option, add a NONE option  
                if (ls.size() > 1) {
                    LeadStatusOption.add(new SelectOption('NONE', '-None'));
                }
                
                // add the rest of the lead status options
                for (LeadStatus convertStatus : ls){
                    LeadStatusOption.add(new SelectOption(convertStatus.MasterLabel, convertStatus.MasterLabel));
                } 
                
            }
            
            return LeadStatusOption;
        }
        set;
    }
    
        // This method is called when the user clicks the Convert button on the VF Page
    public PageReference convertLeadDtl() {
         if(accountRecordType == 'Merge_Record_Type'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You have selected a merge account. Please do not select a merge account to convert the lead.'));
            return null;
         }
       
         leadConvert.Status = 'Converted'; 
         update leadConvert;
        // This is the lead convert object that will convert the lead 
        Database.LeadConvert objleadConvert = new database.LeadConvert();
        
        //set lead ID
        objleadConvert.setLeadId(leadToConvert.Id); 
        
        // if a due date is set but the subject is not, then show an error 
       /* if (taskID2.ActivityDate != null && string.isBlank(taskID2.Subject)){
            
            //PrintError('You must enter a Subject if a Due Date is set..');
            return null;
            
        } */
        
        // if Lead Status is not entered show an error  
        //objleadConvert.ProjectType__c = leadConvert.ProjectType__c;
        
        //if the Account is not set, then show an error
        if (selectedAccount == 'NONE')
        {
           // PrintError('Please select an Account.');
            return null;
            
        }
        
        // otherwise set the account id
        else if (selectedAccount != 'NEW') {
            objleadConvert.setAccountId(selectedAccount);
        }
        
        //set the lead convert status
        objleadConvert.setConvertedStatus(leadConvert.Status);
        
        //set the variable to create or not create an opportunity
        objleadConvert.setDoNotCreateOpportunity(doNotCreateOppty);
        
        //set the Opportunity name
        objleadConvert.setOpportunityName(((doNotCreateOppty) 
            ? null : opportunityID.Name));
        
        //set the owner id
        objleadConvert.setOwnerId(contactId.ownerID);
        
        //set whether to have a notification email
        objleadConvert.setSendNotificationEmail(sendOwnerEmail);
        
        system.debug('objleadConvert--> ' + objleadConvert);
        
       
        //convert the lead
        Database.LeadConvertResult leadConvertResult = Database.convertLead(objleadConvert);
        
        
        
        system.debug('leadConvertResult --> ' + leadConvertResult );
        
        // if the lead converting was a success then create a task
        if (leadConvertResult.success)
        {
            
            // make sure that the task information component is being used and check to see if the user has filled out the Subject field 
            if( taskID2.subject != null)
            {
                //create a new task
                Task taskToCreate = new Task();
                
                //set whether there is a reminder
                taskToCreate.IsReminderSet = taskID2.IsReminderSet;
                
                //if the reminder is set, and the reminder's date is set
                if (taskToCreate.IsReminderSet 
                    && taskID2.ActivityDate != null) {
                    
                    //set the reminder time based on the reminder class's ActivityDate
                    //The date and time in the reminder class is converted into a datetime by the convertToDatetime() method
                    
                    //taskToCreate.ReminderDateTime = Datetime.valueof(reminderTime);

                    system.debug('taskToCreate.ReminderDateTime --> ' + taskToCreate.ReminderDateTime);
                    
                }   
                
                //set the whatId to the Opportunity Id            
                taskToCreate.WhatId = leadConvertResult.getOpportunityId();
                
                //set the whoId to the contact Id
                taskToCreate.WhoId = leadConvertResult.getContactId();
                
                //set the subject
                taskToCreate.Subject =taskID2.Subject;
                
                //set the status
                taskToCreate.Status = taskID2.Status;
                
                //set the activity date 
                taskToCreate.ActivityDate = taskID2.ActivityDate;
                
                //set the Priority 
                taskToCreate.Priority = taskID2.Priority;
                
                //set the custom field Primary Resource (this is a custom field on the Task showing an example of adding custom fields to the page)
                //taskToCreate.Primary_Resource__c = taskID2.Primary_Resource__c;
                
                //set the Description field which comes from the leadConvertTaskDescComponent
                taskToCreate.Description =  taskID2.Description;
                 taskToCreate.Legacy_Task_EMG_Id__c = taskID2.Legacy_Task_EMG_Id__c;
                taskToCreate.Legacy_Event_EMG_Id__c = taskID2.Legacy_Event_EMG_Id__c;
                taskToCreate.Legacy_WhoId__c = taskID2.Legacy_WhoId__c;
                taskToCreate.Legacy_WhatId__c = taskID2.Legacy_WhatId__c;
                taskToCreate.Legacy_OwnerId__c = taskID2.Legacy_OwnerId__c;
                taskToCreate.Legacy_AccountId__c = taskID2.Legacy_AccountId__c;
                taskToCreate.Legacy_Recorded_Comments__c = taskID2.Legacy_Recorded_Comments__c;
                taskToCreate.Legacy_Sub_Code__c = taskID2.Legacy_Sub_Code__c;
                //taskToCreate.Activity_Type__c = taskID2.Activity_Type__c;
                //taskToCreate.TypeOfTask__c = taskID2.TypeOfTask__c;
                //taskToCreate.Call_Category__c = taskID2.Call_Category__c;
                
                

                //if the sendNotificationEmail variable in the leadConvertTaskDescComponent class is set then send an email
                if (true)//sendNotificationEmail)
                {
                    //create a new DMLOptions class instance
                    Database.DMLOptions dmlo = new Database.DMLOptions();
                    
                    //set the trigger user email flag to true
                    dmlo.EmailHeader.triggerUserEmail = true;
                    
                    //insert the task
                    database.insert(taskToCreate, dmlo);
                }
                else
                {
                    //if the sendNotificationEmail field was not checked by the user then simply insert the task
                    insert taskToCreate;
                }
            }
            
            if(!doNotCreateOppty)
            {
                /* Update Opportunity data on created opportunity */
                Opportunity objOpportunity = new Opportunity();
                objOpportunity.id = leadConvertResult.getOpportunityId();
                //objOpportunity.CFA__c = leadConvert.mobilePhone;
                objOpportunity.Primary_Line_of_Business__c= leadConvert.Primary_Line_of_Business__c;
                objOpportunity.Lines_of_Businesses__c = leadConvert.Lines_of_Businesses__c;
                objOpportunity.Partner_Opportunity_Source__c = leadConvert.Opportunity_Source__c;
                objOpportunity.Type = leadConvert.Opportunity_Type__c;
                objOpportunity.Primary_Solution1__c = leadConvert.Primary_Solution__c;
                objOpportunity.Products__c = leadConvert.Products__c;
                objOpportunity.currencyisocode = leadConvert.currencyisocode;
                objOpportunity.Contact__c =   leadConvertResult.getContactId();
                objOpportunity.LeadDevelopmentRep__c = leadConvert.ownerid;
                objOpportunity.Lead_Offer__c = leadConvert.Lead_Offer__c;
                /*objOpportunity.PricingType__c= leadConvert.PricingType__c;
                objOpportunity.Contractual_Obligation__c= leadConvert.Contractual_Obligation__c;  */
                objOpportunity.Direct_Indirect_Sale__c = leadConvert.Direct_Indirect_Sale__c;
                objOpportunity.Sold_To_Country__c = leadConvert.Sold_To_Country__c;                
                update objOpportunity;
            }
            
            /* Update Contact data on created contact*/
                Contact objContact = new Contact();
                objContact.id = leadConvertResult.getContactId();
                objContact.NPS__c = false;
                update objContact;
                
            
            // redirect the user to the newly created Account
            PageReference pageRef = new PageReference('/' + leadConvertResult.getAccountId());
            
            pageRef.setRedirect(true);
            
            return pageRef; 
        }
        else
        {

            //if converting was unsucessful, print the errors to the pageMessages and return null
            System.Debug(leadConvertResult.errors);

            //PrintErrors(leadConvertResult.errors);
            
            return null;
        }
        
        return null;

    }
}