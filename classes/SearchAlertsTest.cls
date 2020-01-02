@isTest(seeAllData = true)
public class SearchAlertsTest {
    
	static testMethod void init_NoParams(){
		PageReference pageRef = Page.SearchAlerts;
        SearchAlerts sa = new SearchAlerts();
        
        //test no parameters
        sa.init();      
    }
    
	static testMethod void init_InvalidParams(){
		PageReference pageRef = Page.SearchAlerts;
        SearchAlerts sa = new SearchAlerts();
        
        //test invalidparameters
        pageRef.getParameters().put('url', 'dummy');
        pageRef.getParameters().put('int', 'dummy');
        Test.setCurrentPage(pageRef);
        sa.init();
    }   
    
	static testMethod void init_SfQuestionParams(){
		PageReference pageRef = Page.SearchAlerts;
        SearchAlerts sa = new SearchAlerts();

        //test sf question document parameters
        pageRef.getParameters().put('url', 'http://www.salesforce.com/org:organization/object:Question/record:906Z00000004P4OIAU');
        pageRef.getParameters().put('int', 'https://genesys--SBGenFULL2.cs11.my.salesforce.com/906Z00000004P4OIAU');
        Test.setCurrentPage(pageRef);
        sa.init();
    }   
    
	static testMethod void init_TechDocsParams(){
		PageReference pageRef = Page.SearchAlerts;
        SearchAlerts sa = new SearchAlerts();
        
        //test techdoc document parameters
        pageRef.getParameters().put('url', 'https://docs.genesys.com/Documentation/PSAAS/latest/Administrator/Welcome');
        pageRef.getParameters().put('int', 'https://docs.genesys.com/Documentation/PSAAS/latest/Administrator/Welcome');
        Test.setCurrentPage(pageRef);
        sa.init();
    }  
    
	static testMethod void init_KbArticleParams(){
		PageReference pageRef = Page.SearchAlerts;
        SearchAlerts sa = new SearchAlerts();
        
        //test kbarticle document parameters
        pageRef.getParameters().put('url', 'http://www.salesforce.com/org:organization/articletype:SOLUTIONS/article:kA4Z000000002xRKAQ/language:en_US');
        pageRef.getParameters().put('int', 'https://genesys--SBGenFULL2.cs11.my.salesforce.com/kA4Z000000002xR?lang=en_US');
        Test.setCurrentPage(pageRef);
        sa.init();
    }        
    
    static testMethod void testAsAGuest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Genesys Customer Care Profile'];

                Account testAccount = TestUtil.createAccounts(1, false)[0];
        
        RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
        Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
        testAccount.Country__c = Ctry.Id;
        testAccount.recordTypeId = rt.Id;
        testAccount.Status__c = 'Active';
        testAccount.Account_Status__c = 'Active';  
        testAccount.Partner_Program_Status__c = 'Active';
        testAccount.Partner_Tier__c = 'Bronze';
        testAccount.PartnerType__c = 'VAR;Specialized Reseller;Cloud Reseller;Managed Services Provider;Contract Reseller';  
        insert testAccount;
        
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        
        User testUser = TestCommon.createUser('t0233', 'testGenUser0233@test132.com.test', 'testGenUserfname0233', 'testGenUserlname0233', p.id, false);      
        //testUser.ContactId = testContact.id;
        //insert testUser; 

        System.runAs(testUser){
			init_NoParams();
    		init_InvalidParams();
            init_SfQuestionParams();
            init_TechDocsParams();
            init_KbArticleParams();
        }
    }
}