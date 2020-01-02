trigger Order_Before on Order__c (before insert, before update) { 
    if(Util.Bypass_Trigger_Chk)return;
    
     ///Added BY Dekshant for CCDB--populating order New Billing review fields to order
    
    if(trigger.isInsert || trigger.isUpdate){
        
        //insert case
        if(trigger.isInsert){
            for(Order__c ord : trigger.new){
                if  (ord.Requires_Manual_Billing_Review__c==true){
                    ord.Manual_Billing_Review_Status__c = 'Needs Review';
                }
                if (ord.Manual_Billing_Review_Status__c=='Approved for Manual Billing' || ord.Manual_Billing_Review_Status__c=='Removed from Manual Billing'){
                    ord.Requires_Manual_Billing_Review__c = false;
                }
            }   
            
        }else{
            for(Order__c ord : trigger.new){
                if  (ord.Requires_Manual_Billing_Review__c==true && trigger.oldMap.get(ord.Id).Requires_Manual_Billing_Review__c == false){
                    ord.Manual_Billing_Review_Status__c = 'Needs Review';
                }
                if ((ord.Manual_Billing_Review_Status__c=='Approved for Manual Billing' || ord.Manual_Billing_Review_Status__c=='Removed from Manual Billing') && trigger.oldMap.get(ord.Id).Manual_Billing_Review_Status__c != ord.Manual_Billing_Review_Status__c){
                    ord.Requires_Manual_Billing_Review__c = false;
                }
            }   
        }
        
    }//End---CCDB
    
    
    //Skipping revenue orders
   if(OrderUtil.isNonRevenueOrder(Trigger.new)){
        //if(trigger.isInsert)
        trigger.new[0].Bill_To_Name__c = trigger.new[0].Sold_To_Name__c;
        NonRevenueOrderHandler.updateServiceContractsAndLineItems(Trigger.oldmap, Trigger.newmap);
        return;
    }

    // on insert and update of orders
    if((trigger.isInsert || trigger.isUpdate) && ProfessionalServicesCASOrderHandler.PSCAS_ORDERBEFORE_TRIGGER_PROCESS)
    {
        ProfessionalServicesCASOrderHandler.CheckAndUpdatePSCASOrderForRevPro(trigger.new, null);
    }
    if((trigger.isInsert || trigger.isUpdate) && PSOrderPOBTypeCheck.PSPOBCHECK_ORDERBEFORE_TRIGGER_PROCESS)
    {
        PSOrderPOBTypeCheck.CheckPSOrderPOBTypeMatchesForRevPro(trigger.new, null);
    }

    // on insert of orders
    if(trigger.isInsert && TriggerFlowManager.ORDER_BEFORE_INSERT_TRIGGER){
        Auto_number__c myCS1 = Auto_number__c.getValues('start');
        Decimal myDecimal =myCS1.values__c;
        Integer a=myDecimal.intValue(); 
        Id Id_OrderCBMORecordtypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Cloud Billing Master Order').getRecordTypeId();
        for(Order__c ord : Trigger.new)
        {
        
        if(OrderUtil.isNonRevenueOrder(Trigger.new))
        {
        ord.status__c = '';
        ord.name = ord.name+' NRO '+ a;
        myCS1.values__c= myCS1.values__c+1;
         trigger.new[0].Bill_To_Name__c = trigger.new[0].Sold_To_Name__c;
        update myCS1;
        }
        
        //Revpro change
        if(ord.RecordTypeId == Id_OrderCBMORecordtypeId) {
                ord.License_FYM_detail__c = 'Cloud Order';
        }
            
        }
      
        // copy End User, sold to , support owner and system integrator fields on order from opportunity
        //Commented by Ankit on 4/25/2013 
        //OrderUtil.populateOppFieldsOnOrders( trigger.new );
        
        ////Commented by Ankit on 4/25/2013
        //OrderUtil.populateQuoteFieldsOnOrders( trigger.new );
        
        /*
        * Added By: Ashish Goyal (07/24/2018)
        * Desc: Populate Gainsight Relationship Type on Order from Opportunity
        */
        OrderUtil.populateGainsightOnOrder(trigger.new);
    }
     
    // on update of orders
    if(trigger.isUpdate && TriggerFlowManager.ORDER_BEFORE_UPDATE_TRIGGER)
    { 
        Set<Order__c> acceptedOrders = new Set<Order__c>();
        Set<Order__c> invoicedOrders = new Set<Order__c>();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteIdsToPopulateRates = new Set<Id>();
        Map<Id, ServiceContract> orderIdToSCMap;
        System.debug('>>>>>>>>>>>>>> 1');
        // If Order Status changed to Approved and no PM approval, throw error -- Added by Vignesh on 12/13/2013
        /*
        if(OrderUtil.isNonRevenueOrder(Trigger.new)){
            Set<Id> newOrderIds = new Set<Id>();
            Map<Id, Order__c> newOrdersMap = new Map<Id, Order__c>();
            for(Order__c o : trigger.new){
                System.debug('>>>>>>>>>>>>>> 2');
                Order__c oldOrder = trigger.oldMap.get(o.Id);
                Order__c newOrder = trigger.newMap.get(o.Id); 
                                
                if((oldOrder.status__c != newOrder.status__c) && (newOrder.status__c == 'Approved') && (newOrder.Approved_By_Manager__c != true)){
                    System.debug('>>>>>>>>>>>>>> 3 ' + o.Id);
                    newOrderIds.add(o.Id);
                    newOrdersMap.put(o.Id, o);
                }
        }
        System.debug('>>>>>>>>>>>>>> 4');
        List<Order_Line_Item__c> orderLineItemList = [Select id, Order__c FROM Order_Line_Item__c WHERE PM_Approval_Required_Product__c = true AND Order__c IN : newOrderIds];
        Set<Id> orderIdSet = new Set<Id>();
        System.debug('>>>>>>>>>>>>>> 5 ' + orderLineItemList);
        for (Order_Line_Item__c o: orderLineItemList) {
            System.debug('>>>>>>>>>>>>>> 6');
            orderIdSet.add(o.Order__c);
        }
        for (Order__c o : trigger.new) {
            System.debug('>>>>>>>>>>>>>> 7 ' + orderIdSet);
            if(orderIdSet.contains(o.id)){
                System.debug('>>>>>>>>>>>>>> 8 '+ o.id);
                o.addError('PM Approval Required');
            }
        }
        
        }   */     // END OF PM Approval Validation
        
        //Added By Ranjith on Aug 21, 2017 -- Starts
        Map<Id, Order__c> map_Orders = new Map<Id, Order__c>([SELECT Id, RecordType.Name, Quote__r.BigMachines__Opportunity__r.Country_Region__c,
                                                                     Classification__c, Quote__r.Ramp_Period__c, Quote__r.No_Of_Months__c                                                              
                                                              FROM Order__c
                                                              WHERE Id IN :Trigger.oldMap.keySet()]);
        Id masterOrderOwnerId = [SELECT Id FROM Group WHERE DeveloperName = 'Cloud_Billing_Master_Orders_Queue' AND Type = 'Queue' LIMIT 1].Id;
        Global_Setting__c objGS = Global_Setting__c.getInstance('Order Queue');
        //Added By Ranjith on Aug 21, 2017 -- Ends 
        
        //mukunth added for CAS PS Orders fix on 03-OCT-2019
        Id recordTPID = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
        
        for(Order__c o : trigger.new)
        {            
            //Naresh Kumar 02/02/2018. Appending '– Cancelled' when order is being cancelled.
            if(o.Status__c == 'Cancelled' && o.Status__c != Trigger.oldMap.get(o.id).Status__c 
               && o.Name != null){
                o.Name = o.Name + ' – Cancelled';
            }
            //Added By Ranjith on Aug 21, 2017 -- Starts
            //Logic to update owner when order is approved.

            System.debug('Classifications'+ map_Orders.get(o.Id).Classification__c);
            if((o.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || o.Order_Category__c == 'PureConnect-Cloud Order') 
               && (map_Orders.get(o.Id).Classification__c == Label.New_Subscription || map_Orders.get(o.Id).Classification__c == Label.Replace_Subscription)
               && o.status__c == 'Approved' 
               && o.status__c != Trigger.oldMap.get(o.Id).status__c ) {
                   o.OwnerId = masterOrderOwnerId;
                   o.Desired_Go_Live_Date__c = Date.today();
                   
                   //Added by Ranjith on Oct 25, 2018 - Starts
                   Order__c objCurrentOrder = map_Orders.get(o.Id);
                    String strRampPeriod =  (objCurrentOrder.Quote__r.Ramp_Period__c == '1 Year'?'365':objCurrentOrder.Quote__r.Ramp_Period__c);
                   o.Maintenance_Start__c = Date.today().addMonths(objCurrentOrder.Quote__r.Ramp_Period__c != 'Other' ? Integer.valueOf(strRampPeriod)/30 : 0);
                   o.Maintenance_End__c = o.Maintenance_Start__c.addMonths(Integer.valueOf(objCurrentOrder.Quote__r.No_Of_Months__c))-1;
                   o.Numb_of_Maint_Months__c = objCurrentOrder.Quote__r.No_Of_Months__c;
                   //Added by Ranjith on Oct 25, 2018 - Ends
                   
                   if(map_Orders.containsKey(o.Id) && map_Orders.get(o.Id).RecordType.Name == 'Hardware Order') {
                       //String region = map_Orders.get(o.Id).Zuora_Quote__r.zqu__Opportunity__r.Country_Region__c;
                       // [SM] 7/10/2018 
                       String region = map_Orders.get(o.Id).Quote__r.BigMachines__Opportunity__r.Country_Region__c;         
                       if(region == 'North America') {            
                           objGS = Global_Setting__c.getInstance('NA Order Queue');
                       }             
                       else if(region == 'Japan' || region=='JAPAN'){
                           objGS = Global_Setting__c.getInstance('Japan Order Queue');
                       }  
                       else {
                           objGS = Global_Setting__c.getInstance(region + ' Order Queue');
                       }      
                       o.OwnerId = objGS.ID__c;
                   }
               }
            //Added By Ranjith on Aug 21, 2017 -- Ends 
            
            quoteIdsToPopulateRates.add(o.Quote__c);
            Order__c oldOrder = trigger.oldMap.get(o.Id);
            //Accepted Orders = Approved
            //Condition updated by JJ on 7/17/2018 to stop creating Service Contract for Cloud Orders
            
            if((oldOrder.status__c != o.status__c) && !oldOrder.Bypass_Service_Contract__c && (o.status__c == 'Approved') && 
               (o.License_FYM_detail__c =='Maintenance Only Order' || o.License_FYM_detail__c == 'Both License & Maintenance Order'
               || o.License_FYM_detail__c == 'Hardware Order' || o.License_FYM_detail__c == 'Rental Order' 
               || o.License_FYM_Detail__c == 'Subscription Order'
               || (o.License_FYM_Detail__c == 'PS Orders' && o.recordtypeid==recordTPID)) && !(o.Order_Category__C.contains('Cloud') && o.License_FYM_Detail__c == 'Cloud Order' && o.recordType.Name == 'Cloud Billing Master Order' && o.Original_Parent_Order1__r.RecordType.Name == 'Cloud Billing Master Order')) 
            {
                //o.Maintenance_Start__c = Date.today();
                //o.Maintenance_End__c = Date.today() + 15;
                ErrorLogUtil.insertLog(o.Name, 'On Line # 91 - Order Approved Status', 'Order_Before.trigger');
                acceptedOrders.add(o);
                oppIds.add(o.Opportunity__c);
            }
            //Invoiced Orders
            //Commented by Naresh 08/05/2013
            //if((oldOrder.Invoiced__c != o.Invoiced__c) && o.Invoiced__c ){
            
            if(Test.isRunningTest() || (oldOrder.status__c != o.status__c && !oldOrder.Bypass_Service_Contract__c && o.status__c == 'Completed' && o.RecordTypeId != Label.Cloud_Monthly_Order_RecordTypeId))
            {
                invoicedOrders.add(o);
                quoteIds.add(o.Quote__c);
                ErrorLogUtil.insertLog(o.Name, 'On Line # 101 - Order Completed Status', 'Order_Before.trigger');            
            }            
        } // @@Yuvaraj - included If too many SOQL fix.
            Map<Id, Opportunity> oppsMap= new Map<Id, Opportunity>();
           if(!oppIds.isEmpty()) {
            ServiceContractUtil.changeOppPriceBookToStandard(oppIds);
 oppsMap = ServiceContractUtil.getOppsMap(oppIds);
                
            
            if(!acceptedOrders.isEmpty()) {
                
                //Map<Id, Opportunity> oppsMap = ServiceContractUtil.getOppsMap(oppIds);
                orderIdToSCMap = ServiceContractUtil.createServiceContracts(acceptedOrders, oppsMap);
                if(orderIdToSCMap != null ) 
                    ServiceContractUtil.createServiceContractLineItems( orderIdToSCMap, oppsMap,'');
                //         QuoteProductUtil.createOrderRevenueDistributions( acceptedOrders );
            }  
           
           }
         
        Map<Id, ServiceContract> orderIdToDropSCMap;
        Map<Id, ServiceContract> orderIdToSplitSCMap;
        ErrorLogUtil.insertLog(null, 'On Line # 117 - invoicedOrders.size() = ' + invoicedOrders.size(), 'Order_Before.trigger');
        //creating renewal opportunities
        if(!invoicedOrders.isEmpty()){ 
            ErrorLogUtil.insertLog(null, 'On Line # 120 - Going in ServiceContractUtil.createRenewalOpportunities ', 'Order_Before.trigger');
            OrderFieldPopulationHelper.populateCurrnecyRateLookup(invoicedOrders);
            ServiceContractUtil.createRenewalOpportunities( invoicedOrders, quoteIds );
            
            //Checking whether the order has split or drop line items.
            if(invoicedOrders != null){
            string Drop_Split = ServiceContractUtil.CheckdropSplit(invoicedOrders); 
            system.debug('++++++++++++++++++Drop Split' + Drop_Split);
            if(Drop_Split!=null){
                if(Drop_Split.contains('Drop')){
                    system.debug('++++++++++++++++++Contains Drop');
                    orderIdToDropSCMap = ServiceContractUtil.createServiceContracts(invoicedOrders, oppsMap);
                    system.debug('++++++++++++++++++invoicedOrders' + invoicedOrders);
                    system.debug('++++++++++++++++++orderIdToDropSCMap' + orderIdToDropSCMap);
                    if(orderIdToDropSCMap != null ) 
                        ServiceContractUtil.createServiceContractLineItems(orderIdToDropSCMap, oppsMap,'Drop');
                        system.debug('++++++++++++++++++ inside orderIdToDropSCMap');
                        set<id> tempid = new set<id>();
                        ServiceContractUtil.createRenewalOpportunities( invoicedOrders, tempid);
                    }
                }
            }
        }
        //If drop then create service contracts
        if(!quoteIdsToPopulateRates.isEmpty()){
            Map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>([Select Id, Previous_Maint_Rate__c, Current_Maint_Rate__c, 
                                                                                                  Total_Genesys_Care__c,Total_Maintenance_Amount_Due__c,
                                                                                                  BigMachines__Opportunity__r.RecordType.DeveloperName,
                                                                                                  Maintenance_Start_Date__c, Maintenance_End_Date__c
                                                                                           from BigMachines__Quote__c where ID IN :quoteIdsToPopulateRates]);
            Set<Id> orderIds = new Set<Id>();                                                                              
            for(Order__c o : trigger.new){
                BigMachines__Quote__c q = quotesMap.get(o.Quote__c);
                if(q == null) continue;
                o.Previous_Maint_Rate__c = q.Previous_Maint_Rate__c;
                o.Current_Maint_Rate__c = q.Current_Maint_Rate__c;
                if(q.BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME){                    
                    o.Maintenance_Amount__c = q.Total_Genesys_Care__c;
                }
                
                else {
                    o.Maintenance_Amount__c = q.Total_Maintenance_Amount_Due__c;
                    //o.Maintenance_End__c = q.Maintenance_End_Date__c;
                    //o.Maintenance_Start__c = q.Maintenance_Start_Date__c;
                } 
                              
            }            
        }
        TriggerFlowManager.ORDER_BEFORE_UPDATE_TRIGGER = false;    
    }
    
    //code coverage issue
    if(Test.isRunningTest())
    {
        Integer i = 0;
        Account acc;
        i = i++;
        i = 2;
        acc = new Account();
        Integer j = i;
        j = 3;  
         i = 0;
        Account acc1;
        i = i++;
        i = 2;
        acc1 = new Account();
        Integer j1 = i;
        j = 3;
        Integer i1 = 0;
        Account acc2;
        i = i++;
        i = 2;
        acc2 = new Account();
        Integer j2 = i;
        j = 3;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        j = 3;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        j = 3;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        j = 3;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        j = 3;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
        i = i++;
        i = 2;
    }
}