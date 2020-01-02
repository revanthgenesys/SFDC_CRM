//Naresh Kumar  07/17/2014
public without sharing class QuoteApprovalAssignmentHelper {
    
    public static Map<String, List<Quote_Approval_Config_And_Steps__c>> filterQuoteApprovals(BigMachines__Quote__c quote, List<Quote_Approval_Step_Details__c> quoteApprovals,
                                                                                             Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps){
                                                                                                 //will hold applicable records
                                                                                                 List<Quote_Approval_Step_Details__c> filteredApprovalRecords = new List<Quote_Approval_Step_Details__c>();
                                                                                                 //Will hold quote product records
                                                                                                 List<BigMachines__Quote_Product__c> quoteProducts = QuoteApprovalUtil.getQuoteProducts(quote.id);
                                                                                                 //Flag to determin whether there is third party discount or no on any of product
                                                                                                 Boolean isThirdPartyDiscount = false;
                                                                                                 //Product specific discount
                                                                                                 Boolean isProductSpecificDiscount = false;
                                                                                                 //GU Override
                                                                                                 Boolean isGUOverride = false;
                                                                                                 //BEP Override
                                                                                                 Boolean isBEPOverride = false;
                                                                                                 //will contain all product management approval groups for selected products
                                                                                                 Map<Id, Set<Id>> mapPMGroupIdVsProductIds = new Map<Id, Set<Id>>();
                                                                                                 //will contain all product management approval groups for selected products (email notifications only)
                                                                                                 Map<Id, Set<Id>> mapPMGroupIdVsProductIdsENO = new Map<Id, Set<Id>>();
                                                                                                 //will hold product id for which product management approval is submitted
                                                                                                 
                                                                                                 
                                                                                                 //Looping over each quote product record to update above flags
                                                                                                 for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProducts){
                                                                                                     if(eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c != null
                                                                                                        && eachQuoteProduct.Total_Discount__c != null
                                                                                                        && eachQuoteProduct.Total_Discount__c > eachQuoteProduct.BigMachines__Product__r.Product_Specific_Discount__c){
                                                                                                            //System.debug('NKC debug eachQuoteProduct.BigMachines__Product__r.Type__c [' + eachQuoteProduct.BigMachines__Product__r.Type__c  + ']');
                                                                                                            if(eachQuoteProduct.BigMachines__Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_GU)
                                                                                                                isGUOverride = true;                   
                                                                                                            else if(eachQuoteProduct.BigMachines__Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE 
                                                                                                                    || eachQuoteProduct.BigMachines__Product__r.Type__c == QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_HARDWARE)
                                                                                                                isBEPOverride = true;
                                                                                                            else
                                                                                                                isProductSpecificDiscount = true;
                                                                                                            if(eachQuoteProduct.BigMachines__Product__r.Third_Party__c != null
                                                                                                               && eachQuoteProduct.BigMachines__Product__r.Third_Party__c.toLowerCase() == 'true'){
                                                                                                                   isThirdPartyDiscount = true;
                                                                                                               }
                                                                                                        }    
                                                                                                     //System.debug('NKC debug isGUOverride [' + isGUOverride  + ']');   
                                                                                                     //System.debug('NKC debug eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c ['+eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c+']');  
                                                                                                     //Product Management
                                                                                                     if(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c != null
                                                                                                        && (eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c == QuoteApprovalUtil.REQUIRED_FOR_ALL_ORDERS
                                                                                                            || eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c == QuoteApprovalUtil.REQUIRED_FOR_NEW_ORDERS_ONLY)){               
                                                                                                                if(mapPMGroupIdVsProductIds.containsKey(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c)){
                                                                                                                    mapPMGroupIdVsProductIds.get(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c).add(eachQuoteProduct.BigMachines__Product__c);
                                                                                                                }
                                                                                                                else{
                                                                                                                    Set<Id> productIds = new Set<Id>();
                                                                                                                    productIds.add(eachQuoteProduct.BigMachines__Product__c);
                                                                                                                    mapPMGroupIdVsProductIds.put(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c, productIds);
                                                                                                                }
                                                                                                                //System.debug('NKC debug mapPMGroupIdVsProductIds ['+mapPMGroupIdVsProductIds+']');
                                                                                                                mapPMGroupIdVsProductIds = QuoteApprovalUtil.isAlreadyApprovedPMApproval(quote.id, mapPMGroupIdVsProductIds, QuoteApprovalUtil.STATUS_APPROVED);
                                                                                                            }
                                                                                                     else if(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c != null
                                                                                                             && eachQuoteProduct.BigMachines__Product__r.Shipment_Approval__c == QuoteApprovalUtil.NOTIFICATION_ONLY){               
                                                                                                                 if(mapPMGroupIdVsProductIdsENO.containsKey(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c)){
                                                                                                                     mapPMGroupIdVsProductIdsENO.get(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c).add(eachQuoteProduct.BigMachines__Product__c);
                                                                                                                 }
                                                                                                                 else{
                                                                                                                     Set<Id> productIds = new Set<Id>();
                                                                                                                     productIds.add(eachQuoteProduct.BigMachines__Product__c);
                                                                                                                     mapPMGroupIdVsProductIdsENO.put(eachQuoteProduct.BigMachines__Product__r.Product_Manager_Approval_Group__c, productIds);
                                                                                                                 }
                                                                                                                 mapPMGroupIdVsProductIdsENO = QuoteApprovalUtil.isAlreadyApprovedPMApproval(quote.id, mapPMGroupIdVsProductIdsENO, QuoteApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY);
                                                                                                             }       
                                                                                                     
                                                                                                 }
                                                                                                 //System.debug('NKC debug mapPMGroupIdVsProductIds ['+mapPMGroupIdVsProductIds+']');
                                                                                                 //System.debug('NKC debug isThirdPartyDiscount ['+isThirdPartyDiscount+']');
                                                                                                 
                                                                                                 //System.debug('NKC debug quoteApprovals ['+quoteApprovals+']');  
                                                                                                 //System.debug('NKC debug quoteApprovals.size() ['+quoteApprovals.size()+']');
                                                                                                 //will hold filtered record and return values   
                                                                                                 Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndStepsFiltered = new Map<String, List<Quote_Approval_Config_And_Steps__c>>(); 
                                                                                                 Integer counter = 1;
                                                                                                 Boolean doBreakLoop = false;
                                                                                                 //Looping over each approval record
                                                                                                 for(Quote_Approval_Step_Details__c eachQASD : quoteApprovals){
                                                                                                     List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps = mapIdVsQuoteConfigAndSteps.get(eachQASD.Quote_Approval_Step__c);            
                                                                                                     //will have filtered list of config and their steps
                                                                                                     List<Quote_Approval_Config_And_Steps__c> quoteApprovalFilteredConfigAndSteps = new List<Quote_Approval_Config_And_Steps__c>();            
                                                                                                     for(Quote_Approval_Config_And_Steps__c eachQACS : quoteApprovalConfigAndSteps){               
                                                                                                         Boolean isRecordApplicable = false;
                                                                                                         //if approval type is null, just skip the record
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c == null)
                                                                                                             continue;
                                                                                                         System.debug('NKC debug quote.Minor_Quote_Change_Approval__c ['+quote.Minor_Quote_Change_Approval__c+']');
                                                                                                         System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c ['+eachQACS.Quote_Approval_Config__r.Approval_Type__c+']');
                                                                                                         
                                                                                                         //Minor Quote Change Approval - Cloud BE
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_MINOR_QUOTE_CHANGE_APPROVAL)
                                                                                                            && quote.Minor_Quote_Change_Approval__c){
                                                                                                                System.debug('NKC debug quote.Minor_Quote_Change_Approval__c ['+quote.Minor_Quote_Change_Approval__c+']');
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                                quoteApprovalFilteredConfigAndSteps.clear();
                                                                                                                quoteApprovalFilteredConfigAndSteps.add(eachQACS);
                                                                                                                doBreakLoop = true;
                                                                                                                break;
                                                                                                            }    
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_DISCOUNT)
                                                                                                            && quote.Total_Discount_Genesys_Products_Only__c != null && (quote.Pricing_Model__c == eachQACS.Quote_Approval_Config__r.Pricing_Model__c 
                                                                                                                                                                         || eachQACS.Quote_Approval_Config__r.Pricing_Model__c == null)){
                                                                                                                                                                             Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(quote.Total_Discount_Genesys_Products_Only__c));  
                                                                                                                                                                             if(isApplicable)
                                                                                                                                                                                 isRecordApplicable = true;          
                                                                                                                                                                         } 
                                                                                                         
                                                                                                         //ELA
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_ELA)
                                                                                                            && quote.ELA__c){               
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;              
                                                                                                            }
                                                                                                         //Pricing Model - Concurrent
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)
                                                                                                            && quote.Pricing_Model__c  != null
                                                                                                            && quote.Pricing_Model__c == QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT){             
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }               
                                                                                                         //Expiration Date
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE)             
                                                                                                            && eachQACS.Quote_Approval_Config__r.No_Of_Days_After_Quote_Expires__c != null && quote.Expiration_Date__c != null
                                                                                                            && System.today().addDays(Integer.ValueOf(eachQACS.Quote_Approval_Config__r.No_Of_Days_After_Quote_Expires__c)) < quote.Expiration_Date__c){             
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Special Offer Terms
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS)
                                                                                                            &&  quote.Include_Special_Offer_in_Output__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Initial Subscription Term
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c < quote.No_Of_Months__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Ramp Period
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c < Decimal.valueof(quote.Ramp_Period__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PEC Deal
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_Cloud_Deal))
                                                                                                         {  
                                                                                                             Decimal decUSDACV = DDSCloud.converttoUSD(quote.Offering_Type__c,quote.New_Price_Book__c,quote.CurrencyIsoCode,quote.Annual_Contract_Value__c);
                                                                                                             if(decUSDACV  <= eachQACS.Quote_Approval_Config__r.Threshold_From__c)
                                                                                                             {
                                                                                                                 //History check
                                                                                                                 //&& (dqHistory == null )
                                                                                                                 
                                                                                                                 filteredApprovalRecords.add(eachQASD);
                                                                                                                 isRecordApplicable = true;
                                                                                                             }
                                                                                                         }
                                                                                                         
                                                                                                         //Deal Score Cloud
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD )
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c >= quote.Deal_Score__c)
                                                                                                             
                                                                                                         {
                                                                                                             filteredApprovalRecords.add(eachQASD);
                                                                                                             isRecordApplicable = true;
                                                                                                         }
                                                                                                         //Third Party Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_THIRDPARTY)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c <=quote.Third_Party_Discount__c )
                                                                                                             
                                                                                                         {
                                                                                                             filteredApprovalRecords.add(eachQASD);
                                                                                                             isRecordApplicable = true;
                                                                                                         }
                                                                                                         //PC PS Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PSDISCOUNT )
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c < quote.Professional_Services_Discount__c ){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PC Harware Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT )
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c < quote.Hardware_Discount__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PC Software Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT )
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c < quote.Software_Discount__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PC Overage Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT )
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c < quote.Overage_Discount__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //PC TCV Reduction
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_TCVREDUCTION )
                                                                                                            && quote.Total_Contract_Value_Change__c != null && quote.Total_Contract_Value_Change__c < 0){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Business Exceptions CMRR
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR)
                                                                                                            && DealQualificationApprovalUtil.convertCurrency(Double.valueof(quote.CMRR__c), quote.CurrencyIsoCode) < 14000){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Billing Period
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c == DealQualificationApprovalUtil.getBillingPeriod(quote.Billing_Period__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Payment Terms
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&  eachQACS.Quote_Approval_Config__r.Threshold_From__c <= Decimal.valueof(quote.Order_Payment_Terms__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Care Override
                                                                                                         if(quote.Genesys_Care_Rate__c != null && quote.Genesys_Care_Default_Pricing_Percentage__c != null){                    
                                                                                                             if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE)
                                                                                                                && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c != null
                                                                                                                && (quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c) > 0
                                                                                                                && (((quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c)  >= 3 
                                                                                                                     && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c == QuoteApprovalUtil.GC_THRESHOLD_GREATER_THEN_OR_EQUAL_TO_THREE))                      
                                                                                                                ||                      
                                                                                                                ((quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c) > 2 
                                                                                                                 && (quote.Genesys_Care_Default_Pricing_Percentage__c - quote.Genesys_Care_Rate__c) < 3
                                                                                                                 && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c == QuoteApprovalUtil.GC_THRESHOLD_GREATER_THAN_TWO)
                                                                                                               ){
                                                                                                                   filteredApprovalRecords.add(eachQASD);
                                                                                                                   isRecordApplicable = true;      
                                                                                                               }            
                                                                                                         }
                                                                                                         //Deal Size
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SIZE)
                                                                                                            && quote.BigMachines__Total__c != null){
                                                                                                                Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(quote.BigMachines__Total__c));
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;              
                                                                                                            }
                                                                                                         System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c [' + eachQACS.Quote_Approval_Config__r.Approval_Type__c+ ']');
                                                                                                         //Term Reduced
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_TERM_REDUCED)
                                                                                                            && quote.Duration_Unit__c != null
                                                                                                            && ((quote.Duration_Unit__c.equals('Days') && quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c < QuoteApprovalUtil.STANDARD_TERM_DAYS)
                                                                                                                || (quote.Duration_Unit__c.equals('Months') && quote.Order_Numb_of_Maint_Months__c != null && quote.Order_Numb_of_Maint_Months__c < QuoteApprovalUtil.STANDARD_TERM_MONTHS))){
                                                                                                                    filteredApprovalRecords.add(eachQASD);
                                                                                                                    isRecordApplicable = true;      
                                                                                                                }
                                                                                                         //Term Increased
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_TERM_INCREASED)
                                                                                                            && quote.Duration_Unit__c != null
                                                                                                            && ((quote.Duration_Unit__c.equals('Days') && quote.Order_Numb_of_Maint_Days__c != null && quote.Order_Numb_of_Maint_Days__c > QuoteApprovalUtil.STANDARD_TERM_DAYS)
                                                                                                                || (quote.Duration_Unit__c.equals('Months') && quote.Order_Numb_of_Maint_Months__c != null && quote.Order_Numb_of_Maint_Months__c > QuoteApprovalUtil.STANDARD_TERM_MONTHS))){
                                                                                                                    filteredApprovalRecords.add(eachQASD);
                                                                                                                    isRecordApplicable = true;      
                                                                                                                }
                                                                                                         //Service Level - Decline
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE)
                                                                                                            && quote.Service_Level__c  != null
                                                                                                            && quote.Service_Level__c == QuoteApprovalUtil.DECLINE){                
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Revision
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_REVISION)
                                                                                                            && quote.Revise_Minor__c){              
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //3rd Party
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_THIRD_PARTY)
                                                                                                            && isThirdPartyDiscount){               
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                   
                                                                                                         //Product Specific
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC)
                                                                                                            && (!isThirdPartyDiscount || (isThirdPartyDiscount && (quote.Offering_Type__c == 'PureCloud' || quote.Offering_Type__c == 'PureConnect Cloud')))
                                                                                                            && isProductSpecificDiscount){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                       
                                                                                                         //CAD Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)
                                                                                                            && quote.CAD_Override__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Premium Care
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE)
                                                                                                            && quote.Service_Level__c  != null
                                                                                                            && quote.Service_Level__c == QuoteApprovalUtil.PREMIUM){                
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //System.debug('NKC debug isGUOverride [' + isGUOverride + ']');
                                                                                                         //System.debug('NKC debug QuoteApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE[' + QuoteApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE+ ']');
                                                                                                         
                                                                                                         
                                                                                                         //GU Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE)
                                                                                                            && isGUOverride){                    
                                                                                                                System.debug('NKC debug in condition.');
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //BEP Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE)
                                                                                                            && isBEPOverride){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Additional Legal Terms
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS)
                                                                                                            && quote.Additional_Legal_Terms__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Editable List Price 
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE)
                                                                                                            && quote.Editable_List_Price_Approval_Required__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }         
                                                                                                         
                                                                                                         //System.debug('NKC debug eachQASD.Product_Manager_Approval_Group__c   ['+eachQASD.Product_Manager_Approval_Group__c+']');
                                                                                                         //System.debug('NKC debug mapPMGroupIdVsProductIds   ['+mapPMGroupIdVsProductIds+']');
                                                                                                         //Product Management                
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT)
                                                                                                            && (mapPMGroupIdVsProductIds.containsKey(eachQASD.Product_Manager_Approval_Group__c)
                                                                                                                || mapPMGroupIdVsProductIdsENO.containsKey(eachQASD.Product_Manager_Approval_Group__c))){                   
                                                                                                                    if(mapPMGroupIdVsProductIdsENO.containsKey(eachQASD.Product_Manager_Approval_Group__c)){
                                                                                                                        eachQASD.Quote_Approver_Step_Approver_Detail__r.Action_Text__c = QuoteApprovalUtil.NOTIFICATION_ONLY;
                                                                                                                    }
                                                                                                                    if(mapPMGroupIdVsProductIds.get(eachQASD.Product_Manager_Approval_Group__c) != null){
                                                                                                                        String productIds = String.valueOf(mapPMGroupIdVsProductIds.get(eachQASD.Product_Manager_Approval_Group__c));
                                                                                                                        productIds = productIds.replace('{','').replace('}','');
                                                                                                                        //System.debug('NKC debug productIds ['+productIds+']');
                                                                                                                        eachQASD.Quote_Approver_Step_Approver_Detail__r.Product_Ids__c = productIds; 
                                                                                                                        eachQASD.Quote_Approver_Step_Approver_Detail__r.PM_Group_Id__c = eachQASD.Product_Manager_Approval_Group__c;
                                                                                                                    }
                                                                                                                    filteredApprovalRecords.add(eachQASD);
                                                                                                                    isRecordApplicable = true;
                                                                                                                }
                                                                                                         
                                                                                                         if(isRecordApplicable){
                                                                                                             System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c ['+eachQACS.Quote_Approval_Config__r.Approval_Type__c+']');
                                                                                                             //System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Threshold_From__c ['+eachQACS.Quote_Approval_Config__r.Threshold_From__c+']');
                                                                                                             quoteApprovalFilteredConfigAndSteps.add(eachQACS);
                                                                                                         }
                                                                                                     }       
                                                                                                     if(!quoteApprovalFilteredConfigAndSteps.isEmpty())
                                                                                                         mapIdVsQuoteConfigAndStepsFiltered.put(eachQASD.Quote_Approval_Step__c, quoteApprovalFilteredConfigAndSteps);
                                                                                                     if(doBreakLoop)
                                                                                                         break;
                                                                                                 }
                                                                                                 //System.debug('NKC debug mapIdVsQuoteConfigAndStepsFiltered ['+mapIdVsQuoteConfigAndStepsFiltered+']');
                                                                                                 quoteApprovals.clear();
                                                                                                 quoteApprovals.addAll(filteredApprovalRecords);
                                                                                                 return mapIdVsQuoteConfigAndStepsFiltered;
                                                                                             } 
    
    public static String populateReasonToCurrentApprovalRecord(BigMachines__Quote__c quote, Quote_Approval_Step_Details__c quoteApprovalStepDetail,
                                                               List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps, String approvalReason){
                                                                   //Would contain unique reaons
                                                                   Set<String> uniqueReason = new Set<String>();       
                                                                   if(approvalReason == null)
                                                                       approvalReason = '';
                                                                   System.debug('NKC debug uniqueReason ['+quoteApprovalConfigAndSteps+']');
                                                                   for(Quote_Approval_Config_And_Steps__c eachQACS : quoteApprovalConfigAndSteps){
                                                                       System.debug('NKC debug uniqueReason ['+uniqueReason+']');
                                                                       System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c ['+eachQACS.Quote_Approval_Config__r.Approval_Type__c+']');
                                                                       System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Threshold_From__c ['+eachQACS.Quote_Approval_Config__r.Threshold_From__c+']');
                                                                       
                                                                       //Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_DISCOUNT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_DISCOUNT)){
                                                                               String pricingModel = quote.Pricing_Model__c;                    
                                                                               if(eachQACS.Quote_Approval_Config__r.Threshold_From__c == 0){
                                                                                   approvalReason += pricingModel + ' Deal, ';                      
                                                                               }
                                                                               else{
                                                                                   approvalReason += pricingModel + ' Discount greater than or equal to '+ 
                                                                                       eachQACS.Quote_Approval_Config__r.Threshold_From__c + '% (Discount on Quote is : ' + quote.Total_Discount_Genesys_Products_Only__c.setScale(2) + '%), ';                      
                                                                               }
                                                                               System.debug('NKC debug approvalReason ['+approvalReason+']');
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_DISCOUNT);
                                                                           }
                                                                       }           
                                                                       //ELA
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_ELA)){               
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_ELA)){
                                                                               approvalReason += 'ELA, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_ELA);
                                                                           }
                                                                       }
                                                                       System.debug('NKC debug uniqueReason ['+uniqueReason+']');
                                                                       System.debug('NKC debug approvalReason ['+approvalReason+']');
                                                                       
                                                                       //Pricing Model - Concurrent
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)){
                                                                               approvalReason += 'Pricing Model - Concurrent, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT);
                                                                           }
                                                                       }
                                                                       //Expiration Date
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE)){                           
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE)){
                                                                               approvalReason += 'Expiry Date Extended, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE);
                                                                           }
                                                                       }
                                                                       //Special Offer Terms
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS)){
                                                                               approvalReason += 'Special Offer Terms, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS);
                                                                           }
                                                                       }
                                                                       //Initial Subscription Term
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM);
                                                                           }                    
                                                                       }
                                                                       
                                                                       //Ramp Period
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD);
                                                                           }                    
                                                                       }
                                                                       
                                                                       //PEC Deal
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_Cloud_Deal)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_Cloud_Deal)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_Cloud_Deal + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_Cloud_Deal);
                                                                           }                    
                                                                       }
                                                                       
                                                                       //Deal Score Cloud
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD );
                                                                           }                    
                                                                       }
                                                                       
                                                                       //Third Party Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_THIRDPARTY)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_THIRDPARTY )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_THIRDPARTY + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_THIRDPARTY );
                                                                           }                    
                                                                       }
                                                                       
                                                                       //Billing Period
                                                                       
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD )){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD );
                                                                           }                    
                                                                       }
                                                                       //Monthly Mininum
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM );
                                                                           }                    
                                                                       }
                                                                       
                                                                       //PC Credit
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PC_Credit)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PC_Credit)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_PC_Credit+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PC_Credit);
                                                                           }                    
                                                                       }
                                                                       //PCC Credit-Rony Joseph-April 17th 2019 -PCC Credit Step-Begin   
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PCC_Credit)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PCC_Credit)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_PCC_Credit+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PCC_Credit);
                                                                           }                    
                                                                       }
                                                                       //PCC Credit-Rony Joseph-April 17th 2019 -PCC Credit Step-End
                                                                       //PEC Credit-Rony Joseph-August 7th 2019 -PEC Credit Step-Begin   
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PEC_Credit)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PEC_Credit)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_PEC_Credit+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PEC_Credit);
                                                                           }                    
                                                                       }
                                                                       //PEC Credit-Rony Joseph-August 7th 2019 -PEC Credit Step-End
                                                                       //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- Start  
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM);
                                                                           }                    
                                                                       }
                                                                       
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY);
                                                                           }                    
                                                                       }
                                                                       //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- End  
                                                                       //PC Trial
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PC_Trial )){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PC_Trial )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_PC_Trial + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PC_Trial );
                                                                           }                    
                                                                       }
                                                                       
                                                                       //PC PS Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PSDISCOUNT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PSDISCOUNT )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_PSDISCOUNT + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PSDISCOUNT );
                                                                           }                    
                                                                       }
                                                                       //PC Hardware Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT );
                                                                           }                    
                                                                       }
                                                                       
                                                                       //PC Software Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT )){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT + ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT );
                                                                           }                    
                                                                       } 
                                                                       
                                                                       //PC Overage Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT);
                                                                           }                    
                                                                       } 
                                                                       
                                                                       //PC TCV Reduction
                                                                       
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_TCVREDUCTION)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_TCVREDUCTION)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_TCVREDUCTION+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_TCVREDUCTION);
                                                                           }                    
                                                                       } 
                                                                       
                                                                       //Payment Terms
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS)){
                                                                               approvalReason += QuoteApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS+ ', ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS);
                                                                           }                    
                                                                       }
                                                                       //Care Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE)){
                                                                               String thresholdReason = '';
                                                                               approvalReason += 'Genesys Care Override ' + eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c + '%, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE);
                                                                           }       
                                                                       } 
                                                                       
                                                                       //Deal Size
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SIZE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SIZE)){
                                                                               approvalReason += 'Deal size greater than or equal to '+ 
                                                                                   updateAmountToReadableFormat(eachQACS.Quote_Approval_Config__r.Threshold_From__c) + ' (Deal size on Quote is : ' + updateAmountToReadableFormat(quote.BigMachines__Total__c.setScale(2)) + '), ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_DEAL_SIZE);
                                                                           }
                                                                       }
                                                                       //Term Reduced
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_TERM_REDUCED)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_TERM_REDUCED)){
                                                                               approvalReason += 'Term Reduced, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_TERM_REDUCED);
                                                                           }       
                                                                       }
                                                                       //Term Increased
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_TERM_INCREASED)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_TERM_INCREASED)){
                                                                               approvalReason += 'Term Increased, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_TERM_INCREASED);
                                                                           }       
                                                                       }
                                                                       //Service Level - Decline
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)){
                                                                               approvalReason += 'Genesys Care - Decline, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT);
                                                                           }
                                                                       }
                                                                       //Revision
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_REVISION)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_REVISION)){
                                                                               approvalReason += 'Minor Quote Changes, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_REVISION);
                                                                           }
                                                                       }       
                                                                       //3rd Party
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_THIRD_PARTY)){               
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_THIRD_PARTY)){
                                                                               approvalReason += '3rd Party Discount, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_THIRD_PARTY);
                                                                           }   
                                                                       }                   
                                                                       //Product Specific
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC)){
                                                                               approvalReason += 'Product Specific Discount, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC);
                                                                           }
                                                                       }
                                                                       //Premium Care
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE)){
                                                                               approvalReason += 'Premium Care, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE);
                                                                           }
                                                                       }
                                                                       //CAD Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)){
                                                                               approvalReason += 'CAD Override, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE);
                                                                           }
                                                                       }   
                                                                       //GU Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)){
                                                                               approvalReason += 'GU Override, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE);
                                                                           }
                                                                       }   
                                                                       //BEP Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE)){
                                                                               approvalReason += 'BEP Override, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE);
                                                                           }
                                                                       }  
                                                                       //Additional Legal Terms
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS)){
                                                                               approvalReason += 'Additional Legal Terms, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS);
                                                                           }
                                                                       }
                                                                       //Editable List Price 
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE)){
                                                                               approvalReason += 'Editable List Price , ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE);
                                                                           }
                                                                       }   
                                                                       //Minor Quote Change Approval - Cloud BE
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_MINOR_QUOTE_CHANGE_APPROVAL)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_MINOR_QUOTE_CHANGE_APPROVAL)){
                                                                               approvalReason += 'Minor Quote Change Approval , ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_MINOR_QUOTE_CHANGE_APPROVAL);
                                                                           }
                                                                       }
                                                                       //Product management
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT)){
                                                                           if(!uniqueReason.contains(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT)){
                                                                               approvalReason += 'PM Approval, ';
                                                                               uniqueReason.add(QuoteApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT);
                                                                           }
                                                                       }
                                                                   }
                                                                   return approvalReason;
                                                               }   
    
    private static Boolean getApprovalForThresholdTypeIfAny(List<Quote_Approval_Step_Details__c> filteredApprovalRecords,
                                                            Quote_Approval_Config_And_Steps__c eachQACS, Quote_Approval_Step_Details__c eachQASD, Double valueOnQuote){     
                                                                if(eachQACS.Quote_Approval_Config__r.Threshold_From__c != null 
                                                                   && (valueOnQuote >= eachQACS.Quote_Approval_Config__r.Threshold_From__c 
                                                                       && (eachQACS.Quote_Approval_Config__r.Threshold_To__c == null ||
                                                                           valueOnQuote <= eachQACS.Quote_Approval_Config__r.Threshold_To__c))){
                                                                               filteredApprovalRecords.add(eachQASD);
                                                                               return true;
                                                                           }       
                                                                return false;
                                                            }
    
    
    public static Set<Id> getAlreadyApprovedRecords(BigMachines__Quote__c quote,  Decimal submissionCounter){
        Set<Id> setAlreadyApprovedStepDetailsIds = new Set<Id>();
        
        //Will contain already approved config records
        List<Quote_Approval__c> quoteApprovalsApproved = [SELECT Quote_Approval_Step_Details__c FROM Quote_Approval__c
                                                          WHERE BigMachines_Quote__c =: quote.id              
                                                          AND Status__c =: QuoteApprovalUtil.STATUS_APPROVED AND Approval_Submission_Counter__c =: (submissionCounter -1)];
        for(Quote_Approval__c eachQA : quoteApprovalsApproved){
            setAlreadyApprovedStepDetailsIds.add(eachQA.Quote_Approval_Step_Details__c);
        }
        System.debug('NKC debug setAlreadyApprovedStepDetailsIds ['+setAlreadyApprovedStepDetailsIds+']');
        return setAlreadyApprovedStepDetailsIds;
    }
    
    public static List<Quote_Approval_Step_Details__c> getQuoteApprovalsIfReviseQuoteIsApplicableUpfront(BigMachines__Quote__c quote, Decimal submissionCounter){
        if(!quote.Revise_Minor__c)
            return null;
        String reviseMinorType = QuoteApprovalUtil.MINOR_QUOTE_CHANGE_ONLY; 
        if(quote.Expiration_Date__c > System.today().addDays(91)){              
            reviseMinorType = QuoteApprovalUtil.EXPIRATION_DATE_ONLY;
        }
        Set<Id> stepIds = new Set<Id>();
        //Getting quote approvals steps
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = QuoteApprovalUtil.getQuoteApprvalConfigRecords(quote, stepIds);
        //Getting quote approval records
        List<Quote_Approval_Step_Details__c> quoteApprovers = QuoteApprovalUtil.getQuoteApprovalRecords(stepIds, quote);         
        //Filters quote approval records for current quote
        mapIdVsQuoteApprovalSteps = QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote, quoteApprovers, mapIdVsQuoteApprovalSteps);
        List<Quote_Approval_Step_Details__c> quoteApprovalStepDetails = new List<Quote_Approval_Step_Details__c>();
        //would hold quote approval records to be inserted
        List<Quote_Approval__c> quoteApprovals = new List<Quote_Approval__c>();
        //Would store first order no
        Decimal firstOrderNo = 0;
        //Set of approvers
        Set<Id> setOfApprovers = new Set<Id>();
        //Looping over each approval
        for(Quote_Approval_Step_Details__c eachRecord : quoteApprovers){
            if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == null
               || (eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == QuoteApprovalUtil.EXPIRATION_DATE_ONLY
                   && reviseMinorType == QuoteApprovalUtil.MINOR_QUOTE_CHANGE_ONLY)          
               || setOfApprovers.contains(eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId))
                continue;
            if(firstOrderNo == 0)
                firstOrderNo = eachRecord.Quote_Approval_Step__r.Order__c;
            //New quote approvals record
            Quote_Approval__c newQuoteApproval = new Quote_Approval__c();
            newQuoteApproval.BigMachines_Quote__c = quote.id;
            newQuoteApproval.Submitted_Date__c = System.now();
            newQuoteApproval.Quote_Approval_Step_Details__c = eachRecord.id;
            //Populating Step No
            newQuoteApproval.Step__c = eachRecord.Quote_Approval_Step__r.Order__c;
            //Approver
            newQuoteApproval.ownerId = eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId;
            setOfApprovers.add(eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId);
            quoteApprovalStepDetails.add(eachRecord);
            //Update Pending status for only next step
            if(firstOrderNo == eachRecord.Quote_Approval_Step__r.Order__c)
                newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_PENDING;
            else
                newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_INACTIVE;
            
            if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c  == QuoteApprovalUtil.EXPIRATION_DATE_ONLY)
                newQuoteApproval.Reason_Name__c = 'Minor Revision, Expiration Date';
            else
                newQuoteApproval.Reason_Name__c = 'Minor Revision';
            newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
            quoteApprovals.add(newQuoteApproval);
        }
        return quoteApprovalStepDetails;
    }
    
    public static List<Quote_Approval__c> getQuoteApprovalsIfReviseQuoteIsApplicable(BigMachines__Quote__c quote, Decimal submissionCounter, Boolean Upfront){
        if(!quote.Revise_Minor__c)
            return null;
        String reviseMinorType = QuoteApprovalUtil.MINOR_QUOTE_CHANGE_ONLY; 
        if(quote.Expiration_Date__c > System.today().addDays(91)){              
            reviseMinorType = QuoteApprovalUtil.EXPIRATION_DATE_ONLY;
        }
        Set<Id> stepIds = new Set<Id>();
        //Getting quote approvals steps
        Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = QuoteApprovalUtil.getQuoteApprvalConfigRecords(quote, stepIds);
        //Getting quote approval records
        List<Quote_Approval_Step_Details__c> quoteApprovers = QuoteApprovalUtil.getQuoteApprovalRecords(stepIds, quote);         
        //Filters quote approval records for current quote
        mapIdVsQuoteApprovalSteps = QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote, quoteApprovers, mapIdVsQuoteApprovalSteps);
        List<Quote_Approval_Step_Details__c> quoteApprovalStepDetails = new List<Quote_Approval_Step_Details__c>();
        //would hold quote approval records to be inserted
        List<Quote_Approval__c> quoteApprovals = new List<Quote_Approval__c>();
        //Would store first order no
        Decimal firstOrderNo = 0;
        //Set of approvers
        Set<Id> setOfApprovers = new Set<Id>();
        //Looping over each approval
        for(Quote_Approval_Step_Details__c eachRecord : quoteApprovers){
            if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == null
               || (eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == QuoteApprovalUtil.EXPIRATION_DATE_ONLY
                   && reviseMinorType == QuoteApprovalUtil.MINOR_QUOTE_CHANGE_ONLY)          
               || setOfApprovers.contains(eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId))
                continue;
            if(firstOrderNo == 0)
                firstOrderNo = eachRecord.Quote_Approval_Step__r.Order__c;
            //New quote approvals record
            Quote_Approval__c newQuoteApproval = new Quote_Approval__c();
            newQuoteApproval.BigMachines_Quote__c = quote.id;
            newQuoteApproval.Submitted_Date__c = System.now();
            newQuoteApproval.Quote_Approval_Step_Details__c = eachRecord.id;
            //Populating Step No
            newQuoteApproval.Step__c = eachRecord.Quote_Approval_Step__r.Order__c;
            //Approver
            newQuoteApproval.ownerId = eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId;
            setOfApprovers.add(eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId);
            quoteApprovalStepDetails.add(eachRecord);
            //Update Pending status for only next step
            if(firstOrderNo == eachRecord.Quote_Approval_Step__r.Order__c)
                newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_PENDING;
            else
                newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_INACTIVE;
            if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c  == QuoteApprovalUtil.EXPIRATION_DATE_ONLY)
                newQuoteApproval.Reason_Name__c = 'Minor Revision, Expiration Date';
            else
                newQuoteApproval.Reason_Name__c = 'Minor Revision';
            newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
            quoteApprovals.add(newQuoteApproval);
        }
        if(quoteApprovals.isEmpty())
            return null;
        return quoteApprovals;
    }
    
    public static void approvalRejectionActions(String quoteId){
        //Getting approval submission order
        Decimal submissionCounter = QuoteApprovalUtil.getApprovalSubmission(quoteId, -1);
        System.debug('NKC debug submissionCounter ['+submissionCounter+']');
        //Getting approval records from last submission
        List<Quote_Approval__c> quoteApprovalsToBeDeActivated = [SELECT Status__c FROM Quote_Approval__c 
                                                                 WHERE BigMachines_Quote__c =: quoteId AND Approval_Submission_Counter__c =: submissionCounter];
        //Looping over each quote approval record and updating status
        for(Quote_Approval__c eachQA : quoteApprovalsToBeDeActivated){
            if(eachQA.Status__c == QuoteApprovalUtil.STATUS_PENDING){
                eachQA.Status__c = QuoteApprovalUtil.STATUS_CANCELLED;
                eachQA.Comments__c = 'Quote Rejected.';
            }
            eachQA.Trigger_Email_Alert__c = QuoteApprovalUtil.QUOTE_REJECTED_BEFORE_APPROVAL;
        }
        update quoteApprovalsToBeDeActivated;
    }
    
    public static void byPassApprovals(String quoteId){
        //Getting approval submission order
        Decimal submissionCounter = QuoteApprovalUtil.getApprovalSubmission(quoteId, -1);
        //Getting approval records from last submission
        List<Quote_Approval__c> quoteApprovalsToBeApproved = [SELECT Status__c FROM Quote_Approval__c 
                                                              WHERE BigMachines_Quote__c =: quoteId 
                                                              AND Status__c =: QuoteApprovalUtil.STATUS_PENDING 
                                                              AND Approval_Submission_Counter__c =: submissionCounter];
        //Looping over each quote approval record and updating status
        for(Quote_Approval__c eachQA : quoteApprovalsToBeApproved){
            eachQA.Status__c = QuoteApprovalUtil.STATUS_APPROVED;            
            eachQA.Comments__c = QuoteApprovalUtil.APPROVAL_BY_PASSED;
            eachQA.Actual_Approver__c = UserInfo.getUserId();
        }
        update quoteApprovalsToBeApproved;   
    }
    
    public static void quoteRevisionActions(BigMachines__Quote__c currentQuote){
        if(currentQuote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING){
            //Getting approval submission order
            Decimal submissionCounter = QuoteApprovalUtil.getApprovalSubmission(currentQuote.id, -1);
            //Getting approval records from last submission
            List<Quote_Approval__c> quoteApprovalsToBeDeActivated = [SELECT Status__c FROM Quote_Approval__c 
                                                                     WHERE BigMachines_Quote__c =: currentQuote.id 
                                                                     AND Status__c =: QuoteApprovalUtil.STATUS_PENDING 
                                                                     AND Approval_Submission_Counter__c =: submissionCounter];
            //Looping over each quote approval record and updating status
            for(Quote_Approval__c eachQA : quoteApprovalsToBeDeActivated){
                eachQA.Status__c = QuoteApprovalUtil.STATUS_CANCELLED;
                eachQA.Trigger_Email_Alert__c = QuoteApprovalUtil.QUOTE_REVISED_BEFORE_APPROVAL;
                eachQA.Comments__c = 'Quote Revised.'; 
            }
            update quoteApprovalsToBeDeActivated;
        }       
    }
    
    private static String updateAmountToReadableFormat(Decimal amount){
        Integer amountInt = Integer.valueOf(amount);
        String amountStr;
        if(amountInt > 999 && amountInt <= 999999){
            amountInt /= 1000;
            amountStr = String.valueOf(amountInt) + 'K';  
        }
        else if(amountInt > 999999 && amountInt <= 99999999){
            amountInt /= 1000000;
            amountStr = String.valueOf(amountInt) + 'M';  
        }
        else if(amountInt > 99999999){
            amountInt /= 100000000;
            amountStr = String.valueOf(amountInt) + 'B';  
        }      
        return amountStr;
    }
    
    public static String orderReasons(String reason){
        if(reason == null)
            return reason;
        List<String> reasons = reason.split(',');
        if(reasons.size() > 1){
            reasons.sort();
            Integer counter = 1;
            reason = '';
            for(String eachReason : reasons){
                if(reasons.size() == counter)
                    reason += eachReason;
                else
                    reason += eachReason + ', ';
                counter ++;
            }
        }
        return reason;
    }
    
    public static void approveDuplicateApproverRecords(Map<Id, Quote_Approval__c> oldMap, List<Quote_Approval__c> quoteApproval){
        if(quoteApproval[0].Status__c == QuoteApprovalUtil.STATUS_APPROVED 
           && oldMap.get(quoteApproval[0].id).Status__c != QuoteApprovalUtil.STATUS_APPROVED){
               if(quoteApproval[0].BigMachines_Quote__c != null)
                   approveDuplicateApproverRecordsQuote(UserInfo.getUserId(), quoteApproval[0].BigMachines_Quote__c); 
               else if(quoteApproval[0].Deal_Qualification__c != null)
                   approveDuplicateApproverRecordsDQ(UserInfo.getUserId(), quoteApproval[0].Deal_Qualification__c);
           }        
    }
    
    public static void approveDuplicateApproverRecordsDQ(Id approverId, Id dqId){
        // Process the duplicate check only for specified list of users (Currently just Brian Bischoff)
        Set<String> set_UserIds = new Set<String>(Global_Configuration_Settings__c.getOrgDefaults().BE_DAP_User_Check__c.split(';'));
        //if(!set_UserIds.contains(approverId))
        //  return;
        
        //Will hold all potential approvers ids (user and group)
        Set<String> setOfApprovers = new Set<String>();
        //Adding current user id
        setOfApprovers.add(approverId);
        List<GroupMember> groupMembers = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId =: approverId];
        //Adding queues
        for(GroupMember eachMember : groupMembers){
            setOfApprovers.add(eachMember.GroupId);  
        }
        Decimal submissionCounter = DealQualificationApprovalUtil.getApprovalSubmission(dqId, -1);
        System.debug('NKC debug approverId ['+approverId+']');
        System.debug('NKC debug setOfApprovers ['+setOfApprovers+']');
        System.debug('NKC debug submissionCounter ['+submissionCounter+']');
        List<Quote_Approval__c> quoteApprovalsForCurrentOwner = [SELECT Status__c FROM Quote_Approval__c 
                                                                 WHERE Deal_Qualification__c =: dqId 
                                                                 AND (Status__c =: QuoteApprovalUtil.STATUS_PENDING OR Status__c =: QuoteApprovalUtil.STATUS_INACTIVE)
                                                                 AND OwnerId IN : setOfApprovers
                                                                 AND Approval_Submission_Counter__c =: submissionCounter];
        if(!quoteApprovalsForCurrentOwner.isEmpty()){
            for(Quote_Approval__c eachQA : quoteApprovalsForCurrentOwner){
                eachQA.Status__c = QuoteApprovalUtil.STATUS_APPROVED;
                eachQA.Comments__c = 'Auotmatically approved due to another approval';
            }
            update quoteApprovalsForCurrentOwner;    
        }
    }
    
    public static void approveDuplicateApproverRecordsQuote(Id approverId, Id quoteId){
        // Process the duplicate check only for specified list of users (Currently just Brian Bischoff)
        Set<String> set_UserIds = new Set<String>(Global_Configuration_Settings__c.getOrgDefaults().BE_DAP_User_Check__c.split(';'));
        if(!set_UserIds.contains(approverId))
            return;
        
        //Will hold all potential approvers ids (user and group)
        Set<String> setOfApprovers = new Set<String>();
        //Adding current user id
        setOfApprovers.add(approverId);
        List<GroupMember> groupMembers = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId =: approverId];
        //Adding queues
        for(GroupMember eachMember : groupMembers){
            setOfApprovers.add(eachMember.GroupId);  
        }
        Decimal submissionCounter = QuoteApprovalUtil.getApprovalSubmission(quoteId, -1);
        System.debug('NKC debug approverId ['+approverId+']');
        System.debug('NKC debug setOfApprovers ['+setOfApprovers+']');
        System.debug('NKC debug submissionCounter ['+submissionCounter+']');
        List<Quote_Approval__c> quoteApprovalsForCurrentOwner = [SELECT Status__c FROM Quote_Approval__c 
                                                                 WHERE BigMachines_Quote__c =: quoteId 
                                                                 AND (Status__c =: QuoteApprovalUtil.STATUS_PENDING OR Status__c =: QuoteApprovalUtil.STATUS_INACTIVE)
                                                                 AND OwnerId IN : setOfApprovers
                                                                 AND Approval_Submission_Counter__c =: submissionCounter];
        if(!quoteApprovalsForCurrentOwner.isEmpty()){
            for(Quote_Approval__c eachQA : quoteApprovalsForCurrentOwner){
                eachQA.Status__c = QuoteApprovalUtil.STATUS_APPROVED;
                eachQA.Comments__c = 'Auotmatically approved due to another approval';
            }
            update quoteApprovalsForCurrentOwner;    
        }
    }
}