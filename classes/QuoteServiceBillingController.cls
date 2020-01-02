public with sharing class QuoteServiceBillingController
{
    // MAX Cloud Deployment List Size
    private final Integer MAX_CLOUD_DEPLOYMENT_LIST_SIZE = 50;
    // Contract
    @testVisible
    public GCR_Content_Document_Detail__c objContract {get; private set;}
    // Contract Pricing End Date - Show in UI ass last day of month, store in object first of next month
    public GCR_Content_Document_Detail__c objContractPricingEndDate {get; set;}
    
    // Contract Tenant Ids not necessarily assigned to this contract
    public List<Cloud_Deployment__c> list_TenantId {get; private set;}
    // Contract Subscriber Ids not necessarily assigned to this contract
    public List<Cloud_Deployment__c> list_SubscriberId {get; private set;}
    // Contract Portico Ids not necessarily assigned to this contract
    public List<Cloud_Deployment__c> list_PorticoId {get; private set;}
    // PureConnect Ids not necessarily assigned to this contract
    public List<Cloud_Deployment__c> list_PureConnectId {get; private set;}
    // PureCloud Ids not necessarily assigned to this contract
    public List<Cloud_Deployment__c> list_PureCloudId {get; private set;}
    // Billing Platform Ids not necessarily assigned to this contract
    public List<Cloud_Deployment__c> list_BillingPlatformId {get; private set;}
    // Billing Address selected on related quote
    public Account_Order_Address__c objBillingAddress {get; set;}
    // Client Product Mappings for all Cloud Deployments
    public List<Client_Product_Mapping__c> list_ClientProductMappings {get; set;}
    
    // Set of Contract Ids that have the same Platform Ids also assigned to them.
    private Set<Id> setContractsWithSamePlatformIds;
    
    
    // Legal documents associated with the Contract
    public List<GCR_Content_Document_Detail__c> list_Documents {get; private set;}
    // List of Tier Set Wrapper rows under Tier Set Configuration tab
    public List<TierSetWrapper> list_TierSetWrappers {get; set;}
    // For Index of Tier Row to determine which record is being removed
    public String strTierIndex {get; set;}
    // For Index of Tier Range/Contract Service/Recurring Charge to determine which record is being removed
    public String strRowIndex {get; set;}
    // To indicate whether Tier Set Configuration is in edit mode
    public Boolean blnIsEdit {get; private set;}
    // To indicate whether BOGO Info is in edit mode
    public Boolean blnIsBOGOEdit {get; private set;}
    // List of Drop-down options for Related Tier Set Selection
    public List<SelectOption> list_TierSetOptions {get; set;}
    // To indicate whether this contract has any rating exceptions
    public Boolean blnHasRatingExceptions {get; private set;}
    // Day of the month the contract starts
    public Integer intContractStartDay {get; private set;}
    
    // Rating Jobs
    //public List<AsyncApexJob> list_ratingJobs {get; private set;}
    
    // *** To store records which have been removed/deleted by the user ***
    List<Contract_Tier_Range__c> list_ContractTierRangesBeingRemoved;
    List<Contract_Service__c> list_ContractServicesBeingRemoved;
    List<Contract_Recurring_Charge__c> list_ContractRecChargesBeingRemoved;
    List<Contract_Tier_Set__c> list_TierSetsBeingRemoved;
    List<BOGO_Detail__c> list_BOGODetailsBeingRemoved;
    
    // To capture Month and Year for usage report
    public Cloud_Billing_Log__c objLog {get; set;}
    
    //Nitin - Year Month
    public String RerateYearMonthSelection {get; set;}
    public List<SelectOption> RerateTimeperiodoptions {get; set;}
    
    // *** Re-Rate ***
    public Cloud_Billing_Log__c objRerateLog {get; set;}
    // Variables for launching reports
    public Cloud_Billing_Log__c objReportJobLog {get; set;}
    
    // *** Rate *** - Added by Vijay - CRMBILL-104
    public Cloud_Billing_Log__c objRateLog {get; set;}
    
    // To indicate whether the running user has Contract Super User permission set
    public Boolean blnIsContractSuperUser {get; private set;}
    // To indicate whether the running user has Contract Approver permission set
    public Boolean blnIsContractApprover {get; private set;}
    // To indicate whether the running user has Contract Manager permission set
    @testVisible
    public Boolean blnIsContractManager {get; private set;}
    // To indicate whether the running user has Contract Read Only permission set
    public Boolean blnIsContractReadOnly {get; private set;}
    
    // List of available Carriers in the Tier Set Dropdown
    public List<String> listCarrierDropdown {get; private set;}
    
    // List of Subscriber Id's for the contract for use in Report Request creation
    public List<SelectOption> list_SelectPlatformIds {get; private set;}
    
    // iTrack 24901
    // New Report Request
    public Cloud_Billing_Report_Request__c objNewReportRequest {get; set;}
    // List of Existing Report Requests for this contract
    public List<Cloud_Billing_Report_Request__c> list_CloudBillingReportRequest {get; private set;}
    
    // Input for selecting carrier in Contract Tier Set
    public List<SelectOption> list_TierSetCarriersToSelect {get; private set;}    
    
    // Input for selecting multiple Platform Ids
    public List<String> list_SelectedPlatformIds; 
    public String[] getList_SelectedPlatformIds() {
        return list_SelectedPlatformIds;
    }
    public void setList_SelectedPlatformIds(String[] list_SelectedPlatformIds) {
        this.list_SelectedPlatformIds = list_SelectedPlatformIds;
    }
    
    public Map<Id, zqu__QuoteRatePlan__c> map_QuoteRatePlan { get; set; }
    public Map<Id, zqu__QuoteChargeDetail__c> map_QPIdToQPRecord { get; set; }
    public Map<Id, Id> map_QtChrgeDtlToPrdRtPlChrge { get; set; }    
    public Map<Id,Id> map_ProdIdToQPId { get; set; }    
    public Map<Id, zqu__QuoteRatePlanCharge__c> map_PrdRtPlChrgeToQtRtPlChrge { get; set; } 
    
    
    // *** Id of Batch Job : To prevent concurrent jobs from being kicked off ***
    Id idReRateJob;
    
    // Attachment Variables
    public blob Attach {get;set;}  
    public String strUploadedfileName {get;set;}
    @TestVisible
    public List<Attachment> list_contractAttachments {get; private set;}
    private String cid;

    //Boolean field to display Zuora Net Price and Quantitiy
    public Boolean blnDispZuNetprQuantitiy {get;set;}
    
    //List of Quotes Associated with the contract
    public list<BigMachines__Quote__c> list_RelatedQuotes{get;set;}
    
	//ECD Initial investigation for dynamic multi-picklist
	public List<String> selectableTierSetNames { get; set; }
    public String strSelectedTierSets { get; set; }
    public List<SelectOption> listSelectedTierSets { get; set; }
    public List<CommitmentWrapper> listBillingCommitments { get; set; }

    public class CommitmentWrapper
    {
        public Billing_Setup_Commitment__c objBillingCommitment {get; set;}
        public List<Billing_Setup_Commitment_Tier_Set__c> listCommitmentTierSetAssignment {get; set;}
        public List<TierSetWrapper> listCommitmentTierSetWrapper {get; set;}

        public CommitmentWrapper(Billing_Setup_Commitment__c objBillingCommitment, List<TierSetWrapper> listAllBillingSetupTierSetWrappers) {
            System.Debug('CommitmentWrapper ctor');
            this.objBillingCommitment = objBillingCommitment;
            this.listCommitmentTierSetAssignment = objBillingCommitment.Billing_Setup_Commitment_Tier_Sets__r;

            // Create a set of the actual Tier Set Assignments to the Tier Set Wrapper
            Set<Id> setTierSetsAssigned = new Set<Id>();
            for (Billing_Setup_Commitment_Tier_Set__c objBillingSetupCommitmentTierSet : objBillingCommitment.Billing_Setup_Commitment_Tier_Sets__r) {
                setTierSetsAssigned.add(objBillingSetupCommitmentTierSet.Billing_Setup_Tier_Set__c);
            }

            this.listCommitmentTierSetWrapper = new List<TierSetWrapper>();
            for (TierSetWrapper objTierSetWrapperMain : listAllBillingSetupTierSetWrappers) {
                System.Debug(' Sent in wrapper objTierSetWrapperMain ' + objTierSetWrapperMain);
                TierSetWrapper objTierSetWrapper = new TierSetWrapper();
                objTierSetWrapper.objContractTierSet = objTierSetWrapperMain.objContractTierSet;
                if (setTierSetsAssigned.contains(objTierSetWrapper.objContractTierSet.Id)) {
                    objTierSetWrapper.blnAssigned = true;
                } else {
                    objTierSetWrapper.blnAssigned = false;
                }
                System.Debug('  Yeilded objTierSetWrapper ' + objTierSetWrapper);
                listCommitmentTierSetWrapper.add(objTierSetWrapper);
            }
        }
        
        public void debug() {
            System.debug('objBillingCommitment ' + objBillingCommitment);
            for (Billing_Setup_Commitment_Tier_Set__c objCTSA : listCommitmentTierSetAssignment) {
                System.debug(' objCTSA ' + objCTSA);
            }
            for (TierSetWrapper objCTSW : listCommitmentTierSetWrapper) {
                System.debug('  objCTSW ' + objCTSW);
            }
        }
        
        public void clear() {
            listCommitmentTierSetAssignment.clear();
        	listCommitmentTierSetWrapper.clear();
        }
    }
    public class TierSetWrapper
    {
        public Contract_Tier_Set__c objContractTierSet {get; set;}
        public List<Contract_Tier_Range__c> list_ContractTierRanges {get; set;}
        public List<Contract_Service__c> list_ContractServices {get; set;}
        public List<Contract_Recurring_Charge__c> list_ContractRecurringCharges {get; set;}
        public List<BOGO_Detail__c> list_BOGODetails {get; set;}
        
        //Nitin 5
        public Decimal decZuQuantity {get; set;}
        public Decimal decZuNetPrice {get; set;}

        public Boolean blnAssigned { get; set; }

        // *** Constructor ***
        public TierSetWrapper()
        {
            objContractTierSet = new Contract_Tier_Set__c();
            list_ContractTierRanges = new List<Contract_Tier_Range__c>{new Contract_Tier_Range__c()};
                list_ContractServices = new List<Contract_Service__c>{new Contract_Service__c()};
                    list_ContractRecurringCharges = new List<Contract_Recurring_Charge__c>();
            list_BOGODetails = new List<BOGO_Detail__c>();
        }
        
        // *** Constructor ***
        public TierSetWrapper(Contract_Tier_Set__c objContractTierSet,List<Contract_Tier_Range__c> list_ContractTierRanges,
                              List<Contract_Service__c> list_ContractServices,List<Contract_Recurring_Charge__c> list_ContractRecurringCharges,
                              List<BOGO_Detail__c> list_BOGODetails)
        {
            this.objContractTierSet = objContractTierSet;
            this.list_ContractTierRanges = list_ContractTierRanges;
            this.list_ContractServices = list_ContractServices;
            this.list_ContractRecurringCharges = list_ContractRecurringCharges;
            this.list_BOGODetails = list_BOGODetails;
            
            this.decZuQuantity = 0;
            this.decZuNetPrice = 0;
        }
    }
    
    // *** Constructor ***
    public QuoteServiceBillingController(ApexPages.StandardController controller)
    {
        blnIsEdit = blnIsBOGOEdit = blnHasRatingExceptions = blnDispZuNetprQuantitiy = false;       
        
        objRerateLog = new Cloud_Billing_Log__c();
        objRateLog = new Cloud_Billing_Log__c();
        objLog = new Cloud_Billing_Log__c(Month__c = String.valueOf(Date.today().month()),Year__c = String.valueOf(Date.today().year()));
        map_QtChrgeDtlToPrdRtPlChrge = new Map<Id, Id>();
        map_PrdRtPlChrgeToQtRtPlChrge = new Map<Id, zqu__QuoteRatePlanCharge__c>();
        map_QPIdToQPRecord = new Map<Id, zqu__QuoteChargeDetail__c>();
        map_QuoteRatePlan = new Map<Id,zqu__QuoteRatePlan__c>();
        map_ProdIdToQPId = new Map<Id,Id>();
        // Default Report Dates to last month
        Date dtTemp = Date.today().addMonths(-1);
        objReportJobLog = new Cloud_Billing_Log__c();
        objReportJobLog.Month__c = String.valueOf(dtTemp.month());
        objReportJobLog.Year__c = String.valueOf(dtTemp.year());
        
        cid = ApexPages.currentPage().getParameters().get('id');
        if(cid == null)
            return;
        
        // fetch Contract details       
        populateContract(cid);
        // fetch Billing Address for Contract
        populateBillingAddress();
        // fetch associated legal documents
        populateDocuments();
        // fetch/initialize tier set configuration
        populateTierSetsAndServices();
        // fetch/initialize billing Commitments
        populateBillingCommitments();
        // fetch client product mapping configs for this contract
        populateProductMappings();
        // check for permission sets
        checkPermissions();
        if(objContract.Status__c == null)
            objContract.Status__c = 'New';
        populateReportRequests();
        //list_ratingJobs = populateRatingStatus();
        populateCarrierDropdown();
        if(objContract.Zuora_Quote__c != null) {
            buildZuoraQuoteInfo();            
            
            blnDispZuNetprQuantitiy = true;
        }
        //Nitin - populate Year month dropdown
        populateYearMonthDropdown();
    }
    
    public void populateYearMonthDropdown(){
        
        RerateTimeperiodoptions = new List<SelectOption>();
        
        Datetime CurrentDate = datetime.now();
        //Datetime CurrentDate = System.Datetime.newInstance(2018, 01, 10);             
        Datetime PreviousMonthDate = CurrentDate.addMonths(-1);
        
        String currentMonthDisp =  CurrentDate.format('MMMMM');
        String currentMonthval =  String.valueOf(CurrentDate.month());
        String currentYear='-'+String.valueOf(CurrentDate.Year());
        
        String previousMonthDisp =  PreviousMonthDate.format('MMMMM');
        String previousMonthVal =  String.valueOf(PreviousMonthDate.month());
        String previousYear='-'+String.valueOf(PreviousMonthDate.Year());        
        
        RerateTimeperiodoptions.add(new SelectOption(currentMonthval+currentYear, currentMonthDisp+currentYear));
        RerateTimeperiodoptions.add(new SelectOption(previousMonthVal+previousYear, previousMonthDisp+previousYear));
        
    }
    
    public void populateCarrierDropdown() {
        List<Calling_Rate__c> list_ShortCodeCarrier = [select Carrier_Name__c
                                                       from Calling_Rate__c
                                                       where RecordTypeId = :Label.Cloud_Billing_Calling_Rate_Carrier_Map_RecordTypeId];
        Set<String> set_UniqueShortCodeCarrier = new Set<String>();
        for (Calling_Rate__c cr : list_ShortCodeCarrier) {
            if (!set_UniqueShortCodeCarrier.contains(cr.Carrier_Name__c)) {
                System.debug('populateCarrierDropdown adding ' + cr.Carrier_Name__c);
                set_UniqueShortCodeCarrier.add(cr.Carrier_Name__c);
            }
        }
        list_TierSetCarriersToSelect = new List<SelectOption>();
        list_TierSetCarriersToSelect.add(new SelectOption('None', '--None--', false));
        for (String strCarrier : new List<String>(set_UniqueShortCodeCarrier)) {
            list_TierSetCarriersToSelect.add(new SelectOption(strCarrier, strCarrier, false));
        }
    }
    /*
public List<AsyncApexJob> populateRatingStatus() {
List<AsyncApexJob> listJobs =
[select ApexClass.Name, TotalJobItems, JobItemsProcessed, Status, CreatedDate
from AsyncApexJob
where Status != 'Completed'
and ApexClass.Name in ('BatchReconcileServiceUsageData',
'BatchReconcileRollupData',
'BatchRateCloudUsageData',
'BatchReRateUsageData')];
System.debug('listJobs size: ' + listJobs.size());
for (AsyncApexJob j : listJobs) {
System.debug('Name ' + j.ApexClass.Name);
}
return listJobs;
}
*/
    
        public void populateCloudDeployments() {
        // Contract Cloud Deployments
        // Order with unassigned deployments first. Display up to 1000
        List<Cloud_Deployment__c> listContractCloudDeployment = [SELECT Id, Name, Tenant_ID__c, PE_Subscription_ID__c, Portico_Platform_Id__c,
                                                                 PureConnect_ID__c, PureCloud_OrgID__c,Billing_Platform_Id__c,
                                                                 Cloud_Billing_Contract__c, Cloud_Billing_Contract_Add__c,
                                                                 Cloud_Billing_Contract__r.Name,
                                                                 (SELECT Id, Contract__c, Cloud_Deployment__c, Contract__r.Name 
                                                                  FROM Cloud_Deployment_To_Contract_Junctions__r)
                                                                 FROM Cloud_Deployment__c where Account__c = :objContract.Account_Name__c
                                                                 OR Sold_To_Account__c = :objContract.Account_Name__c
                                                                 order by Cloud_Billing_Contract_Add__c];
        System.debug('Got Cloud Deployment List Size ' + listContractCloudDeployment.size());
        
        list_SelectPlatformIds = new List<SelectOption>();
        Boolean blnTenantIdExceedsMsg = false;
        list_TenantId = new List<Cloud_Deployment__c>();
        Boolean blnSubscriberIdExceedsMsg = false;
        list_SubscriberId = new List<Cloud_Deployment__c>();
        Boolean blnPorticoIdExceedsMsg = false;
        list_PorticoId = new List<Cloud_Deployment__c>();
        Boolean blnPureConnectIsExceedsMsg = false;
        list_PureConnectId = new List<Cloud_Deployment__c>();
        Boolean blnPureCloudIdExceedsMsg = false;
        list_PureCloudId = new List<Cloud_Deployment__c>();
        Boolean blnBillingPlatformIdExceedsMsg = false;    
        list_BillingPlatformId = new List<Cloud_Deployment__c>();

        Set<String> setPlatformIdsAssignedThisContract = new Set<String>();
        setContractsWithSamePlatformIds = new Set<Id>();
            
        for (Cloud_Deployment__c cd : listContractCloudDeployment) {
            cd.Cloud_Billing_Contract_Add__c = false;
            Set<Id> setContractSameAssignment = new Set<Id>();
            Boolean blnAssignedThisContract = false;
            for (Cloud_Deployment_To_Contract_Junction__c objCDCJ : cd.Cloud_Deployment_To_Contract_Junctions__r) {
                System.debug('cd: Junction :'+objCDCJ);
                if (objCDCJ.Contract__c == objContract.Id) {
                    cd.Cloud_Billing_Contract_Add__c = true;
                    blnAssignedThisContract = true;
                // Assume we may see this Cloud Deployment assigned to this contract.
                // Store assigned contract ids not this contract in case also assigned to the other.
                } else if (objCDCJ.Contract__c != null) {
                    setContractSameAssignment.add(objCDCJ.Contract__c);
                }
                // If not assigned, not contract to store
            }
            // If it turns out this Cloud Deployment is assigned to this contract add all other contract to which is it also assigned.
            if (blnAssignedThisContract) {
                setContractsWithSamePlatformIds.addAll(setContractSameAssignment);
            }

            System.debug('CD: got ' + cd);
            if (String.isNotBlank(cd.Tenant_ID__c)) {
                if (list_TenantId.size() < MAX_CLOUD_DEPLOYMENT_LIST_SIZE) {
                    list_TenantId.add(cd);
                    list_SelectPlatformIds.add(new SelectOption(cd.Tenant_ID__c, cd.Tenant_ID__c, false));
                } else {
                    if (blnTenantIdExceedsMsg == false) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Tenant Id List Size Greater than ' + MAX_CLOUD_DEPLOYMENT_LIST_SIZE +
                                                                   '. Please Manage Cloud Deployments through Account page'));
                        blnTenantIdExceedsMsg = true;
                    }
                }
            }
            if (String.isNotBlank(cd.PE_Subscription_ID__c)) {
                if (list_SubscriberId.size() < MAX_CLOUD_DEPLOYMENT_LIST_SIZE) {
                    list_SubscriberId.add(cd);
                    list_SelectPlatformIds.add(new SelectOption(cd.PE_Subscription_ID__c, cd.PE_Subscription_ID__c, false));
                } else {
                    if (blnSubscriberIdExceedsMsg == false) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Subscriber List Size Greater than ' + MAX_CLOUD_DEPLOYMENT_LIST_SIZE +
                                                                   '. Please Manage Cloud Deployments through Account page'));
                        blnSubscriberIdExceedsMsg = true;
                    }
                }
            }
            if (String.isNotBlank(cd.Portico_Platform_Id__c)) {
                System.debug('list_PorticoId: Seeing Portico CD ' + cd.Portico_Platform_Id__c + ' list size is ' + list_PorticoId.size());
                if (list_PorticoId.size() < MAX_CLOUD_DEPLOYMENT_LIST_SIZE) {
                    list_PorticoId.add(cd);
                    list_SelectPlatformIds.add(new SelectOption(cd.Portico_Platform_Id__c, cd.Portico_Platform_Id__c, false));
                } else {
                    if (blnPorticoIdExceedsMsg == false) {
                        System.debug('list_PorticoId: Adding msg for Portico');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Portico Id List Size Greater than ' + MAX_CLOUD_DEPLOYMENT_LIST_SIZE +
                                                                   '. Please Manage Cloud Deployments through Account page'));
                        blnPorticoIdExceedsMsg = true;
                    }
                }
            }
            
            if (String.isNotBlank(cd.PureConnect_ID__c)) {
                System.debug('list_PureConnectId: Seeing PureConnect CD ' + cd.PureConnect_ID__c + ' list size is ' + list_PureConnectId.size());
                if (list_PureConnectId.size() < MAX_CLOUD_DEPLOYMENT_LIST_SIZE) {
                    list_PureConnectId.add(cd);
                    list_SelectPlatformIds.add(new SelectOption(cd.PureConnect_ID__c, cd.PureConnect_ID__c, false));
                } else {
                    if (blnPureConnectIsExceedsMsg == false) {
                        System.debug('list_PureConnectId: Adding msg for PureConnect');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PureConnect Id List Size Greater than ' + MAX_CLOUD_DEPLOYMENT_LIST_SIZE +
                                                                   '. Please Manage Cloud Deployments through Account page'));
                        blnPureConnectIsExceedsMsg = true;
                    }
                }
            }
            
            if (String.isNotBlank(cd.PureCloud_OrgID__c)) {
                System.debug('list_PureCloudId: Seeing PureCloud CD ' + cd.PureCloud_OrgID__c + ' list size is ' + list_PureCloudId.size());
                if (list_PureCloudId.size() < MAX_CLOUD_DEPLOYMENT_LIST_SIZE) {
                    list_PureCloudId.add(cd);
                    list_SelectPlatformIds.add(new SelectOption(cd.PureCloud_OrgID__c, cd.PureCloud_OrgID__c, false));
                } else {
                    if (blnPureCloudIdExceedsMsg == false) {
                        System.debug('list_PureCloudId: Adding msg for PureCloud');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PureCloud Id List Size Greater than ' + MAX_CLOUD_DEPLOYMENT_LIST_SIZE +
                                                                   '. Please Manage Cloud Deployments through Account page'));
                        blnPureCloudIdExceedsMsg = true;
                    }
                }
            }
            
            //Added by Rony Joseph - April 04 2018 -Start    
            if (String.isNotBlank(cd.Billing_Platform_Id__c)) {
                System.debug('list_BillingPlatformId: Seeing BillingPlatform CD ' + cd.Billing_Platform_Id__c + ' list size is ' + list_BillingPlatformId.size());
                if (list_BillingPlatformId.size() < MAX_CLOUD_DEPLOYMENT_LIST_SIZE) {
                    list_BillingPlatformId.add(cd);
                    list_SelectPlatformIds.add(new SelectOption(cd.Billing_Platform_Id__c, cd.Billing_Platform_Id__c, false));
                } else {
                    if (blnBillingPlatformIdExceedsMsg == false) {
                        System.debug('list_BillingPlatformId: Adding msg for BillingPlatform');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'BillingPlatform Id List Size Greater than ' + MAX_CLOUD_DEPLOYMENT_LIST_SIZE +
                                                                   '. Please Manage Cloud Deployments through Account page'));
                        blnBillingPlatformIdExceedsMsg = true;
                    }
                }
            }
            //Added by Rony Joseph - April 04 2018 -End    
            
        }
        
    }
    
    // *** Method to populate Contract details ***
    void populateContract(String strContractId)
    {
        objContract = fetchContract(strContractId);
        populateCloudDeployments();
        // iTrack 24901
        objNewReportRequest = new Cloud_Billing_Report_Request__c();
        
        // END NEW        
        if(!objContract.Cloud_Billing_Exceptions__r.isEmpty()) blnHasRatingExceptions = true;
    }
    
    // iTrack 24901
    public void populateReportRequests() {
        list_CloudBillingReportRequest = [select Id, Name, Report_Type__c, Platform_Id_List__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c
                                          from Cloud_Billing_Report_Request__c
                                          where Contract__c = :cid
                                          order by End_Year__c desc, End_Month__c desc];
    }
    
    // iTrack 24901
    public void createNewReportRequest() {
        System.Debug('list_SelectedPlatformIds ' + list_SelectedPlatformIds);
        
        // Error Check Dates
        if (objNewReportRequest.End_Year__c < objNewReportRequest.Start_Year__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'End Year cannot be before Start Year.'));
            return;
        } else if ((objNewReportRequest.End_Year__c == objNewReportRequest.Start_Year__c) && (objNewReportRequest.End_Month__c < objNewReportRequest.Start_Month__c) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'End Month cannot be before Start Month the the same year.'));
            return;
        }
        
        // Ensure proper data supplied
        if (list_SelectedPlatformIds.size() <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose at least one Platform Id.'));
            return;
        }
        if (String.isBlank(objNewReportRequest.Report_Type__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please choose at least one Report Type.'));
            return;
        }
        
        String strPlatformIdList = String.join(list_SelectedPlatformIds, ';');
        System.Debug('strPlatformIdList ' + strPlatformIdList);
        objNewReportRequest.Platform_Id_List__c = strPlatformIdList;
        objNewReportRequest.Contract__c = objContract.Id;
        insert objNewReportRequest;
        // Call to repopulate list according to sort order
        populateReportRequests();
        objNewReportRequest = new Cloud_Billing_Report_Request__c();
    }
    
    // iTrack 24901
    public void runReportRequests() {
        System.Debug('runReportRequests');
        Date dtReportDate = Date.newInstance(Integer.valueOf(objReportJobLog.Year__c), Integer.valueOf(objReportJobLog.Month__c), 1);
        
        CloudBillingData info =
            new CloudBillingData(false, objReportJobLog.Month__c, objReportJobLog.Year__c, null);
        info.contractId = objContract.Id;
        
        List<Cloud_Billing_Report_Instance__c> listInstances = CloudBillingUtil.runCloudBillingReportRequests(info);
    }
    
    // *** Method to query Contract details ***
    private GCR_Content_Document_Detail__c fetchContract(String strContractId)
    {
        // iTrack 22158 Sold_To_Name_Formula__c, Quote__r.Sold_To_Name__c, Quote__r.Sold_To_Name__r.SAP_Account_Code__c added to query
        // iTrack 21261 Added PO__c,PO_Start_Date__c,PO_End_Date__c,PO_Adjustment_Description__c,PO_Starting_Balance__c,PO_Remaining_Balance__c to query
        // iTrack 24752 added Inbound_Billing_Type__c to query
        // iTrack 23650 added Outbound_Rate_Table_Discount__c to query
        GCR_Content_Document_Detail__c objContract  = 
            [SELECT Id, Name, GCR__r.Opportunity__c, Status__c,Outbound_Billing_Type__c, Outbound_Rate_Table_Discount__c, Inbound_Billing_Type__c,Quote__r.Contracts__c,Quote__r.Contracts__r.createddate,
             Expiration_Renewal_Date__c,Genesys_Entity__c,Invoice_Type__c,Invoice_Delivery_Type__c,
             Manual_Review_Required__c,Manual_Review_Reason__c,Approved__c,Sold_To_Name_Formula__c, 
             Product_Group__c,Service_Level_Agreement__c,Pricing_Start_Date__c,Pricing_End_Date__c,Reviewed__c,Status_Notes__c,Usage_Data_Submission_Method__c,
             CurrencyISOCode, Ramp_Start_Date__c, Ramp_End_Date__c,
             
             Quote__r.Sold_To_Name__c, Quote__r.Sold_To_Name__r.SAP_Account_Code__c,Quote__r.Overage_Allowance__c,
             Quote__c,Quote__r.BigMachines__Description__c,Quote__r.Special_Offer_Terms__c,Quote__r.Legal_Terms__c,Quote__r.Overage_Allowance_Other__c,
             Quote__r.Billing_Period__c,Quote__r.CurrencyISOCode,Quote__r.Overage_Price_Premium__c,
             Quote__r.Offering_Type__c,
             Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c,
             Quote__r.Order__r.Name,

             // CRMBILL-274
			 Quote__r.Order__c, Quote__r.Order__r.TotalOrder__c, Quote__r.Order__r.CreatedDate, Quote__r.Order__r.Pricing_Model__c, Quote__r.Order__r.Payment_Terms__c,
             Quote__r.Order__r.Direct_Sales__c,Quote__r.Order__r.Maintenance_Start__c, Quote__r.Order__r.Maintenance_End__c, Quote__r.Order__r.License_FYM_detail__c,
             
             Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c, 
             Zuora_Quote__r.zqu__Opportunity__r.Direct_Sales__c, Zuora_Quote__r.CurrencyISOCode, Zuora_Quote__r.Order_Payment_Terms__c,
             Zuora_Quote__r.zqu__PaymentTerm__c,Zuora_Quote__r.zqu__Terms__c,Zuora_Quote__r.zqu__Currency__c,
             Zuora_Quote__r.zqu__Opportunity__r.Lines_of_Businesses__c, Zuora_Quote__r.zqu__Account__c, 
             
             Account_Name__c,Account_Name__r.Name,Account_Name__r.OwnerId,Account_Name__r.Country__r.Region__c, Contract_Type__c,
             Account_Name__r.SAP_Account_Code__c,Account_Name__r.Subsidary__c,Direct_Sales_Rep_Override__c, 
             Override_Invoice_Footer__c,Invoice_Footer_Text__c,Order_Date_Option__c, Net_Days_Override__c,Account_Name_Override__c,
             PO__c,PO_Start_Date__c,PO_End_Date__c,PO_Adjustment_Description__c,PO_Starting_Balance__c,PO_Remaining_Balance__c,   
             // Added by Vijay - 31st Jul 2017 - Start
             Name__c,
             // Added by Vijay - 31st Jul 2017 - End             
             Country_Override__c,Postal_Code_Override__c,
             (SELECT Id FROM Cloud_Billing_Exceptions__r WHERE Resolved__c = false LIMIT 1)
             FROM GCR_Content_Document_Detail__c WHERE Id = :strContractId];
        
        // We display the end date as the last day of the month, but store the first of next month
        if (objContract.Pricing_Start_Date__c != null) {
            intContractStartDay = objContract.Pricing_Start_Date__c.day();
        }
        
        //list of Quotes associated with Contract 
        list_RelatedQuotes = [select id,Quote_Number__c,createddate from BigMachines__Quote__c where contracts__C = :strContractId];
/*
        else{
            if(objContract.Product_Group__c == 'PureCloud'){               
                List<dsfs__DocuSign_Status__c> lst_objContractDocusign = [SELECT ID, GCR_Content_Document__c,dsfs__Completed_Date_Time__c 
                                                                FROM dsfs__DocuSign_Status__c WHERE GCR_Content_Document__c = :strContractId limit 1];
                if(lst_objContractDocusign.size()>0){
                    dsfs__DocuSign_Status__c objContractDocusign = lst_objContractDocusign[0];
                    if(objContractDocusign != null && objContractDocusign.dsfs__Completed_Date_Time__c!=null){
                    objContract.Pricing_Start_Date__c = DATE.newInstance(objContractDocusign.dsfs__Completed_Date_Time__c.year(), 
                                                                         objContractDocusign.dsfs__Completed_Date_Time__c.month(), 
                                                                         objContractDocusign.dsfs__Completed_Date_Time__c.day());
                    }  
                }                              
            }
        }
*/
        Date dtContractPricingEndDate = objContract.Pricing_End_Date__c;
        if (dtContractPricingEndDate != null) {
            System.debug('fetchContract: before dtContractPricingEndDate ' + dtContractPricingEndDate);
            dtContractPricingEndDate = dtContractPricingEndDate.addDays(-1);
            System.debug('fetchContract: after  dtContractPricingEndDate ' + dtContractPricingEndDate);
        }
        objContractPricingEndDate = new GCR_Content_Document_Detail__c(Pricing_End_Date__c = dtContractPricingEndDate);
        
        return objContract;
    }
    
    // *** Method to query Legal documents associated with the Contract ***
    public void populateDocuments()
    {
        list_Documents = [SELECT Folder__c,View_Folder__c,Document_Name__c,Contract_Type__c,Agreement_Type__c
                          FROM GCR_Content_Document_Detail__c 
                          WHERE Account_Name__c = :objContract.Account_Name__c AND Id != :objContract.Id];
    }
    
    // *** Method to query Billing Address selected on related quote ***
    public void populateBillingAddress()
    {
        objBillingAddress = new Account_Order_Address__c();
        //if(objContract.Quote__c != null || objContract.Zuora_Quote__c != null)
        {
            // iTracks 26037
            List<Account_Order_Address__c> list_BillingAddress = [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                                                  Zip_Code__c, Phone__c, Fax__c, Email__c,Additional_Emails__c,Attention_To__c, Order__c, Quote__c, Zuora_Quote__c
                                                                  FROM Account_Order_Address__c WHERE 
                                                                  //(Quote__c = :objContract.Quote__c OR Zuora_Quote__c =: objContract.Zuora_Quote__c) AND 
                                                                  Address_Type__c = 'Bill To' AND
                                                                  GCR_Content_Document_Detail__c = :objContract.ID LIMIT 1];
            if(!list_BillingAddress.isEmpty())
                objBillingAddress = list_BillingAddress[0];
        }
    }
	@TestVisible
    private void populateBillingCommitments() {
        
        if (listBillingCommitments == null) {
            listBillingCommitments = new List<CommitmentWrapper>();
        } else {
            for (CommitmentWrapper objCommitment : listBillingCommitments) {
                objCommitment.clear();
            }
            listBillingCommitments.clear();
        }
        for (Billing_Setup_Commitment__c objBillingCommitment : 
             [select Id, Name, Committed_Amount__c, Description__c, Product__c,
              (select Billing_Setup_Tier_Set__r.Name
               from Billing_Setup_Commitment_Tier_Sets__r)
              from Billing_Setup_Commitment__c
              where Billing_Setup__c = :objContract.Id]) {
                  CommitmentWrapper objCommitmentWrapper = new CommitmentWrapper(objBillingCommitment, list_TierSetWrappers);
                  listBillingCommitments.add(objCommitmentWrapper);
              }
    }

    public void changeCommitmentTierSetAssignments() {
        System.Debug('Got strSelectedTierSets ' + strSelectedTierSets);
    }

    public void addNewCommitment() {
        if (listBillingCommitments == null) {
            listBillingCommitments = new List<CommitmentWrapper>();
        }
        CommitmentWrapper objCommitmentWrapper = new CommitmentWrapper(new Billing_Setup_Commitment__c(Billing_Setup__c = objContract.Id), list_TierSetWrappers);
        listBillingCommitments.add(objCommitmentWrapper);
    }
    
    // *** Method to set-up Tier Set configuration ***
    public void populateTierSetsAndServices()
    {
        list_ContractTierRangesBeingRemoved = new List<Contract_Tier_Range__c>();
        list_ContractServicesBeingRemoved = new List<Contract_Service__c>();
        list_ContractRecChargesBeingRemoved = new List<Contract_Recurring_Charge__c>();
        list_TierSetsBeingRemoved = new List<Contract_Tier_Set__c>();
        list_BOGODetailsBeingRemoved = new List<BOGO_Detail__c>();
        
        list_TierSetWrappers = new List<TierSetWrapper>();
        List<Contract_Tier_Set__c> list_ContractTierSets = fetchTierSetConfiguration();

        for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSets) {
            list_TierSetWrappers.add(new TierSetWrapper(objContractTierSet,objContractTierSet.Contract_Tier_Ranges__r,
                                                        objContractTierSet.Contract_Services__r,objContractTierSet.Contract_Recurring_Charges__r,objContractTierSet.BOGO_Details__r));
        }
        
    }

    // *** Method to query Tier Set configuration ***
    @TestVisible
    private List<Contract_Tier_Set__c> fetchTierSetConfiguration()
    {
        // itracks 25634 Added Business_Care fields to query
        // iTracks
        return([SELECT Id,Name,Aggregation_Model__c,Units_Type__c,Product__c,Period_In_Months__c,RC_Period__c, Carrier__c,
                
                Quote_Product__r.BigMachines__Product__c,Quote_Product__r.BigMachines__Quantity__c,Quote_Product__r.Metric__c,
                Quote_Product__r.Net_Unit_Price_1_Per_Month__c,Quote_Product__r.Net_Unit_Price_1__c,Quote_Product__r.Net_Unit_Price_2__c,Quote_Product__c,Quote_Product__r.Level_Of_Support__c,
                
                Quote_Charge_Detail__r.zqu__ProductRatePlan__r.zqu__Product__c,
                
                (SELECT From__c,To__c,Price__c,Contract_Tier_Set__c FROM Contract_Tier_Ranges__r WHERE Is_Deleted__c = false ORDER BY From__c),
                (SELECT Id,Contract_Tier_Set__c,Service__c,Contract_Id_Service_Identifier__c,Service__r.Channel_Type__c,Service__r.Device_Type__c,
                 Service__r.UID__c,Service__r.Name,Service__r.Service_Type__c,Service__r.Service_Type_Value__c,Service__r.Subcampaign_Type__c,Use_Calling_Rates__c
                 FROM Contract_Services__r WHERE Is_Deleted__c = false ORDER BY Name),
                (SELECT Id,Contract_Tier_Set__c,Units__c,Amount__c,Charge_Description__c,External_Note__c,Type__c,Active__c, Pre_Bill__c,
                 Business_Care_Min_Revenue_Threshold__c, Business_Care_Max_Revenue_Threshold__c, Business_Care_Support_Fee_Percentage__c,
                 Deferred__c, Quantity__c,  Rate__c
                 FROM Contract_Recurring_Charges__r WHERE Is_Deleted__c = false ORDER BY Name),
                (SELECT Parent_Quantity__c,Parent_Tier_Set__c,Related_Quantity__c,Related_Tier_Set__r.Name,Prorate__c 
                 FROM BOGO_Details__r WHERE Is_Deleted__c = false ORDER BY Name)
                FROM Contract_Tier_Set__c WHERE Contract__c = :objContract.Id AND Is_Deleted__c = false ORDER BY Name]);
    }
    // New method to gather product mappings for all Cloud Deployments for the Account
    public void populateProductMappings() {
        list_ClientProductMappings = [select Id, Name, Cloud_Deployment__c, Cloud_Deployment__r.Name,
                                      /*Cloud_Deployment__r.*/Tenant_ID__c, Cloud_Deployment__r.Cloud_Billing_Contract__c,
                                      Cloud_Deployment__r.Cloud_Billing_Contract__r.Name, Cloud_Deployment__r.Cloud_Billing_Contract_Add__c
                                      FROM Client_Product_Mapping__c
                                      WHERE Account__c = :objContract.Account_Name__c];
    }
    
    //*** Handler/Method for Update Billing Address button ***
    public void updateBillingAddressBtnHandler()
    {
        String strEmailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,10}$';
        Pattern objPattern = Pattern.compile(strEmailRegex);
        try
        {
            // Added by Vijay 20th Jul 2017 - Start - Email validation
            if(String.isNotBlank(objBillingAddress.Email__c) ){
                Matcher objMatcher = objPattern.matcher(objBillingAddress.Email__c);
                
                if(!objPattern.matcher(objBillingAddress.Email__c).matches()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Billing Address Email Is Not valid. Please enter valid Email Address'));
                    return ;
                }
            }
            if(String.isNotBlank(objBillingAddress.Additional_Emails__c)){
                boolean bolFlag = false;
                if(objBillingAddress.Additional_Emails__c.contains(';')){
                    List<String> list_Emails = objBillingAddress.Additional_Emails__c.split(';');
                    for(String strEmail : list_Emails){
                        Matcher objMatcher = objPattern.matcher(strEmail);
                        bolFlag = !objPattern.matcher(strEmail).matches();
                        if(bolFlag) break;
                    }
                }else{
                    Matcher objMatcher = objPattern.matcher(objBillingAddress.Additional_Emails__c);
                    bolFlag = !objPattern.matcher(objBillingAddress.Additional_Emails__c).matches();
                }
                
                if(bolFlag){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Billing Address Additional Emails Is Not valid. Please enter valid Email Address and seperated each Email with ";"'));
                    return ;
                }
            }
            // Added by Vijay 20th Jul 2017 - End
            if(objBillingAddress.Id != null)
            {
                update objBillingAddress;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Billing Address Successfully Updated.'));
            }
        }
        catch(Exception ex){}
    }
    
    //*** Handler/Method for Reviewed button ***
    public void reviewedBtnHandler()
    {
        try
        {
            if(objBillingAddress.Id == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Billing Address should be available before a contract can be marked reviewed.'));
                return;
            }
            objContract.Reviewed__c = true;
            update objBillingAddress;
        }
        catch(Exception ex){}
    }
    
    public static Boolean blnIsPricingEndDateCorrect(Integer intStartDay, Date dtPricingEndDate) {
        // If evergreen
        if (dtPricingEndDate == null) {
            System.debug('End Date is Null, Contract is Evergreen. End Date OK.');
            return true;
        }
        // Edge case where start is the first, need to check the last day of the end date month as that must be the end date
        if (intStartDay == 1) {
            Integer intDaysInEndMonth = Date.daysInMonth(dtPricingEndDate.year(), dtPricingEndDate.month());
            System.debug('dtPricingEndDate.day() ' + dtPricingEndDate.day() + ' dtPricingEndDate ' + dtPricingEndDate +
                         ' intDaysInEndMonth ' + intDaysInEndMonth);
            if (dtPricingEndDate.day() != intDaysInEndMonth) {
                System.debug('Start Day is the first. End date is NOT the last day of its month. FAIL');
                return false;
            }
            System.debug('Start Day is the first. End date is the last day of its month. OK');
            return true;
        }
        
        if (dtPricingEndDate.day() != intStartDay-1) {
            System.debug('Start Day is NOT the first. End date is NOT the start day minus 1. FAIL');
            return false;
        }
        System.debug('Start Day is NOT the first. End date is the start day minus 1. OK');
        return true;
    }
    
    //*** Handler/Method for Update Contract button ***
    public void saveContract()
    {
        try
        {
            if(objContract.Manual_Review_Required__c == 'Yes' && String.isBlank(objContract.Manual_Review_Reason__c))
            {
                objContract.Manual_Review_Reason__c.addError('Value Required');
                return;
            }
            if(objContract.Override_Invoice_Footer__c && String.isBlank(objContract.Invoice_Footer_Text__c))
            {
                objContract.Invoice_Footer_Text__c.addError('Value Required');
                return;
            }
            if((objContract.Status__c == 'Rejected' || objContract.Status__c == 'Hold') && String.isBlank(objContract.Status_Notes__c))
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Status Notes required for Rejected or Hold status.'));
                objContract.Status_Notes__c.addError('Required for Rejected or Hold status.');
                return;
            }
            // iTracks 33333 Now need to compare with the UI entry date
            if((objContract.Invoice_Delivery_Type__c == 'Email' || objContract.Invoice_Delivery_Type__c == 'Both Email and Paper') &&
               objBillingAddress.Id != null && String.isBlank(objBillingAddress.Email__c))
            {
                objBillingAddress.Email__c.addError('Value Required');
                return;
            }
            if(objContract.Pricing_Start_Date__c != null && objContractPricingEndDate.Pricing_End_Date__c != null &&
               objContract.Pricing_Start_Date__c >= objContractPricingEndDate.Pricing_End_Date__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Billing Effective Start Date cannot be greater than Billing Effective End Date.'));
                return;
            }
            // Billing effective start date not required when Contract status in "Rejected" - condition added by Vijay - June 28th 2017
            if (objContract.Pricing_Start_Date__c == null && objContract.Status__c != 'Rejected') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract must have a Billing Effective Start Date.'));
                return;
            }
            // Null Check condition added by Vijay - June 29th 2017 - minimize required fields on Rejected Status.
            if(objContract.Pricing_Start_Date__c != NULL){
                Integer intStartDay = objContract.Pricing_Start_Date__c.day();
                // iTracks 33333
                if(objContractPricingEndDate.Pricing_End_Date__c != null) {
                    if (!blnIsPricingEndDateCorrect(intStartDay, objContractPricingEndDate.Pricing_End_Date__c)) {
                        // iTracks 33333
                        objContractPricingEndDate.Pricing_End_Date__c.addError('Billing Effective End Date day has to be the day before the Billing Effective Start Date day.');
                        objContractPricingEndDate.Pricing_End_Date__c.addError('Example ' + objContract.Pricing_Start_Date__c +
                                                                               ' could end on ' + objContract.Pricing_Start_Date__c.addMonths(1).addDays(-1) +
                                                                               ' or ' + objContract.Pricing_Start_Date__c.addMonths(2).addDays(-1));
                        return;
                    }
                }
            }
            // iTracks 33333
            // Actually store the pricing end date + 1 to be able to rate all data for the last day of the month cycle 
            Date dtContractPricingEnd = objContractPricingEndDate.Pricing_End_Date__c;
            if (dtContractPricingEnd != null) {
                dtContractPricingEnd = dtContractPricingEnd.addDays(1);
                objContract.Pricing_End_Date__c = dtContractPricingEnd;
            } else {
                objContract.Pricing_End_Date__c = null;
            }
            
            if( objContract.Status__c != 'Rejected' && (String.isBlank(objContract.Genesys_Entity__c) 
                                                        || objContract.Genesys_Entity__c.split(';').size() > 1))
            {
                objContract.Genesys_Entity__c.addError('Please select a value (only 1).');
                return;
            }
            if(objContract.Status__c == 'Approved')
            {
                if(blnIsContractManager)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract Manager cannot approve Contract.'));
                    return;
                }
                if(!objContract.Reviewed__c)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Contract needs to be reviewed before being approved.'));
                    return;
                }
                if(objContract.Pricing_Start_Date__c == null)
                {
                    objContract.Pricing_Start_Date__c.addError('Value Required');
                    return;
                }
                if(String.isBlank(objContract.Invoice_Delivery_Type__c))
                {
                    objContract.Invoice_Delivery_Type__c.addError('Value Required');
                    return;
                }
                if(String.isBlank(objContract.Order_Date_Option__c))
                {
                    objContract.Order_Date_Option__c.addError('Value Required');
                    return;
                }
                if (String.isBlank(objBillingAddress.Zip_Code__c)) {
                    objBillingAddress.Zip_Code__c.addError('Value Required for Postal Code');
                    return;
                }
                
                // Allow multiple contracts for a customer
                /*if([SELECT COUNT() FROM GCR_Content_Document_Detail__c WHERE Account_Name__c = :objContract.Account_Name__c AND 
Quote__c != null AND Status__c = 'Approved' AND Id != :objContract.Id] > 0)
{
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There cannot be more than 1 Active contract for an account.'));
return;
}
// Source of Platform Ids moved to Cloud Deployment object
if([SELECT COUNT() FROM Account WHERE Id = :objContract.Account_Name__c AND
Subscriber_ID__c = null AND Tenant_ID__c = null AND RMS_Enterprise_ID__c = null AND RMS_Super_Enterprise_ID__c = null] > 0)
{
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'At least one platform identifier needs to be specified for the account.'));
return;
}*/
                
                // Flag is set when contract is approved. It is not unchecked when status is reverted. Used to indicate if it was ever approved.
                objContract.Approved__c = true;
            }
            
            populateCloudDeploymentContractId(list_TenantId);
            populateCloudDeploymentContractId(list_SubscriberId);
            populateCloudDeploymentContractId(list_PorticoId);
            populateCloudDeploymentContractId(list_PureConnectId);
            populateCloudDeploymentContractId(list_PureCloudId);
            //ECD 2018-04-10 
            populateCloudDeploymentContractId(list_BillingPlatformId);
            /*
System.debug('Attempt saving platform Ids');
update list_TenantId;
update list_SubscriberId;
update list_PorticoId;
update list_PureConnectId;
update list_PureCloudId;
*/
            System.debug('Attempt saving Contract');
			upsertBillingCommitments();
            update objContract;
            
            System.debug('addClientProductMappings');
            addClientProductMappings();
            System.debug('populateProductMappings');
            populateProductMappings();
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Contract Successfully Updated.'));
        }
        catch(Exception ex){
            // Added by Vijay - June 29th
            System.debug('Error :'+ex.getLineNumber()+':'+ex.getStackTraceString());
        }
    }

    public void upsertBillingCommitments() {

        // First upsert remaining Commitments so we know we have Id references for them
        List<Billing_Setup_Commitment__c> listlistBillingCommitmentsToSave = new List<Billing_Setup_Commitment__c>();
        for (CommitmentWrapper objCommitmentWrapper : listBillingCommitments) {
            listlistBillingCommitmentsToSave.add(objCommitmentWrapper.objBillingCommitment);
        }
        upsert listlistBillingCommitmentsToSave;

        List<Billing_Setup_Commitment_Tier_Set__c> listBillingCommitmentTierSetsToInsert = new List<Billing_Setup_Commitment_Tier_Set__c>();
        List<Billing_Setup_Commitment_Tier_Set__c> listBillingCommitmentTierSetsToDelete = new List<Billing_Setup_Commitment_Tier_Set__c>();
        for (CommitmentWrapper objCommitmentWrapper : listBillingCommitments) {
            objCommitmentWrapper.debug();
            for (TierSetWrapper objTierSetWrapper : objCommitmentWrapper.listCommitmentTierSetWrapper) {
                if (objTierSetWrapper.blnAssigned == true) {
                    System.Debug('ASSIGNED');
                    Boolean blnExists = false;
                    // Search for an existing assignment for this tier set. If one exists, keep it. If one does not exist, insert one.
                    for (Billing_Setup_Commitment_Tier_Set__c objCommitmentTierSetAssignment :  objCommitmentWrapper.listCommitmentTierSetAssignment) {
                        if (objTierSetWrapper.objContractTierSet.Id == objCommitmentTierSetAssignment.Billing_Setup_Tier_Set__c) {
                            blnExists = true;
                            break;
                        }
                    }
                    System.Debug('blnExists ' + blnExists);
                    // Create new assignment
                    if (!blnExists) {
                        Billing_Setup_Commitment_Tier_Set__c objBillingSetupCommitmentTierSet = new Billing_Setup_Commitment_Tier_Set__c(
                            Billing_Setup_Commitment__c = objCommitmentWrapper.objBillingCommitment.Id,
                            Billing_Setup_Tier_Set__c = objTierSetWrapper.objContractTierSet.Id
                        );
                        System.Debug('objBillingSetupCommitmentTierSet created ' + objBillingSetupCommitmentTierSet);
                        listBillingCommitmentTierSetsToInsert.add(objBillingSetupCommitmentTierSet);
                    }
                    // Tier Set marked as not assigned. Delete assignment if still present
                } else {
                    // Search for an existing assignment for this tier set. If one exists, keep it. If one does not exist, insert one.
                    for (Billing_Setup_Commitment_Tier_Set__c objCommitmentTierSetAssignment :  objCommitmentWrapper.listCommitmentTierSetAssignment) {
                        if (objTierSetWrapper.objContractTierSet.Id == objCommitmentTierSetAssignment.Billing_Setup_Tier_Set__c) {
                            System.Debug('objTierSetWrapper.objContractTierSet.Id == objCommitmentTierSetAssignment.Billing_Setup_Tier_Set__c delete ' + objTierSetWrapper.objContractTierSet.Id);
							listBillingCommitmentTierSetsToDelete.add(objCommitmentTierSetAssignment);
                            break;
                        }
                    }
                }
            }
        }
        upsert listBillingCommitmentTierSetsToInsert;
        delete listBillingCommitmentTierSetsToDelete;
        
        populateBillingCommitments();
    }

    private Boolean blnCloudDeploymentBelongsToThisContract(Cloud_Deployment__c objCloudDeployment) {
        if (objCloudDeployment.Cloud_Deployment_To_Contract_Junctions__r != null &&
            objCloudDeployment.Cloud_Deployment_To_Contract_Junctions__r.size() > 0) {
                for (Cloud_Deployment_To_Contract_Junction__c objCDCJ : objCloudDeployment.Cloud_Deployment_To_Contract_Junctions__r) {
                    if (objCDCJ.Contract__c == objContract.Id) {
                        return true;
                    }
                }
            }
        return false;
    }
    
    public void addClientProductMappings() {
        List<Client_Product_Mapping__c> list_ClientProductMappingsToAdd = new List<Client_Product_Mapping__c>();
        List<Cloud_Deployment__c> listCloudDeploymentsNeedingClientProductMapping = new List<Cloud_Deployment__c>();
        listCloudDeploymentsNeedingClientProductMapping.addAll(list_TenantId);
        for (Cloud_Deployment__c objCloudDeployment : listCloudDeploymentsNeedingClientProductMapping) {
            if (blnCloudDeploymentBelongsToThisContract(objCloudDeployment)) {
                System.debug('addClientProductMappings: Cloud Deployment belongs to this contract, create a Client Product Mapping if needed ' + objCloudDeployment.Name);
                // Assume we have to create one unless we can find one
                Boolean blnSaveNewClientProductMapping = true;
                for (Client_Product_Mapping__c objClientProductMapping : list_ClientProductMappings) {
                    if (objClientProductMapping.Cloud_Deployment__c == objCloudDeployment.Id) {
                        // We have saved a Client Product Mapping for this Cloud Deployment before
                        System.debug('addClientProductMappings: Client Product Mapping Already Exists for ' + objCloudDeployment.Name);
                        blnSaveNewClientProductMapping = false;
                    }
                }
                if (blnSaveNewClientProductMapping) {
                    // We have not saved a Client Product Mapping for this Cloud Deployment before. Add one.
                    System.debug('addClientProductMappings: Creating Product Mapping for ' + objCloudDeployment.Name);
                    Client_Product_Mapping__c objNewClientProductMapping = new Client_Product_Mapping__c(Name = objCloudDeployment.Name,
                                                                                                         Account__c = objContract.Account_Name__c,
                                                                                                         Cloud_Deployment__c = objCloudDeployment.Id);
                    list_ClientProductMappingsToAdd.add(objNewClientProductMapping);
                }
            } else {
                System.debug('addClientProductMappings: Cloud Deployment does not belong to this contract. ' + objCloudDeployment.Name + ' no action');
            }
        }
        // Skip ClientProductMappings for Subscriber Ids
        
        // Save first to populate Id's to prevent double creation
        insert list_ClientProductMappingsToAdd;
        for (Client_Product_Mapping__c objClientProductMapping : list_ClientProductMappingsToAdd) {
            list_ClientProductMappings.add(objClientProductMapping);
        }
    }
    
    // If the Cloud_Billing_Contract_Add__c flag is set on any of the Cloud_Deployment__c objects, set the Contract Lookup to this contract
    private void populateCloudDeploymentContractId(List<Cloud_Deployment__c> listCloudDeploymentContractId) {
        List<Cloud_Deployment_To_Contract_Junction__c> list_NewCloudDeploymentContractJunctions = new List<Cloud_Deployment_To_Contract_Junction__c>();
        List<Cloud_Deployment_To_Contract_Junction__c> list_CloudDeploymentContractJunctionsToDelete = new List<Cloud_Deployment_To_Contract_Junction__c>();
        for (Cloud_Deployment__c objCloudDeployment : listCloudDeploymentContractId) {
            // The check box is checked, make sure assigned to this contract.
            if (objCloudDeployment.Cloud_Billing_Contract_Add__c) {
                Boolean blnCreateNewJunction = true;
                for (Cloud_Deployment_To_Contract_Junction__c objCDCJ : objCloudDeployment.Cloud_Deployment_To_Contract_Junctions__r) {
                    // There is already an assignment, do nothing.
                    if (objCDCJ.Cloud_Deployment__c == objCloudDeployment.Id && objCDCJ.Contract__c == objContract.Id) {
                        System.debug ('populateCloudDeploymentContractId: Junction already exists, no action ' + objCDCJ);
                        blnCreateNewJunction = false;
                        break;
                    }
                }
                if (blnCreateNewJunction) {
                    // Not assigned create new assignment.
                    Cloud_Deployment_To_Contract_Junction__c objNewCDCJ = new Cloud_Deployment_To_Contract_Junction__c(
                        Contract__c = objContract.Id,
                        Cloud_Deployment__c = objCloudDeployment.Id);
                    System.debug ('populateCloudDeploymentContractId: Create new Junction ' + objNewCDCJ);
                    list_NewCloudDeploymentContractJunctions.add(objNewCDCJ);
                }
                // The check box is NOT checked, delete any previous assignment
            } else {
                for (Cloud_Deployment_To_Contract_Junction__c objCDCJ : objCloudDeployment.Cloud_Deployment_To_Contract_Junctions__r) {
                    System.debug ('populateCloudDeploymentContractId: Examine Junction ' + objCDCJ);
                    if (objCDCJ.Cloud_Deployment__c == objCloudDeployment.Id && objCDCJ.Contract__c == objContract.Id) {
                        System.debug ('populateCloudDeploymentContractId: Delete Junction ' + objCDCJ);
                        list_CloudDeploymentContractJunctionsToDelete.add(objCDCJ);
                    }
                }
            }
        }

        Boolean blnNewToRepopulateCloudDeployments = false;
        System.debug('populateCloudDeploymentContractId: list_NewCloudDeploymentContractJunctions ' + list_NewCloudDeploymentContractJunctions);
        if (list_NewCloudDeploymentContractJunctions.size() > 0) {
            insert list_NewCloudDeploymentContractJunctions;
            blnNewToRepopulateCloudDeployments = true;
        }
        System.debug('populateCloudDeploymentContractId: list_CloudDeploymentContractJunctionsToDelete ' + list_CloudDeploymentContractJunctionsToDelete);
        if (list_CloudDeploymentContractJunctionsToDelete.size() > 0) {
            delete list_CloudDeploymentContractJunctionsToDelete;
            blnNewToRepopulateCloudDeployments = true;
        }
        if (blnNewToRepopulateCloudDeployments) {
            System.Debug('populateCloudDeploymentContractId: Repopulating Cloud Deployments');
            populateCloudDeployments();
        }
    }
    
    //*** Handler/Method for Import/Overwrite Info from Quote button ***
    public void resetServiceInfoFromQuote()
    {
        String strOfferingType = objContract.Quote__r.Offering_Type__c;
        if(strOfferingType != null)
            CloudBillingUtil.resetServiceInfoFromQuote(objContract,strOfferingType);
        try
        {       
            if(objContract.Quote__c != null){
                
                Map<Id,Id> map_ProdIdToQPId = new Map<Id,Id>();
                Map<Id,BigMachines__Quote_Product__c> map_QPIdToQPRecord = new Map<Id,BigMachines__Quote_Product__c>([SELECT Id,BigMachines__Product__c,
                                                                                                                      BigMachines__Product__r.Name,
                                                                                                                      BigMachines__Quantity__c,Net_Unit_Price__c FROM BigMachines__Quote_Product__c
                                                                                                                      WHERE BigMachines__Quote__c = :objContract.Quote__c AND BigMachines__Product__r.Type__c != 'Genesys Care'
                                                                                                                     AND BigMachines__Product__r.Product_Category__c != 'Hardware']);
                
                // Fetching Quote Products and creating a map of Product Id to Quote Product Id
                for(BigMachines__Quote_Product__c objQP : map_QPIdToQPRecord.values())
                    map_ProdIdToQPId.put(objQP.BigMachines__Product__c,objQP.Id);
            }
            //Logic to handle Zuora Quotes
            else if(objContract.Zuora_Quote__c != null) {
                buildZuoraQuoteInfo();
            }
             // fetch/initialize tier set configuration
            populateTierSetsAndServices();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    //*** Method to load quantity and price for Zuora Quotes
    private void buildZuoraQuoteInfo() {
        if(objContract.Contract_Type__c != 'Cloud Billing - Telco') {            
            map_QPIdToQPRecord = new Map<Id, zqu__QuoteChargeDetail__c>(
                [SELECT zqu__ProductRatePlanCharge__r.zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                 zqu__ProductRatePlan__r.zqu__Product__r.Type__c, zqu__Quote__c, zqu__BillingTax__c,
                 zqu__ProductRatePlan__r.zqu__Product__c, zqu__ProductRatePlan__r.zqu__Product__r.Name,
                 zqu__BillingSubtotal__c, zqu__BillingTotal__c, zqu__BillingDiscount__c
                 FROM zqu__QuoteChargeDetail__c
                 WHERE zqu__Quote__c = :objContract.Zuora_Quote__c
                 AND zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c != 'Voice Services']);           
        }
        else {
            map_QPIdToQPRecord = new Map<Id, zqu__QuoteChargeDetail__c>(
                [SELECT zqu__ProductRatePlanCharge__r.zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                 zqu__ProductRatePlan__r.zqu__Product__r.Type__c, zqu__Quote__c, zqu__BillingTax__c,
                 zqu__ProductRatePlan__r.zqu__Product__c, zqu__ProductRatePlan__r.zqu__Product__r.Name,
                 zqu__BillingSubtotal__c, zqu__BillingTotal__c, zqu__BillingDiscount__c
                 FROM zqu__QuoteChargeDetail__c
                 WHERE zqu__Quote__c = :objContract.Zuora_Quote__c
                 AND zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c = 'Voice Services']);           
        }
        for(zqu__QuoteChargeDetail__c objQtChrgeDtl : map_QPIdToQPRecord.values()) {
            //Build a map between Quote Charge Detail and Product Rate Plan
            map_QtChrgeDtlToPrdRtPlChrge.put(objQtChrgeDtl.Id, objQtChrgeDtl.zqu__ProductRatePlanCharge__c);
            map_ProdIdToQPId.put(objQtChrgeDtl.zqu__ProductRatePlan__r.zqu__Product__c, objQtChrgeDtl.Id);            
        }
        //Build a map between product rate plan and quote rate plan charge
        for(zqu__QuoteRatePlanCharge__c objQtRtPlChrg : [SELECT Id, zqu__Discount__c, zqu__ListPrice__c, zqu__ProductRatePlanCharge__c,
                                                         zqu__EffectivePrice__c, zqu__Quantity__c, zqu__UOM__c
                                                         FROM zqu__QuoteRatePlanCharge__c 
                                                         WHERE zqu__ProductRatePlanCharge__c IN :map_QtChrgeDtlToPrdRtPlChrge.values()
                                                         AND zqu__QuoteRatePlan__r.zqu__Quote__c =: objContract.Zuora_Quote__c]) {            
                                                             map_PrdRtPlChrgeToQtRtPlChrge.put(objQtRtPlChrg.zqu__ProductRatePlanCharge__c, objQtRtPlChrg);         
                                                         }
        
        System.debug('######'+map_QPIdToQPRecord.size());
        System.debug('######'+map_QtChrgeDtlToPrdRtPlChrge.size());
        System.debug('######'+map_PrdRtPlChrgeToQtRtPlChrge.size());
        System.debug('######'+map_ProdIdToQPId.size());
        
        //Update the wrapper with quantity and net price values
        List<TierSetWrapper> lst_CntrctTierSetPriceQuan = new List<TierSetWrapper>();            
        for(TierSetWrapper objTSW:list_TierSetWrappers){
            zqu__QuoteRatePlanCharge__c objQuRaPlC = map_PrdRtPlChrgeToQtRtPlChrge.get(map_QtChrgeDtlToPrdRtPlChrge.get(objTSW.objContractTierSet.Quote_Charge_Detail__c));
            if(objQuRaPlC!=null){
                objTSW.decZuQuantity = objQuRaPlC.zqu__Quantity__c;
                objTSW.decZuNetPrice = objQuRaPlC.zqu__EffectivePrice__c;        
            }
            lst_CntrctTierSetPriceQuan.add(objTSW);              
        }            
        list_TierSetWrappers.clear();
        list_TierSetWrappers = lst_CntrctTierSetPriceQuan;
        
    }
    
    // *** Handler for Remove Tier Range button ***
    public void removeTierRange()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        Integer intRow = Integer.valueOf(strRowIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            
            if(intRow == 0 && objTSWrapper.list_ContractTierRanges.size() == 1)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There needs to be atleast one range for a Tier Set.'));
            else
            {
                if(objTSWrapper.list_ContractTierRanges[intRow].Id != null)
                {
                    objTSWrapper.list_ContractTierRanges[intRow].Is_Deleted__c = true;
                    list_ContractTierRangesBeingRemoved.add(objTSWrapper.list_ContractTierRanges[intRow]);
                }
                
                objTSWrapper.list_ContractTierRanges.remove(intRow);
            }
        }
    }
    
    // *** Handler for Add Tier Range button ***
    public void addTierRange()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            Contract_Tier_Range__c objContractTR = new Contract_Tier_Range__c(Contract_Tier_Set__c = objTSWrapper.objContractTierSet.Id,
                                                                              CurrencyISOCode = objContract.Quote__c != null ? objContract.Quote__r.CurrencyISOCode : objContract.Zuora_Quote__r.CurrencyISOCode);
            objTSWrapper.list_ContractTierRanges.add(objContractTR);
        }
    }
    
    // *** Handler for Remove Contract Service button ***
    public void removeContractService()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        Integer intRow = Integer.valueOf(strRowIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            
            if(objTSWrapper.list_ContractServices[intRow].Id != null)
            {
                objTSWrapper.list_ContractServices[intRow].Is_Deleted__c = true;
                list_ContractServicesBeingRemoved.add(objTSWrapper.list_ContractServices[intRow]);
            }
            
            objTSWrapper.list_ContractServices.remove(intRow);
        }
    }
    
    // *** Handler for Add Contract Service button ***
    public void addContractService()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objTSWrapper.objContractTierSet.Id,
                                                                         CurrencyISOCode = objContract.Quote__c != null ? objContract.Quote__r.CurrencyISOCode : objContract.Zuora_Quote__r.CurrencyISOCode);
            objTSWrapper.list_ContractServices.add(objContService);
        }
    }
    
    // *** Handler for Remove Recurring Charge button ***
    public void removeRecurringCharge()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        Integer intRow = Integer.valueOf(strRowIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            
            if(objTSWrapper.list_ContractRecurringCharges[intRow].Id != null)
            {
                objTSWrapper.list_ContractRecurringCharges[intRow].Is_Deleted__c = true;
                list_ContractRecChargesBeingRemoved.add(objTSWrapper.list_ContractRecurringCharges[intRow]);
            }
            
            objTSWrapper.list_ContractRecurringCharges.remove(intRow);
        }
    }
    
    // *** Handler for Add Recurring Charge button ***
    public void addRecurringCharge()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            Contract_Recurring_Charge__c objRecCharge = new Contract_Recurring_Charge__c(Contract_Tier_Set__c = objTSWrapper.objContractTierSet.Id,
                                                                                         CurrencyISOCode = objContract.Quote__c != null ? objContract.Quote__r.CurrencyISOCode : objContract.Zuora_Quote__r.CurrencyISOCode);
            objTSWrapper.list_ContractRecurringCharges.add(objRecCharge);
        }
    }
    
    // *** Handler for Remove Tier Set button ***
    public void removeTierSet()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            
            if(objTSWrapper.objContractTierSet.Id != null)
            {
                objTSWrapper.objContractTierSet.Is_Deleted__c = true;
                list_TierSetsBeingRemoved.add(objTSWrapper.objContractTierSet);
            }
            
            list_TierSetWrappers.remove(intTierRow);
        }
    }
    
    //Added By Vijay - 31st Jul 2017 - start
    
    private TierSetWrapper getNewTierSet(){
        TierSetWrapper objTSWrapper = new TierSetWrapper();
        objTSWrapper.objContractTierSet.Contract__c = objContract.Id;
        objTSWrapper.objContractTierSet.CurrencyISOCode = objContract.Quote__c != null ? objContract.Quote__r.CurrencyISOCode : objContract.Zuora_Quote__r.CurrencyISOCode;
        return objTSWrapper;
    }
    
    public void addTierSetAtBottom()
    {
        TierSetWrapper objTSWrapper = getNewTierSet();
        list_TierSetWrappers.add(objTSWrapper);
    }
    public void refreshProductTierSet()
    {
        //IF objTSWrapper.objContractTierSet.Product__c is blank - error message to select a product
        //ELSE - refresh from conrtact tier set
        Integer intTierRow = Integer.valueOf(strTierIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size()){
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
             Product_Tier_Set__c objProdTierSet;
            
            try{              
            
            objProdTierSet = [SELECT Id, Name,Product__c,Aggregation_Model__c,Units_Type__c,
                                                                      (SELECT From__c,To__c,Price__c FROM Product_Tier_Ranges__r),
                                                                      (SELECT Service__c,Service__r.Use_Calling_Rates__c FROM Product_Tier_Set_Services__r),
                                                                      (SELECT Amount__c,Charge_Description__c,External_Note__c,Type__c FROM Product_Recurring_Charges__r)
                                                                      FROM Product_Tier_Set__c WHERE Product__c = :objTSWrapper.objContractTierSet.Product__c limit 1];
            }catch(Exception ex){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No  Product Tier Set found for the selected product - '+objTSWrapper.objContractTierSet.Product__c)); 
            }
            
            if(objProdTierSet==NULL){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No  Product Tier Set found for the selected product - '+objTSWrapper.objContractTierSet.Product__c));                
            }else{
                //Contract_Tier_Set__c objContractTierSet = new Contract_Tier_Set__c(Contract__c = objContract.Id);
                objTSWrapper.objContractTierSet.Name = objProdTierSet.Name;
                objTSWrapper.objContractTierSet.Aggregation_Model__c = objProdTierSet.Aggregation_Model__c;
                objTSWrapper.objContractTierSet.Units_Type__c = objProdTierSet.Units_Type__c;
                objTSWrapper.objContractTierSet.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                // Associating corresponding Quote Product to the Tier Set
                objTSWrapper.objContractTierSet.Quote_Product__c = map_ProdIdToQPId.get(objProdTierSet.Product__c);
                
                //Refresh the current tier ranges
                objTSWrapper.list_ContractTierRanges.clear();
                //Create new tier ranges based on the product tier set
                for(Product_Tier_Range__c  objProdTR : objProdTierSet.Product_Tier_Ranges__r){
                    //Contract_Tier_Range__c objContractTR = new Contract_Tier_Range__c(Contract_Tier_Set__c = objContractTierSet.Id);
                    Contract_Tier_Range__c objContractTR = new Contract_Tier_Range__c();
                    //list_ContractTierRanges
                    objContractTR.From__c = objProdTR.From__c;
                    objContractTR.To__c = objProdTR.To__c;
                    objContractTR.Price__c = objProdTR.Price__c;
                    objContractTR.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                    objTSWrapper.list_ContractTierRanges.add(objContractTR);                
                }
                
                //Refresh Services 
                objTSWrapper.list_ContractServices.clear();
                for(Product_Tier_Set_Service__c  objProdTSS : objProdTierSet.Product_Tier_Set_Services__r){
                    //Contract_Service__c objContService = new Contract_Service__c(Contract_Tier_Set__c = objContractTierSet.Id);
                    Contract_Service__c objContService = new Contract_Service__c();
                    objContService.Service__c = objProdTSS.Service__c;
                    objContService.Use_Calling_Rates__c = objProdTSS.Service__r.Use_Calling_Rates__c;
                    objContService.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                    objTSWrapper.list_ContractServices.add(objContService);
                }
                
                //Refresh Reccuring charges             
                objTSWrapper.list_ContractRecurringCharges.clear();
                for(Product_Recurring_Charge__c  objProdRC : objProdTierSet.Product_Recurring_Charges__r){
                    //Contract_Recurring_Charge__c objContRecCharge = new Contract_Recurring_Charge__c(Contract_Tier_Set__c = objContractTierSet.Id);
                    Contract_Recurring_Charge__c objContRecCharge = new Contract_Recurring_Charge__c();
                    // Populate default price if there is one
                    if(objProdRC.Amount__c != null)
                        objContRecCharge.Amount__c = objProdRC.Amount__c;                                    
                    objContRecCharge.Charge_Description__c = objProdRC.Charge_Description__c;
                    objContRecCharge.External_Note__c = objProdRC.External_Note__c;
                    objContRecCharge.Type__c = objProdRC.Type__c;
                    objContRecCharge.CurrencyISOCode = objContract.Quote__r.CurrencyISOCode;
                    objTSWrapper.list_ContractRecurringCharges.add(objContRecCharge);
                }                
            }           
        }
    }
    
    public void addTierSetOnTop()
    {
        TierSetWrapper objTSWrapper = getNewTierSet();
        List<TierSetWrapper> list_TempWrap = new List<TierSetWrapper>{objTSWrapper};
        list_TempWrap.addAll(list_TierSetWrappers);
        list_TierSetWrappers = list_TempWrap;
    }
    //Added By Vijay - 31st Jul 2017 - End
    //
    // *** Handler for Remove BOGO Detail button ***
    public void removeBOGODetail()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        Integer intRow = Integer.valueOf(strRowIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            
            if(objTSWrapper.list_BOGODetails[intRow].Id != null)
            {
                objTSWrapper.list_BOGODetails[intRow].Is_Deleted__c = true;
                list_BOGODetailsBeingRemoved.add(objTSWrapper.list_BOGODetails[intRow]);
            }
            
            objTSWrapper.list_BOGODetails.remove(intRow);
        }
    }
    
    // *** Handler for Add BOGO Detail button ***
    public void addBOGODetail()
    {
        Integer intTierRow = Integer.valueOf(strTierIndex);
        if(intTierRow >= 0 && intTierRow < list_TierSetWrappers.size())
        {
            TierSetWrapper objTSWrapper = list_TierSetWrappers[intTierRow];
            BOGO_Detail__c objBOGODetail = new BOGO_Detail__c(Parent_Tier_Set__c = objTSWrapper.objContractTierSet.Id,
                                                              CurrencyISOCode = objContract.Quote__c != null ? objContract.Quote__r.CurrencyISOCode : objContract.Zuora_Quote__r.CurrencyISOCode);
            objTSWrapper.list_BOGODetails.add(objBOGODetail);
        }
    }
    
    // *** Handler for Edit button ***
    public void editBtnHandler()
    {
        blnIsEdit = true;
    }
    
    // *** Handler for BOGO Edit button ***
    public void editBOGOBtnHandler()
    {
        blnIsBOGOEdit = true;
        list_TierSetOptions = new List<SelectOption>();
        //list_TierSetOptions = new List<SelectOption>{new SelectOption(null,'--None--')};
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
            list_TierSetOptions.add(new SelectOption(objTSWrapper.objContractTierSet.Id,objTSWrapper.objContractTierSet.Name));
    }
    
    // *** Handler for Cancel Edit button ***
    public void cancelEditBtnHandler()
    {
        populateTierSetsAndServices();
        blnIsEdit = false;
    }
    
    // *** Handler for Cancel Edit BOGO Info button ***
    public void cancelEditBOGOBtnHandler()
    {
        populateTierSetsAndServices();
        blnIsBOGOEdit = false;
    }
    
    // *** Handler for Save button ***
    public void saveBOGOBtnHandler()
    {
        if(checkRequiredFieldsForBOGO() || checkValidationRulesForBOGO())
            return;
        
        // DB Save-point
        Savepoint objSP = Database.setSavepoint();
        try
        {       
            List<BOGO_Detail__c> list_BOGODetailsToSave = new List<BOGO_Detail__c>();
            
            for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
                list_BOGODetailsToSave.addAll(objTSWrapper.list_BOGODetails);
            
            // If Contract was ever approved then soft delete removed BOGO details
            if(objContract.Approved__c)
            {
                if(!list_BOGODetailsBeingRemoved.isEmpty())
                    list_BOGODetailsToSave.addAll(list_BOGODetailsBeingRemoved);
            }
            else
            {
                // Deleting removed BOGO Details
                if(!list_BOGODetailsBeingRemoved.isEmpty())
                    delete list_BOGODetailsBeingRemoved;
            }
            
            // Upserting BOGO Details
            if(!list_BOGODetailsToSave.isEmpty())
                upsert list_BOGODetailsToSave;
            
            cancelEditBOGOBtnHandler();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    // *** To check whether all required fields are filled for BOGO Details***
    Boolean checkRequiredFieldsForBOGO()
    {
        Boolean blnHasRequiredError = false;
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            for(BOGO_Detail__c objBOGODetail: objTSWrapper.list_BOGODetails)
            {
                // Parent Quantity is required
                if(objBOGODetail.Parent_Quantity__c == null || objBOGODetail.Parent_Quantity__c == 0)
                {
                    objBOGODetail.Parent_Quantity__c.addError('Required Value !');
                    blnHasRequiredError = true;
                }
                // Related Quantity is required
                if(objBOGODetail.Related_Quantity__c == null || objBOGODetail.Related_Quantity__c == 0)
                {
                    objBOGODetail.Related_Quantity__c.addError('Required Value !');
                    blnHasRequiredError = true;
                }
                // Related Tier Set is required
                if(objBOGODetail.Related_Tier_Set__c == null)
                {
                    objBOGODetail.Related_Tier_Set__c.addError('Required Value !');
                    blnHasRequiredError = true;
                }
            }
        }
        return blnHasRequiredError;
    }
    
    // *** To check whether all validations for BOGO are met ***
    Boolean checkValidationRulesForBOGO()
    {
        Boolean blnHasValidationError = false;
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            Set<Id> set_RelatedTierSetIds = new Set<Id>();
            for(BOGO_Detail__c objBOGODetail: objTSWrapper.list_BOGODetails)
            {
                if(objBOGODetail.Related_Tier_Set__c == objBOGODetail.Parent_Tier_Set__c)
                {
                    objBOGODetail.Related_Tier_Set__c.addError('Please choose a tier set different to the parent !');
                    blnHasValidationError = true;
                    continue;
                }
                if(set_RelatedTierSetIds.contains(objBOGODetail.Related_Tier_Set__c))
                {
                    objBOGODetail.Related_Tier_Set__c.addError('Same Tier Set selected more than once !');
                    blnHasValidationError = true;
                    continue;
                }
                set_RelatedTierSetIds.add(objBOGODetail.Related_Tier_Set__c);
            }
        }
        return blnHasValidationError;
    }
    
    // *** Handler for Save button ***
    public void saveBtnHandler()
    {
        if(checkRequiredFields() || checkValidationRules() || checkTierRanges())
            return;
        // DB Save-point
        Savepoint objSP = Database.setSavepoint();
        try
        {       
            saveLogic();
            cancelEditBtnHandler();
            // Tier Sets may have changed
            populateBillingCommitments();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    // *** Handler for Quick Save button ***
    public void quickSaveBtnHandler()
    {
        if(checkRequiredFields() || checkValidationRules() || checkTierRanges())
            return;
        
        // DB Save-point
        Savepoint objSP = Database.setSavepoint();
        try
        {       
            saveLogic();
            populateTierSetsAndServices();
            // Tier Sets may have changed
            populateBillingCommitments();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    // *** To check whether all required fields are filled ***
    Boolean checkRequiredFields()
    {
        Boolean blnHasRequiredError = false;
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            // Tier Set Name is required
            if(String.isBlank(objTSWrapper.objContractTierSet.Name))
            {
                objTSWrapper.objContractTierSet.Name.addError('Please provide a name for the Tier Set');
                blnHasRequiredError = true;
            }
            // Aggregation Model for tier Set is required
            if(String.isBlank(objTSWrapper.objContractTierSet.Aggregation_Model__c))
            {
                objTSWrapper.objContractTierSet.Aggregation_Model__c.addError('Please select an Aggregation Model');
                blnHasRequiredError = true;
            }
            // Units Type for tier Set is required
            if(String.isBlank(objTSWrapper.objContractTierSet.Units_Type__c))
            {
                objTSWrapper.objContractTierSet.Units_Type__c.addError('Please select Units Type');
                blnHasRequiredError = true;
            }
            // Usage Term for tier Set is required
            if(String.isBlank(objTSWrapper.objContractTierSet.Period_In_Months__c))
            {
                objTSWrapper.objContractTierSet.Period_In_Months__c.addError('Please specify Usage Term');
                blnHasRequiredError = true;
            }
            // From, To and Price are required for Tier Ranges
            for(Contract_Tier_Range__c objContractTR : objTSWrapper.list_ContractTierRanges)
            {
                if(objContractTR.From__c == null)
                {
                    objContractTR.From__c.addError('Required Value !');
                    blnHasRequiredError = true;
                }
                if(objContractTR.To__c == null)
                {
                    /*objContractTR.To__c.addError('Required Value !');
blnHasRequiredError = true;*/
                    // Default to 999,999,999,999 if left blank
                    objContractTR.To__c = 999999999999.0;
                }
                if(objContractTR.Price__c == null)
                {
                    objContractTR.Price__c.addError('Required Value !');
                    blnHasRequiredError = true;
                }
            }
            // Service is required for Contract Services
            for(Contract_Service__c objContService : objTSWrapper.list_ContractServices)
            {
                if(objContService.Service__c == null)
                {
                    objContService.Service__c.addError('Please select a service');
                    blnHasRequiredError = true;
                }
            }
            // Recurring Charges only allow Pre-Bill on Flat fees.
            for (Contract_Recurring_Charge__c rc : objTSWrapper.list_ContractRecurringCharges) {
                if (rc.Pre_Bill__c == true) {
                    if (rc.Type__c != 'Monthly Flat Fee' && rc.Type__c != 'Variable Term Flat Fee' && rc.Type__c != 'One Time Flat Fee' && rc.Type__c != 'Installment Plan') {
                        rc.Type__c.addError('Recurring charges cannot be Pre-Bill unless a flat fee or installment plan');
                        blnHasRequiredError = true;
                    }
                }
                
                //Add Validation per CRMBILL-121
                Boolean  isNullQuantity;
                if(rc.Quantity__c == null) isNullQuantity = true;
                    else isNullQuantity = false;
                
               Boolean  isNullRate;
                if(rc.Rate__c == null) isNullRate = true;
                    else isNullRate = false;
                
                Boolean  isNullAmount;
                if(rc.Amount__c == null) isNullAmount = true;
                    else isNullAmount = false;
                
                if(isNullAmount){
                    if(isNullRate){
                        //Enter Rate to calculate amount
                        rc.Rate__c.addError('Enter Rate to calculate amount');
                        blnHasRequiredError = true;
                        break;
                    }else if(isNullQuantity){
                        //Enter Quantitiy to calculate amount
                        rc.Quantity__c.addError('Enter Quantity to calculate amount');
                        blnHasRequiredError = true;
                        break;
                    }else{
                        //popuate amount =  Rate * quantity
                        rc.Amount__c = rc.Rate__c * rc.Quantity__c;
                       // blnHasRequiredError = false;
                    }                   
                }else{
                     if(isNullQuantity && isNullRate){
                        //blnHasRequiredError = false;
                    }else{
                        //Match the amount = Rate * quantity - Valid
                        if(isNullQuantity){
                            rc.Quantity__c.addError('Enter Quantity to calculate amount');
                            blnHasRequiredError = true;
                            break;
                        }else if(isNullRate){                               
                            rc.Rate__c.addError('Enter Rate to calculate amount');
                            blnHasRequiredError = true;
                            break;
                        }else if(!isNullRate && !isNullRate){
                            if(rc.Amount__c == (rc.Rate__c * rc.Quantity__c)){                                
                                //blnHasRequiredError = false;
                            }
                            else{
                                rc.Amount__c.addError('Amount should be equal to Quantity * Rate');
                                blnHasRequiredError = true;
                                break;
                            }                            
                        }
                    }
                }
                
                System.Debug('blnHasRequiredError - ' + blnHasRequiredError);
                
            }
        }
        return blnHasRequiredError;
    }
    
    // *** To check whether all validations (other than Tier Range) are met ***
    Boolean checkValidationRules()
    {
        System.debug('checkValidationRules');
        Boolean blnHasValidationError = false;
        Set<Id> set_ServiceIds = new Set<Id>();
        Set<Id> set_ServiceIdsNoDupsAllowed = new Set<Id>();
        //Set<String> set_CarrierServiceIds = new Set<String>();
        Set<String> set_TierNames = new Set<String>();
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            // Two tier Sets cannot have the same name
            if(set_TierNames.contains(objTSWrapper.objContractTierSet.Name))
            {
                objTSWrapper.objContractTierSet.Name.addError('Identical Names.');
                blnHasValidationError = true;
            }
            else
                set_TierNames.add(objTSWrapper.objContractTierSet.Name);
            
            if(objTSWrapper.objContractTierSet.Quote_Product__c == null && objTSWrapper.objContractTierSet.Quote_Charge_Detail__c == null && objTSWrapper.objContractTierSet.Product__c == null)
            {
                objTSWrapper.objContractTierSet.Product__c.addError('Required !!');
                blnHasValidationError = true;
            }
           
            for(Contract_Service__c objContService : objTSWrapper.list_ContractServices)
            {
                // Duplicate Services cannot be there on a Contract
                if(set_ServiceIdsNoDupsAllowed.contains(objContService.Service__c)) {
                    objContService.Service__c.addError('There can be only 1 instance of this Service on a Contract:' + 
                        (objContService.Id != null ? ('(' + objContService.Service__r.Name + ')') : ''));
                    blnHasValidationError = true;
                } else {
                    set_ServiceIds.add(objContService.Service__c);
                    // Improve this logic with config
                    if (objContService.Service__r.Service_Type_Value__c >= 1 &&
                        objContService.Service__r.Service_Type_Value__c <= 4) {
                           System.Debug('checkValidationRules: dont allow duplicate service ' + objContService.Service__r.Name);
                           set_ServiceIdsNoDupsAllowed.add(objContService.Service__c);
                    }
                }
            }
        }

        if(!blnHasValidationError) {
            System.debug('checkValidationRules: query against other contracts');
            // There should be only instance of each service across all contracts with the customer
            List<Contract_Service__c> list_OtherContractServices = [SELECT Service__r.Name,Contract_Tier_Set__r.Contract__r.Name 
                        FROM Contract_Service__c WHERE Contract_Tier_Set__r.Contract__c != :objContract.Id AND 
                        Contract_Tier_Set__r.Contract__c = :setContractsWithSamePlatformIds AND Service__c IN :set_ServiceIdsNoDupsAllowed
                        AND Contract_Tier_Set__r.Contract__r.Status__c = 'Approved' 
                        AND Is_Deleted__c = false
                        ORDER BY Contract_Tier_Set__r.Contract__r.Name];
            
            if(!list_OtherContractServices.isEmpty())
            {
                blnHasValidationError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The following service(s) are already added to a different contract for the same customer.'));
                for(Contract_Service__c objContService : list_OtherContractServices)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,objContService.Service__r.Name + ' (' + objContService.Contract_Tier_Set__r.Contract__r.Name + ')'));
            }
        }


        List<Service__c> list_InactiveServices = [SELECT Name FROM Service__c WHERE Id IN :set_ServiceIds AND Active__c = false];
        if(!list_InactiveServices.isEmpty())
        {
            blnHasValidationError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The following services are inactive and cannot be added to the Contract.'));
            for(Service__c objService : list_InactiveServices)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,objService.Name));
        }
        
        //Default blank valuse in Business Care
        System.Debug('Checking Recurring Charges for its values and set defaults where appropriate');
        List<Contract_Recurring_Charge__c> list_ContractRecurringChargesToSave = new List<Contract_Recurring_Charge__c>();
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            list_ContractRecurringChargesToSave.addAll(objTSWrapper.list_ContractRecurringCharges);
        }
        System.debug('Starting rcs');
        for (Contract_Recurring_Charge__c rc: list_ContractRecurringChargesToSave) {
            System.debug('rc ' + rc);
            if (rc.Type__c == null) {
                blnHasValidationError = true;
                rc.addError('Recurring Charge Type Required');
            }
            if (rc.Type__c == 'Business Care') {
                rc.Charge_Description__c = 'Business Care for Cloud';
                if (rc.Amount__c == null) {
                    rc.Amount__c = 500;
                }
                System.debug('Found A Business Care [' + rc.Business_Care_Min_Revenue_Threshold__c + ',' + rc.Business_Care_Max_Revenue_Threshold__c + ',' + rc.Business_Care_Support_Fee_Percentage__c + ']');
                if (rc.Business_Care_Min_Revenue_Threshold__c == null) {
                    rc.Business_Care_Min_Revenue_Threshold__c = 0;
                }
                if (rc.Business_Care_Max_Revenue_Threshold__c <= 0) {
                    rc.Business_Care_Max_Revenue_Threshold__c.addError('Max Revenue Threshold must be greater than 0. Leave blank to have no Max Threshold.');
                    blnHasValidationError = true;
                }
                if (rc.Business_Care_Support_Fee_Percentage__c == null) {
                    rc.Business_Care_Support_Fee_Percentage__c = 15;
                }
            }
        }
        
        return blnHasValidationError;
    }
    
    // *** To check whether Tier Range validations are met ***
    @TestVisible
    Boolean checkTierRanges()
    {
        Boolean blnHasTierRangeError = false;
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            for(Contract_Tier_Range__c objContractTR : objTSWrapper.list_ContractTierRanges)
            {
                // Range must be correctly set
                if(objContractTR.From__c > objContractTR.To__c)
                {
                    objContractTR.To__c.addError('To < From');
                    blnHasTierRangeError = true;
                }
            }
        }
        if(blnHasTierRangeError)
            return blnHasTierRangeError;
        
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            Integer intTempSize = objTSWrapper.list_ContractTierRanges.size();
            // There should not be any gaps in Ranges
            for(Integer i=1; i<intTempSize ; i++)
            {
                Contract_Tier_Range__c objPreviousTR = objTSWrapper.list_ContractTierRanges[i-1];
                Contract_Tier_Range__c objCurrentTR = objTSWrapper.list_ContractTierRanges[i];
                if((objPreviousTR.To__c + 1) != objCurrentTR.From__c)
                {
                    blnHasTierRangeError = true;
                    objCurrentTR.From__c.addError('Ranges must be continuous');
                }
            }
        }
        
        return blnHasTierRangeError;
    }
    
    // *** Save logic for Tier Set Configuration ***
    @TestVisible
    void saveLogic()
    {
        List<Contract_Tier_Set__c> list_ContractTierSetsToSave = new List<Contract_Tier_Set__c>();
        List<Contract_Tier_Range__c> list_ContractTRsToSave = new List<Contract_Tier_Range__c>();
        List<Contract_Service__c> list_ContractServicesToSave = new List<Contract_Service__c>();
        List<Contract_Recurring_Charge__c> list_ContractRecurringChargesToSave = new List<Contract_Recurring_Charge__c>();
        List<BOGO_Detail__c> list_BOGODetailsToSave = new List<BOGO_Detail__c>();
        
        // Save all Tier Sets first
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            if (objTSWrapper.objContractTierSet.Carrier__c == 'None') {
                objTSWrapper.objContractTierSet.Carrier__c = null;
            }
            list_ContractTierSetsToSave.add(objTSWrapper.objContractTierSet);
            // Ensuring that all Tier Sets have a product as well
            if(objTSWrapper.objContractTierSet.Quote_Product__c != null && objTSWrapper.objContractTierSet.Quote_Charge_Detail__c == null && objTSWrapper.objContractTierSet.Product__c == null)
                objTSWrapper.objContractTierSet.Product__c = objTSWrapper.objContractTierSet.Quote_Product__r.BigMachines__Product__c;
            else if(objTSWrapper.objContractTierSet.Quote_Product__c == null && objTSWrapper.objContractTierSet.Quote_Charge_Detail__c != null && objTSWrapper.objContractTierSet.Product__c == null)
                objTSWrapper.objContractTierSet.Product__c = objTSWrapper.objContractTierSet.Quote_Charge_Detail__r.zqu__ProductRatePlan__r.zqu__Product__c;
            
        }
        
        // Tier Sets to be soft deleted are added to the save list for tier sets
        if(objContract.Approved__c && !list_TierSetsBeingRemoved.isEmpty())
            list_ContractTierSetsToSave.addAll(list_TierSetsBeingRemoved);
        
        // Contract Tier Sets
        if(!list_ContractTierSetsToSave.isEmpty())
            upsert list_ContractTierSetsToSave;
        
        // Update Tier Set Ids where ever needed
        for(TierSetWrapper objTSWrapper : list_TierSetWrappers)
        {
            for(Contract_Tier_Range__c objContractTR : objTSWrapper.list_ContractTierRanges)
            {
                if(objContractTR.Contract_Tier_Set__c == null)
                    objContractTR.Contract_Tier_Set__c = objTSWrapper.objContractTierSet.Id;
            }
            list_ContractTRsToSave.addAll(objTSWrapper.list_ContractTierRanges);
            
            for(Contract_Service__c objContService : objTSWrapper.list_ContractServices)
            {
                if(objContService.Contract_Tier_Set__c == null)
                    objContService.Contract_Tier_Set__c = objTSWrapper.objContractTierSet.Id;
            }
            list_ContractServicesToSave.addAll(objTSWrapper.list_ContractServices);
            
            for(Contract_Recurring_Charge__c objRecCharge : objTSWrapper.list_ContractRecurringCharges)
            {
                if(objRecCharge.Contract_Tier_Set__c == null)
                    objRecCharge.Contract_Tier_Set__c = objTSWrapper.objContractTierSet.Id;
            }
            list_ContractRecurringChargesToSave.addAll(objTSWrapper.list_ContractRecurringCharges);
        }
        
        // If Contract was ever approved then soft delete removed Contract Services, Contract Recurring Charges, Ranges etc.
        if(objContract.Approved__c)
        {
            // Contract Services
            if(!list_ContractServicesBeingRemoved.isEmpty())
                list_ContractServicesToSave.addAll(list_ContractServicesBeingRemoved);
            
            // Contract Recurring Charges
            if(!list_ContractRecChargesBeingRemoved.isEmpty())
                list_ContractRecurringChargesToSave.addAll(list_ContractRecChargesBeingRemoved);
            
            // Contract Tier Ranges
            if(!list_ContractTierRangesBeingRemoved.isEmpty())
                list_ContractTRsToSave.addAll(list_ContractTierRangesBeingRemoved);
            
            // Soft delete all children records of tier sets being soft deleted
            for(Contract_Tier_Set__c objContractTierSet : list_TierSetsBeingRemoved)
            {
                // Contract Services
                if(!objContractTierSet.Contract_Services__r.isEmpty())
                {
                    for(Contract_Service__c objContService : objContractTierSet.Contract_Services__r)
                        objContService.Is_Deleted__c = true;
                    
                    list_ContractServicesToSave.addAll(objContractTierSet.Contract_Services__r);
                }
                // Contract Recurring Charges
                if(!objContractTierSet.Contract_Recurring_Charges__r.isEmpty())
                {
                    for(Contract_Recurring_Charge__c objRecCharge : objContractTierSet.Contract_Recurring_Charges__r)
                        objRecCharge.Is_Deleted__c = true;
                    
                    list_ContractRecurringChargesToSave.addAll(objContractTierSet.Contract_Recurring_Charges__r);
                }
                // Contract Tier Ranges
                if(!objContractTierSet.Contract_Tier_Ranges__r.isEmpty())
                {
                    for(Contract_Tier_Range__c objContractTR : objContractTierSet.Contract_Tier_Ranges__r)
                        objContractTR.Is_Deleted__c = true;
                    
                    list_ContractTRsToSave.addAll(objContractTierSet.Contract_Tier_Ranges__r);
                }
                // BOGO Details
                if(!objContractTierSet.BOGO_Details__r.isEmpty())
                {
                    for(BOGO_Detail__c objBOGODetail : objContractTierSet.BOGO_Details__r)
                        objBOGODetail.Is_Deleted__c = true;
                    
                    list_BOGODetailsToSave.addAll(objContractTierSet.BOGO_Details__r);
                }
            }
        }
        else
        {  
            // Contract Services
            if(!list_ContractServicesBeingRemoved.isEmpty())
                delete list_ContractServicesBeingRemoved;
            
            // Contract Recurring Charges
            if(!list_ContractRecChargesBeingRemoved.isEmpty())
                delete list_ContractRecChargesBeingRemoved;
            
            // Contract Tier Ranges
            if(!list_ContractTierRangesBeingRemoved.isEmpty())
                delete list_ContractTierRangesBeingRemoved;
            
            // Contract Tier Sets
            if(!list_TierSetsBeingRemoved.isEmpty())
                delete list_TierSetsBeingRemoved;
        }
        
        // Save all dependent records of tier Sets
        
        // Contract Tier Ranges
        if(!list_ContractTRsToSave.isEmpty())
            upsert list_ContractTRsToSave;
        
        // Contract Services
        if(!list_ContractServicesToSave.isEmpty())
            upsert list_ContractServicesToSave;
        
        // Contract Recurring Charges
        if(!list_ContractRecurringChargesToSave.isEmpty())
            upsert list_ContractRecurringChargesToSave;
        
        // BOGO Details
        if(!list_BOGODetailsToSave.isEmpty())
            upsert list_BOGODetailsToSave;
    }
    
    // *** Re-rate button handler ***
    public void reRateUsageData()
    {
        //Assign Month and Year values from new drop down
        //List<string> varMonthYear = RerateYearMonthSelection.split('-');
        //objRerateLog.Month__c = varMonthYear[0];
        //objRerateLog.Year__c = varMonthYear[1];  
        System.debug(objRerateLog.Month__c);
        System.debug(objRerateLog.Year__c);
        
        if(objContract.Status__c != 'Approved')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot re-rate data as contract is not in approved status.'));
            return;
        }
        
        if((String.isBlank(objRerateLog.Month__c) || String.isBlank(objRerateLog.Year__c)) && 
           (objRerateLog.Start_Date__c == null || objRerateLog.End_Date__c == null))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select either month/year or date range.'));
            return;
        }
        // Block execution of job if rerating or rating job is currently running
        if(CloudBillingUtil.blnIsRatingJobRunning())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please wait for the current Re-Rate job to complete and try again in some time.'));
            return;
        }
        
        // DB Save-point
        SavePoint objSP = Database.setSavepoint();
        try
        {            
            Date dtStart,dtEnd;
            if(String.isNotBlank(objRerateLog.Month__c) && String.isNotBlank(objRerateLog.Year__c))
            {                
                dtStart = date.newInstance(Integer.valueOf(objRerateLog.Year__c), Integer.valueOf(objRerateLog.Month__c),objContract.Pricing_Start_Date__c.day());
                dtEnd = dtStart.addDays(Date.daysInMonth(Integer.valueOf(objRerateLog.Year__c),Integer.valueOf(objRerateLog.Month__c)));
            }
            /*else if(objRerateLog.Start_Date__c != null && objRerateLog.End_Date__c != null)
{
dtStart = objRerateLog.Start_Date__c;
dtEnd = objRerateLog.End_Date__c;
}*/
            else
            {                
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select either month/year or date range.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month/year.'));
                return;
            }
            // objRerateLog is sent in from UI to gather the month. Don't create a new one.
            objRerateLog.Type__c = 'Re-Rate';
            objRerateLog.Status__c = 'Submitted';
            objRerateLog.Account__c = objContract.Account_Name__c;
            objRerateLog.User__c = UserInfo.getUserId();
            objRerateLog.Time__c = DateTime.now();
            objRerateLog.Start_Date__c = dtStart;
            objRerateLog.End_Date__c = dtEnd;
            System.debug('reRateUsageData: Inserting Log ' + objRerateLog);
            insert objRerateLog;
            
            // Invoke batch Job to reprocess Usage Data (batch size = 2000).
            System.debug('Rerating Start:' + dtStart + ' End:' + dtEnd + ' Account:' + objContract.Account_Name__c);
            BatchReRateUsageData objBatch = new BatchReRateUsageData(dtStart,dtEnd,objContract.Account_Name__c);
            objBatch.objJobLog = objRerateLog;
	        Integer intRatingBatchSize = Integer.valueOf(Label.Billing_Rating_Batch_Size);
            idReRateJob = Database.executeBatch(objBatch,intRatingBatchSize);
            objRerateLog.AsyncApexJob_Id__c = idReRateJob;
            update objRerateLog;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                                       'Re-Rating started. After Completing all Rerates, please run the Reconcile Job from the Contract Search Admin Tab to update the Reconciliation Report.'));
            // Re-setting Id so that the object can be re-used to create another record
            objRerateLog.Id = null;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    // *** Rating button handler ***
    // Added by Vijay - Start
    public void rateUsageData(){
        
        if(objContract.Status__c != 'Approved')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot rate data as contract is not in approved status.'));
            return;
        }
        // Block execution of job if rerating or rating job is currently running
        if(CloudBillingUtil.blnIsRatingJobRunning())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please wait for the current Rate or Re-Rate job to complete and try again in some time.'));
            return;
        }
        // DB Save-point
        SavePoint objSP = Database.setSavepoint();
        try{
            objRateLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
            objRateLog.Account__c = objContract.Account_Name__c;
            objRateLog.User__c = UserInfo.getUserId();
            objRateLog.Time__c = DateTime.now();
            System.debug('RateCloudUsageData: Inserting Log ' + objRateLog);
            insert objRateLog;
            System.debug('RateCloudUsageData: Log Id: '+objRateLog.Id);
            
            BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
            objBatch.objJobLog = objRateLog;
            Integer intRatingBatchSize = Integer.valueOf(Label.Billing_Rating_Batch_Size);
            Id idRatingJob = Database.executeBatch(objBatch,intRatingBatchSize); 
            objRateLog.AsyncApexJob_Id__c = idRatingJob;
            update objRateLog;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                                                       'Rating started. After Completing all Rates, please run the Reconcile Job from the Contract Search Admin Tab to update the Reconciliation Report.'));
            // Re-setting Id so that the object can be re-used to create another record
            objRateLog.Id = null;
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
        
    }
    // Added by Vijay - End
    
    // *** Manual Order Creation Handler ***
    // Added By Vijay - Oct 6th 2017  - CRMBILL-158 - Start
    public void handleManualOrderCreation(){
        if(objContract.Status__c != 'Approved')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create order. Contract is not in approved status.'));
            return;
        }
        if(String.isBlank(objLog.Month__c) || String.isBlank(objLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to create Order.'));
            return;
        }
        
        CloudBillingData objData = new CloudBillingData();
        objData.contractId = objContract.Id;
        objData.month = objLog.Month__c;
        objData.year = objLog.Year__c;
        objData.day = objContract.Pricing_Start_Date__c.day()+'';
        
        objLog = CloudBillingUtil.createNewCloudBillingLog('Order Creation Manual', 'Submitted');
        objLog.Month__c = objData.month;
        objLog.Year__c = objData.year;
        
        // DB Save-point
        SavePoint objSP = Database.setSavepoint();
        try{
            BatchCreateCloudMonthlySalesOrders objBatchJob = new BatchCreateCloudMonthlySalesOrders(objData);
            List<Id> list_masterOrderIds = new List<Id>();
            list_masterOrderIds.add(objContract.Quote__r.Order__c);
            objBatchJob.mapMasterOrderIdToActiveSubscription = CloudBillingUtil.getMapMasterOrderIdToActiveSubscription(list_masterOrderIds);

            DateTime dtTime = DateTime.now();
            String strDateTime = dtTime.format('hhmmss');
            Order__c objOrder = objBatchJob.createOrder(objContract, 'M' + strDateTime);

            Util.Bypass_Trigger_Chk = true;
            insert objOrder;

            Account_Order_Address__c objBillingAddress = [SELECT Id, GCR_Content_Document_Detail__c,Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                                                      Zip_Code__c, Phone__c, Fax__c, Email__c,Additional_Emails__c, GCR_Content_Document_Detail__r.Account_Name_Override__c
                                                                      FROM Account_Order_Address__c WHERE
                                                                      GCR_Content_Document_Detail__c = :objContract.Id
                                                                      and Address_Type__c = 'Bill To'
                                                                      LIMIT 1];
            {
            Account_Order_Address__c objBillToAddress = objBillingAddress.clone(false, true, false, false);
            if (objContract.Account_Name_Override__c != null) {
                objBillToAddress.Company__c = objContract.Account_Name_Override__c;
            }
            objBillToAddress.Address_Type__c = 'Bill To';
            objBillToAddress.GCR_Content_Document_Detail__c = null;
            objBillToAddress.Quote__c = null;
            objBillToAddress.Zuora_Quote__c = null;
            objBillToAddress.Account__c = objOrder.End_User_Name__c;
            objBillToAddress.Sold_To_Business_Partner__c = objOrder.End_User_Name__c;
            objBillToAddress.Order__c = objOrder.Id;
            insert objBillToAddress;
            }
            {
            Account_Order_Address__c objShipToAddress = objBillingAddress.clone(false, true, false, false);
            if (objContract.Account_Name_Override__c != null) {
                objShipToAddress.Company__c = objContract.Account_Name_Override__c;
            }
            objShipToAddress.Address_Type__c = 'Ship To';
            objShipToAddress.GCR_Content_Document_Detail__c = null;
            objShipToAddress.Quote__c = null;
            objShipToAddress.Zuora_Quote__c = null;
            objShipToAddress.Account__c = objOrder.End_User_Name__c;
            objShipToAddress.Sold_To_Business_Partner__c = objOrder.End_User_Name__c;
            objShipToAddress.Order__c = objOrder.Id;
            insert objShipToAddress;
            }

            System.debug('Order Id : '+objOrder.Id);
            Util.Bypass_Trigger_Chk = false;  
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Order Creation Completed.'));
            
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            
            objLog.Exceptions__c += ex.getMessage();
            
            Database.rollback(objSP);
        }
        
        objLog.Status__c = 'Completed';
        upsert objLog;
        
        objLog.Id = null;
        
    }
    // Added By Vijay - Oct 6th 2017  - CRMBILL-158 - End
    
    
    // *** View Usage Report button handler ***
    public PageReference viewUsageReport()
    {
        if(String.isBlank(objLog.Month__c) || String.isBlank(objLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view usage report.'));
            return null;
        }
        String strMonth = objLog.Month__c;
        String strYear = objLog.Year__c;
        if (CloudBillingUtil.isBillingLastMonth(objContract.Product_Group__c) || Test.isRunningTest()) {
            Cloud_Billing_Log__c objLastMonthLog = CloudBillingUtil.getLogLastMonth(objLog);
            strMonth = objLastMonthLog.Month__c;
            strYear = objLastMonthLog.Year__c;
        }
        return (new PageReference('/' + Label.Usage_Report_Id + '?pv0=' + objContract.Name + '&pv1=' + strMonth + '&pv2=' + strYear));
    }
    public PageReference viewUsageReportWithBursting()
    {
        if(String.isBlank(objLog.Month__c) || String.isBlank(objLog.Year__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select month and year to view usage report.'));
            return null;
        }
        String strMonth = objLog.Month__c;
        String strYear = objLog.Year__c;
        System.debug('viewUsageReportWithBursting:objContract.Product_Group__c ' + objContract.Product_Group__c);
        if (CloudBillingUtil.isBillingLastMonth(objContract.Product_Group__c) || Test.isRunningTest()) {
            Cloud_Billing_Log__c objLastMonthLog = CloudBillingUtil.getLogLastMonth(objLog);
            strMonth = objLastMonthLog.Month__c;
            strYear = objLastMonthLog.Year__c;
        }
        return (new PageReference('/' + Label.Usage_Report_With_Bursting_Id + '?pv0=' + objContract.Name + '&pv1=' + strMonth + '&pv2=' + strYear));
    }    
    // *** Method to check the Permission set assigned to the running user ***
    public void checkPermissions()
    {
        blnIsContractApprover = blnIsContractManager = blnIsContractReadOnly = blnIsContractSuperUser = false;
        for(PermissionSetAssignment objPSA : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND 
                                              (PermissionSet.Name in ('Cloud_Billing_Contract_Manager',
                                                                      'Cloud_Billing_Contract_Approver',
                                                                      'Cloud_Billing_Contract_Read_Only',
                                                                      'Cloud_Billing_Super_User',
                                                                      'Cloud_Billing_Currency_Mgmt', // Not used currently in UI
                                                                      'Cloud_Billing_Developer', // Not used currently in UI
                                                                      'Cloud_Billing_Invoicing'))]) // Not used currently in UI
        {
            if(objPSA.PermissionSet.Name == 'Cloud_Billing_Contract_Manager')
                blnIsContractManager = true;
            else if(objPSA.PermissionSet.Name == 'Cloud_Billing_Contract_Manager')
                blnIsContractApprover = true;
            else if(objPSA.PermissionSet.Name == 'Cloud_Billing_Contract_Read_Only')
                blnIsContractReadOnly = true;
            // Super Users gets them all?
            else if(objPSA.PermissionSet.Name == 'Cloud_Billing_Super_User') {
                blnIsContractSuperUser = true;
                //blnIsContractManager = true;
                //blnIsContractApprover = true;
                //blnIsContractReadOnly = true;
            }
            // fall out of logic no permission set
        }
        System.debug('blnIsContractApprover ' + blnIsContractApprover);
        System.debug('blnIsContractManager ' + blnIsContractManager);
        System.debug('blnIsContractReadOnly ' + blnIsContractReadOnly);
        System.debug('blnIsContractSuperUser ' + blnIsContractSuperUser);
    }
    
    // *** Method to clone Contract ***
    public PageReference cloneBtnHandler()
    {
        GCR_Content_Document_Detail__c objSourceContract = fetchContract(objContract.Id);
        // Clone contract
        GCR_Content_Document_Detail__c objClonedContract = objSourceContract.clone(false,true,false,false);
        objClonedContract.Document_Name__c = 'Cloud Billing Contract';
        objClonedContract.Status__c = 'In Progress';
        objClonedContract.Approved__c = false;
        insert objClonedContract;
        
        //Nitin - Add new biling address
        Account_Order_Address__c objClonedAOAdd = objBillingAddress.clone(false,true,false,false);
        objClonedAOAdd.GCR_Content_Document_Detail__c = objClonedContract.Id;
        objClonedAOAdd.Quote__c = objClonedAOAdd.Zuora_Quote__c = NULL;
        insert objClonedAOAdd;
        
        // Clone Contract Tier Sets
        List<Contract_Tier_Set__c> list_ContractTierSets = fetchTierSetConfiguration();
        List<Contract_Tier_Set__c> list_ClonedContractTierSets = list_ContractTierSets.deepClone(false,false,false);
        
        for(Contract_Tier_Set__c objClonedContractTierSet : list_ClonedContractTierSets)
            objClonedContractTierSet.Contract__c = objClonedContract.Id;
        
        if(!list_ClonedContractTierSets.isEmpty())
            insert list_ClonedContractTierSets;
        
        Map<Id,Id> map_OldToNewTierSetId = new Map<Id,Id>();
        Integer i=-1;
        for(Contract_Tier_Set__c objClonedContractTierSet : list_ClonedContractTierSets)
            map_OldToNewTierSetId.put(list_ContractTierSets[++i].Id,objClonedContractTierSet.Id);
        
        // Clone Contract Tier Set Child Objects
        List<Contract_Tier_Range__c> list_ClonedTierRanges = new List<Contract_Tier_Range__c>();
        List<Contract_Service__c> list_ClonedContractServices = new List<Contract_Service__c>();
        List<Contract_Recurring_Charge__c> list_ClonedRecurringCharges = new List<Contract_Recurring_Charge__c>();
        List<BOGO_Detail__c> list_ClonedBOGODetails = new List<BOGO_Detail__c>();
        
        for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSets)
        {
            if(!objContractTierSet.Contract_Tier_Ranges__r.isEmpty())
                list_ClonedTierRanges.addAll(objContractTierSet.Contract_Tier_Ranges__r.deepClone(false,false,false));
            
            if(!objContractTierSet.Contract_Services__r.isEmpty())
                list_ClonedContractServices.addAll(objContractTierSet.Contract_Services__r.deepClone(false,false,false));
            
            if(!objContractTierSet.Contract_Recurring_Charges__r.isEmpty())
                list_ClonedRecurringCharges.addAll(objContractTierSet.Contract_Recurring_Charges__r.deepClone(false,false,false));
            
            if(!objContractTierSet.BOGO_Details__r.isEmpty())
                list_ClonedBOGODetails.addAll(objContractTierSet.BOGO_Details__r.deepClone(false,false,false));
        }
        
        for(Contract_Tier_Range__c objContractTR : list_ClonedTierRanges)
            objContractTR.Contract_Tier_Set__c = map_OldToNewTierSetId.get(objContractTR.Contract_Tier_Set__c);
        
        for(Contract_Service__c objContService : list_ClonedContractServices)
            objContService.Contract_Tier_Set__c = map_OldToNewTierSetId.get(objContService.Contract_Tier_Set__c);
        
        for(Contract_Recurring_Charge__c objRecCharge: list_ClonedRecurringCharges)
            objRecCharge.Contract_Tier_Set__c = map_OldToNewTierSetId.get(objRecCharge.Contract_Tier_Set__c);
        
        for(BOGO_Detail__c objBOGODetail : list_ClonedBOGODetails) 
        {
            objBOGODetail.Parent_Tier_Set__c = map_OldToNewTierSetId.get(objBOGODetail.Parent_Tier_Set__c);
            
            if(objBOGODetail.Related_Tier_Set__c != null)
                objBOGODetail.Related_Tier_Set__c = map_OldToNewTierSetId.get(objBOGODetail.Related_Tier_Set__c);
        }
        
        if(!list_ClonedTierRanges.isEmpty())
            insert list_ClonedTierRanges;
        
        if(!list_ClonedContractServices.isEmpty())
            insert list_ClonedContractServices;
        
        if(!list_ClonedRecurringCharges.isEmpty())
            insert list_ClonedRecurringCharges;
        
        if(!list_ClonedBOGODetails.isEmpty())
            insert list_ClonedBOGODetails;
        
        return (new PageReference('/' + objClonedContract.Id));
    }
    
}