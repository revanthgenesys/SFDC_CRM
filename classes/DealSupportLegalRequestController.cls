//Naresh Kumar  01/02/2015
public with sharing class DealSupportLegalRequestController {
    public String oppId {get;set;}
    public String accId {get;set;}
    public List<GCR__c> gcrs {get;set;}
    public Boolean showGrid {get;set;}
    public String gcrPageParams {get;set;}
    public DealSupportLegalRequestController(){
        oppId = Apexpages.currentPage().getParameters().get('oppId');
        accId = Apexpages.currentPage().getParameters().get('accId');
        showGrid = false;
        gcrPageParams = '';
        populateGCRs();
    }
    
    private void populateGCRs(){
        if(oppId != null){
            gcrs = [SELECT Name, Contract_Type__c, Synopsis__c, Status__c, CreatedDate FROM GCR__c WHERE Opportunity__c =: oppId order by createddate desc];
            gcrPageParams = '&oppId='+ oppId;
        }
        else if(accId != null){
            gcrs = [SELECT Name, Contract_Type__c, Synopsis__c, Status__c, CreatedDate FROM GCR__c WHERE Account__c =: accId order by createddate desc];
            gcrPageParams = '&accId='+ accId;
        }
        else
            gcrs = [SELECT Name, Contract_Type__c, Synopsis__c, Status__c, CreatedDate FROM GCR__c WHERE CreatedById =: UserInfo.getUserId()  order by createddate desc];
        if(!gcrs.isEmpty()){
            showGrid = true;
        }       
    }
}