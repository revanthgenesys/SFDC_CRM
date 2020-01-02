public class ProposalPdfInlineDataExt 
{
    // Quote
    public BigMachines__Quote__c objQuote {get; private set;}
    // Flex Care Products
    public List<BigMachines__Quote_Product__c> list_FlexCare {get; private set;}
    // Fees Products
    public List<BigMachines__Quote_Product__c> list_Fees {get; private set;}
    // Grid Products
    public List<BigMachines__Quote_Product__c> list_GridProducts {get; private set;}
    // Number of Periods
    public Integer intNumOfPeriods {get; private set;}
    // Map of Column Widths
    public Map<String,Decimal> map_ColNameToColWidth {get; private set;}
    
    Map<String,InvoiceGroup> map_InvoiceNumToInvoiceGroup;
    // Indicates whether it's for Internal i.e. Order management team
    public String strInternal {get; private set;}
    //public Boolean blnShowKPIs {get; private set;}
    public Boolean PureConnectDirect {get; set;}
    public Boolean Downsize {get; set;}
    public class InvoiceGroup
    {
        public List<BigMachines__Quote_Product__c> list_QouteProducts {get; set;}
        public BigMachines__Quote_Product__c objInvoiceGroupQP {get; set;}
        // Added by RAO
        public Boolean invoiceELA {get; set;}
        public InvoiceGroup()
        {
            list_QouteProducts = new List<BigMachines__Quote_Product__c>();
            objInvoiceGroupQP = new BigMachines__Quote_Product__c();
            invoiceELA = false;
        }
    }
    
    public List<InvoiceGroup> list_InvoiceGroups {get; private set;}
    
    //*** Constructor ***
    public ProposalPdfInlineDataExt(ApexPages.StandardController controller) 
    {
        Downsize=false;
        // Flag set for internal ie. Order Management team to show some additional data (strInternal = 1)
        strInternal = ApexPages.currentPage().getParameters().get('internal');
        
        objQuote = [SELECT Id, Hide_Maintenance_Due__c, Show_Maintenance_Due_Sub_Totals__c, Show_Total_Maintenance_Due__c, Hide_Discount__c,
                    Hide_Revised_Net__c, Show_Revised_Net_Sub_Totals__c, Show_Total_License_Net_Value__c,
                    Hide_Truncate_Decimals__c,Hide_P2P_Uplift_Fee__c,Show_Comments__c, Hide_ELA__c,
                    Hide_Quaterly_Semi_Annual_Fee__c,Hide_Reinstatement_Fee__c,Hide_Periods__c,Show_Rates__c,Show_KPIs__c,Show_Shelving_Fees__c,
                    Show_Reinstatment__c,Show_EOS__c,Show_EOS_Fees__c,Show_Product_Code__c,Show_Billing_Plan__c,Group_Product_By__c,
                    Period1_Maintenance_Due_Formula__c,Period1_Flex_Care_Amount__c,Period1_P2P_Uplift_Fee__c,
                    Period1_Quaterly_Semi_Annual_Fee__c,Total_Due_Period1__c,
                    Period2_Maintenance_Due__c,Period2_Flex_Care_Amount__c,Period2_P2P_Uplift_Fee__c,
                    Period2_Quaterly_Semi_Annual_Fee__c,Total_Due_Period2__c,
                    Period3_Maintenance_Due__c,Period3_Flex_Care_Amount__c,Period3_P2P_Uplift_Fee__c,
                    Period3_Quaterly_Semi_Annual_Fee__c,Total_Due_Period3__c,
                    Period4_Maintenance_Due__c,Period4_Flex_Care_Amount__c,Period4_P2P_Uplift_Fee__c,
                    Period4_Quaterly_Semi_Annual_Fee__c,Total_Due_Period4__c,
                    Period5_Maintenance_Due__c,Period5_Flex_Care_Amount__c,Period5_P2P_Uplift_Fee__c,
                    Period5_Quaterly_Semi_Annual_Fee__c,Total_Due_Period5__c,Show_Pricing_Model__c,
                    Total_Taxes__c,Grand_Total__c,Total_Flex_Care__c,Extended_End_of_Support_Formula__c,Total_Renewal_Without_Tax__c,
                    Reinstatement_Fee_Formula__c,Total_Revised_Net_License_Value_Formula__c,Total_Shelving_Fee__c,CurrencyISOCode,
                    Period1_EOS_Fee__c,Period2_EOS_Fee__c,Period3_EOS_Fee__c,Period4_EOS_Fee__c,Period5_EOS_Fee__c,
                    Period1_Reinstatement_Fee__c,Period2_Reinstatement_Fee__c,Period3_Reinstatement_Fee__c,Period4_Reinstatement_Fee__c,Period5_Reinstatement_Fee__c,
                    Period1_Shelving_Fee__c,Period2_Shelving_Fee__c,Period3_Shelving_Fee__c,Period4_Shelving_Fee__c,Period5_Shelving_Fee__c,
                    Period1_KPI1_Amount__c,Period2_KPI1_Amount__c,Period3_KPI1_Amount__c,Period4_KPI1_Amount__c,Period5_KPI1_Amount__c,
                    Period1_KPI2_Amount__c,Period2_KPI2_Amount__c,Period3_KPI2_Amount__c,Period4_KPI2_Amount__c,Period5_KPI2_Amount__c,
                    Total_KPI1_Amount__c,Total_KPI2_Amount__c, Maintenance_Due_Discount_Amount__c, Total_Maintenance_Due_After_Discount__c,
                    Sold_To_Name__r.Name,End_User_ID__r.Name,Name,Quote_Created_Date__c,Current_Maint_Rate__c,Increase_type__c, License_Reduction_Fee__c,Opportunity_Offering_Type__c,
                    (SELECT Start_Date__c,End_Date__c,Default_Period_Care_Rate__c,Default_Increase__c,KPI1__c,KPI2__c
                     FROM Quote_Periods__r ORDER BY Start_Date__c),
                    (SELECT Amount__c,Invoice__c,Invoice_Date__c,Support_Period_End_Date__c,Support_Period_Start_Date__c 
                     FROM Quote_Billing_Plans__r ORDER BY Support_Period_Start_Date__c)
                    FROM BigMachines__Quote__c WHERE Id = :controller.getId()];
        
        intNumOfPeriods = objQuote.Quote_Periods__r.size();
        
        /** By Yuvaraj - Revised Net to Revised List Price label change on PDF**/
        if(objQuote.Opportunity_Offering_Type__c =='PureConnect' && objQuote.Sold_To_Name__r.Name==objQuote.End_User_ID__r.Name)
        PureConnectDirect =true;
        
        /*blnShowKPIs = false;
for(Quote_Period__c objQuotePeriod : objQuote.Quote_Periods__r)
{
if((objQuotePeriod.KPI1__c != null && objQuotePeriod.KPI1__c != 0) || (objQuotePeriod.KPI2__c != null && objQuotePeriod.KPI2__c != 0))
{
blnShowKPIs = true;
break;
}
}*/
        
        fetchConfigProducts();
        fetchGridProducts();
        defineColumnWidths();
        // Added by RAO
        populateInvoiceELA();
        
    }
    
    //*** To define column widths based on the columns being displayed ***
    void defineColumnWidths()
    {
        map_ColNameToColWidth = new Map<String,Decimal>();
        Decimal decDeduction = (objQuote.Show_Reinstatment__c?2:0) + ((objQuote.Show_EOS__c || objQuote.Show_EOS_Fees__c)?2:0) +
            (objQuote.Show_Product_Code__c?2.5:0) + ((objQuote.Hide_Revised_Net__c && strInternal != '1') ?0:2.5) +
            (objQuote.Show_EOS_Fees__c?1.5:0) + (objQuote.Show_Shelving_Fees__c?3.5:0);
        
        map_ColNameToColWidth.put('Product Name',31);
        map_ColNameToColWidth.put('Quantity',21);
        map_ColNameToColWidth.put('Original Quantity',21);
        map_ColNameToColWidth.put('Maintenance Start Date',26);
        map_ColNameToColWidth.put('Maintenance End Date',26);
        if(!objQuote.Hide_Maintenance_Due__c || strInternal == '1')
        {
            map_ColNameToColWidth.put('Maintenance Due',20);
            map_ColNameToColWidth.put('Quantity',14);
            map_ColNameToColWidth.put('Original Quantity',14);
            map_ColNameToColWidth.put('Maintenance Start Date',18);
            map_ColNameToColWidth.put('Maintenance End Date',18);
        }
        
        if(objQuote.Show_Reinstatment__c)
            map_ColNameToColWidth.put('Reinstatement',8);
        
        if(objQuote.Show_EOS__c)
            map_ColNameToColWidth.put('Extended EOS',8);
        
        if(objQuote.Show_EOS_Fees__c)
        {
            map_ColNameToColWidth.put('Extended EOS',16);
            map_ColNameToColWidth.put('Maintenance Due',18);
        }
        if(objQuote.Show_Shelving_Fees__c)
        {
            map_ColNameToColWidth.put('Shelving Fees',14);
            if(map_ColNameToColWidth.containsKey('Maintenance Due'))
            {
                map_ColNameToColWidth.put('Shelving Fees',16);
                map_ColNameToColWidth.put('Maintenance Due',map_ColNameToColWidth.get('Maintenance Due') - 2);
            }
        }
        
        if(objQuote.Show_Product_Code__c)
            map_ColNameToColWidth.put('Product Code',8);
        
        if(!objQuote.Hide_Revised_Net__c || strInternal == '1')
            map_ColNameToColWidth.put('Revised Net',8);
        
        map_ColNameToColWidth.put('Product Name',map_ColNameToColWidth.get('Product Name') - decDeduction);
        map_ColNameToColWidth.put('Quantity',map_ColNameToColWidth.get('Quantity') - decDeduction);
        map_ColNameToColWidth.put('Maintenance Start Date',map_ColNameToColWidth.get('Maintenance Start Date') - decDeduction);
        map_ColNameToColWidth.put('Maintenance End Date',map_ColNameToColWidth.get('Maintenance End Date') - decDeduction);
    }
    
    //*** To fetch Configuration (Fees and Flex Care) Products ***
    void fetchConfigProducts()
    {
        list_Fees = new List<BigMachines__Quote_Product__c>();
        list_FlexCare = new List<BigMachines__Quote_Product__c>();
        
        for(BigMachines__Quote_Product__c objQuoteProduct : [SELECT Id,BigMachines__Product__r.Type__c,Comment__c,
                                                             Product_Description__c,Maintenance_Start_Date__c,Maintenance_End_Date__c,
                                                             BigMachines__Product__r.Name,Sales_Price_Display__c,Revised_Net_License_value__c
                                                             FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :objQuote.Id AND
                                                             (BigMachines__Product__r.Type__c = 'Flex Care' OR BigMachines__Product__r.Type__c = 'Fees')
                                                             ORDER BY Maintenance_Start_Date__c,Product_Description__c])
        {
            if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Fees')                  
                list_Fees.add(objQuoteProduct);
            
            else if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
                list_FlexCare.add(objQuoteProduct);
        }
    }
    
    //*** To fetch Grid Products ***
    void fetchGridProducts()
    {
        list_GridProducts = new List<BigMachines__Quote_Product__c>();
        //list_InvoiceNum = new List<String>();
        list_InvoiceGroups = new List<InvoiceGroup>();
        if(objQuote.Group_Product_By__c == null || objQuote.Group_Product_By__c == '')
        {
            list_GridProducts = [SELECT Current_Qty__c, Maintenance_Due_Display__c,Year2_Maintenance_Due_Display__c, Comment__c,
                                 Year3_Maintenance_Due_Display__c, Year4_Maintenance_Due_Display__c,Year5_Maintenance_Due_Display__c,
                                 Maintenance_Due_Formula__c,Maintenance_Due__c, Year2_Maintenance_Due__c, 
                                 Year3_Maintenance_Due__c,Year4_Maintenance_Due__c,Year5_Maintenance_Due__c,
                                 Period1_EOS_Fee__c, Period2_EOS_Fee__c, Period3_EOS_Fee__c,Period4_EOS_Fee__c,Period5_EOS_Fee__c,
                                 Period1_Shelving_Fee__c, Period2_Shelving_Fee__c, Period3_Shelving_Fee__c,Period4_Shelving_Fee__c,Period5_Shelving_Fee__c,
                                 Product_Description__c,
                                 BigMachines__Product__r.Name, BigMachines__Product__r.APN_Number__c, BigMachines__Product__r.Description, BigMachines__Product__r.OfferingType__c,
                                 Revised_Net_License_Value__c,Product_type__c,
                                 Extended_End_of_Support__c,Reinstatement__c,Maintenance_Start_Date__c,Maintenance_End_Date__c,
                                 Contract_Line_Update_Status__c, Original_Qty__c
                                 FROM BigMachines__Quote_Product__c
                                 WHERE BigMachines__Quote__c = :objQuote.id AND 
                                 BigMachines__Product__r.Genesys_Care_Quote__c = false AND
                                 BigMachines__Product__r.Type__c != 'Flex Care' AND
                                 BigMachines__Product__r.Type__c != 'Fees'  AND (Dont_Show_On_Quote__c = false OR Contract_Line_Update_Status__c='Downsize')
                                 ORDER BY Maintenance_Start_Date__c,Product_Description__c];
        }
        else if(objQuote.Group_Product_By__c == 'Part Number')
        {
            Map<Id,BigMachines__Quote_Product__c> map_ProductIdToQuoteProduct = new Map<Id,BigMachines__Quote_Product__c>();
            
            for(BigMachines__Quote_Product__c objQuoteProduct : [SELECT Id,BigMachines__Product__r.Type__c,Comment__c,
                                                                 Product_Description__c,Maintenance_Start_Date__c,Maintenance_End_Date__c,Current_Qty__c,
                                                                 BigMachines__Product__r.Name, BigMachines__Product__r.APN_Number__c, BigMachines__Product__r.Description, BigMachines__Product__r.OfferingType__c,
                                                                 BigMachines__Product__c,Revised_Net_License_Value__c,
                                                                 Maintenance_Due__c, Year2_Maintenance_Due__c, Year3_Maintenance_Due__c,
                                                                 Year4_Maintenance_Due__c,Year5_Maintenance_Due__c,
                                                                 Period1_EOS_Fee__c, Period2_EOS_Fee__c, Period3_EOS_Fee__c,Period4_EOS_Fee__c,Period5_EOS_Fee__c,
                                                                 Period1_Shelving_Fee__c, Period2_Shelving_Fee__c, Period3_Shelving_Fee__c,Period4_Shelving_Fee__c,Period5_Shelving_Fee__c,Product_type__c,
                                                                 Extended_End_of_Support__c,Reinstatement__c,
                                                                 Contract_Line_Update_Status__c, Original_Qty__c
                                                                 FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :objQuote.Id AND
                                                                 BigMachines__Product__r.Genesys_Care_Quote__c = false AND
                                                                 BigMachines__Product__r.Type__c != 'Flex Care' AND
                                                                 BigMachines__Product__r.Type__c != 'Fees' AND (Dont_Show_On_Quote__c = false OR Contract_Line_Update_Status__c='Downsize')
                                                                 ORDER BY Product_Description__c])
            {
                if(map_ProductIdToQuoteProduct.containsKey(objQuoteProduct.BigMachines__Product__c))                  
                {
                    BigMachines__Quote_Product__c objTempQP = map_ProductIdToQuoteProduct.get(objQuoteProduct.BigMachines__Product__c);
                    
                   
                    //Quantity
                    objTempQP.Current_Qty__c = objTempQP.Current_Qty__c != null ? objTempQP.Current_Qty__c : 0;
                    objQuoteProduct.Current_Qty__c = objQuoteProduct.Current_Qty__c != null ? objQuoteProduct.Current_Qty__c : 0;  
					
					//Mukunth added as fix for INC0441611
                    objTempQP.Original_Qty__c = objTempQP.Original_Qty__c != null ? objTempQP.Original_Qty__c : 0;
                    objQuoteProduct.Original_Qty__c = objQuoteProduct.Original_Qty__c != null ? objQuoteProduct.Original_Qty__c : 0;  
					//Mukunth - End
                    
                   
                    // ADDED BY RAO for calculating proper current quantities when Shelved
                    // RAO *** Calculate the Current Quantity by deducting the Shelved Items 
                    if(objQuoteProduct.Contract_Line_Update_Status__c == 'Shelved' || objQuoteProduct.Contract_Line_Update_Status__c == 'Drop' || objQuoteProduct.Contract_Line_Update_Status__c == 'Downsize'){
                       
                        Downsize=true;
                        if(objQuoteProduct.Original_Qty__c == objQuoteProduct.Current_Qty__c){
                            objTempQP.Current_Qty__c = (objTempQP.Current_Qty__c != null && objTempQP.Current_Qty__c != 0)? objTempQP.Current_Qty__c : 0;
                            objTempQP.Original_Qty__c += objQuoteProduct.Original_Qty__c;
                        }
                        else{
							//Mukunth added as fix for INC0441611
                            objTempQP.Current_Qty__c += objQuoteProduct.Current_Qty__c;
							objTempQP.Original_Qty__c += objQuoteProduct.Original_Qty__c;
							//Mukunth - End
						}
                            
                    } else {
                        objTempQP.Current_Qty__c += objQuoteProduct.Current_Qty__c;
						objTempQP.Original_Qty__c += objQuoteProduct.Original_Qty__c;//Mukunth added as fix for INC0441611
					}
                    
                 //   objTempQP.Current_Qty__c += objQuoteProduct.Current_Qty__c;
                 
                    
                    //Revised Net
                    objTempQP.Revised_Net_License_Value__c = objTempQP.Revised_Net_License_Value__c != null ? objTempQP.Revised_Net_License_Value__c : 0;
                    objQuoteProduct.Revised_Net_License_Value__c = objQuoteProduct.Revised_Net_License_Value__c != null ? objQuoteProduct.Revised_Net_License_Value__c : 0;                 
                    objTempQP.Revised_Net_License_Value__c += objQuoteProduct.Revised_Net_License_Value__c;
                    
                    for(Integer intYear = 1; intYear <= 5 ; intYear++)
                    {
                        String strMaintDueFieldName = (intYear == 1) ? 'Maintenance_Due__c' : 'Year' + String.valueOf(intYear) + '_Maintenance_Due__c';
                        String strEOSFieldName = 'Period' + String.valueOf(intYear) + '_EOS_Fee__c';
                        String strShelvingFieldName = 'Period' + String.valueOf(intYear) + '_Shelving_Fee__c';
                        
                        // Maintenance Due
                        objTempQP.put(strMaintDueFieldName,objTempQP.get(strMaintDueFieldName) != null ? (Decimal)objTempQP.get(strMaintDueFieldName) : 0);
                        objQuoteProduct.put(strMaintDueFieldName,objQuoteProduct.get(strMaintDueFieldName) != null ? (Decimal)objQuoteProduct.get(strMaintDueFieldName) : 0);
                        objTempQP.put(strMaintDueFieldName,(Decimal)objTempQP.get(strMaintDueFieldName) + (Decimal)objQuoteProduct.get(strMaintDueFieldName));
                        
                        // EOS
                        objTempQP.put(strEOSFieldName,objTempQP.get(strEOSFieldName) != null ? (Decimal)objTempQP.get(strEOSFieldName) : 0);
                        objQuoteProduct.put(strEOSFieldName,objQuoteProduct.get(strEOSFieldName) != null ? (Decimal)objQuoteProduct.get(strEOSFieldName) : 0);
                        objTempQP.put(strEOSFieldName,(Decimal)objTempQP.get(strEOSFieldName) + (Decimal)objQuoteProduct.get(strEOSFieldName));
                        
                        // Shelving Fees
                        objTempQP.put(strShelvingFieldName,objTempQP.get(strShelvingFieldName) != null ? (Decimal)objTempQP.get(strShelvingFieldName) : 0);
                        objQuoteProduct.put(strShelvingFieldName,objQuoteProduct.get(strShelvingFieldName) != null ? (Decimal)objQuoteProduct.get(strShelvingFieldName) : 0);
                        objTempQP.put(strShelvingFieldName,(Decimal)objTempQP.get(strShelvingFieldName) + (Decimal)objQuoteProduct.get(strShelvingFieldName));
                    }
                    
                    if(objQuote.Hide_Periods__c)
                    {
                        // Using Total_Maintenance_Due__c as a container for total of maintenance due
                        objTempQP.Total_Maintenance_Due__c = objTempQP.Maintenance_Due__c + objTempQP.Year2_Maintenance_Due__c + 
                            objTempQP.Year3_Maintenance_Due__c + objTempQP.Year4_Maintenance_Due__c + objTempQP.Year5_Maintenance_Due__c;
                        
                        // Using Adjustment__c as a container for total of EOS fee
                        objTempQP.Adjustment__c = objTempQP.Period1_EOS_Fee__c + objTempQP.Period2_EOS_Fee__c + 
                            objTempQP.Period3_EOS_Fee__c + objTempQP.Period4_EOS_Fee__c + objTempQP.Period5_EOS_Fee__c;
                        
                        // Using Decreased_Quote_Value__c as a container for total of Shelving fee
                        objTempQP.Decreased_Quote_Value__c = objTempQP.Period1_Shelving_Fee__c + objTempQP.Period2_Shelving_Fee__c + 
                            objTempQP.Period3_Shelving_Fee__c + objTempQP.Period4_Shelving_Fee__c + objTempQP.Period5_Shelving_Fee__c;
                    }
                }
                else
                {
                    
                   
                    // ADDED BY RAO for calculating proper current quantities when Shelved
                    // RAO *** Calculate the Current Quantity by deducting the Shelved Items 
                    if(objQuoteProduct.Contract_Line_Update_Status__c == 'Shelved' || objQuoteProduct.Contract_Line_Update_Status__c == 'Drop' || objQuoteProduct.Contract_Line_Update_Status__c == 'Downsize'){
                        // objQuoteProduct.Original_Qty__c - objQuoteProduct.Current_Qty__c
                       Downsize=true;
                        if(objQuoteProduct.Original_Qty__c == objQuoteProduct.Current_Qty__c)
                            objQuoteProduct.Current_Qty__c = 0;
                    } 
                    
                   
                    
                    map_ProductIdToQuoteProduct.put(objQuoteProduct.BigMachines__Product__c,objQuoteProduct);
                    if(objQuote.Hide_Periods__c)
                    {
                        // Using Total_Maintenance_Due__c as a container for total of maintenance due
                        objQuoteProduct.Total_Maintenance_Due__c = (objQuoteProduct.Maintenance_Due__c != null ? objQuoteProduct.Maintenance_Due__c : 0) +
                            (objQuoteProduct.Year2_Maintenance_Due__c != null ? objQuoteProduct.Year2_Maintenance_Due__c : 0) +
                            (objQuoteProduct.Year3_Maintenance_Due__c != null ? objQuoteProduct.Year3_Maintenance_Due__c : 0) +
                            (objQuoteProduct.Year4_Maintenance_Due__c != null ? objQuoteProduct.Year4_Maintenance_Due__c : 0) +
                            (objQuoteProduct.Year5_Maintenance_Due__c != null ? objQuoteProduct.Year5_Maintenance_Due__c : 0);
                        
                        // Using Adjustment__c as a container for total of EOS fee
                        objQuoteProduct.Adjustment__c = (objQuoteProduct.Period1_EOS_Fee__c != null ? objQuoteProduct.Period1_EOS_Fee__c : 0) +
                            (objQuoteProduct.Period2_EOS_Fee__c != null ? objQuoteProduct.Period2_EOS_Fee__c : 0) +
                            (objQuoteProduct.Period3_EOS_Fee__c != null ? objQuoteProduct.Period3_EOS_Fee__c : 0) +
                            (objQuoteProduct.Period4_EOS_Fee__c != null ? objQuoteProduct.Period4_EOS_Fee__c : 0) +
                            (objQuoteProduct.Period5_EOS_Fee__c != null ? objQuoteProduct.Period5_EOS_Fee__c : 0);
                        
                        // Using Decreased_Quote_Value__c as a container for total of Shelving fee              
                        objQuoteProduct.Decreased_Quote_Value__c = (objQuoteProduct.Period1_Shelving_Fee__c != null ? objQuoteProduct.Period1_Shelving_Fee__c : 0) +
                            (objQuoteProduct.Period2_Shelving_Fee__c != null ? objQuoteProduct.Period2_Shelving_Fee__c : 0) +
                            (objQuoteProduct.Period3_Shelving_Fee__c != null ? objQuoteProduct.Period3_Shelving_Fee__c : 0) +
                            (objQuoteProduct.Period4_Shelving_Fee__c != null ? objQuoteProduct.Period4_Shelving_Fee__c : 0) +
                            (objQuoteProduct.Period5_Shelving_Fee__c != null ? objQuoteProduct.Period5_Shelving_Fee__c : 0);
                    }
                    list_GridProducts.add(objQuoteProduct);
                }
            }
        }
        else if(objQuote.Group_Product_By__c == 'Invoice Number')
        {
            map_InvoiceNumToInvoiceGroup = new Map<String,InvoiceGroup>();
            
            for(BigMachines__Quote_Product__c objQuoteProduct : [SELECT Id,BigMachines__Product__r.Type__c,Comment__c,
                                                                 Product_Description__c,Maintenance_Start_Date__c,Maintenance_End_Date__c,Current_Qty__c,
                                                                 BigMachines__Product__r.Name, BigMachines__Product__r.APN_Number__c, BigMachines__Product__r.Description, BigMachines__Product__r.OfferingType__c,
                                                                 BigMachines__Product__c,Revised_Net_License_Value__c,
                                                                 Maintenance_Due__c, Year2_Maintenance_Due__c, Year3_Maintenance_Due__c,
                                                                 Year4_Maintenance_Due__c,Year5_Maintenance_Due__c,
                                                                 Period1_EOS_Fee__c, Period2_EOS_Fee__c, Period3_EOS_Fee__c,Period4_EOS_Fee__c,Period5_EOS_Fee__c,
                                                                 Period1_Shelving_Fee__c, Period2_Shelving_Fee__c, Period3_Shelving_Fee__c,Period4_Shelving_Fee__c,Period5_Shelving_Fee__c,Product_type__c,
                                                                 Extended_End_of_Support__c,Reinstatement__c,Lic_Invoice__c,
                                                                 Original_License_Invoice_Date__c,Original_PO__c,Invoice_Rate__c,
                                                                 Contract_Line_Update_Status__c, Original_Qty__c                                                                 
                                                                 FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :objQuote.Id AND
                                                                 BigMachines__Product__r.Genesys_Care_Quote__c = false AND
                                                                 BigMachines__Product__r.Type__c != 'Flex Care' AND
                                                                 BigMachines__Product__r.Type__c != 'Fees' AND (Dont_Show_On_Quote__c = false OR Contract_Line_Update_Status__c='Downsize')
                                                                 ORDER BY  Original_License_Invoice_Date__c NULLS LAST,Product_Description__c])
            {
                String LicInvoiceUpperCase = objQuoteProduct.Lic_Invoice__c != NULL ? objQuoteProduct.Lic_Invoice__c.toUpperCase() : '-';
                
                if(objQuoteProduct.Contract_Line_Update_Status__c == 'Shelved' || objQuoteProduct.Contract_Line_Update_Status__c == 'Drop' || objQuoteProduct.Contract_Line_Update_Status__c == 'Downsize'){
                    // objQuoteProduct.Original_Qty__c - objQuoteProduct.Current_Qty__c
                   Downsize=true;
                    if(objQuoteProduct.Original_Qty__c == objQuoteProduct.Current_Qty__c)
                        objQuoteProduct.Current_Qty__c = 0;
                } 
                
                
                if(objQuote.Hide_Periods__c)
                {
                    // Using Total_Maintenance_Due__c as a container for total of maintenance due
                    objQuoteProduct.Total_Maintenance_Due__c = (objQuoteProduct.Maintenance_Due__c != null ? objQuoteProduct.Maintenance_Due__c : 0) +
                        (objQuoteProduct.Year2_Maintenance_Due__c != null ? objQuoteProduct.Year2_Maintenance_Due__c : 0) +
                        (objQuoteProduct.Year3_Maintenance_Due__c != null ? objQuoteProduct.Year3_Maintenance_Due__c : 0) +
                        (objQuoteProduct.Year4_Maintenance_Due__c != null ? objQuoteProduct.Year4_Maintenance_Due__c : 0) +
                        (objQuoteProduct.Year5_Maintenance_Due__c != null ? objQuoteProduct.Year5_Maintenance_Due__c : 0);
                    
                    // Using Adjustment__c as a container for total of EOS fee
                    objQuoteProduct.Adjustment__c = (objQuoteProduct.Period1_EOS_Fee__c != null ? objQuoteProduct.Period1_EOS_Fee__c : 0) +
                        (objQuoteProduct.Period2_EOS_Fee__c != null ? objQuoteProduct.Period2_EOS_Fee__c : 0) +
                        (objQuoteProduct.Period3_EOS_Fee__c != null ? objQuoteProduct.Period3_EOS_Fee__c : 0) +
                        (objQuoteProduct.Period4_EOS_Fee__c != null ? objQuoteProduct.Period4_EOS_Fee__c : 0) +
                        (objQuoteProduct.Period5_EOS_Fee__c != null ? objQuoteProduct.Period5_EOS_Fee__c : 0);
                    
                    // Using Decreased_Quote_Value__c as a container for total of Shelving fee
                    objQuoteProduct.Decreased_Quote_Value__c = (objQuoteProduct.Period1_Shelving_Fee__c != null ? objQuoteProduct.Period1_Shelving_Fee__c : 0) +
                        (objQuoteProduct.Period2_Shelving_Fee__c != null ? objQuoteProduct.Period2_Shelving_Fee__c : 0) +
                        (objQuoteProduct.Period3_Shelving_Fee__c != null ? objQuoteProduct.Period3_Shelving_Fee__c : 0) +
                        (objQuoteProduct.Period4_Shelving_Fee__c != null ? objQuoteProduct.Period4_Shelving_Fee__c : 0) +
                        (objQuoteProduct.Period5_Shelving_Fee__c != null ? objQuoteProduct.Period5_Shelving_Fee__c : 0);
                }
                
                if(map_InvoiceNumToInvoiceGroup.containsKey(LicInvoiceUpperCase))
                {
                    InvoiceGroup objInvoiceGroup = map_InvoiceNumToInvoiceGroup.get(LicInvoiceUpperCase);
                    objInvoiceGroup.list_QouteProducts.add(objQuoteProduct);
                    BigMachines__Quote_Product__c objTempQP = objInvoiceGroup.objInvoiceGroupQP;
                    objTempQP.Revised_Net_License_Value__c = objTempQP.Revised_Net_License_Value__c != NULL ? objTempQP.Revised_Net_License_Value__c : 0;
                    objTempQP.Revised_Net_License_Value__c += (objQuoteProduct.Revised_Net_License_Value__c != null && objQuoteProduct.Revised_Net_License_Value__c > 0) ? objQuoteProduct.Revised_Net_License_Value__c : 0;
                    
                    for(Integer intYear = 1; intYear <= 5 ; intYear++)
                    {
                        String strMaintDueFieldName = (intYear == 1) ? 'Maintenance_Due__c' : 'Year' + String.valueOf(intYear) + '_Maintenance_Due__c';
                        String strEOSFieldName = 'Period' + String.valueOf(intYear) + '_EOS_Fee__c';
                        String strShelvingFieldName = 'Period' + String.valueOf(intYear) + '_Shelving_Fee__c';
                        
                        // Maintenance Due
                        objTempQP.put(strMaintDueFieldName,objTempQP.get(strMaintDueFieldName) != null ? (Decimal)objTempQP.get(strMaintDueFieldName) : 0);
                        objQuoteProduct.put(strMaintDueFieldName,objQuoteProduct.get(strMaintDueFieldName) != null ? (Decimal)objQuoteProduct.get(strMaintDueFieldName) : 0);
                        objTempQP.put(strMaintDueFieldName,(Decimal)objTempQP.get(strMaintDueFieldName) + (Decimal)objQuoteProduct.get(strMaintDueFieldName));
                        
                        // EOS
                        objTempQP.put(strEOSFieldName,objTempQP.get(strEOSFieldName) != null ? (Decimal)objTempQP.get(strEOSFieldName) : 0);
                        objQuoteProduct.put(strEOSFieldName,objQuoteProduct.get(strEOSFieldName) != null ? (Decimal)objQuoteProduct.get(strEOSFieldName) : 0);
                        objTempQP.put(strEOSFieldName,(Decimal)objTempQP.get(strEOSFieldName) + (Decimal)objQuoteProduct.get(strEOSFieldName));
                        
                        // Shelving Fees
                        objTempQP.put(strShelvingFieldName,objTempQP.get(strShelvingFieldName) != null ? (Decimal)objTempQP.get(strShelvingFieldName) : 0);
                        objQuoteProduct.put(strShelvingFieldName,objQuoteProduct.get(strShelvingFieldName) != null ? (Decimal)objQuoteProduct.get(strShelvingFieldName) : 0);
                        objTempQP.put(strShelvingFieldName,(Decimal)objTempQP.get(strShelvingFieldName) + (Decimal)objQuoteProduct.get(strShelvingFieldName));
                    }
                    
                    if(objQuote.Hide_Periods__c)
                    {
                        // Using Total_Maintenance_Due__c as a container for total of maintenance due
                        objTempQP.Total_Maintenance_Due__c = objTempQP.Maintenance_Due__c + objTempQP.Year2_Maintenance_Due__c + 
                            objTempQP.Year3_Maintenance_Due__c + objTempQP.Year4_Maintenance_Due__c + objTempQP.Year5_Maintenance_Due__c;
                        
                        // Using Adjustment__c as a container for total of EOS fee
                        objTempQP.Adjustment__c = objTempQP.Period1_EOS_Fee__c + objTempQP.Period2_EOS_Fee__c + 
                            objTempQP.Period3_EOS_Fee__c + objTempQP.Period4_EOS_Fee__c + objTempQP.Period5_EOS_Fee__c;
                        
                        // Using Decreased_Quote_Value__c as a container for total of Shelving fee
                        objTempQP.Decreased_Quote_Value__c = objTempQP.Period1_Shelving_Fee__c + objTempQP.Period2_Shelving_Fee__c + 
                            objTempQP.Period3_Shelving_Fee__c + objTempQP.Period4_Shelving_Fee__c + objTempQP.Period5_Shelving_Fee__c;
                    }
                }
                else
                {
                    InvoiceGroup objInvoiceGroup = new InvoiceGroup();
                    objInvoiceGroup.list_QouteProducts.add(objQuoteProduct);
                    BigMachines__Quote_Product__c objTempQP = new BigMachines__Quote_Product__c();
                    objTempQP.Lic_Invoice__c = objQuoteProduct.Lic_Invoice__c;
                    objTempQP.Original_License_Invoice_Date__c = objQuoteProduct.Original_License_Invoice_Date__c;
                    objTempQP.Original_PO__c = objQuoteProduct.Original_PO__c;
                    objTempQP.Invoice_Rate__c = objQuoteProduct.Invoice_Rate__c;
                    objTempQP.Revised_Net_License_Value__c = objQuoteProduct.Revised_Net_License_Value__c;
                    
                    for(Integer intYear = 1; intYear <= 5 ; intYear++)
                    {
                        String strMaintDueFieldName = (intYear == 1) ? 'Maintenance_Due__c' : 'Year' + String.valueOf(intYear) + '_Maintenance_Due__c';
                        String strEOSFieldName = 'Period' + String.valueOf(intYear) + '_EOS_Fee__c';
                        String strShelvingFieldName = 'Period' + String.valueOf(intYear) + '_Shelving_Fee__c';
                        // Maintenance Due
                        objTempQP.put(strMaintDueFieldName,(Decimal)objQuoteProduct.get(strMaintDueFieldName));
                        // EOS
                        objTempQP.put(strEOSFieldName,(Decimal)objQuoteProduct.get(strEOSFieldName));
                        // Shelving Fees
                        objTempQP.put(strShelvingFieldName,(Decimal)objQuoteProduct.get(strShelvingFieldName));
                    }
                    
                    objInvoiceGroup.objInvoiceGroupQP = objTempQP;
                    map_InvoiceNumToInvoiceGroup.put(LicInvoiceUpperCase,objInvoiceGroup);
                    list_InvoiceGroups.add(objInvoiceGroup);
                    if(objQuote.Hide_Periods__c)
                        objTempQP.Total_Maintenance_Due__c = objQuoteProduct.Total_Maintenance_Due__c;
                    
                }
            }
        }
    }
    // Added by RAO
    void populateInvoiceELA(){
        if(map_InvoiceNumToInvoiceGroup != NULL){
            for(Invoice__c inv : [SELECT id, Name, ELA__c FROM Invoice__c WHERE Name IN :map_InvoiceNumToInvoiceGroup.keySet()]){
                String invName = inv.Name != NULL ? inv.Name.toUpperCase() : '-';
                if(map_InvoiceNumToInvoiceGroup.get(invName) != NULL)
                    map_InvoiceNumToInvoiceGroup.get(invName).invoiceELA = inv.ELA__c;
            }
        }
    }
}