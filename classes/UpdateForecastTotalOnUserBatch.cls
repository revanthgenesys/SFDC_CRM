/************************************************************************************
Purpose : Batch to update forecasts total on user
Written By :  Naresh Kumar	08/07/2018
Test Classes :  UpdateForecastTotalOnUserBatchTest
*************************************************************************************/
global class UpdateForecastTotalOnUserBatch implements Database.Batchable<sObject>{
   global final String Query;

   global UpdateForecastTotalOnUserBatch(String q){
   		Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
   	  List<Id> listOfUserIds = new List<Id>();
      for(Sobject s : scope){
      	listOfUserIds.add(s.id);    
      } 
      UpdateForecastTotalOnUser.updateTotal(listOfUserIds); 
   }

   global void finish(Database.BatchableContext BC){

   }

}