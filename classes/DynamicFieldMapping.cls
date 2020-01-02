//Naresh Kumar  04/16/2014
public without sharing class DynamicFieldMapping {
	
    public static Order__c getOrderFromQuote(BigMachines__Quote__c quote, Order__c newOrder, String recordName){        
        SObject targetSObject = newOrder;
        SObject sourceSObject = quote;
        targetSObject = DynamicFieldMappingHelper.getPopulatedSObjectRecord(sourceSObject, targetSObject, DynamicFieldMappingHelper.QUOTE_TO_ORDER, recordName);
        System.debug('NKC debug targetSObject ['+targetSObject+']');
        return (Order__c)targetSObject;        
    }
    public static Order_Line_Item__c getOrderLineItemFromQuoteLineItem(BigMachines__Quote_Product__c quoteLineItem, String recordName){        
        //quoteLineItem = (BigMachines__Quote_Product__c)Database.query(DynamicFieldMappingHelper.getQuery(quoteLineItem.id, referenceFields, 'BigMachines__Quote_Product__c'));
        Order_Line_Item__c newOrderLineItem = new Order_Line_Item__c();
        SObject targetSObject = newOrderLineItem;
        SObject sourceSObject = quoteLineItem;
        targetSObject = DynamicFieldMappingHelper.getPopulatedSObjectRecord(sourceSObject, targetSObject, DynamicFieldMappingHelper.QUOTE_LINEITEMS_TO_ORDER_LINE_ITEMS, recordName);
        System.debug('NKC debug targetSObject ['+targetSObject+']');
        return (Order_Line_Item__c)targetSObject;        
    }
    public static ServiceContract getServiceContractFromOrder(Order__c order, String recordName){        
        ServiceContract newSC = new ServiceContract();
        SObject targetSObject = newSC;
        SObject sourceSObject = order;
        targetSObject = DynamicFieldMappingHelper.getPopulatedSObjectRecord(sourceSObject, targetSObject, DynamicFieldMappingHelper.ORDER_TO_SERVICE_CONTRACT, recordName);
        System.debug('NKC debug targetSObject ['+targetSObject+']');
        return (ServiceContract)targetSObject;        
    }
    public static ContractLineItem getSCLineItemFromOrderLineItem(Order_Line_Item__c orderLineItem, String recordName){        
        ContractLineItem newCLI = new ContractLineItem();
        SObject targetSObject = newCLI;
        SObject sourceSObject = orderLineItem;
        targetSObject = DynamicFieldMappingHelper.getPopulatedSObjectRecord(sourceSObject, targetSObject, DynamicFieldMappingHelper.ORDER_LINEITEMS_TO_CONTRACT_LINEITEMS, recordName);
        System.debug('NKC debug targetSObject ['+targetSObject+']');
        return (ContractLineItem)targetSObject;        
    }
}