@isTest
private class BoaRelatedCasesController_Test {
	
	 static testMethod void relCases() {
	    Util.Bypass_Trigger_Chk = true; 
	                        
        Account accnt = TestUtil.createAccounts(1, true)[0];
        Case cs = TestUtil.createCases(1, true)[0];
        cs.Sold_To_Account__c = accnt.Id;
        cs.End_User_Account__c = accnt.Id;
	    update cs;
	    
	    Back_Office_Account__c boa = new Back_Office_Account__c();
		boa.Contract_Status__c = 'Active';
	   	boa.Service_Type__c = 'Premise';
	   	boa.Approval_Status__c = 'Active';
	   	boa.Sold_To_Account__c = accnt.id;
	   	boa.End_User_Account__c = accnt.id;
	   	boa.Unique_STEU__c = accnt.id + '_' + accnt.id ;
	   	boa.End_User_Name__c = accnt.Name;
	   	boa.Sold_To_Name__c = accnt.Name;
        insert boa;
        
        Test.startTest(); 
        
        ApexPages.StandardController stc = new ApexPages.StandardController(boa);
		BoaRelatedCasesController boaCon = new BoaRelatedCasesController(stc);
		boaCon.getNonClosedRelCases();
		boaCon.getClosedRelCases();
                
        Test.stopTest(); 
	    
	 }
}