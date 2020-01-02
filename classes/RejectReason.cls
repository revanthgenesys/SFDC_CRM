public class RejectReason {
   
    public RejectReason(ApexPages.StandardController controller){
       
        Lead_Referral_Registration__c  rjreason =[SELECT ID,Rejection_Reason__c,Status__c FROM Lead_Referral_Registration__c WHERE ID=:controller.getId()];
        if(rjreason.Status__c == 'Rejected' && String.isBlank(rjreason.Rejection_Reason__c)){
           // system.debug('@@@@@@@@@@@@Rejected');
            showMessage();
        }
    }
   
    public void showMessage(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Please provide Rejection Reason'));     
    } 
}