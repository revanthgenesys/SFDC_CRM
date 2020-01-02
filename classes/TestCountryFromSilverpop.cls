/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestCountryFromSilverpop {

    static testMethod void myUnitTestSPUser() {
        //#####Test Scenario 1#####
        /*    
        Scenario: Lead is created with USA's Country__c.Id in Country_From_Silverpop__c. 
            Any user then updates the Country__c.Id to Japan's Id
        Expectation: After the lead updates, the Country_From_Silverpop__c should now be populated with USA's Id   
        */
        
        
        String japanId = 'a06U0000000ugc4';
        String usaId = 'a06U0000000ugdy';
        String germanyId = 'a06U0000000ugbcIAA';
        String silverpopId = '005U0000000eECvIAM';
        
        Country__c countryJapan = new Country__c(
        Name = 'JapanTest');
        
        Country__c countryGermany = new Country__c(
        Name = 'GermanyTest');
        
        //Step 1 - Set up the Lead Record to test
        User uAlias1 = [SELECT Id FROM User WHERE Id = '005U0000000eLQVIA2'];
       System.RunAs(uAlias1){
        
        Lead testLeadOne = new Lead(
        lastname='Test1',
        ALUEGroup__c ='Genesys',
        ContactPhone__c = '55555555',
        Company = 'Test1',
        Country_From_Silverpop__c = 'abc123',
        Country__c = 'a06U0000000ugdy');
        
        //Step 2 - Execute Test 
        insert testLeadOne; 
        
        testLeadOne.Country__c = 'a06U0000000ugc4'; 
        /*
        Lead updatedLead = [SELECT Country__c, Country_From_Silverpop__c
            FROM Lead 
            WHERE Id = :testLeadOne.Id];
            
        Lead.Country__c = japanId;
        */
        update testLeadOne;
        
        //Step 3 - Verify that the Country__c field was updated in the database.
        Lead verifyLead = [SELECT Country__c, Country_From_Silverpop__c
            FROM Lead 
            WHERE Id = :testLeadOne.Id];
        
        
        //Step 4 - Assert the test
        //System.assertEquals(countryJapan.id, verifyLead.Country__c);
        System.assertEquals('a06U0000000ugc4IAA', verifyLead.Country_From_Silverpop__c);
       }
        //#####Test Scenario 2#####
        /*Scenario: Inserting testLead2 with country as Germany, using Silverpop Engage user
          Expectation: With Germay's ID inserted into the Country_From_Silverpop__c
                    the trigger should insert Germany's ID into Country__c
        */
        //Step 1 - Set up the Lead Record to test, using the Silverpop Engage User
        User uSilverPop = [SELECT Id FROM User WHERE Id ='005U0000000eECvIAM'];
       System.RunAs(uSilverPop){
        
        Lead testLeadTwo = new Lead(
        lastname='Test2',
        ALUEGroup__c ='Genesys',
        ContactPhone__c = '55555555',
        Company = 'Test2',
        Country_From_Silverpop__c = 'a06U0000000ugbc',
        Country__c = 'a06U0000000ugdy');
        
        
        //Step 2 - Execute Test 
        insert testLeadTwo;
        
        //Step 3 - Verify that the Country__c field was updated in the database.
        Lead updatedLead2 = [SELECT Country__c, Country_From_Silverpop__c
            FROM Lead 
            WHERE Id = :testLeadTwo.Id];
        
        //Step 4 - Assert the test
        System.assertEquals('a06U0000000ugbcIAA', updatedLead2.Country__c);
        
       }
    }
}