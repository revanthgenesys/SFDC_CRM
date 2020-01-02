public class QuoteProductWrapper
{
    public BigMachines__Quote_Product__c record {get; set;}
    public Boolean selected {get; set;}
    public string strPlayOffer {get; set;}
    /*
public Decimal decListPriceOriginal {get; set;}

public Decimal decListPrice {get; set;}
public Decimal decExtListPrice {get; set;}
public Decimal decNetUnitPrice {get; set;}
public Decimal decExtNetPricePrice {get; set;}
*/
    public QuoteProductWrapper()
    {
        selected = false;
        strPlayOffer = '';
        /*
decListPriceOriginal = 0.0;

decListPrice = 0.0;
decExtListPrice = 0.0;
decNetUnitPrice = 0.0;
decExtNetPricePrice = 0.0;
*/
    }
    
    public QuoteProductWrapper(BigMachines__Quote_Product__c objQP) {
        this();
        record = objQP;
        /*
decListPrice = objQP.List_Price__c;
decExtListPrice = objQP.Ext_List__c;
decNetUnitPrice = objQP.Net_Unit_Price__c;
decExtNetPricePrice = objQP.Ext_Net_Price__c;

decListPriceOriginal = decListPrice;
*/
    }
}