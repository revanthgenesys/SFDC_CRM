//Naresh Kumar  07/29/2014
public with sharing class ProposalPDFOnPremiseController {
    //quote 
    public BigMachines__Quote__c quote {get;set;}
    //will hold currency sybmbol
    public String currencySymbol {get;set;}
    //quote products
    public List<wrapperQuoteProducts> quoteProducts {get;set;}
    //quote products
    public List<wrapperQuoteProducts> quoteProductsBundles {get;set;}   
    //quote total summary (categories)
    public List<wrapperQuoteTotalSummary> quoteTotalSummary {get;set;}
    //quote products records
    public List<BigMachines__Quote_Product__c> quoteProductRecords {get; set;}
    //quote products records (ECCNs only)
    public List<BigMachines__Quote_Product__c> quoteProductRecordsECCNs {get; set;}
    //Bundle products records
    public List<BigMachines__Quote_Product__c> quoteProductBundlesRecords {get; set;}
    //Boolean flag to determin whether the quoteProducts list has records or not
    public Boolean showQuoteProduct {get;set;}
    //Boolean flag to determin whether the bundle list has records or not
    public Boolean showBundles {get;set;}
    //Boolean flag which tells is there any PS RDP product
    public Boolean isPSRDPProduct {get;set;}
    //Will contain PSRDP Products
    public Boolean showAdjustment {get;set;}
    public List<BigMachines__Quote_Product__c> quotePSRDPProducts {get; set;}
    public ProposalPDFOnPremiseController(){
        Map<String, List<wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary = new Map<String, List<wrapperQuoteTotalSummary>>(); 
        quotePSRDPProducts = new List<BigMachines__Quote_Product__c>();
        String quoteId = ApexPages.currentPage().getParameters().get('id');     
        //Querying quote record
        quote = ProposalPDFOnPremiseControllerHelper.getQuote(quoteId);         
        //Querying quote product records
        quoteProductRecords = ProposalPDFOnPremiseControllerHelper.getQuoteProducts(quoteId, quote.Group_Product_By__c,quote);
          
        //Querying Bundle
        quoteProductBundlesRecords = ProposalPDFOnPremiseControllerHelper.getQuoteProductsForBundles(quoteId,false);
        
        //Populatting flag to show records
        if(quoteProductRecords.isEmpty()){
            showQuoteProduct = false;
            return;
        }
        else
            showQuoteProduct = true;
        //Populating flag whether to show or hid adjustment
        if(quote.Adjustment__c == null || quote.Adjustment__c == 0)
            showAdjustment = false;
        else
            showAdjustment = true;  
        quoteTotalSummary = new List<wrapperQuoteTotalSummary>();
        //getting populated wrapper list
        quoteProducts = ProposalPDFOnPremiseControllerHelper.getWrapperList(quote, quoteProductRecords, mapTypeVsQuoteTotalSummary, quotePSRDPProducts);    
        //Querying quote products bundles
        quoteProductsBundles = ProposalPDFOnPremiseControllerHelper.getWrapperListBundles(quote, mapTypeVsQuoteTotalSummary, quotePSRDPProducts);
        if(quotePSRDPProducts.isEmpty())
            isPSRDPProduct = false;
        else
            isPSRDPProduct = true;
        System.debug('NKC debug quoteProductsBundles ['+quoteProductsBundles+']');
        
        //populating flag to show bundles or not
        if(quoteProductsBundles.isEmpty())
            showBundles = false;
        else
            showBundles = true;
        //getting popualted summary records
        if(quote.Offering_Type__c == 'Cloud Partner (PPU)')
            quoteTotalSummary = ProposalPDFOnPremiseControllerHelper.getSummaryWrapperListPopulatedPPU(quote, mapTypeVsQuoteTotalSummary);
        else
            quoteTotalSummary = ProposalPDFOnPremiseControllerHelper.getSummaryWrapperListPopulated(quote, mapTypeVsQuoteTotalSummary);
        //getting currency symbol
        currencySymbol = ProposalPDFOnPremiseControllerHelper.getCurrencySymbol(quote.currencyIsoCode);      
        quoteProductRecordsECCNs = new List<BigMachines__Quote_Product__c>();
        for(BigMachines__Quote_Product__c eachQP : quoteProductRecords){
            if(eachQP.BigMachines__Product__r.Type__c !='Genesys Care' && eachQP.BigMachines__Product__r.Type__c != 'Expense Relief')
                quoteProductRecordsECCNs.add(eachQP);   
        }               
    }
    
    public class wrapperQuoteProducts{
        public BigMachines__Quote_Product__c record {get;set;}
        public String headerName {get;set;}
        public String headerDescription {get; set;}
        public Boolean isHeaderRow {get;set;}
        public String rowStyle {get;set;} 
        public String outputFormat {get;set;}
        public Boolean hideNumbers {get;set;}
    }
    
    public class wrapperQuoteTotalSummary{
        public String summaryName {get;set;}
        public String categoryOrBundleName {get;set;}       
        public BigMachines__Quote_Product__c record {get;set;}
        public String outputFormat {get;set;}
        public String rowStyle {get;set;}       
    }
}