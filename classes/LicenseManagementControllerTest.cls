@isTest(seeAllData=true)
public class LicenseManagementControllerTest {
    @isTest
    static void testLicenseManagementController1(){
    	LicenseManagementController lmController = new LicenseManagementController();
    	lmController.tabClicked();
    	lmController.accountSelection.AccountId = [SELECT id FROM Account WHERE Name = 'Avtex' AND RecordType.Name = 'Enterprise - Business Partner' LIMIT 1].Id;
    	lmController.goClicked();
    }

    @isTest
    static void testLicenseManagementController2(){
    	List<Support_Access__c> supportAccessCustomer = [SELECT id, Name, Contact__c, End_User_Account__c FROM Support_Access__c WHERE 
    																End_User_Account__r.ININ_ID__c != NULL
    																AND End_User_Account__r.Type = 'Customer'
    																AND Back_Office_Account__r.Approval_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Contract_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Platform__c = 'PureConnect On Premise' LIMIT 2];
    	if(supportAccessCustomer.size() > 0 ){
			User u1 = [SELECT id FROM User WHERE ContactId = :supportAccessCustomer[0].Contact__c];
			
    		System.runAs(u1){
		    	LicenseManagementController lmController = new LicenseManagementController();
		    	lmController.tabClicked();
		    	lmController.accountSelection.AccountId = supportAccessCustomer[0].End_User_Account__c;
		    	lmController.goClicked();
		    	List<SelectOption> endUserAccounts = lmController.getEndUserAccounts();
    		}	
		}
    }
    
    @isTest
    static void testLicenseManagementController3(){
    	List<Support_Access__c> supportAccessPartner = [SELECT id, Name, Contact__c, End_User_Account__c FROM Support_Access__c WHERE 
    																End_User_Account__r.ININ_ID__c != NULL
    																AND End_User_Account__r.RecordType.Name = 'Enterprise - Business Partner'
    																AND Back_Office_Account__r.Approval_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Contract_Status__c = 'Active' 
																 	AND Back_Office_Account__r.Platform__c = 'PureConnect On Premise' 
																 	AND End_User_Account__r.Name = 'Avtex' LIMIT 2];
    	if(supportAccessPartner.size() > 0 ){
			User u1 = [SELECT id FROM User WHERE ContactId = :supportAccessPartner[0].Contact__c];
			
    		System.runAs(u1){
		    	LicenseManagementController lmController = new LicenseManagementController();
		    	lmController.tabClicked();
		    	lmController.selectedEndUserAccountId = supportAccessPartner[0].End_User_Account__c;
		    	lmController.accountSelection.AccountId = supportAccessPartner[0].End_User_Account__c;
		    	lmController.goClicked();
		    	List<SelectOption> endUserAccounts = lmController.getEndUserAccounts();
    		}	
		}
    }
    
}