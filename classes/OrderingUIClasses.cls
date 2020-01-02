public class OrderingUIClasses {


    //------------------------------------------ Ordering UI Supporting Class definitions ---------------------------------------------
    public class ShippingLocation
    {
        public string id {get;set;}
        public integer LineNumber {get;set;}
        public string AddressId{get;set;}
        public mAddress Address {get;set;}
        public string ContactId {get;set;}
        public date NeedByDate {get;set;}
        public string ShippingInstructions {get;set;}
        public string ShippingMethod {get;set;}
    }

    public class LineItem
    {
        @testVisible
        private integer qty = 0;
        public boolean isOrderLine = false;
        public string Id {get;set;}
        public string PartNumber {get;set;}
        public string PartName {get;set;}
        public integer Quantity
        {
            get
            {
                return qty;
            }
            set {qty = value;}
        }
        public integer Unallocated {get;set;}
        public boolean IsShippable {get;set;}
        public double ListPrice {get;set;}
        public double MSRP {get;set;}
        public double SalesPrice {get;set;}
        public date OrderableStartDate {get;set;}
        public date OrderableEndDate {get;set;}
        public boolean IsMonthly {get;set;}
        public Id parentId {get;set;}
        public boolean IsOrderable
        {
            get {
            if ((this.OrderableStartDate != null) && (Date.today() < this.OrderableStartDate))
                {return false;}
                else if ((this.OrderableEndDate != null) && (Date.today() > this.OrderableEndDate))
                {return false;}
                else
                {return true;}
            }
        }

        //Used for PC Usage Line Items
        public string QuoteChargeName {get; set;}

        public List<LineItemAllocation> Allocation {get;set;}

    }

    public class LineItemAllocation
    {
        public integer Location {get;set;}
        public integer Quantity  {get;set;}
    }

    public class mAddress {
        public string id {get;set;}
        public string LegalName {get;set;}
        public string Name {get;set;}
        public string Street {get;set;}
        public string Street2 {get;set;}
        public string City {get;set;}
        public string State {get;set;}
        public string HtmlStreet
        {
            get {return convertCRtoBR(this.Street);}
        }
       public string PostalCode {get;set;}
        public boolean isActive {get;set;}
        public string Country {get;set;}
        public string AxId {get;set;}
        public override string toString()
       {
            string addr = DisplayAddressLine('', false);
            return addr;
        }

         public string BillingAddressDisplayNoName
        {
            get {
                string addr = DisplayAddressLine('billing', false);
                return addr;
            }
        }

        public string NoTypeNoName
        {
            get {
                string addr = DisplayAddressLine('', false);
                return addr;
            }
        }

        public string ShippingAddressDisplayNoName
        {
            get {
                string addr = DisplayAddressLine('shipping', false);
                return addr;
            }
        }


        public string ShippingAddressDisplay
        {
            get {
                string addr = DisplayAddressLine('shipping', false);
                return addr;
            }
        }

        public string BillingAddressDisplay
        {
            get {
                string addr = DisplayAddressLine('billing', false);
                return addr;
            }
        }

        public string DisplayAddressLine(string Type, boolean WithAddrName)
        {
            if (Type != 'billing' && Type != 'shipping' && Type != '')
                return '** Invalid Type **';
            string inName = Name != null ? Name : '';
            string inStreet = Street != null ? Street : '';
            string inStreet2 = Street2 != null ? Street2 : '';
            string inCity = City != null ? City : '';
            string inState = State != null ? State : '';
            string inPostal = PostalCode != null ? PostalCode : '';
            string contactName = '';
            if (Type == 'shipping')
            {
                contactName = ShippingContactName != null ? ShippingContactName : '';
            }
            else if (Type == 'billing')
            {
                contactName = BillingContactName != null ? BillingContactName : '';
            }
            else
            {
                contactName = '';
            }

            string addr = '';
            if (WithAddrName)
                addr = inName + ' - ';
            addr = addr + (inStreet + ' ' + inCity + ' ' + inState + ' ' + inPostal).Trim();

            if (ContactName.length() > 0)
            {
                addr = addr  + ' (' + contactName + ')';
            }

            return addr;
        }

        public string BillingContactId {get;set;}
        public Contact BillingContact {get;set;}
        public string BillingContactName {get;set;}
        public string BillingContactPhone {get;set;}
        public string BillingContactFax {get;set;}
        public string BillingContactEmail {get;set;}

        public string ShippingContactId {get;set;}
        public Contact ShippingContact {get;set;}
        public string ShippingContactName {get;set;}
        public string ShippingContactPhone {get;set;}
        public string ShippingContactFax {get;set;}
        public string ShippingContactEmail {get;set;}

        private String convertCRtoBR(String StringIn) {
            String result = '';

            if (!String.IsBlank(StringIn))
            {
                List<String> StringLines = StringIn.split('\n',0);

                for (String StringLine : StringLines)
                {
                    if ((result != '') && (StringLine != null)) {result += '<br />';}
                    if (StringLine != null) {result += StringLine;}
                }
            }
            return result;
        }
    }

}