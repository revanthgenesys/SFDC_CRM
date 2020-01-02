public class ConfigurationExt
{
    public BigMachines__Quote__c objQuote {get; set;}
    public String quoteOfferingType {get; set;}
    String strQuoteId;
    // Service Level selected by user
    public String strServiceLevelSelected {get; set;}
    // Service Levels
    public List<SelectOption> list_ServiceLevelOptions {get; set;}
    // Flex Care Products
    public List<ProductSelectRow> list_FlexCare {get; set;}
    // Fees Products
    public List<ProductSelectRow> list_Fees {get; set;}
    // Flex Care Products available for DropDown selection
    public List<SelectOption> list_FlexCareProductOptions {get; set;}
    // For Index of Flex Product table to determine which row is being removed
    public String strIndex {get; set;}
    // Map of Product Id to Quote Product
    Map<Id,BigMachines__Quote_Product__c> map_ProdIdToQuoteProduct;
    // Flex Care Quote Products
    //List<BigMachines__Quote_Product__c> list_FlexCareQuoteProducts;
    // All Products of Configuration Type
    List<Product2> list_Products;
    // Existing Quote Products
    List<BigMachines__Quote_Product__c> list_ExistingProducts;
    
    // Lists for display purpose when quote is locked
    public List<BigMachines__Quote_Product__c> list_FlexCareDisplay  {get; set;}
    public List<BigMachines__Quote_Product__c> list_FeesDisplay  {get; set;}
    
    public class ProductSelectRow
    {
        public BigMachines__Quote_Product__c objQuoteProduct {get;set;}
        public String strProductName {get; set;}
        public Boolean blnIsSelected {get; set;}
        // For Flex Care Product Selection
        public String strProductId {get; set;}
        
        public ProductSelectRow()
        {
            objQuoteProduct = new BigMachines__Quote_Product__c();
            blnIsSelected = false;
        }
    }
    
    // *** Constructor ***
    public ConfigurationExt(ApexPages.StandardController controller) 
    {
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        objQuote = (BigMachines__Quote__c)controller.getRecord();
        BigMachines__Quote__c objQuoteTemp = [SELECT id, Name, Opportunity_Offering_Type__c, Offering_Type__c,CurrencyISOCode  FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
        
        quoteOfferingType = '';
        if(objQuoteTemp.Offering_Type__c == NULL && objQuoteTemp.Opportunity_Offering_Type__c == NULL){
        	quoteOfferingType = 'PureEngage';
        } else if((objQuoteTemp.Offering_Type__c != NULL && objQuoteTemp.Offering_Type__c.contains('PureConnect')) || (objQuoteTemp.Opportunity_Offering_Type__c != NULL && objQuoteTemp.Opportunity_Offering_Type__c.contains('PureConnect'))){
        	quoteOfferingType = 'PureConnect';
        } else if(( objQuoteTemp.Offering_Type__c != NULL && objQuoteTemp.Offering_Type__c.contains('PureEngage')) || (objQuoteTemp.Opportunity_Offering_Type__c != NULL && objQuoteTemp.Opportunity_Offering_Type__c.contains('PureEngage'))){
        	quoteOfferingType = 'PureEngage';
        } else {
        	quoteOfferingType = 'PureEngage';
        }
        
        System.debug('quoteOfferingType = ' + quoteOfferingType);
        initializeData();
    }
    
    // *** Method to initialize data ***
    public void initializeData()
    {
        list_Products = [SELECT Type__c,Id,Name,Description,Genesys_Care_Quote__c,APN_Number__c 
            FROM Product2 WHERE IsActive = true AND 
            (Genesys_Care_Quote__c = true OR Type__c = 'Flex Care' OR (Type__c = 'Fees' AND (NOT Description LIKE '%License Reduction%' ))) ORDER BY Description];
        
        map_ProdIdToQuoteProduct = new Map<Id,BigMachines__Quote_Product__c>();
        list_FlexCareDisplay = new List<BigMachines__Quote_Product__c>();
        list_ExistingProducts = [SELECT Id,BigMachines__Product__c,Product_Description__c, 
                                Maintenance_Start_Date__c,Maintenance_End_Date__c,BigMachines__Sales_Price__c,Revised_Net_License_Value__c,Revised_License_List_Price__c,Original_License_List_Price__c,
                                BigMachines__Product__r.Type__c,BigMachines__Product__r.NG5_NA_USD_Price__c,BigMachines__Product__r.NG1_APAC_ANZ_AUD_Price__c,BigMachines__Product__r.NG2_BRAZIL_BRL_Price__c,BigMachines__Product__r.NG5_NA_CAD_Price__c,
                                BigMachines__Product__r.NG3_EMEA_EUR_Price__c,BigMachines__Product__r.NG3_EMEA_GBP_Price__c,BigMachines__Product__r.NG4_APAC_JAPAN_YEN_Price__c,BigMachines__Product__r.NG5_NZD_Price__c,
                                    BigMachines__Product__r.NG5_ZAR_Price__c,Period_Number__c,APN_Number__c, Comment__c
                                FROM BigMachines__Quote_Product__c WHERE 
                                BigMachines__Quote__c = :strQuoteId AND BigMachines__Product__c IN :list_Products
                                ORDER BY Maintenance_Start_Date__c];
                                
        System.Debug('list_ExistingProducts--->'+list_ExistingProducts);
                                
        for(BigMachines__Quote_Product__c objQuoteProduct : list_ExistingProducts)
        {
            map_ProdIdToQuoteProduct.put(objQuoteProduct.BigMachines__Product__c,objQuoteProduct);
            if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
                list_FlexCareDisplay.add(objQuoteProduct);
        }
        System.Debug('list_FlexCareDisplay1--->'+list_FlexCareDisplay);
        
        // If quote is locked display configuration in Read Only mode
        if(!getIsQuoteUnLocked())
        {
            list_FeesDisplay = new List<BigMachines__Quote_Product__c>();
                
            for(Product2 objProduct : list_Products)
            {
                if(map_ProdIdToQuoteProduct.containsKey(objProduct.Id))
                {
                    BigMachines__Quote_Product__c objTemp = map_ProdIdToQuoteProduct.get(objProduct.Id);
                    
                    if(objProduct.Genesys_Care_Quote__c)
                        strServiceLevelSelected = objProduct.Description;

                    else if(objProduct.Type__c == 'Fees')                   
                        list_FeesDisplay.add(objTemp);
                    
                }
            }
        }
        // If quote is unlocked display configuration in selectable mode
        else
        {
            list_ServiceLevelOptions = new List<SelectOption>();
            list_FlexCareProductOptions = new List<SelectOption>();
            list_FlexCare = new List<ProductSelectRow>();
            list_Fees = new List<ProductSelectRow>();
            strServiceLevelSelected = '';
            
            for(Product2 objProduct : list_Products)
            {
                if(objProduct.Genesys_Care_Quote__c)
                {
                    if(objProduct.Description != null)
                    	list_ServiceLevelOptions.add(new SelectOption(objProduct.Id,objProduct.Description));
                    if(map_ProdIdToQuoteProduct.containsKey(objProduct.Id))
                    {
                        strServiceLevelSelected = objProduct.Id;
                    }
                }
                else if(objProduct.Type__c == 'Flex Care')
                {
                    if(objProduct.Description != null)
                    	list_FlexCareProductOptions.add(new SelectOption(objProduct.Id,objProduct.Description));
                }
                else if(objProduct.Type__c == 'Fees')
                {
                	/* if(objProduct.Description.contains('License Reduction Fee')){
						if(objProduct.Description.contains(quoteOfferingType)){
							ProductSelectRow objRow = new ProductSelectRow();
		                    objRow.strProductName = objProduct.Description;
		                    populateQuoteProduct(objRow.objQuoteProduct,objProduct);
		                    list_Fees.add(objRow);
		                    if(map_ProdIdToQuoteProduct.containsKey(objProduct.Id))
		                    {
		                        BigMachines__Quote_Product__c objTemp = map_ProdIdToQuoteProduct.get(objProduct.Id);
		                        objRow.objQuoteProduct.Maintenance_Start_Date__c = objTemp.Maintenance_Start_Date__c;
		                        objRow.objQuoteProduct.Maintenance_End_Date__c = objTemp.Maintenance_End_Date__c;
		                        objRow.objQuoteProduct.BigMachines__Sales_Price__c = objTemp.BigMachines__Sales_Price__c;
		                        objRow.blnIsSelected = true;                    
		                    }
		                    else if(objQuote.Maintenance_End_Date__c != null)
		                        objRow.objQuoteProduct.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;	
						}                		
                	} else { */
	                    ProductSelectRow objRow = new ProductSelectRow();
	                    objRow.strProductName = objProduct.Description;
	                    populateQuoteProduct(objRow.objQuoteProduct,objProduct);
	                    list_Fees.add(objRow);
	                    if(map_ProdIdToQuoteProduct.containsKey(objProduct.Id))
	                    {
	                        BigMachines__Quote_Product__c objTemp = map_ProdIdToQuoteProduct.get(objProduct.Id);
	                        objRow.objQuoteProduct.Maintenance_Start_Date__c = objTemp.Maintenance_Start_Date__c;
	                        objRow.objQuoteProduct.Maintenance_End_Date__c = objTemp.Maintenance_End_Date__c;
	                        objRow.objQuoteProduct.BigMachines__Sales_Price__c = objTemp.BigMachines__Sales_Price__c;
	                        objRow.blnIsSelected = true;                    
	                    }
	                    else if(objQuote.Maintenance_End_Date__c != null)
	                        objRow.objQuoteProduct.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;
                	// }
                }
            }
            list_ServiceLevelOptions.add(new SelectOption('Maintenance Only','Maintenance Only'));
            
            System.Debug('list_FlexCareDisplay2--->'+list_FlexCareDisplay);
            for(BigMachines__Quote_Product__c objQP : list_FlexCareDisplay)
            {
                ProductSelectRow objRow = new ProductSelectRow();
                objRow.strProductId = objQP.BigMachines__Product__c;
                populateQuoteProduct(objRow.objQuoteProduct,new Product2(Id = objQP.BigMachines__Product__c,
                                        Name = objQP.Product_Description__c,APN_Number__c = objQP.APN_Number__c));
                objRow.objQuoteProduct.Maintenance_Start_Date__c = objQP.Maintenance_Start_Date__c;
                objRow.objQuoteProduct.Maintenance_End_Date__c = objQP.Maintenance_End_Date__c;
                objRow.objQuoteProduct.BigMachines__Sales_Price__c = objQP.BigMachines__Sales_Price__c;
                objRow.objQuoteProduct.Period_Number__c = objQP.Period_Number__c;
                objRow.objQuoteProduct.Revised_Net_License_Value__c=objQP.Revised_Net_License_Value__c;
              
        	   // Product2 pbEntryProduct = (Product2)objQP.Bi.getSobject('Product2');
        	   
        	   //Mukunth commented for RevProd fix - Flex Care License List price not populating
        	    /*System.Debug('objQuote.CurrencyISOCode--->'+objQuote.CurrencyISOCode);
                Decimal listPrice = (ObjQP.BigMachines__Product__r.get(Util.getPriceFieldName(objQuote.CurrencyISOCode)) != NULL & ObjQP.BigMachines__Product__r.get(Util.getPriceFieldName(objQuote.CurrencyISOCode)) != -1) ? (Decimal)ObjQP.BigMachines__Product__r.get(Util.getPriceFieldName(objQuote.CurrencyISOCode)) : 0.0;  
                System.Debug('listPrice--->'+listPrice);
                objRow.objQuoteProduct.Original_License_List_Price__c=listPrice;
                objRow.objQuoteProduct.Revised_License_List_Price__c=listPrice;*/
               //Mukunth code end
                list_FlexCare.add(objRow);
                if(objRow.objQuoteProduct.Maintenance_End_Date__c == null && objQuote.Maintenance_End_Date__c != null)
                    objRow.objQuoteProduct.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;
            }
            System.Debug('list_FlexCare2--->'+list_FlexCare);
        }
        if(objQuote.Service_Level__c == 'Maintenance Only')
                strServiceLevelSelected = objQuote.Service_Level__c;
                
    }
    
    // *** Populate default values for quote products ***
    public void populateQuoteProduct(BigMachines__Quote_Product__c objQuoteProduct,Product2 objProduct)
    {
        objQuoteProduct.BigMachines__Product__c = objProduct.Id;
        objQuoteProduct.BigMachines__Quote__c = strQuoteId;
        objQuoteProduct.BigMachines__Quantity__c = 1;
        objQuoteProduct.Original_Qty__c = 1;
        objQuoteProduct.Current_Qty__c = 1;
        objQuoteProduct.CurrencyISOCode = objQuote.CurrencyISOCode;
        objQuoteProduct.Name = objProduct.Name;
        objQuoteProduct.APN_Number__c = objProduct.APN_Number__c;
        objQuoteProduct.Maintenance_Due__c = 0.0;
        objQuoteProduct.Year2_Maintenance_Due__c = 0.0;
        objQuoteProduct.Year3_Maintenance_Due__c = 0.0;
        objQuoteProduct.Year4_Maintenance_Due__c = 0.0;
        objQuoteProduct.Year5_Maintenance_Due__c = 0.0;
        objQuoteProduct.Revised_Net_License_Value__c=0.0;
        objQuoteProduct.Original_License_List_Price__c=0.0;
        objQuoteProduct.Revised_License_List_Price__c=0.0;
    }
    
    // *** Handler for add Flex Care Line button ***
    public void addFlexCareLine()
    {
        ProductSelectRow objRow = new ProductSelectRow();
        populateQuoteProduct(objRow.objQuoteProduct,new Product2());
        if(objQuote.Maintenance_End_Date__c != null)
            objRow.objQuoteProduct.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;
        list_FlexCare.add(objRow);
    }
    
    // *** Handler for removing a Flex Care Line button ***
    public void removeFlexCareLine()
    {
        Integer intRow = Integer.valueOf(strIndex);
        if(intRow >= 0 && intRow < list_FlexCare.size())
            list_FlexCare.remove(intRow);
    }
    
    // *** Handler for save button ***
    public void saveBtnHandler()
    {
        // *********************  Start : Validations ******************
        Boolean blnHasMissingDataError = false;
        if(strServiceLevelSelected == '' || strServiceLevelSelected == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A Service Level has to be selected. If this is a maintenance quote please select \'Maintenance Only\'.'));
            blnHasMissingDataError = true;
        }
        for(ProductSelectRow objRow : list_FlexCare)
        {
            if(objRow.objQuoteProduct.Maintenance_Start_Date__c == null || 
                objRow.objQuoteProduct.Maintenance_End_Date__c == null ||
                objRow.objQuoteProduct.BigMachines__Sales_Price__c == null ||
                objRow.objQuoteProduct.Period_Number__c == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill all values for selected Flex Care items.'));
                blnHasMissingDataError = true;
                break;
            }
            if(objRow.objQuoteProduct.Maintenance_Start_Date__c > objRow.objQuoteProduct.Maintenance_End_Date__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Flex Care : Start Date on a line is greater than End Date.'));
                blnHasMissingDataError = true;
                break;
            }
            
        }
        for(ProductSelectRow objRow : list_Fees)
        {
            if(objRow.blnIsSelected && 
                (objRow.objQuoteProduct.Maintenance_Start_Date__c == null || 
                objRow.objQuoteProduct.Maintenance_End_Date__c == null ||
                objRow.objQuoteProduct.BigMachines__Sales_Price__c == null))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill all values for selected Fees applicable.'));
                blnHasMissingDataError = true;
                break;
            }
            if(objRow.objQuoteProduct.Maintenance_Start_Date__c > objRow.objQuoteProduct.Maintenance_End_Date__c)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Fees : Start Date on a line is greater than End Date.'));
                blnHasMissingDataError = true;
                break;
            }
        }
        if(blnHasMissingDataError && !Test.isRunningTest())
            return;
        // *********************  End : Validations ******************
        
        List<BigMachines__Quote_Product__c> list_ToBeInserted = new List<BigMachines__Quote_Product__c>();
        if(strServiceLevelSelected == 'Maintenance Only')
            objQuote.Service_Level__c = strServiceLevelSelected;
        // Not a Maintenance quote : Service level is saved as a quote line
        else
        {
            try
        	{
                for(Product2 objProduct : list_Products)
                {
                    if(strServiceLevelSelected == objProduct.Id)
                    {
                        BigMachines__Quote_Product__c objQuoteProduct = new BigMachines__Quote_Product__c();
                        // Hard-coded value to fill required field :  Needs to be changed
                        objQuoteProduct.BigMachines__Sales_Price__c = 1000;
                        /*
                        if(objQuote.Maintenance_End_Date__c != null)
                            objQuoteProduct.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;
                        */
                        populateQuoteProduct(objQuoteProduct,objProduct);
                        list_ToBeInserted.add(objQuoteProduct);
                        // Setting Service Level on Quote
                        if(objProduct.Description != null && objProduct.Description != '')
                        {
                            
                            String plus = '';
                            List<String> list_Words = objProduct.Description.split(' ');
                            if(objProduct.Description != null && objProduct.Description.contains('Plus') && objProduct.Description.contains('Business')) {
                             	objQuote.Service_Level__c = 'Business Care Plus';
                            } else if(objProduct.Description != null && objProduct.Description.contains('Plus') && objProduct.Description.contains('Premium')) {
                             	objQuote.Service_Level__c = 'Premium Care Plus';
                            } else if(list_Words.size() > 0)
                                objQuote.Service_Level__c = list_Words[0] + ' Care';
                        }
                        break;
                    }
                }
            }Catch(exception e){
                System.Debug('Error--->'+e.getMessage());
                System.Debug('ErrorInLine--->'+e.getLineNumber());
            }
        }
        objQuote.Period1_Flex_Care_Amount__c = 0;
        objQuote.Period2_Flex_Care_Amount__c = 0;
        objQuote.Period3_Flex_Care_Amount__c = 0;
        objQuote.Period4_Flex_Care_Amount__c = 0;
        objQuote.Period5_Flex_Care_Amount__c = 0;
        
        set<Id> flexCareProdIDs = new set<Id>();

        for(ProductSelectRow objRow:list_FlexCare){
            flexCareProdIDs.add(objRow.strProductId);
        }
        
        map<Id,Product2> flexProdMap = new map<Id,Product2>([Select Id,NG5_NA_USD_Price__c,NG1_APAC_ANZ_AUD_Price__c,NG2_BRAZIL_BRL_Price__c,NG5_NA_CAD_Price__c,NG3_EMEA_EUR_Price__c,
                                                                NG3_EMEA_GBP_Price__c,NG4_APAC_JAPAN_YEN_Price__c,NG5_NZD_Price__c,NG5_ZAR_Price__c from Product2
                                                                where Id IN:flexCareProdIDs]);
        System.debug('flexProdMap--->'+flexProdMap);
        boolean mapNotEmpty = false;
        if(flexProdMap != null && flexProdMap.size()>0)
            mapNotEmpty = true;

        for(ProductSelectRow objRow : list_FlexCare)
        {
            objRow.objQuoteProduct.BigMachines__Product__c = objRow.strProductId;
            
    	    //Mukunth added for RevProd fix - Flex Care License List price not populating
    	    System.Debug('objQuote.CurrencyISOCode--->'+objQuote.CurrencyISOCode);
            Decimal listPrice = (mapNotEmpty && (flexProdMap.get(objRow.strProductId)).get(Util.getPriceFieldName(objQuote.CurrencyISOCode)) != NULL &&
                                (flexProdMap.get(objRow.strProductId)).get(Util.getPriceFieldName(objQuote.CurrencyISOCode)) != -1) ? (Decimal)(flexProdMap.get(objRow.strProductId)).get(Util.getPriceFieldName(objQuote.CurrencyISOCode)) : 0.0;  
            System.Debug('listPrice--->'+listPrice);
            objRow.objQuoteProduct.Original_License_List_Price__c=listPrice;
            objRow.objQuoteProduct.Revised_License_List_Price__c=listPrice;
            //Mukunth code end
            
            list_ToBeInserted.add(objRow.objQuoteProduct);
            
            
            if(objRow.objQuoteProduct.Period_Number__c != NULL){
                Decimal decTemp = (Decimal) objQuote.get('Period' + objRow.objQuoteProduct.Period_Number__c + '_Flex_Care_Amount__c');
                objQuote.put('Period' + objRow.objQuoteProduct.Period_Number__c + '_Flex_Care_Amount__c', decTemp + objRow.objQuoteProduct.BigMachines__Sales_Price__c);
            }
            	
            if(objQuote.Maintenance_Start_Date__c == null ||
                objQuote.Maintenance_Start_Date__c > objRow.objQuoteProduct.Maintenance_Start_Date__c)
                objQuote.Maintenance_Start_Date__c = objRow.objQuoteProduct.Maintenance_Start_Date__c;
        }

        //objQuote.Extended_End_of_Support__c = 0;
        //objQuote.Reinstatement_fee__c = 0;
        objQuote.Show_EOS__c = false;
        objQuote.Show_Reinstatment__c = false;
        for(ProductSelectRow objRow : list_Fees)
        {
            if(objRow.blnIsSelected)
            {
                list_ToBeInserted.add(objRow.objQuoteProduct);
                //if(objRow.strProductName == 'Extended End of Support')
                if(objRow.strProductName == 'Flex Care-Extended Support(Partner)' || 
                    objRow.strProductName == 'Flex Care-Extended Support(End User)' ||
                    objRow.strProductName == 'Extended End of Support')
                {
                    // Total field so cannot be used to store lump sum charge alone
                    //objQuote.Extended_End_of_Support__c = objRow.objQuoteProduct.BigMachines__Sales_Price__c;
                    objQuote.Show_EOS__c = true;
                }
                    
                else if(objRow.strProductName == 'Reinstatement Fee')
                {
                    // Total field so cannot be used to store lump sum charge alone
                    //objQuote.Reinstatement_fee__c = objRow.objQuoteProduct.BigMachines__Sales_Price__c;
                    objQuote.Show_Reinstatment__c = true;
                }
                    
                if(objQuote.Maintenance_Start_Date__c == null ||
                    objQuote.Maintenance_Start_Date__c > objRow.objQuoteProduct.Maintenance_Start_Date__c)
                    objQuote.Maintenance_Start_Date__c = objRow.objQuoteProduct.Maintenance_Start_Date__c;
            }
        }
        
        if(objQuote.Has_Extended_End_Of_Support__c)
            objQuote.Show_EOS__c = true;
        if(objQuote.Has_Reinstatement__c)
            objQuote.Show_Reinstatment__c = true;
        
        try
        {
            // create new quote products based on current selections
            if(list_ToBeInserted.size() > 0)
                insert list_ToBeInserted;
            
            // remove old/existing quote products related to configuration      
            if(list_ExistingProducts.size() > 0)
                delete list_ExistingProducts;
            if(objQuote.Offering_Type__c == NULL && quoteOfferingType != '') 
            	objQuote.Offering_Type__c = quoteOfferingType;    
            upsert objQuote;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            return;
        }           
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Configuration has been saved.'));
        System.Debug('InitializeAfterSave--->');
        initializeData();
    }
    
    // *** Method to return boolean whether record should be locked from editing or not ***
    public Boolean getIsQuoteUnLocked()
    {
        if(objQuote.BigMachines__Status__c == 'Quote Approval Pending' ||
            objQuote.BigMachines__Status__c == 'Quote Approved' ||
            objQuote.BigMachines__Status__c == 'Order Submitted' || 
            objQuote.BigMachines__Status__c == 'Revision Pending' ||
            objQuote.BigMachines__Status__c == 'Order Accepted' || objQuote.BigMachines__Status__c == 'Order Rejected')
            return false;
        return true;
    }
}