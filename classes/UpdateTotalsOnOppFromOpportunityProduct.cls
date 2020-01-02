public with sharing class UpdateTotalsOnOppFromOpportunityProduct {
    
    public static void updateTotalsOnOpp(Map<Id, OpportunityLineItem> newMap){
      if(CloudQuoteUtil.DO_NOT_CALL_OPP_PRODUCT_TOTAL_LOGIC)
        return;
        Set<String> productType = new Set<String>();        
        Set<Id> oppIds = new Set<Id>();     
        for(OpportunityLineItem eachLineItem : newMap.values()){
            oppIds.add(eachLineItem.OpportunityId);
        } 
        if(oppIds.isEmpty())
            return;
        newMap = new Map<Id, OpportunityLineItem>();
        Double productHardwareTotal = 0;
        List<OpportunityLineItem> oppLineItems = [SELECT OpportunityId, TotalPrice, Product_Name_Formula__c, Quantity,  
          PricebookEntry.Product2.Product_Category__c, PricebookEntry.Product2.Type__c FROM OpportunityLineItem WHERE OpportunityId IN : oppIds];
        List<OpportunityLineItem> oppLineItemsClouds = new List<OpportunityLineItem>();
        for(OpportunityLineItem eachLineItem : oppLineItems){
          productType.add(eachLineItem.PricebookEntry.Product2.Type__c);
                                
         // MS -07/20/15
         // if(eachLineItem.PricebookEntry.Product2.Type__c == 'Cloud')
          if( eachLineItem.PricebookEntry.Product2.Type__c != null && eachLineItem.PricebookEntry.Product2.Type__c.contains('Cloud') )
            oppLineItemsClouds.add(eachLineItem);     
          if(eachLineItem.PricebookEntry.Product2.Type__c == 'Product - Hardware')
            productHardwareTotal += eachLineItem.TotalPrice;     
        }
        List<BigMachines__Quote__c> quotes = [SELECT BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN : oppIds];
        Set<Id> oppIdsHavingQuote = new Set<Id>();
        for(BigMachines__Quote__c eachQuote : quotes)
            oppIdsHavingQuote.add(eachQuote.BigMachines__Opportunity__c);
            
        List<Opportunity> opps = [SELECT Total_PS_Support__c, Annual_Contract_Value_new__c, Total_Annual_Contract_Value__c, Monthly_Commitment__c,
                                 Annual_Contract_Value_Subscription__c, Term_Commitment__c, Estimated_Usage_Agreements_EUA__c,Sold_To_Country__r.RU__c,Quote_Category__c
                                  FROM Opportunity WHERE id IN : oppIds];
        
        Map<Id, Opportunity> oppIdVsOpp = new Map<Id, Opportunity>();
        for(Opportunity eachOpp : opps)
            oppIdVsOpp.put(eachOpp.id, eachOpp);

        Map<Id, Double> mapOppIdVsPSTotal = new Map<Id, Double>();
        Map<Id, Double> mapOppIdVsOtherTotal = new Map<Id, Double>();           
        //Map<Id,String> offeringTypeMap = new Map<Id,String>();
        
        Map<Id, Double> mapOppLitemCloudPPUTotal = new Map<Id, Double>();
        
        for(OpportunityLineItem  eachLineItem : oppLineItemsClouds)
        {
            if(oppIdsHavingQuote.contains(eachLineItem.OpportunityId) && 
               !(oppIdVsOpp.get(eachLineItem.OpportunityId).Sold_To_Country__r.RU__c == 'ANZ' && oppIdVsOpp.get(eachLineItem.OpportunityId).Quote_Category__c == 'Cloud'))
                continue;
            Double amount = (eachLineItem.TotalPrice * eachLineItem.Quantity);
            if(eachLineItem.Product_Name_Formula__c == 'Professional Services - Cloud'){              
                if(mapOppIdVsPSTotal.get(eachLineItem.OpportunityId) == null)
                    mapOppIdVsPSTotal.put(eachLineItem.OpportunityId, amount);
                else{
                    Double total = mapOppIdVsPSTotal.get(eachLineItem.OpportunityId);
                    total += amount;
                    mapOppIdVsPSTotal.put(eachLineItem.OpportunityId, total);
                }
            }
            else if ( eachLineItem.PricebookEntry.Product2.Type__c == 'Cloud PPU' ) {
                if(mapOppLitemCloudPPUTotal.get(eachLineItem.OpportunityId) == null)
                    mapOppLitemCloudPPUTotal.put(eachLineItem.OpportunityId, amount);
                else{
                    Double total = mapOppLitemCloudPPUTotal.get(eachLineItem.OpportunityId);
                    total += amount;
                    mapOppLitemCloudPPUTotal.put(eachLineItem.OpportunityId, total);
                }
            }                        
            else{
                if(mapOppIdVsOtherTotal.get(eachLineItem.OpportunityId) == null)
                    mapOppIdVsOtherTotal.put(eachLineItem.OpportunityId, amount);
                else{
                    Double total = mapOppIdVsOtherTotal.get(eachLineItem.OpportunityId);
                    total += amount;
                    mapOppIdVsOtherTotal.put(eachLineItem.OpportunityId, total);
                }
            }
			// [Sourav 6/21/2017] : Remove automation to update Offering Type on Opportunity based on Opportunity Product
			/*
            if(eachLineItem.PricebookEntry.Product2.Product_Category__c != null && offeringTypeMap.get(eachLineItem.opportunityId) == null){
              offeringTypeMap.put(eachLineItem.OpportunityId,eachLineItem.PricebookEntry.Product2.Product_Category__c);
            }*/            
        }
        System.debug('NKC debug mapOppIdVsPSTotal ['+mapOppIdVsPSTotal+']');
        System.debug('NKC debug mapOppIdVsOtherTotal ['+mapOppIdVsOtherTotal+']');
        
        String plateformType = '';
        if(productType.contains('Cloud'))
          plateformType = 'Cloud';        
        if(productType.size() > 1 && (!productType.contains('Cloud') && productType.size() == 1)){
          plateformType += ';On Premise';
        }
        
        System.debug('NKC debug plateformType ['+plateformType+']');
        for(Opportunity eachOpp : opps)
        {
            Double PSTotal = mapOppIdVsPSTotal.get(eachOpp.id);
            Double otherTotal = mapOppIdVsOtherTotal.get(eachOpp.id);
            Double estimTotal = mapOppLitemCloudPPUTotal.get(eachOpp.id);
            if(otherTotal == null)
                otherTotal = 0;
            if(PSTotal == null)
                PSTotal = 0;
            if ( estimTotal == null )
                 estimTotal = 0;
                
            Integer term = 1;
            // Reads the number of years of subscription term 
            if(String.isNotBlank(eachOpp.Term_Commitment__c) && eachOpp.Term_Commitment__c.containsIgnoreCase(' Year'))
                term = Integer.ValueOf(eachOpp.Term_Commitment__c.substringBefore(' Year'));
                
            if(PSTotal == null)
              PSTotal = 0;
            if(eachOpp.Total_Annual_Contract_Value__c == null)
              eachOpp.Total_Annual_Contract_Value__c = 0;
            if(eachOpp.Annual_Contract_Value_new__c == null)
              eachOpp.Annual_Contract_Value_new__c = 0;
            //Bookings
            eachOpp.Annual_Contract_Value_new__c = otherTotal + PSTotal;
            //Total Contract Value (TCV)
            eachOpp.Total_Annual_Contract_Value__c = ( (otherTotal + estimTotal) * term ) + PSTotal;
            //TCV – Subscriptions Only
            eachOpp.Annual_Contract_Value_Subscription__c = eachOpp.Total_Annual_Contract_Value__c - PSTotal;          
            //EUA
            eachOpp.Estimated_Usage_Agreements_EUA__c = estimTotal > PSTotal ? (estimTotal - PSTotal) : 0;
            // ACV
            eachOpp.ACV_Subscription_Only__c = eachOpp.Annual_Contract_Value_new__c - PSTotal;                      
            //eachOpp.Primary_Line_of_Business__c = plateformType;
            
            eachOpp.Monthly_Commitment__c = eachOpp.ACV_Subscription_Only__c / 12;              

            eachOpp.Total_PS_Support__c = PSTotal; 
            if(eachOpp.Annual_Contract_Value_new__c != 0 && eachOpp.Total_Annual_Contract_Value__c != 0)
            	eachOpp.License_Amount__c = 0;
            // [Sourav 6/21/2017] : Remove automation to update Offering Type on Opportunity based on Opportunity Product
            /*if(offeringTypeMap.get(eachOpp.id) != null)            {
              eachOpp.Lines_of_Businesses__c = offeringTypeMap.get(eachOpp.id);
            }*/
            
            eachOpp.Hardware_Total__c = productHardwareTotal;
        }
        update opps;
    }
}