@isTest 
public class CaseCloudDeplProdSelection_Test {
	
	static Contact testContact;
	static User testUser;
	static Case cs;
	static Account testAccount;
	static Support_Product__c prod;
	static Cloud_Deployment__c depl;
	static RecordType rectpcld;
	
	static void setUpdata() {
	  
		Util.Bypass_Trigger_Chk = true;
        
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
    	prod = new Support_Product__c (name='Cloud Product', Product_Type__c = 'Cloud Service', Cloud_Platform__c = 'Premier Edition');
        insert prod;
        
        depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Cloud_Platform__c = 'PureCloud';
        insert depl;
        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.Id, Cloud_Deployment__c = depl.Id, Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
        
        rectpcld = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Support_Request'];
       
        cs = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectpcld.id);                        
        insert cs;
        cs.Cloud_Deployment__c = depl.Id;
        update cs;
        	
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
	}
		
	static testMethod void newCaseInternal() {
		setUpdata();
	
        Test.startTest(); 
   
		ApexPages.currentPage().getParameters().put('RecordType', rectpcld.Id); 
		ApexPages.currentPage().getParameters().put('fltr', 'eng'); 
		CaseCloudDeplProdSelection contr = new CaseCloudDeplProdSelection(null);	
		contr.contactId = testContact.Id;
		contr.cs.Cloud_Deployment__c = depl.Id;		
		contr.getProdOptions();
		contr.cs.Cloud_Service__c = prod.Id;
        contr.saveCaseUpdates();
		contr.nextPage();
		contr.onchangeCategory();
		Test.stopTest(); 
	}
	
	static testMethod void newCasePortal() {
		setUpdata();
		
        Test.startTest();   
    
    	System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('RecordType', rectpcld.Id);
			ApexPages.currentPage().getParameters().put('fltr', 'pcld');
			CaseCloudDeplProdSelection contr = new CaseCloudDeplProdSelection(null);
            contr.contactId = testContact.Id;
			contr.cs.Cloud_Deployment__c = depl.Id;		
			contr.getProdOptions();
			contr.cs.Cloud_Service__c = prod.Id;
			String tltl = contr.pageTitle;
			String nm = contr.accntName;
            contr.saveCaseUpdates();
			contr.nextPage();			
    	}
    	Test.stopTest();  		
	}
	
	static testMethod void updCaseInternal() {
        setUpdata();
       
        Test.startTest();  
            
			ApexPages.currentPage().getParameters().put('Id', cs.Id); 
			CaseCloudDeplProdSelection contr = new CaseCloudDeplProdSelection(null);	
			contr.contactId = testContact.Id;	
			contr.cs.Cloud_Deployment__c = depl.Id;
			contr.cs.Cloud_Service__c = prod.Id;
            contr.initRecTypeUpd(cs.Id, rectpcld.Id);
            List<SelectOption> ctg = contr.categories;
		    contr.onchangeCategory();
			contr.saveCaseUpdates();
		Test.stopTest();  
	}
	
	static testMethod void newPureCnct() {
        setUpdata();
       
        depl.Cloud_Platform__c = 'PureConnect Cloud';
        update depl;
        
        Test.startTest();  
            
			ApexPages.currentPage().getParameters().put('Id', cs.Id); 
			ApexPages.currentPage().getParameters().put('fltr', 'cnct');
			CaseCloudDeplProdSelection contr = new CaseCloudDeplProdSelection(null);	
			contr.contactId = testContact.Id;	
			contr.cs.Cloud_Deployment__c = depl.Id;
			contr.cs.Cloud_Service__c = prod.Id;
            contr.initRecTypeUpd(cs.Id, rectpcld.Id);
            contr.resetCldDepoyment();
			contr.saveCaseUpdates();
		Test.stopTest();  
	}
	
	static testMethod void newPureUpd() {
        setUpdata();
       
        depl.Cloud_Platform__c = 'PureConnect Cloud';
        update depl;
        
        Test.startTest();  
            
			ApexPages.currentPage().getParameters().put('Id', cs.Id); 
			ApexPages.currentPage().getParameters().put('RecordType', rectpcld.Id);
			ApexPages.currentPage().getParameters().put('fltr', 'cnct');
			ApexPages.currentPage().getParameters().put('updRecTp', '1');
			CaseCloudDeplProdSelection contr = new CaseCloudDeplProdSelection(null);	
			contr.contactId = testContact.Id;	
			contr.cs.Cloud_Deployment__c = depl.Id;
			contr.cs.Cloud_Service__c = prod.Id;
			contr.PatchRelease = '12';
            contr.initRecTypeUpd(cs.Id, rectpcld.Id);
            contr.resetCldDepoyment();
            List<SelectOption> ctg = contr.categories;
		     contr.onchangeCategory();
			contr.saveCaseUpdates();
		Test.stopTest();  
	}
	
	
	
	
	
	
	
	
	
	
	
	
}