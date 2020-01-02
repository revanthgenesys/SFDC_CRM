/*
Class Name = CCDBRelatedLisControllerTest
Purpose = Test class for CCDBRelatedLisController
Developed By = Sushen Adhikary
Developed Date = 20-Dec-2019
Modified By = Sushen Adhikary
Modified Date = 20-Dec-2019
*/
@isTest
private class CCDBRelatedLisControllerTest{

    static testMethod void testCCDBRelatedListLogic()
	{
          
		Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User();
		u.Username = 'test999@genesys.com';    
		u.LastName= 'Test';
		u.FirstName= 'Test';
		u.Email= 'ddd@genesys.com';
		u.CommunityNickname= 'uuu';
		u.Alias= 'uuuu';
		u.TimeZoneSidKey='Europe/Paris';  
		u.LocaleSidKey='fr_FR_EURO';
		u.EmailEncodingKey='ISO-8859-1';     
		u.ProfileId = prof.Id;           
		u.LanguageLocaleKey='fr';
		u.isActive=true;
		u.ByPassValidationRules__c = true;
		u.EmployeeNumber = '99999';
		INSERT u;
	  
		System.runAs(u) {
			//Insert Account record
			Account acc = new Account( Name='Test Account', Status__c = 'Active' );            
			INSERT acc;
			
			//Set the current page
			PageReference myVfPage = Page.PartnerPortalAcctDetail;
			Test.setCurrentPage(myVfPage);

			// Put Id into the current page Parameters
			ApexPages.currentPage().getParameters().put('id', acc.Id);
			
			Test.StartTest();
			
			ApexPages.StandardController sc = new ApexPages.StandardController(acc);
			CCDBRelatedLisController objCon = new CCDBRelatedLisController(sc);
			
			System.assertEquals('Test Account', acc.Name);
			
			Test.StopTest();

        }
    }
}