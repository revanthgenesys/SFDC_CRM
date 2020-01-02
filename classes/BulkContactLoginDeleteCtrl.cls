//Created by Mukunthan for Bulk Contact LDAP login deletion

public class BulkContactLoginDeleteCtrl{
    public string acctId{get;set;}
    public boolean selectAll{get;set;}
    public list<ContactWrapper> deleteConList{get;set;}
    public List<ContactWrapper> validConWrapLst{get;set;}
    private list<Id> accIDs = new list<Id>();
    private map<string, account> acctMap = new map<string, account>();
    private list<Id> refinedConIDList = new list<Id>();
    private list<Contact> updContactLst = new list<Contact>();
    private list<account> accLst = new list<account>();
    
    private static final string DELETE_NO_LOGIN_ERR_MSG = 'The web login cannot be deleted because a web login does not exist for this contact.  ';
    private static final string DELETE_NO_CONTACTID_ERR_MSG = 'A web login cannot be deleted because the contact does not have a ContactId.  ';
    private static final string DELETE_REQ_SUBMITTED = 'A Web Login request has been submitted already. ';
    
    public BulkContactLoginDeleteCtrl(){
        deleteConList = new list<ContactWrapper>();
        validConWrapLst = new list<ContactWrapper>();
        acctId = ApexPages.currentPage().getParameters().get('acctId');
        System.Debug('acctId--->'+acctId);
        if(!string.isBlank(acctId)){
            for(Contact conRec:[SELECT Id,Contact.FirstName,Contact.lastName,Account.Name,AccountId,Email,Contact_ID__c,Has_LDAP_Login__c,
                                Has_Requested_LDAP_Change__c FROM Contact WHERE AccountId =:acctId AND Has_LDAP_Login__c = true]){
                deleteConList.add(new ContactWrapper(conRec));
            }
        }
        System.Debug('deleteConList--->'+deleteConList);
    }
    
    public void procSelectedContacts(){
        try{
            for(ContactWrapper conWrap: deleteConList){
                if(conWrap.selected == true){
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
            for(ContactWrapper uncheckRec:deleteConList){
                uncheckRec.selected = false;
            }
            validConWrapLst = new list<ContactWrapper>();
            refinedConIDList = new list<Id>();
            updContactLst = new list<Contact>();
        }
    }

    public void validateAndRequestContacts(list<ContactWrapper> contWrprLst){
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
                if (eachconWrpr.contact.Has_LDAP_Login__c == false) 
                {
                    eachconWrpr.validationTxt = string.isBlank(eachconWrpr.validationTxt)?DELETE_NO_LOGIN_ERR_MSG:eachconWrpr.validationTxt + '; ' + DELETE_NO_LOGIN_ERR_MSG;
                    isError = true;
                }
                if (acctMap.get(eachconWrpr.Contact.AccountId).Account_Sub_Type__c != 'PureCloud Customer' && (eachconWrpr.Contact.Contact_ID__c == null || eachconWrpr.Contact.Contact_ID__c == ''))
                {
                    eachconWrpr.validationTxt = string.isBlank(eachconWrpr.validationTxt)?DELETE_NO_CONTACTID_ERR_MSG:eachconWrpr.validationTxt + '; ' + DELETE_NO_CONTACTID_ERR_MSG;
                    isError = true;
                }
                if (eachconWrpr.Contact.Has_Requested_LDAP_Change__c == true) 
                {
                    eachconWrpr.validationTxt = string.isBlank(eachconWrpr.validationTxt)?DELETE_REQ_SUBMITTED:eachconWrpr.validationTxt + '; ' + DELETE_REQ_SUBMITTED;
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
                        ldap.DeleteLogins(refinedConIDList);
                    }
                    
                    updContactLst = [Select Id,Has_Requested_LDAP_Change__c from Contact where Id IN:refinedConIDList];
                    AddMessageToLog(updContactLst,'Success',UserInfo.getName() + ' has requested the deletion of the web login.');
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
    
    public void selectAllContactsAndProc(){
        if(selectAll == true){
            for(ContactWrapper conWrap: deleteConList){
                conWrap.selected = true;
            }
        }
        else{
            for(ContactWrapper conWrap: deleteConList){
                conWrap.selected = false;
            }
        }
    }

    public pagereference cancelProc(){
        pagereference retToAcct = new pagereference('/'+acctId);
        retToAcct.setRedirect(true);
        return retToAcct;
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