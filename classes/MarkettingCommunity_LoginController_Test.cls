@isTest
public with sharing class MarkettingCommunity_LoginController_Test{
  static testMethod void testMethod1() {
    Cookie c1 = new Cookie('username', 'test@test.com', null, -1, false);
      ApexPages.currentPage().setCookies(new Cookie[]{c1});
    MarkettingCommunity_LoginController obj = new MarkettingCommunity_LoginController();
    ApexPages.currentPage().getParameters().put('pageType','as');
    MarkettingCommunity_LoginController obj1 = new MarkettingCommunity_LoginController();    
    //obj1.verified = true;
    obj1.forwardToCustomAuthPage();
    obj1.rememberMe = true;
    obj1.login();
    obj1.firstName = 'test user';
    obj1.lastName = 'test user';
    obj1.companyName = 'test user';
    obj1.email = 'test user';
    obj1.countryName = 'United States';
    obj1.needToRegister();
    obj1.registerNewUser();
  }
}