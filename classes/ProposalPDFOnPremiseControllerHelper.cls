//Naresh Kumar
public without sharing class ProposalPDFOnPremiseControllerHelper {
    public final static String CATEGORY_VIEW = 'Category View';
    public final static String PRODUCT_TYPE_BUNDLE = 'Bundle';
    public final static String GENESYS_CARE = 'Genesys Care';
    public final static String PRODUCT_TYPE_PSRDP = 'PS Service Offering';
    //returns quote record
    public static BigMachines__Quote__c getQuote(String quoteId){
        BigMachines__Quote__c quote = [SELECT Shipping_Handling__c,BigMachines__Status__c,Show_Cover_Page__c, Show_Cover_Letter__c, Group_Product_By__c, Proposal_Language__c, 
            Hide_Decimal_In_Total__c, Hide_Discount__c, Hide_Volume_Discount__c, Hide_Adjustments__c, Hide_Maintenance_Months__c, 
            Hide_Table_of_Contents__c, Hide_End_User__c, Cover_Letter_Text__c, currencyIsoCode,
            Sold_To_Name__r.Name, End_User_ID__r.Name, Genesys_Care_Rep_Name__c, Name, Hide_Extended_Net_Price__c, 
            End_User_ID__r.SAP_Account_Code__c,End_User_ID__r.Street1__c, End_User_ID__r.Street2__c, End_User_ID__r.Street3__c,
            End_User_ID__r.City__c, End_User_ID__r.StateProvince__c, End_User_ID__r.Country__r.Name, End_User_ID__c, Sold_To_Name__c,
            End_User_ID__r.ZipCode__c,Sold_To_Name__r.Street1__c, Sold_To_Name__r.Street2__c, Sold_To_Name__r.Street3__c,Conversion_Quote__c,
            Sold_To_Name__r.City__c, Sold_To_Name__r.StateProvince__c, Sold_To_Name__r.Country__r.Name,
            Sold_To_Name__r.ZipCode__c,CreatedDate, Expiration_Date__c, Pricing_Model__c, No_Of_Months__c,
            BigMachines__Opportunity__r.Country_Selling_Entity__c, Owner.FirstName, Owner.LastName,
            Owner.Email, Owner.Phone, Order_Numb_of_Maint_Months__c, Hide_Quote_Version__c, Revision_No__c,
            Adjustment__c, Total_Adjustments__c, Proposal_Date__c, Hide_Product_Description__c, Product_Description__c,
            Duration_Unit__c, Order_Numb_of_Maint_Days__c, Contact__r.FirstName,Contact__r.lastName,Contact__r.phone,Contact__r.email,  Hide_List_Price__c,
            Hide_Ext_List_Price__c, Hide_Line_Item_Pricing__c, Executive_Summary__c,Show_Executive_Summary__c,Show_Genesys_Unique_Benefits__c,Genesys_Unique_Benefits__c,
            Show_Impacting_the_lives_of_people__c,Impacting_the_lives_of_everyday_people__c,Show_The_Genesys_Solution__c,
            Genesys_Solution__c,Show_What_You_Want_to_Achieve__c,What_You_Want_to_Achieve__c,Show_Why_Genesys__c,Why_Genesys__c,proposal_title__c,Special_Offer_Terms__c, Is_GU_EMEA__c, Total_Taxes__c,
            Sold_To_Address__c,Sold_To_City__c,Sold_To_state__c,Sold_To_Zip_Code__c,Sold_To_Country__c, Total_Prepaid_Prof_Services__c, CAD_Override__c,Opp_Sold_To_Country__c,
            BigMachines__Opportunity__r.Lines_of_Businesses__c, CMRR__c, Annual_Contract_Value__c, Cloud_Total__c, Do_Not_Group_Output_By_Taxonomy_Category__c,
            Offering_Type__c, Treat_SO_as_PO__c, Hide_Maintenance_Due__c, Hide_Partner_Price__c, Show_MSA_in_Output__c, Hide_Partner_Margin__c,
            BigMachines__Opportunity__r.Account.Partner_Product_Margin__c, BigMachines__Opportunity__r.Account.Partner_GU_Margin__c,
            BigMachines__Opportunity__r.Country__r.PureConnect_Cloud_Selling_Entity__c, MSA_Link__c, Show_Signature_Box__c,Selling_Entity_Formula__c,
            Sold_To_Name__r.Partner_Product_Margin__c, Sold_To_Name__r.Partner_GU_Margin__c FROM  BigMachines__Quote__c WHERE id =: quoteId];
        if(quote.Proposal_Date__c == null)
            quote.Proposal_Date__c = Date.valueOf(quote.CreatedDate);
        return quote;
    }
    //retuns quote products
    public static List<BigMachines__Quote_Product__c> getQuoteProducts(String quoteId, String groupBy,BigMachines__Quote__c quote){
        List<BigMachines__Quote_Product__c> quoteProductRecords;
    List<String> listOfAPNsToSkip = Label.Free_Products_APN.split(';')[0].split(',');
        listOfAPNsToSkip.addAll(Label.Free_Products_APN.split(';')[1].split(','));
        listOfAPNsToSkip.addAll(Label.Free_Products_APN.split(';')[2].split(','));
        
        if(groupBy == null || groupBy == CATEGORY_VIEW){
            if(quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC){
               //Mukunth added BigMachines__Product__c and BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c field to below query as part of 6 digit project  
              quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c,BigMachines__Product__c,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,
                    Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                    BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                    Bundle__c, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c, BigMachines__Product__r.APN_Number__c,
                    BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c, Net_Unit_Price__c, Maintenance_Due__c,
                    Partner_Price__c, APN_Number__c, Name, Bundle__r.Description__c, Bundle__r.Name,Pass_through__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId 
                    AND (Bundle__c =: NULL OR Bundle__r.Group_Type__c = 'Use Case')  AND APN_Number__c NOT IN :listOfAPNsToSkip ORDER BY BigMachines__Product__r.Type__c];
            }
            else{
              //Mukunth added BigMachines__Product__c and BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c field to below query as part of 6 digit project
              quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c,
                    Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                    BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                    BigMachines__Product__c,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,
                    Bundle__c, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c, BigMachines__Product__r.APN_Number__c, 
                    BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c, Net_Unit_Price__c, Maintenance_Due__c,
                    Partner_Price__c, APN_Number__c, Name, Bundle__r.Description__c, Bundle__r.Name,Pass_through__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId 
                    AND (Bundle__c =: NULL  OR Bundle__r.Group_Type__c = 'Use Case') AND APN_Number__c NOT IN :listOfAPNsToSkip ORDER BY BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c];
            }
        }
        else{
            //Mukunth added BigMachines__Product__c and BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c field to below query as part of 6 digit project
            quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c,
                Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                BigMachines__Product__c,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,
                Bundle__c, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c, BigMachines__Product__r.APN_Number__c, 
                BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c, Net_Unit_Price__c,
                Maintenance_Due__c, Partner_Price__c, APN_Number__c, Name, Bundle__r.Description__c, Bundle__r.Name
                FROM BigMachines__Quote_Product__c  WHERE BigMachines__Quote__c =: quoteId
                AND (Bundle__c =: NULL  OR Bundle__r.Group_Type__c = 'Use Case') AND APN_Number__c NOT IN :listOfAPNsToSkip ORDER BY Group_Number__c];
        }
       
    
        for(integer i=0; i<quoteProductRecords.size();i++){
            
          
            
            if(quoteProductRecords[i].BigMachines__Product__r.Type__c == 'Genesys Care'){
                  if(quote.Hide_Maintenance_Months__c == true){
                        quoteProductRecords[i].BigMachines__Quantity__c = null; 
                        quoteProductRecords[i].Unit_of_Measure__c=null ;
                }
                if(quote.Duration_Unit__c != null && quote.Hide_Maintenance_Months__c == false && 
                   (quote.Order_Numb_of_Maint_Months__c != null || quote.Order_Numb_of_Maint_Days__c != null)){
                    
                        if(quote.Duration_Unit__c.equals('Days')){
                            quoteProductRecords[i].BigMachines__Quantity__c = quote.Order_Numb_of_Maint_Days__c ;
                            if(quote.Order_Numb_of_Maint_Days__c > 1)
                             quoteProductRecords[i].Unit_of_Measure__c='Days' ;
                            else
                                quoteProductRecords[i].Unit_of_Measure__c='Day' ;
                        }
                        else{
                           quoteProductRecords[i].BigMachines__Quantity__c = quote.Order_Numb_of_Maint_Months__c;
                           if(quote.Order_Numb_of_Maint_Months__c > 1)
                               quoteProductRecords[i].Unit_of_Measure__c='Months' ;
                            else
                               quoteProductRecords[i].Unit_of_Measure__c='Month' ;
                        }
                    }
                }
                
                
            }
            
            
        
        
        
        return quoteProductRecords;
    }
    //retuns quote products for bundles
    public static List<BigMachines__Quote_Product__c> getQuoteProductsForBundles(String quoteId, boolean showheaderline){
        List<BigMachines__Quote_Product__c> quoteProductRecords;
        //Mukunth added BigMachines__Product__c and BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c field to below if-else as part of 6 digit project
        if(showheaderline)
        quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c,
                Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                Bundle__c, Bundle__r.Name, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c,
                BigMachines__Product__c,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,
                BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c , Accepted_Volume_Discount__c 
                FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId 
                AND Bundle__c != NULL ORDER BY Bundle__r.Name];
        else 
             quoteProductRecords = [SELECT Product_Description__c, BigMachines__Product__r.Name, BigMachines__Quantity__c,
                Unit_of_Measure__c, Ext_Net_Price__c, Ext_List__c, Total_Discount__c, List_Price__c, BigMachines__Product__r.New_Category__c,
                BigMachines__Product__r.Taxonomy_Solution_Category__c, BigMachines__Product__r.Taxonomy_Solution__c,
                Bundle__c, Bundle__r.Name, BigMachines__Product__r.ECCN__c, BigMachines__Product__r.Type__c, Group_Number__c,
                BigMachines__Product__c,BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c,////Mukunth added BigMachines__Product__c and BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c
                BigMachines__Product__r.PSRDP_Product_T_C_Url__c, Bundle_Line__c, Accepted_Volume_Discount__c 
                FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =: quoteId 
                AND Bundle__c != NULL AND Bundle_Line__c != null ORDER BY Bundle__r.Name];
        
        return quoteProductRecords;
    }   
    //getting populated wrapperRecords
    public static List<ProposalPDFOnPremiseController.wrapperQuoteProducts> getWrapperList(BigMachines__Quote__c quote, List<BigMachines__Quote_Product__c> quoteProductRecords,
        Map<String, List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary, List<BigMachines__Quote_Product__c> quotePSRDPProducts){      
        //will contain unique Category/Group
        Set<String> uniqueHeader = new Set<String>();
        //will hold wrapper records to return
        List<ProposalPDFOnPremiseController.wrapperQuoteProducts> quoteProducts = new List<ProposalPDFOnPremiseController.wrapperQuoteProducts>();
        //will contain total row record
        BigMachines__Quote_Product__c totalRecord = new BigMachines__Quote_Product__c();
        //No of records in a particular group
        Integer recordsInGroup = 0;
        //Getting proposal group map
        Map<String, String> mapProposalGroupNumberVsName = getProporalGroupsMap(quote.id);
        
        //will hold bundles
        List<ProposalPDFOnPremiseController.wrapperQuoteProducts> bundles = new List<ProposalPDFOnPremiseController.wrapperQuoteProducts>();
        System.debug('NKC debug quoteProductRecords.size() ['+ quoteProductRecords.size() +']');
        //Looping over each record and adding to wrapper list
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductRecords){  
            System.debug('NKC debug eachQuoteProduct.BigMachines__Product__r.Type__c ['+eachQuoteProduct.BigMachines__Product__r.Type__c+']');      
            //Populating PS RDP flag
            if(eachQuoteProduct.BigMachines__Product__r.Type__c == PRODUCT_TYPE_PSRDP){
                quotePSRDPProducts.add(eachQuoteProduct);
            }
            
            String groupName = getUniqueGroupName(quote, eachQuoteProduct, mapProposalGroupNumberVsName);
            String typeName = getTypeName(eachQuoteProduct.BigMachines__Product__r.Type__c);
            String temp = groupName;
            if(groupName != typeName && quote.Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC)
              temp = typeName + ' - ' + temp;
            if(quote.Group_Product_By__c == 'Use Case View')
              temp = groupName;
            System.debug('NKC debug groupName [' + groupName + ']');
            if(!uniqueHeader.contains(temp)){                              
                ProposalPDFOnPremiseController.wrapperQuoteProducts headerRecord = new ProposalPDFOnPremiseController.wrapperQuoteProducts();
                //Summary total record
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary newSummaryRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                if(totalRecord.Total_Discount__c != null && totalRecord.Total_Discount__c != 0)
                    totalRecord.Total_Discount__c /= recordsInGroup;
                totalRecord = new BigMachines__Quote_Product__c();
                recordsInGroup = 0;
                headerRecord.isHeaderRow = true;
                headerRecord.headerName = temp;
                if(quote.Group_Product_By__c == 'Use Case View')
                  headerRecord.headerDescription = eachQuoteProduct.Bundle__r.Description__c;
                headerRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
                headerRecord.record = totalRecord;
                headerRecord.hideNumbers = false;
                if(quote.Hide_Decimal_In_Total__c){
                    headerRecord.outputFormat = '###,###';
                    newSummaryRecord.outputFormat = '###,###';
                }
                else{
                    //Mukunth modified below code for 6 digit project
                    //headerRecord.outputFormat = '###,##0.00';
                    //newSummaryRecord.outputFormat = '###,##0.00';
                    if(eachQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '6'){
                        headerRecord.outputFormat = '###,##0.000000';
                        newSummaryRecord.outputFormat = '###,##0.000000';
                    }
                    else if(eachQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '4'){
                        headerRecord.outputFormat = '###,##0.0000';
                        newSummaryRecord.outputFormat = '###,##0.0000';
                    }
                    else{
                        headerRecord.outputFormat = '###,##0.00';
                        newSummaryRecord.outputFormat = '###,##0.00';
                    }
                }
                uniqueHeader.add(temp);
                quoteProducts.add(headerRecord);                
                newSummaryRecord.summaryName = groupName;
                newSummaryRecord.record = totalRecord;      
                 
                System.debug('NKC debug typeName [' + typeName + ']');
                if(mapTypeVsQuoteTotalSummary.containsKey(typeName)){
                    mapTypeVsQuoteTotalSummary.get(typeName).add(newSummaryRecord);
                }
                else{
                    List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary> newList = new List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>();
                    newList.add(newSummaryRecord);
                    mapTypeVsQuoteTotalSummary.put(typeName, newList);
                }
            }
            ProposalPDFOnPremiseController.wrapperQuoteProducts newRecord = new ProposalPDFOnPremiseController.wrapperQuoteProducts();
            newRecord.isHeaderRow = false;
            newRecord.record = eachQuoteProduct;
            newRecord.hideNumbers = false;          
            newRecord.rowStyle = '';
            if(quote.Hide_Decimal_In_Total__c)
                newRecord.outputFormat = '###,###';
            else{
                //Mukunth modified below code for 6 digit project
                //newRecord.outputFormat = '###,##0.00';   
                if(eachQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '6'){
                    newRecord.outputFormat = '###,##0.000000';
                }
                else if(eachQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '4'){
                    newRecord.outputFormat = '###,##0.0000';
                }
                else{
                    newRecord.outputFormat = '###,##0.00';
                }  
            }     
            eachQuoteProduct.Ext_List__c = (eachQuoteProduct.Ext_List__c == null ? 0 : eachQuoteProduct.Ext_List__c);
            eachQuoteProduct.Ext_Net_Price__c = (eachQuoteProduct.Ext_Net_Price__c == null ? 0 : eachQuoteProduct.Ext_Net_Price__c);            
            //eachQuoteProduct.Accepted_Volume_Discount__c = (eachQuoteProduct.Accepted_Volume_Discount__c == null ? 0 : eachQuoteProduct.Accepted_Volume_Discount__c);
            eachQuoteProduct.Total_Discount__c = (eachQuoteProduct.Total_Discount__c == null ? 0 : eachQuoteProduct.Total_Discount__c);
            eachQuoteProduct.List_Price__c = (eachQuoteProduct.List_Price__c == null ? 0 : eachQuoteProduct.List_Price__c);
            //Updating total
            totalRecord = updateTotal(totalRecord, eachQuoteProduct);
            recordsInGroup ++;
            quoteProducts.add(newRecord);           
        }        
        if(recordsInGroup > 0 && totalRecord.Total_Discount__c != null && totalRecord.Total_Discount__c != 0)
            totalRecord.Total_Discount__c /= recordsInGroup;
        return quoteProducts;
    }
    public static List<ProposalPDFOnPremiseController.wrapperQuoteProducts> getWrapperListBundles(BigMachines__Quote__c quote, 
        Map<String, List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary,  
        List<BigMachines__Quote_Product__c> quotePSRDPProducts){         
        //will hold wrapper records to return
        List<ProposalPDFOnPremiseController.wrapperQuoteProducts> quoteProducts = new List<ProposalPDFOnPremiseController.wrapperQuoteProducts>();
        //Bundles
        List<BigMachines__Quote_Product__c> quoteProductBundles = getQuoteProductsForBundles(quote.id,false);
        //will contain unique Category/Group
        Set<String> uniqueHeader = new Set<String>();       
        BigMachines__Quote_Product__c totalRecord;
        //Looping over each record and adding to wrapper list
        for(BigMachines__Quote_Product__c eachQuoteProduct : quoteProductBundles){
            //Populating PS RDP flag
            System.debug('**************');
            System.debug('NKC debug eachQuoteProduct.BigMachines__Product__r.Type__c ['+eachQuoteProduct.BigMachines__Product__r.Type__c+']');
            
            if(eachQuoteProduct.BigMachines__Product__r.Type__c == PRODUCT_TYPE_PSRDP){
                quotePSRDPProducts.add(eachQuoteProduct);
            }
            String bundleName = eachQuoteProduct.Bundle__r.Name;        
            if(!uniqueHeader.contains(bundleName)){             
                System.debug('NKC debug bundleName ['+bundleName+']');
                //Summary total record
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary newSummaryRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();               
                ProposalPDFOnPremiseController.wrapperQuoteProducts headerRecord = new ProposalPDFOnPremiseController.wrapperQuoteProducts();
                totalRecord = new BigMachines__Quote_Product__c();
                headerRecord.isHeaderRow = true;
                headerRecord.headerName = bundleName;
                headerRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
                headerRecord.record = totalRecord;
                headerRecord.hideNumbers = false;
                if(quote.Hide_Decimal_In_Total__c){
                    headerRecord.outputFormat = '###,###';      
                    newSummaryRecord.outputFormat = '###,###';          
                }
                else{
                    headerRecord.outputFormat = '###,##0.00';   
                    newSummaryRecord.outputFormat = '###,##0.00';               
                }
                uniqueHeader.add(bundleName);
                quoteProducts.add(headerRecord);
                newSummaryRecord.summaryName = bundleName; 
                
                //totalRecord = eachQuoteProduct;            
                newSummaryRecord.record = totalRecord;  
                    
                String typeName = 'Bundles';        
                if(mapTypeVsQuoteTotalSummary.containsKey(typeName)){
                    mapTypeVsQuoteTotalSummary.get(typeName).add(newSummaryRecord);
                }
                else{
                    List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary> newList = new List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>();
                    newList.add(newSummaryRecord);
                    mapTypeVsQuoteTotalSummary.put(typeName, newList);
                }
            }
            
            if(eachQuoteProduct.Bundle_Line__c != null){
                System.debug('NKC debug eachQuoteProduct.Ext_Net_Price__c [' + eachQuoteProduct.Ext_Net_Price__c + ']');
                totalRecord = updateTotal(totalRecord, eachQuoteProduct); 
                totalRecord.Total_Discount__c = eachQuoteProduct.Total_Discount__c;             
            }
            System.debug('NKC debug bundleName ['+bundleName+']');          
            if(eachQuoteProduct.BigMachines__Product__r.Name == bundleName){
                totalRecord.Ext_List__c = eachQuoteProduct.Ext_List__c;
                totalRecord.Ext_Net_Price__c = eachQuoteProduct.Ext_Net_Price__c;
                totalRecord.Accepted_Volume_Discount__c = eachQuoteProduct.Accepted_Volume_Discount__c;
                totalRecord.Total_Discount__c = eachQuoteProduct.Total_Discount__c;
                totalRecord.List_Price__c = eachQuoteProduct.List_Price__c; 
                System.debug('NKC debug totalRecord.List_Price__c ['+totalRecord.List_Price__c+']');
                System.debug('NKC debug mapTypeVsQuoteTotalSummary.get(Bundles) ['+mapTypeVsQuoteTotalSummary.get('Bundles')+']');      
                continue; 
            }
            ProposalPDFOnPremiseController.wrapperQuoteProducts newRecord = new ProposalPDFOnPremiseController.wrapperQuoteProducts();
            newRecord.isHeaderRow = false;
            newRecord.record = eachQuoteProduct;
            newRecord.hideNumbers = false;   
                    
            newRecord.rowStyle = '';
            if(quote.Hide_Decimal_In_Total__c)
                newRecord.outputFormat = '###,###';
            else{
                //Mukunth modified below code for 6 digit project
                //newRecord.outputFormat = '###,##0.00';  
                if(eachQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '6'){
                    newRecord.outputFormat = '###,##0.000000';
                }
                else if(eachQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '4'){
                    newRecord.outputFormat = '###,##0.0000';
                }
                else{
                    newRecord.outputFormat = '###,##0.00';
                }
            }        
            eachQuoteProduct.Ext_List__c = (eachQuoteProduct.Ext_List__c == null ? 0 : eachQuoteProduct.Ext_List__c);
            eachQuoteProduct.Ext_Net_Price__c = (eachQuoteProduct.Ext_Net_Price__c == null ? 0 : eachQuoteProduct.Ext_Net_Price__c);
            eachQuoteProduct.Total_Discount__c = (eachQuoteProduct.Accepted_Volume_Discount__c == null ? 0 : eachQuoteProduct.Accepted_Volume_Discount__c);
            eachQuoteProduct.Total_Discount__c = (eachQuoteProduct.Total_Discount__c == null ? 0 : eachQuoteProduct.Total_Discount__c);
            eachQuoteProduct.List_Price__c = (eachQuoteProduct.List_Price__c == null ? 0 : eachQuoteProduct.List_Price__c);
            //Naresh Kumar  11/06/2017 We do not want to show bunldes lines for below offering types.
            if(quote.Offering_Type__c != 'PureEngage Subscription' && quote.Offering_Type__c != 'PureConnect Subscription')
              quoteProducts.add(newRecord);
        }
        
        return quoteProducts;
    }
    private static BigMachines__Quote_Product__c updateTotal(BigMachines__Quote_Product__c totalRecord, BigMachines__Quote_Product__c eachQuoteProduct){
        //List Price            
        if(totalRecord.Ext_List__c == null)
            totalRecord.Ext_List__c = eachQuoteProduct.Ext_List__c;
        else
            totalRecord.Ext_List__c += (eachQuoteProduct.Ext_List__c == null ? 0 : eachQuoteProduct.Ext_List__c);
        //Extended Price            
        if(totalRecord.Ext_Net_Price__c == null)
            totalRecord.Ext_Net_Price__c = eachQuoteProduct.Ext_Net_Price__c;
        else
            totalRecord.Ext_Net_Price__c += (eachQuoteProduct.Ext_Net_Price__c == null ? 0 : eachQuoteProduct.Ext_Net_Price__c);
        //Volume Discount          
        if(totalRecord.Accepted_Volume_Discount__c == null)
            totalRecord.Accepted_Volume_Discount__c = eachQuoteProduct.Accepted_Volume_Discount__c;
        else
            totalRecord.Accepted_Volume_Discount__c += (eachQuoteProduct.Accepted_Volume_Discount__c == null ? 0 : eachQuoteProduct.Accepted_Volume_Discount__c);
        //Discount          
        if(totalRecord.Total_Discount__c == null)
            totalRecord.Total_Discount__c = eachQuoteProduct.Total_Discount__c;
        else
            totalRecord.Total_Discount__c += (eachQuoteProduct.Total_Discount__c == null ? 0 : eachQuoteProduct.Total_Discount__c);
        //List Price            
        if(totalRecord.List_Price__c == null)
            totalRecord.List_Price__c = eachQuoteProduct.List_Price__c;
        else
            totalRecord.List_Price__c += (eachQuoteProduct.List_Price__c == null ? 0 : eachQuoteProduct.List_Price__c);
            
        return totalRecord;
    }
    
    public static List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary> getSummaryWrapperListPopulatedPPU(BigMachines__Quote__c quote, 
        Map<String, List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary){
            List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary> quoteTotalSummary1 =
                new List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>();    
            Decimal total = 0;                
            Integer totalMainGroups = 0;                
            if(quote.Total_Taxes__c == null)
                quote.Total_Taxes__c = 0;
            if(quote.Total_Prepaid_Prof_Services__c == null)
                quote.Total_Prepaid_Prof_Services__c = 0;
            //Prepaid Professional Service
            BigMachines__Quote_Product__c PPSQuoteProductRecord = new BigMachines__Quote_Product__c();
            PPSQuoteProductRecord.Ext_Net_Price__c = quote.Total_Prepaid_Prof_Services__c;
            ProposalPDFOnPremiseController.wrapperQuoteTotalSummary PPSRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
            PPSRecord.summaryName = 'Prepaid Professional Service';
            PPSRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
            PPSRecord.record = PPSQuoteProductRecord;
            if(quote.Hide_Decimal_In_Total__c){
                PPSRecord.outputFormat = '###,###';                         
            }
            else{
                PPSRecord.outputFormat = '###,##0.00';              
            }
            //Tax row
            BigMachines__Quote_Product__c taxQuoteProductRecord = new BigMachines__Quote_Product__c();
            taxQuoteProductRecord.Ext_Net_Price__c = quote.Total_Taxes__c;
            ProposalPDFOnPremiseController.wrapperQuoteTotalSummary taxRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
            taxRecord.summaryName = 'Tax';
            taxRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
            taxRecord.record = taxQuoteProductRecord;
            if(quote.Hide_Decimal_In_Total__c){
                taxRecord.outputFormat = '###,###';                         
            }
            else{
                taxRecord.outputFormat = '###,##0.00';              
            }
            
            //Main heading
            BigMachines__Quote_Product__c mainHeadingRecord = new BigMachines__Quote_Product__c(); 
            ProposalPDFOnPremiseController.wrapperQuoteTotalSummary headingRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
            headingRecord.summaryName = 'Total Quote';
            headingRecord.rowStyle = 'font-weight:bold;background-color:#CFCFCF;';
            headingRecord.record = mainHeadingRecord;
            mainHeadingRecord.Ext_Net_Price__c = (mainHeadingRecord.Ext_Net_Price__c == null ? 0 : mainHeadingRecord.Ext_Net_Price__c) + quote.Total_Taxes__c + quote.Total_Prepaid_Prof_Services__c;
            if(quote.Hide_Decimal_In_Total__c){
                headingRecord.outputFormat = '###,###';                         
            }
            else{
                headingRecord.outputFormat = '###,##0.00';              
            }           
            for(String eachSection : mapTypeVsQuoteTotalSummary.keyset()){
                Integer totalSubMainGroups = 0; 
                BigMachines__Quote_Product__c sectionTotalRecord = new BigMachines__Quote_Product__c();
                System.debug('NKC debug eachSection ['+eachSection+']');
                //Looping over each software total record
                for(ProposalPDFOnPremiseController.wrapperQuoteTotalSummary eachRecord : mapTypeVsQuoteTotalSummary.get(eachSection)){
                    BigMachines__Quote_Product__c quoteProduct = eachRecord.record;
                    System.debug('NKC debug quoteProduct.List_Price__c ['+quoteProduct.List_Price__c+']');
                    //Updating total
                    sectionTotalRecord = updateTotal(sectionTotalRecord, quoteProduct);
                    mainHeadingRecord = updateTotal(mainHeadingRecord, quoteProduct);
                    eachRecord.categoryOrBundleName = eachRecord.summaryName;                   
                    eachRecord.summaryName = '';    
                    eachRecord.record = quoteProduct;
                    if(eachRecord.categoryOrBundleName == GENESYS_CARE){
                        eachRecord.record.List_Price__c = null;
                        sectionTotalRecord.List_Price__c = null;
                    }
                    totalSubMainGroups ++;          
                }               
                //Section heading
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary newRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                newRecord.summaryName = eachSection;
                newRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
                newRecord.record = sectionTotalRecord;
                if(eachSection == GENESYS_CARE && quote.Duration_Unit__c != null && quote.Hide_Maintenance_Months__c == false && quote.Duration_Unit__c != null 
                    && (quote.Order_Numb_of_Maint_Months__c != null || quote.Order_Numb_of_Maint_Days__c != null)){
                    if(quote.Duration_Unit__c.equals('Days')){
                        if(quote.Order_Numb_of_Maint_Days__c > 1)
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Days__c) + ' Days)' ;
                        else
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Days__c) + ' Day)' ;
                    }
                    else{
                        if(quote.Order_Numb_of_Maint_Months__c > 1)
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Months__c) + ' Months)' ;
                        else
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Months__c) + ' Month)' ;
                    }
                }
                if(quote.Hide_Decimal_In_Total__c){
                    newRecord.outputFormat = '###,###';                         
                }
                else{
                    newRecord.outputFormat = '###,##0.00';              
                }
                if(sectionTotalRecord.Total_Discount__c != null && sectionTotalRecord.Total_Discount__c != 0)
                    sectionTotalRecord.Total_Discount__c /= totalSubMainGroups;
                
                quoteTotalSummary1.add(newRecord);
                //Adding all categories under software recorrd
                quoteTotalSummary1.addAll(mapTypeVsQuoteTotalSummary.get(eachSection));
                totalMainGroups ++;
            }       
            if(quote.Total_Taxes__c != 0)
                quoteTotalSummary1.add(taxRecord);
            if(quote.Total_Prepaid_Prof_Services__c != 0)
              quoteTotalSummary1.add(PPSRecord);
            quoteTotalSummary1.add(headingRecord);
            System.debug('NKC debug totalMainGroups ['+totalMainGroups+']');
            //if(mainHeadingRecord.Total_Discount__c != null && mainHeadingRecord.Total_Discount__c != 0)
            //    mainHeadingRecord.Total_Discount__c /= totalMainGroups;
            mainHeadingRecord.Total_Discount__c = null;
            if(quote.Offering_Type__c == 'Cloud Partner (PPU)'){
                //CMRR
                BigMachines__Quote_Product__c CMRR = new BigMachines__Quote_Product__c();
                CMRR.Ext_Net_Price__c = quote.CMRR__c;
                total += quote.CMRR__c == null ? 0 : quote.CMRR__c;
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary CMRRRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                CMRRRecord.summaryName = 'Commited Monthly Recurring Revenue';
                CMRRRecord.rowStyle = 'background-color:#E6E6E6;';
                CMRRRecord.record = CMRR;
                if(quote.Hide_Decimal_In_Total__c){
                    CMRRRecord.outputFormat = '###,###';                         
                }
                else{
                    CMRRRecord.outputFormat = '###,##0.00';              
                }
                quoteTotalSummary1.add(CMRRRecord);
                //ACV
                BigMachines__Quote_Product__c ACV = new BigMachines__Quote_Product__c();
                ACV.Ext_Net_Price__c = quote.Annual_Contract_Value__c;
                total += quote.Annual_Contract_Value__c == null ? 0 : quote.Annual_Contract_Value__c;
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary ACVRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                ACVRecord.summaryName = 'Annual Contract Value';
                ACVRecord.rowStyle = 'background-color:#E6E6E6;';
                ACVRecord.record = ACV;
                if(quote.Hide_Decimal_In_Total__c){
                    ACVRecord.outputFormat = '###,###';                         
                }
                else{
                    ACVRecord.outputFormat = '###,##0.00';              
                }
                quoteTotalSummary1.add(ACVRecord);
                //TCV
                BigMachines__Quote_Product__c TCV = new BigMachines__Quote_Product__c();
                TCV.Ext_Net_Price__c = quote.Cloud_Total__c;
                total += quote.Cloud_Total__c == null ? 0 : quote.Cloud_Total__c;
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary TCVRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                TCVRecord.summaryName = 'Total Contract Value';
                TCVRecord.rowStyle = 'background-color:#E6E6E6;';
                TCVRecord.record = TCV;
                if(quote.Hide_Decimal_In_Total__c){
                    TCVRecord.outputFormat = '###,###';                         
                }
                else{
                    TCVRecord.outputFormat = '###,##0.00';              
                }
                quoteTotalSummary1.add(TCVRecord);
                /*
                //total
                BigMachines__Quote_Product__c total1 = new BigMachines__Quote_Product__c();
                total1.Ext_Net_Price__c = total;
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary totalRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                totalRecord.summaryName = 'Total';
                totalRecord.rowStyle = 'font-weight:bold;background-color:#CFCFCF;';
                totalRecord.record = total1;
                if(quote.Hide_Decimal_In_Total__c){
                    totalRecord.outputFormat = '###,###';                         
                }
                else{
                    totalRecord.outputFormat = '###,##0.00';              
                }
                quoteTotalSummary1.add(totalRecord);
                */
            }
            return quoteTotalSummary1;
        }
         
    public static List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary> getSummaryWrapperListPopulated(BigMachines__Quote__c quote, 
        Map<String, List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>> mapTypeVsQuoteTotalSummary){
            List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary> quoteTotalSummary1 =
                new List<ProposalPDFOnPremiseController.wrapperQuoteTotalSummary>();    
            Integer totalMainGroups = 0;                
            if(quote.Total_Taxes__c == null)
                quote.Total_Taxes__c = 0;
            if(quote.Total_Prepaid_Prof_Services__c == null)
                quote.Total_Prepaid_Prof_Services__c = 0;
            //Prepaid Professional Service
            BigMachines__Quote_Product__c PPSQuoteProductRecord = new BigMachines__Quote_Product__c();
            PPSQuoteProductRecord.Ext_Net_Price__c = quote.Total_Prepaid_Prof_Services__c;
            ProposalPDFOnPremiseController.wrapperQuoteTotalSummary PPSRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
            PPSRecord.summaryName = 'Prepaid Professional Service';
            PPSRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
            PPSRecord.record = PPSQuoteProductRecord;
            if(quote.Hide_Decimal_In_Total__c){
                PPSRecord.outputFormat = '###,###';                         
            }
            else{
                PPSRecord.outputFormat = '###,##0.00';              
            }
            //Tax row
            BigMachines__Quote_Product__c taxQuoteProductRecord = new BigMachines__Quote_Product__c();
            taxQuoteProductRecord.Ext_Net_Price__c = quote.Total_Taxes__c;
            ProposalPDFOnPremiseController.wrapperQuoteTotalSummary taxRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
            taxRecord.summaryName = 'Tax';
            taxRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
            taxRecord.record = taxQuoteProductRecord;
            if(quote.Hide_Decimal_In_Total__c){
                taxRecord.outputFormat = '###,###';                         
            }
            else{
                taxRecord.outputFormat = '###,##0.00';              
            }
            
            //Main heading
            BigMachines__Quote_Product__c mainHeadingRecord = new BigMachines__Quote_Product__c(); 
            ProposalPDFOnPremiseController.wrapperQuoteTotalSummary headingRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
            headingRecord.summaryName = 'Total Quote';
            headingRecord.rowStyle = 'font-weight:bold;background-color:#CFCFCF;';
            headingRecord.record = mainHeadingRecord;
            mainHeadingRecord.Ext_Net_Price__c = (mainHeadingRecord.Ext_Net_Price__c == null ? 0 : mainHeadingRecord.Ext_Net_Price__c) + quote.Total_Taxes__c + quote.Total_Prepaid_Prof_Services__c;
            if(quote.Hide_Decimal_In_Total__c){
                headingRecord.outputFormat = '###,###';                         
            }
            else{
                headingRecord.outputFormat = '###,##0.00';              
            }           
            for(String eachSection : mapTypeVsQuoteTotalSummary.keyset()){
                Integer totalSubMainGroups = 0; 
                BigMachines__Quote_Product__c sectionTotalRecord = new BigMachines__Quote_Product__c();
                System.debug('NKC debug eachSection ['+eachSection+']');
                //Looping over each software total record
                for(ProposalPDFOnPremiseController.wrapperQuoteTotalSummary eachRecord : mapTypeVsQuoteTotalSummary.get(eachSection)){
                    BigMachines__Quote_Product__c quoteProduct = eachRecord.record;
                    System.debug('NKC debug quoteProduct.List_Price__c ['+quoteProduct.List_Price__c+']');
                    //Updating total
                    sectionTotalRecord = updateTotal(sectionTotalRecord, quoteProduct);
                    mainHeadingRecord = updateTotal(mainHeadingRecord, quoteProduct);
                    eachRecord.categoryOrBundleName = eachRecord.summaryName;                   
                    eachRecord.summaryName = '';    
                    eachRecord.record = quoteProduct;
                    if(eachRecord.categoryOrBundleName == GENESYS_CARE){
                        eachRecord.record.List_Price__c = null;
                        sectionTotalRecord.List_Price__c = null;
                    }
                    totalSubMainGroups ++;          
                }               
                //Section heading
                ProposalPDFOnPremiseController.wrapperQuoteTotalSummary newRecord = new ProposalPDFOnPremiseController.wrapperQuoteTotalSummary();
                newRecord.summaryName = eachSection;
                newRecord.rowStyle = 'font-weight:bold;background-color:#E6E6E6;';
                newRecord.record = sectionTotalRecord;
                if(eachSection == GENESYS_CARE && quote.Duration_Unit__c != null && quote.Hide_Maintenance_Months__c == false && quote.Duration_Unit__c != null 
                    && (quote.Order_Numb_of_Maint_Months__c != null || quote.Order_Numb_of_Maint_Days__c != null)){
                    if(quote.Duration_Unit__c.equals('Days')){
                        if(quote.Order_Numb_of_Maint_Days__c > 1)
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Days__c) + ' Days)' ;
                        else
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Days__c) + ' Day)' ;
                    }
                    else{
                        if(quote.Order_Numb_of_Maint_Months__c > 1)
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Months__c) + ' Months)' ;
                        else
                            newRecord.summaryName += ' (' + String.valueOf(quote.Order_Numb_of_Maint_Months__c) + ' Month)' ;
                    }
                }
                if(quote.Hide_Decimal_In_Total__c){
                    newRecord.outputFormat = '###,###';                         
                }
                else{
                    newRecord.outputFormat = '###,##0.00';              
                }
                if(sectionTotalRecord.Total_Discount__c != null && sectionTotalRecord.Total_Discount__c != 0)
                    sectionTotalRecord.Total_Discount__c /= totalSubMainGroups;
                
                quoteTotalSummary1.add(newRecord);
                //Adding all categories under software recorrd
                quoteTotalSummary1.addAll(mapTypeVsQuoteTotalSummary.get(eachSection));
                totalMainGroups ++;
            }       
            if(quote.Total_Taxes__c != 0)
                quoteTotalSummary1.add(taxRecord);
            if(quote.Total_Prepaid_Prof_Services__c != 0)
              quoteTotalSummary1.add(PPSRecord);
            quoteTotalSummary1.add(headingRecord);
            System.debug('NKC debug totalMainGroups ['+totalMainGroups+']');
            //if(mainHeadingRecord.Total_Discount__c != null && mainHeadingRecord.Total_Discount__c != 0)
            //    mainHeadingRecord.Total_Discount__c /= totalMainGroups;
            mainHeadingRecord.Total_Discount__c = null;
            return quoteTotalSummary1;
        }
    //Getting groupname
    @TestVisible
    private static String getUniqueGroupName(BigMachines__Quote__c quote, BigMachines__Quote_Product__c quoteQuoteProduct, Map<String, String> mapProposalGroupNumberVsName){
        String groupName;
        if(quote.Group_Product_By__c == null || quote.Group_Product_By__c == 'Category View'){
            if(quote.Do_Not_Group_Output_By_Taxonomy_Category__c || quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution_Category__c == null 
                || quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution__c == null){
                if(quoteQuoteProduct.BigMachines__Product__r.New_Category__c == null)
                    groupName = 'No Category Defined';
                else
                    groupName = quoteQuoteProduct.BigMachines__Product__r.New_Category__c;
            }
            else{
                if(quote.Offering_Type__c == 'PureConnect On Premise')
                     groupName = quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution__c;  
                else
                  groupName = quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution_Category__c + ' - ' + quoteQuoteProduct.BigMachines__Product__r.Taxonomy_Solution__c; 
            }
        }
        else if(quote.Group_Product_By__c == 'Use Case View'){
            groupName = quoteQuoteProduct.Bundle__r.Name;
        }
        else{
            if(quoteQuoteProduct.Group_Number__c == null)
                groupName = 'No Group Defined';
            else
                groupName = mapProposalGroupNumberVsName.get(quoteQuoteProduct.Group_Number__c);                
        }   
        return groupName;
    }
    //Populates application type name
    @TestVisible
    private static String getTypeName(String typeName){
        if(typeName == 'Product')
            return 'Software';
        if(typeName == 'Product - Hardware')
            return 'Hardware';
        if(typeName == 'PS' || typeName == 'PS-Contract')
            return 'Professional Services';
        if(typeName == 'GU')
            return 'Education';
        return typeName;        
    }
    //Get currency symbol
    public static String getCurrencySymbol(String currencyISOCode){
        if(currencyIsoCode == 'USD' || currencyIsoCode == 'AUD')
            return '$';
        else if(currencyIsoCode == 'GBP')
            return '£';
        else if(currencyISOCode == 'BRL')
            return 'R$';         
        else if(currencyISOCode == 'EUR')
            return '€';         
        else if(currencyISOCode == 'JPY')
            return '¥';         
            
        return '';
    }
    //Getting propoal group map
    @TestVisible
    private static Map<String, String> getProporalGroupsMap(Id quoteId){
        Map<String, String> mapProposalGroupNumberVsName = new Map<String, String> ();
        List<Quote_Proposal_Group__c> proposalGroups = [SELECT Group_Number__c, Name__c, Description__c  FROM Quote_Proposal_Group__c 
            WHERE Quote__c =: quoteId];
        for(Quote_Proposal_Group__c eachQPG : proposalGroups){
            String description = '';
            if(eachQPG.Description__c != null){
                if(eachQPG.Description__c.length() > 40){
                    description = eachQPG.Description__c.substring(0, 39) + ' ...';     
                }
                else
                    description = eachQPG.Description__c;
            }
            mapProposalGroupNumberVsName.put(eachQPG.Group_Number__c, eachQPG.Name__c + ' ('+ description +')');
        }
        return mapProposalGroupNumberVsName;
    }
}