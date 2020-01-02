@isTest
public without sharing class pkb_Test {

  static String siteName = 'PKB_TEST_' + String.valueOf(Crypto.getRandomInteger());    // use this to set the siteName prop of the pkb_Controller class
  static String publishStatus = 'draft'; // use this to set the pub status prop of the pkb_Controller
  static String lang = 'en_US';
  static PKB__c pkb;
  static SObject kavObj;
  static String objType;
  static PKB_Featured__c featured;
  static PKB_Featured__c keyword;
  static List<PKB_Article_Feedback_Deflection__c> pafds;
  class TestException extends Exception { }
  
  static testMethod void testController() {
    Test.startTest();
    setupData();
    setupSettingsData();

    Id kaId = (Id)kavObj.get('KnowledgeArticleId');
    Id kavId = (Id)kavObj.get('Id'); 
    String articleNumber = (String)kavObj.get('ArticleNumber');

    System.debug('***** SITE NAME: ' +siteName+ '*****');
    System.debug('***** PKB NAME: ' +pkb.Name+ '*****');
    System.debug('***** KEYWORD PKB NAME: ' +keyword.PKB_Name__c+ ' *****');

    System.debug('***** DOES KEYWORD RECORD EXIST? *****');
    System.debug([select Id, Name, Article_Number__c from PKB_Article_Feedback_Deflection__c where Id = :keyword.Id]);

    String catString;

    // setupData will have instantiated kavObj, and if it hasn't, show the error and return
    if (kavObj == null) {
      System.debug('***** APEX UNIT TEST ERROR: PLEASE ENSURE THAT AT LEAST ONE CUSTOM ARTICLE TYPE IS DEFINED IN THE ORG *****');
      return;
    }

    // set the fixed search results to all possible ids that should be returned via sosl throughout the code
    List<String> searchResults = new List<String>{
      keyword.Id,
      kavId     
    };
    Test.setFixedSearchResults(searchResults);
    
    System.debug('***** THESE IDs WILL ALWAYS RETURN WITH SOSL QUERIES: ***** ');
    System.debug(searchResults);

    // refCon is an essentially empty instance of the controller that allows access to the public variables that refer
    // to the names of the various url params that will be used to set up tests
    pkb_Controller refCon = new pkb_Controller();
    pkb_Controller pkbCon;
    PageReference p;
    
    // test first with no params and empty KA
    p = new PageReference('/');
    System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
    Test.setCurrentPage(p);
    pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
    System.assertNotEquals(pkbCon.publishStatus, null);

    // test with query of foo, language of english, and random category, and generate search RSS
    p = new PageReference('/');
    p.getParameters().put(refCon.queryParam, 'foo');
    p.getParameters().put(refCon.languageParam, lang);

    p.getParameters().put(refCon.categoryParam, catString);
    System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
    Test.setCurrentPage(p);
    pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
    pkbCon.prepareSearchRSS();

    // test with actual article id, so that viewingArticle will be true in the controller
    p = new PageReference('/?id=' +kaId);
    System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
    Test.setCurrentPage(p);
    pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle(Id = kaId)));
    pkbCon.prepareSearchRSS(); // to execute negative branch of first line of method

    // run through a bunch of the basic props
    System.assertNotEquals(pkbCon.pageTitle, null);
    System.assertNotEquals(pkbCon.selectedLanguageURL, null);
    pkbCon.selectedCategory = 'foo';
    System.assertNotEquals(pkbCon.selectedCategoryLabel, null);
    pkbCon.selectedCategory = '';
    System.assert(!pkbCon.caseCreateError);
    System.assert(!pkbCon.caseCreated);
    System.assert(!pkbCon.feedbackRecorded);
    System.assertNotEquals(pkbCon.languageOptions, null);
    System.assertEquals(pkbCon.currPage, 1);
    pkbCon.nextPage();
    pkbCon.prevPage();
    System.assertEquals(pkbCon.currPage, 1);

    // test basic defferal -- a deflection record should be created with an article associated to it since an article is being viewed
    pkbCon.deferred();
    pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
    System.assert(pafds.size() == 1);

    // test with contact us, while viewing article, and already entered question
    p = new PageReference('/');
    p.getParameters().put('id', kaId);
    p.getParameters().put(refCon.contactUsParam, refCon.contactUsValue);
//    p.getParameters().put(refCon.queryParam, 'help me');
    System.debug('****** TESTING WITH URL: ' +p.getUrl()+ ' *****');
    Test.setCurrentPage(p);
    pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle(Id = kaId)));

    // should add another defferal record
    pkbCon.feedbackComments = 'some comments';
    pkbCon.recordArticleFeedback();
    pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
    System.assert(pafds.size() == 2);
    
    // should add another defferal record
    pkbCon.contactUsDeferral();
    pafds = [select Id from PKB_Article_Feedback_Deflection__c where Article_Number__c = :articleNumber];
    System.assert(pafds.size() == 3);
    Test.stopTest();
    // set up for case creation
    pkbCon.theCud.firstName = 'Foo';
    pkbCon.theCud.lastName = 'Bar';
    pkbCon.theCud.email = ''; // should fail validation
    pkbCon.createCase();
    System.assert(pkbCon.caseCreateError);

    System.debug('***** CASE TYPE OPTS: *****');
    System.debug(refCon.caseTypeOptions);

    String validType = 'foo';
    if (!refCon.caseTypeOptions.isEmpty()) {
      for (SelectOption so : refCon.caseTypeOptions) {
        if (!isBlank(so.getValue())) validType = so.getValue();
        break;
      }
    }    
  }
  static testmethod void testController2()
  {
        pkb_Controller pkbCon = new pkb_Controller(new ApexPages.StandardController(new KnowledgeArticle()));
        
        //static PKB__c pkb;
        setupData();
        setupSettingsData();
        System.test.startTest();
        pkbCon.theCud = new pkb_Controller.ContactUsData();
        pkbCon.theCud.firstName = 'Foo';
        pkbCon.theCud.lastName = 'Bar';
        pkbCon.theCud.email = ''; // should fail validation
        // flip the pkb setting to create account and contact       
        pkb.Create_Contact_and_Account__c = true;
        update pkb;
        pkbCon.createCase(); 
        System.test.stopTest();
  }  
  static testMethod void testSettingsController() {
    setupSettingsData();

    pkb_SettingsController refCon = new pkb_SettingsController();
    pkb_SettingsController pkbsc;
    PageReference p;
    
    // test with new record
    p = new PageReference('/?' +refCon.createSettingsParam+ '=' +refCon.createSettingsValue);
    Test.setCurrentPage(p);
    pkbsc = new pkb_SettingsController(new ApexPages.StandardController(new PKB__c()));
    System.assert(pkbsc.creatingSettings);

    // test with existing record
    p = new PageReference('/?id=' +pkb.Id);
    Test.setCurrentPage(p);
    pkbsc = new pkb_SettingsController(new ApexPages.StandardController(pkb));
    System.assert(!pkbsc.creatingSettings);

    // there is at least one pkb settings record and so the settings options list is not empty
    System.assert(!pkbsc.settingsOptions.isEmpty());

    // this will fail the first time since there is no site named with this test's site name
    p = pkbsc.saveSettings();
    System.assertEquals(p, null);

    // throw the test bit and try again
    // save the settings and assert that the resulting page ref contains the id of the settings    
    pkb_SettingsController.isRunningTest = true;
    p = pkbsc.saveSettings();
    System.assert(p.getUrl().contains(pkb.Id));
  }

  static void setupSettingsData() {
    // create custom settings collection based on siteName
    pkb = new PKB__c();
    pkb.Name = siteName;
    pkb.Category_Group_1__c = '1';
    pkb.Category_Group_2__c = '2';
    pkb.Category_Group_3__c = '3';
    pkb.Root_Category_1__c = '1';
    pkb.Root_Category_2__c = '2';
    pkb.Root_Category_3__c = '3';

    pkb.Create_Contact_and_Account__c = false;
    pkb.Display_Article_Summary__c = true;
    pkb.Multi_Language_Enabled__c = true;
    pkb.Popular_Articles_Size__c = 2;
    pkb.Related_Articles_Size__c = 2;
    pkb.Results_Page_Size__c = 2;
    insert pkb;
  }

  static void setupData() {
    // create article of first type found in the objects that end with __kav
    List<String> kavNames = new List<String>(pkb_Controller.kavNames);
    if (kavNames.isEmpty()) return;

    // set the controller's default pub status to draft so that the queries will find records
    pkb_Controller.DEFAULT_PUBLISH_STATUS = publishStatus;
    pkb_Controller.DEFAULT_SITE_NAME = siteName;

    objType = kavNames.get(0);
    
    System.debug('***** CUSTOM ARTICLE TYPE: ' +objType+ ' *****');

    kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
    kavObj.put('Title','Foo Foo Foo!!!');
    kavObj.put('UrlName', 'foo-foo-foo2');
    kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
    kavObj.put('Language', lang);
    insert kavObj;

    // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    String q = 'select ' +pkb_Controller.join(pkb_Controller.kavFields, ',')+ ' from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
    kavObj = (KnowledgeArticleVersion)Database.query(q);

    // create featured record
    featured = new PKB_Featured__c(
      Article_Number__c = (String)kavObj.get('ArticleNumber'),
      Is_Keyword_Article__c = false,
      PKB_Name__c = siteName
    );    
    insert featured;

    System.debug('***** FEATURED RECORD JUST CREATED: ' +featured.Id+ ' *****');
    System.debug(featured);

    // create keyword recommended record
    keyword = new PKB_Featured__c(
      Article_Number__c = (String)kavObj.get('ArticleNumber'),
      Is_Keyword_Article__c = true,
      Keyword__c = 'foo',
      PKB_Name__c = siteName
    );        
    insert keyword;
    
    System.debug('***** KEYWORD RECORD JUST CREATED: ' +keyword.Id+ ' *****');
    System.debug(keyword);
    
  }
  
  
  static testMethod void testTheSubscriptions(){
    setupSubscriptionData();
    setupSubscriptionCatData();
  }
  
  
  
  
  public static void setupSubscriptionCatData() {
    pkb_categorySubscription pkbCatSub = new pkb_categorySubscription();
    
    
    //PageReference p = new PageReference('/');
    ApexPages.currentPage().getParameters().put('typeId', 'HOW_TO_TEMPLATE__kav');
     ApexPages.currentPage().getParameters().put('typeTitle', 'HOW TO');
    
     ApexPages.currentPage().getParameters().put('catJson', '[{"catId":"Product:SG_GENESYSDESKTOP_2_29","catValue":"Product:SG_GENESYSDESKTOP_2_29"},{"catId":"Product:SG_GENESYSRULESSYSTEM_1_2","catValue":"Product:SG_GENESYSRULESSYSTEM_1_2"}]');
    
    pkbCatSub.addArticleTypesubscribe();




    pkbCatSub.addCatAndTypesubscribe();
  }
  
  
  public static void setupSubscriptionData() {
    // create article of first type found in the objects that end with __kav
    List<String> kavNames = new List<String>(pkb_Controller.kavNames);
    if (kavNames.isEmpty()) return;

    // set the controller's default pub status to draft so that the queries will find records
    pkb_Controller.DEFAULT_PUBLISH_STATUS = publishStatus;
    pkb_Controller.DEFAULT_SITE_NAME = siteName;

    objType = kavNames.get(0);
    
    System.debug('***** CUSTOM ARTICLE TYPE: ' +objType+ ' *****');

    kavObj = Schema.getGlobalDescribe().get('HOW_TO_TEMPLATE__kav').newSObject();
    kavObj.put('Title','Foo Foo Foo Subscription!!!');
    kavObj.put('UrlName', 'foo-foo-foo-Subscription');
    kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo. Subscription');
    kavObj.put('Language', lang);
    insert kavObj;


    //KbManagement.PublishingService.publishArticle((String)kavObj.get('Id'),false);
    

    // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
    String q = 'select ' +pkb_Controller.join(pkb_Controller.kavFields, ',')+ ' from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = :publishStatus';
    kavObj = (KnowledgeArticleVersion)Database.query(q);

    List<recordType> recordTypes = [Select r.SobjectType, r.Name, r.Id From RecordType r where name='Article' and SobjectType = 'Solution_Search_Alert__c'];
            


    pkb_subscriptionController pkbSub = new pkb_subscriptionController();
    
    //System.assert(pkbSub.getThesubscribe() == null);
    System.assert(!pkbSub.getIssubscribe());


    pkbSub.articleId =((String)kavObj.get('knowledgeArticleId'));
    pkbSub.articleTitle=('Foo Foo Foo Subscription!!!');
    pkbSub.articleLanguage=(lang);


    pkbSub.togglesubscribe();

    System.assert(pkbSub.getIssubscribe());


    // create featured record
   Solution_Search_Alert__c newsub = new Solution_Search_Alert__c(
        User__c = userInfo.getUserId(),
        Article_Id__c = (String)kavObj.get('knowledgeArticleId'),
        Article_Title__c = (String)kavObj.get('Title'),
        Article_Language__c = (String)kavObj.get('Language'),
        Type__c = 'Article',
        Frenquency__c = '1 per Day',
        RecordTypeId = recordTypes[0].Id
    );
    insert(newsub);
    
    recordTypes = [Select r.SobjectType, r.Name, r.Id From RecordType r where name='Article Type' and SobjectType = 'Solution_Search_Alert__c'];
        
    Solution_Search_Alert__c newsub2 = new Solution_Search_Alert__c(
        User__c = userInfo.getUserId(),
        Article_Type_API_Name__c = 'HOW_TO_TEMPLATE__kav',
        Article_Type__c = 'HOW_TO_TEMPLATE__kav',
        Type__c = 'Article Type',
        RecordTypeId = recordTypes[0].Id,
        Solution_Search_Alert_Preference__c = 'Only Updated Articles'
    );
    insert newsub2;
    
  }
  

  // returns true if string is null or empty
  static Boolean isBlank(String s) {
    return ( s == null || s == '');
  }
  
  
  
  public static testMethod Case testCaseInsert() {
        User testUser = setupTestUser();
        Case testCase = getTestCase(testUser);
        //insert testCase;
        return testCase;
    }
    
    static User setupTestUser() {
        Id profileId = [Select Id From Profile WHERE UserType='Standard' Limit 1].Id;
        User testUser = new User(
            Alias = 'jqtester', 
            Username = 'jqtester@genesys.com',
            LastName = 'Tester',
            FirstName = 'John Q.', 
            Email = 'jquester@genesys.com', 
            CommunityNickname= 'JT',    
            TimeZoneSidKey='America/Los_Angeles',
            LocaleSidKey='en_US',
            EmailEncodingKey='ISO-8859-1',
            ProfileId= profileId,
            LanguageLocaleKey='en_US',
            isActive=true,
            ByPassValidationRules__c = true,
            EmployeeNumber = 'EMP-'+ Math.random().format()
        );
        insert testUser;
        return testUser;
    }
    
    static Case getTestCase(User owner) {
        return new Case(Status = 'New',
                        Case_Type__c = 'Data Visibility', 
                        Subject = 'Some Test Case for CaseSyncController and related Trigger' , 
                        Description = 'This is a case to test CaseSyncController and ProductCategoryFilterUpdate', 
                        OwnerId = owner.Id);             
    }
    
    /*static testMethod void testFlaggedArticleChatterTrigger() {
        User testUser = setupTestUser();
        setupData();
        Id kaId = (Id)kavObj.get('KnowledgeArticleId');
        FeedItem f = new FeedItem();
        f.CreatedById = testUser.Id;
        f.Type = 'TextPost';
        f.Body = 'Test of #flag chatter Item xx11xx22xx33xx';
        f.ParentId = kaId;
        insert f;
        List<Case> testCases = [SELECT Id,Description FROM Case WHERE AccountId=null AND Flagged_Article_Id__c=:kaId];
        System.assert(testCases.size()==1);
        if (testCases.size()==1) {
            String priorDesc = testCases[0].Description;
            f = new FeedItem();
            f.CreatedById = testUser.Id;
            f.Type = 'TextPost';
            f.Body = 'Test of #flag chatter Item xx11xx22xx33xx where case already exists';
            f.ParentId = kaId;
            insert f;
            testCases = [SELECT Id,Description FROM Case WHERE AccountId=null AND Flagged_Article_Id__c=:kaId];
            System.assert(testCases.size()==1);
            System.assert(priorDesc!=testCases[0].Description);
        }
    }*/
}