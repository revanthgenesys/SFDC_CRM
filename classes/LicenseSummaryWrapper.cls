public class LicenseSummaryWrapper{
        public String partNumber {get; set;}
        public Boolean isselected {get; set;}
        public String description {get; set;}
        public Decimal total {get; set;}
        public Decimal used {get; set;}
        public Decimal available {get; set;}
        public List<String> partKeys {get; set;}
        public Integer orderedQty {get;set;}
        public String productId;
        
        public LicenseSummaryWrapper(){}
        public LicenseSummaryWrapper(String partNumber, String description, Decimal total, Decimal used, List<String> partKeys){}
        public LicenseSummaryWrapper(String partNumber, String description, Decimal total, Decimal used, List<String> partKeys, String productId){
            this.partNumber = partNumber;
            this.description = description;
            this.total = total;
            this.used = used != NULL ? used : 0;
            this.available = this.total - this.used;
            this.partKeys = new List<String>(); 
            this.orderedQty = 0;
            this.isSelected = False;
            this.productId = productId;
            if(partKeys != NULL){
                this.partKeys = partKeys;
            }  else { system.debug('inside License:'+'This item is legally licensed however no license string appears to \'key\' the item in the product.');
                this.partKeys = new List<String>{'This item is legally licensed however no license string appears to \'key\' the item in the product.'};
            }
        }
 }