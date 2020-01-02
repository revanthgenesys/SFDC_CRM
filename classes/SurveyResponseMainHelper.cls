//Naresh Kumar  07/08/2016
public without sharing class SurveyResponseMainHelper {

    public static void createNPSSurveyResponseRecord(Map<Id, Survey_Response__c> newMap){
        List<JBCXM__SurveyResponse__c> NPSSurveysToBeInserted = new List<JBCXM__SurveyResponse__c>();
        String year = String.valueOf(System.today().year());
        //Looping over each record and creating new NPS survey record.
        for(Survey_Response__c eachResponse : newMap.values()){
            try{
              if(eachResponse.Account_Type__c  != 'Cloud')
                continue;
                JBCXM__SurveyResponse__c NPSSurveyToBeInserted = new JBCXM__SurveyResponse__c();
                NPSSurveyToBeInserted.Survey_Response__c = eachResponse.id;
                NPSSurveyToBeInserted.JBCXM__Account__c = eachResponse.Account__c;
                String surveyName = year;
                if(eachResponse.Survey_Type__c == 'Relationship'){
                  if(eachResponse.CreatedDate.month() <= 6)
                    surveyName += ' H1 Relationship';
                  else
                    surveyName +=' H2 Relationship';
                }
                else if(eachResponse.Survey_Type__c == 'Transactional'){
                  if(eachResponse.CreatedDate.month() <= 6)
                    surveyName += ' H1 Support';
                  else
                    surveyName += ' H2 Support';
                }
                List<JBCXM__SurveyMaster__c> surveyMaster = [SELECT id FROM JBCXM__SurveyMaster__c WHERE JBCXM__SurveyName__c=: surveyName];
                if(!surveyMaster.isEmpty()){
                  NPSSurveyToBeInserted.JBCXM__SurveyCode__c = surveyMaster[0].id;
                }
                NPSSurveyToBeInserted.JBCXM__NPSComment__c = eachResponse.Verbatim__c;
                if(eachResponse.NPS_Rating__c != null){
                  Decimal score = Decimal.valueOf(eachResponse.NPS_Rating__c);
                  NPSSurveyToBeInserted.JBCXM__NPSScore__c = score;  
                  NPSSurveyToBeInserted.JBCXM__NPSScoreText__c = eachResponse.NPS_Rating__c;         
                  if(score >= 9)
                      NPSSurveyToBeInserted.JBCXM__NPSScoreType__c = 'Promoter';  
                  else if(score >= 7)
                      NPSSurveyToBeInserted.JBCXM__NPSScoreType__c = 'Passive';
                  else
                      NPSSurveyToBeInserted.JBCXM__NPSScoreType__c = 'Detractor';
                 }
                NPSSurveyToBeInserted.JBCXM__ResponseDate__c  = eachResponse.CreatedDate;
                NPSSurveyToBeInserted.JBCXM__UserEmail__c = eachResponse.Contact_Email_Formula__c;
                NPSSurveyToBeInserted.JBCXM__UserName__c = eachResponse.End_User_Account_Name__c;
                NPSSurveyToBeInserted.JBCXM__UserRole__c = eachResponse.Role_Name__c;
                NPSSurveysToBeInserted.add(NPSSurveyToBeInserted);
            }
            catch(Exception ex){
                String htmlBody = 'Dear Admin, <br/><br/>';
                htmlBody += 'Error Details = ' + ex.getMessage() + '<br/><br/>';
                htmlBody += 'Survey(s) Details = [' + eachResponse + ']<br/><br/>';
                htmlBody += 'Thanks';                       
                SendEmail.sendSingleEmail(Label.Survey_Response_Admin_Email_Ids, 'Survey Response Trigger Error', htmlBody, 'SurveyResponse@genesys.com');          
            }
       }   
       if(!NPSSurveysToBeInserted.isEmpty()){
            Database.SaveResult[] srList = Database.insert(NPSSurveysToBeInserted, false);              
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()){
                    Survey_Response__c errorRecord = newMap.get(sr.getId());                   
                    String htmlBody = 'Dear Admin, <br/><br/>';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                        
                        htmlBody += 'Error Details = ' + err .getMessage() + '<br/><br/>';
                    }
                    htmlBody += 'Survey(s) Details = [' + errorRecord + ']<br/><br/>';
                    htmlBody += 'Thanks';                       
                    SendEmail.sendSingleEmail(Label.Survey_Response_Admin_Email_Ids, 'Survey Response Trigger Error', htmlBody, 'SurveyResponse@genesys.com');
                }
            }
        }
    }        
}