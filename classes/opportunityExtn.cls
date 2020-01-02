public class opportunityExtn {
    private final Opportunity opp;
    public String uname{get;set;}
    
    public List<OpportunityLineItem> opplines { get; set; }
    public string SelectedOppLineId { get; set; }
    public Boolean isRenewalOppy {get;set;} 
    public opportunityExtn (ApexPages.StandardController stdController) {
        this.opp= (Opportunity )stdController.getRecord();
        Opportunity tempOpp = [select RecordType.DeveloperName from opportunity where id=:opp.Id];
        isRenewalOppy = false;
        if(tempOpp.RecordType.DeveloperName.equals('Genesys_Renewal')){
            isRenewalOppy = true;
        }
    }
    
    public PageReference Change_PB() {
        uname = UserInfo.getName();
        PriceBook2 pb = [select Id,Name from pricebook2 where Name = 'Sales PriceBook'];
        Opportunity opp = [select Pricebook2Id,CurrencyIsoCode from opportunity where id=:opp.Id];
        System.Debug('opportunityExtn.Change_PB: PriceBook pb ' + pb);
        System.Debug('opportunityExtn.Change_PB: opp ' + opp);
        if(opp.Pricebook2Id == pb.Id) return null;
        if(getQuotecheck() == 'none') {
            return null;
        }
        
        
        List<OpportunityLineItem> oldLineItems = [Select id,
                                                  UnitPrice,
                                                  TotalPrice,
                                                  Quantity,
                                                  Product_Name_Formula__c,
                                                  PricebookEntry.Product2Id,
                                                  PricebookEntryId,OpportunityId,
                                                  ServiceDate//, ProductCode 
                                                  from OpportunityLineItem where opportunityId = :opp.Id ];           
        System.Debug('opportunityExtn.Change_PB: oldLineItems ' + oldLineItems);
        Map<Id,Id> PBEntry = new Map<Id,Id>();
        Set<id> prod = new Set<Id>();
        List<OpportunityLineItem> newLineItems  = new List<OpportunityLineItem>(); 
        //adds products to set
        for(OpportunityLineItem oli: oldLineItems){
            prod.add(oli.PricebookEntry.Product2Id);
        }
        System.Debug('opportunityExtn.Change_PB: Set Product Ids [prod] ' + prod);
        //finding pricebook entry
        for(PricebookEntry PBEntry0bj:[ Select id,product2id,Pricebook2.Name from pricebookentry where pricebook2id =: pb.Id and product2id in:prod and CurrencyIsoCode=:opp.CurrencyIsoCode ]){
			System.Debug('opportunityExtn.Change_PB: Mapping PBEntry ' + PBEntry0bj);
            PBEntry.put(PBEntry0bj.product2id,PBEntry0bj.Id);
        }
        //Creating new product records based on sales pricebook
        for(OpportunityLineItem obj:oldLineItems){
            if(obj.PricebookEntry.Product2Id != null){
                OpportunityLineItem newrec = new OpportunityLineItem();
                newrec.OpportunityId = obj.OpportunityId;
                newrec.PricebookEntryId = PBEntry.get(obj.PricebookEntry.Product2Id);
                newrec.Quantity = obj.Quantity;
                newrec.UnitPrice = obj.UnitPrice;
                newrec.ServiceDate = obj.ServiceDate; 
                newLineItems.add(newrec);
            }
        } 
        System.Debug('opportunityExtn.Change_PB: After Creation newLineItems ' + newLineItems);
        delete oldLineItems;
		System.Debug('opportunityExtn.Change_PB: Made it past delete oldLineItems');
        opportunity newopp = new opportunity(id=opp.Id);        
        newopp.Pricebook2Id=pb.Id;
        update newopp ; 
		System.Debug('opportunityExtn.Change_PB: Made it past update newopp');

        insert newLineItems;
		System.Debug('opportunityExtn.Change_PB: Made it past insert newLineItems');
        return null;
    }
    
    
    
    public String getQuotecheck() {
        List<BigMachines__Quote__c> quoteList = [select Name from BigMachines__Quote__c where BigMachines__Opportunity__c=:opp.Id Limit 1];
        List<zqu__Quote__c> zuoraQuoteList = [SELECT id FROM zqu__Quote__c WHERE zqu__Opportunity__c =: opp.id LIMIT 1];
        
        if((quoteList.isEmpty() && zuoraQuoteList.isEmpty()) || (UserInfo.getProfileId() == Label.APAC_Profile_Id && 
                                                                 opp.Primary_Line_of_Business__c != null && opp.Primary_Line_of_Business__c.contains('Cloud')))
            return '';
        else
            return 'none';
    }
    
    public List<OpportunityLineItem> getOppline() {
        opplines = [select PricebookEntry.Product2.Id,PricebookEntry.Product2.Name,PricebookEntry.Product2.Description,PricebookEntry.Product2.SI_Version_Number__c,PricebookEntry.Product2.Pricing_Model__c,ListPrice,Discount,Total_Discount__c,Quantity__c,Id,Quantity,UnitPrice,TotalPrice,
                    PricebookEntry.Product2.Tier_Pricing_Decimal_Precision__c from OpportunityLineItem where opportunityid=:opp.Id];
        
        if(opplines.isEmpty())
            return null;
        else
            return opplines;
    }
    
    public void DeleteLineItem() {
        
        if (SelectedOppLineId == null) {
            return;
        }
        
        OpportunityLineItem deleteRecord = null;
        
        for(OpportunityLineItem o : opplines)
            if (o.Id == SelectedOppLineId) {
                deleteRecord = o;
                break;
            }
        
        if (deleteRecord != null) {
            delete deleteRecord;
            return;
        }
    }
    
}