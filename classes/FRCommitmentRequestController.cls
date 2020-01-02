public without sharing class FRCommitmentRequestController {

    public String presentState {get; set;}
    private ID commId; 
    private FR_Commitment__c comm;

    public FRCommitmentRequestController (ApexPages.StandardController stdController) {
        commId = stdController.getId();
   
        if ( String.isNotBlank(commId) ) {
        	
           List<FR_Commitment__c> commlst = [SELECT Commitment_Progress__c FROM FR_Commitment__c WHERE Id = :commId];
           comm = commlst[0];
           presentState = comm.Commitment_Progress__c;    
        }   
    }
 
    public PageReference withdraw() {
    	comm.Commitment_Progress__c = 'Withdrawn';
    	update comm;
    	return new PageReference('/' + commId);
    }
}