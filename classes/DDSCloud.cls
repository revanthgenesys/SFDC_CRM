/************************************************************************************
Purpose : Class to calculate raw score
Written By : Anto Carmel
Test Classes : DDSCloudTest
*************************************************************************************/

public without sharing class DDSCloud {

public List<BigMachines__Quote_Product__c>list_BigMachineQuoteProductsforAdjustment{get; set;}
//public static Decimal decPartnerScore {get;set;}

//Mukunth added below variable for DDS337 on 26-JUN-2019
private static decimal decPCPartnerMargin = -7777;

/** Method to calculate raw score**/
public static DDSCloudModel calculateRawScore(BigMachines__Quote__c objQuote) {
    DDSCloudModel objDDS;
    List<BigMachines__Quote_Product__c> list_BigMachinesQuoteProducts;
    list_BigMachinesQuoteProducts = [SELECT Id,BigMachines__Product__r.Name,BigMachines__Product__r.Unit_of_Measure__c, BigMachines__Product__r.Taxonomy_Solution__c,
                                         Extended_Price_Per_Month__c, List_Price__c, BigMachines__Quantity__c,BigMachines__Product__r.ProductSubFamily__c,
                                         BigMachines__Product__r.APN_Number__c, BigMachines__Quote__r.Offering_Type__c,BigMachines__Product__r.Type__c,
                                         BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Product__r.Third_Party__c,BigMachines__Product__r.Product_Specific_Discount__c,Total_Discount__c,BigMachines__Product__r.Product_Group__c,BigMachines__Product__r.New_Category__c,
                                         BigMachines__Product__r.Product_Sub_category__c, BigMachines__Product__r.Sub_Category__c,Partner_Price__c,Disc__c,Discount__c, BigMachines__Quote__r.No_Of_Months__c
                                         FROM BigMachines__Quote_Product__c
                                         WHERE BigMachines__Quote__c = :objQuote.Id AND Hide_Record__c = FALSE AND Is_Overage__c = FALSE];

   try {
        //Mukunth added below if condition for DDS337
        if(objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect' && objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
            decPCPartnerMargin = fetchPCPartnerMargin(objQuote.Sold_To_Name__c);

        System.Debug('decPCPartnerMargin--->'+decPCPartnerMargin);
        //Mukunth code end
       
        objDDS = buildDDSCloudModel(objQuote,list_BigMachinesQuoteProducts);
        if(!objDDS.blnOnlyThirdPartyandHardwareQuote){
             Decimal decFinalScore = fetchRawScore(objQuote.Offering_Type__c,objDDS);
             system.debug('decFinalScore--' + decFinalScore);
             objQuote.Deal_Score__c = decFinalScore != 0 ? decFinalScore:null;
             objQuote.ACV_List_Price__c = objDDS.decDealSize;
        }
        else{
            Decimal decFinalScore = fetchThirdPartyandHardwareScore(objQuote,list_BigMachinesQuoteProducts);
             objQuote.Deal_Score__c = decFinalScore != 0 ? decFinalScore:null;
        } 

        objDDS.objDealScoreHistory = createDDSScoreHistory(objDDS,objQuote.Id,objQuote.Deal_Score__c);
        objQuote.Compensation_Multiplier__c = getDDSCompensation(objQuote);
        objQuote.Third_Party_Discount__c = objDDS.objScoreAdjustment.decThirdpartyDiscount;
        //For score = partner baseline discount
        //objQuote.Score__c = decPartnerScore;
        system.debug('objQuoteValue--' + objQuote.Deal_Score__c);

        update objQuote;
    } catch (Exception e) {
        system.debug('objQuoteValue exception' + e);
    }
    return objDDS;

}
/** Method to build DDSCloudModel with all the values to query the data from DDS Cloud Master Object**/
@TestVisible 
private static DDSCloudModel buildDDSCloudModel(BigMachines__Quote__c objQuote,List<BigMachines__Quote_Product__c> list_BigMachinesQuoteProducts) {
    system.debug('invoked DDS Model');
    List<String>list_UOMCategoryDiscount = fetchUnitofMeasureCategoryandDiscount(objQuote,list_BigMachinesQuoteProducts);
    system.debug('Substep');
    DDSCloudModel objDDS = new DDSCloudModel();
    if (objQuote.Offering_Type__c == 'Business Edition') {
        objDDS.strOfferingType = 'PureEngage Cloud';
    } else
        objDDS.strOfferingType = objQuote.Offering_Type__c;

    objDDS.strRegion = objQuote.CurrencyIsoCode;
    if (objQuote.Offering_Type__c == 'Business Edition' && objQuote.BigMachines__Opportunity__r.Type == 'New Logo') {
        objDDS.strDealType = 'New Subscription';
    } else if (objQuote.Offering_Type__c == 'Business Edition') {
        objDDS.strDealType = 'Amend Subscription';
    } else {
        objDDS.strDealType = objQuote.order_type__c;
    }

    objDDS.strDirectIndirect = objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c;
    objDDS.strDirectIndirectUI = objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c;
    objDDs.decDiscount = Decimal.valueOf(list_UOMCategoryDiscount[0]).round(System.RoundingMode.HALF_UP);
    objDDS.decDealSize =converttoUSD(objQuote.Offering_Type__c,objQuote.New_Price_Book__c,objQuote.CurrencyIsoCode,Decimal.valueOf(list_UOMCategoryDiscount[1]));
    objDDS.objScoreAdjustment = new ScoreAdjustment();
    objDDS.objScoreAdjustment.decRawScore = Decimal.valueOf(list_UOMCategoryDiscount[0]).round(System.RoundingMode.HALF_UP);
    objDDS.objScoreAdjustment.decThirdpartyDiscount = Decimal.valueOf(list_UOMCategoryDiscount[2]).round(System.RoundingMode.HALF_UP);
    objDDS.objScoreAdjustment.decMaxDiscount = Decimal.valueOf(list_UOMCategoryDiscount[3]).round(System.RoundingMode.HALF_UP);
    objDDS.objScoreAdjustment.decHardwareDiscount = Decimal.valueof(list_UOMCategoryDiscount[4]).round(System.RoundingMode.HALF_UP);
    objDDS.objScoreAdjustment.decPSDiscount = Decimal.valueOf(list_UOMCategoryDiscount[5]).round(System.RoundingMode.HALF_UP);
    objDDS.objScoreAdjustment.decContractualDiscount = Decimal.valueof(list_UOMCategoryDiscount[6]).round(System.RoundingMode.HALF_UP);
    System.debug(list_UOMCategoryDiscount[12]+' '+objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c+' '+objDDS.strDirectIndirectUI);
    if(Decimal.valueof(list_UOMCategoryDiscount[12]).round(System.RoundingMode.HALF_UP) == 0 && objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect'){
        objDDS.strDirectIndirect = 'Direct';
        objDDS.strDirectIndirectUI = objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c + ' without partner margin';
    }
    objDDS.objScoreAdjustment.decThirdPartyImpact = Decimal.valueof(list_UOMCategoryDiscount[7]);
    objDDS.objScoreAdjustment.decHardwareImpact = Decimal.valueof(list_UOMCategoryDiscount[8]);
    objDDS.objScoreAdjustment.decPSImpact = Decimal.valueOf(list_UOMCategoryDiscount[9]);
    objDDS.objScoreAdjustment.decMaxLicenseImpact = Decimal.valueOf(list_UOMCategoryDiscount[10]);
    objDDS.objScoreAdjustment.decScoreImpact = Decimal.valueOf(list_UOMCategoryDiscount[11]);
    objDDS.objContractualDiscount = new ContractualDiscount();
    System.Debug('list_UOMCategoryDiscount[12]--->'+list_UOMCategoryDiscount[12]);
    objDDS.objContractualDiscount.decPartnerDiscount =  Decimal.valueof(list_UOMCategoryDiscount[12]).round(System.RoundingMode.HALF_UP);
    objDDS.objContractualDiscount.decDealRegistrationDiscount = Decimal.valueof(list_UOMCategoryDiscount[13]).round(System.RoundingMode.HALF_UP);
    objDDS.objContractualDiscount.decCustomerDiscount = Decimal.valueof(list_UOMCategoryDiscount[14]).round(System.RoundingMode.HALF_UP);
    objDDS.decDealSizeOrginal = Decimal.valueof(list_UOMCategoryDiscount[15]);
    objDDS.blnOnlyThirdPartyandHardwareQuote = Boolean.valueOf(list_UOMCategoryDiscount[16]);

    return objDDS;

}
/** Mehtod to calculate Raw Score **/
@TestVisible 
private static Decimal fetchRawScore(String offeringType,DDSCloudModel objDDSCloud) {
    DDS_Cloud_Master__c objDDSCloudMaster = new DDS_Cloud_Master__c();
    Decimal decScore = 0;
    System.debug('Cloud Model -- ' + objDDSCloud);
    
    try {
        objDDSCloudMaster = queryBuilder(offeringType,objDDSCloud);
        system.debug('objDDSCloudMaster --' + objDDSCloudMaster);
        system.debug('objDDSCloud.decDiscount --' + objDDSCloud.decDiscount);
        if(objDDSCloud.strDirectIndirect == 'Direct' ||(objDDSCloud.strDirectIndirect == 'Indirect' && objDDSCloud.strOfferingType == 'PureEngage Cloud')){
            System.debug('objDDSCloudMaster  --'+objDDSCloudMaster );
            if (objDDSCloudMaster != null) {
                System.debug('decScore  --'+decScore );
                objDDSCloud.list_CutoffDisplay = buildCuttoffDisplay(objDDSCloudMaster);
                System.debug('Cuttoff Display --'+objDDSCloud.list_CutoffDisplay);
                if (objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_5__c) {
                    decScore = 5;
                } else if (objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_4__c) {
                    decScore = 4;
                } else if (objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_3__c) {
                    decScore = 3;
                } else if (objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_2__c) {
                    decScore = 2;
                } else {
                    decScore = 1;
                }
                objDDSCloud.decScoreForRawScore = decScore;
            }
            else {
                return decScore;
            }
            Decimal decContractualAdjustment = contractualAdjustment(objDDSCloudMaster,objDDSCloud);
            System.debug('Contractual--'+decContractualAdjustment);
            decScore = decContractualAdjustment == 0 ? decScore : decContractualAdjustment;
            objDDSCloud.decScoreAfterContractualAdjustment = decScore;
        }
        else if((objDDSCloud.strDirectIndirect == 'Indirect' && objDDSCloud.strOfferingType != 'PureEngage Cloud')){
            System.Debug('Indirect--->');
            if (objDDSCloudMaster != null) {
                objDDSCloud.list_CutoffDisplay = buildCuttoffDisplayforIndirect(objDDSCloudMaster,objDDSCloud);
                //max discount = max between partner discount+deal reg discount and contractual discount
                //-111 means discount = max discount 
                //-999 means discount < max discount 
                //-222 means discount <= max discount 
                Decimal decMaxOfPartnerAndCustomerDisc = Math.max(objDDSCloud.objContractualDiscount.decPartnerDiscount, objDDSCloud.objContractualDiscount.decCustomerDiscount);
                System.Debug('Partner Disc--->'+objDDSCloud.objContractualDiscount.decPartnerDiscount);
                System.Debug('Contractual--->'+objDDSCloud.objContractualDiscount.decCustomerDiscount);
                System.Debug('decMaxOfPartnerAndCustomerDisc--->'+decMaxOfPartnerAndCustomerDisc);
                Decimal decOffset5 = objDDSCloudMaster.Offset_5__c == null? 0.00:objDDSCloudMaster.Offset_5__c;
                if ((objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_5__c && objDDSCloudMaster.Cutoff_5__c != -999 && objDDSCloudMaster.Cutoff_5__c != -111 && objDDSCloudMaster.Cutoff_4__c != -222)
                    || (objDDSCloudMaster.Cutoff_5__c == -999 && objDDSCloud.decDiscount < decMaxOfPartnerAndCustomerDisc)
                    || (objDDSCloudMaster.Cutoff_5__c == -111 && objDDSCloud.decDiscount == decMaxOfPartnerAndCustomerDisc)
                    || (objDDSCloudMaster.Cutoff_5__c == -222 && objDDSCloud.decDiscount <= (decMaxOfPartnerAndCustomerDisc+decOffset5))) {//Mukunth added Offset_5 to this line for DDS337
                    decScore = 5;
                }
                else if((objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_4__c && objDDSCloudMaster.Cutoff_4__c != -999 && objDDSCloudMaster.Cutoff_4__c != -111 && objDDSCloudMaster.Cutoff_4__c != -222)
                        || (objDDSCloudMaster.Cutoff_4__c == -999 && objDDSCloud.decDiscount < decMaxOfPartnerAndCustomerDisc)
                        || (objDDSCloudMaster.Cutoff_4__c == -111 && objDDSCloud.decDiscount == decMaxOfPartnerAndCustomerDisc)
                        || (objDDSCloudMaster.Cutoff_4__c == -222 && objDDSCloud.decDiscount <= (decMaxOfPartnerAndCustomerDisc+objDDSCloudMaster.Offset_4__c))){
                    decScore = 4;
                }
                else if((objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_3__c && objDDSCloudMaster.Cutoff_3__c != -999 && objDDSCloudMaster.Cutoff_3__c != -111 && objDDSCloudMaster.Cutoff_3__c != -222)
                        || (objDDSCloudMaster.Cutoff_3__c == -999 && objDDSCloud.decDiscount < decMaxOfPartnerAndCustomerDisc)
                        || (objDDSCloudMaster.Cutoff_3__c == -111 && objDDSCloud.decDiscount == decMaxOfPartnerAndCustomerDisc)
                        || (objDDSCloudMaster.Cutoff_3__c == -222 && objDDSCloud.decDiscount <= (decMaxOfPartnerAndCustomerDisc+objDDSCloudMaster.Offset_3__c))){
                    decScore = 3;
                }
                else if((objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_2__c &&  objDDSCloudMaster.Cutoff_2__c != -222) 
                        || (objDDSCloudMaster.Cutoff_2__c == -222 && objDDSCloud.decDiscount <= (decMaxOfPartnerAndCustomerDisc+objDDSCloudMaster.Offset_2__c))){
                    decScore = 2;
                }
                else{
                    decScore = 1;
                }
                objDDSCloud.decScoreForRawScore = decScore;
                System.Debug('decScore--->'+decScore);
            }
            else {
                return decScore;
            }
        }            
        objDDSCloud.decScoreAfterAllAdjustment = decScore+objDDSCloud.objScoreAdjustment.decScoreImpact;
        if(objDDSCloud.decScoreAfterAllAdjustment < 1){
            return 1;
        }
        return ((objDDSCloud.decScoreAfterAllAdjustment).round(System.RoundingMode.HALF_UP));
    }
    catch (Exception e) {
        System.debug('fetchRawScore Exception ----' +e);
        return decScore;
    }
    return null;
}
/** Method to fetch raw score from DDS Cloud Master Object **/
@TestVisible 
private static Decimal contractualAdjustment(DDS_Cloud_Master__c objDDSCloudMaster,DDSCloudModel objDDSCloud) {
    //DDS_Cloud_Master__c objDDSCloudMaster = new DDS_Cloud_Master__c();
    Decimal decScore =0;
   Decimal decContractualDiscount = objDDSCloud.objScoreAdjustment.decContractualDiscount;
        //Decimal decContractualDiscount = 45;
    try{
        if (objDDSCloudMaster != null) {
            if (objDDSCloud.decDiscount <= decContractualDiscount && (decContractualDiscount <= objDDSCloudMaster.Cutoff_5__c || decContractualDiscount <= objDDSCloudMaster.Cutoff_4__c || objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_5__c)&&objDDSCloudMaster.Cutoff_5__c != -888) {
                decScore = 5;
            } else if (objDDSCloud.decDiscount <= decContractualDiscount && (objDDSCloud.decDiscount > objDDSCloudMaster.Cutoff_4__c && objDDSCloud.decDiscount <= objDDSCloudMaster.Cutoff_3__c)) {
                decScore = 4;
            } else if ((objDDSCloud.decDiscount <= decContractualDiscount && objDDSCloud.decDiscount > objDDSCloudMaster.Cutoff_3__c)) {
                decScore = 3;
            }
        }
        return decScore;
    } catch (Exception e) {

        return decScore;
    }

    return null;
}
/** Method to build Cutoff display**/
@TestVisible 
private static List<CutoffDisplay> buildCuttoffDisplay(DDS_Cloud_Master__c objDDSCloudMaster){

   List<CutoffDisplay> list_CuttOffDisplay = new List<CutoffDisplay>();

    for(Integer int_i = 5;int_i<=5&&int_i>0;int_i-- ){
        CutoffDisplay objCutoffDisplay = new CutoffDisplay();
        if(int_i == 5 && objDDSCloudMaster.Cutoff_5__c != -888){
            objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_5__c);
            objCutoffDisplay.strRange = '<=';
            objCutoffDisplay.strDealScore = String.valueOf(int_i);
        }
        if(int_i == 4){
            objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_4__c);
            objCutoffDisplay.strRange = '<=';
            objCutoffDisplay.strDealScore = String.valueOf(int_i);
        }
        if(int_i == 3){
            objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_3__c);
            objCutoffDisplay.strRange = '<=';
            objCutoffDisplay.strDealScore = String.valueOf(int_i);
        }
        if(int_i == 2){
            objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_2__c);
            objCutoffDisplay.strRange = '<=';
            objCutoffDisplay.strDealScore = String.valueOf(int_i);
        }
        if(int_i == 1){
            objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_2__c);
            objCutoffDisplay.strRange = '>';
            objCutoffDisplay.strDealScore = String.valueOf(int_i);
        }
        if(objCutoffDisplay.strCutoff != null && objCutoffDisplay.strCutoff != null){
            list_CuttOffDisplay.add(objCutoffDisplay);
        }
    }
    return list_CuttOffDisplay;

}

/** Method to build Cutoff display for PC Indirect **/
@TestVisible 
private static List<CutoffDisplay> buildCuttoffDisplayforIndirect(DDS_Cloud_Master__c objDDSCloudMaster,DDSCloudModel objDDSCloud){

    List<CutoffDisplay> list_CuttOffDisplay = new List<CutoffDisplay>();
    Decimal decMaxValue = Math.max(objDDSCloud.objContractualDiscount.decPartnerDiscount, objDDSCloud.objContractualDiscount.decCustomerDiscount);
    System.debug('decMaxValue  -- ' + decMaxValue);
    for(Integer int_i = 5; int_i <= 5 && int_i > 0; int_i-- ){
        CutoffDisplay objCutoffDisplay = new CutoffDisplay();
        if(int_i == 5){
            if(objDDSCloudMaster.Cutoff_5__c != -999 && objDDSCloudMaster.Cutoff_5__c != -111 && objDDSCloudMaster.Cutoff_5__c != -222 && objDDSCloudMaster.Cutoff_5__c != -888){
                objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_5__c);
                objCutoffDisplay.strRange = '<=';
            }
            else if(objDDSCloudMaster.Cutoff_5__c == -999){
                objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                objCutoffDisplay.strRange = '<';
            }
            else if(objDDSCloudMaster.Cutoff_5__c == -111){
                 objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                objCutoffDisplay.strRange = '=';
            }
            else if(objDDSCloudMaster.Cutoff_5__c == -222){
                //Mukunth added Partner Margin < 17% condition for DDS337
                if(objDDSCloudMaster.Filter_Criteria__c == 'Margin<15%'){
                    objCutoffDisplay.strCutoff = String.valueOf(decMaxValue + objDDSCloudMaster.Offset_5__c);
                    objCutoffDisplay.strRange = '<=';
                }
                else{
                    objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                    objCutoffDisplay.strRange = '<=';
                }
            }
        }
        if(int_i == 4){
            if(objDDSCloudMaster.Cutoff_4__c != -999 && objDDSCloudMaster.Cutoff_4__c != -111 && objDDSCloudMaster.Cutoff_4__c != -222 && objDDSCloudMaster.Cutoff_4__c != -888){
                objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_4__c);
                objCutoffDisplay.strRange = '<=';
            }
            else if(objDDSCloudMaster.Cutoff_4__c == -999){
                 objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                objCutoffDisplay.strRange = '<';
            }
            else if(objDDSCloudMaster.Cutoff_4__c == -111){
                 objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                objCutoffDisplay.strRange = '=';
            }
            else if(objDDSCloudMaster.Cutoff_4__c == -222){
                objCutoffDisplay.strCutoff = String.valueOf(decMaxValue+objDDSCloudMaster.Offset_4__c);
                    objCutoffDisplay.strRange = '<=';
            }
        }
        if(int_i == 3){
            if(objDDSCloudMaster.Cutoff_3__c != -999 && objDDSCloudMaster.Cutoff_3__c != -111 && objDDSCloudMaster.Cutoff_3__c != -222 && objDDSCloudMaster.Cutoff_3__c != -888){
                objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_3__c);
                objCutoffDisplay.strRange = '<=';
            }
            else if(objDDSCloudMaster.Cutoff_3__c == -999){
                 objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                objCutoffDisplay.strRange = '<';
            }
            else if(objDDSCloudMaster.Cutoff_3__c == -111){
                 objCutoffDisplay.strCutoff = String.valueOf(decMaxValue);
                    objCutoffDisplay.strRange = '=';
            }
            else if(objDDSCloudMaster.Cutoff_3__c == -222){
                objCutoffDisplay.strCutoff = String.valueOf(decMaxValue+objDDSCloudMaster.Offset_3__c);
                    objCutoffDisplay.strRange = '<=';
            }
        }
        if(int_i == 2){
            if(objDDSCloudMaster.Cutoff_2__c != -999 && objDDSCloudMaster.Cutoff_2__c != -111 && objDDSCloudMaster.Cutoff_2__c != -222){
                objCutoffDisplay.strRange = '<=';
                objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_2__c);
            }
            else if(objDDSCloudMaster.Cutoff_2__c == -222) {
                objCutoffDisplay.strRange = '<=';
                objCutoffDisplay.strCutoff = String.valueOf(decMaxValue+objDDSCloudMaster.Offset_2__c);
            }
        }

        if(int_i == 1){
            if(objDDSCloudMaster.Cutoff_2__c != -999 && objDDSCloudMaster.Cutoff_2__c != -111 && objDDSCloudMaster.Cutoff_2__c != -222){
                objCutoffDisplay.strRange = '>';
                objCutoffDisplay.strCutoff = String.valueOf(objDDSCloudMaster.Cutoff_2__c);
            }
            else if(objDDSCloudMaster.Cutoff_2__c == -222) {
                objCutoffDisplay.strRange = '>';
                objCutoffDisplay.strCutoff = String.valueOf(decMaxValue+objDDSCloudMaster.Offset_2__c);
            }
        }
        objCutoffDisplay.strDealScore = String.valueOf(int_i);
        //Hiding cutoff below partner base line
        System.debug('objCutoffDisplay.strCutoff-- ' + objCutoffDisplay.strCutoff);
        System.debug('objCutoffDisplay.strRange-- ' + objCutoffDisplay.strRange);
        if(!(Decimal.valueof(objCutoffDisplay.strCutoff) < decMaxValue || (Decimal.valueof(objCutoffDisplay.strCutoff) == decMaxValue && objCutoffDisplay.strRange == '<')))
            list_CuttOffDisplay.add(objCutoffDisplay);
    }
    System.debug('list_CuttOffDisplay-- ' + list_CuttOffDisplay);
    return list_CuttOffDisplay;

}
/** Method to build query to get DDS Cloud Master Info **/
@TestVisible 
private static DDS_Cloud_Master__c queryBuilder(String offeringType, DDSCloudModel objDDSCloud){
    List<DDS_Cloud_Master__c> list_DDSCloudMasterRecords = new List<DDS_Cloud_Master__c>();
    String strOfferingType = objDDSCloud.strOfferingType;
    String strRegion = objDDSCloud.strRegion;
    String strDealType = objDDSCloud.strDealType;
    String strDirectIndirect = objDDSCloud.strDirectIndirect;
    Decimal decDealSize = objDDSCloud.decDealSize;
    String  strUOM = objDDSCloud.strUOM;
    String strProductGroup = objDDSCloud.strProductGroup;
    String strApnNumber = objDDSCloud.strApnNumber;
    String strProductFamily = objDDSCloud.strProductFamily;

    String strQueryString = 'SELECT Id, Cutoff_2__c, Cutoff_3__c, Cutoff_4__c, Cutoff_5__c,Offset_2__c,Offset_3__c,Offset_4__c,Offset_5__c,Filter_Criteria__c FROM DDS_Cloud_Master__c WHERE Offering_Type__c = :strOfferingType AND (Deal_Size_From__c < :decDealSize AND Deal_Size_To__c >= :decDealSize)';
    if(offeringType == 'Business Edition'){offeringType = SubscriptionUtil.OFFERING_TYPE_PEC ; }
    if(offeringType == SubscriptionUtil.OFFERING_TYPE_PC || offeringType == SubscriptionUtil.OFFERING_TYPE_PCC || offeringType == SubscriptionUtil.OFFERING_TYPE_PEC){
        strQueryString +=' AND Direct_Indirect__c = :strDirectIndirect';
    }
    //Mukunth added for DDS337 on 26-JUN-2019
    if(decPCPartnerMargin < decimal.valueof(15) && decPCPartnerMargin != decimal.valueof(-7777) && decDealSize > 0 && decDealSize <= 120000){
        strQueryString += ' AND Filter_Criteria__c = \'Margin<15%\'';
    }
    //Mukunth code end
    
    strQueryString +=' Limit 1';
    
    System.Debug('strQueryString--->'+strQueryString);
    
    list_DDSCloudMasterRecords = Database.query(strQueryString);
    if(list_DDSCloudMasterRecords.size() > 0) {
        return list_DDSCloudMasterRecords[0];
    }
    return null;
}

/** Method to fetch the UOM, Category and Discount for the DDSCloudModel **/
@TestVisible 
private static List<String> fetchUnitofMeasureCategoryandDiscount(BigMachines__Quote__c objQuote,List<BigMachines__Quote_Product__c> list_BigMachinesQuoteProducts) {
    try{
        Decimal decACVWithoutDiscount = 0;
        Decimal decACVWithDiscount = 0;
        Decimal decDiscount = 0;
        Decimal decExtListPriceThirdParty = 0;
        Decimal decExtListPriceLicense = 0;
        Decimal decExtListPricePS = 0;
        Decimal decExtListPriceHardware = 0;
        Decimal decPartnerPrice = 0;
        Decimal decPartnerPriceDiscount = 0;
        Decimal decDealRegistrationDiscount = 0;
        Decimal decCustomerDiscount = 0;
        Decimal decCredit = 0;
        Integer intRecordSizeRawDiscount = 0;
        Boolean blnThirdPartyandHardwareonlyQuote = true;
        /**Decimal decThirdPartyDifference = 0;
        Decimal decMaxLicenseDifference = 0;**/
        Decimal decTotalExlistPriceThirdParty = 0;
        Decimal decTotalDicountedPriceThirdParty = 0;
        Decimal decTotalThirdPartyDiscount = 0;
        Decimal decTotalExlistPriceMaxLicense = 0;
        Decimal decTotalDicountedPriceMaxLicense = 0;
        Decimal decTotalMaxLicenseDiscount = 0;
        Decimal decTotalExlistPricePS = 0;
        Decimal decTotalDiscountedPricePS = 0;
        Decimal decTotalPSDiscount = 0;
        Decimal decTotalListPrice = 0;
        Decimal decTotalExListPriceHardware = 0;
        Decimal decTotalDiscountedPriceHardware = 0;
        Decimal decTotalHardwareDiscount = 0;
        Decimal decPEVMultilpier = 12*Global_Configuration_Settings__c.getOrgDefaults().PEV_Third_Party_Cloud__c;
        decCustomerDiscount = objQuote.Customer_Contractual_Rate__c != null ? objQuote.Customer_Contractual_Rate__c:0;
        if((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
        && objQuote.BigMachines__Opportunity__r.Partner_Opportunity_Source__c == 'Partner Registered Opportunity' 
        && objQuote.BigMachines__Opportunity__r.Partner_Opportunity_Status__c == 'Approved' 
        && objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect'){
            decDealRegistrationDiscount = (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC  || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) ? Global_Configuration_Settings__c.getinstance().PCC_Deal_Registration_Discount__c : 0;
        }
        List<String>list_UOMCategoryDiscount = new List<String>();
        List<BigMachines__Quote_Product__c> list_BigMachinesQuoteProductsforRawScore = new List<BigMachines__Quote_Product__c>();

        for (BigMachines__Quote_Product__c objQuoteProduct : list_BigMachinesQuoteProducts) {
            if(objQuoteProduct.BigMachines__Product__r.Third_Party__c != 'TRUE' && objQuoteProduct.BigMachines__Product__r.Type__c != 'Product - Hardware' && !objQuoteProduct.BigMachines__Product__r.Product_Group__c.contains('PureSuccess')) {
               //&& objQuoteProduct.BigMachines__Product__r.Product_Group__c != 'PureSuccess Direct A-la-Carte' && objQuoteProduct.BigMachines__Product__r.Product_Group__c != 'PureSuccess Direct Offer'
               //&& objQuoteProduct.BigMachines__Product__r.Product_Group__c != 'PureSuccess Indirect A-la-Carte' && objQuoteProduct.BigMachines__Product__r.Product_Group__c != 'PureSuccess Indirect Offer'){
                blnThirdPartyandHardwareonlyQuote = false;
            }
            //Added By Ranjith on Apr 15, 2019 -- Starts -- For Migration Credit
            if(objQuoteProduct.BigMachines__Product__r.New_Category__c == 'Credit') {
            //if(Label.PureCloud_Credit_Products.contains(objQuoteProduct.BigMachines__Product__r.Name)){
                System.debug('#####objQuoteProduct.Extended_Price_Per_Month__c: '+objQuoteProduct.Extended_Price_Per_Month__c);                    
                if(objQuoteProduct.BigMachines__Product__r.Include_in_CMMR_Total__c) 
                    decCredit += objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c;
                else 
                    decCredit += objQuoteProduct.Extended_Price_Per_Month__c/objQuote.No_Of_Months__c;
            //Added By Ranjith on Apr 15, 2019 -- Ends -- For Migration Credit
            }
            if(objQuoteProduct.BigMachines__Product__r.Include_in_CMMR_Total__c && objQuoteProduct.BigMachines__Product__r.Third_Party__c !='TRUE' && objQuoteProduct.BigMachines__Product__r.Type__c != 'Product - Hardware' && objQuoteProduct.BigMachines__Product__r.Type__c != 'Hardware Warranty'
               && objQuoteProduct.BigMachines__Product__r.New_Category__c != 'Credit') { //Added By Ranjith on Apr 15, 2019 -- Ends -- For Migration Credit
                 if((objQuote.Offering_Type__c == 'Business Edition' || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) && objQuoteProduct.BigMachines__Product__r.Product_Sub_category__c != 'Telco' && objQuoteProduct.BigMachines__Product__r.Type__c != 'GU'){
                    list_BigMachinesQuoteProductsforRawScore.add(objQuoteProduct);
                 }
                 if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC && objQuoteProduct.BigMachines__Product__r.Product_Sub_category__c != 'Telco' && objQuoteProduct.BigMachines__Product__r.Sub_Category__c != 'Monthly Telecommunications and Datacenter Fees' && objQuoteProduct.BigMachines__Product__r.Sub_Category__c != 'Interaction Collector'&& objQuoteProduct.BigMachines__Product__r.Type__c != 'GU'){
                    list_BigMachinesQuoteProductsforRawScore.add(objQuoteProduct);
                 }
                 if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC && objQuoteProduct.BigMachines__Product__r.Sub_Category__c != 'Service Packages' && objQuoteProduct.BigMachines__Product__r.Sub_Category__c != 'AppFoundry Services'&& objQuoteProduct.BigMachines__Product__r.Type__c != 'GU'){
                    list_BigMachinesQuoteProductsforRawScore.add(objQuoteProduct);
                 }
            }

            if(objQuoteProduct.BigMachines__Product__r.Third_Party__c == 'TRUE' && objQuoteProduct.BigMachines__Product__r.Type__c != 'Product - Hardware' && objQuoteProduct.BigMachines__Product__r.Type__c != 'Hardware Warranty'){
                if(objQuoteProduct.BigMachines__Product__r.Include_in_CMMR_Total__c){
                    //Indirect -- Partner price and direct -- List price
                    decExtListPriceThirdParty = ((objQuoteProduct.Partner_Price__c != null && objQuoteProduct.Partner_Price__c > 0 ? objQuoteProduct.Partner_Price__c : objQuoteProduct.List_Price__c) * objQuoteProduct.BigMachines__Quantity__c)*decPEVMultilpier;
                    decTotalExlistPriceThirdParty +=decExtListPriceThirdParty;
                    decTotalDicountedPriceThirdParty +=objQuoteProduct.Extended_Price_Per_Month__c*decPEVMultilpier;
                }
                else{
                    //Indirect -- Partner price and direct -- List price
                    decExtListPriceThirdParty = ((objQuoteProduct.Partner_Price__c != null  && objQuoteProduct.Partner_Price__c > 0 ? objQuoteProduct.Partner_Price__c : objQuoteProduct.List_Price__c) * objQuoteProduct.BigMachines__Quantity__c);
                    decTotalExlistPriceThirdParty +=decExtListPriceThirdParty;
                    decTotalDicountedPriceThirdParty +=objQuoteProduct.Extended_Price_Per_Month__c;
                }
            }

            if((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC &&(objQuoteProduct.BigMachines__Product__r.Sub_Category__c=='Service Packages' || objQuoteProduct.BigMachines__Product__r.Sub_Category__c=='AppFoundry Services'))||(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC &&objQuoteProduct.BigMachines__Product__r.Sub_Category__c=='Interaction Collector')) {
                //Indirect -- Partner price and direct -- List price
                decExtListPricePS = ((objQuoteProduct.Partner_Price__c != null  && objQuoteProduct.Partner_Price__c > 0  ? objQuoteProduct.Partner_Price__c : objQuoteProduct.List_Price__c) * objQuoteProduct.BigMachines__Quantity__c);
                decTotalExlistPricePS += decExtListPricePS;
                decTotalDiscountedPricePS += objQuoteProduct.Extended_Price_Per_Month__c;
            }

            if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Product - Hardware' || objQuoteProduct.BigMachines__Product__r.Type__c == 'Hardware Warranty') {
                
                //Indirect -- Partner price and direct -- List price
                decExtListPriceHardware = ((objQuoteProduct.Partner_Price__c != null  && objQuoteProduct.Partner_Price__c > 0 ? objQuoteProduct.Partner_Price__c : objQuoteProduct.List_Price__c) * objQuoteProduct.BigMachines__Quantity__c);
                decTotalExListPriceHardware += decExtListPriceHardware;
                decTotalDiscountedPriceHardware += objQuoteProduct.Extended_Price_Per_Month__c;
                system.debug('Inside HW'+decTotalExListPriceHardware);
            }
        }
        system.debug('blnThirdPartyandHardwareonlyQuote '+blnThirdPartyandHardwareonlyQuote );
        for(BigMachines__Quote_Product__c objQuoteProduct : list_BigMachinesQuoteProductsforRawScore){
                
            decACVWithoutDiscount += (objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c);
            if(objQuoteProduct.Extended_Price_Per_Month__c != null){
                decACVWithDiscount += objQuoteProduct.Extended_Price_Per_Month__c;
            }
            if(objQuoteProduct.Partner_Price__c != null  && objQuoteProduct.Partner_Price__c > 0 ) {
                decPartnerPrice += (objQuoteProduct.Partner_Price__c *objQuoteProduct.BigMachines__Quantity__c) ;
            }
        }
        System.debug('decACVWithoutDiscount ---'+decACVWithoutDiscount);
        System.debug('decPartnerPrice--->'+decPartnerPrice);
        if(decACVWithoutDiscount != 0){
            if(decTotalExlistPriceThirdParty != 0){
                decTotalThirdPartyDiscount = 100-((decTotalDicountedPriceThirdParty/decTotalExlistPriceThirdParty)*100);
            }
            System.debug('ThirdPartyDiscount---'+decTotalThirdPartyDiscount);
                
            if(decTotalExlistPricePS !=0){
                decTotalPSDiscount = 100-((decTotalDiscountedPricePS/decTotalExlistPricePS)*100);
            }
            System.debug('TotalPSDiscount---'+decTotalPSDiscount);

            if(decTotalExListPriceHardware !=0){
                decTotalHardwareDiscount = 100-((decTotalDiscountedPriceHardware/decTotalExListPriceHardware)*100);
            }
            System.debug('TotalHardwareDiscount---'+decTotalHardwareDiscount);                
            
            if(((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC && objQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c )||(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC && objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) ||(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC && objQuote.BigMachines__Opportunity__r.PureEngage_Cloud_Partner_Approved__c)) && decPartnerPrice > 0){
                decPartnerPriceDiscount = 100-((decPartnerPrice/decACVWithoutDiscount)*100);
            }
            if(decACVWithoutDiscount != 0){
                decDiscount = 1-(decACVWithDiscount/decACVWithoutDiscount);
            }
        }
        List<Decimal>list_ImpactScore = calculateScoreImpact(decTotalThirdPartyDiscount,decTotalHardwareDiscount,decTotalPSDiscount,decDiscount,objQuote.Offering_Type__c);
           
        list_UOMCategoryDiscount.add(String.valueof(decDiscount*100));
        list_UOMCategoryDiscount.add(String.valueof((decACVWithoutDiscount)*12)); //Added By Ranjith on Apr 15, 2019 -- Starts -- For Migration Credit
        list_UOMCategoryDiscount.add(String.valueOf(decTotalThirdPartyDiscount));
        list_UOMCategoryDiscount.add(String.valueOf(decDiscount*100));
        list_UOMCategoryDiscount.add(String.valueOf(decTotalHardwareDiscount));
        list_UOMCategoryDiscount.add(String.valueOf(decTotalPSDiscount));
        //list_UOMCategoryDiscount.add(String.valueOf(decPartnerPriceDiscount+decDealRegistrationDiscount+decCustomerDiscount));
        list_UOMCategoryDiscount.add(String.valueOf(decDealRegistrationDiscount+decCustomerDiscount));
        list_UOMCategoryDiscount.add(String.valueof(list_ImpactScore[0]));
        list_UOMCategoryDiscount.add(String.valueof(list_ImpactScore[1]));
        list_UOMCategoryDiscount.add(String.valueof(list_ImpactScore[2]));
        list_UOMCategoryDiscount.add(String.valueof(list_ImpactScore[3]));
        list_UOMCategoryDiscount.add(String.valueof(list_ImpactScore[4]));
        System.Debug('decPartnerPriceDiscount--->'+decPartnerPriceDiscount);
        list_UOMCategoryDiscount.add(String.valueOf(decPartnerPriceDiscount));
        list_UOMCategoryDiscount.add(String.valueOf(decDealRegistrationDiscount));
        list_UOMCategoryDiscount.add(String.valueOf(decCustomerDiscount));
        list_UOMCategoryDiscount.add(String.valueOf(decACVWithoutDiscount*12));
        list_UOMCategoryDiscount.add(String.valueOf(blnThirdPartyandHardwareonlyQuote));

        return list_UOMCategoryDiscount;
    }
    catch (Exception e) {
        system.debug('CategoryUOM exception' + e);

    }
    return null;
}
/** Method to calculate score impact **/
@TestVisible
private static List<decimal> calculateScoreImpact(Decimal decThirdPartyDiscount, Decimal decHardWareDiscount, Decimal decPSDiscount, Decimal decMaxLicenseDiscount, String strOfferingType)  {
    List<Decimal>list_ImpactScore = new List<Decimal>();
    System.debug('invoked');
    Decimal decThirdPartyDiscountDelta = 0;
    Decimal decHardWareDiscountDelta = 0;
    Decimal decPSDiscountDelta = 0;
    Decimal decMaxLicenseDiscountDelta = 0;
    Decimal decThirdPartyScoreImpact = 0;
    Decimal decHardwareScoreImpact =0;
    Decimal decPSScoreImpact = 0;
    Decimal decMaxLicenseScoreImpact = 0;
    Boolean blnThirdPartyDiscountDeltaCalculated = false;
    Boolean blnHardWareDiscountDeltaCalculated = false;
    Boolean blnPSDiscountDeltaCalculated = false;
    Boolean blnMaxLicenseDeltaCalculated = false;
    List<DDS_Cloud_Scoring_Adjustments__mdt> list_ThirdPartyAdjustment = new List<DDS_Cloud_Scoring_Adjustments__mdt>();
    if(strOfferingType == SubscriptionUtil.OFFERING_TYPE_PC || strOfferingType == SubscriptionUtil.OFFERING_TYPE_PCC){
       list_ThirdPartyAdjustment = [SELECT Id, Cutoff_From__c, Cutoff_To__c, Factor_Weight__c,Scoring_Adjustment_Factor__c, Impact_Weight__c, Max_Allowed_Discount__c
                                                                         FROM DDS_Cloud_Scoring_Adjustments__mdt WHERE Offering_Type__c = :strOfferingType];
    }
    else{
         list_ThirdPartyAdjustment = [SELECT Id, Cutoff_From__c, Cutoff_To__c, Factor_Weight__c,Scoring_Adjustment_Factor__c, Impact_Weight__c, Max_Allowed_Discount__c
                                                                         FROM DDS_Cloud_Scoring_Adjustments__mdt WHERE Offering_Type__c = 'PureEngage Cloud'];
    }
    System.debug('Third Party Adjustment'+list_ThirdPartyAdjustment.size());
    for(DDS_Cloud_Scoring_Adjustments__mdt objScoringAdjustment : list_ThirdPartyAdjustment){

        if(objScoringAdjustment.Scoring_Adjustment_Factor__c == 'Third Party Discount') {
            if(!blnThirdPartyDiscountDeltaCalculated) {
                blnThirdPartyDiscountDeltaCalculated = true;
                if(decThirdPartyDiscount > objScoringAdjustment.Max_Allowed_Discount__c) {
                    decThirdPartyDiscountDelta = decThirdPartyDiscount - objScoringAdjustment.Max_Allowed_Discount__c;
                }
            }
            if(blnThirdPartyDiscountDeltaCalculated) {
               if(decThirdPartyDiscountDelta == 0) {
                    decThirdPartyScoreImpact = 0;
                }
                else if(decThirdPartyDiscountDelta > objScoringAdjustment.Cutoff_From__c && decThirdPartyDiscountDelta <= objScoringAdjustment.Cutoff_To__c) {
                    decThirdPartyScoreImpact = objScoringAdjustment.Factor_Weight__c * objScoringAdjustment.Impact_Weight__c;
                } 
            }
        }
        else if(objScoringAdjustment.Scoring_Adjustment_Factor__c == 'Hardware Discount'){
            if (!blnHardWareDiscountDeltaCalculated) {
                blnHardWareDiscountDeltaCalculated = true;
                 if(decHardWareDiscount > objScoringAdjustment.Max_Allowed_Discount__c) {
                    decHardWareDiscountDelta =decHardWareDiscount -  objScoringAdjustment.Max_Allowed_Discount__c;
                }
            }
            if(blnHardWareDiscountDeltaCalculated) {
                if(decHardWareDiscountDelta == 0){
                    decHardwareScoreImpact = 0;
                }
                else if(decHardWareDiscountDelta>objScoringAdjustment.Cutoff_From__c && decHardWareDiscountDelta <= objScoringAdjustment.Cutoff_To__c) {
                    decHardwareScoreImpact = objScoringAdjustment.Factor_Weight__c * objScoringAdjustment.Impact_Weight__c;
                }
            }
        }
        else if(objScoringAdjustment.Scoring_Adjustment_Factor__c == 'PS Discount'){
             if(!blnPSDiscountDeltaCalculated) {
                blnPSDiscountDeltaCalculated = true;
                 if(decPSDiscount > objScoringAdjustment.Max_Allowed_Discount__c) {
                    decPSDiscountDelta =  decPSDiscount-objScoringAdjustment.Max_Allowed_Discount__c;
                }
            }
            if(blnPSDiscountDeltaCalculated) {
               if(decPSDiscountDelta == 0){
                    decPSScoreImpact = 0;
                }
                else if(decPSDiscountDelta>objScoringAdjustment.Cutoff_From__c && decPSDiscountDelta <= objScoringAdjustment.Cutoff_To__c) {
                     decPSScoreImpact = objScoringAdjustment.Factor_Weight__c * objScoringAdjustment.Impact_Weight__c;
                } 
            }
        }
        else if(objScoringAdjustment.Scoring_Adjustment_Factor__c == 'Max License Discount'){
            if(!blnMaxLicenseDeltaCalculated) {
                blnMaxLicenseDeltaCalculated = true;
                if(decMaxLicenseDiscount > objScoringAdjustment.Max_Allowed_Discount__c) {
                    decMaxLicenseDiscountDelta = decMaxLicenseDiscount - objScoringAdjustment.Max_Allowed_Discount__c;
                    System.debug('Max License Delta'+decMaxLicenseDiscountDelta);
                }
            }
            if(blnMaxLicenseDeltaCalculated) {
                if(decMaxLicenseDiscountDelta == 0){
                    decMaxLicenseScoreImpact = 0;
                }
                else if(decMaxLicenseDiscountDelta>objScoringAdjustment.Cutoff_From__c && decMaxLicenseDiscountDelta <= objScoringAdjustment.Cutoff_To__c) {
                    decMaxLicenseScoreImpact = objScoringAdjustment.Factor_Weight__c * objScoringAdjustment.Impact_Weight__c;
                } 
            }
        }
    }

    list_ImpactScore.add(decThirdPartyScoreImpact);
    list_ImpactScore.add(decHardwareScoreImpact);
    list_ImpactScore.add(decPSScoreImpact);
    list_ImpactScore.add(decMaxLicenseScoreImpact);
    list_ImpactScore.add(decThirdPartyScoreImpact + decHardwareScoreImpact + decPSScoreImpact +decMaxLicenseScoreImpact);
    return list_ImpactScore;
}
   
/** Method to convert currency **/
public static Decimal converttoUSD(String strOfferingType,String strPriceBook,String strCountryISOCode,Decimal decACV){
    String strQueryString = 'SELECT Id,Conversion_Rate__c FROM Currency_Configuration__c WHERE';
    if(strOfferingType == 'Business Edition'){
        strQueryString +=  ' Offering_Type__c = \'' +'PureEngage Cloud' +'\''+' AND Price_Book__c = :strCountryISOCode';
    }
    else{
        strQueryString +=  ' Offering_Type__c INCLUDES (:strOfferingType) AND Price_Book__c = :strPriceBook';
    }
    
     //Added by Ram Agarawal, Date: 11-12-2019, Issue: CreateCloudPCController submit of product exception(Pure cloud quoting Requirement).
    strQueryString += ' Limit 1 ';
    //Ended by Ram Agarawal, Date: 11-12-2019, Issue: CreateCloudPCController submit of product exception.
    /**Currency_Configuration__c objCurrencyConfiguration = [SELECT Id,Conversion_Rate__c 
                                                            FROM Currency_Configuration__c WHERE Offering_Type__c INCLUDES (:strOfferingType) AND Price_Book__c = :strPriceBook];**/
    Currency_Configuration__c objCurrencyConfiguration = Database.query(strQueryString);
    System.debug('Currency Configuration--'+objCurrencyConfiguration);
    System.debug('ACV--'+decACV);
    Decimal decConvertedValue = decACV/objCurrencyConfiguration.Conversion_Rate__c;

    return decConvertedValue;
} 

/** Method to create DDS history **/
private static DealScoreHistory__c createDDSScoreHistory(DDSCloudModel objDDS, Id idQuoteId, Decimal decDealScore){
    
    String strLog = '';

     strLog = 'Raw Score : ' +objDDS.objScoreAdjustment.decRawScore+'<br/>Third Party Discount : '+objDDS.objScoreAdjustment.decThirdpartyDiscount+'<br/>Max License Discount : '+objDDS.objScoreAdjustment.decMaxDiscount;
     strLog += '<br/>Hardware Discount : '+objDDS.objScoreAdjustment.decHardwareDiscount+'<br/>PS Discount : '+objDDS.objScoreAdjustment.decPSDiscount+'<br/>Contractual Discount : '+objDDS.objScoreAdjustment.decContractualDiscount;
     strLog += '<br/><br/>';
     strLog += 'Third Party Discount Impact : '+objDDS.objScoreAdjustment.decThirdPartyImpact;
     strLog += '<br/>Hardware Discount Impact : '+objDDS.objScoreAdjustment.decHardwareImpact;
     strLog += '<br/>PS Discount Impact : '+objDDS.objScoreAdjustment.decPSImpact;
     strLog += '<br/>Max Discount Impact : '+  objDDS.objScoreAdjustment.decMaxLicenseImpact;
     strLog += '<br/>TotalImpact' +objDDS.objScoreAdjustment.decScoreImpact;

     DealScoreHistory__c objDDSHistory = new  DealScoreHistory__c();
     objDDSHistory.Log__c = strLog;
     objDDSHistory.Quote__c = idQuoteId;
     objDDSHistory.Quote_Id__c = idQuoteId;
     objDDSHistory.DealScore__c = decDealScore;
     objDDSHistory.Third_Party_Discount__c = objDDS.objScoreAdjustment.decThirdpartyDiscount;
     objDDSHistory.Consolidated_Contractual_Discount__c = objDDS.objScoreAdjustment.decContractualDiscount;
     objDDSHistory.Customer_Discount__c = objDDS.objContractualDiscount.decCustomerDiscount;
     objDDSHistory.Deal_Registration_Discount__c = objDDS.objContractualDiscount.decDealRegistrationDiscount;
     objDDSHistory.Deal_Score_After_Contractual_Discount__c = objDDS.decScoreAfterContractualAdjustment;
     objDDSHistory.Deal_Score_After_Overall_Adjustment__c = objDDS.decScoreAfterAllAdjustment;
     objDDSHistory.Deal_Size__c = objDDS.decDealSize;
     objDDSHistory.Direct_Indirect__c = objDDS.strDirectIndirectUI;
     objDDSHistory.Hardware_Discount_Impact__c = objDDS.objScoreAdjustment.decHardwareImpact;
     objDDSHistory.Max_License_Discount__c = objDDS.objScoreAdjustment.decMaxDiscount;
     objDDSHistory.Max_License_Discount_Impact__c = objDDS.objScoreAdjustment.decMaxLicenseImpact;
     objDDSHistory.Partner_Discount__c = objDDS.objContractualDiscount.decPartnerDiscount;
     objDDSHistory.PS_Discount__c = objDDS.objScoreAdjustment.decPSDiscount;
     objDDSHistory.PS_Discount_Impact__c = objDDS.objScoreAdjustment.decPSImpact;
     objDDSHistory.Raw_Score__c = objDDS.decScoreForRawScore;
     objDDSHistory.Raw_Score_Discount__c = objDDS.decDiscount;
     objDDSHistory.Third_Party_Discount_Impact__c = objDDS.objScoreAdjustment.decThirdPartyImpact;
     objDDSHistory.Total_Impact__c = objDDS.objScoreAdjustment.decScoreImpact;
     objDDSHistory.Hardware_Discount__c = objDDS.objScoreAdjustment.decHardwareDiscount;
        
        objDDSHistory.Cutoff__c = '';
        if(objDDS.list_CutoffDisplay != null)
        {
            objDDSHistory.Cutoff__c += '<HTML><TABLE><TR><TH>Cutoff %</TH><TH>Deal Score</TR></TH>';
            
            for(CutoffDisplay objCutoff : objDDS.list_CutoffDisplay)
            {
                //objCutoff.strRange +''
                objDDSHistory.Cutoff__c += '<TR><TD>';
                objDDSHistory.Cutoff__c += objCutoff.strRange == '<=' ? '&lt=' : (objCutoff.strRange == '>' ? '&gt;' : (objCutoff.strRange == '<' ? '&lt;':objCutoff.strRange));
                objDDSHistory.Cutoff__c += ' '+objCutoff.strCutoff + '%</TD>';
                objDDSHistory.Cutoff__c += '<TD>' + objCutoff.strDealScore+ '</TD></TR>';
            }
            objDDSHistory.Cutoff__c += '</TABLE></HTML>';
            system.debug(objDDSHistory.Cutoff__c);
        }

     upsert objDDSHistory Quote_Id__c;
     return objDDSHistory;

}

/** Method to get score for only Third party and Hardware quote **/
@TestVisible
private static Decimal fetchThirdPartyandHardwareScore(BigMachines__Quote__c objQuote,List<BigMachines__Quote_Product__c> list_BigMachinesQuoteProducts){
    
    Decimal decTotalExlistPrice = 0;
    Decimal decPEVMultilpier = 12*Global_Configuration_Settings__c.getOrgDefaults().PEV_Third_Party_Cloud__c;
    Map<Id,Decimal>map_Discount = new Map<Id,Decimal>();
    Map<Id,Decimal>map_ListPrice = new Map<Id,Decimal>();
    for (BigMachines__Quote_Product__c objQuoteProduct : list_BigMachinesQuoteProducts) {   
            if(objQuoteProduct.BigMachines__Product__r.Third_Party__c == 'TRUE' && objQuoteProduct.BigMachines__Product__r.Include_in_CMMR_Total__c){
                    map_ListPrice.put(objQuoteProduct.Id,objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c*decPEVMultilpier);
                    map_Discount.put(objQuoteProduct.Id,((1-((objQuoteProduct.Extended_Price_Per_Month__c*decPEVMultilpier)/(objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c*decPEVMultilpier)))*100).round(System.RoundingMode.HALF_UP));
                    decTotalExlistPrice +=objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c*decPEVMultilpier;
            }
            else if(objQuoteProduct.BigMachines__Product__r.Type__c == 'Product - Hardware' || objQuoteProduct.BigMachines__Product__r.Type__c == 'Hardware Warranty' ||(objQuoteProduct.BigMachines__Product__r.Third_Party__c == 'TRUE' && !objQuoteProduct.BigMachines__Product__r.Include_in_CMMR_Total__c)){
                    map_ListPrice.put(objQuoteProduct.Id,objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c);
                    map_Discount.put(objQuoteProduct.Id,((1-(objQuoteProduct.Extended_Price_Per_Month__c/(objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c)))*100).round(System.RoundingMode.HALF_UP));
                    decTotalExlistPrice +=objQuoteProduct.List_Price__c * objQuoteProduct.BigMachines__Quantity__c;
            }
        }
    return fetchCalculatedThirdPartyandHardwareScore(objQuote.Offering_Type__c,map_Discount,map_ListPrice,decTotalExlistPrice).round(System.RoundingMode.HALF_UP);
}

/** Method to get score for only Third party and Hardware quote for different offering types **/
private static Decimal fetchCalculatedThirdPartyandHardwareScore(String strOfferingType,Map<Id,Decimal>map_Discount,Map<Id,Decimal>map_ListPrice,Decimal decTotalListPrice){
    Decimal decScore = 0;
    Decimal decDiscount = 0;
    Decimal decWeightedScore =0;
    Decimal decListPrice = 0;
    if(strOfferingType == SubscriptionUtil.OFFERING_TYPE_PC || strOfferingType == SubscriptionUtil.OFFERING_TYPE_PCC) {
        for(Id idQuoteId : map_Discount.keySet()){
            decDiscount = map_Discount.get(idQuoteId);
            if(decDiscount <= 5){
                decScore = 5;
            }
            if(5 < decDiscount && decDiscount < 10){
                decScore = 4;
            }
            else if(decDiscount == 10){
                decScore = 3;
            }
            else if(10 < decDiscount && decDiscount <= 15){
                decScore = 2;
            }
            else if(15 < decDiscount && decDiscount <= 100){
                decScore = 1;
            }
            else{
                decScore = 0;
            }
           decWeightedScore += (map_ListPrice.get(idQuoteId)/decTotalListPrice)*decScore;
        }
    }
    else if(strOfferingType =='Business Edition' || strOfferingType == SubscriptionUtil.OFFERING_TYPE_PEC) {
        for(Id idQuoteId : map_Discount.keySet()){
            decDiscount = map_Discount.get(idQuoteId);
            if(decDiscount <= 25){
                decScore = 5;
            }
            else if(25 < decDiscount && decDiscount < 30){
                decScore = 4;
            }
            else if(decDiscount == 30){
                decScore = 3;
            }
            else if(30 < decDiscount && decDiscount <= 35){
                decScore = 2;
            }
            else if(35 < decDiscount && decDiscount <= 100){
                decScore = 1;
            }
            else{
                decScore = 0;
            }
            decWeightedScore += (map_ListPrice.get(idQuoteId)/decTotalListPrice)*decScore;
        }
    }
    return decWeightedScore;
}

/** Method to DDS compensation **/ 
private static Decimal getDDSCompensation(BigMachines__Quote__c objQuote){
  if(objQuote.Deal_Score__c == null ||objQuote.Offering_Type__c == null )
      return null;
  
  string strCompMultiplier;
  string strSearch_Variable_Name = 'Grade ' + objQuote.Deal_Score__c;
  Decimal decCompAmount;
  ///Get Constants  
  for ( DDS_Cloud_Constant__mdt objCnst : fetchDDSCloudConstant(objQuote.Offering_Type__c)) {
      If(objCnst.Variable_Name__c == strSearch_Variable_Name )
      strCompMultiplier = objCnst.Variable_Value__c;
  }
  if(strCompMultiplier == null)
      return null;
  
   return Decimal.valueOf(strCompMultiplier);  
}
/** Method to get DDS cloud constant **/
private static List<DDS_Cloud_Constant__mdt>fetchDDSCloudConstant(String strOfferingType) {
    String strQueryString = 'SELECT Variable_Name__c, Variable_Value__c FROM DDS_Cloud_Constant__mdt WHERE Type__c = \''+'Constant'+'\' AND';
    if(strOfferingType == 'Business Edition'){
        strQueryString +=  ' Offering__c = \'' +'PureEngage Cloud' +'\'';
    }
    else{
        strQueryString +=  ' Offering__c = :strOfferingType';
    }

    return(Database.query(strQueryString));
}

/** Method to get DDS history **/
public static DealScoreHistory__c fetchDDSHistory(Id idQuoteId){
    try{
        DealScoreHistory__c objDDSHistory= [SELECT Third_Party_Discount__c,Consolidated_Contractual_Discount__c ,Customer_Discount__c,Deal_Registration_Discount__c,
                                            Deal_Score_After_Contractual_Discount__c,Deal_Score_After_Overall_Adjustment__c,Deal_Size__c,Direct_Indirect__c ,Hardware_Discount_Impact__c,Max_License_Discount__c,
                                            Max_License_Discount_Impact__c,Partner_Discount__c,PS_Discount__c,PS_Discount_Impact__c,Raw_Score__c,Raw_Score_Discount__c,Third_Party_Discount_Impact__c,Total_Impact__c,
                                            Cutoff__c, Hardware_Discount__c
                                            FROM DealScoreHistory__c
                                            WHERE Quote__c = :idQuoteId
                                            ORDER BY CreatedDate DESC LIMIT 1];
        return objDDSHistory;
    }
    catch(Exception e){
        System.debug(e);
        return null;
    }
}

//Mukunth added for DDS337 on 26-JUN-2019
public static decimal fetchPCPartnerMargin(Id partnerId){
    map<string,decimal> partnerMarginPC = QuoteCloudUtil.buildPartnerMargins(partnerId);

    if(partnerMarginPC.containsKey(SubscriptionUtil.OFFERING_TYPE_PC))
        return partnerMarginPC.get(SubscriptionUtil.OFFERING_TYPE_PC);
    else
        return -7777;

}
//Mukunth code end

/** Wrapper class to hold DDS Cloud data to query the values from DDS Cloud Master Object**/
public class DDSCloudModel {
    public String strOfferingType {get; set;}
    public String strRegion {get; set;}
    public String strDealType {get; set;}
    public String strDirectIndirect {get; set;}
    public String strDirectIndirectUI {get;set;}
    public String strProductFamily {get; set;}
    public Decimal decCompensationMultiplier {get; set;}
    public Decimal decDiscount {get; set;}
    public String strUOM {get; set;}
    public String strProductGroup {get; set;}
    public String strCutoff {get;set;}
    public Decimal decDealSize {get; set;}
    public Decimal decDealSizeOrginal {get; set;}
    public String strApnNumber {get; set;}
    public Decimal decScoreForRawScore {get; set;}
    public Decimal decScoreAfterContractualAdjustment {get; set;}
    public Decimal decScoreAfterAllAdjustment {get; set;}
    public DDS_Cloud_Master__c objCloudMaster {get; set;}
    public List<CutoffDisplay> list_CutoffDisplay{get; set;}
    public ScoreAdjustment objScoreAdjustment {get; set;}
    public ContractualDiscount objContractualDiscount {get;set;}
    public Boolean blnOnlyThirdPartyandHardwareQuote {get;set;}
    public DealScoreHistory__c objDealScoreHistory{get;set;}
}

public class ScoreAdjustment {
    public Decimal decThirdpartyDiscount{get; set;}
    public Decimal decMaxDiscount{get; set;}
    public Decimal decRawScore{get; set;}
    public Decimal decScoreImpact {get;set;}
    public Decimal decThirdPartyImpact {get; set;}
    public Decimal decHardwareImpact {get; set;}
    public Decimal decMaxLicenseImpact {get; set;}
    public Decimal decPSImpact {get; set;}
    public Decimal decPSDiscount {get; set;}
    public Decimal decHardwareDiscount {get; set;}
    public Decimal decContractualDiscount{get; set;}
}

public class ContractualDiscount {
    public Decimal decPartnerDiscount {get; set;}
    public Decimal decDealRegistrationDiscount {get; set;}
    public Decimal decCustomerDiscount{get; set;}
}

public class CutoffDisplay{
    public String strRange{get; set;}
    public String strCutoff{get; set;}
    public String strDealScore{get; set;}
}


}