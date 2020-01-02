/* @Class Name   : PublicGroupReportController 
 * @Description  : This is a controller class for preparing the Vf template which needs to be sent as RFP weekly support table.
 * @Created On   : 17/08/2018 
 */
public with sharing class PublicGroupReportControllerOpen {  
    // sfdc URL of the instance
    public String sfdcURL {get;set;}
    
    public string strMessage {get;set;}
    
    //public List<BigMachines__Quote_Product__c> quoteProdList {get;set;}
    //public List<Order_Line_Item__c> lstOrderQuoteOPPData {get;set;}
    public List<BigMachines__Quote_Product__c> lstQuotePrdOPPData {get;set;}
    
    public Map<string,List<BigMachines__Quote_Product__c>> listData {get;set;}
    public String reportName {get;set;}
    
    public string orgCurr {get; set;}
 
    
    
    public PublicGroupReportControllerOpen(){
        
        strMessage ='';
        loadReport();
    }
    
    
    public List<BigMachines__Quote_Product__c> loadReport(){
        
    Dynamic_Query__c dynamicQueryRec = [Select Process_Name__c,Query_type__c,Query_Name__c,Report_Name__c
                                        from Dynamic_Query__c
                                        where Process_Name__c = 'Default'];
    //Org Default Currency
    orgCurr = UserInfo.getDefaultCurrency();
 
 //Query corrected by JJ
 //Commented as Dynamic Query is built
/*
 lstOrderQuoteOPPData = [select id,Name,Order__r.Name,Product__r.APN_Number__c,Product__r.Name,Order__r.Quote__r.BigMachines__Opportunity__r.Name,
                        Order__r.Quote__r.Quote_Number__c,Order__r.Quote__r.BigMachines__Opportunity__c,
                        Order__r.Quote__r.BigMachines__Opportunity__r.ACV_Subscription_Only__c,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Account.Name,
                        Order__r.Quote__r.BigMachines__Opportunity__r.createddate,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Source_Order__r.Name,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Actual_Closed_Date__c,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Term_Commitment__c,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Type,
                        Order__r.Quote__r.BigMachines__Opportunity__r.StageName,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Contact__r.Name,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Owner.Name,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Sold_to_Business_Partner_Sap_Code__c,
                        Order__r.Quote__r.BigMachines__Opportunity__r.TotalOpportunityQuantity,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Invoice__c,
                        Order__r.Quote__r.Billing_Period__c,
                        Order__r.Quote__r.Initial_Subscription_Term__c,
                        Order__r.Quote__r.Ramp_Period__c,
                        Order__r.Quote__r.Sub_Region__c,
                        Order__r.Quote__r.AE_Rep_Email__c,
                        Ext_Net_Price__c,BigMachines_Quantity__c,
                        List_Price__c,
                        Order__r.Quote__r.BigMachines__Opportunity__r.Source_Order__r.Sales_Channel__c 
                        from Order_Line_Item__c where 
                        Order__r.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c = 'PureCloud' and Order__r.Quote__r.BigMachines__Opportunity__r.StageName = '6.Closed' and
                        Order__r.Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c = 'Won' and
                        Order__r.Quote__r.BigMachines__Is_Primary__c = true and
                        (Product__r.APN_Number__c  like '%pureins%' OR
                        Product__r.Name like '%pureins%')
                        Order By Order__r.Quote__r.BigMachines__Opportunity__r.Name];       
 */

                        string query = 'select id,Name,APN_Number__c,BigMachines__Quote__r.BigMachines__Opportunity__r.Name,';
                        query += ' BigMachines__Quote__r.Quote_Number__c,BigMachines__Quote__r.BigMachines__Opportunity__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Annual_Contract_Value__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Account.Name,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.createddate,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Source_Order__r.Name,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Actual_Closed_Date__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Term_Commitment__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Type,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.StageName,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.BusinessPartner__r.Name,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.CloseDate,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Contact__r.Name,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Owner.Name,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Owner.Email,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.SubRU__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_To_Country__r.Name,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Sold_to_Business_Partner_Sap_Code__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.TotalOpportunityQuantity,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Invoice__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Country_Sub_Region__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Country_Region__c,';
                        
                        query += ' BigMachines__Quote__r.createddate,';
                        query += ' BigMachines__Quote__r.Billing_Period__c,';
                        query += ' BigMachines__Quote__r.Initial_Subscription_Term__c,';
                        query += ' BigMachines__Quote__r.Ramp_Period__c,';
                        query += ' BigMachines__Quote__r.Sub_Region__c,';
                        query += ' BigMachines__Quote__r.Sold_To_Region__c,';
                        query += ' BigMachines__Quote__r.AE_Rep_Email__c,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.ACV_Subscription_Only__c,';
                        query += ' Ext_Net_Price__c,Quantity__c,';
                        query += ' List_Price__c,';
                        query += ' CurrencyIsoCode,';
                        query += ' BigMachines__Quote__r.BigMachines__Opportunity__r.Source_Order__r.Sales_Channel__c';
                        query += ' from BigMachines__Quote_Product__c  ';
                        
                        
                        
                        
                        string labelvalue = 'Default'; 
                        
                        //Using Dynamic_Query__c Default Record
                        if(dynamicQueryRec != null){
                            
                            query += dynamicQueryRec.Query_type__c;
                        }
                        
                        //query += Label.Default;
                        query += ' Order By BigMachines__Quote__r.BigMachines__Opportunity__r.Name';
                        
                        query += ' LIMIT 49999';
                        
      
        system.debug(query);
        lstQuotePrdOPPData = Database.query(query);
        
        if(lstQuotePrdOPPData.size()<= 0)
            strMessage = 'Report doesn\'t have data';
        
        //Fetching conversion Rate -- Start
        Map<String,Double> currencyToConversionRateMap = new Map<String,Double>();
        String supportedISOCodesQ = 'SELECT ConversionRate,IsoCode FROM CurrencyType WHERE IsActive=TRUE';
        List<CurrencyType> pListSupportedISOCodes = Database.query(supportedISOCodesQ);

        for(CurrencyType currType : pListSupportedISOCodes){
            
            currencyToConversionRateMap.put(currType.IsoCode,currType.ConversionRate);
            
        }
        //Fetching conversion Rate -- END
        
        Set<ID> setOPPID = new Set<ID>();
        for(BigMachines__Quote_Product__c obj : lstQuotePrdOPPData)
            setOPPID.add(obj.BigMachines__Quote__r.BigMachines__Opportunity__c);
        
        system.debug(setOPPID);
        listData = new Map<string,List<BigMachines__Quote_Product__c>>();

        if(dynamicQueryRec != null){
            reportName = dynamicQueryRec.Report_Name__c;
            
        }

        for(ID objOPPID : setOPPID)
        {
            List<BigMachines__Quote_Product__c> objOPPData = new List<BigMachines__Quote_Product__c>();
            string OPPName = '';
            for(BigMachines__Quote_Product__c objOL : lstQuotePrdOPPData)
            {
                if(objOPPID == objOL.BigMachines__Quote__r.BigMachines__Opportunity__c)
                {
                    system.debug('Enter');
                    
                    //Conversion....this field is used -- Added By Anshul
                    if(!currencyToCOnversionRateMap.isEmpty()){
                        
                        Decimal value =0.0;
                        value = objOL.BigMachines__Quote__r.BigMachines__Opportunity__r.Annual_Contract_Value__c/currencyToCOnversionRateMap.get(objOL.CurrencyIsoCode);
                        objOL.BigMachines__Quote__r.BigMachines__Opportunity__r.ACV_Subscription_Only__c = value.setScale(2);
                    }
                    
                    objOPPData.add(objOL);
                    OPPName = objOL.BigMachines__Quote__r.BigMachines__Opportunity__r.Name;
                    
                }
                
            }
            system.debug(objOPPData);
            listData.put(OPPName,objOPPData);
            
        }       
        
        return lstQuotePrdOPPData ;
    }
    
    
   
}