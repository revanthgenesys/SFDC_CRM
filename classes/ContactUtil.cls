public without sharing class ContactUtil {
  @TestVisible
  private static List<Support_Access__c> suppAccesses;
  private static List<Support_Access_Cloud__c> suppAccessCloud;
  private static List<Support_Product__c> supportProducts;
  @TestVisible  
  private static User currentUserInfo;
  private static Map<String, String> portalUserPermissionMap;
  
  private static void retrieveSupportAccessPremiseAll(ID ContactId) {      
      suppAccesses = new List<Support_Access__c>();
       
      if ( ContactId != null ) {
          suppAccesses = [SELECT End_User_Account__c, End_User_Account__r.Name, Sold_To_Account__c, Sold_To_Account__r.Name, 
                                 Back_Office_Account__c, Back_Office_Account__r.Name, BOA_Platform__c, SR_Access_Level__c, Status__c, 
                                 Service_Contract_Status__c, BOA_Support_Package__c, Back_Office_Account__r.Subscription__c 
                          FROM Support_Access__c 
                          WHERE Contact__c =: ContactId
                          ORDER BY End_User_Account__r.Name];
      }     
  }
   
  private static void retrieveSupportAccessCloudAll(ID ContactId) {
      suppAccessCloud = new List<Support_Access_Cloud__c>();
      
       if ( ContactId != null ) {
           suppAccessCloud = [SELECT Cloud_Deployment__c, Access_Status__c, Access_Level__c, CD_Platform__c 
                              FROM Support_Access_Cloud__c 
                              WHERE Contact__c = :ContactId];                                   
       }    
  }
  
  public static Map<String, String> getPortalUserPermissionMap () {
       if ( portalUserPermissionMap != null )
          return portalUserPermissionMap;
       
       if ( currentUserInfo == null )
          getCurrentUser();
          
        if ( suppAccesses == null ) 
            retrieveSupportAccessPremiseAll(currentUserInfo.contactid);
        
        if ( suppAccessCloud == null )
         retrieveSupportAccessCloudAll(currentUserInfo.contactid);
         
        portalUserPermissionMap = new Map<String, String>{'PureEngagePremise'  => 'None',
                                                         'PureConnectPremise' => 'None',
                                                         'PureEngageCloud'    => 'None',
                                                         'PureConnectCloud'   => 'None',
                                                         'PureCloud'          => 'None',
                                                         'PartnerAccess'      => 'None',
                                                         'PureCnctPremMngSrv' => 'None',
                                                         'PureEngPremMngSrv'  => 'None',
                                                         'UsageFileUpload'    => 'None'};                                                                                                                     
        //Premise
       for (Support_Access__c sa : suppAccesses ) {
          if ( sa.Status__c != 'Active' )  //&& sa.Service_Contract_Status__c != 'Active')
              continue;
        
          if ( sa.BOA_Platform__c == 'PureEngage On Premise' )  {
            
              if ( sa.SR_Access_Level__c == 'Read/Write' )  {
                   if ( sa.Back_Office_Account__r.Subscription__c )
                     portalUserPermissionMap.put('UsageFileUpload', 'Yes');
              
                  if ( portalUserPermissionMap.get('PureEngagePremise') != 'Read/Write' )  
                         portalUserPermissionMap.put('PureEngagePremise', 'Read/Write'); 
                         
                  if ( sa.BOA_Support_Package__c == 'Managed Services' && portalUserPermissionMap.get('PureEngPremMngSrv') != 'Read/Write' )  
                        portalUserPermissionMap.put('PureEngPremMngSrv', 'Read/Write');
            
                  continue;
              }
              else if ( sa.SR_Access_Level__c == 'Read Only' ) {
               
                   if ( portalUserPermissionMap.get('PureEngagePremise') == 'None' || portalUserPermissionMap.get('PureEngagePremise') == 'Basic' )  
                     portalUserPermissionMap.put('PureEngagePremise', 'Read Only');
                     
                   if ( sa.BOA_Support_Package__c == 'Managed Services' &&                      
                        (portalUserPermissionMap.get('PureEngPremMngSrv') == 'None' || portalUserPermissionMap.get('PureEngPremMngSrv') == 'Basic') )  
                            portalUserPermissionMap.put('PureEngPremMngSrv', 'Read Only');
                                             
                   continue;
              }
              else if ( sa.SR_Access_Level__c == 'Basic' && portalUserPermissionMap.get('PureEngagePremise') == 'None' )  {                 
                   portalUserPermissionMap.put('PureEngagePremise', 'Basic');                 
                   continue;
              }
              
         }
         else if ( sa.BOA_Platform__c == 'PureConnect On Premise' )  {
            
              if ( sa.SR_Access_Level__c == 'Read/Write' ) { 
                   if ( portalUserPermissionMap.get('PureConnectPremise') != 'Read/Write' )
                       portalUserPermissionMap.put('PureConnectPremise', 'Read/Write');
                    
                   if ( sa.BOA_Support_Package__c == 'Managed Services' && portalUserPermissionMap.get('PureCnctPremMngSrv') != 'Read/Write' )  
                        portalUserPermissionMap.put('PureCnctPremMngSrv', 'Read/Write');
                        
                   if ( sa.Back_Office_Account__r.Subscription__c ) 
                      portalUserPermissionMap.put('UsageFileUpload', 'Yes');
    
                   continue;
              }
              else if ( sa.SR_Access_Level__c == 'Read Only' ) { 
                   
                   if ( portalUserPermissionMap.get('PureConnectPremise') == 'None' || portalUserPermissionMap.get('PureConnectPremise') == 'Basic' )
                          portalUserPermissionMap.put('PureConnectPremise', 'Read Only');

                   if ( sa.BOA_Support_Package__c == 'Managed Services' &&                      
                        (portalUserPermissionMap.get('PureCnctPremMngSrv') == 'None' || portalUserPermissionMap.get('PureCnctPremMngSrv') == 'Basic') )  
                            portalUserPermissionMap.put('PureCnctPremMngSrv', 'Read Only');
                      
                   continue;
              }
              else if ( sa.SR_Access_Level__c == 'Basic' && portalUserPermissionMap.get('PureConnectPremise') == 'None' )  {
                   portalUserPermissionMap.put('PureConnectPremise', 'Basic');
                   continue;
              }
         }
       } 
       
       /// Cloud
       for (Support_Access_Cloud__c sa : suppAccessCloud ) {
          if ( sa.Access_Status__c != 'Active' )  
              continue;
        
          if ( sa.CD_Platform__c == 'PureEngage' )  {
              if ( sa.Access_Level__c == 'Read/Write' && portalUserPermissionMap.get('PureEngageCloud') != 'Read/Write' )  {
                   portalUserPermissionMap.put('PureEngageCloud', 'Read/Write');
                   continue;
              }
              else if ( sa.Access_Level__c == 'Read Only' && 
                    (portalUserPermissionMap.get('PureEngageCloud') == 'None' || portalUserPermissionMap.get('PureEngageCloud') == 'Basic') )  {
                   portalUserPermissionMap.put('PureEngageCloud', 'Read Only');
                   continue;
              }
              else if ( sa.Access_Level__c == 'Basic' && portalUserPermissionMap.get('PureEngageCloud') == 'None' )  {
                   portalUserPermissionMap.put('PureEngageCloud', 'Basic');
                   continue;
              }
         }
         else if ( sa.CD_Platform__c == 'PureConnect' )  {
              if ( sa.Access_Level__c == 'Read/Write' && portalUserPermissionMap.get('PureConnectCloud') != 'Read/Write' )  {
                   portalUserPermissionMap.put('PureConnectCloud', 'Read/Write');
                   continue;
              }
              else if ( sa.Access_Level__c == 'Read Only' && 
                       (portalUserPermissionMap.get('PureConnectCloud') == 'None' || portalUserPermissionMap.get('PureConnectCloud') == 'Basic' ) )  {
                   portalUserPermissionMap.put('PureConnectCloud', 'Read Only');
                   continue;
              }
              else if ( sa.Access_Level__c == 'Basic' && portalUserPermissionMap.get('PureConnectCloud') == 'None' )  {
                   portalUserPermissionMap.put('PureConnectCloud', 'Basic');
                   continue;
              }
         }
         else if ( sa.CD_Platform__c == 'PureCloud' )  {
              if ( sa.Access_Level__c == 'Read/Write' && portalUserPermissionMap.get('PureCloud') != 'Read/Write' )  {
                   portalUserPermissionMap.put('PureCloud', 'Read/Write');
                   continue;
              }
              else if ( sa.Access_Level__c == 'Read Only' && 
                     (portalUserPermissionMap.get('PureCloud') == 'None' || portalUserPermissionMap.get('PureCloud') == 'Basic') )  {
                   portalUserPermissionMap.put('PureCloud', 'Read Only');
                   continue;
              }
              else if ( sa.Access_Level__c == 'Basic' && portalUserPermissionMap.get('PureCloud') == 'None' )  {
                   portalUserPermissionMap.put('PureCloud', 'Basic');
                   continue;
              }
         }
       } 
       
       ///Partner
      if ( currentUserInfo.Profile.Name.contains('Partner') )
         portalUserPermissionMap.put('PartnerAccess', 'Yes');
    
       return portalUserPermissionMap;
  }
     
  public static List<Support_Access__c> getRWSupprtAccLstByContact(ID ContactId) {
      if ( suppAccesses == null )
         retrieveSupportAccessPremiseAll(ContactId);

      List<Support_Access__c> retList = new List<Support_Access__c> ();
      for (Support_Access__c sa : suppAccesses ) {
         if ( sa.SR_Access_Level__c == 'Read/Write' && sa.Status__c == 'Active' && sa.Service_Contract_Status__c == 'Active')
            retList.add(sa);
      }

      return retList;
  }
  
  public static List<Support_Access__c> getAllActiveSupprtAccLstByContact(ID ContactId) {
      if ( suppAccesses == null )
         retrieveSupportAccessPremiseAll(ContactId);

      List<Support_Access__c> retList = new List<Support_Access__c> ();
      
      /// include contracts in any status
      for (Support_Access__c sa : suppAccesses ) {
         if ( (sa.SR_Access_Level__c == 'Read/Write' || sa.SR_Access_Level__c == 'Read Only') && sa.Status__c == 'Active' )                
            retList.add(sa);
      }

      return retList;
  }
  
  public static List<Cloud_Deployment__c> getUserCloudDepl() {
    /// Access Read/Write
     if ( currentUserInfo == null )
        getCurrentUser();
        
     if ( suppAccessCloud == null )
         retrieveSupportAccessCloudAll(currentUserInfo.contactid);
         
     List<Cloud_Deployment__c> cloudDeplts = new List<Cloud_Deployment__c>();
     List<Id> cldIDs = new List<Id>();
     
     for ( Support_Access_Cloud__c sa : suppAccessCloud )  {
        if ( sa.Access_Status__c == 'Active' && sa.Access_Level__c == 'Read/Write' )
              cldIDs.add(sa.Cloud_Deployment__c);
     }
           
     if ( !cldIDs.isEmpty() ) {
         
        cloudDeplts = [SELECT Id, Name, Account__r.Name, Account__c, Cloud_Offering__c, Support_Status__c, Cloud_Platform__c
                        FROM Cloud_Deployment__c WHERE Support_Status__c != 'Billing Only' 
                        AND Support_Status__c != 'Order Processing' AND Id IN :cldIDs
                        ORDER BY Name];
        
     }             
     return cloudDeplts;
  }
  
  public static List<Cloud_Deployment__c> getAllActiveCloudDeplByContId(ID contactId) {
    /// Access Read/Write and Read/Only
     if ( suppAccessCloud == null )
         retrieveSupportAccessCloudAll(contactId);
         
     List<Cloud_Deployment__c> cloudDeplts = new List<Cloud_Deployment__c>();
     List<Id> cldIDs = new List<Id>();
     
     for ( Support_Access_Cloud__c sa : suppAccessCloud )  {
        if ( sa.Access_Status__c == 'Active' && (sa.Access_Level__c == 'Read/Write' || sa.Access_Level__c == 'Read Only') )
              cldIDs.add(sa.Cloud_Deployment__c);
     }
           
     if ( !cldIDs.isEmpty() ) {
         
        cloudDeplts = [SELECT Id, Name, Account__r.Name, Account__c, Cloud_Offering__c, Support_Status__c, Cloud_Platform__c
                        FROM Cloud_Deployment__c WHERE Support_Status__c != 'Billing Only' 
                        AND Support_Status__c != 'Order Processing' AND Id IN :cldIDs
                        ORDER BY Name];
        
     }             
     return cloudDeplts;
  }
  
  // copy accounts parent id to contacts Employer field - executed on insert and onchange of account on contacts
  public static void updateContactsEmployer(Set<Id> accountIds, List<Contact> contacts, Map<Id,Contact> oldMap){
    if(!accountIds.isEmpty()){
        //Naresh Kumar	08/07/18	Fixing 101 SOQL Error. Below SOQL is not used anywhere.
      	//Map<Id, Account> accountsMap = new Map<Id, Account>([Select Id,ParentId,Account.RecordType.DeveloperName from Account where Id IN: accountIds]);
      	Set<Id> contsIds = new Set<Id>();

      // wsmith Fixing null pointer exception for insert of new Contact
      // The original code below assumed the Contact will be updated and
      // checks for an entry in the oldMap which would be null
      for(Contact eachContact : contacts) {
        if (null != oldMap) {
          // wsmith .. assume an update is happening when oldMap is not null
          if(eachContact.accountId != oldMap.get(eachContact.id).accountId) {
            contsIds.add(eachContact.id);
          }
        }
        else {
          // wsmith .. I assume this is an insert and we use the current contact account
          contsIds.add(eachContact.id);
        }
      }
      //Naresh Kumar	08/06/2018	Fixing 101 SOQL Error. Adding condition - No need to call SOQL if the set is empty.
      if(!contsIds.isEmpty()){
      	contacts = [SELECT accountId, Account.RecordType.DeveloperName, Employer__c FROM Contact WHERE id in : contsIds];
        
          for(Contact con : contacts){
             if (con.accountId != null)
                 con.Employer__c = con.accountId;
          }
             
          if(!contacts.isEmpty())
            update contacts;
      }
    }
  }
  
  // associate the contact to its matching account based on their email domains- fired on insert
  public static void populateContactsAccountId(List<Contact> contacts){
    Map<String, contact> contactsMap = new Map<String, Contact>();
    for(Contact con : contacts){
      // to check if the contact is created from Web
      if(con.is_Created_From_Site__c){
        if(con.Email != null){
          Integer i = con.email.indexOfIgnoreCase('@');
          system.debug(i);
          if(i!=-1){
              String emailDomain = con.email.substring(i+1, con.email.length()) ;
              system.debug(emailDomain);
            contactsMap.put( emailDomain , con);
          }
        }
      }
    }
    system.debug(contactsMap);
    // if emaildomains to contacts map is not empty
    if(!contactsMap.isEmpty()){
      //Naresh Kumar	08/06/2018	Fixing 101 SOQL issue	Commenting below SOQL and using custom label to store Holding Account id.  
      //Account  holdingAcc = [Select Id from Account where Name='Holding Account' LIMIT 1];
      Id holdingAccId = Label.Holding_Account_Id;
      Map<String, Email_Domain__c> matchNameToEdomain = new Map<String, Email_Domain__c>();
      system.debug(contactsMap.keySet());
      // query for all emaildomains for the contacts emails
      for(Email_Domain__c e : [Select Account__c, Account__r.ParentId, Match_Domain_Name__c 
                   from Email_Domain__c where Match_Domain_Name__c IN :contactsMap.keySet() ]){
      system.debug(e);
        matchNameToEdomain.put(e.Match_Domain_Name__c, e);
      }
      
      // loop through contacts emails domain to see if they have a matching domain, 
      //if they do attach the contact to that respective account else attach it to holding account
      for(String emailDomain :contactsMap.keySet() ){
        Contact con = contactsMap.get(emailDomain);
        system.debug(matchNameToEdomain);
        system.debug(matchNameToEdomain.get(emailDomain) );
        if(matchNameToEdomain.get(emailDomain) == null){
          con.AccountId  = holdingAccId;
          con.Status__c = 'Pending';
        }
        else{
          con.AccountId = matchNameToEdomain.get(emailDOmain).Account__c;
          con.Employer__c = matchNameToEdomain.get(emailDomain).Account__r.ParentId;
        }
      }
    }
  }
  
  // for existing contacts, if the account name is changed from holding account to the correct account, create the email domain if it does not exist
  public static void createEmailDomains(Map<Id, Contact> oldMap, List<Contact> newContacts){
    //Naresh Kumar	08/06/2018	Fixing 101 SOQL issue	Commenting below SOQL and using custom label to store Holding Account id.  
    //Account  holdingAcc = [Select Id from Account where Name='Holding Account' LIMIT 1];    
    Id holdingAccId = Label.Holding_Account_Id;
    Map<Contact, Id> contactToAccountId = new Map<Contact, Id>();
    
    for( Contact con : newContacts ){
      Contact oldCon = oldMap.get(con.Id);
      if(con.AccountId != oldCon.AccountId && oldCon.AccountId == holdingAccId && con.AddToEmailDomain__c){
          contactToAccountId.put(con, con.AccountId);
      }
    }
    if(!contactToAccountId.isEmpty()){
      Map<Id, Id> accountIdToParentId = new Map<Id, Id>();
      for(Account a : [Select Id, Parentid from Account where Id IN :contactToAccountId.values() and Parent.RecordType.DeveloperName Like '%Group%']){
        accountIdToParentId.put(a.Id, a.ParentId);
      }
      
      Map<String, Email_Domain__c> matchDomainToEmailDomain = new Map<String, Email_Domain__c>();
      for(Email_Domain__c ed : [Select Id, Match_Domain_Name__c from Email_Domain__c where Account__c IN :accountIdToParentId.values()]){
        matchDomainToEmailDomain.put( ed.Match_Domain_Name__c, ed);
      }
      List<Email_Domain__c> edomainsToInsert = new List<Email_Domain__c>();
      for( Contact con : contactToAccountId.keySet()){
        if(con.Email != null){
          Integer i = con.email.indexOfIgnoreCase('@');
          if(i!=-1){
              String emailDomain = con.email.substring(i+1, con.email.length());
              if(!matchDomainToEmailDomain.containsKey(emailDomain)){
                if(accountIdToParentId.get(con.accountId) != null)
                  edomainsToInsert.add(new Email_Domain__c(Name=emailDomain, Match_Domain_Name__c=emailDomain, account__c=accountIdToParentId.get(con.accountId)));
              }
          }
        }
      }
      if(!edomainsToInsert.isEmpty())
        insert edomainsToInsert;  
    }  
  }
  
  private static void getCurrentUser() {
    currentUserInfo =  [SELECT Id, ContactId, IsPortalEnabled, SB_Customer__c, GCAP_User__c, Profile.Name
                        FROM User WHERE ID = :UserInfo.getUserId()];        
    return;
  }
  
  public static ID getUserContactId () {
    if ( currentUserInfo == null )
        getCurrentUser();
     
     return  currentUserInfo.contactid; 
  }
  public static Boolean isCloudUser () {
    if ( currentUserInfo == null )
        getCurrentUser();
     
     return  isCaseContactCloud(currentUserInfo.contactid) ; 
  }
  public static Boolean isPortalUser() {
    if ( currentUserInfo == null )
        getCurrentUser();
    
        if ( currentUserInfo.IsPortalEnabled == true )
            return true;
        else
            return false; 
  }
  public static Boolean isPremiseUser () {
    if ( currentUserInfo == null )
        getCurrentUser();
     
     return  isCaseContactPremise(currentUserInfo.contactid) ; 
  }
  
  public static Boolean isCaseContactPremise(Id ContactId) {
    Boolean premRWaccess = false;
    
    if ( suppAccesses == null )
         retrieveSupportAccessPremiseAll(ContactId);

      for (Support_Access__c sa : suppAccesses ) {
         if ( sa.SR_Access_Level__c == 'Read/Write' && sa.Status__c == 'Active' ) {                               
            premRWaccess = true;
            break;
         }
      }
    
    return premRWaccess;
  }
  
 public static Boolean isPremiseReadOnlyUser () {
    Boolean premROaccess = false;
    if ( currentUserInfo == null )
        getCurrentUser();
        
    if ( suppAccesses == null )
         retrieveSupportAccessPremiseAll(currentUserInfo.contactid);
    
     for (Support_Access__c sa : suppAccesses ) {
         if ( sa.SR_Access_Level__c == 'Read Only' && sa.Status__c == 'Active' ) {
            premROaccess = true;
            break;
         }
      }
    
    return premROaccess;  
  }
  
 public static Boolean isCloudReadOnlyUser() {
    /// Read Only cloud access
    Boolean cldROaccess = false;
    if ( currentUserInfo == null )
        getCurrentUser();
        
     if ( suppAccessCloud == null )
         retrieveSupportAccessCloudAll(currentUserInfo.contactid);

     for ( Support_Access_Cloud__c sa : suppAccessCloud )  {
        if ( sa.Access_Status__c == 'Active' && sa.Access_Level__c == 'Read Only' ) {
            cldROaccess = true;
            break;
        }           
     }
        
    return cldROaccess;  
  } 
  
  public static Boolean isCaseContactCloud(Id ContactId) {
    ///R/W access
    Boolean cldWRaccess = false;
    
     if ( suppAccessCloud == null )
         retrieveSupportAccessCloudAll(ContactId);

     for ( Support_Access_Cloud__c sa : suppAccessCloud )  {
        if ( sa.Access_Status__c == 'Active' && sa.Access_Level__c == 'Read/Write' ) {
            cldWRaccess = true;
            break;
        }           
     }
        
    return cldWRaccess;  
  } 
    
  public static Boolean isSBContact() {
    if ( currentUserInfo == null )
        getCurrentUser();
        
    if ( currentUserInfo.SB_Customer__c == true )
            return true;
        else
            return false;
  }

  public static Boolean isGCAPuser() {
    if ( currentUserInfo == null )
        getCurrentUser();
 
    if ( currentUserInfo.GCAP_User__c == true )
            return true;
        else
            return false;
  }
  
  public static void validateTrainingAccess(List<Contact> newList, Map<Id, Contact> oldMap) {
        Map<Id,Contact> mapUpdatedContacts = new  Map<Id,Contact>();
        Map<Id, User> mapActivePortalUsers = new Map<Id, User>();
        List<Id> lstActPortalUserIds = new List<Id>();
        Set<Id> PermSetAssignmentIds = new Set<Id>();
        
        for(contact cnt : newList) {
            if(cnt.Training_Access__c == true && oldMap.get(cnt.Id).Training_Access__c == false) {
                mapUpdatedContacts.put(cnt.Id,cnt);    
            }
        }  
        if(!mapUpdatedContacts.isEmpty()) {
            List<User> lstActivePortalUsers = new List<User>([select Id, contactId,profile.Name from user where isActive = true and contactId in: mapUpdatedContacts.keySet()]);
            for(user usr : lstActivePortalUsers) {
                mapActivePortalUsers.put(usr.ContactId,usr);
                lstActPortalUserIds.add(usr.Id);
            }
            
            if(!lstActPortalUserIds.isEmpty()) {
                List<PermissionSetAssignment>  lstPermSetAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: PartnerPortalUtil.PARTNER_PORTAL_PERMISSIONSET_ID and AssigneeId in: lstActPortalUserIds];
                for(PermissionSetAssignment psa : lstPermSetAssignment) {
                    PermSetAssignmentIds.add(psa.AssigneeId);       
                } 
            }
            
            for(Id cntId : mapUpdatedContacts.keySet()) {
              if(mapUpdatedContacts.get(cntId).status__c != null && mapUpdatedContacts.get(cntId).status__c != '' && mapUpdatedContacts.get(cntId).status__c == 'Active') {
                if(mapActivePortalUsers.containsKey(cntId) && mapActivePortalUsers.get(cntId).profile.Name != PartnerPortalUtil.GOLD_PARTNER_PROFILE_NAME) {
                    if(!PermSetAssignmentIds.contains(mapActivePortalUsers.get(cntId).Id)) {
                        mapUpdatedContacts.get(cntId).addError('Training Access cannot be enabled for the contact which does not have portal access');      
                    }
                }
                else if(!mapActivePortalUsers.containsKey(cntId)) {
                    mapUpdatedContacts.get(cntId).addError('Training access cannot be enabled. Contact does not have partner portal access.');    
                }
              }
              else {
                 mapUpdatedContacts.get(cntId).addError('Training access cannot be enabled. Contact status is not Active');
              }
                
            }
        } 
    } 
    
    private static Boolean CheckDefaultPerms(String perms) {
        if (perms != null) {
            if (perms.contains('Education')) {
                return true;
            }       
        }
        return false;
    }
    
    // Method migrated from ININ ContactManagement    
    public static void UpdateContactPermissionsInLdap(List<Contact> contacts, Map<Id,Contact> oldMap){   
        List<Id> contactIds = new List<Id>();   
        List<Id> createIds = new List<Id>();
        
        Set<string> accountIds = new Set<string>();
        for(Contact c : contacts){
            if(!accountIds.Contains(c.AccountId)){
                accountIds.add(c.AccountId);
            }
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Type FROM Account Where Id IN : accountIds]);
                
        for(Contact cont : contacts){
            if(cont.Has_Ldap_Login__c){                
                if(oldMap != null){
                    Contact oldContact = oldMap.get(cont.Id);
                     //Contact exists already
                    if(oldContact != null){
                        if(oldContact.Ldap_Contact_Permissions__c != cont.Ldap_Contact_Permissions__c || oldContact.Ldap_Pricesheet_Permissions__c != cont.Ldap_Pricesheet_Permissions__c){  
                            contactIds.add(cont.Id);   
                        }
                    }
                    // If the contact didn't exist before, we only need to sync when permissions are present
                    else if (!String.isEmpty(cont.Ldap_Contact_Permissions__c) || !String.isEmpty(cont.Ldap_Pricesheet_Permissions__c)){                        
                        contactIds.add(cont.Id);   
                    }
                }
                // If the contact didn't exist before, we only need to sync when permissions are present
                else if (!String.isEmpty(cont.Ldap_Contact_Permissions__c) || !String.isEmpty(cont.Ldap_Pricesheet_Permissions__c))
                {                     
                    contactIds.add(cont.Id);   
                }
            }
            // THIS IS SPECIFIC FOR THE LEARNING ACCESS REQUESTS
            // only worry about updates, not inserts
            else if ((oldMap != null) && (oldMap.get(cont.Id) != null)){
                Contact oldContact = oldMap.get(cont.Id);
                // Create an LDAP login only if the only permission is Education and the contact is tied to a partner, customer, consultant, or alliance
                
                if(CheckDefaultPerms(cont.Ldap_Contact_Permissions__c) && (oldContact.Ldap_Contact_Permissions__c != cont.Ldap_Contact_Permissions__c)){
                    createIds.add(cont.Id);
                    Account a = accounts.get(cont.AccountId);
                    // Is the account a partner, customer, consultant, or alliance
                    if (a != null)
                    {
                        if (Utility.IsSyncedAccountType(a.Type))
                        {
                            createIds.add(cont.Id);
                        }
                    }
                }
            }
        }
        // Cannot be included from Batch or Future calls                
        if(contactIds.size() > 0 && !System.isFuture() && !System.isBatch()){   
            // add contacts to Azure Queue
            LdapManagement.UpdatePermissionsAsync(contactIds);
        }
                
        if(createIds.size() > 0 && !System.isFuture() && !System.isBatch()) {   
            // add contacts to Azure Queue only if this is an update, an insert is handled else where.
            LdapManagement.CreateLoginsAsync(createIds);
        }
    }
    
    private static void UpdateContactInLdap(List<Contact> contacts, Map<Id,Contact> oldMap)
    {   
        List<Id> contactIds = new List<Id>();
                    
        if(oldMap != null)
        {
            for(Contact c : contacts)
            {
                if(c.Has_Ldap_Login__c)
                {    
                    Contact oldContact = oldMap.get(c.Id);
                    // Update to existing contact
                    if(oldContact != null) 
                    {
                        // Only update when certain fields change
                        if(c.FirstName != oldContact.FirstName ||
                           c.LastName != oldContact.LastName ||
                           c.AccountId != oldContact.AccountId ||
                           c.Contact_ID__c != oldContact.Contact_ID__c)
                        {  
                            contactIds.add(c.Id);   
                        }
                    }
                }
            } 
                
            if(contactIds.size() > 0 && !System.isFuture() && !System.isBatch()) // Cannot be included from Batch or Future calls
            {   
                // add contacts to Azure Queue
                LdapManagement.UpdateLoginsAsync(contactIds);
            }          
        }
    }

    private static void RemoveLogins(List<Contact> contacts, Map<Id, Contact> oldMap)
    {
        List<Id> contactIds = new List<Id>();

        for(Contact c : contacts)
        {
                if(c.Has_Ldap_Login__c)
                {    
                    contactIds.add(c.Id); 
                }
        }
        
        if(contactIds.size() > 0)
        {   
            // add contacts to Azure Queue for deletion
            LdapManagement.DeleteLoginsAsync(contactIds);
        }   
    }
    
    public static void AfterUpdate(List<Contact> contacts, Map<Id,Contact> oldMap)
    {      
        ContactUtil.UpdateContactPermissionsInLdap(contacts,oldMap);
        ContactUtil.UpdateContactInLdap(contacts, oldMap);
    }
    
    public static void AfterInsert(List<Contact> contacts)
    {   
        ContactUtil.UpdateContactPermissionsInLdap(contacts,null);
        //ContactUtil.CreateLdapLogins(contacts);
    }
            
    public static void BeforeInsert(List<Contact> contacts)
    {
        //ContactUtil.GrantBasePermissions(contacts, null);        
    }
    
    public static void BeforeDelete(List<Contact> oldContacts, Map<Id,Contact> oldMap)
    {
        ContactUtil.RemoveLogins(oldContacts, oldMap);
    }
    
    //Sep 8 - Anju - Update Contact Mailing Country, city and state from custom fields starts
    public static void UpdateMailingAddress(List<Contact> contacts)
    {
        Set<id> SetCountryIds = new Set<id>();
        
        for(Contact objCon : contacts){
            if(String.isblank(objCon.MailingCountry) && String.isnotblank(objCon.Country__c)){
                SetCountryIds.add(objCon.Country__c);
            }
            if(String.isblank(objCon.Mailingstate) && String.isnotblank(objCon.StateProvince__c)){
                objCon.Mailingstate = objCon.StateProvince__c;
            }
        } 
        //Naresh Kumar	08/06/2018	Fixing 101 SOQL Issue - Adding a condition to ignore SOQL call if the set is empty.
        if(!SetCountryIds.isEmpty()){
            Map<id, Country__c> MapCountry = new Map<id,Country__c>([Select id, name from Country__c where id in :SetCountryIds]);
            for(Contact objCon : contacts){
                if(String.isblank(objCon.MailingCountry) && String.isnotblank(objCon.Country__c)){
                    if(MapCountry.containskey(objCon.Country__c))
                        objCon.MailingCountry = MapCountry.get(objCon.Country__c).name;
                }
            }     
        }
    }
    //Sep 8 - Anju - Update Contact Mailing Country, city and state from custom fields ends
    //Added by RSystems on 04/25/2018 to check the PureSuccess Main Contact
    //It will not work in Bulk Upload as error can't be shown
    public static string CheckMainContact(List<Contact> objNew , List<Contact> objOld)
    {
      //boolean isExist = false;
      string sConName ;
      if(objNew.size()<= 1)
      {
       if(objNew[0].PureSuccess_Main_Contact__c != objOld[0].PureSuccess_Main_Contact__c && objNew[0].PureSuccess_Main_Contact__c)
       {
         
         List<Contact>list_Con = [select id,PureSuccess_Main_Contact__c,Name from Contact where Accountid =: objNew[0].AccountId];
         for(Contact objCon : list_Con)
         {
            if(objCon.id != objNew[0].id && objCon.PureSuccess_Main_Contact__c)
            {
              sConName = objCon.Name;
            }
         }
       }
       }
       return sConName;
    }
    
    
    // Added By: Ashish (07/20/2018)
    // Desc: To populate the offering type from account at the time of contact creation
    
    public static void populateOfferingTypeOnContact(List<Contact> list_Contacts){
        system.debug('Enter in method');
        Map<Id,List<Contact>> map_AccountIdContactList = new Map<Id,List<Contact>>();
        for(Contact con : list_Contacts){
            if(con.accountId != NULL){
                if(!map_AccountIdContactList.containsKey(con.accountId)){
                    map_AccountIdContactList.put(con.accountId, new List<Contact>());
                }
                map_AccountIdContactList.get(con.accountId).add(con);
            }
        } 
        //for(Account acc : [SELECT Id, AccountOfferingType__c FROM Account WHERE ID IN :map_AccountIdContactList.KeySet() AND AccountOfferingType__c != NULL]){
        for(Account acc : [SELECT Id, Offering_Type__c FROM Account WHERE ID IN :map_AccountIdContactList.KeySet() AND Offering_Type__c != NULL]){
            string firstOfferType;
            string remaingOfferType;
            if(acc.Offering_Type__c.indexOf(';') != -1){
                firstOfferType = acc.Offering_Type__c.subString(0, acc.Offering_Type__c.indexOf(';'));
                remaingOfferType = acc.Offering_Type__c.subString(acc.Offering_Type__c.indexOf(';')+1);
            }else{
                firstOfferType = acc.Offering_Type__c;
            }
            for(Contact con : map_AccountIdContactList.get(acc.Id)){
                con.Primary_offering__c = firstOfferType;
                if(remaingOfferType != null)
                    con.Additional_Offering__c = remaingOfferType;
            }
        }
    }
    
}