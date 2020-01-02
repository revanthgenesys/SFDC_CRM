public class dqSpecOfferSubApprCentralCtrl {
    
    public list<Deal_Qualification__c> allDQSpecOfferSubAppr{get;set;}
    //public list<Quote_Approval__c> allDQSpecOfferSubAppr{get;set;}

    public dqSpecOfferSubApprCentralCtrl(){
        allDQSpecOfferSubAppr = new list<Deal_Qualification__c>();
        fetchallDQSpecOfferSubAppr();
    }
    
    public void fetchallDQSpecOfferSubAppr(){

			allDQSpecOfferSubAppr = [Select Id,Name,Req_Credit_Collections_approval__c,Req_Legal_approval__c,Req_Order_Mgmt_Billing_approval__c,Req_Revenue_Approval__c,
			                        Credit_and_Collections_approval__c,Credit_Collections_Comments__c,Legal_approval__c,Legal_Comments__c,Order_Mgmt_Billing_approval__c,
			                        Order_Management_Billing_Comments__c,Revenue_approval__c,Revenue_Comments__c,opportunity__r.Country_Region__c from Deal_Qualification__c
			                        where Status__c=:DealQualificationApprovalUtil.QUOTE_STATUS_PENDING
			                        AND (Req_Revenue_Approval__c = true OR Req_Order_Mgmt_Billing_approval__c = true
			                            OR Req_Legal_approval__c = true OR Req_Credit_Collections_approval__c = true)];
			                            
			system.debug('allDQSpecOfferSubAppr--->'+allDQSpecOfferSubAppr.size());

    }
    
}