public class CloudSubscriptionRenewalLogCreation{
    
    public static void SuccessLogCreation(Id IdSubId,Id IdOppId,Id IdQuoteId){
        Subscription_Renewal_Audit_Log__c objSuccessLog  =  new Subscription_Renewal_Audit_Log__c(Error_Message_Returned_by_the_System__c = '',Opportunity__c = IdOppId,Quote__c = IdQuoteId, Record_Created_By__c = userInfo.getUserID(),Record_Created_On__c = System.today(),	Record_Creation_Status__c = 'Success',Subscription__c = IdSubId	);
        insert objSuccessLog;
        
    }
    public static void FailureLogCreation(Id IdSubId,String strErrorMessage){
        Subscription_Renewal_Audit_Log__c objFailureLog  =  new Subscription_Renewal_Audit_Log__c(Error_Message_Returned_by_the_System__c = strErrorMessage,Record_Created_On__c = System.today(),Record_Created_By__c = userInfo.getUserID(),	Record_Creation_Status__c = 'Failed',Subscription__c = IdSubId	);
        insert objFailureLog;
        
    }
}