@isTest
public class CasePremContactProdSelection_Test {
	
	static Contact testContact;
	static User testUser;
	static Case cs;
	static Case cs2;
	static Account testAccount;
	static Support_Product__c prod;
	static Support_Product__c comp;
	
	static void setUpdata() {
	  Util.Bypass_Trigger_Chk = true;
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
    	prod = new Support_Product__c (name='Product', Product_Type__c = 'Product');
        insert prod;
        comp = new Support_Product__c (name='Product', Product_Type__c = 'Component', Parent_Product__c = prod.Id);
        insert comp;
        
       Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    boa.Platform__c = 'PureConnect On Premise';
	    boa.Support_Package__c = 'Managed Services';
	    boa.Contract_Status__c = 'Active';
	    insert boa;
	     boa.Contract_Status__c = 'Active';
	     update boa;
	     
	    Back_Office_Account__c boa2 = new Back_Office_Account__c();
	    boa2.Sold_To_Account__c = testAccount.Id;
	    boa2.End_User_Account__c = testAccount.Id;
	    boa2.Platform__c = 'PureEngage On Premise';
	    boa2.Contract_Status__c = 'Active';
	    insert boa2;
	     boa2.Contract_Status__c = 'Active';
	     update boa2;

        Support_Access__c sa = new Support_Access__c(Back_Office_Account__c = boa.Id, SR_Access_Level__c = 'Read/Write',
                                                      Status__c = 'Active', Contact__c = testContact.id);
        insert sa;
        
         Support_Access__c sa2 = new Support_Access__c(Back_Office_Account__c = boa2.Id, SR_Access_Level__c = 'Read/Write',
                                                      Status__c = 'Active', Contact__c = testContact.id);
        insert sa2;
        
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        
        cs = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id, Back_Office_Account__c = boa.Id, Major_Version__c ='1.0');                        
        insert cs;
        
        cs2 = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id, Back_Office_Account__c = boa2.Id, Major_Version__c ='1.0');                        
        insert cs2;
        	
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
	}
		
	static testMethod void newCaseInternal() {
		setUpdata();
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        
        Test.startTest();    
		ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
		ApexPages.currentPage().getParameters().put('fltr', 'eng'); 
		
		CasePremContactProdSelection contr = new CasePremContactProdSelection(null);	
		contr.endUserName = 'AccName';
		contr.soldToName = 'AccName';
		contr.portalFilter = 'eng';
		contr.isProductNotFound = true;
		contr.onProdNotFound();	
		contr.selectedProduct = prod.Id;
		contr.onchangeProduct();
		contr.selectedComponent = comp.Id;
		contr.onchangeComponent();
		contr.selectedMjrRel = 'Unknown';
		contr.onchangeRelease();
		contr.selectedVersion = 'Unspecified';
		contr.resetOptionsAll();
		contr.nextPage();
		contr.setPureCnctGroups();
		contr.setPureCnctProdsByGroup();
		contr.setPureCnctProblmByProd();	
		
		ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
		ApexPages.currentPage().getParameters().put('fltr', 'cnct'); 
		CasePremContactProdSelection contr2 = new CasePremContactProdSelection(null);	
			
		Test.stopTest();
	}
	
	static testMethod void newCasePortalEng() {
		setUpdata();
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        cs.recordtypeid = rectp[0].id;
        update cs;
        
        Test.startTest();    
    	System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
			ApexPages.currentPage().getParameters().put('fltr', 'eng');
		
			CasePremContactProdSelection contr = new CasePremContactProdSelection(null);
			contr.resetOptionsAll();
			contr.isProductNotFound = true;
			contr.endUserName = 'AccName';
		    contr.soldToName = 'AccName';
			contr.contactId = testContact.Id;
			contr.onProdNotFound();	
			contr.selectedProduct = prod.Id;
			contr.onchangePureEngageProduct();
			contr.selectedComponent = comp.Id;
			contr.onchangeComponent();
			contr.selectedMjrRel = '8.0';
			contr.onchangeRelease();
			contr.selectedVersion = '8.5.0.000';					    	
		   // contr.resetOptionsAll();		
			contr.saveCaseUpdates();		
			contr.nextPage();
			
			contr.caseType = 'Genesys_Feature_Request_Case';
			contr.nextPage();
			
			contr.caseType = 'Premises_Service_Request';
			contr.nextPage();
			
			String tltl = contr.pageTitle;
    	}
    	Test.stopTest();  		
	}
	
	static testMethod void newCasePortalCnct() {
		setUpdata();
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Premises_Service_Request'];
        cs.recordtypeid = rectp[0].id;
        update cs;
        
        Test.startTest();    
    	System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
			ApexPages.currentPage().getParameters().put('fltr', 'cnct');
		
			CasePremContactProdSelection contr = new CasePremContactProdSelection(null);
			contr.isProductNotFound = true;
			
			contr.endUserName = 'AccName';
		    contr.soldToName = 'AccName';
			contr.contactId = testContact.Id;
            
			contr.selectedProduct = prod.Id;
			contr.onchangeProduct();
			contr.onchangePureConnectProduct();
			contr.onchangePCGroup();
			
			contr.selectedMjrRel = '12';
			contr.onchangeRelease();
		
			contr.isPureEngage = true;
			contr.saveCaseUpdates();		
			contr.nextPage();
			contr.caseType = 'Genesys_Feature_Request_Case';
			contr.nextPage();
			
			contr.caseType = 'Premises_Service_Request';
			contr.nextPage();
			contr.resetOptionsAll();
			
			String tltl = contr.pageTitle;
    	}
    	Test.stopTest();  		
	}
	
	static testMethod void newCasePortalMac() {
		setUpdata();
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Premises_Service_Request'];
        cs.recordtypeid = rectp[0].id;
        update cs;
        
        Test.startTest();    
    	System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
			ApexPages.currentPage().getParameters().put('fltr', 'mac');
		
			CasePremContactProdSelection contr = new CasePremContactProdSelection(null);
			contr.isProductNotFound = true;
			contr.endUserName = 'AccName';
		    contr.soldToName = 'AccName';
		    contr.resetOptionsAll();
			contr.onchangeRelease();
			contr.onchangeComponent();
			contr.saveCaseUpdates();		
			contr.contactId = testContact.Id;            
			contr.selectedProduct = prod.Id;
						
			contr.nextPage();

			contr.isPureEngage = true;
			contr.caseType = 'Genesys_Feature_Request_Case';
			contr.nextPage();
			
			contr.isPureEngage = false;
			contr.isPureConnect = true;
			contr.caseType = 'Premises_Service_Request';
			contr.nextPage();
			
			String tltl = contr.pageTitle;
    	}
    	Test.stopTest();  		
	}
	
	static testMethod void updCaseInternal() {
		setUpdata();
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        
        Test.startTest();  
			PageReference pageRef = ApexPages.currentPage();
			pageRef.getParameters().put('Id', cs2.Id); 
			pageRef.getParameters().put('updRecTp', '1'); 
			pageRef.getParameters().put('fltr', 'eng'); 
			pageRef.getParameters().put('rqst', 'mac'); 
			
			ApexPages.StandardController sc = new ApexPages.StandardController(cs2);	
			CasePremContactProdSelection contr = new CasePremContactProdSelection(sc);	
		
			contr.contactId = testContact.Id;
			contr.endUserAccId = testAccount.Id;
			contr.soldToAccId = testAccount.Id;
			contr.resetOptionsAll();
			contr.endUserName = 'AccName';
		    contr.soldToName = 'AccName';
			contr.isProductNotFound = true;
			contr.onProdNotFound();	
			contr.selectedProduct = prod.Id;
			contr.selectedComponent = comp.Id;
			contr.onchangeComponent();
			contr.selectedMjrRel = '8.0';
			contr.selectedVersion = '8.5.0.000';

			contr.saveCaseUpdates();
			contr.nextPage();
			
			contr.isPureConnect = true;
			contr.patchRelease = '12';
			contr.saveCaseUpdates();
			
			contr.isPureEngage = true;
			pageRef.getParameters().put('rqst', 'dtprv'); 
			contr.saveCaseUpdates();
			
		Test.stopTest();  
	}
	
	static testMethod void updRecType() {
        setUpdata();
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        cs.recordtypeid = rectp[0].id;
        update cs;
        
        Test.startTest();  
            PageReference pageRef = ApexPages.currentPage();
			pageRef.getParameters().put('RecordType', rectp[0].Id); 
			pageRef.getParameters().put('Id', cs.Id); 
			pageRef.getParameters().put('updRecTp', '1'); 
			
			ApexPages.StandardController sc = new ApexPages.StandardController(cs);			
			CasePremContactProdSelection contr = new CasePremContactProdSelection(sc);	
			
			contr.resetOptionsAll();
			contr.onchangeRelease();
			contr.onchangeComponent();
			
			contr.contactId = testContact.Id;
			contr.endUserAccId = testAccount.Id;
			contr.soldToAccId = testAccount.Id;
			contr.endUserName = 'AccName';
		    contr.soldToName = 'AccName';
			
			contr.selectedProduct = prod.Id;
			contr.selectedComponent = comp.Id;
			contr.selectedMjrRel = '8.0';
			contr.selectedVersion = '8.5.0.000';
			
			contr.caseType = 'Genesys_Product_Case';
			contr.nextPage();
			List<SelectOption> ct = contr.categories;
			contr.onchangeCategory();
			contr.isProductNotFound = true;
			contr.onProdNotFound();	
			
			contr.saveCaseUpdates();

		Test.stopTest();  
	}

}