//Naresh Kumar  11/18/2014
public without sharing class DealQualificationApprovalUtil {
    public final static string STATUS_INACTIVE = 'In-Active';
    public final static string STATUS_PENDING = 'Pending';
    public final static string STATUS_APPROVED = 'Approved';
    public final static string STATUS_REJECTED = 'Rejected';
    public final static string STATUS_CANCELLED = 'Cancelled';
    public final static string STATUS_REVISION_PENDING = 'Revision Pending';
    public final static string STATUS_APPROVER_NOTIFICATION_ONLY = 'Notification Only'; 
    public final static string STATUS_APPROVAL_RESET = 'Approval Reset';    
    public final static string QUOTE_STATUS_REJECTED = 'Rejected';
    public final static string QUOTE_STATUS_APPROVED = 'Approved';
    public final static string QUOTE_STATUS_PENDING = 'Approval Pending';
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
    public final static String APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC = 'Require Separate Quote for Genesys Care - Notification';
    public final static String APPROVAL_TYPE_FUTURE_PRODUCTS = 'Future Products - Notification';
    public final static String APPROVAL_TYPE_PS = 'Profressional Services - Notification';
    public final static String APPROVAL_TYPE_THIRD_PARTY_OVERRIDE = 'Third Party Care Override';
    public final static String APPROVAL_TYPE_CLOUD_PARTNER = 'Cloud Partner';    
    public final static String APPROVAL_TYPE_PPU_DEAL = 'PPU Deal'; 
    public final static String APPROVAL_TYPE_OLD_PRICING1 = 'Old Pricing';
    public final static String APPROVAL_TYPE_FINANCE_EXCEPTION = 'Finance Exception Approval';
    public final static String APPROVAL_TYPE_LEGAL_EXCEPTION = 'Legal Exception Approval';    
    public final static String APPROVAL_TYPE_PRIORITY_VIP_SUPPORT = 'Priority/VIP Priority Support';    
    public final static String APPROVAL_TYPE_BASE_AGENT_DISCOUNT = 'Base Agent Discount';    
    public final static String APPROVAL_TYPE_HARDWARE_DISCOUNT = 'Hardware Discount';    
    public final static String APPROVAL_TYPE_ADD_ON_DISCOUNT = 'Business Users & Add-On Discount';    
    public final static String APPROVAL_TYPE_BUSINESS_USER_DISCOUNT = 'Business Users Provisioning Discount';        
    public final static String APPROVAL_TYPE_DATA_CENTER_DISCOUNT = 'Data Center Provisioning Discount';
    public final static String APPROVAL_TYPE_CARVEOUT = 'Carveout';    
    public final static String APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL = 'Subscription Smart Qualified Approval';
    public final static String APPROVAL_TYPE_RENTAL_QUOTE = 'Rental Quote';    
    public final static String APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD = 'Usage Data Submission Method';
    public final static String APPROVAL_TYPE_DEAL_SCORE = 'Deal Score';    
    public final static String APPROVAL_TYPE_QUOTE_CONVERSION = 'Quote Conversion';
    public final static String APPROVAL_TYPE_CONTRACTUAL_RATE = 'Contractual Rate'; 
    public final static String APPROVAL_TYPE_SEASONAL_LICENSING = 'Seasonal Licensing'; 
    public final static String APPROVAL_TYPE_CREDIT_APPLIED = 'Credit';   
    public final static String APPROVAL_TYPE_PC_SMALL_MEDIUM = 'PureConnect Small Medium';     
    public final static String QUOTE_REJECTED_BEFORE_APPROVAL = 'Quote Rejected Before Approval';
    public final static String QUOTE_REVISED_BEFORE_APPROVAL = 'Quote Revised Before Approval';   
    public final static String PM_SHIPMENT_NOTIFICATION = 'PM Shipment Notification';
    public final static String AE_PM_SHIPMENT_NOTIFICATION = 'AE PM Shipment Notification';  
    public final static String NO_APPROVAL_REQUIRED = 'No Approval Required';
    public final static String REQUIRED_FOR_ALL_ORDERS = 'Required for all Orders';
    public final static String REQUIRED_FOR_NEW_ORDERS_ONLY = 'Required for New Orders Only';
    public final static String NOTIFICATION_ONLY = 'No Approval Required - Email Notification when Quoted'; 
    public final static String MINOR_QUOTE_CHANGE_ONLY = 'Minor Quote Change Only';
    public final static String MINOR_QUOTE_AND_EXPIRATION_DATE = 'Minor Quote And Expiration Date'; 
    public final static String EXPIRATION_DATE_ONLY = 'Expiration Date Only';
    public final static String DECLINE = 'Decline';
    public final static String PREMIUM = 'Premium';
    public final static String BUSINESS = 'Business';    
    public final static String PRODUCT_TYPE_GU = 'GU';
    public final static String PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE = 'Product - System License';
    public final static String PRODUCT_TYPE_PRODUCT_HARDWARE = 'Product - Hardware';
    public final static Integer STANDARD_TERM_MONTHS = 12;
    public final static Integer STANDARD_TERM_DAYS = 365;
    public final static String GC_THRESHOLD_NO_OVERRIDE = 'No override';
    public final static String GC_THRESHOLD_LESS_THAN_TWO = 'Override < 2 %';
    public final static String GC_THRESHOLD_TWO_TO_THREE = 'Override 2 - 3 %';
    public final static String GC_THRESHOLD_GREATER_THAN_THREE = 'Override > 3%';    
    public final static String APPROVAL_BY_PASSED = 'Approval By-passed';
    public final static String GENESYS_CARE_NONSTANDARD = 'Non Standard';
    public final static String GENESYS_CARE_STANDARD = 'Standard';   
    public final static String GENESYS_CARE_CONTRACTUAL_RATE = 'Contractual Rate'; 
    public final static String CONCURRENT = 'Concurrent';
    public final static String DQ_RECORD_ORIGINAL = 'Original';
    public final static String DQ_RECORD_HISTORY = 'History';
    public final static String PRODUCT_HAS_PREREQ = Label.EOL_Value;
    public final static String NEW_PRODUCT_WITH_LIMITED = Label.Restrictions_Value;
    public final static String HIGHLY_TECHNICAL_SALE = Label.Highly_Technical_Sale_PM_Approval_Required;
    //public final static String NOTIFICATION_ONLY_SO_PM = 'Notification only so PM can help AE if quote looks incorrect';
    public final static String NOTIFICATION_ONLY_SO_PM = 'No Approval Required - Email Notification when Quoted';
    public final static String PRODUCT_AVAILABLE_FOR_EXP = Label.Expansion_Only_Value;
    public final static String ITEM_CAN_ONLY_BE_SOLD = 'Item can only be sold as part of a bundle';
    public final static String ITEM_TO_BE_DISCONTINUED = 'Item to be discontinued';
    public final static String NEW_PRICING = 'New Pricing';
    public final static String OLD_PRICING = 'Old Pricing';
    public final static Decimal NEW_PRICING_LEVEL2_THRESHOLD = 50;
    public final static Decimal OLD_PRICING_LEVEL2_THRESHOLD = 75;
    public final static String LEVEL1 = 'Level 1';
    public final static String LEVEL2 = 'Level 2';
    public final static String LEVEL3 = 'Level 3';
    public final static String LEVEL4 = 'Level 4';
    public final static String APPROVAL_Type_Old_Pricing = 'Old Pricing Used';
    
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
    public final static String APPROVAL_TYPE_PCC_Credit = 'PureConnect Cloud Credit';
    public final static String APPROVAL_TYPE_PEC_Credit = 'PureEngage Cloud Credit';
    public final static String APPROVAL_TYPE_PC_Trial = 'PureCloud Trial';
    
    public final static String APPROVAL_TYPE_SMART_USE_CASE = 'Smart Use Case';
    public final static String APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR = 'Annual Price Escalator';
    public final static String APPROVAL_TYPE_OVERAGE_ALLOWANCE = 'Overage Allowance';
    public final static String APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION = 'Payment - Terms - Subscription';    
    public final static String APPROVAL_TYPE_DISCOUNT_SIZE_BASE_PACKAGE = 'Discount Size - Base Package';
    
    public final static String APPROVAL_TYPE_PSDISCOUNT = 'Professional Services Discount';
    public final static String APPROVAL_TYPE_HARDWAREDISCOUNT = 'Hardware Discount';
    public final static String APPROVAL_TYPE_SOFTWAREDISCOUNT = 'Software Discount';
    public final static String APPROVAL_TYPE_OVERAGEDISCOUNT = 'Overage Discount';
    public final static String APPROVAL_TYPE_TCVREDUCTION = 'TCV Reduction';
    
    public final static String APPROVAL_TYPE_PS_PPW_OFFLINE = 'PS Project Profitability (Offline)';
    public final static String APPROVAL_TYPE_PS_NBT = 'PS Non Billable Travel';
    public final static String APPROVAL_TYPE_DEAL_SCORE_CLOUD = 'Deal-Score Cloud';
    public final static String APPROVAL_TYPE_Cloud_Deal = 'Cloud Deal';
    public final static String APPROVAL_TYPE_THIRDPARTY = 'Third Party Discount';
    public final static String APPROVAL_TYPE_BILLING_CATEGORY = 'Billing Category';//  //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890
    public final static String APPROVAL_RENEWAL_SUBSCRIPTION_TERM = 'Renewal Subscription Term';//  //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890

    
    public static Deal_Qualification__c getDQFromId(Id dqId){
        //Getting current quote record
        return [SELECT Name, Net_Deal_Value__c, Old_Pricing_Discount__c, New_Pricing_Discount__c, CurrencyIsoCode, Ramp_Period_Days__c, Payment_Terms__c,
                Genesys_Care__c, Override_by_2__c, Override_2__c, Term_Increase__c, Term_Decrease__c, Decline__c,Migration_Credit__c,Renewal_Subscription_Term__c,Billing_Category__c,
                Premium_Care__c, Require_Separate_Quote_for_Genesys_Care__c, Support_Option__c, Other_Non_Standard_Finance_Exceptions__c,
                ELA__c, X3rd_Party_Products__c, Contractual_Pricing__c, Are_you_selling_Non_GA_Future_Roadmap__c,
                No_Professional_Services_Required__c, Other__c, Partner_Provided_Professional_Services__c, Opportunity__r.Country_Region__c, Opportunity__r.Country_Sub_Region__c, Expected_Billing_Start_Date__c, Delayed_Billing_Start_Date__c,
                Opportunity__r.Country_DAP__c, Opportunity__r.New_DAP_Region__c, Opportunity__r.Country__r.Old_Pricing_DAP_Region__c,
                Special_Offer_Terms__c, CAD_Override__c, Service_Level__c, Status__c, Expiration_Date__c, Opportunity__r.Country__r.RU__c,
                PureCloud_Credit_Applied__c,Additional_Legal_Terms__c, Editable_List_Price_Approval_Required__c, Do_you_require_Professional_Services__c,
                Product_or_Solution_Name__c, Describe_your_roadmap_related_request__c, Justification_and_time_constraints__c,
                Product_Managers_already_approached__c, Is_Genesys_Providing_PS__c, Is_third_Party_company_providing_PS__c,
                Pricing_Type__c, Contractual_Rate__c, GC_Override__c, Quote__r.Quote_Business_Type__c, Quote__r.Offering_Type__c,
                Special_Offers_Business_Exceptions__c, Product_Values__c, Potential_Growth__c, Discount_On_Quote__c, Justification_for_Discount__c,
                Compliance_of_the_Request_with_Value_Pri__c, Current_and_Historical_discount_within_t__c, Current_and_Historical_Genesys_Care_Rate__c,
                Historical_Discount_on_the_Account__c, Historical_Genesys_Care_rate_on_the_acco__c, Deal_Factory_Recommendation_Status__c,
                Submission_Date__c, Approval_Date__c, Competitor__c, X3rd_Party_Override__c, Competition__c, Partner__c, Opportunity__r.BusinessPartner__c,
                IsOldPricingApproved__c, Partner_Tier_Discount__c, Deal_Registration_Discount__c, Term_Discount__c, Seat_Size_Discount__c, Seat_Count_Tier__c,
                Term_Discount_Range__c, Seat_Discount_Range__c, New_Logo_Discount_Range__c, New_Logo_Discount__c, Term_Length__c, Is_Cloud_Partner__c,
                Cloud_Partner_Approval__c, PPU_Deal_Approval__c, Platform_Type__c, Offering_Type__c, Total_Genesys_Agent_Seats__c,Total_Agent_Seats__c,
                Number_of_Seats__c,Committed_Minutes__c,Estimated_Usage_Minutes__c,Pricing_Model__c,Is_Telco_Included__c,Is_Telco_Quoted_At_Standard_Rates__c,
                Explanation_for_Telco_Pricing__c,Is_MPLS_included__c,Has_MPLS_been_approved__c,Has_MPLS_questionnaire_been_submitted__c,DQ_Page_Name__c,
                Is_Inbound_Voice_included__c,Data_Center_Region__c,PureEngage_Cloud_Regional_Avg_Discount__c,Margin__c,Type__c,
                Finance_Exception__c, Legal_Exceptions__c, PureCloud_Business_Exceptions__c, Any_Overage_over_20_for_any_month__c, Explanation_for_Overage__c,
                Business_Users_Add_On__c,Base_Agent_Discount__c, Hardware_Discount__c, Business_Users_Provisioning_Discount__c, Data_Center_Provisioning_Discount__c,
                Estimated_Usage_Minutes_Numbers__c, Initial_Subscription_Term_Months__c, Professional_Services__c, What_is_total_list_price__c, Carveout__c,
                OwnerId, Opportunity__r.Owner.Name, Opportunity__r.Owner.Email, CarveOutDetails__c, Burst_Allowance_Price_Uptick__c, Payment_Terms_Price_Uptick__c,
                Initial_Subscription_Term_Months_PC__c,If_Other_Term_Months_Requested__c,If_Other_Ramp_Period_Requested_Days__c,
                PureCloud_Monthly_Minimum__c,If_Other_PureCloud_Monthly_Minimum_Req__c,Billing_Period__c, Business_User_to_Agent_Ratio_Exception__c,Estimated_Monthly_Recurring_Revenue__c,Estimated_Number_of_Agents__c,Estimated_Number_of_Business_Users__c,
                Less_than_100_Agents__c,Monthly_Recurring_Revenue_less_than_14K__c,More_than_5_000_Business_Users__c, Opportunity__r.Region_Non_CSM__c,PureCloud_Trial__c,
                Overage_Allowance__c, Overage_Price_Premium__c, PureSuccess__c, Are_you_selling_A_La_Cart_PureSuccess__c, Rental__c, Usage_Data_Submission_Method__c,
                Delayed_Billing_Start_Date_Days__c, Delayed_Subscription_Start_Date_Days__c, Optional_extended_term_length_Months__c, Price_Escalation__c,
                PS_Discount_on_Quote__c, Overage_Discount__c,Software_Discount__c,Smart_Use_Case__c,TCV_Reduction__c, Discount_Base_Package__c, Overage_Allowance_Other__c, Annual_Price_Escalation_Other__c, Subscription_Smart_Qualified_Approval__c,
                Incentive_Rebate__c, Deal_Score_Size__c, Deal_Score__c, Net_Deal_Size_Amount__c, Quote__c, Quote__r.Amendment_For__c,Third_Party_Discount__c,
                Quote__r.End_User_ID__c, Quote__r.Sold_To_Name__c, Quote__r.Total_Discount__c, Quote__r.Conversion_Quote__c,Conversion_Quote__c, Contractual_Rate_Approval__c,Quote__r.Reason_for_New_when_Sub_s_Already_Exist__c, //Quote__r.Offering_Feature__c,
                //Mukunth added below columns for INC0416843 - DQ Special Offers Sub-aprpovers
                Req_Credit_Collections_approval__c,Req_Legal_approval__c,Req_Order_Mgmt_Billing_approval__c,Req_Revenue_Approval__c,Credit_and_Collections_approval__c,
                Credit_Collections_Comments__c,Legal_approval__c,Legal_Comments__c,Order_Mgmt_Billing_approval__c,Order_Management_Billing_Comments__c,Revenue_approval__c,
                Revenue_Comments__c,createdbyid,Seasonal_License_Net_Value_Y1__c,Seasonal_License_Net_Value_Y2__c,Total_Recurring_Credit__c,Total_Non_Recurring_Credit__c
                //Mukunth code end - DQ Special Offers
                // ,PC_Small_Medium_Approval__c  
                FROM Deal_Qualification__c WHERE id =: dqId LIMIT 1];
    }
    /*
    public static List<Deal_Qualification__c> getDQ(Id oppId, String pricingType){
        return getDQ(oppId, pricingType, DQ_RECORD_ORIGINAL);
    }
    */

    // Overload to allow for record to be returned by specific ID
    public static List<Deal_Qualification__c> getDQ(Id oppId, String pricingType, String platformType, String offeringType, String recordType, Id recordId)
    {
        if(!String.isEmpty(recordId))
        {
            return new List<Deal_Qualification__c>{getDQFromId(recordId)};
        }
        else
        {
            return getDQ(oppId, pricingType, platformType, offeringType, recordType);
        }
    }

    public static List<Deal_Qualification__c> getDQ(Id oppId, String pricingType, String platformType, String offeringType, String recordType){
        system.debug(oppId +'-'+pricingType+'-'+ platformType + '-' + offeringType+'-'+recordType);
        //Filtering out on premise offering type
        if(offeringType == null)
            offeringType = QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE;
        //Getting current quote record
        return [SELECT Name, Net_Deal_Value__c, Old_Pricing_Discount__c, Ramp_Period_Days__c, Payment_Terms__c,CurrencyIsoCode, New_Pricing_Discount__c,
                Genesys_Care__c, Override_by_2__c, Override_2__c, Term_Increase__c, Term_Decrease__c, Decline__c,Migration_Credit__c,Billing_Category__c,Renewal_Subscription_Term__c,
                No_Professional_Services_Required__c, Other__c, Partner_Provided_Professional_Services__c, Premium_Care__c, Require_Separate_Quote_for_Genesys_Care__c, Support_Option__c, Expected_Billing_Start_Date__c, Delayed_Billing_Start_Date__c,
                ELA__c, X3rd_Party_Products__c, Contractual_Pricing__c, Are_you_selling_Non_GA_Future_Roadmap__c,
                Opportunity__r.Country_Region__c, Opportunity__r.Country_Sub_Region__c, Opportunity__r.Country__r.RU__c, Other_Non_Standard_Finance_Exceptions__c,
                Opportunity__r.Country_DAP__c, Opportunity__r.New_DAP_Region__c, Opportunity__r.Country__r.Old_Pricing_DAP_Region__c,
                Special_Offer_Terms__c, CAD_Override__c, Service_Level__c, Status__c, Expiration_Date__c,Quote__r.Reason_for_New_when_Sub_s_Already_Exist__c,
                Additional_Legal_Terms__c, Editable_List_Price_Approval_Required__c, Do_you_require_Professional_Services__c,
                Product_or_Solution_Name__c, Describe_your_roadmap_related_request__c, Justification_and_time_constraints__c,
                Product_Managers_already_approached__c, Is_Genesys_Providing_PS__c, Is_third_Party_company_providing_PS__c,
                Pricing_Type__c, Contractual_Rate__c, GC_Override__c, Quote__r.Quote_Business_Type__c, Quote__r.Offering_Type__c,
                Special_Offers_Business_Exceptions__c, Product_Values__c, Potential_Growth__c, Discount_On_Quote__c, Justification_for_Discount__c,
                Compliance_of_the_Request_with_Value_Pri__c, Current_and_Historical_discount_within_t__c, Current_and_Historical_Genesys_Care_Rate__c,
                Historical_Discount_on_the_Account__c, Historical_Genesys_Care_rate_on_the_acco__c, Deal_Factory_Recommendation_Status__c,
                Submission_Date__c, Approval_Date__c, Competitor__c, X3rd_Party_Override__c, Competition__c, Partner__c, Opportunity__r.BusinessPartner__c,
                PureCloud_Credit_Applied__c,IsOldPricingApproved__c, Partner_Tier_Discount__c, Deal_Registration_Discount__c, Term_Discount__c, Seat_Size_Discount__c, Seat_Count_Tier__c,
                Term_Discount_Range__c, Seat_Discount_Range__c, New_Logo_Discount_Range__c, New_Logo_Discount__c, Term_Length__c, Is_Cloud_Partner__c,
                Cloud_Partner_Approval__c, PPU_Deal_Approval__c, Platform_Type__c, Offering_Type__c, Total_Genesys_Agent_Seats__c,Total_Agent_Seats__c,
                Number_of_Seats__c,Committed_Minutes__c,Estimated_Usage_Minutes__c,Pricing_Model__c,Is_Telco_Included__c,Is_Telco_Quoted_At_Standard_Rates__c,
                Explanation_for_Telco_Pricing__c,Is_MPLS_included__c,Has_MPLS_been_approved__c,Has_MPLS_questionnaire_been_submitted__c,
                Is_Inbound_Voice_included__c,Data_Center_Region__c,PureEngage_Cloud_Regional_Avg_Discount__c,Margin__c,Type__c,DQ_Page_Name__c,
                Finance_Exception__c, Legal_Exceptions__c, PureCloud_Business_Exceptions__c, Base_Agent_Discount__c, Hardware_Discount__c, 
                Business_Users_Add_On__c,Business_Users_Provisioning_Discount__c, Data_Center_Provisioning_Discount__c, Any_Overage_over_20_for_any_month__c, 
                Explanation_for_Overage__c,Estimated_Usage_Minutes_Numbers__c, Initial_Subscription_Term_Months__c, Professional_Services__c,
                What_is_total_list_price__c, Carveout__c, OwnerId, Opportunity__r.Owner.Name, Opportunity__r.Owner.Email, CarveOutDetails__c,
                Initial_Subscription_Term_Months_PC__c,If_Other_Term_Months_Requested__c,If_Other_Ramp_Period_Requested_Days__c,
                Billing_Period__c, PureCloud_Monthly_Minimum__c,If_Other_PureCloud_Monthly_Minimum_Req__c, Burst_Allowance_Price_Uptick__c, Payment_Terms_Price_Uptick__c,
                Business_User_to_Agent_Ratio_Exception__c,Estimated_Monthly_Recurring_Revenue__c,Estimated_Number_of_Agents__c,Estimated_Number_of_Business_Users__c,
                Less_than_100_Agents__c,Monthly_Recurring_Revenue_less_than_14K__c,More_than_5_000_Business_Users__c, Opportunity__r.Region_Non_CSM__c,PureCloud_Trial__c,
                Overage_Allowance__c, Overage_Price_Premium__c, PureSuccess__c, Are_you_selling_A_La_Cart_PureSuccess__c, Rental__c, Usage_Data_Submission_Method__c,
                Delayed_Billing_Start_Date_Days__c, Delayed_Subscription_Start_Date_Days__c, Optional_extended_term_length_Months__c, Price_Escalation__c,
                PS_Discount_on_Quote__c,Software_Discount__c,Overage_Discount__c,Smart_Use_Case__c,TCV_Reduction__c, Discount_Base_Package__c, Overage_Allowance_Other__c, Annual_Price_Escalation_Other__c, Subscription_Smart_Qualified_Approval__c,
                Incentive_Rebate__c, Deal_Score_Size__c, Deal_Score__c, Net_Deal_Size_Amount__c, Quote__c, Quote__r.Amendment_For__c,Third_Party_Discount__c,
                Quote__r.End_User_ID__c, Quote__r.Sold_To_Name__c, Quote__r.Total_Discount__c, Quote__r.Conversion_Quote__c,Conversion_Quote__c, Contractual_Rate_Approval__c,
              //  ,PC_Small_Medium_Approval__c, Quote__r.Offering_Feature__c
                //Mukunth added below columns for INC0416843 - DQ Special Offers Sub-aprpovers
                Req_Credit_Collections_approval__c,Req_Legal_approval__c,Req_Order_Mgmt_Billing_approval__c,Req_Revenue_Approval__c,Credit_and_Collections_approval__c,
                Credit_Collections_Comments__c,Legal_approval__c,Legal_Comments__c,Order_Mgmt_Billing_approval__c,Order_Management_Billing_Comments__c,Revenue_approval__c,
                Revenue_Comments__c,createdbyid,Seasonal_License_Net_Value_Y1__c,Seasonal_License_Net_Value_Y2__c,Total_Recurring_Credit__c,Total_Non_Recurring_Credit__c
                //Mukunth code end - DQ Special Offers
                FROM Deal_Qualification__c 
                WHERE Pricing_Type__c =:pricingType AND Platform_Type__c =:platformType AND Offering_Type__c =:offeringType 
                AND Type__c =: recordType AND Opportunity__c =: oppId ];    
    }
    
    public static List<Deal_Qualification__c> getDQ(Id oppId, String pricingType, String platformType, String offeringType){
        return getDQ(oppId, pricingType, platformType, offeringType,  DQ_RECORD_ORIGINAL);
    } 
    
    public static List<Deal_Qualification__c> getDQHistory(Id oppId, String pricingType, String platformType, String offeringType){
        // getting current deal qualification history record
        return getDQ(oppId, pricingType, platformType, offeringType, DQ_RECORD_HISTORY);  
    }
    
    public static Set<Id> getPMGroupIdsWithPMApprovalRequired(Id dqId){
        List<Deal_Qualification_Products__c> dealQualProductsWithPMApprovalRequired = [SELECT Product__r.Product_Manager_Approval_Group__c 
            FROM Deal_Qualification_Products__c WHERE Deal_Qualification__c =: dqId 
            AND Product__r.Product_Manager_Approval_Group__c != null];
        Set<Id> productMgmtGroupIds = new Set<Id>();
        for(Deal_Qualification_Products__c eachDQProduct : dealQualProductsWithPMApprovalRequired){
            productMgmtGroupIds.add(eachDQProduct.Product__r.Product_Manager_Approval_Group__c);
        }
        return productMgmtGroupIds;
    }
    public static List<Deal_Qualification_Products__c> getDQProducts(Id dqId){
        return [SELECT Name, Discount__c, Product__c, Quantity__c, Product__r.Name, 
          Product__r.Product_Manager_Approval_Group__c, Product__r.Third_Party__c, Product__r.Type__c,
            Product__r.Product_Specific_Discount__c, Approval_Reason__c, 
            Product__r.Shipment_Approval__c
            FROM Deal_Qualification_Products__c WHERE Deal_Qualification__c =: dqId];                 
    }
    
    public static Decimal getApprovalSubmission(String dqId, Integer stepNo){
        List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
            WHERE Deal_Qualification__c =: dqId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
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
    
    
    public static Map<String, List<Quote_Approval_Config_And_Steps__c>> getQuoteApprvalConfigRecords(Deal_Qualification__c dq, Set<Id> stepIds){
      System.debug('NKC debug dq.Pricing_Type__c [' + dq.Pricing_Type__c + ']');
        //Getting all the steps which doesn't depends on the region sub region
        //List<Quote_Approval_Config_And_Steps__c> approvalSteps = [SELECT Quote_Approval_Steps__c FROM Quote_Approval_Config_And_Steps__c
        //  WHERE Quote_Approval_Config__r.Doesn_t_Depend_on_Region_Sub_Region__c = true AND Quote_Approval_Steps__c =: stepIds];
        //Map which will hold quote approval step id and record
        String quoteType = dq.Quote__r.Quote_Business_Type__c;        
        if(quoteType == null){
            if(dq.Platform_Type__c != null)
                quoteType = dq.Platform_Type__c;
            else
                quoteType = 'On Premise';
        } 
        
        String quoteOfferingType = dq.Quote__r.Offering_Type__c;
        if(quoteOfferingType == null)
            quoteOfferingType = dq.Offering_Type__c;
        if(dq.Pricing_Model__c == 'PPU' || quoteOfferingType == 'On Premise'){
          quoteOfferingType = QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE;
          quoteType = 'On Premise';
        }
        System.debug('NKC debug quoteType [' + quoteType + ']');
        System.debug('NKC debug quoteOfferingType [' + quoteOfferingType + ']');
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalConfig = new Map<String, List<Quote_Approval_Config_And_Steps__c>>();
        List<Quote_Approval_And_Quote_Approval_Region__c> quoteApprovalRegions;
        //Getting all approvals based on regions
        if(dq.Pricing_Type__c == NEW_PRICING){
          quoteApprovalRegions = [SELECT Quote_Approval_Config__c FROM Quote_Approval_And_Quote_Approval_Region__c
              WHERE Quote_Approval_Region__r.DAP_Region__c =: dq.Opportunity__r.Country__r.RU__c
              AND Quote_Approval_Config__r.Active__c = true 
              AND Quote_Approval_Config__r.Quote_Type__c =: quoteType
              AND Quote_Approval_Config__r.Offering_Type__c INCLUDES (:quoteOfferingType)
              AND (Quote_Approval_Config__r.Pricing_Type__c =: dq.Pricing_Type__c OR Quote_Approval_Config__r.Pricing_Type__c = NULL)];
        }
        else{
          quoteApprovalRegions = [SELECT Quote_Approval_Config__c FROM Quote_Approval_And_Quote_Approval_Region__c
              WHERE Quote_Approval_Region__r.DAP_Region__c =: dq.Opportunity__r.Country_DAP__c 
              AND Quote_Approval_Config__r.Active__c = true 
              AND Quote_Approval_Config__r.Quote_Type__c =: quoteType
              AND Quote_Approval_Config__r.Offering_Type__c INCLUDES(:quoteOfferingType) 
              AND (Quote_Approval_Config__r.Pricing_Type__c =: dq.Pricing_Type__c OR Quote_Approval_Config__r.Pricing_Type__c = NULL)];
        }
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
            Quote_Approval_Config__r.Care_Override_Threshold__c, Step__c, Quote_Approval_Steps__r.Notification_Only__c,
            Quote_Approval_Config__r.Threshold_Price_From__c, Quote_Approval_Config__r.Threshold_Price_To__c,
            Quote_Approval_Config__r.Threshold_From_Details__c, Quote_Approval_Config__r.Criteria__c, 
            Quote_Approval_Config__r.Partner_Only_Approval__c            
            FROM Quote_Approval_Config_And_Steps__c WHERE  Quote_Approval_Config__r.Active__c = true
            AND (Quote_Approval_Config__c IN : quoteApprovalConfigIds 
            OR Quote_Approval_Config__r.Approval_Type__c =: APPROVAL_TYPE_PRODUCT_MANAGEMENT
            OR Quote_Approval_Config__r.Doesn_t_Depend_on_Region_Sub_Region__c =: true)
            AND Quote_Approval_Config__r.Quote_Type__c =: quoteType
            AND Quote_Approval_Config__r.Offering_Type__c INCLUDES(:quoteOfferingType) 
            AND (Quote_Approval_Config__r.Pricing_Type__c =: dq.Pricing_Type__c OR Quote_Approval_Config__r.Pricing_Type__c = NULL)
            order by Quote_Approval_Steps__r.name                                                                         
            ];
        for(Quote_Approval_Config_And_Steps__c eachQAC : quoteApprovalConfigs){
            System.debug('NKC debug eachQAC.Quote_Approval_Config__r.Approval_Type__c [' + eachQAC.Quote_Approval_Config__r.Approval_Type__c + ']');
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
    
    public static List<Decimal> getMinimumApprovalLimit(BigMachines__Quote__c quote){
      String quoteType = quote.Quote_Business_Type__c;
        if(quoteType == null)
          quoteType = 'On Premise';
      String quoteOfferingType = quote.Offering_Type__c;
      if(quoteOfferingType == null)
          quoteOfferingType = QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE;
      if(quote.Pricing_Model__c == 'PPU')
          quoteOfferingType = null;
      System.debug('NKC debug quoteOfferingType [' + quoteOfferingType + ']');
      List<Quote_Approval_And_Quote_Approval_Region__c> quoteApprovalRegions;
      //Getting all approvals based on regions
      if(quote.Quote_Opportunity_Type__c == 'New Pricing'){
          quoteApprovalRegions = [SELECT Quote_Approval_Config__c FROM Quote_Approval_And_Quote_Approval_Region__c
              WHERE Quote_Approval_Region__r.DAP_Region__c =: quote.BigMachines__Opportunity__r.Country__r.RU__c
              AND Quote_Approval_Config__r.Active__c = true
              AND Quote_Approval_Config__r.Quote_Type__c =: quoteType
              AND Quote_Approval_Config__r.Offering_Type__c INCLUDES(:quoteOfferingType) 
              AND (Quote_Approval_Config__r.Pricing_Type__c =: quote.Quote_Opportunity_Type__c OR Quote_Approval_Config__r.Pricing_Type__c = NULL)
              ];
      }
      else{
        quoteApprovalRegions = [SELECT Quote_Approval_Config__c FROM Quote_Approval_And_Quote_Approval_Region__c
              WHERE Quote_Approval_Region__r.DAP_Region__c =: quote.BigMachines__Opportunity__r.Country_DAP__c
              AND Quote_Approval_Config__r.Active__c = true 
              AND Quote_Approval_Config__r.Quote_Type__c =: quoteType
              AND Quote_Approval_Config__r.Offering_Type__c INCLUDES(:quoteOfferingType)
              AND (Quote_Approval_Config__r.Pricing_Type__c =: quote.Quote_Opportunity_Type__c OR Quote_Approval_Config__r.Pricing_Type__c = NULL)
              ];
      }
        //will hold approval config ids
        Set<Id> quoteApprovalConfigIds = new Set<Id>();
        //Looping over each record
        for(Quote_Approval_And_Quote_Approval_Region__c eachQuoteApprovalRegion : quoteApprovalRegions){
            quoteApprovalConfigIds.add(eachQuoteApprovalRegion.Quote_Approval_Config__c);
        }
        //Querying quote approval
        List<Quote_Approval_Config__c> quoteApprovalConfigs = [SELECT Threshold_From__c, Approval_Type__c FROM Quote_Approval_Config__c 
          WHERE Active__c = true
            AND (id IN : quoteApprovalConfigIds OR Doesn_t_Depend_on_Region_Sub_Region__c =: true)
            AND Quote_Type__c =: quoteType AND Offering_Type__c INCLUDES(:quoteOfferingType) 
            AND (Pricing_Type__c =: quote.Quote_Opportunity_Type__c OR Pricing_Type__c = NULL)
            AND (Approval_Type__c =: APPROVAL_TYPE_DEAL_SIZE OR Approval_Type__c =: APPROVAL_TYPE_DISCOUNT) ORDER BY Threshold_From__c ASC];
       Decimal minimumDiscount, minimumDealSize;
       for(Quote_Approval_Config__c eachConfig : quoteApprovalConfigs){
           if(eachConfig.Approval_Type__c == APPROVAL_TYPE_DISCOUNT && minimumDiscount == null){
             minimumDiscount = eachConfig.Threshold_From__c;
           }
           if(eachConfig.Approval_Type__c == APPROVAL_TYPE_DEAL_SIZE && minimumDealSize == null){
             minimumDealSize = eachConfig.Threshold_From__c;
           }           
       }
       List<Decimal> minmumLimits = new List<Decimal>();
       minmumLimits.add(minimumDiscount);
       minmumLimits.add(minimumDealSize);
       return minmumLimits;
       
    }
    
    public static Boolean isNotificationOnly(String shippingApproval){
      if(shippingApproval == NOTIFICATION_ONLY || shippingApproval == 'New product with limited functionality or other restrictions'
        || shippingApproval == 'Product has prerequisites or limited compatibility or is headed towards EOL'
        || shippingApproval == 'Notification only so PM can help AE if quote looks incorrect' ){
        return true;  
      }
      else
        return false;
    }
    
    public static Boolean isPMApprovalRequired(String shippingApproval){
      if(shippingApproval == DealQualificationApprovalUtil.HIGHLY_TECHNICAL_SALE)
        return true;      
      else
        return false;
    }
    
    public static String getDealSizePickListVal(Decimal dealSize){
        return getDealSizePickListVal(dealSize, null);
    }
    public static String getDealSizePickListVal(Decimal dealSize, String offeringType){
      String dealValue;
      if(offeringType == QuoteUtil.OFFERING_TYPE_CIC){
          if(dealSize <= 25000){
            dealValue = '< 25K';
          }
          else if(dealSize <= 50000){
            dealValue = '25K - 50K';
          }
          else if(dealSize <= 75000){
            dealValue = '50K - 75K';
          }
          else if(dealSize <= 100000){
            dealValue = '75K - 100K';
          }
          else if(dealSize <= 500000){
            dealValue = '100K - 500K';
          }
          else if(dealSize <= 1000000){
            dealValue = '500K - 1M';
          }
          else if(dealSize <= 2000000){
            dealValue = '1M - 2M';
          }
          else if(dealSize <= 3000000){
            dealValue = '2M - 3M';
          }
          else if(dealSize <= 10000000){
            dealValue = '3M - 10M';
          }
          else if(dealSize <= 50000000){
            dealValue = '10M - 50M';
          }
          else if(dealSize <= 200000000){
            dealValue = '50M - 200M';
          }      
          else {
            dealValue = '200M - 500M';
          }      
      }
          else{
            if(dealSize <= 25000){
            dealValue = '< 25K';
          }
          else if(dealSize <= 50000){
            dealValue = '25K - 50K';
          }
          else if(dealSize <= 100000){
            dealValue = '50K - 100K';
          }
          else if(dealSize <= 250000){
            dealValue = '100K - 250K';
          }
          else if(dealSize <= 500000){
            dealValue = '250K - 500K';
          }
          else if(dealSize <= 1000000){
            dealValue = '500K - 1M';
          }
          else if(dealSize <= 2000000){
            dealValue = '1M - 2M';
          }
          else if(dealSize <= 3000000){
            dealValue = '2M - 3M';
          }
          else if(dealSize <= 10000000){
            dealValue = '3M - 10M';
          }
          else if(dealSize <= 50000000){
            dealValue = '10M - 50M';
          }
          else if(dealSize <= 200000000){
            dealValue = '50M - 200M';
          }      
          else {
            dealValue = '200M - 500M';
          }
        }
      
      return dealValue;
    }
    
    public static String getDealScoreSizePickListVal(Decimal dealSize){
      String dealValue;
      if(dealSize <= 50000)
        dealValue = '< 50K';
      else if(dealSize <= 250000)
        dealValue = '50K - 250K';
      else if(dealSize <= 750000)
        dealValue = '250K - 750K';
      else if(dealSize <= 2000000)
        dealValue = '750K - 2M';
      else if(dealSize <= 20000000)
        dealValue = '2M - 20M';
      else
        dealValue = '20M - 500M';  
      return dealValue;
    }
    
    public static Double getDealSize(String dealSizeRange){
      if(dealSizeRange != null && (dealSizeRange.indexOf('-') != -1 || dealSizeRange.indexOf('<') != -1)){
        String valueStr;
        if(dealSizeRange.contains('-')){
          valueStr = dealSizeRange.split('-')[1].replace(' ', '');
          system.debug(valueStr);
        }
        else if(dealSizeRange.contains('<')){
          valueStr = dealSizeRange.split('<')[1].replace(' ', '');
        }
        if(valueStr.contains('K')){
          return Double.valueOf(valueStr.replace('K', '')) * 1000;
        }
        else if(valueStr.contains('M')){
          system.debug(valueStr);
          return Double.valueOf(valueStr.replace('M', '')) * 1000000;
          
        }
        else if(valueStr.contains('B')){
          return Double.valueOf(valueStr.replace('B', '')) * 100000000;
        }
        return Double.valueOf(valueStr);
      }      
        return 0;
    }
    
    public static String getDiscountSizePickListVal(Double discountSize, String pricingType){
      String discountValue;  
      if(pricingType == NEW_PRICING){
        if(discountSize < 15)
            discountValue = '< 15%';
        else if(discountSize < 25)
            discountValue = '< 25%';
          else if(discountSize < 30)
            discountValue = '< 30%';
        else if(discountSize < 35)
          discountValue = '< 35%';
      else if(discountSize < 37)
          discountValue = '< 37%';
      else if(discountSize < 40)
          discountValue = '< 40%';
      else if(discountSize < 45)
          discountValue = '< 45%';
      else if(discountSize < 50)
          discountValue = '< 50%';
      else if(discountSize < 55)
          discountValue = '< 55%';
      else if(discountSize < 60)
          discountValue = '< 60%';
      else if(discountSize < 65)
          discountValue = '< 65%';
      else if(discountSize < 68.5)
          discountValue = '< 68.5%';
      else if(discountSize < 70)
          discountValue = '< 70%';
      else if(discountSize < 75)
          discountValue = '< 75%';
      else if(discountSize < 80)
          discountValue = '< 80%';
      else if(discountSize < 82.5)
          discountValue = '< 82.5%';
      else if(discountSize < 85)
          discountValue = '< 85%';
      else if(discountSize < 90)
          discountValue = '< 90%';
      else if(discountSize < 95)
          discountValue = '< 95%';
      else if(discountSize < 100)
          discountValue = '< 100%';
      else 
          discountValue = '= 100%';            
      }
      else{
        if(discountSize < 15)
            discountValue = '< 15%';
        else if(discountSize < 25)
            discountValue = '< 25%';
        else if(discountSize < 35)
            discountValue = '< 35%';
        else if(discountSize < 45)
            discountValue = '< 45%';
        else if(discountSize < 55)
            discountValue = '< 55%';        
        else if(discountSize < 65)
          discountValue = '< 65%';
      else if(discountSize < 70)
          discountValue = '< 70%';
      else if(discountSize < 75)
          discountValue = '< 75%';
      else if(discountSize < 80)
          discountValue = '< 80%';
      else if(discountSize < 85)
          discountValue = '< 85%';
      else if(discountSize < 90)
          discountValue = '< 90%';
      else if(discountSize < 92)
          discountValue = '< 92%';
      else if(discountSize < 95)
          discountValue = '< 95%';
        else if(discountSize < 96)
          discountValue = '< 96%';
        else if(discountSize < 98)
          discountValue = '< 98%';        
      else if(discountSize < 100)
          discountValue = '< 100%';
      else 
          discountValue = '= 100%';
      }                  
      return discountValue;
    }
    
    public static Double getDiscountSize(String discountRange){      
      if(discountRange != null && discountRange != 'No Discount'){
        String valueStr;
        Double discount;        
        if(discountRange.contains('-')){
          valueStr = discountRange.split('-')[1].replace(' ', '').replace('%','');
          discount = Double.valueOf(valueStr);
        }
        else{        
          if(discountRange.contains('<')){
              valueStr = discountRange.replace(' ', '').replace('%','').replace('<', '');
              discount = Double.valueOf(valueStr) - 0.01;
          }
          else if(discountRange.contains('=')){
              valueStr = discountRange.replace(' ', '').replace('%','').replace('=', '');
              discount = Double.valueOf(valueStr);
          }
        }
        System.debug('NKC debug discount ['+discount+']');
        return discount;
      }
      return 0;
    }
    
    //convert to usd
    public static Double convertCurrency(Double valueToConvert, String isoCode){
      List<CurrencyType> currencyRecord = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: isoCode AND IsActive = true];
      Double totalQuoteUSD = valueToConvert;
      System.debug('NKC debug valueToConvert ['+valueToConvert+']');
        System.debug('NKC debug currencyRecord[0].ConversionRate ['+currencyRecord[0].ConversionRate+']');
        if(!currencyRecord.isEmpty() && currencyRecord[0].ConversionRate != null){
          totalQuoteUSD = valueToConvert / currencyRecord[0].ConversionRate;
        }
        System.debug('NKC debug totalQuoteUSD ['+totalQuoteUSD+']');
        return totalQuoteUSD;
    }
    
    //covert from usd to other
    public static Double convertCurrencyfromUSD(Double valueToConvert, String isoCode){
      List<CurrencyType> currencyRecord = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode =: isoCode AND IsActive = true];
      Double totalQuote = valueToConvert;
        if(!currencyRecord.isEmpty() && currencyRecord[0].ConversionRate != null){
          totalQuote = valueToConvert * currencyRecord[0].ConversionRate;
        }
        return totalQuote;
    }
    
    public static Double getDQListPrice(String discountStr, Double totalQuoteUSD){
       //Discount
         Double discount, dealListPrice;
         if(discountStr == 'No Discount')
           discount = 0;
         else 
           discount = getDiscountSize(discountStr);
         if(discount == 100)
           discount = 99.99;
         
         //Getting list price
         totalQuoteUSD = (totalQuoteUSD * 100) / (100 - discount);         
         return totalQuoteUSD; 
    }
    
    public static List<Quote_Approval_Step_Details__c> getQuoteApprovalRecords(Set<Id> quoteApprovalStepIds, Deal_Qualification__c dq){      
        System.debug('NKC debug quoteApprovalStepIds ['+quoteApprovalStepIds+']');  
        Set<Id> pmGroupIdsWithPMApprovalRequired = getPMGroupIdsWithPMApprovalRequired(dq.id);
        Double totalQuoteUSD = convertCurrency(getDealSize(dq.Net_Deal_Value__c ), dq.CurrencyIsoCode);         
        System.debug('NKC debug totalQuoteUSD ['+totalQuoteUSD+']');
        totalQuoteUSD = getDQListPrice(dq.New_Pricing_Discount__c, totalQuoteUSD);
        System.debug('NKC debug totalQuoteUSD ['+totalQuoteUSD+']');
        String strCountrySubRegion = dq.Opportunity__r.Country_Sub_Region__c;
        if(dq.offering_type__c != null && (dq.offering_type__c == 'PureCloud' || dq.offering_type__c == 'PureConnect Cloud' || dq.offering_type__c == 'Business Edition') && dq.Opportunity__r.Country_Region__c == 'CSM')
            strCountrySubRegion = dq.offering_type__c;
        //Getting the approval records
        List<Quote_Approval_Step_Details__c> quoteApprovers = [SELECT Quote_Approval_Step__c,
                Quote_Approver_Step_Approver_Detail__r.Name, Quote_Approver_Step_Approver_Detail__r.OwnerId,
                Quote_Approval_Step__r.Name, Quote_Approval_Step__r.Order__c,  Quote_Approval_Step__r.Notification_Only__c,
                Quote_Approval_Step__r.Partner_Only_Step__c,
                Quote_Approver_Step_Approver_Detail__r.Owner.Name,
                Quote_Approver_Step_Approver_Detail__r.Action_Text__c,
                Quote_Approver_Step_Approver_Detail__r.PM_Group_Id__c,
                Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Name,
                Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Email,
                Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c,
                Quote_Approver_Step_Approver_Detail__r.Email__c,                                                               
                Product_Manager_Approval_Group__c, Quote_Approver_Step_Approver_Detail__r.Product_Ids__c
                FROM Quote_Approval_Step_Details__c WHERE 
                Quote_Approval_Step__c IN : quoteApprovalStepIds 
                //Sub Regional Head
                //AND ((Quote_Approval_Region__r.DAP_Region__c  =: dq.Opportunity__r.Country_DAP__c
                //AND ((Quote_Approval_Region__r.DAP_Region__c  =: dq.Opportunity__r.Country_DAP__c  
                AND (
                (Quote_Approval_Region__r.DAP_Region__c  =: dq.Opportunity__r.Country__r.Old_Pricing_DAP_Region__c
                AND Quote_Approval_Region__r.Sub_Region__c =: strCountrySubRegion)
                //Anju for CSM multi regions cloud
                OR (Quote_Approval_Region__r.DAP_Region__c  =: dq.Opportunity__r.Region_Non_CSM__c AND Quote_Approval_Region__r.Region__c = 'CSM' AND Quote_Approval_Region__r.Sub_Region__c = :strCountrySubRegion)
                OR (Quote_Approval_Region__r.DAP_Region__c = null AND Quote_Approval_Region__r.Region__c = 'CSM' AND Quote_Approval_Region__r.Sub_Region__c = :strCountrySubRegion)
                OR (Quote_Approval_Region__r.Sub_Region__c = :dq.offering_type__c AND Quote_Approval_Region__r.Region__c =: dq.Opportunity__r.Country_Region__c AND Quote_Approval_Region__r.Region__c != 'CSM')
                
                //Generic
                OR Quote_Approval_Region__c = NULL
                //Regional Finance Controller, Regional SVP and SVP GC
                OR (Quote_Approval_Region__r.Sub_Region__c = NULL AND Quote_Approval_Region__r.Region__c =: dq.Opportunity__r.Country_Region__c)
                //NO CSM     
                OR (Quote_Approval_Step__r.Step_Type__c =: dq.Opportunity__r.Country_Region__c
                    AND Quote_Approval_Region__r.Region__c =: dq.Opportunity__r.Region_Non_CSM__c
                   AND Quote_Approval_Region__r.Sub_Region__c = NULL)
                OR Product_Manager_Approval_Group__c IN: pmGroupIdsWithPMApprovalRequired)
                AND ( Quote_Approval_Step__r.Deal_Size_Threshold_From__c <= : totalQuoteUSD  
                    OR Quote_Approval_Step__r.Deal_Size_Threshold_From__c = NULL)
                ORDER BY Quote_Approval_Step__r.Order__c, Priority_Sequence__c
                                  ];
        return quoteApprovers;
    }
    
    public static Map<Id, Set<Id>> isAlreadyApprovedPMApproval(String dqId, Map<Id, Set<Id>> mapGroupIdVsProductId, String status){
        List<Quote_Approval__c> alreadyApprovedApprovals = [SELECT Product_Ids__c, Product_Manager_Approval_Group__c FROM Quote_Approval__c WHERE  
            Status__c =: status AND Product_Manager_Approval_Group__c != null AND Deal_Qualification__c =: dqId];
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
    
    public static String getRespectiveDQPageName(String platformType, String offeringType){     
        String pageName = 'DealQualification';
        if(platformType == 'Cloud' && offeringType == 'Business Edition'){
            pageName = 'DealQualificationCloud';
        }
        else if(platformType == 'Cloud' && offeringType == 'Cloud Partner (PPU)'){
            pageName = 'DealQualificationPPU';
        }
        else if(offeringType == QuoteUtil.OFFERING_TYPE_CIC){
            pageName = 'DealQualificationCIC';
        }
        else if(offeringType == QuoteUtil.OFFERING_TYPE_CAAS){
            pageName = 'DealQualificationCloud';
        }
        else if(offeringType == 'PureEngage Cloud')
        {
            pageName = 'DealQualificationCloud';    
        }
        else if(offeringType == 'PureCloud'){
            pageName = 'DealQualificationCloud';
        }
        else if(offeringType == 'PureEngage Subscription' || offeringType == 'PureConnect Subscription'){
            pageName = 'DealQualificationSubscription';
        }            
        return pageName;
    }
    
    // NikM: Added to get the PS specific page names to load
    public static String getRespectivePSPageName(String platformType, String offeringType, String dqID){     
        String pageName = 'PSApprovalWarning';
        if (dqID != null)
        {
            Deal_Qualification__c checkDQ = [SELECT Name, Offering_Type__c, PS_PageRef__c
                                       FROM Deal_Qualification__c WHERE id =: dqId];
                                            
            if (checkDQ.Offering_Type__c == 'Professional Services')
            {
                PageName = checkDQ.PS_PageRef__c;
            }
            else
            {
                // Not a PS specific item, so just use the regular page ref method to get the pageName
                pageName = getRespectiveDQPageName(platformType, offeringType);
            }
            }
        return pageName;
    }
    
    public static void populateLevel1Approver(List<Quote_Approval__c> list_OfQuoteApproval, User quoteOwner){
            
    }
    
    public static Integer getInitialSubscriptionTerm(String InitialSubscriptionTerm, Decimal OtherInitialSubscriptionTerm){
      if(InitialSubscriptionTerm != null){
          if(InitialSubscriptionTerm == 'Other' && OtherInitialSubscriptionTerm != null)
              return Integer.valueof(OtherInitialSubscriptionTerm);
          else
              return Integer.valueof(InitialSubscriptionTerm);
      }      
      return 0;
    }
    
    public static Integer getRampPeriod(String RampPeriod, Decimal OtherRampPeriod){
      if(RampPeriod != null){
          String strRampPeriod =  (RampPeriod == '1 Year'?'365':RampPeriod);
          if(RampPeriod == 'Other' && OtherRampPeriod != null)
              return Integer.valueof(OtherRampPeriod);
          else
              return Integer.valueof(strRampPeriod);
      }      
      return 0;
    }
    public static Integer getPaymentTerms(String PaymentTerms){
      if(PaymentTerms != null && PaymentTerms != 'Other'){
              return Integer.valueof(PaymentTerms.right(2));
      }      
      return 0;
    }
    public static Integer getBillingPeriod(String BillingPeriod){
      if(BillingPeriod != null){
              if(BillingPeriod == 'Monthly')
                  return 1;
              if (BillingPeriod == 'Quarterly')
                  return 2;
              else if (BillingPeriod == 'Semi-Annually')
                  return 3;
              //else if (BillingPeriod == 'Annually')
                  //return 4;
      }    
      return 0;
    }
    
    public static Integer getPCMonthlyMinimum(String PCMonthlyMin, Decimal OtherPCMonthlyMin){
      if(PCMonthlyMin != null){
          if(PCMonthlyMin == 'Other' && OtherPCMonthlyMin != null)
              return Integer.valueof(OtherPCMonthlyMin);
          else
              return Integer.valueof(PCMonthlyMin);
      }      
      return 0;
    }
    
    //Mukunth added below code for INC0416843 - DQ Special Offers Sub-aprpovers
    
    public static Messaging.SingleEmailMessage prepareFinanceApprEmail(list<string> toAddresses, string templateId,string dqId){
        Messaging.SingleEmailMessage ApprEmail = new Messaging.SingleEmailMessage();
        ApprEmail.setTemplateId(Id.valueOf(templateId));
        ApprEmail.setToAddresses(toAddresses);
        ApprEmail.setTargetObjectId(UserInfo.getUserId());
        ApprEmail.setSaveAsActivity(false);
        ApprEmail.setWhatId(Id.valueOf(dqId));
        ApprEmail.setTreatTargetObjectAsRecipient(true);
        //sendEmailToFinArea.add(ApprEmail);
        return ApprEmail;
    }
    
    public static DQSpecOfferSubApprWrapper checkSpecOfferApprPending(Deal_Qualification__c objDQ){
        
        map<string,list<string>> finToAddresses = new map<string,list<string>>();
      list<Quote_Approval__c> dqApprovals = new list<Quote_Approval__c>();
      boolean isSpecApprOfferPending = false;
      map<string, DQ_Special_Offers__c> dqSpecOffersCS = new map<string, DQ_Special_Offers__c>();
      
      dqApprovals = [select id,Reason_Name__c
                      //OwnerId,Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__c 
                      from Quote_Approval__c where Status__c IN ('Pending','In Progress','In-Active') AND Deal_Qualification__c = :objDQ.Id];
      for(Quote_Approval__c dqAppr:dqApprovals){
          if(dqAppr.Reason_Name__c != null && (dqAppr.Reason_Name__c).containsIgnoreCase('Special') && (dqAppr.Reason_Name__c).containsIgnoreCase('Offer') 
              && (label.DQ_SubApprover_Profile_Id.split(';')).contains((UserInfo.getProfileId()).Left(15))){
              isSpecApprOfferPending = true;
              //DQ_SubApprover_Profile_Id
              //dqApprAssignedTo = dqAppr.ownerId;
              //dqAssignedApprover = dqAppr.Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__c;
          }
      }
      
        if(objDQ.Req_Revenue_Approval__c || objDQ.Req_Order_Mgmt_Billing_approval__c || objDQ.Req_Credit_Collections_approval__c
        || objDQ.Req_Legal_approval__c){
            isSpecApprOfferPending = true;
        }
      
        dqSpecOffersCS = DQ_Special_Offers__c.getAll();
        for(string finReg:dqSpecOffersCS.keySet()){
            if(finToAddresses.containsKey(finReg)){
                finToAddresses.get(finReg).add(dqSpecOffersCS.get(finReg).Primary_Contact_Email__c);
                if(!string.isBlank(dqSpecOffersCS.get(finReg).Back_Up_Contact_Email__c))
                    finToAddresses.get(finReg).add(dqSpecOffersCS.get(finReg).Back_Up_Contact_Email__c);
                if(!string.isBlank(dqSpecOffersCS.get(finReg).Additional_Email_Addresses__c))
                    finToAddresses.get(finReg).addAll(dqSpecOffersCS.get(finReg).Additional_Email_Addresses__c.split(';'));
            }
            else{
                finToAddresses.put(finReg,new list<string>{dqSpecOffersCS.get(finReg).Primary_Contact_Email__c});
                if(!string.isBlank(dqSpecOffersCS.get(finReg).Back_Up_Contact_Email__c))
                    finToAddresses.get(finReg).add(dqSpecOffersCS.get(finReg).Back_Up_Contact_Email__c);
                if(!string.isBlank(dqSpecOffersCS.get(finReg).Additional_Email_Addresses__c))
                    finToAddresses.get(finReg).addAll(dqSpecOffersCS.get(finReg).Additional_Email_Addresses__c.split(';'));
            }
        }
        
        DQSpecOfferSubApprWrapper dqSpecOffrWrppr = new DQSpecOfferSubApprWrapper();
        dqSpecOffrWrppr.isSpecApprOfferPending = isSpecApprOfferPending;
        dqSpecOffrWrppr.finToAddresses = finToAddresses;
        
        string usrEmail = UserInfo.getUserEmail();
        set<string> apprEmailSet = new set<string>();
        
        System.Debug('usrEmail--->'+usrEmail);
        
        for(string strEmail:finToAddresses.keyset()){
            for(string emlStr:finToAddresses.get(strEmail)){
                apprEmailSet.add(emlStr);
            }
        }
        
        if(apprEmailSet.contains(usrEmail)){
            dqSpecOffrWrppr.isSubApprover = true;
        }
        else{
            dqSpecOffrWrppr.isSubApprover = false;
        }
        
        return dqSpecOffrWrppr;
    }
    
    public static void sendSpecOfferSubApprEmails(Deal_Qualification__c objDQ, map<string,list<string>> finToAddresses, string region,
                                                    boolean sentRevEmail, boolean sentOMEmail, boolean sentCCEmail, boolean sentLegalEmail){
        EmailTemplate template = new EmailTemplate();
        list<Messaging.SingleEmailMessage> sendEmailToFinArea = new list<Messaging.SingleEmailMessage>();
        if(objDQ.Req_Revenue_Approval__c && !sentRevEmail && string.isBlank(objDQ.Revenue_approval__c)){
            template = [Select Id from emailtemplate where developername = 'DQRevenueApproval' limit 1];
            objDQ.Revenue_approval__c = 'Pending';
            Messaging.SingleEmailMessage revApprEmail = new Messaging.SingleEmailMessage();
            revApprEmail = prepareFinanceApprEmail(finToAddresses.get('Revenue_'+region),template.Id,objDQ.Id);
            sendEmailToFinArea.add(revApprEmail);
        }
        if(objDQ.Req_Order_Mgmt_Billing_approval__c && !sentOMEmail && string.isBlank(objDQ.Order_Mgmt_Billing_approval__c)){
            template = [Select Id from emailtemplate where developername = 'DQOrderMgmtApproval' limit 1];
            objDQ.Order_Mgmt_Billing_approval__c = 'Pending';
            Messaging.SingleEmailMessage ombApprEmail = new Messaging.SingleEmailMessage();
            ombApprEmail = prepareFinanceApprEmail(finToAddresses.get('OrderMgmt_'+region),template.Id,objDQ.Id);
            sendEmailToFinArea.add(ombApprEmail);
        }
        if(objDQ.Req_Credit_Collections_approval__c && !sentCCEmail && string.isBlank(objDQ.Credit_and_Collections_approval__c)){
            template = [Select Id from emailtemplate where developername = 'DQCreditsApproval' limit 1];
            objDQ.Credit_and_Collections_approval__c = 'Pending';
            system.debug('objDQ.Credit_and_Collections_approval__c--->'+objDQ.Credit_and_Collections_approval__c);
            Messaging.SingleEmailMessage ccApprEmail = new Messaging.SingleEmailMessage();
            ccApprEmail = prepareFinanceApprEmail(finToAddresses.get('CreditCollect_'+region),template.Id,objDQ.Id);
            sendEmailToFinArea.add(ccApprEmail);
        }
        if(objDQ.Req_Legal_approval__c && !sentLegalEmail && string.isBlank(objDQ.Legal_approval__c)){
            template = [Select Id from emailtemplate where developername = 'DQLegalApproval' limit 1];
            objDQ.Legal_approval__c = 'Pending';
            Messaging.SingleEmailMessage lglApprEmail = new Messaging.SingleEmailMessage();
            lglApprEmail = prepareFinanceApprEmail(finToAddresses.get('Legal_'+region),template.Id,objDQ.Id);
            sendEmailToFinArea.add(lglApprEmail);
        }
        System.Debug('sendEmailToFinArea--->'+sendEmailToFinArea);
        if((Global_Setting__c.getvalues('DQ SubApprover Send Email').Type__c).containsIgnoreCase('true'))
            Messaging.sendEmail(sendEmailToFinArea);
            
    }
    
    public class DQSpecOfferSubApprWrapper{
        public boolean isSpecApprOfferPending{get;set;}
        public map<string,list<string>> finToAddresses {get;set;}
        public boolean isSubApprover{get;set;}
        public DQSpecOfferSubApprWrapper(){
        }
    }
    
    //Mukunth code end - DQ Special Offers
}