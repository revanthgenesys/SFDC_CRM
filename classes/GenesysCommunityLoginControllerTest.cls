@isTest(seeAllData=true)
private class GenesysCommunityLoginControllerTest {
    
    static testMethod void validateCommunitymethods() {
        GenesysCommunityLoginController gcLc = new GenesysCommunityLoginController();
        gcLc.forwardToAuthPage();
        gcLc.loginCheck();
    }   
    @isTest static void testCallout() {
        // Set mock callout class 
        GenesysCommunityLoginController obj = new GenesysCommunityLoginController();
        Test.setMock(HttpCalloutMock.class, new PartnerMockHttpResponseGenerator());
       
        obj.checkUserStatusOnLoginFailure();

    } 
}