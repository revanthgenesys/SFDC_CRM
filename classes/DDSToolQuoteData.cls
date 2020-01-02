/* Mariya Steason - Aug 2018
   Purpose: DDSToolQuoteData is a class in the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public class DDSToolQuoteData {
	
	private DDSToolMain ddsTM;
	
	///Quote Header
	public String QuoteNumber; //BigMachines__Quote__r.Quote_Number__c
	public Date CreatedDate; //BigMachines__Quote__r.CreatedDate
	public Date CloseDate; // BigMachines__Quote__r.Opportunity_Close_Date__c
    public String AccountId;  //BigMachines__Quote__r.End_User_ID__c
    public String SoldToId;  ///BigMachines__Quote__r.Sold_To_Name__c; 
    public String Industry; //BigMachines__Quote__r.End_User_ID__r.Industry__c
    public String Vertical; // BigMachines__Quote__r.End_User_ID__r.Industry
    public String offeringType; //BigMachines__Quote__r.BigMachines__Opportunity__r.Lead_Offer__c, before Jan 2019: BigMachines__Quote__r.Offering_Type__c, 
    public String CurrencyCode;  //CurrencyIsoCode
    public String OpptyType;    //BigMachines__Quote__r.BigMachines__Opportunity__r.Type
    public String PriceBook;  //BigMachines__Quote__r.New_Price_Book__c
    public String Region; //BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c
    public String SoldToCountry; //BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Name
    public String SubRegion; //BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.RU__c
    public String SubSubRegion; //BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.SubRU__c
    public Boolean Subscription; //  FROM oppty Lead Offer
    public Boolean Amendment; // parsed BigMachines__Quote__r.Order_Type__c = Amend in amendments
    public String OpptyId;    //BigMachines__Quote__r.BigMachines__Opportunity__c 
    public String OpptySource; //BigMachines__Quote__r.BigMachines__Opportunity__r.Partner_Opportunity_Source__c
    public Decimal CareRate; //BigMachines__Quote__r.Genesys_Care_Rate__c
    public String CareRateOveride; //BigMachines__Quote__r.Genesys_Care_Overide__c - Need to convert to Decimal from text Percentage
    public Decimal CareDefaultContrRate; //BigMachines__Quote__r.Genesys_Care_Default_Pricing_Percentage__c;
    public Decimal CareCustmrContrRatePEng; //BigMachines__Quote__r.End_User_ID__r.FYM_Rate__c - PureEngage, Percentage 
    public Decimal CareCustmrContrRatePCnct; //BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Rate__c - PureConnect, Percentage
    public Boolean isSeparateCareQuote;    //Require_Separate_Quote_for_Genesys_Care__c
	public Decimal CareRateSeparateQuote;  //BigMachines__Quote__r.Reduced_Genesys_Care__c
	public Date CareCustmrContrRatePCnctStart;   ///BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Effective_Date__c, CareCustomerContrRatePCnct Start Date
    public Date CareCustmrContrRatePCnctSEnd;  ///BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Expiration_Date__c, CareCustomerContrRatePCnct End Date
    public Decimal CareDurationMnths;  //BigMachines__Quote__r.Order_Numb_of_Maint_Months__c
    public Decimal UserDisplayQuoteDisc; //BigMachines__Quote__r.Total_Discount_Genesys_and_Third_Party__c -- percentage
    public Decimal CustomerContrRate;  //BigMachines__Quote__r.Customer_Contractual_Rate__c -- percentage
    public Decimal AmendOrigDealScore;  //BigMachines__Quote__r.Amendment_For__r.Quote__r.Deal_Score__c
    public Decimal PerpetualLicNetValue;  //BigMachines__Quote__r.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c
	public Decimal SubscrACV;             //BigMachines__Quote__r.Annual_Contract_Value_1__c
	 
	public String offer;               //BigMachines__Quote__r.Offer__c ; different than offering, example PureBridge - Genesys PureBridge
    
    public Boolean isCareContrct; // is Care under the Contractual Discount

    public Boolean DirectSales; //true if SoldTo = EndUser, otherwise false
    public Boolean isThirdPrtHWonly;  //true if all line items are ThirdParty or Hardware
    public String offering;  //parsed BBigMachines__Quote__r.Offering_Type__c
	public Boolean pureBridgeOffer; //calculated
    

    public List<ProductLine> quoteProdLine;  //ALL line items except One Time charges and Care
    public List<ProductLine> careProd;
    
    public List<HistoricalData> historicalData;  ///historical opportunities, header and agregate price
    public List<LifeTimeLicensePurchase> historicalPurchase; //historical purchases by line item where Solution Category is not null
    public Map<String, String> Constants;
    public Map<String, String> PureBridgeRemoveProds;
    public List<ExcludedData> quoteExclude;
         
   public class ProductLine { 
   	    public String prodId;
        public String Input_Product; // BigMachines__Product__r.Name        	    
	    public String ProductDescr;
	    public String ProductCategory; //prd.BigMachines__Product__r.Product_Category1__c;
	    public String Input_ProductType; //BigMachines__Product__r.Type__c Hardware, Software, etc
	    public Boolean Input_ThirdParty; //BigMachines__Product__r.Third_Party__c == 'TRUE', true
	    public Decimal Input_Quantity; //BigMachines__Quantity__c, Decimal
	    public Decimal UnitListPrice_USD; //BigMachines__Product__r.NG5_NA_USD_Price__c - 
	    public Decimal Input_NetPrice; // Ext_Net_Price__c    - final price - total after discounts, replaced with New_Ext_Net_Price_USD__c ??
	    public Decimal Input_ExtListPrice; // Ext_List__c     -- before discounts, replaced with Equivalent_NA_New_List_Price__c
        public Decimal ProdWeightage;  /// Weightage__c, product % in the BasePackage
        public Decimal ProdMaxDiscount; //BigMachines__Product__r.Product_Specific_Discount__c, Percentage
        public String BundleId;         ///Bundle__c
        public String BundleLineId;     //Bundle_Line__c
        public String BundleGrpType;  //Bundle__r.Group_Type__c
        public String BundleName;  //Bundle__r.Name
        public String PartnerMarginCateg; //BigMachines__Product__r.Partner_Margin_Category__c
				public String Maturity;          // BigMachines__Product__r.Maturity__c
        public Decimal ListPrice;       //List_Price_1__c 
        public Decimal ListPriceYr1;      //List_Price_1__c;
        public Decimal NetUnitPrice1;    ///Net_Unit_Price_1__c
        public String UnitOfMeasure;    //BigMachines__Product__r.Unit_of_Measure__c
        public Boolean isCntrctDisc;     ///Dropped_Products__c
        public String SubscrProduct;   //Subscription_Product__c, used in Amendments       
        public Decimal AmendQty;        //Subscription_Product__r.Quantity__c 
        public Decimal Discount1;      //Discount_1__c, used in Amendments
        public Decimal PrevSubscrDisct;  //Subscription_Product__r.Disc__c, used in Amendments
        public Decimal LocalDisc;        //Total_Discount__c
        
	   ///calculated 
	    public Boolean isProduct; // indicator to treat this line as Product for calculations
	    public Boolean isHardware; /// Hardware indicator
	    public Boolean isThirdParty; /// Third Party Product excluding Hardware
	    public Boolean isBundle;  // bundle
		  public Boolean isEAP;     //Early Adopter Product, derived from Maturity
	    public Decimal Input_TotalListPriceAdjusted; // set in Adjuster
	    public Decimal Input_TotalListPriceLocal; // set in Adjuster
	    public Decimal Input_TotalNetPriceLocal; // set in Adjuster	     
        public Decimal Input_TotalNetPriceAdjusted;  // set in Adjuster 
        public Boolean isAmended = false; // set in Adjuster for amendments 
        public Decimal AmendQtyChange;   //Amendments   
   }

   ///Historical Opportunities, header
   public class HistoricalData {
   	    public String OpptyId;
   	    public String OpptyName;
   	    public Date OpptyCloseDate;
   	    public String OpptyOfferingType;
   	    public String OpptyWinLost;
   	    public Decimal NewExtNetPriceUSD;
   }
   
   //Historical WON Opportunities, product lines
   public class LifeTimeLicensePurchase {
   	    public String prodId;
	    public String Input_SolutionCategory;  //BigMachines__Product__r.Taxonomy_Solution_Category__c - Product Taxonomy Solution Category      
        public String Input_Product; // BigMachines__Product__r.Name        	    
	    public String Input_ProductType; 
	    public Decimal Input_NetPrice; // Ext_Net_Price__c - final price - total after discounts, replaced with New_Ext_Net_Price_USD__c ??
   }
   
   //product lines removed from scoring
   public class ExcludedData {
   	  public String APN;
   	  public String Product; 
   	  public Decimal Disc;
   }
   
   public static DDSToolQuoteData getQuoteDataFromQuote(DDSToolMain ddsTM, String quoteId) {
   	
   	  if ( quoteId == null | String.isBlank(quoteId) ) {
   	     return null;
   	  }

   	  DDSToolQuoteData QuoteData = new DDSToolQuoteData();
   	  QuoteData.ddsTM = ddsTM;
   	        	
   	  List<BigMachines__Quote_Product__c> qtprds = DDSToolSelector.quoteProductsByQuoteId(quoteId);
   	  if ( qtprds.isEmpty() )
   	     return null;
   	 
   	   /// offering
   	  quoteData.offeringType = qtprds[0].BigMachines__Quote__r.Offering_Type__c == null ? 'PureEngage' : qtprds[0].BigMachines__Quote__r.Offering_Type__c;  
   	    	                           
      if (quoteData.offeringType != null && quoteData.offeringType.startsWith('PureEngage'))
			quoteData.offering = 'PureEngage';
	  else if (quoteData.offeringType != null && quoteData.offeringType.startsWith('PureConnect'))
			quoteData.offering = 'PureConnect';
	  else	{
            return null;
	  }   	     	  
      // Populate Quote Header variables from the first Product Line sinse they are same for each line
   	  quoteData.QuoteNumber = qtprds[0].BigMachines__Quote__r.Quote_Number__c;
   	  quoteData.CloseDate   = qtprds[0].BigMachines__Quote__r.Opportunity_Close_Date__c; 
   	  quoteData.CreatedDate = Date.valueOf(qtprds[0].BigMachines__Quote__r.CreatedDate); 
   	  quoteData.AccountId   = qtprds[0].BigMachines__Quote__r.End_User_ID__c;
   	  quoteData.SoldToId    = qtprds[0].BigMachines__Quote__r.Sold_To_Name__c;
   	  quoteData.Industry    = qtprds[0].BigMachines__Quote__r.End_User_ID__r.Industry__c;
   	  quoteData.Vertical    = qtprds[0].BigMachines__Quote__r.End_User_ID__r.Industry;   	  
   	  quoteData.CurrencyCode = qtprds[0].CurrencyIsoCode;
   	  quoteData.PriceBook    = qtprds[0].BigMachines__Quote__r.New_Price_Book__c;
   	  quoteData.SoldToCountry = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Name;
   	  quoteData.Region       = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c;
   	  quoteData.SubRegion    = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.RU__c;
   	  quoteData.SubSubRegion = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.SubRU__c; // not used
   	  quoteData.OpptyType    = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__r.Type;
   	  quoteData.OpptyId      = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__c;
   	  quoteData.OpptySource  = qtprds[0].BigMachines__Quote__r.BigMachines__Opportunity__r.Partner_Opportunity_Source__c;
   	  quoteData.offer        = qtprds[0].BigMachines__Quote__r.Offer__c; 
   	  quoteData.Subscription =  quoteData.offeringType.contains('Subscription') ? true : false;
   	  quoteData.Amendment    = qtprds[0].BigMachines__Quote__r.Order_Type__c != null && 
   	                           qtprds[0].BigMachines__Quote__r.Order_Type__c.startsWith('Amend') ? true : false;
   	                           
      quoteData.AmendOrigDealScore = qtprds[0].BigMachines__Quote__r.Amendment_For__r.Quote__r.Deal_Score__c;  	                           
   	    	  
   	  quoteData.CustomerContrRate = qtprds[0].BigMachines__Quote__r.Customer_Contractual_Rate__c;
   	  //Care rates
   	  quoteData.CareRateOveride = qtprds[0].BigMachines__Quote__r.Genesys_Care_Overide__c; // Text field
      //Care Percentages 
   	  quoteData.CareRate                      = qtprds[0].BigMachines__Quote__r.Genesys_Care_Rate__c;
   	  quoteData.CareCustmrContrRatePEng       = qtprds[0].BigMachines__Quote__r.End_User_ID__r.FYM_Rate__c;
   	  quoteData.CareCustmrContrRatePCnct      = qtprds[0].BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Rate__c;                 
   	  quoteData.CareDefaultContrRate          = qtprds[0].BigMachines__Quote__r.Genesys_Care_Default_Pricing_Percentage__c;
   	  quoteData.CareDurationMnths             = qtprds[0].BigMachines__Quote__r.Order_Numb_of_Maint_Months__c;
   	  //PureConnect care effective dates
   	  quoteData.CareCustmrContrRatePCnctStart = qtprds[0].BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Effective_Date__c;
   	  quoteData.CareCustmrContrRatePCnctSEnd  = qtprds[0].BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Expiration_Date__c; 
	  quoteData.isSeparateCareQuote           = qtprds[0].BigMachines__Quote__r.Require_Separate_Quote_for_Genesys_Care__c;
	  quoteData.CareRateSeparateQuote         = qtprds[0].BigMachines__Quote__r.Reduced_Genesys_Care__c;
   	  quoteData.PerpetualLicNetValue          = qtprds[0].BigMachines__Quote__r.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c;
      quoteData.SubscrACV                     = qtprds[0].BigMachines__Quote__r.Annual_Contract_Value_1__c;

   	  if ( quoteData.Subscription )
   	       quoteData.UserDisplayQuoteDisc = qtprds[0].BigMachines__Quote__r.Total_Discount_Genesys_and_Third_Party__c;
   	  else
   	  	   quoteData.UserDisplayQuoteDisc = qtprds[0].BigMachines__Quote__r.Total_Discount_Genesys_Products_Only__c;
  
	  //Direct/Indirect 
	  quoteData.DirectSales = qtprds[0].BigMachines__Quote__r.End_User_ID__c == qtprds[0].BigMachines__Quote__r.Sold_To_Name__c ? true : false;
 	  //Care under contractual discount
 	  quoteData.isCareContrct = qtprds[0].BigMachines__Quote__r.Genesys_Care_Contractual_Rate__c != null && qtprds[0].BigMachines__Quote__r.Genesys_Care_Contractual_Rate__c ? true : false;
      //PureBridge
      quoteData.pureBridgeOffer = (qtprds[0].BigMachines__Quote__r.Lever__c != null || (quoteData.offer != null && quoteData.offer == 'PureBridge - Genesys PureBridge')) ? true : false;

      ///END Header        
      
   	  ///Get Constants
   	  QuoteData.Constants = new Map<String, String>();
      for ( DDS_Tool_Constants__c cnst : DDSToolSelector.getConstants(quoteData.offering) ) {
     	  	  QuoteData.Constants.put(cnst.Variable_Name__c, cnst.Variable_Value__c);
      }
      
      ///Products to Remove if Offer = PureBridge - Genesys PureBridge
      QuoteData.PureBridgeRemoveProds = new Map<String, String>();
      if ( quoteData.pureBridgeOffer ) {
     	  for ( DDS_Tool_Constants__c prod : DDSToolSelector.getPureBridgeProds() ) 
     	  	  QuoteData.PureBridgeRemoveProds.put(prod.Variable_Name__c, prod.Variable_Value__c); 		 
      }	
          	     	  
   	  quoteData.quoteProdLine = new List<ProductLine>();
   	  quoteData.careProd = new List<ProductLine>();
   	  quoteData.quoteExclude = new List<ExcludedData>();

   	  //LOAD PRODUCT LINES.
   	  // All product types except Care stored in list quoteData.quoteProdLine
   	  //Care stored in list quoteData.careLine
   	  for ( BigMachines__Quote_Product__c prd : qtprds ) {
   	  	  ///remove products defined in Constants if offer is PureBridge - Genesys PureBridge and 
   	  	  // discount >= the defined value OR quantity is >= the defined value
   	  	  if ( quoteData.pureBridgeOffer && QuoteData.PureBridgeRemoveProds.containsKey(prd.BigMachines__Product__r.APN_Number__c) ) {  	  	       
   	  	       String criteriaStr = QuoteData.PureBridgeRemoveProds.get(prd.BigMachines__Product__r.APN_Number__c);
   	  	       Decimal criteriaVal = Decimal.valueOf( criteriaStr.substring(0, criteriaStr.length()-1) );
   	  	       if ( (criteriaStr.endsWith('%') && prd.Total_Discount__c >= criteriaVal) ||
   	  	            (criteriaStr.endsWith('X') && prd.BigMachines__Quantity__c >= criteriaVal) ) {
        	
	   	  	       DDSToolQuoteData.ExcludedData remprd = new DDSToolQuoteData.ExcludedData();
	   	  	       remprd.APN = prd.BigMachines__Product__r.APN_Number__c;
				   remprd.Product = prd.BigMachines__Product__r.Description;
				   remprd.Disc = criteriaStr.endsWith('%') ? prd.Total_Discount__c : prd.BigMachines__Quantity__c;
				   
	   	  	  	   quoteData.quoteExclude.add(remprd);   	  	  	  
	   	  	  	   continue; 
   	  	       }
   	  	  }
 
	   	  DDSToolQuoteData.ProductLine productLine = new DDSToolQuoteData.ProductLine(); 
   	  	   	 
	   	  productLine.prodId                 = prd.Id;  	  
    	  productLine.ProductCategory        = prd.BigMachines__Product__r.Product_Category1__c;
	   	  productLine.Input_ProductType      = prd.BigMachines__Product__r.Type__c == null ? '' : prd.BigMachines__Product__r.Type__c;
	   	  productLine.Input_ThirdParty       = prd.BigMachines__Product__r.Third_Party__c != null && prd.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('True') ? true : false;
	   	  productLine.Input_Product          = prd.BigMachines__Product__r.Name == null ? '' : prd.BigMachines__Product__r.Name;
		  productLine.Maturity               = prd.BigMachines__Product__r.Maturity__c;
	   	  productLine.ProductDescr           = prd.BigMachines__Product__r.Description;
	   	  productLine.Input_Quantity         = prd.BigMachines__Quantity__c;
	   	  productLine.Input_NetPrice         = prd.Ext_Net_Price__c; 
	   	  productLine.Input_ExtListPrice     = prd.Ext_List__c; 
	   	  productLine.LocalDisc              = prd.Total_Discount__c; 
	   	  productLine.UnitListPrice_USD      = prd.BigMachines__Product__r.NG5_NA_USD_Price__c; //used for 3rd Party Products
	   	  productLine.UnitOfMeasure          = prd.BigMachines__Product__r.Unit_of_Measure__c;
	   	  productLine.ProdMaxDiscount        = prd.BigMachines__Product__r.Product_Specific_Discount__c; /// Percentage, need to / 100;
	   	  productLine.BundleId               = prd.Bundle__c;
          productLine.BundleLineId           = prd.Bundle_Line__c;
          productLine.BundleName             = prd.Bundle__r.Name;
          productLine.BundleGrpType          = prd.Bundle__r.Group_Type__c;
          productLine.ProdWeightage          = prd.Weightage__c;
          productLine.PartnerMarginCateg     = prd.BigMachines__Product__r.Partner_Margin_Category__c;
          productLine.ListPrice              = prd.List_Price__c;   //NON subscriptions local ListPrice = List_Price__c * Qty
          productLine.ListPriceYr1           = prd.List_Price_1__c;   //for subscriptions local ListPrice = List_Price_1__c * Qty
          productLine.NetUnitPrice1          = prd.Net_Unit_Price_1__c;
          productLine.isCntrctDisc           = prd.Dropped_Products__c;
          productLine.SubscrProduct          = prd.Subscription_Product__c; //Amendments
          productLine.AmendQty               = prd.Subscription_Product__r.Quantity__c; //Amendments
          productLine.Discount1              = prd.Discount_1__c == null ? 0 : prd.Discount_1__c;  //Amendments
          productLine.PrevSubscrDisct        = prd.Subscription_Product__r.Disc__c == null ? 0 : prd.Subscription_Product__r.Disc__c; //Amendments

	   	  if ( productLine.Input_ProductType != null ) {
	   	  	
	   	  	  if (productLine.Input_ProductType.equals('Bundle') && productLine.BundleGrpType != null && productLine.BundleGrpType == 'Use Case')
	   	  	         continue;
	   	  	 
	   	  	  if (productLine.Input_ProductType == 'Genesys Care' || productLine.Input_ProductType == 'Flex Care' )  {
	           		 quoteData.careProd.add(productLine);
	           		 continue;
	   	  	  }
	   	  	  
	   	  	  //Set flags
	   	      productLine.isProduct =  productLine.Input_ProductType.equals('Product') && !productLine.Input_ThirdParty ? true : false; //Exclude all other types like HW, 3rd Party, etc
	   	      productLine.isHardware = productLine.Input_ProductType.equals('Product - Hardware') ? true : false;	   	      
	   	      productLine.isThirdParty = productLine.Input_ThirdParty && productLine.Input_ProductType.equals('Product') ? true : false;
	   	      productLine.isBundle = productLine.Input_ProductType.equals('Bundle')	? true : false;   
              productLine.isEAP    = productLine.Maturity != null && productLine.Maturity.equals('Early Adopter') && !productLine.isCntrctDisc ? true : false;
              
              if ( productLine.AmendQty != null && productLine.Input_Quantity != null )
  	      	       productLine.AmendQtyChange = productLine.Input_Quantity - productLine.AmendQty;
  	      	  else
  	      	       productLine.AmendQtyChange = 0;
  	      	     
	   	      if ( productLine.isCntrctDisc != null && !productLine.isCntrctDisc && !productLine.isEAP &&
	   	           (productLine.isProduct || productLine.isBundle || productLine.Input_ProductType.equals('GU') || productLine.Input_ProductType.equals('PS')) )
	   	         quoteData.isThirdPrtHWonly = false;
	   	      else if ( quoteData.isThirdPrtHWonly == null && (productLine.isHardware || productLine.isThirdParty) )
	   	         quoteData.isThirdPrtHWonly = true;
	   	  }

          quoteData.quoteProdLine.add(productLine);
   	  }
   	  //if no line items
   	  quoteData.isThirdPrtHWonly = quoteData.isThirdPrtHWonly == null ? false : quoteData.isThirdPrtHWonly;
   	    
   	// Load Historical Data   	
   	  if ( quoteData.AccountId == null || String.isBlank(quoteData.AccountId) ) {
   	  	 ddsTM.Log += 'Missing Quote Account';
   	     return null;
   	  }   	  
   	  List<BigMachines__Quote_Product__c> historyprods = DDSToolSelector.historicalQuoteDataByAccountId(quoteData.AccountId, quoteData.OpptyId);
   	 
   	  /// aggregate product prices by opportunity
   	  quoteData.historicalData = new List<HistoricalData>();
   	  
   	  String privOpptId='';
   	  DDSToolQuoteData.HistoricalData history;  
   	  for ( BigMachines__Quote_Product__c prd : historyprods ) {
   	  	
   	  	  String oppid = prd.BigMachines__Quote__r.BigMachines__Opportunity__c;   	  	  
   	  	  if ( oppid == null || String.isBlank(oppid)) 
   	  	      continue;
   	  	  
   	  	  if ( oppid != privOpptId )  { 
   	  	  	  if ( history != null )
   	  	  	     quoteData.historicalData.add(history);
   	  	  	     
   	      	  history = new DDSToolQuoteData.HistoricalData(); 
   	  	  }
 	  	     	  	  
   	  	  history.OpptyId    = prd.BigMachines__Quote__r.BigMachines__Opportunity__c;
   	      history.OpptyName  = prd.BigMachines__Quote__r.BigMachines__Opportunity__r.Name;
   	      history.OpptyCloseDate = prd.BigMachines__Quote__r.Opportunity_Close_Date__c;
   	      history.OpptyWinLost  = prd.BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c; 

   	      if ( prd.New_Ext_Net_Price_USD__c != null ) {
   	      	   history.NewExtNetPriceUSD = history.NewExtNetPriceUSD == null ? 0 : history.NewExtNetPriceUSD;
   	           history.NewExtNetPriceUSD += prd.New_Ext_Net_Price_USD__c;
   	      }   	         	
   	      privOpptId = history.OpptyId; 
   	  }    	  
   	  /// add last history record
   	  if ( history != null )
   	  	  	quoteData.historicalData.add(history);
   	  	  		  	  	
   	  ///Lifetime License Purchases
      quoteData.historicalPurchase = new List<LifeTimeLicensePurchase>();
   	  for ( BigMachines__Quote_Product__c prd : historyprods ) {
   	  	 if ( prd.BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c != null && 
   	  	      prd.BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c == 'Won' &&
   	  	      prd.BigMachines__Product__r.Type__c != null && prd.BigMachines__Product__r.Type__c == 'Product' &&
   	  	      prd.New_Ext_Net_Price_USD__c != null)  { ///CONFIRM!!
   	  	      
   	  	     LifeTimeLicensePurchase purchase = new LifeTimeLicensePurchase();
   	  	     purchase.prodId                 = prd.Id;  	  
	   	  	 purchase.Input_Product          = prd.BigMachines__Product__r.Name;  
	   	  	 purchase.Input_SolutionCategory = prd.BigMachines__Product__r.Product_Category1__c;
	   	     purchase.Input_ProductType      = prd.BigMachines__Product__r.Type__c;
	   	     purchase.Input_NetPrice         = prd.New_Ext_Net_Price_USD__c;   
	   	    
	   	     quoteData.historicalPurchase.add(purchase);	   	      	     
   	  	 }
   	  }
   	  return quoteData;
   }
   
}