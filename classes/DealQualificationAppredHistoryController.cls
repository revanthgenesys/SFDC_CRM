//Naresh Kumar
public with sharing class DealQualificationAppredHistoryController {
    public String oppId {get;set;}
    public String pricingType {get;set;}
    public String platformType {get;set;}
    public String offeringType {get;set;}
    public String dealscoredq {get;set;}
    public DealQualificationAppredHistoryController(){
        
    }
    
    public Deal_Qualification__c getDQApprovedHistory(){
        List<Deal_Qualification__c> dqHistory = DealQualificationApprovalUtil.getDQHistory(oppId, pricingType, platformType, offeringType);
        if(!dqHistory.isEmpty())
            return dqHistory[0];
        else{
            Deal_Qualification__c dq = new Deal_Qualification__c();
            return dq;
        }
       return null;
    }

}