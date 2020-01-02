public class SurveyDisplay  {
private final Account acc;

public SurveyDisplay (ApexPages.StandardController stdController) {
 this.acc= (Account)stdController.getRecord();
}

public List<Survey_Response__c> getSurvey() {

    List<Survey_Response__c> survey  = new List<Survey_Response__c>();
    String acntID_18 = acc.id;
    String acntID = acntID_18.Substring(0,acntID_18.length()-3);
    survey =  [select id,Name,nps_rating__c,Case__r.CaseNumber,Contact__r.Name,Survey_Type__c,
                        Response_Type_2__c, Deployment_Type1__c, CreatedDate, Dept__c,Product_Offering__c 
             from Survey_Response__c 
             where (Account__c =:acc.iD OR Sold_To_Account__c =:acntID OR End_User_Id__c =:acntID) Order BY CreatedDate DESC];
    
    if(survey.isEmpty())
      return null;
    else
      return survey;
}
}