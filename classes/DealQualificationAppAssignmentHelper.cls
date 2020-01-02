//Naresh Kumar  11/18/2014
public without sharing class DealQualificationAppAssignmentHelper {
    
    public static Map<String, List<Quote_Approval_Config_And_Steps__c>> filterQuoteApprovals(Deal_Qualification__c dq, Deal_Qualification__c dqHistory, List<Quote_Approval_Step_Details__c> quoteApprovals,
                                                                                             Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndSteps){
                                                                                                 //will hold applicable records
                                                                                                 List<Quote_Approval_Step_Details__c> filteredApprovalRecords = new List<Quote_Approval_Step_Details__c>();
                                                                                                 //Will hold quote product records
                                                                                                 List<Deal_Qualification_Products__c> dealQualificationProducts = DealQualificationApprovalUtil.getDQProducts(dq.id);
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
                                                                                                 
                                                                                                 Map<Id, Deal_Qualification_Products__c> mapProductIdVsDQProduct = new Map<Id, Deal_Qualification_Products__c>();
                                                                                                 if(dqHistory != null){
                                                                                                     List<Deal_Qualification_Products__c> dqHistoryProducts = DealQualificationApprovalUtil.getDQProducts(dqHistory.id);      
                                                                                                     for(Deal_Qualification_Products__c eachDQProduct : dqHistoryProducts){
                                                                                                         mapProductIdVsDQProduct.put(eachDQProduct.Product__c, eachDQProduct);  
                                                                                                     }
                                                                                                 }
                                                                                                 
                                                                                                 //Looping over each quote product record to update above flags
                                                                                                 for(Deal_Qualification_Products__c eachDQProduct : dealQualificationProducts){
                                                                                                     System.debug('$$$eachDQProduct:'+eachDQProduct+'###mapProductIdVsDQProduct.get(eachDQProduct.Product__c):'+mapProductIdVsDQProduct.get(eachDQProduct.Product__c));
                                                                                                     if(eachDQProduct.Product__r.Product_Specific_Discount__c != null              
                                                                                                        && eachDQProduct.Discount__c != null
                                                                                                        && (mapProductIdVsDQProduct.get(eachDQProduct.Product__c) == null || mapProductIdVsDQProduct.get(eachDQProduct.Product__c).Discount__c < eachDQProduct.Discount__c)
                                                                                                        && eachDQProduct.Discount__c > eachDQProduct.Product__r.Product_Specific_Discount__c){
                                                                                                            if(eachDQProduct.Product__r.Type__c == DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE 
                                                                                                               || eachDQProduct.Product__r.Type__c == DealQualificationApprovalUtil.PRODUCT_TYPE_PRODUCT_HARDWARE){
                                                                                                                   isBEPOverride = true;
                                                                                                                   continue;
                                                                                                               }
                                                                                                            if(eachDQProduct.Product__r.Type__c == DealQualificationApprovalUtil.PRODUCT_TYPE_GU){
                                                                                                                isGUOverride = true;
                                                                                                                continue;                   
                                                                                                            } 
                                                                                                            
                                                                                                            if(eachDQProduct.Product__r.Third_Party__c != null
                                                                                                               && eachDQProduct.Product__r.Third_Party__c.toLowerCase() == 'true'){
                                                                                                                   isThirdPartyDiscount = true;
                                                                                                                   //Anju for cloud, thirdparty is needed
                                                                                                                   if(dq.Offering_Type__c != 'PureCloud' && dq.Offering_Type__c != 'PureConnect Cloud' && dq.Offering_Type__c != 'PureEngage Cloud')
                                                                                                                       continue;
                                                                                                               }
                                                                                                            isProductSpecificDiscount = true;
                                                                                                        }    
                                                                                                     //System.debug('NKC debug isGUOverride [' + isGUOverride  + ']');   
                                                                                                     //System.debug('NKC debug eachDQProduct.Product__r.Product_Manager_Approval_Group__c ['+eachDQProduct.Product__r.Product_Manager_Approval_Group__c+']');  
                                                                                                     //Product Management
                                                                                                     if(eachDQProduct.Product__r.Product_Manager_Approval_Group__c != null
                                                                                                        && (DealQualificationApprovalUtil.isPMApprovalRequired(eachDQProduct.Product__r.Shipment_Approval__c) || dq.Offering_Type__c == 'PureCloud')){               
                                                                                                            if(mapPMGroupIdVsProductIds.containsKey(eachDQProduct.Product__r.Product_Manager_Approval_Group__c)){
                                                                                                                mapPMGroupIdVsProductIds.get(eachDQProduct.Product__r.Product_Manager_Approval_Group__c).add(eachDQProduct.Product__c);
                                                                                                            }
                                                                                                            else{
                                                                                                                Set<Id> productIds = new Set<Id>();
                                                                                                                productIds.add(eachDQProduct.Product__c);
                                                                                                                mapPMGroupIdVsProductIds.put(eachDQProduct.Product__r.Product_Manager_Approval_Group__c, productIds);
                                                                                                            }
                                                                                                            //System.debug('NKC debug mapPMGroupIdVsProductIds ['+mapPMGroupIdVsProductIds+']');
                                                                                                            mapPMGroupIdVsProductIds = DealQualificationApprovalUtil.isAlreadyApprovedPMApproval(dq.id, mapPMGroupIdVsProductIds, DealQualificationApprovalUtil.STATUS_APPROVED);
                                                                                                        }
                                                                                                     else if(eachDQProduct.Product__r.Product_Manager_Approval_Group__c != null
                                                                                                             && DealQualificationApprovalUtil.isNotificationOnly(eachDQProduct.Product__r.Shipment_Approval__c)){               
                                                                                                                 if(mapPMGroupIdVsProductIdsENO.containsKey(eachDQProduct.Product__r.Product_Manager_Approval_Group__c)){
                                                                                                                     mapPMGroupIdVsProductIdsENO.get(eachDQProduct.Product__r.Product_Manager_Approval_Group__c).add(eachDQProduct.Product__c);
                                                                                                                 }
                                                                                                                 else{
                                                                                                                     Set<Id> productIds = new Set<Id>();
                                                                                                                     productIds.add(eachDQProduct.Product__c);
                                                                                                                     mapPMGroupIdVsProductIdsENO.put(eachDQProduct.Product__r.Product_Manager_Approval_Group__c, productIds);
                                                                                                                 }
                                                                                                                 mapPMGroupIdVsProductIdsENO = DealQualificationApprovalUtil.isAlreadyApprovedPMApproval(dq.id, mapPMGroupIdVsProductIdsENO, DealQualificationApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY);
                                                                                                             }       
                                                                                                     
                                                                                                 }
                                                                                                 //System.debug('NKC debug mapPMGroupIdVsProductIds ['+mapPMGroupIdVsProductIds+']');
                                                                                                 //System.debug('NKC debug isThirdPartyDiscount ['+isThirdPartyDiscount+']');
                                                                                                 
                                                                                                 System.debug('NKC debug quoteApprovals ['+quoteApprovals+']');  
                                                                                                 //System.debug('NKC debug quoteApprovals.size() ['+quoteApprovals.size()+']');
                                                                                                 //will hold filtered record and return values   
                                                                                                 Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteConfigAndStepsFiltered = new Map<String, List<Quote_Approval_Config_And_Steps__c>>(); 
                                                                                                 Integer counter = 1;
                                                                                                 //Looping over each approval record
                                                                                                 for(Quote_Approval_Step_Details__c eachQASD : quoteApprovals){
                                                                                                     List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps = mapIdVsQuoteConfigAndSteps.get(eachQASD.Quote_Approval_Step__c);    
                                                                                                     System.debug('NKC debug eachQASD.Quote_Approval_Step__c ['+eachQASD.Quote_Approval_Step__r.Name+']');       
                                                                                                     //will have filtered list of config and their steps
                                                                                                     List<Quote_Approval_Config_And_Steps__c> quoteApprovalFilteredConfigAndSteps = new List<Quote_Approval_Config_And_Steps__c>();            
                                                                                                     for(Quote_Approval_Config_And_Steps__c eachQACS : quoteApprovalConfigAndSteps){                 
                                                                                                         Boolean isRecordApplicable = false;
                                                                                                         //if approval type is null, just skip the record
                                                                                                         
                                                                                                         System.debug('eachQASD ' + eachQASD);
                                                                                                         System.debug('eachQACS ' + eachQACS);
                                                                                                         System.debug('eachQACS.Quote_Approval_Config__c ' + eachQACS.Quote_Approval_Config__c);
                                                                                                         System.debug('eachQACS.Quote_Approval_Config__r.Approval_Type__c ' + eachQACS.Quote_Approval_Config__r.Approval_Type__c);
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c == null)
                                                                                                             continue;
                                                                                                         //Discount
                                                                                                         Double discountOnDQ;
                                                                                                         if(dq.New_Pricing_Discount__c == 'No Discount')
                                                                                                             discountOnDQ = 0;
                                                                                                         else 
                                                                                                             discountOnDQ = DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c); 
                                                                                                         Double discountOnDQHistory = (dqHistory == null || dqHistory.New_Pricing_Discount__c == 'No Discount') ? 0 : DealQualificationApprovalUtil.getDiscountSize(dqHistory.New_Pricing_Discount__c);
                                                                                                         System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c ['+eachQACS.Quote_Approval_Config__r.Approval_Type__c+']');
                                                                                                         System.debug('NKC debug discountOnDQ ['+discountOnDQ+']');
                                                                                                         System.debug('NKC debug dqHistory ['+dqHistory+']');
                                                                                                         System.debug('NKC debug discountOnDQHistory ['+discountOnDQHistory+']');
                                                                                                         System.debug('NKC debug dq.Pricing_Model__c ['+dq.Pricing_Model__c+']');
                                                                                                         System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Pricing_Model__c ['+eachQACS.Quote_Approval_Config__r.Pricing_Model__c+']');
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT) 
                                                                                                            && (dq.Offering_Type__c == 'Cloud Partner (PPU)' || dq.Pricing_Type__c == 'Old Pricing' || dq.Quote__r.Amendment_For__c != null || dq.Quote__r.Conversion_Quote__c != null )                  
                                                                                                            //History check                  
                                                                                                            && (dqHistory == null || discountOnDQ > discountOnDQHistory)
                                                                                                            && (dq.Pricing_Model__c == eachQACS.Quote_Approval_Config__r.Pricing_Model__c 
                                                                                                                || eachQACS.Quote_Approval_Config__r.Pricing_Model__c == null)){                            
                                                                                                                    Double DQSize;
                                                                                                                    if(dq.Offering_Type__c == QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE)
                                                                                                                        DQSize = DealQualificationApprovalUtil.getDealSize(dq.What_is_total_list_price__c);
                                                                                                                    else
                                                                                                                        DQSize = DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c);
                                                                                                                    //Check threshold price 
                                                                                                                    System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c [' + eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c +']');
                                                                                                                    System.debug('NKC debug DQSize [' + DQSize +']');
                                                                                                                    System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Threshold_Price_To__c [' + eachQACS.Quote_Approval_Config__r.Threshold_Price_To__c +']');
                                                                                                                    if(eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c == null || eachQACS.Quote_Approval_Config__r.Threshold_Price_To__c == null
                                                                                                                       || (DQSize >= eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c && DQSize <= eachQACS.Quote_Approval_Config__r.Threshold_Price_To__c)){
                                                                                                                           Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, discountOnDQ);  
                                                                                                                           if(isApplicable)
                                                                                                                               isRecordApplicable = true;      
                                                                                                                       }         
                                                                                                                }    
                                                                                                         //Discount - Base Package
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT_SIZE_BASE_PACKAGE)){
                                                                                                             Double basePackageDiscountOnDQ;
                                                                                                             if(dq.Discount_Base_Package__c == 'No Discount')
                                                                                                                 basePackageDiscountOnDQ = 0;
                                                                                                             else 
                                                                                                                 basePackageDiscountOnDQ = DealQualificationApprovalUtil.getDiscountSize(dq.Discount_Base_Package__c);       
                                                                                                             Double basePackageDiscountOnDQHistory = (dqHistory == null || dqHistory.Discount_Base_Package__c == 'No Discount') ? 0 : DealQualificationApprovalUtil.getDiscountSize(dqHistory.New_Pricing_Discount__c);
                                                                                                             //History check                  
                                                                                                             if(dqHistory == null || basePackageDiscountOnDQ > basePackageDiscountOnDQHistory){
                                                                                                                 Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, basePackageDiscountOnDQ);  
                                                                                                                 if(isApplicable)
                                                                                                                     isRecordApplicable = true;          
                                                                                                             }
                                                                                                         }
                                                                                                         //ELA
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ELA)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.ELA__c != 'Yes') 
                                                                                                            && dq.ELA__c == 'Yes'){               
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;              
                                                                                                            }
                                                                                                         //Old Pricing
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing)
                                                                                                            && dq.IsOldPricingApproved__c && (dqHistory == null || !dqHistory.IsOldPricingApproved__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;              
                                                                                                            }
                                                                                                         
                                                                                                         //Pricing Model - Concurrent
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Pricing_Model__c == null || (dqHistory.Pricing_Model__c != null && dqHistory.Pricing_Model__c == DealQualificationApprovalUtil.CONCURRENT))
                                                                                                            && dq.Pricing_Model__c != null                    
                                                                                                            && dq.Pricing_Model__c == DealQualificationApprovalUtil.CONCURRENT){             
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            } 
                                                                                                         //Expiration Date
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE)     
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Expiration_Date__c != dq.Expiration_Date__c)    
                                                                                                            && eachQACS.Quote_Approval_Config__r.No_Of_Days_After_Quote_Expires__c != null && dq.Expiration_Date__c != null
                                                                                                            && System.today().addDays(Integer.ValueOf(eachQACS.Quote_Approval_Config__r.No_Of_Days_After_Quote_Expires__c)) < dq.Expiration_Date__c){             
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Special Offer Terms
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Special_Offer_Terms__c || dqHistory.Special_Offers_Business_Exceptions__c != dq.Special_Offers_Business_Exceptions__c)  
                                                                                                            &&  dq.Special_Offer_Terms__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Initial Subscription Term
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM )
                                                                                                            && DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c) > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c) > DealQualificationApprovalUtil.getInitialSubscriptionTerm(dqHistory.Initial_Subscription_Term_Months_PC__c,dqHistory.If_Other_Term_Months_Requested__c))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Ramp Period
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD )
                                                                                                            && DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c) > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c) > DealQualificationApprovalUtil.getRampPeriod(dqHistory.Ramp_Period_Days__c,dqHistory.If_Other_Ramp_Period_Requested_Days__c))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Cloud Deal
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_Cloud_Deal)
                                                                                                            && dq.Net_Deal_Size_Amount__c != null
                                                                                                            && dq.Net_Deal_Size_Amount__c <= eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Net_Deal_Size_Amount__c > dq.Net_Deal_Size_Amount__c)
                                                                                                           ){
                                                                                                               if((dq.Cloud_Partner_Approval__c && eachQACS.Quote_Approval_Config__r.Criteria__c == 'Partner')
                                                                                                                  ||(!dq.Cloud_Partner_Approval__c && eachQACS.Quote_Approval_Config__r.Criteria__c != 'Partner'))
                                                                                                               {
                                                                                                                   filteredApprovalRecords.add(eachQASD);
                                                                                                                   isRecordApplicable = true;
                                                                                                               }
                                                                                                           }
                                                                                                         
                                                                                                         //Deal Score Cloud
                                                                                                         system.debug(dq.Deal_Score__c);
                                                                                                         system.debug(eachQACS.Quote_Approval_Config__r.Threshold_From__c);
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD )
                                                                                                            && dq.Deal_Score__c <= eachQACS.Quote_Approval_Config__r.Threshold_From__c)
                                                                                                         {
                                                                                                             system.debug('Inside deal score cloud');
                                                                                                             Double dealScoreOnDQ = dq.Deal_Score__c == null ? 0 : dq.Deal_Score__c;
                                                                                                             Double dealScoreOnDQHistory = 0;
                                                                                                             Decimal decDifference = 0;
                                                                                                             if(dqHistory != null){
                                                                                                                 dealScoreOnDQHistory = dqHistory.Deal_Score__c == null ? 5 : dqHistory.Deal_Score__c;  
                                                                                                                 decDifference = dq.Net_Deal_Size_Amount__c - (dqHistory.Net_Deal_Size_Amount__c == null ? dq.Net_Deal_Size_Amount__c : dqHistory.Net_Deal_Size_Amount__c);      
                                                                                                             }
                                                                                                             
                                                                                                             Decimal decDiffPercentage = 0;
                                                                                                             
                                                                                                             //History check
                                                                                                             //&& (dqHistory == null || dq.Deal_Score__c < dqHistory.Deal_Score__c)){
                                                                                                             system.debug(dq.Net_Deal_Size_Amount__c);
                                                                                                             if(dq.Net_Deal_Size_Amount__c != null && dq.Net_Deal_Size_Amount__c > 0)
                                                                                                             {
                                                                                                                 decDiffPercentage = (decDifference * 100) / dq.Net_Deal_Size_Amount__c;
                                                                                                                 system.debug(decDiffPercentage);
                                                                                                                 if(dqHistory == null || dqHistory.Deal_Score__c == null || dealScoreOnDQHistory > dealScoreOnDQ || (decDiffPercentage > 10 || decDiffPercentage < -10))
                                                                                                                 {
                                                                                                                     filteredApprovalRecords.add(eachQASD);
                                                                                                                     isRecordApplicable = true;        
                                                                                                                     System.debug('Deal score...');
                                                                                                                 }  
                                                                                                             }  
                                                                                                         } 
                                                                                                         
                                                                                                         //Third Party Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY)
                                                                                                            && dq.Third_Party_Discount__c >= eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Third_Party_Discount__c > dqHistory.Third_Party_Discount__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Business Exceptions                 
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR)
                                                                                                            && dq.Monthly_Recurring_Revenue_less_than_14K__c == 'Yes'
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Monthly_Recurring_Revenue_less_than_14K__c != dq.Monthly_Recurring_Revenue_less_than_14K__c || dqHistory.Estimated_Monthly_Recurring_Revenue__c != dq.Estimated_Monthly_Recurring_Revenue__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM )
                                                                                                            && dq.Estimated_Number_of_Agents__c < eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Estimated_Number_of_Agents__c == null || dq.Estimated_Number_of_Agents__c < dqHistory.Estimated_Number_of_Agents__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS )
                                                                                                            && dq.Estimated_Number_of_Business_Users__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Estimated_Number_of_Business_Users__c == null || dq.Estimated_Number_of_Business_Users__c > dqHistory.Estimated_Number_of_Business_Users__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO )
                                                                                                            && dq.Business_User_to_Agent_Ratio_Exception__c == 'Yes'
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Business_User_to_Agent_Ratio_Exception__c != dqHistory.Business_User_to_Agent_Ratio_Exception__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         
                                                                                                         //Monthly minimum                
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM )
                                                                                                            && dq.If_Other_PureCloud_Monthly_Minimum_Req__c >= eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.If_Other_PureCloud_Monthly_Minimum_Req__c > dqHistory.If_Other_PureCloud_Monthly_Minimum_Req__c || (dqHistory.If_Other_PureCloud_Monthly_Minimum_Req__c == null && dq.If_Other_PureCloud_Monthly_Minimum_Req__c != null))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //PC Credit                
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit)
                                                                                                            && dq.PureCloud_Credit_Applied__c 
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.PureCloud_Credit_Applied__c || (dq.Migration_Credit__c != null && dqHistory.Migration_Credit__c != null && dq.Migration_Credit__c != dqHistory.Migration_Credit__c ))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PCC Credit-Rony Joseph -April 17th 2019-PCC Credit Step-Begins                
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PCC_Credit)
                                                                                                            && dq.PureCloud_Credit_Applied__c 
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.PureCloud_Credit_Applied__c || (dq.Migration_Credit__c != null && dqHistory.Migration_Credit__c != null && dq.Migration_Credit__c != dqHistory.Migration_Credit__c ))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PCC Credit-Rony Joseph -April 17th 2019-PCC Credit Step-Ends  
                                                                                                         //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- Start              
                                                                                                         System.debug('$$$dq.Billing_Category__C:'+dq.Billing_Category__C);
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM)
                                                                                                            &&  dq.Renewal_Subscription_Term__c
                                                                                                            && (dqHistory == null || !dqHistory.Renewal_Subscription_Term__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY)
                                                                                                            &&  dq.Billing_Category__C == 'M2M'
                                                                                                           ){
                                                                                                               filteredApprovalRecords.add(eachQASD);
                                                                                                               isRecordApplicable = true;
                                                                                                           }        
                                                                                                         //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- End  
                                                                                                         //PC Trial
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial )
                                                                                                            && dq.PureCloud_Trial__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.PureCloud_Trial__c)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //PC PS Discount           
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT ) && dq.PS_Discount_on_Quote__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.PS_Discount_on_Quote__c > dqHistory.PS_Discount_on_Quote__c || (dqHistory.PS_Discount_on_Quote__c == null && dq.PS_Discount_on_Quote__c != null))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //PC Hardware Discount                          
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT ) && dq.Hardware_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Hardware_Discount__c > dqHistory.Hardware_Discount__c || (dqHistory.Hardware_Discount__c == null && dq.Hardware_Discount__c != null))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //PC Software Discount                          
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT ) && dq.Software_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Software_Discount__c > dqHistory.Software_Discount__c || (dqHistory.Software_Discount__c == null && dq.Software_Discount__c != null))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //PC Overage Discount                          
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT) && dq.Overage_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Overage_Discount__c > dqHistory.Overage_Discount__c || (dqHistory.Overage_Discount__c == null && dq.Overage_Discount__c != null))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //PC TCV Reduction 
                                                                                                         
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION) && dq.TCV_Reduction__c > 0
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.TCV_Reduction__c > dqHistory.TCV_Reduction__c || (dqHistory.TCV_Reduction__c == null && dq.TCV_Reduction__c != null))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                
                                                                                                         
                                                                                                         //Billing Period                
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD )
                                                                                                            && DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c) == eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c) != DealQualificationApprovalUtil.getBillingPeriod(dqHistory.Billing_Period__c))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Payment Terms
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS )
                                                                                                            && DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c) >= eachQACS.Quote_Approval_Config__r.Threshold_From__c
                                                                                                            //History check
                                                                                                            && (dqHistory == null || DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c) > DealQualificationApprovalUtil.getPaymentterms(dqHistory.Payment_Terms__c))){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Care Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE)                                                   
                                                                                                            && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c != null
                                                                                                            && ((dq.GC_Override__c == DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE
                                                                                                                 //History check
                                                                                                                 && (dqHistory == null || dqHistory.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE)
                                                                                                                 && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c == DealQualificationApprovalUtil.GC_THRESHOLD_TWO_TO_THREE))                      
                                                                                                            ||                      
                                                                                                            (dq.GC_Override__c == DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE
                                                                                                             //History check
                                                                                                             && (dqHistory == null || dqHistory.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE)
                                                                                                             && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c == DealQualificationApprovalUtil.GC_THRESHOLD_GREATER_THAN_THREE)
                                                                                                            ||
                                                                                                            (dq.GC_Override__c == DealQualificationApprovalUtil.GC_THRESHOLD_LESS_THAN_TWO
                                                                                                             //History check
                                                                                                             && (dqHistory == null || dqHistory.GC_Override__c != DealQualificationApprovalUtil.GC_THRESHOLD_LESS_THAN_TWO)
                                                                                                             && eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c == DealQualificationApprovalUtil.GC_THRESHOLD_LESS_THAN_TWO)
                                                                                                           ){
                                                                                                               filteredApprovalRecords.add(eachQASD);
                                                                                                               isRecordApplicable = true;      
                                                                                                           }   
                                                                                                         String strDealSize, strDealSizeHistory;
                                                                                                         if(dq.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC){
                                                                                                             strDealSize = dq.What_is_total_list_price__c;
                                                                                                             if(dqHistory != null)
                                                                                                                 strDealSizeHistory = dqHistory.What_is_total_list_price__c;                    
                                                                                                         }
                                                                                                         else{
                                                                                                             strDealSize = dq.Net_Deal_Value__c;
                                                                                                             if(dqHistory != null)
                                                                                                                 strDealSizeHistory = dqHistory.Net_Deal_Value__c;                    
                                                                                                         }
                                                                                                         //Deal Size
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE)
                                                                                                            //History check                  
                                                                                                            && (dqHistory == null || DealQualificationApprovalUtil.getDealSize(strDealSize) > DealQualificationApprovalUtil.getDealSize(strDealSizeHistory))
                                                                                                            && DealQualificationApprovalUtil.getDealSize(strDealSize) != null){
                                                                                                                Double dealSizeOnDQ = DealQualificationApprovalUtil.getDealSize(strDealSize);
                                                                                                                Double totalQuoteUSD = DealQualificationApprovalUtil.convertCurrency(dealSizeOnDQ, dq.CurrencyIsoCode);
                                                                                                                System.debug('NKC debug totalQuoteUSD ['+totalQuoteUSD+']');
                                                                                                                //Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, totalQuoteUSD - 1);
                                                                                                                
                                                                                                                //new type of approval on deal size for PC
                                                                                                                Boolean isApplicable = false;
                                                                                                                if(dq.Offering_Type__c == 'PureCloud'){
                                                                                                                    if(dq.Offering_Type__c == 'PureCloud'){
                                                                                                                        if(dealSizeOnDQ >= eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c
                                                                                                                           //&& dealSizeOnDQ <= eachQACS.Quote_Approval_Config__r.Threshold_Price_To__c
                                                                                                                           && (eachQACS.Quote_Approval_Config__r.Threshold_From__c != null &&
                                                                                                                               (
                                                                                                                                   dq.Discount_On_Quote__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c ||
                                                                                                                                   dq.Hardware_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c ||
                                                                                                                                   dq.Software_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c ||
                                                                                                                                   dq.PS_Discount_on_Quote__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c ||
                                                                                                                                   dq.Overage_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c 
                                                                                                                               ))
                                                                                                                           && (eachQACS.Quote_Approval_Config__r.Threshold_To__c == null ||
                                                                                                                               dq.Discount_On_Quote__c <= eachQACS.Quote_Approval_Config__r.Threshold_To__c ||
                                                                                                                               dq.Hardware_Discount__c <= eachQACS.Quote_Approval_Config__r.Threshold_To__c ||
                                                                                                                               dq.Software_Discount__c <= eachQACS.Quote_Approval_Config__r.Threshold_To__c ||
                                                                                                                               dq.PS_Discount_on_Quote__c <= eachQACS.Quote_Approval_Config__r.Threshold_To__c ||
                                                                                                                               dq.Overage_Discount__c <= eachQACS.Quote_Approval_Config__r.Threshold_To__c)){
                                                                                                                                   filteredApprovalRecords.add(eachQASD);
                                                                                                                                   isApplicable = true;
                                                                                                                               } 
                                                                                                                    }
                                                                                                                }
                                                                                                                else
                                                                                                                    isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, totalQuoteUSD - 1);
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;              
                                                                                                            }
                                                                                                         System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c [' + eachQACS.Quote_Approval_Config__r.Approval_Type__c+ ']');
                                                                                                         //Term Reduced
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Term_Decrease__c)
                                                                                                            && dq.Term_Decrease__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;      
                                                                                                            }
                                                                                                         //Term Increased
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Term_Increase__c)
                                                                                                            && dq.Term_Increase__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;      
                                                                                                            }
                                                                                                         //Service Level - Decline
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Decline__c)                    
                                                                                                            && dq.Decline__c){                
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                
                                                                                                         /*
//Revision
if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION)
&& dq.Revise_Minor__c){              
filteredApprovalRecords.add(eachQASD);
isRecordApplicable = true;
}
*/
                                                                                                         //3rd Party
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY)
                                                                                                            && isThirdPartyDiscount){               
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                   
                                                                                                         //Product Specific
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC)
                                                                                                            && (!isThirdPartyDiscount || (isThirdPartyDiscount && (dq.Offering_Type__c == 'PureCloud' || dq.Offering_Type__c == 'PureConnect Cloud' || dq.Offering_Type__c == 'PureEngage Cloud' )))
                                                                                                            && isProductSpecificDiscount){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                       
                                                                                                         //CAD Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.CAD_Override__c) 
                                                                                                            && dq.CAD_Override__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Premium Care
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Premium_Care__c) 
                                                                                                            && dq.Premium_Care__c){                
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //System.debug('NKC debug isGUOverride [' + isGUOverride + ']');
                                                                                                         //System.debug('NKC debug DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE[' + DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE+ ']');
                                                                                                         
                                                                                                         
                                                                                                         //GU Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE)
                                                                                                            && isGUOverride){                    
                                                                                                                System.debug('NKC debug in condition.');
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //BEP Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE)
                                                                                                            && isBEPOverride){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Additional Legal Terms
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Additional_Legal_Terms__c) 
                                                                                                            && dq.Additional_Legal_Terms__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Editable List Price 
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Editable_List_Price_Approval_Required__c)
                                                                                                            && dq.Editable_List_Price_Approval_Required__c){
                                                                                                                
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }   
                                                                                                         //Require Separate Quote for Genesys Care - Notification
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Require_Separate_Quote_for_Genesys_Care__c)
                                                                                                            && dq.Require_Separate_Quote_for_Genesys_Care__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }   
                                                                                                         //Future Products - Notification
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Are_you_selling_Non_GA_Future_Roadmap__c == 'No')
                                                                                                            && dq.Are_you_selling_Non_GA_Future_Roadmap__c == 'Yes'){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            } 
                                                                                                         //Profressional Services - Notification
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PS)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Do_you_require_Professional_Services__c == 'No')
                                                                                                            && dq.Do_you_require_Professional_Services__c == 'Yes'){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                       
                                                                                                         //Third Party Override
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.X3rd_Party_Override__c)
                                                                                                            && dq.X3rd_Party_Override__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            } 
                                                                                                         //Old Pricing Usage approval
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.IsOldPricingApproved__c)
                                                                                                            && dq.Pricing_Type__c == 'Old Pricing'){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;      
                                                                                                            }               
                                                                                                         //Cloud Partner
                                                                                                         if(dq.Pricing_Model__c == 'PPU' && eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Cloud_Partner_Approval__c)
                                                                                                            && !dq.Is_Cloud_Partner__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                                
                                                                                                         //PPU Deal
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.PPU_Deal_Approval__c)
                                                                                                            && dq.Pricing_Model__c == 'PPU'){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Finance Exceptions
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Finance_Exception__c != dq.Finance_Exception__c) && dq.Finance_Exception__c != null)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Legal Exceptions
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION)
                                                                                                            //History check                  
                                                                                                            && ((dqHistory == null || dqHistory.Legal_Exceptions__c != dq.Legal_Exceptions__c) && dq.Legal_Exceptions__c != null)){    
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Support Options
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Support_Option__c != dq.Support_Option__c) 
                                                                                                                && (dq.Support_Option__c == 'Priority Support' || dq.Support_Option__c == 'VIP Priority Support'))){
                                                                                                                    filteredApprovalRecords.add(eachQASD);
                                                                                                                    isRecordApplicable = true;
                                                                                                                }
                                                                                                         System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c ['+ eachQACS.Quote_Approval_Config__r.Approval_Type__c + ']');
                                                                                                         //System.debug('NKC debug dqHistory.Base_Agent_Discount__c ['+ dqHistory.Base_Agent_Discount__c + ']');
                                                                                                         System.debug('NKC debug dq.Base_Agent_Discount__cc ['+ dq.Base_Agent_Discount__c + ']');
                                                                                                         //Base Agent Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Base_Agent_Discount__c < dq.Base_Agent_Discount__c))){
                                                                                                                Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(dq.Base_Agent_Discount__c));        
                                                                                                                System.debug('NKC debug isApplicable ['+ isApplicable + ']');
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Hardware Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Hardware_Discount__c < dq.Hardware_Discount__c))){
                                                                                                                Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(dq.Hardware_Discount__c));        
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Add-On Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Business_Users_Add_On__c < dq.Business_Users_Add_On__c))){
                                                                                                                Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(dq.Business_Users_Add_On__c));        
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Business Users Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Business_Users_Provisioning_Discount__c < dq.Business_Users_Provisioning_Discount__c))){
                                                                                                                Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(dq.Business_Users_Provisioning_Discount__c));        
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Data Center Discount
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Data_Center_Provisioning_Discount__c < dq.Data_Center_Provisioning_Discount__c))){
                                                                                                                Boolean isApplicable = getApprovalForThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, Double.valueOf(dq.Data_Center_Provisioning_Discount__c));        
                                                                                                                if(isApplicable)
                                                                                                                    isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Carveout
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Carveout__c || dqHistory.CarveOutDetails__c != dq.CarveOutDetails__c)
                                                                                                            && dq.Carveout__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //SMART Use Case
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Smart_Use_Case__c)
                                                                                                            && dq.Smart_Use_Case__c != null && dq.Smart_Use_Case__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                
                                                                                                         //Price Escalation 
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Price_Escalation__c != dq.Price_Escalation__c)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Criteria__c != null && dq.Price_Escalation__c != null && eachQACS.Quote_Approval_Config__r.Criteria__c.contains(dq.Price_Escalation__c)){                    
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Overage Allowance 
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Overage_Allowance__c != dq.Overage_Allowance__c)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Criteria__c != null && dq.Overage_Allowance__c != null && eachQACS.Quote_Approval_Config__r.Criteria__c.contains(dq.Overage_Allowance__c)){                    
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Payment Term - Subscription 
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dqHistory.Payment_Terms__c != dq.Payment_Terms__c)
                                                                                                            && eachQACS.Quote_Approval_Config__r.Criteria__c != null && dq.Payment_Terms__c != null && eachQACS.Quote_Approval_Config__r.Criteria__c.contains(dq.Payment_Terms__c)){                    
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            } 
                                                                                                         
                                                                                                         //Subscription Smart Qualified Approval
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Subscription_Smart_Qualified_Approval__c)
                                                                                                            && dq.Subscription_Smart_Qualified_Approval__c != null && dq.Subscription_Smart_Qualified_Approval__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                 
                                                                                                         //Rental Quote
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Rental__c)
                                                                                                            && dq.Rental__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }                 
                                                                                                         //Usage Data Submission Method
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || dq.Usage_Data_Submission_Method__c != dqHistory.Usage_Data_Submission_Method__c)
                                                                                                            && (dq.Usage_Data_Submission_Method__c == 'Manual' || dq.Usage_Data_Submission_Method__c == 'No Bursting')){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Seasonal Licensing (Bursting)
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SEASONAL_LICENSING)) {
                                                                                                             Boolean y1blank = (dq.Seasonal_License_Net_Value_Y1__c == null || dq.Seasonal_License_Net_Value_Y1__c == 0) ? true : false;
                                                                                                             Boolean y2blank = (dq.Seasonal_License_Net_Value_Y2__c == null || dq.Seasonal_License_Net_Value_Y2__c == 0) ? true : false;
                                                                                                             Boolean hsty1blank = (dqHistory == null || dqHistory.Seasonal_License_Net_Value_Y1__c == null || dqHistory.Seasonal_License_Net_Value_Y1__c == 0) ? true : false;
                                                                                                             Boolean hsty2blank = (dqHistory == null || dqHistory.Seasonal_License_Net_Value_Y2__c == null || dqHistory.Seasonal_License_Net_Value_Y2__c == 0) ? true : false;
                                                                                                             
                                                                                                             if ( (!y1blank && hsty1blank) || (!y2blank && hsty2blank) || 
                                                                                                                 (dqHistory == null && y1blank && y2blank && dq.Overage_Discount__c == 100) ||
                                                                                                                 (dqHistory != null && dq.Overage_Discount__c == 100 && dqHistory.Overage_Discount__c != 100)) {
                                                                                                                     filteredApprovalRecords.add(eachQASD);
                                                                                                                     isRecordApplicable = true;
                                                                                                                 }
                                                                                                         }
                                                                                                         //Credits
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CREDIT_APPLIED)) {
                                                                                                             Boolean onetime = (dq.Total_Non_Recurring_Credit__c == null || dq.Total_Non_Recurring_Credit__c == 0) ? false : true;
                                                                                                             Boolean reccur = (dq.Total_Recurring_Credit__c == null || dq.Total_Recurring_Credit__c == 0) ? false : true;
                                                                                                             Boolean hstyonetime = (dqHistory == null || dqHistory.Total_Non_Recurring_Credit__c == null || dqHistory.Total_Non_Recurring_Credit__c == 0) ? false : true;
                                                                                                             Boolean hstyreccur = (dqHistory == null || dqHistory.Total_Recurring_Credit__c == null || dqHistory.Total_Recurring_Credit__c == 0) ? false : true;
                                                                                                             
                                                                                                             if ( (onetime && !hstyonetime) || (reccur && !hstyreccur) ) {
                                                                                                                 filteredApprovalRecords.add(eachQASD);
                                                                                                                 isRecordApplicable = true;
                                                                                                             }
                                                                                                         }
                                                                                                         
                                                                                                         strDealSize = dq.Deal_Score_Size__c;
                                                                                                         strDealSizeHistory = null;
                                                                                                         if(dqHistory != null)
                                                                                                             strDealSizeHistory = dqHistory.Deal_Score_Size__c;
                                                                                                         
                                                                                                         //Deal Score
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE) && dq.Quote__r.Amendment_For__c == null
                                                                                                            && dq.Quote__r.Conversion_Quote__c == null
                                                                                                            //History check                  
                                                                                                            //&& (dqHistory == null) || DealQualificationApprovalUtil.getDealSize(strDealSize) > DealQualificationApprovalUtil.getDealSize(strDealSizeHistory))
                                                                                                            && DealQualificationApprovalUtil.getDealSize(strDealSize) != null){
                                                                                                                Double dealSizeOnDQ1 = DealQualificationApprovalUtil.getDealSize(strDealSize);
                                                                                                                Double totalQuoteUSD = DealQualificationApprovalUtil.convertCurrency(dealSizeOnDQ1, dq.CurrencyIsoCode);
                                                                                                                System.debug('NKC debug totalQuoteUSD ['+totalQuoteUSD+']');
                                                                                                                Boolean isThreholdApplicable = getApprovalForDealScoreThresholdTypeIfAny(filteredApprovalRecords, eachQACS, eachQASD, totalQuoteUSD - 1, dq.Deal_Score__c);                        
                                                                                                                System.debug('NKC debug isRecordApplicable ['+isRecordApplicable+']');
                                                                                                                System.debug('NKC debug isRecordApplicable ['+isRecordApplicable+']');
                                                                                                                System.debug('NKC debug dq.Offering_Type__c ['+dq.Offering_Type__c+']');
                                                                                                                System.debug('NKC debug dq.Quote__r.End_User_ID__c ['+dq.Quote__r.End_User_ID__c+']');
                                                                                                                System.debug('NKC debug dq.Quote__r.Sold_To_Name__c ['+dq.Quote__r.Sold_To_Name__c+']');
                                                                                                                System.debug('NKC debug dq.Quote__r.Total_Discount__c ['+dq.Quote__r.Total_Discount__c+']');
                                                                                                                
                                                                                                                if(isThreholdApplicable && (dq.Offering_Type__c != 'PureConnect On Premise' || (dq.Offering_Type__c == 'PureConnect On Premise' && dq.Quote__r.End_User_ID__c == dq.Quote__r.Sold_To_Name__c)
                                                                                                                                            || (dq.Offering_Type__c == 'PureConnect On Premise' && dq.Quote__r.End_User_ID__c != dq.Quote__r.Sold_To_Name__c && dq.Quote__r.Total_Discount__c > 0))){                            
                                                                                                                                                
                                                                                                                                                Double dealSizeOnDQ = DealQualificationApprovalUtil.getDealSize(dq.Deal_Score_Size__c);
                                                                                                                                                Double dealScoreOnDQ = dq.Deal_Score__c == null ? 0 : dq.Deal_Score__c;
                                                                                                                                                Double dealSizeOnDQHistory = 0;
                                                                                                                                                Double dealScoreOnDQHistory = 0;
                                                                                                                                                if(dqHistory != null){
                                                                                                                                                    dealSizeOnDQHistory = DealQualificationApprovalUtil.getDealSize(dqHistory.Deal_Score_Size__c);
                                                                                                                                                    dealScoreOnDQHistory = dqHistory.Deal_Score__c == null ? 0 : dqHistory.Deal_Score__c;        
                                                                                                                                                }
                                                                                                                                                Decimal decDifference = dealSizeOnDQ - dealSizeOnDQHistory;
                                                                                                                                                System.debug('NKC debug decDifference [' + decDifference +']');
                                                                                                                                                System.debug('NKC debug dealSizeOnDQ [' + dealSizeOnDQ +']');
                                                                                                                                                System.debug('NKC debug dealSizeOnDQHistory [' + dealSizeOnDQHistory +']');
                                                                                                                                                System.debug('NKC debug dealScoreOnDQ [' + dealScoreOnDQ +']');
                                                                                                                                                System.debug('NKC debug dealScoreOnDQHistory [' + dealScoreOnDQHistory +']');
                                                                                                                                                Decimal decDiffPercentage = 0 ;
                                                                                                                                                if(dq.Net_Deal_Size_Amount__c != null && dq.Net_Deal_Size_Amount__c > 0)
                                                                                                                                                    decDiffPercentage = (decDifference * 100) / dq.Net_Deal_Size_Amount__c;
                                                                                                                                                //History check                  
                                                                                                                                                if(dqHistory == null || dqHistory.Deal_Score__c == null || dealScoreOnDQHistory > dealScoreOnDQ || (decDiffPercentage > 10 || decDiffPercentage < -10)){
                                                                                                                                                    filteredApprovalRecords.add(eachQASD);
                                                                                                                                                    isRecordApplicable = true;                        
                                                                                                                                                }                      
                                                                                                                                            }        
                                                                                                            }
                                                                                                         //Conversion Quote
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_QUOTE_CONVERSION)
                                                                                                            //History check
                                                                                                            && ((dqHistory == null || dqHistory.Conversion_Quote__c == null) && dq.Conversion_Quote__c != null)){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         //Contractual Rate
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CONTRACTUAL_RATE)
                                                                                                            //History check
                                                                                                            && (dqHistory == null || !dqHistory.Contractual_Rate_Approval__c)
                                                                                                            && dq.Contractual_Rate_Approval__c){
                                                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                                                isRecordApplicable = true;
                                                                                                            }
                                                                                                         
                                                                                                         //Product Management                
                                                                                                         if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT)
                                                                                                            && (mapPMGroupIdVsProductIds.containsKey(eachQASD.Product_Manager_Approval_Group__c)
                                                                                                                || mapPMGroupIdVsProductIdsENO.containsKey(eachQASD.Product_Manager_Approval_Group__c))){                   
                                                                                                                    if(mapPMGroupIdVsProductIdsENO.containsKey(eachQASD.Product_Manager_Approval_Group__c)){
                                                                                                                        eachQASD.Quote_Approver_Step_Approver_Detail__r.Action_Text__c = DealQualificationApprovalUtil.NOTIFICATION_ONLY;
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
                                                                                                     
                                                                                                 }
                                                                                                 //System.debug('NKC debug mapIdVsQuoteConfigAndStepsFiltered ['+mapIdVsQuoteConfigAndStepsFiltered+']');
                                                                                                 quoteApprovals.clear();
                                                                                                 quoteApprovals.addAll(filteredApprovalRecords);
                                                                                                 return mapIdVsQuoteConfigAndStepsFiltered;
                                                                                             } 
    
    public static String populateReasonToCurrentApprovalRecord(Deal_Qualification__c dq, Quote_Approval_Step_Details__c quoteApprovalStepDetail,
                                                               List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps, String approvalReason){
                                                                   //Would contain unique reaons
                                                                   Set<String> uniqueReason = new Set<String>();       
                                                                   if(approvalReason == null)
                                                                       approvalReason = '';
                                                                   System.debug('NKC debug uniqueReason ['+quoteApprovalConfigAndSteps+']');
                                                                   if(quoteApprovalConfigAndSteps == null)    
                                                                       return approvalReason;
                                                                   for(Quote_Approval_Config_And_Steps__c eachQACS : quoteApprovalConfigAndSteps){
                                                                       System.debug('NKC debug uniqueReason ['+uniqueReason+']');
                                                                       System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c ['+eachQACS.Quote_Approval_Config__r.Approval_Type__c+']');
                                                                       System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Threshold_From__c ['+eachQACS.Quote_Approval_Config__r.Threshold_From__c+']');
                                                                       //Discount
                                                                       Double newDiscount = (dq.New_Pricing_Discount__c == 'No Discount' ? 0 : DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c)); 
                                                                       Double oldDiscount = (dq.Old_Pricing_Discount__c == 'No Discount' ? 0 : DealQualificationApprovalUtil.getDiscountSize(dq.Old_Pricing_Discount__c));                
                                                                       Double maxDiscount = newDiscount > oldDiscount ? newDiscount : oldDiscount;
                                                                       
                                                                       //Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c != null && eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT)){
                                                                           String pricingModel = (dq.Pricing_Model__c == null ? '' : dq.Pricing_Model__c);       
                                                                           if(eachQACS.Quote_Approval_Config__r.Threshold_From__c == 0 && !eachQACS.Quote_Approval_Config__r.Partner_Only_Approval__c){                    
                                                                               if(eachQACS.Quote_Approval_Config__r.Quote_Type__c == 'Cloud'){
                                                                                   approvalReason += 'PureEngage Cloud Deal,</br> ';
                                                                               }
                                                                               else{
                                                                                   approvalReason += pricingModel + ' Deal,</br> ';                     
                                                                               }
                                                                               
                                                                           }
                                                                           else if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT)){
                                                                               if(eachQACS.Quote_Approval_Config__r.Quote_Type__c == 'Cloud')
                                                                                   approvalReason += pricingModel + ' Discount greater than '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c + '%,</br> '; //' (Discount on Deal Qualification is : ' + maxDiscount + '%), ';
                                                                               else{
                                                                                   approvalReason += pricingModel + ' Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c + '%,</br> '; //' (Discount on Deal Qualification is : ' + maxDiscount + '%), ';                            
                                                                                   uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT);                       
                                                                               }
                                                                           }                    
                                                                       }
                                                                       //Discount- Base Package
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT_SIZE_BASE_PACKAGE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT_SIZE_BASE_PACKAGE)){
                                                                               approvalReason += ' Base Package Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c + '%,</br> '; 
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_DISCOUNT_SIZE_BASE_PACKAGE);
                                                                           }                    
                                                                       }                       
                                                                       //ELA
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ELA)){               
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ELA)){
                                                                               approvalReason += 'ELA,</br>';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_ELA);
                                                                           }
                                                                       }            
                                                                       //Pricing Model - Concurrent
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT)){
                                                                               approvalReason += 'Pricing Model - Concurrent,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PRICING_MODEL_CONCURRENT);
                                                                           }
                                                                       }
                                                                       //Expiration Date
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE)){                           
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE)){
                                                                               approvalReason += 'Expiry Date Extended,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_EXPIRATION_DATE);
                                                                           }
                                                                       }
                                                                       //Special Offer Terms
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS)){
                                                                               approvalReason += 'Special Offer Terms,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_SPECIAL_OFFER_TERMS);
                                                                           }
                                                                       }
                                                                       //Initial Subscription Term
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM;
                                                                               approvalReason += ' greater than or equal to ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_INITIAL_SUBSCRIPTION_TERM );
                                                                           }
                                                                       }            
                                                                       //Ramp Period
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_RAMP_PERIOD );
                                                                           }
                                                                       }
                                                                       //Cloud Deal
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_Cloud_Deal) 
                                                                          && dq.Net_Deal_Size_Amount__c != null
                                                                          && dq.Net_Deal_Size_Amount__c <= eachQACS.Quote_Approval_Config__r.Threshold_From__c){
                                                                              if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_Cloud_Deal)){
                                                                                  if(dq.offering_type__c == 'PureCloud')
                                                                                      approvalReason += ' PureCloud Deal (ACV does not meet required minimum.)'+ ',</br> '; 
                                                                                  else if(dq.offering_type__c == 'PureConnect Cloud')
                                                                                      approvalReason += ' PureConnect Cloud Deal (ACV does not meet required minimum.)'+ ',</br> '; 
                                                                                  else
                                                                                      approvalReason += ' PureEngage Cloud Deal (ACV does not meet required minimum.)'+ ',</br> '; 
                                                                                  uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_Cloud_Deal);
                                                                                  
                                                                              }                    
                                                                          } 
                                                                       //Deal Score Cloud
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD)){
                                                                               approvalReason += ' Deal Score equals to ';
                                                                               approvalReason += dq.Deal_Score__c == null ? '0' :  String.valueOf(dq.Deal_Score__c) + ',</br> '; 
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE_CLOUD);
                                                                           } 
                                                                       }
                                                                       //Thirdparty Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ '%,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRDPARTY);
                                                                           } 
                                                                       }            
                                                                       //Business Exceptions            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR;
                                                                               approvalReason += ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_EXCEPTIONS_CMRR);
                                                                           }
                                                                       }          
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM ;
                                                                               approvalReason += ' less than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_AGENT_MINIMUM );
                                                                           }
                                                                       }            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS ;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_MAX_BUSINESS_USERS );
                                                                           }
                                                                       }            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO ;
                                                                               approvalReason += ' is not ' + Integer.valueof(eachQACS.Quote_Approval_Config__r.Threshold_From__c)+':1'+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_RATIO );
                                                                           }
                                                                       }
                                                                       //Monthly minimum            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM)){
                                                                               //approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM;
                                                                               approvalReason += 'Non-Standard PureCloud Monthly Minimum,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_MONTHLY_MINIMUM);
                                                                           }
                                                                       }            
                                                                       //PC Credit            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit;
                                                                               approvalReason += ' is applied ' +  ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Credit);
                                                                           }
                                                                       }            
                                                                       //PCC Credit-Rony Joseph-April 17th 2019 -PCC Credit Step-Begin            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PCC_Credit)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PCC_Credit)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_PCC_Credit;
                                                                               approvalReason += ' is applied ' +  ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PCC_Credit);
                                                                           }
                                                                       }
                                                                       //PCC Credit-Rony Joseph-April 17th 2019 -PCC Credit Step-End            
                                                                       //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- Start          
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM;
                                                                               approvalReason += ' is set to \'Automatic Monthly\'\\\'Automatic Initial Subscription\'\\\'No Auto-Renewal\'' +  ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_RENEWAL_SUBSCRIPTION_TERM);
                                                                           }
                                                                       } 
                                                                       
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY;
                                                                               approvalReason += ' is set to M2M ' +  ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_CATEGORY);
                                                                           }
                                                                       } 
                                                                       //Rony Joseph- June 2 2019 - Added for Enhancement INC0415890 -- End 
                                                                       //PC Trial            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial ;
                                                                               approvalReason += ' ' +  ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PC_Trial );
                                                                           }
                                                                       } 
                                                                       //PC PS Discount           
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT ;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ '%,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PSDISCOUNT );
                                                                           }
                                                                       } 
                                                                       //PC Hardware Discount           
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT ;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ '%,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWAREDISCOUNT );
                                                                           }
                                                                       } 
                                                                       //PC Software Discount           
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT ;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ '%,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_SOFTWAREDISCOUNT );
                                                                           }
                                                                       }
                                                                       //PC Overage Discount           
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT )){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT ;
                                                                               approvalReason += ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ '%,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGEDISCOUNT  );
                                                                           }
                                                                       }
                                                                       //PC TCV Reduction 
                                                                       
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION )){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION;
                                                                               approvalReason += ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_TCVREDUCTION );
                                                                           }
                                                                       }               
                                                                       
                                                                       //Billing Period            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD;
                                                                               approvalReason += ' is ' + eachQACS.Quote_Approval_Config__r.Threshold_From_Details__c+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BILLING_PERIOD );
                                                                           }
                                                                       }
                                                                       //Payment Terms
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS)){
                                                                           System.debug('NKC debug eachQACS.Quote_Approval_Config__r.Approval_Type__c [' + eachQACS.Quote_Approval_Config__r.Approval_Type__c + ']');
                                                                           
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS)){
                                                                               approvalReason += DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS;
                                                                               approvalReason += ' greater than or equal to ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS);
                                                                           }
                                                                       }
                                                                       //Care Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.equals(DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE)){
                                                                               String thresholdReason = '';
                                                                               approvalReason += 'Genesys Care  ' + eachQACS.Quote_Approval_Config__r.Care_Override_Threshold__c + ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CARE_OVERRIDE);
                                                                           }       
                                                                       }      
                                                                       //Deal Size
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE)){
                                                                               approvalReason += 'Deal size greater than or equal to '; 
                                                                               //    updateAmountToReadableFormat(eachQACS.Quote_Approval_Config__r.Threshold_From__c) + ',</br> '; // + ' (Deal size on Quote is : ' + updateAmountToReadableFormat(DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c)) + '), ';
                                                                               //Oct 18 new type for PC
                                                                               if(dq.offering_type__c == 'PureCloud'){
                                                                                   if(eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c <= 999)
                                                                                       approvalReason += eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c;
                                                                                   else
                                                                                       approvalReason += updateAmountToReadableFormat(eachQACS.Quote_Approval_Config__r.Threshold_Price_From__c ); 
                                                                                   approvalReason +=  ' and ';
                                                                                   //Discount buckets
                                                                                   String strdiscountBuckets = '';
                                                                                   
                                                                                   if(dq.Discount_On_Quote__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c )
                                                                                       strdiscountBuckets += 'Discount,';
                                                                                   if(dq.Hardware_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c )
                                                                                       strdiscountBuckets += 'Hardware Discount,';
                                                                                   if(dq.Software_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c )
                                                                                       strdiscountBuckets += 'Software Discount,';
                                                                                   if(dq.PS_Discount_on_Quote__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c )
                                                                                       strdiscountBuckets += 'PS Discount,';
                                                                                   if(dq.Overage_Discount__c > eachQACS.Quote_Approval_Config__r.Threshold_From__c )
                                                                                       strdiscountBuckets += 'Overage Discount,';   
                                                                                   
                                                                                   approvalReason +=  strdiscountBuckets.removeend(',');
                                                                                   approvalReason +=  ' greater than ' + eachQACS.Quote_Approval_Config__r.Threshold_From__c+ '%,</br> '; 
                                                                               }
                                                                               else
                                                                                   approvalReason += updateAmountToReadableFormat(eachQACS.Quote_Approval_Config__r.Threshold_From__c) + ',</br> '; // + ' (Deal size on Quote is : ' + updateAmountToReadableFormat(DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c)) + '), ';
                                                                               
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SIZE);
                                                                           }
                                                                       }
                                                                       //Term Reduced
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED)){
                                                                               approvalReason += 'Care Term Reduced,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_REDUCED);
                                                                           }       
                                                                       }
                                                                       //Term Increased
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED)){
                                                                               approvalReason += 'Care Term Increased,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_TERM_INCREASED);
                                                                           }       
                                                                       }            
                                                                       //Service Level - Decline
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE)){
                                                                               approvalReason += 'Genesys Care - Decline,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_SERVICE_LEVEL_DECLINE);
                                                                           }
                                                                       }
                                                                       //Revision
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION)){
                                                                               approvalReason += 'Minor Quote Changes,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_REVISION);
                                                                           }
                                                                       }       
                                                                       //3rd Party
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY)){               
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY)){
                                                                               approvalReason += '3rd Party Discount,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY);
                                                                           }   
                                                                       }                   
                                                                       //Product Specific
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC)){
                                                                               approvalReason += 'Product Specific Discount,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_SPECIFIC);
                                                                           }
                                                                       }
                                                                       //Premium Care
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE)){
                                                                               approvalReason += 'Premium Care,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PREMIUM_CARE);
                                                                           }
                                                                       }
                                                                       //CAD Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)){
                                                                               approvalReason += 'CAD Override,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE);
                                                                           }
                                                                       }   
                                                                       //GU Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_GU_OVERRIDE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE)){
                                                                               approvalReason += 'GU Override,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CAD_OVERRIDE);
                                                                           }
                                                                       }   
                                                                       //BEP Override
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE)){
                                                                               approvalReason += 'BEP Override,</br>';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BEP_OVERRIDE);
                                                                           }
                                                                       }  
                                                                       //Additional Legal Terms
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS)){
                                                                               approvalReason += 'Additional Legal Terms,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_ADDITIONAL_LEGAL_TERMS);
                                                                           }
                                                                       }
                                                                       //Editable List Price 
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE)){
                                                                               approvalReason += 'Editable List Price ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_EDITABLE_LIST_PRICE);
                                                                           }
                                                                       }
                                                                       //Require Separate Quote for Genesys Care - Notification
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC)){
                                                                               approvalReason += 'Require Separate Quote for Genesys Care - Notification,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_REQUIRE_SEP_QUOTE_FOR_GC);
                                                                           }
                                                                       }         
                                                                       //Future Products - Notification
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS)){
                                                                               approvalReason += 'Future Products - Notification,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_FUTURE_PRODUCTS);
                                                                           }
                                                                       }     
                                                                       //Profressional Services - Notification    
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PS)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PS)){
                                                                               approvalReason += 'Profressional Services - Notification,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PS);
                                                                           }
                                                                       }     
                                                                       //Third Party Override            
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE)){
                                                                               approvalReason += 'Third Party Care Override,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_THIRD_PARTY_OVERRIDE);
                                                                           }
                                                                       }            
                                                                       //Old Pricing
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing)){
                                                                               approvalReason += 'Old Pricing Approval,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_Type_Old_Pricing);
                                                                           }       
                                                                       }
                                                                       //Cloud Partner
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER)){
                                                                               approvalReason += 'No Cloud Partner,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CLOUD_PARTNER);
                                                                           }
                                                                       }
                                                                       //PPU Deal
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL)){
                                                                               approvalReason += 'PPU Deal,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PPU_DEAL);
                                                                           }
                                                                       }
                                                                       //Finance Exceptions
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION)){
                                                                               approvalReason += 'Finance Exceptions,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_FINANCE_EXCEPTION);
                                                                           }
                                                                       }
                                                                       //Legal Exceptions
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION)){
                                                                               approvalReason += 'Legal Exceptions,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_LEGAL_EXCEPTION);
                                                                           }
                                                                       }
                                                                       //Support Options
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT)){
                                                                               approvalReason += 'Priority/VIP Priority Support,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PRIORITY_VIP_SUPPORT);
                                                                           }
                                                                       }        
                                                                       //Base Agent Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT)){
                                                                               String strReason = 'Base Agent Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c;
                                                                               approvalReason += strReason + ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BASE_AGENT_DISCOUNT);
                                                                           }
                                                                       }        
                                                                       //Hardware Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT)){
                                                                               String strReason = 'Telco, MPLS, Hardware, 3rd Party, and Miscellaneous Costs Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c;
                                                                               approvalReason += strReason + ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_HARDWARE_DISCOUNT);
                                                                           }
                                                                       }        
                                                                       //Add-On Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT)){
                                                                               String strReason = 'Business Users & Add-On Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c;
                                                                               approvalReason += strReason + ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_ADD_ON_DISCOUNT);
                                                                           }
                                                                       }        
                                                                       //Business Users Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT)){
                                                                               String strReason = 'Business Users Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c;
                                                                               approvalReason += strReason + ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_BUSINESS_USER_DISCOUNT);
                                                                           }
                                                                       }
                                                                       //Data Center Discount
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT)){
                                                                               String strReason = 'Data Center Discount greater than or equal to '+ eachQACS.Quote_Approval_Config__r.Threshold_From__c;
                                                                               approvalReason += strReason + ',</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_DATA_CENTER_DISCOUNT);
                                                                           }
                                                                       }
                                                                       //Carveout 
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT)){
                                                                               approvalReason += 'Carveout ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CARVEOUT);
                                                                           }
                                                                       }   
                                                                       //SMART Use Cae 
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE)){
                                                                               approvalReason += 'SMART Use Case ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_SMART_USE_CASE);
                                                                           }
                                                                       }   
                                                                       //Annual Price Escalator
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR)){
                                                                               approvalReason += 'Annual Price Escalator  - ' + eachQACS.Quote_Approval_Config__r.Criteria__c +' ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_ANNUAL_PRICE_ESCALATOR);
                                                                           }
                                                                       }   
                                                                       //Overage Allowance 
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE)){
                                                                               approvalReason += 'Overage Allowance  - ' + eachQACS.Quote_Approval_Config__r.Criteria__c + ' ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_OVERAGE_ALLOWANCE);
                                                                           }
                                                                       }   
                                                                       //Payment Terms 
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION)){
                                                                           system.debug('checking loop');
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION)){
                                                                               approvalReason += 'Payment Terms - ' + eachQACS.Quote_Approval_Config__r.Criteria__c + ' ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PAYMENT_TERMS_SUBSCRIPTION);
                                                                           }
                                                                       }    
                                                                       //Subscription Smart Qualified Approval
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL)){
                                                                               approvalReason += 'Partner is not SMART and Subscription Qualified ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_SUBSCRIPTION_SMART_QUALIFIED_APPROVAL);
                                                                           }
                                                                       }
                                                                       //Rental Quote
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE)){
                                                                               approvalReason += 'Rental Quote ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_RENTAL_QUOTE);
                                                                           }
                                                                       }
                                                                       //Usage Data Submission Method
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD)){
                                                                               approvalReason += 'Usase Data Submission Method - No Bursting/Manual ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_USASE_DATA_SUBMISSION_METHOD);
                                                                           }
                                                                       }
                                                                       //Deal Score
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE)){
                                                                               approvalReason += 'Deal score equal to '; 
                                                                               approvalReason += dq.Deal_Score__c == null ? '0' :  String.valueOf(dq.Deal_Score__c) + ',</br> ';
                                                                               //approvalReason += updateAmountToReadableFormat(eachQACS.Quote_Approval_Config__r.Threshold_From__c) + ',</br> '; // + ' (Deal size on Quote is : ' + updateAmountToReadableFormat(DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c)) + '), ';                    
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_DEAL_SCORE);
                                                                           }
                                                                       }
                                                                       //Conversion Quote
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_QUOTE_CONVERSION)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_QUOTE_CONVERSION)){
                                                                               approvalReason += 'Conversion Quote ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_QUOTE_CONVERSION);
                                                                           }
                                                                       }
                                                                       //Contractual Rate
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CONTRACTUAL_RATE)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CONTRACTUAL_RATE)){
                                                                               approvalReason += 'Contractual Rate ,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CONTRACTUAL_RATE);
                                                                           }
                                                                       }
                                                                       
                                                                       //Product management
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT)){
                                                                               approvalReason += 'PM Approval,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_PRODUCT_MANAGEMENT);
                                                                           }
                                                                       }
                                                                       
                                                                       //Seasonal Licensing
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SEASONAL_LICENSING)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_SEASONAL_LICENSING)){
                                                                               approvalReason += 'Seasonal Licensing,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_SEASONAL_LICENSING);
                                                                           }
                                                                       }
                                                                       //Credits
                                                                       if(eachQACS.Quote_Approval_Config__r.Approval_Type__c.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CREDIT_APPLIED)){
                                                                           if(!uniqueReason.contains(DealQualificationApprovalUtil.APPROVAL_TYPE_CREDIT_APPLIED)){
                                                                               approvalReason += 'Credit Applied,</br> ';
                                                                               uniqueReason.add(DealQualificationApprovalUtil.APPROVAL_TYPE_CREDIT_APPLIED);
                                                                           }
                                                                       }
                                                                       
                                                                       
                                                                   }
                                                                   return approvalReason;
                                                               }
    
    @TestVisible
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
    
    @TestVisible
    private static Boolean getApprovalForDealScoreThresholdTypeIfAny(List<Quote_Approval_Step_Details__c> filteredApprovalRecords,
                                                                     Quote_Approval_Config_And_Steps__c eachQACS, Quote_Approval_Step_Details__c eachQASD, Double valueOnQuote, Decimal dealScoreOnDQ){ 
                                                                         String dealScorValueseOnConfig = eachQACS.Quote_Approval_Config__r.Criteria__c == null ? '' : eachQACS.Quote_Approval_Config__r.Criteria__c;
                                                                         Set<Decimal> setOfDealScoreValuesConfig = new Set<Decimal>();
                                                                         for(String eachScore : dealScorValueseOnConfig.split(';')){
                                                                             setOfDealScoreValuesConfig.add(Decimal.valueOf(eachScore));             
                                                                         }
                                                                         System.debug('NKC setOfDealScoreValuesConfig [' + setOfDealScoreValuesConfig + ']');
                                                                         System.debug('NKC dealScoreOnDQ [' + dealScoreOnDQ + ']');
                                                                         
                                                                         if(eachQACS.Quote_Approval_Config__r.Threshold_From__c != null 
                                                                            && (valueOnQuote >= eachQACS.Quote_Approval_Config__r.Threshold_From__c 
                                                                                && (eachQACS.Quote_Approval_Config__r.Threshold_To__c == null ||
                                                                                    valueOnQuote <= eachQACS.Quote_Approval_Config__r.Threshold_To__c))
                                                                            && setOfDealScoreValuesConfig.contains(dealScoreOnDQ)){
                                                                                filteredApprovalRecords.add(eachQASD);
                                                                                return true;
                                                                            }       
                                                                         return false;
                                                                     }
    
    public static Set<Id> getAlreadyApprovedRecords(Deal_Qualification__c dq,  Decimal submissionCounter){
        Set<Id> setAlreadyApprovedStepDetailsIds = new Set<Id>();
        
        //Will contain already approved config records
        List<Quote_Approval__c> quoteApprovalsApproved = [SELECT Quote_Approval_Step_Details__c FROM Quote_Approval__c
                                                          WHERE BigMachines_Quote__c =: dq.id              
                                                          AND Status__c =: DealQualificationApprovalUtil.STATUS_APPROVED AND Approval_Submission_Counter__c =: (submissionCounter -1)];
        for(Quote_Approval__c eachQA : quoteApprovalsApproved){
            setAlreadyApprovedStepDetailsIds.add(eachQA.Quote_Approval_Step_Details__c);
        }
        System.debug('NKC debug setAlreadyApprovedStepDetailsIds ['+setAlreadyApprovedStepDetailsIds+']');
        return setAlreadyApprovedStepDetailsIds;
    }
    
    public static List<Quote_Approval_Step_Details__c> getQuoteApprovalsIfReviseQuoteIsApplicableUpfront(Deal_Qualification__c dq, Decimal submissionCounter){
        //if(!dq.Revise_Minor__c)
        return null;
        /*
String reviseMinorType = DealQualificationApprovalUtil.MINOR_QUOTE_CHANGE_ONLY; 
if(dq.Expiration_Date__c > System.today().addDays(91)){              
reviseMinorType = DealQualificationApprovalUtil.EXPIRATION_DATE_ONLY;
}
Set<Id> stepIds = new Set<Id>();
//Getting quote approvals steps
Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = DealQualificationApprovalUtil.getQuoteApprvalConfigRecords(dq, stepIds);
//Getting quote approval records
List<Quote_Approval_Step_Details__c> quoteApprovers = DealQualificationApprovalUtil.getQuoteApprovalRecords(stepIds, dq);               
//Filters quote approval records for current quote
mapIdVsQuoteApprovalSteps = DealQualificationAppAssignmentHelper.filterQuoteApprovals(dq, quoteApprovers, mapIdVsQuoteApprovalSteps);
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
|| (eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == DealQualificationApprovalUtil.EXPIRATION_DATE_ONLY
&& reviseMinorType == DealQualificationApprovalUtil.MINOR_QUOTE_CHANGE_ONLY)                    
|| setOfApprovers.contains(eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId))
continue;
if(firstOrderNo == 0)
firstOrderNo = eachRecord.Quote_Approval_Step__r.Order__c;
//New quote approvals record
Quote_Approval__c newQuoteApproval = new Quote_Approval__c();
newQuoteApproval.BigMachines_Quote__c = dq.id;
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
newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_PENDING;
else
newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_INACTIVE;

if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c  == DealQualificationApprovalUtil.EXPIRATION_DATE_ONLY)
newQuoteApproval.Reason_Name__c = 'Minor Revision, Expiration Date';
else
newQuoteApproval.Reason_Name__c = 'Minor Revision';
newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
quoteApprovals.add(newQuoteApproval);
}
return quoteApprovalStepDetails;
*/
    }
    
    public static List<Quote_Approval__c> getQuoteApprovalsIfReviseQuoteIsApplicable(Deal_Qualification__c dq, Decimal submissionCounter, Boolean Upfront){
        //if(!dq.Revise_Minor__c)
        return null;
        /*
String reviseMinorType = DealQualificationApprovalUtil.MINOR_QUOTE_CHANGE_ONLY; 
if(dq.Expiration_Date__c > System.today().addDays(91)){              
reviseMinorType = DealQualificationApprovalUtil.EXPIRATION_DATE_ONLY;
}
Set<Id> stepIds = new Set<Id>();
//Getting quote approvals steps
Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = DealQualificationApprovalUtil.getQuoteApprvalConfigRecords(dq, stepIds);
//Getting quote approval records
List<Quote_Approval_Step_Details__c> quoteApprovers = DealQualificationApprovalUtil.getQuoteApprovalRecords(stepIds, dq);               
//Filters quote approval records for current quote
mapIdVsQuoteApprovalSteps = DealQualificationAppAssignmentHelper.filterQuoteApprovals(dq, quoteApprovers, mapIdVsQuoteApprovalSteps);
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
|| (eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == DealQualificationApprovalUtil.EXPIRATION_DATE_ONLY
&& reviseMinorType == DealQualificationApprovalUtil.MINOR_QUOTE_CHANGE_ONLY)                    
|| setOfApprovers.contains(eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId))
continue;
if(firstOrderNo == 0)
firstOrderNo = eachRecord.Quote_Approval_Step__r.Order__c;
//New quote approvals record
Quote_Approval__c newQuoteApproval = new Quote_Approval__c();
newQuoteApproval.BigMachines_Quote__c = dq.id;
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
newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_PENDING;
else
newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_INACTIVE;
if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c  == DealQualificationApprovalUtil.EXPIRATION_DATE_ONLY)
newQuoteApproval.Reason_Name__c = 'Minor Revision, Expiration Date';
else
newQuoteApproval.Reason_Name__c = 'Minor Revision';
newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
quoteApprovals.add(newQuoteApproval);
}
if(quoteApprovals.isEmpty())
return null;
return quoteApprovals;
*/
    }
    
    public static void approvalRejectionActions(String dqId){
        //Getting approval submission order
        Decimal submissionCounter = DealQualificationApprovalUtil.getApprovalSubmission(dqId, -1);
        System.debug('NKC debug submissionCounter ['+submissionCounter+']');
        //Getting approval records from last submission
        List<Quote_Approval__c> quoteApprovalsToBeDeActivated = [SELECT Status__c FROM Quote_Approval__c 
                                                                 WHERE Deal_Qualification__c =: dqId AND Approval_Submission_Counter__c =: submissionCounter];
        //Looping over each quote approval record and updating status
        for(Quote_Approval__c eachQA : quoteApprovalsToBeDeActivated){
            if(eachQA.Status__c == DealQualificationApprovalUtil.STATUS_PENDING){
                eachQA.Status__c = DealQualificationApprovalUtil.STATUS_CANCELLED;
                eachQA.Comments__c = 'Quote Rejected.';
                eachQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.QUOTE_REJECTED_BEFORE_APPROVAL;
            }            
        }
        if(!quoteApprovalsToBeDeActivated.isEmpty())
            update quoteApprovalsToBeDeActivated;
    }
    
    public static void cancelDQApprovalsOnRevise(String dqId){
        //Getting approval submission order
        Decimal submissionCounter = DealQualificationApprovalUtil.getApprovalSubmission(dqId, -1);        
        //Getting approval records from last submission
        List<Quote_Approval__c> quoteApprovals = [SELECT Status__c FROM Quote_Approval__c 
                                                  WHERE Deal_Qualification__c =: dqId AND Approval_Submission_Counter__c =: submissionCounter];
        List<Quote_Approval__c> quoteApprovalsToBeDeActivated = new List<Quote_Approval__c>();
        //Looping over each quote approval record and updating status
        for(Quote_Approval__c eachQA : quoteApprovals){
            if(eachQA.Status__c == DealQualificationApprovalUtil.STATUS_PENDING){
                eachQA.Status__c = DealQualificationApprovalUtil.STATUS_CANCELLED;
                eachQA.Comments__c = 'DQ Revised.';
                eachQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.QUOTE_REVISED_BEFORE_APPROVAL;
                quoteApprovalsToBeDeActivated.add(eachQA);
            }            
        }
        if(!quoteApprovalsToBeDeActivated.isEmpty())
            update quoteApprovalsToBeDeActivated;  
    }
    
    public static void byPassApprovals(String dqId){
        //Getting approval submission order
        Decimal submissionCounter = DealQualificationApprovalUtil.getApprovalSubmission(dqId, -1);
        //Getting approval records from last submission
        List<Quote_Approval__c> quoteApprovalsToBeApproved = [SELECT Status__c FROM Quote_Approval__c 
                                                              WHERE Deal_Qualification__c =: dqId 
                                                              AND Status__c =: DealQualificationApprovalUtil.STATUS_PENDING 
                                                              AND Approval_Submission_Counter__c =: submissionCounter];
        //Looping over each quote approval record and updating status
        for(Quote_Approval__c eachQA : quoteApprovalsToBeApproved){
            eachQA.Status__c = DealQualificationApprovalUtil.STATUS_APPROVED;            
            eachQA.Comments__c = DealQualificationApprovalUtil.APPROVAL_BY_PASSED;
            eachQA.Actual_Approver__c = UserInfo.getUserId();
        }
        if(!quoteApprovalsToBeApproved.isEmpty())
            update quoteApprovalsToBeApproved;
    }
    
    public static void quoteRevisionActions(List<BigMachines__Quote__c> newList, Map<id, BigMachines__Quote__c> oldMap){
        BigMachines__Quote__c currentQuote = newList[0];
        if(currentQuote.BigMachines__Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_REVISION_PENDING
           && oldMap.get(currentQuote.id).BigMachines__Status__c != DealQualificationApprovalUtil.QUOTE_STATUS_REVISION_PENDING){
               //Getting approval submission order
               Decimal submissionCounter = DealQualificationApprovalUtil.getApprovalSubmission(currentQuote.id, -1);
               //Getting approval records from last submission
               //Decimal submissionCounter = 1;
               List<Quote_Approval__c> quoteApprovalsToBeDeActivated = [SELECT Status__c FROM Quote_Approval__c 
                                                                        WHERE BigMachines_Quote__c =: currentQuote.id 
                                                                        AND Status__c =: DealQualificationApprovalUtil.STATUS_PENDING 
                                                                        AND Approval_Submission_Counter__c =: submissionCounter];
               //Looping over each quote approval record and updating status
               for(Quote_Approval__c eachQA : quoteApprovalsToBeDeActivated){
                   eachQA.Status__c = DealQualificationApprovalUtil.STATUS_CANCELLED;
                   eachQA.Trigger_Email_Alert__c = DealQualificationApprovalUtil.QUOTE_REVISED_BEFORE_APPROVAL;
                   eachQA.Comments__c = 'Quote Revised.';
               }
               update quoteApprovalsToBeDeActivated;
           }       
    }
    @TestVisible
    private static String updateAmountToReadableFormat(Decimal amount){
        Integer amountInt = Integer.valueOf(amount);
        String amountStr = '0';
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
}