@isTest
public class SearchAlertsRedirectorTest {
	static testMethod void redirect(){
		PageReference pageRef = Page.SearchAlertsRedirector;
        SearchAlertsRedirector sar = new SearchAlertsRedirector();
        
        pageRef.getParameters().put('url', 'dummy');
        pageRef.getParameters().put('int', 'dummy');
        Test.setCurrentPage(pageRef);
        PageReference pr = sar.redirect();
    }   

	static testMethod void redirect_debug(){
		PageReference pageRef = Page.SearchAlertsRedirector;
        SearchAlertsRedirector sar = new SearchAlertsRedirector();
        
        pageRef.getParameters().put('url', 'dummy');
        pageRef.getParameters().put('int', 'dummy');
        pageRef.getParameters().put('debug', '1');
        Test.setCurrentPage(pageRef);
        PageReference pr = sar.redirect();
    }   
}