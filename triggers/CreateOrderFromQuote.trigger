trigger CreateOrderFromQuote on BigMachines__Quote__c (after update) {
    
    
    //Skipping create ordr process for CIC and CaaS quotes.
    if (Util.Bypass_Trigger_Chk  ||(Trigger.new[0].Offering_Type__c == QuoteUtil.OFFERING_TYPE_CIC  || Trigger.new[0].Offering_Type__c == QuoteUtil.OFFERING_TYPE_CAAS
                                    || Trigger.new[0].Offering_Type__c == 'PureEngage Subscription' || Trigger.new[0].Offering_Type__c == 'PureConnect Subscription'  
                                    || Trigger.new[0].Offering_Type__c == 'Cloud Partner (PPU)' || Trigger.new[0].Offering_Type__c == null) && Trigger.new[0].Quote_Business_Type__c != 'Renewal')
        return;
    
    List <Order__c> orders = new List<Order__c>();
    BigMachines__Quote__c quote = Trigger.new[0];
    boolean updateFlag = false;
    boolean exec = false;
    boolean sep_po = false;
    String id = '';
    Order__c order;
    string license_status;
    string region = '';
    string opp_ownerid;
    string owner_email;
    string recType;
    Date tempStart;
    Date tempEnd;
    integer tempTerm;
    Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice = new Map<String, BigMachines__Quote_Product__c>();
    Map<String, BigMachines__Quote_Product__c> mapPSAlacartItems = new Map<String, BigMachines__Quote_Product__c>();
    Map<String, BigMachines__Quote_Product__c> mapPSOfferItems = new Map<String, BigMachines__Quote_Product__c>();
    Order__c pureSuccessChildOrder;
    Order__c obj_NewOneTimeOrder;
    Id recordTypeIdForOLI = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Cloud Billing Master Order Line').getRecordTypeId();
    
    List<Opportunity> opp = [
        Select id, RecordType.DeveloperName, country_region__c, ownerid, owner.email, Gene_Care_Specialist__r.Email,
        Quote_Mtce_Ops__r.Email, Lines_of_Businesses__c,
        account.Subsidary__c
        from opportunity
        where id = :trigger.new[0].BigMachines__Opportunity__c
    ];
    System.debug(LoggingLevel.Error, '------CreateOrderFromQuote=');
    
    if (opp.size() > 0) {
        opp_ownerid = opp[0].ownerid;
        owner_email = opp[0].owner.email;
        if (opp[0].country_region__c != null)
            region = opp[0].country_region__c;
        recType = opp[0].RecordType.DeveloperName;
    }
    
    Id recTpId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('PS Orders').getRecordTypeId();
    
    //License Quote
    List <Order__c> checkOrder = [
        select id
        from Order__c
        where Quote__c = :quote.id
        and (License_FYM_detail__c = 'License only order'
             or License_FYM_detail__c = 'Both License & Maintenance Order' or (License_FYM_Detail__c = 'PS Orders' AND RecordTypeId=:recTpId))
    ];
    id license_orderid;
    if (checkOrder.size() > 0) {
        updateFlag = true;
    }
    
    System.debug('NKC debug quote.BigMachines__Status__c [' + quote.BigMachines__Status__c + ']');
    //System.debug('NKC debug Trigger.oldMap.get(quote.id).BigMachines__Status__c [' + Trigger.oldMap.get(quote.id).BigMachines__Status__c + ']');
    
    //Check for status
    if (quote.BigMachines__Status__c == 'Order Submitted' && Trigger.oldMap.get(quote.id).BigMachines__Status__c != 'Order Submitted') {
        exec = true;
        System.debug(LoggingLevel.Error, '------exec=' + exec);
    }
    
    //Set the License order Status
    if (quote.PO_for_FYM__c == 'Separate PO for FYM') {
        sep_po = true;
        license_status = 'License only order';
    } else {
        license_status = 'Both License & Maintenance Order';
    }
    
    //insert License Order
    if (!updateFlag && exec) {
        System.debug(LoggingLevel.Error, '------Create_Order=');
        order = Create_Order.Insert_Orders(quote, 'Submitted', license_status, region, owner_email, recType, opp[0]);
        //Anju Jan 2018 PureSuccess starts
        if(quote.Offering_Type__c == 'Business Edition')
            OrderCloudUtil.insertPureSuccessItemsFromOffer(quote);
        insert order;
        //create child order for PureSuccess
        if(quote.Offering_Type__c == 'Business Edition' && (quote.PureSuccess__c != null ||(quote.Does_customer_currently_have_PureSuccess__c && quote.A_La_Carte_PureSuccess_Services_Amount__c > 0))){
            pureSuccessChildOrder = order.clone();
            pureSuccessChildOrder.name = (pureSuccessChildOrder.name + Label.PureSuccess_Child_Order_Name).left(80);
            pureSuccessChildOrder.recordtypeid = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
            pureSuccessChildOrder.Original_Parent_Order1__c = order.id;
            pureSuccessChildOrder.ownerid = QuoteUtil.getOrderManagementQueue(quote.id);
            pureSuccessChildOrder.Order_Type__c = 'Revenue';
            pureSuccessChildOrder.License_FYM_detail__c = 'Subscription Order';
            pureSuccessChildOrder.Year__c = '1';
            pureSuccessChildOrder.Numb_of_Maint_Months__c = 12;
            pureSuccessChildOrder.Maintenance_Start__c = system.today();
            pureSuccessChildOrder.Maintenance_End__c = system.today().addmonths(12) - 1; 
            pureSuccessChildOrder.Annual_Contract_Value__c = pureSuccessChildOrder.CMRR__c = 0;
            pureSuccessChildOrder.TCV__c = quote.A_La_Carte_PureSuccess_Services_Amount__c + quote.PureSuccess_Offer_Subscription_Amount__c;
            order.TCV__c = order.TCV__c - pureSuccessChildOrder.TCV__c;
            update order;
            if(pureSuccessChildOrder.TCV__c == 0 || pureSuccessChildOrder.TCV__c ==  null)
                pureSuccessChildOrder.status__c = 'Completed';
            insert pureSuccessChildOrder;
            System.Debug('Inserted PureSuccess Child Order for PEC');//Rony Joseph - March 14th 2019
            //lineitems
            //QuoteUtil.insertPureSuccessItemsFromOffer(quote);  
            
            
        }
        
        //linking address
        if(quote.Offering_Type__c == 'Business Edition'){
            List<Account_Order_Address__c> listAddressOrderLink = new List<Account_Order_Address__c>();
            for(Account_Order_Address__c accAddress : [SELECT Address_Type__c, Address__c, Address2__c, City__c,State__c, Country__c,
                                                       Zip_Code__c, Phone__c, Fax__c, Sold_To_Business_Partner__c,Quote__c,Email__c, Additional_Emails__c,Attention_To__c FROM Account_Order_Address__c WHERE Quote__c = :quote.id])
            {
                if(accAddress.Address_Type__c == 'Bill To')
                {
                    listAddressOrderLink.add(new Account_Order_Address__c(id=accAddress.id,Order__c=order.id));
                    Account_Order_Address__c objChildorderAddress = accAddress.clone();
                    objChildorderAddress.Quote__c =  null;
                    if(pureSuccessChildOrder != null){
                        objChildorderAddress.Order__c=pureSuccessChildOrder.id;
                        listAddressOrderLink.add(objChildorderAddress);
                    }
                }    
                else if(pureSuccessChildOrder != null)
                {
                    listAddressOrderLink.add(new Account_Order_Address__c(id=accAddress.id,Order__c=pureSuccessChildOrder.id));
                }
            }
            if(listAddressOrderLink.size() > 0)
                system.debug(listAddressOrderLink);
            upsert listAddressOrderLink;
            system.debug(listAddressOrderLink);
        }
        //Anju Jan 2018 PureSuccess ends
        
        //Naresh Kumar 02/08/2016  Populating quote's order field.
        BigMachines__Quote__c quoteToBeUpdated = new BigMachines__Quote__c(id = quote.id);
        quoteToBeUpdated.Order__c = order.id;
        update quoteToBeUpdated;
        //if(opp.size() > 0 && opp[0].RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
        if (opp.size() > 0 && quote.Quote_Business_Type__c != 'Renewal' &&
            opp[0].RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME) {
                Order__Share OrderShare = new Order__Share();
                OrderShare.ParentId = order.Id;
                OrderShare.UserOrGroupId = opp_ownerid;
                OrderShare.AccessLevel = 'read';
                
                OrderShare.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
                insert OrderShare;
                
                //PureSuccess Anju Jan 2018
                if(pureSuccessChildOrder != null)
                {
                    Order__Share OrderSharePS = new Order__Share();
                    OrderSharePS.ParentId = pureSuccessChildOrder.Id;
                    OrderSharePS.UserOrGroupId = opp_ownerid;
                    OrderSharePS.AccessLevel = 'read';    
                    OrderSharePS.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
                    insert OrderSharePS;
                }
            }
        license_orderid = order.id;
        List<BigMachines__Quote_Product__c> list_QPTEmp = new List<BigMachines__Quote_Product__c>(); 
        List<Order_Line_Item__c> list_OrderLineItems = new  List<Order_Line_Item__c>();
        OrderCloudUtil.createOneTimeOrdersForPEC(order.id);
    }
    
    //update existing License Order
    if (updateFlag && exec) {
        if (quote.rejected_flag__c)
            order = Create_Order.Update_Orders(quote, checkOrder[0].id, 'Re-Submitted', license_status, region, owner_email, recType, opp[0]); else
                order = Create_Order.Update_Orders(quote, checkOrder[0].id, 'Submitted', license_status, region, owner_email, recType, opp[0]);
        
        update order;
        
        license_orderid = order.id;
        
        //Delete Order line items
        list<Order_Line_Item__c> oli_del = [select id from Order_Line_Item__c where order__c = :order.id];
        delete oli_del;
    }
    
    if (exec) {
        System.debug('Enetered exec');
        if (quote.Quote_Business_Type__c != 'Cloud') {
            // Insert attachment on primary order
            List<Attachment> attList = [select id, name, body from Attachment where ParentId = :quote.id];
            List<Attachment> insertAttList = new List<Attachment>();
            
            for (Attachment a: attList) {
                Attachment att = new Attachment(name = a.name, body = a.body, parentid = order.id);
                insertAttList.add(att);
            }
            
            if (insertAttList.size() > 0)
                insert insertAttList;
        }
        
        //insert order line items
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
        //mukunth added BigMachines__Product__r.POB_Type__c to query
        Sql_stmt += '   BigMachines__Product__c, BigMachines__Product__r.Type__c,BigMachines__Product__r.PS_Contract__c,BigMachines__Product__r.Name,BigMachines__Product__r.Description,';//lookup
        Sql_stmt += '   Maintenance_Start_Date__c,Year2_Maintenance_Due__c,Year3_Maintenance_Due__c,BigMachines__Product__r.POB_Type__c,Year4_Maintenance_Due__c,Year5_Maintenance_Due__c, ';
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
        //Ramar added to populate value from quote to order
        Sql_stmt += '   CX_Platform__c,';
        
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
        Sql_stmt += '   Extended_Price_Per_Period__c,';
        Sql_stmt += '   Service_Contract_Line_ID__c,';
        Sql_stmt += '   Annualized_Maintenance_Last_Period__c, Flavor__c,';
        // 1/21/2015 : To Copy additional information for PS product (if present)
        Sql_stmt += '   Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,';
        // 2/5/2015 : few more fields
        Sql_stmt += '   Application_Support_Cost_Base__c,Solution_Names_Covered__c,Third_Party_Partner_Fee__c,Bundle__r.Group_Type__c,Bundle_Line__c';
        Sql_stmt += '   From BigMachines__Quote_Product__c where  ';
        Sql_stmt += '   BigMachines__Quote__c= \'' + trigger.new[0].id + '\' AND (BigMachines__Product__r.Type__c != \'Bundle\' OR Bundle__r.Group_Type__c = \'Base Package\' OR Bundle__r.Group_Type__c = \'PureSuccess\' OR BigMachines__Product__r.Product_Group__c = \'PureSuccess Indirect Offer\' OR BigMachines__Product__r.Product_Group__c = \'PureSuccess Direct Offer\')';
        
        if (sep_po) {
            Sql_stmt += ' and ( BigMachines__Product__r.Type__c = \'Product - System License\' OR BigMachines__Product__r.Type__c = \'Product - Hardware\' OR BigMachines__Product__r.Type__c = \'Product\')';
        }
        
        if (quote.Is_GU_EMEA__c) {
            Sql_stmt += ' and BigMachines__Product__r.Type__c <> \'Genesys Care\'';
        }
        
        boolean flag ;
        String genesysCareProductId;
        String genesysCareProductName;
        String genesysCareProductDescription;
        Set<String> genesysPS = new Set<String>();
        Set<String> genesysCareFlexCareProductIds = new Set<String>();
        Set<String> genesysFeeProductIds = new Set<String>();
        Set<Id> psExpertApps = new Set<Id>();//Mukunth added for PS Expert Apps line POB update
        
        list<Order_Line_Item__c> oli_lst = new list<Order_Line_Item__c>();
        Order_Line_Item__c genesysCareLine;
        List<String> list_Types = Label.Types_Required_Add_Products.split(';');
        //Rony Joseph- March 24 2019 -One Time Charge Child Order
        List<BigMachines__Quote_Product__c> list_OneTimeQP = new list<BigMachines__Quote_Product__c>();
        Boolean bln_IsOneTimeChargeQuote = false;
        Decimal decNonRecurringCharge = 0;
        integer line_number = 1;
        integer line_numberAlaCart = 5;
        system.debug(Sql_stmt);
        //  List<BigMachines__Quote_Product__c> list_QP = Database.query(Sql_stmt);
        for (BigMachines__Quote_Product__c bm_qm : Database.query(Sql_stmt)) {
            /*
if (bm_qm.BigMachines__Product__r.Type__c == 'Product - Hardware') {
multiShipIds.add(bm_qm.BigMachines__Quote__c);
} else {
softwareOnlyOrderIds.add(bm_qm.BigMachines__Quote__c);
}
*/
            if (bm_qm.BigMachines__Product__r.Type__c == 'Genesys Care') {
                genesysCareProductId = bm_qm.BigMachines__Product__c;
                genesysCareProductName = bm_qm.BigMachines__Product__r.Name;
                genesysCareProductDescription = bm_qm.BigMachines__Product__r.Description;
            }
            if (bm_qm.BigMachines__Product__r.Type__c == 'Flex Care')
                genesysCareFlexCareProductIds.add(bm_qm.BigMachines__Product__c);
            
            if (bm_qm.BigMachines__Product__r.PS_Contract__c != null && bm_qm.BigMachines__Product__r.PS_Contract__c)
                genesysPS.add(bm_qm.BigMachines__Product__c);
            
            
            if (bm_qm.BigMachines__Product__r.Type__c == 'Fees') {
                genesysFeeProductIds.add(bm_qm.BigMachines__Product__c);
                // Sourav : 10/23/2014
                continue;
            }
            
            //PureSuccess Anju Jan 2018 starts
            if(bm_qm.Bundle__r.Group_Type__c == 'PureSuccess'){
                mapOfPackageVsPrice.put(bm_qm.Bundle__r.Type__c, bm_qm);
                if(bm_qm.Bundle_Line__c != NULL)
                    continue;
            } 
            System.debug('#####mapOfPackageVsPrice: '+ mapOfPackageVsPrice);
            //remove Alacarte items
            if(bm_qm.Product_Group__c == 'PureSuccess Direct A-la-Carte' || bm_qm.Product_Group__c == 'PureSuccess Indirect A-la-Carte'){
                mapPSAlacartItems.put(bm_qm.id,bm_qm);
                
            }
            if(bm_qm.Product_Group__c == 'PureSuccess Direct Offer' || bm_qm.Product_Group__c == 'PureSuccess Indirect Offer'){
                mapPSOfferItems.put(bm_qm.id,bm_qm);
            }
            //PureSuccess Anju Jan 2018 ends
             System.debug('#####bln_IsOneTimeChargeQuote:'+bln_IsOneTimeChargeQuote);
            //Rony Joseph- March 24 2019 -One Time Charge Child Order
            if((quote.offering_type__c == 'Business Edition')&&((bm_qm.Product_Group__c == null) || (bm_qm.Product_Group__c != null && !bm_qm.Product_Group__c.contains('PureSuccess'))) 
               &&
               ((bm_qm.Bundle__r.Group_Type__c == null)||(bm_qm.Bundle__r.Group_Type__c != null && !bm_qm.Bundle__r.Group_Type__c.contains('PureSuccess')))
               &&
               (!bm_qm.BigMachines__Product__r.Include_in_CMMR_Total__c)
              ){
                  bln_IsOneTimeChargeQuote = true;
                  // decNonRecurringCharge += (bm_qm.Net_Unit_Price__c*bm_qm.BigMachines__Quantity__c);
                  // list_OneTimeQP.add(bm_qm);
                  system.debug('entered loop Anto');
              }
            
            //Mukunth added below if for populating POB type on PS Expert App lines
            if(bm_qm.BigMachines__Product__r.PS_Contract__c && bm_qm.BigMachines__Product__r.POB_Type__c == 'PS - Fixed Fee on Date')
                psExpertApps.add(bm_qm.BigMachines__Product__c);
            
            Order_Line_Item__c objOrderLineItemclone;
            Order_Line_Item__c obj = new Order_Line_Item__c();//DynamicFieldMapping.getOrderLineItemFromQuoteLineItem(bm_qm, 'License_Orders');
            // 7/1/2016 : Setting default recordtype
            obj.Line_Number__c = line_number;
            line_number += 1;
            System.debug('+++++++++line_number ' + line_number);
            obj.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
            if(quote.offering_type__c == 'Business Edition')
                obj.RecordTypeId = recordTypeIdForOLI;            
            obj.Unit_of_Measure__c = bm_qm.Unit_of_Measure__c;
            obj.Order__c = order.id;
            //Anju PureSuccess Jan 2018 starts
            if(mapPSAlacartItems.containskey(bm_qm.id))
                obj.Order__c = pureSuccessChildOrder.id;
            //Anju PureSuccess Jan 2018 ends
            obj.Flavor__c = bm_qm.Flavor__c;
            ///*
            obj.Quantity__c = bm_qm.Quantity__c;
            obj.Quote_Product__c = bm_qm.id;
            System.debug('NKC debug obj.Quote_Product__c [' + obj.Quote_Product__c + ']');
            obj.Product_txt__c = bm_qm.Product__c;
            obj.Net_Unit_Price__c = bm_qm.Net_Unit_Price__c;
            
            if (quote.Quote_Business_Type__c != 'Cloud')
                obj.Name = bm_qm.APN_Number__c; else
                    obj.Name = bm_qm.BigMachines__Product__r.Name;
            
            obj.Product__c = bm_qm.BigMachines__Product__c;
            obj.List_Price__c = bm_qm.List_Price__c;
            //obj.Line_Number__c = bm_qm.Line_Number__c;
            obj.Ext_Net_Price__c = bm_qm.Ext_Net_Price__c;
            obj.Ext_List__c = bm_qm.Ext_List__c;
            obj.CurrencyIsoCode = bm_qm.CurrencyIsoCode;
            //obj.APN_Number__c = bm_qm.APN_Number__c;
            // 1/2/2015 : Pulling APN Number from the product : Name of sellable items is APN Number
            obj.APN_Number__c = String.isBlank(bm_qm.APN_Number__c) ? bm_qm.BigMachines__Product__r.Name : bm_qm.APN_Number__c;
            if(quote.offering_type__c == 'Business Edition')
                obj.APN_Number__c = String.isBlank(bm_qm.APN_Number__c) ? bm_qm.BigMachines__Product__r.APN_Number__c : bm_qm.APN_Number__c;
            
            obj.description__c =  bm_qm.BigMachines__Product__r.Description != NULL ? (bm_qm.BigMachines__Product__r.Description.length() > 255 ? bm_qm.BigMachines__Product__r.Description.substring(0,254) : bm_qm.BigMachines__Product__r.Description ) : '';
            obj.sales_price__c = bm_qm.BigMachines__Sales_Price__c;
            obj.BigMachines_Quantity__c = bm_qm.BigMachines__Quantity__c;
            obj.Total_Discount__c = bm_qm.Total_Discount__c;
            obj.Product_Specific_Discount__c = bm_qm.Product_Specific_Discount__c;
            if(quote.offering_type__c == 'Business Edition' && (bm_qm.BigMachines__Sales_Price__c == null || bm_qm.BigMachines__Sales_Price__c == 0))
                obj.sales_price__c = bm_qm.List_Price__c;
            if(quote.offering_type__c == 'Business Edition' && bm_qm.Quantity__c == null)
                obj.Quantity__c = bm_qm.BigMachines__Quantity__c;
            if(quote.offering_type__c == 'Business Edition' && bm_qm.Ext_Net_Price__c == null)
                obj.Ext_Net_Price__c = bm_qm.Net_Unit_Price__c;
            obj.BigMachines_Quantity__c = bm_qm.BigMachines__Quantity__c;
            obj.Total_Discount__c = bm_qm.Total_Discount__c;
            obj.Product_Specific_Discount__c = bm_qm.Product_Specific_Discount__c;
            //0 price for base package header line
            if((bm_qm.Bundle__r.Group_Type__c == 'Base Package' && bm_qm.Bundle_Line__c == null) || order.NRO_Type__c == 'Pay Per Use'){
                obj.List_Price__c = 0;
                //obj.Line_Number__c = bm_qm.Line_Number__c;
                obj.Ext_Net_Price__c = 0;
                obj.Ext_List__c = 0;
                obj.Sales_Price__c = 0;
                obj.Net_Unit_Price__c = 0;
            }
            //*/
            //If it's a license opp then copy both the dates from Quote itself. OR if the product is genesys care
            if ((recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && quote.Quote_Business_Type__c != 'Renewal')
                || obj.Product__c == genesysCareProductId) {
                    obj.Maintenance_End_Date__c = quote.Maintenance_End_Date__c;
                    obj.Maintenance_Start_Date__c = quote.Maintenance_Start_Date__c;
                }
            System.debug('NKC debug obj.Maintenance_Start_Date__c [' + obj.Maintenance_Start_Date__c + ']');
            System.debug('NKC debug obj.Maintenance_End_Date__c [' + obj.Maintenance_End_Date__c + ']');
            
            if (recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && quote.Quote_Business_Type__c != 'Renewal') {
                obj.Maintenance_No_of_Months__c = quote.Order_Numb_of_Maint_Months__c;
            }
            //If it's not a license opp then copy both the dates from Quote products.
            else {
                obj.Maintenance_End_Date__c = bm_qm.Maintenance_End_Date__c;
                obj.Maintenance_Start_Date__c = bm_qm.Maintenance_Start_Date__c;
                // 1/21/2015 : Copy additional information for PS product
                if (String.isNotBlank(bm_qm.BigMachines__Product__r.Type__c)) {
                    for (String strType : list_Types) {
                        if (bm_qm.BigMachines__Product__r.Type__c == strType) {
                            obj.Project_ID__c = bm_qm.Project_ID__c;
                            obj.Project_Name__c = bm_qm.Project_Name__c;
                            obj.Third_Party_Partners__c = bm_qm.Third_Party_Partners__c;
                            obj.Third_Party_Applications__c = bm_qm.Third_Party_Applications__c;
                            obj.Third_Party_Partner_Fee__c = bm_qm.Third_Party_Partner_Fee__c;
                            obj.Solution_Names_Covered__c = bm_qm.Solution_Names_Covered__c;
                            obj.Application_Support_Cost_Base__c = bm_qm.Application_Support_Cost_Base__c;
                        }
                    }
                }
            }
            
            // Calculates the Maintenace due and Anuualized at Order level for Licensing Deal
            
            if (quote.PO_for_FYM__c != null && quote.PO_for_FYM__c != 'Declined Maintenance') {
                
                //if(recType != null && recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
                if (recType != null && recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME &&
                    quote.Quote_Business_Type__c != 'Renewal' && quote.Quote_Business_Type__c != 'Cloud') {
                        if (quote.Current_Maint_Rate__c != null) {
                            obj.Maintenance_Due__c = bm_qm.BigMachines__Total_Price__c * (quote.Current_Maint_Rate__c / 100);
                        }
                        if (obj.Maintenance_Due__c != null && obj.Maintenance_Due__c != 0 && quote.Order_Numb_of_Maint_Months__c != 0 && quote.Order_Numb_of_Maint_Months__c != null) {
                            obj.Annualized_Maintenance_Due__c = (obj.Maintenance_Due__c / quote.Order_Numb_of_Maint_Months__c) * 12;
                        }
                    }
            } else {
                obj.Annualized_Maintenance_Due__c = 0;
                obj.Maintenance_Due__c = 0;
            }
            
            //if(recType != null && (recType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || recType == ServiceContractUtil.MAINTENANCE))
            if (recType != null && (quote.Quote_Business_Type__c == 'Renewal' || recType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME
                                    || recType == ServiceContractUtil.MAINTENANCE)) {
                                        obj.Maintenance_Due__c = bm_qm.Maintenance_Due__c;
                                        // Storing Annualized Maintenance from last period applicable on the quote
                                        if (bm_qm.Annualized_Maintenance_Last_Period__c != null)
                                            obj.Annualized_Maintenance_Due__c = bm_qm.Annualized_Maintenance_Last_Period__c; else {
                                                if (bm_qm.Maintenance_Due__c != null && bm_qm.Maintenance_Due__c != 0 &&
                                                    bm_qm.Maintenance_Start_Date__c != null && bm_qm.Maintenance_End_Date__c != null) {
                                                        
                                                        tempStart = OrderUtil.adjustDatetoStartofMonth(bm_qm.Maintenance_Start_Date__c);
                                                        tempEnd = OrderUtil.adjustDatetoStartofMonth(bm_qm.Maintenance_End_Date__c);
                                                        tempTerm = (12 * (tempEnd.year() - tempStart.year())) + (tempEnd.month() - tempStart.month());
                                                        obj.Maintenance_No_of_Months__c = tempTerm;
                                                        if (tempTerm != 0)
                                                            obj.Annualized_Maintenance_Due__c = (bm_qm.Maintenance_Due__c / tempTerm) * 12;
                                                        
                                                    }
                                            }
                                        obj.Sold_To_Name__c = bm_qm.Sold_To_Name__c;
                                        obj.End_User_Name__c = bm_qm.End_User_Name__c;
                                    }
            
            
            //*
            obj.Fees_Applied__c = bm_qm.Fees_Applied__c ;
            //obj.Gnesys_Care_Rate__c = bm_qm.Genesys_Care_Rate__c;
            obj.Increase__c = bm_qm.Increase__c;
            obj.Revised_Net_License_Value__c = bm_qm.Revised_Net_License_Value__c;
            
            //Mukunth added below 5 fields to the query to populate these fields from quote to order
            obj.Original_License_List_Price__c = bm_qm.Original_License_List_Price__c;
            obj.Partner_License_List_Price__c = bm_qm.Partner_License_List_Price__c;
            obj.Revised_License_List_Price__c = bm_qm.Revised_License_List_Price__c;    
            obj.Unit_List_Price__c = bm_qm.Unit_List_Price__c;
            obj.Unit_Partner_Price__c = bm_qm.Unit_Partner_Price__c;
            
            //Ramar added to populate value from quote to order
            obj.CX_Platform__c = bm_qm.CX_Platform__c;
            
            obj.Extended_End_of_Support__c = bm_qm.Extended_End_of_Support__c;
            
            
            obj.Contract_Line_Update_Status__c = bm_qm.Contract_Line_Update_Status__c;
            obj.Current_Qty__c = bm_qm.Current_Qty__c;
            obj.Original_Qty__c = bm_qm.Original_Qty__c;
            obj.Service_Contract_Line_ID__c = bm_qm.Service_Contract_Line_ID__c;
            //Naresh kumar 05/12/2014
            //New Mapping Fields for Renewal Only
            if (quote.Quote_Business_Type__c == 'Renewal' || opp[0].RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME) {
                // For Flex Care and Fees products Sales Price should not be overwritten as Sales Price flows to Maintenance Due on Service Contract
                if (bm_qm.BigMachines__Product__r.Type__c != 'Flex Care' &&
                    bm_qm.BigMachines__Product__r.Type__c != 'Fees') {
                        obj.Year1_Maintenance_Due__c = bm_qm.Maintenance_Due__c;
                        obj.Year2_Maintenance_Due__c = bm_qm.Year2_Maintenance_Due__c;
                        obj.Year3_Maintenance_Due__c = bm_qm.Year3_Maintenance_Due__c;
                        obj.Year4_Maintenance_Due__c = bm_qm.Year4_Maintenance_Due__c;
                        obj.Year5_Maintenance_Due__c = bm_qm.Year5_Maintenance_Due__c;
                        
                        if (bm_qm.Maintenance_Due__c == null)
                            bm_qm.Maintenance_Due__c = 0;
                        if (bm_qm.Year2_Maintenance_Due__c == null)
                            bm_qm.Year2_Maintenance_Due__c = 0;
                        if (bm_qm.Year3_Maintenance_Due__c == null)
                            bm_qm.Year3_Maintenance_Due__c = 0;
                        if (bm_qm.Year4_Maintenance_Due__c == null)
                            bm_qm.Year4_Maintenance_Due__c = 0;
                        if (bm_qm.Year5_Maintenance_Due__c == null)
                            bm_qm.Year5_Maintenance_Due__c = 0;
                        
                        obj.Maintenance_Due__c = bm_qm.Maintenance_Due__c + bm_qm.Year2_Maintenance_Due__c +
                            bm_qm.Year3_Maintenance_Due__c + bm_qm.Year4_Maintenance_Due__c + bm_qm.Year5_Maintenance_Due__c;
                        
                        obj.Genesys_Care_Rate__c = bm_qm.Genesys_Care_Rate__c;
                        obj.Year2_CareRatePercent__c = bm_qm.Year2_CareRatePercent__c;
                        obj.Year3_CareRatePercent__c = bm_qm.Year3_CareRatePercent__c;
                        obj.Year4_CareRatePercent__c = bm_qm.Year4_CareRatePercent__c;
                        obj.Year5_CareRatePercent__c = bm_qm.Year5_CareRatePercent__c;
                        obj.Sales_Price__c = obj.Maintenance_Due__c;
                    }
                // Flex Care and Fees Lines
                else {
                    // Maintenance Due is fetched from Sales Price for Fees and Flex Care Lines
                    obj.Maintenance_Due__c = bm_qm.BigMachines__Sales_Price__c;
                    if (obj.Maintenance_Due__c != null &&
                        bm_qm.Maintenance_Start_Date__c != null && bm_qm.Maintenance_End_Date__c != null) {
                            obj.Maintenance_No_of_Months__c = Util.calculateDurationInMonths(bm_qm.Maintenance_Start_Date__c, bm_qm.Maintenance_End_Date__c);
                            if (obj.Maintenance_No_of_Months__c != 0)
                                obj.Annualized_Maintenance_Due__c = obj.Maintenance_Due__c * (12 / obj.Maintenance_No_of_Months__c);
                        }
                }
                
            }
            
            //Anju PureSuccess Jan 2018 starts
            //Anju Nov 2018 set dummy apn number for puresuccess and set base amount
            if(quote.offering_type__c == 'Business Edition' && (bm_qm.Product_Group__c == 'PureSuccess Direct A-la-Carte' || bm_qm.Product_Group__c == 'PureSuccess Indirect A-la-Carte' || bm_qm.Product_Group__c == 'PureSuccess Direct Offer' || bm_qm.Product_Group__c == 'PureSuccess Indirect Offer'))
            {
                if(bm_qm.Product_Group__c == 'PureSuccess Direct Offer' || bm_qm.Product_Group__c == 'PureSuccess Indirect Offer')
                    obj.Dummy_APN__c = obj.APN_Number__c;     
                obj.Base_Package__c = obj.Ext_Net_Price__c; 
                if(obj.Ext_List__c == null)
                    obj.Ext_List__c = obj.List_price__c * bm_qm.BigMachines__Quantity__c;
            }
            if(mapPSAlacartItems.containskey(bm_qm.id)){
                obj.Order__c = pureSuccessChildOrder.id;
                obj.Year__c = 1;
                obj.Maintenance_Start_Date__c = pureSuccessChildOrder.Maintenance_Start__c;
                obj.Maintenance_End_Date__c = pureSuccessChildOrder.Maintenance_End__c;
                obj.Line_Number__c = line_numberAlaCart;
                line_numberAlaCart ++;
                obj.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
                objOrderLineItemclone = obj.clone();
                objOrderLineItemclone.Order__c = order.id;
                objOrderLineItemclone.RecordTypeId = recordTypeIdForOLI;
                objOrderLineItemclone.Line_Number__c = line_number;
                obj.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
            }
            
            //Anju PureSuccess Jan 2018 ends
            
            //*/
            if (bm_qm.BigMachines__Product__r.Type__c == 'Genesys Care') {
                genesysCareLine = obj;
            }
            flag = true;
            
            if (bm_qm.Contract_Line_Update_Status__c == 'Split' && ((bm_qm.Original_Qty__c == bm_qm.Current_Qty__c) || bm_qm.Current_Qty__c == 0))
                flag = false;
            
            if ((bm_qm.Contract_Line_Update_Status__c == 'Drop' || bm_qm.Contract_Line_Update_Status__c == 'Downsize' || bm_qm.Contract_Line_Update_Status__c == 'Shelved')
                && ((bm_qm.Original_Qty__c == bm_qm.Current_Qty__c) || bm_qm.Current_Qty__c == 0))
                flag = false;
            
            if (bm_qm.Contract_Line_Update_Status__c == 'Retired' && ((bm_qm.Original_Qty__c == bm_qm.Current_Qty__c) || bm_qm.Current_Qty__c == 0))
                flag = false;
            
            //add puresucess offer line twice Anju Jan 2018
            /*if(mapPSOfferItems.containskey(bm_qm.id)){
Order_Line_Item__c obj1 = obj.clone();
obj1.Order__c = order.id;
oli_lst.add(obj1);
}*/
            
            if (flag)
                oli_lst.add(obj);
            if(objOrderLineItemclone != null)
                oli_lst.add(objOrderLineItemclone);
        }
        
        /** Yuvaraj - 25 Apr 2019 . POB type PS-CAS & PS- CAS renewal for RevPro*/
        for(Order_line_item__c eachOLI:oli_lst){
            if(eachOLI.Product__c != genesysCareProductId){
                System.debug('Entering POB : Description:'+eachOLI.description__c);
                //Mukunth added logic for populating POB type on PS Expert App lines
                if(eachOLI.description__c != NULL && (eachOLI.description__c.contains('Custom Application Support') || eachOLI.description__c.contains('Custom App Support'))){
                    System.debug('Setting POB');
                    if(eachOLI.Service_Contract_Line_ID__c !='' && eachOLI.Service_Contract_Line_ID__c!=NULL ) {
                        eachOLI.POB_Type__c = 'PS - CAS - Renewal';
                    }
                    else {
                        eachOLI.POB_Type__c = 'PS - CAS';
                    }

                }
                else if(psExpertApps.size()>0 && psExpertApps.contains(eachOLI.Product__c)){
                    System.debug('Setting EA POB');
                    eachOLI.POB_Type__c = 'PS - Fixed Fee on Date';
                }
                else if(eachOLI.POB_Type__c=='' || eachOLI.POB_Type__c == null){
                    eachOLI.POB_Type__c = 'Not Applicable';
                }
            }
            
            else if(genesysCareFlexCareProductIds.contains(eachOLI.Product__c)){
                
               eachOLI.POB_Type__c = 'Maintenance Renewal'; 
            }
        }
        /*end*/
        //It shouldn't happen in case of license opp
        //if(recType != ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && genesysCareProductId != null){
        if ((quote.Quote_Business_Type__c == 'Renewal' || opp[0].RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
            && genesysCareProductId != null) {
                //order.License_FYM_detail__c = 'Renewal'; 
                //update order;
                oli_lst = CreateOrderFromQuoteTriggerHelper.populateBusinessLinesOnQuoteOtherThanRenewal(oli_lst, genesysCareProductId,
                                                                                                         genesysCareProductName, genesysCareProductDescription, quote, order, genesysCareFlexCareProductIds, genesysFeeProductIds, genesysPS);
            }
        insert oli_lst;
         System.debug('#####bln_IsOneTimeChargeQuote:'+bln_IsOneTimeChargeQuote);
        //Rony Joseph- March 24 2019 -One Time Charge Child Order
        /*if(bln_IsOneTimeChargeQuote && quote.offering_type__c == 'Business Edition'){
            system.debug('entered loop Anto 2');
            Map<Id, Order_Line_Item__c> map_OLIs = new Map<Id, Order_Line_Item__c>();
            List<Order_Line_Item__c> list_OneTimeOrderLineItem = new List<Order_Line_Item__c>();
            for(Order_Line_Item__c objOLI : oli_lst) {
                map_OLIs.put(objOLI.Quote_Product__c, objOLI);
            }
            
            for(BigMachines__Quote_Product__c objQP :list_OneTimeQP){
                
                list_OneTimeOrderLineItem.add(map_OLIs.get(objQP.Id));
            }
            
          //  OrderCloudUtil.createOneTimeChargeOLIforPEC(quote.id,obj_NewOneTimeOrder,list_OneTimeOrderLineItem);
        }*/
        // OrderCloudUtil.createOneTimeChargeOLIforPEC(quote.id,obj_NewOneTimeOrder,list_OneTimeOrderLineItem);
        //Anju 2018 January PureSuccess order lines
        System.debug('#####mapOfPackageVsPrice: '+ mapOfPackageVsPrice); 
        if(!mapOfPackageVsPrice.keySet().isEmpty())
            OrderCloudUtil.createPureSuccessLinesCloud(mapOfPackageVsPrice, Quote, pureSuccessChildOrder, oli_lst);  
    }
    //IN CASE ORDER IS RESUBMITTED WITHOUT FYM
    if (exec)
        checkOrder = [select id from Order__c where Quote__c = :quote.id and License_FYM_detail__c = 'Maintenance Only Order'];
    if (!sep_po && exec && checkOrder.size() > 0) {
        delete checkOrder;
    }
    if (sep_po && exec) {
        id orderid;
        //and Is_licensed_Quote__c=false
        
        if (checkOrder.size() > 0) {
            updateFlag = true;
        }
        
        //INSERT ORDER FIRST TIME OR IF RESUBMITTED WITH FYM
        if ((!updateFlag || checkOrder.isEmpty()) && exec) {
            order = Create_Order.Insert_Orders(quote, 'Pending FYM PO', 'Maintenance Only Order', region, owner_email, recType, opp[0]);
            order.License_Order__c = license_orderid;
            insert order;
            //Naresh Kumar 01/09/2017 We don't need to populate order id at this time since it's maint only order
            //Naresh Kumar  02/08/2016  Populating quote's order field.
            //BigMachines__Quote__c quoteToBeUpdated = new BigMachines__Quote__c(id = quote.id);
            //quoteToBeUpdated.Order__c = order.id;
            //update quoteToBeUpdated;
            //if(opp.size() > 0 && opp[0].RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
            if (opp.size() > 0 && opp[0].RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME &&
                quote.Quote_Business_Type__c != 'Renewal') {
                    Order__Share OrderShare = new Order__Share();
                    OrderShare.ParentId = order.Id;
                    OrderShare.UserOrGroupId = opp_ownerid;
                    OrderShare.AccessLevel = 'edit';
                    OrderShare.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
                    insert OrderShare;
                }
            
            orderid = order.id;
            
            
        }
        
        //update Order
        if (updateFlag && exec && !checkOrder.isEmpty()) {
            if (quote.rejected_flag__c)
                order = Create_Order.Update_Orders(quote, checkOrder[0].id, 'Pending FYM PO', 'Maintenance Only Order', region, owner_email, recType, opp[0]); else
                    order = Create_Order.Update_Orders(quote, checkOrder[0].id, 'Pending FYM PO', 'Maintenance Only Order', region, owner_email, recType, opp[0]);
            order.License_Order__c = license_orderid;
            update order;
            
            orderid = order.id;
            //Delete Order line items
            list<Order_Line_Item__c> oli_del = [select id from Order_Line_Item__c where order__c = :order.id];
            delete oli_del;
        }
        
        string Sql_stmt = 'Select Unit_of_Measure__c,';
        Sql_stmt += '   Quantity__c,';
        Sql_stmt += '   Product__c,';
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
        Sql_stmt += '   BigMachines__Product__r.Type__c, BigMachines__Product__c,BigMachines__Product__r.Name,';//lookup
        Sql_stmt += '   Maintenance_Start_Date__c,';
        Sql_stmt += '   Maintenance_End_Date__c,';
        Sql_stmt += '   Maintenance_Due__c,';
        Sql_stmt += '   Fees_Applied__c,';
        Sql_stmt += '   Genesys_Care_Rate__c,';
        Sql_stmt += '   Increase__c,';
        Sql_stmt += '   Revised_Net_License_Value__c,';
        Sql_stmt += '   Extended_End_of_Support__c,';
        Sql_stmt += '   Sold_To_Name__c,';
        Sql_stmt += '   End_User_Name__c,';
        
        Sql_stmt += '   Contract_Line_Update_Status__c,';
        Sql_stmt += '   Original_Qty__c,';
        Sql_stmt += '   Current_Qty__c,';
        //Sql_stmt += '   IsShippable__c,';
        Sql_stmt += '   Bundle__r.Name,';
        Sql_stmt += '   Bundle_Line__c,';
        Sql_stmt += '   Bundle__r.Group_Type__c,';
        
        //Ramar added to populate value from quote to order
        Sql_stmt += '   CX_Platform__c,';
        
        Sql_stmt += '   Total_Discount__c,';
        Sql_stmt += '   Product_Specific_Discount__c,';
        Sql_stmt += '   BigMachines__Total_Price__c,';
        Sql_stmt += '   Service_Contract_Line_ID__c, Flavor__c,';
        // 1/21/2015 : To Copy additional information for PS product (if present)
        Sql_stmt += '   Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,';
        // 2/5/2015 : few more fields
        Sql_stmt += '   Application_Support_Cost_Base__c,Solution_Names_Covered__c,Third_Party_Partner_Fee__c';
        Sql_stmt += '   From BigMachines__Quote_Product__c where  ';
        Sql_stmt += '   BigMachines__Quote__c= \'' + trigger.new[0].id + '\'  AND BigMachines__Product__r.Type__c != \'Bundle\' ';
        
        //Commented by Ankit on 4/25/2013
        // Sql_stmt += ' and BigMachines__Product__r.Type__c != \'Product\'';
        
        if (quote.Is_GU_EMEA__c) {
            Sql_stmt += ' and BigMachines__Product__r.Type__c <> \'Genesys Care\'';
        }
        
        list<Order_Line_Item__c> oli_lst = new list<Order_Line_Item__c>();
        List<String> list_Types = Label.Types_Required_Add_Products.split(';');
        List<BigMachines__Quote_Product__c> list_OneTimeQP = new list<BigMachines__Quote_Product__c>();
        Boolean bln_IsOneTimeChargeQuote = false;
        Decimal decNonRecurringCharge = 0;
        for (BigMachines__Quote_Product__c bm_qm : Database.query(Sql_stmt)) {
            Order_Line_Item__c obj = new Order_Line_Item__c();//DynamicFieldMapping.getOrderLineItemFromQuoteLineItem(bm_qm, 'License_Orders');
            // 7/1/2016 : Setting default recordtype
            obj.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
            if(quote.offering_type__c == 'Business Edition')
                obj.RecordTypeId = recordTypeIdForOLI;
            obj.Flavor__c = bm_qm.Flavor__c;
            obj.Unit_of_Measure__c = bm_qm.Unit_of_Measure__c;
            obj.Quantity__c = bm_qm.Quantity__c;
            obj.Product_txt__c = bm_qm.Product__c;
            obj.Product__c = bm_qm.BigMachines__Product__c;
            obj.Net_Unit_Price__c = bm_qm.Net_Unit_Price__c;
            obj.Name = bm_qm.APN_Number__c;
            obj.List_Price__c = bm_qm.List_Price__c;
            obj.Line_Number__c = bm_qm.Line_Number__c;
            obj.Ext_Net_Price__c = bm_qm.Ext_Net_Price__c;
            obj.Ext_List__c = bm_qm.Ext_List__c;
            obj.CurrencyIsoCode = bm_qm.CurrencyIsoCode;
            //obj.APN_Number__c = bm_qm.APN_Number__c;
            // 1/2/2015 : Pulling APN Number from the product : Name of sellable items is APN Number
            obj.APN_Number__c = bm_qm.BigMachines__Product__r.Name;
            if(quote.offering_type__c == 'Business Edition')
                obj.APN_Number__c = String.isBlank(bm_qm.APN_Number__c) ? bm_qm.BigMachines__Product__r.APN_Number__c : bm_qm.APN_Number__c;
            
            obj.Order__c = orderid;
            obj.description__c = bm_qm.BigMachines__Description__c;
            obj.sales_price__c = bm_qm.BigMachines__Sales_Price__c;
            obj.BigMachines_Quantity__c = bm_qm.BigMachines__Quantity__c;
            obj.Total_Discount__c = bm_qm.Total_Discount__c;
            obj.Product_Specific_Discount__c = bm_qm.Product_Specific_Discount__c;
            
            obj.Maintenance_End_Date__c = bm_qm.Maintenance_End_Date__c ;
            obj.Maintenance_Start_Date__c = bm_qm.Maintenance_Start_Date__c ;
            
            // 1/21/2015 : Copy additional information for PS product
            if ((recType != ServiceContractUtil.OPP_GEN_NEW_DEV_NAME || quote.Quote_Business_Type__c == 'Renewal') &&
                String.isNotBlank(bm_qm.BigMachines__Product__r.Type__c)) {
                    for (String strType : list_Types) {
                        if (bm_qm.BigMachines__Product__r.Type__c == strType) {
                            obj.Project_ID__c = bm_qm.Project_ID__c;
                            obj.Project_Name__c = bm_qm.Project_Name__c;
                            obj.Third_Party_Partners__c = bm_qm.Third_Party_Partners__c;
                            obj.Third_Party_Applications__c = bm_qm.Third_Party_Applications__c;
                            obj.Third_Party_Partner_Fee__c = bm_qm.Third_Party_Partner_Fee__c;
                            obj.Solution_Names_Covered__c = bm_qm.Solution_Names_Covered__c;
                            obj.Application_Support_Cost_Base__c = bm_qm.Application_Support_Cost_Base__c;
                        }
                    }
                }
            
            // Calculates the Maintenace due and Anuualized at Order level for Licensing Deal
            if (quote.PO_for_FYM__c != null && quote.PO_for_FYM__c != 'Declined Maintenance') {
                //if(recType != null && recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
                if (recType != null && recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME &&
                    quote.Quote_Business_Type__c != 'Renewal') {
                        if (quote.Current_Maint_Rate__c != null) {
                            obj.Maintenance_Due__c = bm_qm.BigMachines__Total_Price__c * (quote.Current_Maint_Rate__c / 100);
                        }
                        if (obj.Maintenance_Due__c != null && obj.Maintenance_Due__c != 0 && quote.Order_Numb_of_Maint_Months__c != 0) {
                            obj.Annualized_Maintenance_Due__c = (obj.Maintenance_Due__c / quote.Order_Numb_of_Maint_Months__c) * 12;
                            
                        }
                        //obj.Sold_To_Name__c = order.Sold_To_Name__r.name;
                        //obj.End_User_Name__c = order.End_User_Name__r.name;
                        
                    }
            }
            
            obj.Fees_Applied__c = bm_qm.Fees_Applied__c ;
            obj.Genesys_Care_Rate__c = bm_qm.Genesys_Care_Rate__c;
            obj.Increase__c = bm_qm.Increase__c;
            obj.Revised_Net_License_Value__c = bm_qm.Revised_Net_License_Value__c;
            obj.Extended_End_of_Support__c = bm_qm.Extended_End_of_Support__c;
            
            
            obj.Contract_Line_Update_Status__c = bm_qm.Contract_Line_Update_Status__c;
            obj.Current_Qty__c = bm_qm.Current_Qty__c;
            obj.Original_Qty__c = bm_qm.Original_Qty__c;
            obj.Service_Contract_Line_ID__c = bm_qm.Service_Contract_Line_ID__c;
            
            //Ramar added to populate value from quote to order
            obj.CX_Platform__c = bm_qm.CX_Platform__c;
            
            oli_lst.add(obj);
        }
        insert oli_lst;
    }
    
    //Order Addresses
    
    if (exec) {
        
        list<Account_Order_Address__c> aoa_lst = new list<Account_Order_Address__c>();
        aoa_lst = [Select id from Account_Order_Address__c where Order__c = :license_orderid];
        if (aoa_lst.size() > 0 && quote.offering_type__c != 'Business Edition')
            delete aoa_lst;
        
        //Populates orders on order from quote orders
        //Naresh Kumar  06/22/1015 - Removed New Pricing condition from below condition.
        if (quote.Quote_Business_Type__c == 'On Premise')
            OrderAddressOnPremiseController.populateAddressOnOrder(quote.id, license_orderid);
        
        else if (quote.Quote_Business_Type__c != 'Cloud') {
            BigMachines__Quote__c bmq = [
                SELECT Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Phone__c, Ship_To_Last_Name__c,
                Ship_To_First_Name__c, Ship_To_Fax__c, Ship_To_E_Mail__c, Ship_To_Country__c,
                Ship_To_Company_Name__c, Ship_To_Company_Name_2__c, Ship_To_City__c,
                Ship_To_Address__c, Ship_To_Address_2__c, Bill_To_Zip_Code__c, Bill_To_State__c,
                Bill_To_Phone__c, Bill_To_Last_Name__c, Bill_To_First_Name__c, Bill_To_Fax__c,
                Bill_To_E_Mail__c, Bill_To_Country__c, Bill_To_Company_Name__c, Bill_To_Company_Name_2__c,
                Bill_To_City__c, Bill_To_Address__c, Bill_To_Address_2__c, End_User_Zip_Code__c,
                End_User_State__c, End_User_Phone__c, End_User_Last_Name__c, End_User_First_Name__c,
                End_User_Fax__c, End_User_E_Mail__c, End_User_Country__c, End_User_Company_Name__c,
                End_User_Company_Name_2__c, End_User_City__c, End_User_Address__c, End_User_Address_2__c,
                Support_Owner_Zip_Code__c, Support_Owner_State__c, Support_Owner_Phone__c, Support_Owner_Last_Name__c,
                Support_Owner_First_Name__c, Support_Owner_Fax__c, Support_Owner_EMail__c,
                Support_Owner_Country__c, Support_Owner_Company_Name__c, Support_Owner_Company_Name2__c,
                Support_Owner_City__c, Support_Owner_Address__c, Support_Owner_Address2__c, SI_Zip_Code__c,
                SI_State__c, SI_Phone__c, SI_Last_Name__c, SI_First_Name__c, SI_Fax__c, SI_EMail__c, SI_Country__c,
                SI_Company_Name__c, SI_Company_Name2__c, SI_City__c, SI_Address__c, SI_Address2__c,
                Sold_To_First_Name__c, Sold_To_Last_Name__c, Sold_To_Company_Name__c, Sold_To_Company_Name2__c,
                Sold_To_Address__c, Sold_To_Address2__c, Sold_To_City__c, Sold_To_State__c, Sold_To_Zip_Code__c,
                Sold_To_Country__c, Sold_To_Phone__c, Sold_To_Fax__c, Sold_To_Email__c, BigMachines__Opportunity__c,
                BigMachines__Opportunity__r.accountid, BigMachines__Opportunity__r.Direct_Sales__c,
                BigMachines__Opportunity__r.BusinessPartner__c
                FROM BigMachines__Quote__c
                WHERE id = :Trigger.new[0].id
            ];
            
            id accountid;
            if (bmq.BigMachines__Opportunity__r.Direct_Sales__c)
                accountid = bmq.BigMachines__Opportunity__r.accountid; else
                    accountid = bmq.BigMachines__Opportunity__r.BusinessPartner__c;
            
            
            //sold to address need to insert.
            System.debug('NKC debug license_orderid [' + license_orderid + ']');
            Account_Order_Address__c aoa = new Account_Order_Address__c();
            //  aoa.Account__c =  accountid;
            aoa.Order__c = license_orderid;
            aoa.Address_Type__c = 'Ship To';
            aoa.Zip_Code__c = bmq.Ship_To_Zip_Code__c;
            aoa.State__c = bmq.Ship_To_State__c;
            aoa.Phone__c = bmq.Ship_To_Phone__c;
            aoa.Last_Name__c = bmq.Ship_To_Last_Name__c;
            aoa.First_Name__c = bmq.Ship_To_First_Name__c;
            aoa.Fax__c = bmq.Ship_To_Fax__c;
            aoa.Email__c = bmq.Ship_To_E_Mail__c;
            aoa.Country__c = bmq.Ship_To_Country__c;
            aoa.Company__c = bmq.Ship_To_Company_Name__c;
            aoa.Company_Name2__c = bmq.Ship_To_Company_Name_2__c;
            aoa.City__c = bmq.Ship_To_City__c;
            aoa.Address__c = bmq.Ship_To_Address__c;
            aoa.Address2__c = bmq.Ship_To_Address_2__c;
            insert aoa;
            
            aoa = new Account_Order_Address__c();
            //  aoa.Account__c =  accountid;
            aoa.Order__c = license_orderid;
            aoa.Address_Type__c = 'Bill To';
            aoa.Zip_Code__c = bmq.Bill_To_Zip_Code__c;
            aoa.State__c = bmq.Bill_To_State__c;
            aoa.Phone__c = bmq.Bill_To_Phone__c;
            aoa.Last_Name__c = bmq.Bill_To_Last_Name__c;
            aoa.First_Name__c = bmq.Bill_To_First_Name__c;
            aoa.Fax__c = bmq.Bill_To_Fax__c;
            aoa.Email__c = bmq.Bill_To_E_Mail__c;
            aoa.Country__c = bmq.Bill_To_Country__c;
            aoa.Company__c = bmq.Bill_To_Company_Name__c;
            aoa.Company_Name2__c = bmq.Bill_To_Company_Name_2__c;
            aoa.City__c = bmq.Bill_To_City__c;
            aoa.Address__c = bmq.Bill_To_Address__c;
            aoa.Address2__c = bmq.Bill_To_Address_2__c;
            insert aoa;
            
            aoa = new Account_Order_Address__c();
            // aoa.Account__c =  bmq.BigMachines__Opportunity__r.accountid;
            aoa.Order__c = license_orderid;
            aoa.Address_Type__c = 'End User';
            aoa.Zip_Code__c = bmq.End_User_Zip_Code__c;
            aoa.State__c = bmq.End_User_State__c;
            aoa.Phone__c = bmq.End_User_Phone__c;
            aoa.Last_Name__c = bmq.End_User_Last_Name__c;
            aoa.First_Name__c = bmq.End_User_First_Name__c;
            aoa.Fax__c = bmq.End_User_Fax__c;
            aoa.Email__c = bmq.End_User_E_Mail__c;
            aoa.Country__c = bmq.End_User_Country__c;
            aoa.Company__c = bmq.End_User_Company_Name__c;
            aoa.Company_Name2__c = bmq.End_User_Company_Name_2__c;
            aoa.City__c = bmq.End_User_City__c;
            aoa.Address__c = bmq.End_User_Address__c;
            aoa.Address2__c = bmq.End_User_Address_2__c;
            insert aoa;
            
            
            
            
            aoa = new Account_Order_Address__c();
            // aoa.Account__c =  bmq.BigMachines__Opportunity__r.accountid;
            aoa.Order__c = license_orderid;
            aoa.Address_Type__c = 'Sold To';
            aoa.Zip_Code__c = bmq.Sold_To_Zip_Code__c;
            aoa.State__c = bmq.Sold_To_State__c;
            aoa.Phone__c = bmq.Sold_To_Phone__c;
            aoa.Last_Name__c = bmq.Sold_To_Last_Name__c;
            aoa.First_Name__c = bmq.Sold_To_First_Name__c;
            aoa.Fax__c = bmq.Sold_To_Fax__c;
            aoa.Email__c = bmq.Sold_To_Email__c;
            aoa.Country__c = bmq.Sold_To_Country__c;
            aoa.Company__c = bmq.Sold_To_Company_Name__c;
            aoa.Company_Name2__c = bmq.Sold_To_Company_Name2__c;
            aoa.City__c = bmq.Sold_To_City__c;
            aoa.Address__c = bmq.Sold_To_Address__c;
            aoa.Address2__c = bmq.Sold_To_Address2__c;
            insert aoa;
        }
    }
    
    integer i = 0;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    i = 1;
    
}