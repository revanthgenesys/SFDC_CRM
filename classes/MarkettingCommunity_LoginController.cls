global class MarkettingCommunity_LoginController {
    global String username{get;set;}
    global String password{get;set;}    
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
    
    global MarkettingCommunity_LoginController (){
        Cookie userNameC = ApexPages.currentPage().getCookies().get('username');
        this.verified = false;
        
        if(userNameC != null)
            userName = userNameC.getValue();
        pageType = ApexPages.currentPage().getParameters().get('pageType');
        if(pageType == 'as'){
            title = 'PARTNER NETWORK PROGRAM APPLICATION';
            companyLabel = 'Company Legal Name';
        }
        else{
            title = 'PARTNER PORTAL REGISTRATION';
            companyLabel = 'Company Name';
        }       
        requestSubmitted = false;
        countries = MarkettingCommunity_LoginHelper.getAllCountries();
    }
    
    global PageReference forwardToCustomAuthPage() {        
        return new PageReference( '/CommunitiesLanding');
    }
    
    global PageReference login() {
    	String landingURL = '/_ui/core/chatter/groups/GroupProfilePage?g=0F9U0000000LLov';
    	//ApexPages.currentPage().getParameters().get('landingPage');
        if(rememberMe){
            Cookie userNameC = new Cookie('username',username,null,315569260,false);
            ApexPages.currentPage().setCookies(new Cookie[]{userNameC});    
        }
        PageReference newPR = Site.login(username, password, landingURL);
        return newPR;
    }
    
    global PageReference needToRegister(){
        PageReference newPR = new PageReference('/MarkettingCommunity_NewUserRegistration');
        newPR.setRedirect(true);
        return newPR;
    }
    
    global PageReference registerNewUser(){
        
        system.debug('----------------------------register--------------------------');
        
        verify();

        String errorMessage = '';
        if(firstName.trim() == '') { errorMessage += 'Please enter First Name <br/>' ;}
        if(lastName.trim() == '') { errorMessage += 'Please enter Last Name <br/>' ;}
        if(companyName.trim() == '') { errorMessage += 'Please enter Company Name <br/>' ;}
        if(countryName == '--Select--' || countryName == null) { errorMessage += 'Please enter Country Name <br/>';}
        if(email.trim() == '') { errorMessage += 'Please enter Email Address <br/>';} 
        if(!Test.isRunningTest()){
            if(!verified ){
                errorMessage += 'Please enter valid security code<br/>';
            }
        }
        if(errorMessage != ''){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.Error,errorMessage));        
            return null;     
        }else
        { 
            
                    system.debug('----------------------------inside--else--------------------------');
            
  
        Boolean isUserAlreadyExists = MarkettingCommunity_LoginHelper.checkForExistingUser(email, pageType);
        
        system.debug('----------------------------isUserAlreadyExists----------------------------'+isUserAlreadyExists);
        
        if(isUserAlreadyExists){
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
                'You request has been submitted successfully, It seems that you are have registered previously.Please use <a href="/partner/secur/forgotpassword.jsp">Change Password</a> Link to change your password.'));
        }
        else{
            MarkettingCommunity_LoginHelper.processRequest(firstName, lastName, companyName, countryName, email, 'as');
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
                'Your request has been submitted successfully, Thanks.'));
        }
        requestSubmitted = true;    
        
        return null;
        }
    }
    
    
    /* ---------------------Captcha Code----------------------- */

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
           
       /* Private helper methods */
    
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
    
 
}