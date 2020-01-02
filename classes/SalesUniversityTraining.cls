public with sharing class SalesUniversityTraining {

    public List<Sales_University_Training__c> getUnivTraining(){
        
        return [SELECT Id,Course_Name__c,Due_Date__c,Transcript_Status__c,LOID__c
                 FROM Sales_University_Training__c WHERE User__c =: UserInfo.getUserId() and Transcript_Status__c in ('Registered','In Progress','Registered / Past Due','Pending Prerequisite')];
    }
}