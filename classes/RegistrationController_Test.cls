/*
	Naresh Kumar	06/17/2013
	Test class for the main controller class CaseDetailController.
*/
@isTest
private class RegistrationController_Test {
	
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
        List<SelectOption> items = objController.prefContactMethod;
        objController.email = 'test@test.com';
        items = objController.salutations;
        items = objController.stateProvince;
        items = objController.countries;
        //objController.getTypes();
        //items = objController.isUserEmailValid;
        List<SelectOption> selop = objController.accessTypes;
        List<SelectOption> lang = objController.language;
        objController.save();
        objController.cancel();
        
        Contact con = objController.checkifContactExits();
        if (con != null)
          objController.createCase(con);
          
        objController.submit();
                
    }
    
     static testMethod void tstContact() {
    	        
        Util.Bypass_Trigger_Chk = true;
    	
        RegistrationController cont = new RegistrationController();
        List<SelectOption> items = cont.prefContactMethod;
        cont.email = 'test@test.com';
        items = cont.salutations;
        items = cont.stateProvince;
        items = cont.countries;
        
        List<SelectOption> selop = cont.accessTypes;
        List<SelectOption> lang = cont.language;
        
        cont.email = 'test@test.com';
        cont.FirstName  = 'firstName';
        cont.LastName   = 'lastName';
        cont.addrLine1  = 'addrLine1';
        cont.addrLine2   = 'addrLine2';
        cont.zipPostalCode   = '94024';
        cont.city           = 'city';
        
        Contact ct = cont.createContact();
        
        cont.createCase(ct);
        
        cont.vaidateChallenge();
        cont.submit();
                         
    }
}