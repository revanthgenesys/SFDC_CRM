/************************************************************************************
Purpose : Includes Subscription related methods
Written By : Ranjith Punneli
Test Classes : SubscriptionUtilTest
*************************************************************************************/

global without sharing class SubscriptionUtil {
    
    public final static string OFFERING_TYPE_PC = 'PureCloud';
    public final static string OFFERING_TYPE_PCC = 'PureConnect Cloud';
    public final static string OFFERING_TYPE_PEC = 'PureEngage Cloud';
    
    // *** Method to return no of subscriptions under an account ***
    public static Integer getSubscriptionCount(Id accountId, String strOfferingType)
    {
        Integer intSubscrSize = [SELECT count() 
                                 FROM Subscription__c 
                                 WHERE Account__c =: accountId
                                 AND Offering_Type__c =: strOfferingType];
        return intSubscrSize;
    }
    // *** Method to return subscription and products under an account ***
    public static Map<Id, Subscription__c> getSubscriptionInfo(Id accountId, String strOfferingType)
    {
        Map<Id, Subscription__c> map_Subscriptions = new Map<Id, Subscription__c>(
            [SELECT Id, Name, Account__c, ACV__c, CMRR__c, TCV__c, Version__c, Bill_To__c, Opportunity_LookUp__c, Opportunity_LookUp__r.Name,
             Account__r.Name, Quote__c, Status__c, Subscription_Start_Date__c, Subscription_End_Date__c, Top_Play__c,Offer__c, 
             Amendment_Date__c, Offering_Type__c, Start_Date__c, Billing_Category__c, Monthly_Minimum__c,
             Org_Id__c, Business_Partner__c, Ramp_Period__c, Price_Book_Currency__c, CurrencyISOCode,
             Term__c, Payment_Term__c, Billing_Period__c, Bill_To_Emails__c,MSA_Link__c,MSA_Link_Type__c,
             Pricing_Method__c,Product_Tier__c,PureSuccess_Offer__c,PureSuccess_Dollar_Amount__c,
             Burst_Allowance__c, Overage_Allowance_Other__c, Annual_Price_Escalation_Other__c,
             Annual_Price_Escalation__c,Deployment_Model__c, recordtypeid, Total_GU_Training_Units__c,
             Bursting_Price_Premium__c,Total_Tokens__c, Telco_CMRR__c, Setup_Provisioning_Charges__c,
             Subscription_Addendum_Type__c, Subscription_Addendum_Link__c,Deal_Registration_Discount__c,Lever__c, Order__r.Maintenance_Start__c,Special_Offer_Terms__c,Order_Special_Offer__c,
             (SELECT Id, Product__c, Product__r.Name, Product__r.APN_Number__c, Net_Unit_Price__c,
              Quantity__c, Total_Discount__c, Product_Quantity__c, Ext_Net_Price__c, CurrencyISOCode,Subscription_Burst_Term__c,
              List_Price__c, Total_Price__c, Is_Overage__c, Subscription__c, Amendment_For__c
              FROM Subscription_Products__r)
             FROM Subscription__c
             WHERE Offering_Type__c = :strOfferingType
             AND Account__c = :accountId
             AND Status__c = 'Active']);         
        return map_Subscriptions;
    }
    
    public static Map<Id, Subscription__c> getSubscriptionInfoWithoutBundleLines(Id accountId, String strOfferingType){
        Map<Id, Subscription__c> map_Subscriptions = new Map<Id, Subscription__c>(
            [SELECT Id, Name, Account__c, ACV__c, CMRR__c, TCV__c, Version__c, Bill_To__c, Opportunity_LookUp__c,Lever__c,
             Account__r.Name, Quote__c, Status__c, Subscription_Start_Date__c, Subscription_End_Date__c, 
             Amendment_Date__c, Offering_Type__c, Start_Date__c, Billing_Category__c, Monthly_Minimum__c,
             Org_Id__c, Business_Partner__c, Ramp_Period__c, Price_Book_Currency__c, CurrencyISOCode,
             Term__c, Payment_Term__c, Billing_Period__c, Bill_To_Emails__c, Bursting_Price_Premium__c,
             Usage_Data_Submission_Method__c, Quote__r.Keep_the_existing_estate_on_Perpetual__c,
             Payment_Terms_Price_Uptick__c, Overage_Allowance_Price_Uptick__c,Top_Play__c,Offer__c, 
             Subscription_Addendum_Type__c, Subscription_Addendum_Link__c, Quote__r.Product_Version__c,
             Burst_Allowance__c,Overage_Allowance_Other__c,Annual_Price_Escalation__c,Annual_Price_Escalation_Other__c, Right_To_Burst__c, Right_To_Remix__c,
             Optional_extended_term_length_Months__c,Order__r.Maintenance_Start__c,Special_Offer_Terms__c,Order_Special_Offer__c,
             (SELECT Id, Product__c, Product__r.Name, Product__r.APN_Number__c, Net_Unit_Price__c,Subscription_Burst_Term__c,
              Quantity__c, Total_Discount__c, Product_Quantity__c, Ext_Net_Price__c, CurrencyISOCode,
              List_Price__c, Total_Price__c, Is_Overage__c, Subscription__c, Amendment_For__c
              FROM Subscription_Products__r WHERE Quote_Product__r.Bundle_Line__c = null)
             FROM Subscription__c
             WHERE Offering_Type__c = :strOfferingType
             AND Account__c = :accountId
             AND Status__c = 'Active']);         
        return map_Subscriptions;
    }
    
    //*** Method to pull original subscription information
    public static List<Subscription__c> getSubscriptionsList(Set<String> set_SubscriptionIds) {
        List<Subscription__c> list_Subscriptions = new List<Subscription__c>();
        list_Subscriptions = [SELECT Id, Name, Account__c, ACV__c, CMRR__c, TCV__c, Version__c, CurrencyISOCode, Bill_To__c,
                              Quote__c, Status__c, Subscription_Start_Date__c, Subscription_End_Date__c, Amendment_Date__c, 
                              Total_Education__c, Total_Hardware__c, Total_Services__c, Offering_Type__c, Business_Partner__c,
                              Term__c, Payment_Term__c, Billing_Period__c, Amendment_For__c, Auto_Renewed__c, Billing_Category__c,
                              Is_Cloned__c, Message__c, Monthly_Minimum__c, Order__c, Org_Id__c, Original_Subscription__c,Top_Play__c,Offer__c,
                              Price_Book_Currency__c, Ramp_Period__c, Renewal_Subscription_Term__c, Sale_Type__c, Total_GU_Training_Units__c,
                              Start_Date__c, Sync_Status__c, Total_Non_Recurring_Fees__c, Bill_To_Emails__c, Opportunity_LookUp__c,
                              Total_Tokens__c, Telco_CMRR__c, Setup_Provisioning_Charges__c,Deal_Registration_Discount__c,Order__r.Maintenance_Start__c,
                              (SELECT Id, or_Amount__c, Adjustment__c, Amendment_For__c, Bundle__c, Disc__c,
                               Ext_List__c, Ext_Net_Price__c, Group_Number__c, Hide_Record__c, Is_Overage__c,
                               Line_Number__c, List_Price__c, Net_Unit_Price__c, Partner_Price__c, CurrencyISOCode,
                               Product__c, Product__r.Name, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c, 
                               Product__r.Product_Group__c, Quote_Product__r.Is_Overage__c, Quote_Product__r.Name,
                               //Total_3rd_Party__c,
                               Product_Option__c, Quantity__c, Quote_Product__c, Subscription__c, Total_Discount__c,Subscription_Burst_Term__c,Total_Price__c                                         
                               FROM Subscription_Products__r)
                              FROM Subscription__c
                              WHERE Id IN : set_SubscriptionIds];
        return list_Subscriptions;
    }
    
    //Added By Ranjith on Nov 3, 2017 -- Starts
    //*** Method to pull original subscription information
    public static Subscription__c getSubscription(Id subscrId) {
        Subscription__c objSubscription = new Subscription__c();
        objSubscription = [SELECT Id, Name, Account__c, ACV__c, CMRR__c, TCV__c, Version__c, CurrencyISOCode, Bill_To__c,Top_Play__c,Offer__c,
                           Quote__c, Status__c, Subscription_Start_Date__c, Subscription_End_Date__c, Amendment_Date__c, 
                           Total_Education__c, Total_Hardware__c, Total_Services__c, Offering_Type__c, Business_Partner__c,
                           Term__c, Payment_Term__c, Billing_Period__c, Amendment_For__c, Auto_Renewed__c, Billing_Category__c,
                           Is_Cloned__c, Message__c, Monthly_Minimum__c, Order__c, Org_Id__c, Original_Subscription__c,
                           Price_Book_Currency__c, Ramp_Period__c, Renewal_Subscription_Term__c, Sale_Type__c, Total_GU_Training_Units__c,
                           Start_Date__c, Sync_Status__c, Total_Non_Recurring_Fees__c, Bill_To_Emails__c, Opportunity_LookUp__c,
                           Total_Tokens__c, Telco_CMRR__c, Setup_Provisioning_Charges__c,Deal_Registration_Discount__c,Order__r.Maintenance_Start__c,Requires_Manual_Billing_Review__c,Manual_Billing_Review_Status__c,
                           (SELECT Id, or_Amount__c, Adjustment__c, Amendment_For__c, Bundle__c, Disc__c, CurrencyISOCode,
                            Ext_List__c, Ext_Net_Price__c, Group_Number__c, Hide_Record__c, Is_Overage__c,
                            Line_Number__c, List_Price__c, Net_Unit_Price__c, Partner_Price__c, Product_Quantity__c,
                            Product__c, Product__r.Name, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c, 
                            Product__r.Product_Group__c, Quote_Product__r.Is_Overage__c, Quote_Product__r.Name,
                            Product_Option__c, Quantity__c, Quote_Product__c, Subscription__c, Total_Discount__c,Subscription_Burst_Term__c, 
                            //Total_3rd_Party__c, 
                            Total_Price__c
                            FROM Subscription_Products__r)
                           FROM Subscription__c
                           WHERE Id =: subscrId LIMIT 1];
        return objSubscription;
    }
    //Added By Ranjith on Nov 3, 2017 -- Ends
    
    //*** Method to pull subscriptions which need to be auto renewed
    public static List<Subscription__c> getSubscriptionsForAutoRenewal(Date dtRunDate) {
        /** Edited by Anto on 08/15/2018 **/
        List<Schema.FieldSetMember> gridFields = SObjectType.Subscription__c.FieldSets.Auto_Renewal_Cloud.getFields();
        String strQueryString = 'Select ';
        for(Schema.FieldSetMember field : gridFields){
            strQueryString += field.getFieldPath() + ', ';
        }
        strQueryString +='(SELECT Id, Status__c, Subscription_End_Date__c,Order_Special_Offer__c,Requires_Manual_Billing_Review__c,Manual_Billing_Review_Status__c FROM NewSubscriptions__r WHERE Status__c = \'' +'Active' +'\''+')FROM Subscription__c WHERE';
        strQueryString += ' Offering_Type__c in (\''+ SubscriptionUtil.OFFERING_TYPE_PC + '\',\''+ SubscriptionUtil.OFFERING_TYPE_PCC + '\',\''+ SubscriptionUtil.OFFERING_TYPE_PEC +'\')'; 
        strQueryString +=' AND Status__c = \'' +'Active' +'\''+' AND Subscription_End_Date__c =  :dtRunDate';
        system.debug(Database.query(strQueryString));
        return Database.query(strQueryString);
        /**Edited by Anto Ends**/
    }
    
    public static List<BigMachines__Quote__c> getQuotes(List<Id> list_QuoteIds ) {
        List<BigMachines__Quote__c> list_Quotes = new List<BigMachines__Quote__c>();
        list_Quotes = [SELECT Id, BigMachines__Opportunity__c, Order__c, Billing_Category__c,BigMachines__Opportunity__r.Contract_Effective_Date__c,Order_Accepted_Date__c,  
                       BigMachines__Opportunity__r.StageName, Offering_Type__c,BigMachines__Opportunity__r.Contract_Expiration_Date__c,
                       BigMachines__Opportunity__r.ForecastStatus__c, New_Price_Book__c,BigMachines__Opportunity__r.Direct_Indirect_Sale__c,
                       BigMachines__Opportunity__r.Contract_Type__c,Sale_Type__c,Name,BigMachines__Opportunity__r.Name,
                       BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,
                       End_User_ID__c, Sold_To_Name__c, Annual_Contract_Value__c, BigMachines__Status__c,
                       Total_Contract_Value__c, CMRR__c, Total_Education__c, Billing_Start_Date__c,
                       Total_Hardware__c, Total_Services__c, Renewal_Subscription_Term__c,
                       Subscription_Start_Date__c, Subscription_End_Date__c, No_Of_Months__c,
                       Subscription_Amend_Date__c, Expiration_Date__c, Non_Recurring_Fees__c,
                       Order_Type__c, Amendment_For__c, Amendment_For__r.Version__c, Billing_Period__c,
                       Amendment_For__r.Org_Id__c, Amendment_For__r.Original_Subscription__c, 
                       Amendment_For__r.Status__c, Amendment_For__r.Committed_Term_Date_Validation__c, Annual_Contract_Value_1__c,
                       Amendment_For__r.ACV__c, Amendment_For__r.TCV__c,Annual_Contract_Value_2__c,
                       Amendment_For__r.Start_Date__c,Amendment_For__r.Contract_Expiration_Date__c,Amendment_For__r.Term__c,
                       Amendment_For__r.Term_Length_Months__c,Amendment_For__r.Ramp_Period__c,Amendment_For__r.Ramp_End_Date__c,
                       Initial_Subscription_Term__c, CurrencyISOCode, Order_Payment_Terms__c,                               
                       Amendment_For__r.Subscription_Start_Date__c, Cloud_Total__c, Ramp_Period__c,
                       Amendment_For__r.Subscription_End_Date__c, PureCloud_Monthly_Minimum__c,
                       Include_Special_Offer_in_Output__c,TAM_Amount__c,TAM_Duration_Months__c,
                       BigMachines__Opportunity__r.ownerid,
                       Annual_Contract_Value_Change__c,Total_Discount_Genesys_and_Third_Party__c,Contract_Signature_Date__c,Top_Play__c,Offer__c,
                       End_User_ID__r.CSM_Account_Owner__c, Reason_for_New_when_Sub_s_Already_Exist__c,
                       Amendment_For__r.Order__c,Amendment_For__r.Order__r.name,Order__r.name,
                       Special_Offer_Terms__c,BigMachines__Opportunity__r.Incremental_Agent_Seat_Count__c,
                       MSA_Link__c,MSA_Link_Type__c, PureSuccess__c, Optional_extended_term_length_Months__c,
                       BigMachines__Opportunity__r.Legal_Exceptions__c,
                       Incentive_Rebate__c,Amendment_For__r.Master_Order_Number__c,Amendment_For__r.Master_Order__c, Order_Date_Submitted__c,
                       Pricing_Model__c,Product_Tier__c,PureSuccess_Offer_Subscription_Amount__c,
                       Overage_Allowance__c, Overage_Allowance_Other__c, Overage_Price_Premium__c, Price_Escalation__c, 
                       Annual_Price_Escalation_Other__c, RightToBurst__c, RightToRemix__c, Usage_Data_Submission_Method__c,                        
                       Subscription_Addendum_Link__c, Subscription_Addendum_Type__c,Minimum_Fees_Period__c, 
                       Order__r.Master_Order_Number__c, Master_Order__c,Token_Value__c, Telco_Cost__c,
                       Setup_Provisioning_Charges__c, Payment_Terms_Price_Uptick__c, Overage_Allowance_Price_Uptick__c, 
                       Deal_Registration_Discount__c,Deployment_Model__c, Total_GU_Training_Units__c,Lever__c,
                       //Mukunthan added below fields to populate PO Number field on CDDB recordtype on 13-MAR-2019
                       Amendment_For__r.Master_Order__r.PO_Number__c,Order__r.PO_Number__c,
                       //Kartik Silla Legal DSR fields/written to CCDB
                       Amendment_For__r.Select_Ramp_Extension_Reason__c,  
                       //Mukunth added for PEC MultiYear ACV
                       //Total_3rd_Party__c, 
                       Multi_Year_ACV_Year_1__c,Multi_Year_ACV_Year_2__c,Multi_Year_ACV_Year_3__c,Multi_Year_ACV_Year_4__c,
                       Multi_Year_ACV_Year_5__c,Multi_Year_ACV_Year_6__c,Multi_Year_ACV_Year_7__c,
                       Multi_Year_ACV_Year_8__c,Multi_Year_ACV_Year_9__c,Multi_Year_ACV_Year_10__c,Contract_terms_drive_ACV_Change__c,
                       //Mukunth code end - PEC MultiYear ACV
                       //kartik special offers sync
                       Amendment_For__r.Master_Special_Offer_Terms__c,Seasonal_License_Net_Value_Y1__c,Seasonal_License_Net_Value_Y2__c,
                        (SELECT Id, Name, BigMachines__Quote__c, List_Price__c,Cumulative_Total_of_Price_for_Amendment__c,
                            Partner_Price__c, Partner_Price_1__c, Partner_Price_2__c, Product_Quantity__c, Hide_Record__c,Play__c,Offer__C,
                            Net_Unit_Price__c, Net_Unit_Price_1__c, Net_Unit_Price_2__c, BigMachines__Total_Price__c,CurrencyISOCode,Billing_Category__c,Active_Start_Date__c,Active_End_Date__c,Type_of_Product__c,
                            BigMachines__Product__c, Quantity__c,BigMachines__Quantity__c, Subscription_Product__r.Quantity__c, Line_Number__c,
                            BigMachines__Product__r.Charge_Type__c, Subscription_Product__c,List_Price_2__c,List_Price_1__c,
                            or_Amount__c, Adjustment__c, Disc__c, Is_Overage__c, Subscription_Burst_Term__c,
                            Ext_List__c, Ext_Net_Price__c, Group_Number__c, Equivalent_Old_List_Price__c, 
                            PM_Approver__c, Product_Option__c, Total_Discount__c, Bundle__r.Group_Type__c,MSRP__c,Bundle_Line__c,
                            BigMachines__Quote__r.Offering_Type__c,BigMachines__Quote__r.No_Of_Months__c, Subscription_Product__r.Ext_Net_Price__c,
                            Subscription_Product__r.Original_List_Price__c,Subscription_Product__r.List_Price__c,Subscription_Product__r.Partner_Price__c
                            FROM BigMachines__BigMachines_Quote_Products__r),
                        (SELECT Id, Quote__c FROM Subscription_Burst_Terms__r)
                       FROM BigMachines__Quote__c
                       WHERE Id IN :list_QuoteIds 
                       AND BigMachines__Opportunity__c != null]; 
        return list_Quotes;
    }
    
    // *** Method to return subscription products under a subscription ***
    public static List<Subscription_Product__c> getSubscriptionProducts(Id subscriptionId)
    {
        List<Subscription_Product__c> list_SubscriptionProds = [SELECT Id, Name, List_Price__c, Partner_Price__c, Is_Overage__c,Quote_Product__r.Product_Specific_Discount__c,
                                                                Net_Unit_Price__c, Total_Price__c, Product__c,Quote_Product__r.Unit_of_Measure__c,
                                                                Product__r.Name, Product__r.APN_Number__c, Amendment_For__c,Ext_Net_Price_Change__c,Play__c,Offer__c,
                                                                or_Amount__c, Adjustment__c, Disc__c, Quantity__c,Quote_Product__c,Billing_Category__c,Active_Start_Date__c,Active_End_Date__c,Type_of_Product__c,
                                                                Ext_List__c, Ext_Net_Price__c, Group_Number__c, CurrencyISOCode,
                                                                PM_Approver__c, Product_Option__c, Total_Discount__c,Product__r.Description__c,
                                                                Product__r.New_Category__c, Product__r.Sub_Category__c, Product__r.Unit_of_Measure__c,
                                                                Product__r.Is_Concurrent__c, Product__r.Third_Party__c, Quote_Product__r.Bundle__r.Type__c, 
                                                                Line_Number__c, Hide_Record__c, Quote_Product__r.Hide_Record__c, Product__r.Type__c,
                                                                Quote_Product__r.Line_Number__c, Quote_Product__r.Bundle__r.Group_Type__c, Quote_Product__r.Bundle__c,Quote_Product__r.BigMachines__Product__r.New_Category__c,
                                                                MSRP__c, Quote_Product__r.Weightage__c,Bundle__c,Quote_Product__r.third_party__c,Subscription_Burst_Term__c
                                                                FROM Subscription_Product__c 
                                                                WHERE Subscription__c = :subscriptionId];     
        return list_SubscriptionProds;
    }
    
    // *** Method to return subscription products under a subscription ***
    public static List<Subscription_Product__c> getSubscriptionProductForSubscrps(Set<Id> set_SubscriptionIds)
    {
        List<Subscription_Product__c> list_SubscriptionProds = [SELECT Id, or_Amount__c, Adjustment__c, Product__c, Product__r.Name, PM_Approver__c,
                                                                Net_Unit_Price__c, Quantity__c, Total_Discount__c, Product__r.APN_Number__c,
                                                                Product_Quantity__c, Ext_Net_Price__c, Disc__c, Ext_List__c,Subscription__r.Offering_Type__c,
                                                                Group_Number__c, Hide_Record__c, Line_Number__c, Partner_Price__c, 
                                                                Product_Option__c, Quote_Product__c, Quote_Product__r.Bundle__c, List_Price__c, Total_Price__c,Play__c,Offer__c,  
                                                                Is_Overage__c, Subscription__c, Bundle__c, Product__r.Price_Type__c,Subscription__r.Business_Partner__r.Approved_for_PureCloud_Billing__c,  
                                                                Subscription__r.Sale_Type__c, Subscription__r.Price_Book_Currency__c, Subscription__r.Billing_category__c,
                                                                Subscription__r.Business_Partner__c, Product__r.Partner_Margin_Type__c,Quote_Product__r.Bundle__r.Group_Type__c, 
                                                                Subscription__r.Business_Partner__r.PartnerType__c, Subscription__r.Business_Partner__r.Partner_Offering_Type__c,Quote_Product__r.BigMachines__Product__r.New_Category__c,
                                                                Product__r.New_Category__c, Product__r.Include_in_CMMR_Total__c, Product__r.Partner_Margin_Category__c,Billing_Category__c,Active_Start_Date__c,Active_End_Date__c,Type_of_Product__c,
                                                                Product__r.Product_Group__c, Product__r.IsActive, Product__r.Show_In_Quoting__c, 
                                                                Product__r.Sub_Category__c, Product__r.Unit_of_Measure__c, CurrencyISOCode,
                                                                Product__r.Is_Concurrent__c, Product__r.Third_Party__c, Amendment_For__c,
                                                                Quote_Product__r.Hide_Record__c, Product__r.NG1_APAC_ANZ_AUD_Price__c, 
                                                                Product__r.NG2_BRAZIL_BRL_Price__c, Product__r.NG3_EMEA_EUR_Price__c, 
                                                                Product__r.NG5_NA_CAD_Price__c, Product__r.NG4_APAC_JAPAN_YEN_Price__c, 
                                                                Product__r.NG5_NZD_Price__c, Product__r.NG3_EMEA_GBP_Price__c, 
                                                                Product__r.NG5_NA_USD_Price__c, Product__r.NG5_ZAR_Price__c,Quote_Product__r.Line_Number__c,
                                                                MSRP__c,Quote_Product__r.Weightage__c,Subscription_Burst_Term__c,
                                                                //Mukunth Quote_Product__r.third_party__c added for PEC
                                                                Quote_Product__r.third_party__c
                                                                FROM Subscription_Product__c
                                                                WHERE Subscription__c IN :set_SubscriptionIds];     
        return list_SubscriptionProds;
    }
    
    // *** Method to build quote products from subscription products ***
    public static BigMachines__Quote_Product__c buildQuoteProdFromSubscrProd(Id quoteId, Subscription_Product__c objSubscrProd)
    {
        BigMachines__Quote_Product__c objNewQP = new BigMachines__Quote_Product__c();
        objNewQP.BigMachines__Quote__c = quoteId;
        objNewQP.Name = objSubscrProd.Product__r.Name;
        objNewQP.APN_Number__c = objSubscrProd.Product__r.APN_Number__c;
        objNewQP.BigMachines__Product__c = objSubscrProd.Product__c;
        objNewQP.Bundle__c =(objSubscrProd.Quote_Product__r.Bundle__r.Group_Type__c != 'Use Case' || objSubscrProd.Quote_Product__r.BigMachines__Product__r.New_Category__c == 'Use Case' )?objSubscrProd.Quote_Product__r.Bundle__c:null;
        objNewQP.Quantity__c = objSubscrProd.Quantity__c;
        objNewQP.List_Price__c = objSubscrProd.List_Price__c;
        objNewQP.Quantity__c = objSubscrProd.Quantity__c;
        objNewQP.BigMachines__Quantity__c = objSubscrProd.Quantity__c != null ? objSubscrProd.Quantity__c : 0;
        objNewQP.Line_Number__c = objSubscrProd.Line_Number__c;
        objNewQP.Hide_Record__c = objSubscrProd.Hide_Record__c;
        objNewQP.Partner_Price__c = objSubscrProd.Partner_Price__c;
        objNewQP.Net_Unit_Price__c = objSubscrProd.Net_Unit_Price__c;
        objNewQP.BigMachines__Sales_Price__c = objSubscrProd.Net_Unit_Price__c != null ? objSubscrProd.Net_Unit_Price__c : 0;
        objNewQP.or_Amount__c = objSubscrProd.or_Amount__c;
        objNewQP.Adjustment__c = objSubscrProd.Adjustment__c;
        objNewQP.Disc__c = objSubscrProd.Disc__c;
        objNewQP.Total_Discount__c = objSubscrProd.Total_Discount__c;
        objNewQP.Group_Number__c = objSubscrProd.Group_Number__c;
        objNewQP.PM_Approver__c = objSubscrProd.PM_Approver__c;
        objNewQP.Product_Option__c = objSubscrProd.Product_Option__c;
        objNewQP.Ext_List__c = objSubscrProd.Ext_List__c;
        objNewQP.Ext_Net_Price__c = objSubscrProd.Ext_Net_Price__c;
        objNewQP.Subscription_Product__c = objSubscrProd.Id;
        objNewQP.Is_Overage__c = objSubscrProd.Is_Overage__c;
        objNewQP.CurrencyISOCode = objSubscrProd.CurrencyISOCode;
        objNewQP.MSRP__c = objSubscrProd.MSRP__c;
        objNewQP.Weightage__c = objSubscrProd.Quote_Product__r.Weightage__c;
        //Rony Joseph-June 5 2019-Trial Automation - Start
        objNewQP.Billing_Category__c = objSubscrProd.Billing_Category__c;
        objNewQP.Active_Start_Date__c = objSubscrProd.Active_Start_Date__c;
        objNewQP.Active_End_Date__c = objSubscrProd.Active_End_Date__c;
        objNewQP.Type_of_Product__c = objSubscrProd.Type_of_Product__c;
        //Mukunth added objNewQP.Third_Party__c = objSubscrProd.Quote_Product__r.third_party__c for PEC
        objNewQP.Third_Party__c = objSubscrProd.Quote_Product__r.third_party__c;
        //Rony Joseph-June 5 2019-Trial Automation - End
        
        objNewQP.Subscription_Burst_Term__c = objSubscrProd.Subscription_Burst_Term__c;        
        return objNewQP;
    }
    // *** Method to build subscription products from quote products ***
    public static Subscription_Product__c buildSubscrProdFromQuoteProd(BigMachines__Quote_Product__c objQtProd)
    {
        Subscription_Product__c objNewSubscriptionProd = new Subscription_Product__c();    
        objNewSubscriptionProd.Product__c = objQtProd.BigMachines__Product__c;                   
        objNewSubscriptionProd.Quantity__c = objQtProd.Quantity__c;
        if(objQtProd.BigMachines__Quantity__c != null && objQtProd.Quantity__c == null)
            objNewSubscriptionProd.Quantity__c = objQtProd.BigMachines__Quantity__c; 
        objNewSubscriptionProd.List_Price__c = objQtProd.List_Price__c;
        objNewSubscriptionProd.Original_List_Price__c = objQtProd.Equivalent_Old_List_Price__c;
        if(objNewSubscriptionProd.Original_List_Price__c == null)
            objNewSubscriptionProd.Original_List_Price__c = objNewSubscriptionProd.List_Price__c;
        objNewSubscriptionProd.Partner_Price__c = objQtProd.Partner_Price__c;
        objNewSubscriptionProd.Net_Unit_Price__c = objQtProd.Net_Unit_Price__c;
        objNewSubscriptionProd.or_Amount__c = objQtProd.or_Amount__c;
        objNewSubscriptionProd.Adjustment__c = objQtProd.Adjustment__c;
        objNewSubscriptionProd.Disc__c = objQtProd.Disc__c;
        objNewSubscriptionProd.Total_Discount__c = objQtProd.Total_Discount__c;
        objNewSubscriptionProd.Group_Number__c = objQtProd.Group_Number__c;
        objNewSubscriptionProd.PM_Approver__c = objQtProd.PM_Approver__c;
        objNewSubscriptionProd.Product_Option__c = objQtProd.Product_Option__c;
        //MS 11/30/19
        if( objQtProd.BigMachines__Quote__r.Offering_Type__c != null && objNewSubscriptionProd.Quantity__c != null &&
            (objQtProd.BigMachines__Quote__r.Offering_Type__c == 'PureEngage Subscription' || 
             objQtProd.BigMachines__Quote__r.Offering_Type__c == 'PureConnect Subscription') ) {

             onPremSubscrProdAmounts(objQtProd, objNewSubscriptionProd);
        }
        else {       
            objNewSubscriptionProd.Ext_List__c = objQtProd.Ext_List__c;
            objNewSubscriptionProd.Ext_Net_Price__c = objQtProd.Ext_Net_Price__c;
            objNewSubscriptionProd.Total_Price__c = objQtProd.BigMachines__Total_Price__c; 
        }

        objNewSubscriptionProd.Quote_Product__c = objQtProd.Id;
        objNewSubscriptionProd.Is_Overage__c = objQtProd.Is_Overage__c;
        objNewSubscriptionProd.Subscription_Burst_Term__c = objQtProd.Subscription_Burst_Term__c;
        objNewSubscriptionProd.Line_Number__c = objQtProd.Line_Number__c;
        objNewSubscriptionProd.Hide_Record__c = objQtProd.Hide_Record__c;
        objNewSubscriptionProd.Amendment_For__c =  objQtProd.Subscription_Product__c != null ? objQtProd.Subscription_Product__c : null;
        objNewSubscriptionProd.CurrencyISOCode = objQtProd.CurrencyISOCode;
        objNewSubscriptionProd.MSRP__c = objQtProd.MSRP__c;
        //Rony Joseph-June 5 2019-Trial Automation - Start
        objNewSubscriptionProd.Billing_Category__c = objQtProd.Billing_Category__c;
        objNewSubscriptionProd.Type_of_Product__c = objQtProd.Type_of_Product__c;
        objNewSubscriptionProd.Active_End_Date__c = objQtProd.Active_End_Date__c;
        objNewSubscriptionProd.Active_Start_Date__c = objQtProd.Active_Start_Date__c;
        //Rony Joseph-June 5 2019-Trial Automation - End
        objNewSubscriptionProd.Store_Cumulative_Total_for_Amend__c= objQtProd.Cumulative_Total_of_Price_for_Amendment__c;
        
        return objNewSubscriptionProd;
    }
    
    // *** Method to build subscription from quote ***
    public static Subscription__c buildSubscrFromQuote(BigMachines__Quote__c objQuote)
    {
        Subscription__c objNewSubscription = new Subscription__c();
        objNewSubscription.Quote__c = objQuote.Id;
        objNewSubscription.Account__c = objQuote.End_User_ID__c;
        objNewSubscription.Business_Partner__c = objQuote.Sold_To_Name__c;
        objNewSubscription.Bill_To__c = objNewSubscription.Business_Partner__c;
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC 
           && !objQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
               objNewSubscription.Bill_To__c = objNewSubscription.Account__c;
           }
        objNewSubscription.Order__c = objQuote.Order__c;
        objNewSubscription.Opportunity_LookUp__c = objQuote.BigMachines__Opportunity__c;
        //Kartik Silla  Legal DSR fields/written to CCDB
        list<GCR__c> GC = new List<GCR__c>();
        GC = [select id,Ramp_Extension_Reason__c,Is_this_DSR_for_a_Ramp_Extension__c from GCR__c where Opportunity__c=:objQuote.BigMachines__Opportunity__c and status__c = '10-Completed'];
        system.debug('GC'+GC.size());
        if(GC.size() > 0)
        {
            if(GC[0].Is_this_DSR_for_a_Ramp_Extension__c == 'Yes' )
            {
                objNewSubscription.Select_Ramp_Extension_Reason__c = GC[0].Ramp_Extension_Reason__c;     
            }
        }
        else if(GC.size() == 0 && objQuote.Order_Type__c == Label.Amend_Subscription)
        {
            objNewSubscription.Select_Ramp_Extension_Reason__c = objQuote.Amendment_For__r.Select_Ramp_Extension_Reason__c;    
        }
        system.debug('coming'+objQuote.Amendment_For__r.Select_Ramp_Extension_Reason__c);
        // objNewSubscription.Select_Ramp_Extension_Reason__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Amendment_For__r.Select_Ramp_Extension_Reason__c : objNewSubscription.Select_Ramp_Extension_Reason__c;
        objNewSubscription.PO_Number__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Amendment_For__r.Master_Order__r.PO_Number__c : objQuote.Order__r.PO_Number__c;
        
        objNewSubscription.Offering_Type__c = objQuote.Offering_Type__c;
        objNewSubscription.Start_Date__c = objQuote.Billing_Start_Date__c;
        objNewSubscription.Subscription_Start_Date__c = objQuote.Subscription_Start_Date__c != null ? objQuote.Subscription_Start_Date__c : System.today();
        objNewSubscription.Subscription_End_Date__c = objQuote.Subscription_End_Date__c;
        objNewSubscription.Status__c = 'Active';
        objNewSubscription.Total_Education__c = objQuote.Total_Education__c;
        objNewSubscription.Total_Hardware__c = objQuote.Total_Hardware__c;
        objNewSubscription.Total_Services__c = objQuote.Total_Services__c;
       //MS commented 11/20/19 objNewSubscription.Total_3rd_Party__c = objQuote.Total_3rd_Party__c; // Added by navaneetha for 3rd party 21/10/2019
        objNewSubscription.Total_Non_Recurring_Fees__c = objQuote.Non_Recurring_Fees__c;
        objNewSubscription.CMRR__c = objQuote.CMRR__c;
        objNewSubscription.ACV__c = objQuote.Annual_Contract_Value__c;
        objNewSubscription.TCV__c = objQuote.Total_Contract_Value__c; 
        //Added By Ranjith on Apr 23, 2019 -- Starts -- Reason for new sub 
        objNewSubscription.Reason_for_New_when_Sub_s_Already_Exist__c = objQuote.Reason_for_New_when_Sub_s_Already_Exist__c;
        //Added By Ranjith on Apr 23, 2019 -- Ends -- Reason for new sub 
        
        //Naresh Kumar  11/12/2017 Adding different fields depending on offering types.

        if  (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription')  {
            objNewSubscription.Amendment_For__c = objQuote.Amendment_For__c;
            objNewSubscription.PureSuccess_Offer__c = objQuote.PureSuccess__c == null ? 'Standard Support' : objQuote.PureSuccess__c;
            
            if ( objQuote.Optional_extended_term_length_Months__c != null && objQuote.No_Of_Months__c > 12 )
                objNewSubscription.Anniversary_Date__c = System.today().addMonths(Integer.valueOf(objQuote.Optional_extended_term_length_Months__c));
            
            if(objQuote.Overage_Allowance__c != null && objQuote.Overage_Allowance__c != 'N/A'){
                if(objQuote.Overage_Allowance__c != 'Other')
                    objNewSubscription.Burst_Allowance__c = Decimal.valueOf(objQuote.Overage_Allowance__c.replace('%',''));
                objNewSubscription.Overage_Allowance_Other__c = objQuote.Overage_Allowance_Other__c;                
            }
            objNewSubscription.Bursting_Price_Premium__c = objQuote.Overage_Price_Premium__c;
            objNewSubscription.Payment_Term__c = objQuote.Order_Payment_Terms__c;
            if(objQuote.Price_Escalation__c != null && (objQuote.Price_Escalation__c != 'N/A')){
                if(objQuote.Price_Escalation__c != 'Other')                
                    objNewSubscription.Annual_Price_Escalation__c = Decimal.valueOf(objQuote.Price_Escalation__c.replace('%',''));
                objNewSubscription.Annual_Price_Escalation_Other__c = objQuote.Annual_Price_Escalation_Other__c;
            }
            if(objQuote.Price_Escalation__c == 'Other'){
                objNewSubscription.Annual_Price_Escalation_Other__c = objQuote.Annual_Price_Escalation_Other__c;
            }   
            objNewSubscription.Payment_Terms_Price_Uptick__c = objQuote.Payment_Terms_Price_Uptick__c;
            objNewSubscription.Overage_Allowance_Price_Uptick__c = objQuote.Overage_Allowance_Price_Uptick__c;            
            objNewSubscription.Right_To_Burst__c = objQuote.RightToBurst__c;
            objNewSubscription.Right_To_Remix__c = objQuote.RightToRemix__c;
            objNewSubscription.Optional_extended_term_length_Months__c = objQuote.Optional_extended_term_length_Months__c;
            objNewSubscription.Usage_Data_Submission_Method__c = objQuote.Usage_Data_Submission_Method__c;
            objNewSubscription.Pricing_Method__c = objQuote.Pricing_Model__c;
            objNewSubscription.Includes_Special_Offers__c = objQuote.Include_Special_Offer_in_Output__c;
            objNewSubscription.MSA_Link__c = objQuote.MSA_Link__c;
            objNewSubscription.MSA_Link_Type__c = objQuote.MSA_Link_Type__c;
            objNewSubscription.Subscription_Addendum_Link__c = objQuote.Subscription_Addendum_Link__c;
            objNewSubscription.Subscription_Addendum_Type__c = objQuote.Subscription_Addendum_Type__c; 
            objNewSubscription.Master_Order__c = objQuote.Order__c;
            if(objQuote.End_User_ID__c == objQuote.Sold_To_Name__c){
                objNewSubscription.Business_Partner__c = null;
                objNewSubscription.Bill_To__c = objQuote.End_User_ID__c;
            }
            else{
                objNewSubscription.Business_Partner__c = objQuote.Sold_To_Name__c;    
                objNewSubscription.Bill_To__c = objNewSubscription.Business_Partner__c;
            }

            onPremSubscrTotals(objQuote, objNewSubscription);

        } ///END Premise Subscription

        objNewSubscription.Version__c = 1;
        objNewSubscription.Amendment_Date__c = null;
        objNewSubscription.Billing_Category__c = objQuote.Billing_Category__c;
        objNewSubscription.Billing_Period__c = objQuote.Billing_Period__c;
        objNewSubscription.Renewal_Subscription_Term__c = objQuote.Renewal_Subscription_Term__c;
        objNewSubscription.Price_Book_Currency__c = objQuote.New_Price_Book__c;
        objNewSubscription.CurrencyISOCode = objQuote.CurrencyISOCode;
        
        if( (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') && 
           objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c != null)
            objNewSubscription.Sale_Type__c = objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Direct' ? 'Direct' : 'Indirect';
        else 
            objNewSubscription.Sale_Type__c = objQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c ? 'Indirect' : 'Direct';
        
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC) {
            objNewSubscription.Monthly_Minimum__c = objQuote.PureCloud_Monthly_Minimum__c;            
        }     
        objNewSubscription.Term__c = objQuote.Initial_Subscription_Term__c;
        objNewSubscription.Payment_Term__c = objQuote.Order_Payment_Terms__c;
        
        //Anju recordtype setting for Cloud
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
        {
            objNewSubscription.recordtypeid = Schema.SObjectType.Subscription__c.getRecordTypeInfosByName().get('Cloud').getRecordTypeId();
            objNewSubscription.Deal_Registration_Discount__c = objQuote.Deal_Registration_Discount__c;
        }
        //Anju Gain sight relationship setup
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
            objNewSubscription.Gainsight_Relationship_Type__c = SubscriptionUtil.OFFERING_TYPE_PC;
        else if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
            objNewSubscription.Gainsight_Relationship_Type__c = SubscriptionUtil.OFFERING_TYPE_PCC;
        // Added by kartik
        else if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
            objNewSubscription.Gainsight_Relationship_Type__c = SubscriptionUtil.OFFERING_TYPE_PEC;
        if(objQuote.Ramp_Period__c != null){
            String strRampPeriod =  (objQuote.Ramp_Period__c == '1 Year'?'365':objQuote.Ramp_Period__c);
            objNewSubscription.Ramp_Period__c = Integer.valueOf(strRampPeriod)/30;
        }
        //Anju May 30 New fields for CCDB Cloud renewal
        objNewSubscription.Includes_Special_Offers__c = objQuote.Include_Special_Offer_in_Output__c;
        if(objQuote.Special_Offer_Terms__c != NULL)
            objNewSubscription.Includes_Special_Offers__c = True;
        objNewSubscription.TAM_Services_Amount__c = objQuote.TAM_Amount__c;
        objNewSubscription.TAM_Duration_Months__c = objQuote.TAM_Duration_Months__c;
        /*objNewSubscription.Opportunity_Owner__c = objQuote.BigMachines__Opportunity__r.ownerid;*/
        //objNewSubscription.ACV_Changes__c = objQuote.Annual_Contract_Value_Change__c;
        objNewSubscription.Total_Discount_Genesys_and_Third_Party__c = objQuote.Total_Discount_Genesys_and_Third_Party__c;
        objNewSubscription.Contract_Signature_Date__c = objQuote.Contract_Signature_Date__c;
        Map<String,JBCXM__GSRelationship__c> map_AccountGSRelationship = OpportunityUtil.FetchGSRelationship(new Set<Id>{objQuote.End_User_ID__c});
        objNewSubscription.CSM__c = (map_AccountGSRelationship.containskey(objQuote.End_User_ID__c + ':' + objQuote.Offering_Type__c)&& map_AccountGSRelationship.get(objQuote.End_User_ID__c + ':' + objQuote.Offering_Type__c) !=null)? map_AccountGSRelationship.get(objQuote.End_User_ID__c + ':' + objQuote.Offering_Type__c).JBCXM__GSCSM__c : objQuote.End_User_ID__r.CSM_Account_Owner__c;
        
        //Anju June 6 Rebate
        objNewSubscription.Incentive_Rebate__c = objQuote.Incentive_Rebate__c;
        
        //Anju May 31 Revpro
        //Kartik PEC condition
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ) {
            objNewSubscription.Master_Order__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Amendment_For__r.Master_Order__c : objQuote.Order__c;
            objNewSubscription.Master_Special_Offer_Terms__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Amendment_For__r.Master_Special_Offer_Terms__c : objQuote.Special_Offer_Terms__c;
        }

        objNewSubscription.Order_Special_Offer__c = objQuote.Special_Offer_Terms__c;

        /*  else if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) {
objNewSubscription.Master_Order__c = objQuote.Master_Order__c == null ? objQuote.Order__c : objQuote.Master_Order__c;
} */
        
        //Mukunthan added below line to populate PO Number from Master Order on 13-MAR-2019
        objNewSubscription.PO_Number__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Amendment_For__r.Master_Order__r.PO_Number__c : objQuote.Order__r.PO_Number__c;
        
        //objNewSubscription.Special_Offer_Terms_Business_Exception__c = objQuote.Special_Offer_Terms__c;
        objNewSubscription.Minimum_Agent_Quantity__c = objQuote.BigMachines__Opportunity__r.Incremental_Agent_Seat_Count__c;
        objNewSubscription.MSA_Link__c = objQuote.MSA_Link__c;
        objNewSubscription.MSA_Link_Type__c = objQuote.MSA_Link_Type__c;
        objNewSubscription.Legal_Exceptions__c = ((objQuote.MSA_Link_Type__c == 'Custom'||(objQuote.MSA_Link_Type__c == 'Standard' && objQuote.Order_Type__c == Label.Amend_Subscription ) )&& objQuote.BigMachines__Opportunity__r.Legal_Exceptions__c != null )?objQuote.BigMachines__Opportunity__r.Legal_Exceptions__c:'';
        Opportunity ObjOpp = [select Contract_Effective_Date__c,Contract_Expiration_Date__c from Opportunity where id = :objQuote.BigMachines__Opportunity__c];
        objNewSubscription.Contract_Effective_Date__c = (objQuote.MSA_Link_Type__c == 'Custom'||(objQuote.MSA_Link_Type__c == 'Standard' && objQuote.Order_Type__c == Label.Amend_Subscription ) )?(objQuote.BigMachines__Opportunity__r.Legal_Exceptions__c != null?((objOpp.Contract_Effective_Date__c != null)?(objOpp.Contract_Effective_Date__c):Date.valueof(objQuote.Contract_Signature_Date__c)):((objOpp.Contract_Effective_Date__c != null)?(objOpp.Contract_Effective_Date__c):null)):
        ((objQuote.BigMachines__Opportunity__r.Legal_Exceptions__c != null)?((objOpp.Contract_Effective_Date__c != null)?(objOpp.Contract_Effective_Date__c):Date.valueof(objQuote.Contract_Signature_Date__c)):((Date.valueof(objQuote.Contract_Signature_Date__c) != null)?(Date.valueof(objQuote.Contract_Signature_Date__c)):null));
            objNewSubscription.Contract_Expiration_Date__c = (objQuote.MSA_Link_Type__c == 'Custom'||(objQuote.MSA_Link_Type__c == 'Standard' && objQuote.Order_Type__c == Label.Amend_Subscription ) )?(objQuote.BigMachines__Opportunity__r.Legal_Exceptions__c != null?((objOpp.Contract_Expiration_Date__c != null)?(objOpp.Contract_Expiration_Date__c):Date.valueof(objQuote.Subscription_End_Date__c)):((objOpp.Contract_Expiration_Date__c != null)?(objOpp.Contract_Expiration_Date__c):null)):
        ((objQuote.BigMachines__Opportunity__r.Legal_Exceptions__c != null)?((objOpp.Contract_Expiration_Date__c != null)?(objOpp.Contract_Expiration_Date__c):Date.valueof(objQuote.Subscription_End_Date__c)):(Date.valueof(objQuote.Subscription_End_Date__c)!=null?Date.valueof(objQuote.Subscription_End_Date__c):null));  
            String strContractType = '';
        List<Governing_Contract_Type__mdt> listOfContractTypes = [SELECT Governing_Contract_Type__c FROM Governing_Contract_Type__mdt WHERE Offering_Type__c = :objQuote.Offering_Type__c];            
        if(!listOfContractTypes.isEmpty())
            strContractType = listOfContractTypes[0].Governing_Contract_Type__c;
        objNewSubscription.Contract_Type__c = ((objQuote.MSA_Link_Type__c == 'Custom'||(objQuote.MSA_Link_Type__c == 'Standard' && objQuote.Order_Type__c == Label.Amend_Subscription ) ) && objQuote.BigMachines__Opportunity__c != null) ?  objQuote.BigMachines__Opportunity__r.Contract_Type__c : strContractType;
        objNewSubscription.Term_Length_Months__c = objQuote.No_Of_Months__c;
        objNewSubscription.Ramp_End_Date__c = objQuote.Subscription_Start_Date__c != null ?(objQuote.Subscription_Start_Date__c - 1): objQuote.Order_Date_Submitted__c;
        if((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)&& objNewSubscription.Ramp_Period__c == 0 && objQuote.Subscription_Start_Date__c!=null) {
            objNewSubscription.Ramp_End_Date__c = objQuote.Subscription_Start_Date__c;
        }
        //Anju PCC Subscriptions
        //added PEC by kartik
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
        {
            objNewSubscription.Pricing_Method__c = objQuote.Pricing_Model__c;
            objNewSubscription.Product_Tier__c = objQuote.Product_Tier__c;
            objNewSubscription.PureSuccess_Offer__c = objQuote.PureSuccess__c;
            objNewSubscription.PureSuccess_Dollar_Amount__c = objQuote.PureSuccess_Offer_Subscription_Amount__c;
            //objNewSubscription.Burst_Allowance__c = objQuote.Overage_Allowance_Other__c != null ? objQuote.Overage_Allowance_Other__c : 20;
            //objNewSubscription.Annual_Price_Escalation__c = objQuote.Annual_Price_Escalation_Other__c != null ? objQuote.Annual_Price_Escalation_Other__c : Decimal.valueof(objQuote.Price_Escalation__c.replace('%',''));
            system.debug('1****'+objNewSubscription.Annual_Price_Escalation__c);
            system.debug('2****'+objQuote.Price_Escalation__c);
            objNewSubscription.Annual_Price_Escalation__c = (objQuote.Price_Escalation__c != null && objQuote.Price_Escalation__c != 'Other') ? Decimal.valueof(objQuote.Price_Escalation__c.replace('%','')) : null;
            objNewSubscription.Annual_Price_Escalation_Other__c = objQuote.Annual_Price_Escalation_Other__c;
            objNewSubscription.Burst_Allowance__c = (objQuote.Overage_Allowance__c != null && objQuote.Overage_Allowance__c != 'Other') ? Decimal.valueof(objQuote.Overage_Allowance__c.replace('%','')) : null;
            objNewSubscription.Overage_Allowance_Other__c = objQuote.Overage_Allowance_Other__c;
            objNewSubscription.Total_Tokens__c = objQuote.Token_Value__c == null ? 0 : objQuote.Token_Value__c;
            objNewSubscription.Total_GU_Training_Units__c = objQuote.Total_GU_Training_Units__c == null ? 0 : objQuote.Total_GU_Training_Units__c;
            objNewSubscription.Telco_CMRR__c = objQuote.Telco_Cost__c == null ? 0 : objQuote.Telco_Cost__c;
            objNewSubscription.Setup_Provisioning_Charges__c = objQuote.Setup_Provisioning_Charges__c == null ? 0 : objQuote.Setup_Provisioning_Charges__c;
            objNewSubscription.Deployment_Model__c = objQuote.Deployment_Model__c;
        }
        
        //mukunth added to capture PEC Multi-Year ACV
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC){
            objNewSubscription.ACV_Year_1__c = objQuote.Multi_Year_ACV_Year_1__c;
            objNewSubscription.ACV_Year_2__c = objQuote.Multi_Year_ACV_Year_2__c;
            objNewSubscription.ACV_Year_3__c = objQuote.Multi_Year_ACV_Year_3__c;
            objNewSubscription.ACV_Year_4__c = objQuote.Multi_Year_ACV_Year_4__c;
            objNewSubscription.ACV_Year_5__c = objQuote.Multi_Year_ACV_Year_5__c;
            objNewSubscription.ACV_Year_6__c = objQuote.Multi_Year_ACV_Year_6__c;
            objNewSubscription.ACV_Year_7__c = objQuote.Multi_Year_ACV_Year_7__c;
            objNewSubscription.ACV_Year_8__c     = objQuote.Multi_Year_ACV_Year_8__c;
            objNewSubscription.ACV_Year_9__c = objQuote.Multi_Year_ACV_Year_9__c;
            objNewSubscription.ACV_Year_10__c = objQuote.Multi_Year_ACV_Year_10__c;
            objNewSubscription.Contract_terms_drive_ACV_Change__c = objQuote.Contract_terms_drive_ACV_Change__c;
        }       
        //Mukunth code end
        
        //Anju PC PureSuccess
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
        {
            objNewSubscription.Total_Tokens__c = objQuote.Token_Value__c == null ? 0 : objQuote.Token_Value__c;
            objNewSubscription.Total_GU_Training_Units__c = objQuote.Total_GU_Training_Units__c == null ? 0 : objQuote.Total_GU_Training_Units__c;
            objNewSubscription.PureSuccess_Offer__c = objQuote.PureSuccess__c;
            objNewSubscription.PureSuccess_Dollar_Amount__c = objQuote.PureSuccess_Offer_Subscription_Amount__c;   
            //Added By Ranjith on Jan 14, 2018 - Starts - RevPro Changes
            objNewSubscription.Committed_Term_Date_Validation__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Order_Accepted_Date__c : objQuote.Order_Accepted_Date__c;//Rony Joseph - August 11 2019 -Changed value from Subscription Start Date to Order Accepted Date - RevPro Change
            //Added By Ranjith on Jan 14, 2018 - Ends - RevPro Changes                 
        }           
        if(objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription'){
            //MS 11/22/2019 New quote, not amendment
             if (objQuote.Amendment_For__c == null) {
                //Subscr Start date
                if(objQuote.Ramp_Period__c != null && objQuote.Ramp_Period__c != 'Other') {
                    if (objQuote.Ramp_Period__c != null ) {
                        Integer rampMon=0;
                        if ( objQuote.Ramp_Period__c == '1 Year' )
                            rampMon = 12;
                        else
                            rampMon = objQuote.Ramp_Period__c.isNumeric() ? Integer.valueOf(objQuote.Ramp_Period__c)/30 : 0;
                    
                        objNewSubscription.Ramp_End_Date__c = (objQuote.Subscription_Start_Date__c != null && rampMon != 0) ? 
                                                                objQuote.Subscription_Start_Date__c.addMonths(rampMon).addDays(-1) : objQuote.Subscription_Start_Date__c;
                        objNewSubscription.Subscription_Start_Date__c = (objNewSubscription.Ramp_End_Date__c != null && rampMon != 0) ? 
                                                                objNewSubscription.Ramp_End_Date__c.addDays(1) : objQuote.Subscription_Start_Date__c;
                    }
                }
                else {
                     objNewSubscription.Subscription_Start_Date__c = objQuote.Subscription_Start_Date__c;
                     objNewSubscription.Ramp_End_Date__c  = objQuote.Subscription_Start_Date__c;
                }  
                ///Subscr End Date
                if ( objQuote.No_Of_Months__c != null ) {
                    try {
                        Decimal trm = (objQuote.No_Of_Months__c/12).round(System.RoundingMode.CEILING);
                        objNewSubscription.Term__c = String.valueOf(trm) + ' ' + ((trm == 1) ? 'Year' : 'Years');
                    }  catch(Exception e) {}

                    //Subscription End Date: add term to the Start Date after Deployment Period was laready added
                    //objNewSubscription.Subscription_End_Date__c = (objNewSubscription.Subscription_Start_Date__c).addMonths(Integer.valueOf(objQuote.No_Of_Months__c));
                }
                objNewSubscription.Contract_Expiration_Date__c = objNewSubscription.Subscription_End_Date__c;
                objNewSubscription.Master_Special_Offer_Terms__c = objQuote.Special_Offer_Terms__c;
                ///TODO - objNewSubscription.Master_Special_Offer_Terms__c from master Order              
            }
            else { //Amendment - all copied from CCDB
                 objNewSubscription.Subscription_Start_Date__c = objQuote.Amendment_For__r.Subscription_Start_Date__c;
                 objNewSubscription.Subscription_End_Date__c = objQuote.Amendment_For__r.Subscription_End_Date__c;
                 objNewSubscription.Start_Date__c = objQuote.Amendment_For__r.Start_Date__c;
                 objNewSubscription.Contract_Expiration_Date__c = objQuote.Amendment_For__r.Contract_Expiration_Date__c;
                 objNewSubscription.Term__c = objQuote.Amendment_For__r.Term__c;
                 objNewSubscription.Term_Length_Months__c = objQuote.No_Of_Months__c; // objQuote.Amendment_For__r.Term_Length_Months__c; //MS from Quote
                 objNewSubscription.Ramp_Period__c = objQuote.Amendment_For__r.Ramp_Period__c;
                 objNewSubscription.Ramp_End_Date__c = objQuote.Amendment_For__r.Ramp_End_Date__c;
                 objNewSubscription.Amendment_Date__c = System.today();
             }
        }
        //Anju August 2018 Revpro clear fields for PEC
        // commented by kartik
        /*   if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
{
objNewSubscription.Billing_Category__c = null;
objNewSubscription.Ramp_End_Date__c = null;
objNewSubscription.Subscription_End_Date__c = null;
objNewSubscription.Offering_Type__c = 'PureEngage Cloud';
} */
        System.debug('objNewSubscription:'+objNewSubscription.Select_Ramp_Extension_Reason__c);
        //Rony Joseph-PureBridge No Billing flag-June 5th 2019
        if((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC || objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') &&(objQuote.Lever__c !=null) ){
            objNewSubscription.No_Billing_During_Ramp__c = (objQuote.Lever__C.contains('Lever 1'))?true:false;
        }                                                     
        return objNewSubscription;
    
    } //END buildSubscrFromQuote
    
    // *** Method to build quote from subscription ***
    public static BigMachines__Quote__c buildQuoteFromSubscr(Subscription__c objSubscription, BigMachines__Quote__c objQt)
    {
        BigMachines__Quote__c objQuote = new BigMachines__Quote__c();        
        if(objQt != null) {
            objQuote = objQt;
        }    
        objQuote.Offering_Type__c = objSubscription.Offering_Type__c;
        objQuote.ownerId = userInfo.getUserId();
        objQuote.End_User_ID__c = objSubscription.Account__c;
        objQuote.BigMachines__Account__c = objSubscription.Account__c;
        if(objSubscription.Business_Partner__c != null)
            objQuote.Sold_To_Name__c = objSubscription.Business_Partner__c;

        if(objQuote.Offering_Type__c != 'PureEngage Subscription' && objQuote.Offering_Type__c != 'PureConnect Subscription'){
            objQuote.Billing_Start_Date__c = objSubscription.Start_Date__c;
            objQuote.Subscription_Start_Date__c = objSubscription.Subscription_Start_Date__c;           
            objQuote.Subscription_End_Date__c = objSubscription.Subscription_End_Date__c;
            objQuote.No_Of_Months__c = objQuote.Subscription_Start_Date__c.monthsBetween(objQuote.Subscription_End_Date__c);
        } 
        objQuote.Initial_Subscription_Term__c = objSubscription.Term__c; //objQuote.No_Of_Months__c == 12 ? '1 Year' : (objQuote.No_Of_Months__c > 12 ? (objQuote.No_Of_Months__c/12) + ' Years' : '1 Month');
        objQuote.Billing_Category__c = objSubscription.Billing_Category__c;
        objQuote.Billing_Period__c = objSubscription.Billing_Period__c;
        objQuote.Ramp_Period__c = (objSubscription.Ramp_Period__c != 12)?String.valueOf(objSubscription.Ramp_Period__c * 30):'1 Year';
        objQuote.PureCloud_Monthly_Minimum__c = objSubscription.Monthly_Minimum__c;
        objQuote.New_Price_Book__c = objSubscription.Price_Book_Currency__c; 
        objQuote.CurrencyISOCode = objSubscription.CurrencyISOCode;
        objQuote.Order_Payment_Terms__c = objSubscription.Payment_Term__c;
        objQuote.Lever__c = objSubscription.Lever__c;
        
        //Naresh Kumar  08/23/2018 Adding different fields depending on offering types.
        if(objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') {
            ///Start Date is Today
            //objQuote.Subscription_Start_Date__c = objSubscription.Order__r.Maintenance_Start__c != null ? objSubscription.Order__r.Maintenance_Start__c : objSubscription.Start_Date__c;          
            objQuote.Subscription_Start_Date__c = System.Today() > objSubscription.Subscription_Start_Date__c ? System.Today() : objSubscription.Subscription_Start_Date__c;
            objQuote.Subscription_End_Date__c = objSubscription.Subscription_End_Date__c;
            objQuote.No_Of_Months__c = objQuote.Subscription_Start_Date__c.monthsBetween(objQuote.Subscription_End_Date__c);
            objQuote.Billing_Start_Date__c = objQuote.Subscription_Start_Date__c; 

            objQuote.Overage_Price_Premium__c = objSubscription.Bursting_Price_Premium__c; 
            objQuote.Usage_Data_Submission_Method__c = objSubscription.Usage_Data_Submission_Method__c;
            objQuote.Keep_the_existing_estate_on_Perpetual__c = objSubscription.Quote__r.Keep_the_existing_estate_on_Perpetual__c;
    
            objQuote.Overage_Allowance__c = objSubscription.Overage_Allowance_Other__c != null ? 'Other' : objSubscription.Burst_Allowance__c+'%';
            objQuote.Overage_Allowance_Other__c = objSubscription.Overage_Allowance_Other__c;

            objQuote.Price_Escalation__c = objSubscription.Annual_Price_Escalation_Other__c != null ? 'Other' : 
                                           objSubscription.Annual_Price_Escalation__c != null ? objSubscription.Annual_Price_Escalation__c+'%' : '';
            objQuote.Annual_Price_Escalation_Other__c = objSubscription.Annual_Price_Escalation_Other__c;

            objQuote.RightToBurst__c = objSubscription.Right_To_Burst__c;
            objQuote.RightToRemix__c = objSubscription.Right_To_Remix__c;
            objQuote.Optional_extended_term_length_Months__c = objSubscription.Optional_extended_term_length_Months__c;
            objQuote.Payment_Terms_Price_Uptick__c = objSubscription.Payment_Terms_Price_Uptick__c;
            objQuote.Overage_Allowance_Price_Uptick__c = objSubscription.Overage_Allowance_Price_Uptick__c;
            objQuote.Subscription_Addendum_Type__c = objSubscription.Subscription_Addendum_Type__c;
            objQuote.Subscription_Addendum_Link__c = objSubscription.Subscription_Addendum_Link__c;    
            objQuote.Product_Version__c = objSubscription.Quote__r.Product_Version__c; 
        }
        //Anju new fields for PCC
        //Added PEC condition bt Kartik
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
        {
            objQuote.Pricing_Model__c = objSubscription.Pricing_Method__c;
            objQuote.Product_Tier__c = objSubscription.Product_Tier__c;
            objQuote.PureSuccess__c = objSubscription.PureSuccess_Offer__c;
            objQuote.PureSuccess_Offer_Subscription_Amount__c = objSubscription.PureSuccess_Dollar_Amount__c;
            objQuote.Token_Value__c = objSubscription.Total_Tokens__c;
            objQuote.Total_GU_Training_Units__c = objSubscription.Total_GU_Training_Units__c;
            objQuote.Setup_Provisioning_Charges__c = objSubscription.Setup_Provisioning_Charges__c;
            // objQuote.Price_Escalation__c = objSubscription.Annual_Price_Escalation_Other__c != null ? 'Other' : objSubscription.Annual_Price_Escalation__c+'%';
            // Added by Kartik for Null check before maping Annual_Price_Escalation__c to Price_Escalation__c
            objQuote.Price_Escalation__c = objSubscription.Annual_Price_Escalation_Other__c != null ? 'Other' : objSubscription.Annual_Price_Escalation__c != null ? objSubscription.Annual_Price_Escalation__c+'%' : '';
            objQuote.Annual_Price_Escalation_Other__c = objSubscription.Annual_Price_Escalation_Other__c;
            objQuote.Overage_Allowance__c = objSubscription.Overage_Allowance_Other__c != null ? 'Other' : objSubscription.Burst_Allowance__c+'%';
            objQuote.Overage_Allowance_Other__c = objSubscription.Overage_Allowance_Other__c;
            //objNewSubscription.Burst_Allowance__c = objQuote.Overage_Allowance_Other__c != null ? objQuote.Overage_Allowance_Other__c : 20;
            //objNewSubscription.Annual_Price_Increase__c = objQuote.Annual_Price_Escalation_Other__c != null ? objQuote.Annual_Price_Escalation_Other__c : Decimal.valueof(objQuote.Price_Escalation__c.replace('%',''));
            objQuote.Deployment_Model__c = objSubscription.Deployment_Model__c;
        }
        //Anju PC PureSuccess
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
        {
            objQuote.PureSuccess__c = objSubscription.PureSuccess_Offer__c;
            objQuote.PureSuccess_Offer_Subscription_Amount__c = objSubscription.PureSuccess_Dollar_Amount__c;
            objQuote.Token_Value__c = objSubscription.Total_Tokens__c;
            objQuote.Total_GU_Training_Units__c = objSubscription.Total_GU_Training_Units__c;
        }           
        if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
        {
            objQuote.Deal_Registration_Discount__c = objSubscription.Deal_Registration_Discount__c;
        }
        return objQuote;
    }
    
    // *** Method to get removed products from amended quote based on subscription ***
    public static List<Subscription_Product__c> getRemovedProductsFromAmendedQuote(Set<Id> set_ExistingProdIds, Subscription__c objSubscription)
    {  
        List<Subscription_Product__c> list_RemovedProducts = new List<Subscription_Product__c>();
        for(Subscription_Product__c objSubscrProd : objSubscription.Subscription_Products__r) {
            if(!set_ExistingProdIds.contains(objSubscrProd.Product__c)) {
                list_RemovedProducts.add(objSubscrProd);
            }
        }        
        return list_RemovedProducts;
    }
    
    public static Map<String, Service_Token_Definition__c> loadServiceTokenDefinition() {
        Map<String, Service_Token_Definition__c> map_TokDefs = new Map<String, Service_Token_Definition__c>();
        
        for(Service_Token_Definition__c objTD : [SELECT Id, Name, Part_Number__c, Service_Token_Count__c, Service_Token_Expire_Days__c,
                                                 Support_Purchase_Count__c, Support_Purchase_Expire_Days__c, Support_Option__c 
                                                 FROM Service_Token_Definition__c
                                                 WHERE Part_Number__c != null]) {
                                                     map_TokDefs.put(objTD.Part_Number__c, objTD);
                                                 }  
        return map_TokDefs;
    }
    
    // *** Method to create service tokens ***
    public static void createServiceTokens(List<Subscription_Product__c> list_SubscrProds, Map<String, Service_Token_Definition__c> map_TokDefs) {
        Map<Id, List<Service_Token__c>> map_ExistingTokens = new Map<Id, List<Service_Token__c>>();
        Map<Id, List<Support_Purchase__c>> map_ExistingEPS =  new Map<Id, List<Support_Purchase__c>>();
        Map<Id,integer> map_AccountBatch = new Map<Id,integer>();
        List<Service_Token__c> list_NewTokens = new List<Service_Token__c>();
        List<support_purchase__c> list_NewEPS = new List<support_purchase__c>();
        Set<Id> set_AcctIds = new Set<Id>();       
        
        for(Subscription_Product__c objSubscrProd : list_SubscrProds) {
            set_AcctIds.add(objSubscrProd.Subscription__r.Account__c);
        }
        
        for(Support_Purchase__c objEPS : [SELECT Id, Name, Account__c, Effective_Date__c, Description__c 
                                          FROM Support_Purchase__c 
                                          WHERE Account__c IN : set_AcctIds]) {
                                              if(map_ExistingEPS.ContainsKey(objEPS.Account__c)) {
                                                  map_ExistingEPS.get(objEPS.Account__c).add(objEPS);
                                              }
                                              else {
                                                  map_ExistingEPS.put(objEPS.account__c, new List<Support_Purchase__c> {objEPS});
                                              }
                                          }
        for(Service_Token__c objToken : [SELECT Id, Name, Account__c, Batch__c, Effective_Date__c, Description__c, Expiration_Date__c, Quantity__c
                                         FROM Service_Token__c 
                                         WHERE Account__c IN : set_AcctIds
                                         ORDER BY Batch__c]) {
                                             if(map_ExistingTokens.containsKey(objToken.Account__c)) {
                                                 map_ExistingTokens.get(objToken.Account__c).add(objToken);
                                                 if(objToken.Batch__c != null && objToken.Batch__c > map_AccountBatch.get(objToken.Account__c)) {
                                                     map_AccountBatch.put(objToken.Account__c, Integer.valueOf(objToken.Batch__c));
                                                 }
                                             }
                                             else {
                                                 map_ExistingTokens.put(objToken.Account__c, new List<Service_Token__c> {objToken});
                                                 map_AccountBatch.put(objToken.Account__c, objToken.Batch__c != null ? Integer.valueOf(objToken.Batch__c) : 0);
                                             }
                                         }
        for(Subscription_Product__c objSubscrProd : list_SubscrProds) {
            Boolean blnCreateNewEPS = true;
            Boolean blnCreateNewToken = true;
            if(map_TokDefs.containsKey(objSubscrProd.Product__r.APN_Number__c)) {
                Service_Token_Definition__c objTD = map_TokDefs.get(objSubscrProd.Product__r.APN_Number__c);
                if(map_ExistingEPS.containsKey(objSubscrProd.Subscription__r.Account__c)) {
                    for(Support_Purchase__c objSupPrch : map_ExistingEPS.get(objSubscrProd.Subscription__r.Account__c)){
                        if(objSupPrch.Effective_Date__c == objSubscrProd.Subscription__r.Start_Date__c
                           && String.isNotEmpty(objSupPrch.Description__c)
                           && objSupPrch.Description__c.contains(objSubscrProd.Product__r.APN_Number__c)) {
                               blnCreateNewEPS = false;
                           }
                    }
                }
                if(blnCreateNewEPS) {               
                    Support_Purchase__c objNewSupPrch = new Support_Purchase__c();
                    objNewSupPrch.Account__c = objSubscrProd.Subscription__r.Account__c;
                    objNewSupPrch.Order__c = null;
                    objNewSupPrch.Action__c = 'Support Purchase';
                    objNewSupPrch.Quantity__c = Integer.valueOf(objTD.support_Purchase_Count__c) * Integer.valueOf(objSubscrProd.Quantity__c);
                    objNewSupPrch.Description__c = 'Purchased as a part of: ' + objSubscrProd.Product__r.APN_Number__c + ' on subscription: ' + objSubscrProd.Subscription__r.Name;
                    objNewSupPrch.Effective_Date__c = objSubscrProd.Subscription__r.Start_Date__c;
                    objNewSupPrch.Expiration_Date__c = objSubscrProd.Subscription__r.Start_Date__c.addDays(Integer.ValueOf(objTD.Support_Purchase_Expire_Days__c));
                    list_NewEPS.add(objNewSupPrch);
                }   
                if(map_ExistingTokens.ContainsKey(objSubscrProd.Subscription__r.Account__c)) {                   
                    for(Service_Token__c objToken : map_ExistingTokens.get(objSubscrProd.Subscription__r.Account__c)) {
                        if(objToken.Effective_Date__c == objSubscrProd.Subscription__r.Start_Date__c
                           && String.isNotEmpty(objToken.Description__c)
                           && objToken.Description__c.contains(objSubscrProd.Product__r.APN_Number__c)) {
                               blnCreateNewToken = false;
                           }
                    }
                }       
                if(blnCreateNewToken) {
                    Service_Token__c objNewToken = new Service_Token__c();
                    objNewToken.Action__c = 'Token Purchase';
                    objNewToken.Account__c = objSubscrProd.Subscription__r.Account__c;
                    objNewToken.Description__c = 'Purchased as a part of: ' + objSubscrProd.Product__r.APN_Number__c + ' on subscription: ' + objSubscrProd.Subscription__r.Name;
                    objNewToken.Effective_Date__c = objSubscrProd.Subscription__r.Start_Date__c;
                    objNewToken.Expiration_Date__c = objSubscrProd.Subscription__r.Start_Date__c.addDays(Integer.ValueOf(objTD.Service_Token_Expire_Days__c));
                    objNewToken.Quantity__c = Integer.valueOf(objTD.Service_Token_Count__c) * Integer.valueOf(objSubscrProd.Quantity__c);                
                    objNewToken.Batch__c = 1;
                    if(map_AccountBatch.containsKey(objSubscrProd.Subscription__r.Account__c)) {                    
                        objNewToken.Batch__c = map_AccountBatch.get(objSubscrProd.Subscription__r.Account__c) + 1;
                        map_AccountBatch.put(objSubscrProd.Subscription__r.Account__c,  map_AccountBatch.get(objSubscrProd.Subscription__r.Account__c) + 1);
                    }
                    list_NewTokens.add(objNewToken);                
                }
            }
        }
        try {
            System.debug('#####list_NewTokens: '+list_NewTokens); 
            if(list_NewTokens.size() > 0) {
                upsert list_NewTokens;
            }
            System.debug('#####list_NewEPS: '+list_NewEPS); 
            if(list_NewEPS.size() > 0)  {
                insert list_NewEPS;
            }
        }
        catch(Exception e) {
            System.debug('Error Occurred: '+ e.getMessage());
        }
    }
    
    // *** Method to update support options under account ***
    public static void updateAccountSupportOptions(Map<Id, Account> map_Accounts, Map<Id, List<Subscription_Product__c>> map_AcctChrgs) {
        Map<string,integer> map_TokenRank = new Map<String,integer>{'Bronze Support'=>1,'Silver Support'=>2,'Gold Support'=>3,'Platinum Support'=>4};
            Map<string,string> map_PCSupportOptions = new Map<String,String>();
        map_PCSupportOptions.put('PS-170-PURE-SVBRONZE','Bronze Support');
        map_PCSupportOptions.put('PS-170-PURE-SVBRONZEAN','Bronze Support');
        map_PCSupportOptions.put('PS-170-PURE-SUCBRONZE','Bronze Support');
        map_PCSupportOptions.put('PS-170-PURE-SVSILVER','Silver Support');
        map_PCSupportOptions.put('PS-170-PURE-SVSILVERAN','Silver Support');
        map_PCSupportOptions.put('PS-170-PURE-SUCSILVER','Silver Support');
        map_PCSupportOptions.put('PS-170-PURE-GOLD','Gold Support');
        map_PCSupportOptions.put('PS-170-PURE-GOLDAN','Gold Support');
        map_PCSupportOptions.put('PS-170-PURE-SUCGOLD','Gold Support');
        map_PCSupportOptions.put('PS-170-PURE-PLATINUM','Platinum Support');
        map_PCSupportOptions.put('PS-170-PURE-PLATINUMAN','Platinum Support');
        
        for(Account objAcct : map_Accounts.values()) {
            Boolean blnUpdAcct = false;
            if(map_AcctChrgs.containsKey(objAcct.Id)) {
                System.debug('#####objAcct.Support_Option__c: '+objAcct.Support_Option__c); 
                for(Subscription_Product__c objSubscrProd : map_AcctChrgs.get(objAcct.Id)) {
                    String supportType = map_PCSupportOptions.get(objSubscrProd.Product__r.APN_Number__c); 
                    if(String.IsBlank(objAcct.Support_Option__c) 
                       || (map_TokenRank.containsKey(supportType) && map_TokenRank.containsKey(objAcct.Support_Option__c) 
                           && map_TokenRank.get(supportType) > map_TokenRank.get(objAcct.Support_Option__c))) {
                               objAcct.Support_Option__c = supportType;
                           }
                }
            }
        }
        try {  
            System.debug('#####map_Accounts.values: '+map_Accounts.values()); 
            update map_Accounts.values();
        }
        catch(Exception e) {
            System.debug('Error Occurred: '+ e.getMessage());
        }
    }    
    
    // *** Method to set up bill to emails for a subscription ***    
    public static Map<Id, String> setOrderBillToEmailsMap(Set<Id> set_OrderIds) {
        Map<Id, String> map_OrderBillToEmails = new Map<Id, String>();        
        for(Account_Order_Address__c objAOA : [SELECT Address_Type__c, Address__c, Address2__c, City__c, Shipping_Method_Name__c, Order__c,
                                               State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c, Additional_Emails__c
                                               FROM Account_Order_Address__c 
                                               WHERE Order__c IN: set_OrderIds 
                                               AND Address_Type__c = 'Bill To'
                                               ORDER BY Address_Type__c]) {            
        if(String.isNotBlank(objAOA.Email__c)) {
            map_OrderBillToEmails.put(objAOA.Order__c, objAOA.Email__c + ';');
        }
        if(String.isNotBlank(objAOA.Additional_Emails__c)) {
            if(map_OrderBillToEmails.containsKey(objAOA.Order__c)) {
                map_OrderBillToEmails.put(objAOA.Order__c, map_OrderBillToEmails.get(objAOA.Order__c) + objAOA.Additional_Emails__c.replace(',', ';') + ';');
            }
            else {
                map_OrderBillToEmails.put(objAOA.Order__c, objAOA.Additional_Emails__c.replace(',', ';') + ';');
            }
        }        
    }
        return map_OrderBillToEmails;
    }
    
    // *** Method to call from Edit Subscription button ***
    webservice static Id editSubscription(Id subscrId) {
        return cloneSubscriptionAndProducts(subscrId);        
    }
    
    // *** Method to clone a subscription and subscription products ***
    public static Id cloneSubscriptionAndProducts(Id subscrId) {
        List<Subscription_Product__c> list_ToInsertSubscrptionProds = new List<Subscription_Product__c>();
        Subscription__c objSubscription = SubscriptionUtil.getSubscription(subscrId);
        
        Subscription__c objNewSubscription = objSubscription.clone(false, true, false, false);
        objNewSubscription.Status__c = 'Inactive';  
        objNewSubscription.Amendment_For__c = objSubscription.Id;  
        objNewSubscription.Amendment_Date__c = System.today();   
        objNewSubscription.Is_Cloned__c = true;
        if(objSubscription.Original_Subscription__c == null) {
            objNewSubscription.Original_Subscription__c = objSubscription.Id;
        }   
        objNewSubscription.Sync_Status__c = 'Waiting to Sync';
        objNewSubscription.Version__c += 1;         
        objNewSubscription.Auto_Renewed__c = false;
        objNewSubscription.Message__c = '';        
        insert objNewSubscription;
        
        for(Subscription_Product__c objSubscrpProd : objSubscription.Subscription_Products__r) {
            Subscription_Product__c objNewSubscrpProd = objSubscrpProd.clone(false, true, false, false);  
            objNewSubscrpProd.Subscription__c = objNewSubscription.Id;
            objNewSubscrpProd.Amendment_For__c = objSubscrpProd.Id;
            list_ToInsertSubscrptionProds.add(objNewSubscrpProd);
        }        
        insert list_ToInsertSubscrptionProds;
        
        return objNewSubscription.Id;
    }    
    
    // *** Method to post new subscription Ids to PureCloud from button click ***
    //@InvocableMethod
    webservice static void invokeSendSubscriptionIds(List<Subscription__c> list_Subscriptions) {        
        Set<String> set_SubscriptionIds = new Set<String>();                
        List<Subscription__c> list_ToUpdateSubscriptions = new List<Subscription__c>();
        
        for(Subscription__c objSubscr : list_Subscriptions) {
            set_SubscriptionIds.add(objSubscr.Id);
        }
        
        for(Subscription__c objSubscr : [SELECT Id, Status__c, Is_Cloned__c, Amendment_For__c
                                         FROM Subscription__c 
                                         WHERE Id IN :set_SubscriptionIds]) {
                                             if(objSubscr.Is_Cloned__c && objSubscr.Status__c != 'Active') {
                                                 objSubscr.Status__c = 'Active';
                                                 list_ToUpdateSubscriptions.add(objSubscr);                
                                                 if(objSubscr.Amendment_For__c != null) {
                                                     Subscription__c objAmendSubscr = new Subscription__c();
                                                     objAmendSubscr.Id = objSubscr.Amendment_For__c;
                                                     objAmendSubscr.Status__c = 'Amended';
                                                     list_ToUpdateSubscriptions.add(objAmendSubscr);
                                                     //set_SubscriptionIds.add(objAmendSubscr.Id);
                                                 }
                                             }  
                                         }
        System.debug('#####list_ToUpdateSubscriptions: '+list_ToUpdateSubscriptions);
        if(list_ToUpdateSubscriptions.size() > 0) {
            update list_ToUpdateSubscriptions;
        }
        SubscriptionUtil.sendSubscriptionsToPC(set_SubscriptionIds);  
    } 
    @future (callout=true)
    webservice static void sendSubscriptionsToBilling(string subscriptionId,string cloudDeploymentId,string offeringType){
        if(offeringType =='PureConnect Subscription' || offeringType == 'PureConnect Cloud'){
            Subscription__c  objSubscription = [SELECT Id,name, Cloud_Deployment__c, Account_Name__c,
                                                 Account__c,Cloud_Deployment__r.Name 
                                                FROM Subscription__c 
                                                where Id=:subscriptionId LIMIT 1];
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Pure_Cloud_Subscription');
            req.setHeader('Content-Type', 'application/json;');
            req.setBody('{"subscription_id":"'+ objSubscription.Id + '","deployment_id":"'+ objSubscription.Cloud_Deployment__c +'"}'); 
            req.setMethod('POST');
            System.debug('#####req: '+req.getBody());
            Http http = new Http();
            HTTPResponse res = !Test.isRunningTest() ? http.send(req) : new HTTPResponse();
            String strStatus = res.getStatus() == 'OK' ? 'Sent to PureCloud' : 'Failed to Send';
            system.debug('strStatus*********** :'+res);
            if(strStatus == 'Failed to Send'){
                system.debug('Error occured ..send email invoked**');
                //send Email notification
                List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
                //'CaaS-Development@genesys.com',
                //List<String> emails=new List<String>{'vinay.ravula@genesys.com'};
     
                List<String> emails=new List<String>{'CaaS-Development@genesys.com'};
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                mail.setToAddresses(emails);
                mail.setSubject('MyCloud Sync fail occurred for Subscription Record: '+objSubscription.Id );
                string strBody='<font size="4" color="red">MyCloud Sync failure Notification of Subscription Record:</font> '+objSubscription.Id;
                strBody = strBody +'<br></br><br></br>';
                strBody = strBody +'<b>Account Name: </b>'+objSubscription.Account_Name__c+ '<br></br>';
                strBody = strBody +'<b>Account: </b>'+objSubscription.Account__c + '<br></br>';
                strBody = strBody +'<b>Cloud Deployment Name:  </b>'+objSubscription.Cloud_Deployment__r.Name + '<br></br>';
                strBody = strBody +'<b>Cloud Deployment SFDC ID:   </b>'+objSubscription.Cloud_Deployment__c + '<br></br>';
                strBody = strBody +'<b>Offering Type:   </b>'+offeringType ;
                //str
                mail.setHtmlBody(strBody);
                mails.add(mail);
                Messaging.sendEmail(mails);
            }
            PCOrder_Subscription_Logs__c objPClog = new PCOrder_Subscription_Logs__c();
            objPCLog.Name = 'API call made for sendSubscriptionsToBilling- ' + objSubscription.Name;
            objPCLog.Subscription__c = objSubscription.Id;
            objPClog.Message_Type__c = 'Made API call for sendSubscriptionsToBilling ' + objSubscription.Name;
            objPClog.Request_Details__c = 'Subscription ' + objSubscription.Name +  ' send to PureCloud subscription';
            objPClog.Result_Message__c = 'Status code: '+res.getStatusCode() + ';' + res.getBody();
            objPClog.Is_Request_Successful__c = (res.getStatusCode()==200) ? true : false;
            objPClog.Log_Type__c = (res.getStatusCode()==200) ? 'Success' : 'Failure';
            objPClog.Date_Submitted__c = Datetime.now();
            //list_PClogs.add(objPClog);
            if(objPClog !=NULL){
                try{
                    INSERT objPClog;
                }catch(Exception ex){
                    system.debug('Exception in logging*** '+objPClog);
                }
            }
        }
    }
    // *** Method to post new subscription Ids to PureCloud ***
    @future (callout=true)
    public static void sendSubscriptionsToPC(Set<String> set_Subscriptions) {
        List<Subscription__c> list_ToUpdateSubscriptions = new List<Subscription__c>();
        List<PCOrder_Subscription_Logs__c> list_PClogs = new List<PCOrder_Subscription_Logs__c>();   
        
        list_ToUpdateSubscriptions = SubscriptionUtil.getSubscriptionsList(set_Subscriptions);
        System.debug('#####list_ToUpdateSubscriptions : '+list_ToUpdateSubscriptions);
        
        for(Subscription__c objSubscr: list_ToUpdateSubscriptions) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:PureCloud_Endpoint_URL');
            req.setHeader('x-api-key', Label.PureCloud_API_Key);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setBody('{"subscriptionId":"'+ objSubscr.Id + '"}');            
            req.setMethod('POST');
            System.debug('#####req: '+req);
            Http http = new Http();
            HTTPResponse res = !Test.isRunningTest() ? http.send(req) : new HTTPResponse();
            System.debug(res.getBody());            
            String strStatus = res.getStatus() == 'OK' ? 'Sent to PureCloud' : 'Failed to Send';
            
            if(strStatus == 'Failed to Send' && objSubscr.Status__c == 'Active') {
                objSubscr.Status__c =  'Inactive';
            }
            objSubscr.Sync_Status__c = strStatus;
            objSubscr.Message__c = strStatus == 'Failed to Send' ? res.getBody() : 'Success';            
            
            PCOrder_Subscription_Logs__c objPClog = new PCOrder_Subscription_Logs__c();
            objPCLog.Name = 'API call made for subscription- ' + objSubscr.Name;
            objPCLog.Subscription__c = objSubscr.Id;
            objPClog.Message_Type__c = 'Made API call for subscription ' + objSubscr.Name;
            objPClog.Request_Details__c = 'Subscription ' + objSubscr.Name +  ' send to PureCloud';
            objPClog.Result_Message__c = 'Status code: '+res.getStatusCode() + ';' + res.getBody();
            objPClog.Is_Request_Successful__c = (res.getStatusCode()==200) ? true : false;
            objPClog.Log_Type__c = (res.getStatusCode()==200) ? 'Success' : 'Failure';
            objPClog.Date_Submitted__c = Datetime.now();
            list_PClogs.add(objPClog);
        }
        
        if(list_ToUpdateSubscriptions.size() > 0)
            update list_ToUpdateSubscriptions;
        if(list_PClogs.size() > 0)
            insert list_PClogs;
    }    
    
    public static String buildQryForRenewOppAndQuoteFromSubscrs(String strWhereCondition) {
        String strQuery = 'SELECT Id,Name , Account__c,Opportunity__c, Quote__c,Contract_Effective_Date__c, Quote__r.BigMachines__Op' +
            'portunity__c, Order__c, Order__r.Opportunity__c,Contract_Expiration_Date__c, Opportunity_LookUp__c,Total_Ha' +
            'rdware__c,Term_Length_Months__c,Sale_Type__c,Account__r.Name,Contract_Signature_Date__c,Account__r.CSM_Account_Owner__c,CSM__c,Annual_Price_Escalation_Other__c,Annual_Price_Escalation__c,';
        strQuery += ' Offering_Type__c,Original_Subscription__c, Contract_Type__c,Legal_Exceptions__c, Business_Partner__c,Business_Partner__r.Owner.email, Subscription_' +
            'Start_Date__c, Subscription_End_Date__c, Term__c, Billing_Category__c, Billing' +
            '_Period__c,Deal_Registration_Discount__c,Account__r.Ownerid,PureSuccess_Offer__c,PureSuccess_Dollar_Amount__c,Setup_Provisioning_Charges__c,Overage_Allowance_Other__c,Burst_Allowance__c,Business_Partner__r.Country__c,Account__r.Genesys_Care_Ops__c,';
        strQuery += ' Ramp_Period__c, Monthly_Minimum__c, Price_Book_Currency__c, CurrencyISOCode,Product_Tier__c,Total_Tokens__c,Total_GU_Training_Units__c,Pricing_Method__c,Deployment_Model__c,Account__r.Country__c,Account__r.Genesys_Care_specialist__c,' +
            'Payment_Term__c, Start_Date__c,Top_Play__c,Offer__c,Lever__c';
        strQuery += ' FROM Subscription__c ' + strWhereCondition;
        return strQuery;
    }
    
    @future
    public static void updateSubscriptionFlagOnOrder(Set<Id> setOfOrderIds){
        Util.Bypass_Trigger_Chk = true;
        List<Order__c> listOfOrdersToBeUpdated = new List<Order__c>();
        for(Id eachOrderId : setOfOrderIds){
            Order__c objOrder = new Order__c(id = eachOrderId, Generate_Subscription_Record__c = false);
            listOfOrdersToBeUpdated.add(objOrder); 
        }
        if(!listOfOrdersToBeUpdated.isEmpty())
            update listOfOrdersToBeUpdated;
    }    
    
    // *** Method to clone a subscription and subscription products  for Trial Subscriptions***
    webservice static Id cloneSubscriptionAndProductsForTrial(Id subscrId,String OfferingDetail) {
        try{
            List<Subscription_Product__c> list_ToInsertSubscrptionProds = new List<Subscription_Product__c>();
            String strObjName = 'Subscription__c';
            String strWhereCondition = 'Id = :subscrId';
            System.debug(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            List<Subscription__c> list_SourceSubscriptions = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            
            //Subscription__c objSubscription =list_SourceSubscriptions[0];
            
            Subscription__c objNewSubscription = list_SourceSubscriptions[0].clone(false, true, false, false);
            
            objNewSubscription.Subscription_Start_Date__c = objNewSubscription.Subscription_End_Date__c.AddDays(1);
            objNewSubscription.Start_Date__c = objNewSubscription.Subscription_End_Date__c.AddDays(1);
            objNewSubscription.Ramp_End_Date__c = objNewSubscription.Subscription_End_Date__c.AddDays(1);
            objNewSubscription.Ramp_Period__c = 0;
            objNewSubscription.Subscription_End_Date__c = objNewSubscription.Subscription_Start_Date__c.addMonths(1)-1;
            objNewSubscription.Version__c = objNewSubscription.Version__c+1;
            objNewSubscription.Amendment_For__c = list_SourceSubscriptions[0].Id;   
            objNewSubscription.Original_Subscription__c = (objNewSubscription.Version__c == 2)?list_SourceSubscriptions[0].Id: list_SourceSubscriptions[0].Original_Subscription__c;
            objNewSubscription.RecordtypeId = Schema.SObjectType.Subscription__c.getRecordTypeInfosByName().get('Cloud').getRecordTypeId();             
            
            insert objNewSubscription;
            strObjName = 'Subscription_Product__c';
            strWhereCondition = 'Subscription__c = :subscrId';
            List<Subscription_Product__c> list_OriginalSubscriptionProducts = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            for(Subscription_Product__c objSubscrpProd : list_OriginalSubscriptionProducts) {
                Subscription_Product__c objNewSubscrpProd = objSubscrpProd.clone(false, true, false, false);  
                objNewSubscrpProd.Subscription__c = objNewSubscription.Id;
                list_ToInsertSubscrptionProds.add(objNewSubscrpProd);
            }        
            insert list_ToInsertSubscrptionProds;
            return objNewSubscription.Id;
        }
        catch(Exception e) {
            System.debug('Error has occurred:'+e.getMessage()+'\n'+ e.getStackTraceString());
            return null;
        }
    }
    
    //Mukunthan added below method to copy Bill To, Ship To adresses and Activation Email to CCDB reocrd as part of CRMBILL-395
    @future
    public static void copyAccountOrderAddrtoCCDB(map<Id,string> ccdbIDMap){
        list<string> orderIDs = new list<string>();
        //ccdbLst = [select Id,Order__c from Subscription__c where Id IN:ccdbIDLst];
        map<string,string> CCDBToOrder = new map<string,string>();
        for(Subscription__c eachCCDB:[select Id,Order__c from Subscription__c where Id IN:ccdbIDMap.keyset()]){
            if(eachCCDB.Order__c != null){
                CCDBToOrder.put(eachCCDB.Id,eachCCDB.Order__c);
            }
        }
        if(CCDBToOrder.size()>0){
            list<Account_Order_Address__c> aoaLst = new list<Account_Order_Address__c>();
            aoaLst = [select id,name,order__c, address_type__c from Account_Order_Address__c where order__c IN:CCDBToOrder.values()];
            if(aoaLst.size()>0){
                list<string> offeringTpForBillToShipTo = (Global_setting__c.getinstance('CCDB Bill To Ship To Address Type').Information__c).split(';');
                list<string> offeringTpForActEmail = (Global_setting__c.getinstance('CCDB Activation Email Address Type').Information__c).split(';');
                
                for(string CCDBId:CCDBToOrder.keyset()){
                    for(Account_Order_Address__c eachAOA:aoaLst){
                        if(eachAOA.order__c == CCDBToOrder.get(CCDBId)){
                            if(eachAOA.address_type__c != 'Activation Email' && offeringTpForBillToShipTo.contains(ccdbIDMap.get(CCDBId))){
                                eachAOA.CCDB_Subscription__c = CCDBId;
                            }
                            if(eachAOA.address_type__c == 'Activation Email' && offeringTpForActEmail.contains(ccdbIDMap.get(CCDBId))){
                                eachAOA.CCDB_Subscription__c = CCDBId;
                            }
                        }
                    }
                }
                update aoaLst;
            }
        }
    }

    public static void onPremSubscrTotals(BigMachines__Quote__c objQuote, Subscription__c objNewSubscription) {

        Decimal totmnths = getOnPremSubscMonths(objQuote.No_Of_Months__c); 

        Boolean useY1 = decNullTest(objQuote.Annual_Contract_Value_1__c) != 0 ? true : false;
        Decimal qtAcv = useY1 ? decNullTest(objQuote.Annual_Contract_Value_1__c) : decNullTest(objQuote.Annual_Contract_Value_2__c);   
        Decimal qtSeasonal = useY1 ? decNullTest(objQuote.Seasonal_License_Net_Value_Y1__c) : decNullTest(objQuote.Seasonal_License_Net_Value_Y2__c);
        Decimal qtTCV = decNullTest(objQuote.Cloud_Total__c);
            
        Decimal prevAcv = decNullTest(objQuote.Amendment_For__r.ACV__c);
        Decimal prevTCV = decNullTest(objQuote.Amendment_For__r.TCV__c) ;

        Decimal annualQtAcv = (qtAcv/totmnths) * 12;
       // Decimal annualQtTcv = (qtTCV/totmnths) * 12;

        objNewSubscription.ACV__c = annualQtAcv + qtSeasonal + prevAcv;
        objNewSubscription.TCV__c = qtTCV + prevTCV;
    }

    public static void onPremSubscrProdAmounts(BigMachines__Quote_Product__c objQtProd, Subscription_Product__c objNewSubscriptionProd) {
 
        Boolean addedProd = objQtProd.Subscription_Product__r.Quantity__c == null ? true : false;
        Decimal qty = decNullTest(objNewSubscriptionProd.Quantity__c);
        Decimal qtyChange = qty - decNullTest(objQtProd.Subscription_Product__r.Quantity__c);

        Decimal totmnths = getOnPremSubscMonths(objQtProd.BigMachines__Quote__r.No_Of_Months__c); 

        Decimal prtnr = decNullTest(objQtProd.Partner_Price_1__c) != 0 ? objQtProd.Partner_Price_1__c : decNullTest(objQtProd.Partner_Price_2__c);
        Decimal lstprice = decNullTest(objQtProd.List_Price_1__c) != 0 ? objQtProd.List_Price_1__c : decNullTest(objQtProd.List_Price_2__c);
        Decimal netUnit = decNullTest(objQtProd.Net_Unit_Price_1__c) != 0 ? objQtProd.Net_Unit_Price_1__c : decNullTest(objQtProd.Net_Unit_Price_2__c);
       
        Decimal annualPrtnr =  (prtnr/totmnths) * 12;
        Decimal annualLst = (lstprice/totmnths) * 12;
        Decimal annualNetUnit = (netUnit/totmnths) * 12;

        //partner price = 0 means Direct sale
        Boolean isPartner = (prtnr != 0) ? true : false;
        
        //no changes, copy amounts from the subscription prod
        if ( !addedProd && qtyChange == 0 ) {
            objNewSubscriptionProd.Original_List_Price__c = objQtProd.Subscription_Product__r.Original_List_Price__c;
            objNewSubscriptionProd.Partner_Price__c = objQtProd.Subscription_Product__r.Partner_Price__c;
            objNewSubscriptionProd.List_Price__c = objQtProd.Subscription_Product__r.List_Price__c;
        }
        else {
            objNewSubscriptionProd.Partner_Price__c = isPartner ? annualPrtnr : null; 
            objNewSubscriptionProd.List_Price__c = annualLst;
        }
        objNewSubscriptionProd.Net_Unit_Price__c = annualNetUnit;
        objNewSubscriptionProd.Ext_List__c = isPartner ? annualPrtnr * qty : annualLst * qty;

        objNewSubscriptionProd.Ext_Net_Price__c = (annualNetUnit * qtyChange) + decNullTest(objQtProd.Subscription_Product__r.Ext_Net_Price__c);
        objNewSubscriptionProd.Total_Price__c = objNewSubscriptionProd.Ext_Net_Price__c; 
  
        if(objNewSubscriptionProd.Original_List_Price__c == null)
            objNewSubscriptionProd.Original_List_Price__c = objNewSubscriptionProd.List_Price__c;
    }

    public static Decimal decNullTest(Decimal decNum) {
            return (decNum == null ? 0 : decNum); 
    }

    public static Decimal getOnPremSubscMonths(Decimal qtMonths) {
        Decimal retMonths;

        if (qtMonths == null) 
           retMonths = 24;
        else if (qtMonths == 0) 
           retMonths = 1;
        else if ( qtMonths > 12)
           retMonths = qtMonths - 12;
        else
            retMonths = qtMonths;

        return retMonths;
    }
   
    
    
}