public with sharing class RqiAqiForm {
    public String cType {get;set;}
    public String dateRange1 {get;set;}
    public String dateRange2 {get;set;}
    public String authorId {get;set;}
    public RQI_Audit__c authorname {get;set;}
    public List<Case> caseList;
    public List<KnowledgeArticleVersion> articleList;
    
    public List<Case> getcaseList(){
        return  caseList;
    }
    
    
    public List<KnowledgeArticleVersion> getarticleList(){
        return  articleList;
    }
    
    public RqiAqiForm(){
        authorname = new RQI_Audit__c();
        caseList = new List<Case>();
        articleList = new List<KnowledgeArticleVersion>();
    }
    
    public Pagereference valuesFromUser(){
        cType = apexpages.currentpage().getparameters().get('casesorarticles');
        dateRange1 = apexpages.currentpage().getparameters().get('datestart');
        dateRange2 = apexpages.currentpage().getparameters().get('dateend');
        authorId = authorname.Author__c ;
        setupCasesOrArticles();
        return null;
    }
       
    public void setupCasesOrArticles(){
        //Check which button the user clicked
        if(cType.equals('retCases')){
            //get 6 random closed cases owned by the specified user in the date range specified
            System.debug('Type clicked: '+cType);
            Case currentCase;
            List<Date> usingdates = whichDateRange();
            System.debug('Case Author ID: '+ authorname.Author__c);
            //when you create the RQIs, you need to make sure to exclude cases with related RQIs
            caseList = [
                SELECT Id, CaseNumber 
                FROM Case 
                WHERE OwnerId=: authorname.Author__c 
                AND ClosedDate!=null 
                AND ClosedDate >= :usingdates.get(0) 
                AND ClosedDate <= :usingdates.get(1) 
                AND Id NOT IN (SELECT Case__c FROM RQI_Audit__c)
                LIMIT 100
            ];
                
            Integer totCases = caseList.size();
            System.debug('Total Number of Cases: '+totCases);
            String test = 'These are the case ids returned ';
            if (totCases>6) {
                //choose 6 random cases from all that were returned
                Map<Id, Case> caseMap = new Map<Id, Case>();
                List<Case> realList=new List<Case>();
                
                test += 'from case count more than 6: ';
                Integer rand;
                Integer i=0;
               // for (i=0;i<6;i++) {
               while ( caseMap.size() < 6 && i< 20 )  {
                    rand = Math.floor(Math.random() * totCases).intValue();
                    //currentCase = caseList.get(rand);
                    
                    caseMap.put(caseList.get(rand).Id, caseList.get(rand)); 
                    i++;                   
                    //realList.add(currentCase);
                   // test += currentCase.Id+'  ';
                }
                System.debug(test);
                caseList = new List<Case>();
                //caseList.addAll(realList);
                caseList = caseMap.values();

            } else if(totCases==0||totCases<0){
                //no cases were found
                //message is shown to the user based on caseList.size if its 0 then they are prompted to search again
            }else {
                //use all cases that were returned
                test+= 'from case count less than 6: ';
                for (Case c: caseList){ 
                    test += c.Id+'  ';
                }
                System.debug(test);
            }
        }else if(cType.equals('retArticles')){
            //get 4 random articles owned by the specified user in the date range specified
            System.debug('Type clicked: '+cType);
            KnowledgeArticleVersion currentArticle;
            List<Date> usingdates = whichDateRange();
            System.debug('Article Author ID: '+ authorname.Author__c);
            //when you create the AQIs, you need to make sure to exclude articles in the process of or have already been audited
            List<Id> excludeAlreadyAuditedArticles = new List<Id>();
            for(SObject sc :[SELECT Article_ID__c FROM AQI_Audit__c]){
                try{
                    Id i = (Id)sc.get('Article_ID__c');
                    excludeAlreadyAuditedArticles.add(i);
                }catch(Exception e){
                    System.debug('not an id, someone corrupted the data');
                }
            }
            articleList = [
                SELECT Id, ValidationStatus, PublishStatus, Language, CreatedDate, CreatedById, ArticleNumber 
                FROM KnowledgeArticleVersion
                WHERE PublishStatus='Online'
                AND Language='en_US'
                AND (ValidationStatus='Validated Internal' 
                    OR ValidationStatus='Validated Partner' 
                    OR ValidationStatus='Validated Customer' 
                    OR ValidationStatus='Validated Public')
                AND CreatedById= :authorname.Author__c 
                AND CreatedDate!=null
                AND CreatedDate >= :usingdates.get(0) 
                AND CreatedDate <= :usingdates.get(1)
                AND Id NOT IN : excludeAlreadyAuditedArticles
                LIMIT 100
            ];
            Integer totArticles= articleList.size();
            System.debug('Total Number of Articles: '+totArticles);
            String test2 = 'These are the article ids returned ';
            if (totArticles>4) {
                //choose 4 random articles from all that were returned
                List<KnowledgeArticleVersion> realList2=new List<KnowledgeArticleVersion>();
                Map<Id,KnowledgeArticleVersion> artclMap= new Map<Id, KnowledgeArticleVersion>();
                
                test2 += 'from article count more than 6: ';
                Integer rand; 
                Integer i=0;
                //for (i=0;i<4;i++) {
                while ( artclMap.size() < 4 && i<20 ) {
                    rand = Math.floor(Math.random() * totArticles).intValue();
                    //currentArticle = articleList.get(rand);
                    
                    artclMap.put(articleList.get(rand).id, articleList.get(rand));
                    
                   // realList2.add(currentArticle);
                   // test2 += currentArticle.Id+'  ';
                }
                System.debug(test2);
                articleList = new List<KnowledgeArticleVersion>();
                //articleList.addAll(realList2);
                articleList = artclMap.values();

            } else if(totArticles==0||totArticles<0){
                //no articles were found
                // message is shown to the user based on articleList.size if its 0 then they are prompted to search again by the VF page
            }else {
                //use all cases that were returned
                test2+= 'from case count less than 4: ';
                for (KnowledgeArticleVersion c: articleList){ 
                    test2 += c.Id+'  ';
                }
                System.debug(test2);
            }
        }else{
            //TODO: reset the form and have the user try again.
        }
    }
    
    /* 
        function to return the date range the user selected 
        TODO: check which radio button is checked to determine which date range to use instead of checking the daterange fields
        Format currently being passed for both daterange and prevmonths:
        Start Date: 2013-10-12 00:00:00 End Date: 2013-12-12 00:00:00
    */
    public List<Date> whichDateRange(){
        List<Date> useThisDateRange = new List<Date>();
        Date dstart;
        Date dend;
        String[] useDate;
        //if (!(dateRange1.equals('')) || !(dateRange2.equals(''))) {
        if(dateRange1 != '' && dateRange2 != ''){
            useDate = dateRange1.split('/');
            dstart = Date.newinstance(Integer.valueOf(useDate[2].trim()),Integer.valueOf(useDate[0].trim()),Integer.valueOf(useDate[1].trim()));
            useDate = dateRange2.split('/');
            dend = Date.newinstance(Integer.valueOf(useDate[2]),Integer.valueOf(useDate[0]),Integer.valueOf(useDate[1]));
            System.Debug('Start Date: '+dstart+' End Date: '+dend);
        } else {
            /*
            dstart = Date.today();
            dend = Date.today().addMonths(-2);*/
            dend = Date.today() + 1;
            dstart = Date.today().addMonths(-2);
            System.Debug('Start Date: '+dstart+' End Date: '+dend);
        }
        useThisDateRange.add(dstart);
        useThisDateRange.add(dend);
        return useThisDateRange;
    }
    
}