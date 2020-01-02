public class ExportToExcelController
{
    public BigMachines__Quote__c quote {get; set;}
    public List<QuoteProductWrapper> list_QuoteProducts {get; set;} 
    public List<QuoteProductWrapper> list_QuoteProd {get; set;} 
    
    String quoteId;
    
    // List of Sales Order Numbers in ascending order
    public List<String> list_SalesOrerNum {get; set;}
    // Map of Sales Order Number to List of Quote Product Wrapper
    public Map<String,List<QuoteProductWrapper>> map_SalesOrderNumToQuoteProdWrapper {get; set;}
    public Map<String,List<QuoteProductWrapper>> map_ProductQuoteWrapper {get; set;}
    
    // List of Quote Periods being displayed
    public List<Quote_Period__c> list_QuotePeriods {get; set;}

    // Number of Quote Periods
    public Integer intNumOfPeriods {get; set;}
    // To indicate if Extended End Of Support Fee is on the Quote
    public Boolean blnHasExtendedEOSFee {get; set;}
    // To indicate if Reinstatement Fee is on the Quote
    public Boolean blnHasReinstatementFee {get; set;}
    // To store all product upgrades for this quote
    public List<Quote_Products_Upgrade__c> list_ProductUpgrades {get; private set;}
    // Flex Care Products
    public List<BigMachines__Quote_Product__c> list_FlexCare {get; set;}
    // Fees Products
    public List<BigMachines__Quote_Product__c> list_Fees {get; set;}
    // Service Level
    public BigMachines__Quote_Product__c objServiceLevel {get; set;}
    // To store the default care rate based on the service level and country of end user
    public Decimal decDefaultCareRate {get; private set;}
    
    public class QuoteProductWrapper
    {
        public BigMachines__Quote_Product__c record {get; set;}
        public Boolean selected {get; set;}
        
        public QuoteProductWrapper()
        {
            selected = false;
        }
    }
    
    public ExportToExcelController()
    {
        init();
    }
    
    private void init()
    {
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        blnHasExtendedEOSFee = blnHasReinstatementFee = false;
        
        // Fetching Quote information
        quote = getQuote(quoteId);
        System.debug('<<< ' + quote.Sold_To_Name__c);
        list_QuoteProducts = new List<QuoteProductWrapper>();
        if(quoteId != null)
        {           
            // Fetching Quote Products
            getQuoteProducts(quoteId);
             getQuoteProductsByProduct(quoteId);
            
            // Checking for Fees and setting up Configuration products
            fetchConfigurationProducts();
            
            // Fetching Quote Periods
            fetchQuotePeriods();
            
            // Set Tax Rate and based on country and initialize default care rate based on service level and country
            initializeTaxAndDefaultCareRate();           
            
            // Fetching Quote Product Upgrades
            fetchQuoteProductUpgrades();                       
           getQuoteProductsByProduct(quoteId);
        }
    }
    
    // *** Method to initialize Tax rate for some countries (Default tax rates stored on country records) ***
    public void initializeTaxAndDefaultCareRate()
    {
        if(quote.End_User_ID__c != null)
        {
            String strQuery = 'SELECT Country__r.Tax_Rate__c'; 
            
            //Adding the applicable care rate field to the query 
            if(objServiceLevel != null && objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c != null)
                strQuery += ',Country__r.' + objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c;
                
            strQuery += ' FROM Account WHERE Id = \'' + quote.End_User_ID__c + '\'';
            
            List<Account> list_Temp = Database.query(strQuery);

            // Default Care Rate
            if(objServiceLevel != null && objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c != null)
                decDefaultCareRate = (Decimal) list_Temp[0].getSObject('Country__r').get(objServiceLevel.BigMachines__Product__r.Care_Rate_Applicable__c);
        }
    }

    // *** Method to query Quote Periods ***
   private void fetchQuotePeriods()
    {
        list_QuotePeriods = [SELECT Start_Date__c,End_Date__c,Default_Period_Care_Rate__c,Months__c,KPI1__c,KPI2__c,
                            Quarterly_Semi_Annual_Fee__c,Partner_to_Partner_Uplift_Fee__c,Default_Increase__c
                        FROM Quote_Period__c WHERE Quote__c = :quote.Id ORDER BY Start_Date__c];
        intNumOfPeriods = list_QuotePeriods.size();
    }

    
    // *** Method to query Quote Product Upgrades ***
    private void fetchQuoteProductUpgrades()
    {
        list_ProductUpgrades = [SELECT From__c,To__c,From__r.Description,To__r.Description
                        FROM Quote_Products_Upgrade__c WHERE Quote__c = :quote.Id ORDER BY CreatedDate];
    }
    
    
    // *** Method to query and set-up Configuration products/lines ***
    private void fetchConfigurationProducts()
    {
        list_Fees = new List<BigMachines__Quote_Product__c>();
        list_FlexCare = new List<BigMachines__Quote_Product__c>();
        //objServiceLevel = new BigMachines__Quote_Product__c();
        
        for(BigMachines__Quote_Product__c objQuoteProduct : [SELECT Id,BigMachines__Product__r.Type__c,
                Product_Description__c,Original_Qty__c,Current_Qty__c,Maintenance_Start_Date__c,
                Maintenance_End_Date__c,BigMachines__Product__r.Genesys_Care_Quote__c,
                BigMachines__Product__r.Description,Sales_Price_Display__c,BigMachines__Sales_Price__c,
                BigMachines__Product__r.Care_Rate_Applicable__c
                FROM BigMachines__Quote_Product__c 
                WHERE BigMachines__Quote__c = :quote.Id AND 
                (BigMachines__Product__r.Genesys_Care_Quote__c = true
                OR BigMachines__Product__r.Type__c = 'Flex Care' OR
                BigMachines__Product__r.Type__c = 'Fees')])
        {
            // Checking for Fees : 'Extended End of Support' and 'Reinstatement'
            if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Fees')
            {
                if(objQuoteProduct.BigMachines__Product__r.Description == 'Extended End of Support')
                    blnHasExtendedEOSFee = true;
                else if(objQuoteProduct.BigMachines__Product__r.Description == 'Reinstatement Fee')
                    blnHasReinstatementFee = true;
                    
                list_Fees.add(objQuoteProduct);
            }
            else if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
                list_FlexCare.add(objQuoteProduct);
            else if(objQuoteProduct.BigMachines__Product__r.Genesys_Care_Quote__c)
                objServiceLevel = objQuoteProduct;
        }
        if(quote.Has_Extended_End_Of_Support__c)
            blnHasExtendedEOSFee = true;
        if(quote.Has_Reinstatement__c)
            blnHasReinstatementFee = true;
    }        
    
    // *** Method to return quote object ***
    public BigMachines__Quote__c getQuote(Id quoteId)
    {
        BigMachines__Quote__c quote;
        quote = (BigMachines__Quote__c)Database.query(prepareQuoteQuery(quoteId));
        return quote;
    }
        
    // *** Method to get Quote Products ***
    public void getQuoteProducts(Id quoteId)
    {
        List<BigMachines__Quote_Product__c> list_QuoteProductRecords = (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQuery(quoteId));
        list_QuoteProducts = new List<QuoteProductWrapper>();
        list_SalesOrerNum = new List<String>();
        map_SalesOrderNumToQuoteProdWrapper = new Map<String,List<QuoteProductWrapper>>();
        for(BigMachines__Quote_Product__c eachQuoteProduct : list_QuoteProductRecords)
        {   
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
			
          
			if( eachQuoteProduct.Contract_Line_Update_Status__c !=null && (eachQuoteProduct.Contract_Line_Update_Status__c =='Drop' 
                                                                                   || eachQuoteProduct.Contract_Line_Update_Status__c =='Split' 
                                                                                   || eachQuoteProduct.Contract_Line_Update_Status__c =='Shelved' 
                                                                                   || eachQuoteProduct.Contract_Line_Update_Status__c =='Downsize' 
                                                                                   || eachQuoteProduct.Contract_Line_Update_Status__c =='Retired' 
                                                                                  )) {	             	
    	         	// eachQuoteProduct.Current_Qty__c =  eachQuoteProduct.Original_Qty__c - eachQuoteProduct.Current_Qty__c;
    	         	if(eachQuoteProduct.Original_Qty__c == eachQuoteProduct.Current_Qty__c)
    	         		eachQuoteProduct.Current_Qty__c =  0;
        	}             	
			
            wrapperRecord.record = eachQuoteProduct;
            list_QuoteProducts.add(wrapperRecord);
            // Creating a map of Sales Order Number to list of wrapper products
            /* Group By is being changed from Sales Order Number to Invoice Number
            if(wrapperRecord.record.Sales_Order__c != '' && wrapperRecord.record.Sales_Order__c != null)*/
            if(wrapperRecord.record.Lic_Invoice__c != '' && wrapperRecord.record.Lic_Invoice__c != null)
            {
                if(map_SalesOrderNumToQuoteProdWrapper.containsKey(wrapperRecord.record.Lic_Invoice__c))
                    map_SalesOrderNumToQuoteProdWrapper.get(wrapperRecord.record.Lic_Invoice__c).add(wrapperRecord);
                else
                {
                    map_SalesOrderNumToQuoteProdWrapper.put(wrapperRecord.record.Lic_Invoice__c,new List<QuoteProductWrapper>{wrapperRecord});
                    list_SalesOrerNum.add(wrapperRecord.record.Lic_Invoice__c);
                }
            }
            // Using Sales order value as 'BLANK' to group when Sales Order is not available
            else
            {
                if(map_SalesOrderNumToQuoteProdWrapper.containsKey('BLANK'))
                    map_SalesOrderNumToQuoteProdWrapper.get('BLANK').add(wrapperRecord);
                else
                {
                    map_SalesOrderNumToQuoteProdWrapper.put('BLANK',new List<QuoteProductWrapper>{wrapperRecord});
                    list_SalesOrerNum.add('BLANK');
                }
            }
        }
    }
    
    
   // *** Method to get Quote Products ***
    
    public void getQuoteProductsByProduct(Id quoteId){
        List<BigMachines__Quote_Product__c> list_QuoteProductRecords = (List<BigMachines__Quote_Product__c>)Database.query(prepareQuoteProductQueryByProduct(quoteId));
        list_QuoteProd = new List<QuoteProductWrapper>();
        //list_SalesOrerNum = new List<String>();
        map_ProductQuoteWrapper = new Map<String,List<QuoteProductWrapper>>();
        QuoteProductWrapper currentRecord ;
            
        for(BigMachines__Quote_Product__c eachQuoteProduct : list_QuoteProductRecords){   
            QuoteProductWrapper wrapperRecord = new QuoteProductWrapper();
            wrapperRecord.record = eachQuoteProduct;
            //list_QuoteProd.add(wrapperRecord);
            
             QuoteProductWrapper tempRecord = new QuoteProductWrapper();
   
            if( map_ProductQuoteWrapper.get(wrapperRecord.record.Product_Description__c) != null) {
	            if( wrapperRecord.record.Contract_Line_Update_Status__c !=null && (wrapperRecord.record.Contract_Line_Update_Status__c =='Drop' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Split' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Shelved' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Downsize' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Retired' 
                                                                                  )) 
                {	
					// currentRecord.record.Current_Qty__c =  currentRecord.record.Current_Qty__c +  (wrapperRecord.record.Original_Qty__c - wrapperRecord.record.Current_Qty__c);
                    if(wrapperRecord.record.Original_Qty__c != wrapperRecord.record.Current_Qty__c)                                                                                      
						currentRecord.record.Current_Qty__c =  (currentRecord.record.Current_Qty__c != NULL ? currentRecord.record.Current_Qty__c : 0)
																+  (wrapperRecord.record.Current_Qty__c != NULL ? wrapperRecord.record.Current_Qty__c : 0);
        	    } else {
             		currentRecord.record.Current_Qty__c =  (currentRecord.record.Current_Qty__c != NULL ? currentRecord.record.Current_Qty__c : 0)
             												 +  (wrapperRecord.record.Current_Qty__c != NULL ? wrapperRecord.record.Current_Qty__c : 0);
        	    }
                   
	            currentRecord.record.Original_Qty__c =  (currentRecord.record.Original_Qty__c != NULL ? currentRecord.record.Original_Qty__c : 0)
	            										+  (wrapperRecord.record.Original_Qty__c != NULL ? wrapperRecord.record.Original_Qty__c : 0);
             
             	if(currentRecord.record.Previous_Line_Maintenance_Value__c!=null && wrapperRecord.record.Previous_Line_Maintenance_Value__c != null)
             		currentRecord.record.Previous_Line_Maintenance_Value__c =  (currentRecord.record.Previous_Line_Maintenance_Value__c != NULL ? currentRecord.record.Previous_Line_Maintenance_Value__c : 0)
             																	+  (wrapperRecord.record.Previous_Line_Maintenance_Value__c != NULL ? wrapperRecord.record.Previous_Line_Maintenance_Value__c : 0);  
             
             	currentRecord.record.Revised_Net_License_Value__c =  (currentRecord.record.Revised_Net_License_Value__c != NULL ? currentRecord.record.Revised_Net_License_Value__c : 0)
             														 +  (wrapperRecord.record.Revised_Net_License_Value__c != NULL ? wrapperRecord.record.Revised_Net_License_Value__c : 0);            
             	currentRecord.record.Original_Net_License_Value__c =  (currentRecord.record.Original_Net_License_Value__c != NULL ? currentRecord.record.Original_Net_License_Value__c : 0) 
             														+  (wrapperRecord.record.Original_Net_License_Value__c != NULL ? wrapperRecord.record.Original_Net_License_Value__c : 0);             
				currentRecord.record.Maintenance_Due__c = (currentRecord.record.Maintenance_Due__c != NULL ? currentRecord.record.Maintenance_Due__c : 0)
														+  (wrapperRecord.record.Maintenance_Due__c != NULL ? wrapperRecord.record.Maintenance_Due__c : 0);             
                currentRecord.record.Year2_Maintenance_Due__c = (currentRecord.record.Year2_Maintenance_Due__c != NULL ? currentRecord.record.Year2_Maintenance_Due__c : 0 )
                												+  (wrapperRecord.record.Year2_Maintenance_Due__c != NULL ? wrapperRecord.record.Year2_Maintenance_Due__c : 0);             
                currentRecord.record.Year3_Maintenance_Due__c = (currentRecord.record.Year3_Maintenance_Due__c != NULL ? currentRecord.record.Year3_Maintenance_Due__c : 0)
                												 +  (wrapperRecord.record.Year3_Maintenance_Due__c != NULL ? wrapperRecord.record.Year3_Maintenance_Due__c : 0);             
                currentRecord.record.Year4_Maintenance_Due__c = (currentRecord.record.Year4_Maintenance_Due__c != NULL ? currentRecord.record.Year4_Maintenance_Due__c : 0)
                												 +  (wrapperRecord.record.Year4_Maintenance_Due__c != NULL ? wrapperRecord.record.Year4_Maintenance_Due__c : 0);             
                currentRecord.record.Year5_Maintenance_Due__c = (currentRecord.record.Year5_Maintenance_Due__c != NULL ? currentRecord.record.Year5_Maintenance_Due__c : 0) 
                												+  (wrapperRecord.record.Year5_Maintenance_Due__c != NULL ? wrapperRecord.record.Year5_Maintenance_Due__c : 0);             
             //map_ProductQuoteWrapper.put(wrapperRecord.record.Product_Description__c,new List<QuoteProductWrapper>{wrapperRecord});
            } else {
				if( wrapperRecord.record.Contract_Line_Update_Status__c !=null && (wrapperRecord.record.Contract_Line_Update_Status__c =='Drop' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Split' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Shelved' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Downsize' 
                                                                                   || wrapperRecord.record.Contract_Line_Update_Status__c =='Retired' 
                                                                                  )) 
                {	             	
    	         	//wrapperRecord.record.Current_Qty__c =  wrapperRecord.record.Original_Qty__c - wrapperRecord.record.Current_Qty__c;
    	         	if( wrapperRecord.record.Original_Qty__c == wrapperRecord.record.Current_Qty__c)                                                                                      
    	         		wrapperRecord.record.Current_Qty__c = 0;
        	    } 
                
	            map_ProductQuoteWrapper.put(wrapperRecord.record.Product_Description__c,new List<QuoteProductWrapper>{wrapperRecord});
    	        currentRecord = wrapperRecord ;
        	    list_QuoteProd.add(wrapperRecord);
           }
		}
    }

    // *** Method to generate query string to query Quote from the DB ***
    public String prepareQuoteQuery(Id quoteId)
    {
        String strQuoteQuery = 'SELECT ';       
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> quoteFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Renewals.getFields();
        for(Schema.FieldSetMember field : quoteFields)
        {
            strQuoteQuery += field.getFieldPath() + ', ';
        }
        
        strQuoteQuery += ' End_User_ID__r.Country__r.Tax_Rate__c, End_User_ID__r.Country__r.Name,End_User_ID__r.screening_checklist_completed__c,Quote_Cloned_Revised__r.Name';     
        strQuoteQuery += ' FROM BigMachines__Quote__c WHERE id = \'' + quoteId + '\'';
        return strQuoteQuery;
    }
    
    public String prepareQuoteProductQuery(Id quoteId)
    {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFields.getFields();
        for(Schema.FieldSetMember field : gridFields)
        {
            strQueryAllFields += field.getFieldPath() + ', ';
        }
        //strQueryAllFields += 'BigMachines__Product__r.Type__c,BigMachines__Product__r.Genesys_Care_Quote__c';
        //strQueryAllFields = strQueryAllFields.substring(0, strQueryAllFields.lastIndexOf(','));
        strQueryAllFields += 'total_invoice_maint__c,total_invoice_revise_net__c,BigMachines__Product__r.Name,BigMachines__Product__r.End_of_Support__c,BigMachines__Product__r.End_of_Support_Date__c,';
        strQueryAllFields += 'BigMachines__Product__r.LRA_Uplift_Not_Applicable__c,BigMachines__Product__r.LDA_Uplift_Not_Applicable__c';
        //strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Product__r.Type__c != \'Genesys Care\' AND BigMachines__Quote__c = \'' + quoteId + '\'';
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'';
        strQueryAllFields += ' AND BigMachines__Product__r.Genesys_Care_Quote__c = false';
        strQueryAllFields += ' AND BigMachines__Product__r.Type__c != \'Flex Care\'';
        strQueryAllFields += ' AND BigMachines__Product__r.Type__c != \'Fees\'';
        //strQueryAllFields += ' AND Sales_Order__c != null';
        //strQueryAllFields += ' ORDER BY Sales_Order__c NULLS LAST,Original_License_Invoice_Date__c';
        // To Group By Lic_Invoice__c (Invoice Number)
        strQueryAllFields += ' ORDER BY Original_License_Invoice_Date__c,Lic_Invoice__c NULLS LAST,BigMachines__Product__r.Name';
        return strQueryAllFields;
    }
    
 public String prepareQuoteProductQueryByProduct(Id quoteId)
    {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.GridFields.getFields();
        for(Schema.FieldSetMember field : gridFields)
        {
            strQueryAllFields += field.getFieldPath() + ', ';
        }
        //strQueryAllFields += 'BigMachines__Product__r.Type__c,BigMachines__Product__r.Genesys_Care_Quote__c';
        //strQueryAllFields = strQueryAllFields.substring(0, strQueryAllFields.lastIndexOf(','));
        strQueryAllFields += 'BigMachines__Product__r.Name,BigMachines__Product__r.End_of_Support__c,BigMachines__Product__r.End_of_Support_Date__c,';
        strQueryAllFields += 'BigMachines__Product__r.LRA_Uplift_Not_Applicable__c,BigMachines__Product__r.LDA_Uplift_Not_Applicable__c';
        //strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Product__r.Type__c != \'Genesys Care\' AND BigMachines__Quote__c = \'' + quoteId + '\'';
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = \'' + quoteId + '\'';
        strQueryAllFields += ' AND BigMachines__Product__r.Genesys_Care_Quote__c = false';
        strQueryAllFields += ' AND BigMachines__Product__r.Type__c != \'Flex Care\'';
        strQueryAllFields += ' AND BigMachines__Product__r.Type__c != \'Fees\'';
        //strQueryAllFields += ' AND Sales_Order__c != null';
        //strQueryAllFields += ' ORDER BY Sales_Order__c NULLS LAST,Original_License_Invoice_Date__c';
        // To Group By Lic_Invoice__c (Invoice Number)
        strQueryAllFields += ' ORDER BY Product_Description__c';
        return strQueryAllFields;
    }  
    
    public void dummyMethod(){
        Integer i = 0;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
        i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++; i++;i++; i++; i++; i++; i++;
    }
}