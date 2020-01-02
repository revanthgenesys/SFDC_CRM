//Naresh Kumar  02/15/2015
public without sharing class QuoteRevenueForecastControllerHelper {
    public final static string GREEN = '#75FF75';
    public final static string YELLOW = '#FFE680';
    public final static string ORANGE = '#FFAD33';
    public final static string RED = '#FF7D5C';

    public static Cloud_Billing_Information__c createCloudBillingRecord(String oppId) {
        List < BigMachines__Quote__c > primaryQuote = [SELECT id, Sold_To_Name__c FROM BigMachines__Quote__c
            WHERE BigMachines__Opportunity__c =: oppId
            AND BigMachines__Is_Primary__c = true
        ];
        Cloud_Billing_Information__c newCloudBillingInfo = new Cloud_Billing_Information__c(Opportunity__c = oppId);
        if (!primaryQuote.isEmpty()) {
            newCloudBillingInfo.Account__c = primaryQuote[0].Sold_To_Name__c;
            newCloudBillingInfo.Quote__c = primaryQuote[0].id;
        }
        insert newCloudBillingInfo;
        return newCloudBillingInfo;
    }

    //public static List<QuoteRevenueForecastController.phaseWrapper> populatePhases(String cloudBillingId,  List<boolean> activeMonthNames){
    //    return populatePhases(cloudBillingId, null, activeMonthNames);
    //}
    /*
    private static List<QuoteRevenueForecastController.lineItemsWrapper> getPSLines(String oppId){
        List<QuoteRevenueForecastController.lineItemsWrapper> oppLines = new List<QuoteRevenueForecastController.lineItemsWrapper>();
        List<Opportunity> PSOpp = [SELECT id FROM Opportunity WHERE ParentOpportunity__c =: oppId];
        if(PSOpp.isEmpty())
            return oppLines;
        List<OpportunityLineItem> oppLineItems = [SELECT PricebookEntry.Product2Id, PricebookEntry.Product2.Name, 
            TotalPrice, Quantity FROM OpportunityLineItem WHERE OpportunityId =: PSOpp[0].id];
        if(oppLineItems.isEmpty())
            return oppLines;
        QuoteRevenueForecastController.lineItemsWrapper newLine = new QuoteRevenueForecastController.lineItemsWrapper();
        newLine.selected = false;
        newLine.lineName = 'PS Cloud Revenue Lines';
        newLine.isHeaderLine = true;
        newLine.rowStyle = 'background-color:#B9F0B9;font-weight:bold;';
        oppLines.add(newLine);
        for(OpportunityLineItem eachLineItem : oppLineItems){
            newLine = new QuoteRevenueForecastController.lineItemsWrapper();
            newLine.selected = false;
            newLine.lineName = eachLineItem.PricebookEntry.Product2.Name;
            newLine.quantity = eachLineItem.TotalPrice;
            newLine.oppProductId = eachLineItem.PricebookEntry.Product2Id;
            //newLine.quantity = eachLineItem.Quantity;
            newLine.isOppLine = true;
            newLine.isHeaderLine = false;
            oppLines.add(newLine);
        }
        return oppLines;
    }
    */
    public static List < QuoteRevenueForecastController.revenueDetailWrapper > populateRevenueDetails(String cloudBillingId, String selectedPhase, List < boolean > activeMonthNames) {
        List < Cloud_Billing_Phase__c > billingPhases = [SELECT id, Name, end_date__c, Phase_Classification__c, Phase_Revenue__c,
            Month_1_Revenue__c, Month_2_Revenue__c, Month_3_Revenue__c, Month_4_Revenue__c, Month_5_Revenue__c, Month_6_Revenue__c, Month_7_Revenue__c,
            Month_8_Revenue__c, Month_9_Revenue__c, Month_10_Revenue__c, Month_11_Revenue__c, Month_12_Revenue__c, Month_13_Revenue__c,
            Month_14_Revenue__c, Month_15_Revenue__c, Month_16_Revenue__c, Month_17_Revenue__c, Month_18_Revenue__c, Month_19_Revenue__c,
            Month_20_Revenue__c, Month_21_Revenue__c, Month_22_Revenue__c, Month_23_Revenue__c, Month_24_Revenue__c, Month_25_Revenue__c,
            Month_26_Revenue__c, Month_27_Revenue__c, Month_28_Revenue__c, Month_29_Revenue__c, Month_30_Revenue__c, Month_31_Revenue__c,
            Month_32_Revenue__c, Month_33_Revenue__c, Month_34_Revenue__c, Month_35_Revenue__c, Month_36_Revenue__c, cmrr__c, Phase_Revenue_One_Time__c
            FROM Cloud_Billing_Phase__c
            WHERE Cloud_Billing_Information__c =: cloudBillingId ORDER BY end_date__c ASC
        ];
        List < QuoteRevenueForecastController.revenueDetailWrapper > phases = new List < QuoteRevenueForecastController.revenueDetailWrapper > ();
        Decimal tm1 = 0;
        Decimal tm2 = 0;
        Decimal tm3 = 0;
        Decimal tm4 = 0;
        Decimal tm5 = 0;
        Decimal tm6 = 0;
        Decimal tm7 = 0;
        Decimal tm8 = 0;
        Decimal tm9 = 0;
        Decimal tm10 = 0;
        Decimal tm11 = 0;
        Decimal tm12 = 0;
        Decimal tm13 = 0;
        Decimal tm14 = 0;
        Decimal tm15 = 0;
        Decimal tm16 = 0;
        Decimal tm17 = 0;
        Decimal tm18 = 0;
        Decimal tm19 = 0;
        Decimal tm20 = 0;
        Decimal tm21 = 0;
        Decimal tm22 = 0;
        Decimal tm23 = 0;
        Decimal tm24 = 0;
        Decimal tm25 = 0;
        Decimal tm26 = 0;
        Decimal tm27 = 0;
        Decimal tm28 = 0;
        Decimal tm29 = 0;
        Decimal tm30 = 0;
        Decimal tm31 = 0;
        Decimal tm32 = 0;
        Decimal tm33 = 0;
        Decimal tm34 = 0;
        Decimal tm35 = 0;
        Decimal tm36 = 0;
        Decimal cmrr = 0;
        Decimal totalOneTime = 0;



        for (Cloud_Billing_Phase__c eachCBP: billingPhases) {
            QuoteRevenueForecastController.revenueDetailWrapper newPhase = new QuoteRevenueForecastController.revenueDetailWrapper();
            newPhase.phase = eachCBP;
            newPhase.isTotalRow = false;
            newPhase.isCMRRRow = false;
            if (selectedPhase == eachCBP.id)
                newPhase.rowStyle = 'background-color:#FFFF99;';

            tm1 = tm1 + eachCBP.Month_1_Revenue__c;
            tm2 = tm2 + eachCBP.Month_2_Revenue__c;
            tm3 = tm3 + eachCBP.Month_3_Revenue__c;
            tm4 = tm4 + eachCBP.Month_4_Revenue__c;
            tm5 = tm5 + eachCBP.Month_5_Revenue__c;
            tm6 = tm6 + eachCBP.Month_6_Revenue__c;
            tm7 = tm7 + eachCBP.Month_7_Revenue__c;
            tm8 = tm8 + eachCBP.Month_8_Revenue__c;
            tm9 = tm9 + eachCBP.Month_9_Revenue__c;
            tm10 = tm10 + eachCBP.Month_10_Revenue__c;
            tm11 = tm11 + eachCBP.Month_11_Revenue__c;
            tm12 = tm12 + eachCBP.Month_12_Revenue__c;
            tm13 = tm13 + eachCBP.Month_13_Revenue__c;
            tm14 = tm14 + eachCBP.Month_14_Revenue__c;
            tm15 = tm15 + eachCBP.Month_15_Revenue__c;
            tm16 = tm16 + eachCBP.Month_16_Revenue__c;
            tm17 = tm17 + eachCBP.Month_17_Revenue__c;
            tm18 = tm18 + eachCBP.Month_18_Revenue__c;
            tm19 = tm19 + eachCBP.Month_19_Revenue__c;
            tm20 = tm20 + eachCBP.Month_20_Revenue__c;
            tm21 = tm21 + eachCBP.Month_21_Revenue__c;
            tm22 = tm22 + eachCBP.Month_22_Revenue__c;
            tm23 = tm23 + eachCBP.Month_23_Revenue__c;
            tm24 = tm24 + eachCBP.Month_24_Revenue__c;
            tm25 = tm25 + eachCBP.Month_25_Revenue__c;
            tm26 = tm26 + eachCBP.Month_26_Revenue__c;
            tm27 = tm27 + eachCBP.Month_27_Revenue__c;
            tm28 = tm28 + eachCBP.Month_28_Revenue__c;
            tm29 = tm29 + eachCBP.Month_29_Revenue__c;
            tm30 = tm30 + eachCBP.Month_30_Revenue__c;
            tm31 = tm31 + eachCBP.Month_31_Revenue__c;
            tm32 = tm32 + eachCBP.Month_32_Revenue__c;
            tm33 = tm33 + eachCBP.Month_33_Revenue__c;
            tm34 = tm34 + eachCBP.Month_34_Revenue__c;
            tm35 = tm35 + eachCBP.Month_35_Revenue__c;
            tm36 = tm36 + eachCBP.Month_36_Revenue__c;
            totalOneTime = totalOneTime + eachCBP.Phase_Revenue_One_Time__c;

            cmrr = eachCBP.cmrr__c;
            if (activeMonthNames != null) {
                Decimal total1To24 = (activeMonthNames[0] ? eachCBP.Month_1_Revenue__c : 0) +
                    (activeMonthNames[1] ? eachCBP.Month_2_Revenue__c : 0) +
                    (activeMonthNames[2] ? eachCBP.Month_3_Revenue__c : 0) +
                    (activeMonthNames[3] ? eachCBP.Month_4_Revenue__c : 0) +
                    (activeMonthNames[4] ? eachCBP.Month_5_Revenue__c : 0) +
                    (activeMonthNames[5] ? eachCBP.Month_6_Revenue__c : 0) +
                    (activeMonthNames[6] ? eachCBP.Month_7_Revenue__c : 0) +
                    (activeMonthNames[7] ? eachCBP.Month_8_Revenue__c : 0) +
                    (activeMonthNames[8] ? eachCBP.Month_9_Revenue__c : 0) +
                    (activeMonthNames[9] ? eachCBP.Month_10_Revenue__c : 0) +
                    (activeMonthNames[10] ? eachCBP.Month_11_Revenue__c : 0) +
                    (activeMonthNames[11] ? eachCBP.Month_12_Revenue__c : 0) +
                    (activeMonthNames[12] ? eachCBP.Month_13_Revenue__c : 0) +
                    (activeMonthNames[13] ? eachCBP.Month_14_Revenue__c : 0) +
                    (activeMonthNames[14] ? eachCBP.Month_15_Revenue__c : 0) +
                    (activeMonthNames[15] ? eachCBP.Month_16_Revenue__c : 0) +
                    (activeMonthNames[16] ? eachCBP.Month_17_Revenue__c : 0) +
                    (activeMonthNames[17] ? eachCBP.Month_18_Revenue__c : 0) +
                    (activeMonthNames[18] ? eachCBP.Month_19_Revenue__c : 0) +
                    (activeMonthNames[19] ? eachCBP.Month_20_Revenue__c : 0) +
                    (activeMonthNames[20] ? eachCBP.Month_21_Revenue__c : 0) +
                    (activeMonthNames[21] ? eachCBP.Month_22_Revenue__c : 0) +
                    (activeMonthNames[22] ? eachCBP.Month_23_Revenue__c : 0) +
                    (activeMonthNames[23] ? eachCBP.Month_24_Revenue__c : 0) +
                    (activeMonthNames[24] ? eachCBP.Month_25_Revenue__c : 0) +
                    (activeMonthNames[25] ? eachCBP.Month_26_Revenue__c : 0) +
                    (activeMonthNames[26] ? eachCBP.Month_27_Revenue__c : 0) +
                    (activeMonthNames[27] ? eachCBP.Month_28_Revenue__c : 0) +
                    (activeMonthNames[28] ? eachCBP.Month_29_Revenue__c : 0) +
                    (activeMonthNames[29] ? eachCBP.Month_30_Revenue__c : 0) +
                    (activeMonthNames[20] ? eachCBP.Month_31_Revenue__c : 0) +
                    (activeMonthNames[31] ? eachCBP.Month_32_Revenue__c : 0) +
                    (activeMonthNames[32] ? eachCBP.Month_33_Revenue__c : 0) +
                    (activeMonthNames[33] ? eachCBP.Month_34_Revenue__c : 0) +
                    (activeMonthNames[34] ? eachCBP.Month_35_Revenue__c : 0) +
                    (activeMonthNames[35] ? eachCBP.Month_36_Revenue__c : 0);

                newPhase.total1To24 = total1To24;
            }
            phases.add(newPhase);
        }
        QuoteRevenueForecastController.revenueDetailWrapper newPhase = new QuoteRevenueForecastController.revenueDetailWrapper();
        newPhase.isTotalRow = true;
        newPhase.isCMRRRow = false;
        Cloud_Billing_Phase__c totalRecord = new Cloud_Billing_Phase__c();
        newPhase.rowStyle = 'font-weight:bold;';
        newPhase.Total_Month_1 = tm1;
        newPhase.Total_Month_2 = tm2;
        newPhase.Total_Month_3 = tm3;
        newPhase.Total_Month_4 = tm4;
        newPhase.Total_Month_5 = tm5;
        newPhase.Total_Month_6 = tm6;
        newPhase.Total_Month_7 = tm7;
        newPhase.Total_Month_8 = tm8;
        newPhase.Total_Month_9 = tm9;
        newPhase.Total_Month_10 = tm10;
        newPhase.Total_Month_11 = tm11;
        newPhase.Total_Month_12 = tm12;
        newPhase.Total_Month_13 = tm13;
        newPhase.Total_Month_14 = tm14;
        newPhase.Total_Month_15 = tm15;
        newPhase.Total_Month_16 = tm16;
        newPhase.Total_Month_17 = tm17;
        newPhase.Total_Month_18 = tm18;
        newPhase.Total_Month_19 = tm19;
        newPhase.Total_Month_20 = tm20;
        newPhase.Total_Month_21 = tm21;
        newPhase.Total_Month_22 = tm22;
        newPhase.Total_Month_23 = tm23;
        newPhase.Total_Month_24 = tm24;
        newPhase.Total_Month_25 = tm25;
        newPhase.Total_Month_26 = tm26;
        newPhase.Total_Month_27 = tm27;
        newPhase.Total_Month_28 = tm28;
        newPhase.Total_Month_29 = tm29;
        newPhase.Total_Month_30 = tm30;
        newPhase.Total_Month_31 = tm31;
        newPhase.Total_Month_32 = tm32;
        newPhase.Total_Month_33 = tm33;
        newPhase.Total_Month_34 = tm34;
        newPhase.Total_Month_35 = tm35;
        newPhase.Total_Month_36 = tm36;
        newPhase.totalPhaseRevenueOneTime = totalOneTime;

        if (activeMonthNames != null) {
            Decimal total1To24 = (activeMonthNames[0] ? newPhase.Total_Month_1 : 0) +
                (activeMonthNames[1] ? newPhase.Total_Month_2 : 0) +
                (activeMonthNames[2] ? newPhase.Total_Month_3 : 0) +
                (activeMonthNames[3] ? newPhase.Total_Month_4 : 0) +
                (activeMonthNames[4] ? newPhase.Total_Month_5 : 0) +
                (activeMonthNames[5] ? newPhase.Total_Month_6 : 0) +
                (activeMonthNames[6] ? newPhase.Total_Month_7 : 0) +
                (activeMonthNames[7] ? newPhase.Total_Month_8 : 0) +
                (activeMonthNames[8] ? newPhase.Total_Month_9 : 0) +
                (activeMonthNames[9] ? newPhase.Total_Month_10 : 0) +
                (activeMonthNames[10] ? newPhase.Total_Month_11 : 0) +
                (activeMonthNames[11] ? newPhase.Total_Month_12 : 0) +
                (activeMonthNames[12] ? newPhase.Total_Month_13 : 0) +
                (activeMonthNames[13] ? newPhase.Total_Month_14 : 0) +
                (activeMonthNames[14] ? newPhase.Total_Month_15 : 0) +
                (activeMonthNames[15] ? newPhase.Total_Month_16 : 0) +
                (activeMonthNames[16] ? newPhase.Total_Month_17 : 0) +
                (activeMonthNames[17] ? newPhase.Total_Month_18 : 0) +
                (activeMonthNames[18] ? newPhase.Total_Month_19 : 0) +
                (activeMonthNames[19] ? newPhase.Total_Month_20 : 0) +
                (activeMonthNames[20] ? newPhase.Total_Month_21 : 0) +
                (activeMonthNames[21] ? newPhase.Total_Month_22 : 0) +
                (activeMonthNames[22] ? newPhase.Total_Month_23 : 0) +
                (activeMonthNames[23] ? newPhase.Total_Month_24 : 0) +
                (activeMonthNames[24] ? newPhase.Total_Month_25 : 0) +
                (activeMonthNames[25] ? newPhase.Total_Month_26 : 0) +
                (activeMonthNames[26] ? newPhase.Total_Month_27 : 0) +
                (activeMonthNames[27] ? newPhase.Total_Month_28 : 0) +
                (activeMonthNames[28] ? newPhase.Total_Month_29 : 0) +
                (activeMonthNames[29] ? newPhase.Total_Month_30 : 0) +
                (activeMonthNames[30] ? newPhase.Total_Month_31 : 0) +
                (activeMonthNames[31] ? newPhase.Total_Month_32 : 0) +
                (activeMonthNames[32] ? newPhase.Total_Month_33 : 0) +
                (activeMonthNames[33] ? newPhase.Total_Month_34 : 0) +
                (activeMonthNames[34] ? newPhase.Total_Month_35 : 0) +
                (activeMonthNames[35] ? newPhase.Total_Month_36 : 0);

            newPhase.total1To24 = total1To24;
        }
        phases.add(newPhase);

        newPhase = new QuoteRevenueForecastController.revenueDetailWrapper();
        newPhase.isTotalRow = false;
        newPhase.isCMRRRow = true;
        totalRecord = new Cloud_Billing_Phase__c();
        newPhase.rowStyle = 'font-weight:bold;';
        newPhase.Total_Month_1 = cmrr;
        newPhase.Total_Month_2 = cmrr;
        newPhase.Total_Month_3 = cmrr;
        newPhase.Total_Month_4 = cmrr;
        newPhase.Total_Month_5 = cmrr;
        newPhase.Total_Month_6 = cmrr;
        newPhase.Total_Month_7 = cmrr;
        newPhase.Total_Month_8 = cmrr;
        newPhase.Total_Month_9 = cmrr;
        newPhase.Total_Month_10 = cmrr;
        newPhase.Total_Month_11 = cmrr;
        newPhase.Total_Month_12 = cmrr;
        newPhase.Total_Month_13 = cmrr;
        newPhase.Total_Month_14 = cmrr;
        newPhase.Total_Month_15 = cmrr;
        newPhase.Total_Month_16 = cmrr;
        newPhase.Total_Month_17 = cmrr;
        newPhase.Total_Month_18 = cmrr;
        newPhase.Total_Month_19 = cmrr;
        newPhase.Total_Month_20 = cmrr;
        newPhase.Total_Month_21 = cmrr;
        newPhase.Total_Month_22 = cmrr;
        newPhase.Total_Month_23 = cmrr;
        newPhase.Total_Month_24 = cmrr;
        newPhase.Total_Month_25 = cmrr;
        newPhase.Total_Month_26 = cmrr;
        newPhase.Total_Month_27 = cmrr;
        newPhase.Total_Month_28 = cmrr;
        newPhase.Total_Month_29 = cmrr;
        newPhase.Total_Month_30 = cmrr;
        newPhase.Total_Month_31 = cmrr;
        newPhase.Total_Month_32 = cmrr;
        newPhase.Total_Month_33 = cmrr;
        newPhase.Total_Month_34 = cmrr;
        newPhase.Total_Month_35 = cmrr;
        newPhase.Total_Month_36 = cmrr;

        if (activeMonthNames != null) {
            Decimal total1To24 = (activeMonthNames[0] ? newPhase.Total_Month_1 : 0) +
                (activeMonthNames[1] ? newPhase.Total_Month_2 : 0) +
                (activeMonthNames[2] ? newPhase.Total_Month_3 : 0) +
                (activeMonthNames[3] ? newPhase.Total_Month_4 : 0) +
                (activeMonthNames[4] ? newPhase.Total_Month_5 : 0) +
                (activeMonthNames[5] ? newPhase.Total_Month_6 : 0) +
                (activeMonthNames[6] ? newPhase.Total_Month_7 : 0) +
                (activeMonthNames[7] ? newPhase.Total_Month_8 : 0) +
                (activeMonthNames[8] ? newPhase.Total_Month_9 : 0) +
                (activeMonthNames[9] ? newPhase.Total_Month_10 : 0) +
                (activeMonthNames[10] ? newPhase.Total_Month_11 : 0) +
                (activeMonthNames[11] ? newPhase.Total_Month_12 : 0) +
                (activeMonthNames[12] ? newPhase.Total_Month_13 : 0) +
                (activeMonthNames[13] ? newPhase.Total_Month_14 : 0) +
                (activeMonthNames[14] ? newPhase.Total_Month_15 : 0) +
                (activeMonthNames[15] ? newPhase.Total_Month_16 : 0) +
                (activeMonthNames[16] ? newPhase.Total_Month_17 : 0) +
                (activeMonthNames[17] ? newPhase.Total_Month_18 : 0) +
                (activeMonthNames[18] ? newPhase.Total_Month_19 : 0) +
                (activeMonthNames[19] ? newPhase.Total_Month_20 : 0) +
                (activeMonthNames[20] ? newPhase.Total_Month_21 : 0) +
                (activeMonthNames[21] ? newPhase.Total_Month_22 : 0) +
                (activeMonthNames[22] ? newPhase.Total_Month_23 : 0) +
                (activeMonthNames[23] ? newPhase.Total_Month_24 : 0) +
                (activeMonthNames[24] ? newPhase.Total_Month_25 : 0) +
                (activeMonthNames[25] ? newPhase.Total_Month_26 : 0) +
                (activeMonthNames[26] ? newPhase.Total_Month_27 : 0) +
                (activeMonthNames[27] ? newPhase.Total_Month_28 : 0) +
                (activeMonthNames[28] ? newPhase.Total_Month_29 : 0) +
                (activeMonthNames[29] ? newPhase.Total_Month_30 : 0) +
                (activeMonthNames[30] ? newPhase.Total_Month_31 : 0) +
                (activeMonthNames[31] ? newPhase.Total_Month_32 : 0) +
                (activeMonthNames[32] ? newPhase.Total_Month_33 : 0) +
                (activeMonthNames[33] ? newPhase.Total_Month_34 : 0) +
                (activeMonthNames[34] ? newPhase.Total_Month_35 : 0) +
                (activeMonthNames[35] ? newPhase.Total_Month_36 : 0);

            newPhase.total1To24 = total1To24;
        }
        phases.add(newPhase);
        return phases;
    }

    public static List < QuoteRevenueForecastController.phaseWrapper > populatePhases(String cloudBillingId, String selectedPhase) {
        List < Cloud_Billing_Phase__c > billingPhases = [SELECT id, Phase_Number__c, End_Date__c, Phase_Classification__c, Phase_Revenue__c,
            Phase_Name__c FROM Cloud_Billing_Phase__c
            WHERE Cloud_Billing_Information__c =: cloudBillingId ORDER BY End_Date__c ASC
        ];
        List < QuoteRevenueForecastController.phaseWrapper > phases = new List < QuoteRevenueForecastController.phaseWrapper > ();
        for (Cloud_Billing_Phase__c eachCBP: billingPhases) {
            QuoteRevenueForecastController.phaseWrapper newPhase = new QuoteRevenueForecastController.phaseWrapper();
            newPhase.phase = eachCBP;
            newPhase.isAddPhase = false;
            //if(selectedPhase == eachCBP.id)
            //    newPhase.style = 'font-weight:bold;background-color:#8a9ebe;color:#FFFFFF;';
            phases.add(newPhase);
        }
        QuoteRevenueForecastController.phaseWrapper newPhase = new QuoteRevenueForecastController.phaseWrapper();
        newPhase.isAddPhase = true;
        newPhase.style = 'font-weight:bold;';
        phases.add(newPhase);
        return phases;
    }

    public static List < QuoteRevenueForecastController.lineItemsWrapper > populateLines(String oppId, String quoteNumber, String selectedPhase) {
        List < BigMachines__Quote_Product__c > quoteProducts = [SELECT id, BigMachines__Description__c, BigMachines__Quantity__c, Net_Unit_Price__c,
            BigMachines__Quote__r.Name, BigMachines__Product__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__r.BigMachines__Opportunity__c =: oppId
            AND BigMachines__Quote__r.BigMachines__Is_Primary__c = true ORDER BY BigMachines__Description__c
        ];
        if (!quoteProducts.isEmpty())
            quoteNumber = quoteProducts[0].BigMachines__Quote__r.Name;
        List < QuoteRevenueForecastController.lineItemsWrapper > lineItems = new List < QuoteRevenueForecastController.lineItemsWrapper > ();
        Map < Id, String > mapProductIdVsPhases = new Map < Id, String > ();
        Map < Id, Integer > mapProductIdVsPhaseTotal = new Map < Id, Integer > ();
        populateLineItemsPhases(oppId, mapProductIdVsPhases, mapProductIdVsPhaseTotal);
        QuoteRevenueForecastController.lineItemsWrapper newItem = getHeaderRecord();
        lineItems.add(newItem);
        List < Cloud_Phase_Line_Items__c > cloudPhaseLineItems;
        if (selectedPhase != null && selectedPhase != '')
            cloudPhaseLineItems = [SELECT id, Quantity__c, Product__c, Product__r.Name, Net_Unit_Price__c, Revenue__c, Adjusted_Revenue__c,
                Cloud_Billing_Phase__c, Net_Unit_Price_One_Time__c FROM Cloud_Phase_Line_Items__c WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId
                AND Cloud_Billing_Phase__c =: selectedPhase ORDER BY Product__r.Name
            ];
        else
            cloudPhaseLineItems = [SELECT id, Quantity__c, Product__c, Product__r.Name, Net_Unit_Price__c, Revenue__c, Adjusted_Revenue__c,
                Cloud_Billing_Phase__c, Net_Unit_Price_One_Time__c FROM Cloud_Phase_Line_Items__c WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId
                ORDER BY Product__r.Name
            ];
        Double totalRevenue = 0;
        for (Cloud_Phase_Line_Items__c eachPhaseLine: cloudPhaseLineItems) {
            newItem = getLineItemPopulated(eachPhaseLine, mapProductIdVsPhases, mapProductIdVsPhaseTotal);
            totalRevenue += (newItem.revenue == null ? 0 : newItem.revenue);
            lineItems.add(newItem);
        }

        if (lineItems.size() == 1 && (selectedPhase == null || selectedPhase == '' && selectedPhase == null)) {
            for (BigMachines__Quote_Product__c eachQP: quoteProducts) {
                newItem = new QuoteRevenueForecastController.lineItemsWrapper();
                newItem.lineName = eachQP.BigMachines__Description__c;
                newItem.status = 'Active';
                newItem.quantity = eachQP.BigMachines__Quantity__c;
                newItem.price = eachQP.Net_Unit_Price__c;
                newItem.quoteProduct = eachQP;
                newItem.revenue = (eachQP.Net_Unit_Price__c == null ? 0 : eachQP.Net_Unit_Price__c) * (eachQP.BigMachines__Quantity__c == null ? 0 : eachQP.BigMachines__Quantity__c);
                newItem.selected = false;
                newItem.phaseQuantity = 0;
                newItem.linePhases = mapProductIdVsPhases.get(eachQP.id);
                newItem.isHeaderLine = false;
                newItem.isTotalLine = false;
                newItem.isOppLine = false;
                newItem.phaseTotal = mapProductIdVsPhaseTotal.get(eachQP.id);
                newItem.isFromQuote = true;
                newItem.isAddLine = false;
                totalRevenue += newItem.revenue;
                lineItems.add(newItem);
            }
        }
        newItem = getTotalRecord(totalRevenue);
        lineItems.add(newItem);
        //List<QuoteRevenueForecastController.lineItemsWrapper> psLines = getPSLines(oppId);

        return lineItems;
    }

    private static QuoteRevenueForecastController.lineItemsWrapper getHeaderRecord() {
        QuoteRevenueForecastController.lineItemsWrapper newItem = new QuoteRevenueForecastController.lineItemsWrapper();
        newItem.selected = false;
        newItem.lineName = 'Subscription Cloud Revenue Lines';
        newItem.isHeaderLine = true;
        newItem.isTotalLine = false;
        newItem.rowStyle = 'background-color:#B9F0B9;font-weight:bold;';
        return newItem;
    }

    private static QuoteRevenueForecastController.lineItemsWrapper getTotalRecord(Decimal totalRevenue) {
        QuoteRevenueForecastController.lineItemsWrapper newItem = new QuoteRevenueForecastController.lineItemsWrapper();
        newItem.selected = false;
        newItem.lineName = 'Total';
        newItem.isHeaderLine = true;
        newItem.isTotalLine = true;
        newItem.revenue = totalRevenue;
        newItem.rowStyle = 'background-color:#B9F0B9;font-weight:bold;';
        return newItem;
    }

    private static QuoteRevenueForecastController.lineItemsWrapper getLineItemPopulated(Cloud_Phase_Line_Items__c eachPhaseLine, Map < Id, String > mapProductIdVsPhases,
        Map < Id, Integer > mapProductIdVsPhaseTotal) {
        QuoteRevenueForecastController.lineItemsWrapper newItem = new QuoteRevenueForecastController.lineItemsWrapper();
        newItem.lineName = eachPhaseLine.Product__r.Name;
        newItem.status = 'Active';
        newItem.quantity = eachPhaseLine.Quantity__c;
        if (Label.Cloud_Rev_Forecast_One_Time_Charges_Product_Ids.contains(eachPhaseLine.Product__c))
            newItem.price = eachPhaseLine.Net_Unit_Price_One_Time__c;
        else
            newItem.price = eachPhaseLine.Net_Unit_Price__c;
        newItem.phaseLineItem = eachPhaseLine;
        newItem.phaseId = eachPhaseLine.Cloud_Billing_Phase__c;
        newItem.revenue = eachPhaseLine.Adjusted_Revenue__c;
        newItem.selected = false;
        newItem.phaseQuantity = 0;
        newItem.linePhases = mapProductIdVsPhases.get(eachPhaseLine.Product__c);
        newItem.isHeaderLine = false;
        newItem.isTotalLine = false;
        newItem.isOppLine = false;
        newItem.phaseTotal = mapProductIdVsPhaseTotal.get(eachPhaseLine.Product__c);
        newItem.isFromQuote = false;
        return newItem;
    }
    

    public static List < QuoteRevenueForecastController.lineItemsWrapper > loadPhaseLineItems(String selectedPhase, List < QuoteRevenueForecastController.lineItemsWrapper > lineItems, String oppId) {
        lineItems.clear();
        Map < Id, String > mapProductIdVsPhases = new Map < Id, String > ();
        Map < Id, Integer > mapProductIdVsPhaseTotal = new Map < Id, Integer > ();
        populateLineItemsPhases(oppId, mapProductIdVsPhases, mapProductIdVsPhaseTotal);
        Set < Id > setOfSelectedPhaseLineItemIds = new Set < Id > ();
        List < Cloud_Phase_Line_Items__c > phaseLineItems;
        if (selectedPhase != null && selectedPhase != '')
            phaseLineItems = [SELECT id, Quantity__c, Product__c, Product__r.Name, Net_Unit_Price__c, Revenue__c, Adjusted_Revenue__c,
                Cloud_Billing_Phase__c, Net_Unit_Price_One_Time__c FROM Cloud_Phase_Line_Items__c WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId
                AND Cloud_Billing_Phase__c =: selectedPhase
            ];
        else
            phaseLineItems = [SELECT id, Quantity__c, Product__c, Product__r.Name, Net_Unit_Price__c, Revenue__c, Adjusted_Revenue__c,
                Cloud_Billing_Phase__c, Net_Unit_Price_One_Time__c FROM Cloud_Phase_Line_Items__c WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId
                ORDER BY Product__r.Name
            ];
        Double totalRevenue = 0;
        QuoteRevenueForecastController.lineItemsWrapper newItem = getHeaderRecord();
        lineItems.add(newItem);
        for (Cloud_Phase_Line_Items__c eachPhaseLine: phaseLineItems) {
            newItem = getLineItemPopulated(eachPhaseLine, mapProductIdVsPhases, mapProductIdVsPhaseTotal);
            totalRevenue += (newItem.revenue == null ? 0 : newItem.revenue) + (eachPhaseLine.Net_Unit_Price_One_Time__c == null ? 0 : eachPhaseLine.Net_Unit_Price_One_Time__c);
            lineItems.add(newItem);
        }
        newItem = getTotalRecord(totalRevenue);
        lineItems.add(newItem);
        return lineItems;
    }

    public static void populateLineItemsPhases(String oppId, Map < Id, String > mapProductIdVsPhases, Map < Id, Integer > mapProductIdVsPhaseTotal) {

        List < Cloud_Phase_Line_Items__c > allPhaseLines = [SELECT Quantity__c, Product__c, Cloud_Billing_Phase__r.Phase_Number__c FROM
            Cloud_Phase_Line_Items__c WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId
        ];

        for (Cloud_Phase_Line_Items__c eachLine: allPhaseLines) {
            String phases;
            Integer phaseTotal = 0;
            if (mapProductIdVsPhases.get(eachLine.Product__c) != null) {
                phases = mapProductIdVsPhases.get(eachLine.Product__c);
                phases = phases + ', ' + 'Phase ' + eachLine.Cloud_Billing_Phase__r.Phase_Number__c + ' (' + String.valueOf(eachLine.Quantity__c) + ')';
                mapProductIdVsPhases.put(eachLine.Product__c, phases);
                phaseTotal = mapProductIdVsPhaseTotal.get(eachLine.Product__c);
                phaseTotal = phaseTotal + Integer.valueOf(eachLine.Quantity__c);
                mapProductIdVsPhaseTotal.put(eachLine.Product__c, phaseTotal);
            } else {
                phases = 'Phase ' + eachLine.Cloud_Billing_Phase__r.Phase_Number__c + ' (' + String.valueOf(eachLine.Quantity__c) + ')';
                mapProductIdVsPhases.put(eachLine.Product__c, phases);
                phaseTotal = phaseTotal + Integer.valueOf(eachLine.Quantity__c);
                mapProductIdVsPhaseTotal.put(eachLine.Product__c, phaseTotal);
            }
        }
    }

    public static void cloneProductLine(List < QuoteRevenueForecastController.lineItemsWrapper > productLineItems, String recordIdToClone) {
        QuoteRevenueForecastController.lineItemsWrapper newItem = new QuoteRevenueForecastController.lineItemsWrapper();
        System.debug('NKC debug productLineItems [' + productLineItems + ']');
        for (QuoteRevenueForecastController.lineItemsWrapper eachItem: productLineItems) {
            if (eachItem.phaseLineItem != null && recordIdToClone == eachItem.phaseLineItem.id) {
                newItem.index = eachItem.index;
                newItem.isHeaderLine = eachItem.isHeaderLine;
                newItem.isTotalLine = eachItem.isTotalLine;
                newItem.isOppLine = eachItem.isOppLine;
                newItem.lineName = eachItem.lineName;
                newItem.selected = eachItem.selected;
                newItem.status = eachItem.status;
                newItem.quantity = eachItem.quantity;
                newItem.revenue = eachItem.revenue;
                newItem.price = eachItem.price;
                newItem.quoteProduct = eachItem.quoteProduct;
                newItem.oppProductId = eachItem.oppProductId;
                newItem.phaseQuantity = eachItem.phaseQuantity;
                newItem.rowStyle = eachItem.rowStyle;
                newItem.linePhases = eachItem.linePhases;
                newItem.phaseTotal = eachItem.phaseTotal;
                newItem.netUnitPrice = eachItem.netUnitPrice;
                newItem.phaseId = eachItem.phaseId;
                newItem.phaseLineItem = eachItem.phaseLineItem;
                newItem.isFromQuote = false;
                productLineItems.add(newItem);
                break;
            }
        }
    }

    public static void savePhaseLines(List < QuoteRevenueForecastController.lineItemsWrapper > productLineItems, String oppId, String selectedPhase, String accountId) {
        List < Cloud_Phase_Line_Items__c > cloudPhaseLinessToBeDeleted;

        if (selectedPhase == null || selectedPhase == '')
            cloudPhaseLinessToBeDeleted = [SELECT id FROM Cloud_Phase_Line_Items__c WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId];
        else
            cloudPhaseLinessToBeDeleted = [SELECT id FROM Cloud_Phase_Line_Items__c
                WHERE Cloud_Billing_Phase__r.Cloud_Billing_Information__r.Opportunity__c =: oppId AND Cloud_Billing_Phase__c =: selectedPhase
            ];
        if (!cloudPhaseLinessToBeDeleted.isEmpty())
            delete cloudPhaseLinessToBeDeleted;
        List < Cloud_Phase_Line_Items__c > cloudPhaseLinesToBeInserted = new List < Cloud_Phase_Line_Items__c > ();
        for (QuoteRevenueForecastController.lineItemsWrapper eachItem: productLineItems) {
            if (eachItem.phaseId != null && !eachItem.isHeaderLine && !eachItem.isTotalLine) {
                Cloud_Phase_Line_Items__c newLineItem = new Cloud_Phase_Line_Items__c();
                newLineItem.Account__c = accountId;
                newLineItem.Quantity__c = eachItem.quantity;
                System.debug('NKC debug Label.Cloud_Rev_Forecast_One_Time_Charges_Product_Ids [' + Label.Cloud_Rev_Forecast_One_Time_Charges_Product_Ids + ']');
                System.debug('NKC debug eachItem.phaseLineItem.Product__c [' + eachItem.phaseLineItem.Product__c + ']');
                if (eachItem.phaseLineItem.Product__c != null && Label.Cloud_Rev_Forecast_One_Time_Charges_Product_Ids.contains(eachItem.phaseLineItem.Product__c))
                    newLineItem.Net_Unit_Price_One_Time__c = eachItem.price;
                else
                    newLineItem.Net_Unit_Price__c = eachItem.price;
                newLineItem.Adjusted_Revenue__c = (eachItem.price == null ? 0 : eachItem.price) * (eachItem.quantity == null ? 0 : eachItem.quantity);
                newLineItem.Cloud_Billing_Phase__c = eachItem.phaseId;
                //newLineItem.Adjusted_Revenue__c = eachItem.netUnitPrice * eachItem.phaseQuantity;
                System.debug('NKC debug eachItem.revenue [' + eachItem.revenue + ']');
                System.debug('NKC debug newLineItem.Product__c [' + newLineItem.Product__c + ']');
                if (eachItem.isFromQuote && !eachItem.isAddLine)
                    newLineItem.Product__c = eachItem.quoteProduct.BigMachines__Product__c;
                else
                    newLineItem.Product__c = eachItem.phaseLineItem.Product__c;
                System.debug('NKC debug eachItem.phaseLineItem [' + eachItem.phaseLineItem + ']');
                System.debug('NKC debug eachItem.isAddLine [' + eachItem.isAddLine + ']');
                System.debug('NKC debug newLineItem.Product__c [' + newLineItem.Product__c + ']');
                /*
                if(eachItem.quoteProduct == null){
                    newLineItem.PS_Total__c = eachItem.quantity;
                    newLineItem.Product__c = eachItem.oppProductId;
                }
                else{
                    newLineItem.Quote_Product__c = eachItem.quoteProduct.id;
                    newLineItem.Product__c = eachItem.quoteProduct.BigMachines__Product__c;
                }
                */
                newLineItem.Cloud_Billing_Phase__c = eachItem.phaseId;
                cloudPhaseLinesToBeInserted.add(newLineItem);
            }
        }
        if (!cloudPhaseLinesToBeInserted.isEmpty())
            insert cloudPhaseLinesToBeInserted;

    }
    
    
    public static Cloud_Billing_Phase__c getPhase(String phaseId){
    	return [SELECT End_Date__c, Phase_Revenue_One_Time__c FROM Cloud_Billing_Phase__c WHERE id =: phaseId];	
    }

    public static Cloud_Billing_Phase__c populatePhaseDates(Cloud_Billing_Phase__c phase, Date oppClosedDate) {
    	System.debug('NKC debug phase ['+phase+']');
    	System.debug('NKC debug oppClosedDate ['+oppClosedDate+']');
    	
        if (oppClosedDate != null) {
            Integer year = oppClosedDate.Year();
            Integer month = oppClosedDate.Month();
            Integer day = oppClosedDate.Day();
            Integer year1 = year;
            Integer month1 = month;
            Integer day1 = day;


            if (phase.End_Date__c != null) {
                year1 = phase.End_Date__c.Year();
                month1 = phase.End_Date__c.Month();
                day1 = phase.End_Date__c.Day();
            }

            Boolean flag = false;
      Boolean oneTimeChargesApplied = false;
      
      phase.One_Time_Revenue_1__c = 0;
      phase.One_Time_Revenue_2__c = 0;
      phase.One_Time_Revenue_3__c = 0;
      phase.One_Time_Revenue_4__c = 0;
      phase.One_Time_Revenue_5__c = 0;
      phase.One_Time_Revenue_6__c = 0;
      phase.One_Time_Revenue_7__c = 0;
      phase.One_Time_Revenue_8__c = 0;
      phase.One_Time_Revenue_9__c = 0;
      phase.One_Time_Revenue_10__c = 0;
      phase.One_Time_Revenue_11__c = 0;
      phase.One_Time_Revenue_12__c = 0;
      phase.One_Time_Revenue_13__c = 0;
      phase.One_Time_Revenue_14__c = 0;
      phase.One_Time_Revenue_15__c = 0;
      phase.One_Time_Revenue_16__c = 0;
      phase.One_Time_Revenue_17__c = 0;
      phase.One_Time_Revenue_18__c = 0;
      phase.One_Time_Revenue_19__c = 0;
      phase.One_Time_Revenue_20__c = 0;
      phase.One_Time_Revenue_21__c = 0;
      phase.One_Time_Revenue_22__c = 0;
      phase.One_Time_Revenue_23__c = 0;
      phase.One_Time_Revenue_24__c = 0;
      phase.One_Time_Revenue_25__c = 0;
      phase.One_Time_Revenue_26__c = 0;
      phase.One_Time_Revenue_27__c = 0;
      phase.One_Time_Revenue_28__c = 0;
      phase.One_Time_Revenue_29__c = 0;
      phase.One_Time_Revenue_30__c = 0;
      phase.One_Time_Revenue_31__c = 0;
      phase.One_Time_Revenue_32__c = 0;
      phase.One_Time_Revenue_33__c = 0;
      phase.One_Time_Revenue_34__c = 0;
      phase.One_Time_Revenue_35__c = 0;
      phase.One_Time_Revenue_36__c = 0;
      
      
      System.debug('NKC debug month ['+month+']');
            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_1__c = 0;            
            else{
              System.debug('NKC debug flag ['+flag+']');
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_1__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } 
              else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_1__c = 0;
                  else
                      phase.Month_1__c = date.daysInMonth(year, month);
              }
              
              if(phase.Month_1__c >0 && !oneTimeChargesApplied){
                phase.One_Time_Revenue_1__c = phase.Phase_Revenue_One_Time__c;
                oneTimeChargesApplied = true;
              }
            }


            year = getNextYear(month, year);
            month = getNextMonth(month);



            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_2__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_2__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_2__c = 0;
                  else
                      phase.Month_2__c = date.daysInMonth(year, month);
              }
              if(phase.Month_2__c >0 && !oneTimeChargesApplied){
                phase.One_Time_Revenue_2__c = phase.Phase_Revenue_One_Time__c;
                oneTimeChargesApplied = true;
              }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_3__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_3__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_3__c = 0;
                  else
                      phase.Month_3__c = date.daysInMonth(year, month);
              }
              if(phase.Month_3__c >0 && !oneTimeChargesApplied){
                phase.One_Time_Revenue_3__c = phase.Phase_Revenue_One_Time__c;
                oneTimeChargesApplied = true;
              }
            }


            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_4__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_4__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_4__c = 0;
                  else
                      phase.Month_4__c = date.daysInMonth(year, month);
              }
              if(phase.Month_4__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_4__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_5__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_5__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_5__c = 0;
                  else
                      phase.Month_5__c = date.daysInMonth(year, month);
              }
              if(phase.Month_5__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_5__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_6__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_6__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_6__c = 0;
                  else
                      phase.Month_6__c = date.daysInMonth(year, month);
              }
              if(phase.Month_6__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_6__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_7__c = 0;
            else{
              if(!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_7__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_7__c = 0;
                  else
                      phase.Month_7__c = date.daysInMonth(year, month);
              }
              if(phase.Month_7__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_7__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_8__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_8__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_8__c = 0;
                  else
                      phase.Month_8__c = date.daysInMonth(year, month);
              }
              if(phase.Month_8__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_8__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_9__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_9__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_9__c = 0;
                  else
                      phase.Month_9__c = date.daysInMonth(year, month);
              }
              
        if(phase.Month_9__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_9__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_10__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_10__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_10__c = 0;
                  else
                      phase.Month_10__c = date.daysInMonth(year, month);
              }
        if(phase.Month_10__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_10__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_11__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_11__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_11__c = 0;
                  else
                      phase.Month_11__c = date.daysInMonth(year, month);
              }
        if(phase.Month_11__c >0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_11__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_12__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_12__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_12__c = 0;
                  else
                      phase.Month_12__c = date.daysInMonth(year, month);
              }
        if(phase.Month_12__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_12__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);


            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_13__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_13__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_13__c = 0;
                  else
                      phase.Month_13__c = date.daysInMonth(year, month);
              }
        if(phase.Month_13__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_13__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }


            year = getNextYear(month, year);
            month = getNextMonth(month);



            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_14__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_14__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_14__c = 0;
                  else
                      phase.Month_14__c = date.daysInMonth(year, month);
              }
        if(phase.Month_14__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_14__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }


            year = getNextYear(month, year);
            month = getNextMonth(month);


            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_15__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_15__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_15__c = 0;
                  else
                      phase.Month_15__c = date.daysInMonth(year, month);
              }
        if(phase.Month_15__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_15__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);



            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_16__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_16__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_16__c = 0;
                  else
                      phase.Month_16__c = date.daysInMonth(year, month);
              }
        if(phase.Month_16__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_16__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }


            year = getNextYear(month, year);
            month = getNextMonth(month);


            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_17__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_17__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_17__c = 0;
                  else
                      phase.Month_17__c = date.daysInMonth(year, month);
              }
        if(phase.Month_17__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_17__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);


            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_18__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_18__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_18__c = 0;
                  else
                      phase.Month_18__c = date.daysInMonth(year, month);
              }
        if(phase.Month_18__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_18__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_19__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_19__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_19__c = 0;
                  else
                      phase.Month_19__c = date.daysInMonth(year, month);
              }
        if(phase.Month_19__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_19__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
  

            year = getNextYear(month, year);
            month = getNextMonth(month);



            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_20__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_20__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_20__c = 0;
                  else
                      phase.Month_20__c = date.daysInMonth(year, month);
              }
        if(phase.Month_20__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_20__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);


            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_21__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_21__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_21__c = 0;
                  else
                      phase.Month_21__c = date.daysInMonth(year, month);
              }
        if(phase.Month_21__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_21__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);



            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_22__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_22__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_22__c = 0;
                  else
                      phase.Month_22__c = date.daysInMonth(year, month);
              }
        if(phase.Month_22__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_22__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);



            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_23__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_23__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_23__c = 0;
                  else
                      phase.Month_23__c = date.daysInMonth(year, month);
              }
        if(phase.Month_23__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_23__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }  
            }

            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_24__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_24__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_24__c = 0;
                  else
                      phase.Month_24__c = date.daysInMonth(year, month);
              }
        if(phase.Month_24__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_24__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_25__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_25__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_25__c = 0;
                  else
                      phase.Month_25__c = date.daysInMonth(year, month);
              }
        if(phase.Month_25__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_25__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_26__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_26__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_26__c = 0;
                  else
                      phase.Month_26__c = date.daysInMonth(year, month);
              }
        if(phase.Month_26__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_26__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_27__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_27__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_27__c = 0;
                  else
                      phase.Month_27__c = date.daysInMonth(year, month);
              }
        if(phase.Month_27__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_27__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_28__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_28__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_28__c = 0;
                  else
                      phase.Month_28__c = date.daysInMonth(year, month);
              }
        if(phase.Month_28__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_28__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_29__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_29__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_29__c = 0;
                  else
                      phase.Month_29__c = date.daysInMonth(year, month);
              }
        if(phase.Month_29__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_29__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_30__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_30__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_30__c = 0;
                  else
                      phase.Month_30__c = date.daysInMonth(year, month);
              }
        if(phase.Month_30__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_30__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_31__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_31__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_31__c = 0;
                  else
                      phase.Month_31__c = date.daysInMonth(year, month);
              }
        if(phase.Month_31__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_31__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_32__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_32__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_32__c = 0;
                  else
                      phase.Month_32__c = date.daysInMonth(year, month);
              }
        if(phase.Month_32__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_32__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_33__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_33__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_33__c = 0;
                  else
                      phase.Month_33__c = date.daysInMonth(year, month);
              }
        if(phase.Month_33__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_33__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_34__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_34__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_34__c = 0;
                  else
                      phase.Month_34__c = date.daysInMonth(year, month);
              }
        if(phase.Month_34__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_34__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_35__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_35__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_35__c = 0;
                  else
                      phase.Month_35__c = date.daysInMonth(year, month);
              }
        if(phase.Month_35__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_35__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }
            }
            year = getNextYear(month, year);
            month = getNextMonth(month);

            if (month != phase.End_Date__c.Month() && year <= phase.End_Date__c.Year() && !flag)
                phase.Month_36__c = 0;
            else{
              if (!flag && year == phase.End_Date__c.Year()) {
                  phase.Month_36__c = date.daysInMonth(year1, month1) - day1 + 1;
                  flag = true;
              } else {
                  if (phase.End_Date__c.Year() > year)
                      phase.Month_36__c = 0;
                  else
                      phase.Month_36__c = date.daysInMonth(year, month);
              }
        if(phase.Month_36__c > 0 && !oneTimeChargesApplied){
          phase.One_Time_Revenue_36__c = phase.Phase_Revenue_One_Time__c;
              oneTimeChargesApplied = true;
            }  
            }
            //month = getNextMonth(month);
            //year = getNextYear(month, year);




            //day = phase.End_Date__c.Day();
            //phase.Month_13__c = day - 1;
        }

        return phase;
    }


    public static List < boolean > getActiveMonthList(Date oppClosedDate, String currentYear) {
        List < String > months1 = new List < String > ();
        List < boolean > activeMonth = new List < boolean > ();
        Integer month = oppClosedDate.month();
        Integer current = 0;
        List < String > months = new List < String > ();
        months.add('Jan');
        months.add('Feb');
        months.add('March');
        months.add('April');
        months.add('May');
        months.add('June');
        months.add('July');
        months.add('August');
        months.add('Sept');
        months.add('Octr');
        months.add('Nov');
        months.add('Dec');


        if (currentYear != null && currentYear != 'All')
            current = Integer.valueof(currentYear);

        Integer year = oppClosedDate.Year();
        Integer monthn = oppClosedDate.Month();
        Integer yearStart = oppClosedDate.Year();

        Integer counter = 1;
        for (Integer i = month - 1; i < 12; i++) {
            System.debug('NKC debug i [' + i + ']');



            if (year != current && currentYear != 'All')
                activeMonth.add(false);
            else
                activeMonth.add(true);

            year = getNextYear(monthn, year);
            monthn = getNextMonth(monthn);



            if (i >= 11) {
                i = -1;

            }
            counter++;

            if (counter > 36)
                break;

        }

        return activeMonth;
    }

    public static List < String > getMonthList(Date oppClosedDate) {
        List < String > months1 = new List < String > ();
        Integer month = oppClosedDate.month();
        List < String > months = new List < String > ();
        months.add('Jan');
        months.add('Feb');
        months.add('March');
        months.add('April');
        months.add('May');
        months.add('June');
        months.add('July');
        months.add('August');
        months.add('Sept');
        months.add('Octr');
        months.add('Nov');
        months.add('Dec');

        Integer year = oppClosedDate.Year();
        Integer monthn = oppClosedDate.Month();
        Integer yearStart = oppClosedDate.Year();

        Integer counter = 1;
        for (Integer i = month - 1; i < 36; i++) {
            System.debug('NKC debug i [' + i + ']');
            months1.add(months[i] + '-' + year);
            year = getNextYear(monthn, year);
            monthn = getNextMonth(monthn);
            if (i >= 11) {
                i = -1;
            }
            if (counter > 36)
                break;

            counter++;
        }

        return months1;
    }

    private static Integer getNextMonth(Integer month) {
        month++;
        if (month > 12)
            month = 1;
        return month;
    }

    private static Integer getNextYear(Integer month, Integer year) {
        if (month == 12)
            year++;
        return year;
    }

    public static List < QuoteRevenueForecastController.wrapperStatusMatrix > populateStatusMatrix(Cloud_Billing_Information__c cloudBillingForecast) {
        List < QuoteRevenueForecastController.wrapperStatusMatrix > statusMatrix = new List < QuoteRevenueForecastController.wrapperStatusMatrix > ();

        //SOW Execution
        QuoteRevenueForecastController.wrapperStatusMatrix newStatus = new QuoteRevenueForecastController.wrapperStatusMatrix();
        newStatus.statusType = 'SOW Execution';
        Integer noOfDaysBetween;
        boolean completedFlag = false;

        if (cloudBillingForecast.Opportunity_Close_Date__c != null) {

            if (cloudBillingForecast.SOW_Execution_Date__c != null) {

                if (cloudBillingForecast.SOW_Execution_Date__c < Date.today())
                    completedFlag = true;

                noOfDaysBetween = cloudBillingForecast.Opportunity_Close_Date__c.daysBetween(cloudBillingForecast.SOW_Execution_Date__c);
            } else {

                noOfDaysBetween = cloudBillingForecast.Opportunity_Close_Date__c.daysBetween(Date.today());
            }


            if (noOfDaysBetween == 0) {
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else if (noOfDaysBetween > 30) {
                newStatus.status = 'Red';
                newStatus.color = RED;
            } else if (noOfDaysBetween > 7) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            } else if (noOfDaysBetween > 0) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            }

            if (completedFlag) {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Completed: ' + String.valueOf(noOfDaysBetween) + ' days past Close Date';
                newStatus.previousColor = newStatus.color;
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Pending: ' + String.valueOf(noOfDaysBetween) + ' days past Close Date';
                newStatus.previousColor = newStatus.color;

            }
            //newStatus.status += ' (' + String.valueOf(noOfDaysBetween) + ')';
        }

        statusMatrix.add(newStatus);

        //Professional Services PM Assigned
        newStatus = new QuoteRevenueForecastController.wrapperStatusMatrix();
        newStatus.statusType = 'Professional Services PM Assigned';
        completedFlag = false;

        if (cloudBillingForecast.PM_Assigned__c != null) {
            if (cloudBillingForecast.PM_Assigned__c < Date.today())
                completedFlag = true;
            noOfDaysBetween = cloudBillingForecast.Opportunity_Close_Date__c.daysBetween(cloudBillingForecast.PM_Assigned__c);
        } else {
            System.debug('SDate' + cloudBillingForecast.Opportunity_Close_Date__c);
            noOfDaysBetween = cloudBillingForecast.Opportunity_Close_Date__c.daysBetween(Date.today());

        }


        if (cloudBillingForecast.Opportunity_Close_Date__c != null) {
            //noOfDaysBetween = cloudBillingForecast.PM_Assigned__c.daysBetween(cloudBillingForecast.Close_Date__c);
            if (noOfDaysBetween == 0) {
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else if (noOfDaysBetween > 20) {
                newStatus.status = 'Red';
                newStatus.color = RED;
            } else if (noOfDaysBetween > 5) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            } else if (noOfDaysBetween > 0) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            }


            if (completedFlag) {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Completed: ' + String.valueOf(noOfDaysBetween) + ' days past Close Date';
                newStatus.previousColor = newStatus.color;
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Pending: ' + String.valueOf(noOfDaysBetween) + ' days past Close Date';
                newStatus.previousColor = newStatus.color;

            }
            //newStatus.status += ' (' + String.valueOf(noOfDaysBetween) + ')';
        }
        statusMatrix.add(newStatus);
        //Discovery Phase Complete
        newStatus = new QuoteRevenueForecastController.wrapperStatusMatrix();
        newStatus.statusType = 'Discovery Phase Complete';
        completedFlag = false;

        if (cloudBillingForecast.Discovery_Phase_Complete__c != null) {
            if (cloudBillingForecast.Discovery_Phase_Complete__c < Date.today())
                completedFlag = true;
            if (cloudBillingForecast.SOW_Execution_Date__c != null)
                noOfDaysBetween = cloudBillingForecast.SOW_Execution_Date__c.daysBetween(cloudBillingForecast.Discovery_Phase_Complete__c);
            else
                noOfDaysBetween = 0;
        } else {
            noOfDaysBetween = cloudBillingForecast.Opportunity_Close_Date__c.daysBetween(Date.today());
        }


        if (cloudBillingForecast.SOW_Execution_Date__c != null) {
            //noOfDaysBetween = cloudBillingForecast.SOW_Execution_Date__c.daysBetween(cloudBillingForecast.Discovery_Phase_Complete__c);
            if (noOfDaysBetween <= 10) {
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else if (noOfDaysBetween > 30) {
                newStatus.status = 'Red';
                newStatus.color = RED;
            } else if (noOfDaysBetween > 20) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            } else if (noOfDaysBetween > 10) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            }

            if (completedFlag) {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Completed: ' + String.valueOf(noOfDaysBetween) + ' days past SOW Execution Date';
                newStatus.previousColor = newStatus.color;
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Pending: ' + String.valueOf(noOfDaysBetween) + ' days past SOW Execution Date';
                newStatus.previousColor = newStatus.color;

            }

            //newStatus.status += ' (' + String.valueOf(noOfDaysBetween) + ')';
        }
        statusMatrix.add(newStatus);

        //Design Phase Complete
        newStatus = new QuoteRevenueForecastController.wrapperStatusMatrix();
        newStatus.statusType = 'Design Phase Complete';
        completedFlag = false;

        if (cloudBillingForecast.Design_Phase_Completed__c != null) {
            if (cloudBillingForecast.Design_Phase_Completed__c < Date.today())
                completedFlag = true;
            if (cloudBillingForecast.Discovery_Phase_Complete__c != null)
                noOfDaysBetween = cloudBillingForecast.Discovery_Phase_Complete__c.daysBetween(cloudBillingForecast.Design_Phase_Completed__c);
            else
                noOfDaysBetween = 0;
        } else {
            if (cloudBillingForecast.Design_Phase_Completed__c != null)
                noOfDaysBetween = cloudBillingForecast.Design_Phase_Completed__c.daysBetween(Date.today());
        }


        if (cloudBillingForecast.Discovery_Phase_Complete__c != null) {
            //noOfDaysBetween = cloudBillingForecast.Discovery_Phase_Complete__c.daysBetween(cloudBillingForecast.Design_Phase_Completed__c);     
            if (noOfDaysBetween <= 10) {
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else if (noOfDaysBetween > 30) {
                newStatus.status = 'Red';
                newStatus.color = RED;
            } else if (noOfDaysBetween > 20) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            } else if (noOfDaysBetween > 10) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            }


            if (completedFlag) {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Completed: ' + String.valueOf(noOfDaysBetween) + ' days past Discovery Phase Complete Date';
                newStatus.previousColor = newStatus.color;
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Pending: ' + String.valueOf(noOfDaysBetween) + ' days past Discovery Phase Complete Date';
                newStatus.previousColor = newStatus.color;

            }


            //newStatus.status += ' (' + String.valueOf(noOfDaysBetween) + ')';
        }
        statusMatrix.add(newStatus);
        //Technical Requirements Documents Complete
        newStatus = new QuoteRevenueForecastController.wrapperStatusMatrix();
        newStatus.statusType = 'Technical Requirements Documents Complete';
        completedFlag = false;

        if (cloudBillingForecast.Technical_Requirements_Completion_Date__c != null) {
            if (cloudBillingForecast.Technical_Requirements_Completion_Date__c < Date.today())
                completedFlag = true;
            if (cloudBillingForecast.Design_Phase_Completed__c != null)
                noOfDaysBetween = cloudBillingForecast.Design_Phase_Completed__c.daysBetween(cloudBillingForecast.Technical_Requirements_Completion_Date__c);
        } else {
            if (cloudBillingForecast.Discovery_Phase_Complete__c != null)
                noOfDaysBetween = cloudBillingForecast.Discovery_Phase_Complete__c.daysBetween(Date.today());
        }


        if (cloudBillingForecast.Design_Phase_Completed__c != null) {


            //noOfDaysBetween = cloudBillingForecast.Design_Phase_Completed__c.daysBetween(cloudBillingForecast.Technical_Requirements_Completion_Date__c);

            if (noOfDaysBetween <= 5) {
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else if (noOfDaysBetween > 20) {
                newStatus.status = 'Red';
                newStatus.color = RED;
            } else if (noOfDaysBetween > 10) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            } else if (noOfDaysBetween > 6) {
                newStatus.status = 'Yellow';
                newStatus.color = YELLOW;
            }

            if (completedFlag) {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Completed: ' + String.valueOf(noOfDaysBetween) + ' days past Design Phase Completed Date';
                newStatus.previousColor = newStatus.color;
                newStatus.status = 'Green';
                newStatus.color = GREEN;
            } else {
                newStatus.previousStatus = newStatus.status;
                newStatus.statusText = 'Pending: ' + String.valueOf(noOfDaysBetween) + ' days past Design Phase Completed Date ';
                newStatus.previousColor = newStatus.color;

            }
            //newStatus.status += ' (' + String.valueOf(noOfDaysBetween) + ')';
        }
        statusMatrix.add(newStatus);

        return statusMatrix;
    }

    public static void revenueHistoryUpdate(Map < Id, Cloud_Billing_Phase__c > oldMap, List < Cloud_Billing_Phase__c > newList) {
        List < Cloud_Billing_Phase_History__c > newHistoryList = new List < Cloud_Billing_Phase_History__c > ();
        Cloud_Billing_Phase_History__c newHistory;
        boolean isUpdate = false;
        Integer noOfDaysBetween;
        Decimal revenueChange;

        for (Cloud_Billing_Phase__c cNew: newList) {
            newHistory = new Cloud_Billing_Phase_History__c();
            Cloud_Billing_Phase__c beforeUpdate = oldMap.get(cNew.Id);
            newHistory.Cloud_Billing_Phase__c = beforeUpdate.id;
            newHistory.Phase_Classification__c = cNew.Phase_Classification__c;
            newHistory.Old_End_Date__c = beforeUpdate.End_Date__c;
            newHistory.New_End_date__c = cNew.End_Date__c;
            newHistory.Old_Phase_Revenue__c = beforeUpdate.Phase_Revenue__c;
            newHistory.New_Phase_Revenue__c = cNew.Phase_Revenue__c;

            if (beforeUpdate.Phase_Revenue__c != cNew.Phase_Revenue__c) {
                isUpdate = true;
                revenueChange = (cNew.Phase_Revenue__c - beforeUpdate.Phase_Revenue__c);
                newHistory.Revenue_Change__c = revenueChange;

                if (revenueChange >= -25000) {
                    newHistory.Revenue_Change_Status__c = 'Green';
                }

                if (revenueChange > -25000 && revenueChange <= -30000) {
                    newHistory.Revenue_Change_Status__c = 'Yellow';
                }

                if (revenueChange <= -60000) {
                    newHistory.Revenue_Change_Status__c = 'Red';
                }


            }

            if (beforeUpdate.End_date__c != cNew.End_date__c) {

                isUpdate = true;
                noOfDaysBetween = beforeUpdate.End_date__c.daysBetween(cNew.End_date__c);
                newHistory.Phase_Date_Change__c = noOfDaysBetween;

                if (noOfDaysBetween <= 29) {
                    newHistory.Phase_Date_Change_Status__c = 'Green';
                }

                if (noOfDaysBetween > 30 && noOfDaysBetween < 60) {
                    newHistory.Phase_Date_Change_Status__c = 'Green';
                }

                if (noOfDaysBetween >= 60) {
                    newHistory.Phase_Date_Change_Status__c = 'Red';
                }
            }



            if (isUpdate)
                newHistoryList.add(newHistory);


            isUpdate = false;
        }
        insert newHistoryList;

    }


    public static void informationHistoryUpdate(Map < Id, Cloud_Billing_Information__c > oldMap, List < Cloud_Billing_Information__c > newList) {
        List < Cloud_Forecast_Information_History__c > newHistoryList = new List < Cloud_Forecast_Information_History__c > ();
        Cloud_Forecast_Information_History__c newHistory;
        boolean isUpdate = false;
        Integer noOfDaysBetween;
        Decimal revenueChange;

        for (Cloud_Billing_Information__c cNew: newList) {

            Cloud_Billing_Information__c beforeUpdate = oldMap.get(cNew.Id);

            if (beforeUpdate.SOW_Execution_Date__c != cNew.SOW_Execution_Date__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.SOW_Execution_Date__c;
                newHistory.New_date__c = cNew.SOW_Execution_Date__c;
                newhistory.Field__c = 'SOW Execution Date';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.Actual_Go_Live_Date__c != cNew.Actual_Go_Live_Date__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.Actual_Go_Live_Date__c;
                newHistory.New_date__c = cNew.Actual_Go_Live_Date__c;
                newhistory.Field__c = 'Actual Go Live Date';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.Forecasted_Go_Live_Date_At_SOW_Signatu__c != cNew.Forecasted_Go_Live_Date_At_SOW_Signatu__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.Forecasted_Go_Live_Date_At_SOW_Signatu__c;
                newHistory.New_date__c = cNew.Forecasted_Go_Live_Date_At_SOW_Signatu__c;
                newhistory.Field__c = 'Forecasted Go-Live Date At SOW Signature';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.Forecasted_Go_Live_Date_Projected__c != cNew.Forecasted_Go_Live_Date_Projected__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.Forecasted_Go_Live_Date_Projected__c;
                newHistory.New_date__c = cNew.Forecasted_Go_Live_Date_Projected__c;
                newhistory.Field__c = 'Forecasted Go-Live Date - Projected';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.Discovery_Phase_Complete__c != cNew.Discovery_Phase_Complete__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.Discovery_Phase_Complete__c;
                newHistory.New_date__c = cNew.Discovery_Phase_Complete__c;
                newhistory.Field__c = 'Discovery Phase Complete';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }


            if (beforeUpdate.Technical_Requirements_Completion_Date__c != cNew.Technical_Requirements_Completion_Date__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.Technical_Requirements_Completion_Date__c;
                newHistory.New_date__c = cNew.Technical_Requirements_Completion_Date__c;
                newhistory.Field__c = 'Technical Requirements Completion Date';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.SOW_Fully_Delivered_Date_Actual__c != cNew.SOW_Fully_Delivered_Date_Actual__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.SOW_Fully_Delivered_Date_Actual__c;
                newHistory.New_date__c = cNew.SOW_Fully_Delivered_Date_Actual__c;
                newhistory.Field__c = 'SOW Fully Delivered Date - Actual';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.SOW_Fully_Delivered_Date_Forecasted__c != cNew.SOW_Fully_Delivered_Date_Forecasted__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.SOW_Fully_Delivered_Date_Forecasted__c;
                newHistory.New_date__c = cNew.SOW_Fully_Delivered_Date_Forecasted__c;
                newhistory.Field__c = 'SOW Fully Delivered Date - Forecasted';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }

            if (beforeUpdate.Design_Phase_Completed__c != cNew.Design_Phase_Completed__c) {
                newHistory = new Cloud_Forecast_Information_History__c();

                newHistory.Cloud_Forecast_Information__c = beforeUpdate.id;
                newHistory.Old_Date__c = beforeUpdate.Design_Phase_Completed__c;
                newHistory.New_date__c = cNew.Design_Phase_Completed__c;
                newhistory.Field__c = 'Design Phase Completed';
                newHistoryList.add(newHistory);
                isUpdate = true;
            }


        }

        if (isUpdate)
            insert newHistoryList;

    }

}