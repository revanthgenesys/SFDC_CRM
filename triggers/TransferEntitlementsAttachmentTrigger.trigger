trigger TransferEntitlementsAttachmentTrigger on Attachment (after insert) {
  //Bypass Trigger added by Rsystems - Priyank line number 3.
    if(Util.Bypass_Trigger_Chk)return;
  
    Set<String> transferEntitlementsIds = new Set<String>();
    Set<String> soldToTransferRequestHeaderIds = new Set<String>();
    for(Attachment att : trigger.New){
         //Check if added attachment is related to TransferEntitlements
         if(att.ParentId.getSobjectType() == Transfer_Tool_Approval__c.SobjectType){
              transferEntitlementsIds.add(att.ParentId);
         }
         //Check if added attachment is related to TransferEntitlements
         if(att.ParentId.getSobjectType() == Sold_To_Transfer_Request_Header__c.SobjectType){
              soldToTransferRequestHeaderIds.add(att.ParentId);
         }
    }
    
    if(transferEntitlementsIds.size() > 0){
        List<Transfer_Tool_Approval__c> transferEntitlementsList = new List<Transfer_Tool_Approval__c>();
        for(String s : transferEntitlementsIds){
          transferEntitlementsList.add(new Transfer_Tool_Approval__c(Id = s, Attachments_Linked__c = true));  
        }
        update transferEntitlementsList;
    } 
    
    if(soldToTransferRequestHeaderIds.size() > 0){
        List<Sold_To_Transfer_Request_Header__c> soldToTransferRequestHeadersList = new List<Sold_To_Transfer_Request_Header__c>();
        for(String s : soldToTransferRequestHeaderIds){
          soldToTransferRequestHeadersList.add(new Sold_To_Transfer_Request_Header__c(Id = s, Attachments_Linked__c = true));  
        }
        update soldToTransferRequestHeadersList;
    }
}