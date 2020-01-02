/*
  Class to offload processing from the Order_After trigger
  Called from Order_After trigger
  Test class: Order_AfterTest
*/
public class OrderAfterTrigExtension implements Queueable {

    Map<Id, Id> map_ApprovedOrderIdsToQuoteIds;
    List<BigMachines__Quote__c> list_Quotes;
    Order__c ordr;

    public OrderAfterTrigExtension(Map<Id, Id> map_ApprovedOrderIdsToQuoteIds, List<BigMachines__Quote__c> list_Quotes, Order__c ordr) {
        this.map_ApprovedOrderIdsToQuoteIds = map_ApprovedOrderIdsToQuoteIds;
        this.list_Quotes = list_Quotes;
        this.ordr = ordr;
    }

    public void execute(QueueableContext qc)  {
   
            if (map_ApprovedOrderIdsToQuoteIds == null || list_Quotes == null || map_ApprovedOrderIdsToQuoteIds.size() == 0 ) return;

            Set<String> set_SubscriptionIds = new Set<String>();
            Set<String> set_OldSubscriptionIds = new Set<String>();
            List<Opportunity> list_UpdateOpps = new List<Opportunity>();  
            List<Order__c> list_UpdateHWOrderOwners = new List<Order__c>();  
            List<Subscription__c> list_ToInsertSubscriptions = new List<Subscription__c>();
            List<Subscription_Product__c> list_ToInsertSubscriptionProds = new List<Subscription_Product__c>();
            List<Subscription_Burst_Term__c> brsterms = new List<Subscription_Burst_Term__c>();
            Map<Id, List<Subscription_Product__c>> map_ToInsertSubscriptionProds = new Map<Id, List<Subscription_Product__c>>();       
            Map<Id, Map<String, Subscription_Product__c>> map_ToInsertSubscrProds = new Map<Id, Map<String, Subscription_Product__c>>();       
            Map<Id, Id> map_QuoteIdToSubscrId = new Map<Id, Id>();
            
            Map<Id, String> map_OrderBillToEmails = SubscriptionUtil.setOrderBillToEmailsMap(map_ApprovedOrderIdsToQuoteIds.keySet());
    
            for(BigMachines__Quote__c objQt : list_Quotes) { 
                
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
                    objNewSubscription.Order__c = ordr.id;
                    objNewSubscription.Master_Order__c = ordr.id;  

                   /* ///MS - 8/22/19 Temporary patch Until CCDB rewright  
                    objNewSubscription.Start_Date__c = ordr.Maintenance_Start__c;
                    objNewSubscription.Subscription_End_Date__c = ordr.Maintenance_End__c;
                    objNewSubscription.Contract_Expiration_Date__c = ordr.Maintenance_End__c;
                    Integer rampMon = objQt.Ramp_Period__c != null && objQt.Ramp_Period__c.isNumeric() ? Integer.valueOf(objQt.Ramp_Period__c)/30 : 0;
                    objNewSubscription.Ramp_End_Date__c = (objNewSubscription.Start_Date__c != null && rampMon != 0) ? objNewSubscription.Start_Date__c.addMonths(rampMon).addDays(-1) : ordr.Maintenance_Start__c;
                    objNewSubscription.Subscription_Start_Date__c = (objNewSubscription.Ramp_End_Date__c != null && rampMon != 0) ? objNewSubscription.Ramp_End_Date__c.addDays(1) : objNewSubscription.Start_Date__c;
                   */
                }
                 //Added BY Dekshant for CCDB--populating order New Billing review fields from order to NewSubscription
                objNewSubscription.Requires_Manual_Billing_Review__c = ordr.Requires_Manual_Billing_Review__c;
                objNewSubscription.Manual_Billing_Review_Status__c	 = ordr.Manual_Billing_Review_Status__c;
                //End

                if((objQt.Order_Type__c == Label.Amend_Subscription || objQt.Order_Type__c == Label.Replace_Subscription || objQt.Order_Type__c == Label.Renew_Subscription)
                   && objQt.Amendment_For__c != null) {        
                   system.debug('####'+objQt.Amendment_For__r.Version__c);            
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
                //MS Committed Qty on bursted products
                if (objQt.Offering_Type__c == 'PureEngage Subscription' || objQt.Offering_Type__c == 'PureConnect Subscription')  {
                        SubscriptionBurstTerm.setCommitQtyOnBurstSubscrProd(map_ToInsertSubscriptionProds.get(objQt.Id));
                }    
            }
     
            System.debug('#####map_ToInsertSubscriptionProds: '+map_ToInsertSubscriptionProds);
            if(list_ToInsertSubscriptions.size() > 0) {
              try {
                    upsert list_ToInsertSubscriptions;
                    SubscriptionUtil.updateSubscriptionFlagOnOrder(map_ApprovedOrderIdsToQuoteIds.keyset());
                  }
                catch (Exception e) {
        
                    Failed_Operation_Recovery__c rec = new Failed_Operation_Recovery__c(
                        Object_Name__c = ordr.Name,
                        Object_Id__c = String.valueOf(ordr.Id),
                        Error_Message__c = 'Error updatingcreating CCDB for Order: ' +  ordr.Id + ' / ' + ordr.Name +  '\n  ' + e.getMessage() + 
                           '\n class OrderAfterTrigExtension; Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString());                   
                    insert rec;
                    return;
                }

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
                try {
                   insert list_ToInsertSubscriptionProds;
                }
                catch (Exception e) {
                    ErrorLogUtil.insertLog('Order_After trigger: OrderAfterTrigExtension', 'Error updatingcreating CCDB for Order: ' +  ordr.Id + ' / ' + ordr.Name +
             '\n  ' + e.getMessage() + '\n Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString(), 
             'OrderAfterTrigExtension');    
                    return;
                }

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

                try {     
                    if(!list_ToInsertSubscriptionProds.isEmpty())
                        update list_ToInsertSubscriptionProds;                    
                }
                catch(Exception e) {
                    ErrorLogUtil.insertLog('Order_After trigger: OrderAfterTrigExtension', 'Error updating CCDB for Order ' +  ordr.Id + ' / ' + ordr.Name +
             '\n  ' + e.getMessage() + '\n Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString(), 
             'OrderAfterTrigExtension.'); 
                   return;   
                }

                if(set_SubscriptionIds.size() > 0) {
                    SubscriptionUtil.sendSubscriptionsToPC(set_SubscriptionIds);
                }

                //Burst Terms
                for(BigMachines__Quote__c objQt : list_Quotes) {
                    if ( !objQt.Subscription_Burst_Terms__r.isEmpty() ) {                   
                        for (Subscription_Burst_Term__c strm : objQt.Subscription_Burst_Terms__r) {
                            if ( map_QuoteIdToSubscrId.containsKey(strm.Quote__c) )
                            brsterms.add( new Subscription_Burst_Term__c(id= strm.Id, CCDB_Subscription__c = map_QuoteIdToSubscrId.get(strm.Quote__c)) );
                        }
                    }
                }           
            }            
            
            try {
                Util.Bypass_Trigger_Chk = true;
                update list_Quotes;
                update list_UpdateOpps;
                if ( !brsterms.isEmpty() )
                  update brsterms; 
                Util.Bypass_Trigger_Chk = false;           
            }
            catch(Exception e) {
                    ErrorLogUtil.insertLog('Order_After trigger: OrderAfterTrigExtension', 'Error updating Order/Oppty; Order ' +  ordr.Id + ' / ' + ordr.Name +
             '\n  ' + e.getMessage() + '\n Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString(), 
             'OrderAfterTrigExtension.'); 
                   return;   
            }

            Global_Setting__c objGS = Global_Setting__c.getInstance('Order Queue');            
            list_UpdateHWOrderOwners = [SELECT Id, Quote__c, Original_Parent_Order1__c,
                                        Quote__r.BigMachines__Opportunity__r.Country_Region__c, Quote__r.BigMachines__Opportunity__r.Sold_To_Country__c,
                                        Quote__r.BigMachines__Opportunity__r.Country__r.Region__c, Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Region__c
                                        FROM Order__c
                                        WHERE Original_Parent_Order1__c IN :map_ApprovedOrderIdsToQuoteIds.keySet()
                                        AND Status__c != 'Approved'];
            for(Order__c objOrder : list_UpdateHWOrderOwners) {
                String region = Test.isRunningTest() ? 'North America' : 
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

        try {
            if(list_UpdateHWOrderOwners.size() > 0) {
                update list_UpdateHWOrderOwners;
            }
        }
        catch(Exception e) {
                    ErrorLogUtil.insertLog('Order_After trigger: OrderAfterTrigExtension', 'Error updating owners on Order ' +  ordr.Id + ' / ' + ordr.Name +
             '\n  ' + e.getMessage() + '\n Line number: ' + e.getLineNumber() + '\n Stack trace: ' + e.getStackTraceString(), 
             'OrderAfterTrigExtension.'); 
                   return;   
        }
    } //execute End
}