@isTest
private class BatchDeleteExpiredSupportAccess_Test {
	
	static testMethod void deleteSuppAccessTest() {}
/*		
	  User user = TestUtil.createUsers(1, false)[0];
	   user.Bypass_Triggers__c = true;
	   user.BypassApexTriggers__c = 'AP01; AP02; AP03; AP04; AP05; BA001; OFFER01; OQM01; PRM01; PRM03; PRM04; PRM05; TM01; TM02; TM03';
	   user.BypassValidationRules__c = true;
	   user.BypassWorkflows__c = true;
	   user.EmployeeNumber = 'EMP-'+ Math.random().format();
	   insert user;
		
	 System.runAs(user) {
	 	
	   TestUtil.setConfigValues();
	   List<ServiceContract> scs1 = new List<ServiceContract>();
       for( Integer x=0; x< 100; x++ ) {
            ServiceContract sc = new ServiceContract();
            sc.Agreement_Status__c = 'Closed';
            sc.StartDate = Date.parse('12/01/2011');
            sc.EndDate = Date.parse('12/01/2012');
            sc.Name = 'Conract' + String.valueOf(x);  
            scs1.add(sc);
        }
        insert scs1;
        
        List<ServiceContract> scs2 = new List<ServiceContract>();
        for( Integer x=0; x< 50; x++ ) {
            ServiceContract sc = new ServiceContract();
            sc.Agreement_Status__c = 'Active';
            sc.StartDate = Date.parse('12/01/2011');
            sc.EndDate = Date.parse('12/01/2012');
            sc.Name = 'Conract' + String.valueOf(x);  
            scs2.add(sc);
        }
        insert scs2;
        
       List<ServiceContract> scs3 = new List<ServiceContract>();
        for( Integer x=0; x< 50; x++ ) {
            ServiceContract sc = new ServiceContract();
            sc.Agreement_Status__c = 'Closed';
            sc.StartDate = Date.parse('12/01/2013');
            sc.EndDate = Date.parse('12/01/2025');
            sc.Name = 'Conract' + String.valueOf(x);  
            scs3.add(sc);
        }
        insert scs3;

        Account account = new Account( Name='Acc', Status__c = 'Active' );            
        insert account;
       
       Contact cont = new Contact(LastName = 'TestContact', Email = 'test@genesys.com', accountId = account.id, FirstName = 'Test');
       insert cont;
        
       List<Support_Access__c> supaccs1 = new List<Support_Access__c>();
        for( Integer x=0; x< 100; x++ ) {
            Support_Access__c sa = new Support_Access__c();
            sa.Contact__c = cont.Id;
            sa.Service_Contract__c = scs1[x].Id;
            supaccs1.add(sa);
        }
       insert supaccs1;
       
       List<Support_Access__c> supaccs2 = new List<Support_Access__c>();
        for( Integer x=0; x< 50; x++ ) {
            Support_Access__c sa = new Support_Access__c();
            sa.Contact__c = cont.Id;
            sa.Service_Contract__c = scs2[x].Id;
            supaccs2.add(sa);
        }
       insert supaccs2;
       
       List<Support_Access__c> supaccs3 = new List<Support_Access__c>();
        for( Integer x=0; x< 50; x++ ) {
            Support_Access__c sa = new Support_Access__c();
            sa.Contact__c = cont.Id;
            sa.Service_Contract__c = scs3[x].Id;
            supaccs3.add(sa);
        }
       insert supaccs3;
		
	   Integer totalnum = [SELECT count() From Support_Access__c];
		                      
       System.assertEquals(totalnum, 200, 'Error in setting up test data, method deleteAll');
         
	   Test.startTest();
	    BatchDeleteExpiredSupportAccess del = new BatchDeleteExpiredSupportAccess();	
		Database.executeBatch(del);
	   Test.stopTest();
 
	    Integer numAfterDelete = [SELECT count() From Support_Access__c];
		                      
       System.assertEquals(numAfterDelete, 100, 'Failed method deleteAll');
       
	 }  
   }
   
   static testMethod void deleteSuppAccessTestException() {
   	  Test.startTest();
	    BatchDeleteExpiredSupportAccess del = new BatchDeleteExpiredSupportAccess();	
	    BatchDeleteExpiredSupportAccess.TEST_EXECUTION_EXCEPTION = true;	    
		Database.executeBatch(del);
	  Test.stopTest();
   	   
   }
 */
 }