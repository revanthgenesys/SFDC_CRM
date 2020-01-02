public class createRenewalOppandQuoteBetweenDates{
    
    public static void createRenewalOppandQuoteBetweenDates(Date dtStartDate,Date dtEndDate){
        
        String strWhereCondition = 'WHERE Status__c = \'Active\' AND (Opportunity_LookUp__c != null OR Quote__c != null  OR Order__c != null) and Offering_Type__c in (';
        List<CCDB_Cloud_Renew_Settings__mdt> list_CCDBSettings = [SELECT Offering_Type__c
                                                                  FROM CCDB_Cloud_Renew_Settings__mdt
                                                                  WHERE Label LIKE 'RenewBatchDays%'];
        if(list_CCDBSettings.size() > 0)
        {                                                           
            for(CCDB_Cloud_Renew_Settings__mdt mdtCCDBSettings : list_CCDBSettings)
            {                                                      
                strWhereCondition += '\''+mdtCCDBSettings.Offering_Type__c+'\',';
            }
            strWhereCondition = strWhereCondition.removeEnd(',');
            strWhereCondition += ')';
        }	
        strWhereCondition += ' AND Subscription_End_Date__c >= ' + String.valueOf(dtStartDate)+ ' And Subscription_End_Date__c <=  ' + String.valueOf(dtEndDate);
        if(Test.isRunningTest())
        {strWhereCondition += ' LIMIT 1';   } 
        System.debug(strWhereCondition);
        CreateRenewalOppAndQuoteFromSubsBatch clsOppAndQuoteRenewal = new CreateRenewalOppAndQuoteFromSubsBatch(strWhereCondition); 
        Database.executeBatch(clsOppAndQuoteRenewal, 1 );  
        
    }
}