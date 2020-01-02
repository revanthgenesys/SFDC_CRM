/************************************************************************************
Purpose : Controller class for the Subscription output PDF page.
Written By :  Naresh Kumar  11/29/2017
Test Classes :  ProposalPDFSubscriptionControllerTest
*************************************************************************************/
//Added fields- Annual Price Increase Other % and Burst Allowance Other % in query of line 189 -INC0419173 
public without sharing class ProposalPDFSubscriptionController {
    //quote 
    public BigMachines__Quote__c quote {get;set;}
    //will hold currency sybmbol
    public String currencySymbol {get;set;}
    //quote products
    public List<wrapperQuoteProducts> quoteProducts {get;set;}
    public List<wrapperQuoteProducts> quoteProductsAlaCarte {get;set;}
    
    public List<wrapperQuoteProducts> quoteProductsSubscriptionLine {get;set;}
    public List<wrapperQuoteProducts> quoteProductsPureSuccessEntitlement {get;set;}
    public List<wrapperQuoteProducts> quoteProductsUpfrontFees {get;set;}
    
    public wrapperQuoteProducts mainTotal {get; private set;}
    //quote products records
    public List<BigMachines__Quote_Product__c> quoteProductRecords {get; set;}
    //quote products records (ECCNs only)
    public List<BigMachines__Quote_Product__c> quoteProductRecordsECCNs {get; set;}
    //Bundle products records
    public List<BigMachines__Quote_Product__c> quoteProductBundlesRecords {get; set;}
    public List<CreateQuoteSubscriptionController.QuoteBurstTerm> list_QuoteBurstTerms {get; set;}
    //Boolean flag to determin whether the quoteProducts list has records or not
    public Boolean showQuoteProduct {get;set;}
    //Boolean flag to determin whether the bundle list has records or not
    public Boolean showBundles {get;set;}
    //Boolean flag which tells is there any PS RDP product
    public Boolean isPSRDPProduct {get;set;}
    //Will contain PSRDP Products
    public Boolean showAdjustment {get;set;}
    public List<BigMachines__Quote_Product__c> quotePSRDPProducts {get; set;}
    public final static String CATEGORY_VIEW = 'Category View';
    public final static String PRODUCT_TYPE_BUNDLE = 'Bundle';
    public final static String GENESYS_CARE = 'Genesys Care';
    public final static String PRODUCT_TYPE_PSRDP = 'PS Service Offering';
    public Integer intTermYears {get; private set;}
    public Integer optionalExtendedTermYears {get; private set;}
    public Double totalAmountDueAtSignature {get; private set;}
    public Double totalContractValue {get; private set;}
    public static Decimal partnerDiscountY1 {get; private set;}
    public static Decimal partnerDiscountY2 {get; private set;}
    public String sellingEntityName {get; private set;}
    public Decimal decHighestDiscount {get; private set;}
    public Decimal decY1AnnualSubscriptionAmount {get; private set;}
    public Decimal decPureSuccessOfferSubscriptionAmount {get; private set;}
    public Decimal decALaCartePureSuccessServiceAmount {get; private set;}
    public Decimal decNonRecurringFee {get; private set;}
    public Decimal decThirdPartyCare {get; private set;}
    public Decimal decAmountDueAtInitialInvoice {get; private set;}
    public Decimal decY2AnnualSubscriptionAmount {get; private set;}
    public Decimal decY1SeasonalLicenseAmount {get; private set;}
    public Decimal decY2SeasonalLicenseAmount {get; private set;}
    public Decimal decAmountDueAtAnniversary {get; private set;}
    public Decimal decTotalCommitment {get; private set;}
    public Decimal decOneTimeCredit {get; private set;}
    public Decimal decCredit {get; private set;}
    public static String strQuoteGeneralPrecisionOutputFormat {get; private set;}
    public Boolean isSmallMediumCenter {get; private set;}
    public Decimal amendTokens {get; private set;}
    public Boolean showDeplPeriod {get; private set;}
    public Boolean oneyear {get; private set;}
    public Boolean secondYrAmend {get; private set;}
    Map<String, Integer> burstTermLength;  
    
    public ProposalPDFSubscriptionController(){
        Map<String, List<wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary = new Map<String, List<wrapperQuoteTotalSummary>>(); 
        quotePSRDPProducts = new List<BigMachines__Quote_Product__c>();
        String quoteId = ApexPages.currentPage().getParameters().get('id');  
        quoteProductsAlaCarte = new List<wrapperQuoteProducts>();
        quoteProductsSubscriptionLine = new List<wrapperQuoteProducts>();
        quoteProductsPureSuccessEntitlement = new List<wrapperQuoteProducts>();
        quoteProductsUpfrontFees = new List<wrapperQuoteProducts>();
        list_QuoteBurstTerms = new List<CreateQuoteSubscriptionController.QuoteBurstTerm>();
        burstTermLength = new Map<String, Integer>();  

        //Querying quote record
        quote = getQuote(quoteId); 
        //MS    
        isSmallMediumCenter = quote.Offering_Feature__c != null && quote.Offering_Feature__c.contains('PureConnect Small Medium') ? true : false;

        //Burst Terms
        initBurstTerms (quoteId);
        
        oneyear = CreateQuoteSubscriptionController.isOneyearQuote(quote); 
        secondYrAmend = (quote.Amendment_For__c == null) ? false : CreateQuoteSubscriptionController.isSecondYrAmend(quote);

        //Querying quote product records
        quoteProductRecords = getQuoteProducts(quoteId, quote.Group_Product_By__c,quote);        
        //To show selling entity on signature block
        if(quote.BigMachines__Opportunity__r.Country_Selling_Entity__c != null)
            sellingEntityName = quote.BigMachines__Opportunity__r.Country_Selling_Entity__c.split(',')[0];
        //Populatting flag to show records
        if(quoteProductRecords.isEmpty()){
            showQuoteProduct = false;
            return;
        }
        else
            showQuoteProduct = true;
        //Populating flag whether to show or hid adjustment
        if(quote.Adjustment__c == null || quote.Adjustment__c == 0)
            showAdjustment = false;
        else
            showAdjustment = true;  
        //getting populated wrapper list
        quoteProducts = getWrapperList(quote, quoteProductRecords, mapTypeVsQuoteTotalSummary, quotePSRDPProducts);    
        //Querying quote products bundles
        if(quotePSRDPProducts.isEmpty())
            isPSRDPProduct = false;
        else
            isPSRDPProduct = true;
        //getting currency symbol
        currencySymbol = getCurrencySymbol(quote.currencyIsoCode);      
        quoteProductRecordsECCNs = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQP : quoteProductRecords){
            if(eachQP.BigMachines__Product__r.Type__c !='Genesys Care' && eachQP.BigMachines__Product__r.Type__c != 'Expense Relief')
                quoteProductRecordsECCNs.add(eachQP);   
        } 
        if(quote.No_Of_Months__c != null)
            intTermYears = Integer.valueOf(quote.No_Of_Months__c / 12);

        if(quote.Optional_extended_term_length_Months__c != null)
            optionalExtendedTermYears = Integer.valueOf(quote.Optional_extended_term_length_Months__c) / 12;
        
        if(quote.One_Time_Charges_1__c == null)
            quote.One_Time_Charges_1__c = 0;
        if(quote.Annual_Contract_Value_2__c == null)
            quote.Annual_Contract_Value_2__c = 0;
        if(quote.One_Time_Charges_1__c == null)
            quote.One_Time_Charges_1__c = 0;
        
        if(quote.Multi_Year_Quote__c){
            List<Partner_Discount__c> listOfPartnerDiscounts = [SELECT Discount__c FROM Partner_Discount__c WHERE
                    Account__c =: quote.Sold_To_Name__c AND Type__c =: quote.Offering_Type__c]; 
            if(!listOfPartnerDiscounts.isEmpty()){
                partnerDiscountY1 = listOfPartnerDiscounts[0].Discount__c;
            if(listOfPartnerDiscounts.size() > 1)
                partnerDiscountY2 = listOfPartnerDiscounts[1].Discount__c;
            }                
        }
        //totalAmountDueAtSignature = quote.Annual_Contract_Value_1__c + quote.One_Time_Charges_1__c;
        //totalContractValue = quote.Annual_Contract_Value_1__c + quote.Annual_Contract_Value_2__c + quote.One_Time_Charges_1__c;
        
        if (quote.Amendment_For__c == null && quote.Ramp_Period__c != null && quote.Ramp_Period__c.isNumeric() && Integer.valueOf(quote.Ramp_Period__c) >= 30)
             showDeplPeriod = true;
        else 
            showDeplPeriod = false;    
        
        if ( quote.Amendment_For__c != null ) {
            populateAmendTotals();
            resetAmendmLists();
        } 

        //Credits
        Decimal recurrCredit = (oneyear || secondYrAmend) ? decNullTest(quote.Total_Recurring_Credit__c) : decNullTest(quote.Total_Recurring_Credit__c) * 2;
        if ( decNullTest(quote.Total_Non_Recurring_Credit__c) > 0 ) // for backward compatibility
            decCredit = decNullTest(quote.Total_Non_Recurring_Credit__c) + recurrCredit;
        else 
            decCredit = decNullTest(quote.Credit_Adjustment__c) + recurrCredit;         
    }
    
    //returns quote record
    public static BigMachines__Quote__c getQuote(String quoteId){
        BigMachines__Quote__c quote = [SELECT Shipping_Handling__c,BigMachines__Status__c,Show_Cover_Page__c, Show_Cover_Letter__c, Group_Product_By__c, Proposal_Language__c, 
            Hide_Decimal_In_Total__c, Hide_Discount__c, Hide_Volume_Discount__c, Hide_Adjustments__c, Hide_Maintenance_Months__c, 
            Hide_Table_of_Contents__c, Hide_End_User__c, Cover_Letter_Text__c, currencyIsoCode, Sold_To_Name__c,
            Sold_To_Name__r.Name, End_User_ID__r.Name, Genesys_Care_Rep_Name__c, Name, Hide_Extended_Net_Price__c, 
            End_User_ID__r.SAP_Account_Code__c,End_User_ID__r.Street1__c, End_User_ID__r.Street2__c, End_User_ID__r.Street3__c,
            End_User_ID__r.City__c, End_User_ID__r.StateProvince__c, End_User_ID__r.Country__r.Name,
            End_User_ID__r.ZipCode__c,Sold_To_Name__r.Street1__c, Sold_To_Name__r.Street2__c, Sold_To_Name__r.Street3__c,
            Sold_To_Name__r.City__c, Sold_To_Name__r.StateProvince__c, Sold_To_Name__r.Country__r.Name,
            Sold_To_Name__r.ZipCode__c,CreatedDate, Expiration_Date__c, Pricing_Model__c, No_Of_Months__c,
            BigMachines__Opportunity__r.Country_Selling_Entity__c, Owner.FirstName, Owner.LastName,
            Owner.Email, Owner.Phone, Order_Numb_of_Maint_Months__c, Hide_Quote_Version__c, Revision_No__c,
            Adjustment__c, Total_Adjustments__c, Proposal_Date__c, Hide_Product_Description__c, Product_Description__c,
            Duration_Unit__c, Order_Numb_of_Maint_Days__c, Contact__r.FirstName,Contact__r.lastName,Contact__r.phone,Contact__r.email,  Hide_List_Price__c,
            Hide_Ext_List_Price__c, Hide_Line_Item_Pricing__c, Executive_Summary__c,Show_Executive_Summary__c,Show_Genesys_Unique_Benefits__c,Genesys_Unique_Benefits__c,
            Show_Impacting_the_lives_of_people__c,Impacting_the_lives_of_everyday_people__c,Show_The_Genesys_Solution__c,
            Genesys_Solution__c,Show_What_You_Want_to_Achieve__c,What_You_Want_to_Achieve__c,Show_Why_Genesys__c,Why_Genesys__c,proposal_title__c,Special_Offer_Terms__c, Is_GU_EMEA__c, Total_Taxes__c,
            Sold_To_Address__c,Sold_To_City__c,Sold_To_state__c,Sold_To_Zip_Code__c,Sold_To_Country__c, Total_Prepaid_Prof_Services__c, CAD_Override__c,Opp_Sold_To_Country__c,
            BigMachines__Opportunity__r.Lines_of_Businesses__c, CMRR__c, Annual_Contract_Value__c, Cloud_Total__c, Do_Not_Group_Output_By_Taxonomy_Category__c,
            Offering_Type__c, Treat_SO_as_PO__c, Hide_Maintenance_Due__c, Hide_Partner_Price__c, Show_MSA_in_Output__c, Hide_Partner_Margin__c,
            BigMachines__Opportunity__r.Account.Partner_Product_Margin__c, BigMachines__Opportunity__r.Account.Partner_GU_Margin__c,
            BigMachines__Opportunity__r.Country__r.PureConnect_Cloud_Selling_Entity__c, MSA_Link__c, Show_Signature_Box__c,
            Sold_To_Name__r.Partner_Product_Margin__c, Sold_To_Name__r.Partner_GU_Margin__c, Cloud_Term_Commitment__c, Subscription_Addendum_Link__c, 
            Overage_Allowance__c, Subscription_Start_Date__c, Optional_extended_term_length_Months__c, One_Time_Charges_1__c, Annual_Contract_Value_1__c, 
            Annual_Contract_Value_2__c, PureSuccess__c, Quote_Business_Type__c, Initial_Subscription_Term__c, Multi_Year_Quote__c,
            Order_Payment_Terms__c, Billing_Period__c, Price_Escalation__c,Annual_Price_Escalation_Other__c,Overage_Allowance_Other__c,PureSuccess_Offer_Subscription_Amount__c, Overage_Price_Premium__c, 
            A_La_Carte_PureSuccess_Services_Amount__c, Total_Contract_Value_1__c, Token_Value__c,Selling_Entity__c,Amount_Due_At_Anniversary__c,
            Show_Genesys_Care_Tab__c, BEP_Third_Party_Genesys_Care__c, End_User_ID__c, Migration_Credit__c, Order_Type__c,
            Amendment_For__r.Quote__r.Highest_Discount__c, Amendment_For__r.Quote__r.Annual_Contract_Value_1__c, Amendment_For__r.Ramp_End_Date__c,
            Amendment_For__r.Subscription_Start_Date__c, Amendment_For__r.Subscription_End_Date__c,
            Amendment_For__r.Quote__r.PureSuccess_Offer_Subscription_Amount__c, Amendment_For__r.Quote__r.A_La_Carte_PureSuccess_Services_Amount__c, 
            Amendment_For__r.Quote__r.One_Time_Charges_1__c, Amendment_For__r.Quote__r.BEP_Third_Party_Genesys_Care__c, 
            Amendment_For__r.Quote__r.Total_Contract_Value_1__c, Amendment_For__r.Quote__r.Annual_Contract_Value_2__c, 
            Amendment_For__r.Quote__r.Amount_Due_At_Anniversary__c, Amendment_For__r.Quote__r.Token_Value__c, Offering_Feature__c,
            Amendment_For__r.Quote__r.Cloud_Total__c, Amendment_For__c, Credit_Adjustment__c,Ramp_Period__c,Pre_Credit_TCV__c,Usage_Data_Submission_Method__c,Total_Recurring_Credit__c,Total_Non_Recurring_Credit__c,
            Seasonal_License_Net_Value_Y1__c,Seasonal_License_Net_Value_Y2__c,Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y1__c,Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y2__c
            FROM  BigMachines__Quote__c WHERE id =: quoteId];
        if(quote.Proposal_Date__c == null)
            quote.Proposal_Date__c = Date.valueOf(quote.CreatedDate);

        if(quote.Hide_Decimal_In_Total__c)
            strQuoteGeneralPrecisionOutputFormat = '###,###';
        else
            strQuoteGeneralPrecisionOutputFormat = '###,##0.00';

        return quote;
    }
    //retuns quote products
    public static List<BigMachines__Quote_Product__c> getQuoteProducts(String quoteId, String groupBy,BigMachines__Quote__c quote){
        List<BigMachines__Quote_Product__c> quoteProductRecords;
        if(groupBy == null || groupBy == CATEGORY_VIEW){
            quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c, Quantity__c,
                    Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                    BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                    Bundle__c, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c, 
                    BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c, Net_Unit_Price__c, Maintenance_Due__c,
                    Partner_Price__c, APN_Number__c, BigMachines__Product__r.APN_Number__c, Name, Bundle__r.Name, Bundle__r.Description__c, Bundle__r.Group_Type__c, BigMachines__Product__r.Third_Party__c,
                    BigMachines__Product__r.Description__c, Partner_Price_1__c, Partner_Price_2__c, Ext_Net_Price_1__c, Ext_Net_Price_2__c,Subscription_Burst_Term__c,
                    Net_Unit_Price_1__c, Net_Unit_Price_2__c, Hardware_or_Third_Party__c, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,Original_Quantity_Amend__c
                    FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId                                 
                    ORDER BY Line_Number__c, Bundle__r.Group_Type__c, BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c];            
        }
        else if(groupBy == 'Use Case View'){
            quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c, Quantity__c,
                Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                Bundle__c, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c, 
                BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c, Net_Unit_Price__c,
                Maintenance_Due__c, Partner_Price__c, APN_Number__c, BigMachines__Product__r.APN_Number__c, Name, Bundle__r.Name, Bundle__r.Description__c, Bundle__r.Group_Type__c,
                BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Description__c, Partner_Price_1__c, Partner_Price_2__c, Subscription_Burst_Term__c,Original_Quantity_Amend__c,
                Ext_Net_Price_1__c, Ext_Net_Price_2__c, Net_Unit_Price_1__c, Net_Unit_Price_2__c, Hardware_or_Third_Party__c, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c
                FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId
                ORDER BY Line_Number__c, Bundle__r.Name, Group_Number__c];    
        }
        else{
            quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c,Quantity__c,
                Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                Bundle__c, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c, 
                BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c, Net_Unit_Price__c,
                Maintenance_Due__c, Partner_Price__c, APN_Number__c, BigMachines__Product__r.APN_Number__c, Name, Bundle__r.Name, Bundle__r.Description__c, Bundle__r.Group_Type__c,
                BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.Description__c, Partner_Price_1__c, Partner_Price_2__c, Subscription_Burst_Term__c,Original_Quantity_Amend__c,
                Ext_Net_Price_1__c, Ext_Net_Price_2__c, Net_Unit_Price_1__c, Net_Unit_Price_2__c, Hardware_or_Third_Party__c, BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c
                FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId
                ORDER BY Line_Number__c, Bundle__r.Group_Type__c, Group_Number__c];
        }      
        return quoteProductRecords;
    }

    @TestVisible
    private static String setOutputFormat(BigMachines__Quote_Product__c objQuoteProduct) {
        System.Debug('setOutputFormat.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c: ' + objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c);
        String strFormat = '###,##0.00';
        if (objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != null && objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '4') {
            strFormat = '###,##0.0000';
        } else if (objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != null && objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '6') {
            strFormat = '###,##0.000000';
        }
        return strFormat;
    }

    private void addPackageToOutput(List<BigMachines__Quote_Product__c> listOfPackage, List<wrapperQuoteProducts> quoteProducts, BigMachines__Quote_Product__c objTotalRecord, Boolean addChildLines){
        for(BigMachines__Quote_Product__c eachQuoteProduct : listOfPackage){              
            //Excluding package line items
            if(!addChildLines && eachQuoteProduct.Bundle_Line__c != null) 
               //|| (eachQuoteProduct.Bundle__c != null && eachQuoteProduct.Bundle__r.Name.equalsIgnoreCase('EQUIP')))
                continue;
            wrapperQuoteProducts newRecord = new wrapperQuoteProducts();
            newRecord.isHeaderRow = false;
            newRecord.record = eachQuoteProduct;
            newRecord.hideNumbers = false;          
            newRecord.rowStyle = '';
            if(quote.Hide_Decimal_In_Total__c)
                newRecord.outputFormat = '###,###';
            else
                newRecord.outputFormat = setOutputFormat(eachQuoteProduct);
            eachQuoteProduct.Net_Unit_Price__c = (eachQuoteProduct.Net_Unit_Price__c == null ? 0 : eachQuoteProduct.Net_Unit_Price__c);
            eachQuoteProduct.Partner_Price__c = (eachQuoteProduct.Partner_Price__c == null ? 0 : eachQuoteProduct.Partner_Price__c);
            eachQuoteProduct.Ext_Net_Price__c = (eachQuoteProduct.Ext_Net_Price__c == null ? 0 : eachQuoteProduct.Ext_Net_Price__c); 
            eachQuoteProduct.Partner_Price_1__c = (eachQuoteProduct.Partner_Price_1__c == null ? 0 : eachQuoteProduct.Partner_Price_1__c); 
            eachQuoteProduct.Partner_Price_2__c = (eachQuoteProduct.Partner_Price_2__c == null ? 0 : eachQuoteProduct.Partner_Price_2__c); 
            eachQuoteProduct.Ext_Net_Price_1__c = (eachQuoteProduct.Ext_Net_Price_1__c == null ? 0 : eachQuoteProduct.Ext_Net_Price_1__c); 
            eachQuoteProduct.Ext_Net_Price_2__c = (eachQuoteProduct.Ext_Net_Price_2__c == null ? 0 : eachQuoteProduct.Ext_Net_Price_2__c); 
            quoteProducts.add(newRecord);
            if(objTotalRecord != null){
                objTotalRecord.Net_Unit_Price__c = (objTotalRecord.Net_Unit_Price__c == null ? 0 : objTotalRecord.Net_Unit_Price__c);
                objTotalRecord.Partner_Price__c = (objTotalRecord.Partner_Price__c == null ? 0 : objTotalRecord.Partner_Price__c);
                objTotalRecord.Ext_Net_Price__c = (objTotalRecord.Ext_Net_Price__c == null ? 0 : objTotalRecord.Ext_Net_Price__c);
                objTotalRecord.Partner_Price_1__c = (objTotalRecord.Partner_Price_1__c == null ? 0 : objTotalRecord.Partner_Price_1__c);
                objTotalRecord.Partner_Price_2__c = (objTotalRecord.Partner_Price_2__c == null ? 0 : objTotalRecord.Partner_Price_2__c);
                objTotalRecord.Ext_Net_Price_1__c = (objTotalRecord.Ext_Net_Price_1__c == null ? 0 : objTotalRecord.Ext_Net_Price_1__c);
                objTotalRecord.Ext_Net_Price_2__c = (objTotalRecord.Ext_Net_Price_2__c == null ? 0 : objTotalRecord.Ext_Net_Price_2__c);
                
                objTotalRecord.Net_Unit_Price__c += eachQuoteProduct.Net_Unit_Price__c;
                objTotalRecord.Partner_Price__c += eachQuoteProduct.Partner_Price__c;
                objTotalRecord.Ext_Net_Price__c += eachQuoteProduct.Ext_Net_Price__c;
                objTotalRecord.Partner_Price_1__c += eachQuoteProduct.Partner_Price_1__c;
                objTotalRecord.Partner_Price_2__c += eachQuoteProduct.Partner_Price_2__c;
                objTotalRecord.Ext_Net_Price_1__c += eachQuoteProduct.Ext_Net_Price_1__c;
                objTotalRecord.Ext_Net_Price_2__c += eachQuoteProduct.Ext_Net_Price_2__c;                
            }
        }
    }
      
    //getting populated wrapperRecords
    private List<wrapperQuoteProducts> getWrapperList(BigMachines__Quote__c quote, List<BigMachines__Quote_Product__c> quoteProductRecords,
        Map<String, List<wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary, List<BigMachines__Quote_Product__c> quotePSRDPProducts){      
        //will contain unique Category/Group
        Set<String> uniqueHeader = new Set<String>();
        Set<String> uniquePackageHeader = new Set<String>();
        //will hold wrapper records to return()
        List<wrapperQuoteProducts> quoteProducts = new List<wrapperQuoteProducts>();
        //will contain total row record
        BigMachines__Quote_Product__c totalRecord = new BigMachines__Quote_Product__c();
        //No of records in a particular group
        Integer recordsInGroup = 0;
        //Getting proposal group map
        Map<String, String> mapProposalGroupNumberVsName = getProporalGroupsMap(quote.id);
        BigMachines__Quote_Product__c objSubscriptionTotal = new BigMachines__Quote_Product__c();
        objSubscriptionTotal.Net_Unit_Price__c = 0;
        objSubscriptionTotal.Partner_Price__c = 0;
        objSubscriptionTotal.Ext_Net_Price__c = 0;
        objSubscriptionTotal.Partner_Price_1__c = 0;
        objSubscriptionTotal.Partner_Price_2__c = 0;
        objSubscriptionTotal.Ext_Net_Price_1__c = 0;
        objSubscriptionTotal.Ext_Net_Price_2__c = 0;
            
        BigMachines__Quote_Product__c objAlaCarteTotal = new BigMachines__Quote_Product__c();
        objAlaCarteTotal.Net_Unit_Price__c = 0;
        objAlaCarteTotal.Partner_Price__c = 0;
        objAlaCarteTotal.Ext_Net_Price__c = 0;   
        objAlaCarteTotal.Partner_Price_1__c = 0;
        objAlaCarteTotal.Partner_Price_2__c = 0;
        objAlaCarteTotal.Ext_Net_Price_1__c = 0;
        objSubscriptionTotal.Ext_Net_Price_2__c = 0;
            
        BigMachines__Quote_Product__c objMainTotal = new BigMachines__Quote_Product__c();
        objMainTotal.Net_Unit_Price__c = 0;
        objMainTotal.Partner_Price__c = 0;
        objMainTotal.Ext_Net_Price__c = 0;   
        objMainTotal.Partner_Price_1__c = 0;
        objMainTotal.Partner_Price_2__c = 0;
        objMainTotal.Ext_Net_Price_1__c = 0;
        objMainTotal.Ext_Net_Price_2__c = 0;
            
        //will hold bundles
        List<wrapperQuoteProducts> bundles = new List<wrapperQuoteProducts>();
        System.debug('NKC debug quoteProductRecords.size() ['+ quoteProductRecords.size() +']');
        List<BigMachines__Quote_Product__c> listOfBasePackages = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> listOfPureSuccessPackages = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> listOfAlaCarteProducts = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> listOfUpfrontFeesProducts = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> listOfRestOfProducts = new List<BigMachines__Quote_Product__c>();

        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductRecords) {  
            if (eachQuoteProduct.Subscription_Burst_Term__c != null && (eachQuoteProduct.Quantity__c == null || eachQuoteProduct.Quantity__c == 0) )
                continue;

             ///MS 9/18/19 in amendments show Quantity change only
            if ( quote.Amendment_For__c != null && eachQuoteProduct.Original_Quantity_Amend__c != null ) {
                 eachQuoteProduct.BigMachines__Quantity__c = eachQuoteProduct.Quantity__c - eachQuoteProduct.Original_Quantity_Amend__c;
            }

            //Bursting
            if ( eachQuoteProduct.Subscription_Burst_Term__c != null ) {             
                for (CreateQuoteSubscriptionController.QuoteBurstTerm btrm : list_QuoteBurstTerms) { 
                    if ( btrm.term.Id == eachQuoteProduct.Subscription_Burst_Term__c && eachQuoteProduct.Bundle_Line__c == null) {
                        btrm.qtprods.add(eachQuoteProduct);
                    }
                }
                continue;
            } 

            if(eachQuoteProduct.Bundle__r.Group_Type__c == 'Base Package')
                listOfBasePackages.add(eachQuoteProduct);
            else if(eachQuoteProduct.Bundle__r.Group_Type__c == 'PureSuccess')
                listOfPureSuccessPackages.add(eachQuoteProduct);    
            else if(eachQuoteProduct.Bundle__r.Group_Type__c == 'A la Carte'){
                listOfAlaCarteProducts.add(eachQuoteProduct);    
            }
            else if(eachQuoteProduct.Hardware_or_Third_Party__c){
                listOfUpfrontFeesProducts.add(eachQuoteProduct);
            }
            else 
                listOfRestOfProducts.add(eachQuoteProduct);
        }
        //TABLE 1
        //Adding Base Package first
        addPackageToOutput(listOfBasePackages, quoteProducts, objSubscriptionTotal, false);
        //Adding A la Carte Items 
        addPackageToOutput(listOfAlaCarteProducts, quoteProductsAlaCarte, objAlaCarteTotal, true);
        
        
        //TABLE 2
        //Adding Base Package first
        addPackageToOutput(listOfBasePackages, quoteProductsSubscriptionLine, null, true);
        //Adding PureSuccess Package 
        addPackageToOutput(listOfPureSuccessPackages, quoteProductsPureSuccessEntitlement, null, true);
            
        //Upfront fees    
        addPackageToOutput(listOfUpfrontFeesProducts, quoteProductsUpfrontFees, null, true);
            
        //Looping over each record and adding to wrapper list
        for(BigMachines__Quote_Product__c eachQuoteProduct : listOfRestOfProducts){  
            if (eachQuoteProduct.Subscription_Burst_Term__c != null && (eachQuoteProduct.Quantity__c == null || eachQuoteProduct.Quantity__c == 0) )
                continue;

            System.debug('NKC debug eachQuoteProduct.BigMachines__Product__r.Type__c ['+eachQuoteProduct.BigMachines__Product__r.Type__c+']');      
            //Populating PS RDP flag
            if(eachQuoteProduct.BigMachines__Product__r.Type__c == PRODUCT_TYPE_PSRDP){
                quotePSRDPProducts.add(eachQuoteProduct);
            }
            String groupName = getUniqueGroupName(quote, eachQuoteProduct, mapProposalGroupNumberVsName);
            String typeName = getTypeName(eachQuoteProduct.BigMachines__Product__r.Type__c);
            String temp = groupName;
            
            System.debug('NKC debug groupName [' + groupName + ']');
            if(!uniqueHeader.contains(temp)){                              
                wrapperQuoteProducts headerRecord = new wrapperQuoteProducts();
                //Summary total record
                wrapperQuoteTotalSummary newSummaryRecord = new wrapperQuoteTotalSummary();
                if(totalRecord.Total_Discount__c != null && totalRecord.Total_Discount__c != 0)
                    totalRecord.Total_Discount__c /= recordsInGroup;
                totalRecord = new BigMachines__Quote_Product__c();
                recordsInGroup = 0;
                headerRecord.isHeaderRow = true;
                headerRecord.headerName = temp;
                
                if(quote.Group_Product_By__c == 'Use Case View')
                    headerRecord.headerDescription = eachQuoteProduct.Bundle__r.Description__c;
                headerRecord.rowStyle = 'font-weight:bold;background-color:#ffffc9;';
                headerRecord.record = totalRecord;
                headerRecord.hideNumbers = false;
                if(quote.Hide_Decimal_In_Total__c){
                    headerRecord.outputFormat = '###,###';
                    newSummaryRecord.outputFormat = '###,###';
                }
                else{
                    headerRecord.outputFormat = setOutputFormat(eachQuoteProduct);
                    newSummaryRecord.outputFormat = setOutputFormat(eachQuoteProduct);
                }
                uniqueHeader.add(temp);
                quoteProducts.add(headerRecord);                
                newSummaryRecord.summaryName = groupName;
                newSummaryRecord.record = totalRecord;      
                 
                System.debug('NKC debug typeName [' + typeName + ']');
                if(mapTypeVsQuoteTotalSummary.containsKey(typeName)){
                    mapTypeVsQuoteTotalSummary.get(typeName).add(newSummaryRecord);
                }
                else{
                    List<wrapperQuoteTotalSummary> newList = new List<wrapperQuoteTotalSummary>();
                    newList.add(newSummaryRecord);
                    mapTypeVsQuoteTotalSummary.put(typeName, newList);
                }
            }
            wrapperQuoteProducts newRecord = new wrapperQuoteProducts();
            newRecord.isHeaderRow = false;
            newRecord.record = eachQuoteProduct;
            newRecord.hideNumbers = false;          
            newRecord.rowStyle = '';
            if(quote.Hide_Decimal_In_Total__c)
                newRecord.outputFormat = '###,###';
            else
                newRecord.outputFormat = setOutputFormat(eachQuoteProduct);

            ///MS 9/18/19 in amendments show Quantity change only
            if ( quote.Amendment_For__c != null && eachQuoteProduct.Original_Quantity_Amend__c != null ) {
                 eachQuoteProduct.BigMachines__Quantity__c = eachQuoteProduct.Quantity__c - eachQuoteProduct.Original_Quantity_Amend__c;
            }

            eachQuoteProduct.Ext_List__c = (eachQuoteProduct.Ext_List__c == null ? 0 : eachQuoteProduct.Ext_List__c);
            eachQuoteProduct.Ext_Net_Price__c = (eachQuoteProduct.Ext_Net_Price__c == null ? 0 : eachQuoteProduct.Ext_Net_Price__c);            
            eachQuoteProduct.Partner_Price_1__c = (eachQuoteProduct.Partner_Price_1__c == null ? 0 : eachQuoteProduct.Partner_Price_1__c);            
            eachQuoteProduct.Partner_Price_2__c = (eachQuoteProduct.Partner_Price_2__c == null ? 0 : eachQuoteProduct.Partner_Price_2__c);            
            eachQuoteProduct.Ext_Net_Price_1__c = (eachQuoteProduct.Ext_Net_Price_1__c == null ? 0 : eachQuoteProduct.Ext_Net_Price_1__c);            
            eachQuoteProduct.Ext_Net_Price_2__c = (eachQuoteProduct.Ext_Net_Price_2__c == null ? 0 : eachQuoteProduct.Ext_Net_Price_2__c);            
 
            //eachQuoteProduct.Accepted_Volume_Discount__c = (eachQuoteProduct.Accepted_Volume_Discount__c == null ? 0 : eachQuoteProduct.Accepted_Volume_Discount__c);
            eachQuoteProduct.Total_Discount__c = (eachQuoteProduct.Total_Discount__c == null ? 0 : eachQuoteProduct.Total_Discount__c);
            eachQuoteProduct.List_Price__c = (eachQuoteProduct.List_Price__c == null ? 0 : eachQuoteProduct.List_Price__c);
            //Updating total
            //totalRecord = updateTotal(totalRecord, eachQuoteProduct);
            objSubscriptionTotal = updateTotal(objSubscriptionTotal, eachQuoteProduct);
            recordsInGroup ++;
            quoteProducts.add(newRecord);  
            quoteProductsSubscriptionLine.add(newRecord);
        }        
        if(recordsInGroup > 0 && totalRecord.Total_Discount__c != null && totalRecord.Total_Discount__c != 0)
            totalRecord.Total_Discount__c /= recordsInGroup;
           
        //Total Record
        wrapperQuoteProducts newRecord = new wrapperQuoteProducts();
        newRecord.headerName = 'Total Subscription';
        newRecord.isHeaderRow = false;
        newRecord.record = objSubscriptionTotal;
        newRecord.hideNumbers = false;          
        newRecord.rowStyle = 'font-weight:bold;';
        if(quote.Hide_Decimal_In_Total__c)
            newRecord.outputFormat = '###,###';
        else
            newRecord.outputFormat = '###,##0.00';          
        quoteProducts.add(newRecord);
            
        //A la Carte total record
        newRecord = new wrapperQuoteProducts();
        newRecord.headerName = 'Total';
        newRecord.isHeaderRow = false;
        newRecord.record = objAlaCarteTotal;
        newRecord.hideNumbers = false;          
        newRecord.rowStyle = 'font-weight:bold;';
        if(quote.Hide_Decimal_In_Total__c)
            newRecord.outputFormat = '###,###';
        else
            newRecord.outputFormat = '###,##0.00'; 
        quoteProductsAlaCarte.add(newRecord);        
            
        objMainTotal = updateTotal(objMainTotal, objSubscriptionTotal);   
        objMainTotal = updateTotal(objMainTotal, objAlaCarteTotal);   
        mainTotal = new wrapperQuoteProducts();
        mainTotal.isHeaderRow = false;
        mainTotal.hideNumbers = false; 
        mainTotal.record = objMainTotal;
        mainTotal.rowStyle = 'font-weight:bold;';
        if(quote.Hide_Decimal_In_Total__c)
            mainTotal.outputFormat = '###,###';
        else
            mainTotal.outputFormat = '###,##0.00'; 
        
        //TABLE 2
        //Adding A la Carte Items 
        addPackageToOutput(listOfAlaCarteProducts, quoteProductsPureSuccessEntitlement, null, true);
        quoteProductsSubscriptionLine = addGroupingToSubscriptionLine(quoteProductsSubscriptionLine);
        quoteProductsPureSuccessEntitlement = addGroupingToSubscriptionLine(quoteProductsPureSuccessEntitlement);
        return quoteProducts;
    }
    
    private List<wrapperQuoteProducts> addGroupingToSubscriptionLine(List<wrapperQuoteProducts> listOfSubscriptionLine){
        List<wrapperQuoteProducts> listOfSubscriptionLine1 = new List<wrapperQuoteProducts>();
        Set<String> setOfBundles = new Set<String>();
        for(wrapperQuoteProducts eachRecord : listOfSubscriptionLine){            
            System.debug('NKC debug eachRecord.record.Bundle__r.Group_Type__c [' + eachRecord.record.Bundle__r.Group_Type__c + ']');
            if(eachRecord.record.Bundle__c != null && (eachRecord.record.Bundle__r.Name == 'PureEngage Base Package' || eachRecord.record.Bundle__r.Name.equalsIgnoreCase('EQUIP')
               || eachRecord.record.Bundle__r.Name.equalsIgnoreCase('DRIVE') || eachRecord.record.Bundle__r.Name.equalsIgnoreCase('GUIDE')) 
               && eachRecord.record.Bundle_Line__c == null){
                continue;
            }
                
            String bundleName = eachRecord.record.Bundle__r.Name;
            if(bundleName == null)
                bundleName = 'Individual Items';
            if(!setOfBundles.contains(bundleName)){
                wrapperQuoteProducts newHeader = new wrapperQuoteProducts();
                newHeader.headerName = bundleName;
                newHeader.headerDescription = eachRecord.record.Bundle__r.Description__c;
                newHeader.rowStyle = 'font-weight:bold;background-color:#c2d8f9;';                
                listOfSubscriptionLine1.add(newHeader);
                setOfBundles.add(bundleName);
            }
            listOfSubscriptionLine1.add(eachRecord);
        }
        return listOfSubscriptionLine1;
    }
    
    private BigMachines__Quote_Product__c updateTotal(BigMachines__Quote_Product__c totalRecord, BigMachines__Quote_Product__c eachQuoteProduct){
        //List Price            
        
        if(totalRecord.Ext_List__c == null)
            totalRecord.Ext_List__c = eachQuoteProduct.Ext_List__c;
        else
            totalRecord.Ext_List__c += (eachQuoteProduct.Ext_List__c == null ? 0 : eachQuoteProduct.Ext_List__c);
        
        //Partner Price 1           
        if(totalRecord.Partner_Price_1__c == null)
            totalRecord.Partner_Price_1__c = eachQuoteProduct.Partner_Price_1__c;
        else
            totalRecord.Partner_Price_1__c += (eachQuoteProduct.Partner_Price_1__c == null ? 0 : eachQuoteProduct.Partner_Price_1__c);
        //Partner Price 2          
        if(totalRecord.Partner_Price_2__c == null)
            totalRecord.Partner_Price_2__c = eachQuoteProduct.Partner_Price_2__c;
        else
            totalRecord.Partner_Price_2__c += (eachQuoteProduct.Partner_Price_2__c == null ? 0 : eachQuoteProduct.Partner_Price_2__c);
        //Extended Price 1           
        if(totalRecord.Ext_Net_Price_1__c == null)
            totalRecord.Ext_Net_Price_1__c = eachQuoteProduct.Ext_Net_Price_1__c;
        else
            totalRecord.Ext_Net_Price_1__c += (eachQuoteProduct.Ext_Net_Price_1__c == null ? 0 : eachQuoteProduct.Ext_Net_Price_1__c);
        //Extended Price 2           
        if(totalRecord.Ext_Net_Price_2__c == null)
            totalRecord.Ext_Net_Price_2__c = eachQuoteProduct.Ext_Net_Price_2__c;
        else
            totalRecord.Ext_Net_Price_2__c += (eachQuoteProduct.Ext_Net_Price_2__c == null ? 0 : eachQuoteProduct.Ext_Net_Price_2__c);
        
        //Extended Price            
        if(totalRecord.Ext_Net_Price__c == null)
            totalRecord.Ext_Net_Price__c = eachQuoteProduct.Ext_Net_Price__c;
        else
            totalRecord.Ext_Net_Price__c += (eachQuoteProduct.Ext_Net_Price__c == null ? 0 : eachQuoteProduct.Ext_Net_Price__c);
        
        //Volume Discount          
        if(totalRecord.Accepted_Volume_Discount__c == null)
            totalRecord.Accepted_Volume_Discount__c = eachQuoteProduct.Accepted_Volume_Discount__c;
        else
            totalRecord.Accepted_Volume_Discount__c += (eachQuoteProduct.Accepted_Volume_Discount__c == null ? 0 : eachQuoteProduct.Accepted_Volume_Discount__c);
        //Discount          
        if(totalRecord.Total_Discount__c == null)
            totalRecord.Total_Discount__c = eachQuoteProduct.Total_Discount__c;
        else
            totalRecord.Total_Discount__c += (eachQuoteProduct.Total_Discount__c == null ? 0 : eachQuoteProduct.Total_Discount__c);
        //List Price            
        if(totalRecord.List_Price__c == null)
            totalRecord.List_Price__c = eachQuoteProduct.List_Price__c;
        else
            totalRecord.List_Price__c += (eachQuoteProduct.List_Price__c == null ? 0 : eachQuoteProduct.List_Price__c);        
        
        //Net Unit Price            
        if(totalRecord.Net_Unit_Price__c == null)
            totalRecord.Net_Unit_Price__c = eachQuoteProduct.Net_Unit_Price__c;
        else
            totalRecord.Net_Unit_Price__c += (eachQuoteProduct.Net_Unit_Price__c == null ? 0 : eachQuoteProduct.Net_Unit_Price__c);
        
        
        return totalRecord;
    }
    
    
    //Getting groupname
    @TestVisible
    private String getUniqueGroupName(BigMachines__Quote__c quote, BigMachines__Quote_Product__c quoteQuoteProduct, Map<String, String> mapProposalGroupNumberVsName){
        String groupName;
        if(quote.Group_Product_By__c == null || quote.Group_Product_By__c == 'Category View'){
            if(quote.Do_Not_Group_Output_By_Taxonomy_Category__c || quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution_Category__c == null 
                || quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution__c == null){
                if(quoteQuoteProduct.BigMachines__Product__r.New_Category__c == null)
                    groupName = 'No Category Defined';
                else
                    groupName = quoteQuoteProduct.BigMachines__Product__r.New_Category__c;
            }
            else{
                if(quote.Offering_Type__c == 'PureConnect On Premise')
                    groupName = quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution__c;  
                else
                    groupName = quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution_Category__c + ' - ' + quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution__c; 
            }
        }
        else if(quote.Group_Product_By__c == 'Use Case View'){
            groupName = quoteQuoteProduct.Bundle__r.Name;
        }
        else{
            if(quoteQuoteProduct.Group_Number__c == null)
                groupName = 'No Group Defined';
            else
                groupName = mapProposalGroupNumberVsName.get(quoteQuoteProduct.Group_Number__c);                
        }   
        return groupName;
    }
    //Populates application type name
    @TestVisible
    private String getTypeName(String typeName){
        if(typeName == 'Product')
            return 'Software';
        if(typeName == 'Product - Hardware')
            return 'Hardware';
        if(typeName == 'PS' || typeName == 'PS-Contract')
            return 'Professional Services';
        if(typeName == 'GU')
            return 'Education';
        return typeName;        
    }
    //Get currency symbol
    public String getCurrencySymbol(String currencyISOCode){
        if(currencyIsoCode == 'USD' || currencyIsoCode == 'AUD')
            return '$';
        else if(currencyIsoCode == 'GBP')
            return '£';
        else if(currencyISOCode == 'BRL')
            return 'R$';         
        else if(currencyISOCode == 'EUR')
            return '€';         
        else if(currencyISOCode == 'JPY')
            return '¥';         
            
        return '';
    }
    //Getting propoal group map
    @TestVisible
    private Map<String, String> getProporalGroupsMap(Id quoteId){
        Map<String, String> mapProposalGroupNumberVsName = new Map<String, String> ();
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
            }
            mapProposalGroupNumberVsName.put(eachQPG.Group_Number__c, eachQPG.Name__c + ' ('+ description +')');
        }
        return mapProposalGroupNumberVsName;
    }
    
    private void populateAmendTotals(){
       if(quote.Amendment_For__c != null){
            //decHighestDiscount = quote.Highest_Discount__c + quote.Amendment_For__r.Quote__r.Highest_Discount__c;                 
            decY1AnnualSubscriptionAmount = (quote.Annual_Contract_Value_1__c == null ? 0 : quote.Annual_Contract_Value_1__c) + (quote.Amendment_For__r.Quote__r.Annual_Contract_Value_1__c == null ? 0 : quote.Amendment_For__r.Quote__r.Annual_Contract_Value_1__c);
            decPureSuccessOfferSubscriptionAmount = (quote.PureSuccess_Offer_Subscription_Amount__c == null ? 0 : quote.PureSuccess_Offer_Subscription_Amount__c) + (quote.Amendment_For__r.Quote__r.PureSuccess_Offer_Subscription_Amount__c == null ? 0 : quote.Amendment_For__r.Quote__r.PureSuccess_Offer_Subscription_Amount__c);
            decALaCartePureSuccessServiceAmount = (quote.A_La_Carte_PureSuccess_Services_Amount__c == null ? 0 : quote.A_La_Carte_PureSuccess_Services_Amount__c) + (quote.Amendment_For__r.Quote__r.A_La_Carte_PureSuccess_Services_Amount__c == null ? 0 : quote.Amendment_For__r.Quote__r.A_La_Carte_PureSuccess_Services_Amount__c);
            decNonRecurringFee = (quote.One_Time_Charges_1__c == null ? 0 : quote.One_Time_Charges_1__c) + (quote.Amendment_For__r.Quote__r.One_Time_Charges_1__c == null ? 0 : quote.Amendment_For__r.Quote__r.One_Time_Charges_1__c);
            decThirdPartyCare = (quote.BEP_Third_Party_Genesys_Care__c == null ? 0 : quote.BEP_Third_Party_Genesys_Care__c) + (quote.Amendment_For__r.Quote__r.BEP_Third_Party_Genesys_Care__c == null ? 0 : quote.Amendment_For__r.Quote__r.BEP_Third_Party_Genesys_Care__c);
            decAmountDueAtInitialInvoice = (quote.Total_Contract_Value_1__c == null ? 0 : quote.Total_Contract_Value_1__c) + (quote.Amendment_For__r.Quote__r.Total_Contract_Value_1__c == null ? 0 : quote.Amendment_For__r.Quote__r.Total_Contract_Value_1__c);
            decY2AnnualSubscriptionAmount = (quote.Annual_Contract_Value_2__c == null ? 0 : quote.Annual_Contract_Value_2__c) + (quote.Amendment_For__r.Quote__r.Annual_Contract_Value_2__c == null ? 0 : quote.Amendment_For__r.Quote__r.Annual_Contract_Value_2__c);
            decAmountDueAtAnniversary = (quote.Amount_Due_At_Anniversary__c == null ? 0 : quote.Amount_Due_At_Anniversary__c) + (quote.Amendment_For__r.Quote__r.Amount_Due_At_Anniversary__c == null ? 0 : quote.Amendment_For__r.Quote__r.Amount_Due_At_Anniversary__c);
          
            decTotalCommitment = decNullTest(quote.Cloud_Total__c) + decNullTest(quote.Amendment_For__r.Quote__r.Cloud_Total__c);                             

            amendTokens = (quote.Amendment_For__r.Quote__r.Token_Value__c != null && quote.Token_Value__c != null ) ? quote.Token_Value__c - quote.Amendment_For__r.Quote__r.Token_Value__c : quote.Token_Value__c;
        
            decY1SeasonalLicenseAmount = decNullTest(quote.Seasonal_License_Net_Value_Y1__c) + decNullTest(quote.Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y1__c);

            decY2SeasonalLicenseAmount = decNullTest(quote.Seasonal_License_Net_Value_Y2__c) + decNullTest(quote.Amendment_For__r.Quote__r.Seasonal_License_Net_Value_Y2__c);

        
        }
    }

    public List<wrapperQuoteProducts> removeUnchangeProds(List<wrapperQuoteProducts> listToClean) {
       Map<Integer, wrapperQuoteProducts> tempProds = new Map<Integer, wrapperQuoteProducts>();  
       Integer n=1;   
       for ( wrapperQuoteProducts prd : listToClean ) {          
           if (prd.record == null || prd.record.Ext_Net_Price_1__c != 0)
              tempProds.put(n++, prd);
       }
       //remove headers
       Boolean isPrevHeader = false;
       for ( Integer i : tempProds.keySet() ) {
           if ( isPrevHeader && tempProds.get(i).isHeaderRow ) 
               tempProds.remove(i-1);

            isPrevHeader = tempProds.get(i).isHeaderRow == null ? false : tempProds.get(i).isHeaderRow;
       }

       return (!tempProds.isEmpty() ) ? tempProds.values() : new List<wrapperQuoteProducts>();
    }

    public void initBurstTerms (String quoteId) {
        //Burst - add terms, initialize products list
        List<Subscription_Burst_Term__c> terms = SubscriptionBurstTerm.getQuoteBurstTerms(quoteId);
        for (Subscription_Burst_Term__c trm : terms) {
            CreateQuoteSubscriptionController.QuoteBurstTerm qtrm = new CreateQuoteSubscriptionController.QuoteBurstTerm();
            qtrm.term = trm;
            qtrm.qtprods = new List<BigMachines__Quote_Product__c>(); 
            list_QuoteBurstTerms.add(qtrm); 
        }
    }

    //MS pre seasonal terms release quote display
    public Boolean getShowBurstFields() {
        Boolean ret = false;
        if ( quote.Usage_Data_Submission_Method__c != null && 
             (quote.Usage_Data_Submission_Method__c == 'Automated' || quote.Usage_Data_Submission_Method__c == 'Manual') ) 
                ret = true;
    
        return ret;
    }

    public void resetAmendmLists() {
         //quoteProducts
         List<wrapperQuoteProducts> prds = removeUnchangeProds(quoteProducts);
         quoteProducts.clear();
         quoteProducts = prds;
         
         ////quoteProductsAlaCarte
         List<wrapperQuoteProducts> alc = removeUnchangeProds(quoteProductsAlaCarte);
         quoteProductsAlaCarte.clear();
         quoteProductsAlaCarte = alc;

         ///quoteProductsUpfrontFees
         List<wrapperQuoteProducts> fees = removeUnchangeProds(quoteProductsUpfrontFees);
         quoteProductsUpfrontFees.clear();
         quoteProductsUpfrontFees = fees;  
    }
    
    public class wrapperQuoteProducts{
        public BigMachines__Quote_Product__c record {get;set;}
        public String packageType {get; private set;}
        public String headerName {get;set;}
        public String headerDescription {get;set;} 
        public Boolean isHeaderRow {get;set;}
        public String rowStyle {get;set;} 
        public String outputFormat {get;set;}
        public Boolean hideNumbers {get;set;}
    }
    public class wrapperQuoteTotalSummary{
        public String summaryName {get;set;}
        public String categoryOrBundleName {get;set;}       
        public BigMachines__Quote_Product__c record {get;set;}
        public String outputFormat {get;set;}
        public String rowStyle {get;set;}       
    }

    public Decimal decNullTest(Decimal decNum) {
        return (decNum == null ? 0 : decNum); 
    }
}