public class LicenseEmailReassign {
    
    public String lrId {get; set;}  
    public String targetId {get; set;}
    public String targetName {get; set;}
    public License_Request__c lrc {get; set;}
    public Boolean completed {get; set;}
    
    public LicenseEmailReassign (ApexPages.StandardController stdController) {
         lrId = stdController.getId();
         this.lrc = (License_Request__c)stdController.getRecord(); 
         lrc.Related_License_Requests__c = null; /// using this field for VF page only to collect input, discurd value before saving the record
         completed = false;                             
    }
            
    public PageReference saveUpdates() {
        targetId = lrc.Related_License_Requests__c;
        if ( lrId == null ) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, 'Error processing the request.');
            ApexPages.addMessage(errorMessage);
            return null;
        }
        
        try {

            List<EmailMessage> msglst = [SELECT Id, Related_Activation_Request__c
	                                     FROM EmailMessage WHERE relatedToId = :lrId];
  
            if ( !msglst.isEmpty() ) {
               for (EmailMessage msg : msglst) {         	
                   msg.Related_Activation_Request__c = lrc.Related_License_Requests__c;
                   update msg;                  
               }
            }  

        }
        catch (Exception ex)  {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errorMessage);
            return null;
        }
        
        /// Close source License Request
        try {
            License_Request__c sLr = new License_Request__c (id = lrId, Status__c = 'Closed', 
                                                              Sub_Status__c = 'Linked', Related_License_Requests__c = null);  
            update sLr;
        }
        catch (Exception ex)  {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
            ApexPages.addMessage(errorMessage);         
            return null;
        }
        
        completed = true;
        
System.debug('*** targetId ' + targetId);        
System.debug('**** String.isNotBlank(targetId) ' + String.isNotBlank(targetId));
        
        if ( String.isNotBlank(targetId) )  {
            List<License_Request__c> trglst = [SELECT Name FROM License_Request__c WHERE Id = :targetId];
            if ( !trglst.isEmpty() )
               targetName = trglst[0].Name;
        }
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Communications have been linked to ' + targetName);
        ApexPages.addMessage(msg);
        
        return null;
    }

}