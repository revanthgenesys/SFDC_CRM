/************************************************************************************
Purpose : Schedular to run Update Forecast batch for users
Written By :  Naresh Kumar	08/13/2018
Test Classes :  UpdateForecastTotalOnUserBatchTest
*************************************************************************************/
global  without sharing class UpdateForecastTotalOnUserSchedular implements Schedulable {
    global void execute(SchedulableContext schedulableContext) {
        String query = Label.Forecast_User_Query;
        if(Test.isRunningTest()){
            query = 'SELECT id FROM User WHERE id = \'' + UserInfo.getUserId() + '\'';
        }
        UpdateForecastTotalOnUserBatch forecastUpdateBatch = 
            new UpdateForecastTotalOnUserBatch(query);
        Database.executebatch(forecastUpdateBatch, 10);        
    }
}