public without sharing class PartnerSignatureController {
    public List<dsfs__DocuSign_Recipient_Status__c> pendingSignatureList{get; set;}
    public List<dsfs__DocuSign_Recipient_Status__c> completedSignatureList{get; set;}
    
    public PartnerSignatureController()
    { 
        checkSignatures();      
    }
    public void checkSignatures(){
        pendingSignatureList = new List<dsfs__DocuSign_Recipient_Status__c>();
        completedSignatureList = new List<dsfs__DocuSign_Recipient_Status__c>(); 
        List<dsfs__DocuSign_Recipient_Status__c> dsRecipientStatus = [SELECT Name,dsfs__DocuSign_Recipient_Id__c, dsfs__Date_Sent__c,dsfs__Date_Signed__c,dsfs__Parent_Status_Record__r.dsfs__Sender__c,
                                                                      dsfs__Parent_Status_Record__r.dsfs__Subject__c,dsfs__Recipient_Status__c,dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c
                                                                      FROM dsfs__DocuSign_Recipient_Status__c 
                                                                      WHERE dsfs__DocuSign_Recipient_Email__c =: UserInfo.getUserEmail()];
        
        system.debug('dsRecipientStatus size :'+dsRecipientStatus.size());
        system.debug('dsRecipientStatus size :'+dsRecipientStatus);
        for(dsfs__DocuSign_Recipient_Status__c ds : dsRecipientStatus) {
            System.debug('ds-dsfs__Parent_Status_Record__r-->'+ds.dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c);
            System.debug('ds dsfs__Recipient_Status__c-->'+ds.dsfs__Recipient_Status__c);
            if(ds.dsfs__Recipient_Status__c != 'Completed' &&  ds.dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c != 'Completed') {
                pendingSignatureList.add(ds);    
            }
            else if(ds.dsfs__Recipient_Status__c == 'Completed') {
                completedSignatureList.add(ds);   
            }
        }
        System.debug('pendingSignatureList-->'+pendingSignatureList);
        System.debug('completedSignatureList-->'+completedSignatureList);
      }
    
}