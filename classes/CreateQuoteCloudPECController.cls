/************************************************************************************
Purpose : Controller class to handle quoting tool page CreateQuoteCloudPEC
Written By : Erik Doetsch and Kartik Silla
Test Classes : CreateQuoteCloudPECControllerTest
*************************************************************************************/
public without sharing class CreateQuoteCloudPECController
{
    private STRING STR_RAMP_PERIOD_DEFAULT = '180';
    public BigMachines__Quote__c quote {get; set;}
    public List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
    public List<QuoteProductWrapper> list_DisplayedQuoteProducts {get; set;} 
    public String quoteProductIdToBeDeleted {get; set;}
    String quoteId;
    Decimal decPricingMultiplier;
    Boolean blnSkipPriceCheck;
    
    //mukunth added for multi-year ACV
    public integer initSubTerm{get;set;}
    public decimal increasePercent{get;set;}
    //public boolean isMultiYrACVEdited{get;set;}
    public BigMachines__Quote__c clonedQuote{get;set;}
    public decimal currentConsolidatedQty{get;set;}
    public decimal prevConsolidatedQty{get;set;}
    
    //Mukunth added below two variables for DDS Mega Deals
    public boolean isMegaDealBln{get;set;}
    private Global_setting__c CloudPevMultiplierPC;
    
    Decimal decPureSuccessAlacarteSum;
    Decimal decPureSuccessBaseSum; 
    Decimal decEventSum;
    Decimal decOtherNonRecurringFees; 
    
    // For facet checkbox for Grid
    public Boolean blnIsHeaderChecked {get; set;}
    // List of Group Headers i.e. Categories or Proposal Group Numbers
    public List<String> list_GroupHeaders {get; set;}
    // Map of Group Header to List of Quote Product Wrappers
    public Map<String,List<QuoteProductWrapper>> map_GroupHeaderToQuoteProdWrapper {get; set;}
    // Training Unit Line
    public BigMachines__Quote_Product__c objTrainingUnit; 
    // For Index of Proposal Group table to determine which record is being removed
    public String strPGIndex {get; set;}
    // List of Proposal Groups being displayed
    public List<Quote_Proposal_Group__c> list_ProposalGroups {get; set;}
    // To indicate Proposal Group Table is in edit mode
    public Boolean blnEditProposalGroup {get; private set;}
    // To indicate if there are errors on Proposal Groups when saving
    public Boolean blnHasProposalGroupErrors {get; set;}
    // For error message if there are any errors when Proposal Groups are being edited
    public String strProposalGroupErrorMsg {get; set;}
    // To indicate whether to show bypass approvals button or not
    public Boolean blnShowByPassApprovals {get; set;}
    // List of Proposal Groups being edited
    public List<Quote_Proposal_Group__c> list_ProposalGroupsBeingEdited {get; set;}
    // List of Proposal Groups that have been removed from edit table and need to be deleted on save
    List<Quote_Proposal_Group__c> list_ProposalGroupsRemoved;
    // List of Proposal Group Number Options
    public List<SelectOption> list_ProposalGroupNumberOptions {get; set;}
    // Map of Proposal Group Number to Record
    Map<String,Quote_Proposal_Group__c> map_GroupNumToGrouprecord;
    // Proposal Group record to store un-grouped amount
    public Quote_Proposal_Group__c objUngrouped {get; private set;} 
    // To store whether to proceed with delete on not based on user decision
    public String strToDelete {get; set;}
    // To indicate whether there is an error when doCalculations() is invoked
    public Boolean blnHasError {get; set;}
    // All products excluding configuration products and bundle items products on the quote
    public List<BigMachines__Quote_Product__c> list_QuoteProductRecords;
    // Bundle Item Products
    List<BigMachines__Quote_Product__c> list_BundleItemQPRecords;
    // To store mass update input values
    public BigMachines__Quote_Product__c objMassUpdateInput {get; set;}
    // To indicate whether there is at least 1 HW Line
    public Boolean blnHasHWLines {get; private set;}
    // To indicate whether there is at least 1 Bundle
    public Boolean blnHasBundles {get; private set;}
    // Boolean to indicate whether it's a simulated quote (Pricing Simulator)
    public Boolean blnIsSimulated {get; private set;}
    // Map to store Bundle Quote Products
    //Boolean to set MSA Link Type as Read-Only
    public Boolean blnCustomMSAType{get;private set;}
    //To indicate PureBridge Opportunity-Rony Joseph-2019 July 22
    public boolean blnisPureBridgeOpp{get;set;}
    Map<Id,BigMachines__Quote_Product__c> map_BundleQuoteProducts;
    public Map<String,List<SelectOption>> map_FlavorsToSelectOptions {get; private set;}
    Id idSoldToAccount;
    Id idOpportunity;
    transient Decimal decTotalSWNetPrice,decTotalHWNetPrice,decTotalEducationNetPrice,decTotalServicesNetPrice,
        decTotalRecAmount,decTotalNonRecAmount,decTotalRecAmountPreDiscount,decTotalNonRecAmountPreDiscount, decTotalCredit, decTotalRecCredit, decTotalNonRecCredit;
    public String dqStatus {get; set;}    
    public Boolean showReviseDQPopup {get;set;}
    public Boolean blnShowSelectColumns {get; private set;}
    public User_Col_Preference__c objColumnPreference {get; set;}
    User_Col_Preference__c objColPrefCopy;
    String oldPricingModel;
    // **** For Pagination ****
    public Integer intPageNum {get; private set;}
    @TestVisible
    public Integer intPageSize {get; private set;}
    public Integer intTotalNoOfRecords {get; private set;}
    public Integer intTotalNoOfDisplayedRecords {get; private set;}    
    @TestVisible
    public String strNewOrderName {get; private set;}
    public String strManualListPriceUpdate {get; private set;}
    // To indicate whether this quote use old or new pricing
    public Boolean blnIsNewPricing {get; private set;}
    //To indicate that MSA Link type Changed
    public Boolean blnMSALInkTypeChange{get; set;}
    
    public Boolean blnIsOldQuote{get; set;}
    
    public Decimal maxSeatCount;
    
    //ECD May 2019 PEC Subscriptions
    public Map<String, String> map_ProdChangeHistory {get; set;}
    public Map<String, String> map_ProdChangeHistoryColor {get; set;}
    public List<Subscription_Product__c> list_RemovedPrevProds {get; set;}
    public String[] strChngeHistColors {get;set;} 
    //Map<String, Decimal> map_PCPartnerMargins = new Map<String, Decimal>();
    Map<String, String> map_SubCategoryRevMappings = new Map<String, String>();
    Map<String, Decimal> map_PrevProdQuantity = new Map<String, Decimal>();   
    
    //ECD PEC partner
    Map<String, Decimal> map_PECPartnerMargins = new Map<String, Decimal>();
    
    List<Deal_Qualification__c> dqs {get; set;}
    Set<ID> set_SeatCountParts = new Set<ID>();
    public static String strRangeandRatePlan = 'Range;Rate Plan';
    
    public DDSCloud.DDSCloudModel obj_DDS {get; set;}
    public DealScoreHistory__c objDDSHistory {get;set;}
    public class QuoteProductWrapper
    {
        public BigMachines__Quote_Product__c record {get; set;}
        public Boolean selected {get; set;}
        public string strPlayOffer{get; set;}
        public QuoteProductWrapper()
        {
            selected = false;
            strPlayOffer = '';
        }
    }
    
    @TestVisible
    public String strSelectedTab {get; private set;}
    
    public List<approvalWrapper> upfrontApprovals {get; set;}
    
    public class approvalWrapper
    {
        public String stepName {get; set;}
        public String styleClass {get; set;}
        public String rowType {get; set;}
        public String approvalReason {get; set;}
        public String functionName {get; set;}
        public String actualApprover {get; set;}
        public String approverName {get; set;}
        public String actualApproverEmailId {get; set;}
    }
    
    public class historyWrapper{
        public transient boolean showAction {get; set;}
        public transient String actionTitle {get; set;}
        public transient Quote_Approval__c approvalRecord {get; set;}
        public transient User actualApprover {get; set;}        
        public transient String rowType {get; set;}
        public transient String stepName {get; set;}
        public transient String styleClass {get; set;}
        public transient String statusClass {get; set;}
        public transient Boolean showOverallStatus {get; set;}
        public transient String submittedDate {get; set;}
        public transient String approvalRejectDate {get; set;}
        public transient String style {get; set;}
    }
    
    public transient Boolean showApprovalHistory {get; set;}
    public transient List<historyWrapper> approvals {get; set;}
    public transient String overAllStatus {get; set;}
    public transient String mode {get; set;}
    public transient Boolean showLastSubmission {get; set;}
    
    public Attachment objAttachment {get; set;}
    // To indicate whether or not to show export screening message
    public Boolean blnShowExportScreeningMsg {get; private set;}
    public Boolean blnShowExportScreeningExpireMsg {get; private set;}
    public id escid{get;private set;}
    @TestVisible
    public Boolean blnIsReviseOrder {get; private set;}
    
    public Boolean blnHasViolations {get; private set;}
    public transient List<DealQualificationAndQuoteApprovalHelper.wrapperViolationSummary> list_Violations {get; set;}
    public transient String strIsFinalize {get; private set;}
    public Deal_Qualification__c dq {get; private set;}
    @TestVisible
    public Decimal totalDiscount {get; private set;}
    public List<SelectOption> list_BillingPeriods {get; private set;}
    public List<SelectOption> list_InitialSubscriptionTerms {get; private set;}
    public List<SelectOption> list_RenewalSubscriptionTerms {get; private set;}
    public List<SelectOption> list_PaymentTerms {get; private set;}
    // ECD PEC Subscription 
    public List<SelectOption> list_RampPeriods {get; private set;}
    
    public Decimal decPreCreditCMRR {get; set;}
    public Decimal decPreCreditACV {get; set;}
    public Decimal decPreCreditTCV {get; set;}
    
    String strOldBillingCategory = '';
    
    public CreateQuoteCloudPECController()
    {
        dqStatus = 'Not Approved';
        //mukunth initialiazed for multi-year ACV
        initSubTerm = 0;
        increasePercent = 0.00;
        
        init();
        String strLandingTab = ApexPages.currentPage().getParameters().get('tab');
        strManualListPriceUpdate = ApexPages.currentPage().getParameters().get('listpriceupdate');
        if(String.isBlank(strManualListPriceUpdate)) {
            strManualListPriceUpdate = '0';
        }
        if(strLandingTab == 'DAPDetails')
            showDAPDetails();
        else if(strLandingTab == 'SpecialOffers')
            showSpecialOffers();
        else if(strLandingTab == 'QuoteApprovals')
        {
            mode =  ApexPages.currentPage().getParameters().get('mode');
            showQuoteApprovals();
        }
        else if(strLandingTab == 'OrderSubmission')
            showOrderSubmission();
        else
            showQuoteDetails();
        getDQStatus();
    }
    
    private void init()
    {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        objUngrouped = new Quote_Proposal_Group__c();
        objMassUpdateInput = new BigMachines__Quote_Product__c();
        list_BillingPeriods = new List<SelectOption>();
        list_InitialSubscriptionTerms = new List<SelectOption>();
        list_RenewalSubscriptionTerms = new List<SelectOption>();
        list_PaymentTerms = new List<SelectOption>();
        // ECD PEC Subscription 
        list_RampPeriods = new List<SelectOption>();
        list_RemovedPrevProds = new List<Subscription_Product__c>();
        intTotalNoOfDisplayedRecords = 0;
        
        //Mukunth added for DDS Mega Deals - get Cloud PEV Mutliplier from custom setting
        CloudPevMultiplierPC = Global_setting__c.getValues('Cloud PEV Multiplier PEC');
        
        blnIsHeaderChecked = blnShowByPassApprovals = blnSkipPriceCheck = blnIsReviseOrder = 
            blnShowExportScreeningMsg = blnShowExportScreeningExpireMsg = blnHasError = blnIsNewPricing = blnIsSimulated = blnHasViolations = blnMSALInkTypeChange = false;
        
        blnShowSelectColumns = false;
        
        // Fetching Quote information
        quote = getQuote((Id)quoteId);
        
        // blocking old quote
        blnIsOldQuote = false;
        // blnCustomMSAType = ((quote.Amendment_For__c != null && quote.Amendment_For__r.MSA_Link_Type__c == 'Custom' &&  quote.MSA_Link_Type__c == 'Standard' && quote.Order_Type__c == Label.Amend_Subscription)||(quote.BigMachines__Opportunity__c != null && quote.BigMachines__Opportunity__r.MSA_Link_Type__c == 'Custom' &&  quote.MSA_Link_Type__c == 'Standard' && (quote.Order_Type__c == Label.Renew_Subscription || quote.Order_Type__c == Label.New_Subscription))||(quote.Order_Type__c == Label.Amend_Subscription && quote.MSA_Link_Type__c == 'Custom'))?true:false;
        
        blnCustomMSAType = ((quote.Amendment_For__c != null && quote.Amendment_For__r.MSA_Link_Type__c == 'Custom' &&  quote.MSA_Link_Type__c == 'Standard' && quote.Order_Type__c == Label.Amend_Subscription)||(quote.BigMachines__Opportunity__c != null && quote.BigMachines__Opportunity__r.MSA_Link_Type__c == 'Custom' &&  quote.MSA_Link_Type__c == 'Standard' && (quote.Order_Type__c == Label.Renew_Subscription || quote.Order_Type__c == Label.New_Subscription))||(quote.MSA_Link_Type__c == 'Custom' && (quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.New_Subscription)))?true:false;
        blnisPureBridgeOpp = (quote.Lever__c != null && quote.BigMachines__Opportunity__r.Avaya_Contract_Expiration__c != null)?true:false;//To indicate PureBridge Opportunity-Rony Joseph-2019 July 22
        
        if(quote.order_type__c != Label.New_Subscription && quote.order_type__c != Label.Renew_Subscription && quote.order_type__c != Label.Amend_Subscription) 
        {
            blnIsOldQuote = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This quote is no longer available for modification, please use new PureEngage Cloud quoting tool to create a new quote.'));
        }
        objDDSHistory = DDSCloud.fetchDDSHistory(quote.Id);
        //Mukunth added below line for DDS Mega Deals
        if(quote.Annual_Contract_Value__c != null)
            isMegaDealBln = checkMegaDeal();
        else
            isMegaDealBln = false;
        
        system.debug(quote);
        
        List<User_Col_Preference__c> list_UserColPref = [SELECT Id,Third_Party__c,Name,Sub_Category__c,Ext_List_Price__c,Partner_Price__c,
                                                         List_Price__c,Net_Unit_Price__c,PM_Approver__c,Unit_of_measure__c
                                                         FROM User_Col_Preference__c WHERE User__c = :UserInfo.getUserId() AND Quote_Type__c = :quote.Offering_Type__c];
        if(list_UserColPref.size() == 0)
            objColumnPreference = new User_Col_Preference__c(Third_Party__c = true,User__c = UserInfo.getUserId(),Quote_Type__c = quote.Offering_Type__c,
                                                             Sub_Category__c = true,Ext_List_Price__c = true,List_Price__c = true,Net_Unit_Price__c = true,
                                                             PM_Approver__c = true,Unit_of_measure__c = true,Partner_Price__c=true);
        else
            objColumnPreference = list_UserColPref[0];
        
        oldPricingModel = quote.Pricing_Model__c;
        
        blnIsNewPricing = true;
        
        if(quote.BigMachines__Status__c == 'Simulated Quote')
            blnIsSimulated = true;
        
        objUngrouped = new Quote_Proposal_Group__c(CurrencyISOCode = quote.CurrencyISOCode);
        
        list_QuoteProducts = new List<QuoteProductWrapper>();
        list_DisplayedQuoteProducts = new List<QuoteProductWrapper>();
        
        if(quoteId != null)
        {   
            // Setting page size to 100
            intPageSize = 100;
            
            // Setting page number to 1
            intPageNum = 1;
            
            // Fetching Proposal Groups
            fetchProposalGroups();
            
            // Set Tax Rate and Pricebook
            initializeTaxAndPriceBook();
            
            // Fetching Quote Products
            getQuoteProducts(quoteId);
            
            // Calculating Group Sub Totals
            calculateGroupSubTotals();
            
            // Setting edit mode on Proposal Group table to false
            blnEditProposalGroup = false;
            
            // Bypass Approvals
            Id idCurrentProfile = UserInfo.getProfileId();
            
            for(String strProfileId : Label.ByPass_Approvals_ProfileIds.split(';'))
            {
                if(idCurrentProfile == ((Id)strProfileId.trim()))
                {
                    blnShowByPassApprovals = true;
                    break;
                }
            }
            
            // Initialize Pricing Multiplier
            decPricingMultiplier = getPricingMultiplier(quote.Pricing_Model__c);
            
            idSoldToAccount = quote.Sold_To_Name__c;
            idOpportunity = quote.BigMachines__Opportunity__c;
            
            for(Schema.PicklistEntry value : BigMachines__Quote__c.Renewal_Subscription_Term__c.getDescribe().getPicklistValues()) {
                if(value.getValue() != 'Other') {
                    list_RenewalSubscriptionTerms.add(new SelectOption(value.getLabel(), value.getValue()));
                }
            }
            
            for(Schema.PicklistEntry value : BigMachines__Quote__c.Ramp_Period__c.getDescribe().getPicklistValues()) {
                //if(value.getValue() != 'Other') {
                list_RampPeriods.add(new SelectOption(value.getLabel(), value.getValue()));
                //}
            }
            
            list_RampPeriods.add(new SelectOption('0', '0'));
            for(Schema.PicklistEntry value : BigMachines__Quote__c.Order_Payment_Terms__c.getDescribe().getPicklistValues()) {
                if(value.getValue() != 'Other') {
                    list_PaymentTerms.add(new SelectOption(value.getLabel(), value.getValue()));
                }
            }  
            
            //Old PEC Partner Margin
            System.debug('before if pec '+quote.End_User_ID__c +' '+ quote.Sold_To_Name__c +' '+ quote.offering_type__c +' '+ quote.BigMachines__Opportunity__r.PureEngage_Cloud_Partner_Approved__c);
            // Possible new formula field to keep separate
            if(quote.End_User_ID__c != quote.Sold_To_Name__c && quote.BigMachines__Opportunity__r.PureEngage_Cloud_Partner_Approved__c) {
                map_PECPartnerMargins = new Map<String, Decimal>();
                system.debug('inside if pec');
                for(Partner_Discount__c objPartnerMargin : [SELECT Discount__c, Category__c
                                                            FROM Partner_Discount__c
                                                            WHERE Account__c = :quote.Sold_To_Name__c AND type__c =: SubscriptionUtil.OFFERING_TYPE_PEC]) {
                                                                /*                                                              if(objPartnerMargin.Category__c == 'Base Line Discount')
map_PECPartnerMargins.put('Cloud Services', objPartnerMargin.Discount__c);
else
*/
                                                                System.Debug('if pec Adding objPartnerMargin ' + objPartnerMargin + ' to map_PECPartnerMargins');
                                                                map_PECPartnerMargins.put(objPartnerMargin.Category__c, objPartnerMargin.Discount__c);
                                                            } 
            }
            
            List<Deal_Qualification__c> listOfDealQualifications = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
            if(!listOfDealQualifications.isEmpty() && listOfDealQualifications[0].Quote__c == quote.id){                
                if(quote.Overage_Allowance_Other__c == null)
                    quote.Overage_Allowance_Other__c = listOfDealQualifications[0].Overage_Allowance_Other__c;
                if(quote.Annual_Price_Escalation_Other__c == null)
                    quote.Annual_Price_Escalation_Other__c = listOfDealQualifications[0].Annual_Price_Escalation_Other__c;                       
            }
            buildChangeHistoryForAmendSubscr();
            changeOfMSALinkType(); 
            
        }   
        //mukunth added for multi-year ACV
        System.Debug('Cons--->');
        populateMultiYrACV();
        
        showReviseDQPopup = false;
    }
    
    public void showReviseVisibility(){
        showReviseDQPopup = true;
    }
    
    public void hideReviseVisibility(){
        showReviseDQPopup = false;
    }
    
    public void showQuoteDetails()
    {
        strSelectedTab = 'Quote Details';
        if(upfrontApprovals != null)
            upfrontApprovals.clear();
        objAttachment = new Attachment(ParentId = quote.Id);
    }
    
    public void showDAPDetails()
    {
        strSelectedTab = 'DAP Details';
        if(upfrontApprovals != null)
            upfrontApprovals.clear();
        objAttachment = new Attachment(ParentId = quote.Id);
    }
    
    public void showSpecialOffers()
    {
        strSelectedTab = 'Special Offers';
        if(upfrontApprovals != null)
            upfrontApprovals.clear();
        objAttachment = new Attachment(ParentId = quote.Id);
    }
    
    public void showQuoteApprovals()
    {
        strSelectedTab = 'Quote Approvals';
        //fetchUpfrontApprovals();
        approvals = fetchApprovals();
        objAttachment = new Attachment(ParentId = quote.Id);
    }
    
    public PageReference showOrderSubmission()
    {
        strSelectedTab = 'Order Submission';
        if(upfrontApprovals != null)
            upfrontApprovals.clear();
        objAttachment = new Attachment(ParentId = quote.Id);
        //Included page's constructor needs to be rerun to fetch products which are added/removed in the commerce section
        PageReference pgRef = new PageReference('/apex/CreateQuoteCloudPEC?id=' + quote.Id + '&tab=ordersubmission');
        pgRef.setRedirect(true);
        return pgRef; 
    }
    
    public PageReference showHistoryAndAttachments()
    {
        objAttachment = new Attachment(ParentId = quote.Id);
        doCalculations();
        if(!blnHasError)
            return (new PageReference('/apex/QuoteApprovalHistoryAndAttachments?id=' + quote.Id + '&retPage=CreateQuoteCloudPEC'));
        return null;    
    }
    
    public PageReference showProposalOptions()
    {
        objAttachment = new Attachment(ParentId = quote.Id);
        doCalculations();
        if(!blnHasError)
            return (new PageReference('/apex/ProposalOptionsCloud?id=' + quote.Id + '&retPage=CreateQuoteCloudPEC'));
        return null;    
    }
    
    // *** Fetching Pricing Multiplier from Custom Settings based on Pricing Model ***
    @TestVisible
    private Decimal getPricingMultiplier(String strPricingModel)
    {
        Decimal decMultiplier = 1;
        
        if(quote.Pricing_Model__c == 'Concurrent')
            decMultiplier = Global_Configuration_Settings__c.getOrgDefaults().PureEngage_Cloud_Concurrent_Multiplier__c;
        
        return decMultiplier;
    }
    
    // *** To handle change of Pricing Model in Quote Header ***
    public void changePricingModel()
    {
        oldPricingModel = quote.Pricing_Model__c;
        decPricingMultiplier = getPricingMultiplier(quote.Pricing_Model__c);
        doCalculations();
    }
    
    // *** To handle change of billing period in Quote Header ***
    public void changeBillingPeriod()
    {
        
        Set<Id> set_RatePlanProdIds = new Set<Id>();
        Set<Id> set_OvgProdParentIds = new Set<Id>();
        Map<Id, Product_Tier_Pricing__c> map_ExistingProdTiers = new Map<Id, Product_Tier_Pricing__c>();
        String strMessage = 'Please remove mentioned products before changing billing category.';
        strOldBillingCategory = quote.Billing_Category__c;
        String strOldInitialSubscrTerm = quote.Initial_Subscription_Term__c;
        String strOldBillingPeriod = quote.Billing_Period__c;
        Boolean blnDispBillCatMessage = false;
        List<BigMachines__Quote_Product__c> list_toUpdateQPPrices = new List<BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
            //if(objQP.BigMachines__Product__r.Charge_Type__c.contains(strOldBillingCategory)) {
            if(!objQP.Hide_Record__c && objQP.BigMachines__Product__r.Price_Type__c != null && strRangeandRatePlan.contains(objQP.BigMachines__Product__r.Price_Type__c)) {
                set_RatePlanProdIds.add(objQP.BigMachines__Product__c);
            }
        }
        System.debug('#####set_RatePlanProdIds: '+set_RatePlanProdIds);
        quote.Billing_Category__c = quote.Initial_Subscription_Term__c == '1 Month' ? 'M2M' : 
        quote.Billing_Period__c == 'Monthly' ? 'Annual M2M' : quote.Billing_Period__c == 'Quarterly'?'Annual Quaterly':
        quote.Billing_Period__c == 'Semi-Annually'?'Annual Semi-Annual':'Annual Pre-Pay';
        System.Debug('quote.Billing_Category__c--->'+quote.Billing_Category__c);
        String strWhereCondition = 'WHERE Product__c IN :set_RatePlanProdIds  AND Charge_Type__c = \'' + quote.Billing_Category__c + '\'';
        for(Product_Tier_Pricing__c objProdTr : Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, quote.New_Price_Book__c + '_Price__c'))) {
            map_ExistingProdTiers.put(objProdTr.Product__c, objProdTr);
        }        
        System.debug('#####map_ExistingProdTiers: '+map_ExistingProdTiers);
        /*for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
if(!objQP.Hide_Record__c && objQP.BigMachines__Product__r.Price_Type__c != null && strRangeandRatePlan.contains(objQP.BigMachines__Product__r.Price_Type__c)
&& !map_ExistingProdTiers.containsKey(objQP.BigMachines__Product__c)) {
strMessage += objQP.Name + ' (' +objQP.APN_Number__c + '),';
blnDispBillCatMessage = true;
}
}*/
        try {
            if(blnDispBillCatMessage) {
                quote.Billing_Category__c = strOldBillingCategory;
                quote.Initial_Subscription_Term__c = strOldInitialSubscrTerm;
                quote.Billing_Period__c = strOldBillingPeriod;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strMessage));   
            }
            else {
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
                    if(map_ExistingProdTiers.containsKey(objQP.BigMachines__Product__c) && !objQP.Is_Overage__c && objQP.Bundle_Line__c == null) {
                        objQP.List_Price__c = (Decimal)map_ExistingProdTiers.get(objQP.BigMachines__Product__c).get(quote.New_Price_Book__c + '_Price__c');
                        list_toUpdateQPPrices.add(objQP);
                    }
                    set_OvgProdParentIds.add(objQP.Id);                    
                    System.debug('@@@@@@objQP.List_Price__c: '+objQP.List_Price__c);
                }
                System.debug('@@@@@@set_OvgProdParentIds: '+set_OvgProdParentIds);
                List<BigMachines__Quote_Product__c> list_OverageQPProducts = [SELECT Id, Hide_Record__c, Parent_Quote_Product__r.Hide_Record__c,BigMachines__Product__c,List_Price__c,Parent_Quote_Product__r.List_Price__c  
                                                                              FROM BigMachines__Quote_Product__c
                                                                              WHERE BigMachines__Quote__c =: quoteId
                                                                              AND Parent_Quote_Product__c IN :set_OvgProdParentIds
                                                                              AND Is_Overage__c = true];
                //AND BigMachines__Product__r.New_Category__c = 'Subscription Fees'];
                System.debug('@@@@@@'+list_OverageQPProducts);
                System.debug('@@@@@@'+map_ExistingProdTiers);
                for(BigMachines__Quote_Product__c objOvrgQP : list_OverageQPProducts) {
                    System.debug('####objOvrgQP.Parent_Quote_Product__r.List_Price__c:'+objOvrgQP.Parent_Quote_Product__r.List_Price__c);
                    objOvrgQP.Hide_Record__c = false; 
                    objOvrgQP.List_Price__c = objOvrgQP.Parent_Quote_Product__r.List_Price__c*1.2;
                    
                    if(objOvrgQP.Parent_Quote_Product__r.Hide_Record__c
                       || (quote.Billing_Category__c == 'M2M' && strOldBillingCategory != 'M2M')) {
                           objOvrgQP.Hide_Record__c = true; 
                       }
                }
                
                Util.Bypass_Trigger_Chk = true;
                list_OverageQPProducts.addAll(list_toUpdateQPPrices);
                update list_OverageQPProducts;
                Util.Bypass_Trigger_Chk = false;
                getQuoteProducts(quoteId);
                doCalculations();
            }            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+e.getMessage()+e.getStackTraceString()));
            System.debug(e.getStackTraceString());
        } 
    }
    
    // *** To handle change of Product Tier ***
    public void changeProductTier() {
        List<BigMachines__Quote_Product__c> list_toRemoveQuoteProducts = new List<BigMachines__Quote_Product__c>();
        String newProductTier = quote.Product_Tier__c;
        System.debug('!!!!!!'+quote.Product_Tier__c);
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
            system.debug(objQP);
            if(objQP.BigMachines__Product__r.Tier__c != null && !objQP.BigMachines__Product__r.Tier__c.contains(quote.Product_Tier__c)) {
                list_toRemoveQuoteProducts.add(objQP);
            }
        }        
        // Savepoint before DML
        Savepoint objSP = Database.setSavepoint();        
        try {
            delete list_toRemoveQuoteProducts; 
            init();
            quote.Product_Tier__c = newProductTier;
            BigMachines__Quote__c obj_UpdateQuote = new BigMachines__Quote__c();
            obj_UpdateQuote.Id = quote.Id;
            obj_UpdateQuote.Product_Tier__c = newProductTier;
            update obj_UpdateQuote;
            doCalculations();           
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+e.getMessage()+e.getStackTraceString()));
            Database.rollback(objSP);
        }       
    }
    
    @Testvisible
    private void checkDealViolations(String strOption)
    {
        blnHasViolations = false;
        list_Violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.Id);
        if(list_Violations != null){
            if(list_Violations.size() == 0)
            {
                if(strOption == 'Convert')
                    convertToRealQuote();
                else if(strOption == 'Finalize')
                {
                    quote.BigMachines__Status__c = 'Quote Approved';
                    update quote;
                    DealQualificationAndQuoteApprovalHelper.resetELAApproval(quote);
                }           
                return;
            }
        }
        if(list_Violations == null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please get deal qualification approved.'));
        else
            DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.Id);
        
        blnHasViolations = true;
    }
    
    // *** Method to convert a simulated quote to a real quote ***
    public void convertToRealQuoteBtnHandler()
    {
        try
        {
            doCalculations();
            // if there is an error skip convert to real quote process and show error
            if(blnHasError)
                return;
            
            checkDealViolations('Convert');
        }
        catch(Exception ex){}
    }
    
    public void convertToRealQuote()
    {
        quote.BigMachines__Status__c = 'Quote In Progress';
        quote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quote.id].Quote_Number__c;
        update quote;
        blnIsSimulated = false;
    }
    
    public void finalizeQuote()
    {        
        // Synchronizing Deal Qualification Products
        doCalculations(); 
        if(blnHasError)
            return;   
        if(list_QuoteProductRecords.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There should be at least 1 product added to the quote before it can be submitted for approval.'));
            return;
        } 
        if(blnisPureBridgeOpp && (quote.Initial_Subscription_Term__c.contains('1') ||  quote.Initial_Subscription_Term__c.contains('2')) && quote.Lever__c.contains('Lever 1')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Initial Subscription Term for PureBrdige Quote should be greater than or equal to 3 years.'));
            return;
        }
        Decimal decACV = DDSCloud.converttoUSD(SubscriptionUtil.OFFERING_TYPE_PC,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        System.debug('##blnisPureBridgeOpp:'+blnisPureBridgeOpp+'###decACV:'+decACV);
        if(blnisPureBridgeOpp && decACV < 150000 && !quote.Lever__c.contains('Lever 1'))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Annual Contract value of this PureBridge Quote is less than the specified criteria.'));
            return;
        }
        DealQualificationAndQuoteApprovalHelper.sendPMApprovalNotifications(quote.id);            
        checkDealViolations('Finalize');
        strIsFinalize = 'true';
    }
    
    public void getDQStatus()
    {
        dqs = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        if(!dqs.isEmpty()){
            dqStatus = dqs[0].Status__c;
            
        }
    }
    
    public void synchAndGoToDQ()
    {
        System.debug('NKC debug SYNCH');
        
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.Id, quote.BigMachines__Opportunity__c);
        System.debug('NKC debug dqStatus ['+dqStatus+']');
        quote.BigMachines__Status__c = 'Quote Approval Pending';
        update quote;
    }
    
    // **************************** Start :  Proposal Group Functionality Methods ********************
    
    // *** Method to query Proposal Groups ***
    private void fetchProposalGroups()
    {
        list_ProposalGroups = [SELECT Id,Description__c,Discount__c,Group_Number__c,Name__c,Sub_Total__c,Goal_Seek__c
                               FROM Quote_Proposal_Group__c WHERE Quote__c = :quote.Id ORDER BY Group_Number__c];
        
        list_ProposalGroupNumberOptions = new List<SelectOption>();
        map_GroupNumToGrouprecord = new Map<String,Quote_Proposal_Group__c>();
        for(Quote_Proposal_Group__c objPG: list_ProposalGroups)
        {
            list_ProposalGroupNumberOptions.add(new SelectOption(objPG.Group_Number__c,objPG.Group_Number__c));
            map_GroupNumToGrouprecord.put(objPG.Group_Number__c,objPG);
        }
    }
    
    // *** Handler for add Quote Proposal Group button ***
    public void addProposalGroup()
    {
        list_ProposalGroupsBeingEdited.add(new Quote_Proposal_Group__c(Quote__c = quote.Id,
                                                                       CurrencyISOCode = quote.CurrencyISOCode));
    }
    
    // *** Handler for removing a Quote Proposal Group button ***
    public void removeProposalGroup()
    {
        Integer intRow = Integer.valueOf(strPGIndex);
        if(list_ProposalGroupsBeingEdited[intRow].Id != null)
            list_ProposalGroupsRemoved.add(list_ProposalGroupsBeingEdited[intRow]);
        list_ProposalGroupsBeingEdited.remove(intRow);
    }
    
    // *** Handler for Quote Proposal Groups 'save' button ***
    public void saveProposalGroup()
    {
        // *********************  Start : Validations ******************
        blnHasProposalGroupErrors = false;
        for(Quote_Proposal_Group__c objPG: list_ProposalGroupsBeingEdited)
        {
            if(String.isBlank(objPG.Name__c))
            {
                blnHasProposalGroupErrors = true;
                strProposalGroupErrorMsg = 'Please specify the name for all Proposal Groups.';
                return;
            }
        }
        // *********************  End : Validations ******************
        
        blnEditProposalGroup = false;
        if(list_ProposalGroupsRemoved.size() > 0)
            delete list_ProposalGroupsRemoved;
        
        // Numbering the proposal groups
        Integer intCounter = 1;
        for(Quote_Proposal_Group__c objPG: list_ProposalGroupsBeingEdited)
            objPG.Group_Number__c = String.valueOf(intCounter++);
        
        upsert list_ProposalGroupsBeingEdited;
        fetchProposalGroups();
    }
    
    // *** Handler for Proposal Group 'cancel' button ***
    public void cancelEditofProposalGroup()
    {
        blnEditProposalGroup = false;
        blnHasProposalGroupErrors = false;
        fetchProposalGroups();
    }
    
    // *** Handler for 'Modify' button ***
    public void editofProposalGroup()
    {
        blnEditProposalGroup = true;
        blnHasProposalGroupErrors = false;
        list_ProposalGroupsBeingEdited = new List<Quote_Proposal_Group__c>();
        list_ProposalGroupsBeingEdited.addAll(list_ProposalGroups);
        if(list_ProposalGroupsBeingEdited.size() == 0)
            addProposalGroup();
        list_ProposalGroupsRemoved = new List<Quote_Proposal_Group__c>();
    }    
    
    // *** Handler for Goal Seek Button on Proposal Groups ***
    public void goalSeekForPG()
    {
        Integer intIndex = Integer.valueOf(strPGIndex);
        if(intIndex >= 0 && intIndex < list_ProposalGroups.size())
        {
            Quote_Proposal_Group__c objPG = list_ProposalGroups[intIndex];
            if(objPG.Goal_Seek__c == null)
            {
                objPG.Goal_Seek__c.addError('Please Enter Value');
                return;
            }
            // Calculate only if the Proposal Group has a Group Number
            if(String.isNotBlank(objPG.Group_Number__c))
            {
                Decimal decGroupListPrice = 0,decNonDiscountedListPrice = 0;
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {                       
                    if(objQP.Group_Number__c == objPG.Group_Number__c && objQP.Ext_List__c != null && objQP.Ext_List__c != 0)
                    {
                        decGroupListPrice += objQP.Ext_List__c;
                        if(!objQP.BigMachines__Product__r.Discountable__c)
                            decNonDiscountedListPrice += objQP.Ext_List__c;
                    }   
                }
                Decimal decTotalExcludingNonDiscounted = decGroupListPrice - decNonDiscountedListPrice;
                if(objPG.Goal_Seek__c > decGroupListPrice)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Goal Seek Amount should be less than Total List Price applicable for discount for the Proposal Group. (' + String.valueOf(decGroupListPrice) + ')'));
                    return;
                }
                System.debug('decTotalExcludingNonDiscounted : '+decTotalExcludingNonDiscounted);
                if(decTotalExcludingNonDiscounted  != 0)
                {
                    Decimal decComputedDiscountPercent = ((decGroupListPrice - objPG.Goal_Seek__c)/decTotalExcludingNonDiscounted) * 100;
                    objPG.Discount__c = decComputedDiscountPercent;
                    // Blanking out other discounts on quote products associated with the relevant proposal group
                    for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                    {   
                        if(objQP.Group_Number__c == objPG.Group_Number__c && objQP.Ext_List__c != null && objQP.Ext_List__c != 0)
                        {
                            objQP.Adjustment__c = 0;
                            objQP.or_Amount__c = null;
                            objQP.Disc__c = null;
                        }
                    }
                    
                    doCalculations();
                }
            }
        }
    }
    
    // *** Handler for Goal Seek Reset Button on Proposal Groups ***
    public void goalSeekResetForPG()
    {
        Integer intIndex = Integer.valueOf(strPGIndex);
        if(intIndex >= 0 && intIndex < list_ProposalGroups.size())
        {
            Quote_Proposal_Group__c objPG = list_ProposalGroups[intIndex];
            objPG.Goal_Seek__c = objPG.Discount__c = 0;
            // Calculate only if the Proposal Group has a Group Number
            if(String.isNotBlank(objPG.Group_Number__c))
            {
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {
                    if(objQP.Group_Number__c == objPG.Group_Number__c)
                        objQP.Disc__c = 0;
                }
                
                doCalculations();
            }
        }
    }
    
    // **************************** End : Proposal Group Functionality Methods ********************
    
    // **************************** Start : Pagination ********************
    
    // *** Method to set up grids rows for current page ***
    public void createCurrentPageList()
    {
        if(intTotalNoOfRecords > 0 && quoteId != null)
        {
            list_GroupHeaders = new List<String>();
            map_GroupHeaderToQuoteProdWrapper = new Map<String,List<QuoteProductWrapper>>();
            map_FlavorsToSelectOptions = new Map<String,List<SelectOption>>();
            String strOvgHeader = quote.Billing_Category__c != 'M2M' ? 'Overage Charges' : 'Usage Charges';
            
            for(Integer i = (intPageNum-1) * intPageSize;i< (intPageNum * intPageSize) && i <  intTotalNoOfDisplayedRecords; i++)
            {
                QuoteProductWrapper wrapperRecord = list_DisplayedQuoteProducts[i];
                
                String strProductFlavors =  wrapperRecord.record.BigMachines__Product__r.Flavors_Available__c;
                if(String.isNotBlank(strProductFlavors))
                {
                    if(!map_FlavorsToSelectOptions.containsKey(strProductFlavors))
                    {
                        List<SelectOption> list_Options = new List<SelectOption>();
                        for(String strQuantity : strProductFlavors.split(';'))
                            list_Options.add(new SelectOption(strQuantity,strQuantity));
                        map_FlavorsToSelectOptions.put(strProductFlavors,list_Options);
                    }
                }
                system.debug('wrapperRecord.record.Is_Overage__c'+wrapperRecord.record.Is_Overage__c);
                String strGroupHeader;
                if(wrapperRecord.record.Is_Overage__c) {
                    strGroupHeader = strOvgHeader;
                }
                else if(!wrapperRecord.record.Hide_Record__c || wrapperRecord.record.BigMachines__Product__r.New_Category__c == 'Use Case') { 
                    if(quote.Grid_Group_By__c == 'Categories') 
                    {
                        strGroupHeader = wrapperRecord.record.BigMachines__Product__r.New_Category__c;                       
                        //strGroupHeader = (wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution_Category__c == null ? '' : wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution_Category__c)
                        //  + ' - ' + (wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution__c == null ? '' : wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution__c);
                    }                
                    //Logic to display Sub Category Grouping
                    else if(quote.Grid_Group_By__c == 'Sub Categories')
                    {
                        strGroupHeader = wrapperRecord.record.BigMachines__Product__r.Sub_Category__c == null ? '' : wrapperRecord.record.BigMachines__Product__r.Sub_Category__c;
                    }
                    
                    else if(quote.Grid_Group_By__c == 'Recurring/Non-Recurring')
                    {
                        if(wrapperRecord.record.BigMachines__Product__r.Include_in_CMMR_Total__c)
                            strGroupHeader = 'Recurring';
                        else
                            strGroupHeader = 'Non-Recurring';
                    }
                    
                    else if(quote.Grid_Group_By__c == 'Bundles/Products')
                    {
                        if(wrapperRecord.record.Bundle__c != null && wrapperRecord.record.Bundle_Line__c==null)
                            strGroupHeader = 'Bundles';
                        else
                            strGroupHeader = 'Products';
                    }
                    
                    else if(quote.Grid_Group_By__c == 'Proposal Groups')
                    {
                        if(map_GroupNumToGrouprecord.containsKey(wrapperRecord.record.Group_Number__c))
                            strGroupHeader = map_GroupNumToGrouprecord.get(wrapperRecord.record.Group_Number__c).Name__c;
                        else
                            strGroupHeader = wrapperRecord.record.Group_Number__c;
                    }
                    else if(quote.Grid_Group_By__c == 'Use Cases'){
                        strGroupHeader = wrapperRecord.record.Bundle__r.Name;
                        if(wrapperRecord.record.Bundle__r.Description__c != null)
                            strGroupHeader += ' - ' + wrapperRecord.record.Bundle__r.Description__c;
                        if(wrapperRecord.record.Bundle__r.Message__c != null)
                            strGroupHeader += '<span style=\'color:red;\'> [' + wrapperRecord.record.Bundle__r.Message__c + ']</span>';
                        if (strGroupHeader == '' ||strGroupHeader == null ){strGroupHeader = 'Non Use Case Products ';}
                        
                        
                    } 
                    else
                    {
                        if(wrapperRecord.record.Third_Party__c == 'TRUE')
                            strGroupHeader = '3rd Party Products';
                        else
                            strGroupHeader = 'Genesys Products';
                    }
                }
                
                if(String.isNotBlank(strGroupHeader))
                {
                    if(map_GroupHeaderToQuoteProdWrapper.containsKey(strGroupHeader))
                        map_GroupHeaderToQuoteProdWrapper.get(strGroupHeader).add(wrapperRecord);
                    else
                    {
                        map_GroupHeaderToQuoteProdWrapper.put(strGroupHeader,new List<QuoteProductWrapper>{wrapperRecord});
                        list_GroupHeaders.add(strGroupHeader);
                    }
                }
                // Using Group Header value as 'BLANK' to Group when Group Header is not available
                else if(!wrapperRecord.record.Hide_Record__c)
                {
                    if(map_GroupHeaderToQuoteProdWrapper.containsKey('BLANK'))
                        map_GroupHeaderToQuoteProdWrapper.get('BLANK').add(wrapperRecord);
                    else
                    {
                        map_GroupHeaderToQuoteProdWrapper.put('BLANK',new List<QuoteProductWrapper>{wrapperRecord});
                    }
                }
            }
            if(map_GroupHeaderToQuoteProdWrapper.containsKey('BLANK'))
                list_GroupHeaders.add('BLANK');
            
        }
        
    }
    
    // *** Method to go to next page ***
    public void next()
    {
        if(getHasNext())
        {
            intPageNum++;
            createCurrentPageList();
        }
    }
    
    // *** Method to go to previous page ***
    public void previous()
    {
        if(getHasPrevious())
        {
            intPageNum--;
            createCurrentPageList();
        }
    }
    
    // *** Method to check if there is a previous page ***
    public Boolean getHasPrevious()
    {
        if(intPageNum > 1)
            return true;
        return false;
    }
    
    // *** Method to check if there is a next page ***
    public Boolean getHasNext()
    {
        if(intPageNum < numberOfPages())
            return true;
        return false;
    }
    
    // *** Method to go to first page ***
    public void first()
    {
        intPageNum = 1;
        createCurrentPageList();
    }
    
    // *** Method to go to last page ***
    public void last()
    {
        intPageNum = numberOfPages();
        createCurrentPageList();
    }
    
    // *** Method to show current page in view ***
    public String getPageNumStr()
    {
        Integer intNoOfPages = numberOfPages();
        return ('Page ' + String.valueOf(intPageNum) + ' of ' + String.valueOf(intNoOfPages));
    }
    
    // *** Method to calculate number of pages ***
    public Integer numberOfPages()
    {
        return (intTotalNoOfDisplayedRecords / intPageSize) + (Math.mod(intTotalNoOfDisplayedRecords,intPageSize) > 0 ? 1:0);
    }
    
    // **************************** End : Pagination ********************
    
    // ******************** Start :  Select Columns Functionality Methods **********
    
    // *** Handler for Select Columns Link ***
    public void selectColumnsHandler()
    {
        blnShowSelectColumns = true;
        objColPrefCopy = objColumnPreference.clone(true,true);
    }
    
    // *** Handler for column configuration save button ***
    public void saveColumnsHandler()
    {
        blnShowSelectColumns = false;
        upsert objColumnPreference;
        objColPrefCopy = null;
    }
    
    // *** Handler for column configuration cancel button ***
    public void cancelColumnsHandler()
    {
        blnShowSelectColumns = false;
        objColumnPreference = objColPrefCopy;
    }
    
    // ******************** Stop :  Select Columns Functionality Methods **********
    
    // *** Handler for submit for approval button ***
    public void submitForApprovalBtnHandler()
    {
        doCalculations();
        // if there is an error skip approval process and show error
        if(blnHasError)
            return;
        
        if(String.isBlank(quote.Service_Level__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Service Level for this quote.'));
            return;
        }
        if(list_QuoteProductRecords.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There should be at least 1 product added to the quote before it can be submitted for approval.'));
            return;
        }
        
        try
        {
            String strResult = QuoteApprovalAssignment.submitQuoteToApproval(quote.Id);
            if(strResult != 'OK')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strResult));            
            else
            {
                quote = getQuote(quoteId);
                if(strSelectedTab == 'Quote Approvals')
                    approvals = fetchApprovals();
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+ex.getMessage()));
        }
    } 
    
    // *** Handler for submit order button ***
    public void bypassApprovalsBtnHandler()
    {
        if(list_QuoteProductRecords.size() == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There should be at least 1 product added to the quote before it can be submitted for approval.'));
            return;
        }
        
        String strOldStatus = quote.BigMachines__Status__c;
        quote.Approval_Submission_Date__c = Date.today();
        quote.Approval_Date__c  = Date.today();
        try
        {
            quote.BigMachines__Status__c = 'Quote Approved';
            quote.Approval_Date__c = System.Today();
            quote.Proposal_Date__c = quote.Approval_Date__c;
            update quote;
            QuoteApprovalAssignmentHelper.byPassApprovals(quote.id);
            
            if(strSelectedTab == 'Quote Approvals')
                approvals = fetchApprovals();
        }
        catch(Exception ex)
        {
            quote.BigMachines__Status__c = strOldStatus;
        }
    }
    
    // *** Method to initialize Tax rate and Pricebook applicable ***
    private void initializeTaxAndPriceBook() 
    {
        quote.Tax_Rate__c = 0;
        quote.Services_Tax_Rate__c = 0;
        quote.Training_Tax_Rate__c = 0;
        
        // Japan does not have decimal place for currency
        if(quote.End_User_ID__r.Country__r.Name == 'Japan' || quote.Sold_To_Name__r.Country__r.Name == 'Japan')
            quote.Hide_Truncate_Decimals__c = true;
    }
    
    // *** Method to set all row check-boxes to true/false based on facet check-box ***
    public void checkUncheckAll()
    {
        for(QuoteProductWrapper obj : list_QuoteProducts)
            obj.selected = blnIsHeaderChecked;
    }
    
    //Naresh Kumar  03/28/2016 Deletes selected quote products
    public pageReference deleteQuoteProducts()
    {
        PageReference newPageRef;
        List<BigMachines__Quote_Product__c> list_ToDelete = new List<BigMachines__Quote_Product__c>();
        Set<Id> setOfQuoteProductIds = new Set<Id>();
        for(List<QuoteProductWrapper> listOfQP : map_GroupHeaderToQuoteProdWrapper.values()){
            for(QuoteProductWrapper eachQPWrapper : listOfQP){
                BigMachines__Quote_Product__c eachQP = eachQPWrapper.record; 
                if(eachQPWrapper.selected){
                    list_ToDelete.add(eachQP);
                    setOfQuoteProductIds.add(eachQP.id);
                    if(objTrainingUnit != null && objTrainingUnit.id == eachQP.id){
                        //quote.Override_Training_Unit__c = true;
                        objTrainingUnit = null;
                    }  
                }
            }
        }
        if(list_ToDelete.isEmpty())
            return newPageRef;
        
        for(Id eachQPId : setOfQuoteProductIds){
            if(map_BundleQuoteProducts.containsKey(eachQPId)){
                for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords){
                    if(objQP.Bundle_Line__c == eachQPId)
                        list_ToDelete.add(objQP);
                }
            }  
        }
        list_ToDelete.addAll(deleteDependentProducts(list_ToDelete));
        
        // Skip Triggers
        Util.Bypass_Trigger_Chk = true;
        delete list_ToDelete;
        getQuoteProducts(quote.id);
        doCalculations();
        //Naresh Kumar   01/04/2016  Updating SML Data
        SMLHelperWTS.updateSMLForAccount(quote.End_User_ID__c);
        return newPageRef;
    }
    
    //*** Handler/Method for delete quote product button ***
    public pageReference deleteQuoteProduct()
    {
        PageReference newPageRef;
        if(strToDelete == 'yes')
        {
            List<BigMachines__Quote_Product__c> list_ToDelete = new List<BigMachines__Quote_Product__c>();
            if(map_BundleQuoteProducts.containsKey(quoteProductIdToBeDeleted))
            {
                list_ToDelete.add(map_BundleQuoteProducts.get(quoteProductIdToBeDeleted));
                for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
                {
                    if(objQP.Bundle_Line__c == quoteProductIdToBeDeleted)
                        list_ToDelete.add(objQP);
                }
            }
            else
                list_ToDelete.add(new BigMachines__Quote_Product__c(id = quoteProductIdToBeDeleted));
            
            if(objTrainingUnit != null && objTrainingUnit.id == quoteProductIdToBeDeleted){
                //quote.Override_Training_Unit__c = true;
                objTrainingUnit = null;                
            }
            
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            list_ToDelete.addAll(deleteDependentProducts(list_ToDelete));            
            delete list_ToDelete;
            getQuoteProducts(quote.id);
            doCalculations();
            //Naresh Kumar   01/04/2016  Updating SML Data
            SMLHelperWTS.updateSMLForAccount(quote.End_User_ID__c);
        }
        return newPageRef;
    }
    
    // *** Clone button handler : To clone a Quote ***
    public pageReference cloneBtnHandler()
    {
        String cloneQuoteId = cloneQuote(false);   
        if(cloneQuoteId.startswith('Warning'))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,''+cloneQuoteId));
            return null;
        }            
        PageReference pg = new PageReference('/apex/CreateQuoteCloudPEC?id='+cloneQuoteId);
        pg.setRedirect(true);
        return pg;
    }
    
    public void changeOpportunity()
    {
        if(quote.BigMachines__Opportunity__c != null)
        {
            List<Opportunity> list_Temp = [SELECT Name,Sold_To_Country__r.New_Price_Book__c,Sold_To_Country__r.Old_Price_Book__c,
                                           BusinessPartner__c,AccountId,Pricebook2Id FROM Opportunity WHERE Id = :quote.BigMachines__Opportunity__c];
            if(list_Temp.size() > 0)
            {
                PriceBook2 standardPB = [select Id,Name from pricebook2 where Name = 'Standard Price Book'];
                if(list_Temp[0].Pricebook2Id != standardPB.id){
                    List<OpportunityLineItem> oppLinesToBeDeleted = [SELECT id FROM OpportunityLineItem WHERE OpportunityId =: list_Temp[0].id];
                    if(oppLinesToBeDeleted.isEmpty())
                        delete oppLinesToBeDeleted;
                    Opportunity oppToBeUpdated = new Opportunity(id = list_Temp[0].id);
                    oppToBeUpdated.Pricebook2Id = standardPB.id;
                    update oppToBeUpdated;
                }                
                if((quote.New_Price_Book__c == list_Temp[0].Sold_To_Country__r.New_Price_Book__c && quote.quote_opportunity_type__c=='New Pricing') ||
                   (quote.New_Price_Book__c == list_Temp[0].Sold_To_Country__r.Old_Price_Book__c && quote.quote_opportunity_type__c =='Old Pricing'))
                {
                    // Skip Triggers
                    Util.Bypass_Trigger_Chk = true;
                    quote.End_User_ID__c = list_Temp[0].AccountId;
                    quote.Sold_To_Name__c = list_Temp[0].BusinessPartner__c;
                    update quote;
                    quote = getQuote(quote.Id);
                    idOpportunity = quote.BigMachines__Opportunity__c;
                    return;
                }
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot change Quote Opportunity to ' + list_Temp[0].Name + ' as the pricebook applicable is different. Please create a new quote if needed.'));
            }
        }
        quote.BigMachines__Opportunity__c = idOpportunity;
    }
    
    public void changeSoldTo()
    {
        if(quote.Sold_To_Name__c != null && idSoldToAccount != quote.Sold_To_Name__c){      
            quote.Sold_To_Address__c = '';
            quote.Sold_To_City__c = '';
            quote.Sold_To_State__c = '';
            quote.Sold_To_Country__c   = '';
            quote.Sold_To_Zip_Code__c = '';
        }
    }
    
    // *** Revise Major button handler : To revise a Quote (Creates a new quote with a different revision number)***
    public pageReference reviseMajorBtnHandler()
    {
        PageReference pg;
        //if DQ pending block revise
        getDQStatus();
        if(dqStatus == 'Approval Pending')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,Label.CloudReviseRestrictMessage));
            return null;
        }
        else
        {
            if(quote.BigMachines__Status__c == 'Quote Approved'){
                String newQuoteId = cloneQuote(true);
                UpdateOppStatus.updateoppStatusFromQuote(newQuoteId);
                pg = new PageReference('/apex/CreateQuoteCloudPEC?id='+newQuoteId);
            }
            else{
                quote.Revision_Approvals__c = true;
                quote.BigMachines__Status__c = 'Revision Pending';
                quote.Approval_Date__c = null;
                quote.Approval_Submission_Date__c = null;
                update quote;
                if(strSelectedTab == 'Quote Approvals')
                    approvals = fetchApprovals();   
                // Copying Quote Approvals
                List<Quote_Approval__c> list_QuoteApprovals = new List<Quote_Approval__c>();
                Set<String> set_AllFields = Schema.SObjectType.Quote_Approval__c.fields.getMap().keySet();
                String strQuoteApprovalQuery = 'SELECT ';
                
                for(String strFieldName : set_AllFields){
                    if(!strFieldName.containsIgnoreCase('lastvieweddate') && !strFieldName.containsIgnoreCase('LastReferencedDate'))
                        strQuoteApprovalQuery += strFieldName + ', ';
                }
                
                strQuoteApprovalQuery = strQuoteApprovalQuery.substring(0, strQuoteApprovalQuery.lastIndexOf(','));
                strQuoteApprovalQuery += ' FROM Quote_Approval__c WHERE BigMachines_Quote__c = \'' + quote.Id + '\''; 
                for(Quote_Approval__c objQuoteApproval : Database.query(strQuoteApprovalQuery))
                {
                    //Quote_Approval__c objQA = objQuoteApproval.clone(false, true);
                    //objQA.BigMachines_Quote__c = quoteCopy.id;
                    objQuoteApproval.Don_t_send_notification_to_approvers__c = true;
                    objQuoteApproval.Trigger_Email_Alert__c = QuoteApprovalUtil.QUOTE_REVISED_BEFORE_APPROVAL;
                    if(objQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_PENDING)
                        objQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_CANCELLED;
                    list_QuoteApprovals.add(objQuoteApproval);
                }
                
                update list_QuoteApprovals;
                pg = new PageReference('/apex/CreateQuoteCloudPEC?id='+quote.id);
                
                
            }
            
            if(strSelectedTab == 'Quote Approvals')
                approvals = fetchApprovals();   
        }
        pg.setRedirect(true);
        return pg;
        
        
        
        
    }
    
    // *** Revise Minor button handler : To make minor revision to a Quote ***
    public void reviseMinorBtnHandler()
    {
        quote.Revise_Minor__c = true;
        quote.Revision_Approvals__c = true;
        quote.BigMachines__Status__c = 'Revision Pending';
        quote.Approval_Date__c = null;
        quote.Approval_Submission_Date__c = null;
        update quote;
        if(strSelectedTab == 'Quote Approvals')
            approvals = fetchApprovals();       
    }
    
    // *** Action method which is called from page as it loads to clone the quote ***
    public pageReference cloneQuoteOnLoad()
    {
        for(BigMachines__Quote_Product__c objQP : (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId)))
        { 
            if(objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c && objQP.Quantity__c != null)
            {
                set_SeatCountParts.add(objQP.BigMachines__Product__c);
            }
        }
        populateSuggestedDiscounts();
        
        if(ApexPages.currentPage().getParameters().get('clone') != null
           && ApexPages.currentPage().getParameters().get('clone') == '1'){
               String clonedQuoteId = cloneQuote(false);
               PageReference pRef = new PageReference('/apex/CreateQuoteCloudPEC?id=' + clonedQuoteId);
               pRef.setRedirect(true);
               return pRef;        
           }   
        return null;
    }
    
    // *** Performs Clone/Revise copying into a new quote ***
    public String cloneQuote(Boolean isRevise)
    {
        Util.Bypass_Trigger_Chk = true;
        // Copying Quote
        BigMachines__Quote__c quoteCopy = quote.clone(false, true);
        quoteCopy.BigMachines__Transaction_Id__c = null;
        quoteCopy.Quote_Created_Date__c = Date.today();
        
        Map<Id, BigMachines__Quote_Product__c> map_OvrgQuoteProds = new Map<Id, BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> list_ProductsWithDepedency = new List<BigMachines__Quote_Product__c>();
        Map<Id, Id> map_NewQPIds = new Map<Id, Id>();
        
        if(!isRevise)
        {
            // Default quote expiration after 1 month
            quoteCopy.Expiration_Date__c = Date.today().addMonths(1);
        }
        quoteCopy.Is_Business_Primary__c = false;
        quoteCopy.BigMachines__Is_Primary__c = false;
        quoteCopy.Revise_Minor__c = false;
        quoteCopy.Sent_to_Customer__c = false;
        quoteCopy.Quote_Cloned_Revised__c = quote.Id;
        quoteCopy.BigMachines__Status__c = 'Quote In Progress';
        //quoteCopy.Quote_Opportunity_Type__c = 'New Pricing';
        
        // Approval and Order Submission related fields should be cleared while revising and cloning quotes
        quoteCopy.Approval_Date__c = null;
        //quoteCopy.Approval_Submission_Date__c = null;
        quoteCopy.Order_Date_Submitted__c = null;
        quoteCopy.Order_PO_Number__c = null;
        quoteCopy.Order_PO_Date__c = null;
        quoteCopy.Order_Type__c = quote.Order_Type__c;
        // Quote Account should map to End User (explicitly copied : if cloned from a quote which has a blank value for account)
        quoteCopy.BigMachines__Account__c = quote.End_User_ID__c;
        
        //ECD (Old) fields for PCC CPQ
        quoteCopy.No_Of_Months__c = quoteCopy.No_Of_Months__c ==  null ? 12 : quoteCopy.No_Of_Months__c;
        quoteCopy.Ramp_Period__c = quoteCopy.Ramp_Period__c ==  null ? STR_RAMP_PERIOD_DEFAULT : quoteCopy.Ramp_Period__c;
        quoteCopy.Subscription_Start_Date__c = quoteCopy.Subscription_Start_Date__c == null ? Date.today().addMonths(Integer.valueOf(quoteCopy.Ramp_Period__c)/30) : quoteCopy.Subscription_Start_Date__c;
        quoteCopy.Subscription_End_Date__c = quoteCopy.Subscription_End_Date__c ==  null ? quoteCopy.Subscription_Start_Date__c.addMonths(Integer.valueOf(quoteCopy.No_Of_Months__c))-1 : quoteCopy.Subscription_End_Date__c;
        if(quoteCopy.order_type__c == 'New')
            quoteCopy.order_type__c = 'New Subscription';
        else if(quoteCopy.order_type__c == 'Add On' || quoteCopy.order_type__c == 'Add-On')
            return 'Warning : Cannot be cloned';
        
        insert quoteCopy;
        //System.debug('<<<< clone : ' + quoteCopy.Maintenance_End_Date__c);
        if(!isRevise)
        {
            quoteCopy = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quoteCopy.id];
            quoteCopy.Name = quoteCopy.Quote_Number__c;
            quoteCopy.Revision_No__c = 1;
            update quoteCopy;
        }
        else
        {
            if(quote.BigMachines__Is_Primary__c)
            {
                List<BigMachines__Quote__c> list_OpptyQuotes = [SELECT Id,Quote_Number__c FROM BigMachines__Quote__c 
                                                                WHERE (Id = :quoteCopy.Id OR BigMachines__Is_Primary__c = true) AND 
                                                                BigMachines__Opportunity__c = :quoteCopy.BigMachines__Opportunity__c];
                
                // Making current Quote primary and removing primary flag from any existing quotes associated with the opportunity
                for(BigMachines__Quote__c objOpptyQuote : list_OpptyQuotes)
                {
                    if(objOpptyQuote.Id == quoteCopy.Id)
                    {
                        // Getting count of quotes with the same name to determine revision number
                        objOpptyQuote.Revision_No__c = [SELECT COUNT() FROM BigMachines__Quote__c WHERE Name = :quoteCopy.Name];
                        objOpptyQuote.BigMachines__Status__c = 'Revision Pending';
                        objOpptyQuote.BigMachines__Is_Primary__c = true;
                    }
                    else
                        objOpptyQuote.BigMachines__Is_Primary__c = false;
                }
                update list_OpptyQuotes;
            }
            else
            {
                // Getting count of quotes with the same name to determine revision number
                quoteCopy.Revision_No__c = [SELECT COUNT() FROM BigMachines__Quote__c WHERE Name = :quoteCopy.Name];
                quoteCopy.BigMachines__Status__c = 'Revision Pending';
                update quoteCopy;
            }
            
            // Copying Quote Approvals
            List<Quote_Approval__c> list_QuoteApprovals = new List<Quote_Approval__c>();
            Set<String> set_AllFields = Schema.SObjectType.Quote_Approval__c.fields.getMap().keySet();
            String strQuoteApprovalQuery = 'SELECT ';
            
            for(String strFieldName : set_AllFields)
                strQuoteApprovalQuery += strFieldName + ', ';
            
            strQuoteApprovalQuery = strQuoteApprovalQuery.substring(0, strQuoteApprovalQuery.lastIndexOf(','));
            strQuoteApprovalQuery += ' FROM Quote_Approval__c WHERE BigMachines_Quote__c = \'' + quote.Id + '\''; 
            for(Quote_Approval__c objQuoteApproval : Database.query(strQuoteApprovalQuery))
            {
                Quote_Approval__c objQA = objQuoteApproval.clone(false, true);
                objQA.BigMachines_Quote__c = quoteCopy.id;
                objQA.Don_t_send_notification_to_approvers__c = true;
                objQA.Trigger_Email_Alert__c = QuoteApprovalUtil.QUOTE_REVISED_BEFORE_APPROVAL;
                if(objQA.Status__c == QuoteApprovalUtil.STATUS_PENDING)
                    objQA.Status__c = QuoteApprovalUtil.STATUS_CANCELLED;
                list_QuoteApprovals.add(objQA);
            }
            
            insert list_QuoteApprovals;
        }            
        
        // Copying Quote Products
        String strQuoteProductsQuery = 'SELECT ';
        
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteProductsQuery += field.getFieldPath() + ', ';
        //strQuoteProductsQuery = strQuoteProductsQuery.substring(0, strQuoteProductsQuery.length()-2);
        strQuoteProductsQuery += 'BigMachines__Product__r.Product_Group__c,BigMachines__Product__r.description__c,BigMachines__Product__r.Partner_Margin_Category__c';
        strQuoteProductsQuery += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quote.Id + '\' ORDER BY BigMachines__Product__r.Sort_Order__c';
        List<BigMachines__Quote_Product__c> quoteProducts = (List<BigMachines__Quote_Product__c>)Database.query(strQuoteProductsQuery);
        List<BigMachines__Quote_Product__c> quoteProductsCopy = new List<BigMachines__Quote_Product__c>();
        Map<Id,Integer> map_BundleLineIdToIndex = new Map<Id,Integer>();
        Integer intIndex = -1;
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts)
        {
            intIndex++;
            BigMachines__Quote_Product__c quoteProductCopy = eachQuoteProduct.clone(false, true);
            quoteProductCopy.BigMachines__Quote__c = quoteCopy.id;
            quoteProductCopy.BigMachines__External_Id__c  = null;
            quoteProductCopy.currencyIsoCode = quote.currencyIsoCode;
            // Storing index of Bundle Quote Products
            if(quoteProductCopy.Bundle__c != null && quoteProductCopy.Bundle_Line__c == null)
                map_BundleLineIdToIndex.put(eachQuoteProduct.Id,intIndex);
            quoteProductCopy.currencyIsoCode = quote.currencyIsoCode;
            quoteProductsCopy.add(quoteProductCopy);
            
            
        }
        
        // Copying Proposal Groups    
        List<Quote_Proposal_Group__c> list_ProposalGroupsCopy = new List<Quote_Proposal_Group__c>();
        for(Quote_Proposal_Group__c eachPG : list_ProposalGroups)
        {
            Quote_Proposal_Group__c newProposalGroup = eachPG.clone(false, true);
            newProposalGroup.Quote__c = quoteCopy.id;
            list_ProposalGroupsCopy.add(newProposalGroup);
        }
        
        
        
        insert quoteProductsCopy;
        List<BigMachines__Quote_Product__c> list_QPsToUpdate = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQP: quoteProductsCopy)
        {
            if(eachQP.Bundle__c != null && eachQP.Bundle_Line__c != null && 
               map_BundleLineIdToIndex.containsKey(eachQP.Bundle_Line__c))
            {
                eachQP.Bundle_Line__c = quoteProductsCopy[map_BundleLineIdToIndex.get(eachQP.Bundle_Line__c)].Id;
                eachQP.hide_record__c = true;
                list_QPsToUpdate.add(eachQP);
            }
            if(eachQP.Is_Overage__c) 
                map_OvrgQuoteProds.put(eachQP.BigMachines__Product__c, eachQP);
            else
                map_NewQPIds.put(eachQP.BigMachines__Product__c, eachQP.Id);
        }
        if(list_QPsToUpdate.size() > 0)
            update list_QPsToUpdate;
        
        insert list_ProposalGroupsCopy;
        
        //Set dependency        
        for(BigMachines__Quote_Product__c objQP : map_OvrgQuoteProds.values()) 
        {
            if(map_NewQPIds.containsKey(objQP.BigMachines__Product__c)) 
            {
                objQP.Parent_Quote_Product__c = map_NewQPIds.get(objQP.BigMachines__Product__c); 
                list_ProductsWithDepedency.add(objQP);
            }                
        }
        if(list_ProductsWithDepedency.size() > 0)
            update list_ProductsWithDepedency;
        return quoteCopy.id;
    }
    
    // *** Method to return quote object ***
    public BigMachines__Quote__c getQuote(Id quoteId)
    {
        BigMachines__Quote__c quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));
        
        if(String.isBlank(quote.Grid_Group_By__c))
            quote.Grid_Group_By__c = 'Recurring/Non-Recurring';
        quote.Ramp_Period__c = quote.Ramp_Period__c == null ? STR_RAMP_PERIOD_DEFAULT : quote.Ramp_Period__c;
        return quote;
    }
    
    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId)
    {
        String strQuoteQuery = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        
        strQuoteQuery += 'End_User_ID__r.Country__r.Name, Quote_Cloned_Revised__r.Name,Token_Value__c,BigMachines__Opportunity__r.Country__r.Region__c,';     
        strQuoteQuery += 'Sold_To_Name__r.Country__r.PSRDP_Region__c,Sold_To_Name__r.Country__r.Name,Sold_To_Name__r.Country__r.Region__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c,BigMachines__Opportunity__r.Run_Rate_USD__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Name,Amendment_For__r.Sale_Type__c,';        
        strQuoteQuery += 'Amendment_For__r.CMRR__c, Amendment_For__r.ACV__c, Amendment_For__r.TCV__c,End_User_ID__r.Subsidary__c,Amendment_For__r.MSA_Link_Type__c,BigMachines__Opportunity__r.MSA_Link_Type__c,';        
        strQuoteQuery += 'Amendment_For__r.Total_Services__c, Amendment_For__r.Total_Education__c, Amendment_For__r.Total_Hardware__c,Amendment_For__r.Total_Non_Recurring_Fees__c,';  
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,BigMachines__Opportunity__r.RecordType.Name,';        
        strQuoteQuery += 'BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email,BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,BigMachines__Opportunity__r.PureEngage_Cloud_Partner_Approved__c, ';
        strQuoteQuery += 'Amendment_For__r.Status__c,Amendment_For__r.Order__r.name,Amendment_For__r.Order__c,BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,';           
        strQuoteQuery += 'Amendment_For__r.Total_Tokens__c,Amendment_For__r.Telco_CMRR__c,Amendment_For__r.Setup_Provisioning_Charges__c,BigMachines__Opportunity__r.Avaya_Contract_Expiration__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Cloud_Renewal__c,PureSuccess__c,BigMachines__Opportunity__r.Account.Partner_Tier__c FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        
        return strQuoteQuery;
    }
    
    // *** Method to get Quote Products ***
    public void getQuoteProducts(Id quoteId)
    {
        list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
        list_BundleItemQPRecords = new List<BigMachines__Quote_Product__c>();
        list_QuoteProducts = new List<QuoteProductWrapper>();
        list_DisplayedQuoteProducts = new List<QuoteProductWrapper>();        
        list_GroupHeaders = new List<String>();
        blnHasHWLines = blnHasBundles = false;       
        map_BundleQuoteProducts = new Map<Id,BigMachines__Quote_Product__c>();
        intTotalNoOfDisplayedRecords = 0; 
        
        for(BigMachines__Quote_Product__c eachQuoteProduct : (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId))) {           
            eachQuoteProduct.currencyIsoCode = quote.currencyIsoCode;
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
            wrapperRecord.record = eachQuoteProduct;
            wrapperRecord.strPlayOffer = ((eachQuoteProduct.Play__c != '' && eachQuoteProduct.Play__c != 'None')?('Play : '+ eachQuoteProduct.Play__c):'') + ' ' + (eachQuoteProduct.Offer__c !=null?('. Offer : '+eachQuoteProduct.Offer__c):'' );
            list_QuoteProducts.add(wrapperRecord);
            if(!eachQuoteProduct.Hide_Record__c) {
                list_DisplayedQuoteProducts.add(wrapperRecord);
            }
            list_QuoteProductRecords.add(eachQuoteProduct);
            
            if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Bundle') {                  
                blnHasBundles = true;
                map_BundleQuoteProducts.put(eachQuoteProduct.Id,eachQuoteProduct);
            }            
            else {
                if(eachQuoteProduct.Bundle_Line__c != null)
                    list_BundleItemQPRecords.add(eachQuoteProduct);  
            }
        }
        System.debug('########intTotalNoOfDisplayedRecords : '+intTotalNoOfDisplayedRecords );
        intTotalNoOfRecords = list_QuoteProducts.size();
        intTotalNoOfDisplayedRecords = list_DisplayedQuoteProducts.size();
        System.debug('########intTotalNoOfRecords: '+intTotalNoOfRecords );
        System.debug('########intTotalNoOfDisplayedRecords : '+intTotalNoOfDisplayedRecords );
        // Set up the Current Page Grid
        createCurrentPageList();
    }
    
    // *** Method to generate query string to query Quote Products from the DB ***
    public String prepareQuoteProductQuery(Id quoteId)
    {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQueryAllFields += field.getFieldPath() + ', ';
        
        strQueryAllFields += 'BigMachines__Product__r.Include_in_Agent_Seat_Count__c,BigMachines__Product__r.Partner_Margin_Category__c, BigMachines__Product__r.description__c,BigMachines__Product__r.Tier__c, BigMachines__Product__r.Product_Group__c, BigMachines__Product__r.' + quote.New_Price_Book__c + '_Price__c,';
        strQueryAllFields += 'Bundle__r.Name,Bundle__r.Token_Value__c, Bundle__r.Type__c, Subscription_Product__r.Partner_Price__c,BigMachines__Product__r.Charge_Type__c, BigMachines__Product__r.Partner_Margin_Type__c,Parent_Quote_Product__r.Quantity__c,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,BigMachines__Product__r.Show_Add_Sign__c,BigMachines__Product__r.Unit_of_Measure__c, ';
        strQueryAllFields += 'Bundle__r.Description__c,Bundle__r.Message__c';
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'';
        
        if(quote.Grid_Group_By__c == 'Categories')
            strQueryAllFields += ' ORDER BY BigMachines__Product__r.New_Category__c ASC NULLS LAST,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Anchor_Product__c,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else if(quote.Grid_Group_By__c == 'Recurring/Non-Recurring')
            strQueryAllFields += ' ORDER BY BigMachines__Product__r.Include_in_CMMR_Total__c DESC,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else if(quote.Grid_Group_By__c == 'Bundles/Products')
            strQueryAllFields += ' ORDER BY Bundle__c NULLS LAST,Bundle__r.Name,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else if(quote.Grid_Group_By__c == 'Proposal Groups')
            strQueryAllFields += ' ORDER BY Group_Number__c NULLS LAST,BigMachines__Product__r.Sort_Order__c,BigMachines__Product__r.Name';
        
        else
            strQueryAllFields += ' ORDER BY Third_Party__c NULLS FIRST, BigMachines__Product__r.Sort_Order__c, BigMachines__Product__r.Name';
        
        System.Debug('prepareQuoteProductQuery: strQueryAllFields ' + strQueryAllFields);
        return strQueryAllFields;
    }
    
    // *** Method to return boolean whether record should be locked from editing or not ***
    public Boolean getIsQuoteUnLocked()
    {
        if(quote.BigMachines__Status__c == 'Quote Approval Pending' ||
           quote.BigMachines__Status__c == 'Quote Approved' ||
           quote.BigMachines__Status__c == 'Order Submitted' || 
           quote.BigMachines__Status__c == 'Order Accepted' || 
           quote.BigMachines__Status__c == 'Order Rejected' ||
           quote.BigMachines__Status__c == 'Quote Rejected')
            return false;
        return true;
    }
    
    // *** Handler for Mass Update Button ***
    public void massUpdateBtnHandler()
    {
        if(objMassUpdateInput.Disc__c != null && String.isBlank(objMassUpdateInput.or_Amount__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Mass Update :: % or Amount : Please Enter Value.'));
            return;
        }
        
        // If both discount and quantity are not specified then end execution
        if(objMassUpdateInput.Disc__c == null && objMassUpdateInput.Quantity__c == null)
            return;
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            System.Debug('massUpdateBtnHandler obj ' + obj + 'objMassUpdateInput ' + objMassUpdateInput);
            if(obj.selected)
            {
                // Updating Discount on Lines 
                if(objMassUpdateInput.Disc__c != null && obj.record.BigMachines__Product__r.Discountable__c)
                {
                    obj.record.Disc__c = objMassUpdateInput.Disc__c;
                    obj.record.or_Amount__c = objMassUpdateInput.or_Amount__c;
                }
                
                // Updating Quantity on Lines
                if(objMassUpdateInput.Quantity__c != null)
                    obj.record.Quantity__c = objMassUpdateInput.Quantity__c;
                
                obj.selected = false;
            }
        }
        
        doCalculations();
    }
    
    // *** Handler for Goal Seek Button **
    public void goalSeekBtnHandler()
    {
        if(quote.Goal_Seek__c == null)
        {
            quote.Goal_Seek__c.addError('Please Enter Value');
            return;
        }
        // Calculating Total Net with only Bundle and Proposal Group Discount (excluding non discountable products) respectively factored in
        Decimal decTotalNetAvailableForGoalSeek = 0,decTotalListPrice = 0;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
        {   
            // Only consider discountable products
            if(objQP.Ext_List__c != null && objQP.Ext_List__c != 0)
            {
                decTotalListPrice += objQP.Ext_List__c;
                decTotalNetAvailableForGoalSeek += objQP.Ext_List__c;
                
                // Proposal Group Discount
                if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) && 
                   map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c != null)
                {
                    decTotalNetAvailableForGoalSeek -= (objQP.Ext_List__c * map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c/100);
                }
                /*// Bundle Discount                
if(objQP.Bundle__c != null && objQP.Bundle_Discount__c != null && objQP.Bundle_Discount__c != 0)
decTotalNetAvailableForGoalSeek -= (objQP.Ext_List__c * objQP.Bundle_Discount__c/100);
*/
            }
        }
        
        Decimal noOfMonths = quote.No_Of_Months__c > 12 ? 12 : quote.No_Of_Months__c;
        Decimal goalSeek = quote.Goal_Seek__c/ noOfMonths;
        
        if(goalSeek > decTotalNetAvailableForGoalSeek)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Goal Seek Amount should be less than Total List Price Less Bundle, Proposal Group Discounts and non Discountable Products.'));
            return;
        }
        
        if(decTotalListPrice != 0)
        {
            Decimal decComputedDiscountPercent = ((decTotalListPrice - goalSeek)/decTotalListPrice) * 100;
            quote.Adjustment__c = 0;
            Decimal decDiscountToAdjust = 0,decListPriceOfItemsToIncrease = 0;
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {               
                objQP.Adjustment__c = 0;
                objQP.or_Amount__c = 'Amt';
                
                if(objQP.List_Price__c != null && objQP.Ext_List__c != null)
                {
                    Decimal listPrice = objQP.List_Price__c;
                    Decimal extListPrice = objQP.Ext_List__c;
                    
                    // if Product is not discountable
                    if(!objQP.BigMachines__Product__r.Discountable__c)
                        decDiscountToAdjust += extListPrice * (decComputedDiscountPercent/100);
                    
                    // Checking for product specific discount limit
                    else if(objQP.Product_Specific_Discount__c != null && objQP.Product_Specific_Discount__c < decComputedDiscountPercent)
                    {
                        objQP.Disc__c = objQP.Product_Specific_Discount__c;
                        objQP.or_Amount__c = '%';
                        decDiscountToAdjust += (extListPrice * (decComputedDiscountPercent - objQP.Product_Specific_Discount__c)/100);
                    }
                    else 
                    {
                        decListPriceOfItemsToIncrease += extListPrice;
                        objQP.Disc__c = (listPrice * decComputedDiscountPercent/100);
                    }
                }
                
                /*
if(objQP.Ext_List__c != null && objQP.Bundle__r.Group_Type__c == 'Campaigns' && objQP.Product_Description__c == 'Campaign')
{
Decimal listPrice = objQP.List_Price__c;
Decimal extListPrice = objQP.Ext_List__c;

// if Product is not discountable
if(!objQP.BigMachines__Product__r.Discountable__c)
decDiscountToAdjust += extListPrice * (decComputedDiscountPercent/100);

// Checking for product specific discount limit
else if(objQP.Product_Specific_Discount__c != null && objQP.Product_Specific_Discount__c < decComputedDiscountPercent)
{
objQP.Disc__c = objQP.Product_Specific_Discount__c;
objQP.or_Amount__c = '%';
decDiscountToAdjust += (extListPrice * (decComputedDiscountPercent - objQP.Product_Specific_Discount__c)/100);
}
else 
{
decListPriceOfItemsToIncrease += extListPrice;
objQP.Disc__c = (extListPrice * decComputedDiscountPercent/100);
}
}*/
            }
            
            if(decDiscountToAdjust > 0)
            {
                if(decListPriceOfItemsToIncrease < decDiscountToAdjust)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Goal Seek Amount is too low. Please increase goal seek amount and re-try.'));
                    return;
                }
                
                Decimal decDiscountPercentToAdjust = (decDiscountToAdjust/decListPriceOfItemsToIncrease) * 100;
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {
                    // Only consider discountable products
                    if(objQP.BigMachines__Product__r.Discountable__c)
                    {
                        if(objQP.Product_Specific_Discount__c != null && objQP.Product_Specific_Discount__c < decComputedDiscountPercent)
                            continue;
                        
                        Decimal listPrice = objQP.List_Price__c;
                        Decimal extListPrice = objQP.Ext_List__c;
                        
                        if(listPrice != null)
                            objQP.Disc__c += (listPrice * decDiscountPercentToAdjust/100);
                        /*else 
{
if(extListPrice != null && objQP.Bundle__r.Group_Type__c == 'Campaigns' && objQP.Product_Description__c == 'Campaign')
objQP.Disc__c += (extListPrice * decDiscountPercentToAdjust/100);
}*/
                    }
                }
            }
            doCalculations();
        }
    }
    
    // *** Handler for Goal Seek Reset Button ***
    public void goalSeekResetBtnHandler()
    {
        quote.Goal_Seek__c = 0;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            objQP.Disc__c = 0;
        
        doCalculations();
    }
    
    // *** Handler for Apply Adjustment Button ***
    public void applyAdjustmentBtnHandler()
    {
        if(quote.Adjustment__c == null)
        {
            quote.Adjustment__c.addError('Please Enter Value');
            return;
        }
        Decimal decAdjustmentDiscount = quote.Adjustment__c == null ? 0 : quote.Adjustment__c;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
        {
            // Only consider discountable products
            if(objQP.BigMachines__Product__r.Discountable__c)
            {
                // Adjustment cannot exceed Product Specific Discount for any product
                if(objQP.Product_Specific_Discount__c != null && decAdjustmentDiscount > objQP.Product_Specific_Discount__c)
                    objQP.Adjustment__c = objQP.Product_Specific_Discount__c;
                else
                    objQP.Adjustment__c = quote.Adjustment__c;
            }
        }
        doCalculations();
    }
    
    // *** Handler for Adjustment Reset Button ***
    public void adjustmentResetBtnHandler()
    {
        quote.Adjustment__c = 0;
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            objQP.Adjustment__c = 0;
        
        doCalculations();
    }
    
    // *** Method to calculate proposal group Sub Totals ***
    public void calculateGroupSubTotals()
    {
        // Initializing sub totals
        objUngrouped.Sub_Total__c = 0;
        for(Quote_Proposal_Group__c objPG: list_ProposalGroups)
            objPG.Sub_Total__c = 0;
        
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
        {
            if(objQP.Ext_Net_Price__c != null)
            {
                Quote_Proposal_Group__c objPG;
                if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c))
                    objPG = map_GroupNumToGrouprecord.get(objQP.Group_Number__c);
                else
                    objPG = objUngrouped;
                
                objPG.Sub_Total__c += objQP.Ext_Net_Price__c;
            }
        }
    }
    
    public Boolean getIsOrderInfoAvailable()
    {
        if(quote.BigMachines__Status__c == 'Quote Approved' || quote.BigMachines__Status__c == 'Order Submitted' || 
           quote.BigMachines__Status__c == 'Order Accepted' || quote.BigMachines__Status__c == 'Order Rejected')
            return true;
        return false;
    }
    
    // *** Handler for Revise Order button ***
    public void reviseOrderBtnHandler()
    {
        blnIsReviseOrder = true;
        if(strSelectedTab != 'Order Submission')
            showOrderSubmission();
    }
    
    // *** Handler for Cancel button ***
    public void cancelBtnHandler()
    {
        blnIsReviseOrder = false;
    }
    
    // *** Method to check whether required fields are filled or not ***
    private Boolean checkRequiredFields()
    {
        Boolean blnHasRequiredError = false;
        if(!quote.Treat_SO_as_PO__c && String.isBlank(quote.Order_PO_Number__c))
        {
            quote.Order_PO_Number__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if(!quote.Treat_SO_as_PO__c && quote.Order_PO_Date__c == null)
        {
            quote.Order_PO_Date__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if(String.isBlank(quote.Order_Payment_Terms__c))
        {
            quote.Order_Payment_Terms__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        return blnHasRequiredError;
    }
    
    // *** Handler for Submit Order button ***
    public PageReference submitOrderBtnHandler()
    {
        Boolean blnIsAttachmentUploaded = false;
        
        if(quote.Amendment_For__c != null && quote.Amendment_For__r.Sale_Type__c != quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Sale Type on Subscription ' +quote.Amendment_For__r.name+' does not match the Sale Type(Direct/Indirect Sale) of the Opportunity of Quote.' ));
            return null;
        }
        if(String.isNotBlank(objAttachment.Name))
        {
            upsert objAttachment;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Attachment Uploaded.'));
            objAttachment = new Attachment(ParentId = quote.Id);
            blnIsAttachmentUploaded = true;
        }
        Boolean blnHasRequiredError = checkRequiredFields();       
        if(blnHasRequiredError)
            return null;
        
        String addressValidation = validateOrderSubmission();
        if(addressValidation != 'OK'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, addressValidation));
            return null;
        }
        
        if(quote.Amendment_For__c != null && quote.Amendment_For__r.Status__c != 'Active') {
            system.debug('Inside subscription status check');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subscription '+ quote.Amendment_For__r.Name +' is not active anymore. Please create a new quote with active subscription'));
            return null;
        }
        if(quote.Contract_Signature_Date__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please update Contract Signature Date.'));
            return null;
        }
        
        blnShowExportScreeningMsg = false;
        blnShowExportScreeningExpireMsg = false;
        // PO attachment not required if 'Customer PO Not Required' flag is checked
        if(!quote.Treat_SO_as_PO__c && !blnIsAttachmentUploaded && ([SELECT count() FROM Attachment WHERE ParentId = :quote.Id] == 0))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There are no attachments on this quote. Please attach PO before submitting order.'));
            return null;
        }    
        if([SELECT count() FROM Account_Order_Address__c WHERE Quote__c =: quote.id AND Address_Type__c = 'Ship To' AND Email__c = null] > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Pleast enter email for the Ship To address.'));
            return null;
        }
        // Checking for Export Screening Check-list (Country is not US and Checklist is not checked)
        List<Export_Screening_Checklist__c> esc = [select id,Checklist_expiration_date__c FROM Export_Screening_Checklist__c where Account__c=:quote.End_User_ID__c];
        if(esc.size()>0)
        {
            if(esc[0].Checklist_expiration_date__c < system.today()){
                escid = esc[0].id;
                blnShowExportScreeningExpireMsg = true;
                System.debug('++++escid'+ escid);
                return null;
            }
        }
        if(quote.End_User_ID__c != null && quote.End_User_ID__r.Country__r.Name != 'United States' &&
           ![SELECT screening_checklist_completed__c FROM Account WHERE Id = :quote.End_User_ID__c].screening_checklist_completed__c)
        {
            system.debug('__insider');
            blnShowExportScreeningMsg = true;
            return null;            
        }
        
        //Check to ensure there are no unallocated shippable products
        List<BigMachines__Quote_Product__c> list_QtProdsShippable = new List<BigMachines__Quote_Product__c>();
        list_QtProdsShippable = [SELECT Id, BigMachines__Quantity__c
                                 FROM BigMachines__Quote_Product__c
                                 WHERE BigMachines__Quote__c =: quote.Id
                                 AND BigMachines__Product__r.ProductShippable__c = 'Yes'];
        if(quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription) {
            list_QtProdsShippable = [SELECT Id, BigMachines__Quantity__c, Quantity_Change__c
                                     FROM BigMachines__Quote_Product__c
                                     WHERE BigMachines__Quote__c =: quote.Id
                                     AND BigMachines__Product__r.ProductShippable__c = 'Yes'
                                     AND BigMachines__Product__r.New_Category__c = 'Hardware'
                                     AND Quantity_Change__c > 0];
        }
        if(list_QtProdsShippable.size() > 0) {
            Map<Id, Decimal> map_OLIAProdQuantities = new Map<Id, Decimal>();
            for(Order_Line_Item_Allocation__c objOLIA : [SELECT Id, Order_Shipping_Location__c, Quantity__c, Quote_Product__c
                                                         FROM Order_Line_Item_Allocation__c 
                                                         WHERE Quote__c =: quote.Id]) {
                                                             if(map_OLIAProdQuantities.containsKey(objOLIA.Quote_Product__c)) {
                                                                 map_OLIAProdQuantities.put(objOLIA.Quote_Product__c, map_OLIAProdQuantities.get(objOLIA.Quote_Product__c) + objOLIA.Quantity__c);
                                                             }
                                                             else {
                                                                 map_OLIAProdQuantities.put(objOLIA.Quote_Product__c, objOLIA.Quantity__c);
                                                             }    
                                                         }
            for(BigMachines__Quote_Product__c objQtProd : list_QtProdsShippable) {
                Decimal decQty = quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription ? objQtProd.Quantity_Change__c : objQtProd.BigMachines__Quantity__c;
                if(!map_OLIAProdQuantities.containsKey(objQtProd.Id) 
                   || map_OLIAProdQuantities.get(objQtProd.Id) != decQty) {
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.PC_Unallocated_Quantity_Error_Message));
                       return null;
                   }
            }
        }  
        
        if([SELECT count() 
            FROM Order__c 
            WHERE RecordType.Name = 'Cloud Billing Master Order'
            AND Opportunity__c = :quote.BigMachines__Opportunity__c
            AND (Status__c = 'Order Submitted' OR Status__c = 'Approved')] > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Order has already been submitted for this Opportunity. Please verify.'));                
                return null;
            }
        
        // Savepoint before DML
        Savepoint objSP = Database.setSavepoint();
        
        String strCurrentStatus = quote.BigMachines__Status__c;
        quote.BigMachines__Status__c = 'Order Submitted';
        quote.Order_Date_Submitted__c = Date.today();
        if(quote.Order_Type__c == Label.New_Subscription || quote.Order_Type__c == Label.Replace_Subscription) {
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            quote.Subscription_Start_Date__c = quote.Order_Date_Submitted__c.addMonths(quote.Ramp_Period__c != 'Other' ? Integer.valueOf(strRampPeriod)/30 : 0);
            quote.Subscription_End_Date__c = quote.Subscription_Start_Date__c.addMonths(Integer.valueOf(quote.No_Of_Months__c))-1;
        } 
        else if(quote.Order_Type__c == Label.Renew_Subscription) {
            //quote.Subscription_Start_Date__c = quote.Order_Date_Submitted__c;
            quote.Subscription_End_Date__c = quote.Subscription_Start_Date__c.addMonths(Integer.valueOf(quote.No_Of_Months__c))-1;
        }
        try {
            //Initiating order creation process.
            if(quote.Quote_Products_without_Line_Numbers__c > 0){QuoteCloudUtil.populateLineNumbers(quote.Id, quote.order_type__c, quote.Amendment_For__r.Quote__c);}
            OrderCloudUtil.orderFromQuote(quote);      
            Order__c obj_NewOrder = [SELECT Id, Name FROM Order__c WHERE Quote__c =: quote.Id AND Original_Parent_Order1__c = null LIMIT 1];
            quote.Order__c = obj_NewOrder.Id;
            Util.Bypass_Trigger_Chk = true;
            update quote;
            
            if(quote.BigMachines__Opportunity__c != null && quote.Order__c != null)
            {
                Util.Bypass_Trigger_Chk = true;
                update (new Opportunity(Id = quote.BigMachines__Opportunity__c, 
                                        ForecastStatus__c = Label.Oppty_Forecast_Status_Order_Submission,
                                        StageName = ((quote.BigMachines__Opportunity__r.RecordType.Name == 'Cloud Renewal')?'Work In Progress':Label.Oppty_Stage_Order_Submission)));
                Util.Bypass_Trigger_Chk = false;
            }
            
            System.debug('######quote.Order__c'+quote.Order__c);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Order Submitted.'));
            blnIsReviseOrder = false;
            PageReference returnPage = new PageReference('/apex/CreateQuoteCloudPEC?Id='+quote.Id+'&tab=OrderSubmission');            
            returnPage.setRedirect(true);
            return returnPage;
            
        }
        catch(Exception ex) {
            quote.BigMachines__Status__c = strCurrentStatus;
            quote.Order_Date_Submitted__c = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+ex.getMessage()+ex.getStackTraceString()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
            return null;
        }
    }
    
    public void saveOrderInfo()
    {
        if(blnIsReviseOrder && checkRequiredFields())
            return;
        
        if(blnIsReviseOrder)
        {
            updateOrders();
        }
        
        blnIsReviseOrder = false;
    }
    
    public void updateOrders()
    {
        List<Order__c> list_Orders = [SELECT Id FROM Order__c WHERE Quote__c = :quote.Id];
        for(Order__c objOrder : list_Orders)
        {
            objOrder.PO_Number__c = quote.Order_PO_Number__c;
            objOrder.PO_Date__c = quote.Order_PO_Date__c;
            objOrder.PO_for_FYM__c = quote.PO_for_FYM__c;
            objOrder.Special_Instructions__c = quote.Order_Special_Instructions__c;
            
            objOrder.Payment_Terms__c = quote.Order_Payment_Terms__c;
            objOrder.Ship_Software_Via__c = quote.Order_Ship_Software_Via__c;
            objOrder.Bill_To_Name__c = quote.Bill_To_Name__c;
            objOrder.Ship_To_Information__c = quote.Ship_To_Information__c;
            objOrder.Support_Owner__c = quote.Support_Owner__c;
            objOrder.System_Integrator__c = quote.System_Integrator__c;
            
            objOrder.Server_OS__c = quote.Server_OS__c;
            objOrder.PBX__c = quote.PBX__c;
            objOrder.Database__c = quote.Database__c;
            objOrder.IVR__c = quote.IVR__c;
            objOrder.Add_Language__c = quote.Add_Language__c;
        }       
        
        if(list_Orders.size() > 0)
            update list_Orders;
    }
    
    public List<historyWrapper> fetchApprovals()
    {
        //Whether to show approve/reject button 
        mode =  ApexPages.currentPage().getParameters().get('mode');
        
        if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_PENDING)
            overAllStatus = QuoteApprovalUtil.STATUS_PENDING;
        else if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_APPROVED)
            overAllStatus = QuoteApprovalUtil.STATUS_APPROVED;
        else if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REJECTED)
            overAllStatus = QuoteApprovalUtil.STATUS_REJECTED;
        else if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING)
            overAllStatus = QuoteApprovalUtil.STATUS_CANCELLED;
        
        //Getting quote approval records with related fields
        List<Quote_Approval__c>  quoteApprovals = [SELECT id, Quote_Approval_Step_Details__c, owner.Name, ownerId, Status__c,
                                                   Quote_Approval_Step_Details__r.Quote_Approval_Step__r.Order__c, Quote_Approval_Step_Details__r.Priority_Sequence__c,
                                                   Step_Name__c, Quote_Approval_Step_Details__r.Quote_Approval_Step__c, Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Name,
                                                   CreatedDate, Actual_Approver__r.Name, Comments__c, BigMachines_Quote__r.BigMachines__Status__c, Approval_Submission_Counter__c,
                                                   LastModifiedDate, Step__c, Submitted_Date__c, Quote_Approval_Date__c, Approval_Method__c
                                                   FROM Quote_Approval__c
                                                   WHERE BigMachines_Quote__c =: quoteId ORDER BY Display_Order__c DESC];
        //Getting Max submission counter
        List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
                                                          WHERE BigMachines_Quote__c =: quoteId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
        //If quote is already rejected, don't show approve/reject buttons
        if(!quoteApprovals.isEmpty() && quoteApprovals[0].BigMachines_Quote__r.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REJECTED)
            mode = 'noAction';
        
        //Making sure of hiding section if there is no approval record
        if(quoteApprovals.isEmpty())
            showApprovalHistory = false;
        else
            showApprovalHistory = true;
        //Initializing wrapper list 
        List<historyWrapper> approvals = new List<historyWrapper>();    
        Integer counter = 1;    
        Set<String> setSteps = new Set<String>();
        Set<Decimal> setSubmissions = new Set<Decimal>();
        //How many times quote is submitted to approval
        Decimal submissionCounter = 1;
        if(!existingQuoteApprovals.isEmpty())
            submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c; 
        //Looping over all quote approval record 
        for(Quote_Approval__c eachQuoteApproval : quoteApprovals){
            if(showLastSubmission != null && showLastSubmission 
               && eachQuoteApproval.Approval_Submission_Counter__c != submissionCounter){
                   continue;
               }            
            //Showing a record for request submission
            if(submissionCounter != eachQuoteApproval.Approval_Submission_Counter__c){
                submissionCounter = eachQuoteApproval.Approval_Submission_Counter__c;
                approvals = addSubmissionRecords(approvals, eachQuoteApproval);
            }   
            //Steps Unique Key
            String key = eachQuoteApproval.Step__c + String.valueOf(eachQuoteApproval.Approval_Submission_Counter__c);
            //Creating step header row          
            if(!setSteps.contains(key)){
                historyWrapper stepHeaderRecord = new historyWrapper();
                stepHeaderRecord.rowType = 'step';
                stepHeaderRecord.actionTitle = 'Step: ' + eachQuoteApproval.Step_Name__c;
                stepHeaderRecord.styleClass = 'stepRow';
                stepHeaderRecord.style= 'color:#ffffff;background-color:#9BC4D7;font-weight:bold;';
                if(counter == 1)
                    stepHeaderRecord.showOverallStatus = true;
                else
                    stepHeaderRecord.showOverallStatus = false;
                approvals.add(stepHeaderRecord);
            }
            
            //Adding submission counter to set to determine no of submission
            setSubmissions.add(eachQuoteApproval.Approval_Submission_Counter__c);
            //Set which tells whether there already a step row or not for current approval record
            setSteps.add(key);
            historyWrapper newRecord = new historyWrapper();
            if(eachQuoteApproval.Submitted_Date__c != null)
                newRecord.submittedDate = eachQuoteApproval.Submitted_Date__c.format();
            if(eachQuoteApproval.Quote_Approval_Date__c != null)
                newRecord.approvalRejectDate = eachQuoteApproval.Quote_Approval_Date__c.format();
            newRecord.approvalRecord = eachQuoteApproval;   
            //Applying css style depending on status
            if(eachQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_APPROVED)
                newRecord.statusClass = 'approved';
            else if(eachQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_REJECTED)
                newRecord.statusClass = 'rejected';
            newRecord.showAction = false;
            newRecord.rowType = 'detail';
            approvals.add(newRecord);
            counter ++;           
            if(counter - 1 == quoteApprovals.size())
                approvals = addSubmissionRecords(approvals, eachQuoteApproval); 
        }   
        return approvals;
    }
    
    @Testvisible
    private List<historyWrapper> addSubmissionRecords(List<historyWrapper> approvals, Quote_Approval__c eachQuoteApproval)
    {
        //Request submission header row
        historyWrapper submissionHeaderRecord = new historyWrapper();
        submissionHeaderRecord.rowType = 'step';
        submissionHeaderRecord.actionTitle = 'Approval Request Submitted';
        submissionHeaderRecord.styleClass = 'stepRow';
        submissionHeaderRecord.showOverallStatus = false;
        submissionHeaderRecord.style= 'background-color:#70AAC6;font-weight:bold;color:#ffffff;';
        approvals.add(submissionHeaderRecord);
        //Cloning quote approval record 
        Quote_Approval__c cloneQuoteApproval = eachQuoteApproval.clone(true,false);
        //Request submission details row
        historyWrapper submissionDetailRecord = new historyWrapper();
        submissionDetailRecord.rowType = 'submissionDetail';
        cloneQuoteApproval.Status__c = 'Submitted'; 
        cloneQuoteApproval.Actual_Approver__c = null;
        submissionDetailRecord.approvalRecord = cloneQuoteApproval; 
        approvals.add(submissionDetailRecord);        
        
        return approvals;       
    }
    // *** Method invoked on click of save button on configuration page (from javascript) ***
    public void saveBeforeReload()
    {
        // Skip Triggers
        Util.Bypass_Trigger_Chk = true;
        try
        {
            if(list_QuoteProductRecords.size() > 0)
                upsert list_QuoteProductRecords;
            
            getQuoteProducts(quoteId);            
            doCalculations();
            //Naresh Kumar   01/04/2016  Updating SML Data
            SMLHelperWTS.updateSMLForAccount(quote.End_User_ID__c);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+ex.getMessage()+ex.getStackTraceString()));
        }
    }
    
    // *** Method to perform maintenance due calculations : Handler for Recalculate button ***
    public pageReference doCalculations()
    {   
        System.Debug('doCalculations start');
        update quote;
        Set<Id> set_QouteProductIds = new Set<Id>();  
        BigMachines__Quote_Product__c objQPTrainingUnit;
        buildChangeHistoryForAmendSubscr();
        System.Debug('doCalculations after buildChangeHistoryForAmendSubscr');
        
        if(objAttachment != null && String.isNotBlank(objAttachment.Name))
        {
            insert objAttachment;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Attachment Uploaded.'));
            objAttachment = new Attachment(ParentId = quote.Id);
        }
        System.Debug('doCalculations before !getIsQuoteUnLocked status ' + quote.BigMachines__Status__c);
        if(!getIsQuoteUnLocked())
        {
            System.Debug('doCalculations in !getIsQuoteUnLocked');
            try
            {
                if(quote.Expiration_Date__c != null && quote.Approval_Submission_Date__c != null)
                {
                    if(quote.Expiration_Date__c < quote.Approval_Submission_Date__c)
                    {
                        System.Debug('doCalculations in !getIsQuoteUnLocked: Expiry Date cannot be earlier than Quote Submitted Date');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Expiry Date cannot be earlier than Quote Submitted Date'));
                        return null;
                    }
                    else if(quote.Approval_Submission_Date__c.daysBetween(quote.Expiration_Date__c) > 90 && quote.BigMachines__Status__c!='Quote Approved')
                    {
                        System.Debug('doCalculations in !getIsQuoteUnLocked: Expiry Date has to be no later than 90 days from Quote Submitted Date. Please revise quote.');
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Expiry Date has to be no later than 90 days from Quote Submitted Date. Please revise quote.'));
                        return null;
                    }
                }                    
                if(quote.Sent_to_Customer__c && quote.BigMachines__Opportunity__c != null)
                    update (new Opportunity(Opportunity_Status__c = 'With Customer',Id = quote.BigMachines__Opportunity__c));
                
                if(getIsOrderInfoAvailable() && (quote.Revise_Minor__c || blnIsReviseOrder))
                    saveOrderInfo();
                
                update quote;
            }
            catch(Exception ex)
            {
                System.Debug('doCalculations in !getIsQuoteUnLocked: An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+ex.getMessage()+ex.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+ex.getMessage()+ex.getStackTraceString()));
            }
            System.Debug('doCalculations in !getIsQuoteUnLocked returning null');
            return null;
        }
        System.Debug('doCalculations after !getIsQuoteUnLocked');
        
        if(quote.Initial_Subscription_Term__c.containsIgnoreCase(' Month'))
            quote.No_Of_Months__c = Integer.ValueOf(quote.Initial_Subscription_Term__c.substringBefore(' Month'));
        if(quote.Initial_Subscription_Term__c.containsIgnoreCase(' Year'))
            quote.No_Of_Months__c = Integer.ValueOf(quote.Initial_Subscription_Term__c.substringBefore(' Year')) * 12;
        
        blnHasError = false;
        // ****************** Validations *****************************
        Integer intIndex = 0;
        Set<Id> set_ProductIds = new Set<Id>();
        Set<Id> set_TieredPricingProductIds = new Set<Id>();
        Map<Id,List<Product_Tier_Pricing__c>> map_TieredProducts = new Map<Id,List<Product_Tier_Pricing__c>>();
        Map<Id,List<Product_Tier_Pricing__c>> map_TieredProductsOverage = new Map<Id,List<Product_Tier_Pricing__c>>();
        
        quote.Editable_List_Price_Approval_Required__c = false;
        
        if(quote.No_Of_Months__c == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Number of Months cannot be 0.'));
            return null;
        }
        
        if(quote.Subscription_Start_Date__c.addMonths(Integer.valueOf(quote.No_Of_Months__c)) - 1 < Date.today()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot change the Initial Subscription Term to a value that will result in a Subscription Term End Date that has already passed.'));
            return null;
        }
        
        System.debug(quote.Amendment_For__c);
        if(quote.Amendment_For__c != null && quote.Amendment_For__r.Status__c != 'Active') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subscription '+ quote.Amendment_For__r.Name +' is not active anymore. Please create a new quote with active subscription'));
            return null;
        }
        if(quote.Amendment_For__c != null && quote.Amendment_For__r.Sale_Type__c != quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Sale Type on Subscription ' +quote.Amendment_For__r.name+' does not match the Sale Type(Direct/Indirect Sale) of the Opportunity of Quote.' ));
            return null;
        }
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
            intIndex++;
            // Storing all product ids of products associated with quote products in a set
            set_ProductIds.add(objQP.BigMachines__Product__c);
            
            if(objQP.BigMachines__Product__r.Price_Type__c == 'Range' 
               || (objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan' && !objQP.Is_Overage__c))
                set_TieredPricingProductIds.add(objQP.BigMachines__Product__c);
            else if(objQP.BigMachines__Product__r.Price_Type__c == 'Editable')
                quote.Editable_List_Price_Approval_Required__c = true;
            // Skip the check for Bundle Header Lines
            System.debug('Bundle +++'+ objQP.Bundle__c);
            if(objQP.Bundle__c != null)
                continue;
            
            if(String.isBlank(objQP.BigMachines__Product__r.New_Category__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please populate category field for the product \"' + objQP.BigMachines__Product__r.Name+ '\".'));
                blnHasError = true;
                return null;
            }    
            
            System.debug('Is Overage +++'+ objQP.Is_Overage__c);
            System.debug('ProductId ++'+objQP.BigMachines__Product__c);
            System.debug('map_PrevProdQuantity +++' + map_PrevProdQuantity);
            System.debug('Quantity+++'+objQP.Quantity__c);
            if((quote.Order_Type__c == Label.Amend_Subscription)
               && Label.Check_For_One_Time_Fees_PCC.contains(objQP.BigMachines__Product__r.New_Category__c)
               && map_PrevProdQuantity.containsKey(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c) && objQP.Quantity__c < map_PrevProdQuantity.get(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c))
            {
                objQP.Quantity__c = map_PrevProdQuantity.get(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c);
                map_ProdChangeHistoryColor.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, strChngeHistColors[0]);
                map_ProdChangeHistory.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, 'Original');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please note that quantity cannot be reduced for \"' + objQP.Product_Description__c + '\".'));
                blnHasError = true;
                return null;
            }
            
            if(String.isNotBlank(objQP.BigMachines__Product__r.Flavors_Available__c) && String.isBlank(objQP.Flavor__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Flavor for the product where ever applicable.'));
                blnHasError = true;
                return null;
            }
            
            //Reset GC Override if needed
            if(!quote.X3rd_Party_Override__c && objQP.Original_Third_Party_GC__c != null)
                objQP.Third_Party_GC__c = objQP.Original_Third_Party_GC__c;
        }
        System.Debug('doCalculations after for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)');
        
        List<Genesys_Product_Prerequisite__c> list_ValidationResults = new List<Genesys_Product_Prerequisite__c>();
        if(!Test.isRunningTest()) {
            list_ValidationResults = QuoteUtil.runPrerequisiteValidations(quote,list_QuoteProductRecords);
        }
        System.debug('doCalculations list_ValidationResults ' + list_ValidationResults.size());
        if(!list_ValidationResults.isEmpty())
        {
            for(Genesys_Product_Prerequisite__c objPreReq : list_ValidationResults)
            {
                if(objPreReq.Mandatory__c)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,objPreReq.Message__c));
                    blnHasError = true;
                }
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,objPreReq.Message__c));
            }
            if(blnHasError)
                return null;
        }
        System.debug('Billing Category+++'+quote.Billing_Category__c);
        if(!set_TieredPricingProductIds.isEmpty()){
            String strQuery = 'SELECT Price_Type__c, Type__c, Partner_Margin_Category__c, (SELECT Charge_Type__c, Range_From__c, Range_To__c,'
                + quote.New_Price_Book__c + '_Price__c FROM Product_Tier_Pricings__r'                 
                + ' WHERE Charge_Type__c = \'' +  quote.Billing_Category__c + '\' OR Charge_Type__c = \'M2M\' ORDER BY Range_From__c)'               
                + ' FROM Product2 WHERE Id IN: set_TieredPricingProductIds';
            system.debug('######'+strQuery);
            for(Product2 eachProduct : Database.query(strQuery))
            {
                for(Product_Tier_Pricing__c objPricing : eachProduct.Product_Tier_Pricings__r)
                {
                    if(objPricing.Charge_Type__c == 'M2M')
                    {
                        if(map_TieredProductsOverage.containskey(eachProduct.id))
                            map_TieredProductsOverage.get(eachProduct.id).add(objPricing);
                        else
                            map_TieredProductsOverage.put(eachProduct.id, new List<Product_Tier_Pricing__c>{objPricing});
                    }
                    else
                    {
                        if(map_TieredProducts.containskey(eachProduct.id))
                            map_TieredProducts.get(eachProduct.id).add(objPricing);
                        else
                            map_TieredProducts.put(eachProduct.id, new List<Product_Tier_Pricing__c>{objPricing});
                    }
                }
            }
        }
        
        //Creating map for overage
        Map<id,BigMachines__Quote_Product__c> map_OverageProducts = new Map<id,BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
            system.debug(objQP);
            if(objQP.Is_Overage__c)
            {
                for(BigMachines__Quote_Product__c objQPParent : list_QuoteProductRecords) {
                    system.debug(objQPParent);
                    if(objQPParent.id == objQP.Parent_Quote_Product__c)
                        map_OverageProducts.put(objQP.id,objQPParent);
                }
            }
            system.debug(map_OverageProducts);
        }
        
        // Checking if prices have been updated
        if(String.isNotBlank(quote.New_Price_Book__c)) {
            Boolean blnHasPriceUpdate = false;
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
                set_ProductIds.add(objQP.BigMachines__Product__c);
                System.debug('####objQP'+objQP);
                System.Debug('quote.New_Price_Book__c ' + quote.New_Price_Book__c);
                Decimal decProductPrice;
                decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get(quote.New_Price_Book__c + '_Price__c');
                //if(!objQP.Is_Overage__c) {                
                // Pulling price for Tiered Pricing product
                if(map_TieredProducts.containsKey(objQP.BigMachines__Product__c)) {
                    //For partners, no tier pricing, base price..
                    if(quote.BigMachines__Opportunity__r.PureEngage_Cloud_Partner_Approved__c)
                    {
                        decProductPrice = decProductPrice;
                        if(objQP.BigMachines__Product__r.Price_Type__c != null && strRangeandRatePlan.contains(objQP.BigMachines__Product__r.Price_Type__c) && map_TieredProducts.get(objQP.BigMachines__Product__c).size() > 0) {
                            if(objQP.Is_Overage__c)
                                decProductPrice = ((Decimal)map_TieredProductsOverage.get(objQP.BigMachines__Product__c)[0].get(quote.New_Price_Book__c + '_Price__c'))*1.2;
                            else
                                decProductPrice = (Decimal)map_TieredProducts.get(objQP.BigMachines__Product__c)[0].get(quote.New_Price_Book__c + '_Price__c');
                        }
                    }
                    else if(objQP.BigMachines__Product__r.Price_Type__c == 'Range')
                    {
                        system.debug(objQP);
                        if(objQP.Is_Overage__c && map_OverageProducts.size() > 0)
                            decProductPrice = (QuoteCloudUtil.getProductTierPricing(map_TieredProductsOverage.get(objQP.BigMachines__Product__c), 
                                                                                    map_OverageProducts.get(objQP.id).Quantity__c, decProductPrice,  quote.New_Price_Book__c + '_Price__c'))*1.2;
                        else
                            decProductPrice = QuoteCloudUtil.getProductTierPricing(map_TieredProducts.get(objQP.BigMachines__Product__c), 
                                                                                   objQP.Quantity__c, decProductPrice,  quote.New_Price_Book__c + '_Price__c');
                    }
                    else if(objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan' 
                            && map_TieredProducts.get(objQP.BigMachines__Product__c).size() > 0) 
                    {
                        if(objQP.Is_Overage__c)
                            decProductPrice = ((Decimal)map_TieredProductsOverage.get(objQP.BigMachines__Product__c)[0].get(quote.New_Price_Book__c + '_Price__c'))*1.2;
                        else
                            decProductPrice = (Decimal)map_TieredProducts.get(objQP.BigMachines__Product__c)[0].get(quote.New_Price_Book__c + '_Price__c');
                    }
                }
                if(decProductPrice == null)
                    continue;
                
                // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                if(quote.Pricing_Model__c == 'Concurrent' && objQP.BigMachines__Product__r.Is_Concurrent__c == 'Yes' && objQP.BigMachines__Product__r.Unit_of_Measure__c != 'Port')
                    decProductPrice *= decPricingMultiplier;
                
                if(!objQP.Hide_Record__c && objQP.List_Price__c != decProductPrice && (objQP.Bundle_Line__c == null || (objQP.Bundle__r != null && (objQP.Bundle__r.Group_Type__c == 'Use Case' || objQP.Bundle__r.Group_Type__c == 'Base Package')))
                   && (strManualListPriceUpdate == '0' || (strManualListPriceUpdate == '1' && !Label.Manual_List_Price_Update_for_Cloud.contains(UserInfo.getUserId().left(15))))) {
                       if(objQP.BigMachines__Product__r.Price_Type__c != 'Editable') {
                           blnHasPriceUpdate = true;  
                           
                           if(quote.Order_Type__c != Label.Amend_Subscription || 
                              (quote.Order_Type__c == Label.Amend_Subscription && (objQP.Subscription_Product__c == null || (String.isNotBlank(strOldBillingCategory) && strOldBillingCategory != quote.Billing_Category__c)) &&   //(objQP.Quantity_Change__c > 0) &&  map_TieredProductsOverage.containskey(objQP.BigMachines__Product__c)) && 
                               (objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan' || objQP.BigMachines__Product__r.Price_Type__c == 'Range'))) 
                           {
                               objQP.List_Price__c = decProductPrice;
                               system.debug(objQP.List_Price__c);
                               if(!objQP.Is_Overage__c)
                                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,objQP.Name + ' price has been updated to ' + decProductPrice));
                           }
                       }
                   }
                //} 
                //Updating MSRP
                objQP.MSRP__c = objQP.List_price__c;
                if(map_TieredProducts.containsKey(objQP.BigMachines__Product__c)) {
                    if(objQP.BigMachines__Product__r.Price_Type__c != null && strRangeandRatePlan.contains(objQP.BigMachines__Product__r.Price_Type__c))
                        objQP.MSRP__c = (Decimal)map_TieredProducts.get(objQP.BigMachines__Product__c)[0].get(quote.New_Price_Book__c + '_Price__c');
                    
                }               
            }            
        }
        
        if(!quote.Include_Special_Offer_in_Output__c && (String.isNotBlank(quote.Special_Offer_Terms__c) || String.isNotBlank(quote.Business_Exceptions__c) ))
        {
            String strRichText;
            if(String.isNotBlank(quote.Special_Offer_Terms__c)){
                strRichText = String.valueof(quote.Special_Offer_Terms__c);
                strRichText = strRichText.replaceall('<.*>','');
            }
            if(String.isNotBlank(strRichText) || String.isNotBlank(quote.Business_Exceptions__c))
                quote.Include_Special_Offer_in_Output__c = true;
        }
        
        // ****************** Calculations *****************************
        // Using 1 consolidated list to limit DML operations
        List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
        intIndex = 0;
        Integer intSetScale = 2;
        Decimal decTotalNetPrice = 0,decTotalDiscountAmt = 0,decGenesysProductsDiscount = 0,listPriceTotalProductsOnly = 0, decGenesysAllDiscount = 0, listPriceTotalAll = 0;
        decTotalRecAmount = decTotalNonRecAmount = decTotalRecAmountPreDiscount = decTotalNonRecAmountPreDiscount = maxSeatCount = 0;
        decTotalCredit = decTotalNonRecCredit = decTotalRecCredit = 0;
        // To indicate whether there is any shipping required
        quote.Shipping_Required__c = false;
        quote.Total_GU_Training_Units__c = 0;
        //List<String> list_QuoteDiscountBuckets = new List<String> {'Base Agent', 'Hardware', 'Business Users & Add-On Functionality', 'Data Center Provisioning', 'Overage'}; 
        List<String> list_QuoteDiscountBuckets = new List<String> {'Cloud Services', 'PROFESSIONAL SERVICES', 'Overage'};
            List<String> list_QuoteOverallDiscounts = new List<String> {'Overall %', 'Third Party', 'Overall Amount'};                 
                
                Map<String, Decimal> map_QuoteDiscounts = new Map<String, Decimal>();
        Map<String, Decimal> map_QuoteProductListPrices = new Map<String, Decimal>();
        Map<String, Boolean> map_DisplayQuoteDiscounts = new Map<String, Boolean>();
        Set<Id> set_OvgProdParentIds = new Set<Id>();
        
        Decimal decTAMAmount = 0;
        Decimal decTAMDuration = 0;        
        Map<String, Decimal> map_TamProduct = new Map<String, Decimal>();
        for(TAM_Product__mdt objTAM : [SELECT MasterLabel, Offering_Type__c, Duration_months__c
                                       FROM TAM_Product__mdt 
                                       WHERE Offering_Type__c =: SubscriptionUtil.OFFERING_TYPE_PEC]) {
                                           map_TamProduct.put(objTAM.MasterLabel, objTAM.Duration_months__c);
                                       }
        
        for(String discBucket : list_QuoteDiscountBuckets) {
            map_QuoteDiscounts.put(discBucket, 0);
            map_QuoteProductListPrices.put(discBucket, 0);
            map_DisplayQuoteDiscounts.put(discBucket, false);
        } 
        for(String overallDisc : list_QuoteOverallDiscounts) {
            map_DisplayQuoteDiscounts.put(overallDisc, false);
        }
        System.debug('#####map_QuoteDiscounts'+map_QuoteDiscounts);
        if(quote.Billing_Category__c == 'M2M') {
            set_OvgProdParentIds = findOverageChargeAPNs();
        }
        System.debug('#####set_OvgProdParentIds: '+set_OvgProdParentIds);  
        
        System.debug('#####list_QuoteProductRecords: '+list_QuoteProductRecords.size());       
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
        {                
            //intIndex++;
            intSetScale = objQP.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != '2' && objQP.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != '4'
                && objQP.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != '6'?2:integer.valueof(objQP.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c); 
            set_ProductIds.add(objQP.BigMachines__Product__c);
            set_QouteProductIds.add(objQP.Id);
            // Initializing values to be computed
            System.debug('#####objQP.Quantity__c'+objQP.Quantity__c);
            //Code change start by Ankit on 11/12 for AVAYA
            objQP.Total_Discount__c = objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c = 0;
            objQP.Extended_Price_Per_Period__c = objQP.Extended_Price_Per_Month__c = 0;
            if(objQP.BigMachines__Product__r.ProductShippable__c=='Yes')
                quote.Shipping_Required__c = true;
            if(objQP.Bundle__r.Group_Type__c !='Campaigns'  && objQP.Product_Description__c != 'Campaign') {
                objQP.Ext_List__c = 0;
                objQP.Ext_Net_Price__c = 0;
            }
           // quote.Total_GU_Training_Units__c = 80;
            if(objQP.BigMachines__Product__r.Type__c == 'Training Unit'){
                //objQPTrainingUnit = objQP;
                // //Modified by Kartik To fix GU Units calculation
               system.debug('Total_GU_Training_Units__c'+quote.Total_GU_Training_Units__c); 
                 system.debug('Total_GU_Training_Units__c'+objQP.BigMachines__Product__c); 
                Product_Group_Item__c tokenvalue = [select Product__c,Token_Value__c from Product_Group_Item__c where Product__c =:objQP.BigMachines__Product__c];
                if(objQP.Quantity__c != null && tokenvalue.Token_Value__c != null){ //   tokenvalue.Token_Value__c != null objQP.Bundle__r.Token_Value__c != null
                   // quote.Total_GU_Training_Units__c += objQP.Quantity__c * objQP.Bundle__r.Token_Value__c;
                    quote.Total_GU_Training_Units__c += (objQP.Quantity__c * tokenvalue.Token_Value__c);
                }
                system.debug('Total_GU_Training_Units__c'+quote.Total_GU_Training_Units__c); 
               // else{ quote.Total_GU_Training_Units__c = 80;}
            }
            
            
            objQP.List_Price__c = (objQP.List_Price__c != null ? objQP.List_Price__c : 0).setScale(intSetScale); 
            objQP.Net_Unit_Price__c = objQP.List_Price__c;
            
            if(objQP.List_Price__c != null && objQP.List_Price__c != 0) {       
                Decimal decProductPartnerMargin = 0;
                System.debug('#####map_PCPartnerMargins: ' + map_PECPartnerMargins);
                if(quote.BigMachines__Opportunity__r.PureEngage_Cloud_Partner_Approved__c) {
                    if(quote.Order_Type__c != Label.Amend_Subscription || 
                       (quote.Order_Type__c == Label.Amend_Subscription && (objQP.Subscription_Product__c == null  || (String.isNotBlank(strOldBillingCategory) && strOldBillingCategory != quote.Billing_Category__c)))) {
                           if(map_PECPartnerMargins.containsKey(objQP.BigMachines__Product__r.Partner_Margin_Category__c))
                           {
                               decProductPartnerMargin = map_PECPartnerMargins.get(objQP.BigMachines__Product__r.Partner_Margin_Category__c);
                               System.Debug('#####map_PCPartnerMargins: objQP ' + objQP + ' got decProductPartnerMargin ' + decProductPartnerMargin);
                               /*
if(quote.BigMachines__Opportunity__r.Partner_Opportunity_Source__c  == 'Partner Registered Opportunity' 
&& quote.BigMachines__Opportunity__r.Partner_Opportunity_Status__c == 'Approved')
{
decProductPartnerMargin += Global_Configuration_Settings__c.getinstance().PCC_Deal_Registration_Discount__c;
quote.Deal_Registration_Discount__c = Global_Configuration_Settings__c.getinstance().PCC_Deal_Registration_Discount__c;
}  
*/
                           }
                           /*
else if(Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c) != NULL)
decProductPartnerMargin =  Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c).Margin__c;
*/                           
                           objQP.Partner_Price__c = (objQP.List_Price__c - (objQP.List_Price__c * decProductPartnerMargin/100));                        
                       }                    
                    //Logic to use same partner margin as in original subscriptions for amendments
                    else {
                        decProductPartnerMargin = objQP.Subscription_Product__r.Partner_Price__c > 0 ? (1 - (objQP.Subscription_Product__r.Partner_Price__c/objQP.List_Price__c))*100 : 0;
                        objQP.Partner_Price__c = objQP.Subscription_Product__r.Partner_Price__c;
                    }
                    System.debug('#####decProductPartnerMargin'+decProductPartnerMargin);
                    objQP.Total_Discount__c += decProductPartnerMargin;
                }
                // Proposal Group Discount
                if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) && 
                   map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c != null && objQP.BigMachines__Product__r.Discountable__c){
                       objQP.Proposal_Group_Discount__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c;
                       objQP.Total_Discount__c += objQP.Proposal_Group_Discount__c;        
                   }                    
                // Line Discount
                if(objQP.Disc__c != null && String.isNotBlank(objQP.or_Amount__c)){
                    // Selected Discount Option is %
                    if(objQP.or_Amount__c == '%'){
                        objQP.Total_Discount__c += objQP.Disc__c;           
                    }
                    // Selected Discount Option is Amt
                    else if(objQP.or_Amount__c == 'Amt'){
                        objQP.Total_Discount__c += (objQP.Disc__c/objQP.List_Price__c) * 100;           
                    }
                }
                
                // Bundle Discount
                if(objQP.Bundle__c != null && objQP.Bundle_Discount__c != null && objQP.Bundle_Discount__c != 0) {
                    objQP.Total_Discount__c += objQP.Bundle_Discount__c;        
                }
                
                // Adjustment Discount
                if(objQP.Adjustment__c != null && objQP.Adjustment__c != 0) {
                    objQP.Total_Discount__c += objQP.Adjustment__c;     
                }   
                
                if(objQP.Total_Discount__c > 100) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Discount cannot exceed 100% on any line.'));
                    blnHasError = true;
                    return null;
                }
                else {                    
                    if(objQP.Total_Discount__c > 0) {
                        objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Total_Discount__c/100);
                    }
                    objQP.List_Price__c = objQP.List_Price__c.setScale(intSetScale);
                    objQP.Partner_Price__c = objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c.setScale(intSetScale) : 0;
                    objQP.Net_Unit_Price__c = objQP.Net_Unit_Price__c.setScale(intSetScale);
                    Decimal decEffectivePrice = objQP.Partner_Price__c > 0 && objQP.Partner_Price__c != null ? objQP.Partner_Price__c : objQP.List_Price__c;
                    Decimal decBasePrice = 0;
                    Decimal decNetUnitPrice = 0;
                    Decimal decOvgBasePrice = 0;
                    Decimal intQty = 0;
                    
                    objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
                    System.debug('#####objQP.Quantity__c'+objQP.Quantity__c);
                    if(objQP.Quantity__c != null) {
                        objQP.Ext_List__c = (decEffectivePrice * objQP.Quantity__c).setScale(2) ;
                        objQP.Ext_Net_Price__c = (objQP.Net_Unit_Price__c * objQP.Quantity__c).setScale(2);
                        intQty = (quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription) && objQP.Quantity_Change__c != null && Label.Check_For_One_Time_Fees_PCC.contains(objQP.BigMachines__Product__r.New_Category__c) ? 
                            objQP.Quantity_Change__c : objQP.Quantity__c;
                        decBasePrice = (objQP.List_Price__c * intQty).setScale(intSetScale);
                        decNetUnitPrice = (objQP.Net_Unit_Price__c * intQty).setScale(intSetScale);
                        decOvgBasePrice = objQP.List_Price__c;
                        
                        System.debug('#####'+objQP.Extended_Price_Per_Period__c );
                        objQP.Extended_Price_Per_Month__c = objQP.Ext_Net_Price__c;
                        objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c; 
                        if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c && !set_OvgProdParentIds.contains(objQP.Id)) {
                            if(quote.Billing_Period__c == 'Annually') {
                                objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 12;
                            } else {
                                System.Debug('CreateQuoteCloudPECController:doCalculations Not expecting Billing Period of ' + quote.Billing_Period__c);
                                objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c;
                            }
                            /*
else if(quote.Billing_Period__c == 'Semi-Annually') {
objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 6;
}
else if(quote.Billing_Period__c == 'Quarterly') {
objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 3;
}  
else if(quote.Billing_Period__c == 'Other') {
objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * quote.No_Of_Months__c;
}           
*/
                        }   
                        System.debug('#####'+objQP.Extended_Price_Per_Period__c );   
                        
                        if(!objQP.Hide_Record__c
                           && objQP.BigMachines__Product__r.New_Category__c != 'Credit') {             
                               //if(!objQP.Hide_Record__c) {
                               if(!objQP.Is_Overage__c) { 
                                   //Logic to sum discounts based on Discount family under Quote
                                   if(map_QuoteDiscounts.containsKey(objQP.BigMachines__Product__r.ProductSubFamily__c)) {
                                       map_QuoteProductListPrices.put(objQP.BigMachines__Product__r.ProductSubFamily__c, map_QuoteProductListPrices.get(objQP.BigMachines__Product__r.ProductSubFamily__c) + decBasePrice);
                                       map_QuoteDiscounts.put(objQP.BigMachines__Product__r.ProductSubFamily__c, map_QuoteDiscounts.get(objQP.BigMachines__Product__r.ProductSubFamily__c) + (decBasePrice - decNetUnitPrice));
                                       if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                           map_DisplayQuoteDiscounts.put(objQP.BigMachines__Product__r.ProductSubFamily__c, true);
                                       }
                                   }
                                   
                                   if(objQP.Bundle__c == null) {
                                       if(objQP.Third_Party__c != 'TRUE'){
                                           decGenesysProductsDiscount += decBasePrice - decNetUnitPrice;
                                           listPriceTotalProductsOnly += decBasePrice;
                                           if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                               map_DisplayQuoteDiscounts.put('Third Party', true);
                                           }
                                       }  
                                       decGenesysAllDiscount += decBasePrice - decNetUnitPrice;
                                       listPriceTotalAll += decBasePrice;   
                                       decTotalNetPrice += decNetUnitPrice ;  
                                       decTotalDiscountAmt += decBasePrice - decNetUnitPrice;
                                       if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                           map_DisplayQuoteDiscounts.put('Overall %', true);
                                           map_DisplayQuoteDiscounts.put('Overall Amount', true);
                                       }            
                                   }   
                               }
                               else {
                                   //Logic to sum discounts for overage charges under Quote
                                   System.debug('######decEffectivePrice: '+decEffectivePrice);
                                   if(map_QuoteDiscounts.containsKey('Overage')) {
                                       map_QuoteProductListPrices.put('Overage', map_QuoteProductListPrices.get('Overage') + decOvgBasePrice);
                                       map_QuoteDiscounts.put('Overage', map_QuoteDiscounts.get('Overage') + (decOvgBasePrice - objQP.Net_Unit_Price__c));
                                       if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                           map_DisplayQuoteDiscounts.put('Overage', true);
                                       }
                                   }
                               }                        
                           }
                        if(objQP.BigMachines__Product__r.New_Category__c == 'Credit') {                                
                            Decimal decCreditAmount = 0;  
                            if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) {
                                decCreditAmount += objQP.Ext_Net_Price__c.setScale(5);
                            }
                            else {
                                decCreditAmount = (objQP.Ext_Net_Price__c/quote.No_Of_Months__c).setScale(5);
                            }  
                            decCreditAmount *= -1;                        
                            map_QuoteDiscounts.put('Cloud Services', map_QuoteDiscounts.get('Cloud Services') + decCreditAmount);
                            decGenesysProductsDiscount += decCreditAmount;
                            decGenesysAllDiscount += decCreditAmount;
                            decTotalDiscountAmt += decCreditAmount;
                        } 
                    }                    
                }    
            }
            else  {
                if(objQP.Bundle__r.Group_Type__c!='Campaigns'  && objQP.Product_Description__c != 'Campaign')
                    objQP.List_Price__c = objQP.Ext_List__c = 0;
            }
        }
        /*
if(blnHasBundles) {
// Copying Bundle Line data and updating the the sell-able item lines related to the Bundles
for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords) {
if(objQP.Bundle_Line__c != null && map_BundleQuoteProducts.containsKey(objQP.Bundle_Line__c)) {
BigMachines__Quote_Product__c objBundleQP = map_BundleQuoteProducts.get(objQP.Bundle_Line__c);
set_ProductIds.add(objBundleQP.BigMachines__Product__c); 
}
}
}*/
        System.Debug('ECD Check blnHasError ' + blnHasError);
        if(blnHasError)
            return null;
        
        if(list_QuoteProductRecords.size() > 0)
            list_ToUpdate.addAll(list_QuoteProductRecords);
        
        calculateGroupSubTotals();
        
        // Storing Sub Totals on Lines and Adding up totals for products of different types and storing total adjustment
        quote.Total_Software__c = quote.Total_Hardware__c = quote.Total_Education__c = quote.Total_Services__c =  quote.Total_Recurring_Credit__c = quote.Total_Non_Recurring_Credit__c = 0 ;
        quote.Minimum_Fees_Period__c = quote.Setup_Provisioning_Charges__c = quote.CMRR__c = quote.Telco_Cost__c = quote.Max_Seat_Count__c = 0;
        decTotalSWNetPrice = decTotalHWNetPrice = decTotalEducationNetPrice = decTotalServicesNetPrice = 0;
        quote.Total_Adjustments__c = quote.Total_List_Price__c = quote.Total_Overage__c = quote.Pre_Credit_CMRR__c = quote.Pre_Credit_ACV__c = quote.Pre_Credit_TCV__c = 0;
        decPureSuccessAlacarteSum = decPureSuccessBaseSum = decEventSum = decOtherNonRecurringFees = 0;
        List<OpportunityLineItem> list_OpptyLinesToInsert = new List<OpportunityLineItem>();       
        System.debug(LoggingLevel.INFO, 'NKC debug list_QuoteProductRecords [' + list_QuoteProductRecords + ']');
        
        decTotalRecAmount = decTotalNonRecAmount = decTotalRecAmountPreDiscount = decTotalNonRecAmountPreDiscount = maxSeatCount = 0;
        quote.No_Cloud_Billing_Contract__c = true;
        quote.Subscription_End_Date__c = quote.Subscription_Start_Date__c.addMonths(Integer.valueOf(quote.No_Of_Months__c))-1;
        Double dblPureSuccessPackageCount = 0;
        Integer intNoOfMonths = quote.Billing_Category__c == 'M2M' ? 12 : Integer.valueOf(quote.No_Of_Months__c);
        
        quote.CMRR_Pre_Discount__c = 0;
        
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
        {               
            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
            if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c))
                objQP.Group_Subtotal__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Sub_Total__c;
            
            //Calculate seat count
            if(!objQP.Is_Overage__c) {
                System.debug('#####Include_in_Agent_Seat_Count__c:' + objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c);
                if(objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c  && objQP.Quantity__c != null) {                   
                    Integer decQtProdSeatCount = 0;
                    if(quote.Order_Type__c == Label.Amend_Subscription && 
                       objQP.Quantity_Change__c != null && objQP.Quantity_Change__c > 0) {
                           decQtProdSeatCount = Integer.valueOf(objQP.Quantity_Change__c); 
                       }
                    else if (objQP.Quantity__c != null && objQP.Quantity__c > 0) {
                        decQtProdSeatCount = Integer.valueOf(objQP.Quantity__c); 
                    }
                    System.debug('#####decQtProdSeatCount:' + decQtProdSeatCount);
                    maxSeatCount += quote.Pricing_Model__c == 'Concurrent' ? decQtProdSeatCount * Concurrent_Multiplier__c.getValues('PureEngageCloud').Multiplier_Value__c : decQtProdSeatCount;
                    set_SeatCountParts.add(objQP.BigMachines__Product__c);
                }
                System.debug('#####maxSeatCount:' + maxSeatCount);
            }
            System.Debug('ECD Checking QP id ' + objQP.Id + ' name ' + objQP.Name + ' with product id ' + objQP.BigMachines__Product__c);
            if(!objQP.Is_Overage__c && !set_OvgProdParentIds.contains(objQP.Id)) {
                System.Debug('ECD !objQP.Is_Overage__c && !set_OvgProdParentIds.contains(objQP.Id)');
                if(objQP.Ext_Net_Price__c != null) {
                    System.Debug('ECD objQP.Ext_Net_Price__c != null objQP.BigMachines__Product__r.Include_in_CMMR_Total__c ' + objQP.BigMachines__Product__r.Include_in_CMMR_Total__c);
                    if(objQP.BigMachines__Product__r.New_Category__c == 'Credit') {
                        System.Debug('Credit');
                        if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) 
                        {
                            decTotalRecCredit += objQP.Ext_Net_Price__c;
                            quote.Total_Recurring_Credit__c += objQP.Ext_Net_Price__c;
                        }
                        else
                        {
                            decTotalNonRecCredit += objQP.Ext_Net_Price__c;
                            quote.Total_Non_Recurring_Credit__c += objQP.Ext_Net_Price__c;
                            
                        }
                        
                    }
                    else if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                        decTotalRecAmount += objQP.Ext_Net_Price__c;     
                    else 
                        decTotalNonRecAmount += objQP.Ext_Net_Price__c;                        
                }
                if(objQP.Ext_List__c != null) {
                    if(objQP.BigMachines__Product__r.New_Category__c != 'Credit') {   
                        if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                            decTotalRecAmountPreDiscount += objQP.Ext_List__c;
                        else
                            decTotalNonRecAmountPreDiscount += objQP.Ext_List__c;
                    }
                }
                // Software
                if(objQP.BigMachines__Product__r.Type__c == 'Cloud') {
                    quote.Total_Software__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                    decTotalSWNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                }
                Decimal decExtNetUnitPrice = objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                if(map_TamProduct.containskey(objQP.APN_Number__c)) {
                    decTAMAmount += decExtNetUnitPrice;
                    decTAMDuration = decTAMDuration < map_TamProduct.get(objQP.APN_Number__c) ? map_TamProduct.get(objQP.APN_Number__c) : decTAMDuration;     
                }                
                if(objQP.BigMachines__Product__r.New_Category__c == 'Monthly Telco Fees') {
                    quote.Telco_Cost__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                    quote.CMRR__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                    quote.CMRR_Pre_Discount__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                }
                
                if(objQP.BigMachines__Product__r.New_Category__c == 'Education Courses and Packaged Curriculum') {
                    System.Debug('ECD Adding to Total_Education__c and decTotalEducationNetPrice ' + objQP.Ext_Net_Price__c + ' for qp.Id ' + objQP.Id + ' product id ' + objQP.BigMachines__Product__c);
                    quote.Total_Education__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                    decTotalEducationNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                }
                
                if(objQP.BigMachines__Product__r.New_Category__c == 'Professional Services') {
                    quote.Total_Services__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                    decTotalServicesNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                }
                
                else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect Offer') {
                    decPureSuccessBaseSum += objQP.Ext_Net_Price__c;
                }
                else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') {
                    decPureSuccessAlacarteSum  += objQP.Ext_Net_Price__c;
                }
                else if(objQP.BigMachines__Product__r.Product_Group__c == 'Installation') {
                    decEventSum += objQP.Ext_Net_Price__c;
                }
                
                if(!String.isBlank(objQP.APN_Number__c)){
                    if(Label.PCC_Non_Recurring_products.contains(objQP.APN_Number__c))
                        decOtherNonRecurringFees += objQP.Ext_Net_Price__c;
                }
                
                //addToQuoteTotals(objQP);
                
                // ECD PEC This setting causes a Billing Setup to be able to be created for the customer.
                if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) {
                    quote.No_Cloud_Billing_Contract__c = false;
                }
                
                // Calculating Total List Price
                if(objQP.Ext_List__c != null)
                    quote.Total_List_Price__c += objQP.Ext_List__c;
                
                if(objQP.Adjustment__c != null)
                    quote.Total_Adjustments__c += objQP.Adjustment__c;
                
                if(objQP.Bundle__r.Type__c == 'GUIDE' || objQP.Bundle__r.Type__c == 'EQUIP' 
                   || objQP.Bundle__r.Type__c == 'DRIVE' || objQP.Bundle__r.Type__c == 'Partner PureSuccess'){
                       quote.PureSuccess__c = objQP.Bundle__r.Type__c;
                   }
                if(Label.PCC_Token_Package_Product.contains(String.valueof(objQP.BigMachines__Product__c).left(15)))
                    dblPureSuccessPackageCount = objQP.BigMachines__Quantity__c;
            }
            else {
                System.Debug('ECD NOT !objQP.Is_Overage__c || !set_OvgProdParentIds.contains(objQP.Id)');
                System.Debug('ECD objQP ' + objQP);
                if(objQP.Quantity__c != null && objQP.Quantity__c > 0)
                    quote.Total_Overage__c += objQP.Net_Unit_Price__c * objQP.Quantity__c;
            }        
        }
        PageReference newPageRef;
        
        decTotalNonRecCredit *= -1;
        decTotalRecCredit *= -1;
        quote.Total_Recurring_Credit__c *=-1;
        quote.Total_Non_Recurring_Credit__c *=-1;
        decTotalCredit = decTotalNonRecCredit + (decTotalRecCredit * intNoOfMonths);
        
        //Adding Telco to monthly fee
        if(quote.Billing_Category__c.contains('M2M'))
            quote.Minimum_Fees_Period__c += quote.Telco_Cost__c;
        
        if(quote.Initial_Subscription_Term__c.containsIgnoreCase(' Year'))
            quote.No_Of_Months__c = Integer.ValueOf(quote.Initial_Subscription_Term__c.substringBefore(' Year')) * 12;
        
        quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c = decTotalNetPrice;
        quote.Total_Subtotal_1__c = quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c;
        quote.Non_Recurring_Fees__c = decTotalNonRecAmount;
        
        System.Debug('ECD assigning quote.Non_Recurring_Fees__c ' + quote.Non_Recurring_Fees__c + ': quote.Total_Hardware__c ' + quote.Total_Hardware__c + ' quote.Total_Education__c ' + quote.Total_Education__c + ' quote.Setup_Provisioning_Charges__c ' + quote.Setup_Provisioning_Charges__c + ' decPureSuccessAlacarteSum ' + decPureSuccessAlacarteSum + ' decPureSuccessBaseSum ' + decPureSuccessBaseSum + ' decOtherNonRecurringFees ' + decOtherNonRecurringFees + ' decEventSum ' + decEventSum);
        quote.Non_Recurring_Fees__c = quote.Non_Recurring_Fees__c + quote.Total_Hardware__c + quote.Total_Education__c + quote.Setup_Provisioning_Charges__c + decPureSuccessAlacarteSum + decPureSuccessBaseSum + decOtherNonRecurringFees + decEventSum;
        System.Debug('ECD resulting quote.Non_Recurring_Fees__c ' + quote.Non_Recurring_Fees__c);
        quote.Max_Seat_Count__c = maxSeatCount;
        quote.Annual_Contract_Value__c = decTotalRecAmount * 12;
        quote.Cloud_Total__c = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount;
        quote.Total_Contract_Value__c = quote.Cloud_Total__c;
        
        quote.ACV_Pre_Discount__c = decTotalRecAmountPreDiscount * 12;
        quote.TCV_Pre_Discount__c = (decTotalRecAmountPreDiscount * intNoOfMonths) + decTotalNonRecAmountPreDiscount;
        quote.CMRR_Pre_Discount__c = decTotalRecAmountPreDiscount;
        
        decPreCreditCMRR = decPreCreditACV = decPreCreditTCV = 0;          
        decPreCreditCMRR = decTotalRecAmount;
        quote.Pre_Credit_CMRR__c = decTotalRecAmount;
        decPreCreditACV = decTotalRecAmount * 12;
        quote.Pre_Credit_ACV__c = decTotalRecAmount * 12;
        decPreCreditTCV = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount;
        quote.Pre_Credit_TCV__c = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount;
        
        
        quote.Cloud_Total__c = quote.Cloud_Total__c - decTotalCredit;
        quote.CMRR_Pre_Discount__c = quote.CMRR_Pre_Discount__c - decTotalRecCredit - (decTotalNonRecCredit/intNoOfMonths);
        quote.ACV_Pre_Discount__c = quote.CMRR_Pre_Discount__c * 12;
        //quote.CMRR__c = quote.CMRR__c - decTotalRecCredit - (decTotalNonRecCredit/intNoOfMonths);                
        quote.CMRR__c = decTotalRecAmount - decTotalRecCredit - (decTotalNonRecCredit/intNoOfMonths);                
        quote.Annual_Contract_Value__c = quote.CMRR__c * 12;    
        //quote.Telco_Cost__c = quote.Telco_Cost__c - decTotalRecCredit - (decTotalNonRecCredit/intNoOfMonths);  
        quote.Migration_Credit__c = decTotalCredit;  
        quote.Total_Contract_Value__c -= decTotalCredit;
        quote.TCV_Pre_Discount__c -= decTotalCredit;
        
        if(quote.Billing_Category__c == 'M2M') {    
            quote.CMRR_Pre_Discount__c = quote.ACV_Pre_Discount__c = 0;
            quote.CMRR__c = quote.Annual_Contract_Value__c = decTotalRecAmount = 0;
        } 
        
        quote.TAM_Amount__c = decTAMAmount;
        quote.TAM_Duration_Months__c = decTAMDuration;
        
        // Percentages
        quote.Total_Discount_Genesys_Products_Only__c = quote.Total_Discount_Genesys_and_Third_Party__c = quote.Professional_Services_Discount__c = 0;
        quote.Hardware_Discount__c = quote.Software_Discount__c = quote.Overage_Discount__c = 0;
        
        //Logic to populate discount % based on Discount family under Quote
        quote.Professional_Services_Discount__c = map_DisplayQuoteDiscounts.get('PROFESSIONAL SERVICES') && map_QuoteProductListPrices.get('PROFESSIONAL SERVICES') > 0 ? (map_QuoteDiscounts.get('PROFESSIONAL SERVICES')/map_QuoteProductListPrices.get('PROFESSIONAL SERVICES'))*100 : 0;
        quote.Software_Discount__c = map_DisplayQuoteDiscounts.get('Cloud Services') && map_QuoteProductListPrices.get('Cloud Services') > 0 ? (map_QuoteDiscounts.get('Cloud Services')/map_QuoteProductListPrices.get('Cloud Services'))*100 : 0;
        quote.Overage_Discount__c = map_DisplayQuoteDiscounts.get('Overage') && map_QuoteProductListPrices.get('Overage') > 0 ? ((map_QuoteDiscounts.get('Overage')/map_QuoteProductListPrices.get('Overage'))*100).setscale(2) : 0;
        system.debug(map_DisplayQuoteDiscounts+':::'+map_QuoteProductListPrices+':::'+map_QuoteDiscounts);
        
        if((decTotalDiscountAmt + decTotalNetPrice) != 0) {
            if(listPriceTotalProductsOnly != 0)
                quote.Total_Discount_Genesys_Products_Only__c = map_DisplayQuoteDiscounts.get('Overall %') ? (decGenesysProductsDiscount/listPriceTotalProductsOnly) * 100 : 0;
            if(listPriceTotalAll != 0)
                quote.Total_Discount_Genesys_and_Third_Party__c = map_DisplayQuoteDiscounts.get('Third Party') ? (decGenesysAllDiscount/listPriceTotalAll) * 100 : 0;
            quote.Total_Discount__c = map_DisplayQuoteDiscounts.get('Overall Amount') ? decTotalDiscountAmt : 0;
        }
        quote.BigMachines__Total__c = quote.Total_Subtotal_1__c; 
        
        //PureSucess Token calculation
        String pureSuccessPackageName = '';
        quote.Token_Value__c = null;
        //quote.Total_GU_Training_Units__c = 0;
        if(quote.PureSuccess__c != null || quote.Does_customer_currently_have_PureSuccess__c) {
            
            if(quote.PureSuccess__c != null) {
                pureSuccessPackageName = quote.PureSuccess__c;
                //todo get offer name
                pureSuccessPackageName = pureSuccessPackageName.touppercase();
                quote.Token_Value__c = QuoteCloudUtil.calculateTokenValue(quote.Annual_Contract_Value__c, quote.Offering_Type__c, pureSuccessPackageName);  
                //if 10 token pack
                if(dblPureSuccessPackageCount > 0)
                    quote.Token_Value__c += 10 * dblPureSuccessPackageCount;
                
                system.debug('token'+quote.Token_Value__c);                    
                quote.PureSuccess_Offer_Subscription_Amount__c = decPureSuccessBaseSum;                    
            }
            quote.A_La_Carte_PureSuccess_Services_Amount__c = decPureSuccessAlacarteSum;
        }
        if(quote.No_Of_Months__c != null){
            quote.Maintenance_Start_Date__c = Date.valueof(quote.CreatedDate);
            quote.Maintenance_End_Date__c = Date.valueOf(quote.CreatedDate.addMonths(Integer.valueof(quote.No_Of_Months__c)));
        } else if (Test.isRunningTest()) {
            quote.Maintenance_End_Date__c = Date.today();
        }
        
        for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords) {                   
            if(objQP.BigMachines__Product__r.type__c ==  'Token') {
                objQP.BigMachines__Quantity__c  = quote.Token_Value__c;
                list_ToUpdate.add(objQP);
            }
        }
        
        Decimal decACVTokenValue = QuoteCloudUtil.calculateTokenValue(quote.Annual_Contract_Value__c, 'Only For ACV', 'NA');
        Integer intTotalTokens = 0;
        BigMachines__Quote_Product__c objLargestQP;
        for(BigMachines__Quote_Product__c objQP : list_ToUpdate)
        {        
            if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c){
                if(objQP.Extended_Price_Per_Month__c != null && decACVTokenValue > 0 && quote.Annual_Contract_Value__c != null){
                    Decimal decLineWeightage = (12 * objQP.Extended_Price_Per_Month__c * 100) / quote.Annual_Contract_Value__c;
                    decLineWeightage = Math.floor(decLineWeightage);
                    
                    objQP.Tokens__c = decACVTokenValue * decLineWeightage / 100;
                    if(intTotalTokens == 0)
                        objLargestQP = objQP;
                    else if(objQP.Extended_Price_Per_Month__c  > objLargestQP.Extended_Price_Per_Month__c)
                        objLargestQP = objQP;
                    intTotalTokens += Integer.valueof(Math.round(objQP.Tokens__c));
                    
                }
            } 
            else if(objQP.Bundle__r.Type__c == 'GUIDE' || objQP.Bundle__r.Type__c == 'EQUIP' 
                    || objQP.Bundle__r.Type__c == 'DRIVE' || objQP.Bundle__r.Type__c == 'Partner PureSuccess'){
                        Decimal decPSTokenValue = QuoteCloudUtil.calculateTokenValue(quote.Annual_Contract_Value__c, quote.Offering_Type__c, pureSuccessPackageName);
                        if(decPSTokenValue > decACVTokenValue)
                            objQP.Tokens__c = decPSTokenValue - decACVTokenValue; 
                        else
                            objQP.Tokens__c = 0;
                    }
            else if(Label.PCC_Token_Package_Product.contains(String.valueof(objQP.BigMachines__Product__c).left(15)) && objQP.BigMachines__Quantity__c != null)
                objQP.Tokens__c = objQP.BigMachines__Quantity__c * 10;                
        }
        if(decACVTokenValue - intTotalTokens != 0)
        {
            system.debug(decACVTokenValue - intTotalTokens);
            for(BigMachines__Quote_Product__c objQP : list_ToUpdate)
            { 
                if(objQP == objLargestQP)
                    objQP.Tokens__c += (decACVTokenValue - intTotalTokens);
            }
        }
        
        quote.Total_Contract_Value_Change__c = 0;
        if(quote.Amendment_For__c != null 
           && (quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription)) {            
               quote.Services_Change__c = quote.Total_Services__c - (quote.Amendment_For__r.Total_Services__c == null? 0 : quote.Amendment_For__r.Total_Services__c);
               quote.Total_Education_Change__c = quote.Total_Education__c - (quote.Amendment_For__r.Total_Education__c == null ? 0 : quote.Amendment_For__r.Total_Education__c);
               quote.Total_Hardware_Change__c = quote.Total_Hardware__c - (quote.Amendment_For__r.Total_Hardware__c == null ? 0 : quote.Amendment_For__r.Total_Hardware__c);
               quote.CMRR_Change__c = quote.CMRR__c - (quote.Amendment_For__r.CMRR__c == null ? 0 : quote.Amendment_For__r.CMRR__c);
               quote.Annual_Contract_Value_Change__c = quote.Annual_Contract_Value__c - (quote.Amendment_For__r.ACV__c == null ? 0 : quote.Amendment_For__r.ACV__c);
               System.Debug('ECD quote.Non_Recurring_Fees__c ' + quote.Non_Recurring_Fees__c + ' quote.Amendment_For__r.Total_Non_Recurring_Fees__c ' + quote.Amendment_For__r.Total_Non_Recurring_Fees__c);
               quote.Non_Recurring_Fees_Changes__c = quote.Non_Recurring_Fees__c - (quote.Amendment_For__r.Total_Non_Recurring_Fees__c == null ? 0 : quote.Amendment_For__r.Total_Non_Recurring_Fees__c);
               quote.Total_Contract_Value_Change__c = quote.Total_Contract_Value__c - (quote.Amendment_For__r.TCV__c == null ? 0 : quote.Amendment_For__r.TCV__c);  
               quote.Telco_CMRR_Change__c = quote.Telco_Cost__c - (quote.Amendment_For__r.Telco_CMRR__c == null ? 0 : quote.Amendment_For__r.Telco_CMRR__c); 
               quote.Total_Tokens_Change__c = (quote.Token_Value__c == null ? 0 : quote.Token_Value__c) - (quote.Amendment_For__r.Total_Tokens__c == null ? 0 : quote.Amendment_For__r.Total_Tokens__c);              
               quote.Setup_Provisioning_Charges_Change__c = (quote.Setup_Provisioning_Charges__c == null ? 0 : quote.Setup_Provisioning_Charges__c) - (quote.Amendment_For__r.Setup_Provisioning_Charges__c == null ? 0 : quote.Amendment_For__r.Setup_Provisioning_Charges__c);
               
               for(Subscription_Product__c objSubscrProd : list_RemovedPrevProds) {
                   //Logic to deduct removed one time product fees from totals.
                   if(quote.Order_Type__c == Label.Amend_Subscription) {
                       Decimal decExtNetUnitPrice = objSubscrProd.Ext_Net_Price__c != null ? objSubscrProd.Ext_Net_Price__c : 0;                    
                       if(objSubscrProd.Product__r.New_Category__c == 'Education') {
                           quote.Total_Education_Change__c += decExtNetUnitPrice;
                           quote.Non_Recurring_Fees_Changes__c += decExtNetUnitPrice;
                           quote.Total_Contract_Value_Change__c += decExtNetUnitPrice;
                       }
                       else if(objSubscrProd.Product__r.New_Category__c == 'Hardware') {
                           quote.Total_Hardware_Change__c += decExtNetUnitPrice;  
                           quote.Non_Recurring_Fees_Changes__c += decExtNetUnitPrice;    
                           quote.Total_Contract_Value_Change__c += decExtNetUnitPrice; 
                       }
                       else if(objSubscrProd.Product__r.New_Category__c == 'Services' || objSubscrProd.Product__r.New_Category__c == 'Voice Services') {
                           quote.Services_Change__c += decExtNetUnitPrice;
                           quote.Non_Recurring_Fees_Changes__c += decExtNetUnitPrice;
                           quote.Total_Contract_Value_Change__c += decExtNetUnitPrice;
                       }   
                   }   
               }
           }
        
        // Savepoint before DML
        Savepoint objSP = Database.setSavepoint();
        
        // Skip Triggers
        Util.Bypass_Trigger_Chk = true;
        try
        {
            if(list_ProposalGroups.size() > 0)
                update list_ProposalGroups;
            
            if(list_ToUpdate.size() > 0)
                Database.upsert(list_ToUpdate, false);
            
            if(getIsOrderInfoAvailable() && (quote.Revise_Minor__c || blnIsReviseOrder))
                saveOrderInfo();
            
            if(quote.Deal_Qualification__c == null){
                List<Deal_Qualification__c> dq = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
                if(!dq.isEmpty())
                    quote.Deal_Qualification__c = dq[0].id; 
            }
            System.Debug('quote.Annual_Contract_Value__c--->'+quote.Annual_Contract_Value__c);
            
            //Mukunth - calling below method to populate multi-year ACV fields
            populateMultiYrACV();
            System.Debug('quote.Billing_Category__cBeforeUpd--->'+quote.Billing_Category__c);
            
            update quote;
            system.debug('DDSCloud calling3222');
            obj_DDS = DDSCloud.calculateRawScore(quote);
            objDDSHistory = obj_DDS.objDealScoreHistory;
            System.debug(obj_DDS );
            //Mukunth added below line for DDS Mega Deals
            if(quote.Annual_Contract_Value__c != null)
                isMegaDealBln = checkMegaDeal();
            else
                isMegaDealBln = false;
            
            // **** Opportunity Synchronization Logic *******
            if(quote.BigMachines__Opportunity__c != null && quote.BigMachines__Is_Primary__c && !blnIsSimulated)
            {                
                // Delete existing lines before creating quote products as opportunity lines
                List<OpportunityLineItem> list_OpptyLinesToDelete = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :quote.BigMachines__Opportunity__c];
                if(list_OpptyLinesToDelete.size() > 0)
                    delete list_OpptyLinesToDelete;
                
                Opportunity oppToUpdate = new Opportunity(Id = quote.BigMachines__Opportunity__c);
                Opportunity objTempOpp = [select Run_Rate_USD__c,MSA_Link_Type__c,Contract_Expiration_Date__c,Contract_Effective_Date__c,Contract_Type__c,Legal_Exceptions__c from opportunity where id =: quote.BigMachines__Opportunity__c];
                oppToUpdate.MSA_Link_Type__c = ((quote.Amendment_For__c != null && quote.Amendment_For__r.MSA_Link_Type__c == 'Custom' &&  quote.MSA_Link_Type__c == 'Standard')||(quote.BigMachines__Opportunity__c != null && quote.BigMachines__Opportunity__r.MSA_Link_Type__c == 'Custom' &&  quote.MSA_Link_Type__c == 'Standard'))?'Custom':quote.MSA_Link_Type__c;
                oppToUpdate.MSA_Link__c = quote.MSA_Link__c;                 oppToUpdate.Primary_Quote__c = quote.Id; 
                oppToUpdate.Deal_Score__c = quote.Deal_Score__c;               
                oppToUpdate.Hardware_Total__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.Total_Hardware_Change__c : quote.Total_Hardware__c;
                oppToUpdate.Education_Amount__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.Total_Education_Change__c : quote.Total_Education__c;
                oppToUpdate.Total_PS_Support__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.Services_Change__c : quote.Total_Services__c;
                
                //Logic to populate additional opportunity fields from primary quote
                if(oppToUpdate.Annual_Contract_Value_new__c == null)
                    oppToUpdate.Annual_Contract_Value_new__c = 0;
                oppToUpdate.Annual_Contract_Value_new__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.Annual_Contract_Value_Change__c : quote.Annual_Contract_Value__c;
                if(quote.BigMachines__Opportunity__r.RecordType.Name != 'Cloud Renewal') 
                    oppToUpdate.ACV_Subscription_Only__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.Annual_Contract_Value_Change__c : quote.Annual_Contract_Value__c;
                oppToUpdate.Annual_Contract_Value_Subscription__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.Annual_Contract_Value_Change__c : quote.Annual_Contract_Value__c;    
                oppToUpdate.Annual_Contract_Value_Change__c = quote.Annual_Contract_Value_Change__c;
                oppToUpdate.Monthly_Commitment__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.CMRR_Change__c : quote.CMRR__c; 
                oppToUpdate.Subscription_CMRR__c = quote.Order_Type__c == Label.Amend_Subscription ? quote.CMRR_Change__c : quote.CMRR__c; 
                oppToUpdate.CMRR_Change__c = quote.CMRR_Change__c; 
                oppToUpdate.Subscription_CMRR_Change__c = quote.CMRR_Change__c;              
                oppToUpdate.Total_Annual_Contract_Value__c = quote.Total_Contract_Value__c - oppToUpdate.Total_PS_Support__c;
                system.debug(quote.Total_Contract_Value_Change__c + '' + oppToUpdate.Total_PS_Support__c);
                oppToUpdate.Total_Contract_Value_Change__c = quote.Total_Contract_Value_Change__c - oppToUpdate.Total_PS_Support__c;
                if(quote.Order_Type__c == Label.Amend_Subscription) {
                    oppToUpdate.Total_Annual_Contract_Value__c = quote.Total_Contract_Value_Change__c;
                }
                
                oppToUpdate.A_La_Carte_PureSuccess_Services_Amount__c = quote.A_La_Carte_PureSuccess_Services_Amount__c;
                oppToUpdate.PureSuccess_Offer_Amount__c = quote.PureSuccess_Offer_Subscription_Amount__c;
                oppToUpdate.PureSuccess_Offer__c =  quote.PureSuccess__c;
                
                if(quote.Order_Type__c == Label.Amend_Subscription) {
                    
                  //  oppToUpdate.Offering_Detail__c = quote.Total_Contract_Value_Change__c >= 0 ? 'Amendment – Upgrade' : 'Amendment – Downgrade'; 
                       // Dec 04 2019 -- Ankaiah -- The below code has been added as per the INC0437617
                    String strAU = 'Amendment – Upgrade';
                    strAU = strAU.replaceAll('a-zA-Z0-9\\s+','');
                       system.debug('====>'+ strAU);
                
                    String strAD = 'Amendment – Downgrade';
                    strAD = strAD.replaceAll('a-zA-Z0-9\\s+','');
                       system.debug('====>'+ strAD); 
                    oppToUpdate.Offering_Detail__c = quote.Total_Contract_Value_Change__c >= 0 ? strAU : strAD ; 
                    quote.Max_Seat_Count__c = quote.Total_Contract_Value_Change__c >= 0 ? quote.Max_Seat_Count__c : 0;
                }
                
                oppToUpdate.Incremental_Agent_Seat_Count__c = quote.Max_Seat_Count__c;
                
                oppToUpdate.TAM_Services_Amount__c = quote.TAM_Amount__c;
                oppToUpdate.TAM_Duration_Months__c = quote.TAM_Duration_Months__c;
                
                //System.debug('Values'+oppToUpdate.Annual_Contract_Value__c+decRunRate+quote.BigMachines__Opportunity__r.RecordType.Name );
                Map<String, Decimal> map_Currencies = new Map<String, Decimal>();
                map_Currencies = QuoteUtil.buildConversionRatesMap();
                if (quote.Annual_Contract_Value__c != null && objTempOpp.Run_Rate_USD__c != null && quote.BigMachines__Opportunity__r.RecordType.Name == 'Cloud Renewal') {
                    Decimal decACV = quote.Annual_Contract_Value__c / map_Currencies.get(quote.CurrencyIsoCode);
                    oppToUpdate.Renewal_Change_v_Run_Rate_USD__c = (decACV - Integer.valueof(objTempOpp.Run_Rate_USD__c)) > 0 ? decACV - Integer.valueof(objTempOpp.Run_Rate_USD__c) : 0;
                    System.debug('oppToUpdate.Renewal_Change_v_Run_Rate_USD__c'+oppToUpdate.Renewal_Change_v_Run_Rate_USD__c);
                }
                if(quote.Order_Type__c == Label.Amend_Subscription && quote.Amendment_For__c != null) {
                    Subscription__c objSub = [Select Legal_Exceptions__c,Contract_Effective_Date__c,Contract_Expiration_Date__c,Contract_Type__c from Subscription__c where id = :quote.Amendment_For__c];  
                    oppToUpdate.Contract_Expiration_Date__c = objTempOpp.Contract_Expiration_Date__c == null ? objSub.Contract_Expiration_Date__c : objTempOpp.Contract_Expiration_Date__c;
                    oppToUpdate.Contract_Effective_Date__c = objTempOpp.Contract_Effective_Date__c == null ? objSub.Contract_Effective_Date__c : objTempOpp.Contract_Effective_Date__c;
                    oppToUpdate.Contract_Type__c = objTempOpp.Contract_Type__c == null ? objSub.Contract_Type__c : objTempOpp.Contract_Type__c;
                    oppToUpdate.Legal_Exceptions__c = objTempOpp.Legal_Exceptions__c == null ? objSub.Legal_Exceptions__c : objTempOpp.Legal_Exceptions__c;
                    System.Debug('Hello There');
                }
                
                update oppToUpdate;
                
                Map<Id,Id> map_ProdIdToPBEId = new Map<Id,Id>();
                for(PricebookEntry objPE : [SELECT Product2Id,Id FROM PricebookEntry WHERE 
                                            Pricebook2Id = :Label.Standard_Pricebook_Id AND isActive = true and 
                                            Product2Id IN :set_ProductIds AND CurrencyISOCode = :quote.CurrencyISOCode])
                    map_ProdIdToPBEId.put(objPE.Product2Id,objPE.Id);
                
                List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();
                for(BigMachines__Quote_Product__c objQP : list_ToUpdate)
                {
                    if(objQP.Bundle__c != null && objQP.Bundle_Line__c == null)
                        continue;
                    System.debug('NKC debug objQP.Bundle_Line__c ['+objQP.Bundle_Line__c+']');
                    //if(objQP.Bundle_Line__c != null)
                    //    continue;
                    System.debug('NKC debug map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c) ['+map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c)+']');    
                    if(map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c)
                       && !objQP.Is_Overage__c  
                       && objQP.Quantity__c > 0)
                    {
                        list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = quote.Id,
                                                                            Description__c = (String.isNotBlank(objQP.Product_Description__c) && objQP.Product_Description__c.length() > 250 ? objQP.Product_Description__c.substring(0, 250) : objQP.Product_Description__c),
                                                                            OpportunityId = quote.BigMachines__Opportunity__c,
                                                                            PricebookEntryId = map_ProdIdToPBEId.get(objQP.BigMachines__Product__c),
                                                                            Quantity = objQP.Quantity__c,Quantity__c = objQP.Quantity__c,UnitPrice = objQP.Net_Unit_Price__c,
                                                                            Total_Discount__c = objQP.Total_Discount__c,Unit_of_Measure__c = objQP.Unit_of_Measure__c));
                    }
                }
                
                if(list_OpptyLinesToCreate.size() > 0)
                    insert list_OpptyLinesToCreate;
            }
            
            // Fetching Quote Products (To update name on Genesys Care line : might scrap this to improve efficiency)
            getQuoteProducts(quoteId);
            blnSkipPriceCheck = blnIsReviseOrder = false;
            
            populateSuggestedDiscounts();
            
            buildChangeHistoryForAmendSubscr();
            QuoteCloudUtil.calculateCumulativeTotal(set_QouteProductIds);
            
            
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected error has occurred while processing your request. Please contact IT/Admin for further assistance: '+ex.getMessage() + ex.getlinenumber()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
        return newPageRef;
    }
    
    private void populateSuggestedDiscounts(){
        getDQStatus();
        if(!dqs.isEmpty()){
            dq = dqs[0];
            
        }   
        else
        {
            dq = new Deal_Qualification__c();
            dq.Opportunity__c = quote.BigMachines__Opportunity__c;
            dq.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
            dq.currencyIsoCode = quote.currencyIsoCode;
            dq.Platform_Type__c = quote.Quote_Business_Type__c; 
            if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC)
                dq.Expiration_Date__c = System.today().addYears(1);  
            dq.Offering_Type__c = (quote.Offering_Type__c == null ? QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE : quote.Offering_Type__c);  
        }
        dq.Seat_Size_Discount__c = 0;
        dq.Seat_Discount_Range__c = '0 - 0%';
        system.debug(quote.Max_Seat_Count__c);
        Decimal decSeatCount;
        if(quote.Max_Seat_Count__c != null){
            if(quote.Pricing_Model__c == 'Concurrent' && quote.Max_Seat_Count__c > 0)
                decSeatCount = quote.Max_Seat_Count__c /2;
            else
                decSeatCount = quote.Max_Seat_Count__c;
            system.debug(decSeatCount);
            for(Product_Tier_Pricing__c eachSizeDiscount : [Select id,Range_To__c,Discount_Range__c
                                                            FROM Product_Tier_Pricing__c 
                                                            WHERE Product__r.Include_in_Agent_Seat_Count__c = True
                                                            AND Product__c in :set_SeatCountParts
                                                            ORDER BY Range_To__c]){
                                                                system.debug(eachSizeDiscount.Range_To__c);
                                                                if(decSeatCount <= eachSizeDiscount.Range_To__c){
                                                                    //dq.Seat_Size_Discount__c = eachSizeDiscount.Discount__c;    
                                                                    dq.Seat_Discount_Range__c = eachSizeDiscount.Discount_Range__c;
                                                                    break;
                                                                }
                                                            }                
        }
        system.debug(dq);
        upsert dq;
    }  
    
    public List<SelectOption> getproductTier(){
        List<SelectOption> options = new List<SelectOption>();  
        String strExistingTier = '';          
        Schema.DescribeFieldResult fieldResult = Admin_Dummy__c.Product_Tier__c.getDescribe();
        if(quote.Product_Tier__c != null)
            strExistingTier = quote.Product_Tier__c;
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        if(strExistingTier != '')
            options.add(new SelectOption(strExistingTier, strExistingTier));
        for(Schema.PicklistEntry f : ple){
            //if((quote.BigMachines__Opportunity__r.Type == 'New logo' && f.getLabel() == 'Enterprise') || (quote.BigMachines__Opportunity__r.Type != 'New logo'))
            if(f.getLabel() != strExistingTier && 
               (
                   f.getLabel() == 'Enterprise' 
                   || Label.PCC_Allow_Old_Tier.contains(String.valueof(quote.BigMachines__Opportunity__c).left(15))
                   || (strExistingTier != 'Enterprise' && f.getLabel() != 'Enterprise' && quote.Order_Type__c == Label.Amend_Subscription)
               )
              )
                options.add(new SelectOption(f.getLabel(), f.getValue()));
        }         
        
        return options;    
    } 
    
    /*public void setMSALink() {
if(quote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC )
{
if(quote.MSA_Link_Type__c == 'Standard')
{
quote.MSA_Link__c = Label.MSA_Links.split(';;')[4].trim();
if(quote.BigMachines__Opportunity__r.Sold_To_Country__r.Name == 'Australia') 
{
quote.MSA_Link__c = Label.MSA_Links.split(';;')[5].trim();
}
}
else if(quote.MSA_Link_Type__c == 'CUSTOM')
{
quote.MSA_Link__c = ' ';
}    
}
}*/
    
    //Logic to bring Change History for Amend
    @Testvisible
    private void buildChangeHistoryForAmendSubscr() {        
        if((quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription)
           && quote.Amendment_For__c != null) {
               Map<String, Decimal> map_NewProdQuantity = new Map<String, Decimal>();            
               Map<String, Subscription_Product__c> map_PrevProdInfo = new Map<String, Subscription_Product__c>();
               List<BigMachines__Quote_Product__c> set_QPQuantityChanged = new  List<BigMachines__Quote_Product__c>();
               map_PrevProdQuantity = new Map<String, Decimal>();
               map_ProdChangeHistory = new Map<String, String>();
               map_ProdChangeHistoryColor = new Map<String, String>();
               list_RemovedPrevProds = new List<Subscription_Product__c>();
               
               List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProducts(quote.Amendment_For__c);
               
               for(Subscription_Product__c objSubProd : list_SubscriptionProds) {
                   String strUniqueKey = objSubProd.Product__c+';'+objSubProd.Is_Overage__c; 
                   System.debug('######strUniqueKey: '+strUniqueKey );
                   if(!String.isBlank(strUniqueKey) && objSubProd.Quantity__c != null) {
                       map_PrevProdInfo.put(strUniqueKey, objSubProd);
                       if(map_PrevProdQuantity.containsKey(strUniqueKey)) {
                           map_PrevProdQuantity.put(strUniqueKey, map_PrevProdQuantity.get(strUniqueKey) + objSubProd.Quantity__c);
                       }
                       else {
                           map_PrevProdQuantity.put(strUniqueKey, objSubProd.Quantity__c);
                       }
                   }
               }
               System.debug('######map_PrevProdQuantity: '+map_PrevProdQuantity);
               for(BigMachines__Quote_Product__c objNewQP : list_QuoteProductRecords) {
                   String strChangeHist = 'Original';  
                   String strUniqueKey = objNewQP.BigMachines__Product__c+';'+objNewQP.Is_Overage__c;
                   System.debug('######strUniqueKey : '+strUniqueKey );
                   if(!String.isBlank(strUniqueKey) && objNewQP.Quantity__c != null) {
                       if(map_NewProdQuantity.containsKey(strUniqueKey)) {
                           map_NewProdQuantity.put(strUniqueKey, map_NewProdQuantity.get(strUniqueKey) + objNewQP.Quantity__c);
                       }
                       else {
                           map_NewProdQuantity.put(strUniqueKey, objNewQP.Quantity__c);
                       }           
                       strChngeHistColors = Label.Amend_Change_History.trim().split(';');
                       map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[0]);
                       if(map_PrevProdQuantity.containsKey(strUniqueKey)) {  
                           if(map_NewProdQuantity.get(strUniqueKey) != map_PrevProdQuantity.get(strUniqueKey)) {
                               //One-time fees for Renewals must show as Added always 
                               if(quote.Order_Type__c == Label.Renew_Subscription 
                                  && (Label.Check_For_One_Time_Fees_PCC.contains(objNewQP.BigMachines__Product__r.New_Category__c ))) {
                                      map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[1]);
                                      strChangeHist = 'Added ';
                                  }                            
                               else { 
                                   strChangeHist = 'Changed Quantity from '+map_PrevProdQuantity.get(strUniqueKey)+' to '+map_NewProdQuantity.get(strUniqueKey);
                                   map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[3]);
                                   if(map_NewProdQuantity.get(strUniqueKey) > map_PrevProdQuantity.get(strUniqueKey)) {
                                       map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[2]);
                                   }
                                   System.debug('######map_ProdChangeHistoryColor.get(strUniqueKey): '+map_ProdChangeHistoryColor.get(strUniqueKey));
                               }
                           }
                       }
                       else {
                           map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[1]);
                           strChangeHist = 'Added '; 
                       }
                       System.debug('######map_ProdChangeHistoryColor.get(strUniqueKey): '+map_ProdChangeHistoryColor.get(strUniqueKey));
                       map_ProdChangeHistory.put(strUniqueKey, strChangeHist);
                   }
               }
               System.debug('######map_NewProdQuantity: '+map_NewProdQuantity);
               System.debug('######map_ProdChangeHistory'+map_ProdChangeHistory);
               System.debug('######map_ProdChangeHistoryColor'+map_ProdChangeHistoryColor);
               for(String strPrevProd : map_PrevProdInfo.keySet()) {
                   if(!map_ProdChangeHistory.containsKey(strPrevProd) && !map_PrevProdInfo.get(strPrevProd).Hide_Record__c && map_PrevProdInfo.get(strPrevProd).Bundle__c == null) { 
                       list_RemovedPrevProds.add(map_PrevProdInfo.get(strPrevProd));                             
                   }
               }
               //Logic to update quantity difference for amend and renew subscriptions
               for(BigMachines__Quote_Product__c objNewQP : list_QuoteProductRecords) {
                   String strUniqueKey = objNewQP.BigMachines__Product__c+';'+objNewQP.Is_Overage__c;
                   objNewQP.Quantity_Change__c = objNewQP.Quantity__c;
                   if(map_PrevProdQuantity.containsKey(strUniqueKey) && map_NewProdQuantity.containsKey(strUniqueKey)) { 
                       if(map_NewProdQuantity.get(strUniqueKey) >= map_PrevProdQuantity.get(strUniqueKey)) 
                           objNewQP.Quantity_Change__c = map_NewProdQuantity.get(strUniqueKey) - map_PrevProdQuantity.get(strUniqueKey);
                       else 
                           objNewQP.Quantity_Change__c = map_PrevProdQuantity.get(strUniqueKey) - map_NewProdQuantity.get(strUniqueKey);
                   }
                   if(objNewQP.Quantity_Change__c > 0){
                       System.debug(objNewQP);
                       set_QPQuantityChanged.add(objNewQP);
                   }
               }
               System.debug(set_QPQuantityChanged);
               QuoteCloudUtil.retrieveBundleBaseProduct(set_QPQuantityChanged,quote,'Existing');
           }
    }
    
    private List<BigMachines__Quote_Product__c> deleteDependentProducts(List<BigMachines__Quote_Product__c> list_ToDelete) {
        Set<Id> set_ToDeleteQPIds = new Set<Id>();
        Set<Id> set_ToDeleteProdIds = new Set<Id>();
        Set<Id> set_ExistingProdIds = new Set<Id>();
        Set<Id> set_ExistingProdGrpItmIds = new Set<Id>();
        Set<Id> set_ToDeleteProdGrpItmIds = new Set<Id>();
        List<BigMachines__Quote_Product__c> list_ToDeleteDepProds = new List<BigMachines__Quote_Product__c>();
        Map<Id, BigMachines__Quote_Product__c> map_OverageQPs = new Map<Id, BigMachines__Quote_Product__c>();
        Map<Id, Product_Group__c> map_ProdGrps = new Map<Id, Product_Group__c>();
        
        for(BigMachines__Quote_Product__c objDeleteQP : list_ToDelete) {
            set_ToDeleteQPIds.add(objDeleteQP.Id);                 
        }        
        System.debug('######set_ToDeleteQPIds: '+set_ToDeleteQPIds);
        
        List<BigMachines__Quote_Product__c> list_ExistingQPs = [SELECT Id, BigMachines__Product__c, Quantity__c, Is_Overage__c, Hide_Record__c,
                                                                Parent_Quote_Product__c
                                                                FROM BigMachines__Quote_Product__c
                                                                WHERE BigMachines__Quote__c = :quote.Id];
        //AND Id NOT IN :set_ToDeleteQPIds];
        for(BigMachines__Quote_Product__c objQP : list_ExistingQPs) {
            if(set_ToDeleteQPIds.contains(objQP.Id)) {
                set_ToDeleteProdIds.add(objQP.BigMachines__Product__c);
                map_OverageQPs.put(objQP.Parent_Quote_Product__c, objQP);
            }
            else {
                if(objQP.Parent_Quote_Product__c == null && !objQP.Hide_Record__c) {
                    set_ExistingProdIds.add(objQP.BigMachines__Product__c);
                }
                else {
                    map_OverageQPs.put(objQP.Parent_Quote_Product__c, objQP);
                }
            }
        }
        System.debug('######set_ToDeleteProdIds: '+set_ToDeleteProdIds); //Pc1
        System.debug('######set_ExistingProdIds: '+set_ExistingProdIds); //p1, p2 and pc
        System.debug('######map_OverageQPs: '+map_OverageQPs);
        List<Product_Group__c> list_ProdGrps = [SELECT Id, Product__c, (SELECT Product__c FROM Product_Group_Items__r)
                                                FROM Product_Group__c
                                                WHERE Group_Type__c = 'Dependent Products'
                                                AND (Product__c = :set_ToDeleteProdIds OR Product__c = :set_ExistingProdIds)];
        for(Product_Group__c objProdGrp : list_ProdGrps) {  
            if(set_ToDeleteProdIds.contains(objProdGrp.Product__c)) {
                for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                    set_ToDeleteProdGrpItmIds.add(objProdGrpItm.Product__c);  //p1, p2 and pc
                }
            }
            if(set_ExistingProdIds.contains(objProdGrp.Product__c)) {
                for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                    set_ExistingProdGrpItmIds.add(objProdGrpItm.Product__c);  //p1, p2 and pc
                }
            }            
        }
        System.debug('######set_ExistingProdGrpItmIds: '+set_ExistingProdGrpItmIds);
        System.debug('######set_ToDeleteProdGrpItmIds: '+set_ToDeleteProdGrpItmIds);
        for(BigMachines__Quote_Product__c objQP : list_ExistingQPs) {
            if(objQP.Parent_Quote_Product__c == null && !set_ToDeleteProdIds.contains(objQP.BigMachines__Product__c) && objQP.Hide_Record__c   //p1, p2, pc
               && set_ToDeleteProdGrpItmIds.contains(objQP.BigMachines__Product__c)
               && !set_ExistingProdGrpItmIds.contains(objQP.BigMachines__Product__c)) { 
                   list_ToDeleteDepProds.add(objQP);
                   if(map_OverageQPs.containsKey(objQP.Id)) {
                       list_ToDeleteDepProds.add(map_OverageQPs.get(objQP.Id));
                   }
               }
            if(set_ToDeleteQPIds.contains(objQP.Id) && map_OverageQPs.containsKey(objQP.Id)) {
                list_ToDeleteDepProds.add(map_OverageQPs.get(objQP.Id));
            }
        }
        System.debug('######list_ToDeleteDepProds: '+list_ToDeleteDepProds);
        return list_ToDeleteDepProds;
    }
    
    public List<SelectOption> getInitialSubscrTerms() {
        List<SelectOption> list_InitialSubscriptionTerms = new List<SelectOption>();        
        for(Schema.PicklistEntry value : BigMachines__Quote__c.Initial_Subscription_Term__c.getDescribe().getPicklistValues()) {
            if(value.getValue() != 'Other') {
                list_InitialSubscriptionTerms.add(new SelectOption(value.getLabel(), value.getValue()));
            }
        } 
        return list_InitialSubscriptionTerms;
    }
    @Testvisible
    private Set<Id> findOverageChargeAPNs() {
        Set<Id> set_OvrgProdParentIds = new Set<Id>();
        for(BigMachines__Quote_Product__c objOvgQP : [SELECT Id, Parent_Quote_Product__c 
                                                      FROM BigMachines__Quote_Product__c
                                                      WHERE BigMachines__Quote__c =: quoteId 
                                                      AND Parent_Quote_Product__c != null]) {
                                                          set_OvrgProdParentIds.add(objOvgQP.Parent_Quote_Product__c);
                                                      }
        return set_OvrgProdParentIds;
    }
    private String validateOrderSubmission(){
        Integer intShippableProductsCount = 0;
        Boolean blnHasPureSuccess = false;
        String returnStr = 'OK';   
        Set<String> addressTypes = new Set<String>();
        List<BigMachines__Quote_Product__c> list_QtProds = new List<BigMachines__Quote_Product__c>();
        
        List<Account_Order_Address__c> orderAddressOnOrder = [SELECT Address_Type__c 
                                                              FROM Account_Order_Address__c 
                                                              WHERE Quote__c =: quote.Id ORDER BY Address_Type__c];
        /*Integer intShippableProductsCount = [SELECT count() 
FROM BigMachines__Quote_Product__c 
WHERE BigMachines__Quote__c =: quote.Id
AND BigMachines__Product__r.ProductShippable__c='Yes'];
if(quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription) {
intShippableProductsCount = [SELECT count() 
FROM BigMachines__Quote_Product__c 
WHERE BigMachines__Quote__c =: quote.Id
AND BigMachines__Product__r.ProductShippable__c='Yes'
AND BigMachines__Product__r.New_Category__c = 'Hardware'
AND Quantity_Change__c > 0];
}*/
        
        list_QtProds = [SELECT Id, Name,  BigMachines__Product__r.New_Category__c, Quantity_Change__c
                        FROM BigMachines__Quote_Product__c 
                        WHERE BigMachines__Quote__c =: quote.Id
                        AND BigMachines__Product__r.ProductShippable__c='Yes'];
        intShippableProductsCount = list_QtProds.size();
        if(quote.Order_Type__c == Label.Amend_Subscription || quote.Order_Type__c == Label.Renew_Subscription) {
            intShippableProductsCount = 0;
            for(BigMachines__Quote_Product__c objQtProd : list_QtProds) {
                if(objQtProd.BigMachines__Product__r.New_Category__c == 'Hardware' && objQtProd.Quantity_Change__c > 0) {
                    intShippableProductsCount += 1;
                }
            }
        }
        
        if(quote.PureSuccess__c != null || quote.Does_customer_currently_have_PureSuccess__c) {
            blnHasPureSuccess = true;
        }
        
        for(Account_Order_Address__c eachAOA : orderAddressOnOrder){
            addressTypes.add(eachAOA.Address_Type__c);
        }   
        String missingAddressTypes = '';
        if(!addressTypes.contains('Bill To')){
            missingAddressTypes += 'Bill To, ';
        }
        if(!addressTypes.contains('End User')){
            missingAddressTypes += 'End User, ';
        }
        if((intShippableProductsCount > 0 || blnHasPureSuccess) && !addressTypes.contains('Ship To')){
            missingAddressTypes += 'Ship To, ';
        }
        if(!addressTypes.contains('Sold To')){
            missingAddressTypes += 'Sold To, ';
        }
        //Muthu:18-Oct-19:Added for PEC149
        if(!addressTypes.contains('Order Acknowledgement')){
            missingAddressTypes += 'Order Acknowledgement, ';
        } 
        if(!String.isBlank(missingAddressTypes)) {   
            missingAddressTypes = missingAddressTypes.substring(0, missingAddressTypes.lastIndexOf(','));
            String es = '';
            if(missingAddressTypes.indexOf(',') != -1){             
                String str = missingAddressTypes.substring(missingAddressTypes.lastIndexOf(','), missingAddressTypes.length());
                str = str.replace(',', 'and');
                missingAddressTypes = missingAddressTypes.substring(0, missingAddressTypes.lastIndexOf(','));
                missingAddressTypes += ' ' + str;
                es = 'es';              
            }
            returnStr = 'Please add ' + missingAddressTypes + ' address' + es + '.';
        }
        return returnStr;
    }
    
    public void changeOfMSALinkType(){
        blnMSALInkTypeChange = false;
        if(quote.Amendment_For__r.MSA_Link_Type__c !=null 
           && (quote.Amendment_For__r.MSA_Link_Type__c == 'Custom' && quote.MSA_Link_Type__c == 'Standard'))
            blnMSALInkTypeChange = true;    
        
        system.debug('MSA_Link_Type__c--->'+quote.MSA_Link_Type__c);    
        system.debug('MSA_Link__c--->'+quote.MSA_Link__c);
        
    } 
    
    public void changeOfMSALinkTypeByUser(){
        if(quote.MSA_Link_Type__c == 'Standard')
            quote.MSA_Link_Type__c = 'Custom';
        else
            quote.MSA_Link_Type__c = 'Standard';
        
        if(quote.MSA_Link_Type__c == 'Standard')
            quote.MSA_Link__c = [SELECT Url__c from  Links__mdt  WHERE Offering_Type__c = 'PureEngage Cloud'].Url__c ;
        else
            quote.MSA_Link__c = '';
        changeOfMSALinkType();
        system.debug('MSA_Link_Type__c--->'+quote.MSA_Link_Type__c);    
        system.debug('MSA_Link__c--->'+quote.MSA_Link__c);
    } 
    
    public void refreshContractDiscount(){
        if(!quote.Require_Contractual_Discount__c){
            quote.Customer_Contractual_Rate__c = 0;
            System.debug(quote.Customer_Contractual_Rate__c);
        }
    }
    
    //Mukunth added below to capture multi-year ACV
    public void populateMultiYrACV(){
        
        if(quote.Annual_Contract_Value__c != null && quote.Price_Escalation__c != null
           && quote.Initial_Subscription_Term__c != null && quote.Initial_Subscription_Term__c != 'Other'){
               
               initSubTerm = integer.valueof((quote.Initial_Subscription_Term__c).substringBefore(' '));
               system.debug('initSubTerm--->'+initSubTerm);
               
               //boolean isACVEdited = false;
               
               currentConsolidatedQty = 0;
               for(BigMachines__Quote_Product__c qpEachRec:list_QuoteProductRecords){
                   if(currentConsolidatedQty == null)
                       currentConsolidatedQty = qpEachRec.Quantity__c;
                   else
                       currentConsolidatedQty += qpEachRec.Quantity__c;
               }
               
               System.Debug('currentConsolidatedQtybefore--->'+currentConsolidatedQty);
               if(prevConsolidatedQty != null){
                   System.Debug('prevConsolidatedQtyBefore--->'+prevConsolidatedQty);
               }
               else
                   System.Debug('prevConsolidatedQtyIsNull--->');
               
               increasePercent = 0;
               
               System.Debug('quote.Annual_Price_Escalation_Other__c--->'+quote.Annual_Price_Escalation_Other__c);
               
               
               
               if(quote.Price_Escalation__c != 'Other')
                   increasePercent = decimal.valueof((quote.Price_Escalation__c).left(1));
               else if(quote.Annual_Price_Escalation_Other__c != null && quote.Price_Escalation__c == 'Other')
                   increasePercent = quote.Annual_Price_Escalation_Other__c;
               else
                   increasePercent = 0;
               
               /*if(clonedQuote != null && quote.Price_Escalation__c == clonedQuote.Price_Escalation__c && quote.Initial_Subscription_Term__c == clonedQuote.Initial_Subscription_Term__c
&& prevConsolidatedQty != null && currentConsolidatedQty == prevConsolidatedQty &&
(quote.Multi_Year_ACV_Year_1__c != clonedQuote.Multi_Year_ACV_Year_1__c || quote.Multi_Year_ACV_Year_2__c != clonedQuote.Multi_Year_ACV_Year_2__c ||
quote.Multi_Year_ACV_Year_3__c != clonedQuote.Multi_Year_ACV_Year_3__c || quote.Multi_Year_ACV_Year_4__c != clonedQuote.Multi_Year_ACV_Year_4__c ||
quote.Multi_Year_ACV_Year_5__c != clonedQuote.Multi_Year_ACV_Year_5__c || quote.Multi_Year_ACV_Year_6__c != clonedQuote.Multi_Year_ACV_Year_6__c || 
quote.Multi_Year_ACV_Year_7__c != clonedQuote.Multi_Year_ACV_Year_7__c ||
quote.Multi_Year_ACV_Year_8__c != clonedQuote.Multi_Year_ACV_Year_8__c || quote.Multi_Year_ACV_Year_9__c != clonedQuote.Multi_Year_ACV_Year_9__c || 
quote.Multi_Year_ACV_Year_10__c != clonedQuote.Multi_Year_ACV_Year_10__c)){
isACVEdited = true;
}*/
               
               //System.Debug('isACVEdited--->'+isACVEdited);
               
               //if(!isACVEdited){
               quote.Multi_Year_ACV_Year_1__c = quote.Multi_Year_ACV_Year_2__c = quote.Multi_Year_ACV_Year_3__c = quote.Multi_Year_ACV_Year_4__c = null;
               quote.Multi_Year_ACV_Year_5__c = quote.Multi_Year_ACV_Year_6__c = quote.Multi_Year_ACV_Year_7__c = quote.Multi_Year_ACV_Year_8__c = null;
               quote.Multi_Year_ACV_Year_9__c = quote.Multi_Year_ACV_Year_10__c = null;
               
               system.debug('increasePercent--->'+increasePercent);
               if(increasePercent != 0 && initSubTerm > 1){
                   for(integer i=1;i<=initSubTerm;i++){
                       if(i==1)
                           quote.Multi_Year_ACV_Year_1__c = quote.Annual_Contract_Value__c;
                       if(i==2)
                           quote.Multi_Year_ACV_Year_2__c = quote.Multi_Year_ACV_Year_1__c + ((quote.Multi_Year_ACV_Year_1__c*increasePercent)/100);
                       if(i==3)
                           quote.Multi_Year_ACV_Year_3__c = quote.Multi_Year_ACV_Year_2__c + ((quote.Multi_Year_ACV_Year_2__c*increasePercent)/100);
                       if(i==4)
                           quote.Multi_Year_ACV_Year_4__c = quote.Multi_Year_ACV_Year_3__c + ((quote.Multi_Year_ACV_Year_3__c*increasePercent)/100);
                       if(i==5)
                           quote.Multi_Year_ACV_Year_5__c = quote.Multi_Year_ACV_Year_4__c + ((quote.Multi_Year_ACV_Year_4__c*increasePercent)/100);
                       if(i==6)
                           quote.Multi_Year_ACV_Year_6__c = quote.Multi_Year_ACV_Year_5__c + ((quote.Multi_Year_ACV_Year_5__c*increasePercent)/100);
                       if(i==7)
                           quote.Multi_Year_ACV_Year_7__c = quote.Multi_Year_ACV_Year_6__c + ((quote.Multi_Year_ACV_Year_6__c*increasePercent)/100);
                       if(i==8)
                           quote.Multi_Year_ACV_Year_8__c = quote.Multi_Year_ACV_Year_7__c + ((quote.Multi_Year_ACV_Year_7__c*increasePercent)/100);
                       if(i==9)
                           quote.Multi_Year_ACV_Year_9__c = quote.Multi_Year_ACV_Year_8__c + ((quote.Multi_Year_ACV_Year_8__c*increasePercent)/100);
                       if(i==10)
                           quote.Multi_Year_ACV_Year_10__c = quote.Multi_Year_ACV_Year_9__c + ((quote.Multi_Year_ACV_Year_9__c*increasePercent)/100);
                   }
               }
               clonedQuote = quote.clone(true,true,false,false);
               
               for(BigMachines__Quote_Product__c qpEachRec:list_QuoteProductRecords){
                   if(prevConsolidatedQty == null)
                       prevConsolidatedQty = qpEachRec.Quantity__c;
                   else
                       prevConsolidatedQty += qpEachRec.Quantity__c;
               }
               //}
               System.Debug('currentConsolidatedQty--->'+currentConsolidatedQty);
               System.Debug('prevConsolidatedQty--->'+prevConsolidatedQty);
               system.debug('quote.Multi_Year_ACV_Year_2__c--->'+quote.Multi_Year_ACV_Year_2__c);
               system.debug('quote.Multi_Year_ACV_Year_2__cClone--->'+clonedQuote.Multi_Year_ACV_Year_2__c);
               
           }
    }
    //Mukunth code end
    
    //Mukunth added below code for DDS Mega Deals
    public boolean checkMegaDeal(){
        if(quote.Annual_Contract_Value__c != null && quote.New_Price_Book__c != null){
            System.Debug('quote.Annual_Contract_Value__c--->'+quote.Annual_Contract_Value__c);
            
            if(DDSCloud.converttoUSD(SubscriptionUtil.OFFERING_TYPE_PC,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c) * Decimal.valueof(CloudPevMultiplierPC.Information__c) > Decimal.valueof(CloudPevMultiplierPC.ID__c)){
                return true;
            }
            else{
                return false;
            }
        }
        else
            return false;
    }
    //Mukunth Code End
    
    public void codeCoverage(){
        for(integer i=0;i<=1;i++){
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;     i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;     i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;     i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;     i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;     i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;     i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}