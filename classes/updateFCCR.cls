public class updateFCCR implements Queueable {
    private Set<Id> oppIds;
    
    public updateFCCR(Set<Id> oppIds) {
        this.oppIds = oppIds;
    }
    public void execute(QueueableContext context) {
        List<FR_Commitment__c> FCCRListUpd = new List<FR_Commitment__c>();     
        for (FR_Commitment__c FCCR : [select Commitment_Progress__c,Assigned_To__r.Id from FR_Commitment__c where (Commitment_Progress__c = 'New' OR Commitment_Progress__c = 'Under Evaluation' OR  Commitment_Progress__c = 'Accepted') AND Opportunity__r.Id in :oppIds]) {
            FCCR.Commitment_Progress__c = 'Lost Opportunity';
            FCCRListUpd.add(FCCR);
        }
        update FCCRListUpd;
/*        for(FR_Commitment__c FCCR:FCCRListUpd){
            SendEmail.SendEmailByTemplate(FCCR.Assigned_To__r.Id,'FCCR Commitment Stage Lost Update',FCCR.Id);
        }*/

    }
}