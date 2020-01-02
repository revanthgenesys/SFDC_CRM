public without sharing class OrderSummaryOfPSChargesExt 
{
  String orderId {get;set;}
  public List<OrderSummary> OrderPlansCharges {get;set;}
  public Boolean noRecordsFound {get; set;}
  
  public OrderSummaryOfPSChargesExt(ApexPages.StandardController sc){
     orderId = sc.getId();
     getTotal();
  }
  
  public void getTotal()
  {
    Map<String, Double> productMap = new Map<String, Double>();
      
    for(Order_PS_Charges__c indvOrPS :[select Id, Order_PS_Charge__c, Charge_Type__c, CurrencyIsoCode, Minutes__c, Hours__c, 
                                  product_Name__c, Rate__c from Order_PS_Charges__c 
                                  where Order_PS_Charge__c!=null and Charge_Type__c='T' 
                                  and Order_PS_Charge__c =:orderId order by product_Name__c asc])
    {
         Double TotalMin = 0.0;
         TotalMin = indvOrPS.Hours__c*60;
         TotalMin = TotalMin+ indvOrPS.Minutes__c;
         
         String ProductKey = indvOrPS.product_Name__c+'_'+String.ValueOf(indvOrPS.Rate__c);
         if(productMap.get(ProductKey)==null)
             productMap.put(ProductKey,TotalMin);
         else
             productMap.put(ProductKey,productMap.get(ProductKey)+TotalMin);                  
    }    
       
       if(productMap.size()>0)
       {
           noRecordsFound = false;
           OrderPlansCharges = new List<OrderSummary>();
           System.debug('>>>>>>'+productMap);
           for(String oschargesElement:productMap.keyset())
           {
              System.debug('>>>>>>'+oschargesElement.split('_')[1]);
              double rate      = Double.Valueof(oschargesElement.split('_')[1]);
              double Quantity  = productMap.get(oschargesElement)/60;
              String MaterialDesc = oschargesElement.split('_')[0];
              double TotalAmount = rate * Quantity; 
              System.debug('rate :' +rate +',Quantity : ' +Quantity +',MaterialDesc : ' +MaterialDesc +',Total : ' +TotalAmount);
              OrderSummary os = new OrderSummary(MaterialDesc,rate,Quantity,rate*Quantity);
              OrderPlansCharges.add(os);
           }
       } else {
           noRecordsFound = true;
       }  
  }
  
  
  public class OrderSummary {
      
      public string materialDescription{get; set;}
      public double rate {get; set;}
      public double totalQuantity {get; set;}
      public double totalPrice {get; set;}
      
      public OrderSummary(String materialDescription, double rate, double totalQuantity, double totalPrice){
              this.materialDescription = materialDescription;
              this.rate = rate; 
              this.totalQuantity = totalQuantity;
              this.totalPrice = totalPrice;
      }
  }
  
}