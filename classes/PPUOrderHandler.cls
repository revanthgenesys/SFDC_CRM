//Naresh Kumar  07/16/2014
public without sharing class PPUOrderHandler {
    
    public static void updateTotalOnOrder(List<Order_Line_Item__c> newList, Boolean isDelete){
        Set<Id> orderIds = new Set<Id>();
        for(Order_Line_Item__c eachOLI : newList)
            orderIds.add(eachOLI.Order__c);
        
        if(orderIds.isEmpty())
            return;
        Map<Id, Decimal> mapQuoteIdVsTotal = new Map<Id, Decimal>();        
        List<Order_Line_Item__c> orderLineItem = [SELECT Sales_Price__c,Total_Price__c,Order__c,Order__r.RecordType.Name
            FROM Order_Line_Item__c WHERE Order__c =: orderIds AND 
            (Order__r.RecordType.DeveloperName =: OrderUtil.PPU_ORDER OR Order__r.RecordType.Name = 'Cloud Monthly Billing Order')];
        
        for(Order_Line_Item__c eachOLI : orderLineItem)
        {
        	if(eachOLI.Sales_Price__c == null)
        		continue;
            if(eachOLI.Order__r.RecordType.Name == 'Cloud Monthly Billing Order' && eachOLI.Total_Price__c == null)
                continue;
            if(eachOLI.Order__r.RecordType.Name != 'Cloud Monthly Billing Order' && eachOLI.Sales_Price__c == null)
                continue;
            System.debug('NKC debug mapQuoteIdVsTotal ['+mapQuoteIdVsTotal+']');
            if(!mapQuoteIdVsTotal.containsKey(eachOLI.Order__c))
            {
                if(eachOLI.Order__r.RecordType.Name == 'Cloud Monthly Billing Order')
                    mapQuoteIdVsTotal.put(eachOLI.Order__c, eachOLI.Total_Price__c);
                else
                    mapQuoteIdVsTotal.put(eachOLI.Order__c, eachOLI.Sales_Price__c);
            }
            else
            {
                Decimal total = mapQuoteIdVsTotal.get(eachOLI.Order__c);
                
                if(eachOLI.Order__r.RecordType.Name == 'Cloud Monthly Billing Order')
                	total += eachOLI.Total_Price__c;
                else    
                	total += eachOLI.Sales_Price__c;
                
                mapQuoteIdVsTotal.put(eachOLI.Order__c, total);
                System.debug('NKC debug total ['+total+']');
            }
        }
        if(!mapQuoteIdVsTotal.isEmpty() || isDelete){
            List<Order__c> ordersToBeUpdated = new List<Order__c>();
            for(Id eachId : orderIds){
                Order__c orderToBeUpdated = new Order__c(id = eachId);
                if(mapQuoteIdVsTotal.get(eachId) == null)
                    orderToBeUpdated.Total_Order__c = 0;
                else
                    orderToBeUpdated.Total_Order__c = mapQuoteIdVsTotal.get(eachId);
                
                ordersToBeUpdated.add(orderToBeUpdated);
                if(!ordersToBeUpdated.isEmpty()){                    
                    update ordersToBeUpdated;
                }
            }
        }
    }
}