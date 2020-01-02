//Naresh Kumar	04/07/2017
public without sharing class OpportunityPartnerButtons {
    // holds opportunity id
    public String strOppId {get; private set;}
    // holds opportunity record
    public Opportunity objOpp {get; private set;}
    public String strBaseURL {get; private set;}
    public OpportunityPartnerButtons(ApexPages.StandardController stdCtrl){
        // getting opportunity id
        strOppId = stdCtrl.getId();
        // getting opportunity record
        objOpp = [SELECT id, Partner_Opportunity_Status__c, Partner_Opportunity_Source__c FROM Opportunity WHERE id =: strOppId];
        strBaseURL = UserInfo.getUserType() == 'PowerPartner' ? '/partner' : '';   
    }
    
    public void submitForApproval(){
        objOpp.Partner_Opportunity_Status__c = 'Submitted';
        update objOpp;        
    }
}