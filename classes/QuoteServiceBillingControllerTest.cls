/**
* Class Name                : QuoteServiceBillingControllerTest
* Test Covered class(es)    : QuoteServiceBillingController
* Description               : This Class is utilized to make a unit test coverage for QuoteServiceBillingController Apex class.
* Util Class utilized       : TestUtil, QuoteServiceBillingController
* Created By                : Erik Doetsch
* Created Date              : Jul 26th 2017
*/
@isTest
public class QuoteServiceBillingControllerTest {
    
    private static GCR_Content_Document_Detail__c objContract;
    
    @isTest
    static void testQuoteServiceBillingCloudDeploymentPopulate() {
        Util.Bypass_Trigger_Chk = true;
        objContract = createAndInsertCloudBillingContract();
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
        /*        
System.assertEquals(objController.list_TenantId.size(), 1);
System.assertEquals(objController.list_SubscriberId.size(), 0);
System.assertEquals(objController.list_PorticoId.size(), 0);
System.assertEquals(objController.list_PureConnectId.size(), 0);
System.assertEquals(objController.list_PureCloudId.size(), 0);
*/
    }
    
    
    @isTest
    static void testQuoteServiceBillingBulk() {
        objContract = createAndInsertCloudBillingContract();
        System.debug('objContract: ' + objContract);

        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);

        System.Debug('populateDocuments');
        objController.populateDocuments();

        System.Debug('populateTierSetsAndServices');
        objController.populateTierSetsAndServices();

        System.Debug('populateProductMappings');
        objController.populateProductMappings();

        System.Debug('checkPermissions');
        objController.checkPermissions();
        
        System.Debug('populateBillingAddress');
        objController.populateBillingAddress();
        

        List<Calling_Rate__c> list_CallingRates = new List<Calling_Rate__c>();
        for(integer i = 0 ; i < 3 ; i++){
            list_CallingRates.add(new Calling_Rate__c(
                Region_Code__c = 'US',
                Destination_Country_Code__c = '1',
                Carrier_Name__c = 'default' ,
                Destination_Career_Digits__c = 'test',
                Destination_Description__c = 'United States - Contiguous',
                Rate_Per_Minute__c = 0.0400,
                Effective_End_Date__c = Date.newInstance(2017, 1, 2) ,
                Effective_Start_Date__c = Date.newInstance(2016, 12, 20),
                RecordTypeId = '0120B000000Qwga' 
            ));
        }
        insert list_CallingRates;


        System.Debug('populateCarrierDropdown');
        objController.populateCarrierDropdown();
        /*
        if(objContract.Zuora_Quote__c != null) {
            objController.buildZuoraQuoteInfo();            
            
            blnDispZuNetprQuantitiy = true;
        }
*/
        System.Debug('populateYearMonthDropdown');
        objController.populateYearMonthDropdown();
    }
    @isTest
    static void testCreateTierSetWrapper() {
        
        /*
         *         public TierSetWrapper(Contract_Tier_Set__c objContractTierSet,List<Contract_Tier_Range__c> list_ContractTierRanges,
                              List<Contract_Service__c> list_ContractServices,List<Contract_Recurring_Charge__c> list_ContractRecurringCharges,
                              List<BOGO_Detail__c> list_BOGODetails)
         */
    }

    // Added by Vijay - Start Jul 26 2017
    //Fail case 
    @isTest
    static void testQuoteServiceBillingCloudDeploymentPopulateMaxTenants() {
        objContract = createAndInsertCloudBillingContract();
        
        
        List<Cloud_Deployment__c> list_Cd = new List<Cloud_Deployment__c>();
        
        for(integer i = 0 ; i < 52 ; i++){
            list_Cd.add(new Cloud_Deployment__c(Account__c = objContract.Account_Name__c, Tenant_ID__c = 'Tenant123'+i));
        }
        insert list_Cd;
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
        QuoteServiceBillingController.TierSetWrapper objTSWrapper = new QuoteServiceBillingController.TierSetWrapper();
    }
    
    //Fail
    @isTest
    static void testQuoteServiceBillingCloudDeploymentPopulateMaxSubscription() {
        objContract = createAndInsertCloudBillingContract();
        
        
        List<Cloud_Deployment__c> list_Cd = new List<Cloud_Deployment__c>();
        
        for(integer i = 0 ; i < 52 ; i++){
            list_Cd.add(new Cloud_Deployment__c(Account__c = objContract.Account_Name__c, PE_Subscription_ID__c = 'Subscription123'+i));
        }
        insert list_Cd;
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
    }
    
    //Fail
    @isTest
    static void testQuoteServiceBillingCloudDeploymentPopulateMaxPortico() {
        objContract = createAndInsertCloudBillingContract();
        
        
        List<Cloud_Deployment__c> list_Cd = new List<Cloud_Deployment__c>();
        
        for(integer i = 0 ; i < 52 ; i++){
            list_Cd.add(new Cloud_Deployment__c(Account__c = objContract.Account_Name__c, Portico_Platform_Id__c = 'Portico123'+i));
        }
        insert list_Cd;
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
    }
    
    //Fail
    @isTest
    static void testQuoteServiceBillingCloudDeploymentPopulateMaxPureConnect() {
        objContract = createAndInsertCloudBillingContract();
        
        
        List<Cloud_Deployment__c> list_Cd = new List<Cloud_Deployment__c>();
        
        for(integer i = 0 ; i < 52 ; i++){
            list_Cd.add(new Cloud_Deployment__c(Account__c = objContract.Account_Name__c, PureConnect_ID__c = 'PureConnect123'+i));
        }
        insert list_Cd;
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
    }
    
    //Fail
    @isTest
    static void testQuoteServiceBillingCloudDeploymentPopulateMaxPureCloud() {
        objContract = createAndInsertCloudBillingContract();
        
        
        List<Cloud_Deployment__c> list_Cd = new List<Cloud_Deployment__c>();
        
        for(integer i = 0 ; i < 52 ; i++){
            list_Cd.add(new Cloud_Deployment__c(Account__c = objContract.Account_Name__c, PureCloud_OrgID__c = 'PureCloud123'+i));
        }
        insert list_Cd;
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
    }
    
    @isTest
    static void testBillingPlatformID() {
        objContract = createAndInsertCloudBillingContract();
        
        
        List<Cloud_Deployment__c> list_Cd = new List<Cloud_Deployment__c>();
        
        for(integer i = 0 ; i < 52 ; i++){
            list_Cd.add(new Cloud_Deployment__c(Account__c = objContract.Account_Name__c, Billing_Platform_Id__c = 'PureCloud123'+i, Cloud_Platform__c = 'PureConnect Subscription'));
        }
        insert list_Cd;
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        //pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        //Test.setCurrentPage('QuoteServiceBilling');
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateCloudDeployments();
        objController.strTierIndex = '0' ;
        objController.refreshProductTierSet();
    }
    
    @isTest
    static void testcreatNewReportRequest(){
        objContract = createAndInsertCloudBillingContract();
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objNewReportRequest = new Cloud_Billing_Report_Request__c(End_Year__c = '2016' , Start_Year__c = '2017') ;
        objController.createNewReportRequest();
        objController.objNewReportRequest = new Cloud_Billing_Report_Request__c(End_Year__c = '2016' , Start_Year__c = '2016' , 
                                                                                End_Month__c = '6' , Start_Month__c = '7') ;
        objController.createNewReportRequest();
        objController.list_SelectedPlatformIds = new List<String>() ;
        objController.createNewReportRequest();
        objController.objNewReportRequest = new Cloud_Billing_Report_Request__c(Report_Type__c = '', End_Year__c = '2016' , Start_Year__c = '2016' , 
                                                                                End_Month__c = '9' , Start_Month__c = '7') ;
        objController.list_SelectedPlatformIds = new List<String>{'test'} ;
        objController.createNewReportRequest();
        objController.objNewReportRequest = new Cloud_Billing_Report_Request__c(Report_Type__c = 'Detail Inbound Usage', End_Year__c = '2016' , Start_Year__c = '2016' , 
                                                                                End_Month__c = '9' , Start_Month__c = '7') ;
        objController.createNewReportRequest();
        
        // Run Report Request
        objController.objReportJobLog = new Cloud_Billing_Log__c();
        objController.objReportJobLog.Month__c = '6';
        objController.objReportJobLog.Year__c = '2017';
        objController.runReportRequests();
    }
    
    @isTest
    static void testUpdateBillingAddress(){
        objContract = createAndInsertCloudBillingContract();
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        
        Account_Order_Address__c objBillingAddress= new Account_Order_Address__c(Quote__c = objContract.Quote__c, Address_Type__c = 'Bill To',
                                                                        GCR_Content_Document_Detail__c = objContract.id );
        insert objBillingAddress;
        objController.objBillingAddress = objBillingAddress;
        objController.objBillingAddress.Email__c = 'testing email to fail';
        objController.updateBillingAddressBtnHandler();
        objController.objBillingAddress.Email__c = 'test@gentest.com';
        objController.objBillingAddress.Additional_Emails__c = 'test@gentest.com';
        objController.updateBillingAddressBtnHandler();
        objController.objBillingAddress.Email__c = 'test@gentest.com';
        objController.objBillingAddress.Additional_Emails__c = 'testing email to fail';
        objController.updateBillingAddressBtnHandler();
        objController.objBillingAddress.Email__c = 'test@gentest.com';
        objController.objBillingAddress.Additional_Emails__c = 'test@gentest.com;test@gentest.com;test@gentest.com';
        objController.updateBillingAddressBtnHandler();
        objController.reviewedBtnHandler();
        objController.objBillingAddress = new Account_Order_Address__c();
        objController.reviewedBtnHandler();
    }
    
    @isTest
    static void testController10(){
        objContract = createAndInsertCloudBillingContract();
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        
        QuoteServiceBillingController.blnIsPricingEndDateCorrect(1, null);
        QuoteServiceBillingController.blnIsPricingEndDateCorrect(1, Date.newInstance(2017,1,1));
        QuoteServiceBillingController.blnIsPricingEndDateCorrect(3, Date.newInstance(2017,1,31));
        QuoteServiceBillingController.blnIsPricingEndDateCorrect(3, Date.newInstance(2017,1,2));
    }
    
    @isTest
    static void testController11(){
        objContract = createAndInsertCloudBillingContract();
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        Account_Order_Address__c objBillingAddress= new Account_Order_Address__c(Quote__c = objContract.Quote__c, Address_Type__c = 'Bill To', Zip_Code__c = '02176',
                                                                        GCR_Content_Document_Detail__c = objContract.id );
        insert objBillingAddress;
        objController.objContractPricingEndDate = new GCR_Content_Document_Detail__c();
        objController.objBillingAddress = objBillingAddress;
        objController.objContract.Manual_Review_Required__c = 'Yes';
        objController.objContract.Manual_Review_Reason__c = '';
        objController.saveContract();
        objController.objContract.Manual_Review_Reason__c = 'test reason';
        objController.saveContract();
        objController.objContract.Override_Invoice_Footer__c = true;
        objController.objContract.Invoice_Footer_Text__c = '';
        objController.saveContract();
        objController.objContract.Invoice_Footer_Text__c = 'test footer';
        objController.saveContract();
        objController.objContract.Status__c = 'Rejected';
        objController.objContract.Status_Notes__c = '';
        objController.saveContract();
        objController.objContract.Status_Notes__c = 'Status Notes';
        objController.saveContract();
        objController.objContract.Invoice_Delivery_Type__c = 'Email';
        objController.objBillingAddress.Email__c = '';
        objController.saveContract();
        objController.objBillingAddress.Email__c = 'test@test.com';
        objController.objContract.Pricing_Start_Date__c = Date.newInstance(2017,1,31);
        objController.objContractPricingEndDate.Pricing_End_Date__c = Date.newInstance(2017,1,1);
        objController.saveContract();
        objController.objContract.Pricing_Start_Date__c = null;
        objController.objContract.Status__c = 'Hold';
        objController.saveContract();
        objController.objContract.Reviewed__c = true;
        objController.objContract.Invoice_Delivery_Type__c = null;
        objController.objContract.Order_Date_Option__c = null;
        objController.objContract.Status__c = 'Approved';
        objController.blnIsContractManager = false;
        objController.saveContract();
        
        objController.objContract.Pricing_Start_Date__c = Date.newInstance(2016,12,31);
        objController.objContractPricingEndDate.Pricing_End_Date__c = Date.newInstance(2017,1,30);
        objController.saveContract();
        
        // Approved
        objController.objContract.Status__c = 'Approved';
        objController.objContract.Genesys_Entity__c = setupGenesysEntity().id;
        objController.blnIsContractManager = true;
        objController.saveContract();
        objController.blnIsContractManager = false;
        objController.objContract.Reviewed__c = false;
        objController.saveContract();
        objController.objContract.Reviewed__c = true;
        objController.objContract.Pricing_Start_Date__c = null;
        objController.saveContract();
        objController.objContract.Pricing_Start_Date__c = Date.newInstance(2017,1,31);
        objController.objContract.Invoice_Delivery_Type__c = '';
        objController.saveContract();
        objController.objContract.Invoice_Delivery_Type__c = 'Email';
        objController.objContract.Order_Date_Option__c = null;
        objController.saveContract();
        objController.objContract.Order_Date_Option__c = 'Current Date';
        objController.saveContract();
		objController.blnIsContractManager = false;

        objController.objContractPricingEndDate.Pricing_End_Date__c = Date.newInstance(2017,3,31);
        //trying to hit final if statements
        System.Debug('objContract.Manual_Review_Required__c ' + objContract.Manual_Review_Required__c);
        System.Debug('objContract.Manual_Review_Reason__c ' + objContract.Manual_Review_Reason__c);

        System.Debug('objContract.Override_Invoice_Footer__c ' + objContract.Override_Invoice_Footer__c);
        System.Debug('objContract.Invoice_Footer_Text__c ' + objContract.Invoice_Footer_Text__c);
        
        System.Debug('objContract.Status__c ' + objContract.Status__c);
        System.Debug('objContract.Status_Notes__c ' + objContract.Status_Notes__c);
        System.Debug('objContract.Invoice_Delivery_Type__c ' + objContract.Invoice_Delivery_Type__c);
        System.Debug('objBillingAddress.Id ' + objBillingAddress.Id);
        System.Debug('objBillingAddress.Email__c ' + objBillingAddress.Email__c);
        System.Debug('objContract.Genesys_Entity__c ' + objContract.Genesys_Entity__c);

        System.Debug('objContract.Pricing_Start_Date__c ' + objContract.Pricing_Start_Date__c);
        System.Debug('objContract.Pricing_End_Date__c ' + objContract.Pricing_End_Date__c);
        System.Debug('objController.objContractPricingEndDate.Pricing_End_Date__c ' + objController.objContractPricingEndDate.Pricing_End_Date__c);

        System.Debug('objContract.Reviewed__c ' + objContract.Reviewed__c);
        
        System.Debug('objContract.Invoice_Delivery_Type__c ' + objContract.Invoice_Delivery_Type__c);
        System.Debug('objContract.Order_Date_Option__c ' + objContract.Order_Date_Option__c);
        System.Debug('objBillingAddress.Zip_Code__c ' + objBillingAddress.Zip_Code__c);

        // Pricing_Start_Date__c null
        objController.objContract.Pricing_Start_Date__c = null;
        objController.saveContract();
        objController.objContract.Pricing_Start_Date__c = Date.newInstance(2017,1,31);

        //End Date Day is the wrong day
        objController.objContract.Pricing_Start_Date__c = Date.newInstance(2016,12,31);
        objController.objContractPricingEndDate.Pricing_End_Date__c = Date.newInstance(2017,1,15);
        objController.saveContract();
        objController.objContractPricingEndDate.Pricing_End_Date__c = Date.newInstance(2017,3,1);

        //Test that Empty Zip Code is rejected
        objController.objBillingAddress.Zip_Code__c = null;
        objController.saveContract(); 
        objController.objBillingAddress.Zip_Code__c = '02176';


		// Order_Date_Option__c null
        objController.objContract.Order_Date_Option__c = null;
        objController.saveContract();
        objController.objContract.Order_Date_Option__c = 'Current Date';

		// Invoice_Delivery_Type__c null
        objController.objContract.Invoice_Delivery_Type__c = null;
        objController.saveContract();
        objController.objContract.Invoice_Delivery_Type__c = 'Email';

    }
    
    public static testmethod void testController12(){
        objContract = createAndInsertCloudBillingContract();
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        //objController.objContract = objContract;
        objController.resetServiceInfoFromQuote();
        
        
        List<Product_Tier_Range__c> list_PTRs = [SELECT id FROM Product_Tier_Range__c];
        delete list_PTRs;
        objController.resetServiceInfoFromQuote();
        
        objController.RerateYearMonthSelection = 'test';
        Boolean blntest = objController.blnIsContractSuperUser;
        List<String> listTest = objController.listCarrierDropdown;
        listTest = objController.getList_SelectedPlatformIds();
        objController.setList_SelectedPlatformIds(listTest);
    }
    
    public static testmethod void testController13(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        //objController.objContract = objContract;
        objController.resetServiceInfoFromQuote();
        
        List<Product_Tier_Range__c> list_PTRs = [SELECT id FROM Product_Tier_Range__c];
        delete list_PTRs;
        objController.resetServiceInfoFromQuote();
    }
    
    public static testmethod void testController14(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        List<Product_Tier_Set__c> list_ProductTierSets = [SELECT Name,Product__c,Aggregation_Model__c,Units_Type__c,
                                                                      (SELECT From__c, To__c, Price__c FROM Product_Tier_Ranges__r)
                                                                      FROM Product_Tier_Set__c];
        List<Product_Tier_Range__c> list_PTRs = list_ProductTierSets[0].Product_Tier_Ranges__r;
        delete list_PTRs;
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        //objController.objContract = objContract;
        objController.resetServiceInfoFromQuote();
    }
    
    public static testmethod void testController15(){
        objContract = createAndInsertCloudBillingContract();
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.populateTierSetsAndServices();
        objController.objContract = objContract;
        objController.strTierIndex = '0' ;
        objController.strRowIndex = '0' ;
        objController.addTierRange();
        objController.removeTierRange();
        objController.addRecurringCharge();
        objController.removeRecurringCharge();
        objController.addContractService();
        objController.removeContractService();
        objController.addTierSetAtBottom();
        objController.addTierSetOnTop();
        objController.removeTierSet();
        objController.addBOGODetail();
        objController.removeBOGODetail();
        objController.editBtnHandler();
        objController.populateTierSetsAndServices();
        objController.editBOGOBtnHandler();
        objController.cancelEditBtnHandler();
        objController.cancelEditBOGOBtnHandler();
        objController.populateTierSetsAndServices();
    }
    
    public static testmethod void testController16(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        Contract_Tier_Set__c objTS = [SELECT Id FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.Id LIMIT 1]; 
        List<Contract_Tier_Set__c> list_CTS = setupContractTierSets(objContract.id, [SELECT id, Name FROM Product2 
                                                                                     WHERE APN_Number__c != NULL AND
                                                                                     recordType.Name != 'Base Item' LIMIT 2]);
        insert list_CTS;
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        
        QuoteServiceBillingController.TierSetWrapper objTSW = new QuoteServiceBillingController.TierSetWrapper();
        objController.list_TierSetWrappers = new List<QuoteServiceBillingController.TierSetWrapper>{objTSW};
        objTSW.list_BOGODetails = new List<BOGO_Detail__c>();
        BOGO_Detail__c objBOGO = new BOGO_Detail__c(Parent_Quantity__c = 0);
        objTSW.list_BOGODetails.add(objBOGO);
        objController.saveBOGOBtnHandler();
        objTSW.list_BOGODetails[0].Parent_Quantity__c = 1;
        objTSW.list_BOGODetails[0].Related_Quantity__c = 0;
        objController.saveBOGOBtnHandler();
        objTSW.list_BOGODetails[0].Related_Quantity__c = 1;
        objTSW.list_BOGODetails[0].Related_Tier_Set__c = null;
        objController.saveBOGOBtnHandler();
        objTSW.list_BOGODetails[0].Related_Tier_Set__c = list_CTS[0].id;
        objController.saveBOGOBtnHandler();
        objTSW.list_BOGODetails[0].Parent_Tier_Set__c = list_CTS[0].id;
        objController.saveBOGOBtnHandler();
        objTSW.list_BOGODetails[0].Parent_Tier_Set__c = list_CTS[1].id;
        objTSW.list_BOGODetails[0].Related_Tier_Set__c = objTS.id;
        objController.saveBOGOBtnHandler();
    }
    
    
    public static testmethod void testController18(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        QuoteServiceBillingController.TierSetWrapper objTSW = new QuoteServiceBillingController.TierSetWrapper();
        objController.list_TierSetWrappers = new List<QuoteServiceBillingController.TierSetWrapper>{objTSW};
        objTSW.objContractTierSet = new Contract_Tier_Set__c(Contract__c = objContract.id);
        objController.saveBtnHandler();
        objTSW.objContractTierSet = new Contract_Tier_Set__c(Name = 'Test', Contract__c = objContract.id);
        objController.saveBtnHandler();
        objTSW.objContractTierSet = new Contract_Tier_Set__c(Name = 'Test', Aggregation_Model__c = 'Max Per Month',
                                                             Contract__c = objContract.id);
        objController.saveBtnHandler();
        objTSW.objContractTierSet = new Contract_Tier_Set__c(Name = 'Test', Aggregation_Model__c = 'Max Per Month',
                                                             Units_Type__c = 'Messages/Seats/Ports', Contract__c = objContract.id);
        objController.saveBtnHandler();
        objTSW.objContractTierSet = new Contract_Tier_Set__c(Name = 'Test', Aggregation_Model__c = 'Max Per Month',
                                                            Units_Type__c = 'Messages/Seats/Ports', Period_In_Months__c = '6',
                                                            Contract__c = objContract.id );
        objController.saveBtnHandler();
        Contract_Tier_Range__c objCTR = new Contract_Tier_Range__c();
        objTSW.list_ContractTierRanges = new List<Contract_Tier_Range__c>{objCTR};
        objController.saveBtnHandler();
        objCTR.From__c = 1;
        objController.saveBtnHandler();
        objCTR.To__c = 1;
        objController.saveBtnHandler();
        objCTR.Price__c = 10;
        objController.saveBtnHandler();
        
        Contract_Service__c objCS = new Contract_Service__c();
        objTSW.list_ContractServices = new List<Contract_Service__c>{objCS};
        objController.saveBtnHandler();
        List<Service__c> list_Service = [SELECT id, Active__c FROM Service__c];
        objCS.Service__c = list_Service[0].id;
        objController.saveBtnHandler();
        
        Contract_Recurring_Charge__c objCRC = new Contract_Recurring_Charge__c();
        objTSW.list_ContractRecurringCharges = new List<Contract_Recurring_Charge__c>{objCRC};
        objController.saveBtnHandler();
        objCRC.Pre_Bill__c = true;
        objCRC.Type__c = 'Business Care';
        objController.saveBtnHandler();
        objCRC.Type__c  = 'One Time Flat Fee';
        objController.saveBtnHandler();
        QuoteServiceBillingController.TierSetWrapper objTSW2 = objTSW;
        objController.list_TierSetWrappers.add(objTSW2);
        objController.saveBtnHandler();
        objController.list_TierSetWrappers.remove(1);
        for(Service__c objService : list_Service){
            objService.Active__c = false;
        }
        update list_Service;
        objController.saveBtnHandler();
        
        for(Service__c objService : list_Service){
            objService.Active__c = true;
        }
        update list_Service;
        objCRC.Pre_Bill__c = false;
        objCRC.Type__c = 'Business Care';
        objCRC.Business_Care_Max_Revenue_Threshold__c = 0;
        objController.saveBtnHandler();
        objCRC.Business_Care_Max_Revenue_Threshold__c = 2;
        objController.saveBtnHandler();
        objCTR.To__c = 2;
        objCTR.From__c = 3;
        objController.checkTierRanges();
        objCTR.To__c = 5;
        objCTR.From__c = 1;
        Contract_Tier_Range__c objCTR2 = new Contract_Tier_Range__c();
        objTSW.list_ContractTierRanges.add(objCTR2);
        objCTR2 = objCTR;
        objCTR2.From__c = 8;
        objCTR2.To__c = 9;
        objController.checkTierRanges();
        
        objController.saveLogic();
        objContract.Approved__c = true;
        objController.saveLogic();
    }
    
     public static testmethod void testController19(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        objController.objContract.Status__c = 'In Progress';
        objController.reRateUsageData();
        objController.objContract.Status__c = 'Approved';
        objController.reRateUsageData();
        objController.objRerateLog = new Cloud_Billing_Log__c();
        objController.reRateUsageData();
        objController.objContract.Pricing_Start_Date__c = Date.newInstance(2017,1,1);
        objController.objRerateLog.Month__c = '1';
        objController.objRerateLog.Year__c = '2017';
        objController.objRerateLog.Start_Date__c = Date.newInstance(2017,1,1);
        objController.objRerateLog.End_Date__c = Date.newInstance(2017,12,1);
        objController.reRateUsageData();
     }
     
     public static testmethod void testController20(){
        SureTax_Settings__c objSureTaxSetting = new SureTax_Settings__c(name= 'SureTaxEnabled', value__c = 'false');
        insert objSureTaxSetting;
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        objController.objContract.Status__c = 'In Progress';
        objController.rateUsageData();
        objController.objContract.Status__c = 'Approved';
        objController.rateUsageData();
     }
     
     public static testmethod void testViewUsageReportBoth(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        objController.objLog = new Cloud_Billing_Log__c();
        objController.viewUsageReport();
        objController.viewUsageReportWithBursting();
        objController.objLog = new Cloud_Billing_Log__c(Month__c = '1', Year__c = '2017');
        objController.viewUsageReport();
        objController.viewUsageReportWithBursting();
     }
     
     public static testmethod void testController22(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        
        Account_Order_Address__c objBillingAddress= new Account_Order_Address__c(Quote__c = objContract.Quote__c, Address_Type__c = 'Bill To',
                                                                        GCR_Content_Document_Detail__c = objContract.id );
        insert objBillingAddress;
        objController.objBillingAddress = objBillingAddress;
        
        objController.cloneBtnHandler();
     }
    
    public static testmethod void testhandleManualOrderCreationFailByStatus(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        objContract.Status__c = 'In Progress';
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        
        objController.objRerateLog.Month__c = '10';
        objController.objRerateLog.Year__c = '2017';
        
        objController.handleManualOrderCreation();
    }
    
    public static testmethod void testhandleManualOrderCreationFailByMonth(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        objContract.Status__c = 'Approved';
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        
        objController.objRerateLog.Month__c = '';
        objController.objRerateLog.Year__c = '2017';
        
        objController.handleManualOrderCreation();
    }
    
    public static testmethod void testhandleManualOrderCreation(){
        objContract = createAndInsertCloudBillingContractWithZuoraQuote();
        objContract.Status__c = 'Approved';
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        objController.objContract = objContract;
        
        objController.objRerateLog.Month__c = '10';
        objController.objRerateLog.Year__c = '2017';
        
        objController.handleManualOrderCreation();
    }
    
    static List<Contract_Tier_Set__c> setupContractTierSets(Id contractId , List<Product2> list_Products){
        List<Contract_Tier_Set__c> list_ContractTS = new List<Contract_Tier_Set__c>();
        for(Product2 objProd : list_Products){
            list_ContractTS.add( new Contract_Tier_Set__c(Name = 'Test '+objProd.Name , 
                                                          Product__c = objProd.id ,
                                                          Period_In_Months__c = '6', 
                                                          Contract__c = contractId , Is_Deleted__c = false ,
                                                           Units_Type__c = 'Messages/Seats/Ports') );
        }
        return list_ContractTS;
    }
    
    public static Genesys_Entity__c setupGenesysEntity(){
        Genesys_Entity__c objGenEntity = new Genesys_Entity__c();
        objGenEntity.Remit_To__c = 'Test Remit To Info';
        objGenEntity.Selling_Entity__c = 'Test Selling Entity Info';
        objGenEntity.CurrencyIsoCode = 'USD';
        insert objGenEntity;
        return objGenEntity;
    }
    
    private static List<Product_Tier_Set__c> setupProductTierSets(List<Product2> list_Products){
        List<Product_Tier_Set__c> list_PTS = new List<Product_Tier_Set__c>();
        
        for(Product2 objProduct : list_Products){
            Product_Tier_Set__c objPTS = new Product_Tier_Set__c(Aggregation_Model__c = 'Max Per Month' , 
                                                                 Product__c = objProduct.Id, Units_Type__c = 'Minutes(Actual)',
                                                                 Name = objProduct.Name);
            list_PTS.add(objPTS);
        }
        insert list_PTS;
        return list_PTS;
    }
    
    private static List<Product_Tier_Range__c> setupProductTierRange(List<Product_Tier_Set__c> list_PTS){
        List<Product_Tier_Range__c> list_PTRs = new List<Product_Tier_Range__c>();
        
        for(Product_Tier_Set__c objPTS : list_PTS){
            Product_Tier_Range__c objPTR = new Product_Tier_Range__c(From__c = 1, Price__c = 10,
                                                                     Product_Tier_Set__c = objPTS.id, To__c = 4 );
            list_PTRs.add(objPTR);
        }
        
        insert list_PTRs;
        return list_PTRs;
    }
    
    private static List<Product_Tier_Set_Service__c> setupProductTierSetService(List<Product_Tier_Set__c> list_PTS){
        List<Product_Tier_Set_Service__c> list_PTSS = new List<Product_Tier_Set_Service__c>();
        TestcloudBillingRating.insertServices();
        List<Service__c> list_Service = [SELECT id FROM Service__c];
        
        
        for(Product_Tier_Set__c objPTS : list_PTS){
            Product_Tier_Set_Service__c objPTSS = new Product_Tier_Set_Service__c(Product_Tier_Set__c = objPTS.id, Service__c = list_Service[0].id );
            list_PTSS.add(objPTSS);
        }
        
        insert list_PTSS;
        return list_PTSS;
    }
    
    private static List<Product_Recurring_Charge__c> setupProductRecurringCharge(List<Product_Tier_Set__c> list_PTS){
        List<Product_Recurring_Charge__c> list_PRC = new List<Product_Recurring_Charge__c>();
        
        for(Product_Tier_Set__c objPTS : list_PTS){
            Product_Recurring_Charge__c objPRC = new Product_Recurring_Charge__c(Amount__c = 10.0, Charge_Description__c = 'None',
                                                                     Product_Tier_Set__c = objPTS.id, Type__c = 'Monthly Flat Fee' );
            list_PRC.add(objPRC);
        }
        
        insert list_PRC;
        return list_PRC;
    }
    
    public static GCR_Content_Document_Detail__c createAndInsertCloudBillingContractWithZuoraQuote() {
        Util.Bypass_Trigger_Chk = true;
        // Create an Account ind insert it
        Account acct = createAccountWithGARN();
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,acct.id, false)[0];
        objOpportunity.Lines_of_Businesses__c = 'PureCloud';
        objOpportunity.Offering_Detail__c = 'Pilot/Trial/POC';
        insert objOpportunity;
        
        zqu__Quote__c objQuote = CloudBillingTestUtil.setupZuoraQuote(
                                    'PureCloud Test ZQuote 1', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote.zqu__StartDate__c = Date.newInstance(2017,1,1);
        objQuote.PureCloud_Ramp_Up_Period__c = 1;
        objQuote.CurrencyISOCode = 'USD';
        insert objQuote;
        
        Genesys_Entity__c objGenEntity = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        GCR_Content_Document_Detail__c objContract = BatchCreateCloudMonthlySalesOrdersTest.setupContractsZ(objQuote);
        objContract.Genesys_Entity__c = objGenEntity.id;
        objContract.Status__c = 'Approved';
        insert objContract;
        
        List<Product2> list_Products = TestUtil.createProducts(5,false,false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
        }
        insert list_Products;
        Order__c objOrder = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(objContract);
        objOrder.Order_Date__c = System.today();
        objOrder.CurrencyIsoCode = 'USD';
        objOrder.Zuora_Quote__c = objQuote.Id;
        insert objOrder;
        
        List<Order_Line_Item__c> list_OLIs = TestUtil.createOrderLines(list_Products, objOrder.Id, true);
        
        List<Product_Tier_Set__c> list_PTS = setupProductTierSets(list_Products);
        
        List<Product_Tier_Range__c> list_PTRs = setupProductTierRange(list_PTS);
        
        List<Product_Tier_Set_Service__c> lis_PTSS = setupProductTierSetService(list_PTS);
        
        List<Product_Recurring_Charge__c> list_PRD = setupProductRecurringCharge(list_PTS);
        
        
        Cloud_Deployment__c cd = new Cloud_Deployment__c(Account__c = acct.Id, Tenant_ID__c = 'Tenant123');
        insert cd;
        System.Debug('testContractCreationAndRating: Save of Cloud Deployment ' + cd);
        Cloud_Deployment_To_Contract_Junction__c objCDCJ = new Cloud_Deployment_To_Contract_Junction__c(Contract__c = objContract.Id, Cloud_Deployment__c = cd.Id);
        insert objCDCJ;

        Contract_Tier_Set__c objTierSet = insertContractTierSetInbound(objContract.Id);
        //insert objTierSet;
        List<Contract_Tier_Range__c> list_range = new List<Contract_Tier_Range__c>();
        Contract_Tier_Range__c range1 = new Contract_Tier_Range__c(From__c = 0, To__c = 9999,Price__c = 1.23,Contract_Tier_Set__c = objTierSet.Id);
        
        Contract_Recurring_Charge__c objRecurringCharge1 = new Contract_Recurring_Charge__c(Contract_Tier_Set__c = objTierSet.Id);
                
        return objContract;
    }
    
    // 
    public static List<zqu__QuoteChargeDetail__c> setupZuoraQuoteChargeDetails(){
        return null;
    }
    
    //Added By Vijay - End Jul 26th 2017
    
    @TestSetup
    static void setupData() {
        //objContract = createAndInsertCloudBillingContract();
        //insert objContract;
    }
    
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
    
    
    
    public static GCR_Content_Document_Detail__c createAndInsertCloudBillingContract(/*(List<Rolled_Up_Usage_Data__c> list_ruud*/) {
        Util.Bypass_Trigger_Chk = true;
        // Create an Account ind insert it
        Account acct = createAccountWithGARN();
        BigMachines__Quote__c quot = new BigMachines__Quote__c();
        quot.offering_type__c = 'PureConnect Subscription';
        insert quot;
        List<Product2> list_Products = TestUtil.createProducts(5,true,false);
        
        /*
        for(Product2 objProd : list_Products ){
            objProd.Type__c = 'Genesys Care';
        }
        insert list_Products;
        */
        List<BigMachines__Quote_Product__c> list_QuoteProducts = TestUtil.createQuoteProducts(list_Products,false);
        
        for(BigMachines__Quote_Product__c objQP : list_QuoteProducts){
            objQP.BigMachines__Product__c = objQP.Product__c;
            objQP.BigMachines__Quote__c = quot.id;
        }
        insert list_QuoteProducts;
        List<Product_Tier_Set__c> list_PTS = setupProductTierSets(list_Products);
        
        List<Product_Tier_Range__c> list_PTRs = setupProductTierRange(list_PTS);
        
        List<Product_Tier_Set_Service__c> lis_PTSS = setupProductTierSetService(list_PTS);
        
        List<Product_Recurring_Charge__c> list_PRD = setupProductRecurringCharge(list_PTS);
        
        GCR_Content_Document_Detail__c contract = new GCR_Content_Document_Detail__c(Pricing_Start_Date__c = Date.newInstance(2015,1,1),
                                                                                     Account_Name__c = acct.Id, 
                                                                                     Status__c = 'Approved',
                                                                                     Quote__c = quot.id);
        insert contract;
        System.Debug('createAndInsertCloudBillingContract: Contract: ' + contract);
        Cloud_Deployment__c cd = new Cloud_Deployment__c(Account__c = acct.Id, Tenant_ID__c = 'Tenant123');
        insert cd;
        System.Debug('testContractCreationAndRating: Save of Cloud Deployment ' + cd);
        Cloud_Deployment_To_Contract_Junction__c objCDCJ = new Cloud_Deployment_To_Contract_Junction__c(Contract__c = contract.Id, Cloud_Deployment__c = cd.Id);
        insert objCDCJ;

        Contract_Tier_Set__c objTierSet = insertContractTierSetInbound(contract.Id);
        //insert objTierSet;
        List<Contract_Tier_Range__c> list_range = new List<Contract_Tier_Range__c>();
        Contract_Tier_Range__c range1 = new Contract_Tier_Range__c(From__c = 0, To__c = 9999,Price__c = 1.23,Contract_Tier_Set__c = objTierSet.Id);
        
        Contract_Recurring_Charge__c objRecurringCharge1 = new Contract_Recurring_Charge__c(Contract_Tier_Set__c = objTierSet.Id);
        /*
         *         public TierSetWrapper(Contract_Tier_Set__c objContractTierSet,List<Contract_Tier_Range__c> list_ContractTierRanges,
                              List<Contract_Service__c> list_ContractServices,List<Contract_Recurring_Charge__c> list_ContractRecurringCharges,
                              List<BOGO_Detail__c> list_BOGODetails)
         */        
        return contract;
    }
    
    
    
    
    private static Contract_Tier_Set__c insertContractTierSetInbound(Id idContract) {
        Contract_Tier_Set__c objContractTierSet = new Contract_Tier_Set__c(
            Name = 'Calling',
            Aggregation_Model__c = 'Step',
            Period_In_Months__c = '1',
            RC_Period__c = '1',
            Units_Type__c = 'Minutes(60s ceiling)',
            Is_Deleted__c = false,
            Contract__c = idContract
        );
        insert objContractTierSet;
        return objContractTierSet;
    }
    @isTest
    public static void testGlobalVariables() {
        Util.Bypass_Trigger_Chk = true;
        objContract = createAndInsertCloudBillingContract();
        System.debug('objContract: ' + objContract);
        
        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);

        QuoteServiceBillingController objQuoteServiceBillingController = new QuoteServiceBillingController(stdController);
        objQuoteServiceBillingController.Attach = Blob.valueOf('blob');
        objQuoteServiceBillingController.strUploadedfileName = 'filename.txt';
        objQuoteServiceBillingController.list_contractAttachments = new List<Attachment>();
    }
    @isTest
    public static void testCommitmentWrapper() {
        Util.Bypass_Trigger_Chk = true;
        objContract = createAndInsertCloudBillingContract();
        System.debug('objContract: ' + objContract);
        Billing_Setup_Commitment__c objBillingSetupCommitment = new Billing_Setup_Commitment__c(
            Billing_Setup__c = objContract.Id,
            Committed_Amount__c = 100
        );
        insert objBillingSetupCommitment;
        List<Contract_Tier_Set__c> list_ContractTierSets = [select id, Name from Contract_Tier_Set__c where Contract__c = :objContract.Id];
        List<Billing_Setup_Commitment_Tier_Set__c> listBillingSetupCommitmentTierSet = new List<Billing_Setup_Commitment_Tier_Set__c>();
        for (Contract_Tier_Set__c objContractTierSet : list_ContractTierSets) {
            System.Debug('testCommitmentWrapper: ' + objContractTierSet);
            Billing_Setup_Commitment_Tier_Set__c objBillingSetupCommitmentTierSet = new Billing_Setup_Commitment_Tier_Set__c (
				Billing_Setup_Commitment__c = objBillingSetupCommitment.Id,
				Billing_Setup_Tier_Set__c = objContractTierSet.Id
            );
            listBillingSetupCommitmentTierSet.add(objBillingSetupCommitmentTierSet);
        }
        insert listBillingSetupCommitmentTierSet;

        PageReference pageRef= Page.QuoteServiceBilling;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', objContract.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(objContract);
        QuoteServiceBillingController objController = new QuoteServiceBillingController(stdController);
        //objController.saveContract();
        objController.upsertBillingCommitments();
    }

}