@isTest
public class CaseSaveController_Test {
	static Contact testContact;
	static User testUser;
	static Case cs;
	static Account testAccount;
	static Cloud_Deployment__c depl;
	static Back_Office_Account__c boa;
	static Support_Product__c prod;
	static Support_Product__c comp;
	
	static void setUpdata() {
	  Util.Bypass_Trigger_Chk = true;
		
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];  
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
    	boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    boa.Platform__c = 'PureConnect On Premise';
	    boa.Support_Package__c = 'Managed Services';
	    boa.Contract_Status__c = 'Active';
	    insert boa;
	     boa.Contract_Status__c = 'Active';
	     update boa;
    	
    	depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Cloud_Platform__c = 'PureCloud';
        insert depl;
    	
    	prod = new Support_Product__c (name='Product', Product_Type__c = 'Product');
        insert prod;
        comp = new Support_Product__c (name='Product', Product_Type__c = 'Component', Parent_Product__c = prod.Id);
        insert comp;
        
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
	}
		
	static testMethod void newCaseInternal() {
		setUpdata();
		
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_case'];
        
        Test.startTest(); 
		ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
		ApexPages.currentPage().getParameters().put('contId', testContact.Id); 
	    ApexPages.currentPage().getParameters().put('stId', testAccount.Id);
        ApexPages.currentPage().getParameters().put('euId', testAccount.Id);  
        
         ApexPages.currentPage().getParameters().put('pltf', 'cnct');
            ApexPages.currentPage().getParameters().put('boaId', boa.Id);                                                         
            ApexPages.currentPage().getParameters().put('prdId', prod.id); 
            ApexPages.currentPage().getParameters().put('compId', comp.id);         
            ApexPages.currentPage().getParameters().put('rel', '12');               
            ApexPages.currentPage().getParameters().put('ver', '34'); 
            ApexPages.currentPage().getParameters().put('prb', 'prob');
                
        CaseSaveController contr = new CaseSaveController(null);
        contr.saveCase();
        String tl = contr.pageTitle;
        Test.stopTest(); 
	}
	
	static testMethod void newCasePortal() {
		setUpdata();
		
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Support_Request'];
        
        Test.startTest(); 
        System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
			ApexPages.currentPage().getParameters().put('contId', testContact.Id); 
		    ApexPages.currentPage().getParameters().put('stId', testAccount.Id);
	        ApexPages.currentPage().getParameters().put('euId', testAccount.Id); 
	        
	         ApexPages.currentPage().getParameters().put('pltf', 'cnct');
            ApexPages.currentPage().getParameters().put('boaId', boa.Id);                                                         
            ApexPages.currentPage().getParameters().put('prdId', prod.id); 
            ApexPages.currentPage().getParameters().put('compId', comp.id);         
            ApexPages.currentPage().getParameters().put('rel', '12');               
            ApexPages.currentPage().getParameters().put('ver', '34'); 
            ApexPages.currentPage().getParameters().put('prb', 'prob');
                 
	        CaseSaveController contr = new CaseSaveController(null);
	        contr.saveCase();
        }
         Test.stopTest(); 
	}
	
	static testMethod void newCasePortal2() {
		setUpdata();
		
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        
        Test.startTest(); 
        System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('RecordType', rectp[0].Id); 
			ApexPages.currentPage().getParameters().put('contId', testContact.Id); 
		    ApexPages.currentPage().getParameters().put('stId', testAccount.Id);
	        ApexPages.currentPage().getParameters().put('euId', testAccount.Id);  
	     
	        ApexPages.currentPage().getParameters().put('pltf', 'cnct');
            ApexPages.currentPage().getParameters().put('boaId', boa.Id);                                                         
            ApexPages.currentPage().getParameters().put('prdId', prod.id); 
            ApexPages.currentPage().getParameters().put('compId', comp.id);         
            ApexPages.currentPage().getParameters().put('rel', '12');               
            ApexPages.currentPage().getParameters().put('ver', '34'); 
            ApexPages.currentPage().getParameters().put('prb', 'prob');
                
	        CaseSaveController contr = new CaseSaveController(null);
	        contr.saveCase();
        }
         Test.stopTest(); 
	}
	
	static testMethod void testCaseInsUpdTrigger() {
		 setUpdata();
	     Util.Bypass_Trigger_Chk = false;
	     
		 List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
		 Case cs = new Case(RecordTypeId=rectp[0].Id, Subject= 'Subj', Description='Descr', ContactId= testContact.Id);
		 insert cs;
		 
		 cs.Description = 'update';
		 update cs;
		
	}

}