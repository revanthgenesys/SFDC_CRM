public class CloudInvoiceComponentControllerTemp
{   
    public Id idInvoice {get; set;}
    public Decimal decTotalPrice {get; private set;}
    public Decimal decTotalTaxPrice {get; private set;}
    public String strFooterText {get; private set;}
    public Boolean blnIsExcel {get; set;}
    public Boolean blnDisplayTax {get; set;}
    public Boolean blnHasPVOrPVRProds {get; set;}
    public Account_Order_Address__c objBillingAddress {get; private set;}
    public Invoice__c objInvoice {get; private set;}
    public Order__c objOrder {get; private set;}
    //Added by Vijay - Aug 9th - 2017 - start
    public Boolean blnHasTaxAmountOnInvoice {get; set;}
    public String strTaxHeaderLabel {get; set;} // Added Aug 10th - vijay - Tax Header label changes based on Subsidiary. Example:  Sales Tax, VAT Tax, VAT/Sales Tax
    //Added by Vijay - Aug 9th - 2017 - end
    
    public List<Order_Line_Item__c> list_TaxOLIs {get; private set;}
    public Map<String, List<Order_Line_Item__c>> map_OLIs { get; private set; }
    public Map<String, Decimal> map_OLISubTotals { get; private set; }
    
    public String baseURL {get; set;}
    
    public Genesys_Entity__c objGenesysEntityInternal;
    
    public CloudInvoiceComponentControllerTemp() 
    {    
    }
    
    
    // Added by Vijay  - Aug 23rd 2017 -Start 
    // Fetch the Base URL of the current envi. FULL,UAT, PROD etc.
    public void getBaseURL(){
    	String baseURL =  System.URL.getSalesforceBaseUrl()+'/';
    }
    // Added by Vijay  - Aug 23rd 2017 - End
    
    public Genesys_Entity__c getObjGenesysEntity()
    {
        init();
        getBaseURL();
        return objGenesysEntityInternal;
    }
    
    void init()
    {
        decTotalPrice = 0;
        decTotalTaxPrice = 0;
        blnIsExcel = false;
        blnHasPVOrPVRProds = false;
        blnHasTaxAmountOnInvoice = false;
        list_TaxOLIs = new List<Order_Line_Item__c>();
        map_OLIs = new Map<String, List<Order_Line_Item__c>>();
        map_OLISubTotals = new Map<String, Decimal>();
        objBillingAddress = new Account_Order_Address__c();
        objInvoice = new Invoice__c();
        objGenesysEntityInternal = new Genesys_Entity__c();
        
        objInvoice = [SELECT Id, Order__c, Show_Tax_Info__c FROM Invoice__c WHERE Id = :idInvoice LIMIT 1];
        
        if(objInvoice.Order__c != null)
        {            
            objOrder = [SELECT Id,Month__c,Year__c,Invoice_Number__c,Invoice_Date__c,Order_Number__c,PO_Number__c,Order_Date__c,
                               CurrencyISOCode,Payment_Terms__c,Offering_Type__c,Sold_To_Name__c,Sold_To_Name__r.Name,
                               Sold_To_Name__r.Country__r.PureCloud_Selling_Entity_CB__c, Sold_To_Name__r.SAP_Account_Code__c,  // Changed Sold_To_Name__r.Country__r.PureCloud_Selling_Entity__c to Sold_To_Name__r.Country__r.PureCloud_Selling_Entity_CB__c  - Change made by Vijay - Selling entity is seperated for CloudBilling. Added new field for CB. 
                               Sold_To_Name__r.Country__r.Name, End_User_Name__c,End_User_Name__r.Name,End_User_Name__r.SAP_Account_Code__c,
                               Memo__c,Subsidaries__r.Billing_Invoice_Footer__c,Maintenance_Start__c,Maintenance_End__c,
                               Due_Date__c,Tax_Amount__c,Customer_Tax_Id__c,Zero_Tax_Wording__c,
                        //Added by Vijay - Aug 10th 2017 - Start
                        	   Subsidaries__c, Subsidaries__r.Name
                        //Added by Vijay - Aug 10th 2017 - End
                        FROM Order__c 
                        WHERE Id = :objInvoice.Order__c LIMIT 1];            
            
            // Getting default Invoice footer from Subsidiary record            
            strFooterText = objOrder.Subsidaries__r.Billing_Invoice_Footer__c;       
        
            List<Account_Order_Address__c> list_BillingAddress = [SELECT Address__c, Address2__c, City__c,State__c, Country__c,Zip_Code__c,
                                                                         Attention_To__c 
                                                                  FROM Account_Order_Address__c 
                                                                  WHERE Address_Type__c = 'Bill To'
                                                                  AND Order__c = :objOrder.Id LIMIT 1];
            if(!list_BillingAddress.isEmpty())
                objBillingAddress = list_BillingAddress[0]; 
                List<Genesys_Entity__c> list_Entities = [SELECT Selling_Entity__c,Remit_To__c FROM Genesys_Entity__c 
                        WHERE CurrencyISOCode = :objOrder.CurrencyISOCode
                          AND Name = :objOrder.Sold_To_Name__r.Country__r.PureCloud_Selling_Entity_CB__c LIMIT 1]; // Changed Sold_To_Name__r.Country__r.PureCloud_Selling_Entity__c to Sold_To_Name__r.Country__r.PureCloud_Selling_Entity_CB__c  - Change made by Vijay - Selling entity is seperated for CloudBilling. Added new field for CB. 
                
                if(!list_Entities.isEmpty()){
                    objGenesysEntityInternal = list_Entities[0];
            }
            
            for(Order_Line_Item__c objOLI : [SELECT Id, Name, Product__c, Product__r.APN_Number__c, Product__r.Type__c,Current_Qty__c,Ext_List__c , 
                                                    BigMachines_Quantity__c, Memo__c, Net_Unit_Price__c, Total_Price__c, Flavor__c, Sales_Price__c 
                                             FROM Order_Line_Item__c
                                             WHERE Order__c = :objOrder.Id
                                             ORDER BY Line_Number__c, Name, Memo__c]) {
                
                if(objOLI.Product__r.Type__c != 'Tax') {
                    if(map_OLIs.containsKey(objOLI.Memo__c)) {
                        map_OLIs.get(objOLI.Memo__c).add(objOLI);
                        map_OLISubTotals.put(objOLI.Memo__c, map_OLISubTotals.get(objOLI.Memo__c) + objOLI.Total_Price__c);
                    }
                    else {
                        map_OLIs.put(objOLI.Memo__c, new List<Order_Line_Item__c> { objOLI });
                        map_OLISubTotals.put(objOLI.Memo__c, objOLI.Total_Price__c);
                    }
                }
                else {
                    list_TaxOLIs.add(objOLI);
                    decTotalTaxPrice += objOLI.Total_Price__c;
                    blnDisplayTax = true;
                }
                decTotalPrice += objOLI.Total_Price__c;
                
                if(!String.isBlank(objOLI.Product__r.APN_Number__c) && !blnHasPVOrPVRProds) {
                     if((objOLI.Product__r.APN_Number__c).substring(0, 2) == 'PV' || (objOLI.Product__r.APN_Number__c).substring(0, 3) == 'PVR') {
                         blnHasPVOrPVRProds = true;
                     }    
                }
            }
            
            // Added By Vijay - PROD Tax amount Fix - Aug 9th 2017 - Start
            if(objOrder.Tax_Amount__c != NULL && objOrder.Tax_Amount__c > 0){
                blnHasTaxAmountOnInvoice = true;
                System.debug('Total Amount Before : '+decTotalPrice);
                decTotalPrice += objOrder.Tax_Amount__c;
                System.debug('Total Amount After : '+decTotalPrice);
                
            }
            // Added By Vijay - PROD Tax amount Fix - Aug 9th 2017 - End
            // Added By Vijay - PROD Tax amount Fix - Aug 10th 2017 - Start
            Set<String> set_SalesTaxSubsidiary = getSetOfSubsidiariesByLabel(Label.Cloud_Billing_Invoice_Sales_Tax_Category_Subsidiaries); 
            
            Set<String> set_VATTaxSubsidiary = getSetOfSubsidiariesByLabel(Label.Cloud_Billing_Invoice_VAT_Tax_Category_Subsidiaries); 
            
            Set<String> set_TaxSubsidiary = getSetOfSubsidiariesByLabel(Label.Cloud_Billing_Invoice_Tax_Category_Subsidiaries);
            
            if(objOrder.Subsidaries__c != NULL && String.isNotBlank(objOrder.Subsidaries__r.Name) 
               && set_SalesTaxSubsidiary.contains(objOrder.Subsidaries__r.Name)){
                strTaxHeaderLabel = 'Sales Tax';
            }
            else if(objOrder.Subsidaries__c != NULL && String.isNotBlank(objOrder.Subsidaries__r.Name) 
                    && set_VATTaxSubsidiary.contains(objOrder.Subsidaries__r.Name))
            {
                strTaxHeaderLabel = 'VAT Tax';
            } else if(objOrder.Subsidaries__c != NULL && String.isNotBlank(objOrder.Subsidaries__r.Name) 
                    && set_TaxSubsidiary.contains(objOrder.Subsidaries__r.Name)){
                strTaxHeaderLabel = 'Tax';
            }
            else{
                strTaxHeaderLabel = 'VAT/Sales Tax';
            }
            // Added By Vijay - PROD Tax amount Fix - Aug 10th 2017 - End
        }
    }
    
    public static set<String> getSetOfSubsidiariesByLabel(String strLabel){
        Set<String> set_Subsidiary = new Set<String>();
        String strTax = strLabel;
        if(strTax.contains(',')){
            set_Subsidiary.addAll(strTax.split(','));
        }else{
            set_Subsidiary.add(strTax);
        }
        return set_Subsidiary;
    }
}