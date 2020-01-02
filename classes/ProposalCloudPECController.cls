/************************************************************************************
Purpose : Controller class to handle service order output page ProposalCloudPC
Written By : Ranjith Punneli
Test Classes : ProposalCloudPECControllerTest
*************************************************************************************/

public class ProposalCloudPECController
{ 
    
    public BigMachines__Quote__c objQuote {get; private set;}
    public Subscription__c objSubscription {get; private set;}
    public List<Integer> list_OrderedHeadings {get; private set;} 
    public List<Account_Order_Address__c> list_QuoteAddresses {get; private set;}
    public List<Account_Order_Address__c> list_QuoteShipToAddresses {get; private set;}
    public List<Subscription_Product__c> list_RemovedProducts {get; private set;}
    public List<BigMachines__Quote_Product__c> list_OveragePrices {get; private set;}
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
    //Anju Jan 2018 PureSuccess ends
    
    public String strCurrencySymbol {get; private set;}
    public String strProductGroupKey{get;set;}
    public Integer intRemainingTerm {get; private set;}
    public Integer intCurrYrProration {get; private set;}
    public Integer intServiceTokensCount {get; private set;}
    public Decimal decSubscriptionTotals {get; private set;}
    public Decimal decEstimatedTotals {get; private set;}
    public Decimal decOneTimeEducationTotals {get; private set;}
    public Decimal decOneTimeServicesTotals {get; private set;}
    public Decimal decOneTimeCloudCareTotals {get; private set;}
    public Decimal decOneTimeTelcoTotals {get; private set;}    
    public Decimal decOneTimeCreditTotals {get; private set;}
    public Decimal decOneTimeTotals {get; private set;}
    public Decimal decOriginalOneTimeTotals {get; private set;}
    public Decimal decOriginalMonthlyTotals {get; private set;}       
    public Decimal decRecCreditTotals {get; private set;}
    public Integer intRampPeriodInMonths{get;set;}
    
    
    //addedby kartik
    public Decimal decOriginalPricefor3GP104566ABAA {get; private set;}
    public Boolean blnHas3GP107415ABAA {get; private set;}
    public Boolean blnHasPredictiveRoutingProd{get;private set;}
    public Boolean blnHasSocialMediaProducts{get; private set;}
    String strQuoteId = '';
    Set<Id> set_ExistingProductIds = new Set<Id>();
    Public Set<Id> set_PRodIds= new Set<Id>();
    
    //Mukunth added for 6 digit for PEC
    public map<Id,Product2> mapProdToPrecision {get;set;}
    
    Set<String> set_DoNotDisplayProducts = new Set<String> {'PCSMS-170-NV-SMS', 'PVR-170-NV-CNCU','PC-170-NV-PCAMAZLEXVO'};
        Map<String, Service_Order_Product_Group__c> map_ServiceOrderProductGroups = new Map<String, Service_Order_Product_Group__c>();
    
    // *** Constructor ***
    public ProposalCloudPECController()
    {
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        blnHas3GP107415ABAA = blnHasPredictiveRoutingProd = blnHasSocialMediaProducts = false;
        decSubscriptionTotals = decEstimatedTotals = decOneTimeCreditTotals = 0;
        decOneTimeTotals = decOneTimeEducationTotals = decOneTimeServicesTotals = decOneTimeTelcoTotals = decOneTimeCloudCareTotals = decRecCreditTotals = 0; 
        decOriginalOneTimeTotals = decOriginalMonthlyTotals = intServiceTokensCount = 0;      
        intRemainingTerm = intCurrYrProration = 12;
        
        list_OrderedHeadings = new List<Integer>();
        list_QuoteAddresses = new List<Account_Order_Address__c>();
        list_OveragePrices = new List<BigMachines__Quote_Product__c>();   
        list_AlacItems = new List<BigMachines__Quote_Product__c>();   
        list_AlacItemsForAmend = new List<BigMachines__Quote_Product__c>(); 
        map_ExistingOriginalSubscrProds = new Map<String, Subscription_Product__c>();
        map_AllOriginalSubscrProds = new Map<String, Subscription_Product__c>();
        map_ProdGrpToQtProds = new Map<String, Map<String,List<BigMachines__Quote_Product__c>>>();
        map_HeadingsWithSortOrder = new Map<Integer, String>();
        
        fetchQuote();
        fetchBillToAddress();
        setProductGroups();
        fetchQuoteProducts();
        strCurrencySymbol = MyOutputTextController.getCurrencySymbolFromIso(objQuote.CurrencyIsoCode); 
        strProductGroupKey =  string.valueof(map_ProdGrpToQtProds.keyset()).replace('{', '').replace('{', '');      
        
        //Mukunth added for 6 digit code for PEC
        //mapProdToPrecision = new map<Id,Product2>([select Id, Tier_Pricing_Decimal_Precision__c from Product2 where IsActive = true]);
        mapProdToPrecision = new map<Id,Product2>([select Id, Tier_Pricing_Decimal_Precision__c from Product2]);
        intRampPeriodInMonths = (objQuote.Ramp_Period__c == '1 Year')?Integer.valueof(12):(Integer.valueof(objQuote.Ramp_Period__c)/30);
            
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
                    BigMachines__Opportunity__r.Direct_Indirect_Sale__c,Total_Tokens_Change__c,MSA_Link_Type__c,Period__c,Overage_Allowance__c,
                    Overage_Allowance_Other__c,Annual_Price_Escalation_Other__c,Price_Escalation__c,Multi_Year_ACV_Year_1__c,Multi_Year_ACV_Year_2__c,
                    Multi_Year_ACV_Year_3__c,Multi_Year_ACV_Year_4__c,Multi_Year_ACV_Year_5__c,Multi_Year_ACV_Year_6__c,Multi_Year_ACV_Year_7__c,
                    Multi_Year_ACV_Year_8__c,Multi_Year_ACV_Year_9__c,Multi_Year_ACV_Year_10__c,Contract_terms_drive_ACV_Change__c
                    FROM BigMachines__Quote__c 
                    WHERE Id = :strQuoteId];    
        //Added By Ranjith on Nove 03, 2017 -- Starts    
        intRemainingTerm = objQuote.Subscription_Start_Date__c.monthsBetween(objQuote.Subscription_End_Date__c);
        if(objQuote.Subscription_Start_Date__c < Date.today() && objQuote.Subscription_End_Date__c > Date.today())
        {
            intRemainingTerm = Date.today().monthsBetween(objQuote.Subscription_End_Date__c);
        }     
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
            System.debug('$$$$$$objQP:'+objQP);   
            if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
               && objQuote.Amendment_For__c != null) {
                   set_ExistingProductIds.add(objQP.BigMachines__Product__c);
                   map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, new Subscription_Product__c());
                   if(map_AllOriginalSubscrProds.containsKey(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c)) {
                       map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, map_AllOriginalSubscrProds.get(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c));
                   }
               }
            System.debug('#####map_ExistingOriginalSubscrProds: '+map_AllOriginalSubscrProds);
            
            //added by kartik
            if(objQP.BigMachines__Product__r.APN_Number__c == '3GP107415ABAA') {
                blnHas3GP107415ABAA = true;                
            }
            if(objQP.BigMachines__Product__r.apn_number__c == '3GP110507ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP110508ABAA' )
            {
                blnHasPredictiveRoutingProd = true;
                
            }
            
            if(objQP.BigMachines__Product__r.apn_number__c == '3GP109231ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP109315ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP109232ABAA' || objQP.BigMachines__Product__r.apn_number__c == '3GP109233ABAA')
            {
                blnHasSocialMediaProducts =  true;
            } 
            
            if(!objQP.Hide_Record__c && !set_DoNotDisplayProducts.contains(objQP.BigMachines__Product__r.APN_Number__c)) { 
                if(String.isBlank(objQP.BigMachines__Product__r.Product_Group__c))  {
                    objQP.BigMachines__Product__r.Product_Group__c = 'Other Charges';
                }
                String strQtProdGroup = 'Other Charges';
                String strMainHeading = 'Other Charges';   
                
                if(map_ServiceOrderProductGroups.containsKey(objQP.BigMachines__Product__r.Product_Group__c)) {
                    strQtProdGroup = objQP.BigMachines__Product__r.Product_Group__c;
                    strMainHeading = map_ServiceOrderProductGroups.get(strQtProdGroup).Billing_Type__c;
                }   
                System.debug('####strQtProdGroup: '+strQtProdGroup);
                System.debug('####strMainHeading: '+strMainHeading);
                System.debug('####Product_Group__c: '+objQP.BigMachines__Product__r.Product_Group__c);               
                
                if(!objQP.Is_Overage__c) {                
                    if((objQuote.Order_Type__c == Label.New_Subscription || objQuote.Order_Type__c == Label.Replace_Subscription)
                       || ((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
                           && (strMainHeading != 'Non Recurring Fees' || (strMainHeading == 'Non Recurring Fees' && objQP.Quantity_Change__c > 0)))) {
                               buildProdGrpToQtProdsMap(objQP, strMainHeading, strQtProdGroup);
                           }
                    if(strMainHeading == 'Monthly Fees' || strMainHeading == 'Monthly (Telco) Fees') {
                        decSubscriptionTotals += objQP.Ext_Net_Price__c;
                        if(objQP.BigMachines__Product__r.Product_Group__c == 'Credit') {
                            decRecCreditTotals += objQP.Ext_Net_Price__c;    
                        }
                    }
                    else if(strMainHeading == 'Non Recurring Fees'){
                        Decimal decExtNetUnitPrice = objQuote.Order_Type__c == Label.Amend_Subscription ? (objQP.Quantity_Change__c > 0 ? (objQP.Net_Unit_Price__c * objQP.Quantity_Change__c).setScale(2) : 0) : objQP.Ext_Net_Price__c;
                        if(objQP.BigMachines__Product__r.Product_Group__c != 'One-Time Credit') {
                            decOneTimeTotals += decExtNetUnitPrice;  
                            if(objQP.BigMachines__Product__r.Product_Group__c == 'Genesys University Training') {
                                decOneTimeEducationTotals += decExtNetUnitPrice;
                            }  
                            else if(objQP.BigMachines__Product__r.Product_Group__c == 'Professional Services Implementation') {
                                decOneTimeServicesTotals += decExtNetUnitPrice;
                            }
                            else if(objQP.BigMachines__Product__r.Product_Group__c == 'Genesys Cloud Care') {
                                decOneTimeCloudCareTotals += decExtNetUnitPrice;
                            } 
                            else if(objQP.BigMachines__Product__r.Product_Group__c == 'Installation') {
                                decOneTimeTelcoTotals += decExtNetUnitPrice;
                            } 
                        }                        
                        else
                            decOneTimeCreditTotals += decExtNetUnitPrice;  
                    } 
                }   
                else {
                    strMainHeading = strQtProdGroup = 'Bursting Premium Pricing';                       
                    buildProdGrpToQtProdsMap(objQP, strMainHeading, strQtProdGroup);
                }
            }   
            if(map_PureSuccessProductGroupsToShow.containskey(objQP.BigMachines__Product__c)) {
                map_PureSuccessProductGroupsToShow.put(objQP.BigMachines__Product__c,true);
            }
            
            if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') {
                list_AlacItems.add(objQP);
            }
            if(objQuote.Order_Type__c == Label.Amend_Subscription && (map_PureSuccessProductGroupsToShowForAmend.containskey(objQP.BigMachines__Product__c)) && objQP.Subscription_Product__c == null ) {
                map_PureSuccessProductGroupsToShowForAmend.put(objQP.BigMachines__Product__c,true);
            }            
            if(objQuote.Order_Type__c == Label.Amend_Subscription && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') && (objQP.Subscription_Product__c == null || objQP.Quantity_Change__c > 0)) {
                list_AlacItemsForAmend.add(objQP);
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
                for ( Integer i = list_RemovedProducts.size() - 1; i > intIndex; --i ) {
                    if(set_PRodIds.contains(list_RemovedProducts[i].Product__c)){list_RemovedProducts.remove( i );}
                }
            }
        }        
        for(String strPrd:map_PureSuccessProductGroupsToShow.keyset()) {
            if(map_PureSuccessProductGroupsToShow.get(strPrd))
                blnDisplayPureSucessMessage = true;
        }
        blnDisplayPureSucessMessage = (list_AlacItems.size() > 0 )?true:blnDisplayPureSucessMessage;
        if(objQuote.Order_Type__c == Label.Amend_Subscription ){
            for(String strPrd:map_PureSuccessProductGroupsToShowForAmend.keyset())  {
                if(map_PureSuccessProductGroupsToShowForAmend.get(strPrd))
                    blnDisplayPureSucessMessage = true;                
            }
            blnDisplayPureSucessMessage = (list_AlacItemsForAmend.size() > 0)?true:blnDisplayPureSucessMessage;
            System.debug('$$$$$map_ProductGroupsToShow'+map_ProductGroupsToShow);
        } 
        decRecCreditTotals *= -1;
        decOneTimeCreditTotals *= -1;
        System.debug('#####list_RemovedProducts: '+list_RemovedProducts);
        
        // added by kartik
        List<Product2> list_CloudStorageProducts = new List<Product2>();
        list_CloudStorageProducts = [SELECT id, List_Price__c, List_Price_AUD__c, List_Price_CAD__c, List_Price_EUR__c, List_Price_GBP__c
                                     FROM Product2
                                     WHERE APN_Number__c = '3GP104566ABAA'];
        if(list_CloudStorageProducts.size() > 0)
        {
            if(objQuote.CurrencyIsoCode == 'GBP')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_GBP__c;
            else if(objQuote.CurrencyIsoCode == 'EUR')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_EUR__c;
            else if(objQuote.CurrencyIsoCode == 'CAD')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_CAD__c;
            else if(objQuote.CurrencyIsoCode == 'AUD')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price_AUD__c;
            else if(objQuote.CurrencyIsoCode == 'USD')
                decOriginalPricefor3GP104566ABAA = list_CloudStorageProducts[0].List_Price__c;
        }
        // added by kartik
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
    String createQuoteProductQueryString(String outPutType) {
        String strQuery = 'SELECT ';
        
        //Getting fields from Service Order Output field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> list_QuoteProductFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Service_Order_Output.getFields();
        for(Schema.FieldSetMember field : list_QuoteProductFields)
            strQuery += field.getFieldPath() + ', ';
        
        strQuery += 'Unit_of_Measure__c,BigMachines__Product__r.Unit_of_Measure__c,Is_Overage__c,BigMachines__Product__r.Sub_Category__c,BigMachines__Product__r.description__c,BigMachines__Quantity__c,BigMachines__Quote__r.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,Updated_Quantity__c,Subscription_Product__c,Parent_Quote_Product__r.Quantity_Change__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' ; 
        
        if(outPutType == 'Standard View')   
            strQuery += objQuote.Id + '\' ORDER BY BigMachines__Product__r.Sort_Order__c,Name';
        else
            strQuery += objQuote.Id + '\' ORDER BY Group_Number__c NULLS last';
        system.debug('strQuery'+strQuery);
        return strQuery;
    }
    
    // *** Method to initialize Product Groups from custom settings ***
    void setProductGroups() {        
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
        for(Product_Group__c pG : [Select id,Product__c,Product__r.description__c,(Select id,name,Quantity__c,Product__c,Product__r.name,Product__r.description,Product__r.description__c,Product__r.Unit_of_Measure__c from Product_Group_Items__r where Product__r.APN_Number__c != :Label.Token_APN_Number) from Product_Group__c where Offering_Type__c includes ('PureCloud') and Type__c IN ('PureSuccess', 'Partner PureSuccess')]){
            map_PureSuccessProductGroupsToShow.put(pG.Product__c,false);
            map_PureSuccessProductGroupsToShowForAmend.put(pG.Product__c,false);
            map_PureSuccesGroupItems.put(pG.Product__c,pG.Product_Group_Items__r);
        }
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