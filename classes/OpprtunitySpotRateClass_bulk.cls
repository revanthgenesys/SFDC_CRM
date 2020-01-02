public class OpprtunitySpotRateClass_bulk {
    
    public static void dailySpotRateBulk(){
        Id cloudRenewalRecTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cloud Renewal').getRecordTypeId();
        Id genRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        List<string> lstRecordTypes = new List<string>{genRecordTypeId,genRecordTypeId};
        List<string> lstWinorLosss = new List<string>{'Lost','Merged/Dup Opp'};
        date dt = date.today()-45;
        string country = 'USD';
        Map<string,ERP_Currency_Daily_Exchange_Rate__c> exchangeRateMap = new Map<string,ERP_Currency_Daily_Exchange_Rate__c>();
        List<Opportunity> lstOpps=[SELECT id,name,CloseDate,CurrencyIsoCode,Spot_Rate_from_Order__c,Spot_Rate__c 
                                   FROM opportunity WHERE CurrencyIsoCode != 'USD' 
                                   AND CloseDate != null 
                                   AND closedate > :dt
                                   AND Win_Loss_Status__c  NOT IN :lstWinorLosss
                                   AND Spot_Rate__c = NULL
                                   AND Has_PS__c =false
                                   AND Cloud_Renewal__c = false
                                   AND amount !=0
                                   AND recordtypeId IN :lstRecordTypes];
                                   //AND ForecastStatus__c ='0.Booked'];
        set<string> periodSet = new set<string>();
        set<string> currencyIsoSet = new set<string>();
        
        for(opportunity objOpp :lstOpps){
           String strPeriod = objOpp.CloseDate.Month() + '-' + objOpp.CloseDate.Year();  
            periodSet.add(strPeriod);
            currencyIsoSet.add(objOpp.CurrencyIsoCode);
        }
        List<ERP_Currency_Daily_Exchange_Rate__c> listOfExchangeRate = [SELECT id,Period_Month_Year__c FROM ERP_Currency_Daily_Exchange_Rate__c
                                                                        WHERE Period_Month_Year__c IN : periodSet 
                                                                        AND FROM_CURRENCY_CODE__c IN: currencyIsoSet
                                                                        AND TO_CURRENCY_CODE__c = 'USD' 
                                                                        AND EXCHANGE_RATE_TYPE__c = 'DAILY' 
                                                                        AND lastmodifieddate>2018-04-18T14:01:00-04:00];
     
        for(ERP_Currency_Daily_Exchange_Rate__c ECDER : listOfExchangeRate){
            exchangeRateMap.put(ECDER.Period_Month_Year__c,ECDER);
        }
        List<Opportunity> lstResultedOpps = new List<opportunity>();
        for(opportunity opp : lstOpps){
            String strPeriod = opp.CloseDate.Month() + '-' + opp.CloseDate.Year();
            if(exchangeRateMap.containsKey(strPeriod)){
                if(exchangeRateMap.get(strPeriod).Period_Month_Year__c == strPeriod){
                    opp.Spot_Rate__c=exchangeRateMap.get(strPeriod).Id;
                    lstResultedOpps.add(opp);
                }
            }
        }
        if(!lstResultedOpps.isEmpty()){
            update lstResultedOpps;
        }
    }
	public static void forecastSpotRateBulk(){
        date dt = date.newInstance(2019, 07, 1);
		date dt1 = date.newInstance(2019, 07, 31);
        Id genRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        Map<string,ERP_Currency_Daily_Exchange_Rate__c> exchangeRateMap = new Map<string,ERP_Currency_Daily_Exchange_Rate__c>();
        List<Opportunity> lstOpps=[SELECT id,name,CloseDate,CurrencyIsoCode,Spot_Rate_from_Order__c,Spot_Rate__c 
                                   FROM opportunity 
                                   WHERE CurrencyIsoCode != 'USD' 
                                   AND Cloud_Renewal__c = false
                                   AND recordtypeId =: genRecordTypeId
                                   AND Spot_Rate_from_Order__c= false 
                                   AND CloseDate != null
                           		   AND closedate >:dt and closedate <:dt1
                                   AND Has_PS__c =false
                                   AND amount !=0
                                   AND ForecastStatus__c ='0.Booked'];
        set<string> periodSet = new set<string>();
        set<string> currencyIsoSet = new set<string>();
        
        for(opportunity objOpp :lstOpps){
           String strPeriod = objOpp.CloseDate.Month() + '-' + objOpp.CloseDate.Year();  
            periodSet.add(strPeriod);
            currencyIsoSet.add(objOpp.CurrencyIsoCode);
        }
        List<ERP_Currency_Daily_Exchange_Rate__c> listOfExchangeRate = [SELECT id,Period_Month_Year__c FROM ERP_Currency_Daily_Exchange_Rate__c
                                                                        WHERE Period_Month_Year__c IN : periodSet 
                                                                        AND FROM_CURRENCY_CODE__c IN: currencyIsoSet
                                                                        AND TO_CURRENCY_CODE__c = 'USD' 
                                                                        AND EXCHANGE_RATE_TYPE__c = 'FORECAST' 
                                                                        AND lastmodifieddate>2018-04-18T14:01:00-04:00];
     
        for(ERP_Currency_Daily_Exchange_Rate__c ECDER : listOfExchangeRate){
            exchangeRateMap.put(ECDER.Period_Month_Year__c,ECDER);
        }
        List<Opportunity> lstResultedOpps = new List<opportunity>();
        for(opportunity opp : lstOpps){
            String strPeriod = opp.CloseDate.Month() + '-' + opp.CloseDate.Year();
            if(exchangeRateMap.containsKey(strPeriod)){
                if(exchangeRateMap.get(strPeriod).Period_Month_Year__c == strPeriod){
                    opp.Spot_Rate__c=exchangeRateMap.get(strPeriod).Id;
                    lstResultedOpps.add(opp);
                }
            }
        }
        if(!lstResultedOpps.isEmpty()){
            update lstResultedOpps;
        }
    }

}