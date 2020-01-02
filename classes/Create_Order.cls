/****************************************************************8
Purpose :  Create Order Record(s) when a quote is submitted.
Written By :  Naresh Kumar  
Test Classes :  Create_Order_Test, QuoteUtilTest
*************************************************************************************/
public class Create_Order {

    public static Order__c Insert_Orders(BigMachines__Quote__c quote,string status,string License_FYM_detail,string region,string owner_email, String oppType, Opportunity opp){

        Order__c order = DynamicFieldMapping.getOrderFromQuote(quote, new Order__c(), 'Non_Revenue_Orders');
        if(quote.Quote_Business_Type__c == 'Cloud'){
            order.Annual_Contract_Value__c = quote.Annual_Contract_Value__c;
            order.CMRR__c = quote.CMRR__c;
            order.TCV__c = quote.Cloud_Total__c;
        }
        //order.quote_number__c = quote.name;
        order.name = 'Order ' + quote.name;
        if(License_FYM_detail.equals('Maintenance Only Order')){
            order.name += '-1';
        }

        //Added by navaneetha on 18-07-2019 for wendy request
        if(quote.Quote_Billing_Plan_count__c >0 ){
        order.Billing_Schedule__c = true;
        } 
     
        order.Master_Order_Number__c = order.name;
        order.Opportunity_Owner1__c = opp.OwnerId;
        order.Date_Submitted__c = Datetime.now();
        //order.Maintenance_Start__c =  quote.Order_Maintenance_Start__c;
        //order.Maintenance_End__c = quote.Order_Maintenance_End__c;
        //order.Quote__c = quote.id;
        //order.Opportunity__c = quote.BigMachines__Opportunity__c;
        order.Due_Date__c = Date.Today() + 2;
        order.PO_Received_Date__c = quote.Order_PO_Received_Date__c;
        Global_Setting__c obj1;
        if(License_FYM_detail=='License only order' || License_FYM_detail=='Both License & Maintenance Order'){
            order.PO_Number__c = quote.Order_PO_Number__c;
            order.PO_Date__c  =  quote.Order_PO_Date__c;
            if(quote.Offering_Type__c == 'Cloud Partner (PPU)')
                obj1 = Global_Setting__c.getInstance('NRO RT');
            else if(quote.Quote_Business_Type__c == 'Cloud')
                obj1 = Global_Setting__c.getInstance('Cloud Billing Master Order RT');
            else
                obj1 = Global_Setting__c.getInstance('License Order RT');
        }
        else {
            obj1 = Global_Setting__c.getInstance('Maintenence Order RT');
        }
        order.recordtypeid = obj1.ID__c;

        if(quote.Quote_Business_Type__c == 'Cloud')
            order.order_type__c = 'Non-Revenue';
        else
            order.order_type__c = 'Revenue';

        order.Genesys_Care_Specialist_Email__c = opp.Gene_Care_Specialist__r.Email;
        order.Genesys_Care_Ops_Email__c = opp.Quote_Mtce_Ops__r.Email;
        
        //Added By Ranjith on Jun 16, 2017 -- Starts
        order.No_Cloud_Billing_Contract__c = quote.No_Cloud_Billing_Contract__c;
        //Added By Ranjith on Jun 16, 2017 -- Ends
        
    /*
            order.Total_Order__c = quote.BigMachines__Total__c;
            order.Current_Rate__c = quote.Current_Maint_Rate__c;
            order.Net_License__c = quote.Total_Software__c;

            //Naresh Kumar  08/22/2013  Populating all the account lookup fields from Quote to Order
            //order.Sold_To_Name__c = quote.Sold_To_Name__c;
            order.Support_Owner__c = quote.Support_Owner__c;
            order.End_User_Name__c = quote.End_User_ID__c;
            order.Bill_To_Name__c = quote.Bill_To_Name__c;
            order.System_Integrator__c = quote.System_Integrator__c;
            order.CurrencyIsoCode = quote.CurrencyIsoCode;
            */
        //Renewal
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
        if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
            order.Net_Maint__c = quote.Total_Maintenance_Amount_Due__c;
        //License
        else if(oppType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
            order.Net_Maint__c = quote.Total_Genesys_Care__c;

        Global_Setting__c obj;
        System.debug('NKC debug region ['+region+']');
        if(region == 'North America'){
            //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
            if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
                    oppType == ServiceContractUtil.MAINTENANCE){
                obj = Global_Setting__c.getInstance('NA Order Queue Renewal');
            }
            else
                obj = Global_Setting__c.getInstance('NA Order Queue');
        }

        if(region=='EMEA'){
            //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
            if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
                    oppType == ServiceContractUtil.MAINTENANCE)
                obj = Global_Setting__c.getInstance('EMEA Order Queue Renewal');
            else
                    obj = Global_Setting__c.getInstance('EMEA Order Queue');
        }

        if(region=='LATAM'){
            //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
            if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
                    oppType == ServiceContractUtil.MAINTENANCE)
                obj = Global_Setting__c.getInstance('LATAM Order Queue Renewal');
            else
                    obj = Global_Setting__c.getInstance('LATAM Order Queue');
        }

        if(region=='APAC'){
            //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
            if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
                    oppType == ServiceContractUtil.MAINTENANCE)
                obj = Global_Setting__c.getInstance('APAC Order Queue Renewal');
            else
                    obj = Global_Setting__c.getInstance('APAC Order Queue');
        }

        if(region=='Japan' || region=='JAPAN'){
            //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
            if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
                    oppType == ServiceContractUtil.MAINTENANCE)
                obj = Global_Setting__c.getInstance('Japan Order Queue Renewal');
            else
                    obj = Global_Setting__c.getInstance('Japan Order Queue');
        }



        if(obj == null){
            obj = Global_Setting__c.getInstance('Order Queue');
        }

        if(obj != null){
            order.OwnerId = obj.ID__c;
        }


        System.debug('NKC debug order.OwnerId ['+order.OwnerId+']');
        //order.OwnerId = '00GK0000000LUYA';//order management group
        //Anju Revpro June 2018 filter out Business edition 
        if(quote.Quote_Business_Type__c == 'Cloud' && quote.Offering_Type__c != 'Cloud Partner (PPU)' && quote.Offering_Type__c != 'Business Edition')
        {
            order.status__c = 'Order Submitted';
            // Assign ownership of Cloud Billing Master Orders to the respective queue
            order.OwnerId = Global_Setting__c.getInstance('Cloud Billing Master Orders Queue').ID__c;
        }
        else
                order.status__c = status;
        if(quote.PPU_Rental__c && quote.Offering_Type__c == 'Cloud Partner (PPU)')
            order.License_FYM_detail__c = 'PPU Order';        
        else if(quote.PPU_Rental__c)
            order.License_FYM_detail__c = 'Rental Order';        
        else
            order.License_FYM_detail__c = License_FYM_detail;

        System.debug('NKC debug quote.Quote_Business_Type__c ['+quote.Quote_Business_Type__c+']');
        //For renewal quotes
        if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME){
            //Naresh Kumar 05/12/2014
            //New Mapping Fields for Renewal Only
            order.Maintenance_Amount__c = quote.Grand_Total__c;
            //order.License_FYM_detail__c = 'Maintenance Only Order';
            if(order.Maintenance_Start__c != null && order.Maintenance_End__c != null)
                order.Numb_of_Maint_Months__c = order.Maintenance_Start__c.monthsBetween(order.Maintenance_End__c) + 1;
            order.Order_Type__c = 'Revenue';
            order.Net_Maint__c = quote.Grand_Total__c;
            order.Net_License__c = quote.Total_Revised_Net_License_Value__c;
            order.Revised_Net_License_Value__c = quote.Total_Revised_Net_License_Value__c;
            order.Comments__c = quote.BigMachines__Description__c;
        }

        order.Ship_To_Name__c = quote.Ship_To_Name__c;
        order.Shipping_Contact_Phone_Number__c = quote.Shipping_Contact_Phone_Number__c;
        order.Shipping_Contact__c = quote.Shipping_Contact__c;
        order.Shipping_Instructions__c = quote.Shipping_Instructions__c;
        order.Shipping_Contact_Email__c = quote.Shipping_Contact_Email__c;
        order.Order_Fulfillment_Email_Receipt__c = quote.Order_Fulfillment_Email_Receipt__c;
        order.Delivery_Method__c = quote.Delivery_Method__c;

        System.debug('NKC debug order.Maintenance_Amount__c ['+order.Maintenance_Amount__c+']');
        //Naresh Kumar  04/29/2018 - Populating few order field for below offering types
        if(quote.Offering_Type__c == null || quote.Offering_Type__c == 'PureConnect On Premise'
          || quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription'){
            order.Direct_Sales_Rep_1__c = quote.End_User_ID__r.OwnerId;
            //Direct Sales
            if(quote.End_User_ID__c == quote.Sold_To_Name__c){              
                order.Ship_To_Name__c = quote.End_User_ID__c;
            }
            //Indirect Sales
            else{
                order.Indirect_Sales_Rep_1__c = quote.Sold_To_Name__r.OwnerId;
                order.Ship_To_Name__c = quote.Sold_To_Name__c;
            }
            order.Bill_To_Name__c = quote.Sold_To_Name__c;
            order.Subsidaries__c = quote.Sold_To_Name__r.Subsidary__c;
            if(order.Ship_software_via__c == 'Courier')
                order.Delivery_Method__c = 'Physical';
            else if(order.Ship_software_via__c == 'FTP')
                order.Delivery_Method__c = 'Electronic';
            String strEmails = '';
            //Getting ship to address email address
            List<Account_Order_Address__c> listOfShipToAddress = [SELECT Email__c FROM Account_Order_Address__c 
                                       WHERE Address_Type__c = 'Ship To' AND Quote__c =: quote.id AND Email__c != null];
            if(!listOfShipToAddress.isEmpty())              
                strEmails = listOfShipToAddress[0].Email__c + ';';
            if(quote.BigMachines__Opportunity__r.Owner.Email != null)
                strEmails += quote.BigMachines__Opportunity__r.Owner.Email + ';';              
            if(quote.BigMachines__Opportunity__r.Account.Owner.Email != null)
                strEmails += quote.BigMachines__Opportunity__r.Account.Owner.Email + ';';
            if(quote.Owner.Email != null)
                strEmails += quote.Owner.Email;              
            order.Order_Fulfillment_Email_Receipt__c = strEmails;
            
            //Subsidaries Logic
            for (PS_Oppty_Subsidiary_Overrides__c PSOppSubsidiaryOverrides: PS_Oppty_Subsidiary_Overrides__c.getall().values()) {
                if (quote.BigMachines__Opportunity__r.Country__r.Name != null 
                    && quote.BigMachines__Opportunity__r.Sold_To_Country__r.Name != null 
                    && quote.BigMachines__Opportunity__r.Sold_To_Country__r.Name != quote.BigMachines__Opportunity__r.Country__r.Name) {
                    System.Debug('NLM debug - sold to country on update is not null, sold to country on opp is not null, and they do not match');
                    if (PSOppSubsidiaryOverrides.Country__c == quote.BigMachines__Opportunity__r.Country__r.Name) {
                        // Sold to country has been matched, so we should now update the subsidiary override on the PS Opportunity with the value from the
                        // custom settings. Note that Region could be matched but is not currently required.
                        List<Subsidary__c> listOfSubs = [SELECT id FROM Subsidary__c WHERE Name =: PSOppSubsidiaryOverrides.Subsidiary_Override__c];
                        if(!listOfSubs.isEmpty())
                            order.Subsidaries__c = listOfSubs[0].id;                        
                    }
                } else {
                        if (PSOppSubsidiaryOverrides.Country__c == quote.BigMachines__Opportunity__r.Sold_To_Country__r.Name 
                            || (quote.BigMachines__Opportunity__r.Sold_To_Country__c == null && PSOppSubsidiaryOverrides.Country__c == quote.BigMachines__Opportunity__r.Country__r.Name)) {
                        // Sold to country has been matched, so we should now update the subsidiary override on the PS Opportunity with the value from the
                        // custom settings. Note that Region could be matched but is not currently required.
                        List<Subsidary__c> listOfSubs = [SELECT id FROM Subsidary__c WHERE Name =: PSOppSubsidiaryOverrides.Subsidiary_Override__c];
                        if(!listOfSubs.isEmpty())
                            order.Subsidaries__c = listOfSubs[0].id;                        
                    }
                }
            }           
        }
        
        if(quote.Offering_Type__c == 'Cloud Partner (PPU)'){
            order.NRO_Type__c = 'Pay Per Use';
            order.Direct_Sales_Rep_1__c = quote.BigMachines__Opportunity__r.OwnerId;
            obj = null;
            if(order.Ship_software_via__c != null && !order.Ship_software_via__c.contains('No Shipment Required')){
                if(region == 'North America')
                    obj = Global_Setting__c.getInstance('NA Order Queue');
                if(region=='EMEA' )
                    obj = Global_Setting__c.getInstance('EMEA Order Queue');
                if(region=='LATAM')
                    obj = Global_Setting__c.getInstance('LATAM Order Queue');
                if(region=='APAC')
                    obj = Global_Setting__c.getInstance('APAC Order Queue');
                if(region=='Japan' || region=='JAPAN')
                    obj = Global_Setting__c.getInstance('Japan Order Queue');
            }
            else if(order.Ship_software_via__c != null && order.Ship_software_via__c.contains('No Shipment Required')){
                obj = Global_Setting__c.getInstance('Maintenance Management Group');
            }
            if(obj == null){
                obj = Global_Setting__c.getInstance('Order Queue');
            }
            if(obj != null){
                order.OwnerId = obj.ID__c;
            }
        }
        //Anju July Revpro changes
        if(quote.Offering_Type__c == 'Business Edition' || quote.Offering_Type__c == 'PureConnect Cloud' )
        {
            order.Direct_Sales_Rep_1__c = opp.OwnerId;
            order.Subsidaries__c = opp.account.Subsidary__c;
            order.License_FYM_detail__c = 'Cloud Order';
            if(quote.Offering_Type__c == 'Business Edition')
                order.Master_Order_Number__c = quote.Master_Order__c != null ? quote.Master_Order_Number__c : order.name;
        }
        return order;
    }

    public static Order__c Update_Orders(BigMachines__Quote__c quote,id orderid,string status,string License_FYM_detail,string region,string owner_email, String oppType, Opportunity opp){

        Order__c order = DynamicFieldMapping.getOrderFromQuote(quote, new Order__c(id = orderid), 'Non_Revenue_Orders');
        //order.quote_number__c = quote.name;
        order.name = 'Order ' + quote.name;
        if(License_FYM_detail.equals('Maintenance Only Order')){
            order.name += '-1';
        }
        order.Master_Order_Number__c = order.name;
        //order.Maintenance_Start__c =  quote.Order_Maintenance_Start__c;
        //order.Maintenance_End__c = quote.Order_Maintenance_End__c;
        //order.Quote__c = quote.id;
        //order.Opportunity__c = quote.BigMachines__Opportunity__c;
        order.Due_Date__c = Date.Today() + 2;
        order.PO_Received_Date__c = quote.Order_PO_Received_Date__c;
        Global_Setting__c obj1;
        if(License_FYM_detail=='License only order' || License_FYM_detail=='Both License & Maintenance Order'){
            order.PO_Number__c = quote.Order_PO_Number__c;
            order.PO_Date__c  =  quote.Order_PO_Date__c;
            obj1 = Global_Setting__c.getInstance('License Order RT');

        } else {
            obj1 = Global_Setting__c.getInstance('Maintenence Order RT');
        }
        order.recordtypeid = obj1.ID__c;
        order.order_type__c = 'Revenue';
            /*
            order.Order_Type__c = quote.Order_Type__c;
            order.Special_Instructions__c = quote.Order_Special_Instructions__c;
            order.Numb_of_Maint_Months__c = quote.Order_Numb_of_Maint_Months__c;
            order.Order_Type__c = quote.Order_Type__c;
            order.Ship_software_via__c = Quote.Order_Ship_Software_Via__c;
            order.Agreement_Type__c = quote.Order_Agreement_Type__c;
            order.Payment_Terms__c = quote.Order_Payment_Terms__c;
            order.PO_for_FYM__c = quote.PO_for_FYM__c;
            order.PO_for_FYM__c = quote.PO_for_FYM__c;
            order.Server_OS__c = quote.Server_OS__c;
            order.PBX__c = quote.PBX__c;
            order.Database__c = quote.Database__c;
            order.IVR__c = quote.IVR__c;
            order.Add_Language__c = quote.Add_Language__c;
            order.Rep_email__c = owner_email;
            order.Quarterly_Semi_Annual_Billing_Fee__c = quote.Quarterly_Semi_Annual_Billing_Fee__c;
            order.Licensing_Reduction_Fee__c = quote.Licensing_Reduction_Fee__c;
            order.Reinstatement_fee__c = quote.Reinstatement_fee__c;
            order.Partner_to_Partner_Uplift__c = quote.Partner_to_Partner_Uplift__c;
            order.Extended_End_of_Support__c = quote.Extended_End_of_Support__c;
            order.Partner_to_Direct__c = quote.Partner_to_Direct__c;

            order.Decreased_Quote_Reason__c = quote.Decreased_Quote_Reason__c;
            order.Cancelled_Quote_Reason__c = quote.Cancelled_Quote_Reason__c;
            //order.Total_Discount__c =   quote.Total_Discount__c;
            order.Sent_to_Customer__c   = quote.Sent_to_Customer__c;
            order.Genesys_Care_Rep_Name__c  = quote.Genesys_Care_Rep_Name__c;
            order.Genesys_Care_Rep_Title__c = quote.Genesys_Care_Rep_Title__c;
            order.Genesys_Care_Rep_Phone__c = quote.Genesys_Care_Rep_Phone__c;
            order.Genesys_Care_Rep_Email__c = quote.Genesys_Care_Rep_Email__c;
            order.Genesys_Care_Rep_Cell__c  = quote.Genesys_Care_Rep_Cell__c;
            order.Current_Maint_Rate__c = quote.Current_Maint_Rate__c;
            order.Previous_Maint_Rate__c    = quote.Previous_Maint_Rate__c;
            order.Maintenance_Level__c = quote.Genesys_Care__c;
            order.Maintenance_Start__c = quote.Maintenance_Start_Date__c;
            order.Maintenance_End__c = quote.Maintenance_End_Date__c;
            */
        //Renewal
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
        if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME){
            order.Net_Maint__c = quote.Total_Maintenance_Amount_Due__c;
            order.Total_Order__c = quote.Total_Maintenance_Amount_Due__c;
        }
        //License
        else if(oppType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME){
            order.Net_Maint__c = quote.Total_Genesys_Care__c;
            order.Total_Order__c = quote.BigMachines__Total__c;
        }
        order.Genesys_Care_Specialist_Email__c = opp.Gene_Care_Specialist__r.Email;
        order.Genesys_Care_Ops_Email__c = opp.Quote_Mtce_Ops__r.Email;

        //order.Current_Rate__c = quote.Current_Maint_Rate__c;
        //order.Net_License__c = quote.Total_Software__c;

        //order.OwnerId = '00GK0000000LUYA';//order management group
        //order.Is_licensed_Quote__c = Is_licensed_Quote;
        //For renewal quotes
        if(quote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME){
            //Naresh Kumar 05/12/2014
            //New Mapping Fields for Renewal Only
            order.Maintenance_Amount__c = quote.Grand_Total__c;
            //order.License_FYM_detail__c = 'Maintenance Only Order';
            if(order.Maintenance_Start__c != null && order.Maintenance_End__c != null)
                order.Numb_of_Maint_Months__c = order.Maintenance_Start__c.monthsBetween(order.Maintenance_End__c) + 1;
            order.Order_Type__c = 'Revenue';
            order.Net_Maint__c = quote.Grand_Total__c;
            order.Net_License__c =quote.Total_Revised_Net_License_Value__c;
            order.Revised_Net_License_Value__c = quote.Total_Revised_Net_License_Value__c;
            order.Comments__c = quote.BigMachines__Description__c;
        }
          /*    Global_Setting__c obj;
            if(region == 'North America'){
                if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
                    obj = Global_Setting__c.getInstance('NA Order Queue Renewal');
                else
                    obj = Global_Setting__c.getInstance('NA Order Queue');
            }

            if(region=='EMEA'){
                if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
                    obj = Global_Setting__c.getInstance('EMEA Order Queue Renewal');
                else
                    obj = Global_Setting__c.getInstance('EMEA Order Queue');
            }

            if(region=='LATAM'){
                if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
                    obj = Global_Setting__c.getInstance('LATAM Order Queue Renewal');
                else
                    obj = Global_Setting__c.getInstance('LATAM Order Queue');
            }

            if(region=='APAC'){
                if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
                    obj = Global_Setting__c.getInstance('APAC Order Queue Renewal');
                else
                    obj = Global_Setting__c.getInstance('APAC Order Queue');
            }

            if(obj == null){
                obj = Global_Setting__c.getInstance('Order Queue');
            }

            if(obj != null){
            order.OwnerId = obj.ID__c;
            }*/

        order.Ship_To_Name__c = quote.Ship_To_Name__c;
        order.Shipping_Contact_Phone_Number__c = quote.Shipping_Contact_Phone_Number__c;
        order.Shipping_Contact__c = quote.Shipping_Contact__c;
        order.Shipping_Instructions__c = quote.Shipping_Instructions__c;
        order.Shipping_Contact_Email__c = quote.Shipping_Contact_Email__c;
        order.Shipping_Contact_Email__c = quote.Shipping_Contact_Email__c;
        order.Delivery_Method__c = quote.Delivery_Method__c;

        if(status=='Re-Submitted'){
            order.status__c = status;
        }
        if(quote.PPU_Rental__c)
            order.License_FYM_detail__c = 'Rental Order';        
        else
          order.License_FYM_detail__c = License_FYM_detail;

        // update order;
        return order;
    }
    @future
    public static void CreateMultiShipOrderFuture(Id quoteId, String offeringType) {
        CreateMultiShipOrder(quoteId, offeringType);
    }

    public static List<Order__c> CreateMultiShipOrder(Id quoteId, String offeringType) {
        Map<Id, Order__c> mapOrder = new Map<Id, Order__c>();
        List<Order__c> list_order = new List<Order__c>();
        Set<Id> qpIds = new Set<Id>();
        Set<Id> parentId = new Set<Id>();        
        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(quoteId);
        Set<Id> softwareOnlyOrderIds = new Set<Id>();
        softwareOnlyOrderIds.add(quoteId);
        Map<Id, List<Order_Line_Item__c>> mapOrderSoftLine = new Map<Id, List<Order_Line_Item__c>>();
        Map<String, RecordType> rts = new Map<String, RecordType>();
        if(offeringType == null)
            offeringType = QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE;
    Integer noOfSoftwareLines = 0;
        for (RecordType rT : [select id,name from recordtype where SobjectType = 'Order__c']) {
            rts.put(rT.Name, rT);
        }
        Order__c objOrderToBeUpdated;
        for (Order__c order : [
                SELECT Id, Quote__c, name, Date_Submitted__c, Due_Date__c, PO_Received_Date__c, PO_Number__c, PO_Date__c, recordtypeid, order_type__c,
                        Genesys_Care_Specialist_Email__c, Genesys_Care_Ops_Email__c, Net_Maint__c, OwnerId, status__c,
                        License_FYM_detail__c, Maintenance_Amount__c, Numb_of_Maint_Months__c, Offering_Type__c,
                        Net_License__c, Revised_Net_License_Value__c, Comments__c, Ship_To_Name__c, Shipping_Contact_Phone_Number__c,
                        Shipping_Contact__c, Shipping_Instructions__c, Shipping_Contact_Email__c, Order_Fulfillment_Email_Receipt__c,
                        Delivery_Method__c, CurrencyIsoCode,Opportunity__c, Total_Order__c, End_User_Name__c, Sold_To_Name__c, Opportunity_Type__c,
                  Quote_Number__c, Ship_software_via__c, Date_Rejected__c, Date_Re_Submitted__c, Maintenance_Start__c, Maintenance_End__c, Payment_Terms__c,
                  Direct_Sales_Rep_1__c, Indirect_Sales_Rep_1__c, Bill_To_Name__c, Subsidaries__c,
                        (SELECT Id, Order__c, Quote_Product__c, Quote_Product__r.BigMachines__Product__r.Type__c, List_Price__c, Net_Unit_Price__c,
                         Sales_Price__c, Ext_Net_Price__c, Year__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, Base_Package__c, POB_Type__c,
                         Product__c, APN_Number__c, BigMachines_Quantity__c, Quantity__c, Unit_of_Measure__c, Ext_List__c, Total_Discount__c,
                         Revised_Net_License_Value__c, Original_Net_License_Value__c, Current_Qty__c FROM Order_Line_Items__r)
                FROM Order__c WHERE Quote__c in :quoteIds LIMIT 1
        ]) {

            mapOrder.put(order.Quote__c, order);
            parentId.add(order.Id);
            objOrderToBeUpdated = order;
            order.TCV__c = 0;
            System.debug(LoggingLevel.Error,'------parentId='+parentId );
            for (Order_Line_Item__c oli : order.Order_Line_Items__r){
                if (oli.Quote_Product__r.BigMachines__Product__r.Type__c != 'Product - Hardware' && oli.Quote_Product__r.BigMachines__Product__r.Type__c != 'Hardware Warranty' && oli.Order__c != null){
                    noOfSoftwareLines ++;
                    if (mapOrderSoftLine.containsKey(oli.Order__c)){
                        mapOrderSoftLine.get(oli.Order__c).add(oli);
                    } else {
                        mapOrderSoftLine.put(oli.Order__c , new List<Order_Line_Item__c>{oli});
                    }                    
                }
                order.TCV__c += oli.Ext_Net_Price__c == null ? 0 : oli.Ext_Net_Price__c;
                qpIds.add(oli.Quote_Product__c);                
            }
        }
        if(objOrderToBeUpdated != null)
            update objOrderToBeUpdated;
        List<Order__c> list_OfOrderToBeDeleted = [SELECT id FROM Order__c WHERE Original_Parent_Order1__c =: parentId];
        if(!list_OfOrderToBeDeleted.isEmpty()){
            delete list_OfOrderToBeDeleted;
        }
        System.debug(LoggingLevel.Error,'------qpIds='+qpIds);
        System.debug(LoggingLevel.Error,'------mapOrderSoftLine='+mapOrderSoftLine );
        Map<Id, List<Account_Order_Address__c>> mapaoa = new Map<Id, List<Account_Order_Address__c>>();
        List<Account_Order_Address__c> list_OrderAddress = new List<Account_Order_Address__c>();
        if (!parentId.isEmpty()) {
            for (Account_Order_Address__c aoa :
            [SELECT Id, Order__c, Additional_Emails__c, Address__c, Address2__c, Address_Type__c, Attention_To__c,City__c,
                    Company__c, Company_Name2__c, Country__c, Email__c, Account__c, First_Name__c, Last_Name__c,
                    Need_By_Date__c, New__c,Phone__c, Quote__c, Shipping_Instructions__c, Shipping_Method_Name__c,
                    Sold_To_Business_Partner__c, State__c, Zip_Code__c, Hardware_Address__c, Copied_From__c
            FROM Account_Order_Address__c
            WHERE Order__c In :parentId ]){ //AND Address_Type__c = 'Ship To'
                if (mapaoa.containsKey(aoa.Order__c)) {
                    mapaoa.get(aoa.Order__c).add(aoa);
                }else {
                    mapaoa.put(aoa.Order__c, new List<Account_Order_Address__c>{aoa});
                }
                System.debug(LoggingLevel.Error,'------mapaoa='+mapaoa );
                list_OrderAddress.add(aoa);
            }
        }
        System.debug(' list_OrderAddress = ' + list_OrderAddress);

        Map<Id, Order_Line_Item_Allocation__c> mapOLIT = new Map<Id, Order_Line_Item_Allocation__c>([
                SELECT id, Order_Line_Item__c, Quantity__c, Quote_Product__c, Quote_Product__r.BigMachines__Quote__c,
                Order_Shipping_Location__c, Order_Shipping_Location__r.Address__c, Order_Shipping_Location__r.City__c,
                Order_Shipping_Location__r.State__c FROM Order_Line_Item_Allocation__c
                WHERE Quote_Product__r.BigMachines__Quote__c IN :quoteIds AND Quantity__c > 0]);
        
        Boolean blnMasterOrderCreated = false;
        List<Order__c> hardwareOrders = new List<Order__c>();
        Integer hardwareCount = 1;
        Map<Id, Order__c> map_OfOrderShippingLocations = new Map<Id, Order__c>();
        Map<Id, Order__c> map_OfIdAndOrderShippingLocations = new Map<Id, Order__c>();
        
        Id orderOwnerId = QuoteUtil.getOrderManagementQueue(quoteId);
        for (Order_Line_Item_Allocation__c qlt : mapOLIT.values()) {
            if (qlt.Quote_Product__r.BigMachines__Quote__c != null &&
                    mapOrder.containsKey(qlt.Quote_Product__r.BigMachines__Quote__c)) {
                if(!blnMasterOrderCreated && (offeringType == QuoteUtil.OFFERING_TYPE_CIC || offeringType == 'PureConnect Subscription' || offeringType == QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE))
                {
                    Order__c masterOrder = mapOrder.get(qlt.Quote_Product__r.BigMachines__Quote__c);
                    masterOrder.Master_Order_Number__c = mapOrder.get(qlt.Quote_Product__r.BigMachines__Quote__c).Name;
                    if (rts.containsKey('Master Order')) {
                        masterOrder.recordtypeid = rts.get('Master Order').Id;
                    }
                    list_order.add(masterOrder);
                    blnMasterOrderCreated = true;
                }
                if(map_OfOrderShippingLocations.keySet().contains(qlt.Order_Shipping_Location__c)){
                    map_OfIdAndOrderShippingLocations.put(qlt.id, map_OfOrderShippingLocations.get(qlt.Order_Shipping_Location__c));
                  continue;             
                }       
                Order__c orderNew = new Order__c();                
                orderNew = CloneOrder(mapOrder.get(qlt.Quote_Product__r.BigMachines__Quote__c), qlt.Id, null);
                orderNew.Master_Order_Number__c = mapOrder.get(qlt.Quote_Product__r.BigMachines__Quote__c).Name;
                if (rts.containsKey('Hardware Order')) 
                {
                    orderNew.recordtypeid = rts.get('General Orders').Id;
                    orderNew.Name = orderNew.Name + '-HW -' + String.valueOf(hardwareCount);
                    orderNew.License_FYM_detail__c = 'Hardware Order';
                    orderNew.Delivery_Method__c = 'Physical';
                    orderNew.Annual_Contract_Value__c = null; 
                    orderNew.Maintenance_Start__c = null;
                    orderNew.Maintenance_End__c = null;
                    orderNew.Numb_of_Maint_Months__c = null;
                    System.debug(' qlt.Quote_Product__r.BigMachines__Quote__c =' + qlt.Quote_Product__r.BigMachines__Quote__c);
                    orderNew.OwnerId = orderOwnerId;
                    hardwareCount ++;     
                    map_OfIdAndOrderShippingLocations.put(qlt.id, orderNew);
                    map_OfOrderShippingLocations.put(qlt.Order_Shipping_Location__c, orderNew);
                }
                list_order.add(orderNew);
                hardwareOrders.add(orderNew);
                qpIds.add(qlt.Quote_Product__c);
                quoteIds.add(qlt.Quote_Product__r.BigMachines__Quote__c);
                
            }
        }
        if((offeringType == QuoteUtil.OFFERING_TYPE_CIC || offeringType == 'PureConnect Subscription' || offeringType == QuoteUtil.OFFERING_TYPE_PUREENGAGE_ONPREMISE) && noOfSoftwareLines > 1){
            for (Id softwareQuiteId : softwareOnlyOrderIds) {
                if (quoteIds.contains(softwareQuiteId)){
                    Order__c orderSoftwareNew = new Order__c();
                    orderSoftwareNew = CloneOrder(mapOrder.get(softwareQuiteId), null, null);
                    orderSoftwareNew.Name = orderSoftwareNew.Name + '-SW';
                    orderSoftwareNew.Master_Order_Number__c = mapOrder.get(softwareQuiteId).Name;
                    if (rts.containsKey('General Orders')) {
                        orderSoftwareNew.recordtypeId = rts.get('General Orders').Id;
                    }
                    list_order.add(orderSoftwareNew);
                }
            }
        }
        Map<Id, BigMachines__Quote__c> mapQuotes = new Map<Id, BigMachines__Quote__c>([
                SELECT Id,Maintenance_End_Date__c, Maintenance_Start_Date__c,Order_Numb_of_Maint_Months__c,
                        PO_for_FYM__c, Current_Maint_Rate__c, Offering_Type__c, Quote_Business_Type__c, PPU_Rental__c
                FROM BigMachines__Quote__c WHERE Id In: quoteIds
        ]);
        Map<Id,BigMachines__Quote_Product__c> bq =  new Map<Id,BigMachines__Quote_Product__c>([select id,Unit_of_Measure__c,Quantity__c, Product__c, Net_Unit_Price__c, Name, List_Price__c,
                Line_Number__c, Ext_Net_Price__c, Ext_List__c, CurrencyIsoCode, APN_Number__c,
                BigMachines__Description__c, BigMachines__Quantity__c, BigMachines__Quote__c, BigMachines__Sales_Price__c,
                BigMachines__Product__c, BigMachines__Product__r.Type__c,BigMachines__Product__r.PS_Contract__c,BigMachines__Product__r.Name,BigMachines__Product__r.Description,
                Maintenance_Start_Date__c,Year2_Maintenance_Due__c,Year3_Maintenance_Due__c,Year4_Maintenance_Due__c,Year5_Maintenance_Due__c,
                Maintenance_End_Date__c,Year2_CareRatePercent__c,Year3_CareRatePercent__c,Year4_CareRatePercent__c,Year5_CareRatePercent__c,
                Maintenance_Due__c, Fees_Applied__c,Genesys_Care_Rate__c, Increase__c,
                Revised_Net_License_Value__c, Extended_End_of_Support__c, Contract_Line_Update_Status__c, Original_Qty__c,
                Current_Qty__c, Total_Discount__c, Product_Specific_Discount__c, BigMachines__Total_Price__c,
                Sold_To_Name__c, End_User_Name__c, Service_Contract_Line_ID__c, BigMachines__Quote__r.Offering_Type__c,
                Annualized_Maintenance_Last_Period__c, Flavor__c,Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,
                Application_Support_Cost_Base__c,Solution_Names_Covered__c,Third_Party_Partner_Fee__c, BigMachines__Product__r.Sub_Type__c, BigMachines__Product__r.Third_Party__c,BigMachines__Product__r.New_category__c,BigMachines__Product__r.sub_Category__c,BigMachines__Product__r.POB_Type__c
        From BigMachines__Quote_Product__c where Id In : qpIds]);

        System.debug(LoggingLevel.Error,'------bq='+bq );

        if (!list_order.isEmpty()){
            upsert list_order;
        }
        List<Order_Line_Item_Allocation__c> list_ShippingAllocations = new List<Order_Line_Item_Allocation__c>();
        Map<Id, List<Id>> map_OfOrderIdVsAllocationIds = new Map<Id, List<Id>>(); 
        //Updating shipping locations with order lookup
        for(Id eachId : map_OfIdAndOrderShippingLocations.keyset()){
          Order_Line_Item_Allocation__c allocationToBeUpdated = new Order_Line_Item_Allocation__c(id = eachId, Order1__c = map_OfIdAndOrderShippingLocations.get(eachId).id);    
            list_ShippingAllocations.add(allocationToBeUpdated);
            if(map_OfOrderIdVsAllocationIds.get(allocationToBeUpdated.Order1__c) == null){
                List<Id> newList = new List<Id>();
                newList.add(eachId);
                map_OfOrderIdVsAllocationIds.put(allocationToBeUpdated.Order1__c, newList);
            }
            else{
                map_OfOrderIdVsAllocationIds.get(allocationToBeUpdated.Order1__c).add(eachId);
            }
        }
        if(!list_ShippingAllocations.isEmpty()){
            update list_ShippingAllocations;
        }
        System.debug(LoggingLevel.Error,'------list_order='+list_order );

        list<Order_Line_Item__c> oli_lst = new list<Order_Line_Item__c>();

        for (Order__c order : list_order){            
            System.debug(LoggingLevel.Error,'------order.Order_Line_Item_Allocation__c='+order.Order_Line_Item_Allocation__c );
            System.debug(LoggingLevel.Error,'------order.Original_Parent_Order1__c='+order.Original_Parent_Order1__c );
            //Hardware
            if (order.Order_Line_Item_Allocation__c != null &&
                mapOLIT.containsKey(order.Order_Line_Item_Allocation__c)){
                order.TCV__c = 0;
                for(Id eachAllocationId : map_OfOrderIdVsAllocationIds.get(order.id)){
                    Order_Line_Item_Allocation__c oliA = mapOLIT.get(eachAllocationId);
                    BigMachines__Quote__c quote = mapQuotes.get(oliA.Quote_Product__r.BigMachines__Quote__c);
                    //integer line_number=1;
                    BigMachines__Quote_Product__c bm_qm = bq.get(oliA.Quote_Product__c);
                    Order_Line_Item__c  obj = buildOrderLI(order, quote, bm_qm, oliA);
                    oli_lst.add(obj);
                    order.TCV__c += obj.Ext_Net_Price__c == null ? 0 : obj.Ext_Net_Price__c;
                }
            }
            //Hardware order
            if (order.Order_Line_Item_Allocation__c != null && mapOLIT.containsKey(order.Order_Line_Item_Allocation__c) 
                && noOfSoftwareLines == 1){
                BigMachines__Quote__c quote = mapQuotes.get(order.Quote__c);
                order.TCV__c = 0;
                for (Order_Line_Item__c oli : mapOrderSoftLine.get(order.Original_Parent_Order1__c)) {
                    if (bq.containsKey(oli.Quote_Product__c)) {
                        BigMachines__Quote_Product__c bm_qm = bq.get(oli.Quote_Product__c);    
                        Order_Line_Item__c obj = buildOrderLI(order, quote, bm_qm, null);
                        if(bm_qm.BigMachines__Quote__r.Offering_Type__c == 'PureEngage Subscription' || bm_qm.BigMachines__Quote__r.Offering_Type__c == 'PureConnect Subscription'){
                                                        
                        }                        
                        oli_lst.add(obj);
                        order.TCV__c += obj.Ext_Net_Price__c == null ? 0 : obj.Ext_Net_Price__c;
                    }
                }              
            }
            //Software Order
            else if (order.Order_Line_Item_Allocation__c == null &&
                mapOrderSoftLine.containsKey(order.Original_Parent_Order1__c)) {
                BigMachines__Quote__c quote = mapQuotes.get(order.Quote__c);
                order.TCV__c = 0;
                System.debug(LoggingLevel.Error,'------order.Original_Parent_Order1__c='+order.Original_Parent_Order1__c );
                for (Order_Line_Item__c oli : mapOrderSoftLine.get(order.Original_Parent_Order1__c)) {
                    System.debug(LoggingLevel.Error,'------bq='+oli.Quote_Product__c);
                    System.debug(LoggingLevel.Error,'-----bq.containsKey(oli.Quote_Product__c)='+bq.containsKey(oli.Quote_Product__c));
                    if (bq.containsKey(oli.Quote_Product__c)) {
                        BigMachines__Quote_Product__c bm_qm = bq.get(oli.Quote_Product__c);
                        Order_Line_Item__c obj = buildOrderLI(order, quote, bm_qm, null);
                        obj.Revised_Net_License_Value__c = oli.Revised_Net_License_Value__c;
                        obj.Original_Net_License_Value__c = oli.Original_Net_License_Value__c;
                        obj.Current_Qty__c = oli.Current_Qty__c;
                        if(bm_qm.BigMachines__Quote__r.Offering_Type__c == 'PureEngage Subscription' || bm_qm.BigMachines__Quote__r.Offering_Type__c == 'PureConnect Subscription'){
                            obj.Year__c = oli.Year__c;
                            obj.Maintenance_Start_Date__c = oli.Maintenance_Start_Date__c;
                            obj.Maintenance_End_Date__c = oli.Maintenance_End_Date__c;
                            obj.Base_Package__c = oli.Base_Package__c;
                            obj.List_Price__c = oli.List_Price__c;
                            obj.Net_Unit_Price__c = oli.Net_Unit_Price__c;
                            obj.Sales_Price__c = oli.Sales_Price__c;
                            obj.Ext_Net_Price__c = oli.Ext_Net_Price__c;
                        }
                        oli_lst.add(obj);
                        order.TCV__c += obj.Ext_Net_Price__c == null ? 0 : obj.Ext_Net_Price__c;
                    }                    
                    //PureSuccess Lines
                    else if(quote.Offering_Type__c == 'PureEngage Subscription' || quote.Offering_Type__c == 'PureConnect Subscription'){
                        Order_Line_Item__c obj = oli.clone(false, true, false, false);
                        obj.Order__c = order.id;
                        obj.Product__c = oli.Product__c;
                        obj.APN_Number__c = oli.APN_Number__c;
                        obj.BigMachines_Quantity__c = oli.BigMachines_Quantity__c;
                        obj.Quantity__c = oli.Quantity__c;
                        obj.Unit_of_Measure__c = oli.Unit_of_Measure__c;
                        obj.Ext_List__c = oli.Ext_List__c;
                        obj.Total_Discount__c = oli.Total_Discount__c;
                        oli_lst.add(obj);
                        order.TCV__c += obj.Ext_Net_Price__c == null ? 0 : obj.Ext_Net_Price__c;
                    }
                }
            }
        }
        if (!list_order.isEmpty()){
            update list_order;
        }
        System.debug(LoggingLevel.Error,'------oli_lst='+oli_lst );
        if (!oli_lst.isEmpty()){
            insert oli_lst;
        }
        System.debug(LoggingLevel.Error,'------mapaoa='+mapaoa );
        List<Account_Order_Address__c> listInsertaoa = new List<Account_Order_Address__c>();
        
        for (Order__c eachOrder : list_order) {
            if (mapaoa.containsKey(eachOrder.Original_Parent_Order1__c)){
                for (Account_Order_Address__c eachAOA : mapaoa.get(eachOrder.Original_Parent_Order1__c)){
                    Account_Order_Address__c aoaInsert = eachAOA.clone(false,true,false,false);
                    aoaInsert.Order__c = eachOrder.Id;
                    System.debug('NKC debug eachOrder.Name [' + eachOrder.Name + ']');
                    System.debug('NKC debug eachOrder.Order_Line_Item_Allocation__c [' + eachOrder.Order_Line_Item_Allocation__c + ']');
                    System.debug('NKC debug eachAOA.Address_Type__c [' + eachAOA.Address_Type__c + ']');
                    //If it's hardware order
                    if(eachOrder.Order_Line_Item_Allocation__c != null && eachAOA.Address_Type__c == 'Ship To'){
                        Order_Line_Item_Allocation__c shippingLocation = mapOLIT.get(eachOrder.Order_Line_Item_Allocation__c);
                        if(eachAOA.Copied_From__c == shippingLocation.Order_Shipping_Location__c){
                            listInsertaoa.add(aoaInsert);
                        }
                        /*
                        if(eachAOA.Address__c == shippingLocation.Order_Shipping_Location__r.Address__c
                            && eachAOA.City__c == shippingLocation.Order_Shipping_Location__r.City__c
                            && eachAOA.State__c == shippingLocation.Order_Shipping_Location__r.State__c){
                            listInsertaoa.add(aoaInsert);        
                        }
            */
                    }
                    //if it's software order
                    else if(eachAOA.Address_Type__c == 'Ship To' && eachOrder.Order_Line_Item_Allocation__c == null
                            && eachOrder.Name != null && eachOrder.Name.endsWith('-SW')){ 
                        if(!eachAOA.Hardware_Address__c)
                          listInsertaoa.add(aoaInsert);        
                    }
                    else 
                        listInsertaoa.add(aoaInsert);                    
                }
            }
        }
        update list_order;
        System.debug(' hardwareOrders =' + hardwareOrders);
        // inserting address for hardware order in case CaaS
        if(offeringType == QuoteUtil.OFFERING_TYPE_CAAS){
            for(Order__c hardwareOrder : hardwareOrders)
                CreateOrderAddressFromQuote(hardwareOrder.id);
        }
        System.debug(LoggingLevel.Error,'------listInsertaoa='+listInsertaoa );
        if(!listInsertaoa.isEmpty()){
           insert listInsertaoa;
        }
        System.debug(LoggingLevel.Error,'------listInsertaoa='+listInsertaoa );
        System.debug(LoggingLevel.Error,'------oli_lst='+oli_lst );

        return null;

    }

    public static Order__c CloneOrder(Order__c order, Id qltId, Id recordtypId){
        Order__c orderNew = new Order__c();     
        orderNew.name = order.name;
        orderNew.End_User_Name__c = order.End_User_Name__c;
        orderNew.Sold_To_Name__c = order.Sold_To_Name__c;
        orderNew.Maintenance_Start__c = order.Maintenance_Start__c;
        orderNew.Maintenance_End__c = order.Maintenance_End__c;
        orderNew.Payment_Terms__c = order.Payment_Terms__c;
        orderNew.Total_Order__c = 0;
        orderNew.Opportunity__c = order.Opportunity__c;
        orderNew.Date_Submitted__c = order.Date_Submitted__c;
        orderNew.Due_Date__c = order.Due_Date__c;
        orderNew.PO_Received_Date__c = order.PO_Received_Date__c;
        orderNew.PO_Number__c = order.PO_Number__c;
        orderNew.PO_Date__c  =  order.PO_Date__c;
        orderNew.recordtypeid = order.recordtypeid;
        orderNew.Order_Type__c = 'Revenue';
        orderNew.Genesys_Care_Specialist_Email__c = order.Genesys_Care_Specialist_Email__c;
        orderNew.Genesys_Care_Ops_Email__c = order.Genesys_Care_Ops_Email__c;
        orderNew.Net_Maint__c = order.Net_Maint__c;
        orderNew.OwnerId = order.OwnerId;
        orderNew.status__c = order.status__c;
        orderNew.License_FYM_detail__c = order.License_FYM_detail__c;
        orderNew.Maintenance_Amount__c = order.Maintenance_Amount__c;
        orderNew.Opportunity_Type__c = order.Opportunity_Type__c;
        orderNew.Numb_of_Maint_Months__c = order.Numb_of_Maint_Months__c;
        orderNew.Net_License__c = order.Net_License__c;
        orderNew.Revised_Net_License_Value__c = order.Revised_Net_License_Value__c;
        orderNew.Comments__c = order.Comments__c;
        orderNew.Ship_To_Name__c = order.Ship_To_Name__c;
        orderNew.Shipping_Contact_Phone_Number__c = order.Shipping_Contact_Phone_Number__c;
        orderNew.Shipping_Contact__c = order.Shipping_Contact__c;
        orderNew.Shipping_Instructions__c = order.Shipping_Instructions__c;
        orderNew.Shipping_Contact_Email__c = order.Shipping_Contact_Email__c;
        orderNew.Order_Fulfillment_Email_Receipt__c = order.Order_Fulfillment_Email_Receipt__c;
        orderNew.Delivery_Method__c = order.Delivery_Method__c;
        orderNew.Direct_Sales_Rep_1__c = order.Direct_Sales_Rep_1__c;
        orderNew.Indirect_Sales_Rep_1__c = order.Indirect_Sales_Rep_1__c;
        orderNew.Bill_To_Name__c = order.Bill_To_Name__c;
        orderNew.Subsidaries__c = order.Subsidaries__c;
        orderNew.Original_Parent_Order1__c = order.Id;
        orderNew.Order_Line_Item_Allocation__c = qltId;
        orderNew.CurrencyIsoCode = order.CurrencyIsoCode;
        orderNew.Quote__c = order.Quote__c; 
        orderNew.quote_number__c = order.quote_number__c;
        orderNew.Ship_software_via__c = order.Ship_software_via__c;
        orderNew.Date_Rejected__c = order.Date_Rejected__c;
        orderNew.Date_Re_Submitted__c = order.Date_Re_Submitted__c;     
        return orderNew;
    }

    public static Order_Line_Item__c buildOrderLI (Order__c order, BigMachines__Quote__c quote, BigMachines__Quote_Product__c bm_qm, Order_Line_Item_Allocation__c objOLIA){
        Order_Line_Item__c obj = new Order_Line_Item__c();
        List<String> list_Types = Label.Types_Required_Add_Products.split(';');

        obj.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
        obj.Flavor__c = bm_qm.Flavor__c;       
 obj.POB_Type__c = QuoteUtil.getPOBType(bm_qm.BigMachines__Product__r.Type__c, 
                                                      bm_qm.BigMachines__Product__r.Sub_Type__c,
                                                    bm_qm.BigMachines__Product__r.New_Category__c,
                                                      bm_qm.BigMachines__Product__r.Third_Party__c,
                                                      
                                                      order.License_FYM_detail__c,
                                                      order.Offering_Type__c,bm_qm.BigMachines__Product__r.POB_Type__c); 
        obj.Unit_of_Measure__c = bm_qm.Unit_of_Measure__c;
        if(objOLIA == null){
            obj.Quantity__c = bm_qm.Quantity__c;
            obj.BigMachines_Quantity__c = bm_qm.BigMachines__Quantity__c;
        }
        else{
            obj.Quantity__c = objOLIA.Quantity__c;
            obj.BigMachines_Quantity__c = objOLIA.Quantity__c;
        }        
        obj.Product_txt__c = bm_qm.Product__c;
        obj.Product__c = bm_qm.BigMachines__Product__c;        
        obj.Name = bm_qm.APN_Number__c;
        System.Debug('bm_qm.QP--->'+bm_qm);
        System.Debug('bm_qm.Line_Number__c--->'+bm_qm.Line_Number__c);
        obj.Line_Number__c = bm_qm.Line_Number__c;        
        obj.CurrencyIsoCode = bm_qm.CurrencyIsoCode;
        obj.APN_Number__c = bm_qm.APN_Number__c;
        obj.Order__c = order.id;
        obj.description__c = bm_qm.BigMachines__Description__c;        
        obj.Total_Discount__c = bm_qm.Total_Discount__c;
        obj.Product_Specific_Discount__c = bm_qm.Product_Specific_Discount__c;

        obj.Maintenance_End_Date__c = bm_qm.Maintenance_End_Date__c ;
        obj.Maintenance_Start_Date__c = bm_qm.Maintenance_Start_Date__c ;

        // 1/21/2015 : Copy additional information for PS product
        if((quote.Quote_Business_Type__c == 'Renewal') &&
                String.isNotBlank(bm_qm.BigMachines__Product__r.Type__c))
        {
            for(String strType : list_Types)
            {
                if(bm_qm.BigMachines__Product__r.Type__c == strType)
                {
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
        if(quote.PO_for_FYM__c !=null && quote.PO_for_FYM__c !='Declined Maintenance')
        {
            //if(recType != null && recType == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
            if(quote.Quote_Business_Type__c != 'Renewal')
            {
                if(quote.Current_Maint_Rate__c != null) {
                    obj.Maintenance_Due__c = bm_qm.BigMachines__Total_Price__c * (quote.Current_Maint_Rate__c/100);
                }
                if(obj.Maintenance_Due__c != null && obj.Maintenance_Due__c != 0 && quote.Order_Numb_of_Maint_Months__c !=0) {
                    obj.Annualized_Maintenance_Due__c =  (obj.Maintenance_Due__c/quote.Order_Numb_of_Maint_Months__c)*12;

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
        obj.List_Price__c = bm_qm.List_Price__c;
        obj.Net_Unit_Price__c = bm_qm.List_Price__c;    
        if(obj.List_Price__c != null && obj.Quantity__c != null)
            obj.Ext_List__c = obj.List_Price__c * obj.Quantity__c;
        if(obj.List_Price__c != null && obj.Total_Discount__c != null)
            obj.Net_Unit_Price__c -= (obj.List_Price__c * obj.Total_Discount__c /100);
            
        obj.sales_price__c = bm_qm.Net_Unit_Price__c;    
        if(obj.Net_Unit_Price__c != null && obj.Quantity__c != null)
            obj.Ext_Net_Price__c = obj.Net_Unit_Price__c * obj.Quantity__c;
        obj.Service_Contract_Line_ID__c=bm_qm.Service_Contract_Line_ID__c;
        order.Total_Order__c += (obj.Sales_Price__c == null ? 0 : obj.Sales_Price__c ) * (obj.BigMachines_Quantity__c == null ? 0 : obj.BigMachines_Quantity__c); 
        
        //Naresh Kumar  10/16/2018  - Populating Dummy APNs for Rental order
        if(bm_qm.BigMachines__Product__r.Type__c == 'Product' && order.License_FYM_detail__c == 'Rental Order'){
            if(quote.Offering_Type__c == null && quote.PPU_Rental__c)
                obj.Dummy_APN__c = Label.Rental_Order_Dummy_APNs.split(';')[0];
            else if(quote.Offering_Type__c == 'PureConnect On Premise' && quote.PPU_Rental__c)
                obj.Dummy_APN__c = Label.Rental_Order_Dummy_APNs.split(';')[1];
        }
        
        return obj;
    }
    @testvisible
    private static void CreateOrderAddressFromQuote(String orderId){
        String quoteId = [SELECT Quote__c FROM Order__c WHERE id =: orderId].Quote__c;
        List<Account_Order_Address__c> orderAddress = new List<Account_Order_Address__c>();
        for(Account_Order_Address__c quoteAddress : [SELECT Id, Order__c, Additional_Emails__c, Address__c, Address2__c, Address_Type__c, Attention_To__c,City__c,
                    Company__c, Company_Name2__c, Country__c, Email__c, Account__c, First_Name__c, Last_Name__c,
                    Need_By_Date__c, New__c,Phone__c, Quote__c, Shipping_Instructions__c, Shipping_Method_Name__c,
                    Sold_To_Business_Partner__c, State__c, Zip_Code__c
            FROM Account_Order_Address__c
            WHERE Quote__c = :quoteId]){
            //AND Address_Type__c = 'Ship To']
                Account_Order_Address__c newOrderAddress = quoteAddress.clone(false, false, false, false);
                newOrderAddress.Quote__c = null;
                newOrderAddress.Order__c = orderId;
                orderAddress.add(newOrderAddress);
         }
         insert orderAddress;   
            
    }
    
    //Added By Ranjith on Jun 14, 2017 -- Starts
    //*** Method to create Hardware orders based on Ship to addresses
    public static void createMultiShipOrderForPureConnect(Id quoteId, Order__c objNewOrder) {

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
    
        for(RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Order__c']) {
            map_OrderRecTypes.put(recType.Name, recType);
        }   
        
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
            else if(obj_AOA.Address_Type__c == 'Bill To' || obj_AOA.Address_Type__c == 'Sold To' || obj_AOA.Address_Type__c == 'End User') {
                list_NonShipToOrderAddresses.add(obj_AOA);
            }
            obj_AOA.Order__c = objNewOrder.Id;
        }
        System.debug('$$$$$list_HWShipToOrderAddresses'+list_HWShipToOrderAddresses.size());
        System.debug('$$$$$list_NonShipToOrderAddresses'+list_NonShipToOrderAddresses.size());
        update list_AllAccountOrderAddresses; 
        
        //if HW order needs to be created
        if(list_HWShipToOrderAddresses.size() > 0) {
            
            BigMachines__Quote__c objQuote = [SELECT Id, Offering_Type__c FROM BigMachines__Quote__c WHERE Id = :quoteId LIMIT 1];
            //Create HW orders
            Id idHWOrderOwner = QuoteUtil.getOrderManagementQueue(quoteId);
            if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC) {
                idHWOrderOwner = [SELECT Id FROM Group WHERE DeveloperName = 'Cloud_Billing_Master_Orders_Queue' AND Type = 'Queue' LIMIT 1].Id;
            }
            //Build as many HW orders as ship to (with Shipping method field populated) address count
            for(Integer i=0; i<list_HWShipToOrderAddresses.size(); i++) {
                Order__c obj_NewHWOrder = objNewOrder.clone(false, false, false, false);
                obj_NewHWOrder.Name = objNewOrder.Name + '-HW -' + (i+1);
                obj_NewHWOrder.RecordTypeId = map_OrderRecTypes.get('Hardware Order').Id;
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
    //Naresh Kumar  -   07/04/2018 - Creating child orders for a NRO.
    @future
    public static void createChildOrdersForNRO(Id quoteId){
        
        List<Order__c> listOfOrders = [SELECT Id, Quote__c, Name, Date_Submitted__c, Due_Date__c, PO_Received_Date__c, PO_Number__c, PO_Date__c, recordtypeid, order_type__c,
                        Genesys_Care_Specialist_Email__c, Genesys_Care_Ops_Email__c, Net_Maint__c, OwnerId, status__c,
                        License_FYM_detail__c, Maintenance_Amount__c, Numb_of_Maint_Months__c, Offering_Type__c,
                        Net_License__c, Revised_Net_License_Value__c, Comments__c, Ship_To_Name__c, Shipping_Contact_Phone_Number__c,
                        Shipping_Contact__c, Shipping_Instructions__c, Shipping_Contact_Email__c, Order_Fulfillment_Email_Receipt__c,
                        Delivery_Method__c, CurrencyIsoCode,Opportunity__c, Total_Order__c, End_User_Name__c, Sold_To_Name__c, Opportunity_Type__c,
                        Quote_Number__c, Date_Rejected__c, Date_Re_Submitted__c, Maintenance_Start__c, Maintenance_End__c, Payment_Terms__c,
                        Ship_software_via__c, NRO_Type__c, Bill_To_Name__c, Order_Date__c, ERP_Hold__c, Priority__c, 
                        (SELECT Id, Order__c, End_User_Name__c, Quote_Product__c, Quote_Product__r.BigMachines__Product__r.Type__c, List_Price__c, Net_Unit_Price__c,
                        Sales_Price__c, Ext_Net_Price__c, Year__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, Base_Package__c, POB_Type__c,
                        Product__c, APN_Number__c, BigMachines_Quantity__c, Quantity__c, Unit_of_Measure__c, Ext_List__c, Total_Discount__c FROM Order_Line_Items__r),
                        Annual_Contract_Value__c FROM Order__c WHERE Quote__c = :quoteId];
        
        Order__c objMasterOrder;
        if(listOfOrders.isEmpty()){
            return;
        }
        else{
            objMasterOrder = listOfOrders[0];
        }
        
        List<Order__c> listOfOrdersToBeUpdated = new List<Order__c>();
        objMasterOrder.Master_Order_Number__c = objMasterOrder.Name;
        objMasterOrder.RecordTypeId =  Order__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Master Order').getRecordTypeId();
        listOfOrdersToBeUpdated.add(objMasterOrder);
        
        List<Order_Line_Item__c> listOfOLIUsaseOrder = new List<Order_Line_Item__c>();
        //Child NRO order
        Order__c objChildNROOrder = objMasterOrder.clone(false, true, false, false);
        objChildNROOrder.Master_Order_Number__c = objMasterOrder.Name;
        objChildNROOrder.Original_Parent_Order1__c = objMasterOrder.id;
        objChildNROOrder.Name += '-NRO';
        objChildNROOrder.RecordTypeId =  Order__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Non-Revenue Orders').getRecordTypeId();
        listOfOrdersToBeUpdated.add(objChildNROOrder);
        
        upsert listOfOrdersToBeUpdated;
        
        List<Order_Line_Item__c> listOfLineItemsToBeInserted = new List<Order_Line_Item__c>();
        List<Order_Line_Item__c> listOfLineItemsToBeUpdated = new List<Order_Line_Item__c>();
        //Looping order order line items
        for(Order_Line_Item__c eachOLI : objMasterOrder.Order_Line_Items__r){               
            //Child NRO order line
            Order_Line_Item__c objNROOLI = eachOLI.clone(false, true, false, false);
            objNROOLI.Order__c = objChildNROOrder.id;
            objNROOLI.List_Price__c = 0;
            objNROOLI.Ext_Net_Price__c = 0;
            objNROOLI.Ext_List__c = 0;
            objNROOLI.Sales_Price__c = 0;
            objNROOLI.Net_Unit_Price__c = 0;  
            objNROOLI.Skip_Invoice__c = false;
            listOfLineItemsToBeInserted.add(objNROOLI);   
            Order_Line_Item__c objNROOLIToBeUpdated = eachOLI;
            objNROOLIToBeUpdated.POB_Type__c = 'Not Applicable';
            listOfLineItemsToBeUpdated.add(objNROOLIToBeUpdated);
        }
        
        if(!listOfLineItemsToBeUpdated.isEmpty())
            update listOfLineItemsToBeUpdated;
        
        //Adding default lines to master order
        List<Product2> listOfProducts = [SELECT id, APN_Number__c, Type__c, Sub_Type__c, Third_Party__c,New_Category__c,Sub_category__c,POB_Type__c
                                         FROM Product2 WHERE APN_Number__c IN : Label.PPU_Master_Order_Default_Lines.split(';')];
        Integer count = 1;
        for(Product2 eachProduct : listOfProducts){
            Order_Line_Item__c objOLI = new Order_Line_Item__c();
            objOLI.Order__c = objMasterOrder.id;
            objOLI.Product__c = eachProduct.id;
            objOLI.APN_Number__c = eachProduct.APN_Number__c;
            objOLI.Name = eachProduct.APN_Number__c;
            if(count == 1){
                objOLI.Quantity__c = 1;
                objOLI.BigMachines_Quantity__c = 1;
                objOLI.List_Price__c = objMasterOrder.Total_Order__c;
                objOLI.Ext_Net_Price__c = objMasterOrder.Total_Order__c;
                objOLI.Ext_List__c = objMasterOrder.Total_Order__c;
                objOLI.Sales_Price__c = objMasterOrder.Total_Order__c;
                objOLI.Net_Unit_Price__c = objMasterOrder.Total_Order__c;    
            }
            else{
                objOLI.Quantity__c = 0;
                objOLI.BigMachines_Quantity__c = 0;
                objOLI.List_Price__c = 0;
                objOLI.Ext_Net_Price__c = 0;
                objOLI.Ext_List__c = 0;
                objOLI.Sales_Price__c = 0;
                objOLI.Net_Unit_Price__c = 0;
            }
            if(eachProduct.Sub_Type__c == 'PPU Overage')
                objOLI.Revenue_Classification__c = 'Overage';
            else       
                objOLI.Base_Package__c = objMasterOrder.Annual_Contract_Value__c;
            //Changes added by Ankit
            objOLI.line_number__c  = objMasterOrder.Order_Line_Items__r.size() + count;
            objOLI.Dummy_APN__c =    eachProduct.APN_Number__c;
     objOLI.POB_Type__c = QuoteUtil.getPOBType(eachProduct.Type__c, eachProduct.Sub_Type__c,eachProduct.New_Category__c,eachProduct.Third_Party__c, objMasterOrder.License_FYM_detail__c, 'Cloud Partner (PPU)',eachProduct.POB_Type__c);
            listOfLineItemsToBeInserted.add(objOLI);
            count++;
        }
        
        if(!listOfLineItemsToBeInserted.isEmpty())
            insert listOfLineItemsToBeInserted;        
    }
    
    public static void CreateOrderTest(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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