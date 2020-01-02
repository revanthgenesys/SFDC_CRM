@isTest
public class CaseChangeRecordTypeController_Test {
	static Contact testContact;
	static Case cscld;
	static Case csprm;
	static Account testAccount;
	static Support_Product__c prod;
	static Cloud_Deployment__c depl;
	static List<RecordType> rectpPrm;
	static List<RecordType> rectpCld;
	
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
	   	depl.Cloud_Platform__c = 'Premier Edition';
        insert depl;
        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.Id, Cloud_Deployment__c = depl.Id, Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
        
        Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    insert boa;
	    boa.Contract_Status__c = 'Active';
	    update boa;

        Support_Access__c sap = new Support_Access__c(Back_Office_Account__c = boa.Id, SR_Access_Level__c = 'Read/Write',
                                                      Status__c = 'Active', Contact__c = testContact.id);
        insert sap;
   
        rectpCld = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Service_Request'];
        rectpPrm = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Product_Case'];
        
        csprm = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectpPrm[0].id, Support_Product__c = prod.Id);                        
        insert csprm;
        csprm.Cloud_Deployment__c = depl.Id;
        update csprm;
        
        cscld = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectpCld[0].id, Cloud_Service__c = prod.Id);                        
        insert cscld;
         
	}
	
	
	static testMethod void tstCldtoCld() {
		setUpdata();
	
		Test.startTest(); 		
		ApexPages.currentPage().getParameters().put('id', cscld.Id);
		CaseChangeRecordTypeController contr = new CaseChangeRecordTypeController(null);
		contr.selectedRecTypeId = rectpCld[0].Id;		
		String btn = contr.btnLabel;
		contr.nextPage();	
		contr.setCaseSubTypes();
		contr.gotoCldPage();
		contr.gotoPremPage();
		contr.setTargetType();
		contr.saveCase();
		Test.stopTest();			
	}
}