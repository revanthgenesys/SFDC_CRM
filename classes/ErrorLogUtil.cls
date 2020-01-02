//Naresh Kumar	03/13/2014
public with sharing class ErrorLogUtil {	
	public static void insertLog(String recordName, String logDetails, String source){
		try{
			Error_Log__c newLog = new Error_Log__c();
			newLog.Code_Type__c = recordName;
			newLog.Error_Description__c = logDetails;
			newLog.User_Name__c = UserInfo.getUserId();
			newLog.Object_Name__c = source;
			insert newLog;
			//String html = 'https://na12.salesforce.com/' + newLog.id;
			//if(recordName != null)
			//SendEmail.sendSingleEmail('nareshk.it@gmail.com', 'New Order Completed', html);
		}
		catch(Exception ex){
			//SendEmail.sendSingleEmail('nareshk.it@gmail.com', 'Error in ErrorLogUtil', ex.getMessage());
		}
	}
}