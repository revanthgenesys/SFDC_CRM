@isTest 
private class GenesysConsuCommunityLoginControllerTest {
    
    static testMethod void validateCommunitymethods() {
        GenesysConsuCommunityLoginController gcLc = new GenesysConsuCommunityLoginController();
        gcLc.forwardToAuthPage();
        gcLc.loginCheck();
    }    
}