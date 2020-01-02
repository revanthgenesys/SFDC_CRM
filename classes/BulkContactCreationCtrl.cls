//Created by Mukunthan for Bulk Contact LDAP login creation

public class BulkContactCreationCtrl{

    
    //public Account accountRec{get;set;}
    public List<ContactWrapper> lstConWrap{get;set;}
    public boolean isSubmitted{get;set;}
    public boolean selectAll{get;set;}
    public List<ContactWrapper> validConWrapLst{get;set;}
    private List<Contact> conList = new List<Contact>();
    public list<contact> getconList(){
        return conList;
    }
    //private list<contact> contactListUpd = new list<contact>();
    private list<Id> refinedConIDList = new list<Id>();
    private map<string, account> acctMap = new map<string, account>();
    private list<account> accLst = new list<account>();
    private list<Id> accIDs = new list<Id>();
    private string acctId;
    
    private list<Contact> updContactLst = new list<Contact>();
    
    private final string CREATE_NO_EMAIL_ERR_MSG = 'A web login cannot be created because the contact does not have an email address.  ';
    private final string CREATE_NO_CONTACTID_ERR_MSG = 'A web login cannot be created because the contact does not have a ContactId.  It may not yet be synced, so please try again in a few minutes.  ';
    
        public BulkContactCreationCtrl() {
            //this.accountRec = (account)stdController.getRecord();
            lstConWrap = new List<ContactWrapper>();
            validConWrapLst = new List<ContactWrapper>();
            isSubmitted = false;
            acctId = ApexPages.currentPage().getParameters().get('acctId');
            for(Contact con: [SELECT Id,Contact.FirstName,Contact.lastName,Account.Name,AccountId,Email,Contact_ID__c,Has_LDAP_Login__c,Has_Requested_LDAP_Change__c FROM Contact WHERE AccountId =: acctId AND Has_LDAP_Login__c = false]){
                lstConWrap.add(new ContactWrapper(con)); 
            }
            System.Debug('lstConWrap--->'+lstConWrap);
        }

        public void procSelectedContacts(){
            try{
                for(ContactWrapper conWrap: lstConWrap){
                    if(conWrap.selected == true && (conWrap.validationTxt != '' || !string.isBlank(conWrap.validationTxt))){
                        validConWrapLst.add(conWrap);  
                    }
                }
                System.Debug('validConWrapLst--->'+validConWrapLst);
                if(validConWrapLst.size()>0){
                    validateAndRequestContacts(validConWrapLst);
                }
                else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Select one or more Contact records and try again.'));
                }
                
            }
           catch(Exception e){
               System.Debug('ErrorMsg--->'+e.getMessage());
               System.Debug('ErrorInLine--->'+e.getLineNumber());
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           }
           finally{
                for(ContactWrapper uncheckRec:lstConWrap){
                    uncheckRec.selected = false;
                }
                validConWrapLst = new List<ContactWrapper>();
                refinedConIDList = new list<Id>();
                updContactLst = new list<Contact>();
           }
       }
       
        public void selectAllContactsAndProc(){
            if(selectAll == true){
                for(ContactWrapper conWrap: lstConWrap){
                    conWrap.selected = true;
                }
            }
            else{
                for(ContactWrapper conWrap: lstConWrap){
                    conWrap.selected = false;
                }
            }
        }
        
        public pagereference cancelProc(){
            pagereference retToAcct = new pagereference('/'+acctId);
            retToAcct.setRedirect(true);
            return retToAcct;
        }
        
        public void validateAndRequestContacts(list<ContactWrapper> contWrprLst){
            //contactListUpd = [Select Id, AccountId from Contact where Has_LDAP_Login__c = false AND Bulk_Create_Login__c = true limit 5];
            //contactListUpd = [Select Id, AccountId,Email,Contact_ID__c,Has_LDAP_Login__c,Bulk_Create_Login__c from Contact where Has_LDAP_Login__c = false limit 3];
            //System.Debug('contactListUpd--->'+contactListUpd);
            if(contWrprLst.size()>0){
                for(ContactWrapper conWrprRec:contWrprLst){
                    accIDs.add(conWrprRec.Contact.AccountId);
                }
                
                accLst = [Select Id,Account_Sub_Type__c from Account where Id IN:accIDs];
                for(account eachAcc:accLst){
                    acctMap.put(eachAcc.Id,eachAcc);
                }
                
                for(ContactWrapper eachconWrpr:contWrprLst){
                    boolean isError = false;
                    
                    if (eachconWrpr.Contact.Has_Requested_LDAP_Change__c == true) 
                    {
                        eachconWrpr.validationTxt = 'A Web Login request has been submitted already';
                        isError = true;
                    }          
                    
                    if (eachconWrpr.Contact.Email == null || eachconWrpr.Contact.Email == '')
                    {
                        eachconWrpr.validationTxt = string.isBlank(eachconWrpr.validationTxt)?CREATE_NO_EMAIL_ERR_MSG:eachconWrpr.validationTxt + '; ' + CREATE_NO_EMAIL_ERR_MSG;
                        isError = true;
                    }            
                    
                    if (acctMap.get(eachconWrpr.Contact.AccountId).Account_Sub_Type__c != 'PureCloud Customer' && (eachconWrpr.Contact.Contact_ID__c == null || eachconWrpr.Contact.Contact_ID__c == ''))
                    {
                        eachconWrpr.validationTxt = string.isBlank(eachconWrpr.validationTxt)?CREATE_NO_CONTACTID_ERR_MSG:eachconWrpr.validationTxt + '; ' + CREATE_NO_CONTACTID_ERR_MSG;
                        isError = true;
                    }            
                    
                    if (!isError)
                    {
                        eachconWrpr.validationTxt = 'Request Submitted';
                        refinedConIDList.add(eachconWrpr.Contact.Id);
                    }
                }
                if(refinedConIDList.size()>0){
                    try{
                        if(!Test.isRunningTest()){
                            LdapManagement ldap = new LdapManagement();
                            ldap.CreateLogins(refinedConIDList);
                        }
                        
                        updContactLst = [Select Id,Has_Requested_LDAP_Change__c from Contact where Id IN:refinedConIDList];
                        
                        AddMessageToLog(updContactLst,'Success',UserInfo.getName() + ' has requested the creation of the web login.');
                    }
                    catch(Exception e){
                        System.Debug('CallOutException--->'+e.getMessage());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    }                   
                    try{
                        for(contact conProc:updContactLst){
                            conProc.Has_Requested_LDAP_Change__c = true;
                        }
                        
                        update updContactLst;
                        
                    }
                    catch(Exception e){
                        System.Debug('UpdateException--->'+e.getMessage());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    }
                }
            }
        }
        
    private void AddMessageToLog(list<contact> contactLst, String result, String message)
    {        
        list<LDAP_Log__c> ldapLogLst = new list<LDAP_Log__c>();
        for(contact conRec:contactLst){
            LDAP_Log__c log = new LDAP_Log__c();
            log.Contact__c = conRec.Id;
            log.Result__c = result;
            Log.Message__c = message;
            ldapLogLst.add(log);
        }
        insert ldapLogLst;
    }
    
     public class ContactWrapper{
        
        public Contact contact{get;set;}
        public Boolean selected{get;set;}
        public string validationTxt{get;set;}
        
        public ContactWrapper(Contact contact){
            this.Contact = contact;
            this.selected = false;
            this.validationTxt = 'Request not submitted';
        }
    }
    
}