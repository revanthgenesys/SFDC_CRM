public class InvoiceButtonEntentionController {
    public Invoice__c objInvoice {get; private set;}

    //CTORs
    public InvoiceButtonEntentionController(ApexPages.StandardController stdController) {
        System.debug('enter with Standard Controller');
        Id idInvoice = stdController.getRecord().id;
        objInvoice = getInvoice(idInvoice);
    }
/*
    public InvoiceButtonEntentionController(id idInvoice) {
        System.debug('enter with Manual call');
        objInvoice = getInvoice(idInvoice);
    }
*/
	// Methods
    private Invoice__c getInvoice(id idInvoice) {
        Invoice__c objInvoice = [
            select
            Id,
            Order__r.Offering_Type__c,
            Invoice_Number__c,
            Status__c,
            (SELECT Id FROM Attachments)
            from Invoice__c where id = :idInvoice
        ];
        System.debug('Got invoice ' + objInvoice);
        return objInvoice;
    }

    public PageReference generateInvoicePDF() {
        String strURL = '/apex/CloudInvoicePdf?scontrolCaching=1&id=' + objInvoice.Id;
        System.Debug('Trying Page: ' + strURL);
        PageReference objPageReference = new PageReference(strURL);
        return objPageReference;
    }

    public PageReference generateInvoiceExcel() {
        String strURL = '/apex/CloudInvoiceExcel?scontrolCaching=1&id=' + objInvoice.Id;
        System.Debug('Trying Page: ' + strURL);
        PageReference objPageReference = new PageReference(strURL);
        return objPageReference;
    }

    public PageReference sendInvoice() {
        
        objInvoice.Status__c = 'Send Email';
        update objInvoice;

        String strURL = '/' + objInvoice.Id;
        PageReference objPageReference = new PageReference(strURL);//ApexPages.currentPage();
        objPageReference.setRedirect(false);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Emailing invoice.'));
        return objPageReference;
    }
}