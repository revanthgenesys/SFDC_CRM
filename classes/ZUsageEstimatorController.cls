public with sharing class ZUsageEstimatorController {

    private final zqu__Quote__c quote;

    public List<zqu.zChargeGroup> zChargeGroups { get; set; }
    public List<zqu.zCharge> newCharges { get; private set; }
    public List<zqu.zCharge> removedCharges { get; private set; }
    public List<zqu.zCharge> originalCharges { get; private set; }

    public class ChargeItem
    {
        public Id ID {get;set;}
        public String Name {get;set;}
        public string ProductName {get;set;}
        public String Type {get;set;}
        public Decimal UnitPrice {get;set;}
        public Decimal Discount {get;set;}
        public Integer Quantity {get;set;}
        public String UOM {get;set;}
        public Integer Period {get;set;}
        public Decimal TotalCharge {get;set;}
        public String CurrencyCode {get;set;}
        public boolean IsDiscountable {get;set;}
        public String GroupType {get;set;}
        public Id ProductRatePlanChargeId { get; set; }
        public zqu__QuoteRatePlanCharge__c QuoteCharge {get; set;}
    }
    
    public class AutoDiscount
    {
        public boolean PrePay {get;set;}
        public string PartCategory  {get;set;}
        public decimal MinAmount  {get;set;}
        public Decimal MaxAmount  {get;set;}
        public Decimal Discount  {get;set;}            
    }

    private static String OnetimeHFName = 'onetimeChargesHf';
    private static String ServicesHFName = 'servicesChargesHf';
    private static String UsagesHFName = 'usageChargesHf';
    private static String PurecloudVoiceHFName = 'purecloudVoiceChargesHf';
    private static String PurecloudVoicePartHFName = 'purecloudVoicePartHf';
    private static string RecurringHardwareHFName = 'recurringHardwareChargesHF';
    
    public Decimal TotalOneTime {get;set;}
    public Decimal TotalOneTimeAll { get; set; }
    public Decimal TotalRecurringHardwareOneTime {get;set;}
    public Decimal TotalUsage {get;set;}
    public Decimal TotalAnnualizedUsage {get;set;}
    public Decimal TotalServices {get;set;}
    public Decimal TotalMonthly { get; set; }    
    public Decimal TotalPurecloudVoiceUsage {get;set;}  
    public Decimal TotalAnnualizedPurecloudVoiceUsage {get;set;}  
    public Decimal TotalAnnualizedRecurringHardware {get;set;}
    public Decimal GrandTotal {get;set;}
    
    //List<AutoDiscount> lstDiscounts;

    public Map<String, ChargeItem> onetimeCharges  { get; set; }
    public Map<String, ChargeItem> recurringHardwareCharges  { get; set; }
    public Map<String, ChargeItem> servicesCharges  { get; set; }
    public Map<String, ChargeItem> usageCharges  { get; set; }
    public Map<String, ChargeItem> purecloudVoiceCharges  { get; set; }
    public Map<String, ChargeItem> purecloudVoicePart  { get; set; }
    public Map<String, ChargeItem> usageAndRecurringHardwareCharges  { get; set; }

    public integer onetimeChargesSize {get;set;}
    public integer recurringHardwareChargesSize {get;set;}
    public integer servicesChargesSize {get;set;}
    public integer usageChargesSize {get;set;}
    public integer purecloudVoiceChargesSize {get;set;}
    public integer purecloudVoicePartSize {get;set;}
    public integer usageAndRecurringHardwareChargesSize {get;set;}

    public List<ChargeItem> onetimeChargeItems  {get;set;}
    public List<ChargeItem> servicesChargeItems  {get;set;}
    public List<ChargeItem> usageChargeItems  {get;set;}
    public List<ChargeItem> purecloudVoiceChargeItems  {get;set;}
    public List<ChargeItem> purecloudVoicePartItem  {get;set;}
    public List<ChargeItem> recurringHardwareChargeItems  {get;set;}
    public List<ChargeItem> allChargeItems { get; set; }
    
    Map<Id, Integer> indexesTable; 
    
    public Boolean NoOnetime {get;set;}
    public Boolean NoServices {get;set;}
    public Boolean NoUsage {get;set;}
    public Boolean NoPurecloudVoice {get;set;}
    public Boolean NoRecurringHardware  {get;set;}
    public Boolean attachmentSaved { get; set; }

    public string autoDiscountsJSON
    {
        get
        {
            //return JSON.serializePretty(lstDiscounts);
            return JSON.serializePretty(new List<AutoDiscount>());
        }
    }
    
    public string onetimeChargeItemsJSON
    {
        get
        {
            return JSON.serializePretty(onetimeChargeItems);    
        }
    }
    
    public string servicesChargeItemsJSON
    {
        get
        {
            return JSON.serializePretty(servicesChargeItems);    
        }
    }
    
    public string purecloudVoiceChargeItemsJSON
    {
        get
        {
            return JSON.serializePretty(purecloudVoiceChargeItems);    
        }
    }
    
    public string purecloudVoicePartJSON
    {
        get
        {
            return JSON.serializePretty(purecloudVoicePartItem);    
        }
    }
    
    public string usageChargeItemsJSON
    {
        get
        {
            return JSON.serializePretty(usageChargeItems);    
        }
    }
    
    public string recurringHardwareChargeItemsJSON
    {
        get
        {
            return JSON.serializePretty(recurringHardwareChargeItems);    
        }
    }

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

    public ZUsageEstimatorController(ApexPages.StandardController stdController) {
        this.quote = (zqu__Quote__c)stdController.getRecord();

        LoadPage();
    }

    private void GroupCharges()
    {
        // Get Quote Rate Plan Charge custom fields
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'EstimatedQty__c', 
                                                                        'Estimated_Discount__c', 
                                                                        'Estimated_Period__c', 
                                                                        'Product_Category__c',
                                                                        'Annual_PrePay__c',
                                                                        'Can_Be_Auto_Discounted__c'};
        zChargeGroups = zqu.zQuoteUtil.getChargeGroups(this.quote.Id);

        newCharges = new List<zqu.zCharge>();
        originalCharges = new List<zqu.zCharge>();
        removedCharges = new List<zqu.zCharge>();
        
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
                newCharges.addAll(z.zCharges);
            }

            if(z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT)
            {
                removedCharges.addAll(z.zCharges);
            }

            if(z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL
                || z.groupType == zqu.zChargeGroup.TYPE_CANCELLATION_ORIGINAL)
            {
                originalCharges.addAll(z.zCharges);
            }
        }

        allChargeItems = new List<ChargeItem>();
        allChargeItems.addAll(FillChargeItems(newCharges, 'new'));
        allChargeItems.addAll(FillChargeItems(removedCharges, 'removed'));
        allChargeItems.addAll(FillChargeItems(originalCharges, 'original'));

        LoadQuoteCharges();
    }

    private void LoadQuoteCharges()
    {
        system.debug('LoadQuoteCharges()');
        onetimeCharges = new Map<String, ChargeItem>();
        recurringHardwareCharges = new Map<String,ChargeItem>();
        servicesCharges = new Map<String, ChargeItem>();
        usagecharges = new Map<String, ChargeItem>();
        purecloudVoiceCharges = new Map<String, ChargeItem>();
        pureCloudVoicePart = new Map<String, ChargeItem>();
        usageAndrecurringHardwareCharges = new Map<String, ChargeItem>();
        Map<String, ChargeItem> uncategorizedCharges = new Map<String, ChargeItem>();        

        for(ChargeItem zchar : allChargeItems)
        {
            zqu__QuoteRatePlanCharge__c charge = zchar.QuoteCharge;
            if(String.isBlank(charge.Product_Category__c) && String.isNotBlank(zchar.ProductRatePlanChargeId))
            {
                uncategorizedCharges.put(zchar.ProductRatePlanChargeId, zchar);
                continue;
            }

            if (charge.Product_Category__c == 'Voice Services')
            {
                purecloudVoiceCharges.put(charge.Id, zchar);                
            }
            
            if(charge.Product_Category__c == 'Hardware' || charge.Product_Category__c == 'Education')
            {
                
                if (charge.zqu__ChargeType__c == 'Recurring')
                {
                    recurringHardwareCharges.put(charge.Id, zchar);
                    usageAndRecurringHardwareCharges.put(charge.Id, zchar);
                }
                else if(charge.zqu__ChargeType__c != 'Usage')
                {
                    onetimeCharges.put(charge.Id, zchar);
                }
            }
            
            if(charge.Product_Category__c == 'Services')
            {
                servicesCharges.put(charge.Id,zchar);
            }
            
            if(charge.Product_Category__c == 'Licenses' || (charge.Product_Category__c == 'Hardware' && charge.zqu__ChargeType__c == 'Usage'))
            {
                if(charge.zqu__ChargeType__c == 'One-Time')
                {
                    onetimeCharges.put(charge.Id, zchar);
                }
                else
                {
                    usagecharges.put(charge.Id,zchar);
                    usageAndRecurringHardwareCharges.put(charge.Id, zchar); 
                }                
            }
        }

        if(uncategorizedCharges.keySet().size() != 0)
        {
            for(zqu__ProductRatePlanCharge__c p : [SELECT Id, zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c FROM zqu__ProductRatePlanCharge__c WHERE Id IN: uncategorizedCharges.keySet()])
            {
                ChargeItem thisCharge = uncategorizedCharges.get(p.Id);
                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Voice Services')
                {
                    purecloudVoiceCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                }

                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Services')
                {
                    servicesCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                }

                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Licenses' ||
                    (p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Hardware' && uncategorizedCharges.get(p.Id).Type == 'Usage'))
                {
                    if(uncategorizedCharges.get(p.Id).Type == 'One-Time')
                    {
                        onetimeCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                    }
                    else
                    {
                        usageCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                        usageAndRecurringHardwareCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                    }
                }

                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Hardware' || p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Education')
                {
                    if(uncategorizedCharges.get(p.Id).Type == 'Recurring')
                    {
                        recurringHardwareCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);  
                        usageAndRecurringHardwareCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                    }
                    else if(uncategorizedCharges.get(p.Id).Type != 'Usage')
                    {
                        onetimeCharges.put(thisCharge.ProductRatePlanChargeId, thisCharge);
                    }                
                }
            }
        }

        onetimeChargesSize = onetimeCharges.keySet().size();
        recurringHardwareChargesSize = recurringHardwareCharges.keySet().size();
        servicesChargesSize = servicesCharges.keySet().size();
        usageChargesSize = usageCharges.keySet().size();
        purecloudVoiceChargesSize = purecloudVoiceCharges.keySet().size();
        purecloudVoicePartSize = purecloudVoicePart.keySet().size();
        usageAndRecurringHardwareChargesSize = usageAndRecurringHardwareCharges.keySet().size();
        
        InitializeViewModel();
        CalculateGroupTotals();
    }

    private void InitializeViewModel()
    {
        system.debug('InitializeViewModel()');
        onetimeChargeItems = onetimeCharges.values();
        servicesChargeItems = servicesCharges.values();
        usageChargeItems = usagecharges.values();
        purecloudVoiceChargeItems = purecloudVoicecharges.values();
        purecloudVoicePartItem = purecloudVoicePart.values();
        recurringHardwareChargeItems = recurringHardwareCharges.values();
    }

    private void CalculateGroupTotals()
    {
        TotalMonthly = 0;
        List<ChargeItem> usageAndServiceCharges = new List<ChargeItem>();
        usageAndServiceCharges.addAll(usageChargeItems);
        usageAndServiceCharges.addAll(servicesChargeItems);

        List<ChargeItem> lst_TotalOneTimeWithUsageAndService = new List<ChargeItem>();
        for(ChargeItem charge : usageAndServiceCharges)
        {
            zqu__QuoteRatePlanCharge__c q = charge.QuoteCharge;
            if((String.isNotBlank(q.zqu__Period__c) && q.zqu__Period__c == 'Annual') || q.zqu__ChargeType__c == 'One-Time')
            {
                lst_TotalOneTimeWithUsageAndService.add(charge);
            }
        }
        lst_TotalOneTimeWithUsageAndService.addAll(onetimeChargeItems);
        TotalOneTimeAll = CalculateTotalCost(lst_TotalOneTimeWithUsageAndService);
        TotalOneTime = CalculateTotalCost(onetimeChargeItems);
        TotalRecurringHardwareOneTime = CalculateTotalCost(recurringHardwareChargeItems);
        TotalUsage = CalculateTotalCost(usageChargeItems);        
        TotalServices = CalculateTotalCost(servicesChargeItems);
        TotalPurecloudVoiceUsage = CalculateTotalCost(purecloudVoiceChargeItems);

        GrandTotal = TotalOneTime + TotalServices + TotalUsage + TotalRecurringHardwareOneTime + TotalPurecloudVoiceUsage;
    }

    private Decimal CalculateTotalCost(List<ChargeItem> chargeItems)
    {
        Decimal total = 0;
        for(ChargeItem charge : chargeItems)
        {
            if(charge.GroupType == 'removed') continue;
            zqu__QuoteRatePlanCharge__c q = charge.QuoteCharge;
            Decimal chargeTotal = 0;
            if (q.zqu__ListPrice__c != null && q.Estimated_Discount__c != null && q.EstimatedQty__c != null)
            {
                chargeTotal = (q.zqu__ListPrice__c * (1 - (q.Estimated_Discount__c / 100))) * q.EstimatedQty__c;                
                if(!q.zqu__ChargeType__c.equalsIgnoreCase('One-Time') && String.isNotBlank(q.zqu__Period__c) && q.zqu__Period__c == 'Month')
                {
                    TotalMonthly += chargeTotal;                    
                }                
            }
            else if (q.zqu__ListPrice__c != null && q.zqu__Discount__c != null && q.zqu__Quantity__c != null)
            {
                chargeTotal = (q.zqu__ListPrice__c * (1 - (q.zqu__Discount__c / 100))) * q.zqu__Quantity__c;                
                if(!q.zqu__ChargeType__c.equalsIgnoreCase('One-Time') && String.isNotBlank(q.zqu__Period__c) && q.zqu__Period__c == 'Month')
                {
                    TotalMonthly += chargeTotal;                    
                }                
            }
            total += (chargeTotal * charge.Period);
        }

        return total;
    }
    
    private void SetNoChargesFlags()
    {
        system.debug('SetNoChargesFlags()');
        NoOnetime = onetimeChargeItems.size() == 0;
        NoServices = servicesChargeItems.size() == 0;
        NoUsage = usageChargeItems.size() == 0;
        NoPurecloudVoice = purecloudVoiceChargeItems.size() == 0;
        NoRecurringHardware = recurringHardwareCharges.size() == 0;
    }    
    
    private List<ChargeItem> FillChargeItems(List<zqu.zCharge> sCharges, String groupType)
    {
        system.debug('FillChargeItems()');
        List<ChargeItem> chargeItems = new List<ChargeItem>();
        for(zqu.zCharge sCharge : sCharges)
        {
            try
            {
                //system.debug('--> discount: ' + sCharge.zqu__Discount__c);
                //system.debug('--> estimated discount: ' + sCharge.Estimated_Discount__c);
                zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)sCharge.ChargeObject;
                ChargeItem newCharge = new ChargeItem();
                newCharge.Id = charge.Id;
                newCharge.Name = charge.Name;
                newCharge.ProductName = charge.zqu__ProductName__c;
                newCharge.Type = charge.zqu__ChargeType__c;
                newCharge.CurrencyCode = charge.zqu__Currency__c;
                //System.debug('=====> isDiscountable: ' + sCharge.Can_Be_Auto_Discounted__c);
                newCharge.IsDiscountable = charge.Can_Be_Auto_Discounted__c;
                String sPrice = (charge.zqu__ListPrice__c == null ? '0.00' : String.valueOf(charge.zqu__ListPrice__c.SetScale(2)));
                newCharge.UnitPrice = Decimal.valueOf(sPrice);
                Integer estQuantity = (charge.EstimatedQty__c == null) ? 0 : integer.valueOf(charge.EstimatedQty__c);
                Integer quantity = (charge.zqu__Quantity__c == null) ? 0 : integer.valueOf(charge.zqu__Quantity__c);
                if (quantity == 0)
                {
                    newCharge.Quantity = estQuantity;
                }
                else
                {
                    newCharge.Quantity = quantity;
                }
                newCharge.Discount = (charge.zqu__Discount__c == null ? 0 : charge.zqu__Discount__c.SetScale(2)); // PCPQ-103 - don't use estimated value // sCharge.Estimated_Discount__c == null ? (sCharge.zqu__Discount__c == null ? 0 : sCharge.zqu__Discount__c.SetScale(2)) : sCharge.Estimated_Discount__c.SetScale(2);
                newCharge.UOM = charge.zqu__UOM__c == null ? '' : charge.zqu__UOM__c;
                newCharge.Period = ((this.quote.Annual_PrePay__c || this.quote.zqu__InitialTerm__c == 12) && charge.zqu__Period__c == 'Month' && !charge.zqu__ChargeType__c.equalsIgnoreCase('One-Time')) ? 12 : 1;
                newCharge.TotalCharge = 0;
                newCharge.GroupType = groupType;
                newCharge.QuoteCharge = charge;
                newCharge.ProductRatePlanChargeId = sCharge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID;
                
                chargeItems.add(newCharge);                
            }
            catch (exception ex)
            {
                system.debug(ex);
                system.debug(ex.getStackTraceString());
            }
        }
        
        return chargeItems;
    }
    
    public void LoadPage()
    {
        system.debug('LoadPage()');
        GroupCharges();
        //LoadAutoDiscounts();
        SetNoChargesFlags();
        //CalculateQuoteMetrics();
        
        attachmentSaved = false;
        //System.Debug('onetimeChargeItemsJSON: ' + onetimeChargeItemsJSON);
        //System.Debug('servicesChargeItemsJSON: ' + servicesChargeItemsJSON);
        //System.Debug('usageChargeItemsJSON: ' + usageChargeItemsJSON);
        //System.debug('purecloudVoiceItemsJSON: ' + purecloudVoiceChargeItemsJSON);
        //System.debug('recurringHardwareChargeItemsJSON: ' + recurringHardwareChargeItemsJSON);
        //System.debug('autoDiscountsJSON: ' + autoDiscountsJSON);
        
    }

    private void CalculateQuoteMetrics()
    {
        List<zqu.zQuoteUtil.ZBillingResult> billingResults = new List<zqu.zQuoteUtil.ZBillingResult>();
        if(test.isRunningTest())
        {
            billingResults = TestZuoraMockData.TestPreviewQuotes(new List<String>{this.quote.Id});
        }
        else
        {
            billingResults = zqu.zQuoteUtil.previewQuotes(new List<String>{this.quote.Id});
        }
        
        if(billingResults.size() > 0 && billingResults[0].totalInfo != null)
        {
            zqu.zQuoteUtil.ZBillingResult billingResult = billingResults[0];
            zqu.zQuoteUtil.TotalInfo totalInfo = billingResults[0].totalInfo;
            this.quote.zqu__previewed_tax__c = totalInfo.tax;
            this.quote.zqu__previewed_discount__c = totalInfo.discount;
            this.quote.zqu__previewed_subtotal__c = totalInfo.subTotal;
            this.quote.zqu__previewed_total__c = totalInfo.total;
            this.quote.zqu__previewed_MRR__c = billingResult.totalMrr;
            this.quote.zqu__Previewed_TCV__c = billingResult.totalTcv;
        }
    }
    
    /*private void LoadAutoDiscounts()
    {
        lstDiscounts = new List<AutoDiscount>();
        for (Zuora_Auto_Discount__c d : [SELECT Annual_Pre_Pay__c, Discount__c, Minimum__c, Maximum__c, Product_Category__c from Zuora_Auto_Discount__c ])
        {
            AutoDiscount ad = new AutoDiscount();
            ad.PrePay = d.Annual_Pre_Pay__c;
            ad.Discount = d.Discount__c;
            ad.MinAmount = d.Minimum__c;
            ad.MaxAmount = d.Maximum__c;
            ad.PartCategory = d.Product_Category__c;
            lstDiscounts.add(ad);            
        }
    } */   
    
    //Save Functions
    private void UpdateEstimates(boolean SaveToQuote)
    {
        system.debug('=====> UpdateEstimates()');
        system.debug('=====> SaveToQuote: ' + SaveToQuote);
        
        //get JSON String
        String onetimeChargesJson = ApexPages.currentPage().getParameters().get(OnetimeHFName);
        String servicesChargesJson = ApexPages.currentPage().getParameters().get(ServicesHFName);
        String usageChargesJson = ApexPages.currentPage().getParameters().get(UsagesHFName);
        String purecloudVoiceChargesJson = ApexPages.currentPage().getParameters().get(PurecloudVoiceHFName);
        String purecloudVoicePartJson = ApexPages.currentPage().getParameters().get(PurecloudVoicePartHFName);
        String recurringHardwareChargesJson = ApexPages.currentPage().getParameters().get(RecurringHardwareHFName);

        
        List<ChargeItem> onetimeChargeItems = new List<ChargeItem>();
        List<ChargeItem> servicesChargeItems = new List<ChargeItem>();
        List<ChargeItem> usageChargeItems = new List<ChargeItem>();
        List<ChargeItem> recurringHardwareChargeItems = new List<ChargeItem>();
        List<ChargeItem> allChargeItems = new List<ChargeItem>();
        List<ChargeItem> pcVoiceChargeItems = new List<ChargeItem>();
        List<ChargeItem> pcVoicePartItem = new List<ChargeItem>();
        //Deserialize
        if (onetimeChargesJson != null)
        {
            onetimeChargeItems =  (List<ChargeItem>) JSON.deserialize(onetimeChargesJson, List<ChargeItem>.class) ;                 
        }
        if (servicesChargesJson != null)
        {
            servicesChargeItems =  (List<ChargeItem>) JSON.deserialize(servicesChargesJson, List<ChargeItem>.class) ;                             
        }
        if (usageChargesJson != null)
        {
            usageChargeItems =  (List<ChargeItem>) JSON.deserialize(usageChargesJson, List<ChargeItem>.class) ;                 
        }
        if (purecloudVoiceChargesJson != null)
        {
            pcVoiceChargeItems =  (List<ChargeItem>) JSON.deserialize(purecloudVoiceChargesJson, List<ChargeItem>.class) ;                 
        }
        if (purecloudVoicePartJson != null)
        {
            pcVoicePartItem =  (List<ChargeItem>) JSON.deserialize(purecloudVoicePartJson, List<ChargeItem>.class) ;                 
        }
        if (recurringHardwareChargesJSON != null)
        {
            recurringHardwareChargeItems =  (List<ChargeItem>) JSON.deserialize(recurringHardwareChargesJSON, List<ChargeItem>.class) ;     
        }
        
        //update collection
        List<ChargeItem> allCharges = onetimeChargeItems;
        allCharges.addAll(servicesChargeItems);
        allCharges.addAll(usageChargeItems);
        allCharges.addAll(recurringHardwareChargeItems);
        
        //We now update PC voice parts that are estimated
        allCharges.addAll(pcVoiceChargeItems);
        
        List<zqu__QuoteRatePlanCharge__c> ChargesToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
        for(ChargeItem charge : allCharges)
        {
            if(String.isBlank(charge.QuoteCharge.Id) || charge.GroupType != 'new') continue;
            zqu__QuoteRatePlanCharge__c toUpdate = onetimeCharges.containsKey(charge.Id) ? 
                onetimeCharges.get(charge.Id).QuoteCharge : servicesCharges.containsKey(charge.Id) ? 
                    servicesCharges.get(charge.id).QuoteCharge : usageCharges.containsKey(charge.Id) ? 
                        usageCharges.get(charge.Id).QuoteCharge : recurringHardwareCharges.containsKey(charge.Id) ? 
                            recurringHardwareCharges.get(charge.Id).QuoteCharge : purecloudVoiceCharges.containsKey(charge.Id) ? 
                                purecloudVoiceCharges.get(charge.Id).QuoteCharge : null;
            
            if(toUpdate.zqu__Model__c == 'Discount-Percentage') continue;
            toUpdate.EstimatedQty__c = charge.Quantity == null ? 0 : charge.Quantity;
            toUpdate.Estimated_Discount__c = charge.Discount == null ? 0 : charge.Discount;
            toUpdate.Estimated_Period__c = charge.Period == null ? 0 : charge.Period;
            if (SaveToQuote == true)
            {
                toUpdate.zqu__Quantity__c = charge.Quantity == null ? 0 : charge.Quantity;
                toUpdate.zqu__Discount__c = charge.Discount == null ? 0 : charge.Discount;
                decimal effectivePrice = (toUpdate.zqu__ListPrice__c == null ? 0 : toUpdate.zqu__ListPrice__c * (1 - toUpdate.zqu__Discount__c / 100));
                toUpdate.zqu__EffectivePrice__c = effectivePrice.setScale(2, System.RoundingMode.HALF_UP);
                //toUpdate.zqu__ProductRatePlanCharge__r.zqu__PrepaymentPeriods__c = charge.Period == null ? 0 : charge.Period;

                // Start PCPQ-76                
                ZQuoteDiscountUtilities.CalculateQuantityAndTotal(toUpdate);
                // End PCPQ-76
            
            }
            ChargesToUpdate.add(toUpdate);
        }

        CalculateQuoteMetrics();
        
        update ChargesToUpdate;
        update this.quote;                 
    }
    
    public PageReference Save() {
        UpdateEstimates(true);
        CheckandMakePrimary();
        
        PageReference thisPage = ApexPages.currentPage();
        thisPage.getParameters().put('id', this.quote.Id);
        thisPage.setRedirect(true);
        return thisPage;
        
    }   
    
    public PageReference SaveAndExit() {
        UpdateEstimates(true);
        CheckandMakePrimary();
        
        PageReference zquotePage = new PageReference('/' + this.quote.Id);
        zquotePage.setRedirect(true);
        return zquotePage;
        
    } 
    
    public PageReference ViewPdf()
    {
        UpdateEstimates(true);
        PageReference pdfPage = Page.ZUsageEstimatorPdf;        
        pdfPage.getParameters().put('id',this.quote.Id);
        pdfPage.setRedirect(true);        
        return pdfPage;
        
    }
    
    private void SavePdf()
    {
        System.debug('SavePdf');        
        try
        {
            Attachment myAttach = new Attachment();       
            myAttach.ParentId = this.quote.Id;     //Id of the object to which the page is attached
            myAttach.name = this.quote.Name + ' Estimator - ' + System.Now().format('yyyy-MM-dd hh-mm a') + '.pdf';
            PageReference myPdf = Page.ZUsageEstimatorPDF;   //myPdfPage is the name of your pdf page
            myPdf.getParameters().put('id', this.quote.Id);
            myAttach.body = Test.isRunningTest() ? Blob.valueOf('ThisUNIT.TEST') : myPdf.getContentAsPdf();
            insert myAttach;                    
        }
        catch (Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));                        
        }
    }
    
    public PageReference SavePdfAsAttachment()
    {
        System.debug('SavePdfAsAttachment');
        UpdateEstimates(false);        
        SavePdf();
        attachmentSaved = true;
        return null;      
    }
    
    //When first PC Quote comes in, make that as primary and update Opp total Anju Starts Oct 6
    public void CheckandMakePrimary()
    {
           List<zqu__Quote__c> exsitingPCQuotes = new List<zqu__Quote__c>();
               exsitingPCQuotes = [SELECT ID FROM zqu__Quote__c WHERE id != :this.quote.id and zqu__Opportunity__c = :this.quote.zqu__Opportunity__c];
           List<BigMachines__Quote__c> exsitingBMQuotes = new List<BigMachines__Quote__c>();
               exsitingBMQuotes = [SELECT ID FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c = :this.quote.zqu__Opportunity__c and (BigMachines__Is_Primary__c = true or Is_Business_Primary__c = true)];
           
           
           if(exsitingPCQuotes.size() < 1 && exsitingBMQuotes.size() < 1 && this.quote.zqu__Primary__c == false)
           {
               this.quote.zqu__Primary__c = true;
               try{
                   update this.quote;
               }catch(Exception e){System.debug(e.getmessage());}
               
               ApexPages.StandardController strCtrl = new ApexPages.StandardController(new opportunity(id = this.quote.zqu__Opportunity__c));
               OpportunityQuotes oppQuotes = new OpportunityQuotes(strCtrl);
               Opportunity objToUpdateOppTotals;
               if(!Test.isRunningTest())                       
                   //Naresh Kumar - 04/03/2018 - Commenting below line as the function doesn't exist in the class.
                   //objToUpdateOppTotals  = oppQuotes.setupOpportunityTotals(this.quote); 
               try{
                   if(objToUpdateOppTotals != null)
                       update objToUpdateOppTotals;
               }catch(Exception e){System.debug(e.getmessage());}
           }
           
    }
    
}