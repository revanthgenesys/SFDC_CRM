global class knowLoginController
{
    public User commUser {get; set;}
    public User advisorUser  {get; set;}
    public User csmUser {get; set;}
    
    public String csmUserName {get; set;}
    public String advisorUserName {get; set;}
    
    public String csmAccountOwner {get; set;}

    public String username {get; set;}
    public String password {get; set;}
    public Boolean err {get; set;}
    public static String SESSION_ID {get; set;}
    public static Boolean auth {get; set;}
    
    public String pureEngPrem {get; set;}
    public String pureCnctPrem {get; set;}
    public String pureEngCld {get; set;}
    public String pureCnctCld {get; set;}
    public String pureCld {get; set;}
    public Boolean isPartner {get; set;}
    public String premMAC {get; set;}
    public String searchTxt {get; set;}
    private String partner {get; set;}       
    private static Map<String, Id> casetypesMap;
    public Boolean isInternalEmployee {get; set;}    
    public Boolean isaccessableToKnowledge {get; set;}
    public boolean isGKNOnlyUser {get;set;}    
    public String MyProflieName {get; set;} 
    public String uType {get; set;}
    public boolean ispureEngPrem {get; set;} 
    public boolean ispureEngCld {get; set;} 
    public boolean ispureCnctCld{get; set;} 
    public boolean ispureCld {get; set;} 
    public boolean IdeaCardAccess {get;set;}
    public boolean PureSuccessAccess {get;set;}
    private map<string,string> perms = new map<string,string>();
    public map<string,string> getperms(){return perms;}
    public string premisesPE{get;set;}
    public string cloudPE{get;set;}
    public string premisesPC{get;set;}
    public string cloudPC{get;set;}
    public string pCloud{get;set;}
    public static String assetPath { get; set; }
    public static String assetImgPath { get; set; }
    public transient  Blob file {set;get;}
    public String PureCloudCookie {get; set;}
    public String PureConnectCookie {get; set;}
    public String PureEngageCookie {get; set;}

    public knowLoginController() {
        commUser = new user();
        PureCloudCookie ='Cloud';
        ispureEngCld = false; 
        ispureEngPrem = false; 
        ispureCnctCld = false;  
        ispureCld = false; 
        isInternalEmployee = false;
        isGKNOnlyUser = false;
        isaccessableToKnowledge = false;
        csmAccountOwner = '';

        perms = ContactUtil.getPortalUserPermissionMap();
        
        if ( !perms.isEmpty() )  {
            pureEngPrem = perms.get('PureEngagePremise');
            pureEngCld = perms.get('PureEngageCloud');

            pureCnctPrem = perms.get('PureConnectPremise');
            pureCnctCld = perms.get('PureConnectCloud');
            
            pureCld = perms.get('PureCloud');
            
            partner = perms.get('PartnerAccess');
            premMAC = perms.get('PremiseMAC');
            
            if (partner.equals('Yes')) { 
                isPartner = true;
            }
        }
        
        premisesPE = pureEngPrem;
        cloudPE = pureEngCld;
        premisesPC = pureCnctPrem;
        cloudPC = pureCnctCld;
        pCloud = pureCld;
        
        System.debug('perms--->' + perms); 
          
        autoRun(); 
        
        //enable knowledgebase card
        if(premisesPE != 'None' || cloudPE != 'None' || premisesPC != 'None' || cloudPC != 'None' || pCloud != 'None' || isInternalEmployee){
            isaccessableToKnowledge = true;
        }

        if (pureEngCld != 'None' || isInternalEmployee) {
            ispureEngCld = true;
        }
        
        if (pureEngPrem != 'None' || isInternalEmployee) {
            ispureEngPrem = true;
        }
        
        if (pureCnctPrem!='None' || pureCnctCld !='None' || isInternalEmployee) {
            ispureCnctCld = true;
        }
        
        if (pureCld !='None' || isInternalEmployee) {
            ispureCld = true;
        }
        
        if (ispureCld) {
            ispureCld = true; 
            ispureEngCld = false; 
            ispureEngPrem = false;
            ispureCnctCld = false;
        } else if (ispureCnctCld) {
            ispureEngCld = false; 
            ispureEngPrem = false;
            ispureCnctCld = true;
        } else if (ispureEngCld) {
            ispureEngCld = true; 
            ispureEngPrem = false;
        }
          
        /*
        List<User> pubList = new List<User>([SELECT Id, Name, profile.Name FROM User where Name='Know Site Guest User' And Id=:userInfo.getUserId()])
        if(pubList.size()==0) */
        
        isPartnerUser();
        
        IdeaCardAccess = checkIdeaCardAccess(commUser.AccountId);
        PureSuccessAccess = checkPureSuccessAccess(commUser.ContactId);
        err = false; 
        
        assetPath = 'https://apps.mypurecloud.com/gkn/1.0.9/assets';
        assetImgPath = 'https://dhqbrvplips7x.cloudfront.net/gkn/1.0.9-39/assets';
    }
    
    static {
        SESSION_ID = userInfo.getSessionId();
                  
        if (SESSION_ID != null) {
            auth = true;
        } else {
            auth = false;
        }
       
        System.Debug('auth--->'+auth+';;'+SESSION_ID);
    }

    global PageReference forwardToAuthPage() {
        String startURL = System.currentPageReference().getParameters().get('startURL'); 
        
        if(Userinfo.getUserType() != 'Guest'){
            if(startURL == null || startURL == ''){
                startURL = '/know/KnowPureCloudHome';
            } 
            return new PageReference(startURL);
        }
         
        return null;
    }
 
    public boolean checkIdeaCardAccess(String accId){
        List<IdeaPermissionAccounts__c> ideaPermission = new List<IdeaPermissionAccounts__c>([select Id from IdeaPermissionAccounts__c where AccountId__c=:accId limit 1]);
        if (ideaPermission.size()>0) {
            return true; 
        }
        
        return false;
    }

    public boolean checkPureSuccessAccess(String contactId){
        List<Contact> conPerm = new List<Contact>([select id, Self_Service_Elements_Access__c, All_Service_Elements_Access__c, PureSuccess_Main_Contact__c from Contact where Id=:contactId limit 1]);
        if(conPerm.size()>0) {
            if (conPerm[0].Self_Service_Elements_Access__c || conPerm[0].All_Service_Elements_Access__c || conPerm[0].PureSuccess_Main_Contact__c) {
              return true;
            } 
        }
        
        return false;
    }
   
    /**
     * [loginCheck description]
     * @return [description]
     */
    global PageReference loginCheck() {
        String startURL = System.currentPageReference().getParameters().get('startURL');
        System.debug(' startURL ' +startURL);
       
        if(startURL == null || startURL == ''){
            startURL = System.currentPageReference().getParameters().get('refURL');
            if(startURL == null || startURL == '') {
                startURL = '/know/KnowCommunityPureCloudH';
            }
        }
        
        System.debug(' startURL2 ' +startURL);
        
        PageReference communityLoginPage = Site.login(username, password, startURL);
        
        if (communityLoginPage == null) {
            err = true;
        }
        
        return communityLoginPage;
    }
    
    public void isPartnerUser() {
        List<User> userList = new List<User>([SELECT Id, 
                                               IsActive,
                                               IsPortalEnabled,
                                               LastName, 
                                               UserType 
                                               FROM User where UserType='PowerPartner' And isActive=true And Id=:userInfo.getUserId()]);
                                               
        if (userList.size()>0) {
            isaccessableToKnowledge = true;
            ispureCld = true; 
            ispureEngCld = false; 
            ispureCnctCld = false;
          
            pureEngPrem = 'YES';
            pureEngCld  = 'YES';

            pureCnctPrem = 'YES';
            pureCnctCld = 'YES';
            
            pureCld = 'YES';
            
            partner = 'YES';
            premMAC = 'YES';
        }
        System.debug('commUser ' + commUser);
        System.debug('ispureEngCld ' + ispureEngCld);
        System.debug('ispureCnctCld ' + ispureCnctCld);
        System.debug('ispureCld ' + ispureCld);
        if (commUser!=null && userList.size()==0 && ispureEngCld == false && ispureCnctCld == false && ispureCld == false) {
            if (commUser.Contact.Account.AccountOfferingTypes__c!=null) {
                //isaccessableToKnowledge = false;
                isGKNOnlyUser = true;
              
                if (commUser.Contact.Account.AccountOfferingTypes__c.containsIgnoreCase('PureCloud'))   {
                    pureCld = 'YES';
                }
                
                if (commUser.Contact.Account.AccountOfferingTypes__c.containsIgnoreCase('PureEngage'))  {
                    pureEngPrem = 'YES';
                    pureEngCld = 'YES';
                }
                
                if (commUser.Contact.Account.AccountOfferingTypes__c.containsIgnoreCase('PureConnect')) {
                    pureCnctPrem = 'YES';
                    pureCnctCld = 'YES';
                }

                if (pureEngCld!='None') {
                    ispureEngCld = true;
                }
                
                if (pureEngPrem !='None') {
                    ispureEngPrem = true;
                }
                
                if (pureCnctPrem!='None' || pureCnctCld !='None') {
                    ispureCnctCld = true;
                }
                
                if (pureCld != 'None') {
                    ispureCld = true;
                }
                
                if (ispureCld) {
                    ispureCld = true; 
                    ispureEngCld = false; 
                    ispureEngPrem = false;
                    ispureCnctCld = false;
                } else if (ispureCnctCld) {
                    ispureEngCld = false; 
                    ispureEngPrem = false;
                    ispureCnctCld = true;
                } else if (ispureEngCld) {
                    ispureEngCld = true; 
                    ispureEngPrem = false;
                }
                
            } else {
                ispureCld = true; 
                ispureEngCld = false; 
                ispureEngPrem = false;
                ispureCnctCld = false;
            }
        }          
    }
    
    /**
     * [autoRun description]
     */
    public void autoRun() {
        commUser  = [select Id, Name,  PureCloudState__c, PureConnectState__c,PureEngageState__c, Contact.Ldap_Contact_Permissions__c, 
                      AccountId,Contact.Account.AccountOfferingTypes__c,UserType, Email,Title, ContactId, SmallPhotoUrl, FirstName, LastName, FullPhotoUrl from user 
                      where Id=:userInfo.getUserId() and isActive=true limit 1];
         
        if (commUser!=null) {
            uType = commUser.UserType;
            List<String> permissions  = new List<String>();

            if (!Test.isRunningTest()) {
                if(commUser.Contact.Ldap_Contact_Permissions__c!=null) {
                    System.debug('commUser.Contact.Ldap_Contact_Permissions__c' +commUser.Contact.Ldap_Contact_Permissions__c);
                    permissions = commUser.Contact.Ldap_Contact_Permissions__c.split(';'); 
                   
                    if (commUser.UserType!=null && (commUser.UserType=='Standard')) {   
                        isInternalEmployee = true;  
                    } 

                    List<Profile> PROFILE = new List<Profile>([SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1]);
                    
                    if(PROFILE.size()>0) {
                        MyProflieName = PROFILE[0].Name;
                    }

                    List<Account> acc  = null;
                    
                    if(commUser.AccountId != null) {
                        acc = new List<Account>([select Id, Advisor__c, CSM_Account_Owner__c from Account where Id=:commUser.AccountId]);
                    }
                 
                    if(acc != null && acc.size() > 0 && acc[0].Advisor__c != null) {
                        advisorUser = [select Id, Name, Email, Phone,Title from user where id=:acc[0].Advisor__c limit 1];
                        if (advisorUser.Name == 'Genesys Advisor') {
                            advisorUserName = 'Genesys Advisor Team';
                        } else {
                            advisorUserName = advisorUser.Name;
                        }
                    }                   
                    if(acc!=null && acc.size()>0 && acc[0].CSM_Account_Owner__c!=null) {
                        csmUser = [select Id, Name, Email, Phone,Title from user where id=:acc[0].CSM_Account_Owner__c limit 1];
                        if (csmUser.Name == 'Genesys Advisor') {
                            csmUserName = 'Genesys Advisor Team';
                        } else {
                            csmUserName = csmUser.Name;
                        }
                    }
                    if(acc!=null && acc.size()>0 && acc[0].CSM_Account_Owner__c!=null) {
                        csmAccountOwner = acc[0].CSM_Account_Owner__c;
                    }
                }
            }   
        }
    }

    /**
     * [saveRecord description]
     * @return [description]
     */
    public PageReference saveRecord() {
      System.debug('Inside the Saving the record Method' +commUser.Title);
      update commUser; 
      autoRun();
      return null;
    }
    
    public PageReference  savePureCloudState() {
        commUser.PureCloudState__c = PureCloudCookie;
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>PureCloudCookie' +PureCloudCookie);
        update commUser; 
        return null;
    }
    
    public PageReference  savePureConnectState() {
        commUser.PureConnectState__c = PureConnectCookie;
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>PureConnectCookie ' +PureConnectCookie);
        update commUser; 
        return null;
    }

    public PageReference  savePureEngageState() {
        commUser.PureEngageState__c = PureEngageCookie;
        System.debug('>>>>>>>>>>>>>>>>>>>>>>>>PureEngageCookie' +PureEngageCookie);
        update commUser; 
        return null;
    }

    public PageReference upload() { 
        Blob b = file;
        Attachment objA; 
        
        try {
            objA=new Attachment();
            objA.body = b;
            objA.name = UserInfo.getUserName();
            objA.parentid= commUser.ContactId;
            objA.ContentType = 'application/jpg';
            ConnectApi.CommunityPage pages = ConnectApi.Communities.getCommunities();
            String communityId = '';
            
            for(ConnectApi.Community comm :pages.communities){
                if (comm.Name == 'Know') {
                    communityId = comm.id;
                }
            }
        
            if(!Test.isRunningTest()){
                ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(communityId, UserInfo.getUserId(),  new ConnectApi.BinaryInput(b,'image/jpg','userImage.jpg'));
                insert objA;
            }
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
            return null;
        } finally {
            objA.body = null; // clears the viewstate
            objA = null;
        }

        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully : '+b));
     
        autoRun(); 
      
        return null;
    }
}