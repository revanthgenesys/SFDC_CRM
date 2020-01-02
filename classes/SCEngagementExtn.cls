public class SCEngagementExtn {
private final Opportunity opp;

 
public List<Wow_Request_Form__c> SCList{ get; set; }
public string SelectedOppLineId { get; set; }
public Boolean isRenewalOppy {get;set;} 
public SCEngagementExtn(ApexPages.StandardController stdController) {
    this.opp= (Opportunity )stdController.getRecord();
    SCList =[SELECT Wow_URL__c, CreatedDate, WoW_Status__c, Primary_Business_Objectives__c,PS_transition__c,(select id,Virtual_User__c,Virtual_User_type__c from WoW_Virtual_Users__r) FROM Wow_Request_Form__c WHERE Opportunity_Id__c =: opp.Id];
    }
}