//Naresh Kumar	07/16/2018
@isTest(seeAllData=true)
private class UpdateForecastTotalOnUserBatchTest {

    @isTest
    public static void testMethod1(){
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        List<RecordType> oppRecordType = [SELECT id FROM RecordType WHERE DeveloperName = 'GEN_Opportunity_Record_Type_New'
                                          AND SObjectType = 'Opportunity'];
        List<Opportunity> testOpps = TestUtil.createOpportunities(3, testAccount.id, false);
        testOpps[0].RecordTypeId = oppRecordType[0].id;
        testOpps[0].ForecastStatus__c = '0.Booked';
        testOpps[0].StageName = '5.Purchase Solution';
        testOpps[0].Win_Loss_Status__c = 'Won';
        testOpps[0].CloseDate = System.today();
        testOpps[0].Competitor__c = 'Test Competitor';
        
        testOpps[1].RecordTypeId = oppRecordType[0].id;
        testOpps[1].ForecastStatus__c = '3.Expected';
        testOpps[1].StageName = '1.Understand Needs';
        testOpps[1].Win_Loss_Status__c = null;
        testOpps[1].CloseDate = System.today();        
        testOpps[1].Competitor__c = 'Test Competitor';
        
        testOpps[2].RecordTypeId = oppRecordType[0].id;
        testOpps[2].Has_PPU_Usage__c = false;
        testOpps[2].Cloud_Renewal__c = false;
        testOpps[2].Has_PS__c = false;        
        testOpps[2].ForecastStatus__c = '0.Booked';
        testOpps[2].StageName = '1.Understand Needs';
        testOpps[2].Win_Loss_Status__c = 'Won';
        testOpps[2].CloseDate = System.today();        
        testOpps[2].Competitor__c = 'Test Competitor';
        
        insert testOpps;
        
        Test.startTest();
        //Database.executeBatch(new UpdateForecastTotalOnUserBatch('SELECT id FROM User WHERE id = \'' + UserInfo.getUserId() + '\' '), 1);
        UpdateForecastTotalOnUserSchedular sh1 = new UpdateForecastTotalOnUserSchedular();
		String sch = '0 0 23 * * ?'; 
        System.schedule('User Batch', sch, sh1);
        Test.stopTest();
    }    
   
}