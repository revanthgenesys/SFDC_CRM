// This class provides essentially calls to BatchTaxCloudUsageDataTest
// as well as a mock response for testing for TaxCalculator

@isTest
public class TaxCalculatorTest {

    public static Id idOrderLineItem;

    @testSetup
    static void setUpData() {
        BatchTaxCloudUsageDataTest.setUpData();
    }
    @isTest
    public static void testBatchRolledTax(){
        BatchTaxCloudUsageDataTest.testBatchRolledTax();
    }
    @isTest
    public static void testBatchOrderLineSureTax(){
        BatchTaxCloudUsageDataTest.testBatchOrderLineSureTax();
    }

/*
    {
        Contract_Tier_Set_Period__c objCTSP = new Contract_Tier_Set_Period__c(Start_Date__c = Date.newInstance(2017, 1, 1),
                                                                              End_Date__c = Date.newInstance(2017, 2, 1));
        insert objCTSP;
        Contract_Tier_Set_Month__c objCTSM = new Contract_Tier_Set_Month__c (
            Contract_Tier_Set_Period__c = objCTSP.Id,
            Month__c = '1',
            Year__c = '2017'
        );
        insert objCTSM;
        
        Service_Usage__c objServiceUsage = new Service_Usage__c (
            Contract_Tier_Set_Month__c = objCTSM.Id,
            Tax_Status__c = 'Tax Rollup Needed'
        );
        insert objServiceUsage;
        
        Service_Usage_Tax__c objSUT1 = new Service_Usage_Tax__c(
            Service_Usage__c = objServiceUsage.Id,
            Tax_Type_Code__c = '100',
            Tax_Amount__c = 1.35
        );
        insert objSUT1;
        
        Service_Usage_Tax__c objSUT2 = new Service_Usage_Tax__c(
            Service_Usage__c = objServiceUsage.Id,
            Tax_Type_Code__c = '101',
            Tax_Amount__c = 2.46
        );
        insert objSUT2;
        
        insert SureTaxSettingsFactory.createDefaultSureTaxSettings();
        insert new List<Service__c>{ServiceFactory.createPCVOutboundService('US', false, '050103'), ServiceFactory.createOutboundRateTableService()};
            
            insert CallingRateFactory.createCallingRate();
        
        Rolled_Up_Usage_Data__c ruud = RolledUpUsageDataFactory.createRolledUpUsageDataOutboundWithTax('e3139188-e3b1-4608-a8bc-0660206ad3b1', '46032');
        insert ruud;
        
        // Future Factory classes
        List<Account> list_accts = TestUtil.createAccounts(1, false);
        list_accts[0].SAP_Account_Code__c = 'GARN123';
        upsert list_accts;
        
        Account acct = list_accts[0];
        
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
        insert quote;
        
        // Contract
        GCR_Content_Document_Detail__c contract = new GCR_Content_Document_Detail__c(Pricing_Start_Date__c = Date.newInstance(2015,1,1),
                                                                                     Account_Name__c = acct.Id, 
                                                                                     Status__c = 'Approved',
                                                                                     Quote__c = quote.id);
        insert contract;
        
        // Contract Tier Set
        Contract_Tier_Set__c objContractTierSet = ContractTierSetFactory.createContractTierSet('Calling', contract.Id, 'Step', '1', '1', 'Minutes(60s ceiling)');
        insert objContractTierSet;
        
        List<Service__c> list_services = [SELECT Id, Name, PCV_Service_Identifier__c 
                                          FROM Service__c]; 
        //WHERE PCV_Service_Identifier__c IN :set_ServiceIdentifiers];
        
        List<Contract_Service__c> list_contractServices = new List<Contract_Service__c>();
        for (Service__c objService : list_services) 
        {
            system.debug('#Service Hash: ' + objService.PCV_Service_Identifier__c);
            
            Contract_Service__c objContractService = new Contract_Service__c (
                Contract_Tier_Set__c = objContractTierSet.Id,
                Service__c = objService.Id,
                Is_Deleted__c = false
            );
            list_contractServices.add(objContractService);
        }
        insert list_contractServices;
        
        
        Cloud_Deployment__c cloudDeployment = new Cloud_Deployment__c(
            Account__c = acct.Id, 
            PureCloud_OrgID__c = 'e3139188-e3b1-4608-a8bc-0660206ad3b1'
        );
        
        insert cloudDeployment;
        cloudDeployment = [SELECT Id, PureCloud_OrgID__c, PureCloud_OrgID_Hash__c 
                           FROM Cloud_Deployment__c 
                           WHERE Id = :cloudDeployment.Id];
        System.assertEquals(cloudDeployment.PureCloud_OrgID_Hash__c, 'PCL#e3139188-e3b1-4608-a8bc-0660206ad3b1'); // TODO SHOULD BE PLC? 
        
        Cloud_Deployment_To_Contract_Junction__c objCDTC = new Cloud_Deployment_To_Contract_Junction__c
            (Cloud_Deployment__c = cloudDeployment.Id,
             Contract__c = contract.Id);
        insert objCDTC;
    }
    @isTest
    static void testRollupServiceUsageTaxes() {
        TaxCalculator objTaxCalculator = new TaxCalculator();
        List<Service_Usage__c> listServiceUsage = [
            SELECT
            Id, Name, Rolled_Up_Usage_Data__c, Rolled_Up_Usage_Data__r.Service_Identifier__c,
            Rolled_Up_Usage_Data__r.ZIP_Postal_Code__c, Rolled_Up_Usage_Data__r.Exception_Type__c,
            Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c, Start_Time__c,
            SureTax_Transaction_Type_Code__c, Tax_Status__c, Count__c, Cost__c, Total_Duration__c,
            (SELECT Service_Usage__c, Tax_Type_Code__c, Tax_Amount__c FROM Service_Usage_Taxes__r)
            FROM Service_Usage__c
            WHERE Tax_Status__c = 'Tax Rollup Needed'];
        
        objTaxCalculator.rollupServiceUsageTaxes(listServiceUsage);
    }
    
    @isTest
    static void testRollupServiceUsageTaxesExistingMonthCharges() {
        List<Contract_Tier_Set_Month__c> listContractTierSetMonth = [select Id from Contract_Tier_Set_Month__c];
        System.debug('listContractTierSetMonth ' + listContractTierSetMonth);
        Contract_Tier_Set_Month_Charges__c objContractTierSetMonthCharge = new Contract_Tier_Set_Month_Charges__c(
            Amount__c = 2.34,
            Description__c = '100',
            Contract_Tier_Set_Month__c = listContractTierSetMonth[0].Id
        );
        insert objContractTierSetMonthCharge;
        
        TaxCalculator objTaxCalculator = new TaxCalculator();
        List<Service_Usage__c> listServiceUsage = [
            SELECT
            Id, Name, Rolled_Up_Usage_Data__c, Rolled_Up_Usage_Data__r.Service_Identifier__c,
            Rolled_Up_Usage_Data__r.ZIP_Postal_Code__c, Rolled_Up_Usage_Data__r.Exception_Type__c,
            Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c, Start_Time__c,
            SureTax_Transaction_Type_Code__c, Tax_Status__c, Count__c, Cost__c, Total_Duration__c,
            (SELECT Service_Usage__c, Tax_Type_Code__c, Tax_Amount__c FROM Service_Usage_Taxes__r)
            FROM Service_Usage__c
            WHERE Tax_Status__c = 'Tax Rollup Needed'];
        
        objTaxCalculator.rollupServiceUsageTaxes(listServiceUsage);
    }
    
@isTest static void testRatingWithTax() 
{
Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
insert objLog;

// Invoke batch Job to process Usage Data
Test.startTest();
BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
objBatch.objJobLog = objLog;
Database.executeBatch(objBatch, 200);
Test.stopTest();

List<Service_Usage__c> list_ServiceUsage = [SELECT
Cost__c,
Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Units_Type__c,
Quantity__c,
Rolled_Up_Usage_Data__r.Billable_60__c
FROM Service_Usage__c];
System.debug('#Service Usage Size ' + list_ServiceUsage.size());
for (Service_Usage__c su : list_ServiceUsage)
{
system.debug('#SU: ' + su);
}

// Assert Service Usage
System.assertEquals(list_ServiceUsage.size(), 1, 'Service Usage not found');

// Assert Service Usage Tax
List<Service_Usage_Tax__c> list_ServiceUsageTax = [SELECT Id FROM Service_Usage_Tax__c];
System.assertEquals(list_ServiceUsageTax.size(), 1, 'Service Usage Tax not found');

// Assert Monthly tier set charge
List<Contract_Tier_Set_Month_Charges__c> list_ContractTierSetMonthCharge = [SELECT Id FROM Contract_Tier_Set_Month_Charges__c];
System.assertEquals(list_ContractTierSetMonthCharge.size(), 1, 'Tier Set Month Charges not found');
}

@isTest static void testRatingWithTaxException() 
{
Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
insert objLog;

// Set trigger for mocking an exception - TODO find better way?
List<Rolled_Up_Usage_Data__c> list_exceptionRUUD = new List<Rolled_Up_Usage_Data__c>([SELECT Id, Partner_Info__c FROM Rolled_Up_Usage_Data__c]);
for (Rolled_Up_Usage_Data__c ruud : list_exceptionRUUD)
{
ruud.Partner_Info__c = EXCEPTION_KEYWORD;
}
update list_exceptionRUUD;

// Invoke batch Job to process Usage Data
Test.startTest();
BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
objBatch.objJobLog = objLog;
Database.executeBatch(objBatch, 200);
Test.stopTest();

List<Service_Usage__c> list_ServiceUsage = [SELECT
Cost__c,
Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Units_Type__c,
Quantity__c,
Rolled_Up_Usage_Data__r.Billable_60__c
FROM Service_Usage__c];

System.assertEquals(list_ServiceUsage.size(), 0, 'Service Usage records were not deleted');

List<Cloud_Billing_Exception__c> billingExceptions = [SELECT Id FROM Cloud_Billing_Exception__c];

System.assertNotEquals(billingExceptions.size(), 0, 'No exceptions were created');
}
*/
    public static String mockResponse(List<Service_Usage__c> dummy)
    {
        System.debug('TaxCalculatorTest.mockResponse enter idOrderLineItem ' + idOrderLineItem);
        Boolean hasException = false;
        
        SureTax.Response sureTaxResponse = new SureTax.Response();
        
        sureTaxResponse.Successful = 'Y';
        sureTaxResponse.ResponseCode = '9999';
        sureTaxResponse.HeaderMessage = 'Success';
        sureTaxResponse.ItemMessages = null;
        sureTaxResponse.ClientTracking = 'SF';
        sureTaxResponse.TotalTax = '2.00';
        sureTaxResponse.TransId = 379793975;
        
        SureTax.ItemTax[] itemTaxes = new SureTax.ItemTax[]{};
        SureTax.ItemMessage[] itemMessages = new SureTax.ItemMessage[]{};
        SureTax.ItemTax itemTax = new SureTax.ItemTax();
        itemTax.TaxList = new SureTax.Tax[]{};
        itemTax.LineNumber = idOrderLineItem;
        itemTax.StateCode = 'IN';

        {        
        SureTax.Tax tax = new SureTax.Tax();
        tax.TaxtypeCode = '106';
        tax.TaxTypeDesc = '911 TAX';
        tax.TaxAmount = '0.50';
        itemTax.TaxList.add(tax);
        }
        {        
        SureTax.Tax tax = new SureTax.Tax();
        tax.TaxtypeCode = '035';
        tax.TaxTypeDesc = 'FUSFC TAX';
        tax.TaxAmount = '0.66';
        itemTax.TaxList.add(tax);
        }
        itemTaxes.add(itemTax);
        
        sureTaxResponse.ItemMessages = itemMessages;
        sureTaxResponse.GroupList = itemTaxes;
        
        String response = '{"d":' + JSON.serialize(JSON.serialize(sureTaxResponse, true)) + '}'; 
        System.debug('TaxCalculatorTest.mockResponse response' + response);
        return response;
    }
}