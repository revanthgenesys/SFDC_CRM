public without sharing class ServiceOrderQuoteToolController 
{
    public BigMachines__Quote__c quote {get; set;} 
    private transient List<wrapperQuoteProducts> allRecords {get; set;}
    public List<wrapperQuoteProducts> userSubscriptions {get; set;}
    public List<wrapperQuoteProducts> portSubscriptions {get; set;}
    public List<wrapperQuoteProducts> customerSubscriptions {get; set;}
    public List<wrapperQuoteProducts> rentedEquipmentSubscriptions {get; set;}
    public List<wrapperQuoteProducts> supportSubscriptions {get; set;}
    public List<wrapperQuoteProducts> timeBasedSubscriptions {get; set;}
    public List<wrapperQuoteProducts> transactionBasedSubscriptions {get; set;}
    public List<wrapperQuoteProducts> tierSubscriptions {get; set;}
    public List<wrapperQuoteProducts> configurationProfServicesSubscriptions {get; set;}
    public List<wrapperQuoteProducts> clientManagementSubscriptions {get; set;}
    public List<wrapperQuoteProducts> list_IVROptions {get; set;}
    public List<wrapperQuoteProducts> list_InboundSeatAddOns {get; set;}
    public List<wrapperQuoteProducts> list_AdapterServiceOptions {get; set;}
    public List<wrapperQuoteProducts> list_OtherOptions {get; set;}
    public List<wrapperQuoteProducts> list_CommunicationCircuits {get; set;}
    public List<wrapperQuoteProducts> list_ImplementationCharges {get; set;}
    public List<wrapperQuoteProducts> list_SelfServiceIVR {get; set;}
    public List<wrapperQuoteProducts> list_SelfServiceIVROptions {get; set;}
    public List<wrapperQuoteProducts> list_SelfServiceIVRIntegrations {get; set;}
    public List<wrapperQuoteProducts> list_OutboundCampaignManager {get; set;}
    public List<wrapperQuoteProducts> list_TelcoOptions {get; set;}
    public List<wrapperQuoteProducts> list_ConnectivityOptions {get; set;}
    public List<wrapperQuoteProducts> list_PerSeatPricing {get; set;}
    public List<wrapperQuoteProducts> list_AccessFees {get; set;}
    
    //BE Cloud Sections 
    public List<wrapperQuoteProducts> IVRAndMediaPortOptions {get; set;} 
    public List<wrapperQuoteProducts> BotsAIOptions {get; set;}
    public List<wrapperQuoteProducts> IVRAndMediaPortAddOns {get; set;} 
    public List<wrapperQuoteProducts> perSeatPricingBase {get; set;} 
    public List<wrapperQuoteProducts> digitalChannelOptions {get; set;} 
    public List<wrapperQuoteProducts> inboundSeatAddOnsQM {get; set;}
    public List<wrapperQuoteProducts> inboundSeatAddOnsWO {get; set;}
    public List<wrapperQuoteProducts> inboundSeatAddOnsOS {get; set;}         
    public List<wrapperQuoteProducts> endUserEndPoints {get; set;} 
    public List<wrapperQuoteProducts> cloudContactCenterAdapters {get; set;} 
    public List<wrapperQuoteProducts> telcoITI {get; set;} 
    public List<wrapperQuoteProducts> telcoBLT {get; set;} 
    public List<wrapperQuoteProducts> telcoOP {get; set;} 
    public List<wrapperQuoteProducts> telcoMPLS {get; set;} 
    public List<wrapperQuoteProducts> genesysCare {get; set;} 
    public List<wrapperQuoteProducts> telcoCrossConnect {get; set;} 
    public List<wrapperQuoteProducts> psRapidDevelopmentImplementationPackage {get; set;} 
    public List<wrapperQuoteProducts> psImplementation {get; set;} 
    public List<wrapperQuoteProducts> installationCharges {get; set;}            
    public List<wrapperQuoteProducts> headerRow {get; set;}
    
    public Boolean renderUserSubscriptions {get; set;}
    public Boolean renderPortSubscriptions {get; set;}
    public Boolean renderCustomerSubscriptions {get; set;}
    public Boolean renderRentedEquipmentSubscriptions {get; set;}
    public Boolean renderSupportSubscriptions {get; set;}
    public Boolean renderTimeBasedSubscriptions {get; set;}
    public Boolean renderRransactionBasedSubscriptions {get; set;}
    public Boolean renderTierSubscriptions {get; set;}
    public Boolean renderProfServicesSubscription {get; set;}
    public Boolean renderClientManagementSubscription {get; set;}
    public Boolean blnShowIVROptions {get; set;}
    public Boolean blnShowInboundSeatAddOns {get; set;}
    public Boolean blnShowAdapterServiceOptions {get; set;}
    public Boolean blnShowOtherOptions {get; set;}
    public Boolean blnShowCommunicationCircuits {get; set;}
    public Boolean blnShowImplementationCharges {get; set;}
    public Boolean blnShowSelfServiceIVR {get; set;}
    public Boolean blnShowSelfServiceIVROptions {get; set;}
    public Boolean blnShowSelfServiceIVRIntegrations {get; set;}
    public Boolean blnShowOutboundCampaignManager {get; set;}
    public Boolean blnShowTelcoOptions {get; set;}
    public Boolean blnShowConnectivityOptions {get; set;}
    public Boolean blnShowPerSeatPricing {get; set;}
    public Boolean blnShowAccessFees {get; set;}
    
    //BE Cloud flags
    public Boolean renderIVRAndMediaPortOptions {get; set;}
    public Boolean renderBotsAI  {get; set;}
    public Boolean renderIVRAndMediaPortAddOns  {get; set;}
    public Boolean renderPerSeatPricingBase  {get; set;}
    public Boolean renderDigitalChannelOptions  {get; set;}
    public Boolean renderInboundSeatAddOnsQM  {get; set;}
    public Boolean renderInboundSeatAddOnsWO  {get; set;}
    public Boolean renderInboundSeatAddOnsOS  {get; set;}            
    public Boolean renderEndUserEndPoints  {get; set;}
    public Boolean renderCloudContactCenterAdapters  {get; set;}
    public Boolean renderTelcoITI  {get; set;}
    public Boolean renderTelcoBLT  {get; set;}
    public Boolean renderTelcoOP  {get; set;}
    public Boolean renderTelcoMPLS  {get; set;}              
    public Boolean renderGenesysCare  {get; set;}
    public Boolean renderTelcoCrossConnect  {get; set;}
    public Boolean renderPSRapidDevelopmentImplementationPackage {get; set;} 
    public Boolean renderPSImplementation {get; set;}
    public Boolean renderInstallationCharges {get; set;}
    public Boolean isFromAttachment {get; set;}              
    public Integer index {get; set;}        
    public Opportunity opp {get; set;}
    public String quoteId {get; set;}
    public String sectionType {get; set;}
    public String updgradeType {get; set;}
    private String showSelected {get; set;}    
    public Boolean isErrorMsg {get; set;}    
    public Map<String, List<SelectOption>> mapProductVsProductDevices {get; set;} 
    public List<SelectOption> supportOptionList {get; set;}
    //Map<String, List<Product_Discount_Lookup__c>> mapProductIdVsPricingDiscount {get; set;}
    private Integer noOfQuoteProducts;
    private Integer iPeriod {get; set;}
    public String oppId {get; set;}
    public transient List<Product_Discount_Lookup__c> productDiscounts;
    
    public List<wrapperQuoteProducts> list_GenesysCloudCare {get; set;}
    public Boolean blnShowGenesysCloudCare {get; private set;}
    public List<wrapperQuoteProducts> list_GUTraining {get; set;}
    public Boolean blnShowGUTraining {get; private set;}
    public List<wrapperQuoteProducts> list_ASRandTTS {get; set;}
    public Boolean blnShowASRandTTS {get; private set;}
    public List<wrapperQuoteProducts> list_BluIP {get; set;}
    public Boolean blnShowBluIP {get; private set;}
    
    public List<wrapperQuoteProducts> list_PerMsgPerMin {get; set;}
    public Boolean blnShowPerMsgPerMin {get; private set;}
    public List<wrapperQuoteProducts> list_SWPlatformImplementation {get; set;}
    public Boolean blnShowSWPlatformImplementation {get; private set;}
    public List<wrapperQuoteProducts> list_ShortLongCodeNonRec {get; set;}
    public Boolean blnShowShortLongCodeNonRec {get; private set;}
    public List<wrapperQuoteProducts> list_ShortLongCodeRec {get; set;}
    public Boolean blnShowShortLongCodeRec {get; private set;}
    public List<wrapperQuoteProducts> list_SWPlatformLicensing {get; set;}
    public Boolean blnShowSWPlatformLicensing {get; private set;}
    
    
    //Anju Jan 2018 PureSuccess starts
    public List<wrapperQuoteProducts> list_PureSuccessBase {get; set;}
    public Boolean blnShowPureSuccessBase {get; private set;}
    public List<wrapperQuoteProducts> list_PureSuccessalaCarte {get; set;}
    public Boolean blnShowPureSuccessalaCarte {get; private set;}
    //Anju Jan 2018 PureSuccess ends
    
    public Boolean blnIsHybridCustomer {get; private set;}
    //public String legalRequestStatus {get; private set;}
    
    public transient List<DealQualificationAndQuoteApprovalHelper.wrapperViolationSummary> list_Violations {get; set;}
    public Boolean hasViolations {get; private set;}
    public String dqStatus {get; set;}
    public Boolean showReviseDQPopup {get; private set;}
    
    //Mukunth added below two variables for DDS Mega Deals
    public boolean isMegaDealBln{get;set;}
    private Global_setting__c CloudPevMultiplierPC;
     
    public DealScoreHistory__c objDDSHistory {get;set;}
      
    public ServiceOrderQuoteToolController(ApexPages.StandardController stdController)
    {
        init();
    }
        
    public void init()
    {             
        updgradeType = ApexPages.currentPage().getParameters().get('upgradeType');
        showSelected = ApexPages.currentPage().getParameters().get('showSelected');
        quoteId = ApexPages.currentPage().getParameters().get('id');
        isFromAttachment = false;
        
        //Mukunth added for DDS Mega Deals - get Cloud PEV Mutliplier from custom setting
        CloudPevMultiplierPC = Global_setting__c.getValues('Cloud PEV Multiplier PEC');
        
        if(quoteId == null)
        {
            quoteId = ApexPages.currentPage().getParameters().get('said');
            if(quoteId != null)
                isFromAttachment = true;
        }
        quote = ServiceOrderQuoteHelper.getQuote(quoteId);
        if(quote.Offering_Type__c == 'Business Edition'){
            objDDSHistory = DDSCloud.fetchDDSHistory(quote.Id);
            //Mukunth added below line for DDS Mega Deals
            if(quote.Annual_Contract_Value__c != null)
                isMegaDealBln = checkMegaDeal();
            else
                isMegaDealBln = false;          
        }
        headerRow = new List<wrapperQuoteProducts>();
        isErrorMsg = false;
        if(quoteId == null)
        {       
            String offeringType = ApexPages.currentPage().getParameters().get('offeringType');  
            String pricingModel = ApexPages.currentPage().getParameters().get('pricingModel');
            System.debug('NKC debug offeringType ['+offeringType+']');    
            quote = ServiceOrderQuoteHelper.getQuote(quoteId);
            quote.BigMachines__Status__c = 'Quote In Progress';
            quote.Initial_Subscription_Term__c = '1 Year';
            quote.Renewal_Subscription_Term__c = 'Automatic Annual';
            quote.Period__c = 'Monthly';
            quote.Billing_Period__c = 'Monthly';
            quote.Order_Payment_Terms__c = 'Net 30';
            quote.Offering_Type__c = offeringType;   
            quote.Pricing_Model__c = pricingModel;
            quote.Quote_Opportunity_Type__c = 'New Pricing';
            List<RecordType> cloudQuoteRecordType = [SELECT id FROM RecordType WHERE SobjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote' LIMIT 1];
            
            if(!cloudQuoteRecordType.isEmpty()) 
                quote.RecordTypeId = cloudQuoteRecordType[0].id;
            
            quote.Quote_Business_Type__c = 'Cloud';  

            if(quoteId != null)
            {                    
                oppId = quote.BigMachines__Opportunity__c;
                //quoteProducts = ServiceOrderQuoteHelper.getQuoteProducts(quoteId);                  
            }
            else
            {
                oppId = ApexPages.currentPage().getParameters().get('oppId');                   
                quote.BigMachines__Opportunity__c = oppId;                      
            }                
        }
        else
        {
            oppId = quote.BigMachines__Opportunity__c;                                            
        }               
        opp = ServiceOrderQuoteHelper.getOpp(oppId);
        
        quote.CurrencyIsoCode = opp.CurrencyIsoCode;
        
        blnIsHybridCustomer = false;
        
        // To check for White Label accounts like Telstra
        if(opp.BusinessPartner__c != null)
            blnIsHybridCustomer = Global_Configuration_Settings__c.getOrgDefaults().Hybrid_Accounts__c.contains(String.valueOf(opp.BusinessPartner__c)) ? true : false;
        
        if(blnIsHybridCustomer)
            return;
        
        //if(quote.MSA_Link__c == null && !quote.Custom_MSLSA__c )
        if(quote.MSA_Link__c == null)
        {
            if(quote.Offering_Type__c == 'Business Edition' || quote.Offering_Type__c == 'Enterprise Edition')
                quote.MSA_Link__c = Label.MSA_Links.split(';;')[0].trim();
            else if(quote.Offering_Type__c == 'Premier Edition' || quote.Offering_Type__c == 'Self Service')
                quote.MSA_Link__c = Label.MSA_Links.split(';;')[1].trim();
            else
                quote.MSA_Link__c = Label.MSA_Links.split(';;')[2].trim();
        }
        
        if(quote.SOW_Link__c == null)
            quote.SOW_Link__c = opp.SOW_Url__c;
        
        populationInit();
        //autopopulate PEC offer - Jan 5 - Anju
        /*
        for(wrapperQuoteProducts eachRecord : list_PureSuccessBase)
        {
            if(quote.Offering_Type__c == 'Business Edition' && (quote.BigMachines__Line_Items__c < 1 || quote.BigMachines__Line_Items__c == null))
            {
                        
                if(eachRecord.record.Product__c == 'PEC-D_Equip' && (quote.BigMachines__Opportunity__r.type == 'New Logo' || quote.BigMachines__Opportunity__r.Cloud_Renewal__c))    
                {
                     //eachRecord.autoSelected = true;
                     eachRecord.selected = true;
                     eachRecord.record.Product_Option__c = 'Yes';
                }
                if(eachRecord.record.Product__c == 'PEC_P_Partner' && (quote.BigMachines__Opportunity__r.type == 'New Logo' || quote.BigMachines__Opportunity__r.Cloud_Renewal__c))    
                {
                     //eachRecord.autoSelected = true;
                     eachRecord.selected = true;
                     eachRecord.record.Product_Option__c = 'Yes';
                }     
            }
        }
        system.debug(list_PureSuccessBase);
        */
        
        if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
            supportOptionList = ServiceOrderQuoteToolHelper.getSupportOptions(quote.Offering_Type__c);
        else
            supportOptionList = ServiceOrderQuoteToolHelper.getSupportOptions(quote.currencyIsoCode);    
        
        dqStatus = 'Not Approved';
        List<Deal_Qualification__c> dqs = [SELECT Status__c FROM Deal_Qualification__c WHERE Type__c =: DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL
            AND Platform_Type__c =:quote.Quote_Business_Type__c AND Offering_Type__c =:quote.Offering_Type__c 
            AND Pricing_Type__c =: quote.Quote_Opportunity_Type__c AND Opportunity__c =: oppId];
        if(!dqs.isEmpty()){
            dqStatus = dqs[0].Status__c;
        }
    }
        
    private void populationInit()
    {
        mapProductVsProductDevices = ServiceOrderQuoteToolHelper.getProductVsProductDevicesMap(quote.CurrencyIsoCode);
        allRecords = ServiceOrderQuoteToolHelper.populateQuoteProducts(quote, quote.Offering_Type__c, updgradeType, showSelected, mapProductVsProductDevices);
        noOfQuoteProducts = allRecords.size();
        populateLists();                
        poulateHeaderRecord();
        renderSupportSubscriptions = renderPerSeatPricingBase = blnShowGUTraining = renderPSImplementation = renderInstallationCharges = true;
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            blnShowSWPlatformLicensing = blnShowShortLongCodeRec = blnShowShortLongCodeNonRec =
            blnShowSWPlatformImplementation = blnShowPerMsgPerMin = renderRransactionBasedSubscriptions = true;
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            renderUserSubscriptions = renderPortSubscriptions = renderCustomerSubscriptions = renderEndUserEndPoints = renderRentedEquipmentSubscriptions = 
            renderTimeBasedSubscriptions = renderRransactionBasedSubscriptions = renderTierSubscriptions = renderProfServicesSubscription = 
            blnShowBluIP = blnShowIVROptions = blnShowInboundSeatAddOns = blnShowAdapterServiceOptions = blnShowOtherOptions = blnShowCommunicationCircuits = 
            blnShowImplementationCharges = blnShowSelfServiceIVR = blnShowSelfServiceIVROptions = blnShowSelfServiceIVRIntegrations = blnShowOutboundCampaignManager = 
            blnShowTelcoOptions = blnShowConnectivityOptions = blnShowPerSeatPricing = true;
        }
        else
        {
            renderClientManagementSubscription = renderIVRAndMediaPortOptions = renderIVRAndMediaPortAddOns = 
            renderDigitalChannelOptions = renderInboundSeatAddOnsQM = renderInboundSeatAddOnsWO =
            renderInboundSeatAddOnsOS = renderEndUserEndPoints = renderCloudContactCenterAdapters = rendertelcoITI = 
            rendertelcoBLT = blnShowShortLongCodeRec  = blnShowShortLongCodeNonRec = blnShowSWPlatformLicensing =
            rendertelcoOP = rendertelcoMPLS = renderGenesysCare = renderTelcoCrossConnect = blnShowSWPlatformImplementation =
            renderPSRapidDevelopmentImplementationPackage = blnShowGenesysCloudCare = blnShowASRandTTS = blnShowAccessFees = 
            blnShowPerMsgPerMin = blnShowPureSuccessBase = blnShowPureSuccessalaCarte = renderBotsAI = true;
        }
        
        if(supportSubscriptions.isEmpty())
            renderSupportSubscriptions = false;
        
        if(perSeatPricingBase.isEmpty())
            renderPerSeatPricingBase = false;
        
        if(list_GUTraining.isEmpty())
            blnShowGUTraining = false;
        
        if(installationCharges.isEmpty())
            renderInstallationCharges = false;
        
        if(psImplementation.isEmpty())
            renderPSImplementation = false;
                
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            if(transactionBasedSubscriptions.isEmpty())
                renderRransactionBasedSubscriptions = false;
            
            if(list_PerMsgPerMin.isEmpty())
                blnShowPerMsgPerMin = false;
            
            if(list_SWPlatformImplementation.isEmpty())
                blnShowSWPlatformImplementation = false;
            
            if(list_ShortLongCodeNonRec.isEmpty())
                blnShowShortLongCodeNonRec = false;
            
            if(list_ShortLongCodeRec.isEmpty())
                blnShowShortLongCodeRec = false;
            
            if(list_SWPlatformLicensing.isEmpty())
                blnShowSWPlatformLicensing = false; 
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(userSubscriptions.isEmpty())
                renderUserSubscriptions = false;
            
            if(portSubscriptions.isEmpty())
                renderPortSubscriptions = false;
            
            if(customerSubscriptions.isEmpty())
                renderCustomerSubscriptions = false;
            
            if(rentedEquipmentSubscriptions.isEmpty())
                renderRentedEquipmentSubscriptions = false;
            
            if(timeBasedSubscriptions.isEmpty())
                renderTimeBasedSubscriptions = false;
            
            if(transactionBasedSubscriptions.isEmpty())
                renderRransactionBasedSubscriptions = false;
            
            if(tierSubscriptions.isEmpty())
                renderTierSubscriptions = false;
            
            if(configurationProfServicesSubscriptions.isEmpty())
                renderProfServicesSubscription = false;
            
            if(clientManagementSubscriptions.isEmpty())
                renderClientManagementSubscription = false;
            
            if(list_BluIP.isEmpty())
                blnShowBluIP = false;
            
            if(list_IVROptions.isEmpty())
                blnShowIVROptions = false;
            
            if(list_InboundSeatAddOns.isEmpty())
                blnShowInboundSeatAddOns = false;
            
            if(endUserEndPoints.isEmpty())
                renderEndUserEndPoints = false;
            
            if(list_AdapterServiceOptions.isEmpty())
                blnShowAdapterServiceOptions = false;
            
            if(list_OtherOptions.isEmpty())
                blnShowOtherOptions = false;
            
            if(list_CommunicationCircuits.isEmpty())
                blnShowCommunicationCircuits = false;
            
            if(list_ImplementationCharges.isEmpty())
                blnShowImplementationCharges = false;
            
            if(list_SelfServiceIVR.isEmpty())
                blnShowSelfServiceIVR = false;
            
            if(list_SelfServiceIVROptions.isEmpty())
                blnShowSelfServiceIVROptions = false;
            
            if(list_SelfServiceIVRIntegrations.isEmpty())
                blnShowSelfServiceIVRIntegrations = false;
            
            if(list_OutboundCampaignManager.isEmpty())
                blnShowOutboundCampaignManager = false;
            
            if(list_TelcoOptions.isEmpty())
                blnShowTelcoOptions = false;
            
            if(list_ConnectivityOptions.isEmpty())
                blnShowConnectivityOptions = false;
            
            if(list_PerSeatPricing.isEmpty())
                blnShowPerSeatPricing = false;
            
            
        }
        else
        {
            if(IVRAndMediaPortOptions.isEmpty())
                renderIVRAndMediaPortOptions = false;
            
            if (BotsAIOptions.isEmpty())
                renderBotsAI = false;
                
            if(list_AccessFees.isEmpty())
                blnShowAccessFees = false;
            
            if(IVRAndMediaPortAddOns.isEmpty())
                renderIVRAndMediaPortAddOns = false;
            
            if(digitalChannelOptions.isEmpty())
                renderDigitalChannelOptions= false;
            
            if(inboundSeatAddOnsQM.isEmpty())
                renderInboundSeatAddOnsQM = false;
            
            if(inboundSeatAddOnsWO.isEmpty())
                renderInboundSeatAddOnsWO = false;
            
            if(inboundSeatAddOnsOS.isEmpty())
                renderInboundSeatAddOnsOS = false;                  
            
            if(endUserEndPoints.isEmpty())
                renderEndUserEndPoints = false;
            
            if(cloudContactCenterAdapters.isEmpty())
                renderCloudContactCenterAdapters = false;
            
            if(telcoITI.isEmpty())
                renderTelcoITI = false;
            
            if(telcoBLT.isEmpty())
                renderTelcoBLT = false;
            
            if(telcoOP.isEmpty())
                renderTelcoOP = false;
            
            if(telcoMPLS.isEmpty())
                renderTelcoMPLS = false;
            
            if(genesysCare.isEmpty())
                renderGenesysCare = false;
            
            if(telcoCrossConnect.isEmpty())
                renderTelcoCrossConnect = false;
            
            if(psRapidDevelopmentImplementationPackage.isEmpty())
                renderPSRapidDevelopmentImplementationPackage = false;

            if(list_GenesysCloudCare.isEmpty())
                blnShowGenesysCloudCare = false;
                
            if(list_ASRandTTS.isEmpty())
                blnShowASRandTTS = false;
                
            if(list_ShortLongCodeNonRec.isEmpty())
                blnShowShortLongCodeNonRec = false;
            
            if(list_ShortLongCodeRec.isEmpty())
                blnShowShortLongCodeRec = false;
            
            if(list_SWPlatformImplementation.isEmpty())
                blnShowSWPlatformImplementation = false;     
                
            if(list_SWPlatformLicensing.isEmpty())
                blnShowSWPlatformLicensing = false; 
                
            if(list_PerMsgPerMin.isEmpty())
                blnShowPerMsgPerMin = false;           
            //Anju Jan 2018 PureSuccess starts
            if(list_PureSuccessBase.isEmpty())
                blnShowPureSuccessBase = false;
            if(list_PureSuccessalaCarte.isEmpty())
                blnShowPureSuccessalaCarte = false;
            //Anju Jan 2018 PureSuccess ends
        }
        
        Set<String> selectededProductIds = new Set<String>();
        Set<String> notSelectededProductIds = new Set<String>();
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : allRecords)
        {
            if(eachRecord.selected != null && eachRecord.selected)
                selectededProductIds.add(eachRecord.record.BigMachines__Product__c);                    
            else
                notSelectededProductIds.add(eachRecord.record.BigMachines__Product__c);
        }
        ServiceOrderQuoteToolHelper.autoSelectDependingProducts(allRecords, selectededProductIds, notSelectededProductIds);
        
        
    }
        
    public void poulateHeaderRecord()
    {
        if(headerRow.isEmpty())
            headerRow = ServiceOrderQuoteToolHelper.poulateHeaderRecord(headerRow);
    }
        
    private void populateLists()
    {
        supportSubscriptions = new List<wrapperQuoteProducts>();
        perSeatPricingBase = new List<wrapperQuoteProducts>();
        list_GUTraining = new List<wrapperQuoteProducts>();
        InstallationCharges = new List<wrapperQuoteProducts>();
        psImplementation = new List<wrapperQuoteProducts>();
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            transactionBasedSubscriptions = new List<wrapperQuoteProducts>();
            list_PerMsgPerMin = new List<wrapperQuoteProducts>();
            list_SWPlatformImplementation = new List<wrapperQuoteProducts>();
            list_ShortLongCodeNonRec = new List<wrapperQuoteProducts>();
            list_ShortLongCodeRec = new List<wrapperQuoteProducts>();
            list_SWPlatformLicensing = new List<wrapperQuoteProducts>();
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            userSubscriptions = new List<wrapperQuoteProducts>();
            portSubscriptions = new List<wrapperQuoteProducts>();
            customerSubscriptions = new List<wrapperQuoteProducts>();
            rentedEquipmentSubscriptions = new List<wrapperQuoteProducts>();
            timeBasedSubscriptions = new List<wrapperQuoteProducts>();
            transactionBasedSubscriptions = new List<wrapperQuoteProducts>();
            tierSubscriptions = new List<wrapperQuoteProducts>();             
            configurationProfServicesSubscriptions = new List<wrapperQuoteProducts>();
            clientManagementSubscriptions = new List<wrapperQuoteProducts>();
            list_BluIP = new List<wrapperQuoteProducts>();
            list_IVROptions = new List<wrapperQuoteProducts>();
            list_InboundSeatAddOns = new List<wrapperQuoteProducts>();
            endUserEndPoints = new List<wrapperQuoteProducts>();
            list_AdapterServiceOptions = new List<wrapperQuoteProducts>();
            list_OtherOptions = new List<wrapperQuoteProducts>();
            list_CommunicationCircuits = new List<wrapperQuoteProducts>();
            list_ImplementationCharges = new List<wrapperQuoteProducts>();
            list_SelfServiceIVR = new List<wrapperQuoteProducts>();
            list_SelfServiceIVROptions = new List<wrapperQuoteProducts>();
            list_SelfServiceIVRIntegrations = new List<wrapperQuoteProducts>();
            list_OutboundCampaignManager = new List<wrapperQuoteProducts>();
            list_TelcoOptions = new List<wrapperQuoteProducts>();
            list_ConnectivityOptions = new List<wrapperQuoteProducts>();
            list_PerSeatPricing = new List<wrapperQuoteProducts>();
            
        }
        else
        {
            IVRAndMediaPortOptions = new List<wrapperQuoteProducts>();
            BotsAIOptions = new List<wrapperQuoteProducts>();
            list_AccessFees =  new List<wrapperQuoteProducts>();
            IVRAndMediaPortAddOns = new List<wrapperQuoteProducts>();
            digitalChannelOptions = new List<wrapperQuoteProducts>();
            inboundSeatAddOnsQM = new List<wrapperQuoteProducts>();
            inboundSeatAddOnsWO = new List<wrapperQuoteProducts>();
            inboundSeatAddOnsOS = new List<wrapperQuoteProducts>();                                   
            endUserEndPoints = new List<wrapperQuoteProducts>();
            cloudContactCenterAdapters = new List<wrapperQuoteProducts>();
            telcoITI = new List<wrapperQuoteProducts>();
            telcoBLT = new List<wrapperQuoteProducts>();
            telcoOP = new List<wrapperQuoteProducts>();
            telcoMPLS = new List<wrapperQuoteProducts>();                                     
            genesysCare = new List<wrapperQuoteProducts>();
            telcoCrossConnect = new List<wrapperQuoteProducts>();
            psRapidDevelopmentImplementationPackage = new List<wrapperQuoteProducts>();
            list_GenesysCloudCare = new List<wrapperQuoteProducts>();
            list_ASRandTTS = new List<wrapperQuoteProducts>();
            list_ShortLongCodeNonRec = new List<wrapperQuoteProducts>();
            list_ShortLongCodeRec = new List<wrapperQuoteProducts>();
            list_SWPlatformImplementation = new List<wrapperQuoteProducts>();
            list_SWPlatformLicensing = new List<wrapperQuoteProducts>();
            list_PerMsgPerMin = new List<wrapperQuoteProducts>();
            
            //Anju Jan 2018 PureSuccess starts
            list_PureSuccessBase = new List<wrapperQuoteProducts>();
            list_PureSuccessalaCarte = new List<wrapperQuoteProducts>();
            //Anju Jan 2018 PureSuccess ends
        }
        
        for(wrapperQuoteProducts eachRecord : allRecords)
        {
            System.debug('NKC debug eachRecord.record.Product_Group__c ['+eachRecord.record.Product_Group__c+']');
            
            if(eachRecord.record.Product_Group__c == null)
                continue;
            
            if(eachRecord.record.Product_Group__c.equals('Support'))
            {
                eachRecord.record.BigMachines__Quantity__c = 1;
                supportSubscriptions.add(eachRecord);
            }
            
            else if(eachRecord.record.Product_Group__c.equals('Per Seat Pricing (Base Options)'))
                perSeatPricingBase.add(eachRecord);
            
            else if(eachRecord.record.Product_Group__c == 'Genesys University Training')
                list_GUTraining.add(eachRecord);
                
            else if(eachRecord.record.Product_Group__c.equals('Installation'))
                installationCharges.add(eachRecord);
            
            else if(eachRecord.record.Product_Group__c.equals('Professional Services Implementation'))
                psImplementation.add(eachRecord);
            
            if(quote.Offering_Type__c == 'Outbound Engagement')
            {
                if(eachRecord.record.Product_Group__c.equals('Transaction Based'))
                    transactionBasedSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Per Message/Per Minute'))                              
                    list_PerMsgPerMin.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('SW/Platform Implementation'))
                    list_SWPlatformImplementation.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Short/Long Code Non Recurring Fees'))
                    list_ShortLongCodeNonRec.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Short/Long Code Recurring Fees'))
                    list_ShortLongCodeRec.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('SW/Platform Licensing'))
                    list_SWPlatformLicensing.add(eachRecord);
            }
            else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
            {
                if(eachRecord.record.Product_Group__c.equals('User Subscription'))                              
                    userSubscriptions.add(eachRecord);                        
                
                else if(eachRecord.record.Product_Group__c.equals('Port Subscription'))
                    portSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Customer Subscription'))
                    customerSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Rented Equipment/Communication Fees/Short Codes'))
                    rentedEquipmentSubscriptions.add(eachRecord);                           
                
                else if(eachRecord.record.Product_Group__c.equals('Time Based'))
                    timeBasedSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Transaction Based'))
                    transactionBasedSubscriptions.add(eachRecord);                         
                
                else if(eachRecord.record.Product_Group__c.equals('Tier Based'))
                   tierSubscriptions.add(eachRecord);                                
                
                else if(eachRecord.record.Product_Group__c.equals('Configuration Professional Services'))
                    configurationProfServicesSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Client Management'))
                    clientManagementSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('BluIP'))
                    list_BluIP.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('IVR Options'))
                    list_IVROptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Inbound Seat Add-On Options'))
                    list_InboundSeatAddOns.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('End User End Points'))
                    endUserEndPoints.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Adapter Service Options'))
                    list_AdapterServiceOptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Other Options'))
                    list_OtherOptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Communication Circuits'))
                    list_CommunicationCircuits.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Implementation Charges'))
                    list_ImplementationCharges.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Self-Service/IVR'))
                    list_SelfServiceIVR.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Self-Service/IVR Options'))
                    list_SelfServiceIVROptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Self-Service/IVR Integrations'))
                    list_SelfServiceIVRIntegrations.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Outbound Campaign Manager'))
                    list_OutboundCampaignManager.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Telecommunications Options'))
                    list_TelcoOptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Connectivity Options'))
                    list_ConnectivityOptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Per Seat Pricing'))
                    list_PerSeatPricing.add(eachRecord);
            }
            else
            { 
                if(eachRecord.record.Product_Group__c.equals('IVR and Media Port Options'))
                    IVRAndMediaPortOptions.add(eachRecord);
                    
                if (eachRecord.record.Product_Group__c.equals('Bots and AI'))
                    BotsAIOptions.add(eachRecord);
                    
                if(eachRecord.record.Product_Group__c.equals('Access Fees'))
                    list_AccessFees.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('IVR / Media Port Add Ons'))
                    IVRAndMediaPortAddOns.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Digital Channels Options'))
                    digitalChannelOptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Quality Management'))
                    inboundSeatAddOnsQM.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Workforce Optimization'))
                    inboundSeatAddOnsWO.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Other Services'))
                    inboundSeatAddOnsOS.add(eachRecord);                                    
                
                else if(eachRecord.record.Product_Group__c.equals('End User End Points'))
                    endUserEndPoints.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Cloud Contact Center Adapters'))
                    cloudContactCenterAdapters.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Inbound to IVR'))
                    telcoITI.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Bridging Leg / Transfer to PSTN or PLMN'))
                    telcoBLT.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Outbound to PSTN or PLMN'))
                    telcoOP.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('MPLS'))
                    telcoMPLS.add(eachRecord);                              
                
                else if(eachRecord.record.Product_Group__c.equals('Genesys Care'))
                    genesysCare.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Telco Cross Connect'))
                    telcoCrossConnect.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Professional Services Rapid Deployment ImplementationPackages'))
                    psRapidDevelopmentImplementationPackage.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c == 'Genesys Cloud Care')
                    list_GenesysCloudCare.add(eachRecord);
                    
                else if(eachRecord.record.Product_Group__c == 'ASR and TTS')
                    list_ASRandTTS.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Short/Long Code Non Recurring Fees'))
                    list_ShortLongCodeNonRec.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c.equals('Short/Long Code Recurring Fees'))
                    list_ShortLongCodeRec.add(eachRecord);
                    
                else if(eachRecord.record.Product_Group__c.equals('SW/Platform Implementation'))
                    list_SWPlatformImplementation.add(eachRecord);
                    
                else if(eachRecord.record.Product_Group__c.equals('SW/Platform Licensing'))
                    list_SWPlatformLicensing.add(eachRecord);   
                    
                else if(eachRecord.record.Product_Group__c.equals('Per Message/Per Minute'))                              
                    list_PerMsgPerMin.add(eachRecord);   
                    
                //Anju Jan 2018 PureSuccess starts 
                else if(eachRecord.record.Product_Group__c.equals('PureSuccess Direct Offer') && quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c != 'Indirect')                              
                    list_PureSuccessBase.add(eachRecord);                    
                else if(eachRecord.record.Product_Group__c.equals('PureSuccess Direct A-la-Carte') && quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c != 'Indirect')                              
                    list_PureSuccessalaCarte.add(eachRecord);  
                else if(eachRecord.record.Product_Group__c.equals('PureSuccess Indirect Offer') && quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect')                              
                    list_PureSuccessBase.add(eachRecord);                    
                else if(eachRecord.record.Product_Group__c.equals('PureSuccess Indirect A-la-Carte') && quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect')                              
                    list_PureSuccessalaCarte.add(eachRecord); 
                //Anju Jan 2018 PureSuccess ends
                  
            }                             
        }
        
        if(!supportSubscriptions.isEmpty())
            supportSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(supportSubscriptions, 'Support');
        
        if(!perSeatPricingBase.isEmpty())
            perSeatPricingBase = ServiceOrderQuoteToolHelper.addTotalRow(perSeatPricingBase, 'Per Seat Pricing (Base Options)');
        
        if(!list_GUTraining.isEmpty())
            list_GUTraining = ServiceOrderQuoteToolHelper.addTotalRow(list_GUTraining, 'Genesys University Training');
        
        if(!installationCharges.isEmpty())
            installationCharges = ServiceOrderQuoteToolHelper.addTotalRow(installationCharges, 'Installation');
        
        if(!psImplementation.isEmpty())
            psImplementation = ServiceOrderQuoteToolHelper.addTotalRow(psImplementation, 'Professional Services Implementation');
            
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            if(!transactionBasedSubscriptions.isEmpty())
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(transactionBasedSubscriptions, 'Transaction Based');
            
            if(!list_PerMsgPerMin.isEmpty())
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.addTotalRow(list_PerMsgPerMin, 'Per Message/Per Minute');

            if(!list_SWPlatformImplementation.isEmpty())
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.addTotalRow(list_SWPlatformImplementation, 'SW/Platform Implementation');
            
            if(!list_ShortLongCodeNonRec.isEmpty())
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.addTotalRow(list_ShortLongCodeNonRec, 'Short/Long Code Non Recurring Fees');
            
            if(!list_ShortLongCodeRec.isEmpty())
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.addTotalRow(list_ShortLongCodeRec, 'Short/Long Code Recurring Fees');
            
            if(!list_SWPlatformLicensing.isEmpty())
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.addTotalRow(list_SWPlatformLicensing, 'SW/Platform Licensing');
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(!userSubscriptions.isEmpty())
                userSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(userSubscriptions, 'User Subscription');
            
            if(!portSubscriptions.isEmpty())
                portSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(portSubscriptions, 'Port Subscription');
            
            if(!rentedEquipmentSubscriptions.isEmpty())
                rentedEquipmentSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(rentedEquipmentSubscriptions, 'Rented Equipment/Communication Fees/Short Codes');

            if(!timeBasedSubscriptions.isEmpty())
                timeBasedSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(timeBasedSubscriptions, 'Time Based');
            
            if(!transactionBasedSubscriptions.isEmpty())
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(transactionBasedSubscriptions, 'Transaction Based');
            
            if(!tierSubscriptions.isEmpty())
               tierSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(tierSubscriptions, 'Tier Based');       
            
            if(!configurationProfServicesSubscriptions.isEmpty())
                configurationProfServicesSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(configurationProfServicesSubscriptions, 'Configuration Professional Services');       
            
            if(!clientManagementSubscriptions.isEmpty())
                clientManagementSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(clientManagementSubscriptions, 'Client Management');       
            
            if(!customerSubscriptions.isEmpty())
                customerSubscriptions = ServiceOrderQuoteToolHelper.addTotalRow(customerSubscriptions, 'Customer Subscription');

            if(!list_BluIP.isEmpty())
                list_BluIP = ServiceOrderQuoteToolHelper.addTotalRow(list_BluIP, 'BluIP');
            
            if(!list_IVROptions.isEmpty())
                list_IVROptions = ServiceOrderQuoteToolHelper.addTotalRow(list_IVROptions, 'IVR Options');
            
            if(!list_InboundSeatAddOns.isEmpty())
                list_InboundSeatAddOns = ServiceOrderQuoteToolHelper.addTotalRow(list_InboundSeatAddOns, 'Inbound Seat Add-On Options');
            
            if(!endUserEndPoints.isEmpty())
                endUserEndPoints = ServiceOrderQuoteToolHelper.addTotalRow(endUserEndPoints, 'End User End Points');
            
            if(!list_AdapterServiceOptions.isEmpty())
                list_AdapterServiceOptions = ServiceOrderQuoteToolHelper.addTotalRow(list_AdapterServiceOptions, 'Adapter Service Options');
            
            if(!list_OtherOptions.isEmpty())
                list_OtherOptions = ServiceOrderQuoteToolHelper.addTotalRow(list_OtherOptions, 'Other Options');
            
            if(!list_CommunicationCircuits.isEmpty())
                list_CommunicationCircuits = ServiceOrderQuoteToolHelper.addTotalRow(list_CommunicationCircuits, 'Communication Circuits');
            
            if(!list_ImplementationCharges.isEmpty())
                list_ImplementationCharges = ServiceOrderQuoteToolHelper.addTotalRow(list_ImplementationCharges, 'Implementation Charges');
            
            if(!list_SelfServiceIVR.isEmpty())
                list_SelfServiceIVR = ServiceOrderQuoteToolHelper.addTotalRow(list_SelfServiceIVR, 'Self-Service/IVR');
            
            if(!list_SelfServiceIVROptions.isEmpty())
                list_SelfServiceIVROptions = ServiceOrderQuoteToolHelper.addTotalRow(list_SelfServiceIVROptions, 'Self-Service/IVR Options');
            
            if(!list_SelfServiceIVRIntegrations.isEmpty())
                list_SelfServiceIVRIntegrations = ServiceOrderQuoteToolHelper.addTotalRow(list_SelfServiceIVRIntegrations, 'Self-Service/IVR Integrations');
            
            if(!list_OutboundCampaignManager.isEmpty())
                list_OutboundCampaignManager = ServiceOrderQuoteToolHelper.addTotalRow(list_OutboundCampaignManager, 'Outbound Campaign Manager');
            
            if(!list_TelcoOptions.isEmpty())
                list_TelcoOptions = ServiceOrderQuoteToolHelper.addTotalRow(list_TelcoOptions, 'Telecommunications Options');
            
            if(!list_ConnectivityOptions.isEmpty())
                list_ConnectivityOptions = ServiceOrderQuoteToolHelper.addTotalRow(list_ConnectivityOptions, 'Connectivity Options');
            
            if(!list_PerSeatPricing.isEmpty())
                list_PerSeatPricing = ServiceOrderQuoteToolHelper.addTotalRow(list_PerSeatPricing, 'Per Seat Pricing');
        }   
        else
        {
            if(!IVRAndMediaPortOptions.isEmpty())
                IVRAndMediaPortOptions = ServiceOrderQuoteToolHelper.addTotalRow(IVRAndMediaPortOptions, 'IVR and Media Port Options');
            
            if (!BotsAIOptions.isEmpty())
                BotsAIOptions = ServiceOrderQuoteToolHelper.addTotalRow(BotsAIOptions, 'Bots and AI');
                
            if(!list_AccessFees.isEmpty())
                list_AccessFees = ServiceOrderQuoteToolHelper.addTotalRow(list_AccessFees, 'Access Fees');
            
            if(!IVRAndMediaPortAddOns.isEmpty())
                IVRAndMediaPortAddOns = ServiceOrderQuoteToolHelper.addTotalRow(IVRAndMediaPortAddOns, 'IVR / Media Port Add Ons');
            
            if(!digitalChannelOptions.isEmpty())
                digitalChannelOptions = ServiceOrderQuoteToolHelper.addTotalRow(digitalChannelOptions, 'Digital Channels Options');
            
            if(!inboundSeatAddOnsQM.isEmpty())
                inboundSeatAddOnsQM = ServiceOrderQuoteToolHelper.addTotalRow(inboundSeatAddOnsQM, 'Quality Management');
            
            if(!inboundSeatAddOnsWO.isEmpty())
                inboundSeatAddOnsWO = ServiceOrderQuoteToolHelper.addTotalRow(inboundSeatAddOnsWO, 'Workforce Optimization');
            
            if(!inboundSeatAddOnsOS.isEmpty())
                inboundSeatAddOnsOS = ServiceOrderQuoteToolHelper.addTotalRow(inboundSeatAddOnsOS, 'Other Services');                   
            
            if(!endUserEndPoints.isEmpty())
                endUserEndPoints = ServiceOrderQuoteToolHelper.addTotalRow(endUserEndPoints, 'End User End Points');
            
            if(!cloudContactCenterAdapters.isEmpty())
                cloudContactCenterAdapters = ServiceOrderQuoteToolHelper.addTotalRow(cloudContactCenterAdapters, 'Cloud Contact Center Adapters');
            
            if(!telcoITI.isEmpty())
                telcoITI = ServiceOrderQuoteToolHelper.addTotalRow(telcoITI, 'Inbound to IVR');
            
            if(!telcoBLT.isEmpty())
                telcoBLT = ServiceOrderQuoteToolHelper.addTotalRow(telcoBLT, 'Bridging Leg / Transfer to PSTN or PLMN');
            
            if(!telcoOP.isEmpty())
                telcoOP = ServiceOrderQuoteToolHelper.addTotalRow(telcoOP, 'Outbound to PSTN or PLMN');
            
            if(!telcoMPLS.isEmpty())
                telcoMPLS = ServiceOrderQuoteToolHelper.addTotalRow(telcoMPLS, 'MPLS');                 
            
            if(!genesysCare.isEmpty())
                genesysCare = ServiceOrderQuoteToolHelper.addTotalRow(genesysCare, 'Genesys Care');
            
            if(!telcoCrossConnect.isEmpty())
                telcoCrossConnect = ServiceOrderQuoteToolHelper.addTotalRow(telcoCrossConnect, 'Telco Cross Connect');
            
            if(!psRapidDevelopmentImplementationPackage.isEmpty())
                psRapidDevelopmentImplementationPackage = ServiceOrderQuoteToolHelper.addTotalRow(psRapidDevelopmentImplementationPackage, 'Professional Services Rapid Deployment ImplementationPackages');
                
            if(!list_GenesysCloudCare.isEmpty())
                list_GenesysCloudCare = ServiceOrderQuoteToolHelper.addTotalRow(list_GenesysCloudCare, 'Genesys Cloud Care');
                
            if(!list_ASRandTTS.isEmpty())
                list_ASRandTTS = ServiceOrderQuoteToolHelper.addTotalRow(list_ASRandTTS, 'ASR and TTS');
            
            if(!list_ShortLongCodeNonRec.isEmpty())
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.addTotalRow(list_ShortLongCodeNonRec, 'Short/Long Code Non Recurring Fees');
            
            if(!list_ShortLongCodeRec.isEmpty())
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.addTotalRow(list_ShortLongCodeRec, 'Short/Long Code Recurring Fees');
                
            if(!list_SWPlatformImplementation.isEmpty())
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.addTotalRow(list_SWPlatformImplementation, 'SW/Platform Implementation');
                
            if(!list_SWPlatformLicensing.isEmpty())
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.addTotalRow(list_SWPlatformLicensing, 'SW/Platform Licensing');
                
            if(!list_PerMsgPerMin.isEmpty())
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.addTotalRow(list_PerMsgPerMin, 'Per Message/Per Minute');
            
            //Anju Jan 2018 PureSuccess starts
            if(!list_PureSuccessBase.isEmpty())
                list_PureSuccessBase = ServiceOrderQuoteToolHelper.addTotalRow(list_PureSuccessBase, 'Puresuccess Direct Offer');
                
            if(!list_PureSuccessalaCarte.isEmpty())
                list_PureSuccessalaCarte = ServiceOrderQuoteToolHelper.addTotalRow(list_PureSuccessalaCarte, 'PureSuccess Direct A-la-Carte');
            //Anju Jan 2018 PureSuccess ends
        }
        
        iPeriod = ServiceOrderQuoteToolHelper.setIPeriod(quote.Period__c);                      
        calculateTotals();               
    }
        
        
    public void bulkUpdate()
    {
        supportSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(supportSubscriptions, headerRow);
        perSeatPricingBase = ServiceOrderQuoteToolHelper.bulkUpdate(perSeatPricingBase, headerRow);
        list_GUTraining = ServiceOrderQuoteToolHelper.bulkUpdate(list_GUTraining, headerRow);
        installationCharges = ServiceOrderQuoteToolHelper.bulkUpdate(installationCharges, headerRow);
        psImplementation = ServiceOrderQuoteToolHelper.bulkUpdate(psImplementation, headerRow);
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(transactionBasedSubscriptions, headerRow);
            list_PerMsgPerMin = ServiceOrderQuoteToolHelper.bulkUpdate(list_PerMsgPerMin, headerRow);
            list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.bulkUpdate(list_SWPlatformImplementation, headerRow);
            list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.bulkUpdate(list_ShortLongCodeNonRec, headerRow);
            list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.bulkUpdate(list_ShortLongCodeRec, headerRow);
            list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.bulkUpdate(list_SWPlatformLicensing, headerRow);
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            userSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(userSubscriptions, headerRow);
            portSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(portSubscriptions, headerRow);
            customerSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(customerSubscriptions, headerRow);
            rentedEquipmentSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(rentedEquipmentSubscriptions, headerRow);     
            timeBasedSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(timeBasedSubscriptions, headerRow);
            transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(transactionBasedSubscriptions, headerRow);
            configurationProfServicesSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(configurationProfServicesSubscriptions, headerRow);
            clientManagementSubscriptions = ServiceOrderQuoteToolHelper.bulkUpdate(clientManagementSubscriptions, headerRow);
            list_BluIP = ServiceOrderQuoteToolHelper.bulkUpdate(list_BluIP, headerRow);
            list_IVROptions = ServiceOrderQuoteToolHelper.bulkUpdate(list_IVROptions, headerRow);
            list_InboundSeatAddOns = ServiceOrderQuoteToolHelper.bulkUpdate(list_InboundSeatAddOns, headerRow);
            endUserEndPoints = ServiceOrderQuoteToolHelper.bulkUpdate(endUserEndPoints, headerRow);
            list_AdapterServiceOptions = ServiceOrderQuoteToolHelper.bulkUpdate(list_AdapterServiceOptions, headerRow);
            list_OtherOptions = ServiceOrderQuoteToolHelper.bulkUpdate(list_OtherOptions, headerRow);
            list_CommunicationCircuits = ServiceOrderQuoteToolHelper.bulkUpdate(list_CommunicationCircuits, headerRow);
            list_ImplementationCharges = ServiceOrderQuoteToolHelper.bulkUpdate(list_ImplementationCharges, headerRow);
            list_SelfServiceIVR = ServiceOrderQuoteToolHelper.bulkUpdate(list_SelfServiceIVR, headerRow);
            list_SelfServiceIVROptions = ServiceOrderQuoteToolHelper.bulkUpdate(list_SelfServiceIVROptions, headerRow);
            list_SelfServiceIVRIntegrations = ServiceOrderQuoteToolHelper.bulkUpdate(list_SelfServiceIVRIntegrations, headerRow);
            list_OutboundCampaignManager = ServiceOrderQuoteToolHelper.bulkUpdate(list_OutboundCampaignManager, headerRow);
            list_TelcoOptions = ServiceOrderQuoteToolHelper.bulkUpdate(list_TelcoOptions, headerRow);
            list_ConnectivityOptions = ServiceOrderQuoteToolHelper.bulkUpdate(list_ConnectivityOptions, headerRow);
            list_PerSeatPricing = ServiceOrderQuoteToolHelper.bulkUpdate(list_PerSeatPricing, headerRow);
        }
        else
        {
            IVRAndMediaPortOptions = ServiceOrderQuoteToolHelper.bulkUpdate(IVRAndMediaPortOptions, headerRow);
            BotsAIOptions = ServiceOrderQuoteToolHelper.bulkUpdate(BotsAIOptions, headerRow);
            list_AccessFees = ServiceOrderQuoteToolHelper.bulkUpdate(list_AccessFees, headerRow);
            IVRAndMediaPortAddOns = ServiceOrderQuoteToolHelper.bulkUpdate(IVRAndMediaPortAddOns, headerRow);
            digitalChannelOptions = ServiceOrderQuoteToolHelper.bulkUpdate(digitalChannelOptions, headerRow);  
            inboundSeatAddOnsQM = ServiceOrderQuoteToolHelper.bulkUpdate(inboundSeatAddOnsQM, headerRow);
            inboundSeatAddOnsWO = ServiceOrderQuoteToolHelper.bulkUpdate(inboundSeatAddOnsWO, headerRow);
            inboundSeatAddOnsOS = ServiceOrderQuoteToolHelper.bulkUpdate(inboundSeatAddOnsOS, headerRow);                     
            endUserEndPoints = ServiceOrderQuoteToolHelper.bulkUpdate(endUserEndPoints, headerRow);  
            cloudContactCenterAdapters = ServiceOrderQuoteToolHelper.bulkUpdate(cloudContactCenterAdapters, headerRow);  
            telcoITI = ServiceOrderQuoteToolHelper.bulkUpdate(telcoITI, headerRow);
            telcoBLT = ServiceOrderQuoteToolHelper.bulkUpdate(telcoBLT, headerRow);
            telcoOP = ServiceOrderQuoteToolHelper.bulkUpdate(telcoOP, headerRow);
            telcoMPLS = ServiceOrderQuoteToolHelper.bulkUpdate(telcoMPLS, headerRow);                         
            genesysCare = ServiceOrderQuoteToolHelper.bulkUpdate(genesysCare, headerRow);  
            telcoCrossConnect = ServiceOrderQuoteToolHelper.bulkUpdate(telcoCrossConnect, headerRow);  
            psRapidDevelopmentImplementationPackage = ServiceOrderQuoteToolHelper.bulkUpdate(psRapidDevelopmentImplementationPackage, headerRow);  
            list_GenesysCloudCare = ServiceOrderQuoteToolHelper.bulkUpdate(list_GenesysCloudCare, headerRow);
            list_ASRandTTS = ServiceOrderQuoteToolHelper.bulkUpdate(list_ASRandTTS, headerRow);
            list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.bulkUpdate(list_ShortLongCodeNonRec, headerRow);
            list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.bulkUpdate(list_ShortLongCodeRec, headerRow);
            list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.bulkUpdate(list_SWPlatformImplementation, headerRow);
            list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.bulkUpdate(list_SWPlatformLicensing, headerRow);
            list_PerMsgPerMin = ServiceOrderQuoteToolHelper.bulkUpdate(list_PerMsgPerMin, headerRow);
            
            //Anju Jan 2018 PureSuccess starts
            list_PureSuccessBase = ServiceOrderQuoteToolHelper.bulkUpdate(list_PureSuccessBase, headerRow);
            list_PureSuccessalaCarte = ServiceOrderQuoteToolHelper.bulkUpdate(list_PureSuccessalaCarte, headerRow);
            //Anju Jan 2018 PureSuccess ends
        }         
        bulkCalculationForAll(true);
    }
        
    public void bulkCalculation()
    {
        bulkCalculationForAll(false);
    }
        
    private void bulkCalculationForAll(Boolean onlySelected)
    {
        index = 0;
        System.debug('NKC debug quote.Offering_Type__c ['+quote.Offering_Type__c+']');
        productDiscounts = ServiceOrderQuoteToolHelper.getProductDiscountLookupRecords();
        bulkCalculateEachSection(onlySelected, perSeatPricingBase);
        bulkCalculateEachSection(onlySelected, list_GUTraining);
        bulkCalculateEachSection(onlySelected, installationCharges);
        bulkCalculateEachSection(onlySelected, psImplementation);
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            bulkCalculateEachSection(onlySelected, transactionBasedSubscriptions);
            bulkCalculateEachSection(onlySelected,list_PerMsgPerMin);
            bulkCalculateEachSection(onlySelected, list_SWPlatformImplementation);
            bulkCalculateEachSection(onlySelected, list_ShortLongCodeNonRec);
            bulkCalculateEachSection(onlySelected, list_ShortLongCodeRec);
            bulkCalculateEachSection(onlySelected, list_SWPlatformLicensing);
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            bulkCalculateEachSection(onlySelected, userSubscriptions);
            bulkCalculateEachSection(onlySelected, portSubscriptions);
            bulkCalculateEachSection(onlySelected, rentedEquipmentSubscriptions);
            bulkCalculateEachSection(onlySelected, timeBasedSubscriptions);
            bulkCalculateEachSection(onlySelected, transactionBasedSubscriptions);
            bulkCalculateEachSection(onlySelected, tierSubscriptions);
            bulkCalculateEachSection(onlySelected, configurationProfServicesSubscriptions);
            bulkCalculateEachSection(onlySelected, clientManagementSubscriptions);
            bulkCalculateEachSection(onlySelected, list_BluIP);
            bulkCalculateEachSection(onlySelected, list_IVROptions);
            bulkCalculateEachSection(onlySelected, list_InboundSeatAddOns);
            bulkCalculateEachSection(onlySelected, endUserEndPoints);
            bulkCalculateEachSection(onlySelected, list_AdapterServiceOptions);
            bulkCalculateEachSection(onlySelected, list_OtherOptions);
            bulkCalculateEachSection(onlySelected, list_CommunicationCircuits);
            bulkCalculateEachSection(onlySelected, list_ImplementationCharges);
            bulkCalculateEachSection(onlySelected, list_SelfServiceIVR);
            bulkCalculateEachSection(onlySelected, list_SelfServiceIVRIntegrations);
            bulkCalculateEachSection(onlySelected, list_SelfServiceIVROptions);
            bulkCalculateEachSection(onlySelected, list_OutboundCampaignManager);
            bulkCalculateEachSection(onlySelected, list_TelcoOptions);
            bulkCalculateEachSection(onlySelected, list_ConnectivityOptions);
            bulkCalculateEachSection(onlySelected, list_PerSeatPricing);
        }
        else
        {
            bulkCalculateEachSection(onlySelected, IVRAndMediaPortOptions);
            bulkCalculateEachSection(onlySelected, BotsAIOptions);
            bulkCalculateEachSection(onlySelected, list_AccessFees);
            bulkCalculateEachSection(onlySelected, IVRAndMediaPortAddOns);    
            bulkCalculateEachSection(onlySelected, digitalChannelOptions);     
            bulkCalculateEachSection(onlySelected, inboundSeatAddOnsQM);
            bulkCalculateEachSection(onlySelected, inboundSeatAddOnsWO);
            bulkCalculateEachSection(onlySelected, inboundSeatAddOnsOS);                         
            bulkCalculateEachSection(onlySelected, endUserEndPoints);     
            bulkCalculateEachSection(onlySelected, cloudContactCenterAdapters);     
            bulkCalculateEachSection(onlySelected, telcoITI);
            bulkCalculateEachSection(onlySelected, telcoBLT);
            bulkCalculateEachSection(onlySelected, telcoOP);
            bulkCalculateEachSection(onlySelected, telcoMPLS);                           
            bulkCalculateEachSection(onlySelected, genesysCare);     
            bulkCalculateEachSection(onlySelected, telcoCrossConnect);     
            bulkCalculateEachSection(onlySelected, psRapidDevelopmentImplementationPackage);
            bulkCalculateEachSection(onlySelected, list_GenesysCloudCare);
            bulkCalculateEachSection(onlySelected, list_ASRandTTS);
            bulkCalculateEachSection(onlySelected, list_ShortLongCodeNonRec);
            bulkCalculateEachSection(onlySelected, list_ShortLongCodeRec);
            bulkCalculateEachSection(onlySelected, list_SWPlatformImplementation);
            bulkCalculateEachSection(onlySelected, list_SWPlatformLicensing);
            bulkCalculateEachSection(onlySelected,list_PerMsgPerMin);
            //Anju Jan 2018 PureSuccess starts
            bulkCalculateEachSection(onlySelected,list_PureSuccessBase );
            bulkCalculateEachSection(onlySelected,list_PureSuccessalaCarte );
           //Anju Jan 2018 PureSuccess ends
        }                                       
    }
    
    private void bulkCalculateEachSection(Boolean onlySelected, List<wrapperQuoteProducts> records)
    {            
        if(onlySelected)
        {
            List<wrapperQuoteProducts> newList = new List<wrapperQuoteProducts>();
            for(wrapperQuoteProducts eachRecord : records)
            {
                if(eachRecord.selected != null && eachRecord.selected)
                    newList.add(eachRecord);
            }
            newList = ServiceOrderQuoteToolHelper.doCalculation(newList, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);            
        }
        else
            records = ServiceOrderQuoteToolHelper.doCalculation(records, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
    }
        
    public pageReference save()
    {
        try
        {
            /*if(quote.Custom_MSLSA__c == true)
                quote.MSA_Link__c = null;*/
            hasViolations = false;
            
            if(blnIsHybridCustomer)
            {
                
                if(quote.Id == null)                  
                    quote = ServiceOrderQuoteHelper.saveQuote(quote, opp);
                
                else
                    update quote;
                
                return getPageReference();
            }
            iPeriod = ServiceOrderQuoteToolHelper.setIPeriod(quote.Period__c); 
            bulkCalculationForAll(false);                      
            allRecords = new List<wrapperQuoteProducts>();
            allRecords.addAll(supportSubscriptions);
            allRecords.addAll(perSeatPricingBase);
            allRecords.addAll(list_GUTraining);
            allRecords.addAll(installationCharges);
            allRecords.addAll(psImplementation);
            
            if(quote.Offering_Type__c == 'Outbound Engagement')
            {
                allRecords.addAll(transactionBasedSubscriptions);
                allRecords.addAll(list_PerMsgPerMin);
                allRecords.addAll(list_SWPlatformImplementation);
                allRecords.addAll(list_ShortLongCodeNonRec);
                allRecords.addAll(list_ShortLongCodeRec);
                allRecords.addAll(list_SWPlatformLicensing);
            }
            else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
            {
                allRecords.addAll(userSubscriptions);
                allRecords.addAll(portSubscriptions);  
                allRecords.addAll(customerSubscriptions);
                allRecords.addAll(rentedEquipmentSubscriptions);                
                allRecords.addAll(timeBasedSubscriptions);
                allRecords.addAll(transactionBasedSubscriptions);
                allRecords.addAll(tierSubscriptions);
                allRecords.addAll(configurationProfServicesSubscriptions);            
                allRecords.addAll(clientManagementSubscriptions);
                allRecords.addAll(list_BluIP);
                allRecords.addAll(list_IVROptions);
                allRecords.addAll(list_InboundSeatAddOns);
                allRecords.addAll(endUserEndPoints);
                allRecords.addAll(list_AdapterServiceOptions);
                allRecords.addAll(list_OtherOptions);
                allRecords.addAll(list_CommunicationCircuits);
                allRecords.addAll(list_ImplementationCharges);
                allRecords.addAll(list_SelfServiceIVR);
                allRecords.addAll(list_SelfServiceIVRIntegrations);
                allRecords.addAll(list_SelfServiceIVROptions);
                allRecords.addAll(list_OutboundCampaignManager);
                allRecords.addAll(list_TelcoOptions);
                allRecords.addAll(list_ConnectivityOptions);
                allRecords.addAll(list_PerSeatPricing);
            }
            else
            {
                allRecords.addAll(IVRAndMediaPortOptions);
                allRecords.addAll(BotsAIOptions);
                allRecords.addAll(list_AccessFees);
                allRecords.addAll(IVRAndMediaPortAddOns);
                allRecords.addAll(digitalChannelOptions);
                allRecords.addAll(inboundSeatAddOnsQM);
                allRecords.addAll(inboundSeatAddOnsWO);
                allRecords.addAll(inboundSeatAddOnsOS);                         
                allRecords.addAll(endUserEndPoints);
                allRecords.addAll(cloudContactCenterAdapters);
                allRecords.addAll(telcoITI);
                allRecords.addAll(telcoBLT);
                allRecords.addAll(telcoOP);
                allRecords.addAll(telcoMPLS);                           
                allRecords.addAll(genesysCare);
                allRecords.addAll(telcoCrossConnect);
                allRecords.addAll(psRapidDevelopmentImplementationPackage);
                allRecords.addAll(list_GenesysCloudCare);
                allRecords.addAll(list_ASRandTTS);
                allRecords.addAll(list_ShortLongCodeNonRec);
                allRecords.addAll(list_ShortLongCodeRec);
                allRecords.addAll(list_SWPlatformImplementation);
                allRecords.addAll(list_SWPlatformLicensing);
                allRecords.addAll(list_PerMsgPerMin);
                
                /*
                for(wrapperQuoteProducts eachRecord : list_PureSuccessBase)
                {
                    if(quote.Offering_Type__c == 'Business Edition')
                    {
                                
                        if(eachRecord.record.Product__c == 'PEC-D_Equip' && (quote.BigMachines__Opportunity__r.type == 'New Logo' || quote.BigMachines__Opportunity__r.Cloud_Renewal__c))    
                        {
                             //eachRecord.autoSelected = true;
                             eachRecord.selected = true;
                             eachRecord.record.Product_Option__c = 'Yes';
                        }
                        if(eachRecord.record.Product__c == 'PEC_P_Partner' && (quote.BigMachines__Opportunity__r.type == 'New Logo' || quote.BigMachines__Opportunity__r.Cloud_Renewal__c))    
                        {
                             //eachRecord.autoSelected = true;
                             eachRecord.selected = true;
                             eachRecord.record.Product_Option__c = 'Yes';
                        }     
                    }
                }
                */
                
                //Anju Jan 2018 PureSuccess starts
                allRecords.addAll(list_PureSuccessBase );
                
                //Anju May 14 bundle attaching
                if(list_PureSuccessalaCarte.size() > 0)
                {
                    List<Product_Group__c> listProductGroup = new List<Product_Group__c>();
                    
                    if(quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c != 'Indirect')
                        listProductGroup = [SELECT id,Token_Value__c FROM Product_Group__c WHERE group_type__c = 'A la Carte' AND Offering_type__c = 'PureEngage Cloud' AND Active__c = true AND Product__r.Product_Group__c = 'PureSuccess Direct A-la-Carte'];
                    if(quote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect')
                        listProductGroup = [SELECT id,Token_Value__c FROM Product_Group__c WHERE group_type__c = 'A la Carte' AND Offering_type__c = 'PureEngage Cloud' AND Active__c = true AND Product__r.Product_Group__c = 'PureSuccess Indirect A-la-Carte'];
                    
                    for(wrapperQuoteProducts objalacatrte : list_PureSuccessalaCarte)
                    {
                         if(!listProductGroup.isEmpty())
                              objalacatrte.record.Bundle__c = listProductGroup[0].id;
                    }
                }
                allRecords.addAll(list_PureSuccessalaCarte );
                //Anju Jan 2018 PureSuccess ends
            }
            
            String errorMsg = ServiceOrderQuoteToolHelper.saveQuoteLineItems(allRecords, quote, opp);
            System.debug('<<< errorMsg = ' + errorMsg);
            if(quote.Offering_Type__c == 'Business Edition'){
                objDDSHistory = DDSCloud.fetchDDSHistory(quote.Id);
                //Mukunth added below line for DDS Mega Deals
                if(quote.Annual_Contract_Value__c != null)
                    isMegaDealBln = checkMegaDeal();
                else
                    isMegaDealBln = false;
            }
            
            if(errorMsg == null)
            {
                populationInit();                                                
                isErrorMsg = false;                           
                return getPageReference();
            }
            else
            {
                isErrorMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                return null;
            }
        }                
        catch(Exception ex)
        {
            isErrorMsg = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;    
        }                
    }
        
    public void doCalculationOnPeriodChange()
    {
        productDiscounts = ServiceOrderQuoteToolHelper.getProductDiscountLookupRecords();
        System.debug('NKC debug quote.Period__c ['+quote.Period__c+']');
        iPeriod = ServiceOrderQuoteToolHelper.setIPeriod(quote.Period__c);
        System.debug('NKC debug iPeriod ['+iPeriod+']');
        if(!perSeatPricingBase.isEmpty())
            perSeatPricingBase = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(perSeatPricingBase, iPeriod);
        
        if(!list_GUTraining.isEmpty())
            list_GUTraining = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_GUTraining, iPeriod);
        
        if(!installationCharges.isEmpty())
            installationCharges = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(installationCharges, iPeriod);
        
        if(!psImplementation.isEmpty())
            psImplementation = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(psImplementation, iPeriod);
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            if(!list_PerMsgPerMin.isEmpty())                
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_PerMsgPerMin, iPeriod);
            
            if(!list_SWPlatformImplementation.isEmpty())
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SWPlatformImplementation, iPeriod);
            
            if(!list_ShortLongCodeNonRec.isEmpty())
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ShortLongCodeNonRec, iPeriod);
            
            if(!list_ShortLongCodeRec.isEmpty())
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ShortLongCodeRec, iPeriod);
            
            if(!list_SWPlatformLicensing.isEmpty())
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SWPlatformLicensing, iPeriod);
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(!userSubscriptions.isEmpty())                
                userSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(userSubscriptions, iPeriod);
            
            if(!portSubscriptions.isEmpty())
                portSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(portSubscriptions, iPeriod);
            
            //if(!customerSubscriptions.isEmpty())
            //      customerSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(customerSubscriptions, iPeriod);
            
            if(!rentedEquipmentSubscriptions.isEmpty())
                rentedEquipmentSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(rentedEquipmentSubscriptions, iPeriod);
            
            //if(!supportSubscriptions.isEmpty())
            //      supportSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(supportSubscriptions, iPeriod); 
            
            if(!configurationProfServicesSubscriptions.isEmpty())
                configurationProfServicesSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(configurationProfServicesSubscriptions, iPeriod);
            
            if(!timeBasedSubscriptions.isEmpty())
                timeBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(timeBasedSubscriptions, iPeriod);                
            
            if(!clientManagementSubscriptions.isEmpty())
                clientManagementSubscriptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(clientManagementSubscriptions, iPeriod);
            
            if(!list_BluIP.isEmpty())
                list_BluIP = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_BluIP, iPeriod);
            
            if(!list_IVROptions.isEmpty())
                list_IVROptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_IVROptions, iPeriod);
            
            if(!list_InboundSeatAddOns.isEmpty())
                list_InboundSeatAddOns = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_InboundSeatAddOns, iPeriod);
            
            if(!endUserEndPoints.isEmpty())
                endUserEndPoints = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(endUserEndPoints, iPeriod);
            
            if(!list_AdapterServiceOptions.isEmpty())
                list_AdapterServiceOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_AdapterServiceOptions, iPeriod);
            
            if(!list_OtherOptions.isEmpty())
                list_OtherOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_OtherOptions, iPeriod);
            
            if(!list_CommunicationCircuits.isEmpty())
                list_CommunicationCircuits = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_CommunicationCircuits, iPeriod);
            
            if(!list_ImplementationCharges.isEmpty())
                list_ImplementationCharges = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ImplementationCharges, iPeriod);
            
            if(!list_SelfServiceIVR.isEmpty())
                list_SelfServiceIVR = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SelfServiceIVR, iPeriod);
            
            if(!list_SelfServiceIVROptions.isEmpty())
                list_SelfServiceIVROptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SelfServiceIVROptions, iPeriod);
            
            if(!list_SelfServiceIVRIntegrations.isEmpty())
                list_SelfServiceIVRIntegrations = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SelfServiceIVRIntegrations, iPeriod);
            
            if(!list_OutboundCampaignManager.isEmpty())
                list_OutboundCampaignManager = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_OutboundCampaignManager, iPeriod);
            
            if(!list_TelcoOptions.isEmpty())
                list_TelcoOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_TelcoOptions, iPeriod);
            
            if(!list_ConnectivityOptions.isEmpty())
                list_ConnectivityOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ConnectivityOptions, iPeriod);
            
            if(!list_PerSeatPricing.isEmpty())
                list_PerSeatPricing = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_PerSeatPricing, iPeriod);
        }
        else
        {
            if(!IVRAndMediaPortOptions.isEmpty())
                IVRAndMediaPortOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(IVRAndMediaPortOptions, iPeriod);
            
            if (!BotsAIOptions.isEmpty())
                BotsAIOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(BotsAIOptions, iPeriod);
                
            if(!list_AccessFees.isEmpty())
                list_AccessFees = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_AccessFees, iPeriod);
            
            if(!IVRAndMediaPortAddOns.isEmpty())
                IVRAndMediaPortAddOns = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(IVRAndMediaPortAddOns, iPeriod);
            
            if(!digitalChannelOptions.isEmpty())
                digitalChannelOptions = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(digitalChannelOptions, iPeriod);
            
            if(!inboundSeatAddOnsQM.isEmpty())
                inboundSeatAddOnsQM = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(inboundSeatAddOnsQM, iPeriod);
            
            if(!inboundSeatAddOnsWO.isEmpty())
                inboundSeatAddOnsWO = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(inboundSeatAddOnsWO, iPeriod);
            
            if(!inboundSeatAddOnsOS.isEmpty())
                inboundSeatAddOnsOS = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(inboundSeatAddOnsOS, iPeriod);                    
            
            if(!endUserEndPoints.isEmpty())
                endUserEndPoints = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(endUserEndPoints, iPeriod);
            
            if(!cloudContactCenterAdapters.isEmpty())
                cloudContactCenterAdapters = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(cloudContactCenterAdapters, iPeriod);
            
            if(!telcoITI.isEmpty())
                telcoITI = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(telcoITI, iPeriod);
            
            if(!telcoBLT.isEmpty())
                telcoBLT = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(telcoBLT, iPeriod);
            
            if(!telcoOP.isEmpty())
                telcoOP = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(telcoOP, iPeriod);
            
            if(!telcoMPLS.isEmpty())
                telcoMPLS = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(telcoMPLS, iPeriod);                        
            
            if(!genesysCare.isEmpty())
                genesysCare = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(genesysCare, iPeriod);
            
            if(!telcoCrossConnect.isEmpty())
                telcoCrossConnect = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(telcoCrossConnect, iPeriod);
            
            if(!psRapidDevelopmentImplementationPackage.isEmpty())
                psRapidDevelopmentImplementationPackage = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(psRapidDevelopmentImplementationPackage, iPeriod);
                
            if(!list_GenesysCloudCare.isEmpty())
                list_GenesysCloudCare = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_GenesysCloudCare, iPeriod);

            if(!list_ASRandTTS.isEmpty())
                list_ASRandTTS = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ASRandTTS, iPeriod);
                
            if(!list_ShortLongCodeNonRec.isEmpty())
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ShortLongCodeNonRec, iPeriod);
            
            if(!list_ShortLongCodeRec.isEmpty())
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_ShortLongCodeRec, iPeriod);
                
            if(!list_SWPlatformImplementation.isEmpty())
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SWPlatformImplementation, iPeriod);
                
            if(!list_SWPlatformLicensing.isEmpty())
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_SWPlatformLicensing, iPeriod);
                
            if(!list_PerMsgPerMin.isEmpty())                
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_PerMsgPerMin, iPeriod);
            
            //Anju Jan 2018 PureSuccess starts   
            if(!list_PureSuccessBase.isEmpty())                
                list_PureSuccessBase = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_PureSuccessBase , iPeriod);
            if(!list_PureSuccessalaCarte.isEmpty())                
                list_PureSuccessalaCarte = ServiceOrderQuoteToolHelper.doCalculationOnPeriodChange(list_PureSuccessalaCarte , iPeriod);
            //Anju Jan 2018 PureSuccess ends
        }
    }
        
    private PageReference getPageReference()
    {
            
        String param = '';
        if(updgradeType != null)
            param = '&upgradeType=' + updgradeType + '&showSelected=true';
        
        PageReference pRef;
        if(ApexPages.currentPage().getParameters().get('oppId') != null)
        {                       
            if(quote.Offering_Type__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
                pRef = new PageReference('/apex/ServiceOrderQuoteToolBE?id='+quote.id + param);
            else
                pRef = new PageReference('/apex/ServiceOrderQuoteTool?id='+quote.id + param);
            
            pRef.setRedirect(true);
            return pRef;
        }       
        return null;
    }
    
    public PageReference byPassApprovals()
    {
        quote.BigMachines__Status__c = 'Quote Approved';
        quote.Approval_Date__c = System.today();
        update quote; 
        PageReference pRef = new PageReference('/apex/ServiceOrderQuoteToolBE?id='+quote.id);
        pRef.setRedirect(true);
        return pRef;        
    }
    
    public void submitOrderBtnHandler()
    {
        //if(quote.Offering_Type__c == 'Business Edition' || quote.Offering_Type__c == 'Premier Edition')
        // Validate for all Editions
        quote = ServiceOrderQuoteHelper.getQuote(quote.id);
        String strAddressValidation = OrderAddressCloudController.validateOrderSubmission(quote);
        if(strAddressValidation != 'OK')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strAddressValidation));
            return;
        }
        
        
        String strCurrentStatus = quote.BigMachines__Status__c;
        quote.BigMachines__Status__c = 'Order Submitted';
        quote.Order_Date_Submitted__c = Date.today();
        
        // Save-point before DML
        Savepoint objSP = Database.setSavepoint();
        try
        {
            // [SM 1/27/2017] If Order is created due to quote status update then update Opportunity forecast status ('1.In Hand') and Stage (5.Purchase Solution) 
            if(quote.BigMachines__Opportunity__c != null)
            {
                Util.Bypass_Trigger_Chk = true;
                update (new Opportunity(Id = quote.BigMachines__Opportunity__c,ForecastStatus__c = Label.Oppty_Forecast_Status_Order_Submission,
                                       StageName = Label.Oppty_Stage_Order_Submission));
                Util.Bypass_Trigger_Chk = false;
            }
            
            // To prevent update of other fields (other fields being changed) not updating quote object directly
            update (new BigMachines__Quote__c(id = quote.id,Order_PO_Number__c = quote.Order_PO_Number__c,
               Order_PO_Date__c = quote.Order_PO_Date__c,BigMachines__Status__c = 'Order Submitted',
               Order_Date_Submitted__c = Date.today(),Order_PO_Received_Date__c = quote.Order_PO_Received_Date__c));
  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Order Submitted'));
        }
        catch(Exception ex)
        {
            quote.BigMachines__Status__c = strCurrentStatus;
            quote.Order_Date_Submitted__c = null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    public void showReviseVisibility()
    {
        showReviseDQPopup = true;
    }
        
    public void hideReviseVisibility()
    {
        showReviseDQPopup = false;
    }   
    
    public void getDQStatus()
    {
        system.debug(quote.Offering_Type__c);
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c,
            quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        
        if(!dqs.isEmpty())
            dqStatus = dqs[0].Status__c;
        
        System.debug('NKC debug dqStatus [' + dqStatus + ']');
    }
    
    public void synchAndGoToDQ()
    {
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.Id, quote.BigMachines__Opportunity__c);
        if(quote.Offering_Type__c == 'Business Edition')
        {
            quote.BigMachines__Status__c = 'Quote Approval Pending';
            update quote;
        }
    }
    
    private Boolean checkDealViolations()
    {
        hasViolations = false;
        list_Violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.Id);
        
        if(list_Violations != null && list_Violations.isEmpty())                          
            return hasViolations;            
        
        if(list_Violations == null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please get deal qualification approved.'));
        else
            DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.Id);  
        
        hasViolations = true;
        return hasViolations;
    }
        
    public PageReference submitForApproval()
    {
        quote = ServiceOrderQuoteHelper.getQuote(quote.id);
        if(quote.Contact__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact info is required before submitting the quote to approvals.'));
            return null;
        }
        if(quote.Expiration_Date__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Expiration Date is required to submit the quote to approvals.'));
            return null;
        }  
        if(quote.Discount__c > 0 && quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD && quote.Explanation_of_price_Discount_request__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.SOQT_Discount_Explanation_Validation_Error_Msg));
            return null;
        }   
        if(quote.Offering_Type__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(checkDealViolations())
                return null;
               
            quote.BigMachines__Status__c = 'Quote Approved';
            update quote;
            PageReference pRef = new PageReference('/apex/ServiceOrderQuoteToolBE?id='+quote.id);
            pRef.setRedirect(true);
            return pRef;
        }
        // For other Offerings we trigger standard approval processes if criteria are met or auto approve by the system
        if(quote.Discount__c <= 30 && !quote.Additional_Legal_Terms__c && !quote.Include_Special_Offer_in_Output__c)
        {
            quote.BigMachines__Status__c = 'Quote Approved';
            update quote;   
        }
        else
        {           
            quote.DAP_Reason__c = 'Discount greater than 30% (applied discount : '+quote.Discount__c+'% )';
            
            if(quote.Include_Special_Offer_in_Output__c)
                quote.DAP_Reason__c += ', Special offer Terms included';
            if(quote.Additional_Legal_Terms__c)
                quote.DAP_Reason__c += ', Additional Legal Term';
            
            String result = ServiceOrderQuoteToolHelper.submitQuoteToApprovalProcess(quote);
            if(result != null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, result));
                return null;
            }
        }
        PageReference pRef = new PageReference('/apex/' + getPageName() + '?id='+quote.id);
        pRef.setRedirect(true);
        return pRef;
    }
        
    public void calculateTotals()
    {
        index = -1;
        
        if(productDiscounts == null)
            productDiscounts = ServiceOrderQuoteToolHelper.getProductDiscountLookupRecords();
        
        if(!supportSubscriptions.isEmpty())
            supportSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(supportSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
        if(!perSeatPricingBase.isEmpty())
            perSeatPricingBase = ServiceOrderQuoteToolHelper.doCalculation(perSeatPricingBase, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
        if(!list_GUTraining.isEmpty())
            list_GUTraining = ServiceOrderQuoteToolHelper.doCalculation(list_GUTraining , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
        if(!installationCharges.isEmpty())
            installationCharges = ServiceOrderQuoteToolHelper.doCalculation(installationCharges , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
        if(!psImplementation.isEmpty())
            psImplementation = ServiceOrderQuoteToolHelper.doCalculation(psImplementation, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            if(!transactionBasedSubscriptions.isEmpty())
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(transactionBasedSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            if(!list_PerMsgPerMin.isEmpty())
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.doCalculation(list_PerMsgPerMin, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            if(!list_SWPlatformImplementation.isEmpty())
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformImplementation, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_ShortLongCodeNonRec.isEmpty())
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeNonRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_ShortLongCodeRec.isEmpty())
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_SWPlatformLicensing.isEmpty())
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformLicensing, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(!userSubscriptions.isEmpty())
                userSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(userSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!portSubscriptions.isEmpty())                
                portSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(portSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!rentedEquipmentSubscriptions.isEmpty())
                rentedEquipmentSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(rentedEquipmentSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!timeBasedSubscriptions.isEmpty())
                timeBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(timeBasedSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!transactionBasedSubscriptions.isEmpty())
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(transactionBasedSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!tierSubscriptions.isEmpty())
                tierSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(tierSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!configurationProfServicesSubscriptions.isEmpty())
                configurationProfServicesSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(configurationProfServicesSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!clientManagementSubscriptions.isEmpty())
                clientManagementSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(clientManagementSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts); 
            
            if(!customerSubscriptions.isEmpty())
            {
                System.debug('#### customerSubscriptions ');
                customerSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(customerSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            }
                
            if(!list_BluIP.isEmpty())
                list_BluIP = ServiceOrderQuoteToolHelper.doCalculation(list_BluIP, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_IVROptions.isEmpty())
                list_IVROptions = ServiceOrderQuoteToolHelper.doCalculation(list_IVROptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_InboundSeatAddOns.isEmpty())
                list_InboundSeatAddOns = ServiceOrderQuoteToolHelper.doCalculation(list_InboundSeatAddOns, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            if(!endUserEndPoints.isEmpty())
                endUserEndPoints = ServiceOrderQuoteToolHelper.doCalculation(endUserEndPoints, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_AdapterServiceOptions.isEmpty())
                list_AdapterServiceOptions = ServiceOrderQuoteToolHelper.doCalculation(list_AdapterServiceOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            if(!list_OtherOptions.isEmpty())
                list_OtherOptions = ServiceOrderQuoteToolHelper.doCalculation(list_OtherOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_CommunicationCircuits.isEmpty())
                list_CommunicationCircuits = ServiceOrderQuoteToolHelper.doCalculation(list_CommunicationCircuits, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_ImplementationCharges.isEmpty())
                list_ImplementationCharges = ServiceOrderQuoteToolHelper.doCalculation(list_ImplementationCharges, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_SelfServiceIVR.isEmpty())
                list_SelfServiceIVR = ServiceOrderQuoteToolHelper.doCalculation(list_SelfServiceIVR, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_SelfServiceIVROptions.isEmpty())
                list_SelfServiceIVROptions = ServiceOrderQuoteToolHelper.doCalculation(list_SelfServiceIVROptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_SelfServiceIVRIntegrations.isEmpty())
                list_SelfServiceIVRIntegrations = ServiceOrderQuoteToolHelper.doCalculation(list_SelfServiceIVRIntegrations, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_OutboundCampaignManager.isEmpty())
                list_OutboundCampaignManager = ServiceOrderQuoteToolHelper.doCalculation(list_OutboundCampaignManager, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_TelcoOptions.isEmpty())
                list_TelcoOptions = ServiceOrderQuoteToolHelper.doCalculation(list_TelcoOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_ConnectivityOptions.isEmpty())
                list_ConnectivityOptions = ServiceOrderQuoteToolHelper.doCalculation(list_ConnectivityOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_PerSeatPricing.isEmpty())
                list_PerSeatPricing = ServiceOrderQuoteToolHelper.doCalculation(list_PerSeatPricing, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        }
        else{ 
            if(!IVRAndMediaPortOptions.isEmpty())
                IVRAndMediaPortOptions = ServiceOrderQuoteToolHelper.doCalculation(IVRAndMediaPortOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if (!BotsAIOptions.isEmpty())
                BotsAIOptions = ServiceOrderQuoteToolHelper.doCalculation(BotsAIOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);


            if(!list_AccessFees.isEmpty())
                list_AccessFees = ServiceOrderQuoteToolHelper.doCalculation(list_AccessFees, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!IVRAndMediaPortAddOns.isEmpty())
                IVRAndMediaPortAddOns = ServiceOrderQuoteToolHelper.doCalculation(IVRAndMediaPortAddOns, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!digitalChannelOptions.isEmpty())
                digitalChannelOptions = ServiceOrderQuoteToolHelper.doCalculation(digitalChannelOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!inboundSeatAddOnsQM.isEmpty())
                inboundSeatAddOnsQM = ServiceOrderQuoteToolHelper.doCalculation(inboundSeatAddOnsQM, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!inboundSeatAddOnsWO.isEmpty())
                inboundSeatAddOnsWO = ServiceOrderQuoteToolHelper.doCalculation(inboundSeatAddOnsWO, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!inboundSeatAddOnsOS.isEmpty())
                inboundSeatAddOnsOS = ServiceOrderQuoteToolHelper.doCalculation(inboundSeatAddOnsOS, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);                                
            
            if(!endUserEndPoints.isEmpty())
                endUserEndPoints = ServiceOrderQuoteToolHelper.doCalculation(endUserEndPoints, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!cloudContactCenterAdapters.isEmpty())
                cloudContactCenterAdapters = ServiceOrderQuoteToolHelper.doCalculation(cloudContactCenterAdapters, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!telcoITI.isEmpty())
                telcoITI = ServiceOrderQuoteToolHelper.doCalculation(telcoITI, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!telcoBLT.isEmpty())
                telcoBLT = ServiceOrderQuoteToolHelper.doCalculation(telcoBLT, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!telcoOP.isEmpty())
                telcoOP = ServiceOrderQuoteToolHelper.doCalculation(telcoOP, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!telcoMPLS.isEmpty())
                telcoMPLS = ServiceOrderQuoteToolHelper.doCalculation(telcoMPLS, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);                    
            
            if(!genesysCare.isEmpty())
                genesysCare = ServiceOrderQuoteToolHelper.doCalculation(genesysCare, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!telcoCrossConnect.isEmpty())
                telcoCrossConnect = ServiceOrderQuoteToolHelper.doCalculation(telcoCrossConnect, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!psRapidDevelopmentImplementationPackage.isEmpty())
                psRapidDevelopmentImplementationPackage = ServiceOrderQuoteToolHelper.doCalculation(psRapidDevelopmentImplementationPackage, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
    
            if(!list_GenesysCloudCare.isEmpty())
                list_GenesysCloudCare = ServiceOrderQuoteToolHelper.doCalculation(list_GenesysCloudCare , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                
            if(!list_ASRandTTS.isEmpty())
                list_ASRandTTS = ServiceOrderQuoteToolHelper.doCalculation(list_ASRandTTS , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_ShortLongCodeNonRec.isEmpty())
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeNonRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if(!list_ShortLongCodeRec.isEmpty())
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                
            if(!list_SWPlatformImplementation.isEmpty())
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformImplementation, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                
            if(!list_SWPlatformLicensing.isEmpty())
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformLicensing, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);        
                
            if(!list_PerMsgPerMin.isEmpty())
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.doCalculation(list_PerMsgPerMin, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            //Anju Jan 2018 PureSuccess starts
            if(!list_PureSuccessBase.isEmpty())
                list_PureSuccessBase = ServiceOrderQuoteToolHelper.doCalculation(list_PureSuccessBase , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            if(!list_PureSuccessalaCarte.isEmpty())
                list_PureSuccessalaCarte = ServiceOrderQuoteToolHelper.doCalculation(list_PureSuccessalaCarte, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            //Anju Jan 2018 PureSuccess ends
        }   
    }
        
    public void doCalculationForLocalCommittedMinutes()
    {
        //timeBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculationForLocalCommittedMinutes(timeBasedSubscriptions, index, iPeriod, sectionType);
    }
        
    public void doCalculation()
    {        
        productDiscounts = ServiceOrderQuoteToolHelper.getProductDiscountLookupRecords();
        if(sectionType.equals('Per Seat Pricing (Base Options)'))
            perSeatPricingBase = ServiceOrderQuoteToolHelper.doCalculation(perSeatPricingBase, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);

        else if(sectionType.equals('Genesys University Training'))
            list_GUTraining = ServiceOrderQuoteToolHelper.doCalculation(list_GUTraining, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
        else if(sectionType.equals('Installation'))
            installationCharges = ServiceOrderQuoteToolHelper.doCalculation(installationCharges, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
        else if(sectionType.equals('Professional Services Implementation'))
            psImplementation = ServiceOrderQuoteToolHelper.doCalculation(psImplementation, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            if(sectionType.equals('Transaction Based'))
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(transactionBasedSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            else if(sectionType.equals('Per Message/Per Minute'))
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.doCalculation(list_PerMsgPerMin, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            else if(sectionType.equals('SW/Platform Implementation'))
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformImplementation, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Short/Long Code Non Recurring Fees'))
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeNonRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Short/Long Code Recurring Fees'))
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('SW/Platform Licensing'))
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformLicensing, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                        
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(sectionType.equals('User Subscription') )
                userSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(userSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                    
            else if(sectionType.equals('Port Subscription'))
                portSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(portSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Rented Equipment'))
                rentedEquipmentSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(rentedEquipmentSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                  
            else if(sectionType.equals('Time Based'))
                timeBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(timeBasedSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);                      
            
            else if(sectionType.equals('Transaction Based'))
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(transactionBasedSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Tier Based'))
                tierSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(tierSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                  
            else if(sectionType.equals('Configuration Professional Services'))
                configurationProfServicesSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(configurationProfServicesSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Client Management'))
                clientManagementSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(clientManagementSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                
            else if(sectionType.equals('Customer Subscription'))
                customerSubscriptions = ServiceOrderQuoteToolHelper.doCalculation(customerSubscriptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            else if(sectionType.equals('BluIP'))
                list_BluIP = ServiceOrderQuoteToolHelper.doCalculation(list_BluIP, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('IVR Options'))
                list_IVROptions = ServiceOrderQuoteToolHelper.doCalculation(list_IVROptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Inbound Seat Add-On Options'))
                list_InboundSeatAddOns = ServiceOrderQuoteToolHelper.doCalculation(list_InboundSeatAddOns, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            else if(sectionType.equals('End User End Points'))
                endUserEndPoints = ServiceOrderQuoteToolHelper.doCalculation(endUserEndPoints, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Adapter Service Options'))
                list_AdapterServiceOptions = ServiceOrderQuoteToolHelper.doCalculation(list_AdapterServiceOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Other Options'))
                list_OtherOptions = ServiceOrderQuoteToolHelper.doCalculation(list_OtherOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Communication Circuits'))
                list_CommunicationCircuits = ServiceOrderQuoteToolHelper.doCalculation(list_CommunicationCircuits, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Implementation Charges'))
                list_ImplementationCharges = ServiceOrderQuoteToolHelper.doCalculation(list_ImplementationCharges, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Self-Service/IVR'))
                list_SelfServiceIVR = ServiceOrderQuoteToolHelper.doCalculation(list_SelfServiceIVR, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Self-Service/IVR Options'))
                list_SelfServiceIVROptions = ServiceOrderQuoteToolHelper.doCalculation(list_SelfServiceIVROptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Self-Service/IVR Integrations'))
                list_SelfServiceIVRIntegrations = ServiceOrderQuoteToolHelper.doCalculation(list_SelfServiceIVRIntegrations, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Outbound Campaign Manager'))
                list_OutboundCampaignManager = ServiceOrderQuoteToolHelper.doCalculation(list_OutboundCampaignManager, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Telecommunications Options'))
                list_TelcoOptions = ServiceOrderQuoteToolHelper.doCalculation(list_TelcoOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Connectivity Options'))
                list_ConnectivityOptions = ServiceOrderQuoteToolHelper.doCalculation(list_ConnectivityOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        
            else if(sectionType.equals('Per Seat Pricing'))
                list_PerSeatPricing = ServiceOrderQuoteToolHelper.doCalculation(list_PerSeatPricing, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
        }
        else
        {
            if(sectionType.equals('IVR and Media Port Options'))
                IVRAndMediaPortOptions = ServiceOrderQuoteToolHelper.doCalculation(IVRAndMediaPortOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            if (sectionType.equals('Bots and AI'))
                BotsAIOptions = ServiceOrderQuoteToolHelper.doCalculation(BotsAIOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);

            if(sectionType.equals('Access Fees'))
                list_AccessFees = ServiceOrderQuoteToolHelper.doCalculation(list_AccessFees, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('IVR / Media Port Add Ons'))
                IVRAndMediaPortAddOns = ServiceOrderQuoteToolHelper.doCalculation(IVRAndMediaPortAddOns, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Digital Channels Options'))
                digitalChannelOptions = ServiceOrderQuoteToolHelper.doCalculation(digitalChannelOptions, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Quality Management'))
                inboundSeatAddOnsQM = ServiceOrderQuoteToolHelper.doCalculation(inboundSeatAddOnsQM, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Workforce Optimization'))
                inboundSeatAddOnsWO = ServiceOrderQuoteToolHelper.doCalculation(inboundSeatAddOnsWO, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Other Services'))
                inboundSeatAddOnsOS = ServiceOrderQuoteToolHelper.doCalculation(inboundSeatAddOnsOS, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                           
            else if(sectionType.equals('End User End Points'))
                endUserEndPoints = ServiceOrderQuoteToolHelper.doCalculation(endUserEndPoints, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Cloud Contact Center Adapters'))
                cloudContactCenterAdapters = ServiceOrderQuoteToolHelper.doCalculation(cloudContactCenterAdapters, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Inbound to IVR'))
                telcoITI = ServiceOrderQuoteToolHelper.doCalculation(telcoITI, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Bridging Leg / Transfer to PSTN or PLMN'))
                telcoBLT = ServiceOrderQuoteToolHelper.doCalculation(telcoBLT, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Outbound to PSTN or PLMN'))
                telcoOP = ServiceOrderQuoteToolHelper.doCalculation(telcoOP, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('MPLS'))
                telcoMPLS = ServiceOrderQuoteToolHelper.doCalculation(telcoMPLS, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                          
            else if(sectionType.equals('Genesys Care'))
                genesysCare = ServiceOrderQuoteToolHelper.doCalculation(genesysCare, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Telco Cross Connect'))
                telcoCrossConnect = ServiceOrderQuoteToolHelper.doCalculation(telcoCrossConnect, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Professional Services Rapid Deployment ImplementationPackages'))
                psRapidDevelopmentImplementationPackage = ServiceOrderQuoteToolHelper.doCalculation(psRapidDevelopmentImplementationPackage, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);

            else if(sectionType.equals('Genesys Cloud Care'))
                list_GenesysCloudCare = ServiceOrderQuoteToolHelper.doCalculation(list_GenesysCloudCare, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);

            else if(sectionType.equals('ASR and TTS'))
                list_ASRandTTS = ServiceOrderQuoteToolHelper.doCalculation(list_ASRandTTS, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Short/Long Code Non Recurring Fees'))
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeNonRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
            
            else if(sectionType.equals('Short/Long Code Recurring Fees'))
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.doCalculation(list_ShortLongCodeRec, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);
                
            else if(sectionType.equals('SW/Platform Implementation'))
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.doCalculation(list_SWPlatformImplementation, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);

            else if(sectionType.equals('SW/Platform Licensing'))
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.addMoreProduct(list_SWPlatformLicensing, index, noOfQuoteProducts);   
            
            else if(sectionType.equals('Per Message/Per Minute'))
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.doCalculation(list_PerMsgPerMin, index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);             
            
            //Anju Jan 2018 PureSuccess starts
            else if(sectionType.equals('Puresuccess Direct Offer'))
                list_PureSuccessBase = ServiceOrderQuoteToolHelper.doCalculation(list_PureSuccessBase , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);             
            
            else if(sectionType.equals('Puresuccess Direct A-la-Carte'))
                list_PureSuccessalaCarte = ServiceOrderQuoteToolHelper.doCalculation(list_PureSuccessalaCarte , index, iPeriod, sectionType, quote.CurrencyIsoCode, quote, productDiscounts);             
            //Anju Jan 2018 PureSuccess ends
        }                         
    }
        
    public void addMoreProduct()
    {
        noOfQuoteProducts ++;
        if(sectionType.equals('Per Seat Pricing (Base Options)'))
            perSeatPricingBase = ServiceOrderQuoteToolHelper.addMoreProduct(perSeatPricingBase, index, noOfQuoteProducts);
        
        else if(sectionType.equals('Genesys University Training'))
            list_GUTraining = ServiceOrderQuoteToolHelper.addMoreProduct(list_GUTraining, index, noOfQuoteProducts);
            
        else if(sectionType.equals('Installation'))
            installationCharges = ServiceOrderQuoteToolHelper.addMoreProduct(installationCharges, index, noOfQuoteProducts);
        
        else if(sectionType.equals('Professional Services Implementation'))
            psImplementation = ServiceOrderQuoteToolHelper.addMoreProduct(psImplementation, index, noOfQuoteProducts);
        
        if(quote.Offering_Type__c == 'Outbound Engagement')
        {
            if(sectionType.equals('Transaction Based'))
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(transactionBasedSubscriptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Per Message/Per Minute'))
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.addMoreProduct(list_PerMsgPerMin, index, noOfQuoteProducts);
            
            else if(sectionType.equals('SW/Platform Implementation'))
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.addMoreProduct(list_SWPlatformImplementation, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Short/Long Code Non Recurring Fees'))
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.addMoreProduct(list_ShortLongCodeNonRec, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Short/Long Code Recurring Fees'))
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.addMoreProduct(list_ShortLongCodeRec, index, noOfQuoteProducts);
            
            else if(sectionType.equals('SW/Platform Licensing'))
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.addMoreProduct(list_SWPlatformLicensing, index, noOfQuoteProducts);
        }
        else if(quote.Offering_Type__c != ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            if(sectionType.equals('Rented Equipment'))
                rentedEquipmentSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(rentedEquipmentSubscriptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Transaction Based'))
                transactionBasedSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(transactionBasedSubscriptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('User Subscription'))
                userSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(userSubscriptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Configuration Professional Services'))
                configurationProfServicesSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(configurationProfServicesSubscriptions, index, noOfQuoteProducts);
                    
            else if(sectionType.equals('Time Based'))
               timeBasedSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(timeBasedSubscriptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Tier Based'))
               tierSubscriptions = ServiceOrderQuoteToolHelper.addMoreProduct(tierSubscriptions, index, noOfQuoteProducts);
           
            else if(sectionType.equals('IVR Options'))
                list_IVROptions = ServiceOrderQuoteToolHelper.addMoreProduct(list_IVROptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Inbound Seat Add-On Options'))
                list_InboundSeatAddOns = ServiceOrderQuoteToolHelper.addMoreProduct(list_InboundSeatAddOns, index, noOfQuoteProducts);
           
            else if(sectionType.equals('End User End Points'))
                endUserEndPoints = ServiceOrderQuoteToolHelper.addMoreProduct(endUserEndPoints, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Adapter Service Options'))
                list_AdapterServiceOptions = ServiceOrderQuoteToolHelper.addMoreProduct(list_AdapterServiceOptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Other Options'))
                list_OtherOptions = ServiceOrderQuoteToolHelper.addMoreProduct(list_OtherOptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Communication Circuits'))
                list_CommunicationCircuits = ServiceOrderQuoteToolHelper.addMoreProduct(list_CommunicationCircuits, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Implementation Charges'))
                list_ImplementationCharges = ServiceOrderQuoteToolHelper.addMoreProduct(list_ImplementationCharges, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Self-Service/IVR'))
                list_SelfServiceIVR = ServiceOrderQuoteToolHelper.addMoreProduct(list_SelfServiceIVR, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Self-Service/IVR Options'))
                list_SelfServiceIVROptions = ServiceOrderQuoteToolHelper.addMoreProduct(list_SelfServiceIVROptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Self-Service/IVR Integrations'))
                list_SelfServiceIVRIntegrations = ServiceOrderQuoteToolHelper.addMoreProduct(list_SelfServiceIVRIntegrations, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Outbound Campaign Manager'))
                list_OutboundCampaignManager = ServiceOrderQuoteToolHelper.addMoreProduct(list_OutboundCampaignManager, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Telecommunications Options'))
                list_TelcoOptions = ServiceOrderQuoteToolHelper.addMoreProduct(list_TelcoOptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Connectivity Options'))
                list_ConnectivityOptions = ServiceOrderQuoteToolHelper.addMoreProduct(list_ConnectivityOptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Per Seat Pricing'))
                list_PerSeatPricing = ServiceOrderQuoteToolHelper.addMoreProduct(list_PerSeatPricing, index, noOfQuoteProducts);
        }
        else
        {
            if(sectionType.equals('IVR and Media Port Options'))
                IVRAndMediaPortOptions = ServiceOrderQuoteToolHelper.addMoreProduct(IVRAndMediaPortOptions, index, noOfQuoteProducts);
            
            if (sectionType.equals('Bots and AI'))
                BotsAIOptions = ServiceOrderQuoteToolHelper.addMoreProduct(BotsAIOptions, index, noOfQuoteProducts);
            
            if(sectionType.equals('Access Fees'))
                list_AccessFees = ServiceOrderQuoteToolHelper.addMoreProduct(list_AccessFees, index, noOfQuoteProducts);

            else if(sectionType.equals('IVR / Media Port Add Ons'))
                IVRAndMediaPortAddOns = ServiceOrderQuoteToolHelper.addMoreProduct(IVRAndMediaPortAddOns, index, noOfQuoteProducts);

            else if(sectionType.equals('Digital Channels Options'))
                digitalChannelOptions = ServiceOrderQuoteToolHelper.addMoreProduct(digitalChannelOptions, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Quality Management'))
                inboundSeatAddOnsQM = ServiceOrderQuoteToolHelper.addMoreProduct(inboundSeatAddOnsQM, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Workforce Optimization'))
                inboundSeatAddOnsWO = ServiceOrderQuoteToolHelper.addMoreProduct(inboundSeatAddOnsWO, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Other Services'))
                inboundSeatAddOnsOS = ServiceOrderQuoteToolHelper.addMoreProduct(inboundSeatAddOnsOS, index, noOfQuoteProducts);
                          
            else if(sectionType.equals('End User End Points'))
                endUserEndPoints = ServiceOrderQuoteToolHelper.addMoreProduct(endUserEndPoints, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Cloud Contact Center Adapters'))
                cloudContactCenterAdapters = ServiceOrderQuoteToolHelper.addMoreProduct(cloudContactCenterAdapters, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Inbound to IVR'))
                telcoITI = ServiceOrderQuoteToolHelper.addMoreProduct(telcoITI, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Bridging Leg / Transfer to PSTN or PLMN'))
                telcoBLT = ServiceOrderQuoteToolHelper.addMoreProduct(telcoBLT, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Outbound to PSTN or PLMN'))
                telcoOP = ServiceOrderQuoteToolHelper.addMoreProduct(telcoOP, index, noOfQuoteProducts);
            
            else if(sectionType.equals('MPLS'))
                telcoMPLS = ServiceOrderQuoteToolHelper.addMoreProduct(telcoMPLS, index, noOfQuoteProducts);
                         
            else if(sectionType.equals('Genesys Care'))
                genesysCare = ServiceOrderQuoteToolHelper.addMoreProduct(genesysCare, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Telco Cross Connect'))
                telcoCrossConnect = ServiceOrderQuoteToolHelper.addMoreProduct(telcoCrossConnect, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Professional Services Rapid Deployment ImplementationPackages'))
                psRapidDevelopmentImplementationPackage = ServiceOrderQuoteToolHelper.addMoreProduct(psRapidDevelopmentImplementationPackage, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Genesys Cloud Care'))
                list_GenesysCloudCare = ServiceOrderQuoteToolHelper.addMoreProduct(list_GenesysCloudCare, index, noOfQuoteProducts);

            else if(sectionType.equals('ASR and TTS'))
                list_ASRandTTS = ServiceOrderQuoteToolHelper.addMoreProduct(list_ASRandTTS, index, noOfQuoteProducts);
                
            else if(sectionType.equals('Short/Long Code Non Recurring Fees'))
                list_ShortLongCodeNonRec = ServiceOrderQuoteToolHelper.addMoreProduct(list_ShortLongCodeNonRec, index, noOfQuoteProducts);
            
            else if(sectionType.equals('Short/Long Code Recurring Fees'))
                list_ShortLongCodeRec = ServiceOrderQuoteToolHelper.addMoreProduct(list_ShortLongCodeRec, index, noOfQuoteProducts);
                
            else if(sectionType.equals('SW/Platform Implementation'))
                list_SWPlatformImplementation = ServiceOrderQuoteToolHelper.addMoreProduct(list_SWPlatformImplementation, index, noOfQuoteProducts);
                
            else if(sectionType.equals('SW/Platform Licensing'))
                list_SWPlatformLicensing = ServiceOrderQuoteToolHelper.addMoreProduct(list_SWPlatformLicensing, index, noOfQuoteProducts);
                
            else if(sectionType.equals('Per Message/Per Minute'))
                list_PerMsgPerMin = ServiceOrderQuoteToolHelper.addMoreProduct(list_PerMsgPerMin, index, noOfQuoteProducts);
            
            //Anju Jan 2018 PureSuccess starts
            else if(sectionType.equals('Puresuccess Direct Offer'))
                list_PureSuccessBase = ServiceOrderQuoteToolHelper.addMoreProduct(list_PureSuccessBase , index, noOfQuoteProducts);
                
            else if(sectionType.equals('Puresuccess Direct A-la-Carte'))
                list_PureSuccessalaCarte = ServiceOrderQuoteToolHelper.addMoreProduct(list_PureSuccessalaCarte , index, noOfQuoteProducts);
            //Anju Jan 2018 PureSuccess ends
        }
    }
        
    public pageReference cancel()
    {
        PageReference pg = new PageReference('/'+oppId);
        pg.setRedirect(true);
        return pg;
    }
        
    public pageReference cloneQuote()
    {
        String cloneQuoteId = ServiceOrderQuoteHelper.cloneQuote(quote, false);
        String pageName = getPageName();            
        PageReference pg = new PageReference('/apex/'+pageName+'?id='+cloneQuoteId);
        pg.setRedirect(true);
        return pg;
    }
    public pageReference recall()
    {
        system.debug('Inside revise');
        //if DQ pending block revise
        getDQStatus();
        system.debug(dqStatus);
        system.debug(quote.Offering_Type__c);
        system.debug(ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD);
        if(dqStatus == 'Approval Pending' && quote.Offering_Type__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,Label.CloudReviseRestrictMessage));
            return null;
        }
        else
        {
            if(quote.BigMachines__Status__c == 'Quote Approved')
            {
                quote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING;
                quote.Approved_ACV__c = quote.Annual_Contract_Value__c;
                update quote;
            } 
            else if(quote.BigMachines__Status__c == 'Quote Rejected')
            {
                quote.BigMachines__Status__c = 'Quote In Progress';
                update quote;
            }
            else
            {
                if(quote.Offering_Type__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
                {
                    system.debug('Inside revise BE');
                    quote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING;
                    update quote;   
                    QuoteApprovalAssignmentHelper.quoteRevisionActions(quote);
                }
                else
                    ServiceOrderQuoteToolHelper.recallApprovalProcess(quoteId);
            }
        }
        String pageName = getPageName();   
        PageReference pRef = new PageReference('/apex/'+pageName+'?id='+quote.id);
        pRef.setRedirect(true);
        return pRef;
    }
    
    
    private String getPageName(){
        String pageName;
        if(quote.Offering_Type__c == ServiceOrderQuoteToolHelper.BUSINESS_EDITION_CLOUD)
            pageName = 'ServiceOrderQuoteToolBE';
        else if(quote.Offering_Type__c == ServiceOrderQuoteToolHelper.PRIMIER_EDITION_CLOUD)
            pageName = 'ServiceOrderQuoteToolPE'; 
        else
            pageName = 'ServiceOrderQuoteTool';
        return pageName;
    }
    
    // Handler for Send Contract button
    public void viewContract()
    {       
        try
        {
            update (new BigMachines__Quote__c(Id = quote.Id,Hide_Discount__c = quote.Hide_Discount__c,
                             Hide_Totals__c = quote.Hide_Totals__c,Proposal_Date__c = quote.Proposal_Date__c,Treat_SO_as_PO__c = quote.Treat_SO_as_PO__c));
            /*if(quote.Legal_Contract_Request__c != null){
                legalRequestStatus = [SELECT Status__c FROM GCR__c WHERE id =: quote.Legal_Contract_Request__c].Status__c;
            }*/
            
        }
        catch(Exception e){}
    }
    // Added by Anto on Oct 09, 2018
    public void refreshContractDiscount(){
        if(!quote.Require_Contractual_Discount__c){
            quote.Customer_Contractual_Rate__c = 0;
            System.debug(quote.Customer_Contractual_Rate__c);
        }
    }
    
    //Mukunth added below code for DDS Mega Deals
    public boolean checkMegaDeal(){
        if(quote.Annual_Contract_Value__c != null){
            System.Debug('quote.Annual_Contract_Value__c--->'+quote.Annual_Contract_Value__c);
            if(DDSCloud.converttoUSD(quote.offering_type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c) * Decimal.valueof(CloudPevMultiplierPC.Information__c) > Decimal.valueof(CloudPevMultiplierPC.ID__c)){
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
    
    public class wrapperQuoteProducts
    {
        public BigMachines__Quote_Product__c record {get; set;}
        public Integer index {get; set;}
        public Boolean selected {get; set;}
        public Boolean isListPriceEditable {get; set;}            
        public transient String styleClass {get; set;}
        public Boolean hasDevcies {get; set;}
        public String productOption {get; set;}
        public String productDescription {get; set;}
        public Boolean includeInCMRR {get; set;}
        public Double quantity {get; set;}
        public Boolean showOrderAsLink {get; set;}
        public Boolean showNetPriceAsView {get; set;}
        public String productType {get; set;}
        public String errorMsg {get; set;}
        public Boolean autoSelected {get; set;}
        public Boolean isListPriceInDiscount {get; set;}
        public String listPriceCalculateFrom {get; set;}  
        public Boolean addPremiumCharges {get; set;}
        //Specify if it's a non total row if true       
        public Boolean detailRow {get; set;}   
        public Boolean isDiscountable {get; set;} 
        public String pricingModel {get; set;}  
        public Boolean showAddSign {get; set;} 
        public Boolean isProductNameEditable {get; set;}
        public Boolean blnIncludeinSeatCount {get; set;}
        public String strApnNumber {get; set;}
        
        // Phase out Date if any
        public Date dtPhaseOut {get; set;}
    }   
}