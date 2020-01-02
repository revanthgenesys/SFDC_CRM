public class CloudAccountBillingComponentController
{
    public Id idAccountBilling {get; set;}
    public Boolean blnIsExcel {get; set;}
    public Order__c objOrder {get; private set;}
    public List<ProductDetail> list_ProductDetails {get; private set;}
    public Decimal decTotalInvoiceAmount {get; private set;}
    public String strDateRange {get; private set;}
    public String strCurrencyCode {get; private set;}
    public String strPaymentTerms {get; private set;}
    public String strFooterText {get; private set;}
    // Billing Address selected on related quote
    public Account_Order_Address__c objBillingAddress {get; private set;}
    public Account_Billing_Info__c objAccountBillingInfo {get; private set;}
    public List<Account_Billing_Info_Line__c> list_accountBillingInfoLine {get; private set;}
    
    public Genesys_Entity__c objGenesysEntityInternal;
    
    public String strMainTitle {get; private set;}
    
    public class ProductDetail
    {
        public String strProductName {get; set;}
        public Decimal decTotalQuantity {get; set;}
        public String strUOM {get; set;}
        public Decimal decTotalAmount {get; set;}
        public List<UsageDetail> list_UsageDetails {get; set;}
        public String strDateRange {get; private set;}
        public Decimal decTaxRate {get; private set;}
        
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
    }
    
    public CloudAccountBillingComponentController()
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
        // Put the period strDateRange in the header by default
        list_ProductDetails = new List<ProductDetail>();
        objGenesysEntityInternal = new Genesys_Entity__c();
        objOrder = new Order__c();
        
        List<Account_Billing_Info__c> list_AccountBillingInfo = [SELECT Order__c,
                                                                 Document_Type__c,
                                                                 Date__c,
                                                                 Name,
                                                                 Tax_Number__c,
                                                                 Payment_Terms__c,
                                                                 PO__c,
                                                                 Sales_Rep__c,
                                                                 Sold_To_NS_Bill_To__r.Name,
                                                                 Sold_To_NS_Bill_To__r.SAP_Account_Code__c,
                                                                 Sold_To_NS_Bill_To__r.Subsidary__r.Name,
                                                                 End_User__r.Name,
                                                                 End_User__r.SAP_Account_Code__c,
                                                                 End_User__r.Subsidary__r.Name,
                                                                 Account_Billing_Info_Line_Total__c,
                                                                 Memo_Text__c,
                                                                 (select Units__c,
                                                                  Item__c,
                                                                  Description__c,
                                                                  Memo__c,
                                                                  Start_Date__c,
                                                                  End_Date__c,
                                                                  Quantity__c,
                                                                  UOM__c,
                                                                  Rate__c,
                                                                  Amount__c
                                                                  from Account_Billing_Info_Lines__r)
                                                                 FROM Account_Billing_Info__c WHERE Id = :idAccountBilling];
        
        if(!list_AccountBillingInfo.isEmpty())
            objAccountBillingInfo = list_AccountBillingInfo[0];
        
        strMainTitle = objAccountBillingInfo.Document_Type__c;
        strMainTitle = strMainTitle.replace(' Memo', '');
        
        if(objAccountBillingInfo != null)
        {
            // Gathering a bit too much here due to code copying.
            objOrder = [SELECT Id,Quote__c, Month__c, Year__c,
                        Contract_Lookup__c,Contract_Lookup__r.Quote__c,Contract_Lookup__r.Account_Name_Formula__c,
                        Contract_Lookup__r.Genesys_Entity__c,Invoice_Number__c,Invoice_Date__c,Order_Number__c,PO_Number__c,Order_Date__c,
                        Contract_Lookup__r.Quote__r.CurrencyISOCode,Payment_Terms__c,
                        Contract_Lookup__r.Override_Invoice_Footer__c,Contract_Lookup__r.Invoice_Footer_Text__c,
                        Sold_To_Name__r.SAP_Account_Code__c,Subsidaries__r.Billing_Invoice_Footer__c,
                        Contract_Lookup__r.Quote__r.Name,Due_Date__c,Tax_Amount__c,Customer_Tax_Id__c,Zero_Tax_Wording__c,
                        Contract_Lookup__r.Quote__r.End_User_ID__r.Name, Contract_Lookup__r.Invoice_Type__c
                        FROM Order__c WHERE Id = :objAccountBillingInfo.Order__c];
            
            // If Service Period in the Order Line Items also calculate its String
            Integer intMonth = Integer.valueOf(objOrder.Month__c);
			Integer intYear = Integer.valueOf(objOrder.Year__c);
            strDateRange = Date.newInstance(intYear,intMonth,1).format() + ' - ' + Date.newInstance(intYear,intMonth,Date.daysInMonth(intYear,intMonth)).format();
            
            list_accountBillingInfoLine = new List<Account_Billing_Info_Line__c>();
            for (Account_Billing_Info_Line__c abil : objAccountBillingInfo.Account_Billing_Info_Lines__r) {
                list_accountBillingInfoLine.add(abil);
            }
            
            if(objOrder.Contract_Lookup__r.Quote__c != null)
            {
                List<Account_Order_Address__c> list_BillingAddress = [SELECT Address__c, Address2__c, City__c,State__c, Country__c,Zip_Code__c,
                                                                      Attention_To__c FROM Account_Order_Address__c WHERE Quote__c = :objOrder.Contract_Lookup__r.Quote__c LIMIT 1];
                
                if(!list_BillingAddress.isEmpty())
                    objBillingAddress = list_BillingAddress[0];
            }
            
            if(String.isNotBlank(objOrder.Contract_Lookup__r.Genesys_Entity__c) && objBillingAddress != null)
            {
                List<Genesys_Entity__c> list_Entities = [SELECT Selling_Entity__c,Remit_To__c FROM Genesys_Entity__c 
                                                         WHERE CurrencyISOCode = :objOrder.Contract_Lookup__r.Quote__r.CurrencyISOCode AND 
                                                         Name = :objOrder.Contract_Lookup__r.Genesys_Entity__c.substringBefore(';') LIMIT 1];
                
                if(!list_Entities.isEmpty())
                    objGenesysEntityInternal = list_Entities[0];
            }
            
            // Getting default Invoice footer from Subsidiary record
            strFooterText = objOrder.Subsidaries__r.Billing_Invoice_Footer__c;
            
        }
        if (objBillingAddress == null) {
            objBillingAddress = new Account_Order_Address__c();
        }
        
    }
}