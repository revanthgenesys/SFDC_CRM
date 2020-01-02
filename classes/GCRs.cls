/*
    Naresh Kumar
    09/18/2013
*/
public without sharing class GCRs {
    public List<GCR__c> gcrs {get;set;}
    public GCR__c newGCR {get;set;}
    public String selectedView {get;set;}
    public List<SelectOption> options {get;set;}
    public Boolean showResult {get;set;}
    public String accName {get;set;}
    private String recordTypeId;
    public String selectedRecordType {get;set;}
    public List<SelectOption> recordTypesItems {get;set;}
    public String pageType {get;set;}
    private Boolean isWarning;
    public GCRs(ApexPages.StandardController std){
        pageType = 'newGCR';
        newGCR = new GCR__c();
        accName = ApexPages.currentPage().getParameters().get('accName');        
        recordTypeId = ApexPages.currentPage().getParameters().get('recordTypeId');
        if(recordTypeId == null){
            pageType = 'recordTypeSelection';
            recordTypesItems = new List<SelectOption>();
            List<RecordType> recordTypes = [SELECT id, Name FROM RecordType WHERE SObjectType = 'GCR__c'];
            recordTypesItems.add(new SelectOption('','--Select--'));
            for(RecordType eachRT : recordTypes){
                SelectOption item = new SelectOption(eachRT.id, eachRT.Name);
                recordTypesItems.add(item);
            }
        }
    }
    
    public GCRs(){
        options = new List<SelectOption>();
        SelectOption newOption = new SelectOption('All', 'My All Requests');
        options.add(newOption);
        newOption = new SelectOption('New', 'My New Requests');
        options.add(newOption);
        newOption = new SelectOption('Open', 'My Open Requests');
        options.add(newOption);
        newOption = new SelectOption('Closed', 'My Closed Requests');
        options.add(newOption);
        selectedView = 'All';
        showResult = true;
        loadRecords();
    }
    
    public void loadRecords(){      
        if(selectedView == 'All')
            gcrs = [SELECT Name, Priority__c, /*Synopsis__c, Description__c,*/ CreatedDate, Status__c, Assigned_to_Attorney__c FROM GCR__c 
                WHERE CreatedById =: UserInfo.getUserId() ORDER BY Name];
        else
            gcrs = [SELECT Name, Priority__c, /*Synopsis__c, Description__c, */CreatedDate, Status__c, Assigned_to_Attorney__c FROM GCR__c 
                WHERE CreatedById =: UserInfo.getUserId() AND Status__c =: selectedView ORDER BY Name];
                
        if(gcrs.size() == 0)
            showResult = false;
        else
            showResult = true;
    }
    
    public pageReference save(){
        newGCR.Requester__c = newGCR.CreatedById;
        if(recordTypeId == null){
            RecordType rType = [SELECT id FROM RecordType WHERE SObjectType = 'GCR__c' AND DeveloperName = 'Purchasing'];
            recordTypeId = rType.id;
            /*
            if(newGCR.PR_Netsuite_Number__c == null && isWarning == null){
                String msg = 'If your agreement involves the payment of fees to any third party, you must obtain a Purchase Requisition number from the Purchasing department that serves your region or organization.';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, msg);
                isWarning = true;
                return null;
            }
            */
        }
        newGCR.recordTypeId = recordTypeId;
        newGCR.Status__c = 'Request Submmited';
        insert newGCR;
        PageReference pRef = new PageReference('/' + newGCR.id);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public pageReference cancel(){
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pRef = new PageReference(retURL);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public pageReference next(){
        if(selectedRecordType == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a request type.');
            return null;
        }
        Schema.DescribeSObjectResult r = GCR__c.sObjectType.getDescribe();
        String objPrefix = r.getKeyPrefix();
        PageReference pRef = new PageReference('/' + objPrefix + '/e?nooverride=1&RecordType=' + selectedRecordType);
        return pRef;
    }

}