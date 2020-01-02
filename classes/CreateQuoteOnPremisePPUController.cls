public without sharing class CreateQuoteOnPremisePPUController
    {
        public BigMachines__Quote__c quote {get; set;}
        public List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
        public String quoteProductIdToBeDeleted {get; set;}
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
        public Map<String,List<SelectOption>> map_FlavorsToSelectOptions {get; private set;}
        Id idSoldToAccount;
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
        public Decimal totalAmount {get; private set;}
        public Decimal regionalDiscount {get; private set;}
        public Decimal CMRRPreDiscount {get; private set;}
        public Integer maxSeatCount;
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
        public CreateQuoteOnPremisePPUController()
        {
            /*
            isPPUQuoting = false;
            if(ApexPages.currentPage().getUrl().contains('CreateQuoteOnPremisePPU')){
                isPPUQuoting = true;            
            }
            */
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
            
        }
        
        private void init()
        {
            
            quoteId = ApexPages.currentPage().getParameters().get('id');
            objUngrouped = new Quote_Proposal_Group__c();
            objMassUpdateInput = new BigMachines__Quote_Product__c();
            objAddProductInput = new BigMachines__Quote_Product__c();
            blnIsHeaderChecked = blnShowByPassApprovals = blnSkipPriceCheck = blnIsReviseOrder = 
            blnShowExportScreeningMsg = blnShowExportScreeningExpireMsg = blnHasRDP = blnHasError = blnIsNewPricing = blnIsSimulated = blnHasViolations = false;
            
            blnShowSelectColumns = false;
            //objColumnPreference = User_Col_Preference__c.getInstance(UserInfo.getUserId());
            List<User_Col_Preference__c> list_UserColPref = [SELECT Id,Third_Party__c,Name,Building_Block__c,Ext_List_Price__c,
                            List_Price__c,Net_Unit_Price__c,PM_Approver__c,Product_Specific_Discount__c,Unit_of_measure__c, Accepted_Volume_Discount__c,NG1_PPU_Gold_USD__c 
                            FROM User_Col_Preference__c WHERE User__c = :UserInfo.getUserId()];
            if(list_UserColPref.size() == 0)
                objColumnPreference = new User_Col_Preference__c(Third_Party__c = true,User__c = UserInfo.getUserId(),
                            Building_Block__c = true,Ext_List_Price__c = true,List_Price__c = true,Net_Unit_Price__c = true,
                            PM_Approver__c = true,Product_Specific_Discount__c = true,Unit_of_measure__c = true);
            else
                objColumnPreference = list_UserColPref[0];
            
            // Fetching Quote information
            quote = getQuote((Id)quoteId);
            quote.Pricing_Model__c = 'PPU';
            populatePPUDiscounts();
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
                
            objUngrouped = new Quote_Proposal_Group__c(CurrencyISOCode = quote.CurrencyISOCode);
            
            list_QuoteProducts = new List<QuoteProductWrapper>();
            if(quoteId != null)
            {   
                // Getting regional PPU discount                     
                getRegionalDiscount();
                   
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
            
            
            showReviseDQPopup = false;
        }
        
        private void populatePPUDiscounts(){
            List<Deal_Qualification__c> dqs = [SELECT Status__c, Partner_Tier_Discount__c, Deal_Registration_Discount__c,
                Term_Discount__c, Seat_Size_Discount__c, Term_Discount_Range__c, Seat_Discount_Range__c, New_Logo_Discount_Range__c,
                Term_Length__c, Seat_Count_Tier__c FROM Deal_Qualification__c WHERE Type__c =: DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL
                AND Pricing_Type__c =: quote.Quote_Opportunity_Type__c AND Opportunity__c =: quote.BigMachines__Opportunity__c AND Pricing_Model__c = 'PPU'];
            if(!dqs.isEmpty()){
                dq = dqs[0];
                
                dqStatus = dqs[0].Status__c;
                /*
                dq.Partner_Tier_Discount__c = dq.Partner_Tier_Discount__c == null ? 0 : dq.Partner_Tier_Discount__c;
                dq.Deal_Registration_Discount__c = dq.Deal_Registration_Discount__c == null ? 0 : dq.Deal_Registration_Discount__c ;
                dq.Term_Discount__c = dq.Term_Discount__c == null ? 0 : dq.Term_Discount__c ;
                dq.Seat_Size_Discount__c = dq.Seat_Size_Discount__c == null ? 0 : dq.Seat_Size_Discount__c;                
                totalDiscount = dq.Partner_Tier_Discount__c + dq.Deal_Registration_Discount__c + dq.Term_Discount__c + dq.Seat_Size_Discount__c;
                */                
            }   
            else
                dq = new Deal_Qualification__c();
                totalDiscount = 0;
                dq.Term_Discount__c = 0;
                dq.Term_Discount_Range__c = '0 - 0%';
                dq.Deal_Registration_Discount__c = 0;
                quote.PO_for_FYM__c = 'FYM included in the same PO';
                /*
                String termLength;
                if(quote.BigMachines__Opportunity__r.Term_Commitment__c != null)
                    termLength = quote.BigMachines__Opportunity__r.Term_Commitment__c.replace(' ','').replace('Years','').replace('Year','');
                try{
                    dq.Term_Length__c = Decimal.valueOf(termLength) * 12;                
                }catch(Exception ex){}
                */
                if(quote.No_Of_Months__c != null){
                    List<String> allData = new List<String>(PPU_Term_Discount__c.getAll().keyset());
                    allData.sort();
                    for(String eachValue : allData){
                        PPU_Term_Discount__c eachTermDiscount = PPU_Term_Discount__c.getAll().get(eachValue);
                        if(quote.No_Of_Months__c <= eachTermDiscount.Month__c){
                            dq.Term_Discount__c = eachTermDiscount.Discount__c;
                            dq.Term_Discount_Range__c = eachTermDiscount.Range__c;
                            break;
                        }
                    }                
                }
                totalDiscount += (dq.Term_Discount__c == null ? 0 : dq.Term_Discount__c);
                if(PPU_Deal_Registration_Discount__c.getAll().get(quote.BigMachines__Opportunity__r.Partner_Opportunity_Source__c) != null )
                    dq.Deal_Registration_Discount__c = PPU_Deal_Registration_Discount__c.getAll().get(quote.BigMachines__Opportunity__r.Partner_Opportunity_Source__c).Discount__c;
                totalDiscount += (dq.Deal_Registration_Discount__c == null ? 0 : dq.Deal_Registration_Discount__c);    
                String regionName = quote.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c;
                String countryName = quote.BigMachines__Opportunity__r.Sold_To_Country__r.Name;        
                dq.Partner_Tier_Discount__c = 0;
                PPU_Regional_Tier_Discount__c tierDiscount = PPU_Regional_Tier_Discount__c.getAll().get(countryName);
                if(tierDiscount == null)            
                    tierDiscount = PPU_Regional_Tier_Discount__c.getAll().get(regionName);
                if(tierDiscount != null){
                    String tierName = quote.BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c;
                    System.debug('NKC debug tierName ['+ tierName +']');
                    if(tierName == 'Gold')
                        dq.Partner_Tier_Discount__c = tierDiscount.Gold__c;
                    else if(tierName == 'Silver')
                        dq.Partner_Tier_Discount__c = tierDiscount.Silver__c;
                    else if(tierName == 'Bronze')
                        dq.Partner_Tier_Discount__c = tierDiscount.Bronze__c;              
                }       
                totalDiscount += (dq.Partner_Tier_Discount__c == null ? 0 : dq.Partner_Tier_Discount__c);    
                dq.Seat_Size_Discount__c = 0;
                dq.Seat_Discount_Range__c = '0 - 0%';
                System.debug('NKC debug quote.Max_Seat_Count__c  [' + quote.Max_Seat_Count__c + ']');
                if(quote.Max_Seat_Count__c != null){
                    List<String> allData = new List<String>(PPU_Size_Discount__c.getAll().keyset());
                    allData.sort();
                    for(String eachValue : allData){
                        PPU_Size_Discount__c eachSizeDiscount = PPU_Size_Discount__c.getAll().get(eachValue);
                        System.debug('NKC debug quote.Max_Seat_Count__c [' + quote.Max_Seat_Count__c + ']');
                        System.debug('NKC debug eachSizeDiscount.Seat__c [' + eachSizeDiscount.Seat__c + ']');
                        if(quote.Max_Seat_Count__c <= eachSizeDiscount.Seat__c){
                            dq.Seat_Size_Discount__c = eachSizeDiscount.Discount__c;    
                            dq.Seat_Discount_Range__c = eachSizeDiscount.Range__c;
                            break;
                        }
                    }                
                }
                dq.New_Logo_Discount__c = 0;
                dq.New_Logo_Discount_Range__c = '0 - 0%';
                if(quote.BigMachines__Opportunity__r.Type == 'New logo' && PPU_New_Logo_Discount__c.getAll().values().size() > 0){
                    PPU_New_Logo_Discount__c newLogoDiscount = PPU_New_Logo_Discount__c.getAll().values()[0];
                    dq.New_Logo_Discount__c = newLogoDiscount.Discount__c;
                    dq.New_Logo_Discount_Range__c = newLogoDiscount.Range__c;                    
                }
                totalDiscount += (dq.Seat_Size_Discount__c == null ? 0 : dq.Seat_Size_Discount__c);
                totalDiscount += (dq.New_Logo_Discount__c == null ? 0 : dq.New_Logo_Discount__c);
        }
        
        private void getRegionalDiscount(){
            regionalDiscount = 0;
            String regionName = quote.Sold_To_Name__r.Country__r.Region__c;
            String countryName = quote.Sold_To_Name__r.Country__r.Name;        
            PPU_Regional_Tier_Discount__c tierDiscount = PPU_Regional_Tier_Discount__c.getAll().get(regionName);
            System.debug('NKC debug regionName ['+ regionName +']');
            System.debug('NKC debug countryName ['+ countryName +']');
            System.debug('NKC debug tierDiscount ['+ tierDiscount +']');
            if(tierDiscount == null)            
                tierDiscount = PPU_Regional_Tier_Discount__c.getAll().get(countryName);
            System.debug('NKC debug tierDiscount ['+ tierDiscount +']');
            if(tierDiscount != null){
                String tierName = quote.Sold_To_Name__r.Partner_Tier__c;
                System.debug('NKC debug tierName ['+ tierName +']');
                if(tierName == 'Gold')
                    regionalDiscount = tierDiscount.Gold__c;
                else if(tierName == 'Silver')
                    regionalDiscount = tierDiscount.Silver__c;
                else if(tierName == 'Bronze')
                    regionalDiscount = tierDiscount.Silver__c;              
            }           
            
            System.debug('NKC debug regionalDiscount ['+ regionalDiscount +']');
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
            //fetchUpfrontApprovals();
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
                return (new PageReference('/apex/QuoteApprovalHistoryAndAttachments?id=' + quote.Id + '&retPage=CreateQuotePPU'));
            return null;    
        }
        
        public PageReference showProposalOptions()
        {
            objAttachment = new Attachment(ParentId = quote.Id);
            doCalculations();
            if(!blnHasError)
                return (new PageReference('/apex/ProposalOptions1?id=' + quote.Id + '&retPage=CreateQuotePPU'));
            return null;    
        }
        
        public PageReference showProposalOutputOptions()
        {
            objAttachment = new Attachment(ParentId = quote.Id);
            doCalculations();
            if(!blnHasError)
                return (new PageReference('/apex/ProposalOutputOptions?id=' + quote.Id  + '&retPage=CreateQuotePPU'));
            return null;    
        }
        
        
        /*public PageReference showProductConfiguration()
        {
            doCalculations();
            if(!blnHasError)
                return (new PageReference('/apex/ConfigurationControllerPPU?id=' + quote.Id));
            return null;    
        }*/
        
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
        
        public void changePricingModel()
        {
            /*Decimal decCurrentMultiplier = getPricingMultiplier(quote.Pricing_Model__c);
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {
                if(objQP.List_Price__c != null && objQP.List_Price__c != 0)
                    objQP.List_Price__c *=  (decCurrentMultiplier/decPricingMultiplier);
            }
            // Set Current Multiplier as Overall Multiplier
            decPricingMultiplier = decCurrentMultiplier;
            blnSkipPriceCheck = true;*/
            if(oldPricingModel == 'Branch Office'){
              List<BigMachines__Quote_Product__c> quoteProductBundles = [SELECT id FROM BigMachines__Quote_Product__c 
              WHERE BigMachines__Quote__c =: quote.id AND Bundle__r.Pricing_Model__c INCLUDES ('Branch Office')];
              if(!quoteProductBundles.isEmpty()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Pricing model can not be changed. Please remove branch office bundle in order to change pricing model.'));
                    blnHasError = true;
                    quote.Pricing_Model__c = oldPricingModel;
                    return;  
              }
            }
            oldPricingModel = quote.Pricing_Model__c;
            decPricingMultiplier = getPricingMultiplier(quote.Pricing_Model__c);
            System.debug('++++++++++  decPricingMultiplier'+ decPricingMultiplier);
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
                        
                        System.debug('b+++++ objQP.Unit_of_Measure__c ' +  objQP.Unit_of_Measure__c);
                        System.debug('b++++ quote.Pricing_Model__c ' +  quote.Pricing_Model__c);
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
                        
                        System.debug('a+++++ objQP.Unit_of_Measure__c ' +  objQP.Unit_of_Measure__c);
                        System.debug('a++++ quote.Pricing_Model__c ' +  quote.Pricing_Model__c);
                       /* else if(quote.Pricing_Model__c == 'Concurrent' && objQP.Unit_of_Measure__c.containsIgnoreCase('Named User'))
                            objQP.Unit_of_Measure__c = 'per seat';                    
                        else if(quote.Pricing_Model__c == 'Named User' && objQP.Unit_of_Measure__c.containsIgnoreCase('Concurrent'))
                            objQP.Unit_of_Measure__c = 'per seat';
                        else if(quote.Pricing_Model__c == 'Branch Office' && objQP.Unit_of_Measure__c.containsIgnoreCase('Branch Office'))
                          objQP.Unit_of_Measure__c = 'Branch Office Enabled Seat';  */
                        
                    }
                }
            }
        }
        
        private void checkDealViolations(String strOption){
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
        
        //public void dummyMethod(){}
        
        public void finalizeQuote(){   

            if(String.isBlank(quote.Order_Payment_Terms__c))
            {
                quote.Order_Payment_Terms__c.addError('Required To Submit Quote');
                return;
            }
            // Synchronizing Deal Qualification Products
            doCalculations(); 
            if(blnHasError)
              return;   
            if(list_QuoteProductRecords.size() == 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There should be at least 1 product added to the quote before it can be submitted for approval.'));
                return;
            }     
            DealQualificationAndQuoteApprovalHelper.sendPMApprovalNotifications(quote.id);            
            checkDealViolations('Finalize');
            strIsFinalize = 'true';
        }
        
        
        public void getDQStatus(){
          List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
          if(!dqs.isEmpty()){
            dqStatus = dqs[0].Status__c;
          }
        }
        public void synchAndGoToDQ(){
            System.debug('NKC debug SYNCH');
            
            DealQualificationAndQuoteApprovalHelper.synchDQ(quote.Id, quote.BigMachines__Opportunity__c);
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
                            if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                                decNonDiscountedListPrice += objQP.Ext_List__c;
                        }   
                    }
                    Decimal decTotalExcludingNonDiscounted = decGroupListPrice - decNonDiscountedListPrice;
                    if(objPG.Goal_Seek__c > decGroupListPrice)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Goal Seek Amount should be less than Total List Price applicable for discount for the Proposal Group. (' + String.valueOf(decGroupListPrice) + ')'));
                        return;
                    }
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
                            + ' - ' + (wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution__c == null ? '' : wrapperRecord.record.BigMachines__Product__r.Taxonomy_Solution__c);
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
            /*
            //Naresh : This validation is now moved in submit for approval logic.
            if(quote.Total_Discount__c != null && quote.Total_Discount__c != 0 &&
                String.isBlank(quote.Explanation_of_price_Discount_request__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''));
                return;
            }
            */
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
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
                    //quote.New_Price_Book__c = 'NG1_PPU_USD__c';
                    
                    if(objAccount.Id == quote.Sold_To_Name__c){
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
                delete list_ToDelete;
                getQuoteProducts(quote.id);
                doCalculations();
                //Naresh Kumar   01/04/2016  Updating SML Data
                SMLHelperWTS.updateSMLForAccount(quote.End_User_ID__c);
            }
            return newPageRef;
        }   
        
        //*** Handler/Method for delete quote product button ***
        /*public void addQuoteProduct()
        {
            Boolean blnHasRequiredError = false;
            if(objAddProductInput.Product_Search__c == null)
            {
                objAddProductInput.Product_Search__c.addError('Please Enter Value');
                blnHasRequiredError = true;
            }
            if(objAddProductInput.Quantity__c == null)
            {
                objAddProductInput.Quantity__c.addError('Please Enter Value');
                blnHasRequiredError = true;
            }
            if(blnHasRequiredError)
                return;
    
            if(String.isNotBlank(quote.New_Price_Book__c))
            {
                String strQuery = 'SELECT Id,Name,Description,Unit_of_Measure__c,Product_Specific_Discount__c,Third_Party__c,' 
                //+ quote.New_Price_Book__c + '_Price__c FROM Product2 WHERE Id = \'' + objAddProductInput.BigMachines__Product__c + '\'';
                + quote.New_Price_Book__c + '_Price__c FROM Product2 WHERE Id = \'' + objAddProductInput.Product_Search__c + '\'';
                List<Product2> list_SelectedProduct = Database.query(strQuery);
                if(list_SelectedProduct.size() > 0)
                {
                    Decimal decPrice = (Decimal) list_SelectedProduct[0].get(quote.New_Price_Book__c + '_Price__c');
                    if(decPrice == null)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No price defined for this product.'));
                        return;
                    }
                    objAddProductInput.Name = list_SelectedProduct[0].Name;
                    objAddProductInput.BigMachines__Product__c = objAddProductInput.Product_Search__c;
                    objAddProductInput.BigMachines__Description__c = list_SelectedProduct[0].Description;
                    objAddProductInput.BigMachines__Quote__c = quote.Id;
                    objAddProductInput.Unit_of_Measure__c = list_SelectedProduct[0].Unit_of_Measure__c;
                    objAddProductInput.BigMachines__Sales_Price__c = decPrice;
                    objAddProductInput.List_Price__c = decPrice;
                    objAddProductInput.PPU_PPU_Product_Specific_Discount__c = list_SelectedProduct[0].PPU_PPU_Product_Specific_Discount__c;
                    objAddProductInput.Third_Party__c = list_SelectedProduct[0].Third_Party__c;
                    try
                    {
                        insert objAddProductInput;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Line added to the quote.'));
                        getQuoteProducts(quote.Id);
                    }
                    catch(Exception ex)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                    }
                    objAddProductInput = new BigMachines__Quote_Product__c();
                }
                else
                {
                    objAddProductInput.BigMachines__Product__c.addError('Please select a valid product.');
                    return;
                }
            }
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Pricebook Info Not Available.'));      
        }*/
            
        // *** Clone button handler : To clone a Quote ***
        public pageReference cloneBtnHandler()
        {
            String cloneQuoteId = cloneQuote(false);            
            PageReference pg = new PageReference('/apex/CreateQuotePPU?id='+cloneQuoteId);
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
            /*if(quote.Sold_To_Name__c != null)
            {
                List<Account> list_Temp = [SELECT Name,Country__r.New_Price_Book__c FROM Account WHERE Id = :quote.Sold_To_Name__c];
                if(list_Temp.size() > 0)
                {
                    if(quote.New_Price_Book__c == list_Temp[0].Country__r.New_Price_Book__c)
                    {
                        idSoldToAccount = quote.Sold_To_Name__c;
                        return;
                    }
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot change \'Sold To\' to ' + list_Temp[0].Name + ' as the pricebook applicable is different. Please create a new quote if needed.'));
                }
            }
            quote.Sold_To_Name__c = idSoldToAccount;*/
            if(quote.Sold_To_Name__c != null && idSoldToAccount != quote.Sold_To_Name__c){      
                    quote.Sold_To_Address__c = '';
                            quote.Sold_To_City__c = '';
                            quote.Sold_To_State__c = '';
                            quote.Sold_To_Country__c   = '';
                            quote.Sold_To_Zip_Code__c = '';
            }
        }
        
        /*// *** Revise button handler : To revise a Quote ***
        public void reviseBtnHandler()
        {
            if(quote.BigMachines__Status__c == 'Quote Approval Pending')
            {
                // Recall existing approval requests
            }
            //quote.BigMachines__Status__c = 'Quote In Progress';
            quote.BigMachines__Status__c = 'Revision Pending';
            // Clearing Approval Information
            quote.Approval_Submission_Date__c = null;
            quote.Approval_Date__c = null;
            update quote;
        }*/
        
        // *** Revise Major button handler : To revise a Quote (Creates a new quote with a different revision number)***
        public pageReference reviseMajorBtnHandler()
        {
            PageReference pg;
            if(quote.BigMachines__Status__c == 'Quote Approved'){
            String newQuoteId = cloneQuote(true);
            pg = new PageReference('/apex/CreateQuotePPU?id='+newQuoteId);
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
                pg = new PageReference('/apex/CreateQuotePPU?id='+quote.id);
                
                
            }
             
            if(strSelectedTab == 'Quote Approvals')
                approvals = fetchApprovals();   
            
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
        
        // Action method which is called from page as it loads to clone the quote
        public pageReference cloneQuoteOnLoad(){
            if(ApexPages.currentPage().getParameters().get('clone') != null
                && ApexPages.currentPage().getParameters().get('clone') == '1'){
                String clonedQuoteId = cloneQuote(false);
                PageReference pRef = new PageReference('/apex/CreateQuotePPU?id=' + clonedQuoteId);
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
            quoteCopy.Order_Type__c = 'Revenue';
            
            // Quote Account should map to End User (explicitly copied : if cloned from a quote which has a blank value for account)
            quoteCopy.BigMachines__Account__c = quote.End_User_ID__c;
            
            insert quoteCopy;
            System.debug('<<<< clone : ' + quoteCopy.Maintenance_End_Date__c);
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
            
            List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFieldsOnPremise.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQuoteProductsQuery += field.getFieldPath() + ', ';
            
            strQuoteProductsQuery += 'Id,APN_Number__c';
            strQuoteProductsQuery += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quote.Id + '\'';
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
                    list_QPsToUpdate.add(eachQP);
                }
            }
            if(list_QPsToUpdate.size() > 0)
                update list_QPsToUpdate;
                
            insert list_ProposalGroupsCopy;
    
            return quoteCopy.id;
        }
        
        // *** Method to return quote object ***
        public BigMachines__Quote__c getQuote(Id quoteId)
        {
            BigMachines__Quote__c quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));
            
            if(String.isBlank(quote.Grid_Group_By__c))
                quote.Grid_Group_By__c = 'Categories';
                
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
            
                    strQuoteQuery += 'End_User_ID__r.Country__r.Name, Initial_Subscription_Term__c, End_User_ID__r.Partner_Tier__c, Quote_Cloned_Revised__r.Name,BigMachines__Opportunity__r.Country_Sub_Region__c,Sold_To_Name__r.Country__r.PSRDP_Region__c,PPU_Rental__c,BigMachines__Opportunity__r.Type,';     
            strQuoteQuery += 'BigMachines__Opportunity__r.Direct_Sales__c,BigMachines__Opportunity__r.Country_Region__c,Sold_To_Name__r.Country__r.Name,Deal_Qualification__c,BigMachines__Opportunity__r.Country__c,BigMachines__Opportunity__r.Country__r.Name,';
            strQuoteQuery += 'BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country_DAP__c, BigMachines__Opportunity__r.New_DAP_Region__c, X3rd_Party_Override__c,Sold_To_Name__r.Partner_Tier__c,';
            strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c, Override_Training_Unit__c, Pass_Through__c,No_Of_Months__c,CMRR__c,Annual_Contract_Value__c,Cloud_Total__c,Sold_To_Name__r.Country__r.Region__c,Order_Fulfillment_Email_Receipt__c,';
            strQuoteQuery += 'Ship_To_Name__c, Ship_To_Name__r.SAP_Account_Code__c, Shipping_Contact__c, Shipping_Contact_Phone_Number__c, Shipping_Instructions__c, Shipping_Contact_Email__c,Delivery_Method__c,BigMachines__Opportunity__r.Partner_Opportunity_Source__c, BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,';
            strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name,BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,BigMachines__Opportunity__r.Term_Commitment__c,Opp_Sold_To_Country__c,CMRR_Pre_Discount__c,ACV_Pre_Discount__c,TCV_Pre_Discount__c,Max_Seat_Count__c,';
            strQuoteQuery += 'Support_Owner__c, Comment__c, BigMachines__Opportunity__r.Account.Partner_Tier__c, Require_Separate_Quote_for_Genesys_Care__c, Top_Play__c, Offer__c FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
            return strQuoteQuery;
        }
            
        // *** Method to get Quote Products ***
        public void getQuoteProducts(Id quoteId)
        {
            list_QuoteProductRecords = new List<BigMachines__Quote_Product__c>();
            list_BundleItemQPRecords = new List<BigMachines__Quote_Product__c>();
            list_QuoteProducts = new List<QuoteProductWrapper>();
            list_GroupHeaders = new List<String>();
            objServiceLevel = null;
            objThirdPartyGCLine = null;
            blnHasHWLines = blnHasBundles = blnHasRDP = blnHasEMEAVolDisc = false;        
            map_BundleQuoteProducts = new Map<Id,BigMachines__Quote_Product__c>();
            List<CurrencyType> currentCurrency = [SELECT ConversionRate FROM CurrencyType WHERE ISOCode =: quote.currencyIsoCode];
            for(BigMachines__Quote_Product__c eachQuoteProduct : (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId)))
            {           
                if(eachQuoteProduct.BigMachines__Product__r.Third_Party__c == null || eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toUpperCase() != 'TRUE'){
                    if(eachQuoteProduct.Product_Specific_Discount__c != null && eachQuoteProduct.Product_Specific_Discount__c < regionalDiscount)
                        eachQuoteProduct.Mandatory_Discount__c = eachQuoteProduct.Product_Specific_Discount__c;
                    else    
                        eachQuoteProduct.Mandatory_Discount__c = regionalDiscount + (dq.Deal_Registration_Discount__c == null ? 0 : dq.Deal_Registration_Discount__c);
                }
                if(quote.No_Of_Months__c != null && quote.No_Of_Months__c < 12)
                    eachQuoteProduct.Mandatory_Discount__c = 0;
                eachQuoteProduct.currencyIsoCode = quote.currencyIsoCode;
                if(eachQuoteProduct.BigMachines__Product__r.Third_Party__c == null || eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toUpperCase() == 'TRUE'){
                    eachQuoteProduct.NG1_PPU_Gold_USD__c = eachQuoteProduct.BigMachines__Product__r.NG1_PPU_Gold_USD__c;
                    if(!currentCurrency.isEmpty() && eachQuoteProduct.NG1_PPU_Gold_USD__c != null){                    
                         eachQuoteProduct.NG1_PPU_Gold_USD__c =  eachQuoteProduct.NG1_PPU_Gold_USD__c * currentCurrency[0].ConversionRate;
                    }
                }
                /*
                if(eachQuoteProduct.Is_Training_Unit__c){
                    objTrainingUnit = eachQuoteProduct;
                }
                
                if(!eachQuoteProduct.TU_System_Added__c && eachQuoteProduct.BigMachines__Product__c != null && String.valueOf(eachQuoteProduct.BigMachines__Product__c).contains(Label.Training_Unit_Product_Id)){
                    objTrainingUnit = eachQuoteProduct;
                    //eachQuoteProduct.Is_Training_Unit__c = true;
                    //quote.Override_Training_Unit__c = true; 
                }
                */           
                if(eachQuoteProduct.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                {
                    blnHasRDP = true;
                    // Initializing T&E PS RDP to 20%
                    if(quote.Time_Expense_PS_RDP__c == null)
                        quote.Time_Expense_PS_RDP__c = 20;
                }
                
                if(eachQuoteProduct.BigMachines__Product__r.Genesys_Care_Quote__c)
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
                
                else if(eachQuoteProduct.Bundle_Line__c != null){
                    if(eachQuoteProduct.Bundle__r.Group_Type__c == 'Use Case'){
                        QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
                        wrapperRecord.record = eachQuoteProduct;
                        list_QuoteProducts.add(wrapperRecord);
                        list_QuoteProductRecords.add(eachQuoteProduct);//Added by Priyank in 1 May 2019
                    }else{
                        list_BundleItemQPRecords.add(eachQuoteProduct);
                    }
                    if(eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Product_System_License_Product_Type)
                        blnHasHWLines = true;
                    /*
                    list_BundleItemQPRecords.add(eachQuoteProduct);
                    if(eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || eachQuoteProduct.BigMachines__Product__r.Type__c == Label.Product_System_License_Product_Type)
                        blnHasHWLines = true;
                    */
                }
                else if(eachQuoteProduct.BigMachines__Product__c != null 
                    && String.valueOf(eachQuoteProduct.BigMachines__Product__c).left(15) == Label.CreateQuoteOnPremise_Shipping_Handling_Product_Id.left(15)){
                    objShippingAndHandling = eachQuoteProduct;
                }
                /*
                else if(eachQuoteProduct.BigMachines__Product__c != null 
                    && String.valueOf(eachQuoteProduct.BigMachines__Product__c).left(15) == Label.CreateQuoteOnPremise_Prepaid_Professional_Services_Product_Id.left(15)){
                    objProfessionalServices = eachQuoteProduct;                
                } 
                */
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
        }
        
        // *** Method to generate query string to query Quote Products from the DB ***
        public String prepareQuoteProductQuery(Id quoteId)
        {
            String strQueryAllFields = 'SELECT ';
            //Getting all the fields from a field set : field set used to make system more configurable 
            List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFieldsOnPremise.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQueryAllFields += field.getFieldPath() + ', ';
            
            strQueryAllFields += 'Id,Bundle__r.Group_Type__c,Bundle__r.Message__c,Bundle__r.Description__c,Bundle__r.Discount__c,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Flavors_Available__c,BigMachines__Quote__c,BigMachines__Product__r.NG1_PPU_USD__c';
            strQueryAllFields += ',BigMachines__Product__r.Pricing_Model__c,BigMachines__Product__r.Genesys_Care_Quote__c,BigMachines__Product__r.Shipment_Approval__c,Is_Training_Unit__c,GC_Ext_Net_Price__c,Mandatory_Discount__c';
            strQueryAllFields += ',BigMachines__Product__r.Care_Rate_Applicable_Licensing__c,BigMachines__Product__r.Type__c,Bundle__r.Name, BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Name,Original_Third_Party_GC__c,BigMachines__Product__r.Shipping_Cost__c';
            strQueryAllFields += ',BigMachines__Product__r.Taxonomy_Solution_Category__c,BigMachines__Product__r.Taxonomy_Solution__c,BigMachines__Product__r.NG1_PPU_Silver_USD__c,BigMachines__Product__r.NG1_PPU_Gold_USD__c';
            /*if(blnIsNewPricing)
                strQueryAllFields += ',BigMachines__Product__r.New_Category__c';
            else
            {
                strQueryAllFields += ',BigMachines__Product__r.Tab__c,BigMachines__Product__r.Section__c';
                
                if(quote.New_Price_Book__c != null && quote.New_Price_Book__c.containsIgnoreCase('EMEA'))
                    strQueryAllFields += ',BigMachines__Product__r.EMEA_Volume_Discount_Eligible__c,EMEA_Volume_Discount__c';
            }*/
            strQueryAllFields += ',BigMachines__Product__r.New_Category__c';
            
            if(!blnIsNewPricing && quote.New_Price_Book__c != null && quote.New_Price_Book__c.containsIgnoreCase('EMEA'))
                strQueryAllFields += ',BigMachines__Product__r.EMEA_Volume_Discount_Eligible__c,EMEA_Volume_Discount__c';
            
            strQueryAllFields += ',BigMachines__Product__r.' + quote.New_Price_Book__c + '_Price__c';
            strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\' AND Hide_Record__c = false';
            
            if(quote.Grid_Group_By__c == 'Categories')
            {
                /*if(blnIsNewPricing)
                    strQueryAllFields += ' ORDER BY BigMachines__Product__r.New_Category__c ASC NULLS LAST,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Anchor_Product__c,Product_Description__c';
                else
                    strQueryAllFields += ' ORDER BY BigMachines__Product__r.Tab__c ASC NULLS LAST,BigMachines__Product__r.Section__c,Product_Description__c';*/
            
                strQueryAllFields += ' ORDER BY BigMachines__Product__r.New_Category__c ASC NULLS LAST,BigMachines__Product__r.Building_Block__c,BigMachines__Product__r.Anchor_Product__c,Product_Description__c';
            }
            else if(quote.Grid_Group_By__c == 'Bundles/Products')
                strQueryAllFields += ' ORDER BY Bundle__c NULLS LAST,Bundle__r.Name,Product_Description__c';
            else if(quote.Grid_Group_By__c == 'Proposal Groups')
                strQueryAllFields += ' ORDER BY Group_Number__c NULLS LAST,Product_Description__c';
            else
                strQueryAllFields += ' ORDER BY Third_Party__c NULLS FIRST,Product_Description__c';
                
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
        public void goalSeekBtnHandler()
        {
            if(quote.Goal_Seek__c == null)
            {
                quote.Goal_Seek__c.addError('Please Enter Value');
                return;
            }
            // Calculating Total Net with only Bundle and Proposal Group Discount respectively factored in
            Decimal decTotalNetAfterGroupAndBundleDiscount = 0,decTotalListPrice = 0;
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {   
                if(objQP.Ext_List__c != null && objQP.Ext_List__c != 0)
                {
                    Decimal listPrice = objQP.List_Price__c;
                    Decimal extListPrice = objQP.Ext_List__c;                    
                    
                    if(objQP.Mandatory_Discount__c != null && objQP.Mandatory_Discount__c != 0){
                        listPrice -= (objQP.List_Price__c * objQP.Mandatory_Discount__c) / 100;
                        extListPrice = listPrice * objQP.Quantity__c;
                    }
                    
                    if(objQP.BigMachines__Product__r.Building_Block__c != 'PS Rapid Deployment Packages')
                        decTotalListPrice += extListPrice;
                        
                    decTotalNetAfterGroupAndBundleDiscount += extListPrice;
                    // Proposal Group Discount
                    if(String.isNotBlank(objQP.Group_Number__c) && 
                        map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) && 
                        map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c != null)
                    {
                        decTotalNetAfterGroupAndBundleDiscount -= (extListPrice * map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c/100);
                    }
                    // Bundle Discount
                    if(objQP.Bundle__c != null && objQP.Bundle_Discount__c != null && objQP.Bundle_Discount__c != 0)
                        decTotalNetAfterGroupAndBundleDiscount -= (extListPrice * objQP.Bundle_Discount__c/100);
                }
            }
            Decimal noOfMonths = quote.No_Of_Months__c > 12 ? 12 : quote.No_Of_Months__c;
            Decimal goalSeek = quote.Goal_Seek__c/ noOfMonths;
            System.debug('NKC debug quote.Annual_Contract_Value__c ['+quote.Annual_Contract_Value__c+']');
            System.debug('NKC debug goalSeek ['+goalSeek+']');
            System.debug('NKC debug decTotalNetAfterGroupAndBundleDiscount ['+decTotalNetAfterGroupAndBundleDiscount+']');
            if(goalSeek > decTotalNetAfterGroupAndBundleDiscount){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Goal Seek Amount should be less than Total List Price Less Bundle and Proposal Group Discounts.'));
                return;
            }
            if(decTotalListPrice != 0){
                System.debug('NKC debug decTotalNetAfterGroupAndBundleDiscount ['+decTotalNetAfterGroupAndBundleDiscount+']');
                Decimal decComputedDiscountPercent = ((decTotalNetAfterGroupAndBundleDiscount - goalSeek)/decTotalListPrice) * 100;
                System.debug('NKC debug decComputedDiscountPercent ['+decComputedDiscountPercent+']');
                quote.Adjustment__c = 0;
                Decimal decDiscountToAdjust = 0,decListPriceOfItemsToIncrease = 0;
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {
                    if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                        continue;
                    
                    objQP.Adjustment__c = 0;
                    objQP.or_Amount__c = 'Amt';
                                    
                    if(objQP.List_Price__c != null && objQP.Ext_List__c != null)
                    {
                        Decimal listPrice = objQP.List_Price__c;
                        Decimal extListPrice = objQP.Ext_List__c;
                        
                        if(objQP.Mandatory_Discount__c != null && objQP.Mandatory_Discount__c != 0){
                            listPrice -= (objQP.List_Price__c * objQP.Mandatory_Discount__c) / 100;
                            extListPrice = listPrice * objQP.Quantity__c;
                        }
                                              
                        System.debug('NKC debug listPrice ['+listPrice+']');
                        System.debug('NKC debug extListPrice ['+extListPrice+']');
                        
                        // Checking for product specific discount limit
                        if(objQP.Product_Specific_Discount__c != null && objQP.Product_Specific_Discount__c < decComputedDiscountPercent)
                        {
                            objQP.Disc__c = objQP.Product_Specific_Discount__c;
                            objQP.or_Amount__c = '%';
                            decDiscountToAdjust += (extListPrice * (decComputedDiscountPercent - objQP.Product_Specific_Discount__c)/100);
                            System.debug('NKC debug decDiscountToAdjust [' + decDiscountToAdjust + ']');
                        }
                        else 
                        {
                            decListPriceOfItemsToIncrease += extListPrice;
                            objQP.Disc__c = (listPrice * decComputedDiscountPercent/100);
                            System.debug('NKC debug objQP.Disc__c [' + objQP.Disc__c + ']');
                        }
                    }
                    
                       //Added by Ankit for Avaya on 11/12
                    if(objQP.Ext_List__c != null && objQP.Bundle__r.Group_Type__c == 'Campaigns' && objQP.Product_Description__c == 'Campaign')
                      {
                        Decimal listPrice = objQP.List_Price__c;
                        Decimal extListPrice = objQP.Ext_List__c;
                        if(objQP.Mandatory_Discount__c != null && objQP.Mandatory_Discount__c != 0){
                            listPrice -= (objQP.List_Price__c * objQP.Mandatory_Discount__c) / 100;
                            extListPrice = listPrice * objQP.Quantity__c;
                        }
                        // Checking for product specific discount limit
                        if(objQP.Product_Specific_Discount__c != null && objQP.Product_Specific_Discount__c < decComputedDiscountPercent)
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
                    }
                    
                }
                
                System.debug('NKC debug decDiscountToAdjust [' + decDiscountToAdjust + ']');
                System.debug('NKC debug decListPriceOfItemsToIncrease [' + decListPriceOfItemsToIncrease + ']');
                
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
                        
                        if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages' ||
                            (objQP.Product_Specific_Discount__c != null && objQP.Product_Specific_Discount__c < decComputedDiscountPercent))
                            continue;
                        
                        Decimal listPrice = objQP.List_Price__c;
                        Decimal extListPrice = objQP.Ext_List__c;
                        
                        if(objQP.Mandatory_Discount__c != null && objQP.Mandatory_Discount__c != 0 && objQP.List_Price__c != null){
                            listPrice -= (objQP.List_Price__c * objQP.Mandatory_Discount__c) / 100;
                            extListPrice = listPrice * objQP.Quantity__c;
                        }
                        
                        if(listPrice != null)
                            objQP.Disc__c += (listPrice * decDiscountPercentToAdjust/100);
                        else {
                            if(extListPrice != null && objQP.Bundle__r.Group_Type__c == 'Campaigns' && objQP.Product_Description__c == 'Campaign')
                                objQP.Disc__c += (extListPrice * decDiscountPercentToAdjust/100);
                        }
                        System.debug('NKC debug objQP.Disc__c [' + objQP.Disc__c + ']');
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
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {
                if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                    continue;
                Decimal mandatoryDiscount = objQP.Mandatory_Discount__c == null ? 0 : objQP.Mandatory_Discount__c;
                Decimal mandatoryAndAdjustmentDiscount = mandatoryDiscount + (quote.Adjustment__c == null ? 0 : quote.Adjustment__c);
                // Adjustment cannot exceed Product Specific Discount for any product
                if(objQP.Product_Specific_Discount__c != null && mandatoryAndAdjustmentDiscount > objQP.Product_Specific_Discount__c)
                    objQP.Adjustment__c = 0;
                else{
                    if(quote.Adjustment__c > mandatoryDiscount)
                        objQP.Adjustment__c = quote.Adjustment__c - mandatoryDiscount;
                    else
                        objQP.Adjustment__c = 0;
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
        
        // *** Method to create/delete Third Party GC Line ***
        private void processThirdPartyGCLine()
        {
            if(!blnHasHWLines && objThirdPartyGCLine != null && objThirdPartyGCLine.Id != null)
            {
                delete objThirdPartyGCLine;
                objThirdPartyGCLine = null;
            }
            else if(blnHasHWLines && objThirdPartyGCLine == null)
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
            System.debug('$$$$$$' + objQP.BigMachines__Product__r.Type__c);
            
            if(objQP.Ext_Net_Price__c != null)
                totalAmount += objQP.Ext_Net_Price__c;
            
            if(objQP.Quantity__c != null && objQP.Quantity__c > maxSeatCount)
                maxSeatCount = Integer.valueOf(objQP.Quantity__c); 
                
            if(objQP.Ext_List__c != null)
                CMRRPreDiscount += objQP.Ext_List__c;
            // Software
            if(objQP.BigMachines__Product__r.Type__c == 'Product')
            {
                if(objQP.Ext_List__c != null)
                    quote.Total_Software__c += objQP.Ext_List__c;
                if(objQP.Ext_Net_Price__c != null)
                    decTotalSWNetPrice += objQP.Ext_Net_Price__c;
            }
            
            // Hardware
            else if(objQP.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || objQP.BigMachines__Product__r.Type__c  == Label.Product_System_License_Product_Type)
            {
                System.debug('### ' + objQP.BigMachines__Product__c);
               // if(objQP.Ext_List__c != null)
                   // quote.Total_Hardware__c += objQP.Ext_List__c;
                if(objQP.Ext_Net_Price__c != null)
                    decTotalHWNetPrice += objQP.Ext_Net_Price__c;
                  quote.Total_Hardware__c += objQP.Ext_Net_Price__c;// Added by navaneetha on hardware total  04-Sep-2019.
                  
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
            if(String.isBlank(quote.Order_PO_Number__c))
            {
                quote.Order_PO_Number__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
            if(quote.Order_PO_Date__c == null)
            {
                quote.Order_PO_Date__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
            if(String.isBlank(quote.PO_for_FYM__c))
            {
                quote.PO_for_FYM__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
            /*if(String.isBlank(quote.Order_Payment_Terms__c))
            {
                quote.Order_Payment_Terms__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }*/
            if(String.isBlank(quote.Order_Ship_Software_Via__c))
            {
                quote.Order_Ship_Software_Via__c.addError('Required To Submit Order');
                blnHasRequiredError = true;
            }
            if(String.isBlank(quote.Server_OS__c) || String.isBlank(quote.PBX__c) || String.isBlank(quote.Database__c)
                || String.isBlank(quote.IVR__c) || String.isBlank(quote.Add_Language__c))
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
            if(!blnIsAttachmentUploaded && ([SELECT count() FROM Attachment WHERE ParentId = :quote.Id] == 0))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There are no attachments on this quote. Please attach PO before submitting order.'));
                return;
            }
            //Naresh Kumar  03/07/2016        
            if([SELECT count() FROM Account_Order_Address__c WHERE Quote__c  =: quote.id AND Address_Type__c = 'Ship To' AND Email__c != null] == 0){
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Pleast enter email for the Ship To address.'));
                return;
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
                //Getting overall status
                /*
                if(overAllStatus != QuoteApprovalUtil.STATUS_REJECTED && newRecord.approvalRecord.Status__c == QuoteApprovalUtil.STATUS_PENDING
                    && newRecord.approvalRecord.Approval_Submission_Counter__c == submissionCounter)
                    overAllStatus = QuoteApprovalUtil.STATUS_PENDING;
                if(newRecord.approvalRecord.Status__c == QuoteApprovalUtil.STATUS_REJECTED 
                    && newRecord.approvalRecord.Approval_Submission_Counter__c == submissionCounter)
                    overAllStatus = QuoteApprovalUtil.STATUS_REJECTED;
                */  
                System.debug('NKC debug counter ['+counter+']');
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
            String strCareRateApplicable;
            
            if(quote.Genesys_Care_Default_Pricing_Percentage__c != null && quote.Genesys_Care_Rate__c == null)
                quote.Genesys_Care_Rate__c = quote.Genesys_Care_Default_Pricing_Percentage__c;
            
            if((quote.Duration_Unit__c == 'Months' || String.isBlank(quote.Duration_Unit__c))
                && quote.Order_Numb_of_Maint_Months__c == null)
                quote.Order_Numb_of_Maint_Months__c = 12;
            
            if(String.isBlank(quote.Service_Level__c))
                quote.Service_Level__c = 'Business';    
                
            if(quote.Service_Level__c != 'Decline')
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
                    System.debug('<<< ' + strGCProdName);
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
                        /*
                        // Get FYM Rate from Sold to account if it's there
                        if(quote.Sold_To_Name__c != null ){
                          objAccount = [SELECT FYM_Rate__c FROM Account WHERE id =: quote.Sold_To_Name__c];
                        }
                        */
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
        
        public void saveGC()
        {
            if(quote.Service_Level__c != 'Decline')
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
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
            
            blnHasError = false;
            // ****************** Validations *****************************
            /*if(String.isNotBlank(quote.Special_Offer_Terms__c) && !quote.Include_Special_Offer_in_Output__c)
            {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select Include Special Offer in Output checkbox to proceed.' ) );
                blnHasError = true;
                return null;
            }*/
            // Cannot mix concurrent with non-concurrent products in any one group
            // Cannot have Non 'Named User Pricing' products on a 'Named User Pricing' quote.
            //Map<String,String> map_GroupNumToPricingModel = new Map<String,String>();
            Integer intIndex = 0,intNumberOfPSRDP = 0;
            Set<Id> set_ProductIds = new Set<Id>();
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {
                intIndex++;
                //ADded by Ankit on 10/1
                objQP.Line_Number__c = intIndex;
                set_ProductIds.add(objQP.BigMachines__Product__c);
                // Skip the check for Bundle Header Lines
                if(objQP.Bundle__c != null)
                    continue;
                
                // Validation for zero quantity
                if(objQP.Quantity__c == null || objQP.Quantity__c < 1){
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please make sure the quantity is one or more for the product line \"' + objQP.Product_Description__c + '\".'));
                    blnHasError = true;
                    return null;
                }   
                if(String.isNotBlank(objQP.BigMachines__Product__r.Flavors_Available__c) && String.isBlank(objQP.Flavor__c))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Flavor for the product where ever applicable.'));
                    blnHasError = true;
                    return null;
                }
                
                // Software
                if(blnHasRDP && objQP.BigMachines__Product__r.Type__c == 'Product' && 
                    objQP.Quantity__c > 300 && 
                    objQP.Unit_of_Measure__c != null && objQP.Unit_of_Measure__c.containsIgnoreCase('seat'))
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact your Regional PS Services Engagement Manager to quote opportunities with more than 300 seats.'));
                    blnHasError = true;
                    return null;
                }
                    
                if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                {   
                    intNumberOfPSRDP++;
                    if(objQP.Disc__c != null && objQP.Disc__c != 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'For RDP discounting, contact your Professional Services SEM for assistance.'));
                        blnHasError = true;
                        return null;
                    }
                    if(objQP.Quantity__c != 1)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A single quantity of each package type should be selected. For any additional requirements please contact your Regional PS Services Engagement Manager.'));
                        blnHasError = true;
                        return null;
                    }
                }
                //Reset GC Override if needed
                if(!quote.X3rd_Party_Override__c && objQP.Original_Third_Party_GC__c != null){
                  objQP.Third_Party_GC__c = objQP.Original_Third_Party_GC__c;
                }
                
                /*if(String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) &&
                    String.isNotBlank(objQP.BigMachines__Product__r.Pricing_Model__c))
                {
                    if(map_GroupNumToPricingModel.containsKey(objQP.Group_Number__c) &&
                        objQP.BigMachines__Product__r.Pricing_Model__c != map_GroupNumToPricingModel.get(objQP.Group_Number__c))
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,objQP.Group_Number__c + ' : Cannot mix concurrent with non-concurrent products in a group.'));
                        blnHasError = true;
                        return null;
                    }
                    else
                        map_GroupNumToPricingModel.put(objQP.Group_Number__c,objQP.BigMachines__Product__r.Pricing_Model__c);
                }*/
                
                /*if(quote.Pricing_Model__c == 'Named User Pricing' && objQP.BigMachines__Product__r.Pricing_Model__c != 'Named User Pricing')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot have Non Named User Pricing products on a Named User Pricing Quote.'));
                    blnHasError = true;
                    return null;
                }*/           
            }
            if(intNumberOfPSRDP > 3)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'PS Rapid Deployment Packages limited to three per quote. Please remove the extra PS Rapid Deployment Packages from the quote. (Currently : ' + String.valueOf(intNumberOfPSRDP) + ')'));
                blnHasError = true;
                return null;
            }
            List<CurrencyType> currentCurrency = [SELECT ConversionRate FROM CurrencyType WHERE ISOCode =: quote.currencyIsoCode];
            // Storing all product ids of products associated with quote products in a set
            
            // Checking if prices have been updated
            if(!blnSkipPriceCheck && String.isNotBlank(quote.New_Price_Book__c))
            {
                Boolean blnHasPriceUpdate = false;
                for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
                {
                    // Skip the check for Bundle Header Lines
                    //if(objQP.Bundle__c != null)
                    //    continue;
                    set_ProductIds.add(objQP.BigMachines__Product__c);
                    Decimal decProductPrice;
                    /*
                    if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                        String.isNotBlank(quote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                    {
                        PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(quote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objQP.BigMachines__Product__c);
                        if(objPriceSettings != null)
                            decProductPrice = objPriceSettings.Price__c;
                    }
                    else
                    */
                    String priceBookFieldName = 'NG1_PPU_USD__c';  
                    String tierName = quote.BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c;
                    System.debug('NKC debug tierName ['+ tierName +']');
                    
                    if(tierName == 'Gold')
                        priceBookFieldName = 'NG1_PPU_Gold_USD__c';
                    else if(tierName == 'Silver')
                        priceBookFieldName = 'NG1_PPU_Silver_USD__c';
                    
                    if(objQP.BigMachines__Product__r.Third_Party__c != null && objQP.BigMachines__Product__r.Third_Party__c.toUpperCase() == 'TRUE')
                        decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get(priceBookFieldName);
                    else
                        decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get('NG1_PPU_USD__c');
                    System.debug('NKC debug decProductPrice [' + decProductPrice + ']');
                    if(decProductPrice == null)
                        continue;
                    //decProductPrice *= decPricingMultiplier;
                    if(String.isNotBlank(objQP.Build_Type__c))
                    {
                        AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objQP.Build_Type__c + String.valueOf(objQP.Quantity__c.intValue()));
                        System.debug('<<< ' + objAudioCodeSettings);
                        if(objAudioCodeSettings != null)
                            decProductPrice *= objAudioCodeSettings.Volume_Break_Multiplier__c;
                    }
                    System.debug('+++ quote.Pricing_Model__c' + quote.Pricing_Model__c);
                    System.debug('+++ objQP.BigMachines__Product__r.Pricing_Model__c' + objQP.BigMachines__Product__r.Pricing_Model__c);
                    System.debug('+++ decPricingMultiplier ' + decPricingMultiplier);
                    System.debug('+++ decProductPrice ' + decProductPrice);
                    if(quote.Pricing_Model__c != null && quote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objQP.BigMachines__Product__r.Pricing_Model__c)
                            && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase(quote.Pricing_Model__c))
                        decProductPrice *= decPricingMultiplier;
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
                    decProductPrice = ConfigurationControllerPPU.convertAndUpdatePrice(decProductPrice, quote, product, currentCurrency);
                    System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                    System.debug('NKC debug objQP.List_Price__c ['+objQP.List_Price__c+']');
    
                    if(objQP.List_Price__c != decProductPrice)// && !objQP.Is_Training_Unit__c)
                    {
                      
                        blnHasPriceUpdate = true;
                        objQP.List_Price__c = decProductPrice;
                        String strProdName = objQP.Product_Description__c != null ? objQP.Product_Description__c : objQP.Name;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,strProdName + ' price has been updated to ' + decProductPrice));
                    }
                }
                Set<Id> set_PriceUpdatedBundles = new Set<Id>();
                for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
                {   
                    System.debug('<<<< ' + objQP.Id +'<<<<'+objQP.Bundle__r.Discount__c);
                    Decimal decProductPrice;
                    if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                        String.isNotBlank(quote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                    {
                        PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(quote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objQP.BigMachines__Product__c);
                        if(objPriceSettings != null)
                            decProductPrice = objPriceSettings.Price__c;
                    }
                    else            
                        decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get(quote.New_Price_Book__c + '_Price__c');
                        
                    if(decProductPrice == null)
                        continue;
                    
                    objQP.List_Price__c = objQP.List_Price__c != null ? objQP.List_Price__c : 0;
                    System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                    if(quote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objQP.BigMachines__Product__r.Pricing_Model__c)
                            && objQP.BigMachines__Product__r.Pricing_Model__c.containsIgnoreCase(quote.Pricing_Model__c))
                        decProductPrice *= decPricingMultiplier;
                    System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                    if(objQP.Bundle__r.Group_Type__c == 'Campaigns' && objQP.Bundle__r.Discount__c!=null){
                      System.debug('<<<< inside' + decProductPrice +'<<<<'+objQP.Bundle__r.Discount__c);
                        decProductPrice -= decProductPrice*(objQP.Bundle__r.Discount__c/100);//objQP.Bundle__r.Discount__c;
                        System.debug('<<<< after inside' + decProductPrice);
                    }
                    Product2 product = new Product2(Type__c = objQP.BigMachines__Product__r.Type__c, Third_Party__c = objQP.BigMachines__Product__r.Third_Party__c);
                    decProductPrice = ConfigurationControllerPPU.convertAndUpdatePrice(decProductPrice, quote, product, currentCurrency);
                    System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                    System.debug('NKC debug objQP.List_Price__c ['+objQP.List_Price__c+']');    
                    if(objQP.List_Price__c != decProductPrice )//&& objQP.Bundle__r.Group_Type__c <> 'Campaigns'
                    {
                        
                        blnHasPriceUpdate = true;
                        BigMachines__Quote_Product__c objBundleQP = map_BundleQuoteProducts.get(objQP.Bundle_Line__c);
                        System.debug('<<<< ' + objBundleQP);
                        System.debug('<<<< ' + objQP.List_Price__c);
                        System.debug('<<<< ' + decProductPrice);
                        
                        objBundleQP.List_Price__c = objBundleQP.List_Price__c != null ? objBundleQP.List_Price__c : 0;
                        //objBundleQP.List_Price__c += (decProductPrice - objQP.List_Price__c) * (objQP.Committed_Quantity__c != null ? objQP.Committed_Quantity__c : 1);
                        objQP.List_Price__c = decProductPrice;
                        System.debug('NKC debug decProductPrice ['+decProductPrice+']');
                        System.debug('NKC debug objBundleQP.List_Price__c ['+objBundleQP.List_Price__c+']');
                        set_PriceUpdatedBundles.add(objQP.Bundle_Line__c);
                    }
                }
                for(Id idQP:set_PriceUpdatedBundles)
                {
                    BigMachines__Quote_Product__c objBundleQP = map_BundleQuoteProducts.get(idQP);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,objBundleQP.Name + ' price has been updated to ' + objBundleQP.List_Price__c));
                }
                if(blnHasPriceUpdate)
                {
                    blnHasError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'<b>Please Save to update Quote Products.</b>'));
                    return null;
                }
            }
            
            if(!quote.Include_Special_Offer_in_Output__c && String.isNotBlank(quote.Special_Offer_Terms__c))
            {
                String strRichText = String.valueof(quote.Special_Offer_Terms__c);
                strRichText = strRichText.replaceall('<.*>','');
                if(String.isNotBlank(strRichText))
                    quote.Include_Special_Offer_in_Output__c = true;
            }
            
            saveGC();
            processThirdPartyGCLine();
            
            // ****************** Calculations *****************************
            // Using 1 consolidated list to limit DML operations
            List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
            intIndex = 0;
            Decimal decTotalNetPrice = 0,decTotalDiscount = 0,decGenesysProductsDiscount = 0,decPSRDPTotal = 0, listPriceTotalProductsOnly = 0, decGenesysAllDiscount = 0, listPriceTotalAll = 0;
            
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
            CMRRPreDiscount = 0;
            maxSeatCount = 0;
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords)
            {
                //intIndex++;
                set_ProductIds.add(objQP.BigMachines__Product__c);
                // Initializing values to be computed
                
                //   objQP.Total_Discount__c = objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c 
                //    = objQP.Ext_List__c = objQP.Ext_Net_Price__c = 0;
               
                //Code change start by Ankit on 11/12 for AVAYA
                 objQP.Total_Discount__c = objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c=0;
                   
                if(objQP.Bundle__r.Group_Type__c!='Campaigns'  && objQP.Product_Description__c != 'Campaign'){
                  objQP.Ext_List__c = 0;
                    objQP.Ext_Net_Price__c = 0;
                }
                
                  ////Code change start by Ankit on 11/12 for AVAYA 
                  // Line Discount
                 if(objQP.Bundle__r.Group_Type__c=='Campaigns'  && objQP.Product_Description__c == 'Campaign'){
                    if(objQP.Disc__c != null && String.isNotBlank(objQP.or_Amount__c))
                    {
                        // Proposal Group Discount
                        if(String.isNotBlank(objQP.Group_Number__c) && 
                            map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) && 
                            map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c != null)
                        {
                            if(objQP.BigMachines__Product__r.Building_Block__c != 'PS Rapid Deployment Packages')
                            {
                                objQP.Proposal_Group_Discount__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c;
                                objQP.Total_Discount__c += objQP.Proposal_Group_Discount__c;
                                objQP.Ext_Net_Price__c = objQP.Ext_list__c - (objQP.Ext_list__c * objQP.Proposal_Group_Discount__c/100);
                            }
                        }
                        
                        
                        // Selected Discount Option is %
                        if(objQP.or_Amount__c == '%')
                        {
                            objQP.Total_Discount__c += objQP.Disc__c;
                            objQP.Total_Discount__c += objQP.Mandatory_Discount__c;
                            objQP.Ext_Net_Price__c = objQP.Ext_List__c - objQP.Ext_List__c*(objQP.Total_Discount__c/100);
                            //objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Disc__c/100);
                        }
                        // Selected Discount Option is Amt
                        else if(objQP.or_Amount__c == 'Amt')
                        {
                            objQP.Total_Discount__c += (objQP.Disc__c/objQP.Ext_List__c) * 100;
                            objQP.Ext_Net_Price__c =objQP.Ext_List__c - objQP.Disc__c;
                        }
                    }
                        
                     // Adjustment Discount
                    if(objQP.Adjustment__c != null && objQP.Adjustment__c != 0)
                    {
                        objQP.Total_Discount__c += objQP.Adjustment__c;
                        objQP.Ext_Net_Price__c =objQP.Ext_List__c- (objQP.Ext_List__c * objQP.Total_Discount__c/100);
                    }
                       decTotalNetPrice += objQP.Ext_Net_Price__c;
                        decTotalDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                continue;      
               }
    
                if(objQP.List_Price__c != null && objQP.List_Price__c != 0) 
                {                  
                    objQP.Net_Unit_Price__c = objQP.List_Price__c;
                        
                    // Proposal Group Discount
                    if(String.isNotBlank(objQP.Group_Number__c) && 
                        map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c) && 
                        map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c != null)
                    {
                        if(objQP.BigMachines__Product__r.Building_Block__c != 'PS Rapid Deployment Packages')
                        {
                            objQP.Proposal_Group_Discount__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Discount__c;
                            objQP.Total_Discount__c += objQP.Proposal_Group_Discount__c;
                            objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Proposal_Group_Discount__c/100);
                        }
                    }                    
                    // Line Discount
                    if(objQP.Disc__c != null && String.isNotBlank(objQP.or_Amount__c))
                    {
                        // Selected Discount Option is %
                        if(objQP.or_Amount__c == '%')
                        {
                            objQP.Total_Discount__c += objQP.Disc__c;
                            objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Disc__c/100);
                        }
                        // Selected Discount Option is Amt
                        else if(objQP.or_Amount__c == 'Amt')
                        {
                            objQP.Total_Discount__c += (objQP.Disc__c/objQP.List_Price__c) * 100;
                            objQP.Net_Unit_Price__c -= objQP.Disc__c;
                        }
                    }
                    
                    //Mandatory Discount
                    if(objQP.Mandatory_Discount__c != null)
                    {
                        objQP.Total_Discount__c += objQP.Mandatory_Discount__c;
                        objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Mandatory_Discount__c/100);
                    }
                    // Bundle Discount
                    if(objQP.Bundle__c != null && objQP.Bundle_Discount__c != null && objQP.Bundle_Discount__c != 0)
                    {
                        objQP.Total_Discount__c += objQP.Bundle_Discount__c;
                        objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Bundle_Discount__c/100);
                    }
                    
                    // Adjustment Discount
                    if(objQP.Adjustment__c != null && objQP.Adjustment__c != 0)
                    {
                        objQP.Total_Discount__c += objQP.Adjustment__c;
                        objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Adjustment__c/100);
                    }
    
                    objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
                    
                    if(objQP.Quantity__c != null)
                    {
                        //if(String.isBlank(objQP.Build_Type__c))
                        //{
                            objQP.Ext_List__c = objQP.List_Price__c * objQP.Quantity__c;
                            objQP.Ext_Net_Price__c = objQP.Net_Unit_Price__c * objQP.Quantity__c;
                        /*}
                        else
                        {
                            objQP.Ext_List__c = objQP.List_Price__c;
                            objQP.Ext_Net_Price__c = objQP.Net_Unit_Price__c;
                        }*/
                        decTotalNetPrice += objQP.Ext_Net_Price__c;
                        decTotalDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                        
                        if(objQP.Bundle__c == null)
                        {
                            if(objQP.Third_Party__c != 'TRUE'){
                                decGenesysProductsDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                                listPriceTotalProductsOnly += objQP.Ext_List__c;
                            }  
                            decGenesysAllDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                            listPriceTotalAll += objQP.Ext_List__c;                      
                        }
                    }
                    
                    if(objQP.BigMachines__Product__r.Third_Party__c != null && objQP.BigMachines__Product__r.Third_Party__c.toUpperCase() == 'TRUE'){
                        Decimal goldProductPrice = objQP.NG1_PPU_Gold_USD__c;//(Decimal)objQP.getSObject('BigMachines__Product__r').get('NG1_PPU_Gold_USD__c');
                        if(objQP.Net_Unit_Price__c < goldProductPrice){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please note List price cannot be lowered than Gold tier price for third party products. Please lower your discount for third party products.'));                                                                                    
                            blnHasError = true;
                            return null;
                        }
                    }
                    
                                        
                    if(objQP.Total_Discount__c > 100)
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
                    /*// Total Discount for a Line cannot exceed Product Specific Discount for the Product/Line for 3rd Party Products          
                    if(objQP.PPU_Product_Specific_Discount__c != null && objQP.PPU_Product_Specific_Discount__c != 0 &&
                        objQP.Third_Party__c == 'TRUE' && objQP.Total_Discount__c > objQP.PPU_Product_Specific_Discount__c)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Line ' + String.valueOf(intIndex) + ' : Total Discount cannot exceed Product Specific Discount for 3rd Party Products.'));
                        blnHasError = true;
                    }*/
                    
                    // Add to Third Party GC Line Total Net for Third party HW lines
                    if(objQP.Third_Party__c == 'TRUE' && (objQP.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || objQP.BigMachines__Product__r.Type__c  == Label.Product_System_License_Product_Type))
                    {
                        if(objThirdPartyGCLine != null && objQP.Third_Party_GC__c != null && objQP.Third_Party_GC__c != 0)
                            objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (objQP.Third_Party_GC__c/100);
                    }
                        
                    if(objQP.BigMachines__Product__r.Building_Block__c == 'PS Rapid Deployment Packages')
                        decPSRDPTotal += objQP.Ext_Net_Price__c;
                }
            }
            
            if(blnHasBundles)
            {
                // Copying Bundle Line data and updating the the sell-able item lines related to the Bundles
                for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
                {
                    if(objQP.Bundle_Line__c != null && map_BundleQuoteProducts.containsKey(objQP.Bundle_Line__c))
                    {
                        BigMachines__Quote_Product__c objBundleQP = map_BundleQuoteProducts.get(objQP.Bundle_Line__c);
              set_ProductIds.add(objBundleQP.BigMachines__Product__c);                             
                        
                       //Commented by Ankit for Avaya and added below snippet 
                       // objQP.Total_Discount__c = objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c 
                       //     = objQP.Ext_List__c = objQP.Ext_Net_Price__c = 0;
                       
                        
                        //Code change start by Ankit on 11/12 for AVAYA
                         objQP.Total_Discount__c = objQP.Net_Unit_Price__c = objQP.Proposal_Group_Discount__c=0;
                        
                        if(objQP.Bundle__r.Group_Type__c!='Campaigns'  && objQP.Product_Description__c != 'Campaign'){
                            objQP.Ext_List__c = 0;
                            objQP.Ext_Net_Price__c = 0;
                        }
                        
                      
                        
                        if(objQP.List_Price__c != null && objQP.List_Price__c != 0)
                        {
                            objQP.Net_Unit_Price__c = objQP.List_Price__c;
                            
                            // Line Discount specified at Bundle Level
                            if(objBundleQP.Disc__c != null && String.isNotBlank(objBundleQP.or_Amount__c))
                            {
                                // Selected Discount Option at Bundle Level is %
                                if(objBundleQP.or_Amount__c == '%')
                                {
                                    objQP.Disc__c = objBundleQP.Disc__c;
                                    objQP.or_Amount__c = objBundleQP.or_Amount__c;
                                    objQP.Total_Discount__c += objQP.Disc__c;
                                    objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Disc__c/100);
                                }
                                // Selected Discount Option at Bundle Level is Amt
                                // Changed by Ankit for Avaya on 11/12
                                else if(objBundleQP.or_Amount__c == 'Amt' )
                                {
                                    if(objBundleQP.Product_Description__c != 'Campaign')
                                    objQP.Disc__c = (objBundleQP.Disc__c/objBundleQP.List_Price__c) * objQP.List_Price__c;
                                    else
                                     objQP.Disc__c = (objBundleQP.Disc__c/objBundleQP.Ext_List__c) * objQP.List_Price__c;    
                                    objQP.or_Amount__c = objBundleQP.or_Amount__c;
                                    objQP.Total_Discount__c += (objQP.Disc__c/objQP.List_Price__c) * 100;
                                    objQP.Net_Unit_Price__c -= objQP.Disc__c;
                                }
                            }
                            
                            objQP.Bundle_Discount__c = objBundleQP.Bundle_Discount__c;
                            // Bundle Discount
                            if(objQP.Bundle_Discount__c != null && objQP.Bundle_Discount__c != 0)
                            {
                                objQP.Total_Discount__c += objQP.Bundle_Discount__c;
                                objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Bundle_Discount__c/100);
                            }
                            
                            objQP.Adjustment__c = objBundleQP.Adjustment__c;
                            // Adjustment Discount
                            if(objQP.Adjustment__c != null && objQP.Adjustment__c != 0)
                            {
                                objQP.Total_Discount__c += objQP.Adjustment__c;
                                objQP.Net_Unit_Price__c -= (objQP.List_Price__c * objQP.Adjustment__c/100);
                            }
                            
                            objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
                            
                            if(objQP.Bundle__r.Group_Type__c!='Campaigns')
                            objQP.Quantity__c = objBundleQP.Quantity__c * (objQP.Committed_Quantity__c != null ? objQP.Committed_Quantity__c : 1);
                            
                            if(objQP.Quantity__c != null)
                            {
                                objQP.Ext_List__c = objQP.List_Price__c * objQP.Quantity__c;
                                objQP.Ext_Net_Price__c = objQP.Net_Unit_Price__c * objQP.Quantity__c;
                                //if(objQP.Bundle__r.Group_Type__c == 'Campaigns')
                                //  decTotalNetPrice += objQP.Ext_Net_Price__c;
                                if(objQP.Third_Party__c != 'TRUE'){
                                    decGenesysProductsDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                                    listPriceTotalProductsOnly += objQP.Ext_List__c;
                                }
                                decGenesysAllDiscount += objQP.Ext_List__c - objQP.Ext_Net_Price__c;
                                listPriceTotalAll += objQP.Ext_List__c;
                            }
                            
                            // Software
                            if(blnHasRDP && objQP.BigMachines__Product__r.Type__c == 'Product' && 
                                objQP.Quantity__c > 300 && 
                                objQP.Unit_of_Measure__c != null && objQP.Unit_of_Measure__c.containsIgnoreCase('seat'))
                            {
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please contact your Regional PS Services Engagement Manager to quote opportunities with more than 300 seats.'));
                                blnHasError = true;
                                return null;
                            }
                        }
                        else{
                            //ADDED by Ankit on 11/12 for AVAYA
                            if(objQP.Bundle__r.Group_Type__c!='Campaigns'  && objQP.Product_Description__c != 'Campaign')
                            objQP.List_Price__c = objQP.Ext_List__c = 0;
                        }    
                        /*// Total Discount for a Line cannot exceed Product Specific Discount for the Product/Line for 3rd Party Products          
                        if(objQP.PPU_Product_Specific_Discount__c != null && objQP.PPU_Product_Specific_Discount__c != 0 &&
                            objQP.Third_Party__c == 'TRUE' && objQP.Total_Discount__c > objQP.PPU_Product_Specific_Discount__c)
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Bundle (' + objBundleQP.Name + ') : Total Discount on a line cannot exceed Product Specific Discount for 3rd Party Products.'));
                            blnHasError = true;
                        }*/
                        
                        // Add to Third Party GC Line Total Net for Third party HW lines
                        if(objQP.Third_Party__c == 'TRUE' && (objQP.BigMachines__Product__r.Type__c == Label.Hardware_Product_Type || objQP.BigMachines__Product__r.Type__c  == Label.Product_System_License_Product_Type))
                        {
                            if(objThirdPartyGCLine != null && objQP.Third_Party_GC__c != null && objQP.Third_Party_GC__c != 0)
                                objThirdPartyGCLine.Ext_Net_Price__c += objQP.Ext_Net_Price__c * (objQP.Third_Party_GC__c/100);
                        }
                    }
                }
                list_ToUpdate.addAll(list_BundleItemQPRecords);
            }
            
            if(blnHasError)
                return null;
                
            if(list_QuoteProductRecords.size() > 0)
                list_ToUpdate.addAll(list_QuoteProductRecords);
                
            calculateGroupSubTotals();
            
            // Storing Sub Totals on Lines and Adding up totals for products of different types and storing total adjustment
            quote.Total_Software__c = quote.Total_Hardware__c = quote.Total_Education__c = quote.Total_Services__c  = 0;
            decTotalSWNetPrice = decTotalHWNetPrice = decTotalEducationNetPrice = decTotalServicesNetPrice = 0;
            quote.Total_Adjustments__c = quote.Total_List_Price__c = 0;
            List<OpportunityLineItem> list_OpptyLinesToInsert = new List<OpportunityLineItem>();       
            System.debug(LoggingLevel.INFO, 'NKC debug list_QuoteProductRecords [' + list_QuoteProductRecords + ']');
            BigMachines__Quote_Product__c objShippingAndHandlingToBeDeleted = objShippingAndHandling;
            objShippingAndHandling = null;
            totalAmount = 0;
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
                /*
                System.debug(LoggingLevel.INFO, 'NKC debug objQP.Is_Training_Unit__c [' + objQP.Is_Training_Unit__c + ']');    
                if(objQP.Is_Training_Unit__c){ 
                  objTrainingUnit = objQP;
                } 
                
                System.debug(LoggingLevel.INFO, 'NKC debug objTrainingUnit [' + objTrainingUnit + ']');
                
                System.debug(LoggingLevel.INFO, 'NKC debug objQP.BigMachines__Product__r.Type__c ['+objQP.BigMachines__Product__r.Type__c+']');
                System.debug(LoggingLevel.INFO, 'NKC debug objQP.BigMachines__Product__r.Shipping_Cost__c ['+objQP.BigMachines__Product__r.Shipping_Cost__c+']');            
                if(objQP.BigMachines__Product__r.Type__c == 'Product - Hardware' 
                    && objQP.BigMachines__Product__r.Shipping_Cost__c != null &&  objQP.BigMachines__Product__r.Shipping_Cost__c > 0){
                    objShippingAndHandling = updateShippingAndHandling(quote, objShippingAndHandling, objQP, objShippingAndHandlingToBeDeleted);
                    if(objShippingAndHandling != null)      
                        quote.Shipping_Handling__c = objShippingAndHandling.List_Price__c;         
                }
                */
            }
            
            
            for(BigMachines__Quote_Product__c objQP : list_BundleItemQPRecords)
            {                   
                set_ProductIds.add(objQP.BigMachines__Product__c);
                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                addToQuoteTotalsBasedOnProductType(objQP);
                /*
                if(objQP.BigMachines__Product__r.Type__c == 'Product - Hardware' 
                    && objQP.BigMachines__Product__r.Shipping_Cost__c != null &&  objQP.BigMachines__Product__r.Shipping_Cost__c > 0){
                    objShippingAndHandling = updateShippingAndHandling(quote, objShippingAndHandling, objQP, objShippingAndHandlingToBeDeleted);
                    if(objShippingAndHandling != null)      
                        quote.Shipping_Handling__c = objShippingAndHandling.List_Price__c;         
                }
                */
            }
            /*
            if(objShippingAndHandling != null && objShippingAndHandling.List_Price__c != NULL){
                Double currencyConversionRate = 1;
                List<CurrencyType> usdCurrency = [SELECT ConversionRate FROM CurrencyType WHERE IsActive=TRUE AND ISOCode =: quote.CurrencyIsoCode];
                if(!usdCurrency.isEmpty()){
                    currencyConversionRate = usdCurrency[0].ConversionRate;
                }
                objShippingAndHandling.List_Price__c = objShippingAndHandling.List_Price__c * currencyConversionRate;
                objShippingAndHandling.Ext_List__c = objShippingAndHandling.List_Price__c;
                objShippingAndHandling.Net_Unit_Price__c = objShippingAndHandling.List_Price__c;
                objShippingAndHandling.Ext_Net_Price__c = objShippingAndHandling.List_Price__c; 
            }
            */
            if(blnHasRDP && decTotalSWNetPrice > 500000)
            {
                String strErrMsg = 'Total cost of the net licenses cannot exceed $500K. For additional requirements please contact your regional Professional Services presales contact.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strErrMsg));
                blnHasError = true;
                return null;
            }
            
            // Service Level/Genesys Care
            quote.Total_Genesys_Care__c = 0; 
            if(quote.Service_Level__c != 'Decline' && objServiceLevel != null)
            {           
                if(decTotalSWNetPrice != null)// && !isPPUQuoting)
                {
                    if(quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c != 0)
                        objServiceLevel.GC_Ext_Net_Price__c = decTotalSWNetPrice * (quote.Genesys_Care_Rate__c/100) * 
                            (quote.Duration_Unit__c == 'Days' ? (quote.Order_Numb_of_Maint_Days__c/365):(quote.Order_Numb_of_Maint_Months__c/12));
                    objServiceLevel.Ext_Net_Price__c = 0;//objServiceLevel.GC_Ext_Net_Price__c; 
                    objServiceLevel.Net_Unit_Price__c = 0;//objServiceLevel.Ext_Net_Price__c;
                    objServiceLevel.List_Price__c = 0;//objServiceLevel.Ext_Net_Price__c;
                    objServiceLevel.Ext_List__c = 0;//objServiceLevel.Ext_Net_Price__c;
                    objServiceLevel.BigMachines__Sales_Price__c = 0;//objServiceLevel.Net_Unit_Price__c;
                    quote.Total_Genesys_Care__c = 0;//objServiceLevel.Ext_Net_Price__c;
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
                objThirdPartyGCLine.Ext_List__c = objThirdPartyGCLine.Ext_Net_Price__c;
                objThirdPartyGCLine.BigMachines__Sales_Price__c = objThirdPartyGCLine.Ext_Net_Price__c;
                set_ProductIds.add(objThirdPartyGCLine.BigMachines__Product__c);
                list_ToUpdate.add(objThirdPartyGCLine);
            }
            PageReference newPageRef;
            /*
            //Naresh Kumar  03/23/2016
            //Training Unit
            System.debug(LoggingLevel.INFO, 'NKC debug objTrainingUnit ['+objTrainingUnit+']');
            System.debug(LoggingLevel.INFO, 'NKC debug quote.Total_Software__c ['+quote.Total_Software__c+']');        
            if(!quote.Override_Training_Unit__c && quote.Total_Software__c > 25000)
                objTrainingUnit = updateTrainingUnit(quote, objTrainingUnit, quote.Total_Software__c, quote.BigMachines__Opportunity__r.Type, quote.BigMachines__Opportunity__r.Country_Region__c);
            System.debug(LoggingLevel.INFO, 'NKC debug objTrainingUnit ['+objTrainingUnit+']');    
            if(objTrainingUnit!= null){
                applyVolumeDiscountOnTrainingUnit(quote, objTrainingUnit);
            }
            
             
            if(quote.Total_Prepaid_Prof_Services__c != null && quote.Total_Prepaid_Prof_Services__c > 0){
                if(objProfessionalServices == null){
                    List<Product2> professionalServicesProduct = [SELECT Id, Name, Unit_of_Measure__c, PPU_Product_Specific_Discount__c FROM Product2 
                        WHERE id =: Label.CreateQuoteOnPremise_Prepaid_Professional_Services_Product_Id];
                      if(!professionalServicesProduct.isEmpty()){            
                          objProfessionalServices = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1, BigMachines__Sales_Price__c = 0, BigMachines__Quote__c = quote.id);            
                          objProfessionalServices.Name = professionalServicesProduct[0].Name;
                          objProfessionalServices.List_Price__c = quote.Total_Prepaid_Prof_Services__c;
                          objProfessionalServices.Quantity__c = 1;
                          objProfessionalServices.Unit_of_Measure__c = professionalServicesProduct[0].Unit_of_Measure__c;
                          objProfessionalServices.BigMachines__Product__c = professionalServicesProduct[0].Id;            
                          objProfessionalServices.or_Amount__c = '%';  
                          objProfessionalServices.Ext_List__c = objProfessionalServices.List_Price__c;
                          objProfessionalServices.Net_Unit_Price__c = objProfessionalServices.List_Price__c;
                          objProfessionalServices.Ext_Net_Price__c = objProfessionalServices.List_Price__c;
                          objProfessionalServices.BigMachines__Sales_Price__c = objProfessionalServices.List_Price__c;
                          objProfessionalServices.currencyIsoCode = quote.currencyIsoCode;
                          insert objProfessionalServices; 
                    }
                }
                else{
                    objProfessionalServices.List_Price__c = quote.Total_Prepaid_Prof_Services__c;
                    objProfessionalServices.Ext_List__c = objProfessionalServices.List_Price__c;
                    objProfessionalServices.Net_Unit_Price__c = objProfessionalServices.List_Price__c;
                    objProfessionalServices.Ext_Net_Price__c = objProfessionalServices.List_Price__c;
                    objProfessionalServices.BigMachines__Sales_Price__c = objProfessionalServices.List_Price__c;
                    update objProfessionalServices;
                }       
            }
            else if(objProfessionalServices != null){
                delete objProfessionalServices;     
                objProfessionalServices = null;       
            } 
            
            if(!quote.Override_Training_Unit__c && objTrainingUnit != null && quote.Total_Software__c <= 25000 ){
              delete objTrainingUnit;
              newPageRef = new PageReference('/apex/CreateQuotePPU?id=' + quote.id);
              newPageRef.setRedirect(true);
            }
            */
            quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c = decTotalNetPrice;
            // Amounts
            quote.Total_Discount__c = decTotalDiscount;
            quote.Total_Subtotal_1__c = quote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c 
                + quote.Total_Genesys_Care__c + quote.BEP_Third_Party_Genesys_Care__c;// + quote.Shipping_Handling__c;
            quote.CMRR__c = totalAmount;
            quote.Max_Seat_Count__c = maxSeatCount;
            quote.Annual_Contract_Value__c = totalAmount * (quote.No_Of_Months__c > 12 ? 12 : quote.No_Of_Months__c);
            quote.Cloud_Total__c = totalAmount * quote.No_Of_Months__c;
            
            quote.CMRR_Pre_Discount__c = CMRRPreDiscount;
            quote.ACV_Pre_Discount__c = CMRRPreDiscount * (quote.No_Of_Months__c > 12 ? 12 : quote.No_Of_Months__c);
            quote.TCV_Pre_Discount__c = CMRRPreDiscount * quote.No_Of_Months__c;
            // Percentages
            quote.Total_Discount_Genesys_Products_Only__c = quote.Total_Discount_Genesys_and_Third_Party__c = 0;
            System.debug('NKC debug Total_Software__c ['+decGenesysAllDiscount+']');
            System.debug('NKC debug listPriceTotalAll ['+listPriceTotalAll+']');
            if((decTotalDiscount + decTotalNetPrice) != 0){
                if(listPriceTotalProductsOnly != 0)
                    quote.Total_Discount_Genesys_Products_Only__c = (decGenesysProductsDiscount/listPriceTotalProductsOnly) * 100;
                if(listPriceTotalAll!=0)    //if condition added by Priyank to handle Divide by 0 error on VF page.
                    quote.Total_Discount_Genesys_and_Third_Party__c = (decGenesysAllDiscount/listPriceTotalAll) * 100;            
                //if(listPriceTotalThirdPartyOnly != 0)
                    //quote.Total_Discount_Genesys_and_Third_Party__c = (decGenesysThirdPartyDiscount/listPriceTotalThirdPartyOnly) * 100;
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
            
            
            // Putting in redundancy to update unit of measure so that UOM update is not missed in any quote
            updateUnitOfMeasure();
            
            // Savepoint before DML
            Savepoint objSP = Database.setSavepoint();
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            try
            {
                if(list_ProposalGroups.size() > 0)
                    update list_ProposalGroups;
                
                if(list_ToUpdate.size() > 0)
                    database.upsert(list_ToUpdate, false);
                    
                if(getIsOrderInfoAvailable() && (quote.Revise_Minor__c || blnIsReviseOrder))
                    saveOrderInfo();
                
                if(quote.Deal_Qualification__c == null){
                    List<Deal_Qualification__c> dq = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
                    if(!dq.isEmpty())
                        quote.Deal_Qualification__c = dq[0].id; 
                }            
                update quote;
                System.debug('++++++++before opportunity'+quote.BigMachines__Opportunity__c+quote.BigMachines__Is_Primary__c+blnIsSimulated);
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
                    //if(objProfessionalServices != null)
                    //    set_ProductIds.add(objProfessionalServices.BigMachines__Product__c);
                    Map<Id,Id> map_ProdIdToPBEId = new Map<Id,Id>();
                    for(PricebookEntry objPE : [SELECT Product2Id,Id FROM PricebookEntry WHERE 
                              Pricebook2Id = :Label.Standard_Pricebook_Id AND 
                              Product2Id IN :set_ProductIds AND CurrencyISOCode = :quote.CurrencyISOCode])
                        map_ProdIdToPBEId.put(objPE.Product2Id,objPE.Id);
                    
                    List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();
                    for(BigMachines__Quote_Product__c objQP : list_ToUpdate)
                    {
                      //Naresh Kumar  03/08/2016  Skip the main bundle line   
                      if(objQP.Bundle__c != null && objQP.Bundle_Line__c == null)
                        continue;
                      System.debug('NKC debug objQP.Bundle_Line__c ['+objQP.Bundle_Line__c+']');
                        //if(objQP.Bundle_Line__c != null)
                        //    continue;
                        System.debug('NKC debug map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c) ['+map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c)+']');    
                        if(map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c))
                        {
                            list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = quote.Id,
                                Description__c = objQP.Product_Description__c,OpportunityId = quote.BigMachines__Opportunity__c,
                                PricebookEntryId = map_ProdIdToPBEId.get(objQP.BigMachines__Product__c),
                                Quantity = objQP.Quantity__c,Quantity__c = objQP.Quantity__c,UnitPrice = objQP.Net_Unit_Price__c,
                                Total_Discount__c = objQP.Total_Discount__c,Unit_of_Measure__c = objQP.Unit_of_Measure__c));
                        }
                    }
                    if(objShippingAndHandling != null){
                        list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = quote.Id,
                                Description__c = objShippingAndHandling.Product_Description__c,OpportunityId = quote.BigMachines__Opportunity__c,
                                PricebookEntryId = map_ProdIdToPBEId.get(objShippingAndHandling.BigMachines__Product__c),
                                Quantity = objShippingAndHandling.Quantity__c,Quantity__c = objShippingAndHandling.Quantity__c,UnitPrice = 0,
                                Total_Discount__c = objShippingAndHandling.Total_Discount__c,Unit_of_Measure__c = objShippingAndHandling.Unit_of_Measure__c));  
                    }
                    /*
                    if(objProfessionalServices != null){
                        list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = quote.Id,
                                Description__c = objProfessionalServices.Product_Description__c,OpportunityId = quote.BigMachines__Opportunity__c,
                                PricebookEntryId = map_ProdIdToPBEId.get(objProfessionalServices.BigMachines__Product__c),
                                Quantity = objProfessionalServices.Quantity__c,Quantity__c = objProfessionalServices.Quantity__c,UnitPrice = objProfessionalServices.List_Price__c,
                                Total_Discount__c = objProfessionalServices.Total_Discount__c,Unit_of_Measure__c = objProfessionalServices.Unit_of_Measure__c));  
                    }
                    */
                    if(list_OpptyLinesToCreate.size() > 0)
                        insert list_OpptyLinesToCreate;
                }
                
                // Fetching Quote Products (To update name on Genesys Care line : might scrap this to improve efficiency)
                getQuoteProducts(quoteId);
                
                blnSkipPriceCheck = blnIsReviseOrder = false;
                populatePPUDiscounts();
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                // Roll back changes in case of DML failure
                Database.rollback(objSP);
            }
            return newPageRef;
        }
        /*
        Commented by Anshul Jain as not used on 27Sept'18
        private static BigMachines__Quote_Product__c updateShippingAndHandling(BigMachines__Quote__c quote, BigMachines__Quote_Product__c objShippingAndHandling, 
            BigMachines__Quote_Product__c hardwareQP, BigMachines__Quote_Product__c objShippingAndHandlingToBeDeleted){
            System.debug(LoggingLevel.INFO, 'NKC debug objShippingAndHandling ['+objShippingAndHandling+']');
            if(objShippingAndHandling == null){         
                
                List<Product2> shippingAndHandlingProduct = [SELECT Id, Name, Unit_of_Measure__c, PPU_Product_Specific_Discount__c FROM Product2 
                    WHERE id =: Label.CreateQuoteOnPremise_Shipping_Handling_Product_Id];
                if(shippingAndHandlingProduct.isEmpty()){
                   return null;
                }
                if(objShippingAndHandlingToBeDeleted != null){
                    objShippingAndHandling = objShippingAndHandlingToBeDeleted;
                    objShippingAndHandling.List_Price__c = (hardwareQP.Quantity__c * hardwareQP.BigMachines__Product__r.Shipping_Cost__c);
                }
                else{
                    objShippingAndHandling = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1, BigMachines__Sales_Price__c = 0, BigMachines__Quote__c = quote.id);            
                    objShippingAndHandling.Name = shippingAndHandlingProduct[0].Name;
                    objShippingAndHandling.List_Price__c = (hardwareQP.Quantity__c * hardwareQP.BigMachines__Product__r.Shipping_Cost__c);
                    objShippingAndHandling.Quantity__c = 1;
                    objShippingAndHandling.Unit_of_Measure__c = shippingAndHandlingProduct[0].Unit_of_Measure__c;
                    objShippingAndHandling.BigMachines__Product__c = shippingAndHandlingProduct[0].Id;            
                    objShippingAndHandling.or_Amount__c = '%';
                }  
            }   
            else{
                objShippingAndHandling.List_Price__c += (hardwareQP.Quantity__c * hardwareQP.BigMachines__Product__r.Shipping_Cost__c);
            }   
            System.debug(LoggingLevel.INFO, 'NKC debug objShippingAndHandling.List_Price__c ['+objShippingAndHandling.List_Price__c+']');
            return objShippingAndHandling;
        }*/
        
        
        /*
        //Naresh Kumar  04/26/2016
        //Training Unit
        private static BigMachines__Quote_Product__c updateTrainingUnit(BigMachines__Quote__c quote, BigMachines__Quote_Product__c objTrainingUnit, Decimal totalSoftware, String oppType, String oppRegion){
          System.debug(LoggingLevel.INFO, 'NKC debug objTrainingUnit ['+objTrainingUnit+']');          
          System.debug(LoggingLevel.INFO, 'NKC debug oppType ['+oppType+']');
          System.debug(LoggingLevel.INFO, 'NKC debug oppRegion ['+oppRegion+']');      
            if(objTrainingUnit == null){
              Quote_Training_Unit_Region_Settings__c regionProduct = getTrainingUnitLine(oppType, oppRegion);
              System.debug(LoggingLevel.INFO, 'NKC debug regionProduct ['+regionProduct+']');          
              if(regionProduct != null && regionProduct.value__c != null){
                List<Product2> trainingProduct = [SELECT Id, Name, Unit_of_Measure__c, PPU_Product_Specific_Discount__c FROM Product2 WHERE Name = :regionProduct.value__c];
                System.debug(LoggingLevel.INFO, 'NKC debug trainingProduct ['+trainingProduct+']');
                if(!trainingProduct.isEmpty()){
                  objTrainingUnit = new BigMachines__Quote_Product__c(BigMachines__Quantity__c = 1,
                                        BigMachines__Sales_Price__c = 0, Is_Training_Unit__c = true);
                    objTrainingUnit.Name = trainingProduct[0].Name;
                    objTrainingUnit.List_Price__c = regionProduct.List_Price__c;
                    objTrainingUnit.Quantity__c = 1;
                    objTrainingUnit.Unit_of_Measure__c = trainingProduct[0].Unit_of_Measure__c;
                    objTrainingUnit.BigMachines__Product__c = trainingProduct[0].Id;
                    objTrainingUnit.PPU_Product_Specific_Discount__c = trainingProduct[0].PPU_Product_Specific_Discount__c;
                    objTrainingUnit.or_Amount__c = '%';
                    objTrainingUnit.TU_System_Added__c = true;
                }
              }
              System.debug(LoggingLevel.INFO, 'NKC debug objTrainingUnit ['+objTrainingUnit+']');
              if(objTrainingUnit != null){
                    objTrainingUnit.BigMachines__Quote__c = quote.Id;
                    objTrainingUnit.currencyIsoCode = quote.currencyIsoCode;
                    insert objTrainingUnit;
                }
                else
                  return null;
            }
             List<Double> listOfRanges = new List<Double>();
            List<Quote_Training_Unit_Ranges__c> allRanges = Quote_Training_Unit_Ranges__c.getall().values();
            for(Quote_Training_Unit_Ranges__c eachRange : allRanges){
               listOfRanges.add(Double.valueOf(eachRange.Name));  
            }
            listOfRanges.sort();
            Quote_Training_Unit_Ranges__c applicableRange;
            System.debug(LoggingLevel.INFO, 'NKC debug listOfRanges ['+listOfRanges+']');
            //Looping over each range
            for(Double eachRange : listOfRanges){
              System.debug(LoggingLevel.INFO, 'NKC debug eachRange ['+eachRange+']');
              System.debug(LoggingLevel.INFO, 'NKC debug totalSoftware ['+totalSoftware+']');
              if(totalSoftware < eachRange){
                applicableRange = Quote_Training_Unit_Ranges__c.getall().get(String.valueOf(Math.round(eachRange)));
                break;
              }
            }
            System.debug(LoggingLevel.INFO, 'NKC debug applicableRange ['+applicableRange+']');        
            if(applicableRange != null && applicableRange.Rate__c > 0){
              Double extendedListPrice = (totalSoftware * applicableRange.Rate__c) / 100;
              objTrainingUnit.Quantity__c = Math.round(extendedListPrice / 100);
              objTrainingUnit.Ext_List__c = objTrainingUnit.List_Price__c * objTrainingUnit.Quantity__c;
              if(objTrainingUnit.Disc__c != null && objTrainingUnit.Disc__c != 0)
                objTrainingUnit.Net_Unit_Price__c = objTrainingUnit.List_Price__c - (objTrainingUnit.List_Price__c * objTrainingUnit.Disc__c/100);
              else
                objTrainingUnit.Net_Unit_Price__c = objTrainingUnit.List_Price__c;
              objTrainingUnit.Ext_Net_Price__c = objTrainingUnit.Net_Unit_Price__c * objTrainingUnit.Quantity__c;                     
            }
            return objTrainingUnit;
            //applyVolumeDiscountOnTrainingUnit(quote, objTrainingUnit);
            
        }
        
        private static void applyVolumeDiscountOnTrainingUnit(BigMachines__Quote__c quote, BigMachines__Quote_Product__c objTrainingUnit){
            //Apply volume discount        
            String partnerTier = quote.Sold_To_Name__r.Partner_Tier__c;
            Boolean isDirectSales = quote.BigMachines__Opportunity__r.Direct_Sales__c;
            
            Double volumeDiscount = -1;
            System.debug('NKC debug objTrainingUnit.Ext_List__c [' + objTrainingUnit.Ext_List__c + ']');
            for(Quote_Training_Unit_Volume_Discount__c eachDiscount : Quote_Training_Unit_Volume_Discount__c.getall().values()){
                if(objTrainingUnit.Ext_List__c >= eachDiscount.Range_From__c && objTrainingUnit.Ext_List__c < eachDiscount.Range_To__c){
                    if(isDirectSales)                   
                        volumeDiscount = eachDiscount.Customer__c;              
                    else if(partnerTier == 'Bronze')
                        volumeDiscount = eachDiscount.Bronze__c;
                    else if(partnerTier == 'Gold')
                        volumeDiscount = eachDiscount.Gold__c;
                    else if(partnerTier == 'Silver')
                        volumeDiscount = eachDiscount.Silver__c;
                }           
            }
            System.debug('NKC debug volumeDiscount [' + volumeDiscount + ']');
            objTrainingUnit.Accepted_Volume_Discount__c = (volumeDiscount <= 0 ? 0 : volumeDiscount);
            if(volumeDiscount >= 0 || (objTrainingUnit.Disc__c != null && objTrainingUnit.Disc__c > 0)){
                objTrainingUnit.or_Amount__c = '%';
                if(objTrainingUnit.Disc__c != null && objTrainingUnit.Disc__c > 0)            
                    objTrainingUnit.Net_Unit_Price__c = objTrainingUnit.List_Price__c - (objTrainingUnit.List_Price__c * objTrainingUnit.Disc__c / 100);
                if(volumeDiscount >= 0)
                    objTrainingUnit.Net_Unit_Price__c = objTrainingUnit.Net_Unit_Price__c - (objTrainingUnit.Net_Unit_Price__c * volumeDiscount / 100);
                objTrainingUnit.Ext_Net_Price__c = objTrainingUnit.Net_Unit_Price__c * objTrainingUnit.Quantity__c;
            }
            update objTrainingUnit;
            
        }
        
        private static Quote_Training_Unit_Region_Settings__c getTrainingUnitLine(String oppType, String oppRegion){
            Quote_Training_Unit_Region_Settings__c regionProduct = Quote_Training_Unit_Region_Settings__c.getInstance(oppRegion);
            System.debug('NKC debug regionProduct [' + regionProduct  + ']');
            System.debug('NKC debug oppType [' + oppType + ']');
            if((oppType == 'New logo' || oppType  == 'Existing Business - New Line of Business' || oppType == 'Existing Business - Cross Sell')
              && regionProduct != null){
              return regionProduct;        
            }
            return null;
        }
        */
        
    }