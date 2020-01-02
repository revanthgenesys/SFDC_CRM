public class ProductPriceReportController {
    public List<ProductWrapper> list_ProductWrapper {get; set;}
    public ProductPriceReportController(){
        list_ProductWrapper = new List<ProductWrapper>();
        for(Product2 prod : [SELECT Id, New_Category__c, Sub_Category__c, APN_Number__c, Name, Support_Information__c, 
                                Region__c, Price_Type__c,Charge_Type__c, NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG5_NA_CAD_Price__c,
                                NG5_NA_USD_Price__c, NG5_NZD_Price__c, NG5_ZAR_Price__c, NG3_EMEA_EUR_Price__c, NG1_APAC_ANZ_AUD_Price__c,
                                NG2_BRAZIL_BRL_Price__c,
                                    (SELECT Charge_Type__c, NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG5_NA_CAD_Price__c,
                                    NG5_NA_USD_Price__c, NG5_NZD_Price__c, NG5_ZAR_Price__c, 
                                    NG2_BRAZIL_BRL_Price__c, NG1_APAC_ANZ_AUD_Price__c, NG3_EMEA_EUR_Price__c FROM Product_Tier_Pricings__r) 
                                FROM Product2
                                WHERE OfferingType__c includes ('PureCloud')
                                AND Sub_Category__c != 'PureCloud Voice' AND Sub_Category__c != 'PureCloud Credit' AND Sub_Category__c != 'PureCloud Voice Tax'
                                AND APN_Number__c != 'MP-001-4.0-VDSC'
                                AND (Show_In_Quoting__c = true OR (isActive = true and New_Category__c ='Bundles'))  order by new_category__c,sub_category__c,name])
        {           
            if(prod.Price_Type__c != 'Fixed Price'){
                for(Product_Tier_Pricing__c price : prod.Product_Tier_Pricings__r){
                    ProductWrapper prodWrap = new ProductWrapper();
                    prodWrap.category = prod.New_Category__c;
                    prodWrap.subCategory = prod.Sub_Category__c;
                    prodWrap.apnNumber = prod.APN_Number__c;
                    prodWrap.prodName = prod.Name;
                    prodWrap.descr = prod.Support_Information__c;
                    prodWrap.region = prod.Region__c;
                    prodWrap.price = price.Charge_Type__c;
                    prodWrap.USD = price.NG5_NA_USD_Price__c;
                    prodWrap.CAD = price.NG5_NA_CAD_Price__c;
                    prodWrap.AUD = price.NG1_APAC_ANZ_AUD_Price__c;
                    prodWrap.NZD = price.NG5_NZD_Price__c;
                    prodWrap.GBP = price.NG3_EMEA_GBP_Price__c;
                    prodWrap.EUR = price.NG3_EMEA_EUR_Price__c;
                    prodWrap.BRL = price.NG2_BRAZIL_BRL_Price__c;
                    prodWrap.JPY = price.NG4_APAC_JAPAN_YEN_Price__c;
                    prodWrap.ZAR = price.NG5_ZAR_Price__c;
                    list_ProductWrapper.add(prodWrap);
                }
            }
            if(prod.Price_Type__c == 'Fixed Price'){
                ProductWrapper prodWrap = new ProductWrapper();
                prodWrap.category = prod.New_Category__c;
                prodWrap.subCategory = prod.Sub_Category__c;
                prodWrap.apnNumber = prod.APN_Number__c;
                prodWrap.prodName = prod.Name;
                prodWrap.descr = prod.Support_Information__c;
                prodWrap.region = prod.Region__c;
                prodWrap.price = prod.Price_Type__c;
                prodWrap.USD = prod.NG5_NA_USD_Price__c;
                prodWrap.CAD = prod.NG5_NA_CAD_Price__c;
                prodWrap.AUD = prod.NG1_APAC_ANZ_AUD_Price__c;
                prodWrap.NZD = prod.NG5_NZD_Price__c;
                prodWrap.GBP = prod.NG3_EMEA_GBP_Price__c;
                prodWrap.EUR = prod.NG3_EMEA_EUR_Price__c;
                prodWrap.BRL = prod.NG2_BRAZIL_BRL_Price__c;
                prodWrap.JPY = prod.NG4_APAC_JAPAN_YEN_Price__c;
                prodWrap.ZAR = prod.NG5_ZAR_Price__c;
                list_ProductWrapper.add(prodWrap);
            }
        }
        
        
    }
    
    
    public class ProductWrapper {
        public String category {get; set;}
        public String subCategory {get; set;}
        public String apnNumber {get; set;}
        public String prodName {get; set;}
        public String descr {get; set;}
        public String region {get; set;}
        public String price {get; set;}
        public Decimal USD {get; set;}
        public Decimal CAD {get; set;}
        public Decimal AUD {get; set;}
        public Decimal NZD {get; set;}
        public Decimal GBP {get; set;}
        public Decimal EUR {get; set;}
        public Decimal BRL {get; set;}
        public Decimal JPY {get; set;}
        public Decimal ZAR {get; set;}
    }
}