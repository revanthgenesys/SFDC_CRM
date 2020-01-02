/* Mariya Steason - Aug 2018
   Purpose: DDSToolAdjuster is a class in the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public virtual class DDSToolAdjuster {
	
	private DDSToolMain ddsTM;
    private DDSToolQuoteData QuoteData;
 
    private Decimal TotalProdListPrice;  // contarctual and non-contractual
    private Decimal TotalProdNetPrice;
    
    private Decimal TotalNonCntrctProdListPrice;
    private Decimal TotalNonCntrctProdNetPrice;
    private Decimal TotalNonCntrctProdListPriceLocal;
    private Decimal TotalNonCntrctProdNetPriceLocal;
    
    private Decimal TotalCntrctProdNetPrice;
    private Decimal TotalCntrctProdListPrice;

	private Decimal TotalEapProdNetPrice;
    private Decimal TotalEapProdListPrice;

	private Decimal PEV;
    
    private List<DDSToolQuoteData.ProductLine> nonCntrctProducts;
    private List<DDSToolQuoteData.ProductLine> cntrctProducts;
    private List<DDSToolQuoteData.ProductLine> eapProducts;
    
    public Map<String, String> AdjstVarsMap;    
    ///common variables across PureConnect and PureEngage 
    private Decimal ExchangeRate;
    private Decimal CombinedUplift;
    
    public DDSToolMain.AmendScoring scoringScenario = DDSToolMain.AmendScoring.RESCORE; //for Amendments

    public static DDSToolAdjuster getDDSToolAdjuster(DDSToolMain ddsTM) {  
    	DDSToolAdjuster adjst;
        DDSToolQuoteData qd = ddsTM.quoteData; 
   
        if ( qd.Subscription && qd.Amendment ) {
           adjst = new DDSToolAdjstSubscriptAmend();
        }
      	else if ( qd.Subscription && !qd.Amendment ) {
      		adjst = new DDSToolAdjstSubscript();
      	}
      	else 
   		    adjst = new DDSToolAdjstPerpetual();  

		adjst.ddsTM = ddsTM; 
        adjst.QuoteData = ddsTM.quoteData; 
        
        adjst.AdjstVarsMap = new Map<String, String>();
        
        adjst.configureQuoteData();
        
        //different implementation in each specialized subclass
        adjst.setQuoteLinePriceAdjusted();
        
    	return adjst;
    } 
    
    ///common calculations
        
    ///split line items into contractual and non-contractual lists
    public List<DDSToolQuoteData.ProductLine> getNonCntrctProducts() {
    	if ( nonCntrctProducts == null ) {
    		nonCntrctProducts = new List<DDSToolQuoteData.ProductLine>();
    		for (DDSToolQuoteData.ProductLine pr : quoteData.quoteProdLine) {
    		    if ( !pr.isCntrctDisc && !pr.isEAP )
    		      nonCntrctProducts.add(pr);
    		}    		    		
    	}
    	return nonCntrctProducts;
    }
    //contractual products
    public List<DDSToolQuoteData.ProductLine> getCntrctProducts() {
    	if ( cntrctProducts == null ) {
    		cntrctProducts = new List<DDSToolQuoteData.ProductLine>();
    		for (DDSToolQuoteData.ProductLine pr : quoteData.quoteProdLine) {
    		    if ( pr.isCntrctDisc )
    		      cntrctProducts.add(pr);
    		}    		    		
    	}
    	return cntrctProducts;
    } 
    /// EAP (Early Adopter Product)
    public List<DDSToolQuoteData.ProductLine> getEapProducts() {
    	if ( eapProducts == null ) {
    		eapProducts = new List<DDSToolQuoteData.ProductLine>();
    		for (DDSToolQuoteData.ProductLine pr : quoteData.quoteProdLine) {
    		    if ( pr.isEAP )
    		      eapProducts.add(pr);
    		}    		    		
    	}
    	return eapProducts;
    } 

    //ExchangeRate
    public Decimal getExchangeRate() {
    	if ( ExchangeRate == null ) {
    		ExchangeRate = 1 / DDSToolSelector.getConversionRateByIsoCode(quoteData.CurrencyCode, quoteData.CreatedDate); 
    		
    		if (ddsTM.LogLevel > 1) AdjstVarsMap.put('ExchangeRate', String.valueOf(ExchangeRate.setScale(6))); 
    	}   	 
    	return ExchangeRate;
    }
    //CombinedUplift
    public Decimal getCombinedUplift() {
    	if ( CombinedUplift == null ) { 
    		
    		 Date quoteDate = System.today();  		    		 
    		 //Currency_Configuration__c cconf = DDSToolSelector.getCurrcyConfigByPriceBook(quoteData.PriceBook, quoteData.offering, quoteData.CreatedDate);
    		 Currency_Configuration__c cconf = DDSToolSelector.getCurrcyConfigByPriceBook(quoteData.PriceBook, quoteData.offering, quoteDate);
    		 
    		 if ( cconf != null )
    		    CombinedUplift = cconf.Conversion_Rate__c * cconf.Multiplier__c;
    		    
    		 CombinedUplift = CombinedUplift == null || CombinedUplift == 0 ? 1 : CombinedUplift;
    		 
    		 if (ddsTM.LogLevel > 1) AdjstVarsMap.put('CombinedUplift', String.valueOf(CombinedUplift.setScale(6))); 
    	}
    	return CombinedUplift;
    }

   //TotalProdListPrice - node calculation
  public Decimal getTotalProdListPrice() {
        if ( TotalProdListPrice == null ) {       	       	
        	TotalProdListPrice = getTotalNonCntrctProdListPrice() + getTotalCntrctProdListPrice() + getTotalEapProdListPrice();
 
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalProdListPrice', String.valueOf(TotalProdListPrice.setScale(6))); 
        }
        return TotalProdListPrice;
    } 
    //TotalProdNetPrice 
    public Decimal getTotalProdNetPrice() {
        if ( TotalProdNetPrice == null ) {       	       	
        	TotalProdNetPrice = getTotalNonCntrctProdNetPrice() + getTotalCntrctProdNetPrice() + getTotalEapProdNetPrice(); 
 
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalProdNetPrice', String.valueOf(TotalProdNetPrice.setScale(6))); 
        }
        return TotalProdNetPrice;
    } 
    
    //TotalNonCntrctProdListPrice
    public Decimal getTotalNonCntrctProdListPrice() {
        if ( TotalNonCntrctProdListPrice == null ) {       	       	
        	TotalNonCntrctProdListPrice = 0;
            for (DDSToolQuoteData.ProductLine pr : getNonCntrctProducts())   {
		   	  	if (pr.isProduct ) {
		   	  	    if (pr.Input_TotalListPriceAdjusted != null )         	 
		         		 TotalNonCntrctProdListPrice += pr.Input_TotalListPriceAdjusted;
		         	else {
		         		///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': List Price Error. ';
		         		TotalNonCntrctProdListPrice = 0;
		         		break;
		         	}		         	     
		   	  	} 
		    }		    
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalNonCntrctNonEapProdListPrice', String.valueOf(TotalNonCntrctProdListPrice.setScale(6))); 
        }
        return TotalNonCntrctProdListPrice;
    } 

   //TotalNonCntrctProdListPriceLocal
    public Decimal getTotalNonCntrctProdListPriceLocal() {
        if ( TotalNonCntrctProdListPriceLocal == null ) {       	       	
        	TotalNonCntrctProdListPriceLocal = 0;
            for (DDSToolQuoteData.ProductLine pr : getNonCntrctProducts())   {
		   	  	if (pr.isProduct ) {
		   	  	    if (pr.Input_TotalListPriceLocal != null )         	 
		         		 TotalNonCntrctProdListPriceLocal += pr.Input_TotalListPriceLocal;
		         	else {
		         		///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': List Price Error. ';
		         		TotalNonCntrctProdListPriceLocal = 0;
		         		break;
		         	}		         	     
		   	  	} 
		    }		    
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalNonCntrctNonEapProdListPriceLocal', String.valueOf(TotalNonCntrctProdListPriceLocal.setScale(6))); 
        }
        return TotalNonCntrctProdListPriceLocal;
    } 
    ///TotalCntrctProdListPrice
    public Decimal getTotalCntrctProdListPrice() {
        if ( TotalCntrctProdListPrice == null ) {       	       	
        	TotalCntrctProdListPrice = 0;
            for (DDSToolQuoteData.ProductLine pr : getCntrctProducts())   {
		   	  	if (pr.isProduct ) {
		   	  	    if (pr.Input_TotalListPriceAdjusted != null )         	 
		         		 TotalCntrctProdListPrice += pr.Input_TotalListPriceAdjusted;
		         	else {
		         		///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': List Price Error. ';
		         		TotalCntrctProdListPrice = 0;
		         		break;
		         	}		         	     
		   	  	} 
		    }		    
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalCntrctProdListPrice', String.valueOf(TotalCntrctProdListPrice.setScale(6))); 
        }
        return TotalCntrctProdListPrice;
    } 
    //TotalCntrctProdNetPrice
    public Decimal getTotalCntrctProdNetPrice() {
    	if ( TotalCntrctProdNetPrice == null ) {
    		TotalCntrctProdNetPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : getCntrctProducts())  {
		   	  	if (pr.isProduct ) {
		   	  	   if ( pr.Input_TotalNetPriceAdjusted != null )         	       	  
		         	   TotalCntrctProdNetPrice += pr.Input_TotalNetPriceAdjusted;	
		           else {
		           	   	///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': Net Price Error. ';
		         		TotalCntrctProdNetPrice = 0;
		         		break;
		           }
		   	  	}	            
		    }
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalCntrctProdNetPrice', String.valueOf(TotalCntrctProdNetPrice.setScale(6))); 		    
    	}
    	return TotalCntrctProdNetPrice;
    }
    ///TotalEapProdListPrice
    public Decimal getTotalEapProdListPrice() {
        if ( TotalEapProdListPrice == null ) {       	       	
        	TotalEapProdListPrice = 0;
            for (DDSToolQuoteData.ProductLine pr : getEapProducts())   {
		   	  	if (pr.isProduct ) {
		   	  	    if (pr.Input_TotalListPriceAdjusted != null )         	 
		         		 TotalEapProdListPrice += pr.Input_TotalListPriceAdjusted;
		         	else {
		         		///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': List Price Error. ';
		         		TotalEapProdListPrice = 0;
		         		break;
		         	}		         	     
		   	  	} 
		    }		    
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalEapProdListPrice', String.valueOf(TotalEapProdListPrice.setScale(6))); 
        }
        return TotalEapProdListPrice;
    } 
    //TotalEapProdNetPrice
    public Decimal getTotalEapProdNetPrice() {
    	if ( TotalEapProdNetPrice == null ) {
    		TotalEapProdNetPrice = 0;
    		for (DDSToolQuoteData.ProductLine pr : getEapProducts())  {
		   	  	if (pr.isProduct ) {
		   	  	   if ( pr.Input_TotalNetPriceAdjusted != null )         	       	  
		         	   TotalEapProdNetPrice += pr.Input_TotalNetPriceAdjusted;	
		           else {
		           	   	///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': Net Price Error. ';
		         		TotalEapProdNetPrice = 0;
		         		break;
		           }
		   	  	}	            
		    }
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalEapProdNetPrice', String.valueOf(TotalEapProdNetPrice.setScale(6))); 		    
    	}
    	return TotalEapProdNetPrice;
    }

    //TotalNonCntrctProdNetPrice
    public Decimal getTotalNonCntrctProdNetPrice() {
    	if ( TotalNonCntrctProdNetPrice == null ) {
    		TotalNonCntrctProdNetPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : getNonCntrctProducts())  {
		   	  	if (pr.isProduct ) {
		   	  	   if ( pr.Input_TotalNetPriceAdjusted != null )         	       	  
		         	   TotalNonCntrctProdNetPrice += pr.Input_TotalNetPriceAdjusted;	
		           else {
		           	   	///Error, stop execution
		         		ddsTM.Log += pr.Input_Product + ': Net Price Error. ';
		         		TotalNonCntrctProdNetPrice = 0;
		         		break;
		           }
		   	  	}	            
		    }
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalNonCntrctNonEapProdNetPrice', String.valueOf(TotalNonCntrctProdNetPrice.setScale(6))); 		    
    	}
    	return TotalNonCntrctProdNetPrice;
    }
    
   //TotalNonCntrctProdNetPriceLocal - for display on Test page, not used in calculations
    public Decimal getTotalNonCntrctProdNetPriceLocal() {
    	if ( TotalNonCntrctProdNetPriceLocal == null ) {
    		TotalNonCntrctProdNetPriceLocal=0;
    		for (DDSToolQuoteData.ProductLine pr : getNonCntrctProducts())  {
		   	  	if (pr.isProduct ) {
		   	  	   if ( pr.Input_TotalNetPriceLocal != null )         	       	  
		         	   TotalNonCntrctProdNetPriceLocal += pr.Input_TotalNetPriceLocal;			        
		   	  	}	            
		    }
		    if (ddsTM.LogLevel > 0) AdjstVarsMap.put('TotalNonCntrctNonEapProdNetPriceLocal', String.valueOf(TotalNonCntrctProdNetPriceLocal.setScale(6))); 		    
    	}
    	return TotalNonCntrctProdNetPriceLocal;
    }
         
    ///implemented in Subscription and Non Subscription classes
    public virtual void configureQuoteData() {}  //for now implemented in subsciption class
    public virtual void setQuoteLinePriceAdjusted() {}
	public virtual Decimal getPEV() {return null;}
    public virtual Decimal getTotalQuoteNonCntrctListPrice() {return null;}
    
    ///Subscription specific
    public virtual String getBasePackageId()  {return null;}
    public virtual Decimal getBasePackage_ListPrice() {return null;}
    public virtual Decimal getBasePackage_ListPriceLocal() {return null;}
    public virtual Decimal getBasePackage_NetPriceLocal() {return null;}
    public virtual Decimal getBasePackage_NetPrice() {return null;}
    public virtual Decimal getSubscrBasePackagePriceLicPct() {return null;}
     
    /// Subclasses 
    ///SUBSCRIPTION generic
   public virtual class DDSToolAdjstSubscript extends DDSToolAdjuster {    	
   		private Decimal BasePackage_ListPrice;
   		private Decimal BasePackage_NetPrice;
   		private Decimal BasePackage_ListPriceLocal;
   		private Decimal BasePackage_NetPriceLocal;   	    
        private Decimal SubscrBasePackagePriceLicPct;
        private Decimal TotalQuoteNonCntrctListPrice;
        
   	    private String BasePackageId;
   	
   	 ///ensure Contractual Discount flag on Base Package line items is set according to the flag 
   	 // on the Base Package header line 
   	 public override void configureQuoteData() {   	 	
   	 	  Boolean isBasePackageContractual = false;
		  Boolean isBasePackageEAP = false;   	 	  
   	 	  // locate Base Package header
   	 	 for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) { 
   	 	  	 if ( getBasePackageId() != null && pr.prodId == getBasePackageId() ) {
   	 	  	 	isBasePackageContractual = pr.isCntrctDisc;
				isBasePackageEAP = pr.isEAP;
   	 	  	 	break;
   	 	  	 }   	 	  	    
   	 	  }
   	 	  ///set the Contractual and EAP flag on all Base Package line items 
   	 	  if ( getBasePackageId() != null ) {
	   	 	  for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
	   	 	  	  if ( pr.BundleLineId != null && pr.BundleLineId == getBasePackageId() ) {
	   	 	  	     pr.isCntrctDisc = isBasePackageContractual;
					 pr.isEAP = isBasePackageEAP ? true : pr.isEAP;
				  }
	   	 	  } 
   	 	  }	 	  
   	 }
   	 //BasePackageId
     public override String getBasePackageId() {
   	     if ( BasePackageId == null )  {
   	    	for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) { 
		   	 	if ( pr.BundleGrpType != null && pr.BundleGrpType == 'Base Package' && pr.isBundle && pr.BundleLineId == null ) {
		   	  	 		//BasePackageId = pr.BundleId;
		   	 		BasePackageId = pr.prodId; 	   	  	 	
		   	 	    break;
		   	 	}
   	  	     }   	       	
   	      }
   	      return BasePackageId;
   	 } 
   	 //BasePackage_NetPrice
     public override Decimal getBasePackage_NetPrice()   {
   		if ( BasePackage_NetPrice == null )  {
   			  BasePackage_NetPrice=0;
   			  for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) { 
		   	  	    if ( getBasePackageId() != null && pr.prodId == getBasePackageId() && pr.NetUnitPrice1 != null && pr.Input_Quantity != null) {  	  	 		
		   	  	 	 	BasePackage_NetPrice = pr.NetUnitPrice1 * pr.Input_Quantity * getSubscrBasePackagePriceLicPct() * getExchangeRate();   	  	 	 	   		   	  	 			 
		   	  	 	    break;
		   	  	 	}
   	  	 	   }
   	  	 	   if (ddsTM.LogLevel > 1) AdjstVarsMap.put('BasePackage_NetPrice', String.valueOf(BasePackage_NetPrice.setScale(6))); 
   		}
   		return BasePackage_NetPrice;	   			  			
   	}
   	
    // TotalQuoteNonCntrctListPrice
    public override Decimal getTotalQuoteNonCntrctListPrice() {
    	if ( TotalQuoteNonCntrctListPrice == null ) {
    		TotalQuoteNonCntrctListPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : getNonCntrctProducts())  {
    			///remove BasePackage products
    			if ( pr.Input_TotalListPriceAdjusted != null && (pr.BundleLineId == null || pr.BundleLineId != getBasePackageId()) )   
    			    TotalQuoteNonCntrctListPrice += pr.Input_TotalListPriceAdjusted;
    		}
    		if (ddsTM.LogLevel > 1) AdjstVarsMap.put('TotalQuoteNonCntrctNonEAPListPrice', String.valueOf(TotalQuoteNonCntrctListPrice.setScale(6)));
    	}
    	return TotalQuoteNonCntrctListPrice;
    }    
    //Set adjusted prices on each quote product line item
    public virtual override void setQuoteLinePriceAdjusted() {   
        for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {             
             	 ///bundled product items
            if ( pr.BundleLineId != null && pr.BundleLineId == getBasePackageId() ) {                   	                	
                 if ( getBasePackage_ListPrice() != null && getBasePackage_NetPrice() != null && pr.ProdWeightage != null ) {                 	     
                 	     pr.Input_TotalListPriceLocal = (getBasePackage_ListPriceLocal() * pr.ProdWeightage) / 100;
                 	     pr.Input_TotalNetPriceLocal =  (getBasePackage_NetPriceLocal() * pr.ProdWeightage) / 100;
		     			 pr.Input_TotalListPriceAdjusted = (getBasePackage_ListPrice() * pr.ProdWeightage) / 100;
		     			 pr.Input_TotalNetPriceAdjusted  = (getBasePackage_NetPrice() * pr.ProdWeightage) / 100;
                     }
		    }
		    else {		         
		         // all other items
		       	Decimal lstPr = pr.ListPriceYr1 == null || pr.Input_Quantity == null ? 0 : pr.ListPriceYr1 * pr.Input_Quantity;
		         	//Decimal netPr = pr.ExtNetPriceYr1 == null ? 0 : pr.ExtNetPriceYr1;
		       	Decimal netPr = pr.NetUnitPrice1 == null || pr.Input_Quantity == null ? 0 : pr.NetUnitPrice1 * pr.Input_Quantity;
	
		        if ( !pr.isThirdParty )
		                pr.Input_TotalListPriceAdjusted = lstPr / getCombinedUplift();
		        else 
		          	    pr.Input_TotalListPriceAdjusted = lstPr * getExchangeRate();
		          	    
		        pr.Input_TotalListPriceLocal = lstPr;  
		          
	       	   //NET Price 	 
	       	    pr.Input_TotalNetPriceLocal = netPr;	       	       		                
	     	    pr.Input_TotalNetPriceAdjusted = netPr * getExchangeRate(); 
		   } 
       }
    }    
    //BasePackage_ListPrice
    public override Decimal getBasePackage_ListPrice()   {
   		if ( BasePackage_ListPrice == null ) {
   			  BasePackage_ListPrice=0;
   			  for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) { 	
		   	  	 	if ( pr.prodId == getBasePackageId() && pr.Input_Quantity != null && pr.ListPriceYr1 != null ) {            	
		   	  	    	   BasePackage_ListPrice = ((pr.ListPriceYr1 * pr.Input_Quantity) / getCombinedUplift()) * getSubscrBasePackagePriceLicPct();				   	  	 		   	  	 	
		   	  	 	    break;
		   	  	 	}
   	  	       }
   	  	       if (ddsTM.LogLevel > 1 && BasePackage_ListPrice != null) AdjstVarsMap.put('BasePackage_ListPrice', String.valueOf(BasePackage_ListPrice.setScale(6))); 		   	  	       
   		}
   		return BasePackage_ListPrice;
   	 } 

   	//BasePackage_ListPriceLocal  
    public override Decimal getBasePackage_ListPriceLocal()   {
   		if ( BasePackage_ListPriceLocal == null ) {
   			  BasePackage_ListPriceLocal=0;
   			  for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) { 	
		   	  	 	if ( pr.prodId == getBasePackageId() && pr.Input_Quantity != null && pr.ListPriceYr1 != null ) {            	
		   	  	    	   BasePackage_ListPriceLocal = pr.ListPriceYr1 * pr.Input_Quantity  * getSubscrBasePackagePriceLicPct();				   	  	 		   	  	 	
		   	  	 	    break;
		   	  	 	}
   	  	       }
   	  	       if (ddsTM.LogLevel > 1 && BasePackage_ListPriceLocal != null) AdjstVarsMap.put('BasePackage_ListPriceLocal', String.valueOf(BasePackage_ListPriceLocal.setScale(6))); 		   	  	       
   		}
   		return BasePackage_ListPriceLocal;
   	 }  
	 
   	//BasePackage_NetPriceLocal  
    public override Decimal getBasePackage_NetPriceLocal()   {
   		if ( BasePackage_NetPriceLocal == null ) {
   			  BasePackage_NetPriceLocal=0;
   			  for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) { 	
		   	  	 	if ( pr.prodId == getBasePackageId() && pr.Input_Quantity != null && pr.ListPriceYr1 != null ) {            	
		   	  	    	   BasePackage_NetPriceLocal = pr.NetUnitPrice1 * pr.Input_Quantity  * getSubscrBasePackagePriceLicPct();				   	  	 		   	  	 	
		   	  	 	    break;
		   	  	 	}
   	  	       }
   	  	       if (ddsTM.LogLevel > 1 && BasePackage_NetPriceLocal != null) AdjstVarsMap.put('BasePackage_NetPriceLocal', String.valueOf(BasePackage_NetPriceLocal.setScale(6))); 		   	  	       
   		}
   		return BasePackage_NetPriceLocal;
   	 }   
   	 	   	    	   	  	   	    	   	 
   	 //SubscrBasePackagePriceLicPct (SubscrBasePackagePriceMultiplier)
     public override Decimal getSubscrBasePackagePriceLicPct()   {
	    	if ( SubscrBasePackagePriceLicPct == null ) {	    		
	    		SubscrBasePackagePriceLicPct = QuoteData.offering == 'PureConnect' ?
	    		                               Decimal.valueOf(QuoteData.Constants.get('Constant_PureConnectBasePackageLicensePct')) :
	    		                               Decimal.valueOf(QuoteData.Constants.get('Constant_PureEngageBasePackageLicensePct')); 
   		   
	    		if (ddsTM.LogLevel > 0) AdjstVarsMap.put('SubscrBasePackagePriceLicPct', String.valueOf(SubscrBasePackagePriceLicPct.setScale(6)));		
	    	}
	    	return SubscrBasePackagePriceLicPct;
	    }
	//PEV
	public override Decimal getPEV() {
		if ( PEV == null ) {
             PEV = QuoteData.SubscrACV == null ? 0 : QuoteData.SubscrACV * 2.5 * getExchangeRate();

			 if (ddsTM.LogLevel > 0) AdjstVarsMap.put('PEV', String.valueOf(PEV.setScale(6)));	
		}
		return PEV;
	}


  } //END Subscription class

  ///Amendment Class
  public class DDSToolAdjstSubscriptAmend extends DDSToolAdjstSubscript {

       public override void setQuoteLinePriceAdjusted() {
        	super.setQuoteLinePriceAdjusted();
        	determineScoringScenario();       	
        }
       
  	    private  void determineScoringScenario() {
  	       Boolean rescore = false;
  	       Boolean qtyreduced = false;
  	       Boolean hwqtychange = false;
  	       Boolean hwadded = false;

  	      //process Revenue products 
  	      for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
  	      	 if ( !pr.isProduct && !pr.isBundle ) continue;
   	     	      	    
  	      	 if ( pr.SubscrProduct == null || pr.Discount1 != pr.PrevSubscrDisct || pr.AmendQtyChange > 0 )  {
  	      	 	rescore = true;         
  	       	  	break;
  	      	 }
  	      	 else if ( pr.AmendQtyChange < 0 ) {
  	       	  	 qtyreduced = true; 
  	       	  	 break;
  	       	  } 	       	    	      	  
  	      }
  	      
  	      ///no changes to Revenue products, check non-revenue products
  	      if ( !rescore && !qtyreduced ) {
  	      		         
  	         for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
  	         	if ( !pr.isHardware && !pr.isThirdParty && !pr.Input_ProductType.equals('GU') && !pr.Input_ProductType.equals('PS') ) 
  	         	   continue;
       	
                if ( pr.SubscrProduct == null )  {
	  	      	 	hwadded = true;
	  	       	  	pr.isAmended = true;                 
  	         	}  	         	
  	         	else if ( pr.AmendQtyChange < 0) { 
  	         	    qtyreduced = true;
  	         	    break;
  	         	}         	
  	         	else if ( pr.AmendQtyChange > 0) {
  	         	    hwqtychange = true;
  	         	}
                else if ( pr.Discount1 != pr.PrevSubscrDisct ) {
  	         		rescore = true;                  
  	       	  		break;
  	         	}  	         	  	
             } 
          }
  	      ///analyse the results
  	      if ( qtyreduced )
  	         scoringScenario = DDSToolMain.AmendScoring.WILL_NOT_SCORE;
  	      else if ( rescore )
  	         scoringScenario = DDSToolMain.AmendScoring.RESCORE;
  	      else if ( hwadded )
  	         scoringScenario = DDSToolMain.AmendScoring.HW3PARTY_ONLY;
  	      else if ( hwqtychange && QuoteData.AmendOrigDealScore != null )
             scoringScenario = DDSToolMain.AmendScoring.PREVIOUS_SCORE;  
             
          if (ddsTM.LogLevel > 1) AdjstVarsMap.put('Amendment scoring', String.valueOf(scoringScenario));
  	  }
  	
  }

  ///SubClass Perpetual
   public virtual class DDSToolAdjstPerpetual extends DDSToolAdjuster { 
     private Decimal TotalQuoteNonCntrctListPrice;
   
     ///List
     public override void setQuoteLinePriceAdjusted() { 
         for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
           	  pr.Input_TotalListPriceAdjusted = 0; 
           	  pr.Input_TotalNetPriceAdjusted = 0;   
     
               if ( pr.ListPrice != null && pr.Input_Quantity != null )  {
		      		if ( ! pr.Input_ThirdParty )         	     
			           pr.Input_TotalListPriceAdjusted = (pr.ListPrice * pr.Input_Quantity) / getCombinedUplift();		   
		      		else 
		            	pr.Input_TotalListPriceAdjusted = (pr.ListPrice * pr.Input_Quantity) * getExchangeRate();
               }
              //ListPriceUSD
              if ( pr.ListPrice != null )     
		          pr.Input_TotalListPriceLocal = pr.ListPrice * pr.Input_Quantity;
             	     
		      ///Net Price    
		      if ( pr.Input_NetPrice != null ) {
		           pr.Input_TotalNetPriceAdjusted = pr.Input_NetPrice * getExchangeRate();
		           pr.Input_TotalNetPriceLocal = pr.Input_NetPrice;
		      }
         }
    }  
    //PEV
	public override Decimal getPEV() {
		if ( PEV == null ) {
             PEV = QuoteData.PerpetualLicNetValue == null ? 0 : QuoteData.PerpetualLicNetValue * getExchangeRate();

			 if (ddsTM.LogLevel > 0) AdjstVarsMap.put('PEV', String.valueOf(PEV.setScale(6)));	
		}
		return PEV;
	}
   // TotalQuoteNonCntrctListPrice   
   public override Decimal getTotalQuoteNonCntrctListPrice() {
    	if ( TotalQuoteNonCntrctListPrice == null ) {
    		TotalQuoteNonCntrctListPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : getNonCntrctProducts())  {
    			if ( pr.Input_TotalListPriceAdjusted != null )
    			  TotalQuoteNonCntrctListPrice += pr.Input_TotalListPriceAdjusted;
    		}
    		if (ddsTM.LogLevel > 1) AdjstVarsMap.put('TotalQuoteNonCntrctNonEAPListPrice', String.valueOf(TotalQuoteNonCntrctListPrice.setScale(6)));
    	}
    	return TotalQuoteNonCntrctListPrice;
     }
 }

}