/************************************************************************************
Purpose : Controller class to handle service order output page ProposalCloudPC
Written By : Ranjith Punneli
Test Classes : ProposalCloudPCControllerTest
*************************************************************************************/

public class ProposalCloudPCController
{ 
    public BigMachines__Quote__c objQuote {get; private set;}
    public Subscription__c objSubscription {get; private set;}
    public List<Integer> list_OrderedHeadings {get; private set;} 
    public List<Account_Order_Address__c> list_QuoteAddresses {get; private set;}
    public List<Account_Order_Address__c> list_QuoteShipToAddresses {get; private set;}
    public List<Subscription_Product__c> list_RemovedProducts {get; private set;}
    public List<BigMachines__Quote_Product__c> list_OveragePrices {get; private set;}
    public List<BigMachines__Quote_Product__c> list_ResourceServices {get; private set;}
    public List<BigMachines__Quote_Product__c> list_PilotTrialPOCOverages {get; private set;}
    public Map<String, Subscription_Product__c> map_ExistingOriginalSubscrProds {get; private set;}
    public Map<String, Subscription_Product__c> map_AllOriginalSubscrProds {get; set; }
    public Map<String, Map<String, List<BigMachines__Quote_Product__c>>> map_ProdGrpToQtProds {get; private set;}
    public Map<Integer, String> map_HeadingsWithSortOrder {get; private set;}
    
    //Anju Jan 2018 PureSuccess starts
    public Boolean blnDisplayPureSucessMessage{get;set;}
    public Map<String,Boolean> map_ProductGroupsToShow {get; private set;}
    public Map<String,Boolean> map_PureSuccessProductGroupsToShow {get; private set;}
    public Map<String,Boolean> map_PureSuccessProductGroupsToShowforAmend {get; private set;}
    public Map<String,List<Product_Group_Item__c>> map_PureSuccesGroupItems {get; private set;}
    public List<BigMachines__Quote_Product__c> list_AlacItems {get; private set;}
    public List<BigMachines__Quote_Product__c> list_AlacItemsForAmend {get; private set;}   
    public List<BigMachines__Quote_Product__c> list_AlacItemsAssociatedtoBundle{get;private set;}
    //Anju Jan 2018 PureSuccess ends
    
    public String strCurrencySymbol {get; private set;}
    public String strProductGroupKey{get;set;}
    public String strRecServBillingPeriod {get; private set;}
    public Integer intRemainingTerm {get; private set;}
    public Integer intCurrYrProration {get; private set;}
    public Integer intPCVCount {get; private set;}
    public Integer intServiceTokensCount {get; private set;}
    public Decimal decConversionRate {get; private set;}
    public Decimal decSubscriptionTotals {get; private set;}
    public Decimal decRecBundleTotals {get; private set;}
    public Decimal decNonRecBundleTotals {get; private set;}
    public Decimal decRecurringServiceTotals {get; private set;}
    public Decimal decEstimatedTotals {get; private set;}
    public Decimal decOneTimeHardwareTotals {get; private set;}
    public Decimal decOneTimeEducationTotals {get; private set;}
    public Decimal decOneTimeServicesTotals {get; private set;}
    public Decimal decOneTimeCreditTotals {get; private set;}
    public Decimal decOneTimeTotals {get; private set;}
    public Decimal decOriginalOneTimeTotals {get; private set;}
    public Decimal decMonthlyTotals {get; private set;}
    public Decimal decOriginalMonthlyTotals {get; private set;}   
    public Boolean blnSMSPart {get; private set;}   
    public Boolean blnBYOCPart {get; private set;}   
    public Boolean blnCNCUPart {get; private set;}   
    public Boolean blnPCVPart {get; private set;}   
    public Boolean blnCustomIVRPart {get; private set;}
    public Boolean blnAmazonFlexPart {get; private set;}
    public Boolean blnWhatsAppPart {get; private set;}
    public Decimal decRecCreditTotals {get; private set;}
    public Boolean blnAltoCloud{get;private set;}
    public Integer intRampPeriodInMonths{get;set;}//Rony Joseph - Added to show in Ramp Period Verbiage - October 10th 2019
    public String strPORequired {get; private set;}
    public String strTaxExp {get; private set;}
    public String strRichText{get; private set;}
    
    String strQuoteId = '';
    Set<Id> set_ExistingProductIds = new Set<Id>();
    Public Set<Id> set_PRodIds= new Set<Id>();
    // Rony Joseph - PureSuccess Harmonization - November 2019.
    public Map<Id, List<BigMachines__Quote_Product__c>> mapBundleParentToChildQuoteProducts {get; private set;}
    private List<QuoteProductWrapper> listParentProductWrappers {get; private set;}
    private Set<Id> setReferencedProductIds;
    
    Set<String> set_DoNotDisplayProducts = new Set<String> {'PCSMS-170-NV-SMS', 'PVR-170-NV-CNCU','PC-170-NV-PCAMAZLEXVO'};
        Map<String, Service_Order_Product_Group__c> map_ServiceOrderProductGroups = new Map<String, Service_Order_Product_Group__c>();
    
    // *** Constructor ***
    public ProposalCloudPCController()
    {
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        decSubscriptionTotals = decRecBundleTotals = decNonRecBundleTotals = decRecurringServiceTotals = decEstimatedTotals = decOneTimeCreditTotals = 0;
        decOneTimeTotals = decOneTimeHardwareTotals = decOneTimeEducationTotals = decOneTimeServicesTotals = decRecCreditTotals = 0; 
        decOriginalOneTimeTotals = decOriginalMonthlyTotals = decMonthlyTotals = intPCVCount = intServiceTokensCount = 0;      
        intRemainingTerm = intCurrYrProration = 12;
        strRecServBillingPeriod = 'Monthly';
        
        list_OrderedHeadings = new List<Integer>();
        list_QuoteAddresses = new List<Account_Order_Address__c>();
        list_QuoteShipToAddresses = new List<Account_Order_Address__c>();
        list_OveragePrices = new List<BigMachines__Quote_Product__c>(); 
        list_ResourceServices = new List<BigMachines__Quote_Product__c>(); 
        list_PilotTrialPOCOverages = new List<BigMachines__Quote_Product__c>();   
        map_ExistingOriginalSubscrProds = new Map<String, Subscription_Product__c>();
        map_AllOriginalSubscrProds = new Map<String, Subscription_Product__c>();
        map_ProdGrpToQtProds = new Map<String, Map<String,List<BigMachines__Quote_Product__c>>>();
        map_HeadingsWithSortOrder = new Map<Integer, String>();
        
        // Rony Joseph - PureSuccess Harmonization - November 2019.
        mapBundleParentToChildQuoteProducts = new Map<Id, List<BigMachines__Quote_Product__c>>();
        listParentProductWrappers = new List<QuoteProductWrapper>();
        setReferencedProductIds = new Set<Id>();
        list_AlacItemsAssociatedtoBundle =  new List<BigMachines__Quote_Product__c>();
        
        //Anju Jan 2018 PureSuccess starts
        list_AlacItems = new List<BigMachines__Quote_Product__c>();   
        list_AlacItemsForAmend = new List<BigMachines__Quote_Product__c>(); 
        //Anju Jan 2018 PureSuccess ends
        
        fetchQuote();
        fetchBillToAddress();
        setProductGroups();
        fetchQuoteProducts();
        strCurrencySymbol = MyOutputTextController.getCurrencySymbolFromIso(objQuote.CurrencyIsoCode); 
        //Storing Currency conversion rates
        decConversionRate = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: objQuote.CurrencyIsoCode].ConversionRate; 
        strProductGroupKey =  string.valueof(map_ProdGrpToQtProds.keyset()).replace('{', '').replace('{', '');
        intRampPeriodInMonths = (objQuote.Ramp_Period__c == '1 Year')?Integer.valueof(12):(Integer.valueof(objQuote.Ramp_Period__c)/30);//Rony Joseph - Added to show in Ramp Period Verbiage - October 10th 2019
        strPORequired = (objQuote.Purchase_Order_is_Required__c)?'Required':'';////Rony Joseph - Added to control appearance of PureChase Order - November 2019
        strTaxExp = (objQuote.Tax_Exemption_Applicable__c)?'Required':'';  ////Rony Joseph - Added to control appearance of Tax Exemption - November 2019          
        strRichText = String.valueof(objQuote.Special_Offer_Terms__c).replaceall('<[^>]*>','');
        
    }
    
    // *** Method to query Quote ***
    void fetchQuote()
    {
        objQuote = [SELECT Id,Name,Selling_Entity__c,Sold_To_Name__r.Name,Sold_To_Address__c,Sold_To_City__c,Sold_To_State__c,Show_Updated_Quantity_Only__c,
                    Sold_To_Zip_Code__c,Sold_To_Country__c,Expiration_Date__c,Quote_Created_Date_Formula__c,Owner.Name,Contact__r.Name,
                    Contact__r.ContactPhone__c,Contact__r.Phone,Contact__r.Email,Initial_Subscription_Term__c,No_Of_Months__c,Renewal_Subscription_Term__c,
                    CurrencyIsoCode,Order_Payment_Terms__c,Billing_Period__c,Pricing_Model__c,Opportunity_Offering_Type__c,
                    BigMachines__Opportunity__r.Sold_To_Country__r.PureConnect_Cloud_Selling_Entity__c,Order_Type__c, Hide_List_Price__c,
                    BigMachines__Opportunity__r.Sold_To_Country__r.PureCloud_Selling_Entity__c,Amendment_For__c,PureCloud_Monthly_Minimum__c,
                    BigMachines__Opportunity__r.Sold_To_Country__r.Region__c, BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,
                    BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.Offering_Detail__c, Non_Recurring_Fees_Changes__c,
                    Include_Special_Offer_in_Output__c,Special_Offer_Terms__c,Additional_Legal_Terms__c,Legal_Terms__c, Annual_Contract_Value_Change__c,
                    SOW_Link__c,MSA_Link__c,Annual_Contract_Value__c,Setup_Provisioning_Charges__c,CPS_Total__c,Total_Contract_Value__c,
                    Offering_Type__c,Opp_Sold_To_Country__c,CMRR__c,Ramp_Period__c,Deployment_Model__c,Total_Services__c, Total_Overage__c, 
                    Hide_Discount__c,Hide_Totals__c,Treat_SO_as_PO__c,Genesys_University_Training_Total__c,Proposal_Language__c, Show_One_Time_Fees_Only__c,
                    Proposal_Date__c,Non_Recurring_Fees__c,Product_Tier__c, Minimum_Fees_Period__c,Total_Education__c,Total_Hardware__c,Group_Product_By__c,
                    Subscription_Start_Date__c, Subscription_End_Date__c, Subscription_Amend_Date__c, BigMachines__Opportunity__r.BusinessPartner__c,
                    BigMachines__Opportunity__r.BusinessPartner__r.Name, End_User_ID__c, End_User_ID__r.Name, CMRR_Change__c, Billing_Category__c,
                    PureSuccess__c,PureSuccess_Offer_Subscription_Amount__c,A_La_Carte_PureSuccess_Services_Amount__c,Token_Value__c,
                    BigMachines__Opportunity__r.Direct_Indirect_Sale__c,Total_Tokens_Change__c,Purchase_Order_is_Required__c,Tax_Exemption_Applicable__c  
                    FROM BigMachines__Quote__c 
                    WHERE Id = :strQuoteId];   
        intRemainingTerm = objQuote.Subscription_Start_Date__c.monthsBetween(objQuote.Subscription_End_Date__c);
        if(objQuote.Subscription_Start_Date__c < Date.today() && objQuote.Subscription_End_Date__c > Date.today())
        {
            intRemainingTerm = Date.today().monthsBetween(objQuote.Subscription_End_Date__c);
        }    
        //Added By Ranjith on Nove 03, 2017 -- Starts        
        if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
           && objQuote.Amendment_For__c != null) {
               
               intCurrYrProration = intRemainingTerm == 12 ? 12 : (Math.mod(intRemainingTerm, 12) == 0 ? 12 : Math.mod(intRemainingTerm, 12));
                   
                   objSubscription = SubscriptionUtil.getSubscription(objQuote.Amendment_For__c);
               for(Subscription_Product__c objSubscrProd : objSubscription.Subscription_Products__r) {
                   map_AllOriginalSubscrProds.put(objSubscrProd.Product__c+';'+objSubscrProd.Is_Overage__c, objSubscrProd);
                   if(objSubscrProd.Product__r.Product_Group__c == 'One-Time Fees') {
                       decOriginalOneTimeTotals += objSubscrProd.Ext_Net_Price__c;
                   }
               }
               System.debug('#####map_AllOriginalSubscrProds: '+map_AllOriginalSubscrProds);
           }
        //Added By Ranjith on Nov 03, 2017 -- Ends    
    }
    
    // *** Method to query Quote Products ***
    void fetchQuoteProducts() { 
        for(BigMachines__Quote_Product__c objQP : Database.query(createQuoteProductQueryString('Standard View'))) {
            System.debug('$$$$$$objQP:'+objQP );   
            // Rony Joseph - PureSuccess Harmonization - November 2019.
            if (objQp.Hide_Record__c) {
                QuoteBundleUtil.addBundleChildToParentMap(mapBundleParentToChildQuoteProducts, objQP);
            } else {
                listParentProductWrappers.add(new QuoteProductWrapper(objQP));
            }
            if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
               && objQuote.Amendment_For__c != null) {
                   set_ExistingProductIds.add(objQP.BigMachines__Product__c);
                   map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, new Subscription_Product__c());
                   if(map_AllOriginalSubscrProds.containsKey(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c)) {
                       map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, map_AllOriginalSubscrProds.get(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c));
                   }
               }
            System.debug('#####map_ExistingOriginalSubscrProds: '+map_AllOriginalSubscrProds);
            
            if(objQP.BigMachines__Product__r.APN_Number__c == 'PCSMS-170-NV-SMS') {
                blnSMSPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c == 'PVR-170-NV-CNCU') {
                blnCNCUPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c == 'PV-170-NV-PCBYOC') {
                blnBYOCPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c == 'PC-170-NV-PCIVRCUSPERMIN') {
                blnCustomIVRPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c == 'PV-170-NV-PCVOICE') {
                blnPCVPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c =='PC-170-NV-PCAMAZLEXVO'){
                blnAmazonFlexPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c =='PC-170-NV-WAMESS'){
                blnWhatsAppPart = true;
            }
            if(objQP.BigMachines__Product__r.APN_Number__c =='PC-170-NV-ALTOCLDC' ||objQP.BigMachines__Product__r.APN_Number__c =='PC-170-NV-ALTOCLD'||objQP.BigMachines__Product__r.APN_Number__c =='PC-170-NV-ALTOCLDWEB' ){
                blnAltoCloud = true;
            }  
            System.debug('#189QP'+objQP);
            if(!objQP.Hide_Record__c 
               && !set_DoNotDisplayProducts.contains(objQP.BigMachines__Product__r.APN_Number__c)) { //&& objQP.BigMachines__Product__r.New_Category__c != 'Bundles') {
                   if(objQP.BigMachines__Product__r.Product_Group__c == 'Upfront Hardware Costs' 
                      || objQP.BigMachines__Product__r.New_Category__c == 'Hardware' || objQP.BigMachines__Product__r.New_Category__c == 'Services'
                      || objQP.BigMachines__Product__r.New_Category__c == 'Education'// || objQP.BigMachines__Product__r.New_Category__c == 'Credit'
                      || objQP.BigMachines__Product__r.New_Category__c == 'Education Courses and Packaged Curriculum') {
                          objQP.BigMachines__Product__r.Product_Group__c = 'One-Time Fees';
                      }  
                   else if(objQP.BigMachines__Product__r.New_Category__c == 'Bundles' 
                           && objQP.BigMachines__Product__r.Product_Group__c == 'Subscription Fees') {
                               objQP.BigMachines__Product__r.Product_Group__c = 'Bundles';
                           }                                 
                   else if(String.isBlank(objQP.BigMachines__Product__r.Product_Group__c))  {
                       objQP.BigMachines__Product__r.Product_Group__c = 'Other Charges';
                   }                
                   
                   String strQtProdGroup = 'Other Charges';
                   String strMainHeading = 'Other Charges';
                   if(objQP.BigMachines__Product__r.Product_Group__c == 'One-Time Fees') {
                       strQtProdGroup = objQP.BigMachines__Product__r.New_Category__c;                       
                       if(objQP.BigMachines__Product__r.New_Category__c == 'Credit') {
                           strQtProdGroup = 'One-Time Credit';
                       }
                   }         
                   else {
                       if(map_ServiceOrderProductGroups.containsKey(objQP.BigMachines__Product__r.Product_Group__c)) {
                           strQtProdGroup = objQP.BigMachines__Product__r.Product_Group__c;
                       }
                   }       
                   System.debug('####strQtProdGroup: '+strQtProdGroup);
                   System.debug('####strMainHeading: '+strMainHeading);
                   System.debug('####Product_Group__c: '+objQP.BigMachines__Product__r.Product_Group__c);
                   
                   if(map_ServiceOrderProductGroups.containsKey(strQtProdGroup)) {
                       strMainHeading = map_ServiceOrderProductGroups.get(strQtProdGroup).Billing_Type__c;
                   }
                   
                   if(!objQP.Is_Overage__c || objQP.APN_Number__c == 'PV-170-NV-PCVOICE' || objQP.APN_Number__c == 'PV-170-NV-PCBYOC') {                
                       if((objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription)
                          || (objQuote.Order_Type__c == Label.Amend_Subscription 
                              && ((objQP.BigMachines__Product__r.Product_Group__c != 'One-Time Fees' && objQP.BigMachines__Product__r.Product_Group__c != 'Recurring Services')
                                  || (objQP.BigMachines__Product__r.Product_Group__c == 'One-Time Fees' && objQP.Quantity_Change__c > 0)
                                  || (objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services' && (objQuote.Billing_Category__c == 'Annual M2M' || objQuote.Billing_Category__c == 'M2M'))))
                          || (objQuote.Order_Type__c == Label.Renew_Subscription
                              && (objQP.BigMachines__Product__r.Product_Group__c != 'One-Time Fees'
                                  || (objQP.BigMachines__Product__r.Product_Group__c == 'One-Time Fees' && objQP.Quantity_Change__c > 0))))     {
                                      buildProdGrpToQtProdsMap(objQP, strMainHeading, strQtProdGroup);
                                  }
                       
                       if(objQP.BigMachines__Product__r.Product_Group__c == 'Subscription Fees') {
                           decSubscriptionTotals += objQP.Ext_Net_Price__c;
                       }
                       else if(objQP.BigMachines__Product__r.Product_Group__c == 'Credit') {
                           decRecCreditTotals += objQP.Ext_Net_Price__c;
                       }
                       else if (objQP.BigMachines__Product__r.Product_Group__c == 'Bundles') {
                           if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                               decRecBundleTotals += objQP.Ext_Net_Price__c;
                           else 
                               decNonRecBundleTotals += objQP.Ext_Net_Price__c;
                       }
                       else if(objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services') {
                           decRecurringServiceTotals += objQuote.Billing_Category__c != 'Annual Pre-Pay' || objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription ? 
                               objQP.Ext_Net_Price__c : 0;
                           strRecServBillingPeriod = objQP.Name.contains('Monthly') ? 'Monthly' : 'Annually';
                           intServiceTokensCount += 1;
                       }
                       else if(objQP.BigMachines__Product__r.Product_Group__c == 'One-Time Fees') {
                           //Decimal decExtNetUnitPrice = objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription ? 
                           //                                objQP.Ext_Net_Price__c : (objQP.Quantity_Change__c > 0 ? (objQP.Net_Unit_Price__c * objQP.Quantity_Change__c).setScale(2) : 0);
                           Decimal decExtNetUnitPrice = objQuote.Order_Type__c == Label.Amend_Subscription /*&& objQP.BigMachines__Product__r.New_Category__c != 'Credit'*/ ? (objQP.Quantity_Change__c > 0 ? (objQP.Net_Unit_Price__c * objQP.Quantity_Change__c).setScale(2) : 0) : objQP.Ext_Net_Price__c;
                           if(objQP.BigMachines__Product__r.New_Category__c != 'Credit')
                               decOneTimeTotals += decExtNetUnitPrice;
                           if(objQP.BigMachines__Product__r.New_Category__c == 'Hardware') {
                               decOneTimeHardwareTotals += decExtNetUnitPrice;
                           }  
                           else if(objQP.BigMachines__Product__r.New_Category__c == 'Education' || objQP.BigMachines__Product__r.New_Category__c == 'Education Courses and Packaged Curriculum') {
                               decOneTimeEducationTotals += decExtNetUnitPrice;
                           }  
                           else if(objQP.BigMachines__Product__r.New_Category__c == 'Services') {
                               decOneTimeServicesTotals += decExtNetUnitPrice;
                           }    
                           else if(objQP.BigMachines__Product__r.New_Category__c == 'Credit') {
                               //Added By Ranjith on Dec 04, 2018 -- Starts - To implement -ve amount for PC Credit
                               //decOneTimeTotals += decExtNetUnitPrice;
                               decOneTimeCreditTotals += decExtNetUnitPrice;                               
                               //Added By Ranjith on Dec 04, 2018 -- Ends
                           }
                       }
                       else if(objQP.BigMachines__Product__r.Product_Group__c == 'Estimated PureCloud Virtual Edge') {                        
                           decEstimatedTotals += objQP.Ext_Net_Price__c;
                           decMonthlyTotals += objQP.Ext_Net_Price__c;
                       } 
                       /*else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureCloud Voice'){
intPCVCount += 1;
} 
else if(objQP.BigMachines__Product__r.Product_Group__c == 'Resource Services'){
list_ResourceServices.add(objQP);                        
} 
*/
                   }   
                   else {
                       strMainHeading = strQtProdGroup = 'Overage Subscription Pricing';
                       if(objQP.BigMachines__Product__r.APN_Number__c == 'PC-170-NV-PCEDGE-VIR') {
                           strMainHeading = strQtProdGroup = 'Estimated PureCloud Virtual Edge';
                       }
                       else if(objQP.BigMachines__Product__r.APN_Number__c == 'PC-170-NV-PCIVRCUSPERMIN') {
                           strMainHeading = strQtProdGroup = 'Resource Services';
                       }
                       buildProdGrpToQtProdsMap(objQP, strMainHeading, strQtProdGroup);
                       
                       /*if(objQP.BigMachines__Product__r.Product_Group__c == 'Resource Services'){
list_ResourceServices.add(objQP);
} 
*/
                   }
               }
            else {
                if(objQuote.BigMachines__Opportunity__r.Offering_Detail__c == 'Free Trial' && objQP.Is_Overage__c 
                   && !Label.IVR_Data_Storage_Parts.contains(objQP.apn_number__c) && objQP.BigMachines__Product__r.Sub_Category__c != 'PureCloud Voice' 
                   && !objQP.apn_number__c.startsWith('PCSMS') && !objQP.BigMachines__Product__r.Name.Contains('BYOT') && !objQP.BigMachines__Product__r.Name.Contains('API'))
                {
                    list_PilotTrialPOCOverages.add(objQP);
                }  
            } 
            //Anju Jan 2018 PureSuccess starts   
            if(map_PureSuccessProductGroupsToShow.containskey(objQP.BigMachines__Product__c))
            {
                map_PureSuccessProductGroupsToShow.put(objQP.BigMachines__Product__c,true);
            }
            
            if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte')
            {
                list_AlacItems.add(objQP);
            }
            if(objQuote.Order_Type__c == Label.Amend_Subscription && (map_PureSuccessProductGroupsToShowForAmend.containskey(objQP.BigMachines__Product__c)) && objQP.Subscription_Product__c == null )
            {
                map_PureSuccessProductGroupsToShowForAmend.put(objQP.BigMachines__Product__c,true);
            }
            
            if(objQuote.Order_Type__c == Label.Amend_Subscription && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') && (objQP.Subscription_Product__c == null || objQP.Quantity_Change__c > 0))
            {
                list_AlacItemsForAmend.add(objQP);
            }
            //Anju Jan 2018 PureSuccess ends   
            if((objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') && (objQP.Bundle_Line__c != null && objQP.Bundle__r.Group_Type__c == 'PureSuccess Bundle'))
            {
                list_AlacItemsAssociatedtoBundle.add(objQP);
            }                
        }       
        System.debug('#####list_PilotTrialPOCOverages: '+list_PilotTrialPOCOverages);
        // Rony Joseph - PureSuccess Harmonization - November 2019.
        QuoteBundleUtil.sumChildProductsToParentPricing(mapBundleParentToChildQuoteProducts, listParentProductWrappers);
        for (QuoteProductWrapper objQPW : listParentProductWrappers) {
            setReferencedProductIds.add(objQPW.record.BigMachines__Product__c);
        }
        for (List<BigMachines__Quote_Product__c> listQPs : mapBundleParentToChildQuoteProducts.values()) {
            for (BigMachines__Quote_Product__c objQP : listQPs) {
                setReferencedProductIds.add(objQP.BigMachines__Product__c);
            }
        }
        list_OrderedHeadings.addAll(map_HeadingsWithSortOrder.keyset());
        list_OrderedHeadings.sort();
        System.debug('#####list_OrderedHeadings: '+list_OrderedHeadings);
        
        if(set_ExistingProductIds.size() > 0) {   
            list_RemovedProducts = SubscriptionUtil.getRemovedProductsFromAmendedQuote(set_ExistingProductIds, objSubscription); 
            if( objquote.Show_Updated_Quantity_Only__c){
                Integer intIndex = 0;
                String strObjName = 'BigMachines__Quote_Product__c';
                String strWhereCondition = 'Hide_Record__c = false AND Is_Overage__c = False AND BigMachines__Quote__c = \''+ objquote.Id + '\'' ;
                List<BigMachines__Quote_Product__c> list_QPs = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
                for(BigMachines__Quote_Product__c objQP:list_QPs){
                    set_PRodIds.add(objQP.BigMachines__Product__c);
                }
                for ( Integer i = list_RemovedProducts.size() - 1; i > intIndex; --i )
                {
                    if(set_PRodIds.contains(list_RemovedProducts[i].Product__c)){list_RemovedProducts.remove( i );}
                }
            }
        }
        //Anju Jan 2018 PureSuccess starts
        for(String strPrd:map_PureSuccessProductGroupsToShow.keyset()  )
        {
            if(map_PureSuccessProductGroupsToShow.get(strPrd))
                blnDisplayPureSucessMessage = true;
            
        }
        blnDisplayPureSucessMessage = (list_AlacItems.size() > 0 )?true:blnDisplayPureSucessMessage;
        if(objQuote.Order_Type__c == Label.Amend_Subscription ){
            for(String strPrd:map_PureSuccessProductGroupsToShowForAmend.keyset())
            {
                if(map_PureSuccessProductGroupsToShowForAmend.get(strPrd))
                    blnDisplayPureSucessMessage = true;
                
            }
            blnDisplayPureSucessMessage = (list_AlacItemsForAmend.size() > 0)?true:blnDisplayPureSucessMessage;
            System.debug('$$$$$map_ProductGroupsToShow'+map_ProductGroupsToShow);
        } 
        //Anju Jan 2018 PureSuccess ends
        decRecCreditTotals *= -1;
        decOneTimeCreditTotals *= -1;
        System.debug('#####list_RemovedProducts: '+list_RemovedProducts);
        System.debug('#####list_RemovedProducts: '+list_RemovedProducts);
    }
    
    //Added By Ranjith on Jun 05, 2017 -- Starts
    // *** Method to pull bill to address from account order address object ***
    private void fetchBillToAddress() {    
        //Logic to check if Bill to address is already assigned for this quote
        list_QuoteAddresses = [SELECT Id, Address__c, City__c, Country__c, State__c, Zip_Code__c
                               FROM Account_Order_Address__c 
                               WHERE Quote__c =: objQuote.Id
                               AND Address_Type__c = 'Bill To' LIMIT 1];
        list_QuoteShipToAddresses = [SELECT Id, Address__c, City__c, Country__c, State__c, Zip_Code__c
                                     FROM Account_Order_Address__c 
                                     WHERE Quote__c =: objQuote.Id
                                     AND Address_Type__c = 'Ship To' LIMIT 1];
        
    }
    //Added By Ranjith on Jun 05, 2017 -- Ends
    
    // *** Method to create query string to query Quote Products ***
    String createQuoteProductQueryString(String outPutType)
    {
        String strQuery = 'SELECT ';
        
        //Getting fields from Service Order Output field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> list_QuoteProductFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Service_Order_Output.getFields();
        for(Schema.FieldSetMember field : list_QuoteProductFields)
            strQuery += field.getFieldPath() + ', ';
        
        strQuery += 'Unit_of_Measure__c,Is_Overage__c,BigMachines__Product__r.Sub_Category__c,BigMachines__Product__r.description__c,BigMachines__Quantity__c,BigMachines__Quote__r.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,Updated_Quantity__c,Subscription_Product__c,Parent_Quote_Product__r.Quantity_Change__c,';
        strQuery += 'Bundle__c, Bundle_Line__c, Ext_List__c,Bundle__r.Group_Type__c, ';
        strQuery += 'BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'';
        
        if(outPutType == 'Standard View')   
            strQuery += objQuote.Id + '\' ORDER BY BigMachines__Product__r.Sort_Order__c,Name';
        else
            strQuery += objQuote.Id + '\' ORDER BY Group_Number__c NULLS last';
        return strQuery;
    }
    
    // *** Method to initialize Product Groups from custom settings ***
    void setProductGroups()
    {        
        //Anju Jan 2018 PureSuccess starts
        map_PureSuccessProductGroupsToShow = new Map<String,Boolean>();
        map_PureSuccesGroupItems = new Map<String,List<Product_Group_Item__c>>();
        map_PureSuccessProductGroupsToShowForAmend  = new Map<String,Boolean>();
        //Anju Jan 2018 PureSuccess ends
        
        List<Service_Order_Product_Group__c> list_ProductGroups = [SELECT Group_Name__c,Header_Text__c, Billing_Type__c, Sort_Order__c 
                                                                   FROM Service_Order_Product_Group__c 
                                                                   WHERE Edition__c = :objQuote.Offering_Type__c
                                                                   ORDER BY Name];        
        for(Service_Order_Product_Group__c objProductGroup : list_ProductGroups)  {
            map_ServiceOrderProductGroups.put(objProductGroup.Group_Name__c, objProductGroup); 
        }  
        //Anju Jan 2018 PureSuccess starts
        for(Product_Group__c pG : [Select id,Product__c,Product__r.description__c,(Select id,name,Quantity__c,Product__c,Product__r.name,Product__r.description,Product__r.description__c,Product__r.Unit_of_Measure__c from Product_Group_Items__r where Product__r.APN_Number__c != :Label.Token_APN_Number) from Product_Group__c where Offering_Type__c includes ('PureCloud') and Type__c IN ('PureSuccess', 'Partner PureSuccess')]){
            map_PureSuccessProductGroupsToShow.put(pG.Product__c,false);
            map_PureSuccessProductGroupsToShowForAmend.put(pG.Product__c,false);
            map_PureSuccesGroupItems.put(pG.Product__c,pG.Product_Group_Items__r);
        }
        //Anju Jan 2018 PureSuccess ends 
        System.debug('#####map_ServiceOrderProductGroups: '+map_ServiceOrderProductGroups);
    }
    
    private void buildProdGrpToQtProdsMap(BigMachines__Quote_Product__c objQP, String strMainHeading, String strQtProdGroup) {
        System.debug('#####strQtProdGroup: '+strQtProdGroup);
        System.debug('#####map_ProdGrpToQtProds:'+map_ProdGrpToQtProds);
        System.debug('#####objQP:'+objQP);
        System.debug('#####strMainHeading:'+strMainHeading);
        if(map_ProdGrpToQtProds.containsKey(strMainHeading)) {              
            if(map_ProdGrpToQtProds.get(strMainHeading).containsKey(strQtProdGroup)) {
                if(objQuote.Show_Updated_Quantity_Only__c && objQuote.Order_Type__c == Label.Amend_Subscription ){
                    if(objQP.Quantity_Change__c > 0  || objQP.Parent_Quote_Product__r.Quantity_Change__c > 0)
                        map_ProdGrpToQtProds.get(strMainHeading).get(strQtProdGroup).add(objQP);
                }
                else
                    map_ProdGrpToQtProds.get(strMainHeading).get(strQtProdGroup).add(objQP);
            }
            else {
                if(objQuote.Show_Updated_Quantity_Only__c && objQuote.Order_Type__c == Label.Amend_Subscription ){
                    if(objQP.Quantity_Change__c > 0  || objQP.Parent_Quote_Product__r.Quantity_Change__c > 0) 
                        map_ProdGrpToQtProds.get(strMainHeading).put(strQtProdGroup, new List<BigMachines__Quote_Product__c> { objQP });
                }
                else 
                    map_ProdGrpToQtProds.get(strMainHeading).put(strQtProdGroup, new List<BigMachines__Quote_Product__c> { objQP });
            }      
        }
        else {
            if(objQuote.Show_Updated_Quantity_Only__c && objQuote.Order_Type__c == Label.Amend_Subscription ){
                if(objQP.Quantity_Change__c > 0  || objQP.Parent_Quote_Product__r.Quantity_Change__c > 0) {
                    map_ProdGrpToQtProds.put(strMainHeading, new Map<String, List<BigMachines__Quote_Product__c>>{strQtProdGroup => new List<BigMachines__Quote_Product__c>{objQP}});
                }
            }   
            else
                map_ProdGrpToQtProds.put(strMainHeading, new Map<String, List<BigMachines__Quote_Product__c>>{strQtProdGroup => new List<BigMachines__Quote_Product__c>{objQP}});
        }        
        map_HeadingsWithSortOrder.put(Integer.valueOf(map_ServiceOrderProductGroups.get(strQtProdGroup).Sort_Order__c),
                                      map_ServiceOrderProductGroups.get(strQtProdGroup).Billing_Type__c);        
    }
}