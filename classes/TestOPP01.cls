@isTest
private class TestOPP01 {

    static testMethod void TestStatusGetRefused() {
    User use1 = TestCommon.createUser('testtet', 'test.test@emg.alcatel-lucent.com.emgdev', 'MyTestLastName','MyTestFirstName',Config.PROFIL_ADMIN_ID);
    User use2 = TestCommon.createUser('testhli', 'h.lahmadi@emg.alcatel-lucent.com.emgdev', 'MyLastName','MyFirstName',Config.PROFIL_ADMIN_ID);
   
	Account acc = TestCommon.createAccount(true);
	//myAccountBP1.OwnerId = use1.Id;
	
	Opportunity opp;
	
	
	 System.RunAs(use1) {
	 opp = new Opportunity(
							name='Opp_AlcatelTriggerTest', //mandatory
							stageName='Open', //mandatory
							CloseDate=Date.newInstance(2006,10,10),//mandatory
							AccountId = acc.Id,
							WonLostCancelledReason__c = 'Best Practice' , 
							Competitor__c = '3COM',
							OpportunityBPStatus__c = Config.CORE_OPP_BP_STATUS_ALLOCATED										
							);
	 insert opp;
	 opp.OwnerId = use1.Id;
	 update opp;
	 	
	 }
	 System.RunAs(use2) {
	 	
     Util.myLog('Start Test');  
	 Test.startTest();
	  opp.Opportunity_Sales_Status__c = Config.EMG_STATUS_GET_REJECTED;
	  update opp;		
	 Test.stopTest();
	 Util.myLog('End Test');
	 
	Opportunity oppTestChangeOwner = [Select Id, OwnerId, X1stOwnerId__c
                   					       from Opportunity 
                   					       where Id=:opp.id 
                   					       limit 1];                         	
                   					   
	//System.assertEquals(oppTestChangeOwner.OwnerId, oppTestChangeOwner.X1stOwnerId__c);	
	 }
    }
   }