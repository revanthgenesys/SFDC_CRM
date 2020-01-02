/*
    Class : TestCreateCustomerPortalCase
    Usage : test coverage for CreateCustomerPortal
    Author: Vinay L 5/20/2013
    
*/
@isTest (seeAllData = true)
public class TestCreateCustomerPortalCase {
    static testMethod void createCase(){
               
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            //TestUtil.setConfigValues();
            //TestUtil.setCaseSupportTypesSettings();
        }
        
        RecordType rt = [select id from RecordType where SobjectType='Account' and DeveloperName='EMGCustomerRecordType'];     
        Account accnt = new Account( Name='Test Account', Status__c = 'Active',
                                     SAP_Account_Code__c ='111', RecordTypeId = rt.ID); 
        insert accnt;
        
    	Case cs = new Case(status='Open',subject='test', priority = 'Prod Down',
                            recordtypeid= Global_Setting__c.getInstance('Genesys_Product_Case').ID__c, 
                            Sold_To_Account__c = accnt.Id,
                            End_User_Account__c = accnt.Id); 
        insert cs;
        ApexPages.StandardController sc = new ApexPages.StandardController(cs);
        createCustomerPortalCaseExtenstion createCase = new createCustomerPortalCaseExtenstion(sc);
    }
    
}