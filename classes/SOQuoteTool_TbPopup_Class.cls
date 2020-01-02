public class SOQuoteTool_TbPopup_Class {
public String prodName {get;set;}
public String prdId {get;set;}
public Double discount {get;set;}
public SOQuoteTool_TbPopup_Class()
{
   prdId = ApexPages.currentPage().getParameters().get('id');
   String discStr = ApexPages.currentPage().getParameters().get('discount');
   if(discount != null)
   {
   discount = Double.Valueof(discStr);
   }else 
   {
   discount = 0;
   }
   Product2 prodObj = [Select id,Name from Product2 where id=:prdId ];
   
   prodName = prodObj.Name;
 }
 
  public List<Pricing_Table__c> getreturnTable()
  {
   Set<Id> pricingIds = new Set<Id>();
   List<Pricing_Table__c> pctableList  = new List<Pricing_Table__c>();
   for(Product_Discount_Lookup__c eachlookup : [Select id,Pricing_Table__c from Product_Discount_Lookup__c where product__c =:prdId])
   {
   pricingIds.add(eachlookup.Pricing_Table__c);
   }
   if(pricingIds.size() > 0)
   {
    pctableList = [Select Id,Name,Product_Type__c,Range_From__c,Range_To__c,List_Price__c,Unit_of_Measure__c,Tier__c from Pricing_Table__c where id in :pricingIds order by Tier__c]; 
   }
   return pctableList ;
 }
}