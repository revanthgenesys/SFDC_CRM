//Naresh Kumar  09/22/2015
@isTest (seeAllData=true)
private class CloudBilling_Test 
{
    static testMethod void AttachInvoicePDFService()
    {
        
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Order__c testOrder = TestUtil.createOrders(1, false)[0];
        testOrder.End_User_Name__c = testAccount.id;
        insert testOrder;
        Invoice__c testInvoice = new Invoice__c();      
        testInvoice.Order__c = testOrder.id;
        insert testInvoice;
        
        insert (new Rolled_Up_Usage_Data__c());
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '<a target="_blank" href="https://na14.salesforce.com/services/apexrest/v.9/member/me/results/today;" rel="nofollow">https://na14.salesforce.com/services/apexrest/v.9/member/me/results/today;</a>/' + testInvoice.id; 
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        AttachInvoicePDFService.attachPDFtoInvoiceREST();
        AttachInvoicePDFService.attachPdfToInvoice(testInvoice.id, '');
    }
}