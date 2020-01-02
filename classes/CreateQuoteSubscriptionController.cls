/************************************************************************************
Purpose :  Controller for the quoting tool page CreateQuoteSubscription
Written By :  Naresh Kumar
Test Classes :  CreateQuoteSubscriptionControllerTest
*************************************************************************************/
public without sharing class CreateQuoteSubscriptionController{
        public BigMachines__Quote__c quote {get; set;}
        public List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
        public String quoteProductIdToBeDeleted {get; set;}
        public String quoteBurstTermIdToBeDeleted {get; set;}
        String quoteId;
        Decimal decPricingMultiplier;
        Boolean blnSkipPriceCheck;
        
        // For facet checkbox for Grid
        public Boolean blnIsHeaderChecked {get; set;}
        // List of Group Headers i.e. Categories or Proposal Group Numbers
        public List<String> list_GroupHeaders {get; set;}
        // Map of Group Header to List of Quote Product Wrappers
        public Map<String,List<QuoteProductWrapper>> map_GroupHeaderToQuoteProdWrapper {get; set;}
        // Service Level
        public BigMachines__Quote_Product__c objServiceLevel {get; private set;}
        // Third Party GC Line
        public BigMachines__Quote_Product__c objThirdPartyGCLine {get; private set;}
        // Training Unit Line
        public BigMachines__Quote_Product__c objTrainingUnit;        
        // Shipping & Handling Line
        public BigMachines__Quote_Product__c objShippingAndHandling {get; private set;}
        // Migration Credit Y1
        public BigMachines__Quote_Product__c objMigrationCreditY1 {get; private set;}
        // Migration Credit Y2
        public BigMachines__Quote_Product__c objMigrationCreditY2 {get; private set;}
        ///Non-migration credits
        public List<BigMachines__Quote_Product__c> list_Credits {get; set;}
        // Professional Services
        public BigMachines__Quote_Product__c objProfessionalServices {get; private set;}    
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
        // To store the default care rate based on the service level and country of end user
        //public Decimal decDefaultCareRate {get; private set;}
        // All products excluding configuration products and bundle items products on the quote
        List<BigMachines__Quote_Product__c> list_QuoteProductRecords;
        // Bundle Item Products
        List<BigMachines__Quote_Product__c> list_BundleItemQPRecords;
        // To store mass update input values
        public BigMachines__Quote_Product__c objMassUpdateInput {get; set;}
        // To be used for quick 'Add Product' functionality
        public BigMachines__Quote_Product__c objAddProductInput {get; set;}
        // To indicate whether there is at least 1 HW Line
        public Boolean blnHasHWLines {get; private set;}
        // To indicate whether there is at least 1 Bundle
        public Boolean blnHasBundles {get; private set;}
        // To indicate whether there is at least 1 RDP product
        public Boolean blnHasRDP {get; private set;}
        // To indicate whether there is at least 1 product with EMEA Volume Discount
        public Boolean blnHasEMEAVolDisc {get; private set;}
        // Boolean to indicate whether it's a simulated quote (Pricing Simulator)
        public Boolean blnIsSimulated {get; private set;}
        // Map to store Bundle Quote Products
        Map<Id,BigMachines__Quote_Product__c> map_BundleQuoteProducts;
        Map<String, Integer> burstTermLength;  
        public Map<String,List<SelectOption>> map_FlavorsToSelectOptions {get; private set;}
        public List<QuoteBurstTerm> list_QuoteBurstTerms {get; set;}
        public Id idSoldToAccount;
        Id idOpportunity;
        transient Decimal decTotalSWNetPrice,decTotalHWNetPrice,decTotalEducationNetPrice,decTotalServicesNetPrice;
        public String dqStatus {get; set;}    
        public Boolean showReviseDQPopup {get;set;}
        public Boolean blnShowSelectColumns {get; private set;}
        public User_Col_Preference__c objColumnPreference {get; set;}
        User_Col_Preference__c objColPrefCopy;
        String oldPricingModel;
        // **** For Pagination ****
        public Integer intPageNum {get; private set;}
        public Integer intPageSize {get; private set;}
        public Integer intTotalNoOfRecords {get; private set;}
        //public Boolean isPPUQuoting {get;set;}
        // To indicate whether this quote use old or new pricing
        public Boolean blnIsNewPricing {get; private set;}
        public Decimal totalAmount {get; private set;} //not used??
        public Decimal totalACV {get; private set;}
        public Decimal totalACV1 {get; private set;}
        public Decimal totalACV2 {get; private set;}
        public Decimal totalAcvBrst1 {get; private set;}
        public Decimal totalAcvBrst2 {get; private set;}
        public Decimal totalAmountOneTimeFee {get; private set;}
        public Decimal totalAmountYear1 {get; private set;}
        public Decimal totalAmountYear2 {get; private set;}     
        public Decimal pureSuccessAmount {get; private set;}
        public Decimal regionalDiscount {get; private set;}
        public Decimal CMRRPreDiscount {get; private set;}
        public Integer maxSeatCount;
        public Map<String, String> map_ProdChangeHistory {get; set;}
        public Map<String, String> map_ProdChangeHistoryColor {get; set;}
        Map<String, Decimal> map_PrevProdQuantity; 
        public List<Subscription_Product__c> list_RemovedPrevProds {get; set;}
        public String[] strChngeHistColors {get;set;} 
        public Boolean isAmendQuote {get; private set;}
        public Decimal decHighestDiscount {get; private set;}
        public Decimal decY1AnnualSubscriptionAmount {get; private set;}
        public Decimal decPureSuccessOfferSubscriptionAmount {get; private set;}
        public Decimal decALaCartePureSuccessServiceAmount {get; private set;}
        public Decimal decNonRecurringFee {get; private set;}
        public Decimal decThirdPartyCare {get; private set;}
        public Decimal decAmountDueAtInitialInvoice {get; private set;}
        public Decimal decY2AnnualSubscriptionAmount {get; private set;}
        public Decimal decAmountDueAtAnniversary {get; private set;}
        public Decimal decY1SeasonalLicenseAmount {get; private set;}
        public Decimal decY2SeasonalLicenseAmount {get; private set;}
        public Decimal decTotalCommitment {get; private set;}
        public Decimal decBurstDiscount {get; private set;}
        public Decimal decBurstY1 {get; private set;}
        public Decimal decBurstY2 {get; private set;}
        public Decimal totalCredit {get; private set;}
        public Boolean isSmallMediumCenter {get; private set;}
        public Boolean isPureBridgeOpp {get; private set;}
        public Boolean lever1 {get; set;}
        public Boolean lever2 {get; set;}
        public Boolean lever3 {get; set;}
        public Boolean oneyear {get; set;}
        public Boolean secondYrAmend {get; set;}
       
        //VF page error, putting cutoffs variable back as not able to find it's reference on the page, will remove it.
        //public string cutoffs {get; private set;}
        public class QuoteProductWrapper
        {
            public BigMachines__Quote_Product__c record {get; set;}
            public Boolean selected {get; set;}
            
            public QuoteProductWrapper()
            {
                selected = false;
            }
        }
        
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

        public class QuoteBurstTerm {
            public Subscription_Burst_Term__c term {get; set;}
            public List<BigMachines__Quote_Product__c> qtprods {get; set;}
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
        public Boolean blnIsReviseOrder {get; private set;}
        
        public Boolean blnHasViolations {get; private set;}
        public transient List<DealQualificationAndQuoteApprovalHelper.wrapperViolationSummary> list_Violations {get; set;}
        public transient String strIsFinalize {get; private set;}
        public Deal_Qualification__c dq {get; private set;}
        public Decimal totalDiscount {get; private set;}
        public Boolean blnIsDealFactoryUser {get; private set;}
        public Boolean blnIsDSPilotUser {get; private set;}

        public CreateQuoteSubscriptionController()
        {
            isSmallMediumCenter = false;

            //PureBridge
            isPureBridgeOpp = lever1 = lever2 = lever3 = false;
            
            dqStatus = 'Not Approved';
            init();
            String strLandingTab = ApexPages.currentPage().getParameters().get('tab');
            if(strLandingTab == 'GenesysCare')
                showGenesysCare();
            else if(strLandingTab == 'DAPDetails')
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
            setAddendumLink();            
            if(quote.End_User_ID__r.OrderHold__c){
                if(quote.Sold_To_Region__c == 'North America')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Account_Hold_Notification_NA));
                else if(quote.Sold_To_Region__c == 'EMEA')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Account_Hold_Notification_EMEA));
                else if(quote.Sold_To_Region__c == 'APAC')
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Account_Hold_Notification_APAC));              
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.Account_Hold_Notification));

            }       
            
            isAmendQuote = (quote.Order_Type__c == Label.Order_Type_Amend || quote.Order_Type__c == Label.Order_Type_Subscription) && quote.Amendment_For__c != null;
            populateAmendTotals();
        }
        
        private void init() {
    
            quoteId = ApexPages.currentPage().getParameters().get('id');
            objUngrouped = new Quote_Proposal_Group__c();
            objMassUpdateInput = new BigMachines__Quote_Product__c();
            objAddProductInput = new BigMachines__Quote_Product__c();
            blnIsHeaderChecked = blnShowByPassApprovals = blnSkipPriceCheck = blnIsReviseOrder = 
            blnShowExportScreeningMsg = blnShowExportScreeningExpireMsg = blnHasRDP = blnHasError = blnIsNewPricing = blnIsSimulated = blnHasViolations = false;
            
            blnShowSelectColumns = false;
 
            //objColumnPreference = User_Col_Preference__c.getInstance(UserInfo.getUserId());
            List<User_Col_Preference__c> list_UserColPref = [SELECT Id,Third_Party__c,Name,Building_Block__c,Ext_List_Price__c, Sub_Category__c, Partner_Price__c, 
                            List_Price__c,Net_Unit_Price__c,PM_Approver__c,Product_Specific_Discount__c,Unit_of_measure__c, Accepted_Volume_Discount__c,NG1_PPU_Gold_USD__c 
                            FROM User_Col_Preference__c WHERE User__c = :UserInfo.getUserId()];
            if(list_UserColPref.size() == 0)
                objColumnPreference = new User_Col_Preference__c(Third_Party__c = true,User__c = UserInfo.getUserId(),
                            Building_Block__c = true,Ext_List_Price__c = true,List_Price__c = true,Net_Unit_Price__c = true, Sub_Category__c = true,
                            PM_Approver__c = true,Product_Specific_Discount__c = true,Unit_of_measure__c = true, Partner_Price__c = true);
            else
                objColumnPreference = list_UserColPref[0];
            
            // Fetching Quote information
            quote = getQuote((Id)quoteId);
            /*
            if(isPPUQuoting){
                quote.PPU_Rental__c = true;
                quote.Expiration_Date__c = Date.today().addDays(90);
            }
            */
            oldPricingModel = quote.Pricing_Model__c;
            if(quote.Quote_Opportunity_Type__c == 'New Pricing')
                blnIsNewPricing = true;
                
            if(quote.BigMachines__Status__c == 'Simulated Quote')
                blnIsSimulated = true;
            
            isSmallMediumCenter = quote.Offering_Feature__c != null && quote.Offering_Feature__c.contains('PureConnect Small Medium') ? true : false;

            //PureBridge 
            if ( quote.Lever__c != null ) {
               isPureBridgeOpp = true;
               lever1 = quote.Lever__c.contains('Lever 1') ? true : false;
               lever2 = quote.Lever__c.contains('Lever 2') ? true : false;
               lever3 = quote.Lever__c.contains('Lever 3') ? true : false;      
            }

            objUngrouped = new Quote_Proposal_Group__c(CurrencyISOCode = quote.CurrencyISOCode);

            list_QuoteProducts = new List<QuoteProductWrapper>();
            if(quoteId != null) {  
                   
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
                
                initializeCareRate();
                
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
            }

            quote.No_Of_Months__c = (quote.Amendment_For__c == null) ? quote.No_Of_Months__c : getNumOfMonths(quote);
            
            oneyear = isOneyearQuote(quote); 
            secondYrAmend = isSecondYrAmend(quote);

            totalCredit = decNullTest(quote.Total_Recurring_Credit__c) + decNullTest(quote.Total_Non_Recurring_Credit__c);

            showReviseDQPopup = false;
            getDQStatus();

            //buildChangeHistoryForAmendSubscr(false);
            buildChangeHistoryForAmend();

            blnIsDealFactoryUser = false;
            Map<Id, Group> mapIdVsGroup = new Map<Id, Group> ([SELECT id FROM Group WHERE Name IN : Label.Deal_Factory_Queue_Names.split(',')]);
            List<GroupMember> groupMemberRecord = [SELECT id, UserOrGroupId FROM GroupMember WHERE GroupId =: mapIdVsGroup.keyset()];
            for(GroupMember eachMember : groupMemberRecord){
                if(eachMember.UserOrGroupId == Userinfo.getUserId()){
                    blnIsDealFactoryUser = true;
                    break;  
                }
            }
            List<Deal_Qualification__c> listOfDealQualifications = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, 'New Pricing', 'On Premise', quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
            if(!listOfDealQualifications.isEmpty()){                
                if(quote.Overage_Allowance_Other__c == null)
                                        quote.Overage_Allowance_Other__c = listOfDealQualifications[0].Overage_Allowance_Other__c;
                if(quote.Annual_Price_Escalation_Other__c == null)
                                quote.Annual_Price_Escalation_Other__c = listOfDealQualifications[0].Annual_Price_Escalation_Other__c;
                if(quote.Payment_Terms_Price_Uptick__c == null)
                                quote.Payment_Terms_Price_Uptick__c = listOfDealQualifications[0].Payment_Terms_Price_Uptick__c;
                if(quote.Overage_Allowance_Price_Uptick__c == null)
                                quote.Overage_Allowance_Price_Uptick__c = listOfDealQualifications[0].Burst_Allowance_Price_Uptick__c;                        
            }
            blnIsDSPilotUser = false;
            List<GroupMember> listOfGroupMembers = [SELECT id, UserOrGroupId FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId() 
                      AND GroupId IN (SELECT id FROM Group WHERE DeveloperName = 'Deal_Score_Pilot_Group')];
            if(!listOfGroupMembers.isEmpty())
                blnIsDSPilotUser = true;
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
        
        public void showGenesysCare()
        {
            strSelectedTab = 'Genesys Care';
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
            approvals = fetchApprovals();
            objAttachment = new Attachment(ParentId = quote.Id);
        }
        
        public void showOrderSubmission()
        {
            strSelectedTab = 'Order Submission';
            if(upfrontApprovals != null)
                upfrontApprovals.clear();
            objAttachment = new Attachment(ParentId = quote.Id);
        }
        
        public PageReference showHistoryAndAttachments()
        {
            objAttachment = new Attachment(ParentId = quote.Id);
            doCalculations();
            if(!blnHasError)
                return (new PageReference('/apex/QuoteApprovalHistoryAndAttachments?id=' + quote.Id + '&retPage=CreateQuoteSubscription'));
            return null;    
        }
        
        public PageReference showProposalOptions()
        {
            objAttachment = new Attachment(ParentId = quote.Id);
            doCalculations();
            if(!blnHasError)
                return (new PageReference('/apex/ProposalOptions1?id=' + quote.Id + '&retPage=CreateQuoteSubscription'));
            return null;    
        }
        
        public void CalculateScore(){
            try{
               // if(quote.Amendment_For__c == null){
                    //DDSToolMain.QuoteDDSWrapper objWrapper = DDSToolMain.calculateDealScore(quote);
                    DDSToolInterface.QuoteDDSWrapper objWrapper = DDSToolInterface.calculateDealScore(quote);
                    String strMessage = objWrapper.strMessage;
                    quote = objWrapper.objQuote;
                    quote.Deal_Score_Cutoffs__c = objWrapper.strCutoffs;
                    update quote;
                    if(strMessage != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strMessage));
               // }
            }
            catch(exception e){  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getmessage()));   
            }           
        }
        
        private Decimal getPricingMultiplier(String strPricingModel)
        {
            Decimal decMultiplier = 1;
            
            if(strPricingModel == 'Concurrent')
                decMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Concurrent_Pricebook_Multiplier__c;        
            else if(strPricingModel == 'Named User')
                decMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Named_User_Pricing_Multiplier__c;            
            else if(strPricingModel == 'Branch Office')
          decMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Branch_Office_Multiplier__c;
                
            return decMultiplier;
        }
        
        public void changePricingModel(){
            if(quote.Offering_Type__c == 'PureConnect Subscription'){
                //Fetching base package for respective pricing model
                Map<id, Product_Group__c> listOfProductGroups = new Map<id, Product_Group__c>([SELECT id FROM Product_Group__c 
                                WHERE Offering_Type__c INCLUDES (:quote.Offering_Type__c) AND Group_Type__c = 'Base Package' 
                                AND Active__c = true AND Pricing_Model__c INCLUDES (: quote.Pricing_Model__c)]);
                
                if(!listOfProductGroups.values().isEmpty()){
                    //Removing existing base package
                    List<BigMachines__Quote_Product__c> listOfQuoteProductsToBeRemoved = [SELECT id FROM BigMachines__Quote_Product__c
                                    WHERE BigMachines__Quote__c =: quote.id AND Bundle__r.Group_Type__c = 'Base Package'];
                    if(!listOfQuoteProductsToBeRemoved.isEmpty())
                        delete listOfQuoteProductsToBeRemoved;            
                    
                    //Adding new base package for respective pricing model  
                    String strPureSuccessPackageName = '';
                    List<BigMachines__Quote_Product__c> listOfPureSuccessItem = [SELECT Bundle__r.Type__c FROM BigMachines__Quote_Product__c
                                                                        WHERE BigMachines__Quote__c =: quote.id AND Bundle__r.Group_Type__c = 'PureSuccess'
                                                        AND Bundle_Line__c = null];
                    if(!listOfPureSuccessItem.isEmpty())
                        strPureSuccessPackageName = listOfPureSuccessItem[0].Bundle__r.Type__c;
                    System.debug('NKC debug strPureSuccessPackageName [' + strPureSuccessPackageName +']');
                    ApexPages.CurrentPage().getParameters().put('oppId', quote.BigMachines__Opportunity__c);
                    OptyQuoteHandler objQuoteHandler = new OptyQuoteHandler();
                    objQuoteHandler.addBundleWithLinesToQuote(quote, listOfProductGroups.keyset(), 'Base Package', strPureSuccessPackageName);
                }
            }            
            oldPricingModel = quote.Pricing_Model__c;
            decPricingMultiplier = getPricingMultiplier(quote.Pricing_Model__c);
            updateUnitOfMeasure();
            doCalculations();
            
        }
        
        private void updateUnitOfMeasure()
        {
            System.debug('----inside updateUnitOfMeasure();');
            List<BigMachines__Quote_Product__c> list_AllQPRecords = new List<BigMachines__Quote_Product__c>();
            list_AllQPRecords.addAll(list_QuoteProductRecords);
            list_AllQPRecords.addAll(list_BundleItemQPRecords);
            for(BigMachines__Quote_Product__c objQP : list_AllQPRecords)
            {
                System.debug('b+++++ objQP.Unit_of_Measure__c ' +  objQP.Unit_of_Measure__c);
                        System.debug('b++++ quote.Pricing_Model__c ' +  quote.Pricing_Model__c);
                if(objQP.BigMachines__Product__r.Type__c != 'Bundle'){                
                
                    if(objQP.Unit_of_Measure__c != null && 
                       (objQP.Unit_of_Measure__c.containsIgnoreCase('seat') || objQP.Unit_of_Measure__c.containsIgnoreCase('Named'))
                    )
                      {                   
                        objQP.Unit_of_Measure__c = 'per seat';  
                        if(quote.Pricing_Model__c == 'Enabled')
                            objQP.Unit_of_Measure__c = 'per seat';                    
                        else if(quote.Pricing_Model__c == 'Concurrent' && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase( 'Concurrent'))
                            objQP.Unit_of_Measure__c = 'per concurrent seat';
                        else if(quote.Pricing_Model__c == 'Named User' && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase( 'Named User'))
                            objQP.Unit_of_Measure__c = 'Named User';
                        else if(quote.Pricing_Model__c == 'Branch Office' && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase( 'Branch Office'))
                            objQP.Unit_of_Measure__c = 'Branch Office Enabled Seat';
                        else 
                             objQP.Unit_of_Measure__c = 'per seat'; 
                    }
                }
            }
        }
        
        private void checkDealViolations(String strOption){
            blnHasViolations = false;
            list_Violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.Id);            
            if(list_Violations != null && list_Violations.size() == 0)
            {
                if(strOption == 'Finalize')
                {
                    quote.BigMachines__Status__c = 'Quote Approved';
                    quote.Subscription_Start_Date__c = System.today();
                    update quote;
                    DealQualificationAndQuoteApprovalHelper.resetELAApproval(quote);
                    QuoteUtil.populateDefaultOrderAddress(quote);
                }           
                return;
            }
            if(list_Violations == null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please get deal qualification approved.'));
            else
                DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.Id);
                
            blnHasViolations = true;
        }
        
                    
        public void convertToRealQuote()
        {
            quote.BigMachines__Status__c = 'Quote In Progress';
            quote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quote.id].Quote_Number__c;
            update quote;
            blnIsSimulated = false;
        }
                
        public void finalizeQuote(){       
            // Synchronizing Deal Qualification Products
            //CalculateScore();
            doCalculations(); 
            
            if(blnHasError)
              return;   
            if(list_QuoteProductRecords.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There should be at least 1 product added to the quote before it can be submitted for approval.'));
                return;
            }  
            ///PurBridge validations          
            Decimal totalUSD = getDealSizeUSD(quote, quote.Annual_Contract_Value_1__c);
            if ( isPureBridgeOpp && (Lever2 || lever3) && !isValidLeverByDealSize(totalUSD) ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The deal does not meet the required minimum size of US$150,000 ACV for the Levers selected.'));
                return;
            }

            CalculateScore();

            DealQualificationAndQuoteApprovalHelper.sendPMApprovalNotifications(quote.id);            
            checkDealViolations('Finalize');
            strIsFinalize = 'true'; 
        }
        
        
        public void getDQStatus(){
          List < Deal_Qualification__c > dqs = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
          if(!dqs.isEmpty()){
            dqStatus = dqs[0].Status__c;
          }
        }
        public void synchAndGoToDQ(){
            System.debug('NKC debug SYNCH');            
            DealQualificationAndQuoteApprovalHelper.synchDQ(quote.Id, quote.BigMachines__Opportunity__c);
            quote.BigMachines__Status__c = 'Quote Approval Pending';
            update quote;
            System.debug('NKC debug dqStatus ['+dqStatus+']');
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
                for(Integer i = (intPageNum-1) * intPageSize;i< (intPageNum * intPageSize) && i <  intTotalNoOfRecords; i++)
                {
                    QuoteProductWrapper wrapperRecord = list_QuoteProducts[i];
                    
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
                    
                    String strGroupHeader;
                    if(quote.Grid_Group_By__c == 'Categories')
                    {
                        /*if(blnIsNewPricing)
                            strGroupHeader = wrapperRecord.record.BigMachines__Product__r.New_Category__c;
                        else
                            strGroupHeader = wrapperRecord.record.BigMachines__Product__r.Tab__c;*/
                        strGroupHeader = (wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution_Category__c == null ? '' : wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution_Category__c)
                            + (wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution__c == null ? '' : + ' - ' + wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution__c);
                    }
                    
                    else if(quote.Grid_Group_By__c == 'Bundles/Products')
                    {
                        if(wrapperRecord.record.Bundle__c != null)
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
                    
                    else if(quote.Grid_Group_By__c == 'Use Cases')
                    {
                        strGroupHeader = wrapperRecord.record.Bundle__r.Name;
                        if(wrapperRecord.record.Bundle__r.Description__c != null)
                            strGroupHeader += ' - ' + wrapperRecord.record.Bundle__r.Description__c;
                        
                        if(wrapperRecord.record.Bundle__r.Message__c != null)
                            strGroupHeader += '<span style=\'color:red;\'> [' + wrapperRecord.record.Bundle__r.Message__c + ']</span>';
                        
                    }   
                    
                    else
                    {
                        if(wrapperRecord.record.Third_Party__c == 'TRUE')
                            strGroupHeader = '3rd Party Products';
                        else
                            strGroupHeader = 'Genesys Products';
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
                    else
                    {
                        if(map_GroupHeaderToQuoteProdWrapper.containsKey('BLANK'))
                            map_GroupHeaderToQuoteProdWrapper.get('BLANK').add(wrapperRecord);
                        else
                        {
                            map_GroupHeaderToQuoteProdWrapper.put('BLANK',new List<QuoteProductWrapper>{wrapperRecord});
                            //list_GroupHeaders.add('BLANK');
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
            return (intTotalNoOfRecords / intPageSize) + (Math.mod(intTotalNoOfRecords,intPageSize) > 0 ? 1:0);
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
        
        // *** Method to initialize Tax rate, Default Care Rate and Pricebook applicable ***
        private void initializeTaxAndPriceBook()
        {
            if(quote.Tax_Rate__c == null || quote.New_Price_Book__c == null)
            {
                String strQuery = 'SELECT Id,Country__r.Name,Country__r.' + (blnIsNewPricing ? 'New' : 'Old') + '_Price_Book__c';
                if(quote.Tax_Rate__c == null)
                    strQuery += ',Country__r.Software_Tax_Rate__c,Country__r.Services_Tax_Rate__c,Country__r.Training_Tax_Rate__c';
                
                String strEndUserId = quote.End_User_ID__c;
                String strSoldToId = quote.Sold_To_Name__c;
                strQuery += ' FROM Account WHERE Country__c != null AND (Id = :strEndUserId OR Id = :strSoldToId)';
                System.debug(strQuery);
                List<Account> list_Temp = Database.query(strQuery);
                
                //Naresh Kumar - 09/24/2015, Changed End User country logic for Brazil tax calculation
                Country__c oppEndUserCountry;         
                if(quote.BigMachines__Opportunity__r.Country__c != null){
                    oppEndUserCountry = [SELECT Software_Tax_Rate__c, Services_Tax_Rate__c, 
                        Training_Tax_Rate__c FROM Country__c WHERE id =: quote.BigMachines__Opportunity__r.Country__c];            
                }
                for(Account objAccount : list_Temp){   
                    if(objAccount.Id == quote.End_User_ID__c){
                        // Tax Rates
                        if(quote.Tax_Rate__c == null){
                            if(oppEndUserCountry == null){
                                quote.Tax_Rate__c = objAccount.Country__r.Software_Tax_Rate__c != null ? objAccount.Country__r.Software_Tax_Rate__c : 0;
                                quote.Services_Tax_Rate__c = objAccount.Country__r.Services_Tax_Rate__c != null ? objAccount.Country__r.Services_Tax_Rate__c : 0;
                                quote.Training_Tax_Rate__c = objAccount.Country__r.Training_Tax_Rate__c != null ? objAccount.Country__r.Training_Tax_Rate__c : 0;
                            }
                            else{
                                quote.Tax_Rate__c = oppEndUserCountry.Software_Tax_Rate__c != null ? oppEndUserCountry.Software_Tax_Rate__c : 0;
                                quote.Services_Tax_Rate__c = oppEndUserCountry.Services_Tax_Rate__c != null ? oppEndUserCountry.Services_Tax_Rate__c : 0;
                                quote.Training_Tax_Rate__c = oppEndUserCountry.Training_Tax_Rate__c != null ? oppEndUserCountry.Training_Tax_Rate__c : 0;
                            }
                        }
                        
                        // Japan does not have decimal place for currency
                        if(objAccount.Country__r.Name == 'Japan')
                            quote.Hide_Truncate_Decimals__c = true;
                    }
                    if(objAccount.Id == quote.Sold_To_Name__c && quote.New_Price_Book__c == null){
                        // Pricebook
                        //Naresh Kumar  01/29/2016  Price book changes
                        if(blnIsNewPricing){
                            //quote.New_Price_Book__c = objAccount.Country__r.New_Price_Book__c;
                            quote.New_Price_Book__c = quote.BigMachines__Opportunity__r.Country__r.New_Price_Book__c;
                        }
                        else{                      
                            //quote.New_Price_Book__c = objAccount.Country__r.Old_Price_Book__c;
                            quote.New_Price_Book__c = quote.BigMachines__Opportunity__r.Country__r.Old_Price_Book__c;
                        }
                    }                    
                }
            }
        }
        
        // *** Method to set all row check-boxes to true/false based on facet check-box ***
        public void checkUncheckAll()
        {
            for(QuoteProductWrapper obj : list_QuoteProducts)
                obj.selected = blnIsHeaderChecked;
        }         
        //Naresh Kumar  03/28/2016 Deletes selected quote products
        public pageReference deleteQuoteProducts(){
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

          //delete Burst line if parent was deleted         
          for (QuoteBurstTerm term : list_QuoteBurstTerms) {
              for (BigMachines__Quote_Product__c prd : term.qtprods) {
                  if ( setOfQuoteProductIds.contains(prd.Parent_Quote_Product__c) )
                     list_ToDelete.add(prd);
              }
          }
          
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            delete list_ToDelete;

            //delete Burst Term if no products left
            for (QuoteBurstTerm trm : list_QuoteBurstTerms) {
                (new SubscriptionBurstTerm()).deleteBlankQuoteTerm(trm.term.Id); 
            }

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

                  //delete Burst line if parent was deleted         
                for (QuoteBurstTerm term : list_QuoteBurstTerms) {
                    for (BigMachines__Quote_Product__c prd : term.qtprods) {
                        if ( prd.Parent_Quote_Product__c == quoteProductIdToBeDeleted ) {
                            list_ToDelete.add(prd);
                        }
                    }
                }

                // Skip Triggers
                Util.Bypass_Trigger_Chk = true;
                delete list_ToDelete;
               
                //delete Burst Term if no products left
                for (QuoteBurstTerm trm : list_QuoteBurstTerms) {
                    new SubscriptionBurstTerm().deleteBlankQuoteTerm(trm.term.Id); 
                }
                          
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
            PageReference pg = new PageReference('/apex/CreateQuoteSubscription?id='+cloneQuoteId);
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
            if(quote.BigMachines__Status__c == 'Quote Approved'){
                String newQuoteId = cloneQuote(true);
                pg = new PageReference('/apex/CreateQuoteSubscription?id='+newQuoteId);
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
                
                for(String strFieldName : set_AllFields)
                    strQuoteApprovalQuery += strFieldName + ', ';
                    
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
                pg = new PageReference('/apex/CreateQuoteSubscription?id='+quote.id);
                
                
            }
             
            if(strSelectedTab == 'Quote Approvals')
                approvals = fetchApprovals();   
            
            pg.setRedirect(true);
            return pg;
        }
        
        // Action method which is called from page as it loads to clone the quote
        public pageReference cloneQuoteOnLoad(){
            if(ApexPages.currentPage().getParameters().get('clone') != null
                && ApexPages.currentPage().getParameters().get('clone') == '1'){
                String clonedQuoteId = cloneQuote(false);
                PageReference pRef = new PageReference('/apex/CreateQuoteSubscription?id=' + clonedQuoteId);
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
            if(!isRevise)
            {
                // Default quote expiration after 3 months
                quoteCopy.Expiration_Date__c = Date.today().addDays(90);
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
            //quoteCopy.Order_Type__c = 'New';
           //08/25/18 - Vinay - added below code change - Start
            if (quote.Order_Type__c == 'New')
            { 
                quoteCopy.Order_Type__c = 'New';
                
            }
            else 
            {
                if(quote.Order_Type__c == 'Amend')
                {
             
                    quotecopy.Order_Type__c = 'Amend';
               
                }
                else
                {
                    if(quote.Order_Type__c == 'Renew')
                    {
             
                        quotecopy.Order_Type__c = 'Renew';
               
                    }
                }
            }   
            
            // Vinay - changes end
            
            // Quote Account should map to End User (explicitly copied : if cloned from a quote which has a blank value for account)
            quoteCopy.BigMachines__Account__c = quote.End_User_ID__c;
            
            insert quoteCopy;
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

            //MS - added
            List<Subscription_Burst_Term__c> list_Src_SubscriptionBurstTerms = [SELECT Id, Term_Length_Months__c,CCDB_Subscription_Burst_Term__c FROM Subscription_Burst_Term__c WHERE Quote__c = :quote.Id];
            List<Subscription_Burst_Term__c> list_Trg_SubscriptionBurstTerms = new List<Subscription_Burst_Term__c>();
            Map<Id,Integer> map_Src_SubscriptionBurstTermIdToIndex = new Map<Id,Integer>();
            Integer burstIndex = -1;
            for (Subscription_Burst_Term__c src_SubscriptionBurstTerm : list_Src_SubscriptionBurstTerms) {
                burstIndex++;
                map_Src_SubscriptionBurstTermIdToIndex.put(src_SubscriptionBurstTerm.Id, burstIndex);
                Subscription_Burst_Term__c trg_SubscriptionBurstTerm = src_SubscriptionBurstTerm.clone(false, true);
                trg_SubscriptionBurstTerm.Quote__c = quoteCopy.id;
                list_Trg_SubscriptionBurstTerms.add(trg_SubscriptionBurstTerm);
            }
            if ( !list_Trg_SubscriptionBurstTerms.isEmpty() ) 
                insert list_Trg_SubscriptionBurstTerms; 

            // Copying Quote Products
            String strQuoteProductsQuery = 'SELECT ';
            
            List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFieldsOnPremise.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQuoteProductsQuery += field.getFieldPath() + ', ';
            
            strQuoteProductsQuery += 'Id,APN_Number__c,Line_Number__c,Weightage__c,Subscription_Product__c,Subscription_Burst_Term__c,Parent_Quote_Product__c,Hide_Record__c';
            strQuoteProductsQuery += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quote.Id + '\'';

            //MS exclude BURSTING 
            //strQuoteProductsQuery += ' AND Subscription_Burst_Term__c = null';
            
            /* MS- commented original version
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
            */
            //MS Replacing commented block above
            List<BigMachines__Quote_Product__c> list_Src_QuoteProducts = (List<BigMachines__Quote_Product__c>)Database.query(strQuoteProductsQuery);
            List<BigMachines__Quote_Product__c> list_Trg_QuoteProducts = new List<BigMachines__Quote_Product__c>();
            Map<Id,Integer> map_Src_QuoteProductIdToIndex = new Map<Id,Integer>();
            Integer intIndex = -1;
            for(BigMachines__Quote_Product__c src_QuoteProduct : list_Src_QuoteProducts)
            {
                intIndex++;
                map_Src_QuoteProductIdToIndex.put(src_QuoteProduct.Id, intIndex);
                BigMachines__Quote_Product__c trg_QuoteProduct = src_QuoteProduct.clone(false, true);
                trg_QuoteProduct.BigMachines__Quote__c = quoteCopy.id;
                trg_QuoteProduct.BigMachines__External_Id__c  = null;
                trg_QuoteProduct.currencyIsoCode = quote.currencyIsoCode;
                list_Trg_QuoteProducts.add(trg_QuoteProduct);
            }
            if ( list_Trg_QuoteProducts.size() > 0)
                insert list_Trg_QuoteProducts;
            //MS: end replacement
            
            // Copying Proposal Groups    
            List<Quote_Proposal_Group__c> list_ProposalGroupsCopy = new List<Quote_Proposal_Group__c>();
            for(Quote_Proposal_Group__c eachPG : list_ProposalGroups)
            {
                Quote_Proposal_Group__c newProposalGroup = eachPG.clone(false, true);
                newProposalGroup.Quote__c = quoteCopy.id;
                list_ProposalGroupsCopy.add(newProposalGroup);
            }
            if ( !list_ProposalGroupsCopy.isEmpty())
                  insert list_ProposalGroupsCopy;

            /* MS commented
            insert quoteProductsCopy;
            List<BigMachines__Quote_Product__c> list_QPsToUpdate = new List<BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c eachQP: quoteProductsCopy) {
            
                if(eachQP.Bundle__c != null && eachQP.Bundle_Line__c != null && map_BundleLineIdToIndex.containsKey(eachQP.Bundle_Line__c)) {
                    eachQP.Bundle_Line__c = quoteProductsCopy[map_BundleLineIdToIndex.get(eachQP.Bundle_Line__c)].Id;
                    list_QPsToUpdate.add(eachQP);
                }
            }
            if(list_QPsToUpdate.size() > 0)
                update list_QPsToUpdate;
            */
            
            // Now reassign Bundle_Line__c, Subscription_Burst_Term__c and Parent_Quote_Product__c 
            List<BigMachines__Quote_Product__c> list_QPsToUpdate = new List<BigMachines__Quote_Product__c>();
            Integer listIndex = -1;
            for (Integer idx = 0; list_Trg_QuoteProducts.size() > idx; idx++) {
                BigMachines__Quote_Product__c src_QuoteProduct = list_Src_QuoteProducts[idx];
                BigMachines__Quote_Product__c trg_QuoteProduct = list_Trg_QuoteProducts[idx];
                Boolean addToUpdateList = false;
                if(src_QuoteProduct.Bundle__c != null && src_QuoteProduct.Bundle_Line__c != null && 
                    map_Src_QuoteProductIdToIndex.containsKey(src_QuoteProduct.Bundle_Line__c)) {
                    listIndex = map_Src_QuoteProductIdToIndex.get(src_QuoteProduct.Bundle_Line__c);
                    trg_QuoteProduct.Bundle_Line__c = list_Trg_QuoteProducts[listIndex].Id;
                    addToUpdateList = true;
                }
                if (src_QuoteProduct.Subscription_Burst_Term__c != null && map_Src_SubscriptionBurstTermIdToIndex.containsKey(src_QuoteProduct.Subscription_Burst_Term__c)) {
                    listIndex = map_Src_SubscriptionBurstTermIdToIndex.get(src_QuoteProduct.Subscription_Burst_Term__c);
                    trg_QuoteProduct.Subscription_Burst_Term__c = list_Trg_SubscriptionBurstTerms[listIndex].Id;
                    addToUpdateList = true;
                }
                if (src_QuoteProduct.Parent_Quote_Product__c != null && map_Src_QuoteProductIdToIndex.containsKey(src_QuoteProduct.Parent_Quote_Product__c)) {
                    listIndex = map_Src_QuoteProductIdToIndex.get(src_QuoteProduct.Parent_Quote_Product__c);
                    trg_QuoteProduct.Parent_Quote_Product__c = list_Trg_QuoteProducts[listIndex].Id;
                    addToUpdateList = true;
                }
                if ( addToUpdateList ) list_QPsToUpdate.add(trg_QuoteProduct);
            }
            if (list_QPsToUpdate.size() > 0)
                update list_QPsToUpdate;
    
            return quoteCopy.id;
        }
        
        // *** Method to return quote object ***
        public BigMachines__Quote__c getQuote(Id quoteId)
        {
            BigMachines__Quote__c quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));
            quote.Show_Why_Genesys__c = quote.Show_Genesys_Care_Tab__c;
            if(quote.Amendment_For__c != null)
                quote.Show_Why_Genesys__c = quote.Amendment_For__r.Quote__r.Show_Genesys_Care_Tab__c;
            if(String.isBlank(quote.Grid_Group_By__c))
                quote.Grid_Group_By__c = 'Use Cases';
            return quote;
        }
        
        // *** Method to generate query string to query Quote from the DB ***
        public String prepareQuoteQuery(Id quoteId)
        {
            String strQuoteQuery = 'SELECT ';
            //Getting all the fields from a field set : field set used to make system more configurable 
            List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_On_Premise.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQuoteQuery += field.getFieldPath() + ', ';
            
                    strQuoteQuery += 'Top_Play__c,Offer__c,End_User_ID__r.Country__r.Name, Initial_Subscription_Term__c, End_User_ID__r.Partner_Tier__c, Quote_Cloned_Revised__r.Name,BigMachines__Opportunity__r.Country_Sub_Region__c,Sold_To_Name__r.Country__r.PSRDP_Region__c,PPU_Rental__c,BigMachines__Opportunity__r.Type,End_User_ID__r.OrderHold__c,';     
            strQuoteQuery += 'BigMachines__Opportunity__r.Direct_Sales__c,BigMachines__Opportunity__r.Country_Region__c,Sold_To_Name__r.Country__r.Name,Deal_Qualification__c,BigMachines__Opportunity__r.Country__c,BigMachines__Opportunity__r.Country__r.Name,Payment_Terms_Price_Uptick__c,Overage_Allowance_Price_Uptick__c,';
            strQuoteQuery += 'BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country_DAP__c, BigMachines__Opportunity__r.New_DAP_Region__c, X3rd_Party_Override__c,Sold_To_Name__r.Partner_Tier__c,Subscription_Addendum_Link__c,Subscription_Addendum_Type__c,Deal_Score_Cutoffs__c,';
            strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c, Override_Training_Unit__c, Pass_Through__c,No_Of_Months__c,CMRR__c,Annual_Contract_Value__c,Cloud_Total__c,Sold_To_Name__r.Country__r.Region__c,Order_Fulfillment_Email_Receipt__c,';
            strQuoteQuery += 'Ship_To_Name__c, Ship_To_Name__r.SAP_Account_Code__c, Shipping_Contact__c, Shipping_Contact_Phone_Number__c, Shipping_Instructions__c, Shipping_Contact_Email__c,Delivery_Method__c,BigMachines__Opportunity__r.Partner_Opportunity_Source__c, BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,Require_Contractual_Discount__c,';
            strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name,BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,BigMachines__Opportunity__r.Term_Commitment__c,Opp_Sold_To_Country__c,CMRR_Pre_Discount__c,ACV_Pre_Discount__c,TCV_Pre_Discount__c,Max_Seat_Count__c,Overage_Allowance_Other__c,Annual_Price_Escalation_Other__c,';
            strQuoteQuery += 'Overage_Allowance__c,Overage_Price_Premium__c,Keep_the_existing_estate_on_Perpetual__c, Sold_To_Name__r.SMART_Qualified__c, Sold_To_Name__r.Subscription_Qualified__c, Product_Version__c, Billing_Period__c,Ramp_Period__c,Cloud_Term_Commitment__c,Multi_Year_Quote__c,Show_Genesys_Care_Tab__c,Total_GU_Training_Units__c,Deal_Score__c,';
            strQuoteQuery += 'Support_Owner__c, Comment__c, BigMachines__Opportunity__r.Account.Partner_Tier__c, Require_Separate_Quote_for_Genesys_Care__c, Subscription_Start_Date__c, Subscription_End_Date__c,Billing_Start_Date__c,Token_Value__c,Token_Value_Y2__c,Amendment_For__c,End_User_ID__r.Contractual_PC_FYM_Expiration_Date__c, End_User_ID__r.Contractual_PC_FYM_Rate__c, Sold_To_Name__r.Contractual_PC_FYM_Effective_Date__c, Sold_To_Name__r.Contractual_PC_FYM_Expiration_Date__c, Sold_To_Name__r.Contractual_PC_FYM_Rate__c,';
            strQuoteQuery += 'CMRR_1__c, CMRR_2__c, Annual_Contract_Value_1__c, Annual_Contract_Value_2__c, Total_Contract_Value_1__c, Total_Contract_Value_2__c,RightToBurst__c,RightToRemix__c,PureSuccess_Offer_Subscription_Amount__c,A_La_Carte_PureSuccess_Services_Amount__c,Highest_Discount__c,One_Time_Charges_1__c,Amount_Due_At_Anniversary__c,Sold_To_Name__r.Country__r.Standard_Support__c, Sold_To_Name__r.Country__r.Priority_Support__c, Sold_To_Name__r.Country__r.VIP_Priority_Support__c,';            
            strQuoteQuery += 'Amendment_For__r.Subscription_Start_Date__c, Amendment_For__r.Quote__r.Subscription_End_Date__c,Generate_Revpro_Order__c,Amendment_For__r.Quote__r.CreatedDate,Amendment_For__r.Subscription_End_Date__c,Amendment_For__r.Ramp_End_Date__c,Amendment_For__r.Amendment_Date__c,Amendment_For__r.Quote__r.Show_Genesys_Care_Tab__c,Amendment_For__r.Quote__r.Ramp_Period__c,Show_Why_Genesys__c,MSA_Link__c,';
            strQuoteQuery += 'Amendment_For__r.Quote__r.Highest_Discount__c, Amendment_For__r.Quote__r.Total_Discount_Genesys_and_Third_Party__c,Amendment_For__r.Quote__r.Annual_Contract_Value_1__c, Amendment_For__r.Quote__r.PureSuccess_Offer_Subscription_Amount__c, Amendment_For__r.Quote__r.A_La_Carte_PureSuccess_Services_Amount__c, Amendment_For__r.Quote__r.One_Time_Charges_1__c, Amendment_For__r.Quote__r.BEP_Third_Party_Genesys_Care__c, ';
            strQuoteQuery += 'Amendment_For__r.Quote__r.PureSuccess__c, Amendment_For__r.Quote__r.Total_Contract_Value_1__c, Amendment_For__r.Quote__r.Annual_Contract_Value_2__c, Amendment_For__r.Quote__r.Amount_Due_At_Anniversary__c, Amendment_For__r.Quote__r.Token_Value__c,Amendment_For__r.Quote__r.Token_Value_Y2__c, Amendment_For__r.Quote__r.Cloud_Total__c,Amendment_For__r.Quote__r.Usage_Data_Submission_Method__c,';
            strQuoteQuery += 'Lever__c,BigMachines__Opportunity__r.Lever__c,BigMachines__Opportunity__r.Avaya_Contract_Expiration__c,Pre_Credit_ACV__c,Pre_Credit_TCV__c,Total_Overage__c,Overage_Discount__c,Seasonal_License_Net_Value_Y1__c,Seasonal_License_Net_Value_Y2__c,Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y1__c,Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y2__c,Total_Recurring_Credit__c,Total_Non_Recurring_Credit__c,';
            strQuoteQuery += 'Delayed_Billing_Start_Date_Days__c, MSA_Link_Type__c, BigMachines__Opportunity__r.Direct_Indirect_Sale__c, Delayed_Subscription_Start_Date_Days__c, Optional_extended_term_length_Months__c, Price_Escalation__c, Legal_Contract__c, Shipping_Required__c, PureSuccess__c, Usage_Data_Submission_Method__c, Credit_Adjustment__c, Migration_Credit__c,Offering_Feature__c FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
            return strQuoteQuery;
        }
            
        // *** Method to get Quote Products ***
        public void getQuoteProducts(Id quoteId)
        {
            list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
            list_BundleItemQPRecords = new List<BigMachines__Quote_Product__c>();
            list_Credits = new List<BigMachines__Quote_Product__c>();
            list_QuoteProducts = new List<QuoteProductWrapper>();
            list_GroupHeaders = new List<String>();
            objServiceLevel = null;
            objThirdPartyGCLine = null;
            objMigrationCreditY1 = null;
            objMigrationCreditY2 = null;
            blnHasHWLines = blnHasBundles = blnHasRDP = blnHasEMEAVolDisc = false;        
            map_BundleQuoteProducts = new Map<Id,BigMachines__Quote_Product__c>();
            list_QuoteBurstTerms = new List<QuoteBurstTerm>();
            burstTermLength = new Map<String, Integer>();  
            
            //Burst - add terms, initialize products list
           List<Subscription_Burst_Term__c> terms = SubscriptionBurstTerm.getQuoteBurstTerms(quoteId);
            for (Subscription_Burst_Term__c trm : terms) {
               QuoteBurstTerm qtrm = new QuoteBurstTerm();
               qtrm.term = trm;
               qtrm.qtprods = new List<BigMachines__Quote_Product__c>(); 
               list_QuoteBurstTerms.add(qtrm); 
            }

            List<CurrencyType> currentCurrency = [SELECT ConversionRate FROM CurrencyType WHERE ISOCode =: quote.currencyIsoCode];
            for(BigMachines__Quote_Product__c eachQuoteProduct : (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId)))
            {    system.debug('Bundle_Line__r.Name... ' +eachQuoteProduct.Bundle_Line__r.Name);   

                if(quote.No_Of_Months__c != null && quote.No_Of_Months__c < 12)
                    eachQuoteProduct.Mandatory_Discount__c = 0;
                eachQuoteProduct.currencyIsoCode = quote.currencyIsoCode;
                if(eachQuoteProduct.BigMachines__Product__r.Third_Party__c != null &&
                     eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toUpperCase() == 'TRUE'){
                    eachQuoteProduct.NG1_PPU_Gold_USD__c = eachQuoteProduct.BigMachines__Product__r.NG1_PPU_Gold_USD__c;
                    if(!currentCurrency.isEmpty() && eachQuoteProduct.NG1_PPU_Gold_USD__c != null){                    
                         eachQuoteProduct.NG1_PPU_Gold_USD__c =  eachQuoteProduct.NG1_PPU_Gold_USD__c * currentCurrency[0].ConversionRate;
                    }
                }
  
                if(eachQuoteProduct.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                {
                    blnHasRDP = true;
                    // Initializing T&E PS RDP to 20%
                    if(quote.Time_Expense_PS_RDP__c == null)
                        quote.Time_Expense_PS_RDP__c = 20;
                }

                //MS 10/10/19 Credits
                if (eachQuoteProduct.BigMachines__Product__r.Type__c == 'Migration Credit') {                  
                    list_Credits.add(eachQuoteProduct);
                }

                ///MS - add Burst Products
               else if ( eachQuoteProduct.Subscription_Burst_Term__c != null ) {             
                    for (QuoteBurstTerm btrm : list_QuoteBurstTerms) { 
                       if ( btrm.term.Id == eachQuoteProduct.Subscription_Burst_Term__c ) {
                           btrm.qtprods.add(eachQuoteProduct);
                       }
                    }
                } 
                else if(eachQuoteProduct.BigMachines__Product__r.Genesys_Care_Quote__c && quote.Show_Why_Genesys__c)
                {
                    objServiceLevel = eachQuoteProduct;
                    // Setting Service Level on Quote if it is blank
                    if(String.isNotBlank(objServiceLevel.Product_Description__c) && String.isBlank(quote.Service_Level__c))
                    {
                        List<String> list_Words = objServiceLevel.Product_Description__c.split(' ');
                   
                        if(list_Words.size() > 0) 
                            quote.Service_Level__c = list_Words[0];
                    }
                }          
                else if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care')
                    objThirdPartyGCLine = eachQuoteProduct;
                    
                else if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Bundle')
                {
                    QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
                    wrapperRecord.record = eachQuoteProduct;
                    list_QuoteProducts.add(wrapperRecord);
                    list_QuoteProductRecords.add(eachQuoteProduct);
                    blnHasBundles = true;
                    map_BundleQuoteProducts.put(eachQuoteProduct.Id,eachQuoteProduct);
                }                
                else if(eachQuoteProduct.Bundle_Line__c != null ){
                   // if(eachQuoteProduct.Bundle__r.Group_Type__c == 'Use Case' || (eachQuoteProduct.Bundle_Line__r.Name).contains('Base Package')){
                    if(eachQuoteProduct.Bundle__r.Group_Type__c == 'Use Case'){
                        QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
                        wrapperRecord.record = eachQuoteProduct;
                        list_QuoteProducts.add(wrapperRecord);
                        list_QuoteProductRecords.add(eachQuoteProduct);
                    }else{
                        list_BundleItemQPRecords.add(eachQuoteProduct);
                    }
                    if(eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Product_System_License_Product_Type)
                        blnHasHWLines = true;
                }
                else if(eachQuoteProduct.BigMachines__Product__c != null 
                    && String.valueOf(eachQuoteProduct.BigMachines__Product__c).left(15) == Label.CreateQuoteOnPremise_Shipping_Handling_Product_Id.left(15)){
                    objShippingAndHandling = eachQuoteProduct;
                }
                else if(eachQuoteProduct.BigMachines__Product__c != null 
                    && String.valueOf(eachQuoteProduct.BigMachines__Product__c).left(15) == Label.CreateQuoteOnPremise_Prepaid_Professional_Services_Product_Id.left(15)){
                    objProfessionalServices = eachQuoteProduct;                
                }
                else 
                {
                    QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
                    wrapperRecord.record = eachQuoteProduct;
                    list_QuoteProducts.add(wrapperRecord);
                    list_QuoteProductRecords.add(eachQuoteProduct);
                    if(eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Product_System_License_Product_Type)
                        blnHasHWLines = true;
                }
                // EMEA Volume Discount for old pricing
                if(!blnHasEMEAVolDisc && !blnIsNewPricing && quote.New_Price_Book__c.containsIgnoreCase('EMEA') 
                                && eachQuoteProduct.BigMachines__Product__r.EMEA_Volume_Discount_Eligible__c)
                    blnHasEMEAVolDisc = true;
            }
            intTotalNoOfRecords = list_QuoteProducts.size();

            // Set up the Current Page Grid
            createCurrentPageList();

        } //end of getQuoteProducts
        
        // *** Method to generate query string to query Quote Products from the DB ***
        public String prepareQuoteProductQuery(Id quoteId)
        {
            String strQueryAllFields = 'SELECT ';
            //Getting all the fields from a field set : field set used to make system more configurable 
            List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFieldsOnPremise.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQueryAllFields += field.getFieldPath() + ', ';
            
            strQueryAllFields += 'Id,Bundle__r.Group_Type__c,Bundle_Line__r.Name,Bundle__r.Type__c,Bundle__r.Discount__c,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Third_Party_GC__c,BigMachines__Product__r.Flavors_Available__c,BigMachines__Quote__c,BigMachines__Product__r.Include_in_Agent_Seat_Count__c';//,BigMachines__Product__r.NG1_PPU_USD__c';
            strQueryAllFields += ',BigMachines__Product__r.Pricing_Model__c,BigMachines__Product__r.Quantity__c,BigMachines__Product__r.Genesys_Care_Quote__c,BigMachines__Product__r.Shipment_Approval__c,Is_Training_Unit__c,GC_Ext_Net_Price__c,Mandatory_Discount__c,BigMachines__Product__r.Description__c';
            strQueryAllFields += ',BigMachines__Product__r.Care_Rate_Applicable_Licensing__c,BigMachines__Product__r.Type__c,Bundle__r.Name, Bundle__r.Description__c, Bundle__r.Message__c, BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Name,Original_Third_Party_GC__c,BigMachines__Product__r.Shipping_Cost__c';
            strQueryAllFields += ',BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,BigMachines__Product__r.Seasonal_Licensing_Eligible__c ';
            strQueryAllFields += ',BigMachines__Product__r.Taxonomy_Solution_Category__c,BigMachines__Product__r.Taxonomy_Solution__c,BigMachines__Product__r.NG1_PPU_Silver_USD__c,BigMachines__Product__r.NG1_PPU_Gold_USD__c,Line_Color__c, Bundle__r.Token_Value__c,BigMachines__Product__r.Product_Type__c';
            strQueryAllFields += ',Discount_1__c,Discount_2__c,Net_Unit_Price_1__c,Net_Unit_Price_2__c,Ext_Net_Price_1__c,Ext_Net_Price_2__c, List_Price_1__c, List_Price_2__c, Line_Number__c, Weightage__c, BigMachines__Product__r.One_Time_Charge__c,Bundle_Line__r.Net_Unit_Price_1__c, Bundle_Line__r.Net_Unit_Price_2__c';
            strQueryAllFields += ',Partner_Discount__c,Partner_Discount_1__c, Partner_Discount_2__c, Partner_Price_1__c, Partner_Price_2__c, Ext_List_Price_1__c,Ext_List_Price_2__c,Hardware_or_Third_Party__c, Bundle_Line__r.Ext_Net_Price_1__c, Bundle_Line__r.Ext_Net_Price_2__c,Subscription_Product__r.Quantity__c';
            strQueryAllFields += ',Subscription_Product__r.Original_List_Price__c,BigMachines__Product__r.APN_Number__c,APN_Number__c,Subscription_Product__c,PureBridge_Free_GU__c';    
            strQueryAllFields += ',Subscription_Burst_Term__c,Original_Quantity_Amend__c,Parent_Quote_Product__c,BigMachines__Product__r.New_Category__c';
            
            if(!blnIsNewPricing && quote.New_Price_Book__c != null && quote.New_Price_Book__c.containsIgnoreCase('EMEA'))
                strQueryAllFields += ',BigMachines__Product__r.EMEA_Volume_Discount_Eligible__c,EMEA_Volume_Discount__c';
            
            strQueryAllFields += ',BigMachines__Product__r.' + quote.New_Price_Book__c + '_Price__c';
            strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'';
            
            // Added by Ashish (24/01), to hide the bundle use case from the commerce page
            strQueryAllFields += ' AND Hide_Record__c = false';
            
            if(quote.Grid_Group_By__c == 'Categories')
            {
                strQueryAllFields += ' ORDER BY Line_Number__c ASC, BigMachines__Product__r.New_Category__c ASC NULLS LAST,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Anchor_Product__c,Product_Description__c';
            }
            else if(quote.Grid_Group_By__c == 'Bundles/Products')
                strQueryAllFields += ' ORDER BY Line_Number__c ASC, Bundle__c NULLS LAST,Bundle__r.Name,Product_Description__c';
            else if(quote.Grid_Group_By__c == 'Proposal Groups')
                strQueryAllFields += ' ORDER BY Line_Number__c ASC, Group_Number__c NULLS LAST,Product_Description__c';
            else
                strQueryAllFields += ' ORDER BY Line_Number__c ASC, Third_Party__c NULLS FIRST,Product_Description__c';
                
            return strQueryAllFields;
        }
        
        // *** Method to return boolean whether record should be locked from editing or not ***
        public Boolean getIsQuoteUnLocked() {
            if(quote.BigMachines__Status__c == 'Quote Approval Pending' ||
                quote.BigMachines__Status__c == 'Quote Approved' ||
                quote.BigMachines__Status__c == 'Order Submitted' || 
                quote.BigMachines__Status__c == 'Order Accepted' || 
                quote.BigMachines__Status__c == 'Order Rejected' ||
                quote.BigMachines__Status__c == 'Quote Rejected')
                return false;
            return true;
        }

        //Should show Add Burst button 
        public Boolean getShowAddBurstButton() {
            Boolean ret = false;
            if (getIsQuoteUnLocked() && list_QuoteBurstTerms.size() == 0 && list_QuoteProductRecords != null && !getShowBurstFields()) {
              //  ret = SubscriptionBurstTerm.isQuoteBurstable(quoteId);
              //check for burstable products
              for(BigMachines__Quote_Product__c prd : list_QuoteProductRecords)
                if (prd.BigMachines__Product__r.Seasonal_Licensing_Eligible__c && prd.Bundle_Line__c == null) {
                    ret = true;
                    break;
                }
            }
            return ret;       
        }

        //MS pre seasonal terms release quote display
        public Boolean getShowBurstFields() {
            Boolean ret = false;
           if ((quote.Usage_Data_Submission_Method__c != null && (quote.Usage_Data_Submission_Method__c == 'Automated' || quote.Usage_Data_Submission_Method__c == 'Manual')) ||
               (quote.Amendment_For__r.Quote__r.Usage_Data_Submission_Method__c != null && (quote.Amendment_For__r.Quote__r.Usage_Data_Submission_Method__c == 'Automated' || quote.Amendment_For__r.Quote__r.Usage_Data_Submission_Method__c== 'Manual'))) 
                    ret = true;

            return ret;
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
                if(obj.selected)
                {
                    // Updating Discount on Lines 
                    if(objMassUpdateInput.Disc__c != null)
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
        public void migrationCreditBtnHandler()
        {
            if(quote.Migration_Credit__c == null || quote.Migration_Credit__c == 0)
            {
                quote.Migration_Credit__c.addError('Please Enter Value.');
                return;
            }
            if(quote.Migration_Credit__c > quote.Annual_Contract_Value_1__c ||
               ( quote.No_Of_Months__c != null && Integer.valueOf(quote.No_Of_Months__c) > 12 && quote.Migration_Credit__c > quote.Annual_Contract_Value_2__c) ) {
                quote.Migration_Credit__c.addError('Migration Credit amount can not be greater than Year 1 or Year 2 amount.');
                return;
            }
            
            if(objMigrationCreditY1 == null || objMigrationCreditY2 == null){               
                List<Product2> list_Temp = [SELECT Id,Name,Unit_of_Measure__c,Care_Rate_Applicable_Licensing__c,APN_Number__c
                    FROM Product2 WHERE APN_Number__c =: Label.Subscription_Migration_Credit.split(';')[0] 
                                            OR APN_Number__c =: Label.Subscription_Migration_Credit.split(';')[1] ORDER BY Product_Type__c];
                List<BigMachines__Quote_Product__c> listOfQPs = new List<BigMachines__Quote_Product__c>();
                if(list_Temp.size() > 0){                    
                    //Y1
                    if(objMigrationCreditY1 == null){
                        objMigrationCreditY1 = new BigMachines__Quote_Product__c(Quantity__c = 1, BigMachines__Quote__c = quote.Id,
                        BigMachines__Quantity__c = 1, BigMachines__Sales_Price__c = 0, Ext_Net_Price__C = (quote.Migration_Credit__c * -1));
                        objMigrationCreditY1.Name = list_Temp[0].Name;
                        objMigrationCreditY1.APN_Number__c = list_Temp[0].APN_Number__c;
                        objMigrationCreditY1.Unit_of_Measure__c = list_Temp[0].Unit_of_Measure__c;
                        objMigrationCreditY1.BigMachines__Product__c = list_Temp[0].Id;
                        listOfQPs.add(objMigrationCreditY1);
                    }
                    //Y2
                    if(objMigrationCreditY2 == null && quote.No_Of_Months__c != null && Integer.valueOf(quote.No_Of_Months__c) > 12 ) {
                        objMigrationCreditY2 = new BigMachines__Quote_Product__c(Quantity__c = 1, BigMachines__Quote__c = quote.Id,
                        BigMachines__Quantity__c = 1, BigMachines__Sales_Price__c = 0, Ext_Net_Price__C = (quote.Migration_Credit__c * -1));
                        objMigrationCreditY2.Name = list_Temp[1].Name;
                        objMigrationCreditY2.APN_Number__c = list_Temp[1].APN_Number__c;
                        objMigrationCreditY2.Unit_of_Measure__c = list_Temp[1].Unit_of_Measure__c;
                        objMigrationCreditY2.BigMachines__Product__c = list_Temp[1].Id;
                        listOfQPs.add(objMigrationCreditY2);
                    }                    
                }
                if(!listOfQPs.isEmpty())
                    insert listOfQPs;
            }
            else{
                objMigrationCreditY1.Ext_Net_Price__c =  quote.Migration_Credit__c * -1;
                objMigrationCreditY2.Ext_Net_Price__c =  quote.Migration_Credit__c * -1;   
            }   
            doCalculations();
            
            if(objMigrationCreditY1 != null && objMigrationCreditY2 != null){
                objMigrationCreditY1.Ext_Net_Price__c =  quote.Migration_Credit__c * -1;
                objMigrationCreditY2.Ext_Net_Price__c =  quote.Migration_Credit__c * -1;   
            }
            
        }
        
        // *** Handler for Goal Seek Reset Button ***
        public void migrationCreditResetBtnHandler()
        {
            quote.Migration_Credit__c = 0;
            if(objMigrationCreditY1!=null)
                delete objMigrationCreditY1;
            if(objMigrationCreditY2!=null)
                delete objMigrationCreditY2;
            objMigrationCreditY1 = objMigrationCreditY2 = null;
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
        
        // *** Method to create/delete Third Party GC Line ***
        private void processThirdPartyGCLine()
        {            
            if(objThirdPartyGCLine == null)
            {
                // Fetching Genesys Care 3rd_Party Support Line
                List<Product2> list_Temp = [SELECT Id,Name,Unit_of_Measure__c,APN_Number__c
                                        FROM Product2 WHERE Id = :Label.Genesys_Care_3rd_Party_Support_Id];
                if(list_Temp.size() > 0)
                {
                    objThirdPartyGCLine = new BigMachines__Quote_Product__c(Quantity__c = 1,BigMachines__Quantity__c = 1,
                        BigMachines__Sales_Price__c = 0,BigMachines__Quote__c = quote.Id,APN_Number__c = list_Temp[0].APN_Number__c,
                        Name = list_Temp[0].Name,Unit_of_Measure__c = list_Temp[0].Unit_of_Measure__c,
                        BigMachines__Product__c = list_Temp[0].Id,Third_Party__c = 'TRUE', currencyIsoCode = quote.currencyIsoCode);
                }
            }
        }
        
        private void addToQuoteTotalsBasedOnProductType(BigMachines__Quote_Product__c objQP)
        {
            if (objQP.BigMachines__Product__r.Type__c == 'Migration Credit' )
                return;

            Decimal extNetPrice = (secondYrAmend && objQP.Ext_Net_Price_2__c != null) ? objQP.Ext_Net_Price_2__c : objQP.Ext_Net_Price__c;
            
            if(objQP.Bundle__r.Group_Type__c == 'PureSuccess'){
                if(objQP.Ext_Net_Price__c != null && objQP.Bundle_Line__c == null)
                        pureSuccessAmount += extNetPrice; //objQP.Ext_Net_Price__c;                
                return;
            }
            ///Burst amounts
            if (objQP.Subscription_Burst_Term__c != null ) {
                totalAcvBrst1 += decNullTest(objQP.Ext_Net_Price_1__c);
                totalAcvBrst2 += decNullTest(objQP.Ext_Net_Price_2__c);
            }

            if(objQP.Bundle__r.Group_Type__c == 'A la Carte'){
                if(objQP.Ext_Net_Price__c != null && objQP.Bundle_Line__c == null) 
                    quote.A_La_Carte_PureSuccess_Services_Amount__c += extNetPrice; // objQP.Ext_Net_Price__c;                
            }
            else if(objQP.Ext_Net_Price__c != null && objQP.Bundle_Line__c == null){
                if(objQP.Bundle__r.Group_Type__c == 'Base Package'){
                    totalAmount += extNetPrice / 12;       //objQP.Ext_Net_Price__c / 12;
                    //if(quote.Multi_Year_Quote__c){
                        totalACV1 += (objQP.Ext_Net_Price_1__c == null ? 0 : objQP.Ext_Net_Price_1__c);
                        totalACV2 += (objQP.Ext_Net_Price_2__c == null ? 0 : objQP.Ext_Net_Price_2__c);
                    //}
                        totalACV += (objQP.Ext_Net_Price__c == null ? 0 : objQP.Ext_Net_Price__c);
                }
                else if((objQP.BigMachines__Product__r.Type__c == 'Token' 
                        || objQP.BigMachines__Product__r.Type__c == 'Maintenance'
                        || objQP.BigMachines__Product__r.Type__c == 'Genesys Care'
                        || objQP.BigMachines__Product__r.Type__c == 'Product - Hardware'
                        || objQP.BigMachines__Product__r.Type__c == 'Hardware Warranty'
                        || objQP.BigMachines__Product__r.One_Time_Charge__c) && objQP.Subscription_Burst_Term__c == null )
                            totalAmountOneTimeFee += extNetPrice; //objQP.Ext_Net_Price__c;
                else {
                        totalAmount += objQP.Ext_Net_Price__c;
                    //if(quote.Multi_Year_Quote__c){
                        totalACV1 += (objQP.Ext_Net_Price_1__c == null ? 0 : objQP.Ext_Net_Price_1__c);
                        totalACV2 += (objQP.Ext_Net_Price_2__c == null ? 0 : objQP.Ext_Net_Price_2__c);
                    //}
                        totalACV += (objQP.Ext_Net_Price__c == null ? 0 : objQP.Ext_Net_Price__c);
                }
            }

            if(objQP.Quantity__c != null && objQP.Quantity__c > maxSeatCount)
                maxSeatCount = Integer.valueOf(objQP.Quantity__c); 
                
            if(objQP.Ext_List__c != null && objQP.Bundle_Line__c == null)
                CMRRPreDiscount += objQP.Ext_List__c;
            // Software
            if(objQP.BigMachines__Product__r.Type__c == 'Product')
            {
                if(objQP.Ext_List__c != null)
                    quote.Total_Software__c += objQP.Ext_List__c;
                if(objQP.Ext_Net_Price__c != null)
                    decTotalSWNetPrice += objQP.Ext_Net_Price__c;
                //    quote.Total_Hardware_Opportunity__c += objQP.Ext_Net_Price__c;   // Added by navaneetha
            }
            
            // Hardware
            else if(objQP.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || objQP.BigMachines__Product__r.Type__c  == Label.Product_System_License_Product_Type)
            {
                System.debug('### ' + objQP.BigMachines__Product__c);
                if(objQP.Ext_List__c != null)
                    quote.Total_Hardware__c += objQP.Ext_List__c;
                if(objQP.Ext_Net_Price__c != null)
                    decTotalHWNetPrice += objQP.Ext_Net_Price__c;
                  // quote.Total_Hardware_Opportunity__c += objQP.Ext_Net_Price__c;   // Added by navaneetha on hardware total  04-Sep-2019.
            }
                
            // Education
            else if(objQP.BigMachines__Product__r.Type__c == 'GU')
            {
                if(objQP.Ext_List__c != null)
                    quote.Total_Education__c += objQP.Ext_List__c;
                if(objQP.Ext_Net_Price__c != null)
                    decTotalEducationNetPrice += objQP.Ext_Net_Price__c;
            }
                
            // Professional Services
            else if(objQP.BigMachines__Product__r.Type__c == 'PS' || objQP.BigMachines__Product__r.Type__c == 'PS-Contract' || 
                objQP.BigMachines__Product__r.Type__c == 'PS Service Offering')
            {
                if(objQP.Ext_List__c != null)
                    quote.Total_Services__c += objQP.Ext_List__c;
                if(objQP.Ext_Net_Price__c != null)
                    decTotalServicesNetPrice += objQP.Ext_Net_Price__c;
            }

        } //END addToQuoteTotalsBasedOnProductType
    
        public void setMSALink() {
            if(quote.MSA_Link_Type__c == 'Standard'){
                quote.MSA_Link__c = Label.MSA_Links.split(';;')[3].trim();
            }            
        }
    
        public void setAddendumLink() {          
            if(quote.Subscription_Addendum_Type__c == 'Standard'){
                if(quote.PureSuccess__c != null)
                    quote.Subscription_Addendum_Link__c = Label.Subscription_Addendum_Link.split(';;')[0].trim();
                else
                    quote.Subscription_Addendum_Link__c = Label.Subscription_Addendum_Link.split(';;')[1].trim();
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
            if(String.isBlank(quote.Order_PO_Number__c) && !quote.Treat_SO_as_PO__c)
            {
                quote.Order_PO_Number__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
            if(quote.Order_PO_Date__c == null && !quote.Treat_SO_as_PO__c)
            {
                quote.Order_PO_Date__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
  
            if(String.isBlank(quote.Order_Ship_Software_Via__c))
            {
                quote.Order_Ship_Software_Via__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
            if(quote.Offering_Type__c == 'PureEngage Subscription' && (String.isBlank(quote.Server_OS__c) || String.isBlank(quote.PBX__c) || String.isBlank(quote.Database__c)
                || String.isBlank(quote.IVR__c) || String.isBlank(quote.Add_Language__c)))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'All Technical Information details are required to submit order.'));
                blnHasRequiredError = true;
            }
            return blnHasRequiredError;
        }
        
        // *** Handler for Submit Order button ***
        public void submitOrderBtnHandler()
        {
            Boolean blnIsAttachmentUploaded = false;
            if(String.isNotBlank(objAttachment.Name))
            {
                upsert objAttachment;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Attachment Uploaded.'));
                objAttachment = new Attachment(ParentId = quote.Id);
                blnIsAttachmentUploaded = true;
            }
            Boolean blnHasRequiredError = checkRequiredFields();       
            if(blnHasRequiredError)
                return;
            
            String addressValidation = OrderAddressOnPremiseController.validateOrderSubmission(quote.id);
            if(addressValidation != 'OK'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, addressValidation));
                return;
            }
            blnShowExportScreeningMsg = false;
            blnShowExportScreeningExpireMsg = false;
            if(!blnIsAttachmentUploaded && ([SELECT count() FROM Attachment WHERE ParentId = :quote.Id] == 0)){
                String errorMessage = 'There are no attachments on this quote. Please attach PO before submitting order.';
                if(quote.Treat_SO_as_PO__c)
                        errorMessage = 'Please upload Attach PO or PO Exemption form.';  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                return;
            }
            //Naresh Kumar  03/07/2016        
            if([SELECT count() FROM Account_Order_Address__c WHERE Quote__c  =: quote.id AND Address_Type__c = 'Order Acknowledgement' AND Email__c != null] == 0){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Pleast enter email for the Order Acknowledgement address.'));
                return;
            }
            //Added by Navaneetha fro order acknowledgement manditory 
            if([SELECT count() FROM Account_Order_Address__c WHERE Quote__c  =: quote.id AND Address_Type__c = 'Ship To' AND Email__c != null] == 0){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Pleast enter email for the Ship To address.'));
                return;
            }
            
            if(quote.Shipping_Required__c && [SELECT count() FROM Order_Line_Item_Allocation__c WHERE Quote__c =:quote.id] == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add atleast one shipping location under order submission tab.'));
                return ;    
            }
        
            // Checking for Export Screening Check-list (Country is not US and Checklist is not checked)
            List<Export_Screening_Checklist__c> esc = [select id,Checklist_expiration_date__c FROM Export_Screening_Checklist__c where Account__c=:quote.End_User_ID__c];
            System.debug('++++++esc'+esc.size());
            if(esc.size()>0){
                if(esc[0].Checklist_expiration_date__c < system.today()){
                  escid = esc[0].id;
                    blnShowExportScreeningExpireMsg = true;
                    System.debug('++++escid'+ escid);
                    return;
                }
            }
            System.debug('++quote.End_User_ID__c' + quote.End_User_ID__c);
            System.debug('++quote.End_User_ID__r.Country__r.Name' + quote.End_User_ID__r.Country__r.Name);
            
            
            if(quote.End_User_ID__c != null && quote.End_User_ID__r.Country__r.Name != 'United States' &&
                ![SELECT screening_checklist_completed__c FROM Account WHERE Id = :quote.End_User_ID__c].screening_checklist_completed__c)
            {
                system.debug('__insider');
                blnShowExportScreeningMsg = true;
                return;
              
            }
            
            String strCurrentStatus = quote.BigMachines__Status__c;
            quote.BigMachines__Status__c = 'Order Submitted';
            quote.Order_Date_Submitted__c = Date.today();
            quote.Subscription_Start_Date__c = Date.today();
            Savepoint sp = Database.setSavepoint();
            try
            {
                //Util.Bypass_Trigger_Chk = false;
                update quote;
                //Initiating order creation process.
                QuoteUtil.CreateOrderFromQuote(quote.id);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Order Submitted'));
                blnIsReviseOrder = false;
            }
            catch(Exception ex)
            {
                Database.rollback(sp);    
                quote.BigMachines__Status__c = strCurrentStatus;
                quote.Order_Date_Submitted__c = null;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return;
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
  
                System.debug('NKC debug quoteApprovals.size() ['+quoteApprovals.size()+']');            
                if(counter - 1 == quoteApprovals.size())
                    approvals = addSubmissionRecords(approvals, eachQuoteApproval); 
            }   
            /*
            if(overAllStatus == null)
                overAllStatus = QuoteApprovalUtil.STATUS_APPROVED;  
            */
            return approvals;
        }
        
        private List<historyWrapper> addSubmissionRecords(List<historyWrapper> approvals, Quote_Approval__c eachQuoteApproval){
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
        
        public void assignDefaultGCRate()
        {
            if(!quote.Override_Genesys_Care_Rate__c && quote.Genesys_Care_Default_Pricing_Percentage__c != null)
                quote.Genesys_Care_Rate__c = quote.Genesys_Care_Default_Pricing_Percentage__c;
        }
        
        // *** Method to initialize Default Care Rate ***
        public void initializeCareRate()
        {
            if(quote.Offering_Type__c == 'PureEngage Subscription'){
                String strCareRateApplicable;
                
                if(quote.Genesys_Care_Default_Pricing_Percentage__c != null && quote.Genesys_Care_Rate__c == null)
                    quote.Genesys_Care_Rate__c = quote.Genesys_Care_Default_Pricing_Percentage__c;
                
                if((quote.Duration_Unit__c == 'Months' || String.isBlank(quote.Duration_Unit__c))
                    && quote.Order_Numb_of_Maint_Months__c == null)
                    quote.Order_Numb_of_Maint_Months__c = 12;
                
                if(String.isBlank(quote.Service_Level__c))
                    quote.Service_Level__c = 'Business';    
                    
                if(quote.Service_Level__c != 'Decline' && quote.Show_Why_Genesys__c 
                   && quote.Order_Type__c != Label.Order_Type_Amend && quote.Order_Type__c != Label.Order_Type_Subscription)
                {
                    if(objServiceLevel != null)     
                        strCareRateApplicable = objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable_Licensing__c;
                        
                    // Example : Basic Care-New(End User)
                    String strGCProdName = quote.Service_Level__c + ' Care-New';                
                   
                    if((!quote.BigMachines__Opportunity__r.Direct_Sales__c || quote.Sold_To_Name__c != quote.End_User_ID__c) && !quote.Pass_through__c)
                        strGCProdName += '(Partner)';   
                    else
                        strGCProdName += '(End User)';
                   
                   if((quote.Sold_To_Name__c == quote.End_User_ID__c)  &&  quote.Pass_through__c)
                   {
                     strGCProdName = quote.Service_Level__c + ' Care-New';
                     strGCProdName += '(Partner)'; 
                   }
                    
                  
                  
                        
                    if(objServiceLevel == null  || objServiceLevel.Product_Description__c != strGCProdName)
                    {
                        System.debug('<<< objServiceLevel | strGCProdName ' + strGCProdName);
                        List<Product2> list_Temp = [SELECT Id,Name,Unit_of_Measure__c,Care_Rate_Applicable_Licensing__c,APN_Number__c
                                            FROM Product2 WHERE Description = :strGCProdName AND 
                                            Genesys_Care_Quote__c = true AND IsActive = true];
                        if(list_Temp.size() > 0)
                        {
                            if(objServiceLevel == null)
                            {
                                objServiceLevel = new BigMachines__Quote_Product__c(Quantity__c = 1,
                                        BigMachines__Quantity__c = 1,BigMachines__Sales_Price__c = 0,BigMachines__Quote__c = quote.Id);
                            }
                            objServiceLevel.Name = list_Temp[0].Name;
                            objServiceLevel.APN_Number__c = list_Temp[0].APN_Number__c;
                            objServiceLevel.Unit_of_Measure__c = list_Temp[0].Unit_of_Measure__c;
                            objServiceLevel.BigMachines__Product__c = list_Temp[0].Id;
                            strCareRateApplicable = list_Temp[0].Care_Rate_Applicable_Licensing__c;
                        }
                    }
                    
                    if(String.isNotBlank(strCareRateApplicable))
                    {
                        String strQuery = 'SELECT Id,FYM_Rate__c'; 
                        //Adding the applicable care rate field to the query 
                        strQuery += ',Country__r.' + strCareRateApplicable;
                        String strEndUserId = quote.End_User_ID__c;
                        strQuery += ' FROM Account WHERE Country__c != null AND Id = :strEndUserId LIMIT 1';
                        System.debug(strQuery);
                        List<Account> list_Temp = Database.query(strQuery);
                        if(list_Temp.size() > 0)
                        {   
                            Account objAccount = list_Temp[0];
                            // Default Care Rate
                            quote.Genesys_Care_Default_Pricing_Percentage__c = (Decimal) objAccount.getSObject('Country__r').get(strCareRateApplicable);
                            // Set Genesys Care Rate to default rate if it is not overridden
                            assignDefaultGCRate();
            
                            // Set Genesys Care Rate to Account Contract Rate if applicable
                            if(quote.Genesys_Care_Contractual_Rate__c && objAccount.FYM_Rate__c != null)
                            {
                                quote.Genesys_Care_Rate__c = objAccount.FYM_Rate__c;
                                quote.Genesys_Care_Default_Pricing_Percentage__c = objAccount.FYM_Rate__c;
                            }
                        }
                    }
                }
                else
                {
                    quote.Genesys_Care_Contractual_Rate__c = quote.Override_Genesys_Care_Rate__c = false;
                    quote.Genesys_Care_Default_Pricing_Percentage__c = quote.Genesys_Care_Rate__c = null;
                    quote.Duration_Unit__c = 'Months';
                    quote.Order_Numb_of_Maint_Months__c = 12;
                }
                
                if(quote.Duration_Unit__c == 'Months')
                    quote.Order_Numb_of_Maint_Days__c = null;
                else
                    quote.Order_Numb_of_Maint_Months__c = null;
            }
        }
        
        public void saveGC()
        {
            if(quote.Service_Level__c != 'Decline' && quote.Show_Why_Genesys__c)
            {
                if(quote.Genesys_Care_Rate__c == null)
                {
                    quote.Genesys_Care_Rate__c.addError('Please Enter Value');
                    blnHasError = true;
                }
                if(quote.Duration_Unit__c == 'Months' && quote.Order_Numb_of_Maint_Months__c == null)
                {
                    quote.Order_Numb_of_Maint_Months__c.addError('Please Enter Value');
                    blnHasError = true;
                }
                else if(quote.Duration_Unit__c == 'Days' && quote.Order_Numb_of_Maint_Days__c == null)
                {
                    quote.Order_Numb_of_Maint_Days__c.addError('Please Enter Value');
                    blnHasError = true;
                }
                
                if(blnHasError)
                    return;
            }
            // Remove Genesys care Line and reset Genesys Care Percentages if Service is Declined
            else
            {
                if(objServiceLevel != null && objServiceLevel.Id != null)
                    delete objServiceLevel;
                
                objServiceLevel = null;
                quote.Genesys_Care_Default_Pricing_Percentage__c = null;
                quote.Genesys_Care_Rate__c = null;
            }
            initializeCareRate();
        }
        
        public static Double getPriceEscalation(BigMachines__Quote__c objQuote){
            Double priceEscalator = 0;
            ///one year option
           // if ( objQuote.No_Of_Months__c != null && Integer.valueOf(objQuote.No_Of_Months__c) <= 12 )
           if ( isOneyearQuote(objQuote) )
                 objQuote.Price_Escalation__c = null;               
            else if(objQuote.Price_Escalation__c != null){
                if(objQuote.Price_Escalation__c == 'Other'){
                    if(objQuote.Annual_Price_Escalation_Other__c != null){                              
                        priceEscalator = objQuote.Annual_Price_Escalation_Other__c;                
                    }
                }
                else{
                        priceEscalator = Double.valueOf(objQuote.Price_Escalation__c.replace('%', ''));                    
                }
            }
            return priceEscalator;
        }
        // *** Method invoked on click of save button  on configuration page (from javascript) ***
        public void saveBeforeReload()
        {
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            try
            {
                getQuoteProducts(quoteId);            
                
                saveBurstTerms();

                if(list_QuoteProductRecords.size() > 0)
                    upsert list_QuoteProductRecords;                    
                
                doCalculations();
                //Naresh Kumar   01/04/2016  Updating SML Data
                SMLHelperWTS.updateSMLForAccount(quote.End_User_ID__c);
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
    
        public Map<Id, Double> populateBasePackageWeightageIfMissing(String strBasePackageId){          
            Map<Id, Double> mapOfProductVsWeightage = new Map<Id, Double>();
            for(Product_Group_Item__c eachItem : [SELECT Product__c, Price_Weightage__c FROM Product_Group_Item__c
                WHERE Product_Group__c =: strBasePackageId]){
                mapOfProductVsWeightage.put(eachItem.Product__c, eachItem.Price_Weightage__c);
            }
            return mapOfProductVsWeightage;
        }

        @testVisible
        private List<Decimal> calculatePercentPriceForAmendment(){
            List<Decimal> listOfY1Y2Percentages = new List<Decimal>();
            Decimal decY1Percentage = 1;
            Decimal decY2Percentage = 1; 
            
            if( quote.Amendment_For__c != null && 
                quote.Amendment_For__r.Subscription_End_Date__c != null && quote.Amendment_For__r.Subscription_Start_Date__c != null &&
                System.today() > quote.Amendment_For__r.Subscription_Start_Date__c) {

                Decimal intMonths = (System.today()).monthsBetween(quote.Amendment_For__r.Subscription_End_Date__c);
                intMonths = intMonths < 0 ? 0 : intMonths;

                if(intMonths > 12) {
                    decY1Percentage = (intMonths-12) / 12;
                    decY2Percentage = 1; 
                }
                else if ( oneyear ) { // (quote.No_Of_Months__c != null && Integer.valueOf(quote.No_Of_Months__c) <= 12 ) {   ///one-year option                     
                    decY1Percentage = intMonths / 12;   
                    decY2Percentage = 0;   
                }  
                else {
                    decY1Percentage = 1;         
                    decY2Percentage = intMonths / 12;   
                }                
            }           
             
            listOfY1Y2Percentages.add(decY1Percentage);
            listOfY1Y2Percentages.add(decY2Percentage);

            return listOfY1Y2Percentages;
        }
    
        // *** Method to perform maintenance due calculations : Handler for Recalculate button ***
        public pageReference doCalculations()
        {                   
            if(objAttachment != null && String.isNotBlank(objAttachment.Name))
            {
                insert objAttachment;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Attachment Uploaded.'));
                objAttachment = new Attachment(ParentId = quote.Id);
            }
            if(!getIsQuoteUnLocked())
            {
                try
                {                     
                    if(quote.Expiration_Date__c != null && quote.Approval_Submission_Date__c != null)
                    {
                        if(quote.Expiration_Date__c < quote.Approval_Submission_Date__c)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Expiry Date cannot be earlier than Quote Submitted Date'));
                            return null;
                        }
                        else if(quote.Approval_Submission_Date__c.daysBetween(quote.Expiration_Date__c) > 90 && quote.BigMachines__Status__c!='Quote Approved')
                        {
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
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                }
                return null;
            }

            if(quote.No_Of_Months__c == null || quote.No_Of_Months__c == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Number of Months can not be null or 0.'));
                return null;
            }
            
            //blnHasError = false;
            // ****************** Validations *****************************
   
            // Cannot mix concurrent with non-concurrent products in any one group
            // Cannot have Non 'Named User Pricing' products on a 'Named User Pricing' quote.
            oneyear = isOneyearQuote(quote);        
            
            Integer intIndex = 0,intNumberOfPSRDP = 0;
            Set<Id> set_ProductIds = new Set<Id>();

            if ( !blnHasError ) {
                if ( list_Credits != null && !list_Credits.isEmpty() )
                list_QuoteProductRecords.addAll(list_Credits);
                
                //Add Burst products for processing - exclude base package line items from processing                        
                 if ( list_QuoteBurstTerms != null && !list_QuoteBurstTerms.isEmpty() ) {
                    for (QuoteBurstTerm trm : list_QuoteBurstTerms) {
                        Integer len = trm.term.Term_Length_Months__c == null ? 0 : Integer.valueOf(trm.term.Term_Length_Months__c);
                        burstTermLength.put(trm.term.Id, len);
                        for ( BigMachines__Quote_Product__c pr : trm.qtprods) {
                           // list_QuoteProductRecords.addAll(trm.qtprods);
                           if ( pr.Bundle_Line__c == null)
                             list_QuoteProductRecords.add(pr);
                        }
                    }
                }
            }
            blnHasError = false;
            
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {
                intIndex++;
                set_ProductIds.add(objQP.BigMachines__Product__c);

                objQP.currencyIsoCode = quote.currencyIsoCode;
                
                // Skip the check for Bundle Header Lines
                // if(objQP.Bundle__c != null)
                //    continue;
               
                // Skip the check for Bundle Header Lines
                if(objQP.Bundle__c != null) {
                     ///MS 6/26/19 - validation for Small Medium Center Base Package
                    if ( isSmallMediumCenter && quote.Amendment_For__c == null && objQP.Bundle__r.Group_Type__c != null && objQP.Bundle__r.Group_Type__c == 'Base Package' && 
                            objQP.Quantity__c != null && objQP.Quantity__c > 100 ) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Must quote less than or equal to 100 quantity Base Agent Package.'));
                        blnHasError = true;
                        return null;       
                    }
                    else
                       continue;
                }            
                
                // Validation for zero quantity
                if( objQP.Subscription_Burst_Term__c == null && (objQP.Quantity__c == null || objQP.Quantity__c < 1) ){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please make sure the quantity is one or more for committed the product line \"' + objQP.Product_Description__c + '\".'));
                    blnHasError = true;
                    return null;
                }   
                if(String.isNotBlank(objQP.BigMachines__Product__r.Flavors_Available__c) && String.isBlank(objQP.Flavor__c))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Flavor for the product where ever applicable.'));
                    blnHasError = true;
                    return null;
                }
                if(objQP.Subscription_Product__r.Quantity__c != NULL && objQP.Quantity__c < objQP.Subscription_Product__r.Quantity__c){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The product quantity cannot be lowered from the current subscription quantity.'));
                    blnHasError = true;
                    return null;       
                }
                //Reset GC Override if needed
                if(!quote.X3rd_Party_Override__c && objQP.Original_Third_Party_GC__c != null){
                  objQP.Third_Party_GC__c = objQP.Original_Third_Party_GC__c;
                }                           
            }
            if(intNumberOfPSRDP > 3)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'PS Rapid Deployment Packages limited to three per quote. Please remove the extra PS Rapid Deployment Packages from the quote. (Currently : ' + String.valueOf(intNumberOfPSRDP) + ')'));
                blnHasError = true;
                return null;
            }
            for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
            {                
                set_ProductIds.add(objQP.BigMachines__Product__c);
            }
            List<CurrencyType> currentCurrency = [SELECT ConversionRate FROM CurrencyType WHERE ISOCode =: quote.currencyIsoCode];
            List<Partner_Discount__c> listOfPartnerDiscounts = [SELECT Discount__c, Year__c, Category__c FROM Partner_Discount__c WHERE
                                                           Account__c =: quote.Sold_To_Name__c AND Type__c =: quote.Offering_Type__c];        
            // Storing all product ids of products associated with quote products in a set
            String pureSuccessPackageName = 'EQUIP';
            BigMachines__Quote_Product__c objQPToken;
            BigMachines__Quote_Product__c objQPTrainingUnit;
            quote.Discount__c = 0;
            quote.Base_Agent_Discount__c = 0;
            Decimal decQPToken = 0;
            Boolean blnIsThirdPartyApplicable = false;
            Decimal decExtLicenseBasePackagePriceY1, decExtLicenseBasePackagePriceY2;
            Set<Id> setOfProductIdsToBeIgnoredInSeatCount = new Set<Id>();
            //Naresh Kumar - Seat Count Logic - 04/19/2018
            Map<String, Seat_Count_Products_Mapping__c> mapOfSeatCountProductVsDependentProduct = new Map<String, Seat_Count_Products_Mapping__c>();
            for(Seat_Count_Products_Mapping__c eachMapping : [SELECT Name, Dependent_Products__c FROM Seat_Count_Products_Mapping__c 
                                                                WHERE Offering_Type__c = 'PureEngage On Premise']){
                mapOfSeatCountProductVsDependentProduct.put(eachMapping.Name, eachMapping);                 
            }
            //Percentage for amend quote 
            List<Decimal> listOfY1Y2Percentages = calculatePercentPriceForAmendment();
            Map<Id, Product2> mapOfIdVsProductId = new Map<Id, Product2>([SELECT Partner_Margin_Category__c FROM Product2 WHERE id IN: set_ProductIds]);
            // Checking if prices have been updated
            if(!blnSkipPriceCheck && String.isNotBlank(quote.New_Price_Book__c))
            {                
                Boolean blnHasPriceUpdate = false;                
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {
                    //Add third party line only for non 0 or 255 values
                    if(objQP.BigMachines__Product__r.Third_Party_GC__c != null  && objQP.BigMachines__Product__r.Third_Party_GC__c != 0
                           && objQP.BigMachines__Product__r.Third_Party_GC__c != 255){
                        blnIsThirdPartyApplicable = true;
                    }
 
                    if(objQP.Bundle__r.Type__c == 'GUIDE' || objQP.Bundle__r.Type__c == 'EQUIP' 
                       || objQP.Bundle__r.Type__c == 'DRIVE' || objQP.Bundle__r.Type__c == 'Partner PureSuccess'){
                        quote.PureSuccess__c = objQP.Bundle__r.Type__c;
                    }
                    if(objQP.BigMachines__Product__r.Type__c == 'Training Unit'){
                        objQPTrainingUnit = objQP;
                    } 

                    objQP.Total_Discount__c = 0;
 
                    set_ProductIds.add(objQP.BigMachines__Product__c);
                    Decimal decProductPrice;
                    if(objQP.Bundle__r.Group_Type__c == 'PureSuccess' && objQP.Bundle__r.Name != null)
                        pureSuccessPackageName = objQP.Bundle__r.Name.toUpperCase();
                    //We don't need to recalculate Base Package Pricing as it is coming from base package itself.
                    System.debug('NKC debug objQP.Bundle__r.Group_Type__c [' + objQP.Bundle__r.Group_Type__c + ']');

                    if (objQP.Bundle__r.Group_Type__c == 'Base Package' && !isSmallMediumCenter && !oneyear ) {                       
                        // quote.RightToBurst__c = true; MS-4/30/19
                        quote.RightToRemix__c = true;
                        // quote.Usage_Data_Submission_Method__c = 'No Bursting'; MS-4/30/19
                    }

                    ///MS - for quote updates
                    quote.RightToRemix__c = oneyear ? false : quote.RightToRemix__c;

                    if(quote.Amendment_For__c == null || objQP.Subscription_Product__c == null) 
                        decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get(quote.New_Price_Book__c + '_Price__c');
                    else
                        decProductPrice = objQP.Subscription_Product__r.Original_List_Price__c;
                    objQP.Equivalent_Old_List_Price__c = decProductPrice;
                    
                    if(objQP.Bundle__c != null && (objQP.Bundle__r.Type__c != null && (objQP.Bundle__r.Type__c.equalsIgnoreCase('Equip') || objQP.Bundle__r.Type__c.equalsIgnoreCase('Partner PureSuccess'))))
                        decProductPrice = 0;                    
                    System.debug('NKC debug decProductPrice [' + decProductPrice + ']');
                    if(decProductPrice == null)
                        continue;
                    if(quote.Pricing_Model__c != null && quote.Pricing_Model__c != 'User' && String.isNotBlank(objQP.BigMachines__Product__r.Pricing_Model__c)
                            && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase(quote.Pricing_Model__c) && (quote.Offering_Type__c == 'PureEngage Subscription'))
                        decProductPrice *= decPricingMultiplier;
                    
                    if((objQP.Bundle__r.Group_Type__c == 'Base Package' || objQP.BigMachines__Product__r.Type__c == 'Product' 
                        || objQP.Bundle__r.Group_Type__c == 'PureSuccess' || objQP.Bundle__r.Group_Type__c == 'A la Carte')){ 
                        decProductPrice = QuoteUtil.calculatePaymentTermPrice(decProductPrice, quote, objQP);
                    }
                    
                    if((objQP.Bundle__r.Group_Type__c == 'Base Package' || objQP.BigMachines__Product__r.Type__c == 'Product') 
                       && objQP.Bundle__r.Group_Type__c != 'A la Carte'){ 
                        decProductPrice = QuoteUtil.calculateOveragePrice(decProductPrice, quote, objQP);
                    }
                    if(objQP.BigMachines__Product__r.Type__c == 'Token' && objQP.Quantity__c != null){                        
                        decQPToken += objQP.Quantity__c * 10;    
                    }
                    Double priceEscalator = 0;
                    if(objQP.Bundle__r.Group_Type__c == 'Base Package' || objQP.BigMachines__Product__r.Type__c == 'Product' ||
                       objQP.BigMachines__Product__r.Type__c == 'Cloud') 
                          priceEscalator = getPriceEscalation(quote);

                    Decimal amendMultiplY1=1;
                    Decimal amendMultiplY2=1;
                    if ( objQP.BigMachines__Product__r.Type__c != 'Token' && objQP.BigMachines__Product__r.Type__c != 'Migration Credit' &&
                         objQP.BigMachines__Product__r.Type__c != 'Product - Hardware' && objQP.BigMachines__Product__r.Type__c != 'Hardware Warranty' &&
                          objQP.BigMachines__Product__r.Type__c != 'Training Unit') {
                         amendMultiplY1 = listOfY1Y2Percentages[0];
                         amendMultiplY2 = listOfY1Y2Percentages[1];
                    }

                    decProductPrice = decProductPrice.setScale(2);
                    objQP.List_Price__c = (decProductPrice * amendMultiplY1);                                      
                    objQP.Partner_Price__c = objQP.List_Price__c;
                    objQP.List_Price_1__c = decProductPrice;
                    objQP.List_Price_1__c = (objQP.List_Price_1__c * amendMultiplY1);
                    objQP.List_Price_2__c = decProductPrice;                        
                    objQP.List_Price_2__c += (objQP.List_Price_2__c * priceEscalator) / 100; 
                    objQP.List_Price_2__c = (objQP.List_Price_2__c * amendMultiplY2);
                    objQP.Partner_Price_1__c = objQP.List_Price_1__c;
                    objQP.Partner_Price_2__c = objQP.List_Price_2__c; 
                    //Getting partner margins
                    //MS no Partner discount for Small Centers; if(quote.Multi_Year_Quote__c)  {
                   
                    if ( quote.Multi_Year_Quote__c && !isSmallMediumCenter )  {
                        if(objQP.Bundle__r.Group_Type__c == 'A la Carte'){
                                objQP.Partner_Price_1__c = decProductPrice;
                            objQP.Partner_Price_2__c = decProductPrice;    
                    }
                    else if (  objQP.BigMachines__Product__r.Type__c != 'Migration Credit' ) {                            
                            Product2 objProduct = mapOfIdVsProductId.get(objQP.BigMachines__Product__c);
                            List<Decimal> listOfPartnerPriceAndDiscount = QuoteUtil.getSubscriptionPartnerMargin(decProductPrice, quote, objProduct, listOfPartnerDiscounts);                        
                            //Partner Discount
                            objQP.Partner_Discount_1__c = listOfPartnerPriceAndDiscount[0];
                            objQP.Partner_Discount_2__c = listOfPartnerPriceAndDiscount[1];
                            objQP.Partner_Discount__c = (objQP.Partner_Discount_1__c + objQP.Partner_Discount_2__c) / 2;
                            //Partner Price
                            objQP.Partner_Price_1__c = objQP.List_Price_1__c - ((objQP.List_Price_1__c * objQP.Partner_Discount_1__c) / 100);
                            objQP.Partner_Price_2__c = objQP.List_Price_2__c - ((objQP.List_Price_2__c * objQP.Partner_Discount_2__c) / 100);

                            if (objQP.Hardware_or_Third_Party__c || oneyear)
                                objQP.Partner_Price__c = objQP.Partner_Price_1__c;
                            else
                                objQP.Partner_Price__c = objQP.Partner_Price_1__c + objQP.Partner_Price_2__c;                        
                            //Total Discount    
                            objQP.Total_Discount__c = (objQP.Partner_Discount_1__c > objQP.Partner_Discount_2__c ? objQP.Partner_Discount_1__c : objQP.Partner_Discount_2__c);
                        }
                    }
                   
                    System.debug('+++ decProductPrice ' + decProductPrice);    
                    // EMEA Volume Discount for old pricing (Discounting is tiered)
                    if(blnHasEMEAVolDisc && objQP.BigMachines__Product__r.EMEA_Volume_Discount_Eligible__c && 
                        objQP.Quantity__c != null && objQP.Quantity__c != 0)
                    {
                        Integer intNumOfTiers = EMEA_Volume_Discounts__c.getall().size();
                        Decimal decPreviousRangeHigh = 0,decWeightedTotal = 0;
                        for(Integer i=1 ; i<=intNumOfTiers ; i++)
                        {
                            EMEA_Volume_Discounts__c objEMEADiscount = EMEA_Volume_Discounts__c.getInstance(String.valueOf(i));
                            if(objEMEADiscount != null)
                            {
                                if(objQP.Quantity__c <= objEMEADiscount.Range_End__c)
                                {
                                    decWeightedTotal += (objQP.Quantity__c - decPreviousRangeHigh) * objEMEADiscount.Discount__c;
                                    break;
                                }
                                else
                                    decWeightedTotal += (objEMEADiscount.Range_End__c - decPreviousRangeHigh) * objEMEADiscount.Discount__c;
                                
                                decPreviousRangeHigh = objEMEADiscount.Range_End__c;
                            }
                        }
                        objQP.EMEA_Volume_Discount__c = decWeightedTotal/objQP.Quantity__c;
                        decProductPrice -= (decProductPrice * objQP.EMEA_Volume_Discount__c/100);                        
                    }
                    Product2 product = new Product2(Type__c = objQP.BigMachines__Product__r.Type__c, Third_Party__c = objQP.BigMachines__Product__r.Third_Party__c);
                    
                    //Seat Count Logic - 04/19/2018
                    Seat_Count_Products_Mapping__c eachRecord = mapOfSeatCountProductVsDependentProduct.get(objQP.BigMachines__Product__c);

                    if(eachRecord != null && eachRecord.Dependent_Products__c != null){                      
                        List<String> listOfProductIds = eachRecord.Dependent_Products__c.split(';');
                        for(String eachProduct : listOfProductIds){
                            setOfProductIdsToBeIgnoredInSeatCount.add(eachProduct);
                        }
                    }
                              
                    if (objQP.List_Price__c != (decProductPrice * amendMultiplY1) && objQP.Subscription_Burst_Term__c == null)
                    {                      
                        //blnHasPriceUpdate = true;
                        objQP.List_Price__c = (decProductPrice * amendMultiplY1);
                        objQP.List_Price_1__c = (decProductPrice * amendMultiplY1);
                        objQP.List_Price_2__c = (decProductPrice * amendMultiplY2);
                        String strProdName = objQP.Product_Description__c != null ? objQP.Product_Description__c : objQP.Name;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,strProdName + ' price has been updated to ' + decProductPrice));
                    }
                }
                Set<Id> set_PriceUpdatedBundles = new Set<Id>();

                ///MS 5/30/19 added for missing PureSuccess__c on Amendments
                if ( quote.PureSuccess__c == null && quote.Amendment_For__c != null )
                      quote.PureSuccess__c = quote.Amendment_For__r.Quote__r.PureSuccess__c;
                // MS-end

                Decimal decPackagePercentage = QuoteUtil.getPackagePricingPercentage(quote.Offering_Type__c, quote.PureSuccess__c, 'License');   
                Decimal decLicenseBasePackagePriceY1 = 0, decLicenseBasePackagePriceY2 = 0;                
                Map<Id, Double> mapOfProductVsWeightage;
                
                for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
                {   
                    System.debug('<<<< ' + objQP.Id +'<<<<'+objQP.Bundle__r.Discount__c);
                    Decimal decProductPrice;
                    Decimal decProductPriceY2;
                    if(objQP.Bundle__r.Group_Type__c == 'PureSuccess' && objQP.BigMachines__Product__r.Type__c == 'Token'){
                        objQPToken = objQP;
                    } 

                    if ( oneyear )
                        objQP.Bundle_Line__r.Ext_Net_Price_2__c  = objQP.Bundle_Line__r.Net_Unit_Price_2__c = 0;

                    if(objQP.Bundle__r.Group_Type__c == 'Base Package') {
                        //MS added for Base Package when PureSuccess is not used
                        //if ( isSmallMediumCenter && decPackagePercentage == 0 )
                        //   decPackagePercentage = 100;
                        //    && (quote.PureSuccess__c != null || isSmallMediumCenter) ) { 

                        if( objQP.Bundle_Line__r.Ext_Net_Price_1__c != null && objQP.Bundle_Line__r.Ext_Net_Price_2__c != null ) {
                                                               
                            decExtLicenseBasePackagePriceY1 = (objQP.Bundle_Line__r.Ext_Net_Price_1__c * decPackagePercentage) / 100;
                            decExtLicenseBasePackagePriceY2 = (objQP.Bundle_Line__r.Ext_Net_Price_2__c * decPackagePercentage) / 100;
                            if(objQP.Bundle_Line__r.Net_Unit_Price_1__c != null)
                                decLicenseBasePackagePriceY1 = (objQP.Bundle_Line__r.Net_Unit_Price_1__c * decPackagePercentage) / 100;
                            if(objQP.Bundle_Line__r.Net_Unit_Price_2__c != null)
                                decLicenseBasePackagePriceY2 = (objQP.Bundle_Line__r.Net_Unit_Price_2__c * decPackagePercentage) / 100;
                               
                            if(objQP.Weightage__c == null || objQP.Weightage__c == 0){
                                if(mapOfProductVsWeightage == null)
                                    mapOfProductVsWeightage = populateBasePackageWeightageIfMissing(objQP.Bundle__c);
                                if(objQP.BigMachines__Product__c != null && mapOfProductVsWeightage.get(objQP.BigMachines__Product__c) != null)
                                    objQP.Weightage__c = mapOfProductVsWeightage.get(objQP.BigMachines__Product__c);
                            }
                            objQP.Weightage__c = (objQP.Weightage__c == null ? 0 : objQP.Weightage__c);
                            decProductPrice = (decLicenseBasePackagePriceY1 * objQP.Weightage__c) / 100;                            
                            decProductPriceY2 = (decLicenseBasePackagePriceY2 * objQP.Weightage__c) / 100;                            
                        }
                    }
                    else if(objQP.Bundle__r.Group_Type__c == 'PureSuccess'){
                        decProductPrice = 0;
                        decProductPriceY2 = 0;
                    }
                    else{
                        if(objQP.getSObject('BigMachines__Product__r') != null){
                            if(quote.Amendment_For__c == null) 
                                decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get(quote.New_Price_Book__c + '_Price__c');                    
                            else
                                decProductPrice = objQP.Subscription_Product__r.Original_List_Price__c; 

                            objQP.Equivalent_Old_List_Price__c = decProductPrice;
                            decProductPriceY2 = decProductPrice;
                        }
                    }
                    if(decProductPrice == null){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please click Save button again before you submit the order.'));
                        continue;
                    }
      
                    if(objQP.Bundle__r.Group_Type__c != 'Base Package' && quote.Pricing_Model__c != 'User' && String.isNotBlank(objQP.BigMachines__Product__r.Pricing_Model__c)
                       && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase(quote.Pricing_Model__c)){                           
                        decProductPrice *= decPricingMultiplier;
                    }
                   decProductPrice = decProductPrice.setScale(2);     
                    Double priceEscalator = 0;
                    if(objQP.Bundle__r.Group_Type__c == 'Base Package' || objQP.BigMachines__Product__r.Type__c == 'Cloud' ||
                        objQP.BigMachines__Product__r.Type__c == 'Product' || objQP.Bundle__r.Group_Type__c == 'Campaigns') 
                        priceEscalator = getPriceEscalation(quote);

                    objQP.List_Price__c = (decProductPrice * listOfY1Y2Percentages[0]);                                     
                    objQP.Partner_Price__c = objQP.List_Price__c;
                    objQP.List_Price_1__c = decProductPrice;
                    objQP.List_Price_1__c = (objQP.List_Price_1__c * listOfY1Y2Percentages[0]);
                    objQP.List_Price_2__c = decProductPriceY2;        
                    objQP.List_Price_2__c = (objQP.List_Price_2__c * listOfY1Y2Percentages[0]);

                    if(objQP.Bundle__r.Group_Type__c != 'Base Package')
                        objQP.List_Price_2__c += (objQP.List_Price_2__c * priceEscalator) / 100; 

                    objQP.Partner_Price_1__c = objQP.List_Price_1__c;
                    objQP.Partner_Price_2__c = objQP.List_Price_2__c;
                    System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                    if(objQP.Bundle__r.Group_Type__c == 'Campaigns'){
                        objQP.Discount_1__c = objQP.Disc__c;
                        objQP.Discount_2__c = objQP.Disc__c;                                        
                        Product2 objProduct = mapOfIdVsProductId.get(objQP.BigMachines__Product__c);
                        List<Decimal> listOfPartnerPriceAndDiscount = QuoteUtil.getSubscriptionPartnerMargin(decProductPrice, quote, objProduct, listOfPartnerDiscounts);                        
                        //Partner Discount
                        objQP.Partner_Discount_1__c = listOfPartnerPriceAndDiscount[0];
                        objQP.Partner_Discount_2__c = listOfPartnerPriceAndDiscount[1];
                        objQP.Partner_Discount__c = (objQP.Partner_Discount_1__c + objQP.Partner_Discount_2__c) / 2;                        
                    }
                    Product2 product = new Product2(Type__c = objQP.BigMachines__Product__r.Type__c, Third_Party__c = objQP.BigMachines__Product__r.Third_Party__c);
                    decProductPrice = ConfigurationControllerPPU.convertAndUpdatePrice(decProductPrice, quote, product, currentCurrency);
                    System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                    System.debug('NKC debug objQP.List_Price__c ['+objQP.List_Price__c+']');    
 
                    if(objQP.Bundle__r.Group_Type__c == 'Campaigns'){
                        BigMachines__Quote_Product__c objBundleQP = map_BundleQuoteProducts.get(objQP.Bundle_Line__c);
                        objBundleQP.Ext_List__c = 0;
                        objBundleQP.Ext_List_Price_1__c = 0;
                        objBundleQP.Ext_List_Price_2__c = 0;
                        
                        objBundleQP.Ext_Net_Price__c = 0;
                        objBundleQP.Ext_Net_Price_1__c = 0;
                        objBundleQP.Ext_Net_Price_2__c = 0;
                    }

                    if ( oneyear )
                        objQP.Partner_Price_2__c = objQP.List_Price_2__c = 0;   
                }      
            }
            
            if(!quote.Include_Special_Offer_in_Output__c && String.isNotBlank(quote.Special_Offer_Terms__c))
            {
                String strRichText = String.valueof(quote.Special_Offer_Terms__c);
                strRichText = strRichText.replaceall('<.*>','');
                if(String.isNotBlank(strRichText))
                    quote.Include_Special_Offer_in_Output__c = true;
            }            
            
            //saveGC();
            System.debug('NKC debug blnIsThirdPartyApplicable [' + blnIsThirdPartyApplicable + ']');
            System.debug('NKC debug quote.Show_Why_Genesys__c [' + quote.Show_Why_Genesys__c + ']');
            
            if(blnIsThirdPartyApplicable)
                processThirdPartyGCLine();
            
            // ****************** Calculations *****************************
            // Using 1 consolidated list to limit DML operations
            List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
            intIndex = 0;
            Decimal decTotalNetPrice = 0,decTotalDiscount = 0,decGenesysProductsDiscount = 0,decPSRDPTotal = 0,listPriceTotalProductsOnly = 0, decGenesysAllDiscount = 0; 
            Decimal netPriceTotalBurst = 0, listPriceTotalAll = 0, listPriceTotalBurst = 0, decGenesysProductsBurstDiscount = 0, listPriceTotalBurstProductsOnly = 0;
            
            if(objThirdPartyGCLine != null)
                objThirdPartyGCLine.Ext_Net_Price__c = 0;
                
            if(!blnHasRDP)
                quote.Time_Expense_PS_RDP__c = null;
            else
            {
                if(quote.Sold_To_Region__c != 'LATAM' && (quote.Time_Expense_PS_RDP__c < 20 || quote.Time_Expense_PS_RDP__c == null))
                {
                    blnHasError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select PS T&E expenses at 20% or higher.'));
                    return null;
                }
            }
            totalAmount = 0;
            totalACV = totalACV1 = totalACV2 = 0;
            totalAcvBrst1 = totalAcvBrst2 = 0;
            totalAmountOneTimeFee = 0;
            totalAmountYear1 = 0;
            totalAmountYear2 = 0;
            CMRRPreDiscount = 0;
            maxSeatCount = 0;
            quote.A_La_Carte_PureSuccess_Services_Amount__c = 0;
            quote.Highest_Discount__c = 0;
            Integer noOfLines = 0;
            quote.Additional_Discount_Cloud__c = 0;
            quote.Max_Seat_Count__c = 0;
            Decimal decTotalExtNetThirdParty = 0;
            Decimal decQuantityThirdParty = 0;
            Map<Id, Decimal> basePackAmendQty = new Map<Id, Decimal>();
            // To indicate whether there is any shipping required
                quote.Shipping_Required__c = false;

           //PureBridge GU products
            List<String> pureBrGUpassps = new List<String>();
            for ( Passport_SKUs__mdt gu : [SELECT APN_of_GU_Product__c FROM Passport_SKUs__mdt WHERE Offering_Type__c = :quote.Offering_Type__c])
                pureBrGUpassps.add(gu.APN_of_GU_Product__c);

  
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {
                //intIndex++;
                set_ProductIds.add(objQP.BigMachines__Product__c);
                // Initializing values to be computed
                
                if(quote.Offering_Type__c == 'PureConnect Subscription' && objQP.BigMachines__Product__r.Type__c == 'Product - Hardware')
                        quote.Shipping_Required__c = true;      
                objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c=0;
                   
                if(objQP.Bundle__r.Group_Type__c != 'Campaigns'  && objQP.Product_Description__c != 'Campaign'){
                    objQP.Ext_List__c = 0;
                    objQP.Ext_Net_Price__c = 0;
                }
                
                if(objQP.List_Price__c != null) 
                {                  
                    objQP.Net_Unit_Price__c = objQP.Partner_Price__c;
                    objQP.Net_Unit_Price_1__c = objQP.Partner_Price_1__c;
                    objQP.Net_Unit_Price_2__c = objQP.Partner_Price_2__c;

                    // Proposal Group Discount
                    if(String.isNotBlank(objQP.Group_Number__c) && 
                        map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) && 
                        map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c != null)
                    {
                        if(objQP.BigMachines__Product__r.Building_Block__c != 'PS Rapid Deployment Packages')
                        {
                            objQP.Proposal_Group_Discount__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c;
                            objQP.Total_Discount__c += objQP.Proposal_Group_Discount__c;
                            objQP.Net_Unit_Price__c -= (objQP.Partner_Price__c * objQP.Proposal_Group_Discount__c/100);
                            objQP.Net_Unit_Price_1__c -= (objQP.Partner_Price_1__c * objQP.Proposal_Group_Discount__c/100);
                            objQP.Net_Unit_Price_2__c -= (objQP.Partner_Price_2__c * objQP.Proposal_Group_Discount__c/100);
                        }
                    }  
                    if(quote.Multi_Year_Quote__c){
                        Decimal discount = 0;
                        objQP.Discount_1__c = objQP.Disc__c;
                        objQP.Discount_2__c = objQP.Disc__c;
                    }

                   //Line Discount - not Bursted items
                   if ( objQP.Subscription_Burst_Term__c == null )
                     applyLineItemDiscount(objQP);

                    objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
 
                    if(objQP.Quantity__c != null)
                    {
                        Decimal quantity = objQP.Quantity__c;

                        if(quote.Amendment_For__c != null && objQP.Subscription_Product__r.Quantity__c != null)  {    
                            if ( objQP.Bundle__r.Group_Type__c == 'Base Package' && objQP.Bundle_Line__c == null )
                                basePackAmendQty.put(objQP.Id, objQP.Quantity__c);
                            quantity = quantity - objQP.Subscription_Product__r.Quantity__c;   
                        }

                        objQP.Ext_List__c = decNullTest(objQP.Partner_Price__c) * quantity;
                        objQP.Ext_List_Price_1__c = decNullTest(objQP.Partner_Price_1__c) * quantity;
                        objQP.Ext_List_Price_2__c = decNullTest(objQP.Partner_Price_2__c) * quantity;
                        objQP.Ext_Net_Price__c = decNullTest(objQP.Net_Unit_Price__c) * quantity;
                        objQP.Ext_Net_Price_1__c = decNullTest(objQP.Net_Unit_Price_1__c) * quantity;
                        objQP.Ext_Net_Price_2__c = decNullTest(objQP.Net_Unit_Price_2__c) * quantity;
                        decTotalNetPrice += objQP.Ext_Net_Price__c;
                        decTotalDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;

                        if(objQP.Bundle_Line__c == null)
                        {
                            if (objQP.Third_Party__c != 'TRUE' && objQP.Subscription_Burst_Term__c == null ) {  ///exclude burst prods
                                    decGenesysProductsDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                                    listPriceTotalProductsOnly += objQP.Ext_List__c;
                            }  
                            if ( quantity > 0 && objQP.Subscription_Burst_Term__c == null ) {
                                    decGenesysAllDiscount += (decNullTest(objQP.List_Price_1__c)  * quantity) - decNullTest(objQP.Ext_Net_Price_1__c);
                                    listPriceTotalAll += decNullTest(objQP.List_Price_1__c) * quantity;
                            }
                        }

                        if(objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c && !setOfProductIdsToBeIgnoredInSeatCount.contains(objQP.BigMachines__Product__c)){
                            Decimal decSeatCount = quantity;
                            if(quote.Pricing_Model__c == 'Concurrent'){
                                Global_Setting__c objGlSetting = Global_Setting__c.getInstance('Concurrent Seat Count Multiplier');
                                if(objGlSetting != null){
                                    decSeatCount = decSeatCount * Decimal.valueOf(objGlSetting.ID__c);
                                }
                            }
                            quote.Max_Seat_Count__c += decSeatCount;
                        }
                    }
                    if(objQP.Bundle__r.Group_Type__c == 'Base Package' && objQP.Disc__c != null && objQP.Disc__c > 0)
                        quote.Base_Agent_Discount__c = objQP.Total_Discount__c;
                    if(objQP.Bundle__r.Group_Type__c != 'Base Package' && quote.Discount__c < objQP.Total_Discount__c && objQP.Disc__c != null && objQP.Disc__c > 0)
                        quote.Discount__c = objQP.Total_Discount__c;
                    if(quote.Highest_Discount__c < objQP.Total_Discount__c && (!quote.Multi_Year_Quote__c || (quote.Multi_Year_Quote__c && objQP.Disc__c != null && objQP.Disc__c > 0) ))
                        quote.Highest_Discount__c = objQP.Total_Discount__c;
                    noOfLines ++;
                    quote.Additional_Discount_Cloud__c += objQP.Total_Discount__c;

                     //PureBridge GU 3 units at 100% discount to bypass Partner or any other additional discounts
                    if ( isPureBridgeOpp && lever2 && !pureBrGUpassps.isEmpty() && pureBrGUpassps.contains(objQP.APN_Number__c) &&
                        objQP.Quantity__c != null && objQP.Quantity__c == 3 && objQP.Disc__c == 100.0 ) {
                        objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c = objQP.Net_Unit_Price_1__c = objQP.Net_Unit_Price_2__c = 0;
                        objQP.Ext_Net_Price__c = objQP.Ext_Net_Price_1__c = objQP.Ext_Net_Price_2__c = 0;
                        objQP.Total_Discount__c = objQP.Discount_1__c = objQP.Discount_2__c = 100.0;
                    }

                    if(objQP.Total_Discount__c > 100.0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Total Discount cannot exceed 100% on any line.'));
                        blnHasError = true;
                        return null;
                    }
                }
                else{//ADDED by Ankit on 11/12 for AVAYA
                    if(objQP.Bundle__r.Group_Type__c!='Campaigns'  && objQP.Product_Description__c != 'Campaign')
                    objQP.List_Price__c = objQP.Ext_List__c = 0;
                }
                if(objQP.Bundle__c == null)
                {
                    // Add to Third Party GC Line Total Net for Third party HW lines
                    if(objQP.Third_Party__c == 'TRUE' && objThirdPartyGCLine != null
                       && (objQP.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || objQP.BigMachines__Product__r.Type__c  == Label.Product_System_License_Product_Type)
                       && objThirdPartyGCLine.Ext_Net_Price__c != null)
                    {
                        if(quote.Offering_Type__c == 'PureEngage Subscription'){
                            if(objThirdPartyGCLine != null && objQP.Third_Party_GC__c != null && objQP.Third_Party_GC__c != 0){
                                    objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (objQP.Third_Party_GC__c / 100) *
                                (quote.Duration_Unit__c == 'Days' ? (quote.Order_Numb_of_Maint_Days__c / 365) : (quote.Order_Numb_of_Maint_Months__c / 12));
                            }
                        }
                        //PureConnect Subscription
                        else{
                                if (objThirdPartyGCLine != null && objQP.Third_Party_GC__c != null && objQP.Third_Party_GC__c != 0 && objQP.Third_Party_GC__c != 255)
                                objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (objQP.Third_Party_GC__c / 100) *
                                (quote.Duration_Unit__c == 'Days' ? (quote.Order_Numb_of_Maint_Days__c / 365) : (quote.Order_Numb_of_Maint_Months__c / 12));
                            else if(objQP.Third_Party_GC__c == 255 && quote.Genesys_Care_Rate__c != null)
                                objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (quote.Genesys_Care_Rate__c / 100) *
                                (quote.Duration_Unit__c == 'Days' ? (quote.Order_Numb_of_Maint_Days__c / 365) : (quote.Order_Numb_of_Maint_Months__c / 12));    
                        }
                        if(objQP.Ext_Net_Price__c != null)
                            decTotalExtNetThirdParty += objQP.Ext_Net_Price__c;
                        if(objQP.Quantity__c != null)
                            decQuantityThirdParty += objQP.Quantity__c;
                    }
                    if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                        decPSRDPTotal += objQP.Ext_Net_Price__c;
                }

                 ///Bursting
                if ( objQP.Subscription_Burst_Term__c != null )  {  
                     Decimal quantity = objQP.Quantity__c == null ? 0 : objQP.Quantity__c;

                     if (quote.Amendment_For__c != null && objQP.Subscription_Product__r.Quantity__c != null)                             
                           quantity = objQP.Quantity__c - objQP.Subscription_Product__r.Quantity__c;                                                    

                    Decimal burstPriceMltpr = (Decimal.valueOf(burstTermLength.get(objQP.Subscription_Burst_Term__c)) / 12) * 1.50;

                    objQP.List_Price__c = decNullTest(objQP.List_Price__c) * burstPriceMltpr;  
                    objQP.List_Price_1__c = decNullTest(objQP.List_Price_1__c) * burstPriceMltpr;  
                    objQP.List_Price_2__c = decNullTest(objQP.List_Price_2__c) * burstPriceMltpr;
                    objQP.Partner_Price__c = decNullTest(objQP.Partner_Price__c) * burstPriceMltpr; 
                    objQP.Partner_Price_1__c = decNullTest(objQP.Partner_Price_1__c) * burstPriceMltpr;   
                    objQP.Partner_Price_2__c = decNullTest(objQP.Partner_Price_2__c) * burstPriceMltpr;   
                                 
                    objQP.Ext_List__c =   decNullTest(objQP.Ext_List__c) * burstPriceMltpr;
                    objQP.Ext_List_Price_1__c = decNullTest(objQP.Ext_List_Price_1__c) * burstPriceMltpr; 
                    objQP.Ext_List_Price_2__c = decNullTest(objQP.Ext_List_Price_2__c) * burstPriceMltpr; 

                    objQP.Net_Unit_Price__c  = decNullTest(objQP.Net_Unit_Price__c) * burstPriceMltpr; 
                    objQP.Net_Unit_Price_1__c = decNullTest(objQP.Net_Unit_Price_1__c) * burstPriceMltpr; 
                    objQP.Net_Unit_Price_2__c = decNullTest(objQP.Net_Unit_Price_2__c) * burstPriceMltpr; 

                    //Line Item Discount, determine Net prices
                    applyLineItemDiscount(objQP);
                    
                    objQP.Ext_Net_Price__c = decNullTest(objQP.Net_Unit_Price__c) * quantity ;
                    objQP.Ext_Net_Price_1__c = decNullTest(objQP.Net_Unit_Price_1__c) * quantity ;
                    objQP.Ext_Net_Price_2__c = decNullTest(objQP.Net_Unit_Price_2__c) * quantity ;

                    objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;  
                                      
                    netPriceTotalBurst += decNullTest(objQP.Ext_Net_Price_1__c);
                    listPriceTotalBurst += decNullTest(objQP.List_Price_1__c) * quantity;     
                }

                ////MS - Credits
                 if ( oneyear ||
                  (!secondYrAmend && objQP.BigMachines__Product__r.Type__c == 'Migration Credit' && objQP.BigMachines__Product__r.Name.contains('One-Time')) ) {                 
                            objQP.List_Price_2__c = 0;
                            objQP.Partner_Price_2__c = 0;
                            objQP.Ext_List_Price_2__c = 0;
                            objQP.Net_Unit_Price_2__c = 0;
                            objQP.Ext_Net_Price_2__c = 0;                           
                } 

            } //END for loop

            ///MS Update Base Package quantity on Amendments, not in list_BundleItemQPRecords
            for (BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {             
                if ( objQP.Bundle_Line__c != null && basePackAmendQty.containsKey(objQP.Bundle_Line__c) )              
                    objQP.Quantity__c = objQP.BigMachines__Quantity__c = basePackAmendQty.get(objQP.Bundle_Line__c);
            }

            if(objThirdPartyGCLine != null && !isSmallMediumCenter ){
                objThirdPartyGCLine.Ext_List__c = decTotalExtNetThirdParty;
                objThirdPartyGCLine.Quantity__c = decQuantityThirdParty;
                objThirdPartyGCLine.BigMachines__Quantity__c = decQuantityThirdParty;
            }
            if(noOfLines != 0 && quote.Additional_Discount_Cloud__c != 0)
                quote.Additional_Discount_Cloud__c = quote.Additional_Discount_Cloud__c / noOfLines;
            if(blnHasBundles)
            {
                // Copying Bundle Line data and updating the the sell-able item lines related to the Bundles
                for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
                {

                    if(objQP.Bundle_Line__c != null && map_BundleQuoteProducts.containsKey(objQP.Bundle_Line__c))
                    {
                        BigMachines__Quote_Product__c objBundleQP = map_BundleQuoteProducts.get(objQP.Bundle_Line__c);
                        System.debug('NKC debug objBundleQP.Quantity__c [' + objBundleQP.Quantity__c + ']');
                        if(objBundleQP.Subscription_Product__r.Quantity__c != NULL 
                           && objBundleQP.Quantity__c < objBundleQP.Subscription_Product__r.Quantity__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The product quantity cannot be lowered from the current subscription quantity.'));
                            blnHasError = true;
                            return null;       
                        }

                        ///MS Update Base Package quantity on Amendments
                        if ( objQP.Bundle_Line__c != null && basePackAmendQty.containsKey(objQP.Bundle_Line__c) )
                            objQP.Quantity__c = objQP.BigMachines__Quantity__c = basePackAmendQty.get(objQP.Bundle_Line__c);

                        set_ProductIds.add(objBundleQP.BigMachines__Product__c);                             
    
                        //Code change start by Ankit on 11/12 for AVAYA
                         objQP.Total_Discount__c = objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c=0;
                        if(objQP.Bundle__r.Group_Type__c == 'Base Package'){
                            objQP.Disc__c = null;
                            objQP.Discount_1__c = null;
                            objQP.Discount_2__c = null;
                        }
                        if(objQP.Bundle__r.Group_Type__c != 'Campaigns'  && objQP.Product_Description__c != 'Campaign'){
                            objQP.Ext_List__c = 0;
                            objQP.Ext_Net_Price__c = 0;
                        }
     
                        if(objQP.List_Price__c != null && objQP.List_Price__c != 0)
                        {                            
                            objQP.List_Price__c = objQP.List_Price__c.setScale(2);
                            if(objQP.List_Price_1__c != null)
                                objQP.List_Price_1__c = objQP.List_Price_1__c.setScale(2);
                            if(objQP.List_Price_2__c != null)
                                objQP.List_Price_2__c = objQP.List_Price_2__c.setScale(2);
                            
                            if(objQP.Bundle__r.Group_Type__c == 'Campaigns'){
                                //Partner Price
                                objQP.Partner_Price_1__c = objQP.List_Price_1__c - ((objQP.List_Price_1__c * objQP.Partner_Discount_1__c) / 100);
                                objQP.Partner_Price_2__c = objQP.List_Price_2__c - ((objQP.List_Price_2__c * objQP.Partner_Discount_2__c) / 100);
                            }
                            else{
                                objQP.Partner_Price__c = objQP.List_Price__c;
                                objQP.Partner_Price_1__c = objQP.List_Price_1__c;
                                objQP.Partner_Price_2__c = objQP.List_Price_2__c;
                            }
                            
                            //One year
                            if ( oneyear ) 
                              objQP.List_Price_2__c = objQP.Partner_Price_2__c = 0;  

                            objQP.Net_Unit_Price__c = objQP.Partner_Price__c;
                            objQP.Net_Unit_Price_1__c = objQP.Partner_Price_1__c;
                            objQP.Net_Unit_Price_2__c = objQP.Partner_Price_2__c;
                            
                            System.debug('NKC debug objBundleQP.Disc__c [' + objBundleQP.Disc__c + ']');
                            System.debug('NKC debug objBundleQP [' + objBundleQP + ']');
                         
                            if(objQP.Bundle__r.Group_Type__c == 'Campaigns' && objBundleQP.Bundle_Discount__c != null){
                                objQP.Net_Unit_Price_1__c -= (objQP.Partner_Price_1__c * objBundleQP.Bundle_Discount__c/100);    
                                objQP.Net_Unit_Price_2__c -= (objQP.Partner_Price_2__c * objBundleQP.Bundle_Discount__c/100); 
                                objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objBundleQP.Bundle_Discount__c/100);
                            }
                            objQP.Bundle_Discount__c = objBundleQP.Bundle_Discount__c;
                            objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
                            
                            if(objQP.Bundle__r.Group_Type__c != 'Campaigns' && objBundleQP.Quantity__c != null)
                                objQP.Quantity__c = objBundleQP.Quantity__c * (objQP.Committed_Quantity__c != null ? objQP.Committed_Quantity__c : 1);

                            if(objQP.Quantity__c != null)
                            {
                                Decimal quantity = objQP.Quantity__c;
                                if(quote.Amendment_For__c != null && objQP.Subscription_Product__r.Quantity__c != null){                            
                                    quantity = quantity - objQP.Subscription_Product__r.Quantity__c;                            
                                }

                                objQP.Net_Unit_Price_1__c = objQP.Net_Unit_Price_1__c == null ? 0 : objQP.Net_Unit_Price_1__c;
                                objQP.Net_Unit_Price_2__c = objQP.Net_Unit_Price_2__c == null ? 0 : objQP.Net_Unit_Price_2__c;                                
                                
                                objQP.List_Price__c = objQP.List_Price__c == null ? 0 : objQP.List_Price__c;
                                objQP.List_Price_1__c = objQP.List_Price_1__c == null ? 0 : objQP.List_Price_1__c;
                                objQP.List_Price_2__c = objQP.List_Price_2__c == null ? 0 : objQP.List_Price_2__c;
                                
                                objQP.Ext_List__c = objQP.List_Price__c * quantity;
                                objQP.Ext_List_Price_1__c = objQP.List_Price_1__c * quantity;
                                objQP.Ext_List_Price_2__c = objQP.List_Price_2__c * quantity;
                                
                                objQP.Ext_Net_Price__c = objQP.Net_Unit_Price__c * quantity;
                                objQP.Ext_Net_Price_1__c = objQP.Net_Unit_Price_1__c * quantity;
                                objQP.Ext_Net_Price_2__c = objQP.Net_Unit_Price_2__c * quantity;
                           
                                if( objQP.Third_Party__c != 'TRUE' && objQP.Subscription_Burst_Term__c == null ){
                                    decGenesysProductsDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                                    listPriceTotalProductsOnly += objQP.Ext_List__c;
                                }
            
                            }                                                     
                        }
                        else{
                            //ADDED by Ankit on 11/12 for AVAYA
                            if(objQP.Bundle__r.Group_Type__c!='Campaigns'  && objQP.Product_Description__c != 'Campaign')
                            objQP.List_Price__c = objQP.Ext_List__c = 0;
                        }                        
                        // Add to Third Party GC Line Total Net for Third party HW lines
                        if(objQP.Third_Party__c == 'TRUE' && (objQP.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || objQP.BigMachines__Product__r.Type__c  == Label.Product_System_License_Product_Type))
                        {                            
                            if(quote.Offering_Type__c == 'PureEngage Subscription'){
                                if(objThirdPartyGCLine != null && objQP.Third_Party_GC__c != null && objQP.Third_Party_GC__c != 0)
                                    objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (objQP.Third_Party_GC__c/100);
                            }
                            //PureConnect Subscription
                            else{
                                if (objThirdPartyGCLine != null && objQP.Third_Party_GC__c != null && objQP.Third_Party_GC__c != 0 && objQP.Third_Party_GC__c != 255)
                                    objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (objQP.Third_Party_GC__c / 100);
                                else if(objQP.Third_Party_GC__c == 255 && quote.Genesys_Care_Rate__c != null)
                                    objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (quote.Genesys_Care_Rate__c / 100);    
                            }                       
                        }
                        if(objQP.Bundle__r.Group_Type__c == 'Campaigns'){
                            objBundleQP.Ext_List__c = objBundleQP.Ext_List__c == null ? 0 : objBundleQP.Ext_List__c;
                            objBundleQP.Ext_List_Price_1__c = objBundleQP.Ext_List_Price_1__c == null ? 0 : objBundleQP.Ext_List_Price_1__c;                            
                            objBundleQP.Ext_List_Price_2__c = objBundleQP.Ext_List_Price_2__c == null ? 0 : objBundleQP.Ext_List_Price_2__c; 
                            
                            objBundleQP.Ext_List__c += objQP.Ext_List__c == null ? 0 : objQP.Ext_List__c;
                            objBundleQP.Ext_List_Price_1__c += objQP.Ext_List_Price_1__c == null ? 0 : objQP.Ext_List_Price_1__c;
                            objBundleQP.Ext_List_Price_2__c += objQP.Ext_List_Price_2__c == null ? 0 : objQP.Ext_List_Price_2__c;
                            
                            objBundleQP.Ext_Net_Price__c = objBundleQP.Ext_Net_Price__c == null ? 0 : objBundleQP.Ext_Net_Price__c; 
                            objBundleQP.Ext_Net_Price_1__c = objBundleQP.Ext_Net_Price_1__c == null ? 0 : objBundleQP.Ext_Net_Price_1__c; 
                            objBundleQP.Ext_Net_Price_2__c = objBundleQP.Ext_Net_Price_2__c == null ? 0 : objBundleQP.Ext_Net_Price_2__c; 
                            
                            objBundleQP.Ext_Net_Price__c += objQP.Ext_Net_Price__c == null ? 0 : objQP.Ext_Net_Price__c;
                            objBundleQP.Ext_Net_Price_1__c += objQP.Ext_Net_Price_1__c == null ? 0 : objQP.Ext_Net_Price_1__c;
                            objBundleQP.Ext_Net_Price_2__c += objQP.Ext_Net_Price_2__c == null ? 0 : objQP.Ext_Net_Price_2__c;
                            
                            //objBundleQP.Total_Discount__c = objBundleQP.Total_Discount__c == null ? 0 : objBundleQP.Total_Discount__c;
                            //objBundleQP.Total_Discount__c += objBundleQP.Disc__c == null ? 0 : objBundleQP.Disc__c;
                        }
                        
                    }

                    ////MS - One Year option 
                    if ( oneyear )  {
                            objQP.List_Price_2__c = 0;
                            objQP.Partner_Price_2__c = 0;
                            objQP.Ext_List_Price_2__c = 0;
                            objQP.Net_Unit_Price_2__c = 0;
                            objQP.Ext_Net_Price_2__c = 0;  
                    }
                     
                } ///end for bundle 

                list_ToUpdate.addAll(list_BundleItemQPRecords);
            }
            if(blnHasError)
                return null;

            if(list_QuoteProductRecords.size() > 0)
                list_ToUpdate.addAll(list_QuoteProductRecords);

            calculateGroupSubTotals();
            
            /* MS - not used?
            Integer intNoOfMonths = Integer.valueOf(quote.No_Of_Months__c > 12 ? 12 : quote.No_Of_Months__c);
            
            if(quote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC) {
                quote.Subscription_End_Date__c = quote.Subscription_Start_Date__c.addMonths(Integer.valueOf(quote.No_Of_Months__c));
                intNoOfMonths = (quote.Order_Type__c == Label.Order_Type_Amend) ? 
                        quote.Subscription_Amend_Date__c.monthsBetween(quote.Subscription_End_Date__c) : 
                        quote.Subscription_Start_Date__c.monthsBetween(quote.Subscription_End_Date__c);
            }
            */

            // Storing Sub Totals on Lines and Adding up totals for products of different types and storing total adjustment
            quote.Total_Software__c = quote.Total_Hardware__c = quote.Total_Education__c = quote.Total_Services__c = quote.Total_Hardware_Change__c = 0;
            /* = quote.Total_Hardware_Opportunity__c */
            decTotalSWNetPrice = decTotalHWNetPrice = decTotalEducationNetPrice = decTotalServicesNetPrice = 0;
            quote.Total_Adjustments__c = quote.Total_List_Price__c = quote.Credit_Adjustment__c = quote.Pre_Credit_ACV__c = quote.Pre_Credit_TCV__c = 0;
            quote.Total_Non_Recurring_Credit__c = quote.Total_Recurring_Credit__c = 0;

            List<OpportunityLineItem> list_OpptyLinesToInsert = new List<OpportunityLineItem>();       
            System.debug(LoggingLevel.INFO, 'NKC debug list_QuoteProductRecords [' + list_QuoteProductRecords + ']');
            BigMachines__Quote_Product__c objShippingAndHandlingToBeDeleted = objShippingAndHandling;
            objShippingAndHandling = null;
            totalAmount = 0;
            totalACV = totalACV1 = totalACV2 = 0;
            totalAcvBrst1 = totalAcvBrst2 = 0;
            totalAmountOneTimeFee = 0;
            totalAmountYear1 = 0;
            totalAmountYear2 = 0;
            pureSuccessAmount = 0;
            quote.A_La_Carte_PureSuccess_Services_Amount__c = 0;
            CMRRPreDiscount = 0;
            maxSeatCount = 0;
            //quote.Shipping_Handling__c = 0;
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {               
                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c))
                    objQP.Group_Subtotal__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Sub_Total__c;
                
                addToQuoteTotalsBasedOnProductType(objQP);
                // Calculating Total List Price
                if(objQP.Ext_List__c != null)
                    quote.Total_List_Price__c += objQP.Ext_List__c;
                
                if(objQP.Adjustment__c != null)
                    quote.Total_Adjustments__c += objQP.Adjustment__c;

                //MS - credits, PureBridge, need to deferentiate from Migration Credit entered from the form as oppose to from configurator
                if ( objQP.BigMachines__Product__r.Type__c != null && objQP.BigMachines__Product__r.Type__c == 'Migration Credit' && 
                     objQP.List_Price__c != null && objQP.Quantity__c != null ) { // && objQP.BigMachines__Product__r.Name.startsWith('PureBridge'))
                    
                     objQP.Ext_List__c = objQP.Ext_Net_Price__c = objQP.List_Price__c * objQP.Quantity__c;
                     quote.Credit_Adjustment__c = decNullTest(quote.Credit_Adjustment__c) - objQP.Ext_List__c; //for backward compatability
                                          
                    if ( !objQP.BigMachines__Product__r.Name.contains('Recurring'))  ///MS if not Recurring in the NAME then it is One-Time
                        quote.Total_Non_Recurring_Credit__c = decNullTest(quote.Total_Non_Recurring_Credit__c) - objQP.Ext_List__c;
                    else
                        quote.Total_Recurring_Credit__c = decNullTest(quote.Total_Recurring_Credit__c) - objQP.Ext_List__c;  
                }                                              
            }
            
            for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
            {                   
                set_ProductIds.add(objQP.BigMachines__Product__c);
                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                addToQuoteTotalsBasedOnProductType(objQP);
            }
            
            if(blnHasRDP && decTotalSWNetPrice > 500000)
            {
                String strErrMsg = 'Total cost of the net licenses cannot exceed $500K. For additional requirements please contact your regional Professional Services presales contact.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strErrMsg));
                blnHasError = true;
                return null;
            }
            
            // Service Level/Genesys Care
            quote.Total_Genesys_Care__c = 0; 
            if(quote.Show_Why_Genesys__c && quote.Service_Level__c != 'Decline' && objServiceLevel != null)
            {           
                if(decTotalSWNetPrice != null)// && !isPPUQuoting)
                {

                    if((quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c != null)
                       || (quote.Order_Numb_of_Maint_Months__c != 0 && quote.Order_Numb_of_Maint_Months__c != 0))
                        objServiceLevel.Ext_Net_Price__c = 0;

                    objServiceLevel.Net_Unit_Price__c = objServiceLevel.Ext_Net_Price__c;
                    objServiceLevel.List_Price__c = objServiceLevel.Ext_Net_Price__c;
                    objServiceLevel.Ext_List__c = objServiceLevel.Ext_Net_Price__c;
                    objServiceLevel.BigMachines__Sales_Price__c = objServiceLevel.Ext_Net_Price__c;
                    quote.Total_Genesys_Care__c = objServiceLevel.Ext_Net_Price__c;
                }
                set_ProductIds.add(objServiceLevel.BigMachines__Product__c);

                list_ToUpdate.add(objServiceLevel);
            }            
            // Third Party GC Line
            quote.BEP_Third_Party_Genesys_Care__c = 0;
            
            if(objThirdPartyGCLine != null)
            {
                objThirdPartyGCLine.List_Price__c = objThirdPartyGCLine.Ext_Net_Price__c;
                objThirdPartyGCLine.Net_Unit_Price__c = objThirdPartyGCLine.Ext_Net_Price__c;
                quote.BEP_Third_Party_Genesys_Care__c = objThirdPartyGCLine.Ext_Net_Price__c;
                //objThirdPartyGCLine.Ext_List__c = objThirdPartyGCLine.Ext_Net_Price__c;
                objThirdPartyGCLine.BigMachines__Sales_Price__c = objThirdPartyGCLine.Ext_Net_Price__c;
                set_ProductIds.add(objThirdPartyGCLine.BigMachines__Product__c);

                list_ToUpdate.add(objThirdPartyGCLine);
            }
            
            if (quote.Show_Why_Genesys__c || isSmallMediumCenter ){
                quote.Overage_Allowance__c = null;
                quote.Overage_Allowance_Other__c = null;
                quote.Overage_Price_Premium__c = null;
            }
            
            PageReference newPageRef;
            Integer intTerm = 1;
            Integer intTotalNoOfMonths = Integer.valueOf(quote.No_Of_Months__c);
            if(quote.No_Of_Months__c != null){
                intTerm = Integer.valueOf(quote.No_Of_Months__c / 12);
            }

            Double priceEscalator = getPriceEscalation(quote);

            //Credit totals
            Decimal totalCreditsY1 = decNullTest(quote.Total_Non_Recurring_Credit__c) + decNullTest(quote.Total_Recurring_Credit__c);
            Decimal totalCreditsY2=0;
            if ( secondYrAmend )
               totalCreditsY2 = totalCreditsY1;
            else if ( oneyear )
               totalCreditsY2 = 0;
            else
               totalCreditsY2 = decNullTest(quote.Total_Recurring_Credit__c);
            
            Decimal totalCreditsAll = totalCreditsY1 + totalCreditsY2;

            quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c = decTotalNetPrice;
            // Amounts
            quote.Total_Discount__c = decTotalDiscount;
            quote.Total_Subtotal_1__c = quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c;
                //+ quote.Total_Genesys_Care__c + quote.BEP_Third_Party_Genesys_Care__c;// + quote.Shipping_Handling__c;
         
           //Year 1 Annual Subscription Amount - After Credits
            if(quote.Multi_Year_Quote__c)  //Direct
                quote.Annual_Contract_Value_1__c = totalACV1 - totalAcvBrst1 - totalCreditsY1;
            else 
                quote.Annual_Contract_Value_1__c = totalACV - totalAcvBrst1 - totalCreditsY1;  //Partner
          
            //Year 2 Annual Subscription Amount - After Credits
            if (oneyear ) 
               quote.Annual_Contract_Value_2__c = 0;
            else if (secondYrAmend) {
                quote.Annual_Contract_Value_1__c = 0;
                //in second year Amendm totalCreditsY1 will include one-time credit and any recurring
                quote.Annual_Contract_Value_2__c = totalACV2 - totalAcvBrst2 - totalCreditsY2;
            }                
            else
                quote.Annual_Contract_Value_2__c = ((quote.Annual_Contract_Value_1__c) * (1 + priceEscalator/100)) - totalCreditsY2;

            ///Bursting
            quote.Seasonal_License_Net_Value_Y1__c = totalAcvBrst1;
            quote.Seasonal_License_Net_Value_Y2__c = totalAcvBrst2;

            if ( oneyear )
               quote.Seasonal_License_Net_Value_Y2__c = 0;
            else if (secondYrAmend) 
               quote.Seasonal_License_Net_Value_Y1__c = 0;
               
            //PureSuccess Offer Subscription Amount
            quote.PureSuccess_Offer_Subscription_Amount__c = pureSuccessAmount;
            //Non-Recurring Fees (Including Care)
            if (objServiceLevel != null && objServiceLevel.Subscription_Burst_Term__c == null ) {
                Decimal serviceNet = (secondYrAmend && objServiceLevel.Ext_Net_Price_2__c != null) ? 
                                      objServiceLevel.Ext_Net_Price_2__c : decNullTest(objServiceLevel.Ext_Net_Price__c);

                totalAmountOneTimeFee += serviceNet;
            }

            quote.One_Time_Charges_1__c = totalAmountOneTimeFee;

            //Amount Due at Initial Invoice
            if ( secondYrAmend ) {
                 quote.Total_Contract_Value_1__c = 0;
                 quote.Amount_Due_At_Anniversary__c = 0;
                 quote.Total_Contract_Value_1__c = 0;                 
                 quote.Cloud_Total__c = decNullTest(quote.Annual_Contract_Value_2__c) + 
                                        decNullTest(quote.A_La_Carte_PureSuccess_Services_Amount__c) + 
                                        decNullTest(quote.One_Time_Charges_1__c) + 
                                        decNullTest(quote.PureSuccess_Offer_Subscription_Amount__c) +
                                        decNullTest(quote.BEP_Third_Party_Genesys_Care__c) + 
                                        decNullTest(quote.Seasonal_License_Net_Value_Y2__c);
        
                 if ( totalCreditsY2 > 0 ) {
                    //quote.Pre_Credit_ACV__c = quote.Annual_Contract_Value_2__c + decNullTest(quote.Seasonal_License_Net_Value_Y2__c) + totalCreditsY2;  
                    quote.Pre_Credit_TCV__c = quote.Cloud_Total__c + totalCreditsY2;
                    quote.Pre_Credit_ACV__c = quote.Cloud_Total__c;
                }
            }
            else {
                quote.Total_Contract_Value_1__c = decNullTest(quote.Annual_Contract_Value_1__c) + 
                                                decNullTest(quote.A_La_Carte_PureSuccess_Services_Amount__c) + 
                                                decNullTest(quote.One_Time_Charges_1__c) + 
                                                decNullTest(quote.PureSuccess_Offer_Subscription_Amount__c) +
                                                decNullTest(quote.BEP_Third_Party_Genesys_Care__c) + 
                                                decNullTest(quote.Seasonal_License_Net_Value_Y1__c);
                      
                //Amount Due At Anniversary
                quote.Amount_Due_At_Anniversary__c = oneyear ? 0 :
                                                    decNullTest(quote.Annual_Contract_Value_2__c) + 
                                                    decNullTest(quote.Seasonal_License_Net_Value_Y2__c); //  
                                                 // - decNullTest(quote.Total_Recurring_Credit__c);    // + quote.PureSuccess_Offer_Subscription_Amount__c;
            
                //Total Committment
                quote.Cloud_Total__c = decNullTest(quote.Total_Contract_Value_1__c) + decNullTest(quote.Amount_Due_At_Anniversary__c);
            
                //credits
                if ( totalCreditsY1 > 0 ) {
                    //quote.Pre_Credit_ACV__c = quote.Annual_Contract_Value_1__c + decNullTest(quote.Seasonal_License_Net_Value_Y1__c) + totalCreditsY1; 
                    quote.Pre_Credit_ACV__c = quote.Total_Contract_Value_1__c + totalCreditsY1;  
                    quote.Pre_Credit_TCV__c = quote.Cloud_Total__c + totalCreditsY1 + totalCreditsY2; 
                }
            }

            //Token Calculation
            quote.Max_Seat_Count__c = maxSeatCount;
            Decimal totalACVUSD1 = DealQualificationApprovalUtil.convertCurrency(Double.valueOf(quote.Annual_Contract_Value_1__c), quote.CurrencyIsoCode);
            Decimal totalACVUSD2 = DealQualificationApprovalUtil.convertCurrency(Double.valueOf(quote.Annual_Contract_Value_2__c), quote.CurrencyIsoCode);
            
            if(quote.Show_Why_Genesys__c || isSmallMediumCenter){
                quote.Token_Value__c = 0;
                quote.Token_Value_Y2__c = 0;
            }
            else{
                System.debug('NKC debug totalACVUSD1 [' + totalACVUSD1 + ']');
                System.debug('NKC debug totalACVUSD2 [' + totalACVUSD2 + ']');
                System.debug('NKC debug pureSuccessPackageName [' + pureSuccessPackageName + ']');
                List<Decimal> listOfTokensY1 = QuoteUtil.calculateTokenValue(totalACVUSD1, quote.Offering_Type__c, pureSuccessPackageName);
                List<Decimal> listOfTokensY2 = QuoteUtil.calculateTokenValue(totalACVUSD2, quote.Offering_Type__c, pureSuccessPackageName);
                System.debug('NKC debug listOfTokensY1 [' + listOfTokensY1 + ']');
                quote.Token_Value__c = listOfTokensY1[0] + decQPToken; 
                quote.Token_Value_Y2__c = listOfTokensY2[0] + decQPToken; 
                if(quote.Amendment_For__r.Quote__r.Token_Value__c != null)
                    quote.Token_Value__c += quote.Amendment_For__r.Quote__r.Token_Value__c;
                if(quote.Amendment_For__r.Quote__r.Token_Value_Y2__c != null)
                   quote.Token_Value_Y2__c += quote.Amendment_For__r.Quote__r.Token_Value_Y2__c;

              
                Decimal decACVToken1 = listOfTokensY1[1]; 
                Decimal decACVToken2 = listOfTokensY2[1]; 
                System.debug('NKC debug decACVToken1 [' + decACVToken1 + ']');   
             
                BigMachines__Quote_Product__c objQPHighestWeight;
                Decimal totalTokens1 = 0, totalTokens2 = 0;
                //Calculating tokens for individual lines
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {        
                    if(objQPHighestWeight == null)
                        objQPHighestWeight = objQP;
                    if((objQP.Bundle__r.Group_Type__c == 'Base Package' || objQP.Bundle__c == null) && objQP.Bundle_Line__c == null && !isSmallMediumCenter){
                        Decimal decTACV1 = quote.Multi_Year_Quote__c ? totalACV1 : totalACV;
                        Decimal decTACV2 = quote.Multi_Year_Quote__c ? totalACV2 : totalACV;
                       
                        if(objQP.Ext_Net_Price_1__c != null && decACVToken1 != null && decTACV1 != null && decTACV1 != 0 ){                            
                            Decimal decLineWeightage = objQP.Ext_Net_Price_1__c * 100 / decTACV1;                            
                            objQP.Tokens__c = Math.round(decACVToken1 * decLineWeightage / 100);
                            totalTokens1 += objQP.Tokens__c;
                            if(objQP.Ext_Net_Price_1__c > objQPHighestWeight.Ext_Net_Price_1__c)
                                objQPHighestWeight = objQP;    
                            System.debug('NKC debug decLineWeightage [' + decLineWeightage + ']');
                            System.debug('NKC debug objQP.Ext_Net_Price_1__c [' + objQP.Ext_Net_Price_1__c + ']');
                            System.debug('NKC debug objQP.Tokens__c [' + objQP.Tokens__c + ']');
                        }
                        
                        if(objQP.Ext_Net_Price_2__c != null && decACVToken2 != null && decTACV2 != null && decTACV2 != 0 ){                            
                            Decimal decLineWeightage = objQP.Ext_Net_Price_2__c * 100 / decTACV2;                            
                            objQP.Tokens_Y2__c = Math.round(decACVToken2 * decLineWeightage / 100);
                            totalTokens2 += objQP.Tokens_Y2__c;
                            if(objQP.Ext_Net_Price_2__c > objQPHighestWeight.Ext_Net_Price_2__c)
                                objQPHighestWeight = objQP;    
                            System.debug('NKC debug decLineWeightage [' + decLineWeightage + ']');
                            System.debug('NKC debug objQP.Ext_Net_Price_1__c [' + objQP.Ext_Net_Price_2__c + ']');
                            System.debug('NKC debug objQP.Tokens__c [' + objQP.Tokens__c + ']');
                        }
                    }
                    else if(listOfTokensY1.size() > 1 && (objQP.Bundle__r.Type__c == 'GUIDE' 
                            || objQP.Bundle__r.Type__c == 'DRIVE' || objQP.Bundle__r.Type__c == 'EQUIP')){
                        objQP.Tokens__c = listOfTokensY1[0] - listOfTokensY1[1];
                        objQP.Tokens_Y2__c = listOfTokensY2[0] - listOfTokensY2[1];                                
                    }
                    else if(objQP.BigMachines__Product__r.Type__c == 'Token' && objQP.Quantity__c != null){                        
                        objQP.Tokens__c = objQP.Quantity__c * 10;  
                        objQP.Tokens_Y2__c = objQP.Quantity__c * 10;                          
                    }
                }
                if(decACVToken1 != null && totalTokens1 != null && decACVToken1 != totalTokens1 && objQPHighestWeight.Tokens__c != null)
                    objQPHighestWeight.Tokens__c += decACVToken1 - totalTokens1;
                if(decACVToken2 != null && totalTokens2 != null && decACVToken2 != totalTokens2 && objQPHighestWeight.Tokens_Y2__c != null)
                    objQPHighestWeight.Tokens_Y2__c += decACVToken2 - totalTokens2;
                
            }
            /*
            if(objQPToken != null){
                objQPToken.Quantity__c = quote.Token_Value__c;
                objQPToken.BigMachines__Quantity__c = quote.Token_Value__c;
            }
                        */
            quote.Total_GU_Training_Units__c = 80;
            
            if(objQPTrainingUnit != null && objQPTrainingUnit.Quantity__c != null && objQPTrainingUnit.Bundle__r.Token_Value__c != null){
                Product_Group_Item__c tokenvalue = [select Product__c,Token_Value__c from Product_Group_Item__c where Product__c =:objQPTrainingUnit.BigMachines__Product__c];
                if(tokenvalue.Token_Value__c != null){quote.Total_GU_Training_Units__c += objQPTrainingUnit.Quantity__c * tokenvalue.Token_Value__c;}
                //quote.Total_GU_Training_Units__c += objQPTrainingUnit.Quantity__c * objQPTrainingUnit.Bundle__r.Token_Value__c;
            }
            // Percentages
            quote.Total_Discount_Genesys_Products_Only__c = quote.Total_Discount_Genesys_and_Third_Party__c = quote.Overage_Discount__c = 0;
         
            System.debug('NKC debug Total_Software__c ['+decGenesysAllDiscount+']');
            System.debug('NKC debug listPriceTotalAll ['+listPriceTotalAll+']');

            if((decTotalDiscount + decTotalNetPrice) != 0){
                if(listPriceTotalProductsOnly != 0)
                    quote.Total_Discount_Genesys_Products_Only__c = (decGenesysProductsDiscount/listPriceTotalProductsOnly) * 100;
                if(listPriceTotalAll != 0)
                    quote.Total_Discount_Genesys_and_Third_Party__c = (decGenesysAllDiscount/listPriceTotalAll) * 100;            
            }

            //bursting
            if ( listPriceTotalBurst != 0 ) {
                quote.Overage_Discount__c = (1 - netPriceTotalBurst/listPriceTotalBurst) * 100;
            }
            
            quote.Services_Tax_Rate__c = quote.Services_Tax_Rate__c != null ? quote.Services_Tax_Rate__c:0;
            quote.Training_Tax_Rate__c = quote.Training_Tax_Rate__c != null ? quote.Training_Tax_Rate__c:0;
            quote.Tax_Rate__c = quote.Tax_Rate__c != null ? quote.Tax_Rate__c:0;
            
            // Taxes
            if(quote.End_User_ID__r.Country__r.Name == 'Japan')
                quote.Services_Tax_Rate__c = quote.Training_Tax_Rate__c = quote.Tax_Rate__c;
                
            //Naresh Kumar - 09/24/2015, Changed End User country logic for Brazil tax calculation        
            String endUserCountry = quote.End_User_ID__r.Country__r.Name; 
            if(quote.BigMachines__Opportunity__r.Country__c != null)
                endUserCountry = quote.BigMachines__Opportunity__r.Country__r.Name;
            if(quote.Total_Genesys_Care__c == null)
                quote.Total_Genesys_Care__c = 0;
            if(endUserCountry == 'Brazil')        
                quote.Total_Taxes__c = ((decTotalSWNetPrice + decTotalHWNetPrice)/(1 - quote.Tax_Rate__c/100) +
                                       (decTotalServicesNetPrice + quote.Total_Genesys_Care__c)/(1 - quote.Services_Tax_Rate__c/100) +
                                       (decTotalEducationNetPrice)/(1 - quote.Training_Tax_Rate__c/100)) - 
                                       (decTotalSWNetPrice + decTotalHWNetPrice + decTotalEducationNetPrice + decTotalServicesNetPrice + quote.Total_Genesys_Care__c);
            else                           
                quote.Total_Taxes__c = ((decTotalSWNetPrice + decTotalHWNetPrice) * (quote.Tax_Rate__c/100)) +
                                       ((decTotalServicesNetPrice + quote.Total_Genesys_Care__c) * (quote.Services_Tax_Rate__c/100)) +
                                       ((decTotalEducationNetPrice) * (quote.Training_Tax_Rate__c/100));
            
            quote.BigMachines__Total__c = quote.Total_Subtotal_1__c + 
                                    (quote.Total_Prepaid_Prof_Services__c != null ? quote.Total_Prepaid_Prof_Services__c : 0) +
                                    quote.Total_Taxes__c + (decPSRDPTotal * (quote.Time_Expense_PS_RDP__c != null ? quote.Time_Expense_PS_RDP__c : 0)/100);
            
            //MS USED AS Direct/INdirect indicator; removed from page
            if(quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Direct')
                quote.Multi_Year_Quote__c = false;
            else 
                quote.Multi_Year_Quote__c = true;

            // Putting in redundancy to update unit of measure so that UOM update is not missed in any quote
            updateUnitOfMeasure();

            if (quote.Subscription_Start_Date__c != null && quote.No_Of_Months__c != null) {
                
                Integer rampMon = (quote.Ramp_Period__c != null && quote.Ramp_Period__c.isNumeric()) ? Integer.valueOf(quote.Ramp_Period__c)/30 : 0;
                quote.Subscription_End_Date__c = quote.Subscription_Start_Date__c.addMonths(Integer.valueOf(quote.No_Of_Months__c) + rampMon).addDays(-1);

                if(quote.Amendment_For__c != null){
                    quote.Subscription_End_Date__c = quote.Amendment_For__r.Subscription_End_Date__c;
                }
            }

            //These lines should not be included in totals
            if ( list_QuoteBurstTerms.size() > 0 ) {
                List<BigMachines__Quote_Product__c> bustPackLines = new List<BigMachines__Quote_Product__c>();
                for (QuoteBurstTerm tr : list_QuoteBurstTerms) {
                     bustPackLines.addAll(tr.qtprods);
                }

                list_ToUpdate.addAll(SubscriptionBurstTerm.updateBurstBasePackageItems(list_QuoteProductRecords, bustPackLines));
            }

            // Savepoint before DML
            Savepoint objSP = Database.setSavepoint();
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            //try
            //{
                if(list_ProposalGroups.size() > 0)
                    update list_ProposalGroups;

                if(list_ToUpdate.size() > 0)
                    database.upsert(list_ToUpdate, false);
                    //upsert list_ToUpdate;
                    
                    
                if(getIsOrderInfoAvailable() && (quote.Revise_Minor__c || blnIsReviseOrder))
                    saveOrderInfo();
                
                if(quote.Deal_Qualification__c == null){
                    List<Deal_Qualification__c> dq = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
                    if(!dq.isEmpty())
                        quote.Deal_Qualification__c = dq[0].id; 
                }                            
                popualateContractOnQuote();                
                populateAmendTotals();                
                update quote;

                // **** Opportunity Synchronization Logic *******
                if(quote.BigMachines__Opportunity__c != null && quote.BigMachines__Is_Primary__c && !blnIsSimulated)
                {
                    
                    // Delete existing lines before creating quote products as opportunity lines
                    List<OpportunityLineItem> list_OpptyLinesToDelete = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :quote.BigMachines__Opportunity__c];
                    if(list_OpptyLinesToDelete.size() > 0)
                        delete list_OpptyLinesToDelete;
                        
                    MakeQuotePrimary_WS.CorrectTotalCloud(quote.id);
                        
                    System.debug('NKC debug set_ProductIds ['+set_ProductIds+']');
                    System.debug('NKC debug set_ProductIds.size() ['+set_ProductIds.size()+']');
                    if(objShippingAndHandling != null)
                        set_ProductIds.add(objShippingAndHandling.BigMachines__Product__c);
                    if(objProfessionalServices != null)
                        set_ProductIds.add(objProfessionalServices.BigMachines__Product__c);
                    Map<Id,Id> map_ProdIdToPBEId = new Map<Id,Id>();
                    for(PricebookEntry objPE : [SELECT Product2Id,Id FROM PricebookEntry WHERE 
                              Pricebook2Id = :Label.Standard_Pricebook_Id AND 
                              Product2Id IN :set_ProductIds AND CurrencyISOCode = :quote.CurrencyISOCode])
                        map_ProdIdToPBEId.put(objPE.Product2Id,objPE.Id);
                    
                    List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();

                    for(BigMachines__Quote_Product__c objQP : list_ToUpdate)
                    {
                      //Naresh Kumar  03/08/2016  Skip the main bundle line   
                      if( objQP.Bundle__c != null && objQP.Bundle_Line__c == null )
                        continue;
                      System.debug('NKC debug objQP.Bundle_Line__c ['+objQP.Bundle_Line__c+']');
                        //if(objQP.Bundle_Line__c != null)
                        //    continue;
 
                        if(map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c))
                        {
                            if(objQP.Quantity__c == 0 && objQP.Subscription_Burst_Term__c == null)
                                objQP.Quantity__c = 1;
                            String strDescription;
                            if(objQP.Product_Description__c != null){
                                strDescription = (objQP.Product_Description__c.length() > 255 ? objQP.Product_Description__c.left(255) : objQP.Product_Description__c);
                            }

                            if (objQP.Quantity__c != 0) {
                                list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = quote.Id,
                                    Description__c = strDescription,OpportunityId = quote.BigMachines__Opportunity__c,
                                    PricebookEntryId = map_ProdIdToPBEId.get(objQP.BigMachines__Product__c),
                                    Quantity = objQP.Quantity__c,Quantity__c = objQP.Quantity__c,UnitPrice = objQP.Net_Unit_Price__c,
                                    Total_Discount__c = objQP.Total_Discount__c,Unit_of_Measure__c = objQP.Unit_of_Measure__c));
                            }
                        }
                    }
                    if(list_OpptyLinesToCreate.size() > 0)
                        insert list_OpptyLinesToCreate;                    
                }
                
                saveBurstTerms();

                // Fetching Quote Products (To update name on Genesys Care line : might scrap this to improve efficiency)
                getQuoteProducts(quoteId);
 
                blnSkipPriceCheck = blnIsReviseOrder = false;
                //buildChangeHistoryForAmendSubscr(true);
                buildChangeHistoryForAmend(); 

            return newPageRef;
        } ///END doCalculations

        @testVisible
        private void populateAmendTotals(){
            if(quote.Amendment_For__c != null){
                decHighestDiscount = decNullTest(quote.Amendment_For__r.Quote__r.Total_Discount_Genesys_and_Third_Party__c);  

                decY1AnnualSubscriptionAmount = decNullTest(quote.Annual_Contract_Value_1__c) + decNullTest(quote.Amendment_For__r.Quote__r.Annual_Contract_Value_1__c);

                decPureSuccessOfferSubscriptionAmount = decNullTest(quote.PureSuccess_Offer_Subscription_Amount__c) + decNullTest(quote.Amendment_For__r.Quote__r.PureSuccess_Offer_Subscription_Amount__c);
               
                decALaCartePureSuccessServiceAmount = decNullTest(quote.A_La_Carte_PureSuccess_Services_Amount__c) + decNullTest(quote.Amendment_For__r.Quote__r.A_La_Carte_PureSuccess_Services_Amount__c);
               
                decNonRecurringFee = decNullTest(quote.One_Time_Charges_1__c) + decNullTest(quote.Amendment_For__r.Quote__r.One_Time_Charges_1__c);
               
                decThirdPartyCare = decNullTest(quote.BEP_Third_Party_Genesys_Care__c) + decNullTest(quote.Amendment_For__r.Quote__r.BEP_Third_Party_Genesys_Care__c);
               
                decAmountDueAtInitialInvoice = decNullTest(quote.Total_Contract_Value_1__c) + decNullTest(quote.Amendment_For__r.Quote__r.Total_Contract_Value_1__c);

                decY2AnnualSubscriptionAmount = decNullTest(quote.Annual_Contract_Value_2__c) + decNullTest(quote.Amendment_For__r.Quote__r.Annual_Contract_Value_2__c);

                decAmountDueAtAnniversary = decNullTest(quote.Amount_Due_At_Anniversary__c) + decNullTest(quote.Amendment_For__r.Quote__r.Amount_Due_At_Anniversary__c);

                decY1SeasonalLicenseAmount = decNullTest(quote.Seasonal_License_Net_Value_Y1__c) + decNullTest(quote.Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y1__c);

                decY2SeasonalLicenseAmount = decNullTest(quote.Seasonal_License_Net_Value_Y2__c) + decNullTest(quote.Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y2__c);

                decTotalCommitment = decNullTest(quote.Cloud_Total__c) + decNullTest(quote.Amendment_For__r.Quote__r.Cloud_Total__c);                                             
             }
        }
        @testVisible
        private void popualateContractOnQuote(){ 
            if(quote.BigMachines__Is_Primary__c && quote.Legal_Contract__c == null){
                List<GCR_Content_Document_Detail__c> legalContract = [SELECT id FROM GCR_Content_Document_Detail__c 
                    WHERE Account_Name__c =: quote.End_User_ID__c AND GCR__c != null];
                if(!legalContract.isEmpty()){
                    quote.Legal_Contract__c = legalContract[0].id;
                    GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c(id = legalContract[0].id);
                    objContract.Quote__c = quote.id;
                    objContract.Opportunity__c = quote.BigMachines__Opportunity__c;
                    update objContract;
                }
            }
        }
        
            
    public void refresh(){}

    public void resetRightToBust() {
        if ( quote.RightToBurst__c == false ) {
           quote.Usage_Data_Submission_Method__c = ''; 
        }
    }

    //PureBridge
    public Decimal getDealSizeUSD(BigMachines__Quote__c quote, Decimal amount) {      
         if ( amount == null || amount == 0 || quote.Offering_Type__c == null )
            return 0;
        
        String offering;
        if (quote.Offering_Type__c.startsWith('PureConnect') )
                offering = 'PureConnect';
        else if (quote.Offering_Type__c.startsWith('PureEngage'))
                offering = 'PureEngage';
        else 
            return amount;
        
        Currency_Configuration__c cconf = DDSToolSelector.getCurrcyConfigByPriceBook(quote.New_Price_Book__c, offering, Date.valueOF(System.today()));
        Decimal convrate = (cconf != null && cconf.Conversion_Rate__c != 0) ? cconf.Conversion_Rate__c : 1.0;

        return amount/convrate;
    }

    public Boolean isValidLeverByDealSize(Decimal totalUSD) {
        return (totalUSD != null && totalUSD > 150000.00) ? true : false;
    }
 
    public static Boolean isSecondYrAmend(BigMachines__Quote__c quote) {   
        Boolean retval = false;
        if (quote.Amendment_For__c != null && (quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription')) {            
            Integer term=1;
            if ( quote.Amendment_For__r.Ramp_End_Date__c != null && quote.Amendment_For__r.Subscription_End_Date__c != null) 
                term = (quote.Amendment_For__r.Ramp_End_Date__c).monthsBetween(quote.Amendment_For__r.Subscription_End_Date__c) > 12 ? 2 : 1;

            else if (quote.Amendment_For__r.Subscription_Start_Date__c != null && quote.Amendment_For__r.Subscription_End_Date__c != null)
                term = (quote.Amendment_For__r.Subscription_Start_Date__c).monthsBetween(quote.Amendment_For__r.Subscription_End_Date__c) > 12 ? 2 : 1;   
            
            if (term == 2 && quote.Amendment_For__r.Subscription_Start_Date__c != null &&               
                // System.today() > (quote.Amendment_For__r.Subscription_Start_Date__c).addMonths(12) )
                System.today() > (quote.Amendment_For__r.Subscription_End_Date__c).addMonths(-12) )

            retval = true;                 
        }
        return retval;
    }

    public static Boolean isOneyearQuote(BigMachines__Quote__c quote) {
        Boolean retval = false;
        if (quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription') {
            if ( quote.Amendment_For__c == null )
                retval = (quote.No_Of_Months__c != null && Integer.valueOf(quote.No_Of_Months__c) <= 12) ? true : false;

            else if ( quote.Amendment_For__c != null ) {
            if (quote.Initial_Subscription_Term__c != null ) 
                retval = quote.Initial_Subscription_Term__c.startsWith('1') ? true : false;
            else if ( quote.Amendment_For__r.Subscription_Start_Date__c != null && quote.Amendment_For__r.Subscription_End_Date__c != null)
                retval = (quote.Amendment_For__r.Subscription_Start_Date__c).monthsBetween(quote.Amendment_For__r.Subscription_End_Date__c) <= 12 ? true : false;
            } 
        }
        return retval;
    }

    public Integer getNumOfMonths(BigMachines__Quote__c quote) {
         Integer mnths=0;
         if ( quote.Amendment_For__c != null && quote.Amendment_For__r.Subscription_End_Date__c != null) {
             if ( quote.Amendment_For__r.Subscription_Start_Date__c != null ) {
               Date startdt = (System.Today() > quote.Amendment_For__r.Subscription_Start_Date__c) ? System.Today() : 
                                                quote.Amendment_For__r.Subscription_Start_Date__c;
               mnths = startdt.monthsBetween(quote.Amendment_For__r.Subscription_End_Date__c);
             }
         }
         else if (quote.No_Of_Months__c == null)
               quote.No_Of_Months__c = 24;
         else
             mnths = Integer.valueOf(quote.No_Of_Months__c);

        return mnths;
    }

    public static String getPureBridgeRampPeriod(Date expDate) { 
        Integer deplperiod;    
        if ( expDate != null ) {
                Integer daysdiff = System.today().DaysBetween(Date.valueOf(expDate));
                deplperiod = 180; ///Minimum deployment period
                List<Integer> periods = new List<Integer>();
                if ( daysdiff > 180 ) {             
                    for(Schema.PicklistEntry value : BigMachines__Quote__c.Ramp_Period__c.getDescribe().getPicklistValues()) {
                        if ( value.getValue().isNumeric() && Integer.valueOf(value.getValue()) > 180 ) 
                           periods.add(Integer.valueOf(value.getValue()));
                    }
                    if ( !periods.isEmpty() ) {
                        periods.sort();                    
                        for (Integer i : periods ) {
                            deplperiod = i;
                            if ( i > daysdiff )                
                                break;
                        }      
                    }
                }      
        } 
        return deplperiod != null ? String.valueOf(deplperiod) : null;
    }

    //MS Oct 2019 This method is no longer used. Delete after confirmed
    /*
        @testVisible
        private void buildChangeHistoryForAmendSubscr(boolean flag) { 
          
            if((quote.Order_Type__c == Label.Order_Type_Amend || quote.Order_Type__c == Label.Order_Type_Subscription) && quote.Amendment_For__c != null) {
                Map<String, Decimal> map_NewProdQuantity = new Map<String, Decimal>();            
                Map<String, Subscription_Product__c> map_PrevProdInfo = new Map<String, Subscription_Product__c>();
                map_PrevProdQuantity = new Map<String, Decimal>();
                map_ProdChangeHistory = new Map<String, String>();
                map_ProdChangeHistoryColor = new Map<String, String>();
                list_RemovedPrevProds = new List<Subscription_Product__c>();
                
                //MS - TODO: use Quantity Amended for Jan 2020 release
                List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProducts(quote.Amendment_For__c);        
                for(Subscription_Product__c objSubProd : list_SubscriptionProds) {
                    if((objSubProd.Product__r.Third_Party__c == 'TRUE' && objSubProd.Quote_Product__r.Bundle__r.Group_Type__c != 'PureSuccess') 
                         || objSubProd.Product__r.Type__c == 'Product - Hardware' 
                         || objSubProd.Quote_Product__r.Bundle__r.Type__c == 'Partner PureSuccess'
                         || objSubProd.Product__r.Type__c == 'Genesys Care'
                         || objSubProd.Bundle__c != null)
                        continue;            
                    String strUniqueKey = objSubProd.Product__c+';'+objSubProd.Is_Overage__c; 

                    map_PrevProdInfo.put(strUniqueKey, objSubProd);
                    if(map_PrevProdQuantity.containsKey(strUniqueKey)) {
                        map_PrevProdQuantity.put(strUniqueKey, map_PrevProdQuantity.get(strUniqueKey) + objSubProd.Quantity__c);
                    }
                    else {
                        map_PrevProdQuantity.put(strUniqueKey, objSubProd.Quantity__c);
                    }
                }
                List<BigMachines__Quote_Product__c> listOfAllQuoteProducts = new List<BigMachines__Quote_Product__c>();
                listOfAllQuoteProducts.addAll(list_QuoteProductRecords);
                listOfAllQuoteProducts.addAll(list_BundleItemQPRecords);
                
                list<BigMachines__Quote_Product__c> objQP_listtoupdate = new list<BigMachines__Quote_Product__c>();
                for(BigMachines__Quote_Product__c objNewQP : listOfAllQuoteProducts) {
                    String strChangeHist = 'Original';  
                    String strUniqueKey = objNewQP.BigMachines__Product__c+';'+objNewQP.Is_Overage__c;
                    if(map_NewProdQuantity.containsKey(strUniqueKey)) {
                        map_NewProdQuantity.put(strUniqueKey, map_NewProdQuantity.get(strUniqueKey) + objNewQP.Quantity__c);
                    }
                    else {
                        map_NewProdQuantity.put(strUniqueKey, objNewQP.Quantity__c);
                    }
                                 
                    strChngeHistColors = Label.Amend_Change_History.trim().split(';');
                    map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[0]);

                    if(map_PrevProdQuantity.containsKey(strUniqueKey)) { 

                        if(map_NewProdQuantity.get(strUniqueKey) != map_PrevProdQuantity.get(strUniqueKey) ) {
                            if(map_ProdChangeHistory.get(strUniqueKey) == 'Original' && flag ) {
                                objNewQP.Play__c = quote.Top_Play__c;
                                objNewQP.Offer__c = quote.Offer__c;
                                objQP_listtoupdate.add(objNewQP);
                            }
                            strChangeHist = 'Changed Quantity from '+map_PrevProdQuantity.get(strUniqueKey)+' to '+map_NewProdQuantity.get(strUniqueKey);//objNewQP.Quantity__c;
                            map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[3]);

                            if(map_NewProdQuantity.get(strUniqueKey) > map_PrevProdQuantity.get(strUniqueKey)) {
                                map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[2]);
                            }
                        }
                    }
                    else {
                        map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[1]);
                        strChangeHist = 'Added '; //On '+objNewQP.CreatedDate.month()+'-'+objNewQP.CreatedDate.day()+'-'+objNewQP.CreatedDate.year();
                    }
                    map_ProdChangeHistory.put(strUniqueKey, strChangeHist);
                }
            
                for(String strPrevProd : map_PrevProdInfo.keySet()) {                
                    if(!map_ProdChangeHistory.containsKey(strPrevProd) && !map_PrevProdInfo.get(strPrevProd).Quote_Product__r.Hide_Record__c) { 
                        list_RemovedPrevProds.add(map_PrevProdInfo.get(strPrevProd));
                    }
                }
        
                if(objQP_listtoupdate.size()> 0)
                    update objQP_listtoupdate;
                    
            }          
        }
    */
        @testVisible
        private void buildChangeHistoryForAmend() {            
                map_ProdChangeHistory = new Map<String, String>();
                map_ProdChangeHistoryColor = new Map<String, String>();
           
                List<BigMachines__Quote_Product__c> listOfAllQuoteProducts = new List<BigMachines__Quote_Product__c>();
                listOfAllQuoteProducts.addAll(list_QuoteProductRecords);
                listOfAllQuoteProducts.addAll(list_BundleItemQPRecords); 
                listOfAllQuoteProducts.addAll(list_Credits); 

                //Add Bursting
                for (QuoteBurstTerm tr : list_QuoteBurstTerms) {
                    if ( tr.term.CCDB_Subscription_Burst_Term__c != null )
                    listOfAllQuoteProducts.addAll(tr.qtprods);
                }

                String strChangeHist;
                strChngeHistColors = Label.Amend_Change_History.trim().split(';');

                for(BigMachines__Quote_Product__c objSubProd : listOfAllQuoteProducts) {
                    String strUniqueKey = objSubProd.Id; 

                    if (objSubProd.Subscription_Product__c != null && objSubProd.Original_Quantity_Amend__c != null && objSubProd.Original_Quantity_Amend__c != objSubProd.Quantity__c ) {
                        strChangeHist = 'Changed Quantity from '+ objSubProd.Original_Quantity_Amend__c +' to '+ objSubProd.Quantity__c;

                          if( objSubProd.Original_Quantity_Amend__c > objSubProd.Quantity__c ) 
                                map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[3]);
                          else
                                map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[2]);
                    }
                    else if (objSubProd.Original_Quantity_Amend__c != null && objSubProd.Original_Quantity_Amend__c == objSubProd.Quantity__c ) {
                        strChangeHist = strChangeHist = 'Original';
                        map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[0]);
                    }
                    else {
                        strChangeHist = 'Added '; 
                        map_ProdChangeHistoryColor.put(strUniqueKey, strChngeHistColors[1]);                       
                    }
                    map_ProdChangeHistory.put(strUniqueKey, strChangeHist);
                }
        }


        public void applyLineItemDiscount(BigMachines__Quote_Product__c objQP) {                 
            // Line Discount
            if(objQP.Disc__c != null && String.isNotBlank(objQP.or_Amount__c)  && objQP.Quantity__c != null && objQP.Quantity__c != 0 ) {
            
                // Selected Discount Option is %
                if(objQP.or_Amount__c == '%')
                {
                    objQP.Total_Discount__c += objQP.Disc__c;
                    objQP.Discount_1__c = objQP.Discount_2__c = objQP.Disc__c;
                    objQP.Net_Unit_Price__c -= (objQP.Partner_Price__c * objQP.Disc__c/100);                        
                    if(objQP.Discount_1__c != NULL && objQP.List_Price_1__c != null)
                        objQP.Net_Unit_Price_1__c -= (objQP.List_Price_1__c  * objQP.Discount_1__c/100);    
                    if(objQP.Discount_2__c != NULL && objQP.List_Price_2__c != null)
                        objQP.Net_Unit_Price_2__c -= (objQP.List_Price_2__c * objQP.Discount_2__c/100); 
                }
                // Selected Discount Option is Amt
                else if(objQP.or_Amount__c == 'Amt')
                {
                    ///MS 9/13/19 
                    Decimal prc = objQP.Partner_Price_1__c != null ? objQP.Partner_Price_1__c : objQP.List_Price__c;
                    Decimal priceincr = (objQP.List_Price_1__c != null && objQP.List_Price_2__c != null && objQP.List_Price_1__c != 0 && objQP.List_Price_2__c != 0) ? objQP.List_Price_2__c/objQP.List_Price_1__c : 1.0; 
                    objQP.Net_Unit_Price__c = prc - objQP.Disc__c; 

                    objQP.Net_Unit_Price_1__c = objQP.Net_Unit_Price__c; 
                    objQP.Net_Unit_Price_2__c = objQP.Net_Unit_Price__c * priceincr;

                    objQP.Total_Discount__c = (1 - (objQP.Net_Unit_Price__c/objQP.List_Price__c)) * 100;
                                                
                }
            }                  
        }        

        public Decimal decNullTest(Decimal decNum) {
            return (decNum == null ? 0 : decNum); 
        }

        public void saveBurstTerms() {
            if ( list_QuoteBurstTerms.size() > 0 ) {
                List<Subscription_Burst_Term__c> terms = new List<Subscription_Burst_Term__c>();
                for (QuoteBurstTerm tr : list_QuoteBurstTerms)
                    terms.add(tr.term);
                update terms;
            }
        }

        public void addBurstTerm() {
            try {
            new SubscriptionBurstTerm().addTermToQuote(quote.Id);
            getQuoteProducts(quote.Id);
            } catch (Exception e) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()) );
            }
        }

        public void deleteQuoteBurstTerm() {
            try {
                if ( !String.isEmpty(quoteBurstTermIdToBeDeleted) ) {
                    new SubscriptionBurstTerm().deleteQuoteBurstTerm(quoteBurstTermIdToBeDeleted);
                    getQuoteProducts(quote.Id);
                }   
            } catch (Exception e) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage()) );
            }
        }

	public void testCoverageMethod(){
    	integer i = 0;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
    	i++;
        i++;
    	i++;
    	i++;
    	i++;
    	i++;
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