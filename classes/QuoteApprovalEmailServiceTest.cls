//Naresh Kumar
@IsTest(SeeAllData=true)
private class QuoteApprovalEmailServiceTest {
	static testMethod void myUnitTest1() {
		Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
    	testOpp.Quote_Category__c = 'Cloud';    	    	
        insert testOpp;
        testOpp = [SELECT Country_Sub_Region__c FROM Opportunity WHERE id =: testOpp.id];
        System.debug('NKC debug testOpp ['+testOpp.Country_Sub_Region__c+']');
        List<RecordType> rType = [SELECT id FROM RecordType WHERE SObjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote'];       
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.BigMachines__Status__c = 'In Progress';
        testQuote.Discount__c = 50;
        testQuote.Explanation_of_price_Discount_request__c = 'test';
        testQuote.Pricing_Model__c = 'Premier Edition';
        testQuote.RecordTypeId = rType[0].id;
        insert testQuote;
        User testUser = TestUtil.createUsers(1, true)[0];
        testQuote = [SELECT Name, Quote_Number__c FROM BigMachines__Quote__c WHERE id =: testQuote.id];
        testQuote.Name = testQuote.Quote_Number__c;
        update testQuote;		
        /*
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Request submitted for approval automatically.');
		req.setObjectId(testQuote.id);
		Approval.ProcessResult result = Approval.process(req);
		*/
		Messaging.inboundEmail email = new Messaging.inboundEmail();
		email.Subject = 'Opp Quote#' + testQuote.Quote_Number__c + ':';
		email.plainTextBody = 'Approve \n This is comment';
		email.fromAddress = testUser.Email;
		QuoteApprovalEmailService obj = new QuoteApprovalEmailService();
		obj.handleInboundEmail(email, null);
	}
	static testMethod void myUnitTest2() {
		Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
    	testOpp.Quote_Category__c = 'Cloud';    	    	
        insert testOpp;
        testOpp = [SELECT Country_Sub_Region__c FROM Opportunity WHERE id =: testOpp.id];
        System.debug('NKC debug testOpp ['+testOpp.Country_Sub_Region__c+']');
        List<RecordType> rType = [SELECT id FROM RecordType WHERE SObjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote'];       
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.BigMachines__Status__c = 'In Progress';
        testQuote.Discount__c = 50;
        testQuote.Explanation_of_price_Discount_request__c = 'test';
        testQuote.Pricing_Model__c = 'Business Edition';
        testQuote.RecordTypeId = rType[0].id;
        insert testQuote;
        User testUser = TestUtil.createUsers(1, true)[0];
        testQuote = [SELECT Name, Quote_Number__c FROM BigMachines__Quote__c WHERE id =: testQuote.id];
        testQuote.Name = testQuote.Quote_Number__c;
        update testQuote;	
         //Quote Approval
        Quote_Approval__c testQuoteApproval1 = new Quote_Approval__c(BigMachines_Quote__c = testQuote.id);
        testQuoteApproval1.Status__c = QuoteApprovalUtil.STATUS_PENDING;
        testQuoteApproval1.Approval_Submission_Counter__c = 1;
        testQuoteApproval1.Quote_Approval_Id__c = '111222333';
        insert testQuoteApproval1;	
        /*
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments('Request submitted for approval automatically.');
		req.setObjectId(testQuote.id);
		Approval.ProcessResult result = Approval.process(req);
		*/
		Messaging.inboundEmail email = new Messaging.inboundEmail();
		email.Subject = 'Opp Quote#' + testQuote.Quote_Number__c + ':';
		email.plainTextBody = 'Approve <br/> This is comment <br/><br/><br/><br/>';
		email.plainTextBody += 'ref:00511000001mihyAAA-'+ testQuoteApproval1.id +'-'+testQuote.id+':ref'; 
		email.fromAddress = testUser.Email;
		QuoteApprovalEmailServiceOnPremise objOnPremise = new QuoteApprovalEmailServiceOnPremise();
		objOnPremise.handleInboundEmail(email, null);
	}
}