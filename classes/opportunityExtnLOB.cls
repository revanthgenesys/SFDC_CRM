public class opportunityExtnLOB {
private final Opportunity opp;
public String uname{get;set;}
public string lob{get;set;}
public Map<string,BigMachines__Quote__c> mapQuotes{get;set;}
public boolean quoteExists{get;set;}
public List<OpportunityLineItem> opplines { get; set; }
public string SelectedOppLineId { get; set; }
public Boolean isRenewalOppy {get;set;} 
public opportunityExtnLOB (ApexPages.StandardController stdController) {
    quoteExists = false;
    mapQuotes = new map<string,BigMachines__Quote__c>();
    opplines = new List<OpportunityLineItem>();
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
        if(opp.Pricebook2Id == pb.Id)
        return null;
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
        Map<Id,Id> PBEntry = new Map<Id,Id>();
        Set<id> prod = new Set<Id>();
        List<OpportunityLineItem> newLineItems  = new List<OpportunityLineItem>(); 
        //adds products to set
        for(OpportunityLineItem oli: oldLineItems){
            prod.add(oli.PricebookEntry.Product2Id);
        }
        //finding pricebook entry
        for(PricebookEntry PBEntry0bj:[ Select id,product2id,Pricebook2.Name from pricebookentry where pricebook2id =: pb.Id and product2id in:prod and CurrencyIsoCode=:opp.CurrencyIsoCode ]){
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
                
        delete oldLineItems;
        opportunity newopp = new opportunity(id=opp.Id);        
        newopp.Pricebook2Id=pb.Id;
        update newopp ; 
        insert newLineItems;
        return null;
}



public String getQuotecheck() {
    List<BigMachines__Quote__c> quoteList = [select Name from BigMachines__Quote__c where BigMachines__Opportunity__c=:opp.Id Limit 1];

    if(quoteList.isEmpty())
        return '';
    else
        return 'none';
}

public List<OpportunityLineItem> getOppline() {
    opplines = [select PricebookEntry.Product2.Id,PricebookEntry.Product2.Name,PricebookEntry.Product2.Description,PricebookEntry.Product2.SI_Version_Number__c,PricebookEntry.Product2.Pricing_Model__c,PricebookEntry.Product2.Product_Line__c,ListPrice,Discount,Total_Discount__c,Quantity__c,Id,Quantity,UnitPrice,TotalPrice from OpportunityLineItem where opportunityid=:opp.Id];

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

public void setLobvalue()
{
    system.debug('------------------lob-------------------'+lob);
        system.debug('------------------opp.Id-------------------'+opp.Id);


    for(BigMachines__Quote__c quo: [SELECT id,name,Quote_Business_Type__c,Period__c,Selected_Packages__c,Order_Payment_Terms__c,
    							Initial_Subscription_Term__c,Renewal_Subscription_Term__c,Minimum_Fees_Period__c,is_Business_Primary__c,Annual_Contract_Value__c,
                                                Upgrade_Type__c,Billing_Period__c,Cloud_Term_Commitment__c,Monthly_Commitment__c,
                                                Total_Discount_Genesys_and_Third_Party__c,Pricing_Model__c,Total_Contract_Value__c,Expiration_Date__c,
                                                Minutes_of_use_Per_Port_Per_Month__c,Cloud_Total__c,Additional_Discount_Cloud__c,
                                                Monthly_Contract_Value__c,Setup_Provisioning_Charges__c,BigMachines__Total_Amount__c,                                                
                                                        (SELECT id,Committed_Quantity__c,Overage_Charge__c,BigMachines__Product__c,BigMachines__Product__r.name,BigMachines__Description__c,

                                                        BigMachines__Product__r.SI_Version_Number__c,BigMachines__Quantity__c,Total_Discount__c,List_Price__c,Ext_List__c,

                                                        BigMachines__Product__r.Pricing_Model__c
                                                        FROM BigMachines__BigMachines_Quote_Products__r) FROM BigMachines__Quote__c
                                                        WHERE BigMachines__Opportunity__c=:opp.Id
                                                        AND is_Business_Primary__c=true AND Quote_Business_Type__c= :lob])
    {        
        mapQuotes.put(quo.Quote_Business_Type__c,quo);
    }  
    if(mapQuotes.size()>0)
    {
        quoteExists = true;
    }
    else
    {
        opplines = [select PricebookEntry.Product2.Id,PricebookEntry.Product2.Name,PricebookEntry.Product2.Description,
                        PricebookEntry.Product2.SI_Version_Number__c,PricebookEntry.Product2.Pricing_Model__c,
                        PricebookEntry.Product2.Product_Line__c,ListPrice,Discount,Total_Discount__c,Quantity__c,
                        Id,Quantity,UnitPrice,TotalPrice 
                        from OpportunityLineItem where opportunityid=:opp.Id and PricebookEntry.Product2.ProductLine__c = :lob];
    } 
}

}