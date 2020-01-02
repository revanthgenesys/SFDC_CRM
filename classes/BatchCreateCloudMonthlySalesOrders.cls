global class BatchCreateCloudMonthlySalesOrders implements Database.Batchable<SObject>,Database.Stateful
    {    
        // Line Count
        @TestVisible
        private Integer intLineCount;
        private Integer intLineCountSubscription;
        public final static String REVENUE_CLASSIFICATION_NOT_APPLICABLE = 'Not Applicable';
        public final static String REVENUE_CLASSIFICATION_COMMITTED = 'Committed';
        public final static String REVENUE_CLASSIFICATION_OVERAGE = 'Overage';
        public final static String REVENUE_CLASSIFICATION_UNCOMMITTED = 'Uncommitted';
    
        public final static String POB_CLOUD_COMMITTED = 'Cloud-Committed';
        public final static String POB_CLOUD_UNCOMMITTED = 'Cloud-Uncommitted';
        public final static String POB_CLOUD_RAMP_UNCOMMITTED = 'Cloud-Ramp-Uncommitted';
        public final static String POB_PREMISE_COMMITTED= 'Premise Subscription - Committed';
        public final static String POB_PREMISE_UNCOMMITTED = 'Premise Uncommitted - Usage';
        public final static String POB_NOT_APPLICABLE = 'Not Applicable';
    
        // Prebill?
        public Boolean blnPreBill;
        // Day for which Orders are to be processed
        public final String strDay;
        // Month for which Orders are to be processed
        public final String strMonth;
        // Year for which Orders are to be processed
        public final String strYear;

        // Contract Id (Optional) : To specify individual contract for which Order needs to be processed
        public final String strContractId;
        // Name of subsidiary chosen to run job by subsidiary
        public final String strSubsidiary;
        // Region
        public final String strRegion;
        // Edition
        public final String strEdition;
        // Log Record for this job
        public Cloud_Billing_Log__c objJobLog;
        // Currency Conversion Rates
        @TestVisible
        Map<String,Decimal> map_ConversionRates;
        // Global map to store Platform Id to Cloud Deployment
        Map<String, Cloud_Deployment__c> mapCloudDeploymentHashToCloudDeployment;
         @TestVisible//Global list of Quote product ids  and quantity that are bursted
        Map<BigMachines__Quote_Product__c,decimal> map_BurstedProduct =  new  map<BigMachines__Quote_Product__c,decimal>();
         @TestVisible//Map that contains contract Tier Set to the bursted qunatity 
        Map<ID,Decimal> map_BurstContractTierSet = new Map<ID,Decimal>();
         @TestVisible//Map that contains contract Tier Set to the Set Price of Products 
        Map<ID,Decimal> map_BurstContractTierSetPrice = new Map<ID,Decimal>();
        
        //list of quote products and quantities
        list<BigMachines__Quote_Product__c> list_quoteProducts;
        
        map<BigMachines__Quote_Product__c,decimal> map_QProdtoQuantity;
        Public List<Order_Line_Item__c> list_OrderLineItemsForBase = new List<Order_Line_Item__c>();
        String strBaseQuantityAndPrice;
        //String to store offering Type
        Static String strofferingType;
        //String to store Quote Pricing Model
        Static String strPricingModel;
        @TestVisible//Map that contains Id to Quote Product
        map<id,BigMachines__Quote_Product__c> map_IDToQproducts;
        private CloudBillingData objInfo;
        private Product2 objInboundHairpinProduct;
        public static String CLOUD_DEPLOYMENT_BREAKOUT_INVOICE_TYPE = 'Cloud Deployment Breakout';
        private static Boolean blnUseBillingConversionRate = Label.Cloud_Billing_Use_Billing_Conversion_Rate.equalsIgnoreCase('true');
        
        public class NoCurrencyConversionException extends Exception {
        }
        
        private Map<Id, Decimal> mapTierSetIdToAmount;

        private Boolean blnInRamp;
        private Boolean blnOrderLastMonth;
        
        public Map<Id, Subscription__c> mapMasterOrderIdToActiveSubscription;

        public BatchCreateCloudMonthlySalesOrders(CloudBillingData info) {
            System.Debug('BatchCreateCloudMonthlySalesOrders: ctor start');
            blnOrderLastMonth = false;
            blnPreBill = info.blnIsPreBill;
            strSubsidiary = info.subsidiary;
            strEdition = info.edition;
            if (strEdition != null && CloudBillingUtil.isBillingLastMonth(strEdition)) {
                System.Debug('BatchCreateCloudMonthlySalesOrders: strEdition is last month ' + strEdition + ' set blnOrderLastMonth true');
                blnOrderLastMonth = true;
            }

            strContractId = info.contractId;
            if (strContractId != null) {
                System.Debug('BatchCreateCloudMonthlySalesOrders: User Requested Contract. Check That Contract for PCC and if so adjust by one month');
                GCR_Content_Document_Detail__c objContract = [select Product_Group__c from GCR_Content_Document_Detail__c where Id = :strContractId];
                String strContractProductGroup = objContract.Product_Group__c;
                if (strContractProductGroup != null && CloudBillingUtil.isBillingLastMonth(strContractProductGroup)) {
                    System.Debug('BatchCreateCloudMonthlySalesOrders: strContractProductGroup is last month ' + strContractProductGroup + ' set blnOrderLastMonth true');
                    blnOrderLastMonth = true;
                } else {
                    System.Debug('BatchCreateCloudMonthlySalesOrders: strContractProductGroup is this month ' + strContractProductGroup + ' set blnOrderLastMonth false');
                    blnOrderLastMonth = false;
                }
            }
            strRegion = info.region;
            objInfo = info;
            String strUseBillingConversionRate = Label.Cloud_Billing_Use_Billing_Conversion_Rate;
            System.Debug('BatchCreateCloudMonthlySalesOrders: blnUseBillingConversionRate ' + blnUseBillingConversionRate);
            System.Debug('BatchCreateCloudMonthlySalesOrders: blnOrderLastMonth ' + blnOrderLastMonth);
            if (blnOrderLastMonth) {
                // ECD Reduce the date information by one month
                System.Debug('BatchCreateCloudMonthlySalesOrders: info ' + info);
                Date dtRequestedDate = Date.newInstance(Integer.valueOf(info.year),Integer.valueOf(info.month),Integer.valueOf(info.day));
                Date dtLastMonthDate = dtRequestedDate.addMonths(-1);
                System.Debug('BatchCreateCloudMonthlySalesOrders: Requested Date ' + dtRequestedDate);
                System.Debug('BatchCreateCloudMonthlySalesOrders: Last Month Date ' + dtLastMonthDate);
                strDay = String.valueOf(dtLastMonthDate.day());
                strMonth = String.valueOf(dtLastMonthDate.month());
                strYear = String.valueOf(dtLastMonthDate.year());
            } else {
                strDay = info.day;
                strMonth = info.month;
                strYear = info.year;
            }
            System.Debug('BatchCreateCloudMonthlySalesOrders: strDay/strMonth/strYear ' + strDay + '/' + strMonth + '/' + strYear);
            System.Debug('BatchCreateCloudMonthlySalesOrders: ctor end');
        }
        
        // Cloud Billing based on contract start date.
        public static Set<Integer> addAllContractStartDates(Integer intYear, Integer intMonth, Integer intDay) {
            Date dtForDate = Date.newInstance(intYear, intMonth, intDay);
            Set<Integer> set_ContractStartDays = new Set<Integer>();
            // Always do contracts starting on the day requested
            set_ContractStartDays.add(intDay);
            
            //February
            if(dtForDate.month() == 2) {
                if (!Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 28) {
                    set_ContractStartDays.add(29);
                    set_ContractStartDays.add(30);
                    set_ContractStartDays.add(31);
                } else if (Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 29) {
                    set_ContractStartDays.add(30);
                    set_ContractStartDays.add(31);
                }
                // 30 day months
            } else if ((dtForDate.month() == 4 || dtForDate.month() == 6 || dtForDate.month() == 9 || dtForDate.month() == 11) &&
                       dtForDate.day() == 30
                      ){
                          set_ContractStartDays.add(31);
                      }
            System.Debug('set_ContractStartDays ' + set_ContractStartDays);
            return set_ContractStartDays;
        }
        
        // *** Start Method : Querying all Cloud Contracts (Quote reference present) with status 'Approved' ***
        global Database.QueryLocator start(Database.BatchableContext BC) 
        {              
            if(objJobLog == null)
                objJobLog = CloudBillingUtil.createNewCloudBillingLog('Monthly Order Creation', 'Submitted');
            
            objJobLog.Exceptions__c = (objJobLog.Exceptions__c == null) ? '':objJobLog.Exceptions__c;
            Set<Integer> set_ContractStartDays = addAllContractStartDates(Integer.valueOf(strYear),Integer.valueOf(strMonth),Integer.valueOf(strDay));
            Date dtFirstOfBillingMonth = Date.newInstance(Integer.valueOf(strYear),Integer.valueOf(strMonth),Integer.valueOf(strDay));
            Date dtLastOfBillingMonth = dtFirstOfBillingMonth.addDays(Date.daysInMonth(Integer.valueOf(strYear),Integer.valueOf(strMonth)) - 1);
            System.Debug('BatchCreateCloudMonthlySalesOrders.start dtFirstOfBillingMonth ' + dtFirstOfBillingMonth + ' dtLastOfBillingMonth ' + dtLastOfBillingMonth);
            
            // iTracks 21126 Add Quote__r.Sold_To_Name__c to query
            // iTracks 24752 Add Inbound_Billing_Type__c and Account_Name__r.SAP_Account_Code__c to query
            // iTracks 25080 Add Invoice_Type__c
            
            String strSOQL = 'SELECT Id,Name,Account_Name__c,Account_Name__r.Subsidary__c,Pricing_Start_Date__c,Pricing_End_Date__c,PO__c,'
                + 'Order_Date_Option__c,Quote__c,CurrencyISOCode,Quote__r.CurrencyISOCode, Quote__r.Order__r.Name,'
                + 'Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c,Quote__r.Order__r.Original_Parent_Order1__c,'
                + 'Quote__r.Order__c,'
                + ' Net_Days_Override__c, Direct_Sales_Rep_Override__c, Quote__r.Sold_To_Name__c, Quote__r.Sold_To_Name__r.Country__r.ISO_Code__c,' 
                + ' Inbound_Billing_Type__c, Account_Name__r.SAP_Account_Code__c, '
                + ' Outbound_Rate_Table_Discount__c, Invoice_Type__c, Account_Name_Override__c,Product_Group__c,'
                + ' Zuora_Quote__c, Zuora_Quote__r.CurrencyISOCode, Zuora_Quote__r.zqu__Opportunity__c, Zuora_Quote__r.zqu__Account__c,'
                + ' Ramp_Start_Date__c, Ramp_End_Date__c'
                + ' FROM GCR_Content_Document_Detail__c'
                + ' WHERE Document_Name__c = \'Cloud Billing Contract\' AND Status__c = \'Approved\'' +
                + ' AND Pricing_Start_Day__c in :set_ContractStartDays'
                + ' AND Pricing_Start_Date__c <= :dtLastOfBillingMonth AND'
                + ' (Pricing_End_Date__c = null OR Pricing_End_Date__c >= :dtFirstOfBillingMonth)';
            
            if(String.isNotBlank(strContractId))
                strSOQL += ' AND Id = :strContractId';
            else
                strSOQL += ' AND Manual_Review_Required__c != \'Yes\'';
            
            if(String.isNotBlank(strSubsidiary) && strSubsidiary != 'All')
                strSOQL += ' AND Account_Name__r.Subsidary__r.Name = :strSubsidiary';
            
            if(String.isNotBlank(strRegion) && strRegion != 'All')
                strSOQL += ' AND Account_Name__r.Country__r.Region__c = :strRegion';
            
            if(String.isNotBlank(strEdition) && strEdition != 'All') {
                System.debug('Adding strEdition:[' + strEdition + ']');
                strSOQL += ' AND Product_Group__c = :strEdition';
            }
            
            System.debug('<<< Batch Query : ' + strSOQL);
            return Database.getQueryLocator(strSOQL);
        }
        
        public Order_Line_Item__c createOLIOutboundRatingTable(GCR_Content_Document_Detail__c objContract,
                                                               Order__c objOrder, 
                                                               Contract_Tier_Set__c objContractTierSet,
                                                               List<Order_Line_Item__c> list_OrderLineItemsForTierSet,
                                                               Decimal decCount,
                                                               Decimal decTotalQuantity,
                                                               Decimal decTotalOutboundCallsCost,
                                                               String strCloudDeploymentInfo,
                                                               // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL) - Added By Vijay on Sep 1st
                                                               Decimal decSumCount)
        {
            if (decTotalQuantity == null) {
                decTotalQuantity = 0;
            }
            if (decTotalOutboundCallsCost == null) {
                decTotalOutboundCallsCost = 0;
            }
            
            System.debug(' : strCloudDeploymentInfo ' + strCloudDeploymentInfo);
            String strSystemNotes = 'Cost calculated using previous rated Outbound Rates.\n';
            // Create Order Line
            Order_Line_Item__c objOLI = createOrderLineItem(objContractTierSet, REVENUE_CLASSIFICATION_UNCOMMITTED);
            
            // Added By Vijay - Sep 1st 2017  - Start
            // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL)
            objOLI.Current_Qty__c = decSumCount;
            // Added By Vijay - Sep 1st 2017  - End
            
            list_OrderLineItemsForTierSet.add(objOLI);
            //Count - add a count to the OLI if the count is different from the total usage
            if (decCount > 0) {
                objOLI.Transation_Count__c = decCount;
            }
            objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = decTotalQuantity;
            objOLI.Memo__c = 'Based on Calling Rates';
            if (strCloudDeploymentInfo != null) {
                System.debug('createOLIOutboundRatingTable: Adding ' + strCloudDeploymentInfo + ' to Name');
                objOLI.Name = objOLI.Name + ' (' + strCloudDeploymentInfo + ')';
            }
            
            // Actual rate
            objOLI.Net_Unit_Price__c = null;
            // Total amount for the line
            objOLI.Ext_Net_Price__c = decTotalOutboundCallsCost;
            
            if(objOLI.Quantity__c != null && objOLI.Quantity__c != 0) {
                System.debug('Original objOLI.Ext_Net_Price__c ' +  objOLI.Ext_Net_Price__c);
                // Convert Currency Based on objOLI.Ext_Net_Price__c
                Decimal extNetPriceConverted = objOLI.Ext_Net_Price__c;
                System.Debug('objContractTierSet.Contract__r.Product_Group__c ' + objContractTierSet.Contract__r.Product_Group__c +
                             ' check against do not convert list [' + Label.Cloud_Billing_Offering_No_Currency_Conversion + ']');
                if (CloudBillingUtil.getSetOfStringsByCommaSeperated(Label.Cloud_Billing_Offering_No_Currency_Conversion).contains(objContractTierSet.Contract__r.Product_Group__c)) {
                    System.Debug('objContractTierSet.Contract__r.Product_Group__c ' + objContractTierSet.Contract__r.Product_Group__c +
                                 ' on do not convert list');
                    strSystemNotes +=  'Currency Already Converted\n';
                } else {
                    extNetPriceConverted = Util.convertCurrencyCustom('USD', objOrder.CurrencyISOCode, map_ConversionRates, objOLI.Ext_Net_Price__c);
                    System.Debug('Converted Currency to extNetPriceConverted ' + extNetPriceConverted);
                }
                if (extNetPriceConverted == 0 && objOLI.Ext_Net_Price__c != 0) {
                    
                    String strMsg = 'No Conversion Rate Available from USD to ' + objOrder.CurrencyISOCode;
                    objJobLog.Exceptions__c = strMsg;
                    System.debug(strMsg);
                    Throw new NoCurrencyConversionException(strMsg);
                }
                Decimal calculatedSalesPrice = extNetPriceConverted/objOLI.Quantity__c;
                Decimal calculatedSalesPriceTrunc = cloudRoundPriceFloor(calculatedSalesPrice);
                String note = 'Convert Total Price of ' + objOLI.Ext_Net_Price__c +
                    '.\nTo Converted Total Price of ' + extNetPriceConverted +
                    '.\nCalculated Sales price ' + calculatedSalesPrice + '.' +
                    '.\NTrunc Sales price ' + calculatedSalesPriceTrunc + '.';
                System.debug(note);
                strSystemNotes += note + '\n';
                System.debug('objOLI.Ext_Net_Price__c' + objOLI.Ext_Net_Price__c + '/objOLI.Quantity__c' + objOLI.Quantity__c + ' calculatedSalesPriceTrunc ' + calculatedSalesPriceTrunc);
                objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = calculatedSalesPriceTrunc;
                
                // iTracks 23650 Blanket Discount
                if (objContract.Outbound_Rate_Table_Discount__c != null && objContract.Outbound_Rate_Table_Discount__c != 0) {
                    System.debug('Apply Blank Discount of ' + objContract.Outbound_Rate_Table_Discount__c);
                    Order_Line_Item__c objOLIBlanketDiscount = createOrderLineItem(objContractTierSet, REVENUE_CLASSIFICATION_NOT_APPLICABLE);
                    list_OrderLineItemsForTierSet.add(objOLIBlanketDiscount);
                    objOLIBlanketDiscount.Quantity__c = objOLIBlanketDiscount.BigMachines_Quantity__c = 1;
                    objOLIBlanketDiscount.Memo__c = 'Blanket Discount of ' + objContract.Outbound_Rate_Table_Discount__c + '%';
                    if (!String.isEmpty(strCloudDeploymentInfo)) {
                        System.debug('createOLIOutboundRatingTable: Adding ' + strCloudDeploymentInfo + ' to Blanket Discount Name');
                        objOLIBlanketDiscount.Name = objOLIBlanketDiscount.Name + ' (' + strCloudDeploymentInfo + ')';
                    }
                    Decimal decBlanketDiscount = 0 - ((objOLI.Quantity__c * objOLI.Sales_Price__c * objContract.Outbound_Rate_Table_Discount__c) / 100);
                    Decimal decBlanketDiscountTrunc = cloudRoundPriceFloor(decBlanketDiscount);
                    String noteBlanketDiscount = 'Blanket Discount ' + decBlanketDiscount +
                        '.\nTruncated to ' + decBlanketDiscountTrunc;
                    objOLIBlanketDiscount.System_Notes__c = noteBlanketDiscount;
                    objOLIBlanketDiscount.Ext_Net_Price__c =
                        objOLIBlanketDiscount.Sales_Price__c =
                        objOLIBlanketDiscount.List_Price__c =
                        objOLIBlanketDiscount.Net_Unit_Price__c = decBlanketDiscountTrunc;
                }
            }
            objOLI.System_Notes__c = strSystemNotes;
            return objOLI;
        }
    
        public Order_Line_Item__c createOLIInboundRatingTable(GCR_Content_Document_Detail__c objContract,
                                                              Order__c objOrder, 
                                                              Contract_Tier_Set__c objContractTierSet,
                                                              List<Order_Line_Item__c> list_OrderLineItemsForTierSet,
                                                              Decimal decCount,
                                                              Decimal decTotalQuantity,
                                                              Decimal decTotalInboundCallsCost,
                                                              String strCloudDeploymentInfo,
                                                              // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL) - Added By Vijay on Sep 1st
                                                              Decimal decSumCount)
            
        {
            if (decTotalQuantity == null) {
                decTotalQuantity = 0;
            }
            if (decTotalInboundCallsCost == null) {
                decTotalInboundCallsCost = 0;
            }
            
            System.debug('createOLIInboundRatingTable: strCloudDeploymentInfo ' + strCloudDeploymentInfo);
            System.debug('Contract:'+objContract);
            System.debug('Attempt Inbound Rate Table Calculation');
            String strSystemNotes = 'Cost calculated using previous rated Inbound Rates.\n';
            // Create Order Line
            Order_Line_Item__c objOLI = createOrderLineItem(objContractTierSet, REVENUE_CLASSIFICATION_UNCOMMITTED);
            
            // Added By Vijay - Sep 1st 2017  - Start
            // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL)
            objOLI.Current_Qty__c = decSumCount;
            // Added By Vijay - Sep 1st 2017  - End
            
            list_OrderLineItemsForTierSet.add(objOLI);
            //Count - add a count to the OLI if the count is different from the total usage
            if (decCount > 0) {
                objOLI.Transation_Count__c = decCount;
            }
            
            objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = decTotalQuantity;
            objOLI.Memo__c = 'Based on Inbound Calling Rates';
            if (strCloudDeploymentInfo != null) {
                System.debug('createOLIInboundRatingTable: Adding ' + strCloudDeploymentInfo + ' to Name');
                objOLI.Name = objOLI.Name + ' (' + strCloudDeploymentInfo + ')';
            }
            
            // Actual rate
            objOLI.Net_Unit_Price__c = null;
            // Total amount for the line
            objOLI.Ext_Net_Price__c = decTotalInboundCallsCost;
            
            if(objOLI.Quantity__c != null && objOLI.Quantity__c != 0) {
                System.debug('Original objOLI.Ext_Net_Price__c ' +  objOLI.Ext_Net_Price__c);
                // Convert Currency Based on objOLI.Ext_Net_Price__c
                Decimal extNetPriceConverted = objOLI.Ext_Net_Price__c;
                System.Debug('objContractTierSet.Contract__r.Product_Group__c ' + objContractTierSet.Contract__r.Product_Group__c +
                             ' check against do not convert list [' + Label.Cloud_Billing_Offering_No_Currency_Conversion + ']');
                if (CloudBillingUtil.getSetOfStringsByCommaSeperated(Label.Cloud_Billing_Offering_No_Currency_Conversion).contains(objContractTierSet.Contract__r.Product_Group__c)) {
                    System.Debug('createOLIInboundRatingTable: objContractTierSet.Contract__r.Product_Group__c ' + objContractTierSet.Contract__r.Product_Group__c +
                                 ' on do not convert list');
                    strSystemNotes +=  'Currency Already Converted\n';
                } else {
                    extNetPriceConverted = Util.convertCurrencyCustom('USD', objOrder.CurrencyISOCode, map_ConversionRates, objOLI.Ext_Net_Price__c);
                    System.Debug('createOLIInboundRatingTable: Converted Currency to extNetPriceConverted ' + extNetPriceConverted);
                }
                if (extNetPriceConverted == 0 && objOLI.Ext_Net_Price__c != 0) {
                    
                    String strMsg = 'No Conversion Rate Available from USD to ' + objOrder.CurrencyISOCode;
                    objJobLog.Exceptions__c = strMsg;
                    System.debug(strMsg);
                    Throw new NoCurrencyConversionException(strMsg);
                }
                Decimal calculatedSalesPrice = extNetPriceConverted/objOLI.Quantity__c;
                Decimal calculatedSalesPriceTrunc = cloudRoundPriceFloor(calculatedSalesPrice);
                String note = 'Convert Total Price of ' + objOLI.Ext_Net_Price__c +
                    '.\nTo Converted Total Price of ' + extNetPriceConverted +
                    '.\nCalculated Sales price ' + calculatedSalesPrice + '.' +
                    '.\NTrunc Sales price ' + calculatedSalesPriceTrunc + '.';
                System.debug(note);
                strSystemNotes += note + '\n';
                System.debug('objOLI.Ext_Net_Price__c' + objOLI.Ext_Net_Price__c + '/objOLI.Quantity__c' + objOLI.Quantity__c + ' calculatedSalesPriceTrunc ' + calculatedSalesPriceTrunc);
                objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = calculatedSalesPriceTrunc;
                
            }
            objOLI.System_Notes__c = strSystemNotes;
            
            return objOli;
        }
    
        public static Boolean isActiveCommitmentShortfall(Contract_Tier_Set__c objContractTierSet) {
            System.Debug('isActiveCommitmentShortfall:objContractTierSet ' + objContractTierSet);
            for (Contract_Recurring_Charge__c objRecurringCharge : objContractTierSet.Contract_Recurring_Charges__r) {
                if (objRecurringCharge.Type__c == 'Commitment Shortfall') {
                    return true;
                }
            }
            return false;
        }
        
        // This method increases the line count whereas others do not
        public Decimal createOLIStandard(Contract_Tier_Set__c objContractTierSet,
                                         List<Order_Line_Item__c> list_OrderLineItemsForTierSet,
                                         String strSystemNotes,
                                         Decimal intCount,
                                         Decimal decTotalQuantityThisMonth,
                                         List<Contract_Tier_Set_Month__c> list_PreviousTierSetMonthsForThisOrder,
                                         Decimal decTierSetTotal,
                                         String strCloudDeploymentInfo,
                                         // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL) - Added By Vijay on Sep 1st
                                         Decimal decSumCount)
        {
            Decimal decTotalQuantityPrevMonths = CloudBillingUtil.getTotalQuantity(list_PreviousTierSetMonthsForThisOrder, objContractTierSet.Aggregation_Model__c);
            
            Boolean blnIsPreviousMonthRev = false;
            
            if (decTotalQuantityThisMonth == null)
                decTotalQuantityThisMonth = 0;
            
            if (decTotalQuantityPrevMonths == null)
                decTotalQuantityPrevMonths = 0;
            
            if (decTotalQuantityPrevMonths > 0)
                blnIsPreviousMonthRev = true;
            
            if (decTierSetTotal == null)
                decTierSetTotal = 0;
            
            System.debug('createOLIStandard: Tier Set Id ' + objContractTierSet.Id + ' strCloudDeploymentInfo ' + strCloudDeploymentInfo);
            System.debug('createOLIStandard: decTotalQuantityThisMonth ' + decTotalQuantityThisMonth +
                         ' decTotalQuantityPrevMonths ' + decTotalQuantityPrevMonths +
                         ' decTierSetTotal ' + decTierSetTotal);
            
            // Tier priced activity needs to be calculated
            Integer intRangeCounter = 0;
            Decimal decTotalQuantity = decTotalQuantityPrevMonths + decTotalQuantityThisMonth;
            Decimal decBasePackageUse = 0;
            
            Decimal decPreviousMonthToConsume = decTotalQuantityPrevMonths;
            Decimal decPreviousRangeHigh = 0;
            
            // Iterate through Tier Ranges as needed based on usage quantity. Consume previous month amounts first charging 0.
            for(Contract_Tier_Range__c objContTierRange : objContractTierSet.Contract_Tier_Ranges__r)
            {
                intRangeCounter++;
                // If we consume all of previous activty within this range, where we start counting current month quantity
                Decimal decStartRange = decPreviousRangeHigh;
                
                System.debug('createOLIStandard: Start Tier Range Loop decTotalQuantity ' + decTotalQuantity +
                             ' decPreviousMonthToConsume ' + decPreviousMonthToConsume +
                             ' objContTierRange.To__c ' + objContTierRange.To__c +
                             ' decStartRange ' + decStartRange);
    
                // Assume Committed unless later logic gets to overage which will be changed to uncommitted
                Order_Line_Item__c objOLI = createOrderLineItem(objContractTierSet, REVENUE_CLASSIFICATION_COMMITTED);
    
                system.debug('%%%%Group Edition:'+objContractTierSet);
                if(!objContractTierSet.Contract__r.Product_Group__c.contains('Subscription'))
                    objOLI.Current_Qty__c = decSumCount;
                
                // Consume Previous Month Quantity if there is quantity to consume
                if (decPreviousMonthToConsume > 0) 
                {
                    // Previous months push us past this whole range.
                    if (decPreviousMonthToConsume >= objContTierRange.To__c) 
                    {
                        //Reduce the amount to consume
                        decPreviousMonthToConsume -= objContTierRange.To__c;
                        //Mark the cursor as to the progress we have made
                        decPreviousRangeHigh = objContTierRange.To__c;
                        System.debug('createOLIStandard: Previous exceeds current Tier Range. Consume ' + objContTierRange.To__c +
                                     ' with remaining ' + decPreviousMonthToConsume);
                        continue;
                    } 
                    else 
                    {
                        decStartRange = decTotalQuantityPrevMonths;
                        System.debug('createOLIStandard: Previous within current Tier Range. Consume all ' + decPreviousMonthToConsume);
                        decPreviousMonthToConsume = 0;
                    }
                    System.debug('createOLIStandard: After consume previous month decTotalQuantity ' + decTotalQuantity +
                                 ' decPreviousMonthToConsume ' + decPreviousMonthToConsume +
                                 ' objContTierRange.To__c ' + objContTierRange.To__c +
                                 ' decStartRange ' + decStartRange);
                }
                
                objOLI.System_Notes__c = strSystemNotes;
    
                Boolean blnIsSubscription = objContractTierSet.Contract__r.Product_Group__c.contains('Subscription');
                
                // if more than 1 range then terminology used is standard/overage usage otherwise just usage for memo
                if(intRangeCounter == 1) {
                    objOLI.Memo__c = objContractTierSet.Contract_Tier_Ranges__r.size() > 1 ? 'Standard Usage' : 'Usage';
                    Boolean blnActiveCommitmentShortfall = isActiveCommitmentShortfall(objContractTierSet);
                    if (objContTierRange.Price__c > 0 && !blnActiveCommitmentShortfall) {
                        objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_UNCOMMITTED;
                        if (!blnIsSubscription) {
                            objOLI.POB_Type__c = POB_CLOUD_UNCOMMITTED;
                        }
                    }
                }
                else 
                {
                    objOLI.Memo__c = 'Overage Usage';
                    //Anju April 20 : for subscription name should end with 'Burst' while for others 'Overage'
                    if(!blnIsSubscription)
                    {
                        objOLI.Name = objOLI.Name + ' Overage';
                        objOLI.Description__c = objOLI.Description__c + ' Overage';
                        // If the first tier is priced at 0, then the activity it overage.
                        // If both first and other tiers are priced non-zero, simply uncommited
                        if (objContractTierSet.Contract_Tier_Ranges__r[0].Price__c == 0) {
                            objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_OVERAGE;
                        } else {
                            objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_UNCOMMITTED;
                        }
                        // In all cases we are uncommitted whether uncommitted or overage
                        objOLI.POB_Type__c = POB_CLOUD_UNCOMMITTED;
                    }
                    else
                    {
                        objOLI.Name = objOLI.Name + ' Burst';
                        objOLI.Year__c = 1;
                        objOLI.Description__c = objOLI.Description__c + ' Burst';
                        objOLI.POB_Type__c = POB_PREMISE_UNCOMMITTED;
                    }
                }
                
                if(strCloudDeploymentInfo != null) 
                {
                    System.debug('createOLIStandard: Adding ' + strCloudDeploymentInfo + ' to Name');
                    objOLI.Name = objOLI.Name + ' (' + strCloudDeploymentInfo + ')';
                }
                
                // The remaining quantity within this tier set we can consume before we need to go to the next range
                Decimal decRemainingQuantity = objContTierRange.To__c - decStartRange;
                
                //Consume all in this tier set and we will need to consume more in the next tier set.
                if((decTotalQuantity-decStartRange) > decRemainingQuantity) 
                {
                    System.debug('createOLIStandard: Consume all of the remaining quantity in this Range');
                    objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = decRemainingQuantity;
                    //Anju adding up usage for PES and PCS to create a single order line for monthly order for overage
                    if(intRangeCounter > 1)
                        decBasePackageUse += decRemainingQuantity;
                    decPreviousRangeHigh = objContTierRange.To__c;
                } 
                else 
                {
                    System.debug('createOLIStandard: decTotalQuantity is less than range high so we will not need the next range');
                    objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = decTotalQuantity - decStartRange;
                    //Anju adding up usage for PES and PCS to create a single order line for monthly order for overage
                    if(intRangeCounter > 1)
                        decBasePackageUse += objOLI.Quantity__c;
                    // Remember where we were at the end of this range
                }
                
                System.Debug('createOLIStandard: After consume this month decTotalQuantity: decTotalQuantity ' + decTotalQuantity +
                             ' decTotalQuantityThisMonth ' + decTotalQuantityThisMonth +
                             ' objContTierRange.To__c ' + objContTierRange.To__c +
                             ' decStartRange ' + decStartRange +
                             ' decRemainingQuantity ' + decRemainingQuantity +
                             ' decPreviousRangeHigh ' + decPreviousRangeHigh);
                // Rate
                objOLI.Net_Unit_Price__c = objContTierRange.Price__c;
                // Total Amount
                system.debug(objOLI.Quantity__c + '' + objOLI.Net_Unit_Price__c);
                objOLI.Ext_Net_Price__c = objOLI.Quantity__c * objOLI.Net_Unit_Price__c;
                system.debug(objOLI.Ext_Net_Price__c);
                
                if(objOLI.Quantity__c != null && objOLI.Quantity__c != 0)
                    objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.Quantity__c);
                
                //Count - add a count to the OLI if the count is different from the total usage
                if (intRangeCounter == 1 && intCount > 0) 
                    objOLI.Transation_Count__c = intCount;
                
                decTierSetTotal += objOLI.Ext_Net_Price__c;
                
                //Anju Merge counts for Subscription tier ranges : eg, if original quanitty is 100, usage is 130 and at Tier 3, only one line with 30 qty should be created
                if(objContractTierSet.Contract__r.Product_Group__c != null && objContractTierSet.Contract__r.Product_Group__c.contains('Subscription') && intRangeCounter == 3)
                {
                    map_BurstedProduct.put(map_IDToQproducts.get(objContractTierSet.Quote_Product__r.id),decTotalQuantityThisMonth - decStartRange);
                    map_BurstContractTierSet.put(objContractTierSet.id,decTotalQuantityThisMonth - decStartRange);
                    map_BurstContractTierSetPrice.put(objContractTierSet.id,objContTierRange.Price__c);
                }
                // Add Order Line only if customer is to be billed for it i.e. there is some Sales Price. Display lines with Standard Usage
                if((objOLI.Sales_Price__c != null && objOLI.Sales_Price__c != 0) || (objOLI.Memo__c != 'Usage'))
                {
                    if(!objContractTierSet.Contract__r.Product_Group__c.contains('Subscription'))
                        list_OrderLineItemsForTierSet.add(objOLI);
                    //Anju Merge counts for Subscription tier ranges : eg, if original quanitty is 100, usage is 130 and at Tier 3, only one line with 30 qty should be created
                    else if(objContractTierSet.Contract__r.Product_Group__c != null && objContractTierSet.Contract__r.Product_Group__c.contains('Subscription') && (decTotalQuantityThisMonth + decTotalQuantityPrevMonths) <= objContTierRange.To__c){
                        objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = decBasePackageUse;
                        
                        if(objOLI.Memo__c != 'Standard Usage') 
                            list_OrderLineItemsForTierSet.add(objOLI);
                        
                        //Assigning bundle amouont to package amount field of bundle product
                        objOLI.Ext_Net_Price__c = objOLI.Base_Package__c = objOLI.Quantity__c * objOLI.Net_Unit_Price__c;
                        system.debug(objOLI.Base_Package__c + '' + objOLI.Net_Unit_Price__c);
                        
                        //Anju Base package lines : If PES or PCS base package is bursting, all package lines should be added as order lines
                        if(objOLI.name.contains('PureEngage Base Package') || objOLI.name.contains('PureConnect Base Package'))
                        {
                            
                            //Bundle product's price should be 0 and should be split to lines..
                            objOLI.Net_Unit_Price__c = objOLI.Ext_Net_Price__c = 0;
                            objOLI.line_number__c = 1;
                            if(objOLI.Quantity__c != null && objOLI.Quantity__c != 0)
                                objOLI.Sales_Price__c = 0;
                            //Creating order lines for bundle lines of base package
                            createBasePackageLinesforOrder(objContractTierSet, objOLI.Base_Package__c, objOLI.Quantity__c);
                            strBaseQuantityAndPrice = objContTierRange.Price__c+':'+(decTotalQuantityThisMonth - decStartRange);
                        }
                        else
                        {
                            objOLI.line_number__c = null;
                        }
                    }
                }
                
                
                // Don't go to next range if quantity is less than or equal to current range high
                if((decTotalQuantityThisMonth + decTotalQuantityPrevMonths) <= objContTierRange.To__c) 
                {
                    System.debug('createOLIStandard: Done ' + (decTotalQuantityThisMonth + decTotalQuantityPrevMonths) +
                                 ' does not exceed Tier Range Max ' + objContTierRange.To__c);
                    break;
                }
                // We've consumed all of this range and there is more. Remember where we were
                decPreviousRangeHigh = objContTierRange.To__c;
            }
            System.debug('createOLIStandard: Check for Lookback');
            
            // If Lookback, discount all the previous tiers usage (use the rate from the range applicable for all previous ranges)
            if(objContractTierSet.Aggregation_Model__c == 'Lookback' && list_OrderLineItemsForTierSet.size() > 1)
            {
                Decimal decApplicableRate = list_OrderLineItemsForTierSet[list_OrderLineItemsForTierSet.size() - 1].Net_Unit_Price__c;
                decTierSetTotal = 0;
                for(Order_Line_Item__c objOLI : list_OrderLineItemsForTierSet)
                {
                    objOLI.System_Notes__c += 'Lookback Aggregation Model used to calculate cost.\n';
                    objOLI.Net_Unit_Price__c = decApplicableRate;
                    objOLI.Ext_Net_Price__c = objOLI.BigMachines_Quantity__c = objOLI.Quantity__c * objOLI.Net_Unit_Price__c;
                    system.debug(objOLI.Ext_Net_Price__c);
                    if(objOLI.Quantity__c != null && objOLI.Quantity__c != 0)
                        objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.Quantity__c);
                    
                    decTierSetTotal += objOLI.Ext_Net_Price__c;
                }
            }
            
            return decTierSetTotal;
        }
        
        
        public Integer intTierSetPeriod(Contract_Tier_Set__c objContractTierSet) {
            if (objContractTierSet.Period_In_Months__c == null) {
                return 1;
            }
            return Integer.valueOf(objContractTierSet.Period_In_Months__c);
        }
        
        // *** Execute Method : Processing contracts and service usage info to create Orders for specified month/year (default batch size = 200) ***
        global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
        {
            //ECD
            // Consolidate setting of Trigger flags
            // Retaining comments from below in code:
            // Util.Bypass_Trigger_Chk: Setting this flag to avoid trigger executions
            // Util.blnRunPPUTrigger: Set flag so that trigger logic to populate order total based on line amounts is executed
            // TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL: Force running of the trigger to update the order's Total_Order__c after inserting new Order Line Items
            //Util.Bypass_Trigger_Chk = Util.blnRunPPUTrigger = TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL = true;
            
            objInfo.debug();
            System.Debug('Number of Contracts for which to make an Order ' + sObjects.size());
            
            // DB Save-point
            Savepoint objSP = Database.setSavepoint();
            try 
            {
                // Storing contract records to be processed in current batch
                List<GCR_Content_Document_Detail__c> list_BatchContracts = (List<GCR_Content_Document_Detail__c>)sObjects;
                System.debug('Order creation query returned ' + list_BatchContracts.size() + ' rows');    
                // List of Contracts for which orders need to be created
                List<GCR_Content_Document_Detail__c> list_Contracts = new List<GCR_Content_Document_Detail__c>();
                // List of Orders to be created/inserted
                List<Order__c> list_OrdersToCreate = new List<Order__c>();
                // List of Orders to be deleted
                List<Order__c> list_OrdersToDelete = new List<Order__c>();
                // List of Order Addressees to be deleted
                List<Account_Order_Address__c> list_OrdersAddressesToDelete = new List<Account_Order_Address__c>();
                // List of List or Order Lines to be created/inserted : stored in same order as orders to be inserted
                List<List<Order_Line_Item__c>> list_OrderLineItemLists = new List<List<Order_Line_Item__c>>();
                
                // Map of Contract Id To Order
                Map<Id,List<Order__c>> map_ContractIdToListOrders = new Map<Id,List<Order__c>>();
                // Map of Contract Id To List of Tier Sets under it
                Map<Id,List<Contract_Tier_Set__c>> map_ContractIdToTierSets = new Map<Id,List<Contract_Tier_Set__c>>();
                // Map of Contract Id To Billing Address associated with the quote/contract
                Map<Id,Account_Order_Address__c> map_ContractIdToBillingAddress = new Map<Id,Account_Order_Address__c>();
                Map<Id,String> map_ContractIdToCompanyNameOverride = new Map<Id,String>();
                // iTracks 25634 
                // Save a list of Orders that need Business Care applied afeter completing the Order Line Totals
                List<Order__c> list_OrdersWithBusinessCare = new List<Order__c>();
                // Map from Order to the Business Care Recurring Charge
                Map<Order__c, Contract_Recurring_Charge__c> map_OrderBusinessCareRecurringCharge = new Map<Order__c, Contract_Recurring_Charge__c>();
                
                // Fetch Orders for specified month and contracts in this batch and creating map of Contract Id to Order
                for(Order__c objOrder : [SELECT Id,Contract_Lookup__c,Status__c,
                                         (SELECT Id FROM Account_Order_Addresses__r)
                                         FROM Order__c WHERE Contract_Lookup__c IN :list_BatchContracts AND Month__c = :objInfo.month AND Year__c = :objInfo.year])
                {
                    if ((map_ContractIdToListOrders.containsKey(objOrder.Contract_Lookup__c))) {
                        List<Order__c> listOrders = map_ContractIdToListOrders.get(objOrder.Contract_Lookup__c);
                        listOrders.add(objOrder);
                    } else {
                        List<Order__c> listOrders = new List<Order__c>();
                        listOrders.add(objOrder);
                        map_ContractIdToListOrders.put(objOrder.Contract_Lookup__c, listOrders);
                    }
                }
                
                list<id> list_quoteIds = new list<id>();
                List<Id> list_masterOrderIds = new list<id>();
                // Iterating through batch of Contracts
                for(GCR_Content_Document_Detail__c objContract : list_BatchContracts)
                {
                    System.debug('Contract Id: ' + objContract.Id + ' ' + objContract.Name);
                    list_quoteIds.add(objContract.quote__c);
                    list_masterOrderIds.add(objContract.quote__r.Order__c);
                    // Skip processing this contract if its start day is not the day requested in the UI
                    if (objContract.Pricing_Start_Date__c.day() != Integer.valueOf(strDay)) {
                        System.debug('Contract id ' + objContract.Id + ' has start date ' + objContract.Pricing_Start_Date__c + ' so do not process');
                        continue;
                    }
                    list_Contracts.add(objContract);
                }
                
                mapMasterOrderIdToActiveSubscription = CloudBillingUtil.getMapMasterOrderIdToActiveSubscription(list_masterOrderIds);
/*
                List<Order__c> listMasterOrders = [select Id,
                                                   (select Start_Date__c from Subscriptions__r where Status__c = 'Active' Order By CreatedDate desc) // ciritcal as the [0] element will be the one
                                                   from Order__c where Id in :list_masterOrderIds];
                for (Order__c objMasterOrder : listMasterOrders) {
                    if (objMasterOrder.Subscriptions__r != null && objMasterOrder.Subscriptions__r.size() > 0) {
                        mapMasterOrderIdToActiveSubscription.put(objMasterOrder.Id, objMasterOrder.Subscriptions__r[0]);
                    }
                }
*/                
                list_QuoteProducts = [select ID,Product__c,BigMachines__Quote__r.BigMachines__Opportunity__c,BigMachines__Quantity__c,Bundle__c,
                                      Bundle_Line__c,BigMachines__Quote__r.Overage_Allowance_Other__c,BigMachines__Quote__r.Overage_Allowance__c
                                      from BigMachines__Quote_Product__c
                                      where BigMachines__Quote__c in :list_quoteIds];
                map_IDToQproducts= new map <id,BigMachines__Quote_Product__c>(list_QuoteProducts);
                map_QProdtoQuantity = new  map<BigMachines__Quote_Product__c,decimal> ();         
                for(BigMachines__Quote_Product__c objQP:list_QuoteProducts){
                    map_QProdtoQuantity.put(objQP,objQP.BigMachines__Quantity__c);
                }  
                
                // Creating Map of Contract Id to Billing address using the quote common linkage. This is needed for Order addresses.
                if(!list_Contracts.isEmpty())
                {
                    // Fetching addresses related to quotes associated with Contracts to be processed
                    for(Account_Order_Address__c objBillingAddress : [SELECT Id, GCR_Content_Document_Detail__c,Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                                                      Zip_Code__c, Phone__c, Fax__c, Email__c,Additional_Emails__c, GCR_Content_Document_Detail__r.Account_Name_Override__c
                                                                      FROM Account_Order_Address__c WHERE
                                                                      //Nitin Update the filter condition
                                                                      //Quote__c IN :set_QuoteIds
                                                                      GCR_Content_Document_Detail__c IN :list_Contracts 
                                                                      and Address_Type__c = 'Bill To'])
                    {
                        System.Debug('Add address ' + objBillingAddress);
                        map_ContractIdToBillingAddress.put(objBillingAddress.GCR_Content_Document_Detail__c,objBillingAddress);
                        if (objBillingAddress.GCR_Content_Document_Detail__r.Account_Name_Override__c != null) {
                            map_ContractIdToCompanyNameOverride.put(objBillingAddress.GCR_Content_Document_Detail__c, objBillingAddress.GCR_Content_Document_Detail__r.Account_Name_Override__c);
                        }
                    }
                }
                Date dtFirstOfBillingMonth = Date.newInstance(Integer.valueOf(strYear),Integer.valueOf(strMonth),1);
                map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(dtFirstOfBillingMonth, blnUseBillingConversionRate);
                
                Set<String> setCloudDeploymentHashes = new Set<String>();
                Set<Id> setContractTierSetMultiMonth = new Set<Id>();
                Set<Id> setContractTierSetPeriodsMultiMonth = new Set<Id>();
                Set<Id> set_ContractTierSetMonthIds = new Set<Id>();
                // Fetching Contracts information using Tier Set as Parent and creating map of Contract Id to it's Tier Sets
                System.debug('Entering Contract Tier Set Loop strMonth ' + strMonth + ' strYear ' + strYear);
                // iTracks 25634 add Business_Care_Min_Revenue_Threshold__c, Business_Care_Max_Revenue_Threshold__c, Business_Care_Support_Fee_Percentage__c
                // iTracks 25634 Total_Inbound_Calls_Cost__c
                // iTracks 25080 remove LIMIT 1 on Contract_Tier_Set_Month__r subquery. Also select Source_Name__c, Platform_Id__c
                for(Contract_Tier_Set__c objContractTierSet : [SELECT Id,Name,Aggregation_Model__c,Contract__c,Product__c,Quote_Product__c,Quote_Product__r.id,
                                                               Quote_Product__r.BigMachines__Quote__r.Overage_Allowance_Other__c,Quote_Product__r.BigMachines__Quote__r.Overage_Allowance__c,
                                                               Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Period_In_Months__c, Product__r.SureTax_Code_Undetermined__c,
                                                               Contract__r.Account_Name__r.Subsidary__r.Name, Contract__r.Product_Group__c,Contract__r.Quote__r.offering_type__c,
                                                               Contract__r.Quote__r.Pricing_Model__c,
                                                               (SELECT Id, To__c,From__c,Price__c FROM Contract_Tier_Ranges__r WHERE Is_Deleted__c = false ORDER BY From__c),
                                                               (SELECT Contract_Tier_Set__c,Contract_Tier_Set__r.RC_Period__c,Units__c,Amount__c,Type__c, External_Note__c,Pre_Bill__c,
                                                                Business_Care_Min_Revenue_Threshold__c, Business_Care_Max_Revenue_Threshold__c, Business_Care_Support_Fee_Percentage__c,
                                                                Deferred__c, Contract_Tier_Set__r.Period_In_Months__c, Quantity__c, Rate__c
                                                                FROM Contract_Recurring_Charges__r 
                                                                WHERE Active__c = true AND Is_Deleted__c = false),
                                                               (SELECT Id, Total_Usage__c,Total_Outbound_Calls_Cost__c, Total_Inbound_Calls_Cost__c,
                                                                Max_Usage__c,Max_Usage_AP__c,Max_Usage_EU__c,Max_Usage_US__c, Source_Name__c, Platform_Id__c,
                                                                Contract_Tier_Set_Period__c, Sum_Count__c, Sum_Usage__c
                                                                FROM Contract_Tier_Set_Month__r 
                                                                WHERE Month__c = :strMonth AND Year__c = :strYear),
                                                               (SELECT Parent_Quantity__c,Related_Quantity__c,Related_Tier_Set__c,Prorate__c FROM BOGO_Details__r
                                                                WHERE Is_Deleted__c = false)
                                                               FROM Contract_Tier_Set__c WHERE Contract__c IN :list_Contracts AND Is_Deleted__c = false
                                                               ORDER BY Name])
                {
                    // Multi-Month Usage
                    Integer intPeriodInMonths = intTierSetPeriod(objContractTierSet);
                    if (intPeriodInMonths > 1) {
                        System.Debug('MultiPeriod: Attempt adding for Tier Set [' + objContractTierSet.Name + '] months: ' + objContractTierSet.Contract_Tier_Set_Month__r);
                        for (Contract_Tier_Set_Month__c objCTSM : objContractTierSet.Contract_Tier_Set_Month__r) {
                            if (!setContractTierSetPeriodsMultiMonth.contains(objCTSM.Contract_Tier_Set_Period__c)) {
                                System.Debug('MultiPeriod: Adding for Tier Set [' + objContractTierSet.Name + ']');
                                setContractTierSetPeriodsMultiMonth.add(objCTSM.Contract_Tier_Set_Period__c);
                                setContractTierSetMultiMonth.add(objContractTierSet.Id);
                            }
                            set_ContractTierSetMonthIds.add(objCTSM.Id);
                        }
                    }
                    for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                        String strCloudHash = objContractTierSetMonth.Source_Name__c + '#' + objContractTierSetMonth.Platform_Id__c;
                        if (!setCloudDeploymentHashes.contains(strCloudHash)) {
                            System.Debug('Add Cloud Deployment Hash ' + strCloudHash);
                            setCloudDeploymentHashes.add(strCloudHash);
                        }
                        set_ContractTierSetMonthIds.add(objContractTierSetMonth.Id);
                    }
                    System.debug('$$$ ' + objContractTierSet.Contract_Tier_Set_Month__r);
                    if(map_ContractIdToTierSets.containsKey(objContractTierSet.Contract__c))
                        map_ContractIdToTierSets.get(objContractTierSet.Contract__c).add(objContractTierSet);
                    else
                        map_ContractIdToTierSets.put(objContractTierSet.Contract__c,new List<Contract_Tier_Set__c>{objContractTierSet});
                }
                
                System.debug('set_ContractTierSetMonthIds : '+set_ContractTierSetMonthIds);
                // Added Contract Trier Set Month Charges for Tax amount and description code. - Vijay Jul 11th 2017 - Start
                // Query Contract Tier Set Month Charges with set of TierSetMonthIds
                List<Contract_Tier_Set_Month_Charges__c> list_ContractTierSetMonthCharges =  [SELECT Id, Amount__c, Contract_Tier_Set_Month__c, Description__c,
                                                                                              Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c,
                                                                                              Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Product__c,
                                                                                              Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__r.Product_Group__c,
                                                                                              Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Product__r.APN_Number__c
                                                                                              FROM Contract_Tier_Set_Month_Charges__c 
                                                                                              WHERE Contract_Tier_Set_Month__c = :set_ContractTierSetMonthIds];
                System.debug('list_ContractTierSetMonthCharges : '+list_ContractTierSetMonthCharges);
                
                Map<id, Map<String, Contract_Tier_Set_Month_Charges__c>> map_CTSMCbyTaxCode 
                    = new Map<id, Map<String, Contract_Tier_Set_Month_Charges__c>>();
                for(Contract_Tier_Set_Month_Charges__c objCTSMC : list_ContractTierSetMonthCharges){
                    String strTaxAPNprefix = 'PEC';
                    if (objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__r.Product_Group__c != null &&
                        objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__r.Product_Group__c.contains('PureConnect')) {
                            strTaxAPNprefix = 'PCC';
                            System.Debug('Change Tax Prefix to ' + strTaxAPNprefix);
                        } else {
                            System.Debug('Keep Tax Prefix ' + strTaxAPNprefix);
                        }
                    String strSureTaxProductAPN = CloudBillingUtil.getSureTaxProductAPNFromResponseCode(objCTSMC.Description__c, strTaxAPNprefix);
                    if (String.isBlank(strSureTaxProductAPN)) {
                        String strException = 'Tax Code ' + objCTSMC.Description__c + ' has no APN Number in settings';
                        if (String.isBlank(objJobLog.Exceptions__c)) objJobLog.Exceptions__c = strException;
                        else objJobLog.Exceptions__c += ',' + strException;
                    }
                    System.debug('objCTSMC.Description__c:' + objCTSMC.Description__c + ' strTaxDescription :'+strSureTaxProductAPN);
                    System.debug('!map_CTSMCbyTaxCode.containsKey(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__c) : '+!map_CTSMCbyTaxCode.containsKey(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__c));
                    if(!map_CTSMCbyTaxCode.containsKey(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c)){
                        System.debug('Creating new map for contract ' + objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c);
                        Map<String, Contract_Tier_Set_Month_Charges__c> mapProductAPNToCTSMC =
                            new Map<String, Contract_Tier_Set_Month_Charges__c>{strSureTaxProductAPN => objCTSMC};
                                //private Map<String, Contract_Tier_Set_Month_Charges__c> mapTaxDescToContractTierSetCharge;
                                map_CTSMCbyTaxCode.put(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c,
                                                       mapProductAPNToCTSMC);                        
                    }else{
                        System.debug('Using old map for contract ' + objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c);
                        if(!map_CTSMCbyTaxCode.get(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c).containsKey(strSureTaxProductAPN)){
                            map_CTSMCbyTaxCode.get(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c).put(strSureTaxProductAPN,objCTSMC);
                        }else {
                            map_CTSMCbyTaxCode.get(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c).get(strSureTaxProductAPN).Amount__c += objCTSMC.Amount__c;
                        }
                    }   
                    System.debug('Charge Tax Sum Amount by Group :'+map_CTSMCbyTaxCode.get(objCTSMC.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__c).get(strSureTaxProductAPN).Amount__c);
                }
                //Get Products related to Taxes
                Set<String> setProductAPNs = new Set<String>();
                for (Id contractId : map_CTSMCbyTaxCode.keySet()) {
                    Map<String, Contract_Tier_Set_Month_Charges__c> map_ContractIdTaxCodes = map_CTSMCbyTaxCode.get(contractId);
                    for (String strTaxGrouping : map_ContractIdTaxCodes.keySet()) {
                        // ECD Tax append PEC/PCC here
                        setProductAPNs.add(strTaxGrouping);
                    }
                }
                
                Map<String, Product2> map_ProductAPNToProduct = CloudBillingUtil.getMapOfferingAPNNumberToProduct(setProductAPNs);//new Map<String, Product2>();
                
                mapCloudDeploymentHashToCloudDeployment = CloudBillingUtil.getMapCloudDeploymentfromHashes(setCloudDeploymentHashes);
                
                List<Contract_Tier_Set__c> list_ContractTierSetMultiPeriod = null;
                Map<Id, Contract_Tier_Set__c> map_ContractTierSetToPeriodMultiMonth = new Map<Id, Contract_Tier_Set__c>();
                if (!setContractTierSetPeriodsMultiMonth.isEmpty()) {
                    list_ContractTierSetMultiPeriod = [select (select Id, Name, Total_Usage__c,Total_Outbound_Calls_Cost__c, Total_Inbound_Calls_Cost__c,
                                                               Max_Usage__c,Max_Usage_AP__c,Max_Usage_EU__c,Max_Usage_US__c, Source_Name__c, Platform_Id__c,
                                                               Month__c, Year__c
                                                               from Contract_Tier_Set_Month__r
                                                               where Contract_Tier_Set_Period__c in :setContractTierSetPeriodsMultiMonth
                                                               order by Month_Year_Date__c)
                                                       from Contract_Tier_Set__c
                                                       where Id in :setContractTierSetMultiMonth];
                    System.Debug('list_ContractTierSetMonthMultiPeriod: got list size ' + list_ContractTierSetMultiPeriod.size());
                    for (Contract_Tier_Set__c objCTSM : list_ContractTierSetMultiPeriod) {
                        map_ContractTierSetToPeriodMultiMonth.put(objCTSM.Id, objCTSM);
                    }
                }
    
                Map<Id, List<Billing_Setup_Commitment__c>> mapContractIdToListBillingCommitments = new Map<Id, List<Billing_Setup_Commitment__c>>();
                Set<Id> setTierSetsInCommitments = new Set<Id>();
                List<Billing_Setup_Commitment__c> listBillingAllCommitments = [
                    SELECT Id, Name, Billing_Setup__c, Committed_Amount__c, Description__c,
                    Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c,
                    (SELECT Billing_Setup_Tier_Set__c from Billing_Setup_Commitment_Tier_Sets__r)
                    FROM Billing_Setup_Commitment__c
                    WHERE Billing_Setup__c in :list_Contracts
                ];
                for (Billing_Setup_Commitment__c objBillingSetupCommitment : listBillingAllCommitments) {
                    if (mapContractIdToListBillingCommitments.containsKey(objBillingSetupCommitment.Billing_Setup__c)) {
                        List<Billing_Setup_Commitment__c> listBillingCommitments = mapContractIdToListBillingCommitments.get(objBillingSetupCommitment.Billing_Setup__c);
                        listBillingCommitments.add(objBillingSetupCommitment);
                    } else {
                        List<Billing_Setup_Commitment__c> listBillingCommitments = new List<Billing_Setup_Commitment__c>();
                        listBillingCommitments.add(objBillingSetupCommitment);
                        mapContractIdToListBillingCommitments.put(objBillingSetupCommitment.Billing_Setup__c, listBillingCommitments);
                    }
                    for (Billing_Setup_Commitment_Tier_Set__c objCommimentTierSet : objBillingSetupCommitment.Billing_Setup_Commitment_Tier_Sets__r) {
                        setTierSetsInCommitments.add(objCommimentTierSet.Billing_Setup_Tier_Set__c);
                    }
                }
                mapTierSetIdToAmount = new Map<Id, Decimal>();
                // Iterating through Contracts to be processed for Orders
                for(GCR_Content_Document_Detail__c objContract : list_Contracts)
                {
                    System.debug('<<< objContract.Name ' + objContract.Name);

                    // Create Order header
                    Order__c objOrder;
                    String strOrderNameSuffix = '';
                    List<Order__c> listExistingOrders = map_ContractIdToListOrders.get(objContract.Id);
                    if (listExistingOrders != null && listExistingOrders.size() > 0) {
                        strOrderNameSuffix += String.valueOf(listExistingOrders.size());
                    }
                    if (blnPreBill) {
                        strOrderNameSuffix += 'P';
                    }
                    blnInRamp = false;

                    objOrder = createOrder(objContract, strOrderNameSuffix);
                    
                    System.Debug('Ramp: objContract.Ramp_Start_Date__c ' + objContract.Ramp_Start_Date__c);
                    System.Debug('Ramp: objContract.Ramp_End_Date__c   ' + objContract.Ramp_End_Date__c);
                    System.Debug('Ramp: objOrder.Maintenance_Start__c  ' + objOrder.Maintenance_Start__c);
                    System.Debug('Ramp: objOrder.Maintenance_End__c    ' + objOrder.Maintenance_End__c);
                    if (objContract.Ramp_Start_Date__c != null && objContract.Ramp_Start_Date__c <= objOrder.Maintenance_Start__c) {
                        System.DEbug('Ramp: objContract.Ramp_Start_Date__c <= objOrder.Maintenance_Start__c');
                        // Order is after the ramp start date. Might be in ramp
                        if (objContract.Ramp_End_Date__c == null || objOrder.Maintenance_End__c <= objContract.Ramp_End_Date__c) {
                            blnInRamp = true;
                        }
                    } else {
                        System.Debug('Ramp: NOT objContract.Ramp_Start_Date__c <= objOrder.Maintenance_Start__c');
                    }
                    // Checking for BOGO
                    // Map of related Tier Set Id to quantity to be received for free based on usage
                    Map<Id,Decimal> map_RelatedTierSetIdToFreeQuantity = new Map<Id,Decimal>();
                    
                    // Iterating through Tier Sets for the Contract
                    for(Contract_Tier_Set__c objContractTierSet : map_ContractIdToTierSets.get(objContract.Id))
                    {
                        System.debug('Checking for BOGO');
                        // if there is BOGO under this Tier Set and there is some usage logged
                        if(!objContractTierSet.BOGO_Details__r.isEmpty() && !objContractTierSet.Contract_Tier_Set_Month__r.isEmpty())
                        {
                            System.debug('Calculating BOGO');
                            // Total usage for the month
                            // iTracks 25080
                            Decimal decTotalParentQuantity = CloudBillingUtil.getTotalQuantity(objContractTierSet.Contract_Tier_Set_Month__r, objContractTierSet.Aggregation_Model__c);
                            for(BOGO_Detail__c objBOGODetail: objContractTierSet.BOGO_Details__r)
                            {
                                System.debug('Calculating BOGO for ' + objBOGODetail.Parent_Quantity__c + ',' + objBOGODetail.Related_Quantity__c);
                                Decimal decFreeRelatedQuantity;
                                
                                // if Prorate flag is checked then floor the final result 
                                // (Buy 10 get 3 free will get you 4 free when parent tier set usage is 15)
                                if(objBOGODetail.Prorate__c)
                                    decFreeRelatedQuantity = Math.floor((decTotalParentQuantity/objBOGODetail.Parent_Quantity__c) * objBOGODetail.Related_Quantity__c);
                                
                                // if prorate flag is unchecked then floor the usage quantity ratio and then multiply with free quantity
                                // (Buy 10 get 3 free will get you 3 free when parent tier set usage is 15)
                                else
                                    decFreeRelatedQuantity = Math.floor((decTotalParentQuantity/objBOGODetail.Parent_Quantity__c)) * objBOGODetail.Related_Quantity__c;
                                
                                // Related Tier Set is the Tier Set which gets the free quantity (specified in BOGO details)
                                map_RelatedTierSetIdToFreeQuantity.put(objBOGODetail.Related_Tier_Set__c,decFreeRelatedQuantity);
                            }
                        }   
                    }
                    
                    // List of Order Lines for this Order
                    List<Order_Line_Item__c> list_OrderLineItems = new List<Order_Line_Item__c>();
                    // Counter for maintaining Line count for Line # on Order Line
                    intLineCount = intLineCountSubscription = 0;
    
                    // Iterating through Tier Sets for the Contract
                    for(Contract_Tier_Set__c objContractTierSet : map_ContractIdToTierSets.get(objContract.Id))
                    {
                        System.debug('<<< objContractTierSet.Name ' + objContractTierSet.Name);
                        Decimal decTotalOutboundCallsCost = 0;
                        Decimal decTotalInboundCallsCost = 0;
                        Boolean blnProductHasTaxCode = false;
                        list_OrderLineItemsForBase = new List<Order_Line_Item__c>();
                        if (objContractTierSet.Product__r.SureTax_Code_Undetermined__c != null) {
                            blnProductHasTaxCode = true;
                        }
                        String strSystemNotes = '';
                        // List of Order Lines for current Tier Set
                        List<Order_Line_Item__c> list_OrderLineItemsForTierSet = new List<Order_Line_Item__c>();
                        // Total Amount for Tier Set
                        Decimal decTierSetTotal = 0;
                        Decimal decTierSetRunningTotal = 0;
                        
                        if(!objContractTierSet.Contract_Tier_Set_Month__r.isEmpty() || !objContractTierSet.Contract_Recurring_Charges__r.isEmpty())
                        {
                            // Total Usage Quantity for the month
                            // iTracks 25080
                            Decimal decCount = !objContractTierSet.Contract_Tier_Set_Month__r.isEmpty() ? CloudBillingUtil.getCount(objContractTierSet.Contract_Tier_Set_Month__r) : 0;
                            Decimal decTotalQuantity = !objContractTierSet.Contract_Tier_Set_Month__r.isEmpty() ? CloudBillingUtil.getTotalQuantity(objContractTierSet.Contract_Tier_Set_Month__r, objContractTierSet.Aggregation_Model__c) : 0;
                            List<Contract_Tier_Set_Month__c> list_PreviousTierSetMonthsForThisOrder = new List<Contract_Tier_Set_Month__c>();
                            
                            System.Debug('MultiPeriod: Period: ' + intTierSetPeriod(objContractTierSet));
                            // Need previous month total and this month total.
                            if (intTierSetPeriod(objContractTierSet) > 1) {
                                Contract_Tier_Set__c objContractTierSetMultiMonth = map_ContractTierSetToPeriodMultiMonth.get(objContractTierSet.Id);
                                if (objContractTierSetMultiMonth != null) {
                                    System.Debug('objContractTierSetMultiMonth got list of Tier Set Months Size ' + objContractTierSetMultiMonth.Contract_Tier_Set_Month__r.size());
                                    
                                    // Collect Tier Set Months associated with Tier Set Period but only those older than current month.
                                    if (objContractTierSetMultiMonth.Contract_Tier_Set_Month__r != null) {
                                        for (Contract_Tier_Set_Month__c objCTSM : objContractTierSetMultiMonth.Contract_Tier_Set_Month__r) {
                                            // Tier Set Year is less than the current month, include it.
                                            if (Integer.valueOf(objCTSM.Year__c) < Integer.valueOf(strYear)) {
                                                System.debug('MultiPeriod: Include Tier Set Month ' + objCTSM.Name + ' with date ' + objCTSM.Month__c + '-' + objCTSM.Year__c);
                                                list_PreviousTierSetMonthsForThisOrder.add(objCTSM);
                                                // Tier Set Year is equal and month is less than the current month, include it.
                                            } else if ((Integer.valueOf(objCTSM.Year__c) == Integer.valueOf(strYear)) && (Integer.valueOf(objCTSM.Month__c) < Integer.valueOf(strMonth))) {
                                                System.debug('MultiPeriod: Include Tier Set Month ' + objCTSM.Name + ' with date ' + objCTSM.Month__c + '-' + objCTSM.Year__c);
                                                list_PreviousTierSetMonthsForThisOrder.add(objCTSM);
                                            } else {
                                                System.debug('MultiPeriod: Skip Tier Set Month ' + objCTSM.Name + ' with date ' + objCTSM.Month__c + '-' + objCTSM.Year__c);
                                            }
                                        }
                                    }
                                } else {
                                    System.Debug('MultiPeriod: Period: objContractTierSetMultiMonth is null');
                                }
                            }
                            // Checking if any free quantity available from BOGO : if yes then reduce actual usage quantity
                            if(map_RelatedTierSetIdToFreeQuantity.containsKey(objContractTierSet.Id))
                            {
                                Decimal decFreeRelatedQuantity = map_RelatedTierSetIdToFreeQuantity.get(objContractTierSet.Id);
                                // Reduce quantity with the free quantity and ensure usage quantity is not negative
                                if(decFreeRelatedQuantity != null)
                                {
                                    decTotalQuantity = decTotalQuantity > decFreeRelatedQuantity ? (decTotalQuantity - decFreeRelatedQuantity) : 0;
                                    strSystemNotes += String.valueOf(decFreeRelatedQuantity) + ' quantity free as a result of BOGO.\n';
                                    if(decTotalQuantity < decFreeRelatedQuantity)
                                        strSystemNotes += 'Quantity set to 0 as total usage is less than free quantity.\n';
                                }
                                
                            }
                            System.debug('objContract.Invoice_Type__c ' + objContract.Invoice_Type__c);
                            // If Service Usage info available and we are not being asked for Pre-Bill
                            if(!objContractTierSet.Contract_Tier_Set_Month__r.isEmpty() && !blnPreBill)
                            {
                                // Rate table data has already calculated cost total (for Outbound calls or where rate table is used instead of tier sets)
                                decTotalOutboundCallsCost = CloudBillingUtil.getTotalOutboundCallsCost(objContractTierSet.Contract_Tier_Set_Month__r);
                                decTotalInboundCallsCost = CloudBillingUtil.getTotalInboundCallsCost(objContractTierSet.Contract_Tier_Set_Month__r);
                                if(decTotalOutboundCallsCost > 0)
                                {
                                    System.debug('Calculate Rate Table');
                                    // itrack 25080
                                    if (objContract.Invoice_Type__c != CLOUD_DEPLOYMENT_BREAKOUT_INVOICE_TYPE)
                                    {
                                        // Added By Vijay - Sep 5th 2017  - Start
                                        // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL)
                                        Decimal decSumCount = 0;
                                        if(objContractTierSet.Contract_Tier_Set_Month__r != NULL)
                                            for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                                                if(objContractTierSetMonth.Sum_Count__c != NULL)
                                                    decSumCount += objContractTierSetMonth.Sum_Count__c;
                                            }
                                        // Added By Vijay - Sep 5th 2017  - End
                                        
                                        Order_Line_Item__c objOLI = createOLIOutboundRatingTable(objContract, objOrder, objContractTierSet, list_OrderLineItemsForTierSet,
                                                                                                 decCount,decTotalQuantity, decTotalOutboundCallsCost + decTotalInboundCallsCost, null , decSumCount);
                                        decTierSetTotal += objOLI.Sales_Price__c * objOLI.BigMachines_Quantity__c;
                                        decTierSetRunningTotal += decTierSetTotal;
                                        System.Debug('Finished createOLIOutboundRatingTable got decTierSetTotal ' + decTierSetTotal);
                                    } else
                                    {
                                        for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                                            String strCloudDeploymentInfo = getCloudDeploymentName(objContractTierSetMonth);
                                            List<Contract_Tier_Set_Month__c> list_ctsm = new List<Contract_Tier_Set_Month__c>();
                                            list_ctsm.add(objContractTierSetMonth);
                                            Decimal decCountPerCTSM = CloudBillingUtil.getCount(list_ctsm);
                                            if ((objContractTierSetMonth.Total_Outbound_Calls_Cost__c != null && objContractTierSetMonth.Total_Outbound_Calls_Cost__c > 0) ||
                                                (objContractTierSetMonth.Total_Inbound_Calls_Cost__c != null && objContractTierSetMonth.Total_Inbound_Calls_Cost__c > 0)
                                               ){
                                                   Order_Line_Item__c objOLI = createOLIOutboundRatingTable(objContract, objOrder, objContractTierSet, list_OrderLineItemsForTierSet,
                                                                                                            decCountPerCTSM,
                                                                                                            objContractTierSetMonth.Total_Usage__c,
                                                                                                            objContractTierSetMonth.Total_Outbound_Calls_Cost__c + objContractTierSetMonth.Total_Inbound_Calls_Cost__c,
                                                                                                            strCloudDeploymentInfo, objContractTierSetMonth.Sum_Count__c);
                                                   decTierSetTotal += objOLI.Ext_Net_Price__c;
                                                   decTierSetRunningTotal += decTierSetTotal;
                                               }
                                        }
                                    }
                                }
                                // iTrack 24752
                                else if(decTotalInboundCallsCost > 0)
                                {
                                    System.debug('Calculate Inbound Rate Table');
                                    // itrack 25080
                                    if (objContract.Invoice_Type__c != CLOUD_DEPLOYMENT_BREAKOUT_INVOICE_TYPE)
                                    {
                                        // Added By Vijay - Sep 5th 2017  - Start
                                        // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL)
                                        Decimal decSumCount = 0;
                                        if(objContractTierSet.Contract_Tier_Set_Month__r != NULL)
                                            for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                                                if(objContractTierSetMonth.Sum_Count__c != NULL)
                                                    decSumCount += objContractTierSetMonth.Sum_Count__c;
                                            }
                                        // Added By Vijay - Sep 5th 2017  - End
                                        
                                        Order_Line_Item__c objOLI = createOLIInboundRatingTable(objContract, objOrder, objContractTierSet, list_OrderLineItemsForTierSet,
                                                                                                decCount,
                                                                                                decTotalQuantity, decTotalInboundCallsCost, null, decSumCount);
                                        decTierSetTotal += objOLI.Ext_Net_Price__c;
                                        decTierSetRunningTotal += decTierSetTotal;
                                    }
                                    else
                                    {
                                        for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                                            String strCloudDeploymentInfo = getCloudDeploymentName(objContractTierSetMonth);
                                            List<Contract_Tier_Set_Month__c> list_ctsm = new List<Contract_Tier_Set_Month__c>();
                                            list_ctsm.add(objContractTierSetMonth);
                                            Decimal decCountPerCTSM = CloudBillingUtil.getCount(list_ctsm);
                                            if (objContractTierSetMonth.Total_Inbound_Calls_Cost__c != null && objContractTierSetMonth.Total_Inbound_Calls_Cost__c > 0) {
                                                Order_Line_Item__c objOLI = createOLIInboundRatingTable(objContract, objOrder, objContractTierSet, list_OrderLineItemsForTierSet,
                                                                                                        decCountPerCTSM,
                                                                                                        objContractTierSetMonth.Total_Usage__c,
                                                                                                        objContractTierSetMonth.Total_Inbound_Calls_Cost__c,
                                                                                                        strCloudDeploymentInfo, objContractTierSetMonth.Sum_Count__c);
                                                decTierSetTotal += objOLI.Ext_Net_Price__c;
                                                decTierSetRunningTotal += decTierSetTotal;
                                            }
                                        }
                                    }
                                }
                                else if(decTotalQuantity > 0)
                                {
                                    System.debug('Calculate Standard Tier Set');
                                    // itrack 25080
                                    if (objContract.Invoice_Type__c != CLOUD_DEPLOYMENT_BREAKOUT_INVOICE_TYPE)
                                    {
                                        // Added By Vijay - Sep 5th 2017  - Start
                                        // CRMBILL-146 - Get Sum Count of Calls to OrderLine Item in PureCloud(PCL)
                                        Decimal decSumCount = 0;
                                        if(objContractTierSet.Contract_Tier_Set_Month__r != NULL)
                                            for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                                                if(objContractTierSetMonth.Sum_Count__c != NULL)
                                                    decSumCount += objContractTierSetMonth.Sum_Count__c;
                                            }
                                        // Added By Vijay - Sep 5th 2017  - End
                                        
                                        decTierSetTotal = createOLIStandard(objContractTierSet, list_OrderLineItemsForTierSet,
                                                                            strSystemNotes,decCount,
                                                                            decTotalQuantity,list_PreviousTierSetMonthsForThisOrder,decTierSetTotal, null, decSumCount);
                                        decTierSetRunningTotal += decTierSetTotal;
                                    } else
                                    {
                                        for (Contract_Tier_Set_Month__c objContractTierSetMonth : objContractTierSet.Contract_Tier_Set_Month__r) {
                                            System.debug('Calculate Standard Tier Set Start Loop');
                                            String strCloudDeploymentInfo = getCloudDeploymentName(objContractTierSetMonth);
                                            List<Contract_Tier_Set_Month__c> list_ctsm = new List<Contract_Tier_Set_Month__c>();
                                            list_ctsm.add(objContractTierSetMonth);
                                            Decimal decCountPerCTSM = CloudBillingUtil.getCount(list_ctsm);
                                            decTierSetTotal = createOLIStandard(objContractTierSet, list_OrderLineItemsForTierSet,
                                                                                strSystemNotes,decCountPerCTSM,objContractTierSetMonth.Total_Usage__c,null,decTierSetTotal, strCloudDeploymentInfo,
                                                                                objContractTierSetMonth.Sum_Count__c);
                                            decTierSetRunningTotal += decTierSetTotal;
                                            System.debug('Calculate Standard Tier Set End Loop');
                                        }
                                    }
                                }
                                
                                
                            }
                            System.debug('Done with creating Usage Order Line Items. Enter Recurring Charges with decTierSetTotal ' + decTierSetTotal);
                            // Iterate through recurring charges under the tier set
                            for(Contract_Recurring_Charge__c objContRecCharge : objContractTierSet.Contract_Recurring_Charges__r)
                            {
                                System.debug('User Request Pre-Bill: ' + blnPreBill + ' Recurring Charge Pre Bill:' + objContRecCharge.Pre_Bill__c);
                                // If user asked for Pre-Bill and the RC is not Pre-Bill, skip it
                                if (blnPreBill && !objContRecCharge.Pre_Bill__c) {
                                    System.debug('User Requested PreBill but charge is not Pre-Bill, Skip it');
                                    continue;
                                }
                                // If user did not ask for Pre-Bill and the RC is Pre-Bill, skip it
                                if (!blnPreBill && objContRecCharge.Pre_Bill__c) {
                                    System.debug('User did not Request PreBill. Charge is Pre-Bill, Skip it');
                                    continue;
                                }
                                Boolean writeCharge = true;
    
                                // Recurring Charges are inherently commitments
                                Order_Line_Item__c objOLI = createOrderLineItem(objContractTierSet,objContRecCharge.Deferred__c, REVENUE_CLASSIFICATION_COMMITTED);
                                // Override the Tier Set Period with the Recurring Charge Period
                                try {
                                    objOLI.Tier_Set_Period_In_Months__c = Integer.valueOf(objContRecCharge.Contract_Tier_Set__r.RC_Period__c);
                                } catch (System.Exception te) {
                                    System.debug('Recurring Charge Period is not convertable to Integer: ' + objContRecCharge.Contract_Tier_Set__r.RC_Period__c + ' setting to period of 1 month');
                                    objOLI.Tier_Set_Period_In_Months__c = 1;
                                }
                                //CRMBILL-121 
                                //objOLI.BigMachines_Quantity__c = 1;
                                if(objContRecCharge.Quantity__c!=null)
                                    objOLI.BigMachines_Quantity__c = objContRecCharge.Quantity__c;
                                else
                                    objOLI.BigMachines_Quantity__c = 1;
                                
                                if (!String.isBlank(objContRecCharge.External_Note__c)) {
                                    objOLI.Memo__c = objContRecCharge.External_Note__c;
                                } else {
                                    objOLI.Memo__c = objContRecCharge.Type__c;
                                }
                                
                                // Monthly Flat Fee - charge in all cases whether blnPreBill is set or not
                                if(objContRecCharge.Type__c == 'Monthly Flat Fee' || objContRecCharge.Type__c == 'Installment Plan')
                                {
                                    objOLI.Ext_Net_Price__c = objContRecCharge.Amount__c;
                                    system.debug(objOLI.Ext_Net_Price__c);
                                    System.debug('Monthly Flat Fee applied of: ' + objOLI.Ext_Net_Price__c);
                                    
                                    if(objOLI.BigMachines_Quantity__c != null && objOLI.BigMachines_Quantity__c != 0)
                                        //CRMBILL-121 
                                        objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.BigMachines_Quantity__c);
                                    //objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = objContRecCharge.Rate__c;
                                    if (objContRecCharge.Type__c == 'Installment Plan')
                                        objOLI.Installment_Plan__c = true;
                                }
                                
                                
                                // Monthly Access Fee - charge if any quantity of activity. Skip if not pre-bill
                                else if(objContRecCharge.Type__c == 'Monthly Access Fee' && !blnPreBill)
                                {
                                    // No Activity, Charge Not Applied : Skipped Order Line creation
                                    if (decTotalQuantity == 0) 
                                        continue;
                                    // If there was some activity charge the whole amount
                                    else
                                    {
                                        objOLI.Ext_Net_Price__c = objContRecCharge.Amount__c;
                                        system.debug(objOLI.Ext_Net_Price__c);
                                        if(objOLI.BigMachines_Quantity__c != null && objOLI.BigMachines_Quantity__c != 0)
                                            objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.BigMachines_Quantity__c);
                                    }
                                    
                                }
                                // Commitment Shortfall : Customer agreed to pay a minimum amount for usage against a set of services
                                else if(objContRecCharge.Type__c == 'Commitment Shortfall' && !blnPreBill)
                                {
                                    Boolean blnApplyShortfallCharge = true;
                                    // If the RC period is > 1 check whether we are on the last month of the Cycle
                                    if(objContRecCharge.Contract_Tier_Set__r.Period_In_Months__c != null) {
                                        Integer intPeriod = Integer.valueOf(objContRecCharge.Contract_Tier_Set__r.Period_In_Months__c);
                                        Integer intApplyCharge = getMonthOfBillingCycle(objContract.Pricing_Start_Date__c,
                                                                                        intPeriod,
                                                                                        Integer.valueOf(strDay),
                                                                                        Integer.valueOf(strMonth),
                                                                                        Integer.valueOf(strYear));
                                        if ((intPeriod-1) == intApplyCharge) {
                                            System.Debug('Commitment we are on the last month of the period, apply charge if shortfall. intPeriod ' + intPeriod +
                                                         ' intApplyCharge ' + intApplyCharge);
                                        } else {
                                            System.Debug('Commitment we are Not on the last month of the period, do not run shortfall. intPeriod ' + intPeriod +
                                                         ' intApplyCharge ' + intApplyCharge);
                                            continue;
                                        }
                                    }
                                    
                                    // Activity Not Enough, Charge Difference
                                    if (decTierSetTotal < objContRecCharge.Amount__c)
                                    {
                                        // ECD Oct 2019 Recalculate the BigMachines_Quantity__c based on the usage of the Tier Sets
                                        if (objContRecCharge.Quantity__c != null) {
                                            objOLI.BigMachines_Quantity__c = objContRecCharge.Quantity__c - decTotalQuantity;
                                            System.Debug('Recurring Charge has a quantity, calculate quantity based on subtracting charge quantity from objContRecCharge.Quantity__c ' + objContRecCharge.Quantity__c +
                                                         ' decTotalQuantity ' + decTotalQuantity +
                                                         ' objOLI.BigMachines_Quantity__c ' + objOLI.BigMachines_Quantity__c);
                                        }
                                        objOLI.Ext_Net_Price__c = objContRecCharge.Amount__c - decTierSetTotal;
                                        System.debug('Commitment Short Fall adding charge ' + objOLI.Ext_Net_Price__c);
                                        
                                        if(objOLI.BigMachines_Quantity__c != null && objOLI.BigMachines_Quantity__c != 0)
                                            objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.BigMachines_Quantity__c);
                                        objOLI.Name = objOLI.Name + ' Shortfall';
                                        objOLI.Description__c = objOLI.Description__c + ' Shortfall';
                                    }
                                    
                                    // Activity Covered the Commitment. No Charge.
                                    else {
                                        System.debug('Commitment reached ' + decTierSetTotal + ' greater than commitment of ' + objContRecCharge.Amount__c);
                                        continue;
                                    }
                                }
                                // Variable Term Flat Fee allows writing a charge once every Recurring Charge billing period and not on months in between
                                // If the RC_Period__c is set to 1 this will function exactly as the Monthly Flat Fee
                                else if(objContRecCharge.Type__c == 'Variable Term Flat Fee')
                                {
                                    System.debug('Variable Term Flat Fee objContRecCharge.Contract_Tier_Set__r.RC_Period__c ' + objContRecCharge.Contract_Tier_Set__r.RC_Period__c);
                                    if(objContRecCharge.Contract_Tier_Set__r.RC_Period__c != null)
                                    {
                                        /*
    // Calculate months between start of contract and month we are billing
    Date orderMonth = Date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
    Integer monthsBetween = orderMonth.monthsBetween(objContract.Pricing_Start_Date__c);
    String billingTermStr = objContRecCharge.Contract_Tier_Set__r.RC_Period__c;
    Integer billingTerm = Integer.valueOf(billingTermStr);
    */
                                        // If the remainder of months = 0 we are on a month beginning the billing period
                                        Integer intApplyCharge = getMonthOfBillingCycle(objContract.Pricing_Start_Date__c,
                                                                                        Integer.valueOf(objContRecCharge.Contract_Tier_Set__r.RC_Period__c),
                                                                                        Integer.valueOf(strDay),
                                                                                        Integer.valueOf(strMonth),
                                                                                        Integer.valueOf(strYear));
                                        if (intApplyCharge == 0) {
                                            System.debug('Variable writing variable charge as month mod is ' + intApplyCharge);
                                            objOLI.Ext_Net_Price__c = objContRecCharge.Amount__c;
                                            system.debug(objOLI.Ext_Net_Price__c);
                                            
                                            if(objOLI.BigMachines_Quantity__c != null && objOLI.BigMachines_Quantity__c != 0)
                                                objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.BigMachines_Quantity__c);
                                        } else {
                                            System.debug('Variable skip writing variable charge as month mod is ' + intApplyCharge);
                                            writeCharge = false;
                                        }
                                    }
                                    
                                    else
                                        continue;
                                }
                                // Single charge to occur on only the first invoicing period of the contract
                                else if(objContRecCharge.Type__c == 'One Time Flat Fee') 
                                {
                                    Date orderMonth = Date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
                                    Integer monthsBetween = orderMonth.monthsBetween(objContract.Pricing_Start_Date__c);
                                    if (monthsBetween == 0) {
                                        objOLI.Ext_Net_Price__c = objContRecCharge.Amount__c;
                                        system.debug(objOLI.Ext_Net_Price__c);
                                        if(objOLI.BigMachines_Quantity__c != null && objOLI.BigMachines_Quantity__c != 0)
                                            objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = (objOLI.Ext_Net_Price__c/objOLI.BigMachines_Quantity__c);
                                    } else {
                                        writeCharge = false;
                                    }
                                }
                                else if(objContRecCharge.Type__c == 'Units In Plan' && !blnPreBill) 
                                {
                                    if (decTotalQuantity == 0) {
                                        // Nothing to grant
                                        continue;
                                    }
                                    Decimal decRequestedUnits = 1;
                                    if (objContRecCharge.Units__c != null) {
                                        decRequestedUnits = objContRecCharge.Units__c;
                                    }
                                    Decimal decUnitsToCharge = decTotalQuantity;
                                    if (decRequestedUnits < decUnitsToCharge) {
                                        decUnitsToCharge = decRequestedUnits;
                                    }
                                    objOLI.BigMachines_Quantity__c = decUnitsToCharge;
                                    objOLI.Net_Unit_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = objContRecCharge.Amount__c;
                                    objOLI.Ext_Net_Price__c = decUnitsToCharge * objContRecCharge.Amount__c;
                                    system.debug(objOLI.Ext_Net_Price__c);
                                }
                                // iTracks 25634 Logic
                                else if(objContRecCharge.Type__c == 'Business Care')
                                {
                                    System.debug('In Business Care');
                                    // Save the Order to revist and add a Business Care line after Orders are saved
                                    list_OrdersWithBusinessCare.add(objOrder);
                                    map_OrderBusinessCareRecurringCharge.put(objOrder, objContRecCharge);
                                    writeCharge = false;
                                }
                                
                                // Calculate Buisness Care later because we need all Order Line Items to know the Pre-Support Total
                                if (writeCharge) {
                                    if (blnProductHasTaxCode) {
                                        if (map_ContractIdToBillingAddress.containsKey(objContractTierSet.Contract__c)) {
                                            // If you need to get from Account Order Address keep this comment
                                            // Account_Order_Address__c objBillingAddress = map_ContractIdToBillingAddress.get(objContractTierSet.Contract__c);
                                            // objBillingAddress.Country__c
                                        }
                                        Set<String> setOfEntitiesToTax = CloudBillingUtil.getSetOfStringsByCommaSeperated(Label.Cloud_Billing_Tax_Subsidiaries);
                                        String strSubsidiary = objContractTierSet.Contract__r.Account_Name__r.Subsidary__r.Name;
                                        if (setOfEntitiesToTax.contains(strSubsidiary)) {
                                            objOLI.Tax_Status__c = BatchTaxCloudUsageData.TAX_STATUS_ORDER_LINE_SURETAX_NEEDED;
                                        } else {
                                            System.Debug('Product has tax code, but skipping as subsidiary ' + strSubsidiary +
                                                         ' is not in set setOfEntitiesToTax ' + setOfEntitiesToTax);
                                        }
                                    }
                                    list_OrderLineItemsForTierSet.add(objOLI);
                                    decTierSetRunningTotal += objOLI.Sales_Price__c * objOLI.BigMachines_Quantity__c;
                                }
                            }
                        }
                        System.Debug('Tier Set In Commitment: Checking tier sets for existence in commitment');
                        if (setTierSetsInCommitments.contains(objContractTierSet.Id)) {
                            for (Order_Line_Item__c objOLI : list_OrderLineItemsForTierSet) {
                                if (!map_ProductAPNToProduct.containsKey(objOLI.APN_Number__c)) {
/*      private final String REVENUE_CLASSIFICATION_COMMITTED = 'Committed';
        private final String POB_CLOUD_COMMITTED = 'Cloud-Committed';
        private final String POB_PREMISE_COMMITTED= 'Premise Subscription - Committed';
public String derrivePOBFromRevenueClassification(Contract_Tier_Set__c objContractTierSet, String strRevenueClassification) {
 */
                                    objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_COMMITTED;
                                    objOLI.POB_Type__c = derrivePOBFromRevenueClassification(objContractTierSet, REVENUE_CLASSIFICATION_COMMITTED);
                                    System.Debug('Tier Set In Commitment: objOLI not a Tax Product, reset to committed ' + objOLI);
                                } else {
                                    System.Debug('Tier Set In Commitment: objOLI a Tax Product, leave as Not Applicable ' + objOLI);
                                }
                            }
                        } else {
                            System.Debug('Tier Set In Commitment:  objContractTierSet does not exist in commitment ' + objContractTierSet);
                        }
                        mapTierSetIdToAmount.put(objContractTierSet.Id, decTierSetRunningTotal);
                        if (blnInRamp) {
                            System.Debug('Ramp: Resetting all OLIs to Ramp Uncommitted');
                            for (Order_Line_Item__c objOLI : list_OrderLineItemsForTierSet) {
                                if (!map_ProductAPNToProduct.containsKey(objOLI.APN_Number__c)) {
                                    System.Debug('Ramp: objOLI not a Tax Product, reset to ramp uncommitted ' + objOLI);
                                    objOLI.POB_Type__c = POB_CLOUD_RAMP_UNCOMMITTED;
                                    objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_UNCOMMITTED;
                                } else {
                                    System.Debug('Ramp: objOLI a Tax Product, leave as Not Applicable ' + objOLI);
                                }
                            }
                        }
                        list_OrderLineItems.addAll(list_OrderLineItemsForTierSet);
                        system.debug(list_OrderLineItemsForBase);
                        if(list_OrderLineItemsForBase.size() > 0)
                            list_OrderLineItems.addAll(list_OrderLineItemsForBase);
                    }
                    List<Billing_Setup_Commitment__c> listBillingCommitments = mapContractIdToListBillingCommitments.get(objContract.Id);
                    if (listBillingCommitments != null) {
                        for (Billing_Setup_Commitment__c objBillingCommitment : listBillingCommitments) {
                            Decimal decCommitmentTierSetTotal = 0;
                            for (Billing_Setup_Commitment_Tier_Set__c objBillingSetupCommitmentTierSet : objBillingCommitment.Billing_Setup_Commitment_Tier_Sets__r) {
                                if (mapTierSetIdToAmount.containsKey(objBillingSetupCommitmentTierSet.Billing_Setup_Tier_Set__c)) {
                                    Decimal decTierSetTotal = mapTierSetIdToAmount.get(objBillingSetupCommitmentTierSet.Billing_Setup_Tier_Set__c);
                                    System.Debug('Commitment Tier Set Id ' + objBillingSetupCommitmentTierSet.Billing_Setup_Tier_Set__c + ' has total ' + decTierSetTotal);
                                    decCommitmentTierSetTotal += decTierSetTotal;
                                } else {
                                    System.Debug('Commitment Tier Set Id ' + objBillingSetupCommitmentTierSet.Billing_Setup_Tier_Set__c + ' had ZERO total');
                                }
                            }
                            if (decCommitmentTierSetTotal < objBillingCommitment.Committed_Amount__c) {
                                System.Debug('Commitment Id ' + objBillingCommitment.id +
                                             ' less than commitment: decCommitmentTierSetTotal ' + decCommitmentTierSetTotal +
                                             ' objBillingCommitment.Committed_Amount__c ' + objBillingCommitment.Committed_Amount__c);
                                /* Product__c, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c */
                                Product2 objProduct = new Product2(Id = objBillingCommitment.Product__c,
                                                                   APN_Number__c = objBillingCommitment.Product__r.APN_Number__c,
                                                                   Unit_of_Measure__c = objBillingCommitment.Product__r.Unit_of_Measure__c);
                                Order_Line_Item__c objOLI = createProductOrderLineItem(objProduct, objBillingCommitment.Description__c);
                                objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = 1;
                                objOLI.Sales_Price__c = objOLI.Ext_Net_Price__c = objOLI.List_Price__c = objOLI.Net_Unit_Price__c = objBillingCommitment.Committed_Amount__c - decCommitmentTierSetTotal;
                                list_OrderLineItems.add(objOLI);
                            } else {
                                System.Debug('Commitment Id ' + objBillingCommitment.id +
                                             ' commitment met: decCommitmentTierSetTotal ' + decCommitmentTierSetTotal +
                                             ' objBillingCommitment.Committed_Amount__c ' + objBillingCommitment.Committed_Amount__c);
                            }
                        }
                    }
                    
                    // iTracks 24752 Logic
                    // Inbound Number Flat Fee Calculation
                    if (objContract.Inbound_Billing_Type__c == 'Inbound Rate Table') {
                        String HAIRPIN_NUMBER= 'Hairpin Number';
                        if (objInboundHairpinProduct == null) {
                            objInboundHairpinProduct = [select Id, APN_Number__c, Unit_Of_Measure__c from Product2 where Id = :(Id)Label.Inbound_Hairpin_Product];
                        }
                        System.Debug('Calculating Flat Fees based on numbers used');
                        List<Inbound_Calling_Rate__c> list_InboundCallingRate = [select Id, Flat_Rate__c, Hairpin_Number__c,
                                                                                 Effective_Start_Date__c, Effective_End_Date__c
                                                                                 from Inbound_Calling_Rate__c
                                                                                 where Effective_Start_Date__c <= :dtFirstOfBillingMonth
                                                                                 and Effective_End_Date__c >= :dtFirstOfBillingMonth
                                                                                 and GARN_Account_Code__c = :objContract.Account_Name__r.SAP_Account_Code__c
                                                                                 order by Flat_Rate__c];
                        // This logic dependant on the above query sorting by increasing price
                        Decimal intPrice = 0.0;
                        Integer intCount = 0;
                        for (Inbound_Calling_Rate__c objICR : list_InboundCallingRate) {
                            System.Debug('Got Inbound Rate Id ' + objICR.Id + ': ' + objICR.Hairpin_Number__c + ' Rate ' + objICR.Flat_Rate__c + ' Start ' + objICR.Effective_Start_Date__c + ' End ' + objICR.Effective_End_Date__c);
                            if (objICR.Flat_Rate__c > intPrice) {
                                // Write OLI for the old price if one exists
                                if (intPrice > 0 && intCount > 0) {
                                    System.debug('Creating OLI for old pricing');
                                    Order_Line_Item__c objOLI = createProductOrderLineItem(objInboundHairpinProduct, HAIRPIN_NUMBER);
                                    objOLI.Net_Unit_Price__c = objOLI.Ext_Net_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = intPrice;
                                    objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = intCount;
                                    objOlI.Memo__c = HAIRPIN_NUMBER;
                                    objOLI.CurrencyISOCode = objOrder.CurrencyISOCode;
                                    list_OrderLineItems.add(objOLI);
                                } else {
                                    System.debug('Skip creating initial 0 OLI');
                                }
                                // Starting a new price
                                intPrice = objICR.Flat_Rate__c;
                                intCount = 1;
                            } else {
                                intCount++;
                            }
                        }
                        // Write OLI for the old price if one exists
                        if (intPrice > 0 && intCount > 0) {
                            System.debug('Creating final OLI');
                            Order_Line_Item__c objOLI = createProductOrderLineItem(objInboundHairpinProduct, HAIRPIN_NUMBER);
                            objOLI.Net_Unit_Price__c = objOLI.Ext_Net_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = intPrice;
                            objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = intCount;
                            objOlI.Memo__c = HAIRPIN_NUMBER;
                            objOLI.CurrencyISOCode = objOrder.CurrencyISOCode;
                            list_OrderLineItems.add(objOLI);
                        } else {
                            System.debug('Skip creating initial final OLI');
                        }   
                    }
                    
                    // Add Order Line Items for Tax
                    System.debug('objContractTierSet.Id : '+objContract.Id);
                    System.debug('map_CTSMCbyTaxCode.containsKey(objContractTierSet.Id) :'+map_CTSMCbyTaxCode.containsKey(objContract.Id));
                    
                    if(map_CTSMCbyTaxCode.containsKey(objContract.Id)){
                        System.debug('Contract ' + objContract.Id + ' has tax children in at least one tier set month');
                        Map<String, Contract_Tier_Set_Month_Charges__c> map_ContractIdTaxCodes = map_CTSMCbyTaxCode.get(objContract.Id);
                        System.debug('map_ContractIdTaxCodes: ' + map_ContractIdTaxCodes);
                        Set<String> setTaxGroupingsKeySet = map_ContractIdTaxCodes.keySet();
                        List<String> listTaxGroupings = new List<String>();
                        listTaxGroupings.addAll(setTaxGroupingsKeySet);
                        System.debug('listTaxGroupingslistTaxGroupings :' + listTaxGroupings);
                        System.debug('map_ConversionRates ' + map_ConversionRates + ' list_OrderLineItems ' + list_OrderLineItems);
                        for (String strTaxGrouping : listTaxGroupings) {
                            Contract_Tier_Set_Month_Charges__c objCTSMC = map_ContractIdTaxCodes.get(strTaxGrouping);
                            Product2 objProduct = map_ProductAPNToProduct.get(strTaxGrouping);
                            if (objProduct == null) {
                                System.debug('Warning: No tax product found for strTaxGrouping ' + strTaxGrouping);
                                objProduct = new Product2(Name = strTaxGrouping);
                            }
                            System.debug('Product ' + objProduct + ' strTaxGrouping ' + strTaxGrouping + ' objCTSMC ' + objCTSMC);
                            Order_Line_Item__c objOLI = createOrderLineItem(objProduct, REVENUE_CLASSIFICATION_NOT_APPLICABLE);
                            objOLI.Memo__c = strTaxGrouping;//SureTax_Settings__c.getInstance(objCTSMC.Description__c).Value__c;
                            objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = 1.0;
                            objOLI.Net_Unit_Price__c = objOLI.Ext_Net_Price__c =
                                objOLI.Sales_Price__c = objOLI.List_Price__c = objCTSMC.Amount__c;
                            list_OrderLineItems.add(objOLI);
                        }
                    }
                    // Added by Vijay - Jul 12th 2017 - End
                    
                    if(!list_OrderLineItems.isEmpty())
                    {
                        list_OrdersToCreate.add(objOrder);
                        list_OrderLineItemLists.add(list_OrderLineItems);
                    }
                    
                    if(!map_BurstedProduct.isEmpty())
                        createAutoOpportunityQuote(map_BurstContractTierSet, map_BurstContractTierSetPrice);
                    
                    map_BurstedProduct =  new  map<BigMachines__Quote_Product__c,decimal>();
                }
                
                // Create Orders if any
                System.debug('List of Orders to Create size ' + list_OrdersToCreate.size());
                if(!list_OrdersToCreate.isEmpty())
                {
                    // Remove 'In Progress' orders if any
                    if(!list_OrdersToDelete.isEmpty())
                    {
                        Util.Bypass_Trigger_Chk = true;
                        delete list_OrdersToDelete;
                        
                        // Remove Addresses (if any) related to Orders being removed
                        if(!list_OrdersAddressesToDelete.isEmpty())
                            delete list_OrdersAddressesToDelete;
                    }
                    
                    // Setting this flag to avoid trigger executions
                    Util.Bypass_Trigger_Chk = true;
                    insert list_OrdersToCreate;
                    // Re-Enable Triggers
                    Util.Bypass_Trigger_Chk = false;
                    
                    List<Order_Line_Item__c> list_OLIToInsert = new List<Order_Line_Item__c>();
                    List<Account_Order_Address__c> list_OrdersAddressesToInsert = new List<Account_Order_Address__c>();
                    Integer intCount = -1;
                    // Populate Order Id on Order Lines and Order Addresses for the Orders inserted
                    for(List<Order_Line_Item__c> list_OLI : list_OrderLineItemLists)
                    {
                        intCount++;
                        Order__c objOrder = list_OrdersToCreate[intCount];
                        
                        // Relate order Lines to Orders and populate currency code from order
                        if(!list_OLI.isEmpty())
                        {
                            list_OLIToInsert.addAll(list_OLI);
                            for(Order_Line_Item__c objOLI : list_OLI)
                            {
                                objOLI.Order__c = objOrder.Id;
                                objOLI.CurrencyISOCode = objOrder.CurrencyISOCode;
                                //Anju April 25 set start date for PES and PCS
                                if(objOrder.Sales_Org__c == 'PureEngage Subscription' || objOrder.Sales_Org__c == 'PureConnect Subscription')
                                {
                                    objOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                    objOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;
                                    system.debug(intLineCount);
                                    if(objOLI.line_number__c == null)
                                    {
                                        if(intLineCountSubscription > 0)
                                            objOLI.line_number__c = ++intLineCountSubscription;
                                        else
                                            objOLI.line_number__c = ++intLineCount;
                                    }
                                }
                                if (objOrder.Sales_Org__c == 'Premier Edition') {
                                    setOrderLineItemUncommited(objOLI);
                                }
                            }  
                        }
                        
                        // Create 'Bill To' and 'Ship To' address under the Order for ERP : clone address from Billing address related to quote/contract
                        if(map_ContractIdToBillingAddress.containsKey(objOrder.Contract_Lookup__c))
                        {
                            Account_Order_Address__c objBillingAddress = map_ContractIdToBillingAddress.get(objOrder.Contract_Lookup__c);
                            String strAccountNameOverride = map_ContractIdToCompanyNameOverride.get(objOrder.Contract_Lookup__c);
                            
                            Account_Order_Address__c objBillToAddress = objBillingAddress.clone(false, true, false, false);
                            if (strAccountNameOverride != null) {
                                objBillToAddress.Company__c = strAccountNameOverride;
                            }
                            objBillToAddress.Address_Type__c = 'Bill To';
                            objBillToAddress.GCR_Content_Document_Detail__c = null;
                            objBillToAddress.Quote__c = null;
                            objBillToAddress.Zuora_Quote__c = null;
                            objBillToAddress.Account__c = objOrder.End_User_Name__c;
                            objBillToAddress.Sold_To_Business_Partner__c = objOrder.End_User_Name__c;
                            objBillToAddress.Order__c = objOrder.Id;
                            
                            Account_Order_Address__c objShipToAddress = objBillingAddress.clone(false, true, false, false);
                            if (strAccountNameOverride != null) {
                                objShipToAddress.Company__c = strAccountNameOverride;
                            }
                            objShipToAddress.Address_Type__c = 'Ship To';
                            objShipToAddress.GCR_Content_Document_Detail__c = null;
                            objShipToAddress.Quote__c = null;
                            objShipToAddress.Zuora_Quote__c = null;
                            objShipToAddress.Account__c = objOrder.End_User_Name__c;
                            objShipToAddress.Sold_To_Business_Partner__c = objOrder.End_User_Name__c;
                            objShipToAddress.Order__c = objOrder.Id;
                            
                            
                        Account_Order_Address__c objSoldToAddress = objBillingAddress.clone(false, true, false, false);
                        if (strAccountNameOverride != null) {
                                objSoldToAddress.Company__c = strAccountNameOverride;
                            }
                        objSoldToAddress.Address_Type__c = 'Sold To';
                        objSoldToAddress.GCR_Content_Document_Detail__c = null;
                        objSoldToAddress.Quote__c = null;
                        objSoldToAddress.Zuora_Quote__c = null;
                        objSoldToAddress.Account__c = objOrder.End_User_Name__c;
                        objSoldToAddress.Sold_To_Business_Partner__c = objOrder.End_User_Name__c;
                        objSoldToAddress.Order__c = objOrder.Id;
                        System.debug('Account Order Address:Sold to:'+objSoldToAddress);
                        
                       
                        
                        Account_Order_Address__c objEndUserAddress = objBillingAddress.clone(false, true, false, false);
                        if (strAccountNameOverride != null) {
                                objEndUserAddress.Company__c = strAccountNameOverride;
                            }
                        objEndUserAddress.Address_Type__c = 'End User';
                        objEndUserAddress.GCR_Content_Document_Detail__c = null;
                        objEndUserAddress.Quote__c = null;
                        objEndUserAddress.Zuora_Quote__c = null;
                        objEndUserAddress.Account__c = objOrder.End_User_Name__c;
                        objEndUserAddress.Sold_To_Business_Partner__c = objOrder.End_User_Name__c;
                        objEndUserAddress.Order__c = objOrder.Id;
                        System.debug('Account Order Address:End User:'+objEndUserAddress);
                        
                        
                        list_OrdersAddressesToInsert.add(objBillToAddress);
                        list_OrdersAddressesToInsert.add(objShipToAddress);
                        list_OrdersAddressesToInsert.add(objSoldToAddress);
                        list_OrdersAddressesToInsert.add(objEndUserAddress);
                        }
                    }
                    
                    // Insert Order Lines
                    if(!list_OLIToInsert.isEmpty())
                    {
                        // Set flag so that trigger logic to populate order total based on line amounts is executed
                        Util.blnRunPPUTrigger = true;
                        for (Order_Line_Item__c objOLI : list_OLIToInsert) {
                            System.Debug('Order Line ' + objOLI.Name + ' Product Id ' + objOLI.Product__c + ' APN Number ' + objOLI.Product__c + 'Order:'+objOLI.order__c + 'Line#' + objOLI.Line_Number__c);
                        }
                        //TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL = true;
                        insert list_OLIToInsert;
                        
                    }
                    
                    // Insert Order Addresses
                    if(!list_OrdersAddressesToInsert.isEmpty())
                        insert list_OrdersAddressesToInsert;
                    
                    // iTrack 25634 added logic for Business Care for Cloud
                    // Order totals are calculated by a trigger. So we must go back to the database to get Order Totals
                    // and find Recurring charges for those orders AFTER saving of the initial order
                    if (list_OrdersWithBusinessCare.size() > 0) {
                        Set<Id> set_orderBusinessCare = new Set<Id>();
                        for (Order__c orderBusinessCare : list_OrdersWithBusinessCare) {
                            set_orderBusinessCare.add(orderBusinessCare.Id);
                        }
                        // Regather the orders from the DB now with Total Order
                        List<Order__c> list_OrdersWithBusinessCareFromDb = [select Id, CurrencyISOCode, Contract_Lookup__c, Total_Order__c, Sales_Org__c,
                                                                            (select Line_Number__c from Order_Line_Items__r)
                                                                            from Order__c where Id in :set_orderBusinessCare];
                        
                        Set<Id> set_ContractsWithBusinessCare = new Set<Id>();
                        for (Order__c orderBusinessCare : list_OrdersWithBusinessCareFromDb) {
                            set_ContractsWithBusinessCare.add(orderBusinessCare.Contract_Lookup__c);
                        }
                        Map<Id, Contract_Recurring_Charge__c> map_contractToBuisinessCareRC = new Map<Id, Contract_recurring_Charge__c>();
                        Map<Id, Integer> map_contractToMaxOrderLineNumber = new Map<Id, Integer>();
                        for(Contract_Recurring_Charge__c objContractRc : [SELECT Id, Contract_Tier_Set__r.Contract__c,
                                                                          Contract_Tier_Set__r.Name,
                                                                          Contract_Tier_Set__r.Contract__r.Product_Group__c,
                                                                          Contract_Tier_Set__r.Quote_Product__c,
                                                                          Contract_Tier_Set__r.Product__c,
                                                                          Contract_Tier_Set__r.Product__r.APN_Number__c,
                                                                          Contract_Tier_Set__r.Product__r.Unit_of_Measure__c,
                                                                          Contract_Tier_Set__r.Period_In_Months__c,
                                                                          Amount__c,
                                                                          Business_Care_Min_Revenue_Threshold__c,
                                                                          Business_Care_Max_Revenue_Threshold__c,
                                                                          Business_Care_Support_Fee_Percentage__c,
                                                                          Deferred__c
                                                                          FROM Contract_Recurring_Charge__c
                                                                          WHERE Active__c = true AND Is_Deleted__c = false and Type__c = 'Business Care'])
                        {
                            map_contractToBuisinessCareRC.put(objContractRc.Contract_Tier_Set__r.Contract__c, objContractRc);
                        }
                        List<Order_Line_Item__c> list_OliToSave = new List<Order_Line_Item__c>();
                        for (Order__c orderBusinessCare : list_OrdersWithBusinessCareFromDb) {
                            System.debug('Got order ' + orderBusinessCare.Id);
                            Contract_Recurring_Charge__c rc = map_contractToBuisinessCareRC.get(orderBusinessCare.Contract_Lookup__c);
                            System.debug('Got order ' + rc.Contract_Tier_Set__r.Id + ' name ' + rc.Contract_Tier_Set__r.Name);
                            // Are we above the minimum threshold
                            if (rc.Business_Care_Min_Revenue_Threshold__c == null || orderBusinessCare.Total_Order__c >= rc.Business_Care_Min_Revenue_Threshold__c) {
                                // Are we below the maximum threshold
                                if (rc.Business_Care_Max_Revenue_Threshold__c == null || orderBusinessCare.Total_Order__c <= rc.Business_Care_Max_Revenue_Threshold__c) {
                                    // Calculate the Support Fee. Default is 500
                                    Decimal supportCharge = 500;
                                    if (rc.Amount__c != null) {
                                        supportCharge = rc.Amount__c;
                                    }
                                    System.debug('supportCharge ' + supportCharge);
                                    Decimal businessCareCharge = supportCharge;
                                    Decimal supportPercent = 15;
                                    if (rc.Business_Care_Support_Fee_Percentage__c != null) {
                                        supportPercent = rc.Business_Care_Support_Fee_Percentage__c;
                                    }
                                    System.debug('supportPercent ' + supportPercent);
                                    System.debug('Total_Order__c ' + orderBusinessCare.Total_Order__c);
                                    Decimal percentCharge = orderBusinessCare.Total_Order__c * supportPercent / 100;
                                    System.debug('percentCharge ' + percentCharge);
                                    Decimal percentChargeRounded = cloudRoundPriceFloor(percentCharge);
                                    System.debug('percentChargeRounded ' + percentChargeRounded);
                                    if (percentChargeRounded > supportCharge) {
                                        businessCareCharge = percentChargeRounded;
                                    }
                                    System.debug('businessCareCharge ' + businessCareCharge);
                                    Order_Line_Item__c objOLI = createOrderLineItem(rc.Contract_Tier_Set__r, rc.Deferred__c, REVENUE_CLASSIFICATION_COMMITTED);
                                    if (orderBusinessCare.Sales_Org__c == 'Premier Edition') {
                                        setOrderLineItemUncommited(objOLI);
                                    }
                                    objOlI.Memo__c = 'Business Care';
                                    objOLI.Quantity__c = objOLI.BigMachines_Quantity__c = 1.0;
                                    objOLI.Net_Unit_Price__c = objOLI.Ext_Net_Price__c = objOLI.Sales_Price__c = objOLI.List_Price__c = businessCareCharge;
                                    objOLI.Order__c = orderBusinessCare.Id;
                                    objOLI.CurrencyISOCode = orderBusinessCare.CurrencyISOCode;
                                    list_OliToSave.add(objOLI);
                                }
                            }
                        }
                        if (list_OliToSave.size() > 0) {
                            // Force running of the trigger to update the order's Total_Order__c after inserting new Order Line Items
                            TriggerFlowManager.POPULATE_PPU_ORDER_TOTAL = true;
                            insert list_OliToSave;
                        }
                    }
                    // END iTrack 25634
                }
            }
            catch(Exception e) 
            {
                System.debug('Exception <<<< ' + e.getMessage());
                // Record exception in Log
                objJobLog.Exceptions__c += e.getMessage() + '\n';
                // Roll back changes in case of DML failure
                Database.rollback(objSP);
            }
        }
        @TestVisible
        private static void setOrderLineItemUncommited (Order_Line_Item__c objOLI) {
            System.Debug('BatchCreateCloudMonthlySalesOrders.setOrderLineItemUncommited Changing OLI to Uncommitted due to Premier Edition ' + objOLI);
            objOLI.POB_Type__c = POB_CLOUD_UNCOMMITTED;
            objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_UNCOMMITTED;
        }

        // *** Finish Method : Exception notifications and other final code ***
        global void finish(Database.BatchableContext BC) 
        {
            // Insert/Update Log record
            if(objJobLog != null) {
                objJobLog.Status__c = 'Completed';
                upsert objJobLog;
            }
        }
        
        // *** Create Order method ***  
        public Order__c createOrder(GCR_Content_Document_Detail__c objContract, String strOrderNameSuffixTemp)
        {
            // ECD Now that our contract may have either a Quote or a Zuora Quote we must use logic here to populate variables
            Id idOpportunity;
            Id idSoldTo;
            if (objContract.Quote__c != null) {
                System.Debug('createOrder: Standard Quote');
                idSoldTo = objContract.Quote__r.Sold_To_Name__c;
                idOpportunity = objContract.Quote__r.BigMachines__Opportunity__c;
            } else if (objContract.Zuora_Quote__r != null) {
                System.Debug('createOrder: Zuora Quote');
                idSoldTo = objContract.Zuora_Quote__r.zqu__Account__c;
                idOpportunity = objContract.Zuora_Quote__r.zqu__Opportunity__c;
            } else {
                System.Debug('createOrder: NO Quote!!');
            }
            
            Integer intMonth = Integer.valueOf(strMonth);
            Integer intYear = Integer.valueOf(strYear);
            
            Order__c objOrder = new Order__c();
            if (String.isBlank(strOrderNameSuffixTemp)) {
                objOrder.Name = objContract.Name + '#' + objInfo.month + '-' + objInfo.year;
            } else {
                objOrder.Name = objContract.Name + '#' + objInfo.month + '-' + objInfo.year + '#' + strOrderNameSuffixTemp;
            }
            objOrder.RecordTypeId = (Id)Label.Cloud_Monthly_Order_RecordTypeId;
            objOrder.Date_Submitted__c = Datetime.now();
            
            // Set Order Date
            if (objContract.Order_Date_Option__c == 'Current Date') {
                objOrder.Order_Date__c = Date.today();
            } else if (strDay == '1') {
                Date dtOrderDate = Date.newInstance(intYear,intMonth,Date.daysInMonth(intYear,intMonth));
                objOrder.Order_Date__c = dtOrderDate;
            } else {
                Date dtOrderDate = Date.newInstance(intYear,intMonth,Integer.valueOf(strDay) - 1);
                objOrder.Order_Date__c = dtOrderDate.addMonths(1);
            }
            
            // Set Maintenance Dates
            if (strDay == '1') {
                objOrder.Maintenance_Start__c = Date.newInstance(intYear,intMonth, 1);
                objOrder.Maintenance_End__c = Date.newInstance(intYear,intMonth,Date.daysInMonth(intYear,intMonth));
            } else {
                objOrder.Maintenance_Start__c = Date.newInstance(intYear,intMonth, Integer.valueOf(strDay));
                Date dtOrderDate = Date.newInstance(intYear,intMonth,Integer.valueOf(strDay) - 1);
                objOrder.Maintenance_End__c = dtOrderDate.addMonths(1);
            }
            
            objOrder.PO_Date__c = objOrder.Order_Date__c;
            objOrder.Order_Type__c = 'Revenue';
            objOrder.Status__c = 'In Progress';
            objOrder.Contract_Lookup__c = objContract.Id;
            objOrder.Month__c = objInfo.month; // Use what the user requested not the possible back dated month calculated in the ctor
            objOrder.Year__c = objInfo.year; // Use what the user requested not the possible back dated month calculated in the ctor
            objOrder.End_User_Name__c = objContract.Account_Name__c;
            // iTracks 21126
            objOrder.Bill_To_Name__c = idSoldTo;
            objOrder.Ship_To_Name__c = objContract.Account_Name__c;
            // iTracks 21126
            objOrder.Sold_To_Name__c = idSoldTo;
            objOrder.Subsidaries__c = objContract.Account_Name__r.Subsidary__c;
            objOrder.License_FYM_detail__c = 'Cloud Billing Order';
            objOrder.Opportunity_Type__c = 'GEN_Opportunity_Record_Type_New';
            objOrder.Delivery_Method__c = 'Electronic';
            //objOrder.PO_Number__c = String.isBlank(objContract.Quote__r.Order_PO_Number__c) ? 'N/A' : objContract.Quote__r.Order_PO_Number__c;
            objOrder.PO_Number__c = String.isBlank(objContract.PO__c) ? 'N/A' : objContract.PO__c;
            if (objContract.Net_Days_Override__c != null) {
                objOrder.Payment_Terms__c = objContract.Net_Days_Override__c;
            }
            if (objContract.Direct_Sales_Rep_Override__c != null) {
                objOrder.Direct_Sales_Rep_1__c = objContract.Direct_Sales_Rep_Override__c;
            }
            objOrder.CurrencyISOCode = objContract.CurrencyISOCode;
            // Flag Set in custom settings at org level
            objOrder.ERP_Hold__c = Global_Configuration_Settings__c.getOrgDefaults().Billing_Orders_Hold__c;
            objOrder.Opportunity__c = idOpportunity;
            objOrder.Zuora_Quote__c = objContract.Zuora_Quote__c;
            objOrder.Sales_Org__c = objContract.Product_Group__c;//Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c; //Product_Group__c;
            //Anju April 24 - For PES and PCS these fields need different values
            if(objOrder.Sales_Org__c == 'PureEngage Subscription' || objOrder.Sales_Org__c == 'PureConnect Subscription')
            {
                objOrder.License_FYM_detail__c = 'Subscription Order';
                objOrder.Numb_of_Maint_Months__c = 1;
                objOrder.Quote__c = objContract.Quote__c;
                objOrder.Bypass_Service_Contract__c = true;
            } else if (objOrder.Sales_Org__c == 'Premier Edition') {
                objOrder.License_FYM_detail__c = 'Cloud Premier Billing Order';
            }
            objOrder.Master_Order_Number__c = objContract.Quote__r.Order__r.Name;
            
            if (mapMasterOrderIdToActiveSubscription != null && mapMasterOrderIdToActiveSubscription.containsKey(objContract.Quote__r.Order__c)) {
                System.Debug('createOrder: Found Subscription Object and populating the Go Live Date');
                Subscription__c objSubscription = mapMasterOrderIdToActiveSubscription.get(objContract.Quote__r.Order__c);
                objOrder.Desired_Go_Live_Date__c = objSubscription.Start_Date__c;
            } else {
                System.Debug('createOrder: Did not find Subscription Object, cannot populate Go Live Date');
            }
            
            return objOrder;
        }
        
        @TestVisible
        private Order_Line_Item__c createProductOrderLineItem(Product2 product, String strUniqueName) {
            Order_Line_Item__c objOLI = new Order_Line_Item__c();
            objOLI.Name = strUniqueName;
            objOLI.Description__c = strUniqueName;
            objOLI.RecordTypeId = (Id)Label.Cloud_Monthly_Billing_Order_Line_RecordTypeId;
            objOLI.Line_Number__c = ++intLineCount;
            //objOLI.Quote_Product__c = objContractTierSet.Quote_Product__c;
            objOLI.Product__c = product.Id;
            objOLI.APN_Number__c = product.APN_Number__c;
            objOLI.Unit_of_Measure__c = product.Unit_of_Measure__c;
            objOLI.Tier_Set_Period_In_Months__c = 1;
            objOLI.Revenue_Classification__c = REVENUE_CLASSIFICATION_COMMITTED;
            objOLI.POB_Type__c = POB_CLOUD_COMMITTED;
            return objOLI;
            
        }
        
        // Store a deferred setting
        private Order_Line_Item__c createOrderLineItem(Contract_Tier_Set__c objContractTierSet,Boolean bolDeferred, String strRevenueClassification) {
            Order_Line_Item__c objOLI = createOrderLineItem (objContractTierSet, strRevenueClassification);
            objOLI.Deferred__c = bolDeferred;
            return objOLI;
        }
        
        public String derrivePOBFromRevenueClassification(Contract_Tier_Set__c objContractTierSet, String strRevenueClassification) {
            String strProductGroup = '';
            if (objContractTierSet != null) {
                strProductGroup = objContractTierSet.Contract__r.Product_Group__c;
            }
            System.debug('derrivePOBFromRevenueClassification: Calculating POB Type from Product Group ' + strProductGroup);
            if (strProductGroup.contains('Subscription')) {
                if (strRevenueClassification == REVENUE_CLASSIFICATION_COMMITTED) {
                    return POB_PREMISE_COMMITTED;
                } else if (strRevenueClassification == REVENUE_CLASSIFICATION_UNCOMMITTED) {
                    return POB_PREMISE_UNCOMMITTED;
                } else if (strRevenueClassification == REVENUE_CLASSIFICATION_OVERAGE) {
                    return POB_PREMISE_UNCOMMITTED;
                }
            } else {
                if (strRevenueClassification == REVENUE_CLASSIFICATION_COMMITTED) {
                    return POB_CLOUD_COMMITTED;
                } else if (strRevenueClassification == REVENUE_CLASSIFICATION_UNCOMMITTED) {
                    return POB_CLOUD_UNCOMMITTED;
                } else if (strRevenueClassification == REVENUE_CLASSIFICATION_OVERAGE) {
                    return POB_CLOUD_UNCOMMITTED;
                }
            }
            return POB_NOT_APPLICABLE;
        }
        // *** Create Order Line method ***
        private Order_Line_Item__c createOrderLineItem(Contract_Tier_Set__c objContractTierSet, String strRevenueClassification)
        {
            Order_Line_Item__c objOLI = new Order_Line_Item__c();
            if (objContractTierSet.Contract_Tier_Set_Month__r.size() > 0) {
                objOLI.Contract_Tier_Set_Month__c = objContractTierSet.Contract_Tier_Set_Month__r[0].Id;
            }
            objOLI.Name = objContractTierSet.Name;
            objOLI.RecordTypeId = (Id)Label.Cloud_Monthly_Billing_Order_Line_RecordTypeId;
            system.debug(intLineCount);
            objOLI.Line_Number__c = ++intLineCount;
            objOLI.Description__c = objContractTierSet.Name;
            objOLI.Quote_Product__c = objContractTierSet.Quote_Product__c;
            objOLI.Product__c = objContractTierSet.Product__c;
            objOLI.APN_Number__c = objContractTierSet.Product__r.APN_Number__c;
            objOLI.Unit_of_Measure__c = objContractTierSet.Product__r.Unit_of_Measure__c;
            try {
                objOLI.Tier_Set_Period_In_Months__c = integer.ValueOf(objContractTierSet.Period_In_Months__c);
            } catch (System.TypeException te) {
                System.debug('Period in Months is not convertable to Integer: ' + objContractTierSet.Period_In_Months__c + ' setting to period of 1 month');
                objOLI.Tier_Set_Period_In_Months__c = 1;
            }
            objOLI.Installment_Plan__c = false;
            objOLI.Revenue_Classification__c = strRevenueClassification;
            objOLI.POB_Type__c = derrivePOBFromRevenueClassification(objContractTierSet, strRevenueClassification);
            return objOLI;
        }
        
        public Order_Line_Item__c createOrderLineItem(Product2 objProduct, String strRevenueClassification)
        {
            System.debug('createOrderLineItem Product Name ' + objProduct.Name);
            Order_Line_Item__c objOLI = new Order_Line_Item__c();
            objOLI.RecordTypeId = (Id)Label.Cloud_Monthly_Billing_Order_Line_RecordTypeId;
            objOLI.Line_Number__c = ++intLineCount;
            objOLI.Name = objProduct.Name;
            objOLI.Description__c = objProduct.Name;
            objOLI.Product__c = objProduct.Id;
            objOLI.APN_Number__c = objProduct.APN_Number__c;
            objOLI.Tier_Set_Period_In_Months__c = 1;
            objOLI.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
            objOLI.Installment_Plan__c = false;
            objOLI.Revenue_Classification__c = strRevenueClassification;
            objOLI.POB_Type__c = derrivePOBFromRevenueClassification(null, strRevenueClassification);
            return objOLI;
        }
        
        public static Decimal cloudRoundPriceFloor(Decimal priceFullPrecision) {
            Decimal PRECISION = 100000; // 5 Decimal precision in price
            Decimal multiplyUp = (PRECISION*priceFullPrecision);
            System.Debug('multiplyUp ' + multiplyUp);
            Decimal flooredVal = multiplyUp.round(System.RoundingMode.FLOOR);
            System.Debug('flooredVal ' + flooredVal);
            Decimal priceRounded = flooredVal/PRECISION;
            System.Debug('priceRounded ' + priceRounded);
            return priceRounded;
        }
        
        public String getCloudDeploymentName(Contract_Tier_Set_Month__c objContractTierSetMonth) {
            if (mapCloudDeploymentHashToCloudDeployment == null) {
                System.Debug('mapCloudDeploymentHashToCloudDeployment is null');
                return null;
            }
            Cloud_Deployment__C objCloudDeployment = mapCloudDeploymentHashToCloudDeployment.get(objContractTierSetMonth.Source_Name__c + '#' + objContractTierSetMonth.Platform_Id__c);
            String strCloudDeploymentInfo = objContractTierSetMonth.Platform_Id__c;
            if (objCloudDeployment != null) {
                strCloudDeploymentInfo = objCloudDeployment.Name;
            }
            return strCloudDeploymentInfo;
        }
        
        public Integer getMonthOfBillingCycle(Date dtPricingStartDt, Integer intBillingTerm, Integer intDay, Integer intMonth, Integer intYear) {
            Date orderMonth = Date.newInstance(intYear, intMonth, intDay);
            Integer monthsBetween = dtPricingStartDt.monthsBetween(orderMonth);
            /*
    Date orderMonth = Date.newInstance(Integer.valueOf(strYear), Integer.valueOf(strMonth), 1);
    Integer monthsBetween = orderMonth.monthsBetween(objContract.Pricing_Start_Date__c);
    String billingTermStr = objContRecCharge.Contract_Tier_Set__r.RC_Period__c;
    Integer billingTerm = Integer.valueOf(billingTermStr);
    
    // If the remainer of months = 0 we are on a month beginning the billing period
    Integer applyChargeInt = math.mod(monthsBetween, billingTerm);
    */
            // If the remainer of months = 0 we are on a month beginning the billing period
            Integer intMonthOfBillingCycle = math.mod(monthsBetween, intBillingTerm);
            
            System.debug('getMonthOfBillingCycle: b' + monthsBetween + '/'  + intBillingTerm + 'm' + intMonthOfBillingCycle);
            return intMonthOfBillingCycle;
        }
        
        
        
        
        
        //Added by Anju April 18 -- Create base package child order lines, when base package for PES or PCS burst, all lines items in the base package need to be inserted as order lines
        Static Map<String,Decimal> mapBaseLinesWeightage;
        public void createBasePackageLinesforOrder(Contract_Tier_Set__c objContractTierSet, Decimal decBasePackageSum, Decimal decQuantity){
            try{
                //Create lines with % splits
                system.debug('Inside order line split'+ decBasePackageSum + 'QTY:' +decQuantity);
                list_OrderLineItemsForBase = new List<Order_Line_Item__c>();
                Order_Line_Item__c objLineitem;
                Decimal decTotalSum = 0;
                mapBaseLinesWeightage = new Map<String,Decimal>();
                system.debug(intLineCount);
                intLineCount = 1;
                for(Product_Group_Item__c objpGL: [SELECT id,Product_Group__c,Product__c,Product__r.name,Price_Weightage__c,
                                                   Product_Group__r.Pricing_Model__c,Product_Group__r.Offering_Type__c 
                                                   FROM Product_Group_Item__c 
                                                   WHERE Product_Group__r.Offering_Type__c INCLUDES (:objContractTierSet.Contract__r.quote__r.offering_type__c) 
                                                   AND Product_Group__r.Group_Type__c = 'Base Package' 
                                                   AND Product_Group__r.Active__c = true])
                {
                    if(objpGL.Product_Group__r.Pricing_Model__c == objContractTierSet.Contract__r.quote__r.Pricing_Model__c || (objpGL.Product_Group__r.Offering_Type__c == 'PureEngage Subscription' && objpGL.Product_Group__r.Pricing_Model__c == 'User')) 
                    {                               
                        mapBaseLinesWeightage.put(objpGL.Product__c,objpGL.Price_Weightage__c / 100);
                        objLineitem = new Order_Line_Item__c();
                        objLineitem.name = objpGL.Product__r.name;
                        objLineitem.Product__c = objpGL.Product__c;
                        objLineitem.BigMachines_Quantity__c = decQuantity;
                        objLineitem.Quantity__c = decQuantity;
                        objLineitem.Net_Unit_Price__c = ((decBasePackageSum / decQuantity) * (objpGL.Price_Weightage__c / 100));
                        objLineitem.Ext_Net_Price__c = objLineitem.Net_Unit_Price__c * decQuantity;
                        objLineitem.List_Price__c = objLineitem.Net_Unit_Price__c;
                        objLineitem.Sales_Price__c = objLineitem.Net_Unit_Price__c.setscale(2);
                        objLineitem.Year__c = 1;
                        objLineitem.Line_Number__c = ++intLineCount;
                        decTotalSum += Math.FLOOR((objLineitem.Sales_Price__c * objLineitem.BigMachines_Quantity__c)*100)/100;
                        system.debug(objLineitem.Line_Number__c);
                        objLineitem.POB_Type__c = POB_PREMISE_UNCOMMITTED;
                        objLineitem.Revenue_Classification__c = REVENUE_CLASSIFICATION_OVERAGE;
                        list_OrderLineItemsForBase.add(objLineitem);
                    }
                }
                
                intLineCountSubscription = intLineCount;
                system.debug(decBasePackageSum + ' ' +decTotalSum + ' decBasePackageSum - decTotalSum ' +(decBasePackageSum - decTotalSum));
                if(decBasePackageSum - decTotalSum > 0 && list_OrderLineItemsForBase.size() > 0)
                    list_OrderLineItemsForBase[0].Sales_Price__c += ((decBasePackageSum - decTotalSum) / objLineitem.BigMachines_Quantity__c);
                    
            }   catch(exception e){System.debug('Error:'+e.getMessage()+e.getStackTraceString());}
        }
        
        
        //Added by Anju April 18 -- Create base package Quote lines
        Static String strBundleLine;
        public static List<BigMachines__Quote_Product__c> createBasePackageLinesforQuote(BigMachines__Quote_Product__c basepackageproduct, String strofferingType, String strPricingModel){
            List<BigMachines__Quote_Product__c> listQuoteProducts = new List<BigMachines__Quote_Product__c>();
            try{
                //Create lines with % splits
                
                BigMachines__Quote_Product__c objQuoteProduct;
                System.debug(strofferingType+''+strPricingModel+''+basepackageproduct.Ext_Net_Price__c);
                for(Product_Group_Item__c objpGL: [SELECT id,Product_Group__c,Product__c,Product__r.name,Product__r.APN_Number__c,
                                                   Price_Weightage__c,Product_Group__r.Pricing_Model__c, Product_Group__r.Offering_Type__c
                                                   FROM Product_Group_Item__c 
                                                   WHERE Product_Group__r.Offering_Type__c INCLUDES (:strofferingType) 
                                                   AND Product_Group__r.Group_Type__c = 'Base Package' 
                                                   AND Product_Group__r.Active__c = true])
                {
                    if(objpGL.Product_Group__r.Pricing_Model__c == strPricingModel || (objpGL.Product_Group__r.Pricing_Model__c == 'User' && objpGL.Product_Group__r.Offering_Type__c == 'PureEngage Subscription'))
                    {
                        strBundleLine = objpGL.Product_Group__c;
                        system.debug(strBundleLine);
                        objQuoteProduct= new BigMachines__Quote_Product__c();
                        objQuoteProduct.name = objpGL.Product__r.name;
                        objQuoteProduct.APN_Number__c = objpGL.Product__r.APN_Number__c;
                        objQuoteProduct.BigMachines__Quote__c = basepackageproduct.BigMachines__Quote__c;
                        objQuoteProduct.Product__c = objpGL.Product__c;
                        objQuoteProduct.BigMachines__Product__c = objpGL.Product__c;
                        objQuoteProduct.BigMachines__Quantity__c = basepackageproduct.Quantity__c;
                        objQuoteProduct.Quantity__c = basepackageproduct.Quantity__c;
                        objQuoteProduct.bundle__c = strBundleLine;
                        objQuoteProduct.bundle_line__c = basepackageproduct.id;
                        objQuoteProduct.Net_Unit_Price__c = ((basepackageproduct.Ext_Net_Price__c / objQuoteProduct.Quantity__c) * (objpGL.Price_Weightage__c / 100));
                        objQuoteProduct.BigMachines__Sales_Price__c = objQuoteProduct.Net_Unit_Price__c;
                        objQuoteProduct.List_Price__c = objQuoteProduct.Net_Unit_Price__c;
                        objQuoteProduct.List_Price_1__c = objQuoteProduct.Net_Unit_Price__c;
                        objQuoteProduct.Ext_Net_Price_1__c = objQuoteProduct.Net_Unit_Price__c * objQuoteProduct.Quantity__c;
                        objQuoteProduct.Ext_Net_Price__c = objQuoteProduct.Net_Unit_Price__c * objQuoteProduct.Quantity__c;
                        objQuoteProduct.Ext_List__c = objQuoteProduct.List_Price__c * objQuoteProduct.Quantity__c;
                        listQuoteProducts.add(objQuoteProduct);
                    }
                }
                
            }   catch(exception e){System.debug('Error:'+e.getMessage()+e.getStackTraceString());}
            return listQuoteProducts;
        }
        
        
        
        // Added By Rony Joseph - March 29 2018  - Start
        // **Creation of Auto Opportunity and Quote **
        
        public static void createAutoOpportunityQuote(map<id,decimal> map_BurstContractTierSet, map<id,decimal> map_BurstContractTierSetPrice){
            try{
                String strObjName;
                String strWhereCondition;
                Opportunity objOpportunity,objClonedOpportunity;
                //List of Contract Tier Sets to insert as Quote Products
                list<Contract_Tier_Set__c> list_CTR = new list<Contract_Tier_Set__c>();
                //List of Quote Products to clone
                list<BigMachines__Quote_Product__c> list_QuotePro = new list<BigMachines__Quote_Product__c>();
                //List of Account Address to insert
                list<Account_Order_Address__c> list_AccountAddresstoInsert = new list<Account_Order_Address__c>();
                
                list_CTR =  [SELECT id,name,Contract__c,quote_product__c,Product__c,Product__r.name,Product__r.APN_Number__c,Contract__r.Quote__c,
                             Contract__r.Quote__r.BigMachines__Opportunity__r.id,quote_product__r.List_price__c,quote_product__r.Net_Unit_Price__c,
                             quote_product__r.BigMachines__Sales_Price__c
                             FROM Contract_Tier_Set__c where id in :map_BurstContractTierSet.keyset()];
                
                //Opportunity Creation
                ID objOpportunityID = list_CTR[0].Contract__r.Quote__r.BigMachines__Opportunity__r.id;
                strobjName = 'Opportunity';
                strWhereCondition = 'id  = :objOpportunityID';
                objClonedOpportunity = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName,strWhereCondition));
                
                objOpportunity = objClonedOpportunity.Clone(false,true,false,false);
                objOpportunity.ParentOpportunity__c = objOpportunityID;
                objOpportunity.name = objOpportunity.name+'– Increase Minimum';
                objOpportunity.stageName = '5.Purchase Solution';
                objOpportunity.recordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
                objOpportunity.Type='Existing Business - Expansion';    
                objOpportunity.Win_Loss_Status__c =null;
                objOpportunity.ForecastStatus__c = '3.Expected';
                objOpportunity.PureSuccess_Offer__c = 'NA';
                objOpportunity.Offering_Detail__c = 'Amendment - Burst';
                objOpportunity.WonLostCancelledReason__c = 'Existing business addon';
                objOpportunity.Detail_on_Won_Lost_Reason__c ='Addon/Expansion of existing business';
                objOpportunity.Factors_Influencing_Price__c = 'Contractual price with the customer';
                objOpportunity.Is_Business_Consulting_Engaged__c='No';
                objOpportunity.Is_Solution_Consulting_Engaged__c = 'No';
                objOpportunity.CloseDate = System.Today()+30;
                //Clear totals
                objOpportunity.ACV_Year_2__c = null;
                objOpportunity.ACV_Subscription_Only__c = null;
                objOpportunity.Total_Annual_Contract_Value__c =  null;
                objOpportunity.License_Amount__c = null;
                objOpportunity.Primary_Quote__c = null;
                
                System.debug('objOpportunity:'+objOpportunity);
                insert objOpportunity;
                
                //Quote Creation
                ID objQuoteID = list_CTR[0].Contract__r.Quote__c;
                strobjName = 'BigMachines__Quote__c';
                strWhereCondition = 'id = :objQuoteID';
                BigMachines__Quote__c objquote = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName,strWhereCondition));
                BigMachines__Quote__c objClonedQuote = objquote.Clone(false,true,false,false);
                objClonedQuote.BigMachines__Status__c='Quote in Progress';
                //objClonedQuote.name = objClonedQuote.name+'– Increase Minimum';
                objClonedQuote.BigMachines__Opportunity__c = objOpportunity.id;
                objClonedQuote.Contracts__c = list_CTR[0].Contract__c;
                objClonedQuote.Order_Type__c = 'Amend Subscription';
                
                //Clear totals
                objClonedQuote.Order__c = null;
                objClonedQuote.PureSuccess__c = null;
                objClonedQuote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c = null;
                objClonedQuote.Annual_Contract_Value_1__c = null;
                objClonedQuote.Annual_Contract_Value_2__c = null;
                objClonedQuote.Total_Contract_Value_1__c = null;
                objClonedQuote.Total_Contract_Value_2__c = null;
                objClonedQuote.Total_Subtotal_1__c = null;
                objClonedQuote.Total_Subtotal_2__c = null;
                objClonedQuote.BigMachines__Total__c = null;
                objClonedQuote.Total__c = null;
                objClonedQuote.Total_List_Price__c = null;
                objClonedQuote.Amount_Due_At_Anniversary__c = null;
                //objClonedQuote.BigMachines__Total_Amount__c = null;
                objClonedQuote.Total_Software__c =  null;
                objClonedQuote.Cloud_Total__c =  null;
                objClonedQuote.Subscription_Start_Date__c = system.today();
                objClonedQuote.No_Of_Months__c = objClonedQuote.Subscription_Start_Date__c.monthsBetween(objClonedQuote.Subscription_End_Date__c);
                
                System.debug('###objClonedQuote'+objClonedQuote); 
                insert objClonedQuote;
                objClonedQuote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id =: objClonedQuote.id].Quote_Number__c;
                update objClonedQuote;
                
                //Quote Product creation
                strofferingType = objClonedQuote.offering_type__c;
                strPricingModel = objClonedQuote.Pricing_Model__c;
                Boolean blnBasePESadded = false;
                Boolean blnBasePCSadded = false;
                BigMachines__Quote_Product__c basepackageproduct;
                for(Contract_Tier_Set__c objcontracttierset : list_CTR)
                {
                    BigMachines__Quote_Product__c objQuotePro = new BigMachines__Quote_Product__c();
                    objQuotePro.name = objcontracttierset.Product__r.name;
                    objQuotePro.APN_Number__c = objcontracttierset.Product__r.APN_Number__c;
                    objQuotePro.BigMachines__Quote__c = objClonedQuote.id;
                    objQuotePro.BigMachines__Quantity__c = map_BurstContractTierSet.get(objcontracttierset.id);
                    objQuotePro.Quantity__c = map_BurstContractTierSet.get(objcontracttierset.id);
                    objQuotePro.BigMachines__Product__c = objcontracttierset.Product__c;
                    //Getting price from quote product
                    if(objcontracttierset.quote_product__c != null)
                    {
                        System.debug(objcontracttierset.quote_product__r.Net_Unit_Price__c);
                        objQuotePro.BigMachines__Sales_Price__c = objcontracttierset.quote_product__r.BigMachines__Sales_Price__c;
                        objQuotePro.List_Price__c = objcontracttierset.quote_product__r.List_price__c;
                        objQuotePro.Net_Unit_Price__c = objcontracttierset.quote_product__r.Net_Unit_Price__c;
                        
                    }
                    else
                    {
                        objQuotePro.BigMachines__Sales_Price__c = map_BurstContractTierSetPrice.get(objcontracttierset.id);
                        objQuotePro.List_Price__c = map_BurstContractTierSetPrice.get(objcontracttierset.id);
                        objQuotePro.Net_Unit_Price__c = map_BurstContractTierSetPrice.get(objcontracttierset.id);
                        
                    }
                    
                    objQuotePro.List_Price_1__c = objQuotePro.List_Price__c;
                    objQuotePro.Ext_List__c = objQuotePro.List_Price__c * objQuotePro.BigMachines__Quantity__c;
                    objQuotePro.Ext_Net_Price__c = objQuotePro.Net_Unit_Price__c * objQuotePro.BigMachines__Quantity__c;
                    objQuotePro.Ext_Net_Price_1__c = objQuotePro.Ext_Net_Price__c;
                    
                    if(objcontracttierset.name == 'PureEngage Base Package' || objcontracttierset.name == 'PureConnect Base Package')
                        basepackageproduct = objQuotePro;
                    else
                        list_QuotePro.add(objQuotePro);
                }
                
                if(basepackageproduct != null)
                {
                    insert basepackageproduct;
                    list_QuotePro.addall(createBasePackageLinesforQuote(basepackageproduct,strofferingType,strPricingModel));
                    system.debug(strBundleLine);
                    basepackageproduct.bundle__c = strBundleLine;
                    update basepackageproduct;
                }
                if(list_QuotePro.size() > 0)
                    insert list_QuotePro;
                
                //Make quote primary, update opportunity totals and create opportunity line items
                MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objClonedQuote.id));
                OpportunityQuotes.populateOpportunityProducts(String.valueof(objClonedQuote.id));
                
                //Create address
                strobjName = 'Account_Order_Address__c';
                strWhereCondition = 'Quote__C = :objQuoteID'; 
                Account_Order_Address__c objClonedAccountOrder;
                list<Account_Order_Address__c> list_Accountaddr =  Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName,strWhereCondition));
                for(Account_Order_Address__c objAccountOrder : list_accountaddr){
                    objClonedAccountOrder=objAccountOrder.Clone(false,true,false,false);
                    objClonedAccountOrder.Order__c=null;
                    objClonedAccountOrder.Quote__c =  objClonedQuote.id;
                    list_accountAddresstoInsert.add(objClonedAccountOrder);
                }
                
                insert list_AccountAddresstoInsert;
            }  catch(exception e){System.debug('Error:'+e.getMessage()+e.getStackTraceString());}
        }
        // Added By Rony Joseph - March 29 2018  - End
        
    }