public class TransferEntitlementsAttMsgController {
    ApexPages.StandardController ttaController;
    String ttaId;
	public TransferEntitlementsAttMsgController(ApexPages.StandardController controller) {
        ttaController = controller;
        ttaId = ttaController.getId();
        
        Transfer_Tool_Approval__c tta = [SELECT id, Attachments_Linked__c from Transfer_Tool_Approval__c where id = :ttaId LIMIT 1];
        if(tta.Attachments_Linked__c == false){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'At least one attachment is required before submitting for Approval.'));
        }        
    }
}