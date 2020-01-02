public virtual class DDSToolFinalScore {
	
	public Integer Score;
	public Integer FinalScore;
	public String contractScoreAdjusted; ///flag for UI info message
	public String EAPScoreAdjusted; ///flag for UI info message
	public String MegaDeal; //flag for UI info message
	public Map<String, Map<String, Decimal>> finalCutoffsMap;
		
	private DDSToolMain ddsTM;
    private DDSToolQuoteData QuoteData;     
    private DDSToolAdjuster adjust;
    private DDSToolPostCalc PostCalc;
 	
 	public DDSToolFinalScore(DDSToolMain ddsTM) {
       	this.ddsTM = ddsTM;
       	this.adjust = ddsTM.adjust;
        this.QuoteData = ddsTM.quoteData;
        this.PostCalc = ddsTM.postCalc;

        this.finalCutoffsMap = new Map<String, Map<String, Decimal>>();
 		
 	}
 	
	public static DDSToolFinalScore getDDSToolFinalScore(DDSToolMain ddsTM) {   	
		DDSToolFinalScore finalScoring = null;
        
        if ( ddsTM.quoteData.Amendment && ddsTM.adjust.scoringScenario == DDSToolMain.AmendScoring.PREVIOUS_SCORE ) {
        	finalScoring = new DDSToolFinalAmendPrev(ddsTM);
        }
		else if ( ddsTM.quoteData.isThirdPrtHWonly ||
		         (ddsTM.quoteData.Amendment && ddsTM.adjust.scoringScenario == DDSToolMain.AmendScoring.HW3PARTY_ONLY) ) {
		   finalScoring = new DDSToolFinalThirdPrtyHWonly(ddsTM);
		} 
		else {
		   finalScoring = new DDSToolFinalPremLicensedProd(ddsTM);
		}

        finalScoring.calcScore();
        finalScoring.megaDealScoring();

    	return finalScoring;
    } 
    
   public void megaDealScoring() {
	   //if > $10M
	   if ( adjust.getPEV() > Math.pow(10,7) ) {
		   Score = null;
		   FinalScore = null;
		   MegaDeal = 'Y';
	   }
   }

   public virtual void calcScore() {}
   
   ///Class to handle Amendments to return previous score
   public class DDSToolFinalAmendPrev extends DDSToolFinalScore {
   	   public DDSToolFinalAmendPrev(DDSToolMain ddsTM) {
   	       super(ddsTM);
   	   }
   	   
   	   public override void calcScore() {  
   	   	   if ( QuoteData.AmendOrigDealScore != null ) {
	   	   	   Score = Integer.valueOf(QuoteData.AmendOrigDealScore);
	   	   	   FinalScore = Score;
   	   	   }
   	   }   	
   }   
    //////////////  
    ///Class to handle ThirdParty/Hardware Only type of quotes
    public class DDSToolFinalThirdPrtyHWonly extends DDSToolFinalScore {
    	
    	public List<ThirdPartyHWLineItem> thirdPrtyNonCntrLineItems;
    	public List<ThirdPartyHWLineItem> thirdPrtyCntrctLineItems;

    	private Decimal totalNonCntrctListPrice=0;
    	
    	private Decimal totalNetPrice=0;
    	private Decimal totalNonCntrctNetPrice=0;
    	private Decimal totalCntrctNetPrice=0;
    	
    	public DDSToolFinalThirdPrtyHWonly(DDSToolMain ddsTM) {
    		super(ddsTM);
    		thirdPrtyNonCntrLineItems = new List<ThirdPartyHWLineItem>();
    		thirdPrtyCntrctLineItems = new List<ThirdPartyHWLineItem>();
    	}
    	
    	public override void calcScore() {  
    		splitNonContrctLineItems(); 
    		calcMaxDiscScore(); 
    		calcWeightedScore();	 		

    		calcFinalScore();    		
    	}
    
       public void splitNonContrctLineItems() {
 
    	for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
    		    ///if Not Amendment include ThirdParty and Hardware lines only 		   
    		    if ( !QuoteData.Amendment && !pr.isHardware && !pr.isThirdParty && !pr.isCntrctDisc ) 
    		           continue;
    		       		    
     		    ///if Amendment include Amended lines only, these can include GU, Hardware and ThirdParty, PS
    		    if ( QuoteData.Amendment && !pr.isAmended ) continue;
    		       		
	    		ThirdPartyHWLineItem ln = new ThirdPartyHWLineItem();
	    		ln.name = pr.ProductDescr;
	    		ln.isHW = pr.isHardware ? true : false;
	    		ln.isThirdPrty = pr.isThirdParty ? true : false;
	    		ln.prtnrMarginCateg = pr.PartnerMarginCateg;
	    		ln.listPrice = pr.Input_TotalListPriceLocal;   
	    		ln.netPrice = pr.Input_TotalNetPriceLocal;
	    		ln.maxDisc = pr.ProdMaxDiscount;
	    		ln.amendAdded = pr.isAmended;
	   
		    	if ( pr.LocalDisc != null )
		    	    ln.discntPct =  pr.LocalDisc; 
		    	else if ( ln.listPrice != null && ln.netPrice != null && ln.listPrice != 0 )
		    		ln.discntPct = ((1 - (ln.netPrice / ln.listPrice)) * 100).setScale(2); 
		        
		        
		    	if ( ! pr.isCntrctDisc ) {
		    		thirdPrtyNonCntrLineItems.add(ln);
		    		totalNonCntrctListPrice += pr.Input_TotalListPriceLocal != null ? pr.Input_TotalListPriceLocal : 0;
		    		totalNonCntrctNetPrice += pr.Input_TotalNetPriceLocal != null ? pr.Input_TotalNetPriceLocal : 0;
		    	}
		    	else {
		    		thirdPrtyCntrctLineItems.add(ln);
		    		totalCntrctNetPrice += pr.Input_TotalNetPriceLocal != null ? pr.Input_TotalNetPriceLocal : 0;
		    	}
		    	    
		    	totalNetPrice = totalNonCntrctNetPrice + totalCntrctNetPrice; 
    	 }
     }
    //Score non-contractual portion only	
    //where product MAX discount is specified
    private void calcMaxDiscScore() {
    	Decimal dfltHWDisct = Decimal.valueOf(QuoteData.Constants.get('HardwareDiscount'));
    	Decimal dflt3PrtDisct = Decimal.valueOf(QuoteData.Constants.get('ThirdPartyDiscount'));  
    	
    	for ( ThirdPartyHWLineItem li : thirdPrtyNonCntrLineItems ) {
    		Decimal maxDiscApplied;
    		if ( li.maxDisc == null ) {
    		    if ( li.isHW )
    				maxDiscApplied = dfltHWDisct;
    			else if ( li.isThirdPrty )
    			    maxDiscApplied = dflt3PrtDisct; 
    			else {
    			    maxDiscApplied = 40.0; 
    			}
                li.defaultMaxDisc = maxDiscApplied; //UI display
    		}
    		else {
    			maxDiscApplied = li.maxDisc;  
    		}
            /// Three scenarios
	    	//1. maxDiscApplied >= 5%
	    	//2. maxDiscApplied > 0 and < 5%
	    	//3. maxDiscApplied = 0; < 0 to cover negative values
	    	
	    	if ( maxDiscApplied >= 5 ) {	    		
	    		if ( li.discntPct <= maxDiscApplied - 5 ) 
	    		    li.score = 5;
	    		else if ( maxDiscApplied - 5 < li.discntPct && li.discntPct < maxDiscApplied ) 
	    		   li.score = 4;
	    		else if ( maxDiscApplied == li.discntPct ) 
	    		   li.score = 3;
	    		 else if ( maxDiscApplied < li.discntPct && li.discntPct <= maxDiscApplied + 5 ) 
	    		   li.score = 2;
	    		 else if ( maxDiscApplied + 5 < li.discntPct ) 
	    		    li.score = 1;   		
	    	}
	    	else if ( maxDiscApplied > 0 && maxDiscApplied < 5 )  {	    		
	    		if ( li.discntPct < maxDiscApplied ) 
	    		    li.score = 5;
	    		else if ( maxDiscApplied == li.discntPct ) 
	    		   li.score = 4;
	    		else if ( maxDiscApplied < li.discntPct && li.discntPct <= maxDiscApplied + 5 ) 
	    		   li.score = 3;
	    		 else if ( maxDiscApplied + 5 < li.discntPct && li.discntPct <= maxDiscApplied + 10 ) 
	    		   li.score = 2;
	    		 else if ( maxDiscApplied + 10 < li.discntPct ) 
	    		    li.score = 1;   			    		
	    	}
	    	else if ( maxDiscApplied <= 0 ) {
	    		if ( li.discntPct == maxDiscApplied ) 
	    		    li.score = 5;
	    		else if ( maxDiscApplied < li.discntPct && li.discntPct <= maxDiscApplied + 5 ) 
	    		   li.score = 4;
	    		else if ( maxDiscApplied + 5 < li.discntPct && li.discntPct <= maxDiscApplied + 10 ) 
	    		   li.score = 3;
	    		 else if ( maxDiscApplied + 10 < li.discntPct && li.discntPct <= maxDiscApplied + 15 ) 
	    		   li.score = 2;
	    		 else if ( maxDiscApplied + 15 < li.discntPct ) 
	    		    li.score = 1;   			    		
	    	} 
    	}
    } 
    
   ///Calculate non-contractual weighted score 
   private void calcWeightedScore() {
    		Boolean calcError = false;
    		Decimal totalScore=0;
    		for ( ThirdPartyHWLineItem li : thirdPrtyNonCntrLineItems ) {    			
    			if ( !li.isHW && !li.isThirdPrty )
    			   continue;
    			else if ( li.score == null ) {
    				calcError = true;
    				break;
    			}
    			
    			if ( totalNonCntrctListPrice != 0 ) {
	    			li.weightedScore = ((li.listPrice / totalNonCntrctListPrice) * li.score).setScale(6);  
	    			totalScore += li.weightedScore;  
    			}			
    		}   		
    		Score = calcError || totalScore == null ? null : Integer.valueOf(totalScore.round());
    	}    	  
   
	    // Final Score
	   public void calcFinalScore() { 
	       Decimal nonCntrScore=0;
	       Decimal cntrctScore=0;
	 
	       if (  thirdPrtyNonCntrLineItems.size() > 0 ) {
	       	       	
	           if ( totalNetPrice > 0 && Score != null ) {
	           	
		        	///calculate weight of non-contractual portion of the deal
		        	nonCntrScore = Score * (totalNonCntrctNetPrice / totalNetPrice);	        		        	
		        	///calculate weight of contractual portion
		        	cntrctScore = 3 * (totalCntrctNetPrice / totalNetPrice);
		        	
		        	FinalScore = Integer.valueOf((nonCntrScore + cntrctScore).round());
		        	
		        	PostCalc.PostCalcVarsMap.put('Weighted Score - non-contractual', String.valueOf(nonCntrScore.setScale(2)));
		        	PostCalc.PostCalcVarsMap.put('Weighted Score - contractual', String.valueOf(cntrctScore.setScale(2)));
	           }
	        } 
	        else if ( thirdPrtyCntrctLineItems.size() > 0 ) {
	        	Score = 3;
	            FinalScore = 3; 
	            contractScoreAdjusted ='Y';
	        }
	        
	        if (nonCntrScore > 0 && cntrctScore > 0 && Score != null) 
	               PostCalc.PostCalcVarsMap.put('Score before Contractual Disc adjustment', String.valueOf(Score));
	        
	        if (adjust.getCntrctProducts().size() > 0 ) PostCalc.PostCalcVarsMap.put('Score after Contractual Disc adjustment', String.valueOf(FinalScore));       
	    }
    }
    
    ///wrapper class for ThirdParty/Hardware Only quotes line items
    public class ThirdPartyHWLineItem {
    	public String name;
    	public Boolean isHW;
    	public Boolean isThirdPrty;
    	public Integer score;
    	public String prtnrMarginCateg;
    	public Decimal discntPct;
    	public Decimal maxDisc;
    	public Decimal defaultMaxDisc;
    	public Decimal listPrice;
    	public Decimal netPrice;
    	public Decimal weightedScore;
    	public Boolean amendAdded;
    }
    
    /////////////////
    /// Class to handle all Premise types   
    public class DDSToolFinalPremLicensedProd extends DDSToolFinalScore {
    	private DDSToolInterCalc InterCalc;
    	private DDSToolNode NodeTree;
    	
    	private Map<String, Decimal> nodeCutoffs;
		private Map<String, Decimal> NormDiscountCutoffsMap;
		private Map<String, Decimal> AddSubscriptCutoffsMap;
		private Map<String, Decimal> AddCareCutoffsMap;
		private Map<String, Decimal> AddPSCutoffsMap;
		private Map<String, Decimal> AddGUCutoffsMap;
		private Map<String, Decimal> AddThirdPartyCutoffsMap;
		private Map<String, Decimal> AddHWCutoffsMap;
		private Map<String, Decimal> AddMaxDisctsCutoffsMap;
		private Map<String, Decimal> QuoteDiscAdjustedCutoffMap;		
		private Decimal SubscrPriceRealizMultiplr;

	    public DDSToolFinalPremLicensedProd(DDSToolMain ddsTM) {
	    	super(ddsTM);
	    	InterCalc = ddsTM.interCalc;
	        NodeTree = ddsTM.nodeTree;
	    	nodeCutoffs = NodeTree.getNodeCutoffs();
    	 }
    
    public override void calcScore() {     	
    	    	    	
    	calcNormDiscountCutoffs();
    	calcSubscriptionImpact();
    	calcCareImpact();
    	calcPSImpact();
    	calcGUImpact();
    	calcMaxDiscountsImpact();
    	calcScoreFromBands();   	
    	calcFinalScore();  
    	
    	calcDiscAdjustedCuoffs();
    }
    
    /// Subscription Multiplier
    private Decimal getSubscrPriceRealizMultiplr() {
    	if ( SubscrPriceRealizMultiplr == null ) {
    		SubscrPriceRealizMultiplr=0;
    		if ( QuoteData.offering == 'PureEngage' )
    			SubscrPriceRealizMultiplr = Decimal.valueOf(QuoteData.Constants.get('Constant_SubscriptionPureEngagePriceRealizationMultiplier'));
    	    else if ( QuoteData.offering == 'PureConnect' )
    	        SubscrPriceRealizMultiplr = Decimal.valueOf(QuoteData.Constants.get('Constant_SubscriptionPureConnectPriceRealizationMultiplier'));
    	}
    	return SubscrPriceRealizMultiplr;
    }
    ///Normalized Discount Cutoffs, different for PureEngage and PureConnect
    //PureConnect is copy of node cuoffs, PureEngage is 1-NodeCutoff
    private void calcNormDiscountCutoffs() {
    	  NormDiscountCutoffsMap = new Map<String, Decimal>();

    	  if ( QuoteData.offering == 'PureConnect' )
    	  	    NormDiscountCutoffsMap = nodeCutoffs.clone();
    	  else if ( QuoteData.offering == 'PureEngage' )  {
    		for ( String pr : nodeCutoffs.keySet() ) {
    			Decimal priceRealiz = (1 + nodeCutoffs.get(pr)) * (1- PostCalc.getPredictedDiscountAdjusted());
    			NormDiscountCutoffsMap.put( pr, (1- priceRealiz) );    		
    		} 
    		///For display only, not used otherwise
    		//finalCutoffsMap.put('Price Realization Error Cutoffs', nodeCutoffs);  		
    	  }  
    	  finalCutoffsMap.put('Node Cutoffs', nodeCutoffs);    	  
    	  finalCutoffsMap.put('Normalized Discount Cutoffs', NormDiscountCutoffsMap);
    }
    
    ///Step 1: Subscription Impact
    private void calcSubscriptionImpact() {
    	AddSubscriptCutoffsMap = new Map<String, Decimal>();

    	if ( QuoteData.Subscription && adjust.getTotalNonCntrctProdListPrice() > 0) {
    		Decimal subscrShare = 1 + getSubscrPriceRealizMultiplr() * PostCalc.getSubscriptionShare();    		
    		for ( String pr : NormDiscountCutoffsMap.keySet() ) {
    			Decimal priceRealiz = 1-NormDiscountCutoffsMap.get(pr);
    			Decimal priceRealizVal = priceRealiz * subscrShare;
    			Decimal adjstDisc = 1 - priceRealizVal;
    			
    			AddSubscriptCutoffsMap.put( pr, adjstDisc < 0 ? 0 : adjstDisc);
    		}   		
    	}    	
    	else
    	   AddSubscriptCutoffsMap = NormDiscountCutoffsMap.clone(); 
    	   
    	FinalCutoffsMap.put('Subscription Impact', AddSubscriptCutoffsMap);
    }
    ///Step 2: Care Impact
    private void calcCareImpact() {
    	AddCareCutoffsMap = new Map<String, Decimal>();

    	if ( QuoteData.Subscription || QuoteData.isCareContrct || adjust.getTotalNonCntrctProdListPrice() == 0 ) {
    		//Care is not applicable for Subscription deals
    		AddCareCutoffsMap = AddSubscriptCutoffsMap.clone();
    	}  
    	else {  	
	    	for ( String pr : AddSubscriptCutoffsMap.keySet() ) {
	    		Decimal priceRealiz = 1-AddSubscriptCutoffsMap.get(pr);
	    		Decimal priceRealizVal = priceRealiz * adjust.getTotalNonCntrctProdListPrice();   // PostCalc.getOriginalListPrice();
	    		Decimal adjstVal = priceRealizVal -  PostCalc.getCareRateAmount();
	   		    Decimal adjstDisc = 1 - (adjstVal/adjust.getTotalNonCntrctProdListPrice()); 
	    		
	    		AddCareCutoffsMap.put( pr, adjstDisc < 0 ? 0 : adjstDisc);              
	    	} 
    	} 	
    	FinalCutoffsMap.put('Care Impact', AddCareCutoffsMap);
    }
    
    //Step3: PS Impact
    private void calcPSImpact() {
    	AddPSCutoffsMap = new Map<String, Decimal>();

    	if ( adjust.getTotalNonCntrctProdListPrice() > 0 && PostCalc.getPSDiff() != 0 ) {
    		for ( String pr : AddCareCutoffsMap.keySet() ) {
	    		Decimal priceRealiz = 1-AddCareCutoffsMap.get(pr);
	    		Decimal priceRealizVal = priceRealiz * adjust.getTotalNonCntrctProdListPrice();
	    		Decimal adjstVal = priceRealizVal - PostCalc.getPSDiff();
	    		Decimal adjstDisc = 1 - (adjstVal/adjust.getTotalNonCntrctProdListPrice()); 
	    		
	    		AddPSCutoffsMap.put( pr, adjstDisc); 
    		}   		
    	}
    	else
    		AddPSCutoffsMap = AddCareCutoffsMap.clone();
    		
        FinalCutoffsMap.put('PS Impact', AddPSCutoffsMap);        
    }
    //Step 4: GU Impact
    private void calcGUImpact() {
    	AddGUCutoffsMap = new Map<String, Decimal>();

    	if ( adjust.getTotalNonCntrctProdListPrice() > 0 && PostCalc.getGUDiff() != 0 ) {
    		for ( String pr : AddPSCutoffsMap.keySet() ) {
	    		Decimal priceRealiz = 1-AddPSCutoffsMap.get(pr);
	    		Decimal priceRealizVal = priceRealiz * adjust.getTotalNonCntrctProdListPrice();
	    		Decimal adjstVal = priceRealizVal - PostCalc.getGUDiff();
	    		Decimal adjstDisc = 1 - (adjstVal/adjust.getTotalNonCntrctProdListPrice());
	    		
	    		AddGUCutoffsMap.put( pr, adjstDisc); 
    		}   		
    	}
    	else
    		AddGUCutoffsMap = AddPSCutoffsMap.clone(); 
    		
    	FinalCutoffsMap.put('GU Impact', AddGUCutoffsMap);      
    }

    // Step 7: Max Discounts
    private void calcMaxDiscountsImpact() {
    	AddMaxDisctsCutoffsMap = new  Map<String, Decimal>();    
	
    	if ( adjust.getTotalNonCntrctProdListPrice() > 0 ) {	
	    	for ( String pr : AddGUCutoffsMap.keySet() ) {
	    		Decimal priceRealiz = 1-AddGUCutoffsMap.get(pr);
	    		Decimal priceRealizVal = priceRealiz * adjust.getTotalNonCntrctProdListPrice();
	    		Decimal adjstVal = priceRealizVal - PostCalc.getMaxHardWareDiff() - 
	    		                                    PostCalc.getMaxThirdPartyDiff() - 
	    		                                    PostCalc.getMaxBundleDiff() - 
	    		                                    PostCalc.getMaxLicenseDiff(); 
	    		Decimal adjstDisc = 1 - (adjstVal/adjust.getTotalNonCntrctProdListPrice());
	    		   		
	    		AddMaxDisctsCutoffsMap.put( pr, adjstDisc);
    		}  
    	}
    	else
    	     AddMaxDisctsCutoffsMap = AddGUCutoffsMap.clone();
    	     	
    	FinalCutoffsMap.put('MAX Discounts Impact', AddMaxDisctsCutoffsMap);   	
    }
    
    /// Score
    private void calcScoreFromBands() {    		
    	    Decimal disc;   	    
    	    if ( PostCalc.getLocalNonContractualDiscount() == 0 ) {
    	        disc = 0;
    	        Score = 5;
    	    }
    		else { 
        		disc = PostCalc.getNonCntrctDiscount(); 
        		
         		if ( disc.setScale(4) <= AddMaxDisctsCutoffsMap.get('5').setScale(4) )
	    		    Score = 5;
	    		else if ( disc.setScale(4) <= AddMaxDisctsCutoffsMap.get('4').setScale(4) )
	    		    Score = 4;
	    		else if ( disc.setScale(4) <= AddMaxDisctsCutoffsMap.get('3').setScale(4) )
	    		    Score = 3;
	    		else if ( disc.setScale(4) <= AddMaxDisctsCutoffsMap.get('2').setScale(4) )
	    		    Score = 2;
	    		else 
	    		    Score = 1; 
    		}
    		    
    		ddsTM.Log += 'Discount: ' + disc.setScale(6) + '  ';
    }		    
    // Final Score
    public void calcFinalScore() { 
       // FinalScore = adjustScoreForContractDisc();
       Decimal nonCntrScore=0;
       Decimal cntrctScore=0;
	   Decimal eapScore=0;
 
       if ( adjust.getNonCntrctProducts().size() > 0 ) {
       	       	
           if ( adjust.getTotalProdNetPrice() > 0 && Score != null ) {
           	
	        	///calculate weight of non-contractual portion of the deal
	        	nonCntrScore = Score * (adjust.getTotalNonCntrctProdNetPrice() / adjust.getTotalProdNetPrice());	        		        	
	        	///calculate weight of contractual portion
	        	cntrctScore = 3 * (adjust.getTotalCntrctProdNetPrice() / adjust.getTotalProdNetPrice());
				///calculate weight of EAP portion
	        	eapScore = 3 * (adjust.getTotalEapProdNetPrice() / adjust.getTotalProdNetPrice());
	        	
	        	FinalScore = Integer.valueOf((nonCntrScore + cntrctScore + eapScore).round());
	        	
	        	PostCalc.PostCalcVarsMap.put('Weighted Score - non-contractual', String.valueOf(nonCntrScore.setScale(2)));
	        	PostCalc.PostCalcVarsMap.put('Weighted Score - contractual', String.valueOf(cntrctScore.setScale(2)));
				PostCalc.PostCalcVarsMap.put('Weighted Score - EAP', String.valueOf(eapScore.setScale(2)));
           }
           else
               FinalScore = Score;
        } 
        else if ( adjust.getCntrctProducts().size() + adjust.getEapProducts().size() > 0 ) {
          /// all line items contractual or EAP
        	Score = 3;
            FinalScore = 3;            
        }
        
		//Contractual message flag           
        contractScoreAdjusted = adjust.getCntrctProducts().size() > 0 && FinalScore == 3 ? 'Y' : 'N';

		///EAP message flag
        EAPScoreAdjusted = adjust.getEapProducts().size() > 0 ? 'Y' : 'N';
        
        if ( Score != null && nonCntrScore > 0 && (cntrctScore > 0 || eapScore > 0) )
               PostCalc.PostCalcVarsMap.put('Score before Contractual/EAP Disc adjustment', String.valueOf(Score));
        
        if (adjust.getCntrctProducts().size() > 0 ) PostCalc.PostCalcVarsMap.put('Score after Contractual/EAP Disc adjustment', String.valueOf(FinalScore));       
    }
    
    ///Cutoffs adjusted for quote discount to display on the quote
    public void calcDiscAdjustedCuoffs() {
    	QuoteDiscAdjustedCutoffMap = new Map<String, Decimal>();  
    	
    	for ( String pr : AddMaxDisctsCutoffsMap.keySet() ) {
    		
    		if ( adjust.getTotalNonCntrctProdListPriceLocal() != null && adjust.getTotalNonCntrctProdListPriceLocal() != 0 ) {
	    		Decimal priceRealiz = 1-AddMaxDisctsCutoffsMap.get(pr);
	    		Decimal adjstVal = priceRealiz * adjust.getTotalNonCntrctProdListPrice();
	    		Decimal adjstValLocal = adjstVal / adjust.getExchangeRate();
	    		Decimal adjstDisc = 1 - (adjstValLocal/adjust.getTotalNonCntrctProdListPriceLocal());
	    		
	    		 //put floor = 0% and ciling = 97% 
	    		if ( adjstDisc < 0 )
	    		   adjstDisc = 0;
	    		else if ( adjstDisc >= 1 )
	    		   adjstDisc = 0.97;
	    		   
	    		QuoteDiscAdjustedCutoffMap.put( pr, adjstDisc);
    		}
    		else
    		    QuoteDiscAdjustedCutoffMap = AddMaxDisctsCutoffsMap.clone();
    	} 
    	
    	FinalCutoffsMap.put('Quote Discount Adjusted', QuoteDiscAdjustedCutoffMap);     	  	
    }


 
  }   /// END class DDSToolFinalPremLicensedProd
}