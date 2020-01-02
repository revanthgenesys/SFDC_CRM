/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        system.debug('Apexpages.currentPage().getUrl()' + Apexpages.currentPage().getUrl());
         for(String theVal:Apexpages.currentPage().getHeaders().keyset()){
        	system.debug(theVal + 'Apexpages.currentPage().Apexpages.currentPage().getHeaders().values()' + Apexpages.currentPage().getHeaders().get(theVal));
        }
        if(Site.getPrefix() != null && Site.getPrefix().contains('customercare')){
        	
        	String startUrl = System.currentPageReference().getParameters().get('startURL');
			if(startUrl!= null){
        		startUrl = 'startURL='+EncodingUtil.urlEncode(startURL, 'UTF-8');
        	}else{
        		startUrl = '';
        	}
			return new PageReference(Site.getPrefix() + '/GenesysCommunityLogin?' +startUrl );
        	
        	
        }
        
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
}