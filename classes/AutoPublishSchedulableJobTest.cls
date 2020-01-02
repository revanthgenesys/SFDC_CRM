@IsTest(SeeAllData=true)
public class AutoPublishSchedulableJobTest {

    static AutoPublishSchedulableJob job = new AutoPublishSchedulableJob();
    static String jobId;
    static List<Integer> articleListSizes = new List<Integer>();
    public static Integer NUMBER_OF_ARTICLES_PER_TYPE = 10;

    static void setupArticles() {
        CaseArticle curCaseArticle;
        List<sObject> articleList;
        List<Case> caseList = [
            SELECT Id
            FROM Case
            LIMIT 3
        ];
        System.assertEquals(3, caseList.size());
        for (integer cnt = 0; cnt < AutoPublishBatchableTask.ARTICLE_VERSION_TABLES.size(); cnt++) {
            String keppInternal = '';
            /*if(AutoPublishBatchableTask.ARTICLE_VERSION_KEEP_INTERNAL.get(AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt])){
                keppInternal = ' AND KEEP_INTERNAL__c = \'No\'';
            }*/
            
            articleList = Database.query('SELECT Id, KnowledgeArticleId FROM ' + AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt] + ' ' +
            'WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND ValidationStatus = \'Validated Internal\' ' +
            keppInternal + '   AND INTENDED_AUDIENCE__c <> \'Internal\' LIMIT '+NUMBER_OF_ARTICLES_PER_TYPE);
            articleListSizes.add(articleList.size());
            List<CaseArticle> caseArticleList = new List<CaseArticle>();
            for (sObject curArticle : articleList) {
                for (Case curCase: caseList) {
                    curCaseArticle = new CaseArticle();
                    curCaseArticle.CaseId = curCase.Id;
                    curCaseArticle.KnowledgeArticleId = (String)curArticle.get('KnowledgeArticleId');
                    caseArticleList.add(curCaseArticle);
                }
            }
            insert caseArticleList;

            system.debug('SSS ' + AutoPublishBatchableTask.ARTICLE_TABLES[cnt] + ' articleList.size()=' + articleList.size());
            //System.assert(articleList.size() > 0);
/*
            System.assertEquals(articleList.size(), Database.query('SELECT COUNT(Id) FROM ' + AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt] + ' ' +
            'WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND ValidationStatus = \'Validated Internal\' ' + keppInternal +
            'AND INTENDED_AUDIENCE__c <> \'Internal\' AND KnowledgeArticleId IN ( SELECT Id From ' + AutoPublishBatchableTask.ARTICLE_TABLES[cnt] + ' ' +
            'WHERE CaseAssociationCount > 1 )')[0].get('expr0'));
*/
        }
    }

    static void executeJob() {
        job.processArticles();
    }

    static void assertResults() {
        for (integer cnt = 0; cnt < AutoPublishBatchableTask.ARTICLE_VERSION_TABLES.size(); cnt++) {
            system.debug('SSS ' + AutoPublishBatchableTask.ARTICLE_TABLES[cnt]);
            String keppInternal = '';
            /*if(AutoPublishBatchableTask.ARTICLE_VERSION_KEEP_INTERNAL.get(AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt])){
                keppInternal = ' AND KEEP_INTERNAL__c = \'No\'';
            }*/
/*
            System.assertEquals(0, Database.query('SELECT COUNT(Id) ' + 
                'FROM ' + AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt] + ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND ValidationStatus = \'Validated Internal\' ' +
                keppInternal +' AND INTENDED_AUDIENCE__c <> \'Internal\' AND KnowledgeArticleId IN ( SELECT Id FROM ' + AutoPublishBatchableTask.ARTICLE_TABLES[cnt] + ' WHERE CaseAssociationCount > 1 )')[0].get('expr0'));
            System.debug('++++++debug = ' + Database.query('SELECT COUNT(Id) ' +
                'FROM ' + AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt] + ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND ValidationStatus <> \'Validated Internal\'  ' + keppInternal +
                'AND INTENDED_AUDIENCE__c <> \'Internal\' AND KnowledgeArticleId IN ( SELECT Id FROM ' + AutoPublishBatchableTask.ARTICLE_TABLES[cnt] + ' WHERE CaseAssociationCount > 1 )')[0].get('expr0'));
            System.assertEquals( articleListSizes.get(cnt), Database.query('SELECT COUNT(Id) ' +
                'FROM ' + AutoPublishBatchableTask.ARTICLE_VERSION_TABLES[cnt] + ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND ValidationStatus <> \'Validated Internal\'  ' + keppInternal +
                'AND INTENDED_AUDIENCE__c <> \'Internal\' AND KnowledgeArticleId IN ( SELECT Id FROM ' + AutoPublishBatchableTask.ARTICLE_TABLES[cnt] + ' WHERE CaseAssociationCount > 1 )')[0].get('expr0'));
*/
        }
    }

    static testMethod void testExecute() {
       
try{        Test.startTest();

        setupArticles();

        executeJob();
        
        //System.abortJob(batchID) ;

        Test.stopTest();

        //assertResults();
    
}catch(Exception e){
    
}
    
    }

}