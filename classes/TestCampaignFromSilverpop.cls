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
private class TestCampaignFromSilverpop {

    static testMethod void myUnitTestSPUser() {
    	//#####Test Scenario 1#####
    	/*    
    	Scenario: A lead is updated by a user who is not "Genesys Marketing Automation" and they are overiding the 
    	campaign_source__c with a new value. 
    
    	Expectation: After the lead updates, the Campaign_Source_From_SP__c should now be populated with new campaign Id   
    	*/
    	
    	
    	String Genmobile = '701U0000000UbYYIA0';
    	String Socialmedia = '701U0000000UbXGIA0';
    	String WebCustServ = '701U0000000UbY9IAK';
    	String silverpopId = '005U0000000eECvIAM';
    	
    	
    	
    	Campaign campaignGenmobile = new Campaign (
    	Name = 'GenMobileTest');
    	
    	Campaign  campaignSocialmedia = new Campaign (
    	Name = 'SocialMediaTest');
    	
    	//Step 1 - Set up the Lead Record to test
    	
    	
    	
    	User uAlias1 = [SELECT Id FROM User WHERE Id ='005U0000000eLQVIA2'];
       System.RunAs(uAlias1){
    	
    	Lead testLeadOne = new Lead(
    	lastname='TestCampSource',
    	ALUEGroup__c ='Genesys',
    	ContactPhone__c = '55555555',
    	Company = 'Test1',
    	Country_From_Silverpop__c = 'abc123',
    	Campaign_Source_From_SP__c = '123abc',
    	Country__c = 'a06U0000000ugc4IAA');
    	
    	//Step 2 - Execute Test 
    	insert testLeadOne; 
    	
    	testLeadOne.Campaign_Source__c = campaignGenMobile.id; 
    	
    	update testLeadOne;
    	
    	//Step 3 - Verify that the Campaign_Source_From_SP__c field was updated in the database with the correct id.
    	Lead verifyLead = [SELECT Campaign_Source__c, Campaign_Source_From_SP__c
    		FROM Lead 
    		WHERE Id = :testLeadOne.Id];
        
    	
    	//Step 4 - Assert the test
		System.assertEquals(campaignGenmobile.id, verifyLead.Campaign_Source_From_SP__c);
       }
    	//#####Test Scenario 2#####
    	/*Scenario: Inserting testLead2 with campaignSocialmedia.id, using the Silverpop Engage user
		  Expectation: With campaignSocialmedia.id inserted into the Campaign_Source_From_SP__c
		  			the trigger should insert campaignSocialmedia.id into Campaign_Source__c
		*/
		//Step 1 - Set up the Lead Record to test, using the Silverpop Engage User
		User uSilverPop = [SELECT Id FROM User WHERE Id ='005U0000000eECvIAM'];
       System.RunAs(uSilverPop){
		
		Lead testLeadTwo = new Lead(
    	lastname='Test2',
    	ALUEGroup__c ='Genesys',
    	ContactPhone__c = '55555555',
    	Company = 'Test2',
    	Country_From_Silverpop__c = 'a06U0000000ugc4IAA',
    	Campaign_Source_From_SP__c = campaignSocialmedia.id);
    	//Country__c = 'a06U0000000ugc4IAA');
		
		//Step 2 - Execute Test 
		insert testLeadTwo;
		
		//Step 3 - Verify that the Campaign_Source__c field was updated in the database.
		Lead updatedLead2 = [SELECT Campaign_Source__c, Campaign_Source_From_SP__c
    		FROM Lead 
    		WHERE Id = :testLeadTwo.Id];
		
		//Step 4 - Assert the test
		System.assertEquals(campaignSocialmedia.id, updatedLead2.Campaign_Source__c);
		
       }
    }
}