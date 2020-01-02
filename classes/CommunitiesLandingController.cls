/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        system.debug('Apexpages.currentPage().getUrl()' + Apexpages.currentPage().getUrl());
        
        
         for(String theVal:Apexpages.currentPage().getHeaders().keyset()){
            system.debug(theVal + 'Apexpages.currentPage().Apexpages.currentPage().getHeaders().values()' + Apexpages.currentPage().getHeaders().get(theVal));
        }
        
   if(Site.getPrefix() != null && Site.getPrefix().contains('customercare') ){
   
            String startUrl = System.currentPageReference().getParameters().get('startURL');
            if(startUrl!= null){
                startUrl = 'startURL='+EncodingUtil.urlEncode(startURL, 'UTF-8');
            }else{
                startUrl = '';
            }
     return new PageReference(Site.getPrefix() + '/GenesysCommunityLogin?' +startUrl );
            
        }
               
        return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}