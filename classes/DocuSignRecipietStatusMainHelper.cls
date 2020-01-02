//Naresh Kumar  01/06/2015
public class DocuSignRecipietStatusMainHelper {

    public static void updateGCRStatus(List<dsfs__DocuSign_Recipient_Status__c> newList, Map<Id, dsfs__DocuSign_Recipient_Status__c> oldMap) {
        dsfs__DocuSign_Recipient_Status__c recipientStatus = newList[0];
        if(recipientStatus.dsfs__Date_Signed__c != oldMap.get(recipientStatus.id).dsfs__Date_Signed__c){
            List<dsfs__DocuSign_Recipient_Status__c> recipientStatusRefresh = [SELECT dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__c,
            	dsfs__Parent_Status_Record__r.GCR_Content_Document__c, dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c 
            	FROM dsfs__DocuSign_Recipient_Status__c WHERE id =: recipientStatus.id];
            GCR__c gcrToBeUpdated = new GCR__c(id = recipientStatusRefresh[0].dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__c);
            GCR_Content_Document_Detail__c gcrContentDocumentDetail = [SELECT Customer_Signed__c FROM GCR_Content_Document_Detail__c
            	WHERE id =: recipientStatusRefresh[0].dsfs__Parent_Status_Record__r.GCR_Content_Document__c LIMIT 1];
            if(recipientStatus.dsfs__DocuSign_Recipient_Email__c != null 
                && recipientStatus.dsfs__DocuSign_Recipient_Email__c.contains('@genesys.com')){
                if(gcrContentDocumentDetail.Customer_Signed__c)
                	gcrToBeUpdated.Status__c = GCRContentDocumentDetailsContHelper.GCR_STATUS_COMPLETED;
                else
                	gcrToBeUpdated.Status__c = GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS;    
            }
            else if(recipientStatus.dsfs__DocuSign_Recipient_Email__c != null 
                && !recipientStatus.dsfs__DocuSign_Recipient_Email__c.contains('@genesys.com')){
                if(recipientStatusRefresh[0].dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c != 'Completed')
                gcrToBeUpdated.Status__c = GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_CUSTOMER;
            }   
            if(gcrToBeUpdated.id != null && gcrToBeUpdated.Status__c != null)        
                update gcrToBeUpdated;          
        }    
    }
}