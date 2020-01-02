/*
	Naresh Kumar	06/15/2013
	Test class for the main controller class UpdateCaseProductControllerNew.
*/
//@isTest(seeAllData = true)
@isTest
private class UpdateCaseProductControllerNew_Test {

	 public static  User testUser;
     public static Contact testContact;
     public static Account accnt;
     public static Product_Version__c testPV;
     public static List<Account> testAccounts;
     public static List<Support_Product__c> testParentSupportProducts;
     public static List<Support_Product__c> testSupportProducts;
     public static Cloud_Deployment__c cldDep;
     
     public static void setTstData() {
     	    TestUtil.setConfigValues();
         List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
           TestUtil.setCaseSupportTypesSettings();
        }
     	
     	Util.Bypass_Trigger_Chk = true;
	    Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
	    accnt = TestUtil.createAccounts(1, true)[0];
	    testContact = TestUtil.createContacts(1, accnt, true)[0];
	    	
	    testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);    	
		testUser.ContactId = testContact.id;
		insert testUser;

	    cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
	                                          Cloud_Offering__c = 'Prod', Support_Status__c = 'Active', Sold_To_Account__c = accnt.id);
	    insert cldDep;
	        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
         
        Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = accnt.Id;
			boa.End_User_Account__c = accnt.Id;
			insert boa;
			
	    List<Support_Access__c> saLst = new List<Support_Access__c>();
		Support_Access__c pr = new Support_Access__c(Back_Office_Account__c = boa.Id,
			                                             Contact__c = testContact.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read/Write');
			                                             
		insert pr;   

    	testParentSupportProducts = TestUtil.createSupportProducts(3, true);  
    	
    	testParentSupportProducts[2].Product_Type__c = 'Product Line';
    	testParentSupportProducts[2].Name = 'Cloud';
    	update testParentSupportProducts[2];
    	 	
    	testSupportProducts = TestUtil.createSupportProducts(7, false);
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
    
    	testSupportProducts[6].Product_Type__c = 'Product';
    	testSupportProducts[6].Name = 'Cloud Products';
    	testSupportProducts[6].Parent_Product__c = testParentSupportProducts[2].id;
    	
    	insert testSupportProducts;
       	  	
    	testPV = TestUtil.createProductVerion(1, true, testSupportProducts[0])[0];
    	testAccounts = TestUtil.createAccounts(2, true);
    	
     }
     
    static testMethod void tstFR() 
    {
    	setTstData();
    	
    	Case testCase1 = new Case();
    	String rtype1 = Global_Setting__c.getInstance('Genesys_Feature_Request_Case').ID__c;
    	testCase1.RecordTypeId= Global_Setting__c.getInstance('Genesys_Feature_Request_Case').ID__c;
    	testCase1.Component__c = testSupportProducts[0].id;    	
    	testCase1.End_User_Account__c = testAccounts[0].id;
    	testCase1.Sold_To_Account__c = testAccounts[1].id;    		
    	testCase1.Support_Product__c = testSupportProducts[4].id;
    	testCase1.Product_Line__c = testParentSupportProducts[0].id;
    	testCase1.Product_Version__c = testPV.id;
    	testCase1.ContactId = testContact.id;
    	testCase1.Feature_Description__c = 'test description';
    	insert testCase1;
    	
    	Apexpages.currentPage().getParameters().put('page','2');
    	Apexpages.currentPage().getParameters().put('RecordType', rtype1);
    	Apexpages.currentPage().getParameters().put('cont', testContact.id);
    	Apexpages.currentPage().getParameters().put('eu', testAccounts[0].id);
    	Apexpages.currentPage().getParameters().put('sto', testAccounts[1].id);
    	Apexpages.currentPage().getParameters().put('pl', testParentSupportProducts[0].id);
    	Apexpages.currentPage().getParameters().put('cm', testSupportProducts[0].id);
    	Apexpages.currentPage().getParameters().put('pv', testPV.id);
    	Apexpages.currentPage().getParameters().put('sp', testSupportProducts[4].id);
    	ApexPages.currentPage().getParameters().put('isSaas','true');
    	Apexpages.currentPage().getParameters().put('conid', testContact.id);
   		
   	    Test.startTest();
 
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testCase1);
        UpdateCaseProductControllerNew objExtension = new UpdateCaseProductControllerNew(stdController);    
        objExtension.populateProdLines();
        objExtension.isProductNotFound = true;
    
        objExtension.populatesProds();
        objExtension.populateMajorVersion();
        objExtension.populatesComponents();
        objExtension.populatesProductVersions();
        objExtension.setVersion();
        objExtension.next();
        
        objExtension.lazyLoad();
        objExtension.save();
        objExtension.saveCase();
        objExtension.cancel();
   
        Test.stopTest();
   }
   
   static testMethod void adminCase() {
    	
   	    setTstData();
   	    
    	Case testCase1 = new Case();
    	String rtype1 = Global_Setting__c.getInstance('Genesys_Admin_Case').ID__c;
    	testCase1.RecordTypeId= Global_Setting__c.getInstance('Genesys_Admin_Case').ID__c;
    	testCase1.Component__c = testSupportProducts[0].id;    	
    	testCase1.End_User_Account__c = testAccounts[0].id;
    	testCase1.Sold_To_Account__c = testAccounts[1].id;    		
    	testCase1.Support_Product__c = testSupportProducts[4].id;
    	testCase1.Product_Line__c = testParentSupportProducts[0].id;
    	testCase1.Product_Version__c = testPV.id;
    	testCase1.ContactId = testContact.id;
    	testCase1.Feature_Description__c = 'test description';
   // 	insert testCase1;
    	    	
    	Apexpages.currentPage().getParameters().put('page','2');
    	Apexpages.currentPage().getParameters().put('RecordType', rtype1);
    	Apexpages.currentPage().getParameters().put('cont', testContact.id);
    	Apexpages.currentPage().getParameters().put('eu', testAccounts[0].id);
    	Apexpages.currentPage().getParameters().put('sto', testAccounts[1].id);
    	Apexpages.currentPage().getParameters().put('pl', testParentSupportProducts[0].id);
    	Apexpages.currentPage().getParameters().put('cm', testSupportProducts[0].id);
    	ApexPages.currentPage().getParameters().put('ct', 'Cloud');
    	Apexpages.currentPage().getParameters().put('conid', testContact.id);
    	ApexPages.currentPage().getParameters().put('dpl', cldDep.Id);
   	
   	    Test.startTest();
   	    
   	    System.runAs(testUser) {
	    	ApexPages.StandardController stdController = new ApexPages.StandardController(testCase1);
	        UpdateCaseProductControllerNew objExtension = new UpdateCaseProductControllerNew(stdController); 
	        objExtension.isPortalCloudUser = true;  
            objExtension.setContact();
   
	        objExtension.populateProdLines();
	        objExtension.isProductNotFound = true;
	   
	        objExtension.populatesProds();
	        objExtension.populateMajorVersion();
	        objExtension.populatesComponents();
	        objExtension.populatesProductVersions();
	        objExtension.lazyLoad();
	        objExtension.next();
	        objExtension.saveCase();
   	    }
        Test.stopTest();     	
   }
   
    static testMethod void tstOutage() 
    {
    	setTstData();
    	
    	Case testCase1 = new Case();
    	String rtype1 = Global_Setting__c.getInstance('Genesys_Outage').ID__c;
    	testCase1.RecordTypeId= Global_Setting__c.getInstance('Genesys_Outage').ID__c;
    	testCase1.Component__c = testSupportProducts[0].id;    	
    	testCase1.End_User_Account__c = testAccounts[0].id;
    	testCase1.Sold_To_Account__c = testAccounts[1].id;    		
    	testCase1.Support_Product__c = testSupportProducts[4].id;
    	testCase1.Product_Line__c = testParentSupportProducts[0].id;
    	testCase1.Product_Version__c = testPV.id;
    	testCase1.ContactId = testContact.id;
    	testCase1.Feature_Description__c = 'test description';
    	insert testCase1;
    	
    	Apexpages.currentPage().getParameters().put('page','2');
    	Apexpages.currentPage().getParameters().put('RecordType', rtype1);
    	Apexpages.currentPage().getParameters().put('cont', testContact.id);
    	Apexpages.currentPage().getParameters().put('eu', testAccounts[0].id);
    	Apexpages.currentPage().getParameters().put('sto', testAccounts[1].id);
    	Apexpages.currentPage().getParameters().put('pl', testParentSupportProducts[0].id);
    	Apexpages.currentPage().getParameters().put('cm', testSupportProducts[0].id);
    	Apexpages.currentPage().getParameters().put('pv', testPV.id);
    	Apexpages.currentPage().getParameters().put('sp', testSupportProducts[4].id);
    	ApexPages.currentPage().getParameters().put('isSaas','true');
    	Apexpages.currentPage().getParameters().put('conid', testContact.id);
   		
   	    Test.startTest();
 
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testCase1);
        UpdateCaseProductControllerNew objExtension = new UpdateCaseProductControllerNew(stdController);  
  
        objExtension.populateProdLines();
        objExtension.populatesProds();
        objExtension.populateMajorVersion();
        objExtension.populatesComponents();
        objExtension.populatesProductVersions();
        objExtension.setVersion();
        objExtension.next();
        
        objExtension.lazyLoad();
        objExtension.save();
        objExtension.caseType = 'Genesys_Outage';  
        objExtension.goToFRCasePage();
        objExtension.cancel();
   
        Test.stopTest();
   }
   
    static testMethod void tstIntCloud() 
    {
    	setTstData();
    	
    	Case testCase1 = new Case();
    	String rtype1 = Global_Setting__c.getInstance('Genesys_Product_Case').ID__c;
    	testCase1.RecordTypeId= Global_Setting__c.getInstance('Genesys_Product_Case').ID__c;
    	testCase1.Component__c = testSupportProducts[0].id;    	
    	testCase1.End_User_Account__c = testAccounts[0].id;
    	testCase1.Sold_To_Account__c = testAccounts[1].id;  
    	testCase1.Cloud_Deployment__c =  cldDep.Id;		
    	testCase1.Support_Product__c = testSupportProducts[4].id;
    	testCase1.Product_Line__c = testParentSupportProducts[0].id;
    	testCase1.ContactId = testContact.id;

    	insert testCase1;
    	
    	Apexpages.currentPage().getParameters().put('RecordType', rtype1);
    	Apexpages.currentPage().getParameters().put('cont', testContact.id);
    	Apexpages.currentPage().getParameters().put('eu', testAccounts[0].id);
    	Apexpages.currentPage().getParameters().put('sto', testAccounts[1].id);
     	Apexpages.currentPage().getParameters().put('conid', testContact.id);
   		
   	    Test.startTest();
 
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testCase1);
        UpdateCaseProductControllerNew objExtension = new UpdateCaseProductControllerNew(stdController);  
  
        objExtension.saveNewCloudCaseInternal();
        objExtension.cancel();
   
        Test.stopTest(); 
   }
   
 
}