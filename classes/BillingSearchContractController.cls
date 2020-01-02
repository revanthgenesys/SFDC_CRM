public with sharing class BillingSearchContractController
{
    // List of Recent Contracts
    public List<GCR_Content_Document_Detail__c> list_RecentContracts {get; private set;}
    // List of Contracts in 'New' status
    public List<GCR_Content_Document_Detail__c> list_NewContracts {get; private set;}
    // List of Contracts in 'In Progress' *** Removed rejected -- or 'Rejected' status
    public List<GCR_Content_Document_Detail__c> list_InProgressContracts {get; private set;}
    // List of Contracts in 'Awaiting Approval' status
    public List<GCR_Content_Document_Detail__c> list_AwaitingApprovalContracts {get; private set;}
    // List of Contracts in 'Hold' status
    public List<GCR_Content_Document_Detail__c> list_HoldContracts {get; private set;}
    // List of Account Billing Info Objects users may need to deal with
    public List<Account_Billing_Info__c> list_AccountBillingInfo {get; private set;}
    
    // List of Contracts returned as search results
    public List<GCR_Content_Document_Detail__c> list_SearchResults {get; private set;}
    // To indicate whether to show search results or not
    public Boolean blnShowSearchResults {get; private set;}
    // Name of Contract being search
    public String strContractName {get; set;}
    //Subscriber id to be searched by
    public String strSubscriberId {get; set;}
    //Tenant id to be searched by
    public String strTenantId {get; set;}
    //Portico id to be searched by
    public String strPorticoId {get; set;}
    //Caas id to be searched by
    public String strPureConnectId {get; set;}
    //PureCloud id to be searched by
    public String strPureCloudId {get; set;}
    //Platform Id id to be searched by ECD 2018-04-10
    public String strBillingPlatformId {get; set;}
    //GARN code to be searched by
    public String strGARNCode {get; set;}
    // Name of Account for which contracts are being searched
    public String strAccountName {get; set;}
    // To render picklist for Product group/Edition options and store selection made by user
    public Opportunity objSearchDummyOppty {get; set;}
    // Name of subsidiary chosen to run jobs by subsidiary
    public String strSubsidiary {get; set;}
    // iTracks 22567
    // Run particular region option in Admin Tab
    public String strRegion {get; set;}
    // iTracks 29871
    // // Run particular Edition option in Admin Tab
    public String strEdition {get; set;}
    // iTracks 24805
    // Run particular region for Contract Search
    public String strRegionContractFilter {get; set;}
    // Run Pre-Bill or standard order creation
    public Boolean blnPreBill {get; set;}
    // Monthly Sales Order/Invoice Creation Job Log
    public Cloud_Billing_Log__c objJobLog {get; set;}
    // List of Upgrades/Downgrades
    public List<Order__c> list_UpgradesDowngrades {get; private set;}
    // List of Renewals
    public List<Order__c> list_Renewals {get; private set;}
    
    // List of New Master Orders
    @TestVisible
    public List<Order__c> list_NewMasterOrders {get; private set;}
    // List of New Master Orders filtered
    public List<Order__c> list_NewMasterOrdersFiltered {get; private set;}
    //Order Id of Upgrade/Downgrade Order to be marked as synced
    public String strOrderId {get; set;}
    // To indicate whether there are any Billing exceptions
    public Boolean blnHasRatingExceptions {get; private set;}
    
    // *** Ids of Batch Jobs : To prevent concurrent jobs from being kicked off ***
    Id idOrderCreationJob;
    Id idInvoiceCreationJob;
    Id idRatingJob;
    Id idReconcileJob;

    // To indicate whether the running user has Contract Approver permission set
    public Boolean blnIsContractApprover {get; private set;}
    // To indicate whether the running user has Contract Manager permission set
    public Boolean blnIsContractManager {get; private set;}
    // To indicate whether the running user has Contract Read Only permission set
    public Boolean blnIsContractReadOnly {get; private set;}
    
    //To Search Setup New Billing Contracts By Fields.
    public List<SelectOption> billingContractFieldOption {get; set;}
    public String billingContractSelectedField {get; set;}
    public String billingContractSeachValue {get; set;}
    public String billingContractSearchQuery {get; set;}
    
    //To Search Upgrades/Downgrades By Fields
    public String upgradeDowngradeSelectedField {get; set;}
    public String upgradeDowngradeSeachValue {get; set;}
    public String upgradeDowngradeSearchQuery {get; set;}
    
    //To Search Upgrades/Downgrades By Fields
    public String renewalSelectedField {get; set;}
    public String renewalSeachValue {get; set;}
    public String renewalSearchQuery {get; set;}

    //To Sort Setup New Billing Contracts By Fields.
    public String sortOnBillingContract {get; set;}
    public String sortDirectionToBillingContract {get; set;}
    
    // Added by Vijay  - Oct 10th  - Start
    // CRMBILL - 164
    // To setup active tab for Page.
    public String strActiveTab {get; set;}
    // Added by Vijay  - Oct 10th  - End
    
    //Added by Rony - Mar 7 2018-Start
    //**Added to pass the offering type**
    public String strOfferingType;
    //Added by Rony - Mar 7 2018-End
    
    public String sortExpressionOnMasterOrderList
    {
        get
        {
            return sortOnBillingContract;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortOnBillingContract)
                sortDirectionToBillingContract = (sortDirectionToBillingContract == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirectionToBillingContract = 'ASC';
            sortOnBillingContract = value;
        }
    }
    
    //To Sort Upgrades/Downgrades By Fields.
    public String sortOnUpgradeDowngrade {get; set;}
    public String sortDirectionToUpgradeDowngrade {get; set;}
    
    public String sortExpressionOnUpgradeDowngradeOrderList
    {
        get
        {
            return sortOnUpgradeDowngrade;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortOnUpgradeDowngrade)
                sortDirectionToUpgradeDowngrade = (sortDirectionToUpgradeDowngrade == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirectionToUpgradeDowngrade = 'ASC';
            sortOnUpgradeDowngrade = value;
        }
    }

    //To Sort Renewal By Fields.
    public String sortOnRenewal {get; set;}
    public String sortDirectionToRenewal {get; set;}
    
    public String sortExpressionOnRenewalOrderList
    {
        get
        {
            return sortOnRenewal;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortOnRenewal)
                sortDirectionToRenewal = (sortDirectionToRenewal == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirectionToRenewal = 'ASC';
            sortOnRenewal = value;
        }
    }

    // iTracks 24805
    private Map<String, String> constructMapForRegionAccountToUser() {
        Map<String, String> mapRegionForAccountToUser = new Map<String, String> {
            'APAC' => 'APAC',
            'EMEA' => 'EMEA',
            'LATIN AMERICA' => 'LATAM',
            'NORTH AMERICA' => 'North America'
        };
        return mapRegionForAccountToUser;
    }
    
    // *** Constructor ***
    public BillingSearchContractController()
    {
        // Added by Vijay  - Oct 10th  - Start
        // CRMBILL - 164
        strActiveTab = 'Home';
        // Added by Vijay  - Oct 10th  - End
        // iTracks 24805
        Id userId = UserInfo.getUserId();
        USer objUser = [select Name, Employee_Region__c from User where Id = :userId];
        System.Debug('Id ' + userId + ' Name ' + objUser.Name + ' Employee_Region__c ' + objUser.Employee_Region__c);
        strRegionContractFilter = null;
        Map<String, String> mapRegionForAccountToUser = constructMapForRegionAccountToUser();
        if (mapRegionForAccountToUser.containsKey(objUser.Employee_Region__c)) {
            strRegionContractFilter = mapRegionForAccountToUser.get(objUser.Employee_Region__c);
            System.debug('Setting Region for User [' + objUser.Employee_Region__c + '] to Account Region [' + strRegionContractFilter + ']');
        }

        // Initializing data
        blnShowSearchResults = false;
        
        objSearchDummyOppty = new Opportunity(RecordtypeId = (Id)('012U0000000LrBP'));
        
        //Sorting Order for Action Items
        //Sorting Order initiation for Setup New Billing Contracts
        sortOnBillingContract = sortDirectionToBillingContract = '';
        
        //Sorting Order initiation for Upgrades/Downgrades
        sortOnUpgradeDowngrade = sortDirectionToUpgradeDowngrade = '';
        
        setupSearchOptions();
        
        loadContracts();
    }
    
    // Added by Vijay  - Oct 10th  - Start
    // CRMBILL - 164
    public void handleViewExceptionReports(){
        strActiveTab = 'admin';
    }
    // Added by Vijay  - Oct 10th  - End
    
    @TestVisible
    private void setupSearchOptions(){
        billingContractFieldOption = new List<SelectOption>();

        billingContractFieldOption.add(new SelectOption('All','All Fields'));
        billingContractFieldOption.add(new SelectOption('Account','Account'));
        billingContractFieldOption.add(new SelectOption('Opportunity','Opportunity'));
        billingContractFieldOption.add(new SelectOption('Product','Product'));
        billingContractFieldOption.add(new SelectOption('Quote','Quote'));
        billingContractFieldOption.add(new SelectOption('Order','Order'));
    }

    public void loadContracts() {
        // fetch contracts
        fetchContracts();
        // initialize Log object
        initializeLogObject();
        // fetch Upgrades/Downgrades AKA Amendments
        fetchUpgradesDowngrades();
        // fetch Renewals
        fetchRenewals();
        // fetch new master orders
        fetchNewMasterOrders();
        // fetch Account Billing Info objects
        fetchAccountBillingInfo();
        // check for Billing Exceptions
        checkExceptions();
        // check for permission sets
        checkPermissions();
    }

    // *** Setup New Billing Contract Sorting ***
    public String getSortDirectionToBillingContract()
    {
        //if not column is selected 
        if (sortExpressionOnMasterOrderList == null || sortExpressionOnMasterOrderList == '')
            return 'ASC';
        else
            return sortDirectionToBillingContract;
    }
    
    public void setSortDirectionToBillingContract(String value)
    {  
        sortDirectionToBillingContract = value;
    }
    
    // *** Upgrades/Downgrades Sorting ***
    public String getSortDirectionToUpgradeDowngrade()
    {
        //if not column is selected 
        if (sortExpressionOnUpgradeDowngradeOrderList == null || sortExpressionOnUpgradeDowngradeOrderList == '')
            return 'ASC';
        else
            return sortDirectionToUpgradeDowngrade;
    }
    
    public void setSortDirectionToUpgradeDowngrade(String value)
    {  
        sortDirectionToUpgradeDowngrade = value;
    }
    
    
    //*** Method to initialize Log object ***
    @TestVisible
    void initializeLogObject()
    {
        Date dtTemp = Date.today().addMonths(-1);
        objJobLog = new Cloud_Billing_Log__c();
        objJobLog.Day__c = '1';
        objJobLog.Month__c = String.valueOf(dtTemp.month());
        objJobLog.Year__c = String.valueOf(dtTemp.year());
    }

    // We can currently only search for 3 things from Cloud Deployment
    @TestVisible
    private boolean isUserSearchingFromCloudDeployment() {
        if (String.isNotBlank(strSubscriberId)) return true;
        if(String.isNotBlank(strTenantId)) return true;
        if(String.isNotBlank(strPorticoId)) return true;
        if(String.isNotBlank(strPureConnectId)) return true;
        if(String.isNotBlank(strPureCloudId)) return true;
        if(String.isNotBlank(strBillingPlatformId)) return true;
        return false;
    }
    
    @TestVisible
    private Boolean isUserSearchingForContract() {
        if(String.isNotBlank(strContractName)) return true;
        if(String.isNotBlank(strGARNCode)) return true;
        if(String.isNotBlank(strAccountName)) return true;
        if(String.isNotBlank(objSearchDummyOppty.Lines_of_Businesses__c)) return true;
        return false;
    }

    public void searchFromCloudDeployment()
    {
        System.debug('isUserSearchingFromCloudDeployment ' + isUserSearchingFromCloudDeployment() + ' isUserSearchingForContract ' + isUserSearchingForContract());
        List<Cloud_Deployment__c> list_CloudDeployment = null;
        if (isUserSearchingFromCloudDeployment()) {
            String strQuery = 'SELECT Account__c, Account__r.Name, Sold_To_Account__c FROM Cloud_Deployment__c where ';
            
            Boolean blnFirstWhereClause = true;
            if (String.isNotBlank(strSubscriberId)) {
                if (!blnFirstWhereClause) strQuery += ' AND';
                strQuery += ' PE_Subscription_ID__c LIKE \'%' + strSubscriberId.trim() + '%\'';
                blnFirstWhereClause = false;
            }
            if(String.isNotBlank(strTenantId)) {
                if (!blnFirstWhereClause) strQuery += ' AND';
                strQuery += ' Tenant_ID__c LIKE \'%' + strTenantId.trim() + '%\'';
            }
            if(String.isNotBlank(strPorticoId)) {
                if (!blnFirstWhereClause) strQuery += ' AND';
                strQuery += ' Portico_Platform_Id__c LIKE \'%' + strPorticoId.trim() + '%\'';
            }
            if(String.isNotBlank(strPureConnectId)) {
                if (!blnFirstWhereClause) strQuery += ' AND';
                strQuery += ' PureConnect_Id__c LIKE \'%' + strPureConnectId.trim() + '%\'';
            }
            if(String.isNotBlank(strPureCloudId)) {
                if (!blnFirstWhereClause) strQuery += ' AND';
                strQuery += ' PureCloud_OrgID__c LIKE \'%' + strPureCloudId.trim() + '%\'';
            }
            if(String.isNotBlank(strBillingPlatformId)) {
                if (!blnFirstWhereClause) strQuery += ' AND';
                strQuery += ' Billing_Platform_Id__c LIKE \'%' + strBillingPlatformId.trim() + '%\'';
            }
            
            System.debug('Cloud Deployment SOQL ' + strQuery);
            list_CloudDeployment = (List<Cloud_Deployment__c>)Database.query(strQuery);
            if (list_CloudDeployment.size() == 0) {
                System.Debug('Found no Accounts in Cloud Deployments for the subscriber or tenant ids');
            } else {
                for (Cloud_Deployment__c cd : list_CloudDeployment) {
                    System.Debug('Found Account in Cloud Deployment ' + cd.Account__r.Name);
                }
            }
        }

        // If we previously were only searching for a cloud deployment and did not get a hit, and we were also
        // not searching for Account/Contract/Product Group we would get random results here. Return null
        // list if no cloud deployments found and we are not searching for things referenced by the contract
        if ((list_CloudDeployment == null || list_CloudDeployment.size() == 0) && !isUserSearchingForContract()) {
            // Need to return a list of size zero, not null;
            list_SearchResults = new List<GCR_Content_Document_Detail__c>();
            return;
        }
        
        blnShowSearchResults = true;
        // iTracks 24805 add field Account_Name__r.Country__r.Region__c
        String strQuery = 'SELECT id, Name, Account_Name__c, GCR__r.Opportunity__c, GCR__r.Opportunity__r.Name, '
            + 'Pricing_Start_Date__c, Status__c, Expiration_Renewal_Date__c, Quote__c, Product_Group__c, Name__c , '
            + 'Account_Name__r.Country__r.Region__c '
            + 'FROM GCR_Content_Document_Detail__c WHERE '
            + 'Document_Name__c = \'Cloud Billing Contract\'';

        if (list_CloudDeployment != null && list_CloudDeployment.size() > 0) {
            strQuery += ' AND (Account_Name__c = \'' + list_CloudDeployment[0].Account__c + '\'';
            if (list_CloudDeployment[0].Sold_To_Account__c != null) {
                strQuery += ' OR Account_Name__c = \'' + list_CloudDeployment[0].Sold_To_Account__c + '\'';
            }
            strQuery += ')';
            
        }
        if(String.isNotBlank(strContractName))
            strQuery += ' AND Name LIKE \'%' + strContractName.trim() + '%\'';
        
        if(String.isNotBlank(strGARNCode))
            strQuery += ' AND Account_Name__r.SAP_Account_Code__c LIKE \'%' + strGARNCode.trim() + '%\'';
        
        if(String.isNotBlank(strAccountName))
            strQuery += ' AND Account_Name__r.Name LIKE \'%' + strAccountName.trim().replaceAll('\'', '\\\\\'') + '%\'';
        
        if(String.isNotBlank(objSearchDummyOppty.Lines_of_Businesses__c))
            strQuery += ' AND Product_Group__c = \'' + objSearchDummyOppty.Lines_of_Businesses__c + '\'';

        if(String.isNotBlank(strRegionContractFilter))
            strQuery += ' AND Account_Name__r.Country__r.Region__c = \'' + strRegionContractFilter + '\'';

        strQuery +=' LIMIT 10';
        
        System.debug('<<<< debug query ['+strQuery+']');
        list_SearchResults = (List<GCR_Content_Document_Detail__c>)Database.query(strQuery);
    }

    //*** Handler/Method for Contract Search ***
    public void search()
    {
        System.debug('In Contract Search');
        blnShowSearchResults = true;
        // iTracks 24805 Quote__r.Order__r.Region__c
        String strQuery = 'SELECT id, Name, Account_Name__c, GCR__r.Opportunity__c, GCR__r.Opportunity__r.Name, '
            + 'Pricing_Start_Date__c, Status__c, Expiration_Renewal_Date__c, Quote__c, Product_Group__c, '
            + 'Quote__r.Order__r.Region__c '
            + 'FROM GCR_Content_Document_Detail__c WHERE '
            + 'Document_Name__c = \'Cloud Billing Contract\'';
        
        if(String.isNotBlank(strContractName))
            strQuery += ' AND Name LIKE \'%' + strContractName.trim() + '%\'';
        
        if(String.isNotBlank(strSubscriberId))
            strQuery += ' AND Account_Name__r.Subscriber_ID__c LIKE \'%' + strSubscriberId.trim() + '%\'';
        
        if(String.isNotBlank(strTenantId))
            strQuery += ' AND Account_Name__r.Tenant_ID__c LIKE \'%' + strTenantId.trim() + '%\'';
        
        if(String.isNotBlank(strGARNCode))
            strQuery += ' AND Account_Name__r.SAP_Account_Code__c LIKE \'%' + strGARNCode.trim() + '%\'';
        
        if(String.isNotBlank(strAccountName))
            strQuery += ' AND Account_Name__r.Name LIKE \'%' + strAccountName.trim() + '%\'';
        
        if(String.isNotBlank(objSearchDummyOppty.Lines_of_Businesses__c))
            strQuery += ' AND Product_Group__c = \'' + objSearchDummyOppty.Lines_of_Businesses__c + '\'';

        if(String.isNotBlank(strRegionContractFilter))
            strQuery += ' AND Account_Name__r.Name LIKE \'%' + strAccountName.trim() + '%\'';

        strQuery +=' LIMIT 10';
        
        System.debug('<<<< debug query ['+strQuery+']');
        list_SearchResults = (List<GCR_Content_Document_Detail__c>)Database.query(strQuery);
    }
    
    public void runReportRequests() {
        System.Debug('runReportRequests');
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to run Cloud Billing Report Requests.'));
            return;
        }
        objJobLog.Type__c = 'Run Cloud Billing Report Requests';
        objJobLog.User__c = UserInfo.getUserId();
        objJobLog.Time__c = DateTime.now();
        insert objJobLog;
        objJobLog.Id = null;

        CloudBillingData info = new CloudBillingData(blnPreBill, objJobLog.Month__c, objJobLog.Year__c, null);

        if(objJobLog.Contract__c != null) {
            info.contractId = objJobLog.Contract__c;
        } else {
            info.subsidiary = strSubsidiary;
            info.region = strRegion;
            info.edition = strEdition;
        }
        CloudBillingUtil.runCloudBillingReportRequests(info);
    }
    
    @TestVisible
    void fetchAccountBillingInfo() {
        // iTracks 24805 add field Sold_To_NS_Bill_To__r.Country__r.Region__c 
        String strQuery = 'SELECT Id, Name, Document_Type__c,' +
            ' Sold_To_NS_Bill_To__r.Name, Sold_To_NS_Bill_To__r.Country__r.Region__c,' +
            ' Order__r.Name, Order__r.Invoice_Date__c, Date__c,' +
            ' NS_Status__c, Status__c' + 
            ' FROM Account_Billing_Info__c where Status__c != \'Email Sent\' and Order__r.RecordType.Name = \'Cloud Monthly Billing Order\'';
        if (String.isNotBlank(strRegionContractFilter)) {
            strQuery += ' AND Sold_To_NS_Bill_To__r.Country__r.Region__c = \'' + strRegionContractFilter + '\'';
        }
        strQuery += ' LIMIT 100';
        System.Debug('fetchAccountBillingInfo query: ' + strQuery);
        list_AccountBillingInfo = Database.query(strQuery);
    }
    
    //*** Method to fetch contracts and populate the various contract lists based on status ***
    @TestVisible
    void fetchContracts()
    {
        list_RecentContracts = new List<GCR_Content_Document_Detail__c>();
        list_NewContracts = new List<GCR_Content_Document_Detail__c>();
        list_InProgressContracts = new List<GCR_Content_Document_Detail__c>();
        list_AwaitingApprovalContracts = new List<GCR_Content_Document_Detail__c>();
        list_HoldContracts = new List<GCR_Content_Document_Detail__c>();
        Boolean blnIsRecentFull = false,blnIsNewFull = false,blnIsInProgressFull = false,blnIsAwaitingApprovalFull = false,blnIsHoldFull = false;
        // iTracks 24805 Make query dynamic string to make region selection optional
        String strQuery = 'SELECT id, Name, Account_Name__c,'
                        + ' Pricing_Start_Date__c, Status__c,Quote__c,Zuora_Quote__c,Product_Group__c, Name__c, '
                        + ' GCR__r.Status__c,Expiration_Renewal_Date__c,'
                        + ' Account_Name__r.Country__r.Region__c'
                        + ' FROM GCR_Content_Document_Detail__c'
                        + ' WHERE Document_Name__c = \'Cloud Billing Contract\'';

        if (String.isNotBlank(strRegionContractFilter)) {
            strQuery += ' AND Account_Name__r.Country__r.Region__c = \'' + strRegionContractFilter + '\'';
        }

        strQuery += ' ORDER BY LastModifiedDate DESC LIMIT 200';

        System.Debug('fetchContracts Query ' + strQuery);
        List<GCR_Content_Document_Detail__c> list_Contracts = Database.query(strQuery);

        for(GCR_Content_Document_Detail__c objContract : list_Contracts)
        {
            if(!blnIsRecentFull)
            {
                list_RecentContracts.add(objContract);
                if(list_RecentContracts.size() == 20)
                    blnIsRecentFull = true;
            }
            
            if(!blnIsNewFull && objContract.Status__c == 'New')
            {
                list_NewContracts.add(objContract);
                if(list_NewContracts.size() == 25)
                    blnIsNewFull = true;
            }
            
            if(!blnIsInProgressFull && (objContract.Status__c == 'In Progress'))// || objContract.Status__c == 'Rejected'))
            {
                list_InProgressContracts.add(objContract);
                if(list_InProgressContracts.size() == 10)
                    blnIsInProgressFull = true;
            }
            
            if(!blnIsAwaitingApprovalFull && objContract.Status__c == 'Awaiting Approval')
            {
                list_AwaitingApprovalContracts.add(objContract);
                if(list_AwaitingApprovalContracts.size() == 10)
                    blnIsAwaitingApprovalFull = true;
            }
            
            if(!blnIsHoldFull && objContract.Status__c == 'Hold')
            {
                list_HoldContracts.add(objContract);
                if(list_HoldContracts.size() == 10)
                    blnIsHoldFull = true;
            }
            
            if(blnIsRecentFull && blnIsNewFull && blnIsInProgressFull && blnIsAwaitingApprovalFull && blnIsHoldFull)
                break;
        }
    }

    public void runReconcileJob()
    {
        // Block execution of job if another job of same type is not yet complete
        if(idReconcileJob != null && [Select Status from AsyncApexJob where Id = :idReconcileJob].Status != 'Completed')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please wait for the current Reconcile job to complete and try again in some time.'));
            return;
        }
        
        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Reconcile Rollup Usage', 'Submitted');
        insert objLog;
        
        // Invoke batch Job to process Usage Data
        BatchReconcileRollupData objBatch = new BatchReconcileRollupData();
        objBatch.objJobLog = objLog;
        //***when test class is executed the batch limit should be restricted*/
		Integer intReconcileBatchSize = Integer.valueOf(Label.Billing_Reconcile_Batch_Size);
        idReconcileJob = Database.executeBatch(objBatch,intReconcileBatchSize);

        objLog.AsyncApexJob_Id__c = idReconcileJob;
        update objLog;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Reconcile Job started. Please wait for some time before running the same job again.'));
    }
    
  
    //*** Handler/Method for Run Rating Job ***
    public void runRatingJob()
    {
        // Block execution of job if another job of same type is not yet complete
        // idRatingJob Can Probably be deleted
        if(CloudBillingUtil.blnIsRatingJobRunning())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please wait for the current Rating job to complete and try again in some time.'));
            return;
        }
        
        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
        insert objLog;
        
        // Invoke batch Job to process Usage Data
        BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
        objBatch.objJobLog = objLog;
        //***when test class is executed the batch limit should be restricted*/
		Integer intRatingBatchSize = Integer.valueOf(Label.Billing_Rating_Batch_Size);
        idRatingJob = Database.executeBatch(objBatch,intRatingBatchSize);
        
        objLog.AsyncApexJob_Id__c = idRatingJob;
        update objLog;

        /*
        PushTopic pushTopic = new PushTopic();
        pushTopic.Name = 'RatingJobCompleteUpdate';
        String strQuery = 'select Id, Type__c, Status__c from Cloud_Billing_Log__c where Id = \'' + objLog.Id + '\'';
        pushTopic.Query = strQuery;
        System.Debug('pushTopic.Query strQuery: ' + strQuery);
        pushTopic.ApiVersion = 38.0;
        pushTopic.NotifyForOperationCreate = true;
        pushTopic.NotifyForOperationUpdate = true;
        pushTopic.NotifyForOperationUndelete = true;
        pushTopic.NotifyForOperationDelete = true;
        pushTopic.NotifyForFields = 'Referenced';
        insert pushTopic;
        */
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Rating Job started. Please wait for some time before running the same job again.'));
    }

    // iTracks 29871 Make the options check a single method
    public Boolean blnProperOptions() {
        // Perform  subsidiary check only if the job is not being run for an individual contract
        if(String.isBlank(strSubsidiary) && objJobLog.Contract__c == null && String.isBlank(strRegion) && String.isBlank(strEdition))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Subsidiary, Region and Edition. Or request a specific contract.'));
            System.Debug('blnProperOptions: Failed strSubsidiary ' + strSubsidiary + ' objJobLog.Contract__c ' + objJobLog.Contract__c +
                         ' strRegion' + strRegion + ' strEdition ' + strEdition);
            return false;
        }
        return true;
    }    

    //*** Handler/Method for Monthly Sales Order Creation Job ***
    public void runOrderCreationJob()
    {
        // Perform  subsidiary check only if the job is not being run for an individual contract
        // iTracks 29871
        if(!blnProperOptions()) {
            return;
        }
        if(String.isBlank(objJobLog.Day__c) || String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select day month and year to run Order Creation Job.'));
            return;
        }
        // Block execution of job if another job of same type is not yet complete
        if(idOrderCreationJob != null && [Select Status from AsyncApexJob where Id = :idOrderCreationJob].Status != 'Completed')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please wait for the current Order creation job to complete and try again in some time.'));
            return;
        }
        
        objJobLog.Type__c = 'Monthly Order Creation';
        objJobLog.Status__c = 'Submitted';
        objJobLog.User__c = UserInfo.getUserId();
        objJobLog.Time__c = DateTime.now();
        insert objJobLog;
        
        Integer intOrderBatchSize = Integer.valueOf(Label.Cloud_Monthly_Billing_Order_Batch_Size);
            
        // Invoke batch Job to create Monthly Sales order(s)
        if(objJobLog.Contract__c != null)
        {

            CloudBillingData info = new CloudBillingData(blnPreBill, objJobLog.Month__c, objJobLog.Year__c, objJobLog.Day__c);
            info.contractId = objJobLog.Contract__c;
            BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(info);
            objBatch.objJobLog = objJobLog;
            System.debug('runOrderCreationJob: Launch for Contract ' + objBatch);
            idOrderCreationJob = Database.executeBatch(objBatch, intOrderBatchSize);
            objJobLog.AsyncApexJob_Id__c = idOrderCreationJob;
            update objJobLog;
        }
        else
        {
            CloudBillingData info = new CloudBillingData(blnPreBill, objJobLog.Month__c, objJobLog.Year__c, objJobLog.Day__c);
            info.subsidiary = strSubsidiary;
            info.region = strRegion;
            info.edition = strEdition;
            BatchCreateCloudMonthlySalesOrders objBatch = new BatchCreateCloudMonthlySalesOrders(info);
            objBatch.objJobLog = objJobLog;
            System.debug('runOrderCreationJob: Launch for Bulk ' + objBatch);
            idOrderCreationJob = Database.executeBatch(objBatch, intOrderBatchSize);
            objJobLog.AsyncApexJob_Id__c = idOrderCreationJob;
            update objJobLog;
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Order Creation started. Please wait for some time before running the same job again.'));
        // Re-setting Id so that the object can be re-used to create another record
        objJobLog.Id = null;
    }

    public void runOrderLineItemTaxJob() {

        if (SureTax_Settings__c.getValues('SureTaxEnabled').Value__c != 'True') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'System not currently configured to tax through SureTax'));
            System.Debug('runOrderLineItemTaxJob: SureTax not Enabled');
            return;
        }
        if(!blnProperOptions()) {
            System.Debug('runOrderLineItemTaxJob: Improper Options');
            return;
        }
        if(String.isBlank(objJobLog.Day__c) || String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select day month and year to run Order Creation Job.'));
            return;
        }
        objJobLog.Type__c = 'Order Line Tax Creation';
        objJobLog.Status__c = 'Submitted';
        objJobLog.User__c = UserInfo.getUserId();
        objJobLog.Time__c = DateTime.now();
        objJobLog.Id = null;
        insert objJobLog;

        Set<String> setOfEntitiesToTax = CloudBillingUtil.getSetOfStringsByCommaSeperated(Label.Cloud_Billing_Tax_Subsidiaries);
        System.Debug('setOfEntitiesToTax: ' + setOfEntitiesToTax);
        if(objJobLog.Contract__c != null) {
            GCR_Content_Document_Detail__c objContractCheck = [select Account_Name__r.Name, Account_Name__r.Subsidary__r.Name
                                                               from GCR_Content_Document_Detail__c
                                                               where Id = :objJobLog.Contract__c];
            if (!setOfEntitiesToTax.contains(objContractCheck.Account_Name__r.Subsidary__r.Name)) {
                String strError = 'Contract account ' + objContractCheck.Account_Name__r.Name + ' subsidiary is ' + objContractCheck.Account_Name__r.Subsidary__r.Name + 
                                                           ' and is therefore not taxable. Configured only for ' + Label.Cloud_Billing_Tax_Subsidiaries + '.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strError));
                System.Debug('runOrderLineItemTaxJob: strError ' + strError);
                return;
            }
            CloudBillingData info = new CloudBillingData(false, objJobLog.Month__c, objJobLog.Year__c, objJobLog.Day__c);
            info.contractId = objJobLog.Contract__c;
            BatchTaxCloudUsageData objBatch = new BatchTaxCloudUsageData(BatchTaxCloudUsageData.PROCESS_ORDER_LINE_SURETAX, info);
            objBatch.objJobLog = objJobLog;
            System.debug('runOrderLineItemTaxJob: Launch for Contract ' + objBatch);
            //Due to API callouts, process only one contract at a time
            objJobLog.AsyncApexJob_Id__c = Database.executeBatch(objBatch, 1);
            update objJobLog;
        } else {
            if (strSubsidiary == 'All' || !setOfEntitiesToTax.contains(strSubsidiary)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please chose a specific Subsidiary to tax from ' + Label.Cloud_Billing_Tax_Subsidiaries));
                return;
            }
            CloudBillingData info = new CloudBillingData(false, objJobLog.Month__c, objJobLog.Year__c, objJobLog.Day__c);
            info.subsidiary = strSubsidiary;
            info.region = strRegion;
            info.edition = strEdition;
            BatchTaxCloudUsageData objBatch = new BatchTaxCloudUsageData(BatchTaxCloudUsageData.PROCESS_ORDER_LINE_SURETAX, info);
            objBatch.objJobLog = objJobLog;
            System.debug('runOrderLineItemTaxJob: Launch for Bulk ' + objBatch);
            System.debug('objJobLog: ' + objJobLog);
            //Due to API callouts, process only one contract at a time
            objJobLog.AsyncApexJob_Id__c = Database.executeBatch(objBatch, 1);
            update objJobLog;
        }

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Order Line Item Tax Job started. Please wait for some time before running the same job again.'));
        // Re-setting Id so that the object can be re-used to create another record
        objJobLog.Id = null;
    }    
    //*** Handler/Method for Monthly Invoice Creation Job ***
    public void runInvoiceCreationJob()
    {
        // Perform  subsidiary check only if the job is not being run for an individual contract
        // iTracks 29871
        if(!blnProperOptions()) {
            return;
        }
        // Forbid certain products as we phase out invoices from Cloud Billing in favor of NetSuite
        if(CloudBillingUtil.getSetOfStringsByCommaSeperated(Label.Cloud_Billing_Editions_No_Invoices).contains(strEdition)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Edition ' + strEdition + ' no longer uses Cloud Billing Invoices'));
            return;
        }
        if(String.isBlank(objJobLog.Day__c) || String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select day month and year to run Invoice Creation Job.'));
            return;
        }
        // Block execution of job if another job of same type is not yet complete
        if(idInvoiceCreationJob != null && [Select Status from AsyncApexJob where Id = :idInvoiceCreationJob].Status != 'Completed')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please wait for the current Invoice creation job to complete and try again in some time.'));
            return;
        }
        if(objJobLog.Contract__c != null) {
            GCR_Content_Document_Detail__c objContract = [select Product_Group__c from GCR_Content_Document_Detail__c where Id = :objJobLog.Contract__c];
            if (objContract!= null) {
                if (CloudBillingUtil.getSetOfStringsByCommaSeperated(Label.Cloud_Billing_Editions_No_Invoices).contains(objContract.Product_Group__c)) {
                    String strError = 'Edition ' + objContract.Product_Group__c + ' no longer uses Cloud Billing Invoices';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                    System.Debug(strError);
                    return;
                } else {
                    System.Debug('Edition ' + objContract.Product_Group__c + ' still uses Cloud Billing Invoices');
                }
            }
        }        
        objJobLog.Type__c = 'Monthly Invoice Creation';
        objJobLog.Status__c = 'Submitted';
        objJobLog.User__c = UserInfo.getUserId();
        objJobLog.Time__c = DateTime.now();
        insert objJobLog;
        
        // Invoke batch Job to create Monthly Invoice(s)
        // iTracks 29871 Simplify to use the BatchCreateCloudMonthlySalesOrdersInfo object
        CloudBillingData info = new CloudBillingData(blnPreBill, objJobLog.Month__c, objJobLog.Year__c, objJobLog.Day__c);

        if(objJobLog.Contract__c != null) {
            info.contractId = objJobLog.Contract__c;
        } else {
            info.subsidiary = strSubsidiary;
            info.region = strRegion;
            info.edition = strEdition;
        }
        BatchInvoicePDFAttach objBatchInvoiceAttach = new BatchInvoicePDFAttach(info);
        objBatchInvoiceAttach.objJobLog = objJobLog;
        idInvoiceCreationJob = Database.executeBatch(objBatchInvoiceAttach,50);
        objJobLog.AsyncApexJob_Id__c = idInvoiceCreationJob;
        upsert objJobLog;

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Invoice Creation started. Please wait for some time before running the same job again.'));
        // Re-setting Id so that the object can be re-used to create another record
        objJobLog.Id = null;
    }
    
    //*** Handler/Method for Invoice Distribution via email ***
    public void sendInvoicesHandler()
    {
        // Perform  subsidiary check only if the job is not being run for an individual contract
        if(!blnProperOptions()) {
            return;
        }
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to run Invoice Distribution Job.'));
            return;
        }
        
        objJobLog.Type__c = 'Invoice Email Distribution';
        objJobLog.Status__c = 'Submitted';
        objJobLog.User__c = UserInfo.getUserId();
        objJobLog.Time__c = DateTime.now();

        insert objJobLog;
        
        CloudBillingData info = new CloudBillingData();
        if(objJobLog.Contract__c != null) {
            info.contractId = objJobLog.Contract__c;
        } else {
            info.subsidiary = strSubsidiary;
            info.region = strRegion;
            info.edition = strEdition;
        }

        BatchSendInvoices objBatchSendInvoices = new BatchSendInvoices(info, objJobLog);
        
        Id iDSendInvoices = Database.executeBatch(objBatchSendInvoices,5);
        objJobLog.AsyncApexJob_Id__c = iDSendInvoices;
        upsert objJobLog;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Send Invoice Job started. Please wait for some time before running the same job again.'));
        // Re-setting Id so that the object can be re-used to create another record
        objJobLog.Id = null;
    }
    
    // *** View Monthly Orders by month button handler ***
    public PageReference viewOrdersByMonth()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view usage report.'));
            return null;
        }
        return (new PageReference('/' + Label.Monthly_Billing_Orders_By_Month + '?&pv1=' + objJobLog.Month__c + '&pv2=' + objJobLog.Year__c));
    }
    
    // *** View Monthly Invoices button handler ***
    public PageReference viewInvoicesByMonth()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view usage report.'));
            return null;
        }
        return (new PageReference('/' + Label.Monthly_Invoices + '?&pv0=' + objJobLog.Month__c + '&pv1=' + objJobLog.Year__c));
    }
    
    // *** View Monthly Reconciliation button handler ***
    public PageReference viewReconciliationByMonth()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view reconciliation report.'));
            return null;
        }
        return (new PageReference('/' + Label.Monthly_Reconciliation_Report_Id + '?&pv0=' + objJobLog.Month__c + '&pv1=' + objJobLog.Year__c));
    }

        // *** View Monthly Orders by month button handler ***
    public PageReference viewInstallmentOrdersByMonth()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view usage report.'));
            return null;
        }
        return (new PageReference('/' + Label.Monthly_Installment_Orders_By_Month + '?&pv1=' + objJobLog.Month__c + '&pv2=' + objJobLog.Year__c));
    }

    public PageReference viewPureConnectBurstExpectedFilesCS()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select billing year to PureConnect Burst Expected Files CS.'));
            return null;
        }
        return (new PageReference('/' + Label.Billing_PureConnect_Burst_Expected_Files_CS + '?&pv0=' + objJobLog.Year__c));
    }

    public PageReference viewPureEngageBurstExpectedFilesCS()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select billing year to PureEngage Burst Expected Files CS.'));
            return null;
        }
        return (new PageReference('/' + Label.Billing_PureEngage_Burst_Expected_Files_CS + '?&pv0=' + objJobLog.Year__c));
    }

        // *** View Monthly Orders by month button handler ***
    public PageReference viewDeferredOrdersByMonth()
    {
        if(String.isBlank(objJobLog.Month__c) || String.isBlank(objJobLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view deferred orders by month report.'));
            return null;
        }
        return (new PageReference('/' + Label.Monthly_Deferred_Orders_By_Month + '?&pv1=' + objJobLog.Month__c + '&pv2=' + objJobLog.Year__c));
    }

    //*** Method to fetch Upgrades/Downgrades that need to be synced with Contracts ***
    public void fetchUpgradesDowngrades()
    {
        System.debug('fetchUpgradesDowngrades: upgradeDowngradeSearchQuery ' + upgradeDowngradeSearchQuery);
        // iTracks 24805 Make query dynamic string to make region selection optional
        String strQuery = 'SELECT Id,Name,Quote__c,Quote__r.BigMachines__Opportunity__c,CreatedDate,Quote__r.End_User_ID__c,Quote__r.Contracts__c,Quote__r.BigMachines__Opportunity__r.name'
            //ECD
                        + ',Order__c.Offering_Type__c,Order__c.PO_Number__c'
                        + ' FROM Order__c WHERE '
            			+ Label.Billing_Orders_Query_Condition_Amendment;
            //((RecordType.Name = \'Cloud Billing Master Order\' AND (Status__c = \'Approved\' OR Status__c = \'Completed\')' 
            //            + ' AND Quote__r.Upgrade_Type__c != null AND Synced_with_Contract__c = false'
            //            + ' AND Quote__r.BigMachines__Opportunity__r.RecordType.Name = \'Upgrade Downgrade\') OR (Quote__r.Contracts__c != null and Quote__r.Order_Type__c = \'Amend Subscription\'))';

        if (String.isNotBlank(strRegionContractFilter)) {
            strQuery += ' AND End_User_Name__r.Country__r.Region__c = \'' + strRegionContractFilter + '\'';
        }

        // Search by Choosen Fields.
        if(String.isNotBlank(upgradeDowngradeSearchQuery))
            strQuery += ' '+ upgradeDowngradeSearchQuery +' ';
        
        // Sort by choosen Field
        if(sortOnUpgradeDowngrade != sortDirectionToUpgradeDowngrade)
        strQuery += ' ORDER BY '+ sortOnUpgradeDowngrade + ' '+ sortDirectionToUpgradeDowngrade + ' NULLS LAST';
        
        System.Debug('(Upgrade Downgrade) Amendments Query ' + strQuery);
        list_UpgradesDowngrades = new List<Order__c>();
        list_UpgradesDowngrades = Database.query(strQuery);
        System.Debug('(Upgrade Downgrade) Amendments Query Results Count ' + list_UpgradesDowngrades.size());
        
    }
    
    //*** Method to fetch Renewals that need to be synced with Contracts ***
    public void fetchRenewals()
    {
        // iTracks 24805 Make query dynamic string to make region selection optional
        String strQuery = 'SELECT Id,Name,Quote__c,Quote__r.BigMachines__Opportunity__c,CreatedDate,Quote__r.End_User_ID__c,Quote__r.Contracts__c,Quote__r.BigMachines__Opportunity__r.name'
                        + ',Order__c.Offering_Type__c,Order__c.PO_Number__c'
                        + ' FROM Order__c WHERE '
            			+ Label.Billing_Orders_Query_Condition_Renewal;

        if (String.isNotBlank(strRegionContractFilter)) {
            strQuery += ' AND End_User_Name__r.Country__r.Region__c = \'' + strRegionContractFilter + '\'';
        }

        // Search by Choosen Fields.
        if(String.isNotBlank(renewalSearchQuery))
            strQuery += ' '+ renewalSearchQuery +' ';
        
        // Sort by choosen Field
        if(sortOnRenewal != sortDirectionToRenewal)
        strQuery += ' ORDER BY '+ sortOnRenewal + ' '+ sortDirectionToRenewal + ' NULLS LAST';
        
        System.Debug('Renewals Query ' + strQuery);
        list_Renewals = new List<Order__c>();
        list_Renewals = Database.query(strQuery);
        System.Debug('Renewals Query Results Count ' + list_Renewals.size());
        
    }

    // *** Mark Synced button handler ***
    public void markOrderAsSynced()
    {
        try
        {
            // Setting this flag to avoid trigger executions
            Util.Bypass_Trigger_Chk = true;
            update (new Order__c(Id = strOrderId,Synced_with_Contract__c = true));
            fetchUpgradesDowngrades();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    //*** Method to fetch new fetch Master Orders to be set up as Billing Contracts ***
    public void fetchNewMasterOrders()
    {
        list_NewMasterOrdersFiltered = new List<Order__c>();
        if(list_NewMasterOrders != NULL)
        System.debug('Old List of list_NewMasterOrders : '+list_NewMasterOrders.size());
        // iTracks 24805 Make query dynamic string to make region selection optional
        String strQuery = 'SELECT Id, Name, Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__c, Zuora_Quote__r.zqu__Account__c,'
                         + ' Quote__c, Quote__r.BigMachines__Opportunity__c, Quote__r.End_User_ID__c,'
                         + ' CreatedDate, Offering_Type__c, PO_Number__c, End_User_Name__r.Country__r.Region__c, '
                         + ' Quote__r.Name, Zuora_Quote__r.Name, '
                         + ' Quote__r.End_User_ID__r.Name, Zuora_Quote__r.zqu__Account__r.Name, '
                         + ' Quote__r.BigMachines__Opportunity__r.Name, Zuora_Quote__r.zqu__Opportunity__r.Name '
                         + ' FROM Order__c' 
                         + ' WHERE ' +System.Label.Billing_Contract_Orders_Query_Condition;//replaced where condition with system label

        if (String.isNotBlank(strRegionContractFilter)) {
            strQuery += ' AND End_User_Name__r.Country__r.Region__c = \'' + strRegionContractFilter + '\'';
        }
        
        // Search by Choosen Fields.
        if(String.isNotBlank(billingContractSearchQuery))
            strQuery += ' '+ billingContractSearchQuery +' ';
        
        // Sort by choosen Field except for Account, Opportuntiy and Quote.
        if(sortOnBillingContract != sortDirectionToBillingContract){
            System.debug('Sort on Billing Contract -> Sort By: '+sortOnBillingContract);
            System.debug('Sort on Billing Contract -> Sort Direction: '+sortDirectionToBillingContract);
            if(sortOnBillingContract != 'Account' && sortOnBillingContract != 'Quote'
              && sortOnBillingContract != 'Opportunity'){
                strQuery += ' ORDER BY '+ sortOnBillingContract + ' '+ sortDirectionToBillingContract + ' NULLS LAST';
            }
        }
        strQuery += ' LIMIT 100';
        System.Debug('New Master Order Query ' + strQuery);
        list_NewMasterOrders = Database.query(strQuery);
        System.debug('New List of list_NewMasterOrders :'+list_NewMasterOrders.size());
        
        // Sort by choosen field only if Account, Opportunity and Quote.
        if(sortOnBillingContract == 'Account'){
            System.debug('In Account Sort');
            list_NewMasterOrders = getSortedOrderList(getOrderMap(list_NewMasterOrders, 'Account'),
                                                      sortDirectionToBillingContract);
        }
        else if(sortOnBillingContract == 'Opportunity'){
            System.debug('In Opportunity Sort');
            list_NewMasterOrders = getSortedOrderList(getOrderMap(list_NewMasterOrders, 'Opportunity'),
                                                      sortDirectionToBillingContract);
        }
        else if(sortOnBillingContract == 'Quote'){
            System.debug('In Quote Sort');
            list_NewMasterOrders = getSortedOrderList(getOrderMap(list_NewMasterOrders, 'Quote'),
                                                      sortDirectionToBillingContract);           
        }
        //limit the display size to 25
        for(Order__c objOrder:list_NewMasterOrders){
            if(list_NewMasterOrdersFiltered.size()<25){
                list_NewMasterOrdersFiltered.add(objOrder);
            }
        }
    }
    
    @TestVisible
    private Map<String,Order__c> getOrderMap(List<Order__c> list_Orders, String sortByField){
        Map<String,Order__c> orderSortMap = new Map<String,Order__c>();
        for(Order__c orderInfo : list_Orders){
            if(sortByField == 'Account'){
                if(orderInfo.Quote__c!=null){
                    orderSortMap.put(orderInfo.Quote__r.End_User_ID__r.Name+'#'+orderInfo.id, orderInfo);
                }else if(orderInfo.Zuora_Quote__c!=null){
                    orderSortMap.put(orderInfo.Zuora_Quote__r.zqu__Account__r.Name+'#'+orderInfo.id, orderInfo);
                }
            }else if(sortByField == 'Opportunity'){
                if(orderInfo.Quote__c!=null){
                    orderSortMap.put(orderInfo.Quote__r.BigMachines__Opportunity__r.Name+'#'+orderInfo.id, orderInfo);
                }else if(orderInfo.Zuora_Quote__c!=null){
                    orderSortMap.put(orderInfo.Zuora_Quote__r.zqu__Opportunity__r.Name+'#'+orderInfo.id, orderInfo);
                }
            }else if(sortByField == 'Quote'){
                if(orderInfo.Quote__c!=null){
                    orderSortMap.put(orderInfo.Quote__r.Name+'#'+orderInfo.id, orderInfo);
                }else if(orderInfo.Zuora_Quote__c!=null){
                    orderSortMap.put(orderInfo.Zuora_Quote__r.Name+'#'+orderInfo.id, orderInfo);
                }
            }
            
        }
        return orderSortMap;
    }
    
    @TestVisible
    private List<Order__c> getSortedOrderList(Map<String,Order__c> orderMap, String sortDirection){
        List<Order__c> sortedList = new List<Order__c>();
        
        List<String> sortedKeys = new List<String>(orderMap.keySet());
        sortedKeys.sort();
        System.debug('Sorted Keys :' + sortedKeys);
        if(sortDirection == 'ASC'){
            for(String key : sortedKeys)
                sortedList.add(orderMap.get(key));
        }else{
            for(integer i = sortedKeys.size() - 1 ; i > -1 ; i--){
                sortedList.add(orderMap.get(sortedKeys[i]));
            }
        }
        System.debug('Sorted List: '+sortedList);
        return sortedList;
    }
    
    // *** Create Billing Contract for new quote/order ***
    public void createBillingContract()
    {
        System.Debug('createBillingContract: Enter looking for strOrderId ' + strOrderId);
        try{
            // Setting this flag to avoid trigger executions
            Util.Bypass_Trigger_Chk = true;

            List<Order__c> listAllPageOrders = new List<Order__c>();
            listAllPageOrders.addAll(list_NewMasterOrders);
            listAllPageOrders.addAll(list_UpgradesDowngrades);
            listAllPageOrders.addAll(list_Renewals);

            for(Order__c objOrder : listAllPageOrders)
            {
                if(objOrder.Id == strOrderId)
                {
                    System.Debug('createBillingContract: Found Order ' + objOrder);
                    strOfferingType = objOrder.Offering_Type__c.contains('Subscription')?objOrder.Offering_Type__c:null;
                    List<GCR_Content_Document_Detail__c> list_ExistingContract = [SELECT Name 
                                                                                  FROM GCR_Content_Document_Detail__c 
                                                                                  WHERE Status__c = 'Approved' 
                                                                                    AND Account_Name__c = :objOrder.Quote__r.End_User_ID__c
                                                                                    AND Document_Name__c = 'Cloud Billing Contract' LIMIT 1];
                  
                  if(!list_ExistingContract.isEmpty())
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                                                   'A Billing Contract already exists with the customer. ' + list_ExistingContract[0].Name));
                    
                    //Added by Ranjith on May 19 -- Starts
                    //Logic to find if Telco prodcuts exists or not for Zuora Quotes
                    /*
                    Boolean blnOnlyTelcoProducts = true;
                    Boolean blnHasTelcoProducts = false;
                    if(objOrder.Zuora_Quote__c != null) {
                        for(Order_Line_Item__c objOLI : [SELECT Id, Product__r.Product_Category__c
                                                         FROM Order_Line_Item__c 
                                                         WHERE Order__c =: objOrder.Id]) {
                            if(objOLI.Product__r.Product_Category__c != 'Voice Services') {                                     
                                blnOnlyTelcoProducts = false;
                            }
                            else {
                                blnHasTelcoProducts = true;
                            }
                        }                                                                       
                    }
                    */
                    //Added by Ranjith on May 19 -- Ends
                    
                    // Create Cloud Billing Contract
                    List<GCR_Content_Document_Detail__c> list_NewContracts = new List<GCR_Content_Document_Detail__c>();
                    GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
                    objContract.Account_Name__c = objOrder.Quote__c != null ? objOrder.Quote__r.End_User_ID__c : objOrder.Zuora_Quote__r.zqu__Account__c;
                    objContract.Document_Name__c = 'Cloud Billing Contract';
                    objContract.Quote__c = objOrder.Quote__c;
                    objContract.CurrencyIsoCode = objOrder.Quote__r.CurrencyIsoCode;
                    //objContract.Zuora_Quote__c = objOrder.Zuora_Quote__c;
                    objContract.PO__c = objOrder.PO_Number__c;
                    objContract.Order_Date_Option__c = 'Last Day of Usage Month';
                    objContract.Status__c = 'New';
                    objContract.Active__c = true;

                    list_NewContracts.add(objContract);                    
                    insert list_NewContracts;
                    
                    //Added by Nitin to add Account Address for the new contracts                                   
                    List<Account_Order_Address__c> lst_Acc_Add_new = new List<Account_Order_Address__c>();                    
                    for(GCR_Content_Document_Detail__c objConrtact : list_NewContracts ){                        
                        Account_Order_Address__c objAddress = new Account_Order_Address__c();                        
                        
                        if(objOrder.Quote__c!=null){
                            List<Account_Order_Address__c> list_BillingAddress = [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                    Zip_Code__c, Phone__c, Fax__c, Email__c,Additional_Emails__c,Attention_To__c, Order__c, Quote__c, Zuora_Quote__c
                                    FROM Account_Order_Address__c WHERE (Quote__c = :objOrder.Quote__c) 
                                                                  and Address_Type__c = 'Bill To' LIMIT 1];                            
                            
                            if(list_BillingAddress.size()!=0){
                                objAddress = list_BillingAddress[0];
                            }
                        }else if(objOrder.Zuora_Quote__c!=null){
                            List<Account_Order_Address__c> list_BillingAddress = [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                    Zip_Code__c, Phone__c, Fax__c, Email__c,Additional_Emails__c,Attention_To__c, Order__c, Quote__c, Zuora_Quote__c
                                    FROM Account_Order_Address__c WHERE (Zuora_Quote__c = :objOrder.Zuora_Quote__c) 
                                                                  and Address_Type__c = 'Bill To' LIMIT 1];                            
                            
                            if(list_BillingAddress.size()!=0){
                                objAddress = list_BillingAddress[0];
                            }
                        }
                        objAddress.Id = NULL;
                        objAddress.GCR_Content_Document_Detail__c = objConrtact.Id;
                        objAddress.Order__c = null;
                        objAddress.Quote__c = null;
                        objAddress.Zuora_Quote__c = null;
                        objAddress.CurrencyIsoCode = objOrder.CurrencyIsoCode;
                        objAddress.Address_Type__c = 'Bill To';
                        
                        lst_Acc_Add_new.add(objAddress);
                        
                    //Nitin Jun 19 code to import contract information - Starts Here
                    // Offering Type is needed in the CloudBillingUtil.resetServiceInfoFromQuote method.
                    // Load everything assigned initially plus the Offering_Type__c
                    objContract = [select Account_Name__c, Document_Name__c, Quote__c, Quote__r.Offering_Type__c, CurrencyIsoCode, PO__c, Order_Date_Option__c, Status__c, Active__c
                                   from GCR_Content_Document_Detail__c
                                   where id = :objContract.Id];
                    System.Debug('createBillingContract: sending objConrtact ' + objConrtact +
                                 ' objConrtact.Quote__r.Offering_Type__c ' + objConrtact.Quote__r.Offering_Type__c +
                                 ' strOfferingType ' + strOfferingType);
                    CloudBillingUtil.resetServiceInfoFromQuote(objConrtact,strOfferingType);                   
                    //Nitin Jun 19 code to import contract information - Ends Here
                        
                    }
                    //Insert the new address
                    Insert lst_Acc_Add_new;
                    
                    // Update Order synced flag
                    objOrder.Synced_with_Contract__c = true;
                    update objOrder;
                    
                    break;
                }
            }
            fetchNewMasterOrders();
            fetchUpgradesDowngrades();
            fetchRenewals();
            fetchContracts();            
        }       
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    // *** Method to check if there are any recent rating exceptions ***
    @TestVisible
    private void checkExceptions()
    {
        blnHasRatingExceptions = false;
        if([SELECT Id FROM Cloud_Billing_Exception__c WHERE CreatedDate >= LAST_MONTH AND Resolved__c = false ORDER BY CreatedDate DESC LIMIT 1].size() > 0)
            blnHasRatingExceptions = true;
    }
    
    // *** Method to check the Permission set assigned to the running user ***
    @TestVisible
    private void checkPermissions()
    {
        blnIsContractApprover = blnIsContractManager = blnIsContractReadOnly = false;
        for(PermissionSetAssignment objPSA : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND 
                                              (PermissionSet.Name in ('Cloud_Billing_Contract_Manager', 'Cloud_Billing_Contract_Approver',
                                                                     'Cloud_Billing_Contract_Read_Only'))])
        {
            if(objPSA.PermissionSet.Name == 'Cloud_Billing_Contract_Manager')
                blnIsContractManager = true;
            else if(objPSA.PermissionSet.Name == 'Cloud_Billing_Contract_Approver')
                blnIsContractApprover = true;
            else if(objPSA.PermissionSet.Name == 'Cloud_Billing_Contract_Read_Only')
                blnIsContractReadOnly = true;
            // fall out of logic no permission set
        }
    }
    
    private final String strAccountFieldName = 'Quote__r.End_User_ID__r.Name';
    private final String strOpportunityFieldName = 'Quote__r.BigMachines__Opportunity__r.Name';
    private final String strProductFieldName = 'Offering_Type__c';
    private final String strQuoteFieldName = 'Quote__r.Name';
    private final String strOrderFieldName = 'Name';

    private String fetchWhereClause(String strSelectedField, String strSearchValue) {
        String likeValue = ' LIKE \'%' + strSearchValue + '%\'';
        if(strSelectedField == 'All')
            return ' AND ('
            + strAccountFieldName + likeValue + ' OR '
            + strOpportunityFieldName + likeValue + ' OR '
            + strProductFieldName + likeValue + ' OR '
            + strQuoteFieldName + likeValue + ' OR '
            + strOrderFieldName + likeValue + ')';

        if(strSelectedField == 'Account')
            return ' AND ' + strAccountFieldName + likeValue;
        
        if(strSelectedField == 'Opportunity')
            return ' AND ' + strOpportunityFieldName + likeValue;
        
        if(strSelectedField == 'Product')
            return ' AND ' + strProductFieldName + likeValue;

        if(strSelectedField == 'Quote')
            return ' AND  ' + strQuoteFieldName + likeValue;
        
        if(strSelectedField == 'Order')
            return ' AND ' + strOrderFieldName + likeValue;
        
        return '';
    }

    public void fetchBillingContractBySearchValue(){

        billingContractSearchQuery = fetchWhereClause(billingContractSelectedField, billingContractSeachValue);
        System.debug('fetchBillingContractBySearchValue: billingContractSearchQuery ' + billingContractSearchQuery);
        fetchNewMasterOrders();
        return;
    }
    
    public void clearBillingContractBySearchValue(){
        billingContractSearchQuery = '';
        fetchNewMasterOrders();
    }
    
    public void fecthUpgradeDowngradeBySearchValue(){

        upgradeDowngradeSearchQuery = fetchWhereClause(upgradeDowngradeSelectedField, upgradeDowngradeSeachValue);
        System.debug('fecthUpgradeDowngradeBySearchValue: upgradeDowngradeSearchQuery ' + upgradeDowngradeSearchQuery);
        fetchUpgradesDowngrades();
        return;
    }
    
    public void clearUpgradeDowngradeBySearchValue(){
        upgradeDowngradeSearchQuery = '';
        fetchUpgradesDowngrades();
    }

    public void fetchRenewalBySearchValue() {

        renewalSearchQuery = fetchWhereClause(renewalSelectedField, renewalSeachValue);
        System.debug('fetchRenewalBySearchValue: renewalSearchQuery ' + renewalSearchQuery);
        fetchRenewals();
        return;
    }
    
    public void clearRenewalBySearchValue(){
        renewalSearchQuery = '';
        fetchRenewals();
    }

}