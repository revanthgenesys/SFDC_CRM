global without sharing class ZuoraQuoteUtility {
    
    // Instance variable
    private static ZuoraQuoteUtility instance = null;
    // Error Strings
    private static final String ERROR_NO_QUOTE = 'The quote you are attempting to change is invalid.  Please try again, or contact support for assistance.';
    private static final String ERROR_NO_OPP = 'The quote you are attempting to set as the primary is not associated with an opportunity.  Please assign an opportunity to the quote';
    private static final String ERROR_QUOTE_NOT_PRIMARY = 'The quote you are attempting to sync is not the primary quote for this opportunity.  You may only sync the primary quote to the Opportunity.';
    private static final String ERROR_MORE_THAN_ONE_PRIMARY = 'There is more than one primary quote for this opportunity.  Please select a quote and set it as the primary, then retry this operation.';
    private static final String INFO_ALREADY_PRIMARY = 'The quote you selected is already the Primary for this Opportunity.';
    private static final String SUCCESS_QUOTE_UPDATES = 'The Quote was successfully marked as the Primary for this Opportunity.';
    private static final String SUCCESS_OPP_UPDATES = 'The Opportunity was successfully updated with information from the Primary Quote.';
    // Opportunity ID passed to the controller
    public Id oppId { get; set; }
    
    // List of all Zuora quotes on the opportunity
    public Map<Id, zqu__Quote__c> zQuotes
    {
        get
        {
            if(zQuotes == null)
            {
                zQuotes = new Map<Id, zqu__Quote__c>([SELECT Id, Name, zqu__Primary__c, Annual_PrePay__c, zqu__InitialTerm__c,
                                                        zqu__Previewed_MRR__c, MSA_Link__c, zqu__Opportunity__c, zqu__Previewed_TCV__c,
                                                        zqu__Previewed_Total__c, zqu__Currency__c, zqu__InitialTermPeriodType__c
                                                        FROM zqu__Quote__c WHERE zqu__Opportunity__c = :this.oppId]);
            }
            return zQuotes;
        }
        private set;
    }
    // List of all Big Machines quotes on the opportunity
    public Map<Id, BigMachines__Quote__c> bQuotes
    {
        get
        {
            if(bQuotes == null)
            {
                bQuotes = new Map<Id, BigMachines__Quote__c>([SELECT Id, Name, BigMachines__Is_Primary__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :this.oppId]);
            }
            return bQuotes;
        }
        private set;
    }
    // Quote selected by user to be the primary quote   
    public Id primaryQuoteId { get; set; }
    // Set to store all current Primary Quotes
    public Set<Id> currentPrimaryQuotes { get; set; }   
    
    // Private constructor 
    private ZuoraQuoteUtility(Id oppId) {
        
        this.oppId = oppId;
        populateQuoteList();    
    }

    // Lazy Load for singleton instance 
    public static ZuoraQuoteUtility getInstance(Id oppId)
    {
        if(instance == null) instance = new ZuoraQuoteUtility(oppId);
        return instance;
    }

    private void populateQuoteList()
    {       
        this.currentPrimaryQuotes = new Set<Id>();
        
        // Populate Quote list for Zuora Quotes
        if(!zQuotes.values().isEmpty())
        {
            for(zqu__Quote__c zQuote : zQuotes.values())
            {
                if(zQuote.zqu__Primary__c) this.currentPrimaryQuotes.add(zQuote.Id);
            }
        }

        // Populate Quote list for BigMachines Quotes
        if(!bQuotes.values().isEmpty())
        {
            for(BigMachines__Quote__c bQuote : bQuotes.values())
            {
                if(bQuote.BigMachines__Is_Primary__c) this.currentPrimaryQuotes.add(bQuote.Id);
            }
        }
    }

    public String setPrimaryQuote()
    {
        if(this.currentPrimaryQuotes.contains(this.primaryQuoteId) && this.currentPrimaryQuotes.size() == 1)
        {           
            return INFO_ALREADY_PRIMARY;
        }
        else
        {
            return updateQuotes();
        }
    }

    // Method to update Quotes
    private String updateQuotes()
    {
        List<sObject> objToUpdate = new List<sObject>();
        
        // Mark the current primary quote
        if(this.zQuotes.containsKey(this.primaryQuoteId))
        {
            zqu__Quote__c z = this.zQuotes.get(this.primaryQuoteId);
            z.zqu__Primary__c = true;
            objToUpdate.add(z);
        }
        else if(this.bQuotes.containsKey(this.primaryQuoteId))
        {
            BigMachines__Quote__c b = this.bQuotes.get(this.primaryQuoteId);
            b.BigMachines__Is_Primary__c = true;
            objToUpdate.add(b);
        }

        // Uncheck previous primary quotes
        for(Id i : this.currentPrimaryQuotes)
        {
            if(i == this.primaryQuoteId) continue;

            if(this.zQuotes.containsKey(i))
            {
                zqu__Quote__c z = this.zQuotes.get(i);
                z.zqu__Primary__c = false;
                objToUpdate.add(z);
                //updateOppFields(z.zqu__Previewed_TCV__c);
                //objToUpdate.add(this.opp);
            }
            else if(this.bQuotes.containsKey(i))
            {
                BigMachines__Quote__c b = this.bQuotes.get(i);
                b.BigMachines__Is_Primary__c = false;
                objToUpdate.add(b);
            }
        }

        // DML Operation
        try
        {
            update objToUpdate;
            return SUCCESS_QUOTE_UPDATES;
        }
        catch(System.DmlException e)
        {
            String resultString = '';
            for(Integer i = 0; i < e.getNumDml(); i++)
            {
                resultString += e.getDmlMessage(i) + '\n';
            }
            return resultString;
        }
    }

    public String updateOpp()
    {
        String resultString = '';
        zqu__Quote__c zQuote = new zqu__Quote__c();
        // Delete existing lines before creating quote products as opportunity lines
        List<OpportunityLineItem> list_OpptyLinesToDelete = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :this.oppId];
        if(list_OpptyLinesToDelete.size() > 0)
        {
            // DML Operation
            try
            {
                delete list_OpptyLinesToDelete;
            }
            catch(System.DmlException e)
            {
                for(Integer i = 0; i < e.getNumDml(); i++)
                {
                    resultString += e.getDmlMessage(i) + '\n';
                }
                return resultString;
            }
        }

        if(zQuotes.containsKey(this.primaryQuoteId))
        {
            zQuote = zQuotes.get(this.primaryQuoteId);
        }
        else
        {
            return ERROR_NO_QUOTE;
        }
        
        Opportunity oppToUpdate = new Opportunity(Id = this.oppId);
        //oppToUpdate.Primary_Quote__c = quote.id;                
        //oppToUpdate.Hardware_Total__c = quote.Total_Hardware__c;
        //oppToUpdate.Education_Amount__c = quote.Total_Education__c;               
        //oppToUpdate.Annual_Contract_Value_new__c = (zquote.Annual_Prepay__c ? zquote.zqu__Previewed_TCV__c;
        //oppToUpdate.ACV_Subscription_Only__c = quote.Annual_Contract_Value__c;    
        //oppToUpdate.Annual_Contract_Value_Subscription__c = quote.Annual_Contract_Value__c;   
        oppToUpdate.Total_Annual_Contract_Value__c = zQuote.zqu__Previewed_TCV__c;                 
        oppToUpdate.Monthly_Commitment__c = zQuote.zqu__Previewed_MRR__c; 
        //oppToUpdate.Term_Commitment__c = zQuote.zqu__InitialTerm__c;                
        oppToUpdate.Frequency_Term__c = zQuote.zqu__InitialTermPeriodType__c;
        oppToUpdate.MSA_Url__c = zQuote.MSA_Link__c;
        oppToUpdate.Primary_Line_of_Business__c = 'Cloud';
        
        // DML Operation
        try
        {
            update oppToUpdate;
        }
        catch(System.DmlException e)
        {
            for(Integer i = 0; i < e.getNumDml(); i++)
            {
                resultString += e.getDmlMessage(i) + '\n';
            }
            return resultString;
        }

        List<zqu.zChargeGroup> zChargeGroups = new List<zqu.zChargeGroup>();
        // Get Quote Rate Plan Charge custom fields
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Product_Description__c',
                                                                        'Product_Category__c',
                                                                        'Partner_Price__c',
                                                                        'Document_Category__c',
                                                                        'Document_Subcategory__c'};
        zChargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id);

        Set<String> set_ProductIds = new Set<String>();
        for(zqu.zChargeGroup zChargeGroup : zChargeGroups)
        {
            set_ProductIds.add(zChargeGroup.productId);
        }

        Map<Id,Id> map_ProdIdToPBEId = new Map<Id,Id>();
        for(PricebookEntry objPE : [SELECT Product2Id,Id FROM PricebookEntry WHERE 
                                    Pricebook2Id = :Label.Standard_Pricebook_Id AND 
                                    Product2Id IN :set_ProductIds AND CurrencyISOCode = :zQuote.zqu__Currency__c])
        {
            map_ProdIdToPBEId.put(objPE.Product2Id,objPE.Id);
        }
        
        List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();
        for(zqu.zChargeGroup zChargeGroup : zChargeGroups)
        {
            if(!map_ProdIdToPBEId.containsKey(zChargeGroup.productId)) continue;

            for(zqu.zCharge zCharge : zChargeGroup.zCharges)
            {
                zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zCharge.chargeObject;
                if(charge.zqu__Quantity__c < 1) continue;
                list_OpptyLinesToCreate.add(new OpportunityLineItem(Description__c = charge.Name, OpportunityId = zQuote.zqu__Opportunity__c,
                                                                    PricebookEntryId = map_ProdIdToPBEId.get(zChargeGroup.productId),                                                                   
                                                                    Quantity = charge.zqu__Quantity__c, UnitPrice = charge.zqu__ListPrice__c,
                                                                    Total_Discount__c = charge.zqu__Discount__c, Unit_of_Measure__c = charge.zqu__UOM__c));
                
            }
        }
        
        if(list_OpptyLinesToCreate.size() > 0)
        {
            // DML Operation
            try
            {
                insert list_OpptyLinesToCreate;
            }
            catch(System.DmlException e)
            {
                for(Integer i = 0; i < e.getNumDml(); i++)
                {
                    resultString += e.getDmlMessage(i) + '\n';
                }
                return resultString;
            }           
        }

        return SUCCESS_OPP_UPDATES;
    }

    // Webservice method to set the primary qoute based on the user selection
    webservice static String setZuoraQuoteAsPrimary(Id quoteId)
    {
        zqu__Quote__c zQuote = [SELECT Id, zqu__Opportunity__c FROM zqu__Quote__c WHERE Id =:quoteId LIMIT 1];

        if(zQuote == null) return ERROR_NO_QUOTE;
        if(String.isBlank(zQuote.zqu__Opportunity__c)) return ERROR_NO_OPP;

        ZuoraQuoteUtility util = ZuoraQuoteUtility.getInstance(zQuote.zqu__Opportunity__c);
        util.primaryQuoteId = zQuote.Id;
        String quoteResult = util.setPrimaryQuote();

        if(!quoteResult.contains(ZuoraQuoteUtility.SUCCESS_QUOTE_UPDATES)) return quoteResult;

        String oppResult = util.updateOpp();

        if(!oppResult.contains(ZuoraQuoteUtility.SUCCESS_OPP_UPDATES)) return oppResult;

        return quoteResult + '\n' + oppResult;
    }

    // Webservice method set sync the quote to the opportunity based on the user selection
    webservice static String syncQuoteToOpportunity(Id quoteId)
    {
        zqu__Quote__c zQuote = [SELECT Id, zqu__Opportunity__c FROM zqu__Quote__c WHERE Id =:quoteId LIMIT 1];

        if(zQuote == null) return ERROR_NO_QUOTE;
        if(String.isBlank(zQuote.zqu__Opportunity__c)) return ERROR_NO_OPP;

        ZuoraQuoteUtility util = ZuoraQuoteUtility.getInstance(zQuote.zqu__Opportunity__c);     

        if(!util.currentPrimaryQuotes.contains(zQuote.Id))
        {
            return ERROR_QUOTE_NOT_PRIMARY;
        }
        else if(util.currentPrimaryQuotes.size() > 1 )
        {
            return ERROR_MORE_THAN_ONE_PRIMARY;
        }
        else
        {
            util.primaryQuoteId = zQuote.Id;
            return util.updateOpp();
        }       
    }
    
    webservice static void updateChargePartnerPricing(Id quoteId)
    {
        try
        {
            //zqu__Quote__c zQuote = (zqu__Quote__c)JSON.deserialize(zQuoteJson, zqu__Quote__c.class);
            zqu__Quote__c zQuote = [SELECT Id, zqu__Opportunity__r.BusinessPartner__c, zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c FROM zqu__Quote__c WHERE Id = :quoteId LIMIT 1];
            if(!zQuote.zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) return;
            
            List<PureCloud_Partner_Margin__c> partnerMargins = new List<PureCloud_Partner_Margin__c> ([SELECT Percent__c, Margin_Type__c
                                                                                                         FROM PureCloud_Partner_Margin__c
                                                                                                         WHERE From_Date__c <= TODAY AND To_Date__c >= TODAY AND Account__c = :zQuote.zqu__Opportunity__r.BusinessPartner__c
                                                                                                         ORDER BY To_Date__c ASC]);
            zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Product_Description__c',
                                                                            'Product_Category__c',
                                                                            'Partner_Price__c',
                                                                            'Document_Category__c',
                                                                            'Document_Subcategory__c'};
            List<zqu.zChargeGroup> zChargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id);
            
            List<zqu.zChargeGroup> groupsToUpdate = new List<zqu.zChargeGroup>();
            
            //Added By Ranjith on Aug 07, 2017 -- Starts
             Map<Id, zqu__QuoteRatePlanCharge__c> map_qtRtPlnChrgs = getQuoteRatePlanCharges(quoteId);
            //Added By Ranjith on Aug 07, 2017 -- Ends
            
            for(zqu.zChargeGroup zChargeGroup : zChargeGroups)
            {
                if(zChargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL || zChargeGroup.groupType == zqu.zChargeGroup.TYPE_CANCELLATION_ORIGINAL) continue;
                for(zqu.zCharge zCharge : zChargeGroup.zCharges)
                {
                    zCharge = setPartnerPricing(zCharge, partnerMargins, map_qtRtPlnChrgs);
                }
                groupsToUpdate.add(zChargeGroup);
            }
            zqu.zQuoteUtil.updateChargeGroups(groupsToUpdate);
        }
        catch(Exception e)
        {
            system.debug('Exception while updating charge groups: ' + e.getMessage());
        }
    }
    
    public static zqu.zCharge setPartnerPricing(zqu.zCharge zCharge, List<PureCloud_Partner_Margin__c> partnerMargins, Map<Id, zqu__QuoteRatePlanCharge__c> map_qtRtPlnChrgs)
    {
        Map<String, Decimal> marginMap = new Map<String, Decimal>();
        if (partnerMargins.size() > 0)
        {
            for (PureCloud_Partner_Margin__c partnerMargin : partnerMargins)
            {
                if (!marginMap.containsKey(partnerMargin.Margin_Type__c))
                {
                    marginMap.put(partnerMargin.Margin_Type__c, partnerMargin.Percent__c);
                }
            }
        }
        
        zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zCharge.chargeObject;
        
        Decimal effectivePrice = charge.zqu__EffectivePrice__c != null ? charge.zqu__EffectivePrice__c  : 0;
        Decimal partnerMargin = 0;
        
        //Added By Ranjith on Aug 07, 2017 -- Starts
        if(!map_qtRtPlnChrgs.containsKey(charge.Id) || String.isBlank(charge.Document_Subcategory__c)) return zCharge;
        
        zqu__QuoteRatePlanCharge__c qtRtPlnChrge = map_qtRtPlnChrgs.get(charge.Id);
        
        partnerMargin = marginMap.containsKey(qtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c) ? 
                                marginMap.get(qtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c) : 0;
        //Added By Ranjith on Aug 07, 2017 -- Ends 
        
        //Commented By Ranjith on Aug 07, 2017 -- Starts
        /*
        system.debug('!!Margin Map: ' + marginMap);
        string pcKey = 'PureCloud';
        string pcVoiceKey = 'PureCloud Voice';
        if(String.isBlank(charge.Product_Category__c) || String.isBlank(charge.Document_Subcategory__c)) return zCharge;

        system.debug('!! Charge category ' + charge.Product_Category__c);
        // PureCloud Licenses
        if (charge.Product_Category__c == 'Licenses')
        {
            partnerMargin = marginMap.containsKey(pcKey) == true ? marginMap.get(pcKey) : 0;
        }
        // PureCloud Voice
        else if (charge.Document_Subcategory__c == 'PureCloud Voice' && charge.Product_Category__c == 'Voice Services')
        {
            partnerMargin = marginMap.containsKey(pcVoiceKey) == true ? marginMap.get(pcVoiceKey) : 0;
        }
        */
        //Commented By Ranjith on Aug 07, 2017 -- Ends
        
        system.debug('!! Margin: ' + partnerMargin);
        //charge.Partner_Price__c = (effectivePrice - (effectivePrice * partnerMargin/100)).setScale(2, RoundingMode.HALF_UP);
        charge.Partner_Price__c = (effectivePrice - (effectivePrice * partnerMargin/100));
        
        if(charge.zqu__Quantity__c != null) 
        {
            charge.zqu__Total__c = (charge.zqu__ChargeType__c == 'Recurring' && charge.zqu__Period__c == 'Annual' ? (charge.Partner_Price__c / 12).setScale(2, RoundingMode.HALF_UP) * charge.zqu__Quantity__c * 12 : charge.Partner_Price__c * charge.zqu__Quantity__c);
        }
        
        return zCharge;
    }

    //Added By Ranjith on Aug 07, 2017 -- Starts            
    public static Map<Id, zqu__QuoteRatePlanCharge__c> getQuoteRatePlanCharges(Id quoteId)
    {              
        return new Map<Id, zqu__QuoteRatePlanCharge__c>(
                    [SELECT Id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c 
                     FROM zqu__QuoteRatePlanCharge__c
                     WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: quoteId]);       
    }
    //Added By Ranjith on Aug 07, 2017 -- Ends
}