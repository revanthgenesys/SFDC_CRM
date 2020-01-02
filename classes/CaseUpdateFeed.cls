public with sharing class CaseUpdateFeed {
    //private case ca;
    public Genesys_Case_Updates__c genCaseUp {get;set;}
    public Id caseId{get;set;}
    public boolean insFailed {get;set;}
    public Boolean doRender {get;set;}
    public CaseUpdateFeed(ApexPages.StandardController stdController) {
        //this.ca = (Case)stdController.getRecord();
        genCaseUp = new Genesys_Case_Updates__c();
        caseId = stdController.getId();
        genCaseUp.Case__c =caseId;
        doRender = false;
    }
    
    public Pagereference saveCaseUpdate(){
        /*if(genCaseUp.Name == null || genCaseUp.Name == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Subject is required.');
            ApexPages.addMessage(myMsg);
            insFailed = true;
            return null;
        }
        insFailed = false;*/
        upsert  genCaseUp;
        if(genCaseUp.Make_Public__c){
            Case existingCase = new Case(id = genCaseUp.Case__c);
            existingCase.Last_Public_Case_Update_Description__c = genCaseUp.Description__c;         
            if(genCaseUp.Type__c != null && genCaseUp.Type__c.contains('PS Update'))
                existingCase.Last_Public_Customer_Update__c = System.now();
            else
                existingCase.Last_Public_Care_Update__c = System.now();
            update existingCase;                    
        }
        doRender = true;
        return null;
    }
}