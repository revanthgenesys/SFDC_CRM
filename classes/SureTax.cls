public class SureTax {

    public SureTax()
    {
    }
    
	// Response from SureTax
    public class ItemTax
    {
        public String CustomerNumber;
        public String InvoiceNumber;
        public String LineNumber;
        public String LocationCode;
        public String StateCode;
        public SureTax.Tax[] TaxList;
    }

    public class Tax 
    {
        public String CityName;
        public String CountyName;
        public Decimal FeeRate;
        //public String JurisdictionCode;
        public String Juriscode;
        public Decimal PercentTaxable;
        public String Revenue;
        public String RevenueBase;
        public String TaxAmount;
        //public String TaxAuthId;
        public String TaxAuthorityID;
        //public String TaxAuthName;
        public String TaxAuthorityName;
        public String TaxOnTax;
        public Decimal TaxRate;
        public String TaxTypeCode;
        public String TaxTypeDesc;
    }

    public class Item 
    {
        //public Decimal AuxRevenue;
        public SureTax.Address Address;
        public String AuxRevenueType;
        public String BillToNumber;
        //public Boolean CommonCarrier;
        //public String Country;
        public String CustomerNumber; // Used for tax aggregation by customer
        //public String DestCountryCode;
        //public String FreightOnBoard;
        public String Geocode;
        public String InvoiceNumber; // Used for tax aggregation by invoice.
        public String LineNumber; // Used to identify an item within the request. If no value, numbered sequentially.
        //public Boolean MailOrder;
        //public String OrderApprovalPlus4;
        //public String OrderApprovalZipcode;
        //public String OrderPlacementPlus4;
        //public String OrderPlacementZipcode;
        public String OrigNumber;
        //public String OriginCountryCode;
        public SureTax.Address P2PAddress;
        public String P2PPlus4;
        public String P2PZipcode;
        public String Parameter1;
        public String Parameter2;
        //public String PostalCode; // Required for Situs Rule 05
        public String Plus4; // Always send Plus4, default to 0000 if none
        public String RegulatoryCode; // Required. Provider type, i.e. '03' is VoIP, '70' is Retail
        public Decimal Revenue; // Required.
        public String SalesTypeCode; // Required. R - Residential, B - Business, I - Industrial, L - Lifeline
        //public Integer Seconds;
        //public Boolean ShipFromPOB;
        //public String ShipFromPlus4;
        //public String ShipFromZipcode;
        //public String State;
        public String[] TaxExemptionCodeList; // Required. Tax exemptions ot be applied to the item
        public String TaxIncludedCode; // Required. 0 - No tax included in Revenue, 1 - Tax included in Revenue
        public String TaxSitusOverrideCode;
        public String TaxSitusRule; // Required. Usually 05 for Zip+4
        public String TermNumber;
        public String TransDate; // Required. MM/DD/YYYY or MM-DD-YYYY
        public String TransTypeCode;
        //public String UDF;
        public String UnitType; // Required. Default is 00
        public Integer Units; // Required.
        //public String Zipcode; // Required for Situs Rule 05
    }
    public class Address
    {
        public Address(String PostalCode, String Plus4) {
            this.PostalCode = PostalCode;
            this.Plus4 = Plus4;
        }
        public String PostalCode;
        public String Plus4;
        public final String VerifyAddress = '0';
    }
/*
    public class P2PAddress
    {
        public P2PAddress(String PostalCode, String Plus4) {
            this.PostalCode = PostalCode;
            this.Plus4 = Plus4;
        }
        public String PostalCode;
        public String Plus4;
        public final String VerifyAddress = '0';
    }
*/
    public class ItemMessage 
    {
        public String LineNumber;
        public String ResponseCode;
        public String Message;
    }

    public class Request 
    {
        public String BusinessUnit; // Provides context in rating results
        public String ClientNumber; // Required.
        public String ClientTracking; // Identifier for transactions, hardcoded to order id
        public String CmplDataMonth;
		public String CmplDataYear;
        public String DataMonth; // Required. Month to use for tax calculation purposes
        public String DataYear; // Required. Year to use for tax calculation purposes
        public String IndustryExemption;
        public SureTax.Item[] ItemList;
        public String ResponseGroup; // Required. '03' default
        public String ResponseType; // Required. Determines granularity of tax information. Use 'D#' where # is 1-9.
        public String ReturnFileCode; // Required. 'Q' for Testing, '0' for formal processing in SureTax. Always use 'Q' for testing and quoting.
        public String STAN; // Required. null default
        public Decimal TotalRevenue; // Required. Total revenue of the request (sum of order lines)
        public String ValidationKey; // Required for our purposes 
    }

    public class Response {
        public String Successful;
        public String ResponseCode;
        public String HeaderMessage;
        public SureTax.ItemMessage[] ItemMessages;
        public String ClientTracking;
        public String TotalTax;
        public Integer TransId;
        public String STAN;
        public SureTax.ItemTax[] GroupList;
        
        // Feb 20 2018 Change of URL
        public String MasterTransId;
    }
}