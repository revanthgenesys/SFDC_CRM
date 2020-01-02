public class OrderDetailController {
 
    public List<Order__c>list_Orders {get; private set;}

    public String strBaseURL {get; private set;}

    public String strOppId {get; private set;}

    
    public OrderDetailController (ApexPages.StandardController stdCtrl){
      strOppId = stdCtrl.getId();
      list_Orders = new  List<Order__c>();
      GetOrders();
    }
       
//trevor dewitt 7.31 added Order_number__c to the query below 
    private void GetOrders()
    {
      list_Orders = [Select id,name,PO_Number__c,PO_Date__c,quote_number__c,Order_Number__c from Order__c where Opportunity__c =: strOppId ];
    }
}