/*
Case Relationship
04/10/2013    Naresh Kumar    Original for Task/Story #   
Description : Custom controller for the VF Case Relationship
*/
public without sharing class CaseRelationshipController{   
    //public List<caseRelationshipWrapper> relationList {get;set;}
    public List<Related_Case__c> caseRelationships {get;set;}
    public Boolean renderPageBlock {get;set;}
    String caseId;
    public String selectedRelationId {get;set;}
    public Case parentCase {get;set;}
    public String returnURL {get;set;}
    public CaseRelationshipController(ApexPages.StandardController stdController){
        caseId = stdController.getId();   
        renderPageBlock = true;
        returnURL = '';        
        if(caseId == null){
            renderPageBlock = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Required parameter is missing so can not render the page.');
            ApexPages.addMessage(errorMessage);
        }
        parentCase = [Select CaseNumber From Case where id =: caseId limit 1];
        loadRecords();
    }
    
    private void loadRecords(){
        caseRelationships = [Select id, Parent_Case__r.CaseNumber, Parent_Case__r.Description, Parent_Case__r.Subject, Parent_Case__r.recordtype.name,
            Case__r.CaseNumber, Case__r.Description, Case__r.Subject, Case__r.recordtype.name,Note__c from Related_Case__c 
            where Parent_Case__c =: caseId or Case__c =: caseId ];            
        if(caseRelationships.isEmpty()){
            renderPageBlock = false;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'No relationship available.');
            ApexPages.addMessage(errorMessage);
        }
    }
    
    public void add(){
        string objPrefix = Related_Case__c.sObjectType.getDescribe().getKeyPrefix();
        string url = '/' + objPrefix + '/e?retURL=/apex/Case_Relationships?id=' + caseId + '&' + Label.Related_Case_Field_Id + '=' + parentCase.CaseNumber;
        returnURL = url; 
        //PageReference pf = new PageReference(url);
        //pf.setRedirect(true);
        //return pf; 
    }
    
    public pageReference back(){
        return new PageReference('/' + caseId);    
    }
     
    public void deleteRelationship(){
        Related_Case__c frr = new Related_Case__c(id = selectedRelationId);
        try{
        delete frr;
        }
        catch(Exception ex){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is some error on the page. Info = '+ex.getMessage());
            ApexPages.addMessage(errorMessage);
        }
        loadRecords();
    }    
}