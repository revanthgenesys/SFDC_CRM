public without sharing class PartnerPortalOpportyViewController {
        
    public ID id {get; private set;}
    public String name {get; set;}
    public String forecastStatus {get; set;}
    public String winloss {get; set;}
    public String stage {get; set;}
    public String account {get; set;}
    public Datetime createdate {get; set;}
    public Datetime expdate {get; set;}
    public Decimal amount {get; set;}
    public List<oppProduct> prodLines {get; set;}
    public String curr {get; set;}
        
        public PartnerPortalOpportyViewController()  {
           String oppId = ApexPages.currentPage().getParameters().get('Id');
           String acctId = ApexPages.currentPage().getParameters().get('acc');
                
            if ( oppId == null || acctId == null ) {
                  errMessage();
                  return;
            }    
            ///as an additional visibility protection will verify that the opp is linked to the correct account                 
            List<User> usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() AND Contact.AccountId = :acctId];           
            if ( usr.isEmpty() ) {
               errMessage();
               return;
            } 
            List<Opportunity> opp = [SELECT Id, Name, ForecastStatus__c, Win_Loss_Status__c, StageName, Account.Name, CreatedDate,
                                             Expiration_Date__c, Amount, CurrencyIsoCode 
                                 FROM Opportunity 
                                 WHERE Id = :oppId
                                  AND Partner_Opportunity_Registration__c IN 
                                       (SELECT Id FROM partner_portal_prospect__c WHERE Account__c =: acctId)];
                                       
	        if ( opp.isEmpty() )
	           return;
	        
	        name = opp[0].Name;
	        forecastStatus = opp[0].ForecastStatus__c;
	        winloss = opp[0].Win_Loss_Status__c;
	        stage = opp[0].StageName;
	        account = opp[0].Account.Name;
	        createdate = opp[0].CreatedDate;
	        expdate = opp[0].Expiration_Date__c;
	        amount = opp[0].Amount;
	        curr = opp[0].CurrencyIsoCode;
	        
	        prodLines = new List<oppProduct>();   
	        List<OpportunityLineItem> prods = [SELECT PricebookEntry.Product2.Name, Name, TotalPrice, Quantity
	                                            FROM OpportunityLineItem 
	                                           WHERE opportunityId = :opp[0].Id]; 
	                                       
	        for ( OpportunityLineItem ln : prods )  {
	                prodLines.add( new oppProduct(ln) );
	        }
        }
        
        public class oppProduct {
            public String prname { get; set; }
	        public Integer qty { get; set; }
	        public Decimal pramount { get; set; }
	        
	        public oppProduct (OpportunityLineItem lnItem) {
	             this.prname = lnItem.PricebookEntry.Product2.Name;
	             this.qty = (Integer)lnItem.Quantity;
	             this.pramount = lnItem.TotalPrice;
	        }        
        }
        
        public PageReference errMessage() {
        	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'No Data Found.');
            ApexPages.addMessage(msg);
            return null;
        }
        
}