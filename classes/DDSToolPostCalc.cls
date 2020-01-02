public virtual class DDSToolPostCalc {

	private DDSToolMain ddsTM;
    private DDSToolQuoteData QuoteData;  
    private DDSToolAdjuster adjust;
    private DDSToolInterCalc InterCalc;
	
    // common variables across PureConnect and PureEngage
    private Decimal nonCntrctDiscount;
    private Decimal UserDisplDiscAdjuster;
    private Decimal OriginalListPrice;    
    private Decimal SubscriptionShare;
    private Decimal ThirdPartyListPrice;				
	private Decimal ThirdPartyNetPrice;				
	private Decimal ThirdPartyDiscount;
	private Decimal HardwareListPrice;
    private Decimal HardwareNetPrice;
    private Decimal HardwareDiscount;

	private Decimal AnnualCareRateDiff; 
	private Decimal SelectedCarePercentage;
    private Decimal LifetimeCareRateDiff; 
    private Decimal CareRateAmount;
    private Decimal PSDiff;
    
    private Decimal MaxHardWareDiff;
    private Decimal MaxThirdPartyDiff;
    private Decimal MaxBundleDiff;
    private Decimal MaxLicenseDiff;
    private Decimal DealRegistrDisc;
    private Decimal PartnerContractualDiscount;
    private Decimal LocalNonContractualDiscount;
    
    public Map<String, String> PostCalcVarsMap;
     
    public static DDSToolPostCalc getDDSToolPostCalc(DDSToolMain ddsTM) {
		DDSToolPostCalc pc;

        DDSToolQuoteData qd = ddsTM.quoteData;
       	if (qd.offering == 'PureEngage') {
   		    pc = new DDSToolPostCalcPureEngage();
       	} else if (qd.offering == 'PureConnect') {
   		    pc = new DDSToolPostCalcPureConnect();
       	}
       	pc.ddsTM = ddsTM;
       	pc.QuoteData = ddsTM.quoteData;
       	pc.adjust = ddsTM.adjust;
       	pc.InterCalc = ddsTM.interCalc;
        pc.PostCalcVarsMap = new  Map<String, String>();
        
    	return pc;
    } 
    ///common variables methods
    public Decimal getPredictedCareRateByOffer(String offer, String careType, Decimal price) {
    	Decimal ClusterCareCoeff;
    	Decimal InterceptCare=0;
    	Decimal SlopePriceCare=0;
        List<Decimal> allclustrs = new List<Decimal>();
  
    	List<DDS_Tool_Constants__c> coeff = DDSToolSelector.getCoeffByType(offer, careType);
        for ( DDS_Tool_Constants__c cf : coeff ) {
    		 if ( cf.Cluster__c != null && String.isNotBlank(cf.Cluster__c) ) {
    			 if ( cf.Cluster__c.ToUpperCase() == InterCalc.getCluster().ToUpperCase() )
    				  ClusterCareCoeff = cf.Coefficient_Value__c;

 				 allclustrs.add(cf.Coefficient_Value__c);
    		 }
    		 else if ( cf.Variable_Name__c == 'Intercept')
    				InterceptCare = cf.Coefficient_Value__c;
    		 else if ( cf.Variable_Name__c == 'LN_Price')
    				SlopePriceCare = cf.Coefficient_Value__c;    				   
    	}	
    	///if Cluster not found use average	productLine.Input_ProductType != null
    	if ( ClusterCareCoeff == null )  {
    		Decimal total=0;
    		if ( allclustrs.size() > 0 )  {
	    		for (Decimal clcoef : allclustrs)
	    			total += clcoef;
	    				
	    		ClusterCareCoeff = total/allclustrs.size();  
    		}
    		else
    			ClusterCareCoeff = 0;  				
    	}         
    	return InterceptCare +
    		   SlopePriceCare * math.log(price) +
    		   ClusterCareCoeff;    			
    }
    //SubscriptionShare -- share of products in the total quote List price --- SAME as adjust.getTotalQuoteNonCntrctListPrice(), should be 1 always
    public Decimal getSubscriptionShare() {
    	if ( SubscriptionShare == null ) {  		
    		if ( QuoteData.Subscription && adjust.getTotalQuoteNonCntrctListPrice() > 0 ) {
    			Decimal shareTotal=0;
    			for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
                   if ( pr.Input_TotalListPriceAdjusted != null && (pr.BundleLineId == null || pr.BundleLineId != adjust.getBasePackageId()) )  
    					shareTotal += pr.Input_TotalListPriceAdjusted;
    			}
    			SubscriptionShare = shareTotal / adjust.getTotalQuoteNonCntrctListPrice();
    		} 
    		else
    		   SubscriptionShare = 0;
    		   
    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('SubscriptionShare', String.valueOf(SubscriptionShare.setScale(6)));
    	}
    	return SubscriptionShare;
    }
    //MaxBundleDiff
    public Decimal getMaxBundleDiff() {
    	if ( MaxBundleDiff == null ) {
    		MaxBundleDiff=0;		 
	        for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
	    		if ( pr.ProdMaxDiscount != null && pr.prodId == adjust.getBasePackageId() )  {	    				
	    			Decimal maxDiscDelta = (1 - (adjust.getBasePackage_NetPrice() / adjust.getBasePackage_ListPrice())) - (pr.ProdMaxDiscount / 100);
	    			if ( maxDiscDelta > 0 )
	    			   MaxBundleDiff -= maxDiscDelta * adjust.getBasePackage_ListPrice();	    			   
	    			break;
	    		}    			
	    	}    	  
	   	   	if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('MaxBundleDiff', String.valueOf(MaxBundleDiff.setScale(6)));
    	}
    	return MaxBundleDiff;
    }    
    //ThirdPartyListPrice
    public Decimal getThirdPartyListPrice()   {
    	if ( ThirdPartyListPrice == null )  {
    	 	ThirdPartyListPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
    			if ( pr.isThirdParty )
    				ThirdPartyListPrice += pr.Input_TotalListPriceAdjusted;
    		}
    		
    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('ThirdPartyListPrice', String.valueOf(ThirdPartyListPrice.setScale(6)));
    	}
    	return ThirdPartyListPrice;
   }
   //ThirdPartyNetPrice
   public Decimal getThirdPartyNetPrice() {
    	if ( ThirdPartyNetPrice == null )  {
    	 	ThirdPartyNetPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
    			if ( pr.isThirdParty )
    				ThirdPartyNetPrice += pr.Input_TotalNetPriceAdjusted;
    		}
    		    		
    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('ThirdPartyNetPrice', String.valueOf(ThirdPartyNetPrice.setScale(6)));
    	}
    	return ThirdPartyNetPrice;
    }
    //ThirdPartyDiscount
    public Decimal getThirdPartyDiscount() {
    	if ( ThirdPartyDiscount == null )  {
    		ThirdPartyDiscount = 0;
    	 	if ( getThirdPartyListPrice() > 0 )
    	 		ThirdPartyDiscount = 1 - (getThirdPartyNetPrice() / getThirdPartyListPrice());
 
    	 	if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('ThirdPartyDiscount', String.valueOf(ThirdPartyDiscount.setScale(6)));
    	}
    	return ThirdPartyDiscount;
    }
 
   //MaxThirdPartyDiff
   public Decimal getMaxThirdPartyDiff() {
   	   if ( MaxThirdPartyDiff == null ) {
   	   	  MaxThirdPartyDiff=0;
   	   	  for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts())   {
    			if ( pr.isThirdParty && pr.Input_TotalListPriceAdjusted != 0 )  {
    				
    				Decimal appliedDisc =  pr.ProdMaxDiscount != null ? pr.ProdMaxDiscount : Decimal.valueOf(QuoteData.Constants.get('ThirdPartyDiscount'));
    				
    				Decimal maxDiscDelta = (1 - (pr.Input_TotalNetPriceAdjusted / pr.Input_TotalListPriceAdjusted)) - (appliedDisc / 100);
    				if ( maxDiscDelta > 0 )
    				   MaxThirdPartyDiff -= maxDiscDelta * pr.Input_TotalListPriceAdjusted;
    			}
    	  }
   	   	  if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('MaxThirdPartyDiff', String.valueOf(MaxThirdPartyDiff.setScale(6)));
   	   }
   	   return MaxThirdPartyDiff;
   }
   ///HARDWARE
   	//HardwareListPrice
   public Decimal getHardwareListPrice() {
    	if ( HardwareListPrice == null ) {
    		HardwareListPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
    			if ( pr.isHardware && pr.Input_TotalListPriceAdjusted != null )
     			   HardwareListPrice += pr.Input_TotalListPriceAdjusted;
    		}  
    					
    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('HardwareListPrice', String.valueOf(HardwareListPrice.setScale(6)));
    	}
        return HardwareListPrice;
   }
   ///HardwareNetPrice
   public Decimal getHardwareNetPrice() {
    	if ( HardwareNetPrice == null ) {
    		HardwareNetPrice=0;
    		for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
    			if ( pr.isHardware )
    				HardwareNetPrice += pr.Input_TotalNetPriceAdjusted;
    		}   			
    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('HardwareNetPrice', String.valueOf(HardwareNetPrice.setScale(6)));
    	}
    	return HardwareNetPrice;
    }
  //HardwareDiscount
  public Decimal getHardwareDiscount() {
     if ( HardwareDiscount == null )  {
     	  HardwareDiscount = 0;
    	 if ( getHardwareListPrice() > 0 )
    	    HardwareDiscount = 1 - (getHardwareNetPrice() / getHardwareListPrice());
    	    
    	 if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('HardwareDiscount', String.valueOf(HardwareDiscount.setScale(6)));
      }
      return HardwareDiscount;
   }

   ///MaxHardWareDiff
   public Decimal getMaxHardWareDiff()   {
   	   if ( MaxHardWareDiff == null )  {
   	   	  MaxHardWareDiff=0;
   	   	  for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
    			if ( pr.isHardware && pr.Input_TotalListPriceAdjusted != 0 )  {
    				
    				Decimal appliedDisc = pr.ProdMaxDiscount != null ? pr.ProdMaxDiscount :  Decimal.valueOf(QuoteData.Constants.get('HardwareDiscount'));
    
    				Decimal maxDiscDelta = (1 - (pr.Input_TotalNetPriceAdjusted / pr.Input_TotalListPriceAdjusted)) - (appliedDisc / 100);
    				if ( maxDiscDelta > 0 )
    				   MaxHardWareDiff -= maxDiscDelta * pr.Input_TotalListPriceAdjusted;
    			}
    	  }
   	   	  if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('MaxHardWareDiff', String.valueOf(MaxHardWareDiff.setScale(6)));
   	   }
   	   return MaxHardWareDiff;
   } 
   //MaxLicenseDiff
   public Decimal getMaxLicenseDiff()   {
   	   if ( MaxLicenseDiff == null )  {
   	   	  MaxLicenseDiff=0;
   	   	  for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts()) {
    			if ( pr.isProduct && pr.ProdMaxDiscount != null && pr.Input_TotalListPriceAdjusted != 0 )  {  				
    				Decimal maxDiscDelta = (1 - (pr.Input_TotalNetPriceAdjusted / pr.Input_TotalListPriceAdjusted)) - (pr.ProdMaxDiscount / 100);
    				if ( maxDiscDelta > 0 )
    				   MaxLicenseDiff -= maxDiscDelta * pr.Input_TotalListPriceAdjusted;
    			}
    	  }
   	   	  if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('MaxLicenseDiff', String.valueOf(MaxLicenseDiff.setScale(6)));
   	   }
   	   return MaxLicenseDiff;
   } 

///CARE
    //SelectedCarePercentage
    public Decimal getSelectedCarePercentage()   {
    	 if ( SelectedCarePercentage == null ) {
                if ( QuoteData.isSeparateCareQuote && QuoteData.CareRateSeparateQuote != null ) {
                   SelectedCarePercentage = QuoteData.CareRateSeparateQuote / 100; 
				}
    	 	    else if ( QuoteData.CareRateOveride != null ) {
	    	 	 	try {
	    	 	 		SelectedCarePercentage = Decimal.valueOf( QuoteData.CareRateOveride.removeEnd('%') ) / 100;
	    	 	 	}
	    	 	 	catch(Exception ex) {
	    	 	 	   if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('SelectedCarePercentage', 'Error');
	    	 	 	}  
    	 	    } 
    	 	    else if ( QuoteData.CareRate != null )
    	 	       SelectedCarePercentage = QuoteData.CareRate / 100; 
    	 	       
    	 	    if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('SelectedCarePercentage', String.valueOf(SelectedCarePercentage));	 	 	
    	 }
    	 return SelectedCarePercentage;
   }    
   //AnnualCareRateDiff
   public Decimal getAnnualCareRateDiff() {
    	if ( AnnualCareRateDiff == null )  {
    		Decimal baseRate = getCareCustmrContrRate() == null ? getPredictedCareRate() : getCareCustmrContrRate();
    		
    		if ( getSelectedCarePercentage() != null )
    			AnnualCareRateDiff = getSelectedCarePercentage() - baseRate;
    	    else
    		    AnnualCareRateDiff = 0;
  
    	    String conditionalRate; /// for display only
    	    if ( AnnualCareRateDiff == 0 )	
    	          conditionalRate = 'Neutral';
    	    else if ( AnnualCareRateDiff > 0 )
    	          conditionalRate = 'Benefit';
    	    else
    	         conditionalRate = 'Penalty';
    	    
    	  	if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('AnnualCareRateDiff', conditionalRate + ':  ' + String.valueOf(AnnualCareRateDiff.setScale(6)));
    	}
    	return AnnualCareRateDiff;
     }  
    ///LifetimeCareRateDiff
    public Decimal getLifetimeCareRateDiff()   {
    	if ( LifetimeCareRateDiff == null )  {
    		 		
     		Double intrate = Double.valueOf(QuoteData.Constants.get('InterestRate'));  
     		Double mnths = QuoteData.CareDurationMnths == null ? 12 : QuoteData.CareDurationMnths; 
 
     		LifetimeCareRateDiff = getAnnualCareRateDiff() * math.pow((1+intrate), (mnths/12));
     			
     		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('LifetimeCareRateDiff', String.valueOf(LifetimeCareRateDiff.setScale(6)));
     	} 
     	return LifetimeCareRateDiff;
     }
     ///CareRateAmount
    public Decimal getCareRateAmount() {
	      if ( CareRateAmount == null ) {
	    		Decimal price = adjust.getTotalNonCntrctProdListPrice();

	    		CareRateAmount = 0;   		
	    		if ( !QuoteData.Subscription && getLifetimeCareRateDiff() != null )
	    			CareRateAmount = getLifetimeCareRateDiff() * price;
	   
	    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('CareRateAmount', String.valueOf(CareRateAmount != null ? CareRateAmount.setScale(6) : null) );   			
	     }
    	return CareRateAmount;
     }
  
    //PSDiff
    public Decimal getPSDiff() {
    	if ( PSDiff == null ) {
    		PSDiff=0;
    		Opportunity psopp = DDSToolSelector.getPSOpportunity(ddsTM.quoteId);
    		
    		if ( psopp != null && psopp.Sold_Margin_PPW__c != null && psopp.PS_Amount_On_Premise__c != null ) {
    			    			
    			Decimal TargetProfit = Decimal.valueOf(QuoteData.Constants.get('PSTargetProfitabilityPc')); 
    			Decimal PSProfit = psopp.Sold_Margin_PPW__c / 100;
    			if ( PSProfit < TargetProfit ) {
    				Decimal PSExchangeRate = 1 / DDSToolSelector.getConversionRateByIsoCode(psopp.CurrencyIsoCode, Date.valueOf(psopp.CloseDate));     				
    				PSDiff = (TargetProfit - PSProfit) * psopp.PS_Amount_On_Premise__c * PSExchangeRate;
    			}
    		}    		
    		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('PSDiff', String.valueOf(PSDiff.setScale(6)));    		 		
    	}
    	
    	return PSDiff;
    }  
    //nonCntrctDiscount - non-contractual products Discount
    public Decimal getNonCntrctDiscount() {
    	if ( nonCntrctDiscount == null ) {
              nonCntrctDiscount=0;
              
              if ( adjust.getTotalNonCntrctProdListPrice() != 0 )
                 nonCntrctDiscount = 1 - (adjust.getTotalNonCntrctProdNetPrice() / adjust.getTotalNonCntrctProdListPrice());
              
    	   	  if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('nonCntrctDiscount', String.valueOf(nonCntrctDiscount.setScale(6)));
    	}
    	return nonCntrctDiscount;
    } 

/*    
    //UserDisplDiscAdjuster 
   public Decimal getUserDisplDiscAdjuster()  {
    	if ( UserDisplDiscAdjuster == null ) {
    		UserDisplDiscAdjuster = 1;
      		if ( QuoteData.UserDisplayQuoteDisc != null && QuoteData.UserDisplayQuoteDisc != 0 && getNonCntrctDiscount() != 1 ) {
                Decimal quoteDisc = QuoteData.UserDisplayQuoteDisc / 100;
   
                ///adjusting to 100% limit, which is Price Realization
    			if ( getNonCntrctDiscount() <= quoteDisc )
    			   UserDisplDiscAdjuster = (1-quoteDisc) / (1-getNonCntrctDiscount());
    			else   ///adjusting to 0 limit, wich is Discount
    			   UserDisplDiscAdjuster = quoteDisc / getNonCntrctDiscount();  
    		}    		
    		if (ddsTM.LogLevel > 1) PostCalcVarsMap.put('UserDisplDiscAdjuster', String.valueOf(UserDisplDiscAdjuster.setScale(6)));
    	}   	
    	return UserDisplDiscAdjuster;
    }
*/
   // PartnerContractualDiscount - might need to moveto a subclass later
   // PureConnect and Indirect
   public Decimal getPartnerContractualDiscount() {
   	   if ( PartnerContractualDiscount == null ) {
   	   	   Decimal partnerDisc;

	   	   if ( QuoteData.offering == 'PureConnect' && !QuoteData.DirectSales ) 
	    		partnerDisc = DDSToolSelector.getPartnerContractualDiscount(QuoteData.SoldToId, QuoteData.offering, QuoteData.Subscription);
   	
	    	PartnerContractualDiscount = partnerDisc == null ? 0 : partnerDisc;
    	
    	    if (ddsTM.LogLevel > 1) PostCalcVarsMap.put('PartnerContractualDiscount', String.valueOf(PartnerContractualDiscount.setScale(2))); 
   	   }
       return PartnerContractualDiscount;
   }
   
   public Decimal getLocalNonContractualDiscount() {
   	  if ( LocalNonContractualDiscount == null ) {
   	  	    LocalNonContractualDiscount = 0;
	   	    for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts())  {
				  ///6/25/19 if (pr.isProduct && pr.LocalDisc != null ) { 
			   	  if ( (pr.isProduct || (adjust.getBasePackageId() != null && pr.prodId == adjust.getBasePackageId())) && pr.LocalDisc != null ) {  
			   	  	LocalNonContractualDiscount += pr.LocalDisc;
			   	}
	   	    }
	   	    
	     if (ddsTM.LogLevel > 1) PostCalcVarsMap.put('LocalNonContractNonEapDiscount', String.valueOf(LocalNonContractualDiscount.setScale(2))); 
   	  }
   	  return LocalNonContractualDiscount;
   }

///END OF SUPER CLASS METHODS
                  
   /// same variable - different implementation 
   public virtual Decimal getPredictedCareRate() {return null;} 
   public virtual Decimal getCareCustmrContrRate() {return null;}    
   public virtual Decimal getGUDiff() {return null;} 
    
 //// Engage variables
   public virtual Decimal getPredictedDiscountAdjusted() {return null;} 
   public virtual Decimal getPriceRealization() {return null;}
   public virtual Decimal getGUTargetNetPrice() {return null;} 
   public virtual Decimal getGUTotalNetPrice() {return null;} 
 
  ///Connect variables
   public virtual Decimal getIndirectDealPureConnect() {return null;} 
 
   ///PURE ENGAGE implementations
   public class DDSToolPostCalcPureEngage extends DDSToolPostCalc {	
    	private Decimal PredictedDiscountAdjusted;
		private Decimal PredictedThirdPartyDiscount;		
    	private Decimal PredictedCareRate;   	
	    private Decimal CareCustmrContrRate;	    
	    private Decimal GUTargetNetPrice;
	    private Decimal GUTotalNetPrice;
	    private Decimal GUDiff;
	    private Decimal PredictedHardwareDiscount;
    	
    	//PredictedDiscountAdjusted
    	public override Decimal getPredictedDiscountAdjusted() {
    		if ( PredictedDiscountAdjusted == null ) {
    			Decimal interDiscRegr = Decimal.valueOf(QuoteData.Constants.get('InterceptDiscountRegression'));
    			Decimal slopeLPDR = Decimal.valueOf(QuoteData.Constants.get('Slope_LN_ListPriceDiscountRegression'));
    			Decimal minLPDR = Decimal.valueOf(QuoteData.Constants.get('MinimumListPriceDiscountRegression'));
    			Decimal linAdjDR = Decimal.valueOf(QuoteData.Constants.get('LinearadjustmentDiscountRegression'));
    			Decimal listPR = adjust.getTotalNonCntrctProdListPrice();  
    			
    			try {
	    			Decimal maxLPR = math.max(listPR, minLPDR);
	    			Decimal minRegr = math.min(maxLPR, slopeLPDR * linAdjDR);    			
	    			PredictedDiscountAdjusted = interDiscRegr + slopeLPDR * math.log(minRegr) - minRegr/linAdjDR; 
    			}
    			catch(Exception ex) {
    				PredictedDiscountAdjusted = 0;
    				PostCalcVarsMap.put('PredictedDiscountAdjusted', 'Error. Replaced with 0');
    			}
    			PostCalcVarsMap.put('PredictedDiscountAdjusted', String.valueOf(PredictedDiscountAdjusted.setScale(6)));   			
    		}
    		return PredictedDiscountAdjusted;
    	}

    	 //CareCustmrContrRate
    	 public override Decimal getCareCustmrContrRate() {
    	 	if ( CareCustmrContrRate == null ) {
    	 		//CareCustmrContrRate=0;
    	 		if ( QuoteData.CareCustmrContrRatePEng != null )
    	 		   CareCustmrContrRate = QuoteData.CareCustmrContrRatePEng / 100;
    	 		   
    	 		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('CareCustmrContrRate', CareCustmrContrRate != null ? String.valueOf(CareCustmrContrRate.setScale(6)) : null);
    	 	}
    	 	return CareCustmrContrRate;
    	 }
       //PredictedCareRate
    	public override Decimal getPredictedCareRate() {
    	 	 if ( PredictedCareRate == null ) {
    	 	 	///Indirect deal before 1/1/2018 use ListPrice, otherwise use NetPrice  
    	 	 	///if 100% discount net price is 0, in that case use list 	  	 	 	
    	 	 	if ( !QuoteData.DirectSales && QuoteData.CreatedDate < Date.valueOf('2018-01-01') || adjust.getTotalNonCntrctProdNetPrice() == 0 )
    	 	 	    PredictedCareRate = super.getPredictedCareRateByOffer('PureEngage', 'Care', adjust.getTotalNonCntrctProdListPrice()); 
    	 	 	else    
    	 	 		PredictedCareRate = super.getPredictedCareRateByOffer('PureEngage', 'Care', adjust.getTotalNonCntrctProdNetPrice());
    	 	 	
    	 	 	if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('PredictedCareRate', String.valueOf(PredictedCareRate.setScale(6)));
    	 	 }
    	 	 return PredictedCareRate;
   	 }       

      //GUVolumeDisc
      public Decimal getGUVolumeDisc(Decimal units) {
      	  Decimal disc=0;
      	  if (units < 500 && units >= 250)
      	     disc = 0.05;
      	  else if (units < 1000 && units >= 500)
      	     disc = 0.1;
      	  else if (units < 2000 && units >= 1000)
      	     disc = 0.15;
      	  else if (units < 3000 && units >= 2000)
      	     disc = 0.2;
      	  else if (units >= 3000)
      	     disc = 0.25;
      	  
      	  return disc;
      }
	  //GUTotalNetPrice
	  public override Decimal getGUTotalNetPrice() {
	  	if ( GUTotalNetPrice == null ) {
	  		GUTotalNetPrice=0;
	  		for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts())   {
		   	  	if (pr.Input_ProductType != null && pr.Input_ProductType == 'GU' )          	 
		         	 GUTotalNetPrice += pr.Input_TotalNetPriceAdjusted; 
		    }
		    if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('GUTotalNetPrice', String.valueOf(GUTotalNetPrice.setScale(6)));
	  	}
	  	return GUTotalNetPrice;
	  }
	  //GUTargetNetPrice
	  public override Decimal getGUTargetNetPrice() {
	  	  if ( GUTargetNetPrice == null )  {
	  	  	  GUTargetNetPrice = 0;
	  	  	  for (DDSToolQuoteData.ProductLine pr : adjust.getNonCntrctProducts())   {
		   	  	if (pr.Input_ProductType != null && pr.Input_ProductType == 'GU' ) {
		   	  	   Decimal listPrice = pr.Input_TotalListPriceAdjusted == null ? 0 : pr.Input_TotalListPriceAdjusted;
		   	  	   Decimal qty = pr.Input_Quantity == null ? 0 : pr.Input_Quantity;  
		   	  	   
	  	  	 	   GUTargetNetPrice += listPrice - (listPrice * getGUVolumeDisc(qty));
		   	  	}
	  	  	  }
	  	  	  if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('GUTargetNetPrice', String.valueOf(GUTargetNetPrice.setScale(6)));
	  	  }
	  	  return GUTargetNetPrice;
	  }
	  //GUDiff
	  public override Decimal getGUDiff() {
	  	  if ( GUDiff == null ) {
	  	  	  GUDiff = getGUTotalNetPrice() - getGUTargetNetPrice();	  	  	  
	  	  	  if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('GUDiff', String.valueOf(GUDiff.setScale(6)));
	  	  }
	  	  return GUDiff;
	  }

    }  
    
    ///PURE CONNECT implementations
    public class DDSToolPostCalcPureConnect extends DDSToolPostCalc {    	
    	private Decimal PredictedCareRate;   	
	    private Decimal CareCustmrContrRate;
	    
    	//private Decimal PredictedThirdPartyDiscount;
    	//private Decimal PredictedHardwareDiscount;
    	private Decimal IndirectDealPureConnect;
 
    	//PredictedCareRate
    	public override Decimal getPredictedCareRate() {
    	 	/// PureConnect by ListPriceConverted
    	 	 if ( PredictedCareRate == null ) {
    	 	 	///Indirect deal after 1/1/2018 use NetPrice, otherwise use ListPrice   	 	 	
    	 	 	if ( !QuoteData.DirectSales && QuoteData.CreatedDate > Date.valueOf('2018-01-01') && adjust.getTotalNonCntrctProdNetPrice() != 0 )
    	 	 	     PredictedCareRate = super.getPredictedCareRateByOffer('PureConnect', 'Care Indirect', adjust.getTotalNonCntrctProdNetPrice()); 
                else if ( !QuoteData.DirectSales && QuoteData.CreatedDate > Date.valueOf('2018-01-01') && adjust.getTotalNonCntrctProdNetPrice() == 0 )
                      PredictedCareRate = super.getPredictedCareRateByOffer('PureConnect', 'Care Indirect', adjust.getTotalNonCntrctProdListPrice()); 
    	 	 	else 
    	 	 	     PredictedCareRate = super.getPredictedCareRateByOffer('PureConnect', 'Care Direct', adjust.getTotalNonCntrctProdListPrice());
   
    	 	 	if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('PredictedCareRate', String.valueOf(PredictedCareRate.setScale(6)));
    	 	 }
    	 	 return PredictedCareRate;
       }
        //CareCustmrContrRate
       public override Decimal getCareCustmrContrRate() {
    	 	if ( CareCustmrContrRate == null ) {
    	 		if ( QuoteData.CareCustmrContrRatePCnct != null ) {
    	 		   if ( QuoteData.CareCustmrContrRatePCnctStart != null && QuoteData.CareCustmrContrRatePCnctStart > QuoteData.CreatedDate )
    	 		       CareCustmrContrRate = null;
    	 		   else if ( QuoteData.CareCustmrContrRatePCnctSEnd != null && QuoteData.CareCustmrContrRatePCnctSEnd < QuoteData.CreatedDate )
    	 			   CareCustmrContrRate = null;
    	 		   else
    	 		   	   CareCustmrContrRate = QuoteData.CareCustmrContrRatePCnct / 100;
    	 		}
    	 		if (ddsTM.LogLevel > 0) PostCalcVarsMap.put('CareCustmrContrRate', CareCustmrContrRate != null ? String.valueOf(CareCustmrContrRate.setScale(6)) : null);
    	    }
    	 	return CareCustmrContrRate;
       }
    	//GUDiff
      public override Decimal getGUDiff() {
    		///not implemented for PureConnect
    		return 0;
       }	
   
    }    
    
}