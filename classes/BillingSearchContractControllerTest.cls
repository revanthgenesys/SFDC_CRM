/**
 * Class Name               : BillingSearchContractControllerTest
 * Test Covered class(es)   : BillingSearchContractController
 * Description              : This Class is utilized to make a unit test coverage for BillingSearchContractController Apex class.
 * Util Class utilized      : TestUtil, BatchCreateCloudMonthlySalesOrdersTest
 * Created By               : Vijay Gopi
 * Created Date             : Jul 25th 2017
 */
@isTest
private class BillingSearchContractControllerTest {

    @testsetup
    static void setupData() {
        SureTax_Settings__c objSureTaxSetting = new SureTax_Settings__c(name = 'SureTaxEnabled', value__c = 'false');
        insert objSureTaxSetting;
        
        Util.Bypass_Trigger_Chk = true;
        Country__c objCountry = setupCountry();
        Subsidary__c objSubsidary = new Subsidary__c(Active__c = true,
                                                     Name = '8100',
                                                     Billing_Invoice_Footer__c = 'Invoice Footer Data',
                                                     Country__c = objCountry.Id,
                                                     Description__c = '8100'
        );
        insert objSubsidary;

        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        list_Accounts[0].country__c =objCountry.id;
        list_Accounts[0].Subsidary__c = objSubsidary.Id;
        insert list_Accounts;
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunity.Lines_of_Businesses__c = 'PureCloud';
        objOpportunity.Country__c = objCountry.Id;
        insert objOpportunity;
        
        zqu__Quote__c objQuote = BatchCreateCloudMonthlySalesOrdersTest.setupZuoraQuote(
                                    'PureCloud Test ZQuote 1', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote.zqu__StartDate__c = System.today()- 730; 
        zqu__Quote__c objQuote2 = BatchCreateCloudMonthlySalesOrdersTest.setupZuoraQuote(
                                    'PureCloud Test ZQuote 2', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote2.zqu__StartDate__c = System.today()- 730; 
        zqu__Quote__c objQuote3 = BatchCreateCloudMonthlySalesOrdersTest.setupZuoraQuote(
                                    'PureCloud Test ZQuote 3', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote3.zqu__StartDate__c = System.today()- 730; 
        zqu__Quote__c objQuote4 = BatchCreateCloudMonthlySalesOrdersTest.setupZuoraQuote(
                                    'PureCloud Test ZQuote 4', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote4.zqu__StartDate__c = System.today()- 730; 
        List<zqu__Quote__c> list_Quotes = new List<zqu__Quote__c>{objQuote, objQuote2,objQuote3, objQuote4};
        insert list_Quotes;
        
        Genesys_Entity__c objGenEntity = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        GCR_Content_Document_Detail__c objContract = BatchCreateCloudMonthlySalesOrdersTest.setupContractsZ(list_Quotes[0]);
        objContract.Genesys_Entity__c = objGenEntity.id;
        objContract.Status__c = 'New';
        GCR_Content_Document_Detail__c objContract2 = BatchCreateCloudMonthlySalesOrdersTest.setupContractsZ(list_Quotes[1]);
        objContract2.Genesys_Entity__c = objGenEntity.id;
        objContract2.Status__c = 'In Progress';
        GCR_Content_Document_Detail__c objContract3 = BatchCreateCloudMonthlySalesOrdersTest.setupContractsZ(list_Quotes[2]);
        objContract3.Genesys_Entity__c = objGenEntity.id;
        objContract3.Status__c = 'Awaiting Approval';
        GCR_Content_Document_Detail__c objContract4 = BatchCreateCloudMonthlySalesOrdersTest.setupContractsZ(list_Quotes[3]);
        objContract4.Genesys_Entity__c = objGenEntity.id;
        objContract4.Status__c = 'Hold';
        List<GCR_Content_Document_Detail__c> list_Contracts = new List<GCR_Content_Document_Detail__c>{objContract, objContract2,
                                                                                                    objContract3, objContract4};
        insert list_Contracts;
        
        List<Cloud_Deployment__c> list_CloudDeployments = setupCloudDeployments(list_Contracts);
        
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
        }
        insert list_Products;
        
        Order__c objOrder = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(list_Contracts[0]);
        objOrder.Order_Date__c = System.today();
        objOrder.CurrencyIsoCode = 'USD';
        Order__c objOrder2 = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(list_Contracts[1]);
        objOrder2.Order_Date__c = System.today();
        objOrder2.CurrencyIsoCode = 'USD';
        Order__c objOrder3 = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(list_Contracts[2]);
        objOrder3.Order_Date__c = System.today();
        objOrder3.CurrencyIsoCode = 'USD';
        Order__c objOrder4 = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(list_Contracts[3]);
        objOrder4.Order_Date__c = System.today();
        objOrder4.CurrencyIsoCode = 'USD';
        List<Order__c> list_Orders = new List<Order__c>{objOrder,objOrder2,objOrder3,objOrder4};
        insert list_Orders;
        
        List<BigMachines__Quote__c> listtestBMQuote = TestDataFactoryForQuoteTool.createQuotes(objOpportunity.id,list_Accounts[0].id,1);
        listtestBMQuote[0].offering_type__c = 'PureConnect Subscription';
        update listtestBMQuote[0];
        Order__c objOrder5 = objOrder4.clone();
        objOrder5.quote__c = listtestBMQuote[0].id;
        objOrder5.Contract_Lookup__c = NULL;
        insert objOrder5;
    }
    
    private static testmethod void controllerTest1(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.upgradeDowngradeSelectedField = 'All';
        objBSCC.getSortDirectionToBillingContract();
        objBSCC.getSortDirectionToUpgradeDowngrade();
        //objBSCC.setSortDirectionToUpgradeDowngrade('ASC');
        objBSCC.isUserSearchingFromCloudDeployment();
        objBSCC.isUserSearchingForContract();
        objBSCC.strAccountName = 'Test';
        objBSCC.searchFromCloudDeployment();
        objBSCC.search();
        objBSCC.runReportRequests();
        objBSCC.runReconcileJob();
        objBSCC.runRatingJob();
        objBSCC.blnProperOptions();
        objBSCC.runOrderCreationJob();
        objBSCC.runInvoiceCreationJob();
        objBSCC.sendInvoicesHandler();
        objBSCC.viewOrdersByMonth();
        objBSCC.viewInvoicesByMonth();
        objBSCC.viewReconciliationByMonth();
        objBSCC.viewInstallmentOrdersByMonth();
        objBSCC.viewDeferredOrdersByMonth();
        objBSCC.markOrderAsSynced();
        objBSCC.createBillingContract();
        objBSCC.fetchBillingContractBySearchValue();
        objBSCC.clearBillingContractBySearchValue();
        objBSCC.fecthUpgradeDowngradeBySearchValue();
        objBSCC.clearUpgradeDowngradeBySearchValue();
        objBSCC.sortExpressionOnMasterOrderList = 'ASC';
        objBSCC.sortExpressionOnMasterOrderList = 'DESC';
        objBSCC.sortExpressionOnUpgradeDowngradeOrderList = 'ASC';
        objBSCC.sortExpressionOnUpgradeDowngradeOrderList = 'DESC';
        Test.stopTest();
    }
    
    private static testmethod void controllerTest2(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.upgradeDowngradeSelectedField = 'All';
        objBSCC.strSubscriberId = 'Test';
        objBSCC.strTenantId = 'Test';
        objBSCC.strPorticoId = 'Test';
        objBSCC.strPureConnectId = 'Test';
        objBSCC.strPureCloudId = 'Test';
        objBSCC.searchFromCloudDeployment();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest3(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.upgradeDowngradeSelectedField = 'All';
        objBSCC.strContractName = 'Test';
        objBSCC.strGARNCode = 'Test';
        objBSCC.strAccountName = 'Test';
        objBSCC.searchFromCloudDeployment();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest4(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.upgradeDowngradeSelectedField = 'All';
        objBSCC.strPureConnectId = '#';
        objBSCC.searchFromCloudDeployment();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest5(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strContractName = 'Test';
        objBSCC.strSubscriberId = 'Test';
        objBSCC.strTenantId = 'Test';
        objBSCC.strGARNCode = 'GARN TEST';
        objBSCC.strAccountName = 'Test';
        objBSCC.strRegionContractFilter = 'NA';
        
        objBSCC.search();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest6(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strRegionContractFilter = 'NA';
        objBSCC.fetchAccountBillingInfo();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest7(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Month__c = '';
        objBSCC.runReportRequests();
        Test.stopTest();
    }
    
    // Fail test for Order creation Job
    private static testmethod void controllerTest8(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1];
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.runOrderCreationJob();
        Test.stopTest();
    }
    
    // Success test for Order creation Job
    private static testmethod void controllerTest9(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1];
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.objJobLog.Day__c = System.today().day()+'';
        objBSCC.objJobLog.Month__c = '6';
        objBSCC.objJobLog.Year__c = '2017';
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.runOrderCreationJob();
        Test.stopTest();
    }
    
    // Fail test for Order creation Job - Order already exist with this contract
    private static testmethod void controllerTest10(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id, Account_Name__c , Zuora_Quote__r.zqu__Opportunity__c
                                                      FROM GCR_Content_Document_Detail__c LIMIT 1];
        Order__c objOrder = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(objContract);
        objOrder.Order_Date__c = System.today();
        objOrder.CurrencyIsoCode = 'USD';
        objOrder.Status__c = 'Approved';
        Util.Bypass_Trigger_Chk = true;
        insert objOrder;
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.objJobLog.Day__c = System.today().day()+'';
        objBSCC.objJobLog.Month__c = '6';
        objBSCC.objJobLog.Year__c = '2017';
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.runOrderCreationJob();
        Test.stopTest();
    }
    
    // Success Order creation
    private static testmethod void controllerTest11(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = null;
        objBSCC.objJobLog.Day__c = System.today().day()+'';
        objBSCC.objJobLog.Month__c = '6';
        objBSCC.objJobLog.Year__c = '2017';
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.runOrderCreationJob();
        Test.stopTest();
    }
    
    // Fail test for Invoice creation Job
    private static testmethod void controllerTest12(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1];
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.runInvoiceCreationJob();
        Test.stopTest();
    }
    
    // Success test for Invoce creation Job
    private static testmethod void controllerTest13(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1];
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.objJobLog.Day__c = System.today().day()+'';
        objBSCC.objJobLog.Month__c = '6';
        objBSCC.objJobLog.Year__c = '2017';
        objBSCC.runInvoiceCreationJob();
        Test.stopTest();
    }
    
    // Fail test for Invoice Distribution via email  Handler Job
    private static testmethod void controllerTest14(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1];
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.sendInvoicesHandler();
        Test.stopTest();
    }
    
    // Success test for Invoice Distribution via email  Handler Job
    private static testmethod void controllerTest15(){
        Test.startTest();
        GCR_Content_Document_Detail__c objContract = [SELECT id FROM GCR_Content_Document_Detail__c LIMIT 1];
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Contract__c = objContract.id;
        objBSCC.strRegion = 'All';
        objBSCC.strEdition = 'All';
        objBSCC.strSubscriberId = 'All';
        objBSCC.objJobLog.Month__c = '6';
        objBSCC.objJobLog.Year__c = '2017';
        objBSCC.sendInvoicesHandler();
        Test.stopTest();
    }
    
    // Page Errors - Month or Year not provided.
    private static testmethod void controllerTest16(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Month__c = '';
        objBSCC.viewOrdersByMonth();
        objBSCC.viewInvoicesByMonth();
        objBSCC.viewReconciliationByMonth();
        objBSCC.viewInstallmentOrdersByMonth();
        objBSCC.viewDeferredOrdersByMonth();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest17(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strRegionContractFilter = 'NA';
        objBSCC.upgradeDowngradeSearchQuery = ' AND Quote__r.End_User_ID__r.Name LIKE \'%test%\' ';
        objBSCC.sortOnUpgradeDowngrade = 'Quote__r.End_User_ID__r.Name';
        objBSCC.sortDirectionToUpgradeDowngrade = 'ASC';
        objBSCC.fetchUpgradesDowngrades();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest18(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strRegionContractFilter = 'NA';
        objBSCC.billingContractSearchQuery = ' AND Offering_Type__c LIKE  \'%test%\' ';
        objBSCC.sortOnBillingContract = 'Quote__r.End_User_ID__r.Name';
        objBSCC.sortDirectionToBillingContract = 'ASC';
        objBSCC.fetchNewMasterOrders();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest19(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strRegionContractFilter = 'NA';
        objBSCC.billingContractSearchQuery = ' AND Offering_Type__c LIKE  \'%test%\' ';
        objBSCC.sortOnBillingContract = 'Quote__r.End_User_ID__r.Name';
        objBSCC.sortDirectionToBillingContract = 'ASC';
        objBSCC.sortOnBillingContract = 'Account';
        objBSCC.fetchNewMasterOrders();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest20(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strRegionContractFilter = 'NA';
        objBSCC.billingContractSearchQuery = ' AND Offering_Type__c LIKE  \'%test%\' ';
        objBSCC.sortOnBillingContract = 'Quote__r.End_User_ID__r.Name';
        objBSCC.sortDirectionToBillingContract = 'ASC';
        objBSCC.sortOnBillingContract = 'Opportunity';
        objBSCC.fetchNewMasterOrders();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest21(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strRegionContractFilter = 'NA';
        objBSCC.billingContractSearchQuery = ' AND Offering_Type__c LIKE  \'%test%\' ';
        objBSCC.sortOnBillingContract = 'Quote__r.End_User_ID__r.Name';
        objBSCC.sortDirectionToBillingContract = 'ASC';
        objBSCC.sortOnBillingContract = 'Quote';
        objBSCC.fetchNewMasterOrders();
        Test.stopTest();
    }
    
    private static testmethod void controllerTest22(){
        GCR_Content_Document_Detail__c objContract = [SELECT id, Account_Name__c , Zuora_Quote__r.zqu__Opportunity__c
                                                      FROM GCR_Content_Document_Detail__c LIMIT 1];
        Order__c objOrder = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(objContract);
        objOrder.Order_Date__c = System.today();
        objOrder.CurrencyIsoCode = 'USD';
        objOrder.Status__c = 'Approved';
        Util.Bypass_Trigger_Chk = true;
        insert objOrder;
        Map<String,Order__c> map_Orders = new Map<String,Order__c>([SELECT Id, Name, Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__c,
                                                                     Zuora_Quote__r.zqu__Account__c,
                                                                     Quote__c, Quote__r.BigMachines__Opportunity__c, Quote__r.End_User_ID__c,
                                                                     CreatedDate, Offering_Type__c, PO_Number__c, End_User_Name__r.Country__r.Region__c,
                                                                     Quote__r.Name, Zuora_Quote__r.Name, 
                                                                     Quote__r.End_User_ID__r.Name, Zuora_Quote__r.zqu__Account__r.Name,
                                                                     Quote__r.BigMachines__Opportunity__r.Name, Zuora_Quote__r.zqu__Opportunity__r.Name 
                                                                     FROM Order__c]);
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.getOrderMap(map_Orders.values() , 'Account');
        objBSCC.getOrderMap(map_Orders.values() , 'Opportunity');
        objBSCC.getOrderMap(map_Orders.values() , 'Quote');
        objBSCC.getSortedOrderList(map_Orders, 'ASC');
        objBSCC.getSortedOrderList(map_Orders, 'DESC');
        Test.stopTest();
    }
    
    // Fail Create Billing Contract
    private static testmethod void controllerTest23(){
        GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c, Document_Name__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Status__c = 'Approved';
        objContract.Document_Name__c = 'Cloud Billing Contract';
        update objContract;
        
        List<Order__c> list_Orders = [SELECT Id, Name, Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__c,
                                     Zuora_Quote__r.zqu__Account__c,
                                     Quote__c, Quote__r.BigMachines__Opportunity__c, Quote__r.End_User_ID__c,
                                     CreatedDate, Offering_Type__c, PO_Number__c, End_User_Name__r.Country__r.Region__c,
                                     Quote__r.Name, Zuora_Quote__r.Name, 
                                     Quote__r.End_User_ID__r.Name, Zuora_Quote__r.zqu__Account__r.Name,
                                     Quote__r.BigMachines__Opportunity__r.Name, Zuora_Quote__r.zqu__Opportunity__r.Name 
                                     FROM Order__c WHERE Contract_Lookup__c = :objContract.Id  LIMIT 1 ];
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strOrderId = list_Orders[0].id;
        objBSCC.list_NewMasterOrders = list_Orders;
        objBSCC.createBillingContract();
        Test.stopTest();
    }
    
    // Success Create Billing Contract
    private static testmethod void controllerTest24(){
        GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c, Document_Name__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Status__c = 'In Progress';
        objContract.Document_Name__c = 'Cloud Billing Contract';
        update objContract;
        
        List<Order__c> list_Orders = [SELECT Id, Name, Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__c,
                                     Zuora_Quote__r.zqu__Account__c,
                                     Quote__c, Quote__r.BigMachines__Opportunity__c, Quote__r.End_User_ID__c,
                                     CreatedDate, Offering_Type__c, PO_Number__c, End_User_Name__r.Country__r.Region__c,
                                     Quote__r.Name, Zuora_Quote__r.Name, 
                                     Quote__r.End_User_ID__r.Name, Zuora_Quote__r.zqu__Account__r.Name,
                                     Quote__r.BigMachines__Opportunity__r.Name, Zuora_Quote__r.zqu__Opportunity__r.Name 
                                     FROM Order__c WHERE Contract_Lookup__c = :objContract.Id  LIMIT 1 ];
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strOrderId = list_Orders[0].id;
        objBSCC.list_NewMasterOrders = list_Orders;
        objBSCC.createBillingContract();
        Test.stopTest();
    }
    
    //Anju May 2018 changes for PCS and PES subscription
    private static testmethod void controllerTest25(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.handleViewExceptionReports();
        objBSCC.setSortDirectionToBillingContract('test');
        objBSCC.setSortDirectionToUpgradeDowngrade('test');
        objBSCC.runOrderLineItemTaxJob();
        
        List<Order__c> list_Orders = [SELECT Id, Name, Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__c,
                                     Zuora_Quote__r.zqu__Account__c,Contract_Lookup__c,
                                     Quote__c, Quote__r.BigMachines__Opportunity__c, Quote__r.End_User_ID__c,
                                     CreatedDate, Offering_Type__c, PO_Number__c, End_User_Name__r.Country__r.Region__c,
                                     Quote__r.Name, Zuora_Quote__r.Name, Quote__r.CurrencyIsoCode,
                                     Quote__r.End_User_ID__r.Name, Zuora_Quote__r.zqu__Account__r.Name,
                                     Quote__r.BigMachines__Opportunity__r.Name, Zuora_Quote__r.zqu__Opportunity__r.Name 
                                     FROM Order__c WHERE Quote__r.Offering_Type__c = 'PureConnect Subscription' AND Contract_Lookup__c = NULL LIMIT 1 ];
        
        system.debug(list_Orders);
        if(list_Orders.size() > 0)
        {
            objBSCC.strOrderId = list_Orders[0].id;
            objBSCC.list_NewMasterOrders = list_Orders;
            objBSCC.createBillingContract();
        } 
        
        SureTax_Settings__c objSureTax = [Select id from SureTax_Settings__c limit 1];
        objSureTax.Value__c = 'True';
        update objSureTax;
        objBSCC.runOrderLineItemTaxJob();
        Test.stopTest();
    }
    private static testmethod void testSortExpression(){
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        System.debug(objBSCC.sortExpressionOnRenewalOrderList);
    }
    private static testmethod void testRunOrderLineItemTaxJobAll(){
        // Turn on SureTax
        insert SureTaxSettingsFactory.createDefaultSureTaxSettings();

        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.strSubsidiary = '8100';
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Day__c = '1';
        objBSCC.objJobLog.Month__c = '9';
        objBSCC.objJobLog.Year__c = '2018';
        objBSCC.runOrderLineItemTaxJob();
        /*strSubsidiary) && objJobLog.Contract__c == null && String.isBlank(strRegion) && String.isBlank(strEdition))
         */
    }

    private static testmethod void testRunOrderLineItemTaxJobContractGood(){
        // Turn on SureTax
        insert SureTaxSettingsFactory.createDefaultSureTaxSettings();

        BillingSearchContractController objBSCC = new BillingSearchContractController();
        GCR_Content_Document_Detail__c objContract = [select Account_Name__r.Subsidary__r.Name
                                                      from GCR_Content_Document_Detail__c
                                                      LIMIT 1];
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.strSubsidiary = '8100';
        objBSCC.objJobLog.Day__c = '1';
        objBSCC.objJobLog.Month__c = '9';
        objBSCC.objJobLog.Year__c = '2018';
        if (objContract != null) {
            objBSCC.objJobLog.Contract__c = objContract.Id;
			objBSCC.runOrderLineItemTaxJob();
        } else {
            System.Debug('testRunOrderLineItemTaxJobContract: No Contracts in System');
        }
    }

    private static testmethod void testRunOrderLineItemTaxJobContractBadSubsidary(){
        // Turn on SureTax
        insert SureTaxSettingsFactory.createDefaultSureTaxSettings();

        BillingSearchContractController objBSCC = new BillingSearchContractController();
        GCR_Content_Document_Detail__c objContract = [select Account_Name__r.Subsidary__r.Name
                                                      from GCR_Content_Document_Detail__c
                                                      LIMIT 1];
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.strSubsidiary = '9999';
        objBSCC.objJobLog.Day__c = '1';
        objBSCC.objJobLog.Month__c = '9';
        objBSCC.objJobLog.Year__c = '2018';
        if (objContract != null) {
            objBSCC.objJobLog.Contract__c = objContract.Id;
			objBSCC.runOrderLineItemTaxJob();
        } else {
            System.Debug('testRunOrderLineItemTaxJobContract: No Contracts in System');
        }
    }
    
    private static testmethod void testBustExpectedFiles(){
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Month__c = '9';
        objBSCC.objJobLog.Year__c = '2018';
		objBSCC.viewPureConnectBurstExpectedFilesCS();
		objBSCC.viewPureEngageBurstExpectedFilesCS();
    }

    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                                Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                                New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
    
    
    static List<Cloud_Deployment__c> setupCloudDeployments(List<GCR_Content_Document_Detail__c> list_Contracts){
        List<Cloud_Deployment__c> list_CloudDeployments = new List<Cloud_Deployment__c>();
        
        for(GCR_Content_Document_Detail__c objContract : list_Contracts){
            Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
            objCloudDeployment.Account__c = objContract.Account_Name__c;
            objCloudDeployment.Cloud_Platform__c = 'PureCloud';
            objCloudDeployment.PureCloud_OrgID__c = objContract.Account_Name__c + '#'+ objContract.id ;
            list_CloudDeployments.add(objCloudDeployment);
        }
        insert list_CloudDeployments;
        return list_CloudDeployments;
    }
}