public class CloudInvoiceComponentController
{
    public Id idInvoice {get; set;}
    public Boolean blnIsExcel {get; set;}
    public Order__c objOrder {get; private set;}
    public List<ProductDetail> list_ProductDetails {get; private set;}
    public Decimal decTotalInvoiceAmount {get; private set;}
    public Boolean blnHasTax {get; private set;}
    public Boolean blnHasOrderLineTaxRate {get; private set;}
    public Integer intColspan {get; private set;}
    public Decimal decGrandTotal {get; private set;}
    public String strDateRange {get; private set;}
    public Boolean blnHasOrderLinePeriod {get; private set; }
    public String strCurrencyCode {get; private set;}
    public String strPaymentTerms {get; private set;}
    public String strFooterText {get; private set;}
    public String strCurrencyISOCode {get; private set;}
	// blnHasCountMessages Added by Vijay - June 9th 2017 
	public Boolean blnHasCountMessages {get; set;}
    public Invoice__c objInvoice {get; set;}
	// Tax fields - Added by Vijay - June 14th 2017
	public Decimal decTotalTaxAmount {get; set;}
    // Billing Address selected on related quote
    public Account_Order_Address__c objBillingAddress {get; private set;}
    
    public Genesys_Entity__c objGenesysEntityInternal;
    
    // list of Tax descriptions and amount
    public list<TaxDetail> list_TaxDetails {get; set;}
    
    public class TaxDetail {
        public String strDescription {get; set;}
        public Decimal decTaxAmount {get; set;}
        
        public TaxDetail(String strDesc , Decimal decAmount){
            strDescription = strDesc;
            decTaxAmount = decAmount;
        }
    }
    
    public class ProductDetail
    {
        //public String strProductNumber {get; set;}
        public String strProductName {get; set;}
        public Decimal decTotalQuantity {get; set;}
        public String strUOM {get; set;}
        public Decimal decTotalAmount {get; set;}
        public List<UsageDetail> list_UsageDetails {get; set;}
        public String strDateRange {get; private set;}
        public Decimal decTaxRate {get; private set;}
        //strAPNNumber Added By Vijay - June 5th 2017
        public String strAPNNumber {get; set;}
        public String strQuoteProdcut {get; set;}
        public Decimal decTotalMessages {get; set;}
        
        public ProductDetail()
        {
            decTotalAmount = 0;
            list_UsageDetails = new List<UsageDetail>();
        }
    }
    
    public class UsageDetail
    {
        public String strMemo {get; set;}
        public Decimal decQuantity {get; set;}
        public Decimal decRate {get; set;}
        public Decimal decAmount {get; set;}
        //decMessages Added By Vijay - June 6th 2017
        public Decimal decMessages {get; set;}
    }
    
    public CloudInvoiceComponentController()
    {
        blnIsExcel = false;
    }
    
    public Genesys_Entity__c getObjGenesysEntity()
    {
        init();
        return objGenesysEntityInternal;
    }
    
    void init()
    {
    	// Default Count Messages Cloumn hide. - Added By -Vijay 
    	blnHasCountMessages = false;
        // Currently the column size of the Order Line Item table minus 2 columns reserved for the Grand Total Section
        intColspan = 8;
        // Put the period strDateRange in the header by default
        blnHasOrderLinePeriod = false;
        decTotalInvoiceAmount = decGrandTotal = 0;
        blnHasTax = false;
        blnHasOrderLineTaxRate = false;
        list_ProductDetails = new List<ProductDetail>();
        objBillingAddress = new Account_Order_Address__c();
        objGenesysEntityInternal = new Genesys_Entity__c();
        objOrder = new Order__c();
        objInvoice = new Invoice__c();
        
        list_TaxDetails = new List<TaxDetail>();
        
        List<Invoice__c> list_Invoices = [SELECT Id,Order__c, Show_Tax_Info__c, Invoice_Number__c FROM Invoice__c WHERE Id = :idInvoice];
        
        if(!list_Invoices.isEmpty())
            objInvoice = list_Invoices[0];
        
        if(objInvoice.Order__c != null)
        {
            // iTracks 26055 add select Contract_Lookup__r.Account_Name_Override__c
            // iTracks 23650 Blanket Discount add sorting by Line_Number__c from Order_Line_Items__r
            objOrder = [SELECT Id,Month__c,Year__c,Contract_Lookup__c,Contract_Lookup__r.Quote__c,Contract_Lookup__r.Account_Name_Formula__c,
                        Contract_Lookup__r.Genesys_Entity__c,Invoice_Number__c,Invoice_Date__c,Order_Number__c,PO_Number__c,Order_Date__c,
                        Contract_Lookup__r.Quote__r.CurrencyISOCode,Payment_Terms__c,Offering_Type__c,
                        Contract_Lookup__r.Invoice_Type__c,
                        Contract_Lookup__r.Quote__r.End_User_ID__r.Name, Contract_Lookup__r.Quote__r.End_User_ID__r.SAP_Account_Code__c, 
                        Contract_Lookup__r.Sold_To_Name_Formula__c,Contract_Lookup__r.Account_Name_Override__c,
                        Contract_Lookup__r.Override_Invoice_Footer__c,Contract_Lookup__r.Invoice_Footer_Text__c,
                        Sold_To_Name__r.SAP_Account_Code__c, Contract_Lookup__r.Zuora_Quote__c, 
                        Contract_Lookup__r.Zuora_Quote__r.CurrencyISOCode, Contract_Lookup__r.Quote__r.Opp_Sold_To_Country__c,
                        Contract_Lookup__r.Pricing_Start_Date__c,
                        Memo__c,Subsidaries__r.Billing_Invoice_Footer__c,
                        Contract_Lookup__r.Quote__r.Name,Due_Date__c,Tax_Amount__c,Customer_Tax_Id__c,Zero_Tax_Wording__c,
                        (SELECT Name,Unit_of_Measure__c,BigMachines_Quantity__c,Memo__c,Net_Unit_Price__c,Total_Price__c,
                         Tier_Set_Period_In_Months__c, Tax_Rate__c, APN_Number__c, Quote_Product__c 
                            FROM Order_Line_Items__r ORDER BY Name, Memo__c)
                        FROM Order__c WHERE Id = :objInvoice.Order__c];

            if (objOrder.Contract_Lookup__r.Quote__r != null) {
                strCurrencyISOCode = objOrder.Contract_Lookup__r.Quote__r.CurrencyISOCode;
            } else {
                strCurrencyISOCode = objOrder.Contract_Lookup__r.Zuora_Quote__r.CurrencyISOCode;
            }

            // If any of the Order Line Items has a muilti-month period, move the period into the order line item
            for (Order_Line_Item__c oli : objOrder.Order_Line_Items__r) {
                if (oli.Tier_Set_Period_In_Months__c != null && oli.Tier_Set_Period_In_Months__c > 1) {
                    blnHasOrderLinePeriod = true;
                }
                if (oli.Tax_Rate__c != null) {
                    blnHasOrderLineTaxRate = true;
                }
            }
            if(objOrder.Tax_Amount__c != null && objOrder.Tax_Amount__c != 0)
                blnHasTax = true;
            
            // Getting default Invoice footer from Subsidiary record            
            strFooterText = objOrder.Subsidaries__r.Billing_Invoice_Footer__c;
            //Added By Ranjith on May 16, 2017 -- Starts 
            if(objOrder.Offering_Type__c == 'Premier Edition' || objOrder.Offering_Type__c == 'Self Service') {
                strFooterText = [SELECT Message__c FROM Flow_Message_User_Info__c WHERE Name = 'Invoice Footer - Premier' LIMIT 1].Message__c;
            }
            //Added By Ranjith on May 16, 2017 -- Ends
            if(objOrder.Contract_Lookup__c != null && String.isNotBlank(objOrder.Month__c) && String.isNotBlank(objOrder.Year__c))
            {
                Integer intMonth = Integer.valueOf(objOrder.Month__c);
                Integer intYear = Integer.valueOf(objOrder.Year__c);
                Date dtOrderDate = objOrder.Order_Date__c;
                if (objOrder.Contract_Lookup__r.Pricing_Start_Date__c.day() == 1) {
	                strDateRange = Date.newInstance(intYear,intMonth,1).format() + ' - ' + Date.newInstance(intYear,intMonth,Date.daysInMonth(intYear,intMonth)).format();
                } else {
                    strDateRange = dtOrderDate.addMonths(-1).addDays(1).format() + ' - ' + dtOrderDate.format();
                }
                // If Invoice footer is overriden on contract use the override text
                if(objOrder.Contract_Lookup__r.Override_Invoice_Footer__c)
                    strFooterText = objOrder.Contract_Lookup__r.Invoice_Footer_Text__c;
                
                if(objOrder.Contract_Lookup__r.Quote__c != null || objOrder.Contract_Lookup__r.Zuora_Quote__c != NULL)
                {
                    List<Account_Order_Address__c> list_BillingAddress = [SELECT Address__c, Address2__c, City__c,State__c, Country__c,Zip_Code__c,
                             Attention_To__c FROM Account_Order_Address__c WHERE (Quote__c = :objOrder.Contract_Lookup__r.Quote__c
                                                                          		OR Zuora_Quote__c = :objOrder.Contract_Lookup__r.Zuora_Quote__c)
                                                                          // Below Conditions Added by Vijay - 20th June 2017
                                                                          AND Address_Type__c = 'Bill To'
                                                                          AND GCR_Content_Document_Detail__c = :objOrder.Contract_Lookup__c
                                                                          LIMIT 1];
                    if(!list_BillingAddress.isEmpty())
                        objBillingAddress = list_BillingAddress[0];
                }
                
                if(String.isNotBlank(objOrder.Contract_Lookup__r.Genesys_Entity__c) && objBillingAddress != null)
                {
                    List<Genesys_Entity__c> list_Entities = [SELECT Selling_Entity__c,Remit_To__c FROM Genesys_Entity__c 
                            WHERE (CurrencyISOCode = :objOrder.Contract_Lookup__r.Quote__r.CurrencyISOCode OR 
                                   CurrencyISOCode = :objOrder.Contract_Lookup__r.Zuora_Quote__r.CurrencyISOCode)AND 
                                Name = :objOrder.Contract_Lookup__r.Genesys_Entity__c.substringBefore(';') LIMIT 1];
                    
                    if(!list_Entities.isEmpty()){
                        objGenesysEntityInternal = list_Entities[0];
                    }
                    /*else{
                        objGenesysEntityInternal = new Genesys_Entity__c();
                        objGenesysEntityInternal.Selling_Entity__c = [SELECT selling_entity__c FROM Country__c 
                                                	WHERE (CurrencyISOCode = :objOrder.Contract_Lookup__r.Quote__r.CurrencyISOCode 
                                                    AND Name = : objOrder.Contract_Lookup__r.Quote__r.Opp_Sold_To_Country__c) 
                                                    OR 
                                                    CurrencyISOCode = :objOrder.Contract_Lookup__r.Zuora_Quote__r.CurrencyISOCode][0].selling_entity__c;
                        
                    }*/
                        
                    
                }
                
                Map<String,List<Order_Line_Item__c>> map_TSNameToOLI = new Map<String,List<Order_Line_Item__c>>();
                for(Order_Line_Item__c objOLI : objOrder.Order_Line_Items__r)
                {
                    if(map_TSNameToOLI.containsKey(objOLI.Name))
                        map_TSNameToOLI.get(objOLI.Name).add(objOLI);
                    else
                        map_TSNameToOLI.put(objOLI.Name,new List<Order_Line_Item__c>{objOLI});
                }
                List<SureTax_Settings__c> list_SureTaxSettings = SureTax_Settings__c.getAll().values();
                Set<String> set_taxDescriptions = new Set<String>();
                for(SureTax_Settings__c objSureTax : list_SureTaxSettings){
                    set_taxDescriptions.add(objSureTax.Value__c);
                }
                System.debug('list_SureTaxSettings : '+list_SureTaxSettings);
                System.debug('set_taxDescriptions :'+set_taxDescriptions);
                
                for(String strTSName : map_TSNameToOLI.keySet())
                {
                    List<Order_Line_Item__c> list_OLI = map_TSNameToOLI.get(strTSName);
                    System.debug('list_OLI[0].Memo__c :'+list_OLI[0].Memo__c);
                    ProductDetail objProdDetail = new ProductDetail();
                    if(!list_OLI[0].Name.equalsIgnoreCase('Tax Group') )
                        list_ProductDetails.add(objProdDetail);
                    objProdDetail.strProductName = list_OLI[0].Name;
                    objProdDetail.strUOM = list_OLI[0].Unit_of_Measure__c;
                    objProdDetail.decTotalQuantity = objProdDetail.decTotalAmount = 0;
                    // APNNumber added by Vijay - June 5th
                    objProdDetail.strAPNNumber = list_OLI[0].APN_Number__c;
                    objProdDetail.strQuoteProdcut = list_OLI[0].Quote_Product__c;
                    System.debug('strQuoteProdcut = '+objProdDetail.strQuoteProdcut);
                    // If Service Period in the Order Line Items also calculate its String
                    Date startThisMonth = Date.newInstance(intYear,intMonth,1);
                    Decimal monthOffset;
                    if (list_OLI[0].Tier_Set_Period_In_Months__c != null) {
                        monthOffset = list_OLI[0].Tier_Set_Period_In_Months__c;
                    } else {
                        monthOffset = 1;
                    }
                    Date actualEndDate = Date.newInstance(intYear,intMonth,Date.daysInMonth(intYear,intMonth)).addMonths(monthOffset.intValue()-1);
                    objProdDetail.strDateRange = startThisMonth.format() + ' - ' + actualEndDate.format();
                    objProdDetail.decTaxRate = list_OLI[0].Tax_Rate__c;
                    
                    for(Order_Line_Item__c objOLI : list_OLI)
                    {
                        if(!set_taxDescriptions.contains(objOLI.Memo__c)){
                            UsageDetail objUsageDetail = new UsageDetail();
                            objProdDetail.list_UsageDetails.add(objUsageDetail);
                            objUsageDetail.strMemo = (objOLI.Memo__c == NULL) ? '' : objOLI.Memo__c;
                            
                            /*
                            if (objUsageDetail.strMemo == null) {
                            objUsageDetail.strMemo = '';
                            }
                            */
                            
                            // iTracks 23650 Blanket Discount add
                            /*
                            if(!objUsageDetail.strMemo.startsWith('Blanket Discount') &&
                               objUsageDetail.strMemo != 'Commitment Shortfall' && objUsageDetail.strMemo != 'Monthly Access Fee' && 
                               objUsageDetail.strMemo != 'Monthly Flat Fee' && objUsageDetail.strMemo != 'Variable Term Flat Fee' &&
                               objUsageDetail.strMemo != 'One Time Flat Fee')
                            */
							if (objOLI.BigMachines_Quantity__c > 1) 
                            {
                                objUsageDetail.decQuantity = objOLI.BigMachines_Quantity__c;
                                objProdDetail.decTotalQuantity += objUsageDetail.decQuantity;
                            }
                            
                            
                            objUsageDetail.decAmount = objOLI.Total_Price__c;
                            if (!objUsageDetail.strMemo.startsWith('Blanket Discount')) {
                                objUsageDetail.decRate = objOLI.Net_Unit_Price__c;
                            }
                            
                            objProdDetail.decTotalAmount += objUsageDetail.decAmount;
                        }
                        else{
                            list_TaxDetails.add(new TaxDetail(objOLI.Memo__c,objOLI.Total_Price__c));
                            System.debug('list_TaxDetails :'+list_TaxDetails );
                            //decTotalInvoiceAmount += objOLI.Total_Price__c;
                            blnHasTax = true;
                            objOrder.Tax_Amount__c = (objOrder.Tax_Amount__c != NULL) ? objOrder.Tax_Amount__c+objOLI.Total_Price__c : objOLI.Total_Price__c ;
                        }
                        
                    }
                    decTotalInvoiceAmount += objProdDetail.decTotalAmount;
                    
                }
                decGrandTotal = decTotalInvoiceAmount + (blnHasTax? objOrder.Tax_Amount__c : 0);
               
                
                // Added by Vijay - Start 
                // No. of Messages on the PDF page - Start
                List<Contract_Tier_Set_Month__c> list_ContractTierSetMonths = [SELECT id, Contract_Tier_Set__c, Contract_Tier_Set__r.Quote_Product__c,
                                                                               Sum_Count__c
                                                                               FROM Contract_Tier_Set_Month__c
                                                                               WHERE Contract_Tier_Set__r.Contract__c = :objOrder.Contract_Lookup__c
                                                                               AND Contract_Tier_Set__r.Quote_Product__c != NULL];
                
                Map<String,List<Decimal>> map_TierSetMonthByQuoteProduct = new Map<String,List<Decimal>>();
                for(Contract_Tier_Set_Month__c objTierSetMonth : list_ContractTierSetMonths){
                    System.debug('Contract_Tier_Set_Month__c objTierSetMonth -> Quote_Product__c = '+objTierSetMonth.Contract_Tier_Set__r.Quote_Product__c);
                    if(!map_TierSetMonthByQuoteProduct.containsKey(objTierSetMonth.Contract_Tier_Set__r.Quote_Product__c))
                        map_TierSetMonthByQuoteProduct.put(objTierSetMonth.Contract_Tier_Set__r.Quote_Product__c, new List<Decimal>());
                    map_TierSetMonthByQuoteProduct.get(objTierSetMonth.Contract_Tier_Set__r.Quote_Product__c).add(objTierSetMonth.Sum_Count__c);
                    System.debug(objTierSetMonth.Contract_Tier_Set__r.Quote_Product__c+' -> '+objTierSetMonth.Sum_Count__c);
                }

                for(ProductDetail objProductDetail : list_ProductDetails){
                    if(objProductDetail.strQuoteProdcut != NULL && objProductDetail.list_UsageDetails != NULL)
                    {
                        if(objProductDetail.decTotalMessages == NULL){
                            objProductDetail.decTotalMessages = 0;
                        }
                        integer intCount = 0;
                        for(UsageDetail objUsageDetail : objProductDetail.list_UsageDetails){
                            if(map_TierSetMonthByQuoteProduct.get(objProductDetail.strQuoteProdcut) != NULL 
                               && map_TierSetMonthByQuoteProduct.get(objProductDetail.strQuoteProdcut).size() > intCount){
                                objUsageDetail.decMessages = map_TierSetMonthByQuoteProduct.get(objProductDetail.strQuoteProdcut)[intCount];
                                objProductDetail.decTotalMessages += map_TierSetMonthByQuoteProduct.get(objProductDetail.strQuoteProdcut)[intCount];
                            }else{
                                objUsageDetail.decMessages = 0;
                            }
                            if(!blnHasCountMessages) blnHasCountMessages = (objUsageDetail.decMessages != 0 && objUsageDetail.decMessages != NULL);
                            intCount++;
                        }
                    }
                }
                // No. of Messages on the PDF page - End
                // Tax information - Start
                /*
                List<Contract_Tier_Set_Month__c> list_AllTierSetMonths = [SELECT id FROM Contract_Tier_Set_Month__c
                                                                          WHERE Contract_Tier_Set__r.Contract__c = :objOrder.Contract_Lookup__c];
                List<Id> list_ContractTierSetMonthIds = new List<Id>();
                for(Contract_Tier_Set_Month__c objTierSetMonth : list_AllTierSetMonths){
                	list_ContractTierSetMonthIds.add(objTierSetMonth.id);
                }
                List<Contract_Tier_Set_Month_Charges__c> list_ContractSetMonthCharges = [SELECT id, Amount__c, Contract_Tier_Set_Month__c, Description__c
                																		 FROM Contract_Tier_Set_Month_Charges__c
                																		 WHERE Contract_Tier_Set_Month__c IN :list_ContractTierSetMonthIds];
                decTotalTaxAmount = 0.0;
                for(Contract_Tier_Set_Month_Charges__c objTierSetMonthCharge : list_ContractSetMonthCharges){
                	decTotalTaxAmount += objTierSetMonthCharge.Amount__c;
                }
                */
               
                
                // Tax information - End 
                // Added by Vijay - End
            }
        }
        // If the period is displayed in the header, we don't display it its column
        if (!blnHasOrderLinePeriod) {
            intColspan--;
        }
        //If we are not showing ta
        if (!blnHasOrderLineTaxRate) {
            intColspan--;
        }
        // If Count Messages not exist or zeros for all, Don't Display Count Messages Cloumn - Vijay
        if (!blnHasCountMessages) {
            intColspan--;
        }

        if(objOrder.Contract_Lookup__r.Invoice_Type__c == NULL || 
           (!objOrder.Contract_Lookup__r.Invoice_Type__c.equalsIgnoreCase( 'Standard with Part Number'))){
            intColspan--; 
        } 
        
        // Line break for long words in Order memo. - Vijay - June 29th 2017
        if(String.isNotBlank(objOrder.Memo__c)){
        	String[] strLineBreakArray = objOrder.Memo__c.split('\\s');
        	String strTemp;
            String strOrderMemo = '';
            integer intLasti = 0;
            String[] list_TempArray ;
        	for(integer j = 0 ; j < strLineBreakArray.size() ; j++){
        		strTemp = '';
        		if(strLineBreakArray[j].length() > 48){
        			Integer[] intCharArray = strLineBreakArray[j].getChars();
        			for(integer i = 0 ; i < intCharArray.size() ; i++){
                        list_TempArray = strTemp.split(' ');
        				strTemp += String.fromCharArray( new List<integer>{intCharArray[i]}) 
                            		+ ((list_TempArray[list_TempArray.size()-1].length() == 48) ? ' ' : '');
                        strTemp += (strTemp.endsWith('<br>')) ? ' ': '';
                        System.debug('String Temp ='+strTemp);
        			}
                    strLineBreakArray[j] = strTemp;
        		}
                strOrderMemo += strLineBreakArray[j] + ' ';
        	}
            objOrder.Memo__c = strOrderMemo;
        }
    }
}