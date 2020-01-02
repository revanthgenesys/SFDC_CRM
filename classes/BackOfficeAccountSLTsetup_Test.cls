@isTest
public class BackOfficeAccountSLTsetup_Test {
	
	static testMethod void tst() {
	
		Util.Bypass_Trigger_Chk = true;
		Account testAccount = TestUtil.createAccounts(1, true)[0];
		
		Util.Bypass_Trigger_Chk = true;
 
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testAccount.Status__c = 'Active';
    	testAccount.SAP_Account_Code__c ='111';
    	update testAccount;
   
        Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    boa.Support_Package__c = 'Managed Services';
	    boa.Contract_Status__c = 'Active';
	    insert boa;     
    	
        List<RecordType> recType = [SELECT Id FROM RecordType 
                            WHERE SobjectType = 'Service_Level_Target__c' AND DeveloperName = 'SLT_BOA_Definition'];
                                
        Service_Level_Target__c slt = new Service_Level_Target__c (RecordTypeId = recType[0].Id, BOA_Support_Package__c = 'Managed Services');
        insert slt;
        
        Test.startTest(); 
         ApexPages.StandardController sc = new ApexPages.StandardController(boa);
        BackOfficeAccountSLTsetup contr = new BackOfficeAccountSLTsetup(sc);
        
        contr.currentSltType =  'template';
        contr.addCustomSlt();
        contr.saveCustSlt();
         contr.currentSltType =  'custom';
        contr.removeCustomSlt();
        contr.editCustom();
        contr.actCancel();
        Test.stopTest(); 
        
	}
    
}