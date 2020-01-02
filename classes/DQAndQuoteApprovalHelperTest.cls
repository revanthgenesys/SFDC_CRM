@isTest(seeAllData=true)
private class DQAndQuoteApprovalHelperTest{ 
    static testMethod void testDealQualificationAndQuoteApprovalHelper() { 
        
        Deal_Qualification__c dq = [Select id,Term_Increase__c,Premium_Care__c,ELA__c,Term_Decrease__c,Net_Deal_Value__c,GC_Override__c,New_Pricing_Discount__c,Opportunity__c,Platform_Type__c,Offering_Type__c from Deal_Qualification__c limit 1];
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c,Quote_Business_Type__c,Offering_Type__c from BigMachines__Quote__c where BigMachines__Status__c = 'Quote Approved' and Offering_Type__c = 'Business Edition' and BigMachines__Line_Items__c > 0 limit 1];
        
        DealQualificationAndQuoteApprovalHelper dqHelper = new DealQualificationAndQuoteApprovalHelper();
        List<DealQualificationAndQuoteApprovalHelper.wrapperViolationSummary> violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.id);
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        DealQualificationAndQuoteApprovalHelper.resetApprovalsIfNeeded(dq,'New Pricing');
        //DealQualificationAndQuoteApprovalHelper.insertNotificationResetInfo(dq.id,'test');
        DealQualificationAndQuoteApprovalHelper.resetELAApproval(quote);
        DealQualificationAndQuoteApprovalHelper.getOverrideScore('test');
        DealQualificationAndQuoteApprovalHelper.sendPMApprovalNotifications(quote.id);
        
        quote.Include_Special_Offer_in_Output__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);
    }
    
    static testMethod void testDealQualificationAndQuoteApprovalHelper2() { 
        Deal_Qualification__c dq = [Select id,Term_Increase__c,Premium_Care__c,ELA__c,Term_Decrease__c,Net_Deal_Value__c,GC_Override__c,New_Pricing_Discount__c,Opportunity__c,Platform_Type__c,Offering_Type__c from Deal_Qualification__c limit 1];
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c,Quote_Business_Type__c,Offering_Type__c  from BigMachines__Quote__c where BigMachines__Status__c = 'Quote Approved' and Offering_Type__c = :QuoteUtil.OFFERING_TYPE_CAAS and BigMachines__Line_Items__c > 0  limit 1];
        
        DealQualificationAndQuoteApprovalHelper dqHelper = new DealQualificationAndQuoteApprovalHelper();
        List<DealQualificationAndQuoteApprovalHelper.wrapperViolationSummary> violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.id);
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c);
        DealQualificationAndQuoteApprovalHelper.resetApprovalsIfNeeded(dq,'New Pricing');
        //DealQualificationAndQuoteApprovalHelper.insertNotificationResetInfo(dq.id,'test');
        DealQualificationAndQuoteApprovalHelper.resetELAApproval(quote);
        
        quote.Include_Special_Offer_in_Output__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);
        quote.Editable_List_Price_Approval_Required__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);
    }
    
    static testMethod void testDealQualificationAndQuoteApprovalHelper3() { 
        
        Deal_Qualification__c dq = [Select id,Term_Increase__c,Premium_Care__c,ELA__c,Term_Decrease__c,Net_Deal_Value__c,GC_Override__c,New_Pricing_Discount__c,Opportunity__c,Platform_Type__c,Offering_Type__c from Deal_Qualification__c where Type__c = 'History' limit 1];
        dq = [Select id,Opportunity__c,Platform_Type__c,Term_Increase__c,ELA__c,Premium_Care__c,Term_Decrease__c,Net_Deal_Value__c,GC_Override__c,New_Pricing_Discount__c,Offering_Type__c from Deal_Qualification__c where Type__c = 'Original' and Opportunity__c = :dq.Opportunity__c and Platform_Type__c =:dq.Platform_Type__c and Offering_Type__c = :dq.Offering_Type__c  limit 1];
        
        BigMachines__Quote_Product__c qProduct = [Select id,BigMachines__Quote__c from BigMachines__Quote_Product__c where BigMachines__Product__r.Product_Specific_Discount__c != null and Total_Discount__c > 50 and BigMachines__Quote__r.BigMachines__Status__c = 'Quote Approved' and BigMachines__Quote__r.Offering_Type__c != 'Business Edition' and BigMachines__Quote__r.Offering_Type__c != :QuoteUtil.OFFERING_TYPE_CAAS and BigMachines__Product__r.Type__c != :QuoteApprovalUtil.PRODUCT_TYPE_PRODUCT_SYSTEM_LICENSE and BigMachines__Product__r.Type__c != :QuoteApprovalUtil.PRODUCT_TYPE_GU limit 1];
        BigMachines__Quote__c quote = [Select id,BigMachines__Opportunity__c,Quote_Business_Type__c,Offering_Type__c  from BigMachines__Quote__c where id = :qProduct.BigMachines__Quote__c  limit 1];
        
        DealQualificationAndQuoteApprovalHelper dqHelper = new DealQualificationAndQuoteApprovalHelper();
        List<DealQualificationAndQuoteApprovalHelper.wrapperViolationSummary> violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        DealQualificationAndQuoteApprovalHelper.insertUpdateViolations(quote.id);
        DealQualificationAndQuoteApprovalHelper.synchDQ(quote.id,quote.BigMachines__Opportunity__c); 
        DealQualificationAndQuoteApprovalHelper.resetApprovalsIfNeeded(dq,'New Pricing');
        //DealQualificationAndQuoteApprovalHelper.insertNotificationResetInfo(dq.id,'test');
        DealQualificationAndQuoteApprovalHelper.resetELAApproval(quote);
        
        Order_Line_Item__c oLine = [Select id,Order__c from Order_Line_Item__c limit 1];
        DealQualificationAndQuoteApprovalHelper.sendNROPMApprovalNotifications(oLine.Order__c);
        
        quote.ELA__c = True;
        violations = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.Include_Special_Offer_in_Output__c = True;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        //quote.Service_Level__c = 'test';
        //update quote;
        //violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        //quote.GC_Decline__c = True;
        //violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        
        quote.CAD_Override__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.Additional_Legal_Terms__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.X3rd_Party_Override__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.No_Of_Months__c = 0;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        Test.startTest();
        quote.Pricing_Model__c = 'PPU';
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.Finance_Exceptions__c = 'MRR less than 2K USD';
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.Legal_Exceptions__c = 'Extended Warranty';
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        quote.Carveout__c = True;
        update quote;
        violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        Test.stopTest();
        //quote.Editable_List_Price_Approval_Required__c = True;
        //update quote;
        //violations  = DealQualificationAndQuoteApprovalHelper.validateQuoteApproval(quote.id);        
        
    }
    
}