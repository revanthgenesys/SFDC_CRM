@isTest(SeeAllData = true)
public class SourceAccountMain_Test {
    static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;
            
             Test.startTest();
            
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            objTestAccount.Country__c = [SELECT Id FROM Country__c WHERE Name = 'Brazil' LIMIT 1].Id;
            insert objTestAccount;
            
            List<SourceAccounts__c>list_DD = new List<SourceAccounts__c>();
            SourceAccounts__c objSA = new SourceAccounts__c();
            objSA.Trial_Status__c = 'Active';
            objSA.Account__c = objTestAccount.id;
            insert objSA;
            
            objSA.Trial_Status__c = 'Inactive';
            update objSA;

            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
   
}