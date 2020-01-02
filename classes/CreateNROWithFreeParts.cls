/************************************************************************************
Purpose :  Create NRO with free parts.
Written By :  Naresh Kumar	03/22/2018
Test Classes : CreateNROWithFreePartsTest 

Change History 
03/11/2019 - Change of future method to Queueable apex by Yuvaraj Palani

*************************************************************************************/
public class CreateNROWithFreeParts implements Queueable {

    Id OrderId;
    public CreateNROWithFreeParts(Id OrderId){

        this.OrderId=OrderId;
    }
    public void execute(QueueableContext context) {
         List<PureConnect_Dev_Parts__c> listOfFreeParts = [SELECT Purchased_Part__c, Free_Part__c
                     FROM PureConnect_Dev_Parts__c WHERE Purchased_Part__c IN 
                     (SELECT Product__c FROM Order_Line_Item__c WHERE Order__c =: orderId)];
        //Return if there is no free parts
        if(listOfFreeParts.isEmpty())
            return;
        Order__c objOrder = [SELECT id, Name, Opportunity__c, End_User_Name__c, Sold_To_Name__c, Quote__c,
                            Maintenance_Start__c, Maintenance_End__c  FROM Order__c WHERE id =: orderId];
        //Creates NRO Order        
	   	Order__c objNewNROOrder = new Order__c ();
	  	objNewNROOrder.Name = 'NRO - ' + objOrder.Name;
        objNewNROOrder.Opportunity__c = objOrder.Opportunity__c;
        objNewNROOrder.Quote__c = objOrder.Quote__c;
	    objNewNROOrder.RecordTypeId = Global_Setting__c.getInstance('NRO RT').ID__c;
	    objNewNROOrder.NRO_Type__c = 'Entitlement Adjustment';
        objNewNROOrder.End_User_Name__c = objOrder.End_User_Name__c;
	    objNewNROOrder.Sold_To_Name__c = objOrder.Sold_To_Name__c;	    
	    objNewNROOrder.Maintenance_Start__c = objOrder.Maintenance_Start__c;
	    objNewNROOrder.Maintenance_End__c = objOrder.Maintenance_End__c;
	    objNewNROOrder.Status__c = 'In Progress';
	    objNewNROOrder.Priority__c = '3-Medium';
	    objNewNROOrder.Ship_software_via__c = 'No Shipment Required';
	    objNewNROOrder.Order_Fulfillment_Email_Receipt__c = 'genesyslicense@genesys.com';	    
        insert objNewNROOrder;
		
        //Creats a map to hold mapping of purchases vs free parts	    
        Map<Id, List<Id>> mapOfPurchasedPartsVsFreeParts = new Map<Id, List<Id>>();
        
        //Looping over list of free parts
        for(PureConnect_Dev_Parts__c eachPart : listOfFreeParts){
            List<Id> listOfFreePartsTemp;
            if(mapOfPurchasedPartsVsFreeParts.get(eachPart.Purchased_Part__c) == null){
                listOfFreePartsTemp = new List<Id>();
                listOfFreePartsTemp.add(eachPart.Free_Part__c);
                mapOfPurchasedPartsVsFreeParts.put(eachPart.Purchased_Part__c, listOfFreePartsTemp);
            }    
            else{
                listOfFreePartsTemp = mapOfPurchasedPartsVsFreeParts.get(eachPart.Purchased_Part__c);
                listOfFreePartsTemp.add(eachPart.Free_Part__c);
                mapOfPurchasedPartsVsFreeParts.put(eachPart.Purchased_Part__c, listOfFreePartsTemp);
            }
        }
        //Creates NRO Order Line Items
	    List<Order_Line_Item__c> listOfOrderLinesToBeCreated = new List<Order_Line_Item__c>();
        //List of order lines from main order
	    List<Order_Line_Item__c> listOfOrderLines = [SELECT Product__c, Quantity__c FROM Order_Line_Item__c WHERE Order__c =: objOrder.id];
        
        Map<Id, Order_Line_Item__c> mapOfProductIdVSOrderLineItem = new Map<Id, Order_Line_Item__c>();
        //Looping over order lin items
        for(Order_Line_Item__c eachOLI : listOfOrderLines){
        	mapOfProductIdVSOrderLineItem.put(eachOLI.Product__c, eachOLI);    
        }
        
        Integer intCounter = 1;
        //Looping over free order lines
	   	for(Id eachPurhasedProductId : mapOfPurchasedPartsVsFreeParts.keyset()) {
            Order_Line_Item__c objPurchasedOLI = mapOfProductIdVSOrderLineItem.get(eachPurhasedProductId);
            //Getting list of free parts from map
       		List<Id> listOfFreePartsTemp = mapOfPurchasedPartsVsFreeParts.get(eachPurhasedProductId);
            //Looping over each of free part
            for(Id eachFreePartProductId : listOfFreePartsTemp){
	    	   Order_Line_Item__c objNewOLI = new Order_Line_Item__c ( Order__c = objNewNROOrder.id ); 
	    	   objNewOLI.RecordTypeId =  Global_Setting__c.getInstance('Order Line Default RT').ID__c;
	    	   objNewOLI.Name = String.valueOf(intCounter);
	    	   objNewOLI.Product__c = eachFreePartProductId;
	    	   objNewOLI.BigMachines_Quantity__c = objPurchasedOLI.Quantity__c;
	    	   objNewOLI.Quantity__c = objPurchasedOLI.Quantity__c;
	    	   listOfOrderLinesToBeCreated.add(objNewOLI);
               intCounter ++;
	    	}
        }	
	 	insert listOfOrderLinesToBeCreated;
	    //Approving order
	    objNewNROOrder.Status__c = 'Approved';
        update objNewNROOrder;
        //Completing order
        objNewNROOrder.Status__c = 'Completed';
        update objNewNROOrder;

    }

	/*@future
    public static void createNRO(Id orderId){
        //Getting list of free items
        List<PureConnect_Dev_Parts__c> listOfFreeParts = [SELECT Purchased_Part__c, Free_Part__c
                     FROM PureConnect_Dev_Parts__c WHERE Purchased_Part__c IN 
                     (SELECT Product__c FROM Order_Line_Item__c WHERE Order__c =: orderId)];
        //Return if there is no free parts
        if(listOfFreeParts.isEmpty())
            return;
        Order__c objOrder = [SELECT id, Name, Opportunity__c, End_User_Name__c, Sold_To_Name__c, Quote__c,
                            Maintenance_Start__c, Maintenance_End__c  FROM Order__c WHERE id =: orderId];
        //Creates NRO Order        
	   	Order__c objNewNROOrder = new Order__c ();
	  	objNewNROOrder.Name = 'NRO - ' + objOrder.Name;
        objNewNROOrder.Opportunity__c = objOrder.Opportunity__c;
        objNewNROOrder.Quote__c = objOrder.Quote__c;
	    objNewNROOrder.RecordTypeId = Global_Setting__c.getInstance('NRO RT').ID__c;
	    objNewNROOrder.NRO_Type__c = 'Entitlement Adjustment';
        objNewNROOrder.End_User_Name__c = objOrder.End_User_Name__c;
	    objNewNROOrder.Sold_To_Name__c = objOrder.Sold_To_Name__c;	    
	    objNewNROOrder.Maintenance_Start__c = objOrder.Maintenance_Start__c;
	    objNewNROOrder.Maintenance_End__c = objOrder.Maintenance_End__c;
	    objNewNROOrder.Status__c = 'In Progress';
	    objNewNROOrder.Priority__c = '3-Medium';
	    objNewNROOrder.Ship_software_via__c = 'No Shipment Required';
	    objNewNROOrder.Order_Fulfillment_Email_Receipt__c = 'genesyslicense@genesys.com';	    
        insert objNewNROOrder;
		
        //Creats a map to hold mapping of purchases vs free parts	    
        Map<Id, List<Id>> mapOfPurchasedPartsVsFreeParts = new Map<Id, List<Id>>();
        
        //Looping over list of free parts
        for(PureConnect_Dev_Parts__c eachPart : listOfFreeParts){
            List<Id> listOfFreePartsTemp;
            if(mapOfPurchasedPartsVsFreeParts.get(eachPart.Purchased_Part__c) == null){
                listOfFreePartsTemp = new List<Id>();
                listOfFreePartsTemp.add(eachPart.Free_Part__c);
                mapOfPurchasedPartsVsFreeParts.put(eachPart.Purchased_Part__c, listOfFreePartsTemp);
            }    
            else{
                listOfFreePartsTemp = mapOfPurchasedPartsVsFreeParts.get(eachPart.Purchased_Part__c);
                listOfFreePartsTemp.add(eachPart.Free_Part__c);
                mapOfPurchasedPartsVsFreeParts.put(eachPart.Purchased_Part__c, listOfFreePartsTemp);
            }
        }
        //Creates NRO Order Line Items
	    List<Order_Line_Item__c> listOfOrderLinesToBeCreated = new List<Order_Line_Item__c>();
        //List of order lines from main order
	    List<Order_Line_Item__c> listOfOrderLines = [SELECT Product__c, Quantity__c FROM Order_Line_Item__c WHERE Order__c =: objOrder.id];
        
        Map<Id, Order_Line_Item__c> mapOfProductIdVSOrderLineItem = new Map<Id, Order_Line_Item__c>();
        //Looping over order lin items
        for(Order_Line_Item__c eachOLI : listOfOrderLines){
        	mapOfProductIdVSOrderLineItem.put(eachOLI.Product__c, eachOLI);    
        }
        
        Integer intCounter = 1;
        //Looping over free order lines
	   	for(Id eachPurhasedProductId : mapOfPurchasedPartsVsFreeParts.keyset()) {
            Order_Line_Item__c objPurchasedOLI = mapOfProductIdVSOrderLineItem.get(eachPurhasedProductId);
            //Getting list of free parts from map
       		List<Id> listOfFreePartsTemp = mapOfPurchasedPartsVsFreeParts.get(eachPurhasedProductId);
            //Looping over each of free part
            for(Id eachFreePartProductId : listOfFreePartsTemp){
	    	   Order_Line_Item__c objNewOLI = new Order_Line_Item__c ( Order__c = objNewNROOrder.id ); 
	    	   objNewOLI.RecordTypeId =  Global_Setting__c.getInstance('Order Line Default RT').ID__c;
	    	   objNewOLI.Name = String.valueOf(intCounter);
	    	   objNewOLI.Product__c = eachFreePartProductId;
	    	   objNewOLI.BigMachines_Quantity__c = objPurchasedOLI.Quantity__c;
	    	   objNewOLI.Quantity__c = objPurchasedOLI.Quantity__c;
	    	   listOfOrderLinesToBeCreated.add(objNewOLI);
               intCounter ++;
	    	}
        }	
	 	insert listOfOrderLinesToBeCreated;
	    //Approving order
	    objNewNROOrder.Status__c = 'Approved';
        update objNewNROOrder;
        //Completing order
        objNewNROOrder.Status__c = 'Completed';
        update objNewNROOrder;
    }*/
}