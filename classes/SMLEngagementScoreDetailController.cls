//Naresh Kumar 11/10/2015
public class SMLEngagementScoreDetailController{
    public SML_Account_Engagement_Score__c score {get;set;}
    public List<Account_Trends__c> accountTrends {get;set;}
    public List<SML_Account_Engagement_Score_History__c> scoreHistory {get;set;}
    public String accountId;
    public SMLEngagementScoreDetailController(ApexPages.StandardController sc){
         accountId = sc.getId();
         init();
    }
    
    private void init(){
        score = [SELECT Account__c, Account__r.Name, Score__c FROM SML_Account_Engagement_Score__c WHERE Account__c =: accountId LIMIT 1];

        accountTrends = [SELECT id, New_Status__c, Comments__c, CreatedDate, CreatedBy.Name, SML_Data__r.Solution_Category__r.Name FROM Account_Trends__c 
            WHERE SML_Data__r.Account__c =: accountId ORDER BY CreatedDate DESC LIMIT 10];
        scoreHistory = [SELECT id, CreatedDate, CreatedBy.Name, Old_Score__c, New_Score__c 
            FROM SML_Account_Engagement_Score_History__c WHERE SML_Account_Engagement_Score__c =: score.id ORDER BY CreatedDate DESC]; 
    }    
}