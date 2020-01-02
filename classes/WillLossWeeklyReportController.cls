//Naresh Kumar  09/08/2014
public without sharing class WillLossWeeklyReportController {   
    public String sfdcURL {get; private set;}
    public List<wrapperResult> getOpps(){
        sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String query = Label.Win_Loss_Weekly_Report_Query;
        List<wrapperResult> wrapperResults = new List<wrapperResult>();     
        Set<String> setOfRegions = new Set<String>();
        Map<String, Decimal> mapOfCurrencyVsConversionRate = new Map<String, Decimal>();
        for(CurrencyType eachCT : [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE IsActive = true]){
        	mapOfCurrencyVsConversionRate.put(eachCT.isoCode, eachCT.ConversionRate);
        }
        //Looping over each record
        for(Opportunity eachOpp : (List<Opportunity>)Database.query(query)){
            if(!setOfRegions.contains(eachOpp.Country__r.Region__c)){            	
                wrapperResult headerRecord = new wrapperResult();
                headerRecord.isHeaderRecord = true;
                headerRecord.headerName = eachOpp.Country__r.Region__c;
                wrapperResults.add(headerRecord);
                setOfRegions.add(eachOpp.Country__r.Region__c);
            }
            Decimal conversionRate = mapOfCurrencyVsConversionRate.get(eachOpp.currencyIsoCode) == null ? 1 : mapOfCurrencyVsConversionRate.get(eachOpp.currencyIsoCode);
            wrapperResult newRecord = new wrapperResult();
            newRecord.licenseAmount = (eachOpp.License_Amount__c == null ? 0 : (eachOpp.License_Amount__c / conversionRate));
            newRecord.acv = (eachOpp.Annual_Contract_Value__c == null ? 0 : (eachOpp.Annual_Contract_Value__c / conversionRate));
            newRecord.record = eachOpp;
            newRecord.isHeaderRecord = false;
            wrapperResults.add(newRecord);          
        }
        if(wrapperResults.isEmpty()){
            wrapperResult headerRecord = new wrapperResult();
            headerRecord.isHeaderRecord = true;
            headerRecord.headerName = 'No Opportunity found.';
            wrapperResults.add(headerRecord);
        }
        
        return wrapperResults;
    }
    
    public class wrapperResult{
        public Opportunity record {get;set;}
        public Double licenseAmount {get;set;}
        public Double acv {get;set;}
        public String headerName {get;set;}
        public Boolean isHeaderRecord {get;set;}
    }
}