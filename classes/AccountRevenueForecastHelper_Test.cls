@isTest
public class AccountRevenueForecastHelper_Test{

    static testMethod void unitTest(){
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.PE_SS_Flag__c = true;
        insert testAccount;
        
        Account_Revenue_Forecast__c testARF = new Account_Revenue_Forecast__c();
        testARF.Account__c = testAccount.id;
        testARF.PE_SS_Flag__c = true;
        testARF.Offering_Type__c = 'PureCloud';
        insert testARF;
        testARF.Comment_Validation__c = true;
        update testARF;
        JBCXM__GSRelationship__c gsRel1= new JBCXM__GSRelationship__c();
        gsRel1.JBCXM__Account__c = testAccount.id;
        gsRel1.Name = 'PureCloud';
        insert gsRel1;
        
        AccountRevenueForecastHelper arfHelper = new AccountRevenueForecastHelper();
    }
}