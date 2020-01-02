global class OpportunityDailyRateUpdate_Batch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //date dt = date.newInstance(2019, 07, 1);
		//date dt1 = date.newInstance(2019, 07, 31);
		date dt = date.today()-30;
        date dt1 = date.today();
        String forecastStatus = '\''+ '0.Booked' + '\'';
        //+' FROM opportunity WHERE id ='+testID + 'AND CurrencyIsoCode !='+country 
        Id genRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        String country = '\''+ 'USD' + '\'';String testID = '\''+ '0060r000002o4wp' + '\'';
        String query = 'SELECT id,name,CloseDate,CurrencyIsoCode,Spot_Rate_from_Order__c,Spot_Rate__c' 
                        +' FROM opportunity WHERE CurrencyIsoCode !='+country 
                        +' AND Cloud_Renewal__c = false' 
                        +' AND recordtypeId =: genRecordTypeId'
                        +' AND Spot_Rate_from_Order__c= false'
                        +' AND CloseDate != null'
                        +' AND closedate >:dt and closedate <:dt1'
                        +' AND Has_PS__c =false'
                        +' AND amount !=0'
                        +' AND ForecastStatus__c ='+forecastStatus;	
        system.debug('query**** '+query);
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<opportunity> oppList) {
       system.debug('oppList ****** '+oppList);
        Map<string,ERP_Currency_Daily_Exchange_Rate__c> exchangeRateMap = new Map<string,ERP_Currency_Daily_Exchange_Rate__c>();
		set<string> periodSet = new set<string>();
        set<string> currencyIsoSet = new set<string>();
        
        for(opportunity objOpp :oppList){
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
        for(opportunity opp : oppList){
            String strPeriod = opp.CloseDate.Month() + '-' + opp.CloseDate.Year();
            system.debug('strPeriod****'+strPeriod);
            system.debug('exchangeRateMap****'+exchangeRateMap);
            if(exchangeRateMap.containsKey(strPeriod)){
                system.debug('it has**** '+exchangeRateMap.get(strPeriod).Period_Month_Year__c );
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
    
    global void finish(Database.BatchableContext BC) {
    	// execute any post-processing operations
  }

}