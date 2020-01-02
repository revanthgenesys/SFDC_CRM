/************************************************************************************
Purpose : Scheduler class for SubscriptionAutoRenewal
Written By : Ranjith Punneli
Test Classes : SubscriptionAutoRenewalTest
*************************************************************************************/

global class SubscriptionAutoRenewalScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        SubscriptionAutoRenewal clsAutoRenewal = new SubscriptionAutoRenewal(Date.today());    
        String strWhereCondition = 'WHERE Status__c = \'Active\' AND Billing_Category__c !=\'M2M\'';
        List<CCDB_Cloud_Renew_Settings__mdt> list_CCDBSettings = [SELECT Id, Label, Offering_Type__c, Number_of_days__c 
                                                                     FROM CCDB_Cloud_Renew_Settings__mdt
                                                                     WHERE Label LIKE 'RenewBatchDays%'];
        
        if(list_CCDBSettings.size() > 0)
        {                                                           
            strWhereCondition += ' AND (';
            for(CCDB_Cloud_Renew_Settings__mdt mdtCCDBSettings : list_CCDBSettings)
            {                                                      
                Date dtEndDate = Date.today().addDays(Integer.valueof(mdtCCDBSettings.Number_of_days__c));
                strWhereCondition += ' (Offering_Type__c = \'' + mdtCCDBSettings.Offering_Type__c + '\' AND Subscription_End_Date__c = ' +  String.valueOf(dtEndDate) +') OR';
            }
            strWhereCondition = strWhereCondition.removeEnd('OR');
            strWhereCondition += ')';
        }
		if(Test.isRunningTest()){
        	strWhereCondition = strWhereCondition + ' LIMIT 1';
        }
        System.debug('strWhereCondition '+strWhereCondition );
        CreateRenewalOppAndQuoteFromSubsBatch clsOppAndQuoteRenewal = new CreateRenewalOppAndQuoteFromSubsBatch(strWhereCondition); 
        Database.executeBatch(clsOppAndQuoteRenewal, 1);  
		/*strWhereCondition = 'Status__c = \'Active\' and  Offering_Type__c = \''+SubscriptionUtil.OFFERING_TYPE_PC+'\' and Status_of_AppFoundry_Trial_Products__c = \'Trial Products Added and Active\' and End_Date_of_AppFoundry_Trial_Projects__c = '+String.valueOf(System.today()) ;  
        System.debug('strWhereCondition '+strWhereCondition );
        if(Test.isRunningTest()){
        	strWhereCondition = strWhereCondition + ' LIMIT 1';
        }
        ConvertPureCloudTrialSubscriptions clsTrialRenewal = new ConvertPureCloudTrialSubscriptions(strWhereCondition); 
        //Database.executeBatch(clsTrialRenewal,1);  */

    }    
}