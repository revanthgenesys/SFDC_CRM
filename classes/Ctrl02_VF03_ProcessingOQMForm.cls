public with sharing class Ctrl02_VF03_ProcessingOQMForm {

private OQM_Form__c OQMF {get; set;}
private Id [] ListToEmail = new Id []{};
private String OQMStatus;


public Ctrl02_VF03_ProcessingOQMForm (ApexPages.StandardController stdController) {
        Util.MyLog('###Ctrl02_VF03_ProcessingQOMForm');
        this.OQMF = (OQM_Form__c)stdController.getRecord();
        this.OQMF = [SELECT RecordTypeId, UserToAddress__c,BP__c,OpportunityName__r.Country__r.Region__c, NewOQM__c,QueueName__c, OwnerId, UserToAddress__r.Email, Owner.Email, RFPOQM__c
                     FROM OQM_Form__c
                     WHERE id =: this.OQMF.id];

    }

public PageReference Submit_OQM_Form() {
    Util.MyLog('###Submit_OQM_Form Start');
    OQMStatus = 'Submitted';
    if(OQMF.RecordTypeId ==  Config.RT_RFP_Submission){ 
        Send_RFP_Email(Config.SUBMIT_RFP_FORM_TEMPLATE);
        SwitchOwnerRFP();
        return new Pagereference('/'+OQMF.OpportunityName__c);
    }
    else{
        // Send Bid & Proposal notification for an OQM Form creation
        if(this.OQMF.NewOQM__c) 
            Send_Bid_And_Proposal_Email(Config.OQM_STATUS_SUBMIT);  
        else 
            Send_Bid_And_Proposal_Email(Config.OQM_STATUS_PENDING); 
        
        // Call method to switch owner and UserToAddress
        SwitchOwner ();
        
        //Return User to OQM list page
        Util.MyLog('###Submit_OQM_Form End');
        Opportunity o = new Opportunity(id = this.oqmf.opportunityName__c);
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        return sc.view();
    }
}

public PageReference Reject_OQM_Form() {
    Util.MyLog('###Reject_OQM_Form Start');
    // Set OQM Status to Rejected
    OQMStatus = 'Rejected';
    if(OQMF.RecordTypeId ==  Config.RT_RFP_Submission){
        Send_RFP_Email(Config.REJECTED_RFP_FORM_TEMPLATE);
        
        // Change RecordType when RFP Form has been refused 
        RecordType rt = [select Id 
                     from RecordType 
                     where DeveloperName = :Config.RT_RFP_PROPOSAL_REFUSED
                     AND SobjectType = 'OQM_Form__c'];
        OQMF.RecordTypeId = rt.Id;
    
        // Update OQM record
        //update OQMF;
    
        return new Pagereference('/'+OQMF.OpportunityName__c);
    }
    else{
    // Send Bid & Proposal notification for an OQM Form rejection
    Send_Bid_And_Proposal_Email(Config.OQM_STATUS_REJECTED);
    
    
    // Change RecordType when OQM Form has been accepted 
    RecordType rt = [select Id 
                     from RecordType 
                     where DeveloperName = :Config.RT_OQM_REFUSED
                     AND SobjectType = 'OQM_Form__c'];
    OQMF.RecordTypeId = rt.Id;
    
    // Update OQM record
    //update OQMF;
    
    //Return User to OQM list page
    ApexPages.StandardController sc = new ApexPages.StandardController(this.OQMF);
    Util.MyLog('###Reject_OQM_Form End');
    return sc.view();
    }
}

public PageReference Pending_OQM_Form() {
    Util.MyLog('###Pending_OQM_Form Start');
    // Set OQM Status to Pending
    OQMStatus = 'Pending';
    if(OQMF.RecordTypeId ==  Config.RT_RFP_Submission){
        Send_RFP_Email(Config.PENDING_RFP_FORM_TEMPLATE);
        return new Pagereference('/'+OQMF.OpportunityName__c);
    }
    else{

    // Send Bid & Proposal notification for an OQM Form rejection
    Send_Bid_And_Proposal_Email(Config.OQM_STATUS_PENDING);
    
    // Call method to switch owner and UserToAddress
    SwitchOwner ();
    
    //Return User to OQM list page    
    Schema.Describesobjectresult result = Schema.Sobjecttype.OQM_Form__c;
    ApexPages.Pagereference page = new PageReference('/' + result.getKeyPrefix() + '/o');
    Util.MyLog('###Pending_OQM_Form End');
    return page;
    }
}

public PageReference Accepted_OQM_Form() {
    Util.MyLog('###Accepted_OQM_Form Start');
    // Set OQMStatus to Accepted
     OQMStatus = 'Accepted';
     if(OQMF.RecordTypeId ==  Config.RT_RFP_Submission){

        Send_RFP_Email(Config.ACCEPTED_RFP_FORM_TEMPLATE);
        
         // Change RecordType when OQM Form has been accepted 
         RecordType rt = [select Id 
                     from RecordType 
                     where DeveloperName = :Config.RT_RFP_PROPOSAL_ACCEPTED
                     AND SobjectType = 'OQM_Form__c'];
        OQMF.RecordTypeId = rt.Id;
        // Update OQM record
       // update OQMF;
 
        return new Pagereference('/'+OQMF.OpportunityName__c);
    }
    else{
    
    OQMF.FormAccepted__c = Date.Today();    
        
    // Send Bid & Proposal notification for an OQM Form rejection
    Send_Bid_And_Proposal_Email(Config.OQM_STATUS_ACCEPTED);
    
    // Change RecordType when OQM Form has been accepted 
    RecordType rt = [select Id 
                     from RecordType 
                     where DeveloperName = :Config.RT_OQM_ACCEPTED
                     AND SobjectType = 'OQM_Form__c'];
    OQMF.RecordTypeId = rt.Id;
    
    // Update OQM record
    //update OQMF;

    //Return User to OQM list page
    ApexPages.StandardController sc = new ApexPages.StandardController(this.OQMF);
    Util.MyLog('###Accepted_OQM_Form End');
    return sc.view();
    }
}
public void Send_RFP_Email(String templateName) {
    Util.MyLog('###Send_RFP_Email Start');
    Util.MyLog('###TemplateName = ' + Config.RFP_MAIL);
    String userType = Schema.SObjectType.User.getKeyPrefix();
    this.OQMF.RFPStatus__c = OQMStatus;
    // Create a new single email message object 
    Messaging.SingleEmailMessage[] ListMail = new Messaging.SingleEmailMessage[]{};
    // String to hold the email addresses to which you are sending the email.
   // EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: templateName];
    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: Config.RFP_MAIL];
    List<GroupMember> g = [SELECT userOrGroupId 
                                   FROM groupMember
                                   WHERE  GroupId IN (SELECT Id 
                                                  FROM group 
                                                  WHERE name = : this.OQMF.QueueName__c)];
                        
    for (GroupMember gm : g) {
        if(((String)gm.UserOrGroupId).startsWith(userType)){
            Util.MyLog('###gm.UserOrGroupId = ' + gm.UserOrGroupId);
            ListToEmail.add(gm.UserOrGroupId);
        }
    }
    set<string> setEmails = new set<string>();
    for (integer i =0; ListToEmail.size() > i; i++) {
            setEmails.add(ListToEmail[i]);
    }
    for (integer i =0; ListToEmail.size() > i;i++) {
        ListMail.add(new Messaging.SingleEmailMessage());
        ListMail[i].setTemplateId(template.id);
        list<String> ccAdresses = addQueue(Config.RFP_QUEUE, setEmails);
      /*  if (i == 0 && This.OQMF.OwnerId == this.OQMF.UserToAddress__c){
            ccAdresses.add(This.OQMF.Owner.Email);
            ListMail[i].setCcAddresses(ccAdresses);
        }
        else
            ListMail[i].setCcAddresses(ccAdresses);
            */
            
        ListMail[i].setTargetObjectId(ListToEmail[i]);
        ListMail[i].setSaveAsActivity(false);
        
        //Assign record linked to OQM  
        ListMail[i].setWhatId(this.OQMF.id);
    
        // Specify the address used when the recipients reply to the email.   
        ListMail[i].setReplyTo(This.OQMF.Owner.Email);
    }
    
    Messaging.sendEmail(ListMail);
    Util.MyLog('###Send_RFP_Email End');
}

public void Send_Bid_And_Proposal_Email(String TemplateName) {
    Util.MyLog('###Send_Bid_And_Proposal_Email Start');
        Util.MyLog('###TemplateName = ' + TemplateName);
    String userType = Schema.SObjectType.User.getKeyPrefix();
    
    //Update OQM Form Reception Date on every submit call.
    //Update OQM Status on every action done on OQM
    // Save    => OQM Status = Not Submitted
    // Accept  => OQM Status = Accepted
    // Submit  => OQM Status = Submitted
    // Pending => OQM Status = Pending
    // Reject  => OQM Status = Rejected
    // 20/06/2010 : Olivier Spehner - Kerensen Consulting
    this.OQMF.OQMForm_StatusSystem__c = OQMStatus;
    
    if(TemplateName == Config.OQM_STATUS_SUBMIT 
       || TemplateName ==Config.OQM_STATUS_PENDING){
        this.OQMF.OQMFormReceptionDate__c = date.today();
    }
    
    // Create a new single email message object 
    Messaging.SingleEmailMessage[] ListMail = new Messaging.SingleEmailMessage[]{};
    Util.MyLog('!!!!!! ListMail :' + ListMail); 
    // String to hold the email addresses to which you are sending the email.
    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: TemplateName];
  //EmailTemplate template = [SELECT Id FROM EmailTemplate limit 1];
    // Check if Owner is a Sales Contact and B&P Validator gets ownership => Queue Members to Address email 
    if (This.OQMF.OwnerId == this.OQMF.UserToAddress__c)
    { 
        
        if(this.OQMF.BP__c == null) { 
        /*
            List<GroupMember> g = [SELECT userOrGroupId 
                                   FROM groupMember
                                   WHERE  GroupId IN (SELECT Id 
                                                  FROM group 
                                                  WHERE name = : this.OQMF.QueueName__c)];
                                                  
            */  
            List<GroupMember> g = [SELECT userOrGroupId FROM groupMember limit 1];          
            for (GroupMember gm : g) {
                if(((String)gm.UserOrGroupId).startsWith(userType)){
                    Util.MyLog('###gm.UserOrGroupId = ' + gm.UserOrGroupId);
                    ListToEmail.add(gm.UserOrGroupId);
                    }
            }
        }   
        // Owner is not a sales contact => Send email to sales contact
        else {
            ListToEmail.add(This.OQMF.BP__c);
        }
    }
    else {
        if(This.OQMF.BP__c == null) {
           this.OQMF.BP__c = UserInfo.getUserId();
           this.OQMF.OwnerId = UserInfo.getUserId();
           Util.MyLog('!!!!!! this.OQMF ' + this.OQMF);
              //update this.OQMF;
        }
        ListToEmail.add(This.OQMF.UserToAddress__r.id);
        Util.MyLog('!!!!! ' + ListToEmail);
    }
    set<string> setEmails = new set<string>();
    for (integer i =0; ListToEmail.size() > i; i++) {
            setEmails.add(ListToEmail[i]);
    }
    //PREPAR EMAILS
    // Assign the addresses for the To and CC lists to the mail object.
    Util.MyLog('###ListToEmail.size() = ' + ListToEmail.size());
    for (integer i =0; ListToEmail.size() > i;i++) {
        ListMail.add(new Messaging.SingleEmailMessage());
        ListMail[i].setTemplateId(template.id);
        list<String> ccAdresses = new list<string>();
        list<String> queue = new list<string>();
        if(this.OQMF.queueName__c == Config.BP_CONTACT_EMEA)
            queue = addQueue(Config.BP_CONTACT_EMEA, setEmails);
        else
            queue = addQueue(Config.BP_CONTACT_NA, setEmails);
        
        if(queue != null)
            ccAdresses = queue;
            
        if (i == 0 && This.OQMF.OwnerId == this.OQMF.UserToAddress__c){
            if(This.OQMF.Owner.Email != null)
                ccAdresses.add(This.OQMF.Owner.Email);
        }    
        if(ccAdresses != null)
            ListMail[i].setCcAddresses(ccAdresses);

        ListMail[i].setTargetObjectId(ListToEmail[i]);
        ListMail[i].setSaveAsActivity(false);
        
        //Assign record linked to OQM  
        ListMail[i].setWhatId(this.OQMF.id);
    
        // Specify the address used when the recipients reply to the email.   
       ListMail[i].setReplyTo(This.OQMF.Owner.Email); 
     //   list<String> TestEmail = new list<string>();
     //   TestEmail.add('cloudmadeeasy@gmail.com');
     //   ListMail[i].setToAddresses(TestEmail);
     //   Util.MyLog('!!!!!! Inside for loop' + ListMail[i]);
    }
    // Send the email you have created.
    if (ListMail.size() > 0) { 
        for(Messaging.SingleEmailMessage e : ListMail) {
            Util.MyLog('###Email e = ' + e);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { e });}
    }

    Util.MyLog('###Send_Bid_And_Proposal_Email End');
}

public list<String> addQueue(string queueName,set<string> setEmails){
        String queueId = DAL.getGroupByName(queueName);
        set<string> usersIds = DAL.getGroupMembers(queueId);
        list<string> userIdsToRemove = new list<string>();
        for(string userId : usersIds){
            if(setEmails.contains(userId))
                userIdsToRemove.add(userId);
        }
        usersIds.removeAll(userIdsToRemove);
        List<string> ccAdresses =  new list<string>();
        if(usersIds != null)
           ccAdresses = DAL.getMailUsersByIds(usersIds);
        return ccAdresses;
}

public void SwitchOwnerRFP(){
    Util.MyLog('###SwitchOwnerRFP Start');
    This.OQMF.OwnerId = [SELECT Id,SobjectType,QueueId, Queue.Name
                                FROM QueueSobject qs
                                WHERE qs.SobjectType = 'OQM_Form__c' 
                                AND qs.Queue.Name =: Config.RFP_QUEUE
                                LIMIT 1].QueueId;
    //update this.OQMF;
    Util.MyLog('###SwitchOwnerRFP End');
}

public void SwitchOwner() {
    Util.MyLog('###SwitchOwner Start');
    
    // Check if Owner is the sales contact
    if (This.OQMF.OwnerId == this.OQMF.UserToAddress__c)
    {
        if(this.OQMF.BP__c == null) {
            QueueSobject Que = [SELECT Id,SobjectType,QueueId, Queue.Name
                                FROM QueueSobject qs
                                WHERE qs.SobjectType = 'OQM_Form__c' 
                                AND qs.Queue.Name =: this.OQMF.QueueName__c
                                LIMIT 1]; 
            
            // B&P Queue becomes record owner
            if(Que != null && Que.queueId != null)
                This.OQMF.OwnerId = Que.QueueId;
        }
        else {
            // B&P Queue becomes record owner
            This.OQMF.OwnerId = this.OQMF.BP__c;
        }
    }   
    else
    {
        // Sales Contact becomes record owner
        This.OQMF.OwnerId = This.OQMF.userToAddress__c;
    }
    
    // Check if OQM is a new one to define which Email Template to pick up 
    if (this.OQMF.newOQM__c)
        this.OQMF.newOQM__c = false;
    // Update OQM record
    //update this.OQMF;
    
    Util.MyLog('###SwitchOwner End');
    }
}