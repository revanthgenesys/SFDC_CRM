@isTest(SeeAllData=true)
private class CPRControllerTest {
	
    static testmethod void testCPRController(){
        List<Account> accounts = [SELECT Id FROM Account WHERE (Name = 'ADP (Automatic Data Processing)' OR Name = 'ANZ Bank' ) AND Status__c = 'Active'];
        Test.startTest();
        Test.setCurrentPage(Page.CPR);
		ApexPages.currentPage().getParameters().put('cprFrom', 'account');
		ApexPages.currentPage().getParameters().put('accid', accounts[0].Id);
		CPRController cpr = new CPRController();
        cpr.loadCPRComments();
		cpr.saveComments();       
        List<CPRController.CPRWrapper> cprItems = cpr.cprItems;
        if(!cprItems.isEmpty()){
            Integer currentEntitlements = cprItems[0].currentEntitlements;
            Integer transferred = cprItems[0].getTransferredFinal();
        }
        Test.stopTest();
 	}
	
     static testmethod void testCPRForSplit(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c = 'Split' LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            Test.stopTest();
         }
     }
     static testmethod void testCPRForDropDownsize(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c IN ('Drop', 'Downsize') LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            Test.stopTest();
         }
     }
     static testmethod void testCPRForRetired(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c = 'Retired' LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            Test.stopTest();
         }
     }
     static testmethod void testCPRForShelved(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c = 'Shelved' LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            Test.stopTest();
         }
     }
     static testmethod void testCPRForPendingInNegotiation(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c IN ('In Negotiation', 'Pending') LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            Test.stopTest();
         }
     }
    
     static testmethod void testCPRForPureEngage(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c = 'Active' AND isPureEngagePrem__c = true LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('platformType', 'PureEngage');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            cpr.loadCPRComments();
            Test.stopTest();
         }
     }
     static testmethod void testCPRForPureConnect(){
         List<ContractLineItem> cliList = [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Servicecontract.Agreement_Status__c = 'Active' AND isPureConnectPrem__c = true LIMIT 2];
         if(!cliList.isEmpty()){
            Test.startTest();
            Test.setCurrentPage(Page.CPR);
            ApexPages.currentPage().getParameters().put('cprFrom', 'account');
            ApexPages.currentPage().getParameters().put('platformType', 'PureConnect');
            ApexPages.currentPage().getParameters().put('accid', cliList[0].ServiceContract.End_User_Name__c);
            CPRController cpr = new CPRController();
            cpr.loadCPRComments();
            cpr.mergeCPRWrappers(cpr.cprItems[0],cpr.cprItems[0]);
            Test.stopTest();
         }
     }
		
	    
}