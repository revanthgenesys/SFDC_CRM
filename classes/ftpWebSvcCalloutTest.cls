@isTest (seeAllData=true)
private class ftpWebSvcCalloutTest {
		    
   static testMethod void ftpSvcCalloutTest() { 
 
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new FtpTestWebServiceMock());
       
		Account n_st = new Account(Name ='myCompany1', SAP_Account_Code__c ='000001');
		insert n_st;
		
		Account n_eu = new Account(Name ='myCompany2', SAP_Account_Code__c ='000002');
		insert n_eu;
		
		Account o_st = new Account(Name ='myCompany3', SAP_Account_Code__c ='000003');
		insert o_st;
		
		Account o_eu = new Account(Name ='myCompany4', SAP_Account_Code__c ='000004');
		insert o_eu;

	    Test.setMock(WebServiceMock.class, new FtpTestWebServiceMock()); 
		//FutureCallOuts.callMoveFtpDir('001U000000Hks5I','1234', '001U000000Hks5I', 
		//                                '001U000000Hks5I', '001U000000Hks5I'); 
		FutureCallOuts.callMoveFtpDir(n_st.Id,'1234', n_eu.Id, o_st.Id, o_eu.Id); 
		                                  
    }
}