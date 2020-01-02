/*
    Naresh Kumar    06/20/2013
*/
public with sharing class ChangePasswordPortalController {
    public String newPassword {get;set;}
    public String confirmPassword {get;set;}    
    public String oldPassword {get;set;} 
    public ChangePasswordPortalController(){}
    
    public pageReference updatePassword(){
     
        ApexPages.Message msg;
        if(newPassword != confirmPassword || newPassword.length() < 8 || newPassword == ''){
            msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Both the passwords should match and must be of at least 8 characters'); 
            ApexPages.addMessage(msg);
            return null;
        }
               
       Portal_Password__c portalPassword = new Portal_Password__c();
       portalPassword.username__c = UserInfo.getUserName();
       portalPassword.Reset__c = true;
       portalPassword.Is_Change_Password__c = true;
       // System.setPassword(UserInfo.getUserId(), newPassword);   
              
       if ( Site.changePassword(newPassword, newPassword, oldPassword) != null )  {           
           
           portalPassword.Current_Password__c = newPassword ;
           upsert portalPassword Username__c; 
      
           msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Your password has been updated.');
           ApexPages.addMessage(msg);
       }
       return null;
 
    }
}