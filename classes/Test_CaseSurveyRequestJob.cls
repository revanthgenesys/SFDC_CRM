@isTest 
private class Test_CaseSurveyRequestJob {
	
	static testmethod void tesCaseSurvey() {
		
        Util.Bypass_Trigger_Chk = true;   
       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = new Contact(LastName = 'TestContact', Email ='test@tst.com', accountId = testAccount.id, FirstName = 'Test');
    	insert testContact;
    	      
        List<RecordType> rtId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Genesys_Product_Case' AND  SobjectType = 'Case'];
        List<Case> cs = new List<Case>();
        Case cs1 = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rtId[0].id);                        
        insert cs1;
        cs.add(cs1);
	    
	    Util.Bypass_Trigger_Chk = false;
	    
	    System.Test.startTest();  
	    	       
	    cs[0].Status = 'Closed';
	    cs[0].Sub_Status__c = 'Resolved';
	    cs[0].Closure_Category__c='Other';
	    cs[0].Closure_Reason_Code__c='Other';
	    update cs[0];
	
	     
	     Map<Id, Case> csMap = new Map<Id, Case>(cs);
	     
	     SoundBite sb = new SoundBite();
	     sb.submit();
	     
	    SoundBite.callSoundBite( SoundBite.prepareJSON(cs[0]) );
	    SoundBite.sendInfoToSoundBite(cs, csMap);
	      
        Database.executeBatch( new CaseSurveyRequestJob() ); 
        
        /// duplicate
         Database.executeBatch( new CaseSurveyRequestJob() ); 
  
	    System.Test.stopTest();   
	           	     
	}
}