public without sharing class DealQualificationApprovalAssignment {
  public static String submitDQToApproval(Deal_Qualification__c dq){
        try{
            //Quote can't be submitted if status is Quote Approval Pending
            if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_PENDING)  
                return 'Quote can not be submitted when status is Approval Pending.'; 
            
            //populates all the step(s) 
            List<Quote_Approval__c> quoteApprovalsToBeInserted = getNextApprovalRecords(dq, 0);
            //quote approvals excluding notification only
            List<Quote_Approval__c> quoteApprovalsWONotificationOnly = new List<Quote_Approval__c>();
            if(quoteApprovalsToBeInserted != null){
              for(Quote_Approval__c eachQA : quoteApprovalsToBeInserted){
                if(eachQA.Status__c != DealQualificationApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY)
                  quoteApprovalsWONotificationOnly.add(eachQA);
              }
            }
            //Approval not required
            if(quoteApprovalsWONotificationOnly.isEmpty()){
                dq.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_APPROVED;     
                updateDealQualificationApprovalHistory(dq.id);
                //dq.DAP_Reason__c = null;     
            }
            //Approval required
            else{
                dq.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_PENDING;                              
            }         
            dq.Submission_Date__c = System.today();             
            update dq;           
            if(quoteApprovalsToBeInserted != null && !quoteApprovalsToBeInserted.isEmpty()){              
                insert quoteApprovalsToBeInserted;                
                if(quoteApprovalsToBeInserted != null && !quoteApprovalsToBeInserted.isEmpty()){
                  List<Quote_Approval__c> quoteApproval = [SELECT Step_Name__c FROM Quote_Approval__c WHERE id =: quoteApprovalsToBeInserted[0].id];
                dq = QuoteApprovalMainHelper.updateTimestampOnDQ(dq, 'Submission', quoteApproval[0].Step_Name__c);
                }
              update dq;
            }   
            return 'OK';
        }
        catch(Exception ex){
            return 'Error while submitting for approval. Error : ' + ex.getMessage();
        }
        return 'OK';
    }
    
    public static Deal_Qualification__c getDQHistoryRecord(Deal_Qualification__c dq){
      List<Deal_Qualification__c> dqHistoryRecord = DealQualificationApprovalUtil.getDQ(dq.Opportunity__c, dq.Pricing_Type__c, dq.Platform_Type__c, dq.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_HISTORY);
      if(dqHistoryRecord.isEmpty())
        return null;
      else{        
        return dqHistoryRecord[0];
      }
      return null;  
    } 
    @future
    public static void updateDealQualificationApprovalHistory(String dqId){
      Deal_Qualification__c dq = DealQualificationApprovalUtil.getDQFromId(dqId);
      List<Deal_Qualification__c> dqHistoryRecord = DealQualificationApprovalUtil.getDQHistory(dq.Opportunity__c, dq.Pricing_Type__c, dq.Platform_Type__c, dq.Offering_Type__c);
      Deal_Qualification__c dqHistory;  
      if(dqHistoryRecord.isEmpty()){
        Deal_Qualification__c newDQHistoryRecord = dq.clone(false, true, false, false);
        newDQHistoryRecord.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        insert newDQHistoryRecord;
        dqHistoryRecord.add(newDQHistoryRecord);
        dqHistory = dqHistoryRecord[0];      
      }
      else{
        List<Deal_Qualification_Products__c> dqProductsToBeDeleted = DealQualificationApprovalUtil.getDQProducts(dqHistoryRecord[0].id);
        if(!dqProductsToBeDeleted.isEmpty()){
          delete dqProductsToBeDeleted;
        }    
        dqHistory = dqHistoryRecord[0];
        //Anju August 2018
        if(dq.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
            dqHistory.quote__c = dq.quote__c;
        //Discount
        Double discountOnOriginalDQ = DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c);
        Double discountOnHistoryDQ = DealQualificationApprovalUtil.getDiscountSize(dqHistory.New_Pricing_Discount__c);
        if(discountOnOriginalDQ > discountOnHistoryDQ){
          dqHistory.New_Pricing_Discount__c = dq.New_Pricing_Discount__c;
        }    
        if(dqHistory.Discount_On_Quote__c == null)
            dqHistory.Discount_On_Quote__c = 0;
        if(dq.Discount_On_Quote__c != null && dq.Discount_On_Quote__c > dqHistory.Discount_On_Quote__c){
            dqHistory.Discount_On_Quote__c = dq.Discount_On_Quote__c;    
        }
        //ELA
        if(dq.ELA__c == 'Yes'){
          dqHistory.ELA__c = dq.ELA__c;
        }        
        //Pricing Model - Concurrent
          if(dq.Pricing_Model__c != dqHistory.Pricing_Model__c){
            dqHistory.Pricing_Model__c = dq.Pricing_Model__c;
          }
          //Expiration Date
          if(dq.Expiration_Date__c > dqHistory.Expiration_Date__c || dqHistory.Expiration_Date__c == null){
            dqHistory.Expiration_Date__c = dq.Expiration_Date__c;
          }
          //Special Offer Terms
          if((dq.Special_Offer_Terms__c && !dqHistory.Special_Offer_Terms__c) || dqHistory.Special_Offers_Business_Exceptions__c != dq.Special_Offers_Business_Exceptions__c){
            dqHistory.Special_Offer_Terms__c = dq.Special_Offer_Terms__c;
            dqHistory.Special_Offers_Business_Exceptions__c = dq.Special_Offers_Business_Exceptions__c;
          }
          
          //Anju Nov 2017 - new approvals
          //Initial Subscription Term
          if(DealQualificationApprovalUtil.getInitialSubscriptionTerm(dq.Initial_Subscription_Term_Months_PC__c,dq.If_Other_Term_Months_Requested__c) > DealQualificationApprovalUtil.getInitialSubscriptionTerm(dqHistory.Initial_Subscription_Term_Months_PC__c,dqHistory.If_Other_Term_Months_Requested__c)){
            dqHistory.Initial_Subscription_Term_Months_PC__c = dq.Initial_Subscription_Term_Months_PC__c;
            dqHistory.If_Other_Term_Months_Requested__c= dq.If_Other_Term_Months_Requested__c;
          }
          //Ramp Period
          if(DealQualificationApprovalUtil.getRampPeriod(dq.Ramp_Period_Days__c,dq.If_Other_Ramp_Period_Requested_Days__c) > DealQualificationApprovalUtil.getRampPeriod(dqHistory.Ramp_Period_Days__c,dqHistory.If_Other_Ramp_Period_Requested_Days__c)){
            dqHistory.Ramp_Period_Days__c = dq.Ramp_Period_Days__c;
            dqHistory.If_Other_Ramp_Period_Requested_Days__c = dq.If_Other_Ramp_Period_Requested_Days__c;
          }
                    
          //Business Exceptions 
          if(dq.Estimated_Monthly_Recurring_Revenue__c > dqHistory.Estimated_Monthly_Recurring_Revenue__c){
            dqHistory.Estimated_Monthly_Recurring_Revenue__c = dq.Estimated_Monthly_Recurring_Revenue__c;            
          }
          
          if(dq.Estimated_Number_of_Agents__c < dqHistory.Estimated_Number_of_Agents__c || (dq.Estimated_Number_of_Agents__c != null && dqHistory.Estimated_Number_of_Agents__c == null)){
            dqHistory.Estimated_Number_of_Agents__c= dq.Estimated_Number_of_Agents__c;            
          }
          if(dq.Less_than_100_Agents__c != dqHistory.Less_than_100_Agents__c){
            dqHistory.Less_than_100_Agents__c = dq.Less_than_100_Agents__c;            
          }
          
          if(dq.Estimated_Number_of_Business_Users__c > dqHistory.Estimated_Number_of_Business_Users__c || (dq.Estimated_Number_of_Business_Users__c != null && dqHistory.Estimated_Number_of_Business_Users__c == null)){
            dqHistory.Estimated_Number_of_Business_Users__c = dq.Estimated_Number_of_Business_Users__c;            
          }
          if(dq.More_than_5_000_Business_Users__c != dqHistory.More_than_5_000_Business_Users__c){
            dqHistory.More_than_5_000_Business_Users__c = dq.More_than_5_000_Business_Users__c;            
          }
          
          if(dq.Business_User_to_Agent_Ratio_Exception__c != dqHistory.Business_User_to_Agent_Ratio_Exception__c && dq.Business_User_to_Agent_Ratio_Exception__c == 'Yes'){
            dqHistory.Business_User_to_Agent_Ratio_Exception__c = dq.Business_User_to_Agent_Ratio_Exception__c;            
          }
          
          //Business Exceptions
          if(dq.Monthly_Recurring_Revenue_less_than_14K__c != dqHistory.Monthly_Recurring_Revenue_less_than_14K__c || dq.Estimated_Monthly_Recurring_Revenue__c < dqHistory.Estimated_Monthly_Recurring_Revenue__c){
            dqHistory.Monthly_Recurring_Revenue_less_than_14K__c= dq.Monthly_Recurring_Revenue_less_than_14K__c;
            dqHistory.Estimated_Monthly_Recurring_Revenue__c = dq.Estimated_Monthly_Recurring_Revenue__c;
          }
          
          //PC Credit
          if(dq.PureCloud_Credit_Applied__c != dqHistory.PureCloud_Credit_Applied__c && dq.PureCloud_Credit_Applied__c){            
            dqHistory.PureCloud_Credit_Applied__c = dq.PureCloud_Credit_Applied__c;
          }
          
          //PC Trial
          if(dq.PureCloud_Trial__c != dqHistory.PureCloud_Trial__c && dq.PureCloud_Trial__c){            
            dqHistory.PureCloud_Trial__c = dq.PureCloud_Trial__c;
          }
          
          //PC PS Discount
          
          if(dq.PS_Discount_on_Quote__c != dqHistory.PS_Discount_on_Quote__c && (dq.PS_Discount_on_Quote__c > dqHistory.PS_Discount_on_Quote__c || dqHistory.PS_Discount_on_Quote__c == null)){            
            dqHistory.PS_Discount_on_Quote__c = dq.PS_Discount_on_Quote__c;
          }
          //PC Hardware Discount          
          if(dq.Hardware_Discount__c != dqHistory.Hardware_Discount__c && (dq.Hardware_Discount__c > dqHistory.Hardware_Discount__c || dqHistory.Hardware_Discount__c ==  null)){            
            dqHistory.Hardware_Discount__c = dq.Hardware_Discount__c;
          }
          
          //PC Software Discount          
          if(dq.Software_Discount__c  != dqHistory.Software_Discount__c  && (dq.Software_Discount__c  > dqHistory.Software_Discount__c || dqHistory.Software_Discount__c == null)){            
            dqHistory.Software_Discount__c  = dq.Software_Discount__c;
          } 
          
          //PC Overage Discount          
          if(dq.Overage_Discount__c != dqHistory.Overage_Discount__c && (dq.Overage_Discount__c > dqHistory.Overage_Discount__c || dqHistory.Overage_Discount__c == null)){            
            dqHistory.Overage_Discount__c = dq.Overage_Discount__c;
          } 
          
          //PC TCV Reduction  
                
          if(dq.TCV_Reduction__c != dqHistory.TCV_Reduction__c && (dq.TCV_Reduction__c > dqHistory.TCV_Reduction__c || dqHistory.TCV_Reduction__c == null)){            
            dqHistory.TCV_Reduction__c = dq.TCV_Reduction__c;
          } 
          
          
          //Monthly Minimum
          if(dq.If_Other_PureCloud_Monthly_Minimum_Req__c < dqHistory.If_Other_PureCloud_Monthly_Minimum_Req__c || (dq.If_Other_PureCloud_Monthly_Minimum_Req__c != null && dqHistory.If_Other_PureCloud_Monthly_Minimum_Req__c == null)){
            
            dqHistory.If_Other_PureCloud_Monthly_Minimum_Req__c = dq.If_Other_PureCloud_Monthly_Minimum_Req__c;
          }
          
          //Billing Period
          if(DealQualificationApprovalUtil.getBillingPeriod(dq.Billing_Period__c) != DealQualificationApprovalUtil.getBillingPeriod(dqHistory.Billing_Period__c)){
            dqHistory.Billing_Period__c= dq.Billing_Period__c;            
          }
          //Payment Terms
          if(DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c) > DealQualificationApprovalUtil.getPaymentTerms(dqHistory.Payment_Terms__c)){
            dqHistory.Payment_Terms__c = dq.Payment_Terms__c;            
          }
          
          //Anju Nov 2017 - new approvals ends
          
          //Care Override 
          if(DealQualificationAndQuoteApprovalHelper.getOverrideScore(dq.GC_Override__c) > DealQualificationAndQuoteApprovalHelper.getOverrideScore(dqHistory.GC_Override__c)){
            dqHistory.GC_Override__c = dq.GC_Override__c;
          }
          //Deal Size
          if(DealQualificationApprovalUtil.getDealSize(dq.Net_Deal_Value__c) > DealQualificationApprovalUtil.getDealSize(dqHistory.Net_Deal_Value__c)){
            dqHistory.Net_Deal_Value__c = dq.Net_Deal_Value__c;
          }
          //Anju for PEC
          /*if((dq.offering_type__c == 'Business Edition' || dq.offering_type__c == 'PureCloud' || dq.offering_type__c == 'PureConnect Cloud') && (dq.Net_Deal_Value__c == null || (Integer.valueof(dq.Net_Deal_Value__c) < Integer.valueof(dqHistory.Net_Deal_Value__c)))){
            dqHistory.Net_Deal_Value__c = dq.Net_Deal_Value__c;
          }*/
          //Term Decreased
          if(dq.Term_Decrease__c && !dqHistory.Term_Decrease__c){
            dqHistory.Term_Decrease__c = dq.Term_Decrease__c;
          }
          //Term Increased
          if(dq.Term_Increase__c && !dqHistory.Term_Increase__c){
            dqHistory.Term_Increase__c = dq.Term_Increase__c;
          }
          //Service Level 
          if(dq.Service_Level__c != dqHistory.Service_Level__c){
            dqHistory.Service_Level__c = dq.Service_Level__c;
          }
          //Service Level - Decline
          if(dq.Decline__c){
            dqHistory.Decline__c = dq.Decline__c;
          }
          //Term Increased
          if(dq.CAD_Override__c && !dqHistory.CAD_Override__c){
            dqHistory.CAD_Override__c = dq.CAD_Override__c;
          }
          //Additional Legal Terms
          if(dq.Additional_Legal_Terms__c && !dqHistory.Additional_Legal_Terms__c){
            dqHistory.Additional_Legal_Terms__c = dq.Additional_Legal_Terms__c;
          }
          //Premium Care
          if(dq.Premium_Care__c && !dqHistory.Premium_Care__c){
            dqHistory.Premium_Care__c = dq.Premium_Care__c;
          }  
          //3rd Party Care Override
          if(dq.X3rd_Party_Override__c && !dqHistory.X3rd_Party_Override__c)
            dqHistory.X3rd_Party_Override__c = dq.X3rd_Party_Override__c;
          //Cloud Approval
          if(dq.Cloud_Partner_Approval__c)
            dqHistory.Cloud_Partner_Approval__c = dq.Cloud_Partner_Approval__c ;
          //PPU Deal
          if(dq.PPU_Deal_Approval__c)
            dqHistory.PPU_Deal_Approval__c = dq.PPU_Deal_Approval__c;
          //Old Pricing
          if(dq.IsOldPricingApproved__c)
              dqHistory.IsOldPricingApproved__c = dq.IsOldPricingApproved__c;   
          if(dq.Editable_List_Price_Approval_Required__c)
              dqHistory.Editable_List_Price_Approval_Required__c = dq.Editable_List_Price_Approval_Required__c;
          //Carveout
          if(dq.Carveout__c || dq.CarveOutDetails__c != dqHistory.CarveOutDetails__c){
              dqHistory.Carveout__c = dq.Carveout__c;
              dqHistory.CarveOutDetails__c = dq.CarveOutDetails__c;
          }
          //Finance Exception Approval
          dqHistory.Finance_Exception__c = dq.Finance_Exception__c;          
          //Legal Exceptions
          dqHistory.Legal_Exceptions__c = dq.Legal_Exceptions__c;          
          //Term Length
          dqHistory.Term_Length__c = dq.Term_Length__c;
          //Support Option
          dqHistory.Support_Option__c = dq.Support_Option__c;
          //Base Agent Discount
          if(dqHistory.Base_Agent_Discount__c == null || dqHistory.Base_Agent_Discount__c < dq.Base_Agent_Discount__c)
            dqHistory.Base_Agent_Discount__c = dq.Base_Agent_Discount__c;
          //Hardware Discount
          if(dqHistory.Hardware_Discount__c == null || dqHistory.Hardware_Discount__c < dq.Hardware_Discount__c)
            dqHistory.Hardware_Discount__c = dq.Hardware_Discount__c;
          //Add-On Discount
          if(dqHistory.Business_Users_Add_On__c == null || dqHistory.Business_Users_Add_On__c < dq.Business_Users_Add_On__c)
            dqHistory.Business_Users_Add_On__c = dq.Business_Users_Add_On__c;          
          //Business Users & Data Center Discount
          if(dqHistory.Business_Users_Provisioning_Discount__c == null || dqHistory.Business_Users_Provisioning_Discount__c < dq.Business_Users_Provisioning_Discount__c)
            dqHistory.Business_Users_Provisioning_Discount__c = dq.Business_Users_Provisioning_Discount__c;
          //Data Center Discount
          if(dqHistory.Data_Center_Provisioning_Discount__c == null || dqHistory.Data_Center_Provisioning_Discount__c < dq.Data_Center_Provisioning_Discount__c)
            dqHistory.Data_Center_Provisioning_Discount__c = dq.Data_Center_Provisioning_Discount__c;
          //Rental
          if(dqHistory.Rental__c != dq.Rental__c)
              dqHistory.Rental__c = dq.Rental__c;
          if(dqHistory.Usage_Data_Submission_Method__c != dq.Usage_Data_Submission_Method__c)
              dqHistory.Usage_Data_Submission_Method__c = dq.Usage_Data_Submission_Method__c;
          
          //Deal Score
          dqHistory.Deal_Score__c = dq.Deal_Score__c;
          //Conversion Quote
          dqHistory.Conversion_Quote__c = dq.Conversion_Quote__c;
          //Contractual Rate
          dqHistory.Contractual_Rate_Approval__c = dq.Contractual_Rate_Approval__c;
          // Third Party
          if((dqHistory.Third_Party_Discount__c == null || dqHistory.Third_Party_Discount__c < dq.Third_Party_Discount__c)&&(dqHistory.Third_Party_Discount__c != dq.Third_Party_Discount__c)) {
             dqHistory.Third_Party_Discount__c  = dq.Third_Party_Discount__c;
          }
          
          //Subscription
          if(dq.Offering_Type__c == 'PureEngage Subscription' || dq.Offering_Type__c == 'PureConnect Subscription'){
            //Base Package Discount
            Double baseDiscountOnOriginalDQ = DealQualificationApprovalUtil.getDiscountSize(dq.Discount_Base_Package__c);
            Double baseDiscountOnHistoryDQ = DealQualificationApprovalUtil.getDiscountSize(dqHistory.Discount_Base_Package__c);
            if(baseDiscountOnOriginalDQ > baseDiscountOnHistoryDQ){
                dqHistory.Discount_Base_Package__c = dq.Discount_Base_Package__c;               
            }
            //Non Base Package Discount            
            discountOnOriginalDQ = DealQualificationApprovalUtil.getDiscountSize(dq.New_Pricing_Discount__c);
            discountOnHistoryDQ = DealQualificationApprovalUtil.getDiscountSize(dqHistory.New_Pricing_Discount__c);
            if(discountOnOriginalDQ > discountOnHistoryDQ){
                dqHistory.New_Pricing_Discount__c = dq.New_Pricing_Discount__c;               
            }
            //Annual Price Escalator
            if(dqHistory.Price_Escalation__c != 'Other'){
                dqHistory.Price_Escalation__c = dq.Price_Escalation__c;
            }
            //Overage Allowance
            if(dqHistory.Overage_Allowance__c != 'Other'){
                dqHistory.Overage_Allowance__c = dq.Overage_Allowance__c;
            }
            //Smart Use Case
            if(!dqHistory.Smart_Use_Case__c){
                dqHistory.Smart_Use_Case__c = dq.Smart_Use_Case__c;
            }
            //Subscription Smart Qualified Approval
            if(!dqHistory.Subscription_Smart_Qualified_Approval__c){
                dqHistory.Subscription_Smart_Qualified_Approval__c = dq.Subscription_Smart_Qualified_Approval__c;
            }
            //Deal Score
            //if(DealQualificationApprovalUtil.getDealSize(dq.Deal_Score_Size__c) > DealQualificationApprovalUtil.getDealSize(dqHistory.Deal_Score_Size__c)){
            dqHistory.Deal_Score_Size__c = dq.Deal_Score_Size__c;
            dqHistory.Net_Deal_Size_Amount__c = dq.Net_Deal_Size_Amount__c;
            //}
            //Payment Term
            if(dq.Payment_Terms__c != null){
                Integer daPaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(dq.Payment_Terms__c);
                Integer dqHistoryPaymentTerm = 0;
                if(dqHistory.Payment_Terms__c != null)
                    dqHistoryPaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(dqHistory.Payment_Terms__c);
                //Annual Price Escalator
                if(dqHistoryPaymentTerm < daPaymentTerm){
                    dqHistory.Payment_Terms__c = dq.Payment_Terms__c;
                }
             }    
          }
          
          dqHistory.Net_Deal_Size_Amount__c = dq.Net_Deal_Size_Amount__c;
          
          update dqHistory;
      }
      
      List<Deal_Qualification_Products__c> dqProducts = DealQualificationApprovalUtil.getDQProducts(dqId);
      List<Deal_Qualification_Products__c> dqHistoryProducts = DealQualificationApprovalUtil.getDQProducts(dqHistory.id);
      Map<Id, Deal_Qualification_Products__c> mapProductIdVsDQProduct = new Map<Id, Deal_Qualification_Products__c>();
      for(Deal_Qualification_Products__c eachDQProduct : dqHistoryProducts){
        mapProductIdVsDQProduct.put(eachDQProduct.Product__c, eachDQProduct);  
      }
      List<Deal_Qualification_Products__c> newDQProducts = new List<Deal_Qualification_Products__c> ();      
      for(Deal_Qualification_Products__c eachDQProduct : dqProducts){
        if(mapProductIdVsDQProduct.get(eachDQProduct.Product__c) == null){
          Deal_Qualification_Products__c newDQProduct = eachDQProduct.clone(false, true, false, false);
          newDQProduct.Deal_Qualification__c = dqHistory.id;
          newDQProducts.add(newDQProduct);
        }
        else{
          Deal_Qualification_Products__c existingDQProduct = mapProductIdVsDQProduct.get(eachDQProduct.Product__c);
          if(eachDQProduct.Discount__c > existingDQProduct.Discount__c){
            existingDQProduct.Discount__c = eachDQProduct.Discount__c; 
            newDQProducts.add(existingDQProduct);
          }
        }
      }
      if(!newDQProducts.isEmpty())
        upsert newDQProducts;
    } 
    
    public static List<Quote_Approval__c> getNextApprovalRecords(Deal_Qualification__c dq, Integer stepNo){
    	Deal_Qualification__c dqHistory = getDQHistoryRecord(dq);
        //Getting approval submission order
        Decimal submissionCounter = DealQualificationApprovalUtil.getApprovalSubmission(dq.id, stepNo);
        Set<Id> quoteApprovalConfigIds = new Set<Id>();
        //Will contain ids of already approved records for current step
        Set<Id> setAlreadyApprovedStepDetailsIds = new Set<Id>();
        System.debug('NKC debug submissionCounter ['+submissionCounter+']');
        //Querying records from junction object between quote approval config and approver
        List<Quote_Approval_Step_Details__c> quoteApprovers;
        //Populating all the steps into quote approval object.  
        if(stepNo == 0){
            //List<Quote_Approval__c> quoteApprovers1 = DealQualificationAppAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicable(dq, submissionCounter, false);
            //if(quoteApprovers1 != null)
            //    return quoteApprovers1;
            Set<Id> stepIds = new Set<Id>();
            //Getting quote approvals steps
            Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = DealQualificationApprovalUtil.getQuoteApprvalConfigRecords(dq, stepIds);
            //Getting quote approval records
            quoteApprovers = DealQualificationApprovalUtil.getQuoteApprovalRecords(stepIds, dq);                 
            //Filters quote approval records for current quote
            mapIdVsQuoteApprovalSteps = DealQualificationAppAssignmentHelper.filterQuoteApprovals(dq, dqHistory, quoteApprovers, mapIdVsQuoteApprovalSteps);
            System.debug('NKC debug quoteApprovers [' + quoteApprovers + ']');
            //if there is no qualifying approver, approve record automatically
            if(quoteApprovers.isEmpty())
                return null;
            //If don't resubmit to approved approvers is checked            
            if((dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_REJECTED
                && dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_REVISION_PENDING) 
                //|| dq.Don_t_Resubmit_to_Approved_Approvers__c
                )
                
                setAlreadyApprovedStepDetailsIds = DealQualificationAppAssignmentHelper.getAlreadyApprovedRecords(dq, submissionCounter);
            //System.debug('NKC debug quoteApproverDetails ['+quoteApprovers+']');
            
            //Get quote approval steps
            List<Quote_Approval__c> quoteApprovalsToBeInserted = new List<Quote_Approval__c>();     
            //Would store first order no
            Decimal firstOrderNo = 0;           
            //Would store unique approvers and their approval record (it will help to populate reason)
            Map<String, Quote_Approval__c> mapApproverIdApproval = new Map<String, Quote_Approval__c>();
            Boolean isOwnerPartner = [SELECT IsPortalEnabled FROM User WHERE id =: dq.OwnerId].IsPortalEnabled;
            for(Quote_Approval_Step_Details__c eachRecord : quoteApprovers){
                //If record is already approve, don't submit it again.
                if(setAlreadyApprovedStepDetailsIds.contains(eachRecord.id))
                    continue;
                if(!isOwnerPartner && eachRecord.Quote_Approval_Step__r.Partner_Only_Step__c)
                    continue;
                String stepAndApprover = eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId + eachRecord.Quote_Approval_Step__r.Name;
                //Skip current record if it's approver is already on the list.
                if(mapApproverIdApproval.containsKey(stepAndApprover)){
                    continue;
                }
                if(firstOrderNo == 0)
                    firstOrderNo = eachRecord.Quote_Approval_Step__r.Order__c;
                //New quote approvals record
                Quote_Approval__c newQuoteApproval = new Quote_Approval__c();
                List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps = mapIdVsQuoteApprovalSteps.get(eachRecord.Quote_Approval_Step__c);    
                //Populating quote approval reason  
                String approvalReason = DealQualificationAppAssignmentHelper.populateReasonToCurrentApprovalRecord(dq, eachRecord, quoteApprovalConfigAndSteps, newQuoteApproval.Reason_Name__c);
                newQuoteApproval.Reason_Name__c = approvalReason;               
                //Removes extra comma at the end
                if(newQuoteApproval.Reason_Name__c.lastIndexOf(',') != -1)
                    newQuoteApproval.Reason_Name__c = newQuoteApproval.Reason_Name__c.substring(0, newQuoteApproval.Reason_Name__c.lastIndexOf(','));
                newQuoteApproval.Deal_Qualification__c = dq.id;
                newQuoteApproval.Submitted_Date__c = System.now();
                newQuoteApproval.Quote_Approval_Step_Details__c = eachRecord.id;
                //Populating Step No
                newQuoteApproval.Step__c = eachRecord.Quote_Approval_Step__r.Order__c;
                //Approver
                newQuoteApproval.ownerId = eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId;
                newQuoteApproval.Notification_Email__c = eachRecord.Quote_Approver_Step_Approver_Detail__r.Email__c;
                //Update Pending status for only next step
                if(firstOrderNo == eachRecord.Quote_Approval_Step__r.Order__c)
                    newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_PENDING;
                else
                    newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_INACTIVE;
                if(DealQualificationApprovalUtil.isNotificationOnly(eachRecord.Quote_Approver_Step_Approver_Detail__r.Action_Text__c)
                  || eachRecord.Quote_Approval_Step__r.Notification_Only__c){
                    newQuoteApproval.Status__c = DealQualificationApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY;
                    newQuoteApproval.Comments__c = 'No Approval Required.';
                }
                newQuoteApproval.Product_Ids__c = eachRecord.Quote_Approver_Step_Approver_Detail__r.Product_Ids__c;
                newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
                newQuoteApproval.Product_Manager_Approval_Group__c = eachRecord.Quote_Approver_Step_Approver_Detail__r.PM_Group_Id__c;
                if(isOwnerPartner && eachRecord.Quote_Approval_Step__r.Partner_Only_Step__c){
                    newQuoteApproval.ownerId = dq.Opportunity__r.OwnerId;
                    newQuoteApproval.Reason_Name__c = 'Partner DQ';
                    newQuoteApproval.Partner_Only_Approval__c = true;
                }             
                mapApproverIdApproval.put(stepAndApprover, newQuoteApproval);
                quoteApprovalsToBeInserted.add(newQuoteApproval);   
            }
            //return approval steps to quote approval object
            return quoteApprovalsToBeInserted;          
        }
        //Next step
        else{
            //Getting next step items (if any)
            List<Quote_Approval__c> nextStepApprovals = [SELECT Status__c FROM Quote_Approval__c WHERE 
                Deal_Qualification__c =: dq.id AND Step__c =: stepNo AND Status__c =: DealQualificationApprovalUtil.STATUS_INACTIVE
                AND Approval_Submission_Counter__c =: submissionCounter];
            //If there is any pending approval items
            if(!nextStepApprovals.isEmpty()){
                for(Quote_Approval__c eachQA : nextStepApprovals){
                    /* Naresh Kumar 09/21/2017 Disabling auto approvals.
                    if(stepNo == 4 && dq.Compliance_of_the_Request_with_Value_Pri__c == 'Green = Value Pricing Compliant'){
                        eachQA.Status__c = DealQualificationApprovalUtil.STATUS_APPROVED;
                        eachQA.Trigger_Email_Alert__c = 'Auto Approved - Green = Value Pricing Compliant';
                    }
                    else
                    */
                    eachQA.Status__c = DealQualificationApprovalUtil.STATUS_PENDING;
                    eachQA.Submitted_Date__c = System.now();
                }
                update nextStepApprovals;
            }
            else if([Select count() FROM Quote_Approval__c WHERE 
                Deal_Qualification__c =: dq.id AND Status__c =: DealQualificationApprovalUtil.STATUS_INACTIVE
                AND Approval_Submission_Counter__c =: submissionCounter] > 0)
            {
                system.debug('Inside new else condition');
                getNextApprovalRecords(dq, stepNo + 1);
            }
            return null;
        }
        return null;        
    }
}