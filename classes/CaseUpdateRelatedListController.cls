/*
  Naresh Kumar
  05/15/2013
  Suman 10/09/13 Query and order by last modified date for case updates 
*/
public without sharing class CaseUpdateRelatedListController {
  String caseId {get;set;}
  public String selectedCUId {get;set;}
  public transient List<Genesys_Case_Updates__c> caseUpdates{get;set;}//ST 08/22/13 added transient to reduce viewstate
  public boolean caseClose {get;set;}
  public Case currentCase {get;set;}
  public String caseNumberField {get;set;}
  public String caseUpdatePrivateRecordTypeId {get;set;}
  public Boolean isReadOnlyProfile {get;set;}
  public Boolean isCaseAccessReadOnly {get; set; }
  
  public CaseUpdateRelatedListController(ApexPages.StandardController stdController){

/*remove after 4/12
 if ( ContactUtil.isSBContact() )  {	
  	  isReadOnlyProfile = true;
  	  isCaseAccessReadOnly = true;
 }
 else 
 ///end remove
*/
       isReadOnlyProfile = CaseUtil.isCurrentUserProfileReadOnly();
    
        caseId = stdController.getId();        
        currentCase = (Case)stdController.getRecord();        
        caseUpdates = new List<Genesys_Case_Updates__c>();
        caseNumberField = Label.Case_Update_CaseNumber_Field;
        RecordType rType = [SELECT id FROM RecordType WHERE DeveloperName = 'Private' AND SobjectType = 'Genesys_Case_Updates__c' LIMIT 1];
        caseUpdatePrivateRecordTypeId = rType.id;
        loadRecords();
        caseClosed();        
  }
  public CaseUpdateRelatedListController(){
    caseId = ApexPages.currentPage().getParameters().get('id');
    currentCase = [SELECT id, CaseNumber, Sold_To_Account__c, End_User_Account__c FROM Case WHERE id =: caseId];
    caseUpdates = new List<Genesys_Case_Updates__c>();        
        loadRecords();
        caseClosed(); 

/* remove after 4/12
 if ( ContactUtil.isSBContact() )  {	
  	  isReadOnlyProfile = true;
  	  isCaseAccessReadOnly = true;
 }
 else  {        
  ///end remove 
*/    
        isCaseAccessReadOnly = CaseUtil.isCaseAccessLevelReadOnly(currentCase);
        isReadOnlyProfile = CaseUtil.isCurrentUserProfileReadOnly();      
}
  
  public void caseClosed() {
    Case caseRecord = [Select id,Status from Case where id =:caseId];
    if(caseRecord != null && caseRecord.Status != null && caseRecord.Status =='Closed')
      caseClose = false; 
    else 
      caseClose = true;   
    
  }
  
  private void loadRecords(){    
    caseUpdates = [SELECT id, Name, Created_By_Name__c,Type__c, Status__c, Make_Public__c, Summary__c, CreatedDate, 
                          lastmodifieddate,Description__c,Posted_On_Calc__c
          FROM Genesys_Case_Updates__c WHERE Case__c =: caseId and Make_Public__c = true order by Posted_On_Calc__c desc ];
        System.debug('NKC debug caseUpdates ['+caseUpdates+']');
  }
  
  public void deleteCaseUpdate(){
        Genesys_Case_Updates__c gcu = new Genesys_Case_Updates__c(id = selectedCUId);
        try{
        delete gcu;
        }
        catch(Exception ex){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is some error on the page. Info = '+ex.getMessage());
            ApexPages.addMessage(errorMessage);
        }
        loadRecords();
    }
    
}