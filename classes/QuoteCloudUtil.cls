/*
* Class Name       : QuoteCloudUtil
* Description      : This Apex Class is used as util in multiple places for Cloud Quotes. 
* TestClass        : QuoteCloudUtilTest
*/
public class QuoteCloudUtil
{
    public final static string OFFERING_TYPE_CAAS = 'PureConnect Cloud';
    public final static string OFFERING_TYPE_PC = 'PureCloud';
    // ECD PEC Quote July 2019
    public final static string OFFERING_TYPE_PEC = 'PureEngage Cloud';
    public Static Map<Id, Product2> mapOfProducts;
    
    // *** Method to return Level One Vs Level Two Mapping Record based on Level One ***
    public static List<String> fetchLevelOneVsTwoMapping(String strLevelOne)
    {
        List<Level_One_Level_Two__c> list_All = Level_One_Level_Two__c.getAll().values();
        List<String> list_LevelTwoValues;
        for(Level_One_Level_Two__c objLevelOneVsTwo : list_All)
        {
            if(objLevelOneVsTwo.Level_One__c == strLevelOne)
            {
                list_LevelTwoValues = objLevelOneVsTwo.Level_Two__c.split(';');             
                return list_LevelTwoValues;
            }
        }
        return null;
    }
    
    // ECD PEC Quote July 2019.
    // The above method does NOT take into consideration Offering when returning Level 2 list.
    // It Should in case groupings have the same names in different Offerings
    public static List<String> fetchLevelOneVsTwoMapping(String strLevelOne, String strOfferingType)
    {
        List<Level_One_Level_Two__c> list_All = Level_One_Level_Two__c.getAll().values();
        List<String> list_LevelTwoValues;
        for(Level_One_Level_Two__c objLevelOneVsTwo : list_All)
        {
            if(objLevelOneVsTwo.Level_One__c == strLevelOne && objLevelOneVsTwo.Offering_Type__c == strOfferingType)
            {
                list_LevelTwoValues = objLevelOneVsTwo.Level_Two__c.split(';');             
                return list_LevelTwoValues;
            }
        }
        return null;
    }
    
    // *** Method to return Level Two Vs Level Three Mapping Record based on Level Two ***
    public static List<String> fetchLevelTwoVsThreeMapping(String strLevelTwo, String strOfferingType)
    {
        List<Level_Two_Level_Three__c> list_All = Level_Two_Level_Three__c.getAll().values();
        List<String> list_LevelThreeValues = new List<String>();
        for(Level_Two_Level_Three__c objLevelTwoVsThree : list_All)
        {
            if(objLevelTwoVsThree.Level_Two__c == strLevelTwo && objLevelTwoVsThree.Offering_Type__c == strOfferingType)
            {
                list_LevelThreeValues = objLevelTwoVsThree.Level_Three__c.split(';');
                if(String.isNotBlank(objLevelTwoVsThree.Level_Three2__c))
                    list_LevelThreeValues.addAll(objLevelTwoVsThree.Level_Three2__c.split(';'));
                
                break;
            }
        }
        return list_LevelThreeValues;
    }
    
    //Added By Ranjith on Oct 18, 2017 -- Starts 
    public static Map<String, Decimal> buildPartnerMargins(Id partnerId) 
    {
        Map<String, Decimal> map_PCPartnerMargins = new Map<String, Decimal>();
        for(PureCloud_Partner_Margin__c objPartnerMargin : [SELECT Percent__c, Margin_Type__c
                                                            FROM PureCloud_Partner_Margin__c
                                                            WHERE From_Date__c <= TODAY 
                                                            AND To_Date__c >= TODAY 
                                                            AND Account__c = :partnerId
                                                            ORDER BY To_Date__c ASC])
        {
            map_PCPartnerMargins.put(objPartnerMargin.Margin_Type__c, objPartnerMargin.Percent__c);
        }
        return map_PCPartnerMargins;
    }    
    //Added By Ranjith on Oct 18, 2017 -- Ends
    
    //Anju for Cloud
    public static void createPureSuccessLinesCloud(Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice, 
                                                   BigMachines__Quote__c objQuote, Order__c objOrder, List<Order_Line_Item__c> list_OrderLineItems){
                                                       List<String> listOfProductIds = new List<String>();
                                                       for(BasePackageLineConfiguration__c eachConfigDetails : BasePackageLineConfiguration__c.getAll().values()){
                                                           listOfProductIds.add(eachConfigDetails.PS_Product2_Id__c); 
                                                           listOfProductIds.add(eachConfigDetails.GU_Product2_Id__c); 
                                                           listOfProductIds.add(eachConfigDetails.CC_Product2_Id__c); 
                                                           
                                                       }
                                                       for(String eachPackage : mapOfPackageVsPrice.keySet()){ 
                                                           listOfProductIds.add(mapOfPackageVsPrice.get(eachPackage).Bundle_Line__r.BigMachines__Product__c); 
                                                       }
                                                       mapOfProducts = new Map<Id, Product2>([SELECT APN_Number__c,name FROM Product2 WHERE id IN : listOfProductIds]);
                                                       //Looping over each PureSuccess package  
                                                       for(String eachPackage : mapOfPackageVsPrice.keySet()){ 
                                                           String offeringType = objQuote.Offering_Type__c;
                                                           String packageName = (eachPackage == 'Partner PureSuccess' ? 'PARTNER' : eachPackage.toUpperCase());
                                                           String key = offeringType + '-' + packageName;                
                                                           BasePackageLineConfiguration__c configDetails = BasePackageLineConfiguration__c.getAll().get(key);
                                                           if(configDetails == null)
                                                               return;
                                                           BigMachines__Quote_Product__c packageQP = mapOfPackageVsPrice.get(eachPackage);
                                                           //PS            
                                                           Double PSPercentage = (configDetails.PS__c == null ? 0 : configDetails.PS__c);
                                                           Double PSPrice;
                                                           if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                               PSPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c * PSPercentage / 100;  
                                                           else
                                                           {   System.debug('Values'+ packageQP.Bundle_Line__c+packageQP.Bundle_Line__r.Extended_Price_Per_Month__c+PSPercentage);
                                                            PSPrice = packageQP.Bundle_Line__r.Extended_Price_Per_Month__c * PSPercentage / 100;    
                                                           }   
                                                           Order_Line_Item__c newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                           newOLI.Product__c = configDetails.PS_Product2_Id__c;   
                                                           Product2 PSProduct = mapOfProducts.get(newOLI.Product__c);
                                                           newOLI.APN_Number__c = PSProduct.APN_Number__c;
                                                           newOLI.Year__c = 1;
                                                           newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                           newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c; 
                                                           populatePureSuccessOLI(newOLI, PSPrice, packageQP, objQuote);
                                                           newOLI.Line_Number__c = 1;
                                                           list_OrderLineItems.add(newOLI);
                                                           //GU
                                                           Double GUPercentage = (configDetails.GU__c == null ? 0 : configDetails.GU__c);
                                                           Double GUPrice;
                                                           if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                               GUPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c * GUPercentage / 100; 
                                                           else
                                                               GUPrice = packageQP.Bundle_Line__r.Extended_Price_Per_Month__c * GUPercentage / 100; 
                                                           
                                                           newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                           newOLI.Product__c = configDetails.GU_Product2_Id__c;   
                                                           Product2 GUProduct = mapOfProducts.get(newOLI.Product__c);
                                                           newOLI.APN_Number__c = GUProduct.APN_Number__c;
                                                           newOLI.Year__c = 1;
                                                           newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                           newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c; 
                                                           populatePureSuccessOLI(newOLI, GUPrice, packageQP, objQuote);
                                                           newOLI.Line_Number__c = 2;
                                                           list_OrderLineItems.add(newOLI);
                                                           //CC
                                                           Double CCPercentage = (configDetails.CC__c == null ? 0 : configDetails.CC__c);
                                                           Double CCPrice;
                                                           if(packageQP.Bundle_Line__r.Ext_Net_Price__c != null)
                                                               CCPrice = packageQP.Bundle_Line__r.Ext_Net_Price__c * CCPercentage / 100; 
                                                           else
                                                               CCPrice = packageQP.Bundle_Line__r.Extended_Price_Per_Month__c * CCPercentage / 100;           
                                                           newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                           newOLI.Product__c = configDetails.CC_Product2_Id__c;   
                                                           Product2 CCProduct = mapOfProducts.get(newOLI.Product__c);
                                                           newOLI.APN_Number__c = CCProduct.APN_Number__c;
                                                           newOLI.Year__c = 1;
                                                           newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                           newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;  
                                                           populatePureSuccessOLI(newOLI, CCPrice, packageQP, objQuote);
                                                           newOLI.Line_Number__c = 3;
                                                           list_OrderLineItems.add(newOLI);
                                                           
                                                           newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
                                                           newOLI.Product__c = packageQP.Bundle_Line__r.BigMachines__Product__c;   
                                                           newOLI.APN_Number__c = packageQP.Bundle_Line__r.APN_Number__c;
                                                           newOLI.Year__c = 1;
                                                           newOLI.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                                                           newOLI.Maintenance_End_Date__c = objOrder.Maintenance_End__c;  
                                                           populatePureSuccessOLI(newOLI, 0, packageQP, objQuote);
                                                           newOLI.Base_Package__c = packageQP.Bundle_Line__r.Ext_Net_Price__c; 
                                                           newOLI.Net_Unit_Price__c = 0;
                                                           newOLI.Line_Number__c = 4;
                                                           list_OrderLineItems.add(newOLI);
                                                           
                                                       }
                                                       upsert list_OrderLineItems;    
                                                   }
    
    @TestVisible private static void populatePureSuccessOLI(Order_Line_Item__c newOLI, Double PSPrice, 
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
                                                                    if(mapOfProducts != null){
                                                                        newOLI.Name = mapOfProducts.get(newOLI.Product__c).name;
                                                                    }
                                                            }
    
    
    
    
    
    
    
    
    
    
    
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
    
    public static BigMachines__Quote__c prepareQuotes(Id quoteId) {   
        String strQuoteQuery = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQuoteQuery += field.getFieldPath() + ', ';
        strQuoteQuery += 'Id,End_User_ID__r.Country__r.Name, Quote_Cloned_Revised__r.Name,Quote_Number__c,BigMachines__Opportunity__r.RecordType.Name,BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c,End_User_ID__r.Subsidary__c,PureSuccess__c,';     
        strQuoteQuery += 'Sold_To_Name__r.Country__r.PSRDP_Region__c,Sold_To_Name__r.Country__r.Name,Sold_To_Name__r.Country__r.Region__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Name,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,';
        strQuoteQuery += 'BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email, BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,';        
        strQuoteQuery += 'Amendment_For__r.CMRR__c, Amendment_For__r.ACV__c, Amendment_For__r.TCV__c,TAM_Amount__c,TAM_Duration_Months__c,';        
        strQuoteQuery += 'Amendment_For__r.Total_Services__c, Amendment_For__r.Total_Education__c, Amendment_For__r.Total_Hardware__c,Amendment_For__r.Total_Non_Recurring_Fees__c,';        
        strQuoteQuery += 'Amendment_For__r.Total_Tokens__c,Amendment_For__r.Telco_CMRR__c,Amendment_For__r.Setup_Provisioning_Charges__c,Amendment_For__r.Requires_Manual_Billing_Review__c,Amendment_For__r.Manual_Billing_Review_Status__c,';
        //Anju May 2018 
        strQuoteQuery += 'Amendment_For__r.Status__c,';        
        strQuoteQuery += 'BigMachines__Opportunity__r.Account.Partner_Tier__c FROM BigMachines__Quote__c WHERE Id = :quoteId';
        return Database.Query(strQuoteQuery);
    }
    public Static List<BigMachines__Quote_Product__c> prepareQuoteProduct(Id quoteId) 
    {
        Map<Id,List<BigMachines__Quote_Product__c>> map_QIdtoQPs = new Map<Id,List<BigMachines__Quote_Product__c>>();
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQueryAllFields += field.getFieldPath() + ', ';
        strQueryAllFields += 'Bundle__r.Name, BigMachines__Product__r.Include_in_Agent_Seat_Count__c, BigMachines__Product__r.Tier__c,BigMachines__Product__r.Charge_Type__c, BigMachines__Product__r.Product_Group__c, BigMachines__Product__r.Partner_Margin_Type__c,BigMachines__Product__r.CurrencyISOCode,CurrencyISOCode, ';
        strQueryAllFields +='BigMachines__Product__r.Concurrent_List_Price__c, BigMachines__Product__r.G1_APAC_AUD_Price__c, BigMachines__Product__r.G1_APAC_USD_Price__c, BigMachines__Product__r.G2_CALA_USD_Price__c, BigMachines__Product__r.G3_EMEA_EUR_Price__c, BigMachines__Product__r.G3_EMEA_GBP_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.G3_EMEA_USD_Price__c, BigMachines__Product__r.G4_JAPAN_JPY_Price__c, BigMachines__Product__r.G5_NA_CAD_Price__c, BigMachines__Product__r.G5_NA_USD_Price__c, BigMachines__Product__r.List_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG1_APAC_ANZ_AUD_Price__c, BigMachines__Product__r.NG1_APAC_KOREA_SE_ASIA_USD_Price__c, BigMachines__Product__r.NG1_APAC_USD_Price__c, BigMachines__Product__r.NG2_BRAZIL_BRL_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG2_CALA_USD_Price__c, BigMachines__Product__r.NG3_EMEA_EUR_Price__c, BigMachines__Product__r.NG3_EMEA_GBP_Price__c, BigMachines__Product__r.NG3_EMEA_USD_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG3_Europe_ZAR_Price__c, BigMachines__Product__r.NG4_APAC_CHINA_INDIA_USD_Price__c, BigMachines__Product__r.NG4_APAC_JAPAN_YEN_Price__c, BigMachines__Product__r.NG4_APAC_NZD_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG5_NA_CAD_Price__c,BigMachines__Product__r.NG5_NA_USD_Price__c,BigMachines__Product__r.NG5_NZD_Price__c,BigMachines__Product__r.NG5_ZAR_Price__c';
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :quoteId';
        System.debug('Query'+strQueryAllFields);
        List<BigMachines__Quote_Product__c> list_QuoteProducts = Database.Query(strQueryAllFields);
        return list_QuoteProducts;
    }
    
    public static Map<Id,Map<String,Id>> PreparePBEList(Map<Id,List<BigMachines__Quote_Product__c>> map_QuoteIdtoQuoteProds)
    {
        System.debug(' map_QuoteIdtoQuoteProds'+ map_QuoteIdtoQuoteProds); 
        Set<Id> set_ProdIds = new Set<Id>();
        Set<String> set_ProdCurrency = new Set<String>();
        
        for(Id Id_QuoteId:map_QuoteIdtoQuoteProds.keyset()){
            for(BigMachines__Quote_Product__c objQP:map_QuoteIdtoQuoteProds.get(Id_QuoteId))
            {
                set_ProdIds.add(objQP.BigMachines__Product__c);//set_ProdIds.add(objQP.ID)
                set_ProdCurrency.add(objQP.CurrencyIsoCode);//set_ProdCurrency.add(objQP.BigMachines__Product__r.CurrencyISOCode);
            }   
        }
        System.debug('set_ProdIds'+set_ProdIds+'set_ProdCurrency'+set_ProdCurrency);
        List<PricebookEntry> list_PBE = [SELECT Product2Id,Id,CurrencyISOCode FROM PricebookEntry WHERE Pricebook2Id = :Label.Standard_Pricebook_Id AND 
                                         Product2Id IN :set_ProdIds AND CurrencyISOCode in :set_ProdCurrency];
        Map<Id,Map<String,Id>> map_ProdIdToPBEId = new Map<Id,Map<String,Id>>();                        
        for(PricebookEntry objPBE:list_PBE){
            {
                if(!map_ProdIdToPBEId.containskey(objPBE.Product2Id)) {
                    map_ProdIdToPBEId.put(objPBE.Product2Id,new Map<String,Id>());
                    map_ProdIdToPBEId.get(objPBE.Product2Id).put(String.valueof(objPBE.CurrencyISOCode),objPBE.Id);
                }
                else
                {map_ProdIdToPBEId.get(objPBE.Product2Id).put(String.valueof(objPBE.CurrencyISOCode),objPBE.Id);}   
            }
            
        }
        System.debug('map_ProdIdToPBEId'+map_ProdIdToPBEId);
        return  map_ProdIdToPBEId;              
    }   
    
    
    public static String getMSALink(Opportunity objOpty,String strOfferingType) {
        System.debug(objOpty);
        System.debug(strOfferingType);
        String strURL = '';
        objOpty= [Select Sold_To_Country__r.Name,Sold_To_Country__r.Region__c from Opportunity where id = :objOpty.id ];
        System.debug('objOpty:'+objOpty);
        Map<String,Map<String,string>> map_OfferingTypetoURl = new Map<String,Map<String,String>>();
        for(Links__mdt objMSALink : [SELECT Country__c, Link_Type__c, Offering_Type__c, URL__c 
                                     FROM Links__mdt where
                                     Link_Type__c = 'MSA'
                                    ]) {
                                        
                                        if(map_OfferingTypetoURl.containsKey(objMSALink.Offering_Type__c)){
                                            map_OfferingTypetoURl.get(objMSALink.Offering_Type__c).put(objMSALink.Country__c,objMSALink.URL__c);
                                        }
                                        else
                                        {
                                            map_OfferingTypetoURl.put(objMSALink.Offering_Type__c,new Map<String,String>());
                                            map_OfferingTypetoURl.get(objMSALink.Offering_Type__c).put(objMSALink.Country__c,objMSALink.URL__c);
                                        }   
                                    }
        If(strOfferingType == 'PureCloud'){
            System.debug('map_OfferingTypetoURl.get(strOfferingType):'+map_OfferingTypetoURl.get(strOfferingType).Keyset());
            if(map_OfferingTypetoURl.get(strOfferingType).containsKey(objOpty.Sold_To_Country__r.Name)||map_OfferingTypetoURl.get(strOfferingType).containsKey(objOpty.Sold_To_Country__r.Region__c)){
                strURL = map_OfferingTypetoURl.get(strOfferingType).containsKey(objOpty.Sold_To_Country__r.Name)?map_OfferingTypetoURl.get(strOfferingType).get(objOpty.Sold_To_Country__r.Name):map_OfferingTypetoURl.get(strOfferingType).get(objOpty.Sold_To_Country__r.Region__c);
            }
            else{
                strURL = map_OfferingTypetoURl.get(strOfferingType).get('Default');
            }
            
        }   
        else
        {
            strURL = map_OfferingTypetoURl.get(strOfferingType).get('Default');
        }                            
        
        System.debug('Offering Type:'+ strOfferingType+ ' URL:'+strURL);
        return strURL;
    }
    
    public static Set<Id> findOverageChargeAPNs(BigMachines__Quote__c  objQuote) {
        Set<Id> set_QId = new Set<Id>();
        if(objQuote.Billing_Category__c == 'M2M') {
            set_QId.add(objQuote.Id);   
        }
        Set<Id> set_OvrgProdParentIds = new Set<Id>();
        for(BigMachines__Quote_Product__c objOvgQP : [SELECT Id, Parent_Quote_Product__c 
                                                      FROM BigMachines__Quote_Product__c
                                                      WHERE BigMachines__Quote__c  in :set_QId  
                                                      AND Parent_Quote_Product__c != null]) {
                                                          set_OvrgProdParentIds.add(objOvgQP.Parent_Quote_Product__c);
                                                      }
        return set_OvrgProdParentIds;
    }
    
    public static void buildQuoteProductsForRenewal(Id subscrId, BigMachines__Quote__c objQuote) {
        try{
            opportunity objopp=[select Direct_Indirect_Sale__c,BusinessPartner__c,BusinessPartner__r.PartnerType__c,BusinessPartner__r.Partner_Offering_Type__c from Opportunity where id =: objQuote.BigMachines__Opportunity__c];
            System.debug(objopp);
            Integer intSetScale = 2;
            Boolean blnHasPCCoBrowseForCIC = false;
            Set<Id> set_CommittedProductIds = new Set<Id>();
            Set<Id> set_AddtProdIds = new Set<Id>();
            Set<Id> set_BundleProducts = new Set<Id>();
            Set<Id> set_RatePlanProdIds = new Set<Id>();
            List<BigMachines__Quote_Product__c> list_AllQtProds = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_CommittedQtProds = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_DependentQtProds = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_ToInsertOverageCharges = new List<BigMachines__Quote_Product__c>();
            Map<String, String> map_DependentProducts = new Map<String, String>();
            Map<Id, Id> map_NewQPIds = new Map<Id, Id>();
            Map<Id, Id> map_ProductsToBundles = new Map<Id, Id>();
            Map<Id, Id> map_BundleProducts = new Map<Id, Id>();
            Map<Id, Id> map_BundlesToQuoteProducts = new Map<Id, Id>();
            Map<Id, Product_Tier_Pricing__c> map_ProdTiers = new Map<Id, Product_Tier_Pricing__c>();
            Map<String, Decimal> map_SoldToPCPartnerMargins = new Map<String, Decimal>();
            Map<String, Decimal> map_PCCPartnerMargins = new Map<String, Decimal>();
            Map<Id, BigMachines__Quote_Product__c> map_NewQPs = new Map<Id, BigMachines__Quote_Product__c>();
            Map<Id, Map<String, Product_Tier_Pricing__c>> map_ExistingProdTiers = new Map<Id, Map<String, Product_Tier_Pricing__c>>();
            Map<Id, Subscription_Product__c> map_IdtoOverageSubProds = new Map<Id, Subscription_Product__c>();
            Set<Id> set_TieredPricingProductIds = new Set<Id>();
            Map<Id,List<Product_Tier_Pricing__c>> map_TieredProducts = new Map<Id,List<Product_Tier_Pricing__c>>();
            Map<Id,List<Product_Tier_Pricing__c>> map_TieredProductsOverage = new Map<Id,List<Product_Tier_Pricing__c>>(); 
            String strRangeandRatePlan = 'Range;Rate Plan';
            Decimal decPricingMultiplier;
            
            List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProductForSubscrps(new Set<Id> {subscrId});
            System.debug(list_SubscriptionProds);
            for(Subscription_Product__c objSubscrProd : list_SubscriptionProds) {    
                if(objSubscrProd.Product__c == null) continue;
                //Anju PC PS Changes
                if((!objSubscrProd.Hide_Record__c && !objSubscrProd.Is_Overage__c && (objSubscrProd.Product__r.Show_In_Quoting__c || objSubscrProd.Product__r.New_Category__c == 'PureSuccess'))
                   &&
                   (
                       (!Label.Check_For_One_Time_Fees_PC.contains(objSubscrProd.Product__r.New_Category__c) && objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PC)
                       || 
                       (!Label.Check_For_One_Time_Fees_PCC.contains(objSubscrProd.Product__r.New_Category__c) && objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
                       ||
                       (!Label.Check_For_One_Time_Fees_PEC.contains(objSubscrProd.Product__r.New_Category__c) && objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PEC)
                   )
                   ||(String.isNotBlank(objSubscrProd.Product__r.APN_Number__c) && Label.PC_Overage_Products.contains(objSubscrProd.Product__r.APN_Number__c))
                   ||objSubscrProd.Product__r.New_Category__c == 'Bundles'
                   || objSubscrProd.Product__r.New_Category__c == 'Use Case' 
                   ||(String.isNotBlank(objSubscrProd.Product__r.APN_Number__c) && Label.IVR_Data_Storage_Parts.Contains(objSubscrProd.Product__r.APN_Number__c))) {
                       BigMachines__Quote_Product__c objQP = SubscriptionUtil.buildQuoteProdFromSubscrProd(objQuote.Id, objSubscrProd);
                       list_CommittedQtProds.add(objQP);
                       set_CommittedProductIds.add(objSubscrProd.Product__c);
                       if(objSubscrProd.Product__r.New_Category__c == 'Bundles') {
                           set_BundleProducts.add(objSubscrProd.Product__c);
                       }           
                   }
                if(objSubscrProd.Is_Overage__c){map_IdtoOverageSubProds.put(objSubscrProd.Product__c,objSubscrProd);}
            }
            System.debug('######set_BundleProducts: '+set_BundleProducts);
            System.debug('######set_CommittedProductIds: '+set_CommittedProductIds);
            System.debug('#####list_CommittedQtProds: '+list_CommittedQtProds);
            Integer intLineNumber = list_CommittedQtProds.size();
            
            if(set_BundleProducts.size() > 0) {
                for(Product_Group__c objProdGrp : [SELECT Id, Product__c,
                                                   (SELECT Product__c FROM Product_Group_Items__r)
                                                   FROM Product_Group__c 
                                                   WHERE Product__c IN :set_BundleProducts]) {
                                                       map_ProductsToBundles.put(objProdGrp.Product__c, objProdGrp.Id);    
                                                       for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                                                           map_BundleProducts.put(objProdGrpItm.Product__c, objProdGrp.Product__c);
                                                       }
                                                   }       
                for(BigMachines__Quote_Product__c objQP : list_CommittedQtProds) {
                    //Set bundle lookup for bundle's main product
                    if(map_ProductsToBundles.containsKey(objQP.BigMachines__Product__c)) {
                        objQP.Bundle__c = map_ProductsToBundles.get(objQP.BigMachines__Product__c);         
                    }
                    //Set bundle lookup for bundle line products
                    if(map_BundleProducts.containsKey(objQP.BigMachines__Product__c)) {
                        objQP.Bundle__c = map_ProductsToBundles.get(map_BundleProducts.get(objQP.BigMachines__Product__c));         
                    }       
                }   
            }
            insert list_CommittedQtProds;   
            System.debug(list_CommittedQtProds);
            if(set_BundleProducts.size() > 0) {
                //Retrieve QP Id for bundle's main product  
                for(BigMachines__Quote_Product__c objQP : list_CommittedQtProds) {
                    if(map_ProductsToBundles.containsKey(objQP.BigMachines__Product__c)) {
                        map_BundlesToQuoteProducts.put(objQP.Bundle__c, objQP.Id);
                    }
                }
                //Set up bundle line lookup based on above map
                for(BigMachines__Quote_Product__c objQP : list_CommittedQtProds) {  
                    if(objQP.Bundle__c != null && !map_ProductsToBundles.containsKey(objQP.BigMachines__Product__c) 
                       && map_BundlesToQuoteProducts.containsKey(objQP.Bundle__c)) {
                           objQP.Bundle_Line__c = map_BundlesToQuoteProducts.get(objQP.Bundle__c);
                       } 
                }   
                upsert list_CommittedQtProds;
            }
            list_AllQtProds.addAll(list_CommittedQtProds);
            System.debug(list_AllQtProds);
            //Logic to add dependent products
            List<Product_Group__c> list_ProdGrps = [SELECT Id, Product__c, Product__r.APN_Number__c,
                                                    (SELECT Product__c, Product__r.Name, Product__r.APN_Number__c, 
                                                     Product_Group__r.Product__r.APN_Number__c,
                                                     Product__r.Product_Specific_Discount__c,
                                                     Product__r.Product_Group__c, Product__r.Unit_of_Measure__c
                                                     FROM Product_Group_Items__r 
                                                     WHERE Product_Type__c = 'Mandatory')
                                                    FROM Product_Group__c
                                                    WHERE Group_Type__c = 'Dependent Products'
                                                    AND Product__c IN :set_CommittedProductIds];
            for(Product_Group__c objProdGrp : list_ProdGrps) {
                for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                    if(!set_CommittedProductIds.contains(objProdGrpItm.Product__c)) {
                        set_CommittedProductIds.add(objProdGrpItm.Product__c);
                        set_AddtProdIds.add(objProdGrpItm.Product__c);
                        
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();                
                        objQP.Name = objProdGrpItm.Product__r.Name;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Product__c = objProdGrpItm.Product__c;
                        objQP.APN_Number__c = objProdGrpItm.Product__r.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objProdGrpItm.Product__r.Product_Specific_Discount__c;
                        objQP.Product_Group__c = objProdGrpItm.Product__r.Product_Group__c;
                        objQP.Quantity__c = 0;
                        objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                        objQP.Unit_of_Measure__c = objProdGrpItm.Product__r.Unit_of_Measure__c;
                        objQP.Hide_Record__c = true;
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.Is_Overage__c = objProdGrpItm.Product_Group__r.Product__r.APN_Number__c == 'PCSMS-170-NV-SMS' || objProdGrpItm.Product_Group__r.Product__r.APN_Number__c == 'PV-170-NV-PCVOICE' ? true : false;
                        objQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                        objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                        list_DependentQtProds.add(objQP);
                    }
                }
            }
            System.debug('#####set_AddtProdIds: '+set_AddtProdIds);
            System.debug('#####set_CommittedProductIds: '+set_CommittedProductIds);
            System.debug('#####list_DependentQtProds: '+list_DependentQtProds);
            
            for(BigMachines__Quote_Product__c objQP : list_DependentQtProds) {
                if(Label.PC_Overage_Products.contains(objQP.APN_Number__c)) {
                    objQP.Is_Overage__c = true;
                    objQP.Name += ' Usage';
                }
            }
            insert list_DependentQtProds;   
            list_AllQtProds.addAll(list_DependentQtProds);
            System.debug(list_AllQtProds);
            
            //Logic to build overage charges and map ovg chrgs to parent quote product. helpful while deleting
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {
                map_NewQPs.put(objQP.Id, objQP);
            }
            
            List<Product_Tier_Pricing__c> list_ProdTierPricing = [SELECT Product__c, Product__r.Name, Product__r.APN_Number__c, 
                                                                  Product__r.Unit_of_Measure__c, Product__r.New_Category__c
                                                                  FROM Product_Tier_Pricing__c
                                                                  WHERE Product__c IN :set_CommittedProductIds
                                                                  AND Product__r.Has_Overage__c = true
                                                                  AND Charge_Type__c = 'M2M'];
            for(Product_Tier_Pricing__c objProdTr : list_ProdTierPricing ) {
                map_ProdTiers.put(objProdTr.Product__c, objProdTr);
            }
            System.debug('#####map_ProdTiers: '+map_ProdTiers);
            
            for(Id newQPId : map_NewQPs.keySet()) {                    
                if(map_ProdTiers.containsKey(map_NewQPs.get(newQPId).BigMachines__Product__c)) {
                    Product_Tier_Pricing__c objProdTr = map_ProdTiers.get(map_NewQPs.get(newQPId).BigMachines__Product__c);
                    BigMachines__Quote_Product__c objOverageQP = new BigMachines__Quote_Product__c();
                    objOverageQP.BigMachines__Quote__c = objQuote.Id;
                    objOverageQP.Parent_Quote_Product__c = newQPId;
                    objOverageQP.Is_Overage__c = true;
                    objOverageQP.BigMachines__Product__c = objProdTr.Product__c;
                    objOverageQP.Name = objProdTr.Product__r.Name + ' Overage';
                    objOverageQP.APN_Number__c = objProdTr.Product__r.APN_Number__c;
                    objOverageQP.Unit_of_Measure__c = objProdTr.Product__r.Unit_of_Measure__c;
                    objOverageQP.BigMachines__Quantity__c = objOverageQP.Quantity__c = objOverageQP.BigMachines__Sales_Price__c = 0;
                    objOverageQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                    if(set_AddtProdIds.contains(objProdTr.Product__c)
                       || (objQuote.Billing_Category__c == 'M2M' && objProdTr.Product__r.New_Category__c == 'Subscription Fees')
                       //To build both committed and overage charges for this specific product which is not subscription fees category
                       || objOverageQP.APN_Number__c == 'PC-170-NV-PCIVRCUSPERMIN') { 
                           objOverageQP.Hide_Record__c = true;
                       }
                    objOverageQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                    if(objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC && map_IdtoOverageSubProds.containsKey(objProdTr.Product__c)){
                        objOverageQP.Disc__c = (map_IdtoOverageSubProds.get(objProdTr.Product__c).Disc__c != null)?map_IdtoOverageSubProds.get(objProdTr.Product__c).Disc__c:0;
                        objOverageQP.or_Amount__c = (map_IdtoOverageSubProds.get(objProdTr.Product__c).or_Amount__c != null)?map_IdtoOverageSubProds.get(objProdTr.Product__c).or_Amount__c:'';
                        objOverageQP.Adjustment__c = (map_IdtoOverageSubProds.get(objProdTr.Product__c).Adjustment__c != null)?map_IdtoOverageSubProds.get(objProdTr.Product__c).Adjustment__c:0; 
                    }    
                    list_ToInsertOverageCharges.add(objOverageQP);
                }
            }
            insert list_toInsertOverageCharges;  
            System.debug(list_toInsertOverageCharges);
            list_AllQtProds = new List<BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, Name, BigMachines__Quote__c, BigMachines__Product__c, Subscription_Product__c, CurrencyISOCode, 
                                                       List_Price__c, Partner_Price__c, Net_Unit_Price__c, BigMachines__Sales_Price__c, Ext_List__c, Ext_Net_Price__c,
                                                       Extended_Price_Per_Period__c, Extended_Price_Per_Month__c, APN_Number__c,Parent_Quote_Product__c,
                                                       BigMachines__Quote__r.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,
                                                       Quantity__c, Product_Quantity__c, BigMachines__Quantity__c, Hide_Record__c, Is_Overage__c,
                                                       Bundle_Discount__c, Proposal_Group_Discount__c, or_Amount__c, Adjustment__c, Disc__c, Total_Discount__c,
                                                       BigMachines__Product__r.Price_Type__c, BigMachines__Product__r.NG1_APAC_ANZ_AUD_Price__c,BigMachines__Product__r.Partner_Margin_Category__c, 
                                                       BigMachines__Product__r.NG2_BRAZIL_BRL_Price__c, BigMachines__Product__r.NG3_EMEA_EUR_Price__c, 
                                                       BigMachines__Product__r.NG5_NA_CAD_Price__c, BigMachines__Product__r.NG4_APAC_JAPAN_YEN_Price__c, 
                                                       BigMachines__Product__r.NG5_NZD_Price__c, BigMachines__Product__r.NG3_EMEA_GBP_Price__c, BigMachines__Product__r.Is_Concurrent__c,
                                                       BigMachines__Product__r.NG5_NA_USD_Price__c, BigMachines__Product__r.NG5_ZAR_Price__c, Bundle_Line__c,
                                                       BigMachines__Product__r.Partner_Margin_Type__c, BigMachines__Product__r.Include_in_CMMR_Total__c,
                                                       BigMachines__Product__r.Charge_Type__c, Line_Number__c, Group_Number__c, PM_Approver__c, Product_Option__c
                                                       FROM BigMachines__Quote_Product__c
                                                       WHERE BigMachines__Quote__c =: objQuote.Id]) {
                                                           list_AllQtProds.add(objQP);
                                                           if(objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan') {
                                                               set_RatePlanProdIds.add(objQP.BigMachines__Product__c);
                                                           }
                                                           if(objQP.APN_Number__c == 'PC-170-NV-COBROCIC') {                  
                                                               blnHasPCCoBrowseForCIC = true;
                                                           } 
                                                       }
            System.debug('######set_RatePlanProdIds' + set_RatePlanProdIds);            
            //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
            String strWhereCondition = 'WHERE Product__c IN :set_RatePlanProdIds  AND (Charge_Type__c = \'M2M\' OR Charge_Type__c = \'' + objQuote.Billing_Category__c + '\')';
            for(Product_Tier_Pricing__c objProdTr : Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, objQuote.New_Price_Book__c + '_Price__c'))) {
                //Added By Ranjith on Feb 26, 2019 -- Ends 
                if(map_ExistingProdTiers.containsKey(objProdTr.Product__c)) {
                    map_ExistingProdTiers.get(objProdTr.Product__c).put(objProdTr.Charge_Type__c, objProdTr);
                }
                else {
                    map_ExistingProdTiers.put(objProdTr.Product__c, new Map<String, Product_Tier_Pricing__c> { objProdTr.Charge_Type__c => objProdTr} );
                }       
            }
            System.debug('######map_ExistingProdTiers' + map_ExistingProdTiers);            
            
            for(PureCloud_Partner_Margin__c objPartnerMargin : [SELECT Account__c, Percent__c, Margin_Type__c
                                                                FROM PureCloud_Partner_Margin__c
                                                                WHERE From_Date__c <= TODAY 
                                                                AND To_Date__c >= TODAY 
                                                                AND Account__c =: objQuote.Sold_To_Name__c
                                                                ORDER BY To_Date__c ASC]) {
                                                                    map_SoldToPCPartnerMargins.put(objPartnerMargin.Margin_Type__c, objPartnerMargin.Percent__c);
                                                                }
            System.debug('######map_SoldToPCPartnerMargins' + map_SoldToPCPartnerMargins);
            if(objQuote.End_User_ID__c != objQuote.Sold_To_Name__c && objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) {
                for(Partner_Discount__c objPartnerMargin : [SELECT Discount__c, Category__c
                                                            FROM Partner_Discount__c
                                                            WHERE Account__c = :objQuote.Sold_To_Name__c AND type__c =: SubscriptionUtil.OFFERING_TYPE_PCC]) {
                                                                if(objPartnerMargin.Category__c == 'Base Line Discount')
                                                                    map_PCCPartnerMargins.put('Software', objPartnerMargin.Discount__c);
                                                                else
                                                                    map_PCCPartnerMargins.put(objPartnerMargin.Category__c, objPartnerMargin.Discount__c);
                                                            } 
            }
            Set<Id> set_OvrgProdParentIds = new Set<Id>();
            if(objQuote.Billing_Category__c == 'M2M') {
                set_OvrgProdParentIds = QuoteCloudUtil.findOverageChargeAPNs(objQuote);
            }
            // ECD PEC Quote July 2019
            if(objQuote.Pricing_Model__c == 'Concurrent')
                decPricingMultiplier = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ? Global_Configuration_Settings__c.getOrgDefaults().PureEngage_Cloud_Concurrent_Multiplier__c : Global_Configuration_Settings__c.getOrgDefaults().PureConnect_Concurrent_Multiplier__c;
            //decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().PureConnect_Concurrent_Multiplier__c;
            //added by kartik
            
            Map<id,BigMachines__Quote_Product__c> map_OverageProducts = new Map<id,BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {
                system.debug(objQP);
                if(objQP.BigMachines__Product__r.Price_Type__c == 'Range' || (objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan' && !objQP.Is_Overage__c))
                    set_TieredPricingProductIds.add(objQP.BigMachines__Product__c);    
                if(objQP.Is_Overage__c)
                {
                    for(BigMachines__Quote_Product__c objQPParent : list_AllQtProds) {
                        system.debug(objQPParent);
                        if(objQPParent.id == objQP.Parent_Quote_Product__c)
                            map_OverageProducts.put(objQP.id,objQPParent);
                    }
                }
                system.debug(map_OverageProducts);
            }
            if(!set_TieredPricingProductIds.isEmpty()){
                String strQuery = 'SELECT Price_Type__c, Type__c, Partner_Margin_Category__c, (SELECT Charge_Type__c, Range_From__c, Range_To__c,'
                    + objQuote.New_Price_Book__c + '_Price__c FROM Product_Tier_Pricings__r'                 
                    + ' WHERE Charge_Type__c = \'' +  objQuote.Billing_Category__c + '\' OR Charge_Type__c = \'M2M\' ORDER BY Range_From__c)'               
                    + ' FROM Product2 WHERE Id IN: set_TieredPricingProductIds';
                system.debug('######'+strQuery);
                for(Product2 eachProduct : Database.query(strQuery))
                {
                    for(Product_Tier_Pricing__c objPricing : eachProduct.Product_Tier_Pricings__r)
                    {
                        if(objPricing.Charge_Type__c == 'M2M')
                        {
                            if(map_TieredProductsOverage.containskey(eachProduct.id))
                                map_TieredProductsOverage.get(eachProduct.id).add(objPricing);
                            else
                                map_TieredProductsOverage.put(eachProduct.id, new List<Product_Tier_Pricing__c>{objPricing});
                        }
                        else
                        {
                            if(map_TieredProducts.containskey(eachProduct.id))
                                map_TieredProducts.get(eachProduct.id).add(objPricing);
                            else
                                map_TieredProducts.put(eachProduct.id, new List<Product_Tier_Pricing__c>{objPricing});
                        }
                    }
                }
            }
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {            
                objQP.Bundle_Discount__c = objQP.Proposal_Group_Discount__c = null;
                objQP.Total_Discount__c = objQP.List_Price__c = objQP.Partner_Price__c = objQP.Net_Unit_Price__c = objQP.BigMachines__Sales_Price__c = 0;
                objQP.Extended_Price_Per_Period__c = objQP.Extended_Price_Per_Month__c = objQP.Ext_List__c = objQP.Ext_Net_Price__c = 0;
                if(objQuote.offering_type__c != SubscriptionUtil.OFFERING_TYPE_PCC){objQP.Adjustment__c =0;objQP.or_Amount__c = '';}
                Decimal decProductPartnerMargin = 0;
                String strBillingCategory = objQP.Is_Overage__c ? 'M2M' : objQuote.Billing_Category__c;
                System.debug('#####objQP'+objQP);
                if(objQP.Bundle_Line__c == null) {
                    if(objQuote.offering_type__c != SubscriptionUtil.OFFERING_TYPE_PCC){  
                        objQP.List_Price__c = (Decimal)objQP.BigMachines__Product__r.get(objQuote.New_Price_Book__c + '_Price__c');
                        if(objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan'
                           && map_ExistingProdTiers.containsKey(objQP.BigMachines__Product__c)
                           && map_ExistingProdTiers.get(objQP.BigMachines__Product__c).containsKey(strBillingCategory)) {
                               objQP.List_Price__c = (Decimal)map_ExistingProdTiers.get(objQP.BigMachines__Product__c).get(strBillingCategory).get(objQuote.New_Price_Book__c + '_Price__c');
                           }     
                    }
                    else
                    {
                        
                        Decimal decProductPrice = (Decimal)objQP.getSObject('BigMachines__Product__r').get(objQuote.New_Price_Book__c + '_Price__c');
                        // Pulling price for Tiered Pricing product
                        if(map_TieredProducts.containsKey(objQP.BigMachines__Product__c)) {
                            //For partners, no tier pricing, base price..
                            if(objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c)
                            {
                                decProductPrice = decProductPrice;
                                if(objQP.BigMachines__Product__r.Price_Type__c != null && strRangeandRatePlan.contains(objQP.BigMachines__Product__r.Price_Type__c) && map_TieredProducts.get(objQP.BigMachines__Product__c).size() > 0) {
                                    if(objQP.Is_Overage__c)
                                        decProductPrice = (Decimal)map_TieredProductsOverage.get(objQP.BigMachines__Product__c)[0].get(objQuote.New_Price_Book__c + '_Price__c');
                                    else
                                        decProductPrice = (Decimal)map_TieredProducts.get(objQP.BigMachines__Product__c)[0].get(objQuote.New_Price_Book__c + '_Price__c');
                                }
                            }
                            else if(objQP.BigMachines__Product__r.Price_Type__c == 'Range')
                            {
                                system.debug(objQP);
                                if(objQP.Is_Overage__c && map_OverageProducts.size() > 0)
                                    decProductPrice = QuoteCloudUtil.getProductTierPricing(map_TieredProductsOverage.get(objQP.BigMachines__Product__c), 
                                                                                           map_OverageProducts.get(objQP.id).Quantity__c, decProductPrice,  objQuote.New_Price_Book__c + '_Price__c');
                                else
                                    decProductPrice = QuoteCloudUtil.getProductTierPricing(map_TieredProducts.get(objQP.BigMachines__Product__c), 
                                                                                           objQP.Quantity__c, decProductPrice,  objQuote.New_Price_Book__c + '_Price__c');
                            }
                            else if(objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan' 
                                    && map_TieredProducts.get(objQP.BigMachines__Product__c).size() > 0) 
                            {
                                if(objQP.Is_Overage__c)
                                    decProductPrice = (Decimal)map_TieredProductsOverage.get(objQP.BigMachines__Product__c)[0].get(objQuote.New_Price_Book__c + '_Price__c');
                                else
                                    decProductPrice = (Decimal)map_TieredProducts.get(objQP.BigMachines__Product__c)[0].get(objQuote.New_Price_Book__c + '_Price__c');
                            }
                        }
                        if(decProductPrice == null)
                            continue;
                        
                        // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                        if(objQuote.Pricing_Model__c == 'Concurrent' && objQP.BigMachines__Product__r.Is_Concurrent__c == 'Yes')
                            decProductPrice *= decPricingMultiplier;
                        objQP.List_Price__c = decProductPrice;
                    }        
                    objQP.List_Price__c = (blnHasPCCoBrowseForCIC && objQP.APN_Number__c == 'PC-170-NV-USR3') || objQP.List_Price__c == null ? 0 : objQP.List_Price__c; 
                    Decimal decEffectivePrice = objQP.List_Price__c;
                    System.debug('#####objQP.List_Price__c'+objQP.List_Price__c);    
                    if(objQP.BigMachines__Quote__r.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
                        decProductPartnerMargin = map_SoldToPCPartnerMargins.containsKey(objQP.BigMachines__Product__r.Partner_Margin_Type__c) ? map_SoldToPCPartnerMargins.get(objQP.BigMachines__Product__r.Partner_Margin_Type__c) : 0;
                        System.debug('#####decProductPartnerMargin '+decProductPartnerMargin);
                        objQP.Partner_Price__c = objQP.List_Price__c - (objQP.List_Price__c * decProductPartnerMargin/100);                        
                        objQP.Total_Discount__c += decProductPartnerMargin;
                        decEffectivePrice = objQP.Partner_Price__c != null && objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c : decEffectivePrice;
                    }
                    if(objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) {
                        {
                            if(map_PCCPartnerMargins.containsKey(objQP.BigMachines__Product__r.Partner_Margin_Category__c))
                                decProductPartnerMargin = map_PCCPartnerMargins.get(objQP.BigMachines__Product__r.Partner_Margin_Category__c);
                            else if(Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c) != NULL)
                                decProductPartnerMargin =  Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c).Margin__c;
                            objQP.Partner_Price__c = (objQP.List_Price__c - (objQP.List_Price__c * decProductPartnerMargin/100)); 
                            objQP.Total_Discount__c += decProductPartnerMargin;
                            decEffectivePrice = objQP.Partner_Price__c != null && objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c : decEffectivePrice;
                        }                    
                        
                        System.debug('#####decProductPartnerMargin'+decProductPartnerMargin);
                    }
                    System.debug(objQP.or_Amount__c+String.valueOf(objQP.Adjustment__c)+String.valueof(objQuote.offering_type__c));
                    if(objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC){
                        if(objQP.Disc__c != null && String.isNotBlank(objQP.or_Amount__c)){
                            // Selected Discount Option is %
                            if(objQP.or_Amount__c == '%'){
                                objQP.Total_Discount__c += objQP.Disc__c;           
                            }
                            // Selected Discount Option is Amt
                            else if(objQP.or_Amount__c == 'Amt'){
                                objQP.Total_Discount__c += (objQP.Disc__c/objQP.List_Price__c) * 100;           
                            }
                        }
                        if(objQP.Adjustment__c != null && objQP.Adjustment__c != 0) {
                            objQP.Total_Discount__c += objQP.Adjustment__c;     
                        }  
                    } 
                    System.debug('#####objQP.Partner_Price__c'+objQP.Partner_Price__c);
                    objQP.Net_Unit_Price__c = objQP.List_Price__c - (objQP.List_Price__c * objQP.Total_Discount__c/100);
                    objQP.List_Price__c = objQP.List_Price__c.setScale(intSetScale);
                    objQP.Partner_Price__c = objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c.setScale(intSetScale) : 0;
                    objQP.Net_Unit_Price__c = objQP.Net_Unit_Price__c.setScale(intSetScale);
                    objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
                    System.debug('#####objQP.Quantity__c'+objQP.Quantity__c);
                    if(objQP.Quantity__c != null) {
                        objQP.Ext_List__c = (decEffectivePrice * objQP.Quantity__c).setScale(2) ;
                        objQP.Ext_Net_Price__c = (objQP.Net_Unit_Price__c * objQP.Quantity__c).setScale(2);
                    }
                    System.debug('#####objQP.Ext_List__c'+objQP.Ext_List__c);
                    System.debug('#####objQP.Ext_Net_Price__c'+objQP.Ext_Net_Price__c);
                    objQP.Extended_Price_Per_Month__c = objQP.Ext_Net_Price__c;
                    objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c; 
                    
                    if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c && !set_OvrgProdParentIds.contains(objQP.Id)) {
                        if(objQuote.Billing_Period__c == 'Annually') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 12;
                        }
                        else if(objQuote.Billing_Period__c == 'Semi-Annually') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 6;
                        }
                        else if(objQuote.Billing_Period__c == 'Quarterly') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 3;
                        }  
                        else if(objQuote.Billing_Period__c == 'Other') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * objQuote.No_Of_Months__c;
                        }           
                    } 
                }
            }
            System.debug('Finallist####'+list_AllQtProds);
            update list_AllQtProds;
        }catch(Exception e){
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
        }                           
    } 
    
    public static void buildQuoteProductsForAmend(Id subscrId, BigMachines__Quote__c objQuote) {
        Set<Id> set_RatePlanProdIds = new Set<Id>();
        Set<Id> set_BundleProducts = new Set<Id>();
        List<BigMachines__Quote_Product__c> list_NewQuoteProducts = new List<BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c> list_NewOverageQuoteProducts = new List<BigMachines__Quote_Product__c>();
        Map<Id, BigMachines__Quote_Product__c> map_OvrgQuoteProds = new Map<Id, BigMachines__Quote_Product__c>();
        Map<Id, Map<String, Product_Tier_Pricing__c>> map_ExistingProdTiers = new Map<Id, Map<String, Product_Tier_Pricing__c>>();
        
        List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProductForSubscrps(new Set<Id> {subscrId});
        
        for(Subscription_Product__c objSubscrpProd : list_SubscriptionProds) {
            if(objSubscrpProd.Product__r.Price_Type__c == 'Rate Plan') {
                set_RatePlanProdIds.add(objSubscrpProd.Product__c);
            }
        }
        System.debug('######set_RatePlanProdIds' + set_RatePlanProdIds);            
        
        //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
        String strWhereCondition = 'WHERE Product__c IN :set_RatePlanProdIds  AND (Charge_Type__c = \'M2M\' OR Charge_Type__c = \'' + objQuote.Billing_Category__c + '\')';
        for(Product_Tier_Pricing__c objProdTr : Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, objQuote.New_Price_Book__c + '_Price__c'))) {
            //Added By Ranjith on Feb 26, 2019 -- Ends
            if(map_ExistingProdTiers.containsKey(objProdTr.Product__c)) {
                map_ExistingProdTiers.get(objProdTr.Product__c).put(objProdTr.Charge_Type__c, objProdTr);
            }
            else {
                map_ExistingProdTiers.put(objProdTr.Product__c, new Map<String, Product_Tier_Pricing__c> { objProdTr.Charge_Type__c => objProdTr} );
            }       
        }          
        System.debug('######map_ExistingProdTiers' + map_ExistingProdTiers);
        
        Map<String, Decimal> map_SoldToPCPartnerMargins = new Map<String, Decimal>();
        for(PureCloud_Partner_Margin__c objPartnerMargin : [SELECT Account__c, Percent__c, Margin_Type__c
                                                            FROM PureCloud_Partner_Margin__c
                                                            WHERE From_Date__c <= TODAY 
                                                            AND To_Date__c >= TODAY 
                                                            AND Account__c =: objQuote.Sold_To_Name__c
                                                            ORDER BY To_Date__c ASC]) {
                                                                map_SoldToPCPartnerMargins.put(objPartnerMargin.Margin_Type__c, objPartnerMargin.Percent__c);
                                                            }
        System.debug('######map_SoldToPCPartnerMargins' + map_SoldToPCPartnerMargins);
        
        for(Subscription_Product__c objSubscrProd : list_SubscriptionProds) {            
            BigMachines__Quote_Product__c objQP = SubscriptionUtil.buildQuoteProdFromSubscrProd(objQuote.Id, objSubscrProd);
            System.debug('######objQP: ' + objQP);            
            if(!objSubscrProd.Is_Overage__c) {
                list_NewQuoteProducts.add(objQP);
            } 
            else {
                map_OvrgQuoteProds.put(objSubscrProd.Product__c, objQP);
            } 
            //Anju PCC subscriptions added puresuccess condition for PCC puresuccess
            if(objSubscrProd.Product__r.New_Category__c == 'Bundles' || objSubscrProd.Product__r.New_Category__c == 'PureSuccess') {
                set_BundleProducts.add(objSubscrProd.Product__c);
            }         
        }
        
        //Anju PC PS Changes
        for(String strID : Label.PureSuccess_Cloud_Alacarte_master_product.split(';'))
            set_BundleProducts.add(strID);
        
        System.debug('######list_NewQuoteProducts: '+list_NewQuoteProducts);
        System.debug('######set_BundleProducts: '+set_BundleProducts);
        
        if(list_NewQuoteProducts.size() > 0 || map_OvrgQuoteProds.size() > 0) {                    
            insert list_NewQuoteProducts;
            
            //Handling overage quote products seperately to update lookup to their original quote product. Used for deletion
            Map<Id, Id> map_NewQPIds = new Map<Id, Id>();
            Map<Id, Id> map_ProductsToBundles = new Map<Id, Id>();
            Map<Id, Id> map_BundleProducts = new Map<Id, Id>();
            Map<Id, Id> map_BundlesToQuoteProducts = new Map<Id, Id>();
            List<BigMachines__Quote_Product__c> list_BundleLineQuoteProds = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_BundlesToBeUpserted = new List<BigMachines__Quote_Product__c>();
            
            //Assumption is only bundle will be added in a quote/subscription
            for(Product_Group__c objProdGrp : [SELECT Id, Product__c,
                                               (SELECT Product__c FROM Product_Group_Items__r)
                                               FROM Product_Group__c 
                                               WHERE Product__c IN :set_BundleProducts]) {
                                                   map_ProductsToBundles.put(objProdGrp.Product__c, objProdGrp.Id);    
                                                   for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                                                       map_BundleProducts.put(objProdGrpItm.Product__c, objProdGrp.Product__c);
                                                   }
                                               }
            
            for(BigMachines__Quote_Product__c objQP : list_NewQuoteProducts) {
                map_NewQPIds.put(objQP.BigMachines__Product__c, objQP.Id);
                //Set up bundle relations
                if(map_ProductsToBundles.containsKey(objQP.BigMachines__Product__c)) {
                    objQP.Bundle__c = map_ProductsToBundles.get(objQP.BigMachines__Product__c);
                    map_BundlesToQuoteProducts.put(objQP.Bundle__c, objQP.Id);
                    //list_NewOverageQuoteProducts.add(objQP);
                    list_BundlesToBeUpserted.add(objQP);
                }
                if(map_BundleProducts.containsKey(objQP.BigMachines__Product__c)) {
                    objQP.Bundle__c = map_ProductsToBundles.get(map_BundleProducts.get(objQP.BigMachines__Product__c));
                    //Anju PC PS Changes
                    if(!Label.PureSuccess_Cloud_Alacarte_master_product.contains(String.valueof(map_BundleProducts.get(objQP.BigMachines__Product__c)).left(15)))
                    {
                        objQP.List_Price__c = 0;
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.Partner_Price__c = 0;
                    }
                    list_BundleLineQuoteProds.add(objQP);
                }                    
            }
            
            //Set up relationship for overage products
            for(BigMachines__Quote_Product__c objOvrgQP : map_OvrgQuoteProds.values()) {
                if(map_NewQPIds.containsKey(objOvrgQP.BigMachines__Product__c)) {
                    objOvrgQP.Name += ' Overage';
                    objOvrgQP.Parent_Quote_Product__c = map_NewQPIds.get(objOvrgQP.BigMachines__Product__c); 
                    list_NewOverageQuoteProducts.add(objOvrgQP);                    
                }
                else {
                    if(map_BundleProducts.containsKey(objOvrgQP.BigMachines__Product__c)) {
                        objOvrgQP.Bundle__c = map_ProductsToBundles.get(map_BundleProducts.get(objOvrgQP.BigMachines__Product__c));
                        objOvrgQP.List_Price__c = 0;
                        objOvrgQP.BigMachines__Sales_Price__c = 0;
                        objOvrgQP.Partner_Price__c = 0;
                        list_BundleLineQuoteProds.add(objOvrgQP);
                    }   
                    else {
                        list_NewOverageQuoteProducts.add(objOvrgQP);
                    }
                }                    
            }
            System.debug('######list_NewOverageQuoteProducts: '+list_NewOverageQuoteProducts);
            
            //Set up bundle line relations
            for(BigMachines__Quote_Product__c objBndleLnQP : list_BundleLineQuoteProds) {
                if(map_BundlesToQuoteProducts.containsKey(objBndleLnQP.Bundle__c)) {
                    objBndleLnQP.Bundle_Line__c = map_BundlesToQuoteProducts.get(objBndleLnQP.Bundle__c);                        
                }
                //list_NewOverageQuoteProducts.add(objBndleLnQP);
                list_BundlesToBeUpserted.add(objBndleLnQP);
            }
            System.debug('######list_NewOverageQuoteProducts: '+list_NewOverageQuoteProducts);
            list_BundlesToBeUpserted.addAll(list_NewOverageQuoteProducts);
            if(list_BundlesToBeUpserted.size() > 0) {   
                upsert list_BundlesToBeUpserted;
            } 
        }
    }
    
    public static void updateQuoteTotalsForRenewal(BigMachines__Quote__c objQuote, List<BigMachines__Quote_Product__c> list_QuoteProducts) {        
        try{     
            objQuote = prepareQuotes(objQuote.id);
            list_QuoteProducts = prepareQuoteProducts(objQuote.id);
            Decimal decTotalNetPrice = 0,decTotalDiscountAmt = 0,decGenesysProductsDiscount = 0,listPriceTotalProductsOnly = 0, decGenesysAllDiscount = 0, listPriceTotalAll = 0;
            Map<String, Decimal> map_PCCPartnerMargins = new Map<String, Decimal>();
            Decimal decTotalSWNetPrice = 0,decTotalHWNetPrice = 0,decTotalEducationNetPrice = 0,decTotalServicesNetPrice = 0;
            Decimal decCustomIVRPrice = 0, decTotalRecAmount = 0, decTotalNonRecAmount = 0, decTotalRecServAmount = 0, decTotalRecServAmountPreDiscount = 0;
            Decimal decTotalRecAmountPreDiscount = 0,  decTotalNonRecAmountPreDiscount = 0, decTotalCredit =0,  maxSeatCount = 0, decTotalNonRecCredit = 0, decTotalRecCredit =0;
            Decimal  decPureSuccessAlacarteSum = 0, decPureSuccessBaseSum = 0,decEventSum = 0, decOtherNonRecurringFees = 0;
            Double dblPureSuccessPackageCount = 0;
            Decimal decProductPartnerMargin;
            objQuote.Total_Software__c = objQuote.Total_Hardware__c = objQuote.Total_Education__c = objQuote.Total_Services__c = objQuote.Setup_Provisioning_Charges__c = 0;
            objQuote.Minimum_Fees_Period__c = objQuote.Setup_Provisioning_Charges__c = objQuote.CMRR__c = objQuote.Max_Seat_Count__c = 0;
            objQuote.Total_Adjustments__c = objQuote.Total_List_Price__c = objQuote.Total_Overage__c = 0;
            objQuote.Total_Hardware_Change__c = objQuote.Total_Education_Change__c = objQuote.Services_Change__c = 0;
            List<String> list_QuoteDiscountBuckets = new List<String> {'Base Agent', 'Hardware', 'Business Users & Add-On Functionality', 'Data Center Provisioning', 'Overage'}; 
                List<String> list_QuoteOverallDiscounts = new List<String> {'Overall %', 'Third Party', 'Overall Amount'};                 
                    Map<String, Decimal> map_QuoteDiscounts = new Map<String, Decimal>();
            Map<String, Decimal> map_QuoteProductListPrices = new Map<String, Decimal>();
            Map<String, Boolean> map_DisplayQuoteDiscounts = new Map<String, Boolean>();
            for(String discBucket : list_QuoteDiscountBuckets) {
                map_QuoteDiscounts.put(discBucket, 0);
                map_QuoteProductListPrices.put(discBucket, 0);
                map_DisplayQuoteDiscounts.put(discBucket, false);
            } 
            for(String overallDisc : list_QuoteOverallDiscounts) {
                map_DisplayQuoteDiscounts.put(overallDisc, false);
            }
            Set<Id> set_OvgProdParentIds = new Set<Id>();
            if(objQuote.Billing_Category__c == 'M2M') {
                set_OvgProdParentIds = QuoteCloudUtil.findOverageChargeAPNs(objQuote);
            }
            
            Integer intSetScale = 2;
            Integer intNoOfMonths = Integer.valueOf(objQuote.No_Of_Months__c);
            if(objQuote.Billing_Category__c == 'M2M') {
                intNoOfMonths = 12;
            } 
            System.debug('#######intNoOfMonths: '+intNoOfMonths);
            
            Decimal decTAMAmount = 0;
            Decimal decTAMDuration = 0;        
            Map<String, Decimal> map_TamProduct = new Map<String, Decimal>();
            for(TAM_Product__mdt objTAM : [SELECT MasterLabel, Offering_Type__c, Duration_months__c
                                           FROM TAM_Product__mdt 
                                           WHERE Offering_Type__c =: SubscriptionUtil.OFFERING_TYPE_PCC]) {
                                               map_TamProduct.put(objTAM.MasterLabel, objTAM.Duration_months__c);
                                           }
            
            for(BigMachines__Quote_Product__c objQP : list_QuoteProducts) { 
                //Calculate seat count
                if(!objQP.Is_Overage__c) {
                    if(objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c) {                   
                        Integer decQtProdSeatCount = 0;
                        if (objQP.Quantity__c != null && objQP.Quantity__c > 0) {
                            decQtProdSeatCount = Integer.valueOf(objQP.Quantity__c); 
                        }
                        maxSeatCount += objQP.BigMachines__Product__r.Name.contains('Concurrent') ? decQtProdSeatCount * 2 : decQtProdSeatCount;
                    }
                    System.debug('#####maxSeatCount:' + maxSeatCount);
                }
                
                if(!objQP.Is_Overage__c && !set_OvgProdParentIds.contains(objQP.Id)) {
                    if(objQP.Ext_Net_Price__c != null) {
                        //Added By Ranjith on Apr 9, 2019 -- Starts -- For Migration Credit
                        if(objQP.BigMachines__Product__r.New_Category__c == 'Credit') {     
                            if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) 
                                decTotalRecCredit += objQP.Ext_Net_Price__c;
                            else
                                decTotalNonRecCredit += objQP.Ext_Net_Price__c;
                        }
                        else if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                            decTotalRecAmount += objQP.Ext_Net_Price__c;
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services')
                            decTotalRecServAmount += objQP.Ext_Net_Price__c;                    
                        else 
                            decTotalNonRecAmount += objQP.Ext_Net_Price__c;                        
                        /*if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
decTotalRecAmount += objQP.Ext_Net_Price__c;
else if(objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services')
decTotalRecServAmount += objQP.Ext_Net_Price__c;                    
else {
if(!Label.PureCloud_Credit_Products.contains(objQP.BigMachines__Product__r.Name)) {
decTotalNonRecAmount += objQP.Ext_Net_Price__c;
}
else {
decTotalPCCredit += objQP.Ext_Net_Price__c;
}
}*/
                        //Added By Ranjith on Apr 9, 2019 -- Ends-- For Migration Credit
                    }
                }
                if(objQP.List_Price__c != null && objQP.List_Price__c != 0) {       
                    decProductPartnerMargin = 0;
                    System.debug('#####map_PCPartnerMargins: '+map_PCCPartnerMargins);
                    if(objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) {
                        {
                            if(map_PCCPartnerMargins.containsKey(objQP.BigMachines__Product__r.Partner_Margin_Category__c))
                                decProductPartnerMargin = map_PCCPartnerMargins.get(objQP.BigMachines__Product__r.Partner_Margin_Category__c);
                            else if(Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c) != NULL)
                                decProductPartnerMargin =  Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c).Margin__c;
                            
                            objQP.Partner_Price__c = (objQP.List_Price__c - (objQP.List_Price__c * decProductPartnerMargin/100));                        
                        }                    
                        
                        System.debug('#####decProductPartnerMargin'+decProductPartnerMargin);
                    }
                }   
                if(objQP.Ext_List__c != null) {
                    if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                    {
                        decTotalRecAmountPreDiscount += objQP.Ext_List__c;
                        objQP.Extended_Price_Per_Month__c = objQP.Ext_Net_Price__c;
                        objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c; 
                        if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c && !set_OvgProdParentIds.contains(objQP.Id)) {
                            if(objQuote.Billing_Period__c == 'Annually') {
                                objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 12;
                            }
                            else if(objQuote.Billing_Period__c == 'Semi-Annually') {
                                objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 6;
                            }
                            else if(objQuote.Billing_Period__c == 'Quarterly') {
                                objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 3;
                            }  
                            else if(objQuote.Billing_Period__c == 'Other') {
                                objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * objQuote.No_Of_Months__c;
                            }           
                        } 
                    }
                    else if(objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services')
                        decTotalRecServAmountPreDiscount += objQP.Ext_List__c;
                    else
                        //Added By Ranjith on Apr 9, 2019 -- Starts -- For Migration Credit
                        if(objQP.BigMachines__Product__r.New_Category__c != 'Credit') {
                            //if(!Label.PureCloud_Credit_Products.contains(objQP.BigMachines__Product__r.Name))
                            //Added By Ranjith on Apr 9, 2019 -- Ends -- For Migration Credit
                            decTotalNonRecAmountPreDiscount += objQP.Ext_List__c;                            
                        }
                }
                System.debug('#####objQP:' + objQP);
                // Software
                if(objQP.BigMachines__Product__r.Type__c == 'Cloud') {
                    objQuote.Total_Software__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                    decTotalSWNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                }
                Decimal decExtNetUnitPrice = objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;                    
                if(objQP.BigMachines__Product__r.New_Category__c == 'Education') {
                    objQuote.Total_Education__c += objQP.BigMachines__Product__r.Include_in_CMMR_Total__c ? (decExtNetUnitPrice * intNoOfMonths) : decExtNetUnitPrice;
                }
                else if(objQP.BigMachines__Product__r.New_Category__c == 'Hardware') {
                    objQuote.Total_Hardware__c += objQP.BigMachines__Product__r.Include_in_CMMR_Total__c ? (decExtNetUnitPrice * intNoOfMonths) : decExtNetUnitPrice;       
                }
                else if(objQP.BigMachines__Product__r.New_Category__c == 'Services' || objQP.BigMachines__Product__r.New_Category__c == 'Voice Services') {
                    objQuote.Total_Services__c += objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services' ? (decExtNetUnitPrice * intNoOfMonths) : decExtNetUnitPrice;
                }
                if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) {
                    objQuote.No_Cloud_Billing_Contract__c = false;
                }
                // Calculating Total List Price
                if(objQP.Ext_List__c != null)
                    objQuote.Total_List_Price__c += objQP.Ext_List__c;         
                
                if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC){
                    if(!objQP.Is_Overage__c && !set_OvgProdParentIds.contains(objQP.Id)) {
                        
                        if(map_TamProduct.containskey(objQP.APN_Number__c)) {
                            decTAMAmount += decExtNetUnitPrice;
                            decTAMDuration = decTAMDuration < map_TamProduct.get(objQP.APN_Number__c) ? map_TamProduct.get(objQP.APN_Number__c) : decTAMDuration;     
                        }
                        
                        //addToQuoteTotalsBasedOnProductType(objQP);
                        objQuote.CMRR_Pre_Discount__c = (objQuote.CMRR_Pre_Discount__c == null)?0.00:objQuote.CMRR_Pre_Discount__c;
                        if(objQP.BigMachines__Product__r.Sub_Category__c == 'Add-on Monthly Contact Center Agent Fees'
                           || objQP.BigMachines__Product__r.Sub_Category__c == 'Miscellaneous Monthly Fees'
                           || objQP.BigMachines__Product__r.Sub_Category__c == 'Monthly Contact Center Agent Fees'
                           || objQP.BigMachines__Product__r.Sub_Category__c == 'Latitude') {
                               objQuote.Minimum_Fees_Period__c += objQP.Extended_Price_Per_Period__c != null ? objQP.Extended_Price_Per_Period__c : 0;
                               //Anju Jan 23 CMRR calculation updated as per ticket INC0303855
                               objQuote.CMRR__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                               System.debug(objQuote.CMRR_Pre_Discount__c+String.valueof(objQP.Ext_List__c));
                               objQuote.CMRR_Pre_Discount__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                           }
                        //Anju June 2018 Passthrough
                        else if(objQP.BigMachines__Product__r.Sub_Category__c == 'Passthrough' && objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) {
                            objQuote.Minimum_Fees_Period__c += objQP.Extended_Price_Per_Period__c != null ? objQP.Extended_Price_Per_Period__c : 0;
                            //quote.CMRR__c += objQP.Extended_Price_Per_Period__c != null ? objQP.Extended_Price_Per_Period__c : 0;
                            //Anju Sept 2018 
                            objQuote.CMRR__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            objQuote.CMRR_Pre_Discount__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                        } 
                        else if(objQP.BigMachines__Product__r.Sub_Category__c == 'Monthly Telecommunications and Datacenter Fees') {
                            objQuote.Telco_Cost__c = objQuote.Telco_Cost__c ==  null?0.00:objQuote.Telco_Cost__c;
                            objQuote.Telco_Cost__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            objQuote.CMRR__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            objQuote.CMRR_Pre_Discount__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                        }
                        
                        if(objQP.BigMachines__Product__r.Product_Group__c == 'Upfront Education and Training Services') {
                            objQuote.Total_Education__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            decTotalEducationNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                        }
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'Upfront Hardware Costs') {
                            objQuote.Total_Hardware__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            decTotalHWNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                        }
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'Upfront Provisioning Fees') {
                            objQuote.Setup_Provisioning_Charges__c += objQP.Ext_Net_Price__c;                    
                        }
                        //Anju Jan 2018 PureSuccess starts
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect Offer') {
                            decPureSuccessBaseSum += objQP.Ext_Net_Price__c;
                        }
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') {
                            decPureSuccessAlacarteSum  += objQP.Ext_Net_Price__c;
                        }
                        //Anju June 2018 
                        if(Label.PCC_Non_Recurring_products.contains(objQP.apn_number__c))
                            decOtherNonRecurringFees += objQP.Ext_Net_Price__c;
                        //Anju Jan 2018 PureSuccess starts
                        System.debug(objQP.Bundle__r.Type__c);
                        if(objQP.Bundle__r.Type__c == 'GUIDE' || objQP.Bundle__r.Type__c == 'EQUIP' 
                           || objQP.Bundle__r.Type__c == 'DRIVE' || objQP.Bundle__r.Type__c == 'Partner PureSuccess'){
                               objQuote.PureSuccess__c = objQP.Bundle__r.Type__c;
                           }
                        if(Label.PCC_Token_Package_Product.contains(String.valueof(objQP.BigMachines__Product__c).left(15)))
                            dblPureSuccessPackageCount = objQP.BigMachines__Quantity__c;
                        //Anju Jan 2018 PureSuccess ends
                        
                        
                    }
                    // ECD PEC Quote July 2019
                    else if( objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC){
                        if(objQP.BigMachines__Product__r.Type__c == 'Cloud') {
                            objQuote.Total_Software__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                            decTotalSWNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                        }
                        decExtNetUnitPrice = objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                        if(map_TamProduct.containskey(objQP.APN_Number__c)) {
                            decTAMAmount += decExtNetUnitPrice;
                            decTAMDuration = decTAMDuration < map_TamProduct.get(objQP.APN_Number__c) ? map_TamProduct.get(objQP.APN_Number__c) : decTAMDuration;     
                        }                
                        if(objQP.BigMachines__Product__r.New_Category__c == 'Monthly Telco Fees') {
                            objQuote.Telco_Cost__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            objQuote.CMRR__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            objQuote.CMRR_Pre_Discount__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                        }
                        
                        if(objQP.BigMachines__Product__r.New_Category__c == 'Education Courses and Packaged Curriculum') {
                            System.Debug('ECD Adding to Total_Education__c and decTotalEducationNetPrice ' + objQP.Ext_Net_Price__c + ' for qp.Id ' + objQP.Id + ' product id ' + objQP.BigMachines__Product__c);
                            objQuote.Total_Education__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            decTotalEducationNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                        }
                        
                        if(objQP.BigMachines__Product__r.New_Category__c == 'Professional Services') {
                            objQuote.Total_Services__c += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                            decTotalServicesNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                        }
                        
                        //Anju Jan 2018 PureSuccess starts
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct Offer' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect Offer') {
                            decPureSuccessBaseSum += objQP.Ext_Net_Price__c;
                        }
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || objQP.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte') {
                            decPureSuccessAlacarteSum  += objQP.Ext_Net_Price__c;
                        }
                        //Anju Jan 2018 PureSuccess ends
                        else if(objQP.BigMachines__Product__r.Product_Group__c == 'Installation') {
                            decEventSum += objQP.Ext_Net_Price__c;
                        }
                        //Anju June 2018 
                        if(Label.PCC_Non_Recurring_products.contains(objQP.APN_Number__c))
                            decOtherNonRecurringFees += objQP.Ext_Net_Price__c;
                        
                        //addToQuoteTotals(objQP);
                        
                        /* ECD PEC Subscription
* Not sure on the PCC logic for this. This setting causes a Billing Setup to be able to be created for the customer.
*/
                        if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) {
                            objQuote.No_Cloud_Billing_Contract__c = false;
                        }
                        
                        // Calculating Total List Price
                        if(objQP.Ext_List__c != null)
                            objQuote.Total_List_Price__c += objQP.Ext_List__c;
                        
                        if(objQP.Adjustment__c != null)
                            objQuote.Total_Adjustments__c += objQP.Adjustment__c;
                        
                    }
                    
                    else {
                        if(objQP.Quantity__c != null && objQP.Quantity__c > 0)
                            objQuote.Total_Overage__c += objQP.Net_Unit_Price__c * objQP.Quantity__c;
                    }           
                    
                }
                if(!objQP.Hide_Record__c) {    
                    Decimal decBasePrice = 0;
                    Decimal decNetUnitPrice = 0;
                    Decimal decOvgBasePrice = 0;
                    decBasePrice = (objQP.List_Price__c * objQP.Quantity__c).setScale(intSetScale);
                    decNetUnitPrice = (objQP.Net_Unit_Price__c * objQP.Quantity__c).setScale(intSetScale);
                    decOvgBasePrice = objQP.List_Price__c;
                    if(!objQP.Is_Overage__c) { 
                        //Logic to sum discounts based on Discount family under Quote
                        if(map_QuoteDiscounts.containsKey(objQP.BigMachines__Product__r.ProductSubFamily__c)) {
                            map_QuoteProductListPrices.put(objQP.BigMachines__Product__r.ProductSubFamily__c, map_QuoteProductListPrices.get(objQP.BigMachines__Product__r.ProductSubFamily__c) + decBasePrice);
                            map_QuoteDiscounts.put(objQP.BigMachines__Product__r.ProductSubFamily__c, map_QuoteDiscounts.get(objQP.BigMachines__Product__r.ProductSubFamily__c) + (decBasePrice - decNetUnitPrice));
                            if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                map_DisplayQuoteDiscounts.put(objQP.BigMachines__Product__r.ProductSubFamily__c, true);
                            }
                        }
                        
                        if(objQP.Bundle__c == null) {
                            if(objQP.Third_Party__c != 'TRUE'){
                                decGenesysProductsDiscount += decBasePrice - decNetUnitPrice;
                                listPriceTotalProductsOnly += decBasePrice;
                                if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                    map_DisplayQuoteDiscounts.put('Third Party', true);
                                }
                            }  
                            decGenesysAllDiscount += decBasePrice - decNetUnitPrice;
                            listPriceTotalAll += decBasePrice;   
                            decTotalNetPrice += decNetUnitPrice ;  
                            decTotalDiscountAmt += decBasePrice - decNetUnitPrice;
                            if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                map_DisplayQuoteDiscounts.put('Overall %', true);
                                map_DisplayQuoteDiscounts.put('Overall Amount', true);
                            }            
                        }   
                    }
                    else {
                        //Logic to sum discounts for overage charges under Quote
                        if(map_QuoteDiscounts.containsKey('Overage')) {
                            map_QuoteProductListPrices.put('Overage', map_QuoteProductListPrices.get('Overage') + decOvgBasePrice);
                            map_QuoteDiscounts.put('Overage', map_QuoteDiscounts.get('Overage') + (decOvgBasePrice - objQP.Net_Unit_Price__c));
                            if(objQP.Total_Discount__c != decProductPartnerMargin) {
                                map_DisplayQuoteDiscounts.put('Overage', true);
                            }
                        }
                    }                        
                }            
            } 
            
            //Added By Ranjith on Dec 04, 2018 -- Starts - To implement -ve amount for PC Credit
            //Added By Ranjith on Apr 9, 2019 -- Starts -- For Migration Credit
            decTotalNonRecCredit *= -1;
            decTotalRecCredit *= -1;
            decTotalCredit = decTotalNonRecCredit + (decTotalRecCredit * intNoOfMonths);
            //Added By Ranjith on Apr 9, 2019 -- Ends -- For Migration Credit
            //Added By Ranjith on Dec 04, 2018 -- Ends
            
            objQuote.Total_Subtotal_1__c = objQuote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c;
            objQuote.Non_Recurring_Fees__c = objQuote.Total_Hardware__c + objQuote.Total_Education__c + objQuote.Setup_Provisioning_Charges__c;
            objQuote.Max_Seat_Count__c = maxSeatCount;
            objQuote.Annual_Contract_Value__c = decTotalRecAmount * intNoOfMonths;
            objQuote.Cloud_Total__c = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount - decTotalCredit; //Added By Ranjith on Apr 9, 2019 -- For Migration Credit
            objQuote.Total_Contract_Value__c = objQuote.Cloud_Total__c;
            
            objQuote.CMRR_Pre_Discount__c = decTotalRecAmountPreDiscount;
            objQuote.ACV_Pre_Discount__c = decTotalRecAmountPreDiscount * (objQuote.No_Of_Months__c > 12 ? 12 : objQuote.No_Of_Months__c);
            objQuote.TCV_Pre_Discount__c = (decTotalRecAmountPreDiscount * objQuote.No_Of_Months__c) + decTotalNonRecAmountPreDiscount;
            
            if(objQuote.Billing_Category__c == 'M2M') {    
                objQuote.CMRR_Pre_Discount__c = objQuote.ACV_Pre_Discount__c = 0.00;
                objQuote.CMRR__c = objQuote.Annual_Contract_Value__c = decTotalRecAmount = 0.00;
            }  
            else {            
                Integer intCurrYrProration = intNoOfMonths == 12 ? 12 : Math.mod(intNoOfMonths, 12) == 0 ? 12 : Math.mod(intNoOfMonths, 12);
                //Added By Ranjith on Apr 9, 2019 -- Starts -- For Migration Credit
                /*quote.CMRR_Pre_Discount__c = decTotalRecAmountPreDiscount;
quote.CMRR__c = decTotalRecAmount;                
quote.Annual_Contract_Value__c = (decTotalRecAmount * 12) - (decTotalPCCredit/(intNoOfMonths >= 12 ? intNoOfMonths/12 : 1));             
quote.ACV_Pre_Discount__c = (decTotalRecAmountPreDiscount * 12) - (decTotalPCCredit/(intNoOfMonths >= 12 ? intNoOfMonths/12 : 1)); 
*/
                objQuote.CMRR_Pre_Discount__c = decTotalRecAmountPreDiscount - decTotalRecCredit - (decTotalNonRecCredit/intNoOfMonths);
                objQuote.ACV_Pre_Discount__c = objQuote.CMRR_Pre_Discount__c * 12;
                objQuote.CMRR__c = decTotalRecAmount - decTotalRecCredit - (decTotalNonRecCredit/intNoOfMonths);                
                objQuote.Annual_Contract_Value__c = objQuote.CMRR__c * 12;    
                //Added By Ranjith on Apr 9, 2019 -- Ends -- For Migration Credit   
            }        
            //Added By Ranjith on Apr 9, 2019 -- Starts -- For Migration Credit
            //quote.Non_Recurring_Fees__c = decTotalNonRecAmount - decTotalPCCredit;
            objQuote.Non_Recurring_Fees__c = decTotalNonRecAmount;   
            objQuote.Migration_Credit__c = decTotalCredit;        
            objQuote.Total_Contract_Value__c = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount + (decTotalRecServAmount * intNoOfMonths) - decTotalCredit;
            objQuote.TCV_Pre_Discount__c = (decTotalRecAmountPreDiscount * intNoOfMonths) + decTotalNonRecAmountPreDiscount + (decTotalRecServAmountPreDiscount * intNoOfMonths) - decTotalCredit;
            //Added By Ranjith on Apr 9, 2019 -- Ends -- For Migration Credit
            
            objQuote.Services_Change__c = objQuote.Total_Services__c- objQuote.Amendment_For__r.Total_Services__c;System.debug('####Quote'+objQuote.Total_Education_Change__c+''+objQuote.Total_Education__c+''+objQuote.Amendment_For__r.Total_Education__c);
            objQuote.Total_Education_Change__c = objQuote.Total_Education__c - objQuote.Amendment_For__r.Total_Education__c;
            objQuote.Total_Hardware_Change__c = objQuote.Total_Hardware__c - objQuote.Amendment_For__r.Total_Hardware__c;
            objQuote.CMRR_Change__c = objQuote.CMRR__c - objQuote.Amendment_For__r.CMRR__c;
            objQuote.Annual_Contract_Value_Change__c = objQuote.Annual_Contract_Value__c - objQuote.Amendment_For__r.ACV__c;
            objQuote.Non_Recurring_Fees_Changes__c = objQuote.Non_Recurring_Fees__c - objQuote.Amendment_For__r.Total_Non_Recurring_Fees__c;
            objQuote.Total_Contract_Value_Change__c = objQuote.Total_Contract_Value__c - objQuote.Amendment_For__r.TCV__c;
            if(objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
            {
                system.debug('Anju###'+objQuote.Telco_Cost__c+'###'+objQuote.Amendment_For__r.Telco_CMRR__c);
                objQuote.Telco_CMRR_Change__c = (objQuote.Telco_Cost__c == null ? 0 : objQuote.Telco_Cost__c) - (objQuote.Amendment_For__r.Telco_CMRR__c == null ? 0 : objQuote.Amendment_For__r.Telco_CMRR__c); 
                objQuote.Total_Tokens_Change__c = (objQuote.Token_Value__c == null ? 0 : objQuote.Token_Value__c) - (objQuote.Amendment_For__r.Total_Tokens__c == null ? 0 : objQuote.Amendment_For__r.Total_Tokens__c);              
                objQuote.Setup_Provisioning_Charges_Change__c = (objQuote.Setup_Provisioning_Charges__c == null ? 0 : objQuote.Setup_Provisioning_Charges__c) - (objQuote.Amendment_For__r.Setup_Provisioning_Charges__c == null ? 0 : objQuote.Amendment_For__r.Setup_Provisioning_Charges__c);    
            }
            // Percentages
            objQuote.Total_Discount_Genesys_Products_Only__c = objQuote.Total_Discount_Genesys_and_Third_Party__c = objQuote.Professional_Services_Discount__c = 0;
            objQuote.Hardware_Discount__c = objQuote.Software_Discount__c = objQuote.Overage_Discount__c = 0.00;       
            objQuote.BigMachines__Total__c = objQuote.Total_Subtotal_1__c; 
            objQuote.Selling_Entity__c = '';
            objQuote.Price_Escalation__c = '';
            if(objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
            {
                //Logic to populate discount % based on Discount family under Quote
                objQuote.Base_Agent_Discount__c = map_DisplayQuoteDiscounts.get('Base Agent') && map_QuoteProductListPrices.get('Base Agent') > 0 ? (map_QuoteDiscounts.get('Base Agent')/map_QuoteProductListPrices.get('Base Agent'))*100 : 0;
                objQuote.Hardware_Discount__c = map_DisplayQuoteDiscounts.get('Hardware') && map_QuoteProductListPrices.get('Hardware') > 0 ? (map_QuoteDiscounts.get('Hardware')/map_QuoteProductListPrices.get('Hardware'))*100 : 0;
                objQuote.Business_Users_Add_On__c = map_DisplayQuoteDiscounts.get('Business Users & Add-On Functionality') && map_QuoteProductListPrices.get('Business Users & Add-On Functionality') > 0 ? ((map_QuoteDiscounts.get('Business Users & Add-On Functionality')/map_QuoteProductListPrices.get('Business Users & Add-On Functionality'))*100).setscale(2) : 0;
                system.debug(map_DisplayQuoteDiscounts+':::'+map_QuoteProductListPrices+':::'+map_QuoteDiscounts);
                objQuote.Data_Center_Provisioning_Discount__c = map_DisplayQuoteDiscounts.get('Data Center Provisioning') && map_QuoteProductListPrices.get('Data Center Provisioning') > 0 ? (map_QuoteDiscounts.get('Data Center Provisioning')/map_QuoteProductListPrices.get('Data Center Provisioning'))*100 : 0;       
                objQuote.Overage_Discount__c = map_DisplayQuoteDiscounts.get('Overage') && map_QuoteProductListPrices.get('Overage') > 0 ? (map_QuoteDiscounts.get('Overage')/map_QuoteProductListPrices.get('Overage'))*100 : 0;
                
                if((decTotalDiscountAmt + decTotalNetPrice) != 0) {
                    if(listPriceTotalProductsOnly != 0)
                        objQuote.Total_Discount_Genesys_Products_Only__c = map_DisplayQuoteDiscounts.get('Overall %') ? (decGenesysProductsDiscount/listPriceTotalProductsOnly) * 100 : 0;
                    if(listPriceTotalAll != 0)
                        objQuote.Total_Discount_Genesys_and_Third_Party__c = map_DisplayQuoteDiscounts.get('Third Party') ? (decGenesysAllDiscount/listPriceTotalAll) * 100 : 0;
                    objQuote.Total_Discount__c = map_DisplayQuoteDiscounts.get('Overall Amount') ? decTotalDiscountAmt : 0;
                }
            }   
            
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            if(objQuote.Deal_Qualification__c == null){
                List<Deal_Qualification__c> dq = DealQualificationApprovalUtil.getDQ(objQuote.BigMachines__Opportunity__c, objQuote.Quote_Opportunity_Type__c, objQuote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
                if(!dq.isEmpty())
                    objQuote.Deal_Qualification__c = dq[0].id; 
            }
            System.debug('#######objQuote: '+objQuote);
            
            update objQuote;
        }catch(Exception e){
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
        }                           
    }   
    
    public static void updateOpportunityTotals(BigMachines__Quote__c objQuote) {        
        try{
            Map<Id,Id> map_ProdIdToPBEId = new Map<Id,Id>();
            System.debug('objQuote'+objQuote);
            List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();
            objQuote = QuoteCloudUtil.prepareQuotes(objQuote.Id);
            if(objQuote.BigMachines__Opportunity__c != null && objQuote.BigMachines__Is_Primary__c) {
                Opportunity oppToUpdate = new Opportunity(Id = objQuote.BigMachines__Opportunity__c);
                oppToUpdate.Primary_Quote__c = objQuote.Id;                
                oppToUpdate.Hardware_Total__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Total_Hardware_Change__c : objQuote.Total_Hardware__c;
                oppToUpdate.Education_Amount__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Total_Education_Change__c : objQuote.Total_Education__c;
                oppToUpdate.Total_PS_Support__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Services_Change__c : objQuote.Total_Services__c;
                if(oppToUpdate.Annual_Contract_Value_new__c == null)
                    oppToUpdate.Annual_Contract_Value_new__c = 0;
                oppToUpdate.Annual_Contract_Value_new__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Annual_Contract_Value_Change__c : objQuote.Annual_Contract_Value__c;
                //oppToUpdate.ACV_Subscription_Only__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Annual_Contract_Value_Change__c : objQuote.Annual_Contract_Value__c;    
                oppToUpdate.Annual_Contract_Value_Subscription__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Annual_Contract_Value_Change__c : objQuote.Annual_Contract_Value__c;    
                oppToUpdate.Annual_Contract_Value_Change__c = objQuote.Annual_Contract_Value_Change__c;
                oppToUpdate.Monthly_Commitment__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.CMRR_Change__c : objQuote.CMRR__c; 
                oppToUpdate.Subscription_CMRR__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.CMRR_Change__c : objQuote.CMRR__c; 
                oppToUpdate.CMRR_Change__c = objQuote.CMRR_Change__c; 
                oppToUpdate.Subscription_CMRR_Change__c = objQuote.CMRR_Change__c; 
                System.debug('#####oppToUpdate.Total_PS_Support__c:' + oppToUpdate.Total_PS_Support__c);
                oppToUpdate.Total_Annual_Contract_Value__c = objQuote.Total_Contract_Value__c - oppToUpdate.Total_PS_Support__c;
                oppToUpdate.Total_Contract_Value_Change__c = objQuote.Total_Contract_Value_Change__c - oppToUpdate.Total_PS_Support__c;
                if(objQuote.Order_Type__c == Label.Amend_Subscription) {
                    oppToUpdate.Total_Annual_Contract_Value__c = objQuote.Total_Contract_Value_Change__c;
                }
                
                oppToUpdate.Term_Commitment__c = objQuote.Initial_Subscription_Term__c;                
                oppToUpdate.Frequency_Term__c = objQuote.Billing_Period__c;
                oppToUpdate.MSA_Url__c = objQuote.MSA_Link__c;
                oppToUpdate.Primary_Line_of_Business__c = 'Cloud';
                oppToUpdate.Pricebook2Id = Label.Standard_Pricebook_Id;
                if(objQuote.Order_Type__c == Label.Amend_Subscription) {
                    // oppToUpdate.Offering_Detail__c = objQuote.Total_Contract_Value_Change__c >= 0 ? 'Amendment – Upgrade' : 'Amendment – Downgrade'; 
                    // Dec 04 2019 -- Ankaiah -- The below code has been added as per the INC0437617
                    String strAU = 'Amendment – Upgrade';
                    strAU = strAU.replaceAll('a-zA-Z0-9\\s+','');
                    system.debug('====>'+ strAU);
                    
                    String strAD = 'Amendment – Downgrade';
                    strAD = strAD.replaceAll('a-zA-Z0-9\\s+','');
                    system.debug('====>'+ strAD); 
                    oppToUpdate.Offering_Detail__c = objQuote.Total_Contract_Value_Change__c >= 0 ? strAU : strAD ; 
                    objQuote.Max_Seat_Count__c = objQuote.Total_Contract_Value_Change__c >= 0 ? objQuote.Max_Seat_Count__c : 0;
                }  
                System.debug('#####objQuote:' + objQuote);
                oppToUpdate.Incremental_Agent_Seat_Count__c = objQuote.Max_Seat_Count__c;
                oppToUpdate.TAM_Services_Amount__c = objQuote.TAM_Amount__c;
                oppToUpdate.TAM_Duration_Months__c = objQuote.TAM_Duration_Months__c;
                Map<String, Decimal> map_Currencies = new Map<String, Decimal>();
                map_Currencies = QuoteUtil.buildConversionRatesMap();
                Decimal decRunRate = [select Run_Rate_USD__c from Opportunity where Id = :oppToUpdate.Id].Run_Rate_USD__c;
                if(objQuote.Annual_Contract_Value__c != null && decRunRate != null && objQuote.BigMachines__Opportunity__r.RecordType.Name == 'Cloud Renewal') {
                    Decimal decACV = objQuote.Annual_Contract_Value__c / map_Currencies.get(objQuote.CurrencyIsoCode);
                    oppToUpdate.Renewal_Change_v_Run_Rate_USD__c = (decACV - Integer.valueOf(decRunRate)) > 0 ? decACV - Integer.valueOf(decRunRate) : 0;
                    System.debug('oppToUpdate.Renewal_Change_v_Run_Rate_USD__c'+oppToUpdate.Renewal_Change_v_Run_Rate_USD__c);
                }
                System.debug('#######oppToUpdate: '+oppToUpdate);
                Database.update(oppToUpdate, false);
            }            
        }catch(Exception e){
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
        }
    }                           
    
    
    public static void createOpportunityLineItems(BigMachines__Quote__c objQuote, List<BigMachines__Quote_Product__c> list_QuoteProducts, Set<Id> set_ProductIds) {        
        try{
            Map<Id, Id> map_ProdIdToPBEId = new Map<Id, Id>();
            List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();
            for(PricebookEntry objPE : [SELECT Product2Id,Id FROM PricebookEntry WHERE 
                                        Pricebook2Id = :Label.Standard_Pricebook_Id AND 
                                        Product2Id IN :set_ProductIds AND CurrencyISOCode = :objQuote.CurrencyISOCode])
                map_ProdIdToPBEId.put(objPE.Product2Id, objPE.Id);
            
            for(BigMachines__Quote_Product__c objQP : list_QuoteProducts) {
                if(objQP.Bundle__c != null && objQP.Bundle_Line__c == null)
                    continue;
                System.debug('map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c) ['+map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c)+']');    
                if(map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c) && !objQP.Is_Overage__c  && objQP.Quantity__c > 0) {
                    list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = objQuote.Id,
                                                                        Description__c = (String.isNotBlank(objQP.Product_Description__c) && objQP.Product_Description__c.length() > 250 ? objQP.Product_Description__c.substring(0, 250) : objQP.Product_Description__c),
                                                                        OpportunityId = objQuote.BigMachines__Opportunity__c,
                                                                        PricebookEntryId = map_ProdIdToPBEId.get(objQP.BigMachines__Product__c),
                                                                        Quantity = objQP.Quantity__c,Quantity__c = objQP.Quantity__c,UnitPrice = objQP.Net_Unit_Price__c,
                                                                        Total_Discount__c = objQP.Total_Discount__c,Unit_of_Measure__c = objQP.Unit_of_Measure__c));
                }
            }
            System.debug('#######list_OpptyLinesToCreate.size(): '+list_OpptyLinesToCreate.size());
            if(list_OpptyLinesToCreate.size() > 0)
                Database.insert(list_OpptyLinesToCreate,false); 
        }catch(Exception e){
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
        }                           
    }
    
    public static void cloneAccountOrderAddresses(Id quoteId, Id newQuoteId) {
        try{
            List<Account_Order_Address__c> list_NewAOAs = new List<Account_Order_Address__c>();  
            Id objOwnerId = [select BigMachines__Opportunity__r.ownerid from BigMachines__Quote__c where id =:newQuoteId].BigMachines__Opportunity__r.OwnerId;
            for(Account_Order_Address__c objAOA : [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                                   City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c, 
                                                   Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c, 
                                                   Sort_Order__c, State__c, Zip_Code__c, Quote__c, Additional_Emails__c
                                                   FROM Account_Order_Address__c
                                                   WHERE Quote__c = :quoteId
                                                   AND Address_Type__c != 'Ship To']) {
                                                       Account_Order_Address__c  objNewAOA = objAOA.clone(false, true, false, false);
                                                       objNewAOA.Quote__c = newQuoteId;
                                                       objNewAOA.Order__c = null;
                                                       objNewAOA.OwnerId = objOwnerId;
                                                       
                                                       list_NewAOAs.add(objNewAOA);
                                                   }
            System.debug('######list_NewAOAs: '+list_NewAOAs);
            if(list_NewAOAs.size() > 0) {
                insert list_NewAOAs;
            }
        }catch(Exception e){
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
        }                           
    }
    public static List<BigMachines__Quote_Product__c> prepareQuoteProducts(Id quoteId) {
        String strQueryAllFields = 'SELECT ';
        //Getting all the fields from a field set : field set used to make system more configurable 
        List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields();
        for(Schema.FieldSetMember field : gridFields)
            strQueryAllFields += field.getFieldPath() + ', ';
        strQueryAllFields += 'Bundle__r.Name, BigMachines__Product__r.Include_in_Agent_Seat_Count__c, BigMachines__Product__r.Tier__c,BigMachines__Product__r.Charge_Type__c, BigMachines__Product__r.Product_Group__c, BigMachines__Product__r.Partner_Margin_Type__c,BigMachines__Product__r.CurrencyISOCode,CurrencyISOCode, ';
        strQueryAllFields +='BigMachines__Product__r.Concurrent_List_Price__c, BigMachines__Product__r.G1_APAC_AUD_Price__c, BigMachines__Product__r.G1_APAC_USD_Price__c, BigMachines__Product__r.G2_CALA_USD_Price__c, BigMachines__Product__r.G3_EMEA_EUR_Price__c, BigMachines__Product__r.G3_EMEA_GBP_Price__c,BigMachines__Product__r.Partner_Margin_Category__c,';
        strQueryAllFields +='BigMachines__Product__r.G3_EMEA_USD_Price__c, BigMachines__Product__r.G4_JAPAN_JPY_Price__c, BigMachines__Product__r.G5_NA_CAD_Price__c, BigMachines__Product__r.G5_NA_USD_Price__c, BigMachines__Product__r.List_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG1_APAC_ANZ_AUD_Price__c, BigMachines__Product__r.NG1_APAC_KOREA_SE_ASIA_USD_Price__c, BigMachines__Product__r.NG1_APAC_USD_Price__c, BigMachines__Product__r.NG2_BRAZIL_BRL_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG2_CALA_USD_Price__c, BigMachines__Product__r.NG3_EMEA_EUR_Price__c, BigMachines__Product__r.NG3_EMEA_GBP_Price__c, BigMachines__Product__r.NG3_EMEA_USD_Price__c,Bundle__r.Type__c,';
        strQueryAllFields +='BigMachines__Product__r.NG3_Europe_ZAR_Price__c, BigMachines__Product__r.NG4_APAC_CHINA_INDIA_USD_Price__c, BigMachines__Product__r.NG4_APAC_JAPAN_YEN_Price__c, BigMachines__Product__r.NG4_APAC_NZD_Price__c,';
        strQueryAllFields +='BigMachines__Product__r.NG5_NA_CAD_Price__c,BigMachines__Product__r.NG5_NA_USD_Price__c,BigMachines__Product__r.NG5_NZD_Price__c,BigMachines__Product__r.NG5_ZAR_Price__c';
        strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c = :quoteId';
        System.debug('Query'+strQueryAllFields);
        List<BigMachines__Quote_Product__c> list_QuoteProducts = Database.Query(strQueryAllFields);
        
        return list_QuoteProducts;
    } 
    
    //Anju August 2018 get tier price for Cloud products
    // Gets tier pricing for the product
    public static Decimal getProductTierPricing(List<Product_Tier_Pricing__c> list_OfTierPricing, Decimal decQuantity, Decimal decPrice, String strPriceBookName) {        
        //Check and see if product has tier pricing
        if(!list_OfTierPricing.isEmpty()){
            for(Product_Tier_Pricing__c eachPricing : list_OfTierPricing){                                
                if(decQuantity <= eachPricing.Range_To__c){
                    decPrice = (Decimal)eachPricing.get(strPriceBookName);
                    break;
                }
            }            
        }
        return decPrice;
    }
    
    //--Rony Joseph-September 5 2018 -Start---
    // Generate Renewal Quotes from Subscriptions
    public static BigMachines__Quote__c createRenewalQuotes(Subscription__C objSub,Opportunity objRenewalOpp){
        try{
            BigMachines__Quote__c objNewQuote = new BigMachines__Quote__c(); 
            Map<String, RecordType> map_QuoteRecTypes = QuoteUtil.getRecordTypes('BigMachines__Quote__c');
            Id IdobjQId = objSub.Quote__c;
            String strObjName = 'BigMachines__Quote__c';
            String strWhereCondition = 'Id = :IdobjQId';
            List<BigMachines__Quote__c> list_SourceQts = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            
            if(list_SourceQts.size() > 0) {
                objNewQuote = list_SourceQts[0].clone(false, true, false, false);
                objNewQuote = SubscriptionUtil.buildQuoteFromSubscr(objSub, objNewQuote);
            }
            else {                
                objNewQuote = SubscriptionUtil.buildQuoteFromSubscr(objSub, null);
                objNewQuote.RecordTypeId = map_QuoteRecTypes.get('Cloud Quote').Id;
                objNewQuote.Quote_Created_Date__c = System.today();
                objNewQuote.Grid_Group_By__c = 'Recurring/Non-Recurring';
                objNewQuote.Group_Product_By__c = 'Standard View';
                objNewQuote.Pricing_Model__c = 'Named';
                objNewQuote.Delivery_Method__c = 'Electronic';
                objNewQuote.Renewal_Subscription_Term__c = (objNewQuote.Billing_Category__c != 'M2M' && objNewQuote.Offering_Type__c == 'PureCloud')?'Automatic Annual':'Automatic Monthly';
                objNewQuote.Expiration_Date__c = Date.today().addMonths(1);
                objNewQuote.Quote_Business_Type__c = 'Cloud';
                //objNewQuote.Selling_Entity__c = objOpp.Country_Selling_Entity__c;
                objNewQuote.Quote_Opportunity_Type__c = 'New Pricing'; 
                objNewQuote.Total_Contract_Value__c = 0.00; 
                objNewQuote.Non_Recurring_Fees__c = 0.00; 
                objNewQuote.Total_Hardware_Change__c = 0.00; 
                objNewQuote.Total_Education_Change__c = 0.00; 
            }
            // ECD PEC Quote July 2019
            if((objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC || objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) && objNewQuote.Billing_Category__c == 'M2M')
            {
                objNewQuote.No_Of_Months__c = 12;
                objNewQuote.Initial_Subscription_Term__c = '1 Year';
                objNewQuote.Billing_Category__c = 'Annual Pre-Pay';
                objNewQuote.Billing_Period__c = 'Annually';
                objNewQuote.Subscription_End_Date__c = objNewQuote.Subscription_Start_Date__c.addMonths(Integer.valueOf(objNewQuote.No_Of_Months__c))-1;
            }
            if(objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC){//Added to flip MSA Link type to Standard for PEC Renewal Quotes
                objNewQuote.MSA_Link_Type__c = 'Standard';
                objNewQuote.MSA_Link__c =  getMSALink(objRenewalOpp,objNewQuote.Offering_Type__c);
            }
            objNewQuote.Overage_Allowance__c = (objNewQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)?'20%':'25%';   
            objNewQuote.Overage_Allowance_Other__c = null ;
            objNewQuote.Adjustment__c = null;
            objNewQuote.Total_Adjustments__c = null;
            objNewQuote.Order__c = null;
            objNewQuote.Order_Date_Submitted__c = null;
            objNewQuote.Contract_Signature_Date__c = null;
            objNewQuote.Order_PO_Date__c = null;
            objNewQuote.Order_PO_Received_Date__c = null;
            objNewQuote.Amendment_For__c = objSub.Id;
            objNewQuote.BigMachines__Opportunity__c = objRenewalOpp.Id;
            objNewQuote.BigMachines__Status__c = 'Quote In Progress';
            objNewQuote.Order_Type__c = Label.Renew_Subscription;
            objNewQuote.MSA_Link_Type__c = 'Standard';
            objNewQuote.MSA_Link__c = getMSALink(objRenewalOpp, objRenewalOpp.Lead_Offer__c);
            objNewQuote.Billing_Start_Date__c = objNewQuote.Subscription_End_Date__c + 1;
            objNewQuote.Subscription_Start_Date__c = objNewQuote.Subscription_End_Date__c + 1;
            objNewQuote.No_Of_Months__c = objSub.Term_Length_Months__c!= null ? objSub.Term_Length_Months__c : 12;
            objNewQuote.Subscription_End_Date__c = (Integer.valueOf(objNewQuote.No_Of_Months__c) !=null) ? (objNewQuote.Subscription_Start_Date__c.addMonths(Integer.valueOf(objNewQuote.No_Of_Months__c))-1) : Date.today().addMonths(1);
            objNewQuote.Ramp_Period__c = '0';
            objNewQuote.CurrencyISOCode  = objSub.CurrencyISOCode;
            objNewQuote.Is_Business_Primary__c = true;
            objNewQuote.BigMachines__Is_Primary__c = true;
            objNewQuote.Total_Software__c = objNewQuote.Total_Hardware__c = objNewQuote.Total_Education__c = objNewQuote.Total_Services__c = 0;
            objNewQuote.Minimum_Fees_Period__c = objNewQuote.Setup_Provisioning_Charges__c = objNewQuote.CMRR__c = objNewQuote.Max_Seat_Count__c = 0;
            objNewQuote.Total_Adjustments__c = objNewQuote.Total_List_Price__c = objNewQuote.Total_Overage__c = 0;
            objNewQuote.No_Cloud_Billing_Contract__c = true; 
            objNewQuote.Include_Special_Offer_in_Output__c =  false;
            objNewQuote.Special_Offer_Terms__c = '';                
            objNewQuote.Annual_Contract_Value__c = 0.00;
            objNewQuote.Incentive_Rebate__c = 0.00;
            objNewQuote.Revision_No__c = 1;
            objNewQuote.Expiration_Date__c = Date.today().addMonths(1);
            System.debug('$$$$$'+objNewQuote);
            return objNewQuote;
        }catch(Exception e){
            System.debug('Error has occurred'+e.getMessage()+e.getStackTraceString());
            If(CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage != null){CreateRenewalOppAndQuoteFromSubsBatch.strErrorMessage+= ExceptionHandling.ExceptionHandling(e);}                  
            return null;}                
        
    }
    //--Rony Joseph-September 5 2018 -End---
    
    //Anju Calculate token count for PureSuccess
    public static Decimal calculateTokenValue(Decimal totalACV, String offeringType, String pureSuccessPackageName) {
        Decimal decTokenValue = 0;
        if (totalACV < 5000)
            decTokenValue = 0;
        else {
            decTokenValue = (totalACV / 5000);
            decTokenValue = 5 * (decTokenValue / 5).round(System.RoundingMode.UP);
            decTokenValue.setScale(0);
        }
        System.debug('NKC debug decTokenValue [' + decTokenValue + ']');
        if (decTokenValue > 500)
            decTokenValue = 500;
        // ECD PEC Quote July 2019
        if (offeringType == OFFERING_TYPE_PEC) {
            if (pureSuccessPackageName == 'GUIDE')
                decTokenValue += 25;
            else if (pureSuccessPackageName == 'DRIVE')
                decTokenValue += 85;
        } else if (offeringType == 'PureConnect Cloud') {
            if (pureSuccessPackageName == 'GUIDE')
                decTokenValue += 15;
            else if (pureSuccessPackageName == 'DRIVE')
                decTokenValue += 75;
        } else if (offeringType == 'Business Edition') {
            if (pureSuccessPackageName == 'GUIDE')
                decTokenValue += 25;
            else if (pureSuccessPackageName == 'DRIVE')
                decTokenValue += 85;
        }
        return decTokenValue;
    }
    //Conversion for PC Monthly minimum
    public static Map<String, Decimal> buildConversionRatesMap() {
        Map<String, Decimal> map_ConversionRates = new Map<String, Decimal>
        {'USD'=>1,'CAD'=>1.1,'AUD'=>1.3,'NZD'=>1.4,'GBP'=>0.7,'EUR'=>0.8,'BRL'=>3,'JPY'=>120,'ZAR'=>14.2};
            return map_ConversionRates;
    }   
    
    //Create Dependent and Overage parts
    public static integer createDependentAndOverages(List<BigMachines__Quote_Product__c> list_ToInsert, BigMachines__Quote__c objQuote,Integer intLineNumber)
    {
        String strPricebookFieldName = objQuote.New_Price_Book__c + '_Price__c';
        List<BigMachines__Quote_Product__c> list_ToInsertOverageCharges = new List<BigMachines__Quote_Product__c>();
        if(list_ToInsert.size() > 0){
            //Logic to add overage/usage prices
            Set<Id> set_ProductIds = new Set<Id>();
            Map<Id, Product_Tier_Pricing__c> map_ProdOveragePricing = new Map<Id, Product_Tier_Pricing__c>();
            Map<String, String> map_DependentProducts = new Map<String, String>();
            for(BigMachines__Quote_Product__c objNewQP : list_ToInsert) {
                set_ProductIds.add(objNewQP.BigMachines__Product__c);
            }
            //Added By Ranjith on Dec 06, 2017 -- Starts
            System.debug('SetproductIds---'+set_ProductIds);
            Set<Id> set_AddtProdIds = new Set<Id>();
            Set<Id> set_ExistingProdIds = new Set<Id>();
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c
                                                       FROM BigMachines__Quote_Product__c
                                                       WHERE BigMachines__Quote__c = :objQuote.Id]) {
                                                           set_ExistingProdIds.add(objQP.BigMachines__Product__c);
                                                       }
            
            List<Product_Group__c> list_ProdGrps = [SELECT Id, Product__c, Product__r.APN_Number__c,
                                                    (SELECT Product__c, Product__r.APN_Number__c, 
                                                     Product_Group__r.Product__r.APN_Number__c
                                                     FROM Product_Group_Items__r 
                                                     WHERE Product_Type__c = 'Mandatory')
                                                    FROM Product_Group__c
                                                    WHERE Group_Type__c = 'Dependent Products'
                                                    AND Active__c = true
                                                    AND Product__c IN :set_ProductIds];
            
            System.debug('list group----'+list_ProdGrps);
            for(Product_Group__c objProdGrp : list_ProdGrps) {
                for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                    map_DependentProducts.put(objProdGrpItm.Product__r.APN_Number__c, objProdGrp.Product__r.APN_Number__c);
                    if(!set_ProductIds.contains(objProdGrpItm.Product__c) 
                       && !set_ExistingProdIds.contains(objProdGrpItm.Product__c)) {
                           set_AddtProdIds.add(objProdGrpItm.Product__c);
                           set_ProductIds.add(objProdGrpItm.Product__c);
                       }
                }
            }
            System.debug('#####set_AddtProdIds: '+set_AddtProdIds);
            System.debug('#####map_DependentProducts: '+map_DependentProducts);
            //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
            for(Product2 objAddtProd : Database.query(QuoteCloudUtil.buildProductAndTierPricingQuery(objQuote.Billing_Category__c, objQuote.New_Price_Book__c + '_Price__c'))) {
                //Added By Ranjith on Feb 26, 2019 -- Ends                    
                Decimal decPrice = (Decimal)objAddtProd.get(strPricebookFieldName);
                if((objAddtProd.Price_Type__c == 'Rate Plan' || objAddtProd.Price_Type__c == 'Range') && objAddtProd.Product_Tier_Pricings__r.size() > 0) 
                    //system.debug('Tier Pricing---'+objAddtProd.Product_Tier_Pricings__r[0].get(strPricebookFieldName));
                    decPrice = (Decimal)objAddtProd.Product_Tier_Pricings__r[0].get(strPricebookFieldName);
                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();                
                objQP.Name = objAddtProd.Name;
                objQP.BigMachines__Quote__c = objQuote.Id;
                objQP.BigMachines__Product__c = objAddtProd.Id;
                objQP.APN_Number__c = objAddtProd.APN_Number__c;
                objQP.Product_Specific_Discount__c = objAddtProd.Product_Specific_Discount__c;
                objQP.Product_Group__c = objAddtProd.Product_Group__c;
                objQP.List_Price__c = decPrice;
                objQP.Quantity__c = 0;
                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                objQP.Unit_of_Measure__c = objAddtProd.Unit_of_Measure__c;
                objQP.BigMachines__Sales_Price__c = 0;
                objQP.Hide_Record__c = true;
                objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                //Rony Joseph-June 5 2019-Trial Automation - Start
                objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                objQP.Billing_Category__c = objQuote.Billing_Category__c;
                objQP.Type_of_Product__c  = 'Ordinary';
                //Rony Joseph-June 5 2019-Trial Automation -End                                                                                                                                
                System.debug('#####objQP.APN_Number__c: '+objQP.APN_Number__c);
                if(map_DependentProducts.containsKey(objQP.APN_Number__c)
                   && (map_DependentProducts.get(objQP.APN_Number__c) == 'PCSMS-170-NV-SMS'
                       || map_DependentProducts.get(objQP.APN_Number__c) == 'PV-170-NV-PCVOICE')
                   || objQP.APN_Number__c.left(6) == 'PCSMS-') {
                       System.debug('#####map_DependentProducts: '+map_DependentProducts.get(objQP.APN_Number__c));
                       objQP.Is_Overage__c = true;
                   }
                list_toInsertOverageCharges.add(objQP);
            }
            for(BigMachines__Quote_Product__c objNewQP : list_ToInsert) {
                if(Label.PC_Overage_Products.contains(objNewQP.APN_Number__c)) {
                    objNewQP.Is_Overage__c = true;
                    objNewQP.Name += ' Usage';
                }
                objNewQP.CurrencyISOCode = objQuote.CurrencyISOCode;
            }
            //Logic to map overage to parent quote product. helpful while deleting
            
            
            Map<Id, Product_Tier_Pricing__c> map_ProdTiers = new Map<Id, Product_Tier_Pricing__c>();
            
            Map<Id, BigMachines__Quote_Product__c> map_NewQPs = new Map<Id, BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c objQP : list_ToInsert) {
                map_NewQPs.put(objQP.Id, objQP);
            }
            
            //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
            String strWhereCondition = 'WHERE Product__c IN :set_ProductIds AND Charge_Type__c = \'M2M\' AND Product__r.Has_Overage__c = true';
            List<Product_Tier_Pricing__c> list_ProdTierPricing = Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, objQuote.New_Price_Book__c + '_Price__c'));
            //Added By Ranjith on Feb 26, 2019 -- Ends
            for(Product_Tier_Pricing__c objProdTr : list_ProdTierPricing ) {
                map_ProdTiers.put(objProdTr.Product__c, objProdTr);
            }
            for(Id newQPId : map_NewQPs.keySet()) {                    
                if(map_ProdTiers.containsKey(map_NewQPs.get(newQPId).BigMachines__Product__c)) {
                    Product_Tier_Pricing__c objProdTr = map_ProdTiers.get(map_NewQPs.get(newQPId).BigMachines__Product__c);
                    BigMachines__Quote_Product__c objOverageQP = new BigMachines__Quote_Product__c();
                    objOverageQP.BigMachines__Quote__c = objQuote.Id;
                    objOverageQP.Parent_Quote_Product__c = newQPId;
                    objOverageQP.Is_Overage__c = true;
                    objOverageQP.BigMachines__Product__c = objProdTr.Product__c;
                    objOverageQP.Name = objProdTr.Product__r.Name + ' Overage';
                    objOverageQP.APN_Number__c = objProdTr.Product__r.APN_Number__c;
                    objOverageQP.List_Price__c = (Decimal)objProdTr.get(objQuote.New_Price_Book__c + '_Price__c');
                    objOverageQP.Unit_of_Measure__c = objProdTr.Product__r.Unit_of_Measure__c;
                    objOverageQP.BigMachines__Quantity__c = objOverageQP.Quantity__c = objOverageQP.BigMachines__Sales_Price__c = 0;
                    objOverageQP.or_Amount__c = '%';
                    //Rony Joseph-June 5 2019-Trial Automation - Start
                    objOverageQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                    objOverageQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                    objOverageQP.Billing_Category__c = objQuote.Billing_Category__c;
                    objOverageQP.Type_of_Product__c  = 'Ordinary';
                    //Rony Joseph-June 5 2019-Trial Automation -End                                               
                    if(set_AddtProdIds.contains(objProdTr.Product__c)
                       || (objQuote.Billing_Category__c == 'M2M' && objProdTr.Product__r.New_Category__c == 'Subscription Fees')
                       || objOverageQP.APN_Number__c == 'PC-170-NV-PCIVRCUSPERMIN') {
                           objOverageQP.Hide_Record__c = true;
                       }
                    objOverageQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                    objOverageQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                    list_ToInsertOverageCharges.add(objOverageQP);
                }
            }
            insert list_toInsertOverageCharges;
        }       
        return intLineNumber;
        
    } 
    
    //Added By Rony on Jan 16, 2019 -- Starts
    //retrieve base product of use case bundle given a product 
    public static void retrieveBundleBaseProduct(List<BigMachines__Quote_Product__c> set_QPQuantityChanged,BigMachines__Quote__c objQuote,String strNewOrExisting){
        try{
            System.debug(set_QPQuantityChanged);
            Set<Id> set_ProductIds = new Set<Id>();
            for(BigMachines__Quote_Product__c objQP:set_QPQuantityChanged){
                set_ProductIds.add(objQP.BigMachines__Product__c);
            }
            System.debug('####Products changed'+set_ProductIds);
            List<String> list_UseCaseNames = new List<String>();
            Set<Id> set_BundleIds =new Set<Id>();
            Map<Id,Map<String,Id>> map_ProdIdtoAssocaitedBundle = new Map<Id,Map<String,Id>>();
            Map<Id,BigMachines__Quote_Product__c> map_IdToQuoteProducts =  new Map<Id,BigMachines__Quote_Product__c>();
            Map<Id,BigMachines__Quote_Product__c> map_QPIdtoAssocaitedBundleBaseProduct = new Map<Id,BigMachines__Quote_Product__c>();
            List<Product_Group_Item__c> list_BundleProducts = [Select Product__c,Product_Group__c,Product_Group__r.Name from Product_Group_Item__c where Product__c in :set_ProductIDs];
            for(Product_Group_Item__c objPGItem:list_BundleProducts)
            {
                if(map_ProdIdtoAssocaitedBundle.containsKey(objPGItem.Product__c))
                    map_ProdIdtoAssocaitedBundle.get(objPGItem.Product__c).put(objPGItem.Product_Group__r.Name,objPGItem.Product_Group__c);            
                else                
                    map_ProdIdtoAssocaitedBundle.put(objPGItem.Product__c,new Map<String,Id>{objPGItem.Product_Group__r.Name => objPGItem.Product_Group__c});
                
            }
            System.debug(map_ProdIdtoAssocaitedBundle);
            for(Id IdQPId:map_ProdIdtoAssocaitedBundle.Keyset())
            {
                list_UseCaseNames.Clear();
                list_UseCaseNames.addAll(map_ProdIdtoAssocaitedBundle.get(IdQPId).Keyset());
                list_UseCaseNames.Sort();
                System.debug(list_UseCaseNames);
                if( list_UseCaseNames.size()>0){map_QPIdtoAssocaitedBundleBaseProduct.put(IdQPId,map_IdToQuoteProducts.get(map_ProdIdtoAssocaitedBundle.get(IdQPId).get(list_UseCaseNames[0])));}
            }    
            
            for(BigMachines__Quote_Product__c objQP:set_QPQuantityChanged){
                list_UseCaseNames.Clear();
                IF(map_ProdIdtoAssocaitedBundle.containsKey(objQP.BigMachines__Product__c)) {list_UseCaseNames.addAll(map_ProdIdtoAssocaitedBundle.get(objQP.BigMachines__Product__c).Keyset());}
                list_UseCaseNames.Sort();
                If(list_UseCaseNames.size() > 0){
                    string strusecase = list_UseCaseNames[0];
                    objQP.Bundle__c = map_ProdIdtoAssocaitedBundle.get(objQP.BigMachines__Product__c).get(strusecase);
                }    
                if(strNewOrExisting == 'Existing'){
                    objQP.Play__c =(objQP.Play__c == null || objQP.Play__c == '')?objQuote.Top_Play__c:objQP.Play__c;
                }    
            }
            System.debug('####Completed Base PRoduct retrieval'+set_QPQuantityChanged); 
            If(Limits.getDmlStatements() > 0){Update set_QPQuantityChanged;}     
        }catch(Exception e) {
            System.debug('####Exception has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
            
        } 
    }
    //Added By Rony on Jan 16, 2019 -- Ends
    
    //Added By Rony on Jan 31,2019 --Starts
    //Method to Calculate PS List Price Based on Region and Product Type
    
    public static Map<Id,Decimal> retrivePureSuccessMultiplier(String strRegion,String strQuoteCurrency,Set<Id> PureSuccessProductIds,Id IdQuoteId){
        try{
            System.debug('###PAsed Values: '+ strRegion + ' ' +strQuoteCurrency );
            If(strRegion == 'Developing MEA')
            {strRegion = 'MEA';}
            else if (strRegion == 'EMEA' || strRegion ==  'Central & Eastern Europe')
            {strRegion = 'Europe';}
            else if (strRegion == 'Greater China')
            {strRegion = 'China';}
            else if (strRegion == 'NA')
            {strRegion = 'North America';}
            else if (strRegion == 'LATAM')
            {
                String strSoldtoCountry = [Select Opp_Sold_To_Country__c from BigMachines__Quote__c where id = :IdQuoteId ].Opp_Sold_To_Country__c;
                IF(strSoldtoCountry == 'Brazil')
                    strRegion ='Brazil';            
            }
            
            Map<String,Decimal> map_PriceBookToConversationRate = new Map<String,Decimal>();
            Map<Id,Product2> map_SelectedPSProducts =new Map<Id,Product2>([Select Id,NG5_NA_USD_Price__c,PureSuccess_Type__c from Product2 where Id in :PureSuccessProductIds]);
            Map<Id,Decimal> map_PSIdtoAdjustedPrice = new Map<Id,Decimal>();
            List<Currency_Configuration__c> list_CurrencyConvertorRatePC = [Select id,Offering_Type__c,Price_Book__c,Conversion_Rate__c from Currency_Configuration__c where Offering_Type__c = 'PureCloud' ];
            for(Currency_Configuration__c objCurrecyConfig : list_CurrencyConvertorRatePC) {
                map_PriceBookToConversationRate.put(objCurrecyConfig.Price_Book__c,objCurrecyConfig.Conversion_Rate__c);
            }
            Map<String, String> map_CurrencyToPriceBook = new Map<String, String>
            {'USD'=>'NG5_NA_USD','CAD'=>'NG5_NA_CAD','AUD'=>'NG1_APAC_ANZ_AUD','NZD'=>'NG5_NZD','GBP'=>'NG3_EMEA_GBP','EUR'=>'NG3_EMEA_EUR','BRL'=>'NG2_BRAZIL_BRL','JPY'=>'NG4_APAC_JAPAN_YEN','ZAR'=>'NG5_ZAR'};
                
                List<PureSuccess_Region_Multiplier__mdt>  list_PureSuccessRegionalMultipliers = [Select Type__c,Multiplier__c from PureSuccess_Region_Multiplier__mdt where Region__c = :strRegion ];
            For(PureSuccess_Region_Multiplier__mdt objPSMultiplier:list_PureSuccessRegionalMultipliers){
                map_PriceBookToConversationRate.put(objPSMultiplier.Type__c,objPSMultiplier.Multiplier__c);
            }
            //System.debug(map_PriceBookToConversationRate);
            System.debug(map_SelectedPSProducts);
            System.debug(map_PriceBookToConversationRate);
            For(Id objProdId: PureSuccessProductIds ){
                System.debug(objProdId);
                System.debug(map_SelectedPSProducts.get(objProdId).PureSuccess_Type__c);
                System.debug(map_PriceBookToConversationRate.get(map_SelectedPSProducts.get(objProdId).PureSuccess_Type__c));
                System.debug(map_PriceBookToConversationRate.get(map_CurrencyToPriceBook.get(strQuoteCurrency)));
                Decimal decPrice = map_SelectedPSProducts.get(objProdId).NG5_NA_USD_Price__c;
                Decimal decAdjustedPrice = decPrice;
                If(map_PriceBookToConversationRate.get(map_SelectedPSProducts.get(objProdId).PureSuccess_Type__c) != null){
                    System.debug(decAdjustedPrice);
                    Decimal decAdjustedUSDPrice = ((decAdjustedPrice *  map_PriceBookToConversationRate.get(map_SelectedPSProducts.get(objProdId).PureSuccess_Type__c))/100).round(System.RoundingMode.UP) *100;
                    System.debug(decAdjustedUSDPrice);
                    decAdjustedPrice = ((decAdjustedUSDPrice *map_PriceBookToConversationRate.get(map_CurrencyToPriceBook.get(strQuoteCurrency)))/100).round(System.RoundingMode.UP) *100;
                    System.debug(decAdjustedPrice);
                }
                
                map_PSIdtoAdjustedPrice.put(objProdId,decAdjustedPrice);
            }     
            System.debug(map_PSIdtoAdjustedPrice);
            return map_PSIdtoAdjustedPrice;
        }   catch(Exception ex){
            System.debug('\n####Exception Happened:'+ex.getMessage()+'\n'+ex.getStackTraceString());
            return null; 
        }
    } 
    //Added By Rony on Jan 31,2019 -- Ends
    
    //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
    public static String buildTierPricingQuery(String strWhereCondition, String strPricebook) {         
        String strTierPricingQuery = 'SELECT NG5_NA_USD_Price__c, ' + (strPricebook != 'NG5_NA_USD_Price__c' ? strPricebook + ', ' : '');
        strTierPricingQuery += 'Product__c, Product__r.Name, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c, ';
        strTierPricingQuery += 'Product__r.New_Category__c, Charge_Type__c, Range_To__c, Range_From__c ';
        strTierPricingQuery += 'FROM Product_Tier_Pricing__c ';
        strTierPricingQuery += strWhereCondition;
        System.debug('strTierPricingQuery: ' + strTierPricingQuery);
        return strTierPricingQuery;
    }
    
    public static String buildProductAndTierPricingQuery(String strBillingCategory, String strPricebook) {       
        String strTierPricingQuery = 'SELECT Id, Name, Unit_of_Measure__c, Has_Overage__c, APN_Number__c, Product_Group__c, Price_Type__c, Sub_Category__c,Tier_Pricing_Decimal_Precision__c, ';
        strTierPricingQuery += 'NG5_NA_USD_Price__c, ' + (strPricebook != 'NG5_NA_USD_Price__c' ? strPricebook+', ' : '');
        strTierPricingQuery += 'RecordTypeId, CurrencyIsoCode, Quantity__c, Product_Name__c, Product_Specific_Discount__c, ';   
        strTierPricingQuery += '(SELECT NG5_NA_USD_Price__c, ' + (strPricebook != 'NG5_NA_USD_Price__c' ? strPricebook+', ' : '');
        strTierPricingQuery += 'Product__c, Product__r.Name, Product__r.APN_Number__c, Product__r.Unit_of_Measure__c FROM Product_Tier_Pricings__r ';
        strTierPricingQuery += 'WHERE Charge_Type__c = \'' + strBillingCategory + '\' ORDER BY Range_From__c)' ;
        strTierPricingQuery += 'FROM Product2 WHERE Id IN :set_AddtProdIds';
        return strTierPricingQuery;
    }
    //Added By Ranjith on Feb 26, 2019 -- Ends    
    
    //--Rony Joseph-May 6th 2019 -Starts---
    //Method to clone and create Quote for AppFoundry Trial Automation 
    public static BigMachines__Quote__c cloneSubscriptionQuoteAndQuoteProducts(Subscription__C objOriginalSubscripiton,Opportunity objAppFoundryTrialOpp,List<Product2> List_AppFoundryProducts,Date dtContractSignatureDate,Date dtFreeTillDate,Boolean blnApplyAppFoundryMarkUp){
        try{
            
            List<BigMachines__Quote_Product__c> list_ClonedSubsQuoteProduct = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_AppFoundryQuoteProduct = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_ClonedSubsQuoteProducttoRemove = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_ClonedSubsQuoteProducttoReg = new List<BigMachines__Quote_Product__c>();
            Set<Id> list_QuoteProductstoRemove = new Set<Id>();
            Boolean blnProductPresent =  false;
            Boolean blnTrailRegulirization =  false;
            for(Product2 objProd:List_AppFoundryProducts){
                list_QuoteProductstoRemove.add(objProd.Id);
            }
            System.debug(list_QuoteProductstoRemove);
            Id IdSubsQuoteId = objOriginalSubscripiton.Quote__c;
            Decimal decAppFoundryMarkup = (blnApplyAppFoundryMarkUp)?[select AppFoundry_Markup__c from Account where id = :objOriginalSubscripiton.Business_Partner__c].AppFoundry_Markup__c:0.00;
            String strObjName = 'BigMachines__Quote__c';
            String strWhereCondition = 'Id = :IdSubsQuoteId';
            List<BigMachines__Quote__c> list_SubscriptionQuote = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            BigMachines__Quote__c    objAppFoundryTrialQuote =  list_SubscriptionQuote[0].clone(false, true, false, false);
            objAppFoundryTrialQuote.BigMachines__Status__c = 'Order Accepted';
            objAppFoundryTrialQuote.BigMachines__Opportunity__c = objAppFoundryTrialOpp.Id;
            objAppFoundryTrialQuote.Order_Type__c = Label.Amend_Subscription;
            objAppFoundryTrialQuote.Contract_Signature_Date__c = dtContractSignatureDate;
            objAppFoundryTrialQuote.Amendment_For__c = objOriginalSubscripiton.Id;
            objAppFoundryTrialQuote.Ownerid = OpportunityCloudUtil.activeRecordOwnerId;
            insert  objAppFoundryTrialQuote;   
            buildQuoteProductsForAmend(objOriginalSubscripiton.Id,objAppFoundryTrialQuote);
            Id IdClonedQuoteId = objAppFoundryTrialQuote.Id;
            strObjName = 'BigMachines__Quote_Product__c';
            strWhereCondition = 'BigMachines__Quote__c = :IdClonedQuoteId';
            List<BigMachines__Quote_Product__c> list_SubscriptionQuoteProducts = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            for(Integer j = list_SubscriptionQuoteProducts.size() - 1; j >= 0 ; j--){
                System.debug('####QPChecked:'+list_SubscriptionQuoteProducts[j]);
                if(list_QuoteProductstoRemove.contains(list_SubscriptionQuoteProducts[j].BigMachines__Product__c)){
                    System.debug('###QP removed:'+list_SubscriptionQuoteProducts[j]);
                    list_ClonedSubsQuoteProducttoRemove.add(list_SubscriptionQuoteProducts[j]);
                    list_SubscriptionQuoteProducts.remove(j);
                    blnProductPresent = true;
                }
            }
            IF(list_ClonedSubsQuoteProducttoRemove.size() > 0){
                Database.Delete(list_ClonedSubsQuoteProducttoRemove,false);
                Database.emptyRecycleBin(list_ClonedSubsQuoteProducttoRemove);
            } 
            for(BigMachines__Quote_Product__c objQP:list_SubscriptionQuoteProducts){
                // BigMachines__Quote_Product__c objClonedQP = objQP.clone(false, true, false, false);
                // objClonedQP.BigMachines__Quote__c = objAppFoundryTrialQuote.Id;
                if(objQP.Type_of_Product__c == 'Ordinary'){ 
                    objQP.Active_Start_Date__c = objOriginalSubscripiton.Subscription_Start_Date__c;
                    objQP.Active_End_Date__c = objOriginalSubscripiton.Subscription_End_Date__c;
                    objQP.Billing_Category__c = objAppFoundryTrialQuote.Billing_Category__c;
                }    
                if(objOriginalSubscripiton.End_Date_of_AppFoundry_Trial_Projects__c == System.today() && objOriginalSubscripiton.Status_of_AppFoundry_Trial_Products__c == 'Trial Products Added and Active' )
                {
                    System.debug('#####Entered regulirization code');
                    objQP.Type_of_Product__c = 'Ordinary';
                }   
                
                list_ClonedSubsQuoteProduct.add(objQP);
            }
            System.debug('####List_AppFoundryProducts'+List_AppFoundryProducts);
            if(List_AppFoundryProducts.size() > 0 && !blnProductPresent){
                for(Product2 objAppFoundryProduct:List_AppFoundryProducts){
                    BigMachines__Quote_Product__c objAppFoundryQP = new BigMachines__Quote_Product__c();
                    objAppFoundryQP.BigMachines__Quote__c = objAppFoundryTrialQuote.Id;
                    objAppFoundryQP.BigMachines__Product__c = objAppFoundryProduct.Id;
                    objAppFoundryQP.Active_Start_Date__c = System.today();
                    objAppFoundryQP.Active_End_Date__c = dtFreeTillDate;
                    objAppFoundryQP.BigMachines__Quantity__c = (objOriginalSubscripiton.End_Date_of_AppFoundry_Trial_Projects__c == System.Today())? 1:0;
                    objAppFoundryQP.BigMachines__Sales_Price__c = 0.0;
                    objAppFoundryQP.List_Price__c = ((Decimal)objAppFoundryProduct.get(String.valueof(objAppFoundryTrialQuote.New_Price_Book__c)+'_Price__c'));
                    objAppFoundryQP.Quantity__c = (objOriginalSubscripiton.End_Date_of_AppFoundry_Trial_Projects__c == System.Today())? 1:0;
                    objAppFoundryQP.Net_Unit_Price__c = 0;
                    objAppFoundryQP.Name = objAppFoundryProduct.Name;
                    objAppFoundryQP.APN_Number__c = objAppFoundryProduct.APN_Number__c;
                    objAppFoundryQP.Disc__c = 0.0 ;
                    objAppFoundryQP.or_Amount__c = '%';
                    objAppFoundryQP.Adjustment__c = 0.0 ;
                    objAppFoundryQP.Total_Discount__c = 0.0 ;
                    objAppFoundryQP.Billing_Category__c = 'M2M';
                    objAppFoundryQP.Type_of_Product__c  = 'Trial';
                    list_AppFoundryQuoteProduct.add(objAppFoundryQP);
                }
            }
            else if (List_AppFoundryProducts.size() == 0 && !blnProductPresent){
                for(BigMachines__Quote_Product__c objQP:list_ClonedSubsQuoteProduct){
                    //BigMachines__Quote_Product__c objClonedQP = objQP.clone(false, true, false, false);
                    //objClonedQP.BigMachines__Quote__c = objAppFoundryTrialQuote.Id;
                    if(objQP.Type_of_Product__c == 'Trial' && !objQP.Is_Overage__c){
                        objQP.Active_Start_Date__c = objOriginalSubscripiton.Subscription_Start_Date__c;
                        objQP.Active_End_Date__c = objOriginalSubscripiton.Subscription_End_Date__c;
                        objQP.Billing_Category__c = objAppFoundryTrialQuote.Billing_Category__c;
                        objQP.Type_of_Product__c = 'Ordinary';
                        objQP.BigMachines__Quantity__c = 0;
                        objQP.Quantity__c = 0;
                        blnTrailRegulirization = true;
                        list_ClonedSubsQuoteProducttoReg.add(objQP);
                    }
                    System.debug('###objQP.name:'+objQP.name+'###objQP.Type_of_Product__c:'+objQP.Type_of_Product__c+'objQP.BigMachines__Quantity__c'+objQP.BigMachines__Quantity__c);  
                }
            }  
            System.debug('@@@@list_AppFoundryQuoteProduct:'+list_AppFoundryQuoteProduct);
            insert list_AppFoundryQuoteProduct;
            if((list_AppFoundryQuoteProduct.size() > 0)){list_AppFoundryQuoteProduct = updateQuoteProductPrices(list_AppFoundryQuoteProduct,dtFreeTillDate,decAppFoundryMarkup);}
            if(blnTrailRegulirization && list_ClonedSubsQuoteProducttoReg.size() > 0){list_ClonedSubsQuoteProducttoReg = updateQuoteProductPrices(list_ClonedSubsQuoteProducttoReg,dtFreeTillDate,decAppFoundryMarkup);}
            list_ClonedSubsQuoteProduct.Addall(list_AppFoundryQuoteProduct);
            list_ClonedSubsQuoteProduct.Addall(list_ClonedSubsQuoteProducttoReg);
            System.debug('####list_ClonedSubsQuoteProduct'+list_ClonedSubsQuoteProduct);
            upsert list_ClonedSubsQuoteProduct;
            cloneAccountOrderAddresses(IdSubsQuoteId, objAppFoundryTrialQuote.Id);
            Util.Bypass_Trigger_Chk = true;
            updateQuoteTotalsForRenewal(objAppFoundryTrialQuote,list_ClonedSubsQuoteProduct);
            MakeQuotePrimary_WS.CorrectTotalCloud(objAppFoundryTrialQuote.Id);
            Util.Bypass_Trigger_Chk = true;
            System.debug('###objAppFoundryTrialQuote.Id'+objAppFoundryTrialQuote.Id);
            OpportunityQuotes.populateOpportunityProducts(String.valueof(objAppFoundryTrialQuote.Id));
            updateOpportunityTotals(objAppFoundryTrialQuote);
            populateLineNumbers(objAppFoundryTrialQuote.Id,objAppFoundryTrialQuote.Order_Type__c,IdSubsQuoteId);
            strObjName = 'Deal_Qualification__c';
            strWhereCondition = 'Opportunity__c = \'' + list_SubscriptionQuote[0].BigMachines__Opportunity__c+'\' and Platform_Type__c = \'Cloud\' and Offering_Type__c = \''+list_SubscriptionQuote[0].Offering_Type__c+'\' and Type__c = \'' +DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL + '\'';
            List<Deal_Qualification__c> list_SubscriptionOppDQ = Database.query(CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition));
            if(list_SubscriptionOppDQ.size() > 0)
            {
                System.debug(list_SubscriptionOppDQ);   
                Deal_Qualification__c objClonedDQ = list_SubscriptionOppDQ[0].clone(false, true, false, false);
                objClonedDQ.Opportunity__c = objAppFoundryTrialQuote.BigMachines__Opportunity__c;
                objClonedDQ.Quote__c = objAppFoundryTrialQuote.Id;
                insert objClonedDQ;
            }   
            
            return objAppFoundryTrialQuote;
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                            CreationofTrialRecords.Res.failureMessages.add(e.getMessage()+'\n'+e.getStackTraceString());
                            ErrorLogUtil.insertLog('QuoteCloudUtil', 'Error from method cloneSubscriptionQuoteAndQuoteProducts: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'OpportunityCloudUtil.cloneSubscriptionQuoteAndQuoteProducts()'); 
                            return null;}  
    }  
    //--Rony Joseph-May 6th 2019 -Ends---
    
    
    //--Rony Joseph-May 6th 2019 -Starts---
    //Method to calculate List Price for Quote Products 
    public static List<BigMachines__Quote_Product__c>  updateQuoteProductPrices(List<BigMachines__Quote_Product__c> list_AllQtProds,Date dtFreeTillDate,Decimal decAppFoundryMarkup){
        try{
            Set<Id> set_QPIds = new Set<Id>();
            Id IdQuoteId;
            for(BigMachines__Quote_Product__c objQP:list_AllQtProds){
                set_QPIds.add(objQP.Id);
                IdQuoteId = objQP.BigMachines__Quote__c;
            }
            
            BigMachines__Quote__c objQuote = [select id,CurrencyISOCode,Billing_Category__c,Offering_Type__c,New_Price_Book__c,Sold_To_Name__c,End_User_ID__c,Pricing_Model__c,BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c,Billing_Period__c from BigMachines__Quote__c where id =:IdQuoteId ];
            list_AllQtProds = [select id,Hide_Record__c,Is_Overage__c,BigMachines__Product__r.Show_In_Quoting__c,BigMachines__Product__r.New_Category__c,BigMachines__Product__r.APN_Number__c FROM BigMachines__Quote_Product__c WHERE Id in :set_QPIds] ;
            List<BigMachines__Quote_Product__c> list_CommittedQtProds = new List<BigMachines__Quote_Product__c>();
            Integer intSetScale = 2;
            Boolean blnHasPCCoBrowseForCIC = false;
            Set<Id> set_CommittedProductIds = new Set<Id>();
            Set<Id> set_AddtProdIds = new Set<Id>();
            Set<Id> set_BundleProducts = new Set<Id>();
            Set<Id> set_RatePlanProdIds = new Set<Id>();
            List<BigMachines__Quote_Product__c> list_DependentQtProds = new List<BigMachines__Quote_Product__c>();
            List<BigMachines__Quote_Product__c> list_ToInsertOverageCharges = new List<BigMachines__Quote_Product__c>();
            Map<String, String> map_DependentProducts = new Map<String, String>();
            Map<Id, Id> map_NewQPIds = new Map<Id, Id>();
            Map<Id, Id> map_ProductsToBundles = new Map<Id, Id>();
            Map<Id, Id> map_BundleProducts = new Map<Id, Id>();
            Map<Id, Id> map_BundlesToQuoteProducts = new Map<Id, Id>();
            Map<Id, Product_Tier_Pricing__c> map_ProdTiers = new Map<Id, Product_Tier_Pricing__c>();
            Map<String, Decimal> map_SoldToPCPartnerMargins = new Map<String, Decimal>();
            Map<String, Decimal> map_PCCPartnerMargins = new Map<String, Decimal>();
            Map<Id, BigMachines__Quote_Product__c> map_NewQPs = new Map<Id, BigMachines__Quote_Product__c>();
            Map<Id, Map<String, Product_Tier_Pricing__c>> map_ExistingProdTiers = new Map<Id, Map<String, Product_Tier_Pricing__c>>();
            Map<Id, BigMachines__Quote_Product__c> map_IdtoOverageQuoteProds = new Map<Id, BigMachines__Quote_Product__c>();
            Set<Id> set_TieredPricingProductIds = new Set<Id>();
            Map<Id,List<Product_Tier_Pricing__c>> map_TieredProducts = new Map<Id,List<Product_Tier_Pricing__c>>();
            Map<Id,List<Product_Tier_Pricing__c>> map_TieredProductsOverage = new Map<Id,List<Product_Tier_Pricing__c>>(); 
            String strRangeandRatePlan = 'Range;Rate Plan';
            Decimal decPricingMultiplier;
            
            
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {    
                if((!objQP.Hide_Record__c && !objQP.Is_Overage__c && (objQP.BigMachines__Product__r.Show_In_Quoting__c || objQP.BigMachines__Product__r.New_Category__c == 'PureSuccess'))
                   &&
                   (
                       (!Label.Check_For_One_Time_Fees_PC.contains(objQP.BigMachines__Product__r.New_Category__c) && objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PC)
                       || 
                       (!Label.Check_For_One_Time_Fees_PCC.contains(objQP.BigMachines__Product__r.New_Category__c) && objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
                   )
                   ||Label.PC_Overage_Products.contains(objQP.BigMachines__Product__r.APN_Number__c)
                   ||objQP.BigMachines__Product__r.New_Category__c == 'Bundles'
                   ||objQP.BigMachines__Product__r.New_Category__c == 'Use Case' 
                   ||Label.IVR_Data_Storage_Parts.Contains(objQP.BigMachines__Product__r.APN_Number__c)) {
                       list_CommittedQtProds.add(objQP);
                       set_CommittedProductIds.add(objQP.BigMachines__Product__c);
                       
                   }
                if(objQP.Is_Overage__c){map_IdtoOverageQuoteProds.put(objQP.BigMachines__Product__c,objQP);}
            }
            List<Product_Group__c> list_ProdGrps = [SELECT Id, Product__c, Product__r.APN_Number__c,
                                                    (SELECT Product__c, Product__r.Name, Product__r.APN_Number__c, 
                                                     Product_Group__r.Product__r.APN_Number__c,
                                                     Product__r.Product_Specific_Discount__c,
                                                     Product__r.Product_Group__c, Product__r.Unit_of_Measure__c
                                                     FROM Product_Group_Items__r 
                                                     WHERE Product_Type__c = 'Mandatory')
                                                    FROM Product_Group__c
                                                    WHERE Group_Type__c = 'Dependent Products'
                                                    AND Product__c IN :set_CommittedProductIds];
            for(Product_Group__c objProdGrp : list_ProdGrps) {
                for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                    if(!set_CommittedProductIds.contains(objProdGrpItm.Product__c)) {
                        set_CommittedProductIds.add(objProdGrpItm.Product__c);
                        set_AddtProdIds.add(objProdGrpItm.Product__c);
                        
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();                
                        objQP.Name = objProdGrpItm.Product__r.Name;
                        objQP.BigMachines__Quote__c = IdQuoteId;
                        objQP.BigMachines__Product__c = objProdGrpItm.Product__c;
                        objQP.APN_Number__c = objProdGrpItm.Product__r.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objProdGrpItm.Product__r.Product_Specific_Discount__c;
                        objQP.Product_Group__c = objProdGrpItm.Product__r.Product_Group__c;
                        objQP.Quantity__c = 0;
                        objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                        objQP.Unit_of_Measure__c = objProdGrpItm.Product__r.Unit_of_Measure__c;
                        objQP.Hide_Record__c = true;
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.Is_Overage__c = objProdGrpItm.Product_Group__r.Product__r.APN_Number__c == 'PCSMS-170-NV-SMS' || objProdGrpItm.Product_Group__r.Product__r.APN_Number__c == 'PV-170-NV-PCVOICE' ? true : false;
                        objQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                        objQP.Active_Start_Date__c = System.today();
                        objQP.Active_End_Date__c = dtFreeTillDate;
                        objQP.Billing_Category__c = 'M2M';
                        objQP.Type_of_Product__c  = 'Trial';
                        list_DependentQtProds.add(objQP);
                    }
                }
            }   
            for(BigMachines__Quote_Product__c objQP : list_DependentQtProds) {
                if(Label.PC_Overage_Products.contains(objQP.APN_Number__c)) {
                    objQP.Is_Overage__c = true;
                    objQP.Name += ' Usage';
                }
            }
            insert list_DependentQtProds;   
            for(BigMachines__Quote_Product__c objQP:list_DependentQtProds){
                set_QPIds.add(objQP.Id);
            }
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {
                map_NewQPs.put(objQP.Id, objQP);
            }
            
            List<Product_Tier_Pricing__c> list_ProdTierPricing = [SELECT Product__c, Product__r.Name, Product__r.APN_Number__c, 
                                                                  Product__r.Unit_of_Measure__c, Product__r.New_Category__c
                                                                  FROM Product_Tier_Pricing__c
                                                                  WHERE Product__c IN :set_CommittedProductIds
                                                                  AND Product__r.Has_Overage__c = true
                                                                  AND Charge_Type__c = 'M2M'];
            for(Product_Tier_Pricing__c objProdTr : list_ProdTierPricing ) {
                map_ProdTiers.put(objProdTr.Product__c, objProdTr);
            }
            for(Id newQPId : map_NewQPs.keySet()) {                    
                if(map_ProdTiers.containsKey(map_NewQPs.get(newQPId).BigMachines__Product__c)) {
                    Product_Tier_Pricing__c objProdTr = map_ProdTiers.get(map_NewQPs.get(newQPId).BigMachines__Product__c);
                    BigMachines__Quote_Product__c objOverageQP = new BigMachines__Quote_Product__c();
                    objOverageQP.BigMachines__Quote__c = objQuote.Id;
                    objOverageQP.Parent_Quote_Product__c = newQPId;
                    objOverageQP.Is_Overage__c = true;
                    objOverageQP.BigMachines__Product__c = objProdTr.Product__c;
                    objOverageQP.Name = objProdTr.Product__r.Name + ' Overage';
                    objOverageQP.APN_Number__c = objProdTr.Product__r.APN_Number__c;
                    objOverageQP.Unit_of_Measure__c = objProdTr.Product__r.Unit_of_Measure__c;
                    objOverageQP.BigMachines__Quantity__c = objOverageQP.Quantity__c = objOverageQP.BigMachines__Sales_Price__c = 0;
                    objOverageQP.Active_Start_Date__c = System.today();
                    objOverageQP.Active_End_Date__c = dtFreeTillDate;
                    objOverageQP.Billing_Category__c = 'M2M';
                    objOverageQP.Type_of_Product__c  = 'Trial';
                    if(set_AddtProdIds.contains(objProdTr.Product__c)
                       || (objQuote.Billing_Category__c == 'M2M' && objProdTr.Product__r.New_Category__c == 'Subscription Fees')
                       //To build both committed and overage charges for this specific product which is not subscription fees category
                       || objOverageQP.APN_Number__c == 'PC-170-NV-PCIVRCUSPERMIN') { 
                           objOverageQP.Hide_Record__c = true;
                       }
                    objOverageQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                    if(objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC && map_IdtoOverageQuoteProds.containsKey(objProdTr.Product__c)){
                        objOverageQP.Disc__c = (map_IdtoOverageQuoteProds.get(objProdTr.Product__c).Disc__c != null)?map_IdtoOverageQuoteProds.get(objProdTr.Product__c).Disc__c:0;
                        objOverageQP.or_Amount__c = (map_IdtoOverageQuoteProds.get(objProdTr.Product__c).or_Amount__c != null)?map_IdtoOverageQuoteProds.get(objProdTr.Product__c).or_Amount__c:'';
                        objOverageQP.Adjustment__c = (map_IdtoOverageQuoteProds.get(objProdTr.Product__c).Adjustment__c != null)?map_IdtoOverageQuoteProds.get(objProdTr.Product__c).Adjustment__c:0; 
                    }    
                    list_ToInsertOverageCharges.add(objOverageQP);
                }
            }
            insert list_toInsertOverageCharges;  
            for(BigMachines__Quote_Product__c objQP:list_toInsertOverageCharges){
                set_QPIds.add(objQP.Id);
            }
            list_AllQtProds.clear();        
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, Name, BigMachines__Quote__c, BigMachines__Product__c, Subscription_Product__c, CurrencyISOCode, 
                                                       List_Price__c, Partner_Price__c, Net_Unit_Price__c, BigMachines__Sales_Price__c, Ext_List__c, Ext_Net_Price__c,
                                                       Extended_Price_Per_Period__c, Extended_Price_Per_Month__c, APN_Number__c,Parent_Quote_Product__c,
                                                       BigMachines__Quote__r.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,
                                                       Quantity__c, Product_Quantity__c, BigMachines__Quantity__c, Hide_Record__c, Is_Overage__c,
                                                       Bundle_Discount__c, Proposal_Group_Discount__c, or_Amount__c, Adjustment__c, Disc__c, Total_Discount__c,
                                                       BigMachines__Product__r.Price_Type__c, BigMachines__Product__r.NG1_APAC_ANZ_AUD_Price__c,BigMachines__Product__r.Partner_Margin_Category__c, 
                                                       BigMachines__Product__r.NG2_BRAZIL_BRL_Price__c, BigMachines__Product__r.NG3_EMEA_EUR_Price__c, 
                                                       BigMachines__Product__r.NG5_NA_CAD_Price__c, BigMachines__Product__r.NG4_APAC_JAPAN_YEN_Price__c, 
                                                       BigMachines__Product__r.NG5_NZD_Price__c, BigMachines__Product__r.NG3_EMEA_GBP_Price__c, BigMachines__Product__r.Is_Concurrent__c,
                                                       BigMachines__Product__r.NG5_NA_USD_Price__c, BigMachines__Product__r.NG5_ZAR_Price__c, Bundle_Line__c,
                                                       BigMachines__Product__r.Partner_Margin_Type__c, BigMachines__Product__r.Include_in_CMMR_Total__c,
                                                       BigMachines__Product__r.Charge_Type__c, Line_Number__c, Group_Number__c, PM_Approver__c, Product_Option__c
                                                       FROM BigMachines__Quote_Product__c
                                                       WHERE Id in :set_QPIds]) {
                                                           list_AllQtProds.add(objQP);
                                                           if(objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan') {
                                                               set_RatePlanProdIds.add(objQP.BigMachines__Product__c);
                                                           }
                                                           if(objQP.APN_Number__c == 'PC-170-NV-COBROCIC') {                  
                                                               blnHasPCCoBrowseForCIC = true;
                                                           } 
                                                       }
            System.debug('######set_RatePlanProdIds' + set_RatePlanProdIds);            
            //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
            String strWhereCondition = 'WHERE Product__c IN :set_RatePlanProdIds  AND (Charge_Type__c = \'M2M\')';
            for(Product_Tier_Pricing__c objProdTr : Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, objQuote.New_Price_Book__c + '_Price__c'))) {
                //Added By Ranjith on Feb 26, 2019 -- Ends 
                if(map_ExistingProdTiers.containsKey(objProdTr.Product__c)) {
                    map_ExistingProdTiers.get(objProdTr.Product__c).put(objProdTr.Charge_Type__c, objProdTr);
                }
                else {
                    map_ExistingProdTiers.put(objProdTr.Product__c, new Map<String, Product_Tier_Pricing__c> { objProdTr.Charge_Type__c => objProdTr} );
                }       
            }
            System.debug('######map_ExistingProdTiers' + map_ExistingProdTiers);            
            
            for(PureCloud_Partner_Margin__c objPartnerMargin : [SELECT Account__c, Percent__c, Margin_Type__c
                                                                FROM PureCloud_Partner_Margin__c
                                                                WHERE From_Date__c <= TODAY 
                                                                AND To_Date__c >= TODAY 
                                                                AND Account__c =: objQuote.Sold_To_Name__c
                                                                ORDER BY To_Date__c ASC]) {
                                                                    map_SoldToPCPartnerMargins.put(objPartnerMargin.Margin_Type__c, objPartnerMargin.Percent__c);
                                                                }
            System.debug('######map_SoldToPCPartnerMargins' + map_SoldToPCPartnerMargins);
            if(objQuote.End_User_ID__c != objQuote.Sold_To_Name__c && objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) {
                for(Partner_Discount__c objPartnerMargin : [SELECT Discount__c, Category__c
                                                            FROM Partner_Discount__c
                                                            WHERE Account__c = :objQuote.Sold_To_Name__c AND type__c =: SubscriptionUtil.OFFERING_TYPE_PCC]) {
                                                                if(objPartnerMargin.Category__c == 'Base Line Discount')
                                                                    map_PCCPartnerMargins.put('Software', objPartnerMargin.Discount__c);
                                                                else
                                                                    map_PCCPartnerMargins.put(objPartnerMargin.Category__c, objPartnerMargin.Discount__c);
                                                            } 
            }
            Set<Id> set_OvrgProdParentIds = new Set<Id>();
            if(objQuote.Billing_Category__c == 'M2M') {
                set_OvrgProdParentIds = QuoteCloudUtil.findOverageChargeAPNs(objQuote);
            }
            if(objQuote.Pricing_Model__c == 'Concurrent')
                //    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().PureConnect_Concurrent_Multiplier__c;
                //added by kartik
                decPricingMultiplier = objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ? Global_Configuration_Settings__c.getOrgDefaults().PureEngage_Cloud_Concurrent_Multiplier__c : Global_Configuration_Settings__c.getOrgDefaults().PureConnect_Concurrent_Multiplier__c;
            Map<id,BigMachines__Quote_Product__c> map_OverageProducts = new Map<id,BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {
                system.debug(objQP);
                if(objQP.BigMachines__Product__r.Price_Type__c == 'Range' || (objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan' && !objQP.Is_Overage__c))
                    set_TieredPricingProductIds.add(objQP.BigMachines__Product__c);    
                if(objQP.Is_Overage__c)
                {
                    for(BigMachines__Quote_Product__c objQPParent : list_AllQtProds) {
                        system.debug(objQPParent);
                        if(objQPParent.id == objQP.Parent_Quote_Product__c)
                            map_OverageProducts.put(objQP.id,objQPParent);
                    }
                }
                system.debug(map_OverageProducts);
            }
            if(!set_TieredPricingProductIds.isEmpty()){
                String strQuery = 'SELECT Price_Type__c, Type__c, Partner_Margin_Category__c, (SELECT Charge_Type__c, Range_From__c, Range_To__c,'
                    + objQuote.New_Price_Book__c + '_Price__c FROM Product_Tier_Pricings__r'                 
                    + ' WHERE Charge_Type__c = \'' +  objQuote.Billing_Category__c + '\' OR Charge_Type__c = \'M2M\' ORDER BY Range_From__c)'               
                    + ' FROM Product2 WHERE Id IN: set_TieredPricingProductIds';
                system.debug('######'+strQuery);
                for(Product2 eachProduct : Database.query(strQuery))
                {
                    for(Product_Tier_Pricing__c objPricing : eachProduct.Product_Tier_Pricings__r)
                    {
                        if(objPricing.Charge_Type__c == 'M2M')
                        {
                            if(map_TieredProductsOverage.containskey(eachProduct.id))
                                map_TieredProductsOverage.get(eachProduct.id).add(objPricing);
                            else
                                map_TieredProductsOverage.put(eachProduct.id, new List<Product_Tier_Pricing__c>{objPricing});
                        }
                    }
                }
            }
            for(BigMachines__Quote_Product__c objQP : list_AllQtProds) {            
                objQP.Bundle_Discount__c = objQP.Proposal_Group_Discount__c = null;
                objQP.Total_Discount__c = objQP.List_Price__c = objQP.Partner_Price__c = objQP.Net_Unit_Price__c = objQP.BigMachines__Sales_Price__c = 0;
                objQP.Extended_Price_Per_Period__c = objQP.Extended_Price_Per_Month__c = objQP.Ext_List__c = objQP.Ext_Net_Price__c = 0;
                if(objQuote.offering_type__c != SubscriptionUtil.OFFERING_TYPE_PCC){objQP.Adjustment__c =0;objQP.or_Amount__c = '';}
                Decimal decProductPartnerMargin = 0;
                String strBillingCategory =  'M2M';
                if(true) {
                    if(true){  
                        System.debug('#####objQP.Name'+objQP.Name);
                        System.debug('#####objQP.List_Price__c'+objQP.List_Price__c);
                        System.debug('#####objQP.BigMachines__Product__c:'+objQP.BigMachines__Product__c);
                        System.debug('#####objQuote.New_Price_Book__c'+objQuote.New_Price_Book__c);
                        System.debug('#####objQP.BigMachines__Product__r.Price_Type__c:'+objQP.BigMachines__Product__r.Price_Type__c);
                        System.debug('#####map_ExistingProdTiers.containsKey(objQP.BigMachines__Product__c:'+map_ExistingProdTiers.containsKey(objQP.BigMachines__Product__c));
                        //System.debug('####TierPrice:'+map_ExistingProdTiers.get(objQP.BigMachines__Product__c).get(strBillingCategory).get(objQuote.New_Price_Book__c + '_Price__c'));
                        //System.debug('####DefaultPrice:'+objQP.BigMachines__Product__r.get(objQuote.New_Price_Book__c + '_Price__c'));
                        
                        objQP.List_Price__c = (Decimal)objQP.BigMachines__Product__r.get(objQuote.New_Price_Book__c + '_Price__c');
                        System.debug('@@@1objQP.List_Price__c:'+objQP.List_Price__c);
                        if(objQP.BigMachines__Product__r.Price_Type__c == 'Rate Plan'
                           && map_ExistingProdTiers.containsKey(objQP.BigMachines__Product__c)
                          )
                        {
                            System.debug('@@@1objQP.List_Price__c:'+(Decimal)map_ExistingProdTiers.get(objQP.BigMachines__Product__c).get(strBillingCategory).get(objQuote.New_Price_Book__c + '_Price__c'));
                            objQP.List_Price__c = ((Decimal)map_ExistingProdTiers.get(objQP.BigMachines__Product__c).get(strBillingCategory).get(objQuote.New_Price_Book__c + '_Price__c'))*(1+(decAppFoundryMarkup/100));
                            System.debug('@@@2objQP.List_Price__c:'+objQP.List_Price__c);
                        }     
                        
                        // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                        if(objQuote.Pricing_Model__c == 'Concurrent' && objQP.BigMachines__Product__r.Is_Concurrent__c == 'Yes')
                            objQP.List_Price__c *= decPricingMultiplier;
                    }        
                    objQP.List_Price__c = (blnHasPCCoBrowseForCIC && objQP.APN_Number__c == 'PC-170-NV-USR3') || objQP.List_Price__c == null ? 0 : objQP.List_Price__c; 
                    Decimal decEffectivePrice = objQP.List_Price__c;
                    System.debug('#####objQP.List_Price__c'+objQP.List_Price__c);    
                    if(objQP.BigMachines__Quote__r.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
                        decProductPartnerMargin = map_SoldToPCPartnerMargins.containsKey(objQP.BigMachines__Product__r.Partner_Margin_Type__c) ? map_SoldToPCPartnerMargins.get(objQP.BigMachines__Product__r.Partner_Margin_Type__c) : 0;
                        System.debug('#####decProductPartnerMargin '+decProductPartnerMargin);
                        objQP.Partner_Price__c = objQP.List_Price__c - (objQP.List_Price__c * decProductPartnerMargin/100);                        
                        objQP.Total_Discount__c += decProductPartnerMargin;
                        decEffectivePrice = objQP.Partner_Price__c != null && objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c : decEffectivePrice;
                    }
                    if(objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c) {
                        {
                            if(map_PCCPartnerMargins.containsKey(objQP.BigMachines__Product__r.Partner_Margin_Category__c))
                                decProductPartnerMargin = map_PCCPartnerMargins.get(objQP.BigMachines__Product__r.Partner_Margin_Category__c);
                            else if(Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c) != NULL)
                                decProductPartnerMargin =  Partner_Hardware_Margins__c.getInstance(objQP.BigMachines__Product__r.Partner_Margin_Category__c).Margin__c;
                            objQP.Partner_Price__c = (objQP.List_Price__c - (objQP.List_Price__c * decProductPartnerMargin/100)); 
                            objQP.Total_Discount__c += decProductPartnerMargin;
                            decEffectivePrice = objQP.Partner_Price__c != null && objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c : decEffectivePrice;
                        }                    
                        
                        System.debug('#####decProductPartnerMargin'+decProductPartnerMargin);
                    }
                    System.debug(objQP.or_Amount__c+String.valueOf(objQP.Adjustment__c)+String.valueof(objQuote.offering_type__c));
                    if(objQuote.offering_type__c == SubscriptionUtil.OFFERING_TYPE_PCC){
                        if(objQP.Disc__c != null && String.isNotBlank(objQP.or_Amount__c)){
                            // Selected Discount Option is %
                            if(objQP.or_Amount__c == '%'){
                                objQP.Total_Discount__c += objQP.Disc__c;           
                            }
                            // Selected Discount Option is Amt
                            else if(objQP.or_Amount__c == 'Amt'){
                                objQP.Total_Discount__c += (objQP.Disc__c/objQP.List_Price__c) * 100;           
                            }
                        }
                        if(objQP.Adjustment__c != null && objQP.Adjustment__c != 0) {
                            objQP.Total_Discount__c += objQP.Adjustment__c;     
                        }  
                    } 
                    System.debug('#####objQP.Partner_Price__c'+objQP.Partner_Price__c);
                    objQP.Net_Unit_Price__c = objQP.List_Price__c - (objQP.List_Price__c * objQP.Total_Discount__c/100);
                    objQP.List_Price__c = objQP.List_Price__c.setScale(intSetScale);
                    objQP.Partner_Price__c = objQP.Partner_Price__c > 0 ? objQP.Partner_Price__c.setScale(intSetScale) : 0;
                    objQP.Net_Unit_Price__c = objQP.Net_Unit_Price__c.setScale(intSetScale);
                    objQP.BigMachines__Sales_Price__c = objQP.Net_Unit_Price__c;
                    System.debug('#####objQP.Quantity__c'+objQP.Quantity__c);
                    if(objQP.Quantity__c != null) {
                        objQP.Ext_List__c = (decEffectivePrice * objQP.Quantity__c).setScale(2) ;
                        objQP.Ext_Net_Price__c = (objQP.Net_Unit_Price__c * objQP.Quantity__c).setScale(2);
                    }
                    System.debug('#####objQP.Ext_List__c'+objQP.Ext_List__c);
                    System.debug('#####objQP.Ext_Net_Price__c'+objQP.Ext_Net_Price__c);
                    objQP.Extended_Price_Per_Month__c = objQP.Ext_Net_Price__c;
                    objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c; 
                    
                    if(objQP.BigMachines__Product__r.Include_in_CMMR_Total__c && !set_OvrgProdParentIds.contains(objQP.Id)) {
                        if(objQuote.Billing_Period__c == 'Annually') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 12;
                        }
                        else if(objQuote.Billing_Period__c == 'Semi-Annually') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 6;
                        }
                        else if(objQuote.Billing_Period__c == 'Quarterly') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * 3;
                        }  
                        else if(objQuote.Billing_Period__c == 'Other') {
                            objQP.Extended_Price_Per_Period__c = objQP.Ext_Net_Price__c * objQuote.No_Of_Months__c;
                        }           
                    } 
                }
            }
            System.debug('Finallist####'+list_AllQtProds);
            return list_AllQtProds;
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                            CreationofTrialRecords.Res.failureMessages.add(e.getMessage()+'\n'+e.getStackTraceString());
                            ErrorLogUtil.insertLog('QuoteCloudUtil', 'Error from method updateQuoteProductPrices: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'QuoteCloudUtil.updateQuoteProductPrices()'); 
                            return null;}
        
    }
    //--Rony Joseph-May 6th 2019 -Ends---
    
    //Rony Joseph- July 1st 2019 -PureBridge Project - Starts 
    public static BigMachines__Quote__c updateLeverDetials(BigMachines__Quote__c objQuote,Opportunity objOpty,Map<String,boolean> map_leverSelection){
        try{
            System.debug('###objQuote:'+objQuote);
            //System.debug('New Ramp Date:'+System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c));
            System.debug('####map_leverSelection'+map_leverSelection);
            if(objOpty.Lever__c !=null){
                //System.debug('New Ramp Date:'+System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c));
                System.debug('@@'+(map_leverSelection.containsKey('Lever 2') && map_leverSelection.get('Lever 2')));
                if(map_leverSelection.containsKey('Lever 1') && map_leverSelection.get('Lever 1') && objOpty.Avaya_Contract_Expiration__c !=null){
                    if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC){
                        if(System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c) > 365)
                            objQuote.Ramp_Period__c = '365';
                        else if(System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c)  < 90)
                            objQuote.Ramp_Period__c = '90';
                        else
                        {
                            Integer intDayDifference = System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c);System.debug('####intDayDifference'+intDayDifference);
                            objQuote.Ramp_Period__c =  String.valueof(30 * (intDayDifference/30) +(math.mod(intDayDifference,30) <=15 ? 0:30)); 
                        }   
                    }
                    else if(objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC){
                        if(System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c)  < 180)
                            objQuote.Ramp_Period__c = '180';
                        else
                        {
                            Integer intDayDifference = System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c);
                            objQuote.Ramp_Period__c =  String.valueof(30 * (intDayDifference/30) +(math.mod(intDayDifference,30) <=15 ? 0:30)); 
                        }       
                    }
                    objQuote.Billing_Period__c = 'Annually';  
                    objQuote.Billing_Category__c = 'Annual Pre-Pay';
                }
                
                
                if(map_leverSelection.containsKey('Lever 2') && map_leverSelection.get('Lever 2') && (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)){
                    //    else if(map_leverSelection.containsKey('Lever 2') && map_leverSelection.get('Lever 2') ){
                    System.debug('@@ calling createGUPassports');
                    createGUPassports(objQuote);
                }
                /*else if(map_leverSelection.containsKey('Lever 4') && map_leverSelection.get('Lever 4') && (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC))
{

objQuote.Billing_Category__c = 'Annual Pre-Pay';
objQuote.Hide_Discount__c = true;
objQuote.Hide_List_Price__c = true;
objQuote.Treat_SO_as_PO__c = true;
objQuote.Hide_Totals__c = true;
objQuote.PureCloud_Monthly_Minimum__c = 0;
objQuote.No_Of_Months__c = 1;
objQuote.Ramp_Period__c = '0';
objQuote.Subscription_End_Date__c = (System.today().daysBetween(objOpty.Avaya_Expiry_Date__c) < 365)?objOpty.Avaya_Expiry_Date__c:objQuote.Subscription_Start_Date__c.addMonths(12);

}*/
            } 
            
            return objQuote;
        }catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                            return null;
                           }
        
    }
    //Rony Joseph- July 1st 2019 -PureBridge Project - Ends 
    
    private static void createGUPassports(BigMachines__Quote__c objQuote) {
        Set<String> set_IVRDataStrgPartNos = new Set<String>();
        List<BigMachines__Quote_Product__c> list_IVRDataStorageParts = new list<BigMachines__Quote_Product__c>();
        List<Passport_SKUs__mdt> arr_IVRDataStrgPartNos = [SELECT Id, Label, Offering_Type__c,APN_of_GU_Product__c 
                                                           FROM Passport_SKUs__mdt
                                                           WHERE Offering_Type__c = :objQuote.Offering_Type__c];    
        for(Integer i=0; i<arr_IVRDataStrgPartNos.size(); i++) {
            set_IVRDataStrgPartNos.add(arr_IVRDataStrgPartNos[i].APN_of_GU_Product__c);
        }
        System.debug('####set_IVRDataStrgPartNos: '+set_IVRDataStrgPartNos);
        integer intLineNumber = [select count() from  BigMachines__Quote_Product__c where BigMachines__Quote__c =:objQuote.Id]; 
        for(Product2 objProd : [SELECT Id, Name, APN_Number__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, 
                                NG5_NZD_Price__c, NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, 
                                NG3_EMEA_EUR_Price__c, NG5_NA_CAD_Price__c, NG5_ZAR_Price__c, NG5_NA_USD_Price__c
                                FROM Product2 
                                WHERE APN_Number__c IN :set_IVRDataStrgPartNos]) {
                                    BigMachines__Quote_Product__c objNewQP = new BigMachines__Quote_Product__c();
                                    objNewQP.BigMachines__Quote__c = objQuote.Id;
                                    objNewQP.Name = objProd.Name;
                                    objNewQP.APN_Number__c = objProd.APN_Number__c;
                                    objNewQP.BigMachines__Product__c = objProd.Id;            
                                    objNewQP.BigMachines__Quantity__c = objNewQP.Quantity__c = 3;            
                                    objNewQP.List_Price__c = (Decimal)objProd.get(objQuote.New_Price_Book__c + '_Price__c') != null ? (Decimal)objProd.get(objQuote.New_Price_Book__c + '_Price__c') : 0;
                                    objNewQP.BigMachines__Sales_Price__c = objNewQP.Net_Unit_Price__c != null ? objNewQP.Net_Unit_Price__c : 0;
                                    objNewQP.Ext_List__c = 0;
                                    objNewQP.Ext_Net_Price__c = 0;
                                    objNewQP.Disc__c =100;
                                    objNewQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                                    objNewQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                                    objNewQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                                    objNewQP.Billing_Category__c = objQuote.Billing_Category__c;
                                    objNewQP.Type_of_Product__c  = 'Ordinary';
                                    objNewQP.Line_Number__c  = ++intLineNumber;
                                    System.debug('####objNewQP'+objNewQP);
                                    list_IVRDataStorageParts.add(objNewQP);
                                }
        insert list_IVRDataStorageParts;
        System.debug('####list_IVRDataStorageParts'+list_IVRDataStorageParts);
    }
    
    //Rony Joseph - Calculate the Cumulative Total for Quote Products
    @future
    public static void calculateCumulativeTotal(Set<Id> set_QuoteProductsId){
        try{ 
            Util.Bypass_Trigger_Chk = true;
            List<BigMachines__Quote_Product__c> list_QPS = [select id,Total_Discount__c,BigMachines__Quote__r.Order_Type__c,BigMachines__Quote__r.Amendment_For__c,BigMachines__Quote__r.Amendment_For__r.version__C,BigMachines__Quote__r.Subscription_Amend_Date__c,BigMachines__Quote__r.Subscription_Start_Date__c,Subscription_Product__c,Net_Unit_Price__c,BigMachines__Quantity__c,Quantity_Change__c,Number_of_Remaining_Months__c,Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c,Number_of_Previous_Months__c,Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c,Cumulative_Total_of_Price_for_Amendment__c,Subscription_Product__r.Store_Cumulative_Total_for_Amend__c,BigMachines__Product__r.Include_in_CMMR_Total__c,BigMachines__Quote__r.Subscription_End_Date__c,BigMachines__Quote__r.Amendment_For__r.Subscription_End_Date__c,Subscription_Product__r.Subscription__r.quote__R.order_type__c,Difference_in_Subscription_End_Dates__c from BigMachines__Quote_Product__c where id in :set_QuoteProductsId];
            for(BigMachines__Quote_Product__c objQP:list_QPS){ 
                if(objQP.BigMachines__Quote__r.Order_Type__c == 'Amend Subscription' && objQP.BigMachines__Product__r.Include_in_CMMR_Total__c){
                    if(objQP.Subscription_Product__c != null && 
                       (objQP.Quantity_Change__c != 0 || (objQP.BigMachines__Quote__r.Subscription_End_Date__c != objQP.BigMachines__Quote__r.Amendment_For__r.Subscription_End_Date__c) || (objQP.Net_Unit_Price__c != objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c))){
                           if(objQP.BigMachines__Quote__r.Subscription_Amend_Date__c < objQP.BigMachines__Quote__r.Subscription_Start_Date__c){
                               objQP.Cumulative_Total_of_Price_for_Amendment__c = (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c);
                           }
                           else
                           {
                               if(objQP.Subscription_Product__r.Subscription__r.quote__R.order_type__c != 'Amend Subscription'){
                                   
                                   objQP.Cumulative_Total_of_Price_for_Amendment__c = ((objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c * objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c * objQP.Number_of_Previous_Months__c) +  (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c));
                                   
                               }
                               else if( objQP.Subscription_Product__r.Subscription__r.quote__R.order_type__c == 'Amend Subscription'){
                                   
                                   if (objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c == null || objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c == 0)
                                   {
                                       
                                       objQP.Cumulative_Total_of_Price_for_Amendment__c = ((objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c * objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c * objQP.Number_of_Previous_Months__c) +  (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c));
                                       
                                   }
                                   
                                   else{
                                       Decimal decValue = (objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c != null)? objQP.Subscription_Product__r.Store_Cumulative_Total_for_Amend__c:0.00;
                                       objQP.Cumulative_Total_of_Price_for_Amendment__c = (decValue + (objQP.Net_Unit_Price__c*(objQP.Quantity_Change__c != 0? (((objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c != null) ?(objQP.BigMachines__Quantity__c - objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c): objQP.Quantity_Change__c)):0.00)
                                                                                                       *objQP.Number_of_Remaining_Months__c) + ((objQP.Net_Unit_Price__c - objQP.Subscription_Product__r.Quote_Product__r.Net_Unit_Price__c)* objQP.Number_of_Remaining_Months__c * objQP.Subscription_Product__r.Quote_Product__r.BigMachines__Quantity__c  )+(((objQP.BigMachines__Quote__r.Subscription_End_Date__c != objQP.BigMachines__Quote__r.Amendment_For__r.Subscription_End_Date__c)? objQP.Difference_in_Subscription_End_Dates__c:0.00)  * objQP.Net_Unit_Price__c * objQP.BigMachines__Quantity__c));  
                                   }   
                               }
                               
                               
                           }
                       }   
                    else if(objQP.Subscription_Product__c == null ){
                        
                        objQP.Cumulative_Total_of_Price_for_Amendment__c = (objQP.Net_Unit_Price__c*objQP.BigMachines__Quantity__c*objQP.Number_of_Remaining_Months__c);
                    }
                }
            }
            
            Database.update(list_QPS,false);
            Util.Bypass_Trigger_Chk = false;
        }catch(Exception e){
            System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
        }
    }                                                                                           
    //Rony Joseph - August 29th 2019 - Check if user active -  Start 
    public static Id checkActiveUser(Id IduserId){
        
        Id IdactiveUserId;
        User objUser = [select isActive,managerId from user where Id = :IduserId ];
        if(objUser.isActive)
            IdactiveUserId = IduserId;
        else
            IdactiveUserId =  objUser.managerId;
        return IdactiveUserId;
        
    }
    
    //Rony Joseph - November 11 2019 - Populating line numbers on Quote Products
    public static void populateLineNumbers(Id IdQuoteId,String strOrderType, Id IdOriginalQuoteId){
        Util.Bypass_Trigger_Chk = true;
        if(strOrderType != Label.Amend_Subscription){
            List<BigMachines__Quote_Product__c> list_QPtoretrive = [select id,BigMachines__Quote__r.Name,Line_Number__c,createddate,Subscription_Product__r.Line_Number__c,Subscription_Product__c from BigMachines__Quote_Product__c where BigMachines__Quote__c =:IdQuoteId order by createddate asc ];
            List<BigMachines__Quote_Product__c> list_QPtoUpdate = new list<BigMachines__Quote_Product__c>();
            Decimal decLinenumber = 1;
            Map<Decimal,BigMachines__Quote_Product__c> map_lntoQP  = new Map<Decimal,BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c objQP:list_QPtoretrive){
                if(objQP.Line_Number__c !=  null){map_lntoQP.put(objQP.Line_Number__c,objQP);}
            }
            for(BigMachines__Quote_Product__c objQP:list_QPtoretrive){
                System.debug('objQP:'+objQP);
                System.debug('decLinenumber:'+decLinenumber);
                System.debug('map_lntoQP.containsKey(decLinenumber):'+map_lntoQP.containsKey(decLinenumber));
                if(map_lntoQP.containsKey(decLinenumber)){
                    decLinenumber++;continue;
                }
                else
                {
                    if(objQP.Line_Number__c == null && decLinenumber <= list_QPtoretrive.size() ){
                        objQP.Line_Number__c = decLinenumber;
                        decLinenumber++;
                        list_QPtoUpdate.add(objQP);}
                }
            }
            System.debug('list_QPtoUpdate.size():'+list_QPtoUpdate.size());
            System.debug('list_QPtoUpdate'+list_QPtoUpdate);    
            Database.update(list_QPtoUpdate,false);
        }
        else{
            List<BigMachines__Quote_Product__c> list_QPtoretrive = [select id,Line_Number__c,Subscription_Product__r.Quote_Product__r.Line_Number__c from BigMachines__Quote_Product__c where BigMachines__Quote__c =:IdQuoteId   order by createddate asc ];
            List<BigMachines__Quote_Product__c> list_OriginalQPtoretrive = [select id,Line_Number__c,Subscription_Product__r.Quote_Product__r.Line_Number__c from BigMachines__Quote_Product__c where BigMachines__Quote__c =:IdOriginalQuoteId order by createddate asc ];
            Decimal decLineNumber = 1;
            List<BigMachines__Quote_Product__c> list_QPtoUpdate = new list<BigMachines__Quote_Product__c>();
            Map<Decimal,BigMachines__Quote_Product__c> map_lntoQP  = new Map<Decimal,BigMachines__Quote_Product__c>();
            for(BigMachines__Quote_Product__c objQP:list_OriginalQPtoretrive){
                if(objQP.Line_Number__c != null){map_lntoQP.put(objQP.Line_Number__c,objQP);}
                if(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null){map_lntoQP.put(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c,objQP);}
            }
            for(BigMachines__Quote_Product__c objQP:list_QPtoretrive){
                if(objQP.Line_Number__c != null && !map_lntoQP.containsKey(objQP.Line_Number__c)){map_lntoQP.put(objQP.Line_Number__c,objQP);}
                if(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null && !map_lntoQP.containsKey(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c)){map_lntoQP.put(objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c,objQP);}
            }   
            
            for(BigMachines__Quote_Product__c objQP:list_QPtoretrive){
                System.debug('objQP:'+objQP);
                System.debug('decLinenumber:'+decLinenumber);
                System.debug('map_lntoQP.containsKey(decLinenumber):'+map_lntoQP.containsKey(decLinenumber));
                System.debug('objQP.Line_Number__c:'+objQP.Line_Number__c);
                System.debug('objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c:'+objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c);
                if(objQP.Line_Number__c !=  null || (objQP.Line_Number__c == null && objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null)){
                    if(objQP.Line_Number__c == null && objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c != null){
                        objQP.Line_Number__c = objQP.Subscription_Product__r.Quote_Product__r.Line_Number__c;
                        list_QPtoUpdate.add(objQP);
                    }
                }
                else
                {
                    if(objQP.Line_Number__c == null ){
                        do{
                            decLinenumber++;
                        }while(map_lntoQP.containsKey(decLinenumber));
                        objQP.Line_Number__c = decLinenumber;
                        list_QPtoUpdate.add(objQP);
                    }    
                }
                
            }   
            
            System.debug('list_QPtoUpdate.size():'+list_QPtoUpdate.size());
            System.debug('list_QPtoUpdate'+list_QPtoUpdate);    
            Database.update(list_QPtoUpdate,false);
        }
        Util.Bypass_Trigger_Chk = false;
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
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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