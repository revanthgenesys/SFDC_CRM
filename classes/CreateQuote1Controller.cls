public with sharing class CreateQuote1Controller {
    String quoteId;
    public BigMachines__Quote__c quote {get; set;}
    public transient Opportunity opp {get; set;}
    
    // List of Sales Order Numbers in ascending order (Sales Order Number changed to Invoice Number)
    public List<String> list_SalesOrerNum {get; set;}
    public transient List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
    // Map of Sales Order Number to List of Quote Product Wrapper (Sales Order Number changed to Invoice Number)
    public Map<String,List<QuoteProductWrapper>> map_SalesOrderNumToQuoteProdWrapper {get; set;}
    // List of Quote Periods being displayed
    public List<Quote_Period__c> list_QuotePeriods {get; set;}
    // List of Quote Periods being edited
    public List<Quote_Period__c> list_QuotePeriodsBeingEdited {get; set;}
    // List of Quote Periods that have been removed from edit table and need to be deleted on save
    List<Quote_Period__c> list_QuotePeriodsRemoved;
    // Flex Care Products
    public List<BigMachines__Quote_Product__c> list_FlexCare {get; set;}
    // Fees Products
    public List<BigMachines__Quote_Product__c> list_Fees {get; set;}
    // Service Level
    public BigMachines__Quote_Product__c objServiceLevel {get; set;}
    // All Configuration Products
    List<BigMachines__Quote_Product__c> list_ConfiguartionProducts {get; set;}
    
    
    
    // Id of Quote Product being deleted    
    public String quoteProductIdToBeDeleted {get; set;}
    // Contract Line Id associated with the quote product being deleted
    public String strSCLIIdBeingDeleted {get; set;}
    
    
    public Boolean showQuoteLines {get; set;}
    
    // For facet checkbox for Grid
    public Boolean blnIsHeaderChecked {get; set;}
    // For facet checkbox to select/unselect Reinstatement for all quote products
    public Boolean blnIsReinstatementForAll {get; set;}
    // For Index of Quote Period table to determine which record is being removed
    public String strQPIndex {get; set;}
    // To indicate Quote Period Table is in edit mode
    public Boolean blnEditQuotePeriod {get; set;}
    // To indicate if there are errors on quoting periods when saving
    public Boolean blnHasPeriodErrors {get; set;}
    // For error message if there are any errors when quoting periods are being edited
    public String strPeriodErrorMsg {get; set;}
    // To store whether to proceed with delete on not based on user decision
    public String strToDelete {get; set;}
    // Number of Quote Periods
    public Integer intNumOfPeriods {get; set;}
    // Map to store conversion rate of currencies
    Map<String,Decimal> map_ConversionRates = new Map<String,Decimal>();
    // To indicate if Extended End Of Support Fee is on the Quote
    public Boolean blnHasExtendedEOSFee {get; set;}
    // To indicate if Reinstatement Fee is on the Quote
    public Boolean blnHasReinstatementFee {get; set;}
    // To store all product upgrades for this quote
    public List<Quote_Products_Upgrade__c> list_ProductUpgrades {get; private set;}
    // To indicate whether all maintenance due should be overridden or system computed
    public Boolean blnIsOverrideAll {get; set;}
    // To indicate whether all Revised Net should be overridden or system computed
    public Boolean blnIsOverrideAllRevisedNet {get; set;}
    // To indicate whether all Previous Maintenance should be overridden or not
    public Boolean blnIsOverrideAllPreviousMaintenance {get; set;}
    // To indicate if there is any line with drop or split
    Boolean blnHasADropOrSplitLine;
    // To store the current currency code on the quote
    String strCurrentCurrencyCode;
    // To indicate whether there is an error when doCalculations() is invoked
    Boolean blnHasError;
    // To indicate whether rates should be set irrespective of whether they are blank
    Boolean blnIsApplyRate;
    // To store the default care rate based on the service level and country of end user
    public Decimal decDefaultCareRate {get; private set;}
    // All products excluding configuration products on the quote
    public transient List<BigMachines__Quote_Product__c> list_QuoteProductRecords;
    // To indicate whether or not to show export screening message
    public Boolean blnShowExportScreeningMsg {get; private set;}
    public id escid{get;private set;}
    
    // To indicate whether or not to Re-Import button will be enabled for FYM Quote
    public Boolean blnIsReImportBtnDisabled {get; private set;}
    
    // ***** For Upgrade of Products *****
    public BigMachines__Quote_Product__c objFromProduct {get; set;}
    public BigMachines__Quote_Product__c objToProduct {get; set;}
    
    // **** For Pagination ****
    public Integer intPageNum {get; private set;}
    public Integer intPageSize {get; private set;}
    public Integer intTotalNoOfRecords {get; private set;}
    
    // Invoices and their ELA Status - added by RAO
    public Map<String, Boolean> invoicesELA  {get; set;} 
    public String currentInvoiceForELA  {get; set;} 
    
    public CreateQuote1Controller(){
        init();
    }
    
    private void init(){
        quoteId = ApexPages.currentPage().getParameters().get('id');
        list_Fees = new List<BigMachines__Quote_Product__c>();
        list_FlexCare = new List<BigMachines__Quote_Product__c>();
        objFromProduct = new BigMachines__Quote_Product__c();
        objToProduct = new BigMachines__Quote_Product__c();
        
        blnIsHeaderChecked = blnIsOverrideAll = blnIsOverrideAllRevisedNet = blnIsOverrideAllPreviousMaintenance = 
		blnHasExtendedEOSFee = blnHasReinstatementFee = blnIsReinstatementForAll = blnIsApplyRate = 
        blnShowExportScreeningMsg = showQuoteLines = false;
        blnIsReImportBtnDisabled = true;
        
        String oppId;
        // Fetching Quote information
        quote = getQuote(quoteId);
        list_QuoteProducts = new List<QuoteProductWrapper>(); 
        if(quoteId != null){           
            if(quote.Is_FYM_Quote__c && quote.Parent_Quote__c != null){
                if([SELECT LastModifiedDate FROM BigMachines__Quote__c WHERE Id = :quote.Parent_Quote__c].LastModifiedDate > quote.CreatedDate)
                    blnIsReImportBtnDisabled = false;
            }
            
            oppId = quote.BigMachines__Opportunity__c;
            
            // Setting page size to 100 & page number to 1
            intPageSize = 100;
            intPageNum = 1;
            
            // Checking for Fees and setting up Configuration products
            fetchConfigurationProducts();
            
            // Fetching Quote Periods
            fetchQuotePeriods();
            
            // Fetching Quote Products
            // getQuoteProducts(quoteId);
            getQuoteProductsNoCache(quoteId);
            createCurrentPageList();
            // Initialize care rates with default period percentages
            initializeRates();
            
            // Set Tax Rate and based on country and initialize default care rate based on service level and country
            initializeTaxAndDefaultCareRate();
            
            // Setting edit mode on quote period table to false
            blnEditQuotePeriod = false;
            
            // Fetching Quote Product Upgrades
            fetchQuoteProductUpgrades();
            
            // Storing current currency code
            strCurrentCurrencyCode = quote.CurrencyISOCode;
            
            // Storing Currency conversion rates
            for(CurrencyType curr: [SELECT IsoCode,ConversionRate FROM CurrencyType])         
                map_ConversionRates.put(curr.IsoCode,curr.ConversionRate);            
            
            
            if(getIsQuoteUnLocked())
            {
                List<Opportunity> list_Opp = [SELECT Previous_Maintenance_Rate__c,Gene_Care_Specialist__c,Opportunity_Status__c,
                                              Gene_Care_Specialist__r.Name FROM Opportunity WHERE Id = :oppId];
                
                if(list_Opp.size() > 0)
                {
                    opp = list_Opp[0];
                    quote.Previous_Maint_Rate__c = opp.Previous_Maintenance_Rate__c;
                    if(quote.Genesys_Care_Rep_Name__c == null && opp.Gene_Care_Specialist__c != null)
                        quote.Genesys_Care_Rep_Name__c = opp.Gene_Care_Specialist__r.Name;
                }
            }
        }
        else
        {
            oppId = ApexPages.currentPage().getParameters().get('oppId');
            quote.BigMachines__Opportunity__c = oppId;
            // Blanking out field so that new quotes have total fields in sync
            quote.Total_Maintenance_Amount_Due__c = null;
            quote.Total_Before_Tax_Maintenance__c = null;
            List<Opportunity> list_Opp = [SELECT id, Name, AccountId, BusinessPartner__c, 
                                          CurrencyISOCode,Previous_Maintenance_Rate__c,Gene_Care_Specialist__c,Gene_Care_Specialist__r.Name  
                                          FROM Opportunity WHERE id =: oppId];
            // Pre-populating Sold To,End User, Previous Rate and Currency Code on Quote from Opportunity
            if(list_Opp.size() > 0)
            {
                opp = list_Opp[0];
                if(quote.End_User_ID__c == null && opp.AccountId != null)
                {
                    quote.End_User_ID__c = opp.AccountId;
                    // Quote Account should map to End User
                    quote.BigMachines__Account__c = quote.End_User_ID__c;
                }
                if(quote.Sold_To_Name__c == null && opp.BusinessPartner__c != null)
                    quote.Sold_To_Name__c = opp.BusinessPartner__c;
                quote.CurrencyISOCode = opp.CurrencyISOCode;
                quote.Previous_Maint_Rate__c = opp.Previous_Maintenance_Rate__c;
                quote.Quote_Business_Type__c = 'Renewal';
                quote.Order_Type__c = 'Revenue';
                if(opp.Gene_Care_Specialist__c != null)
                    quote.Genesys_Care_Rep_Name__c = opp.Gene_Care_Specialist__r.Name;
            }
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote or Opportunity Id needs to be passed as a parameter for this page.'));
            
            // Default quote expiration after 3 months
            quote.Expiration_Date__c = Date.today().addMonths(3);
        }
    }
    
    // *** Handler for Re-Import button for FYM quotes ***
    public void reimportBtnHandler()
    {
        // Save-point before DML
        Savepoint objSP = Database.setSavepoint();
        // Skip Triggers
        Util.Bypass_Trigger_Chk = true;
        try
        {
            // Remove/flush existing quote lines
            list_QuoteProductRecords = (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId));
            if(list_QuoteProductRecords.size() > 0)
                delete list_QuoteProductRecords;
            
            // Recreate quote lines from source/parent quote
            List<BigMachines__Quote_Product__c> listQuoteProducts = Util.createQPFromOnPremiseToRenewal(quote.Parent_Quote__c,quote);
            if(listQuoteProducts.size() > 0)
                insert listQuoteProducts;
            
            getQuoteProducts(quoteId);
            // createCurrentPageList();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    // **************************** Start :  Quote Period Functionality Methods ********************
    
    // *** Method to query Quote Periods ***
    private void fetchQuotePeriods()
    {
        list_QuotePeriods = [SELECT Start_Date__c,End_Date__c,Default_Period_Care_Rate__c,Months__c,KPI1__c,KPI2__c,
                             Quarterly_Semi_Annual_Fee__c,Partner_to_Partner_Uplift_Fee__c,Default_Increase__c
                             FROM Quote_Period__c WHERE Quote__c = :quote.Id ORDER BY Start_Date__c];
        intNumOfPeriods = list_QuotePeriods.size();
    }
    
    // *** Handler for add Quote period button ***
    public void addQuotePeriod()
    {
        list_QuotePeriodsBeingEdited.add(new Quote_Period__c(Quote__c = quote.Id,
                                                             Default_Period_Care_Rate__c = (decDefaultCareRate != null) ? decDefaultCareRate:0,
                                                             Default_Increase__c = 0));
    }
    
    // *** Handler for removing a Quote period button ***
    public void removeQuotePeriod()
    {
        Integer intRow = Integer.valueOf(strQPIndex);
        if(intRow == 0 && list_QuotePeriodsBeingEdited.size() == 1)
        {
            blnHasPeriodErrors = true;
            strPeriodErrorMsg = 'There needs to be atleast one Quote Period.';
            return;
        }
        if(list_QuotePeriodsBeingEdited[intRow].Id != null)
            list_QuotePeriodsRemoved.add(list_QuotePeriodsBeingEdited[intRow]);
        list_QuotePeriodsBeingEdited.remove(intRow);
    }
    
    // *** Handler for Quote Period 'save' button ***
    public void saveQuotePeriod()
    {
        // *********************  Start : Validations ******************
        blnHasPeriodErrors = false;
        for(Quote_Period__c objPeriod : list_QuotePeriodsBeingEdited)
        {
            if(objPeriod.Start_Date__c == null || objPeriod.End_Date__c == null)
            {
                blnHasPeriodErrors = true;
                strPeriodErrorMsg = 'Start Date and End Date need to be specified on all periods.';
                return;
            }
            if(objPeriod.Start_Date__c > objPeriod.End_Date__c)
            {
                blnHasPeriodErrors = true;
                strPeriodErrorMsg = 'Start Date cannot be greater than End Date for any period.';
                return;
            }
        }
        Integer intTempSize = list_QuotePeriodsBeingEdited.size();
        if(intTempSize > 5)
        {
            blnHasPeriodErrors = true;
            strPeriodErrorMsg = 'A maximum of 5 Quote Periods is supported by the Quoting Tool.';
            return;
        }
        if(intTempSize > 0)
        {
            if(quote.Maintenance_Start_Date__c != null && 
               list_QuotePeriodsBeingEdited[0].Start_Date__c != quote.Maintenance_Start_Date__c)
            {
                blnHasPeriodErrors = true;
                strPeriodErrorMsg = 'Start Date of quote period(s) has to be equal to quote start date (' + quote.Maintenance_Start_Date__c.format() + ').';
                return;
            }
            if(quote.Maintenance_End_Date__c != null && 
               list_QuotePeriodsBeingEdited[intTempSize - 1].End_Date__c != quote.Maintenance_End_Date__c)
            {
                blnHasPeriodErrors = true;
                strPeriodErrorMsg = 'End Date of quote period(s) has to be equal to quote end date (' + quote.Maintenance_End_Date__c.format() + ').';
                return;
            }
            for(Integer i=1; i<intTempSize ; i++)
            {
                Quote_Period__c objPreviousPeriod = list_QuotePeriodsBeingEdited[i-1];
                Quote_Period__c objCurrentPeriod = list_QuotePeriodsBeingEdited[i];
                if(objPreviousPeriod.End_Date__c.addDays(1) != objCurrentPeriod.Start_Date__c)
                {
                    blnHasPeriodErrors = true;
                    strPeriodErrorMsg = 'Start Date of period ' + (i+1) + ' has to be the next day of the End Date of period ' + i + '.';
                    return;
                }
            }
        }
        // *********************  End : Validations ******************
        
        blnEditQuotePeriod = false;
        if(list_QuotePeriodsRemoved.size() > 0)
            delete list_QuotePeriodsRemoved;
        upsert list_QuotePeriodsBeingEdited;
        fetchQuotePeriods();
        initializeRates();
        doCalculations();
    }
    
    // *** Handler for Quote Period 'cancel' button ***
    public void cancelEditofQuotePeriod()
    {
        blnEditQuotePeriod = false;
        blnHasPeriodErrors = false;
        fetchQuotePeriods();
    }
    
    // *** Handler for 'Modify Quote Periods' button ***
    public void editofQuotePeriod()
    {
        blnEditQuotePeriod = true;
        blnHasPeriodErrors = false;
        list_QuotePeriodsBeingEdited = new List<Quote_Period__c>();
        list_QuotePeriodsBeingEdited.addAll(list_QuotePeriods);
        list_QuotePeriodsRemoved = new List<Quote_Period__c>();
    }
    
    // *** Handler for apply quote period link (Invoked Automatically and no longer from the button/link)***
    public void applyQuotePeriod()
    {
        if(list_QuotePeriods.size() == 0)
        {
            if(quote.Maintenance_Start_Date__c == null || quote.Maintenance_End_Date__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start Date and End Date are required to craete a Quote Period.'));
                return;
            }
            if(quote.Maintenance_Start_Date__c > quote.Maintenance_End_Date__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote Start Date cannot be greater than Quote End Date.'));
                return;
            }
            Quote_Period__c objQuotePeriod = new Quote_Period__c();
            objQuotePeriod.Quote__c = quote.Id;
            objQuotePeriod.Start_Date__c = quote.Maintenance_Start_Date__c;
            objQuotePeriod.End_Date__c = quote.Maintenance_End_Date__c;
            objQuotePeriod.Default_Period_Care_Rate__c = (decDefaultCareRate != null) ? decDefaultCareRate:0;
            objQuotePeriod.Default_Increase__c = 0;
            insert objQuotePeriod;
            fetchQuotePeriods();
            // Initialize care rates with default period percentages
            initializeRates();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Quote Period Created.'));
        }
    }
    
    // *** Method to update Quote Periods if start date or end date on quote has changed ***
    public void adjustDatesOnPeriods()
    {
        if(list_QuotePeriods.size() > 0)
        {
            Boolean blnToBeUpdated = false;
            if(quote.Maintenance_Start_Date__c != list_QuotePeriods[0].Start_Date__c)
            {
                list_QuotePeriods[0].Start_Date__c = quote.Maintenance_Start_Date__c;
                blnToBeUpdated = true;
            }
            if(quote.Maintenance_End_Date__c != list_QuotePeriods[list_QuotePeriods.size() - 1].End_Date__c)
            {
                list_QuotePeriods[list_QuotePeriods.size() - 1].End_Date__c = quote.Maintenance_End_Date__c;
                blnToBeUpdated = true;
            }
            if(blnToBeUpdated)
            {
                update list_QuotePeriods;
                fetchQuotePeriods();
            }
        }
    }
    
    // **************************** End :  Quote Period Functionality Methods ********************
    
    // **************************** Start : Pagination ********************
    
    // *** Method to set up grids rows for current page ***
    public void createCurrentPageList()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        if(intTotalNoOfRecords > 0 && quoteId != null)
        {
            list_SalesOrerNum = new List<String>();
            map_SalesOrderNumToQuoteProdWrapper = new Map<String,List<QuoteProductWrapper>>();
            for(Integer i = (intPageNum-1) * intPageSize;i< (intPageNum * intPageSize) && i < intTotalNoOfRecords ; i++)
            {
                QuoteProductWrapper wrapperRecord = list_QuoteProducts[i];
                // Storing Sales Order Numbers in a list
                // Creating a map of Sales Order Number to list of wrapper products
                /* Group By is being changed from Sales Order Number to Invoice Number*/
                if(wrapperRecord.record.Lic_Invoice__c != '' && wrapperRecord.record.Lic_Invoice__c != null)
                {
                    if(map_SalesOrderNumToQuoteProdWrapper.containsKey(wrapperRecord.record.Lic_Invoice__c))
                        map_SalesOrderNumToQuoteProdWrapper.get(wrapperRecord.record.Lic_Invoice__c).add(wrapperRecord);
                    else
                    {
                        map_SalesOrderNumToQuoteProdWrapper.put(wrapperRecord.record.Lic_Invoice__c,new List<QuoteProductWrapper>{wrapperRecord});
                        list_SalesOrerNum.add(wrapperRecord.record.Lic_Invoice__c);
                    }
                }
                // Using Sales order value as 'BLANK' to group when Sales Order is not available
                else
                {
                    if(map_SalesOrderNumToQuoteProdWrapper.containsKey('BLANK'))
                        map_SalesOrderNumToQuoteProdWrapper.get('BLANK').add(wrapperRecord);
                    else
                    {
                        map_SalesOrderNumToQuoteProdWrapper.put('BLANK',new List<QuoteProductWrapper>{wrapperRecord});
                        list_SalesOrerNum.add('BLANK');
                    }
                }
            }
            // Added by RAO for INVOICE ELA
            for(String invNumber : map_SalesOrderNumToQuoteProdWrapper.keySet()){
                invoicesELA.put(invNumber, false); 	   
            }
            for(Invoice__c inv : [SELECT id, Name, ELA__c FROM Invoice__c WHERE Name IN :map_SalesOrderNumToQuoteProdWrapper.keySet()]){
                invoicesELA.put(inv.Name, inv.ELA__c);
            }
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
    
    // *** Handler for view opportunity link ***
    public PageReference viewOpportunity()
    {
        if(quote.BigMachines__Opportunity__c != null)
            return (new PageReference('/' + quote.BigMachines__Opportunity__c));
        return null;
    }
    
    // *** Handler for submit for approval button ***
    public void submitForApprovalBtnHandler()
    {
        if(String.isBlank(quote.Service_Level__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Service Level for this quote.'));
            return;
        }
        doCalculations();
        // if there is an error skip approval process and show error
        if(blnHasError)
            return;
        
        if((quote.End_User_Region__c == 'APAC' || quote.End_User_Region__c == 'EMEA' ||
            quote.End_User_Region__c == 'LATAM' || quote.End_User_Region__c == 'North America') &&
           (quote.Opportunity_Type__c == 'Genesys_Renewal' || quote.Is_FYM_Quote__c))
        {
            try
            {
                // Auto Approve the request if there are no drop/split lines and current rate >= previous rate
                if(!blnHasADropOrSplitLine && 
                   (quote.Previous_Maint_Rate__c == null || quote.Current_Maint_Rate__c >= quote.Previous_Maint_Rate__c))
                {
                    // Setting flags to true as quote is getting updated twice. To ensure status update logic fires.
                    TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;
                    TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER = true;
                    
                    quote.BigMachines__Status__c = 'Quote Approved';
                    quote.Approval_Submission_Date__c = Date.today();
                    quote.Approval_Date__c = Date.today();
                    update quote;
                }
                else
                {
                    quote.DAP_Reason__c = '';
                    if(blnHasADropOrSplitLine)
                        quote.DAP_Reason__c += 'Quote has atleast one Drop or Split line.\n';
                    if(quote.Current_Maint_Rate__c < quote.Previous_Maint_Rate__c)
                        quote.DAP_Reason__c += 'Current rate is lesser than Previous rate for this quote.';
                    
                    update quote;
                    
                    // Create an approval request for the quote
                    Approval.ProcessSubmitRequest objProcessRequest = new Approval.ProcessSubmitRequest();
                    objProcessRequest.setObjectId(quote.Id);
                    objProcessRequest.setComments(quote.DAP_Reason__c);
                    // Submit the approval request for the quote
                    Approval.ProcessResult result = Approval.process(objProcessRequest);
                    // Fetching Quote information
                    quote = getQuote(quoteId);
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote does not meet Approval critera due to End User region and/or Opportunity Type.'));
        }
    }
    
    // *** Handler for submit order button ***
    public void submitOrderBtnHandler()
    {
        Boolean blnHasRequiredError = false;
        blnShowExportScreeningMsg = false;
        if(quote.Order_PO_Number__c == null || quote.Order_PO_Number__c == '')
        {
            quote.Order_PO_Number__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if(quote.Order_PO_Date__c == null)
        {
            quote.Order_PO_Date__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if(quote.Order_PO_Received_Date__c == null)
        {
            quote.Order_PO_Received_Date__c.addError('Required To Submit Order');
            blnHasRequiredError = true;
        }
        if([SELECT count() FROM Attachment WHERE ParentId = :quote.Id] == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There are no attachments on this quote. Please attach PO before submitting order.'));
            blnHasRequiredError = true;
        }
        
        List<Export_Screening_Checklist__c> esc = [select id,Checklist_expiration_date__c FROM Export_Screening_Checklist__c where Account__c=:quote.End_User_ID__c];
        System.debug('++++++esc'+esc.size());
        if(esc.size()>0){
            if(esc[0].Checklist_expiration_date__c < system.today()){
                escid = esc[0].id;
                blnShowExportScreeningMsg = true;
                System.debug('++++escid'+ escid);
                return;
            }
        }
        
        
        
        
        // Checking for Export Screening Check-list (Country is not US and Checklist is not checked)
        if(quote.End_User_ID__c != null && quote.End_User_ID__r.Country__r.Name != 'United States' &&
           ![SELECT screening_checklist_completed__c FROm Account WHERE Id = :quote.End_User_ID__c].screening_checklist_completed__c)
        {
            blnShowExportScreeningMsg = true;
            return;
        }
        
        if(blnHasRequiredError)
            return;
        
        quote.BigMachines__Status__c = 'Order Submitted';
        quote.Order_Date_Submitted__c = Date.today();
        quote.Total_Maintenance_Amount_Due__c  = quote.Grand_Total__c;
        try
        {
            update quote;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote Could Not Be Updated : ' + ex.getMessage()));
            quote.BigMachines__Status__c = 'Quote Approved';
            quote.Order_Date_Submitted__c = null;
        }
    }
    
    // *** Method to Handle Upgrade of Products for example Product A to Product B across all lines
    public void upgradeProduct()
    {
        Boolean blnIsValueRequiredError = false;
        if(objFromProduct.BigMachines__Product__c == null) {
            objFromProduct.BigMachines__Product__c.addError('From : Value Required');
            blnIsValueRequiredError = true;
        }
        if(objToProduct.BigMachines__Product__c == null) {
            objToProduct.BigMachines__Product__c.addError('To : Value Required');
            blnIsValueRequiredError = true;
        }
        if(blnIsValueRequiredError)
            return;
        
        List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
        
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            if(obj.record.BigMachines__Product__c == objFromProduct.BigMachines__Product__c)
            {
                obj.record.BigMachines__Product__c = objToProduct.BigMachines__Product__c;
                obj.record.Is_Product_Upgraded__c = true;
                list_ToUpdate.add(obj.record);
            }
        }
        if(list_ToUpdate.size() > 0)
            update list_ToUpdate;
        
        // Maintaining History of product upgrades for this quote
        Quote_Products_Upgrade__c objProdUpgradeHistory = new Quote_Products_Upgrade__c
            (Quote__c = quote.Id,From__c = objFromProduct.BigMachines__Product__c,To__c = objToProduct.BigMachines__Product__c);
        insert objProdUpgradeHistory;
        
        // Blanking out From and To Products after upgrade is done
        objFromProduct.BigMachines__Product__c = null;
        objToProduct.BigMachines__Product__c = null;
        
        // Fetching Quote Products
        getQuoteProducts(quote.Id);
        // createCurrentPageList();
        
        // Fetching Quote Product Upgrades
        fetchQuoteProductUpgrades();
    }
    
    // *** Method to query Quote Product Upgrades ***
    private void fetchQuoteProductUpgrades()
    {
        list_ProductUpgrades = [SELECT From__c,To__c,From__r.Description,To__r.Description
                                FROM Quote_Products_Upgrade__c WHERE Quote__c = :quote.Id ORDER BY CreatedDate];
    }
    
    
    // *** Method to query and set-up Configuration products/lines ***
    private void fetchConfigurationProducts()
    {
        list_Fees = new List<BigMachines__Quote_Product__c>();
        list_FlexCare = new List<BigMachines__Quote_Product__c>();
        //objServiceLevel = new BigMachines__Quote_Product__c();
        list_ConfiguartionProducts = [SELECT Id,BigMachines__Product__r.Type__c,
                                      Product_Description__c,Original_Qty__c,Current_Qty__c,Maintenance_Start_Date__c,
                                      Maintenance_End_Date__c,BigMachines__Product__r.Genesys_Care_Quote__c,
                                      BigMachines__Product__r.Description,Sales_Price_Display__c,BigMachines__Sales_Price__c,
                                      BigMachines__Product__r.Care_Rate_Applicable__c
                                      FROM BigMachines__Quote_Product__c 
                                      WHERE BigMachines__Quote__c = :quote.Id AND 
                                      (BigMachines__Product__r.Genesys_Care_Quote__c = true
                                       OR BigMachines__Product__r.Type__c = 'Flex Care' OR
                                       BigMachines__Product__r.Type__c = 'Fees')];
        for(BigMachines__Quote_Product__c objQuoteProduct : list_ConfiguartionProducts)
        {
            // Checking for Fees : 'Extended End of Support' and 'Reinstatement'
            if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Fees')
            {
                //if(objQuoteProduct.BigMachines__Product__r.Description == 'Extended End of Support')
                if(objQuoteProduct.BigMachines__Product__r.Description == 'Flex Care-Extended Support(Partner)' || 
                   objQuoteProduct.BigMachines__Product__r.Description == 'Flex Care-Extended Support(End User)' ||
                   objQuoteProduct.BigMachines__Product__r.Description == 'Extended End of Support')
                {
                    blnHasExtendedEOSFee = true;
                }
                else if(objQuoteProduct.BigMachines__Product__r.Description == 'Reinstatement Fee')
                    blnHasReinstatementFee = true;
                
                list_Fees.add(objQuoteProduct);
            }
            else if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
                list_FlexCare.add(objQuoteProduct);
            else if(objQuoteProduct.BigMachines__Product__r.Genesys_Care_Quote__c)
                objServiceLevel = objQuoteProduct;
        }
        if(quote.Has_Extended_End_Of_Support__c)
            blnHasExtendedEOSFee = true;
        if(quote.Has_Reinstatement__c)
            blnHasReinstatementFee = true;
    }
    
    // *** Method to set Rates on Quote Products based on default care/increase rates on Quote Periods ***
    public void applyRates()
    {
        blnIsApplyRate = true;
        initializeRates();
        blnIsApplyRate = false;
        doCalculations();
    }
    
    // *** Method to initialize Rates on Quote Products (only for blank) based on default care/increase rates on Quote Periods ***
    public void initializeRates()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        if(intNumOfPeriods > 0)
        {
            for(QuoteProductWrapper obj : list_QuoteProducts)
            {
                // Genesys Care Model
                if(quote.Increase_type__c == 'Genesys Care Rate')
                {
                    if((obj.record.Genesys_Care_Rate__c == null || blnIsApplyRate) && intNumOfPeriods > 0)
                        obj.record.Genesys_Care_Rate__c = list_QuotePeriods[0].Default_Period_Care_Rate__c;
                    
                    //Period 2 to Period 5
                    for(Integer i=1; i<intNumOfPeriods ; i++)
                    {
                        Decimal decCareRate = (Decimal) obj.record.get('Year' + String.valueOf(i+1) + '_CareRatePercent__c');
                        if(decCareRate == null || blnIsApplyRate)
                            obj.record.put('Year' + String.valueOf(i+1) + '_CareRatePercent__c',list_QuotePeriods[i].Default_Period_Care_Rate__c);
                    }
                }
                // Increase Percentage Model
                else
                {
                    //Period 1 to Period 5
                    for(Integer i=0; i<intNumOfPeriods ; i++)
                    {
                        Decimal decIncreaseRate = (Decimal) obj.record.get('Year' + String.valueOf(i+1) + '_Increase__c');
                        if(decIncreaseRate == null || blnIsApplyRate)
                            obj.record.put('Year' + String.valueOf(i+1) + '_Increase__c',list_QuotePeriods[i].Default_Increase__c);
                    }
                }
            }
        }
    }   
    
    // *** Method to initialize Tax rate for some countries (Default tax rates stored on country records) ***
    // Japan and Brazil values set. Other countries can be set as required.
    // Also stores default care rate applicable
    public void initializeTaxAndDefaultCareRate()
    {
        if(quote.End_User_ID__c != null)
        {
            String strQuery = 'SELECT Country__r.Tax_Rate__c'; 
            
            //Adding the applicable care rate field to the query 
            if(objServiceLevel != null && objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c != null)
                strQuery += ',Country__r.' + objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c;
            
            strQuery += ' FROM Account WHERE Country__c != null AND Id = \'' + quote.End_User_ID__c + '\'';
            
            List<Account> list_Temp = Database.query(strQuery);
            if(list_Temp.size() > 0)
            {
                // Tax Rate
                if(quote.Tax_Rate__c == null)
                    quote.Tax_Rate__c = list_Temp[0].Country__r.Tax_Rate__c;
                // Default Care Rate
                if(objServiceLevel != null && objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c != null)
                    decDefaultCareRate = (Decimal) list_Temp[0].getSObject('Country__r').get(objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c);
            }
            // Japan does not have decimal place for currency
            if(quote.End_User_ID__r.Country__r.Name == 'Japan')
                quote.Hide_Truncate_Decimals__c = true;
        }
    }
    
    // *** Method to set all row check-boxes to true/false based on facet check-box
    public void checkUncheckAll()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
            obj.selected = blnIsHeaderChecked;
        
        // RAO - Added this line
        System.debug('880 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** Method to set Reinstatement to true/false based on facet check-box for all Quote Products
    public void checkUncheckAllReinstatement()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
            obj.record.Reinstatement__c = blnIsReinstatementForAll;
        
        // RAO - Added this line
        System.debug('890 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To set all override amount flags to true/false based on header flag/checkbox ***
    public void toggleOverrideAll()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        System.debug(' **** blnIsOverrideAll ' + blnIsOverrideAll);
        for(QuoteProductWrapper obj : list_QuoteProducts)
            obj.record.Amount_Due_Override__c = blnIsOverrideAll;
        
        // RAO - Added this line
        System.debug('910 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To set all override revised net flags to true/false based on header flag/checkbox ***
    public void toggleOverrideAllRevisedNet()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        System.debug(' **** blnIsOverrideAllRevisedNet ' + blnIsOverrideAllRevisedNet);
        for(QuoteProductWrapper obj : list_QuoteProducts)
            obj.record.Revised_Net_Override__c = blnIsOverrideAllRevisedNet;
        
        // RAO - Added this line
        System.debug('925 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To set all override previous annualized maintenance due flags to true/false based on header flag/checkbox ***
    public void toggleOverrideAllPreviousMaintenance()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        System.debug(' **** blnIsOverrideAllPreviousMaintenance ' + blnIsOverrideAllPreviousMaintenance);
        for(QuoteProductWrapper obj : list_QuoteProducts)
            obj.record.Previous_Line_Maintenance_Override__c = blnIsOverrideAllPreviousMaintenance;
        
        // RAO - Added this line
        System.debug('940 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To make selected lines applicable for LRA uplift ***
    public void applyLRAUpliftToLines()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            obj.record.Apply_LRA_Uplift__c = obj.selected ? true : obj.record.Apply_LRA_Uplift__c;
            obj.selected = false;
        }
        // RAO - Added this line
        System.debug('956 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To make selected lines not applicable for LRA uplift ***
    public void removeLRAUpliftFromLines()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            obj.record.Apply_LRA_Uplift__c = obj.selected ? false : obj.record.Apply_LRA_Uplift__c;
            obj.selected = false;
        }
        
        // RAO - Added this line
        System.debug('973 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To make selected lines applicable for revised net uplift ***
    public void applyRevisedNetUpliftToLines()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            obj.record.Apply_Revised_Net_Uplift__c = obj.selected ? true : obj.record.Apply_Revised_Net_Uplift__c;
            obj.selected = false;
        }
        // RAO - Added this line
        System.debug('989 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** To make selected lines not applicable for revised net uplift ***
    public void removeRevisedNetUpliftFromLines()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            obj.record.Apply_Revised_Net_Uplift__c = obj.selected ? false : obj.record.Apply_Revised_Net_Uplift__c;
            obj.selected = false;
        }
        
        // RAO - Added this line
        System.debug('1006 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** Save button handler : Saves Quote ***
    public PageReference save()
    {
        blnShowExportScreeningMsg = false;
        if(quoteId == null)
        {
            if(quote.Maintenance_Start_Date__c != null && quote.Maintenance_End_Date__c != null
               && quote.Maintenance_Start_Date__c > quote.Maintenance_End_Date__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote Start Date cannot be greater than Quote End Date.'));
                return null;
            }
            quote.BigMachines__Status__c = 'Quote In Progress';
            upsert quote;
            quote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quote.id].Quote_Number__c;
            update quote;
            // Create a quote period when quote is saved
            if(quote.Quote_Cloned_Revised__c == null && 
               quote.Maintenance_Start_Date__c != null && quote.Maintenance_End_Date__c != null)
            {
                Quote_Period__c objQuotePeriod = new Quote_Period__c();
                objQuotePeriod.Quote__c = quote.Id;
                objQuotePeriod.Start_Date__c = quote.Maintenance_Start_Date__c;
                objQuotePeriod.End_Date__c = quote.Maintenance_End_Date__c;
                insert objQuotePeriod;
            }
            
            // Redirect to Configuration Page when quote is first saved
            PageReference pg = new PageReference('/apex/ConfigurationPage?id='+quote.id);
            pg.setRedirect(true);
            return pg;
        }
        else
        {
            if(!getIsQuoteUnLocked())
            {
                if(quote.Revise_Minor__c)
                {
                    // if quote is in minor revise/revise comments mode then on save revert to old status
                    //quote.BigMachines__Status__c = quote.Status_Before_Revision__c;
                    // On save un-check revise minor flag
                    quote.Revise_Minor__c = false;
                    list_QuoteProductRecords = (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId));
                    if(list_QuoteProductRecords != null && list_QuoteProductRecords.size() > 0)
                        update list_QuoteProductRecords;
                }
                update quote;
                
                if(quote.Sent_to_Customer__c && quote.BigMachines__Opportunity__c != null)
                {
                    update (new Opportunity(Opportunity_Status__c = 'With Customer',Id = quote.BigMachines__Opportunity__c));
                }
            }
            else
            {
                doCalculations();
                // if there is an error stay on the page
                if(blnHasError)
                    return null;
            }
        }   
        PageReference pRef = new PageReference('/apex/CreateQuote?id=' + quote.id);
        pRef.setRedirect(true);
        return pRef;        
    } 
    
    //*** Method to refresh and sync selected quote products ***
    public void refreshSelected()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        synchSelected(list_QuoteProducts);
        
    }
    
    //*** Handler/Method for delete quote product button ***
    public void deleteQuoteProduct(){
        if(strToDelete == 'yes'){
            BigMachines__Quote_Product__c quoteProductToBeDeleted = new BigMachines__Quote_Product__c(id = quoteProductIdToBeDeleted);
            delete quoteProductToBeDeleted;
            // 8/5/2014 : To prevent deleted quote products from being re-imported from corresponding contract lines
            if(String.isNotBlank(strSCLIIdBeingDeleted)){
                List<ContractLineItem> list_CLI = [SELECT Id,Deleted_From_Quotes__c FROM ContractLineItem WHERE Id = :strSCLIIdBeingDeleted];
                String qId =  quote.Id;
                if(list_CLI.size() > 0){
                    list_CLI[0].Deleted_From_Quotes__c = String.isBlank(list_CLI[0].Deleted_From_Quotes__c) ? qId : list_CLI[0].Deleted_From_Quotes__c + ';' + qId;
                    try{
                        update list_CLI[0];
                    }
                    catch(Exception ex){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                    }
                }
            }
            getQuoteProducts(quote.id);
	        // createCurrentPageList();            
        }
    }
    
    // *** Method to return quote object ***
    public BigMachines__Quote__c getQuote(Id quoteId)
    {
        BigMachines__Quote__c quote;
        if(quoteId == null)
        {
            quote = new BigMachines__Quote__c();
            quote.Quote_Created_Date__c = System.today();
        }
        else
        {
            quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));
        }
        return quote;
    }
    
    public void getQuoteProducts(Id quoteId)
    {
        getQuoteProductsNoCache(quoteId);
        // RAO - Added this line
        if(!Test.isRunningTest()){
            System.debug('1128 list_QuoteProducts.size = ' + list_QuoteProducts.size());
            storeQuoteProducts();
        } 
        createCurrentPageList();
    }
    
    // *** Method to get Quote Products ***
    public void getQuoteProductsNoCache(Id quoteId)
    {
        invoicesELA = new Map<String, Boolean>();
        
        list_QuoteProductRecords = (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId));
        
        // Dynamically setting page size to control view state size
        Decimal decPageSizeDeterminer = list_QuoteProductRecords.size() * intNumOfPeriods;
        //if(decPageSizeDeterminer > 600)
        //    intPageSize = 50;
        
        Date dtEarliestStartDate = null;
        List<BigMachines__Quote_Product__c> list_Temp =  [SELECT Maintenance_Start_Date__c
                                                          FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :quote.Id 
                                                          AND Maintenance_Start_Date__c != null ORDER BY Maintenance_Start_Date__c LIMIT 1];
        if(list_Temp.size() > 0)
            dtEarliestStartDate = list_Temp[0].Maintenance_Start_Date__c;
        
        //intTotalNoOfRecords = list_QuoteProductRecords.size();
        list_QuoteProducts = new List<QuoteProductWrapper>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : list_QuoteProductRecords)
        {
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
            // ** RAO ** THE FOLLOWING IF CONDITION HAS BEEN ADDED FOR DROP/ REINSTATE ENHANCEMENT
            if(eachQuoteProduct.Service_Contract_Line__r.ServiceContract.Agreement_Status__c == 'Drop' 
               || eachQuoteProduct.Service_Contract_Line__r.ServiceContract.Agreement_Status__c == 'Downsize'
               || eachQuoteProduct.Service_Contract_Line__r.ServiceContract.Agreement_Status__c == 'Shelved'){
                   if(String.isBlank(eachQuoteProduct.Contract_Line_Update_Status__c))
                       eachQuoteProduct.Contract_Line_Update_Status__c = 'Reinstate';
               }
            
            wrapperRecord.record = eachQuoteProduct;
            list_QuoteProducts.add(wrapperRecord);
        }
        intTotalNoOfRecords = list_QuoteProducts.size();
        
        // Should not overwrite Maintenance Start Date with a null date in case there are no products
        if(dtEarliestStartDate != null)
            quote.Maintenance_Start_Date__c = dtEarliestStartDate;
        
        if(quote.Maintenance_Start_Date__c != null && quote.Maintenance_End_Date__c == null)
            quote.Maintenance_End_Date__c = quote.Maintenance_Start_Date__c.addYears(1) - 1;
        
        if(list_QuoteProducts.size() > 0)
            showQuoteLines = true;
        
        // Set up the Current Page Grid
        // createCurrentPageList();
    }
    
    //*** Sync the values of quote products selected to their contract line items ***
    public void synchSelected(List<QuoteProductWrapper> list_QuoteProducts)
    {
        Set<String> selectedIds = new Set<String>();
        Map<String, BigMachines__Quote_Product__c> mapContractLineIdVsQuoteProduct = new Map<String, BigMachines__Quote_Product__c>();
        for(QuoteProductWrapper eachRecord : list_QuoteProducts)
        {
            if(!eachRecord.selected)
                continue;
            // to check for quote products created from service contract lines
            if(eachRecord.record.Service_Contract_Line_ID__c != null && eachRecord.record.Service_Contract_Line_ID__c != '')
                selectedIds.add(eachRecord.record.Service_Contract_Line_ID__c);         
        }
        List<ContractLineItem> contLineItems = populateContractLineItemsByIds(selectedIds);
        Map<String, ContractLineItem> mapIdVsContractLineItem = new Map<String, ContractLineItem>();
        for(ContractLineItem eachCLI : contLineItems)
            mapIdVsContractLineItem.put(eachCLI.id, eachCLI);
        List<BigMachines__Quote_Product__c> list_QuoteProductsToBeUpdated = new List<BigMachines__Quote_Product__c>();  
        for(QuoteProductWrapper eachRecord : list_QuoteProducts)
        {
            if(!eachRecord.selected)
                continue;
            if(eachRecord.record.Service_Contract_Line_ID__c != null && eachRecord.record.Service_Contract_Line_ID__c != '')
            {
                // Quote dates should sync with date changes made on existing Co-Termed Service Contracts
                eachRecord.record = populateQuoteProduct(eachRecord.record, mapIdVsContractLineItem.get(eachRecord.record.Service_Contract_Line_ID__c),true);
                list_QuoteProductsToBeUpdated.add(eachRecord.record);
            }
        }
        if(!list_QuoteProductsToBeUpdated.isEmpty()) 
        {
            update list_QuoteProductsToBeUpdated;
            Date dtStartDateOnLoad = quote.Maintenance_Start_Date__c;
            // Getting quote products after quote products have been updated
            getQuoteProducts(quote.id);
	        // createCurrentPageList();            
            // if start date of quote has been changed by update of products then update quote
            if(dtStartDateOnLoad != quote.Maintenance_Start_Date__c)
                update quote;
            // Fetching Quote information
            quote = getQuote(quoteId);
        }
    }
    
    //*** Method to sync Quote Products ie create quote products from any newly added Quote Service Contracts ***
    public void syncQuoteProducts()
    {
        System.debug('1228 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        try
        {
            // products should not be synced until the quote is saved or if the quote is locked or for future quote or for FYM Quotes
            if(quote != null && quote.id != null && getIsQuoteUnLocked() && !quote.Is_FYM_Quote__c)
            {
                List<Quote_Service_Contracts__c> quoteServiceContracts = [SELECT Service_Contract__c 
                                                                          FROM Quote_Service_Contracts__c WHERE Quote__c =: quote.id FOR UPDATE];
                
                Set<String> setSCIds = new Set<String>();
                for(Quote_Service_Contracts__c eachQuoteSC : quoteServiceContracts)
                    setSCIds.add(eachQuoteSC.Service_Contract__c);
                
                List<ContractLineItem> contLineItems = populateContractLineItems(setSCIds);
                Map<Id,ContractLineItem> map_ContractLineIdToContract = new Map<Id,ContractLineItem>(contLineItems);
                List<BigMachines__Quote_Product__c> list_QuoteProductsToDelete = new List<BigMachines__Quote_Product__c>();
                
                List<BigMachines__Quote_Product__c> existinglist_QuoteProducts = [SELECT id, Service_Contract_Line_ID__c 
                                                                                  FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quote.id];
                Map<String,BigMachines__Quote_Product__c> mapContractLineIdVsQuoteProduct = 
                    new Map<String,BigMachines__Quote_Product__c>();
                for(BigMachines__Quote_Product__c eachQuoteProduct : existinglist_QuoteProducts)
                {
                    mapContractLineIdVsQuoteProduct.put(eachQuoteProduct.Service_Contract_Line_ID__c, eachQuoteProduct);
                    // Checking to see if the contract line id on quote product exists in cumulative list of Contract Line Ids for the quote
                    if(eachQuoteProduct.Service_Contract_Line_ID__c != null && eachQuoteProduct.Service_Contract_Line_ID__c != '' &&
                       !map_ContractLineIdToContract.containsKey(eachQuoteProduct.Service_Contract_Line_ID__c))
                        list_QuoteProductsToDelete.add(eachQuoteProduct);
                } 
                List<BigMachines__Quote_Product__c> list_QuoteProductsToBeInserted = new List<BigMachines__Quote_Product__c>();
                for(ContractLineItem eachCL : contLineItems)
                {                                   
                    if(mapContractLineIdVsQuoteProduct.get(eachCL.id) != null)
                        continue;
                    BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
                    newQuoteProduct.BigMachines__Quote__c = quote.id;
                    newQuoteProduct = populateQuoteProduct(newQuoteProduct, eachCL, false);
                    
                    // Commenting out code as start date is becoming greater than end date as we are not specifying end date on quote 
                    // Code uncommented as logic is required
                    if(newQuoteProduct.Maintenance_End_Date__c != null)
                        newQuoteProduct.Maintenance_Start_Date__c = newQuoteProduct.Maintenance_End_Date__c.addDays(1);
                    
                    // if the maintenance end date carried over is null then setting start date on line to quote start date
                    else
                        newQuoteProduct.Maintenance_Start_Date__c = quote.Maintenance_Start_Date__c;
                    
                    // All Quote Products should have the same Maintenance End Date as selected on the Quote
                    if(quote.Maintenance_End_Date__c != null)
                        newQuoteProduct.Maintenance_End_Date__c = quote.Maintenance_End_Date__c;
                    
                    list_QuoteProductsToBeInserted.add(newQuoteProduct);
                }
                if(list_QuoteProductsToBeInserted.size() > 0 || list_QuoteProductsToDelete.size() > 0)
                {
                    // To bypass quote product trigger
                    Util.Bypass_Trigger_Chk = true;
                    if(list_QuoteProductsToBeInserted.size() > 0)
                        insert list_QuoteProductsToBeInserted;
                    if(list_QuoteProductsToDelete.size() > 0)
                        delete list_QuoteProductsToDelete;
                    
                    Date dtStartDateOnLoad = quote.Maintenance_Start_Date__c;
                    // Getting quote products after new quote products have been created and/or existing ones deleted or un-co-termed
                    // getQuoteProducts(quote.id);
                    
                    // if start date of quote has been changed by update of products then update quote
                    if(dtStartDateOnLoad != quote.Maintenance_Start_Date__c)
                        update quote;
                    
                    // Fetching Quote information
                    quote = getQuote(quoteId);
                }
                
                /* if the Flex Care item end date is changed to a date beyond the end date of the quote, 
the end date of the quote should update (Flex Care Only Quotes).*/
                if(list_QuoteProducts.size() == 0 && list_FlexCare.size() > 0)
                {
                    Date dtEndDate = quote.Maintenance_End_Date__c;
                    for(BigMachines__Quote_Product__c objQuoteProduct : list_FlexCare)
                    {
                        if(dtEndDate == null || objQuoteProduct.Maintenance_End_Date__c > dtEndDate)
                            dtEndDate = objQuoteProduct.Maintenance_End_Date__c;
                    }
                    if(dtEndDate != quote.Maintenance_End_Date__c)
                    {
                        quote.Maintenance_End_Date__c = dtEndDate;
                        update quote;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            String strErrorMSg = ex.getMessage();
            if(strErrorMSg.contains('UNABLE_TO_LOCK_ROW'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to get a LOCK on data. Please reload page.'));
            else if(strErrorMSg.contains('Record Currently Unavailable'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Multiple Concurrent Attempts to access data. Please reload page.'));
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strErrorMSg));
        }
        
        // Getting quote products after new quote products have been created and/or existing ones deleted or un-co-termed
        if(quote != null && quote.id != null){
            getQuoteProducts(quote.id);
            // createCurrentPageList();
        }
        System.debug('1330 list_QuoteProducts.size = ' + list_QuoteProducts.size());
    }
    
    // *** Future Quote button handler : To create a future quote (start date is next day of current quote) ***
    public pageReference futureQuoteBtnHandler()
    {
        try
        {
            // To bypass quote product trigger
            Util.Bypass_Trigger_Chk = true;
            // Copying Quote
            BigMachines__Quote__c quoteCopy = new BigMachines__Quote__c();
            quoteCopy.BigMachines__Transaction_Id__c = null;
            quoteCopy.Quote_Created_Date__c = Date.today();
            // Default quote expiration after 3 months
            quoteCopy.Expiration_Date__c = Date.today().addMonths(3);
            quoteCopy.Is_Business_Primary__c = false;
            quoteCopy.BigMachines__Is_Primary__c = false;
            quoteCopy.Sent_to_Customer__c = false;
            quoteCopy.No_Revenue__c = quote.No_Revenue__c;
            quoteCopy.Sold_To_Name__c = quote.Sold_To_Name__c;
            quoteCopy.End_User_ID__c = quote.End_User_ID__c;
            // Quote Account should map to End User
            quote.BigMachines__Account__c = quote.End_User_ID__c;
            quoteCopy.BigMachines__Opportunity__c = quote.BigMachines__Opportunity__c;
            quoteCopy.CurrencyISOCode = quote.CurrencyISOCode;
            quoteCopy.Increase_type__c = quote.Increase_type__c;
            quoteCopy.Partner_Direct__c = quote.Partner_Direct__c;
            quoteCopy.Service_Level__c = quote.Service_Level__c;
            // Start date of future quote is next day of end date of current quote
            quoteCopy.Maintenance_Start_Date__c = quote.Maintenance_End_Date__c.addDays(1);
            quoteCopy.Future_Quote__c = true;
            quoteCopy.Quote_Cloned_Revised__c = quote.Id;
            quoteCopy.Increase_type__c = null;
            // Blanking out field so that new quotes have total fields in sync
            quoteCopy.Total_Maintenance_Amount_Due__c = null;
            quoteCopy.Total_Before_Tax_Maintenance__c = null;
            quoteCopy.Quote_Business_Type__c = 'Renewal';
            quoteCopy.Order_Type__c = 'Revenue';
            insert quoteCopy;
            
            System.debug('<<< ' + quoteCopy.Sold_To_Name__c);
            
            // Populate Quote Name and status
            quoteCopy = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quoteCopy.id];
            quoteCopy.Name = quoteCopy.Quote_Number__c;
            quoteCopy.BigMachines__Status__c = 'Quote In Progress';
            update quoteCopy;
            
            // Service Contract Line Items to be set deleted from Quote
            List<String> sclItemsToSetDeletedFromQuote = new List<String>(); 
            // Copying Quote Products
            String strQuoteProductsQuery = 'SELECT ';
            List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFields.getFields();
            for(Schema.FieldSetMember field : gridFields)
                strQuoteProductsQuery += field.getFieldPath() + ', ';
            strQuoteProductsQuery += 'BigMachines__Quantity__c,BigMachines__Product__r.Type__c,Period_Number__c, Service_Contract_Line__c';
            strQuoteProductsQuery += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quote.Id + '\'';
            List<BigMachines__Quote_Product__c> quoteProducts = (List<BigMachines__Quote_Product__c>)Database.query(strQuoteProductsQuery);
            List<BigMachines__Quote_Product__c> quoteProductsCopy = new List<BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts)
            {
                // Do not copy FlexCare or Fees lines
                if(eachQuoteProduct.BigMachines__Product__r.Type__c == 'Flex Care' || 
                   eachQuoteProduct.BigMachines__Product__r.Type__c == 'Fees')
                    continue;
                
                BigMachines__Quote_Product__c quoteProductCopy = eachQuoteProduct.clone(false, true);
                // Do copy completely dropped lines and set them deleted from Quote
                //if(eachQuoteProduct.Current_Qty__c == 0 || (String.isNotBlank(eachQuoteProduct.Contract_Line_Update_Status__c) && eachQuoteProduct.Current_Qty__c == eachQuoteProduct.Original_Qty__c)){
                if(String.isNotBlank(eachQuoteProduct.Contract_Line_Update_Status__c)){
                    if((eachQuoteProduct.Contract_Line_Update_Status__c == 'Drop' || eachQuoteProduct.Contract_Line_Update_Status__c == 'Retired') && eachQuoteProduct.Current_Qty__c == eachQuoteProduct.Original_Qty__c){
                        eachQuoteProduct.Comment__c = 'Full ' + eachQuoteProduct.Contract_Line_Update_Status__c + ' in previous quote';  
                        sclItemsToSetDeletedFromQuote.add(eachQuoteProduct.Service_Contract_Line__c);
                        System.debug('eachQuoteProduct.Service_Contract_Line__c = ' + eachQuoteProduct.Service_Contract_Line__c);
                    } else {
                        if(eachQuoteProduct.Current_Qty__c == eachQuoteProduct.Original_Qty__c)
                            eachQuoteProduct.Comment__c = 'Full ' + eachQuoteProduct.Contract_Line_Update_Status__c + ' in previous quote';  
                        else 
                            eachQuoteProduct.Comment__c = (eachQuoteProduct.Original_Qty__c - eachQuoteProduct.Current_Qty__c) + ' ' + eachQuoteProduct.Contract_Line_Update_Status__c + ' in previous quote';  
                    }
                }
                
                // Current Qty becomes Original Qty for future quote
                quoteProductCopy.Original_Qty__c = eachQuoteProduct.Current_Qty__c;
                // Current Revised Net becomes Original Net for future quote (Changed : should technically always match what 
                // is in the Original Net field of the service contract line items)
                //quoteProductCopy.Original_Net_License_Value__c = eachQuoteProduct.Revised_Net_License_Value__c;
                quoteProductCopy.BigMachines__Quote__c = quoteCopy.id;
                quoteProductCopy.BigMachines__External_Id__c  = null;
                // Product upgrades not to be carried over to future quote
                quoteProductCopy.Is_Product_Upgraded__c = false;
                // All lines should have the same start date as the quote for future quoting
                quoteProductCopy.Maintenance_Start_Date__c = quote.Maintenance_End_Date__c.addDays(1);
                quoteProductCopy.Maintenance_End_Date__c = null;
                // Since end date and quote periods are unknown Maintenance Due amounts should be blank
                quoteProductCopy.Maintenance_Due__c = null;
                quoteProductCopy.Year2_Maintenance_Due__c = null;
                quoteProductCopy.Year3_Maintenance_Due__c = null;
                quoteProductCopy.Year4_Maintenance_Due__c = null;
                quoteProductCopy.Year5_Maintenance_Due__c = null;
                // Since model is being blanked out rates too should be blank 
                quoteProductCopy.Genesys_Care_Rate__c = null;
                quoteProductCopy.Year2_CareRatePercent__c = null;
                quoteProductCopy.Year3_CareRatePercent__c = null;
                quoteProductCopy.Year4_CareRatePercent__c = null;
                quoteProductCopy.Year5_CareRatePercent__c = null;
                quoteProductCopy.Year1_Increase__c = null;
                quoteProductCopy.Year2_Increase__c = null;
                quoteProductCopy.Year3_Increase__c = null;
                quoteProductCopy.Year4_Increase__c = null;
                quoteProductCopy.Year5_Increase__c = null;
                
                // Setting internal field so that Revised Net is not is not calculated from Original Net for Future Quotes
                quoteProductCopy.Revised_Net_From_Contract_Line__c = eachQuoteProduct.Revised_Net_License_Value__c;
                
                //On future quote statuses of drop/split are cleared so user doesn't mistakenly drop split retire again.
                quoteProductCopy.Contract_Line_Update_Status__c = null;
                
                // Previous Maintenance on new quote =  Annualized Maintenance due on old quote (the most recent of the periods Annualized Maintenance)
                if(intNumOfPeriods > 0 && eachQuoteProduct.Maintenance_Start_Date__c != null)
                {
                    Quote_Period__c objPeriod = list_QuotePeriods[intNumOfPeriods - 1];
                    Date dtLaterDate = objPeriod.Start_Date__c >= eachQuoteProduct.Maintenance_Start_Date__c ? objPeriod.Start_Date__c : eachQuoteProduct.Maintenance_Start_Date__c;
                    Decimal decMonthsCalculated = Util.calculateDurationInMonths(dtLaterDate,quote.Maintenance_End_Date__c);
                    quoteProductCopy.Previous_Line_Maintenance_Value__c = 0;
                    if(decMonthsCalculated != null && decMonthsCalculated != 0)
                    {
                        Decimal decMaintDue = 0;
                        if(intNumOfPeriods == 1)
                            decMaintDue = eachQuoteProduct.Maintenance_Due__c;
                        else if(intNumOfPeriods >= 2 && intNumOfPeriods <= 5)
                            decMaintDue = (Decimal) eachQuoteProduct.get('Year' + String.valueOf(intNumOfPeriods) + '_Maintenance_Due__c');
                        
                        if(decMaintDue != null)
                            quoteProductCopy.Previous_Line_Maintenance_Value__c = decMaintDue * (12/decMonthsCalculated);
                    }
                }
                
                quoteProductsCopy.add(quoteProductCopy);
            }
            
            // Copying Quote Service Contracts
            List<Quote_Service_Contracts__c> quoteServicesContracts = [SELECT Service_Contract__c, Service_Contract_ID__c, Quote__c 
                                                                       FROM Quote_Service_Contracts__c WHERE Quote__c = :quote.id];
            List<Quote_Service_Contracts__c> quoteServicesContractsCopy = new List<Quote_Service_Contracts__c>();
            for(Quote_Service_Contracts__c eachQuoteServiceContract : quoteServicesContracts)
            {
                Quote_Service_Contracts__c newQSC = new Quote_Service_Contracts__c();
                if(eachQuoteServiceContract.Service_Contract__c == null)
                    continue;
                newQSC.Quote__c = quoteCopy.id;
                newQSC.Service_Contract__c = eachQuoteServiceContract.Service_Contract__c;
                newQSC.Service_Contract_ID__c = eachQuoteServiceContract.Service_Contract_ID__c;
                quoteServicesContractsCopy.add(newQSC);
            }
            
            insert quoteProductsCopy;
            insert quoteServicesContractsCopy;
            
            if(sclItemsToSetDeletedFromQuote.size() > 0){
                String qId =  quoteCopy.Id;
                List<ContractLineItem> sclItems = [SELECT id, Deleted_From_Quotes__c FROM ContractLineItem WHERE Id IN :sclItemsToSetDeletedFromQuote];					
                for(ContractLineItem cli : sclItems){
                    cli.Deleted_From_Quotes__c = String.isBlank(cli.Deleted_From_Quotes__c) ? qId : cli.Deleted_From_Quotes__c + ';' + qId;    
                }
                update sclItems;
            }
            
            
            PageReference pg = new PageReference('/apex/CreateQuote?id='+ quoteCopy.Id);
            pg.setRedirect(true);
            return pg;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }
    }
    
    // *** Clone button handler : To clone a Quote ***
    public pageReference cloneBtnHandler()
    {
        String cloneQuoteId = cloneQuote(false);            
        PageReference pg = new PageReference('/apex/CreateQuote?id='+cloneQuoteId);
        pg.setRedirect(true);
        return pg;
    }
    
    // *** Revise button handler : To revise a Quote ***
    public void reviseBtnHandler()
    {
        blnShowExportScreeningMsg = false;
        if(quote.BigMachines__Status__c == 'Quote Approval Pending')
        {
            List<ProcessInstance> existingApprovalForQuote = [SELECT Id,(SELECT Id FROM Workitems)
                                                              FROM ProcessInstance WHERE TargetObjectId = :quote.Id AND Status = 'Pending'];
            if(existingApprovalForQuote.size() > 0)
            {
                Boolean blnShowInfoToUser = false;
                for(ProcessInstanceWorkitem objWorkItem : existingApprovalForQuote[0].Workitems)
                {
                    Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                    PWR.setComments('Quote Revised : Approval Request Recalled');
                    PWR.setAction('Removed');
                    PWR.setWorkitemId(objWorkItem.Id);
                    Approval.ProcessResult result =  Approval.process(PWR);
                    blnShowInfoToUser = true;
                }
                if(blnShowInfoToUser)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Approval Request Recalled.'));
            }
        }
        quote.BigMachines__Status__c = 'Quote In Progress';
        // Clearing Split/Drop/Retired Status
        quote.Drop_Status__c = quote.Split_Status__c = quote.Retire_Status__c = quote.Downsize_Status__c = quote.Shelve_Status__c = false;
        // Clearing Approval Information
        quote.Approval_Submission_Date__c = null;
        quote.Approval_Date__c = null;
        // Remove Split/Drop Opportunities and Service Contracts if any
        List<Opportunity> list_ChildOpportunities = [SELECT Id FROM Opportunity WHERE Split_Parent_Quote__c = :quote.Id];
        List<ServiceContract> list_ServiceContracts = [SELECT Id FROM ServiceContract WHERE 
                                                       Renewal_Opportunity__c IN :list_ChildOpportunities];
        // Savepoint before DML
        Savepoint objSP = Database.setSavepoint();
        try
        {
            if(list_ServiceContracts.size() > 0)
                delete list_ServiceContracts;
            
            if(list_ChildOpportunities.size() > 0)
                delete list_ChildOpportunities; 
            
            update quote;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
            // Fetching Quote information
            quote = getQuote(quoteId);
        }
    }
    
    // *** Revise Major button handler : To revise a Quote (Creates a new quote with a different revision number)***
    public pageReference reviseMajorBtnHandler()
    {
        String newQuoteId = cloneQuote(true);
        PageReference pg = new PageReference('/apex/CreateQuote?id='+newQuoteId);
        pg.setRedirect(true);
        return pg;
    }
    
    // *** Revise Minor button handler : To make minor revision to a Quote ***
    public void reviseMinorBtnHandler()
    {
        //quote.BigMachines__Status__c = 'Revision Pending';
        blnShowExportScreeningMsg = false;
        quote.Revise_Minor__c = true;
        update quote;
    }
    
    // *** Performs Clone/Revise copying into a new quote ***
    public String cloneQuote(Boolean isRevise)
    {
        Util.Bypass_Trigger_Chk = true;
        // Copying Quote
        BigMachines__Quote__c quoteCopy = quote.clone(false, true);
        quoteCopy.BigMachines__Transaction_Id__c = null;
        quoteCopy.Quote_Created_Date__c = Date.today();
        // Default quote expiration after 3 months
        quoteCopy.Expiration_Date__c = Date.today().addMonths(3);
        quoteCopy.Is_Business_Primary__c = false;
        quoteCopy.BigMachines__Is_Primary__c = false;
        quoteCopy.Sent_to_Customer__c = false;
        quoteCopy.Quote_Cloned_Revised__c = quote.Id;
        //quoteCopy.Sold_To_Name__c = quote.Sold_To_Name__c;
        //quoteCopy.End_User_ID__c = quote.End_User_ID__c;
        // Blanking out field so that new quotes have total fields in sync
        quoteCopy.Total_Maintenance_Amount_Due__c = null;
        quoteCopy.Total_Before_Tax_Maintenance__c = null;
        quoteCopy.Quote_Business_Type__c = 'Renewal';
        quoteCopy.Order_Type__c = 'Revenue';
        
        // Approval and Order Submission related fields should be cleared while revising and cloning quotes
        quoteCopy.Approval_Date__c = null;
        quoteCopy.Approval_Submission_Date__c = null;
        quoteCopy.Order_Date_Submitted__c = null;
        quoteCopy.Order_PO_Number__c = null;
        quoteCopy.Order_PO_Date__c = null;
        
        // Drop/Split flags should be reset
        quoteCopy.Split_Status__c = false;
        quoteCopy.Drop_Status__c = false;
        quoteCopy.Downsize_Status__c = false;
        quoteCopy.Shelve_Status__c = false;
        
        // Quote Account should map to End User (explicitly copied : if cloned from a quote which has a blank value for account)
        quote.BigMachines__Account__c = quote.End_User_ID__c;
        
        insert quoteCopy;
        
        if(!isRevise)
        {
            quoteCopy = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: quoteCopy.id];
            quoteCopy.Name = quoteCopy.Quote_Number__c;
            quoteCopy.Revision_No__c = 1;
        }
        quoteCopy.BigMachines__Status__c = 'Quote In Progress';
        if(isRevise)
        {
            /*
if(quote.Revision_No__c == null)
quoteCopy.Revision_No__c = 2;
else
quoteCopy.Revision_No__c = quote.Revision_No__c + 1;
*/
            // Getting count of quotes with the same name to determine revision number
            quoteCopy.Revision_No__c = [SELECT COUNT() FROM BigMachines__Quote__c WHERE Name = :quoteCopy.Name];
        }            
        update quoteCopy;
        
        // Copying Quote Products
        String strQuoteProductsQuery = 'SELECT ';
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFields.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteProductsQuery += field.getFieldPath() + ', ';
        
        strQuoteProductsQuery += 'BigMachines__Quantity__c,Period_Number__c ';
        strQuoteProductsQuery += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quote.Id + '\'';
        List<BigMachines__Quote_Product__c> quoteProducts = (List<BigMachines__Quote_Product__c>)Database.query(strQuoteProductsQuery);
        List<BigMachines__Quote_Product__c> quoteProductsCopy = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts)
        {
            BigMachines__Quote_Product__c quoteProductCopy = eachQuoteProduct.clone(false, true);
            quoteProductCopy.BigMachines__Quote__c = quoteCopy.id;
            quoteProductCopy.BigMachines__External_Id__c  = null;
            // Setting internal field so that Revised Net is not is not calculated from Original Net for Clones and Revised Quotes
            if(quoteProductCopy.Revised_Net_From_Contract_Line__c == null)
                quoteProductCopy.Revised_Net_From_Contract_Line__c = quoteProductCopy.Revised_Net_License_Value__c;
            
            quoteProductsCopy.add(quoteProductCopy);
        }
        
        // Copying Quote Service Contracts
        List<Quote_Service_Contracts__c> quoteServicesContracts = [SELECT Service_Contract__c, Service_Contract_ID__c, Quote__c FROM Quote_Service_Contracts__c WHERE Quote__c =: quote.id];
        List<Quote_Service_Contracts__c> quoteServicesContractsCopy = new List<Quote_Service_Contracts__c>();
        for(Quote_Service_Contracts__c eachQuoteServiceContract : quoteServicesContracts)
        {
            Quote_Service_Contracts__c newQSC = new Quote_Service_Contracts__c();
            if(eachQuoteServiceContract.Service_Contract__c == null)
                continue;
            newQSC.Quote__c = quoteCopy.id;
            newQSC.Service_Contract__c = eachQuoteServiceContract.Service_Contract__c;
            newQSC.Service_Contract_ID__c = eachQuoteServiceContract.Service_Contract_ID__c;
            quoteServicesContractsCopy.add(newQSC);
        }
        
        // Copying Quote Periods    
        List<Quote_Period__c> quotePeriodsCopy = new List<Quote_Period__c>();
        for(Quote_Period__c eachQuotePeriod : list_QuotePeriods)
        {
            Quote_Period__c newQuotePeriod = eachQuotePeriod.clone(false, true);
            newQuotePeriod.Quote__c = quoteCopy.id;
            quotePeriodsCopy.add(newQuotePeriod);
        }
        
        // Copying Quote Product Upgrades
        List<Quote_Products_Upgrade__c> list_UpgradesCopy = new List<Quote_Products_Upgrade__c>();
        for(Quote_Products_Upgrade__c objProductUpgrade : list_ProductUpgrades)
        {
            Quote_Products_Upgrade__c objNewRecord = objProductUpgrade.clone(false, true);
            objNewRecord.Quote__c = quoteCopy.id;
            list_UpgradesCopy.add(objNewRecord);
        }
        
        insert quoteProductsCopy;
        //System.debug('<<<< After QL : ' + [SELECT Maintenance_End_Date__c FROM BigMachines__Quote__c WHERE id =: quoteCopy.id].Maintenance_End_Date__c);
        insert quoteServicesContractsCopy;
        //System.debug('<<<< After QSC : ' + [SELECT Maintenance_End_Date__c FROM BigMachines__Quote__c WHERE id =: quoteCopy.id].Maintenance_End_Date__c);
        insert quotePeriodsCopy;
        //System.debug('<<<< After QP : ' + [SELECT Maintenance_End_Date__c FROM BigMachines__Quote__c WHERE id =: quoteCopy.id].Maintenance_End_Date__c);
        insert list_UpgradesCopy;
        return quoteCopy.id;
    }
    
    // *** Method to return Contract Line Items using Service Contract Ids ***
    private List<ContractLineItem> populateContractLineItems(Set<String> setSCIds)
    {
        // Genesys Care products are to be excluded as we are creating separately thorough configuration tab
        // 8/5/2014 : GU lines should not be imported
        List<ContractLineItem> contLineItems = [SELECT Quantity, Upgraded_Product_Name__c, End_Support_Date__c, ListPrice, Original_Net_License_value__c, 
                                                Revised_Net_License_Value__c, Original_Quantity__c,Original_PO__c, Sales_Order__c,Original_License_Invoice_Date__c,Lic_Invoice__c,//Upd_Invoice_date__c,Upd_License_Invoice__c,
                                                Maintenance_Start_Date__c, Maintenance_End_Date__c, Service_Level__c, Maintenance_Amount__c, ServiceContractId, Previous_Line_Maintenance_Value__c, Id, Current_Quantity__c, 
                                                Sold_To_Name_Txt__c, End_User_Name_txt__c,CurrencyISOCode, UnitPrice, Material_Number__c, Product_Description__c,PriceBookEntry.Product2Id,Comments__c,
                                                // CAS fields (10/02/2015)
                                                Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partner__c,Application_Support_Cost_Base__c,Solution_Name__c,Third_Party_Partner_Fee__c
                                                FROM ContractLineItem WHERE ServiceContractId IN : setSCIds AND 
                                                PriceBookEntry.Product2.Type__c NOT IN ('Genesys Care','Flex Care','Fees','GU')
                                                // THE FOLLOWING CONDITION HAS BEEN ADDED BY RAO
                                                AND Current_Quantity__c > 0                                                 
                                                AND Deleted_From_Quotes__c EXCLUDES (:quote.Id)];
        return contLineItems;
    }
    
    // *** Method to return Contract Line Items using Line Ids ***
    private List<ContractLineItem> populateContractLineItemsByIds(Set<String> setSCLineIds)
    {
        // Genesys Care products are to be excluded as we are creating separately thorough configuration tab
        List<ContractLineItem> contLineItems = [SELECT Quantity, Upgraded_Product_Name__c, End_Support_Date__c, ListPrice, Original_Net_License_value__c, 
                                                Revised_Net_License_Value__c, Original_Quantity__c,Original_PO__c, Sales_Order__c,Original_License_Invoice_Date__c,Lic_Invoice__c,//Upd_Invoice_date__c,Upd_License_Invoice__c,
                                                Maintenance_Start_Date__c, Maintenance_End_Date__c, Service_Level__c, Maintenance_Amount__c, ServiceContractId, Previous_Line_Maintenance_Value__c, Id, Current_Quantity__c, 
                                                Sold_To_Name_Txt__c, End_User_Name_txt__c,CurrencyISOCode, UnitPrice, Material_Number__c, Product_Description__c,PriceBookEntry.Product2Id,Comments__c,
                                                // CAS fields (10/02/2015)
                                                Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partner__c,Application_Support_Cost_Base__c,Solution_Name__c,Third_Party_Partner_Fee__c
                                                FROM ContractLineItem WHERE id IN : setSCLineIds AND 
                                                PriceBookEntry.Product2.Type__c NOT IN ('Genesys Care','Flex Care','Fees','GU')
                                                AND Deleted_From_Quotes__c EXCLUDES (:quote.Id)];
        return contLineItems;
    }
    
    // *** Method to populate a quote product using Contract LineInformation ***
    private BigMachines__Quote_Product__c populateQuoteProduct(BigMachines__Quote_Product__c newQuoteProduct, ContractLineItem eachCL,Boolean blnDoNotCopyDateRange)
    {
        newQuoteProduct.BigMachines__Quantity__c = eachCL.Quantity;
        newQuoteProduct.End_Of_Support_Date__c = eachCL.End_Support_Date__c;
        newQuoteProduct.Original_Qty__c = eachCL.Original_Quantity__c;
        newQuoteProduct.Lic_Invoice__c = eachCL.Lic_Invoice__c;
        //newQuoteProduct.Lic_Invoice__c = eachCL.Upd_License_Invoice__c;
        newQuoteProduct.Original_PO__c = eachCL.Original_PO__c;
        newQuoteProduct.Sales_Order__c = eachCL.Sales_Order__c;
        newQuoteProduct.Original_License_Invoice_Date__c = eachCL.Original_License_Invoice_Date__c;
        //newQuoteProduct.Original_License_Invoice_Date__c = eachCL.Upd_Invoice_date__c;
        if(!blnDoNotCopyDateRange)
        {
            newQuoteProduct.Maintenance_Start_Date__c = eachCL.Maintenance_Start_Date__c;
            newQuoteProduct.Maintenance_End_Date__c = eachCL.Maintenance_End_Date__c;
        }
        else if(eachCL.Maintenance_End_Date__c != null)
            newQuoteProduct.Maintenance_Start_Date__c = eachCL.Maintenance_End_Date__c.addDays(1);
        
        //newQuoteProduct. = eachCL.Service_Level__c;
        newQuoteProduct.Service_Contract_Line_ID__c = eachCL.id;
        newQuoteProduct.Service_Contract_Line__c = eachCL.id;
        
        
        newQuoteProduct.Current_Qty__c = eachCL.Current_Quantity__c;
        newQuoteProduct.Sold_To_Name__c = eachCL.Sold_To_Name_Txt__c;
        newQuoteProduct.End_User_Name__c = eachCL.End_User_Name_txt__c;
        newQuoteProduct.CurrencyISOCode = quote.CurrencyISOCode;
        newQuoteProduct.Name = eachCL.Material_Number__c;
        newQuoteProduct.APN_Number__c = eachCL.Material_Number__c;
        newQuoteProduct.BigMachines__Description__c = eachCL.Product_Description__c;
        newQuoteProduct.BigMachines__Product__c = eachCL.PriceBookEntry.Product2Id;
        newQuoteProduct.Comment__c = eachCL.Comments__c;
        // CAS fields (10/02/2015)
        newQuoteProduct.Project_ID__c = eachCL.Project_ID__c;
        newQuoteProduct.Project_Name__c = eachCL.Project_Name__c;
        newQuoteProduct.Third_Party_Partners__c = eachCL.Third_Party_Partner__c;
        newQuoteProduct.Third_Party_Applications__c = eachCL.Third_Party_Applications__c;
        newQuoteProduct.Solution_Names_Covered__c = eachCL.Solution_Name__c;
        
        // if the contract line item and quote have same currency
        if(eachCL.CurrencyISOCode == quote.CurrencyISOCode || quote.No_Currency_Conversion__c)
        {
            newQuoteProduct.List_Price__c = eachCL.ListPrice;
            newQuoteProduct.Original_Net_License_Value__c = eachCL.Original_Net_License_value__c;
            newQuoteProduct.Revised_Net_License_Value__c = eachCL.Revised_Net_License_Value__c;
            // Storing Revised Net from Contract Line as this will be used to recompute Revised Net for Quote Line
            //newQuoteProduct.Maintenance_Due__c = eachCL.Maintenance_Amount__c;
            newQuoteProduct.Previous_Line_Maintenance_Value__c = eachCL.Previous_Line_Maintenance_Value__c;
            // Not Copying Sales Price as on output we use sales price field to display amount for configuration products
            //newQuoteProduct.BigMachines__Sales_Price__c = eachCL.UnitPrice;
            // Setting to 0 as it is a required field
            newQuoteProduct.BigMachines__Sales_Price__c = 0;
            // Earlier Original Net was being used as the base value to compute Revised Net
            newQuoteProduct.Revised_Net_From_Contract_Line__c = eachCL.Revised_Net_License_Value__c;
            // CAS fields (10/02/2015)
            newQuoteProduct.Third_Party_Partner_Fee__c = eachCL.Third_Party_Partner_Fee__c;
            newQuoteProduct.Application_Support_Cost_Base__c = eachCL.Application_Support_Cost_Base__c;
        }
        // else perform currency conversion then store values for currency fields
        else
        {
            newQuoteProduct.List_Price__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.ListPrice);
            newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Original_Net_License_value__c);
            newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Revised_Net_License_Value__c);
            //newQuoteProduct.Maintenance_Due__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Maintenance_Amount__c);
            newQuoteProduct.Previous_Line_Maintenance_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Previous_Line_Maintenance_Value__c);
            // Not Copying Sales Price as on output we use sales price field to display amount for configuration products
            //newQuoteProduct.BigMachines__Sales_Price__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.UnitPrice);
            // Setting to 0 as it is a required field
            newQuoteProduct.BigMachines__Sales_Price__c = 0;
            // Earlier Original Net was being used as the base value to compute Revised Net
            newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Revised_Net_License_Value__c);
            // CAS fields (10/02/2015)
            newQuoteProduct.Third_Party_Partner_Fee__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Third_Party_Partner_Fee__c);
            newQuoteProduct.Application_Support_Cost_Base__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Application_Support_Cost_Base__c);
        }
        
        return newQuoteProduct;
    }
    
    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId)
    {
        String strQuoteQuery = 'SELECT ';       
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> quoteFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Renewals.getFields();
        for(Schema.FieldSetMember field : quoteFields)
        {
            strQuoteQuery += field.getFieldPath() + ', ';
        }
        
        strQuoteQuery += ' End_User_ID__r.Country__r.Tax_Rate__c, End_User_ID__r.Country__r.Name,End_User_ID__r.screening_checklist_completed__c,Quote_Cloned_Revised__r.Name';     
        strQuoteQuery += ' FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuoteQuery;
    }
    
    // *** Method to generate query string to query Quote Products from the DB ***
    public String prepareQuoteProductQuery(Id quoteId)
    {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFields.getFields();
        for(Schema.FieldSetMember field : gridFields)
        {
            strQueryAllFields += field.getFieldPath() + ', ';
        }
        //strQueryAllFields += 'BigMachines__Product__r.Type__c,BigMachines__Product__r.Genesys_Care_Quote__c';
        //strQueryAllFields = strQueryAllFields.substring(0, strQueryAllFields.lastIndexOf(','));
        strQueryAllFields += 'Total_Invoice_Revise_Net__c,total_invoice_Maint__c,BigMachines__Product__r.Name,BigMachines__Product__r.End_of_Support__c,BigMachines__Product__r.End_of_Support_Date__c,';
        strQueryAllFields += 'BigMachines__Product__r.LRA_Uplift_Not_Applicable__c,BigMachines__Product__r.LDA_Uplift_Not_Applicable__c';
        // ** RAO ** THE FOLLOWING LINE IS ADDED FOR DROP/ REINSTATE ENHANCEMENT
        strQueryAllFields += ', Service_Contract_Line__r.ServiceContract.Agreement_Status__c';
        //strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Product__r.Type__c != \'Genesys Care\' AND BigMachines__Quote__c = \'' + quoteId + '\'';
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'';
        strQueryAllFields += ' AND BigMachines__Product__r.Genesys_Care_Quote__c = false';
        strQueryAllFields += ' AND BigMachines__Product__r.Type__c != \'Flex Care\'';
        strQueryAllFields += ' AND BigMachines__Product__r.Type__c != \'Fees\'';
        // ** RAO ** THE FOLLOWING LINE IS ADDED FOR DROP/ REINSTATE ENHANCEMENT
        strQueryAllFields += ' AND (Current_Qty__c > 0 OR Service_Contract_Line__r.Current_Quantity__c > 0)';
        
        //strQueryAllFields += ' AND Sales_Order__c != null';
        //strQueryAllFields += ' ORDER BY Sales_Order__c NULLS LAST,Original_License_Invoice_Date__c';
        // To Group By Lic_Invoice__c (Invoice Number)
        strQueryAllFields += ' ORDER BY Lic_Invoice__c NULLS LAST,Original_License_Invoice_Date__c,BigMachines__Product__r.Name, BigMachines__Product__r.Id';
        return strQueryAllFields;
    }
    
    // *** Method to return boolean whether record should be locked from editing or not ***
    public Boolean getIsQuoteUnLocked()
    {
        if(quote.BigMachines__Status__c == 'Quote Approval Pending' ||
           quote.BigMachines__Status__c == 'Quote Approved' ||
           quote.BigMachines__Status__c == 'Order Submitted' || 
           quote.BigMachines__Status__c == 'Revision Pending' ||
           quote.BigMachines__Status__c == 'Order Accepted' || 
           quote.BigMachines__Status__c == 'Order Rejected')
            return false;
        return true;
    }
    
    // *** Method to perform maintenance due calculations : Handler for Recalculate button ***
    public void doCalculations()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        blnHasError = false;
        Integer intCounter = 0;
        // Validations before values are computed and updated
        if(quote.Maintenance_Start_Date__c != null && quote.Maintenance_End_Date__c != null
           && quote.Maintenance_Start_Date__c > quote.Maintenance_End_Date__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Quote Start Date cannot be greater than Quote End Date.'));
            blnHasError = true;
            return;
        }
        // if there are quote lines and no quote periods
        if(list_QuoteProducts.size() > 0 && list_QuotePeriods.size() == 0)
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'At least one quote period needs to be defined on the quote.'));
            // Create Quote Period Automatically if no Quote Period exists
            applyQuotePeriod();
            if(intNumOfPeriods == 0)
            {
                blnHasError = true;
                return;
            }
        }
        // Reinstatement date should be within Quote Date Range
        /*
//Validation not be applied for Lump Sum Fees
if(blnHasReinstatementFee && 
(quote.Reinstated_Date__c < quote.Maintenance_Start_Date__c || quote.Reinstated_Date__c > quote.Maintenance_End_Date__c))*/
        if(quote.Has_Reinstatement__c && 
           (quote.Reinstated_Date__c < quote.Maintenance_Start_Date__c || quote.Reinstated_Date__c > quote.Maintenance_End_Date__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Reinstatement date is outside of the quote date range.'));
            blnHasError = true;
            return;
        }
        // 8/5/2014 : EOS date should be within Quote Date Range
        if(quote.Has_Extended_End_Of_Support__c && quote.Extended_End_of_Support_Date__c != null &&
           (quote.Extended_End_of_Support_Date__c < quote.Maintenance_Start_Date__c || quote.Extended_End_of_Support_Date__c > quote.Maintenance_End_Date__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Extended End Of Support date is outside of the quote date range.'));
            blnHasError = true;
            return;
        }
        
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            intCounter++;
            // LRA Uplift Validation
            if((obj.record.Contract_Line_Update_Status__c == 'Drop' || obj.record.Contract_Line_Update_Status__c == 'Retired')
               && quote.LRA_Uplift__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'LRA Uplift needs to be specified as there is one or more lines with \'Drop\' or \'Retired\' status.'));
                quote.LRA_Uplift__c.addError('Please Enter Value');
                blnHasError = true;
                return;
            }
            // LDA Uplift Validation
            if(obj.record.Contract_Line_Update_Status__c == 'Downsize' && quote.LDA_Uplift__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'LDA Uplift needs to be specified as there is one or more lines with \'Downsize\' status.'));
                quote.LDA_Uplift__c.addError('Please Enter Value');
                blnHasError = true;
                return;
            }
            // Current Quantity cannot exceed Original Quantity for Drop/Split/Retired/Shelved/Downsized
            if(String.isNotBlank(obj.record.Contract_Line_Update_Status__c) &&
               obj.record.Current_Qty__c > obj.record.Original_Qty__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(intCounter) + ' : Current Quantity cannot exceed Original Quantity for Drop/Split/Retired line.'));
                blnHasError = true;
                return;
            }
            // Quantity Reduced Without Any Status Selected Validation
            if(obj.record.Original_Qty__c != null && obj.record.Current_Qty__c != null &&
               obj.record.Current_Qty__c < obj.record.Original_Qty__c && String.isBlank(obj.record.Contract_Line_Update_Status__c))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(intCounter) + ' : Please select a value for Status as quantity has been reduced.'));
                blnHasError = true;
                return;
            }
            // Quantity cannot be 0 to prevent divide by zero error
            if(obj.record.Original_Qty__c == null || obj.record.Current_Qty__c == null ||
               obj.record.Original_Qty__c == 0.0 || obj.record.Current_Qty__c == 0.0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(intCounter) + ' : Original/Current Quantity cannot be left empty or be 0.'));
                blnHasError = true;
                return;
            }
            // Start Date need not necessarily fall in first quote period
            // Check if start date on line is greater than end date on last quote period/quote end date
            if(list_QuotePeriods.size() > 0 && obj.record.Maintenance_Start_Date__c != null &&
               list_QuotePeriods[intNumOfPeriods - 1].End_Date__c != null && 
               obj.record.Maintenance_Start_Date__c > list_QuotePeriods[intNumOfPeriods - 1].End_Date__c)
            {
                String strErrorMSg = ' : Line Start Date (' + obj.record.Maintenance_Start_Date__c.format() + ') greater than end of last quote period (' + list_QuotePeriods[intNumOfPeriods - 1].End_Date__c.format() + ').';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,String.valueOf(intCounter) + strErrorMSg));
                blnHasError = true;
                return;
            }
            
            /* Reinstatement % and Reinstated Date is required if there is even one product which is 
being Reinstated and Reinstatement Fee has been applied */
            //Validation not be applied for Lump Sum Fees
            if(obj.record.Reinstatement__c && quote.Has_Reinstatement__c &&
               (quote.Reinstatement__c == null || quote.Reinstated_Date__c == null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Reinstatement % and date need to be specified as there are one or more products being Reinstated.'));
                if(quote.Reinstatement__c == null)
                    quote.Reinstatement__c.addError('Please Enter Value');
                if(quote.Reinstated_Date__c == null)
                    quote.Reinstated_Date__c.addError('Please Enter Value');
                blnHasError = true;
                return;
            }
            
            // Extended End of Support % is required if there is even one product which has an Extended End of Support
            //Validation not be applied for Lump Sum Fees
            if(obj.record.Extended_End_of_Support__c && quote.Has_Extended_End_Of_Support__c && 
               quote.Extended_End_of_Support_Percent__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Extended End of Support % needs to be specified as there are one more products with extended end of support.'));
                quote.Extended_End_of_Support_Percent__c.addError('Please Enter Value');
                blnHasError = true;
                return;
            }
        }
        
        // Update Quote Periods if start date or end date on quote has changed
        adjustDatesOnPeriods();
        
        List<Decimal> list_DurationInMonthsStandard = new List<Decimal>();
        Decimal decTotalMonthsStandard = 0.0;
        // if a quote period range becomes negative after adjustment or ti handle anomalies where date ranges on periods are not consecutive
        // Store standard months as well
        for(Integer i=0; i< intNumOfPeriods ; i++)
        {
            if(list_QuotePeriods[i].Start_Date__c > list_QuotePeriods[i].End_Date__c)
            {
                blnHasError = true;
                String strErrorMsg = 'Period ' + (i+1) + ' : Start Date (' + list_QuotePeriods[i].Start_Date__c.format() + ') cannot be greater than End Date (' + list_QuotePeriods[i].End_Date__c.format() + ').';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strErrorMsg));
                return;
            }
            if(i < (intNumOfPeriods - 1))
            {
                Quote_Period__c objCurrentPeriod = list_QuotePeriods[i];
                Quote_Period__c objNextPeriod = list_QuotePeriods[i+1];
                if(objCurrentPeriod.End_Date__c.addDays(1) != objNextPeriod.Start_Date__c)
                {
                    blnHasError = true;
                    String strErrorMsg = 'Start Date of period ' + (i+2) + ' has to be the next day of the End Date of period ' + (i+1) + '.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strErrorMsg));
                    return;
                }
            }
            // Storing standard months so as to compute months only for lines where start date is different from period start date
            if(list_QuotePeriods[i].Months__c != null)
                list_DurationInMonthsStandard.add(list_QuotePeriods[i].Months__c);
            else
                list_DurationInMonthsStandard.add(0.0);
            
            decTotalMonthsStandard += list_DurationInMonthsStandard[i];
        }
        
        // Set Tax Rate and based on country and initialize default care rate based on service level and country    
        initializeTaxAndDefaultCareRate();
        
        intCounter = 0;     
        List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
        
        // Initializing Fee fields, Annual Increase/Decrease fields and Current Rate on Quote
        quote.Period1_P2P_Uplift_Fee__c = quote.Period2_P2P_Uplift_Fee__c = 
            quote.Period3_P2P_Uplift_Fee__c = quote.Period4_P2P_Uplift_Fee__c = quote.Period5_P2P_Uplift_Fee__c = 0.0;
        quote.Partner_to_Partner_Uplift__c = 0.0;
        
        quote.Period1_Quaterly_Semi_Annual_Fee__c = quote.Period2_Quaterly_Semi_Annual_Fee__c = 0.0;
        quote.Period3_Quaterly_Semi_Annual_Fee__c = quote.Period4_Quaterly_Semi_Annual_Fee__c = quote.Period5_Quaterly_Semi_Annual_Fee__c = 0.0;
        quote.Quarterly_Semi_Annual_Billing_Fee__c = 0.0;
        
        quote.Period1_Reinstatement_Fee__c = quote.Period2_Reinstatement_Fee__c = 0.0;
        quote.Period3_Reinstatement_Fee__c = quote.Period4_Reinstatement_Fee__c = quote.Period5_Reinstatement_Fee__c = 0.0;
        quote.Reinstatement_fee__c = 0.0;
        
        quote.Period1_EOS_Fee__c = quote.Period2_EOS_Fee__c = 0.0;
        quote.Period3_EOS_Fee__c = quote.Period4_EOS_Fee__c = quote.Period5_EOS_Fee__c = 0.0;
        quote.Extended_End_of_Support__c = 0.0;
        
        quote.Period1_Shelving_Fee__c = quote.Period2_Shelving_Fee__c = 0.0;
        quote.Period3_Shelving_Fee__c = quote.Period4_Shelving_Fee__c = quote.Period5_Shelving_Fee__c = 0.0;
        
        quote.Period1_KPI1_Amount__c = quote.Period2_KPI1_Amount__c = 0.0;
        quote.Period3_KPI1_Amount__c = quote.Period4_KPI1_Amount__c = quote.Period5_KPI1_Amount__c = 0.0;
        
        quote.Period1_KPI2_Amount__c = quote.Period2_KPI2_Amount__c = 0.0;
        quote.Period3_KPI2_Amount__c = quote.Period4_KPI2_Amount__c = quote.Period5_KPI2_Amount__c = 0.0;
        
        quote.Total_Increase__c = 0.0;
        quote.Total_Decrease_Split__c = 0.0;
        quote.Total_Decrease__c = 0.0;
        
        
        
        //Integer intNoOfRatesAdded = 0;
        //quote.Current_Maint_Rate__c = 0.0;
        blnHasADropOrSplitLine = false;
        Map<String,Decimal> map_InvNumToTotalRevisedNet = new Map<String,Decimal>();
        Map<String,Decimal> map_InvNumToTotalMaintDue = new Map<String,Decimal>();
        Decimal decTotalAnnualizedMaintDue = 0.0;
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            // Setting end date on lines to quote end date
            if(quote.Maintenance_End_Date__c != null)
                obj.record.Maintenance_End_Date__c = quote.Maintenance_End_Date__c;
            
            /*Line start date 4/1/2014  falls in this quote period so rate is 12.96 and end date is 12/31/2014 months are 7.
Now if line start date is 8/1/2014  it again falls in first quote period so 
the value for end date is 12/31/2014 but now months are 5.
Rest of years adjust fine,  it is only the first year will be the one where this need to adjust.
IF START DATE ON QUOTE IS DIFFERENT FROM START OF QUOTE PERIOD*/
            //Decimal decMonthsCalculatedForLine = 0;
            /*
if(intNumOfPeriods > 0)
{
if(list_QuotePeriods[0].Start_Date__c != obj.record.Maintenance_Start_Date__c)
decMonthsCalculatedForLine = Util.calculateDurationInMonths(obj.record.Maintenance_Start_Date__c,list_QuotePeriods[0].End_Date__c);
else
decMonthsCalculatedForLine = list_QuotePeriods[0].Months__c;
}*/
            
            // ************** Start : Quote Period Durations Applicable ************
            List<Decimal> list_DurationInMonths = new List<Decimal>();
            Decimal decTotalMonths = 0.0;
            obj.record.Start_Date_Flag__c = false;
            if(intNumOfPeriods > 0 && obj.record.Maintenance_Start_Date__c != null &&
               obj.record.Maintenance_Start_Date__c != list_QuotePeriods[0].Start_Date__c)
            {
                // Flag is set when Start Date on Line falls outside of initial quote period(s).
                if(obj.record.Maintenance_Start_Date__c > list_QuotePeriods[0].End_Date__c)
                    obj.record.Start_Date_Flag__c = true;
                
                for(Quote_Period__c objPeriod : list_QuotePeriods)
                {
                    // Checking to see which period does the start date on line fall in
                    if(obj.record.Maintenance_Start_Date__c >= objPeriod.Start_Date__c &&
                       obj.record.Maintenance_Start_Date__c <= objPeriod.End_Date__c)
                    {
                        Decimal decMonthsCalculated = Util.calculateDurationInMonths(obj.record.Maintenance_Start_Date__c,objPeriod.End_Date__c);
                        list_DurationInMonths.add(decMonthsCalculated);
                        decTotalMonths += decMonthsCalculated;
                    }
                    // start date falls after current quote period
                    else if(obj.record.Maintenance_Start_Date__c > objPeriod.End_Date__c)
                        list_DurationInMonths.add(0.0);
                    // subsequent quote periods after start date is matched to a quote period
                    else
                    {
                        list_DurationInMonths.add(objPeriod.Months__c);
                        decTotalMonths += objPeriod.Months__c;
                    }
                }
            }
            else
            {
                list_DurationInMonths = list_DurationInMonthsStandard;
                decTotalMonths = decTotalMonthsStandard;
            }
            // ************** End : Quote Period Durations Applicable ************
            
            // ************** Start : Reinstatement Applicable ************
            List<Decimal> list_ReinstatementDurationInMonths = new List<Decimal>();
            /*
//Calculations not be performed for Lump Sum Fees
if(blnHasReinstatementFee && obj.record.Reinstatement__c)*/
            if(quote.Has_Reinstatement__c && obj.record.Reinstatement__c)
            {
                for(Quote_Period__c objPeriod : list_QuotePeriods)
                {
                    // Checking to see which period does the start date on line fall in
                    if(obj.record.Maintenance_Start_Date__c >= objPeriod.Start_Date__c &&
                       obj.record.Maintenance_Start_Date__c <= objPeriod.End_Date__c)
                    {
                        if(obj.record.Maintenance_Start_Date__c <= quote.Reinstated_Date__c)
                        {
                            if(quote.Reinstated_Date__c > objPeriod.End_Date__c)
                                list_ReinstatementDurationInMonths.add(Util.calculateDurationInMonths(obj.record.Maintenance_Start_Date__c,objPeriod.End_Date__c));
                            
                            else
                                list_ReinstatementDurationInMonths.add(Util.calculateDurationInMonths(obj.record.Maintenance_Start_Date__c,quote.Reinstated_Date__c));
                        }
                        else
                            list_ReinstatementDurationInMonths.add(0.0);
                    }
                    // start date falls after current quote period
                    else if(obj.record.Maintenance_Start_Date__c > objPeriod.End_Date__c)
                        list_ReinstatementDurationInMonths.add(0.0);
                    // subsequent quote periods after start date is matched to a quote period
                    else
                    {
                        if(quote.Reinstated_Date__c > objPeriod.End_Date__c)
                            list_ReinstatementDurationInMonths.add(objPeriod.Months__c);
                        
                        else if(quote.Reinstated_Date__c >= objPeriod.Start_Date__c && quote.Reinstated_Date__c <= objPeriod.End_Date__c)
                            list_ReinstatementDurationInMonths.add(Util.calculateDurationInMonths(objPeriod.Start_Date__c,quote.Reinstated_Date__c));
                        
                        else
                            list_ReinstatementDurationInMonths.add(0.0);
                    }
                }
            }
            // ************** End : Reinstatement Applicable ************
            
            // ************** Start : EOS Applicable ************
            List<Decimal> list_EOSDurationInMonths = new List<Decimal>();
            Date dtProductEOS = obj.record.BigMachines__Product__r.End_of_Support_Date__c;
            //Calculations not be performed for Lump Sum Fees
            if(quote.Has_Extended_End_Of_Support__c && obj.record.Extended_End_of_Support__c && dtProductEOS != null)
            {
                for(Quote_Period__c objPeriod : list_QuotePeriods)
                {
                    /* 8/5/2014 : If Extended End Of Support date is specified at header level than end date should be 
that and not line end date(end date of last quote period).*/
                    Date dtEnd = objPeriod.End_Date__c;
                    if(quote.Extended_End_of_Support_Date__c != null)
                    {
                        if(objPeriod.Start_Date__c > quote.Extended_End_of_Support_Date__c ||
                           obj.record.Maintenance_Start_Date__c > quote.Extended_End_of_Support_Date__c ||
                           dtProductEOS > quote.Extended_End_of_Support_Date__c)
                        {
                            list_EOSDurationInMonths.add(0.0);
                            continue;
                        }
                        if(quote.Extended_End_of_Support_Date__c <= objPeriod.End_Date__c)
                            dtEnd = quote.Extended_End_of_Support_Date__c;
                    }
                    // Checking to see which period does the start date on line fall in
                    if(obj.record.Maintenance_Start_Date__c >= objPeriod.Start_Date__c &&
                       obj.record.Maintenance_Start_Date__c <= objPeriod.End_Date__c)
                    {
                        if(obj.record.Maintenance_Start_Date__c >= dtProductEOS)
                            list_EOSDurationInMonths.add(Util.calculateDurationInMonths(obj.record.Maintenance_Start_Date__c,dtEnd));
                        
                        else if(dtProductEOS > dtEnd)
                            list_EOSDurationInMonths.add(0.0);
                        
                        else
                            list_EOSDurationInMonths.add(Util.calculateDurationInMonths(dtProductEOS,dtEnd));
                    }
                    
                    // start date falls after current quote period
                    else if(obj.record.Maintenance_Start_Date__c > objPeriod.End_Date__c)
                        list_EOSDurationInMonths.add(0.0);
                    
                    // subsequent quote periods after start date is matched to a quote period
                    else
                    {
                        /*if(dtProductEOS >= objPeriod.Start_Date__c)
{
//list_EOSDurationInMonths.add(Util.calculateDurationInMonths(dtProductEOS,dtEnd));
list_EOSDurationInMonths.add(Util.calculateDurationInMonths(dtProductEOS,objPeriod.End_Date__c));
}

else
{
//list_EOSDurationInMonths.add(Util.calculateDurationInMonths(objPeriod.Start_Date__c,objPeriod.End_Date__c));
list_EOSDurationInMonths.add(Util.calculateDurationInMonths(objPeriod.Start_Date__c,dtEnd));
}*/
                        if(dtProductEOS > dtEnd)
                            list_EOSDurationInMonths.add(0.0);
                        
                        else if(dtProductEOS >= objPeriod.Start_Date__c && dtProductEOS <= dtEnd)
                            list_EOSDurationInMonths.add(Util.calculateDurationInMonths(dtProductEOS,dtEnd));
                        
                        else if(objPeriod.Start_Date__c >= dtProductEOS)
                            list_EOSDurationInMonths.add(Util.calculateDurationInMonths(objPeriod.Start_Date__c,dtEnd));
                        
                        else
                            list_EOSDurationInMonths.add(0.0);
                    }
                    //System.debug('<<< EOS ' + list_EOSDurationInMonths.size());
                }
            }
            // ************** End : EOS Applicable ************
            
            if(!blnHasADropOrSplitLine && 
               (obj.record.Contract_Line_Update_Status__c == 'Drop' || obj.record.Contract_Line_Update_Status__c == 'Split'))
                blnHasADropOrSplitLine = true;
            
            // Setting Original Net to zero if it is blank/null         
            if(obj.record.Original_Net_License_Value__c == null)
                obj.record.Original_Net_License_Value__c = 0;
            
            // Compute Revised Net only if it is not manually overridden and Original Net is not null and if the product has been created from a service contract
            if(!obj.record.Revised_Net_Override__c && String.isNotBlank(obj.record.Service_Contract_Line_ID__c))
            {
                Decimal decRevisedNetBaseValue;
                if(obj.record.Revised_Net_From_Contract_Line__c != null)
                    decRevisedNetBaseValue = obj.record.Revised_Net_From_Contract_Line__c;
                else if(obj.record.Original_Net_License_Value__c != null)
                    decRevisedNetBaseValue = obj.record.Original_Net_License_Value__c;
                else
                    decRevisedNetBaseValue = 0;
                
                // Bumping up the revised net by uplift %
                // Example : Revised Net = (Original Net) * ( (Current Qty) / (Original Qty) ) * (Increase %)
                // Increase % = (100 + LRA Uplift)/100
                // Re-Calculating Revised Net
                if(String.isNotBlank(obj.record.Contract_Line_Update_Status__c))
                {
                    // Revised Net should be zero if it's a complete drop
                    if(obj.record.Original_Qty__c == obj.record.Current_Qty__c && 
                       (obj.record.Contract_Line_Update_Status__c == 'Drop' || obj.record.Contract_Line_Update_Status__c == 'Split' || 
                        obj.record.Contract_Line_Update_Status__c == 'Retired' || obj.record.Contract_Line_Update_Status__c == 'Downsize'))
                    {
                        obj.record.Revised_Net_License_Value__c = 0;
                    }
                    else
                        obj.record.Revised_Net_License_Value__c = decRevisedNetBaseValue * (obj.record.Current_Qty__c/obj.record.Original_Qty__c);
                }  
                else
                    obj.record.Revised_Net_License_Value__c = decRevisedNetBaseValue;
                
                // if LRA Uplift is not being selectively applied or if line is selected for LRA Uplift
                if(!quote.Apply_LRA_Uplift_Selectively__c || (obj.record.Apply_LRA_Uplift__c))
                {
                    // Products like Custom App Support which are marked as LRA Uplift Not Applicable should be excluded
                    if(quote.LRA_Uplift__c != null && 
                       obj.record.BigMachines__Product__c != null &&
                       !obj.record.BigMachines__Product__r.LRA_Uplift_Not_Applicable__c)
                    {
                        obj.record.Revised_Net_License_Value__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                    }
                }
                
                if(quote.LDA_Uplift__c != null && obj.record.BigMachines__Product__c != null &&
                   !obj.record.BigMachines__Product__r.LDA_Uplift_Not_Applicable__c)
                {
                    obj.record.Revised_Net_License_Value__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                }
                
                // Update Revised Net if Partner Direct % value is available (post any revisions due to 'Drop' status)
                // Partner Direct has been renamed to Revised Net Uplift %
                // if Revised Net Uplift is not being selectively applied or if line is selected for Revised Net Uplift
                if(!quote.Apply_Revised_Net_Uplift_Selectively__c || (obj.record.Apply_Revised_Net_Uplift__c))
                {
                    if(obj.record.Revised_Net_License_Value__c != null && 
                       quote.Partner_Direct__c != null &&
                       quote.Partner_Direct__c != 0.0)
                    {
                        obj.record.Revised_Net_License_Value__c *= ((100.0 + quote.Partner_Direct__c)/100.0);
                    }
                }
            }
            
            // Compute Maintenance Due only if it is not manually overridden
            if(!obj.record.Amount_Due_Override__c)
            {
                obj.record.Maintenance_Due__c = obj.record.Year2_Maintenance_Due__c = 0.0;
                obj.record.Year3_Maintenance_Due__c = obj.record.Year4_Maintenance_Due__c = obj.record.Year5_Maintenance_Due__c = 0.0;
                
                obj.record.Period1_Reinstatement_Fee__c = obj.record.Period2_Reinstatement_Fee__c = 0.0;
                obj.record.Period3_Reinstatement_Fee__c = obj.record.Period4_Reinstatement_Fee__c = obj.record.Period5_Reinstatement_Fee__c = 0.0;
                
                obj.record.Period1_EOS_Fee__c = obj.record.Period2_EOS_Fee__c = 0.0;
                obj.record.Period3_EOS_Fee__c = obj.record.Period4_EOS_Fee__c = obj.record.Period5_EOS_Fee__c = 0.0;
                
                obj.record.Period1_Shelving_Fee__c = obj.record.Period2_Shelving_Fee__c = 0.0;
                obj.record.Period3_Shelving_Fee__c = obj.record.Period4_Shelving_Fee__c = obj.record.Period5_Shelving_Fee__c = 0.0;
                
                obj.record.Period1_KPI1_Amount__c = obj.record.Period2_KPI1_Amount__c = 0.0;
                obj.record.Period3_KPI1_Amount__c = obj.record.Period4_KPI1_Amount__c = obj.record.Period5_KPI1_Amount__c = 0.0;
                
                obj.record.Period1_KPI2_Amount__c = obj.record.Period2_KPI2_Amount__c = 0.0;
                obj.record.Period3_KPI2_Amount__c = obj.record.Period4_KPI2_Amount__c = obj.record.Period5_KPI2_Amount__c = 0.0;
                
                /* If Original Qty = Current Qty and Status is drop/split/retired that means customer is dropping the whole product.  
In that case Maintenance Due will be 0 because customer dropped it. */
                if(!((obj.record.Contract_Line_Update_Status__c == 'Drop' || obj.record.Contract_Line_Update_Status__c == 'Split' || 
                      obj.record.Contract_Line_Update_Status__c == 'Retired' || obj.record.Contract_Line_Update_Status__c == 'Downsize')
                     && obj.record.Original_Qty__c == obj.record.Current_Qty__c))
                {
                    // Maintenance Due for a period = (Revised Net per month) * (No. of months in period)
                    // Genesys Care Rate Model
                    if(quote.Increase_type__c == 'Genesys Care Rate' && obj.record.Revised_Net_License_Value__c != null)
                    {
                        Decimal decRevisedNet = obj.record.Revised_Net_License_Value__c;
                        
                        // Period 1
                        if(obj.record.Genesys_Care_Rate__c != null && intNumOfPeriods > 0 && list_DurationInMonths[0] != null)
                        {           
                            Decimal decRevisedNetPM = ( decRevisedNet * obj.record.Genesys_Care_Rate__c / 100.0 ) / 12;
                            obj.record.Maintenance_Due__c = decRevisedNetPM * list_DurationInMonths[0];
                            
                            // Reinstatement : Calculations not be performed for Lump Sum Fees
                            if(quote.Has_Reinstatement__c && obj.record.Reinstatement__c && list_ReinstatementDurationInMonths[0] != null)
                            {
                                obj.record.Period1_Reinstatement_Fee__c = decRevisedNetPM * list_ReinstatementDurationInMonths[0] * (quote.Reinstatement__c / 100.0);
                                quote.Period1_Reinstatement_Fee__c += obj.record.Period1_Reinstatement_Fee__c;
                            }
                            
                            // EOS : Calculations not be performed for Lump Sum Fees
                            if(quote.Has_Extended_End_Of_Support__c && obj.record.Extended_End_of_Support__c && 
                               dtProductEOS != null && list_EOSDurationInMonths[0] != null)
                            {
                                obj.record.Period1_EOS_Fee__c = decRevisedNetPM * list_EOSDurationInMonths[0] * (quote.Extended_End_of_Support_Percent__c / 100.0);
                                quote.Period1_EOS_Fee__c += obj.record.Period1_EOS_Fee__c;
                            }
                            
                            // Shelving : 50% of Maintenance Due
                            if(obj.record.Contract_Line_Update_Status__c == 'Shelved')
                            {
                                if(obj.record.Original_Qty__c == obj.record.Current_Qty__c)
                                {
                                    obj.record.Period1_Shelving_Fee__c = obj.record.Maintenance_Due__c * 0.5;
                                    obj.record.Maintenance_Due__c = 0;
                                }
                                
                                /* If partial seats are Shelved for example out of 100/50 are renewed but other 50 are Shelved (Just like we do drop)  
then calculate the Total Maintenance on what is shelved and take 50% of it. */
                                else
                                {
                                    obj.record.Period1_Shelving_Fee__c = obj.record.Maintenance_Due__c * 
                                        (obj.record.Original_Qty__c/obj.record.Current_Qty__c) * 
                                        ((obj.record.Original_Qty__c - obj.record.Current_Qty__c)/obj.record.Original_Qty__c) * 0.5;
                                }
                                quote.Period1_Shelving_Fee__c += obj.record.Period1_Shelving_Fee__c;
                            }
                            
                            // KPIs
                            if(list_QuotePeriods[0].KPI1__c != null)
                            {
                                if(quote.Calculate_KPI_Using_Maintenance_Due__c)
                                    obj.record.Period1_KPI1_Amount__c = obj.record.Maintenance_Due__c * (list_QuotePeriods[0].KPI1__c/100);
                                else
                                    obj.record.Period1_KPI1_Amount__c = decRevisedNet * (list_QuotePeriods[0].KPI1__c/100) * (list_DurationInMonths[0]/12);
                                
                                quote.Period1_KPI1_Amount__c += obj.record.Period1_KPI1_Amount__c;
                            }
                            if(list_QuotePeriods[0].KPI2__c != null)
                            {
                                if(quote.Calculate_KPI_Using_Maintenance_Due__c)
                                    obj.record.Period1_KPI2_Amount__c = obj.record.Maintenance_Due__c * (list_QuotePeriods[0].KPI2__c/100);
                                else
                                    obj.record.Period1_KPI2_Amount__c = decRevisedNet * (list_QuotePeriods[0].KPI2__c/100) * (list_DurationInMonths[0]/12);
                                
                                quote.Period1_KPI2_Amount__c += obj.record.Period1_KPI2_Amount__c;
                            }
                        }
                        // Period 2 to Period 5
                        for(Integer i=1; i<intNumOfPeriods ; i++)
                        {
                            String strIndex = String.valueOf(i+1);
                            Decimal decCareRate = (Decimal) obj.record.get('Year' + strIndex + '_CareRatePercent__c');
                            if(decCareRate != null && list_DurationInMonths[i] != null)
                            {           
                                Decimal decRevisedNetPM = ( decRevisedNet * decCareRate / 100.0 ) / 12;
                                obj.record.put('Year' + strIndex + '_Maintenance_Due__c',decRevisedNetPM * list_DurationInMonths[i]);
                                
                                // Reinstatement : Calculations not be performed for Lump Sum Fees
                                if(quote.Has_Reinstatement__c && obj.record.Reinstatement__c && list_ReinstatementDurationInMonths[i] != null)
                                {
                                    obj.record.put('Period' + strIndex + '_Reinstatement_Fee__c',decRevisedNetPM * list_ReinstatementDurationInMonths[i] * (quote.Reinstatement__c / 100.0));
                                    quote.put('Period' + strIndex + '_Reinstatement_Fee__c', ((Decimal)quote.get('Period' + strIndex + '_Reinstatement_Fee__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_Reinstatement_Fee__c')));
                                }
                                
                                // EOS : Calculations not be performed for Lump Sum Fees
                                if(quote.Has_Extended_End_Of_Support__c && obj.record.Extended_End_of_Support__c && 
                                   dtProductEOS != null && list_EOSDurationInMonths[i] != null)
                                {
                                    obj.record.put('Period' + strIndex + '_EOS_Fee__c',decRevisedNetPM * list_EOSDurationInMonths[i] * (quote.Extended_End_of_Support_Percent__c / 100.0));
                                    quote.put('Period' + strIndex + '_EOS_Fee__c', ((Decimal)quote.get('Period' + strIndex + '_EOS_Fee__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_EOS_Fee__c')));
                                }
                                
                                // Shelving : 50% of Maintenance Due
                                if(obj.record.Contract_Line_Update_Status__c == 'Shelved')
                                {
                                    if(obj.record.Original_Qty__c == obj.record.Current_Qty__c)
                                    {
                                        obj.record.put('Period' + strIndex + '_Shelving_Fee__c', (Decimal)obj.record.get('Year' + strIndex + '_Maintenance_Due__c') * 0.5);
                                        obj.record.put('Year' + strIndex + '_Maintenance_Due__c',0);
                                    }
                                    else
                                    {
                                        obj.record.put('Period' + strIndex + '_Shelving_Fee__c', 
                                                       (Decimal)obj.record.get('Year' + strIndex + '_Maintenance_Due__c')* 
                                                       (obj.record.Original_Qty__c/obj.record.Current_Qty__c) * 
                                                       ((obj.record.Original_Qty__c - obj.record.Current_Qty__c)/obj.record.Original_Qty__c) * 0.5);
                                    }
                                    quote.put('Period' + strIndex + '_Shelving_Fee__c', ((Decimal)quote.get('Period' + strIndex + '_Shelving_Fee__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_Shelving_Fee__c')));
                                }
                                
                                // KPIs
                                if(list_QuotePeriods[i].KPI1__c != null)
                                {
                                    if(quote.Calculate_KPI_Using_Maintenance_Due__c)
                                        obj.record.put('Period' + strIndex + '_KPI1_Amount__c',((Decimal)obj.record.get('Year' + strIndex + '_Maintenance_Due__c')) * (list_QuotePeriods[i].KPI1__c/100));
                                    else
                                        obj.record.put('Period' + strIndex + '_KPI1_Amount__c',decRevisedNet * (list_QuotePeriods[i].KPI1__c/100) * (list_DurationInMonths[i]/12));
                                    
                                    quote.put('Period' + strIndex + '_KPI1_Amount__c', ((Decimal)quote.get('Period' + strIndex + '_KPI1_Amount__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_KPI1_Amount__c')));
                                }
                                if(list_QuotePeriods[i].KPI2__c != null)
                                {
                                    if(quote.Calculate_KPI_Using_Maintenance_Due__c)
                                        obj.record.put('Period' + strIndex + '_KPI2_Amount__c',((Decimal)obj.record.get('Year' + strIndex + '_Maintenance_Due__c')) * (list_QuotePeriods[i].KPI2__c/100));
                                    else
                                        obj.record.put('Period' + strIndex + '_KPI2_Amount__c',decRevisedNet * (list_QuotePeriods[i].KPI2__c/100) * (list_DurationInMonths[i]/12));
                                    
                                    quote.put('Period' + strIndex + '_KPI2_Amount__c', ((Decimal)quote.get('Period' + strIndex + '_KPI2_Amount__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_KPI2_Amount__c')));
                                }
                            }
                        }
                    }
                    // Increased Percentage Model
                    else if(quote.Increase_type__c != 'Genesys Care Rate' && 
                            obj.record.Original_Qty__c != 0.0 &&
                            obj.record.Original_Qty__c != null && obj.record.Current_Qty__c != null &&
                            obj.record.Previous_Line_Maintenance_Value__c != null)
                    {
                        //Decimal decPreviousMaintenance = obj.record.Previous_Line_Maintenance_Value__c;
                        //Decimal decQuantityRatio = obj.record.Current_Qty__c/obj.record.Original_Qty__c;
                        Decimal decRevisedNet = obj.record.Revised_Net_License_Value__c;
                        Decimal decEffectiveAmount = obj.record.Previous_Line_Maintenance_Value__c * (obj.record.Current_Qty__c/obj.record.Original_Qty__c);
                        // Period 1
                        if(obj.record.Year1_Increase__c != null && intNumOfPeriods > 0 && 
                           list_DurationInMonths[0] != null && list_DurationInMonths[0] != 0)
                        {           
                            //obj.record.Maintenance_Due__c = decEffectiveAmount + ( decEffectiveAmount * (obj.record.Year1_Increase__c / 100.0) * (list_DurationInMonths[0]/12));
                            // Formula changed to prorate effective amount as well along with the increase amount
                            obj.record.Maintenance_Due__c = decEffectiveAmount * (1 + (obj.record.Year1_Increase__c / 100.0)) * (list_DurationInMonths[0]/12);
                            
                            // KPIs
                            if(list_QuotePeriods[0].KPI1__c != null )
                                obj.record.Period1_KPI1_Amount__c = decRevisedNet * (list_QuotePeriods[0].KPI1__c/100) * (list_DurationInMonths[0]/12);
                            // obj.record.Period1_KPI1_Amount__c = decEffectiveAmount * (list_QuotePeriods[0].KPI1__c/100) * (list_DurationInMonths[0]/12);
                            
                            if(list_QuotePeriods[0].KPI2__c != null )
                                obj.record.Period1_KPI2_Amount__c = decRevisedNet * (list_QuotePeriods[0].KPI2__c/100) * (list_DurationInMonths[0]/12);
                            // obj.record.Period1_KPI2_Amount__c = decEffectiveAmount * (list_QuotePeriods[0].KPI2__c/100) * (list_DurationInMonths[0]/12);
                            
                            // Annualizing
                            decEffectiveAmount = obj.record.Maintenance_Due__c * (12/list_DurationInMonths[0]);
                            
                            // if LRA Uplift is not being selectively applied or if line is selected for LRA Uplift
                            if(!quote.Apply_LRA_Uplift_Selectively__c || (obj.record.Apply_LRA_Uplift__c))
                            {
                                // Products like Custom App Support which are marked as LRA Uplift Not Applicable should be excluded
                                if(quote.LRA_Uplift__c != null && 
                                   obj.record.BigMachines__Product__c != null &&
                                   !obj.record.BigMachines__Product__r.LRA_Uplift_Not_Applicable__c)
                                {
                                    obj.record.Maintenance_Due__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                                    obj.record.Period1_KPI1_Amount__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                                    obj.record.Period1_KPI2_Amount__c *= ((100.0 + quote.LRA_Uplift__c)/100.0);
                                }
                            }
                            
                            if(quote.LDA_Uplift__c != null && obj.record.BigMachines__Product__c != null &&
                               !obj.record.BigMachines__Product__r.LDA_Uplift_Not_Applicable__c)
                            {
                                obj.record.Maintenance_Due__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                                obj.record.Period1_KPI1_Amount__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                                obj.record.Period1_KPI2_Amount__c *= ((100.0 + quote.LDA_Uplift__c)/100.0);
                            }
                            
                            quote.Period1_KPI1_Amount__c += obj.record.Period1_KPI1_Amount__c;
                            quote.Period1_KPI2_Amount__c += obj.record.Period1_KPI2_Amount__c;
                            
                            // Reinstatement : Calculations not be performed for Lump Sum Fees
                            if(quote.Has_Reinstatement__c && obj.record.Reinstatement__c && list_ReinstatementDurationInMonths[0] != null)
                            {
                                obj.record.Period1_Reinstatement_Fee__c = (obj.record.Maintenance_Due__c/list_DurationInMonths[0]) * list_ReinstatementDurationInMonths[0] * (quote.Reinstatement__c / 100.0);
                                quote.Period1_Reinstatement_Fee__c += obj.record.Period1_Reinstatement_Fee__c;
                            }
                            
                            // EOS : Calculations not be performed for Lump Sum Fees
                            if(quote.Has_Extended_End_Of_Support__c && obj.record.Extended_End_of_Support__c && 
                               dtProductEOS != null && list_EOSDurationInMonths[0] != null)
                            {
                                obj.record.Period1_EOS_Fee__c = (obj.record.Maintenance_Due__c/list_DurationInMonths[0]) * list_EOSDurationInMonths[0] * (quote.Extended_End_of_Support_Percent__c / 100.0);
                                quote.Period1_EOS_Fee__c += obj.record.Period1_EOS_Fee__c;
                            }
                            
                            // Shelving : 50% of Maintenance Due
                            if(obj.record.Contract_Line_Update_Status__c == 'Shelved')
                            {
                                if(obj.record.Original_Qty__c == obj.record.Current_Qty__c)
                                {
                                    obj.record.Period1_Shelving_Fee__c = obj.record.Maintenance_Due__c * 0.5;
                                    obj.record.Maintenance_Due__c = 0;
                                }
                                
                                /* If partial seats are Shelved for example out of 100/50 are renewed but other 50 are Shelved (Just like we do drop)  
then calculate the Total Maintenance on what is shelved and take 50% of it. */
                                else
                                {
                                    obj.record.Period1_Shelving_Fee__c = obj.record.Maintenance_Due__c * 
                                        (obj.record.Original_Qty__c/obj.record.Current_Qty__c) * 
                                        ((obj.record.Original_Qty__c - obj.record.Current_Qty__c)/obj.record.Original_Qty__c) * 0.5;
                                }
                                quote.Period1_Shelving_Fee__c += obj.record.Period1_Shelving_Fee__c;
                            }
                        }
                        // Period 2 to Period 5
                        for(Integer i=1; i<intNumOfPeriods ; i++)
                        {
                            String strIndex = String.valueOf(i+1);
                            Decimal decIncreaseRate = (Decimal) obj.record.get('Year' + strIndex + '_Increase__c');
                            if(decIncreaseRate != null && list_DurationInMonths[i] != null && list_DurationInMonths[i] != 0)
                            {           
                                //obj.record.put('Year' + String.valueOf(i+1) + '_Maintenance_Due__c',decEffectiveAmount + ( decEffectiveAmount * (decIncreaseRate / 100.0) * (list_DurationInMonths[i]/12)));
                                // Formula changed to prorate effective amount as well along with the increase amount
                                obj.record.put('Year' + strIndex + '_Maintenance_Due__c',decEffectiveAmount * ( 1 + (decIncreaseRate / 100.0)) * (list_DurationInMonths[i]/12));
                                
                                // KPIs
                                if(list_QuotePeriods[i].KPI1__c != null)
                                {
                                    obj.record.put('Period' + strIndex + '_KPI1_Amount__c',decRevisedNet * (list_QuotePeriods[i].KPI1__c/100) * (list_DurationInMonths[i]/12));
                                    //obj.record.put('Period' + strIndex + '_KPI1_Amount__c',decEffectiveAmount * (list_QuotePeriods[i].KPI1__c/100) * (list_DurationInMonths[i]/12));
                                }
                                if(list_QuotePeriods[i].KPI2__c != null)
                                {
                                    obj.record.put('Period' + strIndex + '_KPI2_Amount__c',decRevisedNet * (list_QuotePeriods[i].KPI2__c/100) * (list_DurationInMonths[i]/12));
                                    //obj.record.put('Period' + strIndex + '_KPI2_Amount__c',decEffectiveAmount * (list_QuotePeriods[i].KPI2__c/100) * (list_DurationInMonths[i]/12));
                                }
                                // Annualizing
                                decEffectiveAmount = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c') * (12/list_DurationInMonths[i]);
                                
                                // if LRA Uplift is not being selectively applied or if line is selected for LRA Uplift
                                if(!quote.Apply_LRA_Uplift_Selectively__c || (obj.record.Apply_LRA_Uplift__c))
                                {
                                    // Products like Custom App Support which are marked as LRA Uplift Not Applicable should be excluded
                                    if(quote.LRA_Uplift__c != null && 
                                       obj.record.BigMachines__Product__c != null &&
                                       !obj.record.BigMachines__Product__r.LRA_Uplift_Not_Applicable__c)
                                    {
                                        Decimal decMaintDue = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c');
                                        obj.record.put('Year' + strIndex + '_Maintenance_Due__c',decMaintDue * ((100.0 + quote.LRA_Uplift__c)/100.0));
                                        // KPIs
                                        if(list_QuotePeriods[i].KPI1__c != null)
                                        {
                                            Decimal decKPIAmount = (Decimal) obj.record.get('Period' + strIndex + '_KPI1_Amount__c');
                                            obj.record.put('Period' + strIndex + '_KPI1_Amount__c',decKPIAmount * ((100.0 + quote.LRA_Uplift__c)/100.0));
                                        }
                                        if(list_QuotePeriods[i].KPI2__c != null)
                                        {
                                            Decimal decKPIAmount = (Decimal) obj.record.get('Period' + strIndex + '_KPI2_Amount__c');
                                            obj.record.put('Period' + strIndex + '_KPI2_Amount__c',decKPIAmount * ((100.0 + quote.LRA_Uplift__c)/100.0));
                                        }
                                    }
                                }
                                
                                if(quote.LDA_Uplift__c != null && obj.record.BigMachines__Product__c != null &&
                                   !obj.record.BigMachines__Product__r.LDA_Uplift_Not_Applicable__c)
                                {
                                    Decimal decMaintDue = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c');
                                    obj.record.put('Year' + strIndex + '_Maintenance_Due__c',decMaintDue * ((100.0 + quote.LDA_Uplift__c)/100.0));
                                    // KPIs
                                    if(list_QuotePeriods[i].KPI1__c != null)
                                    {
                                        Decimal decKPIAmount = (Decimal) obj.record.get('Period' + strIndex + '_KPI1_Amount__c');
                                        obj.record.put('Period' + strIndex + '_KPI1_Amount__c',decKPIAmount * ((100.0 + quote.LDA_Uplift__c)/100.0));
                                    }
                                    if(list_QuotePeriods[i].KPI2__c != null)
                                    {
                                        Decimal decKPIAmount = (Decimal) obj.record.get('Period' + strIndex + '_KPI2_Amount__c');
                                        obj.record.put('Period' + strIndex + '_KPI2_Amount__c',decKPIAmount * ((100.0 + quote.LDA_Uplift__c)/100.0));
                                    }
                                }
                                
                                quote.put('Period' + strIndex + '_KPI1_Amount__c', ((Decimal)quote.get('Period' + strIndex + '_KPI1_Amount__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_KPI1_Amount__c')));
                                quote.put('Period' + strIndex + '_KPI2_Amount__c', ((Decimal)quote.get('Period' + strIndex + '_KPI2_Amount__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_KPI2_Amount__c')));
                                
                                // Reinstatement : Calculations not be performed for Lump Sum Fees
                                if(quote.Has_Reinstatement__c && obj.record.Reinstatement__c && list_ReinstatementDurationInMonths[i] != null)
                                {
                                    Decimal decMaintDue = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c');
                                    obj.record.put('Period' + strIndex + '_Reinstatement_Fee__c',(decMaintDue/list_DurationInMonths[i]) * list_ReinstatementDurationInMonths[i] * (quote.Reinstatement__c / 100.0));
                                    quote.put('Period' + strIndex + '_Reinstatement_Fee__c',((Decimal)quote.get('Period' + strIndex + '_Reinstatement_Fee__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_Reinstatement_Fee__c')));
                                }
                                
                                // EOS : Calculations not be performed for Lump Sum Fees
                                if(quote.Has_Extended_End_Of_Support__c && obj.record.Extended_End_of_Support__c && 
                                   dtProductEOS != null && list_EOSDurationInMonths[i] != null)
                                {
                                    Decimal decMaintDue = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c');
                                    obj.record.put('Period' + strIndex + '_EOS_Fee__c',(decMaintDue/list_DurationInMonths[i]) * list_EOSDurationInMonths[i] * (quote.Extended_End_of_Support_Percent__c / 100.0));
                                    quote.put('Period' + strIndex + '_EOS_Fee__c',((Decimal)quote.get('Period' + strIndex + '_EOS_Fee__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_EOS_Fee__c')));
                                }
                                
                                // Shelving : 50% of Maintenance Due
                                if(obj.record.Contract_Line_Update_Status__c == 'Shelved')
                                {
                                    if(obj.record.Original_Qty__c == obj.record.Current_Qty__c)
                                    {
                                        obj.record.put('Period' + strIndex + '_Shelving_Fee__c', (Decimal)obj.record.get('Year' + strIndex + '_Maintenance_Due__c') * 0.5);
                                        obj.record.put('Year' + strIndex + '_Maintenance_Due__c',0);
                                    }
                                    else
                                    {
                                        obj.record.put('Period' + strIndex + '_Shelving_Fee__c', 
                                                       (Decimal)obj.record.get('Year' + strIndex + '_Maintenance_Due__c')* 
                                                       (obj.record.Original_Qty__c/obj.record.Current_Qty__c) * 
                                                       ((obj.record.Original_Qty__c - obj.record.Current_Qty__c)/obj.record.Original_Qty__c) * 0.5);
                                    }
                                    quote.put('Period' + strIndex + '_Shelving_Fee__c', ((Decimal)quote.get('Period' + strIndex + '_Shelving_Fee__c')) + ((Decimal)obj.record.get('Period' + strIndex + '_Shelving_Fee__c')));
                                }
                            }
                        }
                    }
                }
            }
            // Bug Fix : Initialize periods if periods has been reduced and override is set for any line
            else if(intNumOfPeriods > 0 && intNumOfPeriods < 5)
            {
                for(Integer i = intNumOfPeriods; i < 5 ; i++)
                {
                    String strIndex = String.valueOf(i+1);
                    obj.record.put('Year' + strIndex + '_Maintenance_Due__c',0.0);
                    obj.record.put('Period' + strIndex + '_Reinstatement_Fee__c',0.0);
                    obj.record.put('Period' + strIndex + '_EOS_Fee__c',0.0);
                    obj.record.put('Period' + strIndex + '_Shelving_Fee__c',0.0);
                    obj.record.put('Period' + strIndex + '_KPI1_Amount__c',0.0);
                    obj.record.put('Period' + strIndex + '_KPI2_Amount__c',0.0);
                }
            }
            
            // Fee Calculations : Totalling up fees from line and storing on quote for all periods 
            // Calculating at line level : Calculations can be moved to quote level and not line by line if needed
            // Period 1
            if(intNumOfPeriods > 0)
            {
                if(obj.record.Maintenance_Due__c != null)
                {
                    if(list_QuotePeriods[0].Partner_to_Partner_Uplift_Fee__c != null && 
                       list_QuotePeriods[0].Partner_to_Partner_Uplift_Fee__c != 0.0)
                        quote.Period1_P2P_Uplift_Fee__c += obj.record.Maintenance_Due__c * (list_QuotePeriods[0].Partner_to_Partner_Uplift_Fee__c/100.0);
                    
                    if(list_QuotePeriods[0].Quarterly_Semi_Annual_Fee__c != null && 
                       list_QuotePeriods[0].Quarterly_Semi_Annual_Fee__c != 0.0)
                        quote.Period1_Quaterly_Semi_Annual_Fee__c += obj.record.Maintenance_Due__c * (list_QuotePeriods[0].Quarterly_Semi_Annual_Fee__c/100.0);
                    
                    // Calculating Annualized Maintenance For downstream service contract                   
                    if(list_DurationInMonths[0] != null && list_DurationInMonths[0] != 0)
                        obj.record.Annualized_Maintenance_Last_Period__c = obj.record.Maintenance_Due__c * (12/list_DurationInMonths[0]);
                }
            }
            // Period 2 to Period 5
            for(Integer i=1; i<intNumOfPeriods ; i++)
            {
                String strIndex = String.valueOf(i+1);
                Decimal decMaintenanceDue = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c');
                if(decMaintenanceDue != null)
                {
                    if(list_QuotePeriods[i].Partner_to_Partner_Uplift_Fee__c != null && 
                       list_QuotePeriods[i].Partner_to_Partner_Uplift_Fee__c != 0.0)
                    {
                        
                        Decimal decFee = (Decimal) quote.get('Period' + strIndex + '_P2P_Uplift_Fee__c');
                        quote.put('Period' + strIndex + '_P2P_Uplift_Fee__c',
                                  decFee + (decMaintenanceDue * (list_QuotePeriods[i].Partner_to_Partner_Uplift_Fee__c/100.0)));  
                    }
                    if(list_QuotePeriods[i].Quarterly_Semi_Annual_Fee__c != null && 
                       list_QuotePeriods[i].Quarterly_Semi_Annual_Fee__c != 0.0)
                    {
                        
                        Decimal decFee = (Decimal) quote.get('Period' + strIndex + '_Quaterly_Semi_Annual_Fee__c');
                        quote.put('Period' + strIndex + '_Quaterly_Semi_Annual_Fee__c',
                                  decFee + (decMaintenanceDue * (list_QuotePeriods[i].Quarterly_Semi_Annual_Fee__c/100.0)));
                    }
                    // Calculating Annualized Maintenance For downstream service contract                   
                    if(list_DurationInMonths[i] != null && list_DurationInMonths[i] != 0)
                        obj.record.Annualized_Maintenance_Last_Period__c = decMaintenanceDue * (12/list_DurationInMonths[i]);
                }
            }
            
            // ********* Calculating Annual Increase/Decrease and Current Rate***************
            // Period 1
            Decimal decTotalDueAllPeriods = obj.record.Maintenance_Due__c != null ? obj.record.Maintenance_Due__c : 0.0;
            
            /*// For Current Rate Calculations : Totalling all rates (exclude split/retired)
if(obj.record.Contract_Line_Update_Status__c != 'Split' && obj.record.Contract_Line_Update_Status__c != 'Retired')
{
if(quote.Increase_type__c == 'Genesys Care Rate' && obj.record.Genesys_Care_Rate__c != null)
{
intNoOfRatesAdded++;
quote.Current_Maint_Rate__c += obj.record.Genesys_Care_Rate__c;
System.debug('$$$ ' + quote.Current_Maint_Rate__c);
}
else if(quote.Increase_type__c != 'Genesys Care Rate' && obj.record.Year1_Increase__c != null)
{
intNoOfRatesAdded++;
quote.Current_Maint_Rate__c += obj.record.Year1_Increase__c;
}
}*/
            
            // Period 2 to Period 5
            for(Integer i=1; i<intNumOfPeriods ; i++)
            {
                String strIndex = String.valueOf(i+1);
                Decimal decMaintDue = (Decimal) obj.record.get('Year' + strIndex + '_Maintenance_Due__c');
                decTotalDueAllPeriods += decMaintDue != null ? decMaintDue : 0.0;
                
                /*// For Current Rate Calculations : Totalling all rates (exclude split/retired)
if(obj.record.Contract_Line_Update_Status__c != 'Split' && obj.record.Contract_Line_Update_Status__c != 'Retired')
{
Decimal decCareRate = (Decimal) obj.record.get('Year' + strIndex + '_CareRatePercent__c');
Decimal decIncreaseRate = (Decimal) obj.record.get('Year' + strIndex + '_Increase__c');
if(quote.Increase_type__c == 'Genesys Care Rate' && decCareRate != null)
{
intNoOfRatesAdded++;
quote.Current_Maint_Rate__c += decCareRate;
}
else if(quote.Increase_type__c != 'Genesys Care Rate' && decIncreaseRate != null)
{
intNoOfRatesAdded++;
quote.Current_Maint_Rate__c += decIncreaseRate;
}
}*/
            }
            // Annualizing = (Total Due Amount all periods / Total number of months) * 12
            // Line Increase = (Annualized Amount) - (Previous Maintenance Value)
            Decimal decAnnualizedTotalDue = ((decTotalDueAllPeriods/(decTotalMonths != 0 ? decTotalMonths : 1)) * 12);
            decTotalAnnualizedMaintDue += decAnnualizedTotalDue;
            obj.record.Line_Increase_Value__c = decAnnualizedTotalDue - (obj.record.Previous_Line_Maintenance_Value__c != null ? obj.record.Previous_Line_Maintenance_Value__c : 0.0);
            
            // Since it a decrease we have to negate the increase
            if(obj.record.Contract_Line_Update_Status__c == 'Split')
                quote.Total_Decrease_Split__c += obj.record.Line_Increase_Value__c * (-1);
            else
                quote.Total_Increase__c += obj.record.Line_Increase_Value__c;
            
            if(obj.record.Line_Increase_Value__c < 0) 
                quote.Total_Decrease__c += obj.record.Line_Increase_Value__c *(-1);       
            
            // Invoice Rate Logic (02/02/2015) : storing Total Revised Net and Annualized Maintenance Due Per Invoice
            if(obj.record.Revised_Net_License_Value__c != null)
            {
                if(map_InvNumToTotalRevisedNet.containsKey(obj.record.Lic_Invoice__c))
                    map_InvNumToTotalRevisedNet.put(obj.record.Lic_Invoice__c,map_InvNumToTotalRevisedNet.get(obj.record.Lic_Invoice__c) + obj.record.Revised_Net_License_Value__c);
                else
                    map_InvNumToTotalRevisedNet.put(obj.record.Lic_Invoice__c,obj.record.Revised_Net_License_Value__c);
            }
            if(map_InvNumToTotalMaintDue.containsKey(obj.record.Lic_Invoice__c))
                map_InvNumToTotalMaintDue.put(obj.record.Lic_Invoice__c,map_InvNumToTotalMaintDue.get(obj.record.Lic_Invoice__c) + decAnnualizedTotalDue);
            else
                map_InvNumToTotalMaintDue.put(obj.record.Lic_Invoice__c,decAnnualizedTotalDue);
            
            list_ToUpdate.add(obj.record);
        }
        
        // Calculating Invoice Rates (02/10/2015)
        Map<String,Decimal> map_InvNumToInvoiceRate = new Map<String,Decimal>();
        Map<String,Decimal> map_TotalRevisedNet = new Map<String,Decimal>();
        Map<String,Decimal> map_TotalMaintDue = new Map<String,Decimal>();
        
        Decimal decTotalInvRates = 0;
        Decimal decTotalMaintDue = 0;
        Decimal decTotalReviseNet = 0;
        
        Integer intNumOfRates = 0;
        for(String strInvNum : map_InvNumToTotalMaintDue.keySet())
        {
            if(map_InvNumToTotalRevisedNet.containsKey(strInvNum) && map_InvNumToTotalRevisedNet.get(strInvNum) != 0)
            {
                Decimal decInvoiceRate = (map_InvNumToTotalMaintDue.get(strInvNum)/map_InvNumToTotalRevisedNet.get(strInvNum)) * 100.0;
                
                decTotalMaintDue = map_InvNumToTotalMaintDue.get(strInvNum);
                decTotalReviseNet = map_InvNumToTotalRevisedNet.get(strInvNum);
                
                map_TotalRevisedNet.put(strInvNum,decTotalReviseNet);
                map_TotalMaintDue.put(strInvNum,decTotalMaintDue);
                
                map_InvNumToInvoiceRate.put(strInvNum,decInvoiceRate);
                if(decInvoiceRate>0)
                    intNumOfRates++;
                
                decTotalInvRates += decInvoiceRate;
            }
        }
        
        // Current Rate is average of all invoice rates (02/10/2015)
        quote.Current_Maint_Rate__c = 0;
        if(intNumOfRates != 0)
            quote.Current_Maint_Rate__c = (decTotalInvRates/intNumOfRates);
        
        // Storing Invoice Rate on lines
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            if(map_InvNumToInvoiceRate.containsKey(obj.record.Lic_Invoice__c)) {
                obj.record.Invoice_Rate__c = map_InvNumToInvoiceRate.get(obj.record.Lic_Invoice__c);
                obj.record.Total_Invoice_Maint__c =  map_TotalMaintDue.get(obj.record.Lic_Invoice__c);
                obj.record.Total_Invoice_Revise_Net__c = map_TotalRevisedNet.get(obj.record.Lic_Invoice__c);
            }
            
            else {
                obj.record.Invoice_Rate__c = null;
                
            }
        }
        
        /*  These following quote fields are used to generate order lines.  
So totalling individual period amounts and storing in corresponding fields.*/
        for(Integer i=1; i<= intNumOfPeriods ; i++)
        {
            String strIndex = String.valueOf(i);
            
            // Partner to Partner Uplift Fee
            Decimal decAmount = (Decimal) quote.get('Period' + strIndex + '_P2P_Uplift_Fee__c');
            quote.Partner_to_Partner_Uplift__c += decAmount;
            
            // Quarterly Semi Annual Fee
            decAmount = (Decimal) quote.get('Period' + strIndex + '_Quaterly_Semi_Annual_Fee__c');
            quote.Quarterly_Semi_Annual_Billing_Fee__c += decAmount;
            
            // Reinstatement Fee
            decAmount = (Decimal) quote.get('Period' + strIndex + '_Reinstatement_Fee__c');
            quote.Reinstatement_fee__c += decAmount;
            
            // Extended End Of Support Fee
            decAmount = (Decimal) quote.get('Period' + strIndex + '_EOS_Fee__c');
            quote.Extended_End_of_Support__c += decAmount;
        }
        
        // Add Lump Sum Charge if any to respective total fees fields
        for(BigMachines__Quote_Product__c objQuoteProduct : list_Fees)
        {
            if(objQuoteProduct.BigMachines__Product__r.Description == 'Flex Care-Extended Support(Partner)' || 
               objQuoteProduct.BigMachines__Product__r.Description == 'Flex Care-Extended Support(End User)' ||
               objQuoteProduct.BigMachines__Product__r.Description == 'Extended End of Support')
            {
                quote.Extended_End_of_Support__c += objQuoteProduct.BigMachines__Sales_Price__c;
            }  
            else if(objQuoteProduct.BigMachines__Product__r.Description == 'Reinstatement Fee')
                quote.Reinstatement_fee__c += objQuoteProduct.BigMachines__Sales_Price__c;
        }
        
        /*// Storing average of all rates as current rate (preventing divide by zero error by checking for zero)
quote.Current_Maint_Rate__c /= ((intNoOfRatesAdded != 0 ? intNoOfRatesAdded : 1) * 1.0);
System.debug('$$$ ' + quote.Current_Maint_Rate__c);
// For Increase % Model : If it is 14% and we add a 5% increase then the current rate is 14.7%
if(quote.Increase_type__c != 'Genesys Care Rate' && quote.Previous_Maint_Rate__c != null)
{
quote.Current_Maint_Rate__c = quote.Previous_Maint_Rate__c * ((100.0 + quote.Current_Maint_Rate__c)/100.0);
}*/
        
        /* Flex Care End Dates should not be overwritten : Request to do the same has been reverted
// To update Maintenance End Date on Flex Care products/lines
for(BigMachines__Quote_Product__c objQuoteProduct : list_FlexCare)
{
if(quote.Maintenance_End_Date__c != null)
objQuoteProduct.Maintenance_End_Date__c = quote.Maintenance_End_Date__c;
}
if(list_FlexCare.size() > 0)
list_ToUpdate.addAll(list_FlexCare);
*/
        
        // Quote Account should map to End User
        quote.BigMachines__Account__c = quote.End_User_ID__c;
        try
        {
            if(list_ToUpdate.size() > 0)
                update list_ToUpdate;
            
            if(quote != null)
                upsert quote;
            
            // Fetching Quote Products
            getQuoteProducts(quote.Id);
            // createCurrentPageList();

            // Fetching Quote information
            quote = getQuote(quoteId);
            quote.Total_Maintenance_Amount_Due__c  = quote.Grand_Total__c;
            
            // Actual Maintenance Rate = Annualized Total Maintenance Due/Total Revised Net (02/02/2015)
            if(quote.Total_Revised_Net_License_Value_Formula__c != 0)
                quote.Actual_Maint_Rate__c = (decTotalAnnualizedMaintDue/quote.Total_Revised_Net_License_Value_Formula__c) * 100;
            
            update quote;
        }
        catch(Exception ex)
        {
            System.debug('Exception = ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
		
    }
    
    // *** Method to finalize Revised Net override so that manual entered value is updated based on status ***
    public void finalizeRevisedNet()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            if(obj.record.Revised_Net_Override__c)
            {
                obj.record.Revised_Net_From_Contract_Line__c = obj.record.Revised_Net_License_Value__c;
                obj.record.Revised_Net_Override__c = false;
                list_ToUpdate.add(obj.record);
            }
        }
        if(list_ToUpdate.size() > 0)
        {
            // To bypass quote product trigger
            Util.Bypass_Trigger_Chk = true;
            try
            {
                update list_ToUpdate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Revised Net Overrides Finalized. Please Recalculate to update values.'));
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
        blnIsOverrideAllRevisedNet = false;
        
        // RAO - Added this line
        System.debug('3022 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    // *** Method to support currency change on quote : converts all currency amounts to new currency and recalculates and saves values
    public void changeQuoteCurrency()
    {
        // RAO - Added this line; Refresh list_QuoteProducts from cache
       	fetchQuoteProducts();
        
        // Util.convertCurrencyCustom(source currencyisocode,target currencyisocode,map of conversion rates,amount to convert);
        // Grid Products
        for(QuoteProductWrapper obj : list_QuoteProducts)
        {
            BigMachines__Quote_Product__c objQP = obj.record;
            objQP.CurrencyISOCode = quote.CurrencyISOCode;
            if(!quote.No_Currency_Conversion__c)
            {
                objQP.List_Price__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.List_Price__c);
                objQP.Original_Net_License_Value__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.Original_Net_License_value__c);
                objQP.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.Revised_Net_From_Contract_Line__c);
                objQP.Revised_Net_License_Value__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.Revised_Net_License_Value__c);
                objQP.Previous_Line_Maintenance_Value__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.Previous_Line_Maintenance_Value__c);
                objQP.BigMachines__Sales_Price__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.BigMachines__Sales_Price__c);
                objQP.Maintenance_Due__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.Maintenance_Due__c);
                // Period 2 to Period 5
                for(Integer i=1; i<intNumOfPeriods ; i++)
                {
                    // Maintenance Due
                    Decimal decAmount = (Decimal) objQP.get('Year' + String.valueOf(i+1) + '_Maintenance_Due__c');
                    Decimal decConvertedAmount = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,decAmount);
                    objQP.put('Year' + String.valueOf(i+1) + '_Maintenance_Due__c',decConvertedAmount);
                }
            }
        }
        // Configuration Products
        List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
        list_ToUpdate.addAll(list_FlexCare);
        list_ToUpdate.addAll(list_Fees);
        if(objServiceLevel != null)
            list_ToUpdate.add(objServiceLevel);
        
        for(BigMachines__Quote_Product__c objQP : list_ToUpdate)
        {
            objQP.CurrencyISOCode = quote.CurrencyISOCode;
            if(!quote.No_Currency_Conversion__c)
                objQP.BigMachines__Sales_Price__c = Util.convertCurrencyCustom(strCurrentCurrencyCode,quote.CurrencyISOCode,map_ConversionRates,objQP.BigMachines__Sales_Price__c);
        }
        if(list_ToUpdate.size() > 0)
            update list_ToUpdate;
        
        // To fetch latest formula field value for amount
        if(!quote.No_Currency_Conversion__c)        
            fetchConfigurationProducts();
        
        strCurrentCurrencyCode = quote.CurrencyISOCode;
        // Billing Plans
        List<Quote_Billing_Plan__c> list_BillingPlans = [SELECT Id,Amount__c,CurrencyISOCode FROM Quote_Billing_Plan__c 
                                                         WHERE Quote__c = :quote.Id AND CurrencyISOCode != :quote.CurrencyISOCode];
        for(Quote_Billing_Plan__c objBillingPlan : list_BillingPlans)
        {
            objBillingPlan.CurrencyISOCode = quote.CurrencyISOCode;
            if(!quote.No_Currency_Conversion__c)
                objBillingPlan.Amount__c = Util.convertCurrencyCustom(objBillingPlan.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,objBillingPlan.Amount__c);
        }
        if(list_BillingPlans.size() > 0)
            update list_BillingPlans;
        
        doCalculations();
        
        // RAO - Added this line
        System.debug('3094 list_QuoteProducts.size = ' + list_QuoteProducts.size());
        storeQuoteProducts();
        createCurrentPageList();
    }
    
    public void applyELAChange(){
        // currentInvoiceForELA
        System.debug('currentInvoiceForELA = ' + currentInvoiceForELA);
        Boolean currentELAStatus = invoicesELA.get(currentInvoiceForELA);  
        List<Invoice__c> invoices = [SELECT id, Name, ELA__c FROM Invoice__c WHERE NAME = :currentInvoiceForELA];
        if(invoices.size() > 0){
            invoices[0].ELA__c = currentELAStatus == true ? false : true;
            update invoices;
            invoicesELA.put(currentInvoiceForELA, invoices[0].ELA__c);
        }
    }
    
     public void storeQuoteProducts(){
        String keyId = (quote != NULL && quote.Id != NULL) ? quote.Id : 'QUOTE';
        List<QuoteProductWrapper> quoteProducts1 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts2 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts3 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts4 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts5 = new List<QuoteProductWrapper>();
        
        if(list_QuoteProducts.size() <= 300){
            quoteProducts1 = list_QuoteProducts;
        } else {
            for(Integer i=0; i < list_QuoteProducts.size(); i++){
                if(i < 300){
                    quoteProducts1.add(list_QuoteProducts[i]);
                } else if(i >= 300 && i < 600){
                    quoteProducts2.add(list_QuoteProducts[i]);
                } else if(i >= 600 && i < 900){
                    quoteProducts3.add(list_QuoteProducts[i]);
                } else if(i >= 900 && i < 1200){
                    quoteProducts4.add(list_QuoteProducts[i]);
                } else if(i >= 1200 && i < list_QuoteProducts.size()){
                    quoteProducts5.add(list_QuoteProducts[i]);
                } 
            }
        }
        System.debug('storeQuoteProducts --> listQuoteProducts.size = ' + list_QuoteProducts.size());
        System.debug('storeQuoteProducts --> quoteProducts1.size = ' + quoteProducts1.size());
        System.debug('storeQuoteProducts --> quoteProducts2.size = ' + quoteProducts2.size());
        System.debug('storeQuoteProducts --> quoteProducts3.size = ' + quoteProducts3.size());
        System.debug('storeQuoteProducts --> quoteProducts4.size = ' + quoteProducts4.size());
        System.debug('storeQuoteProducts --> quoteProducts5.size = ' + quoteProducts5.size());
        if(!Test.isRunningTest()){
            Cache.Session.put(keyId + 'listQuoteProducts1', quoteProducts1); 
            Cache.Session.put(keyId + 'listQuoteProducts2', quoteProducts2); 
            Cache.Session.put(keyId + 'listQuoteProducts3', quoteProducts3); 
            Cache.Session.put(keyId + 'listQuoteProducts4', quoteProducts4); 
            Cache.Session.put(keyId + 'listQuoteProducts5', quoteProducts5); 
        }
    } 
    
    public void fetchQuoteProducts(){
        String keyId = (quote != NULL && quote.Id != NULL) ? quote.Id : 'QUOTE';
        if(!Test.isRunningTest() && Cache.Session.get(keyId + 'listQuoteProducts1') != NULL){
	        list_QuoteProducts = new List<QuoteProductWrapper>(); 
            List<QuoteProductWrapper> quoteProducts = new List<QuoteProductWrapper>();
            List<QuoteProductWrapper> quoteProducts1 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts1'); 
            List<QuoteProductWrapper> quoteProducts2 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts2'); 
            List<QuoteProductWrapper> quoteProducts3 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts3'); 
            List<QuoteProductWrapper> quoteProducts4 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts4'); 
            List<QuoteProductWrapper> quoteProducts5 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts5'); 
            if(!quoteProducts1.isEmpty()) list_QuoteProducts.addAll(quoteProducts1);
            if(!quoteProducts2.isEmpty()) list_QuoteProducts.addAll(quoteProducts2);
            if(!quoteProducts3.isEmpty()) list_QuoteProducts.addAll(quoteProducts3);
            if(!quoteProducts4.isEmpty()) list_QuoteProducts.addAll(quoteProducts4);
            if(!quoteProducts5.isEmpty()) list_QuoteProducts.addAll(quoteProducts5);
            System.debug('fetchQuoteProducts --> quoteProducts1.size = ' + quoteProducts1.size());
            System.debug('fetchQuoteProducts --> quoteProducts2.size = ' + quoteProducts2.size());
            System.debug('fetchQuoteProducts --> quoteProducts3.size = ' + quoteProducts3.size());
            System.debug('fetchQuoteProducts --> quoteProducts4.size = ' + quoteProducts4.size());
            System.debug('fetchQuoteProducts --> quoteProducts5.size = ' + quoteProducts5.size());
        } 
    } 
    
    
    
    /*
    public void storeQuoteProducts(List<QuoteProductWrapper> listQuoteProducts){
        //String keyId = quoteId != NULL ? quoteId : 'QUOTE';
        //keyId = keyId.length() == 18 ? keyId.substring(0, 15) : keyId;
        String keyId = (quote != NULL && quote.Id != NULL) ? quote.Id : 'QUOTE';
        List<QuoteProductWrapper> quoteProducts1 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts2 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts3 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts4 = new List<QuoteProductWrapper>();
        List<QuoteProductWrapper> quoteProducts5 = new List<QuoteProductWrapper>();
        
        if(listQuoteProducts.size() <= 300){
            quoteProducts1 = listQuoteProducts;
        } else {
            for(Integer i=0; i < listQuoteProducts.size(); i++){
                if(i < 300){
                    quoteProducts1.add(listQuoteProducts[i]);
                } else if(i >= 300 && i < 600){
                    quoteProducts2.add(listQuoteProducts[i]);
                } else if(i >= 600 && i < 900){
                    quoteProducts3.add(listQuoteProducts[i]);
                } else if(i >= 900 && i < 1200){
                    quoteProducts4.add(listQuoteProducts[i]);
                } else if(i >= 1200 && i < listQuoteProducts.size()){
                    quoteProducts5.add(listQuoteProducts[i]);
                } 
            }
        }
        System.debug('storeQuoteProducts --> listQuoteProducts.size = ' + listQuoteProducts.size());
        System.debug('storeQuoteProducts --> quoteProducts1.size = ' + quoteProducts1.size());
        System.debug('storeQuoteProducts --> quoteProducts2.size = ' + quoteProducts2.size());
        System.debug('storeQuoteProducts --> quoteProducts3.size = ' + quoteProducts3.size());
        System.debug('storeQuoteProducts --> quoteProducts4.size = ' + quoteProducts4.size());
        System.debug('storeQuoteProducts --> quoteProducts5.size = ' + quoteProducts5.size());
        if(!Test.isRunningTest()){
            Cache.Session.put(keyId + 'listQuoteProducts1', quoteProducts1); 
            Cache.Session.put(keyId + 'listQuoteProducts2', quoteProducts2); 
            Cache.Session.put(keyId + 'listQuoteProducts3', quoteProducts3); 
            Cache.Session.put(keyId + 'listQuoteProducts4', quoteProducts4); 
            Cache.Session.put(keyId + 'listQuoteProducts5', quoteProducts5); 
        }
    } 
    
    public List<QuoteProductWrapper> fetchQuoteProducts(){
        //String keyId = quoteId != NULL ? quoteId : 'QUOTE';
        //keyId = keyId.length() == 18 ? keyId.substring(0, 15) : keyId;
        String keyId = (quote != NULL && quote.Id != NULL) ? quote.Id : 'QUOTE';
        if(!Test.isRunningTest() && Cache.Session.get(keyId + 'listQuoteProducts1') != NULL){
            List<QuoteProductWrapper> quoteProducts = new List<QuoteProductWrapper>();
            List<QuoteProductWrapper> quoteProducts1 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts1'); 
            List<QuoteProductWrapper> quoteProducts2 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts2'); 
            List<QuoteProductWrapper> quoteProducts3 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts3'); 
            List<QuoteProductWrapper> quoteProducts4 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts4'); 
            List<QuoteProductWrapper> quoteProducts5 = (List<QuoteProductWrapper>)Cache.Session.get(keyId + 'listQuoteProducts5'); 
            if(!quoteProducts1.isEmpty()) quoteProducts.addAll(quoteProducts1);
            if(!quoteProducts2.isEmpty()) quoteProducts.addAll(quoteProducts2);
            if(!quoteProducts3.isEmpty()) quoteProducts.addAll(quoteProducts3);
            if(!quoteProducts4.isEmpty()) quoteProducts.addAll(quoteProducts4);
            if(!quoteProducts5.isEmpty()) quoteProducts.addAll(quoteProducts5);
            System.debug('fetchQuoteProducts --> quoteProducts1.size = ' + quoteProducts1.size());
            System.debug('fetchQuoteProducts --> quoteProducts2.size = ' + quoteProducts2.size());
            System.debug('fetchQuoteProducts --> quoteProducts3.size = ' + quoteProducts3.size());
            System.debug('fetchQuoteProducts --> quoteProducts4.size = ' + quoteProducts4.size());
            System.debug('fetchQuoteProducts --> quoteProducts5.size = ' + quoteProducts5.size());
            
            return quoteProducts;
        } else {
            return list_QuoteProducts;
        }
    } 
    */
    public class QuoteProductWrapper{
        public BigMachines__Quote_Product__c record {get; set;}
        public Boolean selected {get; set;}
        public QuoteProductWrapper(){
            selected = false;
        }
    }
    

}