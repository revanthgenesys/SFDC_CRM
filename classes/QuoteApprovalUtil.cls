//Naresh Kumar  06/23/2014
public without sharing class QuoteApprovalUtil {
    public final static string STATUS_INACTIVE = 'In-Active';
    public final static string STATUS_PENDING = 'Pending';
    public final static string STATUS_APPROVED = 'Approved';
    public final static string STATUS_REJECTED = 'Rejected';
    public final static string STATUS_CANCELLED = 'Cancelled';
    public final static string STATUS_APPROVER_NOTIFICATION_ONLY = 'Notification Only'; 
    public final static string QUOTE_STATUS_REJECTED = 'Quote Rejected';
    public final static string QUOTE_STATUS_APPROVED = 'Quote Approved';
    public final static string QUOTE_STATUS_PENDING = 'Quote Approval Pending';
    public final static string QUOTE_STATUS_REVISION_PENDING = 'Revision Pending';  
    public final static String APPROVAL_TYPE_DISCOUNT = 'Discount Size';
    public final static String APPROVAL_TYPE_ELA = 'ELA';    
    public final static String APPROVAL_TYPE_PRICING_MODEL_CONCURRENT = 'Pricing Model - Concurrent';   
    public final static String APPROVAL_TYPE_EXPIRATION_DATE = 'Expiration Date';   
    public final static String APPROVAL_TYPE_SPECIAL_OFFER_TERMS = 'Special Offer Terms';
    public final static String APPROVAL_TYPE_CARE_OVERRIDE = 'Care Override';
    public final static String APPROVAL_TYPE_DEAL_SIZE = 'Deal Size';
    public final static String APPROVAL_TYPE_TERM_REDUCED = 'Term Reduced';
    public final static String APPROVAL_TYPE_TERM_INCREASED = 'Term Increased';
    public final static String APPROVAL_TYPE_SERVICE_LEVEL_DECLINE = 'Service Level - Decline';
    public final static String APPROVAL_TYPE_REVISION = 'Revision';
    public final static String APPROVAL_TYPE_THIRD_PARTY = '3rd Party';
    public final static String APPROVAL_TYPE_PRODUCT_SPECIFIC = 'Product Specific';
    public final static String APPROVAL_TYPE_PRODUCT_MANAGEMENT = 'Product Management';     
    public final static String APPROVAL_TYPE_CAD_OVERRIDE = 'CAD Override';
    public final static String APPROVAL_TYPE_PREMIUM_CARE = 'Premium Care';
    public final static String APPROVAL_TYPE_GU_OVERRIDE = 'GU Override';
    public final static String APPROVAL_TYPE_BEP_OVERRIDE = 'BEP Override'; 
    public final static String APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS = 'Additional Legal Terms';    
    public final static String APPROVAL_TYPE_EDITABLE_LIST_PRICE = 'Editable List Price';
    public final static String APPROVAL_TYPE_MINOR_QUOTE_CHANGE_APPROVAL = 'Minor Quote Change Approval';
    public final static String QUOTE_REJECTED_BEFORE_APPROVAL = 'Quote Rejected Before Approval';
    public final static String QUOTE_REVISED_BEFORE_APPROVAL = 'Quote Revised Before Approval';     
    public final static String NO_APPROVAL_REQUIRED = 'No Approval Required';
    public final static String REQUIRED_FOR_ALL_ORDERS = 'Required for all Orders';
    public final static String REQUIRED_FOR_NEW_ORDERS_ONLY = 'Required for New Orders Only';
    public final static String NOTIFICATION_ONLY = 'No Approval Required - Email Notification when Quoted'; 
    public final static String MINOR_QUOTE_CHANGE_ONLY = 'Minor Quote Change Only';
    public final static String MINOR_QUOTE_AND_EXPIRATION_DATE = 'Minor Quote And Expiration Date'; 
    public final static String EXPIRATION_DATE_ONLY = 'Expiration Date Only';
    public final static String DECLINE = 'Decline';
    public final static String PREMIUM = 'Premium';
    public final static String PRODUCT_TYPE_GU = 'GU';
    public final static String PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE = 'Product - System License';
    public final static String PRODUCT_TYPE_PRODUCT_HARDWARE = 'Product - Hardware';
    public final static Integer STANDARD_TERM_MONTHS = 12;
    public final static Integer STANDARD_TERM_DAYS = 365;
    public final static String GC_THRESHOLD_GREATER_THAN_TWO = '> 2';
    public final static String GC_THRESHOLD_GREATER_THEN_OR_EQUAL_TO_THREE = '>= 3';
    public final static String APPROVAL_BY_PASSED = 'Approval By-passed';
    
    public final static String APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM = 'Initial Subscription Term';
    public final static String APPROVAL_TYPE_RAMP_PERIOD = 'Ramp Period';
    public final static String APPROVAL_TYPE_PAYMENT_TERMS = 'Payment Terms';
    public final static String APPROVAL_TYPE_BILLING_PERIOD = 'Billing Period';
    public final static String APPROVAL_TYPE_MONTHLY_MINIMUM = 'PureCloud Monthly Minimum';
    public final static String APPROVAL_TYPE_AGENT_MINIMUM = 'Agent Minimum';
    public final static String APPROVAL_TYPE_MAX_BUSINESS_USERS = 'Max Business Users';
    public final static String APPROVAL_TYPE_BUSINESS_USER_RATIO = 'Business User Ratio';
    public final static String APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR = 'Business Exceptions CMRR';
    
    public final static String APPROVAL_TYPE_PC_Credit = 'PureCloud Credit';
    public final static String APPROVAL_TYPE_PC_Trial = 'PureCloud Trial';
    public final static String APPROVAL_TYPE_PCC_Credit = 'PureConnect Cloud Credit';
    public final static String APPROVAL_TYPE_PEC_Credit = 'PureEngage Cloud Credit';
    
    
    public final static String APPROVAL_TYPE_PSDISCOUNT = 'Professional Services Discount';
    public final static String APPROVAL_TYPE_HARDWAREDISCOUNT = 'Hardware Discount';
    public final static String APPROVAL_TYPE_SOFTWAREDISCOUNT = 'Software Discount';
    public final static String APPROVAL_TYPE_OVERAGEDISCOUNT = 'Overage Discount';
    public final static String APPROVAL_TYPE_TCVREDUCTION = 'TCV Reduction';    
    public final static String APPROVAL_TYPE_DEAL_SCORE_CLOUD = 'Deal-Score Cloud';
    public final static String APPROVAL_TYPE_THIRDPARTY = 'Third Party Discount';
    public final static String APPROVAL_TYPE_Cloud_Deal = 'Cloud Deal';
    public final static String APPROVAL_TYPE_BILLING_CATEGORY = 'Billing Category';//  //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890
    public final static String APPROVAL_RENEWAL_SUBSCRIPTION_TERM = 'Renewal Subscription Term';//  //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890
    
    
    public static BigMachines__Quote__c getQuote(Id quoteId){
        //Getting current quote record
		// Ankaiah - Dec 02 2019 -- Added one field in the query for Enhancement INC0417163
        return [SELECT Quote_Business_Type__c, Don_t_Resubmit_to_Approved_Approvers__c,Migration_Credit__c,Billing_Category__c,Renewal_Subscription_Term__c,
                BigMachines__Opportunity__r.Country_Region__c,BigMachines__Opportunity__r.Offering_Detail__c, BigMachines__Status__c,
                BigMachines__Opportunity__r.Country_Sub_Region__c, BigMachines__Opportunity__r.Country__r.RU__c, 
                Total_Discount_Genesys_and_Third_Party__c, ELA__c, Pricing_Model__c, Expiration_Date__c, Include_Special_Offer_in_Output__c,
                Genesys_Care_Rate__c, Genesys_Care_Default_Pricing_Percentage__c, BigMachines__Total__c,
                Duration_Unit__c, Order_Numb_of_Maint_Days__c, Order_Numb_of_Maint_Months__c,
                Service_Level__c, Revise_Minor__c, Name, CreatedDate, CAD_Override__c, Approval_Submission_Date__c,
                BigMachines__Opportunity__r.Country_DAP__c, BigMachines__Opportunity__r.New_DAP_Region__c,
                Total_Discount_Genesys_Products_Only__c, Offering_Type__c, Additional_Legal_Terms__c,
                Editable_List_Price_Approval_Required__c, CurrencyIsoCode, Total_List_Price__c,
                BigMachines__Opportunity__c, Quote_Opportunity_Type__c, Special_Offer_Terms__c, Deal_Qualification__c,
                Minor_Quote_Change_Approval__c, Sold_To_Name__r.Country__r.RU__c, X3rd_Party_Override__c, Annual_Contract_Value__c,
                Require_Separate_Quote_for_Genesys_Care__c, No_Of_Months__c, Max_Seat_Count__c, Support_Options__c,
                BigMachines__Opportunity__r.BusinessPartner__r.PartnerType__c, Finance_Exceptions__c, Legal_Exceptions__c,
                Base_Agent_Discount__c, Hardware_Discount__c,  Business_Users_Add_On__c, Don_t_Fire_Genesys_Care_Approval__c,
                Data_Center_Provisioning_Discount__c, GC_Decline__c, Carveout__c, CarveOutDetails__c, PPU_Rental__c,Ramp_Period__c,
                BigMachines__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c,Discount__c,Price_Escalation__c, Deal_Score__c,Total_Software__c,
                Overage_Allowance__c, Highest_Discount__c, Order_Type__c,Amendment_For__r.Quote__r.Order_Payment_Terms__c, Usage_Data_Submission_Method__c,
                Amendment_For__r.Quote__r.No_Of_Months__c,Total_Contract_Value_Change__c,Amendment_For__r.Term__c,Amendment_For__r.payment_term__c,
                Professional_Services_Discount__c,Software_Discount__c,Overage_Discount__c,Order_Payment_Terms__c,Billing_Period__c,CMRR__c,
                PureCloud_Monthly_Minimum__c,Owner_Segment__c,BigMachines__Opportunity__r.Direct_Indirect_Sale__c,Third_Party_Discount__c,
                Amendment_For__r.Billing_Period__c,New_Price_Book__c,End_User_ID__c,Total_Discount__c,score__c,Conversion_Quote__c,
                Require_Contractual_Discount__c,Amendment_For__c,Seasonal_License_Net_Value_Y1__c,Seasonal_License_Net_Value_Y2__c,
                Total_Recurring_Credit__c,Total_Non_Recurring_Credit__c,BigMachines__Opportunity__r.Account.Payment_Term__c
                FROM BigMachines__Quote__c WHERE id =: quoteId];
        
    }   
    public static Set<Id> getPMGroupIdsWithPMApprovalRequired(Id quoteId){
        List<BigMachines__Quote_Product__c> quoteProductsWithPMApprovalRequired = [SELECT BigMachines__Product__r.Product_Manager_Approval_Group__c 
                                                                                   FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId 
                                                                                   AND BigMachines__Product__r.Product_Manager_Approval_Group__c != null];
        Set<Id> productMgmtGroupIds = new Set<Id>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWithPMApprovalRequired){
            productMgmtGroupIds.add(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c);
        }
        return productMgmtGroupIds;
    }
    public static List<BigMachines__Quote_Product__c> getQuoteProducts(Id quoteId){
        return [SELECT BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Type__c,BigMachines__Product__r.New_Category__c,name,
                BigMachines__Product__r.Product_Specific_Discount__c, Product_Specific_Discount__c,BigMachines__Product__r.Sub_Category__c,
                BigMachines__Product__r.Product_Manager_Approval_Group__c, BigMachines__Product__c,Discount__c,
                BigMachines__Product__r.Shipment_Approval__c, Total_Discount__c, BigMachines__Quantity__c,
                BigMachines__Product__r.Description__c,BigMachines__Product__r.APN_Number__c,BigMachines__Product__r.name,
                Is_Overage__c,Subscription_Product__c,Subscription_Product__r.Total_Discount__c,
                BigMachines__Product__r.ProductSubFamily__c,Subscription_Product__r.quantity__c,
                BigMachines__Product__r.Include_in_CMMR_Total__c,
                Partner_Price__c,Net_Unit_Price__c
                FROM BigMachines__Quote_Product__c
                WHERE BigMachines__Quote__c =: quoteId];
    }
    
    public static Decimal getApprovalSubmission(String quoteId, Integer stepNo){
        List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
                                                          WHERE BigMachines_Quote__c =: quoteId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
        Decimal submissionCounter = 1;
        //Making sure counter increases only if quote is resubmitted to approvals
        if(!existingQuoteApprovals.isEmpty()){
            if(stepNo == 0)
                submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c + 1;
            else
                submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c;
        }
        return submissionCounter;
    }
    
    
    public static Map<String, List<Quote_Approval_Config_And_Steps__c>> getQuoteApprvalConfigRecords(BigMachines__Quote__c quote, Set<Id> stepIds){
        //Getting all the steps which doesn't depends on the region sub region
        //List<Quote_Approval_Config_And_Steps__c> approvalSteps = [SELECT Quote_Approval_Steps__c FROM Quote_Approval_Config_And_Steps__c
        //  WHERE Quote_Approval_Config__r.Doesn_t_Depend_on_Region_Sub_Region__c = true AND Quote_Approval_Steps__c =: stepIds];
        //Map which will hold quote approval step id and record
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalConfig = new Map<String, List<Quote_Approval_Config_And_Steps__c>>();
        //Getting all approvals based on regions
        List<Quote_Approval_And_Quote_Approval_Region__c> quoteApprovalRegions = [SELECT Quote_Approval_Config__c FROM Quote_Approval_And_Quote_Approval_Region__c
                                                                                  WHERE (Quote_Approval_Region__r.DAP_Region__c =: quote.BigMachines__Opportunity__r.New_DAP_Region__c)
                                                                                  //OR (Quote_Approval_Region__r.Sub_Region__c != null AND Quote_Approval_Region__r.Sub_Region__c =: quote.Sold_To_Name__r.Country__r.RU__c))
                                                                                  //AND Quote_Approval_Region__r.Sub_Region__c =: quote.BigMachines__Opportunity__r.Country_Sub_Region__c
                                                                                  AND Quote_Approval_Config__r.Active__c = true AND Quote_Approval_Config__r.Quote_Type__c =: quote.Quote_Business_Type__c
                                                                                  AND Quote_Approval_Config__r.Quote_Offering_Type__c =: quote.Offering_Type__c];
        //will hold approval config ids
        Set<Id> quoteApprovalConfigIds = new Set<Id>();
        //Looping over each record
        for(Quote_Approval_And_Quote_Approval_Region__c eachQuoteApprovalRegion : quoteApprovalRegions){
            quoteApprovalConfigIds.add(eachQuoteApprovalRegion.Quote_Approval_Config__c);
        }
        //Querying quote approval
        List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigs = [SELECT Quote_Approval_Steps__c, Quote_Approval_Config__r.Approval_Type__c, 
                                                                         Quote_Approval_Config__r.Quote_Type__c, Quote_Approval_Config__r.Threshold_From__c, Quote_Approval_Config__r.Threshold_To__c,
                                                                         Quote_Approval_Config__r.No_Of_Days_After_Quote_Expires__c, Quote_Approval_Config__r.Pricing_Model__c,
                                                                         Quote_Approval_Config__r.Care_Override_Threshold__c, Step__c
                                                                         FROM Quote_Approval_Config_And_Steps__c WHERE  Quote_Approval_Config__r.Active__c = true
                                                                         AND (Quote_Approval_Config__c IN : quoteApprovalConfigIds 
                                                                              OR Quote_Approval_Config__r.Approval_Type__c =: APPROVAL_TYPE_PRODUCT_MANAGEMENT
                                                                              OR Quote_Approval_Config__r.Doesn_t_Depend_on_Region_Sub_Region__c =: true)
                                                                         AND Quote_Approval_Config__r.Quote_Type__c =: quote.Quote_Business_Type__c
                                                                         AND Quote_Approval_Config__r.Quote_Offering_Type__c =: quote.Offering_Type__c];
        for(Quote_Approval_Config_And_Steps__c eachQAC : quoteApprovalConfigs){
            //System.debug('NKC debug eachQAC.Quote_Approval_Config__r.Approval_Type__c [' + eachQAC.Quote_Approval_Config__r.Approval_Type__c + ']');
            stepIds.add(eachQAC.Quote_Approval_Steps__c);
            System.debug('NKC debug eachQAC.Quote_Approval_Steps__c ['+eachQAC.Quote_Approval_Steps__c+']');
            if(mapIdVsQuoteApprovalConfig.containsKey(eachQAC.Quote_Approval_Steps__c)){
                mapIdVsQuoteApprovalConfig.get(eachQAC.Quote_Approval_Steps__c).add(eachQAC);
            }
            else{
                List<Quote_Approval_Config_And_Steps__c> newList = new List<Quote_Approval_Config_And_Steps__c>();
                newList.add(eachQAC);
                mapIdVsQuoteApprovalConfig.put(eachQAC.Quote_Approval_Steps__c, newList);
            }               
        }       
        return mapIdVsQuoteApprovalConfig;
    }
    
    public static List<Quote_Approval_Step_Details__c> getQuoteApprovalRecords(Set<Id> quoteApprovalStepIds, BigMachines__Quote__c quote){      
        System.debug('NKC debug quoteApprovalStepIds ['+quoteApprovalStepIds+']');  
        Set<Id> pmGroupIdsWithPMApprovalRequired = getPMGroupIdsWithPMApprovalRequired(quote.id);
        System.debug('NKC debug pmGroupIdsWithPMApprovalRequired ['+pmGroupIdsWithPMApprovalRequired+']');
        List<CurrencyType> currencyType = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: quote.CurrencyIsoCode AND IsActive = true];
        Double totalQuoteUSD = quote.Total_List_Price__c;
        if(currencyType.isEmpty() && currencyType[0].ConversionRate != null)
            totalQuoteUSD = quote.Total_List_Price__c * currencyType[0].ConversionRate;
        
        //Getting the approval records
        List<Quote_Approval_Step_Details__c> quoteApprovers = [SELECT Quote_Approval_Step__c,
                                                               Quote_Approver_Step_Approver_Detail__r.Name, Quote_Approver_Step_Approver_Detail__r.OwnerId,
                                                               Quote_Approval_Step__r.Name, Quote_Approval_Step__r.Order__c,  
                                                               Quote_Approver_Step_Approver_Detail__r.Owner.Name,
                                                               Quote_Approver_Step_Approver_Detail__r.Action_Text__c,
                                                               Quote_Approver_Step_Approver_Detail__r.PM_Group_Id__c,
                                                               Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Name,
                                                               Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Email,
                                                               Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c,
                                                               Product_Manager_Approval_Group__c, Quote_Approver_Step_Approver_Detail__r.Product_Ids__c
                                                               FROM Quote_Approval_Step_Details__c WHERE 
                                                               Quote_Approval_Step__c IN : quoteApprovalStepIds 
                                                               //Sub Regional Head
                                                               AND ((Quote_Approval_Region__r.DAP_Region__c  =: quote.BigMachines__Opportunity__r.Country_DAP__c
                                                                     AND Quote_Approval_Region__r.Sub_Region__c =: quote.BigMachines__Opportunity__r.Country_Sub_Region__c)
                                                                    //Generic
                                                                    OR Quote_Approval_Region__c = NULL
                                                                    //Regional Finance Controller, Regional SVP and SVP GC
                                                                    OR (Quote_Approval_Region__r.Sub_Region__c = NULL AND Quote_Approval_Region__r.Region__c =: quote.BigMachines__Opportunity__r.Country_Region__c)
                                                                    OR Product_Manager_Approval_Group__c IN: pmGroupIdsWithPMApprovalRequired)
                                                               AND ( Quote_Approval_Step__r.Deal_Size_Threshold_From__c <= : totalQuoteUSD  
                                                                    OR Quote_Approval_Step__r.Deal_Size_Threshold_From__c = NULL)
                                                               ORDER BY Quote_Approval_Step__r.Order__c, Priority_Sequence__c ]; 
        return quoteApprovers;
    }
    
    public static Map<Id, Set<Id>> isAlreadyApprovedPMApproval(String quoteId, Map<Id, Set<Id>> mapGroupIdVsProductId, String status){
        List<Quote_Approval__c> alreadyApprovedApprovals = [SELECT Product_Ids__c, Product_Manager_Approval_Group__c FROM Quote_Approval__c WHERE  
                                                            Status__c =: status AND Product_Manager_Approval_Group__c != null AND BigMachines_Quote__c =: quoteId];
        System.debug('NKC debug alreadyApprovedApprovals ['+alreadyApprovedApprovals+']');
        System.debug('NKC debug mapGroupIdVsProductId ['+mapGroupIdVsProductId+']');
        
        Set<Id> pmGroupIdsToRemove = new Set<Id>();
        for(Quote_Approval__c eachQA : alreadyApprovedApprovals){
            Set<Id> productIds = new Set<Id>();
            if(mapGroupIdVsProductId.get(eachQA.Product_Manager_Approval_Group__c) != null)
                productIds = mapGroupIdVsProductId.get(eachQA.Product_Manager_Approval_Group__c);
            for(String eachProductId : productIds){
                if(eachQA.Product_Ids__c.contains(eachProductId)){
                    mapGroupIdVsProductId.get(eachQA.Product_Manager_Approval_Group__c).remove(eachProductId);
                }
            }
        }
        for(Id eachKey : mapGroupIdVsProductId.keyset()){
            if(mapGroupIdVsProductId.get(eachKey).size() == 0)
                mapGroupIdVsProductId.remove(eachKey);
        }
        System.debug('NKC debug mapGroupIdVsProductId ['+mapGroupIdVsProductId+']');
        
        return mapGroupIdVsProductId;           
    }
}