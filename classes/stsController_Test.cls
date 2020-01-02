@isTest
public with sharing class stsController_Test {
    //Initialization
    //  - Create Controller Object
    //  - Add items to PSS_Catalog__c
    //  - Add questions to PSS_Catalog_Question__c
    //  - Add packages to PSS_Package__c
    public static void Initialize(){
        PSS_Catalog__c cat1 = new PSS_Catalog__c(name='catalog 1', Scope__c='catalog 1 scope', tokenCount__c=2, PSS_ID__c='001');
        insert cat1;
        PSS_Catalog_Question__c q1 = new PSS_Catalog_Question__c(name='question 1', question__c='What is question 1?', category__c='2. Routing', answerType__c='Numeric', PSS_Catalog__c=cat1.Id);
        insert q1;
        PSS_Package__c p1 = new PSS_Package__c(name='package 1', description__c='description', scope__c='scope', tokens__c=40, eps__c=10);
        insert p1;
    } 
    
    //Build new Opportunity
    public static testMethod void createOpportunity(){
        Initialize();
        
        PSS_Catalog__c cat11 = new PSS_Catalog__c(name='catalog 11', Scope__c='catalog 1 scope', tokenCount__c=2, PSS_ID__c='001');
        insert cat11;
        PSS_Catalog_Question__c q11 = new PSS_Catalog_Question__c(name='question 1', question__c='What is question 1?', category__c='2. Routing', answerType__c='Numeric', PSS_Catalog__c=cat11.Id);
        insert q11;
        PSS_Package__c p11 = new PSS_Package__c(name='package 11', description__c='description', scope__c='scope', tokens__c=40, eps__c=10);
        insert p11;
        
        stsController controller = new stsController();
        Test.startTest();
        controller.renderBlankPage(true);
        controller.updatePage();
        controller.save();
        controller.getPss();
        controller.getTokenCount();
        controller.getItems();
        controller.loadOpp();
        controller.AddTokenBundles(1,cat11);
        controller.deleteOpp();
        controller.loadQuote();
        
        Test.stopTest();
        
        List<PSS_Opportunity__c> oppList = [SELECT Id from PSS_Opportunity__c where Id=:controller.pssOpp.Id];
        //System.assertEquals(oppList.size(), 1);
    }
}