@isTest
public class LicenseRequestWebFormController_Test {
	
	static testmethod void tstLisReq() {
		TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;
		
		Country__c us = new Country__c(Name = 'United States', Country__c = 'United States');
		insert us;
		
		Licensing_Analyst__c la = new Licensing_Analyst__c(APAC_Analyst_UserId__c = UserInfo.getUserId());
		insert la;
		
		List<RecordType> rectp = [SELECT Id FROM RecordType WHERE DeveloperName = 'EMGCustomerRecordType'];
		List<Account> acnt=  TestUtil.createAccounts(1, false);
        acnt[0].name='new test accountt';
        acnt[0].SAP_Account_Code__c = '1234';
        acnt[0].Country__c = us.id;
        acnt[0].Status__c = 'Active';
        acnt[0].RecordTypeId = rectp[0].id;
        insert acnt;
        
		Test.startTest();		
		ApexPages.currentPage().getParameters().put('fnm', 'fst');
		ApexPages.currentPage().getParameters().put('lst', 'lst');
		ApexPages.currentPage().getParameters().put('em', 'em@em.com');
		ApexPages.currentPage().getParameters().put('eusr', 'endusr');
		ApexPages.currentPage().getParameters().put('empl', 'employer');
		ApexPages.currentPage().getParameters().put('garn', '1234');
		ApexPages.currentPage().getParameters().put('src', 'internal');
		ApexPages.currentPage().getParameters().put('reqtp', 'AFR');
		
	    LicenseRequestWebFormController cntr = new LicenseRequestWebFormController(null);
	    
	    cntr.submitRequest();
	    
	    cntr.licReq.Request_Type__c = 'Question';
	    cntr.selectedGenImplType = 'GenImpl';
	    cntr.selectedGenDeplType = 'GenDepl';
	    cntr.selectedImplType = 'Impl';
	    cntr.selectedDeplType = 'Depl';
	    
	    cntr.resetFileType();
	    List<SelectOption> impl = cntr.implOptions;
	    List<SelectOption> depl = cntr.deplOptions;
	    
	    cntr.attName = 'Attachment';
	    cntr.upload();
	    cntr.submitRequest();
	    	    
	    List<Attachment> alst = cntr.attachmList;
	    
	    cntr.startNewReq();
	    cntr.newReqInternal();	
	    Test.stopTest();	
	}
    
}