@isTest(seeAllData=true)
private class PartnerApplicationAutoCancellBatchTest {

    static testMethod void myUnitTest() {
    	Test.startTest();
    	Partner_Application__c pa = new Partner_Application__c();
    	pa.Company_Name__c = 'Test Company';
    	pa.Status__c = 'In Progress';
    	pa.Account__c = TestUtil.createAccounts(1, true)[0].id;
        pa.AnnualSalesRevenue_PL__c = 'No';
        pa.Ownership_PL__c = 'No';
        pa.RightToAppointOrDismiss_PL__c = 'No';
        pa.AppointOrDismissMD_PL__c = 'No';
        pa.Government_Veto_PL__c = 'No';
        pa.PublicInternationalOrg_PL__c = 'No';
        pa.Convicted_Executive_PL__c = 'No';
        pa.BannedEmployee_PL__c = 'No';
        pa.ExportEnforcementActivity_PL__c = 'No';
        pa.CountryCurrentlyUnderUS_PL__c = 'No';
        pa.Conflict_of_Interest_PL__c = 'No';
        pa.Current_or_Former_Genesys_Employee_PL__c = 'No';
    	insert pa;
    	PartnerApplicationAutoCancellationBatch obj = new PartnerApplicationAutoCancellationBatch(); 
    	Database.executeBatch(obj);
    	Test.stopTest();
    }
}