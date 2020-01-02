public without sharing class  SearchAlerts {
    public string url {get;set;}
    public string internal {get;set;}
    public string errorMessage {get;set;}
    
    public boolean docIsKbArticle {get;set;}
    public boolean docIsQuestion {get;set;}
    public boolean docIsTechDoc {get;set;}
    
    public string docSfId {get;set;}
    public string docSfLanguage {get;set;}
    
    public string externalLink {get;set;}
    public string internalLink {get;set;}
    
    public SearchAlerts__c settings;
    
    public void init(){
        System.debug('ENTER redirect');
        settings = SearchAlerts__c.getOrgDefaults();
       
        url = ApexPages.currentPage().getParameters().get('url');
        internal = ApexPages.currentPage().getParameters().get('int');

        if( String.isBlank(url) || String.isBlank(internal)){
            errorMessage = 'This page expects parameters.';
            return;
        }
        
        if(!Pattern.matches('https://docs.genesys.com.*|http://www.salesforce.com/org.*',
                            url)){
            errorMessage = 'This page expects a whitelisted parameters.';
            return;
        }
        
        docIsTechDoc = url.containsIgnoreCase('https://docs.genesys.com');
        
        Matcher p = Pattern.compile('http://www.salesforce.com/org:organization/articletype:[^/]+/article:([^/]+)/language:(.*)').matcher(url);
        docIsKbArticle = p.matches();
        if(docIsKbArticle){
            docSfId = p.group(1);
            docSfLanguage = p.group(2);
            if(String.IsBlank(docSfId) || String.IsBlank(docSfLanguage)){
                errorMessage = 'This page expects specific parameters.';
            }
        }
        
        p = Pattern.compile('http://www.salesforce.com/org:organization/object:Question/record:(.*)').matcher(url);
        docIsQuestion =  p.matches();
        if(docIsQuestion){
            docSfId = p.group(1);
            if(String.IsBlank(docSfId)){
                errorMessage = 'This page expects specific parameters.';
	            return;
            }
        }

        if(docIsTechDoc){
            generateTechDocLinks();
        }
        else if(docIsKbArticle){
            generateKbArticleLinks();
        }
        else if(docIsQuestion){
            generateQuestionLinks();
        }
        else {
            generateLinksFallback();
        }
    }

    public boolean getIsError(){
        return !String.isBlank(errorMessage);
    }

    public void generateTechDocLinks(){
        /*For techdocs, requirement is that we must login in SF first (to get some authentication for techdocs site). We use the SearchAlerts redirector to bounce back to techdocs site*/
        externalLink = settings.Customer_Care_Host_Name__c +'?starturl=' + EncodingUtil.urlEncode(settings.Customer_Care_Host_Name__c+'/SearchAlertsRedirector?url=' + url, 'UTF-8');
        
        internalLink = settings.Internal_Host_Name__c + '/apex/SearchAlertsRedirector?url=' + EncodingUtil.urlEncode(internal, 'UTF-8');
    }

    public void generateKbArticleLinks(){
        externalLink = settings.Customer_Care_Host_Name__c +'?starturl=' + EncodingUtil.urlEncode(settings.Customer_Care_Host_Name__c+'/pkb_Home?id=' + docSfId + '&l=' + docSfLanguage + '&fs=Search&pn=1', 'UTF-8');

        internalLink = internal;
    }

    public void generateQuestionLinks(){
		/*interesting case of url hash (#) part that gets truncated. Thats why we pass as a separate url parameter named "hash", and must re-encode it */

        string encAmp = EncodingUtil.urlEncode('&', 'UTF-8');
        string starturl = EncodingUtil.urlEncode('/SearchAlertsRedirector?url=/customercare/community?fromsearchalerts=1'+encAmp+'hash=!feedtype=SINGLE_QUESTION_DETAIL'+encAmp+'id=' + docSfId, 'UTF-8');
        externalLink = settings.Customer_Care_Host_Name__c+'?starturl='+starturl;

        internalLink = internal;
    }

    public void generateLinksFallback(){
		/*interesting case of url hash (#) part that gets truncated. Thats why we pass as a separate url parameter named "hash", and must re-encode it */
        externalLink = internal;

        internalLink = internal;
    }
}