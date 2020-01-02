public without sharing class ZuoraQuoteApprovalEmailController {
    public integer licensesCount;
    public integer hardwareCount;
    public integer servicesCount;
    private List<ChargeItem> licenses;
    private List<ChargeItem> services;
    private List<ChargeItem> hardware;
    private decimal licensesTotal;
    private decimal servicesTotal;
    private decimal hardwareTotal;
    private zqu__Quote__c quote;
    public string Host {get;set;}
    public string BaseUrl {get;set;}
    public string log {get;set;}
    
    // constructor    
    public ZuoraQuoteApprovalEmailController()
    {
        system.debug('## Entered ZuoraQuoteApprovalEmailController()');
        log = '## Entered ZuoraQuoteApprovalEmailController()';
        Host =  URL.getSalesforceBaseUrl().getHost();
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
    }
    public decimal getlicensesTotal()
    {
        return licensesTotal;
    }
    public decimal getservicesTotal()
    {
        return servicesTotal;
    }
    public decimal gethardwareTotal()
    {
        return hardwareTotal;
    }
    
    public zqu__Quote__c getQuote()
    {
        return quote;
    }

    public String QuoteId
    {
        set 
        {
            QuoteId = value;
            log = log + '<br />## set QuoteId() ' + QuoteId;        
            retrieveQuoteValues();            
        }
        get;
    }

    public integer getlicensesCount()
    {
        return licensesCount;
    }    
    public integer getServicesCount()
    {
        return servicesCount;
    }
    public integer getHardwareCount()
    {
        return hardwareCount;
    }
    public List<ChargeItem> getLicenses()
    {
        if (quote == null)
        {
            retrieveQuoteValues();
        }
        return licenses;
    }
    public List<ChargeItem> getServices()
    {
        if (quote == null)
        {
            retrieveQuoteValues();
        }
        return services;
    }
    public List<ChargeItem> getHardware()
    {
        if (quote == null)
        {
            retrieveQuoteValues();
        }
        return hardware;
    }    
    
    private void retrieveQuoteValues()
    {
        system.debug('## entered retrieveQuoteValues()');
        log = log + '<br />## entered retrieveQuoteValues()';
        
        licenses = new List<ChargeItem>();
        services = new List<ChargeItem>();
        hardware = new List<ChargeItem>();
        licensesTotal = 0;
        servicesTotal = 0;
        hardwareTotal = 0;        
        if (String.isEmpty(QuoteId))
        {
            // error
            system.debug(' ## Quote ID was not supplied.');
        }
        else
        {            
            system.debug('## Retrieve quote and quote charge records.');
            /*for (zqu__Quote__c q : [
                SELECT id, name, 
                zqu__Account__c, 
                zqu__Account__r.Name,
                zqu__Account__r.Owner.Name,
                zqu__Opportunity__c,
                zqu__Opportunity__r.Name,
                Annual_PrePay__c,
                Owner.Name,
                (SELECT Id, Name, 
                 zqu__ProductName__c, 
                 zqu__Discount__c, 
                 zqu__ChargeType__c, 
                 Discounted_Amount__c, 
                 Product_Category__c,
                 zqu__ListPrice__c,  
                 zqu__ListTotal__c,
                 zqu__TCV__c FROM zqu__QuoteRatePlanCharge__r)  
                from zqu__quote__c where id =: QuoteId])       
            {*/
                //quote = q;                              
                //system.debug('quote: ' + q);
            for (zqu__QuoteRatePlanCharge__c charge : [SELECT Id, Name, 
                 zqu__ProductName__c, 
                 zqu__Discount__c, 
                 zqu__ChargeType__c, 
                 Discounted_Amount__c, 
                 Product_Category__c,
                 zqu__ListPrice__c,  
                 zqu__ListTotal__c,
                 zqu__TCV__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :QuoteId])
            {
                //system.debug('## Product Name: ' + charge.zqu__ProductName__c);
                //system.debug('## Product Category: ' + charge.zqu__ChargeType__c);
                //system.debug('## List Price: ' + charge.zqu__ListPrice__c);
                                    
                ChargeItem item = new ChargeItem();
                item.ProductName = charge.zqu__ProductName__c;
                item.ListPrice = charge.zqu__ListPrice__c;
                item.DiscountPct = charge.zqu__Discount__c != 0 ? charge.zqu__Discount__c / 100 : 0;
                item.DiscountedAmount = charge.Discounted_Amount__c;
                item.TCV=charge.zqu__TCV__c;
                if(charge.Product_Category__c == 'Licenses')
                { 
                    licenses.add(item);
                    if (charge.zqu__ListTotal__c != null)
                    {
                        licensesTotal += charge.zqu__ListTotal__c;                            
                    }
                }                    
                if(charge.Product_Category__c == 'Services')
                {
                    services.add(item);
                    if (charge.zqu__ListTotal__c != null)
                    {
                        servicesTotal += charge.zqu__ListTotal__c;                            
                    }
                }
                if(charge.Product_Category__c == 'Hardware')
                {
                    hardware.add(item);
                    if (charge.zqu__ListTotal__c != null)
                    {
                        hardwareTotal += charge.zqu__ListTotal__c;                            
                    }
                }
            }
            //}            
        }
        
        
    }
    public string getUrlPrefix()
    {
        return System.URL.getSalesforceBaseUrl().toExternalForm() + '';
    }
    public class ChargeItem
    {
        public string ProductName {get;set;}
        public decimal ListPrice {get;set;}
        public decimal DiscountedAmount {get;set;}
        public double DiscountPct {get;set;}
        public decimal TCV {get;set;}
    }   
    
}