global class UpdateOrderPSChargesBatch implements Database.Batchable<sobject>
{

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String Query = 'select Id, Order_PS_Charge__c, Order_PS_Charge__r.Total_Hours__c, Charge_Type__c, Minutes__c, Hours__c,'+
                        'product_Name__c, Rate__c from Order_PS_Charges__c where Order_PS_Charge__c!=null and Charge_Type__c=\'T\' and ( Minutes__c >0 OR Hours__c >0)'+
                        'Order by Order_PS_Charge__c';

        if(Test.isRunningTest())
        {
            Query += ' Limit 1';
        }

        return Database.getQueryLocator(Query);
    }

     
    global void execute(Database.BatchableContext BC,  List<Order_PS_Charges__c> orderPsCharges){
        
            if (!orderPsCharges.isEmpty()){

                Map<String, Double> TotalHourMap = new Map<String, Double>();

                for(Order_PS_Charges__c Ops:orderPsCharges){
                     if(TotalHourMap.get(Ops.Order_PS_Charge__c)==null) TotalHourMap.put(Ops.Order_PS_Charge__c, 0);
                }

                Map<String, Double> NoOfHours = new Map<String, Double>();
                Map<String, Double> NoOfMin = new Map<String, Double>();

               for(Order_PS_Charges__c OrP: orderPsCharges){
                     if(OrP.Hours__c>0){
                         if(NoOfHours.get(OrP.Order_PS_Charge__c)!=null)                       
                           NoOfHours.put(OrP.Order_PS_Charge__c, NoOfHours.get(OrP.Order_PS_Charge__c)+OrP.Hours__c);    
                         else 
                           NoOfHours.put(OrP.Order_PS_Charge__c, OrP.Hours__c);   
                       }
                       if(OrP.Minutes__c>0){
                         if(NoOfMin.get(OrP.Order_PS_Charge__c)!=null)                       
                           NoOfMin.put(OrP.Order_PS_Charge__c, NoOfMin.get(OrP.Order_PS_Charge__c)+OrP.Minutes__c);    
                         else 
                           NoOfMin.put(OrP.Order_PS_Charge__c, OrP.Minutes__c);   
                      } 
               }

                for(String key :TotalHourMap.keySet()){
                    double TotalHours = 0;  if(NoOfHours.get(key)!=null)  TotalHours = NoOfHours.get(key);
                    double TotalMin   = 0;  if(NoOfMin.get(key)!=null & NoOfMin.get(key)>0)    TotalMin   = NoOfMin.get(key)/60; 
                    TotalHourMap.put(key,TotalHours+TotalMin);
                }

                List<Order__c> UpdateOrder = new List<Order__c>();
       
               for(Order__c od:[select Id, Total_Hours__c from Order__c where Id in:TotalHourMap.keySet()]){
                   od.Total_Hours__c = TotalHourMap.get(od.Id);
                   UpdateOrder.add(od);
               }

                 if(UpdateOrder.size()>0) update UpdateOrder;
            }
    }

    global void finish(Database.BatchableContext BC) {
      
        
    }
    
}