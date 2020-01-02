//Naresh Kumar  01/23/2014
public class PartnerUserRequestMatchingAccExtension {
    public Partner_User_Request__c partnerUserRequest {get;set;}
    public String selectedAccountId {get;set;}
    public String selectedContactId {get;set;}  
    public Boolean renderAccounts {get;set;}
    public Boolean renderContacts {get;set;}    
    public String noAccountMsg {get;set;}
    public String noContactMsg {get;set;}
    public Boolean newusercheckBox{get;set;}
    public List<User> existingUser {get;set;}
    public List<Contact> existingContact {get;set;}
    public Boolean isExistingUserFound {get;set;}
    public Boolean isExistingContactFound {get;set;}
    public Boolean disablePortalAccess {get;set;}
    public Boolean progressStatus{get;set;}
    public Boolean closedStatus {get;set;}
    public Boolean hideNewAccount {get;set;}
    public Boolean hideNewContact {get;set;}
    public Contact lookupContact {get;set;}
    public string fields {get{ return 'Id,Name,Email';} set;}
    public Contact newContact {get;set;}
    public String updateStatus {get;set;}
    public Boolean purUpdated{get;set;}
    public Boolean sendEmailCLicked{get;set;}
    public Boolean rejectButtonClicked{get;set;}
    public String cleanedCompany {get;set;}

    public Id wkItemId {get;set;}
    public Boolean displayEmailPopup{get;set;} 
    public Boolean displayRejectPopup{get;set;} 
     
    public String partnerAccess { get; set {
    partnerAccess = value;
    System.debug('value----partnerAccess---: '+value);
    }
    }
    
    public String contactValue { get; set {
    contactValue = value;
    System.debug('value--------contactValue---------: '+value);
    }
    }
    
    public String accountValue { get; set {
    accountValue = value;
    System.debug('value:--------accountValue---------'+value);
    }
    }
    
    public String createNewContact { get; set { 
    createNewContact = value;
    System.debug('value:---------createNewContact------------ '+value);
    }
    }
    
    public PartnerUserRequestMatchingAccExtension(ApexPages.StandardController stdController){
    String partnerUserReqId = stdController.getId();
    partnerUserRequest = [SELECT id, Name, Country__r.Name,Company_Name__c,Status__c,Email_Subject__c,Show_Partner_Application__c ,Account_Name__c,Contact_Name__c,Partner_Portal_Access__c,First_Name__c,
                                 Last_Name__c,Use_Existing_Account__c, Use_Existing_Contact__c,Company_Name_Fuzzy__c, Email__c, Create_New_Account__c, 
                                 Create_New_Contact__c, Duplicate_Account__c FROM Partner_User_Request__c WHERE id =: partnerUserReqId];
    
   if(partnerUserRequest.Company_Name__c != NULL)
   {
   cleanedCompany = (partnerUserRequest.Company_Name__c).replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');    
   }
   partnerUserRequest.Email_Subject__c  = partnerUserRequest.Name + ':' + partnerUserRequest.First_Name__c +' '+ partnerUserRequest.Last_Name__c + ' - ' ;           
   if(partnerUserRequest.status__c == 'Awaiting Sales Ops')
   {
        updateStatus =  'The email has been sent successfully';
   }else{
        purUpdated = false;
        updateStatus =  'Click on the update button before approving PUR';
   }
   
    existingUser = findUserRecord(partnerUserRequest.Email__c);
    existingContact = findContactRecord(partnerUserRequest.Email__c); 
    lookupContact = new Contact();
    partnerUserRequest.Record_Updated__c = false;
     
    if(partnerUserRequest.status__c == 'Awaiting Approval' || partnerUserRequest.status__c == 'Request Submitted' || partnerUserRequest.status__c == 'Awaiting Sales Ops')  { progressStatus = true; closedStatus = false;}
     else { progressStatus = false; closedStatus = true; }
             
    if(existingUser.isEmpty()) { 
        isExistingUserFound = false;
      }else { 
        isExistingUserFound = true; 
        system.debug('----------------------------------acnt Name---------------------------------------'+existingUser[0].Contact.Account.Name);
        system.debug('----------------------------------contact Name---------------------------------------'+existingUser[0].ContactId);
        partnerUserRequest.Account_Name__c  = existingUser[0].Contact.AccountId;
        partnerUserRequest.Duplicate_Account__c  = existingUser[0].Contact.AccountId;
        partnerUserRequest.Contact_Name__c  = existingUser[0].ContactId;   
        if(!existingContact.isEmpty())
        {
        lookupContact = existingContact[0];
        }
        updateStatus = 'Click on the update button before approving PUR'; 
       }  
      
    if(existingContact.isEmpty()) { 
        isExistingContactFound = false; 
      }else { 
        isExistingContactFound = true; 
        lookupContact = existingContact[0];
        if(closedStatus)
        {
          partnerUserRequest.Account_Name__c = partnerUserRequest.Account_Name__c;
          if(existingContact.size() == 1)
          {
           partnerUserRequest.Contact_Name__c = existingContact[0].id;
          }
        }
      }  
       
    if(isExistingUserFound && isExistingContactFound)
    {
       disablePortalAccess = true;
       hideNewAccount = true ;
       hideNewContact = true;
       partnerUserRequest.Request_Type__c = 'Partner Creation';
       if(!closedStatus) { partnerUserRequest.Partner_Portal_Access__c = 'Existing Partner User Access'; }
    } else if(isExistingUserFound || isExistingContactFound) {
       partnerUserRequest.Request_Type__c = 'Partner Creation';
       disablePortalAccess = true;
       hideNewAccount = true ;
       hideNewContact = true;
      if(!closedStatus) { partnerUserRequest.Partner_Portal_Access__c = 'Existing Partner User Access'; }
    } else if(!isExistingUserFound && !isExistingContactFound){
       partnerUserRequest.Partner_Portal_Access__c = 'Potential Partner User Access';
       disablePortalAccess = false;  
       hideNewAccount = false ;
       hideNewContact = false;          
     }
  }
    
   // Update Create new Account checkbox
    public void createNewAccount(){
     partnerUserRequest.Duplicate_Account__c = null;
     Database.update(partnerUserRequest,false);
    }
   
   // Update Create new Account checkbox 
    public void createNewContact(){
      
    system.debug('----------------------------------------createNewContact--------------------------------------------------');
    
      
      partnerUserRequest.Duplicate_Contact__c = null;
      Database.update(partnerUserRequest,false);    
     }
    
     // Update PartnerAccess field
     public void updatePartnerAccess(){                  
      if(partnerUserRequest.Partner_Portal_Access__c == 'Existing Partner User Access' && partnerUserRequest.Contact_Name__c != Null)
      {
        partnerUserRequest.Create_New_Account__c = false;
        partnerUserRequest.Create_New_Contact__c = false;       
      }else if(partnerUserRequest.Partner_Portal_Access__c == 'Potential Partner User Access')
      {
        partnerUserRequest.Create_New_Account__c = true;
        partnerUserRequest.Create_New_Contact__c = true;
      }
       Database.update(partnerUserRequest,false);  
      }
    
    
    public void updateUserAcntDetails(){
      system.debug('----------------------------------updateUserAcntDetails---------------------------------------'+partnerUserRequest.Account_Name__c);
      partnerUserRequest.Duplicate_Account__c = partnerUserRequest.Account_Name__c;
      PartnerUserRequest.Create_New_Account__c = false;
      Database.update(partnerUserRequest,false);
    }
    
    public void updateUserCntDetails(){
      system.debug('----------------------------------updateUserCntDetails---------------------------------------'+lookupContact.id);
      
      if(lookupContact.Name == '')
      {
        partnerUserRequest.Duplicate_Contact__c = null;
        partnerUserRequest.Contact_Name__c = null;
      }else{
        partnerUserRequest.Duplicate_Contact__c = lookupContact.id;
        partnerUserRequest.Contact_Name__c = lookupContact.id;
        PartnerUserRequest.Create_New_Contact__c = false;
      }    

      Database.update(partnerUserRequest,false);
    }
        
    public PageReference updatePUR()
    { 
      
       if(partnerUserRequest.Account_Name__c != NULL)
       {
        Account acnt = [Select Id,Name from Account where id=:partnerUserRequest.Account_Name__c];
        partnerUserRequest.Duplicate_Account__c = partnerUserRequest.Account_Name__c;
        partnerUserRequest.Company_Name__c = acnt.Name;
        PartnerUserRequest.Create_New_Account__c = false;
       }
       
       system.debug('----------------------------partnerUserRequest.Contact_Name__c---------------------------------'+partnerUserRequest.Contact_Name__c);
       
       system.debug('----------------------------lookupContact.Name---------------------------------'+lookupContact.Name+'------');
       
       system.debug('----------------------------isExistingContactFound---------------------------------'+isExistingContactFound);
       
       
       if(lookupContact.Name != NULL && !isExistingUserFound && lookupContact.Name != '')
       {
          
          system.debug('----------------------------inside 1---------------------------------'+partnerUserRequest.Create_New_Contact__c);
         
        partnerUserRequest.Duplicate_Contact__c = lookupContact.id;
        partnerUserRequest.Contact_Name__c = lookupContact.id;
        PartnerUserRequest.Create_New_Contact__c = false;               
       }else if(partnerUserRequest.Contact_Name__c != NULL && isExistingUserFound)
       {
         
                   system.debug('----------------------------inside 2---------------------------------'+partnerUserRequest.Create_New_Contact__c);
         
         
         partnerUserRequest.Duplicate_Contact__c = partnerUserRequest.Contact_Name__c;
         PartnerUserRequest.Create_New_Contact__c = false;                        
       }
       
       if(partnerUserRequest.Create_New_Contact__c)
       {
        partnerUserRequest.Duplicate_Contact__c = null;
       }
       
       system.debug('----------------------------partnerUserRequest.Account_Name__c---------------------------------'+partnerUserRequest.Account_Name__c);
     
       system.debug('----------------------------partnerUserRequest.Contact_Name__c---------------------------------'+partnerUserRequest.Contact_Name__c);
     
       system.debug('----------------------------partnerUserRequest.Create_New_Contact__c-------------------------'+partnerUserRequest.Create_New_Contact__c);
      
       if( ((partnerUserRequest.Account_Name__c == Null || partnerUserRequest.Contact_Name__c == Null ) && isExistingContactFound && !isExistingUserFound )  
              ||  ((partnerUserRequest.Account_Name__c == Null || !partnerUserRequest.Create_New_Contact__c ) && !isExistingContactFound && !isExistingUserFound)
         )
        {
         
         system.debug('-------------------------------inside first if-------------------------------------');
         
         purUpdated = false;
         partnerUserRequest.Record_Updated__c = false;
         
         system.debug('----------------------------parter portal access---------------------------'+partnerUserRequest.Partner_Portal_Access__c);
         
         if(!isExistingContactFound && !isExistingUserFound)
         {
             updateStatus = 'Please Select Account Name and Create New Contact before approving PUR';
         }else if(isExistingContactFound && !isExistingUserFound){ 
             updateStatus = 'Please Select Account Name and Contact Name before approving PUR';
         }
         
       }else{          
         purUpdated = true;
         partnerUserRequest.Record_Updated__c = true;
         updateStatus = 'Updated successfully.';  
                   
         if(isExistingUserFound)
         {
          Account acnt = [Select Id,Name,RecordTypeId from  Account where id =:partnerUserRequest.Duplicate_Account__c]; 
          Id groupRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Group Account - Customer').getRecordTypeId();
          Id partyRecid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Party Account').getRecordTypeId();
          if(acnt.RecordTypeId == groupRecId || acnt.RecordTypeId == partyRecid)
          {
             partnerUserRequest.Account_Name__c = Null;              
          }
        }
        Database.update(partnerUserRequest,false);
       }            
       return null;
      }
     
       public pagereference sendEmail()
       {      
        partnerUserRequest.SendAccount_Email__c = true;
        updateStatus = 'The email has been sent successfully';    
        partnerUserRequest.Status__c = 'Awaiting Sales Ops';
        sendEmailCLicked = true;
        Database.update(partnerUserRequest,false);  
        
        Messaging.SingleEmailMessage mailHandler = new Messaging.SingleEmailMessage();    
        string email = Label.SalesOps_Email;
        String[] emailRecipient = new String[]{email};
              
        //set the recipient
        mailHandler.setToAddresses(emailRecipient);
        if(Label.Forgot_Password_CC != null){
        String[] emailCCRecipient = Label.Forgot_Password_CC.split(',');
        mailHandler.setBCcAddresses(emailCCRecipient);
        }
          
      //set the reply email address
    //  mailHandler.setReplyTo('noreply@genesys.com');
      OrgWideEmailAddress owdemail = [select id, Address from OrgWideEmailAddress where Address=:Label.PRM_OrdWIde_Email];
      mailHandler.orgWideEmailAddressId =  owdemail.Id;  
      mailHandler.useSignature = false;  
      String headerLogoPath =  PartnerPortalUtil.GENESYS_HEADER_LOGO;
        String footerLogoPath =  PartnerPortalUtil.GENESYS_FOOTER_LOGO;
        
       String body = '<table height="450" width="500" cellpadding="0" cellspacing="0"><tbody>';
       body += '<tr valign="top"><td style="vertical-align:top;height:100;text-align:left;background-color:#ffffff"><img border="0" src="'+headerLogoPath+'"></td></tr>';
       body += '<tr valign="top"><td style="height:5;background-color:#ffffff"></td></tr>';
       body += '<tr valign="top"><td height="300" style="color:#000000;font-size:12pt;background-color:#ffffff;font-family:arial">';
       body += '<table height="400" width="550" cellpadding="5" border="0" cellspacing="5"><tbody>';
       body += '<tr height="400" valign="top"><td style="color:#000000;font-size:12pt;background-color:#ffffff;font-family:arial">';
       body += '<div><div><div class="im"><font face="arial">Dear Sales Ops,</font></div>';
       body += '<div class="im"><div><font face="arial"><br></font></div><div>';
       body += '<font face="arial">'+partnerUserRequest.Email_Body__c+'</font>';
       body += '</div><br/></div><div><font face="arial">';
       body += '<a href="" target="_blank"></a>&nbsp;</font></div><div class="im"><div><font face="arial"><br></font></div>';
       body += '<div class="im"><font face="arial">Thank you,</font></div><div><font face="arial">Genesys Global Channels&nbsp;</font></div><div>';
       body += '<font face="arial">(<a href="mailto:partners@genesys.com" target="_blank">partners@genesys.com</a>)</font></div></div></div></div><div style="color:rgb(0,0,0);font-family:arial;font-size:12pt"><div><br></div></div><div style="color:rgb(0,0,0);font-family:arial;font-size:12pt"><br></div></td></tr></tbody></table></td></tr><tr valign="top"><td style="height:5;background-color:#ffffff"></td></tr><tr valign="top"><td style="vertical-align:top;height:100;text-align:left;background-color:#ffffff"><img border="0" src="'+footerLogoPath+'"></td></tr>';
       body += '<tr valign="top"><td style="height:5;background-color:#ffffff"></td></tr></tbody></table>';
      
      mailHandler.setSubject(partnerUserRequest.Email_Subject__c); 
     // mailHandler.setSubject(partnerUserRequest.Name + ': ' +partnerUserRequest.First_Name__c+'-'+partnerUserRequest.Last_Name__c+'  '+ partnerUserRequest.Email_Subject__c);
      mailHandler.setHtmlBody(body);   
      try{
       Messaging.sendEmail(new Messaging.Email[] { mailHandler });              
      }
      catch(EmailException e){
          System.debug(e.getMessage());                    
      }  
      return null;
     }
     
     public pageReference rejectPur()
     {
        rejectButtonClicked = true;
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        List<ProcessInstanceWorkitem> process = [SELECT Id,ProcessInstance.Status FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :partnerUserRequest.Id  AND ProcessInstance.Status = 'Pending' LIMIT 1 ];
  
      system.debug('-----------------ProcessInstance.Status-----------------'+process[0].ProcessInstance.Status);
     // Database.update(partnerUserRequest,false);  
    req2.setComments(partnerUserRequest.Reject_Comments__c);
    req2.setAction('Reject');
    req2.setWorkitemId(process[0].Id);
    Approval.ProcessResult result2 =  Approval.process(req2);
        return null;
     } 
         
        
    public List<User> findUserRecord(String userEmail)
    {
      List<User> userRecord = new List<User>();
      userRecord = [SELECT id, Full_Name__c, Profile.Name, Contact.Account.Name, Contact.AccountId,isActive,ContactId FROM User WHERE email =:userEmail AND IsActive=true AND Profile.Name != 'System Administrator' LIMIT 1];
      return userRecord;        
    }
    
    public List<Contact> findContactRecord(String userEmail)
    {
      List<Contact> userContact = new List<Contact>();
      userContact = [SELECT id,Name,Account.Name,Account.Id,Title,Owner.Name,Email,Account.Country__r.Name,Account.SAP_Code__c,Account.Type  FROM Contact WHERE email =:userEmail];
      return userContact;       
    }
    
     public void closeEmailPopup()
     {       
       displayEmailPopup = false;   
     }    
  
   public void showEmailPopup()
   {       
     displayEmailPopup = true;   
   }   
   
   
   public void closeRejectPopup()
     {       
       displayRejectPopup = false;   
     }    
  
   public void showRejectPopup()
   {       
     displayRejectPopup = true;   
   } 
}