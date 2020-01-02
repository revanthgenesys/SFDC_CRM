@isTest
public class InvoiceButtonEntentionControllerTest {

    @testSetup
    public static void invoiceButtonEntentionControllerTestSetup() {
        BatchInvoicePDFAttachTest.setUpData();
    }
    
    @isTest
    static void testButtonExtentionController() {
        Invoice__c objInvoice = [SELECT Id FROM Invoice__c LIMIT 1];
        
        ApexPages.currentPage().getParameters().put('id', objInvoice.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objInvoice);
        InvoiceButtonEntentionController objController = new InvoiceButtonEntentionController(stdController);
        objController.generateInvoicePDF();
        objController.generateInvoiceExcel();
        objController.sendInvoice();
    }
}