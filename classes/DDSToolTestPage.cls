/* Mariya Steason - Aug 2018
   Purpose: DDSToolTestPage is the page DDSToolTestPage controller
   Test class: DDSTool_Test
*/
public class DDSToolTestPage {

    public BigMachines__Quote__c qte {get; set;}
    public String quoteId {get; set;}
    public String Log {get; set;}
    public String Score {get; set;}
    public String logLevel {get; set;}
    public Integer node {get; set;}
    public transient List<dtLine> qteData {get; set;}
    public transient List<ThirdPartyHWLine> thirdPrtHWData {get; set;} 
    public transient List<excludeLine> excldData {get; set;}
    public Map<String,String> nodeVars {get; set;}
    public Map<String,String> adjustVars {get; set;}
    public Map<String,String> postPrVars {get; set;}
    public Boolean showScore {get; set;} 
    public Map<String, String> nodeCutoffs {get; set;}
    public Map<String, String> NormDiscount {get; set;}
    public Map<String, String> AddSubscript {get; set;}
    public Map<String, String> AddCare {get; set;}
    public Map<String, String> AddPS {get; set;}
    public Map<String, String> AddGU {get; set;}
    public Map<String, String> AddMaxDiscts {get; set;}
    public Map<String, String> QuoteDiscAdjusted {get; set;}
    public List<String> iterator {get; private set;}
    public String discount {get; private set;}
    public String quoteDiscount {get; private set;}
    public Boolean directSales {get; private set;}
    public Boolean isSubscrpt {get; private set;}
    public Boolean isAmendment {get; private set;}
    public String offering {get; private set;}
    public String offer {get; private set;}
    public String priceBook {get; private set;}
    public String errorMsg {get; set;}
    public Boolean showDealDisc {get; set;}
    public Boolean showDDSPrice {get; set;}
    public Boolean showExcl {get; set;}
    public List<histLine> HistoricalOppts {get; set;}
    public Boolean isThirdPrtHW {get; set;}
    public String AmendScoringPath {get; set;}
    
    public DDSToolTestPage() {
        qte = new BigMachines__Quote__c();
        showScore = false;
        showDealDisc = true;
        isThirdPrtHW = false;
        showExcl = false;
    }
    
    public void getScore() {
        if ( qte.Parent_Quote__c == null )
          return;
       
       String quoteId = qte.Parent_Quote__c;     
       clearVars();
       
       DDSToolMain dds = DDSToolMain.getDDSToolMain(quoteId, Integer.valueOf(logLevel));
       
       Log = dds.Log;
       Score = dds.displayScoreVal;
       
       if (dds.quoteData == null) {
          Score = 'Error';
          return;
       }
       
       qteData= new List<dtLine>();
       for (DDSToolQuoteData.ProductLine pr : dds.quoteData.quoteProdLine) { 
          dtLine ln = new dtLine();
          ln.name = pr.ProductDescr; 
          ln.type = pr.Input_ProductType;
          ln.Category = pr.ProductCategory; 
                   
          ln.ListPrice = pr.Input_TotalListPriceAdjusted != null ? pr.Input_TotalListPriceAdjusted.SetScale(6) : null;
          ln.NetPrice = pr.Input_TotalNetPriceAdjusted != null ? pr.Input_TotalNetPriceAdjusted.SetScale(6) : null;
          
          ln.ListPriceLocal = pr.Input_TotalListPriceLocal != null ? pr.Input_TotalListPriceLocal.SetScale(6) : null;
          ln.NetPriceLocal = pr.Input_TotalNetPriceLocal != null ? pr.Input_TotalNetPriceLocal.SetScale(6) : null;
          
          ln.localDisc = pr.LocalDisc;
          ln.maxDict =  pr.ProdMaxDiscount; 
          ln.ThirdParty = pr.isThirdParty != null && pr.isThirdParty ? 'Yes' : '';
          ln.Hware = pr.isHardware != null && pr.isHardware ? 'Yes' : '';
          ln.weight = pr.ProdWeightage; 
          ln.isCntrctDisc = pr.isCntrctDisc ? 'Yes' : '';
          ln.isEAP = pr.isEAP ? 'Yes' : '';
          qteData.add(ln);   
       } 
       
       
           nodeVars = new Map<String,String>();
           if ( dds.interCalc != null ) {
               for ( String label : dds.interCalc.InterCalcVarsMap.keySet() ) {         
                   nodeVars.put(label, dds.interCalc.InterCalcVarsMap.get(label) == null ? 'null' : dds.interCalc.InterCalcVarsMap.get(label));
                }
       }
       
       if ( Score == 'Error' || Score == null ) {
          Score = 'Error';
          errorMsg = dds.Log;
          return;
       }
       
       showScore = true;
       
       directSales = dds.quoteData.DirectSales;
       offering = dds.quoteData.offering;
       offer    = dds.quoteData.offer;
       priceBook = dds.quoteData.PriceBook;
       isSubscrpt = dds.quoteData.Subscription;
       isAmendment = dds.quoteData.Amendment;
       AmendScoringPath = String.valueOf(dds.adjust.scoringScenario); 
       
      //ThirdParty/Hardware Only 
       isThirdPrtHW = dds.quoteData.isThirdPrtHWonly || dds.adjust.scoringScenario == DDSToolMain.AmendScoring.HW3PARTY_ONLY ? true : false; 
        
      if ( (dds.adjust.getExchangeRate() == 1 && dds.adjust.getCombinedUplift() == 1) || isThirdPrtHW )
                showDDSPrice = false;
      else
            showDDSPrice = true;
  
        if ( isThirdPrtHW )  {
         DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly thirdPartyOnly = (DDSToolFinalScore.DDSToolFinalThirdPrtyHWonly) dds.finalScore;

         thirdPrtHWData = new List<ThirdPartyHWLine>();            
         for ( DDSToolFinalScore.ThirdPartyHWLineItem pr : thirdPartyOnly.thirdPrtyNonCntrLineItems ) { 
                 ThirdPartyHWLine ln = new ThirdPartyHWLine();
                 ln.name = pr.name;  
             ln.discntPct = pr.discntPct;
                 ln.maxDisc = pr.maxDisc;
                 ln.appliedDisc = pr.defaultMaxDisc;
                 ln.score = pr.score;
                 ln.weightedScore = pr.weightedScore;
                 thirdPrtHWData.add(ln);
         }
         return;
       }
       
       if ( ! dds.quoteData.quoteExclude.isEmpty() ) {
           showExcl = true;
           excldData = new List<excludeLine>();
           for ( DDSToolQuoteData.ExcludedData prd : dds.quoteData.quoteExclude ) {
               excludeLine ln = new excludeLine();
               ln.APN = prd.APN;
               ln.Product = prd.Product;
               ln.Disc = prd.Disc;
               excldData.add(ln);
           }     
       }
       
       ////the rest is if NOT ThirdParty/Hardware Only
       iterator = new List<String>{'5','4','3','2'};
       node = dds.nodeTree.Node;       
       
       adjustVars = new Map<String,String>();
       for ( String label : dds.adjust.AdjstVarsMap.keySet() ) {         
           adjustVars.put(label, dds.adjust.AdjstVarsMap.get(label) == null ? 'null' : dds.adjust.AdjstVarsMap.get(label));
           ///display TotalNonCntrctProdNetPriceLocal; it is not used in calculations so need to call; place after TotalNonCntrctProdNetPrice
           if ( label == 'TotalNonCntrctProdNetPrice' )
             adjustVars.put('TotalNonCntrctProdNetPriceLocal', dds.adjust.getTotalNonCntrctProdNetPriceLocal() == null ? 'null' : 
                                                               String.valueOf(dds.adjust.getTotalNonCntrctProdNetPriceLocal().setScale(6)));
       }
 
       postPrVars = new Map<String,String>();
       for ( String label : dds.postCalc.PostCalcVarsMap.keySet() ) {         
           postPrVars.put(label, dds.postCalc.PostCalcVarsMap.get(label) == null ? 'null' : dds.postCalc.PostCalcVarsMap.get(label));
        }
        
       Decimal disc = dds.postCalc.getNonCntrctDiscount() * 100 ;
       discount = String.valueOf(disc.SetScale(2))  + '%';
       quoteDiscount = dds.quoteData.UserDisplayQuoteDisc == null ? '' : String.valueOf(dds.quoteData.UserDisplayQuoteDisc.SetScale(2))  + '%';
       if ( dds.quoteData.UserDisplayQuoteDisc == null || (dds.quoteData.UserDisplayQuoteDisc == 0 && dds.postCalc.getNonCntrctDiscount() != 0) )
              showDealDisc = false;
       
       ///Cutoffs
      nodeCutoffs = new Map<String, String>();        
      for (String grade : dds.finalScore.finalCutoffsMap.get('Node Cutoffs').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('Node Cutoffs').get(grade) * 100;
           nodeCutoffs.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('Node Cutoffs').get(grade).setScale(6) +')'));
       }
       
       NormDiscount = new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('Normalized Discount Cutoffs').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('Normalized Discount Cutoffs').get(grade) * 100;
           NormDiscount.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('Normalized Discount Cutoffs').get(grade).setScale(6) +')'));
       }
       AddSubscript = new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('Subscription Impact').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('Subscription Impact').get(grade) * 100;
           AddSubscript.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('Subscription Impact').get(grade).setScale(6) +')'));
       }
       AddCare = new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('Care Impact').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('Care Impact').get(grade) * 100;
           AddCare.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('Care Impact').get(grade).setScale(6) +')'));
       }
       AddPS = new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('PS Impact').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('PS Impact').get(grade) * 100;
           AddPS.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('PS Impact').get(grade).setScale(6) +')'));
       }
       AddGU = new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('GU Impact').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('GU Impact').get(grade) * 100;
           AddGU.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('GU Impact').get(grade).setScale(6) +')'));
       }
       AddMaxDiscts = new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('MAX Discounts Impact').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('MAX Discounts Impact').get(grade) * 100;
           AddMaxDiscts.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('MAX Discounts Impact').get(grade).setScale(6) +')'));
       }
 
       QuoteDiscAdjusted =  new Map<String, String>(); 
       for (String grade : dds.finalScore.finalCutoffsMap.get('Quote Discount Adjusted').keySet()) {
           Decimal cutoff = dds.finalScore.finalCutoffsMap.get('Quote Discount Adjusted').get(grade) * 100;
           QuoteDiscAdjusted.put(grade, String.valueOf(String.valueOf(cutoff.setScale(2)) + '%  (' + dds.finalScore.finalCutoffsMap.get('Quote Discount Adjusted').get(grade).setScale(6) +')'));
       }
              
       HistoricalOppts = new List<histLine>();
       Integer n=1;
       for (DDSToolQuoteData.HistoricalData hst : dds.quoteData.historicalData) { 
          histLine hl = new histLine();
          hl.oppName = hst.OpptyName; 
          hl.WinLost = hst.OpptyWinLost;
          hl.num = n++;
          HistoricalOppts.add(hl);
       }
    }
    
    public class dtLine {
       public String name {get; set;}
       public String type {get; set;}
       public String Category {get; set;}
       public Decimal ListPrice {get; set;}
       public Decimal NetPrice {get; set;}
       public Decimal ListPriceLocal {get; set;}
       public Decimal NetPriceLocal {get; set;}
       public Decimal maxDict {get; set;}  
       public Decimal localDisc {get; set;}
       public Decimal weight {get; set;} 
       public String ThirdParty {get; set;} 
       public String Hware {get; set;}
       public String isCntrctDisc {get; set;}
       public String isEAP {get; set;}
    }
    
    public class ThirdPartyHWLine {
        public String name {get; set;}
        public Integer score {get; set;}
        public Decimal discntPct {get; set;}
        public Decimal maxDisc {get; set;}
        public Decimal appliedDisc {get; set;}
        public Decimal weightedScore {get; set;}
    }
    
    public class histLine {
       public String oppName {get; set;}
       public String WinLost {get; set;}
       public Integer num {get; set;}
    }
    
   public class excludeLine {
          public String APN {get; set;}
          public String Product {get; set;} 
          public Decimal Disc {get; set;}
   }
    
    public PageReference clear() {
        qte = new BigMachines__Quote__c();
        showScore = false;    
        quoteId = null;
        clearVars();
         
        return null;
    }
    
    public void clearVars() {    
        Log = null;
        Score = null;
        showScore = false;
        showDealDisc = true;
        showExcl = false;
        node = null;
        discount=null;
        directSales =null;
        offering=null;
        offer = null;
        priceBook =null;
        isSubscrpt=null;
        errorMsg = null;
        
        qteData=null;
        adjustVars=null;
        nodeVars = null;
        postPrVars=null;
        nodeCutoffs= null;
        
        NormDiscount = null;
        AddSubscript = null;
        AddCare = null;
        AddPS=null;
        AddGU=null;
        AddMaxDiscts=null;
        HistoricalOppts=null;
    }
}