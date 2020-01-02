public class OrderLineItemPremSubscription {

    public Boolean addPureSuccessBundleToAmend = false;
    public final String OFFERING_FEATURE_SMALL_MED = 'PureConnect Small Medium';

    public OrderLineItemPremSubscription() {

    }

    public void insertOrderLineItemsSubscription(BigMachines__Quote__c objQuote , Order__c objOrder, Opportunity objOpportunity, Boolean blnIsSeperatePO) {

    Boolean blnIncludeLineItem ;
    String genesysCareProductId;
    String genesysCareProductName;
    String genesysCareProductDescription;
    Date tempStart;
    Date tempEnd;
    integer tempTerm;
    Set<String> genesysPS = new Set<String>();
    Set<String> genesysCareFlexCareProductIds = new Set<String>();
    Set<String> genesysFeeProductIds = new Set<String>();
    List<Order_Line_Item__c> list_OrderLineItems = new list<Order_Line_Item__c>();
    Order_Line_Item__c genesysCareLineY1, genesysCareLineY2;
    Order_Line_Item__c thirdCareLine;
    List<String> list_Types = Label.Types_Required_Add_Products.split(';');
    Decimal decBasePackagePriceY1 = 0;
    Decimal decBasePackagePriceY2 = 0;
    Decimal decPureSuccessPriceY1 = 0;
    Decimal decPureSuccessPriceY2 = 0;
    Decimal decNetQuantityY1 = 0, decNetQuantityY2 = 0;
    Decimal decNetListPriceY1 = 0, decNetListPriceY2 = 0;
    Decimal decNetSellPriceY1 = 0, decNetSellPriceY2 = 0;
    Decimal decNetQuantityTP = 0;
    Decimal decNetListPriceTP = 0;
    Decimal decNetSellPriceTP = 0;
    Boolean hasPureSuccess = false;
    Boolean hasStandardSupport = false;
    Boolean hasBusinessCare = false;

    Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice = new Map<String, BigMachines__Quote_Product__c>();

    List<BigMachines__Quote_Product__c> quoteProducts = getQuoteProductLines(objQuote, blnIsSeperatePO);

///SET FLAGS and some prices
        for (BigMachines__Quote_Product__c quoteProduct : quoteProducts) {
            if ( quoteProduct.BigMachines__Product__c != null && quoteProduct.BigMachines__Product__r.Description != null &&
                (quoteProduct.BigMachines__Product__r.Name.contains('PureSuccess') || quoteProduct.BigMachines__Product__r.Description.contains('PureSuccess')) )
                hasPureSuccess = true;

            ///MS added for amendnents
            else if ( objQuote.Amendment_For__c != null && objQuote.Amendment_For__r.PureSuccess_Offer__c != null && 
                    objQuote.Amendment_For__r.PureSuccess_Offer__c.contains('PureSuccess') )
                hasPureSuccess = true;

            if ( quoteProduct.BigMachines__Product__c != null && quoteProduct.BigMachines__Product__r.Type__c != null &&
            quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' ) { 
                if (quoteProduct.BigMachines__Product__r.Description.contains('Standard Support')) 
                hasStandardSupport = true;
                else if (quoteProduct.BigMachines__Product__r.Description.contains('Business Care'))
                hasBusinessCare = true;
            }

            if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package') {
                if (quoteProduct.Bundle_Line__c == NULL) {
                    decBasePackagePriceY1 = decNullTest(quoteProduct.Ext_Net_Price_1__c);
                    decBasePackagePriceY2 = decNullTest(quoteProduct.Ext_Net_Price_2__c);
                }
            }
            if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess') {
                hasPureSuccess = true;
                if (quoteProduct.Bundle_Line__c == NULL) {
                    decPureSuccessPriceY1 = decNullTest(quoteProduct.Ext_Net_Price_1__c);
                    decPureSuccessPriceY2 = decNullTest(quoteProduct.Ext_Net_Price_2__c);
                }
            }
        }
//  END FLAGS

  //  Decimal decLicenseAlaCartePercentage = hasPureSuccess || hasStandardSupport || hasBusinessCare ? QuoteUtil.getPackagePricingPercentage(objQuote.Offering_Type__c, 'A la Carte', 'License') : 100.0;

    Decimal decTotalOfLicenseAlaCarteY1 = 0, decTotalOfLicenseAlaCarteY2 = 0;
    //MS added for Standard Support - at of 9/5/2019 applies to SMCC only
 
    String dummyAPN = getDummyAPN(objQuote, hasStandardSupport);
    
    Order_Line_Item__c objOLIGCY1, objOLIGCY2;
    Boolean blnIsBusinessCareLineOnQuote = false;

    ///SKIPING: Bundle exploded lines, EQUIP, Partner PureSuccess
    for (BigMachines__Quote_Product__c quoteProduct : quoteProducts) {
        Boolean blnIsBusinessCare = false;
        //Subscription
        if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess') {
            mapOfPackageVsPrice.put(quoteProduct.Bundle__r.Type__c, quoteProduct);
            
            if (quoteProduct.Bundle_Line__c != NULL || quoteProduct.Bundle__r.Type__c == 'EQUIP' || quoteProduct.Bundle__r.Type__c == 'Partner PureSuccess')
                continue;
        }

        if (quoteProduct.BigMachines__Product__r.PS_Contract__c != null && quoteProduct.BigMachines__Product__r.PS_Contract__c)
            genesysPS.add(quoteProduct.BigMachines__Product__c);                
   
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care') {
            genesysCareProductId = quoteProduct.BigMachines__Product__c;
            genesysCareProductName = quoteProduct.BigMachines__Product__r.Name;
            genesysCareProductDescription = quoteProduct.BigMachines__Product__r.Description;
            blnIsBusinessCare = true;
        }
        else if (quoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
            genesysCareFlexCareProductIds.add(quoteProduct.BigMachines__Product__c);        
       
        else if (quoteProduct.BigMachines__Product__r.Type__c == 'Fees') {
            genesysFeeProductIds.add(quoteProduct.BigMachines__Product__c);
            continue;
        }

        Order_Line_Item__c objOrderLineItem = new Order_Line_Item__c();
 
 ///INITIALIZE
        objOrderLineItem.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
        objOrderLineItem.Unit_of_Measure__c = quoteProduct.Unit_of_Measure__c;
        objOrderLineItem.Order__c = objOrder.id;
        objOrderLineItem.Flavor__c = quoteProduct.Flavor__c;
        objOrderLineItem.Tokens__c = quoteProduct.Tokens__c;
  
        ///MS 5/30/19 removed from IF condition: (&& quoteProduct.Bundle_Line__c == null) to re-number bundle line items 
        if (objQuote.Amendment_For__c != null && quoteProduct.Subscription_Product__r.Quantity__c != null
            && quoteProduct.Quantity__c != null && !blnIsBusinessCare) {
                objOrderLineItem.Quantity__c = quoteProduct.Quantity__c - quoteProduct.Subscription_Product__r.Quantity__c;                   
                //MS 5/30/19 added
                if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && objOrderLineItem.Quantity__c > 0)
                    addPureSuccessBundleToAmend = true; 
    
                if (objOrderLineItem.Quantity__c == 0)
                    continue;
            } else
                objOrderLineItem.Quantity__c = quoteProduct.Quantity__c;

///INITIALIZE
        if(quoteProduct.Bundle_Line__c == null){
            //Naresh Kumar  06/28/2018  Populating POB Type
          objOrderLineItem.POB_Type__c = QuoteUtil.getPOBType(quoteProduct.BigMachines__Product__r.Type__c,
                                                            quoteProduct.BigMachines__Product__r.Sub_Type__c,
                                                            quoteProduct.BigMachines__Product__r.New_category__c,
                                                            quoteProduct.BigMachines__Product__r.Third_Party__c,
                                                            objOrder.License_FYM_detail__c,
                                                            objQuote.Offering_Type__c,quoteProduct.BigMachines__Product__r.POB_Type__c);
        }
        else
            objOrderLineItem.POB_Type__c = 'Not Applicable';

        objOrderLineItem.Sold_To_Name__c = quoteProduct.Sold_To_Name__c;
        objOrderLineItem.End_User_Name__c = quoteProduct.End_User_Name__c;
        objOrderLineItem.Quote_Product__c = quoteProduct.id;
        objOrderLineItem.Product_txt__c = quoteProduct.Product__c;
        objOrderLineItem.Name = quoteProduct.BigMachines__Product__r.APN_Number__c; //BURST??

        objOrderLineItem.CurrencyIsoCode =  objQuote.CurrencyIsoCode; // quoteProduct.CurrencyIsoCode;
        objOrderLineItem.APN_Number__c = quoteProduct.BigMachines__Product__r.APN_Number__c;             
        objOrderLineItem.Product__c = quoteProduct.BigMachines__Product__c;
        objOrderLineItem.description__c = quoteProduct.BigMachines__Description__c;
        objOrderLineItem.Product_Specific_Discount__c = quoteProduct.Product_Specific_Discount__c;

        objOrderLineItem.Fees_Applied__c = quoteProduct.Fees_Applied__c ;
        objOrderLineItem.Increase__c = quoteProduct.Increase__c;
        objOrderLineItem.Revised_Net_License_Value__c = quoteProduct.Revised_Net_License_Value__c;
        objOrderLineItem.Extended_End_of_Support__c = quoteProduct.Extended_End_of_Support__c;
        
        objOrderLineItem.Contract_Line_Update_Status__c = quoteProduct.Contract_Line_Update_Status__c;
        objOrderLineItem.Current_Qty__c = quoteProduct.Current_Qty__c;
        objOrderLineItem.Original_Qty__c = quoteProduct.Original_Qty__c;
        objOrderLineItem.Service_Contract_Line_ID__c = quoteProduct.Service_Contract_Line_ID__c;

        objOrderLineItem.Third_Party_Partners__c = quoteProduct.BigMachines__Product__r.Third_Party_Custom__c;
        objOrderLineItem.List_Price__c = decNullTest(quoteProduct.List_Price_1__c);
        objOrderLineItem.Net_Unit_Price__c = decNullTest(quoteProduct.Net_Unit_Price__c);
        objOrderLineItem.Ext_Net_Price__c = decNullTest(quoteProduct.Ext_Net_Price_1__c);
        objOrderLineItem.Ext_List__c = decNullTest(quoteProduct.Ext_List_Price_1__c);
        objOrderLineItem.Sales_Price__c = decNullTest(quoteProduct.Net_Unit_Price_1__c);


        if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != NULL)
            objOrderLineItem.Package_Type__c = 'Base Package';

///ALLOCATIONS??
        if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess'
            || (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == NULL && !objQuote.Generate_Revpro_Order__c)) {
                objOrderLineItem.List_Price__c = 0;
                objOrderLineItem.Net_Unit_Price__c = 0;
                objOrderLineItem.Ext_Net_Price__c = 0;
                objOrderLineItem.Ext_List__c = 0;
                objOrderLineItem.Sales_price__c = 0;

                if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' ) {
                    objOrderLineItem.Base_Package__c = decBasePackagePriceY1;                  
                    objOrderLineItem.List_Price__c = decNullTest(quoteProduct.List_Price_1__c);

                } else if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess') {
                    objOrderLineItem.Base_Package__c = decPureSuccessPriceY1;
                    objOrderLineItem.List_Price__c = decPureSuccessPriceY1;
                }
        } else if (objQuote.Generate_Revpro_Order__c && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) {
                objOrderLineItem.List_Price__c = 0;
                objOrderLineItem.Net_Unit_Price__c = 0;
                objOrderLineItem.Ext_Net_Price__c = 0;
                objOrderLineItem.Ext_List__c = 0;
                objOrderLineItem.Sales_price__c = 0;
        } else if (quoteProduct.Bundle_Line__c == null)
                objOrderLineItem.Base_Package__c = objOrderLineItem.Ext_Net_Price__c;

           //License A la Carte items OR
        //MS - Standard Support price allocation
        if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case' || 
             ( quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) ) {

            decTotalOfLicenseAlaCarteY1 += objOrderLineItem.Ext_Net_Price__c;

             if (quoteProduct.BigMachines__Product__r.Type__c != null && quoteProduct.BigMachines__Product__r.Type__c == 'Migration Credit') {
                 objOrderLineItem.Quantity__c = 1;
                 objOrderLineItem.BigMachines_Quantity__c =1;
                 objOrderLineItem.List_Price__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Ext_List__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Ext_Net_Price__c = objOrderLineItem.Net_Unit_Price__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Sales_price__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Base_Package__c =  objOrderLineItem.List_Price__c;
                 objOrderLineItem.Annualized_Maintenance_Due__c =0;
               
                 objOrderLineItem.Dummy_APN__c = dummyAPN;   

                 //MS - 9/15/19 year and dates on Migration - Year1 only, no Year2 for one-time credit                
            }
            /* REMOVED
            else
                  objOrderLineItem.List_Price__c = (objOrderLineItem.List_Price__c * decLicenseAlaCartePercentage) / 100;
            */

            Decimal decTotalLineDiscount = decNullTest(quoteProduct.Total_Discount__c);

            objOrderLineItem.Net_Unit_Price__c = objOrderLineItem.List_Price__c - ((objOrderLineItem.List_Price__c * decTotalLineDiscount) / 100);
            objOrderLineItem.Quantity__c = objOrderLineItem.Quantity__c == null ? 0 : objOrderLineItem.Quantity__c;
            objOrderLineItem.Ext_List__c = objOrderLineItem.List_Price__c * objOrderLineItem.Quantity__c;
            objOrderLineItem.Ext_Net_Price__c = objOrderLineItem.Net_Unit_Price__c * objOrderLineItem.Quantity__c;
            objOrderLineItem.Sales_price__c = objOrderLineItem.Net_Unit_Price__c;
            
            if ( quoteProduct.Bundle__r.Group_Type__c != 'Base Package' )
                 objOrderLineItem.Package_Type__c = 'License A la Carte';

         }

        objOrderLineItem.BigMachines_Quantity__c = quoteProduct.BigMachines__Quantity__c;
        objOrderLineItem.Total_Discount__c = quoteProduct.Total_Discount__c;
        
        if (objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && objQuote.Quote_Business_Type__c != 'Renewal') {
            objOrderLineItem.Maintenance_No_of_Months__c = objQuote.Order_Numb_of_Maint_Months__c;
        }
        else {
            // 1/21/2015 : Copy additional information for PS product
            if (String.isNotBlank(quoteProduct.BigMachines__Product__r.Type__c)) {
                for (String strType : list_Types) {
                    if (quoteProduct.BigMachines__Product__r.Type__c == strType) {
                        objOrderLineItem.Project_ID__c = quoteProduct.Project_ID__c;
                        objOrderLineItem.Project_Name__c = quoteProduct.Project_Name__c;
                        objOrderLineItem.Third_Party_Partners__c = quoteProduct.Third_Party_Partners__c;
                        objOrderLineItem.Third_Party_Applications__c = quoteProduct.Third_Party_Applications__c;
                        objOrderLineItem.Third_Party_Partner_Fee__c = quoteProduct.Third_Party_Partner_Fee__c;
                        objOrderLineItem.Solution_Names_Covered__c = quoteProduct.Solution_Names_Covered__c;
                        objOrderLineItem.Application_Support_Cost_Base__c = quoteProduct.Application_Support_Cost_Base__c;
                    }
                }
            }
        }
        
        //MS 5/30/19 - Amendment Quantity re-set
         if ( objQuote.Amendment_For__c != null &&
              (objQuote.Offering_Type__c != null && (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription')) )  {                   
                 objOrderLineItem.BigMachines_Quantity__c = objOrderLineItem.Quantity__c;
        }

        // Calculates the Maintenace due and Anuualized at Order level for Licensing Deal       
        if (objQuote.PO_for_FYM__c != null && objQuote.PO_for_FYM__c != 'Declined Maintenance') {
            
            if (objOpportunity.RecordType.DeveloperName != null && objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME &&
                objQuote.Quote_Business_Type__c != 'Renewal' ) {
                    if (objQuote.Current_Maint_Rate__c != null) {
                        objOrderLineItem.Maintenance_Due__c = quoteProduct.BigMachines__Total_Price__c * (objQuote.Current_Maint_Rate__c / 100);
                    }
                    if (objOrderLineItem.Maintenance_Due__c != null && objOrderLineItem.Maintenance_Due__c != 0 && objQuote.Order_Numb_of_Maint_Months__c != 0 && objQuote.Order_Numb_of_Maint_Months__c != null) {
                        objOrderLineItem.Annualized_Maintenance_Due__c = (objOrderLineItem.Maintenance_Due__c / objQuote.Order_Numb_of_Maint_Months__c) * 12;
                    }
                }
        } else {
            objOrderLineItem.Annualized_Maintenance_Due__c = 0;
            objOrderLineItem.Maintenance_Due__c = 0;
        }
        
        if (objOpportunity.RecordType.DeveloperName != null && (objQuote.Quote_Business_Type__c == 'Renewal' || 
               objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.MAINTENANCE)) {
            
                objOrderLineItem.Maintenance_Due__c = quoteProduct.Maintenance_Due__c;
                // Storing Annualized Maintenance from last period applicable on the quote
                if (quoteProduct.Annualized_Maintenance_Last_Period__c != null)
                    objOrderLineItem.Annualized_Maintenance_Due__c = quoteProduct.Annualized_Maintenance_Last_Period__c; 
                else {
                    if (quoteProduct.Maintenance_Due__c != null && quoteProduct.Maintenance_Due__c != 0 &&
                        quoteProduct.Maintenance_Start_Date__c != null && quoteProduct.Maintenance_End_Date__c != null) {
                            
                            tempStart = OrderUtil.adjustDatetoStartofMonth(quoteProduct.Maintenance_Start_Date__c);
                            tempEnd = OrderUtil.adjustDatetoStartofMonth(quoteProduct.Maintenance_End_Date__c);
                            tempTerm = (12 * (tempEnd.year() - tempStart.year())) + (tempEnd.month() - tempStart.month());
                            objOrderLineItem.Maintenance_No_of_Months__c = tempTerm;
                            if (tempTerm != 0)
                                objOrderLineItem.Annualized_Maintenance_Due__c = (quoteProduct.Maintenance_Due__c / tempTerm) * 12;
                            
                    }
                }
        }            

        //Populating Maint start and end date from Order      
        if (objOrder.Numb_of_Maint_Months__c != null) {
            List<Date> listOfStartAndEndDates = new List<Date>();
            if ( objQuote.Amendment_For__c == null || objQuote.Amendment_For__r.Order__c == null )
                listOfStartAndEndDates = QuoteUtil.calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 1);
            else {
                listOfStartAndEndDates = QuoteUtil.calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Order__c, 1);
                ///MS 5/30/19 AMENDMENT - DO NOT CREATE ORDER LINE ITEM IF START DATE = END DATE
                if (listOfStartAndEndDates[0] != null && listOfStartAndEndDates[1] != null && listOfStartAndEndDates[0] == listOfStartAndEndDates[1] ) 
                   continue;
            }

            objOrderLineItem.Maintenance_Start_Date__c = listOfStartAndEndDates[0];
            objOrderLineItem.Maintenance_End_Date__c = listOfStartAndEndDates[1];
        }
             
            objOrderLineItem.Year__c = 1;
            if (blnIsBusinessCare)
                objOLIGCY1 = objOrderLineItem;

            list_OrderLineItems.add(objOrderLineItem);

            //Hardware or Third party should not be for year 2
            //MS - add Migration Credit to the exclusions
           // if (!quoteProduct.Hardware_or_Third_Party__c && quoteProduct.Bundle__r.Group_Type__c != 'PureSuccess'
            //    && quoteProduct.Bundle__r.Group_Type__c != 'A la Carte') {

            if (!quoteProduct.Hardware_or_Third_Party__c && quoteProduct.Bundle__r.Group_Type__c != 'PureSuccess'
                    && quoteProduct.Bundle__r.Group_Type__c != 'A la Carte' && quoteProduct.BigMachines__Product__r.Type__c != 'Migration Credit') {
                    //Year 2 Line

                    Order_Line_Item__c objOrderLineY2 = objOrderLineItem.clone(false, true, false, false);
                    objOrderLineY2.Tokens__c = null;

                    if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != NULL)
                        objOrderLineY2.Package_Type__c = 'Base Package';
                     else if ( quoteProduct.Bundle__r.Group_Type__c != 'Base Package' )
                        objOrderLineY2.Package_Type__c = 'License A la Carte';

                    objOrderLineY2.Year__c = 2;

                    //ala carte or not base package lines
                    if (quoteProduct.Bundle__r.Group_Type__c != 'Base Package' || quoteProduct.Bundle_Line__c != null) {

                        objOrderLineY2.List_Price__c = quoteProduct.List_Price_2__c == null ? 0 : quoteProduct.List_Price_2__c;
                        objOrderLineY2.Net_Unit_Price__c = quoteProduct.Net_Unit_Price__c == null ? 0 : quoteProduct.Net_Unit_Price_2__c;
                        objOrderLineY2.Ext_Net_Price__c = quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c;
                        objOrderLineY2.Ext_List__c = quoteProduct.Ext_List_Price_2__c == null ? 0 : quoteProduct.Ext_List_Price_2__c;
                        objOrderLineY2.Sales_price__c = quoteProduct.Net_Unit_Price_2__c == null ? 0 : quoteProduct.Net_Unit_Price_2__c;
                    }
                      // base package lines
                    if (objQuote.Generate_Revpro_Order__c && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) {
                        objOrderLineY2.List_Price__c = 0;
                        objOrderLineY2.Net_Unit_Price__c = 0;
                        objOrderLineY2.Ext_Net_Price__c = 0;
                        objOrderLineY2.Ext_List__c = 0;
                        objOrderLineY2.Sales_price__c = 0;
                    }
                     //base package header
                    if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null) {
                        objOrderLineY2.Base_Package__c = decBasePackagePriceY2;
                        objOrderLineY2.List_Price__c = quoteProduct.List_Price_2__c == null ? 0 : quoteProduct.List_Price_2__c;

                    } else if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess' && quoteProduct.Bundle_Line__c == null) {
                        objOrderLineY2.Base_Package__c = decPureSuccessPriceY2;

                    } else if (quoteProduct.Bundle_Line__c == null) {
                        objOrderLineY2.Base_Package__c = (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
                    }

                    if (blnIsBusinessCare)
                        objOLIGCY2 = objOrderLineY2;
                    
                    //License A la Carte items OR
                    //MS - Standard Support 
                    // if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case') {
                    if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case' || 
                         ( hasStandardSupport && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) ) {

                        decTotalOfLicenseAlaCarteY2 += (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
                       // objOrderLineY2.List_Price__c = (objOrderLineY2.List_Price__c * decLicenseAlaCartePercentage) / 100;
                        objOrderLineY2.Net_Unit_Price__c = objOrderLineY2.List_Price__c;

                        Decimal decTotalLineDiscount = quoteProduct.Total_Discount__c == null ? 0 : quoteProduct.Total_Discount__c;

                        objOrderLineY2.Net_Unit_Price__c -= (objOrderLineY2.List_Price__c * decTotalLineDiscount) / 100;
                        objOrderLineY2.Ext_List__c = objOrderLineY2.List_Price__c * objOrderLineY2.Quantity__c;
                        objOrderLineY2.Ext_Net_Price__c = objOrderLineY2.Net_Unit_Price__c * objOrderLineY2.Quantity__c;
                        objOrderLineY2.Sales_price__c = objOrderLineY2.Net_Unit_Price__c;
                    }

                    //Populating Maint start and end date from Order
                    if (objOrder.Numb_of_Maint_Months__c != null) {                           
                        List<Date> listOfStartAndEndDates = new List<Date>();
                        if ( objQuote.Amendment_For__c == null || objQuote.Amendment_For__r.Order__c == null )
                            listOfStartAndEndDates = QuoteUtil.calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 2);
                        else 
                            listOfStartAndEndDates = QuoteUtil.calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Order__c, 2);

                        objOrderLineY2.Maintenance_Start_Date__c = listOfStartAndEndDates[0];
                        objOrderLineY2.Maintenance_End_Date__c = listOfStartAndEndDates[1];
                    }

                    //MS 8/7/19 - two years option
                    if ( objQuote.No_Of_Months__c != null && Integer.valueOf(objQuote.No_Of_Months__c) > 12 )
                        list_OrderLineItems.add(objOrderLineY2);

                    //Naresh Kumar  12/10/2018  Populating totals for third party care line
                    if (quoteProduct.BigMachines__Product__r.Third_Party_GC__c != null && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 0 && 
                         quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 255 && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                            && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE')) )   { 

                                if (objOrderLineItem.BigMachines_Quantity__c != null)
                                    decNetQuantityTP += objOrderLineItem.BigMachines_Quantity__c;
                                if (objOrderLineItem.List_Price__c != null && objOrderLineItem.Quantity__c != null)
                                    decNetListPriceTP += (objOrderLineItem.List_Price__c * objOrderLineItem.Quantity__c);
                                if (objOrderLineItem.Ext_Net_Price__c != null)
                                    decNetSellPriceTP += objOrderLineItem.Ext_Net_Price__c;     
                            }

                    //Naresh Kumar  08/06/2018  Populating totals for Care Line
                    else if (quoteProduct.BigMachines__Product__r.Type__c == 'Product') {
                        if(objOrderLineItem.BigMachines_Quantity__c != null)
                            decNetQuantityY1 += objOrderLineItem.BigMachines_Quantity__c;
                        if(objOrderLineY2.BigMachines_Quantity__c != null)
                            decNetQuantityY2 += objOrderLineY2.BigMachines_Quantity__c;
                        
                        if(objOrderLineItem.Ext_List__c != null)
                            decNetListPriceY1 += objOrderLineItem.Ext_List__c;
                        if(objOrderLineY2.Ext_List__c != null)
                            decNetListPriceY2 += objOrderLineY2.Ext_List__c;
                        
                        if(objOrderLineItem.Ext_Net_Price__c != null)
                            decNetSellPriceY1 += objOrderLineItem.Ext_Net_Price__c; 
                        if(objOrderLineY2.Ext_Net_Price__c != null)
                            decNetSellPriceY2 += objOrderLineY2.Ext_Net_Price__c;                         
                    }

                    if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' && 
                         (quoteProduct.BigMachines__Product__r.Third_Party__c == null || !quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                                genesysCareLineY1 = objOrderLineItem;
                                genesysCareLineY2 = objOrderLineY2;                
                    }
                    else if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                                && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE')))  {
                                    thirdCareLine = objOrderLineItem;        
                    }

                    //Naresh Kumar  08/07/2018 Populating Dummy APNS for A la carte items 
                    //MS - Standard Support - add for Base Package 
                    //if(quoteProduct.Bundle__c == null && !listOfDummyAPNs.isEmpty())  {

                    if( quoteProduct.Bundle__c == null || 
                       (hasStandardSupport && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null) ) {

                        objOrderLineItem.Dummy_APN__c = dummyAPN; 
                        objOrderLineY2.Dummy_APN__c = dummyAPN;
                        
                        ///MS Standard Support 
                        if ( hasStandardSupport ) {
                            if ( quoteProduct.Bundle__c == null ) {
                                // Ala Carte lines only 
                                objOrderLineItem.Base_Package__c = objOrderLineItem.Ext_Net_Price__c;
                                objOrderLineY2.Base_Package__c = objOrderLineY2.Ext_Net_Price__c;
                            }
                        }
                    }
        
                } else if (quoteProduct.Hardware_or_Third_Party__c) {
                    objOrderLineItem.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                    objOrderLineItem.Maintenance_End_Date__c = objOrder.Maintenance_End__c;
                }               
        //}
    } ///END loop FOR quote products, skipping bundle lines, Equip, partner success

    //Naresh Kumar  08/06/2018  Populating totals for Care Line
    if (genesysCareLineY1 != null) {
        genesysCareLineY1.Current_Qty__c = decNetQuantityY1;
        genesysCareLineY1.Revised_Net_License_Value__c = decNetSellPriceY1;
        genesysCareLineY1.Original_Net_License_Value__c = decNetListPriceY1;
    }
    if (genesysCareLineY2 != null) {
        genesysCareLineY2.Current_Qty__c = decNetQuantityY2;
        genesysCareLineY2.Revised_Net_License_Value__c = decNetSellPriceY2;
        genesysCareLineY2.Original_Net_License_Value__c = decNetListPriceY2;
    }
    //Naresh Kumar  08/06/2018  Populating totals for Care Line
    if (thirdCareLine != null) {
        thirdCareLine.Current_Qty__c = decNetQuantityTP;
        thirdCareLine.Revised_Net_License_Value__c = decNetSellPriceTP;
        thirdCareLine.Original_Net_License_Value__c = decNetListPriceTP;            
    } 

       /* REMOVED ??? */
        if (!objQuote.Generate_Revpro_Order__c && !mapOfPackageVsPrice.keySet().isEmpty()) {

            createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);

            //Adding Equip lines if Guide is there.
            if (mapOfPackageVsPrice.keySet().contains('GUIDE') || mapOfPackageVsPrice.keySet().contains('DRIVE')) {
                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objQuote.id);
                objQP.Unit_of_Measure__c = null;
                objQP.CurrencyIsoCode = objQuote.CurrencyIsoCode;
                objQP.Current_Qty__c = 1;
                objQP.Original_Qty__c = 1;
                mapOfPackageVsPrice.clear();
                mapOfPackageVsPrice.put('EQUIP', objQP);
                createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
            }
        }

        ///MS 5/30/19 added for Amendment Orders
        if ( !objQuote.Generate_Revpro_Order__c && addPureSuccessBundleToAmend ) {
                // create quote product PureSuccess Bundle
                BigMachines__Quote_Product__c objPSbundle = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objQuote.id);
                objPSbundle.CurrencyIsoCode = objQuote.CurrencyIsoCode;
                objPSbundle.Current_Qty__c = 1;
                objPSbundle.Original_Qty__c = 1;
                mapOfPackageVsPrice.clear();
                mapOfPackageVsPrice.put('Partner PureSuccess', objPSbundle);
                createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
        }
    /* ??? */

    //Adding License A la Carte PureSuceess lines

    /* REMOVED ??? */
    if (!objQuote.Generate_Revpro_Order__c && decTotalOfLicenseAlaCarteY1 > 0 ) {
        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objQuote.id);
        objQP.Unit_of_Measure__c = null;
        objQP.CurrencyIsoCode = objQuote.CurrencyIsoCode;
        objQP.Current_Qty__c = 1;
        objQP.Original_Qty__c = 1;
        mapOfPackageVsPrice.clear();
  
        //Genesys Care Scenario
        //MS - added quote Standard Support
       
        if ((objQuote.Show_Genesys_Care_Tab__c && objQuote.Order_Type__c != Label.Order_Type_Amend && objQuote.Order_Type__c != Label.Order_Type_Subscription) ||
             objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Standard Support' || hasStandardSupport || hasBusinessCare ) {
                 //mapOfPackageVsPrice.put('A LA CARTE-GC', objQP);
                 //Getting % of PureSuccess GC
                 Decimal decPureSuccessGCAlaCartePercentage = QuoteUtil.getPackagePricingPercentage(objQuote.Offering_Type__c, 'A la Carte', 'PureSuccess');
                 Decimal decGCAmountY1 = (decTotalOfLicenseAlaCarteY1 * decPureSuccessGCAlaCartePercentage) / 100;
                 Decimal decGCAmountY2 = (decTotalOfLicenseAlaCarteY2 * decPureSuccessGCAlaCartePercentage) / 100;
                 //Setting up base price for GC lines
                 //YEAR 1
                 objOLIGCY1.List_Price__c = decGCAmountY1;
                 objOLIGCY1.Quantity__c = 1;
                 objOLIGCY1.BigMachines_Quantity__c = 1;
                 objOLIGCY1.Net_Unit_Price__c = decGCAmountY1;
                 objOLIGCY1.Sales_Price__c = decGCAmountY1;
                 objOLIGCY1.Ext_List__c = decGCAmountY1;
                 objOLIGCY1.Ext_Net_Price__c = decGCAmountY1;
                 objOLIGCY1.Maintenance_Due__c = decGCAmountY1;

                // objOLIGCY1.Base_Package__c = 0;
                 //MS - 9/10/19 added for Standard Support lines
                 objOLIGCY1.Base_Package__c = hasStandardSupport ? decGCAmountY1 : 0;
                 //YEAR 2
                 objOLIGCY2.List_Price__c = decGCAmountY2;
                 objOLIGCY2.Quantity__c = 1;
                 objOLIGCY2.BigMachines_Quantity__c = 1;
                 objOLIGCY2.Net_Unit_Price__c = decGCAmountY2;
                 objOLIGCY2.Sales_Price__c = decGCAmountY2;
                 objOLIGCY2.Ext_List__c = decGCAmountY2;
                 objOLIGCY2.Ext_Net_Price__c = decGCAmountY2;
                 objOLIGCY2.Maintenance_Due__c = decGCAmountY2;
                 
                 //objOLIGCY2.Base_Package__c = 0;
                 //MS - 9/10/19 added for Standard Support lines
                 objOLIGCY2.Base_Package__c = hasStandardSupport ? decGCAmountY2 : 0;
             } else
                 mapOfPackageVsPrice.put('A LA CARTE', objQP);

             
        createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decTotalOfLicenseAlaCarteY1, decTotalOfLicenseAlaCarteY2);        
     }
    /* Poosibly remove above */

        Integer line_number = 1;
        for (Order_Line_Item__c eachOLI : list_OrderLineItems) {
            eachOLI.Line_Number__c = line_number;
            line_number++;
        }
        upsert list_OrderLineItems;
    } ///end insertOrderLineItemsSubscription

    public Static Map<Id, Product2> mapOfProducts;

    public void createPureSuccessLines(Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice,
                                            BigMachines__Quote__c objQuote, Order__c objOrder, List<Order_Line_Item__c> list_OrderLineItems) {

            createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, 0, 0);
    }

    public void createPureSuccessLines(Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice,BigMachines__Quote__c objQuote, Order__c objOrder,
                                    List<Order_Line_Item__c> list_OrderLineItems, Decimal decBasePackagePriceY1, Decimal decBasePackagePriceY2) {
   
        List<String> listOfProductIds = new List<String>();
        for (BasePackageLineConfiguration__c eachConfigDetails : BasePackageLineConfiguration__c.getAll().values()) {
            listOfProductIds.add(eachConfigDetails.PS_Product2_Id__c);
            listOfProductIds.add(eachConfigDetails.GU_Product2_Id__c);
            listOfProductIds.add(eachConfigDetails.CC_Product2_Id__c);
        }

        //MS 6/26/19 - skip PureSuccess if Offering Feature is PureConnect Small Medium
       if ( objQuote.Offering_Feature__c != null && objQuote.Offering_Feature__c.contains(OFFERING_FEATURE_SMALL_MED) )
            return;

        mapOfProducts = new Map<Id, Product2>([SELECT APN_Number__c, Name, Type__c, Sub_Type__c, Third_Party__c FROM Product2 WHERE id IN : listOfProductIds]);

        Boolean oneyear = (objQuote.No_Of_Months__c != null && Integer.valueOf(objQuote.No_Of_Months__c) <= 12) ? true : false;

        //Looping over each PureSuccess package
        for (String eachPackage : mapOfPackageVsPrice.keySet()) {
            String offeringType = objQuote.Offering_Type__c;
            String packageName = (eachPackage == 'Partner PureSuccess' ? 'PARTNER' : eachPackage.toUpperCase());
            String key = offeringType + '-' + packageName;

            System.debug('NKC debug key [' + key + ']');
            BasePackageLineConfiguration__c configDetails = BasePackageLineConfiguration__c.getAll().get(key);
            if (configDetails == null)
                return;
            Decimal decPureSuccessPercentage = configDetails.PureSuccess__c == null ? 0 : configDetails.PureSuccess__c;
    
            Decimal decPackagePriceY1 = (decBasePackagePriceY1 * decPureSuccessPercentage) / 100;
            Decimal decPackagePriceY2 = (decBasePackagePriceY2 * decPureSuccessPercentage) / 100;
            BigMachines__Quote_Product__c packageQP = mapOfPackageVsPrice.get(eachPackage);
            //We need only Y1 lines for GUIDE AND DRIVE
            Boolean blnSkipY2 = false;

            if ( packageName != 'PARTNER' && packageName != 'EQUIP' && packageName != 'A LA CARTE'  && packageName != 'A LA CARTE-GC') {
                decPackagePriceY1 = packageQP.Bundle_Line__r.Ext_Net_Price_1__c;
                decPackagePriceY2 = packageQP.Bundle_Line__r.Ext_Net_Price_2__c;
                blnSkipY2 = true;
            }

            //MS One year option
            if ( oneyear ) blnSkipY2 = true;

            if (decPackagePriceY1 == null)
                decPackagePriceY1 = 0;
            if (decPackagePriceY2 == null)
                decPackagePriceY2 = 0;
            List<Date> listOfStartAndEndDatesY1;
            List<Date> listOfStartAndEndDatesY2;
            //Populating Maint start and end date from Order
            if (objOrder.Numb_of_Maint_Months__c != null) {
                ///MS -5/30/19 changes start
                if (objQuote.Offering_Type__c != null && (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') ) {

                    if ( objQuote.Amendment_For__c == null || objQuote.Amendment_For__r.Order__c == null ) {
                        listOfStartAndEndDatesY1 = QuoteUtil.calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 1);
                        listOfStartAndEndDatesY2 = QuoteUtil.calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 2);
                    }
                    else { /// AMEND
                        listOfStartAndEndDatesY1 = QuoteUtil.calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Order__c, 1);
                        listOfStartAndEndDatesY2 = QuoteUtil.calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Order__c, 2);
                    }
                }
            else { ///MS - 5/30/19 changes end
                listOfStartAndEndDatesY1 = OrderUtil.calculateSubscriptionOrderLineDates(objOrder.Maintenance_Start__c,
                                                                                    objOrder.Maintenance_End__c, Integer.valueOf(objOrder.Numb_of_Maint_Months__c), 1);
                listOfStartAndEndDatesY2 = OrderUtil.calculateSubscriptionOrderLineDates(objOrder.Maintenance_Start__c,
                                                                                    objOrder.Maintenance_End__c, Integer.valueOf(objOrder.Numb_of_Maint_Months__c), 2);
            }
        }   
        Double dbTotalPrice1 = 0, dbTotalPrice2 = 0;
        if (packageName == 'PARTNER' || packageName == 'EQUIP' || packageName == 'A LA CARTE') {
            //Looping over all order lines and populating total ext net price for rounding purpose
            //Totals should only include base package line items
            for (Order_Line_Item__c eachOLI : list_OrderLineItems) {
                if (((packageName == 'PARTNER' || packageName == 'EQUIP') && eachOLI.Package_Type__c == 'Base Package')
                    || (packageName == 'A LA CARTE' && eachOLI.Package_Type__c == 'License A la Carte')) {
                        if (eachOLI.Year__c == 1)
                            dbTotalPrice1 += eachOLI.Ext_Net_Price__c;
                        if (eachOLI.Year__c == 2)
                            dbTotalPrice2 += eachOLI.Ext_Net_Price__c;
                    }
            }
        }
        System.debug('NKC debug dbTotalPrice1 [' + dbTotalPrice1 + ']');
        System.debug('NKC debug dbTotalPrice2 [' + dbTotalPrice2 + ']');
        ////PS
        //Y1
        Double PSPercentage = (configDetails.PS__c == null ? 0 : configDetails.PS__c);
        Double PSPrice = decPackagePriceY1 * PSPercentage / 100;
        PSPrice = Decimal.valueOf(PSPrice).setScale(2);
        dbTotalPrice1 += PSPrice;
        Order_Line_Item__c newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
        newOLI.Product__c = configDetails.PS_Product2_Id__c;
        Product2 PSProduct = mapOfProducts.get(newOLI.Product__c);
        newOLI.APN_Number__c = PSProduct.APN_Number__c;
        newOLI.Year__c = 1;
        newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY1[0];
        newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY1[1];
        //if(packageName == 'A LA CARTE')
        newOLI.POB_Type__c = 'Not Applicable';
        //else
        //  newOLI.POB_Type__c = QuoteUtil.getPOBType(PSProduct.Type__c, PSProduct.Sub_Type__c, PSProduct.Third_Party__c, '', objQuote.Offering_Type__c);
        QuoteUtil.populatePureSuccessOLI(newOLI, PSPrice, packageQP, objQuote);
        list_OrderLineItems.add(newOLI);
        //Y2
        if (!blnSkipY2) {
            PSPrice = decPackagePriceY2 * PSPercentage / 100;
            PSPrice = Decimal.valueOf(PSPrice).setScale(2);
            dbTotalPrice2 += PSPrice;
            newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
            //if(packageName == 'A LA CARTE')
            newOLI.POB_Type__c = 'Not Applicable';
            //else
            //  newOLI.POB_Type__c = QuoteUtil.getPOBType(PSProduct.Type__c, PSProduct.Sub_Type__c, PSProduct.Third_Party__c, '', objQuote.Offering_Type__c);
            newOLI.Product__c = configDetails.PS_Product2_Id__c;
            newOLI.APN_Number__c = PSProduct.APN_Number__c;
            newOLI.Year__c = 2;
            newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY2[0];
            newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY2[1];
            QuoteUtil.populatePureSuccessOLI(newOLI, PSPrice, packageQP, objQuote);
            list_OrderLineItems.add(newOLI);
        }
/* REMOVED        
        ////GU
        //Y1
        Double GUPercentage = (configDetails.GU__c == null ? 0 : configDetails.GU__c);
        Double GUPrice = decPackagePriceY1 * GUPercentage / 100;
        GUPrice = Decimal.valueOf(GUPrice).setScale(2);
        dbTotalPrice1 += GUPrice;
        newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
        newOLI.Product__c = configDetails.GU_Product2_Id__c;
        Product2 GUProduct = mapOfProducts.get(newOLI.Product__c);
        //if(packageName == 'A LA CARTE')
        newOLI.POB_Type__c = 'Not Applicable';
        //else
        //  newOLI.POB_Type__c = QuoteUtil.getPOBType(GUProduct.Type__c, GUProduct.Sub_Type__c, GUProduct.Third_Party__c, '', objQuote.Offering_Type__c);
        newOLI.APN_Number__c = GUProduct.APN_Number__c;
        newOLI.Year__c = 1;
        newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY1[0];
        newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY1[1];
        QuoteUtil.populatePureSuccessOLI(newOLI, GUPrice, packageQP, objQuote);
        list_OrderLineItems.add(newOLI);
        //Y2
        if (!blnSkipY2) {
            GUPrice = decPackagePriceY2 * GUPercentage / 100;
            GUPrice = Decimal.valueOf(GUPrice).setScale(2);
            dbTotalPrice2 += GUPrice;
            newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
            //if(packageName == 'A LA CARTE')
            newOLI.POB_Type__c = 'Not Applicable';
            //else
            //  newOLI.POB_Type__c = QuoteUtil.getPOBType(GUProduct.Type__c, GUProduct.Sub_Type__c, GUProduct.Third_Party__c, '', objQuote.Offering_Type__c);
            newOLI.Product__c = configDetails.GU_Product2_Id__c;
            newOLI.APN_Number__c = GUProduct.APN_Number__c;
            newOLI.Year__c = 2;
            newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY2[0];
            newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY2[1];
            QuoteUtil.populatePureSuccessOLI(newOLI, GUPrice, packageQP, objQuote);
            list_OrderLineItems.add(newOLI);
        }
        ////CC
            //Y1
            Double CCPercentage = (configDetails.CC__c == null ? 0 : configDetails.CC__c);
            Double CCPrice = decPackagePriceY1 * CCPercentage / 100;
            CCPrice = Decimal.valueOf(CCPrice).setScale(2);
            dbTotalPrice1 += CCPrice;
            System.debug('NKC debug dbTotalPrice1 [' + dbTotalPrice1 + ']');
            System.debug('NKC debug CCPrice [' + CCPrice + ']');
            System.debug('NKC debug decPackagePriceY1 [' + decPackagePriceY1 + ']');
            System.debug('NKC debug decBasePackagePriceY1 [' + decBasePackagePriceY1 + ']');
            if (packageName == 'PARTNER' || packageName == 'EQUIP' || packageName == 'A LA CARTE')
                CCPrice += (decBasePackagePriceY1 - dbTotalPrice1);
            else
                CCPrice += (decPackagePriceY1 - dbTotalPrice1);
            System.debug('NKC debug CCPrice [' + CCPrice + '] : packageName = ' + packageName);
            newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
            newOLI.Product__c = configDetails.CC_Product2_Id__c;
            Product2 CCProduct = mapOfProducts.get(newOLI.Product__c);
            //if(packageName == 'A LA CARTE')
            newOLI.POB_Type__c = 'Not Applicable';
            //else
            //  newOLI.POB_Type__c = QuoteUtil.getPOBType(CCProduct.Type__c, CCProduct.Sub_Type__c, CCProduct.Third_Party__c, '', objQuote.Offering_Type__c);
            newOLI.APN_Number__c = CCProduct.APN_Number__c;
            newOLI.Year__c = 1;
            newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY1[0];
            newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY1[1];
            QuoteUtil.populatePureSuccessOLI(newOLI, CCPrice, packageQP, objQuote);
            list_OrderLineItems.add(newOLI);
            //Y2
            if (!blnSkipY2) {
                CCPrice = decPackagePriceY2 * CCPercentage / 100;
                CCPrice = Decimal.valueOf(CCPrice).setScale(2);
                dbTotalPrice2 += CCPrice;
    
                if (packageName == 'PARTNER' || packageName == 'EQUIP' || packageName == 'A LA CARTE')
                    CCPrice += (decBasePackagePriceY2 - dbTotalPrice2);
                else
                    CCPrice += (decPackagePriceY2 - dbTotalPrice2);
                System.debug('NKC debug CCPrice [' + CCPrice + '] : packageName = ' + packageName);
                newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                //if(packageName == 'A LA CARTE')
                newOLI.POB_Type__c = 'Not Applicable';
                //else
                //    newOLI.POB_Type__c = QuoteUtil.getPOBType(CCProduct.Type__c, CCProduct.Sub_Type__c, CCProduct.Third_Party__c, '', objQuote.Offering_Type__c);
                newOLI.Product__c = configDetails.CC_Product2_Id__c;
                newOLI.APN_Number__c = CCProduct.APN_Number__c;
                newOLI.Year__c = 2;
                newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY2[0];
                newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY2[1];
                QuoteUtil.populatePureSuccessOLI(newOLI, CCPrice, packageQP, objQuote);
                list_OrderLineItems.add(newOLI);
            }
REMOVED END */
        }
        //upsert list_OrderLineItems;
     
    }

    public List<BigMachines__Quote_Product__c> getQuoteProductLines(BigMachines__Quote__c quote, Boolean blnIsSeperatePO) {

        String strQuoteProductQuery = 'SELECT Unit_of_Measure__c, Quantity__c, Product__c, Net_Unit_Price__c, Name, List_Price__c, Line_Number__c, Ext_Net_Price__c,';
        strQuoteProductQuery += 'Ext_List__c, CurrencyIsoCode, APN_Number__c, BigMachines__Description__c, BigMachines__Quantity__c, BigMachines__Quote__c, BigMachines__Sales_Price__c,';
        strQuoteProductQuery += 'BigMachines__Product__c, BigMachines__Product__r.Type__c, BigMachines__Product__r.PS_Contract__c, BigMachines__Product__r.Name, BigMachines__Product__r.Description,';
        strQuoteProductQuery += 'Maintenance_Start_Date__c, Year2_Maintenance_Due__c, Year3_Maintenance_Due__c, Year4_Maintenance_Due__c, Year5_Maintenance_Due__c,BigMachines__Product__r.Sub_Type__c,';
        strQuoteProductQuery += 'Maintenance_End_Date__c, Year2_CareRatePercent__c, Year3_CareRatePercent__c, Year4_CareRatePercent__c, Year5_CareRatePercent__c,BigMachines__Product__r.APN_Number__c,';
        strQuoteProductQuery += 'Maintenance_Due__c, Fees_Applied__c, Genesys_Care_Rate__c, Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c, Contract_Line_Update_Status__c,';
        strQuoteProductQuery += 'Original_Qty__c, Current_Qty__c, Total_Discount__c, Product_Specific_Discount__c, BigMachines__Total_Price__c, Sold_To_Name__c, End_User_Name__c,Tokens__c,BigMachines__Product__r.Third_Party_Custom__c,';
        strQuoteProductQuery += 'Service_Contract_Line_ID__c, Annualized_Maintenance_Last_Period__c, Flavor__c, Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,Hardware_or_Third_Party__c,BigMachines__Product__r.Third_Party__c,BigMachines__Product__r.Third_Party_GC__c,BigMachines__Product__r.New_category__c,BigMachines__Product__r.Sub_Category__c,BigMachines__Product__r.POB_Type__c,';
        strQuoteProductQuery += 'List_Price_1__c, List_Price_2__c, Ext_Net_Price_1__c, Ext_Net_Price_2__c, Ext_List_Price_1__c, Ext_List_Price_2__c, Net_Unit_Price_1__c, Net_Unit_Price_2__c,Discount_1__c, Discount_2__c, Partner_Discount_1__c, Partner_Discount_2__c,Disc__c,';
        strQuoteProductQuery += 'Bundle_Line__r.Ext_Net_Price__c, Bundle_Line__r.Ext_Net_Price_1__c, Bundle_Line__r.Ext_Net_Price_2__c,BigMachines__Quote__r.Subscription_Start_Date__c, BigMachines__Quote__r.Subscription_End_Date__c, Subscription_Product__r.Quantity__c,BigMachines__Quote__r.Quote_Billing_Plan_count__c,';
        strQuoteProductQuery += 'Application_Support_Cost_Base__c, Solution_Names_Covered__c, Third_Party_Partner_Fee__c, Bundle__r.Name, Bundle__r.Type__c, Bundle__r.Group_Type__c, Bundle_Line__c, Bundle_Line__r.BigMachines__Product__c, Subscription_Burst_Term__c ';
        strQuoteProductQuery += 'FROM BigMachines__Quote_Product__c ';
        strQuoteProductQuery += 'WHERE BigMachines__Quote__c= \'' + quote.Id + '\' AND (BigMachines__Product__r.Type__c != \'Bundle\' OR Bundle__r.Group_Type__c = \'Base Package\' OR Bundle__r.Group_Type__c = \'PureSuccess\')';
        if (blnIsSeperatePO) {
            strQuoteProductQuery += ' and ( BigMachines__Product__r.Type__c = \'Product - System License\' OR BigMachines__Product__r.Type__c = \'Product - Hardware\' OR BigMachines__Product__r.Type__c = \'Product\')';
        }
        if (quote.Is_GU_EMEA__c) 
            strQuoteProductQuery += ' and BigMachines__Product__r.Type__c <> \'Genesys Care\'';

        return Database.query(strQuoteProductQuery);
    }

    public String getDummyAPN (BigMachines__Quote__c objQuote, Boolean hasStandardSupport) {
        String dummyAPN;
        Boolean blnBasePackage = hasStandardSupport ? false : !objQuote.Show_Genesys_Care_Tab__c;
        Boolean blnConcurrent = objQuote.Pricing_Model__c == 'Concurrent' ? true : false;
        String strDirectIndiect = objQuote.End_User_ID__c == objQuote.Sold_To_Name__c ? 'Direct' : 'Indirect';
        
        List<A_La_Carte_Item_PE_PC_Subscription__mdt> listOfDummyAPNs = [SELECT Ala_Carte_Part_Number__c  
                                                                        FROM A_La_Carte_Item_PE_PC_Subscription__mdt
                                                                        WHERE Offering_Type__c =: objQuote.Offering_Type__c AND Base_Package__c =: blnBasePackage
                                                                        AND Direct_Indirect_Sale__c =: strDirectIndiect
                                                                        AND Concurrent__c =: blnConcurrent];
         if ( !listOfDummyAPNs.isEmpty() )
             dummyAPN = listOfDummyAPNs[0].Ala_Carte_Part_Number__c;
            
         return dummyAPN;
    }

    public Decimal decNullTest(Decimal decNum) {
        return (decNum == null ? 0 : decNum); 
    }


}