public class ProposalCloudController
{
    String strQuoteId;
    public BigMachines__Quote__c objQuote {get; private set;}
    public List<Service_Order_Product_Group__c> list_ProductGroups {get; private set;}
    public Map<String,List<BigMachines__Quote_Product__c>> map_ProductGroupToQuoteProducts {get; private set;}
    public Map<String,Boolean> map_ProductGroupsToShow {get; private set;}
    public List<BigMachines__Quote_Product__c> list_OverageProducts {get;set;}
    public String strKeySet{get;set;}
    public Integer intSizeofExistingOriginalSubscrProds { get { return map_ExistingOriginalSubscrProds.size(); } } 
    public Set<Id> set_PRodIds= new Set<Id>();
    public Map<Id, BigMachines__Quote_Product__c> map_ProductvsQuantityChange{get;set;}
    
    
    public Boolean blnHasRecurring {get; private set;}
    public Boolean blnHasNonRecurring {get; private set;}
    public Boolean blnHasMonthlyTelco {get; private set;}
    public Boolean blnDisplayMonthlyTelcoTable {get; private set;}
    public Boolean blnDisplayPureSucessMessage{get;set;}
    public Boolean blnDisplayPureSucessMessageForAmend{get;set;}
    public String strCurrencySymbol {get; private set;}
    public String strRecServBillingPeriod {get; private set;}
    public BigMachines__Quote_Product__c objMonthlyTelcoProd {get; private set;} //CS-012-NV-AR01
    public List<Account_Order_Address__c> list_QuoteAddresses {get; private set;}
    public List<Account_Order_Address__c> list_QuoteShipToAddresses {get; private set;}
    public Map<String, String> map_ProdGroupCategorization {get; private set;} 
    public Decimal conversionRate {get; private set;}
    public Map<String, String> mapProposalGroupNumberVsName {get; private set;}
    
    //Anju Jan 2018 PureSuccess starts
    public Map<String,Boolean> map_PureSuccessProductGroupsToShow {get; private set;}
    public Map<String,Boolean> map_PureSuccessProductGroupsToShowforAmend {get; private set;}
    public Map<String,List<Product_Group_Item__c>> map_PureSuccesGroupItems {get; private set;}
    public Map<String,List<Product_Group_Item__c>> map_PureSuccesGroupItemsforAmend {get; private set;}
    public List<BigMachines__Quote_Product__c> list_AlacItems {get; private set;}
    public List<BigMachines__Quote_Product__c> list_AlacItemsForAmend {get; private set;}
    
    //Anju Jan 2018 PureSuccess ends
    
    //Anju PCC Amend
    public Map<String, Subscription_Product__c> map_ExistingOriginalSubscrProds {get; private set;}
    public Map<String, Subscription_Product__c> map_ExistingOriginalSubscrProds2 {get; private set;}
    public Map<String, Subscription_Product__c> map_AllOriginalSubscrProds {get; set; }
    Set<Id> set_ExistingProductIds = new Set<Id>();
    public Subscription__c objSubscription {get; private set;}
    public Integer intRemainingTerm {get; private set;}
    public Integer intCurrYrProration {get; private set;}
    public Decimal decOriginalOneTimeTotals {get; private set;}
    public List<Subscription_Product__c> list_RemovedProducts {get; private set;}
    public List<Subscription_Product__c> list_RemovedProductsToShow {get; private set;}
    public Decimal decSoftwareFee {get;set;}
    public Decimal decPureSuccessOfferChangeAmount{get;set;}
    public Decimal decPureSuccessAlaCarteChangeAmount{get;set;}
    Set<Id> set_DependentPartsQuoted = new Set<Id>();
    public String str_Key{get;set;}
    public Integer intRampPeriodInMonths{get;set;}//Rony Joseph - Added to show in Ramp Period Verbiage - October 10th 2019
    
    
    //Mukunth added for 6 digit project on 10-APR-2019
    public map<Id,Product2> mapProdToPrecision {get;set;}
    
    //Rony Joseph-April 16 2019-PCC Credit Total Display 
    public Decimal decRecCreditAmout{get;set;}
    public Decimal decOneTimeCreditAmout{get;set;}                       
    // *** Constructor ***
    public ProposalCloudController()
    {
        
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        map_ProdGroupCategorization = new Map<String, String>();
        blnHasRecurring = blnHasNonRecurring = blnHasMonthlyTelco = false;  
        list_AlacItems = new List<BigMachines__Quote_Product__c>();   
        list_AlacItemsForAmend = new List<BigMachines__Quote_Product__c>(); 
        map_AllOriginalSubscrProds = new Map<String, Subscription_Product__c>();
        strRecServBillingPeriod = 'Monthly';
        decPureSuccessOfferChangeAmount = decRecCreditAmout = decOneTimeCreditAmout = decPureSuccessAlaCarteChangeAmount = 0;
        intRemainingTerm = intCurrYrProration = 12;
        decOriginalOneTimeTotals = 0;
        fetchQuote();
        fetchBillToAddress();
        initializeProductGroups();
        fetchQuoteProducts();
        strCurrencySymbol = MyOutputTextController.getCurrencySymbolFromIso(objQuote.CurrencyIsoCode); 
        //Storing Currency conversion rates
        conversionRate = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: objQuote.CurrencyIsoCode].ConversionRate; 
        //Anju PCC Amend
        
        if(objQuote.Billing_Period__c == 'Annually')
            decSoftwareFee = objQuote.CMRR__c *12;
        else if (objQuote.Billing_Period__c == 'Semi-Annually')
            decSoftwareFee = objQuote.CMRR__c *6;
        else if (objQuote.Billing_Period__c == 'Other')
            decSoftwareFee = objQuote.CMRR__c *objQuote.No_Of_Months__c; 
        else if(objQuote.Billing_Period__c == 'Monthly')
            decSoftwareFee = objQuote.CMRR__c;
        System.debug('strRecServBillingPeriod'+strRecServBillingPeriod);
        
        //Mukunth 10-APR-2019 for 6 digit code
        mapProdToPrecision = new map<Id,Product2>([select Id, Tier_Pricing_Decimal_Precision__c from Product2 where IsActive = true]);
        intRampPeriodInMonths = Integer.valueof(objQuote.Ramp_Period__c)/30;//Rony Joseph - Added to show in Ramp Period Verbiage - October 10th 2019
        
        
    }
    
    // *** Method to query Quote ***
    void fetchQuote()
    {
        //Mukunth added Oppty_Lead_Offer__c to below query for 6 digit project
        objQuote = [SELECT Id,Name,Selling_Entity__c,Sold_To_Name__r.Name,Sold_To_Address__c,Sold_To_City__c,Sold_To_State__c,Overage_Allowance__c,End_User_ID__r.Name,
                    Sold_To_Zip_Code__c,Sold_To_Country__c,Expiration_Date__c,Quote_Created_Date_Formula__c,Owner.Name,Contact__r.Name,Price_Escalation__c,Show_Updated_Quantity_Only__c,
                    Contact__r.ContactPhone__c,Contact__r.Email,Initial_Subscription_Term__c,No_Of_Months__c,Renewal_Subscription_Term__c,Overage_Allowance_Other__c,
                    CurrencyIsoCode,Order_Payment_Terms__c,Billing_Period__c,Pricing_Model__c,Opportunity_Offering_Type__c,Total_Education_Change__c,Annual_Price_Escalation_Other__c,
                    BigMachines__Opportunity__r.Sold_To_Country__r.PureConnect_Cloud_Selling_Entity__c,BigMachines__Opportunity__r.Direct_Indirect_Sale__c,
                    BigMachines__Opportunity__r.Sold_To_Country__r.PureCloud_Selling_Entity__c,Total_Hardware_Change__c ,Non_Recurring_Fees_Changes__c ,
                    BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,PureSuccess__c , Show_One_Time_Fees_Only__c,Billing_Category__c ,  
                    PureSuccess_Offer_Subscription_Amount__c,A_La_Carte_PureSuccess_Services_Amount__c,Token_Value__c,Setup_Provisioning_Charges_Change__c,
                    Include_Special_Offer_in_Output__c,Special_Offer_Terms__c,Additional_Legal_Terms__c,Legal_Terms__c,Annual_Contract_Value_Change__c ,
                    SOW_Link__c,MSA_Link__c,Annual_Contract_Value__c,Setup_Provisioning_Charges__c,CPS_Total__c,Total_Contract_Value__c,
                    Offering_Type__c,Opp_Sold_To_Country__c,CMRR__c,Ramp_Period__c,Deployment_Model__c,Order_Type__c ,Total_Tokens_Change__c, 
                    Hide_Discount__c,Hide_Totals__c,Treat_SO_as_PO__c,Genesys_University_Training_Total__c,Proposal_Language__c,CMRR_Change__c,
                    Proposal_Date__c,Non_Recurring_Fees__c,Product_Tier__c, Minimum_Fees_Period__c,Total_Education__c,Total_Hardware__c,Group_Product_By__c,
                    BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c,Telco_Cost__c,Amendment_For__c,Subscription_Start_Date__c,
                    Subscription_End_Date__c,Hide_List_Price__c,Oppty_Lead_Offer__c,BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,BigMachines__Opportunity__r.BusinessPartner__r.name,BigMachines__Opportunity__r.Sold_To_Country__r.Name
                    FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
        intRemainingTerm = objQuote.Subscription_Start_Date__c.monthsBetween(objQuote.Subscription_End_Date__c);
        if(objQuote.Subscription_Start_Date__c < Date.today() && objQuote.Subscription_End_Date__c > Date.today())
        {
            intRemainingTerm = Date.today().monthsBetween(objQuote.Subscription_End_Date__c);
        } 
        //Anju PCC Amend
        if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
           && objQuote.Amendment_For__c != null) {
               
               Integer intNumofMonths = objQuote.Billing_Period__c == 'Annually'? 12 : objQuote.Billing_Period__c == 'Semi-Annually'? 6 : objQuote.Billing_Period__c == 'Quarterly' ? 3 : 1 ;
               intCurrYrProration = intRemainingTerm == intNumofMonths ? intNumofMonths : (Math.mod(intRemainingTerm, intNumofMonths) == 0 ? intNumofMonths : Math.mod(intRemainingTerm, intNumofMonths));
                   
                   objSubscription = SubscriptionUtil.getSubscription(objQuote.Amendment_For__c);
               for(Subscription_Product__c objSubscrProd : objSubscription.Subscription_Products__r) {
                   map_AllOriginalSubscrProds.put(objSubscrProd.Product__c+';'+objSubscrProd.Is_Overage__c, objSubscrProd);
                   if(objSubscrProd.Product__r.Product_Group__c == 'One-Time Fees') {
                       decOriginalOneTimeTotals += objSubscrProd.Ext_Net_Price__c;
                   }
               }
               System.debug('#####map_AllOriginalSubscrProds: '+map_AllOriginalSubscrProds);
           }
    }
    
    // *** Method to query Quote Products ***
    void fetchQuoteProducts()
    {
        
        //if standard view
        map_ExistingOriginalSubscrProds = new Map<String, Subscription_Product__c>();
        map_ProductvsQuantityChange = new Map<Id,BigMachines__Quote_Product__c>(); 
        if(objQuote.Group_Product_By__c == 'Standard View' || objQuote.Group_Product_By__c == '' || objQuote.Group_Product_By__c == null){
            for(BigMachines__Quote_Product__c objQP : Database.query(createQuoteProductQueryString('Standard View')))
            {
                map_ProductvsQuantityChange.put(objQP.BigMachines__Product__c,objQP);
                //Anju PCC Amend
                if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
                   && objQuote.Amendment_For__c != null) {
                       set_ExistingProductIds.add(objQP.BigMachines__Product__c);
                       map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, new Subscription_Product__c());
                       if(map_AllOriginalSubscrProds.containsKey(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c)) {
                           map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, map_AllOriginalSubscrProds.get(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c));
                       }
                   }
                System.debug('map_ExistingOriginalSubscrProds'+map_ExistingOriginalSubscrProds); 
                if(map_ProductGroupToQuoteProducts.containsKey(objQP.BigMachines__Product__r.Product_Group__c) )
                    map_ProductGroupToQuoteProducts.get(objQP.BigMachines__Product__r.Product_Group__c).add(objQP);
                else
                {
                    if((objQP.BigMachines__Product__r.Product_Group__c == 'Monthly Telco' || objQP.BigMachines__Product__r.Product_Group__c == 'Monthly MPLS')  ){
                        map_ProductGroupToQuoteProducts.put('Monthly Telco/MPLS/Data Center Fees',new List<BigMachines__Quote_Product__c>{objQP});
                        map_ProductGroupsToShow.put('Monthly Telco/MPLS/Data Center Fees',true);
                    }
                    else if(objQP.BigMachines__Product__r.Product_Group__c == 'Other Services' && Label.PCC_Other_Services_Exceptions.contains(objQP.BigMachines__Product__r.APN_Number__c))
                    {
                        map_ProductGroupToQuoteProducts.put('OtherServices',new List<BigMachines__Quote_Product__c>{objQP});
                        map_ProductGroupsToShow.put('OtherServices',true);
                    }
                    else {
                        {map_ProductGroupToQuoteProducts.put(objQP.BigMachines__Product__r.Product_Group__c,new List<BigMachines__Quote_Product__c>{objQP});}
                        { map_ProductGroupsToShow.put(objQP.BigMachines__Product__r.Product_Group__c,true);}
                    }
                }
                system.debug(map_ProductGroupToQuoteProducts);
                /*Anju March 2018 Telco cost
if(objQP.BigMachines__Product__r.Product_Group__c != null && (objQP.BigMachines__Product__r.Product_Group__c == 'Monthly Telco/MPLS/Data Center Fees' || objQP.BigMachines__Product__r.Product_Group__c == 'Monthly Telco' || objQP.BigMachines__Product__r.Product_Group__c == 'Monthly MPLS'))
decTelcoCost += objQP.Extended_Price_Per_Month__c;*/
                //Ends Anju
                
                //Added By Ranjith on May 24, 2017 -- Starts
                //Logic to display Monthyl Recurring Telco table  
                if(objQP.BigMachines__Product__r.APN_Number__c == 'CS-012-NV-AR01' && objQuote.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c == 'North America') {
                    objMonthlyTelcoProd = objQP;
                    blnDisplayMonthlyTelcoTable = true;
                }
                //Added By Ranjith on May 24, 2017 -- Ends
                //Added By Ranjith on Jun 06, 2017 -- Starts           
                if((map_ProdGroupCategorization.get('Recurring Fees').contains(objQP.BigMachines__Product__r.Product_Group__c) || 
                    map_ProdGroupCategorization.get('Monthly Recurring (Telco) Fees').contains(objQP.BigMachines__Product__r.Product_Group__c)) &&
                   !Label.PCC_Other_Services_Exceptions.contains(objQP.BigMachines__Product__r.APN_Number__c)) {
                       blnHasRecurring = true; 
                       System.debug('$$$$$QP name'+ objQP.Name);
                       strRecServBillingPeriod = (objQuote.Billing_Period__c =='Annually'?'Annual':(objQuote.Billing_Period__c =='Semi-Annually'?'Semi-Annual':(objQuote.Billing_Period__c =='Quarterly'?'Quarterly':(objQuote.Billing_Period__c =='Monthly'?'Monthly':String.valueof(objQuote.No_Of_Months__c)+' Months'))));
                       System.debug(' strRecServBillingPeriod'+ strRecServBillingPeriod);
                       if(map_ProdGroupCategorization.get('Monthly Recurring (Telco) Fees').contains(objQP.BigMachines__Product__r.Product_Group__c))
                           blnHasMonthlyTelco = true;  
                       
                   } 
                //Added By Ranjith on Jun 06, 2017 -- Ends
                else
                    blnHasNonRecurring = true;
                
                //Anju Jan 2018 PureSuccess starts   
                if(map_PureSuccessProductGroupsToShow.containskey(objQP.BigMachines__Product__c))
                {
                    map_PureSuccessProductGroupsToShow.put(objQP.BigMachines__Product__c,true);
                }
                
                if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte')
                {
                    list_AlacItems.add(objQP);
                }
                if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription) && (map_PureSuccessProductGroupsToShowForAmend.containskey(objQP.BigMachines__Product__c)) && objQP.Subscription_Product__c == null )
                {
                    map_PureSuccessProductGroupsToShowForAmend.put(objQP.BigMachines__Product__c,true);
                    decPureSuccessOfferChangeAmount += objQP.Ext_Net_Price__c;
                }
                
                if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription) && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') && objQP.Subscription_Product__c == null)
                {
                    list_AlacItemsForAmend.add(objQP);
                    decPureSuccessAlaCarteChangeAmount += objQP.Ext_Net_Price__c;
                }
                //Anju Jan 2018 PureSuccess ends
                
                if(objQP.BigMachines__Product__r.Product_Group__c == 'Non-Recurring Fees' && objQP.BigMachines__Product__r.Sub_Category__c == 'Credit' && objQP.Ext_Net_Price__c != null)
                {
                    decOneTimeCreditAmout += objQP.Ext_Net_Price__c;
                }
                
                if(objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Fees' && objQP.BigMachines__Product__r.Sub_Category__c == 'Credit' && objQP.Ext_Net_Price__c != null)
                {
                    decRecCreditAmout += objQP.Ext_Net_Price__c;
                }
                
                decOneTimeCreditAmout *= -1;
                decRecCreditAmout *= -1;
                System.debug('map_ExistingOriginalSubscrProds'+map_ExistingOriginalSubscrProds); 
                System.Debug(map_PureSuccesGroupItems);
                System.Debug(list_AlacItems);
                System.Debug(map_PureSuccessProductGroupsToShow);
                System.Debug(map_PureSuccessProductGroupsToShowForAmend);
                System.Debug(list_AlacItemsForAmend);
                
                for(String strPrd:map_PureSuccessProductGroupsToShow.keyset()  )
                {
                    if(map_PureSuccessProductGroupsToShow.get(strPrd) && objQuote.Order_Type__c != Label.Amend_Subscription)
                        blnDisplayPureSucessMessage = true;
                    
                }
                blnDisplayPureSucessMessage = (list_AlacItems.size() > 0 && objQuote.Order_Type__c != Label.Amend_Subscription)?true:blnDisplayPureSucessMessage;
                if((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription) ){
                    for(String strPrd:map_PureSuccessProductGroupsToShowForAmend.keyset())
                    {
                        if(map_PureSuccessProductGroupsToShowForAmend.get(strPrd))
                            blnDisplayPureSucessMessageForAmend = true;
                        
                    }
                    blnDisplayPureSucessMessageForAmend = (list_AlacItemsForAmend.size() > 0)?true:blnDisplayPureSucessMessageForAmend;
                    System.debug('$$$$$map_ProductGroupsToShow'+map_ProductGroupsToShow);
                }      
            }
        }  
        //proposal group view Sep 28 Anju starts
        else{
            getProporalGroupsMap(objQuote.id);
            list_ProductGroups = new List<Service_Order_Product_Group__c>();
            for(BigMachines__Quote_Product__c objQP : Database.query(createQuoteProductQueryString('Proposal Group View')))
            {
                if(map_ProductGroupToQuoteProducts.containsKey(objQP.Group_Number__c) ){
                    map_ProductGroupToQuoteProducts.get(objQP.Group_Number__c).add(objQP);
                    
                }
                else{
                    {
                        map_ProductGroupToQuoteProducts.put(objQP.Group_Number__c,new List<BigMachines__Quote_Product__c>{objQP});
                        map_ProductGroupsToShow.put(objQP.Group_Number__c,true);
                        list_ProductGroups.add(new Service_Order_Product_Group__c(Group_Name__c = objQP.Group_Number__c, name = objQP.Group_Number__c, Header_Text__c = mapProposalGroupNumberVsName.get(objQP.Group_Number__c)));
                    }
                }
                
            }
            
            
        }
        //proposal group view Sep 28 Anju ends
        
        if(set_ExistingProductIds.size() > 0) {   
            list_RemovedProducts = SubscriptionUtil.getRemovedProductsFromAmendedQuote(set_ExistingProductIds, objSubscription); 
        }
        list_RemovedProductsToShow = new List<Subscription_Product__c>();
        System.debug('list_RemovedProducts'+list_RemovedProducts);
        if(list_RemovedProducts != null && list_RemovedProducts.size()>0 ){
            String strObjName = 'BigMachines__Quote_Product__c';
            String strWhereCondition = 'Hide_Record__c = false AND Is_Overage__c = False AND BigMachines__Quote__c = \''+ objquote.Id + '\'' ;
            List<BigMachines__Quote_Product__c> list_QPs = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            for(Subscription_Product__c objSP:list_RemovedProducts){
                if( objquote.Show_Updated_Quantity_Only__c){
                    for(BigMachines__Quote_Product__c objQP:list_QPs){
                        set_PRodIds.add(objQP.BigMachines__Product__c);
                    }
                    System.debug(objSP);
                    System.debug(map_ProductvsQuantityChange.get(objSP.Product__c));
                    if(!objSP.Hide_Record__C && !set_PRodIds.contains(objSP.Product__c) && !objSP.Is_Overage__c)
                        list_RemovedProductsToShow.add(objSP);
                }
                else{                        
                    if(!objSP.Hide_Record__C)
                        list_RemovedProductsToShow.add(objSP);
                }
            }     
        }      
        System.debug('list_RemovedProducts'+list_RemovedProducts);
        System.debug('set_ExistingProductIds'+set_ExistingProductIds);
        //List of Overage Products - Rony Joseph-August 22nd 2018-Starts
        list_OverageProducts = Database.query(createQuoteProductQueryStringOverage('Overage'));
        System.debug(list_OverageProducts);
        if(list_OverageProducts.size()>0){
            map_ProductGroupsToShow.put('Bursting Premium Pricing',true);
            map_ProductGroupToQuoteProducts.put('Bursting Premium Pricing',new List<BigMachines__Quote_Product__c>());
            for(BigMachines__Quote_Product__c objQP : list_OverageProducts){
                System.debug(objQP+'Source'+map_AllOriginalSubscrProds);
                map_ProductGroupToQuoteProducts.get('Bursting Premium Pricing').add(objQP);
                /* if(map_AllOriginalSubscrProds.containsKey(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c)) */{
                    map_ExistingOriginalSubscrProds.put(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c, map_AllOriginalSubscrProds.get(objQP.BigMachines__Product__c+';'+objQP.Is_Overage__c));
                }
            }
            
        }
        //List of Overage Products - Rony Joseph-August 22nd 2018-Ends  
        System.debug('map_ExistingOriginalSubscrProds'+map_ExistingOriginalSubscrProds);
        if(objQuote.Order_Type__c == Label.Amend_Subscription ){
            List<Service_Order_Product_Group__c> list_PCCNonRecurringProductGroup = [select Group_Name__c from Service_Order_Product_Group__c where Edition__c = 'PureConnect Cloud' and    Billing_Type__c = 'Non-Recurring Fees'];
            for(Service_Order_Product_Group__c objSOPG:list_PCCNonRecurringProductGroup){
                System.debug(objSOPG.Group_Name__c) ;
                System.debug(map_ProductGroupToQuoteProducts.keySet());
                if(map_ProductGroupToQuoteProducts.containsKey(objSOPG.Group_Name__c)){
                    System.debug('Size'+map_ProductGroupToQuoteProducts.get(objSOPG.Group_Name__c).size()+'GP'+objSOPG.Group_Name__c);
                    for(integer i=0;i<map_ProductGroupToQuoteProducts.get(objSOPG.Group_Name__c).size();i++)
                    {   
                        BigMachines__Quote_Product__c objQP =map_ProductGroupToQuoteProducts.get(objSOPG.Group_Name__c)[i]; 
                        if(objQP.Subscription_Product__c != null && (objQP.Quantity_Change__c == 0)){map_ProductGroupToQuoteProducts.get(objSOPG.Group_Name__c).remove(i);i--;}
                    }
                    
                    if(map_ProductGroupToQuoteProducts.get(objSOPG.Group_Name__c).size()>0)
                    {map_ProductGroupToQuoteProducts.get(objSOPG.Group_Name__c).sort();}
                    else
                    { map_ProductGroupsToShow.put(objSOPG.Group_Name__c,false) ; }
                }  
            }
            blnHasNonRecurring = false;
            for(Service_Order_Product_Group__c objSOPG:list_PCCNonRecurringProductGroup){
                
                blnHasNonRecurring = (map_ProductGroupsToShow.get(objSOPG.Group_Name__c))?true:blnHasNonRecurring;
                
            }
        }      
        System.debug(map_ExistingOriginalSubscrProds.keySet());
        strKeySet = String.valueof(map_ExistingOriginalSubscrProds.keySet()).replace('{', '').replace('}', '');
        System.debug('strKeySet'+strKeySet);
        List<string> strlist= strKeySet.split(',');
        For(String str:strlist){
            System.debug(str);
        }
        System.debug('map_ExistingOriginalSubscrProds'+map_ExistingOriginalSubscrProds);
        for(string strkey:map_ExistingOriginalSubscrProds.keyset()){
            System.debug('Key'+strkey+'Quantity'+map_ExistingOriginalSubscrProds.get(strkey));
        }
        
        map_ExistingOriginalSubscrProds2 = new Map<String, Subscription_Product__c>();
        
        for(String str_Key :map_ExistingOriginalSubscrProds.keyset()){
            map_ExistingOriginalSubscrProds2.put(str_Key,map_ExistingOriginalSubscrProds.get(str_Key));
        }
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
        
        //Mukunth added BigMachines__Product__c to query for 6 digit project on 06-APR-2019
        strQuery += 'Unit_of_Measure__c,BigMachines__Product__c,Is_Overage__c,BigMachines__Product__r.description,BigMachines__Product__r.description__c,BigMachines__Quantity__c,BigMachines__Quote__r.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c,Updated_Quantity__c,Subscription_Product__c,BigMachines__Product__r.Sub_Category__c  FROM BigMachines__Quote_Product__c WHERE Hide_Record__c = false AND Is_Overage__c = false And BigMachines__Quote__c = \'' ; 
        strQuery += objQuote.Id + '\'';
        if(outPutType == 'Standard View' && objQuote.Order_Type__c.Contains('Amend') && objQuote.Show_Updated_Quantity_Only__c)
            strQuery +=( ' And (Quantity_Change__c > 0  OR Parent_Quote_Product__r.Quantity_Change__c > 0)');
        if(objQuote.offering_type__c == 'PureConnect Cloud' && !objQuote.Show_Updated_Quantity_Only__c)
            strQuery += ' AND BigMachines__Product__r.New_Category__c !=\'Use Case\'';
        if(outPutType == 'Standard View')   
            strQuery += ' ORDER BY BigMachines__Product__r.Sort_Order__c,Name';
        else
            strQuery += ' ORDER BY Group_Number__c NULLS last';
        System.debug('outPutType:'+outPutType+'strQuery'+strQuery);
        return strQuery;
    }
    // *** Method to create query string to query Overage Quote Products ***
    String createQuoteProductQueryStringOverage(String outPutType)
    {
        String strQuery = 'SELECT ';
        
        //Getting fields from Service Order Output field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> list_QuoteProductFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Service_Order_Output.getFields();
        for(Schema.FieldSetMember field : list_QuoteProductFields)
            strQuery += field.getFieldPath() + ', ';
        
        //Mukunth added BigMachines__Product__c to below query for 6 digit project on 10-APR-2019
        strQuery += 'Unit_of_Measure__c,BigMachines__Product__c,Is_Overage__c,BigMachines__Product__r.description,BigMachines__Product__r.description__c,BigMachines__Quantity__c,BigMachines__Quote__r.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c,Updated_Quantity__c,Subscription_Product__c FROM BigMachines__Quote_Product__c WHERE Hide_Record__c = false AND BigMachines__Quote__c = \'' ; 
        strQuery += objQuote.Id + '\'';
        if(objQuote.Order_Type__c.Contains('Amend') && objQuote.Show_Updated_Quantity_Only__c)
            strQuery +=( ' And (Quantity_Change__c > 0  OR Parent_Quote_Product__r.Quantity_Change__c > 0)');
        if(objQuote.offering_type__c == 'PureConnect Cloud')
            strQuery += ' AND BigMachines__Product__r.New_Category__c !=\'Use Case\'';
        if(outPutType == 'Overage')   
            strQuery += ' AND Is_Overage__c =  true';        
        if(outPutType == 'Standard View')   
            strQuery += ' ORDER BY BigMachines__Product__r.Sort_Order__c,Name';
        else
            strQuery += ' ORDER BY Group_Number__c NULLS last';
        System.debug('outPutType:'+outPutType+'strQuery'+strQuery);
        return strQuery;
    }
    
    
    // *** Method to initialize Product Groups from custom settings ***
    void initializeProductGroups()
    {
        map_ProductGroupToQuoteProducts = new Map<String,List<BigMachines__Quote_Product__c>>();
        map_ProductGroupsToShow = new Map<String,Boolean>();
        //String strEdition = QuoteUtil.OFFERING_TYPE_CAAS;
        String strEdition = 'PureConnect Cloud';
        map_PureSuccessProductGroupsToShow = new Map<String,Boolean>();
        map_PureSuccesGroupItems = new Map<String,List<Product_Group_Item__c>>();
        map_PureSuccesGroupItemsForAmend = new Map<String,List<Product_Group_Item__c>>();
        map_PureSuccessProductGroupsToShowForAmend  = new Map<String,Boolean>();
        
        list_ProductGroups = [SELECT Group_Name__c,Header_Text__c, Billing_Type__c 
                              FROM Service_Order_Product_Group__c 
                              WHERE Edition__c = :strEdition 
                              AND Billing_Type__c != ''
                              AND Group_Name__c NOT IN ('Monthly MPLS','Monthly Telco') ORDER BY Name,Billing_Type__c,Sort_Order__c];
        
        for(Service_Order_Product_Group__c objProductGroup : list_ProductGroups)  {         
            map_ProductGroupsToShow.put(objProductGroup.Group_Name__c,false);      
            if(map_ProdGroupCategorization.containsKey(objProductGroup.Billing_Type__c)) {
                map_ProdGroupCategorization.put(objProductGroup.Billing_Type__c, map_ProdGroupCategorization.get(objProductGroup.Billing_Type__c)+';'+objProductGroup.Group_Name__c);
            }
            else {
                map_ProdGroupCategorization.put(objProductGroup.Billing_Type__c, objProductGroup.Group_Name__c);
            }
        }            
        //Anju Jan 2018 PureSuccess starts
        for(Product_Group__c pG : [Select id,Product__c,Product__r.description__c,(Select id,name,Quantity__c,Product__c,Product__r.name,Product__r.description,Product__r.description__c,Product__r.Unit_of_Measure__c from Product_Group_Items__r where Product__r.APN_Number__c != :Label.Token_APN_Number) from Product_Group__c where Offering_Type__c includes ('PureConnect Cloud') AND Group_Type__c = 'PureSuccess']){
            map_PureSuccessProductGroupsToShow.put(pG.Product__c,false);
            map_PureSuccesGroupItems.put(pG.Product__c,pG.Product_Group_Items__r);
        }
        for(Product_Group__c pG : [Select id,Product__c,Product__r.description__c,(Select id,name,Quantity__c,Product__c,Product__r.name,Product__r.description,Product__r.description__c,Product__r.Unit_of_Measure__c from Product_Group_Items__r where Product__r.APN_Number__c != :Label.Token_APN_Number) from Product_Group__c where Offering_Type__c includes ('PureConnect Cloud') AND Group_Type__c = 'PureSuccess']){
            map_PureSuccessProductGroupsToShowForAmend.put(pG.Product__c,false);
            map_PureSuccesGroupItemsForAmend.put(pG.Product__c,pG.Product_Group_Items__r);
        }
        
        //Anju Jan 2018 PureSuccess ends
        System.debug('$$$$$map_ProductGroupsToShow'+map_ProdGroupCategorization);
    }
    
    //Methond to return proposal groups -- Sep 28 Anju Starts
    void getProporalGroupsMap(Id quoteId){
        mapProposalGroupNumberVsName = new Map<String, String> ();
        List<Quote_Proposal_Group__c> proposalGroups = [SELECT Group_Number__c, Name__c, Description__c  FROM Quote_Proposal_Group__c 
                                                        WHERE Quote__c =: quoteId];
        for(Quote_Proposal_Group__c eachQPG : proposalGroups){
            String description = '';
            if(eachQPG.Description__c != null){
                if(eachQPG.Description__c.length() > 40){
                    description = eachQPG.Description__c.substring(0, 39) + ' ...';  
                }
                else
                    description = eachQPG.Description__c;
                description = ' ('+ description +')';
            }
            mapProposalGroupNumberVsName.put(eachQPG.Group_Number__c, eachQPG.Name__c + ' '+ description);
        }
        
    }
    //Methond to return proposal groups -- Sep 28 Anju ends
}