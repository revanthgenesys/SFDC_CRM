global with sharing class PartnerLoginController {
    global String username{get;set;}
    global String password{get;set;}
    global string loginFailUsrStatus{get;set;}
    global string retErrMsg{get;set;}
    global Boolean rememberMe {get;set;}
    global String firstName {get;set;}
    global String lastName {get;set;}
    global String companyName {get;set;}
    global String countryName {get;set;}
    global String email {get;set;}
    global String pageType {get;set;}
    global String title {get;set;}
    global String companyLabel {get;set;}
    global Boolean requestSubmitted {get;set;}
    global List<SelectOption> countries {get;set;}
    global Boolean verified { get; private set; }
    global String jobTitle {get; set;}
    
    global String partnerType {get; set;}
    
    private string strURL='';
    global PartnerLoginController (){  
        strURL = ApexPages.currentPage().getParameters().get('startURL');    
        Cookie userNameC = ApexPages.currentPage().getCookies().get('username');
        this.verified = false;
        
        if(userNameC != null)
            userName = userNameC.getValue();
        pageType = ApexPages.currentPage().getParameters().get('pageType');
        if(pageType == 'as'){
            title = Label.Partner_Portal_Registration_Header;
            companyLabel = 'Company Legal Name';
        }
        else{
            title = Label.Partner_Portal_Registration_Header;
            companyLabel = 'Company Name';
        }       
        requestSubmitted = false;
        countries = PartnerNewUserRegistrationHelper.getAllCountries();
    }
    
    global PageReference forwardToCustomAuthPage() {        
        return new PageReference( '/CommunitiesLanding');
    }
    
    global PageReference login() {
        /*if(rememberMe){
            Cookie userNameC = new Cookie('username',username,null,315569260,false);
            ApexPages.currentPage().setCookies(new Cookie[]{userNameC});    
        }*/
        system.debug('strURL--->'+strURL);
        PageReference newPR = Site.login(username, password, strURL);
        //PageReference newPR = Site.login(username, password, null);
        
        system.debug('--------------------------username---------------------------------'+username);
      
        system.debug('--------------------------password---------------------------------'+password);
        
        system.debug('--------------------------newPR---------------------------------'+newPR);
        
        return newPR;
    }
    
    global PageReference needToRegister(){
        PageReference newPR = new PageReference('/partnerNewUserRegistration?pageType=as');
        newPR.setRedirect(true);
        return newPR;
    }
    
    global PageReference registerNewUser(){
    
      //  verify();

        String errorMessage = '';
        if(firstName.trim() == '') { errorMessage += 'Please enter First Name <br/>' ;}
        if(lastName.trim() == '') { errorMessage += 'Please enter Last Name <br/>' ;}
        if(companyName.trim() == '') { errorMessage += 'Please enter Company Name <br/>' ;}
        if(countryName == '--Select--' || countryName == null) { errorMessage += 'Please enter Country Name <br/>';}
        if(email.trim() == '') { errorMessage += 'Please enter Email Address <br/>';}
        if(partnerType == '--Select--' || partnerType == null) { errorMessage += 'Please enter Partner Type <br/>';}
        
     /*   if(!Test.isRunningTest()){
            if(!verified ){
                errorMessage += 'Please enter valid security code<br/>';
            }
        }  */
        
        if(errorMessage != ''){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.Error,errorMessage));        
            return null;     
        }else
        { 
    
        Boolean isUserAlreadyExists = PartnerNewUserRegistrationHelper.checkForExistingUser(email, pageType);  
        Boolean isPURAlreadyExists =  PartnerNewUserRegistrationHelper.checkForExistingPUR(email);  
        Boolean isInternalUser = PartnerNewUserRegistrationHelper.checkInternalUser(email);
        
         
        system.debug('------------------------------isUserAlreadyExists-------------------------------------'+isUserAlreadyExists);
        
        system.debug('------------------------------isPURAlreadyExists-------------------------------------'+isPURAlreadyExists);
        
        system.debug('------------------------------isInternalUser-------------------------------------'+isInternalUser);
        
        
        if(isInternalUser) {
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
                'An Internal User exists with that email address. Please email AskSalesOps@genesys.com for further assistance'));   
        }else if(isUserAlreadyExists){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
                'You are a previously registered user.Please use <a href="/partner/forgotpasswordpartner">Change Password</a> Link to change your password.'));
        }else if(isPURAlreadyExists)
        {
           ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
                'You had already submitted a registration request and it is being processed.'));
        }
        else{
            // Last Modified to add Job Title for Processing Request.
            String response = PartnerNewUserRegistrationHelper.processRequest(firstName, lastName, companyName, countryName, email, jobTitle, partnerType, 'as');
            if(response == 'OK')
                ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 'Your request has been submitted successfully, Thanks.'));
            else
                ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, response));
        }
        requestSubmitted = true;    
        
        return null;
        }
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
      /*  if (response.getStatusCode() == 200) {
           loginFailUsrStatus = (response.getBody()).remove('"');
            if(string.isBlank(loginFailUsrStatus) || loginFailUsrStatus.equalsIgnoreCase('ACTIVE')){
                retErrMsg = 'The Login Name or Password you entered is incorrect.  Please try again.';
            }
            else if(loginFailUsrStatus.equalsIgnoreCase('LOCKED_OUT')){
                retErrMsg = 'Your account is Locked Out.  Please use the Forgot Password link below to reset your account and receive an email with a new password.';
            }
            else if(loginFailUsrStatus.equalsIgnoreCase('RECOVERY')){
                retErrMsg = 'Your password has expired.  Please use the Forgot Password link below to receive an email with a new password.';
            }
            else{
                retErrMsg = 'Login failed. Please try again.';
            }
        } */
        if (response.getStatusCode() == 200) {
            
           loginFailUsrStatus = (response.getBody()).remove('"');
            system.debug('loginFailUsrStatus'+loginFailUsrStatus);
            if(loginFailUsrStatus.equalsIgnoreCase('ACTIVE')){
                retErrMsg = 'The password you entered is Incorrect.  Please try again.  If you need a new password sent to you, please click on Forgot Password.';
            }
            else if(String.isBlank(loginFailUsrStatus))
            {
                retErrMsg = 'The username you entered is Incorrect.  Please try again.  If you are new to Genesys, please click on Register Here to request an account.';
            }
            else if(loginFailUsrStatus.equalsIgnoreCase('LOCKED_OUT')){
                retErrMsg = 'Your user account appears to be Locked.  Please click on Forgot Password to unlock your account and have a new password sent to you.';
            }
            
            else if(loginFailUsrStatus.equalsIgnoreCase('RECOVERY') || loginFailUsrStatus.equalsIgnoreCase('PASSWORD_EXPIRED')){
                retErrMsg = 'Your password has expired.  Please click on Forgot Password to have a new password sent to you.';
            }
            else{
                retErrMsg = 'There appears to have been a system error.  Please try again.  If you are unable to log in, please contact us at partners@genesys.com.';
            }
        }
    }
    
    /* ---------------------Captcha Code----------------------- */
    
    /*
    // The API endpoint for the reCAPTCHA service
    private static String baseUrl = 'http://www.google.com/recaptcha/api/verify'; 

    // The keys you get by signing up for reCAPTCHA for your domain
    private static String privateKey = Label.PRM_Captcha_Private_Key;
    public String publicKey { 
        get { return Label.PRM_Captcha_Public_Key; }
    } 
    
      public String challenge { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_challenge_field');
        }
    }
    public String response  { 
        get {
            return ApexPages.currentPage().getParameters().get('recaptcha_response_field');
        }
    }
    
    public PageReference verify() {
        System.debug('reCAPTCHA verification attempt');
        // On first page load, form is empty, so no request to make yet
 
        
        if ( challenge == null || response == null ) { 
            System.debug('reCAPTCHA verification attempt with empty form');
            return null; 
        }
        

        HttpResponse r = makeRequest(baseUrl,
            'privatekey=' + privateKey + 
            '&remoteip='  + remoteHost + 
            '&challenge=' + challenge +
            '&response='  + response
        );
        
        if ( r!= null ) {
            this.verified = (r.getBody().startsWithIgnoreCase('true'));
            
        }
        return null; 
       }
           
    private static HttpResponse makeRequest(string url, string body)  {
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try {
            Http http = new Http();
            response = http.send(req);
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return response;
    }   
        
    private String remoteHost { 
        get { 
            String ret = '127.0.0.1';
            // also could use x-original-remote-host 
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    }
    */
}