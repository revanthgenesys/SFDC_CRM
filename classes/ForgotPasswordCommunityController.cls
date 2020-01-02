/**
* An apex page controller that exposes the site forgot password functionality
*/
public without sharing class ForgotPasswordCommunityController {
    public String username {get; set;}   
    public Boolean passSent {get;set;}
    public String messg {get; set;}
    
    public ForgotPasswordCommunityController() {
        passSent = false;
    }
    
    public PageReference forgotPassword() {
        messg = '';
        
        if ( username == '' )  {
            messg = 'Please enter User Name';
            return null;   
        }
        
        //List<User> usr = [SELECT Id,ContactId FROM User WHERE isActive = true AND UserName =: username AND ContactId != NULL limit 1];
        List<User> usr = [SELECT Id, ContactId, Email FROM User WHERE isActive = true AND Email = :username AND ContactId != NULL limit 1];
        if ( usr.isEmpty() ) {
            messg = 'Please enter Valid User Name';
            return null;
        }
        
        try {
            //System.resetPassword(usr[0].Id, true);
            LdapManagement ldap = new LdapManagement();
            ldap.ResetPassword(usr[0].ContactId);
        }
        catch (Exception ex)  {
            messg = 'Error resetting password. Please try again later.';
            return null;
        }
        
        messg = 'We have sent you an email that tells how to reset your password.';
        return null;
    } 
    
}