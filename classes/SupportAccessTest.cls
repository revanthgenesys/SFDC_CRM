//@isTest(seeAllData=true)
@isTest
private class SupportAccessTest {
	
	public static  User testUser;
    public static Contact testContact1;
    public static Account accnt;
	
	public static void setData() {
		 Util.Bypass_Trigger_Chk = true;
       
	    Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
	    accnt = TestUtil.createAccounts(1, true)[0];
	    testContact1 = TestUtil.createContacts(1, accnt, true)[0];
	    	
	    testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);    	
		testUser.ContactId = testContact1.id;
		testUser.isactive = true;
		insert testUser;

	    Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
	                                                             Support_Status__c = 'Active', Sold_To_Account__c = accnt.id);
	    insert cldDep;
	        
        Support_Access_Cloud__c sac = new Support_Access_Cloud__c (Contact__c = testContact1.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sac;
         
	}

    static testMethod void testSuppAccessController() { 
    	
    	 setData();

         System.runAs(testUser) {
          Test.startTest();
              
              ApexPages.currentPage().getParameters().put('euid', accnt.id);
              ApexPages.currentPage().getParameters().put('stid', accnt.id);
	          SupportAccesscController contr = new SupportAccesscController();
	          contr.ClearForm();
		      List<SelectOption> tp = contr.accessTypes;
		      contr.termsConditions = true;
	          contr.isMain = true;
	          contr.txtMsg = '';
	          contr.isEdit = true;
	           contr.readWriteOnly = false;
	          contr.readyOnly= false;
	          contr.descrip = '';
	          contr.euId = accnt.Id;
	          contr.stId = accnt.Id;
	          contr.stName = '';
	          contr.euName = '';
		      contr.requestedAccess = 'R/W';
		      contr.selectedCloud = true;
		      contr.selectedPrem = true;
		      contr.getSCforSTEU();
		      contr.SubmitForm();
		      contr.goBack();
	      Test.stopTest();
         }
    }
    
    static testMethod void suppUtil () {
    	 setData();
    	
    	Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = accnt.Id;
			boa.End_User_Account__c = accnt.Id;
	    insert boa;
			 
    	List<Support_Access__c> saLst = new List<Support_Access__c>();
		Support_Access__c sa = new Support_Access__c(Back_Office_Account__c = boa.Id,
			                                             Contact__c = testContact1.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read/Write');		                                             
		insert sa;   
    	
	    SupportAccessUtil.setSupportAccessFields( saLst );
	    
	     System.runAs(testUser) {
              
		    ApexPages.currentPage().getParameters().put('euid', accnt.id);
	        ApexPages.currentPage().getParameters().put('stid', accnt.id);
		    SupportAccesscController contr = new SupportAccesscController();
	     }
    }   
}