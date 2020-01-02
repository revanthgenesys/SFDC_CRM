//Naresh Kumar  12/02/2014
public without sharing class DealQualificationAndQuoteApprovalHelper {
    public final static string OK = 'OK';
    
    public final static string ERROR = 'There are some approval violations.';
    
    //Mukunth added below variable for DDS Mega Deal
    private static boolean isMegaDealbln = false;
    
    public static List<wrapperViolationSummary> validateQuoteApproval(String quoteId){
        //
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        //Getting quote
        BigMachines__Quote__c quote = QuoteApprovalUtil.getQuote(quoteId);
        //Deal Qualification    
        //List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, quote.Quote_Opportunity_Type__c);
        //Deal_Qualification__c dq;
        //if(!dqs.isEmpty())
        //  dq = dqs[0];
        
        List<Deal_Qualification__c> dqHistory = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, 
                                                                                    quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_HISTORY);
        
        if(dqHistory.isEmpty()){
            Deal_Qualification__c newHistory = new Deal_Qualification__c();
            dqHistory.add(newHistory);    
        }      
        violations = checkApprovals(quote, dqHistory[0], false);
        System.debug('NKC debug violations ['+violations+']');
        return violations;        
    }
    
    public static List<wrapperViolationSummary> checkApprovals(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){
        List<wrapperViolationSummary> violations;
        if(quote.Offering_Type__c == 'Business Edition')
            violations = checkApprovalsForCloudBE(quote, dq, isValidation);    
        else if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CAAS)
            violations = checkApprovalsForCaaS(quote, dq, isValidation);   
        else if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_PC)
            violations = checkApprovalsForPC(quote, dq, isValidation); 
        else if(quote.Offering_Type__c == 'PureEngage Cloud')
            violations = checkApprovalsForPEC(quote, dq, isValidation); 
        else if(quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription')    
            violations = checkApprovalsForSubscription(quote, dq, isValidation);
        else
            violations = checkApprovalsForOnPremiseQuote(quote, dq, isValidation);
        return violations;
    }
    
    public static List<wrapperViolationSummary> checkApprovalsForSubscription(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){    
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        /*
//Base Package Discount
if(quote.Base_Agent_Discount__c != null ){
Decimal discountOnQuote = quote.Base_Agent_Discount__c.setScale(2, RoundingMode.HALF_UP);
Decimal discountSizeDQ1 = DealQualificationApprovalUtil.getDiscountSize(dq.Discount_Base_Package__c);            
Decimal discountOnDQ = discountSizeDQ1.setScale(2, RoundingMode.HALF_UP);
if(discountOnQuote >= 30 && discountOnQuote > discountOnDQ){              
violations.add(new wrapperViolationSummary('Base Package Discount', String.valueOf(discountOnQuote.setScale(2, RoundingMode.HALF_UP)), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >= 30% discount requires approval.' ));
if(isValidation)
return violations;
}        
} 
*/
        //Non Base Package Discount
        if(quote.Discount__c != null && quote.Amendment_For__c != null){
            Decimal discountOnQuote = quote.Highest_Discount__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountSizeDQ1 = DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c);            
            Decimal discountOnDQ = discountSizeDQ1.setScale(2, RoundingMode.HALF_UP);
            if(discountOnQuote >= 30 && discountOnQuote > discountOnDQ){              
                violations.add(new wrapperViolationSummary('Discount', String.valueOf(discountOnQuote.setScale(2, RoundingMode.HALF_UP)), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >= 30% discount requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        } 
        
        //Annual Price Escalator
        if(quote.Price_Escalation__c != null && quote.Price_Escalation__c == 'Other' && (dq.Price_Escalation__c == null || dq.Price_Escalation__c != 'Other')){
            violations.add(new wrapperViolationSummary('Annual Price Escalation – Other', quote.Price_Escalation__c, dq.Price_Escalation__c == null ? 'Not Approved' : dq.Price_Escalation__c, ' \'Other\' requires approval.' ));
            if(isValidation)
                return violations;    
        }
        
        //Overage Allowance
        if(quote.Overage_Allowance__c != null && quote.Overage_Allowance__c == 'Other' && (dq.Overage_Allowance__c == null || dq.Overage_Allowance__c != 'Other')){
            violations.add(new wrapperViolationSummary('Burst Allowance – Other', quote.Overage_Allowance__c, dq.Overage_Allowance__c == null ? 'Not Approved' : dq.Overage_Allowance__c, ' \'Other\' requires approval.' ));
            if(isValidation)
                return violations;    
        }
        
        //Payment Terms
        if(quote.Order_Payment_Terms__c != null){
            Integer quotePaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Integer dqPaymentTerm = 0;
            if(dq.Payment_Terms__c != null)
                dqPaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            if(quotePaymentTerm >= 45 && quotePaymentTerm > dqPaymentTerm ){
                violations.add(new wrapperViolationSummary('Payment Term', quote.Order_Payment_Terms__c, dq.Payment_Terms__c == null ? 'Not Approved' : dq.Payment_Terms__c, ' >= Net 45 requires approval.' ));
                if(isValidation)
                    return violations;    
            }
        }
        
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            String description = 'Special offer requires approval. ';
            if(dq.Special_Offers_Business_Exceptions__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                description += 'There is difference in offer term.';
            violations.add(new wrapperViolationSummary('Special Offer Terms', getBooleanToStringValue(quote.Include_Special_Offer_in_Output__c), getBooleanToStringValue(dq.Special_Offer_Terms__c), description ));
            if(isValidation)
                return violations; 
        }
        
        //Usage Data Submission Method
        if((quote.Usage_Data_Submission_Method__c == 'Manual' || quote.Usage_Data_Submission_Method__c == 'No Bursting') 
           && dq.Usage_Data_Submission_Method__c != 'Manual' && dq.Usage_Data_Submission_Method__c != 'No Bursting'){
               violations.add(new wrapperViolationSummary('Usage Data Submission Method', quote.Usage_Data_Submission_Method__c, dq.Usage_Data_Submission_Method__c == null ? 'Not Approved' : dq.Overage_Allowance__c, ' \'Manual/No Bursting\' requires approval.' ));
               if(isValidation)
                   return violations;    
           }
        
        //Deal Score
        showDealScoreViolation(quote, dq, violations);

        //Seasonal Licensing (Bursting)
        if( ((quote.Seasonal_License_Net_Value_Y1__c != null && quote.Seasonal_License_Net_Value_Y1__c > 0)
             && (dq.Seasonal_License_Net_Value_Y1__c == null || dq.Seasonal_License_Net_Value_Y1__c == 0))    || 
             ((quote.Seasonal_License_Net_Value_Y2__c != null && quote.Seasonal_License_Net_Value_Y2__c > 0)
             && (dq.Seasonal_License_Net_Value_Y2__c == null || dq.Seasonal_License_Net_Value_Y2__c == 0)) || 
               (quote.Overage_Discount__c == 100 && dq.Overage_Discount__c != 100) )  {

            violations.add(new wrapperViolationSummary('Seasonal Licensing', 'Yes', 'Not Approved', ' Requires approval' ));
            if(isValidation)
                return violations;    
        }
        //Credits 
         if( ((quote.Total_Recurring_Credit__c != null && quote.Total_Recurring_Credit__c > 0)
             && (dq.Total_Recurring_Credit__c == null || dq.Total_Recurring_Credit__c == 0))    || 
             ((quote.Total_Non_Recurring_Credit__c != null && quote.Total_Non_Recurring_Credit__c > 0)
             && (dq.Total_Non_Recurring_Credit__c == null || dq.Total_Non_Recurring_Credit__c == 0)) )  {

            violations.add(new wrapperViolationSummary('Credit Applied', 'Yes', 'Not Approved', ' Requires approval' ));
            if(isValidation)
                return violations;    
        }
        
        return violations;        
    }
    
    public static List<wrapperViolationSummary> checkApprovalsForCloudBE(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){    
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        List<Deal_Qualification_Products__c> dqProducts = DealQualificationApprovalUtil.getDQProducts(dq.id);        
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
        Double decAcvDQ = 0;
        if(dq.Net_Deal_Size_Amount__c != null){
            decAcvDQ = dq.Net_Deal_Size_Amount__c;
            //decAcvDQ = DealQualificationApprovalUtil.convertCurrency(decAcvDQ, quote.CurrencyIsoCode);
        }
        //Cloud Deal
        Decimal decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,'null',quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        if((dq.id == null && decUSDACV <= 600000) || (dq.id != null && (decAcvDQ > decUSDACV || dq.Net_Deal_Size_Amount__c == null) && decUSDACV <= 600000)){
            violations.add(new wrapperViolationSummary('PureEngage Cloud Deal', 'ACV <= USD 600,000', 'Not Approved',  'ACV does not meet required minimum.' ));
            if(isValidation)
                return violations;
        }
        
        //Discount
        /*Anju Commenting for DDS
if(quote.Total_Discount_Genesys_Products_Only__c != null ){
Decimal discountOnQuote = quote.Total_Discount_Genesys_Products_Only__c.setScale(2, RoundingMode.HALF_UP);
Decimal discountSizeDQ1 = (dq.Discount_On_Quote__c == null ? 0 : dq.Discount_On_Quote__c);//DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c);            
Decimal discountOnDQ = discountSizeDQ1.setScale(2, RoundingMode.HALF_UP);
if(discountOnQuote > discountOnDQ){              
violations.add(new wrapperViolationSummary('Discount', String.valueOf(discountOnQuote.setScale(2, RoundingMode.HALF_UP)), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >0% discount requires approval.' ));
if(isValidation)
return violations;
}        
}
*/
        Map<String, Decimal> mapQProductOverrideVsDiscount = new Map<String, Decimal>();
        Boolean isProductSpecificDiscountDQ = false;
        Boolean isProductSpecificDiscountQuote = false;
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            // Max Discount
            if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
               && qrpc.Total_Discount__c != null
               && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c 
               && qrpc.BigMachines__Product__r.Third_Party__c != 'TRUE' ){ 
                   mapQProductOverrideVsDiscount.put(qrpc.BigMachines__Product__c, qrpc.Total_Discount__c);
                   isProductSpecificDiscountQuote = true;
               }
        }
        
        Map<String, Decimal> mapDQProductOverrideVsDiscount = new Map<String, Decimal>();
        //Deal Qualification products
        for(Deal_Qualification_Products__c eachDQProduct : dqProducts){
            if(eachDQProduct.Product__r.Product_Specific_Discount__c != null
               && eachDQProduct.Discount__c != null
               && eachDQProduct.Discount__c > eachDQProduct.Product__r.Product_Specific_Discount__c
               && eachDQProduct.Product__r.Third_Party__c != 'TRUE'){                
                   isProductSpecificDiscountDQ = true;
                   mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c, eachDQProduct.Discount__c);
               }
        }
        
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            //Product Specific Discount
            Decimal PSDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
            if(PSDiscountOnQuote != null){
                Decimal PSDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
                if(PSDiscountOnDQ == null || PSDiscountOnDQ < PSDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('Product Specific Discount', 'Yes', 'Not Approved', 'Product Specific Discount (Product : ' + eachQuoteProduct.BigMachines__Product__r.Name + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            } 
        }
        
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            String description = 'Special offer requires approval. ';
            if(dq.Special_Offers_Business_Exceptions__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                description += 'There is difference in offer term.';
            violations.add(new wrapperViolationSummary('Special Offer Terms', getBooleanToStringValue(quote.Include_Special_Offer_in_Output__c), getBooleanToStringValue(dq.Special_Offer_Terms__c), description ));
            if(isValidation)
                return violations; 
        }        
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c && !dq.Editable_List_Price_Approval_Required__c){
            violations.add(new wrapperViolationSummary('Editable List Price',getBooleanToStringValue(quote.Editable_List_Price_Approval_Required__c ) , 'Not Approved', 'Editable List Price requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        
        //Deal Score Cloud
        CloudDealScoreReapproval(quote,dq,violations);
        /*
if((dq.Deal_Score__c == null || dq.Deal_Score__c > quote.Deal_Score__c) && quote.Deal_Score__c < 5){
violations.add(new wrapperViolationSummary('Deal Score',String.valueof(quote.Deal_Score__c), 'Not Approved', 'Deal Score requires approval.' )); 
if(isValidation)
return violations;  
}
*/
        
        return violations;        
    }
    
    public static List<wrapperViolationSummary> checkApprovalsForCaaS(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){    
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
        List<Deal_Qualification_Products__c> dqProducts = DealQualificationApprovalUtil.getDQProducts(dq.id);
        Boolean blnisCreditInvolved = false;
        Boolean blnisCreditIncreased = false;                  
        //Amend Check
        Boolean blnDiscountDQReq = false;
        Boolean blnOverageDQReq = false;
        Boolean blnBaseAgentDiscountDQReq = false;
        Boolean blnHardwareDiscountDQReq = false;
        Boolean blnDataCenterProvisioningDiscountDQReq = false;
        Boolean blnBusinessUsersAddonDiscountDQReq = false;
        Boolean blnThirdPartyDiscountDQReq = false;
        Map<String, Decimal> mapQProductOverrideVsDiscount = new Map<String, Decimal>();
        Boolean isProductSpecificDiscountDQ = false;
        Boolean isProductSpecificDiscountQuote = false;
        
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            if(qrpc.BigMachines__Product__r.New_Category__c == 'Credit')
                blnisCreditInvolved = true;                                          
            //Amend check
            if((qrpc.Subscription_Product__c ==  null && qrpc.Total_Discount__c > 0) || (qrpc.Subscription_Product__c != null && qrpc.Total_Discount__c > (qrpc.Subscription_Product__r.Total_Discount__c == null ? 0 : qrpc.Subscription_Product__r.Total_Discount__c.setscale(2)))) {
                if(qrpc.Is_Overage__c)
                    blnOverageDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Base Agent')
                    blnBaseAgentDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Hardware')
                    blnHardwareDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Data Center Provisioning')
                    blnDataCenterProvisioningDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Business Users & Add-On Functionality')
                    blnBusinessUsersAddonDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.Third_Party__c == 'TRUE')
                    blnThirdPartyDiscountDQReq = true;
                blnDiscountDQReq = true;
                
                // Product Specific Discount
                if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
                   && qrpc.Total_Discount__c != null
                   && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c 
                   //Anju Nov 20 removing 3rd party check as per Kip's comment
                   //&& qrpc.BigMachines__Product__r.Third_Party__c != 'TRUE'
                  ){                
                      mapQProductOverrideVsDiscount.put(qrpc.BigMachines__Product__c, qrpc.Total_Discount__c);
                      isProductSpecificDiscountQuote = true;
                  } 
            }
            //Amend check for credit
            if(qrpc.Subscription_Product__c !=  null && qrpc.BigMachines__Product__r.New_Category__c == 'Credit' && qrpc.BigMachines__Quantity__c != qrpc.Subscription_Product__r.quantity__c) 
                blnisCreditIncreased = true;              
        }
        Map<String, Decimal> mapDQProductOverrideVsDiscount = new Map<String, Decimal>();
        //Deal Qualification products
        for(Deal_Qualification_Products__c eachDQProduct : dqProducts){
            if(eachDQProduct.Product__r.Product_Specific_Discount__c != null
               && eachDQProduct.Discount__c != null
               && eachDQProduct.Discount__c > eachDQProduct.Product__r.Product_Specific_Discount__c
               //&& eachDQProduct.Product__r.Third_Party__c != 'TRUE'
              ){                
                  isProductSpecificDiscountDQ = true;
                  mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c, eachDQProduct.Discount__c);
              }
        }
        
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            //Product Specific Discount
            Decimal PSDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
            if(PSDiscountOnQuote != null){
                Decimal PSDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
                if(PSDiscountOnDQ == null || PSDiscountOnDQ < PSDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('Product Specific Discount', 'Yes', 'Not Approved', 'Product Specific Discount (Product : ' + eachQuoteProduct.BigMachines__Product__r.Name + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            } 
        }
        
        Double decAcvDQ = 0;
        if(dq.Net_Deal_Size_Amount__c != null){
            decAcvDQ = dq.Net_Deal_Size_Amount__c;
            //decAcvDQ = DealQualificationApprovalUtil.convertCurrency(decAcvDQ, quote.CurrencyIsoCode);
        }
        //Cloud Deal
        Decimal decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        system.debug(decUSDACV + ':' + decAcvDQ);
        if(!quote.Order_Type__c.contains('Amend') && ((dq.id == null && decUSDACV <= 168000.00) || 
                                                      (dq.id != null && (decAcvDQ > decUSDACV || dq.Net_Deal_Size_Amount__c == null) && decUSDACV <= 168000.00))){
                                                          violations.add(new wrapperViolationSummary('PureConnect Cloud Deal', 'ACV <= USD 168,000', 'Not Approved',  'ACV does not meet required minimum.' ));
                                                          if(isValidation)
                                                              return violations;
                                                      }
        
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            String description = 'Special offer requires approval. ';
            if(dq.Special_Offers_Business_Exceptions__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                description += 'There is difference in offer term.';
            violations.add(new wrapperViolationSummary('Special Offer Terms', getBooleanToStringValue(quote.Include_Special_Offer_in_Output__c), getBooleanToStringValue(dq.Special_Offer_Terms__c), description ));
            if(isValidation)
                return violations; 
        } 
        
        //Deal Score Cloud
        if(!quote.Order_Type__c.contains('Amend'))
            CloudDealScoreReapproval(quote,dq,violations);
        /*if((dq.Deal_Score__c == null || dq.Deal_Score__c > quote.Deal_Score__c) && quote.Deal_Score__c < 5 && !quote.Order_Type__c.contains('Amend')){
violations.add(new wrapperViolationSummary('Deal Score',String.valueof(quote.Deal_Score__c), 'Not Approved', 'Deal Score requires approval.' )); 
if(isValidation)
return violations;  
}*/
        //PCC Credit--Rony Joseph-April 17 2019--Validation for PCC Credit-Begins
        System.debug('Inside DQ Sync for PCC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased+'quote.Migration_credit__c:'+quote.Migration_credit__c+'dq.Migration_Credit__c:'+dq.Migration_Credit__c);
        if((!quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c== false||(quote.Migration_credit__c != dq.Migration_Credit__c))  && blnisCreditInvolved)
           || ( quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c == false  || (quote.Migration_credit__c != dq.Migration_Credit__c)) && blnisCreditInvolved && blnisCreditIncreased)){
               String description = 'PureConnect Cloud Credit requires approval. ';
               dq.Migration_Credit__c = quote.Migration_credit__c ;
               violations.add(new wrapperViolationSummary('PureConnect Cloud Credit', '', '', description ));
               if(isValidation)
                   return violations; 
           }
        System.debug('Inside DQ Sync for PCC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased+'quote.Migration_credit__c:'+quote.Migration_credit__c+'dq.Migration_Credit__c:'+dq.Migration_Credit__c);
        
        //PCC Credit--Rony Joseph-April 17 2019--Validation for PCC Credit-Ends                                      
        //Third Party Discount
        if((blnThirdPartyDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Third_Party_Discount__c != null){
            if((dq.Third_Party_Discount__c == null || dq.Third_Party_Discount__c < quote.Third_Party_Discount__c) && quote.Third_Party_Discount__c > 0){
                violations.add(new wrapperViolationSummary('Third Party Discount',String.valueof(quote.Third_Party_Discount__c), 'Not Approved', 'Third Party Discount requires approval.')); 
                if(isValidation)
                    return violations;  
            }
        }
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c && !dq.Editable_List_Price_Approval_Required__c){
            violations.add(new wrapperViolationSummary('Editable List Price',getBooleanToStringValue(quote.Editable_List_Price_Approval_Required__c ) , 'Not Approved', 'Editable List Price requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        
        //Base Agent Discount
        /* Anju removing for DDS
if((blnBaseAgentDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Base_Agent_Discount__c != null){
Decimal discountOnQuote = quote.Base_Agent_Discount__c.setScale(2, RoundingMode.HALF_UP);
Decimal discountOnDQ = (dq.Base_Agent_Discount__c == null ? 0 : dq.Base_Agent_Discount__c).setScale(2, RoundingMode.HALF_UP);
if(discountOnQuote > 0 && discountOnQuote > discountOnDQ){              
violations.add(new wrapperViolationSummary('Base Agent Discount', String.valueOf(discountOnQuote), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >=0 requires approval.' ));
if(isValidation)
return violations;
}        
}*/
        
        //Hardware Discount
        if((blnHardwareDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Hardware_Discount__c != null ){
            Decimal discountOnQuote = quote.Hardware_Discount__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Hardware_Discount__c == null ? 0 : dq.Hardware_Discount__c).setScale(2, RoundingMode.HALF_UP); 
            if(discountOnQuote > 0 && discountOnQuote > discountOnDQ){              
                violations.add(new wrapperViolationSummary('Telco, MPLS, Hardware, 3rd Party, and Miscellaneous Costs Discount', String.valueOf(discountOnQuote), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >=0 requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        //Add-On Discount
        if((blnBusinessUsersAddonDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Business_Users_Add_On__c != null ){
            Decimal discountOnQuote = quote.Business_Users_Add_On__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Business_Users_Add_On__c == null ? 0 : dq.Business_Users_Add_On__c).setScale(2, RoundingMode.HALF_UP);
            if(discountOnQuote > 25 && discountOnQuote > discountOnDQ){              
                violations.add(new wrapperViolationSummary('Business Users & Add-On Discount', String.valueOf(discountOnQuote), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >=0 requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Data Center Provisioning Discount
        if((blnDataCenterProvisioningDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Data_Center_Provisioning_Discount__c != null ){
            Decimal discountOnQuote = quote.Data_Center_Provisioning_Discount__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Data_Center_Provisioning_Discount__c == null ? 0 : dq.Data_Center_Provisioning_Discount__c).setScale(2, RoundingMode.HALF_UP);
            if(discountOnQuote > 10 && discountOnQuote > discountOnDQ){              
                violations.add(new wrapperViolationSummary('Data Center Provisioning Discount', String.valueOf(discountOnQuote), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >=0 requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        } 
        
        //Initial Subscription Term
        if(quote.No_Of_Months__c != null ){
            Decimal termMonths = quote.No_Of_Months__c.setScale(2, RoundingMode.HALF_UP);
            Decimal termMonthsOnDQ = DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c);
            //Amend
            Integer decAmendtermMonths = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Term__c != null){                
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Month'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Month'));
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Year'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Year')) * 12; 
                //termMonths = decAmendtermMonths > termMonths ? decAmendtermMonths : termMonths;
            }
            if(termMonths > 36 && termMonths > termMonthsOnDQ && termMonths > decAmendtermMonths){              
                violations.add(new wrapperViolationSummary('Initial Subscription Term', String.valueOf(termMonths), termMonthsOnDQ  == 0 ? 'Not Approved' : String.valueOf(termMonthsOnDQ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Ramp Period
        if(!quote.Order_Type__c.contains('Amend') && quote.Ramp_Period__c != null && quote.Ramp_Period__c != 'Other'){
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            Decimal rampPeriod = Decimal.valueof(strRampPeriod).setScale(2, RoundingMode.HALF_UP);
            Decimal rampPeriodOnDQ = DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c);
            if(rampPeriod > 180 && rampPeriod > rampPeriodOnDQ ){              
                violations.add(new wrapperViolationSummary('Ramp Period', String.valueOf(rampPeriod), rampPeriodOnDQ == 0 ? 'Not Approved' : String.valueOf(rampPeriodOnDQ ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Billing Period
        if(quote.Billing_Period__c != null && quote.Billing_Period__c != 'Other'){
            Decimal billingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Billing_Period__c);
            Decimal billingPeriodOnDQ = DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c);
            //Amend
            Decimal decBillingPeriod = billingPeriod;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Billing_Period__c != null)                
                decBillingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Amendment_For__r.Billing_Period__c);
            if(!quote.Order_Type__c.contains('Amend'))
                decBillingPeriod = 0;
            if(billingPeriod > 0 && billingPeriod != billingPeriodOnDQ && billingPeriod != decBillingPeriod){              
                violations.add(new wrapperViolationSummary('Billing Period', String.valueOf(quote.Billing_Period__c), billingPeriodOnDQ == 0 ? 'Not Approved' : String.valueOf(billingPeriodOnDQ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Payment Terms
        if(quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            //Amend
            Decimal PaymentTermAmend = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Payment_Term__c != null){
                PaymentTermAmend = DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c) > PaymentTerm ? DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c):PaymentTerm;
            }
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ && PaymentTerm > PaymentTermAmend){              
                violations.add(new wrapperViolationSummary('Payment Terms', String.valueOf(PaymentTerm), PaymentTermOnDQ == 0 ? 'Not Approved' : String.valueOf(PaymentTermOnDQ ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        
        //Agent user calculation
        Decimal intAgentCount = 0;
        Decimal intBusinessUserCount = 0;
        for(BigMachines__Quote_Product__c qProduct : [SELECT id, Quantity__c, BigMachines__Quantity__c, APN_Number__c from  BigMachines__Quote_Product__c where BigMachines__Quote__c = :quote.id]){
            //Added Null Check by Anshul on 22/08/18
            if(qProduct.APN_Number__c != null){
                if(Label.PCC_Agent_based_products.contains(qProduct.APN_Number__c))
                    intAgentCount += qProduct.Quantity__c;
                if(Label.PCC_Business_users_products.contains(qProduct.APN_Number__c))
                    intBusinessUserCount += qProduct.Quantity__c;
            }    
        }
        
        if(intAgentCount > 0 && intAgentCount < 100){
            //if(dq.Estimated_Number_of_Agents__c == null) dq.Estimated_Number_of_Agents__c = 0;
            system.debug(dq.Estimated_Number_of_Agents__c);
            system.debug(intAgentCount );
            if(dq.Estimated_Number_of_Agents__c == null || intAgentCount  < dq.Estimated_Number_of_Agents__c){        
                violations.add(new wrapperViolationSummary('Agent Minimum ', String.valueOf(intAgentCount), dq.Estimated_Number_of_Agents__c == 0 ? 'Not Approved' : String.valueOf(dq.Estimated_Number_of_Agents__c) , ' Less than 100 agents requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        
        if(intBusinessUserCount > 5000){
            if(dq.Estimated_Number_of_Business_Users__c == null) dq.Estimated_Number_of_Business_Users__c = 0;
            
            if(intBusinessUserCount > dq.Estimated_Number_of_Business_Users__c ){              
                violations.add(new wrapperViolationSummary('Maximum Business users ', String.valueOf(intBusinessUserCount), dq.Estimated_Number_of_Business_Users__c == 0 ? 'Not Approved' : String.valueOf(dq.Estimated_Number_of_Business_Users__c ) , ' More than 5000 Business users requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        /*
if(intBusinessUserCount > 0 && intAgentCount > 0){
Decimal intRatio = intBusinessUserCount / intAgentCount;
if(intRatio.round() > 10 && dq.Business_User_to_Agent_Ratio_Exception__c != 'yes'){ 

violations.add(new wrapperViolationSummary('Business User Ratio ', String.valueOf(intRatio), 'Not Approved' , ' requires approval.' ));
if(isValidation)
return violations;
}        
}
*/
        
        //Bursting %
        if(quote.Overage_Allowance__c != null && quote.Overage_Allowance__c == 'Other' && (dq.Overage_Allowance__c == null || dq.Overage_Allowance__c != 'Other' || (dq.Overage_Allowance__c == 'Other' && dq.quote__c != quote.id))){
            violations.add(new wrapperViolationSummary('Burst Allowance – Other', quote.Overage_Allowance__c, dq.Overage_Allowance__c == null ? 'Not Approved' : dq.Overage_Allowance__c, ' \'Other\' requires approval.' ));
            if(isValidation)
                return violations;    
        }
        
        //PC Overage Discount      
        if((blnOverageDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Overage_Discount__c != null){
            
            if(quote.Overage_Discount__c > 0 && (quote.Overage_Discount__c.setScale(2) > dq.Overage_Discount__c || dq.Overage_Discount__c ==  null)){              
                violations.add(new wrapperViolationSummary('Overage Discount', String.valueOf(quote.Overage_Discount__c.setScale(2)), dq.Overage_Discount__c == 0 ? 'Not Approved' : String.valueOf(dq.Overage_Discount__c) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Annual Price Escalator
        if(quote.Price_Escalation__c != null && quote.Price_Escalation__c == 'Other' && (dq.Price_Escalation__c == null || dq.Price_Escalation__c != 'Other' || (dq.Price_Escalation__c == 'Other' && dq.quote__c != quote.id))){
            violations.add(new wrapperViolationSummary('Annual Price Escalation – Other', quote.Price_Escalation__c, dq.Price_Escalation__c == null ? 'Not Approved' : dq.Price_Escalation__c, ' \'Other\' requires approval.' ));
            if(isValidation)
                return violations;    
        }
        
        //TCV reduction        
        if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null){
            if(quote.Total_Contract_Value_Change__c < 0 && (quote.Total_Contract_Value_Change__c < dq.TCV_Reduction__c || dq.TCV_Reduction__c == null)){
                violations.add(new wrapperViolationSummary('TCV Reduction', String.valueOf(quote.Total_Contract_Value_Change__c), '' , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }
            
        }
        
        return violations;        
    }
    
    //DQ Validation for new PC - Anju
    public static List<wrapperViolationSummary> checkApprovalsForPC(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){    
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        system.debug('inside check starts');
        
        BigMachines__Quote__c currentQuote = [Select id,Professional_Services_Discount__c ,currencyisocode,Owner_Segment__c,BigMachines__Opportunity__r.Offering_Detail__c,
                                              PureCloud_Monthly_Minimum__c,BigMachines__Opportunity__r.Direct_Indirect_Sale__c,
                                              BigMachines__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c,
                                              BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c
                                              from BigMachines__Quote__c where id = :quote.id limit 1];
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(currentQuote.id);
        List<Deal_Qualification_Products__c> dqProducts = DealQualificationApprovalUtil.getDQProducts(dq.id);
        if(currentQuote.BigMachines__Opportunity__r.Offering_Detail__c == 'Free Trial')
            return violations;                                         
        Boolean blnisDevOrg = false;
        Boolean blnisCreditInvolved = false;
        Boolean blnisCreditIncreased = false;
        
        //Amend Check
        Boolean blnProfServDQReq = false;
        Boolean blnHardwareDQReq = false;
        Boolean blnSoftwareDQReq = false;
        Boolean blnDiscountDQReq = false;
        Boolean blnOverageDQReq = false;
        Map<String, Decimal> mapQProductOverrideVsDiscount = new Map<String, Decimal>();
        Boolean isProductSpecificDiscountDQ = false;
        Boolean isProductSpecificDiscountQuote = false;
        Boolean blnExceedsPartnerBaselineDiscount = false;
        if(!currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c)
            blnExceedsPartnerBaselineDiscount = true;
        //List<zqu__QuoteRatePlanCharge__c> quoteProducts = [Select id,zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c,zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.name from zqu__QuoteRatePlanCharge__c where QuoteId__c = :currentQuote.id];
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            if(qrpc.BigMachines__Product__r.APN_Number__c != null && Label.PC_DEV_Org_Parts.contains(qrpc.BigMachines__Product__r.APN_Number__c))
                blnisDevOrg = true;
            if(qrpc.BigMachines__Product__r.New_Category__c == 'Credit')
                blnisCreditInvolved = true;
            if(currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c && qrpc.BigMachines__Product__r.Include_in_CMMR_Total__c && qrpc.Partner_Price__c > qrpc.Net_Unit_Price__c)
                blnExceedsPartnerBaselineDiscount = true;
            
            //Amend check
            
            if((qrpc.Subscription_Product__c ==  null && qrpc.Total_Discount__c > 0) || (qrpc.Subscription_Product__c != null && qrpc.Total_Discount__c > qrpc.Subscription_Product__r.Total_Discount__c)) {
                if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'PROFESSIONAL SERVICES') {
                    blnProfServDQReq = true;
                }
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Hardware') {
                    blnHardwareDQReq = true;
                }
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Software') {
                    blnSoftwareDQReq = true;
                }
                if(qrpc.Is_Overage__c)
                    blnOverageDQReq = true;
                
                blnDiscountDQReq = true;
                
                //Product Specific Discount
                if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
                   && qrpc.Total_Discount__c != null
                   && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c
                   //&& qrpc.BigMachines__Product__r.Third_Party__c != 'TRUE' && qrpc.Is_Overage__c != true
                  ){                
                      mapQProductOverrideVsDiscount.put(qrpc.BigMachines__Product__c, qrpc.Total_Discount__c);
                      isProductSpecificDiscountQuote = true;
                  }
                
            }
            //Amend check for credit
            if(qrpc.Subscription_Product__c !=  null && qrpc.BigMachines__Product__r.New_Category__c == 'Credit' && qrpc.BigMachines__Quantity__c > qrpc.Subscription_Product__r.quantity__c) 
                blnisCreditIncreased = true;
            
            
        }
        
        Map<String, Decimal> mapDQProductOverrideVsDiscount = new Map<String, Decimal>();
        //Deal Qualification products
        for(Deal_Qualification_Products__c eachDQProduct : dqProducts){
            if(eachDQProduct.Product__r.Product_Specific_Discount__c != null
               && eachDQProduct.Discount__c != null
               && eachDQProduct.Discount__c > eachDQProduct.Product__r.Product_Specific_Discount__c
               //&& eachDQProduct.Product__r.Third_Party__c != 'TRUE'
              ){                
                  isProductSpecificDiscountDQ = true;
                  mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c, eachDQProduct.Discount__c);
              }
        }
        
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            //Product Specific Discount
            Decimal PSDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
            if(PSDiscountOnQuote != null){
                Decimal PSDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
                if(PSDiscountOnDQ == null || PSDiscountOnDQ < PSDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('Product Specific Discount', 'Yes', 'Not Approved', 'Product Specific Discount (Product : ' + eachQuoteProduct.BigMachines__Product__r.Name + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            } 
        }
        
        //PC Trial
        Boolean blnisTrial = false;
        if(quote.BigMachines__Opportunity__r.Offering_Detail__c != null && quote.BigMachines__Opportunity__r.Offering_Detail__c.contains('Pilot/Trial/POC')){
            blnisTrial = true;
        }
        
        if(dq.PureCloud_Trial__c == false && blnisTrial){
            String description = 'PureCloud Trial requires approval. ';
            
            violations.add(new wrapperViolationSummary('PureCloud Trial', '', '', description ));
            if(isValidation)
                return violations; 
        }
        
        Double decAcvDQ = 0;
        if(dq.Net_Deal_Size_Amount__c != null){
            decAcvDQ = dq.Net_Deal_Size_Amount__c;
            //decAcvDQ = DealQualificationApprovalUtil.convertCurrency(decAcvDQ, quote.CurrencyIsoCode);
        }
        //Cloud Deal
        Decimal decUSDACV =0;
        if(!Test.isRunningTest()) {
            decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        }
        system.debug(dq.id);
        system.debug(decUSDACV);
        system.debug(currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c);
        if(!quote.Order_Type__c.contains('Amend') && !blnisTrial &&
           ((dq.id == null && decUSDACV <= 24000.00 && !currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) 
            || (dq.id == null && decUSDACV <= 12000.00 && currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) 
            || (dq.id != null && (decAcvDQ > decUSDACV || dq.Net_Deal_Size_Amount__c == null) && (decUSDACV <= 12000.00 && currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c || decUSDACV <= 24000.00 && !currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c)))){
                violations.add(new wrapperViolationSummary('PureCloud Deal', currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c == true ? 'ACV <= USD 12,000' : 'ACV <= USD 24,000', 'Not Approved',  'ACV does not meet required minimum.' ));
                if(isValidation)
                    return violations;
            }
        System.debug('Inside check for PC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased);
        //PC Credit
        if((!quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c== false||(quote.Migration_credit__c !=  dq.Migration_Credit__c))  && blnisCreditInvolved)
           || ( quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c == false  || (quote.Migration_credit__c != dq.Migration_Credit__c)) && blnisCreditInvolved && blnisCreditIncreased)){
               String description = 'PureCloud Credit requires approval. ';
               dq.Migration_Credit__c = quote.Migration_credit__c ;
               violations.add(new wrapperViolationSummary('PureCloud Credit', '', '', description ));
               if(isValidation)
                   return violations; 
           }                                                                                                                                                                           
        //Deal Score Cloud
        if(!quote.Order_Type__c.contains('Amend') && blnExceedsPartnerBaselineDiscount)
            CloudDealScoreReapproval(quote,dq,violations);
        /*if((dq.Deal_Score__c == null || dq.Deal_Score__c > quote.Deal_Score__c) && quote.Deal_Score__c < 5 && !quote.Order_Type__c.contains('Amend')){
violations.add(new wrapperViolationSummary('Deal Score',String.valueof(quote.Deal_Score__c), 'Not Approved', 'Deal Score requires approval.' )); 
if(isValidation)
return violations;  
}*/
        
        //PC Monthly minimum
        
        Boolean blnMonthMinNUllCheck = false;
        //if(currentQuote.zqu__SubscriptionType__c == 'New Subscription')
        //{
        if(currentQuote.PureCloud_Monthly_Minimum__c == null){
            currentQuote.PureCloud_Monthly_Minimum__c = 0;
            blnMonthMinNUllCheck = true;
        }
        
        if(dq.If_Other_PureCloud_Monthly_Minimum_Req__c == null){
            dq.If_Other_PureCloud_Monthly_Minimum_Req__c = 0;
            blnMonthMinNUllCheck = true;
        }
        
        Boolean blnMonthMinCheck = false;
        
        Map<String, Decimal> mapCurrencies = new Map<String, Decimal>();
        mapCurrencies = QuoteCloudUtil.buildConversionRatesMap();
        Double USDMonthlyMinimum = currentQuote.PureCloud_Monthly_Minimum__c;
        if(mapCurrencies.containskey(currentQuote.CurrencyIsoCode))
        {
            USDMonthlyMinimum = currentQuote.PureCloud_Monthly_Minimum__c / mapCurrencies.get(currentQuote.CurrencyIsoCode);
            dq.If_Other_PureCloud_Monthly_Minimum_Req__c = dq.If_Other_PureCloud_Monthly_Minimum_Req__c / mapCurrencies.get(currentQuote.CurrencyIsoCode);
        }
        
        if(currentQuote.Owner_Segment__c == 'Velocity' && USDMonthlyMinimum >= 1500){
            
            blnMonthMinCheck = true;
        }
        else if(currentQuote.BigMachines__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c && USDMonthlyMinimum >= 750){
            
            blnMonthMinCheck = true;
        }
        else if(currentQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect' && USDMonthlyMinimum >= 1000){
            
            blnMonthMinCheck = true;
        }
        else if(blnisDevOrg && USDMonthlyMinimum >= 0){
            
            blnMonthMinCheck = true;
        }
        else if(USDMonthlyMinimum >= 2000){
            
            blnMonthMinCheck = true;
        }
        //}
        //else
        // blnMonthMinCheck = true;
        
        if(!quote.Order_Type__c.contains('Amend') && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Pilot/Trial/POC' && blnMonthMinCheck == false && (dq.If_Other_PureCloud_Monthly_Minimum_Req__c > USDMonthlyMinimum || blnMonthMinNUllCheck)){
            String description = 'PureCloud monthly minimum requires approval. ';
            description += 'There is difference in PureCloud monthly minimum.';
            violations.add(new wrapperViolationSummary('PureCloud monthly minimum ', String.valueof(quote.PureCloud_Monthly_Minimum__c), String.valueof(dq.If_Other_PureCloud_Monthly_Minimum_Req__c), description ));
            if(isValidation)
                return violations; 
        }
        
        
        
        //Discount
        /* Anju removing for DDS
Decimal decOnDQ = 0;


Decimal decDiscount = quote.Total_Discount_Genesys_and_Third_Party__c;
if(decDiscount == null)
decDiscount = 0;
if(dq.Discount_On_Quote__c == null)
dq.Discount_On_Quote__c = 0;

decDiscount = decDiscount.setScale(2);

if(decOnDQ != null && dq.Discount_On_Quote__c != null)
decOnDQ = dq.Discount_On_Quote__c.setScale(2);

if((blnDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && decOnDQ < decDiscount){
String description = 'Discount requires approval. ';
description += 'There is difference in discount.';
violations.add(new wrapperViolationSummary('Discount', String.valueof(decDiscount), String.valueof(decOnDQ), description ));
if(isValidation)
return violations; 
}
*/
        //Deal Size
        
        Decimal acv = quote.Annual_Contract_Value__c;
        /*
if(decAcvDQ < acv){
String description = 'Deal size approval. ';          
description += 'There is difference in Net Deal size(ACV).';
violations.add(new wrapperViolationSummary('Deal size ', String.valueof(acv), String.valueof(decAcvDQ), description ));
if(isValidation)
return violations; 
}
*/
        
        
        
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            String description = 'Special offer requires approval. ';
            if(dq.Special_Offers_Business_Exceptions__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                description += 'There is difference in offer term.';
            violations.add(new wrapperViolationSummary('Special Offer Terms', getBooleanToStringValue(quote.Include_Special_Offer_in_Output__c), getBooleanToStringValue(dq.Special_Offer_Terms__c), description ));
            if(isValidation)
                return violations; 
        } 
        
        
        
        //Initial Subscription Term
        if(quote.No_Of_Months__c != null ){
            
            Decimal termMonths = quote.No_Of_Months__c.setScale(2, RoundingMode.HALF_UP);
            Decimal termMonthsOnDQ = DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c);
            //Amend
            Integer decAmendtermMonths = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Term__c != null){
                
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Month'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Month'));
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Year'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Year')) * 12; 
                //termMonths = decAmendtermMonths > termMonths ? decAmendtermMonths : termMonths;
            }
            if(termMonths > 36 && termMonths > termMonthsOnDQ && termMonths > decAmendtermMonths){              
                violations.add(new wrapperViolationSummary('Initial Subscription Term', String.valueOf(termMonths), termMonthsOnDQ  == 0 ? 'Not Approved' : String.valueOf(termMonthsOnDQ) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Ramp Period
        if(!quote.Order_Type__c.contains('Amend') && quote.Ramp_Period__c != null && quote.Ramp_Period__c != 'Other'){
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            Decimal rampPeriod = Decimal.valueof(strRampPeriod).setScale(2, RoundingMode.HALF_UP);
            Decimal rampPeriodOnDQ = DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c);
            if(rampPeriod > 120 && rampPeriod > rampPeriodOnDQ ){              
                violations.add(new wrapperViolationSummary('Ramp Period', String.valueOf(rampPeriod), rampPeriodOnDQ == 0 ? 'Not Approved' : String.valueOf(rampPeriodOnDQ ) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //PC Overage Discount      
        if((blnOverageDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Overage_Discount__c != null){
            
            if(quote.Overage_Discount__c > 0 && (quote.Overage_Discount__c.setScale(2) > dq.Overage_Discount__c || dq.Overage_Discount__c ==  null)){              
                violations.add(new wrapperViolationSummary('Overage Discount', String.valueOf(quote.Overage_Discount__c.setScale(2)), dq.Overage_Discount__c == 0 ? 'Not Approved' : String.valueOf(dq.Overage_Discount__c) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //PC PS Discount        
        if((blnProfServDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Professional_Services_Discount__c != null){
            
            if(quote.Professional_Services_Discount__c  > 0 && (quote.Professional_Services_Discount__c.setScale(2) > dq.PS_Discount_on_Quote__c || dq.PS_Discount_on_Quote__c ==  null)){              
                violations.add(new wrapperViolationSummary('Professional Services Discount', String.valueOf(quote.Professional_Services_Discount__c.setScale(2)), dq.PS_Discount_on_Quote__c == 0 ? 'Not Approved' : String.valueOf(dq.PS_Discount_on_Quote__c) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Harware discount
        if((blnHardwareDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Hardware_Discount__c != null){
            
            if(quote.Hardware_Discount__c  > 0 && (quote.Hardware_Discount__c.setScale(2) > dq.Hardware_Discount__c || dq.Hardware_Discount__c ==  null)){              
                violations.add(new wrapperViolationSummary('Hardware Discount', String.valueOf(quote.Hardware_Discount__c.setScale(2)), dq.Hardware_Discount__c == 0 ? 'Not Approved' : String.valueOf(dq.Hardware_Discount__c) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Software discount
        /* Anju removing for DDS
if((blnSoftwareDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Software_Discount__c != null){

if(quote.Software_Discount__c   > 0 && (quote.Software_Discount__c.setScale(2)  > dq.Software_Discount__c || dq.Software_Discount__c ==  null)){              
violations.add(new wrapperViolationSummary('Software Discount', String.valueOf(quote.Software_Discount__c.setScale(2)), dq.Software_Discount__c == 0 ? 'Not Approved' : String.valueOf(dq.Software_Discount__c) , ' Requires approval.' ));
if(isValidation)
return violations;
}        
}
*/
        
        
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c && !dq.Editable_List_Price_Approval_Required__c){
            violations.add(new wrapperViolationSummary('Editable List Price',getBooleanToStringValue(quote.Editable_List_Price_Approval_Required__c ) , 'Not Approved', 'Editable List Price requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        
        
        //Payment Terms
        if(quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            //Amend
            Decimal PaymentTermAmend = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Payment_Term__c != null){
                PaymentTermAmend = DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c) > PaymentTerm ? DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c):PaymentTerm;
            }
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ && PaymentTerm > PaymentTermAmend){              
                violations.add(new wrapperViolationSummary('Payment Terms', String.valueOf(PaymentTerm), PaymentTermOnDQ == 0 ? 'Not Approved' : String.valueOf(PaymentTermOnDQ ) , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //TCV reduction
        
        if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null){
            if(quote.Total_Contract_Value_Change__c < 0 && (quote.Total_Contract_Value_Change__c < dq.TCV_Reduction__c || dq.TCV_Reduction__c == null)){
                violations.add(new wrapperViolationSummary('TCV Reduction', String.valueOf(quote.Total_Contract_Value_Change__c), '' , ' Requires approval.' ));
                if(isValidation)
                    return violations;
            }
            
        }
        
        //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- Start
        if(quote.Renewal_Subscription_Term__c == 'Automatic Monthly'){
            if((quote.Renewal_Subscription_Term__c == 'Automatic Monthly' && quote.Billing_Category__c != 'M2M') || (quote.Renewal_Subscription_Term__c == 'Automatic Monthly' && quote.Billing_Category__c == 'M2M' && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial')){
                dq.Renewal_Subscription_Term__c = true;
                violations.add(new wrapperViolationSummary('Renewal Subscription Term', String.valueOf(quote.Renewal_Subscription_Term__c), '' , 'Renewal Subscription Term  of \'Automatic Monthly\' requires approval.' ));
                if(isValidation)
                    return violations;
            }
        }
        if(quote.Renewal_Subscription_Term__c == 'Automatic Initial Subscription'){
            if((quote.Renewal_Subscription_Term__c == 'Automatic Initial Subscription' && quote.Billing_Category__c != 'M2M') || (quote.Renewal_Subscription_Term__c == 'Automatic Initial Subscription' && quote.Billing_Category__c == 'M2M' && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial')){
                dq.Renewal_Subscription_Term__c = true;
                violations.add(new wrapperViolationSummary('Renewal Subscription Term', String.valueOf(quote.Renewal_Subscription_Term__c), '' , 'Renewal Subscription Term  of \'Automatic Initial Subscription\' requires approval.' ));
                if(isValidation)
                    return violations;
            }
        }
        if(quote.Renewal_Subscription_Term__c == 'No Auto-Renewal'){
            if((quote.Renewal_Subscription_Term__c == 'No Auto-Renewal' && quote.Billing_Category__c != 'M2M') || (quote.Renewal_Subscription_Term__c == 'No Auto-Renewal' && quote.Billing_Category__c == 'M2M' && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial')){
                dq.Renewal_Subscription_Term__c = true;
                violations.add(new wrapperViolationSummary('Renewal Subscription Term', String.valueOf(quote.Renewal_Subscription_Term__c), '' , 'Renewal Subscription Term  of \'No Auto-Renewal\' requires approval.' ));
                if(isValidation)
                    return violations;
            }
        }
        if(quote.Billing_Category__c == 'M2M'){
            dq.Billing_Category__c = 'M2M';
            violations.add(new wrapperViolationSummary('Billing Category', String.valueOf(quote.Billing_Category__c), '' , 'Billing Category of \'M2M\'requires approval.' ));
            if(isValidation)
                return violations;
        }
        //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- End
        
        return violations;        
    }
    // Added by Kartik
    public static List<wrapperViolationSummary> checkApprovalsForPEC(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){    
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
        List<Deal_Qualification_Products__c> dqProducts = DealQualificationApprovalUtil.getDQProducts(dq.id);
        Boolean blnisCreditInvolved = false;
        Boolean blnisCreditIncreased = false;                                   
        //Amend Check
        Boolean blnDiscountDQReq = false;
        Boolean blnOverageDQReq = false;
        Boolean blnBaseAgentDiscountDQReq = false;
        Boolean blnHardwareDiscountDQReq = false;
        Boolean blnDataCenterProvisioningDiscountDQReq = false;
        Boolean blnBusinessUsersAddonDiscountDQReq = false;
        Boolean blnThirdPartyDiscountDQReq = false;
        Map<String, Decimal> mapQProductOverrideVsDiscount = new Map<String, Decimal>();
        Boolean isProductSpecificDiscountDQ = false;
        Boolean isProductSpecificDiscountQuote = false;
        
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            if(qrpc.BigMachines__Product__r.New_Category__c == 'Credit')
                blnisCreditInvolved = true;                                                                                
            //Amend check
            if((qrpc.Subscription_Product__c ==  null && qrpc.Total_Discount__c > 0) || (qrpc.Subscription_Product__c != null && qrpc.Total_Discount__c > (qrpc.Subscription_Product__r.Total_Discount__c == null ? 0 : qrpc.Subscription_Product__r.Total_Discount__c.setscale(2)))) {
                if(qrpc.Is_Overage__c)
                    blnOverageDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Base Agent')
                    blnBaseAgentDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Hardware')
                    blnHardwareDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Data Center Provisioning')
                    blnDataCenterProvisioningDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Business Users & Add-On Functionality')
                    blnBusinessUsersAddonDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.Third_Party__c == 'TRUE')
                    blnThirdPartyDiscountDQReq = true;
                blnDiscountDQReq = true;
                
                // Product Specific Discount
                if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
                   && qrpc.Total_Discount__c != null
                   && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c 
                   //Anju Nov 20 removing 3rd party check as per Kip's comment
                   //&& qrpc.BigMachines__Product__r.Third_Party__c != 'TRUE'
                  ){                
                      mapQProductOverrideVsDiscount.put(qrpc.BigMachines__Product__c, qrpc.Total_Discount__c);
                      isProductSpecificDiscountQuote = true;
                  } 
            }
            //Amend check for credit
            if(qrpc.Subscription_Product__c !=  null && qrpc.BigMachines__Product__r.New_Category__c == 'Credit' && qrpc.BigMachines__Quantity__c != qrpc.Subscription_Product__r.quantity__c) 
                blnisCreditIncreased = true;                            
        }
        Map<String, Decimal> mapDQProductOverrideVsDiscount = new Map<String, Decimal>();
        //Deal Qualification products
        for(Deal_Qualification_Products__c eachDQProduct : dqProducts){
            if(eachDQProduct.Product__r.Product_Specific_Discount__c != null
               && eachDQProduct.Discount__c != null
               && eachDQProduct.Discount__c > eachDQProduct.Product__r.Product_Specific_Discount__c
               //&& eachDQProduct.Product__r.Third_Party__c != 'TRUE'
              ){                
                  isProductSpecificDiscountDQ = true;
                  mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c, eachDQProduct.Discount__c);
              }
        }
        
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            //Product Specific Discount
            Decimal PSDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
            if(PSDiscountOnQuote != null){
                Decimal PSDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c);
                if((PSDiscountOnDQ == null || PSDiscountOnDQ < PSDiscountOnQuote) && (!eachQuoteProduct.name.contains('Overage')))  {
                    violations.add(new wrapperViolationSummary('Product Specific Discount', 'Yes', 'Not Approved', 'Product Specific Discount (Product : ' + eachQuoteProduct.BigMachines__Product__r.Name + ') requires approval.'));  
                    if(isValidation)
                        return violations;  
                }
            } 
        }
     
        
        Double decAcvDQ = 0;
        if(dq.Net_Deal_Size_Amount__c != null){
            decAcvDQ = dq.Net_Deal_Size_Amount__c;
            //decAcvDQ = DealQualificationApprovalUtil.convertCurrency(decAcvDQ, quote.CurrencyIsoCode);
        }
        //Cloud Deal
        Decimal decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        system.debug(decUSDACV + ':' + decAcvDQ);
        if(!quote.Order_Type__c.contains('Amend') && ((dq.id == null && decUSDACV <= 600000.00) || 
                                                      (dq.id != null && (decAcvDQ > decUSDACV || dq.Net_Deal_Size_Amount__c == null) && decUSDACV <= 600000.00))){
                                                          violations.add(new wrapperViolationSummary('PureEngage Cloud Deal', 'ACV <= USD 600,000', 'Not Approved',  'ACV does not meet required minimum.' ));
                                                          if(isValidation)
                                                              return violations;
                                                      }
        
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            String description = 'Special offer requires approval. ';
            if(dq.Special_Offers_Business_Exceptions__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                description += 'There is difference in offer term.';
            violations.add(new wrapperViolationSummary('Special Offer Terms', getBooleanToStringValue(quote.Include_Special_Offer_in_Output__c), getBooleanToStringValue(dq.Special_Offer_Terms__c), description ));
            if(isValidation)
                return violations; 
        } 
        
        //Deal Score Cloud
        if(!quote.Order_Type__c.contains('Amend'))
            CloudDealScoreReapproval(quote,dq,violations);
        /*if((dq.Deal_Score__c == null || dq.Deal_Score__c > quote.Deal_Score__c) && quote.Deal_Score__c < 5 && !quote.Order_Type__c.contains('Amend')){
violations.add(new wrapperViolationSummary('Deal Score',String.valueof(quote.Deal_Score__c), 'Not Approved', 'Deal Score requires approval.' )); 
if(isValidation)
return violations;  
}*/
        //PCC Credit--Rony Joseph-April 17 2019--Validation for PCC Credit-Begins
        System.debug('Inside DQ Sync for PCC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased+'quote.Migration_credit__c:'+quote.Migration_credit__c+'dq.Migration_Credit__c:'+dq.Migration_Credit__c);
        if((!quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c== false||(quote.Migration_credit__c != dq.Migration_Credit__c))  && blnisCreditInvolved)
           || ( quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c == false  || (quote.Migration_credit__c != dq.Migration_Credit__c)) && blnisCreditInvolved && blnisCreditIncreased)){
               String description = 'PureEngage Cloud Credit requires approval. ';
               dq.Migration_Credit__c = quote.Migration_credit__c ;
               violations.add(new wrapperViolationSummary('PureEngage Cloud Credit', '', '', description ));
               if(isValidation)
                   return violations; 
           }
        System.debug('Inside DQ Sync for PCC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased+'quote.Migration_credit__c:'+quote.Migration_credit__c+'dq.Migration_Credit__c:'+dq.Migration_Credit__c);
        
        //PCC Credit--Rony Joseph-April 17 2019--Validation for PCC Credit-Ends                                                                          
        
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c && !dq.Editable_List_Price_Approval_Required__c){
            violations.add(new wrapperViolationSummary('Editable List Price',getBooleanToStringValue(quote.Editable_List_Price_Approval_Required__c ) , 'Not Approved', 'Editable List Price requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        
        
        
        
        
        //Initial Subscription Term
        if(quote.No_Of_Months__c != null ){
            Decimal termMonths = quote.No_Of_Months__c.setScale(2, RoundingMode.HALF_UP);
            Decimal termMonthsOnDQ = DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c);
            //Amend
            Integer decAmendtermMonths = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Term__c != null){                
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Month'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Month'));
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Year'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Year')) * 12; 
                //termMonths = decAmendtermMonths > termMonths ? decAmendtermMonths : termMonths;
            }
            if(termMonths > 36 && termMonths > termMonthsOnDQ && termMonths > decAmendtermMonths){              
                violations.add(new wrapperViolationSummary('Initial Subscription Term', String.valueOf(termMonths), termMonthsOnDQ  == 0 ? 'Not Approved' : String.valueOf(termMonthsOnDQ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Ramp Period
        if(!quote.Order_Type__c.contains('Amend') && quote.Ramp_Period__c != null && quote.Ramp_Period__c != 'Other'){
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            Decimal rampPeriod = Decimal.valueof(strRampPeriod).setScale(2, RoundingMode.HALF_UP);
            Decimal rampPeriodOnDQ = DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c);
            if(rampPeriod > 180 && rampPeriod > rampPeriodOnDQ ){              
                violations.add(new wrapperViolationSummary('Ramp Period', String.valueOf(rampPeriod), rampPeriodOnDQ == 0 ? 'Not Approved' : String.valueOf(rampPeriodOnDQ ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Billing Period
        if(quote.Billing_Period__c != null && quote.Billing_Period__c != 'Other'){
            Decimal billingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Billing_Period__c);
            Decimal billingPeriodOnDQ = DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c);
            //Amend
            Decimal decBillingPeriod = billingPeriod;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Billing_Period__c != null)                
                decBillingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Amendment_For__r.Billing_Period__c);
            if(!quote.Order_Type__c.contains('Amend'))
                decBillingPeriod = 0;
            if(billingPeriod > 0 && billingPeriod != billingPeriodOnDQ && billingPeriod != decBillingPeriod){              
                violations.add(new wrapperViolationSummary('Billing Period', String.valueOf(quote.Billing_Period__c), billingPeriodOnDQ == 0 ? 'Not Approved' : String.valueOf(billingPeriodOnDQ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        //Payment Terms
        if(quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            //Amend
            Decimal PaymentTermAmend = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Payment_Term__c != null){
                PaymentTermAmend = DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c) > PaymentTerm ? DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c):PaymentTerm;
            }
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ && PaymentTerm > PaymentTermAmend){              
                violations.add(new wrapperViolationSummary('Payment Terms', String.valueOf(PaymentTerm), PaymentTermOnDQ == 0 ? 'Not Approved' : String.valueOf(PaymentTermOnDQ ) , ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        }
        
        
        
        //Bursting %
        if(quote.Overage_Allowance__c != null && quote.Overage_Allowance__c == 'Other' && (dq.Overage_Allowance__c == null || dq.Overage_Allowance__c != 'Other' || (dq.Overage_Allowance__c == 'Other' && dq.quote__c != quote.id))){
            violations.add(new wrapperViolationSummary('Burst Allowance – Other', quote.Overage_Allowance__c, dq.Overage_Allowance__c == null ? 'Not Approved' : dq.Overage_Allowance__c, ' \'Other\' requires approval.' ));
            if(isValidation)
                return violations;    
        }
        
        
        
        //Annual Price Escalator
        if(quote.Price_Escalation__c != null && quote.Price_Escalation__c == 'Other' && (dq.Price_Escalation__c == null || dq.Price_Escalation__c != 'Other' || (dq.Price_Escalation__c == 'Other' && dq.quote__c != quote.id))){
            violations.add(new wrapperViolationSummary('Annual Price Escalation – Other', quote.Price_Escalation__c, dq.Price_Escalation__c == null ? 'Not Approved' : dq.Price_Escalation__c, ' \'Other\' requires approval.' ));
            if(isValidation)
                return violations;    
        }
        
        
        return violations;        
    }
    
    //Anju approval for Deal score cloud
    private static void CloudDealScoreReapproval(BigMachines__Quote__c quote, Deal_Qualification__c dq, List<wrapperViolationSummary> violations){
        //Deal Score
        Double dealSizeOnQuote = 0;
        if(!Test.isRunningTest()) {
            dealSizeOnQuote = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        }
        Double dealSizeOnDQ = dq.Net_Deal_Size_Amount__c == null ? 0 : dq.Net_Deal_Size_Amount__c;
        Double dealScoreOnQuote = quote.Deal_Score__c == null ? 0 : quote.Deal_Score__c;
        Double dealScoreOnDQ = dq.Deal_Score__c == null ? 0 : dq.Deal_Score__c;
        
        Boolean blnApprovalRequired = false;
        
        //Mukunth added for DDS Mega Deals
        Global_setting__c CloudPevMultiplier;
        
        if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CAAS){
            CloudPevMultiplier = Global_setting__c.getValues('Cloud PEV Multiplier PCC');
        }
        else if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_PC){
            CloudPevMultiplier = Global_setting__c.getValues('Cloud PEV Multiplier PC');            
        }
        else if(quote.Offering_Type__c == 'PureEngage Cloud' || quote.Offering_Type__c == 'Business Edition'){
            CloudPevMultiplier = Global_setting__c.getValues('Cloud PEV Multiplier PEC');
        }
        
        if(dealSizeOnQuote != null){
            if(dealSizeOnQuote * Decimal.valueof(CloudPevMultiplier.Information__c) > Decimal.valueof(CloudPevMultiplier.ID__c)){
                isMegaDealbln = true;
            }
        }
        //Mukunth code end
        
        //Mukunth added if condition for Mega Deal. If deal is mega deal then do not submit quote for deal score approval
        if(!isMegaDealbln){
            
            //Original
            if((dq.Deal_Score__c == null || dq.Deal_Score__c > quote.Deal_Score__c) && quote.Deal_Score__c < 5){
                violations.add(new wrapperViolationSummary('Deal Score',String.valueof(quote.Deal_Score__c), 'Not Approved', 'Deal Score requires approval.' )); 
                blnApprovalRequired = true;
                system.debug('Anju inside if');
            }
            
            //Has DDS moved 1 or + grades down
            else if(!blnApprovalRequired && dealScoreOnDQ > dealScoreOnQuote){
                violations.add(new wrapperViolationSummary('Deal Score',  quote.Deal_Score__c == null ? '' : String.valueOf(quote.Deal_Score__c), dq.Deal_Score__c == null ? 'Not Approved' : String.valueOf(dq.Deal_Score__c), 'Deal score change requires approval.'));
                blnApprovalRequired = true;
                system.debug('Anju inside if');  
            }
            //Is prior DDS approved equal to 4 or 5?
            else if(!blnApprovalRequired && (dealScoreOnDQ == 1 || dealScoreOnDQ == 2) && dq.Net_Deal_Size_Amount__c != null){                
                Decimal decDifference = dealSizeOnQuote  - dq.Net_Deal_Size_Amount__c;
                Decimal decDiffPercentage = 0;
                if(dq.Net_Deal_Size_Amount__c != null && dq.Net_Deal_Size_Amount__c > 0)
                    decDiffPercentage = (decDifference * 100) / dq.Net_Deal_Size_Amount__c;
                //Has net deal value oscillated by 10% + of original approval
                if(decDiffPercentage > 10 || decDiffPercentage < -10){
                    violations.add(new wrapperViolationSummary('Deal Score', quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(dealSizeOnQuote)), dealSizeOnDQ == 0 ? 'Not Approved' : quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(dq.Net_Deal_Size_Amount__c)), 'Deal score size changed by more than -10% or +10%.' ));
                    blnApprovalRequired = true;   
                    system.debug('Anju inside if');   
                }
            }
        }
        
    }
    
    public static List<wrapperViolationSummary> checkApprovalsForOnPremiseQuote(BigMachines__Quote__c quote, Deal_Qualification__c dq, Boolean isValidation){
        System.debug('NKC debug dq.id [' + dq.id + ']');  
        List<Deal_Qualification_Products__c> dqProducts = DealQualificationApprovalUtil.getDQProducts(dq.id);
        System.debug('NKC debug dqProducts [' + dqProducts + ']');
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
        Boolean isGUOverrideQuote = false, isBEPOverrideQuote = false, isProductSpecificDiscountQuote = false, isThirdPartyDiscountQuote = false;
        Boolean isGUOverrideDQ = false, isBEPOverrideDQ = false, isProductSpecificDiscountDQ = false, isThirdPartyDiscountDQ = false;
        Boolean isPMApprovalQuote = false, isPMapprovalDQ = false;
        Map<String, Decimal> mapQProductOverrideVsDiscount = new Map<String, Decimal>();
        //Looping over each quote product record to update above flags
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            if(eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c != null
               && eachQuoteProduct.Total_Discount__c != null
               && eachQuoteProduct.Total_Discount__c > eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c){                
                   if(eachQuoteProduct.BigMachines__Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE 
                      || eachQuoteProduct.BigMachines__Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_HARDWARE){
                          isBEPOverrideQuote = true;
                          mapQProductOverrideVsDiscount.put(eachQuoteProduct.BigMachines__Product__c + '-BEP', eachQuoteProduct.Total_Discount__c);
                          continue;
                      }
                   if(eachQuoteProduct.BigMachines__Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_GU){
                       isGUOverrideQuote = true;
                       mapQProductOverrideVsDiscount.put(eachQuoteProduct.BigMachines__Product__c + '-GU', eachQuoteProduct.Total_Discount__c);
                       continue;                   
                   }                 
                   if(eachQuoteProduct.BigMachines__Product__r.Third_Party__c != null
                      && eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toLowerCase() == 'true'){
                          isThirdPartyDiscountQuote = true;
                          mapQProductOverrideVsDiscount.put(eachQuoteProduct.BigMachines__Product__c + '-TP', eachQuoteProduct.Total_Discount__c);
                          continue;
                      }
                   mapQProductOverrideVsDiscount.put(eachQuoteProduct.BigMachines__Product__c + '-PS', eachQuoteProduct.Total_Discount__c);
                   isProductSpecificDiscountQuote = true;
               } 
            //PM Approval
            if(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c != null
               && DealQualificationApprovalUtil.isPMApprovalRequired(eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c)){
                   isPMApprovalQuote = true;  
                   mapQProductOverrideVsDiscount.put(eachQuoteProduct.BigMachines__Product__c + '-PM', 0);
               }
        }
        Map<String, Decimal> mapDQProductOverrideVsDiscount = new Map<String, Decimal>();
        //Deal Qualification products
        for(Deal_Qualification_Products__c eachDQProduct : dqProducts){
            if(eachDQProduct.Product__r.Product_Specific_Discount__c != null
               && eachDQProduct.Discount__c != null
               && eachDQProduct.Discount__c > eachDQProduct.Product__r.Product_Specific_Discount__c){                
                   if(eachDQProduct.Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE 
                      || eachDQProduct.Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_HARDWARE){                    
                          isBEPOverrideDQ = true;
                          mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c + '-BEP', eachDQProduct.Discount__c);
                          continue;
                      }
                   if(eachDQProduct.Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_GU){
                       isGUOverrideDQ = true;
                       mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c + '-GU', eachDQProduct.Discount__c);
                       continue;                   
                   }                 
                   if(eachDQProduct.Product__r.Third_Party__c != null
                      && eachDQProduct.Product__r.Third_Party__c.toLowerCase() == 'true'){
                          isThirdPartyDiscountDQ = true;
                          mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c + '-TP', eachDQProduct.Discount__c);
                          continue;
                      }
                   isProductSpecificDiscountDQ = true;
                   mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c + '-PS', eachDQProduct.Discount__c);
               }
            //PM Approval
            if(eachDQProduct.Product__r.Product_Manager_Approval_Group__c != null
               && DealQualificationApprovalUtil.isPMApprovalRequired(eachDQProduct.Product__r.Shipment_Approval__c)){
                   isPMapprovalDQ = true;  
                   mapDQProductOverrideVsDiscount.put(eachDQProduct.Product__c + '-PM', 0);
               }
        }
        List<Decimal> minimumLimitsDiscountAndDealSize = DealQualificationApprovalUtil.getMinimumApprovalLimit(quote);
        if(quote.Offering_Type__c == 'Cloud Partner (PPU)'){
            minimumLimitsDiscountAndDealSize[0] = 0;
        }
        else if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC){
            minimumLimitsDiscountAndDealSize[0] = 10;  
        }
        else{        
            if(minimumLimitsDiscountAndDealSize[0] < 30)
                minimumLimitsDiscountAndDealSize[0] = 30;
        }
        
        if(Test.isRunningTest()){
            minimumLimitsDiscountAndDealSize[0] = 2;
            minimumLimitsDiscountAndDealSize[1] = 500;
        }
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();
        System.debug('NKC debug quote.Total_Discount_Genesys_Products_Only__c [' + quote.Total_Discount_Genesys_Products_Only__c +']');
        System.debug('NKC debug minimumLimitsDiscountAndDealSize[0] [' + minimumLimitsDiscountAndDealSize[0] +']');
        //Discount
        if(quote.Total_Discount_Genesys_Products_Only__c != null && (quote.Quote_Opportunity_Type__c == 'Old Pricing' || quote.Offering_Type__c == 'Cloud Partner (PPU)' || quote.Conversion_Quote__c != null)){
            Double discountOnQuote = Double.valueOf(quote.Total_Discount_Genesys_Products_Only__c);
            Double discountSizeDQ1 = DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c);            
            Double discountOnDQ = discountSizeDQ1;
            System.debug('NKC debug discountOnQuote [' + discountOnQuote +']');
            System.debug('NKC debug discountSizeDQ1 [' + discountSizeDQ1 +']');
            
            if(discountOnQuote >= minimumLimitsDiscountAndDealSize[0] && discountOnQuote > discountOnDQ){              
                violations.add(new wrapperViolationSummary('Discount', String.valueOf(Decimal.valueOf(discountOnQuote).setScale(2, RoundingMode.HALF_UP)), discountOnDQ == 0 ? 'Not Approved' : String.valueOf(discountOnDQ) , ' >=' + String.valueOf(minimumLimitsDiscountAndDealSize[0]) + ' requires approval.' ));
                if(isValidation)
                    return violations;
            }        
        } 
        System.debug('NKC debug minimumLimitsDiscountAndDealSize ['+minimumLimitsDiscountAndDealSize+']');
        //ELA
        if(quote.ELA__c && dq.ELA__c != 'Yes'){
            violations.add(new wrapperViolationSummary('ELA', getBooleanToStringValue(quote.ELA__c), 'Not Approved', 'ELA requires approval.' ));     
            if(isValidation)
                return violations;       
        }
        /*
//Pricing Model - Concurrent
if(quote.Pricing_Model__c == DealQualificationApprovalUtil.CONCURRENT && dq.Pricing_Model__c != DealQualificationApprovalUtil.CONCURRENT){
violations.add(new wrapperViolationSummary('Pricing Model', quote.Pricing_Model__c, dq.Pricing_Model__c, null ));
if(isValidation)
return violations; 
} 
*/      
        //Expiration Date        
        if(quote.Offering_Type__c != QuoteUtil.OFFERING_TYPE_CIC && quote.Expiration_Date__c != null && System.today().addDays(90) < quote.Expiration_Date__c
           && (dq.Expiration_Date__c == null || quote.Expiration_Date__c > dq.Expiration_Date__c)){
               violations.add(new wrapperViolationSummary('Expiration Date', String.valueOf(quote.Expiration_Date__c), String.valueOf(dq.Expiration_Date__c), 'Extended expiry date requires approval.' ));
               if(isValidation)
                   return violations; 
           }
        //CIC Expiration Date        
        if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC && quote.Expiration_Date__c != null && System.today().addDays(60) < quote.Expiration_Date__c
           && (dq.Expiration_Date__c == null || quote.Expiration_Date__c > dq.Expiration_Date__c)){
               violations.add(new wrapperViolationSummary('Expiration Date', String.valueOf(quote.Expiration_Date__c), String.valueOf(dq.Expiration_Date__c), 'Extended expiry date requires approval.' ));
               if(isValidation)
                   return violations; 
           }
        
        //Mukunth added on 07-JUN-2019 for INC0419391
        list<string> paOffTypes = ((Global_Setting__c.getValues('Payment Terms Approval')).Information__c).split(';');
        if((paOffTypes.contains(quote.Offering_Type__c) || paOffTypes.contains(QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE)) && quote.Order_Payment_Terms__c != null){
            Integer quotePaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            integer dqPaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            if(quotePaymentTerm >= 45 && quotePaymentTerm > dqPaymentTerm){// && quotePaymentTerm > dqPaymentTerm)
                violations.add(new wrapperViolationSummary('Payment Term', quote.Order_Payment_Terms__c, dq.Payment_Terms__c == null ? 'Not Approved' : dq.Payment_Terms__c, ' >= Net 45 requires approval.' ));
                if(isValidation)
                    return violations;    
            }
        }
        //Mukunth code end
        
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            String description = 'Special offer requires approval. ';
            if(dq.Special_Offers_Business_Exceptions__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                description += 'There is difference in offer term.';
            violations.add(new wrapperViolationSummary('Special Offer Terms', getBooleanToStringValue(quote.Include_Special_Offer_in_Output__c), getBooleanToStringValue(dq.Special_Offer_Terms__c), description ));
            if(isValidation)
                return violations; 
        }        
        //Care Override > 3%
        if(!quote.PPU_Rental__c && !quote.Don_t_Fire_Genesys_Care_Approval__c && quote.Genesys_Care_Rate__c != null
           && quote.Genesys_Care_Default_Pricing_Percentage__c != null
           && ((quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c) > 3 )
           && (dq.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE)){
               violations.add(new wrapperViolationSummary('Care Override > 3%', String.valueOf(quote.Genesys_Care_Rate__c) + '%', dq.GC_Override__c == null ? 'Not Approved' : dq.GC_Override__c, 'Genesys Care Override > 3 requires approval.' ));
               if(isValidation)
                   return violations; 
           } 
        //Care Override 2 - 3%
        else if(!quote.PPU_Rental__c && !quote.Don_t_Fire_Genesys_Care_Approval__c && quote.Genesys_Care_Rate__c != null
                && quote.Genesys_Care_Default_Pricing_Percentage__c != null
                && (quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c) >= 2
                && (dq.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE && dq.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE)){
                    violations.add(new wrapperViolationSummary('Care Override 2 - 3%', String.valueOf(quote.Genesys_Care_Rate__c) + '%', getBooleanToStringValue(dq.Override_2__c), 'Genesys Care Override >=2 requires approval.' ));
                    if(isValidation)
                        return violations; 
                }
        //Care Override < 2%
        else if(!quote.PPU_Rental__c && !quote.Don_t_Fire_Genesys_Care_Approval__c && quote.Genesys_Care_Rate__c != null
                && quote.Genesys_Care_Default_Pricing_Percentage__c != null
                && (quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c) >= 1
                && (dq.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE && dq.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE && dq.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_LESS_THAN_TWO)){
                    violations.add(new wrapperViolationSummary('Care Override < 2%', String.valueOf(quote.Genesys_Care_Rate__c) + '%', getBooleanToStringValue(dq.Override_2__c), 'Genesys Care Override < 2 requires approval.' ));
                    if(isValidation)
                        return violations; 
                }
        //Deal Size Increased
        if(quote.BigMachines__Total__c != null ){
            String dealSizeRangeOnQuote = DealQualificationApprovalUtil.getDealSizePickListVal(Double.valueOf(quote.BigMachines__Total__c));
            System.debug('NKC debug dq.Net_Deal_Value__c ['+dq.Net_Deal_Value__c+']');
            Double dealSizeOnQuote = DealQualificationApprovalUtil.getDealSize(dealSizeRangeOnQuote);  
            Double dealSizeOnDQ = DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c);  
            System.debug('NKC debug dealSizeOnQuote ['+dealSizeOnQuote+']');
            System.debug('NKC debug dealSizeOnDQ ['+dealSizeOnDQ+']');
            Double totalQuoteUSD = DealQualificationApprovalUtil.convertCurrency(Double.valueOf(quote.BigMachines__Total__c), quote.CurrencyIsoCode);
            
            if(totalQuoteUSD >= minimumLimitsDiscountAndDealSize[1] && dealSizeOnQuote > dealSizeOnDQ){
                String description = '';
                if(DealQualificationApprovalUtil.getDealSizePickListVal(minimumLimitsDiscountAndDealSize[1]) != null){
                    description = ' > DAP threshold needs approval';
                } 
                violations.add(new wrapperViolationSummary('Deal Size', String.valueOf(Math.round(quote.BigMachines__Total__c)), dealSizeOnDQ == 0 ? 'Not Approved' : String.valueOf(Math.round(dealSizeOnDQ)), description));
                if(isValidation)
                    return violations; 
            }        
        }        
        //Deal Size Decreased
        if(quote.BigMachines__Total__c != null ){
            String dealSizeRangeOnQuote = DealQualificationApprovalUtil.getDealSizePickListVal(Double.valueOf(quote.BigMachines__Total__c));
            Double dealSizeOnQuote = DealQualificationApprovalUtil.getDealSize(dealSizeRangeOnQuote);  
            Double dealSizeOnDQ = DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c);  
            if(quote.BigMachines__Total__c  >= minimumLimitsDiscountAndDealSize[1] && dealSizeOnQuote < dealSizeOnDQ){
                violations.add(new wrapperViolationSummary('Deal Size', quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(quote.BigMachines__Total__c)), dealSizeOnDQ == 0 ? 'Not Approved' : quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(dealSizeOnDQ)), 'Decreasing of deal size requires approval.' ));
                if(isValidation)
                    return violations; 
            }        
        } 
        //Term Reduced
        if(!quote.PPU_Rental__c && quote.Duration_Unit__c != null
           && ((quote.Duration_Unit__c.equals('Days') && quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c < DealQualificationApprovalUtil.STANDARD_TERM_DAYS)
               || (quote.Duration_Unit__c.equals('Months') && quote.Order_Numb_of_Maint_Months__c != null && quote.Order_Numb_of_Maint_Months__c < DealQualificationApprovalUtil.STANDARD_TERM_MONTHS))
           && !dq.Term_Decrease__c){
               String duration;
               if(quote.Duration_Unit__c.equals('Days'))
                   duration = String.valueOf(quote.Order_Numb_of_Maint_Days__c) + ' Day(s)';
               else
                   duration = String.valueOf(quote.Order_Numb_of_Maint_Months__c) + ' Month(s)';
               violations.add(new wrapperViolationSummary('Care Term Reduced', duration, getBooleanToStringValue(dq.Term_Decrease__c), 'Reduced term requires approval.' ));
               if(isValidation)
                   return violations; 
           }
        //Term Increased
        if(!quote.PPU_Rental__c && quote.Duration_Unit__c != null
           && ((quote.Duration_Unit__c.equals('Days') && quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c > QuoteApprovalUtil.STANDARD_TERM_DAYS)
               || (quote.Duration_Unit__c.equals('Months') && quote.Order_Numb_of_Maint_Months__c != null && quote.Order_Numb_of_Maint_Months__c > QuoteApprovalUtil.STANDARD_TERM_MONTHS))
           && !dq.Term_Increase__c){
               String duration;
               if(quote.Duration_Unit__c.equals('Days'))
                   duration = String.valueOf(quote.Order_Numb_of_Maint_Days__c) + ' Day(s)';
               else
                   duration = String.valueOf(quote.Order_Numb_of_Maint_Months__c) + ' Month(s)';
               violations.add(new wrapperViolationSummary('Care Term Increased', duration, getBooleanToStringValue(dq.Term_Increase__c), 'Increased term requires approval.' ));
               if(isValidation)
                   return violations; 
           }
        //Service Level - Decline
        if(quote.Service_Level__c  != null
           && quote.Service_Level__c == DealQualificationApprovalUtil.DECLINE
           // && dq.Service_Level__c != DealQualificationApprovalUtil.DECLINE){    change by ankit on 11/04            
           && dq.Decline__c == false){
               violations.add(new wrapperViolationSummary('Genesys Care - Decline', quote.Service_Level__c, dq.Service_Level__c, '\'Decline\' Genesys Care requires approval.' ));
               if(isValidation)
                   return violations; 
           }
        //Support Option - No Support
        if(quote.GC_Decline__c && dq.Decline__c == false){
            violations.add(new wrapperViolationSummary('Genesys Care - Decline', 'No Support', 'Not Approved', '\'Decline\' Genesys Care requires approval.' ));
            if(isValidation)
                return violations; 
        }
        
        //CAD Override
        if(quote.CAD_Override__c 
           && !dq.CAD_Override__c){
               violations.add(new wrapperViolationSummary('CAD Override', getBooleanToStringValue(quote.CAD_Override__c), getBooleanToStringValue(dq.CAD_Override__c), 'Canadian Dollars Override requires approval.' ));     
               if(isValidation)
                   return violations; 
           }
        //Service Level - Premium
        if(quote.Service_Level__c  != null
           && quote.Service_Level__c == QuoteApprovalUtil.PREMIUM 
           && !dq.Premium_Care__c){                
               violations.add(new wrapperViolationSummary('Premium Care', quote.Service_Level__c, getBooleanToStringValue(dq.Premium_Care__c), 'Premium Care requires approval.' ));
               if(isValidation)
                   return violations; 
           }
        
        //Additional Legal Terms
        if(quote.Additional_Legal_Terms__c && !dq.Additional_Legal_Terms__c){
            violations.add(new wrapperViolationSummary('Additional Legal Terms', getBooleanToStringValue(quote.Additional_Legal_Terms__c), getBooleanToStringValue(dq.Additional_Legal_Terms__c), 'Additional Legal Terms requires approval.' ));  
            if(isValidation)
                return violations; 
        } 
        //Third Party Care Override
        if(quote.X3rd_Party_Override__c && !dq.X3rd_Party_Override__c){
            violations.add(new wrapperViolationSummary('Third Party Care Override', getBooleanToStringValue(quote.X3rd_Party_Override__c), getBooleanToStringValue(dq.X3rd_Party_Override__c), 'Third Party Care Override requires approval.' ));  
            if(isValidation)
                return violations;
        }
        //Old Pricing
        if(quote.Quote_Opportunity_Type__c == 'Old Pricing' && !dq.IsOldPricingApproved__c){
            violations.add(new wrapperViolationSummary('Old Pricing', 'Yes', 'Not Approved', 'Old Pricing requires approval.' ));  
            if(isValidation)
                return violations;
        }
        //Number of Months
        if(quote.No_Of_Months__c != null && dq.Term_Length__c != null && quote.No_Of_Months__c < dq.Term_Length__c){
            violations.add(new wrapperViolationSummary('Number Of Months', String.valueOf(Integer.valueOf(quote.No_Of_Months__c)), String.valueOf(dq.Term_Length__c), 'Number of months can not be less than Deal Qualification months. Please revise the Deal Qualification.' ));  
            if(isValidation)
                return violations;
        }  
        //Cloud Partner
        if(quote.Pricing_Model__c == 'PPU' && (quote.BigMachines__Opportunity__r.BusinessPartner__r.PartnerType__c == null || 
                                               !quote.BigMachines__Opportunity__r.BusinessPartner__r.PartnerType__c.contains('Cloud Solution Provider')) && !dq.Cloud_Partner_Approval__c){
                                                   violations.add(new wrapperViolationSummary('No Cloud Partner', 'No Cloud Partner', 'Not Approved', 'No Cloud Partner requires approval.' ));  
                                                   if(isValidation)
                                                       return violations;
                                               }
        //PPU Deal
        if(quote.Pricing_Model__c == 'PPU' && !dq.PPU_Deal_Approval__c){
            violations.add(new wrapperViolationSummary('PPU Deal', 'Yes', 'Not Approved', 'PPU Deal requires approval.' ));  
            if(isValidation)
                return violations;
        }
        //Finance Exceptions
        if(quote.Finance_Exceptions__c != null && quote.Finance_Exceptions__c != dq.Finance_Exception__c){
            String description = 'Finance exceptions requires approval';
            String quoteReason = 'Not Approved';
            if(dq.Finance_Exception__c != null){
                description = 'There is difference in the exceptions between quote and deal qualification.';        
                quoteReason = 'Approved, but different.';    
            }              
            violations.add(new wrapperViolationSummary('Finance Exceptions', 'Yes', quoteReason, description));      
        }
        //Legal Exceptions
        if(quote.Legal_Exceptions__c != null && quote.Legal_Exceptions__c != dq.Legal_Exceptions__c){
            String description = 'Legal exceptions requires approval';
            String quoteReason = 'Not Approved';
            if(dq.Finance_Exception__c != null){
                description = 'There is difference in the exceptions between quote and deal qualification.';        
                quoteReason = 'Approved, but different.';    
            }              
            violations.add(new wrapperViolationSummary('Legal Exceptions', 'Yes', quoteReason, description));      
        }          
        //Support Options
        if(dq.Support_Option__c == null
           && (quote.Support_Options__c == 'Priority Support' || quote.Support_Options__c == 'VIP Priority Support')){
               violations.add(new wrapperViolationSummary('Priority/VIP Priority Support', quote.Support_Options__c, 'Not Approved', 'Priority/VIP Priority Support requires approval.' ));  
               if(isValidation)
                   return violations;
           }
        //Carveout
        if(!dq.Carveout__c && quote.Carveout__c || dq.CarveOutDetails__c != quote.CarveOutDetails__c){
            String description = 'Carveout requires approval.';
            if(dq.CarveOutDetails__c != quote.CarveOutDetails__c)
                description = 'There is difference in carveout details.';
            violations.add(new wrapperViolationSummary('Carveout', 'Yes', 'Not Approved', description ));  
            if(isValidation)
                return violations;
        }
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            //BEP
            Decimal BEPDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-BEP');
            if(BEPDiscountOnQuote != null){
                Decimal BEPDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-BEP');
                if(BEPDiscountOnDQ == null || BEPDiscountOnDQ < BEPDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('BEP Override', 'Yes', 'Not Approved', 'BEP Override (Product : ' + eachQuoteProduct.BigMachines__Product__r.Description__c + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            }
            //GU
            Decimal GUDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-GU');
            if(GUDiscountOnQuote != null){
                Decimal GUDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-GU');
                if(GUDiscountOnDQ == null || GUDiscountOnDQ < GUDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('GU Override', 'Yes', 'Not Approved', 'GU Override (Product : ' + eachQuoteProduct.BigMachines__Product__r.Description__c + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            }
            //TP
            Decimal TPDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-TP');
            if(TPDiscountOnQuote != null){
                Decimal TPDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-TP');
                if(TPDiscountOnDQ == null || TPDiscountOnDQ < TPDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('Third Party Discount', 'Yes', 'Not Approved', 'Third Party Product (Product : ' + eachQuoteProduct.BigMachines__Product__r.Description__c + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            }
            //Product Specific Discount
            Decimal PSDiscountOnQuote = mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-PS');
            if(PSDiscountOnQuote != null){
                Decimal PSDiscountOnDQ = mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-PS');
                if(PSDiscountOnDQ == null || PSDiscountOnDQ < PSDiscountOnQuote){
                    violations.add(new wrapperViolationSummary('Product Specific Discount', 'Yes', 'Not Approved', 'Product Specific Discount (Product : ' + eachQuoteProduct.BigMachines__Product__r.Description__c + ') requires approval.' ));  
                    if(isValidation)
                        return violations;  
                }
            }
            //PM Approval          
            if(mapQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-PM') != null && mapDQProductOverrideVsDiscount.get(eachQuoteProduct.BigMachines__Product__c + '-PM') == null){
                violations.add(new wrapperViolationSummary('PM Approval', 'Yes', 'Not Approved', 'Product : ' + eachQuoteProduct.BigMachines__Product__r.Description__c + ' requires PM approval.' ));  
                if(isValidation)
                    return violations;
            }  
        }
        
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c && !dq.Editable_List_Price_Approval_Required__c){
            violations.add(new wrapperViolationSummary('Editable List Price',getBooleanToStringValue(quote.Editable_List_Price_Approval_Required__c ) , 'Not Approved', 'Editable List Price requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        //Rental list price
        if(quote.PPU_Rental__c && !dq.Rental__c){
            violations.add(new wrapperViolationSummary('Rental Quote',getBooleanToStringValue(quote.PPU_Rental__c ) , 'Not Approved', 'Rental Quote requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        
        showDealScoreViolation(quote, dq, violations);
        
        //Conversion Quote
        if(quote.Conversion_Quote__c != null && dq.Conversion_Quote__c == null){
            violations.add(new wrapperViolationSummary('Conversion Quote', quote.Conversion_Quote__c, dq.Conversion_Quote__c == null ? 'Not Approved' : dq.Conversion_Quote__c, 'Conversion quote requires approval.'));
            if(isValidation)
                return violations;    
        }
        
        //Contractual Rate
        if(quote.Require_Contractual_Discount__c && !dq.Contractual_Rate_Approval__c){
            violations.add(new wrapperViolationSummary('Contractual Rate',getBooleanToStringValue(quote.Require_Contractual_Discount__c ) , 'Not Approved', 'Contractual Rate requires approval.' ));  
            if(isValidation)
                return violations;    
        }
        
        return violations;        
    }
    
    private static void showDealScoreViolation(BigMachines__Quote__c quote, Deal_Qualification__c dq, List<wrapperViolationSummary> violations ){
        //Deal Score
        if(quote.Total_Software__c != null && quote.Deal_Score__c != null && quote.Quote_Opportunity_Type__c != 'Old Pricing' 
           && quote.Amendment_For__c == null && quote.Conversion_Quote__c == null){
               String dealSizeRangeOnQuote = DealQualificationApprovalUtil.getDealScoreSizePickListVal(Double.valueOf(quote.Total_Software__c));
               Double dealSizeOnQuote = DealQualificationApprovalUtil.getDealSize(dealSizeRangeOnQuote);  
               Double dealSizeOnDQ = DealQualificationApprovalUtil.getDealSize(dq.Deal_Score_Size__c);
               Double dealScoreOnQuote = quote.Deal_Score__c == null ? 0 : quote.Deal_Score__c;
               Double dealScoreOnDQ = dq.Deal_Score__c == null ? 0 : dq.Deal_Score__c;
               
               System.debug('NKC debug dealSizeOnQuote [' + dealSizeOnQuote + ']');
               System.debug('NKC debug dealSizeOnDQ [' + dealSizeOnDQ + ']');
               System.debug('NKC debug dealScoreOnQuote [' + dealScoreOnQuote + ']');
               System.debug('NKC debug dealScoreOnDQ [' + dealScoreOnDQ + ']');
               Boolean blnDealScoreApprovalFired = false;
               if((quote.Offering_Type__c != 'PureConnect On Premise' || (quote.Offering_Type__c == 'PureConnect On Premise' && quote.End_User_ID__c == quote.Sold_To_Name__c)
                   || (quote.Offering_Type__c == 'PureConnect On Premise' && quote.End_User_ID__c != quote.Sold_To_Name__c && quote.Total_Discount__c > 0))
                  && dealScoreOnDQ == 0 && ((dealSizeOnQuote <= 50000 && dealScoreOnQuote <= 2) 
                                            || (dealSizeOnQuote > 50000 && dealSizeOnQuote <= 250000 && dealScoreOnQuote <= 3)
                                            || (dealSizeOnQuote > 250000 && dealSizeOnQuote <= 750000 && dealScoreOnQuote <= 4)
                                            || (dealSizeOnQuote > 750000 && dealSizeOnQuote <= 2000000 && dealScoreOnQuote <= 5)                                      
                                            || (dealSizeOnQuote > 2000000))){
                                                violations.add(new wrapperViolationSummary('Deal Score', 'Deal Size - ' + quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(quote.Total_Software__c)), dealSizeOnDQ == 0 ? 'Not Approved' : quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(dealSizeOnDQ)), 'Deal score requires approval.' ));
                                                blnDealScoreApprovalFired = true;
                                            }      
               //Has DDS moved 1 or + grades down
               if(!blnDealScoreApprovalFired && dealScoreOnDQ > dealScoreOnQuote){
                   violations.add(new wrapperViolationSummary('Deal Score',  quote.Deal_Score__c == null ? '' : String.valueOf(quote.Deal_Score__c), dq.Deal_Score__c == null ? 'Not Approved' : String.valueOf(dq.Deal_Score__c), 'Deal score change requires approval.'));
                   blnDealScoreApprovalFired = true;  
               }
               //Is prior DDS approved equal to 4 or 5?
               if(!blnDealScoreApprovalFired && (dealScoreOnDQ == 1 || dealScoreOnDQ == 2) && dq.Net_Deal_Size_Amount__c != null){                
                   Decimal decDifference = quote.Total_Software__c - dq.Net_Deal_Size_Amount__c;
                   System.debug('NKC debug decDifference [' + decDifference +']');
                   Decimal decDiffPercentage = 0;
                   if(dq.Net_Deal_Size_Amount__c != null && dq.Net_Deal_Size_Amount__c > 0)
                       decDiffPercentage = (decDifference * 100) / dq.Net_Deal_Size_Amount__c;
                   //Has net deal value oscillated by 10% + of original approval
                   if(decDiffPercentage > 10 || decDiffPercentage < -10){
                       violations.add(new wrapperViolationSummary('Deal Score', quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(quote.Total_Software__c)), dealSizeOnDQ == 0 ? 'Not Approved' : quote.CurrencyIsoCode + ' ' + String.valueOf(Math.round(dq.Net_Deal_Size_Amount__c)), 'Deal score size changed by more than -10% or +10%.' ));
                       blnDealScoreApprovalFired = true;      
                   }
               }
               
               //Have *deal chacacteristics been modified and are non standard?
               //if(){
               
               //}
           }
    }
    
    public static void insertUpdateViolations(String quoteId){
        //Getting quote
        BigMachines__Quote__c quote = QuoteApprovalUtil.getQuote(quoteId);
        //Deal Qualification    
        List<Deal_Qualification__c> dqHistory = DealQualificationApprovalUtil.getDQ(quote.BigMachines__Opportunity__c, 
                                                                                    quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, 
                                                                                    quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_HISTORY);
        List<wrapperViolationSummary> violations = new List<wrapperViolationSummary>();  
        if(!dqHistory.isEmpty())
            violations = checkApprovals(quote, dqHistory[0], false);
        
        List<Quote_Approval_Violation__c> existingViolations = [SELECT Approval_Type__c FROM Quote_Approval_Violation__c 
                                                                WHERE Quote__c =: quoteId];
        Set<String> setOfApprovalTypes = new Set<String>();
        for(Quote_Approval_Violation__c eachViolation : existingViolations)
            setOfApprovalTypes.add(eachViolation.Approval_Type__c);
        List<Quote_Approval_Violation__c> violationsToBeInserted = new List<Quote_Approval_Violation__c>();
        for(wrapperViolationSummary eachViolation : violations){
            if(!setOfApprovalTypes.contains(eachViolation.approvalName)){
                Quote_Approval_Violation__c newViolation = new Quote_Approval_Violation__c();
                newViolation.Quote__c = quoteId;
                //newViolation.Deal_Qualification__c = dqId;        
                newViolation.Quote_Value__c = eachViolation.fieldValueOnQuote;
                newViolation.Deal_Qualification_Value__c = eachViolation.fieldValueApproved;
                newViolation.Approval_Type__c = eachViolation.approvalName;
                newViolation.Description__c = eachViolation.Description;
                violationsToBeInserted.add(newViolation);          
            }
        }
        insert violationsToBeInserted;
    }
    
    public static String synchDQ(String quoteId, String oppId){
        BigMachines__Quote__c quote = QuoteApprovalUtil.getQuote(quoteId); 
        System.debug('NKC debug oppId [' + oppId +']');
        System.debug('NKC debug quote.Quote_Opportunity_Type__c [' + quote.Quote_Opportunity_Type__c +']');
        System.debug('NKC debug quote.Offering_Type__c [' + quote.Offering_Type__c +']');      
        System.debug('NKC debug quote.Quote_Business_Type__c [' + quote.Quote_Business_Type__c +']');
        String dqStatus; 
        if(quote.Offering_Type__c == 'Business Edition'){
            dqStatus = synchDQCloudBE(quote , oppId);
        }
        else if(quote.Offering_Type__c == 'PureCloud'){
            dqStatus = synchDQPC(quote , oppId);
        }
        else if(quote.Offering_Type__c == 'PureConnect Cloud'){
            dqStatus = synchDQPCC(quote , oppId);
        }
        else if(quote.Offering_Type__c == 'PureEngage Cloud'){
            dqStatus = synchDQPEC(quote , oppId);
        }
        else{
            dqStatus = synchDQOnPremise(quote , oppId);
        }
        return dqStatus;
    }
    //added by kartik
    public static String synchDQPEC(BigMachines__Quote__c quote, String oppId){
        String quoteId = quote.id;
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
        Boolean blnisCreditInvolved = false;
        Boolean blnisCreditIncreased = false;
        //Amend Check
        Boolean blnDiscountDQReq = false;
        Boolean blnOverageDQReq = false;
        Boolean blnBaseAgentDiscountDQReq = false;
        Boolean blnHardwareDiscountDQReq = false;
        Boolean blnDataCenterProvisioningDiscountDQReq = false;
        Boolean blnBusinessUsersAddonDiscountDQReq = false;
        Boolean blnThirdPartyDiscountDQReq = false;
        List<BigMachines__Quote_Product__c> quoteProductsWhichRequiresApproval = new List<BigMachines__Quote_Product__c>();
        Boolean isThirdPartyProduct = false;  
        Map<Id, String> mapProductIdVsReason = new Map<Id, String>();
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            //Amend check
            if(qrpc.BigMachines__Product__r.New_Category__c == 'Credit')
                blnisCreditInvolved = true;
            if((qrpc.Subscription_Product__c ==  null && qrpc.Total_Discount__c > 0) || (qrpc.Subscription_Product__c != null && qrpc.Total_Discount__c > (qrpc.Subscription_Product__r.Total_Discount__c == null ? 0 : qrpc.Subscription_Product__r.Total_Discount__c.setscale(2)))) {
                if(qrpc.Is_Overage__c)
                    blnOverageDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Base Agent')
                    blnBaseAgentDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Hardware')
                    blnHardwareDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Data Center Provisioning')
                    blnDataCenterProvisioningDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Business Users & Add-On Functionality')
                    blnBusinessUsersAddonDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.Third_Party__c == 'True')
                    blnThirdPartyDiscountDQReq = true;
                blnDiscountDQReq = true;
                
                
                if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
                   && qrpc.Total_Discount__c != null
                   && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c){
                       quoteProductsWhichRequiresApproval.add(qrpc);
                       mapProductIdVsReason.put(qrpc.BigMachines__Product__c, 'Product Specific Discount');
                   } 
            }
            if(qrpc.Subscription_Product__c !=  null && qrpc.BigMachines__Product__r.New_Category__c == 'Credit' && qrpc.BigMachines__Quantity__c > qrpc.Subscription_Product__r.quantity__c) 
                blnisCreditIncreased = true;  
            
        }
        
        Deal_Qualification__c dq;
        if(dqs.isEmpty()){
            dq = new Deal_Qualification__c();
            dq.Opportunity__c = oppId;
            dq.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
            dq.currencyIsoCode = quote.currencyIsoCode;
            dq.Platform_Type__c = quote.Quote_Business_Type__c; 
            if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC)
                dq.Expiration_Date__c = System.today().addYears(1);  
            dq.Offering_Type__c = (quote.Offering_Type__c == null ? QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE : quote.Offering_Type__c);                    
        }
        else{
            dq = dqs[0];
        }  
        
        //Deal Score Cloud  
        dq.Deal_Score__c = null;
        //Mukunth added Mega Deal check for DDSCloud
        if(!isMegaDealbln){
            if(!quote.Order_Type__c.contains('Amend')){
                dq.Deal_Score__c = quote.Deal_Score__c;
            }
        }
        
        //PCC Credit-Rony Joseph-April 17th 2019-PCC Credit Reset - Begin
        System.debug('Inside DQ Sync for PCC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased+'quote.Migration_credit__c:'+quote.Migration_credit__c+'dq.Migration_Credit__c:'+dq.Migration_Credit__c);
        dq.PureCloud_Credit_Applied__c = false;
        if((!quote.Order_Type__c.contains('Amend') && dq.PureCloud_Credit_Applied__c == false && ( (quote.Migration_credit__c != null && dq.Migration_Credit__c !=null && quote.Migration_credit__c != dq.Migration_Credit__c)) && blnisCreditInvolved)
           || (quote.Order_Type__c.contains('Amend') && dq.PureCloud_Credit_Applied__c == false && blnisCreditInvolved && (blnisCreditIncreased || (quote.Migration_credit__c != null && dq.Migration_Credit__c !=null && quote.Migration_credit__c != dq.Migration_Credit__c)))){
               dq.PureCloud_Credit_Applied__c = true; 
               dq.Migration_Credit__c = quote.Migration_credit__c;
           }
        //PCC Credit-Rony Joseph-April 17th 2019-PCC Credit Reset - End
        
        
        
        
        
        
        
        
        
        
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c != dq.Editable_List_Price_Approval_Required__c){
            dq.Editable_List_Price_Approval_Required__c = quote.Editable_List_Price_Approval_Required__c;
        }
        //Special Offer Terms
        dq.Special_Offers_Business_Exceptions__c = null;
        dq.Special_Offer_Terms__c = false;
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            
            dq.Special_Offer_Terms__c = true;
            if(quote.Special_Offer_Terms__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                dq.Special_Offers_Business_Exceptions__c = quote.Special_Offer_Terms__c;
        } 
        
        //Initial Subscription Term
        dq.If_Other_Term_Months_Requested__c = null; 
        dq.Initial_Subscription_Term_Months_PC__c = null;                   
        if(quote.No_Of_Months__c != null ){
            Decimal termMonths = quote.No_Of_Months__c.setScale(2, RoundingMode.HALF_UP);
            Decimal termMonthsOnDQ = DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c);
            //Amend
            Integer decAmendtermMonths = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Term__c != null){                
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Month'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Month'));
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Year'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Year')) * 12; 
                //termMonths = decAmendtermMonths > termMonths ? decAmendtermMonths : termMonths;
            }
            if(termMonths > 36 && termMonths > termMonthsOnDQ && termMonths > decAmendtermMonths){  
                if(termMonths  <= 60)
                    dq.Initial_Subscription_Term_Months_PC__c = String.valueof(Integer.valueof(termMonths));
                else{
                    dq.If_Other_Term_Months_Requested__c = quote.No_Of_Months__c;
                    dq.Initial_Subscription_Term_Months_PC__c = 'Other';
                }
                
            }        
        }
        
        //Ramp Period
        dq.If_Other_Ramp_Period_Requested_Days__c = null;
        dq.Ramp_Period_Days__c = null;
        if(!quote.Order_Type__c.contains('Amend') && quote.Ramp_Period__c != null && quote.Ramp_Period__c != 'Other'){
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            Decimal rampPeriod = Decimal.valueof(strRampPeriod).setScale(2, RoundingMode.HALF_UP);
            Decimal rampPeriodOnDQ = DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c);
            if(rampPeriod > 180 && rampPeriod > rampPeriodOnDQ ){  
                if(rampPeriod <= 365 || quote.Ramp_Period__c == 'Other')
                    dq.Ramp_Period_Days__c = String.valueof(strRampPeriod);
                else{            
                    dq.If_Other_Ramp_Period_Requested_Days__c = Decimal.valueof(quote.Ramp_Period__c);
                    dq.Ramp_Period_Days__c = 'Other';
                }
            }        
        } 
        
        //Payment Terms
        //dq.Payment_Terms__c = null;
        if(quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            system.debug('====>QuotePaymentTerm'+PaymentTerm);
            system.debug('====>PaymentTermOnDQ'+PaymentTermOnDQ);
            //Amend
            Decimal PaymentTermAmend = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Payment_Term__c != null){
                PaymentTermAmend = DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c) > PaymentTerm ? DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c):PaymentTerm;
            }
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ && PaymentTerm > PaymentTermAmend){              
                dq.Payment_Terms__c = quote.Order_Payment_Terms__c;
            }        
        }
        
        
        
        
        //Billing Period
        dq.Billing_Period__c = null;
        if(quote.Billing_Period__c != null && quote.Billing_Period__c != 'Other'){
            Decimal billingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Billing_Period__c);
            Decimal billingPeriodOnDQ = DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c);
            //Amend
            Decimal decBillingPeriod = billingPeriod;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Billing_Period__c != null)                
                decBillingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Amendment_For__r.Billing_Period__c);
            if(!quote.Order_Type__c.contains('Amend'))
                decBillingPeriod = 0;
            if(billingPeriod > 0 && billingPeriod != billingPeriodOnDQ && billingPeriod != decBillingPeriod){                         
                dq.Billing_Period__c = quote.Billing_Period__c;
            }        
        }
        
        
        
        
        
        //Burst %
        dq.Overage_Allowance__c = quote.Overage_Allowance__c;
        dq.Overage_Allowance_Other__c = null;
        
        //PC Overage Discount     
        dq.Overage_Discount__c = null; 
        if((blnOverageDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Overage_Discount__c != null){
            
            if(quote.Overage_Discount__c > 0 && (quote.Overage_Discount__c.setScale(2) > dq.Overage_Discount__c || dq.Overage_Discount__c ==  null)){              
                dq.Overage_Discount__c = quote.Overage_Discount__c.setScale(2);
            }        
        }
        //Annual Price Escalator
        dq.Price_Escalation__c = quote.Price_Escalation__c;
        dq.Annual_Price_Escalation_Other__c = null;
        
        
        
        
        //Deal size
        Decimal decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        //dq.Net_Deal_Value__c = String.valueof(decUSDACV);
        dq.Net_Deal_Size_Amount__c = null;
        if(!quote.Order_Type__c.contains('Amend'))
            dq.Net_Deal_Size_Amount__c = decUSDACV;
        dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(decUSDACV);
        
        dq.Quote__c = quote.Id; 
        system.debug('dq'+dq);
        upsert dq;
        system.debug('dqafter'+dq);
        List<Deal_Qualification_Products__c> dqProductsToBeDeleted = DealQualificationApprovalUtil.getDQProducts(dq.id);
        if(!dqProductsToBeDeleted.isEmpty())
            delete dqProductsToBeDeleted;
        if(quoteProductsWhichRequiresApproval.isEmpty()){          
            return dq.Status__c;
        }
        List<Deal_Qualification_Products__c> dqProductsToBeUpserted = new List<Deal_Qualification_Products__c> ();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWhichRequiresApproval){
            Deal_Qualification_Products__c newDQProduct = new Deal_Qualification_Products__c();
            newDQProduct.Deal_Qualification__c = dq.id;
            newDQProduct.Product__c = eachQuoteProduct.BigMachines__Product__c;
            newDQProduct.Discount__c =   eachQuoteProduct.Total_Discount__c;
            newDQProduct.Quantity__c = eachQuoteProduct.BigMachines__Quantity__c;
            newDQProduct.Approval_Reason__c = mapProductIdVsReason.get(eachQuoteProduct.BigMachines__Product__c);
            dqProductsToBeUpserted.add(newDQProduct);      
        } 
        system.debug('dqProductsToBeUpserted'+dqProductsToBeUpserted);
        if(!dqProductsToBeUpserted.isEmpty())
            insert dqProductsToBeUpserted;
        return dq.Status__c;
        
    }
    public static String synchDQCloudBE(BigMachines__Quote__c quote, String oppId){
        String quoteId = quote.id;      
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        System.debug('NKC debug dqs [' + dqs + ']');
        Deal_Qualification__c dq;
        if(dqs.isEmpty()){
            dq = new Deal_Qualification__c();
            dq.Opportunity__c = oppId;
            dq.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
            dq.currencyIsoCode = quote.currencyIsoCode;
            dq.Offering_Type__c = quote.Offering_Type__c;
            dq.Platform_Type__c = 'Cloud';
        }
        else{
            dq = dqs[0];
        }      
        
        //Deal size
        Decimal decUSDACV  = 0;
        if(!Test.isRunningTest()) {
            decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,'null',quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        }
        dq.Net_Deal_Size_Amount__c = decUSDACV;
        dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(decUSDACV);
        //dq.Net_Deal_Value__c = String.valueof(decUSDACV);
        //Deal Score Cloud
        
        //Mukunth added for DDS Mega Deal
        if(!isMegaDealbln)
            dq.Deal_Score__c = quote.Deal_Score__c;
        
        dq.Discount_On_Quote__c = null;
        dq.New_Pricing_Discount__c = null;
        //Discount
        if(quote.Total_Discount_Genesys_Products_Only__c != null ){
            Integer roundNear = 5;
            Double discountOnQuote = Double.valueOf(quote.Total_Discount_Genesys_Products_Only__c);
            dq.Discount_On_Quote__c = Decimal.valueOf(discountOnQuote);//.setScale(1);
            if(discountOnQuote <= 0)
                dq.New_Pricing_Discount__c = 'No Discount';
            else
                dq.New_Pricing_Discount__c = DealQualificationApprovalUtil.getDiscountSizePickListVal(discountOnQuote, dq.Pricing_Type__c);              
            
        }
        //Special Offer Terms
        
        if(quote.Include_Special_Offer_in_Output__c != dq.Special_Offer_Terms__c){
            dq.Special_Offer_Terms__c = quote.Include_Special_Offer_in_Output__c;
        }
        //Special Offer term conditions (comments)
        if(quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c){
            dq.Special_Offers_Business_Exceptions__c = quote.Special_Offer_Terms__c;
        }
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c != dq.Editable_List_Price_Approval_Required__c){
            dq.Editable_List_Price_Approval_Required__c = quote.Editable_List_Price_Approval_Required__c;
        }
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quoteId);
        List<BigMachines__Quote_Product__c> quoteProductsWhichRequiresApproval = new List<BigMachines__Quote_Product__c>();
        Boolean isThirdPartyProduct = false;  
        Map<Id, String> mapProductIdVsReason = new Map<Id, String>();  
        //Looping over each quote product record to update above flags
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            if(eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c != null
               && eachQuoteProduct.Total_Discount__c != null
               && eachQuoteProduct.Total_Discount__c > eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c){
                   quoteProductsWhichRequiresApproval.add(eachQuoteProduct);
                   mapProductIdVsReason.put(eachQuoteProduct.BigMachines__Product__c, 'Product Specific Discount');
               } 
            
        }
        dq.Quote__c = quote.Id; 
        upsert dq; 
        List<Deal_Qualification_Products__c> dqProductsToBeDeleted = DealQualificationApprovalUtil.getDQProducts(dq.id);
        if(!dqProductsToBeDeleted.isEmpty())
            delete dqProductsToBeDeleted;
        if(quoteProductsWhichRequiresApproval.isEmpty()){          
            return dq.Status__c;
        }
        List<Deal_Qualification_Products__c> dqProductsToBeUpserted = new List<Deal_Qualification_Products__c> ();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWhichRequiresApproval){
            Deal_Qualification_Products__c newDQProduct = new Deal_Qualification_Products__c();
            newDQProduct.Deal_Qualification__c = dq.id;
            newDQProduct.Product__c = eachQuoteProduct.BigMachines__Product__c;
            newDQProduct.Discount__c =   eachQuoteProduct.Total_Discount__c;
            newDQProduct.Quantity__c = eachQuoteProduct.BigMachines__Quantity__c;
            newDQProduct.Approval_Reason__c = mapProductIdVsReason.get(eachQuoteProduct.BigMachines__Product__c);
            dqProductsToBeUpserted.add(newDQProduct);      
        }    
        if(!dqProductsToBeUpserted.isEmpty())
            insert dqProductsToBeUpserted;     
        return dq.Status__c;
    }
    
    public static String synchDQOnPremise(BigMachines__Quote__c quote, String oppId){
        String quoteId = quote.id;
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        
        Deal_Qualification__c dq;
        if(dqs.isEmpty()){
            dq = new Deal_Qualification__c();
            dq.Opportunity__c = oppId;
            dq.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
            dq.currencyIsoCode = quote.currencyIsoCode;
            dq.Platform_Type__c = quote.Quote_Business_Type__c; 
            if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC)
                dq.Expiration_Date__c = System.today().addYears(1);  
            dq.Offering_Type__c = (quote.Offering_Type__c == null ? QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE : quote.Offering_Type__c);                    
        }
        else{
            dq = dqs[0];
        }      
        
        //Discount
        if(quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription'){
            //Base Package Discount
            if(quote.Base_Agent_Discount__c != null){
                if(quote.Base_Agent_Discount__c <= 0)
                    dq.Discount_Base_Package__c = 'No Discount';
                else
                    dq.Discount_Base_Package__c = DealQualificationApprovalUtil.getDiscountSizePickListVal(Double.valueOf(quote.Base_Agent_Discount__c), 'New Pricing');        
            }
            //Non Base Package Discount            
            if(quote.Discount__c != null){
                if(quote.Discount__c <= 0)
                    dq.New_Pricing_Discount__c = 'No Discount';
                else
                    dq.New_Pricing_Discount__c = DealQualificationApprovalUtil.getDiscountSizePickListVal(Double.valueOf(quote.Discount__c), 'New Pricing');    
            }
            //Annual Price Escalator
            if(dq.Price_Escalation__c != 'Other'){
                dq.Price_Escalation__c = quote.Price_Escalation__c;
            }
            //Overage Allowance
            if(dq.Overage_Allowance__c != 'Other'){
                dq.Overage_Allowance__c = quote.Overage_Allowance__c;
            }
            //Payment Term
            if(dq.Payment_Terms__c != quote.Order_Payment_Terms__c)
                dq.Payment_Terms__c = quote.Order_Payment_Terms__c;
            
        }
        else if(quote.Total_Discount_Genesys_Products_Only__c != null ){
            Integer roundNear = 5;
            Double discountOnQuote = Double.valueOf(quote.Total_Discount_Genesys_Products_Only__c);
            dq.Discount_On_Quote__c = discountOnQuote;
            System.debug('NKC debug discountOnQuote [' + discountOnQuote + ']');
            if(discountOnQuote <= 0)
                dq.New_Pricing_Discount__c = 'No Discount';
            else
                dq.New_Pricing_Discount__c = DealQualificationApprovalUtil.getDiscountSizePickListVal(discountOnQuote, dq.Pricing_Type__c);              
        }      
        //ELA 
        if(quote.ELA__c && dq.ELA__c != 'Yes'){
            dq.ELA__c = 'Yes';
        }
        else if(!quote.ELA__c && dq.ELA__c == 'Yes'){
            dq.ELA__c = 'No';
        }
        
        //Pricing Model - Concurrent
        if(quote.Pricing_Model__c != dq.Pricing_Model__c){
            dq.Pricing_Model__c = quote.Pricing_Model__c;
        }
        //Expiration Date        
        if(quote.Expiration_Date__c != null && (dq.Expiration_Date__c == null || quote.Expiration_Date__c > dq.Expiration_Date__c)){
            dq.Expiration_Date__c  = quote.Expiration_Date__c;
        }
        //Term Length
        dq.Term_Length__c = quote.No_Of_Months__c;
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c != dq.Special_Offer_Terms__c){
            dq.Special_Offer_Terms__c = quote.Include_Special_Offer_in_Output__c ;          
        }
        if(quote.Include_Special_Offer_in_Output__c && dq.Special_Offers_Business_Exceptions__c != quote.Special_Offer_Terms__c){
            dq.Special_Offers_Business_Exceptions__c = quote.Special_Offer_Terms__c;
        }
        //Care Override > 3%
        if(!quote.PPU_Rental__c && quote.Genesys_Care_Rate__c != null
           && quote.Genesys_Care_Default_Pricing_Percentage__c != null){
               Decimal careOverride = quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c;
               if(careOverride <= 0)
                   dq.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_NO_OVERRIDE;
               else if(careOverride < 2)
                   dq.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_LESS_THAN_TWO;
               else if(careOverride >= 2 && careOverride <= 3)
                   dq.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE;
               else if(careOverride > 3)
                   dq.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE;
               if(careOverride >= 0)
                   dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;          
           }
        /*
if(quote.Support_Options__c == 'Standard Support'){
dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_STANDARD;                               
}
*/
        //Deal Size
        if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC && quote.Total_List_Price__c != null){
            dq.What_is_total_list_price__c = DealQualificationApprovalUtil.getDealSizePickListVal(quote.Total_List_Price__c, QuoteUtil.OFFERING_TYPE_CIC);
            dq.Net_Deal_Value__c = dq.What_is_total_list_price__c;
        }
        else if(quote.Pricing_Model__c == 'PPU' && quote.Annual_Contract_Value__c != null){
            dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(quote.Annual_Contract_Value__c);
        }
        else{
            if(quote.BigMachines__Total__c != null)
                dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(quote.BigMachines__Total__c);
            if(quote.Total_List_Price__c != null)
                dq.What_is_total_list_price__c = DealQualificationApprovalUtil.getDealSizePickListVal(quote.Total_List_Price__c, QuoteUtil.OFFERING_TYPE_CIC);
        } 
        //Term Reduced
        if(!quote.PPU_Rental__c && quote.Duration_Unit__c != null
           && ((quote.Duration_Unit__c.equals('Days') && quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c < DealQualificationApprovalUtil.STANDARD_TERM_DAYS)
               || (quote.Duration_Unit__c.equals('Months') && quote.Order_Numb_of_Maint_Months__c != null && quote.Order_Numb_of_Maint_Months__c < DealQualificationApprovalUtil.STANDARD_TERM_MONTHS))){
                   dq.Term_Decrease__c = true;
                   dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;
               }
        else{
            dq.Term_Decrease__c = false;
        }
        //Term Increased
        if(!quote.PPU_Rental__c && quote.Duration_Unit__c != null
           && ((quote.Duration_Unit__c.equals('Days') && quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c > QuoteApprovalUtil.STANDARD_TERM_DAYS)
               || (quote.Duration_Unit__c.equals('Months') && quote.Order_Numb_of_Maint_Months__c != null && quote.Order_Numb_of_Maint_Months__c > QuoteApprovalUtil.STANDARD_TERM_MONTHS))){
                   dq.Term_Increase__c = true;
                   dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;    
               }
        else{
            dq.Term_Increase__c = false;
        }
        //Service Level - Decline
        if(quote.Service_Level__c != null
           && quote.Service_Level__c == DealQualificationApprovalUtil.DECLINE
           && !dq.Decline__c){ 
               dq.Decline__c = true;
               dq.Service_Level__c = quote.Service_Level__c;
               dq.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_NO_OVERRIDE;
               dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;
           }
        else if(quote.Service_Level__c != null
                && quote.Service_Level__c != DealQualificationApprovalUtil.DECLINE
                && dq.Decline__c){
                    dq.Decline__c = false;
                } 
        //No Support
        if(quote.GC_Decline__c && !dq.Decline__c){ 
            dq.Decline__c = true;
            dq.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_NO_OVERRIDE;
            dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;
        }
        else if(!quote.GC_Decline__c && dq.Decline__c){
            dq.Decline__c = false;
        }
        //CAD Override
        if(quote.CAD_Override__c != dq.CAD_Override__c){
            dq.CAD_Override__c = quote.CAD_Override__c;
        }
        //Service Level - Premium
        if(quote.Service_Level__c  != null
           && quote.Service_Level__c == QuoteApprovalUtil.PREMIUM){  
               dq.Premium_Care__c = true;
               dq.Genesys_Care__c = DealQualificationApprovalUtil.GENESYS_CARE_NONSTANDARD;
           }
        else{
            dq.Premium_Care__c = false;
        }
        //Third Party Override
        if(quote.X3rd_Party_Override__c != dq.X3rd_Party_Override__c){
            dq.X3rd_Party_Override__c = quote.X3rd_Party_Override__c;
        }
        //Require Seperate Quote For Genesys Care
        if(quote.Require_Separate_Quote_for_Genesys_Care__c != dq.Require_Separate_Quote_for_Genesys_Care__c){
            dq.Require_Separate_Quote_for_Genesys_Care__c = quote.Require_Separate_Quote_for_Genesys_Care__c;
        }   
        //Old Pricing
        if(quote.Quote_Opportunity_Type__c == 'Old Pricing'){
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
        }
        //Special Offer Terms
        if(quote.Include_Special_Offer_in_Output__c != dq.Special_Offer_Terms__c){
            dq.Special_Offer_Terms__c = quote.Include_Special_Offer_in_Output__c;
        }
        //Special Offer term conditions (comments)
        if(quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c){
            dq.Special_Offers_Business_Exceptions__c = quote.Special_Offer_Terms__c;
        }
        //Finance Exceptions
        if(quote.Finance_Exceptions__c != dq.Finance_Exception__c && quote.Finance_Exceptions__c != null){
            dq.Finance_Exception__c = quote.Finance_Exceptions__c;
        }
        //Legal Exceptions
        if(quote.Legal_Exceptions__c != dq.Legal_Exceptions__c && quote.Legal_Exceptions__c != null){
            dq.Legal_Exceptions__c = quote.Legal_Exceptions__c;
        }
        //Support Options
        if(quote.Support_Options__c != dq.Support_Option__c && quote.Support_Options__c != null 
           && quote.Support_Options__c != 'Standard Support'){
               dq.Support_Option__c = quote.Support_Options__c;
           }
        if(quote.Carveout__c){
            dq.Carveout__c = true;
            dq.CarveOutDetails__c = quote.CarveOutDetails__c;
        }
        //Base Agent Discount      
        dq.Base_Agent_Discount__c = quote.Base_Agent_Discount__c;
        //Hardware Discount     
        dq.Hardware_Discount__c = quote.Hardware_Discount__c;
        //Add-On Discount     
        dq.Business_Users_Add_On__c = quote.Business_Users_Add_On__c;
        //Business Users Discount      
        //dq.Business_Users_Provisioning_Discount__c = quote.Business_Users_Provisioning_Discount__c;
        //Data Center Discount      
        dq.Data_Center_Provisioning_Discount__c = quote.Data_Center_Provisioning_Discount__c;
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c != dq.Editable_List_Price_Approval_Required__c){
            dq.Editable_List_Price_Approval_Required__c = quote.Editable_List_Price_Approval_Required__c;
        }
        //Rental Quote
        dq.Rental__c = quote.PPU_Rental__c;
        //Usage Data Submission Method
        dq.Usage_Data_Submission_Method__c = quote.Usage_Data_Submission_Method__c;
        //Deal Score
        if(dq.Pricing_Type__c != 'Old Pricing' && quote.Amendment_For__c == null){
            dq.Deal_Score_Size__c = DealQualificationApprovalUtil.getDealScoreSizePickListVal(quote.Total_Software__c);
            dq.Net_Deal_Size_Amount__c = quote.Total_Software__c;
            dq.Deal_Score__c = quote.Deal_Score__c;
        }
        //Conversion Quote
        dq.Conversion_Quote__c = quote.Conversion_Quote__c;
        //Contractual Rate
        dq.Contractual_Rate_Approval__c = quote.Require_Contractual_Discount__c;
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quoteId);
        List<BigMachines__Quote_Product__c> quoteProductsWhichRequiresApproval = new List<BigMachines__Quote_Product__c>();
        Boolean isThirdPartyProduct = false;  
        Map<Id, String> mapProductIdVsReason = new Map<Id, String>();  
        //Looping over each quote product record to update above flags
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
            if(!isThirdPartyProduct && eachQuoteProduct.BigMachines__Product__r.Third_Party__c != null
               && eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toLowerCase() == 'true'){
                   isThirdPartyProduct = true;
               }
            if((eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c != null
                && eachQuoteProduct.Total_Discount__c != null
                && eachQuoteProduct.Total_Discount__c > eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c)
               || (eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c != null 
                   && DealQualificationApprovalUtil.isPMApprovalRequired(eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c)) ){
                       quoteProductsWhichRequiresApproval.add(eachQuoteProduct);
                       if(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c != null 
                          && DealQualificationApprovalUtil.isPMApprovalRequired(eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c)){
                              mapProductIdVsReason.put(eachQuoteProduct.BigMachines__Product__c, 'PM Approval Required');
                              continue;
                          }
                       if(eachQuoteProduct.BigMachines__Product__r.Third_Party__c != null
                          && eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toLowerCase() == 'true'){
                              mapProductIdVsReason.put(eachQuoteProduct.BigMachines__Product__c, 'Third Party Product');                  
                              continue;
                          }
                       if(eachQuoteProduct.BigMachines__Product__r.Type__c == DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE 
                          || eachQuoteProduct.BigMachines__Product__r.Type__c == DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_HARDWARE){
                              mapProductIdVsReason.put(eachQuoteProduct.BigMachines__Product__c, 'BEP Override');
                              continue;
                          }
                       if(eachQuoteProduct.BigMachines__Product__r.Type__c == DealQualificationApprovalUtil.PRODUCT_TYPE_GU){
                           mapProductIdVsReason.put(eachQuoteProduct.BigMachines__Product__c, 'GU Override');
                           continue;                   
                       }
                       mapProductIdVsReason.put(eachQuoteProduct.BigMachines__Product__c, 'Product Specific Discount');
                   } 
            
        }        
        if(isThirdPartyProduct)
            dq.X3rd_Party_Products__c = 'Yes';
        else
            dq.X3rd_Party_Products__c = 'No';        
        dq.Quote__c = quoteId;
        dq.Seat_Count_Tier__c = quote.Max_Seat_Count__c;

         //Seasonal Licensing (Bursting)
        if( dq.Seasonal_License_Net_Value_Y1__c != quote.Seasonal_License_Net_Value_Y1__c ) 
            dq.Seasonal_License_Net_Value_Y1__c = quote.Seasonal_License_Net_Value_Y1__c;
        if (dq.Seasonal_License_Net_Value_Y2__c != quote.Seasonal_License_Net_Value_Y2__c)    
            dq.Seasonal_License_Net_Value_Y2__c = quote.Seasonal_License_Net_Value_Y2__c;
        if (dq.Overage_Discount__c != quote.Overage_Discount__c)
             dq.Overage_Discount__c = quote.Overage_Discount__c;

        //Credits
        if( dq.Total_Recurring_Credit__c != quote.Total_Recurring_Credit__c ) 
            dq.Total_Recurring_Credit__c = quote.Total_Recurring_Credit__c;
        if (dq.Total_Non_Recurring_Credit__c != quote.Total_Non_Recurring_Credit__c)    
            dq.Total_Non_Recurring_Credit__c = quote.Total_Non_Recurring_Credit__c;

        //Mukunth added on 07-JUN-2019 for INC0419391
        list<string> paOffTypes = ((Global_Setting__c.getValues('Payment Terms Approval')).Information__c).split(';');
        //dq.Payment_Terms__c = null;
        if((paOffTypes.contains(quote.Offering_Type__c) || paOffTypes.contains(QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE)) && quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ){              
                dq.Payment_Terms__c = quote.Order_Payment_Terms__c;
            }        
        }
        //Mukunth code end        
    
        upsert dq;
        
        //resetApprovalsIfNeeded(dq, quote.Quote_Opportunity_Type__c);
        
        
        List<Deal_Qualification_Products__c> dqProductsToBeDeleted = DealQualificationApprovalUtil.getDQProducts(dq.id);
        if(!dqProductsToBeDeleted.isEmpty())
            delete dqProductsToBeDeleted;
        if(quoteProductsWhichRequiresApproval.isEmpty()){          
            return dq.Status__c;
        }
        List<Deal_Qualification_Products__c> dqProductsToBeUpserted = new List<Deal_Qualification_Products__c> ();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWhichRequiresApproval){
            Deal_Qualification_Products__c newDQProduct = new Deal_Qualification_Products__c();
            newDQProduct.Deal_Qualification__c = dq.id;
            newDQProduct.Product__c = eachQuoteProduct.BigMachines__Product__c;
            newDQProduct.Discount__c =   eachQuoteProduct.Total_Discount__c;
            newDQProduct.Quantity__c = eachQuoteProduct.BigMachines__Quantity__c;
            newDQProduct.Approval_Reason__c = mapProductIdVsReason.get(eachQuoteProduct.BigMachines__Product__c);
            dqProductsToBeUpserted.add(newDQProduct);      
        }    
        if(!dqProductsToBeUpserted.isEmpty())
            insert dqProductsToBeUpserted;
        return dq.Status__c;
    }
    
    //Anju May 2018 new sync function for PC DQ
    public static String synchDQPC(BigMachines__Quote__c quote, String oppId){
        String quoteId = quote.id;
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        
        Deal_Qualification__c dq;
        if(dqs.isEmpty()){
            dq = new Deal_Qualification__c();
            dq.Opportunity__c = oppId;
            dq.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
            dq.currencyIsoCode = quote.currencyIsoCode;
            dq.Platform_Type__c = quote.Quote_Business_Type__c; 
            if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC)
                dq.Expiration_Date__c = System.today().addYears(1);  
            dq.Offering_Type__c = (quote.Offering_Type__c == null ? QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE : quote.Offering_Type__c);                    
        }
        else{
            dq = dqs[0];
        }      
        
        BigMachines__Quote__c currentQuote = [Select id,currencyisocode,Owner_Segment__c,PureCloud_Monthly_Minimum__c,
                                              BigMachines__Opportunity__r.Direct_Indirect_Sale__c,
                                              BigMachines__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c,
                                              BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c 
                                              from BigMachines__Quote__c where id = :quote.id limit 1];
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(currentQuote.id);
        
        Boolean blnisDevOrg = false;
        Boolean blnisCreditInvolved = false;
        Boolean blnisCreditIncreased = false;
        
        //Amend Check
        Boolean blnProfServDQReq = false;
        Boolean blnHardwareDQReq = false;
        Boolean blnSoftwareDQReq = false;
        Boolean blnDiscountDQReq = false;
        Boolean blnOverageDQReq = false;
        List<BigMachines__Quote_Product__c> quoteProductsWhichRequiresApproval = new List<BigMachines__Quote_Product__c>();
        Boolean isThirdPartyProduct = false;  
        Map<Id, String> mapProductIdVsReason = new Map<Id, String>();
        Boolean blnExceedsPartnerBaselineDiscount = false;
        if(!currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c)
            blnExceedsPartnerBaselineDiscount = true;
        //List<zqu__QuoteRatePlanCharge__c> quoteProducts = [Select id,zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c,zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.name from zqu__QuoteRatePlanCharge__c where QuoteId__c = :currentQuote.id];
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            if(qrpc.BigMachines__Product__r.APN_Number__c != null && Label.PC_DEV_Org_Parts.contains(qrpc.BigMachines__Product__r.APN_Number__c))
                blnisDevOrg = true;
            if(qrpc.BigMachines__Product__r.New_Category__c == 'Credit')
                blnisCreditInvolved = true;
            if(currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c && qrpc.BigMachines__Product__r.Include_in_CMMR_Total__c && qrpc.Partner_Price__c > qrpc.Net_Unit_Price__c)
                blnExceedsPartnerBaselineDiscount = true;
            
            //Amend check
            
            if((qrpc.Subscription_Product__c ==  null && qrpc.Total_Discount__c > 0) || (qrpc.Subscription_Product__c != null && qrpc.Total_Discount__c > qrpc.Subscription_Product__r.Total_Discount__c)) {
                if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'PROFESSIONAL SERVICES') {
                    blnProfServDQReq = true;
                }
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Hardware') {
                    blnHardwareDQReq = true;
                }
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Software') {
                    blnSoftwareDQReq = true;
                }
                if(qrpc.Is_Overage__c)
                    blnOverageDQReq = true;
                
                blnDiscountDQReq = true;
                
                //Product Specific Discount
                if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
                   && qrpc.Total_Discount__c != null
                   && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c){
                       quoteProductsWhichRequiresApproval.add(qrpc);
                       mapProductIdVsReason.put(qrpc.BigMachines__Product__c, 'Product Specific Discount');
                   }
                
            }
            //Amend check for credit
            if(qrpc.Subscription_Product__c !=  null && qrpc.BigMachines__Product__r.New_Category__c == 'Credit' && qrpc.BigMachines__Quantity__c > qrpc.Subscription_Product__r.quantity__c) 
                blnisCreditIncreased = true;
            
            
        }
        //Deal Score Cloud
        dq.Deal_Score__c = null;
        //Mukunth added Mega Deal Check for DDS Mega Deals
        if(!isMegaDealbln){
            if(!quote.Order_Type__c.contains('Amend') && blnExceedsPartnerBaselineDiscount){
                dq.Deal_Score__c = quote.Deal_Score__c;
            }
        }
        
        System.debug('Inside DQ Sync for PC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased);
        //PC Credit
        System.debug('Inside DQ Sync for PC:'+' dq.PureCloud_Credit_Applied__c:'+dq.PureCloud_Credit_Applied__c + ' quote.Order_Type__c:'+quote.Order_Type__c+' blnisCreditInvolved:'+blnisCreditInvolved+' blnisCreditIncreased:'+blnisCreditIncreased);
        dq.PureCloud_Credit_Applied__c = false;
        if((!quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c == false || (quote.Migration_credit__c != null && dq.Migration_Credit__c !=null && quote.Migration_credit__c != dq.Migration_Credit__c))&& blnisCreditInvolved )
           || (quote.Order_Type__c.contains('Amend') && (dq.PureCloud_Credit_Applied__c == false || (quote.Migration_credit__c != null && dq.Migration_Credit__c !=null && quote.Migration_credit__c != dq.Migration_Credit__c) || blnisCreditIncreased)&& blnisCreditInvolved)){
               dq.PureCloud_Credit_Applied__c = true; 
               dq.Migration_Credit__c = quote.Migration_credit__c;
           }
        //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- Start
        dq.Renewal_Subscription_Term__c = false;
        if(quote.Renewal_Subscription_Term__c == 'Automatic Monthly'){
            if((quote.Renewal_Subscription_Term__c == 'Automatic Monthly' && quote.Billing_Category__c != 'M2M') || (quote.Renewal_Subscription_Term__c == 'Automatic Monthly' && quote.Billing_Category__c == 'M2M' && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial')){
                dq.Renewal_Subscription_Term__c = true;
            }
        }
        if(quote.Renewal_Subscription_Term__c == 'Automatic Initial Subscription'){
            if((quote.Renewal_Subscription_Term__c == 'Automatic Initial Subscription' && quote.Billing_Category__c != 'M2M') || (quote.Renewal_Subscription_Term__c == 'Automatic Initial Subscription' && quote.Billing_Category__c == 'M2M' && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial')){
                dq.Renewal_Subscription_Term__c = true;
            }
        }
        if(quote.Renewal_Subscription_Term__c == 'No Auto-Renewal'){
            if((quote.Renewal_Subscription_Term__c == 'No Auto-Renewal' && quote.Billing_Category__c != 'M2M') || (quote.Renewal_Subscription_Term__c == 'No Auto-Renewal' && quote.Billing_Category__c == 'M2M' && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial')){
                dq.Renewal_Subscription_Term__c = true;
            }
        }     
        if(quote.Billing_Category__c  == 'M2M'){
            dq.Billing_Category__c = 'M2M';
        }  
        //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- End
        //PC Monthly minimum
        
        Boolean blnMonthMinNUllCheck = false;
        dq.If_Other_PureCloud_Monthly_Minimum_Req__c = null;
        dq.PureCloud_Monthly_Minimum__c = null;
        Map<String, Decimal> mapCurrencies = new Map<String, Decimal>();
        mapCurrencies = QuoteCloudUtil.buildConversionRatesMap();
        Double USDMonthlyMinimum = currentQuote.PureCloud_Monthly_Minimum__c;
        if(currentQuote.PureCloud_Monthly_Minimum__c == null)
            currentQuote.PureCloud_Monthly_Minimum__c = 0;
        if(dq.If_Other_PureCloud_Monthly_Minimum_Req__c == null){
            dq.If_Other_PureCloud_Monthly_Minimum_Req__c = 0;
            blnMonthMinNUllCheck = true;
        }
        if(mapCurrencies.containskey(currentQuote.CurrencyIsoCode))
        {
            USDMonthlyMinimum = currentQuote.PureCloud_Monthly_Minimum__c / mapCurrencies.get(currentQuote.CurrencyIsoCode);
            dq.If_Other_PureCloud_Monthly_Minimum_Req__c = dq.If_Other_PureCloud_Monthly_Minimum_Req__c / mapCurrencies.get(currentQuote.CurrencyIsoCode);
        }
        //if(currentQuote.zqu__SubscriptionType__c == 'New Subscription')
        //{
        
        
        Boolean blnMonthMinCheck = false;
        
        
        if(currentQuote.Owner_Segment__c == 'Velocity' && USDMonthlyMinimum >= 1500){
            
            blnMonthMinCheck = true;
        }
        else if(currentQuote.BigMachines__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c && USDMonthlyMinimum >= 750){
            
            blnMonthMinCheck = true;
        }
        else if(currentQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect' && USDMonthlyMinimum >= 1000){
            
            blnMonthMinCheck = true;
        }
        else if(blnisDevOrg && USDMonthlyMinimum >= 0){
            
            blnMonthMinCheck = true;
        }
        else if(USDMonthlyMinimum >= 2000){
            
            blnMonthMinCheck = true;
        }
        //}
        //else
        // blnMonthMinCheck = true;
        
        if(!quote.Order_Type__c.contains('Amend') && quote.BigMachines__Opportunity__r.Offering_Detail__c != 'Pilot/Trial/POC' && blnMonthMinCheck == false && (dq.If_Other_PureCloud_Monthly_Minimum_Req__c > USDMonthlyMinimum || blnMonthMinNUllCheck)){
            dq.If_Other_PureCloud_Monthly_Minimum_Req__c = quote.PureCloud_Monthly_Minimum__c;
            dq.PureCloud_Monthly_Minimum__c =  'Other';
        }
        else
        {
            dq.PureCloud_Monthly_Minimum__c = null;
            dq.If_Other_PureCloud_Monthly_Minimum_Req__c = null;
        }
        
        //PC Trial
        Boolean blnisTrial = false;
        if(quote.BigMachines__Opportunity__r.Offering_Detail__c != null && quote.BigMachines__Opportunity__r.Offering_Detail__c.contains('Pilot/Trial/POC')){
            blnisTrial = true;
        }
        
        dq.PureCloud_Trial__c = false;
        if(dq.PureCloud_Trial__c == false && blnisTrial){
            dq.PureCloud_Trial__c = true;
        }
        
        //Discount
        Decimal decOnDQ = 0;
        Double decAcvDQ = 0;
        if(dq.Net_Deal_Value__c != null){
            decAcvDQ = DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c);
            decAcvDQ = DealQualificationApprovalUtil.convertCurrency(decAcvDQ, quote.CurrencyIsoCode);
        }
        
        Decimal decDiscount = quote.Total_Discount_Genesys_and_Third_Party__c;
        dq.Discount_On_Quote__c = null;
        if(decDiscount == null)
            decDiscount = 0;
        if(dq.Discount_On_Quote__c == null)
            dq.Discount_On_Quote__c = 0;
        decDiscount = decDiscount.setScale(2);
        
        if(decOnDQ != null && dq.Discount_On_Quote__c != null)
            decOnDQ = dq.Discount_On_Quote__c.setScale(2);
        
        if((blnDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && decOnDQ < decDiscount){
            dq.Discount_On_Quote__c = decDiscount;
        }
        
        //Special Offer Terms
        dq.Special_Offers_Business_Exceptions__c = null;
        dq.Special_Offer_Terms__c = false;
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            dq.Special_Offers_Business_Exceptions__c = quote.Special_Offer_Terms__c;
            dq.Special_Offer_Terms__c = quote.Include_Special_Offer_in_Output__c;
        } 
        
        
        
        //Initial Subscription Term
        dq.If_Other_Term_Months_Requested__c = null; 
        dq.Initial_Subscription_Term_Months_PC__c = null;               
        if(quote.No_Of_Months__c != null ){
            
            Decimal termMonths = quote.No_Of_Months__c.setScale(2, RoundingMode.HALF_UP);
            Decimal termMonthsOnDQ = DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c);
            //Amend
            Integer decAmendtermMonths = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Term__c != null){
                
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Month'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Month'));
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Year'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Year')) * 12; 
                //termMonths = decAmendtermMonths > termMonths ? decAmendtermMonths : termMonths;
            }
            if(termMonths > 36 && termMonths > termMonthsOnDQ && termMonths > decAmendtermMonths){              
                dq.If_Other_Term_Months_Requested__c = quote.No_Of_Months__c;
                dq.Initial_Subscription_Term_Months_PC__c = 'Other';
            }
            else if(quote.Order_Type__c.contains('Amend'))
                dq.Initial_Subscription_Term_Months_PC__c = '0'; 
            else
                dq.Initial_Subscription_Term_Months_PC__c = String.valueof(termMonths);    
        }
        
        //Ramp Period
        dq.If_Other_Ramp_Period_Requested_Days__c = null;
        dq.Ramp_Period_Days__c = null;
        if(!quote.Order_Type__c.contains('Amend') && quote.Ramp_Period__c != 'Other'){
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            Decimal rampPeriod = Decimal.valueof(strRampPeriod).setScale(2, RoundingMode.HALF_UP);
            Decimal rampPeriodOnDQ = DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c);
            if(rampPeriod > 90 && rampPeriod > rampPeriodOnDQ ){              
                if(rampPeriod <= 150 || quote.Ramp_Period__c == 'Other')
                    dq.Ramp_Period_Days__c = String.valueof(Integer.valueof(rampPeriod));
                else{            
                    dq.If_Other_Ramp_Period_Requested_Days__c = Decimal.valueof(strRampPeriod);
                    dq.Ramp_Period_Days__c = 'Other';
                }
            }
            else
                dq.Ramp_Period_Days__c = String.valueof(rampPeriod);        
        }
        else if (quote.Order_Type__c.contains('Amend'))
        {
            dq.Ramp_Period_Days__c = '0';
        }
        
        //PC Overage Discount 
        dq.Overage_Discount__c = null;     
        if((blnOverageDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Overage_Discount__c != null){
            
            if(quote.Overage_Discount__c > 0 && (quote.Overage_Discount__c.setScale(2) > dq.Overage_Discount__c || dq.Overage_Discount__c ==  null)){              
                dq.Overage_Discount__c = quote.Overage_Discount__c.setScale(2);
            }        
        }
        
        //PC PS Discount
        dq.PS_Discount_on_Quote__c = null;        
        if((blnProfServDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Professional_Services_Discount__c != null){
            
            if(quote.Professional_Services_Discount__c  > 0 && (quote.Professional_Services_Discount__c.setScale(2) > dq.PS_Discount_on_Quote__c || dq.PS_Discount_on_Quote__c ==  null)){              
                dq.PS_Discount_on_Quote__c = quote.Professional_Services_Discount__c.setScale(2);
            }        
        }
        
        //Harware discount
        dq.Hardware_Discount__c = null;
        if((blnHardwareDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Hardware_Discount__c != null){
            
            if(quote.Hardware_Discount__c  > 0 && (quote.Hardware_Discount__c.setScale(2) > dq.Hardware_Discount__c || dq.Hardware_Discount__c ==  null)){              
                dq.Hardware_Discount__c = quote.Hardware_Discount__c.setScale(2);
            }
        }
        
        //Software discount
        dq.Software_Discount__c = null;
        if((blnSoftwareDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Software_Discount__c != null){
            
            if(quote.Software_Discount__c   > 0 && (quote.Software_Discount__c.setScale(2)  > dq.Software_Discount__c || dq.Software_Discount__c ==  null)){              
                dq.Software_Discount__c = quote.Software_Discount__c.setScale(2);
            }        
        }
        
        //Editable list price
        dq.Editable_List_Price_Approval_Required__c = false;
        if(quote.Editable_List_Price_Approval_Required__c && !dq.Editable_List_Price_Approval_Required__c){
            dq.Editable_List_Price_Approval_Required__c = quote.Editable_List_Price_Approval_Required__c;    
        }
        
        //Payment Terms
        dq.Payment_Terms__c = null;
        if(quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            system.debug('===>QuotePaymentTerm'+PaymentTerm);
            system.debug('===>PaymentTermOnDQ'+PaymentTermOnDQ);
            //Amend
            Decimal PaymentTermAmend = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Payment_Term__c != null){
                PaymentTermAmend = DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c) > PaymentTerm ? DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c):PaymentTerm;
            }
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ && PaymentTerm > PaymentTermAmend){              
                dq.Payment_Terms__c = quote.Order_Payment_Terms__c;
            }        
        }
        
        //TCV reduction
        dq.TCV_Reduction__c = null;
        if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null){
            if(quote.Total_Contract_Value_Change__c < 0 && ((quote.Total_Contract_Value_Change__c * -1) > dq.TCV_Reduction__c || dq.TCV_Reduction__c == null)){
                dq.TCV_Reduction__c = quote.Total_Contract_Value_Change__c * -1;
            }
            
        }                
        
        //Deal Size
        dq.Net_Deal_Size_Amount__c = null;
        Decimal decUSDACV = 0;
        if(!Test.isRunningTest()) {
            decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        }
        if(!quote.Order_Type__c.contains('Amend') && !blnisTrial)
            dq.Net_Deal_Size_Amount__c = decUSDACV;
        dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(decUSDACV);
        
        if(currentQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c)
            dq.Cloud_Partner_Approval__c = true;
        else
            dq.Cloud_Partner_Approval__c = false;
        //dq.Net_Deal_Value__c = String.valueof(decUSDACV);
        
        /*
Decimal acv = quote.Annual_Contract_Value__c;

if(decAcvDQ < acv){
dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(quote.Annual_Contract_Value__c);
}
*/
        
        dq.Quote__c = quote.Id;
        upsert dq;
        
        List<Deal_Qualification_Products__c> dqProductsToBeDeleted = DealQualificationApprovalUtil.getDQProducts(dq.id);
        if(!dqProductsToBeDeleted.isEmpty())
            delete dqProductsToBeDeleted;
        if(quoteProductsWhichRequiresApproval.isEmpty()){          
            return dq.Status__c;
        }
        List<Deal_Qualification_Products__c> dqProductsToBeUpserted = new List<Deal_Qualification_Products__c> ();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWhichRequiresApproval){
            Deal_Qualification_Products__c newDQProduct = new Deal_Qualification_Products__c();
            newDQProduct.Deal_Qualification__c = dq.id;
            newDQProduct.Product__c = eachQuoteProduct.BigMachines__Product__c;
            newDQProduct.Discount__c =   eachQuoteProduct.Total_Discount__c;
            newDQProduct.Quantity__c = eachQuoteProduct.BigMachines__Quantity__c;
            newDQProduct.Approval_Reason__c = mapProductIdVsReason.get(eachQuoteProduct.BigMachines__Product__c);
            dqProductsToBeUpserted.add(newDQProduct);      
        }    
        if(!dqProductsToBeUpserted.isEmpty())
            insert dqProductsToBeUpserted;
        
        return dq.Status__c;
    }
    
    //Anju July 2018 new sync function for PCC DQ
    public static String synchDQPCC(BigMachines__Quote__c quote, String oppId){
        String quoteId = quote.id;
        List<Deal_Qualification__c> dqs = DealQualificationApprovalUtil.getDQ(oppId, quote.Quote_Opportunity_Type__c, quote.Quote_Business_Type__c, quote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
        
        List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
        Boolean blnisCreditInvolved = false;
        Boolean blnisCreditIncreased = false;                  
        //Amend Check
        Boolean blnDiscountDQReq = false;
        Boolean blnOverageDQReq = false;
        Boolean blnBaseAgentDiscountDQReq = false;
        Boolean blnHardwareDiscountDQReq = false;
        Boolean blnDataCenterProvisioningDiscountDQReq = false;
        Boolean blnBusinessUsersAddonDiscountDQReq = false;
        Boolean blnThirdPartyDiscountDQReq = false;
        List<BigMachines__Quote_Product__c> quoteProductsWhichRequiresApproval = new List<BigMachines__Quote_Product__c>();
        Boolean isThirdPartyProduct = false;  
        Map<Id, String> mapProductIdVsReason = new Map<Id, String>();
        for(BigMachines__Quote_Product__c qrpc : quoteProducts)
        {
            //Amend check
            if(qrpc.BigMachines__Product__r.New_Category__c == 'Credit')
                blnisCreditInvolved = true;                                         
            if((qrpc.Subscription_Product__c ==  null && qrpc.Total_Discount__c > 0) || (qrpc.Subscription_Product__c != null && qrpc.Total_Discount__c > (qrpc.Subscription_Product__r.Total_Discount__c == null ? 0 : qrpc.Subscription_Product__r.Total_Discount__c.setscale(2)))) {
                if(qrpc.Is_Overage__c)
                    blnOverageDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Base Agent')
                    blnBaseAgentDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Hardware')
                    blnHardwareDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Data Center Provisioning')
                    blnDataCenterProvisioningDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.ProductSubFamily__c == 'Business Users & Add-On Functionality')
                    blnBusinessUsersAddonDiscountDQReq = true;
                else if(qrpc.BigMachines__Product__r.Third_Party__c == 'True')
                    blnThirdPartyDiscountDQReq = true;
                blnDiscountDQReq = true;
                
                
                if(qrpc.BigMachines__Product__r.Product_Specific_Discount__c != null
                   && qrpc.Total_Discount__c != null
                   && qrpc.Total_Discount__c > qrpc.BigMachines__Product__r.Product_Specific_Discount__c){
                       quoteProductsWhichRequiresApproval.add(qrpc);
                       mapProductIdVsReason.put(qrpc.BigMachines__Product__c, 'Product Specific Discount');
                   } 
            }
            if(qrpc.Subscription_Product__c !=  null && qrpc.BigMachines__Product__r.New_Category__c == 'Credit' && qrpc.BigMachines__Quantity__c > qrpc.Subscription_Product__r.quantity__c) 
                blnisCreditIncreased = true;                                                                                                       
        }
        Deal_Qualification__c dq;
        if(dqs.isEmpty()){
            dq = new Deal_Qualification__c();
            dq.Opportunity__c = oppId;
            dq.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
            dq.Pricing_Type__c = quote.Quote_Opportunity_Type__c;
            dq.currencyIsoCode = quote.currencyIsoCode;
            dq.Platform_Type__c = quote.Quote_Business_Type__c; 
            if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC)
                dq.Expiration_Date__c = System.today().addYears(1);  
            dq.Offering_Type__c = (quote.Offering_Type__c == null ? QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE : quote.Offering_Type__c);                    
        }
        else{
            dq = dqs[0];
        }  
        
        //Deal Score Cloud  
        dq.Deal_Score__c = null;
        //Mukunth added Mega Deal Check for DDS Mega Deals
        if(!isMegaDealbln){
            if(!quote.Order_Type__c.contains('Amend')){
                dq.Deal_Score__c = quote.Deal_Score__c;
            }
        }
        
        //PCC Credit-Rony Joseph-April 17th 2019-PCC Credit Reset - Begin
        dq.PureCloud_Credit_Applied__c = false;
        if((!quote.Order_Type__c.contains('Amend') && blnisCreditInvolved && ( dq.PureCloud_Credit_Applied__c == false|| (quote.Migration_credit__c != null && dq.Migration_Credit__c !=null && quote.Migration_credit__c != dq.Migration_Credit__c)))
           || (quote.Order_Type__c.contains('Amend') && dq.PureCloud_Credit_Applied__c == false && blnisCreditInvolved && (blnisCreditIncreased || quote.Migration_credit__c != null && dq.Migration_Credit__c !=null && quote.Migration_credit__c != dq.Migration_Credit__c))){
               dq.PureCloud_Credit_Applied__c = true; 
               dq.Migration_Credit__c = quote.Migration_credit__c;
           }
        //PCC Credit-Rony Joseph-April 17th 2019-PCC Credit Reset - End
        //Third Party Discount
        dq.Third_Party_Discount__c = null;
        if((blnThirdPartyDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Third_Party_Discount__c != null){
            if((dq.Third_Party_Discount__c == null || dq.Third_Party_Discount__c < quote.Third_Party_Discount__c) && quote.Third_Party_Discount__c > 0){
                dq.Third_Party_Discount__c = quote.Third_Party_Discount__c;
            }
        }
        
        
        //Pricing Model - Concurrent
        if(quote.Pricing_Model__c != dq.Pricing_Model__c){
            dq.Pricing_Model__c = quote.Pricing_Model__c;
        }
        
        //Base Agent Discount 
        dq.Base_Agent_Discount__c = null;
        if((blnBaseAgentDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Base_Agent_Discount__c != null){
            Decimal discountOnQuote = quote.Base_Agent_Discount__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Base_Agent_Discount__c == null ? 0 : dq.Base_Agent_Discount__c).setScale(2, RoundingMode.HALF_UP);
            if(discountOnQuote > 0 && discountOnQuote > discountOnDQ){              
                dq.Base_Agent_Discount__c = quote.Base_Agent_Discount__c;
            }        
        }     
        
        //Hardware Discount
        dq.Hardware_Discount__c = null;
        if((blnHardwareDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Hardware_Discount__c != null ){
            Decimal discountOnQuote = quote.Hardware_Discount__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Hardware_Discount__c == null ? 0 : dq.Hardware_Discount__c).setScale(2, RoundingMode.HALF_UP); 
            if(discountOnQuote > 0 && discountOnQuote > discountOnDQ){              
                dq.Hardware_Discount__c = quote.Hardware_Discount__c;
            }        
        }     
        
        //Add-On Discount 
        dq.Business_Users_Add_On__c = null;
        if((blnBusinessUsersAddonDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Business_Users_Add_On__c != null ){
            Decimal discountOnQuote = quote.Business_Users_Add_On__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Business_Users_Add_On__c == null ? 0 : dq.Business_Users_Add_On__c).setScale(2, RoundingMode.HALF_UP);
            if(discountOnQuote > 25 && discountOnQuote > discountOnDQ){              
                dq.Business_Users_Add_On__c = quote.Business_Users_Add_On__c;
            }        
        }    
        
        //Data Center Provisioning Discount
        dq.Data_Center_Provisioning_Discount__c = null;
        if((blnDataCenterProvisioningDiscountDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Data_Center_Provisioning_Discount__c != null ){
            Decimal discountOnQuote = quote.Data_Center_Provisioning_Discount__c.setScale(2, RoundingMode.HALF_UP);
            Decimal discountOnDQ = (dq.Data_Center_Provisioning_Discount__c == null ? 0 : dq.Data_Center_Provisioning_Discount__c).setScale(2, RoundingMode.HALF_UP);
            if(discountOnQuote > 10 && discountOnQuote > discountOnDQ){              
                dq.Data_Center_Provisioning_Discount__c = quote.Data_Center_Provisioning_Discount__c;
            }        
        } 
        
        //Editable list price
        if(quote.Editable_List_Price_Approval_Required__c != dq.Editable_List_Price_Approval_Required__c){
            dq.Editable_List_Price_Approval_Required__c = quote.Editable_List_Price_Approval_Required__c;
        }
        //Special Offer Terms
        dq.Special_Offers_Business_Exceptions__c = null;
        dq.Special_Offer_Terms__c = false;
        if(quote.Include_Special_Offer_in_Output__c && (!dq.Special_Offer_Terms__c || quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)){
            
            dq.Special_Offer_Terms__c = true;
            if(quote.Special_Offer_Terms__c != null && quote.Special_Offer_Terms__c != dq.Special_Offers_Business_Exceptions__c)
                dq.Special_Offers_Business_Exceptions__c = quote.Special_Offer_Terms__c;
        } 
        
        //Initial Subscription Term
        dq.If_Other_Term_Months_Requested__c = null; 
        dq.Initial_Subscription_Term_Months_PC__c = null;                   
        if(quote.No_Of_Months__c != null ){
            Decimal termMonths = quote.No_Of_Months__c.setScale(2, RoundingMode.HALF_UP);
            Decimal termMonthsOnDQ = DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c);
            //Amend
            Integer decAmendtermMonths = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Term__c != null){                
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Month'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Month'));
                if(quote.Amendment_For__r.Term__c.containsIgnoreCase(' Year'))
                    decAmendtermMonths = Integer.ValueOf(quote.Amendment_For__r.Term__c.substringBefore(' Year')) * 12; 
                //termMonths = decAmendtermMonths > termMonths ? decAmendtermMonths : termMonths;
            }
            if(termMonths > 36 && termMonths > termMonthsOnDQ && termMonths > decAmendtermMonths){  
                if(termMonths  <= 60)
                    dq.Initial_Subscription_Term_Months_PC__c = String.valueof(Integer.valueof(termMonths));
                else{
                    dq.If_Other_Term_Months_Requested__c = quote.No_Of_Months__c;
                    dq.Initial_Subscription_Term_Months_PC__c = 'Other';
                }
                
            }        
        }
        
        //Ramp Period
        dq.If_Other_Ramp_Period_Requested_Days__c = null;
        dq.Ramp_Period_Days__c = null;
        if(!quote.Order_Type__c.contains('Amend') && quote.Ramp_Period__c != null && quote.Ramp_Period__c != 'Other'){
            String strRampPeriod =  (quote.Ramp_Period__c == '1 Year'?'365':quote.Ramp_Period__c);
            Decimal rampPeriod = Decimal.valueof(strRampPeriod).setScale(2, RoundingMode.HALF_UP);
            Decimal rampPeriodOnDQ = DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c);
            if(rampPeriod > 180 && rampPeriod > rampPeriodOnDQ ){  
                if(rampPeriod <= 365 || quote.Ramp_Period__c == 'Other')
                    dq.Ramp_Period_Days__c = String.valueof(Integer.valueof(rampPeriod));
                else{            
                    dq.If_Other_Ramp_Period_Requested_Days__c = Decimal.valueof(strRampPeriod);
                    dq.Ramp_Period_Days__c = 'Other';
                }
            }        
        } 
        
        //Payment Terms
        dq.Payment_Terms__c = null;
        if(quote.Order_Payment_Terms__c != null){
            Decimal PaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(quote.Order_Payment_Terms__c);
            Decimal PaymentTermOnDQ = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
            //Amend
            Decimal PaymentTermAmend = 0;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Payment_Term__c != null){
                PaymentTermAmend = DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c) > PaymentTerm ? DealQualificationApprovalUtil.getPaymentTerms(quote.Amendment_For__r.Payment_Term__c):PaymentTerm;
            }
            if(PaymentTerm >= 45 && PaymentTerm > PaymentTermOnDQ && PaymentTerm > PaymentTermAmend){              
                dq.Payment_Terms__c = quote.Order_Payment_Terms__c;
            }        
        }
        
        
        
        
        //Billing Period
        dq.Billing_Period__c = null;
        if(quote.Billing_Period__c != null && quote.Billing_Period__c != 'Other'){
            Decimal billingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Billing_Period__c);
            Decimal billingPeriodOnDQ = DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c);
            //Amend
            Decimal decBillingPeriod = billingPeriod;
            if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null && quote.Amendment_For__r.Billing_Period__c != null)                
                decBillingPeriod = DealQualificationApprovalUtil.getBillingPeriod(quote.Amendment_For__r.Billing_Period__c);
            if(!quote.Order_Type__c.contains('Amend'))
                decBillingPeriod = 0;
            if(billingPeriod > 0 && billingPeriod != billingPeriodOnDQ && billingPeriod != decBillingPeriod){                         
                dq.Billing_Period__c = quote.Billing_Period__c;
            }        
        }
        
        //Business Exceptions
        dq.Estimated_Monthly_Recurring_Revenue__c = null;
        if(quote.CMRR__c != null && DealQualificationApprovalUtil.convertCurrency(Double.valueof(quote.CMRR__c), quote.CurrencyIsoCode) < 14000){
            if(dq.Estimated_Monthly_Recurring_Revenue__c == null)
                dq.Estimated_Monthly_Recurring_Revenue__c = 0;
            if(DealQualificationApprovalUtil.convertCurrency(Double.valueof(quote.CMRR__c), quote.CurrencyIsoCode) < DealQualificationApprovalUtil.convertCurrency(Double.valueof(dq.Estimated_Monthly_Recurring_Revenue__c), quote.CurrencyIsoCode)){              
                dq.Estimated_Monthly_Recurring_Revenue__c = quote.CMRR__c;
            }        
        }
        
        //Agent user calculation
        Decimal intAgentCount = 0;
        Decimal intBusinessUserCount = 0;
        for(BigMachines__Quote_Product__c qProduct : [SELECT id, Quantity__c, BigMachines__Quantity__c, APN_Number__c from  BigMachines__Quote_Product__c where BigMachines__Quote__c = :quote.id]){
            if(Label.PCC_Agent_based_products.contains(qProduct.APN_Number__c))
                intAgentCount += qProduct.Quantity__c;
            if(Label.PCC_Business_users_products.contains(qProduct.APN_Number__c))
                intBusinessUserCount += qProduct.Quantity__c;
        }
        dq.Estimated_Number_of_Agents__c = null;
        dq.Less_than_100_Agents__c = null;
        if(intAgentCount > 0 && intAgentCount < 100){
            //if(dq.Estimated_Number_of_Agents__c == null) dq.Estimated_Number_of_Agents__c = 0;
            if(dq.Estimated_Number_of_Agents__c == null || intAgentCount  < dq.Estimated_Number_of_Agents__c){            
                dq.Estimated_Number_of_Agents__c = intAgentCount;
                dq.Less_than_100_Agents__c = 'Yes';
            }        
        }
        
        dq.Estimated_Number_of_Business_Users__c = null;
        dq.More_than_5_000_Business_Users__c = null;
        if(intBusinessUserCount > 5000){
            if(dq.Estimated_Number_of_Business_Users__c == null) dq.Estimated_Number_of_Business_Users__c = 0;
            
            if(intBusinessUserCount > dq.Estimated_Number_of_Business_Users__c ){              
                dq.Estimated_Number_of_Business_Users__c  = intBusinessUserCount ;
                dq.More_than_5_000_Business_Users__c = 'Yes';
            }        
        }
        dq.Business_User_to_Agent_Ratio_Exception__c = null;
        /*
if(intBusinessUserCount > 0 && intAgentCount > 0){

Decimal intRatio = intBusinessUserCount / intAgentCount;
if(intRatio.round() > 10 && dq.Business_User_to_Agent_Ratio_Exception__c != 'Yes'){ 

dq.Business_User_to_Agent_Ratio_Exception__c  = 'Yes';
}        
}
*/
        
        //Burst %
        dq.Overage_Allowance__c = quote.Overage_Allowance__c;
        dq.Overage_Allowance_Other__c = null;
        
        //PC Overage Discount     
        dq.Overage_Discount__c = null; 
        if((blnOverageDQReq || !quote.Order_Type__c.contains('Amend')) && quote.Overage_Discount__c != null){
            
            if(quote.Overage_Discount__c > 0 && (quote.Overage_Discount__c.setScale(2) > dq.Overage_Discount__c || dq.Overage_Discount__c ==  null)){              
                dq.Overage_Discount__c = quote.Overage_Discount__c.setScale(2);
            }        
        }
        //Annual Price Escalator
        dq.Price_Escalation__c = quote.Price_Escalation__c;
        dq.Annual_Price_Escalation_Other__c = null;
        
        
        //TCV reduction
        dq.TCV_Reduction__c = null;
        if(quote.Order_Type__c.contains('Amend') && quote.Amendment_For__c != null){
            if(quote.Total_Contract_Value_Change__c < 0 && ((quote.Total_Contract_Value_Change__c * -1) > dq.TCV_Reduction__c || dq.TCV_Reduction__c == null)){
                dq.TCV_Reduction__c = quote.Total_Contract_Value_Change__c * -1;
            }
            
        } 
        
        //Deal size
        Decimal decUSDACV = 0;
        if(!Test.isRunningTest()) {
            decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
        }
        //dq.Net_Deal_Value__c = String.valueof(decUSDACV);
        dq.Net_Deal_Size_Amount__c = null;
        if(!quote.Order_Type__c.contains('Amend'))
            dq.Net_Deal_Size_Amount__c = decUSDACV;
        dq.Net_Deal_Value__c = DealQualificationApprovalUtil.getDealSizePickListVal(decUSDACV);
        
        dq.Quote__c = quote.Id;   
        upsert dq;
        
        List<Deal_Qualification_Products__c> dqProductsToBeDeleted = DealQualificationApprovalUtil.getDQProducts(dq.id);
        if(!dqProductsToBeDeleted.isEmpty())
            delete dqProductsToBeDeleted;
        if(quoteProductsWhichRequiresApproval.isEmpty()){          
            return dq.Status__c;
        }
        List<Deal_Qualification_Products__c> dqProductsToBeUpserted = new List<Deal_Qualification_Products__c> ();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWhichRequiresApproval){
            Deal_Qualification_Products__c newDQProduct = new Deal_Qualification_Products__c();
            newDQProduct.Deal_Qualification__c = dq.id;
            newDQProduct.Product__c = eachQuoteProduct.BigMachines__Product__c;
            newDQProduct.Discount__c =   eachQuoteProduct.Total_Discount__c;
            newDQProduct.Quantity__c = eachQuoteProduct.BigMachines__Quantity__c;
            newDQProduct.Approval_Reason__c = mapProductIdVsReason.get(eachQuoteProduct.BigMachines__Product__c);
            dqProductsToBeUpserted.add(newDQProduct);      
        }    
        if(!dqProductsToBeUpserted.isEmpty())
            insert dqProductsToBeUpserted;
        return dq.Status__c;
        
    }
    public static void resetApprovalsIfNeeded(Deal_Qualification__c dq, String pricingType){
        
        List<Deal_Qualification__c> dqHs = DealQualificationApprovalUtil.getDQHistory(dq.Opportunity__c, pricingType, dq.Platform_Type__c, dq.Offering_Type__c);
        
        if(dqHs.isEmpty())
            return;
        Deal_Qualification__c dqHistory = dqHs[0];
        //Deal Size reduced
        Double dealSizeOnOriginalDQ = DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c);
        Double dealSizeOnHistoryDQ = DealQualificationApprovalUtil.getDealSize(dqHistory.Net_Deal_Value__c);
        if(dealSizeOnOriginalDQ < dealSizeOnHistoryDQ){
            delete dqHistory;
            //dq.Status__c = 'In Progress';
            //update dq;
            insertNotificationResetInfo(dq.id, 'All approvals have been reset because deal size was reduced.');
            return;
        }
        //Discount Incresed
        Double discountOnOriginalDQ = DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c);
        Double discountOnHistoryDQ = DealQualificationApprovalUtil.getDiscountSize(dqHistory.New_Pricing_Discount__c);
        if(discountOnOriginalDQ > discountOnHistoryDQ){
            delete dqHistory;
            insertNotificationResetInfo(dq.id, 'All approvals have been reset because discount was increased.');
            return;
        }
        Boolean updateHistory = false;
        
        //GC Override
        if(dqHistory.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_NO_OVERRIDE && 
           (getOverrideScore(dq.GC_Override__c) > getOverrideScore(dqHistory.GC_Override__c)
            || (!dq.Term_Increase__c && dqHistory.Term_Increase__c)
            || (!dq.Term_Decrease__c && dqHistory.Term_Decrease__c)
            || (!dq.Premium_Care__c && dqHistory.Premium_Care__c)          
            ||  (dq.ELA__c == 'No' && dqHistory.ELA__c == 'Yes')
            //||  (dq.Service_Level__c == DealQualificationApprovalUtil.BUSINESS && dqHistory.Premium_Care__c)
           )){
               dqHistory.GC_Override__c = DealQualificationApprovalUtil.GC_THRESHOLD_NO_OVERRIDE;
               updateHistory = true;
           }
        
        if(updateHistory){
            update dqHistory;
            insertNotificationResetInfo(dq.id, 'GC Override approvals have been reset.');
        }
        
    }  
    
    public static void insertNotificationResetInfo(String dqId, String comments){
        //Getting Max submission counter
        List<Quote_Approval__c> existingQuoteApprovals = [SELECT Step__c, Approval_Submission_Counter__c FROM Quote_Approval__c 
                                                          WHERE Deal_Qualification__c =: dqId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
        //How many times quote is submitted to approval    
        if(!existingQuoteApprovals.isEmpty()){
            Decimal submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c;
            Quote_Approval__c newQuoteApproval = new Quote_Approval__c(Deal_Qualification__c = dqId);
            newQuoteApproval.Step__c = existingQuoteApprovals[0].Step__c;
            newQuoteApproval.Comments__c = comments;
            newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_APPROVAL_RESET;
            newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
            insert newQuoteApproval;
        }
    }
    
    public static void resetELAApproval(BigMachines__Quote__c quote){
        String pricingType = quote.BigMachines__Opportunity__c;
        if(pricingType == 'New Pricing')
            pricingType = DealQualificationApprovalUtil.NEW_PRICING;
        
        List<Deal_Qualification__c> dqHistory = DealQualificationApprovalUtil.getDQHistory(quote.BigMachines__Opportunity__c, pricingType, quote.Quote_Business_Type__c,quote.Offering_Type__c);
        if(!dqHistory.isEmpty() && dqHistory[0].ELA__c == 'Yes'){
            dqHistory[0].ELA__c = 'No';
            update dqHistory[0];
        }
    }
    
    public static Integer getOverrideScore(String gcOverrideValue){
        if(gcOverrideValue == DealQualificationApprovalUtil.GC_THRESHOLD_NO_OVERRIDE || gcOverrideValue == null)
            return 0;
        else if(gcOverrideValue == DealQualificationApprovalUtil.GC_THRESHOLD_LESS_THAN_TWO)
            return 1;
        else if(gcOverrideValue == DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE)
            return 2;
        else if(gcOverrideValue == DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE)
            return 3;
        return 0;
    }
    private static String getBooleanToStringValue(Boolean bVal){
        if(bVal != null && bVal)
            return 'Yes';
        else
            return 'Not Approved';
    }
    
    public static void sendPMApprovalNotifications(String quoteId){
        
        Map<Id, BigMachines__Quote_Product__c> quoteProducts = new Map<Id, BigMachines__Quote_Product__c>([SELECT id, BigMachines__Product__r.Product_Manager_Approval_Group__c,
                                                                                                           BigMachines__Quote__c, BigMachines__Product__r.Shipment_Approval__c  FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId]);
        
        Set<Id> quoteProductIds = quoteProducts.keyset();
        List<BigMachines__Quote_Product__c> quoteProductsWithPMNotification = [SELECT BigMachines__Quote__c, Confirmation__c, 
                                                                               BigMachines__Product__r.Shipment_Approval__c, 
                                                                               BigMachines__Product__r.Product_Manager_Approval_Group__c FROM BigMachines__Quote_Product__c
                                                                               WHERE id =: quoteProductIds
                                                                               AND id NOT IN (SELECT Quote_Product__c FROM Quote_Approval__c WHERE BigMachines_Quote__c =: quoteId AND Trigger_Email_Alert__c =: DealQualificationApprovalUtil.PM_SHIPMENT_NOTIFICATION)
                                                                               AND BigMachines__Product__r.Product_Manager_Approval_Group__c != NULL
                                                                               AND ( BigMachines__Product__r.Shipment_Approval__c =: DealQualificationApprovalUtil.PRODUCT_HAS_PREREQ 
                                                                                    OR BigMachines__Product__r.Shipment_Approval__c =: DealQualificationApprovalUtil.NEW_PRODUCT_WITH_LIMITED 
                                                                                    OR BigMachines__Product__r.Shipment_Approval__c =: DealQualificationApprovalUtil.NOTIFICATION_ONLY_SO_PM 
                                                                                    OR BigMachines__Product__r.Shipment_Approval__c =:DealQualificationApprovalUtil.PRODUCT_AVAILABLE_FOR_EXP)];
        if(quoteProductsWithPMNotification.isEmpty())
            return ;
        Map<Id, Id> mapPMGroupIdVsOwnerId = new Map<Id, Id>(); 
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWithPMNotification){
            mapPMGroupIdVsOwnerId.put(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c, null);  
        }
        
        List<Quote_Approval_Step_Details__c> quoteApprovalStepDetailsPM = [SELECT Product_Manager_Approval_Group__c, Quote_Approver_Step_Approver_Detail__r.OwnerId
                                                                           FROM Quote_Approval_Step_Details__c WHERE Product_Manager_Approval_Group__c IN : mapPMGroupIdVsOwnerId.keyset()];
        if(quoteApprovalStepDetailsPM.isEmpty())
            return;
        
        for(Quote_Approval_Step_Details__c eachStepDetails : quoteApprovalStepDetailsPM){
            mapPMGroupIdVsOwnerId.put(eachStepDetails.Product_Manager_Approval_Group__c, eachStepDetails.Quote_Approver_Step_Approver_Detail__r.OwnerId); 
        }     
        
        List<Quote_Approval__c> quoteApprovalsToBeInserted = new List<Quote_Approval__c>();
        Set<Id> setOfPMs = new Set<Id>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductsWithPMNotification){
            Quote_Approval__c newQA = new Quote_Approval__c();
            newQA.BigMachines_Quote__c = eachQuoteProduct.BigMachines__Quote__c;
            newQA.Status__c = DealQualificationApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY;
            newQA.Reason_Name__c = eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c;
            newQA.Comments__c = 'No Approval Required.';
            newQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.PM_SHIPMENT_NOTIFICATION;
            newQA.Quote_Product__c = eachQuoteProduct.id;
            newQA.ownerId = mapPMGroupIdVsOwnerId.get(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c);
            if(!setOfPMs.contains(newQA.ownerId)){
                setOfPMs.add(newQA.ownerId);
                quoteApprovalsToBeInserted.add(newQA);            
            }
        }
        if(!quoteApprovalsToBeInserted.isEmpty()){
            Quote_Approval__c newQA = quoteApprovalsToBeInserted[0].clone(false, true, false, false);  
            newQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.AE_PM_SHIPMENT_NOTIFICATION;
            newQA.ownerId = UserInfo.getUserId();
            if(newQA.Reason_Name__c == DealQualificationApprovalUtil.NEW_PRODUCT_WITH_LIMITED
               && Label.Additional_emails_for_PM_Notification != ''){
                   newQA.Notification_Email__c = Label.Additional_emails_for_PM_Notification.split(',')[0];
                   newQA.Email_2__c = Label.Additional_emails_for_PM_Notification.split(',')[1];        
               }
            quoteApprovalsToBeInserted.add(newQA);
        }
        insert quoteApprovalsToBeInserted;
        
    }
    
    public static void sendNROPMApprovalNotifications(String orderId){
        
        List<Order_Line_Item__c> orderLineWithPMNotification = [SELECT Order__c, PM_Confirmation__c, 
                                                                Product__r.Shipment_Approval__c, 
                                                                Product__r.Product_Manager_Approval_Group__c FROM Order_Line_Item__c
                                                                WHERE Order__c =: orderId
                                                                AND id NOT IN (SELECT Order_Line_Item__c FROM Quote_Approval__c WHERE Order__c =: orderId AND Trigger_Email_Alert__c =: DealQualificationApprovalUtil.PM_SHIPMENT_NOTIFICATION)
                                                                AND Product__r.Product_Manager_Approval_Group__c != NULL
                                                                AND ( Product__r.Shipment_Approval__c =: DealQualificationApprovalUtil.PRODUCT_HAS_PREREQ 
                                                                     OR Product__r.Shipment_Approval__c =: DealQualificationApprovalUtil.NEW_PRODUCT_WITH_LIMITED 
                                                                     OR Product__r.Shipment_Approval__c =: DealQualificationApprovalUtil.NOTIFICATION_ONLY_SO_PM 
                                                                     OR Product__r.Shipment_Approval__c =:DealQualificationApprovalUtil.PRODUCT_AVAILABLE_FOR_EXP)];
        if(orderLineWithPMNotification.isEmpty())
            return ;
        Map<Id, Id> mapPMGroupIdVsOwnerId = new Map<Id, Id>(); 
        for(Order_Line_Item__c eachOLI : orderLineWithPMNotification){
            mapPMGroupIdVsOwnerId.put(eachOLI.Product__r.Product_Manager_Approval_Group__c, null);  
        }
        
        List<Quote_Approval_Step_Details__c> quoteApprovalStepDetailsPM = [SELECT Product_Manager_Approval_Group__c, Quote_Approver_Step_Approver_Detail__r.OwnerId
                                                                           FROM Quote_Approval_Step_Details__c WHERE Product_Manager_Approval_Group__c IN : mapPMGroupIdVsOwnerId.keyset()];
        if(quoteApprovalStepDetailsPM.isEmpty())
            return;
        
        for(Quote_Approval_Step_Details__c eachStepDetails : quoteApprovalStepDetailsPM){
            mapPMGroupIdVsOwnerId.put(eachStepDetails.Product_Manager_Approval_Group__c, eachStepDetails.Quote_Approver_Step_Approver_Detail__r.OwnerId); 
        }     
        
        List<Quote_Approval__c> quoteApprovalsToBeInserted = new List<Quote_Approval__c>();
        Set<Id> setOfPMs = new Set<Id>();
        for(Order_Line_Item__c eachOLI : orderLineWithPMNotification){
            Quote_Approval__c newQA = new Quote_Approval__c();
            newQA.Order__c = eachOLI.Order__c;
            newQA.Status__c = DealQualificationApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY;
            newQA.Reason_Name__c = eachOLI.Product__r.Shipment_Approval__c;
            newQA.Comments__c = 'No Approval Required.';
            newQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.PM_SHIPMENT_NOTIFICATION;
            newQA.Order_Line_Item__c = eachOLI.id;
            newQA.ownerId = mapPMGroupIdVsOwnerId.get(eachOLI.Product__r.Product_Manager_Approval_Group__c);
            if(newQA.OwnerId == null){                
                System.debug('NKC debug eachOLI.Product__r.Product_Manager_Approval_Group__c [' + eachOLI.Product__r.Product_Manager_Approval_Group__c + ']');
                System.debug('NKC debug newQA.Reason_Name__c [' + newQA.Reason_Name__c + ']');
            }
            if(!setOfPMs.contains(newQA.ownerId)){
                setOfPMs.add(newQA.ownerId);
                quoteApprovalsToBeInserted.add(newQA);            
            }      
        }
        if(!quoteApprovalsToBeInserted.isEmpty()){
            Quote_Approval__c newQA = quoteApprovalsToBeInserted[0].clone(false, true, false, false);  
            newQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.AE_PM_SHIPMENT_NOTIFICATION;
            newQA.ownerId = UserInfo.getUserId();
            if(newQA.Reason_Name__c == DealQualificationApprovalUtil.NEW_PRODUCT_WITH_LIMITED
               && Label.Additional_emails_for_PM_Notification != ''){
                   newQA.Notification_Email__c = Label.Additional_emails_for_PM_Notification.split(',')[0];
                   newQA.Email_2__c = Label.Additional_emails_for_PM_Notification.split(',')[1];        
               }      
            quoteApprovalsToBeInserted.add(newQA);
        }
        insert quoteApprovalsToBeInserted;    
    }
    
    public class wrapperViolationSummary{
        public String approvalName {get;set;}
        public String fieldValueOnQuote {get;set;}
        public String fieldValueApproved {get;set;}
        public String Description {get;set;}
        public wrapperViolationSummary(String approvalName, String fValueQuote, String fValueApproved, String vDesc){
            this.approvalName = approvalName;
            this.fieldValueOnQuote = fValueQuote;
            this.fieldValueApproved = fValueApproved;
            this.Description = vDesc;      
        }    
    }  
}