global with sharing class userSubscriptionAlerts {


    global static list<User> batchStart(Boolean isDaily){
        String Frequency = '1 per Day';
        if(!isDaily){
            Frequency = '1 per Week';
        }
        return [select id,UserType,(select ownerId,Type__c,Article_ID__c,Solution_Search_Alert_Preference__c,Category_ID__c,Article_Type_API_Name__c,Last_Run_Date__c from Solution_Search_Alerts__r where Frenquency__c =:Frequency ) from user where id in (select ownerId from Solution_Search_Alert__c)];
    }
    
    
    global static void batchExcecute(Boolean isDaily,List<sObject> scopeList){
        
        
        Boolean isSandbox = URL.getSalesforceBaseUrl().getHost().left(2).equalsignorecase('cs');
        
        //String siteURL = 'http://genesys.force.com/support/GenesysPortalLogin';
      //MS- 01/2016
      //  String siteURL = System.Label.Genesys_Authenticated_Portal_URL + 'GenesysCommunityLogin';
        String siteURLfull = System.Label.Genesys_Authenticated_Portal_URL;
		String siteURL = siteURLfull.substring(0, siteURLfull.length()-1);
    
        /*
        if(isSandbox){
            siteURL = 'http://sbgenfull-genesys.cs10.force.com/support/GenesysPortalLoginSandBox';
        }
        */
        
        Integer daysToAdd = 1;
        if(!isDaily){
            daysToAdd = 7;
        }
        Datetime lastRun = Datetime.now() - daysToAdd;
        
        Map<Id,KnowledgeArticleVersion> kavsLastModifDate;
        if(!test.isRunningTest()){
            kavsLastModifDate = new Map<Id,KnowledgeArticleVersion>([select id,knowledgearticleId,articleType,title,FirstPublishedDate from knowledgeArticleVersion where 
                                            publishstatus = 'online' and language = 'en_US' and LastModifiedDate >: lastRun  ]);
        }else{
            kavsLastModifDate = new Map<Id,KnowledgeArticleVersion>([select id,knowledgearticleId,articleType,title,FirstPublishedDate from knowledgeArticleVersion where 
                                            publishstatus = 'draft' and language = 'en_US' and LastModifiedDate >: lastRun  ]);
        }
                                            
        Map<String, KnowledgeArticleVersion> knowledgeMaps = new Map<String, KnowledgeArticleVersion>();
        
        Map<String, set<String>> knowledgeCatMap = new Map<String,  set<String>>();
        
        Map<String, set<String>> typeToArticleIdMap = new Map<String,  set<String>>();
        
        
        for(KnowledgeArticleVersion kav:kavsLastModifDate.values()){
            knowledgeMaps.put(kav.knowledgearticleId,kav);
            
            set<String> kavsTypes;
            
            if(!typeToArticleIdMap.containsKey(kav.articleType)){
                kavsTypes = new set<String>();
            }else{
                kavsTypes = typeToArticleIdMap.get(kav.articleType);
            }
            
            kavsTypes.add(kav.knowledgeArticleId);
            
            typeToArticleIdMap.put(kav.articleType,kavsTypes);
        }
        
        
        
        List<String> articleTypes = new List<String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

    
        for( Schema.SObjectType op: schemaMap.values() ) {
            if( op.getDescribe().getName().endsWith('__kav')  ) {
                articleTypes.add( op.getDescribe().getName());
            }
        }
        
        for(String theType:articleTypes){
        
            set<Id> ids =  kavsLastModifDate.keyset();
            String q = 'select ParentId,CreatedDate, DataCategoryName, DataCategoryGroupName from '+theType.replaceAll('__kav','')+'__DataCategorySelection  where parentId in: ids';
            List<SObject> cats = (List<SObject>) Database.query(q);
            List<String> tmp = new List<String>();
            for( SObject howToCat: cats ) {
                set<String> kavsCat;
                
                if(!knowledgeCatMap.containsKey(howToCat.get('DataCategoryGroupName') + ':' + howToCat.get('DataCategoryName'))){
                    kavsCat = new set<String>();
                }else{
                    kavsCat = knowledgeCatMap.get(howToCat.get('DataCategoryGroupName') + ':' + howToCat.get('DataCategoryName'));
                }
                
                kavsCat.add((String)howToCat.get('ParentId'));
                knowledgeCatMap.put(howToCat.get('DataCategoryGroupName') + ':' + howToCat.get('DataCategoryName'),kavsCat);
            }
        
        }
        
        /*
        List<HOW_TO_TEMPLATE__DataCategorySelection> howTosCategories = [Select h.ParentId,h.CreatedDate, h.DataCategoryName, h.DataCategoryGroupName From HOW_TO_TEMPLATE__DataCategorySelection h 
                                                                            where ParentId in: kavsLastModifDate.keyset()];
        
        for(HOW_TO_TEMPLATE__DataCategorySelection howToCat:howTosCategories){
            
            set<String> kavsCat;
            
            if(!knowledgeCatMap.containsKey(howToCat.DataCategoryGroupName + ':' + howToCat.DataCategoryName)){
                kavsCat = new set<String>();
            }else{
                kavsCat = knowledgeCatMap.get(howToCat.DataCategoryGroupName + ':' + howToCat.DataCategoryName);
            }
            
            kavsCat.add(howToCat.ParentId);
            knowledgeCatMap.put(howToCat.DataCategoryGroupName + ':' + howToCat.DataCategoryName,kavsCat);
        }
        */
        
        List<System_Subscription_Email__c> emailSubs = new List<System_Subscription_Email__c>();
        
        List<Solution_Search_Alert__c> solAlertsToUpdate = new List<Solution_Search_Alert__c>();
        
        for(sObject sobj:scopeList){
            User currentUser = (User)sobj;
            map <String,KnowledgeArticleVersion> articlesToEmails = new map <String,KnowledgeArticleVersion>();
            for(Solution_Search_Alert__c ssa:currentUser.Solution_Search_Alerts__r){
                //checking the subscription type 
                //if article then we add the article to the list to send if the article changed today
                //if category then loop thru the articles changed today and add them to be sent
                //the same with article types
                
                ssa.Last_Run_Date__c = Datetime.now();
                solAlertsToUpdate.add(ssa);
                
                if(ssa.Type__c == 'Article'){
                    
                    if(knowledgeMaps.containsKey(ssa.Article_ID__c)){
                        
                        articlesToEmails.put(knowledgeMaps.get(ssa.Article_ID__c).knowledgearticleId,knowledgeMaps.get(ssa.Article_ID__c));
                        
                    }
                    
                }else if(ssa.Type__c == 'Category'){
                    
                    if(knowledgeCatMap.containsKey(ssa.Category_ID__c)){
                        for(String kavId:knowledgeCatMap.get(ssa.Category_ID__c)){
                            if(kavsLastModifDate.containsKey(kavId)){
                                KnowledgeArticleVersion thekavToEmail =  kavsLastModifDate.get(kavId);
                                if(ssa.Solution_Search_Alert_Preference__c == 'New And Updated Articles' ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }else if(ssa.Solution_Search_Alert_Preference__c == 'Only New Articles' && isNew(lastRun,thekavToEmail.firstPublishedDate)  ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }else if(ssa.Solution_Search_Alert_Preference__c == 'Only Updated Articles' && !isNew(lastRun,thekavToEmail.firstPublishedDate)){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }
                            }
                        }
                    }
                    
                    
                }else if(ssa.Type__c == 'Article Type'){
                    
                    
                    if(typeToArticleIdMap.containsKey(ssa.Article_Type_API_Name__c)){
                        for(String kavId:typeToArticleIdMap.get(ssa.Article_Type_API_Name__c)){
                            if(knowledgeMaps.containsKey(kavId)){
                                KnowledgeArticleVersion thekavToEmail =  knowledgeMaps.get(kavId);
                                if(ssa.Solution_Search_Alert_Preference__c == 'New And Updated Articles' ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }else if(ssa.Solution_Search_Alert_Preference__c == 'Only New Articles' && isNew(lastRun,thekavToEmail.firstPublishedDate)  ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }else if(ssa.Solution_Search_Alert_Preference__c == 'Only Updated Articles' && !isNew(lastRun,thekavToEmail.firstPublishedDate) ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }
                            }
                        }
                        
                    }
                    
                }else if(ssa.Type__c == 'Category and Article Type'){
                    
                    if(typeToArticleIdMap.containsKey(ssa.Article_Type_API_Name__c) && knowledgeCatMap.containsKey(ssa.Category_ID__c)){
                        for(String kavId:typeToArticleIdMap.get(ssa.Article_Type_API_Name__c)){
                            if(knowledgeMaps.containsKey(kavId) && (knowledgeCatMap.get(ssa.Category_ID__c)).contains(knowledgeMaps.get(kavId).Id)){
                                KnowledgeArticleVersion thekavToEmail =  knowledgeMaps.get(kavId);
                                if(ssa.Solution_Search_Alert_Preference__c == 'New And Updated Articles' ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }else if(ssa.Solution_Search_Alert_Preference__c == 'Only New Articles' &&  isNew(lastRun,thekavToEmail.firstPublishedDate) ){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }else if(ssa.Solution_Search_Alert_Preference__c == 'Only Updated Articles' && !isNew(lastRun,thekavToEmail.firstPublishedDate)){
                                    articlesToEmails.put(thekavToEmail.knowledgearticleId,thekavToEmail);
                                }
                            }
                        }
                        
                    }
                    
                }
                
            }
            
            
          List<String> keys = new List<String>(articlesToEmails.keySet());
            
            List<UserRecordAccess> recordAccess = [SELECT RecordId FROM UserRecordAccess WHERE UserId =: currentUser.Id
                                                                                                AND RecordId in: keys
                                                                                                and HasReadAccess = true];
            set <Id> allowedIds = new set <Id>();
            for(UserRecordAccess userRec:recordAccess){
                allowedIds.add(userRec.RecordId);
            }
            
            //we store the emails to send so we can send them in another batch job
            String articleEmailBody = '';
            
            List<KnowledgeArticleVersion> articlesToEmailSorted  = articlesToEmails.values();
            
            sortList(articlesToEmailSorted,'articleType','asc');
            
            String articleTypeForOrdering = '';
            
            for(KnowledgeArticleVersion kavEmail:articlesToEmailSorted){
                if(allowedIds.contains(kavEmail.knowledgearticleId)){
                    if( articleTypeForOrdering != kavEmail.ArticleType){
                        if(articleTypeForOrdering != ''){
                            articleEmailBody += '<br/>' ;
                        }
                        articleTypeForOrdering = kavEmail.ArticleType;
                        articleEmailBody += '<b>'+getKAVDescribeById(kavEmail.knowledgeArticleId).getLabel() + '</b><br/>';
                    }
                    if(currentUser.UserType != 'Standard'){
                       //MS-01/2016  String EncodedURL = EncodingUtil.urlEncode(System.Label.Genesys_Authenticated_Portal_URL + 'pkb_Home?id=' + kavEmail.knowledgeArticleId, 'UTF-8');
                      //  String EncodedURL = EncodingUtil.urlEncode(System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + 'apex' + '/' + 'pkb_Home?id=' + kavEmail.knowledgeArticleId, 'UTF-8');
                        String EncodedURL = EncodingUtil.urlEncode('/customercare/pkb_Home?id=' + kavEmail.knowledgeArticleId, 'UTF-8');
                        articleEmailBody += '<a href="'+siteURL+'?startURL='+ EncodedURL + '" >'+kavEmail.title+'</a><br/>';
                    }else{
                        articleEmailBody += '<a href="'+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + kavEmail.knowledgeArticleId + '" >'+kavEmail.title+'</a><br/>';
                        
                    }
                }
            }
            
            
            if(articleEmailBody != ''){
                if(currentUser.UserType == 'Standard'){
                    articleEmailBody = '<b>Links for Genesys staff only.</b><br/>' + articleEmailBody;
                }
                emailSubs.add(new System_Subscription_Email__c(Email_Body__c = articleEmailBody,To_User__c = currentUser.Id,isSent__c=false));
            }
            
        }
        
        insert emailSubs;
        update solAlertsToUpdate;
    }
    
    
     global static void sortList(List<Sobject> items, String sortField, String order){


       List<Sobject> resultList = new List<Sobject>();
   
        //Create a map that can be used for sorting 
       Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
           
       for(Sobject ob : items){
                if(objectMap.get(ob.get(sortField)) == null){  // For non Sobject use obj.ProperyName
                    objectMap.put(ob.get(sortField), new List<Sobject>()); 
                }
                objectMap.get(ob.get(sortField)).add(ob);
        }       
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
       
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
       
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(Sobject ob : resultList){
                items.add(ob); 
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]);  
            }
        }
    }
    
    global static Set<String> kavNames { 
        set;
        get {
            if (kavNames == null) {
                kavNames = new Set<String>();
            Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
    
            for (String s : gd.keySet()) {
              if (s.contains('__kav')) {
                kavNames.add(s);
              }
            }
            }
          return kavNames;
        }
    }

    global static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap {
        get {
            if (kavObjPrefixMap == null) {
                kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
                Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
                Schema.DescribeSObjectResult sor;
                for (String s : kavNames) {
                    sor = gd.get(s).getDescribe(); 
                    kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
                }
            }
          return kavObjPrefixMap;
        }
    }

      global static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
        if (isBlank(i) || i.length() < 15) return null;
        return kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
      }

    global static boolean isNew(DateTime lastRun, DateTime firstPublishedDate){
        Boolean isNew = false;
        
        if(lastRun < firstPublishedDate){
            isNew = true;
        }
        return isNew;
    }
    
    // returns true if string is null or empty
      global static Boolean isBlank(String s) {
        return ( s == null || s == '');
      }


     



}