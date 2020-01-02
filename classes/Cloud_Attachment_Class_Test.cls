//Naresh 	07/30/2017	
@isTest
private class Cloud_Attachment_Class_Test {
	
    static testMethod void testMethod1(){        
        Account testAccount = TestUtil.createAccounts(1, true)[0];        
        ApexPages.currentPage().getParameters().put('id', testAccount.id);
        cloud_attachment_class objController = new cloud_attachment_class(new ApexPages.StandardController(testAccount));
        objController.getAtmtList();
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        ApexPages.currentPage().getParameters().put('id', testOpp.id);
        objController = new cloud_attachment_class(new ApexPages.StandardController(testAccount));
        
        Case testCase = TestUtil.createCases(1, true)[0];
        ApexPages.currentPage().getParameters().put('id', testCase.id);
        objController = new cloud_attachment_class(new ApexPages.StandardController(testAccount));
        
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        ApexPages.currentPage().getParameters().put('id', testContact.id);
        objController = new cloud_attachment_class(new ApexPages.StandardController(testAccount));
        
        Lead testLead = new Lead(LastName = 'Test', Company = 'TestCompany');
        insert testLead;
        ApexPages.currentPage().getParameters().put('id', testLead.id);
        objController = new cloud_attachment_class(new ApexPages.StandardController(testAccount));        
    }
    
    @testSetup static void testSetup(){
        TestUtil.setConfigValues();  
    }
}