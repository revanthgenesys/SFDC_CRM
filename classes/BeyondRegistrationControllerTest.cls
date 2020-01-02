/*
	Naresh Kumar	06/17/2013
	Test class for the main controller class CaseDetailController.
*/
@isTest
private class BeyondRegistrationControllerTest {
	
    static testMethod void myUnitTest() {
    	
        TestUtil.setConfigValues();   	
    	List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {      		
       		TestUtil.setCaseSupportTypesSettings();
        }
    	
        RegistrationController objController = new RegistrationController();
        List<SelectOption> items;
        
        objController.email = 'test@test.com';
        items = objController.stateProvince;
        items = objController.countries;
        items = objController.getTimeZone();
        objController.firstName = 'Test';
        objController.lastName = 'Test';
        objController.businessPhone = '8888888888';
        objController.companyname = 'Test';

        objController.save();
        
        Contact con = objController.checkifContactExits();
        if (con != null)
          objController.createCase(con);
          
        objController.save();
                
    }
    
     static testMethod void tstContact() {
        Util.Bypass_Trigger_Chk = true;
    	
        BeyondRegistrationController cont = new BeyondRegistrationController();
         
        List<SelectOption> items;
         
        items = cont.stateProvince;
        items = cont.countries;
        items = cont.getTimeZone();
        
        cont.email = 'test@test.com';
        cont.firstName  = 'firstName';
        cont.lastName   = 'lastName';
        cont.businessPhone = '8888888888';
        cont.companyname = 'Test';
        
        Contact ct = cont.createContact();
        
        cont.createCase(ct);
        cont.save();
    }
}