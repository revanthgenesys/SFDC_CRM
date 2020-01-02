/* Mariya Steason - Aug 2018
   Purpose: DDSToolInterCalc is a class in the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public virtual class DDSToolInterCalc {
    
    public Map<String, String> InterCalcVarsMap;
    
    private DDSToolMain ddsTM;
    private DDSToolQuoteData QuoteData; 
    private DDSToolAdjuster adjust; 

    private String Account_Name_Vertical_Fixed;      
    private Integer Customer_age;        //from 2 years of history
    private Decimal DDS_List_Price_USD;  
    private Integer Digital_5Percent_2019; 
    private String Dominant_Product_Category_50PCT_2019; 
    private String Dominant_Unit_of_Measure_50Pct; 
    private Integer Inbound_5Percent_2019;         
    private Decimal Last2Years_NetRevenue; 
    private Decimal LastSixMonths_NetRevenue; 
    private Decimal LastYear_NetRevenue;   
    private Integer LastYear_NumberOfDeals; 
    private Integer Number_of_Lost;        //from 2 years of history
    private String number_of_products_5pc;   
    private Integer Number_of_products_in_deal_5pc;     
    private Integer Number_Product_Category_Over5percent_2019;  
    private Integer Open_Platform_5Percent_2019;               
    private String Public_sector_vs_enterprise_customer;  
    private Integer Self_Service_5Percent_2019; 
    private String Sold_To_Country;             
    private String Sold_To_Country_Region;     
    private String Sold_To_Country_Sub_Sub_Region; 
    private String Type;                        
    private Integer WEM_5Percent_2019; 
    private Date CloseDate;                      
    
    private String Cluster;
    
    public static DDSToolInterCalc getDDSToolInterCalc(DDSToolMain ddsTM) {  
    	DDSToolInterCalc interCalc = new DDSToolInterCalc();       
        interCalc.ddsTM = ddsTM;  
        interCalc.QuoteData = ddsTM.quoteData;  		      
        interCalc.adjust = ddsTM.adjust;
        interCalc.InterCalcVarsMap = new Map<String, String>();

    	return interCalc;
    }

    ///generic methods
   private Integer getProdCategNum_5pcByName(String prodCategName)  {
        Integer cat5pc = 0;  /// Boolean 0 or 1
    	Decimal catTotalPrice = 0;
    	///type Product only	
    	for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
    		if ( !pr.isProduct || pr.ProductCategory == null || String.isBlank(pr.ProductCategory) )
    		   continue;
    
    		if (pr.ProductCategory.contains(prodCategName) )
    			catTotalPrice += pr.Input_TotalListPriceAdjusted;
    	}  
    	  		
    	if ( adjust.getTotalProdListPrice() > 0 ) {
    		    if ( catTotalPrice / adjust.getTotalProdListPrice() >= 0.05 )	
    		  		  cat5pc = 1;
    		    else
    	             cat5pc = 0;
    	}   		
    	return cat5pc;    	
    }      
    private Integer getPastDealsByDate(Integer months) {
    	Integer deals=0;
    	for ( DDSToolQuoteData.HistoricalData hst : QuoteData.historicalData ) {
    		if ( hst.OpptyCloseDate != null && getCloseDate() != null &&  hst.OpptyWinLost == 'Won' &&
    		     hst.OpptyCloseDate < getCloseDate() && hst.OpptyCloseDate >= getCloseDate().addMonths(months) ) 
    		   deals++;
    	}
    	return deals;
    }    
    private Decimal getPastDealsNetRevenewByDate(Integer months) {
    	Decimal revenue=0;
    	for ( DDSToolQuoteData.HistoricalData hst : QuoteData.historicalData ) {
    		if ( hst.OpptyCloseDate != null && getCloseDate() != null &&  hst.OpptyWinLost == 'Won' && hst.NewExtNetPriceUSD != null &&
    		     hst.OpptyCloseDate < getCloseDate() && hst.OpptyCloseDate >= getCloseDate().addMonths(months) )  
    		    	 revenue += hst.NewExtNetPriceUSD;   
    	}
    	return revenue;
    }
    
   //Variables
   //Account_Name_Vertical_Fixed
   public String getAccount_Name_Vertical_Fixed() {
   	  if ( Account_Name_Vertical_Fixed == null ) {
  
   	  	  Account_Name_Vertical_Fixed = QuoteData.Vertical == null ? '' : QuoteData.Vertical;
   	  	 
   	  	 if (ddsTM.LogLevel > 1) InterCalcVarsMap.put('Account_Name_Vertical_Fixed', Account_Name_Vertical_Fixed);
   	  }
   	  return Account_Name_Vertical_Fixed;
   }
    //Customer_age
   public Integer getCustomer_age() {
    	if ( Customer_age == null ) {
    		Customer_age = 0;
    		Date mindt;
    		Date maxdt; 
    		for ( DDSToolQuoteData.HistoricalData hst : QuoteData.historicalData ) {
    			if ( hst.OpptyWinLost == 'Won' && hst.OpptyCloseDate != null && hst.OpptyCloseDate > Date.valueOf('2017-01-01') ) {
    				if ( mindt == null && maxdt == null ) {
    					mindt = hst.OpptyCloseDate;
    					maxdt = hst.OpptyCloseDate;
    				}
    				else if ( mindt > hst.OpptyCloseDate )
    				   mindt = hst.OpptyCloseDate;
    				else if ( maxdt < hst.OpptyCloseDate )
    				   maxdt = hst.OpptyCloseDate;
    			}
    		} 
    		
    		if ( mindt != null && maxdt != null )
    		    Customer_age = mindt.daysBetween(maxdt);

    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Customer_age', String.valueOf(Customer_age));
    	}
        return Customer_age; 
   
    }
    //DDS_List_Price_USD - add underscores
    public Decimal getDDS_List_Price_USD()   { 
        if ( DDS_List_Price_USD == null )  {
    	     DDS_List_Price_USD = adjust.getTotalProdListPrice();
    	       
    	     if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('DDS_List_Price_USD', String.valueOf(DDS_List_Price_USD.setScale(6)));
    	 }    	    
    	 return DDS_List_Price_USD;
     }
    //Digital_5Percent_2019  - add underscore  	 
    public Integer getDigital_5Percent_2019() {
    	if ( Digital_5Percent_2019 == null ) {
    		Digital_5Percent_2019 = getProdCategNum_5pcByName('Digital');
    		 	 
    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Digital_5Percent_2019', String.valueOf(Digital_5Percent_2019));
         }
    	return Digital_5Percent_2019;
   	}
   	 //Inbound_5Percent_2019
    public Integer getInbound_5Percent_2019() {
           if ( Inbound_5Percent_2019 == null ) {
           	   Inbound_5Percent_2019 = getProdCategNum_5pcByName('Intbound');
           	   
           	   if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Inbound_5Percent_2019', String.valueOf(Inbound_5Percent_2019));
           }
    	   return Inbound_5Percent_2019;
    }
   //Dominant_Product_Category_50PCT_2019
    public String getDominant_Product_Category_50PCT_2019()    {  
       	   if ( Dominant_Product_Category_50PCT_2019 == null )  {
       	   	
	    		Map<String, Decimal> categories = new Map<String, Decimal>();
	    			    		
	    		for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
	    			if ( !pr.isProduct || pr.ProductCategory == null || String.isBlank(pr.ProductCategory) )
    		   			continue;

	    			categories.put(pr.ProductCategory, 
	    			               categories.containsKey(pr.ProductCategory) ? 
	    			               categories.get(pr.ProductCategory) + pr.Input_TotalListPriceAdjusted : pr.Input_TotalListPriceAdjusted);
	    		}   		
	    			    		
	            String dominantCategory; 
	            if ( adjust.getTotalProdListPrice() > 0 )  {    
		            Decimal maxPrc=0;
			    	for (String categ : categories.keySet()) {	
			    		Decimal prc = categories.get(categ) / adjust.getTotalProdListPrice(); 		    				    			 
			    		if ( prc >= 0.5 && prc > maxPrc ) {
			    			maxPrc = prc;			    			
			    			dominantCategory = categ;			    			
			    		}		    			
		    		}
	            }
	            
	    		if ( dominantCategory != null )	    		   
	    			Dominant_Product_Category_50PCT_2019 = dominantCategory;
	    		else if ( categories.size() > 0 )
	    		    Dominant_Product_Category_50PCT_2019 = 'Multiple';
	    		else
	    		     Dominant_Product_Category_50PCT_2019 = '';
	    		     
	    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Dominant_Product_Category_50PCT_2019', String.valueOf(Dominant_Product_Category_50PCT_2019));
       	   }	
    	   return Dominant_Product_Category_50PCT_2019;     		
      }  
      
    //Dominant_Unit_of_Measure_50Pct
    public String getDominant_Unit_of_Measure_50Pct()    {  
       	   if ( Dominant_Unit_of_Measure_50Pct == null )  {
       	   	
	    		Map<String, Decimal> units = new Map<String, Decimal>();
	    		
	    		for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
	    			if ( !pr.isProduct || pr.UnitOfMeasure == null || String.isBlank(pr.UnitOfMeasure) )
    		   			continue;

	    			units.put(pr.UnitOfMeasure, 
	    			          units.containsKey(pr.UnitOfMeasure) ? 
	    			          units.get(pr.UnitOfMeasure) + pr.Input_TotalListPriceAdjusted : pr.Input_TotalListPriceAdjusted);
	    		}   		
	    			    		
	            String dominantUnit; 
	            if ( adjust.getTotalProdListPrice() > 0 )  {    
		            Decimal maxPrc=0;
			    	for (String unit : units.keySet()) {	
			    		Decimal prc = units.get(unit) / adjust.getTotalProdListPrice(); 		    				    			 
			    		if ( prc >= 0.5 && prc > maxPrc ) {
			    			maxPrc = prc;			    			
			    			dominantUnit = unit;			    			
			    		}		    			
		    		}
	            }
	            
	    		if ( dominantUnit != null )	    		   
	    			Dominant_Unit_of_Measure_50Pct = dominantUnit;
	    		else if ( units.size() > 0 )
	    		    Dominant_Unit_of_Measure_50Pct = 'Multiple';
	    		else
	    		     Dominant_Unit_of_Measure_50Pct = '';
	    		     
	    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Dominant_Unit_of_Measure_50Pct', String.valueOf(Dominant_Unit_of_Measure_50Pct));
       	   }	
    	   return Dominant_Unit_of_Measure_50Pct;     		
      } 
    //LastYear_NetRevenue
   public  Decimal getLastYear_NetRevenue()  {
   		if ( LastYear_NetRevenue == null )  {
   			LastYear_NetRevenue = getPastDealsNetRevenewByDate(-12);
    			
   		    if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('LastYear_NetRevenue', String.valueOf(LastYear_NetRevenue.SetScale(6)));
   		}
   		return LastYear_NetRevenue;
   	}
   	//Last2Years_NetRevenue
   	public  Decimal getLast2Years_NetRevenue() {
   		if ( Last2Years_NetRevenue == null ) {
   			Last2Years_NetRevenue = getPastDealsNetRevenewByDate(-24);
   			
   			if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Last2Years_NetRevenue', String.valueOf(Last2Years_NetRevenue.SetScale(6)));
   		}
   		return Last2Years_NetRevenue;
   	}
   	//LastSixMonths_NetRevenue
   public  Decimal getLastSixMonths_NetRevenue() {
    	if ( LastSixMonths_NetRevenue == null ) {
    		LastSixMonths_NetRevenue = getPastDealsNetRevenewByDate(-6);
    			
    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('LastSixMonths_NetRevenue', String.valueOf(LastSixMonths_NetRevenue.SetScale(6)));
    	}
    	return LastSixMonths_NetRevenue;
  }    	   	
   	//CloseDate
   public Date getCloseDate() {
    	if ( CloseDate == null )  {
    		Date lastValid = Date.valueOf(QuoteData.Constants.get('Constant_LastValidDate'));		
    		if ( QuoteData.CloseDate == null || lastValid <= QuoteData.CloseDate )
    		    	CloseDate = lastValid;
    		else 
    		    CloseDate = QuoteData.CloseDate;
    		
    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('CloseDate', String.valueOf(CloseDate));
    	}
    	return CloseDate;
   }   
   //LastYear_NumberOfDeals
   public Integer getLastYear_NumberOfDeals() {
       if ( LastYear_NumberOfDeals == null ) {
           	LastYear_NumberOfDeals = getPastDealsByDate(-12);  
           	   
           	if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('LastYear_NumberOfDeals', String.valueOf(LastYear_NumberOfDeals));        	
        }           
        return LastYear_NumberOfDeals;           
   }      	  	 
  //Number_of_Lost
  public Integer getNumber_of_Lost() {
       if ( Number_of_Lost == null ) {
    	  Number_of_Lost=0;
    	  for ( DDSToolQuoteData.HistoricalData hst : QuoteData.historicalData ) {
    	   	  if ( hst.OpptyWinLost != null && hst.OpptyWinLost == 'Lost' && hst.OpptyCloseDate > Date.valueOf('2017-01-01') ) 
    	   	  	Number_of_Lost++;  	  	
    	   }    	     	   	     		 	
    	   if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Number_of_Lost', String.valueOf(Number_of_Lost)); 
    	}
    	return Number_of_Lost;
   }    	
  //number_of_products_5pc
  public String getNumber_of_products_5pc()   {
  	  if ( number_of_products_5pc == null ) {
  	    Integer prodNum = getNumber_of_products_in_deal_5pc();
  	    
  	    if ( prodNum < 3 )
  	       number_of_products_5pc = '<3 products'; 
  	    else if ( prodNum >= 3 && prodNum <= 10 ) 
  	       number_of_products_5pc = '3-10 products';
  	     else if ( prodNum > 10 )  
  	        number_of_products_5pc = 'more than 10 products'; 
  	    
  	  	if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('number_of_products_5pc', number_of_products_5pc); 
  	  }
  	  return number_of_products_5pc;
  }
  //Number_of_products_in_deal_5pc
  public Integer getNumber_of_products_in_deal_5pc() {
  	  if ( Number_of_products_in_deal_5pc == null ) {
  	  	 Number_of_products_in_deal_5pc = 0;
  	  	 
  	  	 Map<String, Decimal> products = new Map<String, Decimal>();   		
         for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
    		  if (!pr.isProduct || pr.Input_Product == null || String.isBlank(pr.Input_Product) )
    			 continue;
    
    			 products.put(pr.Input_Product, 
    			              products.containsKey(pr.Input_Product) ? 
    			              products.get(pr.Input_Product) + pr.Input_TotalListPriceAdjusted : pr.Input_TotalListPriceAdjusted);
    	}   		
    	///get products with value > 5% of the deal
    	if ( adjust.getTotalProdListPrice() > 0 )  {    		
	    	Integer prodNum = 0;
	    	for (String prd : products.keySet()) {	    				    			 
	    		if ( products.get(prd) / adjust.getTotalProdListPrice() >= 0.05 )
	    		   prodNum++;
	    	}	    		
	    	Number_of_products_in_deal_5pc = prodNum;
    	}
  	  	if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Number_of_products_in_deal_5pc', String.valueOf(Number_of_products_in_deal_5pc)); 
  	  }
  	  return Number_of_products_in_deal_5pc;
  }
  
  //Number_Product_Category_Over5percent_2019
  public Integer getNumber_Product_Category_Over5percent_2019() {
  	  if ( Number_Product_Category_Over5percent_2019 == null ) {
  	  	  Number_Product_Category_Over5percent_2019 = 0;
  	  	  
  	  	  Map<String, Decimal> categories = new Map<String, Decimal>();
    		
    	  for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
    			if ( !pr.isProduct || pr.ProductCategory == null || String.isBlank(pr.ProductCategory) )
    		   			continue;

    			categories.put(pr.ProductCategory, 
    			               categories.containsKey(pr.ProductCategory) ? 
    			               categories.get(pr.ProductCategory) + pr.Input_TotalListPriceAdjusted : pr.Input_TotalListPriceAdjusted);
    		}   		
    		///get categories with value > 5% of the deal
    		if ( adjust.getTotalProdListPrice() > 0 )  {    		
	    		Integer categoriesNum = 0;
	    		for (String categ : categories.keySet()) {	    				    			 
	    			if ( categories.get(categ) / adjust.getTotalProdListPrice() >= 0.05 )
	    			   categoriesNum++;
	    		}	    		
	    		Number_Product_Category_Over5percent_2019 = categoriesNum;
    		}
  	  	    if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Number_Product_Category_Over5percent_2019', String.valueOf(Number_Product_Category_Over5percent_2019)); 
  	  }
  	  return Number_Product_Category_Over5percent_2019;
  }
  //Open_Platform_5Percent_2019
  public Integer getOpen_Platform_5Percent_2019() {
  	  if ( Open_Platform_5Percent_2019 == null ) {
  	  	
  	  	   Open_Platform_5Percent_2019 = getProdCategNum_5pcByName('Open Platform');
  	  	   
  	  	   if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Open_Platform_5Percent_2019', String.valueOf(Open_Platform_5Percent_2019)); 
  	  }
  	  return Open_Platform_5Percent_2019;
  }
  //WEM_5Percent_2019
  public Integer getWEM_5Percent_2019() {
  	  if ( WEM_5Percent_2019 == null ) {
  	  	
  	  	   WEM_5Percent_2019 = getProdCategNum_5pcByName('WEM');
  	  	   
  	  	   if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('WEM_5Percent_2019', String.valueOf(WEM_5Percent_2019)); 
  	  }
  	  return WEM_5Percent_2019;
  }
    
  //Self_Service_5Percent_2019
  public Integer getSelf_Service_5Percent_2019()  {
  	  if ( Self_Service_5Percent_2019 == null ) {
  	  	Self_Service_5Percent_2019 = 0;
  	  	
    	Decimal catTotalPrice = 0;	
    	for (DDSToolQuoteData.ProductLine pr : QuoteData.quoteProdLine) {
    		if ( !pr.isProduct || pr.ProductCategory == null || String.isBlank(pr.ProductCategory) )
    		   continue;
    
    		if ( pr.ProductCategory.startsWith('Self-Service') || pr.ProductCategory.startsWith('Self Service') )
    			catTotalPrice += pr.Input_TotalListPriceAdjusted;
    	}  
    	  		
    	if ( adjust.getTotalProdListPrice() > 0 ) {
    		if ( catTotalPrice / adjust.getTotalProdListPrice() >= 0.05 )	
    		  	Self_Service_5Percent_2019 = 1;
    		else
    	       Self_Service_5Percent_2019 = 0;
    	}   		
	 
  	  	 if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Self_Service_5Percent_2019', String.valueOf(Self_Service_5Percent_2019));   	  	
  	  }
  	  return Self_Service_5Percent_2019;
  }
  //Public_sector_vs_enterprise_customer
  public  String getPublic_sector_vs_enterprise_customer() {
       if ( Public_sector_vs_enterprise_customer == null ) {
      	  	
      	  if ( QuoteData.Industry != null && 
      	       (QuoteData.Industry == 'Government' || QuoteData.Industry == 'Public' ))
      	           Public_sector_vs_enterprise_customer = 'Public';
      	  else
      	  	        Public_sector_vs_enterprise_customer = 'Private';
      	  	        
      	  if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Public_sector_vs_enterprise_customer', String.valueOf(Public_sector_vs_enterprise_customer));
      	}
      	return Public_sector_vs_enterprise_customer;
   }
   // Sold To Country  
   public String getSold_To_Country()   {
    	if ( Sold_To_Country == null ) {
    		if ( QuoteData.SoldToCountry == null )
               Sold_To_Country = 'OTHER';
            else if ( QuoteData.SoldToCountry.equalsIgnoreCase('United States') )
    		   Sold_To_Country = 'USA';
    		else
    			Sold_To_Country = DDSToolSelector.getSoldToCountryMapped(QuoteData.SoldToCountry) == null ? 'OTHER' : QuoteData.SoldToCountry.toUpperCase();
    		    		
    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Sold_To_Country', String.valueOf(Sold_To_Country));
    	}
    	return Sold_To_Country;
   } 
   //Sold_To_Country_Region
   public String getSold_To_Country_Region() {
    	if ( Sold_To_Country_Region == null ) {
    		Sold_To_Country_Region = QuoteData.Region == null ? '' : QuoteData.Region;
    		
    		if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Sold_To_Country_Region', Sold_To_Country_Region);
    	}
    	return Sold_To_Country_Region;
   }
  //Sold_To_Country_Sub_Sub_Region
  public String getSold_To_Country_Sub_Sub_Region() {
    	if ( Sold_To_Country_Sub_Sub_Region == null ) {
    		Sold_To_Country_Sub_Sub_Region = QuoteData.SubSubRegion == null ? '' :  QuoteData.SubSubRegion;
    		
    		if (ddsTM.LogLevel > 1) InterCalcVarsMap.put('Sold_To_Country_Sub_Sub_Region', Sold_To_Country_Sub_Sub_Region);
    	}
    	return Sold_To_Country_Sub_Sub_Region;
   }
  //Type
  public String getType()   {
  	  if ( Type == null ) {
  	  	  Type = QuoteData.OpptyType == null ? '' : QuoteData.OpptyType;
  	  	  
  	  	  if (ddsTM.LogLevel > 1) InterCalcVarsMap.put('Type', Type);
  	  }
  	  return Type;
 } 	
 //Cluster - used in PostCalc
  public String getCluster()   {
    	if ( Cluster == null ) {
    		String clstr = DDSToolSelector.getCluster(QuoteData.Region, QuoteData.SubSubRegion);
    		if ( clstr == null || String.isBlank(clstr) ) 
    		    Cluster = 'OTHER';
    		else 
    		    Cluster = clstr;
    		    
    	    if (ddsTM.LogLevel > 0) InterCalcVarsMap.put('Cluster', String.valueOf(Cluster));
    	}
    	return Cluster;
    } 

}