/*
 * Class            : AutoRenewalUtil
 * Description      : Util Class for all processing methods required to handle Auto Quoting for Pure Enagage and Pure Connect.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jul 03, 2017
 * Test Class       : AutoRenewalAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY		Modified Date		Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 *
 */ 
 public class AutoRenewalUtil {

    public static Map<String,Decimal> map_ConversionRates;
    public static Map<String,Decimal> partnerDiscountMap;
    static {
        map_ConversionRates = new Map<String,Decimal>();
		for(CurrencyType curr: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
        	map_ConversionRates.put(curr.IsoCode,curr.ConversionRate);
		}         
    }
    
    
    public static Account endUserAccount;
    public static Account soldToAccount;
    public static String offeringType; 
    
    // Find all "Sold To" Accounts for the given "End User"
    public static void createAutoRenewalQuotes(Account autoRenewAccount){
    	offeringType = '';
    	endUserAccount = autoRenewAccount;
    	
        Integer contractTerm = endUserAccount.Auto_Renew_Contract_Term__c != NULL ? endUserAccount.Auto_Renew_Contract_Term__c.intValue() : 12;
        Date startDate = endUserAccount.Auto_Renew_Anniversary__c.addDays(-2);
        Date endDate = startDate.addMonths(contractTerm).addDays(-3);
        
        Map<String, List<String>> soldTo_PureEngage_Opportunities = new  Map<String, List<String>>();
        Map<String, List<String>> soldTo_PureConnect_Opportunities = new  Map<String, List<String>>();
        for(ServiceContract sc : [SELECT id, Name, Renewal_Opportunity__c, Renewal_Opportunity__r.Name, Renewal_Opportunity__r.CloseDate,
									Sold_To_Name__c, Sold_To_Name__r.Name, AccountId, Account.Name, Offering_Type__c, Renewal_Opportunity__r.Lines_of_Businesses__c 
                                  FROM ServiceContract 
                                  WHERE Renewal_Opportunity__r.AccountId = :endUserAccount.Id
                                  	AND Renewal_Opportunity__r.RecordType.Name = 'Genesys Renewal' 
                                  	AND Renewal_Opportunity__r.Opportunity_Status__c = 'In Progress'
                                  	AND Renewal_Opportunity__r.CloseDate >= :startDate
                                  	AND Renewal_Opportunity__r.CloseDate <= :endDate
                                  	AND Renewal_Opportunity__r.Already_Auto_Renew__c = false
                                 	ORDER BY Sold_To_Name__c ASC, Renewal_Opportunity__r.CloseDate ASC])
        {
            if(sc.Offering_Type__c == 'PureConnect' || sc.Renewal_Opportunity__r.Lines_of_Businesses__c == 'PureConnect'){
                if(soldTo_PureConnect_Opportunities.containsKey(sc.Sold_To_Name__c)){
                    soldTo_PureConnect_Opportunities.get(sc.Sold_To_Name__c).add(sc.Renewal_Opportunity__c);	                             
                } else {
                    soldTo_PureConnect_Opportunities.put(sc.Sold_To_Name__c, new List<String>{sc.Renewal_Opportunity__c});
                }                        
            } else {
                if(soldTo_PureEngage_Opportunities.containsKey(sc.Sold_To_Name__c)){
                    soldTo_PureEngage_Opportunities.get(sc.Sold_To_Name__c).add(sc.Renewal_Opportunity__c);	                             
                } else {
                    soldTo_PureEngage_Opportunities.put(sc.Sold_To_Name__c, new List<String>{sc.Renewal_Opportunity__c});
                }                        
            }
        }
		
        // Multiple End User & Sold To combinations are found .. send an email to Genesys Care
        // PureEngage
        if(soldTo_PureEngage_Opportunities.size() > 1){
        	buildAndSendEmail(endUserAccount, 'PureEngage');
        } else {
            for(String soldToAccountVar : soldTo_PureEngage_Opportunities.keySet()){
            	soldToAccount = [SELECT Id, Name, Type, Partner_Product_Margin__c, Partner_GU_Margin__c  FROM Account WHERE Id = :soldToAccountVar];
            	offeringType = 'PureEngage';
            	createQuote(soldTo_PureEngage_Opportunities.get(soldToAccountVar));
        	}
        }
        
        // Multiple End User & Sold To combinations are found .. send an email to Genesys Care
        // PureConnect
        if(soldTo_PureConnect_Opportunities.size() > 1){
        	buildAndSendEmail(endUserAccount, 'PureConnect');
        } else {
            for(String soldToAccountVar : soldTo_PureConnect_Opportunities.keySet()){
            	soldToAccount = [SELECT Id, Name, Type, Partner_Product_Margin__c, Partner_GU_Margin__c  FROM Account WHERE Id = :soldToAccountVar];
            	offeringType = 'PureConnect';
            	createQuote(soldTo_PureConnect_Opportunities.get(soldToAccountVar));
        	}
        }
    } 
    
    // Find all "Sold To" Accounts for the given "End User"
    public static void createAutoRenewalGapQuotes(Account autoRenewAccount){
    	endUserAccount = autoRenewAccount;
		
		Map<String, Map<Date, List<String>>> soldTo_PureEngage_Opportunities = new  Map<String, Map<Date, List<String>>>();
       	Map<String, Map<Date, List<String>>>  soldTo_PureConnect_Opportunities = new Map<String, Map<Date, List<String>>>();
        for(ServiceContract sc : [SELECT id, Name, Renewal_Opportunity__c, Renewal_Opportunity__r.Name, Renewal_Opportunity__r.CloseDate,
										Sold_To_Name__c, Sold_To_Name__r.Name, AccountId, Account.Name, Offering_Type__c, Renewal_Opportunity__r.Lines_of_Businesses__c 
                                  	FROM ServiceContract 
                                  	WHERE Renewal_Opportunity__r.AccountId = :endUserAccount.Id 
                                  	AND Renewal_Opportunity__r.Eligible_for_Gap_Quote__c = true 
                                 	ORDER BY Sold_To_Name__c ASC, Renewal_Opportunity__r.CloseDate ASC])
        {
            if(sc.Offering_Type__c == 'PureConnect' || sc.Renewal_Opportunity__r.Lines_of_Businesses__c == 'PureConnect'){
                if(soldTo_PureConnect_Opportunities.containsKey(sc.Sold_To_Name__c)){
                	if(soldTo_PureConnect_Opportunities.get(sc.Sold_To_Name__c).containsKey(sc.Renewal_Opportunity__r.CloseDate)){
                		soldTo_PureConnect_Opportunities.get(sc.Sold_To_Name__c).get(sc.Renewal_Opportunity__r.CloseDate).add(sc.Renewal_Opportunity__c);
                	} else {
                		Map<Date, List<String>> innerMap = new Map<Date, List<String>>();
                		innerMap.put(sc.Renewal_Opportunity__r.CloseDate, new List<String>{sc.Renewal_Opportunity__c});
	                    soldTo_PureConnect_Opportunities.put(sc.Sold_To_Name__c, innerMap);
                	}
                } else {
                	Map<Date, List<String>> innerMap = new Map<Date, List<String>>();
                	innerMap.put(sc.Renewal_Opportunity__r.CloseDate, new List<String>{sc.Renewal_Opportunity__c});
	                soldTo_PureConnect_Opportunities.put(sc.Sold_To_Name__c, innerMap);
                }                        
            } else {
            	if(soldTo_PureEngage_Opportunities.containsKey(sc.Sold_To_Name__c)){
                	if(soldTo_PureEngage_Opportunities.get(sc.Sold_To_Name__c).containsKey(sc.Renewal_Opportunity__r.CloseDate)){
                		soldTo_PureEngage_Opportunities.get(sc.Sold_To_Name__c).get(sc.Renewal_Opportunity__r.CloseDate).add(sc.Renewal_Opportunity__c);
                	} else {
                		Map<Date, List<String>> innerMap = new Map<Date, List<String>>();
                		innerMap.put(sc.Renewal_Opportunity__r.CloseDate, new List<String>{sc.Renewal_Opportunity__c});
	                    soldTo_PureEngage_Opportunities.put(sc.Sold_To_Name__c, innerMap);
                	}
                } else {
                	Map<Date, List<String>> innerMap = new Map<Date, List<String>>();
                	innerMap.put(sc.Renewal_Opportunity__r.CloseDate, new List<String>{sc.Renewal_Opportunity__c});
	                soldTo_PureEngage_Opportunities.put(sc.Sold_To_Name__c, innerMap);
                }     
            }
        }
		
        // PureEngage
        for(String soldToAccountVar : soldTo_PureEngage_Opportunities.keySet()){
        	soldToAccount = [SELECT Id, Name, Type, Partner_Product_Margin__c, Partner_GU_Margin__c  FROM Account WHERE Id = :soldToAccountVar];
        	offeringType = 'PureEngage';
        	for(Date closeDate : soldTo_PureEngage_Opportunities.get(soldToAccountVar).keySet()){
	        	createGapQuote(soldTo_PureEngage_Opportunities.get(soldToAccountVar).get(closeDate));
        	}
    	}

        // PureConnect
        for(String soldToAccountVar : soldTo_PureConnect_Opportunities.keySet()){
        	soldToAccount = [SELECT Id, Name, Type, Partner_Product_Margin__c, Partner_GU_Margin__c  FROM Account WHERE Id = :soldToAccountVar];
        	offeringType = 'PureConnect';
        	for(Date closeDate : soldTo_PureConnect_Opportunities.get(soldToAccountVar).keySet()){
	        	createGapQuote(soldTo_PureConnect_Opportunities.get(soldToAccountVar).get(closeDate));
        	}
    	}
    }
    
    
    public static void createQuote(List<String> opportunityIds){
        Opportunity baseOpportunity = [SELECT id, Name, AccountId, BusinessPartner__c, Service_Contract__c,
                                      CurrencyISOCode,Previous_Maintenance_Rate__c,Gene_Care_Specialist__c,Gene_Care_Specialist__r.Name  
                                      FROM Opportunity WHERE id = :opportunityIds[0]];
		
        Integer contactTermMonths = endUserAccount.Auto_Renew_Contract_Term__c != NULL ? endUserAccount.Auto_Renew_Contract_Term__c.intValue() : 12;
        Decimal contractIncreaseRate = (endUserAccount.Increased_Percentage__c != NULL && endUserAccount.Increased_Percentage__c && endUserAccount.Auto_Renew_Contractual_Increase__c != NULL ) ? endUserAccount.Auto_Renew_Contractual_Increase__c : 0 ;
        Date startDate = endUserAccount.Auto_Renew_Anniversary__c;
        Date endDate = startDate.addMonths(contactTermMonths).addDays(-1);
        
        // Create Quote with Base Opportunity
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
		quote.Quote_Created_Date__c = System.today();
		quote.Expiration_Date__c = Date.today().addMonths(3);
		quote.BigMachines__Opportunity__c = baseOpportunity.id;
        quote.Total_Maintenance_Amount_Due__c = null;
        quote.Total_Before_Tax_Maintenance__c = null;
        quote.End_User_ID__c = baseOpportunity.AccountId;
        quote.BigMachines__Account__c = baseOpportunity.AccountId;
		quote.Sold_To_Name__c = baseOpportunity.BusinessPartner__c;
        quote.CurrencyISOCode = baseOpportunity.CurrencyISOCode;
        quote.Quote_Business_Type__c = 'Renewal';
        quote.Order_Type__c = 'Revenue';
        quote.BigMachines__Status__c = 'Quote In Progress';
        quote.Maintenance_Start_Date__c = startDate;
		quote.Maintenance_End_Date__c = endDate;           
		quote.Increase_type__c = (endUserAccount.Increased_Percentage__c != NULL && endUserAccount.Increased_Percentage__c == true && endUserAccount.Auto_Renew_Contractual_Increase__c != NULL) ? 'Increased Percentage' : 'Genesys Care Rate';  
        quote.Previous_Maint_Rate__c = baseOpportunity.Previous_Maintenance_Rate__c;
        quote.Current_Maint_Rate__c = 0.0;
		quote.Actual_Maint_Rate__c = 0.0;

        if(baseOpportunity.Gene_Care_Specialist__c != null)
            quote.Genesys_Care_Rep_Name__c = baseOpportunity.Gene_Care_Specialist__r.Name;

		quote.Quote_Mailing_List__c = getSendQuoteEmailAddresses(baseOpportunity.BusinessPartner__c);

        insert quote;

        
		// To bypass quote product trigger
        Util.Bypass_Trigger_Chk = true;
        
        String supportProduct = offeringType == 'PureConnect' ? endUserAccount.Support_Option__c : endUserAccount.Genesys_Care_Offering__c;
		if(offeringType == 'PureEngage'){
	        if(supportProduct.endsWith('(End User)') || supportProduct.endsWith('(Partner)')){
				supportProduct = supportProduct.replace('-New','-Renewal');        	
	        } else {
	        	supportProduct = supportProduct + '-Renewal' + (soldToAccount.Type == 'Partner' ? '(Partner)' : '(End User)'); 
	        }						
		}        						
        
        System.debug('supportProduct = ' + supportProduct);
        Product2 product = [SELECT Id,Name,Type__c,Description,Care_Rate_Applicable__c,Genesys_Care_Quote__c,APN_Number__c 
        					FROM Product2 WHERE Description = :supportProduct AND Type__c = 'Genesys Care' LIMIT 1];
            
        BigMachines__Quote_Product__c quoteProductsGenesysCare = populateQuoteServiceLevel(quote, product);
        insert quoteProductsGenesysCare;
        Util.Bypass_Trigger_Chk = false;
        // Set the Quote Level Values - Update Quote
        if(product.Description != null && product.Description != ''){
            String plus = '';
            List<String> list_Words = product.Description.split(' ');
            if(product.Description != null && product.Description.contains('Support')) {
                quote.Service_Level__c = product.Description;
            } else if(product.Description != null && product.Description.contains('Plus') && product.Description.contains('Business')) {
                quote.Service_Level__c = 'Business Care Plus';
            } else if(product.Description != null && product.Description.contains('Plus') && product.Description.contains('Premium')) {
                quote.Service_Level__c = 'Premium Care Plus';
            } else if(list_Words.size() > 0) {
                quote.Service_Level__c = list_Words[0] + ' Care';
            }
        }
        
        Decimal decDefaultCareRate = 0.0;
        String careRateFieldAPIName = product.Care_Rate_Applicable__c;
        String strQuery = 'SELECT Country__r.Tax_Rate__c, Country__r.' + careRateFieldAPIName + ' FROM Account WHERE Country__c != null AND Id = \'' + quote.End_User_ID__c + '\'';
        
        List<Account> accountsForRates = Database.query(strQuery);
        if(accountsForRates.size() > 0){
            // Tax Rate
            if(quote.Tax_Rate__c == null)
                quote.Tax_Rate__c = accountsForRates[0].Country__r.Tax_Rate__c;
            // Default Care Rate
            decDefaultCareRate = (Decimal) accountsForRates[0].getSObject('Country__r').get(careRateFieldAPIName);
        }

		// If the Quote is 'Genesys Care Rate'
        if(quote.Increase_type__c == 'Genesys Care Rate' && endUserAccount.Auto_Renew_Rate__c != NULL && endUserAccount.Auto_Renew_Rate__c > 0)
			decDefaultCareRate = endUserAccount.Auto_Renew_Rate__c;

		// If the Quote is 'Increased Percentage'
		if(quote.Increase_type__c ==  'Increased Percentage' && quote.Previous_Maint_Rate__c > 0)
			decDefaultCareRate = quote.Previous_Maint_Rate__c;
	
		// Update Quote Name & Previously Set Service_Level__c     
        quote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id = :quote.id].Quote_Number__c + '-A';
		update quote;
        
        // For PureConnect need to get maintenanceDiscount
		Decimal quoteFinalRate = decDefaultCareRate;
		
		// Create a quote period when quote is saved
		List<Quote_Period__c> quotePeriods = new List<Quote_Period__c>();
        if(quote.Quote_Cloned_Revised__c == null && quote.Maintenance_Start_Date__c != null && quote.Maintenance_End_Date__c != null){
            Date qpStartDate = quote.Maintenance_Start_Date__c;
            Date qpEndDate = quote.Maintenance_Start_Date__c.addMonths(12).addDays(-1);
            for(Integer i=0; i<contactTermMonths/12; i++){
                // Need to add Maintenance Discount
            	quotePeriods.add(new Quote_Period__c(Quote__c = quote.Id, Start_Date__c = qpStartDate, End_Date__c = qpEndDate,
                                                                 Default_Period_Care_Rate__c = quoteFinalRate, Default_Increase__c = contractIncreaseRate));
                qpStartDate = qpEndDate.addDays(1);
                qpEndDate = qpStartDate.addMonths((i+1) * 12).addDays(-1);
            }
            insert quotePeriods;
        }
        
         // CoTerm Other Opportunities 
        if(opportunityIds.size() > 1){
            List<String> cotermOpportunityIds = new List<String>();
            for(Integer i=1; i < opportunityIds.size(); i++){
                cotermOpportunityIds.add(opportunityIds[i]);
            }
            
            List<Quote_Service_Contracts__c> cotermServiceContracts = new List<Quote_Service_Contracts__c>();
            for(ServiceContract sc : [SELECT id FROM ServiceContract WHERE Renewal_Opportunity__c IN :cotermOpportunityIds]){
                cotermServiceContracts.add(new Quote_Service_Contracts__c(Quote__c = quote.Id, Service_Contract__c = sc.Id));
            }
            
            if(cotermServiceContracts.size() > 0)
                insert cotermServiceContracts;
        }

		// Copy all Products from Co-Termed Service Contracts        
        syncQuoteProducts(quote);
        applyPureConnectUpgrades(quote);
        
        // Do calculations ...
        CreateQuoteController quoteController = new CreateQuoteController(quote.id);
        quoteController.initializeRates();
        quoteController.doCalculations();
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for(String oppId : opportunityIds){
        	opportunities.add(new Opportunity(id=oppId, Already_Auto_Renew__c = true));
        }
        update opportunities;
    } 
    
	public static void createGapQuote(List<String> opportunityIds){
        Opportunity baseOpportunity = [SELECT id, Name, AccountId, BusinessPartner__c, Service_Contract__c,
                                      CurrencyISOCode,Previous_Maintenance_Rate__c,Gene_Care_Specialist__c,Gene_Care_Specialist__r.Name  
                                      FROM Opportunity WHERE id = :opportunityIds[0]];
		
        Integer contactTermMonths = endUserAccount.Auto_Renew_Contract_Term__c != NULL ? endUserAccount.Auto_Renew_Contract_Term__c.intValue() : 12;
        Decimal contractIncreaseRate = (endUserAccount.Increased_Percentage__c != NULL && endUserAccount.Increased_Percentage__c == true && endUserAccount.Auto_Renew_Contractual_Increase__c != NULL ) ? endUserAccount.Auto_Renew_Contractual_Increase__c : 0 ;
        Date startDate = Date.today();
        Date endDate = endUserAccount.Auto_Renew_Anniversary__c.addMonths(contactTermMonths).addDays(-1);
        
        // Create Quote with Base Opportunity
        BigMachines__Quote__c quote = new BigMachines__Quote__c();
		quote.Quote_Created_Date__c = System.today();
		quote.Expiration_Date__c = Date.today().addMonths(3);
		quote.BigMachines__Opportunity__c = baseOpportunity.id;
        quote.Total_Maintenance_Amount_Due__c = null;
        quote.Total_Before_Tax_Maintenance__c = null;
        quote.End_User_ID__c = baseOpportunity.AccountId;
        quote.BigMachines__Account__c = baseOpportunity.AccountId;
		quote.Sold_To_Name__c = baseOpportunity.BusinessPartner__c;
        quote.CurrencyISOCode = baseOpportunity.CurrencyISOCode;
        quote.Quote_Business_Type__c = 'Renewal';
        quote.Order_Type__c = 'Revenue';
        quote.BigMachines__Status__c = 'Quote In Progress';
        quote.Maintenance_Start_Date__c = startDate;
		quote.Maintenance_End_Date__c = endDate;           
		quote.Increase_type__c = (endUserAccount.Increased_Percentage__c != NULL && endUserAccount.Increased_Percentage__c == true && endUserAccount.Auto_Renew_Contractual_Increase__c != NULL) ? 'Increased Percentage' : 'Genesys Care Rate';
        quote.Previous_Maint_Rate__c = baseOpportunity.Previous_Maintenance_Rate__c;
        quote.Current_Maint_Rate__c = 0.0;
		quote.Actual_Maint_Rate__c = 0.0;

        if(baseOpportunity.Gene_Care_Specialist__c != null)
            quote.Genesys_Care_Rep_Name__c = baseOpportunity.Gene_Care_Specialist__r.Name;

		quote.Quote_Mailing_List__c = getSendQuoteEmailAddresses(baseOpportunity.BusinessPartner__c);
        insert quote;
        
		// To bypass quote product trigger
        Util.Bypass_Trigger_Chk = true;
        
        String supportProduct = offeringType == 'PureConnect' ? endUserAccount.Support_Option__c : endUserAccount.Genesys_Care_Offering__c;
		if(offeringType == 'PureEngage'){
	        if(supportProduct.endsWith('(End User)') || supportProduct.endsWith('(Partner)')){
				supportProduct = supportProduct.replace('-New','-Renewal');        	
	        } else {
	        	supportProduct = supportProduct + '-Renewal' + (soldToAccount.Type == 'Partner' ? '(Partner)' : '(End User)'); 
	        }						
		}        						
        
        Product2 product = [SELECT Id,Name,Type__c,Description,Care_Rate_Applicable__c,Genesys_Care_Quote__c,APN_Number__c 
        					FROM Product2 WHERE Description = :supportProduct AND Type__c = 'Genesys Care' LIMIT 1];
            
        BigMachines__Quote_Product__c quoteProductsGenesysCare = populateQuoteServiceLevel(quote, product);
        insert quoteProductsGenesysCare;
        Util.Bypass_Trigger_Chk = false;

        // Set the Quote Level Values - Update Quote
        if(product.Description != null && product.Description != ''){
            String plus = '';
            List<String> list_Words = product.Description.split(' ');
            if(product.Description != null && product.Description.contains('Support')) {
                quote.Service_Level__c = product.Description;
            } else if(product.Description != null && product.Description.contains('Plus') && product.Description.contains('Business')) {
                quote.Service_Level__c = 'Business Care Plus';
            } else if(product.Description != null && product.Description.contains('Plus') && product.Description.contains('Premium')) {
                quote.Service_Level__c = 'Premium Care Plus';
            } else if(list_Words.size() > 0) {
                quote.Service_Level__c = list_Words[0] + ' Care';
            }
        }
        
        Decimal decDefaultCareRate = 0.0;
        String careRateFieldAPIName = product.Care_Rate_Applicable__c;
        String strQuery = 'SELECT Country__r.Tax_Rate__c, Country__r.' + careRateFieldAPIName + ' FROM Account WHERE Country__c != null AND Id = \'' + quote.End_User_ID__c + '\'';
        
        List<Account> accountsForRates = Database.query(strQuery);
        if(accountsForRates.size() > 0){
            // Tax Rate
            if(quote.Tax_Rate__c == null)
                quote.Tax_Rate__c = accountsForRates[0].Country__r.Tax_Rate__c;
            // Default Care Rate
            decDefaultCareRate = (Decimal) accountsForRates[0].getSObject('Country__r').get(careRateFieldAPIName);
        }

		// If the Quote is 'Genesys Care Rate'
        if(quote.Increase_type__c == 'Genesys Care Rate' && endUserAccount.Auto_Renew_Rate__c != NULL && endUserAccount.Auto_Renew_Rate__c > 0)
			decDefaultCareRate = endUserAccount.Auto_Renew_Rate__c;

		// If the Quote is 'Increased Percentage'
		if(quote.Increase_type__c ==  'Increased Percentage' && quote.Previous_Maint_Rate__c > 0)
			decDefaultCareRate = quote.Previous_Maint_Rate__c;
	
		// Update Quote Name & Previously Set Service_Level__c     
        quote.Name = [SELECT Quote_Number__c FROM BigMachines__Quote__c WHERE id = :quote.id].Quote_Number__c + '-A';
		update quote;
        
		// For PureConnect need to get maintenanceDiscount
		Decimal quoteFinalRate = decDefaultCareRate;
		
		// Create a quote period when quote is saved
		List<Quote_Period__c> quotePeriods = new List<Quote_Period__c>();
        if(quote.Quote_Cloned_Revised__c == null && quote.Maintenance_Start_Date__c != null && quote.Maintenance_End_Date__c != null){
            Date qpStartDate = quote.Maintenance_Start_Date__c;
            Date qpEndDate = quote.Maintenance_Start_Date__c.addMonths(12).addDays(-1);
            for(Integer i=0; i<contactTermMonths/12; i++){
                // Need to add Maintenance Discount
            	quotePeriods.add(new Quote_Period__c(Quote__c = quote.Id, Start_Date__c = qpStartDate, End_Date__c = qpEndDate,
                                                                 Default_Period_Care_Rate__c = quoteFinalRate, Default_Increase__c = contractIncreaseRate));
                qpStartDate = qpEndDate.addDays(1);
                qpEndDate = qpStartDate.addMonths((i+1) * 12).addDays(-1);
            }
            insert quotePeriods;
        }
        
         // CoTerm Other Opportunities 
        if(opportunityIds.size() > 1){
            List<String> cotermOpportunityIds = new List<String>();
            for(Integer i=1; i < opportunityIds.size(); i++){
                cotermOpportunityIds.add(opportunityIds[i]);
            }
            
            List<Quote_Service_Contracts__c> cotermServiceContracts = new List<Quote_Service_Contracts__c>();
            for(ServiceContract sc : [SELECT id FROM ServiceContract WHERE Renewal_Opportunity__c IN :cotermOpportunityIds]){
                cotermServiceContracts.add(new Quote_Service_Contracts__c(Quote__c = quote.Id, Service_Contract__c = sc.Id));
            }

            if(cotermServiceContracts.size() > 0)
                insert cotermServiceContracts;
        }
        
        // Copy all Products from Co-Termed Service Contracts        
        Util.Bypass_Trigger_Chk = true;
        syncQuoteProducts(quote);
        Util.Bypass_Trigger_Chk = false;
        applyPureConnectUpgrades(quote);
        // Do calculations ...
        CreateQuoteController quoteController = new CreateQuoteController(quote.id);
        quoteController.initializeRates();
        quoteController.doCalculations();
        
        List<Opportunity> opportunities = new List<Opportunity>();
        for(String oppId : opportunityIds){
        	opportunities.add(new Opportunity(id=oppId, Already_Auto_Renew__c = true));
        }
        update opportunities;
    } 
    
    //*** Method to sync Quote Products ie create quote products from any newly added Quote Service Contracts ***
    public static void syncQuoteProducts(BigMachines__Quote__c quote)
    {
        // Get all Quote Service Contracts
        Set<String> quoteServiceContractIds = new Set<String>();
        for(Quote_Service_Contracts__c eachQuoteSC : [SELECT Service_Contract__c FROM Quote_Service_Contracts__c WHERE Quote__c = :quote.Id]){
            quoteServiceContractIds.add(eachQuoteSC.Service_Contract__c);
        }
        
        // Get all Service Contract Line Items from all Quote Service Contracts        
		List<ContractLineItem> contractLineItems = [SELECT Quantity, Upgraded_Product_Name__c, End_Support_Date__c, ListPrice, 
                                                Original_Net_License_value__c, Revised_Net_License_Value__c, Original_Quantity__c, 
                                                Original_PO__c, Sales_Order__c,Original_License_Invoice_Date__c, Lic_Invoice__c,
												Maintenance_Start_Date__c, Maintenance_End_Date__c, Service_Level__c, Maintenance_Amount__c, 
                                                ServiceContractId, Previous_Line_Maintenance_Value__c, Id, Current_Quantity__c, Sold_To_Name_Txt__c, 
                                                End_User_Name_txt__c,CurrencyISOCode, UnitPrice, Material_Number__c, Product_Description__c,
                                                Comments__c, Project_ID__c,Project_Name__c,Third_Party_Applications__c,
                                                Third_Party_Partner__c,Application_Support_Cost_Base__c,Solution_Name__c,Third_Party_Partner_Fee__c,
                                                Non_Billable__c,
                                                ServiceContract.Renewal_Opportunity__r.Lines_of_Businesses__c,
                                                ServiceContract.Quote_Name__c,
                                                ServiceContract.Quote_Name__r.Opportunity_Type__c,
                                                ServiceContract.Offering_Type__c, 
                                                PriceBookEntry.Product2Id, 
                                                PriceBookEntry.Product2.Type__c, 
                                                PriceBookEntry.Product2.Third_Party_GC__c,
                                                PriceBookEntry.Product2.Partner_Margin_Category__c,
                                                PriceBookEntry.Product2.Product_Category__c,    
                                                PriceBookEntry.Product2.NG5_NA_USD_Price__c,  
                                                PriceBookEntry.Product2.NG1_APAC_ANZ_AUD_Price__c ,
                                                PriceBookEntry.Product2.NG2_BRAZIL_BRL_Price__c ,
                                                PriceBookEntry.Product2.NG5_NA_CAD_Price__c ,
                                                PriceBookEntry.Product2.NG3_EMEA_EUR_Price__c ,
                                                PriceBookEntry.Product2.NG3_EMEA_GBP_Price__c ,
                                                PriceBookEntry.Product2.NG4_APAC_JAPAN_YEN_Price__c ,
                                                PriceBookEntry.Product2.NG5_NZD_Price__c ,
                                                PriceBookEntry.Product2.NG5_ZAR_Price__c
                                                FROM ContractLineItem 
                                                WHERE ServiceContractId IN :quoteServiceContractIds 
                                                AND PriceBookEntry.Product2.Type__c NOT IN ('Genesys Care','Flex Care','Fees','GU')
            									AND Current_Quantity__c > 0                                                 
            									AND Deleted_From_Quotes__c EXCLUDES (:quote.Id)];
        
        // Prepare the list of Quote Products to be inserted
        partnerDiscountMap = getPartnerDisountMap(quote.End_User_ID__c, quote.Sold_To_Name__c);
        List<BigMachines__Quote_Product__c> quoteProducts = new List<BigMachines__Quote_Product__c>();
		for(ContractLineItem eachCL : contractLineItems){                                   
            quoteProducts.add(populateQuoteProduct(quote, eachCL));
        }
	
        // To bypass quote product trigger
        Util.Bypass_Trigger_Chk = true;
        if(quoteProducts.size() > 0)
            insert quoteProducts;
        Util.Bypass_Trigger_Chk = false;    

    }
    
    public static void applyPureConnectUpgrades(BigMachines__Quote__c quote){
    	partnerDiscountMap = getPartnerDisountMap(quote.End_User_ID__c, quote.Sold_To_Name__c);
    	System.debug('applyPureConnectUpgrades Entered ...');
    	applyPureConnectVersionUpgrades(quote);
    	applyPureConnectPurchaseUpgrades(quote, 1);
    	applyPureConnectPurchaseUpgrades(quote, 2);
    	System.debug('applyPureConnectUpgrades Exited ...');
    }
    // Added by RAO - for Auto Quoting, PureConnect Purchase Upgrades
    
    public static void applyPureConnectVersionUpgrades(BigMachines__Quote__c quote){
    	System.debug('applyPureConnectVersionUpgrades Entered ...');
    	// Version Upgrades -- STARTS
		Set<String> quoteSCIds = new Set<String>();
		for(Quote_Service_Contracts__c qsc : [SELECT Id, Service_Contract__c FROM Quote_Service_Contracts__c WHERE Quote__c = :quote.Id AND (Service_Contract__r.Offering_Type__c = 'PureConnect' OR Service_Contract__r.Renewal_Opportunity__r.Lines_of_Businesses__c = 'PureConnect')]){
			quoteSCIds.add(qsc.Service_Contract__c);
		}
		
		if(quoteSCIds.size() > 0){
			// Verion Upgrades -- START
    		List<Product_Upgrade_Request__c> versionUpgradeRequests = [SELECT Id, Account__c, Product__c, Type__c, Quantity__c, Processed__c 
    																	FROM Product_Upgrade_Request__c
																		WHERE Account__c = :quote.End_User_ID__c AND Type__c = 'Version' AND Processed__c = false];
			if(versionUpgradeRequests.size() > 0){
				Set<String> versionUpgradeProductIds = new Set<String>();
				for(Product_Upgrade_Request__c pur: versionUpgradeRequests){
					versionUpgradeProductIds.add(pur.Product__c);
				}	
				
				Map<String, List<Pure_Connect_Version_Upgrade__c>> versionUpgradeMapping = new Map<String, List<Pure_Connect_Version_Upgrade__c>>();
				for(Pure_Connect_Version_Upgrade__c pcvu : [SELECT Old_Product__c, 
																New_Product__c, New_Product__r.Name, New_Product__r.Type__c, New_Product__r.description, New_Product__r.APN_Number__c, New_Product__r.Third_Party_GC__c,
																New_Product__r.Partner_Margin_Category__c, New_Product__r.Product_Category__c, New_Product__r.NG5_NA_USD_Price__c,  
																New_Product__r.NG1_APAC_ANZ_AUD_Price__c, New_Product__r.NG2_BRAZIL_BRL_Price__c, New_Product__r.NG5_NA_CAD_Price__c,
																New_Product__r.NG3_EMEA_EUR_Price__c, New_Product__r.NG3_EMEA_GBP_Price__c, New_Product__r.NG4_APAC_JAPAN_YEN_Price__c,
																New_Product__r.NG5_NZD_Price__c, New_Product__r.NG5_ZAR_Price__c
															FROM Pure_Connect_Version_Upgrade__c WHERE Old_Product__c IN :versionUpgradeProductIds])
															 //AND New_Product__r.APN_Number__c <> NULL AND New_Product__r.APN_Number__c <> ''
				{
					if(versionUpgradeMapping.containsKey(pcvu.Old_Product__c)){
						List<Pure_Connect_Version_Upgrade__c> pcvuList = versionUpgradeMapping.get(pcvu.Old_Product__c);
						pcvuList.add(pcvu);
						versionUpgradeMapping.put(pcvu.Old_Product__c, pcvuList);
					} else {
						versionUpgradeMapping.put(pcvu.Old_Product__c, new List<Pure_Connect_Version_Upgrade__c>{pcvu});
					}
				}				

				List<BigMachines__Quote_Product__c> quoteProductsForUpgrade = [SELECT id, BigMachines__Quote__c, BigMachines__Quantity__c, End_Of_Support_Date__c, Original_Qty__c, 
																					Lic_Invoice__c, Original_PO__c, Sales_Order__c, Original_License_Invoice_Date__c, Maintenance_Start_Date__c, 
																					Maintenance_End_Date__c, Service_Contract_Line_ID__c, Service_Contract_Line__c, Service_Contract_Line__r.Deleted_From_Quotes__c,
																					Current_Qty__c, Sold_To_Name__c, End_User_Name__c, CurrencyISOCode, Name, APN_Number__c, 
																					BigMachines__Description__c, BigMachines__Product__c, Comment__c, Project_ID__c, Project_Name__c, 
																					Third_Party_Partners__c, Third_Party_Applications__c, Solution_Names_Covered__c, List_Price__c, 
																					Original_Net_License_Value__c, Revised_Net_License_Value__c, Previous_Line_Maintenance_Value__c,
																					BigMachines__Sales_Price__c, Revised_Net_From_Contract_Line__c, Third_Party_Partner_Fee__c, 
																					Application_Support_Cost_Base__c, Is_Product_Upgraded__c
																					,BigMachines__Product__r.Product_Upgrade__c
																				FROM BigMachines__Quote_Product__c 
																				WHERE BigMachines__Quote__c = :quote.Id 
																				AND BigMachines__Product__c IN :versionUpgradeProductIds];	
			
				List<BigMachines__Quote_Product__c> quoteProductsToInsert = new List<BigMachines__Quote_Product__c>();
				List<BigMachines__Quote_Product__c> quoteProductsToDelete = new List<BigMachines__Quote_Product__c>();
				List<ContractLineItem> contractLineItemsToUpdate = new List<ContractLineItem>();
				List<Quote_Products_Upgrade__c> quoteProductUpgradeList = new List<Quote_Products_Upgrade__c>();

				for(BigMachines__Quote_Product__c qp: quoteProductsForUpgrade)  {
					List<Pure_Connect_Version_Upgrade__c> toProducts = versionUpgradeMapping.get(qp.BigMachines__Product__c);
					
					if(toProducts != NULL){
						for(Integer i=0; i < toProducts.size(); i++){
							Pure_Connect_Version_Upgrade__c pcvu = toProducts[i];
							if(pcvu.New_Product__c == NULL){
								contractLineItemsToUpdate.add(new ContractLineItem(id = qp.Service_Contract_Line__c, Deleted_From_Quotes__c = String.isBlank(qp.Service_Contract_Line__r.Deleted_From_Quotes__c) ? '' + quote.Id : qp.Service_Contract_Line__r.Deleted_From_Quotes__c + ';' + quote.Id));
								quoteProductsToDelete.add(qp);
								continue;										
							}

							quoteProductUpgradeList.add(new Quote_Products_Upgrade__c(Quote__c = quote.Id, From__c = pcvu.Old_Product__c, To__c = pcvu.New_Product__c));
							// Calculate Partner Discount for the current product 
						    Decimal partnerMultipler = 1.0;
						    /*
					        if(soldToAccount.Type == 'Partner' && pcvu.New_Product__r.Type__c != NULL && pcvu.New_Product__r.Type__c.startsWith('Product')){
					        	if(partnerDiscountMap.get('PureConnect On Premise') != NULL)
						  			partnerMultipler = 1.0 - partnerDiscountMap.get('PureConnect On Premise')/100;	      	
					        } else if(soldToAccount.Type == 'Partner' && pcvu.New_Product__r.Type__c == 'GU'){ 
					        	if(partnerDiscountMap.get('GU') != NULL)
						  			partnerMultipler = 1.0 - partnerDiscountMap.get('GU')/100;	      	
					        }
					        */
					        // Code to use Partner Discount Fields from Account Level
					        if(soldToAccount.Type == 'Partner' && pcvu.New_Product__r.Type__c != NULL && pcvu.New_Product__r.Type__c.startsWith('Product') && soldToAccount.Partner_Product_Margin__c != NULL){
								partnerMultipler = 1.0 - soldToAccount.Partner_Product_Margin__c/100;	      	
							} else if(soldToAccount.Type == 'Partner' && pcvu.New_Product__r.Type__c == 'GU' && soldToAccount.Partner_GU_Margin__c != NULL ){ 
								partnerMultipler = 1.0 - soldToAccount.Partner_GU_Margin__c/100;	      	
							}
					        Product2 pbEntryProduct = (Product2)pcvu.getSobject('New_Product__r');
							Decimal listPrice = (Decimal)pbEntryProduct.get(Util.getPriceFieldName(quote.CurrencyISOCode));  
					        
					        
							// for first product, just upgrade the existing quote product 
							if(i == 0){
								qp.Name = pcvu.New_Product__r.Name;
								qp.APN_Number__c = pcvu.New_Product__r.APN_Number__c;
								qp.BigMachines__Description__c =  pcvu.New_Product__r.description != NULL ? (pcvu.New_Product__r.description.length() > 255 ? pcvu.New_Product__r.description.substring(0,254) : pcvu.New_Product__r.description ) : '';
					          	qp.BigMachines__Product__c = pcvu.New_Product__c;
					           	qp.Is_Product_Upgraded__c = true;
					           	
								qp.List_Price__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,listPrice);
								qp.Original_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice * partnerMultipler) );
								qp.Revised_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice * partnerMultipler));
								qp.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(qp.Current_Qty__c * listPrice * partnerMultipler));
					           	
							} else {
								
								// Create a new Quote Product when you have 1:N version upgrade from 2nd To Product onwards
								BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
								newQuoteProduct.BigMachines__Quote__c = quote.Id;
								newQuoteProduct.BigMachines__Quantity__c = qp.BigMachines__Quantity__c;
								newQuoteProduct.End_Of_Support_Date__c = qp.End_Of_Support_Date__c;
								newQuoteProduct.Original_Qty__c = qp.Original_Qty__c;
								newQuoteProduct.Lic_Invoice__c = qp.Lic_Invoice__c;
								newQuoteProduct.Original_PO__c = qp.Original_PO__c;
								newQuoteProduct.Sales_Order__c = qp.Sales_Order__c;
								newQuoteProduct.Original_License_Invoice_Date__c = qp.Original_License_Invoice_Date__c;
								newQuoteProduct.Maintenance_Start_Date__c = qp.Maintenance_Start_Date__c;
								newQuoteProduct.Maintenance_End_Date__c = qp.Maintenance_End_Date__c;
								newQuoteProduct.Service_Contract_Line_ID__c = qp.Service_Contract_Line_ID__c;
								newQuoteProduct.Service_Contract_Line__c = qp.Service_Contract_Line__c;
								newQuoteProduct.Current_Qty__c = qp.Current_Qty__c;
								newQuoteProduct.Sold_To_Name__c = qp.Sold_To_Name__c;
								newQuoteProduct.End_User_Name__c = qp.End_User_Name__c;
								newQuoteProduct.CurrencyISOCode = qp.CurrencyISOCode;
								
								newQuoteProduct.Name = pcvu.New_Product__r.Name;
								newQuoteProduct.APN_Number__c = pcvu.New_Product__r.APN_Number__c;
                                newQuoteProduct.BigMachines__Description__c = pcvu.New_Product__r.description != NULL ? (pcvu.New_Product__r.description.length() > 255 ? pcvu.New_Product__r.description.substring(0,254) : pcvu.New_Product__r.description ) : '';
								newQuoteProduct.BigMachines__Product__c = pcvu.New_Product__c;

								newQuoteProduct.Comment__c = qp.Comment__c;
								newQuoteProduct.Project_ID__c = qp.Project_ID__c;
								newQuoteProduct.Project_Name__c = qp.Project_Name__c;
								newQuoteProduct.Third_Party_Partners__c = qp.Third_Party_Partners__c;
								newQuoteProduct.Third_Party_Applications__c = qp.Third_Party_Applications__c;
								newQuoteProduct.Solution_Names_Covered__c = qp.Solution_Names_Covered__c;
								newQuoteProduct.BigMachines__Sales_Price__c = 0;
								
								newQuoteProduct.List_Price__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,listPrice);
								newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice * partnerMultipler));
								newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice * partnerMultipler));
								newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(qp.Current_Qty__c * listPrice * partnerMultipler));
								
								newQuoteProduct.Previous_Line_Maintenance_Value__c = qp.Previous_Line_Maintenance_Value__c;
								newQuoteProduct.Third_Party_Partner_Fee__c = qp.Third_Party_Partner_Fee__c;
								newQuoteProduct.Application_Support_Cost_Base__c = qp.Application_Support_Cost_Base__c;
								newQuoteProduct.Is_Product_Upgraded__c = true;
								quoteProductsToInsert.add(newQuoteProduct);
							}
						}
					}
		        }

		        // To bypass quote product trigger
		        Util.Bypass_Trigger_Chk = true;
		        if(quoteProductsForUpgrade.size() > 0)
					Database.update(quoteProductsForUpgrade);
		        if(quoteProductsToInsert.size() > 0)
		            insert quoteProductsToInsert;
		        if(contractLineItemsToUpdate.size() > 0)
					Database.update(contractLineItemsToUpdate);	    
				if(quoteProductUpgradeList.size() > 0)	
					Database.insert(quoteProductUpgradeList);
				Util.Bypass_Trigger_Chk = false;																		
			}
			// Verion Upgrades -- ENDS			
		}
		System.debug('applyPureConnectVersionUpgrades Exited ...');
    }
    
    
    /*
	if (UL Part is found in Quote Products)
		FOR LOWER VERSION PRODUCT (Error Conditions)	
			1. If Lower version part not found in the current Quote Products
			or
			2. If Lower version part is found and Current qunatity is not enough in all Quote Products existing
			AND
			Set Contract_Line_Update_Status__c to "Purchase Upgrade" 
		FOR HIGHER VERSION PRODUCT 
			1. If Higher version part does not exists in the current Quote products (Add the new Quote Product)
			or
			2. If Higher version part exists, then update the Current Quantity
			AND
			Set Contract_Line_Update_Status__c to "Purchase Upgrade" 
		
			
	Referesh Selected & Do Calculations need to be updated based on Contract_Line_Update_Status__c to "Purchase Upgrade"			
		If quote has UL Parts and if the current line item is one of the UL Parts Lower Version	Do calculation accordingly
		If quote has UL Parts and if the current line item is one of the UL Parts Higher Version	
	*/
    public static void applyPureConnectPurchaseUpgrades(BigMachines__Quote__c quote, Integer passIndex){
		System.debug('applyPureConnectPurchaseUpgrades Entered ...');
    	
    	// Purchase Upgrades -- STARTS
		Set<String> quoteSCIds = new Set<String>();
		for(Quote_Service_Contracts__c qsc : [SELECT Id, Service_Contract__c FROM Quote_Service_Contracts__c WHERE Quote__c = :quote.Id AND (Service_Contract__r.Offering_Type__c = 'PureConnect' OR Service_Contract__r.Renewal_Opportunity__r.Lines_of_Businesses__c = 'PureConnect')]){
			quoteSCIds.add(qsc.Service_Contract__c);
		}
		
		if(quoteSCIds.size() > 0){
			
			
			// UL_Upsize_Parts__c Custom Setting --> UL_Upsize_Parts__c, Part_To_Be_Decremented__c, Part_To_Be_Incremented__c
			
			// Find all UL Parts from Quote Service Contracts
			Map<String, UL_Upsize_Parts__c> ULUpsizeParts = UL_Upsize_Parts__c.getAll();
			List<ContractLineItem> cliProductsHavingULParts = [SELECT Quantity, Upgraded_Product_Name__c, End_Support_Date__c, ListPrice, Original_Net_License_value__c, Deleted_From_Quotes__c, 
												            Revised_Net_License_Value__c, Original_Quantity__c,Original_PO__c, Sales_Order__c,Original_License_Invoice_Date__c,Lic_Invoice__c,//Upd_Invoice_date__c,Upd_License_Invoice__c,
												            Maintenance_Start_Date__c, Maintenance_End_Date__c, Service_Level__c, Maintenance_Amount__c, ServiceContractId, Previous_Line_Maintenance_Value__c, Id, Current_Quantity__c, 
												            Sold_To_Name_Txt__c, End_User_Name_txt__c,CurrencyISOCode, UnitPrice, Material_Number__c, Product_Description__c, Comments__c, Non_Billable__c,
												      		Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partner__c,Application_Support_Cost_Base__c,Solution_Name__c,Third_Party_Partner_Fee__c,
												      		ServiceContract.Offering_Type__c, ServiceContract.Quote_Name__c, ServiceContract.Quote_Name__r.Opportunity_Type__c, ServiceContract.Renewal_Opportunity__r.Lines_of_Businesses__c, 
												            PriceBookEntry.Product2Id, 
												            PriceBookEntry.Product2.APN_Number__c,
												            PriceBookEntry.Product2.Type__c, 
												            PriceBookEntry.Product2.Third_Party_GC__c,
												            PriceBookEntry.Product2.Partner_Margin_Category__c,
												            PriceBookEntry.Product2.Product_Category__c,    
												            PriceBookEntry.Product2.NG5_NA_USD_Price__c,  
												            PriceBookEntry.Product2.NG1_APAC_ANZ_AUD_Price__c ,
												            PriceBookEntry.Product2.NG2_BRAZIL_BRL_Price__c ,
												            PriceBookEntry.Product2.NG5_NA_CAD_Price__c ,
												            PriceBookEntry.Product2.NG3_EMEA_EUR_Price__c ,
												            PriceBookEntry.Product2.NG3_EMEA_GBP_Price__c ,
												            PriceBookEntry.Product2.NG4_APAC_JAPAN_YEN_Price__c ,
												            PriceBookEntry.Product2.NG5_NZD_Price__c ,
												            PriceBookEntry.Product2.NG5_ZAR_Price__c
												            FROM ContractLineItem WHERE ServiceContractId IN :quoteSCIds 
															AND Deleted_From_Quotes__c EXCLUDES (:quote.Id)
															AND PriceBookEntry.Product2.APN_Number__c IN :ULUpsizeParts.KeySet()];
																
			if(cliProductsHavingULParts.size() > 0){
				Set<String> ULUpsizePartsNamesUpgradeFrom = new Set<String>();
				Set<String> ULUpsizePartsNamesUpgradeTo = new Set<String>();
				Map<String, String> ULPartFromToMapping = new Map<String, String>();
				
				for(ContractLineItem cli: cliProductsHavingULParts){
					UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(cli.PriceBookEntry.Product2.APN_Number__c);
					if(ulPart != NULL){
						ULUpsizePartsNamesUpgradeFrom.add(ulPart.Part_To_Be_Decremented__c);
						ULUpsizePartsNamesUpgradeTo.add(ulPart.Part_To_Be_Incremented__c);
						ULPartFromToMapping.put(ulPart.Part_To_Be_Decremented__c, ulPart.Part_To_Be_Incremented__c);
					}
				}
				
				Map<String, Product2> productsMap = new Map<String, Product2>();
				for(Product2 p: [SELECT Id, Name, Description, APN_Number__c, Type__c, Product_Category__c, Partner_Margin_Category__c,
					 								NG5_NA_USD_Price__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c,
	                                                NG5_NA_CAD_Price__c, NG3_EMEA_EUR_Price__c, NG3_EMEA_GBP_Price__c,
	                                                NG4_APAC_JAPAN_YEN_Price__c, NG5_NZD_Price__c, NG5_ZAR_Price__c 
								FROM Product2     
	                            WHERE APN_Number__c IN :ULUpsizePartsNamesUpgradeTo AND APN_Number__c <> NULL AND APN_Number__c <> ''])
				{
					productsMap.put(p.APN_Number__c, p);
				}
				
				List<BigMachines__Quote_Product__c> quoteProductsWithULParts = [SELECT id, BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Product__r.APN_Number__c,
																					Product_Description__c, APN_Number__c, Is_Product_Upgraded__c, CurrencyISOCode,
																					List_Price__c, Revised_Net_License_Value__c, Revised_Net_From_Contract_Line__c, Current_Qty__c,
																					Service_Contract_Line__r.Maintenance_Start_Date__c, Service_Contract_Line__r.Maintenance_End_Date__c,
																					Purchase_Upgrade_Applied_From__c, Contract_Line_Update_Status__c
																			  FROM BigMachines__Quote_Product__c 
																			  WHERE BigMachines__Quote__c = :quote.Id 
																			  AND BigMachines__Product__r.APN_Number__c IN :ULUpsizeParts.KeySet() ];
				
				List<BigMachines__Quote_Product__c> quoteProductsForUpgradeFrom = [SELECT id, BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Product__r.APN_Number__c,
																					Product_Description__c, APN_Number__c, Is_Product_Upgraded__c, CurrencyISOCode,
																					List_Price__c, Revised_Net_License_Value__c, Revised_Net_From_Contract_Line__c, Current_Qty__c,
																					Service_Contract_Line__r.Maintenance_Start_Date__c, Service_Contract_Line__r.Maintenance_End_Date__c,
																					Purchase_Upgrade_Applied_From__c, Contract_Line_Update_Status__c
																			  FROM BigMachines__Quote_Product__c 
																			  WHERE BigMachines__Quote__c = :quote.Id 
																			  AND BigMachines__Product__r.APN_Number__c IN :ULUpsizePartsNamesUpgradeFrom ];
																			  
				List<BigMachines__Quote_Product__c> quoteProductsForUpgradeTo = [SELECT id, BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Product__r.APN_Number__c,
																					Product_Description__c, APN_Number__c, Is_Product_Upgraded__c, CurrencyISOCode,
																					List_Price__c, Revised_Net_License_Value__c, Revised_Net_From_Contract_Line__c, Current_Qty__c,
																					Service_Contract_Line__r.Maintenance_Start_Date__c, Service_Contract_Line__r.Maintenance_End_Date__c,
																					Purchase_Upgrade_Applied_From__c, Contract_Line_Update_Status__c
																			  FROM BigMachines__Quote_Product__c 
																			  WHERE BigMachines__Quote__c = :quote.Id 
																			  AND BigMachines__Product__r.APN_Number__c IN :ULUpsizePartsNamesUpgradeTo ];															  
													
													
				// Check whether UL Part can be upgarded in current quote									
				List<ContractLineItem> cliCanNotUpgrade = new List<ContractLineItem>();
				List<ContractLineItem> cliCanUpgrade = new List<ContractLineItem>();
				for(ContractLineItem cli: cliProductsHavingULParts){						
					UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(cli.PriceBookEntry.Product2.APN_Number__c);
					Decimal quantityForUpgarde = cli.Current_Quantity__c;
					for(BigMachines__Quote_Product__c qp : quoteProductsForUpgradeFrom){
						if(qp.BigMachines__Product__r.APN_Number__c == ulPart.Part_To_Be_Decremented__c && (qp.Purchase_Upgrade_Applied_From__c == NULL || (qp.Purchase_Upgrade_Applied_From__c != NULL && !qp.Purchase_Upgrade_Applied_From__c.containsIgnoreCase(qp.BigMachines__Product__r.APN_Number__c )))){
							quantityForUpgarde = quantityForUpgarde - qp.Current_Qty__c;
						}
					}
					if(quantityForUpgarde > 0){
						cliCanNotUpgrade.add(cli);	
					} else {
						cliCanUpgrade.add(cli);
					}
				}	
				System.debug('cliCanUpgrade'+cliCanUpgrade);
				System.debug('cliCanNotUpgrade'+cliCanNotUpgrade);
				
				List<Quote_Products_Upgrade__c> quoteProductsUpgradeList = new List<Quote_Products_Upgrade__c>();
				List<BigMachines__Quote_Product__c> newQuoteProducts = new List<BigMachines__Quote_Product__c>();
				Map<String, BigMachines__Quote_Product__c> deleteQuoteProducts = new Map<String, BigMachines__Quote_Product__c>();
				for(ContractLineItem cli: cliCanUpgrade){						
					UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(cli.PriceBookEntry.Product2.APN_Number__c);
					Decimal quantityForUpgarde = cli.Current_Quantity__c;
					// Add UL Part Quote Product to Quote Products delete list
					for(BigMachines__Quote_Product__c qp : quoteProductsWithULParts){
						if(qp.BigMachines__Product__r.APN_Number__c == cli.PriceBookEntry.Product2.APN_Number__c){
							deleteQuoteProducts.put(qp.id, qp);		
						}		
					}
					
					// Decrement the Quantities from Lower Version, Set Contract_Line_Update_Status__c = 'Purchase Upgrade'
					String productForUpgradeFrom = NULL;
					for(BigMachines__Quote_Product__c qp : quoteProductsForUpgradeFrom){
						if(qp.BigMachines__Product__r.APN_Number__c == ulPart.Part_To_Be_Decremented__c && quantityForUpgarde > 0){
							productForUpgradeFrom = qp.BigMachines__Product__c;
							if(qp.Current_Qty__c >= quantityForUpgarde){
								qp.Current_Qty__c = qp.Current_Qty__c - quantityForUpgarde;
								// Revised_Net_License_Value__c ??
								quantityForUpgarde = 0;	
								qp.Purchase_Upgrade_Applied_From__c = qp.Purchase_Upgrade_Applied_From__c + ';' + cli.id;
								qp.Contract_Line_Update_Status__c = 'Purchase Upgrade';
								qp.Is_Product_Upgraded__c = true;
							} else {
								quantityForUpgarde = quantityForUpgarde - qp.Current_Qty__c;
								qp.Current_Qty__c = 0;
								qp.Purchase_Upgrade_Applied_From__c = qp.Purchase_Upgrade_Applied_From__c + ';' + cli.id;
								qp.Contract_Line_Update_Status__c = 'Purchase Upgrade';
								qp.Is_Product_Upgraded__c = true;
							}
						}
					}
					
					// Delete the current Contract line Item from Quote, set Deleted_From_Quotes__c
					cli.Deleted_From_Quotes__c = String.isBlank(cli.Deleted_From_Quotes__c) ? '' + quote.Id : cli.Deleted_From_Quotes__c + ';' + quote.Id;
					quoteProductsUpgradeList.add(new Quote_Products_Upgrade__c( Quote__c = quote.Id, From__c = productForUpgradeFrom, To__c = productsMap.get(ulPart.Part_To_Be_Incremented__c).id ) );
					
					
					// Increment the Quantities from Higher Version, Set Contract_Line_Update_Status__c = 'Purchase Upgrade'
					boolean upgradeApplied = false;
					for(BigMachines__Quote_Product__c qp : quoteProductsForUpgradeTo){
						if(qp.BigMachines__Product__r.APN_Number__c == ulPart.Part_To_Be_Incremented__c && ( cli.Maintenance_End_Date__c != NULL && qp.Maintenance_Start_Date__c == cli.Maintenance_End_Date__c.addDays(1)) && upgradeApplied == false){
							upgradeApplied = true;
							qp.Current_Qty__c = qp.Current_Qty__c + cli.Current_Quantity__c;
							qp.Purchase_Upgrade_Applied_From__c = qp.Purchase_Upgrade_Applied_From__c + ';' + cli.id;
							qp.Contract_Line_Update_Status__c = 'Purchase Upgrade';	
							qp.Is_Product_Upgraded__c = true;
						}
					}
					
					// Higher Version product does not exist in Quote Products, Add new quote Product
					if(upgradeApplied == false){
						// Add new Quote Product
						BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
	                    newQuoteProduct.BigMachines__Quote__c = quote.id;
	                    newQuoteProduct.Contract_Line_Update_Status__c = 'Purchase Upgrade';	
	                    newQuoteProduct.Is_Product_Upgraded__c = true;
	                    newQuoteProduct.BigMachines__Quantity__c = cli.Current_Quantity__c;
				        newQuoteProduct.End_Of_Support_Date__c = cli.End_Support_Date__c;
				        newQuoteProduct.Original_Qty__c = cli.Current_Quantity__c;
				        newQuoteProduct.Lic_Invoice__c = cli.Lic_Invoice__c;
				        newQuoteProduct.Original_PO__c = cli.Original_PO__c;
				        newQuoteProduct.Sales_Order__c = cli.Sales_Order__c;
				        newQuoteProduct.Original_License_Invoice_Date__c = cli.Original_License_Invoice_Date__c;
				        newQuoteProduct.Maintenance_Start_Date__c = quote.Maintenance_Start_Date__c;
						if(cli.Maintenance_End_Date__c != null)
				            newQuoteProduct.Maintenance_Start_Date__c = cli.Maintenance_End_Date__c.addDays(1);
				        else
				            newQuoteProduct.Maintenance_Start_Date__c = quote.Maintenance_Start_Date__c;
				        
				        newQuoteProduct.Service_Contract_Line_ID__c = NULL;
				        newQuoteProduct.Service_Contract_Line__c = NULL;
				        newQuoteProduct.Current_Qty__c = cli.Current_Quantity__c;
				        newQuoteProduct.Sold_To_Name__c = cli.Sold_To_Name_Txt__c;
				        newQuoteProduct.End_User_Name__c = cli.End_User_Name_txt__c;
				        newQuoteProduct.CurrencyISOCode = quote.CurrencyISOCode;
				        
				        newQuoteProduct.Comment__c = cli.Comments__c;
					    newQuoteProduct.Project_ID__c = cli.Project_ID__c;
					    newQuoteProduct.Project_Name__c = cli.Project_Name__c;
					    newQuoteProduct.Third_Party_Partners__c = cli.Third_Party_Partner__c;
					    newQuoteProduct.Third_Party_Applications__c = cli.Third_Party_Applications__c;
					    newQuoteProduct.Solution_Names_Covered__c = cli.Solution_Name__c;
					    
					    // Calculate Partner Discount for the current product 
			        	Product2 product = productsMap.get(ulPart.Part_To_Be_Incremented__c);
						Decimal listPrice = product.get(Util.getPriceFieldName(quote.CurrencyISOCode)) != NULL ? (Decimal)product.get(Util.getPriceFieldName(quote.CurrencyISOCode)) : 0.0;  

					    Decimal partnerMultipler = 1.0;
					    /*
				        if(soldToAccount.Type == 'Partner' && product.Type__c != NULL && product.Type__c.startsWith('Product')){
				        	if(partnerDiscountMap.get('PureConnect On Premise') != NULL)
					  			partnerMultipler = 1.0 - partnerDiscountMap.get('PureConnect On Premise')/100;	      	
				        } else if(soldToAccount.Type == 'Partner' && product.Type__c == 'GU'){ 
				        	if(partnerDiscountMap.get('GU') != NULL)
					  			partnerMultipler = 1.0 - partnerDiscountMap.get('GU')/100;	      	
				        }
					    */
					    // Code to use Partner Discount Fields from Account Level
				        if(soldToAccount.Type == 'Partner' && product.Type__c != NULL && product.Type__c.startsWith('Product') && soldToAccount.Partner_Product_Margin__c != NULL){
							partnerMultipler = 1.0 - soldToAccount.Partner_Product_Margin__c/100;	      	
						} else if(soldToAccount.Type == 'Partner' && product.Type__c == 'GU' && soldToAccount.Partner_GU_Margin__c != NULL ){ 
							partnerMultipler = 1.0 - soldToAccount.Partner_GU_Margin__c/100;	      	
						}
					    
			            newQuoteProduct.Name = product.APN_Number__c;
				        newQuoteProduct.APN_Number__c = product.APN_Number__c;
				        newQuoteProduct.BigMachines__Description__c = product.Description != NULL ? (product.Description.length() > 255 ? product.Description.substring(0,254) : product.Description ) : '';
				        newQuoteProduct.BigMachines__Product__c = product.Id;
			            
			             // if the contract line item and quote have same currency
			            if(cli.CurrencyISOCode == quote.CurrencyISOCode || quote.No_Currency_Conversion__c) {
			                newQuoteProduct.List_Price__c = listPrice;
			                newQuoteProduct.Original_Net_License_Value__c = (cli.Current_Quantity__c * listPrice * partnerMultipler);
			                newQuoteProduct.Revised_Net_License_Value__c = (cli.Current_Quantity__c * listPrice * partnerMultipler);
			                newQuoteProduct.Previous_Line_Maintenance_Value__c = 0;
			                newQuoteProduct.BigMachines__Sales_Price__c = 0;
			                newQuoteProduct.Revised_Net_From_Contract_Line__c = (cli.Current_Quantity__c * listPrice * partnerMultipler);
			                newQuoteProduct.Third_Party_Partner_Fee__c = cli.Third_Party_Partner_Fee__c;
			                newQuoteProduct.Application_Support_Cost_Base__c = cli.Application_Support_Cost_Base__c;
			            } else {
			                newQuoteProduct.List_Price__c = Util.convertCurrencyCustom(cli.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,listPrice);
			                newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(cli.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(cli.Current_Quantity__c * listPrice * partnerMultipler));
			                newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(cli.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(cli.Current_Quantity__c * listPrice * partnerMultipler));
			                newQuoteProduct.Previous_Line_Maintenance_Value__c = 0;
			                newQuoteProduct.BigMachines__Sales_Price__c = 0;
			                newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(cli.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(cli.Current_Quantity__c * listPrice * partnerMultipler));
			                newQuoteProduct.Third_Party_Partner_Fee__c = Util.convertCurrencyCustom(cli.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,cli.Third_Party_Partner_Fee__c);
			                newQuoteProduct.Application_Support_Cost_Base__c = Util.convertCurrencyCustom(cli.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,cli.Application_Support_Cost_Base__c);
			            }
			            newQuoteProducts.add(newQuoteProduct);
			        }
			        
				}
				
				Util.Bypass_Trigger_Chk = true;
				if(newQuoteProducts.size() > 0)
					insert newQuoteProducts;
				if(cliCanUpgrade.size() > 0)
					update cliCanUpgrade;
				if(quoteProductsForUpgradeFrom.size() > 0)
					update quoteProductsForUpgradeFrom;
				if(quoteProductsForUpgradeTo.size() > 0)
					update quoteProductsForUpgradeTo;
				if(quoteProductsUpgradeList.size() > 0)
					insert quoteProductsUpgradeList;
				if(deleteQuoteProducts.size() > 0)
					delete deleteQuoteProducts.values();
				Util.Bypass_Trigger_Chk = false;
					
				// Add error messages to the quote if the any UL Parts can not be upgraded														  
				if(cliCanNotUpgrade.size() > 0 && passIndex == 2){
					for(ContractLineItem cli: cliCanNotUpgrade){
						UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(cli.PriceBookEntry.Product2.APN_Number__c);
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Purchase Upgrade for ' + cli.PriceBookEntry.Product2.APN_Number__c + ' is not completly applied; please see that all Lower Version ('+ulPart.Part_To_Be_Decremented__c+') products are included in Quote.'));
					}
				}
			}													
		}
		
		System.debug('applyPureConnectPurchaseUpgrades Exited ...');
    }
    
    //*** Method to check and apply any Product Upgrades available ***
    /*
    public static void applyQuoteProductUpgrades(BigMachines__Quote__c quote)
    {
    	if(offeringType == 'PureEngage'){
	    	List<BigMachines__Quote_Product__c> quoteProductsForUpgrade = [SELECT id, BigMachines__Quote__c,
					BigMachines__Product__c, Product_Description__c, APN_Number__c, 
					BigMachines__Product__r.Product_Upgrade__c, BigMachines__Product__r.Product_Upgrade__r.Name, BigMachines__Product__r.Product_Upgrade__r.description,
					BigMachines__Product__r.Product_Upgrade__r.APN_Number__c, Is_Product_Upgraded__c 
				FROM BigMachines__Quote_Product__c 
				WHERE BigMachines__Quote__c = :quote.Id 
				AND BigMachines__Product__r.Product_Upgrade__c != NULL AND BigMachines__Product__r.Product_Upgrade__c <> ''
				AND BigMachines__Product__r.Product_Upgrade__r.APN_Number__c != NULL AND BigMachines__Product__r.Product_Upgrade__r.APN_Number__c <> ''];
			
			List<Quote_Products_Upgrade__c> quoteProductUpgradeList = new List<Quote_Products_Upgrade__c>();
			for(BigMachines__Quote_Product__c qp: quoteProductsForUpgrade)  {
                    quoteProductUpgradeList.add(new Quote_Products_Upgrade__c(Quote__c = quote.Id ,
                                                                                From__c = qp.BigMachines__Product__c,
                                                                                To__c = qp.BigMachines__Product__r.Product_Upgrade__c));
             
                    qp.Name = qp.BigMachines__Product__r.Product_Upgrade__r.Name;
                    qp.APN_Number__c = qp.BigMachines__Product__r.Product_Upgrade__r.APN_Number__c;
                    qp.BigMachines__Description__c = qp.BigMachines__Product__r.Product_Upgrade__r.description;
                    qp.BigMachines__Product__c = qp.BigMachines__Product__r.Product_Upgrade__c;
                    qp.Is_Product_Upgraded__c = true;
	        }
	        if(quoteProductsForUpgrade.size() > 0)
				Database.update(quoteProductsForUpgrade);
			if(quoteProductUpgradeList.size() > 0)	
				Database.insert(quoteProductUpgradeList);
    	}
    	
    	if(offeringType == 'PureConnect'){
    		
    		// Verion Upgrades -- START
    		List<Product_Upgrade_Request__c> versionUpgradeRequests = [SELECT Id, Account__c, Product__c, Type__c, Quantity__c, Processed__c 
    																	FROM Product_Upgrade_Request__c
																		WHERE Account__c = :endUserAccount.Id AND Type__c = 'Version' AND Processed__c = false];
			if(versionUpgradeRequests.size() > 0){
				Set<String> versionUpgradeProductIds = new Set<String>();
				for(Product_Upgrade_Request__c pur: versionUpgradeRequests){
					versionUpgradeProductIds.add(pur.Product__c);
					// pur.Processed__c = true;
				}	
				
				Map<String, List<Pure_Connect_Version_Upgrade__c>> versionUpgradeMapping = new Map<String, List<Pure_Connect_Version_Upgrade__c>>();
				for(Pure_Connect_Version_Upgrade__c pcvu : [SELECT Old_Product__c, 
																New_Product__c, New_Product__r.Name, New_Product__r.Type__c, New_Product__r.description, New_Product__r.APN_Number__c, New_Product__r.Third_Party_GC__c,
																New_Product__r.Partner_Margin_Category__c, New_Product__r.Product_Category__c, New_Product__r.NG5_NA_USD_Price__c,  
																New_Product__r.NG1_APAC_ANZ_AUD_Price__c, New_Product__r.NG2_BRAZIL_BRL_Price__c, New_Product__r.NG5_NA_CAD_Price__c,
																New_Product__r.NG3_EMEA_EUR_Price__c, New_Product__r.NG3_EMEA_GBP_Price__c, New_Product__r.NG4_APAC_JAPAN_YEN_Price__c,
																New_Product__r.NG5_NZD_Price__c, New_Product__r.NG5_ZAR_Price__c
															FROM Pure_Connect_Version_Upgrade__c 
                                                            WHERE Old_Product__c IN :versionUpgradeProductIds 
                                                           AND New_Product__r.APN_Number__c <> NULL AND New_Product__r.APN_Number__c <> ''])
				{
					if(versionUpgradeMapping.containsKey(pcvu.Old_Product__c)){
						List<Pure_Connect_Version_Upgrade__c> pcvuList = versionUpgradeMapping.get(pcvu.Old_Product__c);
						pcvuList.add(pcvu);
						versionUpgradeMapping.put(pcvu.Old_Product__c, pcvuList);
					} else {
						versionUpgradeMapping.put(pcvu.Old_Product__c, new List<Pure_Connect_Version_Upgrade__c>{pcvu});
					}
				}				

				List<BigMachines__Quote_Product__c> quoteProductsForUpgrade = [SELECT id, BigMachines__Quote__c, BigMachines__Quantity__c, End_Of_Support_Date__c, Original_Qty__c, 
																					Lic_Invoice__c, Original_PO__c, Sales_Order__c, Original_License_Invoice_Date__c,
																					Maintenance_Start_Date__c, Maintenance_End_Date__c, Service_Contract_Line_ID__c, Service_Contract_Line__c, 
																					Current_Qty__c, Sold_To_Name__c, End_User_Name__c, CurrencyISOCode, Name, APN_Number__c, 
																					BigMachines__Description__c, BigMachines__Product__c, Comment__c, Project_ID__c, Project_Name__c, 
																					Third_Party_Partners__c, Third_Party_Applications__c, Solution_Names_Covered__c, List_Price__c, 
																					Original_Net_License_Value__c, Revised_Net_License_Value__c, Previous_Line_Maintenance_Value__c,
																					BigMachines__Sales_Price__c, Revised_Net_From_Contract_Line__c, Third_Party_Partner_Fee__c, 
																					Application_Support_Cost_Base__c, Is_Product_Upgraded__c
																					,BigMachines__Product__r.Product_Upgrade__c
																				FROM BigMachines__Quote_Product__c 
																				WHERE BigMachines__Quote__c = :quote.Id 
																				AND BigMachines__Product__c IN :versionUpgradeProductIds];	
			
				List<BigMachines__Quote_Product__c> quoteProductsToInsert = new List<BigMachines__Quote_Product__c>();
				List<Quote_Products_Upgrade__c> quoteProductUpgradeList = new List<Quote_Products_Upgrade__c>();

				for(BigMachines__Quote_Product__c qp: quoteProductsForUpgrade)  {
					List<Pure_Connect_Version_Upgrade__c> toProducts = versionUpgradeMapping.get(qp.BigMachines__Product__c);
					
					if(toProducts != NULL){
						for(Integer i=0; i < toProducts.size(); i++){
							Pure_Connect_Version_Upgrade__c pcvu = toProducts[i];
							quoteProductUpgradeList.add(new Quote_Products_Upgrade__c(Quote__c = quote.Id, From__c = pcvu.Old_Product__c, To__c = pcvu.New_Product__c));

							// for first product, just upgrade the existing quote product 
							if(i == 0){
								qp.Name = pcvu.New_Product__r.Name;
								qp.APN_Number__c = pcvu.New_Product__r.APN_Number__c;
								qp.BigMachines__Description__c = pcvu.New_Product__r.description;
					          	qp.BigMachines__Product__c = pcvu.New_Product__c;
					           	qp.Is_Product_Upgraded__c = true;
							} else {
								//Decimal partnerSoftwareMultiplier = (soldToAccount.Software_Price_Multiplier__c != NULL && soldToAccount.Software_Price_Multiplier__c > 0) ? soldToAccount.Software_Price_Multiplier__c : 1.0;
						        //Decimal partnerEducationMultiplier = (soldToAccount.Education_Price_Multiplier__c != NULL && soldToAccount.Education_Price_Multiplier__c > 0) ? soldToAccount.Education_Price_Multiplier__c : 1.0;
								Decimal partnerSoftwareMultiplier = 1.0 - ((soldToAccount.Partner_Product_Margin__c != NULL && soldToAccount.Partner_Product_Margin__c > 0) ? soldToAccount.Partner_Product_Margin__c/ 100 : 0.0);
						        Decimal partnerEducationMultiplier = 1.0 - ((soldToAccount.Partner_GU_Margin__c != NULL && soldToAccount.Partner_GU_Margin__c > 0) ? soldToAccount.Partner_GU_Margin__c/ 100 : 0.0);
						        Decimal partnerMultipler = 1.0;
						        
						        if(soldToAccount.Type == 'Partner' && pcvu.New_Product__r.Type__c != NULL && pcvu.New_Product__r.Type__c.startsWith('Product')){ 
									if(String.isNotBlank(pcvu.New_Product__r.Partner_Margin_Category__c) && Partner_Hardware_Margins__c.getInstance(pcvu.New_Product__r.Partner_Margin_Category__c) != NULL)
						  				partnerMultipler = 1 - (Partner_Hardware_Margins__c.getInstance(pcvu.New_Product__r.Partner_Margin_Category__c).Margin__c/100);
						  			else	
						  				partnerMultipler = partnerSoftwareMultiplier;	      	
						        } else if(soldToAccount.Type == 'Partner' && pcvu.New_Product__r.Type__c == 'GU'){ 
									partnerMultipler = partnerEducationMultiplier;
						        }
						        if(partnerMultipler > 1){
						        	partnerMultipler = partnerMultipler/100;
						        }

								// Create a new Quote Product when you have 1:N version upgrade from 2nd To Product onwards
								BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
								newQuoteProduct.BigMachines__Quote__c = quote.Id;
								newQuoteProduct.BigMachines__Quantity__c = qp.BigMachines__Quantity__c;
								newQuoteProduct.End_Of_Support_Date__c = qp.End_Of_Support_Date__c;
								newQuoteProduct.Original_Qty__c = qp.Original_Qty__c;
								newQuoteProduct.Lic_Invoice__c = qp.Lic_Invoice__c;
								newQuoteProduct.Original_PO__c = qp.Original_PO__c;
								newQuoteProduct.Sales_Order__c = qp.Sales_Order__c;
								newQuoteProduct.Original_License_Invoice_Date__c = qp.Original_License_Invoice_Date__c;
								newQuoteProduct.Maintenance_Start_Date__c = qp.Maintenance_Start_Date__c;
								newQuoteProduct.Maintenance_End_Date__c = qp.Maintenance_End_Date__c;
								newQuoteProduct.Service_Contract_Line_ID__c = qp.Service_Contract_Line_ID__c;
								newQuoteProduct.Service_Contract_Line__c = qp.Service_Contract_Line__c;
								newQuoteProduct.Current_Qty__c = qp.Current_Qty__c;
								newQuoteProduct.Sold_To_Name__c = qp.Sold_To_Name__c;
								newQuoteProduct.End_User_Name__c = qp.End_User_Name__c;
								newQuoteProduct.CurrencyISOCode = qp.CurrencyISOCode;
								
								newQuoteProduct.Name = pcvu.New_Product__r.Name;
								newQuoteProduct.APN_Number__c = pcvu.New_Product__r.APN_Number__c;
								newQuoteProduct.BigMachines__Description__c = pcvu.New_Product__r.description;
								newQuoteProduct.BigMachines__Product__c = pcvu.New_Product__c;

								newQuoteProduct.Comment__c = qp.Comment__c;
								newQuoteProduct.Project_ID__c = qp.Project_ID__c;
								newQuoteProduct.Project_Name__c = qp.Project_Name__c;
								newQuoteProduct.Third_Party_Partners__c = qp.Third_Party_Partners__c;
								newQuoteProduct.Third_Party_Applications__c = qp.Third_Party_Applications__c;
								newQuoteProduct.Solution_Names_Covered__c = qp.Solution_Names_Covered__c;
								newQuoteProduct.BigMachines__Sales_Price__c = 0;
					
								Product2 pbEntryProduct = (Product2)pcvu.getSobject('New_Product__r');
								Decimal listPrice = (Decimal)pbEntryProduct.get(Util.getPriceFieldName(quote.CurrencyISOCode));  
								newQuoteProduct.List_Price__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,listPrice);
								//newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice) * partnerMultipler);
								//newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice) * partnerMultipler);
								//newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(qp.Current_Qty__c * listPrice) * partnerMultipler);
								newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice));
								newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qp.Current_Qty__c * listPrice));
								newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(qp.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(qp.Current_Qty__c * listPrice));
								newQuoteProduct.Previous_Line_Maintenance_Value__c = qp.Previous_Line_Maintenance_Value__c;
								newQuoteProduct.Third_Party_Partner_Fee__c = qp.Third_Party_Partner_Fee__c;
								newQuoteProduct.Application_Support_Cost_Base__c = qp.Application_Support_Cost_Base__c;
								
								newQuoteProduct.Is_Product_Upgraded__c = true;
								quoteProductsToInsert.add(newQuoteProduct);
							}
						}
					}
		        }

		        // To bypass quote product trigger
		        Util.Bypass_Trigger_Chk = true;
		        if(quoteProductsForUpgrade.size() > 0)
					Database.update(quoteProductsForUpgrade);
		        if(quoteProductsToInsert.size() > 0)
		            insert quoteProductsToInsert;
		        Util.Bypass_Trigger_Chk = false; 
				
				if(quoteProductUpgradeList.size() > 0)	
					Database.insert(quoteProductUpgradeList);	
				
				// Database.update(versionUpgradeRequests);									
													
			}
			// Verion Upgrades -- ENDS
			
			// Purchase Upgrades -- STARTS
			
			// UL_Upsize_Parts__c Custom Setting --> UL_Upsize_Parts__c, Part_To_Be_Decremented__c, Part_To_Be_Incremented__c
			Map<String, UL_Upsize_Parts__c> ULUpsizeParts = UL_Upsize_Parts__c.getAll();
	    	List<BigMachines__Quote_Product__c> quoteProductsHavingULParts = [SELECT id, BigMachines__Quote__c, Product_Description__c, APN_Number__c, 
		    																	BigMachines__Product__c, BigMachines__Product__r.APN_Number__c, BigMachines__Product__r.Description, 
		    																	Service_Contract_Line__c, Service_Contract_Line__r.Deleted_From_Quotes__c,
		    																	Service_Contract_Line__r.Maintenance_Start_Date__c, Service_Contract_Line__r.Maintenance_End_Date__c
																			  FROM BigMachines__Quote_Product__c 
																			  WHERE BigMachines__Quote__c = :quote.Id 
                                                                              AND BigMachines__Product__r.APN_Number__c != NULL
																			  AND BigMachines__Product__r.APN_Number__c IN :ULUpsizeParts.KeySet()];
			if(quoteProductsHavingULParts.size() > 0){
				Set<String> ULUpsizePartsNamesUpgradeFrom = new Set<String>();
				Set<String> ULUpsizePartsNamesUpgradeTo = new Set<String>();
				Map<String, String> ULPartFromToMapping = new Map<String, String>();
				
				for(BigMachines__Quote_Product__c qp: quoteProductsHavingULParts){
					
					UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(qp.BigMachines__Product__r.APN_Number__c);
					if(ulPart != NULL){
						ULUpsizePartsNamesUpgradeFrom.add(ulPart.Part_To_Be_Decremented__c);
						ULUpsizePartsNamesUpgradeTo.add(ulPart.Part_To_Be_Incremented__c);
						ULPartFromToMapping.put(ulPart.Part_To_Be_Decremented__c, ulPart.Part_To_Be_Incremented__c);
					}
				}
				
				Map<String, Product2> productsMap = new Map<String, Product2>();
				for(Product2 p: [SELECT Id, Name, Description, APN_Number__c, Type__c, Product_Category__c, Partner_Margin_Category__c,
					 								NG5_NA_USD_Price__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c,
	                                                NG5_NA_CAD_Price__c, NG3_EMEA_EUR_Price__c, NG3_EMEA_GBP_Price__c,
	                                                NG4_APAC_JAPAN_YEN_Price__c, NG5_NZD_Price__c, NG5_ZAR_Price__c 
								FROM Product2 WHERE APN_Number__c != NULL AND APN_Number__c IN :ULUpsizePartsNamesUpgradeTo])
				{
					productsMap.put(p.APN_Number__c, p);
				}

				List<BigMachines__Quote_Product__c> quoteProductsForUpgrade = [SELECT id, BigMachines__Quote__c, BigMachines__Product__c, BigMachines__Product__r.APN_Number__c,
																					Product_Description__c, APN_Number__c, Is_Product_Upgraded__c, CurrencyISOCode,
																					List_Price__c, Revised_Net_License_Value__c, Revised_Net_From_Contract_Line__c, Current_Qty__c,
																					Service_Contract_Line__r.Maintenance_Start_Date__c, Service_Contract_Line__r.Maintenance_End_Date__c
																			  FROM BigMachines__Quote_Product__c 
																			  WHERE BigMachines__Quote__c = :quote.Id 
																			  AND BigMachines__Product__r.APN_Number__c IN :ULUpsizePartsNamesUpgradeFrom 
																			  AND Is_Product_Upgraded__c = false];
				
				if(quoteProductsForUpgrade.size() > 0){				
					List<Quote_Products_Upgrade__c> quoteProductsUpgradeList = new List<Quote_Products_Upgrade__c>();
					Map<String, BigMachines__Quote_Product__c> quoteProductsToUpdateMap	= new Map<String, BigMachines__Quote_Product__c>();
					Map<String, BigMachines__Quote_Product__c> quoteProductsToDeleteMap	= new Map<String, BigMachines__Quote_Product__c>();
					List<ContractLineItem> clisToUpdate = new List<ContractLineItem>(); 

					Map<String, List<BigMachines__Quote_Product__c>> quoteProductsForUpgradeMap = new Map<String, List<BigMachines__Quote_Product__c>>();
					for(BigMachines__Quote_Product__c qp : quoteProductsForUpgrade){
						if(quoteProductsForUpgradeMap.containsKey(qp.BigMachines__Product__r.APN_Number__c)){
							quoteProductsForUpgradeMap.get(qp.BigMachines__Product__r.APN_Number__c).add(qp);	
						} else {
							quoteProductsForUpgradeMap.put(qp.BigMachines__Product__r.APN_Number__c, new List<BigMachines__Quote_Product__c>{qp});
						}
					}
																							  
					// Loop through each UL Part and identify its corresponding lower level versions and upgrade them to higher version							
					for(BigMachines__Quote_Product__c qpWithULPart: quoteProductsHavingULParts){
						UL_Upsize_Parts__c ulPart = ULUpsizeParts.get(qpWithULPart.BigMachines__Product__r.APN_Number__c);
						List<BigMachines__Quote_Product__c> qpList = quoteProductsForUpgradeMap.get(ulPart.Part_To_Be_Decremented__c);
						
						Boolean canUpgrade = false;
						String fromProductId;
						String fromProductAPNNumber;
						String toProductAPNNumber;  
						Product2 toProduct;
								
						if(qpList != NULL){
							for(BigMachines__Quote_Product__c qpToUpgrade : qpList){
								fromProductId = qpToUpgrade.BigMachines__Product__c;
								fromProductAPNNumber = qpToUpgrade.BigMachines__Product__r.APN_Number__c;
								toProductAPNNumber = ULPartFromToMapping.get(fromProductAPNNumber);  
								toProduct = productsMap.get(toProductAPNNumber);
								
								if(qpWithULPart.Service_Contract_Line__r.Maintenance_End_Date__c == qpToUpgrade.Service_Contract_Line__r.Maintenance_End_Date__c){
									canUpgrade = true;	
									quoteProductsToDeleteMap.put(qpWithULPart.id, qpWithULPart);
									//ULPartAPNNumbers.add(qpToUpgrade.BigMachines__Product__r.APN_Number__c);
								}
							}
						}
						
						// If Upgrade exists, 
						// 1. Mark the Contract Line Item not to Include in Quote
						// 2. Delete Quote Product with UL Part
						// 3. Enter an Quote Product Upgrade Mapping Entry
						// 4. Upgrade all Quote Products with Lower Parts to Higher Parts if the dates matches
						
						if(canUpgrade && toProduct != NULL && toProduct.APN_Number__c != NULL){
							clisToUpdate.add(new ContractLineItem(Id = qpWithULPart.Service_Contract_Line__c, Deleted_From_Quotes__c = quote.Id));
							quoteProductsUpgradeList.add(new Quote_Products_Upgrade__c(Quote__c = quote.Id, From__c = fromProductId, To__c = toProduct.Id));
							for(BigMachines__Quote_Product__c qpToUpgrade : qpList){
								if(qpWithULPart.Service_Contract_Line__r.Maintenance_End_Date__c == qpToUpgrade.Service_Contract_Line__r.Maintenance_End_Date__c){
									// quoteProductsUpgradeList.add(new Quote_Products_Upgrade__c(Quote__c = quote.Id, From__c = fromProductId, To__c = toProduct.Id));

							        // Decimal partnerSoftwareMultiplier = (soldToAccount.Software_Price_Multiplier__c != NULL && soldToAccount.Software_Price_Multiplier__c  > 0) ? soldToAccount.Software_Price_Multiplier__c : 1.0;
							        // Decimal partnerEducationMultiplier = (soldToAccount.Education_Price_Multiplier__c != NULL && soldToAccount.Education_Price_Multiplier__c > 0) ? soldToAccount.Education_Price_Multiplier__c : 1.0;
									Decimal partnerSoftwareMultiplier = 1.0 - ((soldToAccount.Partner_Product_Margin__c != NULL && soldToAccount.Partner_Product_Margin__c > 0) ? soldToAccount.Partner_Product_Margin__c/ 100 : 0.0);
							        Decimal partnerEducationMultiplier = 1.0 - ((soldToAccount.Partner_GU_Margin__c != NULL && soldToAccount.Partner_GU_Margin__c > 0) ? soldToAccount.Partner_GU_Margin__c/ 100 : 0.0);
							        
							        Decimal partnerMultipler = 1.0;
							        if(soldToAccount.Type == 'Partner' && toProduct.Type__c != NULL && toProduct.Type__c.startsWith('Product')){
							           	if(String.isNotBlank(toProduct.Partner_Margin_Category__c) && Partner_Hardware_Margins__c.getInstance(toProduct.Partner_Margin_Category__c) != NULL)
											partnerMultipler = 1 - (Partner_Hardware_Margins__c.getInstance(toProduct.Partner_Margin_Category__c).Margin__c/100);
										else	
											partnerMultipler = partnerSoftwareMultiplier;
							        } else if(soldToAccount.Type == 'Partner' && toProduct.Type__c == 'GU'){
										partnerMultipler = partnerEducationMultiplier;
							        }
									if(partnerMultipler > 1){
										partnerMultipler = partnerMultipler/100;
									}							        
						     		
									Decimal listPrice = (Decimal)toProduct.get(Util.getPriceFieldName(quote.CurrencyISOCode));  
						             // if the contract line item and quote have same currency
						            if(qpToUpgrade.CurrencyISOCode == quote.CurrencyISOCode || quote.No_Currency_Conversion__c) {
						                qpToUpgrade.List_Price__c = listPrice;
						                qpToUpgrade.Original_Net_License_Value__c = (qpToUpgrade.Current_Qty__c * listPrice);
						                qpToUpgrade.Revised_Net_License_Value__c = (qpToUpgrade.Current_Qty__c * listPrice);
						                qpToUpgrade.Revised_Net_From_Contract_Line__c = (qpToUpgrade.Current_Qty__c * listPrice);
						                //qpToUpgrade.Revised_Net_License_Value__c = (qpToUpgrade.Current_Qty__c * listPrice) *  partnerMultipler;
						                //qpToUpgrade.Revised_Net_From_Contract_Line__c = (qpToUpgrade.Current_Qty__c * listPrice) * partnerMultipler;
						            } else {
						                qpToUpgrade.List_Price__c = Util.convertCurrencyCustom(qpToUpgrade.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,listPrice);
						                qpToUpgrade.Original_Net_License_Value__c = Util.convertCurrencyCustom(qpToUpgrade.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qpToUpgrade.Current_Qty__c * listPrice));
						                qpToUpgrade.Revised_Net_License_Value__c = Util.convertCurrencyCustom(qpToUpgrade.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qpToUpgrade.Current_Qty__c * listPrice) );
						                qpToUpgrade.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(qpToUpgrade.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(qpToUpgrade.Current_Qty__c * listPrice));
						                //qpToUpgrade.Revised_Net_License_Value__c = Util.convertCurrencyCustom(qpToUpgrade.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates, (qpToUpgrade.Current_Qty__c * listPrice) * partnerMultipler);
						                //qpToUpgrade.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(qpToUpgrade.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(qpToUpgrade.Current_Qty__c * listPrice) * partnerMultipler);
						            }			     
									qpToUpgrade.Name = toProduct.Name;
									qpToUpgrade.APN_Number__c = toProduct.APN_Number__c;
									qpToUpgrade.BigMachines__Description__c = toProduct.description;
						          	qpToUpgrade.BigMachines__Product__c = toProduct.Id;
						           	qpToUpgrade.Is_Product_Upgraded__c = true;
									quoteProductsToUpdateMap.put(qpToUpgrade.Id, qpToUpgrade);
								}
							}
						}
					}
					// Do all updates here ...	
					if(quoteProductsUpgradeList.size() > 0)
						Database.insert(quoteProductsUpgradeList);
						
					if(quoteProductsToUpdateMap.size() > 0)	
						Database.update(quoteProductsToUpdateMap.values());	
						
					if(quoteProductsToDeleteMap.size() > 0)	
						Database.delete(quoteProductsToDeleteMap.values());

					if(clisToUpdate.size() > 0)	
						Database.update(clisToUpdate);	
				}
			} // Purchase Upgrades - ENDS 
    	}
    }
    */
    
    
    public static BigMachines__Quote_Product__c populateQuoteProduct(BigMachines__Quote__c quote, ContractLineItem eachCL){
            
        BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
        newQuoteProduct.BigMachines__Quote__c = quote.Id;
        newQuoteProduct.BigMachines__Quantity__c = eachCL.Quantity;
        newQuoteProduct.End_Of_Support_Date__c = eachCL.End_Support_Date__c;
        newQuoteProduct.Original_Qty__c = eachCL.Original_Quantity__c;
        newQuoteProduct.Lic_Invoice__c = eachCL.Lic_Invoice__c;
        newQuoteProduct.Original_PO__c = eachCL.Original_PO__c;
        newQuoteProduct.Sales_Order__c = eachCL.Sales_Order__c;
        newQuoteProduct.Original_License_Invoice_Date__c = eachCL.Original_License_Invoice_Date__c;

		// Adjust the Start and End dates on Quote Products
        // if the maintenance end date carried over is null then setting start date on line to quote start date
        if(eachCL.Maintenance_End_Date__c != null)
            newQuoteProduct.Maintenance_Start_Date__c = eachCL.Maintenance_End_Date__c.addDays(1);
        else
            newQuoteProduct.Maintenance_Start_Date__c = quote.Maintenance_Start_Date__c;
        
        // All Quote Products should have the same Maintenance End Date as selected on the Quote
        if(quote.Maintenance_End_Date__c != null)
            newQuoteProduct.Maintenance_End_Date__c = quote.Maintenance_End_Date__c;

        newQuoteProduct.Service_Contract_Line_ID__c = eachCL.id;
        newQuoteProduct.Service_Contract_Line__c = eachCL.id;
        newQuoteProduct.Current_Qty__c = eachCL.Current_Quantity__c;
        newQuoteProduct.Sold_To_Name__c = eachCL.Sold_To_Name_Txt__c;
        newQuoteProduct.End_User_Name__c = eachCL.End_User_Name_txt__c;
        newQuoteProduct.CurrencyISOCode = quote.CurrencyISOCode;
        newQuoteProduct.Name = eachCL.Material_Number__c;
        newQuoteProduct.APN_Number__c = eachCL.Material_Number__c;
        newQuoteProduct.BigMachines__Description__c = eachCL.Product_Description__c;
        newQuoteProduct.BigMachines__Product__c = eachCL.PriceBookEntry.Product2Id;
        newQuoteProduct.Comment__c = eachCL.Comments__c;
        newQuoteProduct.Project_ID__c = eachCL.Project_ID__c;
        newQuoteProduct.Project_Name__c = eachCL.Project_Name__c;
        newQuoteProduct.Third_Party_Partners__c = eachCL.Third_Party_Partner__c;
        newQuoteProduct.Third_Party_Applications__c = eachCL.Third_Party_Applications__c;
        newQuoteProduct.Solution_Names_Covered__c = eachCL.Solution_Name__c;

        // if Contract Line Items Service Contract is of Offerring Type = PureConnect 
        // Need to bring the Product Level List price and calculate Revised Net License
        // || eachCL.ServiceContract.Quote_Name__r.Opportunity_Type__c == 'GEN_Opportunity_Record_Type_New'
        if((eachCL.ServiceContract.Quote_Name__c == NULL || eachCL.ServiceContract.Quote_Name__r.Opportunity_Type__c == 'GEN - Opportunity Record Type') && (eachCL.ServiceContract.Offering_Type__c == 'PureConnect' || eachCL.ServiceContract.Renewal_Opportunity__r.Lines_of_Businesses__c == 'PureConnect')){
        	PriceBookEntry pbEntry = (PriceBookEntry)eachCL.getSobject('PriceBookEntry');
        	Product2 pbEntryProduct = (Product2)pbEntry.getSobject('Product2');
			Decimal listPrice = (Decimal)pbEntryProduct.get(Util.getPriceFieldName(quote.CurrencyISOCode));  
			// Calculate Partner Discount for the current product 
		    Decimal partnerMultipler = 1.0;
		    /*
		    if(soldToAccount.Type == 'Partner' && pbEntryProduct.Type__c != NULL && pbEntryProduct.Type__c.startsWith('Product')){
		    	if(partnerDiscountMap.get('PureConnect On Premise') != NULL)
		  			partnerMultipler = 1.0 - partnerDiscountMap.get('PureConnect On Premise')/100;	      	
		    } else if(soldToAccount.Type == 'Partner' && pbEntryProduct.Type__c == 'GU'){ 
		    	if(partnerDiscountMap.get('GU') != NULL)
		  			partnerMultipler = 1.0 - partnerDiscountMap.get('GU')/100;	      	
		    }
		    */
		    // Code to use Partner Discount Fields from Account Level
	        if(soldToAccount.Type == 'Partner' && pbEntryProduct.Type__c != NULL && pbEntryProduct.Type__c.startsWith('Product') && soldToAccount.Partner_Product_Margin__c != NULL){
				partnerMultipler = 1.0 - soldToAccount.Partner_Product_Margin__c/100;	      	
			} else if(soldToAccount.Type == 'Partner' && pbEntryProduct.Type__c == 'GU' && soldToAccount.Partner_GU_Margin__c != NULL ){ 
				partnerMultipler = 1.0 - soldToAccount.Partner_GU_Margin__c/100;	      	
			}
             // if the contract line item and quote have same currency
             if(eachCL.CurrencyISOCode == quote.CurrencyISOCode || quote.No_Currency_Conversion__c) {
                newQuoteProduct.List_Price__c = listPrice;
                newQuoteProduct.Original_Net_License_Value__c =  (eachCL.Current_Quantity__c * listPrice * partnerMultipler);
                newQuoteProduct.Revised_Net_License_Value__c = (eachCL.Current_Quantity__c * listPrice * partnerMultipler);
                newQuoteProduct.Previous_Line_Maintenance_Value__c = eachCL.Previous_Line_Maintenance_Value__c;
                newQuoteProduct.BigMachines__Sales_Price__c = 0;
                newQuoteProduct.Revised_Net_From_Contract_Line__c = (eachCL.Current_Quantity__c * listPrice * partnerMultipler);
                newQuoteProduct.Third_Party_Partner_Fee__c = eachCL.Third_Party_Partner_Fee__c;
                newQuoteProduct.Application_Support_Cost_Base__c = eachCL.Application_Support_Cost_Base__c;
            } else {
                newQuoteProduct.List_Price__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,listPrice);
                newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(eachCL.Current_Quantity__c * listPrice * partnerMultipler ));
                newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(eachCL.Current_Quantity__c * listPrice * partnerMultipler ));
                newQuoteProduct.Previous_Line_Maintenance_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Previous_Line_Maintenance_Value__c);
                newQuoteProduct.BigMachines__Sales_Price__c = 0;
                newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,(eachCL.Current_Quantity__c * listPrice * partnerMultipler));
                newQuoteProduct.Third_Party_Partner_Fee__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Third_Party_Partner_Fee__c);
                newQuoteProduct.Application_Support_Cost_Base__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Application_Support_Cost_Base__c);
            }
        } else {
         	// if the contract line item and quote have same currency
            if(eachCL.CurrencyISOCode == quote.CurrencyISOCode || quote.No_Currency_Conversion__c){
                newQuoteProduct.List_Price__c = eachCL.ListPrice;
                newQuoteProduct.Original_Net_License_Value__c = eachCL.Original_Net_License_value__c;
                newQuoteProduct.Revised_Net_License_Value__c = eachCL.Revised_Net_License_Value__c;
                newQuoteProduct.Previous_Line_Maintenance_Value__c = eachCL.Previous_Line_Maintenance_Value__c;
                newQuoteProduct.BigMachines__Sales_Price__c = 0;
                newQuoteProduct.Revised_Net_From_Contract_Line__c = eachCL.Revised_Net_License_Value__c;
                newQuoteProduct.Third_Party_Partner_Fee__c = eachCL.Third_Party_Partner_Fee__c;
                newQuoteProduct.Application_Support_Cost_Base__c = eachCL.Application_Support_Cost_Base__c;
            } else {
                newQuoteProduct.List_Price__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.ListPrice);
                newQuoteProduct.Original_Net_License_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Original_Net_License_value__c);
                newQuoteProduct.Revised_Net_License_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Revised_Net_License_Value__c);
                newQuoteProduct.Previous_Line_Maintenance_Value__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Previous_Line_Maintenance_Value__c);
                newQuoteProduct.BigMachines__Sales_Price__c = 0;
                newQuoteProduct.Revised_Net_From_Contract_Line__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Revised_Net_License_Value__c);
                newQuoteProduct.Third_Party_Partner_Fee__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Third_Party_Partner_Fee__c);
                newQuoteProduct.Application_Support_Cost_Base__c = Util.convertCurrencyCustom(eachCL.CurrencyISOCode,quote.CurrencyISOCode,map_ConversionRates,eachCL.Application_Support_Cost_Base__c);
            } 
        }
        return newQuoteProduct;
    }

    public static BigMachines__Quote_Product__c populateQuoteServiceLevel(BigMachines__Quote__c quote, Product2 product){
        BigMachines__Quote_Product__c newQuoteProduct = new BigMachines__Quote_Product__c();
        // Hard-coded value to fill required field :  Needs to be changed
        newQuoteProduct.BigMachines__Sales_Price__c = 1000;
        newQuoteProduct.BigMachines__Product__c = product.Id;
        newQuoteProduct.BigMachines__Quote__c = quote.Id;
        newQuoteProduct.CurrencyISOCode = quote.CurrencyISOCode;
        newQuoteProduct.Name = product.Name;
        newQuoteProduct.APN_Number__c = product.APN_Number__c;
        newQuoteProduct.BigMachines__Quantity__c = 1;
        newQuoteProduct.Original_Qty__c = 1;
        newQuoteProduct.Current_Qty__c = 1;
        newQuoteProduct.Maintenance_Due__c = 0.0;
        newQuoteProduct.Year2_Maintenance_Due__c = 0.0;
        newQuoteProduct.Year3_Maintenance_Due__c = 0.0;
        newQuoteProduct.Year4_Maintenance_Due__c = 0.0;
        newQuoteProduct.Year5_Maintenance_Due__c = 0.0;            
        return newQuoteProduct;
    }
    
    public static String getSendQuoteEmailAddresses(String accountId){
    	String emailAddresses = '';
    	for(Contact c : [SELECT id, Email FROM Contact WHERE AccountId = :accountId AND Send_Quote__c = true]){
    		emailAddresses = emailAddresses + c.Email + ',';
    	}
    	if(emailAddresses.length() > 0){
    		emailAddresses = emailAddresses.substring(0,emailAddresses.length()-1);
    	}
    	return emailAddresses;
    } 
    
    public static void buildAndSendEmail(Account endUserAccount, String offeringType){
		List<string> emailAddresses = new List<string>();
       	emailAddresses.add('Prabhuram.Doraiswamy@genesys.com');

        if(endUserAccount.Genesys_Care_specialist__r.Email != NULL)
            emailAddresses.add(endUserAccount.Genesys_Care_specialist__r.Email);
        if(endUserAccount.Genesys_Care_Ops__r.Email != NULL)
            emailAddresses.add(endUserAccount.Genesys_Care_Ops__r.Email);
        
        String emailSubject = endUserAccount.Name + ' :: '+offeringType+' :: Auto Renewals - Could not be processed';
        String emailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td>Hi,</td></tr>';
        emailBody += '<tr><td>Auto Renewals could not be processed for '+endUserAccount.Name+'.</td></tr>';
        emailBody += '<tr><td></td></tr>';
        emailBody += '<tr><td>Reason: Multiple End User & Sold To combinations.</td></tr>';
        emailBody += '</table></td></tr>';
        emailBody += '</table>';
        emailBody += '</body></html>';
        
        Util.EmailNotification(emailBody,emailSubject,emailAddresses);
    }
    
    public static Map<String, Decimal> getPartnerDisountMap(String endUserAccountId, String soldToAccountId){
    	Map<String, Decimal> partnerDiscountMap = new Map<String, Decimal>();
    	
    	List<Partner_Discount__c> partnerDiscountList = [SELECT id, Type__c, Discount__c FROM Partner_Discount__c WHERE Account__c = :soldToAccountId AND (Effective_Date__c = NULL OR Effective_Date__c >= TODAY) AND (Expiration_Date__c = NULL OR Expiration_Date__c <= TODAY)];
		for(Partner_Discount__c pd : partnerDiscountList){
			if(pd.Type__c != NULL && pd.Type__c.startsWith('GU')){
				if(pd.Type__c == 'GU (Sold To)' && endUserAccountId == soldToAccountId){
					partnerDiscountMap.put('GU', pd.Discount__c);	
				} 
				if(pd.Type__c == 'GU (Sold Through)' && endUserAccountId != soldToAccountId){
					partnerDiscountMap.put('GU', pd.Discount__c);	
				}
			} else {
				partnerDiscountMap.put(pd.Type__c, pd.Discount__c);				
			}
		}   
		
		return partnerDiscountMap; 	 
    }
}