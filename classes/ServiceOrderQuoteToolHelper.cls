public without sharing class ServiceOrderQuoteToolHelper 
{
    public static final String PRIMIER_EDITION_CLOUD = 'Premier Edition';
    public static final String ENTERPRISE_EDITION_CLOUD = 'Enterprise Edition';
    public static final String BUSINESS_EDITION_CLOUD = 'Business Edition';
    public static final String SELF_SERVICE = 'Self Service';
    public static final String PROACTIVE_COMMUNICATIONS = 'Proactive Communications';
    public static final String MOBILE_MARKETING = 'Mobile Marketing';
    public static DDSCloud.DDSCloudModel obj_DDS {get; set;}
    public static DealScoreHistory__c objDDSHistory {get;set;}
    
    // To store total Enhanced IVR minutes to calculate ASR
    static Double decTotalEnhancedIVRMins = 0;
    // To store total Amount of Enhanced IVR Options and Integrations except CX Analytics
    static Double decTotalIVROptAndInt = 0;
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> populateQuoteProducts(BigMachines__Quote__c quote, String category, String updgradeType, String showSelected, 
                                                                                                   Map<String, List<SelectOption>> mapProductVsProductDevices)
    {          
        List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLineItems = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();       
        System.debug('NKC debug category ['+category+']');
        List<Product2> products = [SELECT Id, Name, Product_Group__c, Product_Category__c, Unit_of_Measure__c, Description, APN_Number__c,
                                   Price_Type__c, Product_Option__c, Include_in_CMMR_Total__c, Show_Product_As_Link_to_Price_List__c, 
                                   Show_Net_Price_as_View__c, Type__c, List_Price__c, Is_List_Price_Is_In_Percentage__c,Cloud_Quoting_Phase_Out_Date__c, 
                                   Calculate_List_Price_From__c, Add_Premium_Charges__c,Discountable__c, Pricing_Model__c, Show_Add_Sign__c, Include_in_Agent_Seat_Count__c,
                                   Is_Product_Name_Editable__c, Description__c, Concurrent_List_Price__c, List_Price_GBP__c, List_Price_EUR__c,List_Price_AUD__c,List_Price_CAD__c
                                   FROM Product2 WHERE Product_Category__c =: category AND IsActive = true
                                   AND Product_Group__c IN ('User Subscription','Port Subscription','Customer Subscription','Rented Equipment/Communication Fees/Short Codes','Time Based',
                                                            'Transaction Based','Tier Based','Configuration Professional Services','Client Management',
                                                            'IVR and Media Port Options', 'IVR / Media Port Add Ons', 'Per Seat Pricing (Base Options)', 'Digital Channels Options', 'Quality Management',
                                                            'Workforce Optimization', 'Other Services', 'End User End Points','Cloud Contact Center Adapters', 'Inbound to IVR','Bridging Leg / Transfer to PSTN or PLMN', 
                                                            'Outbound to PSTN or PLMN', 'MPLS', 
                                                            'Genesys Care', 'Telco Cross Connect', 'Professional Services Rapid Deployment ImplementationPackages', 'Professional Services Implementation',
                                                            'Installation','Genesys Cloud Care','Genesys University Training','ASR and TTS','BluIP',
                                                            'Per Message/Per Minute','SW/Platform Implementation','Short/Long Code Non Recurring Fees','Short/Long Code Recurring Fees',
                                                            'SW/Platform Licensing','IVR Options','Inbound Seat Add-On Options','Adapter Service Options','Other Options','Implementation Charges',
                                                            'Self-Service/IVR','Self-Service/IVR Options','Self-Service/IVR Integrations','Outbound Campaign Manager',
                                                            'Telecommunications Options','Connectivity Options','Per Seat Pricing','Access Fees','PureSuccess Direct Offer','PureSuccess Indirect Offer','PureSuccess Direct A-la-Carte','PureSuccess Indirect A-la-Carte','Bots and AI')
                                   AND (Available_For_Currencies__c = null OR Available_For_Currencies__c = : quote.CurrencyIsoCode) ORDER BY Sort_Order__c NULLS FIRST];
        
        List<Product2> supportProducts = [SELECT Name, Product_Group__c, Product_Category__c, Unit_of_Measure__c, APN_Number__c,
                                          Description, Price_Type__c, Product_Option__c, Include_in_CMMR_Total__c, Show_Product_As_Link_to_Price_List__c,
                                          Show_Net_Price_as_View__c,Type__c, List_Price__c, Is_List_Price_Is_In_Percentage__c,Cloud_Quoting_Phase_Out_Date__c, 
                                          Calculate_List_Price_From__c, Add_Premium_Charges__c, Discountable__c,Pricing_Model__c, Show_Add_Sign__c, 
                                          Is_Product_Name_Editable__c, Concurrent_List_Price__c, List_Price_GBP__c, List_Price_EUR__c, List_Price_AUD__c,List_Price_CAD__c,Include_in_Agent_Seat_Count__c
                                          FROM Product2 WHERE IsActive = true AND Product_Group__c = 'Support'];
        
        products.addAll(supportProducts);
        
        Map<String, List<BigMachines__Quote_Product__c>> mapProductIdVsQuoteProduct = new Map<String, List<BigMachines__Quote_Product__c>>(); 
        if(quote.id != null)
        {
            List<BigMachines__Quote_Product__c> quoteProducts = (List<BigMachines__Quote_Product__c>)Database.query(ServiceOrderQuoteHelper.prepareQuoteProductQuery(quote.id));            
            for(BigMachines__Quote_Product__c eachQuoteProduct: quoteProducts)
            {
                if(mapProductIdVsQuoteProduct.containsKey(eachQuoteProduct.BigMachines__Product__c))
                    mapProductIdVsQuoteProduct.get(eachQuoteProduct.BigMachines__Product__c).add(eachQuoteProduct);             
                else
                {
                    List<BigMachines__Quote_Product__c> quoteProducts1 = new List<BigMachines__Quote_Product__c>();
                    quoteProducts1.add(eachQuoteProduct);
                    mapProductIdVsQuoteProduct.put(eachQuoteProduct.BigMachines__Product__c, quoteProducts1);   
                }               
            }
        }
        System.debug('NKC debug mapProductIdVsQuoteProduct ['+mapProductIdVsQuoteProduct+']');
        Integer counter = 0;
        Double concurrentUplift = Currency_Settings__c.getAll().get(quote.CurrencyISOCode).Cloud_BE_Concurrent_Uplift_multiplier__c;
        for(Product2 eachProduct : products)
        {
            ServiceOrderQuoteToolController.wrapperQuoteProducts newRecord = new ServiceOrderQuoteToolController.wrapperQuoteProducts();
            BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
            System.debug('NKC debug eachProduct.id ['+eachProduct.id+']');
            System.debug('NKC debug mapProductIdVsQuoteProduct.get(eachProduct.id) ['+mapProductIdVsQuoteProduct.get(eachProduct.id)+']');
            newRecord.isListPriceEditable = eachProduct.Price_Type__c == 'Editable' ? true : false ;            
            newQuoteProduct.List_Price__c = eachProduct.List_Price__c;
            System.debug('NKC debug eachProduct.List_Price__c ['+newQuoteProduct.List_Price__c+']');
            newRecord.record = newQuoteProduct;
            newRecord.index = counter;  
            newRecord.detailRow = true; 
            newRecord.dtPhaseOut = eachProduct.Cloud_Quoting_Phase_Out_Date__c;
            System.debug('NKC debug updgradeType ['+updgradeType+']');
            
            if(mapProductIdVsQuoteProduct.get(eachProduct.id) != null)
            {
                //if(mapProductIdVsQuoteProduct.get(eachProduct.id) == null)
                //  continue;
                for(BigMachines__Quote_Product__c eachQuoteProduct : mapProductIdVsQuoteProduct.get(eachProduct.id))
                {
                    newRecord = new ServiceOrderQuoteToolController.wrapperQuoteProducts();
                    newRecord.index = counter;
                    newQuoteProduct = eachQuoteProduct;                  
                    //if(updgradeType == null || showSelected != null)
                    newRecord.selected = true;
                    newRecord.record = newQuoteProduct;
                    newRecord.hasDevcies = mapProductVsProductDevices.get(newQuoteProduct.BigMachines__Product__c) == null ? false : true ;
                    newRecord.productDescription = eachProduct.Description;
                    //Anju Jan 2018 PureSuccess starts
                    if(quote.Offering_Type__c == 'Business Edition' && (eachProduct.product_group__c == 'PureSuccess Direct Offer' || eachProduct.product_group__c == 'PureSuccess Indirect Offer' || eachProduct.product_group__c == 'PureSuccess Direct A-la-Carte' || eachProduct.product_group__c == 'PureSuccess Indirect A-la-Carte'))
                        newRecord.productDescription = eachProduct.Description__c;
                    //Anju Jan 2018 PureSuccess ends
                    
                    newRecord.productOption = eachProduct.Product_Option__c;
                    newRecord.includeInCMRR = eachProduct.Include_in_CMMR_Total__c;
                    newRecord.showOrderAsLink = eachProduct.Show_Product_As_Link_to_Price_List__c;
                    newRecord.showNetPriceAsView = eachProduct.Show_Net_Price_as_View__c;
                    newRecord.productType = eachProduct.Type__c;
                    newRecord.isListPriceEditable = eachProduct.Price_Type__c == 'Editable' ? true : false ;
                    newRecord.isListPriceInDiscount = eachProduct.Is_List_Price_Is_In_Percentage__c;
                    newRecord.listPriceCalculateFrom = eachProduct.Calculate_List_Price_From__c;
                    newRecord.addPremiumCharges = eachProduct.Add_Premium_Charges__c;
                    newRecord.isDiscountable = eachProduct.Discountable__c;
                    newRecord.pricingModel = eachProduct.Pricing_Model__c;
                    newRecord.autoSelected = false;
                    newRecord.detailRow = true; 
                    newRecord.showAddSign = eachProduct.Show_Add_Sign__c;
                    newRecord.isProductNameEditable = eachProduct.Is_Product_Name_Editable__c;
                    
                    //Anju March 2018 Seat Count
                    newRecord.blnIncludeinSeatCount = eachProduct.Include_in_Agent_Seat_Count__c;
                    newRecord.strApnNumber = eachProduct.APN_Number__c;
                    
                    System.debug('NKC debug newRecord.listPriceCalculateFrom ['+newRecord.listPriceCalculateFrom+']');              
                    quoteLineItems.add(newRecord);
                    counter ++;
                    
                }
            }
            else
            {
                if(!eachProduct.Is_Product_Name_Editable__c)
                    newQuoteProduct.Product__c = eachProduct.Name;
                
                newQuoteProduct.Metric__c = eachProduct.Unit_of_Measure__c;
                newQuoteProduct.BigMachines__Product__c = eachProduct.id;
                newQuoteProduct.Product_Group__c = eachProduct.Product_Group__c;
                newQuoteProduct.BigMachines__Quote__c = quote.id;
                newQuoteProduct.BigMachines__Sales_Price__c = 0;
                //Anju Jan 2018 PureSuccess starts
                if(quote.Offering_Type__c == 'Business Edition' && (eachProduct.product_group__c == 'PureSuccess Direct Offer' || eachProduct.product_group__c == 'PureSuccess Indirect Offer' || eachProduct.product_group__c == 'PureSuccess Direct A-la-Carte' || eachProduct.product_group__c == 'PureSuccess Indirect A-la-Carte'))
                    newQuoteProduct.Name = eachProduct.description__c;
                else                        
                    newQuoteProduct.Name = eachProduct.Name;                    
                newQuoteProduct.BigMachines__Description__c = eachProduct.Name;
                newQuoteProduct.CurrencyIsoCode = quote.CurrencyIsoCode;
                newRecord.record = newQuoteProduct;
                
                //If GBP List price is available use it and don't use conversion
                if(quote.CurrencyIsoCode == 'GBP' && eachProduct.List_Price_GBP__c != null)
                    newRecord.record.List_Price__c = eachProduct.List_Price_GBP__c;
                
                //If EUR List price is available use it and don't use conversion
                else if(quote.CurrencyIsoCode == 'EUR' && eachProduct.List_Price_EUR__c != null)
                    newRecord.record.List_Price__c = eachProduct.List_Price_EUR__c;
                
                //If AUD List price is available use it and don't use conversion
                else if(quote.CurrencyIsoCode == 'AUD' && eachProduct.List_Price_AUD__c != null)
                    newRecord.record.List_Price__c = eachProduct.List_Price_AUD__c;
                
                //If CAD List price is available use it and don't use conversion
                else if(quote.CurrencyIsoCode == 'CAD' && eachProduct.List_Price_CAD__c != null)
                    newRecord.record.List_Price__c = eachProduct.List_Price_CAD__c;
                
                if(quote.Pricing_Model__c == 'Concurrent' && eachProduct.Pricing_Model__c != null
                   && eachProduct.Pricing_Model__c.contains('Concurrent') && newRecord.record.List_Price__c != null && 
                   newRecord.record.List_Price__c != 0)
                {
                    if(eachProduct.Concurrent_List_Price__c == null)                    
                        newRecord.record.List_Price__c *= concurrentUplift;
                    else
                        newRecord.record.List_Price__c = eachProduct.Concurrent_List_Price__c * Currency_Settings__c.getInstance(quote.CurrencyIsoCode).Conversion_Rate__c;     
                }
                
                if((!(quote.Pricing_Model__c == 'Concurrent' && eachProduct.Concurrent_List_Price__c != null)) &&
                   ((quote.currencyIsoCode != 'USD' && quote.currencyIsoCode != 'GBP' && quote.currencyIsoCode != 'EUR' && quote.currencyIsoCode != 'AUD' && quote.currencyIsoCode != 'CAD') 
                    || (quote.CurrencyIsoCode == 'GBP' && eachProduct.List_Price_GBP__c == null) 
                    || (quote.CurrencyIsoCode == 'CAD' && eachProduct.List_Price_CAD__c == null)
                    || (quote.CurrencyIsoCode == 'EUR' && eachProduct.List_Price_EUR__c == null)
                    || (quote.CurrencyIsoCode == 'AUD' && eachProduct.List_Price_AUD__c == null)))               
                    newRecord.record.List_Price__c = getConvertedListPrice(newRecord, newRecord.record.List_Price__c, 'USD');
                
                
                newRecord.productOption = eachProduct.Product_Option__c;
                newRecord.productDescription = eachProduct.Description;
                if(quote.Offering_Type__c == 'Business Edition' && (eachProduct.product_group__c == 'PureSuccess Direct Offer' || eachProduct.product_group__c == 'PureSuccess Indirect Offer' || eachProduct.product_group__c == 'PureSuccess Direct A-la-Carte' || eachProduct.product_group__c == 'PureSuccess Indirect A-la-Carte'))
                    newRecord.productDescription = eachProduct.Description__c;
                newRecord.includeInCMRR = eachProduct.Include_in_CMMR_Total__c;
                newRecord.showOrderAsLink = eachProduct.Show_Product_As_Link_to_Price_List__c;
                newRecord.showNetPriceAsView = eachProduct.Show_Net_Price_as_View__c;
                newRecord.hasDevcies = mapProductVsProductDevices.get(newQuoteProduct.BigMachines__Product__c) == null ? false : true ;
                newRecord.isListPriceInDiscount = eachProduct.Is_List_Price_Is_In_Percentage__c;
                newRecord.listPriceCalculateFrom = eachProduct.Calculate_List_Price_From__c;
                newRecord.addPremiumCharges = eachProduct.Add_Premium_Charges__c;
                newRecord.productType = eachProduct.Type__c;
                newRecord.autoSelected = false;
                System.debug('NKC debug quote.currencyIsoCode ['+quote.currencyIsoCode+']');
                
                newRecord.isDiscountable = eachProduct.Discountable__c;
                newRecord.pricingModel = eachProduct.Pricing_Model__c;
                newRecord.showAddSign = eachProduct.Show_Add_Sign__c;
                newRecord.isProductNameEditable = eachProduct.Is_Product_Name_Editable__c;
                
                //Anju March 2018 Seat Count
                newRecord.blnIncludeinSeatCount = eachProduct.Include_in_Agent_Seat_Count__c;
                newRecord.strApnNumber = eachProduct.APN_Number__c;
                
                quoteLineItems.add(newRecord);
                counter ++;             
                System.debug('NKC debug newRecord.listPriceCalculateFrom ['+newRecord.listPriceCalculateFrom+']');
                
                
            }           
            System.debug('NKC debug eachProduct.List_Price__c ['+newQuoteProduct.List_Price__c+']');
        }
        System.debug('NKC debug quoteLineItems ['+quoteLineItems+']');
        System.debug('NKC debug quoteLineItems.size() ['+quoteLineItems.size()+']');
        
        return quoteLineItems;
    }
    
    public static String saveQuoteLineItems(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> allQuoteLineItems, BigMachines__Quote__c quote, Opportunity opp)
    {
        
        if(quote.Initial_Subscription_Term__c == 'Other' && quote.Period__c != 'Monthly' && quote.Period__c != 'Annually' && quote.Period__c != 'One Time')
            return 'You can only select \'Other\' in Initial Subcription Term if Allotment Period is Monthly, Annually or One Time';
        
        Boolean blnHasPhasedOutProducts = false;
        
        //Anju Jan 2018 PureSuccess starts
        Integer intPureSuccessBaseCount = 0;
        String pureSuccessPackageName = '';
        Double dblPureSuccessPackageCount = 0;
        //Anju Jan 2018 PureSuccess ends
        
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts objQPWrapper : allQuoteLineItems)
        {   
            System.debug(objQPWrapper);
            if(objQPWrapper.selected != null && objQPWrapper.selected && 
               objQPWrapper.dtPhaseOut != null && objQPWrapper.dtPhaseOut <= quote.CreatedDate)
            {
                blnHasPhasedOutProducts = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, objQPWrapper.record.Product__c + ' is not available for new quotes.'));
            }
            
            //Anju Jan 2018 PureSuccess starts
            if(objQPWrapper.selected != null && objQPWrapper.selected && objQPWrapper.record.Product__c == 'PEC-D_Guide'){
                intPureSuccessBaseCount ++;
                pureSuccessPackageName = 'Guide';
            }
            if(objQPWrapper.selected != null && objQPWrapper.selected && objQPWrapper.record.Product__c == 'PEC-D_Drive'){
                intPureSuccessBaseCount ++;
                pureSuccessPackageName = 'Drive';
            }
            if(objQPWrapper.selected != null && objQPWrapper.selected && objQPWrapper.record.Product__c == 'PEC-D_Equip'){
                intPureSuccessBaseCount ++;
                pureSuccessPackageName = 'EQUIP';
            }
            if(objQPWrapper.selected != null && objQPWrapper.selected && objQPWrapper.record.Product__c == 'PEC-P_Partner'){
                intPureSuccessBaseCount ++;
                pureSuccessPackageName = 'PARTNER';
            }
            
            
            if(objQPWrapper.selected != null && objQPWrapper.selected && Label.PEC_Token_Package_Product.contains(objQPWrapper.record.Product__c))
                dblPureSuccessPackageCount = objQPWrapper.record.BigMachines__Quantity__c;
            
            //Anju Jan 2018 PureSuccess ends
        }
        
        
        if(blnHasPhasedOutProducts)
            return 'Please select other relevant products.';
        
        //Anju Jan 2018 PureSuccess starts
        if(intPureSuccessBaseCount > 1 && (quote.Keep_the_existing_estate_on_Perpetual__c || opp.Type == 'New logo' || opp.Cloud_Renewal__c) && quote.Offering_Type__c == 'Business Edition')
            return Label.PEC_PureSuccess_Error2;
        if(intPureSuccessBaseCount == 0 && (quote.Keep_the_existing_estate_on_Perpetual__c || opp.Type == 'New logo' || opp.Cloud_Renewal__c) && quote.Offering_Type__c == 'Business Edition')
            return Label.PEC_PureSuccess_Error1;
        //Anju Jan 2018 PureSuccess ends
        
        List<BigMachines__Quote_Product__c> quoteProductsToBeInserted = new List<BigMachines__Quote_Product__c>();
        Map<ID,Boolean> map_QPProductMap = new Map<ID,Boolean>();
        
        //Double maxDiscountAmontLineItems = 0;
        Double totalDiscount = 0;
        Integer noOfSelectedQuoteLines = 0;
        Double CMMR = 0,dblCMMRList = 0;
        Double totalNRC = 0;
        Double feesAppliedTotal = 0;
        quote.Monthly_Contract_Value__c = 0;
        Boolean hasUserSubscripiton = false;
        Boolean hasTimeBased = false;       
        Boolean hasRecurring = false;
        
        //Anju May Tam Sum
        Decimal decTAMSum = 0;
        
        Boolean hasClientManagement = false;
        List<ServiceOrderQuoteToolController.wrapperQuoteProducts> customerSubscriptions = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();
        List<ServiceOrderQuoteToolController.wrapperQuoteProducts> support = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();
        //Set<String> setOfferingType = new Set<String>();
        Set<String> selectedProductIds = new Set<String>();
        Set<String> nonSelectedProductIds = new Set<String>();      
        Boolean isAllInOnePerMinute = false;
        Boolean isAllInOnePerSeat = false;
        Boolean isStandardPerMinute = false;
        Boolean isStandardPerSeat = false;
        Boolean isRecurring = false;
        Boolean isClientManagement = false;
        Boolean isNonRecurring = false;
        quote.Is_IVR_And_Media_Ports__c = false;
        quote.Is_Add_Ons_And_Enabled_Inbound_Agents__c = false;
        quote.Is_Communication_Circuits_Phone_Numbers__c = false;
        quote.CPS_Total__c = 0;
        Double totalTelcoCrossConnect = 0;
        Double totalExtendedNetPrice = 0;
        quote.Editable_List_Price_Approval_Required__c = false;
        Double totalInstallationCharges = 0;
        quote.Cloud_Care_Total__c = 0;
        quote.Genesys_University_Training_Total__c = 0;
        quote.Total_Education__c = 0;
        quote.Has_Usage_Based_Fees__c = false;
        // Non Recurring Fees excluding PS
        quote.Non_Recurring_Fees__c = 0;
        //Oct 12 new fields for PEC Anju
        Double Outbound_Fees = 0;
        Double Network_Access_Fees = 0;
        Double Platform_Access_Fees = 0;
        quote.A_La_Carte_PureSuccess_Services_Amount__c = 0;
        //Anju May 14 GU Units
        quote.Total_GU_Training_Units__c = 0;
        quote.PureSuccess_Offer_Subscription_Amount__c = 0;
        //Anju March 2018 Seat Count
        quote.Max_Seat_Count__c = 0;
        Decimal decMaxSeatCount = 0;
        //Anju May 14 GU Unit
        BigMachines__Quote_Product__c objQPTrainingUnit;
        
        
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : allQuoteLineItems)
        {           
            eachRecord.record.id = null;
            
            if(eachRecord.record.Extended_Price_Per_Month__c == null)
                eachRecord.record.Extended_Price_Per_Month__c = 0;
            
            
            if( eachRecord.selected != null && eachRecord.selected )
            {  
                //Nov 20 Anju new check for discoutn size
                
                if(Label.PureEngage_Products_with_45_discount.contains(String.valueof(eachRecord.record.BigMachines__Product__c).left(15)) && eachRecord.record.Discount__c > 45)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Discount cannot be more than 45%';
                    return Label.PureEngage_Products_with_45_Error;
                }
                //Nov 20 Anju new check for discoutn size
                //Feb 22 Anju new check for discoutn size
                
                if(Label.PureEngage_Products_with_40_discount.contains(String.valueof(eachRecord.record.BigMachines__Product__c).left(15)) && eachRecord.record.Discount__c > 40)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Discount cannot be more than 40%';
                    return Label.PureEngage_Products_with_40_Error;
                }
                //Feb 22 Anju new check for discoutn size
                if(eachRecord.record.Product_Group__c == 'ASR and TTS' && eachRecord.record.Discount__c > 30)
                {
                    System.debug('<<< inside error');
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Discount cannot be more than 30%';
                    return 'The maximum discount allowed for ASR/TTS products is 30%';
                }
                
                if(eachRecord.record.Product__c == 'Cloud Contact Center Voice Recording Storage(/ret month)' && eachRecord.record.Discount__c > 50)
                {
                    System.debug('<<< inside error');
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Discount cannot be more than 50%';
                    return 'The maximum discount allowed for Cloud Contact Center Voice Recording Storage(/ret month) is 50%';
                }
                //April 2018
                if(eachRecord.record.Product__c == 'Cloud Contact Center - Statistics API' && eachRecord.record.Discount__c > 40)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Discount cannot be more than 40%';
                    return 'The maximum discount allowed for Cloud Contact Center - Statistics API is 40%';
                }
                if(eachRecord.record.Product__c == 'Cloud Contact Center - Agent API' && eachRecord.record.Discount__c > 50)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Discount cannot be more than 40%';
                    return 'The maximum discount allowed for Cloud Contact Center - Agent API is 50%';
                }
                if(eachRecord.strApnNumber == '3GP107390ABAA' && eachRecord.record.BigMachines__Quantity__c < 50000)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Quantity selected for Outbound Voice with CX Contact Interaction - PEC should be equal or greater than 50K';
                    return 'Quantity selected for Outbound Voice with CX Contact Interaction - PEC should be equal or greater than 50K';
                }
                if(eachRecord.strApnNumber == '3GP109185ABAA' && eachRecord.record.BigMachines__Quantity__c < 100000)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Quantity selected for Genesys Predictive Routing for Cust. Svc. - PEC should be equal or greater than 100K.';
                    return 'Quantity selected for Genesys Predictive Routing for Cust. Svc. - PEC should be equal or greater than 100K.';
                }
                
                if(eachRecord.strApnNumber == '3GP109186ABAA' && eachRecord.record.BigMachines__Quantity__c < 50000)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Quantity selected for Genesys Predictive Routing for Sales - PEC should be equal or greater than 50K';
                    return 'Quantity selected for Genesys Predictive Routing for Sales - PEC should be equal or greater than 50K';
                }
         if(eachRecord.strApnNumber == '3GP110507ABAA' && eachRecord.record.BigMachines__Quantity__c < 100000)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Quantity selected for Genesys Predictive Routing for Cust. Svc. – HYB  should be equal or greater than 100K.';
                    return 'Quantity selected for Genesys Predictive Routing for Cust. Svc. – HYB  should be equal or greater than 100K.';
                }
                
                if(eachRecord.strApnNumber == '3GP110508ABAA' && eachRecord.record.BigMachines__Quantity__c < 50000)
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Quantity selected for Genesys Predictive Routing for Sales – HYB should be equal or greater than 50K';
                    return 'Quantity selected for Genesys Predictive Routing for Sales – HYB should be equal or greater than 50K';
                }
                
                if(eachRecord.strApnNumber == '3GP109229ABAA' && (eachRecord.record.Device__c == null || eachRecord.record.Device__c == '--Select--'))
                {
                    eachRecord.styleClass = 'errorRow';
                    eachRecord.errorMsg = 'Please select a device for Gplus WFM Adapter - PEC.';
                    return 'Please select a device for Gplus WFM Adapter - PEC.';
                }
                
                if(eachRecord.isListPriceEditable)
                    quote.Editable_List_Price_Approval_Required__c = true;
                
                selectedProductIds.add(eachRecord.record.BigMachines__Product__c);          
                
                if(eachRecord.record.BigMachines__Quantity__c == null)
                    eachRecord.record.BigMachines__Quantity__c = 1;
                
                /*
if(!eachRecord.autoSelected && eachRecord.record.BigMachines__Quantity__c == 0 && eachRecord.productOption != 'Yes/No'){                                                        
return Label.SOQT_Quantity_Validation_Msg;
}
*/
                eachRecord.record.BigMachines__Quote__c = quote.id;
                quoteProductsToBeInserted.add(eachRecord.record);
                map_QPProductMap.put(eachRecord.record.BigMachines__Product__c,eachRecord.includeInCMRR);
                /*if(eachRecord.record.Discount__c != null && eachRecord.record.Discount__c > maxDiscountAmontLineItems)
maxDiscountAmontLineItems = eachRecord.record.Discount__c;*/    
                
                if(eachRecord.record.Installation_Fees__c != null && feesAppliedTotal != null)
                    feesAppliedTotal += eachRecord.record.Installation_Fees__c;
                
                eachRecord.record.Total_Discount__c = eachRecord.record.Discount__c;
                noOfSelectedQuoteLines ++;
                
                if(eachRecord.record.Product_Group__c == 'User Subscription')
                    hasUserSubscripiton = true;
                
                if(eachRecord.record.Product_Group__c == 'Time Based')
                    hasTimeBased = true;
                
                if(eachRecord.record.Installation_Fees__c == null)
                    eachRecord.record.Installation_Fees__c = 0;
                
                if(eachRecord.record.Fees_Applied__c != null && eachRecord.includeInCMRR != null && eachRecord.includeInCMRR)
                {
                    CMMR += (eachRecord.record.Fees_Applied__c - eachRecord.record.Installation_Fees__c);
                    dblCMMRList += eachRecord.record.List_Price__c * eachRecord.record.BigMachines__Quantity__c;
                }      
                System.debug('NKC debug CMMR ['+CMMR+']');
                
                if(eachRecord.record.Fees_Applied__c != null)
                    totalExtendedNetPrice += (eachRecord.record.Fees_Applied__c - eachRecord.record.Installation_Fees__c);
                
                if(eachRecord.record.Product_Group__c == 'Customer Subscription')
                    customerSubscriptions.add(eachRecord);
                
                else if(eachRecord.record.Product_Group__c == 'Support')
                    support.add(eachRecord);
                
                if(eachRecord.record.Extended_Price_Per_Month__c != null)
                    quote.Monthly_Contract_Value__c += eachRecord.record.Extended_Price_Per_Month__c;   
                //if(eachRecord.productType == 'Cloud' || eachRecord.productType == 'Product')
                //setOfferingType.add(eachRecord.productType);
                
                if(eachRecord.productDescription == Label.Per_Seat_All_In_One)
                    isAllInOnePerSeat = true;
                
                if(eachRecord.productDescription == Label.Per_Seat_Standard)
                    isStandardPerSeat = true;
                
                if(eachRecord.productDescription == Label.Per_Minute_All_In_One)
                    isAllInOnePerMinute = true;
                
                if(eachRecord.productDescription == Label.Per_Minute_Standard)
                    isStandardPerMinute = true;
                
                if(quote.Offering_Type__c == 'Outbound Engagement')
                {
                    if(!isRecurring && (eachRecord.record.Product_Group__c == 'Short/Long Code Recurring Fees' || 
                                        eachRecord.record.Product_Group__c == 'SW/Platform Licensing' || 
                                        eachRecord.record.Product_Group__c == 'Per Seat Pricing (Base Options)' ||
                                        eachRecord.record.Product_Group__c == 'Support'))
                    {   
                        isRecurring = true;
                    }
                    if(!isNonRecurring && (eachRecord.record.Product_Group__c == 'Short/Long Code Non Recurring Fees' || 
                                           eachRecord.record.Product_Group__c == 'SW/Platform Implementation' || 
                                           eachRecord.record.Product_Group__c == 'Transaction Based' ||
                                           eachRecord.record.Product_Group__c == 'Professional Services Implementation'))
                    {
                        isNonRecurring = true;
                    }
                    if(!quote.Has_Usage_Based_Fees__c && eachRecord.record.Product_Group__c == 'Per Message/Per Minute')
                    {
                        quote.Has_Usage_Based_Fees__c = true;
                    }
                }
                else
                {
                    if(!isRecurring && (eachRecord.record.Product_Group__c == 'User Subscription' || 
                                        eachRecord.record.Product_Group__c == 'Port Subscription' || 
                                        eachRecord.record.Product_Group__c == 'Customer Subscription' || 
                                        eachRecord.record.Product_Group__c == 'Rented Equipment/Communication Fees/Short Codes' || 
                                        eachRecord.record.Product_Group__c == 'Support' ||
                                        eachRecord.record.Product_Group__c == 'IVR and Media Port Options' ||
                                        eachRecord.record.Product_Group__c == 'IVR / Media Port Add Ons' ||
                                        eachRecord.record.Product_Group__c == 'Per Seat Pricing (Base Options)' ||
                                        eachRecord.record.Product_Group__c == 'Digital Channels Options' ||
                                        eachRecord.record.Product_Group__c == 'Quality Management' ||
                                        eachRecord.record.Product_Group__c == 'Workforce Optimization' ||
                                        eachRecord.record.Product_Group__c == 'Other Services' ||
                                        eachRecord.record.Product_Group__c == 'End User End Points' ||
                                        eachRecord.record.Product_Group__c == 'Cloud Contact Center Adapters' ||
                                        eachRecord.record.Product_Group__c == 'Inbound to IVR' ||
                                        eachRecord.record.Product_Group__c == 'Bridging Leg / Transfer to PSTN or PLMN' ||
                                        eachRecord.record.Product_Group__c == 'Outbound to PSTN or PLMN' ||
                                        eachRecord.record.Product_Group__c == 'MPLS' ||
                                        eachRecord.record.Product_Group__c == 'ASR and TTS' ||
                                        eachRecord.record.Product_Group__c == 'BluIP' ||
                                        eachRecord.record.Product_Group__c == 'Access Fees' ||
                                        eachRecord.record.Product_Group__c == 'Short/Long Code Recurring Fees' || 
                                        eachRecord.record.Product_Group__c == 'SW/Platform Licensing'))
                    {   
                        isRecurring = true;
                    }
                    if( !isNonRecurring && (eachRecord.record.Product_Group__c == 'Time Based' || 
                                            eachRecord.record.Product_Group__c == 'Transaction Based' || 
                                            eachRecord.record.Product_Group__c == 'Tier Based' ||
                                            eachRecord.record.Product_Group__c == 'Configuration Professional Services' ||
                                            eachRecord.record.Product_Group__c == 'Genesys Care' ||
                                            eachRecord.record.Product_Group__c == 'Telco Cross Connect' ||
                                            eachRecord.record.Product_Group__c == 'Professional Services Rapid Deployment ImplementationPackages' ||
                                            eachRecord.record.Product_Group__c == 'Professional Services Implementation' ||
                                            eachRecord.record.Product_Group__c == 'Genesys Cloud Care' ||
                                            eachRecord.record.Product_Group__c == 'Genesys University Training' ||
                                            eachRecord.record.Product_Group__c == 'Installation' ||
                                            eachRecord.record.Product_Group__c == 'Implementation Charges' ||
                                            eachRecord.record.Product_Group__c == 'Short/Long Code Non Recurring Fees' ||
                                            eachRecord.record.Product_Group__c == 'SW/Platform Implementation'))
                    {
                        isNonRecurring = true;
                    }
                    
                    if(!quote.Has_Usage_Based_Fees__c && eachRecord.record.Product_Group__c == 'Per Message/Per Minute')
                    {
                        quote.Has_Usage_Based_Fees__c = true;
                    }
                }
                
                if(eachRecord.record.Product_Group__c == 'Client Management')
                    isClientManagement = true;
                
                if(eachRecord.record.Product_Group__c == 'VR and Media Port Options' ||
                   eachRecord.record.Product_Group__c == 'IVR / Media Port Add Ons')
                    quote.Is_IVR_And_Media_Ports__c = true;
                
                if(!quote.Is_Add_Ons_And_Enabled_Inbound_Agents__c && (eachRecord.record.Product_Group__c == 'Quality Management' ||
                                                                       eachRecord.record.Product_Group__c == 'Workforce Optimization' ||
                                                                       eachRecord.record.Product_Group__c == 'Other Services' ||
                                                                       eachRecord.record.Product_Group__c == 'End User End Points'))
                    quote.Is_Add_Ons_And_Enabled_Inbound_Agents__c = true;
                
                if(!quote.Is_Add_Ons_And_Enabled_Inbound_Agents__c && (eachRecord.record.Product_Group__c == 'Inbound to IVR' ||
                                                                       eachRecord.record.Product_Group__c == 'Bridging Leg / Transfer to PSTN or PLMN' ||
                                                                       eachRecord.record.Product_Group__c == 'Outbound to PSTN or PLMN' ||
                                                                       eachRecord.record.Product_Group__c == 'MPLS'))
                    quote.Is_Add_Ons_And_Enabled_Inbound_Agents__c = true;
                
                //Anju March 2018 Seat Count
                if(eachRecord.blnIncludeinSeatCount != null && eachRecord.blnIncludeinSeatCount && eachRecord.record.BigMachines__Quantity__c != null)
                    decMaxSeatCount += eachRecord.record.BigMachines__Quantity__c;
                //Anju May 14 GU Units
                
                if(eachRecord.ProductType == 'Training Unit'){
                    objQPTrainingUnit = eachRecord.record;
                }     
                
                //Anju May TAM
                //system.debug(eachRecord.strApnNumber);
                if(eachRecord.strApnNumber != NULL && Label.PEC_TAM_Products.contains(eachRecord.strApnNumber))
                    decTAMSum += eachRecord.record.Extended_Price_Per_Month__c;
                system.debug(decTAMSum);
            }
            else
                nonSelectedProductIds.add(eachRecord.record.BigMachines__Product__c);
            
            if(quote.Offering_Type__c == PRIMIER_EDITION_CLOUD && hasUserSubscripiton && hasTimeBased)
                return Label.SOQT_USAndTB_Validaation_Msg;
            
            if(eachRecord.index != -1)
                continue;
            
            if(!(eachRecord.record.Product_Group__c == 'User Subscription' || 
                 eachRecord.record.Product_Group__c == 'Port Subscription' || 
                 eachRecord.record.Product_Group__c == 'Customer Subscription' || 
                 eachRecord.record.Product_Group__c == 'Rented Equipment/Communication Fees/Short Codes' || 
                 eachRecord.record.Product_Group__c == 'Support'))
                totalNRC += eachRecord.record.Extended_Price_Per_Month__c;
            
            if(eachRecord.index == -1)
            {
                if(quote.Offering_Type__c == 'Outbound Engagement')
                {
                    if(eachRecord.record.Product_Group__c == 'Short/Long Code Non Recurring Fees' || 
                       eachRecord.record.Product_Group__c == 'SW/Platform Implementation' || 
                       eachRecord.record.Product_Group__c == 'Transaction Based')
                        quote.Non_Recurring_Fees__c += eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Professional Services Implementation')
                        quote.CPS_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                }
                else
                {
                    if(eachRecord.record.Product_Group__c == 'User Subscription')
                        quote.User_Subscription_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Port Subscription')
                        quote.Port_Subscription_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Customer Subscription')
                        quote.Customer_Subscription_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Rented Equipment/Communications Circuits/Short Codes')
                        quote.Rented_Equipment_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Time Based')
                        quote.Time_Based_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Transaction Based')
                        quote.Transaction_Based_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Tier Based')
                        quote.Tier_Based_Total__c = eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Client Management')
                        quote.Client_Management_Total__c = eachRecord.record.Extended_Price_Per_Month__c;   
                    
                    else if(eachRecord.record.Product_Group__c == 'Configuration Professional Services'
                            || eachRecord.record.Product_Group__c == 'Professional Services Rapid Deployment ImplementationPackages'
                            || eachRecord.record.Product_Group__c == 'Professional Services Implementation'){
                                quote.CPS_Total__c += eachRecord.record.Extended_Price_Per_Month__c;
                                system.debug('CPS_Total__c'+quote.CPS_Total__c);}
                    else if(eachRecord.record.Product_Group__c == 'Telco Cross Connect')
                    {
                        totalTelcoCrossConnect += eachRecord.record.Extended_Price_Per_Month__c;
                        
                    }
                    
                    else if(eachRecord.record.Product_Group__c == 'Installation')
                        totalInstallationCharges += eachRecord.record.Extended_Price_Per_Month__c;   
                    
                    else if(eachRecord.record.Product_Group__c == 'Genesys Cloud Care')
                        quote.Cloud_Care_Total__c += eachRecord.record.Extended_Price_Per_Month__c;
                    
                    else if(eachRecord.record.Product_Group__c == 'Genesys University Training'){
                        quote.Genesys_University_Training_Total__c += eachRecord.record.Extended_Price_Per_Month__c;
                        quote.Total_Education__c += eachRecord.record.Extended_Price_Per_Month__c;
                    }    
                    
                    
                    // [SM 2/16/2017] Adding Access Fees products to Non Recurring Fee even though it is recurring but should not be counted in CMRR or ACV.
                    else if(eachRecord.record.Product_Group__c == 'Implementation Charges' || eachRecord.record.Product_Group__c == 'Access Fees' ||
                            eachRecord.record.Product_Group__c == 'Short/Long Code Non Recurring Fees' || eachRecord.record.Product_Group__c == 'SW/Platform Implementation'
                            || eachRecord.record.Product_Group__c == 'Puresuccess Direct A-la-Carte' || eachRecord.record.Product_Group__c == 'Puresuccess Indirect A-la-Carte' || eachRecord.record.Product_Group__c == 'PureSuccess Direct Offer' || eachRecord.record.Product_Group__c == 'PureSuccess Indirect Offer'){
                                quote.Non_Recurring_Fees__c += eachRecord.record.Extended_Price_Per_Month__c;
                                system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);
                            }
                    //Anju Jan 2018 PureSuccess starts
                    //PureSuccess Totals
                    if(eachRecord.record.Product_Group__c == 'Puresuccess Direct A-la-Carte' || eachRecord.record.Product_Group__c == 'Puresuccess Indirect A-la-Carte')
                        quote.A_La_Carte_PureSuccess_Services_Amount__c += eachRecord.record.Extended_Price_Per_Month__c;
                    if(eachRecord.record.Product_Group__c == 'PureSuccess Direct Offer' || eachRecord.record.Product_Group__c == 'PureSuccess Indirect Offer')
                        quote.PureSuccess_Offer_Subscription_Amount__c += eachRecord.record.Extended_Price_Per_Month__c;
                    
                    //Anju May 14 GU Units
                    quote.Total_GU_Training_Units__c = 80;
                    
                    if(objQPTrainingUnit != null && objQPTrainingUnit.BigMachines__Quantity__c != null){
                        // && objQPTrainingUnit.Bundle__r.Token_Value__c != null
                        system.debug('Inside GU Ints');
                        quote.Total_GU_Training_Units__c += objQPTrainingUnit.BigMachines__Quantity__c * 80;
                    }
                    //Anju Jan 2018 PureSuccess ends
                    
                    //Oct 12 new pec fields anju
                    system.debug('661');
                    if(eachRecord.record.Product_Group__c == 'Telco Cross Connect')
                        Network_Access_Fees += eachRecord.record.Extended_Price_Per_Month__c;
                    if(eachRecord.record.Product_Group__c == 'Access Fees')
                        Platform_Access_Fees += eachRecord.record.Extended_Price_Per_Month__c;
                    if(eachRecord.record.Product_Group__c == 'Short/Long Code Non Recurring Fees' || eachRecord.record.Product_Group__c == 'SW/Platform Implementation')
                        Outbound_Fees += eachRecord.record.Extended_Price_Per_Month__c;
                    
                    
                }
            }
        }
        
        
        
        // 2/18/2016 : Care has to be selected for Self Service and Premier Quotes
        if(support.isEmpty() && (quote.Offering_Type__c == 'Self Service' || quote.Offering_Type__c == 'Premier Edition'))
            return 'Care has to be selected for a ' + quote.Offering_Type__c + ' quote.';
        
        String returnMsg = validateSelectedProducts(allQuoteLineItems, selectedProductIds, nonSelectedProductIds);
        if(returnMsg != null){
            return returnMsg;
        }
        quote.Is_All_In_One_Per_Seat_Selected__c = isAllInOnePerSeat;
        quote.Is_Standard_Per_Seat_Selected__c = isStandardPerSeat;
        quote.Is_All_In_One_Per_Minute_Selected__c = isAllInOnePerMinute;
        quote.Is_Standard_Per_Minute_Selected__c = isStandardPerMinute;
        quote.Is_Recurring__c = isRecurring;
        quote.Is_Client_Management__c = isClientManagement;
        quote.Is_Non_Recurring__c = isNonRecurring;
        
        if(quote.Offering_Type__c == PROACTIVE_COMMUNICATIONS || quote.Offering_Type__c == MOBILE_MARKETING)
        {
            if(quote.Minimum_Fees_Period__c != null)
                CMMR = quote.Minimum_Fees_Period__c;
            else
                CMMR = 0;
        }
        System.debug('NKC debug CMMR ['+CMMR+']');
        customerSubscriptions = doCalculationForSupportAndCS(customerSubscriptions, CMMR, true, 1);
        
        support = doCalculationForSupportAndCS(support, CMMR, false, getIPeriodForSupport(quote.Period__c));
        quote.Support_Total__c = 0;
        if(!support.isEmpty())  
        {           
            quote.Support_Total__c = support[0].record.Extended_Price_Per_Month__c;         
            if(support[0].record.Extended_Price_Per_Month__c != null)
            {
                //CMMR += support[0].record.Extended_Price_Per_Month__c * 12;
                quote.Support_Total__c = support[0].record.Extended_Price_Per_Month__c;
                if(quote.Monthly_Contract_Value__c != null)
                    quote.Monthly_Contract_Value__c += support[0].record.Extended_Price_Per_Month__c;
            }
        }
        System.debug('NKC debug CMMR ['+CMMR+']');
        quote.Customer_Subscription_Total__c = 0;
        if(!customerSubscriptions.isEmpty())
        {
            System.debug('NKC debug customerSubscriptions[0].record.Extended_Price_Per_Month__c ['+customerSubscriptions[0].record.Extended_Price_Per_Month__c+']');
            if(customerSubscriptions[0].record.Extended_Price_Per_Month__c != null)
                //CMMR += customerSubscriptions[0].record.Extended_Price_Per_Month__c;
                quote.Customer_Subscription_Total__c = customerSubscriptions[0].record.Extended_Price_Per_Month__c;
            
            if(quote.Monthly_Contract_Value__c != null)
                quote.Monthly_Contract_Value__c += customerSubscriptions[0].record.Extended_Price_Per_Month__c;         
        }
        System.debug('NKC debug CMMR ['+CMMR+']');
        
        Integer term = 1;
        // Reads the number of years of subscription term 
        if(String.isNotBlank(quote.Initial_Subscription_Term__c) && quote.Initial_Subscription_Term__c.containsIgnoreCase(' Year'))
            term = Integer.ValueOf(quote.Initial_Subscription_Term__c.substringBefore(' Year'));        
        
        quote.Cloud_Term_Commitment__c = term;
        if(quote.CPS_Total__c == null)
            quote.CPS_Total__c = 0;
        if(quote.Support_Total__c == null)
            quote.Support_Total__c = 0;
        if(quote.Cloud_Total__c == null)
            quote.Cloud_Total__c = 0;
        
        Boolean isProactiveOrMobileMarketing = false;       
        if(quote.Offering_Type__c == PROACTIVE_COMMUNICATIONS || quote.Offering_Type__c == MOBILE_MARKETING)
            isProactiveOrMobileMarketing = true;        
        if(!isProactiveOrMobileMarketing)
            quote.Minimum_Fees_Period__c = CMMR;        
        if(quote.Minimum_Fees_Period__c == null)
            quote.Minimum_Fees_Period__c = 0;
        
        //Oct 12 Update ACV for PEC Business edition - Anju - Remove for Business edition
        Double Cloud_Care_TotalTemp = quote.Cloud_Care_Total__c;
        if(quote.Offering_Type__c == BUSINESS_EDITION_CLOUD)
            quote.Cloud_Care_Total__c = 0;
        
        //Anju TAM
        quote.TAM_amount__c = decTAMSum;
        Decimal decACVMonths;
        if(isProactiveOrMobileMarketing)
        {
            quote.Annual_Contract_Value__c = quote.Minimum_Fees_Period__c * 12;     
            quote.Cloud_Total__c = (quote.Annual_Contract_Value__c * term ) + quote.CPS_Total__c; 
            system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
        }   
        else
        {
            if(quote.Initial_Subscription_Term__c == 'Other')
            {
                if(quote.No_Of_Months__c == null || quote.No_Of_Months__c == 0)
                    return 'No Of Months can not be blank or zero.';
                Double noOfMonths = quote.No_Of_Months__c;
                // ACV should be the TCV if number of months is less than 12 otherwise ACV should represent 12 months i.e. annual value
                decACVMonths = (noOfMonths > 12) ? 12 : noOfMonths;
                if(quote.Period__c == 'Annually' || quote.Period__c == 'One Time')
                {
                    //Annual Contract Value 
                    quote.Annual_Contract_Value__c = (quote.Customer_Subscription_Total__c * decACVMonths) + (quote.Support_Total__c * decACVMonths) + CMMR + quote.Cloud_Care_Total__c;
                    
                    //Commited Monthly Recurring Revenue
                    quote.CMRR__c = (quote.Annual_Contract_Value__c/decACVMonths);
                    
                    //Minimum Fee Period
                    quote.Minimum_Fees_Period__c = quote.Annual_Contract_Value__c ;
                    
                    //Total Contract Value
                    quote.Cloud_Total__c = (quote.CMRR__c * noOfMonths) +  quote.CPS_Total__c + quote.Non_Recurring_Fees__c;  
                    system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);   
                    system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);       
                }
                else if(quote.Period__c == 'Monthly')
                {
                    CMMR += quote.Support_Total__c + quote.Customer_Subscription_Total__c;
                    
                    //Commited Monthly Recurring Revenue    
                    quote.CMRR__c = CMMR;
                    
                    //Minimum Fee Period
                    quote.Minimum_Fees_Period__c = CMMR; 
                    
                    //Annual Contract Value         
                    quote.Annual_Contract_Value__c = CMMR * decACVMonths + quote.Cloud_Care_Total__c; 
                    
                    //Total Contract Value
                    quote.Cloud_Total__c = ((quote.Annual_Contract_Value__c/decACVMonths) * noOfMonths) + quote.CPS_Total__c + quote.Non_Recurring_Fees__c;
                    system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);
                    system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
                }
            }
            else if(quote.Period__c == 'Quarterly')
            {
                //Annual Contract Value 
                quote.Annual_Contract_Value__c = (quote.Customer_Subscription_Total__c * 12) + (quote.Support_Total__c * 12) + (CMMR * 4) + quote.Cloud_Care_Total__c; 
                
                //Commited Monthly Recurring Revenue
                quote.CMRR__c = (quote.Annual_Contract_Value__c / 12);
                
                //Minimum Fee Period
                quote.Minimum_Fees_Period__c = (quote.Annual_Contract_Value__c / 4);
                
                //Total Contract Value
                quote.Cloud_Total__c = (quote.Annual_Contract_Value__c * term) +  quote.CPS_Total__c + quote.Non_Recurring_Fees__c;
                system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
                system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);
            }
            else if(quote.Period__c == 'Semi-Annually')
            {
                //Annual Contract Value 
                quote.Annual_Contract_Value__c = (quote.Customer_Subscription_Total__c * 12) + (quote.Support_Total__c * 12) + (CMMR * 2) + quote.Cloud_Care_Total__c; 
                //Commited Monthly Recurring Revenue
                quote.CMRR__c = (quote.Annual_Contract_Value__c / 12);
                //Minimum Fee Period
                quote.Minimum_Fees_Period__c = (quote.Annual_Contract_Value__c / 2);
                //Total Contract Value
                quote.Cloud_Total__c = (quote.Annual_Contract_Value__c * term) +  quote.CPS_Total__c + quote.Non_Recurring_Fees__c;
                system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
                system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);
            }           
            else if(quote.Period__c == 'Annually' || quote.Period__c == 'One Time')
            {
                //Annual Contract Value 
                quote.Annual_Contract_Value__c = (quote.Customer_Subscription_Total__c * 12) + (quote.Support_Total__c * 12) + CMMR + quote.Cloud_Care_Total__c; 
                //Commited Monthly Recurring Revenue
                quote.CMRR__c = (quote.Annual_Contract_Value__c / 12);
                //Minimum Fee Period
                quote.Minimum_Fees_Period__c = quote.Annual_Contract_Value__c ;
                //Total Contract Value
                quote.Cloud_Total__c = (quote.Annual_Contract_Value__c * term) +  quote.CPS_Total__c + quote.Non_Recurring_Fees__c; 
                system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);     
                system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);     
            }
            else
            {
                CMMR += quote.Support_Total__c + quote.Customer_Subscription_Total__c;
                //Commited Monthly Recurring Revenue    
                quote.CMRR__c = CMMR;
                //Minimum Fee Period
                quote.Minimum_Fees_Period__c = CMMR;    
                //Annual Contract Value 
                system.debug('Anju test1'+quote.Support_Total__c+':'+quote.Customer_Subscription_Total__c); 
                system.debug('CMRR'+  CMMR +':'+quote.Cloud_Care_Total__c);     
                quote.Annual_Contract_Value__c = CMMR * 12 + quote.Cloud_Care_Total__c;   
                system.debug('quote.Cloud_Care_Total__c'+ quote.Cloud_Care_Total__c);  
                //Total Contract Value
                quote.Cloud_Total__c = (quote.Annual_Contract_Value__c * term ) + quote.CPS_Total__c + quote.Non_Recurring_Fees__c;
                system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
                system.debug('quote.Non_Recurring_Fees__c'+quote.Non_Recurring_Fees__c);
            }       
            //Total Contract Value
            quote.Cloud_Total__c += totalTelcoCrossConnect + totalInstallationCharges + quote.Genesys_University_Training_Total__c;
            system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
            
            //Oct 12 update tcv with annual care for business - Anju
            if(quote.Offering_Type__c == BUSINESS_EDITION_CLOUD)
            {
                quote.Cloud_Total__c += Cloud_Care_TotalTemp ;
                quote.Cloud_Care_Total__c = Cloud_Care_TotalTemp;
                system.debug('Cloud_Total__c'+ quote.Cloud_Total__c);
            }
        }
        
        if(quote.Annual_Contract_Value__c == null)
            quote.Annual_Contract_Value__c = 0;     
        
        //quote.Discount__c = maxDiscountAmontLineItems;
        quote.Discount__c = dblCMMRList != 0 ? ((dblCMMRList - CMMR)/dblCMMRList) * 100 : 0;
        quote.Total_Discount_Genesys_Products_Only__c  = quote.Discount__c;
        quote.Total_Contract_Value__c = quote.Cloud_Total__c;
        quote.Total_Discount_Genesys_and_Third_Party__c = totalDiscount;
        
        if(noOfSelectedQuoteLines > 0)
            quote.Additional_Discount_Cloud__c = totalDiscount / noOfSelectedQuoteLines;
        
        quote.Setup_Provisioning_Charges__c = feesAppliedTotal + totalInstallationCharges;     
        quote.Monthly_Commitment__c = quote.Minimum_Fees_Period__c;
        quote.BigMachines__Total__c = quote.Annual_Contract_Value__c;
        Double ACVBeforePS = quote.Annual_Contract_Value__c;
        //quote.Annual_Contract_Value__c += quote.CPS_Total__c;
        //Rounding off
        if(quote.CMRR__c == null)
            quote.CMRR__c = 0;
        
        quote.CMRR__c = quote.CMRR__c.setScale(0, System.Roundingmode.HALF_UP);
        quote.Minimum_Fees_Period__c = quote.Minimum_Fees_Period__c.setScale(0, System.Roundingmode.HALF_UP);
        quote.Annual_Contract_Value__c = quote.Annual_Contract_Value__c.setScale(0, System.Roundingmode.HALF_UP);
        quote.Total_Contract_Value__c = quote.Total_Contract_Value__c.setScale(0, System.Roundingmode.HALF_UP);
        quote.Cloud_Total__c = quote.Cloud_Total__c.setScale(0, System.Roundingmode.HALF_UP);
        
        if(quote.Special_Offer_Terms__c != null && quote.Special_Offer_Terms__c.trim() != '')
            quote.Include_Special_Offer_in_Output__c = true;
        else
            quote.Include_Special_Offer_in_Output__c = false;
        
        //PureSucess Token calculation Anju Jan 2018
        //Anju Jan 2018 PureSuccess starts
        //Added By Ranjith on Apr 3rd, 2019 -- Starts - To convert ACV to USD
        Decimal decACVInUSD = quote.Annual_Contract_Value__c;
        if(!Test.isRunningTest() && quote.Offering_Type__c == 'PureEngage Cloud') {
            decACVInUSD = DDSCloud.converttoUSD(quote.Offering_Type__c, quote.New_Price_Book__c, quote.CurrencyIsoCode, quote.Annual_Contract_Value__c);
        }
        //Added By Ranjith on Apr 3rd, 2019 -- Ends- To convert ACV to USD
        
        if(pureSuccessPackageName != null && pureSuccessPackageName != '')
        {
            pureSuccessPackageName = pureSuccessPackageName.touppercase();
            quote.Token_Value__c = QuoteCloudUtil.calculateTokenValue(decACVInUSD, quote.Offering_Type__c, pureSuccessPackageName);
            quote.PureSuccess__c = pureSuccessPackageName;
            if(dblPureSuccessPackageCount > 0)
                quote.Token_Value__c += 10 * dblPureSuccessPackageCount;
            
            system.debug('token'+quote.Token_Value__c);
        }
        //Anju Jan 2018 PureSuccess ends
        
        Double dblNoofMonths = quote.No_Of_Months__c == null ? 0 : quote.No_Of_Months__c;
        decACVMonths = (dblNoofMonths > 12 || dblNoofMonths == 0) ? 12 : dblNoofMonths ;
        if(quote.Initial_Subscription_Term__c != 'Other') decACVMonths = 12;
        
        //Anju August 2018 Calculating tokens for individual lines
        Decimal decACVTokenValue = QuoteCloudUtil.calculateTokenValue(decACVInUSD, 'Only For ACV', 'NA');
        Integer intTotalTokens = 0;
        BigMachines__Quote_Product__c objLargestQP;
        for(BigMachines__Quote_Product__c objQP : quoteProductsToBeInserted)
        {        
            if(map_QPProductMap.get(objQP.BigMachines__Product__c) && objQP.Bundle__c == null && objQP.Product_Group__c != 'PureSuccess Direct Offer' && objQP.Product_Group__c != 'PureSuccess Indirect Offer'){
                if(objQP.Extended_Price_Per_Month__c != null && decACVTokenValue > 0 && quote.Annual_Contract_Value__c != null){
                    Decimal decLineWeightage = (decACVMonths * objQP.Extended_Price_Per_Month__c * 100) / quote.Annual_Contract_Value__c;
                    decLineWeightage = Math.floor(decLineWeightage);
                    
                    objQP.Tokens__c = decACVTokenValue * decLineWeightage / 100;
                    if(intTotalTokens == 0)
                        objLargestQP = objQP;
                    else if(objQP.Extended_Price_Per_Month__c  > objLargestQP.Extended_Price_Per_Month__c)
                        objLargestQP = objQP;
                    intTotalTokens += Integer.valueof(Math.round(objQP.Tokens__c));
                    
                }
            }
            else if(objQP.Product__c == 'PEC-D_Guide' || objQP.Product__c == 'PEC-D_Drive' || objQP.Product__c == 'PEC-D_Equip' || objQP.Product__c == 'PEC-P_Partne'){
                      
                      Decimal decPSTokenValue = QuoteCloudUtil.calculateTokenValue(decACVInUSD, quote.Offering_Type__c, pureSuccessPackageName);
                      if(decPSTokenValue > decACVTokenValue)
                          objQP.Tokens__c = decPSTokenValue - decACVTokenValue; 
                      else
                          objQP.Tokens__c = 0;
                      system.debug('Inside PS part'+decPSTokenValue);
                      system.debug('Inside PS part'+decACVTokenValue);
            }
            else if(Label.PEC_Token_Package_Product.contains(objQP.Product__c) && objQP.BigMachines__Quantity__c != null){                        
                      system.debug('Inside token part' + objQP.BigMachines__Quantity__c);
                      objQP.Tokens__c = objQP.BigMachines__Quantity__c * 10;    
            } 
        }
        if(decACVTokenValue - intTotalTokens != 0)
        {
            system.debug(decACVTokenValue - intTotalTokens);
            for(BigMachines__Quote_Product__c objQP : quoteProductsToBeInserted)
            { 
                if(objQP == objLargestQP)
                    objQP.Tokens__c += (decACVTokenValue - intTotalTokens);
            }
        }
        
        //Anju March 2018 Seat Count
        if(quote.Pricing_Model__c == 'Concurrent')
            quote.Max_Seat_Count__c = decMaxSeatCount * 2;
        else
            quote.Max_Seat_Count__c = decMaxSeatCount;
        
        Savepoint objSP = Database.setSavepoint(); 
        try{
            if(quote.id == null)
            {
                quote = ServiceOrderQuoteHelper.saveQuote(quote, opp);
                for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsToBeInserted)
                    eachQuoteProduct.BigMachines__Quote__c = quote.id;
            }
            else
                update quote;
                Map<Id, BigMachines__Quote_Product__c> map_QPIdObject = new Map<Id, BigMachines__Quote_Product__c>();
                List<BigMachines__Quote_Product__c> listQuoteProdToDeleted = new List<BigMachines__Quote_Product__c>();
                for(BigMachines__Quote_Product__c bigQP : [SELECT id, BigMachines__Product__c, Bundle__c, Offer__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quote.id]){
                    map_QPIdObject.put(bigQP.BigMachines__Product__c , bigQP);
                    listQuoteProdToDeleted.add(bigQP);
                }
                
                for(BigMachines__Quote_Product__c objQP : quoteProductsToBeInserted){
                    objQP.CurrencyISOCode = quote.CurrencyISOCode;
                    objQP.Play__c = quote.Top_Play__c;
                    if(map_QPIdObject.containsKey(objQP.BigMachines__Product__c)){
                        objQP.Bundle__c = map_QPIdObject.get(objQP.BigMachines__Product__c).Bundle__c;
                        objQP.Offer__c = map_QPIdObject.get(objQP.BigMachines__Product__c).Offer__c;
                    }
                }
                    
                if(!listQuoteProdToDeleted.isEmpty())
                    delete listQuoteProdToDeleted;     
                if(!quoteProductsToBeInserted.isEmpty()){                   
                    insert quoteProductsToBeInserted;
                }
                if(quote.Offering_Type__c == 'Business Edition')
                {
                    obj_DDS = DDSCloud.calculateRawScore(quote);
                    objDDSHistory = obj_DDS.objDealScoreHistory;
                    System.debug('Cloud Data --'+obj_DDS);
                }
            /*// Synchronize with Opportunity if the quote is not a BE quote for ANZ
if(!(opp.Sold_To_Country__r.RU__c == 'ANZ' && 
(Opp.Lines_of_Businesses__c == 'Business Edition' || Opp.Lines_of_Businesses__c == 'Premier Edition')))
{*/
            System.debug('NKC debug quote.BigMachines__Is_Primary__c ['+quote.BigMachines__Is_Primary__c+']');      
            BigMachines__Quote__c freshQuote = [SELECT Is_Business_Primary__c, BigMachines__Is_Primary__c FROM BigMachines__Quote__c WHERE id =: quote.id];
            System.debug('NKC debug freshQuote.BigMachines__Is_Primary__c ['+freshQuote.BigMachines__Is_Primary__c+']');        
            System.debug('NKC debug freshQuote ['+freshQuote+']');
            List<OpportunityLineItem> oppLineItemsToBeInserted = new List<OpportunityLineItem>(); 
            List<OpportunityLineItem> oppLineItemsToBeDeleted = new List<OpportunityLineItem>(); 
            system.debug('$$Anju$$primary'+freshQuote.BigMachines__Is_Primary__c);       
            if(freshQuote.BigMachines__Is_Primary__c)
            {  
                CloudQuoteUtil.DO_NOT_CALL_OPP_PRODUCT_TOTAL_LOGIC = true;      
                if(quote.CPS_Total__c == null)
                    quote.CPS_Total__c = 0;
                if(quote.Support_Total__c == null)
                    quote.Support_Total__c = 0;     
                if(quote.Cloud_Total__c == null)
                    quote.Cloud_Total__c = 0;           
                if(opp.Annual_Contract_Value_new__c == null)
                    opp.Annual_Contract_Value_new__c = 0;
                //Removing Support from PS as per Pushpa on 05/01
                opp.Total_PS_Support__c = quote.CPS_Total__c;// + quote.Support_Total__c;               
                if(quote.Annual_Contract_Value__c == null)
                    quote.Annual_Contract_Value__c = 0;
                opp.Annual_Contract_Value_new__c = ACVBeforePS + opp.Total_PS_Support__c;             
                opp.ACV_Subscription_Only__c = opp.Annual_Contract_Value_new__c - opp.Total_PS_Support__c + quote.TAM_amount__c;          
                //opp.Total_Annual_Contract_Value__c = (ACVBeforePS * term) + opp.Total_PS_Support__c;
                //Modified to take from TCV
                opp.Total_Annual_Contract_Value__c = quote.Total_Contract_Value__c;
                opp.Annual_Contract_Value_Subscription__c = opp.Total_Annual_Contract_Value__c - opp.Total_PS_Support__c;
                opp.Monthly_Commitment__c = quote.Minimum_Fees_Period__c;       
                opp.Term_Commitment__c = quote.Initial_Subscription_Term__c;
                opp.Frequency_Term__c = quote.Period__c;
                
                //Sep 12 adding education amount - Anju starts
                opp.Education_Amount__c = quote.Genesys_University_Training_Total__c;
                system.debug('$$Anju$$ oppvalue'+opp);
                //Sep 12 adding education amount - Anju ends
                
                //PureSuccess Total Anju 2018
                //Anju Jan 2018 PureSuccess starts
                opp.A_La_Carte_PureSuccess_Services_Amount__c = quote.A_La_Carte_PureSuccess_Services_Amount__c;
                opp.PureSuccess_Offer_Amount__c = quote.PureSuccess_Offer_Subscription_Amount__c;
                opp.PureSuccess_Offer__c =  quote.PureSuccess__c;
                //Anju Jan 2018 PureSuccess ends
                //Anju March 2018 Seat Count
                opp.Incremental_Agent_Seat_Count__c = quote.Max_Seat_Count__c;
                opp.Deal_Score__c = quote.Deal_Score__c;
                
                opp.MSA_Url__c = quote.MSA_Link__c;
                //opp.Primary_Line_of_Business__c = plateformType;
                opp.Primary_Line_of_Business__c = 'Cloud';
                
                Map<Id,Id> PBEntry = new Map<Id,Id>();
                for(PricebookEntry eachPBEntry:[ SELECT id,product2id,Pricebook2.Name FROM pricebookentry 
                                                WHERE pricebook2id =: opp.Pricebook2Id AND product2id in : selectedProductIds 
                                                AND CurrencyIsoCode =: quote.CurrencyIsoCode ])
                    PBEntry.put(eachPBEntry.product2id,eachPBEntry.Id); 
                
                System.debug('NKC debug PBEntry ['+PBEntry+']');
                for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsToBeInserted)
                {
                    OpportunityLineItem newLineItem = new OpportunityLineItem();
                    System.debug('NKC debug PBEENTRY ['+PBEntry.get(eachQuoteProduct.BigMachines__Product__c)+']');              
                    newLineItem.PricebookEntryId = PBEntry.get(eachQuoteProduct.BigMachines__Product__c);
                    
                    if(eachQuoteProduct.BigMachines__Quantity__c == null || eachQuoteProduct.BigMachines__Quantity__c == 0)
                        eachQuoteProduct.BigMachines__Quantity__c = 1;
                    
                    //newLineItem.ProductId = eachQuoteProduct.BigMachines__Product__c;
                    newLineItem.Quantity = eachQuoteProduct.BigMachines__Quantity__c;
                    newLineItem.Quantity__c = eachQuoteProduct.BigMachines__Quantity__c;
                    //newLineItem.TotalPrice = eachQuoteProduct.Fees_Applied__c;
                    newLineItem.UnitPrice = eachQuoteProduct.Net_Unit_Price__c;
                    newLineItem.Total_Discount__c = eachQuoteProduct.Discount__c;
                    newLineItem.Product_Type__c = 'Cloud';
                    newLineItem.OpportunityId = opp.id;
                    oppLineItemsToBeInserted.add(newLineItem);
                }
                
                
                oppLineItemsToBeDeleted = [SELECT id FROM OpportunityLineItem WHERE OpportunityId =: opp.id];
                if(!oppLineItemsToBeDeleted.isEmpty())
                    delete oppLineItemsToBeDeleted;
                
                //Added By Ranjith on Aug 16, 2017 -- Starts
                opp.Pricebook2Id = Label.Standard_Pricebook_Id;
                //Added By Ranjith on Aug 16, 2017 -- Ends
                update opp;
                //Inserting Opp Line Items
                
                
                
                if(!Test.isRunningTest())
                    if(!oppLineItemsToBeInserted.isEmpty() && quote.CurrencyIsoCode == 'USD')
                    insert oppLineItemsToBeInserted;
            }
            
        }
        catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            Database.rollback(objSP);
        } 
        //}
        
        
        
        return null;
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> autoSelectDependingProducts(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> allQuoteLineItems, Set<String> selectedProductIds, Set<String> nonSelectedProductIds)
    {
        System.debug('NKC debug selectedProductIds ['+selectedProductIds+']');
        System.debug('NKC debug nonSelectedProductIds ['+nonSelectedProductIds+']');        
        List<Product2> products = [SELECT id, Auto_Select_This_Product_If__c FROM Product2 
                                   WHERE id IN : selectedProductIds OR id IN : nonSelectedProductIds];
        Set<String> autoSelectProductId = new Set<String>();        
        for(Product2 eachProduct : products )
        {
            if(eachProduct.Auto_Select_This_Product_If__c != null && selectedProductIds.contains(eachProduct.Auto_Select_This_Product_If__c))
                autoSelectProductId.add(eachProduct.id);            
        }               
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : allQuoteLineItems)
        {
            if(eachRecord.autoSelected != null && eachRecord.autoSelected)
            {
                eachRecord.autoSelected = false;
                eachRecord.selected = false;
                eachRecord.record.BigMachines__Quantity__c = null;
                eachRecord.record.Product_Option__c = null;
            }
        }
        
        if(autoSelectProductId.isEmpty())
            return null;
        
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : allQuoteLineItems)
        {           
            if(autoSelectProductId.contains(eachRecord.record.BigMachines__Product__c))
            {
                eachRecord.autoSelected = true;
                eachRecord.record.Product_Option__c = 'Yes';
                eachRecord.selected = true;
                eachRecord.styleClass = 'disabled';
                /*// Supervisor seat calculation (Change design at some point)
if(eachRecord.record.Product__c == 'Cloud Contact Center Supervisor Seat')
{
for(ServiceOrderQuoteToolController.wrapperQuoteProducts checkRecord : allQuoteLineItems)
{
if(checkRecord.record.Product__c == 'Cloud Contact Center Inbound Voice Seat')
{
eachRecord.record.BigMachines__Quantity__c = (checkRecord.record.BigMachines__Quantity__c / 10).round(RoundingMode.CEILING);
eachRecord.record.Net_Unit_Price__c = eachRecord.record.List_Price__c;
if(eachRecord.record.Discount__c != null)
eachRecord.record.Net_Unit_Price__c -= eachRecord.record.Discount__c * eachRecord.record.List_Price__c * .01;
eachRecord.record.Extended_Price_Per_Month__c = eachRecord.record.Net_Unit_Price__c * eachRecord.record.BigMachines__Quantity__c;
eachRecord.record.Fees_Applied__c = eachRecord.record.Extended_Price_Per_Month__c;
break;
}
}
}
else
{*/
                eachRecord.record.BigMachines__Quantity__c = 1;
                eachRecord.record.Discount__c = 0;
                eachRecord.record.Net_Unit_Price__c = 0;
                eachRecord.record.Extended_Price_Per_Month__c = 0;
                eachRecord.record.Fees_Applied__c = 0;
                //}
            }
            else
                eachRecord.autoSelected = false;                        
        }
        
        return allQuoteLineItems;   
    }
    
    private static String validateSelectedProducts(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> allQuoteLineItems, Set<String> selectedProductIds, Set<String> nonSelectedProductIds)
    {
        System.debug('NKC debug selectedProductIds ['+selectedProductIds+']');
        List<Product2> products = [SELECT id, Must_Not_be_Selected_If_Product_Is__c, Must_Not_be_Selected_If_Product_Is__r.Name, 
                                   Must_be_Selected_If_Selected_Product_Is__c, Must_be_Selected_If_Selected_Product_Is__r.Name FROM Product2 
                                   WHERE id IN : selectedProductIds OR id IN : nonSelectedProductIds];
        Map<String, String> mustNotBeSelectProductIdsVsName = new Map<String, String>();
        Map<String, String> mustBeSelectProductIdsVsName = new Map<String, String>();
        for(Product2 eachProduct : products )
        {          
            if(eachProduct.Must_Not_be_Selected_If_Product_Is__c != null && selectedProductIds.contains(eachProduct.id) && selectedProductIds.contains(eachProduct.Must_Not_be_Selected_If_Product_Is__c))
                mustNotBeSelectProductIdsVsName.put(eachProduct.id, eachProduct.Must_Not_be_Selected_If_Product_Is__r.Name);
            else if(eachProduct.Must_be_Selected_If_Selected_Product_Is__c != null && nonSelectedProductIds.contains(eachProduct.id) && selectedProductIds.contains(eachProduct.Must_be_Selected_If_Selected_Product_Is__c))
                mustBeSelectProductIdsVsName.put(eachProduct.id, eachProduct.Must_be_Selected_If_Selected_Product_Is__r.Name);              
        }
        
        if(mustNotBeSelectProductIdsVsName.isEmpty() && mustBeSelectProductIdsVsName.isEmpty())
            return null;
        
        Boolean isError = false;
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : allQuoteLineItems)
        {
            if(eachRecord.autoSelected != null && eachRecord.autoSelected)
                continue;           
            if(eachRecord.index != -1 && mustNotBeSelectProductIdsVsName.keyset().contains(eachRecord.record.BigMachines__Product__c))
            {
                eachRecord.styleClass = 'errorRow';
                eachRecord.errorMsg = 'You can not select this product because you have selected ' + mustNotBeSelectProductIdsVsName.get(eachRecord.record.BigMachines__Product__c) + '.';
                isError = true;
            }
            
            if(eachRecord.index != -1 && mustBeSelectProductIdsVsName.keyset().contains(eachRecord.record.BigMachines__Product__c))
            {
                eachRecord.styleClass = 'errorRow';
                eachRecord.errorMsg = 'You need to select this product because you have selected ' + mustBeSelectProductIdsVsName.get(eachRecord.record.BigMachines__Product__c) + '.';
                isError = true;
            }
        }
        if(isError)
            return 'There is some product selection validation error. Please find more details at line level.';
        else 
            return null;        
    }
    @testvisible
    private static Double caculateMininumFeesPeriod(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines)
    {
        Integer totalQuantity = 0;
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
        {
            if(!Test.isRunningTest() && eachRecord.selected && eachRecord.includeInCMRR && eachRecord.record.BigMachines__Quantity__c != null )
                totalQuantity += Integer.valueOf(eachRecord.record.BigMachines__Quantity__c);
        }
        List<Product_Discount_Lookup__c> productDiscounts = [SELECT Pricing_Table__r.Monthly_Invoice_Commit__c 
                                                             FROM Product_Discount_Lookup__c WHERE Product__r.Name = 'Local Committed Minutes-PEC' 
                                                             AND Pricing_Table__r.Range_From__c <= : totalQuantity AND Pricing_Table__r.Range_To__c >= : totalQuantity];
        
        if(!productDiscounts.isEmpty())
            return productDiscounts[0].Pricing_Table__r.Monthly_Invoice_Commit__c;
        
        return null;
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts>  bulkUpdate(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines, List<ServiceOrderQuoteToolController.wrapperQuoteProducts> headerRow)
    {
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachQuoteProduct : quoteLines)
        {
            if(eachQuoteProduct.selected != null && eachQuoteProduct.selected)
            {
                if(headerRow[0].record.BigMachines__Quantity__c != null)
                    eachQuoteProduct.record.BigMachines__Quantity__c = headerRow[0].record.BigMachines__Quantity__c;
                
                // 3/15/2016 : Should only set discount for discountable lines
                if(headerRow[0].record.Discount__c != null && eachQuoteProduct.isDiscountable)
                    eachQuoteProduct.record.Discount__c = headerRow[0].record.Discount__c;              
            }
        }
        return quoteLines;
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> poulateHeaderRecord(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> headerRecord)
    {
        ServiceOrderQuoteToolController.wrapperQuoteProducts headerRow = new ServiceOrderQuoteToolController.wrapperQuoteProducts();
        BigMachines__Quote_Product__c newRecord = new BigMachines__Quote_Product__c();
        headerRow.record = newRecord;
        headerRecord.add(headerRow);
        return headerRecord;
    }
    @testvisible
    private static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> doCalculationForSupportAndCS(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines, Decimal CMMR, Boolean isCS, Integer iPeriod)
    {
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
        {
            if(eachRecord.selected && CMMR != null)
            {
                System.debug('NKC debug eachRecord.record.Level_Of_Support__c ['+eachRecord.record.Level_Of_Support__c+']');
                List<Product_Discount_Lookup__c> productDiscounts;
                if(!isCS)
                {
                    productDiscounts = [SELECT Pricing_Table__r.List_Price__c, Pricing_Table__r.Price_Type__c,
                                        Pricing_Table__r.Range_From__c, Pricing_Table__r.Range_To__c, Pricing_Table__r.Monthly_Invoice_Commit__c
                                        FROM Product_Discount_Lookup__c 
                                        WHERE Product__c =: eachRecord.record.BigMachines__Product__c AND Pricing_Table__r.Product_Type__c =: eachRecord.record.Level_Of_Support__c];
                }
                else
                {
                    productDiscounts = [SELECT Pricing_Table__r.List_Price__c, Pricing_Table__r.Price_Type__c,
                                        Pricing_Table__r.Range_From__c, Pricing_Table__r.Range_To__c, Pricing_Table__r.Monthly_Invoice_Commit__c
                                        FROM Product_Discount_Lookup__c 
                                        WHERE Product__c =: eachRecord.record.BigMachines__Product__c];
                }    
                if(!productDiscounts.isEmpty())
                {
                    String pricingType = productDiscounts[0].Pricing_Table__r.Price_Type__c;
                    Double percentageOfCMMR;
                    System.debug('NKC debug percentageOfCMMR ['+percentageOfCMMR+']');
                    if(pricingType.equals('Fixed Price'))
                    {
                        Decimal discountPercentage = productDiscounts[0].Pricing_Table__r.Monthly_Invoice_Commit__c == null ? 0 : productDiscounts[0].Pricing_Table__r.Monthly_Invoice_Commit__c;
                        System.debug('NKC debug CMMR ['+CMMR+']');
                        System.debug('NKC debug iPeriod ['+iPeriod+']');                           
                        
                        if(CMMR != 0)
                            CMMR /= iPeriod;
                        
                        System.debug('NKC debug CMMR ['+CMMR+']');
                        percentageOfCMMR = CMMR * discountPercentage / 100;
                        System.debug('NKC debug percentageOfCMMR ['+percentageOfCMMR+']');
                        Decimal extendedPrice = percentageOfCMMR > productDiscounts[0].Pricing_Table__r.List_Price__c ? percentageOfCMMR : productDiscounts[0].Pricing_Table__r.List_Price__c;
                        System.debug('NKC debug extendedPrice ['+extendedPrice+']');
                        //If it's % then no need to convert again.
                        
                        if(percentageOfCMMR > productDiscounts[0].Pricing_Table__r.List_Price__c)
                            eachRecord.record.Extended_Price_Per_Month__c = extendedPrice;
                        else
                            eachRecord.record.Extended_Price_Per_Month__c = getConvertedListPrice(eachRecord, extendedPrice, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);
                        
                        eachRecord.record.List_Price__c = eachRecord.record.Extended_Price_Per_Month__c;                            
                    }
                    else if(pricingType.equals('Range'))
                    {                           
                        Boolean doesItFallInRange = false;
                        for(Product_Discount_Lookup__c eachDiscountRecord : productDiscounts)
                        {                              
                            Double fromRange = eachDiscountRecord.Pricing_Table__r.Range_From__c;
                            Double toRange = eachDiscountRecord.Pricing_Table__r.Range_To__c;       
                            System.debug('NKC debug fromRange ['+fromRange+']');
                            System.debug('NKC debug toRange ['+toRange+']');
                            System.debug('NKC debug percentageOfCMMR ['+percentageOfCMMR+']');                       
                            if(CMMR >= fromRange && CMMR <= toRange)
                            {
                                eachRecord.record.Extended_Price_Per_Month__c = getConvertedListPrice(eachRecord, eachDiscountRecord.Pricing_Table__r.List_Price__c, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);
                                eachRecord.record.List_Price__c = eachRecord.record.Extended_Price_Per_Month__c;                                    
                                Decimal discountPercentage = eachDiscountRecord.Pricing_Table__r.Monthly_Invoice_Commit__c == null ? 0 : eachDiscountRecord.Pricing_Table__r.Monthly_Invoice_Commit__c;
                                percentageOfCMMR = CMMR * discountPercentage / 100;
                                doesItFallInRange = true;
                                System.debug('NKC debug percentageOfCMMR ['+percentageOfCMMR+']');
                                System.debug('NKC debug eachRecord.record.Extended_Price_Per_Month__c ['+eachRecord.record.Extended_Price_Per_Month__c+']');
                                break;                                  
                            }
                        }
                        if(doesItFallInRange == true)
                        {
                            if(percentageOfCMMR > eachRecord.record.Extended_Price_Per_Month__c)
                            {
                                eachRecord.record.Extended_Price_Per_Month__c = getConvertedListPrice(eachRecord, percentageOfCMMR, 'USD');
                                eachRecord.record.List_Price__c = eachRecord.record.Extended_Price_Per_Month__c; 
                            }
                        }
                    }
                }
                
                if(eachRecord.record.Extended_Price_Per_Month__c != null && eachRecord.record.Discount__c != null && eachRecord.record.Discount__c != 0)
                    eachRecord.record.Extended_Price_Per_Month__c -= eachRecord.record.Extended_Price_Per_Month__c * eachRecord.record.Discount__c / 100;
                
                System.debug('NKC debug eachRecord.record.Extended_Price_Per_Month__c ['+eachRecord.record.Extended_Price_Per_Month__c+']');
            }           
            else if(eachRecord.selected == false)
            {
                eachRecord.selected = false;
                eachRecord.record.BigMachines__Quantity__c = null;
                //eachRecord.record.List_Price__c = null;
                eachRecord.record.Discount__c = null;
                eachRecord.record.Net_Unit_Price__c = null;
                eachRecord.record.Extended_Price_Per_Month__c = null;
                eachRecord.record.Fees_Applied__c = null;               
            }
            if(eachRecord.selected != null && eachRecord.selected && eachRecord.record.Product_Option__c == 'No')
            {
                eachRecord.record.Extended_Price_Per_Month__c = 0;
                eachRecord.record.Fees_Applied__c = 0;              
            }
        }
        
        return quoteLines;     
    }
    
    public static List<Product_Discount_Lookup__c> getProductDiscountLookupRecords()
    {
        List<Product_Discount_Lookup__c> productDiscounts = [SELECT Pricing_Table__r.List_Price__c, Pricing_Table__r.Price_Type__c,
                                                             Pricing_Table__r.Range_From__c, Pricing_Table__r.Range_To__c, Pricing_Table__r.Product_Group__c, Pricing_Table__r.Activation_Fee__c,
                                                             Product__r.Product_Option__c, Product__c, Pricing_Table__r.Product_Type__c, Pricing_Table__r.CurrencyISOCode
                                                             FROM Product_Discount_Lookup__c];                    
        return productDiscounts;
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> doCalculation(List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines, 
                                                                                           Integer index, Integer iPeriod, String sectionType, String currencyIsoCode, BigMachines__Quote__c quote, List<Product_Discount_Lookup__c> productDiscounts1 )
    {
        ServiceOrderQuoteToolController.wrapperQuoteProducts totalRecord;       
        Double total = 0;               
        Set<String> selectededProductIds = new Set<String>();
        Set<String> notSelectededProductIds = new Set<String>();
        List<Product_Discount_Lookup__c> productDiscounts = new List<Product_Discount_Lookup__c>();
        productDiscounts.addAll(productDiscounts1);
        System.debug('Calculation Method : ' + sectionType);
        Map<String, List<ServiceOrderQuoteToolController.wrapperQuoteProducts>> mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated = new Map<String, List<ServiceOrderQuoteToolController.wrapperQuoteProducts>>();
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
        {
            
            if(eachRecord.listPriceCalculateFrom != null)
            {              
                if(mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.get(eachRecord.listPriceCalculateFrom) == null)
                {
                    List<ServiceOrderQuoteToolController.wrapperQuoteProducts> newList = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();
                    newList.add(eachRecord);    
                    mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.put(eachRecord.listPriceCalculateFrom, newList);
                }
                else
                    mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.get(eachRecord.listPriceCalculateFrom).add(eachRecord); 
            }
        }       
        
        List<Integer> currentCurrencyRecordIndex = new List<Integer>();
        Integer counter = 0;
        List<Product_Discount_Lookup__c> productDiscountMatchingCurrency = new List<Product_Discount_Lookup__c>();
        for(Product_Discount_Lookup__c eachProductDiscount : productDiscounts)
        {            
            if(eachProductDiscount.Pricing_Table__r.CurrencyISOCode == currencyIsoCode)
            {
                currentCurrencyRecordIndex.add(counter);
                productDiscountMatchingCurrency.add(eachProductDiscount);
            }
            counter ++;
        }
        System.debug('NKC debug currentCurrencyRecordIndex ['+currentCurrencyRecordIndex+']');
        System.debug('NKC debug productDiscounts ['+productDiscounts+']');
        Integer deletedCount = 0;
        for(Integer i : currentCurrencyRecordIndex)
        {
            productDiscounts.remove(i - deletedCount);
            deletedCount ++;    
        }
        productDiscountMatchingCurrency.addAll(productDiscounts);
        productDiscounts = productDiscountMatchingCurrency;
        System.debug('NKC debug productDiscountMatchingCurrency ['+productDiscountMatchingCurrency+']');
        
        System.debug('NKC debug productDiscounts ['+productDiscounts+']');
        Map<Id, List<Product_Discount_Lookup__c>> keyIdVsPricingList = new Map<Id, List<Product_Discount_Lookup__c>>();
        for(Product_Discount_Lookup__c eachProductDiscount : productDiscounts)
        {
            if(keyIdVsPricingList.get(eachProductDiscount.Product__c) == null)
            {
                List<Product_Discount_Lookup__c> newList = new List<Product_Discount_Lookup__c>();
                newList.add(eachProductDiscount);
                keyIdVsPricingList.put(eachProductDiscount.Product__c, newList);
            }
            else
                keyIdVsPricingList.get(eachProductDiscount.Product__c).add(eachProductDiscount);
            //=: eachRecord.record.Product_Group__c AND Pricing_Table__r.Product_Type__c =: eachRecord.record.Device__c
        }           
        
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
        {
            System.debug('$$' + eachRecord.index + ' index = ' + index);
            eachRecord.styleClass = 'none';
            notSelectededProductIds.add(eachRecord.record.BigMachines__Product__c);
            if(eachRecord.index == -1)
            {
                totalRecord = eachRecord;
                eachRecord.styleClass = 'totalRow';
                continue;
            }
            
            if(eachRecord.productOption == 'Yes/No')
                eachRecord.record.BigMachines__Quantity__c = 1;
            
            else if(eachRecord.record.BigMachines__Quantity__c == null) 
                eachRecord.record.BigMachines__Quantity__c = 0;             
            
            if( eachRecord.selected != null && eachRecord.selected && (index == eachRecord.index || index == 0))
            {
                eachRecord.styleClass = 'activeRow';
                eachRecord.selected = true;
                selectededProductIds.add(eachRecord.record.BigMachines__Product__c);
                notSelectededProductIds.remove(eachRecord.record.BigMachines__Product__c);              
                productDiscounts = keyIdVsPricingList.get(eachRecord.record.BigMachines__Product__c);
                System.debug('NKC debug productDiscounts ['+productDiscounts+']');
                System.debug('NKC debug eachRecord.record.BigMachines__Product__c ['+eachRecord.record.BigMachines__Product__c+']');
                
                if(productDiscounts != null && !productDiscounts.isEmpty())
                {
                    String pricingType = productDiscounts[0].Pricing_Table__r.Price_Type__c;
                    eachRecord.productOption = productDiscounts[0].Product__r.Product_Option__c;
                    
                    if(pricingType.equals('Fixed Price'))
                    {
                        if(!productDiscounts.isEmpty() && productDiscounts.size() == 1)
                        {
                            eachRecord.record.List_Price__c = getConvertedListPrice(eachRecord, productDiscounts[0].Pricing_Table__r.List_Price__c, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);                            
                            eachRecord.record.Installation_Fees__c = getConvertedListPrice(eachRecord, productDiscounts[0].Pricing_Table__r.Activation_Fee__c, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);
                        }
                        else if(productDiscounts.size() > 1)
                        {                           
                            for(Product_Discount_Lookup__c eachDiscountRecord : productDiscounts)
                            {
                                if(eachDiscountRecord.Pricing_Table__r.Product_Type__c == eachRecord.record.Device__c)
                                {
                                    eachRecord.record.List_Price__c = getConvertedListPrice(eachRecord, eachDiscountRecord.Pricing_Table__r.List_Price__c, eachDiscountRecord.Pricing_Table__r.CurrencyIsoCode);
                                    eachRecord.record.Installation_Fees__c = getConvertedListPrice(eachRecord, eachDiscountRecord.Pricing_Table__r.Activation_Fee__c, eachDiscountRecord.Pricing_Table__r.CurrencyIsoCode);
                                    break;
                                }
                            }
                        }
                    }                   
                    else if(pricingType.equals('Editable'))
                    {                                                
                        eachRecord.isListPriceEditable = true;
                        //eachRecord.record.List_Price__c = productDiscounts[0].Pricing_Table__r.List_Price__c;
                        eachRecord.record.Installation_Fees__c = getConvertedListPrice(eachRecord,productDiscounts[0].Pricing_Table__r.Activation_Fee__c, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);
                    }
                    else
                    {
                        for(Product_Discount_Lookup__c eachDiscountRecord : productDiscounts)
                        {
                            Double quantity = eachRecord.record.BigMachines__Quantity__c;                           
                            Double fromRange = eachDiscountRecord.Pricing_Table__r.Range_From__c;
                            Double toRange = eachDiscountRecord.Pricing_Table__r.Range_To__c;
                            if(quantity >= fromRange && quantity <= toRange)
                            {
                                eachRecord.record.List_Price__c = getConvertedListPrice(eachRecord, eachDiscountRecord.Pricing_Table__r.List_Price__c, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);
                                eachRecord.record.Installation_Fees__c = getConvertedListPrice(eachRecord, eachDiscountRecord.Pricing_Table__r.Activation_Fee__c, productDiscounts[0].Pricing_Table__r.CurrencyIsoCode);
                                break;
                            }
                        }
                    }                   
                }
                
                if(quote.Offering_Type__c == 'Premier Edition')
                {
                    // Storing total Enhanced IVR minutes
                    if(eachRecord.record.Name == 'Premier Enhanced IVR' && eachRecord.record.Product_Group__c == 'Self-Service/IVR')
                        decTotalEnhancedIVRMins += eachRecord.record.BigMachines__Quantity__c;
                    
                    // Assuming Enhanced IVR will be calculated first (in order) and total minutes will be available
                    else if(eachRecord.record.Name == 'Premier Call Recording (For Stand-Alone IVR)')
                        eachRecord.record.BigMachines__Quantity__c = decTotalEnhancedIVRMins;
                    
                    // Assuming total amount for CX Analytics calculation will be available due to ordering of products
                    // CX Analytics is 10% of Total Amount of IVR Options and Integrations with minimum being $250
                    else if(eachRecord.record.Name == 'Premier CX Analytics for IVR')
                    {
                        Decimal decAmt = decTotalIVROptAndInt * Currency_Settings__c.getInstance('CX Analytics for IVR').Conversion_Rate__c;
                        Decimal decMinAmt = Currency_Settings__c.getInstance('CX Analytics for IVR').Cloud_BE_Concurrent_Uplift_multiplier__c;
                        eachRecord.record.List_Price__c = decAmt > decMinAmt ? decAmt : decMinAmt;
                    }
                }
                
                if(eachRecord.record.Installation_Fees__c == null) 
                    eachRecord.record.Installation_Fees__c = 0;             
                
                if(eachRecord.record.Fees_Applied__c == null) 
                    eachRecord.record.Fees_Applied__c = 0;
                
                if(eachRecord.record.List_Price__c == null)
                    eachRecord.record.List_Price__c = 0; 
                
                if(sectionType == 'Transaction Based' || sectionType == 'Tier Based')
                    eachRecord.record.Net_Unit_Price__c = eachRecord.record.List_Price__c;
                else
                    eachRecord.record.Net_Unit_Price__c = eachRecord.record.List_Price__c * iPeriod;
                
                if(eachRecord.record.Discount__c != null && eachRecord.record.Discount__c != 0)
                    eachRecord.record.Net_Unit_Price__c -= eachRecord.record.Net_Unit_Price__c * eachRecord.record.Discount__c / 100;
                
                eachRecord.record.Extended_Price_Per_Month__c = eachRecord.record.Net_Unit_Price__c * eachRecord.record.BigMachines__Quantity__c;
                eachRecord.record.Fees_Applied__c = eachRecord.record.Extended_Price_Per_Month__c + eachRecord.record.Installation_Fees__c;
                
                if(quote.Offering_Type__c == 'Premier Edition' && eachRecord.record.Name != 'Premier CX Analytics for IVR' &&
                   (eachRecord.record.Product_Group__c == 'Self-Service/IVR Options' || 
                    eachRecord.record.Product_Group__c == 'Self-Service/IVR Integrations'))
                    decTotalIVROptAndInt += eachRecord.record.Extended_Price_Per_Month__c;
                
            }           
            else if(eachRecord.selected == false)
            {
                eachRecord.record.BigMachines__Quantity__c = null;
                //eachRecord.record.List_Price__c = null;
                eachRecord.record.Discount__c = null;
                eachRecord.record.Net_Unit_Price__c = null;
                eachRecord.record.Extended_Price_Per_Month__c = null;
                eachRecord.record.Fees_Applied__c = null;                               
            }
            if(eachRecord.selected != null && eachRecord.selected && eachRecord.record.Product_Option__c == 'No')
            {
                eachRecord.record.Extended_Price_Per_Month__c = 0;
                eachRecord.record.Fees_Applied__c = 0;              
            }
            
            System.debug(' Product_Group__c = '+ eachRecord.record.Product_Group__c);
            // 18929 : To fix sub totals for Customer Subscriptions and Support for Self Service Quote
            if(eachRecord.record.Product_Group__c == 'Customer Subscription' || eachRecord.record.Product_Group__c == 'Support')
                total += eachRecord.record.Extended_Price_Per_Month__c != null ? eachRecord.record.Extended_Price_Per_Month__c : 0;
            else
                total += eachRecord.record.Fees_Applied__c != null ? eachRecord.record.Fees_Applied__c : 0;
        }
        
        if(index != -1)
        {
            autoSelectDependingProducts(quoteLines, selectededProductIds, notSelectededProductIds);
            calculatePercentListPrice(mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated, quoteLines);
        }
        if(totalRecord != null)
        {
            totalRecord.record.Extended_Price_Per_Month__c = total;
            totalRecord.record.Net_Unit_Price__c = null;
            System.debug('<<< totalRecord ' + totalRecord);
        }
        return quoteLines;  
    }   
    
    @TestVisible
    private static void calculatePercentListPrice(Map<String, List<ServiceOrderQuoteToolController.wrapperQuoteProducts>> mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated,
                                                  List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines)
    {
        System.debug('NKC debug mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated ['+mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated+']');
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
        {
            List<ServiceOrderQuoteToolController.wrapperQuoteProducts> childRecords =  mapProductIdVsChildRecordsForWhichLPNeedsToBeCalculated.get(eachRecord.record.BigMachines__Product__c);
            
            if(childRecords == null)
                continue;
            
            System.debug('NKC debug childRecords ['+childRecords+']');
            System.debug('NKC debug childRecords.size() ['+childRecords.size()+']');
            
            for(ServiceOrderQuoteToolController.wrapperQuoteProducts childRecord : childRecords)
            {
                System.debug('NKC debug childRecord ['+childRecord+']');
                if(childRecord != null && childRecord.selected != null && childRecord.selected && eachRecord.selected != null && eachRecord.selected)
                {
                    System.debug('NKC debug in');
                    if(eachRecord.record.List_Price__c == null)
                        eachRecord.record.List_Price__c = 0;
                    
                    if(childRecord.record.List_Price__c == null)
                        childRecord.record.List_Price__c = 0;
                    
                    if(childRecord.record.Discount__c == null)
                        childRecord.record.Discount__c = 0;
                    
                    if(childRecord.record.Installation_Fees__c == null)
                        childRecord.record.Installation_Fees__c = 0;
                    
                    if(childRecord.record.Net_Unit_Price__c == null)
                        childRecord.record.Net_Unit_Price__c = 0;
                    
                    Decimal listPrice;
                    
                    if(eachRecord.record.Extended_Price_Per_Month__c == null)
                        listPrice = 0;
                    else
                        listPrice = eachRecord.record.Extended_Price_Per_Month__c * childRecord.record.List_Price__c / 100;
                    
                    if(childRecord.record.Discount__c == 0)
                        childRecord.record.Extended_Price_Per_Month__c = listPrice * childRecord.record.BigMachines__Quantity__c;
                    else
                        childRecord.record.Extended_Price_Per_Month__c =  (listPrice - (listPrice * childRecord.record.Discount__c / 100) * childRecord.record.BigMachines__Quantity__c);
                    
                    Decimal netUnitPriceDiscount = childRecord.record.List_Price__c - (childRecord.record.List_Price__c * childRecord.record.Discount__c / 100);
                    childRecord.record.Net_Unit_Price__c = netUnitPriceDiscount;
                    childRecord.record.Fees_Applied__c = childRecord.record.Extended_Price_Per_Month__c + childRecord.record.Installation_Fees__c;  
                    childRecord.styleClass = 'activeRow';           
                }
            }
        }
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> doCalculationOnPeriodChange
        (List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines, Integer iPeriod)
    {
        Double total = 0;
        ServiceOrderQuoteToolController.wrapperQuoteProducts totalRecord;
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
        {
            if(eachRecord.index == -1)
            {
                totalRecord = eachRecord;
                continue;
            }
            if(eachRecord.selected != null && eachRecord.selected)
            {         
                System.debug('NKC debug iPeriod ['+iPeriod+']');    
                if(eachRecord.record.BigMachines__Quantity__c != null && eachRecord.record.List_Price__c != null && eachRecord.record.Installation_Fees__c != null && iPeriod != null)
                {
                    eachRecord.record.Net_Unit_Price__c = eachRecord.record.List_Price__c  * iPeriod;
                    
                    if(eachRecord.record.Discount__c != null && eachRecord.record.Discount__c != 0)
                        eachRecord.record.Net_Unit_Price__c -= eachRecord.record.Net_Unit_Price__c * eachRecord.record.Discount__c / 100;
                    
                    if(eachRecord.record.Net_Unit_Price__c != null)
                        total += eachRecord.record.Net_Unit_Price__c;
                }
            }
            else if(eachRecord.record.BigMachines__Quantity__c == 0 || eachRecord.record.BigMachines__Quantity__c == null)
            {
                eachRecord.selected = false;
                eachRecord.record.BigMachines__Quantity__c = null;
                eachRecord.record.List_Price__c = null;
                eachRecord.record.Discount__c = null;
                eachRecord.record.Net_Unit_Price__c = null;
                eachRecord.record.Extended_Price_Per_Month__c = null;
                eachRecord.record.Fees_Applied__c = null;               
            }
            
        } 
        if (!Test.isRunningTest())  
            totalRecord.record.Net_Unit_Price__c = total;
        return quoteLines;
    }
    
    public static Map<String, List<Product_Discount_Lookup__c>> getProductIdVsPricingTable
        (List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteLines)
    {
        Set<Id> productIds = new Set<Id>();
        
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteLines)
            productIds.add(eachRecord.record.BigMachines__Product__c);
        
        Map<String, List<Product_Discount_Lookup__c>> mapProductIdVsPricingTable = new Map<String, List<Product_Discount_Lookup__c>>();
        List<Product_Discount_Lookup__c> productDiscounts = [SELECT Pricing_Table__r.List_Price__c,
                                                             Pricing_Table__r.Range_From__c, Pricing_Table__r.Range_To__c, Pricing_Table__r.Product_Group__c, 
                                                             Pricing_Table__r.Activation_Fee__c,Product__r.Product_Option__c,Pricing_Table__r.Price_Type__c
                                                             FROM Product_Discount_Lookup__c WHERE Product__c IN : productIds];
        
        for(Product_Discount_Lookup__c eachPricing : productDiscounts)
        {
            if(mapProductIdVsPricingTable.get(eachPricing.Product__c) == null)
            {
                List<Product_Discount_Lookup__c> newList = new List<Product_Discount_Lookup__c>();
                newList.add(eachPricing);
                mapProductIdVsPricingTable.put(eachPricing.Product__c, newList);                
            }
            else
                mapProductIdVsPricingTable.get(eachPricing.Product__c).add(eachPricing);
        }       
        
        return mapProductIdVsPricingTable;
    }
    
    public static Integer setIPeriod(String quotePeriod)
    {
        return 1;
    }
    
    @TestVisible
    private static Integer getIPeriodForSupport(String quotePeriod)
    {
        Integer iPeriod;
        if(quotePeriod == 'Monthly')
            iPeriod = 1;
        
        else if(quotePeriod == 'Quarterly')
            iPeriod = 3;
        
        else if(quotePeriod == 'Semi-Annually')
            iPeriod = 6;
        
        else if(quotePeriod == 'Annually')
            iPeriod = 12;
        
        else 
            iPeriod = 1;
        
        return iPeriod; 
    }
    
    public static String submitQuoteToApprovalProcess(BigMachines__Quote__c quote)
    {
        update quote;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Request submitted for approval automatically.');
        req.setObjectId(quote.id);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req);          
        return null;
    }
    
    public static Map<String, List<SelectOption>> getProductVsProductDevicesMap(String CurrencyIsoCode)
    {
        Map<String, List<SelectOption>> mapProductVsProductDevices = new Map<String, List<SelectOption>>();
        List<Product_Devices__c> devices = [SELECT Product__c, Device__r.Name, Device__r.CurrencyIsoCode FROM Product_Devices__c ORDER BY Device__r.Order__c ASC];
        Map<String, Set<String>> mapProductCurrencyVsCurrencies = new Map<String, Set<String>>();
        
        for(Product_Devices__c eachDevice : devices)
        {
            if(mapProductCurrencyVsCurrencies.containsKey(eachDevice.Product__c))
                mapProductCurrencyVsCurrencies.get(eachDevice.Product__c).add(eachDevice.Device__r.CurrencyIsoCode);
            else
            {
                Set<String> currencyList = new Set<String>();
                currencyList.add(eachDevice.Device__r.CurrencyIsoCode);
                mapProductCurrencyVsCurrencies.put(eachDevice.Product__c, currencyList);
            }
        }
        
        for(Product_Devices__c eachDevice : devices)
        {
            if(eachDevice.Device__r.Name == null)
                continue;
            
            Set<String> currencies = mapProductCurrencyVsCurrencies.get(eachDevice.Product__c);
            
            if(currencies !=  null && currencies.size() > 1 && eachDevice.Device__r.CurrencyIsoCode != CurrencyIsoCode)            
                continue;
            
            SelectOption newOption = new SelectOption(eachDevice.Device__r.Name, eachDevice.Device__r.Name);
            
            if(mapProductVsProductDevices.containsKey(eachDevice.Product__c))              
                mapProductVsProductDevices.get(eachDevice.Product__c).add(newOption);
            else
            {
                List<SelectOption> productDeviceList = new List<SelectOption>();        
                SelectOption newOption1 = new SelectOption('--Select--', '--Select--');
                productDeviceList.add(newOption1);      
                productDeviceList.add(newOption);
                mapProductVsProductDevices.put(eachDevice.Product__c, productDeviceList);
            }
        }
        
        return mapProductVsProductDevices;
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> addTotalRow
        (List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteProducts, String sectionType)
    {
        ServiceOrderQuoteToolController.wrapperQuoteProducts newRow = new ServiceOrderQuoteToolController.wrapperQuoteProducts();
        BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
        
        if(!quoteProducts.isEmpty())
            newQuoteProduct.CurrencyIsoCode = quoteProducts[0].record.CurrencyIsoCode;
        
        newQuoteProduct.Net_Unit_Price__c = 0.00;
        newRow.record = newQuoteProduct;
        newRow.index = -1;
        newRow.detailRow = false;
        newRow.styleClass = 'totalRow';
        newRow.selected = false;
        newRow.record.Product_Group__c = sectionType;
        quoteProducts.add(newRow);
        
        return quoteProducts;
    }
    
    public static List<ServiceOrderQuoteToolController.wrapperQuoteProducts> addMoreProduct
        (List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteProducts, Integer index,Integer noOfQuoteProducts)
    {
        List<ServiceOrderQuoteToolController.wrapperQuoteProducts> quoteProductsNew = new List<ServiceOrderQuoteToolController.wrapperQuoteProducts>();
        ServiceOrderQuoteToolController.wrapperQuoteProducts newRow;        
        for(ServiceOrderQuoteToolController.wrapperQuoteProducts eachRecord : quoteProducts)
        {
            quoteProductsNew.add(eachRecord);                               
            if(eachRecord.index == index)
            {
                System.debug('NKC debug index ['+index+']');
                System.debug('NKC debug eachRecord.index ['+eachRecord.index+']');
                newRow = new ServiceOrderQuoteToolController.wrapperQuoteProducts();    
                BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
                newQuoteProduct.Product__c = eachRecord.record.Product__c;
                newQuoteProduct.Metric__c = eachRecord.record.Metric__c;
                newQuoteProduct.BigMachines__Product__c = eachRecord.record.BigMachines__Product__c;
                System.debug('NKC debug index ['+eachRecord.record.BigMachines__Product__c+']');
                newQuoteProduct.Product_Group__c = eachRecord.record.Product_Group__c;
                newQuoteProduct.BigMachines__Quote__c = eachRecord.record.BigMachines__Quote__c;
                newQuoteProduct.List_Price__c = eachRecord.record.List_Price__c;
                newQuoteProduct.BigMachines__Sales_Price__c = 0;
                newQuoteProduct.Name = eachRecord.record.Name;            
                newQuoteProduct.BigMachines__Description__c = eachRecord.record.BigMachines__Description__c;
                newQuoteProduct.Device__c = eachRecord.record.Device__c;    
                newQuoteProduct.CurrencyIsoCode = eachRecord.record.CurrencyIsoCode;            
                newRow.autoSelected = eachRecord.autoSelected;  
                newRow.isListPriceEditable = eachRecord.isListPriceEditable;                
                newRow.listPriceCalculateFrom = eachRecord.listPriceCalculateFrom;      
                newRow.productOption = eachRecord.productOption;    
                newRow.hasDevcies = eachRecord.hasDevcies;
                newRow.includeInCMRR = eachRecord.includeInCMRR;    
                newRow.showNetPriceAsView = eachRecord.showNetPriceAsView;  
                newRow.isListPriceInDiscount = eachRecord.isListPriceInDiscount;    
                newRow.isDiscountable = eachRecord.isDiscountable;
                newRow.pricingModel = eachRecord.pricingModel;
                newRow.showAddSign = eachRecord.showAddSign;
                newRow.addPremiumCharges = eachRecord.addPremiumCharges;
                newRow.detailRow = true;                                    
                newRow.record = newQuoteProduct;
                newRow.index = noOfQuoteProducts;
                newRow.styleClass = 'activeRow';
                quoteProductsNew.add(newRow);       
            }           
        }       
        return quoteProductsNew;
    }
    
    public static void recallApprovalProcess(String quoteId)
    {
        List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where 
                                                                   Status = 'Pending' and TargetObjectId = :quoteId]);
        if(!procins.isEmpty())
        {
            List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>
                ([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id]);
            
            if(!workitem.isEmpty())
            {
                System.debug('NKC debug quoteId ['+quoteId+']');
                String currentUserName = Userinfo.getFirstName() + ' ' +  userinfo.getLastName();
                Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
                PWR.setComments('Recalled by ' + currentUserName + '.');
                PWR.setAction('Removed');
                PWR.setWorkitemId(workitem[0].id);
                PWR.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                Approval.ProcessResult result =  Approval.process(PWR);     
            }
        }
    }   
    
    
    private static Double getConvertedListPrice(ServiceOrderQuoteToolController.wrapperQuoteProducts wrapperRecord, 
                                                Decimal listPrice, String pricingTableCurrency)
    {        
        if(listPrice != null && wrapperRecord.isListPriceInDiscount != null && 
           !wrapperRecord.isListPriceInDiscount && pricingTableCurrency == 'USD')
        {
            Double conversionRate = 1;
            Decimal premiumCharges = 0;
            Currency_Settings__c csCurrencySetting = Currency_Settings__c.getAll().get(wrapperRecord.record.CurrencyIsoCode);
            System.debug('####ConversionRate'+csCurrencySetting);
            if(csCurrencySetting != null)
            {
                conversionRate = csCurrencySetting.Conversion_Rate__c;
                premiumCharges = csCurrencySetting.Premium_Charges__c;
            }    
            System.debug('####ConversionRate'+conversionRate);
            listPrice *= conversionRate;
            
            if(wrapperRecord.addPremiumCharges) 
                listPrice += (listPrice * premiumCharges / 100);
        }       
        return listPrice;
    }
    
    public static List<SelectOption> getSupportOptions(String currencyIsoCode)
    {
        List<SelectOption> supportOptions = new List<SelectOption>();
        String options = Currency_Settings__c.getAll().get(currencyIsoCode).Support_Picklist_Values__c;
        
        if(options != null && Currency_Settings__c.getAll().get(currencyIsoCode).Support_Picklist_Values2__c != null)
            options += Currency_Settings__c.getAll().get(currencyIsoCode).Support_Picklist_Values2__c;
        
        if(options != null)
        {
            for(String eachVal : options.split(','))
            {
                SelectOption newOption = new SelectOption(eachVal, eachVal);
                supportOptions.add(newOption);  
            }
        }
        return supportOptions;
    }
    
    
}