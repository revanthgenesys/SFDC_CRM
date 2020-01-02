@isTest
public class CloudBillingContractNewControllerTest {

    private static Account createAccountWithGARN() {
        System.Debug('createAccount: Create an Account');
        List<Account> list_accts = TestUtil.createAccounts(1, true);
        System.Debug('createAccount: Retrieve the inserted Account');
        Account acct = list_accts[0];
        
        //Add Needed information for rating
        acct.SAP_Account_Code__c = 'GARN123';
        upsert acct;
        return acct;
    }
    

    @isTest
    static CloudBillingContractNewController getCloudBillingContractNewController() {
		GCR_Content_Document_Detail__c objNewContract = new GCR_Content_Document_Detail__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(objNewContract);
        CloudBillingContractNewController objController = new CloudBillingContractNewController(sc);
		return objController;  
    }

    @isTest
    static void testCloudBillingContractNewDontSetDirectSales() {
        CloudBillingContractNewController objController = getCloudBillingContractNewController();
        
        //objController.objUIOpportunity.Direct_Sales__c = false;
    }

    @isTest
    static void testCloudBillingContractValidateInvalid() {
        CloudBillingContractNewController objController = getCloudBillingContractNewController();

        // Leave all entries blank for force code within if statements
        
        if (objController.validateInput()) {
            System.Debug('Data is Valid');
        } else {
            System.Debug('Data is NOT Valid');
        }
    }
    
    @isTest
    static void testCloudBillingContractCreate() {
        CloudBillingContractNewController objController = getCloudBillingContractNewController();

        // Populate some Account info
        Account objAccount = createAccountWithGARN();

		// Populate Valid data according to CloudBillingContractNewController.validateInput()
        objController.objNewContract.Account_Name__c = objAccount.Id;
        objController.objUIOpportunity.Lines_of_Businesses__c = 'PureEngage';
        objController.objUIOpportunity.Region__c = 'NA';

        // Set UI Quote Record Type
        List<RecordType> listQuoteRecordType = [select id,Name from RecordType where SobjectType = 'BigMachines__Quote__c'];
        if (listQuoteRecordType != null && listQuoteRecordType.size() > 0) {
            objController.quoteRecordTypeSelectedField = listQuoteRecordType[0].Id;
        }

        // Sdet UI Opportunity Type
		List<RecordType> listOppRecordType = [select id,Name from RecordType where SobjectType = 'Opportunity'];
        if (listOppRecordType != null && listOppRecordType.size() > 0) {
            objController.opportunityRecordTypeSelectedField = listOppRecordType[0].Id;
        }

        objController.objUIOpportunity.Direct_Sales__c = false;

		//Populate some address info        
        objController.objNewContractAddress.Address__c = '123 Fake Street';
        objController.objNewContractAddress.Country__c = 'United States';
        objController.objNewContractAddress.Email__c = 'someone@genesys.com';

        objController.saveBtnHandler();
    }

}