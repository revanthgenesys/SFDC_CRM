@isTest(seeAllData=true)
public class LicenseUsage_BeforeTest {
    
    @isTest
    static void testLicenseUsage_BeforeTest(){
        Account testAccount = [Select Id, Name FROM Account WHERE ININ_ID__c != NULL LIMIT 1];
        License_Request_Log__c requestLog = new License_Request_Log__c(Legacy_ID__c = 'RL-00001', End_User__c = testAccount.Id, Sold_To__c = testAccount.Id, Requested_By__c = UserInfo.getUserId(),
                                                                        MAC_Address__c = 'macaddreess', Machine_Name__c = 'machinename', Log_Type__c = 'testLog',
                                                                        MailConnector1__c = 'Other', SystemType1__c = 'Not Applicable',
                                                                        Generation_Date__c = DateTime.now(), Expiration_Date__c = DateTime.Now().addYears(10), IsActive__c = true
                                                );
        insert requestLog;
        
        CS_Disable_Triggers__c csDisableTriggers = CS_Disable_Triggers__c.getInstance('LicenseUsageTrigger');
        if(csDisableTriggers != null){
            csDisableTriggers.Flag__c = 'Enable';
            update csDisableTriggers;
        } 
        
        License_Usage__c lUsage = new License_Usage__c(Account__c = testAccount.Id, ItemNumber__c = 'SW-005-4.0-SS01', LicenseId__c = 'RL-00001', Quantity_Used__c = 100, Log_Type__c = 'testLog');
        insert lUsage;
        
    }   
}