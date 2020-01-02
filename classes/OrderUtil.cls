public without sharing class OrderUtil {
public final static string NON_REVENUE_ORDER = 'Non_Revenue_Orders';
public final static string PPU_ORDER = 'PPU_Order';
// field mapping from opp to order
public static void populateOppFieldsOnOrders( List<Order__c> newOrders ){
    Set<Id> oppIds = new Set<Id>();
    for(Order__c o : newOrders){
        oppIds.add(o.Opportunity__c);
    }
    Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([Select Id, BusinessPartner__c, CurrencyIsoCode, AccountId, System_Integrator__c, Support_Owner__c 
                                    from Opportunity where Id IN :oppIds]);
    for(Order__c o : newOrders){
        Opportunity opp = oppsMap.get(o.Opportunity__c);
        if(opp!= null){
            o.System_Integrator__c = opp.System_Integrator__c;
            o.Support_Owner__c = opp.Support_Owner__c;
            //o.Sold_To_Name__c = opp.BusinessPartner__c;
            //o.End_User_Name__c = opp.AccountId;
            o.CurrencyIsoCode = opp.CurrencyIsoCode;
        }
    }
}

// field mapping from quote to order
public static void populateQuoteFieldsOnOrders( List<Order__c> newOrders ){
    Set<Id> quoteIds = new Set<Id>();
    for(Order__c o : newOrders){
        quoteIds.add(o.Quote__c);
    }
    Map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>(
                                                            [Select Id, Previous_Maint_Rate__c, Current_Maint_Rate__c,
                                                                    Total_Genesys_Care__c,Total_Maintenance_Amount_Due__c,
                                                                    BigMachines__Opportunity__r.RecordType.DeveloperName,
                                                                    Maintenance_Start_Date__c, Maintenance_End_Date__c,
                                                                    Quarterly_Semi_Annual_Billing_Fee__c, Licensing_Reduction_Fee__c,
                                                                    Reinstatement_fee__c, Partner_to_Partner_Uplift__c, 
                                                                    Extended_End_of_Support__c, Partner_to_Direct__c,
                                                                    Comment__c, Decreased_Quote_Reason__c, Cancelled_Quote_Reason__c,
                                                                    Total_Discount__c, Sent_to_Customer__c, Genesys_Care_Rep_Name__c,
                                                                    Genesys_Care_Rep_Title__c, Genesys_Care_Rep_Phone__c, 
                                                                    Genesys_Care_Rep_Email__c, Genesys_Care_Rep_Cell__c,
                                                                    Bill_to_information__c,SG2_Region__c, Genesys_Care__c,
                                                                    Ship_To_Information__c, Big_Four__c, Big_Six__c, Sales_org__c,
                                                                    Sold_To_Company_Name__c
                                                             from BigMachines__Quote__c where ID IN :quoteIds]);
                                                           
    for(Order__c o : newOrders){
        BigMachines__Quote__c q = quotesMap.get(o.Quote__c);
        // field mapping from quote to Quote
        o.Previous_Maint_Rate__c = q.Previous_Maint_Rate__c;
        o.Current_Maint_Rate__c = q.Current_Maint_Rate__c;
        o.Quarterly_Semi_Annual_Billing_Fee__c = q.Quarterly_Semi_Annual_Billing_Fee__c;
        o.Licensing_Reduction_Fee__c = q.Licensing_Reduction_Fee__c;
        o.Reinstatement_fee__c = q.Reinstatement_fee__c;
        o.Partner_to_Partner_Uplift__c = q.Partner_to_Partner_Uplift__c;
        o.Extended_End_of_Support__c = q.Extended_End_of_Support__c;
        o.Partner_to_Direct__c = q.Partner_to_Direct__c;
        o.Comments__c = q.Comment__c;
        o.Decreased_Quote_Reason__c = q.Decreased_Quote_Reason__c;
        o.Cancelled_Quote_Reason__c = q.Cancelled_Quote_Reason__c;
        //o.Total_Discount__c = q.Total_Discount__c;
        o.Sent_to_Customer__c = q.Sent_to_Customer__c;
        o.Genesys_Care_Rep_Name__c = q.Genesys_Care_Rep_Name__c;
        o.Genesys_Care_Rep_Title__c = q.Genesys_Care_Rep_Title__c;
        o.Genesys_Care_Rep_Phone__c = q.Genesys_Care_Rep_Phone__c;
        o.Genesys_Care_Rep_Email__c = q.Genesys_Care_Rep_Email__c;
        o.Genesys_Care_Rep_Cell__c = q.Genesys_Care_Rep_Cell__c;
        o.Bill_to_information__c = q.Bill_to_information__c;
        o.Ship_To_Information__c = q.Ship_To_Information__c;
        o.Big_Four__c = q.Big_Four__c;
        o.Big_Six__c = q.Big_Six__c;
        o.Sales_Org__c = q.Sales_org__c;
        //o.Sold_To_Name__c = OrderUtil.getName(q.Sold_To_Company_Name__c).id;
        
        // populating maintenance fields based on opp record type
        if(q.BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
        {   
            o.Maintenance_Amount__c = q.Total_Genesys_Care__c;
        }
        else{
             o.Maintenance_Amount__c = q.Total_Maintenance_Amount_Due__c;
             o.Maintenance_End__c = q.Maintenance_End_Date__c;
             o.Maintenance_Start__c = q.Maintenance_Start_Date__c;
        }
    } 
}

public static Date adjustDatetoStartofMonth(Date d) {
    
 if(d.day() < 15)
              return(d.toStartOfMonth());
            else
              return d.addMonths(1).toStartOfMonth();   
    
}

// fieldMapping from QuoteLine to OrderLine
public static void populateQuoteLineFields( Map<Id, Order__c> ordersMap, List<Order_Line_Item__c> olis){
    Map<String, BigMachines__Quote_Product__c> orderAndproductIdToQp = new Map<String, BigMachines__Quote_Product__c>();
    Set<Id> quoteIds = new Set<Id>();
    for(Order__c o : ordersMap.values()){
            quoteIds.add(o.Quote__c);
    }
    for(BigMachines__Quote_Product__c qp :[Select Id, Product__c,Maintenance_Due__c, Fees_Applied__c, Comment__c, Genesys_Care_Rate__c,
            Increase__c, Extended_End_of_Support__c, Contract_Line_Update_Status__c, Original_Qty__c, Current_Qty__c, 
                                           BigMachines__Quote__r.Order__c from BigMachines__Quote_Product__c where BigMachines__Quote__c IN :quoteIds]){
        orderAndproductIdToQp.put(qp.Product__c +','+ qp.BigMachines__Quote__r.Order__c,qp);
    }
    
    if(!orderAndproductIdToQp.isEmpty()){
        for( Order_Line_Item__c o : olis ){
            BigMachines__Quote_Product__c qp = orderAndproductIdToQp.get(o.Product__c +','+ o.Order__c);
            if(qp != null) {
                o.Maintenance_Due__c = qp.Maintenance_Due__c;
                o.Fees_Applied__c = qp.Fees_Applied__c;
                o.Comment__c = qp.Comment__c;
                o.Genesys_Care_Rate__c = qp.Genesys_Care_Rate__c;
                o.Increase__c = qp.Increase__c;
                o.Revised_Net_License_Value__c = qp.Increase__c;
                o.Extended_End_of_Support__c = qp.Extended_End_of_Support__c;
                
            // if(q.BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME) { 
                //o.Sold_To_Name__c = qp.Sold_To_Name__c;
             //}
                
                o.Contract_Line_Update_Status__c = qp.Contract_Line_Update_Status__c;
                o.Original_Qty__c = qp.Original_Qty__c;
                o.Current_Qty__c = qp.Current_Qty__c;                    
            }
        }
    }
}


// field mapping of order dates from License Opportunities
public static Map<Id, Order__c> populateOrderDates( List<Order_Line_Item__c> olis ){        
    Set<Id> orderIds = new Set<Id>();
    Map<Id, Order__c> ordersMap;
    for( Order_Line_Item__c o : olis) {
        orderIds.add(o.Order__c);
    }
    if(!orderIds.isEmpty()){
        ordersMap = new Map<Id, Order__c>([Select Id,  Opportunity__r.RecordType.DeveloperName ,Maintenance_Start__c, Maintenance_End__c,RecordTypeId,
                                                  Quote__c
                                           from Order__c
                                           where Id IN :orderIds AND Offering_Type__c != 'PureConnect Subscription' AND Offering_Type__c != 'PureEngage Subscription']);
        if(!ordersMap.isEmpty()){
            for(Order_Line_Item__c o : olis){
                if(ordersMap.get(o.Order__c) != null){
                if(ordersMap.get(o.Order__c).Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && ordersMap.get(o.Order__c).RecordTypeId != (Id)Label.Cloud_Monthly_Order_RecordTypeId){
                    o.Maintenance_Start_Date__c = ordersMap.get(o.Order__c).Maintenance_Start__c;
                   o.Maintenance_End_Date__c = ordersMap.get(o.Order__c).Maintenance_End__c;
                }
                }
            }
        }
    }
    return ordersMap;
}

public static Account getName(String name) {
Account acc  = null;
Account acct = [Select id from account where name=:name limit 1];
return acct;
}
public static Boolean isNonRevenueOrder(List<Order__c> newList){        
    if(TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK == null && newList.Size() > 0){
        List<Order__c> currentOrder = [SELECT RecordType.DeveloperName FROM Order__c WHERE id =: newList[0].id];
        if(currentOrder.size() > 0)
            TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK = currentOrder[0];
    }
    if(TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK != null && (TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK.RecordType.DeveloperName == OrderUtil.NON_REVENUE_ORDER || TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK.RecordType.DeveloperName == OrderUtil.PPU_ORDER))
        return true;
    return false;
}

public static void sendAcknowledgeEmail(Map<Id, Order__c> newMap, Map<Id, Order__c> oldMap){
    List<Order_Acknowledge_Email__c> listOrderAcknowledgeEmails = new List<Order_Acknowledge_Email__c>();
    //Rony Joseph - Replacing querying with fields from trigger map to bypass 101 SOQL issue - September 9th 2019
    /*List<Order__c> listOfOrders = [SELECT id, Order_Category__c, Sold_To_Name__c, End_User_Name__c, Region__c, Status__c, Quote__r.Amendment_For__c,Original_Parent_Order1__c, 
                                    RecordType.Name FROM Order__c WHERE id IN : newMap.keyset()];*/
    for(Order__c eachOrder : newMap.values()){
        if(
        // eachOrder.Order_Category__c == 'PureEngage - Renewal' || eachOrder.Order_Category__c == 'PureConnect - Renewal' 
        // eachOrder.Order_Category__c == 'PureConnect Subscription' || eachOrder.Order_Category__c == 'PureEngage Subscription'
           eachOrder.Order_Category__c == 'PureConnect On Premise - Rental' || eachOrder.Order_Category__c == 'PureEngage On Premise - Rental'
          || eachOrder.Order_Category__c == null
          || (eachOrder.Region__c != 'North America' && eachOrder.Region__c != 'EMEA' && eachOrder.Region__c != 'APAC' && eachOrder.Region__c != 'LATAM')
         // || (eachOrder.Region__c != 'North America' && eachOrder.Region__c != 'APAC' && eachOrder.Region__c != 'LATAM')
          //|| eachOrder.Quote__r.Amendment_For__c != null
          || eachOrder.Order_RecordType_Name__c == 'PS Orders'|| eachOrder.Order_RecordType_Name__c == 'Cloud Monthly Billing Order'
          || eachOrder.Original_Parent_Order1__c != null
          || (eachOrder.Sold_To_Name__c != eachOrder.End_User_Name__c))
            continue;
        

          //below condition added by Vinay 06/23/19
        if(eachOrder.Region__c == 'EMEA') {

            if((oldMap == null && (eachOrder.Status__c == 'Approved')
                    || (eachOrder.Status__c == 'Approved' && oldMap.get(eachOrder.id).Status__c != 'Approved'))){
                    String orderId = eachOrder.id;
                    Integer noOfRecords =  Database.countQuery('SELECT count() FROM Order_Acknowledge_Email__c WHERE Order__c =: orderId');
                    if(noOfRecords == 0)
                        listOrderAcknowledgeEmails.add(new Order_Acknowledge_Email__c(Order__c = eachOrder.id)); 
                }
     
     
            }
     
                else { 
     
                         if((oldMap == null && (eachOrder.Status__c == 'Order Submitted' || eachOrder.Status__c == 'Submitted')
                                        || (eachOrder.Status__c == 'Order Submitted' && oldMap.get(eachOrder.id).Status__c != 'Order Submitted')
                                        || (eachOrder.Status__c == 'Submitted' && oldMap.get(eachOrder.id).Status__c != 'Submitted'))){
                                        String orderId = eachOrder.id;
                                        Integer noOfRecords =  Database.countQuery('SELECT count() FROM Order_Acknowledge_Email__c WHERE Order__c =: orderId');
                                        if(noOfRecords == 0)
                                            listOrderAcknowledgeEmails.add(new Order_Acknowledge_Email__c(Order__c = eachOrder.id)); 
                                    }
        
            }
                                        
        
    }
    if(!listOrderAcknowledgeEmails.isEmpty()){
        insert listOrderAcknowledgeEmails;
    }
}


public static void populatesFieldsOnOrderLineItems(Map<Id, Order__c> newMap, Map<Id, Order__c> oldMap){
    Set<Id> orderIds = new Set<Id>();
    Map<Id, List<Date>> mapOfOrderIdAndListOfDates = new Map<Id, List<Date>>();
    
    for(Order__c eachOrder : newMap.values()){
        if(eachOrder.Operating_System__c != oldMap.get(eachOrder.id).Operating_System__c || eachOrder.Language__c != oldMap.get(eachOrder.id).Language__c
            || eachOrder.Numb_of_Maint_Months__c != oldMap.get(eachOrder.id).Numb_of_Maint_Months__c || eachOrder.Maintenance_Start__c != oldMap.get(eachOrder.id).Maintenance_Start__c
            || eachOrder.Maintenance_End__c != oldMap.get(eachOrder.id).Maintenance_End__c ){
            orderIds.add(eachOrder.id);                 
        }
    }
   
   if(orderIds.size() > 0) { 
    List<Order_Line_Item__c> olis = [SELECT Order__c, Operating_System__c,Language_lk__c, Maintenance_No_of_Months__c, Maintenance_Start_Date__c, Maintenance_End_Date__c,
        Order__r.Opportunity__r.RecordType.DeveloperName, Year__c, Order__r.Offering_Type__c,Order__r.RecordTypeId, Order__r.Quote__r.Ramp_Period__c,
        Order__r.Maintenance_Start__c,Order__r.Maintenance_End__c,Order__r.Quote__r.Amendment_For__r.Ramp_End_Date__c,Order__r.Quote__r.Amendment_For__c
        FROM Order_Line_Item__c WHERE Order__c In: orderIds];
            
    for(Order_Line_Item__c eachOLI : olis){
 
        eachOLI.Operating_System__c = newMap.get(eachOLI.Order__c).Operating_System__c;         
        eachOLI.Language_lk__c  = newMap.get(eachOLI.Order__c).Language__c;
        if(eachOLI.Order__r.Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && eachOLI.Order__r.RecordTypeId != (Id)Label.Cloud_Monthly_Order_RecordTypeId ){ 
            eachOLI.Maintenance_No_of_Months__c = newMap.get(eachOLI.Order__c).Numb_of_Maint_Months__c;      
            eachOLI.Maintenance_Start_Date__c = newMap.get(eachOLI.Order__c).Maintenance_Start__c;
            eachOLI.Maintenance_End_Date__c = newMap.get(eachOLI.Order__c).Maintenance_End__c;
            
            //Naresh Kumar  02/12/2018  PureConnect & PureEngage Subscription 
            if(eachOLI.Maintenance_No_of_Months__c != null && eachOLI.Year__c != null 
               && (eachOLI.Order__r.Offering_Type__c == 'PureEngage Subscription' || eachOLI.Order__r.Offering_Type__c == 'PureConnect Subscription')){
                /* MS - 12/10/19 - replaced
                List<Date> listOfStartAndEndDates = calculateSubscriptionOrderLineDates(eachOLI.Maintenance_Start_Date__c, 
                        eachOLI.Maintenance_End_Date__c, Integer.valueOf(eachOLI.Maintenance_No_of_Months__c), Integer.valueOf(eachOLI.Year__c));
                */
                List<Date> listOfStartAndEndDates = (eachOLI.Order__r.Quote__r.Amendment_For__c == null) ?
                QuoteUtil.calculateOnPremSubscripOrderLineDates(eachOLI.Order__r.Maintenance_Start__c, eachOLI.Order__r.Maintenance_End__c, eachOLI.Order__r.Quote__r.Ramp_Period__c, Integer.valueOf(eachOLI.Year__c)) :
                calculateSubscriptionOrderLineDates(eachOLI.Maintenance_Start_Date__c, eachOLI.Maintenance_End_Date__c, Integer.valueOf(eachOLI.Maintenance_No_of_Months__c), Integer.valueOf(eachOLI.Year__c));

                eachOLI.Maintenance_Start_Date__c = listOfStartAndEndDates[0];
                eachOLI.Maintenance_End_Date__c = listOfStartAndEndDates[1];
            }
        }
        
    }
    if(!olis.isEmpty())
        update olis;
  }      
}

   // Order Line Item Name Calculation
public static void calculateLineItemName( List<Order_Line_Item__c> lineItemsList) {
    Set<Id> orderIdSet =  new Set<Id> ();
    for(Order_Line_Item__c lineItem: lineItemsList){
        orderIdSet.add(lineItem.Order__c);          
    }
    Order_Line_Item__c [] orderidList = [select id, order__c from Order_Line_Item__c where order__c IN :orderIdSet ] ;
    Map<id, integer> orderMap = new Map<id, integer>();
    integer init=1;
    for(Order_Line_Item__c lnItem : orderidList){
        if(!orderMap.containsKey(lnItem.order__c)){
            orderMap.put(lnItem.order__c, init);
        } else {
            orderMap.put(lnItem.order__c, orderMap.get(lnItem.order__c)+1 );
        }
    }
    for(Order_Line_Item__c lineItem: lineItemsList){
        if(orderMap.containsKey(lineItem.order__c)){
            orderMap.put(lineItem.order__c, orderMap.get(lineItem.order__c)+1 );
            lineItem.Name = String.valueof(orderMap.get(lineItem.order__c));                
        }else{
            orderMap.put(lineItem.order__c, init );
            lineItem.Name = String.valueof(orderMap.get(lineItem.order__c));
        }       
    }
} 

//Update Order Status to Pending when a line item needs PM Approval

public static void updateOrderStatus(id ordId,id orderlineitemid){
    Order__c  orderUpdate;
    List<Product2> prodsWithAppRequired;
    if(ordId != null){
        orderUpdate = [select id, status__c, RecordType.DeveloperName from Order__c where id =: ordId];
    }
    System.debug('>>>>>>>>>>>>>>>>>Entered UpdateOrderStatus outside Valid Block:::' + orderUpdate.status__c);
    if(orderUpdate.status__c != 'Pending PM Approval' && orderUpdate.status__c == null && orderUpdate.RecordType.DeveloperName != 'PPU_Order'){
        System.debug('>>>>>>>>>>>>>>>>>Entered UpdateOrderStatus inside Valid Block:::' + orderUpdate.status__c);
        orderUpdate.status__c = 'Pending PM Approval';
        update orderUpdate; 
    }           
        //prodsWithAppRequired = [SELECT id,name,Product_Manager_Approval_Group__r.Id FROM Product2 WHERE Approval_Required__c = true AND
        //           id IN (SELECT Product__c FROM Order_Line_Item__c WHERE Order__c =: ordId AND Order__r.Approved_By_Manager__c = false)];    
        
        prodsWithAppRequired = [SELECT id,name,Product_Manager_Approval_Group__r.Id FROM Product2 WHERE  Shipment_Approval__c ='Highly Technical Sale - PM Approval Required' 
                                and Product_Manager_Approval_Group__c != '' AND
                   id IN (SELECT Product__c FROM Order_Line_Item__c WHERE id =: orderlineitemid )];
        
        if(!prodsWithAppRequired.isEmpty() && TriggerFlowManager.CURRENT_ORDER_RECORD_FOR_NON_REVENUE_ORDER_CHECK.RecordType.DeveloperName != OrderUtil.PPU_ORDER){
             
            System.debug('>>>>>>>>>>>>>>>>>Entered UpdateOrderStatus About to send Email:::' + orderUpdate.status__c);                
            Update_Order_WS.buildAndSendApprovalRequiredEmail(prodsWithAppRequired, ordId);
            System.debug('>>>>>>>>>>>>>>>>>Entered UpdateOrderStatus About to Email Sent:::' + orderUpdate.status__c);      
        }                               
            
    //update orderUpdate;       
    System.debug('>>>>>>>>>>>>>>>>>After OrderUpdate>>>>>>>>>>:::' + orderUpdate.status__c);
        
}  
    
// Update Order PM Approval Status on Orders

public static void updatePMApprovalStatus(List<Order__c> orderList){
     
    if(orderList.size()>0){
        for(Order__c ord : orderList){
            ord.Approved_By_Manager__c = true;              
        }
                    
        update orderList;           
    }
    
}


// Validate Product selection to exclude SalesPriceBook
public static void validateLineItemProducts( List<Order_Line_Item__c> lineItemsList) {
    Set<Id> productIdSet =  new Set<Id> ();
    integer init=1;
    for(Order_Line_Item__c lineItem: lineItemsList){
        productIdSet.add(lineItem.Product__c);  
    }
    PricebookEntry [] pbEntryList = [Select id, Product2Id  From PricebookEntry  where Product2Id IN :productIdSet and Pricebook2.Name = 'Sales PriceBook' AND IsActive = true];
    Map<id, integer> priceBookEntryMap = new Map<id, integer>();
    if(pbEntryList.size()>0){ 
        for( PricebookEntry pbEntry : pbEntryList){
            if(!priceBookEntryMap.containsKey(pbEntry.Product2Id)){
                priceBookEntryMap.put(pbEntry.Product2Id, init);
            } else {
                priceBookEntryMap.put(pbEntry.Product2Id, priceBookEntryMap.get(pbEntry.Product2Id)+1 );
            }
        }
    }
    for(Order_Line_Item__c lineItem: lineItemsList){
        if(priceBookEntryMap.containsKey(lineItem.Product__c)){
            if(priceBookEntryMap.get(lineItem.Product__c) > 0)
            {
                System.debug('<<< ' + lineItem.Product__c);
                lineItem.addError('This Product is used for Forecasting, please chose a different product.');
                lineItem.Product__c.addError('This Product is used for Forecasting, please chose a different product.');    
            }                   
        }
    }
}

// *** populate info like APN number, UOM from Product ***
public static void populateInfoOnOrderLines(List<Order_Line_Item__c> list_OLIToUpdate)
{
    Set<Id> set_ProductIds = new Set<Id>();
    for(Order_Line_Item__c objOLI : list_OLIToUpdate)
        set_ProductIds.add(objOLI.Product__c);
    
    Map<Id,Product2> map_Products = new Map<Id,Product2>([SELECT Id,APN_Number__c,Unit_of_Measure__c FROM Product2 WHERE Id IN :set_ProductIds]);
    
    for(Order_Line_Item__c objOLI : list_OLIToUpdate)
    {
        if(map_Products.containsKey(objOLI.Product__c))
        {
            Product2 objProduct = map_Products.get(objOLI.Product__c);
            objOLI.APN_Number__c = objProduct.APN_Number__c;
            objOLI.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
            TriggerFlowManager.ORDER_LINE_INFO_UPDATE = false;
        }
    }
}

public static List<Date> calculateSubscriptionOrderLineDates(Date orderStartDate, Date orderEndDate, Integer noOfMonths, Integer Year){
    List<Date> listOfStartAndEndDate = new List<Date>();
    Date orderLineStartDate, orderLineEndDate;
    noOfMonths = orderStartDate.monthsBetween(orderEndDate);
    if(Year == 1){
        orderLineStartDate = orderStartDate;
        if(noOfMonths >= 12)                
            orderLineEndDate = orderStartDate.addMonths(12).addDays(-1);            
        else
            orderLineEndDate = orderEndDate;//orderStartDate.addMonths(noOfMonths).addDays(-1);                         
    }
    else if(Year == 2){
        orderLineStartDate = orderStartDate.addMonths(12);
        if(noOfMonths >= 12)                
            orderLineEndDate = orderEndDate;//orderLineStartDate.addMonths(noOfMonths - 12).addDays(-1);  
    }  
    listOfStartAndEndDate.add(orderLineStartDate);
    listOfStartAndEndDate.add(orderLineEndDate);        
    return listOfStartAndEndDate;
}


/*
* Added By: Ashish Goyal (07/24/2018)
* Desc: Populate Gainsight Relationship Type on Order from Opportunity
*/

public static void populateGainsightOnOrder(List<Order__c> list_NewOrder){
    Map<Id, List<Order__c>> map_IdOppotyListOrder = new Map<Id, List<Order__c>>();
    for(Order__c ordr : list_NewOrder){
        if(ordr.Opportunity__c != null){
            if(!map_IdOppotyListOrder.containsKey(ordr.Opportunity__c)){
                map_IdOppotyListOrder.put(ordr.Opportunity__c, new List<Order__c>());
            }
            map_IdOppotyListOrder.get(ordr.Opportunity__c).add(ordr);
        }
    }
    
    if(map_IdOppotyListOrder.size() > 0){
        for(Opportunity oppty : [SELECT Id, Gainsight_Relationship_Type__c FROM Opportunity WHERE Id IN :map_IdOppotyListOrder.keySet()]){
            for(Order__c ordr : map_IdOppotyListOrder.get(oppty.Id)){
                ordr.Gainsight_Relationship_Type__c = oppty.Gainsight_Relationship_Type__c;
            }
        }
    }
}
}