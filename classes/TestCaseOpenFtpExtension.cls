@isTest (seeAllData = true)
private class TestCaseOpenFtpExtension {
 
	static testMethod void testOpenFtp() {
 
        Case cs = createtestCase();	
			    
			Test.SetCurrentPageReference(New PageReference('/' + cs.Id));	
			ApexPages.Standardcontroller stcontr = New ApexPages.StandardController(cs);			
			CaseOpenGSFTPExtension openFtp = new CaseOpenGSFTPExtension(stcontr);
							
	   Test.startTest();
	   		Test.setMock(WebServiceMock.class, new FtpTestWebServiceMockCreateFolder());
			openFtp.genUrl();
	    Test.stopTest();
		   
	}
	
	static testMethod void testCaseClosedOpenFtp() {
 
        Case cs = createtestCase();	       
        cs.Status = 'Closed';
        cs.Sub_Status__c = 'Resolved';
        cs.Closure_Reason_Code__c = 'Customer requested to Close';
        cs.Closure_Category__c = 'Customer Closure';
        update cs;
	    
	    Test.SetCurrentPageReference(New PageReference('/CaseDetail' + cs.Id));
	    CaseDetailController casedet = new CaseDetailController();	
		CaseOpenGSFTPExtension openFtp = new CaseOpenGSFTPExtension (casedet);		
			
	    Test.startTest();		
	   		Test.setMock(WebServiceMock.class, new FtpTestWebServiceMockCreateFolder());
			openFtp.genUrl();				     
	   Test.stopTest();	  	   
       System.assertNotEquals(null, openFtp.msg);
	}
	
	static testMethod void testOpenFtpWS() {
 
        Case cs = createtestCase();	
         
	    Test.startTest();		   	
	       Test.setMock(WebServiceMock.class, new FtpTestWebServiceMockCreateFolder());	       
		   String ret = CaseOpenGSFTPExtension.genUrl(cs.id);			     
	   Test.stopTest();
	   //System.assertEquals('apex/CaseFtpError', ret);
	   
	}
 
	static testMethod void testGenTempAccount() {

	    Case cs = createtestCase();	
        
        Test.SetCurrentPageReference(New PageReference('/apex/CaseTempFtpGSaccount?id=' + cs.Id));
		ApexPages.Standardcontroller stcontr = New ApexPages.StandardController(cs);	
					
	    Test.startTest();
		    FtpGStempAccountManager acctMgr = new FtpGStempAccountManager(stcontr);
		    Test.setMock(WebServiceMock.class, new FtpTestWebServiceMockCreTmpAcct());
	        acctMgr.generateSFTPaccnt(); 

            /// errors
            FtpGStempAccountManager acctMgr1 = new FtpGStempAccountManager(null); 
            acctMgr1.generateSFTPaccnt(); 
            acctMgr1.disableSFTPaccnt();	        
	    Test.stopTest();
	              	       
	}
	
	static testMethod void testDisableTempAccount() {
 		Case cs = createtestCase();	
 		cs.Temp_SFTP_Account_Expiration_Date__c = System.now().addDays(2);
 		cs.Temp_SFTP_Password__c = 'pw';
 		cs.Temp_SFTP_Account_Name__c = 'acc';
        update cs;
                 
        Test.SetCurrentPageReference(New PageReference('/apex/CaseTempFtpGSaccount?id=' + cs.Id));
		ApexPages.Standardcontroller stcontr = New ApexPages.StandardController(cs);	
							
	    Test.startTest();
		    FtpGStempAccountManager acctMgr = new FtpGStempAccountManager(stcontr);
		    Test.setMock(WebServiceMock.class, new FtpTestWebServiceMockDeactTmpAcct());
	        acctMgr.disableSFTPaccnt();          

	    Test.stopTest();
	        
	}
	
	static Case createtestCase() {
		List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            //TestUtil.setConfigValues();
            //TestUtil.setCaseSupportTypesSettings();
        
        } 
        List<Account> acct = TestUtil.createAccounts(1, true);
		acct[0].SAP_Account_Code__c ='000001';
		update acct[0];
					
		Case cs = new Case(status='Open',subject='test', priority = 'Prod Down',
                            recordtypeid= Global_Setting__c.getInstance('Genesys_Product_Case').ID__c, 
                            Sold_To_Account__c = acct[0].Id,
                            End_User_Account__c = acct[0].Id); 
		insert cs;
		
		//GScape_FTP_Settings__c expset = new GScape_FTP_Settings__c(Name = 'TempAccountExpirationDays',
        //                                                           NumValue__c = 5);          
        //insert expset;   
		return cs;
	}
}