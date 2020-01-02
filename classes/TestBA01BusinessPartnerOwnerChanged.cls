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
private class TestBA01BusinessPartnerOwnerChanged {
	
static testMethod void testBPChangeOwner() {
Util.myLog('START TestBA01BusinessPartnerOwnerChanged.testBPChangeOwner'); 
/***** PREPARE DATA ***********/
User uCurrentUser = TestCommon.createUser('testmlg', 'MyTestUserName@test.test', 'MyTestLastName','MyTestFirstName',null); 
User uNewUser = TestCommon.createUser('testmlg2', 'MyTestUserName2@test.test', 'MyTestLastName2','MyTestFirstName2',null);
System.runAs(uCurrentUser) 
{
	//CREATE ACCOUNT AND RELATED RECORDS
	Account a1 = TestCommon.createAccount(true);
	Account a = TestCommon.createAccountBP(true); 
	Contact c = TestCommon.createContact(a1.Id);
	Opportunity o = TestCommon.createOpportunity(a1.Id);
	o.BusinessPartner__c = a.id;
	update o;
	a.ownerId = uNewUser.id;
	update a;
	
	List<Account> BA01Accounts = new List<Account>();
	BA01Accounts.add(a);
	/*	
	BA01BusinessPartnerOwnerChanged batchBPTest = new BA01BusinessPartnerOwnerChanged('BATCH_FROM_BA001_ACCOUNT__BUSINESS_PARTNER_CHANGE_OWNER',BA01Accounts);
	
	Util.myLog('Start Test');
	Test.startTest(); 
	Id batchIdBP = Database.executeBatch(batchBPTest,200);

	Test.stopTest();    
	Util.myLog('End Test');
	Util.myLog('END TestBA01BusinessPartnerOwnerChanged.testBPChangeOwner');             
	*/
  }
}
}