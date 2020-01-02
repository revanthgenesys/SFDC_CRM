/*
 * Class Name  	:  CBInvoicePDFExtensionController
 * Description 	:  This Class is used to Handle the Invoice and Send to Specific PDF format based on Order's Offering Type.
 * Test Class  	:  CloudInvoiceComponentControllerTest
 * Util Classes	:  
 * Created By  	:  Vijay Gopi.
 */
public class CBInvoicePDFExtensionController {
	
    public Invoice__c objInvoice {get; set;}
    
    
    public CBInvoicePDFExtensionController(ApexPages.StandardController controller){
        objInvoice = (Invoice__c)controller.getRecord();
        
        fetchPDFByOfferingType();
    }
    
    public void fetchPDFByOfferingType(){
        objInvoice = [SELECT Id , Order__r.Offering_Type__c, Order__r.Sales_Org__c  FROM Invoice__c WHERE Id = :objInvoice.Id];
        
    }
    
}