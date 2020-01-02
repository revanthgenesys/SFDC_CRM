@isTest
public class BoaDuplicateReportController_Test {
    
    static testMethod void dupReportTest () {
	
	     Util.Bypass_Trigger_Chk = true;    
        List<Account> testAccounts = TestUtil.createAccounts(2, true);
  
        Account accnt1 = testAccounts[0];
        Account accnt2 = testAccounts[1];
 
		Back_Office_Account__c boa1 = new Back_Office_Account__c();
		boa1.Contract_Status__c = 'Active';
	   	boa1.Service_Type__c = 'Premise';
	   	boa1.Approval_Status__c = 'Active';
	   	boa1.Sold_To_Account__c = accnt1.id;
	   	boa1.End_User_Account__c = accnt1.id;
	   	boa1.Unique_STEU__c = accnt1.id + '_' + accnt1.id ;
        insert boa1;
        
        Back_Office_Account__c boa2 = new Back_Office_Account__c();
		boa2.Contract_Status__c = 'Active';
	   	boa2.Service_Type__c = 'Premise';
	   	boa2.Approval_Status__c = 'Active';
	   	boa2.Sold_To_Account__c = accnt1.id;
	   	boa2.End_User_Account__c = accnt1.id;
	   	boa2.Unique_STEU__c = accnt2.id + '_' + accnt2.id ;
        insert boa2;
        
        Test.startTest();  
    	BoaDuplicateReportController repContrl = new BoaDuplicateReportController();
        Test.stopTest();     
    
    } 
}