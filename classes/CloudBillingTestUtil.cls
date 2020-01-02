@isTest
public class CloudBillingTestUtil {

        public static Contract_Tier_Set__c insertContractTierSetInbound(Id idContract) {
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
        
        Contract_Tier_Range__c objContractTierRange = new Contract_Tier_Range__c (
            Contract_Tier_Set__c = objContractTierSet.Id,
            From__c = 0,
            To__c = 1000,
            Is_Deleted__c = false,
            Price__c = 10
        );
        
        insert objContractTierRange;
        
        return objContractTierSet;
    }

    public static Account createAccountWithGARN() {
        System.Debug('createAccount: Create an Account');
        List<Account> list_accts = TestUtil.createAccounts(1, true);
        System.Debug('createAccount: Retrieve the inserted Account');
        Account acct = list_accts[0];
        
        //Add Needed information for rating
        acct.SAP_Account_Code__c = 'GARN123';
        upsert acct;
        return acct;
    }
    private static List<Contract_Tier_Set_Period__c> insertContractTierSetPeriods(List<Contract_Tier_Set__c> list_ContractTierSets){
        List<Contract_Tier_Set_Period__c> list_ContractTierSetPeriods = new List<Contract_Tier_Set_Period__c>();
        
        for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSets){
            Contract_Tier_Set_Period__c objContractTierSetPeriod = new Contract_Tier_Set_Period__c(); 
            objContractTierSetPeriod.Contract_Tier_Set__c = objContractTierSet.id;
            list_ContractTierSetPeriods.add(objContractTierSetPeriod);
        }
        insert list_ContractTierSetPeriods;
        
        return list_ContractTierSetPeriods;
    }
        public static List<Contract_Tier_Set__c> insertContractTierSets(GCR_Content_Document_Detail__c objContract){
        List<Contract_Tier_Set__c> list_ContractTierSets = new List<Contract_Tier_Set__c>();
        
        for(integer i = 0; i< 3 ; i++){
            list_ContractTierSets.add( new Contract_Tier_Set__c(Contract__c = objContract.id));
        }
        insert list_ContractTierSets;
        
        return list_ContractTierSets;
    }
        public static List<Contract_Tier_Set_Month__c> insertContractTierSetMonths(GCR_Content_Document_Detail__c objContract){
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonths = new List<Contract_Tier_Set_Month__c>();
        List<Contract_Tier_Set__c> list_ContractTierSets = insertContractTierSets(objContract);
        List<Contract_Tier_Set_Period__c> list_ContractTierSetPeriods = insertContractTierSetPeriods(list_ContractTierSets);
        
        for(integer i = 0; i< 3 ; i++){
            Contract_Tier_Set_Month__c objContractTierSetMonth = new Contract_Tier_Set_Month__c();
            objContractTierSetMonth.Contract_Tier_Set__c = list_ContractTierSets[i].id;
            objContractTierSetMonth.Contract_Tier_Set_Period__c = list_ContractTierSetPeriods[i].id;
            list_ContractTierSetMonths.add(objContractTierSetMonth);
        }
        insert list_ContractTierSetMonths;
        
        return list_ContractTierSetMonths;
    }

        public static List<Service_Usage__c> insertServiceUsages(GCR_Content_Document_Detail__c objContract){
        List<Service_Usage__c> list_ServiceUsages = new List<Service_Usage__c>();
        
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonths = insertContractTierSetMonths(objContract);
        
        List<Rolled_Up_Usage_Data__c> list_RolledUpUsageData = new List<Rolled_Up_Usage_Data__c>();
        
        for(integer i = 0; i< 3 ; i++){
            Service_Usage__c objServiceUsage = new Service_Usage__c(Start_Time__c = System.today()-1);
            objServiceUsage.Contract_Tier_Set_Month__c = list_ContractTierSetMonths[i].id;
            
            Rolled_Up_Usage_Data__c objRolledUpUsageData = CloudBillingTestUtil.insertRolledUpUsageDataInboundUS();
            objRolledUpUsageData.Processed__c = true;
            
            objServiceUsage.Rolled_Up_Usage_Data__c = objRolledUpUsageData.Id;
            
            list_RolledUpUsageData.add(objRolledUpUsageData);
            list_ServiceUsages.add(objServiceUsage);
        }
        update list_RolledUpUsageData;

        insert list_ServiceUsages;
        return list_ServiceUsages;
    }

    // Utilising this method in CloudBillingSureTaxTest. Access Specifier should be pulic - Added by Vijay - Jul 13th 2017
    public static GCR_Content_Document_Detail__c createAndInsertCloudBillingContract(List<Rolled_Up_Usage_Data__c> list_ruud) {
        // Create an Account ind insert it
        Account acct = createAccountWithGARN();
        BigMachines__Quote__c quot = new BigMachines__Quote__c();
        insert quot;
        GCR_Content_Document_Detail__c contract = new GCR_Content_Document_Detail__c(Pricing_Start_Date__c = Date.newInstance(2015,1,1),
                                                                                     Account_Name__c = acct.Id, 
                                                                                     Status__c = 'Approved',
                                                                                     Quote__c = quot.id);
        insert contract;
        System.Debug('createAndInsertCloudBillingContract: Contract: ' + contract);
        
        Contract_Tier_Set__c objContractTierSet = insertContractTierSetInbound(contract.Id);
        
        Set<String> setServiceIdentifiers = new Set<String>();
        for (Rolled_Up_Usage_Data__c ruud : list_ruud) {
            setServiceIdentifiers.add(ruud.Service_Identifier__c);
        }
        System.debug('createAndInsertCloudBillingContract: Set Service Identifiers ' + setServiceIdentifiers);
        List<Service__c> list_services = [select Id, Name, Identifier_Hash__c from Service__c where Identifier_Hash__c in :setServiceIdentifiers];
        System.debug('createAndInsertCloudBillingContract: List Services ' + list_services);

        // Current test will add all Services to the one Contract Tier Set for this contract needed to cover the RUUD's
        // Future enhancement of the tests should include separating specific services into different
        // Contract Tier Sets separating activity by different types.
        List<Contract_Service__c> list_contractServices = new List<Contract_Service__c>();
        for (Service__c objService : list_services) {
            Contract_Service__c objContractService = new Contract_Service__c (
                Contract_Tier_Set__c = objContractTierSet.Id,
                Service__c = objService.Id,
                Is_Deleted__c = false
            );
            list_contractServices.add(objContractService);
        }
        insert list_contractServices;
        System.debug('createAndInsertCloudBillingContract: list_contractServices ' + list_contractServices);
        
        return contract;
    }
    
    // Utilising this method in CloudBillingSureTaxTest. Access Specifier should be pulic - Added by Vijay - Jul 13th 2017
    public static List<Rolled_Up_Usage_Data__c> insertRuud() {
        List<Rolled_Up_Usage_Data__c> list_ruud = new List<Rolled_Up_Usage_Data__c>();
        Rolled_Up_Usage_Data__c ruud;
        ruud = insertRolledUpUsageDataInboundUS();
        list_ruud.add(ruud);
        ruud = insertRolledUpUsageDataWirelessOutboundUS();
        list_ruud.add(ruud);
        return list_ruud;
    }
    
    public static Service__c insertServiceInboundUS() {
        Service__c objService = new Service__c(
            Name = 'Inbound Wireline (US)',
            Description__c = 'Inbound Wireline (US)',
            UID__c = 1,
            Channel_Type_Value__c = 1,
            Device_Type_Value__c = 3,
            Service_Type_Value__c = 2,
            Service_Class__c = 0,
            SubCampaign_Type_Value__c = 0,
            Country_Code__c = 1,
            Country_Code_ISO__c = 'US'
        );
        insert objService;
        return objService;
    }
    public static Rolled_Up_Usage_Data__c insertRolledUpUsageDataInboundUS() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Activity_Type__c = 0,
            Source_Name__c = 'BEEEC',
            Platform_Id__c = 'Tenant123',
            Rollup_Id__c = 'test-1',
            Channel_Type__c = 1,
            Device_Type__c = 3,
            Service_Type__c = 2,
            Service_Class__c = 0,
            Origin_Country_Code__c = 1,
            Billable_6__c = 66,
            Billable_30__c = 90,
            Billable_60__c = 120,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0),
            Destination_Device_Career__c = 'test'
        );
        insert ruud;
        Id idRuud = ruud.Id;
        
        // Get the Record again so we get the service identifier formula
        ruud = [select 
                Activity_Type__c,
                Source_Name__c,
                Platform_Id__c,
                Service_Type__c,
                Channel_Type__c,
                Service_Class__c,
                Origin_Country_Code__c,
                Billable_6__c,
                Billable_30__c,
                Billable_60__c,
                Start_Time__c,
                Service_Identifier__c, 
                Inbound_Device__c,
                Destination_Device_Career__c 
                from Rolled_Up_Usage_Data__c
                where Id = :idRuud
               ];
        return ruud;
    }
    
    public static Rolled_Up_Usage_Data__c insertRolledUpUsageDataWirelessOutboundUS() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Activity_Type__c = 0,
            Source_Name__c = 'BEEEC',
            Platform_Id__c = 'Tenant123',
            Rollup_Id__c = 'test-2',
            Channel_Type__c = 1,
            Device_Type__c = 13,
            Service_Type__c = 1,
            Origin_Country_Code__c = 1,
            Origin_Country_Code_ISO__c = 'US',
            Service_Class__c = 0,
            Billable_6__c = 126,
            Billable_30__c = 150,
            Billable_60__c = 180,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0)
        );
        insert ruud;
        Id idRuud = ruud.Id;
        
        // Get the Record again so we get the service identifier formula
        ruud = [select 
                Activity_Type__c,
                Source_Name__c,
                Platform_Id__c,
                Service_Type__c,
                Channel_Type__c,
                Service_Class__c,
                Origin_Country_Code__c,
                Billable_6__c,
                Billable_30__c,
                Billable_60__c,
                Start_Time__c,
                Service_Identifier__c,
                Inbound_Device__c
                from Rolled_Up_Usage_Data__c
                where Id = :idRuud
               ];
        return ruud;
    }
    
    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
    
    public static GCR_Content_Document_Detail__c insertBigMachinesQuoteContract(String strProductGroup, String strOfferingType) {
        Country__c objCountry = setupCountry();
        List<Account> list_Accounts = TestUtil.createAccounts(1, false);
        list_Accounts[0].SAP_Account_Code__c = 'GARNTest';
        list_Accounts[0].country__c =objCountry.id;
        insert list_Accounts;
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunity.StageName = '1.Understand Needs';
        insert objOpportunity;
        objOpportunity.Lines_of_Businesses__c = strProductGroup;
        objOpportunity.Country__c = objCountry.Id;
        update objOpportunity;
        
        BigMachines__Quote__c objQuote = CloudBillingTestUtil.setupBigMachinesQuote(
            'PureConnect Test Quote 1', objOpportunity.AccountId ,objOpportunity.id, strOfferingType);
        insert objQuote;
        
        Genesys_Entity__c objGenEntity = CloudBillingTestUtil.setupGenesysEntity();
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.setupContractPureConnect(objQuote);
        objContract.Genesys_Entity__c = objGenEntity.id;
        objContract.Status__c = 'Approved';
        System.debug('contract' + objContract);
        insert objContract;
        return objContract;
        
    }
    public static GCR_Content_Document_Detail__c insertPureCloudContract() {
        Country__c objCountry = setupCountry();
        List<Account> list_Accounts = TestUtil.createAccounts(1, false);
        list_Accounts[0].SAP_Account_Code__c = 'GARNTest';
        list_Accounts[0].country__c =objCountry.id;
        insert list_Accounts;
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunity.StageName = '1.Understand Needs';
        insert objOpportunity;
        objOpportunity.Lines_of_Businesses__c = 'PureConnect';
        objOpportunity.Country__c = objCountry.Id;
        update objOpportunity;
        
        zqu__Quote__c objQuote = CloudBillingTestUtil.setupZuoraQuote(
            'PureCloud Test ZQuote 1', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote.zqu__StartDate__c = System.today()- 730; 
        objQuote.zqu__Currency__c = 'USD';
        insert objQuote;
        
        Genesys_Entity__c objGenEntity = CloudBillingTestUtil.setupGenesysEntity();
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.setupContractPureCloud(objQuote);
        objContract.Genesys_Entity__c = objGenEntity.id;
        objContract.Status__c = 'Approved';
        System.debug('contract' + objContract);
        insert objContract;
        return objContract;
    }
    public static zqu__Quote__c setupZuoraQuote(String strName, String strAccId , String strOppId, Integer intPeriod ){
        zqu__Quote__c objZquQuote = new zqu__Quote__c();
        objZquQuote.Name = strName;
        objZquQuote.zqu__Account__c = strAccId;
        objZquQuote.zqu__Opportunity__c = strOppId;
        objZquQuote.PureCloud_Ramp_Up_Period__c = intPeriod;
        return objZquQuote;
    }
    public static BigMachines__Quote__c setupBigMachinesQuote(String strName, String strAccId , String strOppId, String strOfferingType) { //, Integer intPeriod ) {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c(
            Name = strName,
            Sold_To_Name__c = strAccId,
            BigMachines__Opportunity__c = strOppId,
            Offering_Type__c = strOfferingType
            //objQuote.zqu__StartDate__c = System.today()- 730
            //objQuote.zqu__Currency__c = 'USD';
        );
        return objQuote;
    }
    
    public static Genesys_Entity__c setupGenesysEntity(){
        Genesys_Entity__c objGenEntity = new Genesys_Entity__c();
        objGenEntity.Remit_To__c = 'Test Remit To Info';
        objGenEntity.Selling_Entity__c = 'Test Selling Entity Info';
        objGenEntity.CurrencyIsoCode = 'USD';
        insert objGenEntity;
        return objGenEntity;
    }
    
    //Generic interface borrowed initially from BatchCreateCloudMonthlySalesOrdersTest    
    public static GCR_Content_Document_Detail__c setupContracts(zqu__Quote__c objQuote){
        return setupContractPureCloud(objQuote);
    }
    public static GCR_Content_Document_Detail__c setupContractPureConnect(BigMachines__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = objQuote.Sold_To_Name__c;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Quote__c = objQuote.id;
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = Date.newInstance(2017, 1, 17);
        return objContract;
    }    
    public static GCR_Content_Document_Detail__c setupContractPureCloud(zqu__Quote__c objQuote){
        GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
        objContract.Account_Name__c = objQuote.zqu__Account__c;
        objContract.Document_Name__c = 'Cloud Billing Contract';
        objContract.Zuora_Quote__c = objQuote.id;
        objContract.Order_Date_Option__c = 'Last Day of Usage Month';
        objContract.Status__c = 'New';
        objContract.Active__c = true;
        objContract.Status__c = 'Approved';
        objContract.Pricing_Start_Date__c = Date.newInstance(2017, 1, 17);
        return objContract;
    }
    
    public static Cloud_Deployment__c setupCloudDeploymentPureConnectAndJunction(GCR_Content_Document_Detail__c objContract){
        Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
        objCloudDeployment.Account__c = objContract.Account_Name__c;
        objCloudDeployment.Cloud_Platform__c = 'PureCloud';
        objCloudDeployment.PureConnect_Id__c = 'Tenant123' ;
        insert objCloudDeployment;
        Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentToContract = new Cloud_Deployment_To_Contract_Junction__c(
            Contract__c = objContract.Id,
            Cloud_Deployment__c = objCloudDeployment.Id
        );
        insert objCloudDeploymentToContract;
        objCloudDeployment = [select
                              Account__c,
                              Cloud_Platform__c,
                              PureConnect_Id__c,
                              (select Contract__c, Cloud_Deployment__c from Cloud_Deployment_To_Contract_Junctions__r)
                              from Cloud_Deployment__c
                              where Id = :objCloudDeployment.Id
                             ];
        return objCloudDeployment;
    }
    public static Cloud_Deployment__c setupCloudDeploymentPureCloudAndJunction(GCR_Content_Document_Detail__c objContract){
        Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
        objCloudDeployment.Account__c = objContract.Account_Name__c;
        objCloudDeployment.Cloud_Platform__c = 'PureCloud';
        objCloudDeployment.PureCloud_OrgID__c = 'PCL123';
        insert objCloudDeployment;
        Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentToContract = new Cloud_Deployment_To_Contract_Junction__c(
            Contract__c = objContract.Id,
            Cloud_Deployment__c = objCloudDeployment.Id
        );
        insert objCloudDeploymentToContract;
        objCloudDeployment = [select
                              Account__c,
                              Cloud_Platform__c,
                              PureCloud_OrgID__c,
                              (select Contract__c, Cloud_Deployment__c from Cloud_Deployment_To_Contract_Junctions__r)
                              from Cloud_Deployment__c
                              where Id = :objCloudDeployment.Id
                             ];
        return objCloudDeployment;
    }
    public static Cloud_Deployment__c setupCloudDeploymentPureEngageAndJunction(GCR_Content_Document_Detail__c objContract){
        Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
        objCloudDeployment.Account__c = objContract.Account_Name__c;
        objCloudDeployment.Cloud_Platform__c = 'PureEngage Cloud';
        objCloudDeployment.Tenant_ID__c = 'BEEEC123';
        insert objCloudDeployment;
        Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentToContract = new Cloud_Deployment_To_Contract_Junction__c(
            Contract__c = objContract.Id,
            Cloud_Deployment__c = objCloudDeployment.Id
        );
        insert objCloudDeploymentToContract;
        objCloudDeployment = [select
                              Account__c,
                              Cloud_Platform__c,
                              Tenant_ID__c,
                              (select Contract__c, Cloud_Deployment__c from Cloud_Deployment_To_Contract_Junctions__r)
                              from Cloud_Deployment__c
                              where Id = :objCloudDeployment.Id
                             ];
        return objCloudDeployment;
    }    
    public static Cloud_Deployment__c setupCloudDeploymentPremierAndJunction(GCR_Content_Document_Detail__c objContract){
        Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
        objCloudDeployment.Account__c = objContract.Account_Name__c;
        objCloudDeployment.Cloud_Platform__c = 'Premier Edition';
        objCloudDeployment.PE_Subscription_ID__c = 'Angel123';
        insert objCloudDeployment;
        Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentToContract = new Cloud_Deployment_To_Contract_Junction__c(
            Contract__c = objContract.Id,
            Cloud_Deployment__c = objCloudDeployment.Id
        );
        insert objCloudDeploymentToContract;
        objCloudDeployment = [select
                              Account__c,
                              Cloud_Platform__c,
                              PE_Subscription_ID__c,
                              PE_Subscriber_Id_Hash__c,
                              (select Contract__c, Cloud_Deployment__c from Cloud_Deployment_To_Contract_Junctions__r)
                              from Cloud_Deployment__c
                              where Id = :objCloudDeployment.Id
                             ];
        System.Debug('CloudBillingTestUtil.setupCloudDeploymentPremierAndJunction: objCloudDeployment ' + objCloudDeployment);
        return objCloudDeployment;
    }
    public static Cloud_Deployment__c setupCloudDeploymentPorticoAndJunction(GCR_Content_Document_Detail__c objContract){
        Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
        objCloudDeployment.Account__c = objContract.Account_Name__c;
        objCloudDeployment.Cloud_Platform__c = 'Outbound Engagement';
        objCloudDeployment.Portico_Platform_Id__c = 'Portico123';
        insert objCloudDeployment;
        Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentToContract = new Cloud_Deployment_To_Contract_Junction__c(
            Contract__c = objContract.Id,
            Cloud_Deployment__c = objCloudDeployment.Id
        );
        insert objCloudDeploymentToContract;
        objCloudDeployment = [select
                              Account__c,
                              Cloud_Platform__c,
                              Portico_Platform_Id__c,
                              Portico_Platform_Id_Hash__c,
                              (select Contract__c, Cloud_Deployment__c from Cloud_Deployment_To_Contract_Junctions__r)
                              from Cloud_Deployment__c
                              where Id = :objCloudDeployment.Id
                             ];
        System.Debug('CloudBillingTestUtil.setupCloudDeploymentPorticoAndJunction: objCloudDeployment ' + objCloudDeployment);
        return objCloudDeployment;
    } 
    
    public static List<Cloud_Deployment_To_Contract_Junction__c> setupInsertCloudDeploymentsAndJunctions(GCR_Content_Document_Detail__c objContract){
        List<Cloud_Deployment_To_Contract_Junction__c> list_junctions = new List<Cloud_Deployment_To_Contract_Junction__c>();
        {
            Cloud_Deployment__c objCDPureConnect = setupCloudDeploymentPureConnectAndJunction(objContract);
            list_junctions.add(objCDPureConnect.Cloud_Deployment_To_Contract_Junctions__r);
        }
        {
            Cloud_Deployment__c objCDPureCloud = setupCloudDeploymentPureCloudAndJunction(objContract);
            list_junctions.add(objCDPureCloud.Cloud_Deployment_To_Contract_Junctions__r);
        }
        upsert list_junctions;
        return list_junctions;
    }
    
    public static Order__c setupOrder(GCR_Content_Document_Detail__c objContract){
        Order__c objOrder = new Order__c(Name = 'Test Order');
        objOrder.Contract_Lookup__c = objContract.Id;
        objOrder.Month__c = '6';
        objOrder.Year__c = '2017';
        objOrder.status__c = 'In Progress';
        objOrder.End_User_Name__c = objOrder.Bill_To_Name__c = objOrder.Sold_To_Name__c = objOrder.Ship_To_Name__c = objContract.Account_Name__c ;
        objOrder.Opportunity__c = objContract.Zuora_Quote__r.zqu__Opportunity__c;
        return objOrder;
    }
    
    public static List<Contract_Tier_Set_Month__c> getListTierSetMonth(Integer intServiceType, List<Contract_Tier_Set__c> list_CTS) {
        List<id> list_ids = new List<id>();
        for(Contract_Tier_Set__c objCTS : list_CTS ){
            list_ids.add(objCTS.id);
            Contract_Tier_Set_Period__c ctsp1 = new Contract_Tier_Set_Period__c();
            insert ctsp1;
            Contract_Tier_Set_Month__c ctsm1 = new Contract_Tier_Set_Month__c(Contract_Tier_Set_Period__c = ctsp1.Id , Contract_Tier_Set__c = objCTS.id, 
                                                                              Month__c = '6' , Year__c = '2017');
            insert ctsm1;
            Service_Usage__c su1 = new Service_Usage__c(Count__c = 2, Quantity__c = 5, Cost__c = 0.1, Service_Type__c = intServiceType, Contract_Tier_Set_Month__c = ctsm1.Id);
            Service_Usage__c su2 = new Service_Usage__c(Count__c = 5, Quantity__c = 10, Cost__c = 0.2, Service_Type__c = intServiceType, Contract_Tier_Set_Month__c = ctsm1.Id);
            insert su1;
            insert su2;
        }
        // Have to get from DB to populate Formula Fields
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = [SELECT id,
                                                                      Sum_Count__c,
                                                                      Max_Usage__c,
                                                                      Total_Usage__c,
                                                                      Total_Outbound_Calls_Cost__c,
                                                                      Total_Inbound_Calls_Cost__c, Contract_Tier_Set__c
                                                                      FROM Contract_Tier_Set_Month__c WHERE Contract_Tier_Set__c = :list_ids];
        return list_ContractTierSetMonth;
    }
    
    public static List<Contract_Tier_Set__c> setupTierSets(Id contractId , List<Product2> list_Products){
        List<Contract_Tier_Set__c> list_ContractTS = new List<Contract_Tier_Set__c>();
        for(Product2 objProd : list_Products){
            list_ContractTS.add( new Contract_Tier_Set__c(Name = 'Test '+objProd.Name , 
                                                          Product__c = objProd.id ,
                                                          Period_In_Months__c = '6', 
                                                          Contract__c = contractId , Is_Deleted__c = false) );
        }
        return list_ContractTS;
    }
    
    public static List<Contract_Tier_Set_Month_Charges__c> setupContractTierSetMonthCharges(List<Contract_Tier_Set_Month__c> list_CTSM){
        List<Contract_Tier_Set_Month_Charges__c> list_CTSMC = new List<Contract_Tier_Set_Month_Charges__c>();
        for(Contract_Tier_Set_Month__c objCTSM : list_CTSM){
            Contract_Tier_Set_Month_Charges__c objCTSMC = new Contract_Tier_Set_Month_Charges__c(Contract_Tier_Set_Month__c = objCTSM.id, 
                                                                                                 Amount__c = 10, Description__c = '102');    
            list_CTSMC.add(objCTSMC);
        }
        insert list_CTSMC;
        return list_CTSMC;
    }
    
    public static List<BOGO_Detail__c> setupBOGODetail(List<Contract_Tier_Set__c> list_CTS){
        List<BOGO_Detail__c> list_BOGO = new List<BOGO_Detail__c>();
        for(Contract_Tier_Set__c objCTS : list_CTS){
            BOGO_Detail__c objBOGO = new BOGO_Detail__c(Is_Deleted__c = false , Parent_Quantity__c = 2, Parent_Tier_Set__c = objCTS.id , Prorate__c = true,
                                                        Related_Quantity__c = 2, Related_Tier_Set__c = list_CTS[0].id);
            list_BOGO.add(objBOGO);
        }
        insert list_BOGO;
        return list_BOGO;
    }
    
    public static List<Contract_Recurring_Charge__c> setupContractRecurringCharges(List<Contract_Tier_Set__c> list_CTS){
        List<Contract_Recurring_Charge__c> list_CRC = new List<Contract_Recurring_Charge__c>();
        
        for(Contract_Tier_Set__c objCTS : list_CTS){
            Contract_Recurring_Charge__c objCRC = new Contract_Recurring_Charge__c(Is_Deleted__c = false , 
                                                                                   Active__c = true, 
                                                                                   Contract_Tier_Set__c = objCTS.id , 
                                                                                   Units__c = 2,
                                                                                   Amount__c = 2.0 , 
                                                                                   Type__c = 'Monthly Flat Fee' , 
                                                                                   External_Note__c = 'Test Note' , 
                                                                                   Pre_Bill__c = false , 
                                                                                   Business_Care_Min_Revenue_Threshold__c = 1,
                                                                                   Business_Care_Max_Revenue_Threshold__c = 2 ,
                                                                                   Business_Care_Support_Fee_Percentage__c = 1 , 
                                                                                   Deferred__c = true);
            
            list_CRC.add(objCRC);
        }
        
        insert list_CRC;
        return list_CRC;
    }
    public static void insertCloudBillingReportRequest2016() {
        Util.Bypass_Trigger_Chk = true;
        GCR_Content_Document_Detail__c objContract;
        List<GCR_Content_Document_Detail__c> list_Contracts = [select Id from GCR_Content_Document_Detail__c];
        if (list_Contracts.size() > 0) {
            objContract = list_Contracts[0];
        } else {
            objContract = insertPureCloudContract();
        }
        
        if (objContract != null) {
            Cloud_Billing_Report_Request__c objCBRR = new Cloud_Billing_Report_Request__c(
                Start_Month__c = '1',
                Start_Year__c = '2016',
                End_Month__c = '12',
                End_Year__c = '2016',
                Report_Type__c = 'Detail Inbound IVR Usage;Detail Inbound Usage;Detail Outbound Usage',
                Contract__c = objContract.id,
                Platform_Id_List__c = 'Platform123'
            );
            insert objCBRR;    
        }
    }
    public static Rolled_Up_Usage_Data__c getRolledUpUsageDataPureCloud() {
        Util.Bypass_Trigger_Chk = true;
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Activity_Type__c = 0,
            Source_Name__c = 'PCL',
            Platform_Id__c = 'PCL123',
            Rollup_Id__c = 'test-1',
            Channel_Type__c = 1,
            Device_Type__c = 3,
            Service_Type__c = 2,
            Service_Class__c = 0,
            Origin_Country_Code__c = 1,
            Billable_6__c = 66,
            Billable_30__c = 90,
            Billable_60__c = 120,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0),
            Destination_Device_Career__c = 'test'
        );
        insert ruud;
        Id idRuud = ruud.Id;
        
        // Get the Record again so we get the service identifier formula
        ruud = [select Id,
                Activity_Type__c,
                Source_Name__c,
                Platform_Id__c,
                Rollup_Id__c,
                Channel_Type__c,
                Device_Type__c,
                Service_Type__c,
                Service_Class__c,
                Origin_Country_Code__c,
                Billable_6__c,
                Billable_30__c,
                Billable_60__c,
                Start_Time__c,
                Destination_Device_Career__c,
                Platform_Id_Hash__c,
                Service_Identifier__c,
                Service_Identifier_Default__c,
                PCV_Service_Identifier__c,
                PCV_Service_Identifier_Default__c
                from Rolled_Up_Usage_Data__c
                where Id = :idRuud
               ];
        System.debug('CloudBillingTestUtil.getRolledUpUsageDataPureCloud: returning updated RUUD ' + ruud);
        return ruud;
    }    
    public static Rolled_Up_Usage_Data__c getRolledUpUsageDataPureConnectTenant123() {
        Util.Bypass_Trigger_Chk = true;
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Activity_Type__c = 0,
            Source_Name__c = 'PCC',
            Platform_Id__c = 'Tenant123',
            Rollup_Id__c = 'test-1',
            Channel_Type__c = 1,
            Device_Type__c = 3,
            Service_Type__c = 2,
            Service_Class__c = 0,
            Origin_Country_Code__c = 1,
            Billable_6__c = 66,
            Billable_30__c = 90,
            Billable_60__c = 120,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0),
            Destination_Device_Career__c = 'test'
        );
        insert ruud;
        Id idRuud = ruud.Id;
        
        // Get the Record again so we get the service identifier formula
        ruud = [select Id,
                Activity_Type__c,
                Source_Name__c,
                Platform_Id__c,
                Rollup_Id__c,
                Channel_Type__c,
                Device_Type__c,
                Service_Type__c,
                Service_Class__c,
                Origin_Country_Code__c,
                Billable_6__c,
                Billable_30__c,
                Billable_60__c,
                Start_Time__c,
                Destination_Device_Career__c,
                Platform_Id_Hash__c,
                Service_Identifier__c,
                Service_Identifier_Default__c,
                PCV_Service_Identifier__c,
                PCV_Service_Identifier_Default__c
                from Rolled_Up_Usage_Data__c
                where Id = :idRuud
               ];
        System.debug('CloudBillingTestUtil.getRolledUpUsageDataPureConnect: returning updated RUUD ' + ruud);
        return ruud;
    }
    
    
    public static Map<String, Cloud_Deployment__c> getMapPlatformIdHashToCloudDeploymentTenant123() {
        Util.Bypass_Trigger_Chk = true;
        Map<String, Cloud_Deployment__c> mapPlatformIdHashToCloudDeployment = new Map<String, Cloud_Deployment__c>();
        
        GCR_Content_Document_Detail__c objContract = insertPureCloudContract();
        Cloud_Deployment__c obj_CDs = CloudBillingTestUtil.setupCloudDeploymentPureConnectAndJunction(objContract);
        Cloud_Deployment__c obj_PCLCDs = CloudBillingTestUtil.setupCloudDeploymentPureCloudAndJunction(objContract);
        
        mapPlatformIdHashToCloudDeployment.put('PCC#Tenant123', obj_CDs);
        mapPlatformIdHashToCloudDeployment.put('PCL#PCL123', obj_PCLCDs);
        System.debug('CloudBillingTestUtil.getMapPlatformIdHashToCloudDeployment returning map ' + mapPlatformIdHashToCloudDeployment);
        return mapPlatformIdHashToCloudDeployment;
    }
    
    public static List<zqu__QuoteChargeDetail__c> setupZuoraQuoteChargeDetails(Id zQuoteId){
        List<zqu__QuoteChargeDetail__c> list_QuoteChargeDetails = TestDataFactoryForQuoteTool.createZuoraQuoteProducts(zQuoteId);
        
        return list_QuoteChargeDetails;
    }
    private void deleteThis() {
        Date dtFromDate = Date.newInstance(2017,11,29);
        Date dtToDate = Date.newInstance(2017,11,28);
        
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        while (dtFromDate <=  dtToDate) {
            objCalculateAverageConversionRates.buildConversionRates(dtFromDate);
            dtFromDate = dtFromDate.addDays(1);
        }
    }
}