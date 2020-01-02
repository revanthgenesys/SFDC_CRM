public class SearchAlertsRedirector {
    public string url {get;set;}
    public string hash {get;set;}
    public string debug {get;set;}
    public string redirecturl {get;set;}
    
    public PageReference redirect(){
        url = ApexPages.currentPage().getParameters().get('url');
        hash = ApexPages.currentPage().getParameters().get('hash');
        debug = ApexPages.currentPage().getParameters().get('debug');
        redirecturl = url + '#' + hash;
        
        PageReference pageRef = new PageReference(redirecturl);
        if(String.IsBlank(debug)){
	        return pageRef;
        }
        return null;
    }
}