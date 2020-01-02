//Naresh Kumar  05/31/2016
public with sharing class CloudForecastQuarterMainHelper {

  public static void onAfterUpdate(List<Cloud_Forecast_Quarter__c> newList, Map<Id, Cloud_Forecast_Quarter__c> oldMap){
    //Code will work only with one record.
    Cloud_Forecast_Quarter__c newRecord = newList[0];
    Cloud_Forecast_Quarter__c oldRecord;
    if(oldMap != null)
      oldRecord = oldMap.get(newRecord.id);  
         system.debug('newRecord==>'+ newRecord); 
    if(newRecord.Current_Week__c && (oldRecord == null || !oldRecord.Current_Week__c) && newRecord.Previous_Week__c != null){
      List<Account_Revenue_Forecast__c> existingARFs = [SELECT id FROM Account_Revenue_Forecast__c WHERE Cloud_Forecast_Quarter__c =: newRecord.id];
      if(existingARFs.isEmpty())
        cloneWeekData(newRecord.id, newRecord.Previous_Week__c);
    }
    if(newRecord.Clone_PESS_Lines__c && (oldRecord == null || !oldRecord.Clone_PESS_Lines__c) && newRecord.Previous_Week__c != null){
      List<Account_Revenue_Forecast__c> existingARFs = [SELECT id FROM Account_Revenue_Forecast__c 
        WHERE Cloud_Forecast_Quarter__c =: newRecord.id AND PE_SS_Flag__c = true];
      if(existingARFs.isEmpty())
        cloneWeekData(newRecord.id, newRecord.Previous_Week__c, true);
    }
  }
  public static void cloneWeekData(String weekId, String previousWeek){
    cloneWeekData(weekId, previousWeek, false);
  }
  public static void cloneWeekData(String weekId, String previousWeek, Boolean clonePESSItemsOnly){
    //Added by Mahesh Varde to avoid Heap Size.
    CloudForecastQuarterClone b = New CloudForecastQuarterClone(weekId, previousWeek);
    database.executebatch(b,200); 
    
    /*List<Account_Revenue_Forecast__c> accountRevenueForecasts = getAccountRevenueForecast(previousWeek, clonePESSItemsOnly);
    List<Account_Revenue_Forecast__c> clonedRecords = new List<Account_Revenue_Forecast__c>(); 
    //Looping over and cloning records
    for(Account_Revenue_Forecast__c eachARF : accountRevenueForecasts){
      Account_Revenue_Forecast__c newRecord = eachARF.clone(false, true);
      newRecord.Previous_Week__c = eachARF.id;
      newRecord.Cloud_Forecast_Quarter__c = weekId;
      newRecord.Cloned_From__c = eachARF.id;
      clonedRecords.add(newRecord);    
    }
    if(!clonedRecords.isEmpty())
      insert clonedRecords;*/
  }
  
  public static void cloneComments(Map<Id, Account_Revenue_Forecast__c> newMap){
    Map<Id, Account_Revenue_Forecast__c> mapOfCloneFromIdVsNewARFRecord = new Map<Id, Account_Revenue_Forecast__c>();
    for(Account_Revenue_Forecast__c eachARF : newMap.values()){
      mapOfCloneFromIdVsNewARFRecord.put(eachARF.Cloned_From__c, eachARF);
    }
    Set<Id> setOfCloneFromId = mapOfCloneFromIdVsNewARFRecord.keyset();
    String accRevenueCommentsFields = CloneUtil.getCreatableFieldsSOQL('Account_Revenue_Forecast_Comment__c', ' Account_Revenue_Forecast__c IN : setOfCloneFromId');
    List<Account_Revenue_Forecast_Comment__c> accountRevenueForecastComments = (List<Account_Revenue_Forecast_Comment__c>)Database.query(accRevenueCommentsFields);
    List<Account_Revenue_Forecast_Comment__c> accountRevenueForecastCommentsToBeInserted = new List<Account_Revenue_Forecast_Comment__c>();
    for(Account_Revenue_Forecast_Comment__c eachComment : accountRevenueForecastComments){
      Account_Revenue_Forecast_Comment__c newComment = eachComment.clone(false, true);
      newComment.Account_Revenue_Forecast__c = mapOfCloneFromIdVsNewARFRecord.get(newComment.Account_Revenue_Forecast__c).id;  
      accountRevenueForecastCommentsToBeInserted.add(newComment);        
    }    
    if(!accountRevenueForecastCommentsToBeInserted.isEmpty())
      insert accountRevenueForecastCommentsToBeInserted;
  }
  
  /*private static List<Account_Revenue_Forecast__c> getAccountRevenueForecast(String weekId, Boolean clonePESSItemsOnly){    
    String whereClause = 'Cloud_Forecast_Quarter__c = \'' + weekId + '\'';
    if(clonePESSItemsOnly)
      whereClause += ' AND PE_SS_Flag__c = true ';  
    String accRevenueFields = CloneUtil.getCreatableFieldsSOQL('Account_Revenue_Forecast__c', whereClause);     
        List<Account_Revenue_Forecast__c> accountRevenueForecasts = (List<Account_Revenue_Forecast__c>)Database.query(accRevenueFields);
        return accountRevenueForecasts;
  }*/
}