/*****************************************************
Class: ServiceContractUtil
Author – Rashmi K
Date – 3/4/2013
Usage : Note : Utility class - automation of creating service contracts, contract line items, entitlements, assets, renewal opportunities, backoffice accounts and
                               update of service contracts, contract lines and entitlements

Revision History
4/17/2013 - Rashmi K : added code to update maintenance Terminated on support access records, on change of Service contract status
******************************************************/
public without sharing class ServiceContractUtil {
    public final static string GENESYS_CARE = 'Genesys Care';
    public final static string MAINTENANCE = 'Maintenance';
    public final static string FLEX_CARE = 'Flex Care';
    public final static string PS = 'PS';
    public final static string OPP_GEN_RENEWAL_DEV_NAME = 'Genesys_Renewal';
    public final static string OPP_GEN_NEW_DEV_NAME = 'GEN_Opportunity_Record_Type_New';
    public final static string OPP_PPU_USAGE_RECORD_TYPE = 'PPU_Usage_Revenue_Record_Type';

    public static Map<Id, ServiceContract> checkIfServiceContractExists(Set<Order__c> orders){
        Set<Id> quoteIds = new Set<Id>();
        for( Order__c o : orders ){
            if( o.Quote__c != null)
                quoteIds.add( o.Quote__c );
        }
        Map<Id, ServiceContract> orderIdToSC = new Map<Id, ServiceContract>();
        if( !quoteIds.isEmpty() ){
            Set<Id> scIds = new Set<Id>();
            for(BigMachines__Quote__c quote : [Select Id, (Select Id, Opportunity__r.Service_Contract__c From Orders__r)
                                               from BigMachines__Quote__c where Id IN :quoteIds]){
                if(quote.Orders__r.size() > 0){
                    for(Order__c o : quote.Orders__r)
                        if(o.Opportunity__r.Service_Contract__c != null)
                            scIds.add( o.Opportunity__r.Service_Contract__c );
                }
            }
            if( !scIds.isEmpty() ){
                for(ServiceContract sc :[Select Id, Order__c from ServiceContract where Id IN :scIds]){
                    orderIdToSC.put(sc.Order__c, sc);
                }
            }
        }
        return orderIdToSC;
    }

    public static Map<Id, Opportunity> getOppsMap( Set<Id> oppIds ){
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([Select Id, Name, RecordType.DeveloperName,
                                                                        Pricebook2Id, CurrencyISOCode,
                                                                        Region__c, Quote_SG2_Region__c
                                                                 from Opportunity where ID IN:oppIds]);
        return oppsMap;
    }

    public static void changeOppPriceBookToStandard(Set<Id> set_OfOppIds){
        try{
            List<Opportunity> objOpps = [SELECT Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE id IN : set_OfOppIds LIMIT 1];
            if(objOpps.isEmpty() || objOpps[0].Pricebook2.Name == 'Standard Price Book'){
                return;
            }
            Opportunity objOpp = objOpps[0];
            PriceBook2 standardPB = [SELECT Id, Name FROM pricebook2 WHERE Name = 'Standard Price Book'];
            if (objOpp.Pricebook2Id != standardPB.id) {
                List <OpportunityLineItem> oppLinesToBeDeleted = [SELECT id FROM OpportunityLineItem WHERE OpportunityId =: objOpp.id];
                if (!oppLinesToBeDeleted.isEmpty())
                    delete oppLinesToBeDeleted;
                Opportunity oppToBeUpdated = new Opportunity(id = objOpp.id, Pricebook2Id = standardPB.id);
                update oppToBeUpdated;
            }
        }
        catch(Exception e){
            System.debug('NKC debug exception : ' + e.getMessage());
        }
    }

    public static void setProductPriceBooks(Set<Id> set_OfProductIds, String strCurrency){
        try{
            List<PriceBookEntry> list_OfPBE = [SELECT id, Product2Id, isActive FROM PriceBookEntry WHERE Product2Id IN : set_OfProductIds AND currencyISOCode =: strCurrency];
            Map<Id, PriceBookEntry> map_OfProduct2VsPBE = new Map<Id, PriceBookEntry>();

            for(PriceBookEntry eachPBE : list_OfPBE){
                map_OfProduct2VsPBE.put(eachPBE.Product2Id, eachPBE);
            }
            PriceBook2 standardPB = [SELECT Id, Name FROM pricebook2 WHERE Name = 'Standard Price Book'];

            List<PriceBookEntry> list_PBEToBeInserted = new List<PriceBookEntry>();
            List<PriceBookEntry> list_PBEToBeUpdated = new List<PriceBookEntry>();
            for(Id eachProduct2Id : set_OfProductIds){
                if(map_OfProduct2VsPBE.get(eachProduct2Id) == null){
                    PriceBookEntry objPBE = new PriceBookEntry(PriceBook2Id = standardPB.id, Product2Id = eachProduct2Id,
                                                CurrencyISOCode = strCurrency, UnitPrice = 0, IsActive = true);
                    list_PBEToBeInserted.add(objPBE);
                }
                else if(map_OfProduct2VsPBE.get(eachProduct2Id) != null && map_OfProduct2VsPBE.get(eachProduct2Id).isActive == false){
                    PriceBookEntry objPBE = new PriceBookEntry(id = map_OfProduct2VsPBE.get(eachProduct2Id).id, IsActive = true);
                    list_PBEToBeUpdated.add(objPBE);
                }
            }

            if(!list_PBEToBeInserted.isEmpty())
                insert list_PBEToBeInserted;

            if(!list_PBEToBeUpdated.isEmpty())
                update list_PBEToBeUpdated;
        }
        catch(Exception e){
            System.debug('NKC debug exception : ' + e.getMessage());
        }
    }

    public static Map<Id, ServiceContract> createServiceContracts(Set<Order__c> orders,
                                                                  Map<Id, Opportunity> oppsMap){
        System.savepoint sp =  Database.setSavepoint();
        //Map<Id, ServiceContract> orderIdToSC = checkIfServiceContractExists( orders );
        // Checking if any order already has a Service Contract
        Set<Id> set_OrderIdsWithServiceContracts = new Set<Id>();
        for(ServiceContract objSC : [SELECT Order__c FROM ServiceContract WHERE Order__c IN :orders AND Order__c != null])
            set_OrderIdsWithServiceContracts.add(objSC.Order__c);

        Map<Id, ServiceContract> scsToInsert = new Map<Id, ServiceContract>();
        List<Pricebook2> pbs = [Select Id from Pricebook2 where isActive = true and isStandard=true];
        Map<Id, Order__c> ordersMap = new map<Id, Order__c>([Select Id, Quote__c,Quote__r.Total_Maintenance_Amount_Due__c,
                                                                    (Select Id, Maintenance_Start_Date__c,
                                                                            Maintenance_End_Date__c,
                                                                            Product__r.Type__c
                                                                    From Order_Line_Items__r )
                                                             from Order__c

                                                             where ID IN: orders]);


        for(Order__c o : orders)
        {
            //if( !orderIdToSC.containsKey(o.Id) )
            // if Order does not have a service contract
            if(!set_OrderIdsWithServiceContracts.contains(o.Id) && o.Order_Category__c != 'PureConnect Cloud - Hardware')
            {
                //System.debug('NKC debug oppsMap.get(o.Opportunity__c).pricebook2Id ['+oppsMap.get(o.Opportunity__c).pricebook2Id+']');
                ServiceContract s = DynamicFieldMapping.getServiceContractFromOrder(o, 'Master');

                //Added by JJ on 07/16/2018 as requsted by Ankit
                if(o.License_FYM_detail__c == 'Rental Order')
                    s.Service_Contract_Type__c = 'Rental';

                s.Name = oppsMap.get(o.Opportunity__c).Name + ' Maintenance Contract';
                if(oppsMap.get(o.Opportunity__c).pricebook2Id != null)
                    s.pricebook2Id = oppsMap.get(o.Opportunity__c).pricebook2Id;
                else{
                    if(!pbs.isEmpty())
                        s.pricebook2Id = pbs[0].id;
                }

                System.debug('NKC debug s.pricebook2Id ['+s.pricebook2Id+']');
                s.Big_Four__c = oppsMap.get(o.Opportunity__c).Region__c;
                s.SG2_Region__c = oppsMap.get(o.Opportunity__c).Quote_SG2_Region__c;

                Boolean isDeclineMaintenance = false;
                if(oppsMap.get(o.Opportunity__c).RecordType.DeveloperName == OPP_GEN_NEW_DEV_NAME){
                    //09/18/2013 Naresh Kumar   Start and End dates shouldn't be changed once order is created.
                    //o.Maintenance_Start__c = date.today();
                    //o.Maintenance_End__c = date.today().addMonths((Integer)o.Numb_of_Maint_Months__c);
                    //o.Maintenance_End__c = date.today() + 15;
                    s.Maintenance_Amount__c = o.Maintenance_Amount__c;
                    isDeclineMaintenance = true;

                    for( Order_Line_Item__c oli : ordersMap.get(o.Id).Order_Line_Items__r){
                        if( oli.Product__r.Type__c == MAINTENANCE || oli.Product__r.Type__c == GENESYS_CARE
                                || oli.Product__r.Type__c == FLEX_CARE || oli.Product__r.Type__c == PS)
                            isDeclineMaintenance = false;
                    }

                    if(isDeclineMaintenance || ordersMap.get(o.Id).Order_Line_Items__r.isEmpty()){
                        isDeclineMaintenance = true;
                        //09/18/2013 Naresh Kumar   Start and End dates shouldn't be changed once order is created.
                        //o.Maintenance_Start__c = date.today();
                        //o.Maintenance_End__c = date.today();
                    }
                }else s.Maintenance_Amount__c = ordersMap.get(o.Id).Quote__r.Total_Maintenance_Amount_Due__c;

                s.Decline_Maintenance__c = isDeclineMaintenance;
                /*
                s.StartDate = o.Maintenance_Start__c;
                s.EndDate = o.Maintenance_End__c;
                s.Service_Level__c = o.Service_Level__c;
                s.Agreement_Status__c = 'Pending';
                s.Opportunity__c = o.Opportunity__c;
                */
                if(o.Quote__r.Quote_Business_Type__c == 'Renewal'){
                    s.Maintenance_Amount__c = o.Maintenance_Amount__c;
                    s.Revised_Net_License_Value__c = o.Revised_Net_License_Value__c;
                }
                if(isDeclineMaintenance)
                    s.Agreement_Status__c = 'Declined';
                //NEW update the opportunity to the orders opportunity

                scsToInsert.put(o.id, s);
            }
        }
        if(!scsToInsert.isEmpty()) {
            insert scsToInsert.values();
            //ServiceContract s1c = [SELECT pricebook2Id FROM ServiceContract WHERE id =: scsToInsert.values()[0].id];
            //System.debug('NKC debug s1c.pricebook2Id ['+s1c.pricebook2Id+']');
          //commented by ankit temp at 5/10/2013
              // List<ServiceContract> scs = [Select Id, Name,Agreement_Number__c from ServiceContract where Id IN : scsToInsert.values()];
           List<ServiceContract> scs = [Select Id, Agreement_Number__c, Name, End_User_Name__c, Sold_To_Name__c, ownerId from ServiceContract where Id IN : scsToInsert.values()];
             //  List<ServiceContract> scs = [Select Id, Name from ServiceContract where Id IN : scsToInsert.values()];

            for(ServiceContract sc : scs)
                sc.Name = sc.Agreement_Number__c;

            // Update only if there are any records in the list
            if(scs.size() > 0)
                update scs;

           // orderIdToSC.putall(scsToInsert);

            Map<Id, Order__c> oppIdToOrder = new Map<Id, Order__c>();
            for(Order__c o : orders){
                oppsMap.get(o.Opportunity__c).Service_Contract__c = scsToInsert.get(o.Id).Id;
                oppIdToOrder.put(o.Opportunity__c, o);
            }
            try{
                if(!oppsMap.isEmpty())
                    update oppsMap.values();
            }catch(Dmlexception ex){
                Database.rollback(sp);
                for (Integer i=0; i < ex.getNumDML(); i++)
                {
                    Opportunity opp = oppsMap.values()[ex.getDmlIndex(i)];
                    if (oppIdToOrder.containsKey(opp.Id)){
                        Order__c o = oppIdToORder.get(opp.Id);
              //          orders.get(o.Id).addError('There was an error while updating Inital Opportunities' + ex.getDmlMessage(i));
                    }
                }
            }
        }
        return scsToInsert;

    }


    public static string CheckdropSplit(Set<Order__c> orders){
         string drop_split;
    if(orders != null){
    List<Order_Line_Item__c> olis = [Select Contract_Line_Update_Status__c from Order_Line_Item__c where Order__c IN : orders];
    for(Order_Line_Item__c oli : olis){
    if(oli.Contract_Line_Update_Status__c!=null){
                if(oli.Contract_Line_Update_Status__c.contains('Drop')){
                 if(drop_split != null){
                            if(!drop_split.contains('Drop'))
                            drop_split += 'Drop';
                            } else {
                            drop_split += 'Drop';
                            }
                    }
                if(oli.Contract_Line_Update_Status__c.contains('Split')){
                    if(drop_split != null){
                        if(!drop_split.contains('Drop'))
                            drop_split += 'Drop';
                        } else {
                            drop_split += 'Drop';
                        }
                    }
    }
    }
    }
    return drop_Split;
    }

    // add dates to contract line but the status should be still pending
    // it shuld change to active when you invoice hte order
    public static void createServiceContractLineItems(Map<Id, ServiceContract> orderIdToSCMap, Map<Id, Opportunity> oppsMap,string status){
        Map<Id, ContractLineItem> oliTocli = new Map<Id, ContractLineItem>();
        List<OpportunityLineItem> oppLineItems;
        List<Order_Line_Item__c> olis = new  List<Order_Line_Item__c>();
       // string drop_split;
        if(status=='') {
            olis = [Select Id, Order__c, Order__r.License_Order__c, Quote_Product__c,Product__c, Product__r.Description, BigMachines_Quantity__c,End_Support_Date__c,
                        Order__r.Invoice_Number__c, Order__r.Invoice_Date__c, Lic_Invoice__c,
                        Order__r.PO_Number__c, Order__r.Previous_Line_Maintenance_Value__c,
                        Order__r.Revised_Net_License_Value__c, Order__r.Maintenance_Level__c,
                        Order__r.Opportunity__c, Sales_Price__c, Pricebook_Entry_ID__c,
                        Maintenance_Due__c, Fees_Applied__c, Comment__c, Genesys_Care_Rate__c,
                        Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c,
                        Sold_To_Name__c, End_User_Name__c, Maintenance_Start_Date__c,
                        Maintenance_End_Date__c, Contract_Line_Update_Status__c, Original_Qty__c,
                        Current_Qty__c, Product__r.Type__c, Order__r.Original_License_Invoice_Date__c,
                        Total_Price__c, Original_Net_License_value__c, Order__r.CurrencyIsoCode, Annualized_Maintenance_Due__c,
                        Order__r.Maintenance_Start__c, Order__r.Maintenance_End__c,Service_Contract_Line_ID__c, Order__r.Sold_To_Name__c,
                        Contract_Line_Item__c, Contract_Line_Item__r.Non_Billable__c, Order__r.License_FYM_detail__c,
                        Year1_Maintenance_Due__c, Year2_Maintenance_Due__c, Year3_Maintenance_Due__c,
                        Year4_Maintenance_Due__c,Year5_Maintenance_Due__c,
                        Year2_CareRatePercent__c, Year3_CareRatePercent__c, Year4_CareRatePercent__c, Year5_CareRatePercent__c,
                        Order__r.Quote__r.Quote_Business_Type__c, Material_Number__c, Order__r.Offering_Type__c,
                        // 1/21/2015 : To Copy additional information for PS product (if present)
                        Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,
                        // 2/5/2015 : few more fields
                        Application_Support_Cost_Base__c,Solution_Names_Covered__c,Third_Party_Partner_Fee__c,
                    	//Ramar added to populate value from order to Service Contract Line Item
                    	CX_Platform__c
                 from Order_Line_Item__c where Order__c IN : orderIdToSCMap.keySet() ];

        }
    /*
       if(status=='Drop') {
         olis = [Select Id, Order__c, Product__c, BigMachines_Quantity__c,End_Support_Date__c,
                                                Order__r.Invoice_Number__c, Order__r.Invoice_Date__c,
                                                Order__r.PO_Number__c, Order__r.Previous_Line_Maintenance_Value__c,
                                                Order__r.Revised_Net_License_Value__c, Order__r.Maintenance_Level__c,
                                                Order__r.Opportunity__c, Sales_Price__c, Pricebook_Entry_ID__c,
                                                Maintenance_Due__c, Fees_Applied__c, Comment__c, Genesys_Care_Rate__c,
                                                Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c,
                                                Sold_To_Name__c, End_User_Name__c, Maintenance_Start_Date__c,
                                                Maintenance_End_Date__c, Contract_Line_Update_Status__c, Original_Qty__c,
                                                Current_Qty__c, Product__r.Type__c, Order__r.Original_License_Invoice_Date__c,
                                                Total_Price__c, Original_Net_License_value__c, Order__r.CurrencyIsoCode
                                         from Order_Line_Item__c where Order__c IN : orderIdToSCMap.keySet() and Contract_Line_Update_Status__c like '%Drop%'];
        }

        if(status=='Split') {
         olis = [Select Id, Order__c, Product__c, BigMachines_Quantity__c,End_Support_Date__c,
                                                Order__r.Invoice_Number__c, Order__r.Invoice_Date__c,
                                                Order__r.PO_Number__c, Order__r.Previous_Line_Maintenance_Value__c,
                                                Order__r.Revised_Net_License_Value__c, Order__r.Maintenance_Level__c,
                                                Order__r.Opportunity__c, Sales_Price__c, Pricebook_Entry_ID__c,
                                                Maintenance_Due__c, Fees_Applied__c, Comment__c, Genesys_Care_Rate__c,
                                                Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c,
                                                Sold_To_Name__c, End_User_Name__c, Maintenance_Start_Date__c,
                                                Maintenance_End_Date__c, Contract_Line_Update_Status__c, Original_Qty__c,
                                                Current_Qty__c, Product__r.Type__c, Order__r.Original_License_Invoice_Date__c,
                                                Total_Price__c, Original_Net_License_value__c, Order__r.CurrencyIsoCode, Order__r.Maintenance_Start__c,Service_Contract_Line_ID__c
                                         from Order_Line_Item__c where Order__c IN : orderIdToSCMap.keySet() and Contract_Line_Update_Status__c like '%Split%'];
        }
        */
        system.debug(oppsMap.keySet());

        Set<Id> product2Ids = new Set<Id>();
        Set<String> isoCodes = new Set<String>();
        String strCurrency = 'USD';
        Boolean blnSplitHardwareOrder = false;
        List<String> listOfHardwareLinePrefixes = Label.Hardware_Lines_Prefix_For_Seperate_SC.split(';');
        Set<String> setOfHardwareLinePrefixes = new Set<String>();
        SetOfHardwareLinePrefixes.addAll(listOfHardwareLinePrefixes);
        Set<Id> setOfOLIForSeperateSC = new Set<Id>();
        System.debug('NKC debug setOfHardwareLinePrefixes [' + setOfHardwareLinePrefixes +']');
        Date orderMaintStartDate;
        Id hardwareOrderId;
        for(Order_Line_Item__c oli : olis){
            product2Ids.add( oli.Product__c);
            isoCodes.add(oli.Order__r.CurrencyIsoCode);
            strCurrency = oli.Order__r.CurrencyIsoCode;
            orderMaintStartDate = oli.Order__r.Maintenance_Start__c;
            if(oli.Order__r.License_FYM_detail__c == 'Hardware Order'){
                hardwareOrderId = oli.Order__c;
                System.debug('NKC debug oli.Material_Number__c [' + oli.Material_Number__c +']');
                if(oli.Material_Number__c != null){
                    String strItemPrefix = oli.Material_Number__c.split('-')[0];
                    System.debug('NKC debug strItemPrefix [' + strItemPrefix +']');
                    if(setOfHardwareLinePrefixes.contains(strItemPrefix)){
                        setOfOLIForSeperateSC.add(oli.id);
                        blnSplitHardwareOrder = true;
                    }
                }
                if(oli.Product__r.Type__c == 'Maintenance' || oli.Product__r.Type__c == 'Genesys Care'){
                    setOfOLIForSeperateSC.add(oli.id);
                }
            }
        }

        ServiceContract hardwareSC;
        if(blnSplitHardwareOrder){
            ServiceContract sc = orderIdToSCMap.get(hardwareOrderId);
            hardwareSC = sc.clone(false, true, false, false);
            /*
            hardwareSC.Revised_Net_License_Value__c = 0;
            hardwareSC.Total_Annualized_Maintenance_Due__c = 0;
            */
            insert hardwareSC;
            ServiceContract objSC = [SELECT Agreement_Number__c FROM ServiceContract WHERE Id =: hardwareSC.id LIMIT 1];
            hardwareSC.Name = objSC.Agreement_Number__c;
            if(orderMaintStartDate != null){
                hardwareSC.StartDate = orderMaintStartDate;
                hardwareSC.EndDate = orderMaintStartDate.addMonths(12);
                hardwareSC.Do_not_override_SC_dates__c = true;
            }
            util.Bypass_Trigger_Chk = true;
            List<ServiceContract> list_OfSCToBeUpdated = new List<ServiceContract>();
            list_OfSCToBeUpdated.add(hardwareSC);
            sc.Service_Contract_Type__c = 'Hardware';
            sc.Name = [SELECT Agreement_Number__c FROM ServiceContract WHERE id =: sc.id].Agreement_Number__c;
            list_OfSCToBeUpdated.add(sc);
            update list_OfSCToBeUpdated;
            util.Bypass_Trigger_Chk = false;
        }

        setProductPriceBooks(product2Ids, strCurrency);
        Map<Id, List<PricebookEntry>> pb2IdToPBE = new Map<Id, List<PricebookEntry>>();
        if(!product2Ids.isEmpty())
            for(PricebookEntry pbe : [Select Product2Id, Pricebook2Id, Id, CurrencyIsoCode
                                      From PricebookEntry
                                      where Pricebook2.IsStandard = true and Pricebook2.IsActive=true
                                            and CurrencyIsoCode IN :isocodes
                                            and Product2Id IN : product2Ids]){
                if(!pb2IdToPBE.containsKey(pbe.Product2Id))
                    pb2IdToPBE.put(pbe.Product2Id, new List<PricebookEntry>{pbe});
                else
                    pb2IdToPBE.get(pbe.Product2Id).add(pbe);
            }
        Map<Id, List<ContractLineItem>> scIdToClis = new Map<Id, List<ContractLineItem>>();
        List<ServiceContract> scToBeUpdated = new List<ServiceContract>();
        Map<Id, ServiceContract> scIdVsSCMapRefresh = new Map<Id, ServiceContract>();
        Set<Id> scIds = new Set<Id>();
        List<ContractLineItem> list_OfHardwareCLI = new List<ContractLineItem>();
        for(ServiceContract eachSC : orderIdToSCMap.values())
            scIds.add(eachSC.id);
        //if(hardwareSC != null)
        //  scIds.add(hardwareSC.id);
        for(ServiceContract eachSC : [SELECT id, Flex_Care_CSM__c, Flex_Care_Optimization__c, StartDate, EndDate,
        Agreement_Status__c, Name, Previous_Maint_Rate__c, Current_Maint_Rate__c FROM ServiceContract WHERE id IN : scIds]){
            scIdVsSCMapRefresh.put(eachSC.id, eachSC);
        }

        Boolean flexCareCSMFlag = false;
        Boolean flexCareOptFlag = false;
        for(Order_Line_Item__c oli : olis){
            ContractLineItem c = new ContractLineItem();//DynamicFieldMapping.getSCLineItemFromOrderLineItem(oli, 'Genesys_Renewal');
            ServiceContract sc = scIdVsSCMapRefresh.get(orderIdToSCMap.get(oli.Order__c).id);
            /*
            ServiceContract hardwareSCFresh;
            if(hardwareSC != null)
                hardwareSCFresh = scIdVsSCMapRefresh.get(hardwareSC.id);
            */
            if(flexCareCSMFlag == false && sc.Flex_Care_CSM__c == false &&
                    oli.Product__r.Description != null && oli.Product__r.Description.startsWith('Flex Care-Opt')){
                if(scToBeUpdated.isEmpty()){
                    sc.Flex_Care_CSM__c = true;
                    scToBeUpdated.add(sc);
                }
                else
                    scToBeUpdated[0].Flex_Care_CSM__c = true;
                flexCareCSMFlag = true;
            }
            if(flexCareOptFlag == false && sc.Flex_Care_Optimization__c == false &&
                    oli.Product__r.Description != null && oli.Product__r.Description.startsWith('Flex Care-CSM')){
                if(scToBeUpdated.isEmpty()){
                    sc.Flex_Care_Optimization__c = true;
                    scToBeUpdated.add(sc);
                }
                else
                    scToBeUpdated[0].Flex_Care_Optimization__c = true;
                flexCareOptFlag = true;
            }
            c.Order_Line_Item__c = oli.id;
            c.ServiceContractId = sc.Id;
            c.Quantity = oli.BigMachines_Quantity__c;
            if(pb2IdToPBE.get(oli.Product__c) != null)
                for(PricebookEntry pbe : pb2IdToPBE.get(oli.Product__c)){
                    if(pbe.CurrencyIsoCode == oli.Order__r.CurrencyIsoCode)
                    c.PricebookEntryId = pbe.Id;
                }
            System.debug('NKC debug c.PricebookEntryId [' + c.PricebookEntryId +']');
            System.debug('NKC debug oli.Product__c ['+ oli.Product__c +']');

            c.UnitPrice = oli.Sales_Price__c != NULL ? oli.Sales_Price__c : 0;


            c.Sold_To_Name_Lookup__c = oli.Order__r.Sold_To_Name__c;
            ///*
            c.Upgraded_Product__c = oli.Product__c;
            c.Quote_Product__c = oli.Quote_Product__c;
            if(oli.Order__r.Offering_Type__c == 'PureEngage Subscription' || oli.Order__r.Offering_Type__c == 'PureConnect Subscription'){
                c.StartDate = oli.Maintenance_Start_Date__c;
                c.EndDate = oli.Maintenance_End_Date__c;
                c.Maintenance_Start_Date__c = oli.Maintenance_Start_Date__c;
                c.Maintenance_End_Date__c = oli.Maintenance_End_Date__c;
            }
            else{
                c.StartDate = sc.StartDate;
                c.EndDate = sc.EndDate;
                c.Maintenance_Start_Date__c = sc.StartDate;
                c.Maintenance_End_Date__c = sc.EndDate;
            }
            c.Agreement_Status__c = sc.Agreement_Status__c;
            //*/
            c.Original_License_Invoice__c = oli.Order__r.Invoice_Number__c;
            if(oppsMap.get(oli.Order__r.Opportunity__c) != null && oppsMap.get(oli.Order__r.Opportunity__c).RecordType.DeveloperName == OPP_GEN_NEW_DEV_NAME){
              c.Lic_Invoice__c = oli.Order__r.Invoice_Number__c;
            }
            else{
              c.Lic_Invoice__c = oli.Lic_Invoice__c;
            }
            c.Original_License_Invoice_Date__c = oli.Order__r.Original_License_Invoice_Date__c;
            c.Original_PO__c = oli.Order__r.PO_Number__c;

            //c.Previous_Line_Maintenance_Value__c = oli.Maintenance_Due__c;
            // Storing Annualized Maintenance Due as the Previous Annualized Value for Service Contract
            c.Previous_Line_Maintenance_Value__c = oli.Annualized_Maintenance_Due__c;
            c.Revised_Net_License_value__c = oli.Order__r.Revised_Net_License_Value__c;
            c.Maintenance_Level__c = oli.Order__r.Maintenance_Level__c;
            ///*
            c.End_Support_Date__c = oli.End_Support_Date__c;
            c.Fees_Applied__c = oli.Fees_Applied__c;
            c.Comments__c = oli.Comment__c;
            c.Genesys_Care_Rate__c = oli.Genesys_Care_Rate__c;
            c.Increase__c = oli.Increase__c;
            c.Revised_net_license_value__c = oli.Revised_net_license_value__c;
            c.Extended_End_of_Support__c = oli.Extended_End_of_Support__c;
            c.Sold_To_Name__c = oli.Sold_To_Name__c;
            c.End_User_Name__c = oli.End_User_Name__c;
            c.Maintenance_Start_Date__c = oli.Maintenance_Start_Date__c;
            c.Maintenance_End_Date__c = oli.Maintenance_End_Date__c;
            //*/
            c.Agreement_Status__c = sc.Agreement_Status__c;
            c.Previous_Maintenance_Rate__c = sc.Previous_Maint_Rate__c;
            c.Current_Maintenance_Rate__c = sc.Current_Maint_Rate__c;
            c.Annualized_Maintenance_Due__c = oli.Annualized_Maintenance_Due__c;

            c.Contract_Line_Item__c = oli.Service_Contract_Line_ID__c;
            c.Non_Billable__c = oli.Contract_Line_Item__r.Non_Billable__c;

            // 1/21/2015 : To Copy additional information for PS product (if present)
            c.Project_ID__c = oli.Project_ID__c;
            c.Project_Name__c = oli.Project_Name__c;
            c.Third_Party_Partner__c = oli.Third_Party_Partners__c;
            c.Third_Party_Applications__c = oli.Third_Party_Applications__c;
            c.Third_Party_Partner_Fee__c = oli.Third_Party_Partner_Fee__c;
            c.Solution_Name__c = oli.Solution_Names_Covered__c;
            c.Application_Support_Cost_Base__c = oli.Application_Support_Cost_Base__c;

            //Ramar added to populate value from oreder to SC line item
            c.CX_Platform__c = oli.CX_Platform__c;

            if(Test.isRunningTest() || oppsMap.get(oli.Order__r.Opportunity__c).RecordType.DeveloperName == OPP_GEN_RENEWAL_DEV_NAME){
                //*
                c.Original_Net_License_value__c = oli.Original_Net_License_value__c;
                c.Revised_Net_License_value__c =  oli.Total_Price__c;
                c.Current_Quantity__c = oli.BigMachines_Quantity__c;
                c.Original_Quantity__c = oli.Original_Qty__c;
                //*/
            }
            if(Test.isRunningTest() || oppsMap.get(oli.Order__r.Opportunity__c).RecordType.DeveloperName == OPP_GEN_NEW_DEV_NAME){
                c.Original_Net_License_value__c = oli.Total_Price__c;
                c.Revised_Net_License_value__c = oli.Total_Price__c;
                c.Current_Quantity__c = oli.BigMachines_Quantity__c;
                c.Original_Quantity__c = oli.BigMachines_Quantity__c;
                c.Maintenance_Start_Date__c = oli.Order__r.Maintenance_Start__c;
                c.Maintenance_End_Date__c =  oli.Order__r.Maintenance_End__c;
            }
            System.debug('NKC debug oli.Order__r.Quote__r.Quote_Business_Type__c ['+oli.Order__r.Quote__r.Quote_Business_Type__c+']');
            if(oli.Order__r.Quote__r.Quote_Business_Type__c == 'Renewal')
            {
                // Maintenance Due should not be 0 for Flex Care and Fees products

                System.debug('NKC' +oli.Product__r.Type__c);
                if(oli.Product__r.Type__c == 'Genesys Care') {
                c.Revised_Net_License_value__c = 0;
                c.Original_Quantity__c = 0;
                c.Annualized_Maintenance_Due__c = 0;
                c.Previous_Line_Maintenance_Value__c = 0;
                c.Lic_Invoice__c = '';
                }

               else
               {

                if(oli.Product__r.Type__c != 'Flex Care' && oli.Product__r.Type__c != 'Fees')
                {
                    c.Year1_Maintenance_Due__c = oli.Year1_Maintenance_Due__c;
                    c.Year2_Maintenance_Due__c = oli.Year2_Maintenance_Due__c;
                    c.Year3_Maintenance_Due__c = oli.Year3_Maintenance_Due__c;
                    c.Year4_Maintenance_Due__c = oli.Year4_Maintenance_Due__c;
                    c.Year5_Maintenance_Due__c = oli.Year5_Maintenance_Due__c;

                    c.Genesys_Care_Rate__c = oli.Genesys_Care_Rate__c;
                    c.Year2_CareRatePercent__c = oli.Year2_CareRatePercent__c;
                    c.Year3_CareRatePercent__c = oli.Year3_CareRatePercent__c;
                    c.Year4_CareRatePercent__c = oli.Year4_CareRatePercent__c;
                    c.Year5_CareRatePercent__c = oli.Year5_CareRatePercent__c;

                    if(c.Year1_Maintenance_Due__c == null)
                        c.Year1_Maintenance_Due__c = 0;
                    if(c.Year2_Maintenance_Due__c == null)
                        c.Year2_Maintenance_Due__c = 0;
                    if(c.Year3_Maintenance_Due__c == null)
                        c.Year3_Maintenance_Due__c = 0;
                    if(c.Year4_Maintenance_Due__c == null)
                        c.Year4_Maintenance_Due__c = 0;
                    if(c.Year5_Maintenance_Due__c == null)
                        c.Year5_Maintenance_Due__c = 0;

                    c.Annualized_Maintenance_Due__c = c.Year1_Maintenance_Due__c + c.Year2_Maintenance_Due__c +
                            c.Year3_Maintenance_Due__c + c.Year4_Maintenance_Due__c + c.Year5_Maintenance_Due__c;
                }
                else
                {
                    // Maintenance Due
                    c.Annualized_Maintenance_Due__c = oli.Sales_Price__c;
                    // Annualized Maintenance Due
                    if(c.Annualized_Maintenance_Due__c != null &&
                        c.Maintenance_Start_Date__c != null && c.Maintenance_End_Date__c != null)
                    {
                        c.Previous_Line_Maintenance_Value__c = c.Annualized_Maintenance_Due__c * (12/Util.calculateDurationInMonths(c.Maintenance_Start_Date__c,c.Maintenance_End_Date__c));
                    }
                }
             }
            }

            if(blnSplitHardwareOrder && hardwareSC != null && setOfOLIForSeperateSC.contains(oli.id)){
                ContractLineItem hardwareCLI = c.clone(false, true, false, false);
                hardwareCLI.Non_Billable__c = true;
                hardwareCLI.ServiceContractId = hardwareSC.id;
                list_OfHardwareCLI.add(hardwareCLI);
                system.debug('########HardWareCLI'+list_OfHardwareCLI.size());//KK:10/12
            }
            if(blnSplitHardwareOrder && (oli.Product__r.Type__c == 'Maintenance' || oli.Product__r.Type__c == 'Genesys Care')){
                c.Revised_Net_License_value__c = 0;
                c.Annualized_Maintenance_Due__c = 0;
            }
            c.ServiceContractId = sc.Id;
            oliTocli.put(oli.Id, c);
            System.debug('NKC debug c.Annualized_Maintenance_Due__c ['+c.Annualized_Maintenance_Due__c+']');
            System.debug('NKC debug c.Original_Quantity__c ['+c.Original_Quantity__c+']');
            System.debug('NKC debug oli.BigMachines_Quantity__c ['+oli.BigMachines_Quantity__c+']');
            System.debug('NKC debug oli.Current_Qty__c; ['+oli.Current_Qty__c+']');


            if(!scIdToClis.containsKey(sc.Id))
                scIdToClis.put(sc.Id, new List<ContractLineItem>{c});
            else
                scIdToClis.get(sc.Id).add(c);
            if(Test.isRunningTest())
                return;
        }
        List<ContractLineItem> contractLineItemsToBeUpdated = oliTocli.values();
        system.debug('#######Maintenance Start Date and End Date'+contractLineItemsToBeUpdated);//kk:10/12
        system.debug('#######Maintenance Start Date and End Date'+contractLineItemsToBeUpdated.size());//kk:10/12
        contractLineItemsToBeUpdated.addAll(list_OfHardwareCLI);
        System.debug('NKC debug U = ' + UserInfo.getUserId());
        System.debug('RAO contractLineItemsToBeUpdated = ' + contractLineItemsToBeUpdated);
        if(!contractLineItemsToBeUpdated.isEmpty())
            insert contractLineItemsToBeUpdated;

        if(!scToBeUpdated.isEmpty()){
            update scToBeUpdated;
        }

        // update the order line items with the respective contract line item ids
        for(Order_Line_Item__c oli : olis){
            if(oliTocli.get(oli.Id) != null)
                oli.Contract_Line_Item__c = oliTocli.get(oli.Id).Id;
        }
        update olis;
    }

    public static void updateEntitlements(Map<Id, ServiceContract> oldMap, List<ServiceContract> newList){

        Map<Id, ServiceContract> updatedSCs = new Map<Id, ServiceContract>();
        for(ServiceContract sc : newList){
            ServiceContract oldSC = oldMap.get(sc.Id);
            if(sc.Agreement_Status__c != oldSC.Agreement_Status__c ||
               sc.StartDate != oldSc.StartDate || sc.EndDate != oldSC.EndDate)
                updatedSCs.put( sc.Id, sc );
        }
        if(!updatedSCs.isEmpty()){
            List<Entitlement> entitlements = [Select Id, Agreement_Status__c, ServiceContractID,
                                                     Support_Owner__c, Sold_To__c
                                              from Entitlement
                                              where ServiceContractID IN : updatedSCs.keySet()];
            for(Entitlement e : entitlements) {
                e.Agreement_Status__c = updatedSCs.get(e.ServiceContractID).Agreement_Status__c;
                e.StartDate = updatedSCs.get(e.ServiceContractID).StartDate;
                e.EndDate = updatedSCs.get(e.ServiceContractID).EndDate;
                if(e.Support_Owner__c == null )
                    e.Support_Owner__c = updatedSCs.get(e.ServiceContractID).Support_Owner__c;
            }

            if(!entitlements.isEmpty())
                update entitlements;
            TriggerFlowManager.SC_AFTER_ENTITLEMENT_UPDATION = false;
        }
    }

  public static void createEntitlements(List<ContractLineItem> newCLIs) {

        List<Entitlement> entitlements = new List<Entitlement>();
        List<ContractLineItem> clis = [Select Id, ServiceContractId,ServiceContract.Order__c,
                                              ServiceContract.End_User_Name__c, StartDate, EndDate,
                                              PricebookEntry.Product2.Type__c, ServiceContract.Sold_To_Name__c,
                                              AssetId, ServiceContract.Agreement_Status__c,
                                              ServiceContract.Support_Owner__c, ServiceContract.System_Integrator__c,
                                              PricebookEntry.Product2.Name, PricebookEntry.Product2Id
                                       from COntractLineItem where Id in : newCLIs];
        Set<Id> orderIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for(ContractLineItem cli : clis){
            orderIds.add(cli.ServiceContract.Order__c);
        }
        Map<Id, Order__c> ordersMap = new Map<Id, Order__c>([Select Id, Opportunity__r.AccountId
                                                             from Order__c where Id IN : orderIds]);

        for(ContractLineItem cli : clis){
            if(cli.PricebookEntry.Product2.Type__c == GENESYS_CARE || cli.PricebookEntry.Product2.Type__c == MAINTENANCE)
                productIds.add( cli.PricebookEntry.Product2Id );
        }
        map<id,Id> productIdToEntitlementProcessId = new map<Id, Id>();
        map<id, Id> entitlementTemplateIdToProductId = new map<Id, Id>();
        if(!productIds.isEmpty()){
            for(ProductEntitlementTemplate pe : [Select product2Id,  EntitlementTemplateId From ProductEntitlementTemplate where product2Id In: productIds])
                entitlementTemplateIdToProductId.put( pe.EntitlementTemplateId, pe.product2Id);
            if(!entitlementTemplateIdToProductId.isEmpty()){
                for(EntitlementTemplate e : [Select slaProcessId from EntitlementTemplate where Id in :entitlementTemplateIdToProductId.keySet()])
                {
                    Id productId = entitlementTemplateIdToProductId.get(e.Id);
                    productIdToEntitlementProcessId.put(productId, e.slaProcessId);
                }
            }

        }

        for(ContractLineItem cli : clis){
            if(cli.PricebookEntry.Product2.Type__c == GENESYS_CARE || cli.PricebookEntry.Product2.Type__c == MAINTENANCE){
                Entitlement e = new Entitlement();
                e.Name = cli.PricebookEntry.Product2.Name;
               // System.debug('NKC debug ordersMap.get(cli.ServiceContract.Order__c).Opportunity__r.AccountId ['+ordersMap.get(cli.ServiceContract.Order__c).Opportunity__r.AccountId+']');
                if(ordersMap.get(cli.ServiceContract.Order__c) != null)
                  e.AccountId = ordersMap.get(cli.ServiceContract.Order__c).Opportunity__r.AccountId;
                e.ContractLineItemId = cli.Id;
                e.ServiceContractId = cli.ServiceContractId;
                e.End_User__c = cli.ServiceContract.End_User_Name__c;
                e.Sold_To__c = cli.ServiceContract.Sold_To_Name__c;
                e.Support_Owner__c = cli.ServiceContract.Support_Owner__c;
                e.System_Integrator__c = cli.ServiceContract.System_Integrator__c;
                e.Agreement_Status__c = cli.ServiceContract.Agreement_Status__c;
                e.StartDate = cli.StartDate;
                e.EndDate = cli.EndDate;
                e.AssetId = cli.AssetId;
                if(productIdToEntitlementProcessId.get( cli.PricebookEntry.Product2Id ) != null){
                    e.SlaProcessId = productIdToEntitlementProcessId.get( cli.PricebookEntry.Product2Id );
                }
                if(e.Support_Owner__c == null)
                    e.Support_Owner__c = cli.ServiceContract.Support_Owner__c;
                entitlements.add(e);
            }

        }

        if(!entitlements.isEmpty())
            insert entitlements;
    }

    public static void createAssets(List< ContractLineItem> newCLIs){
      /*
        Map<Id,Asset> cliToAsset = new Map<Id, Asset>();
        List<ContractLineItem> clis = [Select Id, ServiceContractId, PricebookEntry.Product2Id,
                                              PricebookEntry.Product2.Name,
                                              ServiceContract.End_User_Name__c, ServiceContract.Sold_To_Name__c,
                                              ServiceContract.Support_Owner__c, ServiceContract.System_Integrator__c,
                                              ServiceContract.Order__c
                                       from ContractLineItem where Id in : newCLIs];
        Set<Id> orderIds = new Set<Id>();
        for(ContractLineItem cli : clis){
            orderIds.add(cli.ServiceContract.Order__c);
        }
        Map<Id, Order__c> ordersMap = new Map<Id, Order__c>([Select Id, Opportunity__r.AccountId
                                                             from Order__c where Id IN : orderIds]);
        for(ContractLineItem cli : clis){
            Asset a = new Asset();
            a.Name = cli.PricebookEntry.Product2.Name + ' Asset';
            a.AccountId = ordersMap.get(cli.ServiceContract.Order__c).Opportunity__r.AccountId;
            a.Product2Id = cli.PricebookEntry.Product2Id;
            a.End_User__c = cli.ServiceContract.End_User_Name__c;
            a.Sold_To__c = cli.ServiceContract.Sold_To_Name__c;
            a.Support_Owner__c = cli.ServiceContract.Support_Owner__c;
            a.System_Integrator__c = cli.ServiceContract.System_Integrator__c;
            cliToAsset.put(cli.Id, a);
        }
        //try{
            if(!cliToAsset.isEmpty())
                insert cliToAsset.values();
        //}catch(DMlexception ex){
            //Apexpages.addMessage( new Apexpages.Message(ApexPages.Severity.Error, 'There was an error while inserting Assets' + ex.GetMessage()));
        //}
        List<ContractLineItem> clisToUpdate = new List<ContractLineItem>();
        for(Id cliId : cliToAsset.keySet()){
            ContractLineItem cli = new ContractLineItem(Id=cliId, AssetId =cliToAsset.get(cliId).Id);
            clisToUpdate.add(cli);
        }
        //try{
            if(!clisToUpdate.isEmpty())
                update clisToUpdate;
        //}catch(Dmlexception ex){
            //Apexpages.addMessage( new Apexpages.Message(ApexPages.Severity.Error, 'There was an error while updating Contract Lines' + ex.GetMessage()));
        //}
    */
    }

    public static void createRenewalOpportunities( Set<Order__c> newOrders, Set<Id> quoteIds )
    {
        Map<Id, Opportunity> newOppsMap = new Map<Id, Opportunity>();
        ErrorLogUtil.insertLog(null, 'On Line # 569 - ' + newOrders, 'ServiceContractUtil');
        ErrorLogUtil.insertLog(null, 'On Line # 570 - ' + quoteIds, 'ServiceContractUtil');

        /* Lokesh - Dec 02, T-848985
        ** Additiona fields added in query - Opportunity__r.Account.PC_Contracted_Maintenance_Start_Date__c,
        ** Opportunity__r.Account.Auto_Renew_Anniversary__c, Opportunity__r.Lead_Offer__c, Opportunity__r.Account.Genesys_Care_Ops__c,
        ** Opportunity__r.Account.Genesys_Care_specialist__c, Opportunity__r.Account.Genesys_Care_Offering__c
        ** Updated field population logic on renewal opp to pull values from Original Opportunity only when attribute values on Account = null
        */
        Map<Id, Order__c> ordersMap = new Map<Id, Order__c>(
            [Select id,Opportunity__c, Opportunity__r.AccountId, Opportunity__r.Lines_of_Businesses__c, Opportunity__r.Support_Owner__c, Sold_To_Name__c,
                    Opportunity__r.Name,Opportunity__r.BusinessPartner__c, Opportunity__r.currencyISOCode,
                    Quote__r.BigMachines__Is_Primary__c, Quote__r.Total_Maintenance_Amount_Due__c,
                    Opportunity__r.Alternative_Sold_To__c, Opportunity__r.System_Integrator__c, Opportunity__r.sold_to_country__c,
                    Maintenance_Start__c, Maintenance_End__c, Opportunity__r.Country__c, Opportunity__r.OwnerId,
                    Opportunity__r.Direct_Sales__c, Opportunity__r.Non_revenue_Opportunity__c,Opportunity__r.Invoice_Date__c, Opportunity__r.Invoice__c,
                    Opportunity__r.PO_Date__c, Opportunity__r.PO_Number__c,  Opportunity__r.Type,
                    Opportunity__r.RecordType.DeveloperName,Decline_Maintenance__c,
                    Opportunity__r.Gene_Care_Specialist__c,Opportunity__r.Quote_Mtce_Ops__c,Opportunity__r.Quote_Genesys_Care__c,
                    Opportunity__r.Big_Four__c,Opportunity__r.Quote_Big_Six__c,Opportunity__r.Quote_Sales_Org__c,
                    Quote__r.current_maint_rate__c, RecordType.DeveloperName, End_User_Name__c,End_User_Name__r.Genesys_Care_Ops__c,End_User_Name__r.Genesys_Care_specialist__c,
                    Opportunity__r.Account.PC_Contracted_Maintenance_Start_Date__c,
                    Opportunity__r.Account.Auto_Renew_Anniversary__c, Opportunity__r.Lead_Offer__c, Opportunity__r.Account.Genesys_Care_Ops__c,
                    Opportunity__r.Account.Genesys_Care_specialist__c, Opportunity__r.Account.Genesys_Care_Offering__c,
                (Select Quarterly_Semi_Annual_Billing_Fee__c,Licensing_Reduction_Fee__c, Reinstatement_fee__c,
                     Partner_to_Partner_Uplift__c,Extended_End_of_Support__c,Partner_to_Direct__c,
                     Comments__c,Decreased_Quote_Reason__c,Cancelled_Quote_Reason__c,
                     Total_Discount__c,Sent_to_Customer__c,Genesys_Care_Rep_Name__c,
                     Genesys_Care_rep_Title__c,Genesys_Care_rep_Phone__c,Genesys_Care_Rep_Email__c,
                     Genesys_Care_Rep_Cell__c,Current_Maint_Rate__c,Previous_Maint_Rate__c,Bill_To_Name__c,
                     AccountId,Ship_To_Name__c,Sold_To_Name__c,Support_Owner__c,System_Integrator__c,
                     Big_Four__c,Big_Six__c,Sales_Org__c,SG2_Region__c,Genesys_Care__c,Id,Name,
                     End_User_Name__r.Name,Sold_To_Name__r.Name,StartDate, EndDate, Agreement_Status__c,
                     Maintenance_Amount__c,Maintenance_End_Date__c, Renewal_Opportunity__c, Mtce_Ops__c,Renewal_License__c
                From Service_Contracts__r WHERE Service_Contract_Type__c != 'Hardware') ,
                (SELECT Id FROM Opportunities__r LIMIT 1),
                (Select Id, Product__r.Type__c From Order_Line_Items__r where Product__r.Type__c = :GENESYS_CARE or Product__r.Type__c = :MAINTENANCE)
             from Order__c where Id IN :newOrders]);
        system.debug(quoteids);
        Map<Id,List<BigMachines__Quote_Product__c>> quoteIdToQLIs = new Map<Id,List<BigMachines__Quote_Product__c>>();
        for(BigMachines__Quote_Product__c qli : [Select Id, BigMachines__Total_Price__c, BigMachines__Quote__c
                                                 from BigMachines__Quote_Product__c
                                                 where BigMachines__Quote__c IN :quoteIds
                                                    and (BigMachines__Product__r.Type__c = :GENESYS_CARE or BigMachines__Product__r.Type__c = :MAINTENANCE)]){
            if(quoteIdToQLIs.containsKey(qli.BigMachines__Quote__c)){
                quoteIdToQLIs.get(qli.BigMachines__Quote__c).add(qli);
            }
            else
               quoteIdToQLIs.put(qli.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c>{qli});
        }
        ErrorLogUtil.insertLog(null, 'On Line # 609 - ' + quoteIdToQLIs, 'ServiceContractUtil');
       /* Yuvaraj Toomanysoql  List<RecordType> rTypes = [Select Id
                                   from RecordType
                                   where SobjectType='Opportunity' and DeveloperName = :OPP_GEN_RENEWAL_DEV_NAME];*/

        Id rTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for(Order__c o : newOrders)
        {
            //Naresh Kumar  - 05/07/2018    No renewal opportunity for rental orders.
            if(o.License_FYM_detail__c == 'Rental Order')
                continue;
            ErrorLogUtil.insertLog(o.Name, 'On Line # 615 - ' + o, 'ServiceContractUtil');
            // if there are no lines, set decline maintenance is true and order maint start and end date to true
            /*
            if(o.Order_Line_Items__r == null || o.Decline_Maintenance__c){
                o.Maintenance_Start__c = Date.today();
                o.Maintenance_End__c = Date.today();
            }
            else if(ordersMap.get(o.Id).Opportunity__r.RecordType.DeveloperName == OPP_GEN_NEW_DEV_NAME){
                if(o.Numb_of_Maint_Months__c == null) o.addError('Number of Maintenance Months cannot be null');
                if(date.today().day() <= 15)
                    o.Maintenance_Start__c = date.today().toStartOfMonth();
                else
                    o.Maintenance_Start__c = date.today().addMonths(1).toStartOfMonth();
                o.Maintenance_End__c = (o.Maintenance_Start__c.addMonths((Integer)o.Numb_of_Maint_Months__c)).addDays(-1);
            }
            */
            Opportunity opp = new Opportunity();
            // Fetching existing opportunity to prevent duplicate Opportunities from getting created
            if(ordersMap.get(o.Id).Opportunities__r.size() > 0)
                opp = ordersMap.get(o.Id).Opportunities__r[0];

            ServiceContract sc;
            ErrorLogUtil.insertLog(null, 'On Line # 633 - ' + ordersMap.get(o.Id).Service_Contracts__r.size(), 'ServiceContractUtil');
            if(ordersMap.get(o.Id).Service_Contracts__r.size() == 0)
                continue;
            sc = ordersMap.get(o.Id).Service_Contracts__r[0];
            Decimal totalAmount = 0.0;
            ErrorLogUtil.insertLog(sc.Name, 'On Line # 638 - ' + sc, 'ServiceContractUtil');
            if( quoteIdToQLIs.get(o.Quote__c) == null)
            {
                opp.Decline_Maintenance__c = true;
                opp.Opportunity_Status__c ='Declined';

            }
            else {
                for(BigMachines__Quote_Product__c qli : quoteIdToQLIs.get(o.Quote__c))
                {
                    totalAmount += qli.BigMachines__Total_Price__c;
                }

            }
            opp.StageName = '8.Renewal';
            opp.Name = 'Renewal -'+ sc.Sold_To_Name__r.Name + '-' + sc.End_User_Name__r.Name + '-' + sc.Name + '(' + Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day() +')';
            if(opp.Name.length() > 120)
                opp.Name = opp.Name.left(120);
            if((opp.Name).contains('Drop'))
              (opp.Name).replace('Drop','');

            ErrorLogUtil.insertLog(opp.Name, 'On Line # 658 - ' + sc, 'ServiceContractUtil');
            opp.RecordTypeId = rtypeId;

            if(o.Maintenance_End__c  != null)
             opp.Quote_Maintenance_Start_Date__c = o.Maintenance_End__c.addDays(1);

            /*
             //opp.Gene_Care_Specialist__c = ordersMap.get(o.Id).Opportunity__r.Gene_Care_Specialist__c;
             //Commenting above line and adding below line for INC0403624
            opp.Gene_Care_Specialist__c = ordersMap.get(o.Id).End_User_Name__r.Genesys_Care_specialist__c;
             //opp.Quote_Mtce_Ops__c = ordersMap.get(o.Id).Opportunity__r.Quote_Mtce_Ops__c;
             //Commenting above line and adding below line for INC0403624
             opp.Quote_Mtce_Ops__c = ordersMap.get(o.Id).End_User_Name__r.Genesys_Care_Ops__c;
             opp.Quote_Genesys_Care__c = ordersMap.get(o.Id).Opportunity__r.Quote_Genesys_Care__c;*/

             //Lokesh - Dec 02, T-848985 - Start
             opp.Gene_Care_Specialist__c = ordersMap.get(o.Id).Opportunity__r.Account.Genesys_Care_specialist__c !=  null ? ordersMap.get(o.Id).Opportunity__r.Account.Genesys_Care_specialist__c : ordersMap.get(o.Id).Opportunity__r.Gene_Care_Specialist__c;
             opp.Quote_Mtce_Ops__c = ordersMap.get(o.Id).Opportunity__r.Account.Genesys_Care_Ops__c != null ? ordersMap.get(o.Id).Opportunity__r.Account.Genesys_Care_Ops__c : ordersMap.get(o.Id).Opportunity__r.Quote_Mtce_Ops__c;
            //Lokesh Dec 02, Configuring override in OpportunityFieldPopulationHelper to this Util class
             opp.Quote_Genesys_Care__c = ordersMap.get(o.Id).Opportunity__r.Account.Genesys_Care_Offering__c != null ? ordersMap.get(o.Id).Opportunity__r.Account.Genesys_Care_Offering__c : ordersMap.get(o.Id).Opportunity__r.Quote_Genesys_Care__c;
             //Lokesh - Dec 02, T-848985 - End

             opp.Big_Four__c = ordersMap.get(o.Id).Opportunity__r.Big_Four__c;
             opp.Quote_Big_Six__c = ordersMap.get(o.Id).Opportunity__r.Quote_Big_Six__c;
             opp.Quote_Sales_Org__c = ordersMap.get(o.Id).Opportunity__r.Quote_Sales_Org__c;
             opp.Opportunity_Status__c = 'In Progress';
             opp.Forecast_Status__c = 'Pipeline';
             opp.Lines_of_Businesses__c =  ordersMap.get(o.Id).Opportunity__r.Lines_of_Businesses__c;
           if(o.Maintenance_End__c  != null)
            opp.CloseDate = o.Maintenance_End__c.addDays(-1);
           else
            opp.CloseDate = Date.today();

            opp.Current_Maintenance_Rate__c = sc.Current_Maint_Rate__c;
            opp.Support_Owner__c = ordersMap.get(o.Id).Opportunity__r.Support_Owner__c;
            opp.Alternative_Sold_To__c = ordersMap.get(o.Id).Opportunity__r.Alternative_Sold_To__c;
            opp.System_Integrator__c = ordersMap.get(o.Id).Opportunity__r.System_Integrator__c;

            opp.Country__c = ordersMap.get(o.Id).Opportunity__r.Country__c;
            opp.Amount = totalAmount;
            opp.sold_to_country__c = ordersMap.get(o.Id).Opportunity__r.sold_to_country__c;
            opp.OwnerId = ordersMap.get(o.Id).Opportunity__r.OwnerId;
            opp.currencyISOCode = ordersMap.get(o.Id).Opportunity__r.currencyISOCode;
            opp.Direct_Sales__c = ordersMap.get(o.Id).Opportunity__r.Direct_Sales__c;
            opp.Non_revenue_Opportunity__c = ordersMap.get(o.Id).Opportunity__r.Non_revenue_Opportunity__c;
            opp.AccountId = ordersMap.get(o.Id).Opportunity__r.AccountId;
            if(ordersMap.get(o.id).RecordType.DeveloperName== 'Non_Revenue_Orders')
                opp.AccountId = ordersMap.get(o.Id).End_User_Name__c;
            opp.Service_Contract__c = sc.id;
            opp.Previous_Maintenance_Rate__c = ordersMap.get(o.Id).Quote__r.current_maint_rate__c;
            // Source order
            opp.Source_Order__c = o.Id;

            //Lokesh - Dec 02, T-848985
            if(String.isNotBlank(ordersMap.get(o.Id).Opportunity__r.Lead_Offer__c) && ordersMap.get(o.Id).Opportunity__r.Lead_Offer__c.startsWith('PureConnect')) {
                opp.PC_Contracted_Maintenance_Start_Date__c = ordersMap.get(o.Id).Opportunity__r.Account.PC_Contracted_Maintenance_Start_Date__c;
            } else if(String.isNotBlank(ordersMap.get(o.Id).Opportunity__r.Lead_Offer__c) && ordersMap.get(o.Id).Opportunity__r.Lead_Offer__c.startsWith('PureEngage')) {
                opp.PE_Contracted_Maintenance_Start_Date__c = ordersMap.get(o.Id).Opportunity__r.Account.Auto_Renew_Anniversary__c;
            }

            //opp.Quarterly_Semi_Annual_Billing_Fee__c = sc.Quarterly_Semi_Annual_Billing_Fee__c;
            //opp.Licensing_Reduction_Fee__c = sc.Licensing_Reduction_Fee__c;
            //opp.Reinstatement_fee__c = sc.Reinstatement_fee__c;
            //opp.Partner_to_Partner_Uplift__c = sc.Partner_to_Partner_Uplift__c;
            //opp.Extended_End_of_Support__c = sc.Extended_End_of_Support__c;
            //opp.Partner_to_Direct__c = sc.Partner_to_Direct__c;
            opp.Comments__c = sc.Comments__c;
            opp.Decreased_Quote_Reason__c = sc.Decreased_Quote_Reason__c;
            opp.Quote_Cancelled_Quote_Reason__c = sc.Cancelled_Quote_Reason__c;
            opp.Total_Discount__c = sc.Total_Discount__c;
            //opp.Sent_to_Customer__c = sc.Sent_to_Customer__c;
            //opp.Genesys_Care_Rep_Name__c = sc.Genesys_Care_Rep_Name__c;
            opp.Genesys_Care_rep_Title__c = sc.Genesys_Care_rep_Title__c;
            //opp.Genesys_Care_rep_Phone__c = sc.Genesys_Care_rep_Phone__c;
            //opp.Genesys_Care_Rep_Email__c = sc.Genesys_Care_Rep_Email__c;
            opp.Genesys_Care_Rep_Cell__c = sc.Genesys_Care_Rep_Cell__c;

            /*
            if( quoteIdToQLIs.get(o.Quote__c) != null) {
             opp.Invoice_Date__c = o.Invoice_Date__c;
             opp.Invoice__c = o.Invoice_Number__c;
             opp.PO_Date__c = o.PO_Date__c;
             opp.PO_Number__c = o.PO_Number__c;
            }
            */

            //opp.Previous_Maintenance_Rate__c = sc.Previous_Maint_Rate__c;
            opp.Previous_Service_Contract_Amount__c = sc.Maintenance_Amount__c;
            opp.Bill_To_Name__c = sc.Bill_To_Name__c;
            opp.Ship_To_Name__c = sc.Ship_To_Name__c;
            if(ordersMap.get(o.id).Opportunity__r.Direct_Sales__c)
                opp.BusinessPartner__c = ordersMap.get(o.id).Opportunity__r.AccountId;
            else
                opp.BusinessPartner__c = sc.Sold_To_Name__c;

            if(ordersMap.get(o.id).RecordType.DeveloperName == 'Non_Revenue_Orders')
                opp.BusinessPartner__c = ordersMap.get(o.id).Sold_To_Name__c;
            opp.Support_Owner__c = sc.Support_Owner__c;
            if(opp.Support_Owner__c == null)
                opp.Support_Owner__c = sc.Sold_To_Name__c;
            opp.System_Integrator__c = sc.System_Integrator__c;
            //opp.Big_Four__c = sc.Big_Four__c;
            //opp.Quote_Big_Six__c = sc.Big_Six__c;
            //opp.Quote_Sales_Org__c = sc.Sales_Org__c;
            opp.Quote_SG2_Region__c = sc.SG2_Region__c;
            //opp.Quote_Genesys_Care__c = sc.Genesys_Care__c;
            //opp.Quote_Mtce_Ops__c = sc.Mtce_Ops__c;
            opp.Type = ordersMap.get(o.Id).Opportunity__r.Type;
            if(Owner_Settings__c.getValues('Renewal Opp Owner') != null)
                opp.OwnerId = Owner_Settings__c.getValues('Renewal Opp Owner').Owner_Id__c;
            newOppsMap.put(o.Id, opp);

        }
        if(newOppsMap!= null && !newOppsMap.isEmpty())
            upsert newOppsMap.values();

        ErrorLogUtil.insertLog(null, 'On Line # 749 - ' + newOppsMap.values().size(), 'ServiceContractUtil');
        ErrorLogUtil.insertLog(null, 'On Line # 750 - ' + newOppsMap.values(), 'ServiceContractUtil');

        Map<Id, Order__c> oppIdToOrder = new Map<Id, Order__c> ();
        for(Id oId : newOppsMap.keySet()){
            // NEW -no stage update but update the renewal opp field on the initital opp
            if(ordersMap.get(oId).Opportunity__c != null){
                Opportunity opp = new Opportunity(Id = ordersMap.get(oId).Opportunity__c);
                opp.Renewal_Opportunity__c = newOppsMap.get(oId).Id;
                if(ordersMap.get(oId).Sold_To_Name__c != ordersMap.get(oId).Opportunity__r.BusinessPartner__c && !ordersMap.get(oId).Opportunity__r.Direct_Sales__c)
                    opp.BusinessPartner__c = ordersMap.get(oId).Sold_To_Name__c;
                oppsToUpdate.add(opp);
                oppIdToOrder.put(ordersMap.get(oId).Opportunity__c, ordersMap.get(oId));
            }
        }
        ErrorLogUtil.insertLog(null, 'On Line # 762 - ' + oppsToUpdate, 'ServiceContractUtil');
        if(!oppsToUpdate.isEmpty())
            update oppsToUpdate;

        if(!ordersMap.isEmpty())
            updateServiceContractsAndLineItems( ordersMap , newOppsMap);
    }


    static Map<Id, Order__c> getOrdersOppIds(Set<Id> orderIds ){
        Map<Id, Order__c> oppIdToOrder = new Map<Id, Order__c> ();
        for(Order__c o : [Select Id, Maintenance_Start__c, Opportunity__c from Order__c where Id IN :orderIds])
            oppIdToOrder.put(o.Opportunity__c, o);
        return oppIdToOrder;
    }

    static Map<Id, Order__c> getCoTermOpps(Map<Id, Order__c> oppIdToOrder){
        Map<Id, Order__c> coTermOppIdToORder = new Map<Id, Order__c>();
        for(Opportunity o : [Select Id, (Select Id From Opportunities1__r where RecordType.DeveloperName = 'Genesys_Renewal')
                             From Opportunity
                             where Id IN :oppIdToOrder.keySet()]) {
            for(Opportunity opp : o.Opportunities1__r){
                Order__c od = oppIdToOrder.get(o.Id);
                if(!coTermOppIdToORder.containsKey(opp.Id))
                    coTermOppIdToORder.put(opp.Id, od);
            }
        }
        return coTermOppIdToORder;
    }

    // for cotermed opportunities, close the service contracts
    static void closeSCsForCoTermOpps(Map<Id, Order__c> coTermOppIdToORder){
        List<ServiceContract> scsToUpdate = new List<ServiceContract>();
        for(Order__c o : [Select Id, Opportunity__c ,
                                (Select Id, EndDate,  Status From Service_Contracts__r)
                          from Order__c
                          where Opportunity__c IN : coTermOppIdToORder.keyset()]){
            for( ServiceContract sc : o.Service_Contracts__r ) {
                sc.EndDate = coTermOppIdToORder.get( o.Opportunity__c).Maintenance_Start__c.addDays(-1) ;
                scsToUpdate.add( sc );
            }
        }
        if(!scsToUpdate.isEmpty()) {
            update scsToUpdate;
            // check the cotermed checkbox on clis
            updateContractlineItems(scsToUpdate, true);
        }
    }
    //Updating dates on SC line items when they get updated on SC
    public static void populateDatesOnSCLineItems(Map<Id, ServiceContract> newMap, Map<Id, ServiceContract> oldMap){
      Set<Id> updatedSCs = new Set<Id>();
      for(ServiceContract eachSC : newMap.values()){
          if(eachSC.Override_Lines_Date_From_Header__c && eachSC.Override_Lines_Date_From_Header__c != oldMap.get(eachSC.id).Override_Lines_Date_From_Header__c ){
              updatedSCs.add(eachSC.id);
          }
      }
      if(updatedSCs.isEmpty())
        return;
      List<ContractLineItem> scLineItemsToBeUpdated = [SELECT Maintenance_Start_Date__c, Maintenance_End_Date__c, ServiceContractId FROM ContractLineItem
            WHERE ServiceContractId IN : updatedSCs];

      for(ContractLineItem eachItem : scLineItemsToBeUpdated){
           eachItem.Maintenance_Start_Date__c = newMap.get(eachItem.ServiceContractId).StartDate;
           eachItem.Maintenance_End_Date__c = newMap.get(eachItem.ServiceContractId).EndDate;
      }
      update scLineItemsToBeUpdated;
   }
    // for invoiced orders, activate the service contracts and contract line items
    public static void updateServiceContractsAndLineItems( Map<Id, Order__c> ordersMap, Map<Id, Opportunity> newOppsMap ){
      //return;
        Map<Id, ServiceCOntract> scsToUpdate = new Map<Id, ServiceContract>();
        system.debug(newOppsMap);
        for(Order__c o : ordersMap.values()){
            ErrorLogUtil.insertLog(null, 'On Line # 835 - ' + o, 'ServiceContractUtil');
            for( ServiceContract sc : o.Service_Contracts__r ){
                ErrorLogUtil.insertLog(sc.Name, 'On Line # 837 - ' + sc, 'ServiceContractUtil');
                 sc.StartDate = o.Maintenance_Start__c;
                 sc.EndDate = o.Maintenance_End__c;
                 sc.Quote_Name__c = o.Quote__c;
                if(o.Decline_Maintenance__c)
                 sc.Agreement_Status__c = 'Declined';
                else
                 sc.Agreement_Status__c = 'Active';

                if(newOppsMap.get(o.Id) != null){
                    sc.Renewal_Opportunity__c = newOppsMap.get(o.Id).Id;
                    sc.Co_Term_Opportunity__c = newOppsMap.get(o.Id).Id;
                }
                // NEW update the renewal Opp field on Service contract
                scsToUpdate.put(sc.Id, sc);
            }
        }
        ErrorLogUtil.insertLog(null, 'On Line # 852 - ' + scsToUpdate, 'ServiceContractUtil');
        if(!scsToUpdate.isEmpty()){
            update scsToUpdate.values();
            List<ContractLineItem> clis = getClis(scsToUpdate.values());
            if(!clis.isEMpty()){
                for(ContractLineItem cli : clis){
                    cli.Agreement_Status__c = 'Active';
                    if(cli.ServiceContract.Renewal_License__c != 'Renewal')
                        cli.Original_License_Invoice_Date__c = cli.ServiceContract.Order__r.Invoice_Date__c;
                    cli.StartDate = scsToUpdate.get(cli.ServiceContractId).startDate;
                    cli.EndDate = scsToUpdate.get(cli.ServiceContractId).endDate;
                    //Naresh Kumar  05/20/2014
                    //We don't want to change sc line item dates when order status is completed.
                    //cli.Maintenance_Start_Date__c = scsToUpdate.get(cli.ServiceContractId).startDate;
                    //cli.Maintenance_End_Date__c = scsToUpdate.get(cli.ServiceContractId).endDate;
                }
                update clis;
            }
        }
    }

    //  get contractlineItems for service contracts
    public static List<ContractLineItem> getClis( List<ServiceContract> scs){
        return [Select StartDate, EndDate, ServiceContractId, Id, Co_termed__c, Original_License_Invoice_Date__c, ServiceContract.Renewal_License__c,
                ServiceContract.Order__r.Invoice_Date__c
                from ContractLineItem
                where ServiceContractId IN :scs];
    }

    // update contractLineItems to cotermed for deactivated service contracts
    public static void updateContractlineItems(List<ServiceContract> newSCs, Boolean isCotermed){
        List<ContractLineItem> clis = getClis(newScs);
        if(!clis.isEmpty()){
            for(ContractLineItem cli : clis ){
                cli.Co_termed__c = isCotermed;
            }
            update clis;
        }
    }

    public static void addFtpAccess( List<ServiceContract> newScs ){
        List<FTP_Access__c> faList = new List<FTP_Access__c>();
        for( ServiceContract sc: newScs ){
            String soldToSAP = '';
            String endUserSAP = '';

            List<Account> acctList = [SELECT Id, SAP_Account_Code__c FROM Account
                                      WHERE ID = :sc.Sold_To_Name__c
                                         OR ID = :sc.End_User_Name__c];

            if ( acctList.size() != 2 )
                 continue;

            Map<ID, Account> acctMap = new Map<ID, Account>(acctList);
            soldToSAP = acctMap.get(sc.Sold_To_Name__c).SAP_Account_Code__c;
            endUserSAP = acctMap.get(sc.End_User_Name__c).SAP_Account_Code__c;

            if ( soldToSAP == '' || endUserSAP == '' )
                 continue;

            Integer faNum =   [Select count() From FTP_Access__c
                               where SAP_Code_End_User__c = :endUserSAP
                                 and SAP_Code_Sold_To__c  = :soldToSAP];
            if ( faNum == 0 ) {
                FTP_Access__c fa = new FTP_Access__c();

                if ( sc.End_User_Name__c != null && sc.Sold_To_Name__c != null &&
                     (sc.Agreement_Status__c == 'Active' || sc.Agreement_Status__c == 'Pending') )  {

                    fa.End_User_Account__c = sc.End_User_Name__c;
                    fa.Sold_To_Account__c = sc.Sold_To_Name__c;
                    fa.FTP_User_Name__c = GenerateFtpAccount.GenFtpAccount();
                    fa.FTP_Password__c = GenerateFtpPassword.GenPasswd();
                    faList.add(fa);

                    try{
                        if(!faList.isEmpty())
                            insert faList;
                    } catch(DMLexception ex){
                        //;
                    }
                }
            }
        }
    }
}