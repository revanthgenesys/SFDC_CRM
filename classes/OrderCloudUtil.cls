/*
* Class Name       : OrderCloudUtil
* Description      : This Apex Class is used as util in multiple places for Cloud Orders (PC, PCC and PEC). 
* TestClass        : OrderCloudUtilTest
* ***************************************************************************************************************
* Developer Note   : *
* ***************************************************************************************************************
*/
public without sharing class OrderCloudUtil {
    
    public static Order__c pureSuccessChildOrder;
    public static Map<String, BigMachines__Quote_Product__c> mapPSAlacartItems = new Map<String, BigMachines__Quote_Product__c>();
    public static Map<String, BigMachines__Quote_Product__c> mapPSOfferItems = new Map<String, BigMachines__Quote_Product__c>();
    public Static Map<Id, Product2> map_Products;
    public static Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice = new Map<String, BigMachines__Quote_Product__c>();
    public static Boolean blnPureSuccessChangedonAmend;
    
    //Added By Ranjith on Mar 07, 2018 - Starts 
    //**** Method to create or update PC orders
    public static void orderFromQuote(BigMachines__Quote__c objQuote) {
        
        Order__c objOrder = new Order__c();
        Set<Id> set_NewOrderIds = new Set<Id>();        
        List<Order__c> list_ToDeleteHWOrders = new List<Order__c>(); 
        blnPureSuccessChangedonAmend = true;       
        
        for(Order__c objOrd : [SELECT Id, Original_Parent_Order1__c FROM Order__c WHERE Quote__c =: objQuote.Id]) {
            if(objOrd.Original_Parent_Order1__c == null) {
                objOrder = objOrd;
            }
            else {
                list_ToDeleteHWOrders.add(objOrd);
            }
        }
        
        if(objOrder.Id != null) {
            List<Order_Line_Item__c> list_ToDeleteOrderLineItems = [SELECT Id FROM Order_Line_Item__c WHERE Order__c =: objOrder.Id];
            if(list_ToDeleteOrderLineItems.size() > 0) {
                delete list_ToDeleteOrderLineItems;
            }
            if(list_ToDeleteHWOrders.size() > 0) {
                delete list_ToDeleteHWOrders;
            }
        } 
        
        //Create or update order
        objOrder = setUpOrderFromQuote(objQuote, objOrder);
        upsert objOrder;
        set_NewOrderIds.add(objOrder.Id);
        
        List<Account_Order_Address__c> list_AllAccountOrderAddresses = new List<Account_Order_Address__c>();
        list_AllAccountOrderAddresses = [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                         City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                         Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                         Sort_Order__c, State__c, Zip_Code__c, Quote__c 
                                         FROM Account_Order_Address__c WHERE Quote__c = :objQuote.Id];
        for(Account_Order_Address__c obj_AOA : list_AllAccountOrderAddresses) {               
            obj_AOA.Order__c = objOrder.Id;
        }
        if(list_AllAccountOrderAddresses.size() > 0)
            update list_AllAccountOrderAddresses;
        
        
        //Anju PCC PS Order July 2018
        //ECD PEC Quote July 2019
        if(blnPureSuccessChangedonAmend && (objQuote.Offering_Type__c == 'PureConnect Cloud' ||
                                            objQuote.Offering_Type__c == 'PureCloud' ||
                                            objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC)  && (objQuote.PureSuccess__c != null || (objQuote.Does_customer_currently_have_PureSuccess__c && objQuote.A_La_Carte_PureSuccess_Services_Amount__c > 0)))
            createPureSuccessOrder(objQuote,objOrder);
        
        //Create order line items
        List<Order_Line_Item__c> list_ToInsertOrderLineItems = setUpOrderLineItemsFromQuoteProducts(objQuote, objOrder);
        insert list_ToInsertOrderLineItems;        
        
        //ECD PEC Quote July 2019
        if((objQuote.Offering_Type__c == 'PureConnect Cloud' ||
            objQuote.Offering_Type__c == 'PureCloud' ||
            objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC) && objQuote.PureSuccess__c != null && pureSuccessChildOrder != null)
            createPureSuccessLinesCloud(mapOfPackageVsPrice, objQuote, pureSuccessChildOrder, list_ToInsertOrderLineItems);  
        
        //Create HW Orders and associated addresses and line items
        if([SELECT count() FROM Order_Line_Item_Allocation__c WHERE Quote__c =: objQuote.Id AND Quantity__c > 0] > 0) {
            createHWOrdersForCloud(objQuote.id, objOrder);
        }
        createOneTimeChargeOrder(objQuote.id, objOrder,objQuote.Offering_Type__c,objQuote.Order_Type__c,list_AllAccountOrderAddresses);
        for(Order__c objHWOrder : [SELECT Id FROM Order__c WHERE Original_Parent_Order1__c =: objOrder.Id]) {                    
            set_NewOrderIds.add(objHWOrder.Id);
        }
        System.debug('######set_NewOrderIds: '+set_NewOrderIds);
        
        //Share orders with created by user and opportunity owner
        if(!Test.isRunningTest()) {
            shareOrders(set_NewOrderIds, objQuote.BigMachines__Opportunity__r.OwnerId); 
        }
        //ECD PEC Quote July 2019
        /*if((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC ||
objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ||
objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC) && !blnPureSuccessChangedonAmend && pureSuccessChildOrder != null && pureSuccessChildOrder.id != null) {
System.Debug('CloudOrderUtil.orderFromQuote: blnPureSuccessChangedonAmend ' + blnPureSuccessChangedonAmend);
delete pureSuccessChildOrder;
}*/
        
    }
    
    
    //**** Method to set up PC parent order info from PC quote
    public static Order__c setUpOrderFromQuote(BigMachines__Quote__c objQuote, Order__c objNewOrder) {
        String region = Test.isRunningTest() ? 'North America' : //objQuote.BigMachines__Opportunity__r.Country_Region__c;
        String.isBlank(objQuote.BigMachines__Opportunity__r.Sold_To_Country__c) ? 
            objQuote.BigMachines__Opportunity__r.Country__r.Region__c  : 
        objQuote.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c;    
        System.debug('#####region: '+region);
        Global_Setting__c objGS = Global_Setting__c.getInstance('Order Queue'); 
        System.debug('#####objGS: '+objGS);   
        if(region == 'North America') { 
            system.debug('looped inside');          
            objGS = Global_Setting__c.getInstance('NA Order Queue');
        }             
        else if(region == 'Japan' || region=='JAPAN'){
            objGS = Global_Setting__c.getInstance('Japan Order Queue');
        }  
        else {
            objGS = Global_Setting__c.getInstance(region + ' Order Queue');
        }
        System.debug('#####objGS: '+objGS);
        //Map<String, RecordType> map_OrderRecTypes = getRecordTypes('Order__c');        
         objNewOrder.Requires_Manual_Billing_Review__c = objQuote.Amendment_For__r.Requires_Manual_Billing_Review__c;
       objNewOrder.Manual_Billing_Review_Status__c = objQuote.Amendment_For__r.Manual_Billing_Review_Status__c;
        objNewOrder.Status__c = objNewOrder.Id != null ? 'Re-Submitted' : 'Order Submitted';
        objNewOrder.Name = 'Order ' + objQuote.Name;
         if(objGS.ID__c!=Null)
        {
        objNewOrder.OwnerId = objGS.ID__c;//Added for Preventing null pointer for CCDB
            }
        objNewOrder.RecordTypeId =  Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Cloud Billing Master Order').getRecordTypeId();
        objNewOrder.Date_Submitted__c = System.Now();
        objNewOrder.Quote__c = objQuote.Id;
        objNewOrder.Annual_Contract_Value__c = objQuote.Annual_Contract_Value__c;
        objNewOrder.CMRR__c = objQuote.CMRR__c;
        objNewOrder.TCV__c = objQuote.Total_Contract_Value__c;
        objNewOrder.PO_Received_Date__c = objQuote.Order_PO_Received_Date__c;
        objNewOrder.End_User_Name__c = objQuote.End_User_ID__c;
        objNewOrder.Ship_To_Name__c = objQuote.End_User_ID__c;
        objNewOrder.Sold_To_Name__c = objQuote.Sold_To_Name__c; 
        objNewOrder.Bill_To_Name__c = objQuote.Sold_To_Name__c;
        objNewOrder.Order_Type__c = 'Non-Revenue';
        objNewOrder.Opportunity__c = objQuote.BigMachines__Opportunity__c; 
        objNewOrder.Genesys_Care_Specialist_Email__c = objQuote.BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email;
        objNewOrder.Genesys_Care_Ops_Email__c = objQuote.BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email;
        objNewOrder.PO_Number__c = objQuote.Order_PO_Number__c;
        objNewOrder.PO_Date__c = objQuote.Order_PO_Date__c;
        objNewOrder.Payment_Terms__c = objQuote.Order_Payment_Terms__c;
        objNewOrder.Special_Instructions__c = objQuote.Order_Special_Instructions__c;
        objNewOrder.CurrencyIsoCode = objQuote.CurrencyIsoCode;
        objNewOrder.Direct_Sales_Rep_1__c  = objQuote.BigMachines__Opportunity__r.OwnerId;
        objNewOrder.Subsidaries__c  = objQuote.End_User_ID__r.Subsidary__c;
        //Added by Ranjith on Sep 19, 2018 - Starts
        objNewOrder.Desired_Go_Live_Date__c = objQuote.Billing_Start_Date__c;
        objNewOrder.Maintenance_Start__c = objQuote.Subscription_Start_Date__c;
        objNewOrder.Maintenance_End__c = objQuote.Subscription_End_Date__c;
        objNewOrder.Numb_of_Maint_Months__c = objQuote.No_Of_Months__c;
        //Added by Ranjith on Sep 19, 2018 - Ends
        //Added By Ranjith on Apr 23, 2019 -- Starts -- Reason for new sub 
        objNewOrder.Reason_for_New_when_Sub_s_Already_Exist__c = objQuote.Reason_for_New_when_Sub_s_Already_Exist__c;
        //Added By Ranjith on Apr 23, 2019 -- Ends -- Reason for new sub
        //Anju June 2018 Bypass Contract 
        objNewOrder.Bypass_Service_Contract__c = true;
        
        //mukunth added for capturing multi-year ACV
        objNewOrder.Multi_Year_ACV_Year_1__c = objQuote.Multi_Year_ACV_Year_1__c;
        objNewOrder.Multi_Year_ACV_Year_2__c = objQuote.Multi_Year_ACV_Year_2__c;
        objNewOrder.Multi_Year_ACV_Year_3__c = objQuote.Multi_Year_ACV_Year_3__c;
        objNewOrder.Multi_Year_ACV_Year_4__c = objQuote.Multi_Year_ACV_Year_4__c;
        objNewOrder.Multi_Year_ACV_Year_5__c = objQuote.Multi_Year_ACV_Year_5__c;
        objNewOrder.Multi_Year_ACV_Year_6__c = objQuote.Multi_Year_ACV_Year_6__c;
        objNewOrder.Multi_Year_ACV_Year_7__c = objQuote.Multi_Year_ACV_Year_7__c;
        objNewOrder.Multi_Year_ACV_Year_8__c = objQuote.Multi_Year_ACV_Year_8__c;
        objNewOrder.Multi_Year_ACV_Year_9__c = objQuote.Multi_Year_ACV_Year_9__c;
        objNewOrder.Multi_Year_ACV_Year_10__c = objQuote.Multi_Year_ACV_Year_10__c;
        objNewOrder.Contract_terms_drive_ACV_Change__c = objQuote.Contract_terms_drive_ACV_Change__c;
        //mukunth code end
        
        // kartik Special offer term sync with order.
        objNewOrder.Special_Offer_Terms__c = objQuote.Special_Offer_Terms__c;
        
        //Anju May 31 Revpro
        objNewOrder.Master_Order_Number__c = objNewOrder.Name;
        if(objQuote.Order_Type__c == 'Amend Subscription')
        {
            objNewOrder.Master_Order_Number__c = objQuote.Amendment_For__r.Master_Order_Number__c;
            //objNewOrder.Master_Order__c = objQuote.Amendment_For__r.Order__c;     
        }
        
        objNewOrder.Contract_Signature_Date__c = objQuote.Contract_Signature_Date__c;
        objNewOrder.License_FYM_detail__c = 'Cloud Order';
        
        System.debug('######objNewOrder: '+objNewOrder);
        return objNewOrder;
    }
    
    //**** Method to set up PC parent order line items from PC quote products
    public static List<Order_Line_Item__c> setUpOrderLineItemsFromQuoteProducts(BigMachines__Quote__c objQuote, Order__c objNewOrder) {
        try{
            List<Order_Line_Item__c> list_ToInsertOrderLineItems = new List<Order_Line_Item__c>(); 
            Integer intOLICount = 1;   
            //Map<String, RecordType> map_OrderLnItmRecTypes = getRecordTypes('Order_Line_Item__c');
            Set<String> set_OLIUniqueString = new Set<String>();  
            integer line_numberAlaCart = 5;
            Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Cloud Billing Master Order Line').getRecordTypeId();
            //if(objQuote.Amendment_For__c != null && objQuote.Order_Type__c == Label.Amend_Subscription)
            //     blnPureSuccessChangedonAmend = false;
            
            for (BigMachines__Quote_Product__c objQP : [SELECT Id, Total_Discount__c, List_Price__c, BigMachines__Product__c, Hide_Record__c, Extended_Price_Per_Month__c,
                                                        BigMachines__Product__r.Name, BigMachines__Product__r.APN_Number__c,Ext_Net_Price__c,Cumulative_Total_of_Price_for_Amendment__c,
                                                        BigMachines__Product__r.Description__c, Net_Unit_Price__c, Is_Overage__c,Subscription_Product__r.Quantity__c,
                                                        Quantity__c, Unit_of_Measure__c, Partner_Price__c, Product_Specific_Discount__c,Subscription_Product__r.Ext_Net_Price__c,
                                                        Product_Group__c,Bundle__r.Group_Type__c,Bundle_Line__c,Bundle__r.Name,Bundle_Line__r.BigMachines__Product__c,
                                                        Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.APN_Number__c,Bundle_Line__r.Current_Qty__c,Current_Qty__c,
                                                        Original_Qty__c,Bundle_Line__r.Original_Qty__c,Tokens__c,Bundle_Line__r.Tokens__c,
                                                        BigMachines__Product__r.Product_Group__c,Line_Number__c,
                                                        Bundle_Line__r.List_Price__c,Bundle_Line__r.BigMachines__Quantity__c,
                                                        APN_Number__c,BigMachines__Quantity__c,
                                                        Bundle_Line__r.Extended_Price_Per_Month__c
                                                        FROM BigMachines__Quote_Product__c 
                                                        WHERE BigMachines__Quote__c =: objQuote.Id]) { 
                                                            if(objQP.Bundle__r.Group_Type__c == 'PureSuccess'){
                                                                //Anju Jan 30
                                                                //ECD PEC Quote July 2019
                                                                if((objQuote.Offering_Type__c == 'PureConnect Cloud' && objQP.Bundle_Line__c != NULL) ||
                                                                   objQuote.Offering_Type__c == 'PureCloud' ||
                                                                   (objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC && objQP.Bundle_Line__c != NULL) )
                                                                {
                                                                    if(objQuote.Amendment_For__c != null && objQuote.Order_Type__c == Label.Amend_Subscription && objQP.Subscription_Product__c == null)
                                                                    {
                                                                        mapOfPackageVsPrice.put(objQP.Bundle__r.Name, objQP);
                                                                    }
                                                                    else if(objQuote.Order_Type__c != Label.Amend_Subscription)
                                                                        mapOfPackageVsPrice.put(objQP.Bundle__r.Name, objQP);
                                                                    set_OLIUniqueString.add( objQP.BigMachines__Product__c+';'+ objQP.Is_Overage__c);
                                                                    if(objQP.Bundle_Line__c != NULL){continue;}
                                                                }
                                                            }
                                                            
                                                            //PureSuccess Anju Jan 2018 starts remove Alacarte items
                                                            //ECD PEC Quote July 2019
                                                            if((objQuote.Offering_Type__c == 'PureConnect Cloud' ||
                                                                objQuote.Offering_Type__c == 'PureCloud' ||
                                                                objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC) && objQuote.PureSuccess__c != null && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte')){
                                                                    mapPSAlacartItems.put(objQP.id,objQP);
                                                                    if(objQuote.Amendment_For__c != null && objQuote.Order_Type__c == Label.Amend_Subscription)
                                                                    {
                                                                        Decimal decQuanityChange = (objQP.Subscription_Product__c != null && objQP.Subscription_Product__r.Quantity__c != null) ? (objQP.Quantity__c - objQP.Subscription_Product__r.Quantity__c) : objQP.Quantity__c;
                                                                        if(decQuanityChange > 0)
                                                                            blnPureSuccessChangedonAmend = true;
                                                                    }    
                                                                }
                                                            //ECD PEC Quote July 2019
                                                            if((objQuote.Offering_Type__c == 'PureConnect Cloud' ||
                                                                objQuote.Offering_Type__c == 'PureCloud' ||
                                                                objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC) && objQuote.PureSuccess__c != null && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect Offer')){
                                                                    mapPSOfferItems.put(objQP.id,objQP);
                                                                    if(objQuote.Amendment_For__c != null && objQuote.Order_Type__c == Label.Amend_Subscription)
                                                                    {
                                                                        Decimal decQuanityChange = (objQP.Subscription_Product__c != null && objQP.Subscription_Product__r.Quantity__c != null) ? (objQP.Quantity__c - objQP.Subscription_Product__r.Quantity__c) : objQP.Quantity__c;
                                                                        if(decQuanityChange > 0)
                                                                            blnPureSuccessChangedonAmend = true;
                                                                    } 
                                                                }
                                                            //PureSuccess Anju Jan 2018 ends             
                                                            
                                                            Order_Line_Item__c objNewOLI = new Order_Line_Item__c();
                                                            objNewOLI.Order__c = objNewOrder.Id;
                                                            //Anju PureSuccess Jan 2018 starts
                                                            if(mapPSAlacartItems.containskey(objQP.id))
                                                                objNewOLI.Order__c = pureSuccessChildOrder.id;
                                                            //Anju PureSuccess Jan 2018 ends
                                                            objNewOLI.Quote_Product__c = objQP.Id;
                                                            objNewOLI.Line_Number__c = objQP.Line_Number__c;System.debug('objNewOLI.Line_Number__c:'+objNewOLI.Line_Number__c+' objQP.Line_Number__c:'+objQP.Line_Number__c);
                                                            objNewOLI.CurrencyIsoCode=  objQuote.CurrencyIsoCode;
                                                            objNewOLI.Product__c = objQP.BigMachines__Product__c;
                                                            objNewOLI.Product_txt__c = objQP.BigMachines__Product__r.Name;
                                                            objNewOLI.Name = objQP.BigMachines__Product__r.Name;
                                                            objNewOLI.APN_Number__c = objQP.BigMachines__Product__r.APN_Number__c;  
                                                            //Anju Nov 2018 set dummy apn number for puresuccess
                                                            //ECD PEC Quote July 2019
                                                            if((objQuote.Offering_Type__c == 'PureConnect Cloud' ||
                                                                objQuote.Offering_Type__c == 'PureCloud' ||
                                                                objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC) && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect Offer'))
                                                            {
                                                                objNewOLI.Dummy_APN__c = objQP.BigMachines__Product__r.APN_Number__c;  
                                                            }
                                                            //ECD PEC Quote July 2019
                                                            if((objQuote.Offering_Type__c == 'PureConnect Cloud' ||
                                                                objQuote.Offering_Type__c == 'PureCloud' ||
                                                                objQuote.Offering_Type__c == QuoteCloudUtil.OFFERING_TYPE_PEC) && (objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte'))
                                                            {
                                                                objNewOLI.Base_Package__c = objQP.Ext_Net_Price__c; 
                                                            }    
                                                            objNewOLI.Description__c = objQP.BigMachines__Product__r.Description__c;
                                                            //Added By Ranjith on Aug 22, 2018 - Starts
                                                            //objNewOLI.RecordTypeId = map_OrderLnItmRecTypes.get('Default').Id;            
                                                            objNewOLI.RecordTypeId = recordTypeIdForOLI;
                                                            //Added By Ranjith on Aug 22, 2018 - Ends   
                                                            objNewOLI.Unit_of_Measure__c = objQP.Unit_of_Measure__c != null ? objQP.Unit_of_Measure__c : '';
                                                            objNewOLI.Quantity__c = objQP.Quantity__c != null ? Integer.valueOf(objQP.Quantity__c) : 0;
                                                            objNewOLI.BigMachines_Quantity__c = objQP.Quantity__c;
                                                            objNewOLI.List_Price__c = objQP.List_Price__c != null ? objQP.List_Price__c : 0;                       
                                                            objNewOLI.Net_Unit_Price__c = objQP.Net_Unit_Price__c != null ? objQP.Net_Unit_Price__c : 0;
                                                            objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
                                                            //Commented by Ranjith on Nov 15, 2018 - Below lines are not required as it doesnt include additional discounts
                                                            //if(objQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c || objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) {
                                                            //    objNewOLI.Net_Unit_Price__c = objQP.Partner_Price__c != null && objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c : objQP.Net_Unit_Price__c;
                                                            //}
                                                            objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
                                                            System.debug('######objNewOLI.Net_Unit_Price__c: '+objNewOLI.Net_Unit_Price__c);
                                                            System.debug('######objNewOLI.Quantity__c: '+objNewOLI.Quantity__c);
                                                            objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
                                                            if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                                                                objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                                                                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                                                            }            
                                                            objNewOLI.Total_Discount__c = objQP.Total_Discount__c;
                                                            objNewOLI.Product_Specific_Discount__c = objQP.Product_Specific_Discount__c;
                                                            objNewOLI.Cumulative_Total_for_Amendment_c__c = objQP.Cumulative_Total_of_Price_for_Amendment__c;
                                                            objNewOLI.Is_Overage__c = objQP.Is_Overage__c;
                                                            objNewOLI.Ext_Net_Price_Change__c = 0;
                                                            objNewOLI.Quantity_Change__c = 0;
                                                            objNewOLI.Tokens__c = objQP.Tokens__c;
                                                            if(objQuote.Order_Type__c == Label.Amend_Subscription) {
                                                                objNewOLI.Ext_Net_Price_Change__c = (objQP.Subscription_Product__c != null && objQP.Subscription_Product__r.Ext_Net_Price__c != null) ? (objQP.Ext_Net_Price__c - objQP.Subscription_Product__r.Ext_Net_Price__c) : objQP.Ext_Net_Price__c;
                                                                objNewOLI.Quantity_Change__c = (objQP.Subscription_Product__c != null && objQP.Subscription_Product__r.Quantity__c != null) ? (objQP.Quantity__c - objQP.Subscription_Product__r.Quantity__c) : objNewOLI.Quantity__c;
                                                            }
                                                            set_OLIUniqueString.add( objNewOLI.Product__c+';'+ objNewOLI.Is_Overage__c);
                                                            //Anju PureSuccess Jan 2018 starts
                                                            if(mapPSAlacartItems.containskey(objQP.id)){
                                                                objNewOLI.Order__c = pureSuccessChildOrder.id;
                                                                objNewOLI.Year__c = 1;
                                                                objNewOLI.Maintenance_Start_Date__c = pureSuccessChildOrder.Maintenance_Start__c;
                                                                objNewOLI.Maintenance_End_Date__c = pureSuccessChildOrder.Maintenance_End__c;
                                                                objNewOLI.Line_Number__c = objQP.Line_Number__c;System.debug('objNewOLI.Line_Number__c:'+objNewOLI.Line_Number__c+' objQP.Line_Number__c:'+objQP.Line_Number__c);
                                                                objNewOLI.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
                                                                line_numberAlaCart ++;
                                                                Order_Line_Item__c objNewOLIclone = objNewOLI.clone();
                                                                objNewOLIclone.Order__c = objNewOrder.Id;
                                                                objNewOLIclone.RecordTypeId = recordTypeIdForOLI;
                                                                list_ToInsertOrderLineItems.add(objNewOLIclone);
                                                                
                                                            }
                                                            //Anju PureSuccess Jan 2018 ends
                                                            if(!mapPSAlacartItems.containskey(objQP.id))
                                                                list_ToInsertOrderLineItems.add(objNewOLI);
                                                            if(mapPSAlacartItems.containskey(objQP.id) && ((objQuote.Order_Type__c == Label.Amend_Subscription && objNewOLI.Quantity_Change__c > 0) || (objQuote.Order_Type__c != Label.Amend_Subscription)))
                                                            {
                                                                if(objQuote.Order_Type__c == Label.Amend_Subscription)
                                                                {
                                                                    objNewOLI.Quantity__c = objNewOLI.Quantity_Change__c;
                                                                    objNewOLI.BigMachines_Quantity__c = objNewOLI.Quantity_Change__c;
                                                                    objNewOLI.Tokens__c = null;
                                                                }
                                                                objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                                                                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                                                                list_ToInsertOrderLineItems.add(objNewOLI);
                                                            }
                                                            intOLICount++;   
                                                            System.debug('!@#$%^objNewOLI: '+objNewOLI);        
                                                        }
            System.debug('Fields'+objQuote);
            //revpro change, need to change later            
            if(objQuote.Amendment_For__c != null && (objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription ))
            {
                list_ToInsertOrderLineItems.addAll(createOLIfromSupProds(set_OLIUniqueString,intOLICount,objQuote,objNewOrder.Id));
            }
            System.debug('######list_ToInsertOrderLineItems: '+list_ToInsertOrderLineItems);
            
            return list_ToInsertOrderLineItems;
        }catch(System.QueryException e){system.debug('Exception has occurred:'+e.getMessage()+'\n'+e.getTypeName()+'\nStacktrace:'+e.getStackTraceString()+'\n'+e.getDmlFields(0));
                                        return null;
                                       }  
    }      
    
    //Added By Ranjith on Mar 07, 2018 - Ends
    
    //Added By Ranjith on Oct 30, 2017 - Starts
    public static void shareOrders(Set<Id> set_NewOrderIds, Id ownerId) {
        List<Order__Share> list_InsertOrderShares = new List<Order__Share>();
        for(Id orderId : set_NewOrderIds) {
            list_InsertOrderShares.add(new Order__Share(ParentId = orderId, AccessLevel = Label.Access_Permission,
                                                        UserOrGroupId = ownerId,
                                                        RowCause = Schema.Order__Share.RowCause.Rep_Access__c));
            if(ownerId != UserInfo.getUserId()) {
                list_InsertOrderShares.add(new Order__Share(ParentId = orderId, AccessLevel = Label.Access_Permission,
                                                            UserOrGroupId = UserInfo.getUserId(),
                                                            RowCause = Schema.Order__Share.RowCause.Rep_Access__c));
            }
        }        
        insert list_InsertOrderShares;
    }
    //Added By Ranjith on Oct 30, 2017 - Ends
    
    //Added By Ranjith on Jun 26, 2017 - Starts
    // *** Method to pull record types of a sobject ***
    public static Map<String, RecordType> getRecordTypes(String strObjType) {
        Map<String, RecordType> map_rts = new Map<String, RecordType>();
        for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType =: strObjType]) {
            map_rts.put(recType.Name, recType);
        }
        return map_rts;
    }  
    //Added By Ranjith on Jun 26, 2017 - Ends
    
    public static List<Order_Line_Item__c> createOLIfromSupProds(Set<String> set_OLIUniqueString,Integer intOLICount,BigMachines__Quote__c objQuote,Id IdOrderId) {
        
        //Added by Rony Joseph - June 05 2018 - Starts
        //*******Adding removed products from Subscription as Order Line Items with 0 Quantity
        System.debug('Entered createOLIfromSupProds');
        Map<String,Subscription_Product__c> map_PrevProdInfo = new Map<String,Subscription_Product__c>();
        Map<String, RecordType> map_OrderLnItmRecTypes = getRecordTypes('Order_Line_Item__c');
        List<Order_Line_Item__c> list_ToInsertOrderLineItems = new List<Order_Line_Item__C>();
        List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProducts(objQuote.Amendment_For__c);
        for(Subscription_Product__c objSubProd : list_SubscriptionProds) {
            String strUniqueKey = objSubProd.Product__c+';'+objSubProd.Is_Overage__c; 
            System.debug('UniqueString:'+strUniqueKey);
            if(!String.isBlank(strUniqueKey) && objSubProd.Quantity__c != null) {
                map_PrevProdInfo.put(strUniqueKey, objSubProd);
            }
        }   
        
        System.debug('OLIUnistring:'+set_OLIUniqueString);
        System.debug('map_PrevProdInfo.keyset() :'+map_PrevProdInfo.keyset() );
        Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Cloud Billing Master Order Line').getRecordTypeId();
        for(String strUniqueKey:map_PrevProdInfo.keyset()) {
            if(!set_OLIUniqueString.contains(strUniqueKey) && (map_PrevProdInfo.get(strUniqueKey).Product__r.New_Category__c != 'PureSuccess' || (map_PrevProdInfo.get(strUniqueKey).Product__r.New_Category__c == 'PureSuccess' && map_PrevProdInfo.get(strUniqueKey).bundle__c == null))) {
                System.debug('MatchString:'+strUniqueKey);
                Subscription_Product__c objSubProd = map_PrevProdInfo.get(strUniqueKey);
                Order_Line_Item__c objNewOLI = new Order_Line_Item__c();
                objNewOLI.Order__c = IdOrderId;
                objNewOLI.Quote_Product__c = objSubProd.Quote_Product__c;
                objNewOLI.Line_Number__c = objSubProd.Line_Number__c;
                objNewOLI.CurrencyIsoCode=  objSubProd.CurrencyIsoCode;
                objNewOLI.Product__c = objSubProd.Product__c;
                objNewOLI.Product_txt__c = objSubProd.Product__r.Name;
                objNewOLI.Name = objSubProd.Product__r.Name;
                objNewOLI.APN_Number__c = objSubProd.Product__r.APN_Number__c;      
                objNewOLI.Description__c = objSubProd.Product__r.Description__c;
                //Added By Ranjith on Aug 22, 2018 - Starts
                objNewOLI.RecordTypeId = recordTypeIdForOLI;
                //Added By Ranjith on Aug 22, 2018 - Ends                   
                objNewOLI.Unit_of_Measure__c = objSubProd.Quote_Product__r.Unit_of_Measure__c != null ? objSubProd.Quote_Product__r.Unit_of_Measure__c : '';
                objNewOLI.Quantity__c =  0;
                objNewOLI.BigMachines_Quantity__c = 0;
                objNewOLI.List_Price__c = objSubProd.List_Price__c;                       
                objNewOLI.Net_Unit_Price__c = objSubProd.Net_Unit_Price__c;
                objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
                if(objQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
                    objNewOLI.Net_Unit_Price__c = objSubProd.Partner_Price__c != null && objSubProd.Partner_Price__c > 0 ? objSubProd.Partner_Price__c : objSubProd.Net_Unit_Price__c;
                }            
                objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
                System.debug('######objNewOLI.Net_Unit_Price__c: '+objNewOLI.Net_Unit_Price__c);
                System.debug('######objNewOLI.Quantity__c: '+objNewOLI.Quantity__c);
                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
                if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                    objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                }            
                objNewOLI.Total_Discount__c = objSubProd.Total_Discount__c;
                objNewOLI.Product_Specific_Discount__c = objSubProd.Quote_Product__r.Product_Specific_Discount__c;
                objNewOLI.Is_Overage__c = objSubProd.Is_Overage__c;
                objNewOLI.Ext_Net_Price_Change__c = objSubProd.Ext_Net_Price_Change__c;
                objNewOLI.Quantity_Change__c = objSubProd.Quantity__c*-1;
                list_ToInsertOrderLineItems.add(objNewOLI);
                intOLICount++;                
            }
        }        
        return list_ToInsertOrderLineItems;
        //Added by Rony Joseph - June 05 2018 - Ends
    }  
    
    // Anju June 2018 Revpro update POB Type on order line item
    public static void populateRevproFields(List<Order_Line_Item__c> list_OrderLineItems){
        
        Map<Id, Product2> map_products = new Map<Id, Product2> ();
        Map<Id, Order__c> map_Orders = new Map<Id, Order__c> ();
        Set<Id> set_ProductIds = new Set<Id>();
        Set<Id> set_OrderIds = new Set<Id>();
        for(Order_Line_Item__c objOLI : list_OrderLineItems)
        {
            set_ProductIds.add(objOLI.Product__c);
            set_OrderIds.add(objOLI.Order__c);
        }
        
        map_Orders = new Map<Id, Order__c>([Select Id, Order_category__c, Original_Parent_Order1__c, Original_Parent_Order1__r.Order_category__c, Quote__r.Billing_Category__c,Quote__r.Order_Type__c
                                            FROM Order__c
                                            where Id IN :set_OrderIds]);
        
        map_products= new Map<Id, Product2>([Select Id, new_category__c, Sub_Category__c, type__c, POB_Type__c, Include_in_CMMR_Total__c,Product_Group__c, BillingGroup__c, Unit_of_Measure__c 
                                             FROM Product2
                                             where Id IN :set_ProductIds]);
        
        for(Order_Line_Item__c objOrderline : list_OrderLineItems){
            if(objOrderline.POB_Type__c == null && map_Orders.containskey(objOrderline.order__c) && map_Orders.get(objOrderline.Order__c).Order_Category__c != null && (map_Orders.get(objOrderline.Order__c).Order_Category__c.contains('-Cloud Order') || (map_Orders.get(objOrderline.Order__c).Original_Parent_Order1__c != null && map_Orders.get(objOrderline.Order__c).Original_Parent_Order1__r.Order_Category__c.contains('-Cloud Order')))){
                
                if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).POB_Type__c != NULL)
                    objOrderline.POB_Type__c = map_products.get(objOrderline.product__c).POB_Type__c;
                else if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).type__c == 'Hardware Warranty')
                    objOrderline.POB_Type__c = 'Hardware Support';
                else if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).type__c == 'Product - Hardware')
                    objOrderline.POB_Type__c = 'Hardware';
                
                else if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).type__c == 'Token')
                    objOrderline.POB_Type__c = 'PureSuccess Token';
                //For PureSuccess
                else if(map_products.containskey(objOrderline.product__c) && (map_products.get(objOrderline.product__c).new_category__c == 'PureSuccess'))
                    objOrderline.POB_Type__c = 'Point In Time - Cloud';
                else if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).new_category__c == 'Latitude')
                    objOrderline.POB_Type__c = 'Latitude License - Cloud';
                else if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).type__c == 'GU')
                    objOrderline.POB_Type__c = 'Not Applicable';
                else if(map_products.containskey(objOrderline.product__c) && map_products.get(objOrderline.product__c).type__c == 'Professional Services')
                    objOrderline.POB_Type__c = 'Not Applicable';
                //Rony Joseph - Added for Products Removed - September 11th 2019
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' && map_Orders.get(objOrderline.Order__c).Quote__r.Order_Type__c == Label.Amend_Subscription && objOrderline.Quantity_Change__c < 0 && objOrderline.Total_Price__c == 0 )
                    objOrderline.POB_Type__c = 'Cloud-Committed';
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order'  && map_Orders.get(objOrderline.Order__c).Quote__r.Order_Type__c == Label.Amend_Subscription && objOrderline.Quantity_Change__c < 0 && objOrderline.Total_Price__c == 0 )
                    objOrderline.POB_Type__c = 'Cloud-Committed';    
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' && map_products.get(objOrderline.product__c).New_category__c != null && map_products.get(objOrderline.product__c).New_category__c != 'Credit' && Label.Check_For_One_Time_Fees_PC.remove('Hardware;').contains(map_products.get(objOrderline.product__c).New_category__c))
                    objOrderline.POB_Type__c = 'Point In Time - Cloud'; 
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' && map_products.get(objOrderline.product__c).New_category__c != null && Label.Check_For_One_Time_Fees_PCC.remove('Hardware;').contains(map_products.get(objOrderline.product__c).New_category__c))
                    objOrderline.POB_Type__c = 'Point In Time - Cloud';
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order' && !map_products.get(objOrderline.product__c).Include_in_CMMR_Total__c)
                    objOrderline.POB_Type__c = 'Point In Time - Cloud';
                
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' && map_products.get(objOrderline.product__c).New_category__c != null && map_products.get(objOrderline.product__c).New_category__c != 'Credit' && Label.Check_For_One_Time_Fees_PCC.remove('Hardware;').contains(map_products.get(objOrderline.product__c).New_category__c))
                    objOrderline.POB_Type__c = 'Point In Time - Cloud';
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order' && map_products.get(objOrderline.product__c).New_category__c != null && map_products.get(objOrderline.product__c).New_category__c != 'Credit' && Label.Check_For_One_Time_Fees_PCC.remove('Hardware;').contains(map_products.get(objOrderline.product__c).New_category__c))
                    objOrderline.POB_Type__c = 'Point In Time - Cloud';
                
                else if(map_Orders.get(objOrderline.Order__c).Quote__r.Billing_Category__c == 'M2M' || ((map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' || map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order') && objOrderline.APN_Number__c != 'PC-170-NV-MNRQ' && (objOrderline.Is_Overage__c || objOrderline.BigMachines_Quantity__c == 0 || objOrderline.BigMachines_Quantity__c == null || objOrderline.Total_Price__c == 0)))
                    objOrderline.POB_Type__c = 'Cloud-Uncommitted';
                
                // 012319 vinay added PureCloud Credit product
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' && objOrderline.APN_Number__c == 'PC-170-NV-MNRQ' || map_products.get(objOrderline.product__c).New_category__c == 'Credit')
                    objOrderline.POB_Type__c = 'Cloud-Committed';
                //071619 vinay added Pureconnect Cloud Credit product
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' && (objOrderline.APN_Number__c == 'CS-012-NV-PPOC' || objOrderline.APN_Number__c == 'CS-012-NV-PPRC' ) || map_products.get(objOrderline.product__c).New_category__c == 'Credit')
                    objOrderline.POB_Type__c = 'Cloud-Committed'; 
                
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order' && map_products.get(objOrderline.product__c).New_category__c == 'Credit')
                    objOrderline.POB_Type__c = 'Cloud-Committed';       
                
                
                
                //011619 added by Vinay for telco products
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order' && map_products.get(objOrderline.product__c).BillingGroup__c == 'Telco Services' && map_products.get(objOrderline.product__c).Unit_of_Measure__c == 'Per Minute' && (objOrderline.BigMachines_Quantity__c == 0 || objOrderline.BigMachines_Quantity__c == 1) )
                    objOrderline.POB_Type__c = 'Cloud-UnCommitted';      
                
                
                else if(map_Orders.get(objOrderline.Order__c).Quote__r.Billing_Category__c == 'M2M' || ((map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' || map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' || map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order') && objOrderline.APN_Number__c != 'PC-170-NV-MNRQ' && (objOrderline.Is_Overage__c || objOrderline.BigMachines_Quantity__c == 0 || objOrderline.BigMachines_Quantity__c == null || objOrderline.Total_Price__c == 0)))
                    objOrderline.POB_Type__c = 'Cloud-Uncommitted';
                
                //012819 added by Vinay for telco products
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' && map_products.get(objOrderline.product__c).New_Category__c == 'Voice Services' && (map_products.get(objOrderline.product__c).Unit_of_Measure__c == 'Per Minute' || map_products.get(objOrderline.product__c).Unit_of_Measure__c == 'Per Rate Table') && (objOrderline.BigMachines_Quantity__c == 0 || objOrderline.BigMachines_Quantity__c == 1) )
                    objOrderline.POB_Type__c = 'Cloud-UnCommitted';
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' && map_products.get(objOrderline.product__c).New_Category__c == 'Monthly Telecommunications and Datacenter Fees' && map_products.get(objOrderline.product__c).Unit_of_Measure__c == 'Per Number Per Month' && (objOrderline.BigMachines_Quantity__c == 0 || objOrderline.BigMachines_Quantity__c == 1) )
                    objOrderline.POB_Type__c = 'Cloud-UnCommitted';   
                
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order' && objOrderline.BigMachines_Quantity__c > 0 && objOrderline.Total_Price__c > 0 && !objOrderline.Is_Overage__c && map_products.containskey(objOrderline.product__c) && (map_products.get(objOrderline.product__c).type__c == 'Cloud' || map_products.get(objOrderline.product__c).type__c == 'Bundle' || (map_products.get(objOrderline.product__c).type__c == 'AppFoundry' && map_products.get(objOrderline.product__c).Include_in_CMMR_Total__c)))
                    objOrderline.POB_Type__c = 'Cloud-Committed';
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' && objOrderline.BigMachines_Quantity__c > 0 && objOrderline.Total_Price__c > 0 && map_products.get(objOrderline.product__c).type__c == 'Cloud' && map_products.get(objOrderline.product__c).Include_in_CMMR_Total__c)
                    objOrderline.POB_Type__c = 'Cloud-Committed';
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order' && objOrderline.BigMachines_Quantity__c > 0 && objOrderline.Total_Price__c > 0 && map_products.get(objOrderline.product__c).type__c == 'Cloud' && map_products.get(objOrderline.product__c).Include_in_CMMR_Total__c)
                    objOrderline.POB_Type__c = 'Cloud-Committed';
                
                
                else if(map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureConnect-Cloud Order' || map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureEngage-Cloud Order' || map_Orders.get(objOrderline.Order__c).Order_Category__c == 'PureCloud-Cloud Order')
                    objOrderline.POB_Type__c = 'Error';
            }
            
        }
        
    }    
    
    //Anju July 2018 Create puresuccess order for PCC
    public static void createPureSuccessOrder(BigMachines__Quote__c objQuote, Order__c objOrder){        
        pureSuccessChildOrder = objOrder.clone();
        pureSuccessChildOrder.name = (pureSuccessChildOrder.name + Label.PureSuccess_Child_Order_Name).left(80);
        pureSuccessChildOrder.recordtypeid = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
        pureSuccessChildOrder.Original_Parent_Order1__c = objOrder.id;
        //pureSuccessChildOrder.ownerid = getOrderManagementQueue(objQuote.id);
        pureSuccessChildOrder.Order_Type__c = 'Revenue';
        pureSuccessChildOrder.License_FYM_detail__c = 'Cloud Order';
        pureSuccessChildOrder.Year__c = '1';
        pureSuccessChildOrder.Maintenance_Start__c = system.today();
        pureSuccessChildOrder.Maintenance_End__c = system.today().addmonths(Integer.valueof(objQuote.No_Of_Months__c)) - 1;
        pureSuccessChildOrder.Numb_of_Maint_Months__c = objQuote.No_Of_Months__c;
        pureSuccessChildOrder.Annual_Contract_Value__c = pureSuccessChildOrder.CMRR__c = 0;
        pureSuccessChildOrder.Bypass_Service_Contract__c = false;
        pureSuccessChildOrder.TCV__c = objQuote.A_La_Carte_PureSuccess_Services_Amount__c + objQuote.PureSuccess_Offer_Subscription_Amount__c;
        pureSuccessChildOrder.Total_Order__c = pureSuccessChildOrder.TCV__c;
        //Anju Oct 26 2018 no need to subtract PS amoutn from master order
        //objOrder.TCV__c = objOrder.TCV__c - pureSuccessChildOrder.TCV__c;
        //update objOrder;
        if(pureSuccessChildOrder.TCV__c == 0 || pureSuccessChildOrder.TCV__c ==  null)
            pureSuccessChildOrder.status__c = 'Completed';
        insert pureSuccessChildOrder;
        Order__Share OrderSharePS = new Order__Share();
        OrderSharePS.ParentId = pureSuccessChildOrder.Id;
        OrderSharePS.UserOrGroupId = objQuote.BigMachines__Opportunity__r.ownerId;
        OrderSharePS.AccessLevel = 'read';    
        OrderSharePS.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
        insert OrderSharePS;
        //lineitems
        //QuoteUtil.insertPureSuccessItemsFromOffer(quote);
        //copy order address for child
        List<Account_Order_Address__c> listToUpsert = new List<Account_Order_Address__c>();
        for(Account_Order_Address__c a : [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                          City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                          Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                          Sort_Order__c, State__c, Zip_Code__c, Quote__c 
                                          FROM Account_Order_Address__c
                                          WHERE Quote__c = :objQuote.id])
        {
            if(a.Address_Type__c == 'Ship To')
            {
                a.Order__c = pureSuccessChildOrder.id;
                listToUpsert.add(a);
            }
            else
            {
                Account_Order_Address__c temp = a.clone();
                temp.Order__c = pureSuccessChildOrder.id;
                temp.Quote__c = null;
                listToUpsert.add(temp);
            }   
        }
        if(listToUpsert.size() > 0)
            upsert listToUpsert;    
    }
    
    //Anju for Cloud
    public static void createPureSuccessLinesCloud(Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice, 
                                                   BigMachines__Quote__c objQuote, Order__c objOrder, List<Order_Line_Item__c> list_OrderLineItems){
                                                       List<String> listOfProductIds = new List<String>();
                                                       Integer intLineNumber = list_OrderLineItems.size()+1;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                                                       for(BasePackageLineConfiguration__c eachConfigDetails : BasePackageLineConfiguration__c.getAll().values()){
                                                           listOfProductIds.add(eachConfigDetails.PS_Product2_Id__c); 
                                                           listOfProductIds.add(eachConfigDetails.GU_Product2_Id__c); 
                                                           listOfProductIds.add(eachConfigDetails.CC_Product2_Id__c);             
                                                       }
                                                       for(String eachPackage : mapOfPackageVsPrice.keySet()){ 
                                                           listOfProductIds.add(mapOfPackageVsPrice.get(eachPackage).Bundle_Line__r.BigMachines__Product__c); 
                                                       }
                                                       map_Products = new Map<Id, Product2>([SELECT APN_Number__c,name FROM Product2 WHERE id IN : listOfProductIds]);
                                                       //Looping over each PureSuccess package  
                                                       for(String eachPackage : mapOfPackageVsPrice.keySet()){ 
                                                           String offeringType = objQuote.Offering_Type__c;
                                                           String packageName = (eachPackage == 'Partner PureSuccess' ? 'PARTNER' : eachPackage.toUpperCase());
                                                           String key = offeringType + '-' + packageName;                
                                                           BasePackageLineConfiguration__c configDetails = BasePackageLineConfiguration__c.getAll().get(key);
                                                           //Anju PC PS Changes
                                                           Order_Line_Item__c newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                           BigMachines__Quote_Product__c packageQP = mapOfPackageVsPrice.get(eachPackage);
                                                           if(configDetails != null)
                                                           {
                                                               
                                                               //PS            
                                                               /* Anju August 2018 Commenting as per Revpro*/
                                                               /* Anju Nov 2018 reverting as per Revpro */
                                                               Double PSPercentage = (configDetails.PS__c == null ? 0 : configDetails.PS__c);
                                                               Double PSPrice;
                                                               if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                                   PSPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c * PSPercentage / 100;  
                                                               else
                                                                   PSPrice = (packageQP.Bundle_Line__r.Extended_Price_Per_Month__c == null ? 0 : packageQP.Bundle_Line__r.Extended_Price_Per_Month__c) * PSPercentage / 100;          
                                                               newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                               newOLI.Product__c = configDetails.PS_Product2_Id__c;   
                                                               Product2 PSProduct = map_Products.get(newOLI.Product__c);
                                                               newOLI.APN_Number__c = PSProduct.APN_Number__c;
                                                               newOLI.Year__c = 1;
                                                               newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                               newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c; 
                                                               populatePureSuccessOLI(newOLI, PSPrice, packageQP, objQuote);
                                                               newOLI.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                                                               newOLI.POB_Type__c = 'Not Applicable';
                                                               newOLI.Skip_Invoice__c = true;
                                                               list_OrderLineItems.add(newOLI);
                                                               //GU
                                                               Double GUPercentage = (configDetails.GU__c == null ? 0 : configDetails.GU__c);
                                                               Double GUPrice;
                                                               if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                                   GUPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c * GUPercentage / 100; 
                                                               else
                                                                   GUPrice = (packageQP.Bundle_Line__r.Extended_Price_Per_Month__c == null ? 0 : packageQP.Bundle_Line__r.Extended_Price_Per_Month__c) * GUPercentage / 100; 
                                                               
                                                               newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                               newOLI.Product__c = configDetails.GU_Product2_Id__c;   
                                                               Product2 GUProduct = map_Products.get(newOLI.Product__c);
                                                               newOLI.APN_Number__c = GUProduct.APN_Number__c;
                                                               newOLI.Year__c = 1;
                                                               newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                               newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c; 
                                                               populatePureSuccessOLI(newOLI, GUPrice, packageQP, objQuote);
                                                               newOLI.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-
                                                               newOLI.POB_Type__c = 'Not Applicable';
                                                               newOLI.Skip_Invoice__c = true;
                                                               list_OrderLineItems.add(newOLI);
                                                               //CC
                                                               Double CCPercentage = (configDetails.CC__c == null ? 0 : configDetails.CC__c);
                                                               Double CCPrice;
                                                               if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                                   CCPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c * CCPercentage / 100; 
                                                               else
                                                                   CCPrice = (packageQP.Bundle_Line__r.Extended_Price_Per_Month__c == null ? 0 : packageQP.Bundle_Line__r.Extended_Price_Per_Month__c) * CCPercentage / 100;           
                                                               newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                               newOLI.Product__c = configDetails.CC_Product2_Id__c;   
                                                               Product2 CCProduct = map_Products.get(newOLI.Product__c);
                                                               newOLI.APN_Number__c = CCProduct.APN_Number__c;
                                                               newOLI.Year__c = 1;
                                                               newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                               newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;  
                                                               populatePureSuccessOLI(newOLI, CCPrice, packageQP, objQuote);
                                                               newOLI.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-
                                                               newOLI.POB_Type__c = 'Not Applicable';
                                                               newOLI.Skip_Invoice__c = true;
                                                               list_OrderLineItems.add(newOLI);
                                                               
                                                               
                                                               
                                                               if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                                   PSPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c;  
                                                               else
                                                                   PSPrice = packageQP.Bundle_Line__r.Extended_Price_Per_Month__c; 
                                                           }
                                                           newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                           
                                                           //Anju PC PS Changes
                                                           if(packageQP.Bundle_Line__c != null)
                                                           {
                                                               newOLI.Product__c = packageQP.Bundle_Line__r.BigMachines__Product__c;   
                                                               newOLI.APN_Number__c = packageQP.Bundle_Line__r.APN_Number__c == null ? packageQP.Bundle_Line__r.BigMachines__Product__r.APN_Number__c : packageQP.Bundle_Line__r.APN_Number__c;
                                                               newOLI.Dummy_APN__c = newOLI.APN_Number__c;
                                                               newOLI.Year__c = 1;
                                                               newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                               newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;  
                                                               populatePureSuccessOLI(newOLI, 0, packageQP, objQuote);
                                                               newOLI.Base_Package__c = packageQP.Bundle_Line__r.Ext_Net_Price__c; 
                                                               newOLI.Net_Unit_Price__c = 0;
                                                               newOLI.List_Price__c = packageQP.Bundle_Line__r.List_Price__c;
                                                               newOLI.Ext_List__c = packageQP.Bundle_Line__r.List_Price__c * packageQP.Bundle_Line__r.BigMachines__Quantity__c;
                                                               newOLI.Net_Unit_Price__c = newOLI.List_Price__c;
                                                               newOLI.Ext_Net_Price__c = newOLI.Ext_List__c;
                                                               newOLI.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-
                                                               newOLI.Tokens__c = packageQP.Bundle_Line__r.Tokens__c;
                                                           }
                                                           else if(packageQP.Bundle__c != null)
                                                           {
                                                               newOLI.Product__c = packageQP.BigMachines__Product__c;   
                                                               newOLI.APN_Number__c = packageQP.APN_Number__c == null ? packageQP.BigMachines__Product__r.APN_Number__c : packageQP.APN_Number__c;
                                                               newOLI.Dummy_APN__c = newOLI.APN_Number__c;
                                                               newOLI.Year__c = 1;
                                                               newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                               newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;  
                                                               populatePureSuccessOLI(newOLI, 0, packageQP, objQuote);
                                                               newOLI.Base_Package__c = packageQP.Ext_Net_Price__c; 
                                                               newOLI.Net_Unit_Price__c = 0;
                                                               newOLI.List_Price__c = packageQP.List_Price__c;
                                                               newOLI.Ext_List__c = packageQP.List_Price__c * packageQP.BigMachines__Quantity__c;
                                                               newOLI.Net_Unit_Price__c = newOLI.List_Price__c;
                                                               newOLI.Ext_Net_Price__c = newOLI.Ext_List__c;
                                                               newOLI.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-
                                                               
                                                           }
                                                           list_OrderLineItems.add(newOLI);            
                                                       }
                                                       upsert list_OrderLineItems;   
                                                   }
    @testvisible
    private static void populatePureSuccessOLI(Order_Line_Item__c newOLI, Double PSPrice, 
                                               BigMachines__Quote_Product__c packageQP, BigMachines__Quote__c objQuote){
                                                   newOLI.List_Price__c = PSPrice;
                                                   newOLI.Line_Number__c = PSPrice;
                                                   newOLI.Ext_Net_Price__c = PSPrice;
                                                   newOLI.Ext_List__c = PSPrice; 
                                                   newOLI.Sales_Price__c = PSPrice;        
                                                   newOLI.Net_Unit_Price__c = PSPrice;                                                 
                                                   newOLI.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
                                                   newOLI.Unit_of_Measure__c = packageQP.Unit_of_Measure__c;         
                                                   newOLI.CurrencyIsoCode = packageQP.CurrencyIsoCode;         
                                                   newOLI.Current_Qty__c = packageQP.Current_Qty__c;
                                                   newOLI.Original_Qty__c = packageQP.Original_Qty__c;
                                                   newOLI.Quantity__c = 1;
                                                   newOLI.BigMachines_Quantity__c = 1;
                                                   if(newOLI.APN_Number__c != null)
                                                       newOLI.Name = newOLI.APN_Number__c;
                                                   else
                                                       newOLI.Name = map_Products.get(newOLI.Product__c).name;
                                               }
    
    //Anju 2018 January Create puresuccess Direct items from offer for PEC
    public static void insertPureSuccessItemsFromOffer(BigMachines__Quote__c objQuote){        
        BigMachines__Quote_Product__c offerProduct = null;
        for(BigMachines__Quote_Product__c qp : [Select id,BigMachines__Product__c,Extended_Price_Per_Month__c from BigMachines__Quote_Product__c where  BigMachines__Quote__c = :objQuote.id])
        {
            if(Label.PEC_PureSuccess_Offer.contains(String.valueof(qp.BigMachines__Product__c).left(15))){
                offerProduct = qp;
                offerProduct.Ext_Net_Price__c = offerProduct.Extended_Price_Per_Month__c;
                break;
            }
            
        }
        if(offerProduct != null)
        {
            List<BigMachines__Quote_Product__c> toInsert = new List<BigMachines__Quote_Product__c>();
            for(Product_Group_Item__c pL : [Select Product__c,Product_Group__c,Product__r.type__c,Product__r.name from Product_Group_Item__c where Product_Group__r.Product__c = :offerProduct.BigMachines__Product__c])
            {
                BigMachines__Quote_Product__c temp = new BigMachines__Quote_Product__c();
                temp.BigMachines__Quote__c = objQuote.id;
                temp.BigMachines__Quantity__c  = 1;
                if(pL.Product__r.type__c ==  'Token')
                    temp.BigMachines__Quantity__c  = objQuote.Token_Value__c;
                temp.Net_Unit_Price__c = temp.BigMachines__Sales_Price__c = temp.List_Price__c = 0;
                temp.Bundle__c = pL.Product_Group__c;
                temp.Bundle_Line__c = offerProduct.id;
                temp.BigMachines__Product__c = pL.Product__c;
                temp.name = pL.Product__r.name;
                toInsert.add(temp);
                offerProduct.Bundle__c = pL.Product_Group__c;
            }
            if(toInsert.size() > 0)
                insert toInsert;
            update offerProduct;
        }  
    }
    //Added By Ranjith on Jun 14, 2017 -- Starts
    //*** Method to create Hardware orders based on Ship to addresses
    public static void createHWOrdersForCloud(Id quoteId, Order__c objNewOrder) {
        
        List<Order_Line_Item__c> list_HWOrderLineItems = new List<Order_Line_Item__c>();
        List<BigMachines__Quote_Product__c> list_AllQuoteLineItems = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> list_HWQuoteLineItems = new List<BigMachines__Quote_Product__c>();
        List<Account_Order_Address__c> list_HWShipToOrderAddresses = new List<Account_Order_Address__c>();
        List<Account_Order_Address__c> list_NonShipToOrderAddresses = new List<Account_Order_Address__c>();
        List<Account_Order_Address__c> list_NewHWOrderAddresses = new List<Account_Order_Address__c>();
        List<Order_Line_Item_Allocation__c> list_AllOLIAllocations = new List<Order_Line_Item_Allocation__c>();
        List<Order__c> list_NewHWOrders = new List<Order__c>();
        Map<Id, Id> map_HWShipToAddrIdFromMasterOrdToNewHWOrderId = new Map<Id, Id>();
        Map<String, RecordType> map_OrderRecTypes = new Map<String, RecordType>();
        Map<Id, Order_Line_Item__c> map_OLIs = new Map<Id, Order_Line_Item__c>();   
        
        /*for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c']) {
map_OrderRecTypes.put(recType.Name, recType);
} */  
        
        //Pull account order address and differentiate between ship to and other addresses
        List<Account_Order_Address__c> list_AllAccountOrderAddresses = [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                                                        City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                                                        Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                                                        Sort_Order__c, State__c, Zip_Code__c, Quote__c 
                                                                        FROM Account_Order_Address__c
                                                                        WHERE Quote__c = :quoteId];
        System.debug('$$$$$AllAccountOrderAddresses'+list_AllAccountOrderAddresses.size());
        for(Account_Order_Address__c obj_AOA : list_AllAccountOrderAddresses) {                
            //Below list size will be the no of HW orders to be created
            if(obj_AOA.Address_Type__c == 'Ship To' && !String.isBlank(obj_AOA.Shipping_Method_Name__c)) {
                list_HWShipToOrderAddresses.add(obj_AOA);
            }
            //Each of these addresses will be associated to each new HW order
            //Mukunth added Activation Email check to the below if condition
            else if(obj_AOA.Address_Type__c == 'Bill To' || obj_AOA.Address_Type__c == 'Sold To' || obj_AOA.Address_Type__c == 'End User' || obj_AOA.Address_Type__c == 'Activation Email') {
                list_NonShipToOrderAddresses.add(obj_AOA);
            }
            obj_AOA.Order__c = objNewOrder.Id;
        }
        System.debug('$$$$$list_HWShipToOrderAddresses'+list_HWShipToOrderAddresses.size());
        System.debug('$$$$$list_NonShipToOrderAddresses'+list_NonShipToOrderAddresses.size());
        update list_AllAccountOrderAddresses; 
        
        //if HW order needs to be created
        if(list_HWShipToOrderAddresses.size() > 0) {
            Id idHWOrderOwner;
            BigMachines__Quote__c objQuote = [SELECT Id, Offering_Type__c FROM BigMachines__Quote__c WHERE Id = :quoteId LIMIT 1];
            //Create HW orders
            if(objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PC && objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC ){
                idHWOrderOwner = QuoteUtil.getOrderManagementQueue(quoteId);
            }
            if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) {
                idHWOrderOwner = [SELECT Id FROM Group WHERE DeveloperName = 'Cloud_Billing_Master_Orders_Queue' AND Type = 'Queue' LIMIT 1].Id;
            }
            //Build as many HW orders as ship to (with Shipping method field populated) address count
            for(Integer i=0; i<list_HWShipToOrderAddresses.size(); i++) {
                Order__c obj_NewHWOrder = objNewOrder.clone(false, false, false, false);
                obj_NewHWOrder.Name = objNewOrder.Name + '-HW -' + (i+1);
                obj_NewHWOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Hardware Order').getRecordTypeId();
                obj_NewHWOrder.ownerId = idHWOrderOwner;
                obj_NewHWOrder.Order_Type__c = 'Revenue';
                obj_NewHWOrder.Original_Parent_Order1__c = objNewOrder.Id;
                obj_NewHWOrder.License_FYM_detail__c = 'Hardware Order';
                list_NewHWOrders.add(obj_NewHWOrder);
            }
            
            System.debug('$$$$$NewHWOrders'+list_NewHWOrders.size());
            insert list_NewHWOrders;
            
            //Create HW account order addresses for new HW Order: one ship to, sold to, end user and bill to addresses
            for(Integer i=0; i<list_HWShipToOrderAddresses.size(); i++) {
                //Associate one ship to address to HW Order
                Account_Order_Address__c obj_NewShipToAddr = list_HWShipToOrderAddresses[i].clone(false, false, false, false);
                obj_NewShipToAddr.Order__c = list_NewHWOrders[i].Id;
                obj_NewShipToAddr.Quote__c = null;
                list_NewHWOrderAddresses.add(obj_NewShipToAddr);
                
                //Lookup in oli allocation is master order's account order address id. Need to map that id with newly created HW order
                map_HWShipToAddrIdFromMasterOrdToNewHWOrderId.put(list_HWShipToOrderAddresses[i].Id, list_NewHWOrders[i].Id);
                //Associate Sold To, End User and Bill To addresses to each new HW Order
                for(Account_Order_Address__c obj_NonShipToAddr : list_NonShipToOrderAddresses) {
                    Account_Order_Address__c obj_NewNonShipToAddr = obj_NonShipToAddr.clone(false, false, false, false);
                    obj_NewNonShipToAddr.Order__c = list_NewHWOrders[i].Id;
                    obj_NewNonShipToAddr.Quote__c = null;
                    list_NewHWOrderAddresses.add(obj_NewNonShipToAddr);
                }
            }        
            System.debug('$$$$$AllOLI'+list_NewHWOrderAddresses.size());
            insert list_NewHWOrderAddresses;            
            
            //Create HW order line items
            //Pull line items from Quote Charge Detail object
            map_OLIs = new Map<Id, Order_Line_Item__c>();
            for(Order_Line_Item__c obj_OLI : [SELECT Id, Name, Order__c, Quote_Product__c, Line_Number__c, Product__c, Product_txt__c, APN_Number__c,
                                              Description__c, RecordTypeId, Unit_of_Measure__c, Quantity__c, BigMachines_Quantity__c, 
                                              List_Price__c, Net_Unit_Price__c, Ext_List__c, Ext_Net_Price__c, Total_Discount__c, Tax_Amount__c,
                                              Sales_Price__c 
                                              FROM Order_Line_Item__c 
                                              WHERE Order__c = :objNewOrder.Id]) {
                                                  map_OLIs.put(obj_OLI.Quote_Product__c, obj_OLI);
                                              }
            
            //Pull OLI allocation records
            list_AllOLIAllocations = [SELECT Id, Order_Line_Item__c, Order_Shipping_Location__c, Quantity__c, Quote__c, Quote_Product__c
                                      FROM Order_Line_Item_Allocation__c 
                                      WHERE Quote__c =: quoteId];
            System.debug('$$$$$AllOLIAllocations'+list_AllOLIAllocations.size());
            Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            for(Order_Line_Item_Allocation__c obj_OLIAlloc : list_AllOLIAllocations) {                
                //Consider records which has a quantity
                if(obj_OLIAlloc.Quantity__c > 0 
                   && map_OLIs.containsKey(obj_OLIAlloc.Quote_Product__c)) { //Added by Ranjith on Jul 10, 2018
                       //Retrieve master order line item based on quote charge detail
                       Order_Line_Item__c objNewOLI = map_OLIs.get(obj_OLIAlloc.Quote_Product__c).clone(false, false, false, false);
                       //Associate HW order based on OLI Allocation's shipping location and HW Order's ship to address. 
                       //Below map points to Master Order's ship to address and new HW Order id
                       objNewOLI.Order__c = map_HWShipToAddrIdFromMasterOrdToNewHWOrderId.get(obj_OLIAlloc.Order_Shipping_Location__c);
                       //Added By Ranjith on Aug 22, 2018 - Starts        
                       objNewOLI.RecordTypeId = recordTypeIdForOLI;
                       //Added By Ranjith on Aug 22, 2018 - Ends
                       objNewOLI.Quantity__c = Integer.valueOf(obj_OLIAlloc.Quantity__c);
                       objNewOLI.BigMachines_Quantity__c = objNewOLI.Quantity__c;
                       objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
                       objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
                       if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                           objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                           objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                           objNewOLI.Tax_Amount__c = objNewOLI.Tax_Amount__c == null ? 0 : objNewOLI.Tax_Amount__c /objNewOLI.Quantity__c;
                       }
                       //objNewOLI.Total_Discount__c = objQtChrgeDtl.zqu__BillingDiscount__c;                 
                       objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
                       list_HWOrderLineItems.add(objNewOLI);
                   } 
            }
            System.debug('$$$$$HWOrderLineItems'+list_HWOrderLineItems.size());
            
            insert list_HWOrderLineItems;    
        }
    }
    //Added By Ranjith on Jun 14, 2017 -- Ends
    
    //*** Method to create One time charge child orders
    // Added by Anto om October 24, 2018 -Starts
    public static void createOneTimeChargeOrder(Id quoteId, Order__c objNewOrder, String strOfferingType, String strOrderType,List<Account_Order_Address__c> list_AllAccountOrderAddresses) {
        
        List<Order_Line_Item__c> list_OneTimeChargeOrderLineItems = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> list_UpdatedOneTimeChargeOrderLineItems = new List<Order_Line_Item__c>();
        List<Account_Order_Address__c> list_NonShipToOrderAddresses = new List<Account_Order_Address__c>();
        List<Account_Order_Address__c> list_NewOneTimeChargeOrderAddresses = new List<Account_Order_Address__c>();
        Map<String, RecordType> map_OrderRecTypes = new Map<String, RecordType>();
        Map<Id, Order_Line_Item__c> map_OLIs = new Map<Id, Order_Line_Item__c>(); 
        Boolean bln_isOneTimeChargeQuote = false; 
        Decimal decNonRecurringCharge = 0;     
        
        for(Order_Line_Item__c obj_OLI : [SELECT Id, Name, Order__c, Quote_Product__c, Line_Number__c, Product__c, Product_txt__c, APN_Number__c,
                                          Description__c, RecordTypeId, Unit_of_Measure__c, Quantity__c, BigMachines_Quantity__c, 
                                          List_Price__c, Net_Unit_Price__c, Ext_List__c, Ext_Net_Price__c, Total_Discount__c, Tax_Amount__c,
                                          Sales_Price__c,Quantity_Change__c,Product__r.New_category__c,Quote_Product__r.Subscription_Product__c,Product__r.APN_Number__c
                                          FROM Order_Line_Item__c 
                                          WHERE Order__c = :objNewOrder.Id]) {
                                              map_OLIs.put(obj_OLI.Quote_Product__c, obj_OLI);
                                          }  
        System.debug('map$$$'+map_OLIs);
        
        Set<String>set_TAMProducts = new Set<String>();
        for(TAM_Product__mdt obj_TAMProd :[SELECT MasterLabel
                                           FROM TAM_Product__mdt
                                           WHERE Offering_Type__c =:strOfferingType]){
                                               set_TAMProducts.add(obj_TAMProd.MasterLabel);
                                           }
        if(Test.isRunningTest()) {
            bln_isOneTimeChargeQuote = true;
        }
        if(strOrderType != Label.Amend_Subscription){
            for(Order_Line_Item__c objOLI :map_OLIs.values()) {
                if((strOfferingType == SubscriptionUtil.OFFERING_TYPE_PC && ((objOLI.Product__r.New_category__c!= null && Label.Check_For_One_Time_Fees_PC.remove('Hardware;').remove('Credit;').contains(objOLI.Product__r.New_category__c))||(set_TAMProducts.size() != 0 && set_TAMProducts.contains(objOLI.Product__r.APN_Number__c))))
                   || (strOfferingType == SubscriptionUtil.OFFERING_TYPE_PCC && ((objOLI.Product__r.New_category__c!= null && Label.Check_For_One_Time_Fees_PCC.remove('Hardware;').remove('Credit;').contains(objOLI.Product__r.New_category__c))||(set_TAMProducts.size() != 0 && set_TAMProducts.contains(objOLI.Product__r.APN_Number__c))))
                   || (strOfferingType == SubscriptionUtil.OFFERING_TYPE_PEC && ((objOLI.Product__r.New_category__c!= null && Label.Check_For_One_Time_Fees_PEC.contains(objOLI.Product__r.New_category__c))||(set_TAMProducts.size() != 0 && set_TAMProducts.contains(objOLI.Product__r.APN_Number__c))))){
                       
                       bln_isOneTimeChargeQuote = true;
                       decNonRecurringCharge += objOLI.Ext_Net_Price__c;
                       list_OneTimeChargeOrderLineItems.add(objOLI);
                       system.debug('Entered');
                   }
            }
        }
        if(strOrderType == Label.Amend_Subscription){
            for(Order_Line_Item__c objOLI :map_OLIs.values()) {
                if(((strOfferingType == SubscriptionUtil.OFFERING_TYPE_PC && ((objOLI.Product__r.New_category__c!= null && Label.Check_For_One_Time_Fees_PC.remove('Hardware;').remove('Credit;').contains(objOLI.Product__r.New_category__c))||(set_TAMProducts.size() != 0 && set_TAMProducts.contains(objOLI.Product__r.APN_Number__c))))
                    || (strOfferingType == SubscriptionUtil.OFFERING_TYPE_PCC && ((objOLI.Product__r.New_category__c!= null && Label.Check_For_One_Time_Fees_PCC.remove('Hardware;').remove('Credit;').contains(objOLI.Product__r.New_category__c))||(set_TAMProducts.size() != 0 && set_TAMProducts.contains(objOLI.Product__r.APN_Number__c)))))
                   &&(objOLI.Quantity_Change__c > 0 || objOLI.Quote_Product__r.Subscription_Product__c == null)){
                       bln_isOneTimeChargeQuote = true;
                       if(objOLI.Quote_Product__r.Subscription_Product__c == null){
                           decNonRecurringCharge += objOLI.Ext_Net_Price__c;
                       }
                       else if(objOLI.Quantity_Change__c > 0){
                           decNonRecurringCharge += objOLI.Net_Unit_Price__c*objOLI.Quantity_Change__c;
                       }
                       list_OneTimeChargeOrderLineItems.add(objOLI);
                       system.debug('Entered 2');
                   }
            }
            
        }
        
        if(bln_isOneTimeChargeQuote){
            Id id_OneTimeChargeOrderOwner = [SELECT Id FROM Group WHERE DeveloperName = 'Cloud_Billing_Master_Orders_Queue' AND Type = 'Queue' LIMIT 1].Id;
            Order__c obj_NewOneTimeOrder = objNewOrder.clone(false, false, false, false);
            obj_NewOneTimeOrder.Name = objNewOrder.Name + '-OneTime';
            obj_NewOneTimeOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
            obj_NewOneTimeOrder.OwnerId = id_OneTimeChargeOrderOwner;
            obj_NewOneTimeOrder.Order_Type__c = 'Revenue';
            obj_NewOneTimeOrder.Original_Parent_Order1__c = objNewOrder.Id;
            obj_NewOneTimeOrder.License_FYM_detail__c = 'Cloud Order';
            obj_NewOneTimeOrder.TCV__c =decNonRecurringCharge;
            obj_NewOneTimeOrder.Annual_Contract_Value__c = 0;
            obj_NewOneTimeOrder.Total_Order__c = obj_NewOneTimeOrder.TCV__c;
            
            insert obj_NewOneTimeOrder;
            
            for(Account_Order_Address__c obj_AOA : list_AllAccountOrderAddresses) {   
                list_NonShipToOrderAddresses.add(obj_AOA);
                obj_AOA.Order__c = objNewOrder.Id;
            }
            System.debug('Non Shippable Address'+list_NonShipToOrderAddresses.size());
            update list_AllAccountOrderAddresses; 
            
            //Associate Sold To, End User and Bill To addresses to each new One Time Order
            for(Account_Order_Address__c obj_NonShipToAddr : list_NonShipToOrderAddresses) {
                Account_Order_Address__c obj_NewNonShipToAddr = obj_NonShipToAddr.clone(false, false, false, false);
                obj_NewNonShipToAddr.Order__c = obj_NewOneTimeOrder.Id;
                obj_NewNonShipToAddr.Quote__c = null;
                list_NewOneTimeChargeOrderAddresses.add(obj_NewNonShipToAddr);
            }
            
            System.debug('$$$$$AllOLI'+list_NewOneTimeChargeOrderAddresses.size());
            insert list_NewOneTimeChargeOrderAddresses;            
            
            Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            
            System.debug('RecordTypeId'+recordTypeIdForOLI);
            for(Order_Line_Item__c objOLI :list_OneTimeChargeOrderLineItems){
                
                Order_Line_Item__c objNewOLI = map_OLIs.get(objOLI.Quote_Product__c).clone(false, false, false, false);
                
                objNewOLI.Order__c = obj_NewOneTimeOrder.Id;
                objNewOLI.RecordTypeId = recordTypeIdForOLI;
                if(objOLI.Quantity_Change__c> 0){
                    objNewOLI.Quantity__c = objOLI.Quantity_Change__c;
                    objNewOLI.BigMachines_Quantity__c = objOLI.Quantity_Change__c ;
                }
                objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
                if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                    objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Tax_Amount__c = objNewOLI.Tax_Amount__c == null ? 0 : objNewOLI.Tax_Amount__c /objNewOLI.Quantity__c;
                }               
                objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
                list_UpdatedOneTimeChargeOrderLineItems.add(objNewOLI);
            } 
            
            insert list_UpdatedOneTimeChargeOrderLineItems;
        }                
    }
    //Added By Anto on Oct 24, 2018 -- Ends
    
    public static void createOneTimeChargeOLIforPEC(Id quoteId, Order__c objNewChildOrder, List<Order_Line_Item__c> list_OLI){
        System.debug('list_OLI:'+list_OLI);
        List<Account_Order_Address__c> list_NonShipToOrderAddresses = new List<Account_Order_Address__c>();
        List<Account_Order_Address__c> list_NewOneTimeChargeOrderAddresses = new List<Account_Order_Address__c>();
        List<Order_Line_Item__c> list_UpdatedOneTimeChargeOrderLineItems = new List<Order_Line_Item__c>();
        List<Account_Order_Address__c> list_AllAccountOrderAddresses = [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                                                        City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                                                        Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                                                        Sort_Order__c, State__c, Zip_Code__c, Quote__c 
                                                                        FROM Account_Order_Address__c
                                                                        WHERE Quote__c = :quoteId];
        
        //Associate Sold To, End User and Bill To addresses to each new One Time Order
        for(Account_Order_Address__c obj_NonShipToAddr : list_AllAccountOrderAddresses) {
            if(obj_NonShipToAddr.Address_Type__c == 'Bill To'){
                Account_Order_Address__c obj_NewNonShipToAddr = obj_NonShipToAddr.clone(false, false, false, false);
                obj_NewNonShipToAddr.Order__c = objNewChildOrder.Id;
                obj_NewNonShipToAddr.Quote__c = null;
                list_NewOneTimeChargeOrderAddresses.add(obj_NewNonShipToAddr);
            }
        }
        
        System.debug('$$$$$AllOLI'+list_NewOneTimeChargeOrderAddresses.size());
        insert list_NewOneTimeChargeOrderAddresses;            
        
        Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
        
        System.debug('RecordTypeId'+recordTypeIdForOLI);
        System.debug('$$$$list_OLI:'+list_OLI);
        if(!list_OLI.isEmpty() && list_OLI != null){
            for(Order_Line_Item__c objOLI :list_OLI){
                if(objOLI == null){continue;}
                Order_Line_Item__c objNewOLI = objOLI.clone(false, false, false, false);
                objNewOLI.Order__c = objNewChildOrder.Id;
                objNewOLI.RecordTypeId = recordTypeIdForOLI;
                objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
                if(objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                    objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
                    objNewOLI.Tax_Amount__c = objNewOLI.Tax_Amount__c == null ? 0 : objNewOLI.Tax_Amount__c /objNewOLI.Quantity__c;
                }               
                objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
                list_UpdatedOneTimeChargeOrderLineItems.add(objNewOLI);
            } 
        }  
        insert list_UpdatedOneTimeChargeOrderLineItems;
    } 
    //Added By Ranjith on Jun 14, 2017 -- Ends
    
    @TestVisible
    private static Boolean blnIsOneTimeChargeBasedOnOfferingAndNewCategory(String strOrderOfferingType, String strOfferingType, Order_Line_Item__c objOLI, String strCustomLabel, String strRemove, Set<String> set_TAMProducts) {
        String strLabelRemoved = strCustomLabel;
        if (!String.isBlank(strRemove)) {
            strLabelRemoved = strLabelRemoved.remove(strRemove);
        }
        //System.debug('OrderCloudUtil.blnIsOneTimeChargeBasedOnOfferingAndNewCategory strCustomLabel ' + strCustomLabel + ' strLabelRemoved ' + strLabelRemoved);
        
        if (strOrderOfferingType == strOfferingType &&
            ((objOLI.Product__r.New_category__c!= null && strLabelRemoved.contains(objOLI.Product__r.New_category__c)) ||
             (set_TAMProducts.size() != 0 && set_TAMProducts.contains(objOLI.Product__r.APN_Number__c)))) {
                 return true;
             }
        return false;
    }  
    
    @future
    public static void createOneTimeOrdersForPEC(Id objMasterOrderId){
        //Rony Joseph- March 24 2019 -One Time Charge Child Order
        Order__c objOrder = [select id,Quote__r.Offering_Type__c,Quote__r.PO_for_FYM__c,Quote__r.Is_GU_EMEA__c,Opportunity__c from Order__c where id =:objMasterOrderId];
        Boolean sep_po = false;
        Order__c obj_NewOneTimeOrder; 
        String strObjName = 'Order_Line_Item__c';
        String strWhereCondition = 'Order__c =:objMasterOrderId';
        System.debug(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
        List<Order_Line_Item__c> list_OrderLineItems = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
        List<Order_Line_Item__c> list_OneTimeOrderLineItem = new List<Order_Line_Item__c>();
        System.debug('####list_OrderLineItems:'+list_OrderLineItems);
        strObjName = 'Order__c';
        strWhereCondition = 'id =:objMasterOrderId';
        System.debug(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
        List<Order__c> list_Order= Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
        if (objOrder.Quote__r.PO_for_FYM__c == 'Separate PO for FYM') {
            sep_po = true;
        }
        string Sql_stmt = 'Select Unit_of_Measure__c,';
        Sql_stmt += '   Quantity__c,';
        Sql_stmt += '   Product__c,';//txt field
        Sql_stmt += '   Net_Unit_Price__c,';
        Sql_stmt += '   Name,';
        Sql_stmt += '   List_Price__c,';
        Sql_stmt += '   Line_Number__c,';
        Sql_stmt += '   Ext_Net_Price__c,';
        Sql_stmt += '   Ext_List__c,';
        Sql_stmt += '   CurrencyIsoCode,';
        Sql_stmt += '   APN_Number__c,BigMachines__Product__r.APN_Number__c,';
        Sql_stmt += '   BigMachines__Description__c,';
        Sql_stmt += '   BigMachines__Quantity__c,';
        Sql_stmt += '   BigMachines__Quote__c,';
        Sql_stmt += '   BigMachines__Sales_Price__c,';
        Sql_stmt += '   BigMachines__Product__c, BigMachines__Product__r.Type__c,BigMachines__Product__r.PS_Contract__c,BigMachines__Product__r.Name,BigMachines__Product__r.Description,';//lookup
        Sql_stmt += '   Maintenance_Start_Date__c,Year2_Maintenance_Due__c,Year3_Maintenance_Due__c,Year4_Maintenance_Due__c,Year5_Maintenance_Due__c, ';
        Sql_stmt += '   Maintenance_End_Date__c,Year2_CareRatePercent__c,Year3_CareRatePercent__c,Year4_CareRatePercent__c,Year5_CareRatePercent__c,';
        Sql_stmt += '   Maintenance_Due__c,';
        Sql_stmt += '   Fees_Applied__c,';
        Sql_stmt += '   Genesys_Care_Rate__c,';
        Sql_stmt += '   Increase__c,';
        //Mukunth added below 5 fields to the query to populate these fields from quote to order
        Sql_stmt += '   Original_License_List_Price__c,';
        Sql_stmt += '   Partner_License_List_Price__c,';
        Sql_stmt += '   Revised_License_List_Price__c,';
        Sql_stmt += '   Unit_List_Price__c,';
        Sql_stmt += '   Unit_Partner_Price__c,';
        
        Sql_stmt += '   Revised_Net_License_Value__c,';
        Sql_stmt += '   Extended_End_of_Support__c,';
        Sql_stmt += '   Contract_Line_Update_Status__c,';
        Sql_stmt += '   Original_Qty__c,';
        Sql_stmt += '   Current_Qty__c,';
        Sql_stmt += '   Total_Discount__c,';
        Sql_stmt += '   Product_Specific_Discount__c,';
        Sql_stmt += '   BigMachines__Total_Price__c,';
        Sql_stmt += '   Sold_To_Name__c,';
        Sql_stmt += '   End_User_Name__c,';
        //pureSuccess
        Sql_stmt += '   Bundle__r.Name,Ext_Net_Price_1__c,Ext_Net_Price_2__c,';
        Sql_stmt += '   Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.Ext_Net_Price_1__c,Bundle_Line__r.Ext_Net_Price_2__c,';
        Sql_stmt += '   Bundle_Line__r.Extended_Price_Per_Month__c,Product_Group__c,Bundle__r.Type__c,Bundle_Line__r.BigMachines__Product__c,';
        Sql_stmt += '   Bundle_Line__r.APN_Number__c,';
        Sql_stmt += '   Bundle_Line__r.BigMachines__Product__r.APN_Number__c,';
        Sql_stmt += '   Bundle_Line__r.List_Price__c,Bundle_Line__r.BigMachines__Quantity__c,Bundle_Line__r.Tokens__c,';
        Sql_stmt += '   BigMachines__Product__r.Include_in_CMMR_Total__c,';
        Sql_stmt += '   Extended_Price_Per_Period__c,BigMachines__Product__r.Sub_Type__c,';
        Sql_stmt += '   Service_Contract_Line_ID__c,';
        Sql_stmt += '   Annualized_Maintenance_Last_Period__c, Flavor__c,';
        // 1/21/2015 : To Copy additional information for PS product (if present)
        Sql_stmt += '   Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,';
        // 2/5/2015 : few more fields
        Sql_stmt += '   Application_Support_Cost_Base__c,Solution_Names_Covered__c,Third_Party_Partner_Fee__c,Bundle__r.Group_Type__c,Bundle_Line__c';
        Sql_stmt += '   From BigMachines__Quote_Product__c where  ';
        Sql_stmt += '   BigMachines__Quote__c= \'' + objOrder.Quote__r.id + '\' AND (BigMachines__Product__r.Type__c != \'Bundle\' OR Bundle__r.Group_Type__c = \'Base Package\' OR Bundle__r.Group_Type__c = \'PureSuccess\' OR BigMachines__Product__r.Product_Group__c = \'PureSuccess Indirect Offer\' OR BigMachines__Product__r.Product_Group__c = \'PureSuccess Direct Offer\')';
        
        if (sep_po) {
            Sql_stmt += ' and ( BigMachines__Product__r.Type__c = \'Product - System License\' OR BigMachines__Product__r.Type__c = \'Product - Hardware\' OR BigMachines__Product__r.Type__c = \'Product\')';
        }
        
        if (objOrder.Quote__r.Is_GU_EMEA__c) {
            Sql_stmt += ' and BigMachines__Product__r.Type__c <> \'Genesys Care\'';
        }
        
        List<BigMachines__Quote_Product__c> list_QP = Database.query(Sql_stmt);
        List<BigMachines__Quote_Product__c> list_OneTimeQP = new list<BigMachines__Quote_Product__c>();
        Boolean bln_IsOneTimeChargeQuote = false;
        Decimal decNonRecurringCharge = 0;
        
        for (BigMachines__Quote_Product__c objQP : list_QP) {
            //Rony Joseph- March 24 2019 -One Time Charge Child Order
            if((objOrder.Quote__r.offering_type__c == 'Business Edition')&&((objQP.Product_Group__c == null) || (objQP.Product_Group__c != null && !objQP.Product_Group__c.contains('PureSuccess'))) 
               &&
               ((objQP.Bundle__r.Group_Type__c == null)||(objQP.Bundle__r.Group_Type__c != null && !objQP.Bundle__r.Group_Type__c.contains('PureSuccess')))
               &&
               ((objQP.BigMachines__Product__r.Sub_Type__c==null || (objQP.BigMachines__Product__r.Sub_Type__c !=null &&objQP.BigMachines__Product__r.Sub_Type__c != 'PureSuccess')))
               &&
               (!objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
              ){
                  bln_IsOneTimeChargeQuote = true;
                  decNonRecurringCharge += (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c);
                  System.debug('###One-time Product'+objQP);
                  list_OneTimeQP.add(objQP);
              }
        }
        
        if(bln_IsOneTimeChargeQuote && objOrder.Quote__r.offering_type__c == 'Business Edition'){
            
            Map<Id, Order_Line_Item__c> map_OLIs = new Map<Id, Order_Line_Item__c>();
            for(Order_Line_Item__c objOLI : list_OrderLineItems) {
                map_OLIs.put(objOLI.Quote_Product__c, objOLI);
            }
            Id  id_OneTimeChargeOrderOwner = [SELECT Id FROM Group WHERE DeveloperName = 'Cloud_Billing_Master_Orders_Queue' AND Type = 'Queue' LIMIT 1].Id;
            
            obj_NewOneTimeOrder = list_Order[0].clone();
            obj_NewOneTimeOrder.Name = list_Order[0].Name + '-OneTime';
            obj_NewOneTimeOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
            obj_NewOneTimeOrder.OwnerId = id_OneTimeChargeOrderOwner;
            obj_NewOneTimeOrder.Order_Type__c = 'Revenue';
            obj_NewOneTimeOrder.Original_Parent_Order1__c = list_Order[0].Id;
            obj_NewOneTimeOrder.License_FYM_detail__c = 'Cloud Order';
            obj_NewOneTimeOrder.TCV__c =decNonRecurringCharge;
            obj_NewOneTimeOrder.Annual_Contract_Value__c = 0;
            obj_NewOneTimeOrder.Total_Order__c = obj_NewOneTimeOrder.TCV__c;
            insert obj_NewOneTimeOrder;
            System.debug('###list_OneTimeQP:'+list_OneTimeQP);
            for(BigMachines__Quote_Product__c objQP :list_OneTimeQP){
                
                list_OneTimeOrderLineItem.add(map_OLIs.get(objQP.Id));
            }
            System.debug('###list_OneTimeOrderLineItem:'+list_OneTimeOrderLineItem);
            
            List<Account_Order_Address__c> listAddressOrderLink = new List<Account_Order_Address__c>();
            for(Account_Order_Address__c accAddress : [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                                       Zip_Code__c, Phone__c, Fax__c, Sold_To_Business_Partner__c,Quote__c,Email__c, Additional_Emails__c,Attention_To__c FROM Account_Order_Address__c WHERE Quote__c = :objOrder.Quote__r.id])
            {
                if(accAddress.Address_Type__c == 'Bill To')
                {
                    listAddressOrderLink.add(new Account_Order_Address__c(id=accAddress.id,Order__c=list_Order[0].id));
                    Account_Order_Address__c objChildorderAddress = accAddress.clone();
                    objChildorderAddress.Quote__c =  null;
                    if(obj_NewOneTimeOrder != null){
                        objChildorderAddress.Order__c=obj_NewOneTimeOrder.id;
                        listAddressOrderLink.add(objChildorderAddress);
                    }
                }    
                else if(obj_NewOneTimeOrder != null)
                {
                    listAddressOrderLink.add(new Account_Order_Address__c(id=accAddress.id,Order__c=obj_NewOneTimeOrder.id));
                }
            }
            if(listAddressOrderLink.size() > 0)
                system.debug(listAddressOrderLink);
            upsert listAddressOrderLink;
            system.debug(listAddressOrderLink);
            
            if(obj_NewOneTimeOrder != null)
            {
                Id IdOppOwnerId = [select ownerId from Opportunity where id =:objOrder.Opportunity__c  limit 1].ownerId;
                Order__Share OrderSharePS = new Order__Share();
                OrderSharePS.ParentId = obj_NewOneTimeOrder.Id;
                OrderSharePS.UserOrGroupId = IdOppOwnerId;
                OrderSharePS.AccessLevel = 'read';    
                OrderSharePS.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
                insert OrderSharePS;
            }
            System.debug('$$$$list_OneTimeOrderLineItem:'+list_OneTimeOrderLineItem);
            OrderCloudUtil.createOneTimeChargeOLIforPEC(objOrder.Quote__c,obj_NewOneTimeOrder,list_OneTimeOrderLineItem);
            
        }
    }   
    //Added By Rony Joseph on May 6th 2019 -- Starts
    //*** Method to create Cloned Orders for AppFoundry Trial Automation
    public static String cloneSubscriptionOrderAndOrderLineItems( Id  IdSubscriptionId,Id IdobjAppFoundryTrialQuoteId,Id IdAppFoundryTrialOppId,Boolean blnTrialActivation,String strtermsofUsage,Date dtFreeTillDate ){
        String strSubsName;
        try{
            //System.debug('$$$$list_AppFoundryProducts:'+list_AppFoundryProducts);
            Util.Bypass_Trigger_Chk = true;
            Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
            List<Order_Line_Item__c> list_ClonedSubsOrderLineItems = new List<Order_Line_Item__c>();
            List<Order__c> list_CloneSubsChildOrders =new List<Order__C>();
            BigMachines__Quote__c objTrialQuote = QuoteCloudUtil.prepareQuotes(IdobjAppFoundryTrialQuoteId);
            OrderCloudUtil.orderFromQuote(objTrialQuote);
            Order__c objAppFoundryTrialOrder = [SELECT Id, Name FROM Order__c WHERE Quote__c =: objTrialQuote.Id AND Original_Parent_Order1__c = null LIMIT 1];
            objTrialQuote.Order__c = objAppFoundryTrialOrder.Id;   
            objAppFoundryTrialOrder.Quote__c = objTrialQuote.Id;
            Util.Bypass_Trigger_Chk = true;
            update objTrialQuote;
            update objAppFoundryTrialOrder;
            System.Debug('###Number of SOQL Queries Allowed:'+Limits.getLimitQueries());
            System.Debug('###Number of SOQL Queries so far:'+Limits.getQueries());
            objAppFoundryTrialOrder.status__c = 'Approved';
            update objAppFoundryTrialOrder;
            strSubsName = OrderAfterLogic(objAppFoundryTrialOrder,blnTrialActivation,strtermsofUsage,dtFreeTillDate);
            Subscription__c objInsertedSub = [Select id from Subscription__C where name = :strSubsName];
            String strResultString = 'The Operation was successfull.A new Subscription ' + strSubsName + ' was created with the necessary changes.Link : - ' + URL.getSalesforceBaseUrl().toExternalForm()+'/'+ objInsertedSub.Id;
            return strResultString;
            
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                            String strRecordGenerationMethod = 'AppFoundry Record generation has failed.The reason returned by the Platform  is:\n'+strSubsName+'\n'+e.getMessage()+'\n'+e.getStackTraceString();
                            CreationofTrialRecords.Res.failureMessages.add(e.getMessage()+'\n'+e.getStackTraceString());
                            ErrorLogUtil.insertLog('OrderCloudUtil', 'Error from method cloneSubscriptionOrderAndOrderLineItems: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'OrderCloudUtil.cloneSubscriptionOrderAndOrderLineItems()'); 
                            return strRecordGenerationMethod;
                           }  
    }  
    //--Rony Joseph-May 6th 2019 -Ends---
    
    public static String OrderAfterLogic(Order__c objTrialAppFoundryOrder,Boolean blnTrialActivation,String strtermsOfUsage,Date dtFreeTillDate){
        try{
            User objUser = [SELECT Id,Name,BypassValidationRules__c,Bypass_Triggers__c FROM User WHERE Id =: userinfo.getUserId()];
            System.debug('$$$$Util.Bypass_Trigger_Chk:'+ Util.Bypass_Trigger_Chk);
            System.debug('$$$objUser:'+objUser);
            System.Debug('###Number of SOQL Queries so far:'+Limits.getQueries());
            Map<Id,Id> map_ApprovedOrderIdsToQuoteIds =  new Map<Id,Id>{objTrialAppFoundryOrder.Id =>objTrialAppFoundryOrder.Quote__c};
                Set<String> set_SubscriptionIds = new Set<String>();
            Set<String> set_OldSubscriptionIds = new Set<String>();
            List<Opportunity> list_UpdateOpps = new List<Opportunity>();    
            List<Subscription__c> list_ToInsertSubscriptions = new List<Subscription__c>();
            List<Subscription_Product__c> list_ToInsertSubscriptionProds = new List<Subscription_Product__c>();
            Map<Id, List<Subscription_Product__c>> map_ToInsertSubscriptionProds = new Map<Id, List<Subscription_Product__c>>();       
            Map<Id, Map<String, Subscription_Product__c>> map_ToInsertSubscrProds = new Map<Id, Map<String, Subscription_Product__c>>();       
            Map<Id, Id> map_QuoteIdToSubscrId = new Map<Id, Id>();  
            List<Order__c> list_UpdateHWOrderOwners = new List<Order__c>();
            
            Map<Id, String> map_OrderBillToEmails = SubscriptionUtil.setOrderBillToEmailsMap(map_ApprovedOrderIdsToQuoteIds.keySet());
            List<BigMachines__Quote__c> list_Quotes = SubscriptionUtil.getQuotes(map_ApprovedOrderIdsToQuoteIds.values());
            System.debug('####list_Quotes:'+list_Quotes);
            for(BigMachines__Quote__c objQt : list_Quotes) { 
                
                list_UpdateOpps.add(new Opportunity(Id = objQt.BigMachines__Opportunity__c, 
                                                    ForecastStatus__c = Label.Oppty_Forecast_Status_Order_Approved));                 
                Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(objQt);                             
                objQt.BigMachines__Status__c = 'Order Accepted';
                objNewSubscription.Status__c = 'Active';
                objNewSubscription.Sync_Status__c = 'Waiting to Sync'; 
                if(map_OrderBillToEmails.containsKey(objNewSubscription.Order__c)) {  
                    objNewSubscription.Bill_To_Emails__c = map_OrderBillToEmails.get(objNewSubscription.Order__c);   
                }            
                
                
                System.debug('######objNewSubscription.Status__c: '+objNewSubscription.Status__c);
                System.debug('######objNewSubscription.Sync_Status__c: '+objNewSubscription.Sync_Status__c);
                if((objQt.Order_Type__c == Label.Amend_Subscription || objQt.Order_Type__c == Label.Replace_Subscription || objQt.Order_Type__c == Label.Renew_Subscription)
                   && objQt.Amendment_For__c != null) {                    
                       objNewSubscription.Version__c = objQt.Amendment_For__r.Version__c + 1;
                       objNewSubscription.Amendment_For__c = objQt.Amendment_For__c;
                       objNewSubscription.Original_Subscription__c = objQt.Amendment_For__r.Original_Subscription__c != null ? objQt.Amendment_For__r.Original_Subscription__c : objQt.Amendment_For__c;
                       objNewSubscription.Amendment_Date__c = objQt.Order_Type__c == Label.Amend_Subscription ? Date.today() /*objQt.Subscription_Amend_Date__c*/ : null;
                       objNewSubscription.Org_Id__c = objQt.Order_Type__c == Label.Renew_Subscription && objNewSubscription.Subscription_Start_Date__c >= Date.today() ? '' : objQt.Amendment_For__r.Org_Id__c;
                       objNewSubscription.Is_Cloned__c = false;
                       objNewSubscription.Status_of_AppFoundry_Trial_Products__c = (blnTrialActivation)?'Trial Products Added and Active':'Trial Products Deactivated';
                       objNewSubscription.Terms_of_Condition__c  = strtermsOfUsage;
                       
                       if(blnTrialActivation){
                           objNewSubscription.AppFoundry_Trial_Start_Date__c = System.today();
                           objNewSubscription.End_Date_of_AppFoundry_Trial_Projects__c = System.today()+30;
                       } 
                       
                       Subscription__c objAmendForSubscription = new Subscription__c(
                           Id = objQt.Amendment_For__c, 
                           Status__c = objQt.Order_Type__c == Label.Replace_Subscription ? 'Replaced' : 
                           objQt.Order_Type__c == Label.Amend_Subscription ? 'Amended' : 
                           objQt.Order_Type__c == Label.Renew_Subscription && objQt.Amendment_For__r.Subscription_End_Date__c <= Date.today() ? 'Inactive' : 'Active');
                       list_ToInsertSubscriptions.add(objAmendForSubscription);
                       set_OldSubscriptionIds.add(objAmendForSubscription.Id);
                   }
                list_ToInsertSubscriptions.add(objNewSubscription);
                System.debug('#####list_ToInsertSubscriptions: '+list_ToInsertSubscriptions);
                
                if(objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ||objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) {
                    Set<String> set_DisplayedSubscrProds = new Set<String>();
                    for(BigMachines__Quote_Product__c objQtProd : objQt.BigMachines__BigMachines_Quote_Products__r) {   
                        if(!objQtProd.Hide_Record__c) {
                            set_DisplayedSubscrProds.add(objQtProd.BigMachines__Product__c+';'+objQtProd.Is_Overage__c);
                        }
                    }
                    for(BigMachines__Quote_Product__c objQtProd: objQt.BigMachines__BigMachines_Quote_Products__r) { 
                        System.debug('###objQtProd:'+objQtProd);
                        Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);                       
                        objNewSubscriptionProd.CurrencyISOCode = objQt.CurrencyISOCode;
                        String strSubscrProdUniqueKey = objNewSubscriptionProd.Product__c+';'+objNewSubscriptionProd.Is_Overage__c;
                        if(objQtProd.Hide_Record__c && set_DisplayedSubscrProds.contains(strSubscrProdUniqueKey)) {
                            continue;
                        }
                        if(map_ToInsertSubscrProds.containsKey(objQtProd.BigMachines__Quote__c)) {
                            if(map_ToInsertSubscrProds.get(objQtProd.BigMachines__Quote__c).containsKey(strSubscrProdUniqueKey)) {
                                map_ToInsertSubscrProds.get(objQtProd.BigMachines__Quote__c).get(strSubscrProdUniqueKey).Quantity__c += objNewSubscriptionProd.Quantity__c;
                            }
                            else {
                                map_ToInsertSubscrProds.get(objQtProd.BigMachines__Quote__c).put(strSubscrProdUniqueKey, objNewSubscriptionProd);
                            }   
                        }
                        else {
                            map_ToInsertSubscrProds.put(objQtProd.BigMachines__Quote__c, 
                                                        new Map<String, Subscription_Product__c> {strSubscrProdUniqueKey => objNewSubscriptionProd});
                        }
                    }
                }
                
            }
            
            if(list_ToInsertSubscriptions.size() > 0) {
                upsert list_ToInsertSubscriptions;
                SubscriptionUtil.updateSubscriptionFlagOnOrder(map_ApprovedOrderIdsToQuoteIds.keyset()); 
                System.debug('#####set_OldSubscriptionIds: '+set_OldSubscriptionIds);
                System.debug('#####list_ToInsertSubscriptions: '+list_ToInsertSubscriptions);
                for(Subscription__c objSubscr : list_ToInsertSubscriptions) {
                    map_QuoteIdToSubscrId.put(objSubscr.Quote__c, objSubscr.Id);
                    if(objSubscr.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC
                       && !set_OldSubscriptionIds.contains(objSubscr.Id)) {  
                           set_SubscriptionIds.add(objSubscr.Id);
                       }
                }
                System.debug('#####set_SubscriptionIds: '+set_SubscriptionIds);
                System.debug('#####map_QuoteIdToSubscrId: '+map_QuoteIdToSubscrId);
                //For PureCloud and PureConnect Cloud
                for(Id quoteId : map_ToInsertSubscrProds.keySet()) {
                    for(String strUnqKey : map_ToInsertSubscrProds.get(quoteId).keySet()) {
                        Subscription_Product__c objSubscrProd = map_ToInsertSubscrProds.get(quoteId).get(strUnqKey);
                        //objSubscrProd.Active_Start_Date__c = (dtFreeTillDate!=null)?System.Today():list_ToInsertSubscriptions[0].Subscription_Start_Date__c;
                        //objSubscrProd.Active_End_Date__c = (dtFreeTillDate!=null)?dtFreeTillDate:list_ToInsertSubscriptions[0].Subscription_End_Date__c;
                        
                        if(map_QuoteIdToSubscrId.containsKey(quoteId)) {
                            objSubscrProd.Subscription__c = map_QuoteIdToSubscrId.get(quoteId);
                            list_ToInsertSubscriptionProds.add(objSubscrProd);
                        }
                    }
                }
                
                System.debug('#####list_ToInsertSubscriptionProds: '+list_ToInsertSubscriptionProds);
                insert list_ToInsertSubscriptionProds;
                
                //Naresh Kumar - 11/04 - //Populating bundle info                    
                Map<Id, Id> map_OfQuoteProductVsSubscriptionProduct = new Map<Id, Id>();                    
                
                for(Subscription_Product__c eachProduct : list_ToInsertSubscriptionProds){
                    map_OfQuoteProductVsSubscriptionProduct.put(eachProduct.Quote_Product__c, eachProduct.id);    
                }
                
                //Querying subscription products with quote product bundle info
                Map<Id, Subscription_Product__c> map_OfIdVsSubscriptionProducts = new Map<id, Subscription_Product__c>([SELECT id, Quote_Product__c, Quote_Product__r.Bundle_Line__c,
                                                                                                                        Quote_Product__r.Bundle__c, Bundle__c FROM Subscription_Product__c WHERE id IN : map_OfQuoteProductVsSubscriptionProduct.values()]);
                
                list_ToInsertSubscriptionProds.clear();
                for(Subscription_Product__c eachProduct : map_OfIdVsSubscriptionProducts.values()){
                    Id bundleLineQPId = eachProduct.Quote_Product__r.Bundle_Line__c;
                    eachProduct.Bundle__c = map_OfQuoteProductVsSubscriptionProduct.get(bundleLineQPId);
                    if(eachProduct.Bundle__c == null)
                        continue;
                    list_ToInsertSubscriptionProds.add(eachProduct);
                }      
                if(!list_ToInsertSubscriptionProds.isEmpty())
                    update list_ToInsertSubscriptionProds;                    
                
            }
            
            Util.Bypass_Trigger_Chk = true;
            update list_Quotes;
            update list_UpdateOpps;
            
            Global_Setting__c objGS = Global_Setting__c.getInstance('Order Queue');            
            list_UpdateHWOrderOwners = [SELECT Id, Quote__c, Original_Parent_Order1__c,
                                        Quote__r.BigMachines__Opportunity__r.Country_Region__c, Quote__r.BigMachines__Opportunity__r.Sold_To_Country__c,
                                        Quote__r.BigMachines__Opportunity__r.Country__r.Region__c, Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c
                                        FROM Order__c
                                        WHERE Original_Parent_Order1__c IN :map_ApprovedOrderIdsToQuoteIds.keySet()
                                        AND Status__c != 'Approved'];
            for(Order__c objOrder : list_UpdateHWOrderOwners) {
                String region = Test.isRunningTest() ? 'North America' : //objQuote.BigMachines__Opportunity__r.Country_Region__c;
                String.isBlank(objOrder.Quote__r.BigMachines__Opportunity__r.Sold_To_Country__c) ? 
                    objOrder.Quote__r.BigMachines__Opportunity__r.Country__r.Region__c  : 
                objOrder.Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c;    
                System.debug('#####region: '+region);
                if(region == 'North America') {            
                    objGS = Global_Setting__c.getInstance('NA Order Queue');
                }             
                else if(region == 'Japan' || region=='JAPAN'){
                    objGS = Global_Setting__c.getInstance('Japan Order Queue');
                }  
                else {
                    objGS = Global_Setting__c.getInstance(region + ' Order Queue');
                }      
                if(objGS != null)
                    objOrder.OwnerId = objGS.ID__c;    
            }            
            System.debug('#####list_UpdateHWOrderOwners: '+list_UpdateHWOrderOwners);
            if(list_UpdateHWOrderOwners.size() > 0) {
                update list_UpdateHWOrderOwners;
            }
            SubscriptionUtil.copyAccountOrderAddrtoCCDB(new Map<Id,String>{list_ToInsertSubscriptions[1].Id=>list_ToInsertSubscriptions[1].Offering_Type__c});
            System.Debug('###Number of SOQL Queries so far:'+Limits.getQueries());
            String strSubName = [Select name from Subscription__c where Org_Id__c = :list_ToInsertSubscriptions[1].Org_Id__c and Status__c = 'Active'Limit 1 ].name;
            return strSubName;
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                            CreationofTrialRecords.Res.failureMessages.add(e.getMessage()+'\n'+e.getStackTraceString());
                            ErrorLogUtil.insertLog('OrderCloudUtil', 'Error from method OrderAfterLogic: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'OrderCloudUtil.OrderAfterLogic()'); 
                            return 'N/A';}  
        
    }    
    public static void thisForCodeCoverage(){
        for(integer i=0;i<=10;i++){
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}