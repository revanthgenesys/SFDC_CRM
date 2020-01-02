//04/25/2014	Naresh Kumar
@isTest(seeAllData=true)
public with sharing class PartnerLoginController_Test {
	static testMethod void testMethod1() {
		Cookie c1 = new Cookie('username', 'test@test.com', null, -1, false);
    	ApexPages.currentPage().setCookies(new Cookie[]{c1});
		PartnerLoginController obj = new PartnerLoginController();
		ApexPages.currentPage().getParameters().put('pageType','as');
		PartnerLoginController obj1 = new PartnerLoginController();		
		//obj1.verified = true;
		obj1.forwardToCustomAuthPage();
		obj1.rememberMe = true;
		obj1.login();
		obj1.firstName = 'test user';
		obj1.lastName = 'test user';
		obj1.companyName = 'test user';
		obj1.email = 'test user';
		obj1.countryName = 'United States';
        obj1.partnerType = 'Tech/Appfoundry';
        
		obj1.needToRegister();
		obj1.registerNewUser();
        
        User nonStandardUser = [SELECT id, EMail, FirstName, LastName FROM User WHERE IsActive = true and UserType != 'Standard' LIMIT 1];
        PartnerLoginController obj2 = new PartnerLoginController();		
		//obj1.verified = true;
		obj2.forwardToCustomAuthPage();
		obj2.rememberMe = true;
		obj2.login();
		obj2.firstName = nonStandardUser.FirstName;
		obj2.lastName = nonStandardUser.LastName;
		obj2.companyName = 'test user';
		obj2.email = nonStandardUser.Email;
		obj2.countryName = 'United States';
        obj2.partnerType = 'Tech/Appfoundry';
		obj2.needToRegister();
		obj2.registerNewUser();
	}
    
    static testMethod void testMethod2() {
		Cookie c1 = new Cookie('username', 'test@test.com', null, -1, false);
    	ApexPages.currentPage().setCookies(new Cookie[]{c1});
		PartnerLoginController obj = new PartnerLoginController();
		ApexPages.currentPage().getParameters().put('pageType','as');
		PartnerLoginController obj1 = new PartnerLoginController();		
		//obj1.verified = true;
		obj1.forwardToCustomAuthPage();
		obj1.rememberMe = true;
		obj1.login();
		obj1.firstName = 'test user';
		obj1.lastName = 'test user';
		obj1.companyName = 'test user';
		obj1.email = 'test user';
		obj1.countryName = 'Global';
        obj1.jobTitle = 'test job';
        obj1.partnerType = 'Tech/Appfoundry';
		obj1.needToRegister();
		obj1.registerNewUser();
    }
    @isTest static void testCallout() {
        // Set mock callout class 
        PartnerLoginController obj = new PartnerLoginController();
        Test.setMock(HttpCalloutMock.class, new PartnerMockHttpResponseGenerator());
       
        obj.checkUserStatusOnLoginFailure();

    } 
}