/* Mariya Steason - Aug 2018
   Purpose: DDSToolSelector is a class in the quote scoring tool (DDS Tool)
   Test class: DDSTool_Test
*/
public class DDSToolSelector {
	
	public static List<BigMachines__Quote_Product__c> quoteProductsByQuoteId(String quoteId) {
		if ( String.isBlank(quoteId) )
		   return null;
		
		List<BigMachines__Quote_Product__c> prods = [SELECT Id, BigMachines__Quote__r.Opportunity_Close_Date__c, 
	        BigMachines__Quote__r.CreatedDate, BigMachines__Quote__r.New_Price_Book__c,
            BigMachines__Quote__r.BigMachines__Opportunity__r.Name, BigMachines__Quote__r.Opp_End_User_Country__c, 
            BigMachines__Quote__r.End_User_ID__c, BigMachines__Quote__r.Sold_To_Name__c, 
            BigMachines__Quote__r.Offering_Type__c, BigMachines__Quote__r.Offer__c, BigMachines__Quote__r.Order_Type__c,
            BigMachines__Quote__r.Amendment_For__r.Quote__r.Deal_Score__c,
            BigMachines__Quote__r.BigMachines__Opportunity__r.Type, 
            BigMachines__Quote__r.Total_Discount_Genesys_Products_Only__c,
            BigMachines__Quote__r.Quote_Opportunity_Type__c, BigMachines__Quote__r.End_User_ID__r.FYM_Rate__c,        
            BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Primary_Line_of_Business__c,
            BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__c, 
            BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Name, 
            BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,
            BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.RU__c, 
            BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.SubRU__c,
            BigMachines__Quote__r.BigMachines__Opportunity__r.Partner_Opportunity_Source__c,
            BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Rate__c, 
            BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Effective_Date__c,
            BigMachines__Quote__r.End_User_ID__r.Contractual_PC_FYM_Expiration_Date__c,
            BigMachines__Quote__r.End_User_ID__r.Industry, BigMachines__Quote__r.End_User_ID__r.Industry__c,
			BigMachines__Quote__r.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c, BigMachines__Quote__r.Annual_Contract_Value_1__c,
			BigMachines__Quote__r.Require_Separate_Quote_for_Genesys_Care__c, BigMachines__Quote__r.Reduced_Genesys_Care__c,
            BigMachines__Quote__r.Quote_Number__c, BigMachines__Quantity__c, BigMachines__Product__c, 
            BigMachines__Product__r.Third_Party__c, BigMachines__Product__r.APN_Number__c,
            BigMachines__Product__r.Name, BigMachines__Product__r.Description, BigMachines__Product__r.Partner_Margin_Category__c, 
            BigMachines__Product__r.Type__c, BigMachines__Product__r.Product_Category1__c, BigMachines__Product__r.Unit_of_Measure__c, 
            BigMachines__Quote__r.Order_Numb_of_Maint_Months__c, BigMachines__Quote__r.Total_Discount_Genesys_and_Third_Party__c,
            Ext_List__c, Ext_Net_Price__c, NewExtListPrice__c, CurrencyIsoCode, Genesys_Care_Amount__c, New_Ext_Net_Price__c, 
            List_Price_1__c, List_Price__c, Ext_List_Price_1__c, Net_Unit_Price_1__c,
            BigMachines__Product__r.One_Time_Charge__c, Discount_1__c, Total_Discount__c,
            BigMachines__Quote__r.Genesys_Care_Rate__c, BigMachines__Quote__r.Genesys_Care_Overide__c,
            BigMachines__Quote__r.Genesys_Care_Default_Pricing_Percentage__c, BigMachines__Product__r.NG5_NA_USD_Price__c, Weightage__c,
            Bundle__c, Bundle_Line__c, Bundle__r.Name, Bundle__r.Group_Type__c,
            BigMachines__Product__r.Product_Specific_Discount__c, BigMachines__Product__r.Maturity__c,
            BigMachines__Quote__r.Customer_Contractual_Rate__c, BigMachines__Quote__r.Genesys_Care_Contractual_Rate__c,
            Dropped_Products__c, BigMachines__Quote__r.Total_Discount_Gnsys_and_Third_Party_CR__c,
            Subscription_Product__c, Subscription_Product__r.Disc__c, Subscription_Product__r.Quantity__c,
			BigMachines__Quote__r.Lever__c
			FROM BigMachines__Quote_Product__c 
			WHERE BigMachines__Quote__c =: quoteId AND Subscription_Burst_Term__c = null];
				
		return prods;
	}
		
	public static List<BigMachines__Quote_Product__c> historicalQuoteDataByAccountId (String accntId, String opptyId)  {
		if ( String.isBlank(accntId) )
		   return null;
		List<BigMachines__Quote_Product__c> prods = [SELECT BigMachines__Quote__r.BigMachines__Opportunity__c, 
			    BigMachines__Quote__r.BigMachines__Opportunity__r.Name, BigMachines__Quote__r.Opportunity_Close_Date__c, 
			    BigMachines__Quote__r.Opportunity_Offering_Type__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c,
	  	        New_Ext_Net_Price_USD__c, Ext_List__c, BigMachines__Product__r.Product_Category1__c,
	  	        BigMachines__Product__r.Name, BigMachines__Product__r.Type__c, BigMachines__Quote__r.BigMachines__Opportunity__r.CreatedDate 
      		FROM BigMachines__Quote_Product__c 
            WHERE BigMachines__Quote__r.BigMachines__Opportunity__r.AccountId = :accntId 
              AND BigMachines__Quote__r.BigMachines__Opportunity__c != :opptyId  /// remove current oppty from the historical list 
              AND BigMachines__Quote__r.BigMachines__Is_Primary__c = true
              AND BigMachines__Quote__r.BigMachines__Opportunity__r.Cloud_Renewal__c = false
              AND BigMachines__Quote__r.Opportunity_Offering_Type__c IN ('PureConnect','PureEngage')         
              AND (BigMachines__Product__r.Product_Category1__c IN ('Open Platform','Digital','Inbound','Outbound','WEM','Bundle',
                                                                     'Self-Service & Automation','Self Service')  OR
                  BigMachines__Product__r.Product_Category1__c = null)           
              AND BigMachines__Quote__r.Quote_Business_Type__c != 'Renewal'
              AND BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c IN ('Won','Lost')
              AND BigMachines__Quote__r.BigMachines__Opportunity__r.Primary_Line_of_Business__c = 'On Premise' 
              AND BigMachines__Quote__r.BigMachines__Opportunity__r.RecordType.Name = 'GEN - Opportunity Record Type' 
              AND BigMachines__Quote__r.BigMachines__Opportunity__r.CloseDate > 2012-01-01
              AND BigMachines__Quote__r.BigMachines__Opportunity__r.CloseDate < 2019-01-07];
       
        return prods;             
	}
	
	public static Decimal getPartnerContractualDiscount(String soldToId, String offering, Boolean isSubscrpt) {
		 String offer;
		 Decimal discount;		 
		 try {
			 if ( isSubscrpt )
			    offer = offering + ' Subscription';
			 else
			    offer = offering + '% Premise';  
			 
			 List<Partner_Discount__c> disc = [SELECT Discount__c FROM Partner_Discount__c 
			                                   WHERE Account__c = :soldToId AND Category__c = 'Base Line Discount'
			                                    AND Type__c LIKE :offer AND (Year__c ='Year 1' OR Year__c = null)];
			 if ( !disc.isEmpty() )
			    discount = disc[0].Discount__c / 100;
		 }
		 catch(Exception ex) {
		 	return null;
		 }		 
		 return discount;
	}
	
	public static String getCluster(String region, String subRegion) {
		if ( region == null || String.isBlank(region) || subRegion == null || String.isBlank(subRegion) )
		   return null;

		 List<DDS_Tool_Cluster_Mapping__c> clusters = [SELECT Cluster__c FROM DDS_Tool_Cluster_Mapping__c 
		                                       		   WHERE Type__c = 'Region SubRegion Mapping'
		                                          		AND Region__c = :region.toUpperCase().trim() 
		                                          		AND SoldTo_SubSubRegion__c = :subRegion.toUpperCase().trim()];
		if ( clusters.isEmpty() )
		    return null;
		    
		return clusters[0].Cluster__c; 
	}
	
	public static String getSoldToCountryMapped(String country) {
		if ( country == null || String.isBlank(country) )
		   return null;

		 List<DDS_Tool_Cluster_Mapping__c> clusters = [SELECT Country_Mapped__c FROM DDS_Tool_Cluster_Mapping__c 
		                                       		   WHERE Country_Mapped__c = :country.toUpperCase().trim()]; 
		if ( clusters.isEmpty() )
		    return null;
		    
		return clusters[0].Country_Mapped__c; 
	}

	public static List<DDS_Tool_Constants__c> getConstants(String offering) {
		if ( offering == null || String.isBlank(offering))
		    return null;
		    
		return [SELECT Variable_Name__c, Variable_Value__c FROM DDS_Tool_Constants__c 
		         WHERE Type__c = 'Constant' 
		         AND (Offering__c = null OR Offering__c = :offering)];
	} 

	public static Decimal getConversionRateByIsoCode(String isoCode, Date quoteCreateDate) { 
		Decimal rate = 1;
		if ( isoCode != null && String.isNotBlank(isoCode) ) {

			Date dt = Date.valueOf(quoteCreateDate);
			List<DatedConversionRate> curr = [SELECT ConversionRate FROM DatedConversionRate 
			                                  WHERE IsoCode = :isoCode AND StartDate <= :dt AND NextStartDate > :dt]; 
			if ( !curr.isEmpty() )
			   rate = curr[0].ConversionRate;
		}
		return rate;
	}
	
	public static Currency_Configuration__c getCurrcyConfigByPriceBook(String prBook, String offering, Date quoteCreateDate) {
		Currency_Configuration__c retval;		
		if ( prBook != null && String.isNotBlank(prBook) ) {
			
			///REMOVE WHEN CORRECTED IN SFDC CURRENCY CONFIGURATION
			if ( prBook.equals('NG1_APAC_KOREA_SE_ASIA_USD') )	
			       prBook = 'NG1_APAC_KOREA_SE-ASIA_USD';
			    						
			Date dt = Date.valueOf(quoteCreateDate);
			String queryStr = 'SELECT Conversion_Rate__c, Multiplier__c FROM Currency_Configuration__c ' +
				               'WHERE Price_Book__c = :prBook AND Offering_Type__c INCLUDES(:offering) ' +
				               'AND Start_Date__c <= :dt AND End_Date__c > :dt';
		    
		    List<Currency_Configuration__c> cur = Database.query(queryStr);
	
			if ( !cur.isEmpty() ) 
				retval = cur[0];				
			else if ( prBook.contains('_EMEA_') ) {
				prBook = prBook.replace('_EMEA_', '_EUROPE_');	
				cur = Database.query(queryStr);
				
				if ( !cur.isEmpty() ) 
					retval = cur[0];	
			}
		}
		return retval;
	}
	
	public static List<DDS_Tool_Constants__c> getCoeffByType(String offer, String coeffType) {
		List<DDS_Tool_Constants__c> coeff;
		if ( offer != null && String.isNotBlank(offer) && coeffType != null && String.isNotBlank(coeffType) )  {			
			coeff = [SELECT Cluster__c, Variable_Name__c, Coefficient_Value__c
			         FROM DDS_Tool_Constants__c
			         WHERE Coefficient_Type__c = :coeffType AND Offering__c = :offer];
		}		
		return coeff;
	}
	
	public static List<DDS_Tool_Constants__c> getPureBridgeProds() {
		return [SELECT Variable_Name__c, Variable_Value__c FROM DDS_Tool_Constants__c WHERE Type__c = 'Remove Product'];
	}
	
	public static Opportunity getPSOpportunity(String parentId) {
		Opportunity oppty;
		try {
		    List<Opportunity> oppts = [SELECT Id, Sold_Margin_PPW__c, PS_Amount_On_Premise__c, CloseDate, CurrencyIsoCode
				        FROM Opportunity 
				        WHERE RecordType.DeveloperName = 'Professional_Services' AND ParentOpportunity__c = :parentId
				        ORDER BY CloseDate DESC];
				        
		     if ( !oppts.isEmpty() )
		       oppty = oppts[0]; 
		 }
		 catch(Exception ex) {
		 		return null;
		 }
		 
		return oppty;
	}
	
}