@isTest
public class BatchToVerifyBackOffAcctFields_Test {
	
	static testMethod void boaFields1() {
		   Util.Bypass_Trigger_Chk = true;
		
	        Account accnt = TestUtil.createAccounts(1, true)[0];
	
			Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = accnt.Id;
			boa.End_User_Account__c = accnt.Id;
	 
	        List<Back_Office_Account__c> boaLst = new List<Back_Office_Account__c>();
	        boaLst.add(boa);
	        
	        insert boa;
	        
	        Test.StartTest();
		        BatchToVerifyBackOfficeAccountFields batch = new BatchToVerifyBackOfficeAccountFields();
				Database.executeBatch(batch);
			Test.StopTest();        
	}
	
	static testMethod void boaFields2() {
	
	        TestUtil.setConfigValues();
	        
	        ServiceContract servCon = TestUtil.createServiceContracts(1, false)[0];
		    Account accnt = TestUtil.createAccounts(1, true)[0];
		
	        servCon.Sold_To_Name__c = accnt.Id;
			servCon.End_User_Name__c = accnt.Id;
			servCon.Agreement_Status__c = 'Active';
		
		    //trigger on Service Contract should insert Back Office Account
			insert servCon;
			
			List<Back_Office_Account__c> boaLst = [SELECT Id, Contract_Status__c FROM Back_Office_Account__c];
			if ( !boaLst.isEmpty() ) {
	        
	            boaLst[0].Contract_Status__c = 'Closed';
	            boaLst[0].Sold_To_Name__c = null;
	            boaLst[0].End_User_Name__c = null;
	            update boaLst[0];
	            
		        Test.StartTest();
			        BatchToVerifyBackOfficeAccountFields batch = new BatchToVerifyBackOfficeAccountFields();
					Database.executeBatch(batch);
				Test.StopTest();   
			}     
	}
	
	public static String CRON_EXP = '0 0 0 15 3 ? 2025';
	static testMethod void testSchedulable() {		
		String jobId = System.schedule('ScheduleClassTest',
                        CRON_EXP, 
                        new BatchToVerifyBackOffAcctFieldSchedulable());
                        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         				          NextFireTime
         				  FROM CronTrigger WHERE id = :jobId];
		
	}
	
}