global class GenesysCommunityLoginController {

    
    public String username {get; set;}
    public String password {get; set;}
    public Boolean err {get; set;}
    global string retErrMsg{get;set;}
     global string loginFailUsrStatus{get;set;}

    global PageReference forwardToAuthPage() {
        String startURL = System.currentPageReference().getParameters().get('startURL');
 
        if(Userinfo.getUserType() != 'Guest'){
           if(startURL == null || startURL == ''){
                startURL = '/customercare/home/home.jsp';
         } 
         return new PageReference(startURL);
         }
        
        return null;
   }

    
    global PageReference loginCheck() {
        String startURL = System.currentPageReference().getParameters().get('startURL');
                if(startURL == null || startURL == ''){
                        startURL = System.currentPageReference().getParameters().get('refURL');
                        if(startURL == null || startURL == ''){
                                startURL = '/customercare/home/home.jsp';
                        }
                }       
          
        PageReference communityLoginPage = Site.login(username, password, startURL);
        if (communityLoginPage == null)
            err=true;
        return communityLoginPage;
    }
    
    global GenesysCommunityLoginController() {
          err = false; 
    }
    
    global void checkUserStatusOnLoginFailure(){
        string url = global_setting__c.getinstance('Okta UserVerification').Information__c;
        string authHeader = global_setting__c.getinstance('Okta AuthorizationHeader').Information__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url+username);
        request.setMethod('GET');
        request.setHeader('Authorization',authHeader);
        System.Debug('REQ--->'+request);
        HttpResponse response = http.send(request);
        System.Debug('RES--->'+response);
        retErrMsg = '';
        if (response.getStatusCode() == 200) {
           loginFailUsrStatus = (response.getBody()).remove('"');
            if(loginFailUsrStatus.equalsIgnoreCase('ACTIVE')){
                retErrMsg = 'One or more of the values you have entered is incorrect. Please verify your login information and try again.';
            }
            else if(String.isBlank(loginFailUsrStatus))
            {
                retErrMsg = 'One or more of the values you have entered is incorrect. Please verify your login information and try again.';
            }
            else if(loginFailUsrStatus.equalsIgnoreCase('LOCKED_OUT')){
                retErrMsg = 'One or more of the values you have entered is incorrect. Please verify your login information and try again.';
            }
            else if(loginFailUsrStatus.equalsIgnoreCase('RECOVERY') || loginFailUsrStatus.equalsIgnoreCase('PASSWORD_EXPIRED')){
                retErrMsg = 'Your password has expired.  Please click on Forgot Password to have a new password sent to you.';
            }
            else{
                retErrMsg = 'There appears to have been a system error.  Please try again.  If you are unable to log in, please contact us at customercare@genesys.com.';
            }
        }
    }

}