/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
         PageReference pageRef =  Site.changePassword(newPassword, verifyNewPassword, oldpassword);   
         if(pageRef != null){
            Portal_Password__c portalPassword = new Portal_Password__c();
            portalPassword.Username__c = userinfo.getusername();
            portalPassword.Current_password__c = newPassword ;
            upsert portalPassword Username__c;
           // pageRef = new PageReference('home/home.jsp'); 
        }
        return pageRef; 
    }     
    
    public ChangePasswordController() {}
    
    @IsTest(SeeAllData=true) public static void testChangePasswordController() {
        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.oldPassword = '123456';
        controller.newPassword = 'qwerty1'; 
        controller.verifyNewPassword = 'qwerty1';                
        
        System.assertEquals(controller.changePassword(),null);                           
    }    
}