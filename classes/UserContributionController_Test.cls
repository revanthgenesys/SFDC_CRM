@isTest (seeAllData = true)
private class UserContributionController_Test {
	
	static testMethod void howToTemplate() {
        List<Case> testCase = setData(1);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new HOW_TO_TEMPLATE__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Problem_Description__c, ctl.getRecord().get('BENEFITS__c'));
        System.assertEquals(testCase[0].Additional_Recommendations__c, ctl.getRecord().get('SUPPLEMENTAL_INFORMATION__c'));
        System.assertEquals(testCase[0].Resolution_Steps__c, ctl.getRecord().get('STEPS_TO_IMPLEMENT__c'));
	}
	
	static testMethod void internalProcess() {
        List<Case> testCase = setData(2);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new INTERNAL_PROCESSES__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Description, ctl.getRecord().get('QUESTIONSUMMARY__c'));
	}
	
	static testMethod void QA() {
        List<Case> testCase = setData(3);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new QUESTION_AND_ANSWER__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Problem_Description__c, ctl.getRecord().get('QUESTION_DETAIL__c'));
        System.assertEquals(testCase[0].Additional_Recommendations__c, ctl.getRecord().get('SUPPLEMENTAL_INFORMATION__c'));
        System.assertEquals(testCase[0].Resolution_Steps__c, ctl.getRecord().get('ANSWER__c'));       
	}
	
	static testMethod void solution() {
        List<Case> testCase = setData(4);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new SOLUTIONS__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Problem_Description__c, ctl.getRecord().get('Description__c'));
        System.assertEquals(testCase[0].Additional_Recommendations__c, ctl.getRecord().get('SUPPLEMENTAL_INFORMATION__c'));
        System.assertEquals(testCase[0].Problem_Root_Cause__c, ctl.getRecord().get('ROOT_CAUSE__c'));
        System.assertEquals(testCase[0].Resolution_Steps__c, ctl.getRecord().get('SOLUTION__c'));
	}
	
	static testMethod void techArticle() {
        List<Case> testCase = setData(5);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new TECHNICAL_ARTICLE__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Problem_Description__c, ctl.getRecord().get('OVERVIEW__c'));
        System.assertEquals(testCase[0].Additional_Recommendations__c, ctl.getRecord().get('SUPPLEMENTAL_INFORMATION__c'));
        System.assertEquals(testCase[0].Resolution_Steps__c, ctl.getRecord().get('DETAIL__c'));
	}
	
	static testMethod void techNotes() {
        List<Case> testCase = setData(6);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new TECH_NOTES__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Additional_Recommendations__c, ctl.getRecord().get('SUPPLEMENTAL_INFORMATION__c'));
        System.assertEquals(testCase[0].Problem_Description__c + '\n' + testCase[0].Resolution_Steps__c, ctl.getRecord().get('DETAIL__c'));
	}
	
	static testMethod void troublUtil() {
        List<Case> testCase = setData(7);
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('sourceId', testCase[0].Id);
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');
        ApexPages.KnowledgeArticleVersionStandardController ctl =
        new ApexPages.KnowledgeArticleVersionStandardController(new TROUBLESHOOTING_UTILITIES__kav());
        new UserContributionController(ctl);
        Test.stopTest();
        
        System.assertEquals(testCase[0].Id, ctl.getSourceId());
        System.assertEquals(testCase[0].Subject, ctl.getRecord().get('Title'));
        System.assertEquals(testCase[0].Problem_Description__c, ctl.getRecord().get('DETAIL__c'));
	}
	
	private static List<Case> setData(Integer testNum) {
		//List<User> runAsUser = TestUtil.createUsers(1, true);
		User u = new User();
		u.Username = 'test' + testNum + Math.random().format()+'@genesys.com';		
		u.LastName= 'Test';
		u.FirstName= 'Test';
		u.Email= u.Username;
		u.CommunityNickname= u.Username.substring(0, u.Username .indexOf('@'));
		u.Alias= u.CommunityNickname.substring(0,5);
		u.TimeZoneSidKey='Europe/Paris';  
		u.LocaleSidKey='fr_FR_EURO';
		u.EmailEncodingKey='ISO-8859-1';
		Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];   	
		u.ProfileId = prof.Id;		       
		u.LanguageLocaleKey='fr';
		u.isActive=true;
		u.ByPassValidationRules__c = true;
		u.EmployeeNumber = 'EMP-'+ Math.random().format();					
        u.Bypass_Triggers__c = true;
        u.BypassWorkflows__c = true;
        u.BypassValidationRules__c = true;
        insert u;
       
        System.runAs(u) {
       		//TestUtil.setConfigValues();
       		//TestUtil.setCaseSupportTypesSettings();
        }
                     
    	List<Support_Product__c> testParentSupportProducts = TestUtil.createSupportProducts(2, true);   	
    	List<Support_Product__c> testSupportProducts = TestUtil.createSupportProducts(6, false);
    	testSupportProducts[0].Product_Type__c = 'Component';
    	testSupportProducts[0].Parent_Product__c = testParentSupportProducts[0].id;
    	testSupportProducts[1].Product_Type__c = 'Component';
    	testSupportProducts[1].Parent_Product__c = testParentSupportProducts[1].id;    
    	testSupportProducts[2].Product_Type__c = 'Product Line';
    	testSupportProducts[3].Product_Type__c = 'Product Line';    	
    	testSupportProducts[4].Product_Type__c = 'Product';
    	testSupportProducts[4].Parent_Product__c = testParentSupportProducts[0].id;
    	testSupportProducts[5].Product_Type__c = 'Product';
    	testSupportProducts[5].Parent_Product__c = testParentSupportProducts[1].id;
    	
    	insert testSupportProducts;
       	  	
    	Product_Version__c testPV = TestUtil.createProductVerion(1, true, testSupportProducts[0])[0];
    	List<Account> testAccounts = TestUtil.createAccounts(2, true);
    	
    	Contact testContact;    	
    	System.runAs(u) {
    		testContact = TestUtil.createContacts(1, testAccounts[0], true)[0];
    	}
    	List<Case> testCase = TestUtil.createCases(2, false);
    	String rtype1 = Global_Setting__c.getInstance('Genesys_Product_Case').ID__c;
    	testCase[0].RecordTypeId= Global_Setting__c.getInstance('Genesys_Product_Case').ID__c;
    	testCase[0].Component__c = testSupportProducts[0].id;    	
    	testCase[0].End_User_Account__c = testAccounts[0].id;
    	testCase[0].Sold_To_Account__c = testAccounts[1].id;    		
    	testCase[0].Support_Product__c = testSupportProducts[4].id;
    	testCase[0].Product_Line__c = testParentSupportProducts[0].id;
    	testCase[0].Product_Version__c = testPV.id;
    	testCase[0].ContactId = testContact.id;
    	testCase[0].Problem_Description__c = 'Problem Description'; 
        testCase[0].Additional_Recommendations__c = 'Additional Information';
        testCase[0].Resolution_Steps__c = 'Resolution Steps';
        testCase[0].Problem_Root_Cause__c = 'Root Cause';
        testCase[0].Additional_Recommendations__c = 'Additional Recommendations';      
    	testCase[0].Subject = 'Title';
    	testCase[0].Description = 'Description';
    	   	
    	insert testCase[0];
    	
    	return testCase;
    	
	}

}