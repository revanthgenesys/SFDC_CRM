/**
 * @Author      	: Narasimha Rao Tumma
 * @Created Date	: Dec 14, 2015
 * @Org. Release	: Dec 2015
 * @Description 	: Controller class for submitting Partner Rebate Request.
 * @Test Class  	: EarnedRebateClassesTest
 * @Modifications	: 
*/
public class RebateRequestController {

    public String rebateYear;  
    private String userId;
    private String accountId; 
    
    public Partner_Rebate_Request__c rebateRequest {get; set;}
    public Account pAccount {get; set;}
    public Contact pContact {get; set;}
    public User pUser {get; set;}
    public boolean rebateRequestSubmitted {get; set;}
    public Decimal availableEarnedRebate {get; set;}
    public Attachment attachment{
         get {
          if (attachment == null)
            attachment = new Attachment();
          return attachment;
        }
        set;
    }    
    public RebateRequestController(){
        
        rebateRequestSubmitted = false;
        userId = UserInfo.getUserId();
        rebateYear = ApexPages.currentPage().getParameters().get('ry');
        accountId = ApexPages.currentPage().getParameters().get('lua');
        
        pAccount = [Select id, Name, OwnerId, Owner.Name, Owner.Email, Owner.ManagerId, Owner.Manager.Email, TM_Acc_Country_Region__c from Account WHERE Id = :accountId];
        pUser = [select id, Name, ContactId, Contact.Name FROM User WHERE Id = :userId];

        List<Partner_Rebate__c> rebateList = [SELECT Id, Total_Earned_Rebate__c, CurrencyIsoCode
                                              FROM  Partner_Rebate__c 
                                              WHERE Partner_Name__c = :accountId AND Agree_Disagree_Flag__c = true
                                              AND Rebate_Year__c = :rebateYear AND Publish_Earned_Amounts_to_Partner_Portal__c = True];

        
		Regional_Controllers__c regionController;
        if(String.isNotBlank(pAccount.TM_Acc_Country_Region__c))
        	regionController = Regional_Controllers__c.getValues(pAccount.TM_Acc_Country_Region__c);
        else 
        	regionController = Regional_Controllers__c.getValues('North America');
        
        Partner_Rebate_Regional_Channel_Lead__c regionChannelLead;
        if(String.isNotBlank(pAccount.TM_Acc_Country_Region__c))
        	regionChannelLead = Partner_Rebate_Regional_Channel_Lead__c.getValues(pAccount.TM_Acc_Country_Region__c);
        else 
        	regionChannelLead = Partner_Rebate_Regional_Channel_Lead__c.getValues('North America');

        
		/*Regional_Controller_List__c regionController;
        if(String.isNotBlank(pAccount.TM_Acc_Country_Region__c))
        	regionController = Regional_Controller_List__c.getValues(pAccount.TM_Acc_Country_Region__c);
        else 
        	regionController = Regional_Controller_List__c.getValues('North America');*/
        
        User regionControllerUser = [SELECT Id, Name from User Where UserName = :regionController.User_Name__c LIMIT 1];
        User regionChannelLeadUser = [SELECT Id, Name from User Where UserName = :regionChannelLead.User_Name__c LIMIT 1];
        
        rebateRequest = new Partner_Rebate_Request__c();
        rebateRequest.Rebate_Year__c = rebateYear;
        rebateRequest.Partner_Account__c = pAccount.Id;
        rebateRequest.Contact__c = pUser.ContactId;
		rebateRequest.Channel_Manager__c = pAccount.OwnerId;
        // rebateRequest.Regional_Channel_Lead__c = pAccount.Owner.ManagerId;
        rebateRequest.Regional_Channel_Lead__c = regionChannelLeadUser.Id;
        // rebateRequest.Regional_Controller__c = regionController.User_Id__c;     
        rebateRequest.Regional_Controller__c = regionControllerUser.Id;
		rebateRequest.CurrencyIsoCode = rebateList[0].CurrencyIsoCode;
            
        
        Decimal totalEarnedRebate = rebateList[0].Total_Earned_Rebate__c;
		/*
        AggregateResult[] totalRebateUsedResults = [SELECT SUM(Requested_Rebate_Amount__c) total 
                                                    FROM Partner_Rebate_Request__c 
                                                    WHERE Status__c IN ('Processed', 'In-Process') 
                                                    AND  Partner_Account__c = :accountId AND Rebate_Year__c = :rebateYear];
        Decimal totalRebateUsed = totalRebateUsedResults[0].get('total') != NULL ? (Decimal)totalRebateUsedResults[0].get('total') : 0.0;
		*/	
        Decimal totalRebateUsed = 0.0;
        List<Partner_Rebate_Request__c> rebateRequests = [SELECT Id, Name, Date__c, Expense_Type__c, Requested_Rebate_Amount__c, Status__c, Contact__r.Name 
                                                      FROM Partner_Rebate_Request__c 
                                                      WHERE Partner_Account__c = :accountId AND Rebate_Year__c = :rebateYear 
                                                          AND Status__c IN ('Processed', 'In-Process')
                                                          ORDER BY Date__c, Id];
        for(Partner_Rebate_Request__c prr : rebateRequests){
            totalRebateUsed += prr.Requested_Rebate_Amount__c;
        }
        availableEarnedRebate  = totalEarnedRebate - totalRebateUsed;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Maximum available Rebate Amount for this request is ' + availableEarnedRebate.setScale(2)));
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Rebate Request Date should be in between 01/01/'+(Integer.valueOf(rebateYear)+1)+' AND 12/31/'+(Integer.valueOf(rebateYear)+1)+'.'));
   	}
    
    public PageReference saveRebateRequest(){
        Boolean validationsFailed = false; 
        if(rebateRequest.Requested_Rebate_Amount__c > availableEarnedRebate){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not request more than Maximum available Rebate Amount. Maximum available Rebate Amount for this request is ' + availableEarnedRebate.setScale(2)));
            validationsFailed = true;
        }
        if(rebateRequest.Expense_Type__c == 'Marketing Expense' && String.isBlank(rebateRequest.Marketing_Expense_Comments__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Marketing Expense Comments are required when Expense Type is Marketing Expense.'));
            validationsFailed = true;
        }
        if(String.isBlank(attachment.Name)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Purchase Order is required in order to submit Rebate Request, Please attach PO.'));
            validationsFailed = true;
        }
        // If validations failed, Return to Page and display messages
        if(validationsFailed == true){
            return null;
        }
            
        try{
	        insert rebateRequest;
            if(String.isNotBlank(attachment.Name)){
            	attachment.OwnerId = UserInfo.getUserId();
            	attachment.ParentId = rebateRequest.Id; // the record the file is attached to
            	attachment.IsPrivate = false;
              	insert attachment;
            }
            
            // Create an approval request for the account
            Approval.ProcessSubmitRequest aRequest = new Approval.ProcessSubmitRequest();
            aRequest.setComments('Submitting Partner Rebate Request for approval.');
            aRequest.setObjectId(rebateRequest.id);
            // Submit on behalf of a specific submitter
            aRequest.setSubmitterId(UserInfo.getUserId());
            // Submit the record to specific process and skip the criteria evaluation
            aRequest.setProcessDefinitionNameOrId('Partner_Rebate_Request_Approval_Process');
            aRequest.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(aRequest);

            rebateRequestSubmitted = true;
        } catch (DMLException e) {
            System.debug('Error = ' + e.getStackTraceString() + ' ... ' + e.getMessage());
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error while creating Rebate Request.'));
        }
        finally {
      		attachment.body = null; // clears the viewstate
      		attachment = new Attachment();
            pAccount = null;
            pContact = null;
            pUser = null;
            rebateRequest = null;
    	}
        return null;
    }
    
    public PageReference redirectToPerformance(){
        return new PageReference('/partner/apex/Performance');
    }
}