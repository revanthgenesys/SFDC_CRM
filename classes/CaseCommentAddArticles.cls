public without sharing class CaseCommentAddArticles {

    public String caseId  { get;set { 
                                articles = new  List<articleWraper>();
                                findTheArticle(value); 
                                } }

        

    public CaseCommentAddArticles(){  
        
    }

    private static Map<String,String> prefixToTypeLabel;
    private static Map<String,String> PrefixToTypeNameMap = PrefixToTypeName();
    
    
    public List<articleWraper> articles;
    

    public List<articleWraper> getArticles(){
        return articles;
    }
    
    public static Map<String,String> PrefixToTypeName(){
    
        Map<String,String> prefixToTypeName = new Map<String,String>();
        prefixToTypeLabel = new Map<String,String>();
        
        Map<String, Schema.sObjectType> globalDesc = Schema.getGlobalDescribe();
        Set<String> typekeys =  globalDesc.keySet();
        for(String typekey : typekeys) {
            if(typekey.toUpperCase().endsWith('__KAV')) {
                prefixToTypeName.put(globalDesc.get(typekey).getDescribe().getKeyPrefix().toUpperCase(), typekey.substring(0,typekey.length() -5));
                prefixToTypeLabel.put(globalDesc.get(typekey).getDescribe().getKeyPrefix().toUpperCase(),globalDesc.get(typekey).getDescribe().getLabel());
            }
        }
        
        return prefixToTypeName;
    }
    
    
        private void findTheArticle(String theCaseId) {
            list<CaseArticle> thearticles = [SELECT KnowledgeArticleId, ArticleVersionNumber FROM CaseArticle where CaseId =: theCaseId];
            list<string> knowledgeIds = new List<string>();
            for(CaseArticle caseKBs:thearticles) {
                knowledgeIds.add(caseKBs.KnowledgeArticleId);
            }
            
            list<KnowledgeArticleVersion> caseKnowledgeArticles = [SELECT KnowledgeArticleId, Title, Summary,PublishStatus, URLName, ArticleNumber, Language, IsVisibleInApp, IsVisibleInCsp, IsVisibleInPkb, ArticleType FROM KnowledgeArticleVersion where KnowledgeArticleId IN: knowledgeIds AND  PublishStatus='Online' and Language= 'en_US'];
            articles = new  List<articleWraper>();
            for(KnowledgeArticleVersion theKB:caseKnowledgeArticles){
                articles.add(new articleWraper(theKB));
            }
    }
    
    public class articleWraper{
        public KnowledgeArticleVersion theArticle{get;set;}
        public String TheURL { get; set; }
        public String theType { get; set; }
        public String theTypeLabel {get;set;}
        
        public articleWraper(KnowledgeArticleVersion theArticle1){
            theArticle = theArticle1;
            if(PrefixToTypeNameMap.containsKey(String.valueOf(theArticle.KnowledgeArticleId).substring(0,3).toUpperCase())){
                theType = PrefixToTypeNameMap.get(String.valueOf(theArticle.KnowledgeArticleId).substring(0,3).toUpperCase());
                theTypeLabel = prefixToTypeLabel.get(String.valueOf(theArticle.KnowledgeArticleId).substring(0,3).toUpperCase());
            }
            //TheURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + 'apex' + '/' + 'pkb_Home?id=' + TheArticle.knowledgeArticleId;
            
            ///TODO - change hardcoded URL to System...
            //TheURL = 'https://genesyspartner.force.com/customercare/' + 'pkb_Home?id=' + TheArticle.knowledgeArticleId;
            TheURL = System.Label.Genesys_Authenticated_Portal_URL + 'pkb_Home?id=' + TheArticle.knowledgeArticleId;
        }
    }
                
}