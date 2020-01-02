global class GenesysConsuCommunityLoginController
{
    public String username {get; set;}
    public String password {get; set;}
    public Boolean err {get; set;}
    public static String SESSION_ID {get; set;}
    public static Boolean auth {get; set;}
    public list<Community__c> evnt_comm {get;set;}
    public list<Community__c> webnr_comm {get;set;}
    public list<Community__c> rfp_comm {get;set;}


    global PageReference forwardToAuthPage() {
        String startURL = System.currentPageReference().getParameters().get('startURL');
 
        if(Userinfo.getUserType() != 'Guest'){
           if(startURL == null || startURL == ''){
                startURL = '/ConsultantPortal/';
         } 
          return new PageReference(startURL);
         }
        
        return null;
   }
    
     static{
         SESSION_ID = userInfo.getSessionId();
         if(SESSION_ID!=null){
         auth = true;
         }else auth = false;
     }
    
    global PageReference loginCheck() 
    {
        String startURL = System.currentPageReference().getParameters().get('startURL');

        System.debug(' startURL>>>>>>>>>>>>>>>>>>>>>>> ' +startURL);

        if(startURL == null || startURL == ''){
           startURL = System.currentPageReference().getParameters().get('refURL');
           
           if(startURL == null || startURL == ''){
               //startURL = '/ConsultantPortal/CommunityPureCloudDev';
               startURL = '/CommunityPureCloudDev';
           }
           
        }
       
       System.debug(' startURL>>>>>>>>>>>>>>>>>>>>>>> 3' +startURL);
        
       PageReference communityLoginPage = Site.login(username, password, startURL);
       
       System.debug(' startURL>>>>>>>>>>>>>>>>>>>>>>> 4' +startURL);
       
       if (communityLoginPage == null)
            err=true;
            
       return communityLoginPage;
    }
    
    global GenesysConsuCommunityLoginController() {
          err = false; 
          evnt_comm  = [Select Name, Year__c, EventDate__c, Hyperlink__c, Location__c, Title__c  From Community__c where RecordType.Name='Events' and isActive__c= true order by Order__c asc Limit 100];
          webnr_comm = [Select Name, Year__c, EventDate__c, Hyperlink__c, Location__c, Title__c  From Community__c where RecordType.Name='Webinars' and isActive__c= true  order by Order__c asc  Limit 100];
          rfp_comm    = [Select Name, Year__c, EventDate__c, Hyperlink__c, Location__c, Title__c  From Community__c where RecordType.Name='RFP Templates' and isActive__c= true  order by Order__c asc  Limit 100];
    }

}