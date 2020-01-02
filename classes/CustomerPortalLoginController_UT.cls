@isTest
public class CustomerPortalLoginController_UT {
    
    public static testMethod void testSiteLoginController_UT1 () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
                
        System.assertEquals(controller.login(),null);                           
    }   
    
  public static testMethod void testSiteLoginController_UT2 () {
        // Instantiate the CustomerPortalLoginController class 
        CustomerPortalLoginController custmrPrtl= new CustomerPortalLoginController();
      	custmrPrtl.username = 'test@salesforce.com';
        custmrPrtl.password = '123456';
      	custmrPrtl.loginCheck();  
      	custmrPrtl.redirectToCommuniy();
      	custmrPrtl.changePassword();
    } 
}