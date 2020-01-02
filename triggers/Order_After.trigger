/************************************************************************************
Purpose : Trigger to handle order update and approval, subscription creation etc 
Written By : IT
Test Classes : Order_AfterTest
*************************************************************************************/

/*
This logic is taken care of in Order_Before trigger
*/
trigger Order_After on Order__c (after update, after insert) 
{
    if(Util.Bypass_Trigger_Chk)return;   
    //Skipping revenue orders
    if(OrderUtil.isNonRevenueOrder(Trigger.new))
    {
        if(Trigger.isInsert){
            Order__Share OrderShare = new Order__Share();
            OrderShare.ParentId = Trigger.new[0].id;
            OrderShare.UserOrGroupId = Trigger.new[0].createdbyid;
            OrderShare.AccessLevel = 'read';
            
            OrderShare.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
            insert OrderShare;
            
        }
        NonRevenueOrderHandler.createServiceContractForNRO(Trigger.newMap, Trigger.oldMap);
        System.debug('Entering Here 1 >>>>>>>');
        if(Trigger.isUpdate){
            System.debug('Entering Here 1 Insidde Update>>>>>>>');
            NonRevenueOrderHandler.updateServiceContractsAndLineItems(Trigger.newMap, Trigger.oldMap);
            if(Trigger.isAfter && Trigger.isUpdate){ //Added by Ankit on 3/11/2019 for the revpro
                OrderUtil.populatesFieldsOnOrderLineItems(Trigger.newMap, Trigger.oldMap);            
            }
        }
        return;
    }
    if(Trigger.isInsert){
        
        //QuoteFieldMappings.populateAccountInfoFields(Trigger.new);
        //Commented by Ankit on 4/25/2013
        //Uncommented by Naresh 05/02/2013, I have changed inner functions. 
        QuoteFieldMappings.populateFieldsOnOrderInsertUpdate(Trigger.new, null);   
        SendEmailNotificationForPSSC.sendEmailAlert(trigger.new, null, false);
    }
    
    //Added by navaneetha for order created date updated to opportunity closedate.
    /*
    if(Trigger.isInsert && Trigger.isAfter) {  
        system.debug('TEstnavanee'+ 'ABC1');
        OrderTriggerHandler.updateopportunityclosedate(trigger.new, Trigger.newmap);   
    }
    */
    // Navaneetha Code Ended.

    //Naresh Kumar   6/24/2013
    if(Trigger.isAfter && Trigger.isUpdate){
        OrderUtil.populatesFieldsOnOrderLineItems(Trigger.newMap, Trigger.oldMap);            
    }
    //Naresh Kumar 05/23/2019
    OrderUtil.sendAcknowledgeEmail(Trigger.newMap, Trigger.oldMap);
    
    // Update Line Items on Every Order Update(Not a good solution needs to be revised)
    System.debug('NKC debug order ownerId  = ' + Trigger.new[0].ownerId);
    if(trigger.isUpdate && TriggerFlowManager.ORDER_AFTER_ACCOUNT_INFO_POPULATION){
        TriggerFlowManager.ORDER_AFTER_ACCOUNT_INFO_POPULATION = false;
        //QuoteFieldMappings.populateAccountInfoFields(Trigger.new);
    }
    if(trigger.isUpdate && TriggerFlowManager.ORDER_AFTER_SCLINES_POPULATE){
        QuoteFieldMappings.populateFieldsOnOrderInsertUpdate(Trigger.new, Trigger.oldMap);  
    }
    if(trigger.isUpdate){// && TriggerFlowManager.ORDER_AFTER_SC_FIELDS_UPDATION){
        QuoteFieldMappings.updateFieldsOnServiceContractOnOrderUpdate(trigger.new, trigger.oldMap);
        if(TriggerFlowManager.INVOICE_INFO_UPDATE){
            QuoteFieldMappings.populateInvoiceInfoOnSCLineItems(trigger.newMap, trigger.oldMap);
            TriggerFlowManager.INVOICE_INFO_UPDATE = false;
        }
        SendEmailNotificationForPSSC.sendEmailAlert(trigger.new, trigger.oldMap, false);
    }
    if(trigger.isUpdate && TriggerFlowManager.ORDER_AFTER_UPDATE_TRIGGER) { 
        
        //Commented by Ankit on 4/25/2013 
        //QuoteFieldMappings.updateOpportunitiesStatusOnUpdate(Trigger.new, Trigger.old);
        
        
        QuoteFieldMappings.populateOrder(Trigger.new, Trigger.old);
        AccountUpdateOrder.updateAccount(Trigger.newmap, Trigger.oldmap);
        
        //Naresh Kumar  02/04/2014 QuoteSplitDrop existing code is not handling bulk records that's why passing single record.
        if(Trigger.new[0].RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId)
            QuoteSplitDrop.createRetired(Trigger.new[0], Trigger.old[0]);
        
        //Added By Ranjith on Jul 06, 2017 -- Starts
        //Logic to update child peer orders, parent order and quote to Rejected if child order status is changed to Rejected
        Set<Id> set_BMQuoteIds = new Set<Id>();
        Set<Id> set_ZuoraQuoteIds = new Set<Id>();
        List<Order__c> list_UpdateHWOrderOwners = new List<Order__c>();
        Map<Id, Id> map_ApprovedOrderIdsToQuoteIds = new Map<Id, Id>();
        Map<Id, Order__c> map_ParentToChildOrders = new Map<Id, Order__c>();
        
        for(Order__c objOrder : Trigger.new) {
            if(objOrder.status__c == 'Rejected' && objOrder.status__c != Trigger.oldMap.get(objOrder.Id).status__c) {                   
                if(objOrder.Original_Parent_Order1__c != null) {
                    map_ParentToChildOrders.put(objOrder.Original_Parent_Order1__c, objOrder);
                }
                else {
                    map_ParentToChildOrders.put(objOrder.Id, objOrder);
                }
            }
            System.debug('####objOrder.Offering_Type__c: '+ objOrder.Offering_Type__c);
            System.debug('####objOrder.Quote__c : '+ objOrder.Quote__c );
            System.debug('####objOrder.status__c : '+ objOrder.status__c );
            System.debug('####Trigger.oldMap.get(objOrder.Id).status__c : '+ Trigger.oldMap.get(objOrder.Id).status__c);
            System.debug('####objOrder.Original_Parent_Order1__c : '+ objOrder.Original_Parent_Order1__c );
            
           if((objOrder.Offering_Type__c == 'PureEngage Subscription' || objOrder.Offering_Type__c == 'PureConnect Subscription')  
              && objOrder.Quote__c != null
               && ((objOrder.status__c == 'Completed' && objOrder.status__c != Trigger.oldMap.get(objOrder.Id).status__c && objOrder.Generate_Subscription_Record__c) || (objOrder.Generate_Subscription_Record__c && objOrder.Generate_Subscription_Record__c != Trigger.oldMap.get(objOrder.Id).Generate_Subscription_Record__c))
               && objOrder.Original_Parent_Order1__c == null) {
                   map_ApprovedOrderIdsToQuoteIds.put(objOrder.Id, objOrder.Quote__c);
            }
            //Remove below if condition and add PEC check to below main if condition once PEC is moved to subscription model.
            if(objOrder.Order_Category__c == 'PureEngage-Cloud Order' && objOrder.Quote__c != null
               && (objOrder.status__c == 'Completed' || objOrder.status__c == 'Approved') && objOrder.status__c != Trigger.oldMap.get(objOrder.Id).status__c
               && objOrder.Original_Parent_Order1__c == null) {
                system.debug('Inside PEC');
                map_ApprovedOrderIdsToQuoteIds.put(objOrder.Id, objOrder.Quote__c);
            }
            //Anju July 2018 PCC Subscriptions
            if((objOrder.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objOrder.Order_Category__c == 'PureConnect-Cloud Order' || objOrder.Order_Category__c == 'PureEngage-Cloud Order') && objOrder.Quote__c != null
               && (objOrder.status__c == 'Completed' || objOrder.status__c == 'Approved') && objOrder.status__c != Trigger.oldMap.get(objOrder.Id).status__c
               && objOrder.Original_Parent_Order1__c == null) {
                map_ApprovedOrderIdsToQuoteIds.put(objOrder.Id, objOrder.Quote__c);
            }
        }
        if(map_ParentToChildOrders.size() > 0) {
            List<Order__c> list_UpdateOrderStatus = [SELECT Id, status__c, Zuora_Quote__c, Quote__c, Original_Parent_Order1__c, Reject_Reasons__c
                                                     FROM Order__c
                                                     WHERE (Original_Parent_Order1__c IN :map_ParentToChildOrders.keySet()
                                                            OR Id IN :map_ParentToChildOrders.keySet())
                                                     AND status__c != 'Rejected'];            
            for(Order__c objOrder : list_UpdateOrderStatus ) {
                objOrder.status__c = 'Rejected';                
                if(objOrder.Original_Parent_Order1__c != null && map_ParentToChildOrders.containsKey(objOrder.Original_Parent_Order1__c)) {
                    objOrder.Reject_Reasons__c = map_ParentToChildOrders.get(objOrder.Original_Parent_Order1__c).Reject_Reasons__c;
                }
                else if(map_ParentToChildOrders.containsKey(objOrder.Id)) {
                    objOrder.Reject_Reasons__c = map_ParentToChildOrders.get(objOrder.Id).Reject_Reasons__c;
                }
                if(objOrder.Quote__c != null) {
                    set_BMQuoteIds.add(objOrder.Quote__c);
                }                
            }          
            System.debug('#####list_UpdateOrderStatus: '+list_UpdateOrderStatus); 
            update list_UpdateOrderStatus;
            if(set_BMQuoteIds.size() > 0) {
                List<BigMachines__Quote__c> list_UpdateBMQuoteStatus = [SELECT Id, BigMachines__Status__c  
                                                                        FROM BigMachines__Quote__c
                                                                        WHERE Id IN :set_BMQuoteIds];
                for(BigMachines__Quote__c objBMQuote : list_UpdateBMQuoteStatus) {
                    objBMQuote.BigMachines__Status__c = 'Order Rejected';
                }
                update list_UpdateBMQuoteStatus;
            }
        }

        //MS added 8/27/19
        if(map_ApprovedOrderIdsToQuoteIds.size() > 0) { 
           List<BigMachines__Quote__c> list_Quotes = SubscriptionUtil.getQuotes(map_ApprovedOrderIdsToQuoteIds.values());
 
            for(BigMachines__Quote__c objQt : list_Quotes) { 
                if(String.isNotBlank(objQt.Sale_Type__c) &&
                    (objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ||objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)  && 
                     objQt.Sale_Type__c != objQt.BigMachines__Opportunity__r.Direct_Indirect_Sale__c) {

                    Trigger.newmap.get(objQt.order__c).adderror('The Sale Type of the associated Quote ' + objQt.Name + ' does not match Sale type of the Opportunity ' +objQt.BigMachines__Opportunity__r.Name );
                    return;
                }                                                                                                                                                                                                                   
                //Anju May 2018 - If orgiinal subscription is inactive, cannot update, submit the quote / order
                if((objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) 
                    && objQt.Amendment_For__c != null && objQt.Amendment_For__r.Status__c != 'Active') {

                        Trigger.newmap.get(objQt.order__c).adderror('Subscription is not active anymore. Please create a new quote and an order with active subscription');
                        return;
                }
            }

             TriggerFlowManager.ORDER_AFTER_UPDATE_TRIGGER = false;

            System.enqueueJob( new OrderAfterTrigExtension(map_ApprovedOrderIdsToQuoteIds, list_Quotes, Trigger.new[0]) );    
        }
/* //MS - moved to OrderAfterTrigExtension

        //Logic to update opportunities and to send to zbilling
        System.debug('#####map_ApprovedOrderIdsToQuoteIds: '+map_ApprovedOrderIdsToQuoteIds);
        if(map_ApprovedOrderIdsToQuoteIds.size() > 0) { 
            Set<String> set_SubscriptionIds = new Set<String>();
            Set<String> set_OldSubscriptionIds = new Set<String>();
            List<Opportunity> list_UpdateOpps = new List<Opportunity>();    
            List<Subscription__c> list_ToInsertSubscriptions = new List<Subscription__c>();
            List<Subscription_Product__c> list_ToInsertSubscriptionProds = new List<Subscription_Product__c>();
            Map<Id, List<Subscription_Product__c>> map_ToInsertSubscriptionProds = new Map<Id, List<Subscription_Product__c>>();       
            Map<Id, Map<String, Subscription_Product__c>> map_ToInsertSubscrProds = new Map<Id, Map<String, Subscription_Product__c>>();       
            Map<Id, Id> map_QuoteIdToSubscrId = new Map<Id, Id>();
            
            Map<Id, String> map_OrderBillToEmails = SubscriptionUtil.setOrderBillToEmailsMap(map_ApprovedOrderIdsToQuoteIds.keySet());
            
            List<BigMachines__Quote__c> list_Quotes = SubscriptionUtil.getQuotes(map_ApprovedOrderIdsToQuoteIds.values());
            System.debug('#####list_Quotes: '+list_Quotes);
            for(BigMachines__Quote__c objQt : list_Quotes) { 

    ///MS validations - DO not REMOVE!           
                  if(String.isNotBlank(objQt.Sale_Type__c) &&(objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ||objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)  && objQt.Sale_Type__c != objQt.BigMachines__Opportunity__r.Direct_Indirect_Sale__c)
                {
                    system.debug('Inside subscription status check');
                    Trigger.newmap.get(objQt.order__c).adderror('The Sale Type of the associated Quote ' + objQt.Name + ' does not match Sale type of the Opportunity ' +objQt.BigMachines__Opportunity__r.Name );
                    return;
                }                                                                                                                                                                                                                   
                //Anju May 2018 - If orgiinal subscription is inactive, cannot update, submit the quote / order
                if((objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) 
                   && objQt.Amendment_For__c != null && objQt.Amendment_For__r.Status__c != 'Active') {
                    system.debug('Inside subscription status check');
                    Trigger.newmap.get(objQt.order__c).adderror('Subscription is not active anymore. Please create a new quote and an order with active subscription');
                    return;
                }
                
                list_UpdateOpps.add(new Opportunity(Id = objQt.BigMachines__Opportunity__c, 
                                                    ForecastStatus__c = Label.Oppty_Forecast_Status_Order_Approved));                 
                if(objQt.Order_Type__c == Label.New_Subscription || objQt.Order_Type__c == Label.Replace_Subscription) {
                    objQt.Billing_Start_Date__c = Date.today();
                  String strRampPeriod =  (objQt.Ramp_Period__c == '1 Year'?'365':objQt.Ramp_Period__c);
                  objQt.Subscription_Start_Date__c = Date.today().addMonths(objQt.Ramp_Period__c != 'Other' ? Integer.valueOf(strRampPeriod)/30 : 0);
                 objQt.Subscription_End_Date__c = objQt.Subscription_Start_Date__c.addMonths(Integer.valueOf(objQt.No_Of_Months__c))-1;
                }


                Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(objQt);                             
                
                if(objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) {
                    objQt.BigMachines__Status__c = 'Order Accepted';
                    objNewSubscription.Status__c = 'Active';
                    if(objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
                        objNewSubscription.Sync_Status__c = 'Waiting to Sync'; 
                    if(map_OrderBillToEmails.containsKey(objNewSubscription.Order__c)) {  
                        objNewSubscription.Bill_To_Emails__c = map_OrderBillToEmails.get(objNewSubscription.Order__c);   
                    }            
                }
                else if(objQt.Offering_Type__c == 'PureEngage Subscription' || objQt.Offering_Type__c == 'PureConnect Subscription'){
                    objNewSubscription.Order__c = Trigger.new[0].id;
                    objNewSubscription.Master_Order__c = Trigger.new[0].id;  

                    ///MS - 8/22/19 Temporary patch Until CCDB re-right  
                    objNewSubscription.Start_Date__c = Trigger.new[0].Maintenance_Start__c;
                    objNewSubscription.Subscription_End_Date__c = Trigger.new[0].Maintenance_End__c;
                    objNewSubscription.Contract_Expiration_Date__c = Trigger.new[0].Maintenance_End__c;
                    Integer rampMon = objQt.Ramp_Period__c != null && objQt.Ramp_Period__c.isNumeric() ? Integer.valueOf(objQt.Ramp_Period__c)/30 : 0;
                    objNewSubscription.Ramp_End_Date__c = (objNewSubscription.Start_Date__c != null && rampMon != 0) ? objNewSubscription.Start_Date__c.addMonths(rampMon).addDays(-1) : Trigger.new[0].Maintenance_Start__c;
                    objNewSubscription.Subscription_Start_Date__c = (objNewSubscription.Ramp_End_Date__c != null && rampMon != 0) ? objNewSubscription.Ramp_End_Date__c.addDays(1) : objNewSubscription.Start_Date__c;
                }

                System.debug('######objNewSubscription.Status__c: '+objNewSubscription.Status__c);
                System.debug('######objNewSubscription.Sync_Status__c: '+objNewSubscription.Sync_Status__c);
                if((objQt.Order_Type__c == Label.Amend_Subscription || objQt.Order_Type__c == Label.Replace_Subscription || objQt.Order_Type__c == Label.Renew_Subscription)
                   && objQt.Amendment_For__c != null) {                    
                       objNewSubscription.Version__c = objQt.Amendment_For__r.Version__c + 1;
                       objNewSubscription.Amendment_For__c = objQt.Amendment_For__c;
                       objNewSubscription.Original_Subscription__c = objQt.Amendment_For__r.Original_Subscription__c != null ? objQt.Amendment_For__r.Original_Subscription__c : objQt.Amendment_For__c;
                       objNewSubscription.Amendment_Date__c = objQt.Order_Type__c == Label.Amend_Subscription ? Date.today() : null;
                       objNewSubscription.Org_Id__c = objQt.Order_Type__c == Label.Renew_Subscription && objNewSubscription.Subscription_Start_Date__c >= Date.today() ? '' : objQt.Amendment_For__r.Org_Id__c;
                       objNewSubscription.Is_Cloned__c = false;
                       
                       Subscription__c objAmendForSubscription = new Subscription__c(
                           Id = objQt.Amendment_For__c, 
                           Status__c = objQt.Order_Type__c == Label.Replace_Subscription ? 'Replaced' : 
                           objQt.Order_Type__c == Label.Amend_Subscription ? 'Amended' : 
                           objQt.Order_Type__c == Label.Renew_Subscription && objQt.Amendment_For__r.Subscription_End_Date__c <= Date.today() ? 'Inactive' : 'Active');
                       list_ToInsertSubscriptions.add(objAmendForSubscription);
                       set_OldSubscriptionIds.add(objAmendForSubscription.Id);
                   }
                //Naresh Kumar - 06/20  Deactivating old subscription if any
                if(objQt.Offering_Type__c == 'PureEngage Subscription' || objQt.Offering_Type__c == 'PureConnect Subscription'){
                    if(objQt.Amendment_For__c != null 
                       && (objQt.Order_Type__c == Label.Order_Type_Amend || objQt.Order_Type__c == Label.Order_Type_Subscription)){
                        objNewSubscription.Version__c = objQt.Amendment_For__r.Version__c + 1;
                        objNewSubscription.Amendment_For__c = objQt.Amendment_For__c;
                        objNewSubscription.Original_Subscription__c = objQt.Amendment_For__r.Original_Subscription__c != null ? objQt.Amendment_For__r.Original_Subscription__c : objQt.Amendment_For__c;
                        objNewSubscription.Amendment_Date__c = System.today();
                        objNewSubscription.Org_Id__c = objQt.Order_Type__c == Label.Renew_Subscription && objNewSubscription.Subscription_Start_Date__c >= Date.today() ? '' : objQt.Amendment_For__r.Org_Id__c;
                        objNewSubscription.Is_Cloned__c = false; 
                        objNewSubscription.Business_Partner__c = objQt.Sold_To_Name__c; 
                        Subscription__c objAmendForSubscription = new Subscription__c(Id = objQt.Amendment_For__c, Status__c = 'Amended');
                        list_ToInsertSubscriptions.add(objAmendForSubscription);       
                    }    
                }
                list_ToInsertSubscriptions.add(objNewSubscription);
                System.debug('#####list_ToInsertSubscriptions: '+list_ToInsertSubscriptions);
                
                if(objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC ||objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQt.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) {
                    Set<String> set_DisplayedSubscrProds = new Set<String>();
                    for(BigMachines__Quote_Product__c objQtProd : objQt.BigMachines__BigMachines_Quote_Products__r) {   
                        if(!objQtProd.Hide_Record__c) {
                            set_DisplayedSubscrProds.add(objQtProd.BigMachines__Product__c+';'+objQtProd.Is_Overage__c);
                        }
                    }
                    for(BigMachines__Quote_Product__c objQtProd: objQt.BigMachines__BigMachines_Quote_Products__r) {                    
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
                else {
                    for(BigMachines__Quote_Product__c objQtProd: objQt.BigMachines__BigMachines_Quote_Products__r) {                          
                        Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);                       
                        objNewSubscriptionProd.CurrencyISOCode = objQt.CurrencyISOCode;
                       
                         ///MS -22/8/19 remove prices from Base Package line items
                        if( (objQt.Offering_Type__c == 'PureEngage Subscription' || objQt.Offering_Type__c == 'PureConnect Subscription') &&
                              objQtProd.Bundle__r.Group_Type__c == 'Base Package' && objQtProd.Bundle_Line__c != null) {
                                objNewSubscriptionProd.Ext_List__c = objNewSubscriptionProd.List_Price__c = objNewSubscriptionProd.Partner_Price__c = 0;
                                objNewSubscriptionProd.Ext_Net_Price__c = objNewSubscriptionProd.Net_Unit_Price__c = 0;
                                objNewSubscriptionProd.Total_Price__c = 0;
                        }
                        if(map_ToInsertSubscriptionProds.containsKey(objQtProd.BigMachines__Quote__c)) {
                            map_ToInsertSubscriptionProds.get(objQtProd.BigMachines__Quote__c).add(objNewSubscriptionProd);
                        }
                        else {
                            map_ToInsertSubscriptionProds.put(objQtProd.BigMachines__Quote__c, new List<Subscription_Product__c> { objNewSubscriptionProd } );
                        }
                    }
                }    
            }
     
            System.debug('#####map_ToInsertSubscriptionProds: '+map_ToInsertSubscriptionProds);
            if(list_ToInsertSubscriptions.size() > 0) {
                //try {
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
                //Anju Revpro August 2018 update POB Type
                Map<ID,String> map_POBType = new Map<ID,String>();
                for(Order_Line_Item__c objOrderLine : [SELECT id,POB_Type__c,Quote_Product__c 
                                                       FROM Order_Line_Item__c 
                                                       WHERE Order__c in :map_ApprovedOrderIdsToQuoteIds.keyset()])
                    map_POBType.put(objOrderLine.Quote_Product__c, objOrderLine.POB_Type__c);                  
                //For PureCloud and PureConnect Cloud
                for(Id quoteId : map_ToInsertSubscrProds.keySet()) {
                    for(String strUnqKey : map_ToInsertSubscrProds.get(quoteId).keySet()) {
                        Subscription_Product__c objSubscrProd = map_ToInsertSubscrProds.get(quoteId).get(strUnqKey);
                        if(map_QuoteIdToSubscrId.containsKey(quoteId)) {
                            objSubscrProd.Subscription__c = map_QuoteIdToSubscrId.get(quoteId);
                            objSubscrProd.POB_Type__c = map_POBType.containskey(objSubscrProd.Quote_Product__c) ? map_POBType.get(objSubscrProd.Quote_Product__c) : '';
                            list_ToInsertSubscriptionProds.add(objSubscrProd);
                        }
                    }
                }
                //For Other offerings
                for(Id quoteId : map_ToInsertSubscriptionProds.keySet()) {
                    for(Subscription_Product__c objSubscrProd : map_ToInsertSubscriptionProds.get(quoteId)) {
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
                
                if(set_SubscriptionIds.size() > 0) {
                    SubscriptionUtil.sendSubscriptionsToPC(set_SubscriptionIds);
                }
            }            
    
            Util.Bypass_Trigger_Chk = true;
            update list_Quotes;
            update list_UpdateOpps;
            Util.Bypass_Trigger_Chk = false;           
            
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
         
        }
        //Added By Ranjith on Jul 06, 2017 -- Ends        
        
        TriggerFlowManager.ORDER_AFTER_UPDATE_TRIGGER = false;
      
        if(list_UpdateHWOrderOwners.size() > 0) {
            update list_UpdateHWOrderOwners;
        }
     
 */
        
    }    
}