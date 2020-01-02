// Controller class for PureCloudDocument Page
public with sharing class PureCloudDocumentController {

    //Zuora Quote object
    private final zqu__Quote__c zQuote;
    // Boolean for determining if quote is Multi-year term
    public Boolean isMultiYearTerm { get; set; }    
    // Charge Groups Associated with Quote
    
    Map<Id, zqu__QuoteRatePlanCharge__c> map_qtRtPlnChrgs = new Map<Id, zqu__QuoteRatePlanCharge__c>();
    public List<zqu.zChargeGroup> zChargeGroups
    {
        get
        {
            if(zChargeGroups == null)
            {
                zChargeGroups = new List<zqu.zChargeGroup>();
                // Get Quote Rate Plan Charge custom fields
                zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Product_Description__c',
                                                                                'Product_Category__c',
                                                                                'Partner_Price__c',
                                                                                'Document_Category__c',
                                                                                'Document_Subcategory__c'};
                zChargeGroups = zqu.zQuoteUtil.getChargeGroups(this.zQuote.Id);
            }
            return zChargeGroups;
        }
        set;
    }
    // Charge Group Categories
    public List<zqu.zCharge> originalCharges
    {
        get
        {
            if(originalCharges == null)
            {
                originalCharges = new List<zqu.zCharge>();
            }
            return originalCharges;
        }
        set;
    }
    
    public List<zqu.zCharge> newCharges
    {
        get
        {
            if(newCharges == null)
            {
                newCharges = new List<zqu.zCharge>();
            }
            return newCharges;
        }
        set;
    }

    public List<zqu.zCharge> removedCharges
    {
        get
        {
            if(removedCharges == null)
            {
                removedCharges = new List<zqu.zCharge>();
            }
            return removedCharges;
        }
        set;
    }

    public List<zqu.zCharge> discountCharges
    {
        get
        {
            if(discountCharges == null)
            {
                discountCharges = new List<zqu.zCharge>();
            }
            return discountCharges;
        }
        set;
    }

    // Mapping of Charge Category and Subcatgory
    public Map<String, Map<String, List<zqu.zCharge>>> chargeCatSubCatMap { get; set; }
    // Mapping of Product Rate Plan Id to Orginal zCharge
    // Used to get original information from a modified charge in order to display the delta
    public Map<Id, zqu.zCharge> originalChargeMap 
    { 
        get
        {
            if(originalChargeMap == null)
            {
                originalChargeMap = new Map<Id, zqu.zCharge>();
            }
            return originalChargeMap;
        } 
        set;
    }
    // Totals for each Sub-Category
    public Map<String, Decimal> subCatTotal 
    { 
        get
        {
            if(subCatTotal == null)
            {
                subCatTotal = new Map<String, Decimal>();
            }
            return subCatTotal;
        } 
        set; 
    }
    // Charge Totals
    public Decimal onetimeTotals 
    { 
        get
        {
            if(onetimeTotals == null)
            {
                onetimeTotals = 0;
            }
            return onetimeTotals;
        } 
        set; 
    }
    public Decimal estimatedTotals 
    { 
        get
        {
            if(estimatedTotals == null)
            {
                estimatedTotals = 0;
            }
            return estimatedTotals;
        } 
        set;
    }
    public Decimal monthlyServiceTotals 
    { 
        get
        {
            if(monthlyServiceTotals == null)
            {
                monthlyServiceTotals = 0;
            }
            return monthlyServiceTotals;
        } 
        set;
    }
    public Decimal monthlySubscriptionTotals 
    { 
        get
        {
            if(monthlySubscriptionTotals == null)
            {
                monthlySubscriptionTotals = 0;
            }
            return monthlySubscriptionTotals;
        } 
        set;
    }
    public Decimal annualSubscriptionTotal
    {
        get
        {
            if(this.subCatTotal.containsKey('Annual Subscription'))
            {
                return this.subCatTotal.get('Annual Subscription');
            }
            else
            {
                return 0;
            }
        }
    }
    public Decimal onetimeServicesTotal
    {
        get
        {
            if(this.subCatTotal.containsKey('Services'))
            {
                return this.subCatTotal.get('Services');
            }
            else
            {
                return 0;
            }
        }
    }
    public Decimal hardwareTotal
    {
        get
        {
            if(this.subCatTotal.containsKey('Hardware'))
            {
                return this.subCatTotal.get('Hardware');
            }
            else
            {
                return 0;
            }
        }
    }
    public Decimal educationTotal
    {
        get
        {
            if(educationTotal == null)
            {
                educationTotal = 0;
            }
            return educationTotal;
        }
        set;
    }
    public Decimal annualProratedTotal
    {
        get
        {
            if(annualProratedTotal == null)
            {
                annualProratedTotal = 0;
            }
            return annualProratedTotal;
        }
        set;
    }
    public Decimal originalTotals
    {
        get
        {
            if(originalTotals == null)
            {
                originalTotals = 0;
            }
            return originalTotals;
        }
        set;
    }
    public Decimal totalContractValue
    {
        get
        {
            Decimal term = (this.zQuote.zqu__InitialTerm__c == 0 || this.zQuote.zqu__InitialTerm__c == null ? 1 : this.zQuote.zqu__InitialTerm__c);
            Decimal discount = (this.zQuote.zqu__Previewed_Discount__c == null ? 0 : this.zQuote.zqu__Previewed_Discount__c);
            if(this.isMultiYearTerm)
            {
                //return this.yearOneContractValue + ((this.monthlyServiceTotals + this.monthlySubscriptionTotals + (this.annualSubscriptionTotal / 12)) * (term - 12)) + this.originalTotals + discount;
                return this.onetimeTotals + ((this.monthlyServiceTotals + this.monthlySubscriptionTotals + (this.annualSubscriptionTotal / 12)) * term) + this.originalTotals + discount;
            }
            else
            {
                return this.onetimeTotals + ((this.monthlyServiceTotals + this.monthlySubscriptionTotals) * term) + this.originalTotals + discount;
            }
        }
    }
    public Decimal yearOneContractValue
    {
        get
        {
            Decimal discount = (this.zQuote.zqu__Previewed_Discount__c == null ? 0 : this.zQuote.zqu__Previewed_Discount__c);
            return this.onetimeTotals + this.annualProratedTotal + ((this.monthlyServiceTotals + this.monthlySubscriptionTotals) * this.currentYearProration) + discount;
        }
    }
    // END Charge Totals
    // Remaining Term for Amendments
    public Integer remainingTerm
    {
        get
        {
            if(remainingTerm == null)
            {
                Date today = Date.today();
                
                //Modified on Aug 28 2017 by Anju Starts -- If Subscription dates are null, populate it 
                if(this.zQuote.zqu__SubscriptionTermStartDate__c == null) {
                    this.zQuote.zqu__SubscriptionTermStartDate__c = this.zQuote.zqu__StartDate__c.addMonths(this.zQuote.PureCloud_Ramp_Up_Period__c != null ? Integer.valueOf(this.zQuote.PureCloud_Ramp_Up_Period__c) : 0);
                }
                if(this.zQuote.zqu__SubscriptionTermEndDate__c == null) {
                    this.zQuote.zqu__SubscriptionTermEndDate__c = this.zQuote.zqu__SubscriptionTermStartDate__c.addMonths(this.zQuote.zqu__InitialTerm__c != null ? Integer.valueOf(this.zQuote.zqu__InitialTerm__c) : 12);
                }
                //Modified on Aug 28 2017 by Anju ends
                
                if(today > this.zQuote.zqu__SubscriptionTermStartDate__c)
                {
                    remainingTerm = today.monthsBetween(this.zQuote.zqu__SubscriptionTermEndDate__c);
                }
                else
                {
                    if(this.zQuote.zqu__SubscriptionTermEndDate__c !=null && this.zQuote.zqu__SubscriptionTermStartDate__c !=null)
                      remainingTerm = this.zQuote.zqu__SubscriptionTermStartDate__c.monthsBetween(this.zQuote.zqu__SubscriptionTermEndDate__c);
                }
            }
            return remainingTerm;
        }
        private set;
    }
    // Number of Months remaining in the current years subscription.  This number is used for proating multi-year terms
    public Integer currentYearProration
    {
        get
        {   
            return (remainingTerm == 12 ? 12 : (Math.mod(this.remainingTerm, 12) == 0 ? 12 : Math.mod(this.remainingTerm, 12)));
        }
    } 
    // Logo Document Id
    public Id imgDocumentId
    {
        get
        {
            if(imgDocumentId == null)
            {
                imgDocumentId = [SELECT Id FROM Document WHERE DeveloperName = 'Genesys_Telecommunications_Laboratories_Inc_Logo'].Id;
            }
            return imgDocumentId;
        }
        private set;
    }
    // Address Information
    public List<Account_Order_Address__c> addresses
    {
        get
        {
            if(addresses == null)
            {
                addresses = new List<Account_Order_Address__c>();
                addresses = [SELECT Id, Address_Type__c, Address__c, Address2__c, City__c, State__c, Country__c, Zip_Code__c 
                             FROM Account_Order_Address__c 
                             //WHERE Account__c = :this.zQuote.zqu__Account__c];
                             WHERE Zuora_Quote__c = :this.zQuote.Id];
            }
            return addresses;
        }
        private set;
    }    
    
    public Account_Order_Address__c billingAddress
    {
        get
        {
            if(billingAddress == null)
            {
                for(Account_Order_Address__c a : addresses)
                {
                    if(a.Address_Type__c == 'Bill To')
                    {
                        billingAddress = a;
                        break;
                    }
                }
            }
            return billingAddress;
        }
        private set;
    }

    public Account_Order_Address__c shippingAddress
    {
        get
        {
            if(shippingAddress == null)
            {
                for(Account_Order_Address__c a : addresses)
                {
                    if(a.Address_Type__c == 'Ship To')
                    {
                        shippingAddress = a;
                        break;
                    }
                }
            }
            return shippingAddress;
        }
        private set;
    }

    public String currencySymbol
    {
        get
        {
            if(String.isEmpty(currencySymbol) && Currency_Settings__c.getValues(this.zQuote.zqu__Currency__c) != null)
            {
                currencySymbol = Currency_Settings__c.getValues(this.zQuote.zqu__Currency__c).Symbol__c;
            }
            return currencySymbol;
        }
        private set;
    }

    // List of Category Keys ordered to control display of categories
    public List<String> orderedCategories
    {
        get
        {
            if(orderedCategories == null)
            {
                orderedCategories = new List<String>();
                List<String> tmpList = new List<String>(this.chargeCatSubCatMap.keySet());
                tmpList.sort();
                for(Integer i = tmpList.size() - 1; i >= 0; i--)
                {
                    orderedCategories.add(tmpList.get(i));
                }
            }
            system.debug(orderedCategories);
            return orderedCategories;
        }
        private set;
    }

    // Partner Margins
    public List<PureCloud_Partner_Margin__c> partnerMargins
    {
        get
        {
            if(partnerMargins == null)
            {
                partnerMargins = new List<PureCloud_Partner_Margin__c> ([SELECT Percent__c, Margin_Type__c
                                                                            FROM PureCloud_Partner_Margin__c
                                                                            WHERE From_Date__c <= TODAY AND To_Date__c >= TODAY AND Account__c = :this.zQuote.zqu__Opportunity__r.BusinessPartner__c
                                                                            ORDER BY To_Date__c ASC]);
            }
            return partnerMargins;
        }
        private set;
    }
        
    public PureCloudDocumentController(ApexPages.StandardController stdController) {
        this.zQuote = (zqu__Quote__c)stdController.getRecord();

        this.isMultiYearTerm = (this.zQuote.zqu__InitialTerm__c > 12);

        categorizeCharges();
        createChargeMapping(this.newCharges);
        if(!removedCharges.isEmpty()) subtractRemovedChargesFromTotals();
        if(!originalCharges.isEmpty()) sumOriginalChargeTotals();
        
        
    }

    private void categorizeCharges()
    {
        for(zqu.zChargeGroup z : zChargeGroups)
        {
            if(z.groupType == zqu.zChargeGroup.TYPE_SUBSCRIPTION_ADDED 
                || z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_PRODUCT_NEW
                || z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_NEWPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_UPDATEPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_RENEWED )
            {
                this.newCharges.addAll(z.zCharges);
                createOriginalChargeMap(z);
            }

            if(z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT)
            {
                this.removedCharges.addAll(z.zCharges);
            }

            if(z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL
                || z.groupType == zqu.zChargeGroup.TYPE_CANCELLATION_ORIGINAL)
            {
                this.originalCharges.addAll(z.zCharges);
            }
        }
    }

    // Method to populate map of the original charges for any updated charge group
    // Used to show the delta between the original and updated charge
    private void createOriginalChargeMap(zqu.zChargeGroup zChargeGroup)
    {
        if(zChargeGroup.originalChargeGroup == null)
        {
            for(zqu.zCharge z : zChargeGroup.zCharges)
            {
                zqu.zCharge tmpCharge = new zqu.zCharge();
                zqu__QuoteRatePlanCharge__c tmpQRPC = new zqu__QuoteRatePlanCharge__c();
                tmpCharge.chargeObject = (SObject)tmpQRPC;
                tmpCharge.QUANTITY = '0';
                tmpCharge.EFFECTIVE_PRICE = '0';
                tmpCharge.TOTAL = '0';

                originalChargeMap.put(z.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID, tmpCharge);
            }
        }
        else
        {
            for(zqu.zCharge z : zChargeGroup.originalChargeGroup.zCharges)
            {
                originalChargeMap.put(z.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID, z);
            }
        }
        
    }
    //Added By Ranjith on Aug 07, 2017 -- Starts            
    private Map<Id, zqu__QuoteRatePlanCharge__c> getQuoteRatePlanCharges(Id quoteId)
    {              
        return new Map<Id, zqu__QuoteRatePlanCharge__c>(
                    [SELECT Id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c,
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.New_Category__c,
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Show_In_Quoting__c,
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Viewable__c
                     FROM zqu__QuoteRatePlanCharge__c
                     WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: quoteId]);       
    }
    //Added By Ranjith on Aug 07, 2017 -- Ends
    // Populate the Map of Document Category to inner map of Sub Category to Charges
    // Used to dynamically generate the table display in the PDF
    public Map<String, String> mapResourceServices {get; set;}
    public Boolean blnHasResourceServices{get; set;}
    
    private void createChargeMapping(List<zqu.zCharge> zCharges)
    {
        mapResourceServices = new Map<String, String>();
        blnHasResourceServices = false;
        
        this.chargeCatSubCatMap = new Map<String, Map<String, List<zqu.zCharge>>>();
        //Added By Ranjith on Aug 07, 2017 -- Starts
        map_qtRtPlnChrgs = getQuoteRatePlanCharges(zQuote.Id);
        //Added By Ranjith on Aug 07, 2017 -- Ends
        for(zqu.zCharge zcharge : zCharges)
        {
            zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zcharge.chargeObject;

            if(String.isEmpty(charge.Document_Category__c) || String.isEmpty(charge.Document_Subcategory__c)) continue;

            if(zcharge.MODEL.contains('Discount'))
            {
                discountCharges.add(zcharge);
                continue;
            }
            //Added By Ranjith on Aug 07, 2017 -- Starts
            zqu__QuoteRatePlanCharge__c objQtRtPlnChrge = new zqu__QuoteRatePlanCharge__c();
            if(map_qtRtPlnChrgs.containsKey(charge.Id)){
                objQtRtPlnChrge = map_qtRtPlnChrgs.get(charge.Id);
            }
            String strSubCategory = charge.Document_Subcategory__c;
            if(String.isNotBlank(Label.PureCloud_Credit_Products)
               && Label.PureCloud_Credit_Products.contains(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name)) {
                strSubCategory = 'PureCloud Credit';
            }
            //Added By Ranjith on Aug 07, 2017 -- Ends  
            //Anju Dec 20 - Resource Services
            if(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.New_Category__c == 'Resource Services' && objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.name != Label.PC_ResourceService_Custom_IVR_per_Minute_Charge){
            
                if(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Viewable__c == 'Yes') {
                    strSubCategory = 'Resource Services';
                    //not used anymore..
                    mapResourceServices.put(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.name,String.valueof(charge.zqu__EffectivePrice__c == null ? 0 : charge.zqu__EffectivePrice__c));
                }
                blnHasResourceServices = true;
            }
            //Anju Dec 20 - Resource Services ends
            
            else if(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Viewable__c == 'Yes')
            { 
                if(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.name == Label.PC_ResourceService_Custom_IVR_per_Minute_Charge)
                {
                    strSubCategory = 'Resource Services';
                    blnHasResourceServices = true;
                }    
                if(this.chargeCatSubCatMap.containsKey(charge.Document_Category__c))
                {                
                    if(this.chargeCatSubCatMap.get(charge.Document_Category__c).containsKey(strSubCategory))
                    {
                        this.chargeCatSubCatMap.get(charge.Document_Category__c).get(strSubCategory).add(zcharge);
                    }
                    else
                    {
                        this.chargeCatSubCatMap.get(charge.Document_Category__c).putAll(new Map<String, List<zqu.zCharge>>{strSubCategory => new List<zqu.zCharge>{zcharge}});                    
                    }
                }
                else
                {
                    this.chargeCatSubCatMap.put(charge.Document_Category__c, new Map<String, List<zqu.zCharge>>{strSubCategory => new List<zqu.zCharge>{zcharge}});
                }
            }
                        
            if(this.zQuote.zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c)
            {
                zcharge = ZuoraQuoteUtility.setPartnerPricing(zcharge, this.partnerMargins, map_qtRtPlnChrgs);                
            }            
            sumSubCatTotal(zcharge);
            calculateTotals(zcharge);            
        }
        system.debug(chargeCatSubCatMap);
        system.debug(mapResourceServices);
    }

    // Populate the total for each Sub Category being displayed
    private void sumSubCatTotal(zqu.zCharge zCharge)
    {
        try
        {
            Decimal total = 0.00;
            //Added By Ranjith on Aug 07, 2017 -- Starts
            zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zCharge.chargeObject;
            zqu__QuoteRatePlanCharge__c objQtRtPlnChrge = new zqu__QuoteRatePlanCharge__c();
            if(map_qtRtPlnChrgs.containsKey(charge.Id)){
                objQtRtPlnChrge = map_qtRtPlnChrgs.get(charge.Id);
            }
            
            //Boolean prorate = isProratedCharge(zCharge);
            String strSubCategory = charge.Document_Subcategory__c;
            if(String.isNotBlank(Label.PureCloud_Credit_Products)
               && Label.PureCloud_Credit_Products.contains(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name)) {
                strSubCategory = 'PureCloud Credit';
            }
            //Added By Ranjith on Aug 07, 2017 -- Ends
            //Anju Dec 20 - Resource Services
            if(objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.New_Category__c == 'Resource Services' && objQtRtPlnChrge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Viewable__c == 'Yes') {
                strSubCategory = 'Resource Services';
                
            }
            //Anju Dec 20 - Resource Services ends
            if(subCatTotal.containsKey(strSubCategory))
            {                
                total = subCatTotal.get(strSubCategory);
                total += (zCharge.CHARGE_TYPE != 'Usage' ? charge.zqu__Total__c : 0.00);
            }
            else
            {
                total = (zCharge.CHARGE_TYPE != 'Usage' ? charge.zqu__Total__c : 0.00);
            }

            subCatTotal.put(strSubCategory, total);
        }
        catch (Exception e)
        {
            system.debug('Error caluclating totals: ' + e.getMessage());
        }
    }

    // Populate the totals table
    private void calculateTotals(zqu.zCharge zCharge)
    {
        zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zCharge.chargeObject;
        
        if(charge.zqu__Total__c == null) return;
        
        Boolean prorate = isProratedCharge(zCharge);
        if(charge.Document_Category__c == 'One-Time Charges')
        {
            if(charge.Product_Category__c == 'Education')
            {
                this.educationTotal += (prorate ? prorateCharge(zCharge) : charge.zqu__Total__c);
            }
            this.onetimeTotals += (prorate ? prorateCharge(zCharge) : charge.zqu__Total__c);            
        }
        else if(charge.Document_Category__c == 'Monthly Recurring Charges')
        {
            if(charge.Document_Subcategory__c == 'Monthly Subscription')
            {
                this.monthlySubscriptionTotals += charge.zqu__Total__c;
            }
            else if(charge.Document_Subcategory__c == 'Monthly Services')
            {
                this.monthlyServiceTotals += charge.zqu__Total__c;
            }
            else if(charge.Document_Subcategory__c.indexOf('Estimated') > -1)
            {
                this.estimatedTotals += charge.zqu__Total__c;
            }
        }
        else if(charge.Document_Category__c == 'Annual Recurring Charges')
        {
            this.annualProratedTotal += prorateCharge(zCharge);
        }
    }

    // Subtract Removed Charges
    private void subtractRemovedChargesFromTotals()
    {
        try
        {
            for(zqu.zCharge zCharge : this.removedCharges)
            {
                zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zCharge.chargeObject;
                if(charge.zqu__Total__c == null) continue;
                if(zCharge.CHARGE_TYPE == 'One-Time' || (zCharge.CHARGE_TYPE == 'Recurring' && zCharge.PERIOD == 'Annual'))
                {
                    Decimal total = (isProratedCharge(zCharge) ? prorateCharge(zCharge) : charge.zqu__Total__c);
                    this.onetimeTotals -= total;
                }
            }
        }
        catch(Exception e)
        {
            system.debug('Subtract Removed Charges error: ' + e.getMessage());
        }        
    }
    
    // Calculate Original Totals for non modified/added/removed charges
    private void sumOriginalChargeTotals()
    {
        try
        {
            for(zqu.zCharge zCharge : this.originalCharges)
            {
                zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zCharge.chargeObject;
                if(charge.zqu__Total__c == null) continue;
                this.originalTotals += charge.zqu__Total__c;
            }
        }
        catch(Exception e)
        {
            system.debug('Calculate Original Charge Totals error: ' + e.getMessage());
        }  
    }

    // Determine if this is a charge that needs to be prorated for the current subscription
    private Boolean isProratedCharge(zqu.zCharge zCharge)
    {
        if(this.zQuote.zqu__SubscriptionType__c != 'New Subscription'
            && this.zQuote.zqu__InitialTerm__c >= 12 
            && zCharge.CHARGE_TYPE == 'Recurring'
            && zCharge.PERIOD == 'Annual') 
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    // Determine the prorate amount on additional licenses added or licenses removed for the current subscription
    private Decimal prorateCharge(zqu.zCharge zCharge)
    {
        zqu.zCharge originalCharge = originalChargeMap.get(zCharge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
        Decimal total = 0;
        
        if(originalCharge != null)
        {
            total = ((Decimal.valueOf(zCharge.TOTAL) - Decimal.valueOf(originalCharge.TOTAL)) / 12) * this.currentYearProration;        
        }
        else
        {
            total = (Decimal.valueOf(zCharge.TOTAL) / 12) * this.currentYearProration;
        }
        return total;
    }
    
}