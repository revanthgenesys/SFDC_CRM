//Naresh Kumar	05/31/2016
@isTest(seeAllData = true)
private class CloudForecastQuarterMainHelperTest {

    static testMethod void CloudForecastQuarterMainHelper1() {    	
        Cloud_Forecast_Quarter__c testQuarter = new Cloud_Forecast_Quarter__c();
        testQuarter.Name = 'Test Week';
        testQuarter.Active__c = true;
        insert testQuarter;
        insertData(testQuarter.id);
        Cloud_Forecast_Quarter__c testQuarter1 = new Cloud_Forecast_Quarter__c();
        testQuarter1.Name = 'Test Week';
        testQuarter1.Active__c = true;
        testQuarter1.Previous_Week__c = testQuarter.id;
        testQuarter1.Current_Week__c = true;
        insert testQuarter1;        
    }
    
    private static void insertData(String testQuarterId){
    	Account testAccount = TestUtil.createAccounts(1, false)[0];
    	testAccount.PE_SS_Flag__c = true;
    	insert testAccount;
    	Account_Revenue_Forecast__c testARF = new Account_Revenue_Forecast__c();
    	testARF.Account__c = testAccount.id;
    	testARF.PE_SS_Flag__c = true;
    	testARF.Comment_Validation__c = true;
    	testARF.Cloud_Forecast_Quarter__c = testQuarterId;
    	insert testARF;
    	Account_Revenue_Forecast_Comment__c testComment = new Account_Revenue_Forecast_Comment__c();
    	testComment.Account_Revenue_Forecast__c = testARF.id;
    	insert testComment;
    }
}