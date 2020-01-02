public with sharing class TechTutorialsForm {
public String inputText1{get;set;}
public void submitSuggestion() { 	
    PKB_Article_Feedback_Deflection__c afd = new PKB_Article_Feedback_Deflection__c(

      Feedback_Source__c = 'TutorialsPage',
      Comments__c = inputText1
    );
    try{
        afd.OwnerId = [SELECT Id,Name FROM Group WHERE Name ='Feedback' and Type = 'Queue' limit 1].Id;
    }catch(Exception e){

    }
    insert afd;
  }
}