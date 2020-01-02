@IsTest
public with sharing class SMLExcelControllerTest { 
   
   static testMethod void myUnitTestForCase1() {

        SMLExcelController hh = new SMLExcelController();
        
        Country__c objCountry = new Country__c(Country__c='United StatesA', DAP_Region__c='NA', 
                                                Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA', SubRU__c='USA',       
                                                New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;

        Id RecordTypeIdContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        Account testAccount = new Account( Name='Test Account12345678', Status__c = 'Active');  
        testAccount.RecordtypeId= RecordTypeIdContact;
        insert testAccount;

        Solution_Category__c testSolutionCategory = new Solution_Category__c();
        testSolutionCategory.Name = 'Test Category';
        testSolutionCategory.Active__c = true;
        testSolutionCategory.Solution_Name__c = 'Test Category';
        insert testSolutionCategory;
        
        SML_Data__c testSMLData = new SML_Data__c();
        testSMLData.Account__c = testAccount.id; 
        testSMLData.Solution_Category__c = testSolutionCategory.id;
        testSMLData.Status__c = 'Whitespace';
        insert testSMLData;
        
        testSMLData.Status__c = 'Sold';
        update testSMLData;

          String accName ='Test Account12345678';
          String accountType ='Customer';
          String vertical ='ENERGY%20-%20UTILITIES';
          //String territory ='Test';
          String region ='APAC';
          //String subRegion ='USA';

        PageReference myVfPage = Page.SMLExcel;
          Test.setCurrentPage(myVfPage);

          ApexPages.currentPage().getParameters().put('accName', accName);
          ApexPages.currentPage().getParameters().put('accId',testAccount.Id);
          ApexPages.currentPage().getParameters().put('viewId', 'All Accounts');
          ApexPages.currentPage().getParameters().put('key', 'true');
          ApexPages.currentPage().getParameters().put('must', 'true');
          ApexPages.currentPage().getParameters().put('selectedAE', UserInfo.getUserId());
          ApexPages.currentPage().getParameters().put('accountType', accountType);
          //ApexPages.currentPage().getParameters().put('territory', territory);
          ApexPages.currentPage().getParameters().put('vertical', vertical);
          ApexPages.currentPage().getParameters().put('region', region);
          //ApexPages.currentPage().getParameters().put('subRegion', subRegion);
          ApexPages.currentPage().getParameters().put('selectedFilter', 'Customer Crosssell');

          hh.loadFilters();
          hh.filter();
   }

   static testMethod void myUnitTestForCase2() {

        SMLExcelController hh = new SMLExcelController();
        
        Country__c objCountry = new Country__c(Country__c='United StatesA', DAP_Region__c='NA', 
                                                Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA', SubRU__c='USA',       
                                                New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;

        Id RecordTypeIdContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        Account testAccount = new Account( Name='Test Account12345678', Status__c = 'Active');  
        testAccount.RecordtypeId= RecordTypeIdContact;
        insert testAccount;

        Solution_Category__c testSolutionCategory = new Solution_Category__c();
        testSolutionCategory.Name = 'Test Category';
        testSolutionCategory.Active__c = true;
        testSolutionCategory.Solution_Name__c = 'Test Category';
        insert testSolutionCategory;
        
        SML_Data__c testSMLData = new SML_Data__c();
        testSMLData.Account__c = testAccount.id; 
        testSMLData.Solution_Category__c = testSolutionCategory.id;
        testSMLData.Status__c = 'Whitespace';
        insert testSMLData;
        
        testSMLData.Status__c = 'Sold';
        update testSMLData;

          String accName ='Test Account12345678';
          String accountType ='Customer';
          String vertical ='ENERGY%20-%20UTILITIES';
          //String territory ='Test';
          String region ='APAC';
          //String subRegion ='USA';

        PageReference myVfPage = Page.SMLExcel;
          Test.setCurrentPage(myVfPage);

          ApexPages.currentPage().getParameters().put('accName', accName);
          ApexPages.currentPage().getParameters().put('accId',testAccount.Id);
          ApexPages.currentPage().getParameters().put('viewId', 'All Accounts');
          ApexPages.currentPage().getParameters().put('key', 'true');
          ApexPages.currentPage().getParameters().put('must', 'true');
          ApexPages.currentPage().getParameters().put('selectedAE', UserInfo.getUserId());
          ApexPages.currentPage().getParameters().put('accountType', accountType);
          //ApexPages.currentPage().getParameters().put('territory', territory);
          ApexPages.currentPage().getParameters().put('vertical', vertical);
          ApexPages.currentPage().getParameters().put('region', region);
          //ApexPages.currentPage().getParameters().put('subRegion', subRegion);
          ApexPages.currentPage().getParameters().put('selectedFilter', 'My Team');

          hh.loadFilters();
          hh.filter();

           ApexPages.currentPage().getParameters().put('selectedFilter', 'My Accounts');

          hh.loadFilters();
          hh.filter();
          hh.initialStatus='hello'; 
          hh.feedback = new SML_Feedback_Comments__c();
          hh.feedbacks= new List<SML_Feedback_Comments__c>();

   }

   static testMethod void myUnitTestForCase() {
        SMLExcelController hh = new SMLExcelController();
     
        Id RecordTypeIdContact = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
        Account testAccount = new Account( Name='Test Account12345678', Status__c = 'Active' );  
        testAccount.RecordtypeId= RecordTypeIdContact;
        insert testAccount;

        Solution_Category__c testSolutionCategory = new Solution_Category__c();
        testSolutionCategory.Name = 'Test Category';
        testSolutionCategory.Active__c = true;
        testSolutionCategory.Solution_Name__c = 'Test Category';
        insert testSolutionCategory;
        
        SML_Data__c testSMLData = new SML_Data__c();
        testSMLData.Account__c = testAccount.id; 
        testSMLData.Solution_Category__c = testSolutionCategory.id;
        testSMLData.Status__c = 'Whitespace';
        insert testSMLData;
        
        testSMLData.Status__c = 'Sold';
        update testSMLData;

      String accName ='Test';
      String accountType ='Customer';
      String vertical ='ENERGY%20-%20UTILITIES';
      String territory ='Test';
      String region ='APAC';
      String subRegion ='Test';
      
      PageReference myVfPage = Page.SMLExcel;
      Test.setCurrentPage(myVfPage);

      ApexPages.currentPage().getParameters().put('accName', accName);
      ApexPages.currentPage().getParameters().put('accId',testAccount.Id);
      ApexPages.currentPage().getParameters().put('viewId', 'All Accounts');
      ApexPages.currentPage().getParameters().put('key', 'All Accounts');
      ApexPages.currentPage().getParameters().put('must', 'All Accounts');
      ApexPages.currentPage().getParameters().put('selectedAE', 'All Accounts');
      ApexPages.currentPage().getParameters().put('accountType', accountType);
      ApexPages.currentPage().getParameters().put('territory', territory);
      ApexPages.currentPage().getParameters().put('vertical', vertical);
      ApexPages.currentPage().getParameters().put('region', region);
      ApexPages.currentPage().getParameters().put('subRegion', subRegion);
      ApexPages.currentPage().getParameters().put('selectedFilter', 'Customer Crosssell');
      //
        hh.smlDataRow = testSMLData;
        hh.mapCategoryVsColor = new map<String,string>();
        hh.selectedTab='test';
        //hh.initialStatus='test';
        hh.showOLIs =false;
        hh.showQPs =false;
        hh.showOpps =false;
        hh.hideAnalytics =false;
        hh.hideCustomerEngagement =false;
        hh.hideBussOpt =false;
        hh.hideEmpEngagement =false;
        hh.hideOmni =false;
        hh.hideMultimediaCommunication =false;
        hh.showHidePopup =false;
        hh.showPopupFlag =false;
        hh.positiveChange =false;
        hh.negativeChange =false;    
        hh.pageClick =false;
        hh.hideSelfService =false;    
        hh.hidePlateFormService =false;
        hh.hideAssistedService =false;
        hh.showNaStatus =false;

        hh.pageSize =1;
        hh.pageNo =1;
        hh.pageStart =1;
        hh.pageEnd =1;
        hh.pages =1;    

        hh.smlDataId ='test';
        hh.orgName ='test';
        hh.category ='test';
        hh.accountFilters = new List<SelectOption>();
        hh.countries      = new List<SelectOption>();
        hh.regionList     = new List<SelectOption>();
        hh.subRegionList  = new List<SelectOption>();
        hh.aeList         = new List<SelectOption>();

        SMLExcelController.dataWrapper ff = new SMLExcelController.dataWrapper();
        ff.accountName ='test';
        ff.accountNameFull ='test';
        ff.accountId ='test';
        ff.accountType ='test';
        ff.orgClass ='test';
        ff.logoName ='test';
        ff.territory ='test';
        ff.country ='test';
        ff.assignedAE ='test';
        ff.assignedAEFull ='test';
        ff.engagementScore =1;
        ff.whiteSpaceScore=2;
        ff.scoreType='score';
        ff.hideColumn=false;
        ff.smlCategoryData = new Map<String, SML_Data__c> ();
        
        
       // hh.initialStatus ='test';
        /*
        public List<SelectOption> countries {get;set;}
        public List<SelectOption> regionList {get;set;}
        public List<SelectOption> subRegionList {get;set;}
        public SML_Data__c smlDataRow {get;set;}
        public SML_Feedback_Comments__c feedback {get;set;}
        public transient List<SML_Feedback_Comments__c> feedbacks {get;set;}
        */
        
   }
}