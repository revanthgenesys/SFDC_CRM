@isTest
private class AccountHierarchy_Test {
	
	  static testMethod void myUnitTest() {
	  	
    	Account testAccount = TestUtil.createAccounts(1, false)[0];   		
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
    	  
        AccountHierarchy ahContr = new AccountHierarchy(stdController);
               
        Boolean grScct = ahContr.isGroupAccount; 
        ahContr.getRelAccounts();
        
	  }
}