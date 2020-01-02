public class CustomerPortalLoginController {

    
    public String username {get; set;}
    public String password {get; set;}


    public PageReference redirectToCommuniy(){
        String startURL = System.currentPageReference().getParameters().get('startURL');
        if(startURL == null){               
            startURL = '';
        }
        
        //SBGENFULL
        ///return new PageReference('https://sbgenfull-genesyscommunity.cs11.force.com/customercare'+startURL);  
        
        //PROD
        //return new PageReference('https://genesyspartner.force.com/customercare'+startURL); 
        return new PageReference(Label.Prod_URL + startURL);  
    }

    public PageReference loginCheck() {
        String startURL = System.currentPageReference().getParameters().get('startURL');
        system.debug('startURL = '+startURL);
        //return  Site.login(username, password, '/home/home.jsp');
        PageReference pageRef =  Site.login(username, password, '/home/home.jsp');
        System.debug('NKC debug pageRef ['+pageRef+']');
        //system.debug('loginCheck pageRef = '+pageRef);
        if(pageRef != null){
            String url;
            if(password.indexOf('&') != -1)
                password = password.replace('&', '%26');
            //SBGENFULL2
            //url = 'https://cs9.salesforce.com/secur/login_portal.jsp?orgId=00DK000000AbEkA&portalId=060U0000000Pmtk&un='+username+'&pw='+password;
            //PROD
            //url = 'https://genesys.my.salesforce.com/secur/login_portal.jsp?orgId=00DU0000000KM1G&portalId=060U0000000Pmtk&un='+username+'&pw='+password;
            url = Label.LoginCheck_URL + '&un='+username+'&pw='+password;
            if(startURL != null){               
                url += '&startURL=' + startURL;
            }
            pageRef = new PageReference(url);                   
            return pageRef;            
        }
        return null;
    }
     public PageReference changePassword() {
       // String startUrl = System.currentPageReference().getParameters().get('startURL');
        PageReference pageRef = Site.login(username, password, '/apex/changepassword');
        
        return pageRef;
    }
    
    
    
       public CustomerPortalLoginController() {}  
}