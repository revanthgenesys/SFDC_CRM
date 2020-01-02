// Rest Service to create and attach pdfs to invoice records from batch job
@RestResource(urlMapping='/AttachPDF/*')
global class AttachInvoicePDFService 
{
    // *** Rest Service which takes invoice id and generates and attached pdf to it ***
    @HttpGet
    global static void attachPDFtoInvoiceREST()
    {
        RestRequest req = RestContext.request;
        id recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        // Generating pdf using visualforce : passing invoice id to page
        PageReference pdfPage = new PageReference('/apex/CloudInvoicePdf');
        pdfPage.getParameters().put('id',recordId);
        List<Invoice__c> list_Invoice = [SELECT Id,Order__r.End_User_Name__r.Name,Order__r.Month__c,Order__r.Year__c FROM Invoice__c WHERE Id = :recordId];
        Attachment objPDF = new Attachment();
        
        if(!list_Invoice.isEmpty())
            objPDF.Name = list_Invoice[0].Order__r.End_User_Name__r.Name + '-' + list_Invoice[0].Order__r.Month__c + '-' + list_Invoice[0].Order__r.Year__c + '.pdf';
        else
            objPDF.Name = 'Invoice.pdf';
        
        objPDF.ParentId = recordId;
        if (Test.IsRunningTest())
        	objPDF.Body = Blob.valueOf('UNIT.TEST');
   		else
        	objPDF.Body = pdfPage.getContentAsPdf();
        objPDF.Description = 'Monthly Billing Sales Order';
        objPDF.ContentType  = 'application/pdf'; 
        // Insert pdf attachment        
        insert objPDF;
        // Update Invoice status to indicate that pdf has been attached
        update (new Invoice__c(Id = recordId,Status__c = 'Invoice Attached'));
    }
    
    // *** Calling rest Method : This method masks the call-out and provides an abstracted method to be called from the batch job or anywhere else ***
    global static void attachPdfToInvoice(Id recordId,String sessionId)
    {
        String addr = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/AttachPDF/' + recordId;
        HttpRequest req = new HttpRequest();
        req.setEndpoint( addr );
        req.setMethod('GET');
        req.setHeader('Authorization', 'OAuth ' + sessionId);
        Http http = new Http();
        if(!Test.IsRunningTest())
        	HttpResponse response = http.send(req);    
    }
}