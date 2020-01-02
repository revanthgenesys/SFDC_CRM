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
@isTest(seeAllData=true)
private class TechnologyLicenseFormController_Test {

    static testMethod void myUnitTest() {
    	Test.startTest();
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser;
    	Test.stopTest();
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
    	System.runAs(testUser){
	    	Technology_Market_place_Application__c mpObj = new Technology_Market_place_Application__c();
	      	mpObj.Are_any_deals_pending_execution__c = true;
	      	mpObj.Average_deal_size__c = 12000;
	      	mpObj.average_sales_cycle_to_close_a_deal__c = '1 Month';
	      	mpObj.Describe_planned_end_user_pricing__c	= 'Test';
	      	mpObj.Describe_the_point_of_Integration__c = 'test';
	      	mpObj.Elevator_Pitch__c = 'test';
	      	mpObj.Howmany_custmers_are_currently_piloting__c = 1;
	      	Date todayDate = date.newInstance(2015,10,30);
	      	mpObj.If_not_what_is_the_expected_GA_Date__c = todayDate;
	      	//mpObj.If_not_what_is_the_expected_GA_Date__c = todayDate;
	      	mpObj.Is_App_already_built_available_in_Prod__c = true;
	      	mpObj.Is_your_sol_aimed_at_a_part_verticals__c = true;
	      	mpObj.List_of_your_Top_prospects_deal_value__c = 'test';
	      	mpObj.Partner_Account__c = testAccount.id;
	      	mpObj.Please_Describe__c = 'test';
	      	mpObj.Problem_Statement__c = 'test';
	      	mpObj.Solution_Name__c = 'test';
	      	mpObj.Status__c = 'Approved';
	      	mpObj.What_s_your_target_customer_company_size__c = 'Smb';
	      	mpObj.What_currency_does_your_company_transact__c = 'USD';
	      	mpObj.Primary_contact_Name__c = testContact.Id;
	      	mpObj.Partner_Account__c = testAccount.Id;
	      	
	      	insert mpObj;
	      	
	      	Technology_License_Form__c tlfObj = new Technology_License_Form__c();
	      	tlfObj.Product_Sold__c = 'test';
	      	tlfObj.Number_of_Licenses_sold__c = 10;
	      	tlfObj.Sales_price_per_license__c = 25000;
	      	tlfObj.Customer_Name__c = 'Test';
	      	tlfObj.Country_of_sale__c ='Canada';
	      	tlfObj.Date_of_billing__c = todayDate;
	      	tlfObj.Invoicing_Model__c = 'Lump sum payment';
	      	tlfObj.Partner_Account__c = testAccount.Id;
	      	tlfObj.Sales_Currency__c = 'USD';
	      	insert tlfObj;
	      	
	      	PageReference pageRef = Page.TechnologyLicenseForm;
			Test.setCurrentPage(pageRef);	
	    	//ApexPages.currentPage().getParameters().put('id', mpObj.id);
	    	TechnologyLicenseFormController obj = new TechnologyLicenseFormController(new ApexPages.StandardController(tlfObj));
	    	obj.getTechnologyLicenseForm();
	    	obj.first();
	    	obj.last();
	    	obj.previous();
	    	obj.next();
	    	obj.getTotalPages();
	    	boolean hasNext= obj.hasNext;
	    	boolean hasPrevious= obj.hasPrevious;
	    	Integer pageNumber = obj.pageNumber;
	    	Integer resultSize = obj.resultSize;
		}
    }
}